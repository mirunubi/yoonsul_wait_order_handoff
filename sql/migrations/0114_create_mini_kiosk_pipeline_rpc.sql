-- 0114_create_mini_kiosk_pipeline_rpc.sql
-- Purpose: Mini kiosk pipeline.
--          외국인 전용 미니 키오스크.
--          메뉴 표시 + 주문 + 결제 흐름.
--          다국어 우선 (ko/en/zh/ja/vi/th).
--          QR코드 테이블 연동.
--          키오스크 부트스트랩 단일 RPC.
--          i18n: 모든 메시지 = message_catalog 참조.
-- Depends on: 0113_create_api_spec_docs.sql
-- Creates:
--   catchmenu_store.kiosk_configs (table)
--   catchmenu_store.kiosk_sessions (table)
--   function catchmenu_store.bootstrap_kiosk(...)
--   function catchmenu_store.get_kiosk_menu(...)
--   function catchmenu_store.place_kiosk_order(...)
--   function catchmenu_store.get_kiosk_order_status(...)
--   function catchmenu_store.get_kiosk_dashboard(...)

-- =============================================
-- i18n 메시지 등록
-- =============================================
insert into catchmenu_common.message_catalog (
  message_key, locale, message_text
) values
('kiosk_ready', 'ko', '키오스크가 준비되었습니다'),
('kiosk_ready', 'en', 'Kiosk ready'),
('kiosk_ready', 'zh', '自助机已准备好'),
('kiosk_ready', 'ja', 'キオスクの準備ができました'),
('kiosk_ready', 'vi', 'Kiosk đã sẵn sàng'),
('kiosk_ready', 'th', 'คีออสก์พร้อมแล้ว'),

('kiosk_order_placed', 'ko',
  '주문이 접수되었습니다'),
('kiosk_order_placed', 'en',
  'Order placed'),
('kiosk_order_placed', 'zh',
  '订单已提交'),
('kiosk_order_placed', 'ja',
  'ご注文を承りました'),
('kiosk_order_placed', 'vi',
  'Đã đặt hàng'),
('kiosk_order_placed', 'th',
  'สั่งอาหารแล้ว'),

('kiosk_welcome', 'ko',
  '어서오세요! 메뉴를 선택해 주세요'),
('kiosk_welcome', 'en',
  'Welcome! Please select your menu'),
('kiosk_welcome', 'zh',
  '欢迎光临！请选择菜单'),
('kiosk_welcome', 'ja',
  'いらっしゃいませ！メニューをお選びください'),
('kiosk_welcome', 'vi',
  'Chào mừng! Vui lòng chọn món'),
('kiosk_welcome', 'th',
  'ยินดีต้อนรับ! กรุณาเลือกเมนู'),

('kiosk_select_language', 'ko', '언어 선택'),
('kiosk_select_language', 'en',
  'Select Language'),
('kiosk_select_language', 'zh', '选择语言'),
('kiosk_select_language', 'ja', '言語選択'),
('kiosk_select_language', 'vi', 'Chọn ngôn ngữ'),
('kiosk_select_language', 'th', 'เลือกภาษา'),

('kiosk_order_number', 'ko',
  '{order_number}번으로 준비해 드리겠습니다'),
('kiosk_order_number', 'en',
  'Your order number is #{order_number}'),
('kiosk_order_number', 'zh',
  '您的订单号是{order_number}'),
('kiosk_order_number', 'ja',
  '{order_number}番でご準備いたします'),
('kiosk_order_number', 'vi',
  'Số thứ tự của bạn là #{order_number}'),
('kiosk_order_number', 'th',
  'หมายเลขคำสั่งซื้อของคุณคือ #{order_number}'),

('kiosk_payment_select', 'ko',
  '결제 방법을 선택해 주세요'),
('kiosk_payment_select', 'en',
  'Please select payment method'),
('kiosk_payment_select', 'zh',
  '请选择支付方式'),
('kiosk_payment_select', 'ja',
  'お支払い方法をお選びください'),
('kiosk_payment_select', 'vi',
  'Vui lòng chọn phương thức thanh toán'),
('kiosk_payment_select', 'th',
  'กรุณาเลือกวิธีชำระเงิน'),

('kiosk_add_to_cart', 'ko', '담기'),
('kiosk_add_to_cart', 'en', 'Add'),
('kiosk_add_to_cart', 'zh', '添加'),
('kiosk_add_to_cart', 'ja', '追加'),
('kiosk_add_to_cart', 'vi', 'Thêm'),
('kiosk_add_to_cart', 'th', 'เพิ่ม'),

('kiosk_checkout', 'ko', '주문하기'),
('kiosk_checkout', 'en', 'Order'),
('kiosk_checkout', 'zh', '下单'),
('kiosk_checkout', 'ja', '注文する'),
('kiosk_checkout', 'vi', 'Đặt hàng'),
('kiosk_checkout', 'th', 'สั่งอาหาร'),

('kiosk_cancel', 'ko', '취소'),
('kiosk_cancel', 'en', 'Cancel'),
('kiosk_cancel', 'zh', '取消'),
('kiosk_cancel', 'ja', 'キャンセル'),
('kiosk_cancel', 'vi', 'Hủy'),
('kiosk_cancel', 'th', 'ยกเลิก'),

('kiosk_total', 'ko', '합계'),
('kiosk_total', 'en', 'Total'),
('kiosk_total', 'zh', '合计'),
('kiosk_total', 'ja', '合計'),
('kiosk_total', 'vi', 'Tổng cộng'),
('kiosk_total', 'th', 'รวม'),

