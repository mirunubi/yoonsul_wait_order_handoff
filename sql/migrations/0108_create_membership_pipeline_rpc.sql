-- 0108_create_membership_pipeline_rpc.sql
-- Purpose: White-label membership pipeline.
--          4가지 멤버십 모드 지원.
--          1. Standalone: 자체 포인트
--          2. Stamp: 방문 스탬프 → 쿠폰
--          3. Franchise Link: 가맹점 포인트 이관
--          4. Yoonsul Link: yoonsul_os 포인트 이관
--          i18n: 모든 메시지 = message_catalog 참조.
-- Depends on: 0107_create_mini_cms_pipeline_rpc.sql
-- Creates:
--   catchmenu_store.membership_configs (table)
--   catchmenu_store.stamp_cards (table)
--   catchmenu_store.point_transfer_log (table)
--   catchmenu_store.membership_tiers_config (table)
--   function catchmenu_store.get_membership_config(...)
--   function catchmenu_store.earn_points_after_order(...)
--   function catchmenu_store.stamp_visit(...)
--   function catchmenu_store.transfer_points_to_franchise(...)
--   function catchmenu_store.transfer_points_to_yoonsul(...)
--   function catchmenu_store.get_customer_membership(...)
--   function catchmenu_store.get_membership_dashboard(...)

-- =============================================
-- i18n 메시지 등록
-- =============================================
insert into catchmenu_common.message_catalog (
  message_key, locale, message_text
) values
('points_earned', 'ko',
  '{point_amount}P가 적립되었습니다'),
('points_earned', 'en',
  '{point_amount}P earned'),
('points_earned', 'zh',
  '已积{point_amount}分'),
('points_earned', 'ja',
  '{point_amount}Pが積立されました'),
('points_earned', 'vi',
  'Tích {point_amount}P'),
('points_earned', 'th',
  'สะสม {point_amount}P'),

('stamp_added', 'ko',
  '스탬프가 {stamp_count}개 찍혔습니다'),
('stamp_added', 'en',
  '{stamp_count} stamp(s) added'),
('stamp_added', 'zh',
  '已盖{stamp_count}个印章'),
('stamp_added', 'ja',
  'スタンプが{stamp_count}個押されました'),
('stamp_added', 'vi',
  'Thêm {stamp_count} tem'),
('stamp_added', 'th',
  'ประทับตรา {stamp_count} ดวง'),

('stamp_reward_issued', 'ko',
  '스탬프가 가득 찼습니다! 쿠폰이 발급되었습니다'),
('stamp_reward_issued', 'en',
  'Stamp card complete! Coupon issued'),
('stamp_reward_issued', 'zh',
  '集章完成！优惠券已发放'),
('stamp_reward_issued', 'ja',
  'スタンプカードが完成！クーポンが発行されました'),
('stamp_reward_issued', 'vi',
  'Đầy tem! Phiếu giảm giá đã phát'),
('stamp_reward_issued', 'th',
  'ครบตรา! ออกคูปองแล้ว'),

('points_transferred', 'ko',
  '{point_amount}P가 {target_name}(으)로 이관되었습니다'),
('points_transferred', 'en',
  '{point_amount}P transferred to {target_name}'),
('points_transferred', 'zh',
  '{point_amount}分已转移至{target_name}'),
('points_transferred', 'ja',
  '{point_amount}Pが{target_name}に移管されました'),
('points_transferred', 'vi',
  '{point_amount}P chuyển sang {target_name}'),
('points_transferred', 'th',
  'โอน {point_amount}P ไปยัง {target_name}'),

('points_transfer_failed', 'ko',
  '포인트 이관에 실패했습니다. 내부 포인트로 보관됩니다'),
('points_transfer_failed', 'en',
  'Transfer failed. Points held internally'),
('membership_config_loaded', 'ko',
  '멤버십 설정이 로드되었습니다'),
('membership_config_loaded', 'en',
  'Membership config loaded'),
('customer_membership_loaded', 'ko',
  '고객 멤버십이 로드되었습니다'),
('customer_membership_loaded', 'en',
  'Customer membership loaded'),
('membership_dashboard_loaded', 'ko',
  '멤버십 대시보드가 로드되었습니다'),
('membership_dashboard_loaded', 'en',
  'Membership dashboard loaded'),
('tier_upgraded', 'ko',
  '{tier_name} 등급으로 승급되었습니다'),
('tier_upgraded', 'en',
  'Upgraded to {tier_name}'),
('tier_upgraded', 'zh',
  '已升级至{tier_name}'),
('tier_upgraded', 'ja',
  '{tier_name}にランクアップしました'),
('tier_upgraded', 'vi',
  'Nâng hạng lên {tier_name}'),
('tier_upgraded', 'th',
  'อัปเกรดเป็น {tier_name}')
on conflict (message_key, locale) do nothing;

insert into catchmenu_common.error_codes (
  code, error_key, error_domain,
  error_category, http_status, severity
) values
(15001, 'membership_config_not_found',
  'MEMBERSHIP', 'NOT_FOUND', 404, 'WARNING'),
(15002, 'stamp_card_not_found',
  'MEMBERSHIP', 'NOT_FOUND', 404, 'WARNING'),
(15003, 'points_transfer_failed',
  'MEMBERSHIP', 'TECHNICAL', 500, 'WARNING'),
(15004, 'customer_membership_not_found',
  'MEMBERSHIP', 'NOT_FOUND', 404, 'WARNING'),
(15005, 'membership_mode_not_supported',
  'MEMBERSHIP', 'BUSINESS_RULE', 400, 'WARNING')
