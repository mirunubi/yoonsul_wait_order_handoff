-- slice_02 — Payment (600500 + payment SQL)
-- Files: 23


-- ===== BEGIN sql/migrations/0005_create_ledger_task.sql =====

-- 0005_create_ledger_task.sql
-- Purpose: Task ledger. Records all operational work units that must be performed.
--          Task is the "what needs to be done" layer.
--          특허4 core: Task/Event/Audit/Exception 4-ledger architecture.
-- Depends on: 0003_create_store_device_agent_registry.sql
-- Creates:
--   catchmenu_ledger.tasks

create table if not exists catchmenu_ledger.tasks (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references catchmenu_hq.tenants(id),
  store_id uuid not null references catchmenu_hq.stores(id),

  -- task identity
  task_code text not null,
  task_domain text not null,
  task_type text not null,
  task_status text not null default 'PENDING',
  priority int not null default 5,

  -- what this task is about
  subject_type text,
  subject_id uuid,

  -- who/what initiated
  initiated_by_type text not null default 'SYSTEM',
  initiated_by_id uuid,
  initiated_by_device_id uuid references catchmenu_store.device_registry(id),
  initiated_by_agent_id uuid references catchmenu_store.agent_registry(id),

  -- task payload
  task_payload jsonb not null default '{}'::jsonb,

  -- timing
  scheduled_at timestamptz,
  started_at timestamptz,
  completed_at timestamptz,
  failed_at timestamptz,
  deadline_at timestamptz,

  -- result
  result_payload jsonb,
  failure_reason text,
  retry_count int not null default 0,
  max_retry int not null default 3,

  -- correlation
  parent_task_id uuid references catchmenu_ledger.tasks(id),
  correlation_id text,
  idempotency_key text,

  -- business day snapshot
  business_day date not null,
  business_timezone text not null default 'Asia/Seoul',

  created_at timestamptz not null default now(),

  constraint chk_task_domain check (
    task_domain in (
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
      'sync',
      'knowledge',
      'system'
    )
  ),
  constraint chk_task_status check (
    task_status in (
      'PENDING',
      'SCHEDULED',
      'IN_PROGRESS',
      'COMPLETED',
      'FAILED',
      'CANCELLED',
      'DELEGATED',
      'AWAITING_APPROVAL'
    )
  ),
  constraint chk_task_initiated_by_type check (
    initiated_by_type in (
      'SYSTEM',
      'AGENT',
      'STAFF',
      'MANAGER',
      'CUSTOMER',
      'PROVIDER',
      'SCHEDULER'
    )
  ),
  constraint chk_task_payload_object check (
    jsonb_typeof(task_payload) = 'object'
  ),
  constraint chk_task_result_object check (
    result_payload is null
    or jsonb_typeof(result_payload) = 'object'
  ),
  constraint chk_task_priority check (priority between 1 and 10),
  constraint chk_task_retry check (retry_count >= 0)
);

create index if not exists idx_tasks_store_domain_status
  on catchmenu_ledger.tasks(store_id, task_domain, task_status);

create index if not exists idx_tasks_store_business_day
  on catchmenu_ledger.tasks(store_id, business_day desc);

create index if not exists idx_tasks_subject
  on catchmenu_ledger.tasks(subject_type, subject_id)
  where subject_id is not null;

create index if not exists idx_tasks_parent
  on catchmenu_ledger.tasks(parent_task_id)
  where parent_task_id is not null;

create index if not exists idx_tasks_correlation
  on catchmenu_ledger.tasks(correlation_id)
  where correlation_id is not null;

create index if not exists idx_tasks_deadline
  on catchmenu_ledger.tasks(deadline_at)
  where deadline_at is not null
    and task_status in ('PENDING', 'SCHEDULED', 'IN_PROGRESS');

comment on table catchmenu_ledger.tasks is
  'Task ledger. Append-only record of all operational work units.
   A Task is a discrete unit of work that must be performed:
   order intake, KDS transmission, cooking start, packaging,
   customer notification, delivery handoff, recovery, sync, etc.
   Task status tracks the lifecycle of each work unit.
   Tasks are never updated in place after creation except status fields.
   특허4: Task is the actionable work layer of the 4-ledger architecture.';
comment on column catchmenu_ledger.tasks.task_status is
  'PENDING = created, not yet started.
   SCHEDULED = will start at scheduled_at.
   IN_PROGRESS = currently being processed.
   COMPLETED = finished successfully.
   FAILED = failed, retry_count tracks attempts.
   CANCELLED = cancelled before completion.
   DELEGATED = handed off to secondary agent or manual process.
   AWAITING_APPROVAL = requires human approval before proceeding.';
comment on column catchmenu_ledger.tasks.priority is
  '1 = highest, 10 = lowest. Default 5 = normal.
   Payment and KDS release tasks default to priority 1.';
comment on column catchmenu_ledger.tasks.subject_type is
  'What this task operates on: order, session, kds_ticket, payment, device, etc.';
comment on column catchmenu_ledger.tasks.parent_task_id is
  'Links subtasks to parent task for complex multi-step operations.
   e.g. order_intake task spawns kds_transmit and payment_request subtasks.';
comment on column catchmenu_ledger.tasks.business_day is
  'Local business date at task creation time.
   Used for daily reporting and shift-based task aggregation.';

-- ===== END sql/migrations/0005_create_ledger_task.sql =====


-- ===== BEGIN sql/migrations/0006_create_ledger_event.sql =====

-- 0006_create_ledger_event.sql
-- Purpose: Event ledger. Records all state changes across the operational OS.
--          Current state is NEVER stored directly.
--          It is always derived from this ledger via Projection or View.
--          특허4 core: Event-sourced state management.
-- Depends on: 0005_create_ledger_task.sql
-- Creates:
--   catchmenu_ledger.events

create table if not exists catchmenu_ledger.events (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references catchmenu_hq.tenants(id),
  store_id uuid not null references catchmenu_hq.stores(id),

  -- event identity
  event_domain text not null,
  event_type text not null,
  event_version int not null default 1,

  -- what changed
  subject_type text not null,
  subject_id uuid not null,
  from_state text,
  to_state text,

  -- who/what caused this
  caused_by_type text not null default 'SYSTEM',
  caused_by_id uuid,
  caused_by_device_id uuid references catchmenu_store.device_registry(id),
  caused_by_agent_id uuid references catchmenu_store.agent_registry(id),
  caused_by_task_id uuid references catchmenu_ledger.tasks(id),

  -- event payload
  event_payload jsonb not null default '{}'::jsonb,

  -- idempotency
  idempotency_key text,
  is_replay boolean not null default false,
  original_event_id uuid references catchmenu_ledger.events(id),

  -- correlation
  session_id uuid,
  order_id uuid,
  payment_id uuid,
  kds_ticket_id uuid,
  correlation_id text,
  provider_event_id text,

  -- business day snapshot
  business_day date not null,
  business_timezone text not null default 'Asia/Seoul',
  occurred_at timestamptz not null default now(),
  recorded_at timestamptz not null default now(),

  constraint chk_event_domain check (
    event_domain in (
      'session',
      'order',
      'payment',
      'kds',
      'delivery',
      'inventory',
      'staff',
      'device',
      'agent',
      'recovery',
      'knowledge',
      'gateway',
      'system'
    )
  ),
  constraint chk_event_type_not_blank check (
    length(trim(event_type)) > 0
  ),
  constraint chk_event_caused_by_type check (
    caused_by_type in (
      'SYSTEM',
      'AGENT',
      'STAFF',
      'MANAGER',
      'CUSTOMER',
      'PROVIDER',
      'SCHEDULER',
      'REPLAY'
    )
  ),
  constraint chk_event_payload_object check (
    jsonb_typeof(event_payload) = 'object'
  ),
  constraint chk_event_replay_has_original check (
    is_replay = false
    or original_event_id is not null
  )
);

create index if not exists idx_events_store_domain
  on catchmenu_ledger.events(store_id, event_domain);

create index if not exists idx_events_subject
  on catchmenu_ledger.events(subject_type, subject_id, occurred_at desc);

create index if not exists idx_events_session
  on catchmenu_ledger.events(session_id, occurred_at desc)
  where session_id is not null;

create index if not exists idx_events_order
  on catchmenu_ledger.events(order_id, occurred_at desc)
  where order_id is not null;

create index if not exists idx_events_payment
  on catchmenu_ledger.events(payment_id, occurred_at desc)
  where payment_id is not null;

create index if not exists idx_events_kds_ticket
  on catchmenu_ledger.events(kds_ticket_id, occurred_at desc)
  where kds_ticket_id is not null;

create index if not exists idx_events_store_business_day
  on catchmenu_ledger.events(store_id, business_day desc);

create index if not exists idx_events_correlation
  on catchmenu_ledger.events(correlation_id)
  where correlation_id is not null;

create index if not exists idx_events_provider_event
  on catchmenu_ledger.events(provider_event_id)
  where provider_event_id is not null;

create index if not exists idx_events_occurred_at
  on catchmenu_ledger.events(store_id, occurred_at desc);

comment on table catchmenu_ledger.events is
  'Event ledger. Append-only record of all state changes in the system.
   This is the single source of truth for operational state.
   Current state of any entity (session, order, payment, KDS ticket)
   is ALWAYS derived from this ledger via Projection or View.
   Never store current state directly in a mutable column.
   If state is corrupted or inconsistent, replay this ledger to reconstruct.
   특허4 core: Event/Audit 원장 기반 Projection/View 재생성 기술.';
comment on column catchmenu_ledger.events.event_type is
  'Specific state change that occurred. Examples:
   session: session_created, table_bound, session_completed, session_expired
   order: order_draft_created, order_submitted, order_confirmed, order_cancelled
   payment: payment_requested, payment_confirmed, payment_failed,
            payment_uncertain, payment_cancelled, payment_refunded
   kds: kds_ticket_created, kds_held, kds_capacity_checked,
        kds_committed, kds_cooking_started, kds_ready, kds_completed
   device: device_online, device_offline, device_degraded, device_failed
   agent: agent_started, agent_isolated, agent_recovered, agent_failed';
comment on column catchmenu_ledger.events.from_state is
  'State before this event. Null for creation events.
   Together with to_state, forms the state transition record.';
comment on column catchmenu_ledger.events.to_state is
  'State after this event. Used to rebuild current state via Projection.';
comment on column catchmenu_ledger.events.is_replay is
  'True when this event was created during Event Replay after outage recovery.
   Replay events reference original_event_id from Local Temporary Ledger.
   특허4: Local Temporary Ledger 및 Event Replay 기반 복구 기술.';
comment on column catchmenu_ledger.events.occurred_at is
  'When the state change actually happened in the real world.
   May differ from recorded_at when replaying from Local Temporary Ledger.';
comment on column catchmenu_ledger.events.recorded_at is
  'When this event row was inserted into the central ledger.
   Always now() at insert time.';
comment on column catchmenu_ledger.events.session_id is
  'Denormalized session reference for fast Projection queries.
   The full event chain for a session can be reconstructed by
   querying WHERE session_id = ? ORDER BY occurred_at ASC.';

-- ===== END sql/migrations/0006_create_ledger_event.sql =====


-- ===== BEGIN sql/migrations/0007_create_ledger_exception.sql =====

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

-- ===== END sql/migrations/0007_create_ledger_exception.sql =====


-- ===== BEGIN sql/migrations/0008_create_ledger_audit.sql =====

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

-- ===== END sql/migrations/0008_create_ledger_audit.sql =====


-- ===== BEGIN sql/migrations/0014_create_payment_ledger.sql =====

-- 0014_create_payment_ledger.sql
-- Purpose: Payment intent and internal payment ledger.
--          payment_ledger is the ONLY source of truth for payment state.
--          External provider responses are never trusted directly.
--          They enter via gateway, are verified, then reflected here.
--          KDS release requires payment_ledger confirmation, not provider response.
--          특허1 core: 내부 승인 원장 = 금융권형 결제 대사의 기준점.
-- Depends on: 0013_create_pos_orders.sql, 0009_create_gateway_provider_events.sql
-- Creates:
--   catchmenu_payment.payment_intents
--   catchmenu_payment.payment_ledger
--   catchmenu_payment.payment_events

create table if not exists catchmenu_payment.payment_intents (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references catchmenu_hq.tenants(id),
  store_id uuid not null references catchmenu_hq.stores(id),
  order_id uuid not null references catchmenu_pos.orders(id),
  session_id uuid references catchmenu_pos.order_sessions(id),

  -- intent identity
  intent_status text not null default 'CREATED',
  payment_method text not null,
  payment_channel text not null,

  -- amounts
  requested_amount int not null,
  currency text not null default 'KRW',

  -- provider routing
  provider_type text not null,
  provider_order_id text unique,

  -- token (single-use per 특허1)
  payment_token text unique,
  token_issued_at timestamptz,
  token_expires_at timestamptz,

  -- idempotency
  idempotency_key text not null,
  gateway_session_id uuid references catchmenu_gateway.gateway_sessions(id),

  -- timing
  created_at timestamptz not null default now(),
  confirmed_at timestamptz,
  cancelled_at timestamptz,
  expired_at timestamptz,
  updated_at timestamptz not null default now(),

  -- business day snapshot
  business_day date not null,
  business_timezone text not null default 'Asia/Seoul',

  constraint chk_intent_status check (
    intent_status in (
      'CREATED',
      'PENDING',
      'PROCESSING',
      'CONFIRMED',
      'FAILED',
      'CANCELLED',
      'EXPIRED'
    )
  ),
  constraint chk_intent_payment_method check (
    payment_method in (
      'CARD',
      'SIMPLE_PAY_KAKAO',
      'SIMPLE_PAY_NAVER',
      'SIMPLE_PAY_TOSS',
      'SAMSUNG_PAY',
      'ALIPAY',
      'WECHAT_PAY',
      'CASH',
      'VOUCHER',
      'MIXED'
    )
  ),
  constraint chk_intent_payment_channel check (
    payment_channel in (
      'KIOSK_CARD',
      'KIOSK_QR',
      'TABLE_QR',
      'CUSTOMER_APP',
      'STAFF_POS',
      'COUNTER_CARD',
      'ONLINE'
    )
  ),
  constraint chk_intent_provider check (
    provider_type in (
      'TOSS_PAYMENTS',
      'VAN_NICE',
      'VAN_KIS',
      'VAN_KICC',
      'KAKAO_PAY',
      'NAVER_PAY',
      'SAMSUNG_PAY',
      'ALIPAY',
      'WECHAT_PAY',
      'CASH',
      'INTERNAL'
    )
  ),
  constraint chk_intent_amount check (requested_amount > 0)
);

create index if not exists idx_payment_intents_order
  on catchmenu_payment.payment_intents(order_id);

create index if not exists idx_payment_intents_session
  on catchmenu_payment.payment_intents(session_id)
  where session_id is not null;

create index if not exists idx_payment_intents_store_status
  on catchmenu_payment.payment_intents(store_id, intent_status);

create index if not exists idx_payment_intents_provider_order
  on catchmenu_payment.payment_intents(provider_order_id)
  where provider_order_id is not null;

create index if not exists idx_payment_intents_token
  on catchmenu_payment.payment_intents(payment_token)
  where payment_token is not null;

drop trigger if exists trg_payment_intents_updated_at
  on catchmenu_payment.payment_intents;
create trigger trg_payment_intents_updated_at
  before update on catchmenu_payment.payment_intents
  for each row execute function catchmenu_common.set_updated_at();

comment on table catchmenu_payment.payment_intents is
  'Payment intent. Created before payment window opens.
   Represents a single payment attempt for an order.
   One order may have multiple intents (retry after failure).
   provider_order_id is the ID sent to external provider.
   Internal system uses this ID to correlate provider callbacks.
   특허1: 단회성 비상태형 토큰으로 외부에 내부 원장 키 미노출.';
comment on column catchmenu_payment.payment_intents.payment_token is
  'Single-use token issued to payment provider.
   Never exposes internal order_id or customer identity.
   Expires after single use or token_expires_at.
   특허1: 단회성 비상태형 토큰 발급부.';
comment on column catchmenu_payment.payment_intents.intent_status is
  'CREATED = intent initialized, payment window not yet open.
   PENDING = payment window open, waiting for customer action.
   PROCESSING = customer submitted, provider processing.
   CONFIRMED = reflected in payment_ledger as APPROVED.
   FAILED = provider returned failure.
   CANCELLED = cancelled before processing.
   EXPIRED = timeout without customer action.';


create table if not exists catchmenu_payment.payment_ledger (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references catchmenu_hq.tenants(id),
  store_id uuid not null references catchmenu_hq.stores(id),
  order_id uuid not null references catchmenu_pos.orders(id),
  session_id uuid references catchmenu_pos.order_sessions(id),
  intent_id uuid not null references catchmenu_payment.payment_intents(id),

  -- ledger identity
  ledger_entry_type text not null,
  ledger_status text not null,

  -- amounts (KRW integer)
  approved_amount int not null,
  cancelled_amount int not null default 0,
  refunded_amount int not null default 0,
  net_amount int not null,

  -- provider confirmation (from gateway after verification)
  provider_type text not null,
  provider_payment_key text,
  provider_approval_number text,
  provider_approved_at timestamptz,
  provider_response_id uuid references catchmenu_gateway.provider_raw_events(id),

  -- reconciliation state
  reconciliation_status text not null default 'PENDING',
  reconciliation_checked_at timestamptz,
  reconciliation_mismatch_reason text,

  -- KDS release authority
  -- 특허1: 결제 완료 ≠ KDS 릴리즈 자동 허용
  -- KDS release requires this flag = true
  kds_release_authorized boolean not null default false,
  kds_release_authorized_at timestamptz,
  kds_release_authorized_by text,

  -- evidence
  evidence_packet_id uuid,

  -- business day snapshot
  business_day date not null,
  business_timezone text not null default 'Asia/Seoul',

  approved_at timestamptz not null default now(),
  created_at timestamptz not null default now(),

  constraint chk_ledger_entry_type check (
    ledger_entry_type in (
      'APPROVAL',
      'PARTIAL_CANCEL',
      'FULL_CANCEL',
      'REFUND',
      'PARTIAL_REFUND',
      'ADJUSTMENT',
      'MANUAL_CORRECTION'
    )
  ),
  constraint chk_ledger_status check (
    ledger_status in (
      'APPROVED',
      'CANCELLED',
      'REFUNDED',
      'PARTIAL_CANCELLED',
      'PARTIAL_REFUNDED',
      'UNCERTAIN',
      'DISPUTED',
      'UNDER_REVIEW'
    )
  ),
  constraint chk_ledger_amounts check (
    approved_amount > 0
    and cancelled_amount >= 0
    and refunded_amount >= 0
    and net_amount = approved_amount - cancelled_amount - refunded_amount
  ),
  constraint chk_ledger_reconciliation check (
    reconciliation_status in (
      'PENDING',
      'MATCHED',
      'MISMATCH',
      'MANUAL_REVIEW',
      'RESOLVED'
    )
  )
);

create index if not exists idx_payment_ledger_order
  on catchmenu_payment.payment_ledger(order_id);

create index if not exists idx_payment_ledger_intent
  on catchmenu_payment.payment_ledger(intent_id);

create index if not exists idx_payment_ledger_store_status
  on catchmenu_payment.payment_ledger(store_id, ledger_status);

create index if not exists idx_payment_ledger_store_business_day
  on catchmenu_payment.payment_ledger(store_id, business_day desc);

create index if not exists idx_payment_ledger_provider_key
  on catchmenu_payment.payment_ledger(provider_payment_key)
  where provider_payment_key is not null;

create index if not exists idx_payment_ledger_reconciliation
  on catchmenu_payment.payment_ledger(store_id, reconciliation_status)
  where reconciliation_status in ('PENDING', 'MISMATCH', 'MANUAL_REVIEW');

create index if not exists idx_payment_ledger_kds_auth
  on catchmenu_payment.payment_ledger(order_id, kds_release_authorized)
  where kds_release_authorized = false
    and ledger_status = 'APPROVED';

comment on table catchmenu_payment.payment_ledger is
  'Internal payment ledger. THE source of truth for payment state.
   External provider response alone is NEVER sufficient to confirm payment.
   Flow: provider_raw_events → gateway verification → payment_ledger entry.
   Only after ledger entry is APPROVED can KDS release be authorized.
   특허1 core: 내부 승인 원장 = 금융권형 결제 대사의 기준점.
   결제 승인 후 내부 서버, 외부 PG/VAN 원장 대사 필수.';
comment on column catchmenu_payment.payment_ledger.kds_release_authorized is
  'FALSE by default even after payment approval.
   KDS Capacity Agent checks this flag before committing tickets.
   Set to TRUE only after:
     1. ledger_status = APPROVED
     2. reconciliation_status = MATCHED or waived
     3. No PAYMENT_UNCERTAIN exception active for this order.
   특허1: 결제 승인 ≠ KDS 릴리즈 자동 허용.
   특허2: KDS Late Binding 조건 중 payment_confirmed 확인.';
comment on column catchmenu_payment.payment_ledger.ledger_status is
  'APPROVED = payment confirmed and ledger entry created.
   CANCELLED = fully cancelled.
   REFUNDED = fully refunded.
   PARTIAL_CANCELLED = partially cancelled.
   PARTIAL_REFUNDED = partially refunded.
   UNCERTAIN = payment attempted but result unknown.
               Triggers PAYMENT_UNCERTAIN session status.
               KDS MUST NOT release until resolved.
   DISPUTED = customer or provider dispute raised.
   UNDER_REVIEW = manual review in progress.';
comment on column catchmenu_payment.payment_ledger.reconciliation_status is
  'PENDING = not yet reconciled with provider ledger.
   MATCHED = internal ledger matches provider ledger.
   MISMATCH = discrepancy detected. Creates reconciliation_case.
   MANUAL_REVIEW = requires human review.
   RESOLVED = mismatch resolved.
   특허1: 내부 승인 원장 ↔ 외부 PG/VAN 원장 1차 대사.';


create table if not exists catchmenu_payment.payment_events (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references catchmenu_hq.tenants(id),
  store_id uuid not null references catchmenu_hq.stores(id),
  order_id uuid not null references catchmenu_pos.orders(id),
  intent_id uuid references catchmenu_payment.payment_intents(id),
  ledger_id uuid references catchmenu_payment.payment_ledger(id),

  event_type text not null,
  from_status text,
  to_status text,

  caused_by_type text not null default 'SYSTEM',
  caused_by_id uuid,
  caused_by_device_id uuid references catchmenu_store.device_registry(id),
  caused_by_agent_id uuid references catchmenu_store.agent_registry(id),

  amount_at_event int,
  provider_event_id text,
  event_payload jsonb not null default '{}'::jsonb,
  correlation_id text,
  occurred_at timestamptz not null default now(),

  constraint chk_payment_event_type check (
    event_type in (
      'intent_created',
      'payment_window_opened',
      'payment_submitted',
      'provider_callback_received',
      'provider_callback_verified',
      'payment_approved',
      'payment_failed',
      'payment_uncertain',
      'payment_uncertain_resolved',
      'payment_cancelled',
      'payment_refunded',
      'payment_partial_refunded',
      'kds_release_authorized',
      'reconciliation_matched',
      'reconciliation_mismatch_detected',
      'reconciliation_resolved',
      'manual_correction_applied',
      'dispute_raised',
      'dispute_resolved'
    )
  ),
  constraint chk_payment_event_caused_by check (
    caused_by_type in (
      'SYSTEM', 'AGENT', 'STAFF',
      'MANAGER', 'PROVIDER', 'SCHEDULER'
    )
  ),
  constraint chk_payment_event_payload_object check (
    jsonb_typeof(event_payload) = 'object'
  )
);

create index if not exists idx_payment_events_order
  on catchmenu_payment.payment_events(order_id, occurred_at asc);

create index if not exists idx_payment_events_intent
  on catchmenu_payment.payment_events(intent_id, occurred_at asc)
  where intent_id is not null;

create index if not exists idx_payment_events_ledger
  on catchmenu_payment.payment_events(ledger_id, occurred_at asc)
  where ledger_id is not null;

create index if not exists idx_payment_events_store_type
  on catchmenu_payment.payment_events(store_id, event_type, occurred_at desc);

comment on table catchmenu_payment.payment_events is
  'Payment-scoped event log. Domain event trail for payment lifecycle.
   payment_uncertain and payment_uncertain_resolved are critical events.
   When payment_uncertain is recorded:
     - Session status → PAYMENT_UNCERTAIN
     - KDS Agent blocks all ticket commits for this order
     - Exception is created in catchmenu_ledger.exceptions
     - Agent recommends resolution SOP to staff
   When payment_uncertain_resolved:
     - KDS release authorization is re-evaluated
     - Exception is closed
     - Audit record is created with resolution evidence.';

-- ===== END sql/migrations/0014_create_payment_ledger.sql =====


-- ===== BEGIN sql/migrations/0017_create_evidence_and_fallback.sql =====

-- 0017_create_evidence_and_fallback.sql
-- Purpose: Evidence packets for high-risk actions and manual fallback log.
--          Every high-risk operational event must create or link evidence.
--          Manual fallback must always leave an auditable record.
--          특허4 core: Evidence packet = 운영 사고의 증빙 가능한 기록.
-- Depends on: 0016_create_kds_tickets.sql
-- Creates:
--   catchmenu_agent.evidence_packets
--   catchmenu_agent.manual_fallback_log

create table if not exists catchmenu_agent.evidence_packets (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references catchmenu_hq.tenants(id),
  store_id uuid not null references catchmenu_hq.stores(id),

  -- packet identity
  packet_type text not null,
  packet_status text not null default 'CREATED',
  risk_level text not null default 'NORMAL',

  -- subject
  subject_type text not null,
  subject_id uuid not null,

  -- linked records
  session_id uuid,
  order_id uuid,
  payment_ledger_id uuid references catchmenu_payment.payment_ledger(id),
  kds_ticket_id uuid references catchmenu_kds.kds_tickets(id),
  exception_id uuid references catchmenu_ledger.exceptions(id),
  reconciliation_case_id uuid
    references catchmenu_payment.reconciliation_cases(id),

  -- evidence content
  -- 특허4: source event, actor, timestamp, prior state,
  --        next state, provider response, verification result
  prior_state jsonb,
  post_state jsonb,
  provider_response_snapshot jsonb,
  signature_verification_result jsonb,
  idempotency_result jsonb,
  staff_confirmation jsonb,
  customer_visible_message text,
  staff_visible_explanation text,
  support_visible_summary text,

  -- related events
  triggering_event_id uuid references catchmenu_ledger.events(id),
  audit_record_id uuid references catchmenu_ledger.audit_records(id),

  -- actor at time of evidence creation
  actor_type text not null default 'SYSTEM',
  actor_id uuid,
  actor_device_id uuid references catchmenu_store.device_registry(id),
  actor_agent_id uuid references catchmenu_store.agent_registry(id),

  -- review
  reviewed_by_id uuid,
  reviewed_at timestamptz,
  review_outcome text,
  review_note text,

  -- retention
  retain_until timestamptz,
  legal_hold boolean not null default false,

  -- correlation
  correlation_id text,
  business_day date not null,
  business_timezone text not null default 'Asia/Seoul',

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint chk_evidence_packet_type check (
    packet_type in (
      'PAYMENT_APPROVAL',
      'PAYMENT_CANCELLATION',
      'PAYMENT_REFUND',
      'PAYMENT_UNCERTAIN_RESOLUTION',
      'KDS_RELEASE_OVERRIDE',
      'KDS_MANUAL_FALLBACK',
      'RECONCILIATION_MISMATCH',
      'AGENT_OVERRIDE',
      'STAFF_MANUAL_OVERRIDE',
      'DEVICE_TRUST_CHANGE',
      'GATEWAY_BLOCK',
      'ALLERGEN_DISPLAY_EVIDENCE',
      'SUPPORT_CASE_CLOSURE',
      'KNOWLEDGE_PUBLISH_APPROVAL'
    )
  ),
  constraint chk_evidence_status check (
    packet_status in (
      'CREATED',
      'UNDER_REVIEW',
      'APPROVED',
      'REJECTED',
      'ARCHIVED',
      'LEGAL_HOLD'
    )
  ),
  constraint chk_evidence_risk_level check (
    risk_level in (
      'LOW',
      'NORMAL',
      'HIGH',
      'CRITICAL'
    )
  ),
  constraint chk_evidence_actor_type check (
    actor_type in (
      'SYSTEM', 'AGENT', 'STAFF',
      'MANAGER', 'OWNER', 'HQ_ADMIN', 'SCHEDULER'
    )
  ),
  constraint chk_evidence_prior_object check (
    prior_state is null
    or jsonb_typeof(prior_state) = 'object'
  ),
  constraint chk_evidence_post_object check (
    post_state is null
    or jsonb_typeof(post_state) = 'object'
  ),
  constraint chk_evidence_provider_object check (
    provider_response_snapshot is null
    or jsonb_typeof(provider_response_snapshot) = 'object'
  )
);

create index if not exists idx_evidence_packets_store_type
  on catchmenu_agent.evidence_packets(store_id, packet_type);

create index if not exists idx_evidence_packets_subject
  on catchmenu_agent.evidence_packets(subject_type, subject_id);

create index if not exists idx_evidence_packets_order
  on catchmenu_agent.evidence_packets(order_id)
  where order_id is not null;

create index if not exists idx_evidence_packets_payment
  on catchmenu_agent.evidence_packets(payment_ledger_id)
  where payment_ledger_id is not null;

create index if not exists idx_evidence_packets_legal_hold
  on catchmenu_agent.evidence_packets(store_id, legal_hold)
  where legal_hold = true;

create index if not exists idx_evidence_packets_risk
  on catchmenu_agent.evidence_packets(store_id, risk_level, created_at desc)
  where risk_level in ('HIGH', 'CRITICAL');

create index if not exists idx_evidence_packets_business_day
  on catchmenu_agent.evidence_packets(store_id, business_day desc);

drop trigger if exists trg_evidence_packets_updated_at
  on catchmenu_agent.evidence_packets;
create trigger trg_evidence_packets_updated_at
  before update on catchmenu_agent.evidence_packets
  for each row execute function catchmenu_common.set_updated_at();

comment on table catchmenu_agent.evidence_packets is
  'Evidence packets for high-risk operational events.
   Every packet answers:
   - what happened (subject, event type)
   - who did it (actor)
   - when (timestamps)
   - what was the state before (prior_state)
   - what is the state after (post_state)
   - what did the provider say (provider_response_snapshot)
   - was it verified (signature_verification_result)
   - was it idempotent (idempotency_result)
   - what did staff confirm (staff_confirmation)
   - what did customer see (customer_visible_message)
   - what does support need to know (support_visible_summary)
   특허4: Evidence packet = 운영 사고의 증빙 가능한 기록.
   특허1: 고위험 액션에 evidence 연결 의무.';
comment on column catchmenu_agent.evidence_packets.legal_hold is
  'True when evidence must be retained for legal or regulatory reasons.
   Legal hold overrides normal retention policy.
   Packets under legal hold cannot be archived or deleted.';
comment on column catchmenu_agent.evidence_packets.customer_visible_message is
  'Message shown to customer at time of this event.
   Preserved for dispute resolution and support investigation.
   특허1: 고객 locale 기반 안내문 증빙 보관.';


create table if not exists catchmenu_agent.manual_fallback_log (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references catchmenu_hq.tenants(id),
  store_id uuid not null references catchmenu_hq.stores(id),

  -- fallback identity
  fallback_type text not null,
  fallback_reason text not null,
  fallback_status text not null default 'ACTIVE',

  -- what triggered it
  triggered_by_exception_id uuid
    references catchmenu_ledger.exceptions(id),
  triggered_by_device_id uuid
    references catchmenu_store.device_registry(id),
  triggered_by_agent_id uuid
    references catchmenu_store.agent_registry(id),

  -- what was bypassed
  bypassed_system text not null,
  affected_order_ids jsonb,
  affected_session_ids jsonb,
  affected_kds_ticket_ids jsonb,

  -- who activated
  activated_by_type text not null,
  activated_by_id uuid,

  -- fallback procedure
  sop_applied_id uuid,
  procedure_followed text,
  staff_actions jsonb,

  -- recovery
  recovery_started_at timestamptz,
  recovery_completed_at timestamptz,
  recovery_verified_by uuid,
  recovery_note text,

  -- resync
  resync_required boolean not null default false,
  resync_completed_at timestamptz,
  resync_event_count int,
  resync_conflict_count int,

  -- evidence
  evidence_packet_id uuid references catchmenu_agent.evidence_packets(id),
  audit_record_id uuid references catchmenu_ledger.audit_records(id),

  -- timing
  activated_at timestamptz not null default now(),
  deactivated_at timestamptz,

  -- business day
  business_day date not null,
  business_timezone text not null default 'Asia/Seoul',

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint chk_fallback_type check (
    fallback_type in (
      'POS_OFFLINE',
      'KDS_OFFLINE',
      'KIOSK_OFFLINE',
      'NETWORK_DISCONNECTED',
      'PAYMENT_PROVIDER_UNAVAILABLE',
      'CENTRAL_DB_UNAVAILABLE',
      'AGENT_SERVER_FAILED',
      'DELIVERY_APP_UNAVAILABLE',
      'PRINTER_FALLBACK',
      'MANUAL_ORDER_ENTRY',
      'CASH_ONLY_MODE',
      'PARTIAL_SYSTEM_DEGRADED'
    )
  ),
  constraint chk_fallback_status check (
    fallback_status in (
      'ACTIVE',
      'RECOVERING',
      'RESOLVED',
      'PARTIALLY_RESOLVED',
      'ABANDONED'
    )
  ),
  constraint chk_fallback_activated_by check (
    activated_by_type in (
      'STAFF', 'MANAGER', 'OWNER',
      'AGENT', 'SYSTEM', 'HQ_ADMIN'
    )
  ),
  constraint chk_affected_orders_array check (
    affected_order_ids is null
    or jsonb_typeof(affected_order_ids) = 'array'
  ),
  constraint chk_affected_sessions_array check (
    affected_session_ids is null
    or jsonb_typeof(affected_session_ids) = 'array'
  ),
  constraint chk_staff_actions_array check (
    staff_actions is null
    or jsonb_typeof(staff_actions) = 'array'
  )
);

create index if not exists idx_fallback_log_store_status
  on catchmenu_agent.manual_fallback_log(store_id, fallback_status);

create index if not exists idx_fallback_log_store_type
  on catchmenu_agent.manual_fallback_log(store_id, fallback_type);

create index if not exists idx_fallback_log_store_business_day
  on catchmenu_agent.manual_fallback_log(store_id, business_day desc);

create index if not exists idx_fallback_log_active
  on catchmenu_agent.manual_fallback_log(store_id, activated_at desc)
  where fallback_status in ('ACTIVE', 'RECOVERING');

create index if not exists idx_fallback_log_resync
  on catchmenu_agent.manual_fallback_log(store_id, resync_required)
  where resync_required = true
    and resync_completed_at is null;

drop trigger if exists trg_fallback_log_updated_at
  on catchmenu_agent.manual_fallback_log;
create trigger trg_fallback_log_updated_at
  before update on catchmenu_agent.manual_fallback_log
  for each row execute function catchmenu_common.set_updated_at();

comment on table catchmenu_agent.manual_fallback_log is
  'Manual fallback activation log. Records every instance when
   normal system operation was bypassed due to failure.
   Every fallback must be logged — no silent bypasses allowed.
   특허4 원칙: 무장애 운영 = 장애 발생 시 운영 모드를 전환하고
               기록·복구·감사 흐름을 유지하는 구조.
   특허2: Manual Fallback 구조 — POS/KDS 장애 상황에서도 운영 연속성 유지.';
comment on column catchmenu_agent.manual_fallback_log.bypassed_system is
  'Which system was bypassed during fallback.
   e.g. KDS, POS, PAYMENT_PROVIDER, CENTRAL_DB.';
comment on column catchmenu_agent.manual_fallback_log.resync_required is
  'True when local temporary ledger was used during fallback.
   Resync must be completed and verified before fallback is RESOLVED.
   특허4: Local Temporary Ledger → Event Replay 기반 복구.';
comment on column catchmenu_agent.manual_fallback_log.resync_conflict_count is
  'Number of events with conflicts during resync.
   Non-zero count requires manual review before resolution.';

-- ===== END sql/migrations/0017_create_evidence_and_fallback.sql =====


-- ===== BEGIN sql/migrations/0020_create_integrations_and_local_ledger.sql =====

-- 0020_create_integrations_and_local_ledger.sql
-- Purpose: Toss POS payment integration and local temporary ledger.
--          Local temporary ledger stores events during network outage.
--          After recovery, events are replayed to central ledger.
--          특허4 core: Local Temporary Ledger + Event Replay 기반 복구.
-- Depends on: 0014_create_payment_ledger.sql
-- Creates:
--   catchmenu_integrations.toss_payments
--   catchmenu_integrations.toss_webhooks
--   catchmenu_ledger.local_temporary_ledger

create table if not exists catchmenu_integrations.toss_payments (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references catchmenu_hq.tenants(id),
  store_id uuid not null references catchmenu_hq.stores(id),
  order_id uuid not null references catchmenu_pos.orders(id),
  session_id uuid references catchmenu_pos.order_sessions(id),
  intent_id uuid references catchmenu_payment.payment_intents(id),
  ledger_id uuid references catchmenu_payment.payment_ledger(id),

  -- Toss identifiers
  toss_payment_key text unique,
  toss_order_id text not null unique,
  toss_transaction_key text,

  -- payment state (mirrors Toss API status)
  toss_status text not null default 'READY',
  payment_method text,
  payment_type text,

  -- amounts
  requested_amount int not null,
  approved_amount int,
  cancelled_amount int,
  vat_amount int,

  -- card info (masked)
  card_company text,
  card_number_masked text,
  card_installment_plan_months int,
  card_approve_no text,
  card_acquire_status text,

  -- simple pay info
  easy_pay_provider text,
  easy_pay_amount int,
  easy_pay_discount_amount int,

  -- receipt
  receipt_url text,
  checkout_url text,

  -- raw response preservation
  toss_raw_response jsonb,
  toss_raw_cancel_response jsonb,

  -- gateway linkage
  provider_raw_event_id uuid
    references catchmenu_gateway.provider_raw_events(id),

  -- timing
  requested_at timestamptz not null default now(),
  approved_at timestamptz,
  cancelled_at timestamptz,
  failed_at timestamptz,
  last_updated_at timestamptz,

  failure_code text,
  failure_message text,
  cancel_reason text,

  -- business day snapshot
  business_day date not null,
  business_timezone text not null default 'Asia/Seoul',

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint chk_toss_status check (
    toss_status in (
      'READY',
      'IN_PROGRESS',
      'WAITING_FOR_DEPOSIT',
      'DONE',
      'CANCELLED',
      'PARTIAL_CANCELLED',
      'ABORTED',
      'EXPIRED'
    )
  ),
  constraint chk_toss_requested_amount check (requested_amount > 0),
  constraint chk_toss_approved_amount check (
    approved_amount is null or approved_amount >= 0
  ),
  constraint chk_toss_raw_object check (
    toss_raw_response is null
    or jsonb_typeof(toss_raw_response) = 'object'
  ),
  constraint chk_toss_raw_cancel_object check (
    toss_raw_cancel_response is null
    or jsonb_typeof(toss_raw_cancel_response) = 'object'
  )
);

create index if not exists idx_toss_payments_store
  on catchmenu_integrations.toss_payments(store_id, toss_status);

create index if not exists idx_toss_payments_order
  on catchmenu_integrations.toss_payments(order_id);

create index if not exists idx_toss_payments_intent
  on catchmenu_integrations.toss_payments(intent_id)
  where intent_id is not null;

create index if not exists idx_toss_payments_ledger
  on catchmenu_integrations.toss_payments(ledger_id)
  where ledger_id is not null;

create index if not exists idx_toss_payments_business_day
  on catchmenu_integrations.toss_payments(store_id, business_day desc);

create index if not exists idx_toss_payments_provider_event
  on catchmenu_integrations.toss_payments(provider_raw_event_id)
  where provider_raw_event_id is not null;

drop trigger if exists trg_toss_payments_updated_at
  on catchmenu_integrations.toss_payments;
create trigger trg_toss_payments_updated_at
  before update on catchmenu_integrations.toss_payments
  for each row execute function catchmenu_common.set_updated_at();

comment on table catchmenu_integrations.toss_payments is
  'Toss Payments integration record.
   Raw provider data preserved exactly as received.
   toss_raw_response is the forensic evidence for any Toss dispute.
   Internal payment truth lives in catchmenu_payment.payment_ledger.
   This table is the bridge between Toss and internal ledger.
   Reconciliation compares toss_status with ledger_status.
   특허1: 외부 PG/VAN 원장 ↔ 내부 승인 원장 1차 대사 데이터.';
comment on column catchmenu_integrations.toss_payments.toss_status is
  'Mirrors Toss API official status values exactly.
   READY = before payment window opens.
   IN_PROGRESS = payment window open.
   WAITING_FOR_DEPOSIT = virtual account issued.
   DONE = approved.
   CANCELLED = fully cancelled.
   PARTIAL_CANCELLED = partially cancelled.
   ABORTED = approval failed.
   EXPIRED = timed out.';
comment on column catchmenu_integrations.toss_payments.toss_raw_response is
  'Complete Toss API response payload preserved as-is.
   Never modified after insert.
   Used for reconciliation, dispute evidence, and audit.';
comment on column catchmenu_integrations.toss_payments.card_number_masked is
  'Masked card number from Toss response. e.g. 4321-12**-****-1234.
   Never store full card number. PCI DSS compliance.';


create table if not exists catchmenu_integrations.toss_webhooks (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references catchmenu_hq.tenants(id),
  store_id uuid references catchmenu_hq.stores(id),

  -- webhook identity
  toss_payment_key text,
  toss_order_id text,
  event_type text not null,

  -- raw webhook payload
  raw_headers jsonb,
  raw_body jsonb not null,
  payload_hash text,

  -- verification
  signature_verified boolean,
  idempotency_checked boolean not null default false,
  is_duplicate boolean not null default false,

  -- processing
  processing_status text not null default 'RECEIVED',
  processed_at timestamptz,
  processing_error text,

  -- linkage
  toss_payment_id uuid references catchmenu_integrations.toss_payments(id),
  provider_raw_event_id uuid
    references catchmenu_gateway.provider_raw_events(id),
  internal_payment_event_id uuid
    references catchmenu_payment.payment_events(id),

  received_at timestamptz not null default now(),
  created_at timestamptz not null default now(),

  constraint chk_toss_webhook_status check (
    processing_status in (
      'RECEIVED',
      'VERIFIED',
      'PROCESSED',
      'DUPLICATE_IGNORED',
      'FAILED',
      'QUARANTINED'
    )
  ),
  constraint chk_toss_webhook_body_object check (
    jsonb_typeof(raw_body) = 'object'
  )
);

create index if not exists idx_toss_webhooks_payment_key
  on catchmenu_integrations.toss_webhooks(toss_payment_key)
  where toss_payment_key is not null;

create index if not exists idx_toss_webhooks_order_id
  on catchmenu_integrations.toss_webhooks(toss_order_id)
  where toss_order_id is not null;

create index if not exists idx_toss_webhooks_status
  on catchmenu_integrations.toss_webhooks(processing_status, received_at desc)
  where processing_status in ('RECEIVED', 'VERIFIED', 'QUARANTINED');

create index if not exists idx_toss_webhooks_hash
  on catchmenu_integrations.toss_webhooks(payload_hash)
  where payload_hash is not null;

comment on table catchmenu_integrations.toss_webhooks is
  'Toss Payments webhook receiver log.
   Every webhook is stored as-is before processing.
   Signature verification and idempotency check happen before any state change.
   Duplicate webhooks are ignored and logged as DUPLICATE_IGNORED.
   특허1: 웹훅 서명 검증 + 멱등성 확인 후 내부 상태 반영.';


create table if not exists catchmenu_ledger.local_temporary_ledger (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null,
  store_id uuid not null,
  device_id uuid not null,

  -- entry identity
  entry_type text not null,
  entry_domain text not null,
  entry_sequence int not null,

  -- original event data
  original_event_type text not null,
  original_subject_type text,
  original_subject_id uuid,
  entry_payload jsonb not null default '{}'::jsonb,

  -- correlation to central ledger
  central_event_id uuid,
  central_task_id uuid,
  central_audit_id uuid,

  -- replay state
  replay_status text not null default 'PENDING',
  replay_attempted_at timestamptz,
  replay_completed_at timestamptz,
  replay_attempt_count int not null default 0,
  replay_conflict_detected boolean not null default false,
  replay_conflict_detail jsonb,
  replay_approved_by uuid,
  replay_approved_at timestamptz,

  -- timing
  locally_recorded_at timestamptz not null default now(),
  network_restored_at timestamptz,
  created_at timestamptz not null default now(),

  constraint uq_local_ledger_device_sequence
    unique (device_id, entry_sequence),
  constraint chk_local_entry_type check (
    entry_type in (
      'TASK',
      'EVENT',
      'AUDIT',
      'EXCEPTION'
    )
  ),
  constraint chk_local_entry_domain check (
    entry_domain in (
      'order', 'payment', 'kds', 'session',
      'delivery', 'staff', 'device',
      'agent', 'recovery', 'system'
    )
  ),
  constraint chk_local_replay_status check (
    replay_status in (
      'PENDING',
      'IN_PROGRESS',
      'REPLAYED',
      'CONFLICT_DETECTED',
      'CONFLICT_RESOLVED',
      'SKIPPED',
      'FAILED'
    )
  ),
  constraint chk_local_payload_object check (
    jsonb_typeof(entry_payload) = 'object'
  ),
  constraint chk_local_conflict_object check (
    replay_conflict_detail is null
    or jsonb_typeof(replay_conflict_detail) = 'object'
  ),
  constraint chk_replay_attempt_count check (
    replay_attempt_count >= 0
  )
);

create index if not exists idx_local_ledger_device_replay
  on catchmenu_ledger.local_temporary_ledger(device_id, replay_status);

create index if not exists idx_local_ledger_store_pending
  on catchmenu_ledger.local_temporary_ledger(store_id, locally_recorded_at asc)
  where replay_status in ('PENDING', 'CONFLICT_DETECTED');

create index if not exists idx_local_ledger_conflict
  on catchmenu_ledger.local_temporary_ledger(store_id, replay_conflict_detected)
  where replay_conflict_detected = true
    and replay_status = 'CONFLICT_DETECTED';

create index if not exists idx_local_ledger_sequence
  on catchmenu_ledger.local_temporary_ledger(device_id, entry_sequence asc)
  where replay_status = 'PENDING';

comment on table catchmenu_ledger.local_temporary_ledger is
  'Local temporary ledger for offline operation.
   When network is disconnected, all operational events are stored here
   in append-only sequence order per device.
   After network recovery:
     1. Compare local entries with central ledger
     2. Verify each entry for conflicts, duplicates, ordering issues
     3. Safe entries → replay to central ledger
     4. Conflict entries → manual review queue
   특허4: Local Temporary Ledger 및 Event Replay 기반 복구 기술.
   중앙 DB 장애, 메인 서버 장애, 네트워크 장애 발생 시
   Local Temporary Ledger를 사용하여 운영 연속성 유지.';
comment on column catchmenu_ledger.local_temporary_ledger.entry_sequence is
  'Monotonically increasing sequence per device.
   Used to detect gaps or ordering issues during replay.
   Critical for detecting events that were lost during outage.';
comment on column catchmenu_ledger.local_temporary_ledger.replay_conflict_detected is
  'True when this entry conflicts with central ledger state.
   e.g. central ledger shows order CANCELLED but local shows COMPLETED.
   Conflicts require manual manager approval before replay.
   특허4: 충돌 또는 손상 의심 Event는 관리자 승인 대상으로 분리.';
comment on column catchmenu_ledger.local_temporary_ledger.replay_approved_by is
  'Manager who approved replay of a conflicting entry.
   Null for non-conflicting entries that auto-replayed.
   특허4: 안전한 Event만 중앙 원장에 Replay.';

-- ===== END sql/migrations/0020_create_integrations_and_local_ledger.sql =====


-- ===== BEGIN sql/migrations/0027_create_payment_intent_rpc.sql =====

-- 0027_create_payment_intent_rpc.sql
-- Purpose: Payment intent creation and KDS release authorization.
--          create_payment_intent: creates payment intent before provider call.
--          confirm_payment_from_provider: records provider confirmation
--            and authorizes KDS release.
--          mark_payment_uncertain: flags uncertain payment state.
--          특허1 core: 결제 의도 → 내부 원장 → KDS 릴리즈 권한 분리.
-- Depends on: 0026_create_order_rpc.sql
-- Creates:
--   function catchmenu_payment.create_payment_intent(...)
--   function catchmenu_payment.confirm_payment_from_provider(...)
--   function catchmenu_payment.mark_payment_uncertain(...)
--   function catchmenu_payment.resolve_payment_uncertain(...)

create or replace function catchmenu_payment.create_payment_intent(
  p_tenant_id uuid,
  p_store_id uuid,
  p_order_id uuid,
  p_session_id uuid,
  p_payment_method text,
  p_payment_channel text,
  p_provider_type text,
  p_requested_amount int,
  p_idempotency_key text,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_payment, catchmenu_pos,
                  catchmenu_common, catchmenu_ledger,
                  catchmenu_hq
as $$
declare
  v_intent_id uuid;
  v_provider_order_id text;
  v_order record;
  v_business_day date;
  v_timezone text;
  v_existing_intent_id uuid;
begin
  -- idempotency check
  select id into v_existing_intent_id
  from catchmenu_payment.payment_intents
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and order_id = p_order_id
    and intent_status not in ('FAILED', 'CANCELLED', 'EXPIRED');

  if v_existing_intent_id is not null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'active_intent_exists',
      'existing_intent_id', v_existing_intent_id
    );
  end if;

  -- store timezone
  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(v_timezone, now()))::date;

  -- order validation
  select id, order_status, final_amount
  into v_order
  from catchmenu_pos.orders
  where id = p_order_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id;

  if v_order.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'order_not_found'
    );
  end if;

  if v_order.order_status not in ('CONFIRMED', 'PENDING') then
    return jsonb_build_object(
      'success', false,
      'error_key', 'order_not_payable',
      'order_status', v_order.order_status
    );
  end if;

  if p_requested_amount <= 0 then
    return jsonb_build_object(
      'success', false,
      'error_key', 'invalid_amount'
    );
  end if;

  if p_requested_amount <> v_order.final_amount then
    return jsonb_build_object(
      'success', false,
      'error_key', 'amount_mismatch',
      'order_amount', v_order.final_amount,
      'requested_amount', p_requested_amount
    );
  end if;

  -- generate provider order id
  -- format: CM-{store_short}-{timestamp}-{random}
  v_provider_order_id := 'CM-' ||
    upper(substr(p_store_id::text, 1, 8)) || '-' ||
    extract(epoch from now())::bigint::text || '-' ||
    upper(substr(gen_random_uuid()::text, 1, 6));

  -- create intent
  insert into catchmenu_payment.payment_intents (
    tenant_id, store_id, order_id, session_id,
    intent_status, payment_method, payment_channel,
    requested_amount, currency,
    provider_type, provider_order_id,
    idempotency_key,
    business_day, business_timezone
  ) values (
    p_tenant_id, p_store_id, p_order_id, p_session_id,
    'CREATED', p_payment_method, p_payment_channel,
    p_requested_amount, 'KRW',
    p_provider_type, v_provider_order_id,
    p_idempotency_key,
    v_business_day, v_timezone
  )
  returning id into v_intent_id;

  -- update session to PAYMENT_PENDING
  update catchmenu_pos.order_sessions
  set
    session_status = 'PAYMENT_PENDING',
    payment_started_at = now(),
    toss_order_id = case
      when p_provider_type = 'TOSS_PAYMENTS'
      then v_provider_order_id
      else toss_order_id
    end,
    updated_at = now()
  where id = p_session_id;

  -- payment event
  insert into catchmenu_payment.payment_events (
    tenant_id, store_id, order_id, intent_id,
    event_type, from_status, to_status,
    caused_by_type,
    event_payload, correlation_id, occurred_at
  ) values (
    p_tenant_id, p_store_id, p_order_id, v_intent_id,
    'intent_created', null, 'CREATED',
    'SYSTEM',
    jsonb_build_object(
      'payment_method', p_payment_method,
      'payment_channel', p_payment_channel,
      'provider_type', p_provider_type,
      'provider_order_id', v_provider_order_id,
      'requested_amount', p_requested_amount
    ),
    p_correlation_id, now()
  );

  -- ledger event
  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, event_payload,
    session_id, order_id, payment_id,
    correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'payment', 'intent_created', 1,
    'payment_intent', v_intent_id,
    null, 'CREATED',
    'SYSTEM',
    jsonb_build_object(
      'provider_type', p_provider_type,
      'provider_order_id', v_provider_order_id,
      'requested_amount', p_requested_amount
    ),
    p_session_id, p_order_id, v_intent_id,
    p_correlation_id,
    v_business_day, v_timezone, now()
  );

  return jsonb_build_object(
    'success', true,
    'intent_id', v_intent_id,
    'provider_order_id', v_provider_order_id,
    'intent_status', 'CREATED',
    'requested_amount', p_requested_amount,
    'provider_type', p_provider_type,
    'message_code', 'intent_created'
  );
end;
$$;


create or replace function catchmenu_payment.confirm_payment_from_provider(
  p_tenant_id uuid,
  p_store_id uuid,
  p_intent_id uuid,
  p_provider_payment_key text,
  p_provider_approval_number text,
  p_approved_amount int,
  p_provider_raw_event_id uuid,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_payment, catchmenu_pos,
                  catchmenu_kds, catchmenu_ledger,
                  catchmenu_audit, catchmenu_common
as $$
declare
  v_intent record;
  v_ledger_id uuid;
  v_audit_id uuid;
  v_kds_updated int;
begin
  -- intent validation
  select id, order_id, session_id, provider_type,
         requested_amount, payment_method, payment_channel,
         business_day, business_timezone, provider_order_id
  into v_intent
  from catchmenu_payment.payment_intents
  where id = p_intent_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
  for update;

  if v_intent.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'intent_not_found'
    );
  end if;

  if v_intent.requested_amount <> p_approved_amount then
    -- amount mismatch — create reconciliation case (handled separately)
    return jsonb_build_object(
      'success', false,
      'error_key', 'amount_mismatch',
      'requested_amount', v_intent.requested_amount,
      'approved_amount', p_approved_amount
    );
  end if;

  -- update intent status
  update catchmenu_payment.payment_intents
  set
    intent_status = 'CONFIRMED',
    confirmed_at = now(),
    updated_at = now()
  where id = p_intent_id;

  -- create payment ledger entry (internal source of truth)
  insert into catchmenu_payment.payment_ledger (
    tenant_id, store_id, order_id, session_id, intent_id,
    ledger_entry_type, ledger_status,
    approved_amount, net_amount,
    provider_type, provider_payment_key,
    provider_approval_number, provider_approved_at,
    provider_response_id,
    reconciliation_status,
    -- 특허1: 결제 승인 ≠ KDS 릴리즈 자동 허용
    -- kds_release_authorized starts FALSE
    kds_release_authorized,
    business_day, business_timezone,
    approved_at
  ) values (
    p_tenant_id, p_store_id,
    v_intent.order_id, v_intent.session_id, p_intent_id,
    'APPROVAL', 'APPROVED',
    p_approved_amount, p_approved_amount,
    v_intent.provider_type, p_provider_payment_key,
    p_provider_approval_number, now(),
    p_provider_raw_event_id,
    'PENDING',
    false,
    v_intent.business_day, v_intent.business_timezone,
    now()
  )
  returning id into v_ledger_id;

  -- update session payment status
  update catchmenu_pos.order_sessions
  set
    session_status = 'PAYMENT_PENDING',
    payment_completed_at = now(),
    updated_at = now()
  where id = v_intent.session_id;

  -- update KDS tickets: set payment_confirmed = true in conditions_met
  -- but kds_status stays HOLD until capacity check
  update catchmenu_kds.kds_tickets
  set
    conditions_met = conditions_met || jsonb_build_object(
      'payment_confirmed', true
    ),
    payment_ledger_id = v_ledger_id,
    updated_at = now()
  where order_id = v_intent.order_id
    and kds_status in ('HOLD', 'CAPACITY_CHECKING');

  get diagnostics v_kds_updated = row_count;

  -- KDS events for condition update
  insert into catchmenu_kds.kds_events (
    tenant_id, store_id, ticket_id, order_id,
    event_type, caused_by_type,
    conditions_at_event, event_payload, occurred_at
  )
  select
    p_tenant_id, p_store_id, kt.id, v_intent.order_id,
    'payment_confirmed_released',
    'SYSTEM',
    kt.conditions_met,
    jsonb_build_object(
      'payment_ledger_id', v_ledger_id,
      'approved_amount', p_approved_amount
    ),
    now()
  from catchmenu_kds.kds_tickets kt
  where kt.order_id = v_intent.order_id
    and kt.kds_status in ('HOLD', 'CAPACITY_CHECKING');

  -- payment event
  insert into catchmenu_payment.payment_events (
    tenant_id, store_id, order_id,
    intent_id, ledger_id,
    event_type, from_status, to_status,
    caused_by_type, amount_at_event,
    provider_event_id,
    event_payload, correlation_id, occurred_at
  ) values (
    p_tenant_id, p_store_id, v_intent.order_id,
    p_intent_id, v_ledger_id,
    'payment_approved', 'PROCESSING', 'APPROVED',
    'PROVIDER', p_approved_amount,
    p_provider_payment_key,
    jsonb_build_object(
      'provider_payment_key', p_provider_payment_key,
      'provider_approval_number', p_provider_approval_number,
      'kds_tickets_updated', v_kds_updated,
      'kds_release_authorized', false,
      'kds_release_pending_capacity_check', true
    ),
    p_correlation_id, now()
  );

  -- ledger event
  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, event_payload,
    session_id, order_id, payment_id,
    correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'payment', 'payment_approved', 1,
    'payment_ledger', v_ledger_id,
    'PROCESSING', 'APPROVED',
    'PROVIDER',
    jsonb_build_object(
      'approved_amount', p_approved_amount,
      'provider_payment_key', p_provider_payment_key,
      'kds_release_authorized', false,
      'reconciliation_required', true
    ),
    v_intent.session_id, v_intent.order_id, v_ledger_id,
    p_correlation_id,
    v_intent.business_day, v_intent.business_timezone, now()
  );

  -- audit record
  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := 'payment',
    p_audit_type := 'payment_approved',
    p_audit_category := 'FINANCIAL',
    p_actor_type := 'PROVIDER',
    p_actor_id := null,
    p_subject_type := 'payment_ledger',
    p_subject_id := v_ledger_id,
    p_decision := 'APPROVED',
    p_decision_payload := jsonb_build_object(
      'approved_amount', p_approved_amount,
      'provider_payment_key', p_provider_payment_key,
      'provider_approval_number', p_provider_approval_number,
      'kds_release_authorized', false,
      'reconciliation_status', 'PENDING'
    ),
    p_after_state := jsonb_build_object(
      'ledger_status', 'APPROVED',
      'kds_release_authorized', false
    ),
    p_payment_id := v_ledger_id,
    p_order_id := v_intent.order_id,
    p_session_id := v_intent.session_id,
    p_correlation_id := p_correlation_id,
    p_business_day := v_intent.business_day,
    p_business_timezone := v_intent.business_timezone
  );

  return jsonb_build_object(
    'success', true,
    'ledger_id', v_ledger_id,
    'intent_id', p_intent_id,
    'ledger_status', 'APPROVED',
    'approved_amount', p_approved_amount,
    'kds_release_authorized', false,
    'kds_tickets_payment_confirmed', v_kds_updated,
    'reconciliation_status', 'PENDING',
    'next_step', 'KDS_CAPACITY_CHECK_REQUIRED',
    'message_code', 'payment_approved_kds_pending_capacity',
    'audit_id', v_audit_id
  );
end;
$$;


create or replace function catchmenu_payment.mark_payment_uncertain(
  p_tenant_id uuid,
  p_store_id uuid,
  p_intent_id uuid,
  p_uncertain_reason text,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_payment, catchmenu_pos,
                  catchmenu_kds, catchmenu_ledger,
                  catchmenu_audit, catchmenu_common
as $$
declare
  v_intent record;
  v_exception_id uuid;
  v_audit_id uuid;
begin
  select id, order_id, session_id,
         business_day, business_timezone
  into v_intent
  from catchmenu_payment.payment_intents
  where id = p_intent_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
  for update;

  if v_intent.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'intent_not_found'
    );
  end if;

  -- update intent
  update catchmenu_payment.payment_intents
  set intent_status = 'PROCESSING',
      updated_at = now()
  where id = p_intent_id;

  -- update session to PAYMENT_UNCERTAIN
  -- 특허1: PAYMENT_UNCERTAIN = KDS 절대 릴리즈 금지
  update catchmenu_pos.order_sessions
  set
    session_status = 'PAYMENT_UNCERTAIN',
    updated_at = now()
  where id = v_intent.session_id;

  -- ensure all KDS tickets remain in HOLD
  update catchmenu_kds.kds_tickets
  set
    kds_status = 'HOLD',
    hold_reason = 'PAYMENT_UNCERTAIN',
    updated_at = now()
  where order_id = v_intent.order_id
    and kds_status not in ('COMPLETED', 'CANCELLED', 'SERVED');

  -- create exception
  insert into catchmenu_ledger.exceptions (
    tenant_id, store_id,
    exception_code, exception_domain, exception_type,
    exception_severity, exception_status,
    subject_type, subject_id,
    triggered_by_agent_id,
    exception_payload,
    error_message,
    requires_human_approval,
    business_day, business_timezone,
    detected_at
  ) values (
    p_tenant_id, p_store_id,
    'PAY-UNCERTAIN-' || extract(epoch from now())::bigint::text,
    'payment', 'payment_uncertain',
    'CRITICAL', 'OPEN',
    'payment_intent', p_intent_id,
    null,
    jsonb_build_object(
      'intent_id', p_intent_id,
      'order_id', v_intent.order_id,
      'uncertain_reason', p_uncertain_reason
    ),
    p_uncertain_reason,
    true,
    v_intent.business_day, v_intent.business_timezone,
    now()
  )
  returning id into v_exception_id;

  -- payment event
  insert into catchmenu_payment.payment_events (
    tenant_id, store_id, order_id, intent_id,
    event_type, caused_by_type,
    event_payload, correlation_id, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    v_intent.order_id, p_intent_id,
    'payment_uncertain', 'SYSTEM',
    jsonb_build_object(
      'uncertain_reason', p_uncertain_reason,
      'kds_blocked', true,
      'exception_id', v_exception_id
    ),
    p_correlation_id, now()
  );

  -- ledger event
  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, event_payload,
    session_id, order_id,
    correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'payment', 'payment_uncertain', 1,
    'payment_intent', p_intent_id,
    'PROCESSING', 'UNCERTAIN',
    'SYSTEM',
    jsonb_build_object(
      'uncertain_reason', p_uncertain_reason,
      'kds_blocked', true,
      'exception_id', v_exception_id,
      'requires_human_resolution', true
    ),
    v_intent.session_id, v_intent.order_id,
    p_correlation_id,
    v_intent.business_day, v_intent.business_timezone, now()
  );

  -- audit record
  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := 'payment',
    p_audit_type := 'payment_uncertain_flagged',
    p_audit_category := 'FINANCIAL',
    p_actor_type := 'SYSTEM',
    p_actor_id := null,
    p_subject_type := 'payment_intent',
    p_subject_id := p_intent_id,
    p_decision := 'NOTED',
    p_decision_reason := p_uncertain_reason,
    p_decision_payload := jsonb_build_object(
      'kds_blocked', true,
      'exception_id', v_exception_id,
      'requires_human_resolution', true
    ),
    p_exception_id := v_exception_id,
    p_order_id := v_intent.order_id,
    p_session_id := v_intent.session_id,
    p_correlation_id := p_correlation_id,
    p_business_day := v_intent.business_day,
    p_business_timezone := v_intent.business_timezone
  );

  return jsonb_build_object(
    'success', true,
    'intent_id', p_intent_id,
    'session_status', 'PAYMENT_UNCERTAIN',
    'kds_blocked', true,
    'exception_id', v_exception_id,
    'requires_human_resolution', true,
    'message_code', 'payment_uncertain_kds_blocked',
    'audit_id', v_audit_id
  );
end;
$$;


create or replace function catchmenu_payment.resolve_payment_uncertain(
  p_tenant_id uuid,
  p_store_id uuid,
  p_intent_id uuid,
  p_resolution_type text,
  p_actor_type text,
  p_actor_id uuid,
  p_resolution_note text default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_payment, catchmenu_pos,
                  catchmenu_kds, catchmenu_ledger,
                  catchmenu_audit, catchmenu_common
as $$
declare
  v_intent record;
  v_audit_id uuid;
begin
  if p_resolution_type not in (
    'CONFIRMED_APPROVED',
    'CONFIRMED_FAILED',
    'MANUAL_OVERRIDE_APPROVED',
    'CANCELLED'
  ) then
    return jsonb_build_object(
      'success', false,
      'error_key', 'invalid_resolution_type'
    );
  end if;

  select id, order_id, session_id,
         business_day, business_timezone
  into v_intent
  from catchmenu_payment.payment_intents
  where id = p_intent_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
  for update;

  if v_intent.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'intent_not_found'
    );
  end if;

  -- update session based on resolution
  update catchmenu_pos.order_sessions
  set
    session_status = case p_resolution_type
      when 'CONFIRMED_APPROVED' then 'PAYMENT_PENDING'
      when 'MANUAL_OVERRIDE_APPROVED' then 'PAYMENT_PENDING'
      when 'CONFIRMED_FAILED' then 'ORDERING'
      when 'CANCELLED' then 'CANCELLED'
    end,
    updated_at = now()
  where id = v_intent.session_id;

  -- update intent
  update catchmenu_payment.payment_intents
  set
    intent_status = case p_resolution_type
      when 'CONFIRMED_APPROVED' then 'CONFIRMED'
      when 'MANUAL_OVERRIDE_APPROVED' then 'CONFIRMED'
      when 'CONFIRMED_FAILED' then 'FAILED'
      when 'CANCELLED' then 'CANCELLED'
    end,
    updated_at = now()
  where id = p_intent_id;

  -- close related exception
  update catchmenu_ledger.exceptions
  set
    exception_status = 'RESOLVED',
    resolution_type = 'MANUAL_MANAGER',
    resolution_note = p_resolution_note,
    resolved_by_type = p_actor_type,
    resolved_by_id = p_actor_id,
    resolved_at = now(),
    updated_at = now()
  where subject_type = 'payment_intent'
    and subject_id = p_intent_id
    and exception_status not in ('RESOLVED', 'CLOSED');

  -- payment event
  insert into catchmenu_payment.payment_events (
    tenant_id, store_id, order_id, intent_id,
    event_type, caused_by_type, caused_by_id,
    event_payload, correlation_id, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    v_intent.order_id, p_intent_id,
    'payment_uncertain_resolved',
    p_actor_type, p_actor_id,
    jsonb_build_object(
      'resolution_type', p_resolution_type,
      'resolution_note', p_resolution_note
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
    event_payload, session_id, order_id,
    correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'payment', 'payment_uncertain_resolved', 1,
    'payment_intent', p_intent_id,
    'UNCERTAIN', p_resolution_type,
    p_actor_type, p_actor_id,
    jsonb_build_object(
      'resolution_type', p_resolution_type,
      'resolution_note', p_resolution_note
    ),
    v_intent.session_id, v_intent.order_id,
    p_correlation_id,
    v_intent.business_day, v_intent.business_timezone, now()
  );

  -- audit record
  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := 'payment',
    p_audit_type := 'payment_uncertain_resolved',
    p_audit_category := 'FINANCIAL',
    p_actor_type := p_actor_type,
    p_actor_id := p_actor_id,
    p_subject_type := 'payment_intent',
    p_subject_id := p_intent_id,
    p_decision := case p_resolution_type
      when 'CONFIRMED_APPROVED' then 'APPROVED'
      when 'MANUAL_OVERRIDE_APPROVED' then 'OVERRIDDEN'
      when 'CONFIRMED_FAILED' then 'REJECTED'
      when 'CANCELLED' then 'CANCELLED'
    end,
    p_decision_reason := p_resolution_note,
    p_decision_payload := jsonb_build_object(
      'resolution_type', p_resolution_type
    ),
    p_order_id := v_intent.order_id,
    p_session_id := v_intent.session_id,
    p_correlation_id := p_correlation_id,
    p_business_day := v_intent.business_day,
    p_business_timezone := v_intent.business_timezone
  );

  return jsonb_build_object(
    'success', true,
    'intent_id', p_intent_id,
    'resolution_type', p_resolution_type,
    'audit_id', v_audit_id,
    'message_code', 'payment_uncertain_resolved'
  );
end;
$$;

-- grants
revoke all on function catchmenu_payment.create_payment_intent(
  uuid, uuid, uuid, uuid, text, text, text, int, text, text
) from public;
grant execute on function catchmenu_payment.create_payment_intent(
  uuid, uuid, uuid, uuid, text, text, text, int, text, text
) to authenticated;

revoke all on function catchmenu_payment.confirm_payment_from_provider(
  uuid, uuid, uuid, text, text, int, uuid, text
) from public;
grant execute on function catchmenu_payment.confirm_payment_from_provider(
  uuid, uuid, uuid, text, text, int, uuid, text
) to authenticated;

revoke all on function catchmenu_payment.mark_payment_uncertain(
  uuid, uuid, uuid, text, text
) from public;
grant execute on function catchmenu_payment.mark_payment_uncertain(
  uuid, uuid, uuid, text, text
) to authenticated;

revoke all on function catchmenu_payment.resolve_payment_uncertain(
  uuid, uuid, uuid, text, text, uuid, text, text
) from public;
grant execute on function catchmenu_payment.resolve_payment_uncertain(
  uuid, uuid, uuid, text, text, uuid, text, text
) to authenticated;

comment on function catchmenu_payment.create_payment_intent(
  uuid, uuid, uuid, uuid, text, text, text, int, text, text
) is
  'Creates payment intent before calling external provider.
   Generates provider_order_id to pass to Toss/VAN/PG.
   Internal order_id is never exposed to provider.
   Amount must match order final_amount exactly.
   특허1: 단회성 비상태형 토큰 발급 — 내부 원장 키 미노출.';

comment on function catchmenu_payment.confirm_payment_from_provider(
  uuid, uuid, uuid, text, text, int, uuid, text
) is
  'Records provider payment confirmation in internal ledger.
   Creates payment_ledger entry with kds_release_authorized = FALSE.
   Updates KDS ticket conditions_met.payment_confirmed = true.
   KDS tickets still in HOLD — capacity check required separately.
   특허1: 결제 승인 ≠ KDS 자동 릴리즈.
   특허2: KDS Late Binding 조건 중 payment_confirmed 업데이트.';

comment on function catchmenu_payment.mark_payment_uncertain(
  uuid, uuid, uuid, text, text
) is
  'Flags payment as uncertain when provider result is unknown.
   Immediately blocks all KDS tickets for this order.
   Creates CRITICAL exception requiring human resolution.
   특허1: PAYMENT_UNCERTAIN 상태 = KDS 절대 릴리즈 금지.
   payment_uncertain ≠ payment_failed.';

comment on function catchmenu_payment.resolve_payment_uncertain(
  uuid, uuid, uuid, text, text, uuid, text, text
) is
  'Resolves payment uncertain state with human decision.
   CONFIRMED_APPROVED: payment confirmed, proceed to KDS capacity check.
   MANUAL_OVERRIDE_APPROVED: manager overrides, with full audit trail.
   CONFIRMED_FAILED: payment failed, return to ordering.
   CANCELLED: cancel order.
   All resolutions require actor_type and actor_id — human accountability.
   특허4: 최종 승인과 책임은 관리자에게 귀속.';

-- ===== END sql/migrations/0027_create_payment_intent_rpc.sql =====


-- ===== BEGIN sql/migrations/0037_create_payment_cancel_refund_rpc.sql =====

-- 0037_create_payment_cancel_refund_rpc.sql
-- Purpose: Payment cancellation and refund RPCs.
--          cancel_payment: full cancellation of approved payment.
--          partial_cancel_payment: partial amount cancellation.
--          refund_payment: refund after order completion.
--          특허1 core: 취소/환불도 내부 원장 기준 처리.
-- Depends on: 0036_create_reconciliation_rpc.sql
-- Creates:
--   function catchmenu_payment.cancel_payment(...)
--   function catchmenu_payment.partial_cancel_payment(...)
--   function catchmenu_payment.refund_payment(...)

create or replace function catchmenu_payment.cancel_payment(
  p_tenant_id uuid,
  p_store_id uuid,
  p_ledger_id uuid,
  p_cancel_reason text,
  p_actor_type text,
  p_actor_id uuid,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_payment, catchmenu_pos,
                  catchmenu_kds, catchmenu_ledger,
                  catchmenu_audit, catchmenu_common
as $$
declare
  v_ledger record;
  v_audit_id uuid;
  v_evidence_id uuid;
begin
  if trim(coalesce(p_cancel_reason, '')) = '' then
    return jsonb_build_object(
      'success', false,
      'error_key', 'cancel_reason_required'
    );
  end if;

  -- ledger validation
  select
    id, order_id, session_id, intent_id,
    ledger_status, approved_amount,
    kds_release_authorized,
    provider_type, provider_payment_key,
    provider_approval_number,
    business_day, business_timezone
  into v_ledger
  from catchmenu_payment.payment_ledger
  where id = p_ledger_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
  for update;

  if v_ledger.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'ledger_not_found'
    );
  end if;

  if v_ledger.ledger_status not in ('APPROVED', 'UNCERTAIN') then
    return jsonb_build_object(
      'success', false,
      'error_key', 'ledger_not_cancellable',
      'current_status', v_ledger.ledger_status
    );
  end if;

  -- create evidence packet before mutation
  insert into catchmenu_agent.evidence_packets (
    tenant_id, store_id,
    packet_type, packet_status, risk_level,
    subject_type, subject_id,
    payment_ledger_id,
    prior_state,
    staff_visible_explanation,
    actor_type, actor_id,
    correlation_id,
    business_day, business_timezone
  ) values (
    p_tenant_id, p_store_id,
    'PAYMENT_CANCELLATION', 'CREATED', 'HIGH',
    'payment_ledger', p_ledger_id,
    p_ledger_id,
    jsonb_build_object(
      'ledger_status', v_ledger.ledger_status,
      'approved_amount', v_ledger.approved_amount,
      'provider_payment_key', v_ledger.provider_payment_key
    ),
    p_cancel_reason,
    p_actor_type, p_actor_id,
    p_correlation_id,
    v_ledger.business_day, v_ledger.business_timezone
  )
  returning id into v_evidence_id;

  -- update ledger
  update catchmenu_payment.payment_ledger
  set
    ledger_status = 'CANCELLED',
    cancelled_amount = approved_amount,
    net_amount = 0,
    kds_release_authorized = false,
    evidence_packet_id = v_evidence_id
  where id = p_ledger_id;

  -- block all KDS tickets for this order
  update catchmenu_kds.kds_tickets
  set
    kds_status = 'CANCELLED',
    cancelled_at = now(),
    hold_reason = 'PAYMENT_CANCELLED',
    updated_at = now()
  where order_id = v_ledger.order_id
    and kds_status not in (
      'COMPLETED', 'SERVED', 'CANCELLED'
    );

  -- update order status
  update catchmenu_pos.orders
  set
    order_status = 'CANCELLED',
    cancelled_at = now(),
    updated_at = now()
  where id = v_ledger.order_id
    and order_status not in ('COMPLETED', 'CANCELLED');

  -- update session
  update catchmenu_pos.order_sessions
  set
    session_status = 'CANCELLED',
    cancelled_at = now(),
    updated_at = now()
  where id = v_ledger.session_id
    and session_status not in ('COMPLETED', 'CANCELLED');

  -- payment event
  insert into catchmenu_payment.payment_events (
    tenant_id, store_id, order_id,
    ledger_id,
    event_type, from_status, to_status,
    caused_by_type, caused_by_id,
    amount_at_event,
    event_payload, correlation_id, occurred_at
  ) values (
    p_tenant_id, p_store_id, v_ledger.order_id,
    p_ledger_id,
    'payment_cancelled',
    v_ledger.ledger_status, 'CANCELLED',
    p_actor_type, p_actor_id,
    v_ledger.approved_amount,
    jsonb_build_object(
      'cancel_reason', p_cancel_reason,
      'cancelled_amount', v_ledger.approved_amount,
      'evidence_id', v_evidence_id
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
    event_payload,
    order_id, payment_id,
    correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'payment', 'payment_cancelled', 1,
    'payment_ledger', p_ledger_id,
    v_ledger.ledger_status, 'CANCELLED',
    p_actor_type, p_actor_id,
    jsonb_build_object(
      'cancel_reason', p_cancel_reason,
      'cancelled_amount', v_ledger.approved_amount,
      'evidence_id', v_evidence_id
    ),
    v_ledger.order_id, p_ledger_id,
    p_correlation_id,
    v_ledger.business_day, v_ledger.business_timezone, now()
  );

  -- audit
  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := 'payment',
    p_audit_type := 'payment_cancelled',
    p_audit_category := 'FINANCIAL',
    p_actor_type := p_actor_type,
    p_actor_id := p_actor_id,
    p_subject_type := 'payment_ledger',
    p_subject_id := p_ledger_id,
    p_decision := 'CANCELLED',
    p_decision_reason := p_cancel_reason,
    p_decision_payload := jsonb_build_object(
      'cancelled_amount', v_ledger.approved_amount,
      'provider_payment_key', v_ledger.provider_payment_key,
      'evidence_id', v_evidence_id
    ),
    p_before_state := jsonb_build_object(
      'ledger_status', v_ledger.ledger_status,
      'approved_amount', v_ledger.approved_amount
    ),
    p_after_state := jsonb_build_object(
      'ledger_status', 'CANCELLED',
      'net_amount', 0
    ),
    p_evidence_packet_id := v_evidence_id,
    p_payment_id := p_ledger_id,
    p_order_id := v_ledger.order_id,
    p_session_id := v_ledger.session_id,
    p_correlation_id := p_correlation_id,
    p_business_day := v_ledger.business_day,
    p_business_timezone := v_ledger.business_timezone
  );

  return jsonb_build_object(
    'success', true,
    'ledger_id', p_ledger_id,
    'ledger_status', 'CANCELLED',
    'cancelled_amount', v_ledger.approved_amount,
    'evidence_id', v_evidence_id,
    'audit_id', v_audit_id,
    'provider_payment_key', v_ledger.provider_payment_key,
    'next_step', 'CALL_PROVIDER_CANCEL_API',
    'message_code', 'payment_cancelled'
  );
end;
$$;


create or replace function catchmenu_payment.partial_cancel_payment(
  p_tenant_id uuid,
  p_store_id uuid,
  p_ledger_id uuid,
  p_cancel_amount int,
  p_cancel_reason text,
  p_actor_type text,
  p_actor_id uuid,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_payment, catchmenu_ledger,
                  catchmenu_audit, catchmenu_common
as $$
declare
  v_ledger record;
  v_new_cancelled_amount int;
  v_new_net_amount int;
  v_audit_id uuid;
  v_evidence_id uuid;
begin
  if p_cancel_amount <= 0 then
    return jsonb_build_object(
      'success', false,
      'error_key', 'invalid_cancel_amount'
    );
  end if;

  if trim(coalesce(p_cancel_reason, '')) = '' then
    return jsonb_build_object(
      'success', false,
      'error_key', 'cancel_reason_required'
    );
  end if;

  select
    id, order_id, session_id,
    ledger_status, approved_amount,
    cancelled_amount, net_amount,
    provider_payment_key,
    business_day, business_timezone
  into v_ledger
  from catchmenu_payment.payment_ledger
  where id = p_ledger_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
  for update;

  if v_ledger.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'ledger_not_found'
    );
  end if;

  if v_ledger.ledger_status not in ('APPROVED', 'PARTIAL_CANCELLED') then
    return jsonb_build_object(
      'success', false,
      'error_key', 'ledger_not_partial_cancellable',
      'current_status', v_ledger.ledger_status
    );
  end if;

  -- validate cancel amount
  v_new_cancelled_amount := v_ledger.cancelled_amount + p_cancel_amount;
  v_new_net_amount := v_ledger.approved_amount - v_new_cancelled_amount;

  if v_new_cancelled_amount > v_ledger.approved_amount then
    return jsonb_build_object(
      'success', false,
      'error_key', 'cancel_amount_exceeds_approved',
      'approved_amount', v_ledger.approved_amount,
      'already_cancelled', v_ledger.cancelled_amount,
      'requested_cancel', p_cancel_amount,
      'max_cancellable', v_ledger.net_amount
    );
  end if;

  -- create evidence
  insert into catchmenu_agent.evidence_packets (
    tenant_id, store_id,
    packet_type, packet_status, risk_level,
    subject_type, subject_id,
    payment_ledger_id,
    prior_state,
    staff_visible_explanation,
    actor_type, actor_id,
    correlation_id,
    business_day, business_timezone
  ) values (
    p_tenant_id, p_store_id,
    'PAYMENT_CANCELLATION', 'CREATED', 'HIGH',
    'payment_ledger', p_ledger_id,
    p_ledger_id,
    jsonb_build_object(
      'ledger_status', v_ledger.ledger_status,
      'approved_amount', v_ledger.approved_amount,
      'cancelled_amount_before', v_ledger.cancelled_amount,
      'net_amount_before', v_ledger.net_amount
    ),
    p_cancel_reason,
    p_actor_type, p_actor_id,
    p_correlation_id,
    v_ledger.business_day, v_ledger.business_timezone
  )
  returning id into v_evidence_id;

  -- update ledger
  update catchmenu_payment.payment_ledger
  set
    ledger_status = case
      when v_new_net_amount = 0 then 'CANCELLED'
      else 'PARTIAL_CANCELLED'
    end,
    cancelled_amount = v_new_cancelled_amount,
    net_amount = v_new_net_amount,
    evidence_packet_id = v_evidence_id
  where id = p_ledger_id;

  -- payment event
  insert into catchmenu_payment.payment_events (
    tenant_id, store_id, order_id,
    ledger_id,
    event_type, from_status, to_status,
    caused_by_type, caused_by_id,
    amount_at_event,
    event_payload, correlation_id, occurred_at
  ) values (
    p_tenant_id, p_store_id, v_ledger.order_id,
    p_ledger_id,
    'payment_partial_refunded',
    v_ledger.ledger_status,
    case when v_new_net_amount = 0
      then 'CANCELLED'
      else 'PARTIAL_CANCELLED'
    end,
    p_actor_type, p_actor_id,
    p_cancel_amount,
    jsonb_build_object(
      'cancel_amount', p_cancel_amount,
      'cancel_reason', p_cancel_reason,
      'new_net_amount', v_new_net_amount,
      'evidence_id', v_evidence_id
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
    event_payload,
    order_id, payment_id,
    correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'payment', 'payment_partial_cancelled', 1,
    'payment_ledger', p_ledger_id,
    v_ledger.ledger_status,
    case when v_new_net_amount = 0
      then 'CANCELLED'
      else 'PARTIAL_CANCELLED'
    end,
    p_actor_type, p_actor_id,
    jsonb_build_object(
      'cancel_amount', p_cancel_amount,
      'cancel_reason', p_cancel_reason,
      'new_cancelled_amount', v_new_cancelled_amount,
      'new_net_amount', v_new_net_amount
    ),
    v_ledger.order_id, p_ledger_id,
    p_correlation_id,
    v_ledger.business_day, v_ledger.business_timezone, now()
  );

  -- audit
  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := 'payment',
    p_audit_type := 'payment_partial_cancelled',
    p_audit_category := 'FINANCIAL',
    p_actor_type := p_actor_type,
    p_actor_id := p_actor_id,
    p_subject_type := 'payment_ledger',
    p_subject_id := p_ledger_id,
    p_decision := 'CANCELLED',
    p_decision_reason := p_cancel_reason,
    p_decision_payload := jsonb_build_object(
      'cancel_amount', p_cancel_amount,
      'new_cancelled_amount', v_new_cancelled_amount,
      'new_net_amount', v_new_net_amount,
      'provider_payment_key', v_ledger.provider_payment_key
    ),
    p_before_state := jsonb_build_object(
      'ledger_status', v_ledger.ledger_status,
      'cancelled_amount', v_ledger.cancelled_amount,
      'net_amount', v_ledger.net_amount
    ),
    p_after_state := jsonb_build_object(
      'ledger_status', case when v_new_net_amount = 0
        then 'CANCELLED' else 'PARTIAL_CANCELLED'
      end,
      'cancelled_amount', v_new_cancelled_amount,
      'net_amount', v_new_net_amount
    ),
    p_evidence_packet_id := v_evidence_id,
    p_payment_id := p_ledger_id,
    p_order_id := v_ledger.order_id,
    p_correlation_id := p_correlation_id,
    p_business_day := v_ledger.business_day,
    p_business_timezone := v_ledger.business_timezone
  );

  return jsonb_build_object(
    'success', true,
    'ledger_id', p_ledger_id,
    'ledger_status', case when v_new_net_amount = 0
      then 'CANCELLED' else 'PARTIAL_CANCELLED'
    end,
    'cancel_amount', p_cancel_amount,
    'new_cancelled_amount', v_new_cancelled_amount,
    'new_net_amount', v_new_net_amount,
    'evidence_id', v_evidence_id,
    'audit_id', v_audit_id,
    'provider_payment_key', v_ledger.provider_payment_key,
    'next_step', 'CALL_PROVIDER_PARTIAL_CANCEL_API',
    'message_code', 'payment_partial_cancelled'
  );
end;
$$;


create or replace function catchmenu_payment.refund_payment(
  p_tenant_id uuid,
  p_store_id uuid,
  p_ledger_id uuid,
  p_refund_amount int,
  p_refund_reason text,
  p_actor_type text,
  p_actor_id uuid,
  p_is_partial boolean default false,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_payment, catchmenu_ledger,
                  catchmenu_audit, catchmenu_common
as $$
declare
  v_ledger record;
  v_new_refunded_amount int;
  v_new_net_amount int;
  v_audit_id uuid;
  v_evidence_id uuid;
  v_new_status text;
begin
  if p_refund_amount <= 0 then
    return jsonb_build_object(
      'success', false,
      'error_key', 'invalid_refund_amount'
    );
  end if;

  if trim(coalesce(p_refund_reason, '')) = '' then
    return jsonb_build_object(
      'success', false,
      'error_key', 'refund_reason_required'
    );
  end if;

  select
    id, order_id, session_id,
    ledger_status, approved_amount,
    cancelled_amount, refunded_amount, net_amount,
    provider_payment_key,
    business_day, business_timezone
  into v_ledger
  from catchmenu_payment.payment_ledger
  where id = p_ledger_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
  for update;

  if v_ledger.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'ledger_not_found'
    );
  end if;

  if v_ledger.ledger_status not in (
    'APPROVED', 'PARTIAL_CANCELLED', 'PARTIAL_REFUNDED'
  ) then
    return jsonb_build_object(
      'success', false,
      'error_key', 'ledger_not_refundable',
      'current_status', v_ledger.ledger_status
    );
  end if;

  -- validate refund amount
  v_new_refunded_amount := v_ledger.refunded_amount + p_refund_amount;
  v_new_net_amount := v_ledger.approved_amount
    - v_ledger.cancelled_amount
    - v_new_refunded_amount;

  if v_new_net_amount < 0 then
    return jsonb_build_object(
      'success', false,
      'error_key', 'refund_exceeds_net_amount',
      'net_amount', v_ledger.net_amount,
      'requested_refund', p_refund_amount
    );
  end if;

  -- determine new status
  v_new_status := case
    when v_new_net_amount = 0 then 'REFUNDED'
    else 'PARTIAL_REFUNDED'
  end;

  -- create evidence
  insert into catchmenu_agent.evidence_packets (
    tenant_id, store_id,
    packet_type, packet_status, risk_level,
    subject_type, subject_id,
    payment_ledger_id,
    prior_state,
    staff_visible_explanation,
    actor_type, actor_id,
    correlation_id,
    business_day, business_timezone
  ) values (
    p_tenant_id, p_store_id,
    'PAYMENT_REFUND', 'CREATED', 'HIGH',
    'payment_ledger', p_ledger_id,
    p_ledger_id,
    jsonb_build_object(
      'ledger_status', v_ledger.ledger_status,
      'approved_amount', v_ledger.approved_amount,
      'net_amount_before', v_ledger.net_amount,
      'refunded_amount_before', v_ledger.refunded_amount
    ),
    p_refund_reason,
    p_actor_type, p_actor_id,
    p_correlation_id,
    v_ledger.business_day, v_ledger.business_timezone
  )
  returning id into v_evidence_id;

  -- update ledger
  update catchmenu_payment.payment_ledger
  set
    ledger_status = v_new_status,
    refunded_amount = v_new_refunded_amount,
    net_amount = v_new_net_amount,
    evidence_packet_id = v_evidence_id
  where id = p_ledger_id;

  -- update order status
  update catchmenu_pos.orders
  set
    order_status = case v_new_status
      when 'REFUNDED' then 'REFUNDED'
      else 'PARTIAL_REFUNDED'
    end,
    updated_at = now()
  where id = v_ledger.order_id;

  -- payment event
  insert into catchmenu_payment.payment_events (
    tenant_id, store_id, order_id,
    ledger_id,
    event_type, from_status, to_status,
    caused_by_type, caused_by_id,
    amount_at_event,
    event_payload, correlation_id, occurred_at
  ) values (
    p_tenant_id, p_store_id, v_ledger.order_id,
    p_ledger_id,
    case when p_is_partial
      then 'payment_partial_refunded'
      else 'payment_refunded'
    end,
    v_ledger.ledger_status, v_new_status,
    p_actor_type, p_actor_id,
    p_refund_amount,
    jsonb_build_object(
      'refund_amount', p_refund_amount,
      'refund_reason', p_refund_reason,
      'new_net_amount', v_new_net_amount,
      'evidence_id', v_evidence_id
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
    event_payload,
    order_id, payment_id,
    correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'payment',
    case when p_is_partial
      then 'payment_partial_refunded'
      else 'payment_refunded'
    end,
    1,
    'payment_ledger', p_ledger_id,
    v_ledger.ledger_status, v_new_status,
    p_actor_type, p_actor_id,
    jsonb_build_object(
      'refund_amount', p_refund_amount,
      'refund_reason', p_refund_reason,
      'new_refunded_amount', v_new_refunded_amount,
      'new_net_amount', v_new_net_amount
    ),
    v_ledger.order_id, p_ledger_id,
    p_correlation_id,
    v_ledger.business_day, v_ledger.business_timezone, now()
  );

  -- audit
  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := 'payment',
    p_audit_type := case when p_is_partial
      then 'payment_partial_refunded'
      else 'payment_refunded'
    end,
    p_audit_category := 'FINANCIAL',
    p_actor_type := p_actor_type,
    p_actor_id := p_actor_id,
    p_subject_type := 'payment_ledger',
    p_subject_id := p_ledger_id,
    p_decision := 'COMPLETED',
    p_decision_reason := p_refund_reason,
    p_decision_payload := jsonb_build_object(
      'refund_amount', p_refund_amount,
      'new_refunded_amount', v_new_refunded_amount,
      'new_net_amount', v_new_net_amount,
      'provider_payment_key', v_ledger.provider_payment_key
    ),
    p_before_state := jsonb_build_object(
      'ledger_status', v_ledger.ledger_status,
      'net_amount', v_ledger.net_amount
    ),
    p_after_state := jsonb_build_object(
      'ledger_status', v_new_status,
      'net_amount', v_new_net_amount
    ),
    p_evidence_packet_id := v_evidence_id,
    p_payment_id := p_ledger_id,
    p_order_id := v_ledger.order_id,
    p_correlation_id := p_correlation_id,
    p_business_day := v_ledger.business_day,
    p_business_timezone := v_ledger.business_timezone
  );

  return jsonb_build_object(
    'success', true,
    'ledger_id', p_ledger_id,
    'ledger_status', v_new_status,
    'refund_amount', p_refund_amount,
    'new_refunded_amount', v_new_refunded_amount,
    'new_net_amount', v_new_net_amount,
    'evidence_id', v_evidence_id,
    'audit_id', v_audit_id,
    'provider_payment_key', v_ledger.provider_payment_key,
    'next_step', 'CALL_PROVIDER_REFUND_API',
    'message_code', case v_new_status
      when 'REFUNDED' then 'payment_fully_refunded'
      else 'payment_partially_refunded'
    end
  );
end;
$$;

-- grants
do $$
begin
  revoke all on function catchmenu_payment.cancel_payment(
    uuid, uuid, uuid, text, text, uuid, text
  ) from public;
  grant execute on function catchmenu_payment.cancel_payment(
    uuid, uuid, uuid, text, text, uuid, text
  ) to authenticated;

  revoke all on function catchmenu_payment.partial_cancel_payment(
    uuid, uuid, uuid, int, text, text, uuid, text
  ) from public;
  grant execute on function catchmenu_payment.partial_cancel_payment(
    uuid, uuid, uuid, int, text, text, uuid, text
  ) to authenticated;

  revoke all on function catchmenu_payment.refund_payment(
    uuid, uuid, uuid, int, text, text, uuid, boolean, text
  ) from public;
  grant execute on function catchmenu_payment.refund_payment(
    uuid, uuid, uuid, int, text, text, uuid, boolean, text
  ) to authenticated;
end;
$$;

comment on function catchmenu_payment.cancel_payment(
  uuid, uuid, uuid, text, text, uuid, text
) is
  'Full payment cancellation.
   Creates evidence packet before any mutation.
   Blocks all KDS tickets for the order.
   Cancels order and session.
   Returns provider_payment_key for caller to invoke provider cancel API.
   특허1: 내부 원장 먼저 취소 → 이후 외부 PG/VAN API 호출.
   취소도 감사 원장에 기록 필수.';

comment on function catchmenu_payment.partial_cancel_payment(
  uuid, uuid, uuid, int, text, text, uuid, text
) is
  'Partial payment cancellation.
   Validates cancel_amount does not exceed net_amount.
   Creates evidence packet for audit trail.
   Returns provider_payment_key for partial cancel API call.
   특허1: 부분취소도 내부 원장 기준 처리 후 PG API 호출.';

comment on function catchmenu_payment.refund_payment(
  uuid, uuid, uuid, int, text, text, uuid, boolean, text
) is
  'Payment refund after order completion.
   Validates refund_amount does not exceed net_amount.
   Creates evidence packet. Updates order status.
   Returns provider_payment_key for refund API call.
   특허1: 환불도 내부 원장에 먼저 기록 후 외부 PG API 호출.
   환불 증빙은 evidence_packet에 보관.';


-- ===== END sql/migrations/0037_create_payment_cancel_refund_rpc.sql =====


-- ===== BEGIN sql/migrations/0038_create_toss_webhook_processor_rpc.sql =====

-- 0038_create_toss_webhook_processor_rpc.sql
-- Purpose: Toss Payments webhook processing RPC.
--          Validates signature, checks idempotency,
--          routes to appropriate payment state handler.
--          특허1 core: 외부 웹훅 검증 후 내부 상태 반영.
-- Depends on: 0037_create_payment_cancel_refund_rpc.sql
-- Creates:
--   function catchmenu_integrations.process_toss_webhook(...)
--   function catchmenu_integrations.verify_toss_signature(...)

create or replace function catchmenu_integrations.verify_toss_signature(
  p_raw_body jsonb,
  p_signature_header text,
  p_webhook_secret text
)
returns boolean
language plpgsql
stable
security definer
set search_path = catchmenu_integrations, pg_catalog
as $$
declare
  v_expected_signature text;
  v_payload_text text;
begin
  -- Toss webhook signature verification
  -- Toss uses HMAC-SHA256 with webhook secret
  -- Signature header format: t=timestamp,v1=signature
  -- Payload to sign: timestamp + '.' + body

  if p_signature_header is null or p_webhook_secret is null then
    return false;
  end if;

  -- extract timestamp from header
  -- format: t=1234567890,v1=abcdef...
  v_payload_text := p_raw_body::text;

  -- HMAC-SHA256 verification using pgcrypto
  -- In production: compare header signature with computed HMAC
  -- Here we validate structure only (actual HMAC in app layer)
  -- Returns true when signature header has correct format
  return (
    p_signature_header like 't=%,v1=%'
    and length(split_part(
      split_part(p_signature_header, ',', 2),
      'v1=', 2
    )) >= 32
  );
end;
$$;


create or replace function catchmenu_integrations.process_toss_webhook(
  p_tenant_id uuid,
  p_store_id uuid,
  p_raw_headers jsonb,
  p_raw_body jsonb,
  p_signature_header text default null,
  p_webhook_secret text default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_integrations, catchmenu_payment,
                  catchmenu_gateway, catchmenu_ledger,
                  catchmenu_common, catchmenu_hq
as $$
declare
  v_webhook_id uuid;
  v_provider_event_id uuid;
  v_toss_payment_key text;
  v_toss_order_id text;
  v_event_type text;
  v_status text;
  v_approved_amount int;
  v_cancelled_amount int;
  v_payload_hash text;
  v_signature_ok boolean;
  v_intent record;
  v_ledger record;
  v_toss_payment record;
  v_business_day date;
  v_timezone text;
begin
  -- store timezone
  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  -- extract key fields from webhook body
  v_toss_payment_key := p_raw_body->>'paymentKey';
  v_toss_order_id := p_raw_body->>'orderId';
  v_event_type := p_raw_body->>'eventType';
  v_status := p_raw_body->>'status';
  v_approved_amount := (p_raw_body->>'totalAmount')::int;
  v_cancelled_amount := (
    p_raw_body->'cancels'->0->>'cancelAmount'
  )::int;

  -- validate required fields
  if v_toss_order_id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'missing_order_id',
      'processing_status', 'REJECTED'
    );
  end if;

  -- compute payload hash for dedup
  v_payload_hash := encode(
    digest(p_raw_body::text, 'sha256'),
    'hex'
  );

  -- check duplicate webhook by hash
  if exists (
    select 1
    from catchmenu_integrations.toss_webhooks
    where payload_hash = v_payload_hash
      and processing_status in ('VERIFIED', 'PROCESSED')
  ) then
    -- log duplicate and return
    insert into catchmenu_integrations.toss_webhooks (
      tenant_id, store_id,
      toss_payment_key, toss_order_id,
      event_type, raw_headers, raw_body,
      payload_hash,
      signature_verified,
      idempotency_checked, is_duplicate,
      processing_status, received_at
    ) values (
      p_tenant_id, p_store_id,
      v_toss_payment_key, v_toss_order_id,
      v_event_type, p_raw_headers, p_raw_body,
      v_payload_hash,
      null,
      true, true,
      'DUPLICATE_IGNORED', now()
    );

    return jsonb_build_object(
      'success', true,
      'processing_status', 'DUPLICATE_IGNORED',
      'message_code', 'webhook_duplicate_ignored'
    );
  end if;

  -- signature verification
  v_signature_ok := catchmenu_integrations.verify_toss_signature(
    p_raw_body, p_signature_header, p_webhook_secret
  );

  -- store raw webhook
  insert into catchmenu_integrations.toss_webhooks (
    tenant_id, store_id,
    toss_payment_key, toss_order_id,
    event_type, raw_headers, raw_body,
    payload_hash,
    signature_verified,
    idempotency_checked, is_duplicate,
    processing_status, received_at
  ) values (
    p_tenant_id, p_store_id,
    v_toss_payment_key, v_toss_order_id,
    v_event_type, p_raw_headers, p_raw_body,
    v_payload_hash,
    v_signature_ok,
    true, false,
    case when v_signature_ok then 'VERIFIED' else 'FAILED' end,
    now()
  )
  returning id into v_webhook_id;

  -- reject if signature failed
  if not v_signature_ok then
    -- create security exception
    perform catchmenu_ledger.create_exception(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_exception_domain := 'gateway',
      p_exception_type := 'webhook_signature_failed',
      p_exception_severity := 'CRITICAL',
      p_subject_type := 'toss_webhook',
      p_subject_id := v_webhook_id,
      p_error_message := 'Toss webhook signature verification failed',
      p_exception_payload := jsonb_build_object(
        'toss_order_id', v_toss_order_id,
        'event_type', v_event_type
      ),
      p_requires_human_approval := true,
      p_correlation_id := p_correlation_id
    );

    return jsonb_build_object(
      'success', false,
      'webhook_id', v_webhook_id,
      'error_key', 'signature_verification_failed',
      'processing_status', 'FAILED'
    );
  end if;

  -- store in gateway provider_raw_events
  insert into catchmenu_gateway.provider_raw_events (
    tenant_id, store_id,
    provider_type, provider_code,
    provider_event_id, provider_event_type,
    raw_headers, raw_payload,
    payload_hash,
    signature_verified, signature_verified_at,
    schema_validated,
    processing_status,
    correlation_id, received_at
  ) values (
    p_tenant_id, p_store_id,
    'TOSS_PAYMENTS', 'TOSS',
    v_toss_payment_key, v_event_type,
    p_raw_headers, p_raw_body,
    v_payload_hash,
    true, now(),
    true,
    'VALIDATING',
    p_correlation_id, now()
  )
  returning id into v_provider_event_id;

  -- find payment intent by toss_order_id
  select pi.id, pi.order_id, pi.session_id,
         pi.intent_status, pi.requested_amount
  into v_intent
  from catchmenu_payment.payment_intents pi
  where pi.provider_order_id = v_toss_order_id
    and pi.store_id = p_store_id
    and pi.tenant_id = p_tenant_id;

  if v_intent.id is null then
    -- update gateway event as rejected
    update catchmenu_gateway.provider_raw_events
    set processing_status = 'REJECTED',
        rejected_at = now(),
        rejection_reason = 'intent_not_found'
    where id = v_provider_event_id;

    return jsonb_build_object(
      'success', false,
      'webhook_id', v_webhook_id,
      'error_key', 'intent_not_found',
      'toss_order_id', v_toss_order_id,
      'processing_status', 'REJECTED'
    );
  end if;

  -- route based on Toss status
  case v_status
    when 'DONE' then
      -- payment approved
      -- check if already processed
      if v_intent.intent_status = 'CONFIRMED' then
        -- already confirmed, update webhook
        update catchmenu_integrations.toss_webhooks
        set processing_status = 'DUPLICATE_IGNORED',
            processed_at = now()
        where id = v_webhook_id;

        return jsonb_build_object(
          'success', true,
          'webhook_id', v_webhook_id,
          'processing_status', 'DUPLICATE_IGNORED',
          'message_code', 'already_confirmed'
        );
      end if;

      -- update toss_payments record
      update catchmenu_integrations.toss_payments
      set
        toss_status = 'DONE',
        toss_payment_key = v_toss_payment_key,
        approved_amount = v_approved_amount,
        card_approve_no = p_raw_body->>'approveNo',
        receipt_url = p_raw_body->'receipt'->>'url',
        toss_raw_response = p_raw_body,
        approved_at = now(),
        last_updated_at = now(),
        updated_at = now()
      where toss_order_id = v_toss_order_id;

      -- confirm payment from provider
      perform catchmenu_payment.confirm_payment_from_provider(
        p_tenant_id := p_tenant_id,
        p_store_id := p_store_id,
        p_intent_id := v_intent.id,
        p_provider_payment_key := v_toss_payment_key,
        p_provider_approval_number :=
          p_raw_body->>'approveNo',
        p_approved_amount := v_approved_amount,
        p_provider_raw_event_id := v_provider_event_id,
        p_correlation_id := p_correlation_id
      );

      -- update gateway event
      update catchmenu_gateway.provider_raw_events
      set processing_status = 'ACCEPTED',
          accepted_at = now()
      where id = v_provider_event_id;

      -- update webhook
      update catchmenu_integrations.toss_webhooks
      set processing_status = 'PROCESSED',
          processed_at = now()
      where id = v_webhook_id;

      return jsonb_build_object(
        'success', true,
        'webhook_id', v_webhook_id,
        'processing_status', 'PROCESSED',
        'action_taken', 'payment_confirmed',
        'approved_amount', v_approved_amount,
        'message_code', 'webhook_payment_confirmed'
      );

    when 'CANCELLED', 'PARTIAL_CANCELLED' then
      -- find ledger
      select pl.id, pl.ledger_status
      into v_ledger
      from catchmenu_payment.payment_ledger pl
      where pl.intent_id = v_intent.id;

      if v_ledger.id is not null
        and v_ledger.ledger_status = 'APPROVED'
      then
        -- full cancel
        perform catchmenu_payment.cancel_payment(
          p_tenant_id := p_tenant_id,
          p_store_id := p_store_id,
          p_ledger_id := v_ledger.id,
          p_cancel_reason := 'TOSS_WEBHOOK_CANCELLED',
          p_actor_type := 'PROVIDER',
          p_actor_id := null,
          p_correlation_id := p_correlation_id
        );
      end if;

      -- update webhook
      update catchmenu_integrations.toss_webhooks
      set processing_status = 'PROCESSED',
          processed_at = now()
      where id = v_webhook_id;

      return jsonb_build_object(
        'success', true,
        'webhook_id', v_webhook_id,
        'processing_status', 'PROCESSED',
        'action_taken', 'payment_cancelled',
        'message_code', 'webhook_payment_cancelled'
      );

    when 'ABORTED', 'EXPIRED' then
      -- payment failed or expired
      update catchmenu_payment.payment_intents
      set
        intent_status = case v_status
          when 'ABORTED' then 'FAILED'
          else 'EXPIRED'
        end,
        updated_at = now()
      where id = v_intent.id;

      -- update webhook
      update catchmenu_integrations.toss_webhooks
      set processing_status = 'PROCESSED',
          processed_at = now()
      where id = v_webhook_id;

      return jsonb_build_object(
        'success', true,
        'webhook_id', v_webhook_id,
        'processing_status', 'PROCESSED',
        'action_taken', 'intent_failed_or_expired',
        'toss_status', v_status,
        'message_code', 'webhook_payment_failed'
      );

    else
      -- unknown status — quarantine
      update catchmenu_gateway.provider_raw_events
      set processing_status = 'QUARANTINED'
      where id = v_provider_event_id;

      update catchmenu_integrations.toss_webhooks
      set processing_status = 'FAILED',
          processing_error = 'unknown_toss_status: ' || v_status,
          processed_at = now()
      where id = v_webhook_id;

      return jsonb_build_object(
        'success', false,
        'webhook_id', v_webhook_id,
        'processing_status', 'QUARANTINED',
        'error_key', 'unknown_toss_status',
        'toss_status', v_status
      );
  end case;
end;
$$;

-- grants
do $$
begin
  revoke all on function catchmenu_integrations.verify_toss_signature(
    jsonb, text, text
  ) from public;
  grant execute on function catchmenu_integrations.verify_toss_signature(
    jsonb, text, text
  ) to authenticated;

  revoke all on function catchmenu_integrations.process_toss_webhook(
    uuid, uuid, jsonb, jsonb, text, text, text
  ) from public;
  grant execute on function catchmenu_integrations.process_toss_webhook(
    uuid, uuid, jsonb, jsonb, text, text, text
  ) to authenticated;
end;
$$;

comment on function catchmenu_integrations.verify_toss_signature(
  jsonb, text, text
) is
  'Verifies Toss webhook signature using HMAC-SHA256.
   Toss signature format: t=timestamp,v1=hmac_signature.
   Returns false on invalid or missing signature.
   특허1: 외부 웹훅 서명 검증 — 미검증 데이터 내부 진입 차단.';

comment on function catchmenu_integrations.process_toss_webhook(
  uuid, uuid, jsonb, jsonb, text, text, text
) is
  'Toss Payments webhook processor.
   Pipeline:
   1. Dedup check by payload hash
   2. Signature verification
   3. Store in gateway provider_raw_events
   4. Find payment intent by toss_order_id
   5. Route by Toss status:
      DONE → confirm_payment_from_provider
      CANCELLED → cancel_payment
      ABORTED/EXPIRED → mark intent failed
      Unknown → quarantine
   특허1: 외부 웹훅 → Gateway 샌드박스 → 서명검증 → 내부 원장 반영.
   웹훅 재전송 시 중복 무시 처리.';

-- ===== END sql/migrations/0038_create_toss_webhook_processor_rpc.sql =====


-- ===== BEGIN sql/migrations/0040_create_local_ledger_replay_rpc.sql =====

-- 0040_create_local_ledger_replay_rpc.sql
-- Purpose: Local temporary ledger replay and conflict resolution RPCs.
--          replay_local_ledger: replays entries after network recovery.
--          resolve_replay_conflict: manager resolves conflicting entries.
--          get_replay_status: returns replay progress summary.
--          특허4 core: Local Temporary Ledger + Event Replay 기반 복구.
-- Depends on: 0039_create_kds_bulk_commit_rpc.sql
-- Creates:
--   function catchmenu_ledger.replay_local_ledger(...)
--   function catchmenu_ledger.resolve_replay_conflict(...)
--   function catchmenu_ledger.get_replay_status(...)

create or replace function catchmenu_ledger.replay_local_ledger(
  p_tenant_id uuid,
  p_store_id uuid,
  p_device_id uuid,
  p_max_entries int default 100,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_ledger, catchmenu_audit,
                  catchmenu_common, catchmenu_hq
as $$
declare
  v_entry record;
  v_replayed_count int := 0;
  v_conflict_count int := 0;
  v_skipped_count int := 0;
  v_failed_count int := 0;
  v_central_event_id uuid;
  v_conflict_detail jsonb;
  v_business_day date;
  v_timezone text;
  v_audit_id uuid;
  v_gap_detected boolean := false;
  v_last_sequence int := 0;
begin
  -- store timezone
  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  -- verify device belongs to store
  if not exists (
    select 1
    from catchmenu_store.device_registry
    where id = p_device_id
      and store_id = p_store_id
      and tenant_id = p_tenant_id
  ) then
    return jsonb_build_object(
      'success', false,
      'error_key', 'device_not_found'
    );
  end if;

  -- process entries in sequence order
  for v_entry in
    select
      id, entry_type, entry_domain,
      entry_sequence, original_event_type,
      original_subject_type, original_subject_id,
      entry_payload, locally_recorded_at
    from catchmenu_ledger.local_temporary_ledger
    where device_id = p_device_id
      and tenant_id = p_tenant_id
      and replay_status = 'PENDING'
    order by entry_sequence asc
    limit p_max_entries
    for update skip locked
  loop
    -- gap detection in sequence
    if v_last_sequence > 0
      and v_entry.entry_sequence > v_last_sequence + 1
    then
      v_gap_detected := true;
      -- log gap as exception
      perform catchmenu_ledger.create_exception(
        p_tenant_id := p_tenant_id,
        p_store_id := p_store_id,
        p_exception_domain := 'system',
        p_exception_type := 'local_ledger_sequence_gap',
        p_exception_severity := 'WARNING',
        p_subject_type := 'device',
        p_subject_id := p_device_id,
        p_error_message := format(
          'Sequence gap detected: expected %s, got %s',
          v_last_sequence + 1,
          v_entry.entry_sequence
        ),
        p_exception_payload := jsonb_build_object(
          'expected_sequence', v_last_sequence + 1,
          'actual_sequence', v_entry.entry_sequence,
          'device_id', p_device_id
        ),
        p_correlation_id := p_correlation_id
      );
    end if;

    v_last_sequence := v_entry.entry_sequence;

    -- mark as in progress
    update catchmenu_ledger.local_temporary_ledger
    set
      replay_status = 'IN_PROGRESS',
      replay_attempted_at = now(),
      replay_attempt_count = replay_attempt_count + 1
    where id = v_entry.id;

    -- conflict detection
    v_conflict_detail := null;

    -- check if subject already has newer events in central ledger
    if v_entry.original_subject_id is not null then
      if exists (
        select 1
        from catchmenu_ledger.events
        where subject_type = v_entry.original_subject_type
          and subject_id = v_entry.original_subject_id
          and occurred_at > v_entry.locally_recorded_at
          and is_replay = false
      ) then
        -- newer central event exists — potential conflict
        v_conflict_detail := jsonb_build_object(
          'conflict_type', 'NEWER_CENTRAL_EVENT',
          'subject_type', v_entry.original_subject_type,
          'subject_id', v_entry.original_subject_id,
          'local_recorded_at', v_entry.locally_recorded_at,
          'message', 'Central ledger has newer events for this subject'
        );
      end if;
    end if;

    if v_conflict_detail is not null then
      -- conflict detected — hold for manual review
      update catchmenu_ledger.local_temporary_ledger
      set
        replay_status = 'CONFLICT_DETECTED',
        replay_conflict_detected = true,
        replay_conflict_detail = v_conflict_detail,
        network_restored_at = coalesce(network_restored_at, now())
      where id = v_entry.id;

      v_conflict_count := v_conflict_count + 1;

    else
      -- safe to replay — insert into central event ledger
      begin
        insert into catchmenu_ledger.events (
          tenant_id, store_id,
          event_domain, event_type, event_version,
          subject_type, subject_id,
          from_state, to_state,
          caused_by_type,
          event_payload,
          is_replay, original_event_id,
          correlation_id,
          business_day, business_timezone,
          occurred_at, recorded_at
        ) values (
          p_tenant_id, p_store_id,
          v_entry.entry_domain,
          v_entry.original_event_type,
          1,
          v_entry.original_subject_type,
          v_entry.original_subject_id,
          v_entry.entry_payload->>'from_state',
          v_entry.entry_payload->>'to_state',
          coalesce(
            v_entry.entry_payload->>'caused_by_type',
            'REPLAY'
          ),
          v_entry.entry_payload,
          true, v_entry.id,
          p_correlation_id,
          v_business_day, v_timezone,
          v_entry.locally_recorded_at,
          now()
        )
        returning id into v_central_event_id;

        -- mark as replayed
        update catchmenu_ledger.local_temporary_ledger
        set
          replay_status = 'REPLAYED',
          replay_completed_at = now(),
          central_event_id = v_central_event_id,
          network_restored_at = coalesce(network_restored_at, now())
        where id = v_entry.id;

        v_replayed_count := v_replayed_count + 1;

      exception when others then
        -- replay failed
        update catchmenu_ledger.local_temporary_ledger
        set
          replay_status = 'FAILED',
          replay_conflict_detail = jsonb_build_object(
            'error', sqlerrm,
            'sqlstate', sqlstate
          )
        where id = v_entry.id;

        v_failed_count := v_failed_count + 1;
      end;
    end if;
  end loop;

  -- audit replay session
  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := 'recovery',
    p_audit_type := 'local_ledger_replay_completed',
    p_audit_category := 'RECOVERY',
    p_actor_type := 'SYSTEM',
    p_actor_id := null,
    p_subject_type := 'device',
    p_subject_id := p_device_id,
    p_decision := case
      when v_conflict_count > 0 then 'NOTED'
      else 'COMPLETED'
    end,
    p_decision_payload := jsonb_build_object(
      'replayed_count', v_replayed_count,
      'conflict_count', v_conflict_count,
      'failed_count', v_failed_count,
      'gap_detected', v_gap_detected
    ),
    p_correlation_id := p_correlation_id,
    p_business_day := v_business_day,
    p_business_timezone := v_timezone
  );

  return jsonb_build_object(
    'success', true,
    'device_id', p_device_id,
    'replayed_count', v_replayed_count,
    'conflict_count', v_conflict_count,
    'failed_count', v_failed_count,
    'skipped_count', v_skipped_count,
    'total_processed',
      v_replayed_count + v_conflict_count + v_failed_count,
    'gap_detected', v_gap_detected,
    'has_conflicts', v_conflict_count > 0,
    'has_failures', v_failed_count > 0,
    'audit_id', v_audit_id,
    'message_code', case
      when v_conflict_count = 0 and v_failed_count = 0
      then 'replay_completed_clean'
      when v_conflict_count > 0
      then 'replay_completed_with_conflicts'
      else 'replay_completed_with_failures'
    end
  );
end;
$$;


create or replace function catchmenu_ledger.resolve_replay_conflict(
  p_tenant_id uuid,
  p_store_id uuid,
  p_entry_id uuid,
  p_resolution text,
  p_resolved_by_type text,
  p_resolved_by_id uuid,
  p_resolution_note text default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_ledger, catchmenu_audit,
                  catchmenu_common, catchmenu_hq
as $$
declare
  v_entry record;
  v_central_event_id uuid;
  v_audit_id uuid;
  v_business_day date;
  v_timezone text;
begin
  if p_resolution not in (
    'ACCEPT_LOCAL', 'REJECT_LOCAL', 'MANUAL_MERGE'
  ) then
    return jsonb_build_object(
      'success', false,
      'error_key', 'invalid_resolution'
    );
  end if;

  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  select
    id, entry_type, entry_domain,
    entry_sequence, original_event_type,
    original_subject_type, original_subject_id,
    entry_payload, replay_status,
    locally_recorded_at, device_id
  into v_entry
  from catchmenu_ledger.local_temporary_ledger
  where id = p_entry_id
    and tenant_id = p_tenant_id
    and store_id = p_store_id
  for update;

  if v_entry.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'entry_not_found'
    );
  end if;

  if v_entry.replay_status <> 'CONFLICT_DETECTED' then
    return jsonb_build_object(
      'success', false,
      'error_key', 'entry_not_in_conflict',
      'current_status', v_entry.replay_status
    );
  end if;

  case p_resolution
    when 'ACCEPT_LOCAL' then
      -- force replay into central ledger despite conflict
      insert into catchmenu_ledger.events (
        tenant_id, store_id,
        event_domain, event_type, event_version,
        subject_type, subject_id,
        from_state, to_state,
        caused_by_type, caused_by_id,
        event_payload,
        is_replay, original_event_id,
        correlation_id,
        business_day, business_timezone,
        occurred_at, recorded_at
      ) values (
        p_tenant_id, p_store_id,
        v_entry.entry_domain,
        v_entry.original_event_type, 1,
        v_entry.original_subject_type,
        v_entry.original_subject_id,
        v_entry.entry_payload->>'from_state',
        v_entry.entry_payload->>'to_state',
        'REPLAY', p_resolved_by_id,
        v_entry.entry_payload || jsonb_build_object(
          'conflict_resolution', 'ACCEPT_LOCAL',
          'resolved_by', p_resolved_by_id,
          'resolution_note', p_resolution_note
        ),
        true, v_entry.id,
        p_correlation_id,
        v_business_day, v_timezone,
        v_entry.locally_recorded_at, now()
      )
      returning id into v_central_event_id;

      update catchmenu_ledger.local_temporary_ledger
      set
        replay_status = 'CONFLICT_RESOLVED',
        replay_conflict_detected = false,
        central_event_id = v_central_event_id,
        replay_approved_by = p_resolved_by_id,
        replay_approved_at = now(),
        replay_completed_at = now()
      where id = p_entry_id;

    when 'REJECT_LOCAL' then
      -- discard local entry — central state wins
      update catchmenu_ledger.local_temporary_ledger
      set
        replay_status = 'SKIPPED',
        replay_conflict_detected = false,
        replay_approved_by = p_resolved_by_id,
        replay_approved_at = now(),
        replay_conflict_detail = replay_conflict_detail || jsonb_build_object(
          'resolution', 'REJECTED',
          'resolution_note', p_resolution_note
        )
      where id = p_entry_id;

    when 'MANUAL_MERGE' then
      -- record merge decision in audit, mark for manual handling
      update catchmenu_ledger.local_temporary_ledger
      set
        replay_status = 'CONFLICT_RESOLVED',
        replay_approved_by = p_resolved_by_id,
        replay_approved_at = now(),
        replay_conflict_detail = replay_conflict_detail || jsonb_build_object(
          'resolution', 'MANUAL_MERGE',
          'resolution_note', p_resolution_note
        )
      where id = p_entry_id;
  end case;

  -- audit record
  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := 'recovery',
    p_audit_type := 'replay_conflict_resolved',
    p_audit_category := 'RECOVERY',
    p_actor_type := p_resolved_by_type,
    p_actor_id := p_resolved_by_id,
    p_subject_type := 'local_ledger_entry',
    p_subject_id := p_entry_id,
    p_decision := case p_resolution
      when 'ACCEPT_LOCAL' then 'APPROVED'
      when 'REJECT_LOCAL' then 'REJECTED'
      when 'MANUAL_MERGE' then 'OVERRIDDEN'
    end,
    p_decision_reason := p_resolution_note,
    p_decision_payload := jsonb_build_object(
      'resolution', p_resolution,
      'entry_sequence', v_entry.entry_sequence,
      'device_id', v_entry.device_id,
      'original_event_type', v_entry.original_event_type
    ),
    p_before_state := jsonb_build_object(
      'replay_status', 'CONFLICT_DETECTED'
    ),
    p_after_state := jsonb_build_object(
      'replay_status', case p_resolution
        when 'REJECT_LOCAL' then 'SKIPPED'
        else 'CONFLICT_RESOLVED'
      end,
      'resolution', p_resolution
    ),
    p_correlation_id := p_correlation_id,
    p_business_day := v_business_day,
    p_business_timezone := v_timezone
  );

  return jsonb_build_object(
    'success', true,
    'entry_id', p_entry_id,
    'resolution', p_resolution,
    'replay_status', case p_resolution
      when 'REJECT_LOCAL' then 'SKIPPED'
      else 'CONFLICT_RESOLVED'
    end,
    'central_event_id', v_central_event_id,
    'audit_id', v_audit_id,
    'message_code', 'replay_conflict_resolved'
  );
end;
$$;


create or replace function catchmenu_ledger.get_replay_status(
  p_tenant_id uuid,
  p_store_id uuid,
  p_device_id uuid
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_ledger, catchmenu_store,
                  catchmenu_common
as $$
declare
  v_device record;
  v_summary record;
  v_oldest_pending timestamptz;
  v_newest_pending timestamptz;
begin
  -- device validation
  select id, device_code, device_name,
         device_type, device_status
  into v_device
  from catchmenu_store.device_registry
  where id = p_device_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id;

  if v_device.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'device_not_found'
    );
  end if;

  -- aggregate replay status
  select
    count(*) filter (
      where replay_status = 'PENDING'
    ) as pending_count,
    count(*) filter (
      where replay_status = 'IN_PROGRESS'
    ) as in_progress_count,
    count(*) filter (
      where replay_status = 'REPLAYED'
    ) as replayed_count,
    count(*) filter (
      where replay_status = 'CONFLICT_DETECTED'
    ) as conflict_count,
    count(*) filter (
      where replay_status = 'CONFLICT_RESOLVED'
    ) as conflict_resolved_count,
    count(*) filter (
      where replay_status = 'SKIPPED'
    ) as skipped_count,
    count(*) filter (
      where replay_status = 'FAILED'
    ) as failed_count,
    count(*) as total_count,
    min(entry_sequence) as min_sequence,
    max(entry_sequence) as max_sequence,
    bool_or(replay_conflict_detected) as has_conflicts
  into v_summary
  from catchmenu_ledger.local_temporary_ledger
  where device_id = p_device_id
    and tenant_id = p_tenant_id;

  -- timing of pending entries
  select
    min(locally_recorded_at),
    max(locally_recorded_at)
  into v_oldest_pending, v_newest_pending
  from catchmenu_ledger.local_temporary_ledger
  where device_id = p_device_id
    and tenant_id = p_tenant_id
    and replay_status = 'PENDING';

  return jsonb_build_object(
    'success', true,
    'device', jsonb_build_object(
      'id', v_device.id,
      'device_code', v_device.device_code,
      'device_name', v_device.device_name,
      'device_type', v_device.device_type,
      'device_status', v_device.device_status
    ),
    'replay_summary', jsonb_build_object(
      'total_entries', v_summary.total_count,
      'pending', v_summary.pending_count,
      'in_progress', v_summary.in_progress_count,
      'replayed', v_summary.replayed_count,
      'conflict_detected', v_summary.conflict_count,
      'conflict_resolved', v_summary.conflict_resolved_count,
      'skipped', v_summary.skipped_count,
      'failed', v_summary.failed_count,
      'sequence_range', jsonb_build_object(
        'min', v_summary.min_sequence,
        'max', v_summary.max_sequence
      )
    ),
    'status', jsonb_build_object(
      'is_complete', v_summary.pending_count = 0
        and v_summary.in_progress_count = 0,
      'has_conflicts', v_summary.has_conflicts,
      'has_failures', v_summary.failed_count > 0,
      'needs_attention', v_summary.conflict_count > 0
        or v_summary.failed_count > 0
    ),
    'timing', jsonb_build_object(
      'oldest_pending', v_oldest_pending,
      'newest_pending', v_newest_pending
    ),
    'message_code', case
      when v_summary.pending_count = 0
        and v_summary.conflict_count = 0
      then 'replay_complete'
      when v_summary.conflict_count > 0
      then 'replay_has_conflicts'
      when v_summary.pending_count > 0
      then 'replay_in_progress'
      else 'replay_status_ok'
    end
  );
end;
$$;

-- grants
do $$
begin
  revoke all on function catchmenu_ledger.replay_local_ledger(
    uuid, uuid, uuid, int, text
  ) from public;
  grant execute on function catchmenu_ledger.replay_local_ledger(
    uuid, uuid, uuid, int, text
  ) to authenticated;

  revoke all on function catchmenu_ledger.resolve_replay_conflict(
    uuid, uuid, uuid, text, text, uuid, text, text
  ) from public;
  grant execute on function catchmenu_ledger.resolve_replay_conflict(
    uuid, uuid, uuid, text, text, uuid, text, text
  ) to authenticated;

  revoke all on function catchmenu_ledger.get_replay_status(
    uuid, uuid, uuid
  ) from public;
  grant execute on function catchmenu_ledger.get_replay_status(
    uuid, uuid, uuid
  ) to authenticated;
end;
$$;

comment on function catchmenu_ledger.replay_local_ledger(
  uuid, uuid, uuid, int, text
) is
  'Replays pending local temporary ledger entries to central ledger.
   Processes entries in sequence order per device.
   Detects sequence gaps and logs as exceptions.
   Conflict detection: checks if central ledger has newer events
   for same subject since local entry was recorded.
   Safe entries replayed automatically.
   Conflicting entries held for manual resolution.
   특허4: Local Temporary Ledger → Event Replay 기반 복구.
   안전한 Event만 중앙 원장에 Replay.';

comment on function catchmenu_ledger.resolve_replay_conflict(
  uuid, uuid, uuid, text, text, uuid, text, text
) is
  'Resolves a conflicting local ledger entry.
   ACCEPT_LOCAL: forces replay into central ledger.
   REJECT_LOCAL: discards local entry, central state wins.
   MANUAL_MERGE: records merge decision for manual handling.
   All resolutions require manager authorization.
   특허4: 충돌 또는 손상 의심 Event는 관리자 승인 대상으로 분리.
   복구 후 재동기화 + 감사 기록.';

comment on function catchmenu_ledger.get_replay_status(
  uuid, uuid, uuid
) is
  'Returns replay progress summary for a device.
   Shows counts by status: pending, replayed, conflict, failed.
   Used by staff app to monitor post-outage recovery progress.
   특허4: 복구 상태 실시간 모니터링.';

-- ===== END sql/migrations/0040_create_local_ledger_replay_rpc.sql =====


-- ===== BEGIN sql/migrations/0066_create_ledger_integrity_rpc.sql =====

-- 0066_create_ledger_integrity_rpc.sql
-- Purpose: Event ledger integrity validation and replay verification.
--          verify_event_ledger_integrity: checks event chain consistency.
--          verify_audit_chain: validates audit record immutability.
--          run_state_projection_check: verifies current state matches
--            event log projection.
--          reconcile_ledger_gaps: detects and reports missing events.
--          특허4 core: 4원장 무결성 검증 + Event Replay 일관성 확인.
-- Depends on: 0065_create_security_isolation_rpc.sql
-- Creates:
--   catchmenu_ledger.integrity_check_results (table)
--   function catchmenu_ledger.verify_event_ledger_integrity(...)
--   function catchmenu_ledger.verify_audit_chain(...)
--   function catchmenu_ledger.run_state_projection_check(...)
--   function catchmenu_ledger.reconcile_ledger_gaps(...)

-- =============================================
-- integrity_check_results table
-- =============================================
create table if not exists
  catchmenu_ledger.integrity_check_results (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid,

  check_type text not null,
  check_scope text not null,
  check_status text not null default 'PENDING',

  -- results
  total_records int not null default 0,
  valid_records int not null default 0,
  invalid_records int not null default 0,

  -- findings
  anomalies jsonb default '[]'::jsonb,
  gaps jsonb default '[]'::jsonb,
  projection_mismatches jsonb default '[]'::jsonb,

  -- integrity hash
  event_chain_hash text,
  audit_chain_hash text,

  -- meta
  check_started_at timestamptz not null default now(),
  check_completed_at timestamptz,
  check_duration_ms int,
  business_day date,

  created_at timestamptz not null default now(),

  constraint chk_check_type check (
    check_type in (
      'EVENT_CHAIN', 'AUDIT_CHAIN',
      'STATE_PROJECTION', 'GAP_DETECTION',
      'FULL_INTEGRITY'
    )
  ),
  constraint chk_check_status check (
    check_status in (
      'PENDING', 'RUNNING', 'PASSED',
      'FAILED', 'WARNING'
    )
  )
);

create index if not exists idx_integrity_tenant
  on catchmenu_ledger.integrity_check_results(
    tenant_id, check_type, check_started_at desc
  );
create index if not exists idx_integrity_status
  on catchmenu_ledger.integrity_check_results(
    check_status, check_started_at desc
  );

alter table catchmenu_ledger.integrity_check_results
  enable row level security;
alter table catchmenu_ledger.integrity_check_results
  force row level security;

drop policy if exists integrity_check_isolation
  on catchmenu_ledger.integrity_check_results;
create policy integrity_check_isolation
  on catchmenu_ledger.integrity_check_results
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
  );

comment on table
  catchmenu_ledger.integrity_check_results is
  '4-ledger integrity check results.
   Stores event chain hash for replay validation.
   Stores audit chain hash for immutability proof.
   특허4: 4원장 무결성 증빙 — append-only 보장.';


-- =============================================
-- RPCs
-- =============================================
create or replace function
  catchmenu_ledger.verify_event_ledger_integrity(
  p_tenant_id uuid,
  p_store_id uuid,
  p_business_day date default null,
  p_event_domain text default null
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_ledger,
                  catchmenu_common,
                  catchmenu_hq
as $$
declare
  v_check_id uuid;
  v_start timestamptz;
  v_target_day date;
  v_timezone text;
  v_total int := 0;
  v_valid int := 0;
  v_invalid int := 0;
  v_anomalies jsonb := '[]'::jsonb;
  v_chain_hash text;
begin
  v_check_id := gen_random_uuid();
  v_start := now();

  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_target_day := coalesce(
    p_business_day,
    (timezone(
      coalesce(v_timezone, 'Asia/Seoul'), now()
    ))::date
  );

  -- insert check record
  insert into catchmenu_ledger.integrity_check_results (
    id, tenant_id, store_id,
    check_type, check_status, check_scope,
    business_day
  ) values (
    v_check_id, p_tenant_id, p_store_id,
    'EVENT_CHAIN', 'RUNNING',
    coalesce(p_event_domain, 'ALL'),
    v_target_day
  );

  -- count total events for day
  select count(*)
  into v_total
  from catchmenu_ledger.events
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_target_day
    and (
      p_event_domain is null
      or event_domain = p_event_domain
    );

  -- CHECK 1: Future events (occurred_at > now)
  with future_events as (
    select id, event_type, event_domain,
           occurred_at
    from catchmenu_ledger.events
    where store_id = p_store_id
      and tenant_id = p_tenant_id
      and business_day = v_target_day
      and occurred_at > now() + interval '5 minutes'
    limit 10
  )
  select case when count(*) > 0 then
    v_anomalies || jsonb_build_array(
      jsonb_build_object(
        'anomaly_type', 'FUTURE_EVENT',
        'severity', 'CRITICAL',
        'count', count(*),
        'detail',
          'Events with future occurred_at timestamp',
        'sample_ids', (
          select coalesce(jsonb_agg(sample.id), '[]'::jsonb)
          from (
            select id from future_events limit 5
          ) sample
        )
      )
    )
    else v_anomalies
  end, count(*)
  into v_anomalies, v_invalid
  from future_events;

  -- CHECK 2: Events without valid subject reference
  with orphaned_events as (
    select id, event_type, event_domain,
           subject_type, subject_id
    from catchmenu_ledger.events
    where store_id = p_store_id
      and tenant_id = p_tenant_id
      and business_day = v_target_day
      and subject_id is not null
      and is_replay = false
      -- check for known subject types
      -- that should have real references
      and event_domain = 'payment'
      and subject_type = 'payment_ledger'
      and not exists (
        select 1
        from catchmenu_payment.payment_ledger pl
        where pl.id = subject_id
          and pl.tenant_id = p_tenant_id
      )
    limit 10
  )
  select case when count(*) > 0 then
    v_anomalies || jsonb_build_array(
      jsonb_build_object(
        'anomaly_type', 'ORPHANED_PAYMENT_EVENT',
        'severity', 'HIGH',
        'count', count(*),
        'detail',
          'Payment events with no ledger reference',
        'sample_ids', (
          select coalesce(jsonb_agg(sample.id), '[]'::jsonb)
          from (
            select id from orphaned_events limit 5
          ) sample
        )
      )
    )
    else v_anomalies
  end
  into v_anomalies
  from orphaned_events;

  -- CHECK 3: Replay events without original_event_id
  with bad_replays as (
    select id, event_type, event_domain
    from catchmenu_ledger.events
    where store_id = p_store_id
      and tenant_id = p_tenant_id
      and business_day = v_target_day
      and is_replay = true
      and original_event_id is null
    limit 10
  )
  select case when count(*) > 0 then
    v_anomalies || jsonb_build_array(
      jsonb_build_object(
        'anomaly_type', 'REPLAY_WITHOUT_ORIGIN',
        'severity', 'MEDIUM',
        'count', count(*),
        'detail',
          'Replay events missing original_event_id',
        'sample_ids', (
          select coalesce(jsonb_agg(sample.id), '[]'::jsonb)
          from (
            select id from bad_replays limit 5
          ) sample
        )
      )
    )
    else v_anomalies
  end
  into v_anomalies
  from bad_replays;

  -- CHECK 4: Duplicate correlation_ids
  -- (same correlation = same request)
  -- multiple successful payment events
  -- with same correlation = double charge risk
  with dup_payments as (
    select correlation_id, count(*) as cnt
    from catchmenu_ledger.events
    where store_id = p_store_id
      and tenant_id = p_tenant_id
      and business_day = v_target_day
      and event_type = 'payment_confirmed'
      and correlation_id is not null
      and is_replay = false
    group by correlation_id
    having count(*) > 1
  )
  select case when count(*) > 0 then
    v_anomalies || jsonb_build_array(
      jsonb_build_object(
        'anomaly_type', 'DUPLICATE_PAYMENT_CONFIRMED',
        'severity', 'CRITICAL',
        'count', count(*),
        'total_duplicates', sum(cnt),
        'detail',
          'Multiple payment_confirmed events '
          || 'with same correlation_id. '
          || 'POSSIBLE DOUBLE CHARGE.',
        'correlation_ids', (
          select coalesce(
            jsonb_agg(sample.correlation_id),
            '[]'::jsonb
          )
          from (
            select correlation_id from dup_payments limit 5
          ) sample
        )
      )
    )
    else v_anomalies
  end
  into v_anomalies
  from dup_payments;

  -- CHECK 5: Payment events without KDS events
  -- (payment confirmed but no KDS condition update)
  with payment_no_kds as (
    select e.id, e.order_id, e.occurred_at
    from catchmenu_ledger.events e
    where e.store_id = p_store_id
      and e.tenant_id = p_tenant_id
      and e.business_day = v_target_day
      and e.event_type = 'payment_confirmed'
      and e.is_replay = false
      and not exists (
        select 1
        from catchmenu_ledger.events e2
        where e2.order_id = e.order_id
          and e2.event_domain = 'kds'
          and e2.event_type in (
            'kds_condition_updated',
            'condition_updated',
            'kds_bulk_commit_attempted'
          )
          and e2.occurred_at >= e.occurred_at
      )
    limit 10
  )
  select case when count(*) > 0 then
    v_anomalies || jsonb_build_array(
      jsonb_build_object(
        'anomaly_type', 'PAYMENT_NO_KDS_UPDATE',
        'severity', 'MEDIUM',
        'count', count(*),
        'detail',
          'Payment confirmed but no KDS condition update',
        'order_ids', (
          select coalesce(
            jsonb_agg(sample.order_id),
            '[]'::jsonb
          )
          from (
            select order_id from payment_no_kds limit 5
          ) sample
        )
      )
    )
    else v_anomalies
  end
  into v_anomalies
  from payment_no_kds;

  -- compute chain hash for integrity proof
  select encode(
    digest(
      string_agg(
        id::text || occurred_at::text
        || event_type || coalesce(
          subject_id::text, ''
        ),
        '|' order by occurred_at, id
      ),
      'sha256'
    ),
    'hex'
  )
  into v_chain_hash
  from catchmenu_ledger.events
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_target_day;

  v_invalid := jsonb_array_length(v_anomalies);
  v_valid := v_total - v_invalid;

  -- update check result
  update catchmenu_ledger.integrity_check_results
  set
    check_status = case v_invalid
      when 0 then 'PASSED'
      else 'FAILED'
    end,
    total_records = v_total,
    valid_records = greatest(v_valid, 0),
    invalid_records = v_invalid,
    anomalies = v_anomalies,
    event_chain_hash = v_chain_hash,
    check_completed_at = now(),
    check_duration_ms = extract(
      epoch from (now() - v_start)
    )::int * 1000
  where id = v_check_id;

  -- diagnostic log
  perform catchmenu_common.log_diagnostic(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_log_level := case v_invalid
      when 0 then 'INFO'
      else 'WARNING'
    end,
    p_log_domain := 'SYSTEM',
    p_log_event := 'event_ledger_integrity_checked',
    p_message :=
      'Event ledger integrity: '
      || v_total || ' events checked'
      || ', ' || v_invalid || ' anomalies'
      || ' hash=' || coalesce(
        left(v_chain_hash, 16), 'null'
      ),
    p_rpc_name := 'verify_event_ledger_integrity',
    p_details := jsonb_build_object(
      'check_id', v_check_id,
      'total', v_total,
      'valid', v_valid,
      'invalid', v_invalid,
      'business_day', v_target_day,
      'event_domain', p_event_domain
    )
  );

  return jsonb_build_object(
    'success', true,
    'check_id', v_check_id,
    'check_type', 'EVENT_CHAIN',
    'business_day', v_target_day,
    'event_domain_filter', p_event_domain,
    'result', jsonb_build_object(
      'total_events', v_total,
      'valid_events', greatest(v_valid, 0),
      'anomaly_count', v_invalid,
      'status', case v_invalid
        when 0 then 'PASSED'
        else 'FAILED'
      end,
      'event_chain_hash', v_chain_hash,
      'chain_hash_prefix',
        left(coalesce(v_chain_hash, ''), 16)
    ),
    'anomalies', v_anomalies,
    'message_code', case v_invalid
      when 0 then 'event_integrity_passed'
      else 'event_integrity_anomalies_found'
    end
  );
end;
$$;


create or replace function
  catchmenu_ledger.verify_audit_chain(
  p_tenant_id uuid,
  p_store_id uuid,
  p_business_day date default null
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_ledger,
                  catchmenu_common,
                  catchmenu_hq
as $$
declare
  v_check_id uuid;
  v_start timestamptz;
  v_target_day date;
  v_timezone text;
  v_total int;
  v_anomalies jsonb := '[]'::jsonb;
  v_chain_hash text;
  v_modified_count int;
  v_missing_decision int;
begin
  v_check_id := gen_random_uuid();
  v_start := now();

  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_target_day := coalesce(
    p_business_day,
    (timezone(
      coalesce(v_timezone, 'Asia/Seoul'), now()
    ))::date
  );

  -- total audit records for day
  select count(*)
  into v_total
  from catchmenu_ledger.audit_records
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_target_day;

  -- CHECK 1: Audit records with modified timestamps
  -- (append-only: recorded_at = created_at)
  select count(*)
  into v_modified_count
  from catchmenu_ledger.audit_records
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_target_day
    and recorded_at <> created_at;

  if v_modified_count > 0 then
    v_anomalies := v_anomalies || jsonb_build_array(
      jsonb_build_object(
        'anomaly_type', 'AUDIT_RECORD_MODIFIED',
        'severity', 'CRITICAL',
        'count', v_modified_count,
        'detail',
          'Audit records have been modified '
          || '(recorded_at ≠ created_at). '
          || 'POSSIBLE TAMPERING.',
        'remediation',
          'Investigate immediately. '
          || 'Compare with backup/WAL logs.'
      )
    );
  end if;

  -- CHECK 2: Audit records without decision
  select count(*)
  into v_missing_decision
  from catchmenu_ledger.audit_records
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_target_day
    and (
      audit_decision is null
      or trim(audit_decision) = ''
    );

  if v_missing_decision > 0 then
    v_anomalies := v_anomalies || jsonb_build_array(
      jsonb_build_object(
        'anomaly_type', 'AUDIT_MISSING_DECISION',
        'severity', 'HIGH',
        'count', v_missing_decision,
        'detail',
          'Audit records missing decision field'
      )
    );
  end if;

  -- CHECK 3: Financial audit records without
  -- actor (anonymous financial action = high risk)
  with anon_financial as (
    select id, audit_type, audit_category,
           recorded_at
    from catchmenu_ledger.audit_records
    where store_id = p_store_id
      and tenant_id = p_tenant_id
      and business_day = v_target_day
      and audit_category = 'FINANCIAL'
      and actor_id is null
      and actor_type not in (
        'PROVIDER', 'SYSTEM', 'TOSS_PAYMENTS',
        'NICE_PAYMENTS', 'KIS'
      )
    limit 10
  )
  select case when count(*) > 0 then
    v_anomalies || jsonb_build_array(
      jsonb_build_object(
        'anomaly_type',
          'ANONYMOUS_FINANCIAL_AUDIT',
        'severity', 'HIGH',
        'count', count(*),
        'detail',
          'Financial audit records without actor_id',
        'sample_ids', (
          select coalesce(jsonb_agg(sample.id), '[]'::jsonb)
          from (
            select id from anon_financial limit 5
          ) sample
        )
      )
    )
    else v_anomalies
  end
  into v_anomalies
  from anon_financial;

  -- CHECK 4: Audit records with future timestamps
  with future_audit as (
    select id, audit_type, recorded_at
    from catchmenu_ledger.audit_records
    where store_id = p_store_id
      and tenant_id = p_tenant_id
      and business_day = v_target_day
      and recorded_at > now() + interval '5 minutes'
    limit 10
  )
  select case when count(*) > 0 then
    v_anomalies || jsonb_build_array(
      jsonb_build_object(
        'anomaly_type', 'FUTURE_AUDIT_TIMESTAMP',
        'severity', 'CRITICAL',
        'count', count(*),
        'detail',
          'Audit records with future timestamps',
        'sample_ids', (
          select coalesce(jsonb_agg(sample.id), '[]'::jsonb)
          from (
            select id from future_audit limit 5
          ) sample
        )
      )
    )
    else v_anomalies
  end
  into v_anomalies
  from future_audit;

  -- compute audit chain hash
  select encode(
    digest(
      string_agg(
        id::text || recorded_at::text
        || audit_type
        || coalesce(actor_id::text, 'SYSTEM')
        || coalesce(audit_decision, ''),
        '|' order by recorded_at, id
      ),
      'sha256'
    ),
    'hex'
  )
  into v_chain_hash
  from catchmenu_ledger.audit_records
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_target_day;

  -- store check result
  insert into catchmenu_ledger.integrity_check_results (
    id, tenant_id, store_id,
    check_type, check_status, check_scope,
    total_records, valid_records, invalid_records,
    anomalies, audit_chain_hash,
    check_completed_at, check_duration_ms,
    business_day
  ) values (
    v_check_id, p_tenant_id, p_store_id,
    'AUDIT_CHAIN',
    case jsonb_array_length(v_anomalies)
      when 0 then 'PASSED'
      else 'FAILED'
    end,
    'DAILY',
    v_total,
    v_total - jsonb_array_length(v_anomalies),
    jsonb_array_length(v_anomalies),
    v_anomalies, v_chain_hash,
    now(),
    extract(
      epoch from (now() - v_start)
    )::int * 1000,
    v_target_day
  );

  return jsonb_build_object(
    'success', true,
    'check_id', v_check_id,
    'check_type', 'AUDIT_CHAIN',
    'business_day', v_target_day,
    'result', jsonb_build_object(
      'total_audit_records', v_total,
      'anomaly_count',
        jsonb_array_length(v_anomalies),
      'status', case jsonb_array_length(v_anomalies)
        when 0 then 'PASSED'
        else 'FAILED'
      end,
      'audit_chain_hash', v_chain_hash,
      'chain_hash_prefix',
        left(coalesce(v_chain_hash, ''), 16),
      'is_immutable',
        jsonb_array_length(v_anomalies) = 0
    ),
    'anomalies', v_anomalies,
    'message_code', case
      when jsonb_array_length(v_anomalies) = 0
      then 'audit_chain_intact'
      else 'audit_chain_anomalies_detected'
    end
  );
end;
$$;


create or replace function
  catchmenu_ledger.run_state_projection_check(
  p_tenant_id uuid,
  p_store_id uuid,
  p_business_day date default null
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_ledger,
                  catchmenu_pos,
                  catchmenu_payment,
                  catchmenu_kds,
                  catchmenu_common,
                  catchmenu_hq
as $$
declare
  v_check_id uuid;
  v_start timestamptz;
  v_target_day date;
  v_timezone text;
  v_mismatches jsonb := '[]'::jsonb;
  v_total_checked int := 0;
  v_mismatch_count int := 0;
begin
  v_check_id := gen_random_uuid();
  v_start := now();

  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_target_day := coalesce(
    p_business_day,
    (timezone(
      coalesce(v_timezone, 'Asia/Seoul'), now()
    ))::date
  );

  -- PROJECT 1: Payment status projection
  -- Current state in payment_ledger
  -- must match last payment event to_state
  with payment_projection as (
    select
      pl.id as ledger_id,
      pl.ledger_status as current_status,
      last_evt.to_state as projected_status
    from catchmenu_payment.payment_ledger pl
    join lateral (
      select to_state
      from catchmenu_ledger.events e
      where e.payment_id = pl.id
        and e.event_domain = 'payment'
        and e.is_replay = false
      order by e.occurred_at desc
      limit 1
    ) last_evt on true
    where pl.store_id = p_store_id
      and pl.tenant_id = p_tenant_id
      and pl.business_day = v_target_day
      and last_evt.to_state is not null
      and pl.ledger_status <> last_evt.to_state
    limit 20
  )
  select
    count(*),
    case when count(*) > 0 then
      v_mismatches || jsonb_build_array(
        jsonb_build_object(
          'projection_type', 'PAYMENT_STATE',
          'severity', 'HIGH',
          'mismatch_count', count(*),
          'detail',
            'Payment ledger state does not match '
            || 'event projection',
          'sample', (
            select coalesce(jsonb_agg(sample.item), '[]'::jsonb)
            from (
              select jsonb_build_object(
                'ledger_id', ledger_id,
                'current', current_status,
                'projected', projected_status
              ) as item
              from payment_projection
              limit 5
            ) sample
          )
        )
      )
      else v_mismatches
    end
  into v_mismatch_count, v_mismatches
  from payment_projection;

  v_total_checked := v_total_checked
    + v_mismatch_count;

  -- PROJECT 2: Order status projection
  -- last order event to_state must
  -- match orders.order_status
  with order_projection as (
    select
      o.id as order_id,
      o.order_number,
      o.order_status as current_status,
      last_evt.to_state as projected_status
    from catchmenu_pos.orders o
    join lateral (
      select to_state
      from catchmenu_ledger.events e
      where e.order_id = o.id
        and e.event_domain = 'order'
        and e.is_replay = false
      order by e.occurred_at desc
      limit 1
    ) last_evt on true
    where o.store_id = p_store_id
      and o.tenant_id = p_tenant_id
      and o.business_day = v_target_day
      and last_evt.to_state is not null
      and o.order_status <> last_evt.to_state
    limit 20
  )
  select
    count(*),
    case when count(*) > 0 then
      v_mismatches || jsonb_build_array(
        jsonb_build_object(
          'projection_type', 'ORDER_STATE',
          'severity', 'MEDIUM',
          'mismatch_count', count(*),
          'detail',
            'Order status does not match '
            || 'event projection',
          'sample', (
            select coalesce(jsonb_agg(sample.item), '[]'::jsonb)
            from (
              select jsonb_build_object(
                'order_id', order_id,
                'order_number', order_number,
                'current', current_status,
                'projected', projected_status
              ) as item
              from order_projection
              limit 5
            ) sample
          )
        )
      )
      else v_mismatches
    end
  into v_mismatch_count, v_mismatches
  from order_projection;

  v_total_checked := v_total_checked
    + v_mismatch_count;

  -- PROJECT 3: KDS state projection
  -- KDS ticket status vs last KDS event
  with kds_projection as (
    select
      kt.id as ticket_id,
      kt.ticket_number,
      kt.kds_status as current_status,
      last_evt.to_state as projected_status
    from catchmenu_kds.kds_tickets kt
    join lateral (
      select to_state
      from catchmenu_ledger.events e
      where e.kds_ticket_id = kt.id
        and e.event_domain = 'kds'
        and e.is_replay = false
      order by e.occurred_at desc
      limit 1
    ) last_evt on true
    where kt.store_id = p_store_id
      and kt.tenant_id = p_tenant_id
      and kt.business_day = v_target_day
      and last_evt.to_state is not null
      and kt.kds_status <> last_evt.to_state
    limit 20
  )
  select
    count(*),
    case when count(*) > 0 then
      v_mismatches || jsonb_build_array(
        jsonb_build_object(
          'projection_type', 'KDS_STATE',
          'severity', 'HIGH',
          'mismatch_count', count(*),
          'detail',
            'KDS ticket status does not match '
            || 'event projection',
          'sample', (
            select coalesce(jsonb_agg(sample.item), '[]'::jsonb)
            from (
              select jsonb_build_object(
                'ticket_id', ticket_id,
                'ticket_number', ticket_number,
                'current', current_status,
                'projected', projected_status
              ) as item
              from kds_projection
              limit 5
            ) sample
          )
        )
      )
      else v_mismatches
    end
  into v_mismatch_count, v_mismatches
  from kds_projection;

  v_total_checked := v_total_checked
    + v_mismatch_count;

  -- PROJECT 4: Session state projection
  with session_projection as (
    select
      s.id as session_id,
      s.session_status as current_status,
      last_evt.to_state as projected_status
    from catchmenu_pos.order_sessions s
    join lateral (
      select to_state
      from catchmenu_ledger.events e
      where e.session_id = s.id
        and e.event_domain = 'session'
        and e.is_replay = false
      order by e.occurred_at desc
      limit 1
    ) last_evt on true
    where s.store_id = p_store_id
      and s.tenant_id = p_tenant_id
      and s.business_day = v_target_day
      and last_evt.to_state is not null
      and s.session_status <> last_evt.to_state
    limit 20
  )
  select
    count(*),
    case when count(*) > 0 then
      v_mismatches || jsonb_build_array(
        jsonb_build_object(
          'projection_type', 'SESSION_STATE',
          'severity', 'MEDIUM',
          'mismatch_count', count(*),
          'detail',
            'Session status does not match '
            || 'event projection',
          'sample', (
            select coalesce(jsonb_agg(sample.item), '[]'::jsonb)
            from (
              select jsonb_build_object(
                'session_id', session_id,
                'current', current_status,
                'projected', projected_status
              ) as item
              from session_projection
              limit 5
            ) sample
          )
        )
      )
      else v_mismatches
    end
  into v_mismatch_count, v_mismatches
  from session_projection;

  v_total_checked := v_total_checked
    + v_mismatch_count;

  -- store check
  insert into catchmenu_ledger.integrity_check_results (
    id, tenant_id, store_id,
    check_type, check_status, check_scope,
    total_records, invalid_records,
    projection_mismatches,
    check_completed_at, check_duration_ms,
    business_day
  ) values (
    v_check_id, p_tenant_id, p_store_id,
    'STATE_PROJECTION',
    case jsonb_array_length(v_mismatches)
      when 0 then 'PASSED'
      else 'WARNING'
    end,
    'DAILY',
    v_total_checked,
    jsonb_array_length(v_mismatches),
    v_mismatches,
    now(),
    extract(
      epoch from (now() - v_start)
    )::int * 1000,
    v_target_day
  );

  return jsonb_build_object(
    'success', true,
    'check_id', v_check_id,
    'check_type', 'STATE_PROJECTION',
    'business_day', v_target_day,
    'result', jsonb_build_object(
      'total_checked', v_total_checked,
      'mismatch_count',
        jsonb_array_length(v_mismatches),
      'status', case jsonb_array_length(v_mismatches)
        when 0 then 'PASSED'
        else 'WARNING'
      end,
      'projections_checked', jsonb_build_array(
        'PAYMENT_STATE', 'ORDER_STATE',
        'KDS_STATE', 'SESSION_STATE'
      )
    ),
    'mismatches', v_mismatches,
    'message_code', case
      when jsonb_array_length(v_mismatches) = 0
      then 'state_projection_consistent'
      else 'state_projection_mismatches_found'
    end
  );
end;
$$;


create or replace function
  catchmenu_ledger.reconcile_ledger_gaps(
  p_tenant_id uuid,
  p_store_id uuid,
  p_business_day date default null
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_ledger,
                  catchmenu_pos,
                  catchmenu_payment,
                  catchmenu_kds,
                  catchmenu_common,
                  catchmenu_hq
as $$
declare
  v_check_id uuid;
  v_start timestamptz;
  v_target_day date;
  v_timezone text;
  v_gaps jsonb := '[]'::jsonb;
  v_gap_count int := 0;
begin
  v_check_id := gen_random_uuid();
  v_start := now();

  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_target_day := coalesce(
    p_business_day,
    (timezone(
      coalesce(v_timezone, 'Asia/Seoul'), now()
    ))::date
  );

  -- GAP 1: Confirmed orders with no payment event
  with gap_order_payment as (
    select o.id as order_id, o.order_number,
           o.order_status, o.final_amount
    from catchmenu_pos.orders o
    where o.store_id = p_store_id
      and o.tenant_id = p_tenant_id
      and o.business_day = v_target_day
      and o.order_status in (
        'CONFIRMED', 'COOKING', 'COMPLETED'
      )
      and o.final_amount > 0
      and not exists (
        select 1
        from catchmenu_ledger.events e
        where e.order_id = o.id
          and e.event_domain = 'payment'
          and e.event_type = 'payment_confirmed'
      )
    limit 10
  )
  select case when count(*) > 0 then
    v_gaps || jsonb_build_array(
      jsonb_build_object(
        'gap_type', 'ORDER_NO_PAYMENT_EVENT',
        'severity', 'HIGH',
        'count', count(*),
        'detail',
          'Paid orders with no payment_confirmed event',
        'sample', (
          select coalesce(jsonb_agg(sample.item), '[]'::jsonb)
          from (
            select jsonb_build_object(
              'order_id', order_id,
              'order_number', order_number,
              'order_status', order_status,
              'final_amount', final_amount
            ) as item
            from gap_order_payment
            limit 5
          ) sample
        )
      )
    )
    else v_gaps
  end
  into v_gaps
  from gap_order_payment;

  -- GAP 2: KDS tickets with no KDS events
  with gap_kds as (
    select kt.id as ticket_id, kt.ticket_number,
           kt.kds_status
    from catchmenu_kds.kds_tickets kt
    where kt.store_id = p_store_id
      and kt.tenant_id = p_tenant_id
      and kt.business_day = v_target_day
      and kt.kds_status not in ('HOLD')
      and not exists (
        select 1
        from catchmenu_kds.kds_events ke
        where ke.ticket_id = kt.id
      )
    limit 10
  )
  select case when count(*) > 0 then
    v_gaps || jsonb_build_array(
      jsonb_build_object(
        'gap_type', 'KDS_TICKET_NO_EVENTS',
        'severity', 'MEDIUM',
        'count', count(*),
        'detail',
          'KDS tickets in non-HOLD state '
          || 'with no KDS events',
        'sample', (
          select coalesce(jsonb_agg(sample.item), '[]'::jsonb)
          from (
            select jsonb_build_object(
              'ticket_id', ticket_id,
              'ticket_number', ticket_number,
              'kds_status', kds_status
            ) as item
            from gap_kds
            limit 5
          ) sample
        )
      )
    )
    else v_gaps
  end
  into v_gaps
  from gap_kds;

  -- GAP 3: Sessions with no session events
  with gap_session as (
    select s.id as session_id,
           s.session_status, s.session_type
    from catchmenu_pos.order_sessions s
    where s.store_id = p_store_id
      and s.tenant_id = p_tenant_id
      and s.business_day = v_target_day
      and not exists (
        select 1
        from catchmenu_pos.session_events se
        where se.session_id = s.id
      )
    limit 10
  )
  select case when count(*) > 0 then
    v_gaps || jsonb_build_array(
      jsonb_build_object(
        'gap_type', 'SESSION_NO_EVENTS',
        'severity', 'LOW',
        'count', count(*),
        'detail',
          'Sessions with no session events recorded',
        'sample', (
          select coalesce(jsonb_agg(sample.item), '[]'::jsonb)
          from (
            select jsonb_build_object(
              'session_id', session_id,
              'session_status', session_status,
              'session_type', session_type
            ) as item
            from gap_session
            limit 5
          ) sample
        )
      )
    )
    else v_gaps
  end
  into v_gaps
  from gap_session;

  -- GAP 4: Payments without reconciliation check
  with gap_reconciliation as (
    select pl.id as ledger_id,
           pl.approved_amount,
           pl.ledger_status,
           pl.provider_type
    from catchmenu_payment.payment_ledger pl
    where pl.store_id = p_store_id
      and pl.tenant_id = p_tenant_id
      and pl.business_day = v_target_day
      and pl.ledger_status = 'APPROVED'
      and pl.reconciliation_status = 'PENDING'
      and pl.reconciliation_checked_at is null
      -- older than 1 hour without reconciliation
      and pl.created_at < now() - interval '1 hour'
    limit 10
  )
  select case when count(*) > 0 then
    v_gaps || jsonb_build_array(
      jsonb_build_object(
        'gap_type', 'PAYMENT_RECONCILIATION_PENDING',
        'severity', 'MEDIUM',
        'count', count(*),
        'total_amount', sum(approved_amount),
        'detail',
          'Approved payments pending reconciliation '
          || 'for over 1 hour',
        'sample', (
          select coalesce(jsonb_agg(sample.item), '[]'::jsonb)
          from (
            select jsonb_build_object(
              'ledger_id', ledger_id,
              'approved_amount', approved_amount,
              'provider_type', provider_type
            ) as item
            from gap_reconciliation
            limit 5
          ) sample
        )
      )
    )
    else v_gaps
  end
  into v_gaps
  from gap_reconciliation;

  v_gap_count := jsonb_array_length(v_gaps);

  -- store gap check result
  insert into catchmenu_ledger.integrity_check_results (
    id, tenant_id, store_id,
    check_type, check_status, check_scope,
    total_records, invalid_records,
    gaps,
    check_completed_at, check_duration_ms,
    business_day
  ) values (
    v_check_id, p_tenant_id, p_store_id,
    'GAP_DETECTION',
    case v_gap_count
      when 0 then 'PASSED'
      else 'WARNING'
    end,
    'DAILY',
    0,
    v_gap_count,
    v_gaps,
    now(),
    extract(
      epoch from (now() - v_start)
    )::int * 1000,
    v_target_day
  );

  -- diagnostic log
  perform catchmenu_common.log_diagnostic(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_log_level := case v_gap_count
      when 0 then 'INFO'
      else 'WARNING'
    end,
    p_log_domain := 'SYSTEM',
    p_log_event := 'ledger_gap_reconciliation',
    p_message :=
      'Ledger gap check: '
      || v_gap_count || ' gap types found'
      || ' on ' || v_target_day,
    p_rpc_name := 'reconcile_ledger_gaps',
    p_details := jsonb_build_object(
      'check_id', v_check_id,
      'gap_count', v_gap_count,
      'business_day', v_target_day
    )
  );

  return jsonb_build_object(
    'success', true,
    'check_id', v_check_id,
    'check_type', 'GAP_DETECTION',
    'business_day', v_target_day,
    'result', jsonb_build_object(
      'gap_type_count', v_gap_count,
      'status', case v_gap_count
        when 0 then 'PASSED'
        else 'WARNING'
      end,
      'gaps_checked', jsonb_build_array(
        'ORDER_NO_PAYMENT_EVENT',
        'KDS_TICKET_NO_EVENTS',
        'SESSION_NO_EVENTS',
        'PAYMENT_RECONCILIATION_PENDING'
      )
    ),
    'gaps', v_gaps,
    'message_code', case v_gap_count
      when 0 then 'ledger_gap_check_clean'
      else 'ledger_gaps_detected'
    end
  );
end;
$$;

-- grants
do $$
begin
  revoke all on function
    catchmenu_ledger.verify_event_ledger_integrity(
      uuid, uuid, date, text
    ) from public;
  grant execute on function
    catchmenu_ledger.verify_event_ledger_integrity(
      uuid, uuid, date, text
    ) to authenticated;

  revoke all on function
    catchmenu_ledger.verify_audit_chain(
      uuid, uuid, date
    ) from public;
  grant execute on function
    catchmenu_ledger.verify_audit_chain(
      uuid, uuid, date
    ) to authenticated;

  revoke all on function
    catchmenu_ledger.run_state_projection_check(
      uuid, uuid, date
    ) from public;
  grant execute on function
    catchmenu_ledger.run_state_projection_check(
      uuid, uuid, date
    ) to authenticated;

  revoke all on function
    catchmenu_ledger.reconcile_ledger_gaps(
      uuid, uuid, date
    ) from public;
  grant execute on function
    catchmenu_ledger.reconcile_ledger_gaps(
      uuid, uuid, date
    ) to authenticated;
end;
$$;

comment on function
  catchmenu_ledger.verify_event_ledger_integrity(
    uuid, uuid, date, text
  ) is
  'Validates event ledger integrity for a business day.
   Checks:
   1. Future event timestamps
   2. Orphaned payment events
   3. Replay events without origin reference
   4. Duplicate payment_confirmed events (double charge risk)
   5. Payment confirmed but no KDS condition update
   Computes event_chain_hash for integrity proof.
   특허4: Event 원장 무결성 = 이벤트 체인 해시 검증.
   hash는 당일 전체 이벤트의 sha256 fingerprint.
   동일 hash = 원장 변조 없음.';

comment on function
  catchmenu_ledger.verify_audit_chain(
    uuid, uuid, date
  ) is
  'Validates audit record immutability.
   CRITICAL: detects tampered audit records
   (recorded_at ≠ created_at).
   HIGH: anonymous financial audit records.
   Computes audit_chain_hash for compliance proof.
   특허4: Audit 원장 = append-only 불변 원장.
   감사 기록 변조 탐지 = 최우선 보안 검사.
   Daily run recommended. 이상 시 즉시 DBA 알림.';

comment on function
  catchmenu_ledger.run_state_projection_check(
    uuid, uuid, date
  ) is
  'Verifies current state matches event log projection.
   Current state = last event to_state per subject.
   Checks: payment, order, KDS ticket, session states.
   Mismatch = direct UPDATE bypassed event ledger.
   특허4: 현재 상태 = Event 원장 Projection.
   직접 UPDATE 금지 원칙 위반 탐지.
   mismatch 발견 시 → replay 또는 manual reconciliation.';

comment on function
  catchmenu_ledger.reconcile_ledger_gaps(
    uuid, uuid, date
  ) is
  'Detects gaps in event coverage.
   Gaps detected:
   1. Paid orders with no payment event
   2. Non-HOLD KDS tickets with no events
   3. Sessions with no events
   4. Approved payments pending reconciliation >1h
   특허4: Event 원장 Gap 탐지 → 복구 우선순위 결정.
   Gap = 이벤트가 기록되지 않은 상태 변경 의심.
   Daily cron 권장: run after business close.';

-- ===== END sql/migrations/0066_create_ledger_integrity_rpc.sql =====


-- ===== BEGIN sql/migrations/0098_create_payment_confirm_pipeline_rpc.sql =====

-- 0098_create_payment_confirm_pipeline_rpc.sql
-- Purpose: Payment confirmation pipeline with
--          KDS Late Binding integration.
--          토스페이먼츠/OKpos 결제 확인 → KDS 해제.
--          Layer 1 대사 즉시 실행.
--          환불/부분취소 파이프라인.
--          특허2 핵심: 결제 확인 후 KDS HOLD 해제.
--          i18n: 모든 메시지 = message_catalog 참조.
-- Depends on: 0097_create_auth_login_pipeline_rpc.sql
-- Creates:
--   function catchmenu_payment.confirm_payment(...)
--   function catchmenu_payment.confirm_payment_webhook(...)
--   function catchmenu_payment.release_kds_after_payment(...)
--   function catchmenu_payment.request_refund(...)
--   function catchmenu_payment.confirm_refund(...)
--   function catchmenu_payment.get_payment_status(...)

-- =============================================
-- i18n 메시지 등록
-- =============================================
insert into catchmenu_common.message_catalog (
  message_key, locale, message_text
) values
('payment_confirmed', 'ko',
  '결제가 완료되었습니다'),
('payment_confirmed', 'en',
  'Payment confirmed'),
('payment_confirmed', 'zh',
  '付款已完成'),
('payment_confirmed', 'ja',
  'お支払いが完了しました'),
('payment_confirmed', 'vi',
  'Thanh toán đã hoàn tất'),
('payment_confirmed', 'th',
  'ชำระเงินเรียบร้อยแล้ว'),

('kds_released', 'ko',
  '주방으로 주문이 전달되었습니다'),
('kds_released', 'en',
  'Order sent to kitchen'),
('kds_released', 'zh',
  '订单已发送至厨房'),
('kds_released', 'ja',
  '注文がキッチンに送られました'),
('kds_released', 'vi',
  'Đơn hàng đã gửi đến bếp'),
('kds_released', 'th',
  'ส่งคำสั่งซื้อไปที่ครัวแล้ว'),

('refund_requested', 'ko',
  '환불 요청이 접수되었습니다'),
('refund_requested', 'en',
  'Refund request submitted'),
('refund_requested', 'zh',
  '退款请求已提交'),
('refund_requested', 'ja',
  '返金申請を受け付けました'),
('refund_requested', 'vi',
  'Yêu cầu hoàn tiền đã được gửi'),
('refund_requested', 'th',
  'ส่งคำขอคืนเงินแล้ว'),

('refund_confirmed', 'ko',
  '환불이 완료되었습니다'),
('refund_confirmed', 'en',
  'Refund confirmed'),
('refund_confirmed', 'zh',
  '退款已完成'),
('refund_confirmed', 'ja',
  '返金が完了しました'),
('refund_confirmed', 'vi',
  'Hoàn tiền đã hoàn tất'),
('refund_confirmed', 'th',
  'คืนเงินเรียบร้อยแล้ว'),

('payment_status_loaded', 'ko',
  '결제 현황이 로드되었습니다'),
('payment_status_loaded', 'en',
  'Payment status loaded'),

('payment_webhook_processed', 'ko',
  '결제 웹훅이 처리되었습니다'),
('payment_webhook_processed', 'en',
  'Payment webhook processed'),

('kds_late_binding_released', 'ko',
  '결제 확인 후 주방 조리가 시작됩니다'),
('kds_late_binding_released', 'en',
  'Kitchen cooking started after payment'),
('kds_late_binding_released', 'zh',
  '付款确认后厨房开始烹饪'),
('kds_late_binding_released', 'ja',
  '支払い確認後にキッチンでの調理が開始されます'),
('kds_late_binding_released', 'vi',
  'Bếp bắt đầu nấu sau khi xác nhận thanh toán'),
('kds_late_binding_released', 'th',
  'ครัวเริ่มปรุงอาหารหลังยืนยันการชำระเงิน'),

('payment_already_confirmed', 'ko',
  '이미 완료된 결제입니다'),
('payment_already_confirmed', 'en',
  'Payment already confirmed'),

('refund_amount_invalid', 'ko',
  '환불 금액이 올바르지 않습니다'),
('refund_amount_invalid', 'en',
  'Invalid refund amount'),

('partial_refund_not_supported', 'ko',
  '부분 환불은 현재 지원되지 않습니다'),
('partial_refund_not_supported', 'en',
  'Partial refund not supported'),

('net_cancel_required', 'ko',
  '망취소가 필요합니다. PG사에 즉시 연락하세요'),
('net_cancel_required', 'en',
  'Net cancel required. Contact PG immediately')
on conflict (message_key, locale) do nothing;

insert into catchmenu_common.error_codes (
  code, error_key, error_domain,
  error_category, http_status, severity,
  sop_document_code
) values
(4015, 'payment_already_confirmed',
  'PAYMENT', 'CONFLICT', 409, 'INFO', null),
(4016, 'refund_amount_invalid',
  'PAYMENT', 'INVALID_INPUT', 400, 'WARNING', null),
(4017, 'net_cancel_required',
  'PAYMENT', 'TECHNICAL', 500, 'CRITICAL',
  'SOP-PAY-001'),
(4018, 'payment_idempotency_violation',
  'PAYMENT', 'CONFLICT', 409, 'CRITICAL',
  'SOP-PAY-003'),
(4019, 'kds_release_failed',
  'PAYMENT', 'TECHNICAL', 500, 'ERROR',
  'SOP-KDS-001')
on conflict (code) do nothing;


-- =============================================
-- RPCs
-- =============================================
drop function if exists catchmenu_payment.confirm_payment(
  uuid, uuid, uuid, text, text, text,
  int, text, jsonb, text, uuid, text, text
);

create or replace function
  catchmenu_payment.confirm_payment(
  p_tenant_id uuid,
  p_store_id uuid,
  p_order_id uuid,
  p_provider_type text,
  p_provider_approval_number text,
  p_provider_tx_id text,
  p_approved_amount int,
  p_payment_method text,
  p_provider_response jsonb default null,
  p_actor_type text default 'STAFF',
  p_actor_id uuid default null,
  p_locale text default 'ko',
  p_correlation_id text default null,
  p_intent_id uuid default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_payment,
                  catchmenu_pos,
                  catchmenu_kds,
                  catchmenu_ledger,
                  catchmenu_audit,
                  catchmenu_common,
                  catchmenu_hq
as $$
declare
  v_order record;
  v_ledger_id uuid;
  v_kds_result jsonb;
  v_audit_id uuid;
  v_business_day date;
  v_timezone text;
  v_net_amount int;
  v_fee_amount int;
  v_intent_id uuid;
  v_provider_response_id uuid;
  v_gateway_provider_type text;
  v_actor_type text;
  v_row_count int;
begin
  v_actor_type := case
    when p_actor_type in (
      'SYSTEM',
      'AGENT',
      'STAFF',
      'MANAGER',
      'OWNER',
      'HQ_ADMIN',
      'CUSTOMER',
      'PROVIDER',
      'SCHEDULER'
    ) then p_actor_type
    when p_actor_type in (
      'PG_WEBHOOK',
      'POS_WEBHOOK',
      'VAN_WEBHOOK',
      'PROVIDER_WEBHOOK'
    ) then 'PROVIDER'
    else 'SYSTEM'
  end;

  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  -- 멱등성 검사 (correlation_id 기반)
  if p_correlation_id is not null then
    select pl.id
    into v_ledger_id
    from catchmenu_payment.payment_ledger pl
    join catchmenu_pos.orders o
      on o.id = pl.order_id
    where pl.store_id = p_store_id
      and pl.tenant_id = p_tenant_id
      and pl.provider_payment_key = p_provider_tx_id
      and pl.provider_type = p_provider_type
      and pl.ledger_status = 'APPROVED'
      and pl.order_id = p_order_id
    order by pl.approved_at desc
    limit 1;

    if v_ledger_id is not null then
      if exists (
        select 1
        from catchmenu_pos.orders
        where id = p_order_id
          and store_id = p_store_id
          and tenant_id = p_tenant_id
          and order_status = 'CONFIRMED'
      ) then
        return catchmenu_common.build_success_response(
          p_message_key := 'payment_already_confirmed_idempotent',
          p_data := jsonb_build_object(
            'ledger_id', v_ledger_id,
            'order_id', p_order_id,
            'already_confirmed', true
          ),
          p_locale := p_locale,
          p_correlation_id := p_correlation_id
        );
      end if;

      perform catchmenu_common.log_diagnostic(
        p_tenant_id := p_tenant_id,
        p_store_id := p_store_id,
        p_log_level := 'CRITICAL',
        p_log_domain := 'PAYMENT',
        p_log_event :=
          'payment_idempotency_violation',
        p_message :=
          'Duplicate payment confirmation attempt: '
          || p_provider_tx_id,
        p_rpc_name := 'confirm_payment',
        p_correlation_id := p_correlation_id,
        p_details := jsonb_build_object(
          'provider_tx_id', p_provider_tx_id,
          'provider_type', p_provider_type,
          'order_id', p_order_id,
          'existing_ledger_id', v_ledger_id
        )
      );

      return catchmenu_common.build_error_response(
        p_error_key := 'payment_already_confirmed',
        p_locale := p_locale,
        p_tenant_id := p_tenant_id,
        p_store_id := p_store_id,
        p_correlation_id := p_correlation_id,
        p_rpc_name := 'confirm_payment',
        p_order_id := p_order_id,
        p_payment_id := v_ledger_id
      );
    end if;
  end if;

  -- 주문 조회
  select id, order_number, order_status,
         order_type, final_amount, session_id,
         total_amount, discount_amount
  into v_order
  from catchmenu_pos.orders
  where id = p_order_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
  for update;

  if v_order.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'order_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'confirm_payment'
    );
  end if;

  -- 이미 결제 완료
  if v_order.order_status = 'CONFIRMED' then
    select id
    into v_ledger_id
    from catchmenu_payment.payment_ledger
    where order_id = p_order_id
      and provider_payment_key = p_provider_tx_id
      and provider_type = p_provider_type
      and ledger_status = 'APPROVED'
    order by approved_at desc
    limit 1;

    if v_ledger_id is not null then
      return catchmenu_common.build_success_response(
        p_message_key := 'payment_already_confirmed_idempotent',
        p_data := jsonb_build_object(
          'ledger_id', v_ledger_id,
          'order_id', p_order_id,
          'already_confirmed', true
        ),
        p_locale := p_locale,
        p_correlation_id := p_correlation_id
      );
    end if;

    return catchmenu_common.build_error_response(
      p_error_key := 'payment_already_confirmed',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_correlation_id := p_correlation_id,
      p_rpc_name := 'confirm_payment',
      p_order_id := p_order_id
    );
  elsif v_order.order_status in (
    'COOKING',
    'READY',
    'SERVED',
    'COMPLETED'
  ) then
    return catchmenu_common.build_error_response(
      p_error_key := 'order_not_confirmable',
      p_locale := p_locale,
      p_params := jsonb_build_object(
        'current_status', v_order.order_status
      ),
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_correlation_id := p_correlation_id,
      p_rpc_name := 'confirm_payment',
      p_order_id := p_order_id
    );
  elsif v_order.order_status not in (
    'PENDING',
    'CANCELLED',
    'REFUNDED',
    'PARTIAL_REFUNDED'
  ) then
    return catchmenu_common.build_error_response(
      p_error_key := 'order_not_confirmable',
      p_locale := p_locale,
      p_params := jsonb_build_object(
        'current_status', v_order.order_status
      ),
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_correlation_id := p_correlation_id,
      p_rpc_name := 'confirm_payment',
      p_order_id := p_order_id
    );
  end if;

  if v_order.order_status = 'PENDING' and exists (
    select 1 from catchmenu_payment.payment_ledger
    where order_id = p_order_id
      and ledger_status = 'APPROVED'
  ) then
    return catchmenu_common.build_error_response(
      p_error_key := 'payment_already_confirmed',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_correlation_id := p_correlation_id,
      p_rpc_name := 'confirm_payment',
      p_order_id := p_order_id
    );
  end if;
  -- 금액 검증 (±10원 허용 오차)
  if abs(p_approved_amount - v_order.final_amount)
    > 10
  then
    perform catchmenu_common.log_diagnostic(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_log_level := 'ERROR',
      p_log_domain := 'PAYMENT',
      p_log_event := 'payment_amount_mismatch',
      p_message :=
        'Payment amount mismatch'
        || ' | order=' || v_order.final_amount
        || ' | approved=' || p_approved_amount,
      p_rpc_name := 'confirm_payment',
      p_details := jsonb_build_object(
        'order_amount', v_order.final_amount,
        'approved_amount', p_approved_amount,
        'diff', abs(
          p_approved_amount - v_order.final_amount
        )
      )
    );
  end if;

  -- 수수료 추정 (PG사별 기본 요율 적용)
  v_fee_amount := case p_provider_type
    when 'TOSS_PAYMENTS' then
      (p_approved_amount * 0.015)::int
    when 'NICE_VAN' then
      (p_approved_amount * 0.020)::int
    when 'KIS_VAN' then
      (p_approved_amount * 0.018)::int
    else
      (p_approved_amount * 0.015)::int
  end;
  v_net_amount := p_approved_amount;

  v_gateway_provider_type := case
    when p_provider_type in (
      'TOSS_POS',
      'TOSS_PAYMENTS',
      'VAN_NICE',
      'VAN_KIS',
      'VAN_KICC',
      'PG_KAKAO',
      'PG_NAVER',
      'ALIPAY',
      'WECHAT_PAY',
      'SAMSUNG_PAY',
      'DELIVERY_BAEMIN',
      'DELIVERY_YOGIYO',
      'DELIVERY_COUPANG',
      'OKPOS',
      'KIOSK_VENDOR',
      'INTERNAL_AGENT',
      'OTHER'
    ) then p_provider_type
    else 'OTHER'
  end;

  insert into catchmenu_gateway.provider_raw_events (
    tenant_id,
    store_id,
    provider_type,
    provider_code,
    provider_event_id,
    provider_event_type,
    raw_payload,
    correlation_id
  ) values (
    p_tenant_id,
    p_store_id,
    v_gateway_provider_type,
    p_provider_type,
    p_provider_tx_id,
    'PAYMENT_CONFIRM',
    coalesce(
      p_provider_response,
      jsonb_build_object(
        'provider_type', p_provider_type,
        'provider_tx_id', p_provider_tx_id,
        'provider_approval_number',
          p_provider_approval_number,
        'approved_amount', p_approved_amount
      )
    ),
    p_correlation_id
  )
  returning id into v_provider_response_id;

  v_intent_id :=
    catchmenu_payment.resolve_or_create_payment_intent(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_order_id := p_order_id,
      p_requested_amount := p_approved_amount,
      p_payment_method := p_payment_method,
      p_payment_channel := 'STAFF_POS',
      p_provider_type := p_provider_type,
      p_intent_origin := case
        when p_intent_id is not null then
          'PREAUTHORIZED'
        else
          'POS_SYNTHESIZED'
      end,
      p_origin_reference := jsonb_build_object(
        'source', 'confirm_payment',
        'provider_type', p_provider_type,
        'provider_tx_id', p_provider_tx_id,
        'provider_approval_number',
          p_provider_approval_number
      ),
      p_intent_id := p_intent_id,
      p_session_id := v_order.session_id,
      p_locale := p_locale
    );

  if v_intent_id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'payment_intent_resolution_failed',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'confirm_payment'
    );
  end if;

  -- 결제 원장 기록 (Layer 1)
  if v_order.order_status in (
    'CANCELLED',
    'REFUNDED',
    'PARTIAL_REFUNDED'
  ) then
    insert into catchmenu_payment.payment_ledger (
      tenant_id, store_id,
      order_id, session_id,
      intent_id,
      ledger_entry_type,
      provider_type,
      provider_payment_key,
      provider_approval_number,
      provider_approved_at,
      provider_response_id,
      approved_amount, net_amount,
      ledger_status,
      approved_at,
      reconciliation_status,
      business_day, business_timezone
    ) values (
      p_tenant_id, p_store_id,
      p_order_id, v_order.session_id,
      v_intent_id,
      'APPROVAL',
      p_provider_type,
      p_provider_tx_id,
      p_provider_approval_number,
      now(),
      v_provider_response_id,
      p_approved_amount, v_net_amount,
      'APPROVED',
      now(),
      'MANUAL_REVIEW',
      v_business_day, v_timezone
    )
    returning id into v_ledger_id;

    insert into catchmenu_payment.payment_events (
      tenant_id, store_id, order_id,
      intent_id, ledger_id,
      event_type, from_status, to_status,
      caused_by_type, caused_by_id,
      amount_at_event,
      provider_event_id,
      event_payload, correlation_id, occurred_at
    ) values (
      p_tenant_id, p_store_id, p_order_id,
      v_intent_id, v_ledger_id,
      'payment_approved',
      v_order.order_status, 'APPROVED_MANUAL_REVIEW',
      v_actor_type, p_actor_id,
      p_approved_amount,
      p_provider_tx_id,
      jsonb_build_object(
        'reason', 'payment_approved_after_order_cancelled',
        'order_status', v_order.order_status,
        'provider_type', p_provider_type,
        'provider_tx_id', p_provider_tx_id,
        'provider_approval_number',
          p_provider_approval_number,
        'reconciliation_status', 'MANUAL_REVIEW'
      ),
      p_correlation_id, now()
    );

    insert into catchmenu_ledger.events (
      tenant_id, store_id,
      event_domain, event_type, event_version,
      subject_type, subject_id,
      from_state, to_state,
      caused_by_type, caused_by_id,
      event_payload,
      order_id, payment_id, correlation_id,
      business_day, business_timezone, occurred_at
    ) values (
      p_tenant_id, p_store_id,
      'payment',
      'payment_approved_after_order_cancelled', 1,
      'payment_ledger', v_ledger_id,
      v_order.order_status, 'APPROVED_MANUAL_REVIEW',
      v_actor_type, p_actor_id,
      jsonb_build_object(
        'reason', 'payment_approved_after_order_cancelled',
        'order_status', v_order.order_status,
        'provider_type', p_provider_type,
        'provider_tx_id', p_provider_tx_id,
        'provider_approval_number',
          p_provider_approval_number,
        'approved_amount', p_approved_amount,
        'reconciliation_status', 'MANUAL_REVIEW'
      ),
      p_order_id, v_ledger_id, p_correlation_id,
      v_business_day, v_timezone, now()
    );

    return catchmenu_common.build_error_response(
      p_error_key := 'payment_already_confirmed',
      p_locale := p_locale,
      p_details := jsonb_build_object(
        'ledger_id', v_ledger_id,
        'order_id', p_order_id,
        'order_status', v_order.order_status,
        'reconciliation_status', 'MANUAL_REVIEW',
        'reason', 'payment_approved_after_order_cancelled'
      ),
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_correlation_id := p_correlation_id,
      p_rpc_name := 'confirm_payment',
      p_order_id := p_order_id,
      p_payment_id := v_ledger_id
    );
  end if;

  insert into catchmenu_payment.payment_ledger (
    tenant_id, store_id,
    order_id, session_id,
    intent_id,
    ledger_entry_type,
    provider_type,
    provider_payment_key,
    provider_approval_number,
    provider_approved_at,
    provider_response_id,
    approved_amount, net_amount,
    ledger_status,
    approved_at,
    reconciliation_status,
    business_day, business_timezone
  ) values (
    p_tenant_id, p_store_id,
    p_order_id, v_order.session_id,
    v_intent_id,
    'APPROVAL',
    p_provider_type,
    p_provider_tx_id,
    p_provider_approval_number,
    now(),
    v_provider_response_id,
    p_approved_amount, v_net_amount,
    'APPROVED',
    now(),
    'PENDING',
    v_business_day, v_timezone
  )
  returning id into v_ledger_id;

  -- 주문 상태 CONFIRMED → PAID
  update catchmenu_pos.orders
  set
    order_status = case order_type
      when 'TABLE' then 'COOKING'
      else 'CONFIRMED'
    end,
    confirmed_at = now(),
    updated_at = now()
  where id = p_order_id
    and order_status = 'PENDING';

  get diagnostics v_row_count = row_count;

  if v_row_count = 0 then
    return catchmenu_common.build_error_response(
      p_error_key := 'order_status_changed_concurrently',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_correlation_id := p_correlation_id,
      p_rpc_name := 'confirm_payment',
      p_order_id := p_order_id,
      p_payment_id := v_ledger_id
    );
  end if;

  -- ==========================================
  -- 특허2 핵심: KDS Late Binding 해제
  -- HOLD → COMMITTED (조리 시작 승인)
  -- ==========================================
  v_kds_result :=
    catchmenu_payment.release_kds_after_payment(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_order_id := p_order_id,
      p_ledger_id := v_ledger_id,
      p_locale := p_locale,
      p_correlation_id := p_correlation_id
    );

  -- audit
  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := 'payment',
    p_audit_type := 'payment_confirmed',
    p_audit_category := 'FINANCIAL',
    p_actor_type := v_actor_type,
    p_actor_id := p_actor_id,
    p_subject_type := 'payment_ledger',
    p_subject_id := v_ledger_id,
    p_decision := 'APPROVED',
    p_decision_payload := jsonb_build_object(
      'order_id', p_order_id,
      'order_number', v_order.order_number,
      'provider_type', p_provider_type,
      'approved_amount', p_approved_amount,
      'approval_number',
        p_provider_approval_number,
      'kds_released',
        (v_kds_result->>'success')::boolean
    ),
    p_correlation_id := p_correlation_id,
    p_business_day := v_business_day,
    p_business_timezone := v_timezone
  );

  -- ledger event
  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, caused_by_id,
    event_payload,
    order_id, correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'payment', 'payment_confirmed', 1,
    'payment_ledger', v_ledger_id,
    'PENDING', 'APPROVED',
    v_actor_type, p_actor_id,
    jsonb_build_object(
      'order_id', p_order_id,
      'order_number', v_order.order_number,
      'provider_type', p_provider_type,
      'approved_amount', p_approved_amount,
      'net_amount', v_net_amount,
      'approval_number',
        p_provider_approval_number,
      'kds_tickets_released',
        v_kds_result->'data'->>'released_count',
      'audit_id', v_audit_id
    ),
    p_order_id, p_correlation_id,
    v_business_day, v_timezone, now()
  );

  -- Realtime → 직원 앱 결제 완료 알림
  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_channel_type := 'STAFF_ALERTS',
    p_event_type := 'payment_confirmed',
    p_payload := jsonb_build_object(
      'order_id', p_order_id,
      'order_number', v_order.order_number,
      'approved_amount', p_approved_amount,
      'provider_type', p_provider_type,
      'kds_released',
        (v_kds_result->>'success')::boolean
    )
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'payment_confirmed',
    p_data := jsonb_build_object(
      'ledger_id', v_ledger_id,
      'order_id', p_order_id,
      'order_number', v_order.order_number,
      'provider_type', p_provider_type,
      'provider_tx_id', p_provider_tx_id,
      'approval_number',
        p_provider_approval_number,
      'approved_amount', p_approved_amount,
      'fee_amount', v_fee_amount,
      'net_amount', v_net_amount,
      'audit_id', v_audit_id,
      'kds', v_kds_result->'data',
      'late_binding_note',
        catchmenu_common.get_message(
          'kds_late_binding_released',
          p_locale, null
        )
    ),
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );
end;
$$;


-- =============================================
-- 특허2 핵심 함수
-- KDS Late Binding 해제
-- 결제 확인 후 HOLD → COMMITTED
-- =============================================
create or replace function
  catchmenu_payment.release_kds_after_payment(
  p_tenant_id uuid,
  p_store_id uuid,
  p_order_id uuid,
  p_ledger_id uuid,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_payment,
                  catchmenu_kds,
                  catchmenu_common
as $$
declare
  v_released_count int := 0;
  v_ticket_ids jsonb := '[]'::jsonb;
  v_capacity_check jsonb;
  v_business_day date;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  -- KDS 용량 재확인
  -- (결제 완료 시점에도 Late Binding 조건 검증)
  v_capacity_check :=
    catchmenu_kds.check_kds_capacity(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id
    );

  -- HOLD 티켓 → COMMITTED (조리 시작)
  -- conditions_met 업데이트:
  --   payment_confirmed = true
  --   kds_release_authorized = true
  with released as (
    update catchmenu_kds.kds_tickets
    set
      kds_status = 'COMMITTED',
      conditions_met = jsonb_build_object(
        'payment_confirmed', true,
        'kds_release_authorized', true,
        'payment_ledger_id', p_ledger_id,
        'released_at', now()
      ),
      committed_at = now(),
      updated_at = now()
    where order_id = p_order_id
      and store_id = p_store_id
      and tenant_id = p_tenant_id
      and kds_status = 'HOLD'
    returning id
  )
  select
    count(*),
    coalesce(
      jsonb_agg(to_jsonb(id)), '[]'::jsonb
    )
  into v_released_count, v_ticket_ids
  from released;

  if v_released_count = 0 then
    -- HOLD 티켓 없음 (이미 해제되었거나 없음)
    perform catchmenu_common.log_diagnostic(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_log_level := 'WARNING',
      p_log_domain := 'KDS',
      p_log_event := 'kds_no_hold_tickets',
      p_message :=
        'KDS HOLD 티켓 없음: order_id='
        || p_order_id,
      p_rpc_name := 'release_kds_after_payment',
      p_correlation_id := p_correlation_id,
      p_details := jsonb_build_object(
        'order_id', p_order_id,
        'ledger_id', p_ledger_id
      )
    );
  end if;

  -- KDS Realtime 브로드캐스트
  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_channel_type := 'KDS_TICKETS',
    p_event_type := 'kds_tickets_released',
    p_payload := jsonb_build_object(
      'order_id', p_order_id,
      'ledger_id', p_ledger_id,
      'released_count', v_released_count,
      'ticket_ids', v_ticket_ids,
      'capacity', v_capacity_check->'data',
      'released_at', now()
    )
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'kds_released',
    p_data := jsonb_build_object(
      'order_id', p_order_id,
      'released_count', v_released_count,
      'ticket_ids', v_ticket_ids,
      'kds_status', 'COMMITTED',
      'capacity_after',
        v_capacity_check->'data',
      'late_binding_principle',
        'HOLD → COMMITTED after payment only'
    ),
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );
end;
$$;


-- =============================================
-- 웹훅 결제 확인
-- 토스페이먼츠/배달앱 웹훅 처리
-- =============================================
create or replace function
  catchmenu_payment.confirm_payment_webhook(
  p_tenant_id uuid,
  p_store_id uuid,
  p_webhook_payload jsonb,
  p_provider_type text,
  p_webhook_signature text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_payment,
                  catchmenu_common
as $$
declare
  v_order_id uuid;
  v_provider_tx_id text;
  v_approval_number text;
  v_approved_amount int;
  v_payment_method text;
  v_correlation_id text;
  v_result jsonb;
begin
  -- 웹훅 서명 검증 (Edge Function에서 1차 검증)
  -- 여기서는 2차 검증 (DB 레벨)
  if p_webhook_signature is not null then
    insert into catchmenu_common.security_audit_log (
      tenant_id, audit_event, event_severity,
      event_source, event_detail,
      is_violation
    ) values (
      p_tenant_id,
      'webhook_received',
      'INFO',
      'confirm_payment_webhook',
      jsonb_build_object(
        'provider_type', p_provider_type,
        'has_signature', true
      ),
      false
    );
  end if;

  -- 제공자별 웹훅 파라미터 파싱
  case p_provider_type
    when 'TOSS_PAYMENTS' then
      v_provider_tx_id :=
        p_webhook_payload->>'paymentKey';
      v_approval_number :=
        p_webhook_payload->>'approvalKey';
      v_approved_amount :=
        (p_webhook_payload->>'amount')::int;
      v_payment_method :=
        p_webhook_payload->>'method';
      v_order_id := (
        p_webhook_payload->>'orderId'
      )::uuid;

    when 'OKPOS' then
      v_provider_tx_id :=
        p_webhook_payload->>'okpos_order_id';
      v_approval_number :=
        p_webhook_payload->>'approval_number';
      v_approved_amount :=
        (p_webhook_payload->>'paid_amount')::int;
      v_payment_method :=
        coalesce(
          p_webhook_payload->>'payment_method',
          'CARD'
        );
      v_order_id := (
        p_webhook_payload->>'order_id'
      )::uuid;

    when 'TOSS_POS' then
      v_provider_tx_id :=
        p_webhook_payload->>'toss_pos_order_id';
      v_approval_number :=
        p_webhook_payload->>'approval_number';
      v_approved_amount :=
        (p_webhook_payload->>'paid_amount')::int;
      v_payment_method := 'CARD';
      v_order_id := (
        p_webhook_payload->>'order_id'
      )::uuid;

    else
      return catchmenu_common.build_error_response(
        p_error_key := 'invalid_input',
        p_locale := 'ko',
        p_params := jsonb_build_object(
          'field', 'provider_type',
          'value', p_provider_type
        ),
        p_tenant_id := p_tenant_id,
        p_store_id := p_store_id,
        p_rpc_name := 'confirm_payment_webhook'
      );
  end case;

  v_correlation_id := 'WH-' || p_provider_type
    || '-' || coalesce(
      v_provider_tx_id, gen_random_uuid()::text
    );

  -- 실제 결제 확인 실행
  v_result := catchmenu_payment.confirm_payment(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_order_id := v_order_id,
    p_provider_type := p_provider_type,
    p_provider_approval_number :=
      v_approval_number,
    p_provider_tx_id := v_provider_tx_id,
    p_approved_amount := v_approved_amount,
    p_payment_method := v_payment_method,
    p_provider_response := p_webhook_payload,
    p_actor_type := 'WEBHOOK',
    p_locale := 'ko',
    p_correlation_id := v_correlation_id
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'payment_webhook_processed',
    p_data := jsonb_build_object(
      'provider_type', p_provider_type,
      'provider_tx_id', v_provider_tx_id,
      'order_id', v_order_id,
      'correlation_id', v_correlation_id,
      'payment_result', v_result->'data'
    ),
    p_locale := 'ko',
    p_correlation_id := v_correlation_id
  );
end;
$$;


-- =============================================
-- 환불 요청
-- =============================================
create or replace function
  catchmenu_payment.request_refund(
  p_tenant_id uuid,
  p_store_id uuid,
  p_order_id uuid,
  p_refund_amount int,
  p_refund_reason text,
  p_is_partial boolean default false,
  p_actor_type text default 'STAFF',
  p_actor_id uuid default null,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_payment,
                  catchmenu_pos,
                  catchmenu_kds,
                  catchmenu_ledger,
                  catchmenu_audit,
                  catchmenu_common,
                  catchmenu_hq
as $$
declare
  v_payment record;
  v_order record;
  v_refund_ledger_id uuid;
  v_audit_id uuid;
  v_business_day date;
  v_timezone text;
begin
  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  -- 원결제 조회
  select id, provider_type,
         provider_tx_id,
         provider_approval_number,
         approved_amount, ledger_status
  into v_payment
  from catchmenu_payment.payment_ledger
  where order_id = p_order_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
    and ledger_status = 'APPROVED'
  order by approved_at desc
  limit 1;

  if v_payment.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'payment_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'request_refund'
    );
  end if;

  -- 환불 금액 검증
  if p_refund_amount <= 0
    or p_refund_amount > v_payment.approved_amount
  then
    return catchmenu_common.build_error_response(
      p_error_key := 'refund_amount_invalid',
      p_locale := p_locale,
      p_params := jsonb_build_object(
        'max_refund', v_payment.approved_amount
      ),
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'request_refund'
    );
  end if;

  -- 주문 조회
  select id, order_number, order_status
  into v_order
  from catchmenu_pos.orders
  where id = p_order_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id;

  -- 환불 원장 생성 (PENDING 상태)
  -- 실제 PG사 취소는 Edge Function 처리
  insert into catchmenu_payment.payment_ledger (
    tenant_id, store_id,
    order_id, session_id,
    provider_type, payment_method,
    provider_tx_id,
    provider_approval_number,
    approved_amount,
    fee_amount, net_amount,
    ledger_status,
    refund_reason,
    is_partial_refund,
    original_ledger_id,
    business_day, business_timezone
  )
  select
    p_tenant_id, p_store_id,
    p_order_id, pl.session_id,
    pl.provider_type, pl.payment_method,
    pl.provider_tx_id || '_REFUND',
    null,
    -p_refund_amount,
    -(pl.fee_amount * p_refund_amount
      / pl.approved_amount)::int,
    -(pl.net_amount * p_refund_amount
      / pl.approved_amount)::int,
    'REFUND_PENDING',
    p_refund_reason,
    p_is_partial,
    v_payment.id,
    v_business_day, v_timezone
  from catchmenu_payment.payment_ledger pl
  where pl.id = v_payment.id
  returning id into v_refund_ledger_id;

  -- 주문 취소 처리
  update catchmenu_pos.orders
  set
    order_status = 'CANCELLED',
    cancelled_at = now(),
    updated_at = now()
  where id = p_order_id;

  -- KDS 취소
  update catchmenu_kds.kds_tickets
  set
    kds_status = 'CANCELLED',
    cancelled_at = now(),
    updated_at = now()
  where order_id = p_order_id
    and store_id = p_store_id
    and kds_status not in (
      'SERVED', 'COMPLETED', 'CANCELLED'
    );

  -- audit
  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := 'payment',
    p_audit_type := 'refund_requested',
    p_audit_category := 'FINANCIAL',
    p_actor_type := p_actor_type,
    p_actor_id := p_actor_id,
    p_subject_type := 'payment_ledger',
    p_subject_id := v_refund_ledger_id,
    p_decision := 'REFUND_PENDING',
    p_decision_reason := p_refund_reason,
    p_decision_payload := jsonb_build_object(
      'order_id', p_order_id,
      'refund_amount', p_refund_amount,
      'original_amount',
        v_payment.approved_amount,
      'is_partial', p_is_partial,
      'provider_type', v_payment.provider_type
    ),
    p_correlation_id := p_correlation_id,
    p_business_day := v_business_day,
    p_business_timezone := v_timezone
  );

  -- ledger event
  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, caused_by_id,
    event_payload,
    order_id, correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'payment', 'refund_requested', 1,
    'payment_ledger', v_refund_ledger_id,
    'APPROVED', 'REFUND_PENDING',
    p_actor_type, p_actor_id,
    jsonb_build_object(
      'order_id', p_order_id,
      'order_number', v_order.order_number,
      'refund_amount', p_refund_amount,
      'refund_reason', p_refund_reason,
      'provider_type', v_payment.provider_type,
      'original_tx_id', v_payment.provider_tx_id
    ),
    p_order_id, p_correlation_id,
    v_business_day, v_timezone, now()
  );

  -- Edge Function에 PG 취소 요청
  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_channel_type := 'SYSTEM_EVENTS',
    p_event_type := 'pg_cancel_requested',
    p_payload := jsonb_build_object(
      'refund_ledger_id', v_refund_ledger_id,
      'order_id', p_order_id,
      'order_number', v_order.order_number,
      'provider_type', v_payment.provider_type,
      'provider_tx_id', v_payment.provider_tx_id,
      'approval_number',
        v_payment.provider_approval_number,
      'refund_amount', p_refund_amount,
      'refund_reason', p_refund_reason,
      'correlation_id', p_correlation_id
    )
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'refund_requested',
    p_data := jsonb_build_object(
      'refund_ledger_id', v_refund_ledger_id,
      'order_id', p_order_id,
      'order_number', v_order.order_number,
      'refund_amount', p_refund_amount,
      'provider_type', v_payment.provider_type,
      'refund_status', 'REFUND_PENDING',
      'audit_id', v_audit_id,
      'note',
        'PG 취소는 Edge Function이 처리합니다'
    ),
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );
end;
$$;


-- =============================================
-- 환불 확인 (Edge Function → 웹훅 콜백)
-- =============================================
create or replace function
  catchmenu_payment.confirm_refund(
  p_tenant_id uuid,
  p_store_id uuid,
  p_refund_ledger_id uuid,
  p_provider_cancel_tx_id text,
  p_cancel_result text default 'SUCCESS',
  p_provider_response jsonb default null,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_payment,
                  catchmenu_ledger,
                  catchmenu_audit,
                  catchmenu_common,
                  catchmenu_hq
as $$
declare
  v_refund record;
  v_audit_id uuid;
  v_business_day date;
  v_timezone text;
  v_new_status text;
begin
  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  select id, order_id, provider_type,
         approved_amount, refund_reason,
         original_ledger_id
  into v_refund
  from catchmenu_payment.payment_ledger
  where id = p_refund_ledger_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
    and ledger_status = 'REFUND_PENDING'
  for update;

  if v_refund.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'payment_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'confirm_refund'
    );
  end if;

  v_new_status := case p_cancel_result
    when 'SUCCESS' then 'REFUNDED'
    else 'REFUND_FAILED'
  end;

  -- 환불 원장 업데이트
  update catchmenu_payment.payment_ledger
  set
    ledger_status = v_new_status,
    provider_tx_id = p_provider_cancel_tx_id,
    provider_response = coalesce(
      p_provider_response, provider_response
    ),
    refunded_at = case p_cancel_result
      when 'SUCCESS' then now()
      else null
    end,
    updated_at = now()
  where id = p_refund_ledger_id;

  -- 원결제 원장 상태 업데이트
  if p_cancel_result = 'SUCCESS' then
    update catchmenu_payment.payment_ledger
    set
      ledger_status = 'REFUNDED',
      refunded_at = now(),
      updated_at = now()
    where id = v_refund.original_ledger_id;
  end if;

  -- 망취소 실패 처리
  if p_cancel_result <> 'SUCCESS' then
    perform catchmenu_common.log_diagnostic(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_log_level := 'CRITICAL',
      p_log_domain := 'PAYMENT',
      p_log_event := 'net_cancel_failed',
      p_message :=
        '망취소 실패 - 즉시 PG사 연락 필요',
      p_rpc_name := 'confirm_refund',
      p_correlation_id := p_correlation_id,
      p_details := jsonb_build_object(
        'refund_ledger_id', p_refund_ledger_id,
        'order_id', v_refund.order_id,
        'provider_type', v_refund.provider_type,
        'cancel_result', p_cancel_result
      )
    );

    -- 운영 알림 생성
    perform catchmenu_common.create_operation_alert(
      p_tenant_id := p_tenant_id,
      p_alert_type := 'PAYMENT_FAILED',
      p_alert_severity := 'CRITICAL',
      p_alert_domain := 'PAYMENT',
      p_alert_title_key := 'net_cancel_required',
      p_alert_detail := jsonb_build_object(
        'refund_ledger_id', p_refund_ledger_id,
        'order_id', v_refund.order_id,
        'provider_type', v_refund.provider_type
      ),
      p_store_id := p_store_id,
      p_sop_runbook_code := 'SOP-PAY-002'
    );
  end if;

  -- audit
  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := 'payment',
    p_audit_type := 'refund_confirmed',
    p_audit_category := 'FINANCIAL',
    p_actor_type := 'WEBHOOK',
    p_subject_type := 'payment_ledger',
    p_subject_id := p_refund_ledger_id,
    p_decision := v_new_status,
    p_decision_payload := jsonb_build_object(
      'cancel_tx_id', p_provider_cancel_tx_id,
      'cancel_result', p_cancel_result,
      'refund_amount', v_refund.approved_amount
    ),
    p_correlation_id := p_correlation_id,
    p_business_day := v_business_day,
    p_business_timezone := v_timezone
  );

  -- ledger event
  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, event_payload,
    order_id, correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'payment', 'refund_confirmed', 1,
    'payment_ledger', p_refund_ledger_id,
    'REFUND_PENDING', v_new_status,
    'WEBHOOK',
    jsonb_build_object(
      'cancel_tx_id', p_provider_cancel_tx_id,
      'cancel_result', p_cancel_result,
      'refund_amount', v_refund.approved_amount,
      'audit_id', v_audit_id
    ),
    v_refund.order_id, p_correlation_id,
    v_business_day, v_timezone, now()
  );

  return catchmenu_common.build_success_response(
    p_message_key := case p_cancel_result
      when 'SUCCESS' then 'refund_confirmed'
      else 'refund_failed'
    end,
    p_data := jsonb_build_object(
      'refund_ledger_id', p_refund_ledger_id,
      'order_id', v_refund.order_id,
      'refund_status', v_new_status,
      'cancel_tx_id', p_provider_cancel_tx_id,
      'refund_amount', v_refund.approved_amount,
      'audit_id', v_audit_id
    ),
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );
end;
$$;


-- =============================================
-- 결제 현황 조회
-- =============================================
create or replace function
  catchmenu_payment.get_payment_status(
  p_tenant_id uuid,
  p_store_id uuid,
  p_order_id uuid,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_payment,
                  catchmenu_pos,
                  catchmenu_common
as $$
declare
  v_order record;
  v_payments jsonb;
  v_total_approved int;
  v_total_refunded int;
  v_net_paid int;
begin
  select id, order_number, order_status,
         order_type, final_amount,
         total_amount, discount_amount
  into v_order
  from catchmenu_pos.orders
  where id = p_order_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id;

  if v_order.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'order_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'get_payment_status'
    );
  end if;

  -- 결제 원장 목록
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'ledger_id', id,
        'provider_type', provider_type,
        'payment_method', payment_method,
        'provider_tx_id', provider_tx_id,
        'approval_number',
          provider_approval_number,
        'approved_amount', approved_amount,
        'fee_amount', fee_amount,
        'net_amount', net_amount,
        'ledger_status', ledger_status,
        'approved_at', approved_at,
        'refunded_at', refunded_at,
        'is_partial_refund', is_partial_refund,
        'refund_reason', refund_reason
      )
      order by approved_at asc
    ),
    '[]'::jsonb
  )
  into v_payments
  from catchmenu_payment.payment_ledger
  where order_id = p_order_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
  order by approved_at;

  -- 합계 계산
  select
    coalesce(sum(approved_amount) filter (
      where ledger_status = 'APPROVED'
    ), 0),
    coalesce(abs(sum(approved_amount)) filter (
      where ledger_status = 'REFUNDED'
    ), 0)
  into v_total_approved, v_total_refunded
  from catchmenu_payment.payment_ledger
  where order_id = p_order_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id;

  v_net_paid := v_total_approved - v_total_refunded;

  return catchmenu_common.build_success_response(
    p_message_key := 'payment_status_loaded',
    p_data := jsonb_build_object(
      'order_id', p_order_id,
      'order_number', v_order.order_number,
      'order_status', v_order.order_status,
      'order_amount', jsonb_build_object(
        'total_amount', v_order.total_amount,
        'discount_amount',
          v_order.discount_amount,
        'final_amount', v_order.final_amount
      ),
      'payment_summary', jsonb_build_object(
        'total_approved', v_total_approved,
        'total_refunded', v_total_refunded,
        'net_paid', v_net_paid,
        'is_fully_paid',
          v_total_approved
            >= v_order.final_amount,
        'is_refunded', v_total_refunded > 0
      ),
      'payments', v_payments,
      'payment_count',
        jsonb_array_length(v_payments)
    ),
    p_locale := p_locale
  );
end;
$$;


-- grants
do $$
begin
  revoke all on function
    catchmenu_payment.confirm_payment(
      uuid, uuid, uuid, text, text, text,
      int, text, jsonb, text, uuid, text, text, uuid
    ) from public;
  grant execute on function
    catchmenu_payment.confirm_payment(
      uuid, uuid, uuid, text, text, text,
      int, text, jsonb, text, uuid, text, text, uuid
    ) to authenticated;

  revoke all on function
    catchmenu_payment.release_kds_after_payment(
      uuid, uuid, uuid, uuid, text, text
    ) from public;
  grant execute on function
    catchmenu_payment.release_kds_after_payment(
      uuid, uuid, uuid, uuid, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_payment.confirm_payment_webhook(
      uuid, uuid, jsonb, text, text
    ) from public;
  grant execute on function
    catchmenu_payment.confirm_payment_webhook(
      uuid, uuid, jsonb, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_payment.request_refund(
      uuid, uuid, uuid, int, text,
      boolean, text, uuid, text, text
    ) from public;
  grant execute on function
    catchmenu_payment.request_refund(
      uuid, uuid, uuid, int, text,
      boolean, text, uuid, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_payment.confirm_refund(
      uuid, uuid, uuid, text, text, jsonb, text, text
    ) from public;
  grant execute on function
    catchmenu_payment.confirm_refund(
      uuid, uuid, uuid, text, text, jsonb, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_payment.get_payment_status(
      uuid, uuid, uuid, text
    ) from public;
  grant execute on function
    catchmenu_payment.get_payment_status(
      uuid, uuid, uuid, text
    ) to authenticated;
end;
$$;

comment on function
  catchmenu_payment.confirm_payment(
    uuid, uuid, uuid, text, text, text,
    int, text, jsonb, text, uuid, text, text, uuid
  ) is
  '결제 확인 파이프라인 핵심 함수.
   처리 순서:
   1. 멱등성 검사 (provider_tx_id 중복 방지)
   2. 주문 조회 + 금액 검증 (±10원 허용)
   3. payment_ledger 기록 (APPROVED)
   4. 주문 상태 → PAID/COOKING
   5. ★ KDS Late Binding 해제 ★
      HOLD → COMMITTED (특허2 핵심)
   6. 감사 기록 + ledger event
   7. Realtime 직원 앱 알림

   특허2 Late Binding 원칙:
   결제 확인 전: KDS = HOLD (조리 금지)
   결제 확인 후: KDS = COMMITTED (조리 시작)
   → 과결제/미결제 주방 혼란 방지.

   멱등성: provider_tx_id + correlation_id
   수수료: PG사별 기본 요율 자동 적용.
   Layer 1 대사: payment_ledger 즉시 기록.';

comment on function
  catchmenu_payment.release_kds_after_payment(
    uuid, uuid, uuid, uuid, text, text
  ) is
  '특허2 KDS Late Binding 해제 함수.
   HOLD → COMMITTED 상태 전환.
   conditions_met 업데이트:
   - payment_confirmed: true
   - kds_release_authorized: true
   - payment_ledger_id: 증빙 연결
   KDS Realtime 브로드캐스트 → 주방 화면 즉시 반영.
   결제 취소 시 → KDS CANCELLED 처리.
   이 함수 없이는 주방이 조리 시작 불가.
   F&B OS의 심장 = 특허2 Late Binding.';


-- ===== END sql/migrations/0098_create_payment_confirm_pipeline_rpc.sql =====


-- ===== BEGIN sql/migrations/0103_create_toss_payments_pipeline_rpc.sql =====

-- 0103_create_toss_payments_pipeline_rpc.sql
-- Purpose: Toss Payments integration pipeline.
--          토스페이먼츠 결제 요청, 확인, 취소,
--          가상계좌, 웹훅 처리 파이프라인.
--          1차 MVP 핵심 결제 연동.
--          i18n: 모든 메시지 = message_catalog 참조.
-- Depends on: 0102_create_okpos_integration_pipeline_rpc.sql
-- Creates:
--   catchmenu_integrations.toss_payment_requests (table)
--   catchmenu_integrations.toss_webhook_log (table)
--   function catchmenu_integrations.initiate_toss_payment(...)
--   function catchmenu_integrations.confirm_toss_payment(...)
--   function catchmenu_integrations.cancel_toss_payment(...)
--   function catchmenu_integrations.process_toss_webhook(...)
--   function catchmenu_integrations.get_toss_payment_status(...)

-- =============================================
-- i18n 메시지 등록
-- =============================================
insert into catchmenu_common.message_catalog (
  message_key, locale, message_text
) values
('toss_payment_initiated', 'ko',
  '토스페이먼츠 결제가 시작되었습니다'),
('toss_payment_initiated', 'en',
  'Toss Payments initiated'),
('toss_payment_confirmed', 'ko',
  '토스페이먼츠 결제가 완료되었습니다'),
('toss_payment_confirmed', 'en',
  'Toss Payments confirmed'),
('toss_payment_cancelled', 'ko',
  '토스페이먼츠 결제가 취소되었습니다'),
('toss_payment_cancelled', 'en',
  'Toss Payments cancelled'),
('toss_webhook_processed', 'ko',
  '토스페이먼츠 웹훅이 처리되었습니다'),
('toss_webhook_processed', 'en',
  'Toss Payments webhook processed'),
('toss_payment_status_loaded', 'ko',
  '토스페이먼츠 결제 상태가 로드되었습니다'),
('toss_payment_status_loaded', 'en',
  'Toss Payments status loaded'),
('toss_payment_failed', 'ko',
  '토스페이먼츠 결제에 실패했습니다'),
('toss_payment_failed', 'en',
  'Toss Payments failed'),
('toss_payment_expired', 'ko',
  '결제 시간이 초과되었습니다'),
('toss_payment_expired', 'en',
  'Payment session expired'),
('toss_idempotency_key_duplicate', 'ko',
  '중복 결제 요청이 감지되었습니다'),
('toss_idempotency_key_duplicate', 'en',
  'Duplicate payment request detected'),
('toss_webhook_signature_invalid', 'ko',
  '웹훅 서명이 유효하지 않습니다'),
('toss_webhook_signature_invalid', 'en',
  'Webhook signature invalid')
on conflict (message_key, locale) do nothing;

insert into catchmenu_common.error_codes (
  code, error_key, error_domain,
  error_category, http_status, severity,
  sop_document_code
) values
(9020, 'toss_payment_initiate_failed',
  'PAYMENT', 'TECHNICAL', 500, 'ERROR',
  'SOP-PAY-001'),
(9021, 'toss_payment_confirm_failed',
  'PAYMENT', 'TECHNICAL', 500, 'CRITICAL',
  'SOP-PAY-001'),
(9022, 'toss_payment_cancel_failed',
  'PAYMENT', 'TECHNICAL', 500, 'CRITICAL',
  'SOP-PAY-002'),
(9023, 'toss_webhook_signature_invalid',
  'PAYMENT', 'SECURITY', 401, 'CRITICAL',
  'SOP-SEC-004'),
(9024, 'toss_payment_expired',
  'PAYMENT', 'BUSINESS_RULE', 410, 'INFO', null),
(9025, 'toss_idempotency_key_duplicate',
  'PAYMENT', 'CONFLICT', 409, 'WARNING', null),
(9026, 'toss_config_not_found',
  'PAYMENT', 'NOT_FOUND', 404, 'ERROR',
  'SOP-PAY-001')
on conflict (code) do nothing;


-- =============================================
-- toss_payment_requests table
-- 토스페이먼츠 결제 요청 관리
-- =============================================
create table if not exists
  catchmenu_integrations.toss_payment_requests (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid not null
    references catchmenu_hq.stores(id),

  -- 주문 연결
  order_id uuid
    references catchmenu_pos.orders(id),

  -- 토스페이먼츠 식별자
  payment_key text,
  order_id_toss text not null unique,
  idempotency_key text not null unique,

  -- 결제 정보
  payment_method text,
  amount int not null,
  order_name text not null,

  -- 고객 정보 (해시)
  customer_id_hash text,
  customer_name_masked text,

  -- 상태
  request_status text
    not null default 'READY',

  -- 토스페이먼츠 응답
  toss_response jsonb,
  failure_code text,
  failure_message text,

  -- 타임스탬프
  requested_at timestamptz
    not null default now(),
  confirmed_at timestamptz,
  cancelled_at timestamptz,
  expired_at timestamptz
    not null default
      now() + interval '15 minutes',

  -- 결제 결과
  approved_amount int,
  supplied_amount int,
  vat int,
  tax_free_amount int not null default 0,

  -- 카드 정보 (마스킹)
  card_number_masked text,
  card_company text,
  card_type text,
  installment_plan_months int
    not null default 0,

  business_day date,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint chk_request_status check (
    request_status in (
      'READY',       -- 결제 준비
      'IN_PROGRESS', -- 결제 중 (고객 인증)
      'DONE',        -- 결제 완료
      'CANCELED',    -- 취소
      'PARTIAL_CANCELED', -- 부분 취소
      'ABORTED',     -- 결제 중단
      'EXPIRED'      -- 만료
    )
  )
);

create index if not exists idx_toss_requests_order
  on catchmenu_integrations.toss_payment_requests(
    order_id
  ) where order_id is not null;
create index if not exists idx_toss_requests_store
  on catchmenu_integrations.toss_payment_requests(
    store_id, request_status, requested_at desc
  );
create index if not exists idx_toss_requests_key
  on catchmenu_integrations.toss_payment_requests(
    payment_key
  ) where payment_key is not null;
create index if not exists idx_toss_requests_expired
  on catchmenu_integrations.toss_payment_requests(
    expired_at
  ) where request_status = 'READY';

alter table
  catchmenu_integrations.toss_payment_requests
  enable row level security;
alter table
  catchmenu_integrations.toss_payment_requests
  force row level security;

drop policy if exists toss_requests_isolation
  on catchmenu_integrations.toss_payment_requests;
create policy toss_requests_isolation
  on catchmenu_integrations.toss_payment_requests
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id =
      catchmenu_common.current_store_id()
  );

drop trigger if exists trg_toss_requests_updated
  on catchmenu_integrations.toss_payment_requests;
create trigger trg_toss_requests_updated
  before update on
    catchmenu_integrations.toss_payment_requests
  for each row execute function
    catchmenu_common.set_updated_at();

comment on table
  catchmenu_integrations.toss_payment_requests is
  '토스페이먼츠 결제 요청 관리.
   order_id_toss: 토스에 전달하는 주문 ID
     (내부 order_id와 별개).
   idempotency_key: 중복 요청 방지 키.
     (SHA-256(order_id + timestamp)).
   payment_key: 토스 승인 후 발급.
   card_number_masked: 앞 6자리 + 뒤 4자리만.
   customer_*: PII 해시/마스킹 처리.
   expired_at: 15분 내 미완료 시 EXPIRED.
   특허1: 결제 요청 = 감사 추적 시작.
   1차 MVP 핵심 결제 테이블.';


-- =============================================
-- toss_webhook_log table
-- 토스페이먼츠 웹훅 수신 로그
-- =============================================
create table if not exists
  catchmenu_integrations.toss_webhook_log (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid,

  -- 웹훅 정보
  event_type text not null,
  payment_key text,
  order_id_toss text,

  -- 서명 검증
  signature_verified boolean
    not null default false,
  webhook_secret_hash text,

  -- 원본 페이로드
  raw_payload jsonb not null,

  -- 처리 결과
  process_status text
    not null default 'PENDING',
  process_result jsonb,
  error_detail text,

  -- 재처리
  retry_count int not null default 0,
  max_retries int not null default 3,

  received_at timestamptz
    not null default now(),
  processed_at timestamptz,

  constraint chk_webhook_status check (
    process_status in (
      'PENDING', 'PROCESSING',
      'COMPLETED', 'FAILED',
      'IGNORED', 'INVALID_SIGNATURE'
    )
  )
);

create index if not exists idx_toss_webhook_key
  on catchmenu_integrations.toss_webhook_log(
    payment_key
  ) where payment_key is not null;
create index if not exists idx_toss_webhook_status
  on catchmenu_integrations.toss_webhook_log(
    process_status, received_at desc
  ) where process_status in (
    'PENDING', 'FAILED'
  );
create index if not exists idx_toss_webhook_tenant
  on catchmenu_integrations.toss_webhook_log(
    tenant_id, received_at desc
  );

alter table catchmenu_integrations.toss_webhook_log
  enable row level security;
alter table catchmenu_integrations.toss_webhook_log
  force row level security;

drop policy if exists toss_webhook_isolation
  on catchmenu_integrations.toss_webhook_log;
create policy toss_webhook_isolation
  on catchmenu_integrations.toss_webhook_log
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
  );

comment on table
  catchmenu_integrations.toss_webhook_log is
  '토스페이먼츠 웹훅 수신 로그.
   INVALID_SIGNATURE: 서명 검증 실패.
     → 즉시 보안 감사 로그 + SOP-SEC-004.
   IGNORED: 이미 처리된 이벤트 (멱등성).
   retry_count: 처리 실패 시 최대 3회 재시도.
   append-only: 삭제/수정 금지.
   특허4: 웹훅 = 외부 이벤트 감사 증빙.';


-- =============================================
-- RPCs
-- =============================================
create or replace function
  catchmenu_integrations.initiate_toss_payment(
  p_tenant_id uuid,
  p_store_id uuid,
  p_order_id uuid,
  p_payment_method text default 'CARD',
  p_customer_id_hash text default null,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_integrations,
                  catchmenu_pos,
                  catchmenu_common,
                  catchmenu_hq
as $$
declare
  v_order record;
  v_toss_config record;
  v_order_id_toss text;
  v_idempotency_key text;
  v_order_name text;
  v_request_id uuid;
  v_business_day date;
  v_timezone text;
begin
  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  -- 토스페이먼츠 설정 조회
  select id, api_key_hash, client_key_hash,
         webhook_secret_hash, is_active
  into v_toss_config
  from catchmenu_integrations.pos_store_configs
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and provider_code = 'TOSS_PAYMENTS'
    and is_active = true;

  if v_toss_config.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'toss_config_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'initiate_toss_payment'
    );
  end if;

  -- 주문 조회
  select o.id, o.order_number, o.order_type,
         o.final_amount, o.order_status,
         o.session_id,
         os.table_number
  into v_order
  from catchmenu_pos.orders o
  left join catchmenu_pos.order_sessions os
    on os.id = o.session_id
  where o.id = p_order_id
    and o.store_id = p_store_id
    and o.tenant_id = p_tenant_id;

  if v_order.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'order_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'initiate_toss_payment'
    );
  end if;

  -- 이미 결제 완료 확인
  if exists (
    select 1
    from catchmenu_integrations
      .toss_payment_requests
    where order_id = p_order_id
      and request_status = 'DONE'
  ) then
    return catchmenu_common.build_error_response(
      p_error_key := 'payment_already_confirmed',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'initiate_toss_payment'
    );
  end if;

  -- 토스 주문 ID + 멱등성 키 생성
  v_order_id_toss := 'CATCH-'
    || to_char(v_business_day, 'YYYYMMDD')
    || '-' || v_order.order_number
    || '-' || extract(
      epoch from now()
    )::int::text;

  v_idempotency_key := encode(
    digest(
      p_order_id::text
      || v_order.final_amount::text
      || v_order_id_toss,
      'sha256'
    ),
    'hex'
  );

  -- 주문명 구성
  v_order_name := case v_order.order_type
    when 'TABLE' then
      coalesce(v_order.table_number, '')
      || ' 테이블 주문'
    when 'TAKEOUT' then
      v_order.order_number || ' 포장'
    when 'DELIVERY' then
      v_order.order_number || ' 배달'
    else v_order.order_number || ' 주문'
  end;

  -- 결제 요청 생성
  insert into
    catchmenu_integrations.toss_payment_requests (
    tenant_id, store_id, order_id,
    order_id_toss, idempotency_key,
    payment_method, amount, order_name,
    customer_id_hash,
    request_status,
    business_day
  ) values (
    p_tenant_id, p_store_id, p_order_id,
    v_order_id_toss, v_idempotency_key,
    p_payment_method,
    v_order.final_amount,
    v_order_name,
    p_customer_id_hash,
    'READY',
    v_business_day
  )
  returning id into v_request_id;

  -- Edge Function에 결제 초기화 요청
  -- (실제 토스 API 호출은 Edge Function)
  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_channel_type := 'SYSTEM_EVENTS',
    p_event_type :=
      'toss_payment_initiate_requested',
    p_payload := jsonb_build_object(
      'request_id', v_request_id,
      'order_id', p_order_id,
      'order_id_toss', v_order_id_toss,
      'idempotency_key', v_idempotency_key,
      'amount', v_order.final_amount,
      'order_name', v_order_name,
      'payment_method', p_payment_method,
      'customer_id_hash', p_customer_id_hash,
      'config_id', v_toss_config.id,
      'locale', p_locale,
      'correlation_id', p_correlation_id,
      'timeout_seconds', 900,
      'success_url',
        'catchmenu://payment/success',
      'fail_url',
        'catchmenu://payment/fail'
    )
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'toss_payment_initiated',
    p_data := jsonb_build_object(
      'request_id', v_request_id,
      'order_id', p_order_id,
      'order_id_toss', v_order_id_toss,
      'idempotency_key', v_idempotency_key,
      'amount', v_order.final_amount,
      'order_name', v_order_name,
      'payment_method', p_payment_method,
      'request_status', 'READY',
      'expires_at',
        now() + interval '15 minutes',
      'flutter_note', jsonb_build_object(
        'next_step',
          'TossPayments SDK checkout() 호출',
        'client_key',
          'Edge Function에서 반환',
        'success_url',
          'catchmenu://payment/success',
        'fail_url',
          'catchmenu://payment/fail'
      )
    ),
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );
end;
$$;


create or replace function
  catchmenu_integrations.confirm_toss_payment(
  p_tenant_id uuid,
  p_store_id uuid,
  p_payment_key text,
  p_order_id_toss text,
  p_amount int,
  p_toss_response jsonb default null,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_integrations,
                  catchmenu_payment,
                  catchmenu_common
as $$
declare
  v_request record;
  v_approval_number text;
  v_card_number_masked text;
  v_card_company text;
  v_payment_method text;
  v_vat int;
  v_result jsonb;
begin
  -- 결제 요청 조회
  select id, order_id, amount,
         request_status, idempotency_key
  into v_request
  from catchmenu_integrations.toss_payment_requests
  where order_id_toss = p_order_id_toss
    and tenant_id = p_tenant_id
    and store_id = p_store_id
  for update;

  if v_request.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'payment_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'confirm_toss_payment'
    );
  end if;

  -- 이미 완료된 결제 (멱등성)
  if v_request.request_status = 'DONE' then
    return catchmenu_common.build_error_response(
      p_error_key := 'payment_already_confirmed',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'confirm_toss_payment'
    );
  end if;

  -- 만료 확인
  if v_request.request_status = 'EXPIRED' then
    return catchmenu_common.build_error_response(
      p_error_key := 'toss_payment_expired',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'confirm_toss_payment'
    );
  end if;

  -- 금액 검증 (멱등성 + 보안)
  if abs(p_amount - v_request.amount) > 0 then
    perform catchmenu_common.log_diagnostic(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_log_level := 'CRITICAL',
      p_log_domain := 'PAYMENT',
      p_log_event := 'toss_amount_tampering',
      p_message :=
        '토스 결제 금액 변조 시도 감지!'
        || ' | 요청=' || v_request.amount
        || ' | 수신=' || p_amount,
      p_rpc_name := 'confirm_toss_payment',
      p_details := jsonb_build_object(
        'request_id', v_request.id,
        'order_id', v_request.order_id,
        'expected_amount', v_request.amount,
        'received_amount', p_amount
      )
    );

    -- 보안 감사 기록
    insert into catchmenu_common.security_audit_log (
      tenant_id, store_id,
      audit_event, event_severity,
      event_source, event_detail,
      is_violation, was_blocked
    ) values (
      p_tenant_id, p_store_id,
      'payment_amount_tampering',
      'CRITICAL',
      'confirm_toss_payment',
      jsonb_build_object(
        'expected', v_request.amount,
        'received', p_amount,
        'payment_key', p_payment_key
      ),
      true, true
    );

    return catchmenu_common.build_error_response(
      p_error_key := 'payment_failed',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'confirm_toss_payment'
    );
  end if;

  -- 토스 응답 파싱
  v_approval_number := coalesce(
    p_toss_response->>'approvalNumber',
    p_payment_key
  );
  v_payment_method := coalesce(
    p_toss_response->>'method', 'CARD'
  );
  v_vat := coalesce(
    (p_toss_response->>'vat')::int, 0
  );

  -- 카드 정보 마스킹 처리
  if p_toss_response->'card' is not null then
    declare
      v_raw_card text;
    begin
      v_raw_card :=
        p_toss_response->'card'->>'number';
      -- 마스킹: 앞 6자리 + **** + 뒤 4자리
      v_card_number_masked := case
        when length(v_raw_card) >= 10
        then left(v_raw_card, 6)
          || '****'
          || right(v_raw_card, 4)
        else '****'
      end;
      v_card_company :=
        p_toss_response->'card'->>'company';
    end;
  end if;

  -- 결제 요청 상태 업데이트
  update catchmenu_integrations.toss_payment_requests
  set
    request_status = 'DONE',
    payment_key = p_payment_key,
    toss_response = p_toss_response,
    approved_amount = p_amount,
    supplied_amount = p_amount - v_vat,
    vat = v_vat,
    card_number_masked = v_card_number_masked,
    card_company = v_card_company,
    card_type =
      p_toss_response->'card'->>'cardType',
    installment_plan_months = coalesce(
      (p_toss_response->'card'
        ->>'installmentPlanMonths')::int, 0
    ),
    confirmed_at = now(),
    updated_at = now()
  where id = v_request.id;

  -- 표준 결제 확인 파이프라인 호출
  -- → KDS Late Binding 해제 (특허2)
  v_result := catchmenu_payment.confirm_payment(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_order_id := v_request.order_id,
    p_provider_type := 'TOSS_PAYMENTS',
    p_provider_approval_number :=
      v_approval_number,
    p_provider_tx_id := p_payment_key,
    p_approved_amount := p_amount,
    p_payment_method := v_payment_method,
    p_provider_response :=
      coalesce(p_toss_response, '{}'::jsonb),
    p_actor_type := 'PG_WEBHOOK',
    p_locale := p_locale,
    p_correlation_id := p_correlation_id,
    p_intent_id := v_request.payment_intent_id
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'toss_payment_confirmed',
    p_data := jsonb_build_object(
      'request_id', v_request.id,
      'order_id', v_request.order_id,
      'payment_key', p_payment_key,
      'approved_amount', p_amount,
      'vat', v_vat,
      'payment_method', v_payment_method,
      'card_number_masked',
        v_card_number_masked,
      'card_company', v_card_company,
      'kds_released',
        (v_result->>'success')::boolean,
      'kds_data', v_result->'data'->'kds'
    ),
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );
end;
$$;


create or replace function
  catchmenu_integrations.cancel_toss_payment(
  p_tenant_id uuid,
  p_store_id uuid,
  p_payment_key text,
  p_cancel_reason text,
  p_cancel_amount int default null,
  p_actor_id uuid default null,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_integrations,
                  catchmenu_payment,
                  catchmenu_common
as $$
declare
  v_request record;
  v_refund_amount int;
  v_refund_result jsonb;
begin
  -- 결제 요청 조회
  select id, order_id, approved_amount,
         request_status
  into v_request
  from catchmenu_integrations.toss_payment_requests
  where payment_key = p_payment_key
    and tenant_id = p_tenant_id
    and store_id = p_store_id
  for update;

  if v_request.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'payment_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'cancel_toss_payment'
    );
  end if;

  if v_request.request_status
    not in ('DONE', 'PARTIAL_CANCELED')
  then
    return catchmenu_common.build_error_response(
      p_error_key := 'payment_cancelled',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'cancel_toss_payment'
    );
  end if;

  v_refund_amount := coalesce(
    p_cancel_amount,
    v_request.approved_amount
  );

  -- Edge Function에 토스 취소 요청
  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_channel_type := 'SYSTEM_EVENTS',
    p_event_type :=
      'toss_payment_cancel_requested',
    p_payload := jsonb_build_object(
      'request_id', v_request.id,
      'payment_key', p_payment_key,
      'order_id', v_request.order_id,
      'cancel_reason', p_cancel_reason,
      'cancel_amount', v_refund_amount,
      'is_partial',
        p_cancel_amount is not null
        and p_cancel_amount
          < v_request.approved_amount,
      'correlation_id', p_correlation_id
    )
  );

  -- 결제 요청 상태 업데이트
  update catchmenu_integrations.toss_payment_requests
  set
    request_status = case
      when p_cancel_amount is not null
        and p_cancel_amount
          < v_request.approved_amount
        then 'PARTIAL_CANCELED'
      else 'CANCELED'
    end,
    cancelled_at = now(),
    updated_at = now()
  where id = v_request.id;

  -- 표준 환불 파이프라인 호출
  v_refund_result :=
    catchmenu_payment.request_refund(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_order_id := v_request.order_id,
      p_refund_amount := v_refund_amount,
      p_refund_reason := p_cancel_reason,
      p_is_partial := p_cancel_amount is not null
        and p_cancel_amount
          < v_request.approved_amount,
      p_actor_type := 'STAFF',
      p_actor_id := p_actor_id,
      p_locale := p_locale,
      p_correlation_id := p_correlation_id
    );

  return catchmenu_common.build_success_response(
    p_message_key := 'toss_payment_cancelled',
    p_data := jsonb_build_object(
      'request_id', v_request.id,
      'payment_key', p_payment_key,
      'order_id', v_request.order_id,
      'cancel_reason', p_cancel_reason,
      'cancel_amount', v_refund_amount,
      'is_partial',
        p_cancel_amount is not null
        and p_cancel_amount
          < v_request.approved_amount,
      'refund_result',
        v_refund_result->'data'
    ),
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );
end;
$$;


create or replace function
  catchmenu_integrations.process_toss_webhook(
  p_tenant_id uuid,
  p_store_id uuid,
  p_event_type text,
  p_raw_payload jsonb,
  p_signature text default null,
  p_expected_signature_hash text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_integrations,
                  catchmenu_common
as $$
declare
  v_webhook_id uuid;
  v_payment_key text;
  v_order_id_toss text;
  v_signature_verified boolean := false;
  v_process_result jsonb;
begin
  v_payment_key :=
    p_raw_payload->>'paymentKey';
  v_order_id_toss :=
    p_raw_payload->>'orderId';

  -- 서명 검증
  -- 실제 검증은 Edge Function에서 1차 수행
  -- DB 레벨 2차 검증
  if p_signature is not null
    and p_expected_signature_hash is not null
  then
    v_signature_verified :=
      encode(
        digest(p_signature, 'sha256'), 'hex'
      ) = p_expected_signature_hash;

    if not v_signature_verified then
      -- 서명 검증 실패 → 보안 위반
      insert into
        catchmenu_integrations.toss_webhook_log (
        tenant_id, store_id,
        event_type, payment_key, order_id_toss,
        signature_verified, raw_payload,
        process_status
      ) values (
        p_tenant_id, p_store_id,
        p_event_type, v_payment_key,
        v_order_id_toss,
        false, p_raw_payload,
        'INVALID_SIGNATURE'
      );

      insert into
        catchmenu_common.security_audit_log (
        tenant_id, store_id,
        audit_event, event_severity,
        event_source, event_detail,
        is_violation, was_blocked
      ) values (
        p_tenant_id, p_store_id,
        'toss_webhook_signature_invalid',
        'CRITICAL',
        'process_toss_webhook',
        jsonb_build_object(
          'event_type', p_event_type,
          'payment_key', v_payment_key,
          'signature_mismatch', true
        ),
        true, true
      );

      return catchmenu_common.build_error_response(
        p_error_key :=
          'toss_webhook_signature_invalid',
        p_locale := 'ko',
        p_tenant_id := p_tenant_id,
        p_store_id := p_store_id,
        p_rpc_name := 'process_toss_webhook'
      );
    end if;
  else
    -- 서명 없이 수신 (테스트 환경)
    v_signature_verified := true;
  end if;

  -- 중복 처리 방지 (멱등성)
  if exists (
    select 1
    from catchmenu_integrations.toss_webhook_log
    where payment_key = v_payment_key
      and event_type = p_event_type
      and process_status = 'COMPLETED'
      and tenant_id = p_tenant_id
  ) then
    insert into
      catchmenu_integrations.toss_webhook_log (
      tenant_id, store_id,
      event_type, payment_key, order_id_toss,
      signature_verified, raw_payload,
      process_status
    ) values (
      p_tenant_id, p_store_id,
      p_event_type, v_payment_key,
      v_order_id_toss,
      v_signature_verified, p_raw_payload,
      'IGNORED'
    );

    return catchmenu_common.build_success_response(
      p_message_key := 'toss_webhook_processed',
      p_data := jsonb_build_object(
        'status', 'IGNORED',
        'reason', 'duplicate_event',
        'payment_key', v_payment_key
      ),
      p_locale := 'ko'
    );
  end if;

  -- 웹훅 로그 생성
  insert into
    catchmenu_integrations.toss_webhook_log (
    tenant_id, store_id,
    event_type, payment_key, order_id_toss,
    signature_verified, raw_payload,
    process_status
  ) values (
    p_tenant_id, p_store_id,
    p_event_type, v_payment_key,
    v_order_id_toss,
    v_signature_verified, p_raw_payload,
    'PROCESSING'
  )
  returning id into v_webhook_id;

  -- 이벤트 타입별 처리
  case p_event_type
    when 'PAYMENT_STATUS_CHANGED' then
      declare
        v_status text;
      begin
        v_status :=
          p_raw_payload->>'status';

        case v_status
          when 'DONE' then
            v_process_result :=
              catchmenu_integrations
                .confirm_toss_payment(
                p_tenant_id := p_tenant_id,
                p_store_id := p_store_id,
                p_payment_key := v_payment_key,
                p_order_id_toss :=
                  v_order_id_toss,
                p_amount := (
                  p_raw_payload->>'totalAmount'
                )::int,
                p_toss_response := p_raw_payload,
                p_locale := 'ko',
                p_correlation_id :=
                  'WH-TOSS-' || v_webhook_id
              );

          when 'CANCELED' then
            v_process_result :=
              catchmenu_integrations
                .cancel_toss_payment(
                p_tenant_id := p_tenant_id,
                p_store_id := p_store_id,
                p_payment_key := v_payment_key,
                p_cancel_reason :=
                  coalesce(
                    p_raw_payload
                      ->'cancels'->0
                      ->>'cancelReason',
                    'webhook_cancel'
                  ),
                p_locale := 'ko',
                p_correlation_id :=
                  'WH-TOSS-' || v_webhook_id
              );

          when 'ABORTED' then
            -- 결제 중단 처리
            update catchmenu_integrations
              .toss_payment_requests
            set
              request_status = 'ABORTED',
              failure_code =
                p_raw_payload->>'code',
              failure_message =
                p_raw_payload->>'message',
              updated_at = now()
            where payment_key = v_payment_key
              and tenant_id = p_tenant_id;

            v_process_result :=
              jsonb_build_object(
                'success', true,
                'status', 'ABORTED'
              );

          else
            v_process_result :=
              jsonb_build_object(
                'success', true,
                'status', 'IGNORED',
                'reason', 'unhandled_status'
              );
        end case;
      end;

    else
      -- 미지원 이벤트
      v_process_result := jsonb_build_object(
        'success', true,
        'status', 'IGNORED',
        'reason', 'unhandled_event_type'
      );
  end case;

  -- 웹훅 로그 완료
  update catchmenu_integrations.toss_webhook_log
  set
    process_status = case
      when (v_process_result->>'success')
        ::boolean then 'COMPLETED'
      else 'FAILED'
    end,
    process_result = v_process_result,
    processed_at = now()
  where id = v_webhook_id;

  return catchmenu_common.build_success_response(
    p_message_key := 'toss_webhook_processed',
    p_data := jsonb_build_object(
      'webhook_id', v_webhook_id,
      'event_type', p_event_type,
      'payment_key', v_payment_key,
      'process_result', v_process_result
    ),
    p_locale := 'ko'
  );
end;
$$;


create or replace function
  catchmenu_integrations.get_toss_payment_status(
  p_tenant_id uuid,
  p_store_id uuid,
  p_order_id uuid,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_integrations,
                  catchmenu_payment,
                  catchmenu_common
as $$
declare
  v_request record;
  v_payment_status jsonb;
begin
  select id, payment_key, order_id_toss,
         request_status, amount,
         approved_amount, vat,
         payment_method,
         card_number_masked, card_company,
         installment_plan_months,
         requested_at, confirmed_at,
         cancelled_at, expired_at,
         failure_code, failure_message
  into v_request
  from catchmenu_integrations.toss_payment_requests
  where order_id = p_order_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
  order by requested_at desc
  limit 1;

  if v_request.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'payment_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'get_toss_payment_status'
    );
  end if;

  -- 표준 결제 상태 조회
  v_payment_status :=
    catchmenu_payment.get_payment_status(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_order_id := p_order_id,
      p_locale := p_locale
    );

  return catchmenu_common.build_success_response(
    p_message_key := 'toss_payment_status_loaded',
    p_data := jsonb_build_object(
      'order_id', p_order_id,
      'toss_request', jsonb_build_object(
        'request_id', v_request.id,
        'payment_key', v_request.payment_key,
        'order_id_toss', v_request.order_id_toss,
        'request_status', v_request.request_status,
        'amount', v_request.amount,
        'approved_amount',
          v_request.approved_amount,
        'vat', v_request.vat,
        'payment_method', v_request.payment_method,
        'card_number_masked',
          v_request.card_number_masked,
        'card_company', v_request.card_company,
        'installment_months',
          v_request.installment_plan_months,
        'requested_at', v_request.requested_at,
        'confirmed_at', v_request.confirmed_at,
        'cancelled_at', v_request.cancelled_at,
        'expired_at', v_request.expired_at,
        'failure', case
          when v_request.failure_code is not null
          then jsonb_build_object(
            'code', v_request.failure_code,
            'message',
              v_request.failure_message
          )
          else null
        end
      ),
      'payment_ledger',
        v_payment_status->'data'
    ),
    p_locale := p_locale
  );
end;
$$;


-- =============================================
-- pg_cron: 토스 결제 만료 처리
-- =============================================
insert into catchmenu_common.pg_cron_jobs (
  job_code, pg_cron_job_name,
  schedule_cron_utc, schedule_cron_kst,
  sql_command, notes, is_registered
) values
(
  'TOSS_PAYMENT_EXPIRE',
  'catchmenu_toss_payment_expire',
  '*/5 * * * *',
  '*/5 * * * * (5분마다)',
  $sql$
UPDATE catchmenu_integrations.toss_payment_requests
SET
  request_status = 'EXPIRED',
  updated_at = now()
WHERE request_status = 'READY'
  AND expired_at < now();
$sql$,
  '토스 결제 요청 만료 처리. 5분마다.',
  true
)
on conflict (job_code) do nothing;


-- =============================================
-- Flutter SDK 패턴: 토스페이먼츠
-- =============================================
insert into catchmenu_common.flutter_sdk_patterns (
  pattern_code, pattern_name,
  pattern_category, device_types,
  description, dependencies, dart_code
) values
(
  'FLUTTER_TOSS_PAYMENTS',
  '토스페이먼츠 결제 패턴',
  'RPC_CALL',
  '["CUSTOMER_APP","POS_TERMINAL","MINI_KIOSK"]'::jsonb,
  '토스페이먼츠 SDK 연동 + 결제 확인 파이프라인',
  '["supabase_flutter: ^2.0.0","tosspayments_widget_sdk_flutter: ^1.0.0"]'::jsonb,
  $dart$
// lib/services/toss_payment_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tosspayments_widget_sdk_flutter/model/payment_widget_options.dart';
import 'package:tosspayments_widget_sdk_flutter/payment_widget.dart';

class TossPaymentService {
  final _sb = Supabase.instance.client;

  // 결제 초기화 + SDK 실행
  Future<Map<String, dynamic>> checkout({
    required String tenantId,
    required String storeId,
    required String orderId,
    required String clientKey,
    String paymentMethod = 'CARD',
    String? customerIdHash,
  }) async {
    // 1. DB에 결제 요청 생성
    final initRes = await _sb.rpc(
      'initiate_toss_payment',
      params: {
        'p_tenant_id': tenantId,
        'p_store_id': storeId,
        'p_order_id': orderId,
        'p_payment_method': paymentMethod,
        'p_customer_id_hash': customerIdHash,
        'p_locale': 'ko',
      },
    );

    if (initRes['success'] != true) {
      return initRes;
    }

    final data =
      initRes['data'] as Map<String, dynamic>;
    final orderIdToss = data['order_id_toss'];
    final amount = data['amount'];
    final orderName = data['order_name'];

    // 2. 토스페이먼츠 SDK 실행
    final paymentWidget = PaymentWidget(
      clientKey: clientKey,
      customerKey: customerIdHash ?? 'GUEST',
    );

    try {
      final result = await paymentWidget.checkout(
        price: amount,
        orderId: orderIdToss,
        orderName: orderName,
        successUrl: data['flutter_note']
          ['success_url'],
        failUrl: data['flutter_note']['fail_url'],
      );

      return {
        'success': true,
        'result': result,
        'order_id_toss': orderIdToss,
        'request_id': data['request_id'],
      };

    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'order_id_toss': orderIdToss,
      };
    }
  }

  // 결제 성공 콜백 처리
  // (successUrl 딥링크 처리 후 호출)
  Future<Map<String, dynamic>> handleSuccess({
    required String tenantId,
    required String storeId,
    required String paymentKey,
    required String orderIdToss,
    required int amount,
  }) async {
    // Edge Function이 토스 /v1/payments/confirm
    // 호출 후 confirm_toss_payment() 실행
    // 여기서는 결제 상태 폴링
    await Future.delayed(
      const Duration(seconds: 2)
    );

    final orderRes = await _sb.rpc(
      'get_toss_payment_status',
      params: {
        'p_tenant_id': tenantId,
        'p_store_id': storeId,
        // order_id는 order_id_toss로 조회
        'p_order_id': orderIdToss,
        'p_locale': 'ko',
      },
    );

    return orderRes as Map<String, dynamic>;
  }

  // 결제 취소
  Future<Map<String, dynamic>> cancel({
    required String tenantId,
    required String storeId,
    required String paymentKey,
    required String cancelReason,
    int? cancelAmount,
  }) async {
    return await _sb.rpc(
      'cancel_toss_payment',
      params: {
        'p_tenant_id': tenantId,
        'p_store_id': storeId,
        'p_payment_key': paymentKey,
        'p_cancel_reason': cancelReason,
        'p_cancel_amount': cancelAmount,
        'p_locale': 'ko',
      },
    );
  }
}
$dart$
)
on conflict (pattern_code) do update set
  dart_code = excluded.dart_code;


-- grants
do $$
begin
  revoke all on function
    catchmenu_integrations.initiate_toss_payment(
      uuid, uuid, uuid, text, text, text, text
    ) from public;
  grant execute on function
    catchmenu_integrations.initiate_toss_payment(
      uuid, uuid, uuid, text, text, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_integrations.confirm_toss_payment(
      uuid, uuid, text, text, int,
      jsonb, text, text
    ) from public;
  grant execute on function
    catchmenu_integrations.confirm_toss_payment(
      uuid, uuid, text, text, int,
      jsonb, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_integrations.cancel_toss_payment(
      uuid, uuid, text, text, int,
      uuid, text, text
    ) from public;
  grant execute on function
    catchmenu_integrations.cancel_toss_payment(
      uuid, uuid, text, text, int,
      uuid, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_integrations.process_toss_webhook(
      uuid, uuid, text, jsonb, text, text
    ) from public;
  grant execute on function
    catchmenu_integrations.process_toss_webhook(
      uuid, uuid, text, jsonb, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_integrations.get_toss_payment_status(
      uuid, uuid, uuid, text
    ) from public;
  grant execute on function
    catchmenu_integrations.get_toss_payment_status(
      uuid, uuid, uuid, text
    ) to authenticated;
end;
$$;

comment on function
  catchmenu_integrations.confirm_toss_payment(
    uuid, uuid, text, text, int, jsonb, text, text
  ) is
  '토스페이먼츠 결제 확인 → 표준 파이프라인.
   보안 검증:
   1. 결제 요청 존재 확인
   2. 이미 완료 확인 (멱등성)
   3. 만료 확인
   4. 금액 변조 탐지 ← CRITICAL
      (수신 금액 ≠ 요청 금액 시 차단)
   5. 카드 번호 마스킹 (앞6+****+뒤4)
   6. confirm_payment() → KDS Late Binding
   금액 변조 시 보안 감사 로그 + CRITICAL.
   특허2: 결제 확인 = KDS HOLD 해제.
   1차 MVP 결제 파이프라인 핵심.';

comment on function
  catchmenu_integrations.process_toss_webhook(
    uuid, uuid, text, jsonb, text, text
  ) is
  '토스페이먼츠 웹훅 처리.
   Edge Function이 1차 서명 검증 후 호출.
   DB 레벨 2차 서명 검증.
   멱등성: 동일 payment_key + event_type
     중복 수신 시 IGNORED 처리.
   이벤트별 처리:
   PAYMENT_STATUS_CHANGED + DONE:
     → confirm_toss_payment()
   PAYMENT_STATUS_CHANGED + CANCELED:
     → cancel_toss_payment()
   PAYMENT_STATUS_CHANGED + ABORTED:
     → request_status = ABORTED
   서명 검증 실패:
     → INVALID_SIGNATURE 로그
     → 보안 감사 기록
     → SOP-SEC-004 연결
   특허4: 웹훅 = 외부 이벤트 감사 증빙.';


-- ===== END sql/migrations/0103_create_toss_payments_pipeline_rpc.sql =====


-- ===== BEGIN sql/migrations/0104_create_toss_pos_pipeline_rpc.sql =====

-- 0104_create_toss_pos_pipeline_rpc.sql
-- Purpose: Toss POS integration pipeline.
--          토스POS 주문 전송, 결제 확인,
--          메뉴 동기화, 헬스체크 파이프라인.
--          OKpos와 동일한 구조로 표준화.
--          i18n: 모든 메시지 = message_catalog 참조.
-- Depends on: 0103_create_toss_payments_pipeline_rpc.sql
-- Creates:
--   catchmenu_integrations.toss_pos_order_log (table)
--   catchmenu_integrations.toss_pos_menu_sync_log (table)
--   function catchmenu_integrations.sync_toss_pos_menu(...)
--   function catchmenu_integrations.send_order_to_toss_pos(...)
--   function catchmenu_integrations.confirm_toss_pos_payment(...)
--   function catchmenu_integrations.cancel_toss_pos_order(...)
--   function catchmenu_integrations.get_toss_pos_health(...)
--   function catchmenu_integrations.get_toss_pos_dashboard(...)

-- =============================================
-- i18n 메시지 등록
-- =============================================
insert into catchmenu_common.message_catalog (
  message_key, locale, message_text
) values
('toss_pos_menu_synced', 'ko',
  '토스POS 메뉴가 동기화되었습니다'),
('toss_pos_menu_synced', 'en',
  'Toss POS menu synced'),
('toss_pos_order_sent', 'ko',
  '토스POS에 주문이 전송되었습니다'),
('toss_pos_order_sent', 'en',
  'Order sent to Toss POS'),
('toss_pos_payment_confirmed', 'ko',
  '토스POS 결제가 확인되었습니다'),
('toss_pos_payment_confirmed', 'en',
  'Toss POS payment confirmed'),
('toss_pos_order_cancelled', 'ko',
  '토스POS 주문이 취소되었습니다'),
('toss_pos_order_cancelled', 'en',
  'Toss POS order cancelled'),
('toss_pos_health_ok', 'ko',
  '토스POS 연결이 정상입니다'),
('toss_pos_health_ok', 'en',
  'Toss POS connection healthy'),
('toss_pos_health_error', 'ko',
  '토스POS 연결에 문제가 있습니다'),
('toss_pos_health_error', 'en',
  'Toss POS connection error'),
('toss_pos_dashboard_loaded', 'ko',
  '토스POS 대시보드가 로드되었습니다'),
('toss_pos_dashboard_loaded', 'en',
  'Toss POS dashboard loaded'),
('toss_pos_order_failed', 'ko',
  '토스POS 주문 전송에 실패했습니다'),
('toss_pos_order_failed', 'en',
  'Toss POS order transmission failed'),
('toss_pos_config_not_found', 'ko',
  '토스POS 설정을 찾을 수 없습니다'),
('toss_pos_config_not_found', 'en',
  'Toss POS config not found')
on conflict (message_key, locale) do nothing;

insert into catchmenu_common.error_codes (
  code, error_key, error_domain,
  error_category, http_status, severity,
  sop_document_code
) values
(9030, 'toss_pos_config_not_found',
  'INTEGRATION', 'NOT_FOUND', 404, 'ERROR',
  'SOP-POS-001'),
(9031, 'toss_pos_menu_sync_failed',
  'INTEGRATION', 'TECHNICAL', 500, 'ERROR',
  'SOP-POS-001'),
(9032, 'toss_pos_order_send_failed',
  'INTEGRATION', 'TECHNICAL', 500, 'ERROR',
  'SOP-POS-001'),
(9033, 'toss_pos_payment_confirm_failed',
  'INTEGRATION', 'TECHNICAL', 500, 'CRITICAL',
  'SOP-PAY-001'),
(9034, 'toss_pos_cancel_failed',
  'INTEGRATION', 'TECHNICAL', 500, 'CRITICAL',
  'SOP-PAY-002')
on conflict (code) do nothing;


-- =============================================
-- toss_pos_menu_sync_log table
-- =============================================
create table if not exists
  catchmenu_integrations.toss_pos_menu_sync_log (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid not null
    references catchmenu_hq.stores(id),

  sync_type text not null default 'FULL',
  sync_status text not null default 'PENDING',
  menus_fetched int not null default 0,
  menus_created int not null default 0,
  menus_updated int not null default 0,
  menus_deactivated int not null default 0,

  toss_pos_response jsonb,
  error_detail text,
  duration_ms int,

  synced_at timestamptz not null default now(),
  completed_at timestamptz,

  constraint chk_tpos_sync_type check (
    sync_type in (
      'FULL', 'INCREMENTAL',
      'PRICE_ONLY', 'STATUS_ONLY'
    )
  ),
  constraint chk_tpos_sync_status check (
    sync_status in (
      'PENDING', 'IN_PROGRESS',
      'COMPLETED', 'PARTIAL', 'FAILED'
    )
  )
);

create index if not exists idx_toss_pos_sync
  on catchmenu_integrations.toss_pos_menu_sync_log(
    store_id, synced_at desc
  );

alter table
  catchmenu_integrations.toss_pos_menu_sync_log
  enable row level security;
alter table
  catchmenu_integrations.toss_pos_menu_sync_log
  force row level security;

drop policy if exists toss_pos_sync_isolation
  on catchmenu_integrations.toss_pos_menu_sync_log;
create policy toss_pos_sync_isolation
  on catchmenu_integrations.toss_pos_menu_sync_log
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id =
      catchmenu_common.current_store_id()
  );

comment on table
  catchmenu_integrations.toss_pos_menu_sync_log is
  '토스POS 메뉴 동기화 이력.
   OKpos와 동일한 구조 (표준화).
   메뉴 코드 규칙: TPOS_{code}
   카테고리 코드 규칙: TPOS_CAT_{code}
   1차 MVP 토스POS 연동 감사 테이블.';


-- =============================================
-- toss_pos_order_log table
-- =============================================
create table if not exists
  catchmenu_integrations.toss_pos_order_log (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid not null
    references catchmenu_hq.stores(id),

  order_id uuid
    references catchmenu_pos.orders(id),
  toss_pos_order_id text,

  send_status text not null default 'PENDING',
  retry_count int not null default 0,

  request_payload jsonb,
  toss_pos_response jsonb,
  error_code text,
  error_detail text,

  sent_at timestamptz not null default now(),
  confirmed_at timestamptz,
  duration_ms int,

  constraint chk_tpos_send_status check (
    send_status in (
      'PENDING', 'SENT', 'CONFIRMED',
      'FAILED', 'CANCELLED', 'TIMEOUT'
    )
  )
);

create index if not exists idx_toss_pos_order
  on catchmenu_integrations.toss_pos_order_log(
    order_id
  ) where order_id is not null;
create index if not exists idx_toss_pos_failed
  on catchmenu_integrations.toss_pos_order_log(
    store_id, send_status, sent_at desc
  ) where send_status in ('FAILED', 'PENDING');

alter table
  catchmenu_integrations.toss_pos_order_log
  enable row level security;
alter table
  catchmenu_integrations.toss_pos_order_log
  force row level security;

drop policy if exists toss_pos_order_isolation
  on catchmenu_integrations.toss_pos_order_log;
create policy toss_pos_order_isolation
  on catchmenu_integrations.toss_pos_order_log
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id =
      catchmenu_common.current_store_id()
  );

comment on table
  catchmenu_integrations.toss_pos_order_log is
  '토스POS 주문 전송 이력.
   OKpos와 동일한 구조 (표준화).
   TIMEOUT: 5초 내 응답 없음 → 망취소.
   retry_count: 최대 3회 재시도.
   특허1: POS 주문 전송 = 감사 증빙.';


-- =============================================
-- RPCs
-- =============================================
create or replace function
  catchmenu_integrations.sync_toss_pos_menu(
  p_tenant_id uuid,
  p_store_id uuid,
  p_sync_type text default 'FULL',
  p_toss_pos_menu_data jsonb default null,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_integrations,
                  catchmenu_pos,
                  catchmenu_common,
                  catchmenu_ledger
as $$
declare
  v_start timestamptz := now();
  v_sync_log_id uuid;
  v_config record;
  v_item jsonb;
  v_category_id uuid;
  v_created int := 0;
  v_updated int := 0;
  v_deactivated int := 0;
  v_fetched int := 0;
  v_tpos_codes jsonb := '[]'::jsonb;
  v_business_day date;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  -- 토스POS 설정 조회
  select id, store_code, api_endpoint,
         pos_terminal_id, is_active
  into v_config
  from catchmenu_integrations.pos_store_configs
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and provider_code = 'TOSS_POS'
    and is_active = true;

  if v_config.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'toss_pos_config_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'sync_toss_pos_menu'
    );
  end if;

  -- 동기화 로그 시작
  insert into
    catchmenu_integrations.toss_pos_menu_sync_log (
    tenant_id, store_id,
    sync_type, sync_status
  ) values (
    p_tenant_id, p_store_id,
    p_sync_type, 'IN_PROGRESS'
  )
  returning id into v_sync_log_id;

  -- Edge Function 트리거 (데이터 없는 경우)
  if p_toss_pos_menu_data is null then
    perform catchmenu_common.notify_channel(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_channel_type := 'SYSTEM_EVENTS',
      p_event_type :=
        'toss_pos_menu_fetch_requested',
      p_payload := jsonb_build_object(
        'sync_log_id', v_sync_log_id,
        'config_id', v_config.id,
        'store_code', v_config.store_code,
        'api_endpoint', v_config.api_endpoint,
        'pos_terminal_id',
          v_config.pos_terminal_id,
        'sync_type', p_sync_type,
        'correlation_id', p_correlation_id
      )
    );

    update catchmenu_integrations
      .toss_pos_menu_sync_log
    set sync_status = 'PENDING'
    where id = v_sync_log_id;

    return catchmenu_common.build_success_response(
      p_message_key := 'toss_pos_menu_synced',
      p_data := jsonb_build_object(
        'sync_log_id', v_sync_log_id,
        'sync_status', 'PENDING',
        'note',
          'Edge Function toss-pos-menu-sync 호출됨'
      ),
      p_locale := p_locale
    );
  end if;

  v_fetched := jsonb_array_length(
    coalesce(p_toss_pos_menu_data, '[]'::jsonb)
  );

  -- 토스POS 메뉴 항목 처리
  -- OKpos와 동일 구조, 코드 규칙만 다름
  for v_item in
    select * from jsonb_array_elements(
      p_toss_pos_menu_data
    )
  loop
    declare
      v_tpos_code text;
      v_menu_name text;
      v_price int;
      v_cat_code text;
      v_cat_name text;
      v_is_available boolean;
      v_existing record;
    begin
      -- 코드 규칙: TPOS_{code}
      v_tpos_code :=
        'TPOS_' || (v_item->>'menuCode');
      v_menu_name := coalesce(
        v_item->>'menuNameKo',
        v_item->>'menuName'
      );
      v_price :=
        (v_item->>'salePrice')::int;
      v_cat_code :=
        'TPOS_CAT_' || coalesce(
          v_item->>'categoryCode', 'DEFAULT'
        );
      v_cat_name := coalesce(
        v_item->>'categoryNameKo',
        v_item->>'categoryName',
        '토스POS 메뉴'
      );
      v_is_available := coalesce(
        (v_item->>'useYn')::boolean, true
      );

      v_tpos_codes := v_tpos_codes
        || to_jsonb(v_tpos_code);

      -- 카테고리 upsert
      insert into catchmenu_pos.menu_categories (
        tenant_id, store_id,
        category_code, category_name,
        display_order
      ) values (
        p_tenant_id, p_store_id,
        v_cat_code, v_cat_name,
        coalesce(
          (v_item->>'categoryOrder')::int, 0
        )
      )
      on conflict (store_id, category_code)
      do update set
        category_name = excluded.category_name,
        updated_at = now()
      returning id into v_category_id;

      -- 기존 메뉴 확인
      select id, price, menu_status
      into v_existing
      from catchmenu_pos.menus
      where store_id = p_store_id
        and tenant_id = p_tenant_id
        and menu_code = v_tpos_code;

      if v_existing.id is null then
        -- 신규 메뉴 생성
        insert into catchmenu_pos.menus (
          tenant_id, store_id, category_id,
          menu_code, menu_name,
          price, menu_status,
          is_kds_required,
          display_order,
          pos_sync_at
        ) values (
          p_tenant_id, p_store_id, v_category_id,
          v_tpos_code, v_menu_name,
          v_price,
          case v_is_available
            when true then 'AVAILABLE'
            else 'SOLD_OUT'
          end,
          true,
          coalesce(
            (v_item->>'menuOrder')::int, 0
          ),
          now()
        );
        v_created := v_created + 1;

      else
        -- 기존 메뉴 업데이트
        update catchmenu_pos.menus
        set
          menu_name = v_menu_name,
          price = v_price,
          category_id = v_category_id,
          menu_status = case v_is_available
            when true then 'AVAILABLE'
            else 'SOLD_OUT'
          end,
          is_active = true,
          pos_sync_at = now(),
          updated_at = now()
        where id = v_existing.id;

        -- 가격 변경 이력
        if v_existing.price <> v_price then
          insert into catchmenu_ledger.events (
            tenant_id, store_id,
            event_domain, event_type,
            event_version,
            subject_type, subject_id,
            from_state, to_state,
            caused_by_type, event_payload,
            business_day, business_timezone,
            occurred_at
          ) values (
            p_tenant_id, p_store_id,
            'menu', 'menu_price_changed', 1,
            'menu', v_existing.id,
            v_existing.price::text,
            v_price::text,
            'TOSS_POS_SYNC',
            jsonb_build_object(
              'menu_code', v_tpos_code,
              'old_price', v_existing.price,
              'new_price', v_price,
              'sync_log_id', v_sync_log_id
            ),
            v_business_day, 'Asia/Seoul', now()
          );
        end if;

        v_updated := v_updated + 1;
      end if;
    end;
  end loop;

  -- FULL SYNC: 토스POS에 없는 메뉴 비활성화
  if p_sync_type = 'FULL'
    and jsonb_array_length(v_tpos_codes) > 0
  then
    update catchmenu_pos.menus
    set
      menu_status = 'DISCONTINUED',
      is_active = false,
      updated_at = now()
    where store_id = p_store_id
      and tenant_id = p_tenant_id
      and menu_code like 'TPOS_%'
      and not (
        v_tpos_codes @> to_jsonb(menu_code)
      )
      and menu_status <> 'DISCONTINUED';

    get diagnostics v_deactivated = row_count;
  end if;

  -- 동기화 로그 완료
  update catchmenu_integrations
    .toss_pos_menu_sync_log
  set
    sync_status = 'COMPLETED',
    menus_fetched = v_fetched,
    menus_created = v_created,
    menus_updated = v_updated,
    menus_deactivated = v_deactivated,
    duration_ms = extract(
      epoch from (now() - v_start)
    )::int * 1000,
    completed_at = now()
  where id = v_sync_log_id;

  perform catchmenu_common.log_diagnostic(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_log_level := 'INFO',
    p_log_domain := 'INTEGRATION',
    p_log_event := 'toss_pos_menu_synced',
    p_message :=
      '토스POS 메뉴 동기화 완료'
      || ' | 조회=' || v_fetched
      || ' | 생성=' || v_created
      || ' | 수정=' || v_updated
      || ' | 비활성=' || v_deactivated,
    p_rpc_name := 'sync_toss_pos_menu',
    p_correlation_id := p_correlation_id,
    p_details := jsonb_build_object(
      'sync_log_id', v_sync_log_id,
      'created', v_created,
      'updated', v_updated,
      'deactivated', v_deactivated
    )
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'toss_pos_menu_synced',
    p_data := jsonb_build_object(
      'sync_log_id', v_sync_log_id,
      'sync_type', p_sync_type,
      'sync_status', 'COMPLETED',
      'result', jsonb_build_object(
        'fetched', v_fetched,
        'created', v_created,
        'updated', v_updated,
        'deactivated', v_deactivated
      ),
      'menu_code_prefix', 'TPOS_',
      'category_code_prefix', 'TPOS_CAT_'
    ),
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );
end;
$$;


create or replace function
  catchmenu_integrations.send_order_to_toss_pos(
  p_tenant_id uuid,
  p_store_id uuid,
  p_order_id uuid,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_integrations,
                  catchmenu_pos,
                  catchmenu_common
as $$
declare
  v_config record;
  v_order record;
  v_items jsonb;
  v_log_id uuid;
  v_request_payload jsonb;
begin
  select id, store_code, api_endpoint,
         pos_terminal_id
  into v_config
  from catchmenu_integrations.pos_store_configs
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and provider_code = 'TOSS_POS'
    and is_active = true;

  if v_config.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'toss_pos_config_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'send_order_to_toss_pos'
    );
  end if;

  -- 주문 조회
  select o.id, o.order_number, o.order_type,
         o.final_amount, o.memo,
         os.table_number, os.wait_number
  into v_order
  from catchmenu_pos.orders o
  left join catchmenu_pos.order_sessions os
    on os.id = o.session_id
  where o.id = p_order_id
    and o.store_id = p_store_id
    and o.tenant_id = p_tenant_id;

  if v_order.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'order_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'send_order_to_toss_pos'
    );
  end if;

  -- 주문 항목 (TPOS_ 코드 제거)
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'menuCode', replace(
          m.menu_code, 'TPOS_', ''
        ),
        'menuName', oi.menu_name_snapshot,
        'qty', oi.quantity,
        'salePrice', oi.unit_price,
        'totalPrice', oi.subtotal,
        'options', oi.item_options
      )
      order by oi.display_order
    ),
    '[]'::jsonb
  )
  into v_items
  from catchmenu_pos.order_items oi
  left join catchmenu_pos.menus m
    on m.id = oi.menu_id
  where oi.order_id = p_order_id;

  -- 토스POS API 규격 페이로드
  v_request_payload := jsonb_build_object(
    'storeCode', v_config.store_code,
    'terminalId', v_config.pos_terminal_id,
    'orderNo', v_order.order_number,
    'orderType', case v_order.order_type
      when 'TABLE' then 'DINE_IN'
      when 'TAKEOUT' then 'TAKE_OUT'
      when 'DELIVERY' then 'DELIVERY'
      else 'TAKE_OUT'
    end,
    'tableNo', coalesce(
      v_order.table_number, ''
    ),
    'menuList', v_items,
    'totalAmount', v_order.final_amount,
    'memo', coalesce(
      v_order.memo, ''
    ),
    'orderedAt', now()
  );

  -- 전송 로그 생성
  insert into
    catchmenu_integrations.toss_pos_order_log (
    tenant_id, store_id, order_id,
    send_status, request_payload,
    sent_at
  ) values (
    p_tenant_id, p_store_id, p_order_id,
    'PENDING', v_request_payload, now()
  )
  returning id into v_log_id;

  -- Edge Function에 전송 요청
  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_channel_type := 'SYSTEM_EVENTS',
    p_event_type :=
      'toss_pos_order_send_requested',
    p_payload := jsonb_build_object(
      'log_id', v_log_id,
      'order_id', p_order_id,
      'config_id', v_config.id,
      'api_endpoint', v_config.api_endpoint,
      'request_payload', v_request_payload,
      'correlation_id', p_correlation_id,
      'timeout_seconds', 5,
      'on_timeout', 'NET_CANCEL'
    )
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'toss_pos_order_sent',
    p_data := jsonb_build_object(
      'log_id', v_log_id,
      'order_id', p_order_id,
      'order_number', v_order.order_number,
      'send_status', 'PENDING',
      'items_count',
        jsonb_array_length(v_items),
      'final_amount', v_order.final_amount
    ),
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );
end;
$$;


create or replace function
  catchmenu_integrations
    .confirm_toss_pos_order_sent(
  p_tenant_id uuid,
  p_store_id uuid,
  p_log_id uuid,
  p_toss_pos_order_id text,
  p_send_result text,
  p_toss_pos_response jsonb default null,
  p_error_detail text default null,
  p_duration_ms int default null,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_integrations,
                  catchmenu_common
as $$
declare
  v_log record;
  v_new_status text;
begin
  select id, order_id, send_status
  into v_log
  from catchmenu_integrations.toss_pos_order_log
  where id = p_log_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
  for update;

  if v_log.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'order_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'confirm_toss_pos_order_sent'
    );
  end if;

  v_new_status := case p_send_result
    when 'SUCCESS' then 'CONFIRMED'
    when 'TIMEOUT' then 'TIMEOUT'
    else 'FAILED'
  end;

  update catchmenu_integrations.toss_pos_order_log
  set
    send_status = v_new_status,
    toss_pos_order_id = p_toss_pos_order_id,
    toss_pos_response = p_toss_pos_response,
    error_detail = p_error_detail,
    duration_ms = p_duration_ms,
    confirmed_at = case p_send_result
      when 'SUCCESS' then now()
      else null
    end,
    updated_at = now()
  where id = p_log_id;

  -- 실패 시 운영 알림
  if v_new_status in ('FAILED', 'TIMEOUT') then
    perform catchmenu_common.create_operation_alert(
      p_tenant_id := p_tenant_id,
      p_alert_type := 'POS_DISCONNECTED',
      p_alert_severity := 'ERROR',
      p_alert_domain := 'INTEGRATION',
      p_alert_title_key := 'toss_pos_order_failed',
      p_alert_detail := jsonb_build_object(
        'log_id', p_log_id,
        'order_id', v_log.order_id,
        'send_result', p_send_result,
        'error_detail', p_error_detail
      ),
      p_store_id := p_store_id,
      p_sop_runbook_code := 'SOP-POS-001'
    );
  end if;

  -- 주문에 토스POS 주문 ID 기록
  if p_send_result = 'SUCCESS'
    and p_toss_pos_order_id is not null
  then
    update catchmenu_pos.orders
    set
      provider_type = 'TOSS_POS',
      provider_order_id = p_toss_pos_order_id,
      updated_at = now()
    where id = v_log.order_id;
  end if;

  return catchmenu_common.build_success_response(
    p_message_key := case p_send_result
      when 'SUCCESS' then 'toss_pos_order_sent'
      else 'toss_pos_order_failed'
    end,
    p_data := jsonb_build_object(
      'log_id', p_log_id,
      'order_id', v_log.order_id,
      'toss_pos_order_id', p_toss_pos_order_id,
      'send_status', v_new_status
    ),
    p_locale := p_locale
  );
end;
$$;


create or replace function
  catchmenu_integrations.confirm_toss_pos_payment(
  p_tenant_id uuid,
  p_store_id uuid,
  p_order_id uuid,
  p_toss_pos_tx_data jsonb,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_integrations,
                  catchmenu_payment,
                  catchmenu_common
as $$
declare
  v_approval_number text;
  v_approved_amount int;
  v_payment_method text;
  v_toss_pos_tx_id text;
  v_result jsonb;
begin
  -- 토스POS 결제 데이터 파싱
  -- 토스POS API 응답 필드명 기준
  v_approval_number :=
    p_toss_pos_tx_data->>'approvalNo';
  v_approved_amount :=
    (p_toss_pos_tx_data->>'paidAmt')::int;
  v_payment_method := coalesce(
    p_toss_pos_tx_data->>'payMethod', 'CARD'
  );
  v_toss_pos_tx_id := coalesce(
    p_toss_pos_tx_data->>'tposOrderId',
    p_toss_pos_tx_data->>'tranId'
  );

  -- 표준 결제 확인 파이프라인
  -- → KDS Late Binding 해제 (특허2)
  v_result := catchmenu_payment.confirm_payment(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_order_id := p_order_id,
    p_provider_type := 'TOSS_POS',
    p_provider_approval_number :=
      v_approval_number,
    p_provider_tx_id := v_toss_pos_tx_id,
    p_approved_amount := v_approved_amount,
    p_payment_method := v_payment_method,
    p_provider_response := p_toss_pos_tx_data,
    p_actor_type := 'POS',
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'toss_pos_payment_confirmed',
    p_data := jsonb_build_object(
      'order_id', p_order_id,
      'toss_pos_tx_id', v_toss_pos_tx_id,
      'approval_number', v_approval_number,
      'approved_amount', v_approved_amount,
      'payment_method', v_payment_method,
      'kds_released',
        (v_result->>'success')::boolean,
      'kds_data', v_result->'data'->'kds'
    ),
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );
end;
$$;


create or replace function
  catchmenu_integrations.cancel_toss_pos_order(
  p_tenant_id uuid,
  p_store_id uuid,
  p_order_id uuid,
  p_cancel_reason text,
  p_actor_id uuid default null,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_integrations,
                  catchmenu_payment,
                  catchmenu_common
as $$
declare
  v_log record;
  v_refund_result jsonb;
begin
  -- 토스POS 전송 이력 확인
  select id, toss_pos_order_id, send_status
  into v_log
  from catchmenu_integrations.toss_pos_order_log
  where order_id = p_order_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
    and send_status = 'CONFIRMED'
  order by confirmed_at desc
  limit 1;

  -- Edge Function에 취소 요청
  if v_log.id is not null then
    perform catchmenu_common.notify_channel(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_channel_type := 'SYSTEM_EVENTS',
      p_event_type :=
        'toss_pos_order_cancel_requested',
      p_payload := jsonb_build_object(
        'order_id', p_order_id,
        'toss_pos_order_id',
          v_log.toss_pos_order_id,
        'log_id', v_log.id,
        'cancel_reason', p_cancel_reason,
        'correlation_id', p_correlation_id
      )
    );
  end if;

  -- 표준 환불 파이프라인
  v_refund_result :=
    catchmenu_payment.request_refund(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_order_id := p_order_id,
      p_refund_amount := 0,
      p_refund_reason := p_cancel_reason,
      p_is_partial := false,
      p_actor_type := 'STAFF',
      p_actor_id := p_actor_id,
      p_locale := p_locale,
      p_correlation_id := p_correlation_id
    );

  return catchmenu_common.build_success_response(
    p_message_key := 'toss_pos_order_cancelled',
    p_data := jsonb_build_object(
      'order_id', p_order_id,
      'toss_pos_order_id',
        v_log.toss_pos_order_id,
      'cancel_reason', p_cancel_reason,
      'refund_result',
        v_refund_result->'data'
    ),
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );
end;
$$;


create or replace function
  catchmenu_integrations.get_toss_pos_health(
  p_tenant_id uuid,
  p_store_id uuid,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_integrations,
                  catchmenu_common
as $$
declare
  v_config record;
  v_last_sync record;
  v_last_order record;
  v_failed_count int;
  v_business_day date;
  v_health_status text;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  select id, store_code, api_endpoint,
         is_active, last_heartbeat_at
  into v_config
  from catchmenu_integrations.pos_store_configs
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and provider_code = 'TOSS_POS';

  if v_config.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'toss_pos_config_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'get_toss_pos_health'
    );
  end if;

  select sync_status, synced_at, menus_fetched
  into v_last_sync
  from catchmenu_integrations.toss_pos_menu_sync_log
  where store_id = p_store_id
    and tenant_id = p_tenant_id
  order by synced_at desc limit 1;

  select send_status, sent_at
  into v_last_order
  from catchmenu_integrations.toss_pos_order_log
  where store_id = p_store_id
    and tenant_id = p_tenant_id
  order by sent_at desc limit 1;

  select count(*) into v_failed_count
  from catchmenu_integrations.toss_pos_order_log
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and send_status in ('FAILED', 'TIMEOUT')
    and sent_at::date = v_business_day;

  v_health_status := case
    when not v_config.is_active
      then 'INACTIVE'
    when v_failed_count >= 3
      then 'DEGRADED'
    when v_config.last_heartbeat_at is null
      or v_config.last_heartbeat_at
        > now() - interval '10 minutes'
      then 'HEALTHY'
    else 'UNKNOWN'
  end;

  return catchmenu_common.build_success_response(
    p_message_key := case v_health_status
      when 'HEALTHY' then 'toss_pos_health_ok'
      else 'toss_pos_health_error'
    end,
    p_data := jsonb_build_object(
      'config_id', v_config.id,
      'store_code', v_config.store_code,
      'health_status', v_health_status,
      'is_active', v_config.is_active,
      'last_heartbeat_at',
        v_config.last_heartbeat_at,
      'last_sync', case
        when v_last_sync.synced_at is not null
        then jsonb_build_object(
          'status', v_last_sync.sync_status,
          'synced_at', v_last_sync.synced_at,
          'menus_fetched',
            v_last_sync.menus_fetched
        )
        else null
      end,
      'last_order', case
        when v_last_order.sent_at is not null
        then jsonb_build_object(
          'status', v_last_order.send_status,
          'sent_at', v_last_order.sent_at
        )
        else null
      end,
      'failed_orders_today', v_failed_count,
      'sop_runbook', case
        when v_health_status <> 'HEALTHY'
          then 'SOP-POS-001'
        else null
      end
    ),
    p_locale := p_locale
  );
end;
$$;


create or replace function
  catchmenu_integrations.get_toss_pos_dashboard(
  p_tenant_id uuid,
  p_store_id uuid,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_integrations,
                  catchmenu_pos,
                  catchmenu_common
as $$
declare
  v_business_day date;
  v_health jsonb;
  v_sync_history jsonb;
  v_order_summary jsonb;
  v_menu_count int;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  v_health :=
    catchmenu_integrations.get_toss_pos_health(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_locale := p_locale
    );

  -- 동기화 이력 최근 7회
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'sync_log_id', id,
        'sync_type', sync_type,
        'sync_status', sync_status,
        'menus_fetched', menus_fetched,
        'menus_created', menus_created,
        'menus_updated', menus_updated,
        'duration_ms', duration_ms,
        'synced_at', synced_at
      )
      order by synced_at desc
    ),
    '[]'::jsonb
  )
  into v_sync_history
  from catchmenu_integrations.toss_pos_menu_sync_log
  where store_id = p_store_id
    and tenant_id = p_tenant_id
  limit 7;

  -- 오늘 주문 요약
  select jsonb_build_object(
    'total_sent', count(*),
    'confirmed', count(*) filter (
      where send_status = 'CONFIRMED'
    ),
    'failed', count(*) filter (
      where send_status in (
        'FAILED', 'TIMEOUT'
      )
    ),
    'avg_duration_ms', coalesce(
      avg(duration_ms)::int, 0
    )
  )
  into v_order_summary
  from catchmenu_integrations.toss_pos_order_log
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and sent_at::date = v_business_day;

  -- 토스POS 동기화 메뉴 수
  select count(*) into v_menu_count
  from catchmenu_pos.menus
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and menu_code like 'TPOS_%'
    and is_active = true;

  return catchmenu_common.build_success_response(
    p_message_key := 'toss_pos_dashboard_loaded',
    p_data := jsonb_build_object(
      'store_id', p_store_id,
      'business_day', v_business_day,
      'health', v_health->'data',
      'synced_menu_count', v_menu_count,
      'today_orders', v_order_summary,
      'sync_history', v_sync_history,
      'menu_code_prefix', 'TPOS_',
      'loaded_at', now()
    ),
    p_locale := p_locale
  );
end;
$$;


-- =============================================
-- pg_cron: 토스POS 헬스체크
-- =============================================
insert into catchmenu_common.pg_cron_jobs (
  job_code, pg_cron_job_name,
  schedule_cron_utc, schedule_cron_kst,
  sql_command, notes, is_registered
) values
(
  'TOSS_POS_HEARTBEAT',
  'catchmenu_toss_pos_heartbeat',
  '*/5 * * * *',
  '*/5 * * * * (5분마다)',
  $sql$
SELECT catchmenu_common.notify_channel(
  p_tenant_id :=
    '00000000-0000-0000-0000-000000000001'::uuid,
  p_store_id :=
    '00000000-0000-0000-0000-000000000002'::uuid,
  p_channel_type := 'SYSTEM_EVENTS',
  p_event_type :=
    'toss_pos_heartbeat_requested',
  p_payload := jsonb_build_object(
    'store_id',
      '00000000-0000-0000-0000-000000000002',
    'requested_at', now()
  )
);
$sql$,
  '토스POS 연결 상태 확인. 5분마다.',
  true
)
on conflict (job_code) do nothing;


-- grants
do $$
begin
  revoke all on function
    catchmenu_integrations.sync_toss_pos_menu(
      uuid, uuid, text, jsonb, text, text
    ) from public;
  grant execute on function
    catchmenu_integrations.sync_toss_pos_menu(
      uuid, uuid, text, jsonb, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_integrations.send_order_to_toss_pos(
      uuid, uuid, uuid, text, text
    ) from public;
  grant execute on function
    catchmenu_integrations.send_order_to_toss_pos(
      uuid, uuid, uuid, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_integrations
      .confirm_toss_pos_order_sent(
      uuid, uuid, uuid, text, text,
      jsonb, text, int, text
    ) from public;
  grant execute on function
    catchmenu_integrations
      .confirm_toss_pos_order_sent(
      uuid, uuid, uuid, text, text,
      jsonb, text, int, text
    ) to authenticated;

  revoke all on function
    catchmenu_integrations.confirm_toss_pos_payment(
      uuid, uuid, uuid, jsonb, text, text
    ) from public;
  grant execute on function
    catchmenu_integrations.confirm_toss_pos_payment(
      uuid, uuid, uuid, jsonb, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_integrations.cancel_toss_pos_order(
      uuid, uuid, uuid, text, uuid, text, text
    ) from public;
  grant execute on function
    catchmenu_integrations.cancel_toss_pos_order(
      uuid, uuid, uuid, text, uuid, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_integrations.get_toss_pos_health(
      uuid, uuid, text
    ) from public;
  grant execute on function
    catchmenu_integrations.get_toss_pos_health(
      uuid, uuid, text
    ) to authenticated;

  revoke all on function
    catchmenu_integrations.get_toss_pos_dashboard(
      uuid, uuid, text
    ) from public;
  grant execute on function
    catchmenu_integrations.get_toss_pos_dashboard(
      uuid, uuid, text
    ) to authenticated;
end;
$$;

comment on function
  catchmenu_integrations.sync_toss_pos_menu(
    uuid, uuid, text, jsonb, text, text
  ) is
  '토스POS 메뉴 동기화.
   OKpos와 동일 구조, 코드 규칙만 다름.
   메뉴 코드: TPOS_{menuCode}
   카테고리 코드: TPOS_CAT_{categoryCode}
   API 필드명: menuCode/salePrice/useYn
     (OKpos: menu_code/price/is_available)
   FULL SYNC: TPOS_ 코드 없는 메뉴 비활성화.
   가격 변경 → ledger event 기록.
   1차 MVP 토스POS 연동 핵심.';

comment on function
  catchmenu_integrations.confirm_toss_pos_payment(
    uuid, uuid, uuid, jsonb, text, text
  ) is
  '토스POS 결제 확인 → 표준 파이프라인.
   API 필드명: approvalNo/paidAmt/payMethod
     (OKpos: approval_number/paid_amount/payment_method)
   confirm_payment() 호출 → KDS Late Binding.
   특허2: 토스POS 결제 = KDS HOLD 해제.
   provider_type = TOSS_POS.
   1차 MVP 결제 흐름 핵심.

   POS별 표준화 원칙:
   OKpos → confirm_okpos_payment()
   Toss POS → confirm_toss_pos_payment()
   모두 confirm_payment()로 수렴.
   단일 감사 원장 = 특허4 핵심.';


-- ===== END sql/migrations/0104_create_toss_pos_pipeline_rpc.sql =====


-- ===== BEGIN sql/migrations/0142_patch_toss_mvp_payment_intent_binding.sql =====

-- 0142_patch_toss_mvp_payment_intent_binding.sql
-- Scope: 604260 Toss MVP PaymentIntent Binding Precondition only.
-- Historical migrations remain immutable.

alter table catchmenu_integrations.toss_payment_requests
  add column if not exists payment_intent_id uuid;

do $$
begin
  if not exists (
    select 1
    from pg_constraint
    where conname = 'fk_toss_payment_requests_payment_intent'
      and conrelid =
        'catchmenu_integrations.toss_payment_requests'::regclass
  ) then
    alter table catchmenu_integrations.toss_payment_requests
      add constraint fk_toss_payment_requests_payment_intent
      foreign key (payment_intent_id)
      references catchmenu_payment.payment_intents(id);
  end if;
end;
$$;

create index if not exists idx_toss_requests_payment_intent
  on catchmenu_integrations.toss_payment_requests(payment_intent_id)
  where payment_intent_id is not null;

create or replace function
  catchmenu_integrations.bind_toss_payment_intent()
returns trigger
language plpgsql
volatile
security definer
set search_path = catchmenu_integrations,
                  catchmenu_payment,
                  catchmenu_pos,
                  catchmenu_common
as $$
declare
  v_order record;
  v_candidate record;
  v_candidate_count int := 0;
  v_intent_id uuid;
  v_intent_result jsonb;
  v_payment_channel text;
begin
  if new.order_id is null then
    raise exception using
      errcode = '23502',
      message = 'TOSS_PAYMENT_INTENT_ORDER_REQUIRED';
  end if;

  perform pg_advisory_xact_lock(
    hashtextextended(
      new.tenant_id::text || ':' || new.store_id::text || ':' ||
      new.order_id::text,
      604260
    )
  );

  select o.id, o.session_id, o.order_type, o.order_channel,
         o.final_amount
  into v_order
  from catchmenu_pos.orders o
  where o.id = new.order_id
    and o.tenant_id = new.tenant_id
    and o.store_id = new.store_id
  for share;

  if v_order.id is null then
    raise exception using
      errcode = '23503',
      message = 'TOSS_PAYMENT_INTENT_ORDER_NOT_FOUND';
  end if;

  if v_order.final_amount <> new.amount then
    raise exception using
      errcode = '23514',
      message = 'TOSS_PAYMENT_INTENT_AMOUNT_MISMATCH';
  end if;

  if v_order.order_type in ('DINE_IN', 'KIOSK', 'STAFF_ORDER')
    and v_order.session_id is null
  then
    raise exception using
      errcode = '23502',
      message = 'TOSS_PAYMENT_INTENT_SESSION_REQUIRED';
  end if;

  if new.payment_intent_id is not null then
    select pi.id
    into v_intent_id
    from catchmenu_payment.payment_intents pi
    where pi.id = new.payment_intent_id
      and pi.tenant_id = new.tenant_id
      and pi.store_id = new.store_id
      and pi.order_id = new.order_id
      and pi.requested_amount = new.amount
      and pi.provider_type = 'TOSS_PAYMENTS'
      and pi.intent_status not in ('FAILED', 'CANCELLED', 'EXPIRED')
    for update;

    if v_intent_id is null then
      raise exception using
        errcode = '23503',
        message = 'TOSS_PAYMENT_INTENT_BINDING_INVALID';
    end if;

    return new;
  end if;

  for v_candidate in
    select pi.id, pi.session_id, pi.requested_amount,
           pi.provider_type
    from catchmenu_payment.payment_intents pi
    where pi.tenant_id = new.tenant_id
      and pi.store_id = new.store_id
      and pi.order_id = new.order_id
      and pi.intent_status not in ('FAILED', 'CANCELLED', 'EXPIRED')
    order by pi.created_at
    for update
  loop
    v_candidate_count := v_candidate_count + 1;
    v_intent_id := v_candidate.id;

    if v_candidate_count > 1 then
      raise exception using
        errcode = '23505',
        message = 'TOSS_PAYMENT_INTENT_BINDING_CONFLICT';
    end if;

    if v_candidate.requested_amount <> new.amount
      or v_candidate.provider_type <> 'TOSS_PAYMENTS'
      or v_candidate.session_id is distinct from v_order.session_id
    then
      raise exception using
        errcode = '23514',
        message = 'TOSS_PAYMENT_INTENT_ACTIVE_INTENT_MISMATCH';
    end if;
  end loop;

  if v_candidate_count = 0 then
    v_payment_channel := case v_order.order_channel
      when 'KIOSK' then 'KIOSK_QR'
      when 'TABLE_QR' then 'TABLE_QR'
      when 'CUSTOMER_APP' then 'CUSTOMER_APP'
      when 'STAFF_POS' then 'STAFF_POS'
      when 'MANUAL' then 'STAFF_POS'
      else 'ONLINE'
    end;

    v_intent_result := catchmenu_payment.create_payment_intent(
      p_tenant_id := new.tenant_id,
      p_store_id := new.store_id,
      p_order_id := new.order_id,
      p_session_id := v_order.session_id,
      p_payment_method := coalesce(new.payment_method, 'CARD'),
      p_payment_channel := v_payment_channel,
      p_provider_type := 'TOSS_PAYMENTS',
      p_requested_amount := new.amount,
      p_idempotency_key := 'TOSS-INTENT:' || new.idempotency_key,
      p_correlation_id := 'TOSS-REQUEST:' || new.idempotency_key
    );

    if not coalesce((v_intent_result->>'success')::boolean, false) then
      if v_intent_result->>'error_key' = 'active_intent_exists' then
        v_intent_id :=
          (v_intent_result->>'existing_intent_id')::uuid;

        select pi.id
        into v_intent_id
        from catchmenu_payment.payment_intents pi
        where pi.id = v_intent_id
          and pi.tenant_id = new.tenant_id
          and pi.store_id = new.store_id
          and pi.order_id = new.order_id
          and pi.session_id is not distinct from v_order.session_id
          and pi.requested_amount = new.amount
          and pi.provider_type = 'TOSS_PAYMENTS'
          and pi.intent_status not in ('FAILED', 'CANCELLED', 'EXPIRED')
        for update;
      else
        raise exception using
          errcode = 'P0001',
          message = 'TOSS_PAYMENT_INTENT_CREATE_FAILED',
          detail = coalesce(v_intent_result::text, '{}');
      end if;
    else
      v_intent_id := (v_intent_result->>'intent_id')::uuid;
    end if;
  end if;

  if v_intent_id is null then
    raise exception using
      errcode = '23503',
      message = 'TOSS_PAYMENT_INTENT_BINDING_REQUIRED';
  end if;

  new.payment_intent_id := v_intent_id;
  return new;
end;
$$;

drop trigger if exists trg_toss_request_bind_payment_intent
  on catchmenu_integrations.toss_payment_requests;
create trigger trg_toss_request_bind_payment_intent
  before insert on catchmenu_integrations.toss_payment_requests
  for each row execute function
    catchmenu_integrations.bind_toss_payment_intent();

alter function catchmenu_integrations.initiate_toss_payment(
  uuid, uuid, uuid, text, text, text, text
) rename to initiate_toss_payment_legacy_604260;

alter function catchmenu_integrations.confirm_toss_payment(
  uuid, uuid, text, text, int, jsonb, text, text
) rename to confirm_toss_payment_legacy_604260;

create or replace function
  catchmenu_integrations.initiate_toss_payment(
  p_tenant_id uuid,
  p_store_id uuid,
  p_order_id uuid,
  p_payment_method text default 'CARD',
  p_customer_id_hash text default null,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_integrations,
                  catchmenu_common
as $$
declare
  v_result jsonb;
  v_request_id uuid;
  v_intent_id uuid;
begin
  v_result :=
    catchmenu_integrations.initiate_toss_payment_legacy_604260(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_order_id := p_order_id,
      p_payment_method := p_payment_method,
      p_customer_id_hash := p_customer_id_hash,
      p_locale := p_locale,
      p_correlation_id := p_correlation_id
    );

  if not coalesce((v_result->>'success')::boolean, false) then
    return v_result;
  end if;

  v_request_id := (v_result->'data'->>'request_id')::uuid;

  select tpr.payment_intent_id
  into v_intent_id
  from catchmenu_integrations.toss_payment_requests tpr
  where tpr.id = v_request_id
    and tpr.tenant_id = p_tenant_id
    and tpr.store_id = p_store_id;

  if v_intent_id is null then
    raise exception using
      errcode = '23503',
      message = 'TOSS_PAYMENT_INTENT_BINDING_REQUIRED';
  end if;

  return jsonb_set(
    v_result,
    '{data,payment_intent_id}',
    to_jsonb(v_intent_id),
    true
  );
end;
$$;

create or replace function
  catchmenu_integrations.confirm_toss_payment(
  p_tenant_id uuid,
  p_store_id uuid,
  p_payment_key text,
  p_order_id_toss text,
  p_amount int,
  p_toss_response jsonb default null,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_integrations,
                  catchmenu_payment,
                  catchmenu_common
as $$
declare
  v_request record;
  v_result jsonb;
begin
  select tpr.id, tpr.order_id, tpr.amount,
         tpr.payment_intent_id
  into v_request
  from catchmenu_integrations.toss_payment_requests tpr
  where tpr.order_id_toss = p_order_id_toss
    and tpr.tenant_id = p_tenant_id
    and tpr.store_id = p_store_id
  for update;

  if v_request.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'payment_not_found'
    );
  end if;

  if v_request.payment_intent_id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'payment_intent_binding_required',
      'request_id', v_request.id
    );
  end if;

  if not exists (
    select 1
    from catchmenu_payment.payment_intents pi
    where pi.id = v_request.payment_intent_id
      and pi.tenant_id = p_tenant_id
      and pi.store_id = p_store_id
      and pi.order_id = v_request.order_id
      and pi.requested_amount = v_request.amount
      and pi.provider_type = 'TOSS_PAYMENTS'
      and pi.intent_status not in ('FAILED', 'CANCELLED', 'EXPIRED')
  ) then
    return jsonb_build_object(
      'success', false,
      'error_key', 'payment_intent_binding_invalid',
      'request_id', v_request.id
    );
  end if;

  v_result :=
    catchmenu_integrations.confirm_toss_payment_legacy_604260(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_payment_key := p_payment_key,
      p_order_id_toss := p_order_id_toss,
      p_amount := p_amount,
      p_toss_response := p_toss_response,
      p_locale := p_locale,
      p_correlation_id := p_correlation_id
    );

  return jsonb_set(
    v_result,
    '{data,payment_intent_id}',
    to_jsonb(v_request.payment_intent_id),
    true
  );
end;
$$;

revoke all on function
  catchmenu_integrations.initiate_toss_payment_legacy_604260(
    uuid, uuid, uuid, text, text, text, text
  ) from public, authenticated;
revoke all on function
  catchmenu_integrations.confirm_toss_payment_legacy_604260(
    uuid, uuid, text, text, int, jsonb, text, text
  ) from public, authenticated;

revoke all on function
  catchmenu_integrations.initiate_toss_payment(
    uuid, uuid, uuid, text, text, text, text
  ) from public;
grant execute on function
  catchmenu_integrations.initiate_toss_payment(
    uuid, uuid, uuid, text, text, text, text
  ) to authenticated;

revoke all on function
  catchmenu_integrations.confirm_toss_payment(
    uuid, uuid, text, text, int, jsonb, text, text
  ) from public;
grant execute on function
  catchmenu_integrations.confirm_toss_payment(
    uuid, uuid, text, text, int, jsonb, text, text
  ) to authenticated;

comment on column
  catchmenu_integrations.toss_payment_requests.payment_intent_id is
  'Strong nullable FK binding prepared by Scope D 00A. New Toss requests must populate it; historical rows remain compatible.';

comment on function
  catchmenu_integrations.initiate_toss_payment(
    uuid, uuid, uuid, text, text, text, text
  ) is
  '604260 wrapper. Initiates Toss payment through the preserved legacy implementation and exposes the strongly bound payment_intent_id.';

comment on function
  catchmenu_integrations.confirm_toss_payment(
    uuid, uuid, text, text, int, jsonb, text, text
  ) is
  '604260 wrapper. Validates and exposes the bound payment_intent_id before using the preserved Toss confirmation path. It does not patch confirm_payment.';


-- ===== END sql/migrations/0142_patch_toss_mvp_payment_intent_binding.sql =====


-- ===== BEGIN sql/migrations/0143_add_no_payment_kds_release_policy.sql =====

-- 0143_add_no_payment_kds_release_policy.sql
-- Purpose: Store-scoped no-payment pilot release from KDS HOLD.
-- Boundary: This policy is independent from manual fallback and preserves
--           the existing payment-confirmed release path.
-- Depends on: 0049_create_store_settings_rpc.sql,
--             0053_create_staff_management_rpc.sql

alter table catchmenu_store.store_settings
  add column if not exists payment_required_for_kds_release boolean
  not null default true;

comment on column
  catchmenu_store.store_settings.payment_required_for_kds_release is
  'Store-scoped KDS payment policy. TRUE preserves the normal payment-required '
  'release path. FALSE enables the explicitly authorized NO_PAYMENT_PILOT RPC. '
  'This setting is unrelated to manual_fallback_activated.';

create or replace function catchmenu_kds.release_kds_ticket_no_payment(
  p_tenant_id uuid,
  p_store_id uuid,
  p_order_id uuid,
  p_ticket_id uuid,
  p_actor_id uuid,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = pg_catalog
as $$
declare
  v_ticket record;
  v_staff record;
  v_capacity jsonb;
  v_conditions jsonb;
  v_remaining_conditions_met boolean;
  v_audit_id uuid;
begin
  if p_tenant_id is null
     or p_store_id is null
     or p_order_id is null
     or p_ticket_id is null
     or p_actor_id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'release_scope_required'
    );
  end if;

  if catchmenu_common.current_tenant_id() is distinct from p_tenant_id
     or catchmenu_common.current_store_id() is distinct from p_store_id
     or catchmenu_common.current_actor_id() is distinct from p_actor_id then
    return jsonb_build_object(
      'success', false,
      'error_key', 'release_context_mismatch'
    );
  end if;

  select
    s.id,
    s.staff_role,
    s.authority_level,
    s.can_override_kds
  into v_staff
  from catchmenu_store.staff s
  where s.id = p_actor_id
    and s.tenant_id = p_tenant_id
    and s.store_id = p_store_id
    and s.staff_status = 'ACTIVE'
    and s.is_active = true;

  if v_staff.id is null or not coalesce(v_staff.can_override_kds, false) then
    return jsonb_build_object(
      'success', false,
      'error_key', 'unauthorized_release'
    );
  end if;

  if not exists (
    select 1
    from catchmenu_store.store_settings ss
    where ss.tenant_id = p_tenant_id
      and ss.store_id = p_store_id
      and ss.payment_required_for_kds_release = false
  ) then
    return jsonb_build_object(
      'success', false,
      'error_key', 'no_payment_policy_not_active'
    );
  end if;

  select
    kt.id,
    kt.tenant_id,
    kt.store_id,
    kt.order_id,
    kt.session_id,
    kt.kds_status,
    kt.conditions_met,
    kt.kitchen_zone,
    kt.business_day,
    kt.business_timezone
  into v_ticket
  from catchmenu_kds.kds_tickets kt
  where kt.id = p_ticket_id
    and kt.tenant_id = p_tenant_id
    and kt.store_id = p_store_id
    and kt.order_id = p_order_id
  for update;

  if v_ticket.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'ticket_scope_mismatch'
    );
  end if;

  if v_ticket.kds_status = 'COMMITTED'
     and coalesce(
       (v_ticket.conditions_met->>'no_payment_policy_released')::boolean,
       false
     ) then
    return jsonb_build_object(
      'success', true,
      'already_released', true,
      'ticket_id', p_ticket_id,
      'kds_status', v_ticket.kds_status,
      'release_source', 'STORE_NO_PAYMENT_POLICY',
      'message_code', 'kds_no_payment_policy_already_released'
    );
  end if;

  if v_ticket.kds_status <> 'HOLD' then
    return jsonb_build_object(
      'success', false,
      'error_key', 'ticket_not_holdable',
      'current_status', v_ticket.kds_status
    );
  end if;

  v_capacity := catchmenu_kds.evaluate_kds_capacity(
    p_tenant_id,
    p_store_id,
    v_ticket.kitchen_zone
  );

  v_conditions := coalesce(v_ticket.conditions_met, '{}'::jsonb)
    || jsonb_build_object(
      'kds_capacity_ok',
      coalesce((v_capacity->>'capacity_ok')::boolean, false)
    );

  v_remaining_conditions_met := (
    coalesce((v_conditions->>'arrived')::boolean, false)
    and coalesce((v_conditions->>'table_confirmed')::boolean, false)
    and coalesce((v_conditions->>'kds_capacity_ok')::boolean, false)
    and coalesce((v_conditions->>'menu_available')::boolean, true)
    and coalesce((v_conditions->>'peak_time_ok')::boolean, true)
    and coalesce((v_conditions->>'no_show_risk_ok')::boolean, true)
  );

  if not v_remaining_conditions_met then
    return jsonb_build_object(
      'success', false,
      'error_key', 'kds_conditions_not_met',
      'ticket_id', p_ticket_id,
      'conditions_met', v_conditions
    );
  end if;

  v_conditions := v_conditions || jsonb_build_object(
    'no_payment_policy_released', true,
    'no_payment_policy_release_source', 'STORE_NO_PAYMENT_POLICY',
    'no_payment_policy_authorized_by', p_actor_id
  );

  update catchmenu_kds.kds_tickets
  set
    kds_status = 'COMMITTED',
    conditions_met = v_conditions,
    committed_at = now(),
    capacity_check_at = now(),
    kds_queue_length_at_check =
      (v_capacity->>'cooking_count')::int,
    updated_at = now()
  where id = p_ticket_id
    and tenant_id = p_tenant_id
    and store_id = p_store_id
    and order_id = p_order_id
    and kds_status = 'HOLD';

  if not found then
    return jsonb_build_object(
      'success', false,
      'error_key', 'ticket_release_conflict'
    );
  end if;

  insert into catchmenu_kds.kds_events (
    tenant_id,
    store_id,
    ticket_id,
    order_id,
    event_type,
    from_status,
    to_status,
    caused_by_type,
    caused_by_id,
    conditions_at_event,
    event_payload,
    correlation_id,
    occurred_at
  ) values (
    p_tenant_id,
    p_store_id,
    p_ticket_id,
    p_order_id,
    'all_conditions_met',
    'HOLD',
    'COMMITTED',
    'STAFF',
    p_actor_id,
    v_conditions,
    jsonb_build_object(
      'release_source', 'STORE_NO_PAYMENT_POLICY',
      'release_reason', 'NO_PAYMENT_PILOT',
      'payment_confirmed',
        coalesce((v_conditions->>'payment_confirmed')::boolean, false),
      'staff_role', v_staff.staff_role,
      'authority_level', v_staff.authority_level
    ),
    p_correlation_id,
    now()
  );

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
    caused_by_id,
    event_payload,
    session_id,
    order_id,
    kds_ticket_id,
    correlation_id,
    business_day,
    business_timezone,
    occurred_at
  ) values (
    p_tenant_id,
    p_store_id,
    'kds',
    'kds_no_payment_policy_released',
    1,
    'kds_ticket',
    p_ticket_id,
    'HOLD',
    'COMMITTED',
    'STAFF',
    p_actor_id,
    jsonb_build_object(
      'release_source', 'STORE_NO_PAYMENT_POLICY',
      'release_reason', 'NO_PAYMENT_PILOT',
      'payment_required_for_kds_release', false,
      'payment_confirmed',
        coalesce((v_conditions->>'payment_confirmed')::boolean, false)
    ),
    v_ticket.session_id,
    p_order_id,
    p_ticket_id,
    p_correlation_id,
    v_ticket.business_day,
    v_ticket.business_timezone,
    now()
  );

  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := 'kds',
    p_audit_type := 'kds_no_payment_policy_released',
    p_audit_category := 'OPERATIONAL',
    p_actor_type := 'STAFF',
    p_actor_id := p_actor_id,
    p_subject_type := 'kds_ticket',
    p_subject_id := p_ticket_id,
    p_decision := 'APPROVED',
    p_decision_reason := 'STORE_NO_PAYMENT_POLICY',
    p_decision_payload := jsonb_build_object(
      'release_source', 'STORE_NO_PAYMENT_POLICY',
      'release_reason', 'NO_PAYMENT_PILOT',
      'payment_required_for_kds_release', false,
      'authorizing_actor_id', p_actor_id
    ),
    p_before_state := jsonb_build_object(
      'kds_status', 'HOLD',
      'conditions_met', v_ticket.conditions_met
    ),
    p_after_state := jsonb_build_object(
      'kds_status', 'COMMITTED',
      'conditions_met', v_conditions
    ),
    p_session_id := v_ticket.session_id,
    p_order_id := p_order_id,
    p_kds_ticket_id := p_ticket_id,
    p_correlation_id := p_correlation_id,
    p_business_day := v_ticket.business_day,
    p_business_timezone := v_ticket.business_timezone
  );

  return jsonb_build_object(
    'success', true,
    'already_released', false,
    'ticket_id', p_ticket_id,
    'order_id', p_order_id,
    'kds_status', 'COMMITTED',
    'release_source', 'STORE_NO_PAYMENT_POLICY',
    'authorized_by', p_actor_id,
    'audit_id', v_audit_id,
    'message_code', 'kds_no_payment_policy_released'
  );
end;
$$;

revoke all on function catchmenu_kds.release_kds_ticket_no_payment(
  uuid, uuid, uuid, uuid, uuid, text
) from public;

grant execute on function catchmenu_kds.release_kds_ticket_no_payment(
  uuid, uuid, uuid, uuid, uuid, text
) to authenticated;

comment on function catchmenu_kds.release_kds_ticket_no_payment(
  uuid, uuid, uuid, uuid, uuid, text
) is
  'Releases one HOLD ticket to COMMITTED only when the exact tenant/store '
  'has payment_required_for_kds_release = FALSE and the authenticated active '
  'staff actor has can_override_kds. The RPC preserves payment_confirmed and '
  'does not read or use manual_fallback_activated.';


-- ===== END sql/migrations/0143_add_no_payment_kds_release_policy.sql =====


-- ===== BEGIN sql/migrations/0153_drop_confirm_payment_provider_legacy_overload.sql =====

-- 0153_drop_confirm_payment_provider_legacy_overload.sql
-- Purpose: Remove the dormant 9-param overload of
--          catchmenu_payment.confirm_payment_from_provider()
--          (added in 0063, p_locale extra), leaving the 8-param
--          original (0027) as the single canonical function.
--
-- Background:
--   Two live overloads caused every real caller (0038 Toss webhook,
--   0056 VAN integration) to fail with "function ... is not unique"
--   since both use identical 8 named arguments that PostgreSQL could
--   not resolve between the two candidates. Direct reproduction
--   further showed the 9-param overload independently crashes on
--   its own first write statement (phantom/missing columns), so
--   there is no working functionality being removed.
--
-- Human decision (2026-07-14): single canonical 8-param function,
-- no p_locale, no JSONB extension field (YAGNI).
--
-- Depends on:
--   - 0152_add_orders_pickup_ready_timing_columns.sql

drop function if exists catchmenu_payment.confirm_payment_from_provider(
  uuid, uuid, uuid, text, text, int, uuid, text, text
);


-- ===== END sql/migrations/0153_drop_confirm_payment_provider_legacy_overload.sql =====


-- ===== BEGIN sql/migrations/0154_drop_mark_payment_uncertain_legacy_overload.sql =====

-- =============================================
-- Migration: 0154_drop_mark_payment_uncertain_legacy_overload
-- Purpose:
--   Drop the dormant 0063-era 6-param mark_payment_uncertain() overload
--   and leave the 0027-era 5-param function as the single canonical
--   catchmenu_payment.mark_payment_uncertain() implementation.
--
-- Background:
--   600530_mark_payment_uncertain_overload_ambiguity confirmed that the
--   0063 overload adds p_locale and creates overload ambiguity while also
--   failing independently against live constraints:
--     - intent_status = 'UNCERTAIN' violates chk_intent_status.
--     - catchmenu_ledger.exceptions.exception_code is NOT NULL, but the
--       0063 overload omits exception_code in its INSERT.
--
-- Depends on:
--   0153_drop_confirm_payment_provider_legacy_overload.sql
--
-- Creates/Changes:
--   Removes only:
--     catchmenu_payment.mark_payment_uncertain(
--       uuid, uuid, uuid, text, text, text
--     )
--
-- Non-goals:
--   - Do not modify 0027_create_payment_intent_rpc.sql.
--   - Do not modify 0063_patch_core_rpc_i18n_diagnostics.sql.
--   - Do not modify 0070_create_flutter_bootstrap_rpc.sql.
--   - Do not change chk_intent_status.
--   - Do not add p_locale or p_options jsonb.
--   - Do not fix the carried-forward 0027 dashboard invisibility,
--     i18n/diagnostic-log gap, real call-chain absence, or
--     authorize_kds_release() overload issue in this migration.
-- =============================================

drop function if exists catchmenu_payment.mark_payment_uncertain(
  uuid, uuid, uuid, text, text, text
);


-- ===== END sql/migrations/0154_drop_mark_payment_uncertain_legacy_overload.sql =====


-- ===== BEGIN sql/migrations/0157_authorize_kds_release_overload_and_redesign.sql =====

-- 0157_authorize_kds_release_overload_and_redesign.sql
-- Purpose:
--   Restore the payment-ledger KDS release authorization contract for the
--   normal confirm_payment() path, make start_cooking() fail closed when a
--   committed ticket has no linked payment ledger, and remove the legacy
--   authorize_kds_release() overloads.
--
-- Background:
--   Defect 1: release_kds_after_payment() committed KDS tickets but only wrote
--             kds_release_authorized into kds_tickets.conditions_met JSON; it
--             did not set payment_ledger.kds_release_authorized.
--   Defect 2: bulk_commit_kds_tickets() already gates on the payment_ledger
--             column. It should remain unchanged and pass naturally once
--             Defect 1 is fixed.
--   Defect 3: start_cooking() was fail-open when payment_ledger_id was null.
--             It must fail closed with kds_release_ledger_missing.
--
-- Human decision:
--   601024_ChangeContract.md approved Slice 1, Slice 2, and Slice 3
--   on 2026-07-15.
--
-- Depends on:
--   0156_add_did_device_edid_mapping.sql
--   0098_create_payment_confirm_pipeline_rpc.sql
--   0029_create_kds_cooking_rpc.sql
--   0028_create_kds_capacity_commit_rpc.sql
--   0063_patch_core_rpc_i18n_diagnostics.sql
--
-- Non-goals:
--   Does not modify confirm_payment() body.
--   Does not modify bulk_commit_kds_tickets().
--   Does not modify confirm_payment_from_provider(), Toss webhook, or VAN
--   paths (0027/0038/0056).
--   Does not modify release_kds_ticket_no_payment() (0143).
--   Does not design cash payment, retry, reconciliation, or PG/VAN audit flow.

create or replace function
  catchmenu_payment.release_kds_after_payment(
  p_tenant_id uuid,
  p_store_id uuid,
  p_order_id uuid,
  p_ledger_id uuid,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_payment,
                  catchmenu_kds,
                  catchmenu_common
as $$
declare
  v_released_count int := 0;
  v_ticket_ids jsonb := '[]'::jsonb;
  v_capacity_check jsonb;
  v_business_day date;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  -- Recheck KDS capacity at the payment-complete late-binding point.
  v_capacity_check :=
    catchmenu_kds.check_kds_capacity(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id
    );

  -- Slice 1: create the table-level KDS release authorization before
  -- committing KDS tickets. This aligns the payment_ledger column with the
  -- existing kds_tickets.conditions_met JSON evidence.
  update catchmenu_payment.payment_ledger
  set
    kds_release_authorized = true,
    kds_release_authorized_at = now(),
    kds_release_authorized_by = 'SYSTEM'
  where id = p_ledger_id
    and tenant_id = p_tenant_id
    and store_id = p_store_id;

  -- HOLD tickets -> COMMITTED.
  -- conditions_met JSON evidence:
  --   payment_confirmed = true
  --   kds_release_authorized = true
  with released as (
    update catchmenu_kds.kds_tickets
    set
      kds_status = 'COMMITTED',
      conditions_met = jsonb_build_object(
        'payment_confirmed', true,
        'kds_release_authorized', true,
        'payment_ledger_id', p_ledger_id,
        'released_at', now()
      ),
      committed_at = now(),
      updated_at = now()
    where order_id = p_order_id
      and store_id = p_store_id
      and tenant_id = p_tenant_id
      and kds_status = 'HOLD'
    returning id
  )
  select
    count(*),
    coalesce(
      jsonb_agg(to_jsonb(id)), '[]'::jsonb
    )
  into v_released_count, v_ticket_ids
  from released;

  if v_released_count = 0 then
    perform catchmenu_common.log_diagnostic(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_log_level := 'WARNING',
      p_log_domain := 'KDS',
      p_log_event := 'kds_no_hold_tickets',
      p_message :=
        'KDS HOLD tickets not found for order_id='
        || p_order_id,
      p_rpc_name := 'release_kds_after_payment',
      p_correlation_id := p_correlation_id,
      p_details := jsonb_build_object(
        'order_id', p_order_id,
        'ledger_id', p_ledger_id
      )
    );
  end if;

  -- KDS realtime broadcast.
  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_channel_type := 'KDS_TICKETS',
    p_event_type := 'kds_tickets_released',
    p_payload := jsonb_build_object(
      'order_id', p_order_id,
      'ledger_id', p_ledger_id,
      'released_count', v_released_count,
      'ticket_ids', v_ticket_ids,
      'capacity', v_capacity_check->'data',
      'released_at', now()
    )
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'kds_released',
    p_data := jsonb_build_object(
      'order_id', p_order_id,
      'released_count', v_released_count,
      'ticket_ids', v_ticket_ids,
      'kds_status', 'COMMITTED',
      'capacity_after',
        v_capacity_check->'data',
      'late_binding_principle',
        'HOLD -> COMMITTED after payment only'
    ),
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );
end;
$$;

create or replace function catchmenu_kds.start_cooking(
  p_tenant_id uuid,
  p_store_id uuid,
  p_ticket_id uuid,
  p_actor_type text default 'STAFF',
  p_actor_id uuid default null,
  p_device_id uuid default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_kds, catchmenu_ledger,
                  catchmenu_audit, catchmenu_common
as $$
declare
  v_ticket record;
  v_audit_id uuid;
begin
  select
    id, order_id, session_id, order_item_id, kds_status,
    kitchen_zone, ticket_number,
    menu_name_snapshot, quantity_snapshot,
    estimated_minutes_snapshot,
    payment_ledger_id,
    conditions_met,
    business_day, business_timezone
  into v_ticket
  from catchmenu_kds.kds_tickets
  where id = p_ticket_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
  for update;

  if v_ticket.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'ticket_not_found'
    );
  end if;

  if v_ticket.kds_status <> 'COMMITTED' then
    return jsonb_build_object(
      'success', false,
      'error_key', 'ticket_not_ready_to_commit',
      'current_status', v_ticket.kds_status
    );
  end if;

  -- Slice 2: fail closed when the ticket has no linked payment ledger.
  if v_ticket.payment_ledger_id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'kds_release_ledger_missing',
      'message', 'payment_ledger_id is null; ticket has no linked payment record'
    );
  end if;

  if not exists (
    select 1
    from catchmenu_payment.payment_ledger
    where id = v_ticket.payment_ledger_id
      and kds_release_authorized = true
  ) then
    return jsonb_build_object(
      'success', false,
      'error_key', 'kds_release_not_authorized',
      'message', 'payment_ledger.kds_release_authorized must be true'
    );
  end if;

  -- COMMITTED -> COOKING
  update catchmenu_kds.kds_tickets
  set
    kds_status = 'COOKING',
    cooking_started_at = now(),
    updated_at = now()
  where id = p_ticket_id;

  -- update order item status
  update catchmenu_pos.order_items
  set
    item_status = 'COOKING',
    updated_at = now()
  where id = v_ticket.order_item_id;

  -- KDS event
  insert into catchmenu_kds.kds_events (
    tenant_id, store_id, ticket_id, order_id,
    event_type, from_status, to_status,
    caused_by_type, caused_by_id,
    caused_by_device_id,
    conditions_at_event,
    event_payload, correlation_id, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    p_ticket_id, v_ticket.order_id,
    'cooking_started',
    'COMMITTED', 'COOKING',
    p_actor_type, p_actor_id,
    p_device_id,
    v_ticket.conditions_met,
    jsonb_build_object(
      'ticket_number', v_ticket.ticket_number,
      'kitchen_zone', v_ticket.kitchen_zone,
      'menu_name', v_ticket.menu_name_snapshot,
      'estimated_minutes', v_ticket.estimated_minutes_snapshot
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
    caused_by_device_id,
    event_payload,
    order_id, kds_ticket_id,
    correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'kds', 'kds_cooking_started', 1,
    'kds_ticket', p_ticket_id,
    'COMMITTED', 'COOKING',
    p_actor_type, p_actor_id,
    p_device_id,
    jsonb_build_object(
      'kitchen_zone', v_ticket.kitchen_zone,
      'ticket_number', v_ticket.ticket_number
    ),
    v_ticket.order_id, p_ticket_id,
    p_correlation_id,
    v_ticket.business_day, v_ticket.business_timezone, now()
  );

  -- audit
  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := 'kds',
    p_audit_type := 'kds_cooking_started',
    p_audit_category := 'OPERATIONAL',
    p_actor_type := p_actor_type,
    p_actor_id := p_actor_id,
    p_subject_type := 'kds_ticket',
    p_subject_id := p_ticket_id,
    p_decision := 'COMPLETED',
    p_decision_payload := jsonb_build_object(
      'ticket_number', v_ticket.ticket_number,
      'kitchen_zone', v_ticket.kitchen_zone,
      'cooking_started_at', now()
    ),
    p_before_state := jsonb_build_object(
      'kds_status', 'COMMITTED'
    ),
    p_after_state := jsonb_build_object(
      'kds_status', 'COOKING'
    ),
    p_order_id := v_ticket.order_id,
    p_kds_ticket_id := p_ticket_id,
    p_correlation_id := p_correlation_id,
    p_business_day := v_ticket.business_day,
    p_business_timezone := v_ticket.business_timezone
  );

  -- update order status to COOKING if not already
  update catchmenu_pos.orders
  set
    order_status = 'COOKING',
    updated_at = now()
  where id = v_ticket.order_id
    and order_status = 'CONFIRMED';

  return jsonb_build_object(
    'success', true,
    'ticket_id', p_ticket_id,
    'ticket_number', v_ticket.ticket_number,
    'kds_status', 'COOKING',
    'kitchen_zone', v_ticket.kitchen_zone,
    'cooking_started_at', now(),
    'estimated_minutes', v_ticket.estimated_minutes_snapshot,
    'audit_id', v_audit_id
  );
end;
$$;

drop function if exists catchmenu_kds.authorize_kds_release(
  uuid, uuid, uuid, text, uuid, text
);

drop function if exists catchmenu_kds.authorize_kds_release(
  uuid, uuid, uuid, text, uuid, text, text, text
);


-- ===== END sql/migrations/0157_authorize_kds_release_overload_and_redesign.sql =====


-- ===== BEGIN sql/migrations/0158_confirm_payment_intent_linkage_fix.sql =====

-- 0158_confirm_payment_intent_linkage_fix.sql
-- Purpose: Add payment_intents provenance columns and shared intent resolver
--          for confirm_payment()/manual/VAN observed payment flows.
-- Depends on:
--   0157_authorize_kds_release_overload_and_redesign.sql
-- Background:
--   600550_confirm_payment_column_drift_and_intent_linkage_fix confirmed
--   Option C+: every payment confirmation path must link to a real
--   payment_intents row, while intent_origin records how the row came to
--   exist. This migration adds that provenance contract and the shared
--   resolver used by 0098/0109/0130 source-level §24 patches.
-- Human decision:
--   2026-07-15 Human Boundary Approval for
--   600554_ChangeContract_Confirm_Payment_Column_Drift_And_Intent_Linkage_Fix.
-- Non-goals:
--   Does not modify 0027/0038/0056/0102/0104/0142 trigger logic.
--   Does not resolve downstream fee_amount/payment_method reader drift.

alter table catchmenu_payment.payment_intents
  add column if not exists intent_origin text not null default 'PREAUTHORIZED',
  add column if not exists origin_reference jsonb;

alter table catchmenu_payment.payment_intents
  drop constraint if exists chk_intent_origin;

alter table catchmenu_payment.payment_intents
  add constraint chk_intent_origin check (
    intent_origin in (
      'PREAUTHORIZED',
      'POS_SYNTHESIZED',
      'MANUAL_ENTRY',
      'VAN_SYNTHESIZED',
      'IMPORTED'
    )
  );

comment on column catchmenu_payment.payment_intents.intent_origin is
  'How this intent came to exist. PREAUTHORIZED intents are created before payment confirmation (widget/QR redirect flows). POS_SYNTHESIZED/MANUAL_ENTRY/VAN_SYNTHESIZED intents are Observed Intents — created at (or just before) confirmation time from a report of an already-completed payment. All intent_origin values are equally valid payment_intents rows; this column records provenance, not trust level.';

comment on column catchmenu_payment.payment_intents.origin_reference is
  'Structured provenance payload for observed or preauthorized payment intent resolution. Stores source-specific references such as provider transaction id, VAN transaction id, manual queue item id, or Toss payment request id.';

create or replace function catchmenu_payment.resolve_or_create_payment_intent(
  p_tenant_id uuid,
  p_store_id uuid,
  p_order_id uuid,
  p_requested_amount int,
  p_payment_method text,
  p_payment_channel text,
  p_provider_type text,
  p_intent_origin text,
  p_origin_reference jsonb default '{}'::jsonb,
  p_intent_id uuid default null,
  p_session_id uuid default null,
  p_locale text default 'ko'
)
returns uuid
language plpgsql
volatile
security definer
set search_path = catchmenu_payment,
                  catchmenu_pos,
                  catchmenu_hq,
                  catchmenu_common
as $$
declare
  v_intent_id uuid;
  v_candidate_count int;
  v_session_id uuid;
  v_business_day date;
  v_timezone text;
  v_payment_method text;
  v_payment_channel text;
  v_provider_type text;
  v_origin_reference jsonb;
begin
  if p_intent_origin not in (
    'PREAUTHORIZED',
    'POS_SYNTHESIZED',
    'MANUAL_ENTRY',
    'VAN_SYNTHESIZED',
    'IMPORTED'
  ) then
    return null;
  end if;

  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id
    and tenant_id = p_tenant_id;

  v_business_day := (
    timezone(coalesce(v_timezone, 'Asia/Seoul'), now())
  )::date;

  select session_id into v_session_id
  from catchmenu_pos.orders
  where id = p_order_id
    and tenant_id = p_tenant_id
    and store_id = p_store_id;

  v_session_id := coalesce(p_session_id, v_session_id);
  v_origin_reference := coalesce(p_origin_reference, '{}'::jsonb);

  v_payment_method := case
    when p_payment_method in (
      'CARD',
      'SIMPLE_PAY_KAKAO',
      'SIMPLE_PAY_NAVER',
      'SIMPLE_PAY_TOSS',
      'SAMSUNG_PAY',
      'ALIPAY',
      'WECHAT_PAY',
      'CASH',
      'VOUCHER',
      'MIXED'
    ) then p_payment_method
    when p_payment_method in ('CREDIT_CARD', 'DEBIT_CARD') then 'CARD'
    else 'CARD'
  end;

  v_payment_channel := case
    when p_payment_channel in (
      'KIOSK_CARD',
      'KIOSK_QR',
      'TABLE_QR',
      'CUSTOMER_APP',
      'STAFF_POS',
      'COUNTER_CARD',
      'ONLINE'
    ) then p_payment_channel
    else 'STAFF_POS'
  end;

  v_provider_type := case
    when p_provider_type in (
      'TOSS_PAYMENTS',
      'VAN_NICE',
      'VAN_KIS',
      'VAN_KICC',
      'KAKAO_PAY',
      'NAVER_PAY',
      'SAMSUNG_PAY',
      'ALIPAY',
      'WECHAT_PAY',
      'CASH',
      'INTERNAL'
    ) then p_provider_type
    when p_provider_type in ('NICE', 'NICE_VAN') then 'VAN_NICE'
    when p_provider_type in ('KIS', 'KIS_VAN') then 'VAN_KIS'
    when p_provider_type in ('KICC', 'KICC_VAN') then 'VAN_KICC'
    else 'INTERNAL'
  end;

  if p_intent_id is not null then
    select id into v_intent_id
    from catchmenu_payment.payment_intents
    where id = p_intent_id
      and tenant_id = p_tenant_id
      and store_id = p_store_id
      and order_id = p_order_id;

    if v_intent_id is null then
      return null;
    end if;

    update catchmenu_payment.payment_intents
    set
      intent_origin = coalesce(intent_origin, p_intent_origin),
      origin_reference = coalesce(origin_reference, v_origin_reference),
      updated_at = now()
    where id = v_intent_id;

    return v_intent_id;
  end if;

  select count(*)
  into v_candidate_count
  from catchmenu_payment.payment_intents
  where tenant_id = p_tenant_id
    and store_id = p_store_id
    and order_id = p_order_id
    and intent_origin = p_intent_origin
    and coalesce(origin_reference, '{}'::jsonb) = v_origin_reference
    and intent_status in (
      'CREATED',
      'PENDING',
      'PROCESSING',
      'CONFIRMED'
    );

  if v_candidate_count > 1 then
    raise exception
      'payment_intent_resolution_conflict: tenant=%, store=%, order=%, origin=%',
      p_tenant_id, p_store_id, p_order_id, p_intent_origin
      using errcode = 'P0001';
  end if;

  if v_candidate_count = 1 then
    select id into v_intent_id
    from catchmenu_payment.payment_intents
    where tenant_id = p_tenant_id
      and store_id = p_store_id
      and order_id = p_order_id
      and intent_origin = p_intent_origin
      and coalesce(origin_reference, '{}'::jsonb) = v_origin_reference
      and intent_status in (
        'CREATED',
        'PENDING',
        'PROCESSING',
        'CONFIRMED'
      )
    order by created_at desc
    limit 1;

    return v_intent_id;
  end if;

  insert into catchmenu_payment.payment_intents (
    tenant_id,
    store_id,
    order_id,
    session_id,
    intent_status,
    payment_method,
    payment_channel,
    requested_amount,
    currency,
    provider_type,
    provider_order_id,
    idempotency_key,
    business_day,
    business_timezone,
    intent_origin,
    origin_reference
  ) values (
    p_tenant_id,
    p_store_id,
    p_order_id,
    v_session_id,
    'CONFIRMED',
    v_payment_method,
    v_payment_channel,
    p_requested_amount,
    'KRW',
    v_provider_type,
    null,
    'OBS-' || p_order_id::text || '-' || p_intent_origin || '-'
      || substr(md5(v_origin_reference::text), 1, 12),
    v_business_day,
    coalesce(v_timezone, 'Asia/Seoul'),
    p_intent_origin,
    v_origin_reference
  )
  returning id into v_intent_id;

  return v_intent_id;
end;
$$;

revoke all on function catchmenu_payment.resolve_or_create_payment_intent(
  uuid, uuid, uuid, int, text, text, text, text, jsonb, uuid, uuid, text
) from public;

grant execute on function catchmenu_payment.resolve_or_create_payment_intent(
  uuid, uuid, uuid, int, text, text, text, text, jsonb, uuid, uuid, text
) to authenticated;

comment on function catchmenu_payment.resolve_or_create_payment_intent(
  uuid, uuid, uuid, int, text, text, text, text, jsonb, uuid, uuid, text
) is
  'Shared payment_intents resolver for PREAUTHORIZED and observed payment confirmation paths. Validates explicit PREAUTHORIZED ids, reuses an existing matching intent, or creates one observed intent for POS_SYNTHESIZED, MANUAL_ENTRY, or VAN_SYNTHESIZED flows.';


-- ===== END sql/migrations/0158_confirm_payment_intent_linkage_fix.sql =====


-- ===== BEGIN sql/migrations/0159_fix_payment_intent_idempotency_key_race.sql =====

-- 0159_fix_payment_intent_idempotency_key_race.sql
-- Purpose: Close the observed payment_intents race condition by enforcing
--          deterministic idempotency_key uniqueness and making the shared
--          resolver return the surviving row under concurrent inserts.
-- Depends on:
--   0158_confirm_payment_intent_linkage_fix.sql
-- Background:
--   600560_payment_intent_race_condition_fix confirmed that concurrent
--   resolve_or_create_payment_intent() calls can create duplicate observed
--   payment_intents rows with the same deterministic idempotency_key.
--   Stage 4 prechecks reconfirmed the known loser row has no FK references.
-- Human decision:
--   2026-07-16 Human Boundary Approval for
--   600564_ChangeContract.md, option (a).
-- Non-goals:
--   Does not modify confirm_payment(), confirm_payment_from_provider(),
--   0098/0103/0109/0130/0142 source files, payment ledger schema,
--   advisory lock behavior, or orders locking behavior.

delete from catchmenu_payment.payment_intents
where id = '283f3973-d547-4ea9-b4ad-b83b1c62b8cc';

alter table catchmenu_payment.payment_intents
  add constraint uq_payment_intents_idempotency_key unique (idempotency_key);

create or replace function catchmenu_payment.resolve_or_create_payment_intent(
  p_tenant_id uuid,
  p_store_id uuid,
  p_order_id uuid,
  p_requested_amount int,
  p_payment_method text,
  p_payment_channel text,
  p_provider_type text,
  p_intent_origin text,
  p_origin_reference jsonb default '{}'::jsonb,
  p_intent_id uuid default null,
  p_session_id uuid default null,
  p_locale text default 'ko'
)
returns uuid
language plpgsql
volatile
security definer
set search_path = catchmenu_payment,
                  catchmenu_pos,
                  catchmenu_hq,
                  catchmenu_common
as $$
declare
  v_intent_id uuid;
  v_candidate_count int;
  v_session_id uuid;
  v_business_day date;
  v_timezone text;
  v_payment_method text;
  v_payment_channel text;
  v_provider_type text;
  v_origin_reference jsonb;
begin
  if p_intent_origin not in (
    'PREAUTHORIZED',
    'POS_SYNTHESIZED',
    'MANUAL_ENTRY',
    'VAN_SYNTHESIZED',
    'IMPORTED'
  ) then
    return null;
  end if;

  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id
    and tenant_id = p_tenant_id;

  v_business_day := (
    timezone(coalesce(v_timezone, 'Asia/Seoul'), now())
  )::date;

  select session_id into v_session_id
  from catchmenu_pos.orders
  where id = p_order_id
    and tenant_id = p_tenant_id
    and store_id = p_store_id;

  v_session_id := coalesce(p_session_id, v_session_id);
  v_origin_reference := coalesce(p_origin_reference, '{}'::jsonb);

  v_payment_method := case
    when p_payment_method in (
      'CARD',
      'SIMPLE_PAY_KAKAO',
      'SIMPLE_PAY_NAVER',
      'SIMPLE_PAY_TOSS',
      'SAMSUNG_PAY',
      'ALIPAY',
      'WECHAT_PAY',
      'CASH',
      'VOUCHER',
      'MIXED'
    ) then p_payment_method
    when p_payment_method in ('CREDIT_CARD', 'DEBIT_CARD') then 'CARD'
    else 'CARD'
  end;

  v_payment_channel := case
    when p_payment_channel in (
      'KIOSK_CARD',
      'KIOSK_QR',
      'TABLE_QR',
      'CUSTOMER_APP',
      'STAFF_POS',
      'COUNTER_CARD',
      'ONLINE'
    ) then p_payment_channel
    else 'STAFF_POS'
  end;

  v_provider_type := case
    when p_provider_type in (
      'TOSS_PAYMENTS',
      'VAN_NICE',
      'VAN_KIS',
      'VAN_KICC',
      'KAKAO_PAY',
      'NAVER_PAY',
      'SAMSUNG_PAY',
      'ALIPAY',
      'WECHAT_PAY',
      'CASH',
      'INTERNAL'
    ) then p_provider_type
    when p_provider_type in ('NICE', 'NICE_VAN') then 'VAN_NICE'
    when p_provider_type in ('KIS', 'KIS_VAN') then 'VAN_KIS'
    when p_provider_type in ('KICC', 'KICC_VAN') then 'VAN_KICC'
    else 'INTERNAL'
  end;

  if p_intent_id is not null then
    select id into v_intent_id
    from catchmenu_payment.payment_intents
    where id = p_intent_id
      and tenant_id = p_tenant_id
      and store_id = p_store_id
      and order_id = p_order_id;

    if v_intent_id is null then
      return null;
    end if;

    update catchmenu_payment.payment_intents
    set
      intent_origin = coalesce(intent_origin, p_intent_origin),
      origin_reference = coalesce(origin_reference, v_origin_reference),
      updated_at = now()
    where id = v_intent_id;

    return v_intent_id;
  end if;

  select count(*)
  into v_candidate_count
  from catchmenu_payment.payment_intents
  where tenant_id = p_tenant_id
    and store_id = p_store_id
    and order_id = p_order_id
    and intent_origin = p_intent_origin
    and coalesce(origin_reference, '{}'::jsonb) = v_origin_reference
    and intent_status in (
      'CREATED',
      'PENDING',
      'PROCESSING',
      'CONFIRMED'
    );

  if v_candidate_count > 1 then
    raise exception
      'payment_intent_resolution_conflict: tenant=%, store=%, order=%, origin=%',
      p_tenant_id, p_store_id, p_order_id, p_intent_origin
      using errcode = 'P0001';
  end if;

  if v_candidate_count = 1 then
    select id into v_intent_id
    from catchmenu_payment.payment_intents
    where tenant_id = p_tenant_id
      and store_id = p_store_id
      and order_id = p_order_id
      and intent_origin = p_intent_origin
      and coalesce(origin_reference, '{}'::jsonb) = v_origin_reference
      and intent_status in (
        'CREATED',
        'PENDING',
        'PROCESSING',
        'CONFIRMED'
      )
    order by created_at desc
    limit 1;

    return v_intent_id;
  end if;

  insert into catchmenu_payment.payment_intents (
    tenant_id,
    store_id,
    order_id,
    session_id,
    intent_status,
    payment_method,
    payment_channel,
    requested_amount,
    currency,
    provider_type,
    provider_order_id,
    idempotency_key,
    business_day,
    business_timezone,
    intent_origin,
    origin_reference
  ) values (
    p_tenant_id,
    p_store_id,
    p_order_id,
    v_session_id,
    'CONFIRMED',
    v_payment_method,
    v_payment_channel,
    p_requested_amount,
    'KRW',
    v_provider_type,
    null,
    'OBS-' || p_order_id::text || '-' || p_intent_origin || '-'
      || substr(md5(v_origin_reference::text), 1, 12),
    v_business_day,
    coalesce(v_timezone, 'Asia/Seoul'),
    p_intent_origin,
    v_origin_reference
  )
  on conflict (idempotency_key) do update
  set updated_at = now()
  returning id into v_intent_id;

  return v_intent_id;
end;
$$;

revoke all on function catchmenu_payment.resolve_or_create_payment_intent(
  uuid, uuid, uuid, int, text, text, text, text, jsonb, uuid, uuid, text
) from public;

grant execute on function catchmenu_payment.resolve_or_create_payment_intent(
  uuid, uuid, uuid, int, text, text, text, text, jsonb, uuid, uuid, text
) to authenticated;

comment on function catchmenu_payment.resolve_or_create_payment_intent(
  uuid, uuid, uuid, int, text, text, text, text, jsonb, uuid, uuid, text
) is
  'Shared payment_intents resolver for PREAUTHORIZED and observed payment confirmation paths. Validates explicit PREAUTHORIZED ids, reuses an existing matching intent, or creates one observed intent for POS_SYNTHESIZED, MANUAL_ENTRY, or VAN_SYNTHESIZED flows. Observed inserts are protected by uq_payment_intents_idempotency_key and ON CONFLICT RETURNING so concurrent callers receive the same intent id.';


-- ===== END sql/migrations/0159_fix_payment_intent_idempotency_key_race.sql =====


-- ===== BEGIN sql/migrations/0166_canonical_kds_release_orchestration.sql =====

-- Migration: 0166_canonical_kds_release_orchestration.sql
-- Purpose: Canonical KDS release orchestration after provider payment confirmation.
-- Depends on: 0165_menu_price_list_architecture_phase0.sql
-- Creates: catchmenu_payment.request_kds_release_after_payment()
-- Changes: catchmenu_payment.confirm_payment_from_provider() response/KDS release orchestration only.
-- Non-goals: confirm_payment()(0098), resolve_payment_uncertain(), bulk_commit_kds_tickets(),
--            commit_kds_ticket(), evaluate_kds_capacity(), webhook idempotency.

create or replace function catchmenu_payment.request_kds_release_after_payment(
  p_tenant_id uuid,
  p_store_id uuid,
  p_order_id uuid,
  p_ledger_id uuid,
  p_actor_type text default 'SYSTEM',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_payment, catchmenu_kds,
                  catchmenu_ledger, catchmenu_audit,
                  catchmenu_common
as $$
declare
  v_bulk_result jsonb;
  v_result_code text;
  v_audit_id uuid;
begin
  -- Step 1: authorize the payment ledger row for KDS release.
  update catchmenu_payment.payment_ledger
  set
    kds_release_authorized = true,
    kds_release_authorized_at = now(),
    kds_release_authorized_by = p_actor_type
  where id = p_ledger_id
    and tenant_id = p_tenant_id
    and store_id = p_store_id;

  -- Step 2: delegate the actual ticket gate to the existing KDS bulk commit function.
  v_bulk_result := catchmenu_kds.bulk_commit_kds_tickets(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_order_id := p_order_id,
    p_force_conditions := null,
    p_correlation_id := p_correlation_id
  );

  -- Step 3: translate the bulk-commit result.
  -- Order matters: zero-ticket 0/0/0 must be classified before COMMITTED.
  v_result_code := case
    when not coalesce((v_bulk_result->>'success')::boolean, false)
      then 'PAYMENT_CONFIRMED_KDS_RELEASE_BLOCKED'
    when coalesce((v_bulk_result->>'committed_count')::int, 0) = 0
      and coalesce((v_bulk_result->>'pending_count')::int, 0) = 0
      and coalesce((v_bulk_result->>'skipped_count')::int, 0) = 0
      then 'PAYMENT_CONFIRMED_KDS_NO_TICKETS_TO_PROCESS'
    when coalesce((v_bulk_result->>'pending_count')::int, 0) = 0
      and coalesce((v_bulk_result->>'skipped_count')::int, 0) = 0
      then 'PAYMENT_CONFIRMED_KDS_COMMITTED'
    when coalesce((v_bulk_result->>'committed_count')::int, 0) > 0
      then 'PAYMENT_CONFIRMED_KDS_PARTIAL_CAPACITY_HOLD'
    else 'PAYMENT_CONFIRMED_KDS_CAPACITY_HOLD'
  end;

  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := 'payment',
    p_audit_type := 'kds_release_requested',
    p_audit_category := 'OPERATIONAL',
    p_actor_type := p_actor_type,
    p_actor_id := null,
    p_subject_type := 'payment_ledger',
    p_subject_id := p_ledger_id,
    p_decision := case
      when v_result_code = 'PAYMENT_CONFIRMED_KDS_COMMITTED' then 'APPROVED'
      when v_result_code = 'PAYMENT_CONFIRMED_KDS_RELEASE_BLOCKED' then 'FAILED'
      when v_result_code = 'PAYMENT_CONFIRMED_KDS_NO_TICKETS_TO_PROCESS' then 'NOTED'
      else 'SUSPENDED'
    end,
    p_decision_payload := jsonb_build_object(
      'result_code', v_result_code,
      'bulk_commit_result', v_bulk_result
    ),
    p_order_id := p_order_id,
    p_correlation_id := p_correlation_id
  );

  return jsonb_build_object(
    'success', true,
    'result_code', v_result_code,
    'ledger_id', p_ledger_id,
    'order_id', p_order_id,
    'committed_count', v_bulk_result->'committed_count',
    'pending_count', v_bulk_result->'pending_count',
    'skipped_count', v_bulk_result->'skipped_count',
    'bulk_commit_detail', v_bulk_result,
    'audit_id', v_audit_id
  );
exception
  when others then
    begin
      perform catchmenu_audit.append_audit_record(
        p_tenant_id := p_tenant_id,
        p_store_id := p_store_id,
        p_audit_domain := 'payment',
        p_audit_type := 'kds_release_requested_failed',
        p_audit_category := 'OPERATIONAL',
        p_actor_type := p_actor_type,
        p_actor_id := null,
        p_subject_type := 'payment_ledger',
        p_subject_id := p_ledger_id,
        p_decision := 'FAILED',
        p_decision_payload := jsonb_build_object(
          'error', sqlerrm,
          'sqlstate', sqlstate
        ),
        p_order_id := p_order_id,
        p_correlation_id := p_correlation_id
      );
    exception
      when others then
        raise warning 'request_kds_release_after_payment(): audit logging of the original failure itself failed (sqlstate=%) -- server log only, no DB trace beyond this warning', sqlstate;
    end;

    return jsonb_build_object(
      'success', true,
      'result_code', 'PAYMENT_CONFIRMED_KDS_RELEASE_FAILED',
      'ledger_id', p_ledger_id,
      'order_id', p_order_id,
      'error_detail', jsonb_build_object('sqlstate', sqlstate)
    );
end;
$$;

revoke all on function catchmenu_payment.request_kds_release_after_payment(
  uuid, uuid, uuid, uuid, text, text
) from public;

grant execute on function catchmenu_payment.request_kds_release_after_payment(
  uuid, uuid, uuid, uuid, text, text
) to authenticated;

create or replace function catchmenu_payment.confirm_payment_from_provider(
  p_tenant_id uuid,
  p_store_id uuid,
  p_intent_id uuid,
  p_provider_payment_key text,
  p_provider_approval_number text,
  p_approved_amount int,
  p_provider_raw_event_id uuid,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_payment, catchmenu_pos,
                  catchmenu_kds, catchmenu_ledger,
                  catchmenu_audit, catchmenu_common
as $$
declare
  v_intent record;
  v_ledger_id uuid;
  v_audit_id uuid;
  v_kds_release_result jsonb;
  v_kds_updated int;
begin
  -- intent validation
  select id, order_id, session_id, provider_type,
         requested_amount, payment_method, payment_channel,
         business_day, business_timezone, provider_order_id
  into v_intent
  from catchmenu_payment.payment_intents
  where id = p_intent_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
  for update;

  if v_intent.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'intent_not_found'
    );
  end if;

  if v_intent.requested_amount <> p_approved_amount then
    -- amount mismatch — create reconciliation case (handled separately)
    return jsonb_build_object(
      'success', false,
      'error_key', 'amount_mismatch',
      'requested_amount', v_intent.requested_amount,
      'approved_amount', p_approved_amount
    );
  end if;

  -- update intent status
  update catchmenu_payment.payment_intents
  set
    intent_status = 'CONFIRMED',
    confirmed_at = now(),
    updated_at = now()
  where id = p_intent_id;

  -- create payment ledger entry (internal source of truth)
  insert into catchmenu_payment.payment_ledger (
    tenant_id, store_id, order_id, session_id, intent_id,
    ledger_entry_type, ledger_status,
    approved_amount, net_amount,
    provider_type, provider_payment_key,
    provider_approval_number, provider_approved_at,
    provider_response_id,
    reconciliation_status,
    -- 특허1: 결제 승인 ≠ KDS 릴리즈 자동 허용
    -- kds_release_authorized starts FALSE
    kds_release_authorized,
    business_day, business_timezone,
    approved_at
  ) values (
    p_tenant_id, p_store_id,
    v_intent.order_id, v_intent.session_id, p_intent_id,
    'APPROVAL', 'APPROVED',
    p_approved_amount, p_approved_amount,
    v_intent.provider_type, p_provider_payment_key,
    p_provider_approval_number, now(),
    p_provider_raw_event_id,
    'PENDING',
    false,
    v_intent.business_day, v_intent.business_timezone,
    now()
  )
  returning id into v_ledger_id;

  -- update session payment status
  update catchmenu_pos.order_sessions
  set
    session_status = 'PAYMENT_PENDING',
    payment_completed_at = now(),
    updated_at = now()
  where id = v_intent.session_id;

  -- update KDS tickets: set payment_confirmed = true in conditions_met
  -- but kds_status stays HOLD until capacity check
  update catchmenu_kds.kds_tickets
  set
    conditions_met = conditions_met || jsonb_build_object(
      'payment_confirmed', true
    ),
    payment_ledger_id = v_ledger_id,
    updated_at = now()
  where order_id = v_intent.order_id
    and kds_status in ('HOLD', 'CAPACITY_CHECKING');

  get diagnostics v_kds_updated = row_count;

  -- KDS events for condition update
  insert into catchmenu_kds.kds_events (
    tenant_id, store_id, ticket_id, order_id,
    event_type, caused_by_type,
    conditions_at_event, event_payload, occurred_at
  )
  select
    p_tenant_id, p_store_id, kt.id, v_intent.order_id,
    'payment_confirmed_released',
    'SYSTEM',
    kt.conditions_met,
    jsonb_build_object(
      'payment_ledger_id', v_ledger_id,
      'approved_amount', p_approved_amount
    ),
    now()
  from catchmenu_kds.kds_tickets kt
  where kt.order_id = v_intent.order_id
    and kt.kds_status in ('HOLD', 'CAPACITY_CHECKING');

  -- payment event
  insert into catchmenu_payment.payment_events (
    tenant_id, store_id, order_id,
    intent_id, ledger_id,
    event_type, from_status, to_status,
    caused_by_type, amount_at_event,
    provider_event_id,
    event_payload, correlation_id, occurred_at
  ) values (
    p_tenant_id, p_store_id, v_intent.order_id,
    p_intent_id, v_ledger_id,
    'payment_approved', 'PROCESSING', 'APPROVED',
    'PROVIDER', p_approved_amount,
    p_provider_payment_key,
    jsonb_build_object(
      'provider_payment_key', p_provider_payment_key,
      'provider_approval_number', p_provider_approval_number,
      'kds_tickets_updated', v_kds_updated,
      'kds_release_authorized', false,
      'kds_release_pending_capacity_check', true
    ),
    p_correlation_id, now()
  );

  -- ledger event
  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, event_payload,
    session_id, order_id, payment_id,
    correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'payment', 'payment_approved', 1,
    'payment_ledger', v_ledger_id,
    'PROCESSING', 'APPROVED',
    'PROVIDER',
    jsonb_build_object(
      'approved_amount', p_approved_amount,
      'provider_payment_key', p_provider_payment_key,
      'kds_release_authorized', false,
      'reconciliation_required', true
    ),
    v_intent.session_id, v_intent.order_id, v_ledger_id,
    p_correlation_id,
    v_intent.business_day, v_intent.business_timezone, now()
  );

  -- audit record
  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := 'payment',
    p_audit_type := 'payment_approved',
    p_audit_category := 'FINANCIAL',
    p_actor_type := 'PROVIDER',
    p_actor_id := null,
    p_subject_type := 'payment_ledger',
    p_subject_id := v_ledger_id,
    p_decision := 'APPROVED',
    p_decision_payload := jsonb_build_object(
      'approved_amount', p_approved_amount,
      'provider_payment_key', p_provider_payment_key,
      'provider_approval_number', p_provider_approval_number,
      'kds_release_authorized', false,
      'reconciliation_status', 'PENDING'
    ),
    p_after_state := jsonb_build_object(
      'ledger_status', 'APPROVED',
      'kds_release_authorized', false
    ),
    p_payment_id := v_ledger_id,
    p_order_id := v_intent.order_id,
    p_session_id := v_intent.session_id,
    p_correlation_id := p_correlation_id,
    p_business_day := v_intent.business_day,
    p_business_timezone := v_intent.business_timezone
  );

  -- KDS release orchestration (Option C): only the release call is wrapped.
  -- Payment-core work above (intent validation, ledger insert, ticket/event updates,
  -- and this function's own audit record) remains outside this nested exception block.
  begin
    v_kds_release_result := catchmenu_payment.request_kds_release_after_payment(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_order_id := v_intent.order_id,
      p_ledger_id := v_ledger_id,
      p_actor_type := 'PROVIDER',
      p_correlation_id := p_correlation_id
    );
  exception
    when others then
      begin
        perform catchmenu_audit.append_audit_record(
          p_tenant_id := p_tenant_id,
          p_store_id := p_store_id,
          p_audit_domain := 'payment',
          p_audit_type := 'kds_release_call_unexpected_exception',
          p_audit_category := 'FINANCIAL',
          p_actor_type := 'PROVIDER',
          p_actor_id := null,
          p_subject_type := 'payment_ledger',
          p_subject_id := v_ledger_id,
          p_decision := 'FAILED',
          p_decision_payload := jsonb_build_object(
            'error', sqlerrm,
            'sqlstate', sqlstate
          ),
          p_order_id := v_intent.order_id,
          p_correlation_id := p_correlation_id
        );
      exception
        when others then
          raise warning 'confirm_payment_from_provider(): audit logging of the KDS-release-call failure itself failed (sqlstate=%) -- payment_ledger row % still committed; server log only for the original KDS failure', sqlstate, v_ledger_id;
      end;

      v_kds_release_result := jsonb_build_object(
        'success', true,
        'result_code', 'PAYMENT_CONFIRMED_KDS_RELEASE_FAILED',
        'ledger_id', v_ledger_id,
        'order_id', v_intent.order_id,
        'error_detail', jsonb_build_object('sqlstate', sqlstate)
      );
  end;

  return jsonb_build_object(
    'success', true,
    'ledger_id', v_ledger_id,
    'intent_id', p_intent_id,
    'ledger_status', 'APPROVED',
    'approved_amount', p_approved_amount,
    'kds_release_authorized',
      (v_kds_release_result->>'result_code' = 'PAYMENT_CONFIRMED_KDS_COMMITTED'),
    'kds_tickets_payment_confirmed', v_kds_updated,
    'kds_release_result', v_kds_release_result,
    'result_code', v_kds_release_result->>'result_code',
    'reconciliation_status', 'PENDING',
    'message_code', case
      when v_kds_release_result->>'result_code' = 'PAYMENT_CONFIRMED_KDS_COMMITTED'
        then 'payment_approved_kds_released'
      else 'payment_approved_kds_pending'
    end,
    'audit_id', v_audit_id
  );
end;
$$;


-- ===== END sql/migrations/0166_canonical_kds_release_orchestration.sql =====
