-- 0082_create_saas_billing_rpc.sql
-- Purpose: SaaS subscription billing and tenant onboarding RPCs.
--          Plan management, subscription lifecycle,
--          usage tracking, tenant provisioning.
--          1-B차 SaaS 상품화 기반.
--          SaaS 판매 조건: 1-B + AI 고객센터(5차) 동시 요건.
-- Depends on: 0081_create_customer_app_rpc.sql
-- Creates:
--   catchmenu_common.subscription_plans (table)
--   catchmenu_common.subscription_invoices (table)
--   catchmenu_common.usage_records (table)
--   catchmenu_common.tenant_onboarding_log (table)
--   function catchmenu_common.provision_tenant(...)
--   function catchmenu_common.activate_subscription(...)
--   function catchmenu_common.record_usage(...)
--   function catchmenu_common.generate_invoice(...)
--   function catchmenu_common.get_saas_dashboard(...)
--   function catchmenu_common.check_saas_readiness(...)

-- =============================================
-- subscription_plans table
-- SaaS 구독 플랜 정의
-- =============================================
create table if not exists
  catchmenu_common.subscription_plans (
  id uuid primary key default gen_random_uuid(),

  plan_code text not null unique,
  plan_name text not null,
  plan_tier text not null,
  plan_type text not null default 'RECURRING',

  -- 가격
  monthly_fee int not null default 0,
  annual_fee int,
  currency text not null default 'KRW',

  -- 한도
  max_stores int not null default 1,
  max_devices_per_store int not null default 5,
  max_staff_per_store int not null default 10,
  max_menu_items int not null default 100,
  max_monthly_orders int,
  max_monthly_customers int,

  -- 포함 기능
  included_features jsonb
    not null default '[]'::jsonb,
  addon_features jsonb
    default '[]'::jsonb,

  -- SaaS 출시 상태
  -- 판매 조건: 1-B + AI 고객센터(5차) 동시
  is_publicly_available boolean
    not null default false,
  available_from_phase text
    not null default 'PHASE_1B',

  -- 표시
  display_order int not null default 0,
  is_recommended boolean not null default false,
  plan_description text,

  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint chk_plan_tier check (
    plan_tier in (
      'TRIAL', 'STARTER', 'PRO', 'ENTERPRISE'
    )
  ),
  constraint chk_plan_type check (
    plan_type in (
      'FREE', 'RECURRING', 'ANNUAL', 'CUSTOM'
    )
  )
);

drop trigger if exists trg_subscription_plans_updated
  on catchmenu_common.subscription_plans;
create trigger trg_subscription_plans_updated
  before update on
    catchmenu_common.subscription_plans
  for each row execute function
    catchmenu_common.set_updated_at();

-- seed plans
insert into catchmenu_common.subscription_plans (
  plan_code, plan_name, plan_tier, plan_type,
  monthly_fee, annual_fee,
  max_stores, max_devices_per_store,
  max_staff_per_store, max_menu_items,
  max_monthly_orders,
  included_features,
  is_publicly_available,
  available_from_phase,
  display_order, is_recommended,
  plan_description
) values
(
  'TRIAL_30',
  '30일 무료 체험',
  'TRIAL', 'FREE',
  0, null,
  1, 3, 5, 50, 500,
  ('["WAITING_QUEUE","KDS_BASIC","TAKEOUT_ORDER",'
  || '"MENU_MANAGEMENT","OKPOS_INTEGRATION"]')::jsonb,
  false, 'PHASE_1',
  0, false,
  '30일 무료 체험. 1호점 테스트베드 전용.'
),
(
  'STARTER_MONTHLY',
  'STARTER 월 구독',
  'STARTER', 'RECURRING',
  10000, null,
  1, 5, 10, 100, null,
  ('["WAITING_QUEUE","KDS_BASIC","TAKEOUT_ORDER",'
  || '"MENU_MANAGEMENT","OKPOS_INTEGRATION",'
  || '"TOSS_POS_INTEGRATION"]')::jsonb,
  false, 'PHASE_1',
  1, false,
  '월 1만원. 포장주문 + KDS + 대기. '
  || '소상공인 전화 병목 해소 핵심 솔루션.'
),
(
  'PRO_MONTHLY',
  'PRO 월 구독',
  'PRO', 'RECURRING',
  50000, null,
  3, 10, 20, 300, null,
  ('["WAITING_QUEUE","KDS_BASIC","TAKEOUT_ORDER",'
  || '"MENU_MANAGEMENT","OKPOS_INTEGRATION",'
  || '"TOSS_POS_INTEGRATION",'
  || '"CUSTOMER_MEMBERSHIP_APP",'
  || '"DELIVERY_INTEGRATION",'
  || '"DID_CMS","MAJOR_POS_INTEGRATION",'
  || '"AI_CUSTOMER_CENTER","DIGITAL_SOP"]')::jsonb,
  false, 'PHASE_5',
  2, true,
  'SaaS 판매 핵심 플랜. '
  || 'AI 고객센터 + 멤버십 앱 + 배달 통합. '
  || '예상 출시: 2028년 중~2029년 초.'
),
(
  'ENTERPRISE_CUSTOM',
  'ENTERPRISE 맞춤 계약',
  'ENTERPRISE', 'CUSTOM',
  0, null,
  99, 20, 50, 9999, null,
  ('["WAITING_QUEUE","KDS_BASIC","TAKEOUT_ORDER",'
  || '"MENU_MANAGEMENT","OKPOS_INTEGRATION",'
  || '"TOSS_POS_INTEGRATION",'
  || '"CUSTOMER_MEMBERSHIP_APP",'
  || '"DELIVERY_INTEGRATION","DID_CMS",'
  || '"ALL_POS_INTEGRATION","WHITE_LABEL",'
  || '"AI_CUSTOMER_CENTER","DIGITAL_SOP",'
  || '"MULTI_TENANT_SAAS"]')::jsonb,
  false, 'PHASE_6',
  3, false,
  '가맹점 본사 화이트라벨 협상. '
  || '6차 SaaS 완전판. '
  || '전체 POS 연동 + 프랜차이즈 OS.'
)
on conflict (plan_code) do nothing;

