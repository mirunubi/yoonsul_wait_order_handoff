-- slice_05 — Runtime Flow (700000_runtime_flow_bundle)
-- Files: 2


-- ===== BEGIN sql/migrations/0009_create_gateway_provider_events.sql =====

-- 0009_create_gateway_provider_events.sql
-- Purpose: Gateway sandbox boundary. All external inputs land here first.
--          Raw provider events are stored as-is before verification.
--          Nothing enters internal ledgers without passing gateway validation.
--          특허1 core: Zero Trust external boundary + sandbox interface.
-- Depends on: 0008_create_ledger_audit.sql
-- Creates:
--   catchmenu_gateway.provider_raw_events
--   catchmenu_gateway.gateway_sessions

create table if not exists catchmenu_gateway.provider_raw_events (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references catchmenu_hq.tenants(id),
  store_id uuid references catchmenu_hq.stores(id),

  -- provider identity
  provider_type text not null,
  provider_code text not null,
  provider_event_id text,
  provider_event_type text,

  -- raw payload (preserved exactly as received)
  raw_headers jsonb,
  raw_payload jsonb not null,
  payload_hash text,

  -- signature verification
  signature_header text,
  signature_verified boolean,
  signature_verified_at timestamptz,
  signature_algorithm text,

  -- schema validation
  schema_validated boolean,
  schema_validation_errors jsonb,

  -- processing state
  processing_status text not null default 'RECEIVED',
  processing_attempts int not null default 0,
  first_received_at timestamptz not null default now(),
  last_processed_at timestamptz,

  -- result
  accepted_at timestamptz,
  rejected_at timestamptz,
  rejection_reason text,

  -- internal linkage (set after acceptance)
  internal_event_id uuid references catchmenu_ledger.events(id),
  idempotency_key_id uuid references catchmenu_common.idempotency_keys(id),
  correlation_id text,

  -- source device/channel
  source_ip text,
  source_device_id uuid references catchmenu_store.device_registry(id),
  received_at timestamptz not null default now(),

  constraint chk_provider_type check (
    provider_type in (
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
    )
  ),
  constraint chk_gateway_processing_status check (
    processing_status in (
      'RECEIVED',
      'VALIDATING',
      'ACCEPTED',
      'REJECTED',
      'QUARANTINED',
      'REPLAYED',
      'EXPIRED'
    )
  ),
  constraint chk_raw_payload_object check (
    jsonb_typeof(raw_payload) = 'object'
  ),
  constraint chk_schema_errors_object check (
    schema_validation_errors is null
    or jsonb_typeof(schema_validation_errors) = 'object'
  ),
  constraint chk_processing_attempts check (
    processing_attempts >= 0
  )
);

create index if not exists idx_provider_events_store_provider
  on catchmenu_gateway.provider_raw_events(store_id, provider_type);

create index if not exists idx_provider_events_provider_event_id
  on catchmenu_gateway.provider_raw_events(provider_event_id)
  where provider_event_id is not null;

create index if not exists idx_provider_events_status
  on catchmenu_gateway.provider_raw_events(processing_status, received_at desc)
  where processing_status in ('RECEIVED', 'VALIDATING', 'QUARANTINED');

create index if not exists idx_provider_events_correlation
  on catchmenu_gateway.provider_raw_events(correlation_id)
  where correlation_id is not null;

create index if not exists idx_provider_events_internal_event
  on catchmenu_gateway.provider_raw_events(internal_event_id)
  where internal_event_id is not null;

create index if not exists idx_provider_events_payload_hash
  on catchmenu_gateway.provider_raw_events(payload_hash)
  where payload_hash is not null;

comment on table catchmenu_gateway.provider_raw_events is
  'Gateway sandbox. Every external event lands here before touching internal ledgers.
   Raw payload is stored exactly as received — never modified.
   Processing pipeline:
     RECEIVED → signature verification → schema validation → idempotency check
     → ACCEPTED (internal event created) or REJECTED or QUARANTINED.
   Rejected and quarantined events never reach internal ledgers.
   특허1 core: 외부 POS/PG/VAN/배달앱을 신뢰하지 않는 Zero Trust 구조.
   샌드박스 인터페이스가 외부 요청을 검증한 후에만 내부 서버로 전달.';
