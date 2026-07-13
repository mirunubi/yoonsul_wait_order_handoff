-- 0081_create_customer_app_rpc.sql
--
-- DEFERRED: customer_id/customer_token relationship undesigned as of
-- 2026-07-10 -- see sql/migrations/CHANGELOG.md. Do not re-enable until
-- order_sessions <-> customers linkage is explicitly designed (new
-- forward migration required).
--
-- Design gap addressed by 005027_Policy_Order_Payment_Three_Path_Gate_
-- Sequencing_And_Runtime_Control.md. Design-ready as of 2026-07-10 --
-- not yet re-enabled; re-enabling requires a new forward migration
-- through 000701's full pipeline (design lock, human approval,
-- implementation, verification, audit).
--
-- catchmenu_pos.order_sessions (already applied, 0012) has no
-- customer_id column -- only an unused customer_token text field with
-- no established relationship to catchmenu_store.customers anywhere in
-- the codebase. The customer_order_history view and every function
-- below that depended on it (or on writing customer_id into
-- order_sessions) have had that specific dependency commented out, not
-- deleted. customer_app_sessions.customer_id (this file's own new
-- table) is unaffected -- it has a real, valid FK to customers(id).
--
-- Purpose: Customer app session and takeout order flow RPCs.
--          Customer app bootstrap, takeout order placement,
--          order tracking, loyalty integration.
--          1-B차 포장/픽업/단골 멤버십 앱 핵심.
-- Depends on: 0080_create_cms_content_rpc.sql
-- Creates:
--   catchmenu_store.customer_app_sessions (table)
--   catchmenu_store.customer_order_history (view)
--   function catchmenu_store.bootstrap_customer_app(...)
--   function catchmenu_store.place_takeout_order(...)
--   function catchmenu_store.track_takeout_order(...)
--   function catchmenu_store.get_customer_home(...)
--   function catchmenu_store.register_customer_push_token(...)

-- =============================================
-- customer_app_sessions table
-- 고객 앱 세션
-- Phase 2: Firebase Firestore 마이그레이션 대상
-- =============================================
create table if not exists
  catchmenu_store.customer_app_sessions (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid
    references catchmenu_hq.stores(id),

  -- 고객 식별
  customer_id uuid
    references catchmenu_store.customers(id),
  phone_hash text,
  is_guest boolean not null default false,

  -- 앱 정보
  app_version text,
  os_type text,
  device_token text,
  locale text not null default 'ko',

  -- 세션 상태
  session_status text not null default 'ACTIVE',
  last_active_at timestamptz not null default now(),
  expires_at timestamptz
    not null default now() + interval '30 days',

  -- 현재 매장 (선택된 매장)
  current_store_id uuid
    references catchmenu_hq.stores(id),

  -- 장바구니 (임시 저장)
  cart_data jsonb default '{}'::jsonb,
  cart_updated_at timestamptz,

  -- 푸시 알림
  push_enabled boolean not null default true,
  push_token text,
  push_token_updated_at timestamptz,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint chk_session_status check (
    session_status in (
      'ACTIVE', 'EXPIRED', 'LOGGED_OUT'
    )
  ),
  constraint chk_os_type check (
    os_type in ('IOS', 'ANDROID', 'WEB', null)
  )
);

create index if not exists idx_customer_sessions
  on catchmenu_store.customer_app_sessions(
    customer_id, session_status
  ) where session_status = 'ACTIVE';
create index if not exists idx_customer_sessions_store
  on catchmenu_store.customer_app_sessions(
    tenant_id, current_store_id
  ) where session_status = 'ACTIVE';

alter table catchmenu_store.customer_app_sessions
  enable row level security;
alter table catchmenu_store.customer_app_sessions
  force row level security;

drop policy if exists customer_sessions_isolation
  on catchmenu_store.customer_app_sessions;
create policy customer_sessions_isolation
  on catchmenu_store.customer_app_sessions
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
  );

drop trigger if exists trg_customer_sessions_updated
  on catchmenu_store.customer_app_sessions;
create trigger trg_customer_sessions_updated
  before update on
    catchmenu_store.customer_app_sessions
  for each row execute function
    catchmenu_common.set_updated_at();

comment on table
  catchmenu_store.customer_app_sessions is
  '고객 앱 세션.
   Phase 1: Supabase PostgreSQL
   Phase 2: Firebase Firestore 마이그레이션
   (AI 고객센터 대화 세션과 함께 이동).
   cart_data: 장바구니 임시 저장 (jsonb).
   push_token: FCM 토큰.
   is_guest: 비회원 주문 지원.
   1-B차 고객 멤버십 앱 핵심 테이블.
   특허1: 고객 세션 = Handoff 시작점.';