on conflict (code) do nothing;


-- =============================================
-- membership_configs table
-- 매장별 멤버십 모드 설정
-- =============================================
create table if not exists
  catchmenu_store.membership_configs (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid not null
    references catchmenu_hq.stores(id),

  -- 멤버십 모드
  membership_mode text not null
    default 'STANDALONE',

  -- Standalone 설정
  point_earn_rate numeric(5,2)
    not null default 1.0,
  point_earn_unit int not null default 100,
  point_min_order_amount int
    not null default 0,
  point_expiry_days int default 365,

  -- Stamp 설정
  stamp_enabled boolean
    not null default false,
  stamp_goal int not null default 10,
  stamp_reward_coupon_id uuid
    references catchmenu_store.coupons(id),
  stamp_per_visit int not null default 1,
  stamp_min_order_amount int
    not null default 0,

  -- Franchise Link 설정
  franchise_membership_api_endpoint text,
  franchise_membership_api_key_hash text,
  franchise_brand_code text,
  franchise_point_ratio numeric(5,2)
    default 1.0,

  -- Yoonsul Link 설정
  yoonsul_link_enabled boolean
    not null default false,
  yoonsul_tenant_id uuid,
  yoonsul_point_ratio numeric(5,2)
    default 1.0,

  -- 이관 실패 정책
  transfer_fail_policy text
    not null default 'HOLD_INTERNAL',

  -- 등급 사용 여부
  tier_enabled boolean not null default true,

  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint uq_membership_config unique (
    store_id
  ),
  constraint chk_membership_mode check (
    membership_mode in (
      'STANDALONE',     -- 1. 자체 포인트
      'STAMP',          -- 2. 스탬프
      'FRANCHISE_LINK', -- 3. 가맹점 연동
      'YOONSUL_LINK',   -- 4. 윤슬 OS 연동
      'HYBRID'          -- 복합 (스탬프 + 포인트)
    )
  ),
  constraint chk_transfer_fail_policy check (
    transfer_fail_policy in (
      'HOLD_INTERNAL', -- 내부 보관
      'RETRY_3',       -- 3회 재시도 후 보관
      'DISCARD'        -- 폐기
    )
  )
);

alter table catchmenu_store.membership_configs
  enable row level security;
alter table catchmenu_store.membership_configs
  force row level security;

drop policy if exists membership_config_isolation
  on catchmenu_store.membership_configs;
create policy membership_config_isolation
  on catchmenu_store.membership_configs
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id =
      catchmenu_common.current_store_id()
  );

drop trigger if exists trg_membership_config_updated
  on catchmenu_store.membership_configs;
create trigger trg_membership_config_updated
  before update on
    catchmenu_store.membership_configs
  for each row execute function
    catchmenu_common.set_updated_at();

comment on table
  catchmenu_store.membership_configs is
  '매장별 멤버십 모드 설정.
   STANDALONE: 캐치메뉴 자체 포인트.
   STAMP: 방문 스탬프 → 쿠폰 자동 발급.
   FRANCHISE_LINK: 가맹점 포인트 시스템 이관.
   YOONSUL_LINK: yoonsul_os 포인트 이관.
   HYBRID: 스탬프 + 포인트 동시 운영.
   transfer_fail_policy: 이관 실패 처리.
   화이트라벨 멤버십 핵심 설정 테이블.';


-- =============================================
-- stamp_cards table
-- 고객 스탬프 카드
-- =============================================
create table if not exists
  catchmenu_store.stamp_cards (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid not null
    references catchmenu_hq.stores(id),
  customer_id uuid not null
    references catchmenu_store.customers(id),

  -- 스탬프 현황
  current_stamps int not null default 0,
  total_stamps_earned int not null default 0,
  total_rewards_issued int not null default 0,
  stamp_goal int not null default 10,

  -- 마지막 활동
  last_stamp_at timestamptz,
  last_reward_at timestamptz,

  -- 상태
  card_status text not null default 'ACTIVE',

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint uq_stamp_card unique (
    store_id, customer_id
  ),
  constraint chk_card_status check (
    card_status in (
      'ACTIVE', 'SUSPENDED', 'EXPIRED'
    )
  )
);

create index if not exists idx_stamp_cards
  on catchmenu_store.stamp_cards(
    store_id, customer_id
  ) where card_status = 'ACTIVE';

alter table catchmenu_store.stamp_cards
  enable row level security;
alter table catchmenu_store.stamp_cards
  force row level security;

drop policy if exists stamp_cards_isolation
  on catchmenu_store.stamp_cards;
create policy stamp_cards_isolation
  on catchmenu_store.stamp_cards
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id =
      catchmenu_common.current_store_id()
  );

drop trigger if exists trg_stamp_cards_updated
  on catchmenu_store.stamp_cards;
create trigger trg_stamp_cards_updated
  before update on catchmenu_store.stamp_cards
  for each row execute function
    catchmenu_common.set_updated_at();

comment on table catchmenu_store.stamp_cards is
  '고객 스탬프 카드.
   uq_stamp_card: 매장당 고객 1장.
   current_stamps: 현재 스탬프 수.
   stamp_goal: 설정값에서 복사 (변경 대응).
   goal 도달 시 reward_coupon 자동 발급.
   total_rewards_issued: 누적 보상 횟수.';


