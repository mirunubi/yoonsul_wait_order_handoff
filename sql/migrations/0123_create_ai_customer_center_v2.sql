-- 0123_create_ai_customer_center_v2.sql
-- Purpose: AI customer center enhancement.
--          RAG 파이프라인 고도화.
--          Digital SOP 자가 진화.
--          고객 문의 자동 분류.
--          반복 문의 패턴 탐지.
--          AI 답변 신뢰도 검증.
--          i18n: 모든 메시지 = message_catalog.
-- Depends on: 0122_create_coupon_pipeline_rpc.sql

insert into catchmenu_common.message_catalog (
  message_key, locale, message_text
) values
('inquiry_submitted', 'ko',
  '문의가 접수되었습니다'),
('inquiry_submitted', 'en',
  'Inquiry submitted'),
('ai_answer_ready', 'ko',
  'AI 답변이 준비되었습니다'),
('ai_answer_ready', 'en',
  'AI answer ready'),
('knowledge_updated', 'ko',
  '지식 베이스가 업데이트되었습니다'),
('knowledge_updated', 'en',
  'Knowledge base updated'),
('sop_evolved', 'ko',
  'SOP가 자가 진화했습니다'),
('sop_evolved', 'en',
  'SOP self-evolved'),
('ai_center_dashboard_loaded', 'ko',
  'AI 고객센터 대시보드가 로드되었습니다'),
('ai_center_dashboard_loaded', 'en',
  'AI center dashboard loaded')
on conflict (message_key, locale) do nothing;

insert into catchmenu_common.error_codes (
  code, error_key, error_domain,
  error_category, http_status, severity
) values
(13001, 'knowledge_doc_not_found',
  'AI', 'NOT_FOUND', 404, 'WARNING'),
(13002, 'ai_answer_not_grounded',
  'AI', 'INTEGRITY', 200, 'WARNING'),
(13003, 'inquiry_not_found',
  'AI', 'NOT_FOUND', 404, 'WARNING'),
(13004, 'sop_evolution_failed',
  'AI', 'TECHNICAL', 500, 'WARNING')
on conflict (code) do nothing;


-- =============================================
-- customer_inquiries 테이블 보완
-- (0088에서 기본 생성됨 → 컬럼 추가)
-- =============================================
alter table catchmenu_knowledge.customer_inquiries
  add column if not exists
    auto_category text,
  add column if not exists
    ai_confidence numeric(4,3),
  add column if not exists
    is_recurring boolean
      not null default false,
  add column if not exists
    similar_inquiry_count int
      not null default 0,
  add column if not exists
    sop_triggered text,
  add column if not exists
    resolution_time_minutes int,
  add column if not exists
    customer_satisfied boolean;

comment on column
  catchmenu_knowledge.customer_inquiries
  .auto_category is
  'AI 자동 분류 카테고리.
   MENU/ORDER/PAYMENT/WAITING/
   MEMBERSHIP/COMPLAINT/OTHER';

comment on column
  catchmenu_knowledge.customer_inquiries
  .is_recurring is
  '반복 문의 여부.
   동일 패턴이 임계값 이상 → true.
   SOP 자동 생성 트리거.';


-- =============================================
-- sop_evolution_log 테이블
-- SOP 자가 진화 이력
-- =============================================
create table if not exists
  catchmenu_knowledge.sop_evolution_log (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null,
  store_id uuid,

  -- 진화 트리거
  trigger_type text not null,
  trigger_inquiry_ids jsonb,
  trigger_pattern text,

  -- 진화 결과
  evolved_document_code text,
  evolution_type text not null,
  evolution_summary text,
  auto_approved boolean not null default false,

  -- 검증
  requires_human_review boolean
    not null default true,
  reviewed_by uuid,
  reviewed_at timestamptz,
  review_status text not null
    default 'PENDING',

  evolved_at timestamptz
    not null default now(),

  constraint chk_trigger_type check (
    trigger_type in (
      'RECURRING_INQUIRY',
      'KNOWLEDGE_GAP',
      'ERROR_PATTERN',
      'MANUAL_REQUEST'
    )
  ),
  constraint chk_evolution_type check (
    evolution_type in (
      'NEW_SOP_CREATED',
      'EXISTING_SOP_UPDATED',
      'FAQ_ADDED',
      'KNOWLEDGE_EXPANDED'
    )
  ),
  constraint chk_review_status check (
    review_status in (
      'PENDING', 'APPROVED',
      'REJECTED', 'AUTO_APPROVED'
    )
  )
);