comment on column catchmenu_gateway.provider_raw_events.raw_payload is
  'Exact payload received from provider. Never modified after insert.
   This is the forensic evidence for any provider dispute.';
comment on column catchmenu_gateway.provider_raw_events.payload_hash is
  'SHA-256 hash of raw_payload for replay detection.
   If same hash arrives again, it is a duplicate and must be idempotency-checked.';
comment on column catchmenu_gateway.provider_raw_events.signature_verified is
  'True = signature matched provider public key or HMAC secret.
   False = signature mismatch. Event must be REJECTED.
   Null = provider does not use signature verification.';
comment on column catchmenu_gateway.provider_raw_events.processing_status is
  'RECEIVED = just arrived, not yet processed.
   VALIDATING = signature and schema checks in progress.
   ACCEPTED = passed all checks, internal event created.
   REJECTED = failed signature, schema, or idempotency check.
   QUARANTINED = suspicious pattern detected, held for manual review.
   REPLAYED = reprocessed from quarantine after manual approval.
   EXPIRED = TTL passed without processing.';
comment on column catchmenu_gateway.provider_raw_events.internal_event_id is
  'Set after ACCEPTED. Links raw provider event to internal ledger event.
   This is the audit trail connecting external world to internal state.';


create table if not exists catchmenu_gateway.gateway_sessions (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references catchmenu_hq.tenants(id),
  store_id uuid not null references catchmenu_hq.stores(id),

  -- session identity
  session_type text not null,
  session_status text not null default 'ACTIVE',

  -- provider
  provider_type text not null,
  provider_code text,
  provider_session_id text,

  -- token (single-use stateless token per 특허1)
  session_token text unique,
  token_scope jsonb,
  token_issued_at timestamptz,
  token_expires_at timestamptz,
  token_used_count int not null default 0,
  token_max_use int not null default 1,

  -- linked operational context
  store_id_scope uuid references catchmenu_hq.stores(id),
  table_id_scope uuid,
  order_session_id_scope uuid,
  payment_session_id_scope uuid,

  -- event counts
  events_received int not null default 0,
  events_accepted int not null default 0,
  events_rejected int not null default 0,

  -- timing
  opened_at timestamptz not null default now(),
  last_activity_at timestamptz not null default now(),
  closed_at timestamptz,
  expires_at timestamptz,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint chk_gateway_session_type check (
    session_type in (
      'POS_INTEGRATION',
      'PAYMENT_PROCESSING',
      'DELIVERY_INTAKE',
      'WEBHOOK_LISTENER',
      'KIOSK_SESSION',
      'AGENT_SYNC',
      'PROVIDER_CALLBACK'
    )
  ),
  constraint chk_gateway_session_status check (
    session_status in (
      'ACTIVE',
      'SUSPENDED',
      'CLOSED',
      'EXPIRED',
      'REVOKED'
    )
  ),
  constraint chk_token_scope_object check (
    token_scope is null
    or jsonb_typeof(token_scope) = 'object'
  ),
  constraint chk_token_use_count check (
    token_used_count >= 0
    and token_used_count <= token_max_use
  )
);

create index if not exists idx_gateway_sessions_store_type
  on catchmenu_gateway.gateway_sessions(store_id, session_type, session_status);

create index if not exists idx_gateway_sessions_token
  on catchmenu_gateway.gateway_sessions(session_token)
  where session_token is not null;

create index if not exists idx_gateway_sessions_provider
  on catchmenu_gateway.gateway_sessions(provider_type, provider_session_id)
  where provider_session_id is not null;

create index if not exists idx_gateway_sessions_expires
  on catchmenu_gateway.gateway_sessions(expires_at)
  where session_status = 'ACTIVE'
    and expires_at is not null;

drop trigger if exists trg_gateway_sessions_updated_at
  on catchmenu_gateway.gateway_sessions;
create trigger trg_gateway_sessions_updated_at
  before update on catchmenu_gateway.gateway_sessions
  for each row execute function catchmenu_common.set_updated_at();