('kiosk_allergen_notice', 'ko',
  '알레르기 정보는 직원에게 문의해 주세요'),
('kiosk_allergen_notice', 'en',
  'For allergen info, please ask staff'),
('kiosk_allergen_notice', 'zh',
  '过敏信息请咨询工作人员'),
('kiosk_allergen_notice', 'ja',
  'アレルギー情報はスタッフにお問い合わせください'),
('kiosk_allergen_notice', 'vi',
  'Hỏi nhân viên về thông tin dị ứng'),
('kiosk_allergen_notice', 'th',
  'สอบถามพนักงานเกี่ยวกับข้อมูลสารก่อภูมิแพ้'),

('kiosk_session_loaded', 'ko',
  '키오스크 세션이 로드되었습니다'),
('kiosk_session_loaded', 'en',
  'Kiosk session loaded'),

('kiosk_dashboard_loaded', 'ko',
  '키오스크 대시보드가 로드되었습니다'),
('kiosk_dashboard_loaded', 'en',
  'Kiosk dashboard loaded'),

('kiosk_store_closed_msg', 'ko',
  '현재 영업시간이 아닙니다'),
('kiosk_store_closed_msg', 'en',
  'Currently closed'),
('kiosk_store_closed_msg', 'zh',
  '当前不在营业时间'),
('kiosk_store_closed_msg', 'ja',
  '現在営業時間外です'),
('kiosk_store_closed_msg', 'vi',
  'Hiện đang đóng cửa'),
('kiosk_store_closed_msg', 'th',
  'ปิดให้บริการในขณะนี้')
on conflict (message_key, locale) do nothing;

insert into catchmenu_common.error_codes (
  code, error_key, error_domain,
  error_category, http_status, severity
) values
(7050, 'kiosk_not_found',
  'STORE', 'NOT_FOUND', 404, 'WARNING'),
(7051, 'kiosk_store_closed',
  'STORE', 'BUSINESS_RULE', 503, 'INFO'),
(7052, 'kiosk_order_amount_invalid',
  'STORE', 'INVALID_INPUT', 400, 'WARNING'),
(7053, 'kiosk_session_expired',
  'STORE', 'BUSINESS_RULE', 410, 'INFO')
on conflict (code) do nothing;


-- =============================================
-- kiosk_configs table
-- 키오스크별 설정
-- =============================================
create table if not exists
  catchmenu_store.kiosk_configs (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid not null
    references catchmenu_hq.stores(id),
  device_id uuid
    references catchmenu_store.device_registry(id),

  -- 키오스크 정보
  kiosk_code text not null,
  kiosk_name text not null,
  kiosk_type text not null default 'MINI',

  -- 위치
  table_zone text,
  table_number text,
  qr_code text,

  -- 언어 설정
  default_locale text not null default 'ko',
  supported_locales jsonb
    not null default
      '["ko","en","zh","ja","vi","th"]'::jsonb,

  -- 기능 설정
  order_type text not null default 'TAKEOUT',
  payment_methods jsonb
    not null default
      '["CARD","TOSS_PAYMENTS"]'::jsonb,
  show_allergen_info boolean
    not null default true,
  show_calories boolean
    not null default false,
  show_cms_events boolean
    not null default true,

  -- 화면 설정
  idle_timeout_seconds int
    not null default 120,
  attract_loop_enabled boolean
    not null default true,

  -- 메뉴 필터
  hidden_category_codes jsonb
    default '[]'::jsonb,
  featured_menu_ids jsonb
    default '[]'::jsonb,

  -- 상태
  is_active boolean not null default true,
  last_heartbeat_at timestamptz,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint uq_kiosk_code unique (
    store_id, kiosk_code
  ),
  constraint chk_kiosk_type check (
    kiosk_type in (
      'MINI',        -- 소형 (태블릿)
      'STANDARD',    -- 표준 (스탠드)
      'COUNTER',     -- 카운터 임베디드
      'TABLE'        -- 테이블 QR 연동
    )
  ),
  constraint chk_order_type check (
    order_type in (
      'TAKEOUT',
      'TABLE',
      'BOTH'
    )
  )
);

create index if not exists idx_kiosk_configs
  on catchmenu_store.kiosk_configs(
    store_id, is_active
  );

alter table catchmenu_store.kiosk_configs
  enable row level security;
alter table catchmenu_store.kiosk_configs
  force row level security;

drop policy if exists kiosk_configs_isolation
  on catchmenu_store.kiosk_configs;
create policy kiosk_configs_isolation
  on catchmenu_store.kiosk_configs
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id =
      catchmenu_common.current_store_id()
  );

drop trigger if exists trg_kiosk_configs_updated
  on catchmenu_store.kiosk_configs;
create trigger trg_kiosk_configs_updated
  before update on catchmenu_store.kiosk_configs
  for each row execute function
    catchmenu_common.set_updated_at();

comment on table catchmenu_store.kiosk_configs is
  '키오스크 설정.
   MINI: 태블릿 미니 키오스크.
   TABLE: QR코드 테이블 연동.
   supported_locales: 지원 언어.
   default_locale: 초기 표시 언어.
   idle_timeout_seconds: 비활성 초기화 시간.
   3차 키오스크 개발 시 STANDARD 타입 추가.
   CMS 이벤트 표시 가능 (Mini CMS 연동).';


