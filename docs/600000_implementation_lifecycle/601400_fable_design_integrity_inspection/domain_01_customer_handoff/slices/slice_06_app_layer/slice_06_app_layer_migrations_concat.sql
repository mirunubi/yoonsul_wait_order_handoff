-- slice_06 — App Layer (600200 Flutter + catchmenu_app)
-- Files: 3


-- ===== BEGIN sql/migrations/0081_create_customer_app_rpc.sql =====

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
  v_customer_id uuid;
  v_customer_display_name text;
  v_customer_membership_tier text;
  v_customer_point_balance int;
  v_settings record;
  v_session_id uuid;
  v_order_id uuid;
  v_order_number text;
  v_item jsonb;
  v_menu record;
  v_total_amount int := 0;
  v_discount_amount int := 0;
  v_coupon_id uuid;
  v_coupon_discount_type text;
  v_coupon_discount_value int;
  v_coupon_discount_pct numeric;
  v_coupon_min_order_amount int;
  v_coupon_max_discount_amount int;
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
    into v_customer_id,
         v_customer_display_name,
         v_customer_membership_tier,
         v_customer_point_balance
    from catchmenu_store.customers
    where id = p_customer_id
      and tenant_id = p_tenant_id
      and is_active = true;
  elsif p_phone_hash is not null then
    select id, display_name,
           membership_tier, point_balance
    into v_customer_id,
         v_customer_display_name,
         v_customer_membership_tier,
         v_customer_point_balance
    from catchmenu_store.customers
    where phone_hash = p_phone_hash
      and tenant_id = p_tenant_id
      and is_active = true;
  end if;

  -- 포인트 잔액 확인
  if v_customer_id is not null
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
    where customer_id = v_customer_id
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
  elsif v_customer_id is null
    and p_use_points > 0
  then
    perform catchmenu_common.log_diagnostic(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_log_level := 'WARNING',
      p_log_domain := 'ORDER',
      p_log_event := 'points_requested_without_customer',
      p_message := '비회원 포인트 사용 요청 스킵',
      p_error_key := null,
      p_details := jsonb_build_object(
        'p_use_points', p_use_points
      ),
      p_recovery_hint := null,
      p_rpc_name := 'place_takeout_order',
      p_correlation_id := p_correlation_id,
      p_session_id := null,
      p_order_id := null,
      p_payment_id := null,
      p_exception_id := null,
      p_device_id := null,
      p_agent_id := null,
      p_caller_type := null,
      p_caller_id := null
    );
  end if;

  -- 쿠폰 유효성 확인
  if p_coupon_issue_id is not null then
    select ci.id,
           c.discount_type, c.discount_value,
           c.discount_pct,
           c.min_order_amount,
           c.max_discount_amount
    into v_coupon_id,
         v_coupon_discount_type,
         v_coupon_discount_value,
         v_coupon_discount_pct,
         v_coupon_min_order_amount,
         v_coupon_max_discount_amount
    from catchmenu_store.coupon_issues ci
    join catchmenu_store.coupons c
      on c.id = ci.coupon_id
    where ci.id = p_coupon_issue_id
      and ci.customer_id = v_customer_id
      and ci.tenant_id = p_tenant_id
      and ci.issue_status = 'ISSUED'
      and (
        ci.expires_at is null
        or ci.expires_at >= now()
      );

    if v_coupon_id is null then
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
  if v_coupon_id is not null then
    if v_total_amount
      < coalesce(v_coupon_min_order_amount, 0)
    then
      return catchmenu_common.build_error_response(
        p_error_key := 'order_amount_below_minimum',
        p_locale := p_locale,
        p_params := jsonb_build_object(
          'min_order_amount',
            v_coupon_min_order_amount
        ),
        p_tenant_id := p_tenant_id,
        p_store_id := p_store_id,
        p_rpc_name := 'place_takeout_order'
      );
    end if;

    v_coupon_discount := case v_coupon_discount_type
      when 'AMOUNT' then
        v_coupon_discount_value
      when 'PCT' then
        least(
          (v_total_amount
            * v_coupon_discount_pct / 100)::int,
          coalesce(
            v_coupon_max_discount_amount,
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
    'TAKEOUT', 'ORDER_CONFIRMED',
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
  if v_coupon_id is not null then
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
    and v_customer_id is not null
  then
    perform catchmenu_store.deduct_points(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_customer_id := v_customer_id,
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
    'CUSTOMER', v_customer_id,
    jsonb_build_object(
      'order_number', v_order_number,
      'total_amount', v_total_amount,
      'discount_amount', v_discount_amount,
      'final_amount', v_final_amount,
      'coupon_used', v_coupon_id is not null,
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
        coalesce(v_customer_display_name, '비회원'),
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
        'READY', 'COMMITTED'
      )
    ),
    'completed_count', count(*) filter (
      where kds_status in (
        'COMPLETED', 'SERVED'
      )
    ),
    'all_ready', bool_and(
      kds_status in (
        'READY', 'COMMITTED',
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


-- ===== END sql/migrations/0081_create_customer_app_rpc.sql =====


-- ===== BEGIN sql/migrations/0116_create_customer_app_bootstrap_rpc.sql =====

-- 0116_create_customer_app_bootstrap_rpc.sql
-- Purpose: Customer app bootstrap enhancement.
--          대기 연동 + 멤버십 통합 + CMS.
--          고객 앱 단일 RPC 전체 초기화.
--          QR 스캔 → 대기 등록 흐름.
--          주문 추적 실시간 연동.
--          i18n: 모든 메시지 = message_catalog 참조.
-- Depends on: 0115_create_waiting_pipeline_rpc.sql
-- Creates:
--   function catchmenu_store.bootstrap_customer_app_v2(...)
--   function catchmenu_store.get_customer_home(...)
--   function catchmenu_store.qr_scan_action(...)
--   function catchmenu_store.get_order_tracking(...)
--   function catchmenu_store.get_customer_history(...)

-- =============================================
-- i18n 메시지 등록
-- =============================================
insert into catchmenu_common.message_catalog (
  message_key, locale, message_text
) values
('customer_app_ready', 'ko',
  '앱이 준비되었습니다'),
('customer_app_ready', 'en',
  'App ready'),
('customer_app_ready', 'zh', '应用已准备好'),
('customer_app_ready', 'ja', 'アプリの準備ができました'),
('customer_app_ready', 'vi', 'Ứng dụng sẵn sàng'),
('customer_app_ready', 'th', 'แอปพร้อมแล้ว'),

('customer_home_ready', 'ko',
  '홈이 로드되었습니다'),
('customer_home_ready', 'en',
  'Home loaded'),

('qr_scan_processed', 'ko',
  'QR 스캔이 처리되었습니다'),
('qr_scan_processed', 'en',
  'QR scan processed'),

('order_tracking_loaded', 'ko',
  '주문 현황이 로드되었습니다'),
('order_tracking_loaded', 'en',
  'Order tracking loaded'),

('customer_history_loaded', 'ko',
  '주문 내역이 로드되었습니다'),
('customer_history_loaded', 'en',
  'Order history loaded'),

('qr_waiting_register', 'ko',
  'QR로 대기 등록이 완료되었습니다'),
('qr_waiting_register', 'en',
  'Waiting registered via QR'),
('qr_waiting_register', 'zh',
  '已通过QR码登记候位'),
('qr_waiting_register', 'ja',
  'QRコードで順番待ちを登録しました'),
('qr_waiting_register', 'vi',
  'Đã đăng ký chờ qua QR'),
('qr_waiting_register', 'th',
  'ลงทะเบียนรอผ่าน QR แล้ว'),

('qr_table_order', 'ko',
  '테이블 주문 모드로 전환됩니다'),
('qr_table_order', 'en',
  'Switching to table order mode'),
('qr_table_order', 'zh',
  '切换至桌台点餐模式'),
('qr_table_order', 'ja',
  'テーブル注文モードに切り替えます'),
('qr_table_order', 'vi',
  'Chuyển sang chế độ đặt bàn'),
('qr_table_order', 'th',
  'สลับไปโหมดสั่งอาหารที่โต๊ะ'),

('order_cooking', 'ko', '조리 중입니다'),
('order_cooking', 'en', 'Cooking'),
('order_cooking', 'zh', '烹饪中'),
('order_cooking', 'ja', '調理中'),
('order_cooking', 'vi', 'Đang nấu'),
('order_cooking', 'th', 'กำลังปรุง'),

('order_completed_msg', 'ko',
  '주문이 완료되었습니다'),
('order_completed_msg', 'en',
  'Order completed'),
('order_completed_msg', 'zh', '订单已完成'),
('order_completed_msg', 'ja', 'ご注文が完了しました'),
('order_completed_msg', 'vi', 'Đơn hàng hoàn thành'),
('order_completed_msg', 'th', 'คำสั่งซื้อเสร็จสิ้น')
on conflict (message_key, locale) do nothing;


-- =============================================
-- RPCs
-- =============================================
create or replace function
  catchmenu_store.bootstrap_customer_app_v2(
  p_tenant_id uuid,
  p_store_id uuid,
  p_customer_id uuid default null,
  p_phone_hash text default null,
  p_locale text default 'ko',
  p_app_version text default null,
  p_push_token text default null,
  p_os_type text default null
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
  v_store record;
  v_store_settings record;
  v_customer record;
  v_membership jsonb;
  v_active_waiting jsonb;
  v_active_order jsonb;
  v_cms_bundle jsonb;
  v_menu_preview jsonb;
  v_business_day date;
  v_day_of_week int;
  v_business_hours record;
  v_is_open boolean;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;
  v_day_of_week := extract(
    dow from v_business_day
  )::int;

  -- 매장 정보
  select id, store_name, store_type, timezone
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
      p_rpc_name := 'bootstrap_customer_app_v2'
    );
  end if;

  -- 매장 설정
  -- NOTE (§24 lightweight fix, 2026-07-11): min_order_amount was never
  -- a real column on catchmenu_store.store_settings (confirmed via
  -- \d catchmenu_store.store_settings -- no min_order_amount, no
  -- minimum_order_amount, no min_pre_order_amount equivalent). This
  -- SELECT would have failed at runtime with "column does not exist"
  -- on every call. The concept (minimum pre-order amount) was simply
  -- never implemented -- removed from this SELECT rather than mapped
  -- to a nonexistent column.
  select store_mode, waiting_enabled,
         pre_order_enabled
  into v_store_settings
  from catchmenu_store.store_settings
  where store_id = p_store_id
    and tenant_id = p_tenant_id;

  -- 영업시간 확인
  select is_open, open_time, close_time,
         last_order_time
  into v_business_hours
  from catchmenu_store.store_business_hours
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and day_of_week = v_day_of_week;

  v_is_open := case
    when coalesce(
      v_store_settings.store_mode, 'NORMAL'
    ) in ('CLOSED', 'HOLIDAY', 'EMERGENCY')
      then false
    when v_business_hours.is_open = false
      then false
    else true
  end;

  -- 고객 정보 + 멤버십
  if p_customer_id is not null then
    select id, display_name, membership_tier,
           point_balance, visit_count,
           last_visit_at, preferred_locale
    into v_customer
    from catchmenu_store.customers
    where id = p_customer_id
      and tenant_id = p_tenant_id
      and is_active = true;

    if v_customer.id is not null then
      -- 멤버십 조회
      v_membership := (
        catchmenu_store.get_customer_membership(
          p_tenant_id := p_tenant_id,
          p_store_id := p_store_id,
          p_customer_id := p_customer_id,
          p_locale := p_locale
        )
      )->'data';

      -- 현재 대기 세션 확인
      select jsonb_build_object(
        'session_id', os.id,
        'wait_number', os.wait_number,
        'session_status', os.session_status,
        'queue_position', (
          select count(*)
          from catchmenu_pos.order_sessions
          where store_id = p_store_id
            and tenant_id = p_tenant_id
            and business_day = v_business_day
            and session_status in (
              'WAITING', 'ARRIVAL_PENDING'
            )
            and wait_number < os.wait_number
        ),
        'has_pre_order',
          false,
        'pre_order_amount',
          0
      )
      into v_active_waiting
      from catchmenu_pos.order_sessions os
      where os.store_id = p_store_id
        and os.tenant_id = p_tenant_id
        and os.customer_id = p_customer_id
        and os.business_day = v_business_day
        and os.session_status in (
          'WAITING', 'ARRIVAL_PENDING', 'SEATED'
        )
      order by os.session_started_at desc
      limit 1;

      -- 현재 진행 중 주문 확인
      select jsonb_build_object(
        'order_id', o.id,
        'order_number', o.order_number,
        'order_status', o.order_status,
        'order_type', o.order_type,
        'final_amount', o.final_amount,
        'kds_status', (
          select max(kds_status)
          from catchmenu_kds.kds_tickets
          where order_id = o.id
        ),
        'is_paid', exists (
          select 1
          from catchmenu_payment.payment_ledger
          where order_id = o.id
            and ledger_status = 'APPROVED'
        )
      )
      into v_active_order
      from catchmenu_pos.orders o
      where o.store_id = p_store_id
        and o.tenant_id = p_tenant_id
        and o.business_day = v_business_day
        and o.order_status in (
          'CONFIRMED', 'COOKING',
          'READY', 'PAID'
        )
        and exists (
          select 1
          from catchmenu_pos.order_sessions os
          where os.id = o.session_id
            and os.customer_id = p_customer_id
        )
      order by o.ordered_at desc
      limit 1;

      -- 푸시 토큰 업데이트
      if p_push_token is not null then
        update catchmenu_store.customers
        set
          preferred_locale = p_locale,
          updated_at = now()
        where id = p_customer_id;
      end if;
    end if;
  end if;

  -- CMS 번들 (이벤트/배너/팝업)
  v_cms_bundle :=
    catchmenu_store.get_cms_display_bundle(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_display_target := 'CUSTOMER_APP',
      p_trigger_event := 'APP_OPEN',
      p_locale := p_locale
    );

  -- 메뉴 미리보기 (인기 5개)
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'menu_id', m.id,
        'menu_name', case p_locale
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
        'thumbnail_url', m.image_url,
        'menu_status', m.menu_status
      )
      order by m.display_order asc
    ),
    '[]'::jsonb
  )
  into v_menu_preview
  from catchmenu_pos.menus m
  where m.store_id = p_store_id
    and m.tenant_id = p_tenant_id
    and m.is_active = true
    and m.menu_status = 'AVAILABLE'
  limit 5;

  return catchmenu_common.build_success_response(
    p_message_key := 'customer_app_ready',
    p_data := jsonb_build_object(

      -- 매장
      'store', jsonb_build_object(
        'id', v_store.id,
        'store_name', v_store.store_name,
        'store_type', v_store.store_type,
        'is_open', v_is_open,
        'store_mode', coalesce(
          v_store_settings.store_mode, 'NORMAL'
        ),
        'waiting_enabled', coalesce(
          v_store_settings.waiting_enabled, true
        ),
        -- NOTE (§24 lightweight fix, 2026-07-11): min_order_amount was
        -- never implemented on store_settings (see the SELECT above);
        -- hardcoded to 0 rather than referencing a nonexistent field on
        -- v_store_settings, which would itself fail since the record
        -- only carries the columns actually selected into it.
        'min_order_amount', 0,
        'business_hours', case
          when v_business_hours.open_time
            is not null
          then jsonb_build_object(
            'open_time',
              v_business_hours.open_time,
            'close_time',
              v_business_hours.close_time,
            'last_order_time',
              v_business_hours.last_order_time
          )
          else null
        end
      ),

      -- 고객
      'customer', case
        when v_customer.id is not null
        then jsonb_build_object(
          'id', v_customer.id,
          'display_name', v_customer.display_name,
          'membership_tier',
            v_customer.membership_tier,
          'total_points', v_customer.point_balance,
          'visit_count', v_customer.visit_count
        )
        else null
      end,

      -- 멤버십
      'membership', v_membership,

      -- 현재 대기
      'active_waiting', v_active_waiting,
      'has_active_waiting',
        v_active_waiting is not null,

      -- 진행 중 주문
      'active_order', v_active_order,
      'has_active_order',
        v_active_order is not null,

      -- CMS
      'cms', v_cms_bundle->'data',

      -- 메뉴 미리보기
      'menu_preview', v_menu_preview,

      -- Realtime 채널
      'realtime_channel',
        'customer_app:' || p_store_id,

      'business_day', v_business_day,
      'bootstrapped_at', now()
    ),
    p_locale := p_locale
  );
end;
$$;


create or replace function
  catchmenu_store.qr_scan_action(
  p_tenant_id uuid,
  p_store_id uuid,
  p_qr_type text,
  p_qr_data text,
  p_customer_id uuid default null,
  p_guest_count int default 1,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_store,
                  catchmenu_pos,
                  catchmenu_common
as $$
declare
  v_result jsonb;
  v_table_number text;
  v_kiosk_id uuid;
begin
  case p_qr_type

    -- 대기 QR 스캔 → 대기 등록
    when 'WAITING_REGISTER' then
      v_result := catchmenu_pos.register_waiting(
        p_tenant_id := p_tenant_id,
        p_store_id := p_store_id,
        p_guest_count := p_guest_count,
        p_session_type := 'WAITING',
        p_guest_locale := p_locale,
        p_customer_id := p_customer_id,
        p_source := 'QR',
        p_locale := p_locale,
        p_correlation_id := p_correlation_id
      );

      return catchmenu_common
        .build_success_response(
        p_message_key := 'qr_waiting_register',
        p_data := jsonb_build_object(
          'qr_type', p_qr_type,
          'action_result', v_result->'data'
        ),
        p_locale := p_locale,
        p_correlation_id := p_correlation_id
      );

    -- 테이블 QR 스캔 → 테이블 주문 모드
    when 'TABLE_ORDER' then
      v_table_number := p_qr_data;

      return catchmenu_common
        .build_success_response(
        p_message_key := 'qr_table_order',
        p_data := jsonb_build_object(
          'qr_type', p_qr_type,
          'table_number', v_table_number,
          'action', 'SWITCH_TO_TABLE_ORDER',
          'next_screen', 'MENU_CATALOG',
          'order_type', 'TABLE'
        ),
        p_locale := p_locale,
        p_correlation_id := p_correlation_id
      );

    -- 키오스크 QR → 키오스크 세션 연결
    when 'KIOSK_SESSION' then
      v_kiosk_id := p_qr_data::uuid;

      return catchmenu_common
        .build_success_response(
        p_message_key := 'qr_scan_processed',
        p_data := jsonb_build_object(
          'qr_type', p_qr_type,
          'kiosk_id', v_kiosk_id,
          'action', 'LINK_KIOSK_SESSION',
          'next_screen', 'KIOSK_MENU'
        ),
        p_locale := p_locale,
        p_correlation_id := p_correlation_id
      );

    else
      return catchmenu_common.build_error_response(
        p_error_key := 'invalid_input',
        p_locale := p_locale,
        p_params := jsonb_build_object(
          'field', 'qr_type',
          'value', p_qr_type
        ),
        p_tenant_id := p_tenant_id,
        p_store_id := p_store_id,
        p_rpc_name := 'qr_scan_action'
      );
  end case;
end;
$$;


create or replace function
  catchmenu_store.get_order_tracking(
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
  v_kds_tickets jsonb;
  v_payment record;
  v_tracking_status text;
  v_tracking_message text;
begin
  select id, order_number, order_status,
         order_type, order_source,
         final_amount, ordered_at,
         paid_at, session_id
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
      p_rpc_name := 'get_order_tracking'
    );
  end if;

  -- KDS 티켓 상태
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'ticket_id', id,
        'menu_name', menu_name_snapshot,
        'quantity', quantity_snapshot,
        'kds_status', kds_status,
        'kitchen_zone', kitchen_zone,
        'is_late', is_late,
        'committed_at', committed_at,
        'cooking_started_at',
          cooking_started_at,
        'served_at', served_at
      )
      order by ticket_created_at asc
    ),
    '[]'::jsonb
  )
  into v_kds_tickets
  from catchmenu_kds.kds_tickets
  where order_id = p_order_id
    and store_id = p_store_id;

  -- 결제 정보
  select id, ledger_status, approved_amount,
         approved_at, payment_method
  into v_payment
  from catchmenu_payment.payment_ledger
  where order_id = p_order_id
    and ledger_status = 'APPROVED'
  order by approved_at desc
  limit 1;

  -- 추적 상태 + 메시지
  v_tracking_status := case
    when v_payment.id is null
      then 'WAITING_PAYMENT'
    when v_order.order_status = 'READY'
      then 'READY'
    when exists (
      select 1 from catchmenu_kds.kds_tickets
      where order_id = p_order_id
        and kds_status = 'COOKING'
    ) then 'COOKING'
    when exists (
      select 1 from catchmenu_kds.kds_tickets
      where order_id = p_order_id
        and kds_status = 'COMMITTED'
    ) then 'CONFIRMED'
    when v_order.order_status = 'COMPLETED'
      then 'COMPLETED'
    else 'PROCESSING'
  end;

  v_tracking_message :=
    catchmenu_common.get_message(
      case v_tracking_status
        when 'COOKING'
          then 'order_cooking'
        when 'READY'
          then 'order_ready'
        when 'COMPLETED'
          then 'order_completed_msg'
        else 'order_confirmed'
      end,
      p_locale,
      jsonb_build_object(
        'order_number', v_order.order_number
      )
    );

  return catchmenu_common.build_success_response(
    p_message_key := 'order_tracking_loaded',
    p_data := jsonb_build_object(
      'order_id', p_order_id,
      'order_number', v_order.order_number,
      'order_type', v_order.order_type,
      'order_source', v_order.order_source,
      'tracking_status', v_tracking_status,
      'tracking_message', v_tracking_message,
      'is_paid', v_payment.id is not null,
      'payment', case
        when v_payment.id is not null
        then jsonb_build_object(
          'amount', v_payment.approved_amount,
          'method', v_payment.payment_method,
          'approved_at', v_payment.approved_at
        )
        else null
      end,
      'kds_tickets', v_kds_tickets,
      'final_amount', v_order.final_amount,
      'ordered_at', v_order.ordered_at,
      'paid_at', v_order.paid_at,
      'realtime_channel',
        'customer_app:' || p_store_id
    ),
    p_locale := p_locale
  );