-- =============================================
-- point_transfer_log table
-- 포인트 이관 이력
-- =============================================
create table if not exists
  catchmenu_store.point_transfer_log (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid not null
    references catchmenu_hq.stores(id),
  customer_id uuid not null
    references catchmenu_store.customers(id),

  -- 이관 정보
  transfer_type text not null,
  source_points int not null,
  transferred_points int not null,
  transfer_ratio numeric(5,2)
    not null default 1.0,

  -- 대상
  target_system text not null,
  target_customer_id text,
  target_response jsonb,

  -- 상태
  transfer_status text
    not null default 'PENDING',
  retry_count int not null default 0,
  error_detail text,

  -- 연결
  order_id uuid
    references catchmenu_pos.orders(id),

  transferred_at timestamptz
    not null default now(),
  confirmed_at timestamptz,

  constraint chk_transfer_type check (
    transfer_type in (
      'FRANCHISE_LINK',
      'YOONSUL_LINK',
      'INTERNAL_EARN',
      'INTERNAL_USE',
      'INTERNAL_EXPIRE',
      'STAMP_REWARD'
    )
  ),
  constraint chk_transfer_status check (
    transfer_status in (
      'PENDING', 'COMPLETED',
      'FAILED', 'HELD', 'RETRYING'
    )
  )
);

create index if not exists idx_point_transfer
  on catchmenu_store.point_transfer_log(
    store_id, customer_id,
    transferred_at desc
  );
create index if not exists idx_transfer_pending
  on catchmenu_store.point_transfer_log(
    transfer_status, transferred_at
  ) where transfer_status in (
    'PENDING', 'RETRYING'
  );

alter table catchmenu_store.point_transfer_log
  enable row level security;
alter table catchmenu_store.point_transfer_log
  force row level security;

drop policy if exists transfer_log_isolation
  on catchmenu_store.point_transfer_log;
create policy transfer_log_isolation
  on catchmenu_store.point_transfer_log
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id =
      catchmenu_common.current_store_id()
  );

comment on table
  catchmenu_store.point_transfer_log is
  '포인트 이관 이력.
   FRANCHISE_LINK: 가맹점 시스템으로 이관.
   YOONSUL_LINK: yoonsul_os로 이관.
   INTERNAL_*: 내부 포인트 원장.
   STAMP_REWARD: 스탬프 보상 쿠폰.
   HELD: 이관 실패 → 내부 보관.
   append-only 감사 로그.
   특허4: 포인트 이관 = 재무 감사 증빙.';


-- =============================================
-- membership_tiers_config table
-- 등급 설정
-- =============================================
create table if not exists
  catchmenu_store.membership_tiers_config (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid not null
    references catchmenu_hq.stores(id),

  tier_code text not null,
  tier_name_ko text not null,
  tier_name_en text,
  tier_order int not null default 0,

  -- 등급 조건
  min_total_amount int not null default 0,
  min_visit_count int not null default 0,
  min_points int not null default 0,

  -- 등급 혜택
  point_multiplier numeric(4,2)
    not null default 1.0,
  discount_rate numeric(4,2) default 0,
  free_delivery boolean not null default false,
  priority_seating boolean not null default false,

  -- 표시
  tier_badge_color text default '#C0C0C0',
  tier_badge_icon text default 'star',

  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint uq_tier_code unique (
    store_id, tier_code
  )
);

alter table
  catchmenu_store.membership_tiers_config
  enable row level security;
alter table
  catchmenu_store.membership_tiers_config
  force row level security;

drop policy if exists tiers_config_isolation
  on catchmenu_store.membership_tiers_config;
create policy tiers_config_isolation
  on catchmenu_store.membership_tiers_config
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id =
      catchmenu_common.current_store_id()
  );

-- 기본 등급 시드 (STANDALONE 모드용)
do $$
begin
  insert into
    catchmenu_store.membership_tiers_config (
    tenant_id, store_id,
    tier_code, tier_name_ko, tier_name_en,
    tier_order,
    min_total_amount, min_visit_count,
    point_multiplier, discount_rate,
    tier_badge_color, tier_badge_icon
  )
  select
    '00000000-0000-0000-0000-000000000001',
    '00000000-0000-0000-0000-000000000002',
    t.tier_code, t.tier_name_ko,
    t.tier_name_en, t.tier_order,
    t.min_total_amount, t.min_visit_count,
    t.point_multiplier, t.discount_rate,
    t.tier_badge_color, t.tier_badge_icon
  from (values
    ('BRONZE', '브론즈', 'Bronze', 0,
     0, 0, 1.0, 0.0, '#CD7F32', 'circle'),
    ('SILVER', '실버', 'Silver', 1,
     100000, 5, 1.2, 2.0, '#C0C0C0', 'star'),
    ('GOLD', '골드', 'Gold', 2,
     300000, 15, 1.5, 5.0, '#FFD700', 'star_filled'),
    ('VIP', 'VIP', 'VIP', 3,
     1000000, 50, 2.0, 10.0, '#B9A0DC', 'crown')
  ) as t(
    tier_code, tier_name_ko, tier_name_en,
    tier_order, min_total_amount,
    min_visit_count, point_multiplier,
    discount_rate, tier_badge_color,
    tier_badge_icon
  )
  on conflict (store_id, tier_code)
  do nothing;
end;
$$;

comment on table
  catchmenu_store.membership_tiers_config is
  '멤버십 등급 설정.
   기본 등급: BRONZE/SILVER/GOLD/VIP.
   point_multiplier: 등급별 포인트 배율.
   SILVER: 1.2배 / GOLD: 1.5배 / VIP: 2배.
   업주가 앱에서 등급 조건 커스터마이징 가능.
   priority_seating: VIP 우선 착석 기능.';


