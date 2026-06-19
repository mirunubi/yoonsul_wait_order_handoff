-- 0007_create_ledger_exception.sql
-- Purpose: Exception ledger. Records all anomalies, failures, and degraded states.
--          Exceptions are the "what went wrong" layer.
--          AI learns from this ledger to improve operational resilience.
--          특허4 core: Exception 원장 기반 AI 학습 데이터 축적.
-- Depends on: 0006_create_ledger_event.sql
-- Creates:
--   catchmenu_ledger.exceptions

create table if not exists catchmenu_ledger.exceptions (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references catchmenu_hq.tenants(id),
  store_id uuid not null references catchmenu_hq.stores(id),

  -- exception identity
  exception_code text not null,
  exception_domain text not null,
  exception_type text not null,
  exception_severity text not null default 'WARNING',
  exception_status text not null default 'OPEN',

  -- what triggered this
  subject_type text,
  subject_id uuid,
  triggered_by_event_id uuid references catchmenu_ledger.events(id),
  triggered_by_task_id uuid references catchmenu_ledger.tasks(id),
  triggered_by_device_id uuid references catchmenu_store.device_registry(id),
  triggered_by_agent_id uuid references catchmenu_store.agent_registry(id),

  -- exception detail
  exception_payload jsonb not null default '{}'::jsonb,
  error_code text,
  error_message text,
  stack_context jsonb,

  -- detection
  detected_at timestamptz not null default now(),
  first_occurred_at timestamptz not null default now(),
  last_occurred_at timestamptz not null default now(),
  occurrence_count int not null default 1,

  -- resolution
  resolved_at timestamptz,
  resolution_type text,
  resolution_note text,
  resolved_by_type text,
  resolved_by_id uuid,

  -- escalation
  escalated_at timestamptz,
  escalated_to text,
  requires_human_approval boolean not null default false,
  human_approved_at timestamptz,
  human_approved_by uuid,

  -- impact
  affected_orders_count int,
  affected_sessions_count int,
  estimated_revenue_impact int,

  -- sop linkage
  recommended_sop_id uuid,
  applied_sop_id uuid,

  -- correlation
  correlation_id text,
  parent_exception_id uuid references catchmenu_ledger.exceptions(id),

  -- business day snapshot
  business_day date not null,
  business_timezone text not null default 'Asia/Seoul',

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint chk_exception_domain check (
    exception_domain in (
      'order',
      'payment',
      'kds',
      'session',
      'delivery',
      'inventory',
      'staff',
      'pos',
      'kiosk',
      'did',
      'network',
      'database',
      'agent',
      'provider',
      'gateway',
      'system'
    )
  ),
  constraint chk_exception_severity check (
    exception_severity in (
      'INFO',
      'WARNING',
      'ERROR',
      'CRITICAL',
      'FATAL'
    )
  ),
  constraint chk_exception_status check (
    exception_status in (
      'OPEN',
      'ACKNOWLEDGED',
      'IN_RECOVERY',
      'RESOLVED',
      'ESCALATED',
      'SUPPRESSED',
      'CLOSED'
    )
  ),
  constraint chk_exception_resolution_type check (
    resolution_type is null or resolution_type in (
      'AUTO_RECOVERED',
      'AGENT_RECOVERED',
      'MANUAL_STAFF',
      'MANUAL_MANAGER',
      'SOP_APPLIED',
      'ESCALATED_HQ',
      'TIMEOUT_CLOSED',
      'WONT_FIX'
    )
  ),
  constraint chk_exception_payload_object check (
    jsonb_typeof(exception_payload) = 'object'
  ),
  constraint chk_occurrence_count check (occurrence_count >= 1),
  constraint chk_revenue_impact check (
    estimated_revenue_impact is null
    or estimated_revenue_impact >= 0
  )
);

create index if not exists idx_exceptions_store_domain_status
  on catchmenu_ledger.exceptions(store_id, exception_domain, exception_status);

create index if not exists idx_exceptions_store_severity
  on catchmenu_ledger.exceptions(store_id, exception_severity)
  where exception_status in ('OPEN', 'ACKNOWLEDGED', 'IN_RECOVERY', 'ESCALATED');

create index if not exists idx_exceptions_subject
  on catchmenu_ledger.exceptions(subject_type, subject_id)
  where subject_id is not null;

create index if not exists idx_exceptions_store_business_day
  on catchmenu_ledger.exceptions(store_id, business_day desc);

create index if not exists idx_exceptions_correlation
  on catchmenu_ledger.exceptions(correlation_id)
  where correlation_id is not null;

create index if not exists idx_exceptions_parent
  on catchmenu_ledger.exceptions(parent_exception_id)
  where parent_exception_id is not null;

create index if not exists idx_exceptions_requires_approval
  on catchmenu_ledger.exceptions(store_id, requires_human_approval)
  where requires_human_approval = true
    and exception_status not in ('RESOLVED', 'CLOSED');

drop trigger if exists trg_exceptions_updated_at
  on catchmenu_ledger.exceptions;
create trigger trg_exceptions_updated_at
  before update on catchmenu_ledger.exceptions
  for each row execute function catchmenu_common.set_updated_at();

comment on table catchmenu_ledger.exceptions is
  'Exception ledger. Records all anomalies, failures, and degraded operational states.
   This is the primary AI learning data source for operational resilience.
   Exceptions capture what the transaction ledger cannot:
   cooking delays, packaging bottlenecks, stock-out candidates,
   POS/KDS/Kiosk/network/DB/agent failures, recovery outcomes,
   manager approvals and rejections, manual overrides.
   특허4: 예외·복구·승인·감사 데이터를 AI가 학습 가능한 원장 구조로 변환.';
comment on column catchmenu_ledger.exceptions.exception_type is
  'Specific exception category. Examples:
   order: cooking_delay, packaging_bottleneck, order_timeout
   payment: payment_uncertain, duplicate_payment_risk, reconciliation_mismatch
   kds: kds_overload, kds_transmission_failed, kds_hold_timeout
   pos: pos_offline, pos_callback_failed, pos_replay_detected
   network: network_disconnected, network_degraded, sync_failed
   database: db_unreachable, write_failed, replay_conflict
   agent: agent_module_failed, agent_isolated, supervisor_failed
   provider: provider_timeout, provider_response_invalid, webhook_unverified';
comment on column catchmenu_ledger.exceptions.occurrence_count is
  'How many times this exception has occurred.
   Repeated exceptions trigger Knowledge Gap detection in 특허3.
   Threshold-based escalation uses this count.';
comment on column catchmenu_ledger.exceptions.resolution_type is
  'How the exception was resolved.
   AUTO_RECOVERED = system self-healed without human action.
   AGENT_RECOVERED = agent executed approved recovery procedure.
   MANUAL_STAFF = staff manually resolved at store level.
   MANUAL_MANAGER = manager intervened and resolved.
   SOP_APPLIED = standard SOP was applied and succeeded.
   ESCALATED_HQ = escalated to HQ and closed there.
   TIMEOUT_CLOSED = closed after no resolution within deadline.
   WONT_FIX = acknowledged but will not be resolved.';
comment on column catchmenu_ledger.exceptions.recommended_sop_id is
  'SOP recommended by agent at time of detection.
   Links to catchmenu_knowledge.documents.
   특허3: Knowledge Gap detection triggers SOP Evolution Agent.';
comment on column catchmenu_ledger.exceptions.requires_human_approval is
  'True when agent cannot auto-resolve and human decision is required.
   특허4 principle: agents recommend, humans approve.';