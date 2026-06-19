-- 0059_create_point_ledger_rpc.sql
-- Purpose: Customer point accumulation and deduction RPCs.
--          earn_points: earns points from completed order.
--          deduct_points: deducts points for payment discount.
--          expire_points: expires old unspent points.
--          get_point_history: returns point transaction history.
--          특허4 core: 포인트 원장 = append-only 이벤트 기반.
-- Depends on: 0058_create_membership_rpc.sql
-- Creates:
--   catchmenu_store.point_ledger (table)
--   function catchmenu_store.earn_points(...)
--   function catchmenu_store.deduct_points(...)
--   function catchmenu_store.expire_points(...)
--   function catchmenu_store.get_point_history(...)

-- =============================================
-- point_ledger table
-- =============================================
create table if not exists catchmenu_store.point_ledger (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid,
  customer_id uuid not null
    references catchmenu_store.customers(id),

  -- transaction
  transaction_type text not null,
  points_change int not null,
  points_before int not null,
  points_after int not null,

  -- reference
  order_id uuid,
  coupon_issue_id uuid,
  reference_note text,

  -- expiry
  points_expire_at timestamptz,
  is_expired boolean not null default false,
  expired_at timestamptz,

  -- actor
  actor_type text not null default 'SYSTEM',
  actor_id uuid,

  -- business
  business_day date not null,
  business_timezone text not null default 'Asia/Seoul',
  occurred_at timestamptz not null default now(),

  created_at timestamptz not null default now(),

  constraint chk_transaction_type check (
    transaction_type in (
      'EARN', 'DEDUCT', 'EXPIRE',
      'ADJUST', 'BONUS', 'REFUND_EARN'
    )
  ),
  constraint chk_points_after check (
    points_after >= 0
  )
);

create index if not exists idx_point_ledger_customer
  on catchmenu_store.point_ledger(
    customer_id, occurred_at desc
  );
create index if not exists idx_point_ledger_order
  on catchmenu_store.point_ledger(order_id)
  where order_id is not null;
create index if not exists idx_point_ledger_expiry
  on catchmenu_store.point_ledger(points_expire_at)
  where is_expired = false
    and transaction_type = 'EARN';

alter table catchmenu_store.point_ledger
  enable row level security;
alter table catchmenu_store.point_ledger
  force row level security;

drop policy if exists point_ledger_isolation
  on catchmenu_store.point_ledger;
create policy point_ledger_isolation
  on catchmenu_store.point_ledger
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
  );

comment on table catchmenu_store.point_ledger is
  'Append-only point transaction ledger per customer.
   Every point change records before/after balance.
   Current balance = sum of points_change per customer.
   특허4: 포인트 원장 = append-only.
   직접 UPDATE 금지 — 모든 변경은 새 레코드 삽입.';


-- =============================================
-- point rules table
-- =============================================
create table if not exists catchmenu_store.point_rules (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid,

  rule_name text not null,
  rule_type text not null default 'EARN_RATE',

  -- earn rate: points per 100 KRW spent
  earn_rate_per_100 int not null default 1,

  -- tier multipliers
  silver_multiplier numeric(3,1) not null default 1.5,
  gold_multiplier numeric(3,1) not null default 2.0,
  vip_multiplier numeric(3,1) not null default 3.0,

  -- deduction settings
  min_points_for_deduction int not null default 1000,
  max_deduction_rate_pct int not null default 20,

  -- expiry
  points_expire_months int not null default 12,

  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint uq_point_rules unique (tenant_id, rule_type)
);

alter table catchmenu_store.point_rules
  enable row level security;
alter table catchmenu_store.point_rules
  force row level security;

drop policy if exists point_rules_isolation
  on catchmenu_store.point_rules;
create policy point_rules_isolation
  on catchmenu_store.point_rules
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
  );

drop trigger if exists trg_point_rules_updated_at
  on catchmenu_store.point_rules;
create trigger trg_point_rules_updated_at
  before update on catchmenu_store.point_rules
  for each row execute function
    catchmenu_common.set_updated_at();

-- default point rules seed
create or replace function
  catchmenu_store.ensure_point_rules(
  p_tenant_id uuid
)
returns uuid
language plpgsql
volatile
security definer
set search_path = catchmenu_store
as $$
declare
  v_id uuid;
begin
  select id into v_id
  from catchmenu_store.point_rules
  where tenant_id = p_tenant_id
    and rule_type = 'EARN_RATE'
    and is_active = true;

  if v_id is null then
    insert into catchmenu_store.point_rules (
      tenant_id, rule_name, rule_type
    ) values (
      p_tenant_id, '기본 포인트 적립 규칙', 'EARN_RATE'
    )
    returning id into v_id;
  end if;

  return v_id;
