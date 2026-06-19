-- 0033_create_knowledge_gap_rpc.sql
-- Purpose: Knowledge gap detection and SOP evolution RPCs.
--          detect_knowledge_gap: detects missing or inadequate SOP.
--          trigger_sop_evolution: queues SOP draft generation.
--          publish_knowledge_document: publishes approved SOP to runtime.
--          특허3 core: 자가진화형 운영 지식 생성 시스템.
-- Depends on: 0032_create_agent_action_rpc.sql
-- Creates:
--   function catchmenu_knowledge.detect_knowledge_gap(...)
--   function catchmenu_knowledge.trigger_sop_evolution(...)
--   function catchmenu_knowledge.publish_knowledge_document(...)
--   function catchmenu_knowledge.record_sop_feedback(...)

create or replace function catchmenu_knowledge.detect_knowledge_gap(
  p_tenant_id uuid,
  p_store_id uuid,
  p_gap_type text,
  p_domain text,
  p_gap_summary text,
  p_triggering_exception_type text default null,
  p_triggering_exception_ids jsonb default null,
  p_gap_context jsonb default '{}'::jsonb,
  p_existing_document_id uuid default null,
  p_existing_document_inadequacy text default null,
  p_detection_threshold int default 3,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_knowledge, catchmenu_ledger,
                  catchmenu_common, catchmenu_hq
as $$
declare
  v_gap_id uuid;
  v_existing_gap_id uuid;
  v_occurrence_count int;
  v_threshold_reached boolean;
  v_business_day date;
  v_timezone text;
begin
  -- store timezone
  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = coalesce(p_store_id, p_tenant_id)
    and tenant_id = p_tenant_id
  limit 1;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  -- check existing open gap of same type and domain
  select id, occurrence_count
  into v_existing_gap_id, v_occurrence_count
  from catchmenu_knowledge.knowledge_gaps
  where tenant_id = p_tenant_id
    and gap_type = p_gap_type
    and domain = p_domain
    and coalesce(
      triggering_exception_type, ''
    ) = coalesce(p_triggering_exception_type, '')
    and gap_status not in ('RESOLVED', 'DISMISSED')
  limit 1
  for update skip locked;

  if v_existing_gap_id is not null then
    -- increment occurrence
    update catchmenu_knowledge.knowledge_gaps
    set
      occurrence_count = occurrence_count + 1,
      last_detected_at = now(),
      triggering_exception_ids = coalesce(
        triggering_exception_ids, '[]'::jsonb
      ) || coalesce(p_triggering_exception_ids, '[]'::jsonb),
      gap_context = gap_context || coalesce(
        p_gap_context, '{}'::jsonb
      ),
      threshold_reached_at = case
        when threshold_reached_at is null
          and (occurrence_count + 1) >= p_detection_threshold
        then now()
        else threshold_reached_at
      end,
      gap_status = case
        when gap_status = 'DETECTED'
          and (occurrence_count + 1) >= p_detection_threshold
        then 'CONFIRMED'
        else gap_status
      end,
      updated_at = now()
    where id = v_existing_gap_id
    returning occurrence_count, threshold_reached_at is not null
    into v_occurrence_count, v_threshold_reached;

    return jsonb_build_object(
      'success', true,
      'gap_id', v_existing_gap_id,
      'is_new', false,
      'occurrence_count', v_occurrence_count,
      'threshold_reached', v_threshold_reached,
      'evolution_recommended',
        v_occurrence_count >= p_detection_threshold,
      'message_code', case
        when v_occurrence_count >= p_detection_threshold
        then 'gap_threshold_reached_evolution_recommended'
        else 'gap_occurrence_incremented'
      end
    );
  end if;

  -- create new knowledge gap
  insert into catchmenu_knowledge.knowledge_gaps (
    tenant_id, store_id,
    gap_type, gap_status, domain,
    triggering_exception_type,
    triggering_exception_ids,
    occurrence_count,
    first_detected_at, last_detected_at,
    detection_threshold,
    gap_summary, gap_context,
    existing_document_id,
    existing_document_inadequacy,
    correlation_id,
    business_day, business_timezone
  ) values (
    p_tenant_id, p_store_id,
    p_gap_type, 'DETECTED', p_domain,
    p_triggering_exception_type,
    coalesce(p_triggering_exception_ids, '[]'::jsonb),
    1,
    now(), now(),
    p_detection_threshold,
    p_gap_summary,
    coalesce(p_gap_context, '{}'::jsonb),
    p_existing_document_id,
    p_existing_document_inadequacy,
    p_correlation_id,
    v_business_day,
    coalesce(v_timezone, 'Asia/Seoul')
  )
  returning id into v_gap_id;

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
    'knowledge', 'knowledge_gap_detected', 1,
    'knowledge_gap', v_gap_id,
    null, 'DETECTED',
    'SYSTEM',
    jsonb_build_object(
      'gap_type', p_gap_type,
      'domain', p_domain,
      'gap_summary', p_gap_summary,
      'detection_threshold', p_detection_threshold
    ),
    p_correlation_id,
    v_business_day,
    coalesce(v_timezone, 'Asia/Seoul'),
    now()
  );

  return jsonb_build_object(
    'success', true,
    'gap_id', v_gap_id,
    'is_new', true,
    'occurrence_count', 1,
    'threshold_reached', false,
    'evolution_recommended', false,
    'message_code', 'knowledge_gap_detected'
  );
