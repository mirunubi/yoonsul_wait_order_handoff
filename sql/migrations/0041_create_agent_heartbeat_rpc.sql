-- 0041_create_agent_heartbeat_rpc.sql
-- Purpose: Agent heartbeat and status management RPCs.
--          agent_heartbeat: updates agent last_heartbeat_at and status.
--          update_agent_status: changes agent operational status.
--          isolate_agent_module: isolates failed agent module.
--          recover_agent_module: recovers isolated agent.
--          특허4 core: Agent Runtime 모듈별 장애 격리 및 Failover.
-- Depends on: 0040_create_local_ledger_replay_rpc.sql
-- Creates:
--   function catchmenu_agent.agent_heartbeat(...)
--   function catchmenu_agent.update_agent_status(...)
--   function catchmenu_agent.isolate_agent_module(...)
--   function catchmenu_agent.recover_agent_module(...)

create or replace function catchmenu_agent.agent_heartbeat(
  p_tenant_id uuid,
  p_store_id uuid,
  p_agent_id uuid,
  p_runtime_version text default null,
  p_health_payload jsonb default '{}'::jsonb,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_store, catchmenu_ledger,
                  catchmenu_common
as $$
declare
  v_agent record;
  v_previous_status text;
  v_recovered boolean := false;
begin
  select
    id, agent_code, agent_type, agent_status,
    agent_role, last_heartbeat_at
  into v_agent
  from catchmenu_store.agent_registry
  where id = p_agent_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
    and is_active = true
  for update;

  if v_agent.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'agent_not_found'
    );
  end if;

  v_previous_status := v_agent.agent_status;

  -- detect recovery from DEGRADED/FAILED
  if v_agent.agent_status in ('DEGRADED', 'FAILED', 'OFFLINE') then
    v_recovered := true;
  end if;

  -- update heartbeat
  update catchmenu_store.agent_registry
  set
    last_heartbeat_at = now(),
    last_action_at = now(),
    agent_status = 'ONLINE',
    runtime_version = coalesce(
      p_runtime_version, runtime_version
    ),
    updated_at = now()
  where id = p_agent_id;

  -- if recovered from degraded state, log event
  if v_recovered then
    insert into catchmenu_ledger.events (
      tenant_id, store_id,
      event_domain, event_type, event_version,
      subject_type, subject_id,
      from_state, to_state,
      caused_by_type, caused_by_agent_id,
      event_payload, correlation_id,
      business_day, business_timezone, occurred_at
    )
    select
      p_tenant_id, p_store_id,
      'agent', 'agent_recovered', 1,
      'agent', p_agent_id,
      v_previous_status, 'ONLINE',
      'SYSTEM', p_agent_id,
      jsonb_build_object(
        'agent_code', v_agent.agent_code,
        'agent_type', v_agent.agent_type,
        'previous_status', v_previous_status,
        'runtime_version', p_runtime_version,
        'health_payload', p_health_payload
      ),
      p_correlation_id,
      (timezone('Asia/Seoul', now()))::date,
      'Asia/Seoul', now();
  end if;

  return jsonb_build_object(
    'success', true,
    'agent_id', p_agent_id,
    'agent_code', v_agent.agent_code,
    'agent_type', v_agent.agent_type,
    'agent_status', 'ONLINE',
    'heartbeat_at', now(),
    'recovered', v_recovered,
    'previous_status', v_previous_status,
    'message_code', case
      when v_recovered then 'agent_recovered'
      else 'heartbeat_ok'
    end
  );
end;
$$;


