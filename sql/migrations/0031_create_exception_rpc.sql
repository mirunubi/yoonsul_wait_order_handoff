-- 0031_create_exception_rpc.sql
-- Purpose: Exception lifecycle RPCs.
--          create_exception: creates operational exception with classification.
--          acknowledge_exception: staff acknowledges exception.
--          resolve_exception: closes exception with resolution evidence.
--          escalate_exception: escalates to higher authority.
--          특허4 core: Exception 원장 기반 AI 학습 데이터 축적.
-- Depends on: 0030_create_manual_fallback_rpc.sql
-- Creates:
--   function catchmenu_ledger.create_exception(...)
--   function catchmenu_ledger.acknowledge_exception(...)
--   function catchmenu_ledger.resolve_exception(...)
--   function catchmenu_ledger.escalate_exception(...)

create or replace function catchmenu_ledger.create_exception(
  p_tenant_id uuid,
  p_store_id uuid,
  p_exception_domain text,
  p_exception_type text,
  p_exception_severity text,
  p_subject_type text default null,
  p_subject_id uuid default null,
  p_error_message text default null,
  p_error_code text default null,
  p_exception_payload jsonb default '{}'::jsonb,
  p_triggered_by_event_id uuid default null,
  p_triggered_by_task_id uuid default null,
  p_triggered_by_device_id uuid default null,
  p_triggered_by_agent_id uuid default null,
  p_recommended_sop_id uuid default null,
  p_requires_human_approval boolean default false,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_ledger, catchmenu_common,
                  catchmenu_hq
as $$
declare
  v_exception_id uuid;
  v_existing_id uuid;
  v_occurrence_count int;
  v_business_day date;
  v_timezone text;
  v_exception_code text;
begin
  -- store timezone
  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(v_timezone, now()))::date;

  -- check for existing open exception of same type for same subject
  select id, occurrence_count
  into v_existing_id, v_occurrence_count
  from catchmenu_ledger.exceptions
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and exception_type = p_exception_type
    and exception_domain = p_exception_domain
    and exception_status not in ('RESOLVED', 'CLOSED', 'SUPPRESSED')
    and (
      p_subject_id is null
      or subject_id = p_subject_id
    )
  limit 1
  for update skip locked;

  if v_existing_id is not null then
    -- increment occurrence count on existing exception
    update catchmenu_ledger.exceptions
    set
      occurrence_count = occurrence_count + 1,
      last_occurred_at = now(),
      exception_payload = exception_payload || coalesce(
        p_exception_payload, '{}'::jsonb
      ),
      updated_at = now()
    where id = v_existing_id;

    return jsonb_build_object(
      'success', true,
      'exception_id', v_existing_id,
      'is_new', false,
      'occurrence_count', v_occurrence_count + 1,
      'message_code', 'exception_occurrence_incremented'
    );
  end if;

  -- generate exception code
  v_exception_code :=
    upper(substr(p_exception_domain, 1, 3)) || '-' ||
    upper(substr(p_exception_type, 1, 8)) || '-' ||
    extract(epoch from now())::bigint::text;

  -- create new exception
  insert into catchmenu_ledger.exceptions (
    tenant_id, store_id,
    exception_code, exception_domain,
    exception_type, exception_severity,
    exception_status,
    subject_type, subject_id,
    triggered_by_event_id,
    triggered_by_task_id,
    triggered_by_device_id,
    triggered_by_agent_id,
    exception_payload,
    error_code, error_message,
    requires_human_approval,
    recommended_sop_id,
    occurrence_count,
    first_occurred_at, last_occurred_at,
    detected_at,
    correlation_id,
    business_day, business_timezone
  ) values (
    p_tenant_id, p_store_id,
    v_exception_code, p_exception_domain,
    p_exception_type, p_exception_severity,
    'OPEN',
    p_subject_type, p_subject_id,
    p_triggered_by_event_id,
    p_triggered_by_task_id,
    p_triggered_by_device_id,
    p_triggered_by_agent_id,
    coalesce(p_exception_payload, '{}'::jsonb),
    p_error_code, p_error_message,
    p_requires_human_approval,
    p_recommended_sop_id,
    1,
    now(), now(),
    now(),
    p_correlation_id,
    v_business_day, v_timezone
  )
  returning id into v_exception_id;

  -- ledger event
  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, event_payload,
    correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'system', 'exception_created', 1,
    'exception', v_exception_id,
    null, 'OPEN',
    'SYSTEM',
    jsonb_build_object(
      'exception_code', v_exception_code,
      'exception_domain', p_exception_domain,
      'exception_type', p_exception_type,
      'exception_severity', p_exception_severity,
      'requires_human_approval', p_requires_human_approval
    ),
    p_correlation_id,
    v_business_day, v_timezone, now()
  );

  return jsonb_build_object(
    'success', true,
    'exception_id', v_exception_id,
    'exception_code', v_exception_code,
    'exception_status', 'OPEN',
    'is_new', true,
    'occurrence_count', 1,
    'requires_human_approval', p_requires_human_approval,
    'message_code', 'exception_created'
  );