-- =============================================
-- RPCs
-- =============================================
create or replace function
  catchmenu_store.earn_points_after_order(
  p_tenant_id uuid,
  p_store_id uuid,
  p_customer_id uuid,
  p_order_id uuid,
  p_order_amount int,
  p_locale text default 'ko',
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
  v_config record;
  v_customer record;
  v_tier_config record;
  v_earned_points int;
  v_base_points int;
  v_multiplier numeric;
  v_transfer_result jsonb;
  v_stamp_result jsonb;
  v_business_day date;
  v_old_tier text;
  v_new_tier text;
  v_tier_upgraded boolean := false;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  -- 멤버십 설정 조회
  select membership_mode,
         point_earn_rate, point_earn_unit,
         point_min_order_amount,
         stamp_enabled,
         franchise_point_ratio,
         yoonsul_link_enabled,
         yoonsul_point_ratio,
         transfer_fail_policy,
         tier_enabled
  into v_config
  from catchmenu_store.membership_configs
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and is_active = true;

  if v_config.membership_mode is null then
    -- 설정 없으면 기본 STANDALONE 동작
    v_config.membership_mode := 'STANDALONE';
    v_config.point_earn_rate := 1.0;
    v_config.point_earn_unit := 100;
    v_config.point_min_order_amount := 0;
    v_config.tier_enabled := true;
  end if;

  -- 최소 주문 금액 미달
  if p_order_amount
    < v_config.point_min_order_amount
  then
    return catchmenu_common.build_success_response(
      p_message_key := 'points_earned',
      p_data := jsonb_build_object(
        'earned_points', 0,
        'reason', 'below_minimum_order',
        'min_order_amount',
          v_config.point_min_order_amount
      ),
      p_locale := p_locale
    );
  end if;

  -- 고객 조회
  select id, membership_tier,
         total_points, total_spent_amount,
         visit_count
  into v_customer
  from catchmenu_store.customers
  where id = p_customer_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id;

  if v_customer.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'customer_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'earn_points_after_order'
    );
  end if;

  v_old_tier := v_customer.membership_tier;

  -- 등급별 포인트 배율 조회
  v_multiplier := 1.0;
  if v_config.tier_enabled then
    select point_multiplier
    into v_multiplier
    from catchmenu_store.membership_tiers_config
    where store_id = p_store_id
      and tenant_id = p_tenant_id
      and tier_code = v_customer.membership_tier
      and is_active = true;

    v_multiplier := coalesce(v_multiplier, 1.0);
  end if;

  -- 포인트 계산
  v_base_points := (
    p_order_amount
    / v_config.point_earn_unit
    * v_config.point_earn_rate
  )::int;

  v_earned_points := (
    v_base_points * v_multiplier
  )::int;

  -- 모드별 처리
  case v_config.membership_mode
    when 'STANDALONE', 'HYBRID' then
      -- 내부 포인트 적립
      insert into catchmenu_store.point_ledger (
        tenant_id, store_id, customer_id,
        order_id, point_type,
        points, balance_after,
        description, business_day
      ) values (
        p_tenant_id, p_store_id, p_customer_id,
        p_order_id, 'EARN',
        v_earned_points,
        v_customer.total_points + v_earned_points,
        'ORDER_' || p_order_id::text,
        v_business_day
      );

      -- 고객 포인트 업데이트
      update catchmenu_store.customers
      set
        total_points =
          total_points + v_earned_points,
        total_spent_amount =
          total_spent_amount + p_order_amount,
        updated_at = now()
      where id = p_customer_id;

      -- 이관 로그 (내부 적립)
      insert into
        catchmenu_store.point_transfer_log (
        tenant_id, store_id, customer_id,
        transfer_type, source_points,
        transferred_points, transfer_ratio,
        target_system, transfer_status,
        order_id
      ) values (
        p_tenant_id, p_store_id, p_customer_id,
        'INTERNAL_EARN', p_order_amount,
        v_earned_points, v_config.point_earn_rate,
        'CATCHMENU_INTERNAL', 'COMPLETED',
        p_order_id
      );

    when 'FRANCHISE_LINK' then
      -- Edge Function으로 가맹점 포인트 이관
      perform catchmenu_common.notify_channel(
        p_tenant_id := p_tenant_id,
        p_store_id := p_store_id,
        p_channel_type := 'SYSTEM_EVENTS',
        p_event_type :=
          'franchise_point_transfer_requested',
        p_payload := jsonb_build_object(
          'customer_id', p_customer_id,
          'order_id', p_order_id,
          'order_amount', p_order_amount,
          'points_to_transfer', v_earned_points,
          'transfer_ratio',
            v_config.franchise_point_ratio,
          'franchise_brand_code',
            v_config.franchise_brand_code,
          'api_endpoint',
            v_config
              .franchise_membership_api_endpoint,
          'fail_policy',
            v_config.transfer_fail_policy,
          'correlation_id', p_correlation_id
        )
      );

      -- 이관 로그 (PENDING)
      insert into
        catchmenu_store.point_transfer_log (
        tenant_id, store_id, customer_id,
        transfer_type, source_points,
        transferred_points, transfer_ratio,
        target_system, transfer_status,
        order_id
      ) values (
        p_tenant_id, p_store_id, p_customer_id,
        'FRANCHISE_LINK', p_order_amount,
        v_earned_points,
        v_config.franchise_point_ratio,
        coalesce(
          v_config.franchise_brand_code,
          'FRANCHISE'
        ),
        'PENDING',
        p_order_id
      );

    when 'YOONSUL_LINK' then
      -- Edge Function으로 윤슬 OS 포인트 이관
      perform catchmenu_common.notify_channel(
        p_tenant_id := p_tenant_id,
        p_store_id := p_store_id,
        p_channel_type := 'SYSTEM_EVENTS',
        p_event_type :=
          'yoonsul_point_transfer_requested',
        p_payload := jsonb_build_object(
          'customer_id', p_customer_id,
          'order_id', p_order_id,
          'order_amount', p_order_amount,
          'points_to_transfer', v_earned_points,
          'transfer_ratio',
            v_config.yoonsul_point_ratio,
          'yoonsul_tenant_id',
            v_config.yoonsul_tenant_id,
          'fail_policy',
            v_config.transfer_fail_policy,
          'correlation_id', p_correlation_id
        )
      );

      -- 이관 로그 (PENDING)
      insert into
        catchmenu_store.point_transfer_log (
        tenant_id, store_id, customer_id,
        transfer_type, source_points,
        transferred_points, transfer_ratio,
        target_system, transfer_status,
        order_id
      ) values (
        p_tenant_id, p_store_id, p_customer_id,
        'YOONSUL_LINK', p_order_amount,
        v_earned_points,
        v_config.yoonsul_point_ratio,
        'YOONSUL_OS', 'PENDING',
        p_order_id
      );

    else null;
  end case;

  -- 스탬프 처리 (STAMP 또는 HYBRID)
  if v_config.membership_mode in (
    'STAMP', 'HYBRID'
  ) and v_config.stamp_enabled then
    v_stamp_result :=
      catchmenu_store.stamp_visit(
        p_tenant_id := p_tenant_id,
        p_store_id := p_store_id,
        p_customer_id := p_customer_id,
        p_order_id := p_order_id,
        p_order_amount := p_order_amount,
        p_locale := p_locale,
        p_correlation_id := p_correlation_id
      );
  end if;

  -- 등급 업데이트 확인
  if v_config.tier_enabled then
    select tier_code
    into v_new_tier
    from catchmenu_store.membership_tiers_config
    where store_id = p_store_id
      and tenant_id = p_tenant_id
      and is_active = true
      and min_total_amount <= (
        v_customer.total_spent_amount
        + p_order_amount
      )
    order by tier_order desc
    limit 1;

    if v_new_tier is not null
      and v_new_tier <> v_old_tier
    then
      update catchmenu_store.customers
      set
        membership_tier = v_new_tier,
        updated_at = now()
      where id = p_customer_id;

      v_tier_upgraded := true;

      -- 등급 업그레이드 Realtime 알림
      perform catchmenu_common.notify_channel(
        p_tenant_id := p_tenant_id,
        p_store_id := p_store_id,
        p_channel_type := 'CUSTOMER_APP',
        p_event_type := 'tier_upgraded',
        p_payload := jsonb_build_object(
          'customer_id', p_customer_id,
          'old_tier', v_old_tier,
          'new_tier', v_new_tier,
          'message',
            catchmenu_common.get_message(
              'tier_upgraded', p_locale,
              jsonb_build_object(
                'tier_name', v_new_tier
              )
            )
        )
      );
    end if;
  end if;

  -- ledger event
  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, caused_by_id,
    event_payload,
    order_id, correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'membership', 'points_earned', 1,
    'customer', p_customer_id,
    v_old_tier, coalesce(v_new_tier, v_old_tier),
    'SYSTEM', p_customer_id,
    jsonb_build_object(
      'membership_mode',
        v_config.membership_mode,
      'order_amount', p_order_amount,
      'earned_points', v_earned_points,
      'multiplier', v_multiplier,
      'tier_upgraded', v_tier_upgraded,
      'old_tier', v_old_tier,
      'new_tier', v_new_tier
    ),
    p_order_id, p_correlation_id,
    v_business_day, 'Asia/Seoul', now()
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'points_earned',
    p_data := jsonb_build_object(
      'customer_id', p_customer_id,
      'order_id', p_order_id,
      'membership_mode',
        v_config.membership_mode,
      'earned_points', v_earned_points,
      'base_points', v_base_points,
      'multiplier', v_multiplier,
      'tier', coalesce(v_new_tier, v_old_tier),
      'tier_upgraded', v_tier_upgraded,
      'old_tier', case v_tier_upgraded
        when true then v_old_tier else null end,
      'new_tier', case v_tier_upgraded
        when true then v_new_tier else null end,
      'stamp_result', v_stamp_result->'data'
    ),
    p_locale := p_locale,
    p_params := jsonb_build_object(
      'point_amount', v_earned_points
    ),
    p_correlation_id := p_correlation_id
  );
