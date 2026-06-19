-- 0050_create_waiting_queue_rpc.sql
-- Purpose: Waiting queue management RPCs.
--          get_waiting_queue: returns current queue state.
--          call_next_waiting: calls next customer in queue.
--          update_queue_position: reorders queue manually.
--          mark_no_show: marks customer as no-show.
--          estimate_wait_time: estimates wait time for new customer.
--          특허1 core: 대기열 관리 + Late Binding 연결점.
-- Depends on: 0049_create_store_settings_rpc.sql
-- Creates:
--   function catchmenu_pos.get_waiting_queue(...)
--   function catchmenu_pos.call_next_waiting(...)
--   function catchmenu_pos.update_queue_position(...)
--   function catchmenu_pos.mark_no_show(...)
--   function catchmenu_pos.estimate_wait_time(...)

create or replace function catchmenu_pos.get_waiting_queue(
  p_tenant_id uuid,
  p_store_id uuid,
  p_include_arrived boolean default true
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_pos, catchmenu_store,
                  catchmenu_common, catchmenu_hq
as $$
declare
  v_store record;
  v_queue jsonb;
  v_summary jsonb;
  v_business_day date;
begin
  select id, store_name, timezone
  into v_store
  from catchmenu_hq.stores
  where id = p_store_id
    and tenant_id = p_tenant_id
    and is_active = true;

  if v_store.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'store_not_found'
    );
  end if;

  v_business_day := (timezone(v_store.timezone, now()))::date;

  -- queue entries
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'session_id', s.id,
        'wait_number', s.wait_number,
        'queue_position', s.queue_position,
        'session_status', s.session_status,
        'session_type', s.session_type,
        'guest_count', s.guest_count,
        'guest_locale', s.guest_locale,
        'session_started_at', s.session_started_at,
        'arrived_at', s.arrived_at,
        'pre_order_created_at', s.pre_order_created_at,
        'arrival_reliability_score',
          s.arrival_reliability_score,
        'wait_minutes', extract(
          epoch from (now() - s.session_started_at)
        )::int / 60,
        'has_pre_order', s.pre_order_created_at is not null,
        'order_id', s.order_id,
        'expires_at', s.expires_at
      )
      order by
        case s.session_status
          when 'ARRIVAL_PENDING' then 0
          when 'WAITING' then 1
          else 2
        end,
        coalesce(s.queue_position, s.wait_number) asc nulls last,
        s.session_started_at asc
    ),
    '[]'::jsonb
  )
  into v_queue
  from catchmenu_pos.order_sessions s
  where s.store_id = p_store_id
    and s.tenant_id = p_tenant_id
    and s.business_day = v_business_day
    and (
      s.session_status = 'WAITING'
      or (
        p_include_arrived = true
        and s.session_status = 'ARRIVAL_PENDING'
      )
    )
    and s.session_type in ('WAITING', 'PRE_ORDER');

  -- summary
  select jsonb_build_object(
    'total_waiting', count(*) filter (
      where session_status = 'WAITING'
    ),
    'arrival_pending', count(*) filter (
      where session_status = 'ARRIVAL_PENDING'
    ),
    'with_pre_order', count(*) filter (
      where pre_order_created_at is not null
        and session_status in (
          'WAITING', 'ARRIVAL_PENDING'
        )
    ),
    'next_wait_number', coalesce(
      max(wait_number) + 1, 1
    ),
    'avg_wait_minutes', coalesce(
      avg(
        extract(
          epoch from (now() - session_started_at)
        ) / 60
      ) filter (
        where session_status = 'WAITING'
      )::int,
      0
    )
  )
  into v_summary
  from catchmenu_pos.order_sessions
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_business_day
    and session_status in ('WAITING', 'ARRIVAL_PENDING')
    and session_type in ('WAITING', 'PRE_ORDER');

  return jsonb_build_object(
    'success', true,
    'store', jsonb_build_object(
      'id', v_store.id,
      'store_name', v_store.store_name
    ),
    'queue', v_queue,
    'summary', v_summary,
    'business_day', v_business_day,
    'refreshed_at', now(),
    'message_code', 'waiting_queue_loaded'
  );
end;
$$;