end;
$$;


-- =============================================
-- RPCs
-- =============================================
create or replace function catchmenu_store.earn_points(
  p_tenant_id uuid,
  p_store_id uuid,
  p_customer_id uuid,
  p_order_id uuid,
  p_order_amount int,
  p_is_bonus boolean default false,
  p_bonus_points int default null,
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
  v_customer record;
  v_rules record;
  v_points_earned int;
  v_multiplier numeric;
  v_points_before int;
  v_points_after int;
  v_ledger_id uuid;
  v_expire_at timestamptz;
  v_business_day date;
  v_timezone text;
  v_new_tier text;
  v_new_lifetime int;
begin
  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  -- get customer with lock
  select id, membership_tier, point_balance,
         lifetime_spend
  into v_customer
  from catchmenu_store.customers
  where id = p_customer_id
    and tenant_id = p_tenant_id
    and is_active = true
  for update;

  if v_customer.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'customer_not_found'
    );
  end if;

  -- get point rules
  perform catchmenu_store.ensure_point_rules(p_tenant_id);

  select earn_rate_per_100,
         silver_multiplier, gold_multiplier,
         vip_multiplier, points_expire_months
  into v_rules
  from catchmenu_store.point_rules
  where tenant_id = p_tenant_id
    and rule_type = 'EARN_RATE'
    and is_active = true;

  -- tier multiplier
  v_multiplier := case v_customer.membership_tier
    when 'SILVER' then v_rules.silver_multiplier
    when 'GOLD' then v_rules.gold_multiplier
    when 'VIP' then v_rules.vip_multiplier
    else 1.0
  end;

  -- calculate points
  if p_is_bonus and p_bonus_points is not null then
    v_points_earned := p_bonus_points;
  else
    v_points_earned := (
      p_order_amount / 100
      * v_rules.earn_rate_per_100
      * v_multiplier
    )::int;
  end if;

  if v_points_earned <= 0 then
    return jsonb_build_object(
      'success', true,
      'points_earned', 0,
      'message_code', 'no_points_earned'
    );
  end if;

  v_points_before := v_customer.point_balance;
  v_points_after := v_points_before + v_points_earned;
  v_expire_at := now() + (
    v_rules.points_expire_months || ' months'
  )::interval;

  -- update lifetime spend and check tier upgrade
  v_new_lifetime :=
    v_customer.lifetime_spend + p_order_amount;

  v_new_tier := case
    when v_new_lifetime >= 2000000 then 'VIP'
    when v_new_lifetime >= 500000 then 'GOLD'
    when v_new_lifetime >= 100000 then 'SILVER'
    else v_customer.membership_tier
  end;

  -- update customer
  update catchmenu_store.customers
  set
    point_balance = v_points_after,
    lifetime_spend = v_new_lifetime,
    membership_tier = v_new_tier,
    updated_at = now()
  where id = p_customer_id;

  -- append to point ledger (특허4: append-only)
  insert into catchmenu_store.point_ledger (
    tenant_id, store_id, customer_id,
    transaction_type, points_change,
    points_before, points_after,
    order_id, reference_note,
    points_expire_at,
    actor_type,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id, p_customer_id,
    case when p_is_bonus then 'BONUS' else 'EARN' end,
    v_points_earned,
    v_points_before, v_points_after,
    p_order_id,
    case when p_is_bonus
      then '보너스 포인트'
      else '구매 적립 (' ||
        p_order_amount || '원)'
    end,
    v_expire_at,
    'SYSTEM',
    v_business_day, v_timezone, now()
  )
  returning id into v_ledger_id;

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
    'customer', 'points_earned', 1,
    'customer', p_customer_id,
    v_customer.membership_tier, v_new_tier,
    'SYSTEM',
    jsonb_build_object(
      'points_earned', v_points_earned,
      'points_before', v_points_before,
      'points_after', v_points_after,
      'order_amount', p_order_amount,
      'multiplier', v_multiplier,
      'tier_changed',
        v_new_tier <> v_customer.membership_tier,
      'new_tier', v_new_tier
    ),
    p_order_id, p_correlation_id,
    v_business_day, v_timezone, now()
  );

  return jsonb_build_object(
    'success', true,
    'ledger_id', v_ledger_id,
    'customer_id', p_customer_id,
    'points_earned', v_points_earned,
    'points_before', v_points_before,
    'points_after', v_points_after,
    'multiplier', v_multiplier,
    'expire_at', v_expire_at,
    'tier_upgraded',
      v_new_tier <> v_customer.membership_tier,
    'new_tier', v_new_tier,
    'message_code', case
      when v_new_tier <> v_customer.membership_tier
      then 'points_earned_tier_upgraded'
      else 'points_earned'
    end
  );