comment on table catchmenu_gateway.gateway_sessions is
  'Gateway session registry. Tracks active integration sessions with external providers.
   특허1 core: 단회성 비상태형 토큰 발급부.
   Each session issues a single-use stateless token scoped to:
   specific store, table, order session, and payment session.
   Token is never reused. Token never exposes internal customer identifiers.
   External POS receives token only — never internal keys or customer PII.';
comment on column catchmenu_gateway.gateway_sessions.session_token is
  'Single-use stateless token issued to external provider.
   Scoped by store, table, order session, time window, and use count.
   특허1: 단회성 비상태형 토큰으로 외부 POS에 실제 고객 식별자 미노출.';
comment on column catchmenu_gateway.gateway_sessions.token_scope is
  'Json object defining what this token is authorized for.
   e.g. {"store_id": "...", "table_id": "...",
         "allowed_operations": ["order_submit", "payment_request"],
         "max_amount": 100000}';
comment on column catchmenu_gateway.gateway_sessions.token_max_use is
  'Default 1 = single use token. Token is invalidated after first use.
   Higher values allowed for specific session types like webhook listeners.';

-- ===== END sql/migrations/0009_create_gateway_provider_events.sql =====


-- ===== BEGIN sql/migrations/0019_create_knowledge_runtime.sql =====

-- 0019_create_knowledge_runtime.sql
-- Purpose: Operational knowledge runtime. SOP, Policy, Checklist,
--          Runbook, Incident Guide storage and versioning.
--          Knowledge is generated from operational events,
--          validated by governance agent, and published after human approval.
--          특허3 core: 자가진화형 운영 지식 생성 시스템.
-- Depends on: 0018_create_agent_actions_approvals.sql
-- Creates:
--   catchmenu_knowledge.documents
--   catchmenu_knowledge.document_versions
--   catchmenu_knowledge.knowledge_gaps

create table if not exists catchmenu_knowledge.documents (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references catchmenu_hq.tenants(id),
  store_id uuid references catchmenu_hq.stores(id),

  -- document identity
  document_code text not null,
  document_type text not null,
  document_scope text not null default 'STORE',
  document_status text not null default 'DRAFT',

  -- content
  title text not null,
  summary text,
  content text not null,
  content_locale text not null default 'ko',

  -- classification
  domain text not null,
  tags jsonb not null default '[]'::jsonb,
  applies_to_exception_types jsonb,
  applies_to_device_types jsonb,

  -- versioning
  current_version int not null default 1,
  current_version_id uuid,

  -- origin
  -- 특허3: 이벤트에서 자동 생성된 문서인지 수동 작성인지 구분
  origin_type text not null default 'MANUAL',
  generated_by_agent_id uuid
    references catchmenu_store.agent_registry(id),
  generated_from_exception_id uuid
    references catchmenu_ledger.exceptions(id),
  generated_from_gap_id uuid,

  -- approval
  approved_by_id uuid,
  approved_at timestamptz,
  published_at timestamptz,

  -- ai retrieval boundary
  -- 특허3: 내부 운영 지식 외부 미노출 구조
  is_ai_retrievable boolean not null default false,
  ai_retrieval_scope text,
  requires_context_builder boolean not null default true,

  -- feedback
  usage_count int not null default 0,
  effectiveness_score int,
  last_used_at timestamptz,
  last_reviewed_at timestamptz,
  review_due_at timestamptz,

  -- retention
  expires_at timestamptz,
  is_active boolean not null default true,

  constraint uq_knowledge_document_code unique (tenant_id, document_code),
  constraint chk_doc_type check (
    document_type in (
      'SOP',
      'POLICY',
      'CHECKLIST',
      'RUNBOOK',
      'INCIDENT_GUIDE',
      'DECISION_RECORD',
      'WORK_PACKAGE',
      'TRAINING_GUIDE',
      'FAQ'
    )
  ),
  constraint chk_doc_scope check (
    document_scope in (
      'GLOBAL',
      'TENANT',
      'STORE',
      'ROLE',
      'DEVICE_TYPE'
    )
  ),
  constraint chk_doc_status check (
    document_status in (
      'DRAFT',
      'UNDER_REVIEW',
      'APPROVED',
      'PUBLISHED',
      'SUPERSEDED',
      'ARCHIVED',
      'REJECTED'
    )
  ),
  constraint chk_doc_origin check (
    origin_type in (
      'MANUAL',
      'AGENT_GENERATED',
      'AI_GENERATED',
      'IMPORTED',
      'TEMPLATE_DERIVED'
    )
  ),
  constraint chk_doc_domain check (
    domain in (
      'order', 'payment', 'kds', 'session',
      'delivery', 'inventory', 'staff',
      'device', 'agent', 'recovery',
      'customer', 'security', 'system'
    )
  ),
  constraint chk_doc_tags_array check (
    jsonb_typeof(tags) = 'array'
  ),
  constraint chk_doc_effectiveness check (
    effectiveness_score is null
    or effectiveness_score between 0 and 100
  ),
  constraint chk_doc_ai_scope check (
    ai_retrieval_scope is null or ai_retrieval_scope in (
      'CUSTOMER_FACING',
      'STAFF_FACING',
      'SUPPORT_FACING',
      'INTERNAL_ONLY'
    )
  )
);

