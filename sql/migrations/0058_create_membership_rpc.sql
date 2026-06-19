-- 0058_create_membership_rpc.sql
-- Purpose: Customer membership and coupon management RPCs.
--          register_customer: registers customer with membership.
--          issue_coupon: issues coupon to customer.
--          redeem_coupon: redeems coupon at order time.
--          get_customer_profile: returns membership and coupon status.
--          특허1: 고객 세션 ↔ 멤버십 연동 + 쿠폰 감사 증빙.
-- Depends on: 0057_create_delivery_platform_rpc.sql
-- Creates:
--   catchmenu_store.customers (table)
--   catchmenu_store.coupons (table)
--   catchmenu_store.coupon_issues (table)
--   function catchmenu_store.register_customer(...)
--   function catchmenu_store.issue_coupon(...)
--   function catchmenu_store.redeem_coupon(...)
--   function catchmenu_store.get_customer_profile(...)

-- =============================================
-- customers table
-- =============================================
create table if not exists catchmenu_store.customers (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid,

  -- identity
  customer_code text not null,
  display_name text,
  phone_masked text,
  phone_hash text,
  email_masked text,
  email_hash text,
  preferred_locale text not null default 'ko',

  -- membership
  membership_tier text not null default 'STANDARD',
  membership_status text not null default 'ACTIVE',
  point_balance int not null default 0,
  lifetime_spend int not null default 0,
  visit_count int not null default 0,
  last_visit_at timestamptz,
  first_visit_at timestamptz,

  -- preferences
  allergen_profile jsonb default '{}'::jsonb,
  preferred_options jsonb default '{}'::jsonb,

  -- metadata
  acquisition_channel text,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint uq_customer_code unique (
    tenant_id, customer_code
  ),
  constraint uq_customer_phone unique (
    tenant_id, phone_hash
  ),
  constraint chk_membership_tier check (
    membership_tier in (
      'STANDARD', 'SILVER', 'GOLD',
      'VIP', 'BLACKLIST'
    )
  ),
  constraint chk_membership_status check (
    membership_status in (
      'ACTIVE', 'SUSPENDED', 'WITHDRAWN'
    )
  ),
  constraint chk_point_balance check (
    point_balance >= 0
  )
);

create index if not exists idx_customers_tenant
  on catchmenu_store.customers(tenant_id);
create index if not exists idx_customers_phone
  on catchmenu_store.customers(tenant_id, phone_hash)
  where phone_hash is not null;
create index if not exists idx_customers_tier
  on catchmenu_store.customers(
    tenant_id, membership_tier
  ) where is_active = true;

alter table catchmenu_store.customers
  enable row level security;
alter table catchmenu_store.customers
  force row level security;

drop policy if exists customers_isolation
  on catchmenu_store.customers;
create policy customers_isolation
  on catchmenu_store.customers
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
  );

drop trigger if exists trg_customers_updated_at
  on catchmenu_store.customers;
create trigger trg_customers_updated_at
  before update on catchmenu_store.customers
  for each row execute function
    catchmenu_common.set_updated_at();

comment on table catchmenu_store.customers is
  'Customer membership registry.
   Phone and email stored as hash only (PII protection).
   Membership tier auto-upgrades based on lifetime_spend.
   STANDARD → SILVER: 100,000원
   SILVER → GOLD: 500,000원
   GOLD → VIP: 2,000,000원
   특허3: 고객 방문/지출 패턴 → AI 추천 학습 데이터.';


-- =============================================
-- coupons table
-- =============================================
create table if not exists catchmenu_store.coupons (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid,

  coupon_code text not null,
  coupon_name text not null,
  coupon_type text not null,
  discount_type text not null,
  discount_value int not null,
  min_order_amount int not null default 0,
  max_discount_amount int,

  -- validity
  valid_from timestamptz not null default now(),
  valid_until timestamptz,
  total_issue_limit int,
  per_customer_limit int not null default 1,
  issued_count int not null default 0,
  redeemed_count int not null default 0,

  -- eligibility
  eligible_tiers jsonb
    not null default '["STANDARD","SILVER","GOLD","VIP"]'::jsonb,
  eligible_menu_ids jsonb default null,
  eligible_channels jsonb default null,

  coupon_status text not null default 'ACTIVE',
  description text,
  is_active boolean not null default true,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint uq_coupon_code unique (tenant_id, coupon_code),
  constraint chk_coupon_type check (
    coupon_type in (
      'DISCOUNT', 'FREEBIE', 'POINT_MULTIPLIER',
      'FREE_DELIVERY', 'BUNDLE'
    )
  ),
  constraint chk_discount_type check (
    discount_type in ('FIXED', 'PERCENTAGE')
  ),
  constraint chk_coupon_status check (
    coupon_status in (
      'ACTIVE', 'PAUSED', 'EXHAUSTED', 'EXPIRED'
    )
  ),
  constraint chk_discount_value check (
    discount_value > 0
  )
);

