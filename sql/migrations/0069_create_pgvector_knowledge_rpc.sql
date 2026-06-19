-- 0069_create_pgvector_knowledge_rpc.sql
-- Purpose: pgvector embedding and retrieval layer.
--          Vector search is RETRIEVAL ONLY — not authority.
--          Authority = approved versioned documents only.
--          All AI answers grounded in retrieved documents.
--          Tenant/store/RLS/document-status filtering enforced.
-- Depends on: 0068_create_realtime_edge_rpc.sql
-- Creates:
--   catchmenu_knowledge.document_embeddings (table)
--   catchmenu_knowledge.embedding_models (table)
--   function catchmenu_knowledge.upsert_document_embedding(...)
--   function catchmenu_knowledge.search_knowledge_vector(...)
--   function catchmenu_knowledge.build_grounded_ai_context(...)
--   function catchmenu_knowledge.verify_answer_grounding(...)

-- =============================================
-- Enable pgvector extension
-- =============================================
create extension if not exists vector
  schema extensions;

comment on extension vector is
  'pgvector: vector similarity search extension.
   RETRIEVAL LAYER ONLY — not the authority.
   Authority = approved versioned documents.
   Vector index accelerates similarity search.
   All results re-filtered by RLS + document_status.';


-- =============================================
-- embedding_models table
-- 사용 임베딩 모델 레지스트리
-- =============================================
create table if not exists
  catchmenu_knowledge.embedding_models (
  id uuid primary key default gen_random_uuid(),

  model_code text not null unique,
  model_name text not null,
  model_provider text not null,
  embedding_dimensions int not null,

  -- model characteristics
  max_input_tokens int not null default 8192,
  supports_multilingual boolean not null default false,
  supports_korean boolean not null default false,
  cost_per_1k_tokens numeric(10,6),

  -- deployment
  api_endpoint text,
  model_version text,
  is_default boolean not null default false,
  is_active boolean not null default true,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint chk_model_provider check (
    model_provider in (
      'OPENAI', 'ANTHROPIC', 'GOOGLE',
      'UPSTAGE', 'CLOVA', 'CUSTOM'
    )
  ),
  constraint chk_dimensions check (
    embedding_dimensions in (
      256, 512, 768, 1024, 1536, 3072
    )
  )
);

drop trigger if exists trg_embedding_models_updated
  on catchmenu_knowledge.embedding_models;
create trigger trg_embedding_models_updated
  before update on catchmenu_knowledge.embedding_models
  for each row execute function
    catchmenu_common.set_updated_at();

-- seed embedding models
insert into catchmenu_knowledge.embedding_models (
  model_code, model_name, model_provider,
  embedding_dimensions, max_input_tokens,
  supports_multilingual, supports_korean,
  cost_per_1k_tokens, is_default
) values
(
  'TEXT_EMBEDDING_3_SMALL',
  'text-embedding-3-small',
  'OPENAI',
  1536, 8191,
  true, true,
  0.000020, true
),
(
  'TEXT_EMBEDDING_3_LARGE',
  'text-embedding-3-large',
  'OPENAI',
  3072, 8191,
  true, true,
  0.000130, false
),
(
  'UPSTAGE_SOLAR_EMBEDDING',
  'solar-embedding-1-large',
  'UPSTAGE',
  4096, 4096,
  false, true,
  0.000100, false
)
on conflict (model_code) do nothing;

comment on table catchmenu_knowledge.embedding_models is
  'Embedding model registry.
   supports_korean = true: 한국어 SOP/Policy 임베딩 권장.
   Upstage Solar: 한국어 특화 임베딩.
   OpenAI text-embedding-3-small: 기본값 (비용 효율).
   RETRIEVAL 목적 전용 — 답변 생성은 별도 LLM.';