-- DEFERRED (see file header): customer_order_history view depends on
-- the undesigned order_sessions.customer_id relationship. Original SQL
-- preserved below, commented out.
-- -- =============================================
-- -- customer_order_history view
-- -- 고객 주문 이력 (앱 표시용)
-- -- =============================================
-- create or replace view
--   catchmenu_store.customer_order_history as
-- select
--   o.id as order_id,
--   o.tenant_id,
--   o.store_id,
--   s.store_name,
--   o.order_number,
--   o.order_type,
--   o.order_status,
--   o.final_amount,
--   o.ordered_at,
--   o.completed_at,
--   o.cancelled_at,
--   os.id as session_id,
--   c.id as customer_id,
--   c.phone_hash,
--   -- 주문 항목 요약
--   (
--     select coalesce(
--       jsonb_agg(
--         jsonb_build_object(
--           'menu_name', oi.menu_name_snapshot,
--           'quantity', oi.quantity,
--           'unit_price', oi.unit_price
--         )
--         order by oi.display_order
--       ),
--       '[]'::jsonb
--     )
--     from catchmenu_pos.order_items oi
--     where oi.order_id = o.id
--   ) as items,
--   -- 포인트 정산
--   (
--     select coalesce(sum(point_amount), 0)
--     from catchmenu_store.point_ledger pl
--     where pl.order_id = o.id
--       and pl.point_type = 'EARN'
--   ) as earned_points
-- from catchmenu_pos.orders o
-- join catchmenu_pos.order_sessions os
--   on os.id = o.session_id
-- join catchmenu_hq.stores s
--   on s.id = o.store_id
-- left join catchmenu_store.customers c
--   on c.id = os.customer_id
-- where o.order_type in (
--   'TAKEOUT', 'DELIVERY', 'ONLINE'
-- );
--
-- comment on view
--   catchmenu_store.customer_order_history is
--   '고객 앱 주문 이력 뷰.
--    포장/배달/온라인 주문만 포함.
--    earned_points: 주문당 적립 포인트.
--    1-B차 고객 멤버십 앱 주문 이력 화면.';


