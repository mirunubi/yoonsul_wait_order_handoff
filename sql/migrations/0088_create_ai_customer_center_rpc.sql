-- 0088_create_ai_customer_center_rpc.sql
-- Purpose: AI customer center foundation RPCs.
--          Customer inquiry management, AI chat session,
--          unresolved inquiry detection, auto SOP candidate.
--          5차 AI 고객센터 → 1-C차로 앞당김.
--          pgvector + RAG + Digital SOP 기반.
--          i18n: 모든 메시지 = message_catalog 참조.
-- Depends on: 0087_create_multistore_policy_rpc.sql
-- Creates:
--   catchmenu_knowledge.ai_query_logs (table)
--   catchmenu_knowledge.customer_inquiries (table)
--   catchmenu_knowledge.inquiry_categories (table)
--   catchmenu_knowledge.sop_candidates (table)
--   function catchmenu_knowledge.log_ai_query(...)
--   function catchmenu_knowledge.submit_customer_inquiry(...)
--   function catchmenu_knowledge.resolve_inquiry(...)
--   function catchmenu_knowledge.detect_recurring_inquiries(...)
--   function catchmenu_knowledge.generate_sop_candidate(...)
--   function catchmenu_knowledge.get_ai_center_dashboard(...)

-- =============================================
-- i18n 메시지 등록
-- =============================================
insert into catchmenu_common.message_catalog (
  message_key, locale, message_text
) values
('inquiry_submitted', 'ko',
  '문의가 접수되었습니다'),
('inquiry_submitted', 'en',
  'Inquiry submitted'),
('inquiry_resolved', 'ko',
  '문의가 해결되었습니다'),
('inquiry_resolved', 'en',
  'Inquiry resolved'),
('inquiry_not_found', 'ko',
  '문의를 찾을 수 없습니다'),
('inquiry_not_found', 'en',
  'Inquiry not found'),
('sop_candidate_created', 'ko',
  'SOP 후보가 생성되었습니다'),
('sop_candidate_created', 'en',
  'SOP candidate created'),
('ai_query_logged', 'ko',
  'AI 쿼리가 기록되었습니다'),
('ai_query_logged', 'en',
  'AI query logged'),
('recurring_inquiries_detected', 'ko',
  '{count}개의 반복 문의 유형이 감지되었습니다'),
('recurring_inquiries_detected', 'en',
  '{count} recurring inquiry types detected'),
('no_recurring_inquiries', 'ko',
  '감지된 반복 문의가 없습니다'),
('no_recurring_inquiries', 'en',
  'No recurring inquiries detected'),
('ai_center_dashboard_loaded', 'ko',
  'AI 고객센터 대시보드가 로드되었습니다'),
('ai_center_dashboard_loaded', 'en',
  'AI customer center dashboard loaded'),
('ai_answer_not_grounded', 'ko',
  '승인된 문서 기반으로 답변할 수 없습니다. 직원에게 문의해 주세요.'),
('ai_answer_not_grounded', 'en',
  'Cannot answer from approved documents. Please contact staff.'),
('ai_answer_not_grounded', 'zh',
  '无法从已批准的文档中回答。请联系工作人员。'),
('ai_answer_not_grounded', 'ja',
  '承認済み文書から回答できません。スタッフにお問い合わせください。')
on conflict (message_key, locale) do nothing;

insert into catchmenu_common.error_codes (
  code, error_key, error_domain,
  error_category, http_status, severity
) values
(8007, 'inquiry_not_found',
  'KNOWLEDGE', 'NOT_FOUND', 404, 'WARNING'),
(8008, 'inquiry_already_resolved',
  'KNOWLEDGE', 'CONFLICT', 409, 'INFO'),
(8009, 'sop_candidate_exists',
  'KNOWLEDGE', 'CONFLICT', 409, 'INFO'),
(8010, 'ai_answer_not_grounded',
  'KNOWLEDGE', 'BUSINESS_RULE', 422, 'WARNING')
on conflict (code) do nothing;


-- =============================================
-- inquiry_categories table
-- 문의 카테고리
-- =============================================
create table if not exists
  catchmenu_knowledge.inquiry_categories (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),

  category_code text not null,
  category_name text not null,
  category_name_i18n jsonb
    default '{}'::jsonb,
  parent_category_id uuid
    references catchmenu_knowledge
      .inquiry_categories(id),
  display_order int not null default 0,

  -- 자동화 설정
  auto_response_enabled boolean
    not null default false,
  sop_document_code text,
  avg_resolution_minutes int,

  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint uq_inquiry_category unique (
    tenant_id, category_code
  )
);

alter table catchmenu_knowledge.inquiry_categories
  enable row level security;
alter table catchmenu_knowledge.inquiry_categories
  force row level security;

drop policy if exists inquiry_categories_isolation
  on catchmenu_knowledge.inquiry_categories;
create policy inquiry_categories_isolation
  on catchmenu_knowledge.inquiry_categories
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
  );

drop trigger if exists trg_inquiry_cat_updated
  on catchmenu_knowledge.inquiry_categories;
create trigger trg_inquiry_cat_updated
  before update on
    catchmenu_knowledge.inquiry_categories
  for each row execute function
    catchmenu_common.set_updated_at();