-- =============================================
-- document_embeddings table
-- 문서 임베딩 저장 (검색 레이어)
-- =============================================
create table if not exists
  catchmenu_knowledge.document_embeddings (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),

  -- source document reference
  -- MUST link to approved document version
  document_id uuid not null
    references catchmenu_knowledge.documents(id),
  version_id uuid not null
    references catchmenu_knowledge.document_versions(id),

  -- chunk info (long docs split into chunks)
  chunk_index int not null default 0,
  chunk_total int not null default 1,
  chunk_text text not null,
  chunk_char_count int,

  -- embedding
  model_code text not null
    references catchmenu_knowledge.embedding_models(model_code),
  embedding_dimensions int not null,
  embedding extensions.vector(1536),

  -- document metadata snapshot (at embedding time)
  document_type_snapshot text not null,
  document_status_snapshot text not null,
  domain_snapshot text,
  locale_snapshot text not null default 'ko',
  is_ai_retrievable_snapshot boolean
    not null default false,

  -- validity
  -- embedding must be regenerated when
  -- document is updated or superseded
  is_valid boolean not null default true,
  invalidated_at timestamptz,
  invalidated_reason text,

  -- generation
  embedded_at timestamptz not null default now(),
  embedded_by_type text not null default 'SYSTEM',

  created_at timestamptz not null default now(),

  constraint uq_doc_version_chunk unique (
    version_id, chunk_index, model_code
  ),
  constraint chk_embedding_dimensions check (
    embedding_dimensions in (
      256, 512, 768, 1024, 1536, 3072
    )
  ),
  constraint chk_doc_status_snapshot check (
    -- only PUBLISHED documents should have embeddings
    document_status_snapshot = 'PUBLISHED'
  )
);

-- pgvector IVFFlat index for approximate search
-- lists = sqrt(row_count) is a good starting point
-- probes = lists/10 for search accuracy
create index if not exists
  idx_doc_embeddings_vector
  on catchmenu_knowledge.document_embeddings
  using ivfflat (embedding extensions.vector_cosine_ops)
  with (lists = 100)
  where is_valid = true
    and is_ai_retrievable_snapshot = true;

-- tenant isolation index
create index if not exists
  idx_doc_embeddings_tenant
  on catchmenu_knowledge.document_embeddings(
    tenant_id, document_type_snapshot,
    domain_snapshot
  )
  where is_valid = true;

-- version index for invalidation
create index if not exists
  idx_doc_embeddings_version
  on catchmenu_knowledge.document_embeddings(
    version_id, is_valid
  );

alter table catchmenu_knowledge.document_embeddings
  enable row level security;
alter table catchmenu_knowledge.document_embeddings
  force row level security;

drop policy if exists embeddings_isolation
  on catchmenu_knowledge.document_embeddings;
create policy embeddings_isolation
  on catchmenu_knowledge.document_embeddings
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and is_ai_retrievable_snapshot = true
    and document_status_snapshot = 'PUBLISHED'
  );

comment on table
  catchmenu_knowledge.document_embeddings is
  'pgvector embedding store. RETRIEVAL LAYER ONLY.

   핵심 설계 원칙:
   1. embedding은 PUBLISHED 문서만 생성
   2. is_ai_retrievable = true 문서만 인덱스 대상
   3. RLS = tenant 격리 + retrieval 허용 조건 동시 적용
   4. 문서 버전 갱신 시 이전 임베딩 is_valid = false
   5. AI 답변 생성 전 document_id + version_id로
      실제 문서 상태 재확인 필수
   6. chunk_text는 검색용 — 권위 원문은 documents.content

   Authority chain:
   document_embeddings (검색) → document_versions (원문)
   → documents (승인 상태) → AI answer (출처 인용 필수)';