end;
$$;


create or replace function
  catchmenu_store.get_customer_history(
  p_tenant_id uuid,
  p_store_id uuid,
  p_customer_id uuid,
  p_limit int default 20,
  p_offset int default 0,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_store,
                  catchmenu_pos,
                  catchmenu_payment,
                  catchmenu_common
as $$
declare
  v_orders jsonb;
  v_total_count int;
  v_total_spent int;
begin
  select count(*) into v_total_count
  from catchmenu_pos.orders o
  where o.store_id = p_store_id
    and o.tenant_id = p_tenant_id
    and exists (
      select 1
      from catchmenu_pos.order_sessions os
      where os.id = o.session_id
        and os.customer_id = p_customer_id
    )
    and o.order_status in (
      'COMPLETED', 'CANCELLED'
    );

  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'order_id', o.id,
        'order_number', o.order_number,
        'order_type', o.order_type,
        'order_status', o.order_status,
        'final_amount', o.final_amount,
        'ordered_at', o.ordered_at,
        'items', (
          select coalesce(
            jsonb_agg(
              jsonb_build_object(
                'menu_name',
                  oi.menu_name_snapshot,
                'quantity', oi.quantity,
                'subtotal', oi.subtotal
              )
            ),
            '[]'::jsonb
          )
          from catchmenu_pos.order_items oi
          where oi.order_id = o.id
        ),
        'payment_method', (
          select payment_method
          from catchmenu_payment.payment_ledger
          where order_id = o.id
            and ledger_status = 'APPROVED'
          limit 1
        ),
        'earned_points', coalesce(
          (
            select points
            from catchmenu_store.point_ledger
            where order_id = o.id
              and point_type = 'EARN'
              and customer_id = p_customer_id
            limit 1
          ), 0
        )
      )
      order by o.ordered_at desc
    ),
    '[]'::jsonb
  )
  into v_orders
  from catchmenu_pos.orders o
  where o.store_id = p_store_id
    and o.tenant_id = p_tenant_id
    and exists (
      select 1
      from catchmenu_pos.order_sessions os
      where os.id = o.session_id
        and os.customer_id = p_customer_id
    )
    and o.order_status in (
      'COMPLETED', 'CANCELLED'
    )
  order by o.ordered_at desc
  limit p_limit
  offset p_offset;

  -- 총 사용 금액
  select coalesce(sum(o.final_amount), 0)
  into v_total_spent
  from catchmenu_pos.orders o
  where o.store_id = p_store_id
    and o.tenant_id = p_tenant_id
    and o.order_status = 'COMPLETED'
    and exists (
      select 1
      from catchmenu_pos.order_sessions os
      where os.id = o.session_id
        and os.customer_id = p_customer_id
    );

  return catchmenu_common.build_success_response(
    p_message_key := 'customer_history_loaded',
    p_data := jsonb_build_object(
      'orders', v_orders,
      'total_count', v_total_count,
      'page_count',
        jsonb_array_length(v_orders),
      'total_spent', v_total_spent,
      'limit', p_limit,
      'offset', p_offset
    ),
    p_locale := p_locale
  );