create index if not exists idx_knowledge_docs_tenant_type
  on catchmenu_knowledge.documents(tenant_id, document_type, document_status);

create index if not exists idx_knowledge_docs_store
  on catchmenu_knowledge.documents(store_id, document_status)
  where store_id is not null;

create index if not exists idx_knowledge_docs_domain
  on catchmenu_knowledge.documents(domain, document_status)
  where is_active = true;

create index if not exists idx_knowledge_docs_ai_retrievable
  on catchmenu_knowledge.documents(tenant_id, is_ai_retrievable)
  where is_ai_retrievable = true
    and document_status = 'PUBLISHED';

create index if not exists idx_knowledge_docs_review_due
  on catchmenu_knowledge.documents(review_due_at)
  where review_due_at is not null
    and document_status = 'PUBLISHED'
    and is_active = true;

comment on table catchmenu_knowledge.documents is
  'Operational knowledge document registry.
   Documents are generated from operational events by SOP Evolution Agent
   or written manually. All documents go through governance validation
   and human approval before publication.
   특허3: 운영 지식 비공개 응답 구조.
   고객/직원은 내부 SOP 원문에 직접 접근하지 않는다.
   Internal Knowledge → Context Builder → AI Response Generator → External Response.';
comment on column catchmenu_knowledge.documents.origin_type is
  'MANUAL = written by human operator.
   AGENT_GENERATED = drafted by SOP Evolution Agent from event patterns.
   AI_GENERATED = drafted by AI from knowledge gap analysis.
   IMPORTED = brought in from external source.
   TEMPLATE_DERIVED = created from existing template.
   특허3: 운영 이벤트 → Knowledge Gap 탐지 → SOP 초안 자동 생성.';
comment on column catchmenu_knowledge.documents.is_ai_retrievable is
  'True when this document can be retrieved by AI for response generation.
   False = internal only, not retrievable by any AI component.
   특허3: AI는 승인된 출처 추적 가능 콘텐츠에서만 검색.';
comment on column catchmenu_knowledge.documents.requires_context_builder is
  'True = AI must use Context Builder Agent to access this document.
   Raw document content is never exposed directly to AI engine.
   특허3: AI Engine은 직접 DB를 탐색하지 않으며
          Context Builder Agent가 생성한 컨텍스트를 기반으로 동작.';