end;
$$;


create or replace function
  catchmenu_store.stamp_visit(
  p_tenant_id uuid,
  p_store_id uuid,
  p_customer_id uuid,
  p_order_id uuid,
  p_order_amount int,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_store,
                  catchmenu_common
as $$
declare
  v_config record;
  v_card record;
  v_reward_issued boolean := false;
  v_reward_coupon_id uuid;
  v_stamps_added int;
  v_new_stamp_count int;
begin
  -- 스탬프 설정 조회
  select stamp_goal, stamp_reward_coupon_id,
         stamp_per_visit, stamp_min_order_amount
  into v_config
  from catchmenu_store.membership_configs
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and stamp_enabled = true;

  if v_config.stamp_goal is null then
    return catchmenu_common.build_success_response(
      p_message_key := 'stamp_added',
      p_data := jsonb_build_object(
        'enabled', false
      ),
      p_locale := p_locale
    );
  end if;

  -- 최소 주문 금액 확인
  if p_order_amount
    < coalesce(
      v_config.stamp_min_order_amount, 0
    )
  then
    return catchmenu_common.build_success_response(
      p_message_key := 'stamp_added',
      p_data := jsonb_build_object(
        'stamps_added', 0,
        'reason', 'below_minimum_order'
      ),
      p_locale := p_locale
    );
  end if;

  -- 스탬프 카드 조회 또는 생성
  select id, current_stamps, stamp_goal,
         total_rewards_issued
  into v_card
  from catchmenu_store.stamp_cards
  where store_id = p_store_id
    and customer_id = p_customer_id
    and tenant_id = p_tenant_id
    and card_status = 'ACTIVE'
  for update;

  if v_card.id is null then
    insert into catchmenu_store.stamp_cards (
      tenant_id, store_id, customer_id,
      current_stamps, stamp_goal
    ) values (
      p_tenant_id, p_store_id, p_customer_id,
      0, v_config.stamp_goal
    )
    returning id, 0, v_config.stamp_goal, 0
    into v_card;
  end if;

  v_stamps_added := v_config.stamp_per_visit;
  v_new_stamp_count :=
    v_card.current_stamps + v_stamps_added;

  -- 목표 달성 확인
  if v_new_stamp_count >= v_config.stamp_goal then
    v_reward_issued := true;
    v_reward_coupon_id :=
      v_config.stamp_reward_coupon_id;

    -- 스탬프 리셋
    v_new_stamp_count :=
      v_new_stamp_count - v_config.stamp_goal;

    -- 쿠폰 발급
    if v_reward_coupon_id is not null then
      insert into catchmenu_store.coupon_issues (
        tenant_id, store_id,
        coupon_id, customer_id,
        issue_reason, issued_at,
        valid_until
      )
      select
        p_tenant_id, p_store_id,
        v_reward_coupon_id, p_customer_id,
        'STAMP_REWARD',
        now(),
        now() + interval '30 days'
      from catchmenu_store.coupons
      where id = v_reward_coupon_id;
    end if;

    -- 이관 로그 (스탬프 보상)
    insert into
      catchmenu_store.point_transfer_log (
      tenant_id, store_id, customer_id,
      transfer_type, source_points,
      transferred_points, transfer_ratio,
      target_system, transfer_status,
      order_id
    ) values (
      p_tenant_id, p_store_id, p_customer_id,
      'STAMP_REWARD', v_config.stamp_goal,
      1, 1.0,
      'COUPON_' || v_reward_coupon_id::text,
      'COMPLETED',
      p_order_id
    );
  end if;

  -- 스탬프 카드 업데이트
  update catchmenu_store.stamp_cards
  set
    current_stamps = v_new_stamp_count,
    total_stamps_earned =
      total_stamps_earned + v_stamps_added,
    total_rewards_issued =
      total_rewards_issued +
        case v_reward_issued when true then 1
        else 0 end,
    last_stamp_at = now(),
    last_reward_at = case v_reward_issued
      when true then now()
      else last_reward_at
    end,
    updated_at = now()
  where id = v_card.id;

  -- 고객 앱 Realtime 알림
  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_channel_type := 'CUSTOMER_APP',
    p_event_type := case v_reward_issued
      when true then 'stamp_reward_issued'
      else 'stamp_added'
    end,
    p_payload := jsonb_build_object(
      'customer_id', p_customer_id,
      'stamps_added', v_stamps_added,
      'current_stamps', v_new_stamp_count,
      'stamp_goal', v_config.stamp_goal,
      'reward_issued', v_reward_issued,
      'reward_coupon_id', v_reward_coupon_id,
      'message', case v_reward_issued
        when true then
          catchmenu_common.get_message(
            'stamp_reward_issued', p_locale, null
          )
        else
          catchmenu_common.get_message(
            'stamp_added', p_locale,
            jsonb_build_object(
              'stamp_count', v_stamps_added
            )
          )
      end
    )
  );

  return catchmenu_common.build_success_response(
    p_message_key := case v_reward_issued
      when true then 'stamp_reward_issued'
      else 'stamp_added'
    end,
    p_data := jsonb_build_object(
      'customer_id', p_customer_id,
      'stamps_added', v_stamps_added,
      'current_stamps', v_new_stamp_count,
      'stamp_goal', v_config.stamp_goal,
      'remaining_stamps',
        greatest(
          0,
          v_config.stamp_goal - v_new_stamp_count
        ),
      'reward_issued', v_reward_issued,
      'reward_coupon_id', v_reward_coupon_id
    ),
    p_locale := p_locale,
    p_params := jsonb_build_object(
      'stamp_count', v_stamps_added
    ),
    p_correlation_id := p_correlation_id
  );
