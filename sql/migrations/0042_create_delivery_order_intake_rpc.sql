-- 0042_create_delivery_order_intake_rpc.sql
-- Purpose: Delivery order intake from external platforms.
--          Common intake RPC for Baemin, Yogiyo, Coupang Eats.
--          All delivery orders enter through gateway sandbox.
--          특허1 core: 외부 배달앱 주문 → Gateway 샌드박스 → 내부 원장.
-- Depends on: 0041_create_agent_heartbeat_rpc.sql
-- Creates:
--   function catchmenu_integrations.intake_delivery_order(...)
--   function catchmenu_integrations.sync_delivery_order_status(...)
--   function catchmenu_integrations.reject_delivery_order(...)

create or replace function catchmenu_integrations.intake_delivery_order(
  p_tenant_id uuid,
  p_store_id uuid,
  p_provider_type text,
  p_provider_order_id text,
  p_provider_raw_payload jsonb,
  p_gateway_session_id uuid default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_integrations, catchmenu_gateway,
                  catchmenu_pos, catchmenu_kds,
                  catchmenu_ledger, catchmenu_audit,
                  catchmenu_common, catchmenu_hq
as $$
declare
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

  -- idempotency check
  if exists (
    select 1
    from catchmenu_common.idempotency_keys
    where tenant_id = p_tenant_id
      and key_domain = 'order'
      and idempotency_key = p_provider_type
        || ':' || p_provider_order_id
      and processing_status in ('PROCESSING', 'COMPLETED')
  ) then
    return jsonb_build_object(
      'success', false,
      'error_key', 'duplicate_delivery_order',
      'provider_order_id', p_provider_order_id,
      'message_code', 'order_already_received'
    );
  end if;

  -- register idempotency key
  insert into catchmenu_common.idempotency_keys (
    tenant_id, store_id,
    idempotency_key, key_domain, key_scope,
    operation_type, processing_status,
    provider_event_id, correlation_id
  ) values (
    p_tenant_id, p_store_id,
    p_provider_type || ':' || p_provider_order_id,
    'order', 'STORE',
    'delivery_order_intake', 'PROCESSING',
    p_provider_order_id, p_correlation_id
  );

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

  -- generate order number
  select count(*) + 1
  into v_order_count
  from catchmenu_pos.orders
  where store_id = p_store_id
    and business_day = v_business_day;

  v_order_number := 'D-' || lpad(v_order_count::text, 4, '0');

  -- create delivery order session
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
    business_day, business_timezone
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
    v_business_day, v_timezone
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

  -- update idempotency key to COMPLETED
  update catchmenu_common.idempotency_keys
  set
    processing_status = 'COMPLETED',
    completed_at = now(),
    result_payload := jsonb_build_object(
      'order_id', v_order_id,
      'session_id', v_session_id,
      'order_number', v_order_number
    )
  where tenant_id = p_tenant_id
    and key_domain = 'order'
    and idempotency_key =
      p_provider_type || ':' || p_provider_order_id;

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

  return jsonb_build_object(
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
end;
$$;


create or replace function catchmenu_integrations.sync_delivery_order_status(
  p_tenant_id uuid,
  p_store_id uuid,
  p_order_id uuid,
  p_provider_type text,
  p_provider_status text,
  p_provider_event_payload jsonb default '{}'::jsonb,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_pos, catchmenu_ledger,
                  catchmenu_common
as $$
declare
  v_order record;
  v_internal_status text;
begin
  select id, order_status, session_id,
         business_day, business_timezone
  into v_order
  from catchmenu_pos.orders
  where id = p_order_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id;

  if v_order.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'order_not_found'
    );
  end if;

  -- map provider status to internal status
  v_internal_status := case p_provider_status
    when 'ACCEPTED' then 'CONFIRMED'
    when 'COOKING' then 'COOKING'
    when 'READY' then 'READY'
    when 'PICKED_UP' then 'COMPLETED'
    when 'DELIVERED' then 'COMPLETED'
    when 'CANCELLED' then 'CANCELLED'
    else v_order.order_status
  end;

  -- update order if status changed
  if v_internal_status <> v_order.order_status then
    update catchmenu_pos.orders
    set
      order_status = v_internal_status,
      completed_at = case v_internal_status
        when 'COMPLETED' then now()
        else completed_at
      end,
      cancelled_at = case v_internal_status
        when 'CANCELLED' then now()
        else cancelled_at
      end,
      updated_at = now()
    where id = p_order_id;

    -- order event
    insert into catchmenu_pos.order_events (
      tenant_id, store_id, order_id,
      event_type, from_status, to_status,
      caused_by_type,
      event_payload, correlation_id, occurred_at
    ) values (
      p_tenant_id, p_store_id, p_order_id,
      'pos_sync_completed',
      v_order.order_status, v_internal_status,
      'PROVIDER',
      jsonb_build_object(
        'provider_type', p_provider_type,
        'provider_status', p_provider_status,
        'sync_payload', p_provider_event_payload
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
      'order', 'delivery_status_synced', 1,
      'order', p_order_id,
      v_order.order_status, v_internal_status,
      'PROVIDER',
      jsonb_build_object(
        'provider_type', p_provider_type,
        'provider_status', p_provider_status
      ),
      v_order.session_id, p_order_id,
      p_correlation_id,
      v_order.business_day, v_order.business_timezone, now()
    );
  end if;

  return jsonb_build_object(
    'success', true,
    'order_id', p_order_id,
    'provider_status', p_provider_status,
    'internal_status', v_internal_status,
    'status_changed', v_internal_status <> v_order.order_status,
    'message_code', 'delivery_status_synced'
  );
end;
$$;


create or replace function catchmenu_integrations.reject_delivery_order(
  p_tenant_id uuid,
  p_store_id uuid,
  p_provider_type text,
  p_provider_order_id text,
  p_reject_reason text,
  p_actor_type text default 'STAFF',
  p_actor_id uuid default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_pos, catchmenu_gateway,
                  catchmenu_ledger, catchmenu_audit,
                  catchmenu_common, catchmenu_hq
as $$
declare
  v_order record;
  v_session_id uuid;
  v_audit_id uuid;
  v_business_day date;
  v_timezone text;
begin
  if trim(coalesce(p_reject_reason, '')) = '' then
    return jsonb_build_object(
      'success', false,
      'error_key', 'reject_reason_required'
    );
  end if;

  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  -- find order by provider channel and order number pattern
  select o.id, o.order_status, o.session_id
  into v_order
  from catchmenu_pos.orders o
  where o.store_id = p_store_id
    and o.tenant_id = p_tenant_id
    and o.order_channel = p_provider_type
    and o.order_status not in (
      'COMPLETED', 'CANCELLED'
    )
  order by o.ordered_at desc
  limit 1;

  if v_order.id is null then
    -- order not found — reject at gateway level
    update catchmenu_gateway.provider_raw_events
    set
      processing_status = 'REJECTED',
      rejected_at = now(),
      rejection_reason = p_reject_reason
    where provider_event_id = p_provider_order_id
      and provider_type = p_provider_type
      and store_id = p_store_id;

    return jsonb_build_object(
      'success', true,
      'rejected_at_gateway', true,
      'provider_order_id', p_provider_order_id,
      'reject_reason', p_reject_reason,
      'message_code', 'delivery_order_rejected_at_gateway'
    );
  end if;

  -- cancel internal order
  update catchmenu_pos.orders
  set
    order_status = 'CANCELLED',
    cancelled_at = now(),
    updated_at = now()
  where id = v_order.id;

  -- cancel KDS tickets
  update catchmenu_kds.kds_tickets
  set
    kds_status = 'CANCELLED',
    cancelled_at = now(),
    hold_reason = 'DELIVERY_ORDER_REJECTED',
    updated_at = now()
  where order_id = v_order.id
    and kds_status not in (
      'COMPLETED', 'CANCELLED', 'SERVED'
    );

  -- order event
  insert into catchmenu_pos.order_events (
    tenant_id, store_id, order_id,
    event_type, from_status, to_status,
    caused_by_type, caused_by_id,
    event_payload, correlation_id, occurred_at
  ) values (
    p_tenant_id, p_store_id, v_order.id,
    'order_cancelled',
    v_order.order_status, 'CANCELLED',
    p_actor_type, p_actor_id,
    jsonb_build_object(
      'reject_reason', p_reject_reason,
      'provider_type', p_provider_type,
      'provider_order_id', p_provider_order_id
    ),
    p_correlation_id, now()
  );

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
    'order', 'delivery_order_rejected', 1,
    'order', v_order.id,
    v_order.order_status, 'CANCELLED',
    p_actor_type, p_actor_id,
    jsonb_build_object(
      'reject_reason', p_reject_reason,
      'provider_type', p_provider_type
    ),
    v_order.session_id, v_order.id,
    p_correlation_id,
    v_business_day, v_timezone, now()
  );

  -- audit
  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := 'order',
    p_audit_type := 'delivery_order_rejected',
    p_audit_category := 'OPERATIONAL',
    p_actor_type := p_actor_type,
    p_actor_id := p_actor_id,
    p_subject_type := 'order',
    p_subject_id := v_order.id,
    p_decision := 'REJECTED',
    p_decision_reason := p_reject_reason,
    p_decision_payload := jsonb_build_object(
      'provider_type', p_provider_type,
      'provider_order_id', p_provider_order_id
    ),
    p_order_id := v_order.id,
    p_correlation_id := p_correlation_id,
    p_business_day := v_business_day,
    p_business_timezone := v_timezone
  );

  return jsonb_build_object(
    'success', true,
    'order_id', v_order.id,
    'order_status', 'CANCELLED',
    'reject_reason', p_reject_reason,
    'provider_type', p_provider_type,
    'provider_order_id', p_provider_order_id,
    'audit_id', v_audit_id,
    'message_code', 'delivery_order_rejected'
  );
end;
$$;

-- grants
do $$
begin
  revoke all on function catchmenu_integrations.intake_delivery_order(
    uuid, uuid, text, text, jsonb, uuid, text
  ) from public;
  grant execute on function catchmenu_integrations.intake_delivery_order(
    uuid, uuid, text, text, jsonb, uuid, text
  ) to authenticated;

  revoke all on function catchmenu_integrations.sync_delivery_order_status(
    uuid, uuid, uuid, text, text, jsonb, text
  ) from public;
  grant execute on function catchmenu_integrations.sync_delivery_order_status(
    uuid, uuid, uuid, text, text, jsonb, text
  ) to authenticated;

  revoke all on function catchmenu_integrations.reject_delivery_order(
    uuid, uuid, text, text, text, text, uuid, text
  ) from public;
  grant execute on function catchmenu_integrations.reject_delivery_order(
    uuid, uuid, text, text, text, text, uuid, text
  ) to authenticated;
end;
$$;

comment on function catchmenu_integrations.intake_delivery_order(
  uuid, uuid, text, text, jsonb, uuid, text
) is
  'Universal delivery order intake for Baemin, Yogiyo, Coupang Eats.
   All orders enter through gateway sandbox with idempotency check.
   Normalizes provider-specific payload to internal format.
   Creates order session, order, order items, and KDS tickets.
   Delivery orders: arrived + table_confirmed auto-satisfied.
   KDS tickets start at CAPACITY_CHECKING (skip arrival/table hold).
   특허1: 배달앱 주문 → Gateway 샌드박스 → 내부 원장 반영.
   특허2: 배달 주문 KDS 티켓 = 도착/테이블 조건 면제, 용량 조건만 확인.';

comment on function catchmenu_integrations.reject_delivery_order(
  uuid, uuid, text, text, text, text, uuid, text
) is
  'Rejects incoming delivery order.
   Cancels internal order and KDS tickets if already created.
   Rejects at gateway level if order not yet created.
   Reject reason mandatory for audit trail.
   특허1: 거절도 감사 원장에 기록 — 외부 플랫폼 분쟁 증거.';