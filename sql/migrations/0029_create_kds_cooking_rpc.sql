-- 0029_create_kds_cooking_rpc.sql
-- Purpose: KDS cooking lifecycle RPCs.
--          start_cooking: READY_TO_COMMIT → COOKING.
--          complete_cooking: COOKING → READY.
--          serve_ticket: READY → SERVED.
--          complete_order_kds: all tickets done → order COMPLETED.
--          특허2: 조리 실행 큐 투입 후 완료까지 상태 전이 추적.
-- Depends on: 0028_create_kds_capacity_commit_rpc.sql
-- Creates:
--   function catchmenu_kds.start_cooking(...)
--   function catchmenu_kds.complete_cooking(...)
--   function catchmenu_kds.serve_ticket(...)
--   function catchmenu_kds.complete_order_kds(...)

create or replace function catchmenu_kds.start_cooking(
  p_tenant_id uuid,
  p_store_id uuid,
  p_ticket_id uuid,
  p_actor_type text default 'STAFF',
  p_actor_id uuid default null,
  p_device_id uuid default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_kds, catchmenu_ledger,
                  catchmenu_audit, catchmenu_common
as $$
declare
  v_ticket record;
  v_audit_id uuid;
begin
  select
    id, order_id, session_id, kds_status,
    kitchen_zone, ticket_number,
    menu_name_snapshot, quantity_snapshot,
    estimated_minutes_snapshot,
    payment_ledger_id,
    conditions_met,
    business_day, business_timezone
  into v_ticket
  from catchmenu_kds.kds_tickets
  where id = p_ticket_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
  for update;

  if v_ticket.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'ticket_not_found'
    );
  end if;

  if v_ticket.kds_status <> 'READY_TO_COMMIT' then
    return jsonb_build_object(
      'success', false,
      'error_key', 'ticket_not_ready_to_commit',
      'current_status', v_ticket.kds_status
    );
  end if;

  -- verify payment_ledger kds_release_authorized
  if v_ticket.payment_ledger_id is not null then
    if not exists (
      select 1
      from catchmenu_payment.payment_ledger
      where id = v_ticket.payment_ledger_id
        and kds_release_authorized = true
    ) then
      return jsonb_build_object(
        'success', false,
        'error_key', 'kds_release_not_authorized',
        'message', 'payment_ledger.kds_release_authorized must be true'
      );
    end if;
  end if;

  -- READY_TO_COMMIT → COOKING
  update catchmenu_kds.kds_tickets
  set
    kds_status = 'COOKING',
    cooking_started_at = now(),
    updated_at = now()
  where id = p_ticket_id;

  -- update order item status
  update catchmenu_pos.order_items
  set
    item_status = 'COOKING',
    updated_at = now()
  where id = v_ticket.order_item_id;

  -- KDS event
  insert into catchmenu_kds.kds_events (
    tenant_id, store_id, ticket_id, order_id,
    event_type, from_status, to_status,
    caused_by_type, caused_by_id,
    caused_by_device_id,
    conditions_at_event,
    event_payload, correlation_id, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    p_ticket_id, v_ticket.order_id,
    'cooking_started',
    'READY_TO_COMMIT', 'COOKING',
    p_actor_type, p_actor_id,
    p_device_id,
    v_ticket.conditions_met,
    jsonb_build_object(
      'ticket_number', v_ticket.ticket_number,
      'kitchen_zone', v_ticket.kitchen_zone,
      'menu_name', v_ticket.menu_name_snapshot,
      'estimated_minutes', v_ticket.estimated_minutes_snapshot
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
    caused_by_device_id,
    event_payload,
    order_id, kds_ticket_id,
    correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'kds', 'kds_cooking_started', 1,
    'kds_ticket', p_ticket_id,
    'READY_TO_COMMIT', 'COOKING',
    p_actor_type, p_actor_id,
    p_device_id,
    jsonb_build_object(
      'kitchen_zone', v_ticket.kitchen_zone,
      'ticket_number', v_ticket.ticket_number
    ),
    v_ticket.order_id, p_ticket_id,
    p_correlation_id,
    v_ticket.business_day, v_ticket.business_timezone, now()
  );

  -- audit
  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := 'kds',
    p_audit_type := 'kds_cooking_started',
    p_audit_category := 'OPERATIONAL',
    p_actor_type := p_actor_type,
    p_actor_id := p_actor_id,
    p_subject_type := 'kds_ticket',
    p_subject_id := p_ticket_id,
    p_decision := 'COMPLETED',
    p_decision_payload := jsonb_build_object(
      'ticket_number', v_ticket.ticket_number,
      'kitchen_zone', v_ticket.kitchen_zone,
      'cooking_started_at', now()
    ),
    p_before_state := jsonb_build_object(
      'kds_status', 'READY_TO_COMMIT'
    ),
    p_after_state := jsonb_build_object(
      'kds_status', 'COOKING'
    ),
    p_order_id := v_ticket.order_id,
    p_kds_ticket_id := p_ticket_id,
    p_correlation_id := p_correlation_id,
    p_business_day := v_ticket.business_day,
    p_business_timezone := v_ticket.business_timezone
  );

  -- update order status to COOKING if not already
  update catchmenu_pos.orders
  set
    order_status = 'COOKING',
    updated_at = now()
  where id = v_ticket.order_id
    and order_status = 'CONFIRMED';

  return jsonb_build_object(
    'success', true,
    'ticket_id', p_ticket_id,
    'ticket_number', v_ticket.ticket_number,
    'kds_status', 'COOKING',
    'kitchen_zone', v_ticket.kitchen_zone,
    'cooking_started_at', now(),
    'estimated_minutes', v_ticket.estimated_minutes_snapshot,
    'audit_id', v_audit_id
  );
