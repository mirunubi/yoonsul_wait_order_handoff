-- Migration: 0178_order_request_identity_and_numbering.sql
-- Workpacket: 602050
-- Runtime Gate RG-05: stable order request identity and atomic numbering.
-- Scope: seven public orders-writer signatures, six direct wrappers,
-- and one internal run_integration_test writer update.
-- The wrapper boundary receives p_request_id and forwards it unchanged.
-- Function return types, security attributes, and ACLs are preserved.

BEGIN;

CREATE TABLE catchmenu_pos.order_number_allocators (
  tenant_id uuid NOT NULL,
  store_id uuid NOT NULL,
  business_day date NOT NULL,
  last_value bigint NOT NULL CHECK (last_value > 0),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT order_number_allocators_pkey
    PRIMARY KEY (store_id, business_day),
  CONSTRAINT order_number_allocators_tenant_fkey
    FOREIGN KEY (tenant_id) REFERENCES catchmenu_hq.tenants(id),
  CONSTRAINT order_number_allocators_store_fkey
    FOREIGN KEY (store_id) REFERENCES catchmenu_hq.stores(id)
);

ALTER TABLE catchmenu_pos.orders
  DROP CONSTRAINT uq_orders_store_number;

ALTER TABLE catchmenu_pos.orders
  ADD CONSTRAINT uq_orders_store_business_day_number
  UNIQUE (store_id, business_day, order_number);

-- The old uq_orders_store_number backing index is dropped with its constraint.

-- catchmenu_pos.create_order(uuid, uuid, uuid, text, text, jsonb, text, text, text, text)
CREATE OR REPLACE FUNCTION catchmenu_pos.create_order(p_tenant_id uuid, p_store_id uuid, p_session_id uuid, p_order_type text, p_order_channel text, p_items jsonb, p_request_id text, p_memo text DEFAULT NULL::text, p_special_requests text DEFAULT NULL::text, p_correlation_id text DEFAULT NULL::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'catchmenu_pos', 'catchmenu_store', 'catchmenu_ledger', 'catchmenu_audit', 'catchmenu_common', 'catchmenu_hq'
AS $function$
declare
  v_rg05_key text;
  v_rg05_request_hash text;
  v_rg05_existing_hash text;
  v_rg05_existing_result jsonb;
  v_rg05_result jsonb;
  v_rg05_sequence bigint;
  v_rg05_order_number text;
  v_rg04_tenant_status text;
  v_rg04_isolation_state text;
  v_session record;
  v_order_id uuid;
  v_order_number text;
  v_total_amount int := 0;
  v_final_amount int := 0;
  v_item jsonb;
  v_menu record;
  v_item_amount int;
  v_options_amount int;
  v_kitchen_zone_summary jsonb := '{}'::jsonb;
  v_business_day date;
  v_timezone text;
  v_order_count int;
begin
  perform catchmenu_common.assert_caller_tenant_scope(p_tenant_id);

  select t.tenant_status, t.isolation_state
  into v_rg04_tenant_status, v_rg04_isolation_state
  from catchmenu_hq.tenants t
  where t.id = p_tenant_id;

  if v_rg04_tenant_status is null
     or v_rg04_tenant_status not in ('ACTIVE', 'TRIAL')
     or v_rg04_isolation_state is distinct from 'NONE'
  then
    return jsonb_build_object(
      'success', false,
      'error_key', 'tenant_order_creation_blocked'
    );
  end if;

  -- RG-05: stable request identity. The advisory lock serializes equal
  -- canonical keys until the first transaction records its result.
  if nullif(btrim(p_request_id), '') is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'order_request_id_required'
    );
  end if;

  v_rg05_key := pg_catalog.encode(
    extensions.digest(
      pg_catalog.convert_to(
        jsonb_build_object(
          'tenant_id', p_tenant_id,
          'store_id', p_store_id,
          'session_id', p_session_id,
          'operation', 'catchmenu_pos.create_order',
          'request_id', p_request_id
        )::text,
        'UTF8'
      ),
      'sha256'
    ),
    'hex'
  );
  v_rg05_request_hash := pg_catalog.encode(
    extensions.digest(
      pg_catalog.convert_to(
        jsonb_build_array(
          p_tenant_id,
      p_store_id,
      p_session_id,
      p_order_type,
      p_order_channel,
      p_items,
      p_memo,
      p_special_requests
        )::text,
        'UTF8'
      ),
      'sha256'
    ),
    'hex'
  );

  perform pg_catalog.pg_advisory_xact_lock(
    pg_catalog.hashtextextended(v_rg05_key, 0)
  );

  select ik.request_hash, ik.result_payload
  into v_rg05_existing_hash, v_rg05_existing_result
  from catchmenu_common.idempotency_keys ik
  where ik.tenant_id = p_tenant_id
    and ik.key_domain = 'order'
    and ik.idempotency_key = v_rg05_key;

  if found then
    update catchmenu_common.idempotency_keys
    set last_received_at = now(),
        replay_count = replay_count + 1
    where tenant_id = p_tenant_id
      and key_domain = 'order'
      and idempotency_key = v_rg05_key;

    if v_rg05_existing_hash is distinct from v_rg05_request_hash then
      return jsonb_build_object(
        'success', false,
        'error_key', 'IDEMPOTENCY_PAYLOAD_CONFLICT'
      );
    end if;

    if v_rg05_existing_result is not null then
      return v_rg05_existing_result;
    end if;

    return jsonb_build_object(
      'success', false,
      'error_key', 'order_request_in_progress'
    );
  end if;

  -- store timezone
  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(v_timezone, now()))::date;

  -- session validation
  select id, session_type, session_status,
         table_id, guest_count, guest_locale,
         business_day, business_timezone
  into v_session
  from catchmenu_pos.order_sessions
  where id = p_session_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
  for update;

  if v_session.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'session_not_found'
    );
  end if;

  if v_session.session_status not in (
    'SEATED', 'ORDERING', 'WAITING', 'ORDER_CONFIRMED'
  ) then
    return jsonb_build_object(
      'success', false,
      'error_key', 'session_not_orderable',
      'current_status', v_session.session_status
    );
  end if;

  -- items validation
  if p_items is null or jsonb_array_length(p_items) = 0 then
    return jsonb_build_object(
      'success', false,
      'error_key', 'order_items_required'
    );
  end if;

  insert into catchmenu_pos.order_number_allocators (
    tenant_id, store_id, business_day, last_value,
    created_at, updated_at
  ) values (
    p_tenant_id, p_store_id, v_business_day, 1,
    now(), now()
  )
  on conflict (store_id, business_day) do update
  set last_value = catchmenu_pos.order_number_allocators.last_value + 1,
      updated_at = now()
  returning last_value into v_rg05_sequence;

  v_order_number := lpad(v_rg05_sequence::text, 4, '0');

  -- create order header
  insert into catchmenu_pos.orders (
    tenant_id, store_id, session_id, table_id,
    order_number, order_type, order_status,
    order_channel, guest_count, guest_locale,
    memo, special_requests,
    total_amount, discount_amount, final_amount,
    ordered_at, correlation_id,
    business_day, business_timezone,
    idempotency_key
  ) values (
    p_tenant_id, p_store_id, p_session_id,
    v_session.table_id,
    v_order_number, p_order_type, 'PENDING',
    p_order_channel,
    v_session.guest_count,
    v_session.guest_locale,
    p_memo, p_special_requests,
    0, 0, 0,
    now(), p_correlation_id,
    v_business_day, v_timezone,
    v_rg05_key
  )
  returning id into v_order_id;

  -- process each order item
  for v_item in select * from jsonb_array_elements(p_items)
  loop
    -- fetch menu
    select id, menu_code, menu_name, price,
           kitchen_zone, estimated_minutes,
           is_kds_required, menu_status, allergen_info
    into v_menu
    from catchmenu_pos.menus
    where id = (v_item->>'menu_id')::uuid
      and store_id = p_store_id
      and is_active = true;

    if v_menu.id is null then
      -- rollback by raising exception
      raise exception 'menu_not_found:% ', v_item->>'menu_id';
    end if;

    if v_menu.menu_status = 'SOLD_OUT' then
      raise exception 'menu_sold_out:%', v_menu.menu_name;
    end if;

    -- calculate amounts
    v_options_amount := coalesce(
      (v_item->>'options_amount')::int, 0
    );
    v_item_amount := (v_menu.price + v_options_amount)
      * (v_item->>'quantity')::int;
    v_total_amount := v_total_amount + v_item_amount;

    -- track kitchen zones
    if v_menu.kitchen_zone is not null then
      v_kitchen_zone_summary := jsonb_set(
        v_kitchen_zone_summary,
        array[v_menu.kitchen_zone],
        to_jsonb(
          coalesce(
            (v_kitchen_zone_summary->>v_menu.kitchen_zone)::int, 0
          ) + (v_item->>'quantity')::int
        )
      );
    end if;

    -- insert order item
    insert into catchmenu_pos.order_items (
      tenant_id, store_id, order_id, menu_id,
      menu_code_snapshot, menu_name_snapshot,
      unit_price_snapshot, quantity, item_amount,
      selected_options, options_amount,
      kitchen_zone_snapshot, estimated_minutes_snapshot,
      is_kds_required_snapshot,
      allergen_displayed, allergen_locale_displayed,
      item_status, memo
    ) values (
      p_tenant_id, p_store_id, v_order_id, v_menu.id,
      v_menu.menu_code, v_menu.menu_name,
      v_menu.price,
      (v_item->>'quantity')::int,
      v_item_amount,
      coalesce(v_item->'selected_options', '[]'::jsonb),
      v_options_amount,
      v_menu.kitchen_zone,
      v_menu.estimated_minutes,
      v_menu.is_kds_required,
      coalesce((v_item->>'allergen_displayed')::boolean, false),
      v_item->>'allergen_locale',
      'PENDING',
      v_item->>'memo'
    );
  end loop;

  -- update order totals
  v_final_amount := v_total_amount;
  update catchmenu_pos.orders
  set
    total_amount = v_total_amount,
    final_amount = v_final_amount,
    kitchen_zone_summary = v_kitchen_zone_summary,
    updated_at = now()
  where id = v_order_id;

  -- update session order_id
  update catchmenu_pos.order_sessions
  set
    order_id = v_order_id,
    session_status = 'ORDERING',
    updated_at = now()
  where id = p_session_id;

  -- order event
  insert into catchmenu_pos.order_events (
    tenant_id, store_id, order_id,
    event_type, from_status, to_status,
    caused_by_type, event_payload,
    correlation_id, occurred_at
  ) values (
    p_tenant_id, p_store_id, v_order_id,
    'order_created', null, 'PENDING',
    'CUSTOMER',
    jsonb_build_object(
      'item_count', jsonb_array_length(p_items),
      'total_amount', v_total_amount,
      'kitchen_zones', v_kitchen_zone_summary
    ),
    p_correlation_id, now()
  );

  -- ledger event
  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, event_payload,
    session_id, order_id,
    correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'order', 'order_created', 1,
    'order', v_order_id,
    null, 'PENDING',
    'CUSTOMER',
    jsonb_build_object(
      'total_amount', v_total_amount,
      'item_count', jsonb_array_length(p_items),
      'order_number', v_order_number
    ),
    p_session_id, v_order_id,
    p_correlation_id,
    v_business_day, v_timezone, now()
  );

  v_rg05_result := jsonb_build_object(
    'success', true,
    'order_id', v_order_id,
    'order_number', v_order_number,
    'order_status', 'PENDING',
    'total_amount', v_total_amount,
    'final_amount', v_final_amount,
    'item_count', jsonb_array_length(p_items),
    'kitchen_zone_summary', v_kitchen_zone_summary
  );

  insert into catchmenu_common.idempotency_keys (
    tenant_id, store_id,
    idempotency_key, key_domain, key_scope,
    operation_type, request_hash,
    processing_status, result_payload,
    completed_at, last_received_at,
    correlation_id
  ) values (
    p_tenant_id, p_store_id,
    v_rg05_key, 'order', 'STORE',
    'catchmenu_pos.create_order', v_rg05_request_hash,
    'COMPLETED', v_rg05_result,
    now(), now(),
    p_correlation_id
  );

  return v_rg05_result;

exception
  when sqlstate '42501' then
    raise;
  when others then
    return jsonb_build_object(
      'success', false,
      'error_key', split_part(sqlerrm, ':', 1),
      'error_detail', split_part(sqlerrm, ':', 2)
    );
end;
$function$;

