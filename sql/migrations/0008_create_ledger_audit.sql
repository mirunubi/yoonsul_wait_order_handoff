-- 0008_create_ledger_audit.sql
-- Purpose: Audit ledger. Records all decisions, approvals, rejections,
--          overrides, and accountability evidence.
--          Append-only. No UPDATE or DELETE ever.
--          This is the "who decided what and why" layer.
--          특허4 core: Audit 원장 기반 판단·책임 추적.
-- Depends on: 0007_create_ledger_exception.sql
-- Creates:
--   catchmenu_ledger.audit_records

create table if not exists catchmenu_ledger.audit_records (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references catchmenu_hq.tenants(id),
  store_id uuid references catchmenu_hq.stores(id),

  -- audit identity
  audit_domain text not null,
  audit_type text not null,
  audit_category text not null default 'OPERATIONAL',

  -- actor (who made the decision)
  actor_type text not null,
  actor_id uuid,
  actor_device_id uuid references catchmenu_store.device_registry(id),
  actor_agent_id uuid references catchmenu_store.agent_registry(id),
  actor_display_name text,

  -- subject (what was decided upon)
  subject_type text,
  subject_id uuid,

  -- decision
  decision text not null,
  decision_reason text,
  decision_payload jsonb not null default '{}'::jsonb,

  -- before/after state snapshot
  before_state jsonb,
  after_state jsonb,

  -- linked records
  task_id uuid references catchmenu_ledger.tasks(id),
  event_id uuid references catchmenu_ledger.events(id),
  exception_id uuid references catchmenu_ledger.exceptions(id),
  session_id uuid,
  order_id uuid,
  payment_id uuid,
  kds_ticket_id uuid,
  provider_event_id text,

  -- evidence
  evidence_packet_id uuid,
  sop_reference_id uuid,
  idempotency_key text,
  correlation_id text,
  request_id text,

  -- business day snapshot
  business_day date not null,
  business_timezone text not null default 'Asia/Seoul',
  decided_at timestamptz not null default now(),
  recorded_at timestamptz not null default now(),

  constraint chk_audit_domain check (
    audit_domain in (
      'order',
      'payment',
      'kds',
      'session',
      'delivery',
      'inventory',
      'staff',
      'device',
      'agent',
      'recovery',
      'knowledge',
      'gateway',
      'security',
      'system'
    )
  ),
  constraint chk_audit_category check (
    audit_category in (
      'OPERATIONAL',
      'FINANCIAL',
      'SECURITY',
      'COMPLIANCE',
      'RECOVERY',
      'KNOWLEDGE'
    )
  ),
  constraint chk_audit_actor_type check (
    actor_type in (
      'SYSTEM',
      'AGENT',
      'STAFF',
      'MANAGER',
      'OWNER',
      'HQ_ADMIN',
      'CUSTOMER',
      'PROVIDER',
      'SCHEDULER'
    )
  ),
  constraint chk_audit_decision check (
    decision in (
      'APPROVED',
      'REJECTED',
      'OVERRIDDEN',
      'DELEGATED',
      'ESCALATED',
      'CANCELLED',
      'COMPLETED',
      'FAILED',
      'NOTED',
      'SUSPENDED',
      'REVOKED'
    )
  ),
  constraint chk_audit_payload_object check (
    jsonb_typeof(decision_payload) = 'object'
  ),
  constraint chk_audit_before_object check (
    before_state is null
    or jsonb_typeof(before_state) = 'object'
  ),
  constraint chk_audit_after_object check (
    after_state is null
    or jsonb_typeof(after_state) = 'object'
  )
);

create index if not exists idx_audit_store_domain
  on catchmenu_ledger.audit_records(store_id, audit_domain);

create index if not exists idx_audit_store_category
  on catchmenu_ledger.audit_records(store_id, audit_category, decided_at desc);

create index if not exists idx_audit_actor
  on catchmenu_ledger.audit_records(actor_type, actor_id, decided_at desc)
  where actor_id is not null;

create index if not exists idx_audit_subject
  on catchmenu_ledger.audit_records(subject_type, subject_id, decided_at desc)
  where subject_id is not null;

create index if not exists idx_audit_session
  on catchmenu_ledger.audit_records(session_id, decided_at desc)
  where session_id is not null;

create index if not exists idx_audit_order
  on catchmenu_ledger.audit_records(order_id, decided_at desc)
  where order_id is not null;

create index if not exists idx_audit_payment
  on catchmenu_ledger.audit_records(payment_id, decided_at desc)
  where payment_id is not null;

create index if not exists idx_audit_kds_ticket
  on catchmenu_ledger.audit_records(kds_ticket_id, decided_at desc)
  where kds_ticket_id is not null;

create index if not exists idx_audit_exception
  on catchmenu_ledger.audit_records(exception_id)
  where exception_id is not null;

create index if not exists idx_audit_store_business_day
  on catchmenu_ledger.audit_records(store_id, business_day desc);

create index if not exists idx_audit_correlation
  on catchmenu_ledger.audit_records(correlation_id)
  where correlation_id is not null;

create index if not exists idx_audit_financial
  on catchmenu_ledger.audit_records(store_id, decided_at desc)
  where audit_category = 'FINANCIAL';

comment on table catchmenu_ledger.audit_records is
  'Audit ledger. Append-only record of all decisions, approvals, rejections,
   overrides, and accountability evidence in the operational OS.
   This answers: who decided what, when, why, and with what authority.
   Every high-risk action must produce an audit record:
   payment approval, KDS release, agent recovery, staff override,
   manager approval, SOP application, device trust change,
   knowledge document publication.
   No UPDATE or DELETE is ever permitted on this table.
   특허4 core: Audit 원장 = 판단과 책임 추적의 불변 기록.';
comment on column catchmenu_ledger.audit_records.audit_type is
  'Specific audit event. Examples:
   payment: payment_approved, payment_cancelled, refund_authorized
   kds: kds_release_approved, kds_hold_overridden, manual_fallback_activated
   agent: agent_recommendation_approved, agent_recommendation_rejected,
          agent_action_overridden, agent_isolated
   recovery: recovery_sop_applied, manual_recovery_completed,
             event_replay_executed, local_ledger_synced
   security: device_trust_granted, device_trust_revoked,
             gateway_request_blocked, signature_verification_failed
   knowledge: sop_draft_approved, sop_draft_rejected, sop_published';
comment on column catchmenu_ledger.audit_records.decision is
  'APPROVED = actor approved the action or recommendation.
   REJECTED = actor rejected the action or recommendation.
   OVERRIDDEN = actor overrode system or agent decision.
   DELEGATED = actor delegated decision to another party.
   ESCALATED = actor escalated to higher authority.
   CANCELLED = action was cancelled before completion.
   COMPLETED = action completed successfully.
   FAILED = action failed after attempt.
   NOTED = acknowledgement without action.
   SUSPENDED = subject was suspended pending review.
   REVOKED = previously granted permission was revoked.';
comment on column catchmenu_ledger.audit_records.before_state is
  'Snapshot of subject state before the decision.
   Used for reconciliation and dispute evidence.';
comment on column catchmenu_ledger.audit_records.after_state is
  'Snapshot of subject state after the decision.
   Together with before_state, provides full state transition evidence.';
comment on column catchmenu_ledger.audit_records.evidence_packet_id is
  'Links to evidence_packets table for high-risk financial or security actions.
   Payment cancellation, refund, and KDS override must have evidence packets.';
comment on column catchmenu_ledger.audit_records.decided_at is
  'When the decision was made in real time.
   May differ from recorded_at during replay or delayed sync scenarios.';