alter table catchmenu_knowledge.sop_evolution_log
  enable row level security;
alter table catchmenu_knowledge.sop_evolution_log
  force row level security;

drop policy if exists sop_evolution_isolation
  on catchmenu_knowledge.sop_evolution_log;
create policy sop_evolution_isolation
  on catchmenu_knowledge.sop_evolution_log
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
  );

comment on table
  catchmenu_knowledge.sop_evolution_log is
  'SOP 자가 진화 이력.
   RECURRING_INQUIRY:
     동일 문의 5회+ → SOP 자동 생성 제안.
   KNOWLEDGE_GAP:
     AI 답변 불가 패턴 → 문서 보완 요청.
   auto_approved: 낮은 위험도만 자동 승인.
   requires_human_review: 기본 true.
   특허3: AI 자가진화 SOP 핵심 테이블.';


-- =============================================
-- RPCs
-- =============================================
create or replace function
  catchmenu_knowledge.submit_customer_inquiry(
  p_tenant_id uuid,
  p_store_id uuid,
  p_customer_id uuid default null,
  p_inquiry_text text,
  p_inquiry_locale text default 'ko',
  p_inquiry_channel text default 'APP',
  p_order_id uuid default null,
  p_session_id uuid default null,
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
  v_inquiry_id uuid;
  v_auto_category text;
  v_similar_count int;
  v_is_recurring boolean;
  v_ai_answer jsonb;
begin
  -- AI 자동 분류
  v_auto_category := case
    when p_inquiry_text ilike '%메뉴%'
      or p_inquiry_text ilike '%menu%'
      or p_inquiry_text ilike '%음식%'
      then 'MENU'
    when p_inquiry_text ilike '%주문%'
      or p_inquiry_text ilike '%order%'
      then 'ORDER'
    when p_inquiry_text ilike '%결제%'
      or p_inquiry_text ilike '%payment%'
      or p_inquiry_text ilike '%카드%'
      then 'PAYMENT'
    when p_inquiry_text ilike '%대기%'
      or p_inquiry_text ilike '%wait%'
      or p_inquiry_text ilike '%번호%'
      then 'WAITING'
    when p_inquiry_text ilike '%포인트%'
      or p_inquiry_text ilike '%쿠폰%'
      or p_inquiry_text ilike '%멤버십%'
      then 'MEMBERSHIP'
    when p_inquiry_text ilike '%불만%'
      or p_inquiry_text ilike '%환불%'
      or p_inquiry_text ilike '%complaint%'
      then 'COMPLAINT'
    else 'OTHER'
  end;

  -- 유사 문의 수 확인 (반복 탐지)
  select count(*) into v_similar_count
  from catchmenu_knowledge.customer_inquiries
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and auto_category = v_auto_category
    and created_at > now() - interval '7 days';

  v_is_recurring := v_similar_count >= 5;

  -- 문의 등록
  insert into
    catchmenu_knowledge.customer_inquiries (
    tenant_id, store_id, customer_id,
    inquiry_text, inquiry_locale,
    inquiry_channel, order_id,
    session_id,
    auto_category, is_recurring,
    similar_inquiry_count,
    inquiry_status
  ) values (
    p_tenant_id, p_store_id, p_customer_id,
    p_inquiry_text, p_inquiry_locale,
    p_inquiry_channel, p_order_id,
    p_session_id,
    v_auto_category, v_is_recurring,
    v_similar_count,
    'PENDING'
  )
  returning id into v_inquiry_id;

  -- 반복 문의 → SOP 진화 트리거
  if v_is_recurring then
    perform catchmenu_common.notify_channel(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_channel_type := 'SYSTEM_EVENTS',
      p_event_type :=
        'recurring_inquiry_detected',
      p_payload := jsonb_build_object(
        'inquiry_id', v_inquiry_id,
        'category', v_auto_category,
        'similar_count', v_similar_count,
        'trigger_type', 'RECURRING_INQUIRY'
      )
    );
  end if;

  -- RAG 즉시 검색 시도
  v_ai_answer :=
    catchmenu_knowledge.search_knowledge(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_query := p_inquiry_text,
      p_locale := p_inquiry_locale,
      p_max_results := 3
    );

  -- 답변 신뢰도 업데이트
  if (v_ai_answer->'data'->>'found')::boolean
  then
    update catchmenu_knowledge.customer_inquiries
    set
      ai_confidence := (
        v_ai_answer->'data'
          ->'results'->0->>'similarity_score'
      )::numeric,
      inquiry_status = 'AI_ANSWERED'
    where id = v_inquiry_id;
  end if;

  return catchmenu_common.build_success_response(
    p_message_key := 'inquiry_submitted',
    p_data := jsonb_build_object(
      'inquiry_id', v_inquiry_id,
      'auto_category', v_auto_category,
      'is_recurring', v_is_recurring,
      'ai_answer_available',
        (v_ai_answer->'data'->>'found')
          ::boolean,
      'ai_results',
        v_ai_answer->'data'->'results',
      'sop_evolution_triggered',
        v_is_recurring
    ),
    p_locale := p_locale
  );
end;
$$;


create or replace function
  catchmenu_knowledge.detect_recurring_inquiries(
  p_tenant_id uuid,
  p_store_id uuid default null,
  p_days int default 7,
  p_threshold int default 5
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_knowledge,
                  catchmenu_common
as $$
declare
  v_patterns jsonb;
  v_evolved_count int := 0;
  v_pattern record;
  v_evo_id uuid;
begin
  -- 반복 패턴 탐지
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'category', auto_category,
        'count', cnt,
        'inquiry_ids', inquiry_ids,
        'sample_text', sample_text
      )
      order by cnt desc
    ),
    '[]'::jsonb
  )
  into v_patterns
  from (
    select
      auto_category,
      count(*) as cnt,
      jsonb_agg(id) as inquiry_ids,
      (array_agg(
        inquiry_text
        order by created_at desc
      ))[1] as sample_text
    from catchmenu_knowledge.customer_inquiries
    where tenant_id = p_tenant_id
      and (
        p_store_id is null
        or store_id = p_store_id
      )
      and created_at
        > now() - (p_days || ' days')::interval
      and inquiry_status <> 'CLOSED'
    group by auto_category
    having count(*) >= p_threshold
  ) patterns;

  -- 패턴별 SOP 진화 처리
  for v_pattern in
    select *
    from jsonb_array_elements(v_patterns) p
  loop
    -- SOP 진화 로그
    insert into
      catchmenu_knowledge.sop_evolution_log (
      tenant_id, store_id,
      trigger_type, trigger_inquiry_ids,
      trigger_pattern,
      evolution_type, evolution_summary,
      auto_approved, requires_human_review
    ) values (
      p_tenant_id, p_store_id,
      'RECURRING_INQUIRY',
      v_pattern->'inquiry_ids',
      v_pattern->>'category',
      'FAQ_ADDED',
      (v_pattern->>'category')
        || ' 카테고리 반복 문의 '
        || (v_pattern->>'count')
        || '건 감지. FAQ 추가 검토 필요.',
      false,
      true
    )
    returning id into v_evo_id;

    v_evolved_count := v_evolved_count + 1;

    -- 지식 문서 보완 요청
    perform catchmenu_common.notify_channel(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_channel_type := 'SYSTEM_EVENTS',
      p_event_type :=
        'knowledge_gap_detected',
      p_payload := jsonb_build_object(
        'evolution_id', v_evo_id,
        'category',
          v_pattern->>'category',
        'count', v_pattern->>'count',
        'action_required',
          'FAQ 문서 작성 및 검토 후 승인'
      )
    );
  end loop;

  return jsonb_build_object(
    'success', true,
    'data', jsonb_build_object(
      'patterns_found',
        jsonb_array_length(v_patterns),
      'patterns', v_patterns,
      'evolutions_triggered', v_evolved_count,
      'scanned_days', p_days,
      'threshold', p_threshold
    )
  );