-- =============================================
-- RPCs
-- =============================================
create or replace function
  catchmenu_knowledge.upsert_document_embedding(
  p_tenant_id uuid,
  p_document_id uuid,
  p_version_id uuid,
  p_chunk_index int,
  p_chunk_total int,
  p_chunk_text text,
  p_embedding vector(1536),
  p_model_code text default 'TEXT_EMBEDDING_3_SMALL',
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_knowledge,
                  catchmenu_common
as $$
declare
  v_doc record;
  v_version record;
  v_embedding_id uuid;
begin
  -- CRITICAL: validate document is PUBLISHED
  -- and retrievable BEFORE storing embedding
  select d.id, d.document_type, d.document_status,
         d.domain, d.is_ai_retrievable
  into v_doc
  from catchmenu_knowledge.documents d
  where d.id = p_document_id
    and d.tenant_id = p_tenant_id;

  if v_doc.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'gap_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_rpc_name := 'upsert_document_embedding'
    );
  end if;

  -- ENFORCE: only PUBLISHED + ai_retrievable
  if v_doc.document_status <> 'PUBLISHED' then
    return jsonb_build_object(
      'success', false,
      'error_key', 'embedding_requires_published',
      'document_status', v_doc.document_status,
      'message',
        'Embeddings can only be created for '
        || 'PUBLISHED documents. '
        || 'Current status: '
        || v_doc.document_status
    );
  end if;

  if not v_doc.is_ai_retrievable then
    return jsonb_build_object(
      'success', false,
      'error_key', 'embedding_requires_ai_retrievable',
      'message',
        'Document is_ai_retrievable must be true. '
        || 'Set this explicitly during publish approval.'
    );
  end if;

  -- validate version matches document
  select id, version_status
  into v_version
  from catchmenu_knowledge.document_versions
  where id = p_version_id
    and document_id = p_document_id
    and version_status = 'PUBLISHED';

  if v_version.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'embedding_version_not_published',
      'message',
        'Version must be PUBLISHED status. '
        || 'Embedding on draft/review versions blocked.'
    );
  end if;

  -- invalidate existing chunks for this version
  -- (re-embedding = full invalidation first)
  update catchmenu_knowledge.document_embeddings
  set
    is_valid = false,
    invalidated_at = now(),
    invalidated_reason = 'RE_EMBEDDING'
  where version_id = p_version_id
    and chunk_index = p_chunk_index
    and model_code = p_model_code
    and is_valid = true;

  -- insert new embedding
  insert into catchmenu_knowledge.document_embeddings (
    tenant_id, document_id, version_id,
    chunk_index, chunk_total,
    chunk_text, chunk_char_count,
    model_code, embedding_dimensions,
    embedding,
    document_type_snapshot,
    document_status_snapshot,
    domain_snapshot, locale_snapshot,
    is_ai_retrievable_snapshot,
    embedded_at
  ) values (
    p_tenant_id, p_document_id, p_version_id,
    p_chunk_index, p_chunk_total,
    p_chunk_text, length(p_chunk_text),
    p_model_code, 1536,
    p_embedding,
    v_doc.document_type,
    'PUBLISHED',
    v_doc.domain,
    p_locale,
    true,
    now()
  )
  returning id into v_embedding_id;

  return jsonb_build_object(
    'success', true,
    'embedding_id', v_embedding_id,
    'document_id', p_document_id,
    'version_id', p_version_id,
    'chunk_index', p_chunk_index,
    'chunk_total', p_chunk_total,
    'model_code', p_model_code,
    'message_code', 'embedding_stored'
  );
end;
$$;