comment on table
  catchmenu_common.subscription_plans is
  'SaaS 구독 플랜 정의.
   TRIAL: 30일 무료 (1호점 테스트베드).
   STARTER (월 1만원): 포장+KDS+대기.
   PRO: AI 고객센터 + 멤버십 필수.
   ENTERPRISE: 화이트라벨 + 전체 POS.

   SaaS 판매 공식:
   is_publicly_available = true 조건:
   1-B차 완성 + AI 고객센터(5차) 동시 완성.
   예상 시점: 2028년 중~2029년 초.

   현재 모든 플랜 is_publicly_available = false.
   1호점 테스트베드 (2027년 9월) 운영 후
   점진적 활성화.';


-- =============================================
-- subscription_invoices table
-- 구독 청구서
-- =============================================
create table if not exists
  catchmenu_common.subscription_invoices (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),

  -- 청구서 정보
  invoice_number text not null unique,
  invoice_type text not null default 'SUBSCRIPTION',
  plan_code text not null,
  plan_tier text not null,

  -- 청구 기간
  billing_period_start date not null,
  billing_period_end date not null,

  -- 금액
  base_amount int not null default 0,
  addon_amount int not null default 0,
  discount_amount int not null default 0,
  tax_amount int not null default 0,
  total_amount int not null default 0,
  currency text not null default 'KRW',

  -- 상태
  invoice_status text not null default 'DRAFT',
  due_date date,
  paid_at timestamptz,
  payment_method text,
  payment_reference text,

  -- 메모
  invoice_note text,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint chk_invoice_type check (
    invoice_type in (
      'SUBSCRIPTION', 'ADDON',
      'SETUP_FEE', 'REFUND', 'CREDIT'
    )
  ),
  constraint chk_invoice_status check (
    invoice_status in (
      'DRAFT', 'ISSUED', 'PAID',
      'OVERDUE', 'CANCELLED', 'REFUNDED'
    )
  )
);

create index if not exists idx_invoices_tenant
  on catchmenu_common.subscription_invoices(
    tenant_id, billing_period_start desc
  );
create index if not exists idx_invoices_status
  on catchmenu_common.subscription_invoices(
    invoice_status, due_date
  ) where invoice_status in (
    'ISSUED', 'OVERDUE'
  );

alter table catchmenu_common.subscription_invoices
  enable row level security;
alter table catchmenu_common.subscription_invoices
  force row level security;

drop policy if exists invoices_isolation
  on catchmenu_common.subscription_invoices;
create policy invoices_isolation
  on catchmenu_common.subscription_invoices
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
  );

drop trigger if exists trg_invoices_updated
  on catchmenu_common.subscription_invoices;
create trigger trg_invoices_updated
  before update on
    catchmenu_common.subscription_invoices
  for each row execute function
    catchmenu_common.set_updated_at();

comment on table
  catchmenu_common.subscription_invoices is
  'SaaS 구독 청구서.
   월 구독: 1일~말일.
   invoice_number: INV-{YYYYMM}-{SEQ}.
   특허4: 청구서 = 감사 추적 가능 금융 원장.
   SaaS 출시 전에는 내부 테스트용으로만 사용.';


-- =============================================
-- usage_records table
-- SaaS 사용량 추적
-- =============================================
create table if not exists
  catchmenu_common.usage_records (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid,

  -- 사용량 기간
  usage_date date not null,
  usage_month text not null,

  -- 사용량
  order_count int not null default 0,
  takeout_order_count int not null default 0,
  delivery_order_count int not null default 0,
  customer_count int not null default 0,
  new_customer_count int not null default 0,
  kds_ticket_count int not null default 0,
  ai_query_count int not null default 0,
  menu_item_count int not null default 0,
  active_staff_count int not null default 0,

  -- 매출
  gross_revenue int not null default 0,
  net_revenue int not null default 0,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint uq_usage_date unique (
    tenant_id, store_id, usage_date
  )
);

create index if not exists idx_usage_tenant_month
  on catchmenu_common.usage_records(
    tenant_id, usage_month
  );

alter table catchmenu_common.usage_records
  enable row level security;
alter table catchmenu_common.usage_records
  force row level security;

drop policy if exists usage_records_isolation
  on catchmenu_common.usage_records;
create policy usage_records_isolation
  on catchmenu_common.usage_records
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
  );

drop trigger if exists trg_usage_records_updated
  on catchmenu_common.usage_records;
create trigger trg_usage_records_updated
  before update on catchmenu_common.usage_records
  for each row execute function
    catchmenu_common.set_updated_at();