REVOKE ALL ON FUNCTION catchmenu_pos.create_order(uuid, uuid, uuid, text, text, jsonb, text, text, text, text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION catchmenu_pos.create_order(uuid, uuid, uuid, text, text, jsonb, text, text, text, text) TO postgres;
GRANT EXECUTE ON FUNCTION catchmenu_pos.create_order(uuid, uuid, uuid, text, text, jsonb, text, text, text, text) TO authenticated;
COMMENT ON FUNCTION catchmenu_pos.create_order(uuid, uuid, uuid, text, text, jsonb, text, text, text, text) IS 'Creates order from session cart.
   Validates all menu items availability before creating.
   Captures price snapshots at order time — never recalculated.
   Captures allergen display evidence per item.
   특허1: 주문 세션과 주문의 분리 — 세션은 주문 전에 독립 존재.';

-- catchmenu_pos.create_pre_order(uuid, uuid, uuid, jsonb, text, text, text)
CREATE OR REPLACE FUNCTION catchmenu_pos.create_pre_order(p_tenant_id uuid, p_store_id uuid, p_session_id uuid, p_items jsonb, p_request_id text, p_memo text DEFAULT NULL::text, p_correlation_id text DEFAULT NULL::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'catchmenu_pos', 'catchmenu_kds', 'catchmenu_ledger', 'catchmenu_common', 'catchmenu_hq'
AS $function$
declare
  v_rg05_key text;
  v_rg05_request_hash text;
  v_rg05_existing_hash text;
  v_rg05_existing_result jsonb;
  v_rg05_result jsonb;
  v_rg05_sequence bigint;
  v_rg05_order_number text;
  v_rg04_tenant_status text;
  v_rg04_isolation_state text;
  v_session record;
  v_settings record;
  v_order_id uuid;
  v_order_number text;
  v_total_amount int := 0;
  v_item jsonb;
  v_menu record;
  v_item_amount int;
  v_ticket_count int := 0;
  v_kitchen_zone_summary jsonb := '{}'::jsonb;
  v_business_day date;
  v_timezone text;
  v_order_count int;
  v_expire_at timestamptz;
begin
  perform catchmenu_common.assert_caller_tenant_scope(p_tenant_id);

  select t.tenant_status, t.isolation_state
  into v_rg04_tenant_status, v_rg04_isolation_state
  from catchmenu_hq.tenants t
  where t.id = p_tenant_id;

  if v_rg04_tenant_status is null
     or v_rg04_tenant_status not in ('ACTIVE', 'TRIAL')
     or v_rg04_isolation_state is distinct from 'NONE'
  then
    return jsonb_build_object(
      'success', false,
      'error_key', 'tenant_order_creation_blocked'
    );
  end if;

  -- RG-05: stable request identity. The advisory lock serializes equal
  -- canonical keys until the first transaction records its result.
  if nullif(btrim(p_request_id), '') is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'order_request_id_required'
    );
  end if;

  v_rg05_key := pg_catalog.encode(
    extensions.digest(
      pg_catalog.convert_to(
        jsonb_build_object(
          'tenant_id', p_tenant_id,
          'store_id', p_store_id,
          'session_id', p_session_id,
          'operation', 'catchmenu_pos.create_pre_order',
          'request_id', p_request_id
        )::text,
        'UTF8'
      ),
      'sha256'
    ),
    'hex'
  );
  v_rg05_request_hash := pg_catalog.encode(
    extensions.digest(
      pg_catalog.convert_to(
        jsonb_build_array(
          p_tenant_id,
      p_store_id,
      p_session_id,
      p_items,
      p_memo
        )::text,
        'UTF8'
      ),
      'sha256'
    ),
    'hex'
  );

  perform pg_catalog.pg_advisory_xact_lock(
    pg_catalog.hashtextextended(v_rg05_key, 0)
  );

  select ik.request_hash, ik.result_payload
  into v_rg05_existing_hash, v_rg05_existing_result
  from catchmenu_common.idempotency_keys ik
  where ik.tenant_id = p_tenant_id
    and ik.key_domain = 'order'
    and ik.idempotency_key = v_rg05_key;

  if found then
    update catchmenu_common.idempotency_keys
    set last_received_at = now(),
        replay_count = replay_count + 1
    where tenant_id = p_tenant_id
      and key_domain = 'order'
      and idempotency_key = v_rg05_key;

    if v_rg05_existing_hash is distinct from v_rg05_request_hash then
      return jsonb_build_object(
        'success', false,
        'error_key', 'IDEMPOTENCY_PAYLOAD_CONFLICT'
      );
    end if;

    if v_rg05_existing_result is not null then
      return v_rg05_existing_result;
    end if;

    return jsonb_build_object(
      'success', false,
      'error_key', 'order_request_in_progress'
    );
  end if;

  -- store timezone
  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  -- validate session
  select id, session_type, session_status,
         wait_number, guest_count, guest_locale,
         arrival_reliability_score,
         business_day, business_timezone
  into v_session
  from catchmenu_pos.order_sessions
  where id = p_session_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
  for update;

  if v_session.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'session_not_found'
    );
  end if;

  if v_session.session_status not in (
    'WAITING', 'ARRIVAL_PENDING'
  ) then
    return jsonb_build_object(
      'success', false,
      'error_key', 'session_not_pre_orderable',
      'current_status', v_session.session_status
    );
  end if;

  if v_session.session_type not in (
    'WAITING', 'PRE_ORDER'
  ) then
    return jsonb_build_object(
      'success', false,
      'error_key', 'session_type_not_pre_orderable',
      'session_type', v_session.session_type
    );
  end if;

  -- check pre-order settings
  select pre_order_enabled,
         pre_order_expire_minutes,
         arrival_reliability_threshold
  into v_settings
  from catchmenu_store.store_settings
  where store_id = p_store_id
    and tenant_id = p_tenant_id;

  if coalesce(v_settings.pre_order_enabled, true) = false then
    return jsonb_build_object(
      'success', false,
      'error_key', 'pre_order_disabled'
    );
  end if;

  -- check arrival reliability
  if coalesce(
    v_session.arrival_reliability_score, 100
  ) < coalesce(
    v_settings.arrival_reliability_threshold, 60
  ) then
    return jsonb_build_object(
      'success', false,
      'error_key', 'arrival_reliability_too_low',
      'score', v_session.arrival_reliability_score,
      'threshold', v_settings.arrival_reliability_threshold,
      'message', 'Customer no-show history prevents pre-order'
    );
  end if;

  -- validate items
  if p_items is null
    or jsonb_array_length(p_items) = 0
  then
    return jsonb_build_object(
      'success', false,
      'error_key', 'items_required'
    );
  end if;

  insert into catchmenu_pos.order_number_allocators (
    tenant_id, store_id, business_day, last_value,
    created_at, updated_at
  ) values (
    p_tenant_id, p_store_id, v_business_day, 1,
    now(), now()
  )
  on conflict (store_id, business_day) do update
  set last_value = catchmenu_pos.order_number_allocators.last_value + 1,
      updated_at = now()
  returning last_value into v_rg05_sequence;

  v_order_number := 'P-' || lpad(v_rg05_sequence::text, 4, '0');

  v_expire_at := now() + (
    coalesce(
      v_settings.pre_order_expire_minutes, 30
    ) || ' minutes'
  )::interval;

  -- create order
  insert into catchmenu_pos.orders (
    tenant_id, store_id, session_id,
    order_number, order_type,
    order_status, order_channel,
    guest_count, guest_locale,
    memo, ordered_at,
    total_amount, discount_amount, final_amount,
    correlation_id,
    business_day, business_timezone,
    idempotency_key
  ) values (
    p_tenant_id, p_store_id, p_session_id,
    v_order_number, 'DINE_IN',
    'PENDING', 'TABLE_QR',
    v_session.guest_count,
    v_session.guest_locale,
    p_memo, now(),
    0, 0, 0,
    p_correlation_id,
    v_business_day, v_timezone,
    v_rg05_key
  )
  returning id into v_order_id;

  -- process items and create HOLD KDS tickets
  for v_item in
    select * from jsonb_array_elements(p_items)
  loop
    select id, menu_code, menu_name, price,
           kitchen_zone, estimated_minutes,
           is_kds_required, menu_status,
           prep_complexity, peak_time_restricted
    into v_menu
    from catchmenu_pos.menus
    where id = (v_item->>'menu_id')::uuid
      and store_id = p_store_id
      and is_active = true;

    if v_menu.id is null then
      raise exception 'menu_not_found:%',
        v_item->>'menu_id';
    end if;

    if v_menu.menu_status = 'SOLD_OUT' then
      raise exception 'menu_sold_out:%',
        v_menu.menu_name;
    end if;

    v_item_amount := coalesce(
      (v_item->>'quantity')::int, 1
    ) * v_menu.price;
    v_total_amount := v_total_amount + v_item_amount;

    -- kitchen zone tracking
    if v_menu.kitchen_zone is not null then
      v_kitchen_zone_summary := jsonb_set(
        v_kitchen_zone_summary,
        array[v_menu.kitchen_zone],
        to_jsonb(
          coalesce(
            (v_kitchen_zone_summary
              ->>v_menu.kitchen_zone)::int,
            0
          ) + coalesce(
            (v_item->>'quantity')::int, 1
          )
        )
      );
    end if;

    -- insert order item
    insert into catchmenu_pos.order_items (
      tenant_id, store_id, order_id, menu_id,
      menu_code_snapshot, menu_name_snapshot,
      unit_price_snapshot, quantity, item_amount,
      selected_options, options_amount,
      kitchen_zone_snapshot,
      estimated_minutes_snapshot,
      is_kds_required_snapshot,
      allergen_displayed, item_status
    ) values (
      p_tenant_id, p_store_id, v_order_id, v_menu.id,
      v_menu.menu_code, v_menu.menu_name,
      v_menu.price,
      coalesce((v_item->>'quantity')::int, 1),
      v_item_amount,
      coalesce(v_item->'selected_options', '[]'::jsonb),
      0,
      v_menu.kitchen_zone,
      v_menu.estimated_minutes,
      v_menu.is_kds_required,
      false, 'PENDING'
    );

    -- create KDS ticket in HOLD
    -- 특허2: 사전주문 티켓 = 모든 조건 false로 시작
    if v_menu.is_kds_required then
      v_ticket_count := v_ticket_count + 1;

      insert into catchmenu_kds.kds_tickets (
        tenant_id, store_id,
        order_id, session_id,
        ticket_number, kds_status,
        hold_reason, kitchen_zone, priority,
        menu_name_snapshot, quantity_snapshot,
        estimated_minutes_snapshot,
        conditions_met,
        first_hold_at,
        business_day, business_timezone
      ) values (
        p_tenant_id, p_store_id,
        v_order_id, p_session_id,
        v_order_number || '-' ||
          lpad(v_ticket_count::text, 2, '0'),
        'HOLD',
        'PRE_ORDER_WAITING',
        v_menu.kitchen_zone, 5,
        v_menu.menu_name,
        coalesce((v_item->>'quantity')::int, 1),
        v_menu.estimated_minutes,
        -- 특허2: 7개 조건 모두 false로 시작
        jsonb_build_object(
          'arrived', false,
          'table_confirmed', false,
          'payment_confirmed', false,
          'kds_capacity_ok', false,
          'menu_available',
            v_menu.menu_status = 'AVAILABLE',
          'peak_time_ok',
            not v_menu.peak_time_restricted,
          'no_show_risk_ok',
            coalesce(
              v_session.arrival_reliability_score,
              100
            ) >= coalesce(
              v_settings.arrival_reliability_threshold,
              60
            )
        ),
        now(),
        v_business_day, v_timezone
      );
    end if;
  end loop;

  -- update order totals
  update catchmenu_pos.orders
  set
    total_amount = v_total_amount,
    final_amount = v_total_amount,
    kitchen_zone_summary = v_kitchen_zone_summary,
    updated_at = now()
  where id = v_order_id;

  -- update session
  update catchmenu_pos.order_sessions
  set
    session_type = 'PRE_ORDER',
    session_status = 'ORDER_CONFIRMED',
    order_id = v_order_id,
    pre_order_created_at = now(),
    pre_order_expires_at = v_expire_at,
    order_confirmed_at = now(),
    updated_at = now()
  where id = p_session_id;

  -- session event
  insert into catchmenu_pos.session_events (
    tenant_id, store_id, session_id,
    event_type, from_status, to_status,
    caused_by_type, event_payload,
    correlation_id, occurred_at
  ) values (
    p_tenant_id, p_store_id, p_session_id,
    'pre_order_created',
    v_session.session_status, 'ORDER_CONFIRMED',
    'CUSTOMER',
    jsonb_build_object(
      'order_id', v_order_id,
      'order_number', v_order_number,
      'total_amount', v_total_amount,
      'kds_tickets_created', v_ticket_count,
      'all_in_hold', true,
      'expires_at', v_expire_at
    ),
    p_correlation_id, now()
  );

  -- ledger event
  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, event_payload,
    session_id, order_id,
    correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'order', 'pre_order_created', 1,
    'order', v_order_id,
    null, 'PENDING',
    'CUSTOMER',
    jsonb_build_object(
      'order_number', v_order_number,
      'total_amount', v_total_amount,
      'kds_tickets_created', v_ticket_count,
      'all_in_hold', true,
      'wait_number', v_session.wait_number,
      'arrival_reliability_score',
        v_session.arrival_reliability_score
    ),
    p_session_id, v_order_id,
    p_correlation_id,
    v_business_day, v_timezone, now()
  );

  v_rg05_result := jsonb_build_object(
    'success', true,
    'order_id', v_order_id,
    'order_number', v_order_number,
    'session_id', p_session_id,
    'total_amount', v_total_amount,
    'kds_tickets_created', v_ticket_count,
    'all_tickets_in_hold', true,
    'pre_order_expires_at', v_expire_at,
    'wait_number', v_session.wait_number,
    'next_step', 'AWAIT_ARRIVAL_AND_PAYMENT',
    'message_code', 'pre_order_created'
  );

  insert into catchmenu_common.idempotency_keys (
    tenant_id, store_id,
    idempotency_key, key_domain, key_scope,
    operation_type, request_hash,
    processing_status, result_payload,
    completed_at, last_received_at,
    correlation_id
  ) values (
    p_tenant_id, p_store_id,
    v_rg05_key, 'order', 'STORE',
    'catchmenu_pos.create_pre_order', v_rg05_request_hash,
    'COMPLETED', v_rg05_result,
    now(), now(),
    p_correlation_id
  );

  return v_rg05_result;

exception
  when sqlstate '42501' then
    raise;
  when others then
    return jsonb_build_object(
      'success', false,
      'error_key', split_part(sqlerrm, ':', 1),
      'error_detail', split_part(sqlerrm, ':', 2)
    );
end;
$function$;

REVOKE ALL ON FUNCTION catchmenu_pos.create_pre_order(uuid, uuid, uuid, jsonb, text, text, text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION catchmenu_pos.create_pre_order(uuid, uuid, uuid, jsonb, text, text, text) TO postgres;
GRANT EXECUTE ON FUNCTION catchmenu_pos.create_pre_order(uuid, uuid, uuid, jsonb, text, text, text) TO authenticated;
COMMENT ON FUNCTION catchmenu_pos.create_pre_order(uuid, uuid, uuid, jsonb, text, text, text) IS 'Creates pre-order for waiting customer before arrival.
   Validates arrival_reliability_score against threshold.
   Creates order and KDS tickets — all tickets in HOLD.
   All 7 conditions start false.
   Sets pre_order_expires_at from store settings.
   특허2 핵심:
   사전주문 → 즉시 KDS 티켓 생성 (HOLD 상태)
   → arrived + table_confirmed + payment_confirmed 모두 충족 후 조리 큐 투입.
   노쇼 이력이 높은 고객은 사전주문 차단.';

-- catchmenu_pos.pre_order_while_waiting(uuid, uuid, uuid, jsonb, text, text, text)
CREATE OR REPLACE FUNCTION catchmenu_pos.pre_order_while_waiting(p_tenant_id uuid, p_store_id uuid, p_session_id uuid, p_cart_items jsonb, p_request_id text, p_locale text DEFAULT 'ko'::text, p_correlation_id text DEFAULT NULL::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'catchmenu_pos', 'catchmenu_kds', 'catchmenu_common', 'catchmenu_ledger', 'catchmenu_hq'
AS $function$
declare
  v_rg05_key text;
  v_rg05_request_hash text;
  v_rg05_existing_hash text;
  v_rg05_existing_result jsonb;
  v_rg05_result jsonb;
  v_rg05_sequence bigint;
  v_rg05_order_number text;
  v_rg04_tenant_status text;
  v_rg04_isolation_state text;
  v_session record;
  v_order_id uuid;
  v_order_number text;
  v_total_amount int := 0;
  v_item jsonb;
  v_menu record;
  v_business_day date;
  v_timezone text;
  v_ticket_count int := 0;
  v_ticket_number text;
begin
  perform catchmenu_common.assert_caller_tenant_scope(p_tenant_id);

  select t.tenant_status, t.isolation_state
  into v_rg04_tenant_status, v_rg04_isolation_state
  from catchmenu_hq.tenants t
  where t.id = p_tenant_id;

  if v_rg04_tenant_status is null
     or v_rg04_tenant_status not in ('ACTIVE', 'TRIAL')
     or v_rg04_isolation_state is distinct from 'NONE'
  then
    return jsonb_build_object(
      'success', false,
      'error_key', 'tenant_order_creation_blocked'
    );
  end if;

  -- RG-05: stable request identity. The advisory lock serializes equal
  -- canonical keys until the first transaction records its result.
  if nullif(btrim(p_request_id), '') is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'order_request_id_required'
    );
  end if;

  v_rg05_key := pg_catalog.encode(
    extensions.digest(
      pg_catalog.convert_to(
        jsonb_build_object(
          'tenant_id', p_tenant_id,
          'store_id', p_store_id,
          'session_id', p_session_id,
          'operation', 'catchmenu_pos.pre_order_while_waiting',
          'request_id', p_request_id
        )::text,
        'UTF8'
      ),
      'sha256'
    ),
    'hex'
  );
  v_rg05_request_hash := pg_catalog.encode(
    extensions.digest(
      pg_catalog.convert_to(
        jsonb_build_array(
          p_tenant_id,
      p_store_id,
      p_session_id,
      p_cart_items,
      p_locale
        )::text,
        'UTF8'
      ),
      'sha256'
    ),
    'hex'
  );

  perform pg_catalog.pg_advisory_xact_lock(
    pg_catalog.hashtextextended(v_rg05_key, 0)
  );

  select ik.request_hash, ik.result_payload
  into v_rg05_existing_hash, v_rg05_existing_result
  from catchmenu_common.idempotency_keys ik
  where ik.tenant_id = p_tenant_id
    and ik.key_domain = 'order'
    and ik.idempotency_key = v_rg05_key;

  if found then
    update catchmenu_common.idempotency_keys
    set last_received_at = now(),
        replay_count = replay_count + 1
    where tenant_id = p_tenant_id
      and key_domain = 'order'
      and idempotency_key = v_rg05_key;

    if v_rg05_existing_hash is distinct from v_rg05_request_hash then
      return jsonb_build_object(
        'success', false,
        'error_key', 'IDEMPOTENCY_PAYLOAD_CONFLICT'
      );
    end if;

    if v_rg05_existing_result is not null then
      return v_rg05_existing_result;
    end if;

    return jsonb_build_object(
      'success', false,
      'error_key', 'order_request_in_progress'
    );
  end if;

  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  -- 대기 세션 확인
  select id, wait_number, session_status,
         guest_count, guest_locale
  into v_session
  from catchmenu_pos.order_sessions
  where id = p_session_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
  for update;

  if v_session.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'waiting_session_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'pre_order_while_waiting'
    );
  end if;

  -- 대기 중 또는 호출 상태에서만 사전 주문 가능
  if v_session.session_status
    not in ('WAITING', 'ARRIVAL_PENDING')
  then
    return catchmenu_common.build_error_response(
      p_error_key := 'pre_order_requires_waiting',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'pre_order_while_waiting'
    );
  end if;

  -- 금액 계산 + 품절 확인
  for v_item in
    select * from jsonb_array_elements(
      p_cart_items
    )
  loop
    select id, menu_name, price, menu_status,
           is_kds_required, kitchen_zone
    into v_menu
    from catchmenu_pos.menus
    where id = (v_item->>'menu_id')::uuid
      and store_id = p_store_id
      and tenant_id = p_tenant_id
      and is_active = true;

    if v_menu.menu_status = 'SOLD_OUT' then
      return catchmenu_common.build_error_response(
        p_error_key := 'menu_sold_out',
        p_locale := p_locale,
        p_params := jsonb_build_object(
          'menu_name', v_menu.menu_name
        ),
        p_tenant_id := p_tenant_id,
        p_store_id := p_store_id,
        p_rpc_name := 'pre_order_while_waiting'
      );
    end if;

    v_total_amount := v_total_amount
      + v_menu.price
        * (v_item->>'quantity')::int;
  end loop;

  insert into catchmenu_pos.order_number_allocators (
    tenant_id, store_id, business_day, last_value,
    created_at, updated_at
  ) values (
    p_tenant_id, p_store_id, v_business_day, 1,
    now(), now()
  )
  on conflict (store_id, business_day) do update
  set last_value = catchmenu_pos.order_number_allocators.last_value + 1,
      updated_at = now()
  returning last_value into v_rg05_sequence;

  v_order_number := 'W' || lpad(v_rg05_sequence::text, 3, '0');

  -- 주문 생성  -- 주문 생성 (TABLE 타입, PRE_ORDER 소스)
  insert into catchmenu_pos.orders (
    tenant_id, store_id,
    session_id, order_number,
    order_type, order_status,
    order_source,
    total_amount, final_amount,
    ordered_at,
    business_day, business_timezone,
    idempotency_key
  ) values (
    p_tenant_id, p_store_id,
    p_session_id, v_order_number,
    'TABLE', 'CONFIRMED',
    'PRE_ORDER',
    v_total_amount, v_total_amount,
    now(),
    v_business_day, v_timezone,
    v_rg05_key
  )
  returning id into v_order_id;

  -- 주문 항목 + KDS 티켓 (HOLD = 특허2 핵심)
  for v_item in
    select * from jsonb_array_elements(
      p_cart_items
    )
  loop
    select id, menu_name, price,
           is_kds_required, kitchen_zone
    into v_menu
    from catchmenu_pos.menus
    where id = (v_item->>'menu_id')::uuid
      and store_id = p_store_id
      and tenant_id = p_tenant_id;

    insert into catchmenu_pos.order_items (
      tenant_id, store_id,
      order_id, menu_id,
      menu_name_snapshot,
      quantity, unit_price, subtotal,
      item_options
    ) values (
      p_tenant_id, p_store_id,
      v_order_id, v_menu.id,
      v_menu.menu_name,
      (v_item->>'quantity')::int,
      v_menu.price,
      v_menu.price * (v_item->>'quantity')::int,
      coalesce(
        v_item->'options', '[]'::jsonb
      )
    );

    -- ==========================================
    -- 특허2 + 특허1 결합 핵심
    -- 대기 중 사전 주문 → KDS HOLD
    -- 착석 확인 후 결제 → COMMITTED
    -- "대기하면서 메뉴 선택,
    --  착석하자마자 신선하게 나오는 시스템"
    -- ==========================================
    if v_menu.is_kds_required then
      v_ticket_count := v_ticket_count + 1;
      v_ticket_number := v_order_number || '-' || lpad(v_ticket_count::text, 2, '0');

      insert into catchmenu_kds.kds_tickets (
        tenant_id, store_id,
        order_id, ticket_number,
        menu_name_snapshot,
        quantity_snapshot,
        kitchen_zone, kds_status,
        conditions_met,
        ticket_created_at,
        business_day, business_timezone
      ) values (
        p_tenant_id, p_store_id,
        v_order_id, v_ticket_number,
        v_menu.menu_name,
        (v_item->>'quantity')::int,
        coalesce(v_menu.kitchen_zone, 'MAIN'),
        'HOLD',
        jsonb_build_object(
          'payment_confirmed', false,
          'kds_release_authorized', false,
          'waiting_session_id', p_session_id,
          'wait_number',
            v_session.wait_number,
          'order_source', 'PRE_ORDER',
          'release_trigger',
            'seat_confirmed_or_payment'
        ),
        now(),
        v_business_day, v_timezone
      );
    end if;
  end loop;

  -- 세션 사전 주문 금액 업데이트
  update catchmenu_pos.order_sessions
  set
    session_type = 'PRE_ORDER',
    pre_order_amount = v_total_amount,
    updated_at = now()
  where id = p_session_id;

  -- ledger event (특허1 + 특허2)
  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, event_payload,
    order_id, correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'waiting', 'pre_order_registered', 1,
    'order_session', p_session_id,
    'WAITING', 'PRE_ORDER',
    'CUSTOMER',
    jsonb_build_object(
      'order_id', v_order_id,
      'order_number', v_order_number,
      'wait_number', v_session.wait_number,
      'pre_order_amount', v_total_amount,
      'kds_status', 'HOLD',
      'patent_note',
        'Patent1+2: Pre-order HOLD until seated'
    ),
    v_order_id, p_correlation_id,
    v_business_day, v_timezone, now()
  );

  v_rg05_result := catchmenu_common.build_success_response(
    p_message_key := 'pre_order_registered',
    p_data := jsonb_build_object(
      'session_id', p_session_id,
      'order_id', v_order_id,
      'order_number', v_order_number,
      'wait_number', v_session.wait_number,
      'pre_order_amount', v_total_amount,
      'kds_status', 'HOLD',
      'kds_note',
        catchmenu_common.get_message(
          'pre_order_kds_note', p_locale, null
        ),
      'patent_principle', jsonb_build_object(
        'patent1',
          'Wait session tracks full journey',
        'patent2',
          'KDS HOLD until payment confirmed',
        'combined',
          'Pre-order while waiting, fresh food on seat'
      )
    ),
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );

  insert into catchmenu_common.idempotency_keys (
    tenant_id, store_id,
    idempotency_key, key_domain, key_scope,
    operation_type, request_hash,
    processing_status, result_payload,
    completed_at, last_received_at,
    correlation_id
  ) values (
    p_tenant_id, p_store_id,
    v_rg05_key, 'order', 'STORE',
    'catchmenu_pos.pre_order_while_waiting', v_rg05_request_hash,
    'COMPLETED', v_rg05_result,
    now(), now(),
    p_correlation_id
  );

  return v_rg05_result;
