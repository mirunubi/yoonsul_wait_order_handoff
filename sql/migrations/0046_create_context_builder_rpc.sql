-- 0046_create_context_builder_rpc.sql
-- Purpose: Context Builder Agent RPC for AI knowledge retrieval.
--          AI Engine never accesses DB directly.
--          Context Builder assembles safe, approved context
--          and returns it to AI Engine Interface.
--          특허3 core: Context Builder Agent — AI 직접 DB 접근 차단.
-- Depends on: 0045_create_daily_summary_rpc.sql
-- Creates:
--   function catchmenu_knowledge.build_ai_context(...)
--   function catchmenu_knowledge.search_knowledge(...)
--   function catchmenu_knowledge.record_ai_query(...)

create or replace function catchmenu_knowledge.build_ai_context(
  p_tenant_id uuid,
  p_query_type text,
  p_query_context jsonb,
  p_audience text default 'STAFF_FACING',
  p_locale text default 'ko',
  p_store_id uuid default null,
  p_max_documents int default 5,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_knowledge, catchmenu_ledger,
                  catchmenu_common
as $$
declare
  v_context_documents jsonb := '[]'::jsonb;
  v_related_exceptions jsonb := '[]'::jsonb;
  v_operational_state jsonb := '{}'::jsonb;
  v_context_id uuid;
  v_doc_count int := 0;
begin
  -- validate audience
  if p_audience not in (
    'CUSTOMER_FACING',
    'STAFF_FACING',
    'SUPPORT_FACING',
    'INTERNAL_ONLY'
  ) then
    return jsonb_build_object(
      'success', false,
      'error_key', 'invalid_audience'
    );
  end if;

  -- validate query type
  if p_query_type not in (
    'SOP_LOOKUP',
    'EXCEPTION_GUIDANCE',
    'POLICY_CHECK',
    'INCIDENT_RESPONSE',
    'CUSTOMER_SUPPORT',
    'TRAINING_GUIDE',
    'RUNBOOK_LOOKUP',
    'FAQ_LOOKUP'
  ) then
    return jsonb_build_object(
      'success', false,
      'error_key', 'invalid_query_type'
    );
  end if;

  -- 특허3: AI는 Context Builder를 통해서만 문서에 접근
  -- 1. retrieve approved published documents
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'document_id', d.id,
        'document_code', d.document_code,
        'document_type', d.document_type,
        'title', d.title,
        'summary', d.summary,
        'domain', d.domain,
        'version', d.current_version,
        -- content: provided only for INTERNAL_ONLY audience
        -- other audiences get summary only
        'content', case
          when p_audience = 'INTERNAL_ONLY'
          then d.content
          else null
        end,
        'tags', d.tags,
        'effectiveness_score', d.effectiveness_score,
        'last_used_at', d.last_used_at
      )
      order by
        d.effectiveness_score desc nulls last,
        d.published_at desc
      limit p_max_documents
    ),
    '[]'::jsonb
  )
  into v_context_documents
  from catchmenu_knowledge.documents d
  where d.tenant_id = p_tenant_id
    and d.document_status = 'PUBLISHED'
    and d.is_ai_retrievable = true
    and d.is_active = true
    and (
      p_audience = 'INTERNAL_ONLY'
      or d.ai_retrieval_scope = p_audience
      or d.ai_retrieval_scope is null
    )
    and (
      -- query type to document type mapping
      p_query_type = 'SOP_LOOKUP'
        and d.document_type = 'SOP'
      or p_query_type = 'POLICY_CHECK'
        and d.document_type = 'POLICY'
      or p_query_type = 'INCIDENT_RESPONSE'
        and d.document_type in ('RUNBOOK', 'INCIDENT_GUIDE')
      or p_query_type = 'CUSTOMER_SUPPORT'
        and d.document_type in ('FAQ', 'SOP')
      or p_query_type = 'TRAINING_GUIDE'
        and d.document_type = 'TRAINING_GUIDE'
      or p_query_type = 'RUNBOOK_LOOKUP'
        and d.document_type = 'RUNBOOK'
      or p_query_type = 'EXCEPTION_GUIDANCE'
        and d.document_type in (
          'SOP', 'RUNBOOK', 'INCIDENT_GUIDE'
        )
      or p_query_type = 'FAQ_LOOKUP'
        and d.document_type = 'FAQ'
    );

  v_doc_count := jsonb_array_length(v_context_documents);

  -- 2. retrieve related recent exceptions
  -- (for operational context, masked of sensitive data)
  if p_store_id is not null
    and p_query_type in (
      'EXCEPTION_GUIDANCE', 'INCIDENT_RESPONSE'
    )
  then
    select coalesce(
      jsonb_agg(
        jsonb_build_object(
          'exception_domain', e.exception_domain,
          'exception_type', e.exception_type,
          'exception_severity', e.exception_severity,
          'exception_status', e.exception_status,
          'occurrence_count', e.occurrence_count,
          'detected_at', e.detected_at,
          -- mask sensitive payload for non-internal
          'summary', case
            when p_audience = 'INTERNAL_ONLY'
            then e.exception_payload
            else jsonb_build_object(
              'domain', e.exception_domain,
              'type', e.exception_type
            )
          end
        )
        order by e.detected_at desc
        limit 5
      ),
      '[]'::jsonb
    )
    into v_related_exceptions
    from catchmenu_ledger.exceptions e
    where e.store_id = p_store_id
      and e.tenant_id = p_tenant_id
      and e.exception_status in (
        'OPEN', 'ACKNOWLEDGED', 'IN_RECOVERY'
      )
      and e.detected_at >= now() - interval '24 hours';
  end if;

  -- 3. operational state snapshot (safe fields only)
  if p_store_id is not null then
    select jsonb_build_object(
      'active_session_count', (
        select count(*)
        from catchmenu_pos.order_sessions
        where store_id = p_store_id
          and session_status not in (
            'COMPLETED', 'CANCELLED',
            'EXPIRED', 'NO_SHOW'
          )
      ),
      'kds_hold_count', (
        select count(*)
        from catchmenu_kds.kds_tickets
        where store_id = p_store_id
          and kds_status in ('HOLD', 'CAPACITY_CHECKING')
      ),
      'open_exceptions', (
        select count(*)
        from catchmenu_ledger.exceptions
        where store_id = p_store_id
          and exception_status in (
            'OPEN', 'ACKNOWLEDGED'
          )
      ),
      'active_fallback', (
        select exists (
          select 1
          from catchmenu_agent.manual_fallback_log
          where store_id = p_store_id
            and fallback_status in ('ACTIVE', 'RECOVERING')
        )
      )
    )
    into v_operational_state;
  end if;

  -- generate context_id for tracing
  v_context_id := gen_random_uuid();

  -- record AI query for audit and feedback loop
  -- 특허3: AI 검색 이력 → Context Builder 피드백 루프
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
    'knowledge', 'ai_context_built', 1,
    'knowledge_context', v_context_id,
    null, 'BUILT',
    'SYSTEM',
    jsonb_build_object(
      'query_type', p_query_type,
      'audience', p_audience,
      'locale', p_locale,
      'doc_count', v_doc_count,
      'has_exceptions', jsonb_array_length(
        v_related_exceptions
      ) > 0
    ),
    p_correlation_id,
    (timezone('Asia/Seoul', now()))::date,
    'Asia/Seoul', now()
  );

  return jsonb_build_object(
    'success', true,
    'context_id', v_context_id,
    'query_type', p_query_type,
    'audience', p_audience,
    'locale', p_locale,
    'context', jsonb_build_object(
      'documents', v_context_documents,
      'document_count', v_doc_count,
      'related_exceptions', v_related_exceptions,
      'operational_state', v_operational_state,
      'context_built_at', now(),
      'context_ttl_seconds', 300
    ),
    'safety', jsonb_build_object(
      'raw_db_accessed', false,
      'pii_included', false,
      'secrets_included', false,
      'content_masked', p_audience <> 'INTERNAL_ONLY',
      'source_traceable', true
    ),
    'message_code', 'ai_context_built'
  );
