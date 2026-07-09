-- 0107_create_mini_cms_pipeline_rpc.sql
-- Purpose: Mini CMS pipeline for store owners.
--          업주 앱에서 이벤트/배너/쿠폰 등록.
--          고객 앱 + 키오스크 + DID 동시 반영.
--          3차 키오스크 개발 시 재사용 설계.
--          향후 쿠폰 사업 플랫폼 기반.
--          i18n: 모든 메시지 = message_catalog 참조.
-- Depends on: 0106_create_delivery_platform_pipeline_rpc.sql
-- Creates:
--   catchmenu_store.cms_events (table)
--   catchmenu_store.cms_banners (table)
--   catchmenu_store.cms_popups (table)
--   catchmenu_store.cms_publish_log (table)
--   function catchmenu_store.create_cms_event(...)
--   function catchmenu_store.publish_cms_event(...)
--   function catchmenu_store.create_cms_banner(...)
--   function catchmenu_store.create_cms_popup(...)
--   function catchmenu_store.get_cms_dashboard(...)
--   function catchmenu_store.get_cms_display_bundle(...)

-- =============================================
-- i18n 메시지 등록
-- =============================================
insert into catchmenu_common.message_catalog (
  message_key, locale, message_text
) values
('cms_event_created', 'ko',
  '이벤트가 등록되었습니다'),
('cms_event_created', 'en',
  'Event created'),
('cms_event_published', 'ko',
  '이벤트가 발행되었습니다'),
('cms_event_published', 'en',
  'Event published'),
('cms_event_ended', 'ko',
  '이벤트가 종료되었습니다'),
('cms_event_ended', 'en',
  'Event ended'),
('cms_banner_created', 'ko',
  '배너가 등록되었습니다'),
('cms_banner_created', 'en',
  'Banner created'),
('cms_popup_created', 'ko',
  '팝업이 등록되었습니다'),
('cms_popup_created', 'en',
  'Popup created'),
('cms_dashboard_loaded', 'ko',
  'CMS 대시보드가 로드되었습니다'),
('cms_dashboard_loaded', 'en',
  'CMS dashboard loaded'),
('cms_display_bundle_loaded', 'ko',
  'CMS 표시 데이터가 로드되었습니다'),
('cms_display_bundle_loaded', 'en',
  'CMS display bundle loaded'),
('cms_event_not_found', 'ko',
  '이벤트를 찾을 수 없습니다'),
('cms_event_not_found', 'en',
  'Event not found'),
('cms_coupon_linked', 'ko',
  '이벤트에 쿠폰이 연결되었습니다'),
('cms_coupon_linked', 'en',
  'Coupon linked to event'),

-- 고객 앱 표시용 (6개 로케일)
('event_ongoing', 'ko', '진행 중'),
('event_ongoing', 'en', 'Ongoing'),
('event_ongoing', 'zh', '进行中'),
('event_ongoing', 'ja', '開催中'),
('event_ongoing', 'vi', 'Đang diễn ra'),
('event_ongoing', 'th', 'กำลังดำเนินการ'),

('event_dday', 'ko', '오늘 마감'),
('event_dday', 'en', 'Ends Today'),
('event_dday', 'zh', '今日截止'),
('event_dday', 'ja', '本日終了'),
('event_dday', 'vi', 'Kết thúc hôm nay'),
('event_dday', 'th', 'สิ้นสุดวันนี้'),

('event_new', 'ko', '새 이벤트'),
('event_new', 'en', 'New Event'),
('event_new', 'zh', '新活动'),
('event_new', 'ja', '新しいイベント'),
('event_new', 'vi', 'Sự kiện mới'),
('event_new', 'th', 'กิจกรรมใหม่'),

('tap_for_coupon', 'ko', '탭해서 쿠폰받기'),
('tap_for_coupon', 'en', 'Tap for coupon'),
('tap_for_coupon', 'zh', '点击领取优惠券'),
('tap_for_coupon', 'ja', 'タップしてクーポンをゲット'),
('tap_for_coupon', 'vi', 'Nhấn để nhận phiếu'),
('tap_for_coupon', 'th', 'แตะเพื่อรับคูปอง')
on conflict (message_key, locale) do nothing;

insert into catchmenu_common.error_codes (
  code, error_key, error_domain,
  error_category, http_status, severity
) values
(7030, 'cms_event_not_found',
  'STORE', 'NOT_FOUND', 404, 'WARNING'),
(7031, 'cms_event_not_publishable',
  'STORE', 'BUSINESS_RULE', 409, 'WARNING'),
(7032, 'cms_banner_not_found',
  'STORE', 'NOT_FOUND', 404, 'WARNING'),
(7033, 'cms_display_limit_exceeded',
  'STORE', 'CAPACITY', 429, 'WARNING')
on conflict (code) do nothing;