-- =============================================
-- tenant_onboarding_log table
-- 테넌트 온보딩 단계 추적
-- =============================================
create table if not exists
  catchmenu_common.tenant_onboarding_log (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),

  -- 온보딩 단계
  onboarding_step text not null,
  step_status text not null default 'PENDING',
  step_order int not null,

  -- 완료 정보
  completed_at timestamptz,
  completed_by text,
  step_data jsonb default '{}'::jsonb,
  step_note text,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint uq_onboarding_step unique (
    tenant_id, onboarding_step
  ),
  constraint chk_step_status check (
    step_status in (
      'PENDING', 'IN_PROGRESS',
      'COMPLETED', 'SKIPPED', 'FAILED'
    )
  )
);

alter table catchmenu_common.tenant_onboarding_log
  enable row level security;
alter table catchmenu_common.tenant_onboarding_log
  force row level security;

drop policy if exists onboarding_isolation
  on catchmenu_common.tenant_onboarding_log;
create policy onboarding_isolation
  on catchmenu_common.tenant_onboarding_log
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
  );

drop trigger if exists trg_onboarding_updated
  on catchmenu_common.tenant_onboarding_log;
create trigger trg_onboarding_updated
  before update on
    catchmenu_common.tenant_onboarding_log
  for each row execute function
    catchmenu_common.set_updated_at();

comment on table
  catchmenu_common.tenant_onboarding_log is
  '테넌트 온보딩 단계 추적.
   온보딩 단계:
   1. TENANT_CREATED
   2. STORE_CREATED
   3. MENU_UPLOADED
   4. DEVICE_REGISTERED
   5. STAFF_REGISTERED
   6. POS_CONNECTED
   7. TEST_ORDER_PLACED
   8. PAYMENT_TESTED
   9. KDS_VERIFIED
   10. GO_LIVE
   각 단계 완료 → SaaS 활성화 진행도 추적.';


-- =============================================
-- RPCs
-- =============================================
create or replace function
  catchmenu_common.provision_tenant(
  p_tenant_code text,
  p_tenant_name text,
  p_owner_name text,
  p_owner_email text,
  p_owner_phone text,
  p_plan_code text,
  p_store_name text,
  p_store_timezone text default 'Asia/Seoul',
  p_sales_channel text default 'DIRECT',
  p_white_label_partner_code text default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_common,
                  catchmenu_hq,
                  catchmenu_store,
                  catchmenu_ledger
as $$
declare
  v_tenant_id uuid;
  v_store_id uuid;
  v_plan record;
  v_settings_id uuid;
  v_business_day date;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  -- 플랜 조회
  select id, plan_code, plan_tier,
         monthly_fee, included_features,
         max_stores, max_devices_per_store
  into v_plan
  from catchmenu_common.subscription_plans
  where plan_code = p_plan_code
    and is_active = true;

  if v_plan.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'plan_not_found',
      'plan_code', p_plan_code
    );
  end if;

  -- 테넌트 생성
  insert into catchmenu_hq.tenants (
    tenant_code, tenant_name,
    owner_name, owner_email, owner_phone,
    tenant_status
  ) values (
    p_tenant_code, p_tenant_name,
    p_owner_name, p_owner_email, p_owner_phone,
    'ACTIVE'
  )
  returning id into v_tenant_id;

  -- 테넌트 플랜 설정
  insert into catchmenu_common.tenant_plan_configs (
    tenant_id, plan_tier, plan_status,
    monthly_fee,
    trial_ends_at,
    enabled_features,
    max_stores,
    is_white_label,
    white_label_partner_code,
    sales_channel
  ) values (
    v_tenant_id,
    v_plan.plan_tier,
    case v_plan.plan_code
      when 'TRIAL_30' then 'TRIAL'
      else 'ACTIVE'
    end,
    v_plan.monthly_fee,
    case v_plan.plan_code
      when 'TRIAL_30'
        then now() + interval '30 days'
      else null
    end,
    v_plan.included_features,
    v_plan.max_stores,
    p_white_label_partner_code is not null,
    p_white_label_partner_code,
    p_sales_channel
  );

  -- 1호 매장 생성
  insert into catchmenu_hq.stores (
    tenant_id,
    store_code, store_name,
    store_type, store_status,
    timezone
  ) values (
    v_tenant_id,
    p_tenant_code || '_S01',
    p_store_name,
    'RESTAURANT', 'ACTIVE',
    p_store_timezone
  )
  returning id into v_store_id;

  -- 매장 기본 설정
  insert into catchmenu_store.store_settings (
    tenant_id, store_id,
    store_mode, waiting_enabled,
    pre_order_enabled,
    kds_capacity_threshold_total,
    did_refresh_interval_seconds
  ) values (
    v_tenant_id, v_store_id,
    'NORMAL', true, true,
    30, 10
  )
  returning id into v_settings_id;

  -- 온보딩 단계 초기화
  insert into
    catchmenu_common.tenant_onboarding_log (
    tenant_id, onboarding_step,
    step_status, step_order
  )
  select
    v_tenant_id,
    step_name, 'COMPLETED', step_order
  from (
    values
    ('TENANT_CREATED', 1),
    ('STORE_CREATED', 2)
  ) as steps(step_name, step_order)
  union all
  select
    v_tenant_id,
    step_name, 'PENDING', step_order
  from (
    values
    ('MENU_UPLOADED', 3),
    ('DEVICE_REGISTERED', 4),
    ('STAFF_REGISTERED', 5),
    ('POS_CONNECTED', 6),
    ('TEST_ORDER_PLACED', 7),
    ('PAYMENT_TESTED', 8),
    ('KDS_VERIFIED', 9),
    ('GO_LIVE', 10)
  ) as steps(step_name, step_order);

  -- ledger event
  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, event_payload,
    correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    v_tenant_id, v_store_id,
    'system', 'tenant_provisioned', 1,
    'tenant', v_tenant_id,
    null, 'ACTIVE',
    'SYSTEM',
    jsonb_build_object(
      'tenant_code', p_tenant_code,
      'plan_code', p_plan_code,
      'plan_tier', v_plan.plan_tier,
      'sales_channel', p_sales_channel,
      'white_label',
        p_white_label_partner_code is not null
    ),
    p_correlation_id,
    v_business_day, 'Asia/Seoul', now()
  );

  -- 진단 로그
  perform catchmenu_common.log_diagnostic(
    p_tenant_id := v_tenant_id,
    p_store_id := v_store_id,
    p_log_level := 'INFO',
    p_log_domain := 'SYSTEM',
    p_log_event := 'tenant_provisioned',
    p_message :=
      '테넌트 프로비저닝 완료: '
      || p_tenant_name
      || ' | 플랜: ' || p_plan_code
      || ' | 채널: ' || p_sales_channel,
    p_rpc_name := 'provision_tenant',
    p_correlation_id := p_correlation_id,
    p_details := jsonb_build_object(
      'tenant_id', v_tenant_id,
      'store_id', v_store_id,
      'plan_code', p_plan_code
    )
  );

  return jsonb_build_object(
    'success', true,
    'tenant_id', v_tenant_id,
    'store_id', v_store_id,
    'tenant_code', p_tenant_code,
    'plan_tier', v_plan.plan_tier,
    'plan_status', case v_plan.plan_code
      when 'TRIAL_30' then 'TRIAL'
      else 'ACTIVE'
    end,
    'trial_ends_at', case v_plan.plan_code
      when 'TRIAL_30'
        then (now() + interval '30 days')
      else null
    end,
    'onboarding_steps', jsonb_build_object(
      'completed', 2,
      'total', 10,
      'next_step', 'MENU_UPLOADED'
    ),
    'message_code', 'tenant_provisioned'
  );