end;
$$;


create or replace function catchmenu_store.deduct_points(
  p_tenant_id uuid,
  p_store_id uuid,
  p_customer_id uuid,
  p_order_id uuid,
  p_points_to_deduct int,
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
  v_customer record;
  v_rules record;
  v_max_deductible int;
  v_points_before int;
  v_points_after int;
  v_ledger_id uuid;
  v_audit_id uuid;
  v_business_day date;
  v_timezone text;
begin
  if p_points_to_deduct <= 0 then
    return jsonb_build_object(
      'success', false,
      'error_key', 'invalid_deduct_amount'
    );
  end if;

  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  -- get customer with lock
  select id, membership_tier, point_balance
  into v_customer
  from catchmenu_store.customers
  where id = p_customer_id
    and tenant_id = p_tenant_id
    and is_active = true
  for update;

  if v_customer.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'customer_not_found'
    );
  end if;

  -- get rules
  perform catchmenu_store.ensure_point_rules(p_tenant_id);

  select min_points_for_deduction,
         max_deduction_rate_pct
  into v_rules
  from catchmenu_store.point_rules
  where tenant_id = p_tenant_id
    and rule_type = 'EARN_RATE'
    and is_active = true;

  -- minimum balance check
  if v_customer.point_balance
    < v_rules.min_points_for_deduction
  then
    return jsonb_build_object(
      'success', false,
      'error_key', 'insufficient_points',
      'point_balance', v_customer.point_balance,
      'minimum_required',
        v_rules.min_points_for_deduction
    );
  end if;

  -- max deduction = order_amount * max_rate
  v_max_deductible := (
    p_order_amount
    * v_rules.max_deduction_rate_pct / 100
  );

  if p_points_to_deduct > v_max_deductible then
    return jsonb_build_object(
      'success', false,
      'error_key', 'exceeds_max_deduction',
      'requested', p_points_to_deduct,
      'max_deductible', v_max_deductible,
      'max_rate_pct', v_rules.max_deduction_rate_pct
    );
  end if;

  -- cannot exceed balance
  if p_points_to_deduct > v_customer.point_balance then
    return jsonb_build_object(
      'success', false,
      'error_key', 'insufficient_points',
      'point_balance', v_customer.point_balance,
      'requested', p_points_to_deduct
    );
  end if;

  v_points_before := v_customer.point_balance;
  v_points_after := v_points_before - p_points_to_deduct;

  -- update customer balance
  update catchmenu_store.customers
  set
    point_balance = v_points_after,
    updated_at = now()
  where id = p_customer_id;

  -- apply discount to order
  update catchmenu_pos.orders
  set
    discount_amount = discount_amount + p_points_to_deduct,
    final_amount = final_amount - p_points_to_deduct,
    updated_at = now()
  where id = p_order_id;

  -- append to point ledger
  insert into catchmenu_store.point_ledger (
    tenant_id, store_id, customer_id,
    transaction_type, points_change,
    points_before, points_after,
    order_id, reference_note,
    actor_type,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id, p_customer_id,
    'DEDUCT', -p_points_to_deduct,
    v_points_before, v_points_after,
    p_order_id,
    '포인트 결제 사용',
    'CUSTOMER',
    v_business_day, v_timezone, now()
  )
  returning id into v_ledger_id;

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
    'customer', 'points_deducted', 1,
    'customer', p_customer_id,
    v_points_before::text,
    v_points_after::text,
    'CUSTOMER',
    jsonb_build_object(
      'points_deducted', p_points_to_deduct,
      'points_before', v_points_before,
      'points_after', v_points_after,
      'order_amount', p_order_amount,
      'discount_applied', p_points_to_deduct
    ),
    p_order_id, p_correlation_id,
    v_business_day, v_timezone, now()
  );

  -- audit (financial category — 포인트 사용은 금전 가치)
  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := 'customer',
    p_audit_type := 'points_deducted',
    p_audit_category := 'FINANCIAL',
    p_actor_type := 'CUSTOMER',
    p_actor_id := p_customer_id,
    p_subject_type := 'customer',
    p_subject_id := p_customer_id,
    p_decision := 'COMPLETED',
    p_decision_payload := jsonb_build_object(
      'points_deducted', p_points_to_deduct,
      'points_before', v_points_before,
      'points_after', v_points_after,
      'order_amount', p_order_amount
    ),
    p_order_id := p_order_id,
    p_correlation_id := p_correlation_id,
    p_business_day := v_business_day,
    p_business_timezone := v_timezone
  );

  return jsonb_build_object(
    'success', true,
    'ledger_id', v_ledger_id,
    'customer_id', p_customer_id,
    'points_deducted', p_points_to_deduct,
    'points_before', v_points_before,
    'points_after', v_points_after,
    'discount_applied', p_points_to_deduct,
    'order_amount_after',
      p_order_amount - p_points_to_deduct,
    'audit_id', v_audit_id,
    'message_code', 'points_deducted'
  );
