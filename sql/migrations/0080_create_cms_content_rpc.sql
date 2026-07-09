-- 0080_create_cms_content_rpc.sql
-- Purpose: CMS content management RPCs.
--          Menu content, store notices, promotions,
--          banner management, content versioning.
--          1-B차 CMS 메뉴/콘텐츠 관리 기반.
-- Depends on: 0079_create_did_advanced_rpc.sql
-- Creates:
--   catchmenu_store.cms_contents (table)
--   catchmenu_store.cms_content_versions (table)
--   catchmenu_store.store_notices (table)
--   catchmenu_store.promotions (table)
--   function catchmenu_store.publish_cms_content(...)
--   function catchmenu_store.get_cms_content(...)
--   function catchmenu_store.create_store_notice(...)
--   function catchmenu_store.get_active_notices(...)
--   function catchmenu_store.create_promotion(...)
--   function catchmenu_store.get_active_promotions(...)
--   function catchmenu_store.get_store_cms_bundle(...)

-- =============================================
-- cms_contents table
-- CMS 콘텐츠 마스터
-- =============================================
create table if not exists
  catchmenu_store.cms_contents (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid
    references catchmenu_hq.stores(id),

  -- 콘텐츠 식별
  content_code text not null,
  content_name text not null,
  content_type text not null,
  content_category text not null
    default 'GENERAL',

  -- 현재 버전
  current_version_id uuid,
  current_version_number int
    not null default 0,

  -- 상태
  content_status text not null default 'DRAFT',
  published_at timestamptz,
  published_by uuid,

  -- 표시 설정
  display_channels jsonb
    default '["APP","KIOSK","DID"]'::jsonb,
  target_locales jsonb
    default '["ko"]'::jsonb,

  -- 유효 기간
  valid_from timestamptz,
  valid_until timestamptz,

  -- 다국어 지원
  is_i18n boolean not null default false,

  -- 통계
  view_count int not null default 0,
  last_viewed_at timestamptz,

  is_active boolean not null default true,
  created_by uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint uq_cms_content unique (
    tenant_id, store_id, content_code
  ),
  constraint chk_content_type check (
    content_type in (
      'MENU_BOARD',     -- 메뉴판
      'BANNER',         -- 배너
      'NOTICE',         -- 공지
      'PROMOTION',      -- 프로모션
      'EVENT',          -- 이벤트
      'GUIDE',          -- 안내
      'ALLERGEN_INFO',  -- 알레르겐 안내
      'OPERATING_HOURS',-- 영업시간
      'CUSTOM'          -- 커스텀
    )
  ),
  constraint chk_content_status check (
    content_status in (
      'DRAFT', 'REVIEW', 'PUBLISHED',
      'SCHEDULED', 'EXPIRED', 'ARCHIVED'
    )
  )
);

create index if not exists idx_cms_contents_store
  on catchmenu_store.cms_contents(
    store_id, content_type, content_status
  ) where is_active = true;
create index if not exists idx_cms_contents_tenant
  on catchmenu_store.cms_contents(
    tenant_id, content_type
  ) where store_id is null;

alter table catchmenu_store.cms_contents
  enable row level security;
alter table catchmenu_store.cms_contents
  force row level security;

drop policy if exists cms_contents_isolation
  on catchmenu_store.cms_contents;
create policy cms_contents_isolation
  on catchmenu_store.cms_contents
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and (
      store_id is null
      or store_id = catchmenu_common.current_store_id()
    )
  );

drop trigger if exists trg_cms_contents_updated
  on catchmenu_store.cms_contents;
create trigger trg_cms_contents_updated
  before update on catchmenu_store.cms_contents
  for each row execute function
    catchmenu_common.set_updated_at();

comment on table catchmenu_store.cms_contents is
  'CMS 콘텐츠 마스터.
   store_id = null: 테넌트 전체 공통 콘텐츠.
   store_id 있음: 매장별 콘텐츠.
   display_channels: 표시 채널 (APP/KIOSK/DID).
   content_type:
     MENU_BOARD: Flutter 메뉴판 콘텐츠
     BANNER: 앱/키오스크 배너
     PROMOTION: 할인/이벤트 프로모션
   1-B차 CMS 메뉴/콘텐츠 관리 기반.';


-- =============================================
-- cms_content_versions table
-- 콘텐츠 버전 관리
-- =============================================
create table if not exists
  catchmenu_store.cms_content_versions (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  content_id uuid not null
    references catchmenu_store.cms_contents(id),

  version_number int not null,
  version_status text not null default 'DRAFT',

  -- 콘텐츠 데이터 (i18n 포함)
  content_data jsonb not null default '{}'::jsonb,
  content_data_ko jsonb,
  content_data_en jsonb,
  content_data_zh jsonb,
  content_data_ja jsonb,

  -- 미디어
  image_urls jsonb default '[]'::jsonb,
  video_url text,
  thumbnail_url text,

  -- 변경 정보
  change_summary text,
  created_by uuid,
  reviewed_by uuid,
  reviewed_at timestamptz,
  published_at timestamptz,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint uq_content_version unique (
    content_id, version_number
  ),
  constraint chk_version_status check (
    version_status in (
      'DRAFT', 'REVIEW', 'PUBLISHED',
      'SUPERSEDED', 'ARCHIVED'
    )
  )
);