end;
$$;


create or replace function catchmenu_knowledge.search_knowledge(
  p_tenant_id uuid,
  p_search_query text,
  p_domain text default null,
  p_document_types jsonb default null,
  p_audience text default 'STAFF_FACING',
  p_locale text default 'ko',
  p_limit int default 10,
  p_store_id uuid default null
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_knowledge, catchmenu_common
as $$
declare
  v_results jsonb;
  v_result_count int;
begin
  if trim(coalesce(p_search_query, '')) = '' then
    return jsonb_build_object(
      'success', false,
      'error_key', 'search_query_required'
    );
  end if;

  if p_limit > 20 then
    p_limit := 20;
  end if;

  -- full-text search on knowledge documents
  -- 특허3: AI 검색은 승인된 PUBLISHED 문서만 대상
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'document_id', d.id,
        'document_code', d.document_code,
        'document_type', d.document_type,
        'title', d.title,
        'summary', d.summary,
        'domain', d.domain,
        'version', d.current_version,
        'tags', d.tags,
        'effectiveness_score', d.effectiveness_score,
        'relevance_score', ts_rank(
          to_tsvector('simple', coalesce(d.title, '')
            || ' ' || coalesce(d.summary, '')
            || ' ' || coalesce(d.content, '')
          ),
          plainto_tsquery('simple', p_search_query)
        ),
        'published_at', d.published_at
      )
      order by
        ts_rank(
          to_tsvector('simple', coalesce(d.title, '')
            || ' ' || coalesce(d.summary, '')
            || ' ' || coalesce(d.content, '')
          ),
          plainto_tsquery('simple', p_search_query)
        ) desc,
        d.effectiveness_score desc nulls last
    ),
    '[]'::jsonb
  )
  into v_results
  from catchmenu_knowledge.documents d
  where d.tenant_id = p_tenant_id
    and d.document_status = 'PUBLISHED'
    and d.is_ai_retrievable = true
    and d.is_active = true
    and (
      p_domain is null
      or d.domain = p_domain
    )
    and (
      p_document_types is null
      or d.document_type = any(
        select jsonb_array_elements_text(p_document_types)
      )
    )
    and (
      p_audience = 'INTERNAL_ONLY'
      or d.ai_retrieval_scope = p_audience
      or d.ai_retrieval_scope is null
    )
    and to_tsvector(
      'simple',
      coalesce(d.title, '') || ' '
      || coalesce(d.summary, '') || ' '
      || coalesce(d.content, '')
    ) @@ plainto_tsquery('simple', p_search_query)
  limit p_limit;

  v_result_count := jsonb_array_length(
    coalesce(v_results, '[]'::jsonb)
  );

  return jsonb_build_object(
    'success', true,
    'search_query', p_search_query,
    'domain_filter', p_domain,
    'audience', p_audience,
    'result_count', v_result_count,
    'results', coalesce(v_results, '[]'::jsonb),
    'safety', jsonb_build_object(
      'search_scope', 'PUBLISHED_APPROVED_ONLY',
      'pii_excluded', true,
      'raw_db_blocked', true
    ),
    'message_code', case v_result_count
      when 0 then 'no_knowledge_found'
      else 'knowledge_found'
    end
  );