end;
$function$;

REVOKE ALL ON FUNCTION catchmenu_pos.pre_order_while_waiting(uuid, uuid, uuid, jsonb, text, text, text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION catchmenu_pos.pre_order_while_waiting(uuid, uuid, uuid, jsonb, text, text, text) TO postgres;
GRANT EXECUTE ON FUNCTION catchmenu_pos.pre_order_while_waiting(uuid, uuid, uuid, jsonb, text, text, text) TO authenticated;
GRANT EXECUTE ON FUNCTION catchmenu_pos.pre_order_while_waiting(uuid, uuid, uuid, jsonb, text, text, text) TO PUBLIC;
COMMENT ON FUNCTION catchmenu_pos.pre_order_while_waiting(uuid, uuid, uuid, jsonb, text, text, text) IS '대기 중 사전 주문 등록.
   특허1 + 특허2 결합 핵심 함수.

   흐름:
   1. 대기 등록 (register_waiting)
   2. 대기 중 메뉴 선택
      → pre_order_while_waiting()
      → 주문 생성 (PRE_ORDER 소스)
      → KDS = HOLD (조리 금지)
   3. 호출 (call_waiting_customer)
   4. 도착 확인 (confirm_arrival)
   5. 착석 (seat_waiting_customer)
      → KDS 여전히 HOLD
   6. 결제 (confirm_payment)
      → release_kds_after_payment()
      → KDS = COMMITTED (조리 시작!)
   7. 신선한 음식 제공

   고객 경험:
   "대기하면서 메뉴를 골랐는데
    앉자마자 음식이 나왔어요!"
   → 입소문 = 소문의 근거.

   KDS conditions_met 기록:
   waiting_session_id: 추적 가능
   release_trigger: 결제 후 자동 해제
   order_source: PRE_ORDER 구분.

   특허1: 대기 세션 전 여정 추적.
   특허2: KDS HOLD → 결제 후 COMMITTED.';

-- catchmenu_store.place_kiosk_order(uuid, uuid, uuid, uuid, jsonb, text, text, text, text, text)
CREATE OR REPLACE FUNCTION catchmenu_store.place_kiosk_order(p_tenant_id uuid, p_store_id uuid, p_kiosk_id uuid, p_kiosk_session_id uuid, p_cart_items jsonb, p_request_id text, p_order_type text DEFAULT 'TAKEOUT'::text, p_table_number text DEFAULT NULL::text, p_locale text DEFAULT 'ko'::text, p_correlation_id text DEFAULT NULL::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'catchmenu_store', 'catchmenu_pos', 'catchmenu_kds', 'catchmenu_common', 'catchmenu_ledger', 'catchmenu_hq'
AS $function$
declare
  v_rg05_key text;
  v_rg05_request_hash text;
  v_rg05_existing_hash text;
  v_rg05_existing_result jsonb;
  v_rg05_result jsonb;
  v_rg05_sequence bigint;
  v_rg05_order_number text;
  v_rg04_tenant_status text;
  v_rg04_isolation_state text;
  v_kiosk record;
  v_store_settings record;
  v_order_id uuid;
  v_order_number text;
  v_total_amount int := 0;
  v_item jsonb;
  v_menu record;
  v_business_day date;
  v_timezone text;
  v_session_id uuid;
  v_item_count int := 0;
begin
  perform catchmenu_common.assert_caller_tenant_scope(p_tenant_id);

  select t.tenant_status, t.isolation_state
  into v_rg04_tenant_status, v_rg04_isolation_state
  from catchmenu_hq.tenants t
  where t.id = p_tenant_id;

  if v_rg04_tenant_status is null
     or v_rg04_tenant_status not in ('ACTIVE', 'TRIAL')
     or v_rg04_isolation_state is distinct from 'NONE'
  then
    return jsonb_build_object(
      'success', false,
      'error_key', 'tenant_order_creation_blocked'
    );
  end if;

  -- RG-05: stable request identity. The advisory lock serializes equal
  -- canonical keys until the first transaction records its result.
  if nullif(btrim(p_request_id), '') is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'order_request_id_required'
    );
  end if;

  v_rg05_key := pg_catalog.encode(
    extensions.digest(
      pg_catalog.convert_to(
        jsonb_build_object(
          'tenant_id', p_tenant_id,
          'store_id', p_store_id,
          'session_id', p_kiosk_session_id,
          'operation', 'catchmenu_store.place_kiosk_order',
          'request_id', p_request_id
        )::text,
        'UTF8'
      ),
      'sha256'
    ),
    'hex'
  );
  v_rg05_request_hash := pg_catalog.encode(
    extensions.digest(
      pg_catalog.convert_to(
        jsonb_build_array(
          p_tenant_id,
      p_store_id,
      p_kiosk_id,
      p_kiosk_session_id,
      p_cart_items,
      p_order_type,
      p_table_number,
      p_locale
        )::text,
        'UTF8'
      ),
      'sha256'
    ),
    'hex'
  );

  perform pg_catalog.pg_advisory_xact_lock(
    pg_catalog.hashtextextended(v_rg05_key, 0)
  );

  select ik.request_hash, ik.result_payload
  into v_rg05_existing_hash, v_rg05_existing_result
  from catchmenu_common.idempotency_keys ik
  where ik.tenant_id = p_tenant_id
    and ik.key_domain = 'order'
    and ik.idempotency_key = v_rg05_key;

  if found then
    update catchmenu_common.idempotency_keys
    set last_received_at = now(),
        replay_count = replay_count + 1
    where tenant_id = p_tenant_id
      and key_domain = 'order'
      and idempotency_key = v_rg05_key;

    if v_rg05_existing_hash is distinct from v_rg05_request_hash then
      return jsonb_build_object(
        'success', false,
        'error_key', 'IDEMPOTENCY_PAYLOAD_CONFLICT'
      );
    end if;

    if v_rg05_existing_result is not null then
      return v_rg05_existing_result;
    end if;

    return jsonb_build_object(
      'success', false,
      'error_key', 'order_request_in_progress'
    );
  end if;

  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  -- 키오스크 설정 확인
  select id, kiosk_type, order_type
  into v_kiosk
  from catchmenu_store.kiosk_configs
  where id = p_kiosk_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
    and is_active = true;

  if v_kiosk.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'kiosk_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'place_kiosk_order'
    );
  end if;

  -- 매장 설정
  select store_mode, pre_order_enabled,
         min_order_amount
  into v_store_settings
  from catchmenu_store.store_settings
  where store_id = p_store_id
    and tenant_id = p_tenant_id;

  if coalesce(
    v_store_settings.store_mode, 'NORMAL'
  ) in ('CLOSED', 'HOLIDAY', 'EMERGENCY') then
    return catchmenu_common.build_error_response(
      p_error_key := 'kiosk_store_closed',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'place_kiosk_order'
    );
  end if;

  -- 장바구니 금액 계산 + 검증
  for v_item in
    select * from jsonb_array_elements(
      p_cart_items
    )
  loop
    select id, menu_name, price, menu_status
    into v_menu
    from catchmenu_pos.menus
    where id = (v_item->>'menu_id')::uuid
      and store_id = p_store_id
      and tenant_id = p_tenant_id
      and is_active = true;

    if v_menu.menu_status = 'SOLD_OUT' then
      return catchmenu_common.build_error_response(
        p_error_key := 'menu_sold_out',
        p_locale := p_locale,
        p_params := jsonb_build_object(
          'menu_name', v_menu.menu_name
        ),
        p_tenant_id := p_tenant_id,
        p_store_id := p_store_id,
        p_rpc_name := 'place_kiosk_order'
      );
    end if;

    v_total_amount := v_total_amount
      + v_menu.price
        * (v_item->>'quantity')::int;
    v_item_count := v_item_count + 1;
  end loop;

  -- 최소 주문 금액 확인
  if v_total_amount
    < coalesce(
      v_store_settings.min_order_amount, 0
    )
  then
    return catchmenu_common.build_error_response(
      p_error_key := 'order_amount_below_minimum',
      p_locale := p_locale,
      p_params := jsonb_build_object(
        'min_order_amount',
          v_store_settings.min_order_amount
      ),
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'place_kiosk_order'
    );
  end if;

  insert into catchmenu_pos.order_number_allocators (
    tenant_id, store_id, business_day, last_value,
    created_at, updated_at
  ) values (
    p_tenant_id, p_store_id, v_business_day, 1,
    now(), now()
  )
  on conflict (store_id, business_day) do update
  set last_value = catchmenu_pos.order_number_allocators.last_value + 1,
      updated_at = now()
  returning last_value into v_rg05_sequence;

  v_order_number := 'K' || lpad(v_rg05_sequence::text, 3, '0');

  -- 세션 생성  -- 세션 생성
  insert into catchmenu_pos.order_sessions (
    tenant_id, store_id,
    session_type, session_status,
    table_number,
    guest_count,
    session_started_at,
    business_day, business_timezone
  ) values (
    p_tenant_id, p_store_id,
    case p_order_type
      when 'TABLE' then 'TABLE'
      else 'KIOSK'
    end,
    'SEATED',
    p_table_number,
    1,
    now(),
    v_business_day, v_timezone
  )
  returning id into v_session_id;

  -- 주문 생성
  insert into catchmenu_pos.orders (
    tenant_id, store_id,
    session_id, order_number,
    order_type, order_status,
    order_source,
    total_amount, final_amount,
    ordered_at,
    business_day, business_timezone,
    idempotency_key
  ) values (
    p_tenant_id, p_store_id,
    v_session_id, v_order_number,
    p_order_type, 'CONFIRMED',
    'KIOSK',
    v_total_amount, v_total_amount,
    now(),
    v_business_day, v_timezone,
    v_rg05_key
  )
  returning id into v_order_id;

  -- 주문 항목 + KDS 티켓 생성
  for v_item in
    select * from jsonb_array_elements(
      p_cart_items
    )
  loop
    select id, menu_name, price,
           is_kds_required, kitchen_zone
    into v_menu
    from catchmenu_pos.menus
    where id = (v_item->>'menu_id')::uuid
      and store_id = p_store_id
      and tenant_id = p_tenant_id;

    -- 주문 항목
    insert into catchmenu_pos.order_items (
      tenant_id, store_id,
      order_id, menu_id,
      menu_name_snapshot,
      quantity, unit_price, subtotal,
      item_options
    ) values (
      p_tenant_id, p_store_id,
      v_order_id, v_menu.id,
      v_menu.menu_name,
      (v_item->>'quantity')::int,
      v_menu.price,
      v_menu.price * (v_item->>'quantity')::int,
      coalesce(
        v_item->'options', '[]'::jsonb
      )
    );

    -- KDS 티켓 (HOLD 상태 = 특허2)
    -- 키오스크 = 결제 전 주문
    -- → HOLD 유지 → 결제 후 COMMITTED
    if v_menu.is_kds_required then
      insert into catchmenu_kds.kds_tickets (
        tenant_id, store_id,
        order_id, menu_id,
        menu_name_snapshot,
        quantity_snapshot,
        kitchen_zone,
        kds_status,
        conditions_met,
        ticket_created_at,
        business_day, business_timezone
      ) values (
        p_tenant_id, p_store_id,
        v_order_id, v_menu.id,
        v_menu.menu_name,
        (v_item->>'quantity')::int,
        coalesce(
          v_menu.kitchen_zone, 'MAIN'
        ),
        'HOLD',
        jsonb_build_object(
          'payment_confirmed', false,
          'kds_release_authorized', false,
          'order_source', 'KIOSK'
        ),
        now(),
        v_business_day, v_timezone
      );
    end if;
  end loop;

  -- 키오스크 세션 업데이트
  update catchmenu_store.kiosk_sessions
  set
    order_id = v_order_id,
    session_status = 'PAYMENT',
    cart_items = p_cart_items,
    cart_total = v_total_amount,
    order_placed_at = now(),
    last_activity_at = now()
  where id = p_kiosk_session_id;

  -- Realtime → 직원 앱 알림
  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_channel_type := 'STAFF_ALERTS',
    p_event_type := 'takeout_order_received',
    p_payload := jsonb_build_object(
      'order_id', v_order_id,
      'order_number', v_order_number,
      'order_type', p_order_type,
      'order_source', 'KIOSK',
      'total_amount', v_total_amount,
      'item_count', v_item_count,
      'kiosk_id', p_kiosk_id,
      'table_number', p_table_number,
      'alert_message',
        catchmenu_common.get_message(
          'new_order_alert', 'ko',
          jsonb_build_object(
            'order_number', v_order_number
          )
        )
    )
  );

  -- ledger event
  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, event_payload,
    order_id, correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'order', 'kiosk_order_placed', 1,
    'order', v_order_id,
    null, 'CONFIRMED',
    'KIOSK',
    jsonb_build_object(
      'kiosk_id', p_kiosk_id,
      'order_number', v_order_number,
      'order_type', p_order_type,
      'total_amount', v_total_amount,
      'item_count', v_item_count,
      'kds_status', 'HOLD'
    ),
    v_order_id, p_correlation_id,
    v_business_day, v_timezone, now()
  );

  v_rg05_result := catchmenu_common.build_success_response(
    p_message_key := 'kiosk_order_placed',
    p_data := jsonb_build_object(
      'order_id', v_order_id,
      'order_number', v_order_number,
      'order_type', p_order_type,
      'total_amount', v_total_amount,
      'item_count', v_item_count,
      'kds_status', 'HOLD',
      'kds_note',
        '결제 완료 후 주방 조리 시작',
      'order_number_message',
        catchmenu_common.get_message(
          'kiosk_order_number', p_locale,
          jsonb_build_object(
            'order_number', v_order_number
          )
        ),
      'next_step', 'PAYMENT',
      'payment_methods', (
        select payment_methods
        from catchmenu_store.kiosk_configs
        where id = p_kiosk_id
      )
    ),
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );

  insert into catchmenu_common.idempotency_keys (
    tenant_id, store_id,
    idempotency_key, key_domain, key_scope,
    operation_type, request_hash,
    processing_status, result_payload,
    completed_at, last_received_at,
    correlation_id
  ) values (
    p_tenant_id, p_store_id,
    v_rg05_key, 'order', 'STORE',
    'catchmenu_store.place_kiosk_order', v_rg05_request_hash,
    'COMPLETED', v_rg05_result,
    now(), now(),
    p_correlation_id
  );

  return v_rg05_result;
end;
$function$;