create index if not exists idx_cms_versions_content
  on catchmenu_store.cms_content_versions(
    content_id, version_number desc
  );

alter table catchmenu_store.cms_content_versions
  enable row level security;
alter table catchmenu_store.cms_content_versions
  force row level security;

drop policy if exists cms_versions_isolation
  on catchmenu_store.cms_content_versions;
create policy cms_versions_isolation
  on catchmenu_store.cms_content_versions
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
  );

drop trigger if exists trg_cms_versions_updated
  on catchmenu_store.cms_content_versions;
create trigger trg_cms_versions_updated
  before update on
    catchmenu_store.cms_content_versions
  for each row execute function
    catchmenu_common.set_updated_at();

comment on table
  catchmenu_store.cms_content_versions is
  '콘텐츠 버전 관리.
   version_number: 자동 증가.
   content_data: 기본 데이터.
   content_data_ko/en/zh/ja: 다국어 데이터.
   SUPERSEDED: 이전 버전 (조회 가능, 복원 가능).
   특허4: 콘텐츠 버전 = 감사 추적 가능.';


-- =============================================
-- store_notices table
-- 매장 공지사항
-- =============================================
create table if not exists
  catchmenu_store.store_notices (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid not null
    references catchmenu_hq.stores(id),

  -- 공지 정보
  notice_code text not null,
  notice_type text not null,
  priority text not null default 'NORMAL',

  -- 내용 (다국어)
  title jsonb not null
    default '{}'::jsonb,
  body jsonb not null
    default '{}'::jsonb,

  -- 표시 설정
  display_channels jsonb
    default '["APP","KIOSK"]'::jsonb,
  show_on_main boolean not null default false,
  show_on_did boolean not null default false,
  requires_confirm boolean not null default false,

  -- 유효 기간
  valid_from timestamptz not null default now(),
  valid_until timestamptz,

  -- 상태
  notice_status text not null default 'ACTIVE',
  created_by uuid,
  confirmed_count int not null default 0,

  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint uq_notice_code unique (
    store_id, notice_code
  ),
  constraint chk_notice_type check (
    notice_type in (
      'OPERATING_HOURS_CHANGE',
      'MENU_CHANGE',
      'TEMPORARY_CLOSURE',
      'HOLIDAY_NOTICE',
      'PROMOTION_START',
      'ALLERGY_WARNING',
      'SYSTEM_MAINTENANCE',
      'GENERAL'
    )
  ),
  constraint chk_notice_priority check (
    priority in (
      'URGENT', 'HIGH', 'NORMAL', 'LOW'
    )
  ),
  constraint chk_notice_status check (
    notice_status in (
      'ACTIVE', 'EXPIRED',
      'CANCELLED', 'SCHEDULED'
    )
  )
);

create index if not exists idx_store_notices_active
  on catchmenu_store.store_notices(
    store_id, priority, valid_from desc
  )
  where notice_status = 'ACTIVE'
    and is_active = true;

alter table catchmenu_store.store_notices
  enable row level security;
alter table catchmenu_store.store_notices
  force row level security;

drop policy if exists store_notices_isolation
  on catchmenu_store.store_notices;
create policy store_notices_isolation
  on catchmenu_store.store_notices
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id = catchmenu_common.current_store_id()
  );

drop trigger if exists trg_store_notices_updated
  on catchmenu_store.store_notices;
create trigger trg_store_notices_updated
  before update on catchmenu_store.store_notices
  for each row execute function
    catchmenu_common.set_updated_at();

comment on table catchmenu_store.store_notices is
  '매장 공지사항.
   title/body: jsonb i18n 구조
   {"ko": "내용", "en": "Content"}.
   show_on_main: 앱 메인 화면 표시.
   show_on_did: DID 표시 여부.
   requires_confirm: 고객 확인 필요.
   ALLERGY_WARNING: 식품위생법 알레르겐 경고.
   1-B차 매장별 설정/공지 관리 기반.';


