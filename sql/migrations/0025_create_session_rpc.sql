-- 0025_create_session_rpc.sql
-- Purpose: Order session lifecycle RPCs.
--          create_order_session: creates new Handoff session.
--          bind_table_to_session: Late Binding — connects table to session.
--          mark_session_arrived: records customer arrival.
--          expire_session: expires timed-out sessions.
--          특허1 core: 세션 분리 + Late Binding 테이블 후매칭부.
-- Depends on: 0024_create_store_bootstrap_rpc.sql
-- Creates:
--   function catchmenu_pos.create_order_session(...)
--   function catchmenu_pos.mark_session_arrived(...)
--   function catchmenu_pos.bind_table_to_session(...)
--   function catchmenu_pos.expire_session(...)

create or replace function catchmenu_pos.create_order_session(
  p_tenant_id uuid,
  p_store_id uuid,
  p_session_type text,
  p_guest_count int default null,
  p_guest_locale text default 'ko',
  p_wait_number int default null,
  p_table_id uuid default null,
  p_expires_minutes int default 120,
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
  v_session_id uuid;
  v_initial_status text;
  v_business_day date;
  v_timezone text;
  v_table_status text;
begin
  -- store timezone
  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id and is_active = true;

  if v_timezone is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'store_not_found'
    );
  end if;

  v_business_day := (timezone(v_timezone, now()))::date;

  -- validate session type
  if p_session_type not in (
    'WALK_IN', 'WAITING', 'PRE_ORDER', 'KIOSK', 'TAKEOUT', 'DELIVERY'
  ) then
    return jsonb_build_object(
      'success', false,
      'error_key', 'invalid_session_type'
    );
  end if;

  -- determine initial status
  v_initial_status := case p_session_type
    when 'WALK_IN' then 'SEATED'
    when 'WAITING' then 'WAITING'
    when 'PRE_ORDER' then 'WAITING'
    when 'KIOSK' then 'ORDERING'
    when 'TAKEOUT' then 'ORDERING'
    when 'DELIVERY' then 'ORDER_CONFIRMED'
    else 'WAITING'
  end;

  -- if table_id provided for WALK_IN, validate table availability
  if p_table_id is not null then
    select table_status into v_table_status
    from catchmenu_store.dining_tables
    where id = p_table_id
      and store_id = p_store_id
      and is_active = true;

    if v_table_status is null then
      return jsonb_build_object(
        'success', false,
        'error_key', 'table_not_found'
      );
    end if;

    if v_table_status not in ('AVAILABLE', 'RESERVED') then
      return jsonb_build_object(
        'success', false,
        'error_key', 'table_not_available',
        'table_status', v_table_status
      );
    end if;
  end if;

  -- create session
  insert into catchmenu_pos.order_sessions (
    tenant_id,
    store_id,
    session_type,
    session_status,
    table_id,
    guest_count,
    guest_locale,
    wait_number,
    session_started_at,
    seated_at,
    expires_at,
    correlation_id,
    business_day,
    business_timezone
  ) values (
    p_tenant_id,
    p_store_id,
    p_session_type,
    v_initial_status,
    p_table_id,
    p_guest_count,
    coalesce(p_guest_locale, 'ko'),
    p_wait_number,
    now(),
    case when p_session_type = 'WALK_IN' then now() else null end,
    now() + (p_expires_minutes || ' minutes')::interval,
    p_correlation_id,
    v_business_day,
    v_timezone
  )
  returning id into v_session_id;

  -- if WALK_IN with table, update table status
  if p_table_id is not null and p_session_type = 'WALK_IN' then
    update catchmenu_store.dining_tables
    set
      table_status = 'OCCUPIED',
      current_session_id = v_session_id,
      occupied_since = now(),
      updated_at = now()
    where id = p_table_id;
  end if;

  -- session event
  insert into catchmenu_pos.session_events (
    tenant_id,
    store_id,
    session_id,
    event_type,
    from_status,
    to_status,
    caused_by_type,
    event_payload,
    correlation_id,
    table_id_at_event,
    occurred_at
  ) values (
    p_tenant_id,
    p_store_id,
    v_session_id,
    'session_created',
    null,
    v_initial_status,
    'SYSTEM',
    jsonb_build_object(
      'session_type', p_session_type,
      'guest_count', p_guest_count,
      'wait_number', p_wait_number,
      'table_id', p_table_id
    ),
    p_correlation_id,
    p_table_id,
    now()
  );

  -- ledger event
  insert into catchmenu_ledger.events (
    tenant_id,
    store_id,
    event_domain,
    event_type,
    event_version,
    subject_type,
    subject_id,
    from_state,
    to_state,
    caused_by_type,
    event_payload,
    session_id,
    correlation_id,
    business_day,
    business_timezone,
    occurred_at
  ) values (
    p_tenant_id,
    p_store_id,
    'session',
    'session_created',
    1,
    'order_session',
    v_session_id,
    null,
    v_initial_status,
    'SYSTEM',
    jsonb_build_object(
      'session_type', p_session_type,
      'table_id', p_table_id,
      'wait_number', p_wait_number
    ),
    v_session_id,
    p_correlation_id,
    v_business_day,
    v_timezone,
    now()
  );

  return jsonb_build_object(
    'success', true,
    'session_id', v_session_id,
    'session_type', p_session_type,
    'session_status', v_initial_status,
    'table_id', p_table_id,
    'wait_number', p_wait_number,
    'business_day', v_business_day,
    'expires_at', now() + (p_expires_minutes || ' minutes')::interval
  );