end;
$$;


-- 0081's original get_customer_home used a different parameter
-- order/defaults (p_customer_id before p_store_id, p_store_id
-- optional). This file supersedes it with a more complete, dedicated
-- implementation; no already-applied code depends on the old
-- signature, so the old function is dropped first.
drop function if exists catchmenu_store.get_customer_home(
  uuid, uuid, uuid, text
);

create or replace function
  catchmenu_store.get_customer_home(
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
                  catchmenu_pos,
                  catchmenu_common
as $$
declare
  v_customer record;
  v_active_waiting jsonb;
  v_active_order jsonb;
  v_stamp_card jsonb;
  v_available_coupons jsonb;
  v_cms_bundle jsonb;
  v_business_day date;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  select id, display_name, membership_tier,
         point_balance
  into v_customer
  from catchmenu_store.customers
  where id = p_customer_id
    and tenant_id = p_tenant_id
    and is_active = true;

  -- 현재 대기 세션
  select jsonb_build_object(
    'session_id', os.id,
    'wait_number', os.wait_number,
    'session_status', os.session_status,
    'has_pre_order',
      os.pre_order_amount > 0,
    'queue_position', (
      select count(*)
      from catchmenu_pos.order_sessions w
      where w.store_id = p_store_id
        and w.tenant_id = p_tenant_id
        and w.business_day = v_business_day
        and w.session_status in (
          'WAITING', 'ARRIVAL_PENDING'
        )
        and w.wait_number < os.wait_number
    )
  )
  into v_active_waiting
  from catchmenu_pos.order_sessions os
  where os.store_id = p_store_id
    and os.tenant_id = p_tenant_id
    and os.customer_id = p_customer_id
    and os.business_day = v_business_day
    and os.session_status in (
      'WAITING', 'ARRIVAL_PENDING', 'SEATED'
    )
  order by os.session_started_at desc
  limit 1;

  -- 진행 중 주문
  select jsonb_build_object(
    'order_id', o.id,
    'order_number', o.order_number,
    'order_status', o.order_status,
    'final_amount', o.final_amount
  )
  into v_active_order
  from catchmenu_pos.orders o
  join catchmenu_pos.order_sessions os
    on os.id = o.session_id
    and os.customer_id = p_customer_id
  where o.store_id = p_store_id
    and o.tenant_id = p_tenant_id
    and o.business_day = v_business_day
    and o.order_status in (
      'CONFIRMED', 'COOKING', 'READY'
    )
  order by o.ordered_at desc
  limit 1;

  -- 스탬프 카드
  select jsonb_build_object(
    'current_stamps', current_stamps,
    'stamp_goal', stamp_goal,
    'remaining_stamps',
      greatest(0, stamp_goal - current_stamps)
  )
  into v_stamp_card
  from catchmenu_store.stamp_cards
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and customer_id = p_customer_id
    and card_status = 'ACTIVE';

  -- 사용 가능 쿠폰
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'coupon_issue_id', ci.id,
        'coupon_name', c.coupon_name,
        'discount_type', c.discount_type,
        'discount_value', c.discount_value,
        'valid_until', ci.valid_until
      )
      order by ci.valid_until asc
    ),
    '[]'::jsonb
  )
  into v_available_coupons
  from catchmenu_store.coupon_issues ci
  join catchmenu_store.coupons c
    on c.id = ci.coupon_id
  where ci.store_id = p_store_id
    and ci.tenant_id = p_tenant_id
    and ci.customer_id = p_customer_id
    and ci.is_used = false
    and ci.valid_until > now()
  limit 5;

  -- CMS 번들
  v_cms_bundle :=
    catchmenu_store.get_cms_display_bundle(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_display_target := 'CUSTOMER_APP',
      p_trigger_event := 'APP_OPEN',
      p_locale := p_locale
    );

  return catchmenu_common.build_success_response(
    p_message_key := 'customer_home_ready',
    p_data := jsonb_build_object(
      'customer', jsonb_build_object(
        'id', v_customer.id,
        'display_name', v_customer.display_name,
        'membership_tier',
          v_customer.membership_tier,
        'total_points', v_customer.point_balance
      ),
      'active_waiting', v_active_waiting,
      'has_active_waiting',
        v_active_waiting is not null,
      'active_order', v_active_order,
      'has_active_order',
        v_active_order is not null,
      'stamp_card', v_stamp_card,
      'available_coupons', v_available_coupons,
      'coupon_count',
        jsonb_array_length(
          coalesce(
            v_available_coupons, '[]'::jsonb
          )
        ),
      'cms', v_cms_bundle->'data',
      'business_day', v_business_day,
      'loaded_at', now()
    ),
    p_locale := p_locale
  );