end;
$$;


create or replace function catchmenu_ledger.acknowledge_exception(
  p_tenant_id uuid,
  p_store_id uuid,
  p_exception_id uuid,
  p_actor_type text,
  p_actor_id uuid,
  p_acknowledgement_note text default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_ledger, catchmenu_audit,
                  catchmenu_common
as $$
declare
  v_exception record;
  v_audit_id uuid;
begin
  select id, exception_status, exception_type,
         exception_domain, exception_severity,
         business_day, business_timezone
  into v_exception
  from catchmenu_ledger.exceptions
  where id = p_exception_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
  for update;

  if v_exception.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'exception_not_found'
    );
  end if;

  if v_exception.exception_status <> 'OPEN' then
    return jsonb_build_object(
      'success', false,
      'error_key', 'exception_not_open',
      'current_status', v_exception.exception_status
    );
  end if;

  update catchmenu_ledger.exceptions
  set
    exception_status = 'ACKNOWLEDGED',
    updated_at = now()
  where id = p_exception_id;

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
    'system', 'exception_acknowledged', 1,
    'exception', p_exception_id,
    'OPEN', 'ACKNOWLEDGED',
    p_actor_type, p_actor_id,
    jsonb_build_object(
      'acknowledgement_note', p_acknowledgement_note
    ),
    p_correlation_id,
    v_exception.business_day, v_exception.business_timezone, now()
  );

  -- audit
  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := v_exception.exception_domain,
    p_audit_type := 'exception_acknowledged',
    p_audit_category := 'OPERATIONAL',
    p_actor_type := p_actor_type,
    p_actor_id := p_actor_id,
    p_subject_type := 'exception',
    p_subject_id := p_exception_id,
    p_decision := 'NOTED',
    p_decision_reason := p_acknowledgement_note,
    p_decision_payload := jsonb_build_object(
      'exception_type', v_exception.exception_type,
      'exception_severity', v_exception.exception_severity
    ),
    p_before_state := jsonb_build_object(
      'exception_status', 'OPEN'
    ),
    p_after_state := jsonb_build_object(
      'exception_status', 'ACKNOWLEDGED'
    ),
    p_exception_id := p_exception_id,
    p_correlation_id := p_correlation_id,
    p_business_day := v_exception.business_day,
    p_business_timezone := v_exception.business_timezone
  );

  return jsonb_build_object(
    'success', true,
    'exception_id', p_exception_id,
    'exception_status', 'ACKNOWLEDGED',
    'audit_id', v_audit_id
  );
end;
$$;