REVOKE ALL ON FUNCTION catchmenu_store.place_kiosk_order(uuid, uuid, uuid, uuid, jsonb, text, text, text, text, text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION catchmenu_store.place_kiosk_order(uuid, uuid, uuid, uuid, jsonb, text, text, text, text, text) TO postgres;
GRANT EXECUTE ON FUNCTION catchmenu_store.place_kiosk_order(uuid, uuid, uuid, uuid, jsonb, text, text, text, text, text) TO authenticated;
GRANT EXECUTE ON FUNCTION catchmenu_store.place_kiosk_order(uuid, uuid, uuid, uuid, jsonb, text, text, text, text, text) TO PUBLIC;
COMMENT ON FUNCTION catchmenu_store.place_kiosk_order(uuid, uuid, uuid, uuid, jsonb, text, text, text, text, text) IS '키오스크 주문 생성.
   특허2 적용:
   KDS = HOLD (결제 전)
   → 결제 완료 후 confirm_payment() 호출
   → release_kds_after_payment()
   → KDS = COMMITTED (조리 시작)

   order_source = KIOSK:
   직원 앱 대시보드에서 KIOSK 주문 구분.
   대시보드 locale_breakdown:
   외국인 주문 비율 확인 가능.

   주문 번호: K001, K002, K003...
   (키오스크 전용 번호체계)

   Realtime → 직원 앱 즉시 알림.
   1호점 외국인 대응 핵심 기능.';

-- catchmenu_store.place_takeout_order(uuid, uuid, jsonb, text, uuid, text, text, text, uuid, integer, timestamp with time zone, text)
CREATE OR REPLACE FUNCTION catchmenu_store.place_takeout_order(p_tenant_id uuid, p_store_id uuid, p_items jsonb, p_request_id text, p_customer_id uuid DEFAULT NULL::uuid, p_phone_hash text DEFAULT NULL::text, p_locale text DEFAULT 'ko'::text, p_memo text DEFAULT NULL::text, p_coupon_issue_id uuid DEFAULT NULL::uuid, p_use_points integer DEFAULT 0, p_requested_pickup_at timestamp with time zone DEFAULT NULL::timestamp with time zone, p_correlation_id text DEFAULT NULL::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'catchmenu_store', 'catchmenu_pos', 'catchmenu_kds', 'catchmenu_payment', 'catchmenu_ledger', 'catchmenu_common', 'catchmenu_hq'
AS $function$
declare
  v_rg05_key text;
  v_rg05_request_hash text;
  v_rg05_existing_hash text;
  v_rg05_existing_result jsonb;
  v_rg05_result jsonb;
  v_rg05_sequence bigint;
  v_rg05_order_number text;
  v_rg04_tenant_status text;
  v_rg04_isolation_state text;
  v_customer_id uuid;
  v_customer_display_name text;
  v_customer_membership_tier text;
  v_customer_point_balance int;
  v_settings record;
  v_session_id uuid;
  v_order_id uuid;
  v_order_number text;
  v_item jsonb;
  v_menu record;
  v_total_amount int := 0;
  v_discount_amount int := 0;
  v_coupon_id uuid;
  v_coupon_discount_type text;
  v_coupon_discount_value int;
  v_coupon_discount_pct numeric;
  v_coupon_min_order_amount int;
  v_coupon_max_discount_amount int;
  v_coupon_discount int := 0;
  v_point_discount int := 0;
  v_final_amount int;
  v_point_balance int := 0;
  v_business_day date;
  v_timezone text;
  v_order_seq int;
  v_kds_result jsonb;
begin
  perform catchmenu_common.assert_caller_tenant_scope(p_tenant_id);

  select t.tenant_status, t.isolation_state
  into v_rg04_tenant_status, v_rg04_isolation_state
  from catchmenu_hq.tenants t
  where t.id = p_tenant_id;

  if v_rg04_tenant_status is null
     or v_rg04_tenant_status not in ('ACTIVE', 'TRIAL')
     or v_rg04_isolation_state is distinct from 'NONE'
  then
    return jsonb_build_object(
      'success', false,
      'error_key', 'tenant_order_creation_blocked'
    );
  end if;

  -- RG-05: stable request identity. The advisory lock serializes equal
  -- canonical keys until the first transaction records its result.
  if nullif(btrim(p_request_id), '') is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'order_request_id_required'
    );
  end if;

  v_rg05_key := pg_catalog.encode(
    extensions.digest(
      pg_catalog.convert_to(
        jsonb_build_object(
          'tenant_id', p_tenant_id,
          'store_id', p_store_id,
          'session_id', null,
          'operation', 'catchmenu_store.place_takeout_order',
          'request_id', p_request_id
        )::text,
        'UTF8'
      ),
      'sha256'
    ),
    'hex'
  );
  v_rg05_request_hash := pg_catalog.encode(
    extensions.digest(
      pg_catalog.convert_to(
        jsonb_build_array(
          p_tenant_id,
      p_store_id,
      p_items,
      p_customer_id,
      p_phone_hash,
      p_locale,
      p_memo,
      p_coupon_issue_id,
      p_use_points,
      p_requested_pickup_at
        )::text,
        'UTF8'
      ),
      'sha256'
    ),
    'hex'
  );

  perform pg_catalog.pg_advisory_xact_lock(
    pg_catalog.hashtextextended(v_rg05_key, 0)
  );

  select ik.request_hash, ik.result_payload
  into v_rg05_existing_hash, v_rg05_existing_result
  from catchmenu_common.idempotency_keys ik
  where ik.tenant_id = p_tenant_id
    and ik.key_domain = 'order'
    and ik.idempotency_key = v_rg05_key;

  if found then
    update catchmenu_common.idempotency_keys
    set last_received_at = now(),
        replay_count = replay_count + 1
    where tenant_id = p_tenant_id
      and key_domain = 'order'
      and idempotency_key = v_rg05_key;

    if v_rg05_existing_hash is distinct from v_rg05_request_hash then
      return jsonb_build_object(
        'success', false,
        'error_key', 'IDEMPOTENCY_PAYLOAD_CONFLICT'
      );
    end if;

    if v_rg05_existing_result is not null then
      return v_rg05_existing_result;
    end if;

    return jsonb_build_object(
      'success', false,
      'error_key', 'order_request_in_progress'
    );
  end if;

  if jsonb_array_length(
    coalesce(p_items, '[]'::jsonb)
  ) = 0 then
    return catchmenu_common.build_error_response(
      p_error_key := 'items_required',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'place_takeout_order'
    );
  end if;

  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  -- 매장 설정 확인
  select store_mode
  into v_settings
  from catchmenu_store.store_settings
  where store_id = p_store_id
    and tenant_id = p_tenant_id;

  if coalesce(v_settings.store_mode, 'NORMAL')
    in ('CLOSED', 'EMERGENCY')
  then
    return catchmenu_common.build_error_response(
      p_error_key := 'pre_order_disabled',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'place_takeout_order'
    );
  end if;

  -- 고객 조회
  if p_customer_id is not null then
    select id, display_name,
           membership_tier, point_balance
    into v_customer_id,
         v_customer_display_name,
         v_customer_membership_tier,
         v_customer_point_balance
    from catchmenu_store.customers
    where id = p_customer_id
      and tenant_id = p_tenant_id
      and is_active = true;
  elsif p_phone_hash is not null then
    select id, display_name,
           membership_tier, point_balance
    into v_customer_id,
         v_customer_display_name,
         v_customer_membership_tier,
         v_customer_point_balance
    from catchmenu_store.customers
    where phone_hash = p_phone_hash
      and tenant_id = p_tenant_id
      and is_active = true;
  end if;

  -- 포인트 잔액 확인
  if v_customer_id is not null
    and p_use_points > 0
  then
    select coalesce(
      sum(case point_type
        when 'EARN' then point_amount
        when 'USE' then -point_amount
        when 'EXPIRE' then -point_amount
        else 0
      end), 0
    )
    into v_point_balance
    from catchmenu_store.point_ledger
    where customer_id = v_customer_id
      and tenant_id = p_tenant_id;

    if v_point_balance < p_use_points then
      return catchmenu_common.build_error_response(
        p_error_key := 'insufficient_points',
        p_locale := p_locale,
        p_params := jsonb_build_object(
          'point_balance', v_point_balance
        ),
        p_tenant_id := p_tenant_id,
        p_store_id := p_store_id,
        p_rpc_name := 'place_takeout_order'
      );
    end if;
    v_point_discount := p_use_points;
  elsif v_customer_id is null
    and p_use_points > 0
  then
    perform catchmenu_common.log_diagnostic(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_log_level := 'WARNING',
      p_log_domain := 'ORDER',
      p_log_event := 'points_requested_without_customer',
      p_message := '비회원 포인트 사용 요청 스킵',
      p_error_key := null,
      p_details := jsonb_build_object(
        'p_use_points', p_use_points
      ),
      p_recovery_hint := null,
      p_rpc_name := 'place_takeout_order',
      p_correlation_id := p_correlation_id,
      p_session_id := null,
      p_order_id := null,
      p_payment_id := null,
      p_exception_id := null,
      p_device_id := null,
      p_agent_id := null,
      p_caller_type := null,
      p_caller_id := null
    );
  end if;

  -- 쿠폰 유효성 확인
  if p_coupon_issue_id is not null then
    select ci.id,
           c.discount_type, c.discount_value,
           c.discount_pct,
           c.min_order_amount,
           c.max_discount_amount
    into v_coupon_id,
         v_coupon_discount_type,
         v_coupon_discount_value,
         v_coupon_discount_pct,
         v_coupon_min_order_amount,
         v_coupon_max_discount_amount
    from catchmenu_store.coupon_issues ci
    join catchmenu_store.coupons c
      on c.id = ci.coupon_id
    where ci.id = p_coupon_issue_id
      and ci.customer_id = v_customer_id
      and ci.tenant_id = p_tenant_id
      and ci.issue_status = 'ISSUED'
      and (
        ci.expires_at is null
        or ci.expires_at >= now()
      );

    if v_coupon_id is null then
      return catchmenu_common.build_error_response(
        p_error_key := 'coupon_not_redeemable',
        p_locale := p_locale,
        p_tenant_id := p_tenant_id,
        p_store_id := p_store_id,
        p_rpc_name := 'place_takeout_order'
      );
    end if;
  end if;

  -- 메뉴 항목 계산
  for v_item in
    select * from jsonb_array_elements(p_items)
  loop
    select id, menu_name, price, menu_status,
           is_kds_required
    into v_menu
    from catchmenu_pos.menus
    where id = (v_item->>'menu_id')::uuid
      and store_id = p_store_id
      and tenant_id = p_tenant_id
      and is_active = true;

    if v_menu.id is null then
      return catchmenu_common.build_error_response(
        p_error_key := 'menu_not_found',
        p_locale := p_locale,
        p_tenant_id := p_tenant_id,
        p_store_id := p_store_id,
        p_rpc_name := 'place_takeout_order'
      );
    end if;

    if v_menu.menu_status = 'SOLD_OUT' then
      return catchmenu_common.build_error_response(
        p_error_key := 'menu_sold_out',
        p_locale := p_locale,
        p_params := jsonb_build_object(
          'menu_name', v_menu.menu_name
        ),
        p_tenant_id := p_tenant_id,
        p_store_id := p_store_id,
        p_rpc_name := 'place_takeout_order'
      );
    end if;

    v_total_amount := v_total_amount
      + (v_menu.price
        * (v_item->>'quantity')::int);
  end loop;

  -- 쿠폰 할인 계산
  if v_coupon_id is not null then
    if v_total_amount
      < coalesce(v_coupon_min_order_amount, 0)
    then
      return catchmenu_common.build_error_response(
        p_error_key := 'order_amount_below_minimum',
        p_locale := p_locale,
        p_params := jsonb_build_object(
          'min_order_amount',
            v_coupon_min_order_amount
        ),
        p_tenant_id := p_tenant_id,
        p_store_id := p_store_id,
        p_rpc_name := 'place_takeout_order'
      );
    end if;

    v_coupon_discount := case v_coupon_discount_type
      when 'AMOUNT' then
        v_coupon_discount_value
      when 'PCT' then
        least(
          (v_total_amount
            * v_coupon_discount_pct / 100)::int,
          coalesce(
            v_coupon_max_discount_amount,
            999999
          )
        )
      else 0
    end;
  end if;

  v_discount_amount := v_coupon_discount
    + v_point_discount;
  v_final_amount := greatest(
    0, v_total_amount - v_discount_amount
  );

  insert into catchmenu_pos.order_number_allocators (
    tenant_id, store_id, business_day, last_value,
    created_at, updated_at
  ) values (
    p_tenant_id, p_store_id, v_business_day, 1,
    now(), now()
  )
  on conflict (store_id, business_day) do update
  set last_value = catchmenu_pos.order_number_allocators.last_value + 1,
      updated_at = now()
  returning last_value into v_rg05_sequence;

  v_order_number := 'T'
    || to_char(v_business_day, 'MMDD')
    || lpad(v_rg05_sequence::text, 3, '0');

  -- 세션 생성  -- 세션 생성
  -- DEFERRED (see file header): order_sessions has no customer_id
  -- column (only unused customer_token, no designed relationship to
  -- catchmenu_store.customers). customer_id removed from this INSERT's
  -- column/value list below -- original values were:
  --   customer_id, guest_count, guest_locale
  --   v_customer.id, 1, p_locale
  insert into catchmenu_pos.order_sessions (
    tenant_id, store_id,
    session_type, session_status,
    guest_count, guest_locale,
    session_started_at,
    correlation_id,
    business_day, business_timezone
  ) values (
    p_tenant_id, p_store_id,
    'TAKEOUT', 'ORDER_CONFIRMED',
    1, p_locale,
    now(),
    p_correlation_id,
    v_business_day, v_timezone
  )
  returning id into v_session_id;

  -- 주문 생성
  -- DEFERRED (see file header): catchmenu_pos.orders has no
  -- customer_id column either (same undesigned relationship).
  -- customer_id removed from this INSERT's column/value list below --
  -- original values were: customer_id / v_customer.id
  insert into catchmenu_pos.orders (
    tenant_id, store_id, session_id,
    order_number, order_type, order_status,
    total_amount, discount_amount,
    final_amount,
    memo,
    requested_pickup_at,
    ordered_at,
    business_day, business_timezone,
    idempotency_key
  ) values (
    p_tenant_id, p_store_id, v_session_id,
    v_order_number, 'TAKEOUT', 'CONFIRMED',
    v_total_amount, v_discount_amount,
    v_final_amount,
    p_memo,
    p_requested_pickup_at,
    now(),
    v_business_day, v_timezone,
    v_rg05_key
  )
  returning id into v_order_id;

  -- 주문 항목 삽입
  declare
    v_item_idx int := 0;
  begin
    for v_item in
      select * from jsonb_array_elements(p_items)
    loop
      select id, menu_name, price,
             is_kds_required,
             estimated_minutes
      into v_menu
      from catchmenu_pos.menus
      where id = (v_item->>'menu_id')::uuid;

      insert into catchmenu_pos.order_items (
        tenant_id, store_id, order_id,
        menu_id, menu_name_snapshot,
        quantity, unit_price, subtotal,
        is_kds_required,
        display_order
      ) values (
        p_tenant_id, p_store_id, v_order_id,
        v_menu.id, v_menu.menu_name,
        (v_item->>'quantity')::int,
        v_menu.price,
        v_menu.price
          * (v_item->>'quantity')::int,
        v_menu.is_kds_required,
        v_item_idx
      );

      v_item_idx := v_item_idx + 1;
    end loop;
  end;

  -- 쿠폰 사용 처리
  if v_coupon_id is not null then
    update catchmenu_store.coupon_issues
    set
      issue_status = 'USED',
      used_at = now(),
      used_order_id = v_order_id,
      updated_at = now()
    where id = p_coupon_issue_id;
  end if;

  -- 포인트 사용 처리
  if v_point_discount > 0
    and v_customer_id is not null
  then
    perform catchmenu_store.deduct_points(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_customer_id := v_customer_id,
      p_deduct_amount := v_point_discount,
      p_deduct_reason := '포장 주문 포인트 사용',
      p_order_id := v_order_id
    );
  end if;

  -- KDS 티켓 생성
  -- 포장은 TAKEOUT zone
  insert into catchmenu_kds.kds_tickets (
    tenant_id, store_id,
    order_id, session_id,
    menu_id, menu_name_snapshot,
    quantity_snapshot,
    kitchen_zone,
    kds_status,
    conditions_met,
    ticket_created_at,
    business_day, business_timezone
  )
  select
    p_tenant_id, p_store_id,
    v_order_id, v_session_id,
    (v_item->>'menu_id')::uuid,
    m.menu_name,
    (v_item->>'quantity')::int,
    'TAKEOUT',
    'HOLD',
    jsonb_build_object(
      'payment_confirmed', false,
      'kds_release_authorized', false
    ),
    now(),
    v_business_day, v_timezone
  from jsonb_array_elements(p_items) v_item
  join catchmenu_pos.menus m
    on m.id = (v_item->>'menu_id')::uuid
  where m.is_kds_required = true;

  -- ledger event
  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, caused_by_id,
    event_payload,
    session_id, order_id,
    correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'order', 'takeout_order_placed', 1,
    'order', v_order_id,
    null, 'CONFIRMED',
    'CUSTOMER', v_customer_id,
    jsonb_build_object(
      'order_number', v_order_number,
      'total_amount', v_total_amount,
      'discount_amount', v_discount_amount,
      'final_amount', v_final_amount,
      'coupon_used', v_coupon_id is not null,
      'points_used', v_point_discount
    ),
    v_session_id, v_order_id,
    p_correlation_id,
    v_business_day, v_timezone, now()
  );

  -- 직원 앱 알림
  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_channel_type := 'STAFF_ALERTS',
    p_event_type := 'takeout_order_received',
    p_payload := jsonb_build_object(
      'order_id', v_order_id,
      'order_number', v_order_number,
      'final_amount', v_final_amount,
      'customer_name',
        coalesce(v_customer_display_name, '비회원'),
      'requested_pickup_at',
        p_requested_pickup_at,
      'item_count',
        jsonb_array_length(p_items)
    ),
    p_locale := p_locale
  );

  v_rg05_result := catchmenu_common.build_success_response(
    p_message_key := 'order_confirmed',
    p_data := jsonb_build_object(
      'order_id', v_order_id,
      'order_number', v_order_number,
      'session_id', v_session_id,
      'order_status', 'CONFIRMED',
      'order_type', 'TAKEOUT',
      'total_amount', v_total_amount,
      'discount_amount', v_discount_amount,
      'coupon_discount', v_coupon_discount,
      'point_discount', v_point_discount,
      'final_amount', v_final_amount,
      'requested_pickup_at',
        p_requested_pickup_at,
      'business_day', v_business_day,
      'next_step', 'AWAIT_PAYMENT'
    ),
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );

  insert into catchmenu_common.idempotency_keys (
    tenant_id, store_id,
    idempotency_key, key_domain, key_scope,
    operation_type, request_hash,
    processing_status, result_payload,
    completed_at, last_received_at,
    correlation_id
  ) values (
    p_tenant_id, p_store_id,
    v_rg05_key, 'order', 'STORE',
    'catchmenu_store.place_takeout_order', v_rg05_request_hash,
    'COMPLETED', v_rg05_result,
    now(), now(),
    p_correlation_id
  );

  return v_rg05_result;
end;
$function$;