end;
$$;


create or replace function catchmenu_store.expire_points(
  p_tenant_id uuid,
  p_batch_size int default 100
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_store, catchmenu_ledger,
                  catchmenu_common
as $$
declare
  v_expired_count int := 0;
  v_total_expired_points int := 0;
  v_entry record;
  v_customer record;
  v_points_before int;
  v_points_after int;
begin
  -- process expired earn entries
  for v_entry in
    select pl.id, pl.customer_id,
           pl.points_change, pl.tenant_id,
           pl.business_day, pl.business_timezone
    from catchmenu_store.point_ledger pl
    where pl.tenant_id = p_tenant_id
      and pl.transaction_type = 'EARN'
      and pl.is_expired = false
      and pl.points_expire_at <= now()
    limit p_batch_size
    for update skip locked
  loop
    -- get current customer balance
    select id, point_balance
    into v_customer
    from catchmenu_store.customers
    where id = v_entry.customer_id
    for update;

    if v_customer.id is null then
      continue;
    end if;

    -- mark earn entry as expired
    update catchmenu_store.point_ledger
    set
      is_expired = true,
      expired_at = now()
    where id = v_entry.id;

    v_points_before := v_customer.point_balance;
    v_points_after := greatest(
      0,
      v_points_before - v_entry.points_change
    );

    -- deduct expired points
    update catchmenu_store.customers
    set
      point_balance = v_points_after,
      updated_at = now()
    where id = v_entry.customer_id;

    -- append expire record
    insert into catchmenu_store.point_ledger (
      tenant_id, customer_id,
      transaction_type, points_change,
      points_before, points_after,
      reference_note, is_expired,
      actor_type,
      business_day, business_timezone, occurred_at
    ) values (
      p_tenant_id, v_entry.customer_id,
      'EXPIRE',
      -(v_entry.points_change),
      v_points_before, v_points_after,
      '포인트 유효기간 만료',
      true,
      'SYSTEM',
      (timezone('Asia/Seoul', now()))::date,
      'Asia/Seoul', now()
    );

    v_expired_count := v_expired_count + 1;
    v_total_expired_points :=
      v_total_expired_points + v_entry.points_change;
  end loop;

  -- ledger event for batch expiry
  if v_expired_count > 0 then
    insert into catchmenu_ledger.events (
      tenant_id,
      event_domain, event_type, event_version,
      subject_type, subject_id,
      from_state, to_state,
      caused_by_type, event_payload,
      business_day, business_timezone, occurred_at
    ) values (
      p_tenant_id,
      'customer', 'points_batch_expired', 1,
      'tenant', p_tenant_id,
      null, 'EXPIRED',
      'SYSTEM',
      jsonb_build_object(
        'expired_count', v_expired_count,
        'total_expired_points', v_total_expired_points
      ),
      (timezone('Asia/Seoul', now()))::date,
      'Asia/Seoul', now()
    );
  end if;

  return jsonb_build_object(
    'success', true,
    'expired_count', v_expired_count,
    'total_expired_points', v_total_expired_points,
    'processed_at', now(),
    'message_code', case v_expired_count
      when 0 then 'no_points_to_expire'
      else 'points_batch_expired'
    end
  );
end;
$$;


create or replace function catchmenu_store.get_point_history(
  p_tenant_id uuid,
  p_customer_id uuid,
  p_limit int default 20,
  p_offset int default 0
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_store, catchmenu_common
as $$
declare
  v_customer record;
  v_history jsonb;
  v_summary jsonb;
  v_total_count int;
begin
  select id, point_balance, membership_tier,
         lifetime_spend, visit_count
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

  -- total count
  select count(*)
  into v_total_count
  from catchmenu_store.point_ledger
  where customer_id = p_customer_id
    and tenant_id = p_tenant_id;

  -- history with pagination
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'id', pl.id,
        'transaction_type', pl.transaction_type,
        'points_change', pl.points_change,
        'points_before', pl.points_before,
        'points_after', pl.points_after,
        'order_id', pl.order_id,
        'reference_note', pl.reference_note,
        'points_expire_at', pl.points_expire_at,
        'is_expired', pl.is_expired,
        'occurred_at', pl.occurred_at
      )
      order by pl.occurred_at desc
    ),
    '[]'::jsonb
  )
  into v_history
  from catchmenu_store.point_ledger pl
  where pl.customer_id = p_customer_id
    and pl.tenant_id = p_tenant_id
  order by pl.occurred_at desc
  limit p_limit
  offset p_offset;

  -- points summary
  select jsonb_build_object(
    'total_earned', coalesce(
      sum(points_change) filter (
        where transaction_type in ('EARN', 'BONUS')
          and not is_expired
      ), 0
    ),
    'total_deducted', coalesce(
      abs(sum(points_change)) filter (
        where transaction_type = 'DEDUCT'
      ), 0
    ),
    'total_expired', coalesce(
      abs(sum(points_change)) filter (
        where transaction_type = 'EXPIRE'
      ), 0
    ),
    'expiring_soon', coalesce(
      sum(points_change) filter (
        where transaction_type = 'EARN'
          and not is_expired
          and points_expire_at is not null
          and points_expire_at < now()
            + interval '30 days'
      ), 0
    )
  )
  into v_summary
  from catchmenu_store.point_ledger
  where customer_id = p_customer_id
    and tenant_id = p_tenant_id;

  return jsonb_build_object(
    'success', true,
    'customer', jsonb_build_object(
      'id', v_customer.id,
      'point_balance', v_customer.point_balance,
      'membership_tier', v_customer.membership_tier,
      'lifetime_spend', v_customer.lifetime_spend,
      'visit_count', v_customer.visit_count
    ),
    'history', v_history,
    'summary', v_summary,
    'pagination', jsonb_build_object(
      'total_count', v_total_count,
      'limit', p_limit,
      'offset', p_offset,
      'has_more', (p_offset + p_limit) < v_total_count
    ),
    'message_code', 'point_history_loaded'
  );