create index if not exists idx_coupons_tenant
  on catchmenu_store.coupons(tenant_id, coupon_status)
  where is_active = true;

alter table catchmenu_store.coupons
  enable row level security;
alter table catchmenu_store.coupons
  force row level security;

drop policy if exists coupons_isolation
  on catchmenu_store.coupons;
create policy coupons_isolation
  on catchmenu_store.coupons
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
  );

drop trigger if exists trg_coupons_updated_at
  on catchmenu_store.coupons;
create trigger trg_coupons_updated_at
  before update on catchmenu_store.coupons
  for each row execute function
    catchmenu_common.set_updated_at();


-- =============================================
-- coupon_issues table
-- =============================================
create table if not exists catchmenu_store.coupon_issues (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid,
  coupon_id uuid not null
    references catchmenu_store.coupons(id),
  customer_id uuid not null
    references catchmenu_store.customers(id),

  -- issue details
  issue_code text not null,
  issue_status text not null default 'ISSUED',
  issued_at timestamptz not null default now(),
  expires_at timestamptz,

  -- redemption
  redeemed_at timestamptz,
  redeemed_order_id uuid,
  discount_applied int,

  -- audit
  issued_by_type text not null default 'SYSTEM',
  issued_by_id uuid,
  issue_reason text,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint uq_issue_code unique (tenant_id, issue_code),
  constraint chk_issue_status check (
    issue_status in (
      'ISSUED', 'REDEEMED', 'EXPIRED', 'CANCELLED'
    )
  )
);

create index if not exists idx_coupon_issues_customer
  on catchmenu_store.coupon_issues(
    customer_id, issue_status
  );
create index if not exists idx_coupon_issues_coupon
  on catchmenu_store.coupon_issues(
    coupon_id, issue_status
  );

alter table catchmenu_store.coupon_issues
  enable row level security;
alter table catchmenu_store.coupon_issues
  force row level security;

drop policy if exists coupon_issues_isolation
  on catchmenu_store.coupon_issues;
create policy coupon_issues_isolation
  on catchmenu_store.coupon_issues
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
  );

drop trigger if exists trg_coupon_issues_updated_at
  on catchmenu_store.coupon_issues;
create trigger trg_coupon_issues_updated_at
  before update on catchmenu_store.coupon_issues
  for each row execute function
    catchmenu_common.set_updated_at();