-- 기본 카테고리 시드
insert into catchmenu_knowledge.inquiry_categories (
  tenant_id, category_code, category_name,
  category_name_i18n, display_order,
  auto_response_enabled
) values
(
  '00000000-0000-0000-0000-000000000001',
  'MENU_INFO', '메뉴 문의',
  '{"ko":"메뉴 문의","en":"Menu Inquiry",
    "zh":"菜单咨询","ja":"メニューに関するお問い合わせ"}'::jsonb,
  1, true
),
(
  '00000000-0000-0000-0000-000000000001',
  'ORDER_STATUS', '주문 상태 문의',
  '{"ko":"주문 상태 문의","en":"Order Status",
    "zh":"订单状态","ja":"注文状況"}'::jsonb,
  2, true
),
(
  '00000000-0000-0000-0000-000000000001',
  'ALLERGEN', '알레르겐 문의',
  '{"ko":"알레르겐 문의","en":"Allergen Inquiry",
    "zh":"过敏原咨询","ja":"アレルゲンのお問い合わせ"}'::jsonb,
  3, true
),
(
  '00000000-0000-0000-0000-000000000001',
  'PAYMENT', '결제 문의',
  '{"ko":"결제 문의","en":"Payment Inquiry",
    "zh":"付款咨询","ja":"お支払いに関するお問い合わせ"}'::jsonb,
  4, false
),
(
  '00000000-0000-0000-0000-000000000001',
  'WAITING', '대기 문의',
  '{"ko":"대기 문의","en":"Waiting Inquiry",
    "zh":"等待咨询","ja":"待ち時間のお問い合わせ"}'::jsonb,
  5, true
),
(
  '00000000-0000-0000-0000-000000000001',
  'COMPLAINT', '불편 신고',
  '{"ko":"불편 신고","en":"Complaint",
    "zh":"投诉","ja":"ご不満のご報告"}'::jsonb,
  6, false
),
(
  '00000000-0000-0000-0000-000000000001',
  'OTHER', '기타 문의',
  '{"ko":"기타 문의","en":"Other",
    "zh":"其他","ja":"その他"}'::jsonb,
  99, false
)
on conflict (tenant_id, category_code) do nothing;


-- =============================================
-- ai_query_logs table
-- AI 쿼리 로그 (pgvector 검색 추적)
-- =============================================
create table if not exists
  catchmenu_knowledge.ai_query_logs (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid
    references catchmenu_hq.stores(id),

  -- 쿼리 정보
  query_text text not null,
  query_type text not null default 'FAQ_LOOKUP',
  query_locale text not null default 'ko',

  -- 검색 결과
  search_result_count int not null default 0,
  is_grounded boolean not null default false,
  top_similarity_score numeric(5,4),

  -- AI 응답
  ai_answer text,
  cited_document_ids jsonb default '[]'::jsonb,
  cited_document_codes jsonb default '[]'::jsonb,
  answer_verified boolean not null default false,
  verdict text,

  -- 고객 정보
  customer_id uuid,
  session_id uuid,
  channel text not null default 'APP',

  -- 피드백
  customer_feedback text,
  was_helpful boolean,
  escalated_to_human boolean
    not null default false,

  -- 성능
  response_time_ms int,

  query_date date,
  created_at timestamptz not null default now(),

  constraint chk_query_type check (
    query_type in (
      'FAQ_LOOKUP', 'MENU_INFO',
      'ALLERGEN_CHECK', 'ORDER_STATUS',
      'SOP_SEARCH', 'POLICY_LOOKUP',
      'COMPLAINT', 'CUSTOM'
    )
  ),
  constraint chk_query_channel check (
    channel in (
      'APP', 'KIOSK', 'WEB',
      'STAFF_APP', 'INTERNAL'
    )
  )
);

create index if not exists idx_ai_query_tenant
  on catchmenu_knowledge.ai_query_logs(
    tenant_id, query_date desc
  );
create index if not exists idx_ai_query_store
  on catchmenu_knowledge.ai_query_logs(
    store_id, query_date desc
  ) where store_id is not null;
create index if not exists idx_ai_query_grounded
  on catchmenu_knowledge.ai_query_logs(
    is_grounded, query_type
  );
create index if not exists idx_ai_query_helpful
  on catchmenu_knowledge.ai_query_logs(
    was_helpful, query_date desc
  ) where was_helpful is not null;

alter table catchmenu_knowledge.ai_query_logs
  enable row level security;
alter table catchmenu_knowledge.ai_query_logs
  force row level security;

drop policy if exists ai_query_logs_isolation
  on catchmenu_knowledge.ai_query_logs;
create policy ai_query_logs_isolation
  on catchmenu_knowledge.ai_query_logs
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
  );

comment on table catchmenu_knowledge.ai_query_logs is
  'AI 쿼리 로그.
   is_grounded: pgvector 검색 후 승인 문서 기반 답변.
   was_helpful: 고객 피드백 (thumbs up/down).
   escalated_to_human: AI 미해결 → 직원 에스컬레이션.
   verdict: verify_answer_grounding() 결과.
   Phase 2: Firebase Firestore 마이그레이션 대상.
   5차 AI 고객센터 → 1-C차 앞당김.
   특허3: AI 쿼리 = 지식 진화 피드백 루프.';


