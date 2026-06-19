-- 0018_create_agent_actions_approvals.sql
-- Purpose: Agent action log and human approval queue.
--          Agents observe and recommend. Humans approve and execute.
--          Every agent recommendation must be explicitly approved or rejected.
--          특허4 core: 관찰≠변경, 추천≠실행, 증거≠승인, Agent≠Operator.
-- Depends on: 0017_create_evidence_and_fallback.sql
-- Creates:
--   catchmenu_agent.agent_actions
--   catchmenu_agent.agent_approvals

create table if not exists catchmenu_agent.agent_actions (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references catchmenu_hq.tenants(id),
  store_id uuid not null references catchmenu_hq.stores(id),
  agent_id uuid not null references catchmenu_store.agent_registry(id),

  -- action identity
  action_type text not null,
  action_domain text not null,
  action_status text not null default 'PENDING',

  -- what the agent observed
  observation_summary text,
  observation_payload jsonb not null default '{}'::jsonb,

  -- what the agent recommends
  recommendation_type text not null,
  recommendation_summary text not null,
  recommendation_payload jsonb not null default '{}'::jsonb,
  recommended_sop_id uuid,

  -- confidence
  confidence_score int,
  confidence_basis text,

  -- subject
  subject_type text,
  subject_id uuid,

  -- linked records
  exception_id uuid references catchmenu_ledger.exceptions(id),
  task_id uuid references catchmenu_ledger.tasks(id),
  session_id uuid,
  order_id uuid,
  kds_ticket_id uuid references catchmenu_kds.kds_tickets(id),
  fallback_log_id uuid references catchmenu_agent.manual_fallback_log(id),

  -- approval linkage
  approval_id uuid,
  requires_approval boolean not null default true,

  -- execution result (after approval)
  executed_at timestamptz,
  execution_result text,
  execution_payload jsonb,
  execution_failed_reason text,

  -- ai learning feedback
  -- 특허4: Logical AI 운영 결정 메시지 + 관리자 반응 피드백 학습
  manager_feedback text,
  feedback_recorded_at timestamptz,

  -- correlation
  correlation_id text,
  business_day date not null,
  business_timezone text not null default 'Asia/Seoul',

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint chk_agent_action_type check (
    action_type in (
      'FAULT_DETECTED',
      'EXCEPTION_CLASSIFIED',
      'SOP_RECOMMENDED',
      'KDS_CAPACITY_EVALUATED',
      'KDS_COMMIT_RECOMMENDED',
      'KDS_HOLD_RECOMMENDED',
      'RECOVERY_INITIATED',
      'SYNC_COMPLETED',
      'KNOWLEDGE_GAP_DETECTED',
      'SOP_DRAFT_GENERATED',
      'DEVICE_ISOLATED',
      'DEVICE_RECOVERED',
      'PAYMENT_UNCERTAIN_FLAGGED',
      'RECONCILIATION_MISMATCH_FLAGGED',
      'PHYSICAL_AI_TASK_TRANSLATED'
    )
  ),
  constraint chk_agent_action_domain check (
    action_domain in (
      'order', 'payment', 'kds', 'session',
      'device', 'recovery', 'knowledge',
      'gateway', 'security', 'system'
    )
  ),
  constraint chk_agent_action_status check (
    action_status in (
      'PENDING',
      'AWAITING_APPROVAL',
      'APPROVED',
      'REJECTED',
      'EXECUTING',
      'COMPLETED',
      'FAILED',
      'CANCELLED',
      'DELEGATED'
    )
  ),
  constraint chk_agent_recommendation_type check (
    recommendation_type in (
      'APPLY_SOP',
      'NOTIFY_STAFF',
      'NOTIFY_MANAGER',
      'ESCALATE_HQ',
      'HOLD_KDS_TICKET',
      'COMMIT_KDS_TICKET',
      'ACTIVATE_FALLBACK',
      'INITIATE_RECOVERY',
      'ISOLATE_DEVICE',
      'BLOCK_GATEWAY_SESSION',
      'FLAG_PAYMENT_UNCERTAIN',
      'CREATE_EVIDENCE_PACKET',
      'GENERATE_SOP_DRAFT',
      'TRANSLATE_TO_PHYSICAL_AI'
    )
  ),
  constraint chk_agent_confidence check (
    confidence_score is null
    or confidence_score between 0 and 100
  ),
  constraint chk_observation_object check (
    jsonb_typeof(observation_payload) = 'object'
  ),
  constraint chk_recommendation_object check (
    jsonb_typeof(recommendation_payload) = 'object'
  ),
  constraint chk_execution_object check (
    execution_payload is null
    or jsonb_typeof(execution_payload) = 'object'
  )
);

