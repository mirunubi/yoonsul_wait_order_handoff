-- 0030_create_manual_fallback_rpc.sql
-- Purpose: Manual fallback activation and recovery RPCs.
--          activate_manual_fallback: activates fallback mode when system fails.
--          resolve_manual_fallback: closes fallback after system recovery.
--          특허4 core: 무장애 운영 = 장애 시 운영 모드 전환 + 기록 + 복구.
-- Depends on: 0029_create_kds_cooking_rpc.sql
-- Creates:
--   function catchmenu_agent.activate_manual_fallback(...)
--   function catchmenu_agent.resolve_manual_fallback(...)

create or replace function catchmenu_agent.activate_manual_fallback(
  p_tenant_id uuid,
  p_store_id uuid,
  p_fallback_type text,
  p_fallback_reason text,
  p_bypassed_system text,
  p_activated_by_type text,
  p_activated_by_id uuid,
  p_triggered_by_exception_id uuid default null,
  p_triggered_by_device_id uuid default null,
  p_sop_applied_id uuid default null,
  p_affected_order_ids jsonb default null,
  p_affected_session_ids jsonb default null,
  p_affected_kds_ticket_ids jsonb default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_agent, catchmenu_ledger,
                  catchmenu_audit, catchmenu_common,
                  catchmenu_hq
as $$
declare
  v_fallback_id uuid;
  v_evidence_id uuid;
  v_audit_id uuid;
  v_business_day date;
  v_timezone text;
begin
  -- input validation
  if trim(coalesce(p_fallback_reason, '')) = '' then
    return jsonb_build_object(
      'success', false,
      'error_key', 'fallback_reason_required'
    );
  end if;

  if trim(coalesce(p_bypassed_system, '')) = '' then
    return jsonb_build_object(
      'success', false,
      'error_key', 'bypassed_system_required'
    );
  end if;

  -- store timezone
  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(v_timezone, now()))::date;

  -- check if same type already active
  if exists (
    select 1
    from catchmenu_agent.manual_fallback_log
    where store_id = p_store_id
      and tenant_id = p_tenant_id
      and fallback_type = p_fallback_type
      and fallback_status in ('ACTIVE', 'RECOVERING')
  ) then
    return jsonb_build_object(
      'success', false,
      'error_key', 'fallback_already_active',
      'fallback_type', p_fallback_type
    );
  end if;

  -- create evidence packet first
  insert into catchmenu_agent.evidence_packets (
    tenant_id, store_id,
    packet_type, packet_status, risk_level,
    subject_type, subject_id,
    exception_id,
    prior_state,
    staff_visible_explanation,
    actor_type, actor_id,
    correlation_id,
    business_day, business_timezone
  ) values (
    p_tenant_id, p_store_id,
    'KDS_MANUAL_FALLBACK', 'CREATED', 'HIGH',
    'store', p_store_id,
    p_triggered_by_exception_id,
    jsonb_build_object(
      'fallback_type', p_fallback_type,
      'bypassed_system', p_bypassed_system,
      'reason', p_fallback_reason
    ),
    p_fallback_reason,
    p_activated_by_type, p_activated_by_id,
    p_correlation_id,
    v_business_day, v_timezone
  )
  returning id into v_evidence_id;

  -- create fallback log entry
  insert into catchmenu_agent.manual_fallback_log (
    tenant_id, store_id,
    fallback_type, fallback_reason, fallback_status,
    triggered_by_exception_id,
    triggered_by_device_id,
    bypassed_system,
    affected_order_ids,
    affected_session_ids,
    affected_kds_ticket_ids,
    activated_by_type, activated_by_id,
    sop_applied_id,
    evidence_packet_id,
    resync_required,
    activated_at,
    business_day, business_timezone
  ) values (
    p_tenant_id, p_store_id,
    p_fallback_type, p_fallback_reason, 'ACTIVE',
    p_triggered_by_exception_id,
    p_triggered_by_device_id,
    p_bypassed_system,
    p_affected_order_ids,
    p_affected_session_ids,
    p_affected_kds_ticket_ids,
    p_activated_by_type, p_activated_by_id,
    p_sop_applied_id,
    v_evidence_id,
    true,
    now(),
    v_business_day, v_timezone
  )
  returning id into v_fallback_id;

  -- update evidence with fallback id
  update catchmenu_agent.evidence_packets
  set subject_id = v_fallback_id,
      updated_at = now()
  where id = v_evidence_id;

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
    'agent', 'manual_fallback_activated', 1,
    'manual_fallback', v_fallback_id,
    'NORMAL_OPERATION', 'FALLBACK_ACTIVE',
    p_activated_by_type, p_activated_by_id,
    jsonb_build_object(
      'fallback_type', p_fallback_type,
      'bypassed_system', p_bypassed_system,
      'fallback_reason', p_fallback_reason,
      'evidence_id', v_evidence_id
    ),
    p_correlation_id,
    v_business_day, v_timezone, now()
  );

  -- exception record
  insert into catchmenu_ledger.exceptions (
    tenant_id, store_id,
    exception_code, exception_domain,
    exception_type, exception_severity,
    exception_status,
    subject_type, subject_id,
    exception_payload,
    error_message,
    requires_human_approval,
    business_day, business_timezone
  ) values (
    p_tenant_id, p_store_id,
    'FALLBACK-' || upper(p_fallback_type) || '-' ||
      extract(epoch from now())::bigint::text,
    'system',
    'manual_fallback_active',
    'ERROR', 'OPEN',
    'manual_fallback', v_fallback_id,
    jsonb_build_object(
      'fallback_type', p_fallback_type,
      'bypassed_system', p_bypassed_system
    ),
    p_fallback_reason,
    false,
    v_business_day, v_timezone
  );

  -- audit record
  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := 'agent',
    p_audit_type := 'manual_fallback_activated',
    p_audit_category := 'OPERATIONAL',
    p_actor_type := p_activated_by_type,
    p_actor_id := p_activated_by_id,
    p_subject_type := 'manual_fallback',
    p_subject_id := v_fallback_id,
    p_decision := 'APPROVED',
    p_decision_reason := p_fallback_reason,
    p_decision_payload := jsonb_build_object(
      'fallback_type', p_fallback_type,
      'bypassed_system', p_bypassed_system,
      'sop_applied_id', p_sop_applied_id,
      'evidence_id', v_evidence_id
    ),
    p_before_state := jsonb_build_object(
      'operation_mode', 'NORMAL'
    ),
    p_after_state := jsonb_build_object(
      'operation_mode', 'FALLBACK',
      'fallback_type', p_fallback_type
    ),
    p_evidence_packet_id := v_evidence_id,
    p_correlation_id := p_correlation_id,
    p_business_day := v_business_day,
    p_business_timezone := v_timezone
  );

  -- update evidence with audit id
  update catchmenu_agent.evidence_packets
  set audit_record_id = v_audit_id,
      updated_at = now()
  where id = v_evidence_id;

  return jsonb_build_object(
    'success', true,
    'fallback_id', v_fallback_id,
    'fallback_type', p_fallback_type,
    'fallback_status', 'ACTIVE',
    'bypassed_system', p_bypassed_system,
    'evidence_id', v_evidence_id,
    'audit_id', v_audit_id,
    'resync_required', true,
    'message_code', 'fallback_activated'
  );