-- =============================================
-- RPCs
-- =============================================
create or replace function catchmenu_store.register_customer(
  p_tenant_id uuid,
  p_store_id uuid,
  p_phone_hash text,
  p_phone_masked text default null,
  p_display_name text default null,
  p_preferred_locale text default 'ko',
  p_acquisition_channel text default null,
  p_allergen_profile jsonb default '{}'::jsonb,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_store, catchmenu_ledger,
                  catchmenu_common, catchmenu_hq
as $$
declare
  v_customer_id uuid;
  v_customer_code text;
  v_is_new boolean := false;
  v_business_day date;
  v_timezone text;
begin
  if trim(coalesce(p_phone_hash, '')) = '' then
    return jsonb_build_object(
      'success', false,
      'error_key', 'phone_hash_required'
    );
  end if;

  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  -- check existing customer
  select id into v_customer_id
  from catchmenu_store.customers
  where tenant_id = p_tenant_id
    and phone_hash = p_phone_hash
    and is_active = true;

  if v_customer_id is null then
    -- generate customer code
    v_customer_code := 'C' || to_char(now(), 'YYMMDD')
      || lpad(
        (
          select coalesce(count(*), 0) + 1
          from catchmenu_store.customers
          where tenant_id = p_tenant_id
        )::text,
        6, '0'
      );

    insert into catchmenu_store.customers (
      tenant_id, store_id,
      customer_code, display_name,
      phone_masked, phone_hash,
      preferred_locale,
      acquisition_channel,
      allergen_profile,
      first_visit_at, last_visit_at,
      visit_count
    ) values (
      p_tenant_id, p_store_id,
      v_customer_code,
      coalesce(p_display_name, '고객'),
      p_phone_masked, p_phone_hash,
      coalesce(p_preferred_locale, 'ko'),
      p_acquisition_channel,
      coalesce(p_allergen_profile, '{}'::jsonb),
      now(), now(), 1
    )
    returning id into v_customer_id;

    v_is_new := true;

    -- ledger event for new customer
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
      'customer', 'customer_registered', 1,
      'customer', v_customer_id,
      null, 'ACTIVE',
      'SYSTEM',
      jsonb_build_object(
        'customer_code', v_customer_code,
        'membership_tier', 'STANDARD',
        'acquisition_channel', p_acquisition_channel
      ),
      p_correlation_id,
      v_business_day, v_timezone, now()
    );

  else
    -- update returning customer
    update catchmenu_store.customers
    set
      visit_count = visit_count + 1,
      last_visit_at = now(),
      display_name = coalesce(
        p_display_name, display_name
      ),
      updated_at = now()
    where id = v_customer_id
    returning customer_code into v_customer_code;
  end if;

  return jsonb_build_object(
    'success', true,
    'customer_id', v_customer_id,
    'customer_code', v_customer_code,
    'is_new_customer', v_is_new,
    'message_code', case v_is_new
      when true then 'customer_registered'
      else 'customer_recognized'
    end
  );
end;
$$;


create or replace function catchmenu_store.issue_coupon(
  p_tenant_id uuid,
  p_store_id uuid,
  p_coupon_id uuid,
  p_customer_id uuid,
  p_issue_reason text default null,
  p_expires_at timestamptz default null,
  p_actor_type text default 'SYSTEM',
  p_actor_id uuid default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_store, catchmenu_ledger,
                  catchmenu_audit, catchmenu_common
as $$
declare
  v_coupon record;
  v_customer record;
  v_issue_id uuid;
  v_issue_code text;
  v_already_issued int;
  v_audit_id uuid;
begin
  -- get coupon
  select id, coupon_code, coupon_name,
         coupon_type, coupon_status,
         total_issue_limit, issued_count,
         per_customer_limit,
         valid_until, eligible_tiers
  into v_coupon
  from catchmenu_store.coupons
  where id = p_coupon_id
    and tenant_id = p_tenant_id
    and is_active = true
  for update;

  if v_coupon.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'coupon_not_found'
    );
  end if;

  if v_coupon.coupon_status <> 'ACTIVE' then
    return jsonb_build_object(
      'success', false,
      'error_key', 'coupon_not_active',
      'coupon_status', v_coupon.coupon_status
    );
  end if;

  -- check total issue limit
  if v_coupon.total_issue_limit is not null
    and v_coupon.issued_count
      >= v_coupon.total_issue_limit
  then
    return jsonb_build_object(
      'success', false,
      'error_key', 'coupon_exhausted'
    );
  end if;

  -- get customer
  select id, customer_code, membership_tier
  into v_customer
  from catchmenu_store.customers
  where id = p_customer_id
    and tenant_id = p_tenant_id
    and is_active = true;

  if v_customer.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'customer_not_found'
    );
  end if;

  -- check tier eligibility
  if not (
    v_coupon.eligible_tiers @>
      to_jsonb(v_customer.membership_tier)
  ) then
    return jsonb_build_object(
      'success', false,
      'error_key', 'customer_tier_not_eligible',
      'customer_tier', v_customer.membership_tier,
      'eligible_tiers', v_coupon.eligible_tiers
    );
  end if;

  -- check per-customer limit
  select count(*)
  into v_already_issued
  from catchmenu_store.coupon_issues
  where coupon_id = p_coupon_id
    and customer_id = p_customer_id
    and issue_status in ('ISSUED', 'REDEEMED');

  if v_already_issued >= v_coupon.per_customer_limit then
    return jsonb_build_object(
      'success', false,
      'error_key', 'customer_issue_limit_reached',
      'issued_count', v_already_issued,
      'limit', v_coupon.per_customer_limit
    );
  end if;

  -- generate issue code
  v_issue_code := 'ISS-' || v_coupon.coupon_code
    || '-' || extract(epoch from now())::bigint;

  -- issue coupon
  insert into catchmenu_store.coupon_issues (
    tenant_id, store_id,
    coupon_id, customer_id,
    issue_code, issue_status,
    issued_at, expires_at,
    issued_by_type, issued_by_id,
    issue_reason
  ) values (
    p_tenant_id, p_store_id,
    p_coupon_id, p_customer_id,
    v_issue_code, 'ISSUED',
    now(),
    coalesce(
      p_expires_at,
      v_coupon.valid_until
    ),
    p_actor_type, p_actor_id,
    p_issue_reason
  )
  returning id into v_issue_id;

  -- increment coupon issued count
  update catchmenu_store.coupons
  set
    issued_count = issued_count + 1,
    coupon_status = case
      when total_issue_limit is not null
        and issued_count + 1 >= total_issue_limit
      then 'EXHAUSTED'
      else coupon_status
    end,
    updated_at = now()
  where id = p_coupon_id;

  -- audit
  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := 'customer',
    p_audit_type := 'coupon_issued',
    p_audit_category := 'OPERATIONAL',
    p_actor_type := p_actor_type,
    p_actor_id := p_actor_id,
    p_subject_type := 'coupon_issue',
    p_subject_id := v_issue_id,
    p_decision := 'COMPLETED',
    p_decision_reason := p_issue_reason,
    p_decision_payload := jsonb_build_object(
      'coupon_code', v_coupon.coupon_code,
      'coupon_name', v_coupon.coupon_name,
      'customer_code', v_customer.customer_code,
      'issue_code', v_issue_code
    ),
    p_correlation_id := p_correlation_id,
    p_business_day :=
      (timezone('Asia/Seoul', now()))::date,
    p_business_timezone := 'Asia/Seoul'
  );

  return jsonb_build_object(
    'success', true,
    'issue_id', v_issue_id,
    'issue_code', v_issue_code,
    'coupon_id', p_coupon_id,
    'coupon_code', v_coupon.coupon_code,
    'coupon_name', v_coupon.coupon_name,
    'customer_id', p_customer_id,
    'customer_code', v_customer.customer_code,
    'expires_at', coalesce(
      p_expires_at, v_coupon.valid_until
    ),
    'audit_id', v_audit_id,
    'message_code', 'coupon_issued'
  );