-- =============================================
-- promotions table
-- 프로모션/이벤트 관리
-- =============================================
create table if not exists
  catchmenu_store.promotions (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid not null
    references catchmenu_hq.stores(id),

  -- 프로모션 정보
  promotion_code text not null,
  promotion_name text not null,
  promotion_type text not null,

  -- 내용 (다국어)
  title jsonb not null default '{}'::jsonb,
  description jsonb not null
    default '{}'::jsonb,

  -- 혜택 정보
  benefit_type text not null,
  discount_type text,
  discount_value int,
  discount_pct numeric(5,2),
  min_order_amount int,
  max_discount_amount int,

  -- 대상 메뉴 (빈 배열 = 전체)
  target_menu_ids jsonb default '[]'::jsonb,
  target_category_ids jsonb default '[]'::jsonb,

  -- 쿠폰 연결
  coupon_id uuid,

  -- 유효 기간
  valid_from timestamptz not null,
  valid_until timestamptz,

  -- 사용 제한
  max_uses int,
  current_uses int not null default 0,
  max_uses_per_customer int default 1,

  -- 표시
  banner_image_url text,
  display_channels jsonb
    default '["APP","KIOSK"]'::jsonb,
  display_order int not null default 0,

  -- 상태
  promotion_status text
    not null default 'SCHEDULED',
  is_active boolean not null default true,
  created_by uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint uq_promotion_code unique (
    store_id, promotion_code
  ),
  constraint chk_promotion_type check (
    promotion_type in (
      'DISCOUNT',       -- 할인
      'FREE_ITEM',      -- 무료 증정
      'BUNDLE',         -- 묶음 할인
      'HAPPY_HOUR',     -- 해피아워
      'FIRST_ORDER',    -- 첫 주문 혜택
      'LOYALTY',        -- 단골 혜택
      'SEASONAL',       -- 시즌 이벤트
      'CUSTOM'
    )
  ),
  constraint chk_benefit_type check (
    benefit_type in (
      'AMOUNT_DISCOUNT',  -- 금액 할인
      'PCT_DISCOUNT',     -- % 할인
      'FREE_ITEM',        -- 무료 제공
      'POINT_BONUS',      -- 포인트 보너스
      'COUPON_ISSUE'      -- 쿠폰 발급
    )
  ),
  constraint chk_promotion_status check (
    promotion_status in (
      'SCHEDULED', 'ACTIVE',
      'PAUSED', 'ENDED', 'CANCELLED'
    )
  )
);

create index if not exists idx_promotions_active
  on catchmenu_store.promotions(
    store_id, promotion_status,
    valid_from, valid_until
  ) where promotion_status in (
    'SCHEDULED', 'ACTIVE'
  ) and is_active = true;

alter table catchmenu_store.promotions
  enable row level security;
alter table catchmenu_store.promotions
  force row level security;

drop policy if exists promotions_isolation
  on catchmenu_store.promotions;
create policy promotions_isolation
  on catchmenu_store.promotions
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id = catchmenu_common.current_store_id()
  );

drop trigger if exists trg_promotions_updated
  on catchmenu_store.promotions;
create trigger trg_promotions_updated
  before update on catchmenu_store.promotions
  for each row execute function
    catchmenu_common.set_updated_at();

comment on table catchmenu_store.promotions is
  '프로모션/이벤트 관리.
   benefit_type:
     AMOUNT_DISCOUNT: 금액 할인 (discount_value원)
     PCT_DISCOUNT: % 할인 (discount_pct%)
     FREE_ITEM: 무료 증정 (target_menu_ids)
     POINT_BONUS: 포인트 N배 적립
     COUPON_ISSUE: 쿠폰 자동 발급
   max_uses: 전체 사용 한도.
   max_uses_per_customer: 1인당 사용 한도.
   1-B차 고객 멤버십 앱 + 포장 앱 연동 핵심.';