-- =============================================
-- RPCs
-- =============================================
create or replace function
  catchmenu_store.bootstrap_customer_app(
  p_tenant_id uuid,
  p_store_id uuid,
  p_phone_hash text default null,
  p_locale text default 'ko',
  p_app_version text default null,
  p_os_type text default null,
  p_push_token text default null
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
  v_customer record;
  v_session_id uuid;
  v_store record;
  v_settings record;
  v_menu_catalog jsonb;
  v_cms_bundle jsonb;
  v_wait_estimate jsonb;
  v_point_balance int := 0;
  v_active_coupons int := 0;
  v_recent_orders jsonb;
  v_business_day date;
  v_timezone text;
begin
  -- 매장 조회
  select id, store_name, store_status, timezone
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
      p_rpc_name := 'bootstrap_customer_app'
    );
  end if;

  v_timezone := v_store.timezone;
  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  -- 매장 설정
  select store_mode, waiting_enabled,
         pre_order_enabled
  into v_settings
  from catchmenu_store.store_settings
  where store_id = p_store_id
    and tenant_id = p_tenant_id;

  -- 고객 조회 (전화번호 해시 기반)
  if p_phone_hash is not null then
    select id, display_name, membership_tier,
           point_balance, visit_count,
           arrival_reliability_score
    into v_customer
    from catchmenu_store.customers
    where phone_hash = p_phone_hash
      and tenant_id = p_tenant_id
      and is_active = true;

    if v_customer.id is not null then
      -- 포인트 잔액
      select coalesce(
        sum(case point_type
          when 'EARN' then point_amount
          when 'USE' then -point_amount
          when 'EXPIRE' then -point_amount
          else 0
        end), 0
      )
      into v_point_balance
      from catchmenu_store.point_ledger
      where customer_id = v_customer.id
        and tenant_id = p_tenant_id;

      -- 사용 가능 쿠폰 수
      select count(*)
      into v_active_coupons
      from catchmenu_store.coupon_issues ci
      join catchmenu_store.coupons c
        on c.id = ci.coupon_id
      where ci.customer_id = v_customer.id
        and ci.issue_status = 'ISSUED'
        and c.coupon_status = 'ACTIVE'
        and (
          ci.expires_at is null
          or ci.expires_at >= now()
        );

      -- DEFERRED (see file header): customer_order_history depends on
      -- the undesigned order_sessions.customer_id relationship.
      -- Original query preserved below, commented out.
      -- -- 최근 주문 3개
      -- select coalesce(
      --   jsonb_agg(
      --     jsonb_build_object(
      --       'order_id', order_id,
      --       'order_number', order_number,
      --       'order_status', order_status,
      --       'final_amount', final_amount,
      --       'ordered_at', ordered_at,
      --       'store_name', store_name,
      --       'item_count',
      --         jsonb_array_length(items)
      --     )
      --     order by ordered_at desc
      --   ),
      --   '[]'::jsonb
      -- )
      -- into v_recent_orders
      -- from catchmenu_store.customer_order_history
      -- where customer_id = v_customer.id
      --   and tenant_id = p_tenant_id
      -- limit 3;
      v_recent_orders := '[]'::jsonb;
    end if;
  end if;

  -- 고객 앱 세션 생성/갱신
  insert into
    catchmenu_store.customer_app_sessions (
    tenant_id, store_id,
    customer_id, phone_hash,
    is_guest,
    app_version, os_type, locale,
    push_token,
    session_status,
    current_store_id,
    last_active_at, expires_at,
    push_enabled, push_token_updated_at
  ) values (
    p_tenant_id, p_store_id,
    v_customer.id, p_phone_hash,
    v_customer.id is null,
    p_app_version, p_os_type, p_locale,
    p_push_token,
    'ACTIVE',
    p_store_id,
    now(), now() + interval '30 days',
    p_push_token is not null,
    case when p_push_token is not null
      then now() else null
    end
  )
  on conflict do nothing
  returning id into v_session_id;

  if v_session_id is null then
    -- 기존 세션 갱신
    update catchmenu_store.customer_app_sessions
    set
      last_active_at = now(),
      expires_at = now() + interval '30 days',
      push_token = coalesce(
        p_push_token, push_token
      ),
      push_token_updated_at = case
        when p_push_token is not null then now()
        else push_token_updated_at
      end,
      app_version = coalesce(
        p_app_version, app_version
      ),
      current_store_id = p_store_id,
      session_status = 'ACTIVE',
      updated_at = now()
    where customer_id = v_customer.id
      and tenant_id = p_tenant_id
      and session_status = 'ACTIVE'
    returning id into v_session_id;
  end if;

  -- 메뉴 카탈로그 (i18n)
  v_menu_catalog := catchmenu_pos
    .get_menu_catalog_i18n(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_locale := p_locale,
      p_include_hidden := false,
      p_include_sold_out := true,
      p_include_allergens := true
    );

  -- CMS 번들 (공지/프로모션)
  v_cms_bundle := catchmenu_store
    .get_store_cms_bundle(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_channel := 'APP',
      p_locale := p_locale
    );

  -- 대기 예상 시간
  v_wait_estimate := catchmenu_pos
    .estimate_wait_time(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_guest_count := 1
    );

  return jsonb_build_object(
    'success', true,
    'session_id', v_session_id,

    -- 매장 정보
    'store', jsonb_build_object(
      'id', v_store.id,
      'store_name', v_store.store_name,
      'store_status', v_store.store_status,
      'store_mode', coalesce(
        v_settings.store_mode, 'NORMAL'
      ),
      'waiting_enabled', coalesce(
        v_settings.waiting_enabled, true
      ),
      'pre_order_enabled', coalesce(
        v_settings.pre_order_enabled, true
      ),
      'timezone', v_store.timezone,
      'business_day', v_business_day
    ),

    -- 고객 정보
    'customer', case
      when v_customer.id is not null
      then jsonb_build_object(
        'id', v_customer.id,
        'display_name', v_customer.display_name,
        'membership_tier',
          v_customer.membership_tier,
        'point_balance', v_point_balance,
        'active_coupons', v_active_coupons,
        'visit_count', v_customer.visit_count,
        'arrival_reliability_score',
          v_customer.arrival_reliability_score
      )
      else jsonb_build_object(
        'is_guest', true
      )
    end,

    -- 메뉴
    'menu_catalog',
      v_menu_catalog->'data',

    -- CMS
    'cms', jsonb_build_object(
      'notices',
        v_cms_bundle->'notices',
      'promotions',
        v_cms_bundle->'promotions',
      'has_urgent_notice',
        v_cms_bundle->'has_urgent_notice'
    ),

    -- 대기 현황
    'wait_info', v_wait_estimate,

    -- 최근 주문
    'recent_orders', coalesce(
      v_recent_orders, '[]'::jsonb
    ),

    -- 설정
    'locale', p_locale,
    'allergen_consult_notice',
      catchmenu_common.get_message(
        'allergen_consult_staff',
        p_locale, null
      ),

    'bootstrapped_at', now(),
    'message_code', 'customer_app_bootstrapped'
  );
end;
$$;


drop function if exists catchmenu_store.place_takeout_order(
  uuid, uuid, jsonb, uuid, text, text, text, uuid, integer, timestamptz, text
);