REVOKE ALL ON FUNCTION catchmenu_store.place_takeout_order(uuid, uuid, jsonb, text, uuid, text, text, text, uuid, integer, timestamp with time zone, text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION catchmenu_store.place_takeout_order(uuid, uuid, jsonb, text, uuid, text, text, text, uuid, integer, timestamp with time zone, text) TO postgres;
GRANT EXECUTE ON FUNCTION catchmenu_store.place_takeout_order(uuid, uuid, jsonb, text, uuid, text, text, text, uuid, integer, timestamp with time zone, text) TO authenticated;
COMMENT ON FUNCTION catchmenu_store.place_takeout_order(uuid, uuid, jsonb, text, uuid, text, text, text, uuid, integer, timestamp with time zone, text) IS '포장 주문 접수.
   흐름:
   1. 매장 운영 상태 확인
   2. 쿠폰/포인트 유효성 검증
   3. 메뉴 가용성 + 가격 계산
   4. 할인 적용 (쿠폰 + 포인트)
   5. 세션 + 주문 + 주문항목 생성
   6. KDS 티켓 생성 (HOLD 상태)
   7. 쿠폰/포인트 사용 처리
   8. 직원 앱 Realtime 알림
   결제는 별도 confirm_payment_from_provider().
   특허1: 포장 주문 = Wait/Order Handoff.
   특허2: KDS 티켓 = HOLD (결제 확인 후 릴리즈).
   1-B차 포장 앱 핵심 주문 플로우.';

-- catchmenu_integrations.intake_delivery_order(uuid, uuid, text, text, jsonb, text, uuid, text)
CREATE OR REPLACE FUNCTION catchmenu_integrations.intake_delivery_order(p_tenant_id uuid, p_store_id uuid, p_provider_type text, p_provider_order_id text, p_provider_raw_payload jsonb, p_request_id text, p_gateway_session_id uuid DEFAULT NULL::uuid, p_correlation_id text DEFAULT NULL::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'catchmenu_integrations', 'catchmenu_gateway', 'catchmenu_pos', 'catchmenu_kds', 'catchmenu_ledger', 'catchmenu_audit', 'catchmenu_common', 'catchmenu_hq'
AS $function$
declare
  v_rg05_key text;
  v_rg05_request_hash text;
  v_rg05_existing_hash text;
  v_rg05_existing_result jsonb;
  v_rg05_result jsonb;
  v_rg05_sequence bigint;
  v_rg05_order_number text;
  v_rg04_tenant_status text;
  v_rg04_isolation_state text;
  v_provider_event_id uuid;
  v_order_id uuid;
  v_session_id uuid;
  v_order_number text;
  v_business_day date;
  v_timezone text;
  v_menu record;
  v_item jsonb;
  v_total_amount int := 0;
  v_item_amount int;
  v_kitchen_zone_summary jsonb := '{}'::jsonb;
  v_ticket_id uuid;
  v_ticket_count int := 0;
  v_ticket_number text;
  v_order_count int;
  v_normalized jsonb;
begin
  perform catchmenu_common.assert_caller_tenant_scope(p_tenant_id);

  select t.tenant_status, t.isolation_state
  into v_rg04_tenant_status, v_rg04_isolation_state
  from catchmenu_hq.tenants t
  where t.id = p_tenant_id;

  if v_rg04_tenant_status is null
     or v_rg04_tenant_status not in ('ACTIVE', 'TRIAL')
     or v_rg04_isolation_state is distinct from 'NONE'
  then
    return jsonb_build_object(
      'success', false,
      'error_key', 'tenant_order_creation_blocked'
    );
  end if;

  -- RG-05: stable request identity. The advisory lock serializes equal
  -- canonical keys until the first transaction records its result.
  if nullif(btrim(p_request_id), '') is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'order_request_id_required'
    );
  end if;

  v_rg05_key := pg_catalog.encode(
    extensions.digest(
      pg_catalog.convert_to(
        jsonb_build_object(
          'tenant_id', p_tenant_id,
          'store_id', p_store_id,
          'session_id', null,
          'operation', 'catchmenu_integrations.intake_delivery_order',
          'request_id', p_request_id
        )::text,
        'UTF8'
      ),
      'sha256'
    ),
    'hex'
  );
  v_rg05_request_hash := pg_catalog.encode(
    extensions.digest(
      pg_catalog.convert_to(
        jsonb_build_array(
          p_tenant_id,
      p_store_id,
      p_provider_type,
      p_provider_order_id,
      p_provider_raw_payload,
      p_gateway_session_id
        )::text,
        'UTF8'
      ),
      'sha256'
    ),
    'hex'
  );

  perform pg_catalog.pg_advisory_xact_lock(
    pg_catalog.hashtextextended(v_rg05_key, 0)
  );

  select ik.request_hash, ik.result_payload
  into v_rg05_existing_hash, v_rg05_existing_result
  from catchmenu_common.idempotency_keys ik
  where ik.tenant_id = p_tenant_id
    and ik.key_domain = 'order'
    and ik.idempotency_key = v_rg05_key;

  if found then
    update catchmenu_common.idempotency_keys
    set last_received_at = now(),
        replay_count = replay_count + 1
    where tenant_id = p_tenant_id
      and key_domain = 'order'
      and idempotency_key = v_rg05_key;

    if v_rg05_existing_hash is distinct from v_rg05_request_hash then
      return jsonb_build_object(
        'success', false,
        'error_key', 'IDEMPOTENCY_PAYLOAD_CONFLICT'
      );
    end if;

    if v_rg05_existing_result is not null then
      return v_rg05_existing_result;
    end if;

    return jsonb_build_object(
      'success', false,
      'error_key', 'order_request_in_progress'
    );
  end if;

  -- validate provider type
  if p_provider_type not in (
    'DELIVERY_BAEMIN',
    'DELIVERY_YOGIYO',
    'DELIVERY_COUPANG'
  ) then
    return jsonb_build_object(
      'success', false,
      'error_key', 'invalid_provider_type'
    );
  end if;

  if p_provider_raw_payload is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'payload_required'
    );
  end if;

  -- store timezone
  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  -- store in gateway provider_raw_events
  insert into catchmenu_gateway.provider_raw_events (
    tenant_id, store_id,
    provider_type, provider_code,
    provider_event_id, provider_event_type,
    raw_payload,
    payload_hash,
    signature_verified,
    schema_validated,
    processing_status,
    correlation_id, received_at
  ) values (
    p_tenant_id, p_store_id,
    p_provider_type,
    split_part(p_provider_type, '_', 2),
    p_provider_order_id,
    'ORDER_CREATED',
    p_provider_raw_payload,
    encode(digest(
      p_provider_raw_payload::text, 'sha256'
    ), 'hex'),
    true,
    true,
    'VALIDATING',
    p_correlation_id, now()
  )
  returning id into v_provider_event_id;

  -- normalize payload by provider
  -- extract common fields regardless of provider format
  v_normalized := jsonb_build_object(
    'provider_order_id', coalesce(
      p_provider_raw_payload->>'orderId',
      p_provider_raw_payload->>'order_id',
      p_provider_raw_payload->>'id',
      p_provider_order_id
    ),
    'total_amount', coalesce(
      (p_provider_raw_payload->>'totalAmount')::int,
      (p_provider_raw_payload->>'total_price')::int,
      (p_provider_raw_payload->>'orderAmount')::int,
      0
    ),
    'items', coalesce(
      p_provider_raw_payload->'orderItems',
      p_provider_raw_payload->'items',
      p_provider_raw_payload->'menus',
      '[]'::jsonb
    ),
    'special_requests', coalesce(
      p_provider_raw_payload->>'requestMsg',
      p_provider_raw_payload->>'request_message',
      p_provider_raw_payload->>'memo',
      ''
    ),
    'estimated_pickup_at', coalesce(
      p_provider_raw_payload->>'estimatedPickupTime',
      p_provider_raw_payload->>'pickup_time'
    )
  );

  insert into catchmenu_pos.order_number_allocators (
    tenant_id, store_id, business_day, last_value,
    created_at, updated_at
  ) values (
    p_tenant_id, p_store_id, v_business_day, 1,
    now(), now()
  )
  on conflict (store_id, business_day) do update
  set last_value = catchmenu_pos.order_number_allocators.last_value + 1,
      updated_at = now()
  returning last_value into v_rg05_sequence;

  v_order_number := 'D-' || lpad(v_rg05_sequence::text, 4, '0');

  -- create delivery order session  -- create delivery order session
  insert into catchmenu_pos.order_sessions (
    tenant_id, store_id,
    session_type, session_status,
    order_confirmed_at,
    business_day, business_timezone,
    correlation_id
  ) values (
    p_tenant_id, p_store_id,
    'DELIVERY', 'ORDER_CONFIRMED',
    now(),
    v_business_day, v_timezone,
    p_correlation_id
  )
  returning id into v_session_id;

  -- create order
  insert into catchmenu_pos.orders (
    tenant_id, store_id,
    session_id,
    order_number, order_type,
    order_status, order_channel,
    total_amount, discount_amount, final_amount,
    memo,
    ordered_at, confirmed_at,
    correlation_id,
    business_day, business_timezone,
    idempotency_key
  ) values (
    p_tenant_id, p_store_id,
    v_session_id,
    v_order_number, 'DELIVERY',
    'CONFIRMED',
    p_provider_type,
    (v_normalized->>'total_amount')::int,
    0,
    (v_normalized->>'total_amount')::int,
    v_normalized->>'special_requests',
    now(), now(),
    p_correlation_id,
    v_business_day, v_timezone,
    v_rg05_key
  )
  returning id into v_order_id;

  -- update session with order_id
  update catchmenu_pos.order_sessions
  set order_id = v_order_id,
      updated_at = now()
  where id = v_session_id;

  -- process order items
  for v_item in
    select * from jsonb_array_elements(
      v_normalized->'items'
    )
  loop
    -- try to match menu by provider menu code
    select id, menu_name, price,
           kitchen_zone, estimated_minutes,
           is_kds_required
    into v_menu
    from catchmenu_pos.menus
    where store_id = p_store_id
      and is_active = true
      and (
        menu_code = coalesce(
          v_item->>'menuId',
          v_item->>'menu_id',
          v_item->>'productId'
        )
        or menu_name = coalesce(
          v_item->>'menuName',
          v_item->>'menu_name',
          v_item->>'productName'
        )
      )
    limit 1;

    v_item_amount := coalesce(
      (v_item->>'quantity')::int, 1
    ) * coalesce(
      (v_item->>'unitPrice')::int,
      (v_item->>'price')::int,
      v_menu.price,
      0
    );

    -- kitchen zone tracking
    if v_menu.kitchen_zone is not null then
      v_kitchen_zone_summary := jsonb_set(
        v_kitchen_zone_summary,
        array[v_menu.kitchen_zone],
        to_jsonb(
          coalesce(
            (v_kitchen_zone_summary->>v_menu.kitchen_zone)::int, 0
          ) + coalesce((v_item->>'quantity')::int, 1)
        )
      );
    end if;

    -- insert order item
    insert into catchmenu_pos.order_items (
      tenant_id, store_id, order_id,
      menu_id,
      menu_code_snapshot,
      menu_name_snapshot,
      unit_price_snapshot,
      quantity, item_amount,
      selected_options, options_amount,
      kitchen_zone_snapshot,
      estimated_minutes_snapshot,
      is_kds_required_snapshot,
      allergen_displayed,
      item_status
    ) values (
      p_tenant_id, p_store_id, v_order_id,
      v_menu.id,
      coalesce(
        v_item->>'menuId', 'DELIVERY_ITEM'
      ),
      coalesce(
        v_item->>'menuName',
        v_item->>'menu_name',
        v_item->>'productName',
        'Unknown Item'
      ),
      coalesce(
        (v_item->>'unitPrice')::int,
        (v_item->>'price')::int,
        v_menu.price,
        0
      ),
      coalesce((v_item->>'quantity')::int, 1),
      v_item_amount,
      coalesce(v_item->'options', '[]'::jsonb),
      0,
      v_menu.kitchen_zone,
      v_menu.estimated_minutes,
      coalesce(v_menu.is_kds_required, true),
      false,
      'CONFIRMED'
    );

    v_total_amount := v_total_amount + v_item_amount;

    -- create KDS ticket immediately for delivery
    -- delivery orders skip HOLD for arrived/table conditions
    -- but still require capacity check
    if coalesce(v_menu.is_kds_required, true) then
      v_ticket_count := v_ticket_count + 1;
      v_ticket_number := v_order_number || '-'
        || lpad(v_ticket_count::text, 2, '0');

      insert into catchmenu_kds.kds_tickets (
        tenant_id, store_id,
        order_id, session_id,
        ticket_number,
        kds_status, hold_reason,
        kitchen_zone, priority,
        menu_name_snapshot,
        quantity_snapshot,
        estimated_minutes_snapshot,
        -- delivery: arrived + table_confirmed 조건 자동 충족
        -- 특허2: 배달 주문은 도착/테이블 조건 면제
        conditions_met,
        first_hold_at,
        business_day, business_timezone
      ) values (
        p_tenant_id, p_store_id,
        v_order_id, v_session_id,
        v_ticket_number,
        'CAPACITY_CHECKING',
        'KDS_CAPACITY_CHECK',
        v_menu.kitchen_zone, 3,
        coalesce(
          v_item->>'menuName',
          v_item->>'menu_name',
          'Unknown Item'
        ),
        coalesce((v_item->>'quantity')::int, 1),
        v_menu.estimated_minutes,
        jsonb_build_object(
          'arrived', true,
          'table_confirmed', true,
          'payment_confirmed', true,
          'kds_capacity_ok', false,
          'menu_available', true,
          'peak_time_ok', true,
          'no_show_risk_ok', true
        ),
        now(),
        v_business_day, v_timezone
      )
      returning id into v_ticket_id;
    end if;
  end loop;

  -- update order totals
  update catchmenu_pos.orders
  set
    total_amount = v_total_amount,
    final_amount = v_total_amount,
    kitchen_zone_summary = v_kitchen_zone_summary,
    updated_at = now()
  where id = v_order_id;

  -- update gateway event to ACCEPTED
  update catchmenu_gateway.provider_raw_events
  set
    processing_status = 'ACCEPTED',
    accepted_at = now(),
    internal_event_id = null
  where id = v_provider_event_id;

  -- order event
  insert into catchmenu_pos.order_events (
    tenant_id, store_id, order_id,
    event_type, from_status, to_status,
    caused_by_type,
    event_payload, correlation_id, occurred_at
  ) values (
    p_tenant_id, p_store_id, v_order_id,
    'order_created', null, 'CONFIRMED',
    'PROVIDER',
    jsonb_build_object(
      'provider_type', p_provider_type,
      'provider_order_id', p_provider_order_id,
      'total_amount', v_total_amount,
      'kds_tickets_created', v_ticket_count
    ),
    p_correlation_id, now()
  );

  -- ledger event
  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type,
    event_payload,
    session_id, order_id,
    correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'order', 'delivery_order_received', 1,
    'order', v_order_id,
    null, 'CONFIRMED',
    'PROVIDER',
    jsonb_build_object(
      'provider_type', p_provider_type,
      'provider_order_id', p_provider_order_id,
      'order_number', v_order_number,
      'total_amount', v_total_amount,
      'kds_tickets_created', v_ticket_count,
      'provider_event_id', v_provider_event_id
    ),
    v_session_id, v_order_id,
    p_correlation_id,
    v_business_day, v_timezone, now()
  );

  -- audit
  perform catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := 'order',
    p_audit_type := 'delivery_order_received',
    p_audit_category := 'OPERATIONAL',
    p_actor_type := 'PROVIDER',
    p_actor_id := null,
    p_subject_type := 'order',
    p_subject_id := v_order_id,
    p_decision := 'COMPLETED',
    p_decision_payload := jsonb_build_object(
      'provider_type', p_provider_type,
      'provider_order_id', p_provider_order_id,
      'order_number', v_order_number,
      'total_amount', v_total_amount
    ),
    p_order_id := v_order_id,
    p_session_id := v_session_id,
    p_correlation_id := p_correlation_id,
    p_business_day := v_business_day,
    p_business_timezone := v_timezone
  );

  v_rg05_result := jsonb_build_object(
    'success', true,
    'order_id', v_order_id,
    'session_id', v_session_id,
    'order_number', v_order_number,
    'provider_type', p_provider_type,
    'provider_order_id', p_provider_order_id,
    'total_amount', v_total_amount,
    'kds_tickets_created', v_ticket_count,
    'provider_event_id', v_provider_event_id,
    'message_code', 'delivery_order_received'
  );

  insert into catchmenu_common.idempotency_keys (
    tenant_id, store_id,
    idempotency_key, key_domain, key_scope,
    operation_type, request_hash,
    processing_status, result_payload,
    completed_at, last_received_at,
    correlation_id
  ) values (
    p_tenant_id, p_store_id,
    v_rg05_key, 'order', 'STORE',
    'catchmenu_integrations.intake_delivery_order', v_rg05_request_hash,
    'COMPLETED', v_rg05_result,
    now(), now(),
    p_correlation_id
  );

  return v_rg05_result;
end;
$function$;