-- =============================================
-- customer_inquiries table
-- 고객 문의 관리
-- =============================================
create table if not exists
  catchmenu_knowledge.customer_inquiries (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid
    references catchmenu_hq.stores(id),

  -- 문의 식별
  inquiry_number text not null,
  inquiry_type text not null,
  category_id uuid
    references catchmenu_knowledge
      .inquiry_categories(id),

  -- 고객 정보
  customer_id uuid,
  customer_name text,
  contact_info_hash text,
  locale text not null default 'ko',
  channel text not null default 'APP',

  -- 문의 내용
  inquiry_title text,
  inquiry_body text not null,
  attachments jsonb default '[]'::jsonb,

  -- AI 처리
  ai_query_log_id uuid
    references catchmenu_knowledge.ai_query_logs(id),
  ai_attempted boolean not null default false,
  ai_resolved boolean not null default false,
  ai_answer text,
  ai_confidence_score numeric(5,4),

  -- 처리 상태
  inquiry_status text
    not null default 'OPEN',
  assigned_to uuid,
  resolved_by uuid,
  resolved_at timestamptz,
  resolution_note text,
  resolution_type text,

  -- 우선순위
  priority text not null default 'NORMAL',
  is_recurring boolean not null default false,
  recurrence_count int not null default 1,

  -- 연결
  order_id uuid,
  related_inquiry_ids jsonb
    default '[]'::jsonb,

  business_day date,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint uq_inquiry_number unique (
    tenant_id, inquiry_number
  ),
  constraint chk_inquiry_type check (
    inquiry_type in (
      'QUESTION', 'COMPLAINT',
      'SUGGESTION', 'COMPLIMENT', 'OTHER'
    )
  ),
  constraint chk_inquiry_status check (
    inquiry_status in (
      'OPEN', 'AI_PROCESSING',
      'AI_ANSWERED', 'PENDING_HUMAN',
      'IN_PROGRESS', 'RESOLVED',
      'CLOSED', 'SPAM'
    )
  ),
  constraint chk_resolution_type check (
    resolution_type in (
      'AI_RESOLVED', 'STAFF_RESOLVED',
      'AUTO_CLOSED', 'ESCALATED',
      'NO_ACTION_NEEDED', null
    )
  )
);

create index if not exists idx_inquiries_store
  on catchmenu_knowledge.customer_inquiries(
    store_id, inquiry_status, created_at desc
  );
create index if not exists idx_inquiries_tenant
  on catchmenu_knowledge.customer_inquiries(
    tenant_id, inquiry_type, business_day desc
  );
create index if not exists idx_inquiries_recurring
  on catchmenu_knowledge.customer_inquiries(
    tenant_id, category_id, recurrence_count desc
  ) where is_recurring = true;
create index if not exists idx_inquiries_pending
  on catchmenu_knowledge.customer_inquiries(
    store_id, priority, created_at asc
  ) where inquiry_status in (
    'OPEN', 'PENDING_HUMAN', 'IN_PROGRESS'
  );

alter table catchmenu_knowledge.customer_inquiries
  enable row level security;
alter table catchmenu_knowledge.customer_inquiries
  force row level security;

drop policy if exists customer_inquiries_isolation
  on catchmenu_knowledge.customer_inquiries;
create policy customer_inquiries_isolation
  on catchmenu_knowledge.customer_inquiries
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
  );

drop trigger if exists trg_inquiries_updated
  on catchmenu_knowledge.customer_inquiries;
create trigger trg_inquiries_updated
  before update on
    catchmenu_knowledge.customer_inquiries
  for each row execute function
    catchmenu_common.set_updated_at();

comment on table
  catchmenu_knowledge.customer_inquiries is
  '고객 문의 관리.
   AI 처리 흐름:
   OPEN → AI_PROCESSING → AI_ANSWERED (해결)
                        → PENDING_HUMAN (미해결)
                          → IN_PROGRESS → RESOLVED
   is_recurring: 반복 문의 감지 후 표시.
   recurrence_count: 동일 카테고리 반복 횟수.
   특허3: 반복 문의 → SOP 후보 자동 생성.
   5차 AI 고객센터 → 1-C차 앞당김.';


-- =============================================
-- sop_candidates table
-- 자동 SOP 생성 후보
-- =============================================
create table if not exists
  catchmenu_knowledge.sop_candidates (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid,

  -- SOP 후보 정보
  candidate_code text not null,
  candidate_title text not null,
  candidate_domain text not null,
  document_type text not null default 'SOP',

  -- 생성 근거
  trigger_type text not null,
  source_inquiry_ids jsonb
    default '[]'::jsonb,
  source_gap_id uuid,
  trigger_count int not null default 1,

  -- 초안 내용 (AI 생성)
  draft_content text,
  draft_generated_at timestamptz,
  draft_model text,

  -- 승인 워크플로우
  candidate_status text
    not null default 'DETECTED',
  reviewed_by uuid,
  reviewed_at timestamptz,
  review_note text,
  approved_by uuid,
  approved_at timestamptz,

  -- 연결된 문서
  generated_document_id uuid
    references catchmenu_knowledge.documents(id),

  -- 통계
  potential_resolution_count int
    not null default 0,
  priority_score numeric(5,2)
    not null default 0,

  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint uq_sop_candidate unique (
    tenant_id, candidate_code
  ),
  constraint chk_trigger_type check (
    trigger_type in (
      'RECURRING_INQUIRY',
      'KNOWLEDGE_GAP',
      'AI_FAILURE_PATTERN',
      'MANUAL'
    )
  ),
  constraint chk_candidate_status check (
    candidate_status in (
      'DETECTED', 'DRAFT_GENERATED',
      'UNDER_REVIEW', 'APPROVED',
      'PUBLISHED', 'REJECTED', 'DISMISSED'
    )
  )
);

create index if not exists idx_sop_candidates
  on catchmenu_knowledge.sop_candidates(
    tenant_id, candidate_status,
    priority_score desc
  ) where is_active = true;

alter table catchmenu_knowledge.sop_candidates
  enable row level security;
alter table catchmenu_knowledge.sop_candidates
  force row level security;

drop policy if exists sop_candidates_isolation
  on catchmenu_knowledge.sop_candidates;
create policy sop_candidates_isolation
  on catchmenu_knowledge.sop_candidates
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
  );

drop trigger if exists trg_sop_candidates_updated
  on catchmenu_knowledge.sop_candidates;
create trigger trg_sop_candidates_updated
  before update on catchmenu_knowledge.sop_candidates
  for each row execute function
    catchmenu_common.set_updated_at();