-- =============================================
-- kiosk_sessions table
-- 키오스크 사용 세션
-- =============================================
create table if not exists
  catchmenu_store.kiosk_sessions (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid not null
    references catchmenu_hq.stores(id),
  kiosk_id uuid not null
    references catchmenu_store.kiosk_configs(id),

  -- 세션 정보
  session_locale text not null default 'ko',
  table_number text,
  customer_id uuid
    references catchmenu_store.customers(id),

  -- 주문 연결
  order_id uuid
    references catchmenu_pos.orders(id),

  -- 카트 (임시 저장)
  cart_items jsonb default '[]'::jsonb,
  cart_total int not null default 0,

  -- 상태
  session_status text
    not null default 'BROWSING',

  -- 타임스탬프
  session_started_at timestamptz
    not null default now(),
  last_activity_at timestamptz
    not null default now(),
  order_placed_at timestamptz,
  session_ended_at timestamptz,

  business_day date,

  constraint chk_kiosk_session_status check (
    session_status in (
      'BROWSING',    -- 메뉴 탐색
      'CART',        -- 장바구니
      'PAYMENT',     -- 결제 중
      'COMPLETED',   -- 완료
      'CANCELLED',   -- 취소
      'TIMEOUT'      -- 시간 초과
    )
  )
);

create index if not exists idx_kiosk_sessions
  on catchmenu_store.kiosk_sessions(
    kiosk_id, session_status,
    session_started_at desc
  ) where session_status in (
    'BROWSING', 'CART', 'PAYMENT'
  );

alter table catchmenu_store.kiosk_sessions
  enable row level security;
alter table catchmenu_store.kiosk_sessions
  force row level security;

drop policy if exists kiosk_sessions_isolation
  on catchmenu_store.kiosk_sessions;
create policy kiosk_sessions_isolation
  on catchmenu_store.kiosk_sessions
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id =
      catchmenu_common.current_store_id()
  );

comment on table catchmenu_store.kiosk_sessions is
  '키오스크 사용 세션.
   BROWSING → CART → PAYMENT → COMPLETED.
   cart_items: 장바구니 임시 저장 (jsonb).
   TIMEOUT: idle_timeout_seconds 초과.
   order_id: 주문 완료 시 연결.
   특허1: 키오스크 세션 = 고객 진입 추적.';


-- =============================================
-- RPCs
-- =============================================
create or replace function
  catchmenu_store.bootstrap_kiosk(
  p_tenant_id uuid,
  p_store_id uuid,
  p_kiosk_code text,
  p_device_id uuid default null,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_store,
                  catchmenu_pos,
                  catchmenu_common,
                  catchmenu_hq
as $$
declare
  v_kiosk record;
  v_store record;
  v_store_settings record;
  v_menu_catalog jsonb;
  v_cms_bundle jsonb;
  v_business_day date;
  v_business_hours record;
  v_is_open boolean;
  v_day_of_week int;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;
  v_day_of_week := extract(
    dow from v_business_day
  )::int;

  -- 키오스크 설정 조회
  select id, kiosk_code, kiosk_name,
         kiosk_type, order_type,
         default_locale, supported_locales,
         payment_methods, show_allergen_info,
         show_cms_events,
         idle_timeout_seconds,
         hidden_category_codes,
         featured_menu_ids,
         table_number, table_zone
  into v_kiosk
  from catchmenu_store.kiosk_configs
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and kiosk_code = p_kiosk_code
    and is_active = true;

  if v_kiosk.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'kiosk_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'bootstrap_kiosk'
    );
  end if;

  -- 매장 정보
  select id, store_name, timezone
  into v_store
  from catchmenu_hq.stores
  where id = p_store_id
    and tenant_id = p_tenant_id
    and is_active = true;

  -- 매장 설정
  select store_mode, waiting_enabled,
         pre_order_enabled,
         min_order_amount
  into v_store_settings
  from catchmenu_store.store_settings
  where store_id = p_store_id
    and tenant_id = p_tenant_id;

  -- 영업시간 확인
  select is_open, open_time, close_time,
         break_start_time, break_end_time,
         last_order_time
  into v_business_hours
  from catchmenu_store.store_business_hours
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and day_of_week = v_day_of_week;

  -- 영업 여부 판단
  v_is_open := case
    when coalesce(
      v_store_settings.store_mode, 'NORMAL'
    ) in ('CLOSED', 'HOLIDAY', 'EMERGENCY')
      then false
    when v_business_hours.is_open = false
      then false
    when v_business_hours.open_time is not null
      and localtime < v_business_hours.open_time
      then false
    when v_business_hours.close_time is not null
      and localtime > v_business_hours.close_time
      then false
    else true
  end;

  -- 메뉴 카탈로그
  v_menu_catalog :=
    catchmenu_pos.get_menu_catalog_i18n(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_locale := coalesce(
        p_locale, v_kiosk.default_locale
      ),
      p_include_sold_out := false
    );

  -- CMS 번들 (이벤트/배너)
  if v_kiosk.show_cms_events then
    v_cms_bundle :=
      catchmenu_store.get_cms_display_bundle(
        p_tenant_id := p_tenant_id,
        p_store_id := p_store_id,
        p_display_target := 'KIOSK',
        p_locale := coalesce(
          p_locale, v_kiosk.default_locale
        )
      );
  end if;

  -- 키오스크 heartbeat 업데이트
  update catchmenu_store.kiosk_configs
  set
    last_heartbeat_at = now(),
    updated_at = now()
  where id = v_kiosk.id;

  return catchmenu_common.build_success_response(
    p_message_key := 'kiosk_ready',
    p_data := jsonb_build_object(

      -- 키오스크 정보
      'kiosk', jsonb_build_object(
        'id', v_kiosk.id,
        'kiosk_code', v_kiosk.kiosk_code,
        'kiosk_name', v_kiosk.kiosk_name,
        'kiosk_type', v_kiosk.kiosk_type,
        'order_type', v_kiosk.order_type,
        'table_number', v_kiosk.table_number,
        'table_zone', v_kiosk.table_zone
      ),

      -- 매장 정보
      'store', jsonb_build_object(
        'id', v_store.id,
        'store_name', v_store.store_name,
        'store_mode', coalesce(
          v_store_settings.store_mode, 'NORMAL'
        ),
        'is_open', v_is_open,
        'min_order_amount', coalesce(
          v_store_settings.min_order_amount, 0
        )
      ),

      -- 언어 설정
      'locale_config', jsonb_build_object(
        'default_locale',
          v_kiosk.default_locale,
        'supported_locales',
          v_kiosk.supported_locales,
        'current_locale', coalesce(
          p_locale, v_kiosk.default_locale
        ),
        'welcome_message',
          catchmenu_common.get_message(
            'kiosk_welcome',
            coalesce(
              p_locale, v_kiosk.default_locale
            ),
            null
          ),
        'select_language_text',
          catchmenu_common.get_message(
            'kiosk_select_language',
            coalesce(
              p_locale, v_kiosk.default_locale
            ),
            null
          )
      ),

      -- 결제 설정
      'payment_config', jsonb_build_object(
        'payment_methods',
          v_kiosk.payment_methods,
        'payment_select_text',
          catchmenu_common.get_message(
            'kiosk_payment_select',
            coalesce(
              p_locale, v_kiosk.default_locale
            ),
            null
          )
      ),

      -- UI 설정
      'ui_config', jsonb_build_object(
        'idle_timeout_seconds',
          v_kiosk.idle_timeout_seconds,
        'show_allergen_info',
          v_kiosk.show_allergen_info,
        'show_calories',
          v_kiosk.show_calories,
        'show_cms_events',
          v_kiosk.show_cms_events,
        'attract_loop_enabled',
          v_kiosk.attract_loop_enabled,
        'allergen_notice',
          catchmenu_common.get_message(
            'kiosk_allergen_notice',
            coalesce(
              p_locale, v_kiosk.default_locale
            ),
            null
          )
      ),

      -- 메뉴
      'menu_catalog',
        v_menu_catalog->'data',

      -- CMS
      'cms_bundle',
        v_cms_bundle->'data',

      -- 영업시간
      'business_hours', case
        when v_business_hours.is_open is not null
        then jsonb_build_object(
          'is_open', v_business_hours.is_open,
          'open_time', v_business_hours.open_time,
          'close_time', v_business_hours.close_time,
          'break_start',
            v_business_hours.break_start_time,
          'break_end',
            v_business_hours.break_end_time,
          'last_order',
            v_business_hours.last_order_time
        )
        else null
      end,

      -- 폐점 메시지
      'closed_message', case
        when not v_is_open
        then catchmenu_common.get_message(
          'kiosk_store_closed_msg',
          coalesce(
            p_locale, v_kiosk.default_locale
          ),
          null
        )
        else null
      end,

      'business_day', v_business_day,
      'bootstrapped_at', now()
    ),
    p_locale := p_locale
  );