end;
$$;


create or replace function catchmenu_kds.complete_cooking(
  p_tenant_id uuid,
  p_store_id uuid,
  p_ticket_id uuid,
  p_actor_type text default 'STAFF',
  p_actor_id uuid default null,
  p_device_id uuid default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_kds, catchmenu_pos,
                  catchmenu_ledger, catchmenu_audit,
                  catchmenu_common
as $$
declare
  v_ticket record;
  v_all_ready boolean;
  v_audit_id uuid;
begin
  select
    id, order_id, session_id, kds_status,
    kitchen_zone, ticket_number,
    menu_name_snapshot, quantity_snapshot,
    business_day, business_timezone
  into v_ticket
  from catchmenu_kds.kds_tickets
  where id = p_ticket_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
  for update;

  if v_ticket.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'ticket_not_found'
    );
  end if;

  if v_ticket.kds_status <> 'COOKING' then
    return jsonb_build_object(
      'success', false,
      'error_key', 'ticket_not_cooking',
      'current_status', v_ticket.kds_status
    );
  end if;

  -- COOKING → READY
  update catchmenu_kds.kds_tickets
  set
    kds_status = 'READY',
    ready_at = now(),
    updated_at = now()
  where id = p_ticket_id;

  -- update order item
  update catchmenu_pos.order_items
  set
    item_status = 'READY',
    updated_at = now()
  where id = (
    select order_item_id
    from catchmenu_kds.kds_tickets
    where id = p_ticket_id
  );

  -- check if all tickets for this order are READY/SERVED/COMPLETED
  select not exists (
    select 1
    from catchmenu_kds.kds_tickets
    where order_id = v_ticket.order_id
      and kds_status not in (
        'READY', 'SERVED', 'COMPLETED', 'CANCELLED'
      )
      and id <> p_ticket_id
  )
  into v_all_ready;

  -- if all ready, update order status
  if v_all_ready then
    update catchmenu_pos.orders
    set
      order_status = 'READY',
      updated_at = now()
    where id = v_ticket.order_id
      and order_status in ('CONFIRMED', 'COOKING');
  end if;

  -- KDS event
  insert into catchmenu_kds.kds_events (
    tenant_id, store_id, ticket_id, order_id,
    event_type, from_status, to_status,
    caused_by_type, caused_by_id,
    caused_by_device_id,
    event_payload, correlation_id, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    p_ticket_id, v_ticket.order_id,
    'cooking_completed',
    'COOKING', 'READY',
    p_actor_type, p_actor_id,
    p_device_id,
    jsonb_build_object(
      'ticket_number', v_ticket.ticket_number,
      'kitchen_zone', v_ticket.kitchen_zone,
      'all_tickets_ready', v_all_ready
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
    caused_by_device_id,
    event_payload,
    order_id, kds_ticket_id,
    correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'kds', 'kds_ready', 1,
    'kds_ticket', p_ticket_id,
    'COOKING', 'READY',
    p_actor_type, p_actor_id,
    p_device_id,
    jsonb_build_object(
      'kitchen_zone', v_ticket.kitchen_zone,
      'all_tickets_ready', v_all_ready
    ),
    v_ticket.order_id, p_ticket_id,
    p_correlation_id,
    v_ticket.business_day, v_ticket.business_timezone, now()
  );

  -- audit
  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := 'kds',
    p_audit_type := 'kds_cooking_completed',
    p_audit_category := 'OPERATIONAL',
    p_actor_type := p_actor_type,
    p_actor_id := p_actor_id,
    p_subject_type := 'kds_ticket',
    p_subject_id := p_ticket_id,
    p_decision := 'COMPLETED',
    p_decision_payload := jsonb_build_object(
      'ticket_number', v_ticket.ticket_number,
      'kitchen_zone', v_ticket.kitchen_zone,
      'all_tickets_ready', v_all_ready,
      'ready_at', now()
    ),
    p_before_state := jsonb_build_object(
      'kds_status', 'COOKING'
    ),
    p_after_state := jsonb_build_object(
      'kds_status', 'READY',
      'all_tickets_ready', v_all_ready
    ),
    p_order_id := v_ticket.order_id,
    p_kds_ticket_id := p_ticket_id,
    p_correlation_id := p_correlation_id,
    p_business_day := v_ticket.business_day,
    p_business_timezone := v_ticket.business_timezone
  );

  return jsonb_build_object(
    'success', true,
    'ticket_id', p_ticket_id,
    'ticket_number', v_ticket.ticket_number,
    'kds_status', 'READY',
    'kitchen_zone', v_ticket.kitchen_zone,
    'ready_at', now(),
    'all_tickets_ready', v_all_ready,
    'order_status', case when v_all_ready then 'READY' else 'COOKING' end,
    'audit_id', v_audit_id
  );