end;
$$;


create or replace function catchmenu_knowledge.trigger_sop_evolution(
  p_tenant_id uuid,
  p_gap_id uuid,
  p_evolution_agent_id uuid,
  p_document_type text,
  p_document_title text,
  p_document_content text,
  p_domain text,
  p_change_summary text default null,
  p_store_id uuid default null,
  p_document_scope text default 'TENANT',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_knowledge, catchmenu_ledger,
                  catchmenu_common, catchmenu_hq
as $$
declare
  v_gap record;
  v_document_id uuid;
  v_version_id uuid;
  v_document_code text;
  v_business_day date;
  v_timezone text := 'Asia/Seoul';
begin
  -- validate gap
  select id, gap_type, domain, gap_summary,
         gap_status, existing_document_id
  into v_gap
  from catchmenu_knowledge.knowledge_gaps
  where id = p_gap_id
    and tenant_id = p_tenant_id
  for update;

  if v_gap.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'gap_not_found'
    );
  end if;

  if v_gap.gap_status in ('RESOLVED', 'DISMISSED') then
    return jsonb_build_object(
      'success', false,
      'error_key', 'gap_already_resolved',
      'current_status', v_gap.gap_status
    );
  end if;

  v_business_day := (timezone(v_timezone, now()))::date;

  -- generate document code
  v_document_code :=
    upper(substr(p_domain, 1, 3)) || '-' ||
    upper(substr(p_document_type, 1, 3)) || '-' ||
    extract(epoch from now())::bigint::text;

  -- check if updating existing document
  if v_gap.existing_document_id is not null then
    -- create new version of existing document
    select id into v_document_id
    from catchmenu_knowledge.documents
    where id = v_gap.existing_document_id
      and tenant_id = p_tenant_id;

    if v_document_id is not null then
      -- get next version number
      insert into catchmenu_knowledge.document_versions (
        tenant_id, document_id,
        version_number, version_status,
        title_snapshot, content_snapshot,
        change_summary, change_reason,
        origin_type, generated_by_agent_id,
        generated_from_exception_id,
        governance_checked,
        submitted_for_review_at
      )
      select
        p_tenant_id, v_document_id,
        coalesce(max(version_number), 0) + 1,
        'GOVERNANCE_REVIEW',
        p_document_title, p_document_content,
        p_change_summary,
        'Knowledge gap triggered evolution: ' || v_gap.gap_summary,
        'AGENT_GENERATED', p_evolution_agent_id,
        null,
        false,
        now()
      from catchmenu_knowledge.document_versions
      where document_id = v_document_id
      returning id into v_version_id;

      -- update gap status
      update catchmenu_knowledge.knowledge_gaps
      set
        gap_status = 'EVOLVING',
        evolution_agent_id = p_evolution_agent_id,
        evolution_started_at = now(),
        generated_document_id = v_document_id,
        generated_version_id = v_version_id,
        updated_at = now()
      where id = p_gap_id;

      return jsonb_build_object(
        'success', true,
        'gap_id', p_gap_id,
        'document_id', v_document_id,
        'version_id', v_version_id,
        'is_new_document', false,
        'document_status', 'GOVERNANCE_REVIEW',
        'message_code', 'sop_evolution_version_created'
      );
    end if;
  end if;

  -- create new document
  insert into catchmenu_knowledge.documents (
    tenant_id, store_id,
    document_code, document_type,
    document_scope, document_status,
    title, content,
    content_locale, domain,
    origin_type, generated_by_agent_id,
    generated_from_gap_id,
    is_ai_retrievable,
    requires_context_builder,
    current_version
  ) values (
    p_tenant_id, p_store_id,
    v_document_code, p_document_type,
    p_document_scope, 'DRAFT',
    p_document_title, p_document_content,
    'ko', p_domain,
    'AGENT_GENERATED', p_evolution_agent_id,
    p_gap_id,
    false,
    true,
    1
  )
  returning id into v_document_id;

  -- create first version
  insert into catchmenu_knowledge.document_versions (
    tenant_id, document_id,
    version_number, version_status,
    title_snapshot, content_snapshot,
    change_summary, change_reason,
    origin_type, generated_by_agent_id,
    governance_checked,
    submitted_for_review_at
  ) values (
    p_tenant_id, v_document_id,
    1, 'GOVERNANCE_REVIEW',
    p_document_title, p_document_content,
    p_change_summary,
    'Auto-generated from knowledge gap: ' || v_gap.gap_summary,
    'AGENT_GENERATED', p_evolution_agent_id,
    false,
    now()
  )
  returning id into v_version_id;

  -- update document with version id
  update catchmenu_knowledge.documents
  set current_version_id = v_version_id,
      updated_at = now()
  where id = v_document_id;

  -- update gap status
  update catchmenu_knowledge.knowledge_gaps
  set
    gap_status = 'DRAFT_GENERATED',
    evolution_agent_id = p_evolution_agent_id,
    evolution_started_at = now(),
    evolution_completed_at = now(),
    generated_document_id = v_document_id,
    generated_version_id = v_version_id,
    updated_at = now()
  where id = p_gap_id;

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
    'knowledge', 'sop_draft_generated', 1,
    'knowledge_document', v_document_id,
    null, 'GOVERNANCE_REVIEW',
    'AGENT', p_evolution_agent_id,
    jsonb_build_object(
      'gap_id', p_gap_id,
      'document_code', v_document_code,
      'document_type', p_document_type,
      'domain', p_domain,
      'is_new_document', true
    ),
    p_correlation_id,
    v_business_day, v_timezone, now()
  );

  return jsonb_build_object(
    'success', true,
    'gap_id', p_gap_id,
    'document_id', v_document_id,
    'version_id', v_version_id,
    'document_code', v_document_code,
    'is_new_document', true,
    'document_status', 'GOVERNANCE_REVIEW',
    'next_step', 'GOVERNANCE_VALIDATION_REQUIRED',
    'message_code', 'sop_draft_generated'
  );