end;
$$;


-- grants
do $$
begin
  grant execute on function
    catchmenu_store.bootstrap_customer_app_v2(
      uuid, uuid, uuid, text, text, text, text, text
    ) to authenticated;

  grant execute on function
    catchmenu_store.qr_scan_action(
      uuid, uuid, text, text, uuid, int, text, text
    ) to authenticated;

  grant execute on function
    catchmenu_store.get_order_tracking(
      uuid, uuid, uuid, text
    ) to authenticated;

  grant execute on function
    catchmenu_store.get_customer_history(
      uuid, uuid, uuid, int, int, text
    ) to authenticated;

  grant execute on function
    catchmenu_store.get_customer_home(
      uuid, uuid, uuid, text
    ) to authenticated;
end;
$$;

comment on function
  catchmenu_store.bootstrap_customer_app_v2(
    uuid, uuid, uuid, text, text, text, text, text
  ) is
  '고객 앱 부트스트랩 v2.
   단일 RPC 전체 초기화.

   반환 데이터:
   - 매장 정보 + 영업 여부
   - 고객 정보 + 멤버십
   - 현재 대기 세션 (있으면)
   - 진행 중 주문 (있으면)
   - CMS 이벤트/배너/팝업
   - 메뉴 미리보기 5개
   - Realtime 채널

   특허1 연동:
   active_waiting → 대기 현황 즉시 표시
   has_pre_order → 사전 주문 여부

   Flutter 앱 시작 흐름:
   1. bootstrap_customer_app_v2()
   2. has_active_waiting → 대기 화면
   3. has_active_order → 주문 추적
   4. cms popups → 팝업 표시
   5. Realtime 구독';