end;
$$;


create or replace function
  catchmenu_store.get_kiosk_menu(
  p_tenant_id uuid,
  p_store_id uuid,
  p_kiosk_id uuid,
  p_locale text default 'ko',
  p_category_code text default null
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_store,
                  catchmenu_pos,
                  catchmenu_common
as $$
declare
  v_kiosk record;
  v_categories jsonb;
  v_menus jsonb;
begin
  select id, hidden_category_codes,
         featured_menu_ids,
         show_allergen_info,
         default_locale
  into v_kiosk
  from catchmenu_store.kiosk_configs
  where id = p_kiosk_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
    and is_active = true;

  if v_kiosk.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'kiosk_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'get_kiosk_menu'
    );
  end if;

  -- 카테고리 목록 (숨김 제외)
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'category_id', id,
        'category_code', category_code,
        'category_name', case p_locale
          when 'ko' then category_name
          when 'en' then coalesce(
            category_name_en, category_name
          )
          when 'zh' then coalesce(
            category_name_zh, category_name
          )
          when 'ja' then coalesce(
            category_name_ja, category_name
          )
          else category_name
        end,
        'display_order', display_order
      )
      order by display_order asc
    ),
    '[]'::jsonb
  )
  into v_categories
  from catchmenu_pos.menu_categories
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and is_active = true
    and not (
      v_kiosk.hidden_category_codes
        @> to_jsonb(category_code)
    )
    and (
      p_category_code is null
      or category_code = p_category_code
    );

  -- 메뉴 목록
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'menu_id', m.id,
        'category_code', mc.category_code,
        'menu_code', m.menu_code,
        'menu_name', case p_locale
          when 'ko' then m.menu_name
          when 'en' then coalesce(
            m.menu_name_en, m.menu_name
          )
          when 'zh' then coalesce(
            m.menu_name_zh, m.menu_name
          )
          when 'ja' then coalesce(
            m.menu_name_ja, m.menu_name
          )
          else m.menu_name
        end,
        'price', m.price,
        'menu_status', m.menu_status,
        'is_available',
          m.menu_status = 'AVAILABLE',
        'thumbnail_url', m.thumbnail_url,
        'description', m.description,
        'allergen_codes', case
          when v_kiosk.show_allergen_info
          then m.allergen_codes
          else null
        end,
        'allergen_notice', case
          when v_kiosk.show_allergen_info
            and jsonb_array_length(
              coalesce(
                m.allergen_codes, '[]'::jsonb
              )
            ) > 0
          then catchmenu_common.get_message(
            'kiosk_allergen_notice',
            p_locale, null
          )
          else null
        end,
        'menu_options', m.menu_options,
        'is_featured', (
          v_kiosk.featured_menu_ids
            @> to_jsonb(m.id::text)
        ),
        'display_order', m.display_order,
        'add_text',
          catchmenu_common.get_message(
            'kiosk_add_to_cart', p_locale, null
          )
      )
      order by
        (v_kiosk.featured_menu_ids
          @> to_jsonb(m.id::text)) desc,
        mc.display_order asc,
        m.display_order asc
    ),
    '[]'::jsonb
  )
  into v_menus
  from catchmenu_pos.menus m
  join catchmenu_pos.menu_categories mc
    on mc.id = m.category_id
  where m.store_id = p_store_id
    and m.tenant_id = p_tenant_id
    and m.is_active = true
    and m.menu_status <> 'HIDDEN'
    and not (
      v_kiosk.hidden_category_codes
        @> to_jsonb(mc.category_code)
    )
    and (
      p_category_code is null
      or mc.category_code = p_category_code
    );

  return catchmenu_common.build_success_response(
    p_message_key := 'kiosk_session_loaded',
    p_data := jsonb_build_object(
      'kiosk_id', v_kiosk.id,
      'locale', p_locale,
      'categories', v_categories,
      'category_count',
        jsonb_array_length(v_categories),
      'menus', v_menus,
      'menu_count',
        jsonb_array_length(v_menus),
      'checkout_text',
        catchmenu_common.get_message(
          'kiosk_checkout', p_locale, null
        ),
      'cancel_text',
        catchmenu_common.get_message(
          'kiosk_cancel', p_locale, null
        ),
      'total_text',
        catchmenu_common.get_message(
          'kiosk_total', p_locale, null
        )
    ),
    p_locale := p_locale
  );