-- =============================================
-- RPCs
-- =============================================
create or replace function
  catchmenu_store.publish_cms_content(
  p_tenant_id uuid,
  p_store_id uuid,
  p_content_code text,
  p_content_name text,
  p_content_type text,
  p_content_data jsonb,
  p_content_data_ko jsonb default null,
  p_content_data_en jsonb default null,
  p_content_data_zh jsonb default null,
  p_content_data_ja jsonb default null,
  p_display_channels jsonb
    default '["APP","KIOSK","DID"]'::jsonb,
  p_valid_from timestamptz default null,
  p_valid_until timestamptz default null,
  p_change_summary text default null,
  p_actor_id uuid default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_store,
                  catchmenu_common,
                  catchmenu_ledger
as $$
declare
  v_content_id uuid;
  v_version_id uuid;
  v_version_number int;
  v_is_new boolean;
  v_business_day date;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  -- 콘텐츠 마스터 upsert
  v_is_new := not exists (
    select 1 from catchmenu_store.cms_contents
    where tenant_id = p_tenant_id
      and coalesce(store_id::text, 'NULL')
        = coalesce(p_store_id::text, 'NULL')
      and content_code = p_content_code
  );

  insert into catchmenu_store.cms_contents (
    tenant_id, store_id,
    content_code, content_name, content_type,
    content_category, content_status,
    display_channels,
    valid_from, valid_until,
    is_i18n,
    published_at, published_by,
    created_by
  ) values (
    p_tenant_id, p_store_id,
    p_content_code, p_content_name,
    p_content_type, 'GENERAL', 'PUBLISHED',
    p_display_channels,
    p_valid_from, p_valid_until,
    p_content_data_ko is not null
      or p_content_data_en is not null,
    now(), p_actor_id,
    p_actor_id
  )
  on conflict (tenant_id, store_id, content_code)
  do update set
    content_name = excluded.content_name,
    content_status = 'PUBLISHED',
    display_channels = excluded.display_channels,
    valid_from = excluded.valid_from,
    valid_until = excluded.valid_until,
    is_i18n = excluded.is_i18n,
    published_at = now(),
    published_by = p_actor_id,
    updated_at = now()
  returning id, current_version_number
  into v_content_id, v_version_number;

  -- 버전 번호 결정
  v_version_number := coalesce(v_version_number, 0) + 1;

  -- 이전 버전 SUPERSEDED 처리
  update catchmenu_store.cms_content_versions
  set
    version_status = 'SUPERSEDED',
    updated_at = now()
  where content_id = v_content_id
    and version_status = 'PUBLISHED';

  -- 새 버전 생성
  insert into catchmenu_store.cms_content_versions (
    tenant_id, content_id,
    version_number, version_status,
    content_data,
    content_data_ko, content_data_en,
    content_data_zh, content_data_ja,
    change_summary,
    created_by, published_at
  ) values (
    p_tenant_id, v_content_id,
    v_version_number, 'PUBLISHED',
    p_content_data,
    p_content_data_ko, p_content_data_en,
    p_content_data_zh, p_content_data_ja,
    p_change_summary,
    p_actor_id, now()
  )
  returning id into v_version_id;

  -- 마스터 현재 버전 업데이트
  update catchmenu_store.cms_contents
  set
    current_version_id = v_version_id,
    current_version_number = v_version_number
  where id = v_content_id;

  -- Realtime → 앱/키오스크/DID 콘텐츠 업데이트
  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_channel_type := 'MENU_STATUS',
    p_event_type := 'cms_content_published',
    p_payload := jsonb_build_object(
      'content_id', v_content_id,
      'content_code', p_content_code,
      'content_type', p_content_type,
      'version_number', v_version_number,
      'is_new', v_is_new
    )
  );

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
    'store', 'cms_content_published', 1,
    'cms_content', v_content_id,
    case when v_is_new then null else 'PUBLISHED' end,
    'PUBLISHED',
    'STAFF', p_actor_id,
    jsonb_build_object(
      'content_code', p_content_code,
      'content_type', p_content_type,
      'version_number', v_version_number,
      'is_new', v_is_new,
      'change_summary', p_change_summary
    ),
    p_correlation_id,
    v_business_day, 'Asia/Seoul', now()
  );

  return jsonb_build_object(
    'success', true,
    'content_id', v_content_id,
    'version_id', v_version_id,
    'version_number', v_version_number,
    'content_code', p_content_code,
    'content_type', p_content_type,
    'is_new', v_is_new,
    'message_code', 'cms_content_published'
  );
end;
$$;


create or replace function
  catchmenu_store.get_cms_content(
  p_tenant_id uuid,
  p_store_id uuid,
  p_content_code text,
  p_locale text default 'ko',
  p_channel text default 'APP'
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_store,
                  catchmenu_common
as $$
declare
  v_content record;
  v_version record;
  v_localized_data jsonb;
begin
  -- 콘텐츠 조회
  select cc.id, cc.content_code,
         cc.content_name, cc.content_type,
         cc.content_status, cc.display_channels,
         cc.valid_from, cc.valid_until,
         cc.current_version_id,
         cc.current_version_number
  into v_content
  from catchmenu_store.cms_contents cc
  where cc.tenant_id = p_tenant_id
    and (
      cc.store_id = p_store_id
      or cc.store_id is null
    )
    and cc.content_code = p_content_code
    and cc.content_status = 'PUBLISHED'
    and cc.is_active = true
    and (
      cc.valid_from is null
      or cc.valid_from <= now()
    )
    and (
      cc.valid_until is null
      or cc.valid_until >= now()
    )
    and cc.display_channels @>
      to_jsonb(p_channel)
  order by
    case when cc.store_id = p_store_id
      then 0 else 1
    end
  limit 1;

  if v_content.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'no_knowledge_found',
      'content_code', p_content_code
    );
  end if;

  -- 현재 버전 데이터
  select cv.id, cv.version_number,
         cv.content_data,
         cv.content_data_ko, cv.content_data_en,
         cv.content_data_zh, cv.content_data_ja,
         cv.image_urls, cv.thumbnail_url,
         cv.published_at
  into v_version
  from catchmenu_store.cms_content_versions cv
  where cv.id = v_content.current_version_id;

  -- locale 기반 데이터 선택
  v_localized_data := coalesce(
    case p_locale
      when 'ko' then v_version.content_data_ko
      when 'en' then v_version.content_data_en
      when 'zh' then v_version.content_data_zh
      when 'ja' then v_version.content_data_ja
      else null
    end,
    v_version.content_data_ko,
    v_version.content_data
  );

  -- 조회수 증가
  update catchmenu_store.cms_contents
  set
    view_count = view_count + 1,
    last_viewed_at = now(),
    updated_at = now()
  where id = v_content.id;

  return jsonb_build_object(
    'success', true,
    'content_id', v_content.id,
    'content_code', v_content.content_code,
    'content_name', v_content.content_name,
    'content_type', v_content.content_type,
    'version_number', v_version.version_number,
    'locale', p_locale,
    'data', v_localized_data,
    'raw_data', v_version.content_data,
    'image_urls', v_version.image_urls,
    'thumbnail_url', v_version.thumbnail_url,
    'valid_until', v_content.valid_until,
    'published_at', v_version.published_at,
    'message_code', 'cms_content_loaded'
  );