comment on function
  catchmenu_store.qr_scan_action(
    uuid, uuid, text, text, uuid, int, text, text
  ) is
  'QR 스캔 액션 라우터.
   QR 타입별 자동 처리.

   WAITING_REGISTER:
     register_waiting() 자동 호출
     → 대기 등록 완료
   TABLE_ORDER:
     table_number 반환
     → 테이블 주문 모드 전환
   KIOSK_SESSION:
     kiosk_id 반환
     → 키오스크 세션 연결

   Flutter QR 스캔:
   camera 패키지 → qr_code_scanner
   → qr_scan_action() 호출
   → next_screen 기반 라우팅.';


-- ===== END sql/migrations/0116_create_customer_app_bootstrap_rpc.sql =====


-- ===== BEGIN sql/migrations/0149_create_guest_customer_bootstrap_rpc.sql =====

-- 0149_create_guest_customer_bootstrap_rpc.sql
-- Purpose: Create the guest customer bootstrap helper and patch the two
--          existing customer-entry RPCs so omitted p_customer_id values are
--          filled through catchmenu_store.get_or_create_guest_customer().
-- Depends on: 0148_add_order_sessions_customer_id_and_guest_flag.sql
-- Creates:
--   catchmenu_store.get_or_create_guest_customer(uuid, text)
-- Patches via CREATE OR REPLACE FUNCTION:
--   catchmenu_pos.register_waiting(...)
--   catchmenu_store.bootstrap_customer_app_v2(...)
--
-- Human Boundary Approval: 600124_ChangeContract.md approved Stage 4.
-- Design source: 600122_Logic.md. The helper keeps is_guest out of the
-- ON CONFLICT DO UPDATE SET clause so an already-promoted customer is not
-- reverted to guest status by a later same-phone_hash guest bootstrap call.
-- Direct helper grants are intentionally not given to authenticated; callers
-- reach it only through the patched 0115/0116 SECURITY DEFINER RPCs.

