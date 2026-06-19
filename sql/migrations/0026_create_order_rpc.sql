-- 0026_create_order_rpc.sql
-- Purpose: Order creation and confirmation RPCs.
--          create_order: creates order from confirmed session cart.
--          confirm_order: confirms order and triggers KDS ticket creation.
--          cancel_order: cancels order with reason and audit trail.
--          특허1: 주문 세션 → 주문 확정 → KDS 전달 경계.
-- Depends on: 0025_create_session_rpc.sql
-- Creates:
--   function catchmenu_pos.create_order(...)
--   function catchmenu_pos.confirm_order(...)
--   function catchmenu_pos.cancel_order(...)

create or replace function catchmenu_pos.create_order(
  p_tenant_id uuid,
  p_store_id uuid,
  p_session_id uuid,
  p_order_type text,
  p_order_channel text,
  p_items jsonb,
  p_memo text default null,
  p_special_requests text default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_pos, catchmenu_store,
                  catchmenu_ledger, catchmenu_audit,
                  catchmenu_common, catchmenu_hq
as $$
declare
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

  -- generate order number (daily sequential per store)
  select count(*) + 1
  into v_order_count
  from catchmenu_pos.orders
  where store_id = p_store_id
    and business_day = v_business_day;

  v_order_number := lpad(v_order_count::text, 4, '0');

  -- create order header
  insert into catchmenu_pos.orders (
    tenant_id, store_id, session_id, table_id,
    order_number, order_type, order_status,
    order_channel, guest_count, guest_locale,
    memo, special_requests,
    total_amount, discount_amount, final_amount,
    ordered_at, correlation_id,
    business_day, business_timezone
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
    v_business_day, v_timezone
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

  return jsonb_build_object(
    'success', true,
    'order_id', v_order_id,
    'order_number', v_order_number,
    'order_status', 'PENDING',
    'total_amount', v_total_amount,
    'final_amount', v_final_amount,
    'item_count', jsonb_array_length(p_items),
    'kitchen_zone_summary', v_kitchen_zone_summary
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


create or replace function catchmenu_pos.confirm_order(
  p_tenant_id uuid,
  p_store_id uuid,
  p_order_id uuid,
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
  v_order record;
  v_item record;
  v_ticket_id uuid;
  v_ticket_number text;
  v_ticket_count int := 0;
  v_ticket_ids jsonb := '[]'::jsonb;
  v_audit_id uuid;
begin
  -- order validation
  select id, order_status, session_id, table_id,
         order_number, total_amount, final_amount,
         order_channel, business_day, business_timezone
  into v_order
  from catchmenu_pos.orders
  where id = p_order_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
  for update;

  if v_order.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'order_not_found'
    );
  end if;

  if v_order.order_status not in ('PENDING') then
    return jsonb_build_object(
      'success', false,
      'error_key', 'order_not_confirmable',
      'current_status', v_order.order_status
    );
  end if;

  -- confirm order
  update catchmenu_pos.orders
  set
    order_status = 'CONFIRMED',
    confirmed_at = now(),
    updated_at = now()
  where id = p_order_id;

  -- update session status
  update catchmenu_pos.order_sessions
  set
    session_status = 'ORDER_CONFIRMED',
    order_confirmed_at = now(),
    updated_at = now()
  where id = v_order.session_id;

  -- create KDS tickets for each item that requires kitchen
  -- tickets start in HOLD state (특허2)
  for v_item in
    select id, menu_name_snapshot, quantity,
           kitchen_zone_snapshot, estimated_minutes_snapshot,
           is_kds_required_snapshot, unit_price_snapshot
    from catchmenu_pos.order_items
    where order_id = p_order_id
      and is_kds_required_snapshot = true
      and item_status = 'PENDING'
  loop
    v_ticket_count := v_ticket_count + 1;
    v_ticket_number := v_order.order_number || '-' ||
                       lpad(v_ticket_count::text, 2, '0');

    insert into catchmenu_kds.kds_tickets (
      tenant_id, store_id,
      order_id, order_item_id, session_id,
      ticket_number,
      kds_status, hold_reason,
      kitchen_zone, priority,
      menu_name_snapshot, quantity_snapshot,
      estimated_minutes_snapshot,
      conditions_met,
      first_hold_at,
      business_day, business_timezone
    ) values (
      p_tenant_id, p_store_id,
      p_order_id, v_item.id, v_order.session_id,
      v_ticket_number,
      -- 특허2: 모든 KDS 티켓은 HOLD 상태로 시작
      'HOLD', 'AWAITING_CONDITIONS',
      v_item.kitchen_zone_snapshot,
      5,
      v_item.menu_name_snapshot,
      v_item.quantity,
      v_item.estimated_minutes_snapshot,
      -- initial conditions: all false
      jsonb_build_object(
        'arrived', v_order.session_id is not null,
        'table_confirmed', v_order.table_id is not null,
        'payment_confirmed', false,
        'kds_capacity_ok', false,
        'menu_available', true,
        'peak_time_ok', true,
        'no_show_risk_ok', true
      ),
      now(),
      v_order.business_day, v_order.business_timezone
    )
    returning id into v_ticket_id;

    v_ticket_ids := v_ticket_ids || to_jsonb(v_ticket_id);

    -- KDS event
    insert into catchmenu_kds.kds_events (
      tenant_id, store_id,
      ticket_id, order_id,
      event_type, from_status, to_status,
      caused_by_type,
      conditions_at_event,
      event_payload, occurred_at
    ) values (
      p_tenant_id, p_store_id,
      v_ticket_id, p_order_id,
      'ticket_created', null, 'HOLD',
      'SYSTEM',
      jsonb_build_object(
        'payment_confirmed', false,
        'kds_capacity_ok', false
      ),
      jsonb_build_object(
        'ticket_number', v_ticket_number,
        'kitchen_zone', v_item.kitchen_zone_snapshot,
        'hold_reason', 'AWAITING_CONDITIONS'
      ),
      now()
    );
  end loop;

  -- order event
  insert into catchmenu_pos.order_events (
    tenant_id, store_id, order_id,
    event_type, from_status, to_status,
    caused_by_type, caused_by_id,
    event_payload, correlation_id, occurred_at
  ) values (
    p_tenant_id, p_store_id, p_order_id,
    'order_confirmed', 'PENDING', 'CONFIRMED',
    p_actor_type, p_actor_id,
    jsonb_build_object(
      'kds_tickets_created', v_ticket_count,
      'ticket_ids', v_ticket_ids,
      'all_tickets_in_hold', true
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
    'order', 'order_confirmed', 1,
    'order', p_order_id,
    'PENDING', 'CONFIRMED',
    p_actor_type, p_actor_id,
    jsonb_build_object(
      'kds_tickets_created', v_ticket_count,
      'all_in_hold', true,
      'payment_required', true
    ),
    v_order.session_id, p_order_id,
    p_correlation_id,
    v_order.business_day, v_order.business_timezone, now()
  );

  -- audit record
  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := 'order',
    p_audit_type := 'order_confirmed',
    p_audit_category := 'OPERATIONAL',
    p_actor_type := p_actor_type,
    p_actor_id := p_actor_id,
    p_subject_type := 'order',
    p_subject_id := p_order_id,
    p_decision := 'COMPLETED',
    p_decision_payload := jsonb_build_object(
      'order_number', v_order.order_number,
      'total_amount', v_order.total_amount,
      'kds_tickets_created', v_ticket_count,
      'all_tickets_in_hold', true
    ),
    p_before_state := jsonb_build_object('order_status', 'PENDING'),
    p_after_state := jsonb_build_object(
      'order_status', 'CONFIRMED',
      'kds_ticket_count', v_ticket_count
    ),
    p_order_id := p_order_id,
    p_session_id := v_order.session_id,
    p_correlation_id := p_correlation_id,
    p_business_day := v_order.business_day,
    p_business_timezone := v_order.business_timezone
  );

  return jsonb_build_object(
    'success', true,
    'order_id', p_order_id,
    'order_number', v_order.order_number,
    'order_status', 'CONFIRMED',
    'kds_tickets_created', v_ticket_count,
    'ticket_ids', v_ticket_ids,
    'all_tickets_in_hold', true,
    'next_step', 'PAYMENT_REQUIRED',
    'message_code', 'order_confirmed_payment_required',
    'audit_id', v_audit_id
  );
end;
$$;


create or replace function catchmenu_pos.cancel_order(
  p_tenant_id uuid,
  p_store_id uuid,
  p_order_id uuid,
  p_cancel_reason text,
  p_actor_type text default 'STAFF',
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
  v_order record;
  v_cancelled_tickets int;
  v_audit_id uuid;
begin
  if trim(coalesce(p_cancel_reason, '')) = '' then
    return jsonb_build_object(
      'success', false,
      'error_key', 'cancel_reason_required'
    );
  end if;

  select id, order_status, session_id,
         order_number, final_amount,
         business_day, business_timezone
  into v_order
  from catchmenu_pos.orders
  where id = p_order_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
  for update;

  if v_order.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'order_not_found'
    );
  end if;

  if v_order.order_status in (
    'COMPLETED', 'CANCELLED', 'REFUNDED'
  ) then
    return jsonb_build_object(
      'success', false,
      'error_key', 'order_already_terminal',
      'current_status', v_order.order_status
    );
  end if;

  -- cancel order
  update catchmenu_pos.orders
  set
    order_status = 'CANCELLED',
    cancelled_at = now(),
    updated_at = now()
  where id = p_order_id;

  -- cancel all HOLD/CAPACITY_CHECKING KDS tickets
  update catchmenu_kds.kds_tickets
  set
    kds_status = 'CANCELLED',
    cancelled_at = now(),
    updated_at = now()
  where order_id = p_order_id
    and kds_status in ('HOLD', 'CAPACITY_CHECKING', 'READY_TO_COMMIT');

  get diagnostics v_cancelled_tickets = row_count;

  -- cancel order items
  update catchmenu_pos.order_items
  set
    item_status = 'CANCELLED',
    updated_at = now()
  where order_id = p_order_id
    and item_status not in ('SERVED', 'CANCELLED');

  -- order event
  insert into catchmenu_pos.order_events (
    tenant_id, store_id, order_id,
    event_type, from_status, to_status,
    caused_by_type, caused_by_id,
    event_payload, correlation_id, occurred_at
  ) values (
    p_tenant_id, p_store_id, p_order_id,
    'order_cancelled',
    v_order.order_status, 'CANCELLED',
    p_actor_type, p_actor_id,
    jsonb_build_object(
      'cancel_reason', p_cancel_reason,
      'cancelled_kds_tickets', v_cancelled_tickets
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
    'order', 'order_cancelled', 1,
    'order', p_order_id,
    v_order.order_status, 'CANCELLED',
    p_actor_type, p_actor_id,
    jsonb_build_object(
      'cancel_reason', p_cancel_reason,
      'cancelled_kds_tickets', v_cancelled_tickets
    ),
    v_order.session_id, p_order_id,
    p_correlation_id,
    v_order.business_day, v_order.business_timezone, now()
  );

  -- audit record
  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := 'order',
    p_audit_type := 'order_cancelled',
    p_audit_category := 'OPERATIONAL',
    p_actor_type := p_actor_type,
    p_actor_id := p_actor_id,
    p_subject_type := 'order',
    p_subject_id := p_order_id,
    p_decision := 'CANCELLED',
    p_decision_reason := p_cancel_reason,
    p_decision_payload := jsonb_build_object(
      'order_number', v_order.order_number,
      'cancelled_kds_tickets', v_cancelled_tickets
    ),
    p_before_state := jsonb_build_object(
      'order_status', v_order.order_status
    ),
    p_after_state := jsonb_build_object(
      'order_status', 'CANCELLED'
    ),
    p_order_id := p_order_id,
    p_session_id := v_order.session_id,
    p_correlation_id := p_correlation_id,
    p_business_day := v_order.business_day,
    p_business_timezone := v_order.business_timezone
  );

  return jsonb_build_object(
    'success', true,
    'order_id', p_order_id,
    'order_number', v_order.order_number,
    'order_status', 'CANCELLED',
    'cancelled_kds_tickets', v_cancelled_tickets,
    'cancel_reason', p_cancel_reason,
    'audit_id', v_audit_id
  );
end;
$$;

-- grants
revoke all on function catchmenu_pos.create_order(
  uuid, uuid, uuid, text, text, jsonb, text, text, text
) from public;
grant execute on function catchmenu_pos.create_order(
  uuid, uuid, uuid, text, text, jsonb, text, text, text
) to authenticated;

revoke all on function catchmenu_pos.confirm_order(
  uuid, uuid, uuid, text, uuid, text
) from public;
grant execute on function catchmenu_pos.confirm_order(
  uuid, uuid, uuid, text, uuid, text
) to authenticated;

revoke all on function catchmenu_pos.cancel_order(
  uuid, uuid, uuid, text, text, uuid, text
) from public;
grant execute on function catchmenu_pos.cancel_order(
  uuid, uuid, uuid, text, text, uuid, text
) to authenticated;

comment on function catchmenu_pos.create_order(
  uuid, uuid, uuid, text, text, jsonb, text, text, text
) is
  'Creates order from session cart.
   Validates all menu items availability before creating.
   Captures price snapshots at order time — never recalculated.
   Captures allergen display evidence per item.
   특허1: 주문 세션과 주문의 분리 — 세션은 주문 전에 독립 존재.';

comment on function catchmenu_pos.confirm_order(
  uuid, uuid, uuid, text, uuid, text
) is
  'Confirms order and creates KDS tickets in HOLD state.
   All KDS tickets start HOLD — never immediately sent to kitchen.
   payment_confirmed condition starts false.
   KDS tickets only commit after all conditions_met are true.
   특허2: 주문 확정 → KDS 티켓 생성 (HOLD) → 조건 충족 후 조리 큐 투입.
   특허1: 결제 확인 없이 KDS 릴리즈 금지.';

comment on function catchmenu_pos.cancel_order(
  uuid, uuid, uuid, text, text, uuid, text
) is
  'Cancels order and all cancellable KDS tickets.
   Tickets in COOKING or READY state are not cancelled — staff must handle.
   Cancel reason is mandatory and recorded in audit ledger.
   특허4: 모든 취소 행위는 감사 원장에 기록.';