comment on table
  catchmenu_knowledge.sop_candidates is
  'AI 자동 SOP 생성 후보.
   trigger_type:
     RECURRING_INQUIRY: 반복 문의 패턴 감지
     KNOWLEDGE_GAP: pgvector 검색 실패
     AI_FAILURE_PATTERN: AI 미해결 반복
     MANUAL: 직원 수동 등록
   draft_content: AI가 생성한 SOP 초안.
   Human approval 필수 (자동 발행 금지).
   특허3: AI 자가진화 운영 지식 생성 시스템.
   1-C차 Digital SOP 핵심.';


-- =============================================
-- RPCs
-- =============================================
create or replace function
  catchmenu_knowledge.log_ai_query(
  p_tenant_id uuid,
  p_store_id uuid,
  p_query_text text,
  p_query_type text,
  p_query_locale text,
  p_channel text,
  p_search_result_count int,
  p_is_grounded boolean,
  p_ai_answer text default null,
  p_cited_document_ids jsonb default null,
  p_cited_document_codes jsonb default null,
  p_verdict text default null,
  p_answer_verified boolean default false,
  p_top_similarity_score numeric default null,
  p_customer_id uuid default null,
  p_session_id uuid default null,
  p_response_time_ms int default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_knowledge,
                  catchmenu_common
as $$
declare
  v_log_id uuid;
  v_query_date date;
begin
  v_query_date := (timezone(
    'Asia/Seoul', now()
  ))::date;

  insert into catchmenu_knowledge.ai_query_logs (
    tenant_id, store_id,
    query_text, query_type, query_locale,
    channel, search_result_count, is_grounded,
    top_similarity_score,
    ai_answer,
    cited_document_ids, cited_document_codes,
    answer_verified, verdict,
    customer_id, session_id,
    response_time_ms, query_date
  ) values (
    p_tenant_id, p_store_id,
    p_query_text, p_query_type, p_query_locale,
    p_channel,
    p_search_result_count, p_is_grounded,
    p_top_similarity_score,
    p_ai_answer,
    coalesce(p_cited_document_ids, '[]'::jsonb),
    coalesce(p_cited_document_codes, '[]'::jsonb),
    p_answer_verified, p_verdict,
    p_customer_id, p_session_id,
    p_response_time_ms, v_query_date
  )
  returning id into v_log_id;

  -- 미해결 패턴 감지
  if not p_is_grounded
    or p_verdict in (
      'REJECTED_NO_CITATIONS',
      'REJECTED_STALE_CITATIONS'
    )
  then
    perform catchmenu_knowledge
      .detect_knowledge_gap(
        p_tenant_id := p_tenant_id,
        p_store_id := p_store_id,
        p_gap_type := 'AI_RECOMMENDATION_REJECTED',
        p_domain := p_query_type,
        p_gap_summary :=
          p_query_text,
        p_triggering_exception_ids :=
          '[]'::jsonb,
        p_gap_context := jsonb_build_object(
          'query_log_id', v_log_id,
          'query_type', p_query_type,
          'is_grounded', p_is_grounded,
          'verdict', p_verdict
        ),
        p_detection_threshold := 3
      );
  end if;

  return catchmenu_common.build_success_response(
    p_message_key := 'ai_query_logged',
    p_data := jsonb_build_object(
      'log_id', v_log_id,
      'is_grounded', p_is_grounded,
      'verdict', p_verdict,
      'query_date', v_query_date
    ),
    p_locale := p_query_locale
  );
end;
$$;


create or replace function
  catchmenu_knowledge.submit_customer_inquiry(
  p_tenant_id uuid,
  p_store_id uuid,
  p_inquiry_type text,
  p_category_code text,
  p_inquiry_body text,
  p_inquiry_title text default null,
  p_customer_id uuid default null,
  p_order_id uuid default null,
  p_locale text default 'ko',
  p_channel text default 'APP',
  p_ai_query_log_id uuid default null,
  p_ai_answer text default null,
  p_ai_resolved boolean default false,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_knowledge,
                  catchmenu_common,
                  catchmenu_ledger
as $$
declare
  v_inquiry_id uuid;
  v_inquiry_number text;
  v_inquiry_seq int;
  v_category_id uuid;
  v_initial_status text;
  v_recurrence_count int := 1;
  v_is_recurring boolean := false;
  v_business_day date;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  -- 카테고리 조회
  select id into v_category_id
  from catchmenu_knowledge.inquiry_categories
  where tenant_id = p_tenant_id
    and category_code = p_category_code
    and is_active = true;

  -- 문의 번호 생성
  select coalesce(count(*), 0) + 1
  into v_inquiry_seq
  from catchmenu_knowledge.customer_inquiries
  where tenant_id = p_tenant_id
    and business_day = v_business_day;

  v_inquiry_number := 'INQ-'
    || to_char(v_business_day, 'YYYYMMDD')
    || '-'
    || lpad(v_inquiry_seq::text, 4, '0');

  -- 반복 문의 감지
  if v_category_id is not null
    and p_customer_id is not null
  then
    select count(*) + 1
    into v_recurrence_count
    from catchmenu_knowledge.customer_inquiries
    where tenant_id = p_tenant_id
      and customer_id = p_customer_id
      and category_id = v_category_id
      and created_at > now()
        - interval '30 days';

    v_is_recurring := v_recurrence_count > 1;
  end if;

  -- 초기 상태 결정
  v_initial_status := case
    when p_ai_resolved then 'AI_ANSWERED'
    when p_ai_query_log_id is not null
      then 'AI_PROCESSING'
    else 'OPEN'
  end;

  -- 문의 생성
  insert into
    catchmenu_knowledge.customer_inquiries (
    tenant_id, store_id,
    inquiry_number, inquiry_type, category_id,
    customer_id, locale, channel,
    inquiry_title, inquiry_body,
    ai_query_log_id, ai_attempted,
    ai_resolved, ai_answer,
    inquiry_status,
    is_recurring, recurrence_count,
    order_id,
    business_day
  ) values (
    p_tenant_id, p_store_id,
    v_inquiry_number, p_inquiry_type,
    v_category_id,
    p_customer_id, p_locale, p_channel,
    p_inquiry_title, p_inquiry_body,
    p_ai_query_log_id,
    p_ai_query_log_id is not null,
    p_ai_resolved, p_ai_answer,
    v_initial_status,
    v_is_recurring, v_recurrence_count,
    p_order_id,
    v_business_day
  )
  returning id into v_inquiry_id;

  -- 미해결 AI 문의 → PENDING_HUMAN
  if p_ai_query_log_id is not null
    and not p_ai_resolved
  then
    update catchmenu_knowledge.customer_inquiries
    set inquiry_status = 'PENDING_HUMAN'
    where id = v_inquiry_id;
  end if;

  -- 반복 문의 → SOP 후보 감지
  if v_is_recurring
    and v_recurrence_count >= 3
    and v_category_id is not null
  then
    perform catchmenu_knowledge
      .generate_sop_candidate(
        p_tenant_id := p_tenant_id,
        p_store_id := p_store_id,
        p_trigger_type := 'RECURRING_INQUIRY',
        p_candidate_title :=
          coalesce(p_inquiry_title, p_category_code),
        p_candidate_domain := p_category_code,
        p_source_inquiry_id := v_inquiry_id,
        p_trigger_count := v_recurrence_count
      );
  end if;

  -- ledger event
  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, caused_by_id,
    event_payload, correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'knowledge', 'inquiry_submitted', 1,
    'customer_inquiry', v_inquiry_id,
    null, v_initial_status,
    'CUSTOMER', p_customer_id,
    jsonb_build_object(
      'inquiry_number', v_inquiry_number,
      'inquiry_type', p_inquiry_type,
      'category_code', p_category_code,
      'ai_attempted',
        p_ai_query_log_id is not null,
      'ai_resolved', p_ai_resolved,
      'is_recurring', v_is_recurring,
      'recurrence_count', v_recurrence_count
    ),
    p_correlation_id,
    v_business_day, 'Asia/Seoul', now()
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'inquiry_submitted',
    p_data := jsonb_build_object(
      'inquiry_id', v_inquiry_id,
      'inquiry_number', v_inquiry_number,
      'inquiry_status', v_initial_status,
      'ai_resolved', p_ai_resolved,
      'is_recurring', v_is_recurring,
      'recurrence_count', v_recurrence_count,
      'pending_human',
        not p_ai_resolved
        and p_ai_query_log_id is not null
    ),
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );
end;
$$;


create or replace function
  catchmenu_knowledge.resolve_inquiry(
  p_tenant_id uuid,
  p_inquiry_id uuid,
  p_resolution_type text,
  p_resolution_note text,
  p_resolved_by uuid default null,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_knowledge,
                  catchmenu_common,
                  catchmenu_ledger
as $$
declare
  v_inquiry record;
  v_business_day date;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  select id, inquiry_number, inquiry_status,
         category_id, inquiry_type,
         recurrence_count, store_id
  into v_inquiry
  from catchmenu_knowledge.customer_inquiries
  where id = p_inquiry_id
    and tenant_id = p_tenant_id
  for update;

  if v_inquiry.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'inquiry_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_rpc_name := 'resolve_inquiry'
    );
  end if;

  if v_inquiry.inquiry_status in (
    'RESOLVED', 'CLOSED'
  ) then
    return catchmenu_common.build_error_response(
      p_error_key := 'inquiry_already_resolved',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_rpc_name := 'resolve_inquiry'
    );
  end if;

  update catchmenu_knowledge.customer_inquiries
  set
    inquiry_status = 'RESOLVED',
    resolution_type = p_resolution_type,
    resolution_note = p_resolution_note,
    resolved_by = p_resolved_by,
    resolved_at = now(),
    updated_at = now()
  where id = p_inquiry_id;

  -- SOP 효과성 피드백
  if p_resolution_type = 'AI_RESOLVED' then
    perform catchmenu_knowledge
      .record_ai_resolution_outcome(
        p_tenant_id := p_tenant_id,
        p_store_id := v_inquiry.store_id,
        p_exception_id := p_inquiry_id,
        p_context_id := gen_random_uuid(),
        p_sop_document_id := null,
        p_resolution_outcome := 'SUCCESS',
        p_resolution_time_minutes := null,
        p_staff_feedback := p_resolution_note,
        p_ai_recommendation_used := true,
        p_correlation_id := p_correlation_id
      );
  end if;

  -- ledger event
  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, caused_by_id,
    event_payload, correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, v_inquiry.store_id,
    'knowledge', 'inquiry_resolved', 1,
    'customer_inquiry', p_inquiry_id,
    v_inquiry.inquiry_status, 'RESOLVED',
    case p_resolution_type
      when 'AI_RESOLVED' then 'SYSTEM'
      else 'STAFF'
    end,
    p_resolved_by,
    jsonb_build_object(
      'inquiry_number', v_inquiry.inquiry_number,
      'resolution_type', p_resolution_type,
      'resolution_note', p_resolution_note
    ),
    p_correlation_id,
    v_business_day, 'Asia/Seoul', now()
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'inquiry_resolved',
    p_data := jsonb_build_object(
      'inquiry_id', p_inquiry_id,
      'inquiry_number', v_inquiry.inquiry_number,
      'resolution_type', p_resolution_type,
      'resolved_at', now()
    ),
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );
end;
$$;