end;
$$;


create or replace function
  catchmenu_common.activate_subscription(
  p_tenant_id uuid,
  p_plan_code text,
  p_payment_method text,
  p_payment_reference text default null,
  p_white_label_partner_code text default null,
  p_actor_id uuid default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_common,
                  catchmenu_ledger,
                  catchmenu_audit
as $$
declare
  v_plan record;
  v_invoice_id uuid;
  v_invoice_number text;
  v_invoice_seq int;
  v_business_day date;
  v_period_start date;
  v_period_end date;
  v_audit_id uuid;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  v_period_start := date_trunc(
    'month', v_business_day
  )::date;
  v_period_end := (date_trunc(
    'month', v_business_day
  ) + interval '1 month - 1 day')::date;

  -- 플랜 조회
  select id, plan_code, plan_tier,
         monthly_fee, included_features,
         max_stores
  into v_plan
  from catchmenu_common.subscription_plans
  where plan_code = p_plan_code
    and is_active = true;

  if v_plan.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'plan_not_found'
    );
  end if;

  -- 테넌트 플랜 업데이트
  update catchmenu_common.tenant_plan_configs
  set
    plan_tier = v_plan.plan_tier,
    plan_status = 'ACTIVE',
    monthly_fee = v_plan.monthly_fee,
    enabled_features = v_plan.included_features,
    max_stores = v_plan.max_stores,
    subscription_starts_at = now(),
    trial_ends_at = null,
    is_white_label =
      p_white_label_partner_code is not null,
    white_label_partner_code =
      p_white_label_partner_code,
    updated_at = now()
  where tenant_id = p_tenant_id;

  if not found then
    return jsonb_build_object(
      'success', false,
      'error_key', 'plan_not_configured',
      'tenant_id', p_tenant_id
    );
  end if;

  -- 인보이스 번호 생성
  select coalesce(
    max(
      (regexp_match(
        invoice_number, '\d+$'
      ))[1]::int
    ), 0
  ) + 1
  into v_invoice_seq
  from catchmenu_common.subscription_invoices
  where to_char(created_at, 'YYYYMM')
    = to_char(now(), 'YYYYMM');

  v_invoice_number := 'INV-'
    || to_char(now(), 'YYYYMM')
    || '-'
    || lpad(v_invoice_seq::text, 4, '0');

  -- 인보이스 생성
  insert into
    catchmenu_common.subscription_invoices (
    tenant_id, invoice_number,
    invoice_type, plan_code, plan_tier,
    billing_period_start, billing_period_end,
    base_amount, total_amount, currency,
    invoice_status, due_date,
    paid_at, payment_method, payment_reference
  ) values (
    p_tenant_id, v_invoice_number,
    'SUBSCRIPTION', p_plan_code, v_plan.plan_tier,
    v_period_start, v_period_end,
    v_plan.monthly_fee, v_plan.monthly_fee, 'KRW',
    case when v_plan.monthly_fee = 0
      then 'PAID'
      else 'ISSUED'
    end,
    v_period_end,
    case when v_plan.monthly_fee = 0
      then now() else null
    end,
    p_payment_method, p_payment_reference
  )
  returning id into v_invoice_id;

  -- ledger event
  insert into catchmenu_ledger.events (
    tenant_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, caused_by_id,
    event_payload, correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id,
    'system', 'subscription_activated', 1,
    'tenant_plan', p_tenant_id,
    null, 'ACTIVE',
    'SYSTEM', p_actor_id,
    jsonb_build_object(
      'plan_code', p_plan_code,
      'plan_tier', v_plan.plan_tier,
      'monthly_fee', v_plan.monthly_fee,
      'invoice_id', v_invoice_id,
      'invoice_number', v_invoice_number
    ),
    p_correlation_id,
    v_business_day, 'Asia/Seoul', now()
  );

  -- audit
  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_audit_domain := 'system',
    p_audit_type := 'subscription_activated',
    p_audit_category := 'FINANCIAL',
    p_actor_type := 'SYSTEM',
    p_actor_id := p_actor_id,
    p_subject_type := 'tenant_plan',
    p_subject_id := p_tenant_id,
    p_decision := 'APPROVED',
    p_decision_payload := jsonb_build_object(
      'plan_code', p_plan_code,
      'monthly_fee', v_plan.monthly_fee,
      'invoice_number', v_invoice_number
    ),
    p_correlation_id := p_correlation_id,
    p_business_day := v_business_day,
    p_business_timezone := 'Asia/Seoul'
  );

  return jsonb_build_object(
    'success', true,
    'tenant_id', p_tenant_id,
    'plan_code', p_plan_code,
    'plan_tier', v_plan.plan_tier,
    'monthly_fee', v_plan.monthly_fee,
    'invoice_id', v_invoice_id,
    'invoice_number', v_invoice_number,
    'period_start', v_period_start,
    'period_end', v_period_end,
    'audit_id', v_audit_id,
    'message_code', 'subscription_activated'
  );