-- =============================================
-- cms_events table
-- 업주 이벤트 (할인/특가/기념일 등)
-- =============================================
create table if not exists
  catchmenu_store.cms_events (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid not null
    references catchmenu_hq.stores(id),

  -- 이벤트 기본 정보
  event_code text not null,
  event_type text not null,
  event_status text not null default 'DRAFT',

  -- 다국어 제목/내용
  title_ko text not null,
  title_en text,
  title_zh text,
  title_ja text,
  title_vi text,
  title_th text,

  body_ko text,
  body_en text,
  body_zh text,
  body_ja text,
  body_vi text,
  body_th text,

  -- 이미지
  thumbnail_url text,
  banner_image_url text,
  detail_image_urls jsonb default '[]'::jsonb,

  -- 기간
  valid_from timestamptz,
  valid_until timestamptz,

  -- 대상
  display_targets jsonb
    not null default
      '["CUSTOMER_APP","KIOSK","DID"]'::jsonb,
  target_membership_tiers jsonb
    default '["ALL"]'::jsonb,

  -- 연결 쿠폰
  linked_coupon_id uuid
    references catchmenu_store.coupons(id),
  coupon_auto_issue boolean
    not null default false,

  -- 표시 설정
  display_order int not null default 0,
  is_featured boolean not null default false,
  badge_text_key text,

  -- 통계
  view_count int not null default 0,
  coupon_claim_count int not null default 0,
  tap_count int not null default 0,

  -- 발행 정보
  published_at timestamptz,
  published_by uuid,
  ended_at timestamptz,

  created_by uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint uq_cms_event_code unique (
    store_id, event_code
  ),
  constraint chk_event_type check (
    event_type in (
      'DISCOUNT',       -- 할인 이벤트
      'SPECIAL_PRICE',  -- 특가
      'NEW_MENU',       -- 신메뉴
      'ANNIVERSARY',    -- 기념일
      'SEASONAL',       -- 시즌
      'HAPPY_HOUR',     -- 해피아워
      'COMBO',          -- 세트/콤보
      'COUPON',         -- 쿠폰 이벤트
      'NOTICE',         -- 공지
      'CUSTOM'          -- 직접 작성
    )
  ),
  constraint chk_event_status check (
    event_status in (
      'DRAFT',
      'SCHEDULED',
      'ACTIVE',
      'ENDED',
      'CANCELLED'
    )
  )
);

create index if not exists idx_cms_events_store
  on catchmenu_store.cms_events(
    store_id, event_status,
    display_order, valid_from
  ) where event_status = 'ACTIVE';
create index if not exists idx_cms_events_valid
  on catchmenu_store.cms_events(
    store_id, valid_from, valid_until
  ) where event_status in (
    'SCHEDULED', 'ACTIVE'
  );

alter table catchmenu_store.cms_events
  enable row level security;
alter table catchmenu_store.cms_events
  force row level security;

drop policy if exists cms_events_isolation
  on catchmenu_store.cms_events;
create policy cms_events_isolation
  on catchmenu_store.cms_events
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id =
      catchmenu_common.current_store_id()
  );

drop trigger if exists trg_cms_events_updated
  on catchmenu_store.cms_events;
create trigger trg_cms_events_updated
  before update on catchmenu_store.cms_events
  for each row execute function
    catchmenu_common.set_updated_at();

comment on table catchmenu_store.cms_events is
  '업주 이벤트 관리.
   Mini CMS 핵심 테이블.
   display_targets: CUSTOMER_APP/KIOSK/DID
   linked_coupon_id: 쿠폰 이벤트 연결.
   coupon_auto_issue: 탭 시 자동 쿠폰 발급.
   badge_text_key: event_new/event_dday 등.
   3차 키오스크 개발 시 그대로 재사용.
   DID 연동 시 이벤트 배너 자동 표시.
   향후 쿠폰 사업 플랫폼 기반.';


-- =============================================
-- cms_banners table
-- 배너 관리
-- =============================================
create table if not exists
  catchmenu_store.cms_banners (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid not null
    references catchmenu_hq.stores(id),

  -- 배너 정보
  banner_code text not null,
  banner_type text not null,
  banner_status text not null default 'DRAFT',

  -- 다국어 텍스트
  title_ko text not null,
  title_en text,
  subtitle_ko text,
  subtitle_en text,

  -- 이미지
  image_url text,
  background_color text default '#FFFFFF',
  text_color text default '#000000',

  -- 링크
  link_type text default 'NONE',
  link_target text,
  linked_event_id uuid
    references catchmenu_store.cms_events(id),

  -- 표시 위치
  display_position text not null default 'TOP',
  display_targets jsonb
    not null default
      '["CUSTOMER_APP","KIOSK"]'::jsonb,
  display_order int not null default 0,

  -- 기간
  valid_from timestamptz,
  valid_until timestamptz,

  -- 통계
  view_count int not null default 0,
  tap_count int not null default 0,

  created_by uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint uq_cms_banner_code unique (
    store_id, banner_code
  ),
  constraint chk_banner_type check (
    banner_type in (
      'MAIN_TOP',    -- 메인 상단
      'MAIN_MIDDLE', -- 메인 중단
      'POPUP',       -- 팝업
      'FLOATING',    -- 플로팅
      'DID_FULL',    -- DID 전체 화면
      'DID_SIDE'     -- DID 사이드
    )
  ),
  constraint chk_banner_status check (
    banner_status in (
      'DRAFT', 'ACTIVE',
      'INACTIVE', 'EXPIRED'
    )
  ),
  constraint chk_display_position check (
    display_position in (
      'TOP', 'MIDDLE', 'BOTTOM',
      'FULL', 'FLOATING'
    )
  )
);

create index if not exists idx_cms_banners_store
  on catchmenu_store.cms_banners(
    store_id, banner_status,
    display_order
  ) where banner_status = 'ACTIVE';

alter table catchmenu_store.cms_banners
  enable row level security;
alter table catchmenu_store.cms_banners
  force row level security;

drop policy if exists cms_banners_isolation
  on catchmenu_store.cms_banners;
create policy cms_banners_isolation
  on catchmenu_store.cms_banners
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id =
      catchmenu_common.current_store_id()
  );