create or replace function catchmenu_ledger.resolve_exception(
  p_tenant_id uuid,
  p_store_id uuid,
  p_exception_id uuid,
  p_resolution_type text,
  p_resolution_note text,
  p_resolved_by_type text,
  p_resolved_by_id uuid,
  p_applied_sop_id uuid default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_ledger, catchmenu_audit,
                  catchmenu_common
as $$
declare
  v_exception record;
  v_audit_id uuid;
begin
  if trim(coalesce(p_resolution_note, '')) = '' then
    return jsonb_build_object(
      'success', false,
      'error_key', 'resolution_note_required'
    );
  end if;

  select id, exception_status, exception_type,
         exception_domain, exception_severity,
         occurrence_count, recommended_sop_id,
         business_day, business_timezone
  into v_exception
  from catchmenu_ledger.exceptions
  where id = p_exception_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
  for update;

  if v_exception.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'exception_not_found'
    );
  end if;

  if v_exception.exception_status in ('RESOLVED', 'CLOSED') then
    return jsonb_build_object(
      'success', false,
      'error_key', 'exception_already_resolved',
      'current_status', v_exception.exception_status
    );
  end if;

  update catchmenu_ledger.exceptions
  set
    exception_status = 'RESOLVED',
    resolution_type = p_resolution_type,
    resolution_note = p_resolution_note,
    resolved_by_type = p_resolved_by_type,
    resolved_by_id = p_resolved_by_id,
    resolved_at = now(),
    applied_sop_id = coalesce(
      p_applied_sop_id, applied_sop_id
    ),
    updated_at = now()
  where id = p_exception_id;

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
    'system', 'exception_resolved', 1,
    'exception', p_exception_id,
    v_exception.exception_status, 'RESOLVED',
    p_resolved_by_type, p_resolved_by_id,
    jsonb_build_object(
      'resolution_type', p_resolution_type,
      'resolution_note', p_resolution_note,
      'applied_sop_id', p_applied_sop_id,
      'occurrence_count', v_exception.occurrence_count
    ),
    p_correlation_id,
    v_exception.business_day, v_exception.business_timezone, now()
  );

  -- audit
  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := v_exception.exception_domain,
    p_audit_type := 'exception_resolved',
    p_audit_category := 'OPERATIONAL',
    p_actor_type := p_resolved_by_type,
    p_actor_id := p_resolved_by_id,
    p_subject_type := 'exception',
    p_subject_id := p_exception_id,
    p_decision := 'COMPLETED',
    p_decision_reason := p_resolution_note,
    p_decision_payload := jsonb_build_object(
      'resolution_type', p_resolution_type,
      'exception_type', v_exception.exception_type,
      'occurrence_count', v_exception.occurrence_count,
      'applied_sop_id', p_applied_sop_id
    ),
    p_before_state := jsonb_build_object(
      'exception_status', v_exception.exception_status
    ),
    p_after_state := jsonb_build_object(
      'exception_status', 'RESOLVED',
      'resolution_type', p_resolution_type
    ),
    p_exception_id := p_exception_id,
    p_correlation_id := p_correlation_id,
    p_business_day := v_exception.business_day,
    p_business_timezone := v_exception.business_timezone
  );

  return jsonb_build_object(
    'success', true,
    'exception_id', p_exception_id,
    'exception_status', 'RESOLVED',
    'resolution_type', p_resolution_type,
    'occurrence_count', v_exception.occurrence_count,
    'audit_id', v_audit_id,
    'message_code', 'exception_resolved'
  );
end;
$$;