end;
$$;


create or replace function catchmenu_agent.resolve_manual_fallback(
  p_tenant_id uuid,
  p_store_id uuid,
  p_fallback_id uuid,
  p_resolution_type text,
  p_recovery_note text,
  p_resolved_by_type text,
  p_resolved_by_id uuid,
  p_resync_event_count int default null,
  p_resync_conflict_count int default 0,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_agent, catchmenu_ledger,
                  catchmenu_audit, catchmenu_common
as $$
declare
  v_fallback record;
  v_audit_id uuid;
  v_final_status text;
begin
  select id, fallback_type, fallback_status,
         bypassed_system, evidence_packet_id,
         business_day, business_timezone,
         resync_conflict_count
  into v_fallback
  from catchmenu_agent.manual_fallback_log
  where id = p_fallback_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
  for update;

  if v_fallback.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'fallback_not_found'
    );
  end if;

  if v_fallback.fallback_status not in ('ACTIVE', 'RECOVERING') then
    return jsonb_build_object(
      'success', false,
      'error_key', 'fallback_not_active',
      'current_status', v_fallback.fallback_status
    );
  end if;

  -- determine final status
  v_final_status := case
    when coalesce(p_resync_conflict_count, 0) > 0
    then 'PARTIALLY_RESOLVED'
    else 'RESOLVED'
  end;

  -- update fallback log
  update catchmenu_agent.manual_fallback_log
  set
    fallback_status = v_final_status,
    recovery_started_at = coalesce(recovery_started_at, now()),
    recovery_completed_at = now(),
    recovery_note = p_recovery_note,
    deactivated_at = now(),
    resync_completed_at = case
      when p_resync_event_count is not null then now()
      else resync_completed_at
    end,
    resync_event_count = coalesce(
      p_resync_event_count, resync_event_count
    ),
    resync_conflict_count = coalesce(
      p_resync_conflict_count, 0
    ),
    updated_at = now()
  where id = p_fallback_id;

  -- close related exception
  update catchmenu_ledger.exceptions
  set
    exception_status = 'RESOLVED',
    resolution_type = case p_resolution_type
      when 'FULL_RECOVERY' then 'AUTO_RECOVERED'
      when 'PARTIAL_RECOVERY' then 'MANUAL_STAFF'
      else 'MANUAL_MANAGER'
    end,
    resolution_note = p_recovery_note,
    resolved_by_type = p_resolved_by_type,
    resolved_by_id = p_resolved_by_id,
    resolved_at = now(),
    updated_at = now()
  where subject_type = 'manual_fallback'
    and subject_id = p_fallback_id
    and exception_status not in ('RESOLVED', 'CLOSED');

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
    'agent', 'manual_fallback_resolved', 1,
    'manual_fallback', p_fallback_id,
    v_fallback.fallback_status, v_final_status,
    p_resolved_by_type, p_resolved_by_id,
    jsonb_build_object(
      'fallback_type', v_fallback.fallback_type,
      'resolution_type', p_resolution_type,
      'resync_event_count', p_resync_event_count,
      'resync_conflict_count', p_resync_conflict_count,
      'recovery_note', p_recovery_note
    ),
    p_correlation_id,
    v_fallback.business_day, v_fallback.business_timezone, now()
  );

  -- audit
  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := 'agent',
    p_audit_type := 'manual_fallback_resolved',
    p_audit_category := 'OPERATIONAL',
    p_actor_type := p_resolved_by_type,
    p_actor_id := p_resolved_by_id,
    p_subject_type := 'manual_fallback',
    p_subject_id := p_fallback_id,
    p_decision := 'COMPLETED',
    p_decision_reason := p_recovery_note,
    p_decision_payload := jsonb_build_object(
      'fallback_type', v_fallback.fallback_type,
      'resolution_type', p_resolution_type,
      'final_status', v_final_status,
      'resync_event_count', p_resync_event_count,
      'resync_conflict_count', p_resync_conflict_count
    ),
    p_before_state := jsonb_build_object(
      'fallback_status', v_fallback.fallback_status
    ),
    p_after_state := jsonb_build_object(
      'fallback_status', v_final_status,
      'recovery_completed', true
    ),
    p_evidence_packet_id := v_fallback.evidence_packet_id,
    p_correlation_id := p_correlation_id,
    p_business_day := v_fallback.business_day,
    p_business_timezone := v_fallback.business_timezone
  );

  return jsonb_build_object(
    'success', true,
    'fallback_id', p_fallback_id,
    'fallback_type', v_fallback.fallback_type,
    'fallback_status', v_final_status,
    'resolution_type', p_resolution_type,
    'resync_event_count', p_resync_event_count,
    'resync_conflict_count', p_resync_conflict_count,
    'has_conflicts', coalesce(p_resync_conflict_count, 0) > 0,
    'audit_id', v_audit_id,
    'message_code', case v_final_status
      when 'RESOLVED' then 'fallback_fully_resolved'
      else 'fallback_partially_resolved_conflicts_remain'
    end
  );