drop trigger if exists trg_cms_banners_updated
  on catchmenu_store.cms_banners;
create trigger trg_cms_banners_updated
  before update on catchmenu_store.cms_banners
  for each row execute function
    catchmenu_common.set_updated_at();

comment on table catchmenu_store.cms_banners is
  '배너 관리.
   Mini CMS 배너 모듈.
   display_targets: CUSTOMER_APP/KIOSK/DID.
   DID_FULL: DID 전체 화면 광고 배너.
   linked_event_id: 이벤트 연결.
   3차 키오스크 재사용.
   향후 외부 광고주 배너 삽입 포인트.';


-- =============================================
-- cms_popups table
-- 팝업 관리
-- =============================================
create table if not exists
  catchmenu_store.cms_popups (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid not null
    references catchmenu_hq.stores(id),

  popup_code text not null,
  popup_type text not null,
  popup_status text not null default 'DRAFT',

  -- 다국어 내용
  title_ko text not null,
  title_en text,
  body_ko text,
  body_en text,
  cta_text_key text,

  -- 이미지
  image_url text,

  -- 버튼
  primary_button_text_key text,
  primary_button_action text,
  secondary_button_text_key text,

  -- 표시 조건
  display_targets jsonb
    not null default
      '["CUSTOMER_APP"]'::jsonb,
  trigger_event text default 'APP_OPEN',
  show_once_per_session boolean
    not null default true,

  -- 연결
  linked_event_id uuid
    references catchmenu_store.cms_events(id),
  linked_coupon_id uuid
    references catchmenu_store.coupons(id),

  -- 기간
  valid_from timestamptz,
  valid_until timestamptz,

  -- 통계
  view_count int not null default 0,
  cta_click_count int not null default 0,
  dismiss_count int not null default 0,

  created_by uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint uq_cms_popup_code unique (
    store_id, popup_code
  ),
  constraint chk_popup_type check (
    popup_type in (
      'EVENT',      -- 이벤트 알림
      'COUPON',     -- 쿠폰 증정
      'NOTICE',     -- 공지
      'SURVEY',     -- 설문
      'RATING'      -- 평가 요청
    )
  ),
  constraint chk_popup_status check (
    popup_status in (
      'DRAFT', 'ACTIVE',
      'INACTIVE', 'EXPIRED'
    )
  ),
  constraint chk_trigger_event check (
    trigger_event in (
      'APP_OPEN',
      'ORDER_COMPLETE',
      'MENU_VIEW',
      'COUPON_PAGE',
      'CUSTOM'
    )
  )
);

create index if not exists idx_cms_popups_store
  on catchmenu_store.cms_popups(
    store_id, popup_status, valid_until
  ) where popup_status = 'ACTIVE';

alter table catchmenu_store.cms_popups
  enable row level security;
alter table catchmenu_store.cms_popups
  force row level security;

drop policy if exists cms_popups_isolation
  on catchmenu_store.cms_popups;
create policy cms_popups_isolation
  on catchmenu_store.cms_popups
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id =
      catchmenu_common.current_store_id()
  );

drop trigger if exists trg_cms_popups_updated
  on catchmenu_store.cms_popups;
create trigger trg_cms_popups_updated
  before update on catchmenu_store.cms_popups
  for each row execute function
    catchmenu_common.set_updated_at();

comment on table catchmenu_store.cms_popups is
  '팝업 관리.
   trigger_event: APP_OPEN/ORDER_COMPLETE.
   show_once_per_session: 세션당 1회.
   linked_coupon_id: 팝업 쿠폰 자동 발급 연결.
   RATING 팝업: 주문 완료 후 평가 요청.
   3차 키오스크 재사용.';


-- =============================================
-- cms_publish_log table
-- CMS 발행 이력
-- =============================================
create table if not exists
  catchmenu_store.cms_publish_log (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid not null
    references catchmenu_hq.stores(id),

  content_type text not null,
  content_id uuid not null,
  content_code text,

  action text not null,
  action_by uuid,
  action_reason text,

  before_status text,
  after_status text,

  display_targets jsonb,
  realtime_notified boolean
    not null default false,

  actioned_at timestamptz
    not null default now(),

  constraint chk_content_type check (
    content_type in (
      'EVENT', 'BANNER', 'POPUP',
      'NOTICE', 'PROMOTION'
    )
  ),
  constraint chk_cms_action check (
    action in (
      'CREATED', 'PUBLISHED',
      'UPDATED', 'ENDED',
      'CANCELLED', 'DELETED'
    )
  )
);

create index if not exists idx_cms_publish_log
  on catchmenu_store.cms_publish_log(
    store_id, content_type, actioned_at desc
  );

alter table catchmenu_store.cms_publish_log
  enable row level security;
alter table catchmenu_store.cms_publish_log
  force row level security;

drop policy if exists cms_publish_log_isolation
  on catchmenu_store.cms_publish_log;
create policy cms_publish_log_isolation
  on catchmenu_store.cms_publish_log
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id =
      catchmenu_common.current_store_id()
  );

comment on table catchmenu_store.cms_publish_log is
  'CMS 발행 이력.
   append-only 감사 로그.
   업주가 언제 무엇을 발행/수정/종료했는지 추적.
   특허4: CMS 발행 = 운영 이벤트 감사.';