end;
$$;


create or replace function
  catchmenu_store.create_store_notice(
  p_tenant_id uuid,
  p_store_id uuid,
  p_notice_code text,
  p_notice_type text,
  p_title_ko text,
  p_body_ko text,
  p_title_en text default null,
  p_body_en text default null,
  p_priority text default 'NORMAL',
  p_show_on_main boolean default false,
  p_show_on_did boolean default false,
  p_requires_confirm boolean default false,
  p_valid_until timestamptz default null,
  p_display_channels jsonb
    default '["APP","KIOSK"]'::jsonb,
  p_actor_id uuid default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_store,
                  catchmenu_common,
                  catchmenu_ledger
as $$
declare
  v_notice_id uuid;
  v_is_new boolean;
  v_business_day date;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  v_is_new := not exists (
    select 1 from catchmenu_store.store_notices
    where store_id = p_store_id
      and notice_code = p_notice_code
  );

  insert into catchmenu_store.store_notices (
    tenant_id, store_id,
    notice_code, notice_type, priority,
    title, body,
    display_channels,
    show_on_main, show_on_did,
    requires_confirm,
    valid_from, valid_until,
    notice_status, created_by
  ) values (
    p_tenant_id, p_store_id,
    p_notice_code, p_notice_type, p_priority,
    jsonb_build_object(
      'ko', p_title_ko,
      'en', coalesce(p_title_en, p_title_ko)
    ),
    jsonb_build_object(
      'ko', p_body_ko,
      'en', coalesce(p_body_en, p_body_ko)
    ),
    p_display_channels,
    p_show_on_main, p_show_on_did,
    p_requires_confirm,
    now(), p_valid_until,
    'ACTIVE', p_actor_id
  )
  on conflict (store_id, notice_code) do update set
    notice_type = excluded.notice_type,
    priority = excluded.priority,
    title = excluded.title,
    body = excluded.body,
    show_on_main = excluded.show_on_main,
    show_on_did = excluded.show_on_did,
    valid_until = excluded.valid_until,
    notice_status = 'ACTIVE',
    is_active = true,
    updated_at = now()
  returning id into v_notice_id;

  -- Realtime 알림
  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_channel_type := 'STORE_MODE',
    p_event_type := 'notice_created',
    p_payload := jsonb_build_object(
      'notice_id', v_notice_id,
      'notice_type', p_notice_type,
      'priority', p_priority,
      'show_on_main', p_show_on_main,
      'show_on_did', p_show_on_did
    )
  );

  -- ledger event (URGENT/HIGH만)
  if p_priority in ('URGENT', 'HIGH') then
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
      'store', 'urgent_notice_created', 1,
      'store_notice', v_notice_id,
      null, 'ACTIVE',
      'STAFF', p_actor_id,
      jsonb_build_object(
        'notice_code', p_notice_code,
        'notice_type', p_notice_type,
        'priority', p_priority
      ),
      p_correlation_id,
      v_business_day, 'Asia/Seoul', now()
    );
  end if;

  return jsonb_build_object(
    'success', true,
    'notice_id', v_notice_id,
    'notice_code', p_notice_code,
    'notice_type', p_notice_type,
    'priority', p_priority,
    'is_new', v_is_new,
    'message_code', 'notice_created'
  );
end;
$$;


create or replace function
  catchmenu_store.get_active_notices(
  p_tenant_id uuid,
  p_store_id uuid,
  p_channel text default 'APP',
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_store,
                  catchmenu_common
as $$
declare
  v_notices jsonb;
begin
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'notice_id', id,
        'notice_code', notice_code,
        'notice_type', notice_type,
        'priority', priority,
        'title', coalesce(
          title->>p_locale,
          title->>'ko'
        ),
        'body', coalesce(
          body->>p_locale,
          body->>'ko'
        ),
        'show_on_main', show_on_main,
        'show_on_did', show_on_did,
        'requires_confirm', requires_confirm,
        'valid_until', valid_until,
        'created_at', created_at
      )
      order by
        case priority
          when 'URGENT' then 0
          when 'HIGH' then 1
          when 'NORMAL' then 2
          else 3
        end,
        created_at desc
    ),
    '[]'::jsonb
  )
  into v_notices
  from catchmenu_store.store_notices
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and notice_status = 'ACTIVE'
    and is_active = true
    and valid_from <= now()
    and (
      valid_until is null
      or valid_until >= now()
    )
    and display_channels @> to_jsonb(p_channel);

  return jsonb_build_object(
    'success', true,
    'store_id', p_store_id,
    'channel', p_channel,
    'locale', p_locale,
    'notices', v_notices,
    'notice_count', jsonb_array_length(v_notices),
    'has_urgent',
      exists (
        select 1
        from jsonb_array_elements(v_notices) n
        where n->>'priority' = 'URGENT'
      ),
    'message_code', 'notices_loaded'
  );