create or replace function catchmenu_pos.call_next_waiting(
  p_tenant_id uuid,
  p_store_id uuid,
  p_actor_type text default 'STAFF',
  p_actor_id uuid default null,
  p_specific_session_id uuid default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_pos, catchmenu_ledger,
                  catchmenu_audit, catchmenu_common,
                  catchmenu_hq
as $$
declare
  v_session record;
  v_business_day date;
  v_timezone text;
  v_audit_id uuid;
  v_expire_at timestamptz;
begin
  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  -- find next session to call
  if p_specific_session_id is not null then
    select id, session_status, wait_number,
           guest_count, guest_locale,
           pre_order_created_at, order_id
    into v_session
    from catchmenu_pos.order_sessions
    where id = p_specific_session_id
      and store_id = p_store_id
      and tenant_id = p_tenant_id
      and session_status = 'WAITING'
    for update;
  else
    -- auto-select next in queue
    select id, session_status, wait_number,
           guest_count, guest_locale,
           pre_order_created_at, order_id
    into v_session
    from catchmenu_pos.order_sessions
    where store_id = p_store_id
      and tenant_id = p_tenant_id
      and business_day = v_business_day
      and session_status = 'WAITING'
      and session_type in ('WAITING', 'PRE_ORDER')
    order by
      coalesce(queue_position, wait_number) asc nulls last,
      session_started_at asc
    limit 1
    for update skip locked;
  end if;

  if v_session.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'no_waiting_session_found',
      'message_code', 'queue_empty'
    );
  end if;

  -- get no-show expire time from settings
  select now() + (
    coalesce(
      ss.no_show_auto_expire_minutes, 10
    ) || ' minutes'
  )::interval
  into v_expire_at
  from catchmenu_store.store_settings ss
  where ss.store_id = p_store_id
    and ss.tenant_id = p_tenant_id;

  v_expire_at := coalesce(
    v_expire_at, now() + interval '10 minutes'
  );

  -- update session to ARRIVAL_PENDING
  update catchmenu_pos.order_sessions
  set
    session_status = 'ARRIVAL_PENDING',
    expires_at = v_expire_at,
    updated_at = now()
  where id = v_session.id;

  -- session event
  insert into catchmenu_pos.session_events (
    tenant_id, store_id, session_id,
    event_type, from_status, to_status,
    caused_by_type, caused_by_id,
    event_payload, correlation_id, occurred_at
  ) values (
    p_tenant_id, p_store_id, v_session.id,
    'customer_called',
    'WAITING', 'ARRIVAL_PENDING',
    p_actor_type, p_actor_id,
    jsonb_build_object(
      'wait_number', v_session.wait_number,
      'expires_at', v_expire_at,
      'has_pre_order',
        v_session.pre_order_created_at is not null
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
    event_payload, session_id,
    correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'session', 'customer_called', 1,
    'order_session', v_session.id,
    'WAITING', 'ARRIVAL_PENDING',
    p_actor_type, p_actor_id,
    jsonb_build_object(
      'wait_number', v_session.wait_number,
      'expires_at', v_expire_at,
      'guest_count', v_session.guest_count,
      'has_pre_order',
        v_session.pre_order_created_at is not null
    ),
    v_session.id, p_correlation_id,
    v_business_day, v_timezone, now()
  );

  return jsonb_build_object(
    'success', true,
    'session_id', v_session.id,
    'wait_number', v_session.wait_number,
    'session_status', 'ARRIVAL_PENDING',
    'guest_count', v_session.guest_count,
    'guest_locale', v_session.guest_locale,
    'has_pre_order',
      v_session.pre_order_created_at is not null,
    'order_id', v_session.order_id,
    'expires_at', v_expire_at,
    'message_code', 'customer_called'
  );
end;
$$;


create or replace function catchmenu_pos.update_queue_position(
  p_tenant_id uuid,
  p_store_id uuid,
  p_session_id uuid,
  p_new_position int,
  p_reason text,
  p_actor_type text default 'MANAGER',
  p_actor_id uuid default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_pos, catchmenu_ledger,
                  catchmenu_audit, catchmenu_common,
                  catchmenu_hq
as $$
declare
  v_session record;
  v_audit_id uuid;
  v_business_day date;
  v_timezone text;
begin
  if p_new_position < 1 then
    return jsonb_build_object(
      'success', false,
      'error_key', 'invalid_position',
      'message', 'Position must be >= 1'
    );
  end if;

  if trim(coalesce(p_reason, '')) = '' then
    return jsonb_build_object(
      'success', false,
      'error_key', 'reason_required'
    );
  end if;

  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  select id, wait_number, queue_position,
         session_status, guest_count
  into v_session
  from catchmenu_pos.order_sessions
  where id = p_session_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
    and session_status = 'WAITING'
  for update;

  if v_session.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'session_not_found_or_not_waiting'
    );
  end if;

  -- update position
  update catchmenu_pos.order_sessions
  set
    queue_position = p_new_position,
    updated_at = now()
  where id = p_session_id;

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
    'session', 'queue_position_updated', 1,
    'order_session', p_session_id,
    coalesce(
      v_session.queue_position::text, 'null'
    ),
    p_new_position::text,
    p_actor_type, p_actor_id,
    jsonb_build_object(
      'wait_number', v_session.wait_number,
      'previous_position', v_session.queue_position,
      'new_position', p_new_position,
      'reason', p_reason
    ),
    p_session_id, p_correlation_id,
    v_business_day, v_timezone, now()
  );

  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := 'session',
    p_audit_type := 'queue_position_updated',
    p_audit_category := 'OPERATIONAL',
    p_actor_type := p_actor_type,
    p_actor_id := p_actor_id,
    p_subject_type := 'order_session',
    p_subject_id := p_session_id,
    p_decision := 'OVERRIDDEN',
    p_decision_reason := p_reason,
    p_decision_payload := jsonb_build_object(
      'wait_number', v_session.wait_number,
      'previous_position', v_session.queue_position,
      'new_position', p_new_position
    ),
    p_session_id := p_session_id,
    p_correlation_id := p_correlation_id,
    p_business_day := v_business_day,
    p_business_timezone := v_timezone
  );

  return jsonb_build_object(
    'success', true,
    'session_id', p_session_id,
    'wait_number', v_session.wait_number,
    'previous_position', v_session.queue_position,
    'new_position', p_new_position,
    'reason', p_reason,
    'audit_id', v_audit_id,
    'message_code', 'queue_position_updated'
  );