end;
$$;


create or replace function
  catchmenu_store.place_kiosk_order(
  p_tenant_id uuid,
  p_store_id uuid,
  p_kiosk_id uuid,
  p_kiosk_session_id uuid,
  p_cart_items jsonb,
  p_order_type text default 'TAKEOUT',
  p_table_number text default null,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_store,
                  catchmenu_pos,
                  catchmenu_kds,
                  catchmenu_common,
                  catchmenu_ledger,
                  catchmenu_hq
as $$
declare
  v_kiosk record;
  v_store_settings record;
  v_order_id uuid;
  v_order_number text;
  v_total_amount int := 0;
  v_item jsonb;
  v_menu record;
  v_business_day date;
  v_timezone text;
  v_session_id uuid;
  v_item_count int := 0;
begin
  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  -- 키오스크 설정 확인
  select id, kiosk_type, order_type
  into v_kiosk
  from catchmenu_store.kiosk_configs
  where id = p_kiosk_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
    and is_active = true;

  if v_kiosk.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'kiosk_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'place_kiosk_order'
    );
  end if;

  -- 매장 설정
  select store_mode, pre_order_enabled,
         min_order_amount
  into v_store_settings
  from catchmenu_store.store_settings
  where store_id = p_store_id
    and tenant_id = p_tenant_id;

  if coalesce(
    v_store_settings.store_mode, 'NORMAL'
  ) in ('CLOSED', 'HOLIDAY', 'EMERGENCY') then
    return catchmenu_common.build_error_response(
      p_error_key := 'kiosk_store_closed',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'place_kiosk_order'
    );
  end if;

  -- 장바구니 금액 계산 + 검증
  for v_item in
    select * from jsonb_array_elements(
      p_cart_items
    )
  loop
    select id, menu_name, price, menu_status
    into v_menu
    from catchmenu_pos.menus
    where id = (v_item->>'menu_id')::uuid
      and store_id = p_store_id
      and tenant_id = p_tenant_id
      and is_active = true;

    if v_menu.menu_status = 'SOLD_OUT' then
      return catchmenu_common.build_error_response(
        p_error_key := 'menu_sold_out',
        p_locale := p_locale,
        p_params := jsonb_build_object(
          'menu_name', v_menu.menu_name
        ),
        p_tenant_id := p_tenant_id,
        p_store_id := p_store_id,
        p_rpc_name := 'place_kiosk_order'
      );
    end if;

    v_total_amount := v_total_amount
      + v_menu.price
        * (v_item->>'quantity')::int;
    v_item_count := v_item_count + 1;
  end loop;

  -- 최소 주문 금액 확인
  if v_total_amount
    < coalesce(
      v_store_settings.min_order_amount, 0
    )
  then
    return catchmenu_common.build_error_response(
      p_error_key := 'order_amount_below_minimum',
      p_locale := p_locale,
      p_params := jsonb_build_object(
        'min_order_amount',
          v_store_settings.min_order_amount
      ),
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'place_kiosk_order'
    );
  end if;

  -- 주문 번호 생성
  v_order_number := 'K' || lpad(
    (
      select coalesce(count(*), 0) + 1
      from catchmenu_pos.orders
      where store_id = p_store_id
        and tenant_id = p_tenant_id
        and business_day = v_business_day
        and order_source = 'KIOSK'
    )::text, 3, '0'
  );

  -- 세션 생성
  insert into catchmenu_pos.order_sessions (
    tenant_id, store_id,
    session_type, session_status,
    table_number,
    guest_count,
    session_started_at,
    business_day, business_timezone
  ) values (
    p_tenant_id, p_store_id,
    case p_order_type
      when 'TABLE' then 'TABLE'
      else 'KIOSK'
    end,
    'SEATED',
    p_table_number,
    1,
    now(),
    v_business_day, v_timezone
  )
  returning id into v_session_id;

  -- 주문 생성
  insert into catchmenu_pos.orders (
    tenant_id, store_id,
    session_id, order_number,
    order_type, order_status,
    order_source,
    total_amount, final_amount,
    ordered_at,
    business_day, business_timezone
  ) values (
    p_tenant_id, p_store_id,
    v_session_id, v_order_number,
    p_order_type, 'CONFIRMED',
    'KIOSK',
    v_total_amount, v_total_amount,
    now(),
    v_business_day, v_timezone
  )
  returning id into v_order_id;

  -- 주문 항목 + KDS 티켓 생성
  for v_item in
    select * from jsonb_array_elements(
      p_cart_items
    )
  loop
    select id, menu_name, price,
           is_kds_required, kitchen_zone
    into v_menu
    from catchmenu_pos.menus
    where id = (v_item->>'menu_id')::uuid
      and store_id = p_store_id
      and tenant_id = p_tenant_id;

    -- 주문 항목
    insert into catchmenu_pos.order_items (
      tenant_id, store_id,
      order_id, menu_id,
      menu_name_snapshot,
      quantity, unit_price, subtotal,
      item_options
    ) values (
      p_tenant_id, p_store_id,
      v_order_id, v_menu.id,
      v_menu.menu_name,
      (v_item->>'quantity')::int,
      v_menu.price,
      v_menu.price * (v_item->>'quantity')::int,
      coalesce(
        v_item->'options', '[]'::jsonb
      )
    );

    -- KDS 티켓 (HOLD 상태 = 특허2)
    -- 키오스크 = 결제 전 주문
    -- → HOLD 유지 → 결제 후 COMMITTED
    if v_menu.is_kds_required then
      insert into catchmenu_kds.kds_tickets (
        tenant_id, store_id,
        order_id, menu_id,
        menu_name_snapshot,
        quantity_snapshot,
        kitchen_zone,
        kds_status,
        conditions_met,
        ticket_created_at,
        business_day, business_timezone
      ) values (
        p_tenant_id, p_store_id,
        v_order_id, v_menu.id,
        v_menu.menu_name,
        (v_item->>'quantity')::int,
        coalesce(
          v_menu.kitchen_zone, 'MAIN'
        ),
        'HOLD',
        jsonb_build_object(
          'payment_confirmed', false,
          'kds_release_authorized', false,
          'order_source', 'KIOSK'
        ),
        now(),
        v_business_day, v_timezone
      );
    end if;
  end loop;

  -- 키오스크 세션 업데이트
  update catchmenu_store.kiosk_sessions
  set
    order_id = v_order_id,
    session_status = 'PAYMENT',
    cart_items = p_cart_items,
    cart_total = v_total_amount,
    order_placed_at = now(),
    last_activity_at = now()
  where id = p_kiosk_session_id;

  -- Realtime → 직원 앱 알림
  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_channel_type := 'STAFF_ALERTS',
    p_event_type := 'takeout_order_received',
    p_payload := jsonb_build_object(
      'order_id', v_order_id,
      'order_number', v_order_number,
      'order_type', p_order_type,
      'order_source', 'KIOSK',
      'total_amount', v_total_amount,
      'item_count', v_item_count,
      'kiosk_id', p_kiosk_id,
      'table_number', p_table_number,
      'alert_message',
        catchmenu_common.get_message(
          'new_order_alert', 'ko',
          jsonb_build_object(
            'order_number', v_order_number
          )
        )
    )
  );

  -- ledger event
  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, event_payload,
    order_id, correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'order', 'kiosk_order_placed', 1,
    'order', v_order_id,
    null, 'CONFIRMED',
    'KIOSK',
    jsonb_build_object(
      'kiosk_id', p_kiosk_id,
      'order_number', v_order_number,
      'order_type', p_order_type,
      'total_amount', v_total_amount,
      'item_count', v_item_count,
      'kds_status', 'HOLD'
    ),
    v_order_id, p_correlation_id,
    v_business_day, v_timezone, now()
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'kiosk_order_placed',
    p_data := jsonb_build_object(
      'order_id', v_order_id,
      'order_number', v_order_number,
      'order_type', p_order_type,
      'total_amount', v_total_amount,
      'item_count', v_item_count,
      'kds_status', 'HOLD',
      'kds_note',
        '결제 완료 후 주방 조리 시작',
      'order_number_message',
        catchmenu_common.get_message(
          'kiosk_order_number', p_locale,
          jsonb_build_object(
            'order_number', v_order_number
          )
        ),
      'next_step', 'PAYMENT',
      'payment_methods', (
        select payment_methods
        from catchmenu_store.kiosk_configs
        where id = p_kiosk_id
      )
    ),
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );
end;
$$;


