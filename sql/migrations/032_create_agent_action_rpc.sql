-- 0032_create_agent_action_rpc.sql
-- Purpose: Agent action and approval lifecycle RPCs.
--          create_agent_action: records agent observation and recommendation.
--          request_approval: creates human approval request.
--          decide_approval: records human decision on approval request.
--          특허4 core: Human Authority Runtime — 관찰≠변경, 추천≠실행.
-- Depends on: 0031_create_exception_rpc.sql
-- Creates:
--   function catchmenu_agent.create_agent_action(...)
--   function catchmenu_agent.request_approval(...)
--   function catchmenu_agent.decide_approval(...)

create or replace function catchmenu_agent.create_agent_action(
  p_tenant_id uuid,
  p_store_id uuid,
  p_agent_id uuid,
  p_action_type text,
  p_action_domain text,
  p_recommendation_type text,
  p_recommendation_summary text,
  p_observation_summary text default null,
  p_observation_payload jsonb default '{}'::jsonb,
  p_recommendation_payload jsonb default '{}'::jsonb,
  p_confidence_score int default null,
  p_confidence_basis text default null,
  p_subject_type text default null,
  p_subject_id uuid default null,
  p_exception_id uuid default null,
  p_task_id uuid default null,
  p_session_id uuid default null,
  p_order_id uuid default null,
  p_kds_ticket_id uuid default null,
  p_recommended_sop_id uuid default null,
  p_requires_approval boolean default true,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_agent, catchmenu_ledger,
                  catchmenu_common, catchmenu_hq
as $$
declare
  v_action_id uuid;
  v_business_day date;
  v_timezone text;
begin
  -- store timezone
  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(v_timezone, now()))::date;

  -- validate agent exists and is active
  if not exists (
    select 1
    from catchmenu_store.agent_registry
    where id = p_agent_id
      and store_id = p_store_id
      and tenant_id = p_tenant_id
      and is_active = true
  ) then
    return jsonb_build_object(
      'success', false,
      'error_key', 'agent_not_found_or_inactive'
    );
  end if;

  -- validate confidence score
  if p_confidence_score is not null
    and p_confidence_score not between 0 and 100
  then
    return jsonb_build_object(
      'success', false,
      'error_key', 'invalid_confidence_score'
    );
  end if;

  -- create agent action
  insert into catchmenu_agent.agent_actions (
    tenant_id, store_id, agent_id,
    action_type, action_domain,
    action_status,
    observation_summary, observation_payload,
    recommendation_type, recommendation_summary,
    recommendation_payload,
    confidence_score, confidence_basis,
    subject_type, subject_id,
    exception_id, task_id,
    session_id, order_id, kds_ticket_id,
    recommended_sop_id,
    requires_approval,
    correlation_id,
    business_day, business_timezone
  ) values (
    p_tenant_id, p_store_id, p_agent_id,
    p_action_type, p_action_domain,
    case when p_requires_approval
      then 'AWAITING_APPROVAL'
      else 'PENDING'
    end,
    p_observation_summary,
    coalesce(p_observation_payload, '{}'::jsonb),
    p_recommendation_type, p_recommendation_summary,
    coalesce(p_recommendation_payload, '{}'::jsonb),
    p_confidence_score, p_confidence_basis,
    p_subject_type, p_subject_id,
    p_exception_id, p_task_id,
    p_session_id, p_order_id, p_kds_ticket_id,
    p_recommended_sop_id,
    p_requires_approval,
    p_correlation_id,
    v_business_day, v_timezone
  )
  returning id into v_action_id;

  -- update agent last_action_at
  update catchmenu_store.agent_registry
  set
    last_action_at = now(),
    updated_at = now()
  where id = p_agent_id;

  -- ledger event
  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, caused_by_agent_id,
    event_payload, correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'agent', 'agent_action_created', 1,
    'agent_action', v_action_id,
    null, case when p_requires_approval
      then 'AWAITING_APPROVAL'
      else 'PENDING'
    end,
    'AGENT', p_agent_id,
    jsonb_build_object(
      'action_type', p_action_type,
      'recommendation_type', p_recommendation_type,
      'confidence_score', p_confidence_score,
      'requires_approval', p_requires_approval
    ),
    p_correlation_id,
    v_business_day, v_timezone, now()
  );

  return jsonb_build_object(
    'success', true,
    'action_id', v_action_id,
    'action_status', case when p_requires_approval
      then 'AWAITING_APPROVAL'
      else 'PENDING'
    end,
    'requires_approval', p_requires_approval,
    'recommendation_type', p_recommendation_type,
    'confidence_score', p_confidence_score,
    'message_code', case when p_requires_approval
      then 'agent_action_awaiting_approval'
      else 'agent_action_pending'
    end
  );