create or replace function
  catchmenu_store.place_takeout_order(
  p_tenant_id uuid,
  p_store_id uuid,
  p_items jsonb,
  p_customer_id uuid default null,
  p_phone_hash text default null,
  p_locale text default 'ko',
  p_memo text default null,
  p_coupon_issue_id uuid default null,
  p_use_points int default 0,
  p_requested_pickup_at timestamptz default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_store,
                  catchmenu_pos,
                  catchmenu_kds,
                  catchmenu_payment,
                  catchmenu_ledger,
                  catchmenu_common,
                  catchmenu_hq
as $$
declare
  v_customer record;
  v_settings record;
  v_session_id uuid;
  v_order_id uuid;
  v_order_number text;
  v_item jsonb;
  v_menu record;
  v_total_amount int := 0;
  v_discount_amount int := 0;
  v_coupon record;
  v_coupon_discount int := 0;
  v_point_discount int := 0;
  v_final_amount int;
  v_point_balance int := 0;
  v_business_day date;
  v_timezone text;
  v_order_seq int;
  v_kds_result jsonb;
begin
  if jsonb_array_length(
    coalesce(p_items, '[]'::jsonb)
  ) = 0 then
    return catchmenu_common.build_error_response(
      p_error_key := 'items_required',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'place_takeout_order'
    );
  end if;

  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  -- 매장 설정 확인
  select store_mode
  into v_settings
  from catchmenu_store.store_settings
  where store_id = p_store_id
    and tenant_id = p_tenant_id;

  if coalesce(v_settings.store_mode, 'NORMAL')
    in ('CLOSED', 'EMERGENCY')
  then
    return catchmenu_common.build_error_response(
      p_error_key := 'pre_order_disabled',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'place_takeout_order'
    );
  end if;

  -- 고객 조회
  if p_customer_id is not null then
    select id, display_name,
           membership_tier, point_balance
    into v_customer
    from catchmenu_store.customers
    where id = p_customer_id
      and tenant_id = p_tenant_id
      and is_active = true;
  elsif p_phone_hash is not null then
    select id, display_name,
           membership_tier, point_balance
    into v_customer
    from catchmenu_store.customers
    where phone_hash = p_phone_hash
      and tenant_id = p_tenant_id
      and is_active = true;
  end if;

  -- 포인트 잔액 확인
  if v_customer.id is not null
    and p_use_points > 0
  then
    select coalesce(
      sum(case point_type
        when 'EARN' then point_amount
        when 'USE' then -point_amount
        when 'EXPIRE' then -point_amount
        else 0
      end), 0
    )
    into v_point_balance
    from catchmenu_store.point_ledger
    where customer_id = v_customer.id
      and tenant_id = p_tenant_id;

    if v_point_balance < p_use_points then
      return catchmenu_common.build_error_response(
        p_error_key := 'insufficient_points',
        p_locale := p_locale,
        p_params := jsonb_build_object(
          'point_balance', v_point_balance
        ),
        p_tenant_id := p_tenant_id,
        p_store_id := p_store_id,
        p_rpc_name := 'place_takeout_order'
      );
    end if;
    v_point_discount := p_use_points;
  end if;

  -- 쿠폰 유효성 확인
  if p_coupon_issue_id is not null then
    select ci.id, ci.issue_status,
           ci.expires_at,
           c.discount_type, c.discount_value,
           c.discount_pct,
           c.min_order_amount,
           c.max_discount_amount
    into v_coupon
    from catchmenu_store.coupon_issues ci
    join catchmenu_store.coupons c
      on c.id = ci.coupon_id
    where ci.id = p_coupon_issue_id
      and ci.customer_id = v_customer.id
      and ci.tenant_id = p_tenant_id
      and ci.issue_status = 'ISSUED'
      and (
        ci.expires_at is null
        or ci.expires_at >= now()
      );

    if v_coupon.id is null then
      return catchmenu_common.build_error_response(
        p_error_key := 'coupon_not_redeemable',
        p_locale := p_locale,
        p_tenant_id := p_tenant_id,
        p_store_id := p_store_id,
        p_rpc_name := 'place_takeout_order'
      );
    end if;
  end if;

  -- 메뉴 항목 계산
  for v_item in
    select * from jsonb_array_elements(p_items)
  loop
    select id, menu_name, price, menu_status,
           is_kds_required
    into v_menu
    from catchmenu_pos.menus
    where id = (v_item->>'menu_id')::uuid
      and store_id = p_store_id
      and tenant_id = p_tenant_id
      and is_active = true;

    if v_menu.id is null then
      return catchmenu_common.build_error_response(
        p_error_key := 'menu_not_found',
        p_locale := p_locale,
        p_tenant_id := p_tenant_id,
        p_store_id := p_store_id,
        p_rpc_name := 'place_takeout_order'
      );
    end if;

    if v_menu.menu_status = 'SOLD_OUT' then
      return catchmenu_common.build_error_response(
        p_error_key := 'menu_sold_out',
        p_locale := p_locale,
        p_params := jsonb_build_object(
          'menu_name', v_menu.menu_name
        ),
        p_tenant_id := p_tenant_id,
        p_store_id := p_store_id,
        p_rpc_name := 'place_takeout_order'
      );
    end if;

    v_total_amount := v_total_amount
      + (v_menu.price
        * (v_item->>'quantity')::int);
  end loop;

  -- 쿠폰 할인 계산
  if v_coupon.id is not null then
    if v_total_amount
      < coalesce(v_coupon.min_order_amount, 0)
    then
      return catchmenu_common.build_error_response(
        p_error_key := 'order_amount_below_minimum',
        p_locale := p_locale,
        p_params := jsonb_build_object(
          'min_order_amount',
            v_coupon.min_order_amount
        ),
        p_tenant_id := p_tenant_id,
        p_store_id := p_store_id,
        p_rpc_name := 'place_takeout_order'
      );
    end if;

    v_coupon_discount := case v_coupon.discount_type
      when 'AMOUNT' then
        v_coupon.discount_value
      when 'PCT' then
        least(
          (v_total_amount
            * v_coupon.discount_pct / 100)::int,
          coalesce(
            v_coupon.max_discount_amount,
            999999
          )
        )
      else 0
    end;
  end if;

  v_discount_amount := v_coupon_discount
    + v_point_discount;
  v_final_amount := greatest(
    0, v_total_amount - v_discount_amount
  );

  -- 주문번호 생성
  select coalesce(max(
    (regexp_match(order_number, '\d+$'))[1]::int
  ), 0) + 1
  into v_order_seq
  from catchmenu_pos.orders
  where store_id = p_store_id
    and business_day = v_business_day;

  v_order_number := 'T'
    || to_char(v_business_day, 'MMDD')
    || lpad(v_order_seq::text, 3, '0');

  -- 세션 생성
  -- DEFERRED (see file header): order_sessions has no customer_id
  -- column (only unused customer_token, no designed relationship to
  -- catchmenu_store.customers). customer_id removed from this INSERT's
  -- column/value list below -- original values were:
  --   customer_id, guest_count, guest_locale
  --   v_customer.id, 1, p_locale
  insert into catchmenu_pos.order_sessions (
    tenant_id, store_id,
    session_type, session_status,
    guest_count, guest_locale,
    session_started_at,
    correlation_id,
    business_day, business_timezone
  ) values (
    p_tenant_id, p_store_id,
    'ONLINE', 'ORDER_CONFIRMED',
    1, p_locale,
    now(),
    p_correlation_id,
    v_business_day, v_timezone
  )
  returning id into v_session_id;

  -- 주문 생성
  -- DEFERRED (see file header): catchmenu_pos.orders has no
  -- customer_id column either (same undesigned relationship).
  -- customer_id removed from this INSERT's column/value list below --
  -- original values were: customer_id / v_customer.id
  insert into catchmenu_pos.orders (
    tenant_id, store_id, session_id,
    order_number, order_type, order_status,
    total_amount, discount_amount,
    final_amount,
    memo,
    requested_pickup_at,
    ordered_at,
    business_day, business_timezone
  ) values (
    p_tenant_id, p_store_id, v_session_id,
    v_order_number, 'TAKEOUT', 'CONFIRMED',
    v_total_amount, v_discount_amount,
    v_final_amount,
    p_memo,
    p_requested_pickup_at,
    now(),
    v_business_day, v_timezone
  )
  returning id into v_order_id;

  -- 주문 항목 삽입
  declare
    v_item_idx int := 0;
  begin
    for v_item in
      select * from jsonb_array_elements(p_items)
    loop
      select id, menu_name, price,
             is_kds_required,
             estimated_minutes
      into v_menu
      from catchmenu_pos.menus
      where id = (v_item->>'menu_id')::uuid;

      insert into catchmenu_pos.order_items (
        tenant_id, store_id, order_id,
        menu_id, menu_name_snapshot,
        quantity, unit_price, subtotal,
        is_kds_required,
        display_order
      ) values (
        p_tenant_id, p_store_id, v_order_id,
        v_menu.id, v_menu.menu_name,
        (v_item->>'quantity')::int,
        v_menu.price,
        v_menu.price
          * (v_item->>'quantity')::int,
        v_menu.is_kds_required,
        v_item_idx
      );

      v_item_idx := v_item_idx + 1;
    end loop;
  end;

  -- 쿠폰 사용 처리
  if v_coupon.id is not null then
    update catchmenu_store.coupon_issues
    set
      issue_status = 'USED',
      used_at = now(),
      used_order_id = v_order_id,
      updated_at = now()
    where id = p_coupon_issue_id;
  end if;

  -- 포인트 사용 처리
  if v_point_discount > 0
    and v_customer.id is not null
  then
    perform catchmenu_store.deduct_points(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_customer_id := v_customer.id,
      p_deduct_amount := v_point_discount,
      p_deduct_reason := '포장 주문 포인트 사용',
      p_order_id := v_order_id
    );
  end if;

  -- KDS 티켓 생성
  -- 포장은 TAKEOUT zone
  insert into catchmenu_kds.kds_tickets (
    tenant_id, store_id,
    order_id, session_id,
    menu_id, menu_name_snapshot,
    quantity_snapshot,
    kitchen_zone,
    kds_status,
    conditions_met,
    ticket_created_at,
    business_day, business_timezone
  )
  select
    p_tenant_id, p_store_id,
    v_order_id, v_session_id,
    (v_item->>'menu_id')::uuid,
    m.menu_name,
    (v_item->>'quantity')::int,
    'TAKEOUT',
    'HOLD',
    jsonb_build_object(
      'payment_confirmed', false,
      'kds_release_authorized', false
    ),
    now(),
    v_business_day, v_timezone
  from jsonb_array_elements(p_items) v_item
  join catchmenu_pos.menus m
    on m.id = (v_item->>'menu_id')::uuid
  where m.is_kds_required = true;

  -- ledger event
  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, caused_by_id,
    event_payload,
    session_id, order_id,
    correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'order', 'takeout_order_placed', 1,
    'order', v_order_id,
    null, 'CONFIRMED',
    'CUSTOMER', v_customer.id,
    jsonb_build_object(
      'order_number', v_order_number,
      'total_amount', v_total_amount,
      'discount_amount', v_discount_amount,
      'final_amount', v_final_amount,
      'coupon_used', v_coupon.id is not null,
      'points_used', v_point_discount
    ),
    v_session_id, v_order_id,
    p_correlation_id,
    v_business_day, v_timezone, now()
  );

  -- 직원 앱 알림
  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_channel_type := 'STAFF_ALERTS',
    p_event_type := 'takeout_order_received',
    p_payload := jsonb_build_object(
      'order_id', v_order_id,
      'order_number', v_order_number,
      'final_amount', v_final_amount,
      'customer_name',
        coalesce(v_customer.display_name, '비회원'),
      'requested_pickup_at',
        p_requested_pickup_at,
      'item_count',
        jsonb_array_length(p_items)
    ),
    p_locale := p_locale
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'order_confirmed',
    p_data := jsonb_build_object(
      'order_id', v_order_id,
      'order_number', v_order_number,
      'session_id', v_session_id,
      'order_status', 'CONFIRMED',
      'order_type', 'TAKEOUT',
      'total_amount', v_total_amount,
      'discount_amount', v_discount_amount,
      'coupon_discount', v_coupon_discount,
      'point_discount', v_point_discount,
      'final_amount', v_final_amount,
      'requested_pickup_at',
        p_requested_pickup_at,
      'business_day', v_business_day,
      'next_step', 'AWAIT_PAYMENT'
    ),
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );
end;
$$;