create or replace function catchmenu_agent.update_agent_status(
  p_tenant_id uuid,
  p_store_id uuid,
  p_agent_id uuid,
  p_new_status text,
  p_reason text default null,
  p_actor_type text default 'SYSTEM',
  p_actor_id uuid default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_store, catchmenu_ledger,
                  catchmenu_audit, catchmenu_common
as $$
declare
  v_agent record;
  v_audit_id uuid;
  v_business_day date;
begin
  if p_new_status not in (
    'ONLINE', 'OFFLINE', 'DEGRADED',
    'ISOLATED', 'FAILED'
  ) then
    return jsonb_build_object(
      'success', false,
      'error_key', 'invalid_status'
    );
  end if;

  v_business_day := (timezone('Asia/Seoul', now()))::date;

  select id, agent_code, agent_type,
         agent_status, agent_role
  into v_agent
  from catchmenu_store.agent_registry
  where id = p_agent_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
  for update;

  if v_agent.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'agent_not_found'
    );
  end if;

  if v_agent.agent_status = p_new_status then
    return jsonb_build_object(
      'success', true,
      'agent_id', p_agent_id,
      'agent_status', p_new_status,
      'message_code', 'status_unchanged'
    );
  end if;

  -- update status
  update catchmenu_store.agent_registry
  set
    agent_status = p_new_status,
    updated_at = now()
  where id = p_agent_id;

  -- ledger event
  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, caused_by_id,
    event_payload, correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'agent',
    case p_new_status
      when 'ISOLATED' then 'agent_isolated'
      when 'FAILED' then 'agent_failed'
      when 'DEGRADED' then 'agent_degraded'
      when 'ONLINE' then 'agent_started'
      else 'agent_status_changed'
    end,
    1,
    'agent', p_agent_id,
    v_agent.agent_status, p_new_status,
    p_actor_type, p_actor_id,
    jsonb_build_object(
      'agent_code', v_agent.agent_code,
      'agent_type', v_agent.agent_type,
      'reason', p_reason
    ),
    p_correlation_id,
    v_business_day, 'Asia/Seoul', now()
  );

  -- audit for high-severity status changes
  if p_new_status in ('ISOLATED', 'FAILED') then
    v_audit_id := catchmenu_audit.append_audit_record(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_audit_domain := 'agent',
      p_audit_type := 'agent_status_changed',
      p_audit_category := 'OPERATIONAL',
      p_actor_type := p_actor_type,
      p_actor_id := p_actor_id,
      p_subject_type := 'agent',
      p_subject_id := p_agent_id,
      p_decision := case p_new_status
        when 'ISOLATED' then 'SUSPENDED'
        else 'NOTED'
      end,
      p_decision_reason := p_reason,
      p_decision_payload := jsonb_build_object(
        'agent_code', v_agent.agent_code,
        'agent_type', v_agent.agent_type,
        'new_status', p_new_status
      ),
      p_before_state := jsonb_build_object(
        'agent_status', v_agent.agent_status
      ),
      p_after_state := jsonb_build_object(
        'agent_status', p_new_status
      ),
      p_correlation_id := p_correlation_id,
      p_business_day := v_business_day,
      p_business_timezone := 'Asia/Seoul'
    );
  end if;

  -- create exception for failures
  if p_new_status in ('FAILED', 'ISOLATED') then
    perform catchmenu_ledger.create_exception(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_exception_domain := 'agent',
      p_exception_type := case p_new_status
        when 'FAILED' then 'agent_module_failed'
        else 'agent_isolated'
      end,
      p_exception_severity := case p_new_status
        when 'FAILED' then 'ERROR'
        else 'WARNING'
      end,
      p_subject_type := 'agent',
      p_subject_id := p_agent_id,
      p_error_message := p_reason,
      p_exception_payload := jsonb_build_object(
        'agent_code', v_agent.agent_code,
        'agent_type', v_agent.agent_type,
        'previous_status', v_agent.agent_status
      ),
      p_requires_human_approval :=
        p_new_status = 'FAILED',
      p_correlation_id := p_correlation_id
    );
  end if;

  return jsonb_build_object(
    'success', true,
    'agent_id', p_agent_id,
    'agent_code', v_agent.agent_code,
    'agent_type', v_agent.agent_type,
    'previous_status', v_agent.agent_status,
    'new_status', p_new_status,
    'audit_id', v_audit_id,
    'message_code', 'agent_status_updated'
  );
end;
$$;