end;
$$;


create or replace function
  catchmenu_knowledge.get_ai_center_dashboard(
  p_tenant_id uuid,
  p_store_id uuid,
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
  v_inquiry_summary jsonb;
  v_category_breakdown jsonb;
  v_ai_performance jsonb;
  v_evolution_summary jsonb;
  v_knowledge_summary jsonb;
  v_business_day date;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  -- 문의 요약
  select jsonb_build_object(
    'total_today', count(*) filter (
      where created_at::date = v_business_day
    ),
    'total_this_month', count(*) filter (
      where created_at
        >= date_trunc('month', now())
    ),
    'pending', count(*) filter (
      where inquiry_status = 'PENDING'
    ),
    'ai_answered', count(*) filter (
      where inquiry_status = 'AI_ANSWERED'
    ),
    'human_required', count(*) filter (
      where inquiry_status = 'HUMAN_REQUIRED'
    ),
    'recurring', count(*) filter (
      where is_recurring = true
    ),
    'avg_confidence', coalesce(
      avg(ai_confidence)::numeric(4,3), 0
    )
  )
  into v_inquiry_summary
  from catchmenu_knowledge.customer_inquiries
  where store_id = p_store_id
    and tenant_id = p_tenant_id;

  -- 카테고리별 분류
  select coalesce(
    jsonb_object_agg(
      auto_category, cnt
    ),
    '{}'::jsonb
  )
  into v_category_breakdown
  from (
    select
      coalesce(auto_category, 'OTHER')
        as auto_category,
      count(*)::int as cnt
    from catchmenu_knowledge.customer_inquiries
    where store_id = p_store_id
      and tenant_id = p_tenant_id
      and created_at
        >= date_trunc('month', now())
    group by auto_category
  ) c;

  -- AI 성능 지표
  select jsonb_build_object(
    'answer_rate', case
      when count(*) = 0 then 0
      else round(
        count(*) filter (
          where inquiry_status = 'AI_ANSWERED'
        )::numeric / count(*) * 100, 1
      )
    end,
    'avg_confidence', coalesce(
      round(avg(ai_confidence)::numeric, 3), 0
    ),
    'high_confidence', count(*) filter (
      where ai_confidence >= 0.8
    ),
    'low_confidence', count(*) filter (
      where ai_confidence < 0.5
        and ai_confidence is not null
    )
  )
  into v_ai_performance
  from catchmenu_knowledge.customer_inquiries
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and created_at
      >= date_trunc('month', now());

  -- SOP 진화 요약
  select jsonb_build_object(
    'total_evolutions', count(*),
    'pending_review', count(*) filter (
      where review_status = 'PENDING'
    ),
    'approved', count(*) filter (
      where review_status in (
        'APPROVED', 'AUTO_APPROVED'
      )
    ),
    'this_month', count(*) filter (
      where evolved_at
        >= date_trunc('month', now())
    )
  )
  into v_evolution_summary
  from catchmenu_knowledge.sop_evolution_log
  where tenant_id = p_tenant_id
    and (
      p_store_id is null
      or store_id = p_store_id
    );

  -- 지식 문서 요약
  select jsonb_build_object(
    'total_documents', count(*),
    'published', count(*) filter (
      where document_status = 'PUBLISHED'
    ),
    'draft', count(*) filter (
      where document_status = 'DRAFT'
    ),
    'domains', jsonb_agg(
      distinct domain
    )
  )
  into v_knowledge_summary
  from catchmenu_knowledge.documents
  where tenant_id = p_tenant_id
    and (
      store_id is null
      or store_id = p_store_id
    );

  return catchmenu_common.build_success_response(
    p_message_key := 'ai_center_dashboard_loaded',
    p_data := jsonb_build_object(
      'store_id', p_store_id,
      'business_day', v_business_day,
      'inquiry_summary', v_inquiry_summary,
      'category_breakdown', v_category_breakdown,
      'ai_performance', v_ai_performance,
      'evolution_summary', v_evolution_summary,
      'knowledge_summary', v_knowledge_summary,
      'patent_note', jsonb_build_object(
        'patent3',
          'AI self-evolving SOP system',
        'trigger',
          'recurring_inquiry >= 5 → FAQ auto-propose',
        'verification',
          'verify_answer_grounding() prevents hallucination'
      ),
      'loaded_at', now()
    ),
    p_locale := p_locale
  );
end;
$$;


-- pg_cron
insert into catchmenu_common.pg_cron_jobs (
  job_code, pg_cron_job_name,
  schedule_cron_utc, schedule_cron_kst,
  sql_command, notes, is_active
) values
(
  'RECURRING_INQUIRY_DETECT',
  'catchmenu_recurring_inquiry_detect',
  '0 4 * * *',
  '0 13 * * * (매일 13:00 KST)',
  $sql$
SELECT catchmenu_knowledge
  .detect_recurring_inquiries(
    t.id, null, 7, 5
  )
FROM catchmenu_hq.tenants t
WHERE t.tenant_status = 'ACTIVE';
$sql$,
  '반복 문의 패턴 탐지. 매일 13:00.
   7일 내 5건+ 동일 카테고리 → SOP 진화 제안.',
  true
),
(
  'KNOWLEDGE_GAP_DETECT',
  'catchmenu_knowledge_gap_detect',
  '0 3 * * *',
  '0 12 * * * (매일 12:00 KST)',
  $sql$
-- AI 답변 불가 문의 집계
UPDATE catchmenu_knowledge.customer_inquiries
SET inquiry_status = 'HUMAN_REQUIRED'
WHERE inquiry_status = 'PENDING'
  AND ai_confidence IS NULL
  AND created_at < now() - interval '1 hour';
$sql$,
  'AI 미답변 문의 → HUMAN_REQUIRED. 매일 12:00.',
  true
)
on conflict (job_code) do nothing;


-- grants
do $$
begin
  grant execute on function
    catchmenu_knowledge.submit_customer_inquiry(
      uuid, uuid, uuid, text, text,
      text, uuid, uuid, text
    ) to authenticated;

  grant execute on function
    catchmenu_knowledge.detect_recurring_inquiries(
      uuid, uuid, int, int
    ) to authenticated;

  grant execute on function
    catchmenu_knowledge.get_ai_center_dashboard(
      uuid, uuid, text
    ) to authenticated;
end;
$$;

comment on function
  catchmenu_knowledge.detect_recurring_inquiries(
    uuid, uuid, int, int
  ) is
  '반복 문의 패턴 탐지 + SOP 자가 진화.
   특허3: AI 자가진화 SOP 핵심 함수.

   동작:
   1. 지정 기간 내 카테고리별 문의 집계
   2. threshold 이상 → 반복 패턴으로 분류
   3. sop_evolution_log 자동 생성
   4. SYSTEM_EVENTS 채널 알림
   5. Edge Function → 문서 생성 요청

   진화 흐름:
   반복 탐지 → FAQ 문서 초안 생성
   → 인간 검토 → 승인 → 지식베이스 등록
   → 임베딩 → RAG 검색 향상

   pg_cron: 매일 13:00 자동 실행.
   KNOWLEDGE_GAP_DETECT와 함께 동작.';