end;
$$;


create or replace function catchmenu_agent.request_approval(
  p_tenant_id uuid,
  p_store_id uuid,
  p_action_id uuid,
  p_approval_type text,
  p_action_summary text,
  p_notified_to_type text,
  p_notified_to_id uuid,
  p_urgency_level text default 'NORMAL',
  p_risk_summary text default null,
  p_recommended_decision text default null,
  p_notification_channel text default 'APP_PUSH',
  p_auto_escalate_after_minutes int default null,
  p_sop_reference_id uuid default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_agent, catchmenu_ledger,
                  catchmenu_common, catchmenu_hq
as $$
declare
  v_approval_id uuid;
  v_action record;
  v_deadline_at timestamptz;
  v_business_day date;
  v_timezone text;
begin
  -- store timezone
  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(v_timezone, now()))::date;

  -- validate action exists
  select id, action_status, requires_approval
  into v_action
  from catchmenu_agent.agent_actions
  where id = p_action_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id;

  if v_action.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'action_not_found'
    );
  end if;

  if v_action.action_status not in (
    'PENDING', 'AWAITING_APPROVAL'
  ) then
    return jsonb_build_object(
      'success', false,
      'error_key', 'action_not_approvable',
      'current_status', v_action.action_status
    );
  end if;

  -- calculate deadline based on urgency
  v_deadline_at := now() + (
    case p_urgency_level
      when 'IMMEDIATE' then '2 minutes'
      when 'CRITICAL'  then '5 minutes'
      when 'HIGH'      then '15 minutes'
      when 'NORMAL'    then '60 minutes'
      when 'LOW'       then '240 minutes'
      else '60 minutes'
    end
  )::interval;

  -- create approval request
  insert into catchmenu_agent.agent_approvals (
    tenant_id, store_id, action_id,
    approval_type, urgency_level,
    approval_deadline_at,
    action_summary, risk_summary,
    recommended_decision,
    sop_reference_id,
    notified_to_type, notified_to_id,
    notified_at, notification_channel,
    approval_status,
    auto_escalate_after_minutes,
    correlation_id,
    business_day, business_timezone
  ) values (
    p_tenant_id, p_store_id, p_action_id,
    p_approval_type, p_urgency_level,
    v_deadline_at,
    p_action_summary, p_risk_summary,
    p_recommended_decision,
    p_sop_reference_id,
    p_notified_to_type, p_notified_to_id,
    now(), p_notification_channel,
    'NOTIFIED',
    p_auto_escalate_after_minutes,
    p_correlation_id,
    v_business_day, v_timezone
  )
  returning id into v_approval_id;

  -- update action with approval linkage
  update catchmenu_agent.agent_actions
  set
    approval_id = v_approval_id,
    action_status = 'AWAITING_APPROVAL',
    updated_at = now()
  where id = p_action_id;

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
    'agent', 'approval_requested', 1,
    'agent_approval', v_approval_id,
    null, 'NOTIFIED',
    'SYSTEM',
    jsonb_build_object(
      'approval_type', p_approval_type,
      'urgency_level', p_urgency_level,
      'notified_to_type', p_notified_to_type,
      'deadline_at', v_deadline_at
    ),
    p_correlation_id,
    v_business_day, v_timezone, now()
  );

  return jsonb_build_object(
    'success', true,
    'approval_id', v_approval_id,
    'approval_status', 'NOTIFIED',
    'urgency_level', p_urgency_level,
    'deadline_at', v_deadline_at,
    'notified_to_type', p_notified_to_type,
    'notification_channel', p_notification_channel,
    'message_code', 'approval_requested'
  );
end;
$$;