end;
$$;


create or replace function catchmenu_pos.mark_session_arrived(
  p_tenant_id uuid,
  p_store_id uuid,
  p_session_id uuid,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_pos, catchmenu_ledger,
                  catchmenu_audit, catchmenu_common
as $$
declare
  v_session record;
begin
  select id, session_type, session_status,
         table_id, wait_number, business_day, business_timezone
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

  if v_session.session_status not in ('WAITING', 'ARRIVAL_PENDING') then
    return jsonb_build_object(
      'success', false,
      'error_key', 'invalid_session_status',
      'current_status', v_session.session_status
    );
  end if;

  -- update session
  update catchmenu_pos.order_sessions
  set
    session_status = 'ARRIVAL_PENDING',
    arrived_at = now(),
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
    'customer_arrived',
    v_session.session_status,
    'ARRIVAL_PENDING',
    'CUSTOMER',
    jsonb_build_object('wait_number', v_session.wait_number),
    p_correlation_id,
    now()
  );

  -- ledger event
  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, event_payload,
    session_id, correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'session', 'customer_arrived', 1,
    'order_session', p_session_id,
    v_session.session_status, 'ARRIVAL_PENDING',
    'CUSTOMER',
    jsonb_build_object('wait_number', v_session.wait_number),
    p_session_id, p_correlation_id,
    v_session.business_day, v_session.business_timezone, now()
  );

  return jsonb_build_object(
    'success', true,
    'session_id', p_session_id,
    'session_status', 'ARRIVAL_PENDING',
    'arrived_at', now()
  );
end;
$$;