create table if not exists catchmenu_knowledge.document_versions (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references catchmenu_hq.tenants(id),
  document_id uuid not null references catchmenu_knowledge.documents(id),

  version_number int not null,
  version_status text not null default 'DRAFT',

  -- content snapshot
  title_snapshot text not null,
  content_snapshot text not null,
  change_summary text,
  change_reason text,

  -- origin
  origin_type text not null default 'MANUAL',
  generated_by_agent_id uuid
    references catchmenu_store.agent_registry(id),
  generated_from_exception_id uuid
    references catchmenu_ledger.exceptions(id),

  -- governance validation
  governance_checked boolean not null default false,
  governance_checked_at timestamptz,
  governance_issues jsonb,
  duplicate_check_passed boolean,
  link_check_passed boolean,
  rule_check_passed boolean,

  -- approval
  submitted_for_review_at timestamptz,
  reviewed_by_id uuid,
  reviewed_at timestamptz,
  approved_by_id uuid,
  approved_at timestamptz,
  rejection_reason text,

  -- publish
  published_at timestamptz,
  superseded_at timestamptz,
  superseded_by_version_id uuid
    references catchmenu_knowledge.document_versions(id),

  -- feedback loop
  -- 특허3: 생성→검증→저장→운영반영→추가이벤트→지식개선→재반영
  applied_count int not null default 0,
  success_count int not null default 0,
  failure_count int not null default 0,
  feedback_events jsonb,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint uq_document_version unique (document_id, version_number),
  constraint chk_version_status check (
    version_status in (
      'DRAFT',
      'GOVERNANCE_REVIEW',
      'UNDER_REVIEW',
      'APPROVED',
      'PUBLISHED',
      'SUPERSEDED',
      'REJECTED'
    )
  ),
  constraint chk_version_origin check (
    origin_type in (
      'MANUAL',
      'AGENT_GENERATED',
      'AI_GENERATED',
      'IMPORTED',
      'TEMPLATE_DERIVED'
    )
  ),
  constraint chk_governance_issues_object check (
    governance_issues is null
    or jsonb_typeof(governance_issues) = 'object'
  ),
  constraint chk_feedback_events_array check (
    feedback_events is null
    or jsonb_typeof(feedback_events) = 'array'
  ),
  constraint chk_applied_counts check (
    applied_count >= 0
    and success_count >= 0
    and failure_count >= 0
    and applied_count >= success_count + failure_count
  )
);

create index if not exists idx_doc_versions_document
  on catchmenu_knowledge.document_versions(document_id, version_number desc);

create index if not exists idx_doc_versions_status
  on catchmenu_knowledge.document_versions(version_status, created_at desc);

create index if not exists idx_doc_versions_pending_review
  on catchmenu_knowledge.document_versions(submitted_for_review_at)
  where version_status in ('GOVERNANCE_REVIEW', 'UNDER_REVIEW')
    and submitted_for_review_at is not null;

drop trigger if exists trg_doc_versions_updated_at
  on catchmenu_knowledge.document_versions;
create trigger trg_doc_versions_updated_at
  before update on catchmenu_knowledge.document_versions
  for each row execute function catchmenu_common.set_updated_at();

comment on table catchmenu_knowledge.document_versions is
  'Document version history. Every change creates a new version.
   Governance Agent validates each version before human review.
   Feedback loop tracks how many times each version was applied
   and whether it succeeded or failed.
   특허3: 자동 피드백 반영 구조.
   생성→검증→저장→운영반영→추가이벤트수집→지식개선→재반영.';
comment on column catchmenu_knowledge.document_versions.governance_issues is
  'Issues found by Governance Agent during validation.
   e.g. {"duplicate_found": "DOC-002", "broken_link": "SOP-003",
          "numbering_conflict": true}
   특허3: Governance Agent — 번호추천, 중복검사, 링크검사, 문서규칙검사.';
comment on column catchmenu_knowledge.document_versions.feedback_events is
  'Array of feedback events from operational use.
   Each entry records: applied_at, outcome, exception_context.
   Used by SOP Evolution Agent to determine if version needs improvement.';