end;
$$;


create or replace function catchmenu_knowledge.publish_knowledge_document(
  p_tenant_id uuid,
  p_version_id uuid,
  p_approved_by_id uuid,
  p_is_ai_retrievable boolean default false,
  p_ai_retrieval_scope text default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_knowledge, catchmenu_ledger,
                  catchmenu_audit, catchmenu_common
as $$
declare
  v_version record;
  v_document record;
  v_audit_id uuid;
begin
  -- version validation
  select dv.id, dv.document_id, dv.version_number,
         dv.version_status, dv.title_snapshot,
         dv.governance_checked,
         dv.generated_from_exception_id
  into v_version
  from catchmenu_knowledge.document_versions dv
  where dv.id = p_version_id
    and dv.tenant_id = p_tenant_id
  for update;

  if v_version.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'version_not_found'
    );
  end if;

  if v_version.version_status not in (
    'GOVERNANCE_REVIEW', 'UNDER_REVIEW', 'APPROVED'
  ) then
    return jsonb_build_object(
      'success', false,
      'error_key', 'version_not_publishable',
      'current_status', v_version.version_status
    );
  end if;

  if not v_version.governance_checked then
    return jsonb_build_object(
      'success', false,
      'error_key', 'governance_check_required',
      'message', 'Version must pass governance validation before publishing'
    );
  end if;

  -- supersede previous published version
  update catchmenu_knowledge.document_versions
  set
    version_status = 'SUPERSEDED',
    superseded_at = now(),
    superseded_by_version_id = p_version_id,
    updated_at = now()
  where document_id = v_version.document_id
    and version_status = 'PUBLISHED'
    and id <> p_version_id;

  -- publish version
  update catchmenu_knowledge.document_versions
  set
    version_status = 'PUBLISHED',
    approved_by_id = p_approved_by_id,
    approved_at = now(),
    published_at = now(),
    updated_at = now()
  where id = p_version_id;

  -- update document
  update catchmenu_knowledge.documents
  set
    document_status = 'PUBLISHED',
    current_version = v_version.version_number,
    current_version_id = p_version_id,
    is_ai_retrievable = p_is_ai_retrievable,
    ai_retrieval_scope = p_ai_retrieval_scope,
    approved_by_id = p_approved_by_id,
    approved_at = now(),
    published_at = now(),
    last_reviewed_at = now(),
    review_due_at = now() + interval '90 days',
    updated_at = now()
  where id = v_version.document_id
  returning id, document_code, document_type, domain
  into v_document.id, v_document.document_code,
       v_document.document_type, v_document.domain;

  -- resolve related knowledge gap
  update catchmenu_knowledge.knowledge_gaps
  set
    gap_status = 'RESOLVED',
    resolved_at = now(),
    resolution_type = 'NEW_DOCUMENT_PUBLISHED',
    updated_at = now()
  where generated_document_id = v_version.document_id
    and gap_status not in ('RESOLVED', 'DISMISSED');

  -- ledger event
  insert into catchmenu_ledger.events (
    tenant_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, caused_by_id,
    event_payload, correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id,
    'knowledge', 'knowledge_document_published', 1,
    'knowledge_document', v_version.document_id,
    'UNDER_REVIEW', 'PUBLISHED',
    'MANAGER', p_approved_by_id,
    jsonb_build_object(
      'document_id', v_version.document_id,
      'version_id', p_version_id,
      'version_number', v_version.version_number,
      'is_ai_retrievable', p_is_ai_retrievable,
      'ai_retrieval_scope', p_ai_retrieval_scope
    ),
    p_correlation_id,
    (timezone('Asia/Seoul', now()))::date,
    'Asia/Seoul', now()
  );

  -- audit
  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := null,
    p_audit_domain := 'knowledge',
    p_audit_type := 'knowledge_document_published',
    p_audit_category := 'KNOWLEDGE',
    p_actor_type := 'MANAGER',
    p_actor_id := p_approved_by_id,
    p_subject_type := 'knowledge_document',
    p_subject_id := v_version.document_id,
    p_decision := 'APPROVED',
    p_decision_payload := jsonb_build_object(
      'version_id', p_version_id,
      'version_number', v_version.version_number,
      'is_ai_retrievable', p_is_ai_retrievable,
      'ai_retrieval_scope', p_ai_retrieval_scope
    ),
    p_before_state := jsonb_build_object(
      'document_status', 'UNDER_REVIEW'
    ),
    p_after_state := jsonb_build_object(
      'document_status', 'PUBLISHED',
      'is_ai_retrievable', p_is_ai_retrievable
    ),
    p_correlation_id := p_correlation_id,
    p_business_day := (timezone('Asia/Seoul', now()))::date,
    p_business_timezone := 'Asia/Seoul'
  );

  return jsonb_build_object(
    'success', true,
    'document_id', v_version.document_id,
    'version_id', p_version_id,
    'version_number', v_version.version_number,
    'document_status', 'PUBLISHED',
    'is_ai_retrievable', p_is_ai_retrievable,
    'ai_retrieval_scope', p_ai_retrieval_scope,
    'gap_resolved', true,
    'audit_id', v_audit_id,
    'message_code', 'knowledge_document_published'
  );