end;
$$;


create or replace function
  catchmenu_store.create_promotion(
  p_tenant_id uuid,
  p_store_id uuid,
  p_promotion_code text,
  p_promotion_name text,
  p_promotion_type text,
  p_benefit_type text,
  p_title_ko text,
  p_description_ko text,
  p_valid_from timestamptz,
  p_valid_until timestamptz default null,
  p_discount_value int default null,
  p_discount_pct numeric default null,
  p_min_order_amount int default null,
  p_max_discount_amount int default null,
  p_target_menu_ids jsonb default '[]'::jsonb,
  p_max_uses int default null,
  p_max_uses_per_customer int default 1,
  p_banner_image_url text default null,
  p_actor_id uuid default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_store,
                  catchmenu_common,
                  catchmenu_ledger
as $$
declare
  v_promotion_id uuid;
  v_is_new boolean;
  v_initial_status text;
  v_business_day date;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  -- 시작 시각 기준 상태 결정
  v_initial_status := case
    when p_valid_from <= now() then 'ACTIVE'
    else 'SCHEDULED'
  end;

  v_is_new := not exists (
    select 1 from catchmenu_store.promotions
    where store_id = p_store_id
      and promotion_code = p_promotion_code
  );

  insert into catchmenu_store.promotions (
    tenant_id, store_id,
    promotion_code, promotion_name,
    promotion_type, benefit_type,
    title, description,
    valid_from, valid_until,
    discount_value, discount_pct,
    min_order_amount, max_discount_amount,
    target_menu_ids,
    max_uses, max_uses_per_customer,
    banner_image_url,
    display_channels,
    promotion_status, created_by
  ) values (
    p_tenant_id, p_store_id,
    p_promotion_code, p_promotion_name,
    p_promotion_type, p_benefit_type,
    jsonb_build_object('ko', p_title_ko),
    jsonb_build_object('ko', p_description_ko),
    p_valid_from, p_valid_until,
    p_discount_value, p_discount_pct,
    p_min_order_amount, p_max_discount_amount,
    coalesce(p_target_menu_ids, '[]'::jsonb),
    p_max_uses, p_max_uses_per_customer,
    p_banner_image_url,
    '["APP","KIOSK"]'::jsonb,
    v_initial_status, p_actor_id
  )
  on conflict (store_id, promotion_code)
  do update set
    promotion_name = excluded.promotion_name,
    valid_from = excluded.valid_from,
    valid_until = excluded.valid_until,
    discount_value = excluded.discount_value,
    discount_pct = excluded.discount_pct,
    promotion_status = v_initial_status,
    is_active = true,
    updated_at = now()
  returning id into v_promotion_id;

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
    'store', 'promotion_created', 1,
    'promotion', v_promotion_id,
    null, v_initial_status,
    'STAFF', p_actor_id,
    jsonb_build_object(
      'promotion_code', p_promotion_code,
      'promotion_type', p_promotion_type,
      'benefit_type', p_benefit_type,
      'valid_from', p_valid_from,
      'valid_until', p_valid_until
    ),
    p_correlation_id,
    v_business_day, 'Asia/Seoul', now()
  );

  return jsonb_build_object(
    'success', true,
    'promotion_id', v_promotion_id,
    'promotion_code', p_promotion_code,
    'promotion_type', p_promotion_type,
    'promotion_status', v_initial_status,
    'is_new', v_is_new,
    'message_code', 'promotion_created'
  );
end;
$$;


