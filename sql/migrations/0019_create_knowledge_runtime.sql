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