end;
$$;


create or replace function catchmenu_store.redeem_coupon(
  p_tenant_id uuid,
  p_store_id uuid,
  p_issue_code text,
  p_customer_id uuid,
  p_order_id uuid,
  p_order_amount int,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_store, catchmenu_pos,
                  catchmenu_ledger, catchmenu_audit,
                  catchmenu_common, catchmenu_hq
as $$
declare
  v_issue record;
  v_coupon record;
  v_discount_amount int;
  v_audit_id uuid;
  v_business_day date;
  v_timezone text;
begin
  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  -- get coupon issue
  select ci.id, ci.coupon_id, ci.issue_status,
         ci.expires_at, ci.customer_id
  into v_issue
  from catchmenu_store.coupon_issues ci
  where ci.issue_code = p_issue_code
    and ci.tenant_id = p_tenant_id
    and ci.customer_id = p_customer_id
  for update;

  if v_issue.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'coupon_issue_not_found'
    );
  end if;

  if v_issue.issue_status <> 'ISSUED' then
    return jsonb_build_object(
      'success', false,
      'error_key', 'coupon_not_redeemable',
      'current_status', v_issue.issue_status
    );
  end if;

  -- check expiry
  if v_issue.expires_at is not null
    and v_issue.expires_at < now()
  then
    -- auto expire
    update catchmenu_store.coupon_issues
    set issue_status = 'EXPIRED', updated_at = now()
    where id = v_issue.id;

    return jsonb_build_object(
      'success', false,
      'error_key', 'coupon_expired',
      'expired_at', v_issue.expires_at
    );
  end if;

  -- get coupon details
  select id, coupon_code, coupon_name,
         coupon_type, discount_type,
         discount_value, min_order_amount,
         max_discount_amount
  into v_coupon
  from catchmenu_store.coupons
  where id = v_issue.coupon_id;

  -- check min order amount
  if p_order_amount < v_coupon.min_order_amount then
    return jsonb_build_object(
      'success', false,
      'error_key', 'order_amount_below_minimum',
      'min_order_amount', v_coupon.min_order_amount,
      'order_amount', p_order_amount
    );
  end if;

  -- calculate discount
  v_discount_amount := case v_coupon.discount_type
    when 'FIXED' then v_coupon.discount_value
    when 'PERCENTAGE' then
      (p_order_amount * v_coupon.discount_value / 100)
  end;

  -- apply max discount cap
  if v_coupon.max_discount_amount is not null then
    v_discount_amount := least(
      v_discount_amount,
      v_coupon.max_discount_amount
    );
  end if;

  -- cannot exceed order amount
  v_discount_amount := least(
    v_discount_amount, p_order_amount
  );

  -- redeem coupon issue
  update catchmenu_store.coupon_issues
  set
    issue_status = 'REDEEMED',
    redeemed_at = now(),
    redeemed_order_id = p_order_id,
    discount_applied = v_discount_amount,
    updated_at = now()
  where id = v_issue.id;

  -- update coupon redeemed count
  update catchmenu_store.coupons
  set
    redeemed_count = redeemed_count + 1,
    updated_at = now()
  where id = v_coupon.id;

  -- apply discount to order
  update catchmenu_pos.orders
  set
    discount_amount = discount_amount + v_discount_amount,
    final_amount = final_amount - v_discount_amount,
    updated_at = now()
  where id = p_order_id;

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
    'customer', 'coupon_redeemed', 1,
    'coupon_issue', v_issue.id,
    'ISSUED', 'REDEEMED',
    'CUSTOMER',
    jsonb_build_object(
      'issue_code', p_issue_code,
      'coupon_code', v_coupon.coupon_code,
      'discount_amount', v_discount_amount,
      'order_amount', p_order_amount
    ),
    p_order_id, p_correlation_id,
    v_business_day, v_timezone, now()
  );

  -- audit
  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := 'customer',
    p_audit_type := 'coupon_redeemed',
    p_audit_category := 'FINANCIAL',
    p_actor_type := 'CUSTOMER',
    p_actor_id := p_customer_id,
    p_subject_type := 'coupon_issue',
    p_subject_id := v_issue.id,
    p_decision := 'COMPLETED',
    p_decision_payload := jsonb_build_object(
      'coupon_code', v_coupon.coupon_code,
      'issue_code', p_issue_code,
      'discount_amount', v_discount_amount,
      'order_amount', p_order_amount
    ),
    p_order_id := p_order_id,
    p_correlation_id := p_correlation_id,
    p_business_day := v_business_day,
    p_business_timezone := v_timezone
  );

  return jsonb_build_object(
    'success', true,
    'issue_id', v_issue.id,
    'issue_code', p_issue_code,
    'coupon_code', v_coupon.coupon_code,
    'coupon_name', v_coupon.coupon_name,
    'discount_type', v_coupon.discount_type,
    'discount_amount', v_discount_amount,
    'order_amount_after', p_order_amount - v_discount_amount,
    'audit_id', v_audit_id,
    'message_code', 'coupon_redeemed'
  );