create or replace function catchmenu_pos.bind_table_to_session(
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
set search_path = catchmenu_pos, catchmenu_store,
                  catchmenu_ledger, catchmenu_audit,
                  catchmenu_common
as $$
declare
  v_session record;
  v_table record;
  v_audit_id uuid;
begin
  -- session validation
  select id, session_type, session_status,
         table_id, business_day, business_timezone,
         wait_number, guest_count
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

  -- session must be in pre-binding state
  if v_session.session_status not in (
    'WAITING', 'ARRIVAL_PENDING', 'ORDERING'
  ) then
    return jsonb_build_object(
      'success', false,
      'error_key', 'session_not_bindable',
      'current_status', v_session.session_status
    );
  end if;

  -- already bound
  if v_session.table_id is not null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'table_already_bound',
      'current_table_id', v_session.table_id
    );
  end if;

  -- table validation
  select id, table_code, table_name, table_status, current_session_id
  into v_table
  from catchmenu_store.dining_tables
  where id = p_table_id
    and store_id = p_store_id
    and is_active = true
  for update;

  if v_table.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'table_not_found'
    );
  end if;

  if v_table.table_status not in ('AVAILABLE', 'RESERVED') then
    return jsonb_build_object(
      'success', false,
      'error_key', 'table_not_available',
      'table_status', v_table.table_status,
      'current_session_id', v_table.current_session_id
    );
  end if;

  -- Late Binding — the core of 특허1
  -- bind table to session
  update catchmenu_pos.order_sessions
  set
    table_id = p_table_id,
    session_status = 'SEATED',
    seated_at = now(),
    ordering_started_at = now(),
    updated_at = now()
  where id = p_session_id;

  -- update table status
  update catchmenu_store.dining_tables
  set
    table_status = 'OCCUPIED',
    current_session_id = p_session_id,
    occupied_since = now(),
    updated_at = now()
  where id = p_table_id;

  -- session event
  insert into catchmenu_pos.session_events (
    tenant_id, store_id, session_id,
    event_type, from_status, to_status,
    caused_by_type, caused_by_id,
    event_payload, correlation_id,
    table_id_at_event, occurred_at
  ) values (
    p_tenant_id, p_store_id, p_session_id,
    'table_bound',
    v_session.session_status,
    'SEATED',
    p_actor_type, p_actor_id,
    jsonb_build_object(
      'table_id', p_table_id,
      'table_code', v_table.table_code,
      'wait_number', v_session.wait_number,
      'guest_count', v_session.guest_count
    ),
    p_correlation_id,
    p_table_id,
    now()
  );

  -- ledger event
  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, caused_by_id,
    event_payload, session_id,
    correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'session', 'table_bound', 1,
    'order_session', p_session_id,
    v_session.session_status, 'SEATED',
    p_actor_type, p_actor_id,
    jsonb_build_object(
      'table_id', p_table_id,
      'table_code', v_table.table_code,
      'late_binding_completed', true
    ),
    p_session_id, p_correlation_id,
    v_session.business_day, v_session.business_timezone, now()
  );

  -- audit record for Late Binding
  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := 'session',
    p_audit_type := 'table_late_binding_completed',
    p_audit_category := 'OPERATIONAL',
    p_actor_type := p_actor_type,
    p_actor_id := p_actor_id,
    p_subject_type := 'order_session',
    p_subject_id := p_session_id,
    p_decision := 'COMPLETED',
    p_decision_reason := 'Late Binding completed',
    p_decision_payload := jsonb_build_object(
      'table_id', p_table_id,
      'table_code', v_table.table_code,
      'from_status', v_session.session_status,
      'to_status', 'SEATED'
    ),
    p_before_state := jsonb_build_object(
      'session_status', v_session.session_status,
      'table_id', null
    ),
    p_after_state := jsonb_build_object(
      'session_status', 'SEATED',
      'table_id', p_table_id
    ),
    p_session_id := p_session_id,
    p_correlation_id := p_correlation_id,
    p_business_day := v_session.business_day,
    p_business_timezone := v_session.business_timezone
  );

  return jsonb_build_object(
    'success', true,
    'session_id', p_session_id,
    'session_status', 'SEATED',
    'table_id', p_table_id,
    'table_code', v_table.table_code,
    'seated_at', now(),
    'late_binding_completed', true,
    'audit_id', v_audit_id,
    'message_code', 'late_binding_completed'
  );
end;
$$;