create or replace function catchmenu_store.get_or_create_guest_customer(
  p_tenant_id uuid,
  p_phone_hash text default null
)
returns uuid
language plpgsql
volatile
security definer
set search_path = catchmenu_store
as $$
declare
  v_customer_id uuid;
  v_customer_code text;
begin
  -- customer_code 생성: 0058 register_customer()의 패턴 재사용
  v_customer_code := 'C' || to_char(now(), 'YYMMDD')
    || lpad(
      (
        select coalesce(count(*), 0) + 1
        from catchmenu_store.customers
        where tenant_id = p_tenant_id
      )::text,
      6, '0'
    );

  if p_phone_hash is not null then
    insert into catchmenu_store.customers (
      tenant_id, customer_code,
      phone_hash, is_guest,
      preferred_locale, is_active,
      first_visit_at, last_visit_at
    ) values (
      p_tenant_id, v_customer_code,
      p_phone_hash, true,
      'ko', true,
      now(), now()
    )
    on conflict (tenant_id, phone_hash)
    do update set updated_at = now()
    returning id into v_customer_id;
  else
    -- phone_hash 없는 완전 익명: 매번 신규 row (Human 결정 #4)
    insert into catchmenu_store.customers (
      tenant_id, customer_code,
      is_guest,
      preferred_locale, is_active,
      first_visit_at, last_visit_at
    ) values (
      p_tenant_id, v_customer_code,
      true,
      'ko', true,
      now(), now()
    )
    returning id into v_customer_id;
  end if;

  return v_customer_id;
end;
$$;

create or replace function
  catchmenu_pos.register_waiting(
  p_tenant_id uuid,
  p_store_id uuid,
  p_guest_count int,
  p_session_type text default 'WAITING',
  p_guest_locale text default 'ko',
  p_phone_hash text default null,
  p_customer_id uuid default null,
  p_memo text default null,
  p_source text default 'STAFF',
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_pos,
                  catchmenu_store,
                  catchmenu_common,
                  catchmenu_ledger,
                  catchmenu_hq
as $$
declare
  v_settings record;
  v_wait_number int;
  v_queue_position int;
  v_session_id uuid;
  v_est_wait_minutes int;
  v_business_day date;
  v_timezone text;
begin
  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  -- 매장 설정 확인
  select store_mode, waiting_enabled,
         max_wait_number
  into v_settings
  from catchmenu_store.store_settings
  where store_id = p_store_id
    and tenant_id = p_tenant_id;

  -- 대기 비활성화 확인
  if coalesce(v_settings.store_mode, 'NORMAL')
    in ('CLOSED', 'HOLIDAY', 'EMERGENCY')
    or not coalesce(
      v_settings.waiting_enabled, true
    )
  then
    return catchmenu_common.build_error_response(
      p_error_key := 'waiting_queue_disabled',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'register_waiting'
    );
  end if;

  -- 현재 대기 인원 확인
  select count(*) into v_queue_position
  from catchmenu_pos.order_sessions
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_business_day
    and session_status in (
      'WAITING', 'ARRIVAL_PENDING'
    )
    and session_type in (
      'WAITING', 'PRE_ORDER'
    );

  -- 대기 정원 초과
  if v_queue_position >=
    coalesce(v_settings.max_wait_number, 30)
  then
    return catchmenu_common.build_error_response(
      p_error_key := 'wait_queue_full',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'register_waiting'
    );
  end if;

  -- 오늘 대기 번호 채번
  select coalesce(
    max(wait_number), 0
  ) + 1
  into v_wait_number
  from catchmenu_pos.order_sessions
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_business_day;

  -- p_customer_id가 없으면 게스트 헬퍼로 채운다 (600120 patch)
  if p_customer_id is null then
    p_customer_id := catchmenu_store.get_or_create_guest_customer(
      p_tenant_id := p_tenant_id,
      p_phone_hash := p_phone_hash
    );
  end if;

  -- 대기 세션 생성 (특허1 핵심)
  insert into catchmenu_pos.order_sessions (
    tenant_id, store_id,
    session_type, session_status,
    wait_number, queue_position,
    guest_count, guest_locale,
    phone_hash, customer_id,
    session_started_at,
    business_day, business_timezone
  ) values (
    p_tenant_id, p_store_id,
    p_session_type, 'WAITING',
    v_wait_number, v_queue_position + 1,
    p_guest_count, p_guest_locale,
    p_phone_hash, p_customer_id,
    now(),
    v_business_day, v_timezone
  )
  returning id into v_session_id;

  -- 예상 대기 시간 계산
  v_est_wait_minutes :=
    v_queue_position * 10;

  -- Realtime → 대기 화면 + DID 업데이트
  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_channel_type := 'WAITING_QUEUE',
    p_event_type := 'waiting_session_created',
    p_payload := jsonb_build_object(
      'session_id', v_session_id,
      'wait_number', v_wait_number,
      'queue_position', v_queue_position + 1,
      'guest_count', p_guest_count,
      'guest_locale', p_guest_locale,
      'est_wait_minutes', v_est_wait_minutes,
      'source', p_source
    )
  );

  -- 고객 앱 푸시 알림 (전화번호 있는 경우)
  if p_phone_hash is not null then
    perform catchmenu_common.notify_channel(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_channel_type := 'SYSTEM_EVENTS',
      p_event_type := 'push_notification_queued',
      p_payload := jsonb_build_object(
        'phone_hash', p_phone_hash,
        'customer_id', p_customer_id,
        'notification_type', 'WAITING_REGISTERED',
        'wait_number', v_wait_number,
        'queue_position', v_queue_position + 1,
        'locale', p_guest_locale
      )
    );
  end if;

  -- ledger event (특허1)
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
    'waiting', 'waiting_registered', 1,
    'order_session', v_session_id,
    null, 'WAITING',
    p_source,
    jsonb_build_object(
      'wait_number', v_wait_number,
      'queue_position', v_queue_position + 1,
      'guest_count', p_guest_count,
      'session_type', p_session_type,
      'source', p_source
    ),
    p_correlation_id,
    v_business_day, v_timezone, now()
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'waiting_registered',
    p_data := jsonb_build_object(
      'session_id', v_session_id,
      'wait_number', v_wait_number,
      'queue_position', v_queue_position + 1,
      'guest_count', p_guest_count,
      'guest_locale', p_guest_locale,
      'est_wait_minutes', v_est_wait_minutes,
      'pre_order_enabled',
        p_session_type = 'PRE_ORDER',
      'position_message',
        catchmenu_common.get_message(
          'waiting_current_position',
          p_guest_locale,
          jsonb_build_object(
            'position', v_queue_position + 1
          )
        ),
      'est_time_message',
        catchmenu_common.get_message(
          'waiting_est_time',
          p_guest_locale,
          jsonb_build_object(
            'minutes', v_est_wait_minutes
          )
        ),
      'registered_message',
        catchmenu_common.get_message(
          'waiting_registered',
          p_guest_locale,
          jsonb_build_object(
            'wait_number', v_wait_number
          )
        )
    ),
    p_locale := p_locale,
    p_params := jsonb_build_object(
      'wait_number', v_wait_number
    ),
    p_correlation_id := p_correlation_id
  );