create or replace function catchmenu_ledger.escalate_exception(
  p_tenant_id uuid,
  p_store_id uuid,
  p_exception_id uuid,
  p_escalated_to text,
  p_escalation_reason text,
  p_actor_type text,
  p_actor_id uuid,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_ledger, catchmenu_audit,
                  catchmenu_common
as $$
declare
  v_exception record;
  v_audit_id uuid;
begin
  select id, exception_status, exception_type,
         exception_domain, exception_severity,
         business_day, business_timezone
  into v_exception
  from catchmenu_ledger.exceptions
  where id = p_exception_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
  for update;

  if v_exception.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'exception_not_found'
    );
  end if;

  if v_exception.exception_status in ('RESOLVED', 'CLOSED') then
    return jsonb_build_object(
      'success', false,
      'error_key', 'exception_already_terminal',
      'current_status', v_exception.exception_status
    );
  end if;

  update catchmenu_ledger.exceptions
  set
    exception_status = 'ESCALATED',
    escalated_at = now(),
    escalated_to = p_escalated_to,
    updated_at = now()
  where id = p_exception_id;

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
    'system', 'exception_escalated', 1,
    'exception', p_exception_id,
    v_exception.exception_status, 'ESCALATED',
    p_actor_type, p_actor_id,
    jsonb_build_object(
      'escalated_to', p_escalated_to,
      'escalation_reason', p_escalation_reason
    ),
    p_correlation_id,
    v_exception.business_day, v_exception.business_timezone, now()
  );

  -- audit
  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := v_exception.exception_domain,
    p_audit_type := 'exception_escalated',
    p_audit_category := 'OPERATIONAL',
    p_actor_type := p_actor_type,
    p_actor_id := p_actor_id,
    p_subject_type := 'exception',
    p_subject_id := p_exception_id,
    p_decision := 'ESCALATED',
    p_decision_reason := p_escalation_reason,
    p_decision_payload := jsonb_build_object(
      'escalated_to', p_escalated_to,
      'exception_type', v_exception.exception_type,
      'exception_severity', v_exception.exception_severity
    ),
    p_before_state := jsonb_build_object(
      'exception_status', v_exception.exception_status
    ),
    p_after_state := jsonb_build_object(
      'exception_status', 'ESCALATED',
      'escalated_to', p_escalated_to
    ),
    p_exception_id := p_exception_id,
    p_correlation_id := p_correlation_id,
    p_business_day := v_exception.business_day,
    p_business_timezone := v_exception.business_timezone
  );

  return jsonb_build_object(
    'success', true,
    'exception_id', p_exception_id,
    'exception_status', 'ESCALATED',
    'escalated_to', p_escalated_to,
    'audit_id', v_audit_id,
    'message_code', 'exception_escalated'
  );
end;
$$;

-- grants
do $$
begin
  revoke all on function catchmenu_ledger.create_exception(
    uuid, uuid, text, text, text, text, uuid,
    text, text, jsonb, uuid, uuid, uuid, uuid,
    uuid, boolean, text
  ) from public;
  grant execute on function catchmenu_ledger.create_exception(
    uuid, uuid, text, text, text, text, uuid,
    text, text, jsonb, uuid, uuid, uuid, uuid,
    uuid, boolean, text
  ) to authenticated;

  revoke all on function catchmenu_ledger.acknowledge_exception(
    uuid, uuid, uuid, text, uuid, text, text
  ) from public;
  grant execute on function catchmenu_ledger.acknowledge_exception(
    uuid, uuid, uuid, text, uuid, text, text
  ) to authenticated;

  revoke all on function catchmenu_ledger.resolve_exception(
    uuid, uuid, uuid, text, text, text, uuid, uuid, text
  ) from public;
  grant execute on function catchmenu_ledger.resolve_exception(
    uuid, uuid, uuid, text, text, text, uuid, uuid, text
  ) to authenticated;

  revoke all on function catchmenu_ledger.escalate_exception(
    uuid, uuid, uuid, text, text, text, uuid, text
  ) from public;
  grant execute on function catchmenu_ledger.escalate_exception(
    uuid, uuid, uuid, text, text, text, uuid, text
  ) to authenticated;
end;
$$;

comment on function catchmenu_ledger.create_exception(
  uuid, uuid, text, text, text, text, uuid,
  text, text, jsonb, uuid, uuid, uuid, uuid,
  uuid, boolean, text
) is
  'Creates operational exception or increments existing open exception count.
   Deduplicates same exception type for same subject — no duplicate rows.
   occurrence_count drives Knowledge Gap detection threshold.
   특허4: 예외 데이터 원장화 — AI 학습 가능한 구조로 변환.
   특허3: occurrence_count >= threshold → Knowledge Gap Detection 트리거.';

comment on function catchmenu_ledger.resolve_exception(
  uuid, uuid, uuid, text, text, text, uuid, uuid, text
) is
  'Resolves exception with resolution type and note.
   applied_sop_id records which SOP was used.
   Resolution data feeds SOP effectiveness scoring.
   특허3: SOP 적용 결과 피드백 → document_versions.success_count 업데이트.';