end;
$$;

-- grants
revoke all on function catchmenu_agent.activate_manual_fallback(
  uuid, uuid, text, text, text, text, uuid,
  uuid, uuid, uuid, jsonb, jsonb, jsonb, text
) from public;
grant execute on function catchmenu_agent.activate_manual_fallback(
  uuid, uuid, text, text, text, text, uuid,
  uuid, uuid, uuid, jsonb, jsonb, jsonb, text
) to authenticated;

revoke all on function catchmenu_agent.resolve_manual_fallback(
  uuid, uuid, uuid, text, text, text, uuid, int, int, text
) from public;
grant execute on function catchmenu_agent.resolve_manual_fallback(
  uuid, uuid, uuid, text, text, text, uuid, int, int, text
) to authenticated;

comment on function catchmenu_agent.activate_manual_fallback(
  uuid, uuid, text, text, text, text, uuid,
  uuid, uuid, uuid, jsonb, jsonb, jsonb, text
) is
  'Activates manual fallback mode when a system component fails.
   Creates evidence packet and fallback log entry atomically.
   Raises exception record for monitoring.
   Sets resync_required = true — local ledger must be synced after recovery.
   특허4: 무장애 운영 = 장애 발생 시 운영 모드 전환 + 기록 + 감사 흐름 유지.
   특허2: KDS 장애 시 Manual Fallback 구조 — 수기 전표 전환 후 증거 생성.';

comment on function catchmenu_agent.resolve_manual_fallback(
  uuid, uuid, uuid, text, text, text, uuid, int, int, text
) is
  'Resolves manual fallback after system recovery.
   PARTIALLY_RESOLVED when resync_conflict_count > 0.
   Conflicts must be manually reviewed before full RESOLVED status.
   특허4: Local Temporary Ledger → Event Replay → 충돌 감지 → 관리자 검토.';