end;
$$;

create or replace function
  catchmenu_store.bootstrap_customer_app_v2(
  p_tenant_id uuid,
  p_store_id uuid,
  p_customer_id uuid default null,
  p_phone_hash text default null,
  p_locale text default 'ko',
  p_app_version text default null,
  p_push_token text default null,
  p_os_type text default null
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
  v_store record;
  v_store_settings record;
  v_customer record;
  v_membership jsonb;
  v_active_waiting jsonb;
  v_active_order jsonb;
  v_cms_bundle jsonb;
  v_menu_preview jsonb;
  v_business_day date;
  v_day_of_week int;
  v_business_hours record;
  v_is_open boolean;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;
  v_day_of_week := extract(
    dow from v_business_day
  )::int;

  -- 매장 정보
  select id, store_name, store_type, timezone
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
      p_rpc_name := 'bootstrap_customer_app_v2'
    );
  end if;

  -- 매장 설정
  -- NOTE (§24 lightweight fix, 2026-07-11): min_order_amount was never
  -- a real column on catchmenu_store.store_settings (confirmed via
  -- \d catchmenu_store.store_settings -- no min_order_amount, no
  -- minimum_order_amount, no min_pre_order_amount equivalent). This
  -- SELECT would have failed at runtime with "column does not exist"
  -- on every call. The concept (minimum pre-order amount) was simply
  -- never implemented -- removed from this SELECT rather than mapped
  -- to a nonexistent column.
  select store_mode, waiting_enabled,
         pre_order_enabled
  into v_store_settings
  from catchmenu_store.store_settings
  where store_id = p_store_id
    and tenant_id = p_tenant_id;

  -- 영업시간 확인
  select is_open, open_time, close_time,
         last_order_time
  into v_business_hours
  from catchmenu_store.store_business_hours
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and day_of_week = v_day_of_week;

  v_is_open := case
    when coalesce(
      v_store_settings.store_mode, 'NORMAL'
    ) in ('CLOSED', 'HOLIDAY', 'EMERGENCY')
      then false
    when v_business_hours.is_open = false
      then false
    else true
  end;

  -- p_customer_id가 없으면 게스트 헬퍼로 채운다 (600120 patch)
  if p_customer_id is null then
    p_customer_id := catchmenu_store.get_or_create_guest_customer(
      p_tenant_id := p_tenant_id,
      p_phone_hash := p_phone_hash
    );
  end if;

  -- 고객 정보 + 멤버십
  if p_customer_id is not null then
    select id, display_name, membership_tier,
           point_balance, visit_count,
           last_visit_at, preferred_locale
    into v_customer
    from catchmenu_store.customers
    where id = p_customer_id
      and tenant_id = p_tenant_id
      and is_active = true;

    if v_customer.id is not null then
      -- 멤버십 조회
      v_membership := (
        catchmenu_store.get_customer_membership(
          p_tenant_id := p_tenant_id,
          p_store_id := p_store_id,
          p_customer_id := p_customer_id,
          p_locale := p_locale
        )
      )->'data';

      -- 현재 대기 세션 확인
      select jsonb_build_object(
        'session_id', os.id,
        'wait_number', os.wait_number,
        'session_status', os.session_status,
        'queue_position', (
          select count(*)
          from catchmenu_pos.order_sessions
          where store_id = p_store_id
            and tenant_id = p_tenant_id
            and business_day = v_business_day
            and session_status in (
              'WAITING', 'ARRIVAL_PENDING'
            )
            and wait_number < os.wait_number
        ),
        'has_pre_order',
          false,
        'pre_order_amount',
          0
      )
      into v_active_waiting
      from catchmenu_pos.order_sessions os
      where os.store_id = p_store_id
        and os.tenant_id = p_tenant_id
        and os.customer_id = p_customer_id
        and os.business_day = v_business_day
        and os.session_status in (
          'WAITING', 'ARRIVAL_PENDING', 'SEATED'
        )
      order by os.session_started_at desc
      limit 1;

      -- 현재 진행 중 주문 확인
      select jsonb_build_object(
        'order_id', o.id,
        'order_number', o.order_number,
        'order_status', o.order_status,
        'order_type', o.order_type,
        'final_amount', o.final_amount,
        'kds_status', (
          select max(kds_status)
          from catchmenu_kds.kds_tickets
          where order_id = o.id
        ),
        'is_paid', exists (
          select 1
          from catchmenu_payment.payment_ledger
          where order_id = o.id
            and ledger_status = 'APPROVED'
        )
      )
      into v_active_order
      from catchmenu_pos.orders o
      where o.store_id = p_store_id
        and o.tenant_id = p_tenant_id
        and o.business_day = v_business_day
        and o.order_status in (
          'CONFIRMED', 'COOKING',
          'READY', 'PAID'
        )
        and exists (
          select 1
          from catchmenu_pos.order_sessions os
          where os.id = o.session_id
            and os.customer_id = p_customer_id
        )
      order by o.ordered_at desc
      limit 1;

      -- 푸시 토큰 업데이트
      if p_push_token is not null then
        update catchmenu_store.customers
        set
          preferred_locale = p_locale,
          updated_at = now()
        where id = p_customer_id;
      end if;
    end if;
  end if;

  -- CMS 번들 (이벤트/배너/팝업)
  v_cms_bundle :=
    catchmenu_store.get_cms_display_bundle(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_display_target := 'CUSTOMER_APP',
      p_trigger_event := 'APP_OPEN',
      p_locale := p_locale
    );

  -- 메뉴 미리보기 (인기 5개)
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'menu_id', m.id,
        'menu_name', case p_locale
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
        'thumbnail_url', m.image_url,
        'menu_status', m.menu_status
      )
      order by m.display_order asc
    ),
    '[]'::jsonb
  )
  into v_menu_preview
  from catchmenu_pos.menus m
  where m.store_id = p_store_id
    and m.tenant_id = p_tenant_id
    and m.is_active = true
    and m.menu_status = 'AVAILABLE'
  limit 5;

  return catchmenu_common.build_success_response(
    p_message_key := 'customer_app_ready',
    p_data := jsonb_build_object(

      -- 매장
      'store', jsonb_build_object(
        'id', v_store.id,
        'store_name', v_store.store_name,
        'store_type', v_store.store_type,
        'is_open', v_is_open,
        'store_mode', coalesce(
          v_store_settings.store_mode, 'NORMAL'
        ),
        'waiting_enabled', coalesce(
          v_store_settings.waiting_enabled, true
        ),
        -- NOTE (§24 lightweight fix, 2026-07-11): min_order_amount was
        -- never implemented on store_settings (see the SELECT above);
        -- hardcoded to 0 rather than referencing a nonexistent field on
        -- v_store_settings, which would itself fail since the record
        -- only carries the columns actually selected into it.
        'min_order_amount', 0,
        'business_hours', case
          when v_business_hours.open_time
            is not null
          then jsonb_build_object(
            'open_time',
              v_business_hours.open_time,
            'close_time',
              v_business_hours.close_time,
            'last_order_time',
              v_business_hours.last_order_time
          )
          else null
        end
      ),

      -- 고객
      'customer', case
        when v_customer.id is not null
        then jsonb_build_object(
          'id', v_customer.id,
          'display_name', v_customer.display_name,
          'membership_tier',
            v_customer.membership_tier,
          'total_points', v_customer.point_balance,
          'visit_count', v_customer.visit_count
        )
        else null
      end,

      -- 멤버십
      'membership', v_membership,

      -- 현재 대기
      'active_waiting', v_active_waiting,
      'has_active_waiting',
        v_active_waiting is not null,

      -- 진행 중 주문
      'active_order', v_active_order,
      'has_active_order',
        v_active_order is not null,

      -- CMS
      'cms', v_cms_bundle->'data',

      -- 메뉴 미리보기
      'menu_preview', v_menu_preview,

      -- Realtime 채널
      'realtime_channel',
        'customer_app:' || p_store_id,

      'business_day', v_business_day,
      'bootstrapped_at', now()
    ),
    p_locale := p_locale
  );
end;
$$;

revoke all on function catchmenu_store.get_or_create_guest_customer(uuid, text) from public;
revoke all on function catchmenu_store.get_or_create_guest_customer(uuid, text) from authenticated;

-- Preserve existing RPC execute grants for the patched public entry points.
grant execute on function catchmenu_pos.register_waiting(
  uuid, uuid, int, text, text, text, uuid, text, text, text, text
) to authenticated;

grant execute on function catchmenu_store.bootstrap_customer_app_v2(
  uuid, uuid, uuid, text, text, text, text, text
) to authenticated;


-- ===== END sql/migrations/0149_create_guest_customer_bootstrap_rpc.sql =====