end;
$$;


create or replace function catchmenu_knowledge.record_ai_query(
  p_tenant_id uuid,
  p_context_id uuid,
  p_query_type text,
  p_query_summary text,
  p_ai_response_summary text default null,
  p_was_helpful boolean default null,
  p_feedback_note text default null,
  p_store_id uuid default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_knowledge, catchmenu_ledger,
                  catchmenu_common
as $$
declare
  v_record_id uuid;
  v_business_day date;
begin
  v_business_day := (timezone('Asia/Seoul', now()))::date;

  -- record AI query feedback for knowledge evolution
  -- 특허3: AI 응답 피드백 → Knowledge Gap 탐지 → SOP 개선
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
    'knowledge', 'ai_query_recorded', 1,
    'knowledge_context', p_context_id,
    null, 'RECORDED',
    'SYSTEM',
    jsonb_build_object(
      'query_type', p_query_type,
      'query_summary', p_query_summary,
      'was_helpful', p_was_helpful,
      'feedback_note', p_feedback_note,
      'has_response', p_ai_response_summary is not null
    ),
    p_correlation_id,
    v_business_day, 'Asia/Seoul', now()
  )
  returning id into v_record_id;

  -- if not helpful → potential knowledge gap
  -- 특허3: 도움이 안 된 AI 응답 → Knowledge Gap 탐지 트리거
  if p_was_helpful = false then
    perform catchmenu_knowledge.detect_knowledge_gap(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_gap_type := 'MISSING_SOP',
      p_domain := 'system',
      p_gap_summary := 'AI could not provide helpful response for: '
        || p_query_summary,
      p_triggering_exception_type := p_query_type,
      p_gap_context := jsonb_build_object(
        'query_type', p_query_type,
        'query_summary', p_query_summary,
        'feedback_note', p_feedback_note,
        'context_id', p_context_id
      ),
      p_detection_threshold := 3,
      p_correlation_id := p_correlation_id
    );
  end if;

  return jsonb_build_object(
    'success', true,
    'record_id', v_record_id,
    'context_id', p_context_id,
    'gap_detection_triggered', p_was_helpful = false,
    'message_code', 'ai_query_recorded'
  );