create or replace function
  catchmenu_store.track_takeout_order(
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
  v_items jsonb;
  v_kds_status jsonb;
  v_payment record;
  v_status_message text;
begin
  -- 주문 조회
  select o.id, o.order_number, o.order_status,
         o.order_type, o.total_amount,
         o.discount_amount, o.final_amount,
         o.memo,
         o.ordered_at, o.ready_at,
         o.completed_at, o.cancelled_at,
         o.requested_pickup_at
  into v_order
  from catchmenu_pos.orders o
  where o.id = p_order_id
    and o.store_id = p_store_id
    and o.tenant_id = p_tenant_id;

  if v_order.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'order_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'track_takeout_order'
    );
  end if;

  -- 주문 항목
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'menu_name', menu_name_snapshot,
        'quantity', quantity,
        'unit_price', unit_price,
        'subtotal', subtotal
      )
      order by display_order
    ),
    '[]'::jsonb
  )
  into v_items
  from catchmenu_pos.order_items
  where order_id = p_order_id;

  -- KDS 상태
  select jsonb_build_object(
    'total_tickets', count(*),
    'cooking_count', count(*) filter (
      where kds_status = 'COOKING'
    ),
    'ready_count', count(*) filter (
      where kds_status in (
        'READY', 'READY_TO_COMMIT'
      )
    ),
    'completed_count', count(*) filter (
      where kds_status in (
        'COMPLETED', 'SERVED'
      )
    ),
    'all_ready', bool_and(
      kds_status in (
        'READY', 'READY_TO_COMMIT',
        'COMPLETED', 'SERVED'
      )
    )
  )
  into v_kds_status
  from catchmenu_kds.kds_tickets
  where order_id = p_order_id;

  -- 결제 상태
  select ledger_status, approved_amount,
         provider_type
  into v_payment
  from catchmenu_payment.payment_ledger
  where order_id = p_order_id
    and tenant_id = p_tenant_id
    and ledger_status = 'APPROVED'
  limit 1;

  -- 상태 메시지
  v_status_message := case v_order.order_status
    when 'CONFIRMED' then
      catchmenu_common.get_message(
        'order_confirmed', p_locale, null
      )
    when 'COOKING' then
      catchmenu_common.get_message(
        'kds_overloaded', p_locale, null
      )
    when 'READY' then
      catchmenu_common.get_message(
        'order_ready', p_locale,
        jsonb_build_object(
          'order_number', v_order.order_number
        )
      )
    when 'COMPLETED' then
      catchmenu_common.get_message(
        'order_confirmed', p_locale, null
      )
    when 'CANCELLED' then
      catchmenu_common.get_message(
        'order_cancelled', p_locale, null
      )
    else v_order.order_status
  end;

  return jsonb_build_object(
    'success', true,
    'order_id', p_order_id,
    'order_number', v_order.order_number,
    'order_status', v_order.order_status,
    'order_type', v_order.order_type,
    'status_message', v_status_message,
    'amounts', jsonb_build_object(
      'total_amount', v_order.total_amount,
      'discount_amount', v_order.discount_amount,
      'final_amount', v_order.final_amount
    ),
    'payment', case
      when v_payment.ledger_status is not null
      then jsonb_build_object(
        'status', v_payment.ledger_status,
        'amount', v_payment.approved_amount,
        'provider', v_payment.provider_type
      )
      else jsonb_build_object(
        'status', 'PENDING'
      )
    end,
    'items', v_items,
    'kds', v_kds_status,
    'timeline', jsonb_build_object(
      'ordered_at', v_order.ordered_at,
      'ready_at', v_order.ready_at,
      'completed_at', v_order.completed_at,
      'cancelled_at', v_order.cancelled_at,
      'requested_pickup_at',
        v_order.requested_pickup_at
    ),
    'memo', v_order.memo,
    'message_code', 'order_tracked'
  );