create table if not exists catchmenu_knowledge.knowledge_gaps (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references catchmenu_hq.tenants(id),
  store_id uuid references catchmenu_hq.stores(id),

  -- gap identity
  gap_type text not null,
  gap_status text not null default 'DETECTED',
  domain text not null,

  -- what triggered detection
  -- 특허3: Knowledge Gap Detection Agent
  triggering_exception_type text,
  triggering_exception_ids jsonb,
  occurrence_count int not null default 1,
  first_detected_at timestamptz not null default now(),
  last_detected_at timestamptz not null default now(),
  detection_threshold int not null default 3,
  threshold_reached_at timestamptz,

  -- gap detail
  gap_summary text not null,
  gap_context jsonb not null default '{}'::jsonb,
  existing_document_id uuid references catchmenu_knowledge.documents(id),
  existing_document_inadequacy text,

  -- evolution
  -- 특허3: SOP Evolution Agent 실행
  evolution_agent_id uuid references catchmenu_store.agent_registry(id),
  evolution_started_at timestamptz,
  evolution_completed_at timestamptz,
  generated_document_id uuid references catchmenu_knowledge.documents(id),
  generated_version_id uuid
    references catchmenu_knowledge.document_versions(id),

  -- resolution
  resolved_at timestamptz,
  resolution_type text,

  -- correlation
  correlation_id text,
  business_day date not null,
  business_timezone text not null default 'Asia/Seoul',

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint chk_gap_type check (
    gap_type in (
      'MISSING_SOP',
      'INADEQUATE_SOP',
      'MISSING_POLICY',
      'MISSING_RUNBOOK',
      'MISSING_INCIDENT_GUIDE',
      'OUTDATED_DOCUMENT',
      'COVERAGE_GAP',
      'REPEATED_EXCEPTION_NO_SOP'
    )
  ),
  constraint chk_gap_status check (
    gap_status in (
      'DETECTED',
      'CONFIRMED',
      'EVOLUTION_QUEUED',
      'EVOLVING',
      'DRAFT_GENERATED',
      'RESOLVED',
      'DISMISSED'
    )
  ),
  constraint chk_gap_domain check (
    domain in (
      'order', 'payment', 'kds', 'session',
      'delivery', 'inventory', 'staff',
      'device', 'agent', 'recovery',
      'customer', 'security', 'system'
    )
  ),
  constraint chk_gap_context_object check (
    jsonb_typeof(gap_context) = 'object'
  ),
  constraint chk_gap_exception_ids_array check (
    triggering_exception_ids is null
    or jsonb_typeof(triggering_exception_ids) = 'array'
  ),
  constraint chk_gap_occurrence check (occurrence_count >= 1),
  constraint chk_gap_resolution check (
    resolution_type is null or resolution_type in (
      'NEW_DOCUMENT_PUBLISHED',
      'EXISTING_DOCUMENT_UPDATED',
      'GAP_INVALID_DISMISSED',
      'MANUAL_RESOLUTION'
    )
  )
);

create index if not exists idx_knowledge_gaps_store_status
  on catchmenu_knowledge.knowledge_gaps(store_id, gap_status)
  where store_id is not null;

create index if not exists idx_knowledge_gaps_tenant_domain
  on catchmenu_knowledge.knowledge_gaps(tenant_id, domain, gap_status);

create index if not exists idx_knowledge_gaps_threshold
  on catchmenu_knowledge.knowledge_gaps(tenant_id, occurrence_count desc)
  where gap_status in ('DETECTED', 'CONFIRMED')
    and threshold_reached_at is null;

create index if not exists idx_knowledge_gaps_evolution
  on catchmenu_knowledge.knowledge_gaps(gap_status, evolution_started_at)
  where gap_status in ('EVOLUTION_QUEUED', 'EVOLVING');

drop trigger if exists trg_knowledge_gaps_updated_at
  on catchmenu_knowledge.knowledge_gaps;
create trigger trg_knowledge_gaps_updated_at
  before update on catchmenu_knowledge.knowledge_gaps
  for each row execute function catchmenu_common.set_updated_at();

comment on table catchmenu_knowledge.knowledge_gaps is
  'Knowledge gap registry. Detected when operational exceptions
   occur repeatedly without a corresponding SOP or policy.
   특허3 핵심 처리 흐름:
   운영 이벤트 발생 → Knowledge Gap Detection → 지식 공백 탐지
   → Event Store 기록 → 반복 발생 분석 → Threshold 도달
   → SOP Evolution Agent 실행 → 운영 지식 초안 생성
   → Governance 검증 → 승인 → Knowledge Runtime 저장
   → 운영 시스템 자동 반영.';
comment on column catchmenu_knowledge.knowledge_gaps.detection_threshold is
  'Number of occurrences before SOP Evolution Agent is triggered.
   Default 3. CRITICAL exceptions may use threshold 1.
   특허3: 반복 발생 분석 → Threshold 도달 → Agent 실행.';
comment on column catchmenu_knowledge.knowledge_gaps.existing_document_inadequacy is
  'Why existing document is inadequate for this exception pattern.
   Used by SOP Evolution Agent to focus improvement areas.';

-- ===== END sql/migrations/0019_create_knowledge_runtime.sql =====