end;
$$;


create or replace function catchmenu_store.get_customer_profile(
  p_tenant_id uuid,
  p_customer_id uuid
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_store, catchmenu_common
as $$
declare
  v_customer record;
  v_active_coupons jsonb;
  v_recent_visits jsonb;
  v_tier_progress jsonb;
begin
  select id, customer_code, display_name,
         phone_masked, preferred_locale,
         membership_tier, membership_status,
         point_balance, lifetime_spend,
         visit_count, last_visit_at, first_visit_at,
         allergen_profile, acquisition_channel
  into v_customer
  from catchmenu_store.customers
  where id = p_customer_id
    and tenant_id = p_tenant_id
    and is_active = true;

  if v_customer.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'customer_not_found'
    );
  end if;

  -- active coupons
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'issue_id', ci.id,
        'issue_code', ci.issue_code,
        'coupon_name', c.coupon_name,
        'coupon_type', c.coupon_type,
        'discount_type', c.discount_type,
        'discount_value', c.discount_value,
        'min_order_amount', c.min_order_amount,
        'expires_at', ci.expires_at,
        'is_expiring_soon',
          ci.expires_at is not null
          and ci.expires_at < now() + interval '3 days'
      )
      order by ci.expires_at asc nulls last
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
    and (
      ci.expires_at is null
      or ci.expires_at > now()
    );

  -- tier upgrade progress
  v_tier_progress := case v_customer.membership_tier
    when 'STANDARD' then jsonb_build_object(
      'current_tier', 'STANDARD',
      'next_tier', 'SILVER',
      'next_tier_threshold', 100000,
      'spend_remaining',
        greatest(0, 100000 - v_customer.lifetime_spend),
      'progress_pct', least(100,
        (v_customer.lifetime_spend::numeric
          / 100000 * 100)::int
      )
    )
    when 'SILVER' then jsonb_build_object(
      'current_tier', 'SILVER',
      'next_tier', 'GOLD',
      'next_tier_threshold', 500000,
      'spend_remaining',
        greatest(0, 500000 - v_customer.lifetime_spend),
      'progress_pct', least(100,
        (v_customer.lifetime_spend::numeric
          / 500000 * 100)::int
      )
    )
    when 'GOLD' then jsonb_build_object(
      'current_tier', 'GOLD',
      'next_tier', 'VIP',
      'next_tier_threshold', 2000000,
      'spend_remaining',
        greatest(0, 2000000 - v_customer.lifetime_spend),
      'progress_pct', least(100,
        (v_customer.lifetime_spend::numeric
          / 2000000 * 100)::int
      )
    )
    when 'VIP' then jsonb_build_object(
      'current_tier', 'VIP',
      'next_tier', null,
      'next_tier_threshold', null,
      'spend_remaining', 0,
      'progress_pct', 100
    )
    else jsonb_build_object(
      'current_tier', v_customer.membership_tier
    )
  end;

  return jsonb_build_object(
    'success', true,
    'customer', jsonb_build_object(
      'id', v_customer.id,
      'customer_code', v_customer.customer_code,
      'display_name', v_customer.display_name,
      'phone_masked', v_customer.phone_masked,
      'preferred_locale', v_customer.preferred_locale,
      'allergen_profile', v_customer.allergen_profile
    ),
    'membership', jsonb_build_object(
      'tier', v_customer.membership_tier,
      'status', v_customer.membership_status,
      'point_balance', v_customer.point_balance,
      'lifetime_spend', v_customer.lifetime_spend,
      'visit_count', v_customer.visit_count,
      'last_visit_at', v_customer.last_visit_at,
      'first_visit_at', v_customer.first_visit_at
    ),
    'tier_progress', v_tier_progress,
    'active_coupons', v_active_coupons,
    'active_coupon_count',
      jsonb_array_length(v_active_coupons),
    'message_code', 'customer_profile_loaded'
  );
