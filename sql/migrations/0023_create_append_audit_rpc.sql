-- 0023_create_append_audit_rpc.sql
-- Purpose: Secure append-only audit record insertion RPC.
--          Clients must never INSERT into audit_records directly.
--          All audit writes go through this SECURITY DEFINER function.
--          특허4 core: 감사 원장 단일 진입점.
-- Depends on: 0022_create_rls_policies.sql
-- Creates:
--   function catchmenu_audit.append_audit_record(...)

create or replace function catchmenu_audit.append_audit_record(
  p_tenant_id uuid,
  p_store_id uuid,
  p_audit_domain text,
  p_audit_type text,
  p_audit_category text,
  p_actor_type text,
  p_actor_id uuid,
  p_subject_type text,
  p_subject_id uuid,
  p_decision text,
  p_decision_reason text default null,
  p_decision_payload jsonb default '{}'::jsonb,
  p_before_state jsonb default null,
  p_after_state jsonb default null,
  p_task_id uuid default null,
  p_event_id uuid default null,
  p_exception_id uuid default null,
  p_session_id uuid default null,
  p_order_id uuid default null,
  p_payment_id uuid default null,
  p_kds_ticket_id uuid default null,
  p_evidence_packet_id uuid default null,
  p_correlation_id text default null,
  p_request_id text default null,
  p_business_day date default current_date,
  p_business_timezone text default 'Asia/Seoul'
)
returns uuid
language plpgsql
security definer
set search_path = catchmenu_ledger, catchmenu_common, pg_catalog
as $$
declare
  v_id uuid;
begin
  -- input validation
  if p_tenant_id is null then
    raise exception 'tenant_id_required';
  end if;

  if trim(coalesce(p_audit_domain, '')) = '' then
    raise exception 'audit_domain_required';
  end if;

  if trim(coalesce(p_audit_type, '')) = '' then
    raise exception 'audit_type_required';
  end if;

  if trim(coalesce(p_actor_type, '')) = '' then
    raise exception 'actor_type_required';
  end if;

  if trim(coalesce(p_decision, '')) = '' then
    raise exception 'decision_required';
  end if;

  if jsonb_typeof(coalesce(p_decision_payload, '{}'::jsonb)) <> 'object' then
    raise exception 'decision_payload_must_be_object';
  end if;

  insert into catchmenu_ledger.audit_records (
    tenant_id,
    store_id,
    audit_domain,
    audit_type,
    audit_category,
    actor_type,
    actor_id,
    subject_type,
    subject_id,
    decision,
    decision_reason,
    decision_payload,
    before_state,
    after_state,
    task_id,
    event_id,
    exception_id,
    session_id,
    order_id,
    payment_id,
    kds_ticket_id,
    evidence_packet_id,
    correlation_id,
    request_id,
    business_day,
    business_timezone,
    decided_at,
    recorded_at
  ) values (
    p_tenant_id,
    p_store_id,
    lower(trim(p_audit_domain)),
    lower(trim(p_audit_type)),
    coalesce(p_audit_category, 'OPERATIONAL'),
    p_actor_type,
    p_actor_id,
    p_subject_type,
    p_subject_id,
    p_decision,
    p_decision_reason,
    coalesce(p_decision_payload, '{}'::jsonb),
    p_before_state,
    p_after_state,
    p_task_id,
    p_event_id,
    p_exception_id,
    p_session_id,
    p_order_id,
    p_payment_id,
    p_kds_ticket_id,
    p_evidence_packet_id,
    p_correlation_id,
    p_request_id,
    p_business_day,
    p_business_timezone,
    now(),
    now()
  )
  returning id into v_id;

  return v_id;
end;
$$;

revoke all on function catchmenu_audit.append_audit_record(
  uuid, uuid, text, text, text, text, uuid, text, uuid,
  text, text, jsonb, jsonb, jsonb, uuid, uuid, uuid, uuid,
  uuid, uuid, uuid, uuid, text, text, date, text
) from public;

grant execute on function catchmenu_audit.append_audit_record(
  uuid, uuid, text, text, text, text, uuid, text, uuid,
  text, text, jsonb, jsonb, jsonb, uuid, uuid, uuid, uuid,
  uuid, uuid, uuid, uuid, text, text, date, text
) to authenticated;

comment on function catchmenu_audit.append_audit_record(
  uuid, uuid, text, text, text, text, uuid, text, uuid,
  text, text, jsonb, jsonb, jsonb, uuid, uuid, uuid, uuid,
  uuid, uuid, uuid, uuid, text, text, date, text
) is
  'Single append-only audit insertion gateway for catchmenu operational OS.
   All domains must write audit records through this DEFINER function.
   Direct INSERT into catchmenu_ledger.audit_records is prohibited.
   Validates required fields and enforces audit record integrity.
   특허4: 감사 원장 단일 진입점 — 모든 고위험 액션의 책임 추적.';