end;
$$;


create or replace function
  catchmenu_store.get_customer_membership(
  p_tenant_id uuid,
  p_store_id uuid,
  p_customer_id uuid,
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
  v_customer record;
  v_config record;
  v_stamp_card record;
  v_tier_config record;
  v_next_tier record;
  v_recent_points jsonb;
  v_recent_transfers jsonb;
begin
  -- 고객 조회
  select id, display_name, membership_tier,
         total_points, total_spent_amount,
         visit_count, first_visit_at,
         last_visit_at
  into v_customer
  from catchmenu_store.customers
  where id = p_customer_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
    and is_active = true;

  if v_customer.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'customer_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'get_customer_membership'
    );
  end if;

  -- 멤버십 설정
  select membership_mode, stamp_enabled,
         stamp_goal, tier_enabled,
         point_earn_rate, point_earn_unit
  into v_config
  from catchmenu_store.membership_configs
  where store_id = p_store_id
    and tenant_id = p_tenant_id;

  -- 스탬프 카드
  if coalesce(v_config.stamp_enabled, false) then
    select id, current_stamps, stamp_goal,
           total_rewards_issued, last_stamp_at
    into v_stamp_card
    from catchmenu_store.stamp_cards
    where store_id = p_store_id
      and customer_id = p_customer_id
      and tenant_id = p_tenant_id
      and card_status = 'ACTIVE';
  end if;

  -- 현재 등급 정보
  select tier_code, tier_name_ko, tier_name_en,
         point_multiplier, discount_rate,
         tier_badge_color, tier_badge_icon
  into v_tier_config
  from catchmenu_store.membership_tiers_config
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and tier_code = v_customer.membership_tier
    and is_active = true;

  -- 다음 등급
  select tier_code, tier_name_ko, tier_name_en,
         min_total_amount, min_visit_count
  into v_next_tier
  from catchmenu_store.membership_tiers_config
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and is_active = true
    and min_total_amount
      > v_customer.total_spent_amount
  order by min_total_amount asc
  limit 1;

  -- 최근 포인트 이력 (5건)
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'point_type', point_type,
        'points', points,
        'balance_after', balance_after,
        'earned_at', created_at
      )
      order by created_at desc
    ),
    '[]'::jsonb
  )
  into v_recent_points
  from catchmenu_store.point_ledger
  where store_id = p_store_id
    and customer_id = p_customer_id
    and tenant_id = p_tenant_id
  limit 5;

  -- 최근 이관 이력 (3건)
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'transfer_type', transfer_type,
        'transferred_points', transferred_points,
        'target_system', target_system,
        'transfer_status', transfer_status,
        'transferred_at', transferred_at
      )
      order by transferred_at desc
    ),
    '[]'::jsonb
  )
  into v_recent_transfers
  from catchmenu_store.point_transfer_log
  where store_id = p_store_id
    and customer_id = p_customer_id
    and tenant_id = p_tenant_id
    and transfer_type in (
      'FRANCHISE_LINK', 'YOONSUL_LINK'
    )
  limit 3;

  return catchmenu_common.build_success_response(
    p_message_key := 'customer_membership_loaded',
    p_data := jsonb_build_object(
      'customer', jsonb_build_object(
        'id', v_customer.id,
        'display_name', v_customer.display_name,
        'membership_tier',
          v_customer.membership_tier,
        'total_points', v_customer.total_points,
        'total_spent_amount',
          v_customer.total_spent_amount,
        'visit_count', v_customer.visit_count,
        'first_visit_at', v_customer.first_visit_at,
        'last_visit_at', v_customer.last_visit_at
      ),
      'membership_mode', coalesce(
        v_config.membership_mode, 'STANDALONE'
      ),
      'tier', case
        when v_tier_config.tier_code is not null
        then jsonb_build_object(
          'tier_code', v_tier_config.tier_code,
          'tier_name', case p_locale
            when 'en' then
              coalesce(
                v_tier_config.tier_name_en,
                v_tier_config.tier_name_ko
              )
            else v_tier_config.tier_name_ko
          end,
          'point_multiplier',
            v_tier_config.point_multiplier,
          'discount_rate',
            v_tier_config.discount_rate,
          'badge_color',
            v_tier_config.tier_badge_color,
          'badge_icon',
            v_tier_config.tier_badge_icon
        )
        else null
      end,
      'next_tier', case
        when v_next_tier.tier_code is not null
        then jsonb_build_object(
          'tier_code', v_next_tier.tier_code,
          'tier_name', v_next_tier.tier_name_ko,
          'remaining_amount',
            v_next_tier.min_total_amount
            - v_customer.total_spent_amount,
          'remaining_visits',
            greatest(
              0,
              v_next_tier.min_visit_count
              - v_customer.visit_count
            )
        )
        else null
      end,
      'stamp_card', case
        when v_stamp_card.id is not null
        then jsonb_build_object(
          'current_stamps',
            v_stamp_card.current_stamps,
          'stamp_goal', coalesce(
            v_stamp_card.stamp_goal,
            v_config.stamp_goal
          ),
          'remaining_stamps', greatest(
            0,
            coalesce(
              v_stamp_card.stamp_goal,
              v_config.stamp_goal
            ) - v_stamp_card.current_stamps
          ),
          'total_rewards',
            v_stamp_card.total_rewards_issued,
          'last_stamp_at',
            v_stamp_card.last_stamp_at
        )
        else null
      end,
      'recent_points', v_recent_points,
      'recent_transfers', v_recent_transfers
    ),
    p_locale := p_locale
  );