create or replace function catchmenu_agent.isolate_agent_module(
  p_tenant_id uuid,
  p_store_id uuid,
  p_agent_id uuid,
  p_isolation_reason text,
  p_fallback_agent_id uuid default null,
  p_actor_type text default 'SUPERVISOR',
  p_actor_id uuid default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_store, catchmenu_ledger,
                  catchmenu_audit, catchmenu_common
as $$
declare
  v_agent record;
  v_fallback_agent record;
  v_audit_id uuid;
  v_business_day date;
begin
  if trim(coalesce(p_isolation_reason, '')) = '' then
    return jsonb_build_object(
      'success', false,
      'error_key', 'isolation_reason_required'
    );
  end if;

  v_business_day := (timezone('Asia/Seoul', now()))::date;

  select id, agent_code, agent_type,
         agent_status, agent_role
  into v_agent
  from catchmenu_store.agent_registry
  where id = p_agent_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
  for update;

  if v_agent.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'agent_not_found'
    );
  end if;

  if v_agent.agent_status = 'ISOLATED' then
    return jsonb_build_object(
      'success', false,
      'error_key', 'agent_already_isolated'
    );
  end if;

  -- isolate agent
  perform catchmenu_agent.update_agent_status(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_agent_id := p_agent_id,
    p_new_status := 'ISOLATED',
    p_reason := p_isolation_reason,
    p_actor_type := p_actor_type,
    p_actor_id := p_actor_id,
    p_correlation_id := p_correlation_id
  );

  -- activate fallback agent if provided
  if p_fallback_agent_id is not null then
    select id, agent_code, agent_type, agent_status
    into v_fallback_agent
    from catchmenu_store.agent_registry
    where id = p_fallback_agent_id
      and store_id = p_store_id
      and tenant_id = p_tenant_id;

    if v_fallback_agent.id is not null then
      perform catchmenu_agent.update_agent_status(
        p_tenant_id := p_tenant_id,
        p_store_id := p_store_id,
        p_agent_id := p_fallback_agent_id,
        p_new_status := 'ONLINE',
        p_reason := 'Activated as fallback for isolated agent: '
          || v_agent.agent_code,
        p_actor_type := 'SYSTEM',
        p_correlation_id := p_correlation_id
      );
    end if;
  end if;

  -- audit
  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := 'agent',
    p_audit_type := 'agent_module_isolated',
    p_audit_category := 'OPERATIONAL',
    p_actor_type := p_actor_type,
    p_actor_id := p_actor_id,
    p_subject_type := 'agent',
    p_subject_id := p_agent_id,
    p_decision := 'SUSPENDED',
    p_decision_reason := p_isolation_reason,
    p_decision_payload := jsonb_build_object(
      'agent_code', v_agent.agent_code,
      'agent_type', v_agent.agent_type,
      'fallback_agent_id', p_fallback_agent_id,
      'fallback_agent_code', v_fallback_agent.agent_code
    ),
    p_before_state := jsonb_build_object(
      'agent_status', v_agent.agent_status
    ),
    p_after_state := jsonb_build_object(
      'agent_status', 'ISOLATED',
      'fallback_activated',
        p_fallback_agent_id is not null
    ),
    p_correlation_id := p_correlation_id,
    p_business_day := v_business_day,
    p_business_timezone := 'Asia/Seoul'
  );

  return jsonb_build_object(
    'success', true,
    'agent_id', p_agent_id,
    'agent_code', v_agent.agent_code,
    'agent_type', v_agent.agent_type,
    'agent_status', 'ISOLATED',
    'isolation_reason', p_isolation_reason,
    'fallback_activated', p_fallback_agent_id is not null,
    'fallback_agent_id', p_fallback_agent_id,
    'fallback_agent_code', v_fallback_agent.agent_code,
    'audit_id', v_audit_id,
    'message_code', 'agent_isolated'
  );
end;
$$;