create or replace function
  catchmenu_store.get_kiosk_order_status(
  p_tenant_id uuid,
  p_store_id uuid,
  p_order_id uuid,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_store,
                  catchmenu_pos,
                  catchmenu_kds,
                  catchmenu_payment,
                  catchmenu_common
as $$
declare
  v_order record;
  v_kds_status text;
  v_payment_status text;
  v_items jsonb;
begin
  select id, order_number, order_status,
         order_type, final_amount,
         ordered_at, paid_at
  into v_order
  from catchmenu_pos.orders
  where id = p_order_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id;

  if v_order.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'order_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'get_kiosk_order_status'
    );
  end if;

  -- KDS 상태
  select max(kds_status) into v_kds_status
  from catchmenu_kds.kds_tickets
  where order_id = p_order_id
    and store_id = p_store_id;

  -- 결제 상태
  select ledger_status into v_payment_status
  from catchmenu_payment.payment_ledger
  where order_id = p_order_id
    and store_id = p_store_id
  order by approved_at desc
  limit 1;

  -- 주문 항목
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'menu_name', menu_name_snapshot,
        'quantity', quantity,
        'unit_price', unit_price,
        'subtotal', subtotal
      )
    ),
    '[]'::jsonb
  )
  into v_items
  from catchmenu_pos.order_items
  where order_id = p_order_id;

  return catchmenu_common.build_success_response(
    p_message_key := 'kiosk_session_loaded',
    p_data := jsonb_build_object(
      'order_id', p_order_id,
      'order_number', v_order.order_number,
      'order_status', v_order.order_status,
      'order_type', v_order.order_type,
      'final_amount', v_order.final_amount,
      'payment_status', coalesce(
        v_payment_status, 'PENDING'
      ),
      'is_paid',
        v_payment_status = 'APPROVED',
      'kds_status', coalesce(
        v_kds_status, 'HOLD'
      ),
      'is_ready',
        v_order.order_status = 'READY',
      'items', v_items,
      'ordered_at', v_order.ordered_at,
      'paid_at', v_order.paid_at,
      'status_display', case
        when v_payment_status <> 'APPROVED'
          then catchmenu_common.get_message(
            'kiosk_payment_select',
            p_locale, null
          )
        when v_order.order_status = 'READY'
          then catchmenu_common.get_message(
            'order_ready', p_locale,
            jsonb_build_object(
              'order_number',
                v_order.order_number
            )
          )
        when v_kds_status = 'COOKING'
          then catchmenu_common.get_message(
            'delivery_cooking_started',
            p_locale, null
          )
        else catchmenu_common.get_message(
          'kiosk_order_placed',
          p_locale, null
        )
      end
    ),
    p_locale := p_locale
  );