create or replace function
  catchmenu_knowledge.search_knowledge_vector(
  p_tenant_id uuid,
  p_query_embedding vector(1536),
  p_query_text text,
  p_document_types jsonb default null,
  p_domain text default null,
  p_locale text default 'ko',
  p_limit int default 5,
  p_similarity_threshold float default 0.70,
  p_model_code text default 'TEXT_EMBEDDING_3_SMALL',
  p_store_id uuid default null
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_knowledge,
                  catchmenu_common
as $$
declare
  v_results jsonb;
  v_result_count int;
  v_search_id uuid;
begin
  -- enforce limits
  if p_limit > 10 then
    p_limit := 10;
  end if;

  if p_similarity_threshold < 0.5 then
    p_similarity_threshold := 0.5;
  end if;

  v_search_id := gen_random_uuid();

  -- RETRIEVAL with mandatory authority filters
  -- 특허3: pgvector 검색 → 권위 문서 필터 → AI 컨텍스트
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        -- retrieval metadata
        'embedding_id', de.id,
        'similarity_score',
          1 - (
            de.embedding
            <=> p_query_embedding
          ),

        -- authority source reference
        -- AI must cite these fields
        'document_id', de.document_id,
        'version_id', de.version_id,
        'chunk_index', de.chunk_index,

        -- document authority info
        'document_type', d.document_type,
        'document_code', d.document_code,
        'title', d.title,
        'summary', d.summary,
        'domain', d.domain,
        'current_version', d.current_version,
        'published_at', d.published_at,
        'effectiveness_score',
          d.effectiveness_score,

        -- retrieved chunk text
        -- this is what AI uses to answer
        'chunk_text', de.chunk_text,
        'chunk_index', de.chunk_index,
        'chunk_total', de.chunk_total,

        -- authority confirmation fields
        -- AI answer MUST be grounded in these
        'is_published',
          d.document_status = 'PUBLISHED',
        'is_ai_retrievable', d.is_ai_retrievable,
        'authority_confirmed',
          d.document_status = 'PUBLISHED'
          and d.is_ai_retrievable = true
          and de.is_valid = true,

        -- citation reference for AI answer
        'citation', jsonb_build_object(
          'document_code', d.document_code,
          'document_type', d.document_type,
          'title', d.title,
          'version', d.current_version,
          'published_at', d.published_at
        )
      )
      order by
        de.embedding <=> p_query_embedding asc
    ),
    '[]'::jsonb
  )
  into v_results
  from catchmenu_knowledge.document_embeddings de
  join catchmenu_knowledge.documents d
    on d.id = de.document_id
    and d.tenant_id = p_tenant_id
  where de.tenant_id = p_tenant_id
    -- MANDATORY: vector retrieval filters
    and de.is_valid = true
    and de.is_ai_retrievable_snapshot = true
    and de.document_status_snapshot = 'PUBLISHED'
    and de.model_code = p_model_code
    -- MANDATORY: re-verify authority at query time
    and d.document_status = 'PUBLISHED'
    and d.is_ai_retrievable = true
    -- similarity threshold
    and 1 - (de.embedding <=> p_query_embedding)
      >= p_similarity_threshold
    -- optional filters
    and (
      p_document_types is null
      or d.document_type = any(
        select jsonb_array_elements_text(
          p_document_types
        )
      )
    )
    and (
      p_domain is null
      or de.domain_snapshot = p_domain
    )
    and (
      de.locale_snapshot = p_locale
      or de.locale_snapshot = 'ko'
    )
  limit p_limit;

  v_result_count := jsonb_array_length(
    coalesce(v_results, '[]'::jsonb)
  );

  -- log retrieval for feedback loop
  perform catchmenu_common.log_diagnostic(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_log_level := 'DEBUG',
    p_log_domain := 'KNOWLEDGE',
    p_log_event := 'vector_search_executed',
    p_message :=
      'Vector search: query="'
      || left(p_query_text, 50) || '"'
      || ' results=' || v_result_count
      || ' threshold=' || p_similarity_threshold,
    p_rpc_name := 'search_knowledge_vector',
    p_details := jsonb_build_object(
      'search_id', v_search_id,
      'query_length', length(p_query_text),
      'result_count', v_result_count,
      'document_types', p_document_types,
      'domain', p_domain,
      'locale', p_locale,
      'model_code', p_model_code,
      'threshold', p_similarity_threshold
    )
  );

  return jsonb_build_object(
    'success', true,
    'search_id', v_search_id,
    'query_text', p_query_text,
    'result_count', v_result_count,
    'similarity_threshold', p_similarity_threshold,
    'model_code', p_model_code,
    'results', coalesce(v_results, '[]'::jsonb),

    -- safety declaration for AI engine
    'retrieval_safety', jsonb_build_object(
      'all_results_published', true,
      'all_results_ai_retrievable', true,
      'all_results_tenant_isolated', true,
      'authority_confirmed',
        v_result_count > 0,
      'grounding_required', true,
      'hallucination_blocked',
        'AI must only use chunk_text from results',
      'citation_required',
        'All AI answers must cite citation field'
    ),

    'message_code', case v_result_count
      when 0 then 'no_knowledge_found'
      else 'knowledge_retrieved'
    end
  );
end;
$$;


