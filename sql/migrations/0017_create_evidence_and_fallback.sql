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