-- =============================================
-- RPCs
-- =============================================
create or replace function
  catchmenu_store.create_cms_event(
  p_tenant_id uuid,
  p_store_id uuid,
  p_event_type text,
  p_title_ko text,
  p_body_ko text default null,
  p_title_en text default null,
  p_body_en text default null,
  p_thumbnail_url text default null,
  p_banner_image_url text default null,
  p_valid_from timestamptz default null,
  p_valid_until timestamptz default null,
  p_display_targets jsonb
    default '["CUSTOMER_APP","KIOSK","DID"]'::jsonb,
  p_linked_coupon_id uuid default null,
  p_coupon_auto_issue boolean default false,
  p_is_featured boolean default false,
  p_created_by uuid default null,
  p_locale text default 'ko'
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
  v_event_id uuid;
  v_event_code text;
  v_badge_key text;
  v_business_day date;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  -- 이벤트 코드 생성
  v_event_code := 'EVT-'
    || to_char(now(), 'YYYYMMDD')
    || '-' || lpad(
      (
        select coalesce(count(*), 0) + 1
        from catchmenu_store.cms_events
        where store_id = p_store_id
          and tenant_id = p_tenant_id
      )::text, 4, '0'
    );

  -- 배지 텍스트 결정
  v_badge_key := case
    when p_valid_from is not null
      and p_valid_from > now()
      then 'event_new'
    when p_valid_until is not null
      and p_valid_until::date = v_business_day
      then 'event_dday'
    else 'event_ongoing'
  end;

  insert into catchmenu_store.cms_events (
    tenant_id, store_id,
    event_code, event_type,
    event_status,
    title_ko, title_en,
    body_ko, body_en,
    thumbnail_url, banner_image_url,
    valid_from, valid_until,
    display_targets,
    target_membership_tiers,
    linked_coupon_id,
    coupon_auto_issue,
    is_featured, badge_text_key,
    display_order,
    created_by
  ) values (
    p_tenant_id, p_store_id,
    v_event_code, p_event_type,
    case
      when p_valid_from is not null
        and p_valid_from > now()
        then 'SCHEDULED'
      else 'DRAFT'
    end,
    p_title_ko, p_title_en,
    p_body_ko, p_body_en,
    p_thumbnail_url, p_banner_image_url,
    p_valid_from, p_valid_until,
    p_display_targets,
    '["ALL"]'::jsonb,
    p_linked_coupon_id,
    p_coupon_auto_issue,
    p_is_featured, v_badge_key,
    0,
    p_created_by
  )
  returning id into v_event_id;

  -- 발행 로그
  insert into catchmenu_store.cms_publish_log (
    tenant_id, store_id,
    content_type, content_id, content_code,
    action, action_by,
    before_status, after_status,
    display_targets
  ) values (
    p_tenant_id, p_store_id,
    'EVENT', v_event_id, v_event_code,
    'CREATED', p_created_by,
    null, 'DRAFT',
    p_display_targets
  );

  -- ledger event
  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, caused_by_id,
    event_payload,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'cms', 'cms_event_created', 1,
    'cms_event', v_event_id,
    null, 'DRAFT',
    'STAFF', p_created_by,
    jsonb_build_object(
      'event_code', v_event_code,
      'event_type', p_event_type,
      'title_ko', p_title_ko,
      'has_coupon',
        p_linked_coupon_id is not null,
      'display_targets', p_display_targets
    ),
    v_business_day, 'Asia/Seoul', now()
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'cms_event_created',
    p_data := jsonb_build_object(
      'event_id', v_event_id,
      'event_code', v_event_code,
      'event_type', p_event_type,
      'event_status', 'DRAFT',
      'title_ko', p_title_ko,
      'display_targets', p_display_targets,
      'has_coupon',
        p_linked_coupon_id is not null,
      'coupon_auto_issue', p_coupon_auto_issue,
      'next_step',
        'publish_cms_event() 호출로 발행'
    ),
    p_locale := p_locale
  );
end;
$$;


create or replace function
  catchmenu_store.publish_cms_event(
  p_tenant_id uuid,
  p_store_id uuid,
  p_event_id uuid,
  p_published_by uuid default null,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_store,
                  catchmenu_common
as $$
declare
  v_event record;
begin
  select id, event_code, event_type,
         event_status, title_ko,
         display_targets, valid_from,
         valid_until, linked_coupon_id
  into v_event
  from catchmenu_store.cms_events
  where id = p_event_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
  for update;

  if v_event.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'cms_event_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'publish_cms_event'
    );
  end if;

  if v_event.event_status
    not in ('DRAFT', 'SCHEDULED')
  then
    return catchmenu_common.build_error_response(
      p_error_key := 'cms_event_not_publishable',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'publish_cms_event'
    );
  end if;

  -- 이벤트 활성화
  update catchmenu_store.cms_events
  set
    event_status = 'ACTIVE',
    published_at = now(),
    published_by = p_published_by,
    badge_text_key = case
      when valid_until::date
        = (timezone('Asia/Seoul', now()))::date
        then 'event_dday'
      else 'event_ongoing'
    end,
    updated_at = now()
  where id = p_event_id;

  -- 발행 로그
  insert into catchmenu_store.cms_publish_log (
    tenant_id, store_id,
    content_type, content_id, content_code,
    action, action_by,
    before_status, after_status,
    display_targets, realtime_notified
  ) values (
    p_tenant_id, p_store_id,
    'EVENT', v_event.id, v_event.event_code,
    'PUBLISHED', p_published_by,
    v_event.event_status, 'ACTIVE',
    v_event.display_targets, true
  );

  -- Realtime 브로드캐스트 → 전 디바이스
  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_channel_type := 'STORE_MODE',
    p_event_type := 'cms_content_published',
    p_payload := jsonb_build_object(
      'content_type', 'EVENT',
      'event_id', v_event.id,
      'event_code', v_event.event_code,
      'event_type', v_event.event_type,
      'title_ko', v_event.title_ko,
      'display_targets', v_event.display_targets,
      'has_coupon',
        v_event.linked_coupon_id is not null,
      'published_at', now()
    )
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'cms_event_published',
    p_data := jsonb_build_object(
      'event_id', v_event.id,
      'event_code', v_event.event_code,
      'event_type', v_event.event_type,
      'event_status', 'ACTIVE',
      'title_ko', v_event.title_ko,
      'display_targets', v_event.display_targets,
      'published_at', now(),
      'realtime_notified', true,
      'targets_note', jsonb_build_object(
        'CUSTOMER_APP', '고객 앱 즉시 반영',
        'KIOSK', '키오스크 즉시 반영',
        'DID', 'DID 디스플레이 즉시 반영'
      )
    ),
    p_locale := p_locale
  );