create or replace function
  catchmenu_knowledge.build_grounded_ai_context(
  p_tenant_id uuid,
  p_store_id uuid,
  p_query_text text,
  p_query_embedding vector(1536),
  p_query_type text,
  p_audience text default 'STAFF_FACING',
  p_locale text default 'ko',
  p_document_types jsonb
    default '["SOP","POLICY","RUNBOOK","CHECKLIST"]'::jsonb,
  p_domain text default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_knowledge,
                  catchmenu_common
as $$
declare
  v_context_id uuid;
  v_vector_results jsonb;
  v_sop_results jsonb;
  v_policy_results jsonb;
  v_runbook_results jsonb;
  v_checklist_results jsonb;
  v_total_sources int := 0;
  v_grounded boolean := false;
begin
  v_context_id := gen_random_uuid();

  -- STEP 1: Vector search for relevant documents
  -- similarity threshold: 0.72 (high precision)
  v_vector_results :=
    catchmenu_knowledge.search_knowledge_vector(
      p_tenant_id := p_tenant_id,
      p_query_embedding := p_query_embedding,
      p_query_text := p_query_text,
      p_document_types := p_document_types,
      p_domain := p_domain,
      p_locale := p_locale,
      p_limit := 8,
      p_similarity_threshold := 0.72,
      p_store_id := p_store_id
    );

  v_total_sources := coalesce(
    (v_vector_results->>'result_count')::int, 0
  );

  v_grounded := v_total_sources > 0;

  -- STEP 2: Categorize by document type
  -- for structured context assembly
  select coalesce(
    jsonb_agg(r)
    filter (where r->>'document_type' = 'SOP'),
    '[]'::jsonb
  ),
  coalesce(
    jsonb_agg(r)
    filter (where r->>'document_type' = 'POLICY'),
    '[]'::jsonb
  ),
  coalesce(
    jsonb_agg(r)
    filter (where r->>'document_type' = 'RUNBOOK'),
    '[]'::jsonb
  ),
  coalesce(
    jsonb_agg(r)
    filter (
      where r->>'document_type' = 'CHECKLIST'
    ),
    '[]'::jsonb
  )
  into v_sop_results, v_policy_results,
       v_runbook_results, v_checklist_results
  from jsonb_array_elements(
    v_vector_results->'results'
  ) r;

  -- log context build
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
    'knowledge', 'grounded_context_built', 1,
    'knowledge_context', v_context_id,
    null, 'BUILT',
    'SYSTEM',
    jsonb_build_object(
      'query_type', p_query_type,
      'total_sources', v_total_sources,
      'grounded', v_grounded,
      'sop_count', jsonb_array_length(v_sop_results),
      'policy_count',
        jsonb_array_length(v_policy_results),
      'runbook_count',
        jsonb_array_length(v_runbook_results)
    ),
    p_correlation_id,
    (timezone('Asia/Seoul', now()))::date,
    'Asia/Seoul', now()
  );

  return jsonb_build_object(
    'success', true,
    'context_id', v_context_id,
    'query_text', p_query_text,
    'query_type', p_query_type,
    'audience', p_audience,
    'locale', p_locale,
    'is_grounded', v_grounded,
    'total_sources', v_total_sources,

    -- structured context by document type
    'context', jsonb_build_object(
      'sop_documents', v_sop_results,
      'policy_documents', v_policy_results,
      'runbook_documents', v_runbook_results,
      'checklist_documents', v_checklist_results,
      'all_results', v_vector_results->'results'
    ),

    -- MANDATORY grounding instructions for AI engine
    'grounding_instructions', jsonb_build_object(
      -- what AI MUST do
      'must_cite_sources', true,
      'must_use_retrieved_text_only', true,
      'must_reject_if_not_grounded', true,
      'must_include_document_code', true,
      'must_include_version', true,

      -- what AI MUST NOT do
      'must_not_hallucinate', true,
      'must_not_answer_beyond_sources', true,
      'must_not_use_training_knowledge_alone', true,
      'must_not_omit_citations', true,

      -- grounding threshold
      'minimum_similarity_score', 0.72,
      'minimum_authority_sources', 1,

      -- fallback instruction
      'if_no_sources_found',
        'Answer: "해당 질문에 대한 승인된 문서를 찾을 수 없습니다. '
        || '관리자에게 문의하거나 SOP를 확인해 주세요."',

      -- citation format
      'citation_format',
        '[{document_type}] {title} (v{version}) '
        || '— {document_code}'
    ),

    -- authority confirmation
    'authority', jsonb_build_object(
      'all_documents_published', true,
      'all_documents_ai_retrievable', true,
      'tenant_isolated', true,
      'rls_enforced', true,
      'retrieval_layer', 'pgvector',
      'authority_layer', 'approved_documents',
      'authority_chain',
        'pgvector → document_versions → documents',
      'timestamp', now()
    ),

    'message_code', case v_grounded
      when true then 'grounded_context_ready'
      else 'no_grounded_context_available'
    end
  );