end;
$$;


create or replace function
  catchmenu_store.start_kiosk_session(
  p_tenant_id uuid,
  p_store_id uuid,
  p_kiosk_id uuid,
  p_locale text default 'ko',
  p_table_number text default null,
  p_customer_id uuid default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_store,
                  catchmenu_common
as $$
declare
  v_session_id uuid;
  v_business_day date;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  -- 기존 활성 세션 TIMEOUT 처리
  update catchmenu_store.kiosk_sessions
  set
    session_status = 'TIMEOUT',
    session_ended_at = now()
  where kiosk_id = p_kiosk_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
    and session_status in (
      'BROWSING', 'CART'
    );

  -- 새 세션 생성
  insert into catchmenu_store.kiosk_sessions (
    tenant_id, store_id,
    kiosk_id, session_locale,
    table_number, customer_id,
    session_status, cart_items, cart_total,
    business_day
  ) values (
    p_tenant_id, p_store_id,
    p_kiosk_id, p_locale,
    p_table_number, p_customer_id,
    'BROWSING', '[]'::jsonb, 0,
    v_business_day
  )
  returning id into v_session_id;

  return catchmenu_common.build_success_response(
    p_message_key := 'kiosk_session_loaded',
    p_data := jsonb_build_object(
      'session_id', v_session_id,
      'locale', p_locale,
      'table_number', p_table_number,
      'session_status', 'BROWSING',
      'welcome_message',
        catchmenu_common.get_message(
          'kiosk_welcome', p_locale, null
        )
    ),
    p_locale := p_locale
  );
end;
$$;


create or replace function
  catchmenu_store.get_kiosk_dashboard(
  p_tenant_id uuid,
  p_store_id uuid,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_store,
                  catchmenu_pos,
                  catchmenu_common
as $$
declare
  v_business_day date;
  v_kiosk_list jsonb;
  v_today_summary jsonb;
  v_session_summary jsonb;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  -- 키오스크 목록 + 상태
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'kiosk_id', k.id,
        'kiosk_code', k.kiosk_code,
        'kiosk_name', k.kiosk_name,
        'kiosk_type', k.kiosk_type,
        'order_type', k.order_type,
        'table_number', k.table_number,
        'default_locale', k.default_locale,
        'supported_locales',
          k.supported_locales,
        'is_active', k.is_active,
        'last_heartbeat_at',
          k.last_heartbeat_at,
        'is_online', coalesce(
          k.last_heartbeat_at
            > now() - interval '5 minutes',
          false
        ),
        'today_orders', coalesce(
          orders.order_count, 0
        ),
        'today_revenue', coalesce(
          orders.revenue, 0
        ),
        'active_sessions', coalesce(
          sessions.active_count, 0
        )
      )
      order by k.kiosk_code asc
    ),
    '[]'::jsonb
  )
  into v_kiosk_list
  from catchmenu_store.kiosk_configs k
  left join lateral (
    select
      count(*) as order_count,
      coalesce(
        sum(o.final_amount), 0
      ) as revenue
    from catchmenu_pos.orders o
    where o.store_id = p_store_id
      and o.tenant_id = p_tenant_id
      and o.business_day = v_business_day
      and o.order_source = 'KIOSK'
      and o.order_status = 'COMPLETED'
  ) orders on true
  left join lateral (
    select count(*) as active_count
    from catchmenu_store.kiosk_sessions ks
    where ks.kiosk_id = k.id
      and ks.session_status in (
        'BROWSING', 'CART', 'PAYMENT'
      )
  ) sessions on true
  where k.store_id = p_store_id
    and k.tenant_id = p_tenant_id;

  -- 오늘 키오스크 전체 요약
  select jsonb_build_object(
    'total_orders', count(*),
    'completed_orders', count(*) filter (
      where order_status = 'COMPLETED'
    ),
    'total_revenue', coalesce(
      sum(final_amount) filter (
        where order_status = 'COMPLETED'
      ), 0
    ),
    'locale_breakdown', (
      select coalesce(
        jsonb_object_agg(
          session_locale, cnt
        ),
        '{}'::jsonb
      )
      from (
        select ks.session_locale,
               count(*)::int as cnt
        from catchmenu_store.kiosk_sessions ks
        where ks.store_id = p_store_id
          and ks.tenant_id = p_tenant_id
          and ks.business_day = v_business_day
        group by ks.session_locale
      ) l
    )
  )
  into v_today_summary
  from catchmenu_pos.orders
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_business_day
    and order_source = 'KIOSK';

  return catchmenu_common.build_success_response(
    p_message_key := 'kiosk_dashboard_loaded',
    p_data := jsonb_build_object(
      'store_id', p_store_id,
      'business_day', v_business_day,
      'kiosks', v_kiosk_list,
      'kiosk_count',
        jsonb_array_length(v_kiosk_list),
      'today_summary', v_today_summary,
      'locale_note', jsonb_build_object(
        'supported',
          '["ko","en","zh","ja","vi","th"]',
        'foreign_visitor_primary',
          '["en","zh","ja","vi","th"]',
        'use_case',
          '외국인 전용 미니 키오스크'
      ),
      'loaded_at', now()
    ),
    p_locale := p_locale
  );