create or replace function
  catchmenu_knowledge.detect_recurring_inquiries(
  p_tenant_id uuid,
  p_store_id uuid default null,
  p_min_count int default 3,
  p_period_days int default 30,
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
  v_recurring jsonb;
  v_detected_count int;
begin
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'category_id', ci.category_id,
        'category_code', ic.category_code,
        'category_name', coalesce(
          ic.category_name_i18n->>p_locale,
          ic.category_name
        ),
        'inquiry_count', count(*),
        'unresolved_count', count(*) filter (
          where ci.inquiry_status in (
            'OPEN', 'PENDING_HUMAN',
            'IN_PROGRESS'
          )
        ),
        'ai_resolved_count', count(*) filter (
          where ci.ai_resolved = true
        ),
        'ai_resolution_rate', (
          count(*) filter (
            where ci.ai_resolved = true
          )::numeric
          / nullif(count(*), 0) * 100
        )::int,
        'first_seen', min(ci.created_at),
        'last_seen', max(ci.created_at),
        'has_sop_candidate', exists (
          select 1
          from catchmenu_knowledge.sop_candidates sc
          where sc.tenant_id = p_tenant_id
            and sc.candidate_domain
              = ic.category_code
            and sc.candidate_status not in (
              'REJECTED', 'DISMISSED'
            )
        ),
        'sop_document_exists', (
          ic.sop_document_code is not null
        )
      )
      order by count(*) desc
    ),
    '[]'::jsonb
  )
  into v_recurring
  from catchmenu_knowledge.customer_inquiries ci
  join catchmenu_knowledge.inquiry_categories ic
    on ic.id = ci.category_id
  where ci.tenant_id = p_tenant_id
    and (
      p_store_id is null
      or ci.store_id = p_store_id
    )
    and ci.created_at > now()
      - (p_period_days || ' days')::interval
    and ci.category_id is not null
  group by ci.category_id, ic.category_code,
           ic.category_name, ic.category_name_i18n,
           ic.sop_document_code
  having count(*) >= p_min_count;

  v_detected_count := jsonb_array_length(
    coalesce(v_recurring, '[]'::jsonb)
  );

  return catchmenu_common.build_success_response(
    p_message_key := case v_detected_count
      when 0 then 'no_recurring_inquiries'
      else 'recurring_inquiries_detected'
    end,
    p_data := jsonb_build_object(
      'period_days', p_period_days,
      'min_count', p_min_count,
      'detected_count', v_detected_count,
      'recurring_categories', v_recurring
    ),
    p_locale := p_locale,
    p_params := jsonb_build_object(
      'count', v_detected_count
    )
  );