end;
$$;


create or replace function
  catchmenu_store.get_customer_home(
  p_tenant_id uuid,
  p_customer_id uuid,
  p_store_id uuid default null,
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
  v_point_balance int;
  v_active_coupons jsonb;
  v_active_orders jsonb;
  v_recent_orders jsonb;
  v_available_promotions jsonb;
begin
  -- 고객 정보
  select id, display_name, membership_tier,
         point_balance, visit_count,
         lifetime_spend
  into v_customer
  from catchmenu_store.customers
  where id = p_customer_id
    and tenant_id = p_tenant_id
    and is_active = true;

  if v_customer.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'customer_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_rpc_name := 'get_customer_home'
    );
  end if;

  -- 포인트 잔액
  select coalesce(
    sum(case point_type
      when 'EARN' then point_amount
      when 'USE' then -point_amount
      when 'EXPIRE' then -point_amount
      else 0
    end), 0
  )
  into v_point_balance
  from catchmenu_store.point_ledger
  where customer_id = p_customer_id
    and tenant_id = p_tenant_id;

  -- 사용 가능 쿠폰
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'issue_id', ci.id,
        'coupon_name', c.coupon_name,
        'discount_type', c.discount_type,
        'discount_value', c.discount_value,
        'discount_pct', c.discount_pct,
        'min_order_amount', c.min_order_amount,
        'expires_at', ci.expires_at
      )
      order by ci.issued_at desc
    ),
    '[]'::jsonb
  )
  into v_active_coupons
  from catchmenu_store.coupon_issues ci
  join catchmenu_store.coupons c
    on c.id = ci.coupon_id
  where ci.customer_id = p_customer_id
    and ci.tenant_id = p_tenant_id
    and ci.issue_status = 'ISSUED'
    and c.coupon_status = 'ACTIVE'
    and (
      ci.expires_at is null
      or ci.expires_at >= now()
    );