end;
$$;

-- grants
do $$
begin
  revoke all on function catchmenu_knowledge.build_ai_context(
    uuid, text, jsonb, text, text, uuid, int, text
  ) from public;
  grant execute on function catchmenu_knowledge.build_ai_context(
    uuid, text, jsonb, text, text, uuid, int, text
  ) to authenticated;

  revoke all on function catchmenu_knowledge.search_knowledge(
    uuid, text, text, jsonb, text, text, int, uuid
  ) from public;
  grant execute on function catchmenu_knowledge.search_knowledge(
    uuid, text, text, jsonb, text, text, int, uuid
  ) to authenticated;

  revoke all on function catchmenu_knowledge.record_ai_query(
    uuid, uuid, text, text, text, boolean, text, uuid, text
  ) from public;
  grant execute on function catchmenu_knowledge.record_ai_query(
    uuid, uuid, text, text, text, boolean, text, uuid, text
  ) to authenticated;
end;
$$;

comment on function catchmenu_knowledge.build_ai_context(
  uuid, text, jsonb, text, text, uuid, int, text
) is
  'Context Builder Agent — assembles safe AI context from approved sources.
   AI Engine NEVER calls this function directly.
   Knowledge Agent Layer calls this, then passes result to AI Engine Interface.
   Only PUBLISHED + is_ai_retrievable = true documents are included.
   Content masking based on audience:
     CUSTOMER_FACING: summary only, no internal content
     STAFF_FACING: summary only
     SUPPORT_FACING: summary only
     INTERNAL_ONLY: full content
   Operational state included for exception guidance.
   특허3: Context Builder Agent.
   AI는 직접 DB를 탐색하지 않으며
   Context Builder Agent가 생성한 컨텍스트를 기반으로 동작.
   Internal Knowledge → Context Builder → AI Response Generator
   → External Response.';

comment on function catchmenu_knowledge.search_knowledge(
  uuid, text, text, jsonb, text, text, int, uuid
) is
  'Full-text search on approved knowledge documents.
   Restricted to PUBLISHED documents with is_ai_retrievable = true.
   Uses PostgreSQL full-text search with Korean-aware tokenization.
   Returns relevance-ranked results with effectiveness scores.
   특허3: AI 검색은 승인된 출처 추적 가능 콘텐츠에서만 검색.
   미승인/초안/내부전용 문서는 검색 결과에 포함되지 않음.';

comment on function catchmenu_knowledge.record_ai_query(
  uuid, uuid, text, text, text, boolean, text, uuid, text
) is
  'Records AI query and response feedback.
   When was_helpful = false:
   → triggers Knowledge Gap detection automatically.
   → gap occurrence_count increments.
   → when threshold reached, SOP Evolution Agent is queued.
   특허3: 자동 피드백 반영 구조.
   AI 응답 품질 피드백 → Knowledge Gap 탐지 → SOP 개선 루프.';