end;
$$;


create or replace function catchmenu_kds.serve_ticket(
  p_tenant_id uuid,
  p_store_id uuid,
  p_ticket_id uuid,
  p_actor_type text default 'STAFF',
  p_actor_id uuid default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_kds, catchmenu_pos,
                  catchmenu_ledger, catchmenu_common
as $$
declare
  v_ticket record;
begin
  select id, order_id, kds_status,
         ticket_number, kitchen_zone,
         business_day, business_timezone
  into v_ticket
  from catchmenu_kds.kds_tickets
  where id = p_ticket_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
  for update;

  if v_ticket.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'ticket_not_found'
    );
  end if;

  if v_ticket.kds_status <> 'READY' then
    return jsonb_build_object(
      'success', false,
      'error_key', 'ticket_not_ready',
      'current_status', v_ticket.kds_status
    );
  end if;

  -- READY → SERVED
  update catchmenu_kds.kds_tickets
  set
    kds_status = 'SERVED',
    served_at = now(),
    updated_at = now()
  where id = p_ticket_id;

  -- update order item
  update catchmenu_pos.order_items
  set
    item_status = 'SERVED',
    updated_at = now()
  where id = (
    select order_item_id
    from catchmenu_kds.kds_tickets
    where id = p_ticket_id
  );

  -- KDS event
  insert into catchmenu_kds.kds_events (
    tenant_id, store_id, ticket_id, order_id,
    event_type, from_status, to_status,
    caused_by_type, caused_by_id,
    event_payload, correlation_id, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    p_ticket_id, v_ticket.order_id,
    'served',
    'READY', 'SERVED',
    p_actor_type, p_actor_id,
    jsonb_build_object(
      'ticket_number', v_ticket.ticket_number,
      'kitchen_zone', v_ticket.kitchen_zone,
      'served_at', now()
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
    order_id, kds_ticket_id,
    correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'kds', 'kds_served', 1,
    'kds_ticket', p_ticket_id,
    'READY', 'SERVED',
    p_actor_type, p_actor_id,
    jsonb_build_object(
      'ticket_number', v_ticket.ticket_number,
      'kitchen_zone', v_ticket.kitchen_zone
    ),
    v_ticket.order_id, p_ticket_id,
    p_correlation_id,
    v_ticket.business_day, v_ticket.business_timezone, now()
  );

  return jsonb_build_object(
    'success', true,
    'ticket_id', p_ticket_id,
    'ticket_number', v_ticket.ticket_number,
    'kds_status', 'SERVED',
    'served_at', now()
  );
end;
$$;


create or replace function catchmenu_kds.complete_order_kds(
  p_tenant_id uuid,
  p_store_id uuid,
  p_order_id uuid,
  p_actor_type text default 'SYSTEM',
  p_actor_id uuid default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_kds, catchmenu_pos,
                  catchmenu_ledger, catchmenu_audit,
                  catchmenu_common
as $$
declare
  v_order record;
  v_incomplete_count int;
  v_audit_id uuid;
begin
  select id, order_status, session_id,
         order_number, business_day, business_timezone
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

  -- check all KDS tickets completed/served/cancelled
  select count(*)
  into v_incomplete_count
  from catchmenu_kds.kds_tickets
  where order_id = p_order_id
    and kds_status not in (
      'COMPLETED', 'SERVED', 'CANCELLED', 'READY'
    );

  if v_incomplete_count > 0 then
    return jsonb_build_object(
      'success', false,
      'error_key', 'tickets_still_active',
      'incomplete_count', v_incomplete_count
    );
  end if;

  -- mark all SERVED/READY tickets as COMPLETED
  update catchmenu_kds.kds_tickets
  set
    kds_status = 'COMPLETED',
    completed_at = now(),
    updated_at = now()
  where order_id = p_order_id
    and kds_status in ('SERVED', 'READY');

  -- complete order
  update catchmenu_pos.orders
  set
    order_status = 'COMPLETED',
    completed_at = now(),
    updated_at = now()
  where id = p_order_id;

  -- complete session
  update catchmenu_pos.order_sessions
  set
    session_status = 'COMPLETED',
    completed_at = now(),
    updated_at = now()
  where id = v_order.session_id
    and session_status not in ('COMPLETED', 'CANCELLED');

  -- order event
  insert into catchmenu_pos.order_events (
    tenant_id, store_id, order_id,
    event_type, from_status, to_status,
    caused_by_type, caused_by_id,
    event_payload, correlation_id, occurred_at
  ) values (
    p_tenant_id, p_store_id, p_order_id,
    'order_completed',
    v_order.order_status, 'COMPLETED',
    p_actor_type, p_actor_id,
    jsonb_build_object(
      'order_number', v_order.order_number,
      'completed_at', now()
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
    'order', 'order_completed', 1,
    'order', p_order_id,
    v_order.order_status, 'COMPLETED',
    p_actor_type, p_actor_id,
    jsonb_build_object(
      'order_number', v_order.order_number,
      'completed_at', now()
    ),
    v_order.session_id, p_order_id,
    p_correlation_id,
    v_order.business_day, v_order.business_timezone, now()
  );

  -- audit
  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := 'order',
    p_audit_type := 'order_completed',
    p_audit_category := 'OPERATIONAL',
    p_actor_type := p_actor_type,
    p_actor_id := p_actor_id,
    p_subject_type := 'order',
    p_subject_id := p_order_id,
    p_decision := 'COMPLETED',
    p_decision_payload := jsonb_build_object(
      'order_number', v_order.order_number,
      'completed_at', now()
    ),
    p_before_state := jsonb_build_object(
      'order_status', v_order.order_status
    ),
    p_after_state := jsonb_build_object(
      'order_status', 'COMPLETED'
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
    'order_status', 'COMPLETED',
    'session_status', 'COMPLETED',
    'completed_at', now(),
    'audit_id', v_audit_id
  );
end;
$$;

-- grants
do $$
begin
  revoke all on function catchmenu_kds.start_cooking(
    uuid, uuid, uuid, text, uuid, uuid, text
  ) from public;
  grant execute on function catchmenu_kds.start_cooking(
    uuid, uuid, uuid, text, uuid, uuid, text
  ) to authenticated;

  revoke all on function catchmenu_kds.complete_cooking(
    uuid, uuid, uuid, text, uuid, uuid, text
  ) from public;
  grant execute on function catchmenu_kds.complete_cooking(
    uuid, uuid, uuid, text, uuid, uuid, text
  ) to authenticated;

  revoke all on function catchmenu_kds.serve_ticket(
    uuid, uuid, uuid, text, uuid, text
  ) from public;
  grant execute on function catchmenu_kds.serve_ticket(
    uuid, uuid, uuid, text, uuid, text
  ) to authenticated;

  revoke all on function catchmenu_kds.complete_order_kds(
    uuid, uuid, uuid, text, uuid, text
  ) from public;
  grant execute on function catchmenu_kds.complete_order_kds(
    uuid, uuid, uuid, text, uuid, text
  ) to authenticated;
end;
$$;

comment on function catchmenu_kds.start_cooking(
  uuid, uuid, uuid, text, uuid, uuid, text
) is
  'Transitions KDS ticket READY_TO_COMMIT → COOKING.
   Verifies payment_ledger.kds_release_authorized = true before allowing.
   Updates order_item status to COOKING.
   Updates order status to COOKING if first ticket to start.
   특허1: KDS 릴리즈 권한 재확인 — 릴리즈 직전 최종 검증.
   특허2: 조리 시작 타임스탬프 → KPI 데이터.';

comment on function catchmenu_kds.complete_cooking(
  uuid, uuid, uuid, text, uuid, uuid, text
) is
  'Transitions KDS ticket COOKING → READY.
   Checks if all order tickets are ready → updates order to READY.
   특허2: 조리 완료 타임스탬프 → KDS 처리시간 KPI.
   특허3: 조리 완료 이벤트 → AI Agent 학습 데이터.';

comment on function catchmenu_kds.complete_order_kds(
  uuid, uuid, uuid, text, uuid, text
) is
  'Completes entire order after all KDS tickets served.
   Marks all SERVED/READY tickets as COMPLETED.
   Updates order and session to COMPLETED.
   특허3 다이어그램3: 완료 이벤트 → Task/Event 운영 원장 → AI Agent 학습.';