end;
$$;


create or replace function
  catchmenu_store.create_cms_banner(
  p_tenant_id uuid,
  p_store_id uuid,
  p_banner_type text,
  p_title_ko text,
  p_subtitle_ko text default null,
  p_title_en text default null,
  p_image_url text default null,
  p_background_color text default '#FFFFFF',
  p_text_color text default '#000000',
  p_link_type text default 'NONE',
  p_link_target text default null,
  p_linked_event_id uuid default null,
  p_display_position text default 'TOP',
  p_display_targets jsonb
    default '["CUSTOMER_APP","KIOSK"]'::jsonb,
  p_valid_from timestamptz default null,
  p_valid_until timestamptz default null,
  p_display_order int default 0,
  p_created_by uuid default null,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_store,
                  catchmenu_common
as $$
declare
  v_banner_id uuid;
  v_banner_code text;
begin
  v_banner_code := 'BNR-'
    || to_char(now(), 'YYYYMMDD')
    || '-' || lpad(
      (
        select coalesce(count(*), 0) + 1
        from catchmenu_store.cms_banners
        where store_id = p_store_id
          and tenant_id = p_tenant_id
      )::text, 4, '0'
    );

  insert into catchmenu_store.cms_banners (
    tenant_id, store_id,
    banner_code, banner_type,
    banner_status,
    title_ko, title_en,
    subtitle_ko,
    image_url,
    background_color, text_color,
    link_type, link_target,
    linked_event_id,
    display_position,
    display_targets, display_order,
    valid_from, valid_until,
    created_by
  ) values (
    p_tenant_id, p_store_id,
    v_banner_code, p_banner_type,
    'ACTIVE',
    p_title_ko, p_title_en,
    p_subtitle_ko,
    p_image_url,
    p_background_color, p_text_color,
    p_link_type, p_link_target,
    p_linked_event_id,
    p_display_position,
    p_display_targets, p_display_order,
    p_valid_from, p_valid_until,
    p_created_by
  )
  returning id into v_banner_id;

  -- 발행 로그
  insert into catchmenu_store.cms_publish_log (
    tenant_id, store_id,
    content_type, content_id, content_code,
    action, action_by,
    before_status, after_status,
    display_targets, realtime_notified
  ) values (
    p_tenant_id, p_store_id,
    'BANNER', v_banner_id, v_banner_code,
    'PUBLISHED', p_created_by,
    null, 'ACTIVE',
    p_display_targets, true
  );

  -- Realtime 브로드캐스트
  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_channel_type := 'STORE_MODE',
    p_event_type := 'cms_content_published',
    p_payload := jsonb_build_object(
      'content_type', 'BANNER',
      'banner_id', v_banner_id,
      'banner_code', v_banner_code,
      'banner_type', p_banner_type,
      'title_ko', p_title_ko,
      'display_targets', p_display_targets,
      'display_position', p_display_position
    )
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'cms_banner_created',
    p_data := jsonb_build_object(
      'banner_id', v_banner_id,
      'banner_code', v_banner_code,
      'banner_type', p_banner_type,
      'banner_status', 'ACTIVE',
      'title_ko', p_title_ko,
      'display_targets', p_display_targets,
      'realtime_notified', true
    ),
    p_locale := p_locale
  );
end;
$$;