create or replace function catchmenu_agent.decide_approval(
  p_tenant_id uuid,
  p_store_id uuid,
  p_approval_id uuid,
  p_decision text,
  p_decided_by_type text,
  p_decided_by_id uuid,
  p_decision_note text default null,
  p_decision_payload jsonb default null,
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
  v_approval record;
  v_action record;
  v_new_action_status text;
  v_audit_id uuid;
begin
  if p_decision not in (
    'APPROVED', 'REJECTED',
    'MODIFIED_AND_APPROVED', 'DELEGATED'
  ) then
    return jsonb_build_object(
      'success', false,
      'error_key', 'invalid_decision'
    );
  end if;

  -- approval validation
  select id, action_id, approval_type,
         approval_status, urgency_level,
         action_summary, notified_to_type,
         business_day, business_timezone
  into v_approval
  from catchmenu_agent.agent_approvals
  where id = p_approval_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
  for update;

  if v_approval.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'approval_not_found'
    );
  end if;

  if v_approval.approval_status not in (
    'PENDING', 'NOTIFIED', 'UNDER_REVIEW'
  ) then
    return jsonb_build_object(
      'success', false,
      'error_key', 'approval_not_decidable',
      'current_status', v_approval.approval_status
    );
  end if;

  -- determine new approval status
  v_new_action_status := case p_decision
    when 'APPROVED' then 'APPROVED'
    when 'MODIFIED_AND_APPROVED' then 'APPROVED'
    when 'REJECTED' then 'REJECTED'
    when 'DELEGATED' then 'DELEGATED'
  end;

  -- update approval
  update catchmenu_agent.agent_approvals
  set
    approval_status = case p_decision
      when 'APPROVED' then 'APPROVED'
      when 'MODIFIED_AND_APPROVED' then 'MODIFIED_AND_APPROVED'
      when 'REJECTED' then 'REJECTED'
      when 'DELEGATED' then 'ESCALATED'
    end,
    decided_by_type = p_decided_by_type,
    decided_by_id = p_decided_by_id,
    decided_at = now(),
    decision_note = p_decision_note,
    decision_payload = p_decision_payload,
    updated_at = now()
  where id = p_approval_id;

  -- update action status
  update catchmenu_agent.agent_actions
  set
    action_status = case p_decision
      when 'APPROVED' then 'APPROVED'
      when 'MODIFIED_AND_APPROVED' then 'APPROVED'
      when 'REJECTED' then 'REJECTED'
      when 'DELEGATED' then 'DELEGATED'
    end,
    manager_feedback = p_decision,
    feedback_recorded_at = now(),
    updated_at = now()
  where id = v_approval.action_id;

  -- get action for AI feedback
  select id, action_type, action_domain,
         recommendation_type, confidence_score
  into v_action
  from catchmenu_agent.agent_actions
  where id = v_approval.action_id;

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
    'agent', 'approval_decided', 1,
    'agent_approval', p_approval_id,
    v_approval.approval_status,
    case p_decision
      when 'APPROVED' then 'APPROVED'
      when 'MODIFIED_AND_APPROVED' then 'MODIFIED_AND_APPROVED'
      when 'REJECTED' then 'REJECTED'
      when 'DELEGATED' then 'ESCALATED'
    end,
    p_decided_by_type, p_decided_by_id,
    jsonb_build_object(
      'decision', p_decision,
      'decision_note', p_decision_note,
      'approval_type', v_approval.approval_type,
      'action_type', v_action.action_type,
      'confidence_score', v_action.confidence_score
    ),
    p_correlation_id,
    v_approval.business_day, v_approval.business_timezone, now()
  );

  -- audit record
  -- 특허4: 관리자 승인/거절 반응 → Audit 원장에 축적 → AI 학습 신호
  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := v_action.action_domain,
    p_audit_type := 'agent_approval_decided',
    p_audit_category := 'OPERATIONAL',
    p_actor_type := p_decided_by_type,
    p_actor_id := p_decided_by_id,
    p_subject_type := 'agent_approval',
    p_subject_id := p_approval_id,
    p_decision := case p_decision
      when 'APPROVED' then 'APPROVED'
      when 'MODIFIED_AND_APPROVED' then 'OVERRIDDEN'
      when 'REJECTED' then 'REJECTED'
      when 'DELEGATED' then 'DELEGATED'
    end,
    p_decision_reason := p_decision_note,
    p_decision_payload := jsonb_build_object(
      'approval_type', v_approval.approval_type,
      'action_type', v_action.action_type,
      'recommendation_type', v_action.recommendation_type,
      'confidence_score', v_action.confidence_score,
      'manager_decision', p_decision,
      'decision_payload', p_decision_payload
    ),
    p_before_state := jsonb_build_object(
      'approval_status', v_approval.approval_status,
      'action_status', 'AWAITING_APPROVAL'
    ),
    p_after_state := jsonb_build_object(
      'approval_status', p_decision,
      'action_status', v_new_action_status
    ),
    p_correlation_id := p_correlation_id,
    p_business_day := v_approval.business_day,
    p_business_timezone := v_approval.business_timezone
  );

  return jsonb_build_object(
    'success', true,
    'approval_id', p_approval_id,
    'action_id', v_approval.action_id,
    'decision', p_decision,
    'approval_status', case p_decision
      when 'APPROVED' then 'APPROVED'
      when 'MODIFIED_AND_APPROVED' then 'MODIFIED_AND_APPROVED'
      when 'REJECTED' then 'REJECTED'
      when 'DELEGATED' then 'ESCALATED'
    end,
    'action_status', v_new_action_status,
    'decided_at', now(),
    'audit_id', v_audit_id,
    'ai_feedback_recorded', true,
    'message_code', case p_decision
      when 'APPROVED' then 'approval_approved'
      when 'MODIFIED_AND_APPROVED'
        then 'approval_modified_and_approved'
      when 'REJECTED' then 'approval_rejected'
      when 'DELEGATED' then 'approval_delegated'
    end
  );