end;
$$;


create or replace function
  catchmenu_store.get_membership_dashboard(
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
  v_config record;
  v_customer_summary jsonb;
  v_tier_breakdown jsonb;
  v_stamp_summary jsonb;
  v_transfer_summary jsonb;
  v_business_day date;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  select membership_mode, stamp_enabled,
         stamp_goal, tier_enabled,
         point_earn_rate
  into v_config
  from catchmenu_store.membership_configs
  where store_id = p_store_id
    and tenant_id = p_tenant_id;

  -- 고객 요약
  select jsonb_build_object(
    'total_customers', count(*),
    'active_today', count(*) filter (
      where last_visit_at::date = v_business_day
    ),
    'new_this_month', count(*) filter (
      where first_visit_at
        >= date_trunc('month', now())
    ),
    'total_points_issued', coalesce(
      sum(total_points), 0
    ),
    'avg_spend_per_visit', coalesce(
      avg(
        total_spent_amount::numeric
        / nullif(visit_count, 0)
      )::int, 0
    )
  )
  into v_customer_summary
  from catchmenu_store.customers
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and is_active = true;

  -- 등급별 분포
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'tier', membership_tier,
        'count', cnt,
        'percentage', (
          cnt::numeric
          / nullif(total, 0) * 100
        )::int
      )
      order by
        case membership_tier
          when 'VIP' then 0
          when 'GOLD' then 1
          when 'SILVER' then 2
          else 3
        end
    ),
    '[]'::jsonb
  )
  into v_tier_breakdown
  from (
    select membership_tier,
           count(*) as cnt,
           sum(count(*)) over () as total
    from catchmenu_store.customers
    where store_id = p_store_id
      and tenant_id = p_tenant_id
      and is_active = true
    group by membership_tier
  ) t;

  -- 스탬프 요약
  if coalesce(v_config.stamp_enabled, false) then
    select jsonb_build_object(
      'total_cards', count(*),
      'total_stamps_issued', coalesce(
        sum(total_stamps_earned), 0
      ),
      'total_rewards', coalesce(
        sum(total_rewards_issued), 0
      ),
      'avg_stamps', coalesce(
        avg(current_stamps)::int, 0
      )
    )
    into v_stamp_summary
    from catchmenu_store.stamp_cards
    where store_id = p_store_id
      and tenant_id = p_tenant_id
      and card_status = 'ACTIVE';
  end if;

  -- 이관 요약
  select jsonb_build_object(
    'total_transfers', count(*),
    'completed', count(*) filter (
      where transfer_status = 'COMPLETED'
    ),
    'pending', count(*) filter (
      where transfer_status in (
        'PENDING', 'RETRYING'
      )
    ),
    'failed', count(*) filter (
      where transfer_status = 'FAILED'
    ),
    'held', count(*) filter (
      where transfer_status = 'HELD'
    ),
    'total_transferred_points', coalesce(
      sum(transferred_points) filter (
        where transfer_status = 'COMPLETED'
          and transfer_type in (
            'FRANCHISE_LINK', 'YOONSUL_LINK'
          )
      ), 0
    )
  )
  into v_transfer_summary
  from catchmenu_store.point_transfer_log
  where store_id = p_store_id
    and tenant_id = p_tenant_id;

  return catchmenu_common.build_success_response(
    p_message_key := 'membership_dashboard_loaded',
    p_data := jsonb_build_object(
      'store_id', p_store_id,
      'membership_mode', coalesce(
        v_config.membership_mode, 'STANDALONE'
      ),
      'customer_summary', v_customer_summary,
      'tier_breakdown', v_tier_breakdown,
      'stamp_summary', v_stamp_summary,
      'transfer_summary', v_transfer_summary,
      'config', jsonb_build_object(
        'membership_mode',
          v_config.membership_mode,
        'stamp_enabled',
          v_config.stamp_enabled,
        'stamp_goal', v_config.stamp_goal,
        'tier_enabled', v_config.tier_enabled,
        'point_earn_rate',
          v_config.point_earn_rate
      ),
      'loaded_at', now()
    ),
    p_locale := p_locale
  );