create or replace function
  catchmenu_store.create_cms_popup(
  p_tenant_id uuid,
  p_store_id uuid,
  p_popup_type text,
  p_title_ko text,
  p_body_ko text default null,
  p_title_en text default null,
  p_body_en text default null,
  p_image_url text default null,
  p_cta_text_key text default null,
  p_trigger_event text default 'APP_OPEN',
  p_linked_event_id uuid default null,
  p_linked_coupon_id uuid default null,
  p_display_targets jsonb
    default '["CUSTOMER_APP"]'::jsonb,
  p_valid_from timestamptz default null,
  p_valid_until timestamptz default null,
  p_show_once_per_session boolean default true,
  p_created_by uuid default null,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_store,
                  catchmenu_common
as $$
declare
  v_popup_id uuid;
  v_popup_code text;
begin
  v_popup_code := 'POP-'
    || to_char(now(), 'YYYYMMDD')
    || '-' || lpad(
      (
        select coalesce(count(*), 0) + 1
        from catchmenu_store.cms_popups
        where store_id = p_store_id
          and tenant_id = p_tenant_id
      )::text, 4, '0'
    );

  insert into catchmenu_store.cms_popups (
    tenant_id, store_id,
    popup_code, popup_type,
    popup_status,
    title_ko, title_en,
    body_ko, body_en,
    image_url,
    cta_text_key,
    trigger_event,
    linked_event_id, linked_coupon_id,
    display_targets,
    valid_from, valid_until,
    show_once_per_session,
    primary_button_text_key,
    primary_button_action,
    created_by
  ) values (
    p_tenant_id, p_store_id,
    v_popup_code, p_popup_type,
    'ACTIVE',
    p_title_ko, p_title_en,
    p_body_ko, p_body_en,
    p_image_url,
    p_cta_text_key,
    p_trigger_event,
    p_linked_event_id, p_linked_coupon_id,
    p_display_targets,
    p_valid_from, p_valid_until,
    p_show_once_per_session,
    coalesce(p_cta_text_key, 'tap_for_coupon'),
    case p_popup_type
      when 'COUPON' then 'ISSUE_COUPON'
      when 'EVENT' then 'VIEW_EVENT'
      else 'DISMISS'
    end,
    p_created_by
  )
  returning id into v_popup_id;

  -- 발행 로그
  insert into catchmenu_store.cms_publish_log (
    tenant_id, store_id,
    content_type, content_id, content_code,
    action, action_by,
    before_status, after_status,
    display_targets, realtime_notified
  ) values (
    p_tenant_id, p_store_id,
    'POPUP', v_popup_id, v_popup_code,
    'PUBLISHED', p_created_by,
    null, 'ACTIVE',
    p_display_targets, true
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'cms_popup_created',
    p_data := jsonb_build_object(
      'popup_id', v_popup_id,
      'popup_code', v_popup_code,
      'popup_type', p_popup_type,
      'popup_status', 'ACTIVE',
      'title_ko', p_title_ko,
      'trigger_event', p_trigger_event,
      'has_coupon',
        p_linked_coupon_id is not null,
      'display_targets', p_display_targets
    ),
    p_locale := p_locale
  );
end;
$$;


create or replace function
  catchmenu_store.get_cms_display_bundle(
  p_tenant_id uuid,
  p_store_id uuid,
  p_display_target text,
  p_trigger_event text default 'APP_OPEN',
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
  v_events jsonb;
  v_banners jsonb;
  v_popups jsonb;
  v_now timestamptz := now();
begin
  -- 활성 이벤트
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'event_id', id,
        'event_code', event_code,
        'event_type', event_type,
        'title', case p_locale
          when 'ko' then title_ko
          when 'en' then coalesce(title_en, title_ko)
          when 'zh' then coalesce(title_zh, title_ko)
          when 'ja' then coalesce(title_ja, title_ko)
          when 'vi' then coalesce(title_vi, title_ko)
          when 'th' then coalesce(title_th, title_ko)
          else title_ko
        end,
        'body', case p_locale
          when 'ko' then body_ko
          when 'en' then coalesce(body_en, body_ko)
          else body_ko
        end,
        'thumbnail_url', thumbnail_url,
        'banner_image_url', banner_image_url,
        'valid_from', valid_from,
        'valid_until', valid_until,
        'is_featured', is_featured,
        'badge_text',
          catchmenu_common.get_message(
            coalesce(
              badge_text_key, 'event_ongoing'
            ),
            p_locale, null
          ),
        'has_coupon',
          linked_coupon_id is not null,
        'coupon_auto_issue', coupon_auto_issue,
        'tap_text', case
          when linked_coupon_id is not null
          then catchmenu_common.get_message(
            'tap_for_coupon', p_locale, null
          )
          else null
        end,
        'view_count', view_count
      )
      order by
        is_featured desc,
        display_order asc,
        published_at desc
    ),
    '[]'::jsonb
  )
  into v_events
  from catchmenu_store.cms_events
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and event_status = 'ACTIVE'
    and display_targets
      @> to_jsonb(p_display_target)
    and (
      valid_from is null
      or valid_from <= v_now
    )
    and (
      valid_until is null
      or valid_until >= v_now
    );

  -- 활성 배너
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'banner_id', id,
        'banner_code', banner_code,
        'banner_type', banner_type,
        'title', case p_locale
          when 'ko' then title_ko
          when 'en' then coalesce(title_en, title_ko)
          else title_ko
        end,
        'subtitle', subtitle_ko,
        'image_url', image_url,
        'background_color', background_color,
        'text_color', text_color,
        'link_type', link_type,
        'link_target', link_target,
        'display_position', display_position,
        'view_count', view_count
      )
      order by display_order asc
    ),
    '[]'::jsonb
  )
  into v_banners
  from catchmenu_store.cms_banners
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and banner_status = 'ACTIVE'
    and display_targets
      @> to_jsonb(p_display_target)
    and (
      valid_from is null
      or valid_from <= v_now
    )
    and (
      valid_until is null
      or valid_until >= v_now
    );

  -- 활성 팝업
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'popup_id', id,
        'popup_code', popup_code,
        'popup_type', popup_type,
        'title', case p_locale
          when 'ko' then title_ko
          when 'en' then coalesce(title_en, title_ko)
          else title_ko
        end,
        'body', case p_locale
          when 'ko' then body_ko
          when 'en' then coalesce(body_en, body_ko)
          else body_ko
        end,
        'image_url', image_url,
        'cta_text',
          catchmenu_common.get_message(
            coalesce(
              cta_text_key, 'tap_for_coupon'
            ),
            p_locale, null
          ),
        'primary_button_text',
          catchmenu_common.get_message(
            coalesce(
              primary_button_text_key,
              'tap_for_coupon'
            ),
            p_locale, null
          ),
        'primary_button_action',
          primary_button_action,
        'trigger_event', trigger_event,
        'show_once_per_session',
          show_once_per_session,
        'has_coupon',
          linked_coupon_id is not null,
        'linked_coupon_id', linked_coupon_id,
        'view_count', view_count
      )
    ),
    '[]'::jsonb
  )
  into v_popups
  from catchmenu_store.cms_popups
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and popup_status = 'ACTIVE'
    and display_targets
      @> to_jsonb(p_display_target)
    and trigger_event = p_trigger_event
    and (
      valid_from is null
      or valid_from <= v_now
    )
    and (
      valid_until is null
      or valid_until >= v_now
    );

  return catchmenu_common.build_success_response(
    p_message_key := 'cms_display_bundle_loaded',
    p_data := jsonb_build_object(
      'store_id', p_store_id,
      'display_target', p_display_target,
      'locale', p_locale,
      'events', v_events,
      'event_count',
        jsonb_array_length(v_events),
      'banners', v_banners,
      'banner_count',
        jsonb_array_length(v_banners),
      'popups', v_popups,
      'popup_count',
        jsonb_array_length(v_popups),
      'has_content',
        jsonb_array_length(v_events) > 0
        or jsonb_array_length(v_banners) > 0,
      'loaded_at', v_now
    ),
    p_locale := p_locale
  );