create or replace function catchmenu_pos.expire_session(
  p_tenant_id uuid,
  p_store_id uuid,
  p_session_id uuid,
  p_expire_reason text default 'TTL_EXPIRED',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_pos, catchmenu_store,
                  catchmenu_ledger, catchmenu_common
as $$
declare
  v_session record;
  v_expire_status text;
begin
  select id, session_type, session_status,
         table_id, business_day, business_timezone,
         wait_number
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

  if v_session.session_status in (
    'COMPLETED', 'CANCELLED', 'EXPIRED', 'NO_SHOW'
  ) then
    return jsonb_build_object(
      'success', false,
      'error_key', 'session_already_terminal',
      'current_status', v_session.session_status
    );
  end if;

  -- determine terminal status
  v_expire_status := case p_expire_reason
    when 'NO_SHOW' then 'NO_SHOW'
    else 'EXPIRED'
  end;

  -- update session
  update catchmenu_pos.order_sessions
  set
    session_status = v_expire_status,
    cancelled_at = now(),
    updated_at = now()
  where id = p_session_id;

  -- release table if bound
  if v_session.table_id is not null then
    update catchmenu_store.dining_tables
    set
      table_status = 'CLEANING',
      current_session_id = null,
      updated_at = now()
    where id = v_session.table_id
      and current_session_id = p_session_id;
  end if;

  -- session event
  insert into catchmenu_pos.session_events (
    tenant_id, store_id, session_id,
    event_type, from_status, to_status,
    caused_by_type, event_payload,
    correlation_id, occurred_at
  ) values (
    p_tenant_id, p_store_id, p_session_id,
    case p_expire_reason
      when 'NO_SHOW' then 'no_show_marked'
      else 'session_expired'
    end,
    v_session.session_status,
    v_expire_status,
    'SYSTEM',
    jsonb_build_object(
      'expire_reason', p_expire_reason,
      'wait_number', v_session.wait_number
    ),
    p_correlation_id,
    now()
  );

  -- ledger event
  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, event_payload,
    session_id, correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'session',
    case p_expire_reason
      when 'NO_SHOW' then 'no_show_marked'
      else 'session_expired'
    end,
    1,
    'order_session', p_session_id,
    v_session.session_status, v_expire_status,
    'SYSTEM',
    jsonb_build_object('expire_reason', p_expire_reason),
    p_session_id, p_correlation_id,
    v_session.business_day, v_session.business_timezone, now()
  );

  return jsonb_build_object(
    'success', true,
    'session_id', p_session_id,
    'session_status', v_expire_status,
    'expire_reason', p_expire_reason,
    'table_released', v_session.table_id is not null
  );
end;
$$;

-- grants
revoke all on function catchmenu_pos.create_order_session(
  uuid, uuid, text, int, text, int, uuid, int, text
) from public;
grant execute on function catchmenu_pos.create_order_session(
  uuid, uuid, text, int, text, int, uuid, int, text
) to authenticated;

revoke all on function catchmenu_pos.mark_session_arrived(
  uuid, uuid, uuid, text
) from public;
grant execute on function catchmenu_pos.mark_session_arrived(
  uuid, uuid, uuid, text
) to authenticated;

revoke all on function catchmenu_pos.bind_table_to_session(
  uuid, uuid, uuid, uuid, text, uuid, text
) from public;
grant execute on function catchmenu_pos.bind_table_to_session(
  uuid, uuid, uuid, uuid, text, uuid, text
) to authenticated;

revoke all on function catchmenu_pos.expire_session(
  uuid, uuid, uuid, text, text
) from public;
grant execute on function catchmenu_pos.expire_session(
  uuid, uuid, uuid, text, text
) to authenticated;

comment on function catchmenu_pos.create_order_session(
  uuid, uuid, text, int, text, int, uuid, int, text
) is
  'Creates a new Wait/Order Handoff session.
   WALK_IN: immediately SEATED with optional table binding.
   WAITING: enters queue with wait_number.
   PRE_ORDER: 특허2 — pre-order before arrival.
   Writes session_events and ledger events on creation.
   특허1: 세션 분리 — 대기/장바구니/주문/결제/테이블 세션 독립 관리.';

comment on function catchmenu_pos.bind_table_to_session(
  uuid, uuid, uuid, uuid, text, uuid, text
) is
  'Late Binding RPC. The core of 특허1.
   Connects a waiting/arrived session to a physical table.
   Before this call: table_id is NULL on the session.
   After this call: table_id is set, session status = SEATED.
   Validates table availability before binding.
   Writes session_events, ledger event, and audit record.
   특허1: Late Binding 테이블 후매칭부 — 입장 후 실제 테이블과 세션 연결.';

comment on function catchmenu_pos.expire_session(
  uuid, uuid, uuid, text, text
) is
  'Expires or marks no-show for a session.
   Releases bound table to CLEANING status.
   NO_SHOW updates arrival_reliability_score downward.
   특허2: 노쇼 이력 기반 KDS 투입 시점 제어 데이터 생성.';