end;
$$;

-- grants
do $$
begin
  revoke all on function catchmenu_store.register_customer(
    uuid, uuid, text, text, text, text, text, jsonb, text
  ) from public;
  grant execute on function catchmenu_store.register_customer(
    uuid, uuid, text, text, text, text, text, jsonb, text
  ) to authenticated;

  revoke all on function catchmenu_store.issue_coupon(
    uuid, uuid, uuid, uuid, text, timestamptz, text, uuid, text
  ) from public;
  grant execute on function catchmenu_store.issue_coupon(
    uuid, uuid, uuid, uuid, text, timestamptz, text, uuid, text
  ) to authenticated;

  revoke all on function catchmenu_store.redeem_coupon(
    uuid, uuid, text, uuid, uuid, int, text
  ) from public;
  grant execute on function catchmenu_store.redeem_coupon(
    uuid, uuid, text, uuid, uuid, int, text
  ) to authenticated;

  revoke all on function catchmenu_store.get_customer_profile(
    uuid, uuid
  ) from public;
  grant execute on function catchmenu_store.get_customer_profile(
    uuid, uuid
  ) to authenticated;
end;
$$;

comment on function catchmenu_store.register_customer(
  uuid, uuid, text, text, text, text, text, jsonb, text
) is
  'Registers new customer or recognizes returning customer.
   Phone stored as hash only — PII protection.
   New: creates membership at STANDARD tier.
   Returning: increments visit_count and last_visit_at.
   특허1: 고객 세션 시작 시 멤버십 조회/등록.';

comment on function catchmenu_store.redeem_coupon(
  uuid, uuid, text, uuid, uuid, int, text
) is
  'Redeems coupon at order time.
   Validates: status, expiry, min_order_amount.
   Calculates discount (FIXED or PERCENTAGE).
   Applies max_discount_amount cap.
   Directly updates order discount_amount and final_amount.
   Creates audit record — coupon 사용 증빙 보관.
   특허1: 쿠폰 적용 증빙 = 분쟁 해결 감사 이벤트.';