end;
$$;


create or replace function
  catchmenu_store.get_cms_dashboard(
  p_tenant_id uuid,
  p_store_id uuid,
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
  v_event_summary jsonb;
  v_banner_summary jsonb;
  v_popup_summary jsonb;
  v_recent_logs jsonb;
  v_coupon_event_count int;
begin
  -- 이벤트 요약
  select jsonb_build_object(
    'total', count(*),
    'active', count(*) filter (
      where event_status = 'ACTIVE'
    ),
    'scheduled', count(*) filter (
      where event_status = 'SCHEDULED'
    ),
    'draft', count(*) filter (
      where event_status = 'DRAFT'
    ),
    'ended', count(*) filter (
      where event_status = 'ENDED'
    ),
    'total_views', coalesce(
      sum(view_count), 0
    ),
    'total_coupon_claims', coalesce(
      sum(coupon_claim_count), 0
    ),
    'total_taps', coalesce(
      sum(tap_count), 0
    )
  )
  into v_event_summary
  from catchmenu_store.cms_events
  where store_id = p_store_id
    and tenant_id = p_tenant_id;

  -- 배너 요약
  select jsonb_build_object(
    'total', count(*),
    'active', count(*) filter (
      where banner_status = 'ACTIVE'
    ),
    'total_views', coalesce(
      sum(view_count), 0
    ),
    'total_taps', coalesce(
      sum(tap_count), 0
    )
  )
  into v_banner_summary
  from catchmenu_store.cms_banners
  where store_id = p_store_id
    and tenant_id = p_tenant_id;

  -- 팝업 요약
  select jsonb_build_object(
    'total', count(*),
    'active', count(*) filter (
      where popup_status = 'ACTIVE'
    ),
    'total_views', coalesce(
      sum(view_count), 0
    ),
    'cta_clicks', coalesce(
      sum(cta_click_count), 0
    )
  )
  into v_popup_summary
  from catchmenu_store.cms_popups
  where store_id = p_store_id
    and tenant_id = p_tenant_id;

  -- 쿠폰 연결 이벤트 수
  select count(*) into v_coupon_event_count
  from catchmenu_store.cms_events
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and event_status = 'ACTIVE'
    and linked_coupon_id is not null;

  -- 최근 발행 이력
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'content_type', content_type,
        'content_code', content_code,
        'action', action,
        'before_status', before_status,
        'after_status', after_status,
        'actioned_at', actioned_at
      )
      order by actioned_at desc
    ),
    '[]'::jsonb
  )
  into v_recent_logs
  from catchmenu_store.cms_publish_log
  where store_id = p_store_id
    and tenant_id = p_tenant_id
  limit 10;

  return catchmenu_common.build_success_response(
    p_message_key := 'cms_dashboard_loaded',
    p_data := jsonb_build_object(
      'store_id', p_store_id,
      'events', v_event_summary,
      'banners', v_banner_summary,
      'popups', v_popup_summary,
      'coupon_event_count',
        v_coupon_event_count,
      'recent_logs', v_recent_logs,
      'reuse_note', jsonb_build_object(
        'CUSTOMER_APP', '고객 앱 반영',
        'KIOSK', '3차 키오스크 재사용',
        'DID', 'DID 배너 표시',
        'coupon_business',
          '쿠폰 이벤트 = 향후 쿠폰 사업 기반'
      ),
      'loaded_at', now()
    ),
    p_locale := p_locale
  );
end;
$$;