end;
$$;


-- =============================================
-- 기본 키오스크 시드 (1호점)
-- =============================================
insert into catchmenu_store.kiosk_configs (
  tenant_id, store_id,
  kiosk_code, kiosk_name, kiosk_type,
  order_type,
  default_locale, supported_locales,
  payment_methods,
  show_allergen_info, show_cms_events,
  idle_timeout_seconds
) values
(
  '00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000002',
  'KIOSK-01',
  '1번 키오스크 (외국인 전용)',
  'MINI',
  'TAKEOUT',
  'en',
  '["en","zh","ja","vi","th","ko"]'::jsonb,
  '["CARD","TOSS_PAYMENTS"]'::jsonb,
  true, true, 120
),
(
  '00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000002',
  'KIOSK-02',
  '2번 키오스크 (테이블 QR)',
  'TABLE',
  'TABLE',
  'ko',
  '["ko","en","zh","ja","vi","th"]'::jsonb,
  '["CARD","TOSS_PAYMENTS"]'::jsonb,
  true, true, 180
)
on conflict (store_id, kiosk_code)
do nothing;


-- grants
do $$
begin
  grant execute on function
    catchmenu_store.bootstrap_kiosk(
      uuid, uuid, text, uuid, text
    ) to authenticated;

  grant execute on function
    catchmenu_store.get_kiosk_menu(
      uuid, uuid, uuid, text, text
    ) to authenticated;

  grant execute on function
    catchmenu_store.place_kiosk_order(
      uuid, uuid, uuid, uuid, jsonb,
      text, text, text, text
    ) to authenticated;

  grant execute on function
    catchmenu_store.get_kiosk_order_status(
      uuid, uuid, uuid, text
    ) to authenticated;

  grant execute on function
    catchmenu_store.start_kiosk_session(
      uuid, uuid, uuid, text, text, uuid
    ) to authenticated;

  grant execute on function
    catchmenu_store.get_kiosk_dashboard(
      uuid, uuid, text
    ) to authenticated;
end;
$$;

comment on function
  catchmenu_store.bootstrap_kiosk(
    uuid, uuid, text, uuid, text
  ) is
  '미니 키오스크 부트스트랩.
   단일 RPC로 전체 초기화.

   반환 데이터:
   - 키오스크 설정
   - 매장 정보 + 영업 여부
   - 언어 설정 (6개 로케일)
   - 결제 방법 설정
   - UI 설정 (타임아웃/알레르겐)
   - 메뉴 카탈로그 (다국어)
   - CMS 이벤트/배너

   외국인 전용 키오스크:
   default_locale = en
   supported_locales 우선순위:
   en → zh → ja → vi → th → ko

   Flutter 키오스크 시작 흐름:
   1. bootstrap_kiosk() 전체 로드
   2. start_kiosk_session() 세션 시작
   3. 언어 선택 화면
   4. get_kiosk_menu() 메뉴 표시
   5. 장바구니 → place_kiosk_order()
   6. 결제 → confirm_payment()
   7. 완료 화면 → 세션 종료

   idle_timeout_seconds 경과 시:
   세션 TIMEOUT → 초기 화면 복귀.';

comment on function
  catchmenu_store.place_kiosk_order(
    uuid, uuid, uuid, uuid, jsonb,
    text, text, text, text
  ) is
  '키오스크 주문 생성.
   특허2 적용:
   KDS = HOLD (결제 전)
   → 결제 완료 후 confirm_payment() 호출
   → release_kds_after_payment()
   → KDS = COMMITTED (조리 시작)

   order_source = KIOSK:
   직원 앱 대시보드에서 KIOSK 주문 구분.
   대시보드 locale_breakdown:
   외국인 주문 비율 확인 가능.

   주문 번호: K001, K002, K003...
   (키오스크 전용 번호체계)

   Realtime → 직원 앱 즉시 알림.
   1호점 외국인 대응 핵심 기능.';