end;
$$;


create or replace function catchmenu_knowledge.record_sop_feedback(
  p_tenant_id uuid,
  p_version_id uuid,
  p_outcome text,
  p_exception_context jsonb default null,
  p_feedback_note text default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_knowledge, catchmenu_common
as $$
declare
  v_version record;
begin
  if p_outcome not in ('SUCCESS', 'FAILURE', 'PARTIAL') then
    return jsonb_build_object(
      'success', false,
      'error_key', 'invalid_outcome'
    );
  end if;

  select id, document_id, version_status,
         applied_count, success_count, failure_count
  into v_version
  from catchmenu_knowledge.document_versions
  where id = p_version_id
    and tenant_id = p_tenant_id
  for update;

  if v_version.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'version_not_found'
    );
  end if;

  -- update feedback counts
  update catchmenu_knowledge.document_versions
  set
    applied_count = applied_count + 1,
    success_count = success_count + case
      when p_outcome = 'SUCCESS' then 1 else 0
    end,
    failure_count = failure_count + case
      when p_outcome = 'FAILURE' then 1 else 0
    end,
    feedback_events = coalesce(feedback_events, '[]'::jsonb)
      || jsonb_build_array(
        jsonb_build_object(
          'applied_at', now(),
          'outcome', p_outcome,
          'exception_context', p_exception_context,
          'feedback_note', p_feedback_note
        )
      ),
    updated_at = now()
  where id = p_version_id;

  -- update document usage stats
  update catchmenu_knowledge.documents
  set
    usage_count = usage_count + 1,
    last_used_at = now(),
    effectiveness_score = (
      select case
        when (applied_count + 1) = 0 then null
        else (
          (success_count + case
            when p_outcome = 'SUCCESS' then 1 else 0
          end)::float
          / (applied_count + 1) * 100
        )::int
      end
      from catchmenu_knowledge.document_versions
      where id = p_version_id
    ),
    updated_at = now()
  where id = v_version.document_id;

  return jsonb_build_object(
    'success', true,
    'version_id', p_version_id,
    'outcome', p_outcome,
    'applied_count', v_version.applied_count + 1,
    'success_count', v_version.success_count + case
      when p_outcome = 'SUCCESS' then 1 else 0
    end,
    'failure_count', v_version.failure_count + case
      when p_outcome = 'FAILURE' then 1 else 0
    end,
    'message_code', 'sop_feedback_recorded'
  );