end;
$$;


-- grants
do $$
begin
  revoke all on function
    catchmenu_store.earn_points_after_order(
      uuid, uuid, uuid, uuid, int, text, text
    ) from public;
  grant execute on function
    catchmenu_store.earn_points_after_order(
      uuid, uuid, uuid, uuid, int, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_store.stamp_visit(
      uuid, uuid, uuid, uuid, int, text, text
    ) from public;
  grant execute on function
    catchmenu_store.stamp_visit(
      uuid, uuid, uuid, uuid, int, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_store.get_customer_membership(
      uuid, uuid, uuid, text
    ) from public;
  grant execute on function
    catchmenu_store.get_customer_membership(
      uuid, uuid, uuid, text
    ) to authenticated;

  revoke all on function
    catchmenu_store.get_membership_dashboard(
      uuid, uuid, text
    ) from public;
  grant execute on function
    catchmenu_store.get_membership_dashboard(
      uuid, uuid, text
    ) to authenticated;
end;
$$;

comment on function
  catchmenu_store.earn_points_after_order(
    uuid, uuid, uuid, uuid, int, text, text
  ) is
  '주문 완료 후 멤버십 처리 통합 함수.
   결제 확인 후 자동 호출 권장.

   4가지 모드 자동 분기:
   STANDALONE: 내부 포인트 적립
   STAMP: stamp_visit() 호출
   FRANCHISE_LINK: Edge Function 이관 요청
   YOONSUL_LINK: Edge Function 이관 요청
   HYBRID: 포인트 + 스탬프 동시 처리

   등급 자동 업그레이드:
   total_spent_amount 기준으로 자동 계산.
   업그레이드 시 Realtime 알림.

   이관 실패 처리:
   HOLD_INTERNAL: 내부 포인트로 보관
   실패 건 → point_transfer_log HELD
   재시도: Edge Function 별도 처리.

   화이트라벨 원칙:
   캐치메뉴 = 포인트 생성자
   외부 시스템 = 포인트 수신자
   이관 실패 시 고객 손해 없음.';

comment on function
  catchmenu_store.stamp_visit(
    uuid, uuid, uuid, uuid, int, text, text
  ) is
  '스탬프 적립 + 보상 처리.
   목표 달성 시:
   - 스탬프 리셋 (초과분 이월)
   - 쿠폰 자동 발급 (30일 유효)
   - 고객 앱 Realtime 알림
   - point_transfer_log STAMP_REWARD 기록

   미니키오스크 연동:
   주문 완료 → stamp_visit() 자동 호출
   고객 앱에서 스탬프 카드 실시간 확인.

   10번 방문 → 음료 쿠폰 완전 자동화.';