REVOKE ALL ON FUNCTION catchmenu_integrations.intake_delivery_order(uuid, uuid, text, text, jsonb, text, uuid, text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION catchmenu_integrations.intake_delivery_order(uuid, uuid, text, text, jsonb, text, uuid, text) TO postgres;
GRANT EXECUTE ON FUNCTION catchmenu_integrations.intake_delivery_order(uuid, uuid, text, text, jsonb, text, uuid, text) TO authenticated;
COMMENT ON FUNCTION catchmenu_integrations.intake_delivery_order(uuid, uuid, text, text, jsonb, text, uuid, text) IS 'Universal delivery order intake for Baemin, Yogiyo, Coupang Eats.
   All orders enter through gateway sandbox with idempotency check.
   Normalizes provider-specific payload to internal format.
   Creates order session, order, order items, and KDS tickets.
   Delivery orders: arrived + table_confirmed auto-satisfied.
   KDS tickets start at CAPACITY_CHECKING (skip arrival/table hold).
   특허1: 배달앱 주문 → Gateway 샌드박스 → 내부 원장 반영.
   특허2: 배달 주문 KDS 티켓 = 도착/테이블 조건 면제, 용량 조건만 확인.';

-- catchmenu_common.flush_offline_queue(uuid, uuid, text, uuid, integer, text)
CREATE OR REPLACE FUNCTION catchmenu_common.flush_offline_queue(p_tenant_id uuid, p_store_id uuid, p_request_id text, p_device_id uuid DEFAULT NULL::uuid, p_max_batch integer DEFAULT 50, p_locale text DEFAULT 'ko'::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'catchmenu_common', 'catchmenu_pos', 'catchmenu_kds', 'catchmenu_payment', 'catchmenu_store'
AS $function$
declare
  v_rg05_key text;
  v_rg05_request_hash text;
  v_rg05_existing_hash text;
  v_rg05_existing_result jsonb;
  v_rg05_result jsonb;
  v_rg05_sequence bigint;
  v_rg05_order_number text;
  v_rg04_tenant_status text;
  v_rg04_isolation_state text;
  v_item record;
  v_processed int := 0;
  v_failed int := 0;
  v_skipped int := 0;
  v_results jsonb := '[]'::jsonb;
  v_result jsonb;
begin
  perform catchmenu_common.assert_caller_tenant_scope(p_tenant_id);

  select t.tenant_status, t.isolation_state
  into v_rg04_tenant_status, v_rg04_isolation_state
  from catchmenu_hq.tenants t
  where t.id = p_tenant_id;

  if v_rg04_tenant_status is null
     or v_rg04_tenant_status not in ('ACTIVE', 'TRIAL')
     or v_rg04_isolation_state is distinct from 'NONE'
  then
    return jsonb_build_object(
      'success', false,
      'error_key', 'tenant_order_creation_blocked'
    );
  end if;

  -- RG-05: stable request identity. The advisory lock serializes equal
  -- canonical keys until the first transaction records its result.
  if nullif(btrim(p_request_id), '') is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'order_request_id_required'
    );
  end if;

  v_rg05_key := pg_catalog.encode(
    extensions.digest(
      pg_catalog.convert_to(
        jsonb_build_object(
          'tenant_id', p_tenant_id,
          'store_id', p_store_id,
          'session_id', null,
          'operation', 'catchmenu_common.flush_offline_queue',
          'request_id', p_request_id
        )::text,
        'UTF8'
      ),
      'sha256'
    ),
    'hex'
  );
  v_rg05_request_hash := pg_catalog.encode(
    extensions.digest(
      pg_catalog.convert_to(
        jsonb_build_array(
          p_tenant_id,
      p_store_id,
      p_device_id,
      p_max_batch,
      p_locale
        )::text,
        'UTF8'
      ),
      'sha256'
    ),
    'hex'
  );

  perform pg_catalog.pg_advisory_xact_lock(
    pg_catalog.hashtextextended(v_rg05_key, 0)
  );

  select ik.request_hash, ik.result_payload
  into v_rg05_existing_hash, v_rg05_existing_result
  from catchmenu_common.idempotency_keys ik
  where ik.tenant_id = p_tenant_id
    and ik.key_domain = 'order'
    and ik.idempotency_key = v_rg05_key;

  if found then
    update catchmenu_common.idempotency_keys
    set last_received_at = now(),
        replay_count = replay_count + 1
    where tenant_id = p_tenant_id
      and key_domain = 'order'
      and idempotency_key = v_rg05_key;

    if v_rg05_existing_hash is distinct from v_rg05_request_hash then
      return jsonb_build_object(
        'success', false,
        'error_key', 'IDEMPOTENCY_PAYLOAD_CONFLICT'
      );
    end if;

    if v_rg05_existing_result is not null then
      return v_rg05_existing_result;
    end if;

    return jsonb_build_object(
      'success', false,
      'error_key', 'order_request_in_progress'
    );
  end if;

  -- 우선순위 순으로 배치 처리
  for v_item in
    select id, action_type, action_payload,
           local_temp_id, retry_count
    from catchmenu_common.offline_queue
    where store_id = p_store_id
      and tenant_id = p_tenant_id
      and queue_status = 'PENDING'
      and expires_at > now()
      and (
        p_device_id is null
        or device_id = p_device_id
      )
    order by action_priority asc,
             queued_at asc
    limit p_max_batch
    for update skip locked
  loop
    -- PROCESSING 표시
    update catchmenu_common.offline_queue
    set queue_status = 'PROCESSING'
    where id = v_item.id;

    begin
      -- 액션 타입별 실제 처리
      case v_item.action_type

        when 'CREATE_ORDER' then
          -- 주문 생성
          declare
            v_order_id uuid;
          begin
            -- 로컬 임시 ID로 중복 확인
            select id into v_order_id
            from catchmenu_pos.orders
            where tenant_id = p_tenant_id
              and store_id = p_store_id
              and local_temp_id =
                v_item.local_temp_id;

            if v_order_id is null then
              insert into catchmenu_pos.order_number_allocators (
                tenant_id, store_id, business_day, last_value,
                created_at, updated_at
              ) values (
                p_tenant_id, p_store_id,
                (v_item.action_payload->>'business_day')::date,
                1, now(), now()
              )
              on conflict (store_id, business_day) do update
              set last_value = catchmenu_pos.order_number_allocators.last_value + 1,
                  updated_at = now()
              returning last_value into v_rg05_sequence;

              v_rg05_order_number := lpad(
                v_rg05_sequence::text, 4, '0'
              );

              insert into catchmenu_pos.orders (
                tenant_id, store_id,
                order_number, order_type,
                order_status, order_source,
                total_amount, final_amount,
                memo,
                local_temp_id,
                ordered_at, business_day,
                business_timezone,
                idempotency_key
              )
              select
                p_tenant_id, p_store_id,
                v_rg05_key,
                v_rg05_order_number,
                v_item.action_payload
                  ->>'order_type',
                'CONFIRMED',
                'OFFLINE',
                (v_item.action_payload
                  ->>'total_amount')::int,
                (v_item.action_payload
                  ->>'final_amount')::int,
                v_item.action_payload
                  ->>'request_memo',
                v_item.local_temp_id,
                (v_item.action_payload
                  ->>'ordered_at')::timestamptz,
                (v_item.action_payload
                  ->>'business_day')::date,
                'Asia/Seoul'
              returning id into v_order_id;
            end if;

            v_result := jsonb_build_object(
              'success', true,
              'order_id', v_order_id
            );
          end;

        when 'UPDATE_KDS_STATUS' then
          -- KDS 상태 업데이트
          update catchmenu_kds.kds_tickets
          set
            kds_status = v_item.action_payload
              ->>'new_status',
            updated_at = now()
          where id = (
            v_item.action_payload->>'ticket_id'
          )::uuid;

          v_result := jsonb_build_object(
            'success', true,
            'ticket_id', v_item.action_payload
              ->>'ticket_id'
          );

        when 'RECORD_MANUAL_PAYMENT' then
          -- 수기 결제 기록
          declare
            v_ledger_id uuid;
            v_intent_id uuid;
            v_provider_response_id uuid;
            v_order_id uuid;
            v_amount int;
            v_payment_method text;
            v_payment_key text;
            v_provider_payload jsonb;
          begin
            v_order_id := (
              v_item.action_payload
                ->>'order_id'
            )::uuid;
            v_amount := (
              v_item.action_payload
                ->>'amount'
            )::int;
            v_payment_method := coalesce(
              v_item.action_payload
                ->>'payment_method',
              'CASH'
            );
            v_payment_key := 'MANUAL-' || v_item.id::text;
            v_provider_payload := jsonb_build_object(
              'offline', true,
              'manual', true,
              'queue_item_id', v_item.id,
              'note', v_item.action_payload
                ->>'note'
            );

            insert into catchmenu_gateway.provider_raw_events (
              tenant_id,
              store_id,
              provider_type,
              provider_code,
              provider_event_id,
              provider_event_type,
              raw_payload,
              correlation_id
            ) values (
              p_tenant_id,
              p_store_id,
              'OTHER',
              'MANUAL',
              v_payment_key,
              'RECORD_MANUAL_PAYMENT',
              v_provider_payload,
              null
            )
            returning id into v_provider_response_id;

            v_intent_id :=
              catchmenu_payment.resolve_or_create_payment_intent(
                p_tenant_id := p_tenant_id,
                p_store_id := p_store_id,
                p_order_id := v_order_id,
                p_requested_amount := v_amount,
                p_payment_method := v_payment_method,
                p_payment_channel := 'STAFF_POS',
                p_provider_type := 'MANUAL',
                p_intent_origin := 'MANUAL_ENTRY',
                p_origin_reference := jsonb_build_object(
                  'source', 'flush_offline_queue',
                  'queue_item_id', v_item.id,
                  'payment_key', v_payment_key
                ),
                p_intent_id := null,
                p_session_id := null,
                p_locale := p_locale
              );
            insert into
              catchmenu_payment.payment_ledger (
              tenant_id, store_id,
              order_id, intent_id,
              ledger_entry_type,
              provider_type,
              provider_payment_key,
              provider_response_id,
              approved_amount,
              net_amount, ledger_status,
              approved_at, business_day,
              business_timezone
            ) values (
              p_tenant_id, p_store_id,
              v_order_id,
              v_intent_id,
              'APPROVAL',
              'MANUAL',
              v_payment_key,
              v_provider_response_id,
              v_amount,
              v_amount,
              'APPROVED',
              (v_item.action_payload
                ->>'paid_at')::timestamptz,
              (v_item.action_payload
                ->>'business_day')::date,
              'Asia/Seoul'
            )
            returning id into v_ledger_id;

            v_result := jsonb_build_object(
              'success', true,
              'ledger_id', v_ledger_id
            );
          end;

        when 'STAMP_VISIT' then
          v_result :=
            catchmenu_store.stamp_visit(
              p_tenant_id := p_tenant_id,
              p_store_id := p_store_id,
              p_customer_id := (
                v_item.action_payload
                  ->>'customer_id'
              )::uuid,
              p_order_id := (
                v_item.action_payload
                  ->>'order_id'
              )::uuid,
              p_order_amount := (
                v_item.action_payload
                  ->>'order_amount'
              )::int,
              p_locale := p_locale
            );

        when 'LOG_BANNER_VIEW',
             'LOG_EVENT_TAP',
             'LOG_DIAGNOSTIC' then
          -- 통계/로그는 단순 기록
          v_result := jsonb_build_object(
            'success', true,
            'action', v_item.action_type
          );

        else
          v_result := jsonb_build_object(
            'success', false,
            'reason', 'unhandled_action_type'
          );
          v_skipped := v_skipped + 1;
      end case;

      -- 완료 처리
      update catchmenu_common.offline_queue
      set
        queue_status = 'COMPLETED',
        server_result_id = case
          when v_result->>'order_id' is not null
          then (v_result->>'order_id')::uuid
          when v_result->>'ledger_id' is not null
          then (v_result->>'ledger_id')::uuid
          else null
        end,
        flushed_at = now()
      where id = v_item.id;

      v_processed := v_processed + 1;
      v_results := v_results
        || jsonb_build_object(
          'queue_id', v_item.id,
          'action_type', v_item.action_type,
          'status', 'COMPLETED',
          'result', v_result
        );

    exception when others then
      -- 실패 처리
      update catchmenu_common.offline_queue
      set
        queue_status = case
          when retry_count + 1
            >= max_retries then 'FAILED'
          else 'PENDING'
        end,
        retry_count = retry_count + 1,
        error_detail = sqlerrm
      where id = v_item.id;

      v_failed := v_failed + 1;
      v_results := v_results
        || jsonb_build_object(
          'queue_id', v_item.id,
          'action_type', v_item.action_type,
          'status', 'FAILED',
          'error', sqlerrm
        );
    end;
  end loop;

  -- 복구 네트워크 로그
  if v_processed > 0 then
    perform catchmenu_common.log_diagnostic(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_log_level := 'INFO',
      p_log_domain := 'SYSTEM',
      p_log_event := 'offline_queue_flushed',
      p_message :=
        '오프라인 큐 동기화 완료'
        || ' | 처리=' || v_processed
        || ' | 실패=' || v_failed,
      p_rpc_name := 'flush_offline_queue',
      p_details := jsonb_build_object(
        'processed', v_processed,
        'failed', v_failed,
        'skipped', v_skipped
      )
    );
  end if;

  v_rg05_result := catchmenu_common.build_success_response(
    p_message_key := 'offline_queue_flushed',
    p_data := jsonb_build_object(
      'processed', v_processed,
      'failed', v_failed,
      'skipped', v_skipped,
      'total', v_processed + v_failed
        + v_skipped,
      'results', v_results
    ),
    p_locale := p_locale,
    p_params := jsonb_build_object(
      'count', v_processed
    )
  );

  insert into catchmenu_common.idempotency_keys (
    tenant_id, store_id,
    idempotency_key, key_domain, key_scope,
    operation_type, request_hash,
    processing_status, result_payload,
    completed_at, last_received_at,
    correlation_id
  ) values (
    p_tenant_id, p_store_id,
    v_rg05_key, 'order', 'STORE',
    'catchmenu_common.flush_offline_queue', v_rg05_request_hash,
    'COMPLETED', v_rg05_result,
    now(), now(),
    null
  );

  return v_rg05_result;
end;
$function$;

REVOKE ALL ON FUNCTION catchmenu_common.flush_offline_queue(uuid, uuid, text, uuid, integer, text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION catchmenu_common.flush_offline_queue(uuid, uuid, text, uuid, integer, text) TO postgres;
GRANT EXECUTE ON FUNCTION catchmenu_common.flush_offline_queue(uuid, uuid, text, uuid, integer, text) TO authenticated;
COMMENT ON FUNCTION catchmenu_common.flush_offline_queue(uuid, uuid, text, uuid, integer, text) IS '오프라인 큐 동기화 함수.
   온라인 복구 감지 후 Flutter가 즉시 호출.

   처리 순서 (우선순위):
   1. CREATE_ORDER (주문 생성)
   2. RECORD_MANUAL_PAYMENT (수기 결제)
   3. UPDATE_KDS_STATUS (KDS 상태)
   4. CREATE_WAITING_SESSION (대기 등록)
   5. STAMP_VISIT (스탬프)
   9. LOG_* (통계 로그)

   중복 방지:
   CREATE_ORDER: local_temp_id로 중복 확인.
   RECORD_MANUAL_PAYMENT: MANUAL provider.

   배치 처리:
   p_max_batch = 50 (기본값).
   실패 시 retry_count + 1.
   3회 초과 시 FAILED.

   Flutter 호출 시점:
   ConnectivityPlus → onConnectivityChanged
   → ONLINE 감지 → flush_offline_queue().';

-- catchmenu_common.run_integration_test(uuid, uuid, text)
CREATE OR REPLACE FUNCTION catchmenu_common.run_integration_test(p_tenant_id uuid, p_store_id uuid, p_scenario text DEFAULT 'ALL'::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'catchmenu_common', 'catchmenu_pos', 'catchmenu_kds', 'catchmenu_payment', 'catchmenu_store', 'catchmenu_hq'
AS $function$
declare
  v_rg05_run_uuid uuid := gen_random_uuid();
  v_rg05_test_request_id text;
  v_rg05_key text;
  v_rg05_sequence bigint;
  v_rg05_order_number text;
  v_rg04_tenant_status text;
  v_rg04_isolation_state text;
  v_results jsonb := '[]'::jsonb;
  v_pass int := 0;
  v_fail int := 0;
  v_test_order_id uuid;
  v_test_session_id uuid;
  v_test_customer_id uuid;
  v_business_day date;
begin
  perform catchmenu_common.assert_caller_tenant_scope(p_tenant_id);

  select t.tenant_status, t.isolation_state
  into v_rg04_tenant_status, v_rg04_isolation_state
  from catchmenu_hq.tenants t
  where t.id = p_tenant_id;

  if v_rg04_tenant_status is null
     or v_rg04_tenant_status not in ('ACTIVE', 'TRIAL')
     or v_rg04_isolation_state is distinct from 'NONE'
  then
    return jsonb_build_object(
      'success', false,
      'error_key', 'tenant_order_creation_blocked'
    );
  end if;

  delete from pg_temp.final_validation_test_cases;
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  -- =====================
  -- 1. DB 연결 테스트
  -- =====================
  perform catchmenu_common.add_final_validation_test_case(
    'DB 연결',
    true,
    'PostgreSQL 연결 정상'
  );

  -- =====================
  -- 2. 스키마 존재 확인
  -- =====================
  perform catchmenu_common.add_final_validation_test_case(
    '스키마 존재 확인',
    (
      select count(*) = 9
      from information_schema.schemata
      where schema_name in (
        'catchmenu_common', 'catchmenu_hq',
        'catchmenu_pos', 'catchmenu_kds',
        'catchmenu_payment', 'catchmenu_store',
        'catchmenu_integrations',
        'catchmenu_ledger', 'catchmenu_knowledge'
      )
    ),
    '9개 스키마 확인'
  );

  -- =====================
  -- 3. 매장 존재 확인
  -- =====================
  perform catchmenu_common.add_final_validation_test_case(
    '매장 존재 확인',
    exists (
      select 1 from catchmenu_hq.stores
      where id = p_store_id
        and tenant_id = p_tenant_id
        and is_active = true
    ),
    p_store_id::text
  );

  -- =====================
  -- 4. 메뉴 등록 확인
  -- =====================
  declare
    v_menu_count int;
  begin
    select count(*) into v_menu_count
    from catchmenu_pos.menus
    where store_id = p_store_id
      and tenant_id = p_tenant_id
      and is_active = true;

    perform catchmenu_common.add_final_validation_test_case(
      '메뉴 등록 확인',
      v_menu_count >= 0,
      v_menu_count::text || '개 등록'
    );
  end;

  -- =====================
  -- 5. 특허2: KDS HOLD 테스트
  -- =====================
  if p_scenario in ('ALL', 'PATENT2') then
    v_rg05_test_request_id :=
      'integration-test:PATENT2:' || v_rg05_run_uuid::text;
    v_rg05_key := pg_catalog.encode(
      extensions.digest(
        pg_catalog.convert_to(
          jsonb_build_object(
            'tenant_id', p_tenant_id,
            'store_id', p_store_id,
            'session_id', null,
            'operation',
              'catchmenu_common.run_integration_test:PATENT2',
            'request_id', v_rg05_test_request_id
          )::text,
          'UTF8'
        ),
        'sha256'
      ),
      'hex'
    );

    -- Test isolation only. Allocator concurrency is verified separately.
    perform pg_catalog.pg_advisory_xact_lock(
      pg_catalog.hashtextextended(
        'run_integration_test:PATENT2:'
          || p_tenant_id::text || ':' || p_store_id::text,
        0
      )
    );

    declare
      v_test_menu_id uuid;
      v_kds_status text;
    begin
      -- 테스트 메뉴 조회
      select id into v_test_menu_id
      from catchmenu_pos.menus
      where store_id = p_store_id
        and tenant_id = p_tenant_id
        and is_active = true
        and menu_status = 'AVAILABLE'
        and is_kds_required = true
      limit 1;

      if v_test_menu_id is not null then
        -- 테스트 세션 생성
        insert into catchmenu_pos.order_sessions (
          tenant_id, store_id,
          session_type, session_status,
          guest_count,
          session_started_at,
          business_day, business_timezone
        ) values (
          p_tenant_id, p_store_id,
          'KIOSK', 'SEATED', 1,
          now(), v_business_day, 'Asia/Seoul'
        )
        returning id into v_test_session_id;

        insert into catchmenu_pos.order_number_allocators (
          tenant_id, store_id, business_day, last_value,
          created_at, updated_at
        ) values (
          p_tenant_id, p_store_id, v_business_day, 1,
          now(), now()
        )
        on conflict (store_id, business_day) do update
        set last_value = catchmenu_pos.order_number_allocators.last_value + 1,
            updated_at = now()
        returning last_value into v_rg05_sequence;

        v_rg05_order_number := 'TEST-' ||
          lpad(v_rg05_sequence::text, 4, '0');

        -- 테스트 주문 생성
        insert into catchmenu_pos.orders (
          tenant_id, store_id,
          idempotency_key,
          session_id, order_number,
          order_type, order_status,
          order_source, total_amount,
          final_amount, ordered_at,
          business_day, business_timezone
        ) values (
          p_tenant_id, p_store_id,
          v_rg05_key,
          v_test_session_id,
          v_rg05_order_number,
          'TAKEOUT', 'CONFIRMED',
          'KIOSK', 1000, 1000,
          now(), v_business_day, 'Asia/Seoul'
        )
        returning id into v_test_order_id;

        -- KDS 티켓 생성 (HOLD)
        insert into catchmenu_kds.kds_tickets (
          tenant_id, store_id,
          order_id, menu_id,
          menu_name_snapshot, quantity_snapshot,
          kitchen_zone, kds_status,
          conditions_met,
          ticket_created_at,
          business_day, business_timezone
        ) values (
          p_tenant_id, p_store_id,
          v_test_order_id, v_test_menu_id,
          'TEST_MENU', 1, 'MAIN',
          'HOLD',
          jsonb_build_object(
            'payment_confirmed', false,
            'test', true
          ),
          now(), v_business_day, 'Asia/Seoul'
        );

        -- HOLD 확인
        select kds_status into v_kds_status
        from catchmenu_kds.kds_tickets
        where order_id = v_test_order_id;

        perform catchmenu_common.add_final_validation_test_case(
          '특허2: KDS HOLD 확인',
          v_kds_status = 'HOLD',
          '결제 전 KDS = ' || coalesce(
            v_kds_status, 'NULL'
          )
        );

        -- 테스트 데이터 정리
        delete from catchmenu_kds.kds_tickets
        where order_id = v_test_order_id
          and conditions_met->>'test' = 'true';
        delete from catchmenu_pos.orders
        where id = v_test_order_id;
        delete from catchmenu_pos.order_sessions
        where id = v_test_session_id;

      else
        perform catchmenu_common.add_final_validation_test_case(
          '특허2: KDS HOLD 확인',
          true,
          '테스트 메뉴 없음 (스킵)'
        );
      end if;
    end;
  end if;

  -- =====================
  -- 6. RLS 격리 확인
  -- =====================
  perform catchmenu_common.add_final_validation_test_case(
    'RLS 정책 확인',
    (
      select count(*) >= 5
      from pg_policies
      where schemaname like 'catchmenu_%'
    ),
    (
      select count(*)::text
      from pg_policies
      where schemaname like 'catchmenu_%'
    ) || '개 RLS 정책 활성'
  );

  -- =====================
  -- 7. i18n 메시지 확인
  -- =====================
  declare
    v_msg_count int;
    v_locale_count int;
  begin
    select count(*), count(distinct locale)
    into v_msg_count, v_locale_count
    from catchmenu_common.message_catalog;

    perform catchmenu_common.add_final_validation_test_case(
      'i18n 메시지 카탈로그',
      v_locale_count = 6,
      v_msg_count::text || '개 메시지 / '
        || v_locale_count::text || '개 로케일'
    );
  end;

  -- =====================
  -- 8. 에러 코드 확인
  -- =====================
  declare
    v_error_count int;
  begin
    select count(*) into v_error_count
    from catchmenu_common.error_codes;

    perform catchmenu_common.add_final_validation_test_case(
      '에러 코드 등록',
      v_error_count >= 50,
      v_error_count::text || '개 등록'
    );
  end;

  -- =====================
  -- 9. pg_cron 등록 확인
  -- =====================
  declare
    v_cron_count int;
  begin
    select count(*) into v_cron_count
    from catchmenu_common.pg_cron_jobs
    where is_active = true;

    perform catchmenu_common.add_final_validation_test_case(
      'pg_cron 활성 작업',
      v_cron_count >= 20,
      v_cron_count::text || '개 활성'
    );
  end;

  -- =====================
  -- 10. SOP 런북 확인
  -- =====================
  declare
    v_sop_count int;
  begin
    select count(*) into v_sop_count
    from catchmenu_common.sop_runbooks
    where is_active = true;

    perform catchmenu_common.add_final_validation_test_case(
      'SOP 런북 등록',
      v_sop_count >= 20,
      v_sop_count::text || '개 등록'
    );
  end;

  -- =====================
  -- 11. 오픈 체크리스트
  -- =====================
  declare
    v_checklist jsonb;
  begin
    v_checklist :=
      catchmenu_common.run_opening_checklist(
        p_tenant_id, p_store_id
      );

    perform catchmenu_common.add_final_validation_test_case(
      '오픈 체크리스트',
      (v_checklist->'data'->>'overall')
        in ('READY', 'CAUTION'),
      '판정: ' || coalesce(
        v_checklist->'data'->>'overall',
        'N/A'
      )
    );
  end;

  -- =====================
  -- 12. Realtime 채널 확인
  -- =====================
  declare
    v_channel_count int;
  begin
    select count(*) into v_channel_count
    from catchmenu_common.realtime_channels
    where store_id = p_store_id
      and tenant_id = p_tenant_id
      and is_active = true;

    perform catchmenu_common.add_final_validation_test_case(
      'Realtime 채널 확인',
      v_channel_count >= 5,
      v_channel_count::text || '개 채널 활성'
    );
  end;

  -- populate v_results/v_pass/v_fail from the temp table now that all
  -- add_final_validation_test_case() calls above have logged into it
  select
    coalesce(jsonb_agg(
      jsonb_build_object(
        'test', test_name,
        'status', status,
        'detail', detail
      )
      order by ordinal
    ), '[]'::jsonb),
    count(*) filter (where status = 'PASS'),
    count(*) filter (where status = 'FAIL')
  into v_results, v_pass, v_fail
  from pg_temp.final_validation_test_cases;

  -- =====================
  -- 결과 반환
  -- =====================
  return jsonb_build_object(
    'success', true,
    'data', jsonb_build_object(
      'scenario', p_scenario,
      'tenant_id', p_tenant_id,
      'store_id', p_store_id,
      'overall', case v_fail
        when 0 then 'ALL_PASS'
        else 'HAS_FAILURES'
      end,
      'pass_count', v_pass,
      'fail_count', v_fail,
      'total_tests', v_pass + v_fail,
      'tests', v_results,
      'tested_at', now(),
      'next_step', case v_fail
        when 0 then
          'DB 검증 완료. Flutter MVP 개발 시작 가능.'
        else
          'FAIL 항목 수정 후 재실행 필요.'
      end
    )
  );
end;
$function$
;

REVOKE ALL ON FUNCTION catchmenu_common.run_integration_test(uuid, uuid, text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION catchmenu_common.run_integration_test(uuid, uuid, text) TO postgres;
GRANT EXECUTE ON FUNCTION catchmenu_common.run_integration_test(uuid, uuid, text) TO authenticated;
GRANT EXECUTE ON FUNCTION catchmenu_common.run_integration_test(uuid, uuid, text) TO PUBLIC;
COMMENT ON FUNCTION catchmenu_common.run_integration_test(uuid, uuid, text) IS '전체 통합 테스트.

    테스트 항목 (12개):
    1. DB 연결
    2. 스키마 존재 (9개)
    3. 매장 존재
    4. 메뉴 등록
    5. 특허2 KDS HOLD
    6. RLS 정책
    7. i18n 6개 로케일
    8. 에러 코드 50개+
    9. pg_cron 20개+
    10. SOP 런북 20개+
    11. 오픈 체크리스트
    12. Realtime 채널

    DBeaver에서 실행:
    SELECT catchmenu_common.run_integration_test(
      tenant_id, store_id
    );

    ALL_PASS → Flutter MVP 시작.
    HAS_FAILURES → 수정 후 재실행.';

-- catchmenu_pos.submit_kiosk_order(uuid, uuid, uuid, uuid, text, jsonb, text, text, text, text, text, uuid, text)
CREATE OR REPLACE FUNCTION catchmenu_pos.submit_kiosk_order(p_tenant_id uuid, p_store_id uuid, p_session_id uuid, p_kiosk_device_id uuid, p_order_type text, p_items jsonb, p_payment_method text, p_payment_channel text, p_provider_type text, p_request_id text, p_memo text DEFAULT NULL::text, p_table_id uuid DEFAULT NULL::uuid, p_correlation_id text DEFAULT NULL::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'catchmenu_pos', 'catchmenu_kds', 'catchmenu_payment', 'catchmenu_ledger', 'catchmenu_common', 'catchmenu_hq'
AS $function$
declare
  v_session record;
  v_create_result jsonb;
  v_confirm_result jsonb;
  v_intent_result jsonb;
  v_idempotency_key text;
  v_order_id uuid;
begin
  -- session validation
  select id, session_status, session_type,
         business_day, business_timezone
  into v_session
  from catchmenu_pos.order_sessions
  where id = p_session_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id;

  if v_session.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'session_not_found'
    );
  end if;

  if v_session.session_status <> 'ORDERING' then
    return jsonb_build_object(
      'success', false,
      'error_key', 'session_not_ordering',
      'current_status', v_session.session_status
    );
  end if;

  -- WALK_IN Late Binding for DINE_IN
  if p_order_type = 'DINE_IN'
    and p_table_id is not null
  then
    perform catchmenu_pos.bind_table_to_session(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_session_id := p_session_id,
      p_table_id := p_table_id,
      p_actor_type := 'KIOSK',
      p_correlation_id := p_correlation_id
    );
  end if;

  -- step 1: create order
  v_create_result := catchmenu_pos.create_order(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_session_id := p_session_id,
    p_order_type := p_order_type,
    p_order_channel := 'KIOSK',
    p_items := p_items,
    p_request_id := p_request_id,
    p_memo := p_memo,
    p_correlation_id := p_correlation_id
  );

  if not (v_create_result->>'success')::boolean then
    return v_create_result;
  end if;

  v_order_id := (v_create_result->>'order_id')::uuid;

  -- step 2: confirm order (creates KDS tickets in HOLD)
  v_confirm_result := catchmenu_pos.confirm_order(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_order_id := v_order_id,
    p_actor_type := 'KIOSK',
    p_correlation_id := p_correlation_id
  );

  if not (v_confirm_result->>'success')::boolean then
    return v_confirm_result;
  end if;

  -- step 3: create payment intent
  v_idempotency_key := 'KIOSK:' || p_session_id::text
    || ':' || now()::text;

  v_intent_result := catchmenu_payment.create_payment_intent(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_order_id := v_order_id,
    p_session_id := p_session_id,
    p_payment_method := p_payment_method,
    p_payment_channel := p_payment_channel,
    p_provider_type := p_provider_type,
    p_requested_amount :=
      (v_create_result->>'final_amount')::int,
    p_idempotency_key := v_idempotency_key,
    p_correlation_id := p_correlation_id
  );

  if not (v_intent_result->>'success')::boolean then
    return v_intent_result;
  end if;

  return jsonb_build_object(
    'success', true,
    'session_id', p_session_id,
    'order_id', v_order_id,
    'order_number', v_create_result->>'order_number',
    'order_status', 'CONFIRMED',
    'total_amount', v_create_result->>'total_amount',
    'final_amount', v_create_result->>'final_amount',
    'kds_tickets_created',
      v_confirm_result->>'kds_tickets_created',
    'all_tickets_in_hold', true,
    'payment_intent', jsonb_build_object(
      'intent_id', v_intent_result->>'intent_id',
      'provider_order_id',
        v_intent_result->>'provider_order_id',
      'provider_type', p_provider_type
    ),
    'next_step', 'AWAIT_PAYMENT_CONFIRMATION',
    'message_code', 'kiosk_order_submitted'
  );
end;
$function$;

REVOKE ALL ON FUNCTION catchmenu_pos.submit_kiosk_order(uuid, uuid, uuid, uuid, text, jsonb, text, text, text, text, text, uuid, text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION catchmenu_pos.submit_kiosk_order(uuid, uuid, uuid, uuid, text, jsonb, text, text, text, text, text, uuid, text) TO postgres;
GRANT EXECUTE ON FUNCTION catchmenu_pos.submit_kiosk_order(uuid, uuid, uuid, uuid, text, jsonb, text, text, text, text, text, uuid, text) TO authenticated;
COMMENT ON FUNCTION catchmenu_pos.submit_kiosk_order(uuid, uuid, uuid, uuid, text, jsonb, text, text, text, text, text, uuid, text) IS 'Submits complete kiosk order in one call.
   Executes: create_order → confirm_order → create_payment_intent.
   DINE_IN with table_id: bind_table_to_session called first.
   All KDS tickets created in HOLD.
   Returns payment intent for kiosk payment terminal.
   특허1: Kiosk 주문 → 결제 의도 생성 → KDS HOLD.
   특허2: HOLD 티켓은 결제 확인 후 capacity check 진행.';

-- catchmenu_integrations.process_baemin_order(uuid, uuid, jsonb, text, text)
CREATE OR REPLACE FUNCTION catchmenu_integrations.process_baemin_order(p_tenant_id uuid, p_store_id uuid, p_raw_payload jsonb, p_request_id text, p_correlation_id text DEFAULT NULL::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'catchmenu_integrations', 'catchmenu_kds', 'catchmenu_ledger', 'catchmenu_common'
AS $function$
declare
  v_config record;
  v_kds_load int;
  v_provider_order_id text;
  v_normalized jsonb;
  v_intake_result jsonb;
begin
  -- get platform config
  select id, auto_accept_enabled,
         auto_accept_delay_seconds,
         reject_if_kds_overloaded,
         kds_overload_threshold,
         platform_status
  into v_config
  from catchmenu_integrations.delivery_platform_configs
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and platform_type = 'DELIVERY_BAEMIN'
    and is_active = true;

  if v_config.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'baemin_not_configured'
    );
  end if;

  if v_config.platform_status <> 'ACTIVE' then
    return jsonb_build_object(
      'success', false,
      'error_key', 'baemin_platform_suspended',
      'platform_status', v_config.platform_status
    );
  end if;

  -- 특허2: KDS 과부하 체크
  -- COOKING 중인 티켓이 threshold 초과 시 거절
  if v_config.reject_if_kds_overloaded then
    select count(*)
    into v_kds_load
    from catchmenu_kds.kds_tickets
    where store_id = p_store_id
      and tenant_id = p_tenant_id
      and kds_status = 'COOKING';

    if v_kds_load >= v_config.kds_overload_threshold then
      -- auto reject
      perform catchmenu_ledger.create_exception(
        p_tenant_id := p_tenant_id,
        p_store_id := p_store_id,
        p_exception_domain := 'delivery',
        p_exception_type := 'delivery_rejected_kds_overload',
        p_exception_severity := 'WARNING',
        p_subject_type := 'delivery_order',
        p_subject_id := null,
        p_error_message :=
          'Baemin order rejected: KDS overloaded ('
          || v_kds_load || '/'
          || v_config.kds_overload_threshold || ')',
        p_exception_payload := jsonb_build_object(
          'platform', 'DELIVERY_BAEMIN',
          'kds_load', v_kds_load,
          'threshold', v_config.kds_overload_threshold
        ),
        p_correlation_id := p_correlation_id
      );

      return jsonb_build_object(
        'success', false,
        'error_key', 'kds_overloaded',
        'kds_current_load', v_kds_load,
        'threshold', v_config.kds_overload_threshold,
        'action', 'AUTO_REJECTED',
        'message_code', 'baemin_order_rejected_kds_overload'
      );
    end if;
  end if;

  -- extract Baemin order ID
  -- Baemin payload structure: orderId at root
  v_provider_order_id := coalesce(
    p_raw_payload->>'orderId',
    p_raw_payload->>'order_id',
    p_raw_payload->>'id'
  );

  if v_provider_order_id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'missing_baemin_order_id'
    );
  end if;

  -- Baemin-specific normalization
  -- Baemin uses: orderItems array with
  -- menuId, menuName, count, unitPrice
  v_normalized := jsonb_build_object(
    'orderId', v_provider_order_id,
    'totalAmount', coalesce(
      p_raw_payload->>'payAmount',
      p_raw_payload->>'totalAmount',
      '0'
    ),
    'orderItems', coalesce(
      p_raw_payload->'orderItems',
      p_raw_payload->'menus',
      '[]'::jsonb
    ),
    'requestMsg', coalesce(
      p_raw_payload->>'requestMsg',
      p_raw_payload->>'memo',
      ''
    ),
    'estimatedPickupTime',
      p_raw_payload->>'estimatedPickupTime',
    'platform', 'DELIVERY_BAEMIN',
    'baemin_store_id',
      p_raw_payload->>'storeId',
    'order_type',
      coalesce(p_raw_payload->>'orderType', 'DELIVERY')
  );

  -- route to common intake RPC
  v_intake_result :=
    catchmenu_integrations.intake_delivery_order(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_provider_type := 'DELIVERY_BAEMIN',
      p_provider_order_id := v_provider_order_id,
      p_provider_raw_payload := v_normalized,
      p_request_id := p_request_id,
      p_correlation_id := p_correlation_id
    );

  return v_intake_result || jsonb_build_object(
    'platform', 'DELIVERY_BAEMIN',
    'auto_accept_delay_seconds',
      v_config.auto_accept_delay_seconds
  );
end;
$function$;

REVOKE ALL ON FUNCTION catchmenu_integrations.process_baemin_order(uuid, uuid, jsonb, text, text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION catchmenu_integrations.process_baemin_order(uuid, uuid, jsonb, text, text) TO postgres;
GRANT EXECUTE ON FUNCTION catchmenu_integrations.process_baemin_order(uuid, uuid, jsonb, text, text) TO authenticated;
COMMENT ON FUNCTION catchmenu_integrations.process_baemin_order(uuid, uuid, jsonb, text, text) IS 'Baemin-specific order processor.
   1. Checks platform config and status.
   2. KDS overload check (특허2):
      cooking tickets >= threshold → auto reject.
   3. Normalizes Baemin payload to internal format.
   4. Routes to intake_delivery_order.
   Baemin payload: orderId, orderItems[], payAmount,
   requestMsg, estimatedPickupTime.';

-- catchmenu_integrations.process_coupang_order(uuid, uuid, jsonb, text, text)
CREATE OR REPLACE FUNCTION catchmenu_integrations.process_coupang_order(p_tenant_id uuid, p_store_id uuid, p_raw_payload jsonb, p_request_id text, p_correlation_id text DEFAULT NULL::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'catchmenu_integrations', 'catchmenu_kds', 'catchmenu_ledger', 'catchmenu_common'
AS $function$
declare
  v_config record;
  v_kds_load int;
  v_provider_order_id text;
  v_normalized jsonb;
  v_intake_result jsonb;
begin
  select id, auto_accept_enabled,
         auto_accept_delay_seconds,
         reject_if_kds_overloaded,
         kds_overload_threshold,
         platform_status
  into v_config
  from catchmenu_integrations.delivery_platform_configs
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and platform_type = 'DELIVERY_COUPANG'
    and is_active = true;

  if v_config.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'coupang_not_configured'
    );
  end if;

  if v_config.platform_status <> 'ACTIVE' then
    return jsonb_build_object(
      'success', false,
      'error_key', 'coupang_platform_suspended'
    );
  end if;

  -- KDS overload check
  if v_config.reject_if_kds_overloaded then
    select count(*)
    into v_kds_load
    from catchmenu_kds.kds_tickets
    where store_id = p_store_id
      and tenant_id = p_tenant_id
      and kds_status = 'COOKING';

    if v_kds_load >= v_config.kds_overload_threshold then
      return jsonb_build_object(
        'success', false,
        'error_key', 'kds_overloaded',
        'kds_current_load', v_kds_load,
        'threshold', v_config.kds_overload_threshold,
        'action', 'AUTO_REJECTED',
        'message_code',
          'coupang_order_rejected_kds_overload'
      );
    end if;
  end if;

  -- Coupang Eats payload: orderNo at root
  v_provider_order_id := coalesce(
    p_raw_payload->>'orderNo',
    p_raw_payload->>'orderId',
    p_raw_payload->>'order_id'
  );

  if v_provider_order_id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'missing_coupang_order_id'
    );
  end if;

  -- Coupang-specific normalization
  -- Coupang uses: cartItems array with
  -- productId, productName, quantity, unitPrice
  v_normalized := jsonb_build_object(
    'orderId', v_provider_order_id,
    'totalAmount', coalesce(
      p_raw_payload->>'totalPrice',
      p_raw_payload->>'orderAmount',
      '0'
    ),
    'orderItems', (
      select coalesce(
        jsonb_agg(
          jsonb_build_object(
            'menuId', item->>'productId',
            'menuName', item->>'productName',
            'count', item->>'quantity',
            'unitPrice', item->>'unitPrice',
            'options', item->'options'
          )
        ),
        '[]'::jsonb
      )
      from jsonb_array_elements(
        coalesce(
          p_raw_payload->'cartItems',
          p_raw_payload->'items',
          '[]'::jsonb
        )
      ) item
    ),
    'requestMsg', coalesce(
      p_raw_payload->>'storeRequest',
      p_raw_payload->>'requestMsg',
      ''
    ),
    'estimatedPickupTime',
      p_raw_payload->>'estimatedPickupAt',
    'platform', 'DELIVERY_COUPANG',
    'coupang_vendor_id',
      p_raw_payload->>'vendorId'
  );

  -- route to common intake
  v_intake_result :=
    catchmenu_integrations.intake_delivery_order(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_provider_type := 'DELIVERY_COUPANG',
      p_provider_order_id := v_provider_order_id,
      p_provider_raw_payload := v_normalized,
      p_request_id := p_request_id,
      p_correlation_id := p_correlation_id
    );

  return v_intake_result || jsonb_build_object(
    'platform', 'DELIVERY_COUPANG',
    'auto_accept_delay_seconds',
      v_config.auto_accept_delay_seconds
  );
end;
$function$;

REVOKE ALL ON FUNCTION catchmenu_integrations.process_coupang_order(uuid, uuid, jsonb, text, text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION catchmenu_integrations.process_coupang_order(uuid, uuid, jsonb, text, text) TO postgres;
GRANT EXECUTE ON FUNCTION catchmenu_integrations.process_coupang_order(uuid, uuid, jsonb, text, text) TO authenticated;
COMMENT ON FUNCTION catchmenu_integrations.process_coupang_order(uuid, uuid, jsonb, text, text) IS 'Coupang Eats specific order processor.
   Normalizes Coupang payload format:
   orderNo → orderId
   cartItems[].productId → menuId
   cartItems[].productName → menuName
   특허2: KDS 과부하 시 자동 거절.';

-- catchmenu_integrations.process_okpos_order(uuid, uuid, jsonb, text, text)
CREATE OR REPLACE FUNCTION catchmenu_integrations.process_okpos_order(p_tenant_id uuid, p_store_id uuid, p_raw_payload jsonb, p_request_id text, p_correlation_id text DEFAULT NULL::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'catchmenu_integrations', 'catchmenu_gateway', 'catchmenu_pos', 'catchmenu_kds', 'catchmenu_ledger', 'catchmenu_common', 'catchmenu_hq'
AS $function$
declare
  v_config record;
  v_tx_id uuid;
  v_provider_event_id uuid;
  v_okpos_order_id text;
  v_tx_type text;
  v_normalized jsonb;
  v_order_result jsonb;
  v_business_day date;
  v_timezone text;
begin
  -- feature flag 확인
  if not catchmenu_common.is_feature_enabled(
    p_tenant_id, 'OKPOS_INTEGRATION'
  ) then
    return jsonb_build_object(
      'success', false,
      'error_key', 'feature_not_enabled',
      'feature_code', 'OKPOS_INTEGRATION'
    );
  end if;

  -- POS config 확인
  select psc.id, psc.config_status,
         psc.order_push_enabled,
         psc.merchant_id, psc.terminal_id
  into v_config
  from catchmenu_integrations.pos_store_configs psc
  where psc.store_id = p_store_id
    and psc.tenant_id = p_tenant_id
    and psc.provider_code = 'OKPOS'
    and psc.is_active = true;

  if v_config.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'okpos_not_configured',
      'message', 'OKpos 연동이 설정되지 않았습니다'
    );
  end if;

  if v_config.config_status <> 'ACTIVE' then
    return jsonb_build_object(
      'success', false,
      'error_key', 'okpos_not_active',
      'config_status', v_config.config_status
    );
  end if;

  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  -- OKpos 페이로드 파싱
  -- OKpos payload structure:
  -- orderId, orderType, items[], totalAmount,
  -- requestMsg, txType
  v_okpos_order_id := coalesce(
    p_raw_payload->>'orderId',
    p_raw_payload->>'orderNo',
    p_raw_payload->>'id'
  );
  v_tx_type := coalesce(
    p_raw_payload->>'txType',
    'NEW_ORDER'
  );

  if v_okpos_order_id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'missing_okpos_order_id'
    );
  end if;

  -- store raw transaction
  insert into catchmenu_integrations.okpos_transactions (
    tenant_id, store_id,
    okpos_order_id, okpos_store_id,
    okpos_terminal_id, okpos_tx_type,
    total_amount,
    okpos_status, raw_request,
    processing_status,
    okpos_ordered_at,
    business_day, business_timezone
  ) values (
    p_tenant_id, p_store_id,
    v_okpos_order_id,
    v_config.merchant_id,
    v_config.terminal_id,
    v_tx_type,
    (p_raw_payload->>'totalAmount')::int,
    'RECEIVED', p_raw_payload,
    'PROCESSING',
    now(),
    v_business_day, v_timezone
  )
  on conflict (store_id, okpos_order_id) do update set
    processing_status = 'PROCESSING',
    updated_at = now()
  returning id into v_tx_id;

  -- store in gateway
  insert into catchmenu_gateway.provider_raw_events (
    tenant_id, store_id,
    provider_type, provider_code,
    provider_event_id, provider_event_type,
    raw_payload, payload_hash,
    signature_verified, schema_validated,
    processing_status,
    correlation_id, received_at
  ) values (
    p_tenant_id, p_store_id,
    'OKPOS', 'OKPOS',
    v_okpos_order_id, v_tx_type,
    p_raw_payload,
    encode(digest(
      p_raw_payload::text, 'sha256'
    ), 'hex'),
    true, true,
    'VALIDATING',
    p_correlation_id, now()
  )
  returning id into v_provider_event_id;

  -- route by tx_type
  case v_tx_type
    when 'NEW_ORDER' then
      -- normalize OKpos → common format
      v_normalized := jsonb_build_object(
        'orderId', v_okpos_order_id,
        'totalAmount', coalesce(
          p_raw_payload->>'totalAmount', '0'
        ),
        'orderItems', coalesce(
          p_raw_payload->'items',
          p_raw_payload->'orderItems',
          '[]'::jsonb
        ),
        'requestMsg', coalesce(
          p_raw_payload->>'requestMsg',
          p_raw_payload->>'memo', ''
        ),
        'orderType', coalesce(
          p_raw_payload->>'orderType', 'TAKEOUT'
        ),
        'platform', 'OKPOS'
      );

      -- route to intake
      v_order_result :=
        catchmenu_integrations.intake_delivery_order(
          p_tenant_id := p_tenant_id,
          p_store_id := p_store_id,
          p_provider_type := 'DELIVERY_BAEMIN',
          p_provider_order_id := v_okpos_order_id,
          p_provider_raw_payload := v_normalized,
      p_request_id := p_request_id,
          p_correlation_id := p_correlation_id
        );

      -- update tx status
      update catchmenu_integrations.okpos_transactions
      set
        order_id = (v_order_result->>'order_id')::uuid,
        processing_status = case
          when (v_order_result->>'success')::boolean
            then 'COMPLETED'
          else 'FAILED'
        end,
        processing_error = case
          when not (v_order_result->>'success')::boolean
            then v_order_result->>'error_key'
          else null
        end,
        processed_at = now(),
        updated_at = now()
      where id = v_tx_id;

    when 'ORDER_CANCEL' then
      -- 취소 처리
      update catchmenu_integrations.okpos_transactions
      set
        okpos_status = 'CANCELLED',
        processing_status = 'COMPLETED',
        processed_at = now(),
        updated_at = now()
      where id = v_tx_id;

      v_order_result := jsonb_build_object(
        'success', true,
        'action', 'order_cancel_noted',
        'okpos_order_id', v_okpos_order_id
      );

    else
      -- unknown type → log and ignore
      update catchmenu_integrations.okpos_transactions
      set
        processing_status = 'IGNORED',
        processed_at = now(),
        updated_at = now()
      where id = v_tx_id;

      v_order_result := jsonb_build_object(
        'success', true,
        'action', 'ignored',
        'tx_type', v_tx_type
      );
  end case;

  -- update gateway event
  update catchmenu_gateway.provider_raw_events
  set
    processing_status = case
      when (v_order_result->>'success')::boolean
        then 'ACCEPTED'
      else 'REJECTED'
    end,
    accepted_at = case
      when (v_order_result->>'success')::boolean
        then now()
      else null
    end
  where id = v_provider_event_id;

  -- update heartbeat
  update catchmenu_integrations.pos_store_configs
  set
    last_order_pushed_at = now(),
    last_heartbeat_at = now(),
    consecutive_failures = case
      when (v_order_result->>'success')::boolean
        then 0
      else consecutive_failures + 1
    end,
    last_error_at = case
      when not (v_order_result->>'success')::boolean
        then now()
      else last_error_at
    end,
    last_error_message = case
      when not (v_order_result->>'success')::boolean
        then v_order_result->>'error_key'
      else null
    end
  where id = v_config.id;

  return jsonb_build_object(
    'success', (v_order_result->>'success')::boolean,
    'tx_id', v_tx_id,
    'okpos_order_id', v_okpos_order_id,
    'tx_type', v_tx_type,
    'provider_event_id', v_provider_event_id,
    'order_result', v_order_result,
    'message_code', 'okpos_order_processed'
  );
end;
$function$;

REVOKE ALL ON FUNCTION catchmenu_integrations.process_okpos_order(uuid, uuid, jsonb, text, text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION catchmenu_integrations.process_okpos_order(uuid, uuid, jsonb, text, text) TO postgres;
GRANT EXECUTE ON FUNCTION catchmenu_integrations.process_okpos_order(uuid, uuid, jsonb, text, text) TO authenticated;
COMMENT ON FUNCTION catchmenu_integrations.process_okpos_order(uuid, uuid, jsonb, text, text) IS 'OKpos 주문 수신 처리.
   1차 MVP 핵심 연동.
   feature_flag OKPOS_INTEGRATION 확인 후 처리.
   Gateway 샌드박스 경유 → 내부 원장 반영.
   특허1: 외부 POS → Gateway → 내부 원장.';

-- catchmenu_integrations.process_toss_pos_order(uuid, uuid, jsonb, text, text)
CREATE OR REPLACE FUNCTION catchmenu_integrations.process_toss_pos_order(p_tenant_id uuid, p_store_id uuid, p_raw_payload jsonb, p_request_id text, p_correlation_id text DEFAULT NULL::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'catchmenu_integrations', 'catchmenu_gateway', 'catchmenu_common', 'catchmenu_hq'
AS $function$
declare
  v_config record;
  v_tx_id uuid;
  v_provider_event_id uuid;
  v_toss_pos_order_id text;
  v_tx_type text;
  v_normalized jsonb;
  v_order_result jsonb;
  v_business_day date;
  v_timezone text;
begin
  -- feature flag 확인
  if not catchmenu_common.is_feature_enabled(
    p_tenant_id, 'TOSS_POS_INTEGRATION'
  ) then
    return jsonb_build_object(
      'success', false,
      'error_key', 'feature_not_enabled',
      'feature_code', 'TOSS_POS_INTEGRATION'
    );
  end if;

  -- POS config 확인
  select psc.id, psc.config_status,
         psc.merchant_id, psc.terminal_id
  into v_config
  from catchmenu_integrations.pos_store_configs psc
  where psc.store_id = p_store_id
    and psc.tenant_id = p_tenant_id
    and psc.provider_code = 'TOSS_POS'
    and psc.is_active = true;

  if v_config.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'toss_pos_not_configured',
      'message', '토스 POS 연동이 설정되지 않았습니다'
    );
  end if;

  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  -- 토스 POS 페이로드 파싱
  -- Toss POS payload: orderId, items[], amount,
  -- paymentKey, txType
  v_toss_pos_order_id := coalesce(
    p_raw_payload->>'orderId',
    p_raw_payload->>'orderNo'
  );
  v_tx_type := coalesce(
    p_raw_payload->>'txType', 'NEW_ORDER'
  );

  if v_toss_pos_order_id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'missing_toss_pos_order_id'
    );
  end if;

  -- store raw transaction
  insert into catchmenu_integrations.toss_pos_transactions (
    tenant_id, store_id,
    toss_pos_order_id,
    toss_pos_terminal_id, toss_pos_merchant_id,
    toss_pos_tx_type,
    toss_payment_key,
    total_amount, card_amount,
    toss_pos_status, raw_request,
    processing_status,
    toss_pos_ordered_at,
    business_day, business_timezone
  ) values (
    p_tenant_id, p_store_id,
    v_toss_pos_order_id,
    v_config.terminal_id,
    v_config.merchant_id,
    v_tx_type,
    p_raw_payload->>'paymentKey',
    (p_raw_payload->>'amount')::int,
    (p_raw_payload->>'cardAmount')::int,
    'RECEIVED', p_raw_payload,
    'PROCESSING',
    now(),
    v_business_day, v_timezone
  )
  on conflict (store_id, toss_pos_order_id)
  do update set
    processing_status = 'PROCESSING',
    updated_at = now()
  returning id into v_tx_id;

  -- store in gateway
  insert into catchmenu_gateway.provider_raw_events (
    tenant_id, store_id,
    provider_type, provider_code,
    provider_event_id, provider_event_type,
    raw_payload, payload_hash,
    signature_verified, schema_validated,
    processing_status,
    correlation_id, received_at
  ) values (
    p_tenant_id, p_store_id,
    'TOSS_POS', 'TOSS_POS',
    v_toss_pos_order_id, v_tx_type,
    p_raw_payload,
    encode(digest(
      p_raw_payload::text, 'sha256'
    ), 'hex'),
    true, true,
    'VALIDATING',
    p_correlation_id, now()
  )
  returning id into v_provider_event_id;

  -- normalize for common processing
  v_normalized := jsonb_build_object(
    'orderId', v_toss_pos_order_id,
    'totalAmount', coalesce(
      p_raw_payload->>'amount', '0'
    ),
    'orderItems', coalesce(
      p_raw_payload->'items',
      '[]'::jsonb
    ),
    'requestMsg', coalesce(
      p_raw_payload->>'memo', ''
    ),
    'orderType', coalesce(
      p_raw_payload->>'orderType', 'TAKEOUT'
    ),
    'paymentKey', p_raw_payload->>'paymentKey',
    'platform', 'TOSS_POS'
  );

  -- route by tx_type
  case v_tx_type
    when 'NEW_ORDER', 'PAYMENT_CONFIRM' then
      v_order_result :=
        catchmenu_integrations.intake_delivery_order(
          p_tenant_id := p_tenant_id,
          p_store_id := p_store_id,
          p_provider_type := 'DELIVERY_BAEMIN',
          p_provider_order_id := v_toss_pos_order_id,
          p_provider_raw_payload := v_normalized,
      p_request_id := p_request_id,
          p_correlation_id := p_correlation_id
        );

    when 'ORDER_CANCEL', 'PAYMENT_CANCEL' then
      v_order_result := jsonb_build_object(
        'success', true,
        'action', 'cancel_noted',
        'toss_pos_order_id', v_toss_pos_order_id
      );

    else
      v_order_result := jsonb_build_object(
        'success', true,
        'action', 'ignored',
        'tx_type', v_tx_type
      );
  end case;

  -- update tx
  update catchmenu_integrations.toss_pos_transactions
  set
    order_id = case
      when v_order_result->>'order_id' is not null
        then (v_order_result->>'order_id')::uuid
      else null
    end,
    processing_status = case
      when (v_order_result->>'success')::boolean
        then 'COMPLETED'
      else 'FAILED'
    end,
    processed_at = now(),
    updated_at = now()
  where id = v_tx_id;

  -- update gateway
  update catchmenu_gateway.provider_raw_events
  set
    processing_status = 'ACCEPTED',
    accepted_at = now()
  where id = v_provider_event_id;

  -- update heartbeat
  update catchmenu_integrations.pos_store_configs
  set
    last_order_pushed_at = now(),
    last_heartbeat_at = now(),
    consecutive_failures = case
      when (v_order_result->>'success')::boolean
        then 0
      else consecutive_failures + 1
    end
  where id = v_config.id;

  return jsonb_build_object(
    'success', (v_order_result->>'success')::boolean,
    'tx_id', v_tx_id,
    'toss_pos_order_id', v_toss_pos_order_id,
    'tx_type', v_tx_type,
    'order_result', v_order_result,
    'message_code', 'toss_pos_order_processed'
  );
end;
$function$;

REVOKE ALL ON FUNCTION catchmenu_integrations.process_toss_pos_order(uuid, uuid, jsonb, text, text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION catchmenu_integrations.process_toss_pos_order(uuid, uuid, jsonb, text, text) TO postgres;
GRANT EXECUTE ON FUNCTION catchmenu_integrations.process_toss_pos_order(uuid, uuid, jsonb, text, text) TO authenticated;

-- catchmenu_integrations.process_yogiyo_order(uuid, uuid, jsonb, text, text)
CREATE OR REPLACE FUNCTION catchmenu_integrations.process_yogiyo_order(p_tenant_id uuid, p_store_id uuid, p_raw_payload jsonb, p_request_id text, p_correlation_id text DEFAULT NULL::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'catchmenu_integrations', 'catchmenu_kds', 'catchmenu_ledger', 'catchmenu_common'
AS $function$
declare
  v_config record;
  v_kds_load int;
  v_provider_order_id text;
  v_normalized jsonb;
  v_intake_result jsonb;
begin
  select id, auto_accept_enabled,
         auto_accept_delay_seconds,
         reject_if_kds_overloaded,
         kds_overload_threshold,
         platform_status
  into v_config
  from catchmenu_integrations.delivery_platform_configs
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and platform_type = 'DELIVERY_YOGIYO'
    and is_active = true;

  if v_config.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'yogiyo_not_configured'
    );
  end if;

  if v_config.platform_status <> 'ACTIVE' then
    return jsonb_build_object(
      'success', false,
      'error_key', 'yogiyo_platform_suspended'
    );
  end if;

  -- KDS overload check
  if v_config.reject_if_kds_overloaded then
    select count(*)
    into v_kds_load
    from catchmenu_kds.kds_tickets
    where store_id = p_store_id
      and tenant_id = p_tenant_id
      and kds_status = 'COOKING';

    if v_kds_load >= v_config.kds_overload_threshold then
      return jsonb_build_object(
        'success', false,
        'error_key', 'kds_overloaded',
        'kds_current_load', v_kds_load,
        'threshold', v_config.kds_overload_threshold,
        'action', 'AUTO_REJECTED',
        'message_code',
          'yogiyo_order_rejected_kds_overload'
      );
    end if;
  end if;

  -- Yogiyo-specific order ID extraction
  -- Yogiyo payload: order_number at root
  v_provider_order_id := coalesce(
    p_raw_payload->>'order_number',
    p_raw_payload->>'orderId',
    p_raw_payload->>'id'
  );

  if v_provider_order_id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'missing_yogiyo_order_id'
    );
  end if;

  -- Yogiyo-specific normalization
  -- Yogiyo uses: items array with
  -- product_id, product_name, quantity, product_price
  v_normalized := jsonb_build_object(
    'orderId', v_provider_order_id,
    'totalAmount', coalesce(
      p_raw_payload->>'total_price',
      p_raw_payload->>'totalPrice',
      '0'
    ),
    'orderItems', (
      select coalesce(
        jsonb_agg(
          jsonb_build_object(
            'menuId', item->>'product_id',
            'menuName', item->>'product_name',
            'count', item->>'quantity',
            'unitPrice', item->>'product_price'
          )
        ),
        '[]'::jsonb
      )
      from jsonb_array_elements(
        coalesce(
          p_raw_payload->'items',
          p_raw_payload->'order_items',
          '[]'::jsonb
        )
      ) item
    ),
    'requestMsg', coalesce(
      p_raw_payload->>'request_message',
      p_raw_payload->>'memo',
      ''
    ),
    'estimatedPickupTime',
      p_raw_payload->>'pickup_time',
    'platform', 'DELIVERY_YOGIYO',
    'yogiyo_store_id',
      p_raw_payload->>'store_id'
  );

  -- route to common intake
  v_intake_result :=
    catchmenu_integrations.intake_delivery_order(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_provider_type := 'DELIVERY_YOGIYO',
      p_provider_order_id := v_provider_order_id,
      p_provider_raw_payload := v_normalized,
      p_request_id := p_request_id,
      p_correlation_id := p_correlation_id
    );

  return v_intake_result || jsonb_build_object(
    'platform', 'DELIVERY_YOGIYO',
    'auto_accept_delay_seconds',
      v_config.auto_accept_delay_seconds
  );
end;
$function$;

REVOKE ALL ON FUNCTION catchmenu_integrations.process_yogiyo_order(uuid, uuid, jsonb, text, text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION catchmenu_integrations.process_yogiyo_order(uuid, uuid, jsonb, text, text) TO postgres;
GRANT EXECUTE ON FUNCTION catchmenu_integrations.process_yogiyo_order(uuid, uuid, jsonb, text, text) TO authenticated;
COMMENT ON FUNCTION catchmenu_integrations.process_yogiyo_order(uuid, uuid, jsonb, text, text) IS 'Yogiyo-specific order processor.
   Normalizes Yogiyo payload format:
   order_number → orderId
   items[].product_id → menuId
   items[].product_name → menuName
   items[].quantity → count
   특허2: KDS 과부하 시 자동 거절.';

-- Remove the superseded signatures after every new caller is defined.
DROP FUNCTION catchmenu_pos.submit_kiosk_order(uuid, uuid, uuid, uuid, text, jsonb, text, text, text, text, uuid, text);
DROP FUNCTION catchmenu_integrations.process_baemin_order(uuid, uuid, jsonb, text);
DROP FUNCTION catchmenu_integrations.process_coupang_order(uuid, uuid, jsonb, text);
DROP FUNCTION catchmenu_integrations.process_okpos_order(uuid, uuid, jsonb, text);
DROP FUNCTION catchmenu_integrations.process_toss_pos_order(uuid, uuid, jsonb, text);
DROP FUNCTION catchmenu_integrations.process_yogiyo_order(uuid, uuid, jsonb, text);
DROP FUNCTION catchmenu_pos.create_order(uuid, uuid, uuid, text, text, jsonb, text, text, text);
DROP FUNCTION catchmenu_pos.create_pre_order(uuid, uuid, uuid, jsonb, text, text);
DROP FUNCTION catchmenu_pos.pre_order_while_waiting(uuid, uuid, uuid, jsonb, text, text);
DROP FUNCTION catchmenu_store.place_kiosk_order(uuid, uuid, uuid, uuid, jsonb, text, text, text, text);
DROP FUNCTION catchmenu_store.place_takeout_order(uuid, uuid, jsonb, uuid, text, text, text, uuid, integer, timestamp with time zone, text);
DROP FUNCTION catchmenu_integrations.intake_delivery_order(uuid, uuid, text, text, jsonb, uuid, text);
DROP FUNCTION catchmenu_common.flush_offline_queue(uuid, uuid, uuid, integer, text);

COMMIT;