end;
$$;

-- grants
do $$
begin
  revoke all on function catchmenu_store.earn_points(
    uuid, uuid, uuid, uuid, int, boolean, int, text
  ) from public;
  grant execute on function catchmenu_store.earn_points(
    uuid, uuid, uuid, uuid, int, boolean, int, text
  ) to authenticated;

  revoke all on function catchmenu_store.deduct_points(
    uuid, uuid, uuid, uuid, int, int, text
  ) from public;
  grant execute on function catchmenu_store.deduct_points(
    uuid, uuid, uuid, uuid, int, int, text
  ) to authenticated;

  revoke all on function catchmenu_store.expire_points(
    uuid, int
  ) from public;
  grant execute on function catchmenu_store.expire_points(
    uuid, int
  ) to authenticated;

  revoke all on function catchmenu_store.get_point_history(
    uuid, uuid, int, int
  ) from public;
  grant execute on function catchmenu_store.get_point_history(
    uuid, uuid, int, int
  ) to authenticated;
end;
$$;

comment on function catchmenu_store.earn_points(
  uuid, uuid, uuid, uuid, int, boolean, int, text
) is
  'Earns points from completed order.
   Applies tier multiplier: SILVER 1.5x, GOLD 2.0x, VIP 3.0x.
   Default: 1 point per 100 KRW.
   Auto-upgrades membership tier based on lifetime_spend.
   STANDARD → SILVER: 100,000원
   SILVER → GOLD: 500,000원
   GOLD → VIP: 2,000,000원
   특허4: 포인트 원장 = append-only.
   customer.point_balance는 항상 원장 합계와 일치해야 함.';

comment on function catchmenu_store.deduct_points(
  uuid, uuid, uuid, uuid, int, int, text
) is
  'Deducts points for payment discount.
   Validates: minimum balance, max deduction rate (20%).
   Directly applies discount to order.final_amount.
   Creates FINANCIAL audit record.
   특허4: 포인트 차감 = 금전 가치 → FINANCIAL 감사 이벤트.';

comment on function catchmenu_store.expire_points(
  uuid, int
) is
  'Batch expires overdue earn entries.
   Processes up to batch_size entries per call.
   Marks original EARN entry is_expired = true.
   Appends new EXPIRE record to point_ledger.
   특허4: 만료 처리도 append-only 원장에 기록.
   Cron job으로 daily 실행 권장.';