-- DEFERRED (see file header): customer_order_history depends on
-- the undesigned order_sessions.customer_id relationship.
-- Original query preserved below, commented out.
--   -- 진행 중 주문
--   select coalesce(
--     jsonb_agg(
--       jsonb_build_object(
--         'order_id', order_id,
--         'order_number', order_number,
--         'order_status', order_status,
--         'order_type', order_type,
--         'final_amount', final_amount,
--         'ordered_at', ordered_at,
--         'store_name', store_name
--       )
--       order by ordered_at desc
--     ),
--     '[]'::jsonb
--   )
--   into v_active_orders
--   from catchmenu_store.customer_order_history
--   where customer_id = p_customer_id
--     and tenant_id = p_tenant_id
--     and order_status not in (
--       'COMPLETED', 'CANCELLED',
--       'PICKED_UP'
--     )
--     and (
--       p_store_id is null
--       or store_id = p_store_id
--     );
  v_active_orders := '[]'::jsonb;

-- DEFERRED (see file header): customer_order_history depends on
-- the undesigned order_sessions.customer_id relationship.
-- Original query preserved below, commented out.
--   -- 최근 주문 5개
--   select coalesce(
--     jsonb_agg(
--       jsonb_build_object(
--         'order_id', order_id,
--         'order_number', order_number,
--         'order_status', order_status,
--         'final_amount', final_amount,
--         'ordered_at', ordered_at,
--         'store_name', store_name,
--         'item_count',
--           jsonb_array_length(items),
--         'earned_points', earned_points
--       )
--       order by ordered_at desc
--     ),
--     '[]'::jsonb
--   )
--   into v_recent_orders
--   from catchmenu_store.customer_order_history
--   where customer_id = p_customer_id
--     and tenant_id = p_tenant_id
--     and order_status in (
--       'COMPLETED', 'PICKED_UP'
--     )
--     and (
--       p_store_id is null
--       or store_id = p_store_id
--     )
--   limit 5;
  v_recent_orders := '[]'::jsonb;

  -- 사용 가능한 프로모션
  if p_store_id is not null then
    v_available_promotions := (
      catchmenu_store.get_active_promotions(
        p_tenant_id := p_tenant_id,
        p_store_id := p_store_id,
        p_channel := 'APP',
        p_locale := p_locale
      )
    )->'promotions';
  end if;

  return jsonb_build_object(
    'success', true,
    'customer', jsonb_build_object(
      'id', v_customer.id,
      'display_name', v_customer.display_name,
      'membership_tier',
        v_customer.membership_tier,
      'point_balance', v_point_balance,
      'visit_count', v_customer.visit_count,
      'total_spend_amount',
        v_customer.lifetime_spend
    ),
    'active_orders', v_active_orders,
    'active_order_count',
      jsonb_array_length(v_active_orders),
    'coupons', v_active_coupons,
    'coupon_count',
      jsonb_array_length(v_active_coupons),
    'recent_orders', v_recent_orders,
    'promotions', coalesce(
      v_available_promotions, '[]'::jsonb
    ),
    'locale', p_locale,
    'loaded_at', now(),
    'message_code', 'customer_home_loaded'
  );
