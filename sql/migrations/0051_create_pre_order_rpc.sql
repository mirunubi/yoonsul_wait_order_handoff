-- 0051_create_pre_order_rpc.sql
-- Purpose: Pre-order management RPCs.
--          create_pre_order: creates order before customer arrives.
--          confirm_pre_order_arrival: confirms arrival and triggers Late Binding.
--          cancel_pre_order: cancels pre-order before arrival.
--          get_pre_order_status: returns pre-order and KDS state.
--          특허2 core: 사전주문 → HOLD → 조건 충족 시 KDS 투입.
-- Depends on: 0050_create_waiting_queue_rpc.sql
-- Creates:
--   function catchmenu_pos.create_pre_order(...)
--   function catchmenu_pos.confirm_pre_order_arrival(...)
--   function catchmenu_pos.cancel_pre_order(...)
--   function catchmenu_pos.get_pre_order_status(...)

create or replace function catchmenu_pos.create_pre_order(
  p_tenant_id uuid,
  p_store_id uuid,
  p_session_id uuid,
  p_items jsonb,
  p_memo text default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_pos, catchmenu_kds,
                  catchmenu_ledger, catchmenu_common,
                  catchmenu_hq
as $$
declare
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

  -- generate order number
  select count(*) + 1
  into v_order_count
  from catchmenu_pos.orders
  where store_id = p_store_id
    and business_day = v_business_day;

  v_order_number := 'P-' || lpad(
    v_order_count::text, 4, '0'
  );

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
    business_day, business_timezone
  ) values (
    p_tenant_id, p_store_id, p_session_id,
    v_order_number, 'DINE_IN',
    'PENDING', 'TABLE_QR',
    v_session.guest_count,
    v_session.guest_locale,
    p_memo, now(),
    0, 0, 0,
    p_correlation_id,
    v_business_day, v_timezone
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

  return jsonb_build_object(
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

exception
  when others then
    return jsonb_build_object(
      'success', false,
      'error_key', split_part(sqlerrm, ':', 1),
      'error_detail', split_part(sqlerrm, ':', 2)
    );
end;
$$;


create or replace function catchmenu_pos.confirm_pre_order_arrival(
  p_tenant_id uuid,
  p_store_id uuid,
  p_session_id uuid,
  p_table_id uuid,
  p_actor_type text default 'STAFF',
  p_actor_id uuid default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_pos, catchmenu_kds,
                  catchmenu_ledger, catchmenu_common
as $$
declare
  v_session record;
  v_bind_result jsonb;
  v_tickets_updated int;
begin
  -- validate session
  select id, session_type, session_status,
         order_id, pre_order_expires_at,
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

  if v_session.session_type <> 'PRE_ORDER' then
    return jsonb_build_object(
      'success', false,
      'error_key', 'not_a_pre_order_session',
      'session_type', v_session.session_type
    );
  end if;

  -- check expiry
  if v_session.pre_order_expires_at < now() then
    return jsonb_build_object(
      'success', false,
      'error_key', 'pre_order_expired',
      'expired_at', v_session.pre_order_expires_at
    );
  end if;

  -- Late Binding: bind table to session
  -- 특허1: 도착 확인 시 테이블 후매칭 실행
  v_bind_result := catchmenu_pos.bind_table_to_session(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_session_id := p_session_id,
    p_table_id := p_table_id,
    p_actor_type := p_actor_type,
    p_actor_id := p_actor_id,
    p_correlation_id := p_correlation_id
  );

  if not (v_bind_result->>'success')::boolean then
    return v_bind_result;
  end if;

  -- update KDS tickets: arrived + table_confirmed = true
  -- 특허2: 도착 확인 → arrived + table_confirmed 조건 충족
  update catchmenu_kds.kds_tickets
  set
    conditions_met = conditions_met
      || jsonb_build_object(
        'arrived', true,
        'table_confirmed', true
      ),
    updated_at = now()
  where order_id = v_session.order_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
    and kds_status in ('HOLD', 'CAPACITY_CHECKING');

  get diagnostics v_tickets_updated = row_count;

  -- KDS events for condition update
  insert into catchmenu_kds.kds_events (
    tenant_id, store_id, ticket_id, order_id,
    event_type, caused_by_type, caused_by_id,
    conditions_at_event,
    event_payload, correlation_id, occurred_at
  )
  select
    p_tenant_id, p_store_id,
    kt.id, v_session.order_id,
    'condition_updated',
    p_actor_type, p_actor_id,
    kt.conditions_met,
    jsonb_build_object(
      'arrived', true,
      'table_confirmed', true,
      'table_id', p_table_id,
      'late_binding_completed', true
    ),
    p_correlation_id, now()
  from catchmenu_kds.kds_tickets kt
  where kt.order_id = v_session.order_id
    and kt.store_id = p_store_id
    and kt.kds_status in ('HOLD', 'CAPACITY_CHECKING');

  -- update order with table
  update catchmenu_pos.orders
  set
    table_id = p_table_id,
    updated_at = now()
  where id = v_session.order_id;

  return jsonb_build_object(
    'success', true,
    'session_id', p_session_id,
    'order_id', v_session.order_id,
    'table_id', p_table_id,
    'late_binding_completed', true,
    'kds_tickets_updated', v_tickets_updated,
    'conditions_updated', jsonb_build_object(
      'arrived', true,
      'table_confirmed', true
    ),
    'next_step', 'PAYMENT_REQUIRED_FOR_KDS_RELEASE',
    'message_code', 'pre_order_arrival_confirmed'
  );
end;
$$;


create or replace function catchmenu_pos.cancel_pre_order(
  p_tenant_id uuid,
  p_store_id uuid,
  p_session_id uuid,
  p_cancel_reason text,
  p_actor_type text default 'CUSTOMER',
  p_actor_id uuid default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_pos, catchmenu_kds,
                  catchmenu_ledger, catchmenu_audit,
                  catchmenu_common
as $$
declare
  v_session record;
  v_cancelled_tickets int;
  v_audit_id uuid;
begin
  if trim(coalesce(p_cancel_reason, '')) = '' then
    return jsonb_build_object(
      'success', false,
      'error_key', 'cancel_reason_required'
    );
  end if;

  select id, session_type, session_status,
         order_id, wait_number,
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

  if v_session.session_type <> 'PRE_ORDER' then
    return jsonb_build_object(
      'success', false,
      'error_key', 'not_a_pre_order_session'
    );
  end if;

  if v_session.session_status not in (
    'WAITING', 'ARRIVAL_PENDING', 'ORDER_CONFIRMED'
  ) then
    return jsonb_build_object(
      'success', false,
      'error_key', 'session_not_cancellable',
      'current_status', v_session.session_status
    );
  end if;

  -- cancel session
  update catchmenu_pos.order_sessions
  set
    session_status = 'CANCELLED',
    cancelled_at = now(),
    updated_at = now()
  where id = p_session_id;

  -- cancel order if exists
  if v_session.order_id is not null then
    update catchmenu_pos.orders
    set
      order_status = 'CANCELLED',
      cancelled_at = now(),
      updated_at = now()
    where id = v_session.order_id;
  end if;

  -- cancel all KDS tickets
  update catchmenu_kds.kds_tickets
  set
    kds_status = 'CANCELLED',
    hold_reason = 'PRE_ORDER_CANCELLED',
    cancelled_at = now(),
    updated_at = now()
  where order_id = v_session.order_id
    and store_id = p_store_id
    and kds_status not in (
      'COMPLETED', 'CANCELLED', 'SERVED'
    );

  get diagnostics v_cancelled_tickets = row_count;

  -- session event
  insert into catchmenu_pos.session_events (
    tenant_id, store_id, session_id,
    event_type, from_status, to_status,
    caused_by_type, caused_by_id,
    event_payload, correlation_id, occurred_at
  ) values (
    p_tenant_id, p_store_id, p_session_id,
    'session_cancelled',
    v_session.session_status, 'CANCELLED',
    p_actor_type, p_actor_id,
    jsonb_build_object(
      'cancel_reason', p_cancel_reason,
      'order_id', v_session.order_id,
      'cancelled_tickets', v_cancelled_tickets
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
    event_payload, session_id, order_id,
    correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'order', 'pre_order_cancelled', 1,
    'order_session', p_session_id,
    v_session.session_status, 'CANCELLED',
    p_actor_type, p_actor_id,
    jsonb_build_object(
      'cancel_reason', p_cancel_reason,
      'cancelled_tickets', v_cancelled_tickets
    ),
    p_session_id, v_session.order_id,
    p_correlation_id,
    v_session.business_day, v_session.business_timezone,
    now()
  );

  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := 'order',
    p_audit_type := 'pre_order_cancelled',
    p_audit_category := 'OPERATIONAL',
    p_actor_type := p_actor_type,
    p_actor_id := p_actor_id,
    p_subject_type := 'order_session',
    p_subject_id := p_session_id,
    p_decision := 'CANCELLED',
    p_decision_reason := p_cancel_reason,
    p_decision_payload := jsonb_build_object(
      'wait_number', v_session.wait_number,
      'order_id', v_session.order_id,
      'cancelled_tickets', v_cancelled_tickets
    ),
    p_session_id := p_session_id,
    p_order_id := v_session.order_id,
    p_correlation_id := p_correlation_id,
    p_business_day := v_session.business_day,
    p_business_timezone := v_session.business_timezone
  );

  return jsonb_build_object(
    'success', true,
    'session_id', p_session_id,
    'order_id', v_session.order_id,
    'session_status', 'CANCELLED',
    'cancelled_tickets', v_cancelled_tickets,
    'cancel_reason', p_cancel_reason,
    'audit_id', v_audit_id,
    'message_code', 'pre_order_cancelled'
  );
end;
$$;


create or replace function catchmenu_pos.get_pre_order_status(
  p_tenant_id uuid,
  p_store_id uuid,
  p_session_id uuid
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_pos, catchmenu_kds,
                  catchmenu_common
as $$
declare
  v_session record;
  v_order record;
  v_tickets jsonb;
  v_conditions_summary jsonb;
begin
  select id, session_type, session_status,
         wait_number, order_id,
         table_id, arrived_at, seated_at,
         pre_order_created_at, pre_order_expires_at,
         payment_started_at, payment_completed_at,
         arrival_reliability_score
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

  -- order info
  if v_session.order_id is not null then
    select id, order_number, order_status,
           total_amount, final_amount
    into v_order
    from catchmenu_pos.orders
    where id = v_session.order_id;
  end if;

  -- KDS ticket summary
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'ticket_id', kt.id,
        'ticket_number', kt.ticket_number,
        'kds_status', kt.kds_status,
        'kitchen_zone', kt.kitchen_zone,
        'menu_name', kt.menu_name_snapshot,
        'conditions_met', kt.conditions_met,
        'committed_at', kt.committed_at,
        'cooking_started_at', kt.cooking_started_at,
        'ready_at', kt.ready_at
      )
      order by kt.ticket_number
    ),
    '[]'::jsonb
  )
  into v_tickets
  from catchmenu_kds.kds_tickets kt
  where kt.order_id = v_session.order_id
    and kt.store_id = p_store_id;

  -- conditions summary across tickets
  select jsonb_build_object(
    'arrived', bool_and(
      (conditions_met->>'arrived')::boolean
    ),
    'table_confirmed', bool_and(
      (conditions_met->>'table_confirmed')::boolean
    ),
    'payment_confirmed', bool_and(
      (conditions_met->>'payment_confirmed')::boolean
    ),
    'kds_capacity_ok', bool_and(
      (conditions_met->>'kds_capacity_ok')::boolean
    ),
    'all_conditions_met', bool_and(
      (conditions_met->>'arrived')::boolean
      and (conditions_met->>'table_confirmed')::boolean
      and (conditions_met->>'payment_confirmed')::boolean
      and (conditions_met->>'kds_capacity_ok')::boolean
      and coalesce(
        (conditions_met->>'menu_available')::boolean,
        true
      )
    )
  )
  into v_conditions_summary
  from catchmenu_kds.kds_tickets
  where order_id = v_session.order_id
    and store_id = p_store_id
    and kds_status not in ('CANCELLED', 'COMPLETED');

  return jsonb_build_object(
    'success', true,
    'session', jsonb_build_object(
      'id', v_session.id,
      'session_type', v_session.session_type,
      'session_status', v_session.session_status,
      'wait_number', v_session.wait_number,
      'table_id', v_session.table_id,
      'arrived_at', v_session.arrived_at,
      'seated_at', v_session.seated_at,
      'pre_order_created_at',
        v_session.pre_order_created_at,
      'pre_order_expires_at',
        v_session.pre_order_expires_at,
      'is_expired', v_session.pre_order_expires_at
        is not null
        and v_session.pre_order_expires_at < now(),
      'arrival_reliability_score',
        v_session.arrival_reliability_score
    ),
    'order', case
      when v_order.id is not null
      then jsonb_build_object(
        'id', v_order.id,
        'order_number', v_order.order_number,
        'order_status', v_order.order_status,
        'total_amount', v_order.total_amount,
        'final_amount', v_order.final_amount
      )
      else null
    end,
    'kds_tickets', v_tickets,
    'ticket_count', jsonb_array_length(v_tickets),
    'conditions_summary', v_conditions_summary,
    'message_code', 'pre_order_status_loaded'
  );
end;
$$;

-- grants
do $$
begin
  revoke all on function catchmenu_pos.create_pre_order(
    uuid, uuid, uuid, jsonb, text, text
  ) from public;
  grant execute on function catchmenu_pos.create_pre_order(
    uuid, uuid, uuid, jsonb, text, text
  ) to authenticated;

  revoke all on function catchmenu_pos.confirm_pre_order_arrival(
    uuid, uuid, uuid, uuid, text, uuid, text
  ) from public;
  grant execute on function catchmenu_pos.confirm_pre_order_arrival(
    uuid, uuid, uuid, uuid, text, uuid, text
  ) to authenticated;

  revoke all on function catchmenu_pos.cancel_pre_order(
    uuid, uuid, uuid, text, text, uuid, text
  ) from public;
  grant execute on function catchmenu_pos.cancel_pre_order(
    uuid, uuid, uuid, text, text, uuid, text
  ) to authenticated;

  revoke all on function catchmenu_pos.get_pre_order_status(
    uuid, uuid, uuid
  ) from public;
  grant execute on function catchmenu_pos.get_pre_order_status(
    uuid, uuid, uuid
  ) to authenticated;
end;
$$;

comment on function catchmenu_pos.create_pre_order(
  uuid, uuid, uuid, jsonb, text, text
) is
  'Creates pre-order for waiting customer before arrival.
   Validates arrival_reliability_score against threshold.
   Creates order and KDS tickets — all tickets in HOLD.
   All 7 conditions start false.
   Sets pre_order_expires_at from store settings.
   특허2 핵심:
   사전주문 → 즉시 KDS 티켓 생성 (HOLD 상태)
   → arrived + table_confirmed + payment_confirmed 모두 충족 후 조리 큐 투입.
   노쇼 이력이 높은 고객은 사전주문 차단.';

comment on function catchmenu_pos.confirm_pre_order_arrival(
  uuid, uuid, uuid, uuid, text, uuid, text
) is
  'Confirms pre-order customer arrival and completes Late Binding.
   1. Validates pre-order not expired.
   2. Calls bind_table_to_session (Late Binding).
   3. Updates KDS conditions: arrived = true, table_confirmed = true.
   4. KDS tickets move from HOLD → CAPACITY_CHECKING.
   Next step: payment → payment_confirmed = true → all conditions met
   → COMMITTED.
   특허1: 도착 확인 = Late Binding 완료 시점.
   특허2: 도착 확인 → KDS 조건 2개 충족 → 결제 대기.';

comment on function catchmenu_pos.cancel_pre_order(
  uuid, uuid, uuid, text, text, uuid, text
) is
  'Cancels pre-order before cooking starts.
   Cancels session, order, and all HOLD KDS tickets.
   Requires cancel reason for audit trail.
   특허2: 사전주문 취소 → HOLD 티켓 일괄 취소.';