end;
$$;


create or replace function
  catchmenu_knowledge.generate_sop_candidate(
  p_tenant_id uuid,
  p_store_id uuid,
  p_trigger_type text,
  p_candidate_title text,
  p_candidate_domain text,
  p_source_inquiry_id uuid default null,
  p_source_gap_id uuid default null,
  p_trigger_count int default 1,
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
  v_candidate_id uuid;
  v_candidate_code text;
  v_priority_score numeric;
  v_exists boolean;
begin
  -- 이미 존재하는 후보 확인
  v_exists := exists (
    select 1
    from catchmenu_knowledge.sop_candidates
    where tenant_id = p_tenant_id
      and candidate_domain = p_candidate_domain
      and candidate_status not in (
        'REJECTED', 'DISMISSED', 'PUBLISHED'
      )
      and is_active = true
  );

  if v_exists then
    -- 기존 후보 트리거 카운트 증가
    update catchmenu_knowledge.sop_candidates
    set
      trigger_count = trigger_count + 1,
      priority_score = least(
        100,
        priority_score + 5
      ),
      source_inquiry_ids = case
        when p_source_inquiry_id is not null
        then source_inquiry_ids
          || to_jsonb(p_source_inquiry_id)
        else source_inquiry_ids
      end,
      updated_at = now()
    where tenant_id = p_tenant_id
      and candidate_domain = p_candidate_domain
      and candidate_status not in (
        'REJECTED', 'DISMISSED', 'PUBLISHED'
      )
    returning id into v_candidate_id;

    return catchmenu_common.build_success_response(
      p_message_key := 'sop_candidate_created',
      p_data := jsonb_build_object(
        'candidate_id', v_candidate_id,
        'is_new', false,
        'trigger_type', p_trigger_type
      ),
      p_locale := p_locale
    );
  end if;

  -- 새 후보 코드 생성
  declare
    v_seq int;
  begin
    select coalesce(count(*), 0) + 1
    into v_seq
    from catchmenu_knowledge.sop_candidates
    where tenant_id = p_tenant_id;

    v_candidate_code := 'SOPC-'
      || to_char(now(), 'YYYYMM')
      || '-'
      || lpad(v_seq::text, 4, '0');
  end;

  -- 우선순위 점수 계산
  v_priority_score := least(100,
    case p_trigger_type
      when 'RECURRING_INQUIRY' then
        least(50, p_trigger_count * 5)
      when 'KNOWLEDGE_GAP' then 40
      when 'AI_FAILURE_PATTERN' then 60
      else 20
    end
  );

  -- SOP 후보 생성
  insert into catchmenu_knowledge.sop_candidates (
    tenant_id, store_id,
    candidate_code, candidate_title,
    candidate_domain, document_type,
    trigger_type,
    source_inquiry_ids, source_gap_id,
    trigger_count, priority_score,
    candidate_status
  ) values (
    p_tenant_id, p_store_id,
    v_candidate_code, p_candidate_title,
    p_candidate_domain, 'SOP',
    p_trigger_type,
    case when p_source_inquiry_id is not null
      then jsonb_build_array(p_source_inquiry_id)
      else '[]'::jsonb
    end,
    p_source_gap_id,
    p_trigger_count, v_priority_score,
    'DETECTED'
  )
  returning id into v_candidate_id;

  -- knowledge gap 연동
  if p_trigger_type in (
    'RECURRING_INQUIRY', 'AI_FAILURE_PATTERN'
  ) then
    perform catchmenu_knowledge.detect_knowledge_gap(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_gap_type := 'MISSING_SOP',
      p_domain := p_candidate_domain,
      p_gap_summary := p_candidate_title,
      p_triggering_exception_ids := '[]'::jsonb,
      p_gap_context := jsonb_build_object(
        'sop_candidate_id', v_candidate_id,
        'trigger_type', p_trigger_type,
        'trigger_count', p_trigger_count
      ),
      p_detection_threshold := 3
    );
  end if;

  return catchmenu_common.build_success_response(
    p_message_key := 'sop_candidate_created',
    p_data := jsonb_build_object(
      'candidate_id', v_candidate_id,
      'candidate_code', v_candidate_code,
      'candidate_title', p_candidate_title,
      'trigger_type', p_trigger_type,
      'priority_score', v_priority_score,
      'is_new', true,
      'next_step', 'AWAIT_HUMAN_REVIEW'
    ),
    p_locale := p_locale
  );
end;
$$;


create or replace function
  catchmenu_knowledge.get_ai_center_dashboard(
  p_tenant_id uuid,
  p_store_id uuid default null,
  p_period_days int default 7,
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
  v_query_summary jsonb;
  v_inquiry_summary jsonb;
  v_sop_candidates jsonb;
  v_pending_inquiries jsonb;
  v_top_categories jsonb;
  v_period_start timestamptz;
begin
  v_period_start := now()
    - (p_period_days || ' days')::interval;

  -- AI 쿼리 요약
  select jsonb_build_object(
    'total_queries', count(*),
    'grounded_queries', count(*) filter (
      where is_grounded = true
    ),
    'ungrounded_queries', count(*) filter (
      where is_grounded = false
    ),
    'grounding_rate_pct', case count(*)
      when 0 then 0
      else (
        count(*) filter (
          where is_grounded = true
        )::numeric / count(*) * 100
      )::int
    end,
    'helpful_rate_pct', case count(*) filter (
      where was_helpful is not null
    )
      when 0 then null
      else (
        count(*) filter (
          where was_helpful = true
        )::numeric
        / count(*) filter (
          where was_helpful is not null
        ) * 100
      )::int
    end,
    'escalated_to_human', count(*) filter (
      where escalated_to_human = true
    ),
    'avg_response_ms',
      coalesce(avg(response_time_ms)::int, 0)
  )
  into v_query_summary
  from catchmenu_knowledge.ai_query_logs
  where tenant_id = p_tenant_id
    and (
      p_store_id is null
      or store_id = p_store_id
    )
    and created_at > v_period_start;

  -- 문의 현황 요약
  select jsonb_build_object(
    'total_inquiries', count(*),
    'open', count(*) filter (
      where inquiry_status in (
        'OPEN', 'AI_PROCESSING'
      )
    ),
    'pending_human', count(*) filter (
      where inquiry_status = 'PENDING_HUMAN'
    ),
    'in_progress', count(*) filter (
      where inquiry_status = 'IN_PROGRESS'
    ),
    'resolved', count(*) filter (
      where inquiry_status in (
        'RESOLVED', 'AI_ANSWERED'
      )
    ),
    'ai_resolved', count(*) filter (
      where ai_resolved = true
    ),
    'recurring', count(*) filter (
      where is_recurring = true
    ),
    'ai_resolution_rate_pct', case count(*)
      when 0 then 0
      else (
        count(*) filter (
          where ai_resolved = true
        )::numeric / count(*) * 100
      )::int
    end
  )
  into v_inquiry_summary
  from catchmenu_knowledge.customer_inquiries
  where tenant_id = p_tenant_id
    and (
      p_store_id is null
      or store_id = p_store_id
    )
    and created_at > v_period_start;

  -- SOP 후보 현황
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'candidate_id', id,
        'candidate_code', candidate_code,
        'candidate_title', candidate_title,
        'candidate_domain', candidate_domain,
        'trigger_type', trigger_type,
        'trigger_count', trigger_count,
        'priority_score', priority_score,
        'candidate_status', candidate_status,
        'created_at', created_at
      )
      order by priority_score desc,
               trigger_count desc
    ),
    '[]'::jsonb
  )
  into v_sop_candidates
  from catchmenu_knowledge.sop_candidates
  where tenant_id = p_tenant_id
    and candidate_status in (
      'DETECTED', 'DRAFT_GENERATED',
      'UNDER_REVIEW'
    )
    and is_active = true
  limit 10;

  -- 미처리 문의 (우선순위 순)
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'inquiry_id', ci.id,
        'inquiry_number', ci.inquiry_number,
        'inquiry_type', ci.inquiry_type,
        'inquiry_status', ci.inquiry_status,
        'category_code', ic.category_code,
        'category_name', coalesce(
          ic.category_name_i18n->>p_locale,
          ic.category_name
        ),
        'priority', ci.priority,
        'is_recurring', ci.is_recurring,
        'created_at', ci.created_at,
        'wait_minutes', extract(
          epoch from (now() - ci.created_at)
        )::int / 60
      )
      order by
        case ci.priority
          when 'URGENT' then 0
          when 'HIGH' then 1
          else 2
        end,
        ci.created_at asc
    ),
    '[]'::jsonb
  )
  into v_pending_inquiries
  from catchmenu_knowledge.customer_inquiries ci
  left join catchmenu_knowledge.inquiry_categories ic
    on ic.id = ci.category_id
  where ci.tenant_id = p_tenant_id
    and (
      p_store_id is null
      or ci.store_id = p_store_id
    )
    and ci.inquiry_status in (
      'PENDING_HUMAN', 'IN_PROGRESS'
    )
  limit 20;

  -- 카테고리별 문의 빈도
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'category_code', ic.category_code,
        'category_name', coalesce(
          ic.category_name_i18n->>p_locale,
          ic.category_name
        ),
        'count', count(*),
        'ai_resolved_rate', (
          count(*) filter (
            where ci.ai_resolved = true
          )::numeric
          / nullif(count(*), 0) * 100
        )::int
      )
      order by count(*) desc
    ),
    '[]'::jsonb
  )
  into v_top_categories
  from catchmenu_knowledge.customer_inquiries ci
  join catchmenu_knowledge.inquiry_categories ic
    on ic.id = ci.category_id
  where ci.tenant_id = p_tenant_id
    and (
      p_store_id is null
      or ci.store_id = p_store_id
    )
    and ci.created_at > v_period_start
    and ci.category_id is not null
  group by ic.category_code,
           ic.category_name,
           ic.category_name_i18n
  limit 5;

  return catchmenu_common.build_success_response(
    p_message_key := 'ai_center_dashboard_loaded',
    p_data := jsonb_build_object(
      'period_days', p_period_days,
      'store_filter', p_store_id,
      'ai_queries', v_query_summary,
      'inquiries', v_inquiry_summary,
      'sop_candidates', v_sop_candidates,
      'sop_candidate_count',
        jsonb_array_length(v_sop_candidates),
      'pending_inquiries', v_pending_inquiries,
      'pending_count',
        jsonb_array_length(v_pending_inquiries),
      'top_categories', v_top_categories,
      'saas_note',
        'AI 고객센터 = 1-C차 SaaS 판매 필수 요건'
    ),
    p_locale := p_locale
  );