-- =============================================
-- pg_cron: CMS 콘텐츠 만료 처리
-- =============================================
insert into catchmenu_common.pg_cron_jobs (
  job_code, pg_cron_job_name,
  schedule_cron_utc, schedule_cron_kst,
  sql_command, notes, is_registered
) values
(
  'CMS_CONTENT_EXPIRE',
  'catchmenu_cms_content_expire',
  '*/10 * * * *',
  '*/10 * * * * (10분마다)',
  $sql$
-- 이벤트 만료
UPDATE catchmenu_store.cms_events
SET event_status = 'ENDED', updated_at = now()
WHERE event_status = 'ACTIVE'
  AND valid_until IS NOT NULL
  AND valid_until < now();

-- 이벤트 자동 시작 (SCHEDULED → ACTIVE)
UPDATE catchmenu_store.cms_events
SET event_status = 'ACTIVE', updated_at = now()
WHERE event_status = 'SCHEDULED'
  AND valid_from IS NOT NULL
  AND valid_from <= now();

-- 배너 만료
UPDATE catchmenu_store.cms_banners
SET banner_status = 'EXPIRED', updated_at = now()
WHERE banner_status = 'ACTIVE'
  AND valid_until IS NOT NULL
  AND valid_until < now();

-- 팝업 만료
UPDATE catchmenu_store.cms_popups
SET popup_status = 'EXPIRED', updated_at = now()
WHERE popup_status = 'ACTIVE'
  AND valid_until IS NOT NULL
  AND valid_until < now();
$sql$,
  'CMS 콘텐츠 자동 만료/시작. 10분마다.',
  true
)
on conflict (job_code) do nothing;


-- grants
do $$
begin
  revoke all on function
    catchmenu_store.create_cms_event(
      uuid, uuid, text, text, text, text,
      text, text, text, timestamptz,
      timestamptz, jsonb, uuid, boolean,
      boolean, uuid, text
    ) from public;
  grant execute on function
    catchmenu_store.create_cms_event(
      uuid, uuid, text, text, text, text,
      text, text, text, timestamptz,
      timestamptz, jsonb, uuid, boolean,
      boolean, uuid, text
    ) to authenticated;

  revoke all on function
    catchmenu_store.publish_cms_event(
      uuid, uuid, uuid, uuid, text
    ) from public;
  grant execute on function
    catchmenu_store.publish_cms_event(
      uuid, uuid, uuid, uuid, text
    ) to authenticated;

  revoke all on function
    catchmenu_store.create_cms_banner(
      uuid, uuid, text, text, text, text,
      text, text, text, text, text,
      uuid, text, jsonb, timestamptz,
      timestamptz, int, uuid, text
    ) from public;
  grant execute on function
    catchmenu_store.create_cms_banner(
      uuid, uuid, text, text, text, text,
      text, text, text, text, text,
      uuid, text, jsonb, timestamptz,
      timestamptz, int, uuid, text
    ) to authenticated;

  revoke all on function
    catchmenu_store.create_cms_popup(
      uuid, uuid, text, text, text, text,
      text, text, text, text, uuid,
      uuid, jsonb, timestamptz, timestamptz,
      boolean, uuid, text
    ) from public;
  grant execute on function
    catchmenu_store.create_cms_popup(
      uuid, uuid, text, text, text, text,
      text, text, text, text, uuid,
      uuid, jsonb, timestamptz, timestamptz,
      boolean, uuid, text
    ) to authenticated;

  revoke all on function
    catchmenu_store.get_cms_display_bundle(
      uuid, uuid, text, text, text
    ) from public;
  grant execute on function
    catchmenu_store.get_cms_display_bundle(
      uuid, uuid, text, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_store.get_cms_dashboard(
      uuid, uuid, text
    ) from public;
  grant execute on function
    catchmenu_store.get_cms_dashboard(
      uuid, uuid, text
    ) to authenticated;
end;
$$;

comment on function
  catchmenu_store.get_cms_display_bundle(
    uuid, uuid, text, text, text
  ) is
  'CMS 표시 데이터 통합 번들.
   단일 RPC로 이벤트 + 배너 + 팝업 전체 반환.

   display_target별 용도:
   CUSTOMER_APP → 고객 앱 홈 화면
   KIOSK → 3차 키오스크 메인 화면
   DID → DID 디스플레이 배너

   다국어 자동 처리:
   locale 파라미터로 언어 선택.
   미번역 시 한국어 fallback.

   쿠폰 연결:
   has_coupon = true 시 tap_text 표시.
   coupon_auto_issue = true 시 탭 즉시 발급.

   재사용 설계:
   1-B차: 고객 앱
   3차: 키오스크 (그대로 사용)
   DID: 배너 채널 (이미 연동됨)
   향후: 쿠폰 사업 플랫폼 기반.';

comment on function
  catchmenu_store.create_cms_event(
    uuid, uuid, text, text, text, text,
    text, text, text, timestamptz,
    timestamptz, jsonb, uuid, boolean,
    boolean, uuid, text
  ) is
  '업주 이벤트 생성.
   이벤트 유형:
   DISCOUNT: 할인 (예: 런치 20% 할인)
   SPECIAL_PRICE: 특가 (예: 오늘의 특가)
   NEW_MENU: 신메뉴 출시
   ANNIVERSARY: 기념일 (개업 n주년)
   SEASONAL: 시즌 (여름 냉면 특가)
   HAPPY_HOUR: 해피아워
   COMBO: 세트메뉴 이벤트
   COUPON: 쿠폰 이벤트
   NOTICE: 공지
   CUSTOM: 자유 형식

   linked_coupon_id: 쿠폰 연결.
   coupon_auto_issue: 탭 즉시 쿠폰 발급.

   발행 2단계:
   1. create_cms_event() → DRAFT
   2. publish_cms_event() → ACTIVE + Realtime.

   Realtime 발행 → 고객앱/키오스크/DID 즉시 반영.';