create index if not exists idx_agent_actions_store_status
  on catchmenu_agent.agent_actions(store_id, action_status);

create index if not exists idx_agent_actions_agent
  on catchmenu_agent.agent_actions(agent_id, created_at desc);

create index if not exists idx_agent_actions_domain
  on catchmenu_agent.agent_actions(store_id, action_domain, created_at desc);

create index if not exists idx_agent_actions_awaiting
  on catchmenu_agent.agent_actions(store_id, created_at desc)
  where action_status = 'AWAITING_APPROVAL';

create index if not exists idx_agent_actions_exception
  on catchmenu_agent.agent_actions(exception_id)
  where exception_id is not null;

create index if not exists idx_agent_actions_kds_ticket
  on catchmenu_agent.agent_actions(kds_ticket_id)
  where kds_ticket_id is not null;

create index if not exists idx_agent_actions_business_day
  on catchmenu_agent.agent_actions(store_id, business_day desc);

drop trigger if exists trg_agent_actions_updated_at
  on catchmenu_agent.agent_actions;
create trigger trg_agent_actions_updated_at
  before update on catchmenu_agent.agent_actions
  for each row execute function catchmenu_common.set_updated_at();

comment on table catchmenu_agent.agent_actions is
  'Agent action and recommendation log.
   Every agent observation and recommendation is recorded here.
   Agents NEVER execute without human approval (requires_approval = true by default).
   Exception: auto-recovery agents may execute low-risk recovery actions
   when pre-approved by manager standing policy.
   특허4 핵심 원칙:
   관찰(observe) ≠ 변경(change)
   추천(recommend) ≠ 실행(execute)
   증거(evidence) ≠ 승인(approval)
   Agent ≠ Operator
   최종 승인과 책임은 관리자 또는 점주에게 귀속된다.';
comment on column catchmenu_agent.agent_actions.confidence_score is
  'Agent confidence in recommendation. 0-100.
   Low confidence actions require explicit manager approval.
   High confidence routine actions may use standing approval policy.';
comment on column catchmenu_agent.agent_actions.manager_feedback is
  'APPROVED / REJECTED / MODIFIED + reason.
   This feedback is the AI learning signal.
   특허4: Logical AI가 생성한 운영 결정 메시지에 대한
          관리자의 승인/거절/수정 반응을 Audit 원장에 축적.';


create table if not exists catchmenu_agent.agent_approvals (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references catchmenu_hq.tenants(id),
  store_id uuid not null references catchmenu_hq.stores(id),
  action_id uuid not null references catchmenu_agent.agent_actions(id),

  -- approval request
  approval_type text not null,
  urgency_level text not null default 'NORMAL',
  approval_deadline_at timestamptz,

  -- what needs approval
  action_summary text not null,
  risk_summary text,
  recommended_decision text,
  sop_reference_id uuid,

  -- notification
  notified_to_type text not null,
  notified_to_id uuid,
  notified_at timestamptz not null default now(),
  notification_channel text not null default 'APP_PUSH',
  reminder_sent_at timestamptz,

  -- decision
  approval_status text not null default 'PENDING',
  decided_by_type text,
  decided_by_id uuid,
  decided_at timestamptz,
  decision_note text,
  decision_payload jsonb,

  -- escalation
  escalated_at timestamptz,
  escalated_to_type text,
  escalated_to_id uuid,
  escalation_reason text,
  auto_escalate_after_minutes int,

  -- evidence
  evidence_packet_id uuid references catchmenu_agent.evidence_packets(id),
  audit_record_id uuid references catchmenu_ledger.audit_records(id),

  -- correlation
  correlation_id text,
  business_day date not null,
  business_timezone text not null default 'Asia/Seoul',

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint chk_approval_type check (
    approval_type in (
      'KDS_RELEASE_OVERRIDE',
      'PAYMENT_UNCERTAIN_RESOLUTION',
      'RECOVERY_EXECUTION',
      'FALLBACK_ACTIVATION',
      'DEVICE_ISOLATION',
      'GATEWAY_BLOCK',
      'RECONCILIATION_WRITEOFF',
      'SOP_PUBLICATION',
      'AGENT_SCOPE_EXPANSION',
      'PHYSICAL_AI_TASK_EXECUTION',
      'EXCEPTION_ESCALATION',
      'MANUAL_CORRECTION'
    )
  ),
  constraint chk_approval_urgency check (
    urgency_level in (
      'LOW',
      'NORMAL',
      'HIGH',
      'CRITICAL',
      'IMMEDIATE'
    )
  ),
  constraint chk_approval_status check (
    approval_status in (
      'PENDING',
      'NOTIFIED',
      'UNDER_REVIEW',
      'APPROVED',
      'REJECTED',
      'MODIFIED_AND_APPROVED',
      'ESCALATED',
      'TIMED_OUT',
      'CANCELLED'
    )
  ),
  constraint chk_approval_notified_to check (
    notified_to_type in (
      'STAFF', 'MANAGER', 'OWNER',
      'HQ_ADMIN', 'SUPPORT'
    )
  ),
  constraint chk_approval_notification_channel check (
    notification_channel in (
      'APP_PUSH',
      'IN_APP',
      'SMS',
      'EMAIL',
      'KDS_ALERT',
      'DID_ALERT'
    )
  ),
  constraint chk_decision_payload_object check (
    decision_payload is null
    or jsonb_typeof(decision_payload) = 'object'
  )
);