create or replace function
  catchmenu_store.get_active_promotions(
  p_tenant_id uuid,
  p_store_id uuid,
  p_channel text default 'APP',
  p_locale text default 'ko',
  p_menu_id uuid default null
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_store,
                  catchmenu_common
as $$
declare
  v_promotions jsonb;
begin
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'promotion_id', id,
        'promotion_code', promotion_code,
        'promotion_name', promotion_name,
        'promotion_type', promotion_type,
        'benefit_type', benefit_type,
        'title', coalesce(
          title->>p_locale, title->>'ko'
        ),
        'description', coalesce(
          description->>p_locale,
          description->>'ko'
        ),
        'discount_value', discount_value,
        'discount_pct', discount_pct,
        'min_order_amount', min_order_amount,
        'max_discount_amount',
          max_discount_amount,
        'target_menu_ids', target_menu_ids,
        'valid_until', valid_until,
        'remaining_uses', case
          when max_uses is not null
          then max_uses - current_uses
          else null
        end,
        'banner_image_url', banner_image_url,
        'display_order', display_order
      )
      order by display_order asc,
               valid_from desc
    ),
    '[]'::jsonb
  )
  into v_promotions
  from catchmenu_store.promotions
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and promotion_status = 'ACTIVE'
    and is_active = true
    and valid_from <= now()
    and (
      valid_until is null
      or valid_until >= now()
    )
    and (
      max_uses is null
      or current_uses < max_uses
    )
    and display_channels @> to_jsonb(p_channel)
    and (
      p_menu_id is null
      or jsonb_array_length(target_menu_ids) = 0
      or target_menu_ids @>
        to_jsonb(p_menu_id)
    );

  return jsonb_build_object(
    'success', true,
    'store_id', p_store_id,
    'channel', p_channel,
    'locale', p_locale,
    'promotions', v_promotions,
    'promotion_count',
      jsonb_array_length(v_promotions),
    'message_code', 'promotions_loaded'
  );
end;
$$;


create or replace function
  catchmenu_store.get_store_cms_bundle(
  p_tenant_id uuid,
  p_store_id uuid,
  p_channel text default 'APP',
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_store,
                  catchmenu_common,
                  catchmenu_hq
as $$
declare
  v_store record;
  v_notices jsonb;
  v_promotions jsonb;
  v_cms_contents jsonb;
  v_business_day date;
  v_timezone text;
begin
  select id, store_name, timezone
  into v_store
  from catchmenu_hq.stores
  where id = p_store_id
    and tenant_id = p_tenant_id
    and is_active = true;

  if v_store.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'store_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'get_store_cms_bundle'
    );
  end if;

  v_timezone := v_store.timezone;
  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  -- 공지사항
  v_notices := (
    catchmenu_store.get_active_notices(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_channel := p_channel,
      p_locale := p_locale
    )
  )->'notices';

  -- 프로모션
  v_promotions := (
    catchmenu_store.get_active_promotions(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_channel := p_channel,
      p_locale := p_locale
    )
  )->'promotions';

  -- CMS 콘텐츠 (배너/메뉴판 등)
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'content_id', cc.id,
        'content_code', cc.content_code,
        'content_name', cc.content_name,
        'content_type', cc.content_type,
        'version_number',
          cc.current_version_number,
        'data', coalesce(
          case p_locale
            when 'ko' then cv.content_data_ko
            when 'en' then cv.content_data_en
            when 'zh' then cv.content_data_zh
            when 'ja' then cv.content_data_ja
            else null
          end,
          cv.content_data_ko,
          cv.content_data
        ),
        'image_urls', cv.image_urls,
        'thumbnail_url', cv.thumbnail_url
      )
      order by cc.content_type, cc.content_code
    ),
    '[]'::jsonb
  )
  into v_cms_contents
  from catchmenu_store.cms_contents cc
  left join catchmenu_store.cms_content_versions cv
    on cv.id = cc.current_version_id
  where cc.tenant_id = p_tenant_id
    and (
      cc.store_id = p_store_id
      or cc.store_id is null
    )
    and cc.content_status = 'PUBLISHED'
    and cc.is_active = true
    and (
      cc.valid_from is null
      or cc.valid_from <= now()
    )
    and (
      cc.valid_until is null
      or cc.valid_until >= now()
    )
    and cc.display_channels @>
      to_jsonb(p_channel);

  return jsonb_build_object(
    'success', true,
    'store', jsonb_build_object(
      'id', v_store.id,
      'store_name', v_store.store_name
    ),
    'channel', p_channel,
    'locale', p_locale,
    'business_day', v_business_day,
    'notices', coalesce(v_notices, '[]'::jsonb),
    'notice_count',
      jsonb_array_length(
        coalesce(v_notices, '[]'::jsonb)
      ),
    'promotions',
      coalesce(v_promotions, '[]'::jsonb),
    'promotion_count',
      jsonb_array_length(
        coalesce(v_promotions, '[]'::jsonb)
      ),
    'cms_contents',
      coalesce(v_cms_contents, '[]'::jsonb),
    'cms_count',
      jsonb_array_length(
        coalesce(v_cms_contents, '[]'::jsonb)
      ),
    'has_urgent_notice', exists (
      select 1
      from jsonb_array_elements(
        coalesce(v_notices, '[]'::jsonb)
      ) n
      where n->>'priority' = 'URGENT'
    ),
    'generated_at', now(),
    'message_code', 'cms_bundle_loaded'
  );
end;
$$;