end;
$$;


-- pg_cron: 반복 문의 감지 (매일)
insert into catchmenu_common.pg_cron_jobs (
  job_code, pg_cron_job_name,
  schedule_cron_utc, schedule_cron_kst,
  sql_command, notes
) values
(
  'RECURRING_INQUIRY_DETECT',
  'catchmenu_recurring_inquiry',
  '0 19 * * *',
  '0 4 * * * (매일 새벽 4시 KST)',
  $sql$
SELECT catchmenu_knowledge
  .detect_recurring_inquiries(
    p_tenant_id :=
      '00000000-0000-0000-0000-000000000001'::uuid,
    p_min_count := 3,
    p_period_days := 30
  );
$sql$,
  '반복 문의 패턴 감지 → SOP 후보 자동 생성. 매일 새벽 4시.'
)
on conflict (job_code) do nothing;


-- grants
do $$
begin
  revoke all on function
    catchmenu_knowledge.log_ai_query(
      uuid, uuid, text, text, text, text,
      int, boolean, text, jsonb, jsonb,
      text, boolean, numeric, uuid, uuid, int
    ) from public;
  grant execute on function
    catchmenu_knowledge.log_ai_query(
      uuid, uuid, text, text, text, text,
      int, boolean, text, jsonb, jsonb,
      text, boolean, numeric, uuid, uuid, int
    ) to authenticated;

  revoke all on function
    catchmenu_knowledge.submit_customer_inquiry(
      uuid, uuid, text, text, text, text,
      uuid, uuid, text, text, uuid, text,
      boolean, text
    ) from public;
  grant execute on function
    catchmenu_knowledge.submit_customer_inquiry(
      uuid, uuid, text, text, text, text,
      uuid, uuid, text, text, uuid, text,
      boolean, text
    ) to authenticated;

  revoke all on function
    catchmenu_knowledge.resolve_inquiry(
      uuid, uuid, text, text, uuid, text, text
    ) from public;
  grant execute on function
    catchmenu_knowledge.resolve_inquiry(
      uuid, uuid, text, text, uuid, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_knowledge.detect_recurring_inquiries(
      uuid, uuid, int, int, text
    ) from public;
  grant execute on function
    catchmenu_knowledge.detect_recurring_inquiries(
      uuid, uuid, int, int, text
    ) to authenticated;

  revoke all on function
    catchmenu_knowledge.generate_sop_candidate(
      uuid, uuid, text, text, text,
      uuid, uuid, int, text
    ) from public;
  grant execute on function
    catchmenu_knowledge.generate_sop_candidate(
      uuid, uuid, text, text, text,
      uuid, uuid, int, text
    ) to authenticated;

  revoke all on function
    catchmenu_knowledge.get_ai_center_dashboard(
      uuid, uuid, int, text
    ) from public;
  grant execute on function
    catchmenu_knowledge.get_ai_center_dashboard(
      uuid, uuid, int, text
    ) to authenticated;
end;
$$;

comment on function
  catchmenu_knowledge.submit_customer_inquiry(
    uuid, uuid, text, text, text, text,
    uuid, uuid, text, text, uuid, text,
    boolean, text
  ) is
  '고객 문의 접수.
   AI 처리 흐름:
   1. 고객 문의 접수 (OPEN)
   2. AI 쿼리 실행 (AI_PROCESSING)
   3-a. AI 해결 → AI_ANSWERED (종료)
   3-b. AI 미해결 → PENDING_HUMAN
   4. 직원 처리 → IN_PROGRESS → RESOLVED
   반복 문의 3회 이상 → SOP 후보 자동 생성.
   특허3: 반복 문의 → Knowledge Gap
          → SOP 후보 → Human 검토 → 발행.
   1-C차 AI 고객센터 핵심 플로우.';

comment on function
  catchmenu_knowledge.get_ai_center_dashboard(
    uuid, uuid, int, text
  ) is
  'AI 고객센터 운영 대시보드.
   포함 데이터:
   - AI 쿼리 요약 (그라운딩률/도움됨률)
   - 문의 현황 (AI해결률/반복문의)
   - SOP 후보 목록 (우선순위 순)
   - 미처리 문의 (대기 중)
   - 카테고리별 문의 빈도
   SaaS 판매 필수 요건:
   grounding_rate_pct > 80% 목표.
   ai_resolution_rate_pct > 60% 목표.
   1-C차 완전 SaaS = AI 고객센터 포함.';