end;
$$;


create or replace function
  catchmenu_store.register_customer_push_token(
  p_tenant_id uuid,
  p_customer_id uuid,
  p_push_token text,
  p_os_type text default null,
  p_app_version text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_store,
                  catchmenu_common
as $$
declare
  v_updated int;
begin
  if trim(coalesce(p_push_token, '')) = '' then
    return catchmenu_common.build_error_response(
      p_error_key := 'invalid_input',
      p_locale := 'ko',
      p_params := jsonb_build_object(
        'field', 'push_token'
      ),
      p_tenant_id := p_tenant_id,
      p_rpc_name := 'register_customer_push_token'
    );
  end if;

  update catchmenu_store.customer_app_sessions
  set
    push_token = p_push_token,
    push_enabled = true,
    push_token_updated_at = now(),
    os_type = coalesce(p_os_type, os_type),
    app_version = coalesce(
      p_app_version, app_version
    ),
    last_active_at = now(),
    updated_at = now()
  where customer_id = p_customer_id
    and tenant_id = p_tenant_id
    and session_status = 'ACTIVE';

  get diagnostics v_updated = row_count;

  if v_updated = 0 then
    -- 세션이 없으면 새로 생성
    insert into
      catchmenu_store.customer_app_sessions (
      tenant_id, customer_id,
      push_token, push_enabled,
      push_token_updated_at,
      os_type, app_version,
      session_status, last_active_at,
      expires_at
    ) values (
      p_tenant_id, p_customer_id,
      p_push_token, true, now(),
      p_os_type, p_app_version,
      'ACTIVE', now(),
      now() + interval '30 days'
    );
  end if;

  return jsonb_build_object(
    'success', true,
    'customer_id', p_customer_id,
    'push_token_registered', true,
    'message_code', 'push_token_registered'
  );
end;
$$;


-- grants
do $$
begin
  revoke all on function
    catchmenu_store.bootstrap_customer_app(
      uuid, uuid, text, text, text, text, text
    ) from public;
  grant execute on function
    catchmenu_store.bootstrap_customer_app(
      uuid, uuid, text, text, text, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_store.place_takeout_order(
      uuid, uuid, jsonb, uuid, text, text,
      text, uuid, int, timestamptz, text
    ) from public;
  grant execute on function
    catchmenu_store.place_takeout_order(
      uuid, uuid, jsonb, uuid, text, text,
      text, uuid, int, timestamptz, text
    ) to authenticated;

  revoke all on function
    catchmenu_store.track_takeout_order(
      uuid, uuid, uuid, text
    ) from public;
  grant execute on function
    catchmenu_store.track_takeout_order(
      uuid, uuid, uuid, text
    ) to authenticated;

  revoke all on function
    catchmenu_store.get_customer_home(
      uuid, uuid, uuid, text
    ) from public;
  grant execute on function
    catchmenu_store.get_customer_home(
      uuid, uuid, uuid, text
    ) to authenticated;

  revoke all on function
    catchmenu_store.register_customer_push_token(
      uuid, uuid, text, text, text
    ) from public;
  grant execute on function
    catchmenu_store.register_customer_push_token(
      uuid, uuid, text, text, text
    ) to authenticated;
end;
$$;

comment on function
  catchmenu_store.bootstrap_customer_app(
    uuid, uuid, text, text, text, text, text
  ) is
  '고객 앱 시작 시 단일 RPC 호출.
   반환 데이터:
   - 매장 정보 + 운영 상태
   - 고객 멤버십 + 포인트 + 쿠폰
   - 메뉴 카탈로그 (i18n + 알레르겐)
   - CMS 번들 (공지/프로모션)
   - 대기 예상 시간
   - 최근 주문 3개
   Phase 2: 세션 데이터 Firebase 마이그레이션.
   특허1: 고객 앱 = 고객 Handoff 시작점.
   1-B차 포장/멤버십 앱 핵심 bootstrap.';

comment on function
  catchmenu_store.place_takeout_order(
    uuid, uuid, jsonb, uuid, text, text,
    text, uuid, int, timestamptz, text
  ) is
  '포장 주문 접수.
   흐름:
   1. 매장 운영 상태 확인
   2. 쿠폰/포인트 유효성 검증
   3. 메뉴 가용성 + 가격 계산
   4. 할인 적용 (쿠폰 + 포인트)
   5. 세션 + 주문 + 주문항목 생성
   6. KDS 티켓 생성 (HOLD 상태)
   7. 쿠폰/포인트 사용 처리
   8. 직원 앱 Realtime 알림
   결제는 별도 confirm_payment_from_provider().
   특허1: 포장 주문 = Wait/Order Handoff.
   특허2: KDS 티켓 = HOLD (결제 확인 후 릴리즈).
   1-B차 포장 앱 핵심 주문 플로우.';