-- pg_cron: 프로모션 상태 자동 업데이트
insert into catchmenu_common.pg_cron_jobs (
  job_code, pg_cron_job_name,
  schedule_cron_utc, schedule_cron_kst,
  sql_command, notes
) values
(
  'PROMOTION_STATUS_UPDATE',
  'catchmenu_promotion_status',
  '*/10 * * * *',
  '*/10 * * * * (10분마다)',
  $sql$
-- 시작된 프로모션 활성화
UPDATE catchmenu_store.promotions
SET promotion_status = 'ACTIVE', updated_at = now()
WHERE promotion_status = 'SCHEDULED'
  AND valid_from <= now()
  AND (valid_until IS NULL OR valid_until >= now());

-- 종료된 프로모션 만료
UPDATE catchmenu_store.promotions
SET promotion_status = 'ENDED', updated_at = now()
WHERE promotion_status = 'ACTIVE'
  AND valid_until IS NOT NULL
  AND valid_until < now();

-- 만료된 공지 처리
UPDATE catchmenu_store.store_notices
SET notice_status = 'EXPIRED', updated_at = now()
WHERE notice_status = 'ACTIVE'
  AND valid_until IS NOT NULL
  AND valid_until < now();
$sql$,
  '프로모션 상태 자동 전환 + 공지 만료 처리. 10분마다.'
)
on conflict (job_code) do nothing;


-- grants
do $$
begin
  revoke all on function
    catchmenu_store.publish_cms_content(
      uuid, uuid, text, text, text,
      jsonb, jsonb, jsonb, jsonb, jsonb,
      jsonb, timestamptz, timestamptz,
      text, uuid, text
    ) from public;
  grant execute on function
    catchmenu_store.publish_cms_content(
      uuid, uuid, text, text, text,
      jsonb, jsonb, jsonb, jsonb, jsonb,
      jsonb, timestamptz, timestamptz,
      text, uuid, text
    ) to authenticated;

  revoke all on function
    catchmenu_store.get_cms_content(
      uuid, uuid, text, text, text
    ) from public;
  grant execute on function
    catchmenu_store.get_cms_content(
      uuid, uuid, text, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_store.create_store_notice(
      uuid, uuid, text, text, text, text,
      text, text, text, boolean, boolean,
      boolean, timestamptz, jsonb, uuid, text
    ) from public;
  grant execute on function
    catchmenu_store.create_store_notice(
      uuid, uuid, text, text, text, text,
      text, text, text, boolean, boolean,
      boolean, timestamptz, jsonb, uuid, text
    ) to authenticated;

  revoke all on function
    catchmenu_store.get_active_notices(
      uuid, uuid, text, text
    ) from public;
  grant execute on function
    catchmenu_store.get_active_notices(
      uuid, uuid, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_store.create_promotion(
      uuid, uuid, text, text, text, text,
      text, text, timestamptz, timestamptz,
      int, numeric, int, int, jsonb,
      int, int, text, uuid, text
    ) from public;
  grant execute on function
    catchmenu_store.create_promotion(
      uuid, uuid, text, text, text, text,
      text, text, timestamptz, timestamptz,
      int, numeric, int, int, jsonb,
      int, int, text, uuid, text
    ) to authenticated;

  revoke all on function
    catchmenu_store.get_active_promotions(
      uuid, uuid, text, text, uuid
    ) from public;
  grant execute on function
    catchmenu_store.get_active_promotions(
      uuid, uuid, text, text, uuid
    ) to authenticated;

  revoke all on function
    catchmenu_store.get_store_cms_bundle(
      uuid, uuid, text, text
    ) from public;
  grant execute on function
    catchmenu_store.get_store_cms_bundle(
      uuid, uuid, text, text
    ) to authenticated;
end;
$$;

comment on function
  catchmenu_store.get_store_cms_bundle(
    uuid, uuid, text, text
  ) is
  '앱/키오스크 시작 시 CMS 전체 번들 로드.
   단일 RPC 호출로:
   - 활성 공지사항 (긴급/높음/일반 순)
   - 활성 프로모션 (display_order 순)
   - 발행된 CMS 콘텐츠 (배너/메뉴판 등)
   channel: APP/KIOSK/DID 별 필터링.
   locale: 다국어 콘텐츠 자동 선택.
   has_urgent_notice: 긴급 공지 존재 여부.
   Flutter bootstrap_app 이후 별도 호출.
   1-B차 CMS 고도화 핵심 번들 RPC.';

comment on function
  catchmenu_store.publish_cms_content(
    uuid, uuid, text, text, text,
    jsonb, jsonb, jsonb, jsonb, jsonb,
    jsonb, timestamptz, timestamptz,
    text, uuid, text
  ) is
  'CMS 콘텐츠 발행 + 버전 관리.
   기존 PUBLISHED 버전 → SUPERSEDED 처리.
   새 버전 생성 → 마스터 버전 업데이트.
   Realtime → 앱/키오스크/DID 즉시 반영.
   i18n: content_data_ko/en/zh/ja 분리 저장.
   특허4: CMS 콘텐츠 = 버전 감사 추적.
   1-B차 CMS 메뉴/콘텐츠 관리 기반.';