create or replace function catchmenu_agent.recover_agent_module(
  p_tenant_id uuid,
  p_store_id uuid,
  p_agent_id uuid,
  p_recovery_note text,
  p_actor_type text default 'STAFF',
  p_actor_id uuid default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_store, catchmenu_ledger,
                  catchmenu_audit, catchmenu_common
as $$
declare
  v_agent record;
  v_audit_id uuid;
  v_business_day date;
begin
  if trim(coalesce(p_recovery_note, '')) = '' then
    return jsonb_build_object(
      'success', false,
      'error_key', 'recovery_note_required'
    );
  end if;

  v_business_day := (timezone('Asia/Seoul', now()))::date;

  select id, agent_code, agent_type, agent_status
  into v_agent
  from catchmenu_store.agent_registry
  where id = p_agent_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
  for update;

  if v_agent.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'agent_not_found'
    );
  end if;

  if v_agent.agent_status not in (
    'ISOLATED', 'FAILED', 'DEGRADED', 'OFFLINE'
  ) then
    return jsonb_build_object(
      'success', false,
      'error_key', 'agent_not_recoverable',
      'current_status', v_agent.agent_status
    );
  end if;

  -- recover agent to ONLINE
  perform catchmenu_agent.update_agent_status(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_agent_id := p_agent_id,
    p_new_status := 'ONLINE',
    p_reason := p_recovery_note,
    p_actor_type := p_actor_type,
    p_actor_id := p_actor_id,
    p_correlation_id := p_correlation_id
  );

  -- resolve related exceptions
  update catchmenu_ledger.exceptions
  set
    exception_status = 'RESOLVED',
    resolution_type = 'AGENT_RECOVERED',
    resolution_note = p_recovery_note,
    resolved_by_type = p_actor_type,
    resolved_by_id = p_actor_id,
    resolved_at = now(),
    updated_at = now()
  where subject_type = 'agent'
    and subject_id = p_agent_id
    and exception_status not in ('RESOLVED', 'CLOSED');

  -- audit
  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := 'agent',
    p_audit_type := 'agent_module_recovered',
    p_audit_category := 'OPERATIONAL',
    p_actor_type := p_actor_type,
    p_actor_id := p_actor_id,
    p_subject_type := 'agent',
    p_subject_id := p_agent_id,
    p_decision := 'COMPLETED',
    p_decision_reason := p_recovery_note,
    p_decision_payload := jsonb_build_object(
      'agent_code', v_agent.agent_code,
      'agent_type', v_agent.agent_type,
      'previous_status', v_agent.agent_status
    ),
    p_before_state := jsonb_build_object(
      'agent_status', v_agent.agent_status
    ),
    p_after_state := jsonb_build_object(
      'agent_status', 'ONLINE'
    ),
    p_correlation_id := p_correlation_id,
    p_business_day := v_business_day,
    p_business_timezone := 'Asia/Seoul'
  );

  return jsonb_build_object(
    'success', true,
    'agent_id', p_agent_id,
    'agent_code', v_agent.agent_code,
    'agent_type', v_agent.agent_type,
    'previous_status', v_agent.agent_status,
    'agent_status', 'ONLINE',
    'recovery_note', p_recovery_note,
    'audit_id', v_audit_id,
    'message_code', 'agent_recovered'
  );
end;
$$;

-- grants
do $$
begin
  revoke all on function catchmenu_agent.agent_heartbeat(
    uuid, uuid, uuid, text, jsonb, text
  ) from public;
  grant execute on function catchmenu_agent.agent_heartbeat(
    uuid, uuid, uuid, text, jsonb, text
  ) to authenticated;

  revoke all on function catchmenu_agent.update_agent_status(
    uuid, uuid, uuid, text, text, text, uuid, text
  ) from public;
  grant execute on function catchmenu_agent.update_agent_status(
    uuid, uuid, uuid, text, text, text, uuid, text
  ) to authenticated;

  revoke all on function catchmenu_agent.isolate_agent_module(
    uuid, uuid, uuid, text, uuid, text, uuid, text
  ) from public;
  grant execute on function catchmenu_agent.isolate_agent_module(
    uuid, uuid, uuid, text, uuid, text, uuid, text
  ) to authenticated;

  revoke all on function catchmenu_agent.recover_agent_module(
    uuid, uuid, uuid, text, text, uuid, text
  ) from public;
  grant execute on function catchmenu_agent.recover_agent_module(
    uuid, uuid, uuid, text, text, uuid, text
  ) to authenticated;
end;
$$;

comment on function catchmenu_agent.agent_heartbeat(
  uuid, uuid, uuid, text, jsonb, text
) is
  'Updates agent last_heartbeat_at and confirms ONLINE status.
   Auto-detects recovery from DEGRADED/FAILED/OFFLINE.
   Logs recovery event to ledger.
   Called by each agent module on regular interval.
   특허4: Agent Runtime 상태 모니터링 — Supervisor가 heartbeat 누락 감지.';

comment on function catchmenu_agent.isolate_agent_module(
  uuid, uuid, uuid, text, uuid, text, uuid, text
) is
  'Isolates a failed agent module without shutting down entire Agent Runtime.
   Optionally activates fallback agent for the isolated module function.
   특허4: Agent 모듈별 장애 격리.
   전체 Agent Server 셧다운 없이 장애 모듈만 격리 후 재시작.
   재시작 실패 시 해당 모듈 기능만 Secondary로 위임.';

comment on function catchmenu_agent.recover_agent_module(
  uuid, uuid, uuid, text, text, uuid, text
) is
  'Recovers an isolated or failed agent module back to ONLINE.
   Resolves all related exceptions automatically.
   Requires recovery note for audit trail.
   특허4: 복구 후 재동기화 + 감사 기록.';