end;
$$;


create or replace function
  catchmenu_common.record_usage(
  p_tenant_id uuid,
  p_store_id uuid,
  p_usage_date date default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_common,
                  catchmenu_pos,
                  catchmenu_payment,
                  catchmenu_kds,
                  catchmenu_store,
                  catchmenu_knowledge
as $$
declare
  v_target_date date;
  v_usage_month text;
  v_order_count int;
  v_takeout_count int;
  v_delivery_count int;
  v_customer_count int;
  v_new_customer_count int;
  v_kds_count int;
  v_ai_count int;
  v_menu_count int;
  v_staff_count int;
  v_gross_revenue int;
  v_net_revenue int;
begin
  v_target_date := coalesce(
    p_usage_date,
    (timezone('Asia/Seoul', now()))::date
  );
  v_usage_month := to_char(v_target_date, 'YYYYMM');

  -- 집계
  select
    count(*) filter (
      where order_status = 'COMPLETED'
    ),
    count(*) filter (
      where order_type = 'TAKEOUT'
        and order_status = 'COMPLETED'
    ),
    count(*) filter (
      where order_type = 'DELIVERY'
        and order_status = 'COMPLETED'
    )
  into v_order_count, v_takeout_count,
       v_delivery_count
  from catchmenu_pos.orders
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_target_date;

  -- 고객
  select
    count(distinct customer_id) filter (
      where customer_id is not null
    ),
    count(distinct c.id) filter (
      where c.created_at::date = v_target_date
    )
  into v_customer_count, v_new_customer_count
  from catchmenu_pos.order_sessions os
  left join catchmenu_store.customers c
    on c.id = os.customer_id
  where os.store_id = p_store_id
    and os.tenant_id = p_tenant_id
    and os.business_day = v_target_date;

  -- KDS
  select count(*)
  into v_kds_count
  from catchmenu_kds.kds_tickets
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_target_date;

  -- AI 쿼리
  select count(*)
  into v_ai_count
  from catchmenu_knowledge.ai_query_logs
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and query_date = v_target_date;

  -- 메뉴
  select count(*)
  into v_menu_count
  from catchmenu_pos.menus
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and is_active = true;

  -- 직원
  select count(distinct staff_id)
  into v_staff_count
  from catchmenu_store.staff_shifts
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and shift_date = v_target_date
    and shift_status in (
      'CLOCKED_IN', 'CLOCKED_OUT'
    );

  -- 매출
  select
    coalesce(sum(approved_amount), 0),
    coalesce(sum(net_amount), 0)
  into v_gross_revenue, v_net_revenue
  from catchmenu_payment.payment_ledger
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_target_date
    and ledger_status = 'APPROVED';

  -- upsert
  insert into catchmenu_common.usage_records (
    tenant_id, store_id,
    usage_date, usage_month,
    order_count, takeout_order_count,
    delivery_order_count,
    customer_count, new_customer_count,
    kds_ticket_count, ai_query_count,
    menu_item_count, active_staff_count,
    gross_revenue, net_revenue
  ) values (
    p_tenant_id, p_store_id,
    v_target_date, v_usage_month,
    coalesce(v_order_count, 0),
    coalesce(v_takeout_count, 0),
    coalesce(v_delivery_count, 0),
    coalesce(v_customer_count, 0),
    coalesce(v_new_customer_count, 0),
    coalesce(v_kds_count, 0),
    coalesce(v_ai_count, 0),
    coalesce(v_menu_count, 0),
    coalesce(v_staff_count, 0),
    coalesce(v_gross_revenue, 0),
    coalesce(v_net_revenue, 0)
  )
  on conflict (tenant_id, store_id, usage_date)
  do update set
    order_count = excluded.order_count,
    takeout_order_count =
      excluded.takeout_order_count,
    delivery_order_count =
      excluded.delivery_order_count,
    customer_count = excluded.customer_count,
    new_customer_count =
      excluded.new_customer_count,
    kds_ticket_count = excluded.kds_ticket_count,
    ai_query_count = excluded.ai_query_count,
    menu_item_count = excluded.menu_item_count,
    active_staff_count =
      excluded.active_staff_count,
    gross_revenue = excluded.gross_revenue,
    net_revenue = excluded.net_revenue,
    updated_at = now();

  return jsonb_build_object(
    'success', true,
    'usage_date', v_target_date,
    'usage_month', v_usage_month,
    'summary', jsonb_build_object(
      'order_count', v_order_count,
      'takeout_count', v_takeout_count,
      'customer_count', v_customer_count,
      'gross_revenue', v_gross_revenue,
      'ai_query_count', v_ai_count
    ),
    'message_code', 'usage_recorded'
  );
end;
$$;


-- add_check was originally (incorrectly) written as a nested procedure
-- inside check_saas_readiness's DECLARE section -- same invalid pattern
-- as 0073's assert_true (PL/pgSQL has no nested-subprogram syntax).
-- Fixed the same way: a real standalone function (not a procedure --
-- CALL cannot reliably take arbitrary expression arguments the way this
-- function's is_feature_enabled(...) or ... conditions do), logging to
-- a temp table since a standalone routine can't mutate
-- check_saas_readiness's local variables directly. All 10
-- `perform add_saas_check(...)` sites below were mechanically changed to
-- `perform add_saas_check(...)` -- no argument list touched.
create temp table if not exists saas_readiness_checks (
  ordinal bigint generated always as identity,
  check_name text,
  passed boolean,
  category text,
  note text
);

create or replace function catchmenu_common.add_saas_check(
  p_check text,
  p_passed boolean,
  p_category text,
  p_note text default null
)
returns void
language plpgsql
as $$
begin
  insert into pg_temp.saas_readiness_checks (check_name, passed, category, note)
    values (p_check, p_passed, p_category, p_note);
end;
$$;

create or replace function
  catchmenu_common.check_saas_readiness(
  p_tenant_id uuid
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_common,
                  catchmenu_hq,
                  catchmenu_store,
                  catchmenu_pos
as $$
declare
  v_checks jsonb := '[]'::jsonb;
  v_passed int := 0;
  v_failed int := 0;
  v_plan record;
  v_store_count int;
  v_menu_count int;
  v_device_count int;
begin
  delete from pg_temp.saas_readiness_checks;

  -- 플랜 정보
  select plan_tier, plan_status,
         enabled_features
  into v_plan
  from catchmenu_common.tenant_plan_configs
  where tenant_id = p_tenant_id;

  -- CHECK 1: 플랜 설정
  perform add_saas_check(
    '플랜 구성 완료',
    v_plan.plan_tier is not null,
    'BILLING',
    '현재 플랜: '
      || coalesce(v_plan.plan_tier, 'NONE')
  );

  -- CHECK 2: 매장 설정
  select count(*) into v_store_count
  from catchmenu_hq.stores
  where tenant_id = p_tenant_id
    and is_active = true;

  perform add_saas_check(
    '매장 1개 이상 등록',
    v_store_count >= 1,
    'SETUP',
    '등록 매장 수: ' || v_store_count
  );

  -- CHECK 3: 메뉴 등록
  select count(*) into v_menu_count
  from catchmenu_pos.menus m
  join catchmenu_hq.stores s
    on s.id = m.store_id
  where s.tenant_id = p_tenant_id
    and m.is_active = true;

  perform add_saas_check(
    '메뉴 5개 이상 등록',
    v_menu_count >= 5,
    'SETUP',
    '등록 메뉴 수: ' || v_menu_count
  );

  -- CHECK 4: 디바이스 등록
  select count(*) into v_device_count
  from catchmenu_store.device_registry d
  join catchmenu_hq.stores s
    on s.id = d.store_id
  where s.tenant_id = p_tenant_id
    and d.trust_level = 'TRUSTED'
    and d.is_active = true;

  perform add_saas_check(
    'TRUSTED 디바이스 1개 이상',
    v_device_count >= 1,
    'SETUP',
    'TRUSTED 디바이스 수: ' || v_device_count
  );

  -- CHECK 5: POS 연동
  perform add_saas_check(
    'OKpos 또는 토스POS 연동',
    catchmenu_common.is_feature_enabled(
      p_tenant_id, 'OKPOS_INTEGRATION'
    ) or catchmenu_common.is_feature_enabled(
      p_tenant_id, 'TOSS_POS_INTEGRATION'
    ),
    'INTEGRATION',
    '1차 POS 연동 필수'
  );

  -- CHECK 6: 포장 주문 기능
  perform add_saas_check(
    '포장 주문 기능 활성화',
    catchmenu_common.is_feature_enabled(
      p_tenant_id, 'TAKEOUT_ORDER'
    ),
    'FEATURE',
    '포장 주문 = 월 1만원 핵심 가치'
  );

  -- CHECK 7: 고객 앱 (PRO 요건)
  perform add_saas_check(
    '고객 멤버십 앱 (PRO 필수)',
    catchmenu_common.is_feature_enabled(
      p_tenant_id, 'CUSTOMER_MEMBERSHIP_APP'
    ),
    'SAAS_REQUIRED',
    'SaaS 판매 필수 기능 (1-B차)'
  );

  -- CHECK 8: 배달 연동 (PRO 요건)
  perform add_saas_check(
    '배달앱 연동 (PRO 필수)',
    catchmenu_common.is_feature_enabled(
      p_tenant_id, 'DELIVERY_INTEGRATION'
    ),
    'SAAS_REQUIRED',
    'SaaS 판매 필수 기능 (1-B차)'
  );

  -- CHECK 9: AI 고객센터 (SaaS 핵심 요건)
  perform add_saas_check(
    'AI 고객센터 (SaaS 판매 핵심 필수)',
    catchmenu_common.is_feature_enabled(
      p_tenant_id, 'AI_CUSTOMER_CENTER'
    ),
    'SAAS_REQUIRED',
    'SaaS 판매 핵심 요건 (5차). '
    || '예상: 2028년 중~2029년 초.'
  );

  -- CHECK 10: 디지털 SOP
  perform add_saas_check(
    '디지털 SOP (PRO 필수)',
    catchmenu_common.is_feature_enabled(
      p_tenant_id, 'DIGITAL_SOP'
    ),
    'SAAS_REQUIRED',
    'SaaS 판매 필수 기능 (5차)'
  );

  -- populate v_checks/v_passed/v_failed from the temp table now that
  -- all add_saas_check() calls above have logged into it
  select
    coalesce(jsonb_agg(
      jsonb_build_object(
        'check', check_name,
        'category', category,
        'status', case passed when true then 'PASS' else 'FAIL' end,
        'note', note
      )
      order by ordinal
    ), '[]'::jsonb),
    count(*) filter (where passed),
    count(*) filter (where not passed)
  into v_checks, v_passed, v_failed
  from pg_temp.saas_readiness_checks;

  -- SaaS 준비 완료 여부
  declare
    v_saas_required_passed boolean;
  begin
    select bool_and(
      case c->>'category'
        when 'SAAS_REQUIRED'
        then c->>'status' = 'PASS'
        else true
      end
    )
    into v_saas_required_passed
    from jsonb_array_elements(v_checks) c;

    return jsonb_build_object(
      'success', true,
      'tenant_id', p_tenant_id,
      'plan_tier', v_plan.plan_tier,
      'total_checks', v_passed + v_failed,
      'passed', v_passed,
      'failed', v_failed,
      'saas_ready', v_saas_required_passed,
      'setup_ready', (
        select bool_and(
          c->>'status' = 'PASS'
        )
        from jsonb_array_elements(v_checks) c
        where c->>'category' in (
          'BILLING', 'SETUP', 'INTEGRATION',
          'FEATURE'
        )
      ),
      'checks', v_checks,
      'saas_launch_estimate',
        '2028년 중~2029년 초 (AI 고객센터 완성 후)',
      'current_phase', case
        when v_passed <= 3 then 'SETUP'
        when v_passed <= 6 then 'PHASE_1'
        when v_passed <= 8 then 'PHASE_1B'
        else 'PHASE_5_READY'
      end,
      'message_code', case
        when v_saas_required_passed
          then 'saas_ready'
          else 'saas_not_ready'
      end
    );
  end;
end;
$$;


create or replace function
  catchmenu_common.get_saas_dashboard(
  p_tenant_id uuid,
  p_period_months int default 3
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_common,
                  catchmenu_hq
as $$
declare
  v_plan record;
  v_onboarding jsonb;
  v_usage_summary jsonb;
  v_invoices jsonb;
  v_store_count int;
  v_period_start date;
begin
  v_period_start := (date_trunc(
    'month', now()
  ) - ((p_period_months - 1)
    || ' months')::interval
  )::date;

  -- 플랜 정보
  select plan_tier, plan_status,
         monthly_fee, enabled_features,
         max_stores, trial_ends_at,
         subscription_starts_at,
         is_white_label,
         white_label_partner_code
  into v_plan
  from catchmenu_common.tenant_plan_configs
  where tenant_id = p_tenant_id;

  -- 온보딩 진행률
  select jsonb_build_object(
    'total', count(*),
    'completed', count(*) filter (
      where step_status = 'COMPLETED'
    ),
    'completion_pct', (
      count(*) filter (
        where step_status = 'COMPLETED'
      )::numeric / count(*) * 100
    )::int,
    'next_step', (
      select onboarding_step
      from catchmenu_common
        .tenant_onboarding_log
      where tenant_id = p_tenant_id
        and step_status = 'PENDING'
      order by step_order
      limit 1
    )
  )
  into v_onboarding
  from catchmenu_common.tenant_onboarding_log
  where tenant_id = p_tenant_id;

  -- 매장 수
  select count(*) into v_store_count
  from catchmenu_hq.stores
  where tenant_id = p_tenant_id
    and is_active = true;

  -- 기간별 사용량
  select jsonb_build_object(
    'total_orders',
      coalesce(sum(order_count), 0),
    'total_takeout',
      coalesce(sum(takeout_order_count), 0),
    'total_delivery',
      coalesce(sum(delivery_order_count), 0),
    'total_customers',
      coalesce(sum(customer_count), 0),
    'total_revenue',
      coalesce(sum(gross_revenue), 0),
    'total_ai_queries',
      coalesce(sum(ai_query_count), 0),
    'period_months', p_period_months
  )
  into v_usage_summary
  from catchmenu_common.usage_records
  where tenant_id = p_tenant_id
    and usage_date >= v_period_start;

  -- 최근 인보이스
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'invoice_number', invoice_number,
        'plan_tier', plan_tier,
        'total_amount', total_amount,
        'invoice_status', invoice_status,
        'billing_period_start',
          billing_period_start,
        'billing_period_end',
          billing_period_end,
        'paid_at', paid_at
      )
      order by billing_period_start desc
    ),
    '[]'::jsonb
  )
  into v_invoices
  from catchmenu_common.subscription_invoices
  where tenant_id = p_tenant_id
  limit 6;

  return jsonb_build_object(
    'success', true,
    'tenant_id', p_tenant_id,

    -- 구독 상태
    'subscription', jsonb_build_object(
      'plan_tier', v_plan.plan_tier,
      'plan_status', v_plan.plan_status,
      'monthly_fee', v_plan.monthly_fee,
      'enabled_feature_count',
        jsonb_array_length(
          coalesce(v_plan.enabled_features,
            '[]'::jsonb)
        ),
      'max_stores', v_plan.max_stores,
      'current_stores', v_store_count,
      'trial_ends_at', v_plan.trial_ends_at,
      'subscription_starts_at',
        v_plan.subscription_starts_at,
      'is_white_label', v_plan.is_white_label,
      'white_label_partner',
        v_plan.white_label_partner_code
    ),

    -- 온보딩
    'onboarding', v_onboarding,

    -- 사용량
    'usage', v_usage_summary,

    -- 청구서
    'invoices', v_invoices,

    -- SaaS 준비도
    'saas_readiness', (
      catchmenu_common.check_saas_readiness(
        p_tenant_id
      )
    ),

    'generated_at', now(),
    'message_code', 'saas_dashboard_loaded'
  );
end;
$$;


-- pg_cron: 일일 사용량 기록
insert into catchmenu_common.pg_cron_jobs (
  job_code, pg_cron_job_name,
  schedule_cron_utc, schedule_cron_kst,
  sql_command, notes
) values
(
  'DAILY_USAGE_RECORD',
  'catchmenu_daily_usage',
  '30 15 * * *',
  '30 0 * * * (매일 자정 30분 KST)',
  $sql$
SELECT catchmenu_common.record_usage(
  p_tenant_id :=
    '00000000-0000-0000-0000-000000000001'::uuid,
  p_store_id :=
    '00000000-0000-0000-0000-000000000002'::uuid
);
$sql$,
  '일일 사용량 집계 기록. 매일 자정 30분 KST.'
)
on conflict (job_code) do nothing;


-- grants
do $$
begin
  revoke all on function
    catchmenu_common.provision_tenant(
      text, text, text, text, text,
      text, text, text, text, text, text
    ) from public;
  grant execute on function
    catchmenu_common.provision_tenant(
      text, text, text, text, text,
      text, text, text, text, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_common.activate_subscription(
      uuid, text, text, text, text, uuid, text
    ) from public;
  grant execute on function
    catchmenu_common.activate_subscription(
      uuid, text, text, text, text, uuid, text
    ) to authenticated;

  revoke all on function
    catchmenu_common.record_usage(uuid, uuid, date)
    from public;
  grant execute on function
    catchmenu_common.record_usage(uuid, uuid, date)
    to authenticated;

  revoke all on function
    catchmenu_common.check_saas_readiness(uuid)
    from public;
  grant execute on function
    catchmenu_common.check_saas_readiness(uuid)
    to authenticated;

  revoke all on function
    catchmenu_common.get_saas_dashboard(uuid, int)
    from public;
  grant execute on function
    catchmenu_common.get_saas_dashboard(uuid, int)
    to authenticated;

  grant select on
    catchmenu_common.subscription_plans
    to authenticated;
end;
$$;

comment on function
  catchmenu_common.check_saas_readiness(uuid) is
  'SaaS 판매 준비 체크리스트 (10개 항목).
   카테고리:
   BILLING: 플랜 구성
   SETUP: 매장/메뉴/디바이스
   INTEGRATION: POS 연동
   FEATURE: 기능 활성화
   SAAS_REQUIRED: SaaS 판매 필수 요건

   saas_ready = true 조건:
   SAAS_REQUIRED 항목 전부 PASS.
   현재 필수 항목:
   - CUSTOMER_MEMBERSHIP_APP (1-B차)
   - DELIVERY_INTEGRATION (1-B차)
   - AI_CUSTOMER_CENTER (5차) ← 핵심
   - DIGITAL_SOP (5차)

   예상 saas_ready: 2028년 중~2029년 초.
   1호점 오픈: 2027년 9월.
   setup_ready = true: 1호점 운영 가능.';

comment on function
  catchmenu_common.provision_tenant(
    text, text, text, text, text,
    text, text, text, text, text, text
  ) is
  '신규 테넌트 프로비저닝.
   생성 항목:
   1. 테넌트 (tenants)
   2. 테넌트 플랜 (tenant_plan_configs)
   3. 1호 매장 (stores)
   4. 매장 기본 설정 (store_settings)
   5. 온보딩 단계 초기화 (10단계)
   sales_channel:
     DIRECT: 직접 영업
     WHITE_LABEL: 가맹점 본사 협상
     POS_BUNDLE: OKpos/토스POS 번들
   온보딩 완료 후 GO_LIVE 단계
   → 실제 운영 시작.';