end;
$$;

-- grants
do $$
begin
  revoke all on function catchmenu_knowledge.detect_knowledge_gap(
    uuid, uuid, text, text, text, text, jsonb,
    jsonb, uuid, text, int, text
  ) from public;
  grant execute on function catchmenu_knowledge.detect_knowledge_gap(
    uuid, uuid, text, text, text, text, jsonb,
    jsonb, uuid, text, int, text
  ) to authenticated;

  revoke all on function catchmenu_knowledge.trigger_sop_evolution(
    uuid, uuid, uuid, text, text, text,
    text, text, uuid, text, text
  ) from public;
  grant execute on function catchmenu_knowledge.trigger_sop_evolution(
    uuid, uuid, uuid, text, text, text,
    text, text, uuid, text, text
  ) to authenticated;

  revoke all on function catchmenu_knowledge.publish_knowledge_document(
    uuid, uuid, uuid, boolean, text, text
  ) from public;
  grant execute on function catchmenu_knowledge.publish_knowledge_document(
    uuid, uuid, uuid, boolean, text, text
  ) to authenticated;

  revoke all on function catchmenu_knowledge.record_sop_feedback(
    uuid, uuid, text, jsonb, text, text
  ) from public;
  grant execute on function catchmenu_knowledge.record_sop_feedback(
    uuid, uuid, text, jsonb, text, text
  ) to authenticated;
end;
$$;

comment on function catchmenu_knowledge.detect_knowledge_gap(
  uuid, uuid, text, text, text, text, jsonb,
  jsonb, uuid, text, int, text
) is
  'Detects or increments knowledge gap.
   When occurrence_count reaches detection_threshold:
   → gap_status DETECTED → CONFIRMED
   → evolution_recommended = true
   → SOP Evolution Agent should be triggered.
   특허3: 반복 발생 분석 → Threshold 도달 → SOP Evolution Agent 실행.';

comment on function catchmenu_knowledge.trigger_sop_evolution(
  uuid, uuid, uuid, text, text, text,
  text, text, uuid, text, text
) is
  'Triggers SOP draft generation from knowledge gap.
   Creates new document or new version of existing document.
   Draft enters GOVERNANCE_REVIEW status.
   Governance Agent validates before human review.
   특허3: SOP Evolution Agent → 운영 지식 초안 생성
          → Governance 검증 → 승인 → Knowledge Runtime 저장.';

comment on function catchmenu_knowledge.publish_knowledge_document(
  uuid, uuid, uuid, boolean, text, text
) is
  'Publishes approved knowledge document to operational runtime.
   Governance check must pass before publishing.
   Supersedes previous published version automatically.
   Sets is_ai_retrievable based on approval decision.
   Resolves related knowledge gap automatically.
   특허3: 승인 → Knowledge Runtime 저장 → 운영 시스템 자동 반영.
   AI는 Context Builder를 통해서만 접근.
   내부 SOP 원문은 외부에 직접 노출하지 않음.';

comment on function catchmenu_knowledge.record_sop_feedback(
  uuid, uuid, text, jsonb, text, text
) is
  'Records outcome feedback when SOP is applied to a real exception.
   Updates effectiveness_score on parent document.
   Feeds SOP Evolution Agent with performance data.
   특허3: 자동 피드백 반영 구조.
   생성→검증→저장→운영반영→추가이벤트수집→지식개선→재반영.';