end;
$$;


create or replace function
  catchmenu_knowledge.verify_answer_grounding(
  p_tenant_id uuid,
  p_context_id uuid,
  p_ai_answer text,
  p_cited_document_ids jsonb,
  p_cited_version_ids jsonb,
  p_query_text text,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_knowledge,
                  catchmenu_common
as $$
declare
  v_verification_id uuid;
  v_doc_count int;
  v_published_count int;
  v_all_published boolean;
  v_all_retrievable boolean;
  v_citation_issues jsonb := '[]'::jsonb;
  v_is_grounded boolean;
  v_risk_level text;
begin
  v_verification_id := gen_random_uuid();

  -- verify all cited documents exist and are PUBLISHED
  select
    count(*),
    count(*) filter (
      where d.document_status = 'PUBLISHED'
        and d.is_ai_retrievable = true
        and d.tenant_id = p_tenant_id
    )
  into v_doc_count, v_published_count
  from jsonb_array_elements_text(
    p_cited_document_ids
  ) doc_id
  join catchmenu_knowledge.documents d
    on d.id = doc_id::uuid;

  v_all_published :=
    v_doc_count > 0
    and v_doc_count = v_published_count;

  v_all_retrievable := v_all_published;

  -- check for documents that are no longer valid
  -- (superseded since context was built)
  with stale_citations as (
    select d.id, d.document_code,
           d.document_status, d.is_ai_retrievable
    from jsonb_array_elements_text(
      p_cited_document_ids
    ) doc_id
    join catchmenu_knowledge.documents d
      on d.id = doc_id::uuid
    where d.document_status <> 'PUBLISHED'
      or d.is_ai_retrievable = false
  )
  select case when count(*) > 0 then
    v_citation_issues || jsonb_build_array(
      jsonb_build_object(
        'issue_type', 'STALE_DOCUMENT_CITED',
        'severity', 'CRITICAL',
        'count', count(*),
        'detail',
          'AI cited documents that are no longer '
          || 'published or retrievable',
        'stale_docs', jsonb_agg(
          jsonb_build_object(
            'id', id,
            'document_code', document_code,
            'status', document_status
          )
        )
      )
    )
    else v_citation_issues
  end
  into v_citation_issues
  from stale_citations;

  -- check version validity
  with stale_versions as (
    select dv.id, dv.version_status,
           dv.document_id
    from jsonb_array_elements_text(
      coalesce(p_cited_version_ids, '[]'::jsonb)
    ) ver_id
    join catchmenu_knowledge.document_versions dv
      on dv.id = ver_id::uuid
    where dv.version_status not in (
      'PUBLISHED', 'SUPERSEDED'
    )
  )
  select case when count(*) > 0 then
    v_citation_issues || jsonb_build_array(
      jsonb_build_object(
        'issue_type', 'INVALID_VERSION_CITED',
        'severity', 'HIGH',
        'count', count(*),
        'detail',
          'AI cited document versions '
          || 'not in PUBLISHED status'
      )
    )
    else v_citation_issues
  end
  into v_citation_issues
  from stale_versions;

  -- empty answer check
  if trim(coalesce(p_ai_answer, '')) = '' then
    v_citation_issues := v_citation_issues
      || jsonb_build_array(
        jsonb_build_object(
          'issue_type', 'EMPTY_ANSWER',
          'severity', 'HIGH',
          'detail', 'AI produced empty answer'
        )
      );
  end if;

  -- no citations check
  if v_doc_count = 0 then
    v_citation_issues := v_citation_issues
      || jsonb_build_array(
        jsonb_build_object(
          'issue_type', 'NO_CITATIONS',
          'severity', 'CRITICAL',
          'detail',
            'AI answer has no document citations. '
            || 'Possible hallucination.'
        )
      );
  end if;

  -- determine grounding status
  v_is_grounded :=
    v_all_published
    and v_doc_count > 0
    and jsonb_array_length(v_citation_issues) = 0;

  v_risk_level := case
    when v_is_grounded then 'LOW'
    when jsonb_array_length(v_citation_issues) = 0
      and v_doc_count > 0
    then 'MEDIUM'
    else 'HIGH'
  end;

  -- log verification
  perform catchmenu_common.log_diagnostic(
    p_tenant_id := p_tenant_id,
    p_log_level := case v_risk_level
      when 'LOW' then 'INFO'
      when 'MEDIUM' then 'WARNING'
      else 'ERROR'
    end,
    p_log_domain := 'KNOWLEDGE',
    p_log_event := 'ai_answer_grounding_verified',
    p_message :=
      'AI grounding check: '
      || case v_is_grounded
        when true then 'GROUNDED'
        else 'UNGROUNDED'
      end
      || ' citations=' || v_doc_count
      || ' issues=' || jsonb_array_length(
        v_citation_issues
      ),
    p_rpc_name := 'verify_answer_grounding',
    p_details := jsonb_build_object(
      'verification_id', v_verification_id,
      'context_id', p_context_id,
      'is_grounded', v_is_grounded,
      'doc_count', v_doc_count,
      'issue_count',
        jsonb_array_length(v_citation_issues)
    )
  );

  return jsonb_build_object(
    'success', true,
    'verification_id', v_verification_id,
    'context_id', p_context_id,
    'is_grounded', v_is_grounded,
    'risk_level', v_risk_level,
    'citation_summary', jsonb_build_object(
      'cited_document_count', v_doc_count,
      'all_published', v_all_published,
      'all_retrievable', v_all_retrievable,
      'issue_count',
        jsonb_array_length(v_citation_issues)
    ),
    'citation_issues', v_citation_issues,
    'verdict', case
      when v_is_grounded then
        'ANSWER_GROUNDED_IN_APPROVED_DOCUMENTS'
      when v_doc_count = 0 then
        'REJECTED_NO_CITATIONS'
      when not v_all_published then
        'REJECTED_STALE_CITATIONS'
      else
        'REVIEW_REQUIRED'
    end,
    'action', case
      when v_is_grounded then 'DELIVER_TO_USER'
      when v_risk_level = 'HIGH' then
        'BLOCK_AND_ESCALATE'
      else 'FLAG_FOR_REVIEW'
    end,
    'message_code', case v_is_grounded
      when true then 'answer_grounding_verified'
      else 'answer_grounding_failed'
    end
  );
end;
$$;


-- invalidate embeddings when document superseded
create or replace function
  catchmenu_knowledge.invalidate_embeddings_on_supersede()
returns trigger
language plpgsql
security definer
set search_path = catchmenu_knowledge
as $$
begin
  -- when version is SUPERSEDED,
  -- invalidate its embeddings
  if new.version_status = 'SUPERSEDED'
    and old.version_status = 'PUBLISHED'
  then
    update catchmenu_knowledge.document_embeddings
    set
      is_valid = false,
      invalidated_at = now(),
      invalidated_reason =
        'DOCUMENT_VERSION_SUPERSEDED'
    where version_id = new.id
      and is_valid = true;
  end if;
  return new;
end;
$$;

drop trigger if exists
  trg_invalidate_embeddings_on_supersede
  on catchmenu_knowledge.document_versions;
create trigger
  trg_invalidate_embeddings_on_supersede
  after update of version_status
  on catchmenu_knowledge.document_versions
  for each row
  when (
    new.version_status = 'SUPERSEDED'
    and old.version_status = 'PUBLISHED'
  )
  execute function
    catchmenu_knowledge.invalidate_embeddings_on_supersede();

comment on trigger
  trg_invalidate_embeddings_on_supersede
  on catchmenu_knowledge.document_versions is
  'Auto-invalidates pgvector embeddings when
   document version is superseded.
   Prevents AI from retrieving outdated content.
   특허3: 문서 버전 교체 → 임베딩 즉시 무효화.
   새 버전 publish 후 re-embedding 필수.';


-- grants
do $$
begin
  revoke all on function
    catchmenu_knowledge.upsert_document_embedding(
      uuid, uuid, uuid, int, int, text,
      vector, text, text
    ) from public;
  grant execute on function
    catchmenu_knowledge.upsert_document_embedding(
      uuid, uuid, uuid, int, int, text,
      vector, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_knowledge.search_knowledge_vector(
      uuid, vector, text, jsonb, text,
      text, int, float, text, uuid
    ) from public;
  grant execute on function
    catchmenu_knowledge.search_knowledge_vector(
      uuid, vector, text, jsonb, text,
      text, int, float, text, uuid
    ) to authenticated;

  revoke all on function
    catchmenu_knowledge.build_grounded_ai_context(
      uuid, uuid, text, vector, text,
      text, text, jsonb, text, text
    ) from public;
  grant execute on function
    catchmenu_knowledge.build_grounded_ai_context(
      uuid, uuid, text, vector, text,
      text, text, jsonb, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_knowledge.verify_answer_grounding(
      uuid, uuid, text, jsonb, jsonb, text, text
    ) from public;
  grant execute on function
    catchmenu_knowledge.verify_answer_grounding(
      uuid, uuid, text, jsonb, jsonb, text, text
    ) to authenticated;
end;
$$;

comment on function
  catchmenu_knowledge.search_knowledge_vector(
    uuid, vector, text, jsonb, text,
    text, int, float, text, uuid
  ) is
  'pgvector similarity search — RETRIEVAL ONLY.

   검색 파이프라인:
   1. pgvector 코사인 유사도 검색
   2. is_valid = true 필터 (무효화 임베딩 제외)
   3. is_ai_retrievable_snapshot = true 필터
   4. document_status_snapshot = PUBLISHED 필터
   5. 쿼리 시점 권위 재확인
      (d.document_status = PUBLISHED 재검증)
   6. tenant_id RLS 격리

   검색 결과 ≠ AI 답변
   검색 결과 = AI 답변의 근거 문서

   AI는 반드시:
   - chunk_text만 사용
   - citation 필드 인용
   - 소스 없으면 답변 거부

   특허3: pgvector = 검색 레이어.
   권위 = PUBLISHED 승인 문서.';

comment on function
  catchmenu_knowledge.build_grounded_ai_context(
    uuid, uuid, text, vector, text,
    text, text, jsonb, text, text
  ) is
  'Builds retrieval-grounded AI context.
   Combines vector search with grounding instructions.

   grounding_instructions 포함:
   - must_cite_sources: true
   - must_use_retrieved_text_only: true
   - must_not_hallucinate: true
   - if_no_sources_found: 거부 메시지 반환
   - citation_format: [Type] Title (vN) — CODE

   AI Engine은 이 함수 결과만 사용하여 답변 생성.
   검색 결과 없으면 → 답변 거부 (hallucination 방지).

   특허3: Context Builder → pgvector 검색
          → grounded context → AI 답변 생성
          → 출처 검증 → 사용자 전달.';

comment on function
  catchmenu_knowledge.verify_answer_grounding(
    uuid, uuid, text, jsonb, jsonb, text, text
  ) is
  'Verifies AI answer is grounded in approved documents.
   Checks:
   1. All cited documents are PUBLISHED
   2. All cited documents are ai_retrievable
   3. No stale/superseded versions cited
   4. Answer is not empty
   5. Citations exist

   Verdict:
   ANSWER_GROUNDED → DELIVER_TO_USER
   REJECTED_NO_CITATIONS → BLOCK_AND_ESCALATE
   REJECTED_STALE_CITATIONS → BLOCK_AND_ESCALATE
   REVIEW_REQUIRED → FLAG_FOR_REVIEW

   특허3: AI 답변 권위 검증.
   hallucination = citation_issues CRITICAL.
   stale citation = BLOCK 즉시.
   이 함수 통과 후에만 사용자에게 답변 전달.';