end;
$$;


create or replace function catchmenu_pos.mark_no_show(
  p_tenant_id uuid,
  p_store_id uuid,
  p_session_id uuid,
  p_actor_type text default 'STAFF',
  p_actor_id uuid default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_pos, catchmenu_ledger,
                  catchmenu_common, catchmenu_hq
as $$
declare
  v_session record;
  v_business_day date;
  v_timezone text;
  v_new_score int;
begin
  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  select id, session_status, wait_number,
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
      'error_key', 'session_not_markable',
      'current_status', v_session.session_status
    );
  end if;

  -- decrease arrival reliability score
  -- 특허2: 노쇼 이력 → arrival_reliability_score 하락
  -- → KDS no_show_risk_ok 조건 판단에 영향
  v_new_score := greatest(
    0,
    coalesce(v_session.arrival_reliability_score, 100) - 20
  );

  update catchmenu_pos.order_sessions
  set
    session_status = 'NO_SHOW',
    arrival_reliability_score = v_new_score,
    cancelled_at = now(),
    updated_at = now()
  where id = p_session_id;

  -- session event
  insert into catchmenu_pos.session_events (
    tenant_id, store_id, session_id,
    event_type, from_status, to_status,
    caused_by_type, caused_by_id,
    event_payload, correlation_id, occurred_at
  ) values (
    p_tenant_id, p_store_id, p_session_id,
    'no_show_marked',
    v_session.session_status, 'NO_SHOW',
    p_actor_type, p_actor_id,
    jsonb_build_object(
      'wait_number', v_session.wait_number,
      'previous_score',
        v_session.arrival_reliability_score,
      'new_score', v_new_score,
      'score_penalty', 20
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
    event_payload, session_id,
    correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'session', 'no_show_marked', 1,
    'order_session', p_session_id,
    v_session.session_status, 'NO_SHOW',
    p_actor_type, p_actor_id,
    jsonb_build_object(
      'wait_number', v_session.wait_number,
      'arrival_reliability_score_new', v_new_score,
      'score_penalty_applied', 20
    ),
    p_session_id, p_correlation_id,
    v_session.business_day, v_session.business_timezone,
    now()
  );

  return jsonb_build_object(
    'success', true,
    'session_id', p_session_id,
    'wait_number', v_session.wait_number,
    'session_status', 'NO_SHOW',
    'arrival_reliability_score', v_new_score,
    'score_penalty', 20,
    'message_code', 'no_show_marked'
  );
end;
$$;


create or replace function catchmenu_pos.estimate_wait_time(
  p_tenant_id uuid,
  p_store_id uuid,
  p_guest_count int default 1
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_pos, catchmenu_store,
                  catchmenu_common, catchmenu_hq
as $$
declare
  v_timezone text;
  v_business_day date;
  v_queue_length int;
  v_avg_session_minutes numeric;
  v_available_tables int;
  v_suitable_tables int;
  v_estimated_minutes int;
  v_next_wait_number int;
  v_settings record;
begin
  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  -- current queue length
  select count(*)
  into v_queue_length
  from catchmenu_pos.order_sessions
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_business_day
    and session_status in ('WAITING', 'ARRIVAL_PENDING');

  -- average session duration today (seated to completed)
  select coalesce(
    avg(
      extract(epoch from (
        completed_at - seated_at
      )) / 60
    ) filter (
      where seated_at is not null
        and completed_at is not null
    ),
    45
  )::int
  into v_avg_session_minutes
  from catchmenu_pos.order_sessions
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_business_day
    and session_status = 'COMPLETED';

  -- available tables that can seat guest_count
  select
    count(*) filter (
      where table_status = 'AVAILABLE'
        and capacity >= p_guest_count
    ),
    count(*) filter (
      where capacity >= p_guest_count
    )
  into v_available_tables, v_suitable_tables
  from catchmenu_store.dining_tables
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and is_active = true;

  -- estimate wait time
  v_estimated_minutes := case
    when v_available_tables > 0 then 0
    when v_suitable_tables = 0 then -1 -- no suitable tables
    when v_queue_length = 0 then 5
    else (
      v_queue_length * v_avg_session_minutes
      / greatest(v_suitable_tables, 1)
    )::int
  end;

  -- next wait number
  select coalesce(max(wait_number), 0) + 1
  into v_next_wait_number
  from catchmenu_pos.order_sessions
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_business_day;

  -- get settings
  select waiting_enabled, pre_order_enabled
  into v_settings
  from catchmenu_store.store_settings
  where store_id = p_store_id
    and tenant_id = p_tenant_id;

  return jsonb_build_object(
    'success', true,
    'store_id', p_store_id,
    'guest_count', p_guest_count,
    'estimated_wait_minutes', v_estimated_minutes,
    'can_seat_immediately', v_available_tables > 0,
    'queue_length', v_queue_length,
    'next_wait_number', v_next_wait_number,
    'available_tables', v_available_tables,
    'avg_session_minutes', v_avg_session_minutes,
    'waiting_enabled', coalesce(
      v_settings.waiting_enabled, true
    ),
    'pre_order_enabled', coalesce(
      v_settings.pre_order_enabled, true
    ),
    'message_code', case
      when v_suitable_tables = 0
      then 'no_suitable_tables'
      when v_available_tables > 0
      then 'table_available_now'
      else 'estimated_wait_time'
    end
  );
end;
$$;

-- grants
do $$
begin
  revoke all on function catchmenu_pos.get_waiting_queue(
    uuid, uuid, boolean
  ) from public;
  grant execute on function catchmenu_pos.get_waiting_queue(
    uuid, uuid, boolean
  ) to authenticated;

  revoke all on function catchmenu_pos.call_next_waiting(
    uuid, uuid, text, uuid, uuid, text
  ) from public;
  grant execute on function catchmenu_pos.call_next_waiting(
    uuid, uuid, text, uuid, uuid, text
  ) to authenticated;

  revoke all on function catchmenu_pos.update_queue_position(
    uuid, uuid, uuid, int, text, text, uuid, text
  ) from public;
  grant execute on function catchmenu_pos.update_queue_position(
    uuid, uuid, uuid, int, text, text, uuid, text
  ) to authenticated;

  revoke all on function catchmenu_pos.mark_no_show(
    uuid, uuid, uuid, text, uuid, text
  ) from public;
  grant execute on function catchmenu_pos.mark_no_show(
    uuid, uuid, uuid, text, uuid, text
  ) to authenticated;

  revoke all on function catchmenu_pos.estimate_wait_time(
    uuid, uuid, int
  ) from public;
  grant execute on function catchmenu_pos.estimate_wait_time(
    uuid, uuid, int
  ) to authenticated;
end;
$$;

comment on function catchmenu_pos.get_waiting_queue(
  uuid, uuid, boolean
) is
  'Returns current waiting queue state.
   ARRIVAL_PENDING sessions shown first (already called).
   WAITING sessions follow in queue position order.
   Shows pre-order flag for each session.
   특허1: 대기열 현황 — 대기번호/호출상태/선주문 여부 조회.';

comment on function catchmenu_pos.call_next_waiting(
  uuid, uuid, text, uuid, uuid, text
) is
  'Calls next customer in waiting queue.
   Transitions WAITING → ARRIVAL_PENDING.
   Sets expiry time from store settings no_show_auto_expire_minutes.
   Auto-selects by queue_position or wait_number if not specified.
   특허1: 대기 호출 → ARRIVAL_PENDING → Late Binding 준비 상태.';

comment on function catchmenu_pos.mark_no_show(
  uuid, uuid, uuid, text, uuid, text
) is
  'Marks called customer as no-show.
   Decreases arrival_reliability_score by 20 points.
   Score affects KDS Late Binding no_show_risk_ok condition.
   특허2: 노쇼 이력 → arrival_reliability_score 하락
          → KDS no_show_risk_ok 조건 판단 강화.';

comment on function catchmenu_pos.estimate_wait_time(
  uuid, uuid, int
) is
  'Estimates wait time for new customer.
   Uses: current queue length + avg session duration + available tables.
   Returns 0 if table immediately available.
   Returns -1 if no suitable tables for guest_count.
   Used by customer app and entrance display.
   특허1: 고객 입장 전 대기 시간 예측 — 선주문 결정 지원.';