end;
$$;

-- grants
do $$
begin
  revoke all on function catchmenu_agent.create_agent_action(
    uuid, uuid, uuid, text, text, text, text,
    text, jsonb, jsonb, int, text, text, uuid,
    uuid, uuid, uuid, uuid, uuid, uuid, boolean, text
  ) from public;
  grant execute on function catchmenu_agent.create_agent_action(
    uuid, uuid, uuid, text, text, text, text,
    text, jsonb, jsonb, int, text, text, uuid,
    uuid, uuid, uuid, uuid, uuid, uuid, boolean, text
  ) to authenticated;

  revoke all on function catchmenu_agent.request_approval(
    uuid, uuid, uuid, text, text, text, uuid,
    text, text, text, text, int, uuid, text
  ) from public;
  grant execute on function catchmenu_agent.request_approval(
    uuid, uuid, uuid, text, text, text, uuid,
    text, text, text, text, int, uuid, text
  ) to authenticated;

  revoke all on function catchmenu_agent.decide_approval(
    uuid, uuid, uuid, text, text, uuid, text, jsonb, text
  ) from public;
  grant execute on function catchmenu_agent.decide_approval(
    uuid, uuid, uuid, text, text, uuid, text, jsonb, text
  ) to authenticated;
end;
$$;

comment on function catchmenu_agent.create_agent_action(
  uuid, uuid, uuid, text, text, text, text,
  text, jsonb, jsonb, int, text, text, uuid,
  uuid, uuid, uuid, uuid, uuid, uuid, boolean, text
) is
  'Records agent observation and recommendation.
   Agents NEVER mutate business state directly.
   Every recommendation goes through approval before execution.
   manager_feedback is the AI learning signal.
   특허4: 관찰(observe) ≠ 변경(change), 추천(recommend) ≠ 실행(execute).
   Agent ≠ Operator. 최종 책임은 관리자에게 귀속.';

comment on function catchmenu_agent.request_approval(
  uuid, uuid, uuid, text, text, text, uuid,
  text, text, text, text, int, uuid, text
) is
  'Creates human approval request for agent recommendation.
   Deadline calculated automatically from urgency level.
   IMMEDIATE = 2min, CRITICAL = 5min, HIGH = 15min,
   NORMAL = 60min, LOW = 240min.
   특허4: Human Authority Runtime — 사람이 판단/승인/실행 책임.';

comment on function catchmenu_agent.decide_approval(
  uuid, uuid, uuid, text, text, uuid, text, jsonb, text
) is
  'Records human decision on agent approval request.
   Writes audit record with full decision context.
   manager_feedback stored on agent_action for AI learning.
   특허4: Logical AI 운영 결정 메시지에 대한 관리자 반응
          → Audit 원장 축적 → 후속 결정 메시지 생성에 반영.';