create index if not exists idx_agent_approvals_store_status
  on catchmenu_agent.agent_approvals(store_id, approval_status);

create index if not exists idx_agent_approvals_pending
  on catchmenu_agent.agent_approvals(store_id, urgency_level, created_at desc)
  where approval_status in ('PENDING', 'NOTIFIED', 'UNDER_REVIEW');

create index if not exists idx_agent_approvals_action
  on catchmenu_agent.agent_approvals(action_id);

create index if not exists idx_agent_approvals_notified_to
  on catchmenu_agent.agent_approvals(notified_to_id, approval_status)
  where notified_to_id is not null;

create index if not exists idx_agent_approvals_deadline
  on catchmenu_agent.agent_approvals(approval_deadline_at)
  where approval_status in ('PENDING', 'NOTIFIED')
    and approval_deadline_at is not null;

create index if not exists idx_agent_approvals_business_day
  on catchmenu_agent.agent_approvals(store_id, business_day desc);

drop trigger if exists trg_agent_approvals_updated_at
  on catchmenu_agent.agent_approvals;
create trigger trg_agent_approvals_updated_at
  before update on catchmenu_agent.agent_approvals
  for each row execute function catchmenu_common.set_updated_at();

comment on table catchmenu_agent.agent_approvals is
  'Human approval queue for agent recommendations.
   Every high-risk agent action requires explicit human decision.
   특허4: Human Authority Runtime.
   판단(Decide) / 승인(Authorize) / 실행(Execute) / 소유(Own)
   사람(점주/매니저/점장)이 최종 판단·승인·실행 책임을 보유.
   Approval flow:
     Agent detects → creates agent_action →
     creates agent_approval → notifies human →
     human decides → audit_record created →
     action executed (if approved).';
comment on column catchmenu_agent.agent_approvals.urgency_level is
  'IMMEDIATE = payment uncertain, KDS blocked, active customer impact.
   CRITICAL = device contamination suspect, financial discrepancy.
   HIGH = fallback activation, reconciliation mismatch.
   NORMAL = SOP recommendation, routine recovery.
   LOW = knowledge gap detection, non-urgent optimization.';
comment on column catchmenu_agent.agent_approvals.auto_escalate_after_minutes is
  'Minutes before auto-escalating to next authority level.
   IMMEDIATE urgency: 2 minutes.
   CRITICAL: 5 minutes.
   HIGH: 15 minutes.
   NORMAL: 60 minutes.
   Null = no auto-escalation.';
comment on column catchmenu_agent.agent_approvals.approval_status is
  'TIMED_OUT = deadline passed without decision.
   Auto-escalates to manager or HQ depending on urgency.
   MODIFIED_AND_APPROVED = approved with changes to recommendation.
   Changes are recorded in decision_payload and decision_note.';