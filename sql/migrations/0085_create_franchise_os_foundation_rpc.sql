-- 0085_create_franchise_os_foundation_rpc.sql
-- Purpose: Franchise_OS foundation RPCs.
--          Brand/franchise hierarchy management,
--          store policy distribution,
--          franchise KPI tracking,
--          HQ approval workflow foundation.
--          3차 Franchise_OS 사전 작업.
--          i18n: 모든 메시지 = message_catalog 참조.
-- Depends on: 0084_create_reconciliation_advanced_rpc.sql
-- Creates:
--   catchmenu_hq.franchise_brands (table)
--   catchmenu_hq.franchise_policies (table)
--   catchmenu_hq.franchise_policy_assignments (table)
--   catchmenu_hq.franchise_kpi_targets (table)
--   catchmenu_hq.franchise_approval_requests (table)
--   function catchmenu_hq.create_franchise_brand(...)
--   function catchmenu_hq.assign_store_to_brand(...)
--   function catchmenu_hq.publish_franchise_policy(...)
--   function catchmenu_hq.apply_policy_to_stores(...)
--   function catchmenu_hq.request_hq_approval(...)
--   function catchmenu_hq.process_hq_approval(...)
--   function catchmenu_hq.get_franchise_dashboard(...)

-- =============================================
-- i18n message catalog 추가
-- 모든 메시지 키 사전 등록
-- =============================================
insert into catchmenu_common.message_catalog (
  message_key, locale, message_text
) values
-- franchise 도메인
('franchise_brand_created', 'ko',
  '프랜차이즈 브랜드가 생성되었습니다'),
('franchise_brand_created', 'en',
  'Franchise brand created'),
('store_assigned_to_brand', 'ko',
  '매장이 브랜드에 배정되었습니다'),
('store_assigned_to_brand', 'en',
  'Store assigned to brand'),
('franchise_policy_published', 'ko',
  '프랜차이즈 정책이 배포되었습니다'),
('franchise_policy_published', 'en',
  'Franchise policy published'),
('policy_applied_to_stores', 'ko',
  '{store_count}개 매장에 정책이 적용되었습니다'),
('policy_applied_to_stores', 'en',
  'Policy applied to {store_count} stores'),
('approval_requested', 'ko',
  '승인 요청이 접수되었습니다'),
('approval_requested', 'en',
  'Approval request submitted'),
('approval_approved', 'ko',
  '승인이 완료되었습니다'),
('approval_approved', 'en',
  'Request approved'),
('approval_rejected', 'ko',
  '승인이 거절되었습니다'),
('approval_rejected', 'en',
  'Request rejected'),
('franchise_dashboard_loaded', 'ko',
  '프랜차이즈 대시보드가 로드되었습니다'),
('franchise_dashboard_loaded', 'en',
  'Franchise dashboard loaded'),
-- kpi 관련
('kpi_target_set', 'ko',
  'KPI 목표가 설정되었습니다'),
('kpi_target_set', 'en',
  'KPI target set'),
('kpi_below_target', 'ko',
  'KPI가 목표치 이하입니다'),
('kpi_below_target', 'en',
  'KPI is below target'),
-- policy 관련
('policy_conflict_detected', 'ko',
  '정책 충돌이 감지되었습니다'),
('policy_conflict_detected', 'en',
  'Policy conflict detected'),
('policy_not_found', 'ko',
  '정책을 찾을 수 없습니다'),
('policy_not_found', 'en',
  'Policy not found'),
('brand_not_found', 'ko',
  '브랜드를 찾을 수 없습니다'),
('brand_not_found', 'en',
  'Brand not found'),
('approval_not_found', 'ko',
  '승인 요청을 찾을 수 없습니다'),
('approval_not_found', 'en',
  'Approval request not found'),
('approval_already_processed', 'ko',
  '이미 처리된 승인 요청입니다'),
('approval_already_processed', 'en',
  'Approval request already processed')
on conflict (message_key, locale) do nothing;

-- error_codes 추가
insert into catchmenu_common.error_codes (
  code, error_key, error_domain,
  error_category, http_status, severity
) values
(11005, 'brand_not_found',
  'FRANCHISE', 'NOT_FOUND', 404, 'WARNING'),
(11006, 'policy_not_found',
  'FRANCHISE', 'NOT_FOUND', 404, 'WARNING'),
(11007, 'approval_not_found',
  'FRANCHISE', 'NOT_FOUND', 404, 'WARNING'),
(11008, 'approval_already_processed',
  'FRANCHISE', 'CONFLICT', 409, 'WARNING'),
(11009, 'policy_conflict_detected',
  'FRANCHISE', 'CONFLICT', 409, 'WARNING'),
(11010, 'store_already_in_brand',
  'FRANCHISE', 'CONFLICT', 409, 'WARNING'),
(11011, 'kpi_target_not_found',
  'FRANCHISE', 'NOT_FOUND', 404, 'WARNING')
on conflict (code) do nothing;


-- =============================================
-- franchise_brands table
-- 프랜차이즈 브랜드 관리
-- =============================================
create table if not exists
  catchmenu_hq.franchise_brands (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),

  brand_code text not null,
  brand_name text not null,
  brand_type text not null default 'FRANCHISE',

  -- 브랜드 계층
  parent_brand_id uuid
    references catchmenu_hq.franchise_brands(id),
  brand_level int not null default 1,

  -- 본사 정보
  hq_store_id uuid
    references catchmenu_hq.stores(id),
  hq_contact_name text,
  hq_contact_email text,
  hq_contact_phone text,

  -- 계약 정보
  contract_start_date date,
  contract_end_date date,
  royalty_rate_pct numeric(5,2),

  -- 브랜드 설정
  brand_color text,
  brand_logo_url text,
  brand_guidelines_url text,

  -- 멤버십 공유
  shared_membership boolean
    not null default false,
  shared_menu_template boolean
    not null default false,

  -- 현황
  active_store_count int not null default 0,
  brand_status text not null default 'ACTIVE',

  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint uq_brand_code unique (
    tenant_id, brand_code
  ),
  constraint chk_brand_type check (
    brand_type in (
      'FRANCHISE', 'CHAIN',
      'VIRTUAL_BRAND', 'LICENSE'
    )
  ),
  constraint chk_brand_status check (
    brand_status in (
      'ACTIVE', 'SUSPENDED',
      'TERMINATED', 'PENDING'
    )
  )
);

create index if not exists idx_brands_tenant
  on catchmenu_hq.franchise_brands(
    tenant_id, brand_type
  ) where is_active = true;
create index if not exists idx_brands_parent
  on catchmenu_hq.franchise_brands(
    parent_brand_id
  ) where parent_brand_id is not null;

alter table catchmenu_hq.franchise_brands
  enable row level security;
alter table catchmenu_hq.franchise_brands
  force row level security;

drop policy if exists franchise_brands_isolation
  on catchmenu_hq.franchise_brands;
create policy franchise_brands_isolation
  on catchmenu_hq.franchise_brands
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
  );

drop trigger if exists trg_franchise_brands_updated
  on catchmenu_hq.franchise_brands;
create trigger trg_franchise_brands_updated
  before update on catchmenu_hq.franchise_brands
  for each row execute function
    catchmenu_common.set_updated_at();

comment on table catchmenu_hq.franchise_brands is
  '프랜차이즈 브랜드 관리.
   brand_level: 1=본사, 2=지역본부, 3=가맹점.
   FRANCHISE: 로열티 기반 가맹.
   CHAIN: 직영 체인.
   VIRTUAL_BRAND: 배달 전용 가상 브랜드.
   shared_membership: 브랜드 내 포인트 공유.
   3차 Franchise_OS 핵심 구조.
   4차에서 완전 구현.';


-- =============================================
-- franchise_policies table
-- 프랜차이즈 정책 정의
-- =============================================
create table if not exists
  catchmenu_hq.franchise_policies (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  brand_id uuid not null
    references catchmenu_hq.franchise_brands(id),

  -- 정책 식별
  policy_code text not null,
  policy_name text not null,
  policy_type text not null,
  policy_category text not null,

  -- 정책 내용
  policy_data jsonb not null
    default '{}'::jsonb,
  policy_description text,

  -- 버전 관리
  version_number int not null default 1,
  superseded_by uuid,
  supersedes uuid,

  -- 적용 범위
  applies_to text not null default 'ALL_STORES',
  target_store_ids jsonb default null,
  excluded_store_ids jsonb default '[]'::jsonb,

  -- 강제 적용 여부
  is_mandatory boolean not null default false,
  override_allowed boolean not null default false,

  -- 유효 기간
  effective_from date not null default current_date,
  effective_until date,

  -- 승인
  requires_hq_approval boolean
    not null default false,
  approved_by uuid,
  approved_at timestamptz,

  -- 상태
  policy_status text not null default 'DRAFT',
  published_at timestamptz,
  published_by uuid,

  created_by uuid,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint uq_policy_code unique (
    brand_id, policy_code, version_number
  ),
  constraint chk_policy_type check (
    policy_type in (
      'MENU',           -- 메뉴 정책
      'PRICING',        -- 가격 정책
      'OPERATION',      -- 운영 정책
      'QUALITY',        -- 품질 기준
      'PROMOTION',      -- 프로모션 정책
      'STAFF',          -- 직원 정책
      'COMPLIANCE',     -- 컴플라이언스
      'MEMBERSHIP',     -- 멤버십 정책
      'CUSTOM'
    )
  ),
  constraint chk_policy_status check (
    policy_status in (
      'DRAFT', 'REVIEW', 'APPROVED',
      'PUBLISHED', 'SUPERSEDED', 'ARCHIVED'
    )
  ),
  constraint chk_applies_to check (
    applies_to in (
      'ALL_STORES', 'SELECTED_STORES',
      'REGION', 'TIER'
    )
  )
);

create index if not exists idx_policies_brand
  on catchmenu_hq.franchise_policies(
    brand_id, policy_type, policy_status
  ) where is_active = true;

alter table catchmenu_hq.franchise_policies
  enable row level security;
alter table catchmenu_hq.franchise_policies
  force row level security;

drop policy if exists franchise_policies_isolation
  on catchmenu_hq.franchise_policies;
create policy franchise_policies_isolation
  on catchmenu_hq.franchise_policies
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
  );

drop trigger if exists trg_franchise_policies_updated
  on catchmenu_hq.franchise_policies;
create trigger trg_franchise_policies_updated
  before update on catchmenu_hq.franchise_policies
  for each row execute function
    catchmenu_common.set_updated_at();

comment on table
  catchmenu_hq.franchise_policies is
  '프랜차이즈 정책 정의.
   is_mandatory = true: 가맹점 강제 적용.
   override_allowed = true: 가맹점 예외 허용.
   version_number: 정책 버전 관리.
   supersedes: 이전 버전 연결.
   policy_data: 정책 상세 내용 (type별 다름).
   MENU 예: {allowed_menus: [...], restricted: [...]}.
   PRICING 예: {max_discount_pct: 10, ...}.
   3차 Franchise_OS 정책 배포 기반.';


-- =============================================
-- franchise_policy_assignments table
-- 매장별 정책 적용 현황
-- =============================================
create table if not exists
  catchmenu_hq.franchise_policy_assignments (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  policy_id uuid not null
    references catchmenu_hq.franchise_policies(id),
  store_id uuid not null
    references catchmenu_hq.stores(id),
  brand_id uuid not null
    references catchmenu_hq.franchise_brands(id),

  -- 적용 상태
  assignment_status text
    not null default 'PENDING',
  applied_at timestamptz,
  applied_by text default 'SYSTEM',

  -- 로컬 오버라이드
  has_local_override boolean
    not null default false,
  local_override_data jsonb,
  override_approved_by uuid,
  override_approved_at timestamptz,

  -- 검증
  last_verified_at timestamptz,
  compliance_status text
    not null default 'PENDING',

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint uq_policy_assignment unique (
    policy_id, store_id
  ),
  constraint chk_assignment_status check (
    assignment_status in (
      'PENDING', 'APPLIED', 'FAILED',
      'OVERRIDDEN', 'REVOKED'
    )
  ),
  constraint chk_compliance_status check (
    compliance_status in (
      'PENDING', 'COMPLIANT',
      'NON_COMPLIANT', 'EXCEPTION_GRANTED'
    )
  )
);

create index if not exists idx_policy_assignments
  on catchmenu_hq.franchise_policy_assignments(
    store_id, assignment_status
  );
create index if not exists idx_policy_assign_policy
  on catchmenu_hq.franchise_policy_assignments(
    policy_id, assignment_status
  );

alter table
  catchmenu_hq.franchise_policy_assignments
  enable row level security;
alter table
  catchmenu_hq.franchise_policy_assignments
  force row level security;

drop policy if exists policy_assignments_isolation
  on catchmenu_hq.franchise_policy_assignments;
create policy policy_assignments_isolation
  on catchmenu_hq.franchise_policy_assignments
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
  );

drop trigger if exists trg_policy_assign_updated
  on catchmenu_hq.franchise_policy_assignments;
create trigger trg_policy_assign_updated
  before update on
    catchmenu_hq.franchise_policy_assignments
  for each row execute function
    catchmenu_common.set_updated_at();


-- =============================================
-- franchise_kpi_targets table
-- KPI 목표치 설정
-- =============================================
create table if not exists
  catchmenu_hq.franchise_kpi_targets (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  brand_id uuid not null
    references catchmenu_hq.franchise_brands(id),
  store_id uuid
    references catchmenu_hq.stores(id),

  -- KPI 식별
  kpi_code text not null,
  kpi_name text not null,
  kpi_type text not null,
  kpi_unit text not null,

  -- 목표치
  target_period text not null default 'MONTHLY',
  target_year int not null,
  target_month int,
  target_value numeric(15,2) not null,
  warning_threshold_pct numeric(5,2)
    not null default 80,
  critical_threshold_pct numeric(5,2)
    not null default 60,

  -- 현재 실적
  actual_value numeric(15,2),
  achievement_pct numeric(5,2),
  last_updated_at timestamptz,

  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint uq_kpi_target unique (
    store_id, brand_id, kpi_code,
    target_year, target_month
  ),
  constraint chk_kpi_type check (
    kpi_type in (
      'REVENUE', 'ORDER_COUNT',
      'CUSTOMER_COUNT', 'AVG_ORDER_VALUE',
      'SATISFACTION_SCORE', 'COMPLIANCE_RATE',
      'STAFF_TURNOVER', 'CUSTOM'
    )
  ),
  constraint chk_target_period check (
    target_period in (
      'DAILY', 'WEEKLY', 'MONTHLY', 'ANNUAL'
    )
  )
);

create index if not exists idx_kpi_targets_store
  on catchmenu_hq.franchise_kpi_targets(
    store_id, target_year, target_month
  ) where is_active = true;
create index if not exists idx_kpi_targets_brand
  on catchmenu_hq.franchise_kpi_targets(
    brand_id, kpi_type
  ) where is_active = true;

alter table catchmenu_hq.franchise_kpi_targets
  enable row level security;
alter table catchmenu_hq.franchise_kpi_targets
  force row level security;

drop policy if exists kpi_targets_isolation
  on catchmenu_hq.franchise_kpi_targets;
create policy kpi_targets_isolation
  on catchmenu_hq.franchise_kpi_targets
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
  );

drop trigger if exists trg_kpi_targets_updated
  on catchmenu_hq.franchise_kpi_targets;
create trigger trg_kpi_targets_updated
  before update on
    catchmenu_hq.franchise_kpi_targets
  for each row execute function
    catchmenu_common.set_updated_at();


-- =============================================
-- franchise_approval_requests table
-- 본사 승인 워크플로우
-- =============================================
create table if not exists
  catchmenu_hq.franchise_approval_requests (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  brand_id uuid not null
    references catchmenu_hq.franchise_brands(id),

  -- 요청 정보
  request_code text not null unique,
  request_type text not null,
  request_title text not null,
  request_body jsonb not null
    default '{}'::jsonb,
  priority text not null default 'NORMAL',

  -- 요청자
  from_store_id uuid
    references catchmenu_hq.stores(id),
  requested_by uuid,
  requested_at timestamptz
    not null default now(),

  -- 승인자
  assigned_to uuid,
  approved_by uuid,
  approval_status text
    not null default 'PENDING',
  approved_at timestamptz,

  -- 결정
  decision text,
  decision_reason text,
  decision_data jsonb,

  -- 기한
  due_date timestamptz,
  is_overdue boolean not null default false,

  -- 연결
  related_policy_id uuid,
  related_menu_template_id uuid,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint chk_request_type check (
    request_type in (
      'MENU_EXCEPTION',
      'PRICE_EXCEPTION',
      'PROMOTION_APPROVAL',
      'POLICY_OVERRIDE',
      'STORE_CLOSURE',
      'STAFF_EXCEPTION',
      'QUALITY_WAIVER',
      'CUSTOM'
    )
  ),
  constraint chk_approval_status check (
    approval_status in (
      'PENDING', 'UNDER_REVIEW',
      'APPROVED', 'REJECTED',
      'CANCELLED', 'EXPIRED'
    )
  )
);

create index if not exists idx_approval_brand
  on catchmenu_hq.franchise_approval_requests(
    brand_id, approval_status, requested_at desc
  );
create index if not exists idx_approval_store
  on catchmenu_hq.franchise_approval_requests(
    from_store_id, approval_status
  );
create index if not exists idx_approval_pending
  on catchmenu_hq.franchise_approval_requests(
    tenant_id, due_date
  ) where approval_status = 'PENDING';

alter table
  catchmenu_hq.franchise_approval_requests
  enable row level security;
alter table
  catchmenu_hq.franchise_approval_requests
  force row level security;

drop policy if exists approval_requests_isolation
  on catchmenu_hq.franchise_approval_requests;
create policy approval_requests_isolation
  on catchmenu_hq.franchise_approval_requests
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
  );

drop trigger if exists trg_approval_requests_updated
  on catchmenu_hq.franchise_approval_requests;
create trigger trg_approval_requests_updated
  before update on
    catchmenu_hq.franchise_approval_requests
  for each row execute function
    catchmenu_common.set_updated_at();

comment on table
  catchmenu_hq.franchise_approval_requests is
  '본사 승인 워크플로우.
   MENU_EXCEPTION: 가맹점 메뉴 예외 허용 요청.
   PRICE_EXCEPTION: 가격 정책 예외 요청.
   PROMOTION_APPROVAL: 프로모션 본사 승인.
   POLICY_OVERRIDE: 정책 오버라이드 요청.
   due_date: 기한 초과 → is_overdue = true.
   3차 Franchise_OS 승인 워크플로우 기반.
   4차에서 알림 + 에스컬레이션 완전 구현.';


-- =============================================
-- RPCs
-- =============================================
create or replace function
  catchmenu_hq.create_franchise_brand(
  p_tenant_id uuid,
  p_brand_code text,
  p_brand_name text,
  p_brand_type text,
  p_hq_store_id uuid default null,
  p_parent_brand_id uuid default null,
  p_royalty_rate_pct numeric default null,
  p_shared_membership boolean default false,
  p_shared_menu_template boolean default false,
  p_locale text default 'ko',
  p_actor_type text default 'OWNER',
  p_actor_id uuid default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_hq,
                  catchmenu_ledger,
                  catchmenu_audit,
                  catchmenu_common
as $$
declare
  v_brand_id uuid;
  v_brand_level int := 1;
  v_audit_id uuid;
  v_business_day date;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  -- 계층 레벨 결정
  if p_parent_brand_id is not null then
    select brand_level + 1
    into v_brand_level
    from catchmenu_hq.franchise_brands
    where id = p_parent_brand_id
      and tenant_id = p_tenant_id;

    if v_brand_level is null then
      return catchmenu_common.build_error_response(
        p_error_key := 'brand_not_found',
        p_locale := p_locale,
        p_tenant_id := p_tenant_id,
        p_rpc_name := 'create_franchise_brand'
      );
    end if;
  end if;

  insert into catchmenu_hq.franchise_brands (
    tenant_id, brand_code, brand_name,
    brand_type, parent_brand_id, brand_level,
    hq_store_id, royalty_rate_pct,
    shared_membership, shared_menu_template,
    brand_status
  ) values (
    p_tenant_id, p_brand_code, p_brand_name,
    p_brand_type, p_parent_brand_id,
    v_brand_level,
    p_hq_store_id, p_royalty_rate_pct,
    p_shared_membership, p_shared_menu_template,
    'ACTIVE'
  )
  on conflict (tenant_id, brand_code) do update set
    brand_name = excluded.brand_name,
    royalty_rate_pct = excluded.royalty_rate_pct,
    shared_membership = excluded.shared_membership,
    is_active = true,
    updated_at = now()
  returning id into v_brand_id;

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
    'franchise', 'brand_created', 1,
    'franchise_brand', v_brand_id,
    null, 'ACTIVE',
    p_actor_type, p_actor_id,
    jsonb_build_object(
      'brand_code', p_brand_code,
      'brand_type', p_brand_type,
      'brand_level', v_brand_level,
      'shared_membership', p_shared_membership
    ),
    p_correlation_id,
    v_business_day, 'Asia/Seoul', now()
  );

  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_audit_domain := 'franchise',
    p_audit_type := 'brand_created',
    p_audit_category := 'OPERATIONAL',
    p_actor_type := p_actor_type,
    p_actor_id := p_actor_id,
    p_subject_type := 'franchise_brand',
    p_subject_id := v_brand_id,
    p_decision := 'COMPLETED',
    p_decision_payload := jsonb_build_object(
      'brand_code', p_brand_code,
      'brand_type', p_brand_type
    ),
    p_correlation_id := p_correlation_id,
    p_business_day := v_business_day,
    p_business_timezone := 'Asia/Seoul'
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'franchise_brand_created',
    p_data := jsonb_build_object(
      'brand_id', v_brand_id,
      'brand_code', p_brand_code,
      'brand_type', p_brand_type,
      'brand_level', v_brand_level,
      'audit_id', v_audit_id
    ),
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );
end;
$$;


create or replace function
  catchmenu_hq.assign_store_to_brand(
  p_tenant_id uuid,
  p_brand_id uuid,
  p_store_id uuid,
  p_member_role text default 'MEMBER',
  p_locale text default 'ko',
  p_actor_id uuid default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_hq,
                  catchmenu_ledger,
                  catchmenu_common
as $$
declare
  v_brand record;
  v_member_id uuid;
  v_business_day date;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  select id, brand_code, brand_name,
         active_store_count
  into v_brand
  from catchmenu_hq.franchise_brands
  where id = p_brand_id
    and tenant_id = p_tenant_id
    and is_active = true;

  if v_brand.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'brand_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_rpc_name := 'assign_store_to_brand'
    );
  end if;

  -- 이미 배정 여부 확인
  if exists (
    select 1 from catchmenu_hq.store_group_members
    where group_id = p_brand_id
      and store_id = p_store_id
      and is_active = true
  ) then
    return catchmenu_common.build_error_response(
      p_error_key := 'store_already_in_brand',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_rpc_name := 'assign_store_to_brand'
    );
  end if;

  -- store_group_members 에 추가
  insert into catchmenu_hq.store_group_members (
    tenant_id, group_id, store_id,
    member_role, joined_by
  ) values (
    p_tenant_id, p_brand_id, p_store_id,
    p_member_role, p_actor_id
  )
  on conflict (group_id, store_id) do update set
    is_active = true,
    member_role = excluded.member_role,
    updated_at = now()
  returning id into v_member_id;

  -- 브랜드 매장 수 증가
  update catchmenu_hq.franchise_brands
  set
    active_store_count = active_store_count + 1,
    updated_at = now()
  where id = p_brand_id;

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
    'franchise', 'store_assigned_to_brand', 1,
    'franchise_brand', p_brand_id,
    null, 'ASSIGNED',
    'SYSTEM', p_actor_id,
    jsonb_build_object(
      'brand_id', p_brand_id,
      'brand_code', v_brand.brand_code,
      'store_id', p_store_id,
      'member_role', p_member_role
    ),
    p_correlation_id,
    v_business_day, 'Asia/Seoul', now()
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'store_assigned_to_brand',
    p_data := jsonb_build_object(
      'member_id', v_member_id,
      'brand_id', p_brand_id,
      'brand_code', v_brand.brand_code,
      'store_id', p_store_id,
      'member_role', p_member_role
    ),
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );
end;
$$;


create or replace function
  catchmenu_hq.publish_franchise_policy(
  p_tenant_id uuid,
  p_brand_id uuid,
  p_policy_code text,
  p_policy_name text,
  p_policy_type text,
  p_policy_data jsonb,
  p_is_mandatory boolean default false,
  p_override_allowed boolean default false,
  p_applies_to text default 'ALL_STORES',
  p_target_store_ids jsonb default null,
  p_effective_from date default null,
  p_effective_until date default null,
  p_locale text default 'ko',
  p_actor_id uuid default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_hq,
                  catchmenu_ledger,
                  catchmenu_audit,
                  catchmenu_common
as $$
declare
  v_policy_id uuid;
  v_version_number int := 1;
  v_old_policy_id uuid;
  v_audit_id uuid;
  v_business_day date;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  -- 브랜드 존재 확인
  if not exists (
    select 1 from catchmenu_hq.franchise_brands
    where id = p_brand_id
      and tenant_id = p_tenant_id
      and is_active = true
  ) then
    return catchmenu_common.build_error_response(
      p_error_key := 'brand_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_rpc_name := 'publish_franchise_policy'
    );
  end if;

  -- 기존 정책 버전 확인
  select id, version_number
  into v_old_policy_id, v_version_number
  from catchmenu_hq.franchise_policies
  where brand_id = p_brand_id
    and policy_code = p_policy_code
    and policy_status = 'PUBLISHED'
    and is_active = true
  order by version_number desc
  limit 1;

  if v_old_policy_id is not null then
    v_version_number := v_version_number + 1;
    -- 기존 정책 SUPERSEDED
    update catchmenu_hq.franchise_policies
    set
      policy_status = 'SUPERSEDED',
      updated_at = now()
    where id = v_old_policy_id;
  end if;

  -- 새 정책 생성
  insert into catchmenu_hq.franchise_policies (
    tenant_id, brand_id,
    policy_code, policy_name,
    policy_type, policy_category,
    policy_data,
    version_number, supersedes,
    applies_to, target_store_ids,
    is_mandatory, override_allowed,
    effective_from, effective_until,
    policy_status, published_at, published_by,
    created_by
  ) values (
    p_tenant_id, p_brand_id,
    p_policy_code, p_policy_name,
    p_policy_type, 'GENERAL',
    p_policy_data,
    v_version_number, v_old_policy_id,
    p_applies_to, p_target_store_ids,
    p_is_mandatory, p_override_allowed,
    coalesce(p_effective_from, current_date),
    p_effective_until,
    'PUBLISHED', now(), p_actor_id,
    p_actor_id
  )
  returning id into v_policy_id;

  -- 기존 정책에 superseded_by 연결
  if v_old_policy_id is not null then
    update catchmenu_hq.franchise_policies
    set superseded_by = v_policy_id
    where id = v_old_policy_id;
  end if;

  -- audit
  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_audit_domain := 'franchise',
    p_audit_type := 'policy_published',
    p_audit_category := 'OPERATIONAL',
    p_actor_type := 'STAFF',
    p_actor_id := p_actor_id,
    p_subject_type := 'franchise_policy',
    p_subject_id := v_policy_id,
    p_decision := 'PUBLISHED',
    p_decision_payload := jsonb_build_object(
      'policy_code', p_policy_code,
      'policy_type', p_policy_type,
      'version', v_version_number,
      'is_mandatory', p_is_mandatory
    ),
    p_correlation_id := p_correlation_id,
    p_business_day := v_business_day,
    p_business_timezone := 'Asia/Seoul'
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'franchise_policy_published',
    p_data := jsonb_build_object(
      'policy_id', v_policy_id,
      'policy_code', p_policy_code,
      'policy_type', p_policy_type,
      'version_number', v_version_number,
      'is_mandatory', p_is_mandatory,
      'applies_to', p_applies_to,
      'supersedes', v_old_policy_id,
      'audit_id', v_audit_id
    ),
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );
end;
$$;


create or replace function
  catchmenu_hq.apply_policy_to_stores(
  p_tenant_id uuid,
  p_policy_id uuid,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_hq,
                  catchmenu_ledger,
                  catchmenu_common
as $$
declare
  v_policy record;
  v_store_id uuid;
  v_applied_count int := 0;
  v_failed_count int := 0;
  v_store_ids jsonb;
  v_business_day date;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  -- 정책 조회
  select id, policy_code, policy_type,
         brand_id, applies_to,
         target_store_ids, is_mandatory
  into v_policy
  from catchmenu_hq.franchise_policies
  where id = p_policy_id
    and tenant_id = p_tenant_id
    and policy_status = 'PUBLISHED'
    and is_active = true;

  if v_policy.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'policy_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_rpc_name := 'apply_policy_to_stores'
    );
  end if;

  -- 대상 매장 결정
  if v_policy.applies_to = 'ALL_STORES' then
    select coalesce(
      jsonb_agg(s.id), '[]'::jsonb
    )
    into v_store_ids
    from catchmenu_hq.store_group_members sgm
    join catchmenu_hq.stores s
      on s.id = sgm.store_id
    where sgm.group_id = v_policy.brand_id
      and sgm.is_active = true
      and s.is_active = true;
  else
    v_store_ids := coalesce(
      v_policy.target_store_ids,
      '[]'::jsonb
    );
  end if;

  -- 매장별 정책 적용
  for v_store_id in
    select jsonb_array_elements_text(
      v_store_ids
    )::uuid
  loop
    begin
      insert into
        catchmenu_hq.franchise_policy_assignments (
        tenant_id, policy_id, store_id, brand_id,
        assignment_status, applied_at, applied_by,
        compliance_status
      ) values (
        p_tenant_id, v_policy.id,
        v_store_id, v_policy.brand_id,
        'APPLIED', now(), 'SYSTEM',
        'PENDING'
      )
      on conflict (policy_id, store_id) do update set
        assignment_status = 'APPLIED',
        applied_at = now(),
        applied_by = 'SYSTEM',
        updated_at = now();

      v_applied_count := v_applied_count + 1;

    exception when others then
      v_failed_count := v_failed_count + 1;
    end;
  end loop;

  -- ledger event
  insert into catchmenu_ledger.events (
    tenant_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, event_payload,
    correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id,
    'franchise', 'policy_applied_to_stores', 1,
    'franchise_policy', p_policy_id,
    null, 'APPLIED',
    'SYSTEM',
    jsonb_build_object(
      'policy_code', v_policy.policy_code,
      'policy_type', v_policy.policy_type,
      'applied_count', v_applied_count,
      'failed_count', v_failed_count,
      'is_mandatory', v_policy.is_mandatory
    ),
    p_correlation_id,
    v_business_day, 'Asia/Seoul', now()
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'policy_applied_to_stores',
    p_data := jsonb_build_object(
      'policy_id', p_policy_id,
      'policy_code', v_policy.policy_code,
      'applied_count', v_applied_count,
      'failed_count', v_failed_count,
      'total_stores',
        jsonb_array_length(v_store_ids)
    ),
    p_locale := p_locale,
    p_params := jsonb_build_object(
      'store_count', v_applied_count
    ),
    p_correlation_id := p_correlation_id
  );
end;
$$;


create or replace function
  catchmenu_hq.request_hq_approval(
  p_tenant_id uuid,
  p_brand_id uuid,
  p_from_store_id uuid,
  p_request_type text,
  p_request_title text,
  p_request_body jsonb,
  p_priority text default 'NORMAL',
  p_due_date timestamptz default null,
  p_related_policy_id uuid default null,
  p_locale text default 'ko',
  p_requested_by uuid default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_hq,
                  catchmenu_ledger,
                  catchmenu_common
as $$
declare
  v_request_id uuid;
  v_request_code text;
  v_request_seq int;
  v_business_day date;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  if not exists (
    select 1 from catchmenu_hq.franchise_brands
    where id = p_brand_id
      and tenant_id = p_tenant_id
      and is_active = true
  ) then
    return catchmenu_common.build_error_response(
      p_error_key := 'brand_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_rpc_name := 'request_hq_approval'
    );
  end if;

  -- 요청 코드 생성
  select coalesce(count(*), 0) + 1
  into v_request_seq
  from catchmenu_hq.franchise_approval_requests
  where brand_id = p_brand_id
    and date_trunc('month', requested_at)
      = date_trunc('month', now());

  v_request_code := 'APR-'
    || to_char(now(), 'YYYYMM')
    || '-'
    || lpad(v_request_seq::text, 4, '0');

  insert into
    catchmenu_hq.franchise_approval_requests (
    tenant_id, brand_id, request_code,
    request_type, request_title,
    request_body, priority,
    from_store_id, requested_by,
    requested_at, due_date,
    related_policy_id,
    approval_status
  ) values (
    p_tenant_id, p_brand_id, v_request_code,
    p_request_type, p_request_title,
    p_request_body, p_priority,
    p_from_store_id, p_requested_by,
    now(), p_due_date,
    p_related_policy_id,
    'PENDING'
  )
  returning id into v_request_id;

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
    p_tenant_id, p_from_store_id,
    'franchise', 'approval_requested', 1,
    'approval_request', v_request_id,
    null, 'PENDING',
    'STAFF', p_requested_by,
    jsonb_build_object(
      'request_code', v_request_code,
      'request_type', p_request_type,
      'priority', p_priority
    ),
    p_correlation_id,
    v_business_day, 'Asia/Seoul', now()
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'approval_requested',
    p_data := jsonb_build_object(
      'request_id', v_request_id,
      'request_code', v_request_code,
      'request_type', p_request_type,
      'priority', p_priority,
      'approval_status', 'PENDING',
      'due_date', p_due_date
    ),
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );
end;
$$;


create or replace function
  catchmenu_hq.process_hq_approval(
  p_tenant_id uuid,
  p_request_id uuid,
  p_decision text,
  p_decision_reason text default null,
  p_decision_data jsonb default null,
  p_locale text default 'ko',
  p_approved_by uuid default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_hq,
                  catchmenu_ledger,
                  catchmenu_audit,
                  catchmenu_common
as $$
declare
  v_request record;
  v_new_status text;
  v_message_key text;
  v_audit_id uuid;
  v_business_day date;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  if p_decision not in (
    'APPROVED', 'REJECTED'
  ) then
    return catchmenu_common.build_error_response(
      p_error_key := 'invalid_input',
      p_locale := p_locale,
      p_params := jsonb_build_object(
        'field', 'decision',
        'allowed', 'APPROVED or REJECTED'
      ),
      p_tenant_id := p_tenant_id,
      p_rpc_name := 'process_hq_approval'
    );
  end if;

  select id, request_code, request_type,
         approval_status, brand_id,
         from_store_id, requested_by
  into v_request
  from catchmenu_hq.franchise_approval_requests
  where id = p_request_id
    and tenant_id = p_tenant_id
  for update;

  if v_request.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'approval_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_rpc_name := 'process_hq_approval'
    );
  end if;

  if v_request.approval_status not in (
    'PENDING', 'UNDER_REVIEW'
  ) then
    return catchmenu_common.build_error_response(
      p_error_key := 'approval_already_processed',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_rpc_name := 'process_hq_approval'
    );
  end if;

  v_new_status := p_decision;
  v_message_key := case p_decision
    when 'APPROVED' then 'approval_approved'
    else 'approval_rejected'
  end;

  -- 승인 처리
  update catchmenu_hq.franchise_approval_requests
  set
    approval_status = v_new_status,
    approved_by = p_approved_by,
    approved_at = now(),
    decision = p_decision,
    decision_reason = p_decision_reason,
    decision_data = p_decision_data,
    updated_at = now()
  where id = p_request_id;

  -- 승인 시 정책 자동 적용
  if p_decision = 'APPROVED'
    and v_request.request_type
      = 'POLICY_OVERRIDE'
  then
    perform catchmenu_hq.apply_policy_to_stores(
      p_tenant_id := p_tenant_id,
      p_policy_id := (
        select related_policy_id
        from catchmenu_hq
          .franchise_approval_requests
        where id = p_request_id
      ),
      p_locale := p_locale,
      p_correlation_id := p_correlation_id
    );
  end if;

  -- audit
  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := v_request.from_store_id,
    p_audit_domain := 'franchise',
    p_audit_type := 'approval_processed',
    p_audit_category := 'OPERATIONAL',
    p_actor_type := 'HQ_ADMIN',
    p_actor_id := p_approved_by,
    p_subject_type := 'approval_request',
    p_subject_id := p_request_id,
    p_decision := p_decision,
    p_decision_reason := p_decision_reason,
    p_decision_payload := p_decision_data,
    p_correlation_id := p_correlation_id,
    p_business_day := v_business_day,
    p_business_timezone := 'Asia/Seoul'
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
    p_tenant_id, v_request.from_store_id,
    'franchise', 'approval_processed', 1,
    'approval_request', p_request_id,
    v_request.approval_status, v_new_status,
    'HQ_ADMIN', p_approved_by,
    jsonb_build_object(
      'request_code', v_request.request_code,
      'request_type', v_request.request_type,
      'decision', p_decision,
      'decision_reason', p_decision_reason
    ),
    p_correlation_id,
    v_business_day, 'Asia/Seoul', now()
  );

  return catchmenu_common.build_success_response(
    p_message_key := v_message_key,
    p_data := jsonb_build_object(
      'request_id', p_request_id,
      'request_code', v_request.request_code,
      'decision', p_decision,
      'approval_status', v_new_status,
      'audit_id', v_audit_id
    ),
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );
end;
$$;


create or replace function
  catchmenu_hq.get_franchise_dashboard(
  p_tenant_id uuid,
  p_brand_id uuid,
  p_business_day date default null,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_hq,
                  catchmenu_pos,
                  catchmenu_payment,
                  catchmenu_common
as $$
declare
  v_brand record;
  v_target_day date;
  v_stores jsonb;
  v_kpi_summary jsonb;
  v_policy_summary jsonb;
  v_pending_approvals jsonb;
  v_brand_totals jsonb;
begin
  v_target_day := coalesce(
    p_business_day,
    (timezone('Asia/Seoul', now()))::date
  );

  select id, brand_code, brand_name,
         brand_type, brand_level,
         active_store_count, brand_status,
         shared_membership
  into v_brand
  from catchmenu_hq.franchise_brands
  where id = p_brand_id
    and tenant_id = p_tenant_id
    and is_active = true;

  if v_brand.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'brand_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_rpc_name := 'get_franchise_dashboard'
    );
  end if;

  -- 매장별 오늘 성과
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'store_id', s.id,
        'store_name', s.store_name,
        'store_status', s.store_status,
        'member_role', sgm.member_role,
        'today_revenue', coalesce((
          select sum(net_amount)
          from catchmenu_payment.payment_ledger
          where store_id = s.id
            and business_day = v_target_day
            and ledger_status = 'APPROVED'
        ), 0),
        'today_orders', coalesce((
          select count(*)
          from catchmenu_pos.orders
          where store_id = s.id
            and business_day = v_target_day
            and order_status = 'COMPLETED'
        ), 0),
        'policy_compliance', coalesce((
          select count(*) filter (
            where compliance_status = 'COMPLIANT'
          )::numeric
          / nullif(count(*), 0) * 100, 0
        )::int
          from catchmenu_hq
            .franchise_policy_assignments
          where store_id = s.id
            and tenant_id = p_tenant_id
        ),
        'pending_approvals', (
          select count(*)
          from catchmenu_hq
            .franchise_approval_requests
          where from_store_id = s.id
            and approval_status = 'PENDING'
        )
      )
      order by s.store_name
    ),
    '[]'::jsonb
  )
  into v_stores
  from catchmenu_hq.store_group_members sgm
  join catchmenu_hq.stores s
    on s.id = sgm.store_id
  where sgm.group_id = p_brand_id
    and sgm.tenant_id = p_tenant_id
    and sgm.is_active = true
    and s.is_active = true;

  -- 브랜드 전체 합계
  select jsonb_build_object(
    'total_stores', count(*),
    'total_revenue', coalesce(
      sum((m->>'today_revenue')::numeric), 0
    ),
    'total_orders', coalesce(
      sum((m->>'today_orders')::int), 0
    ),
    'avg_compliance_pct', coalesce(
      avg((m->>'policy_compliance')::numeric), 0
    )::int,
    'stores_with_pending_approvals', count(*)
      filter (
        where (m->>'pending_approvals')::int > 0
      )
  )
  into v_brand_totals
  from jsonb_array_elements(v_stores) m;

  -- KPI 달성 현황
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'kpi_code', kpi_code,
        'kpi_name', kpi_name,
        'kpi_type', kpi_type,
        'target_value', target_value,
        'actual_value', actual_value,
        'achievement_pct', achievement_pct,
        'is_below_warning',
          coalesce(achievement_pct, 0)
            < warning_threshold_pct
      )
      order by achievement_pct asc nulls last
    ),
    '[]'::jsonb
  )
  into v_kpi_summary
  from catchmenu_hq.franchise_kpi_targets
  where brand_id = p_brand_id
    and tenant_id = p_tenant_id
    and target_year = extract(year from v_target_day)
    and (
      target_month is null
      or target_month = extract(
        month from v_target_day
      )
    )
    and is_active = true;

  -- 정책 준수 현황
  select jsonb_build_object(
    'total_assignments', count(*),
    'compliant', count(*) filter (
      where compliance_status = 'COMPLIANT'
    ),
    'non_compliant', count(*) filter (
      where compliance_status = 'NON_COMPLIANT'
    ),
    'pending_check', count(*) filter (
      where compliance_status = 'PENDING'
    )
  )
  into v_policy_summary
  from catchmenu_hq.franchise_policy_assignments fpa
  join catchmenu_hq.store_group_members sgm
    on sgm.store_id = fpa.store_id
  where sgm.group_id = p_brand_id
    and fpa.tenant_id = p_tenant_id;

  -- 미처리 승인 요청
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'request_id', id,
        'request_code', request_code,
        'request_type', request_type,
        'request_title', request_title,
        'priority', priority,
        'from_store_id', from_store_id,
        'requested_at', requested_at,
        'due_date', due_date,
        'is_overdue', is_overdue
      )
      order by
        case priority
          when 'URGENT' then 0
          when 'HIGH' then 1
          else 2
        end,
        requested_at asc
    ),
    '[]'::jsonb
  )
  into v_pending_approvals
  from catchmenu_hq.franchise_approval_requests
  where brand_id = p_brand_id
    and tenant_id = p_tenant_id
    and approval_status = 'PENDING'
  limit 20;

  return catchmenu_common.build_success_response(
    p_message_key := 'franchise_dashboard_loaded',
    p_data := jsonb_build_object(
      'brand', jsonb_build_object(
        'id', v_brand.id,
        'brand_code', v_brand.brand_code,
        'brand_name', v_brand.brand_name,
        'brand_type', v_brand.brand_type,
        'brand_level', v_brand.brand_level,
        'brand_status', v_brand.brand_status,
        'shared_membership',
          v_brand.shared_membership
      ),
      'business_day', v_target_day,
      'stores', v_stores,
      'totals', v_brand_totals,
      'kpi_summary', v_kpi_summary,
      'policy_summary', v_policy_summary,
      'pending_approvals', v_pending_approvals,
      'pending_approval_count',
        jsonb_array_length(v_pending_approvals)
    ),
    p_locale := p_locale
  );
end;
$$;


-- grants
do $$
begin
  revoke all on function
    catchmenu_hq.create_franchise_brand(
      uuid, text, text, text, uuid, uuid,
      numeric, boolean, boolean,
      text, text, uuid, text
    ) from public;
  grant execute on function
    catchmenu_hq.create_franchise_brand(
      uuid, text, text, text, uuid, uuid,
      numeric, boolean, boolean,
      text, text, uuid, text
    ) to authenticated;

  revoke all on function
    catchmenu_hq.assign_store_to_brand(
      uuid, uuid, uuid, text, text, uuid, text
    ) from public;
  grant execute on function
    catchmenu_hq.assign_store_to_brand(
      uuid, uuid, uuid, text, text, uuid, text
    ) to authenticated;

  revoke all on function
    catchmenu_hq.publish_franchise_policy(
      uuid, uuid, text, text, text, jsonb,
      boolean, boolean, text, jsonb, date,
      date, text, uuid, text
    ) from public;
  grant execute on function
    catchmenu_hq.publish_franchise_policy(
      uuid, uuid, text, text, text, jsonb,
      boolean, boolean, text, jsonb, date,
      date, text, uuid, text
    ) to authenticated;

  revoke all on function
    catchmenu_hq.apply_policy_to_stores(
      uuid, uuid, text, text
    ) from public;
  grant execute on function
    catchmenu_hq.apply_policy_to_stores(
      uuid, uuid, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_hq.request_hq_approval(
      uuid, uuid, uuid, text, text, jsonb,
      text, timestamptz, uuid, text, uuid, text
    ) from public;
  grant execute on function
    catchmenu_hq.request_hq_approval(
      uuid, uuid, uuid, text, text, jsonb,
      text, timestamptz, uuid, text, uuid, text
    ) to authenticated;

  revoke all on function
    catchmenu_hq.process_hq_approval(
      uuid, uuid, text, text, jsonb,
      text, uuid, text
    ) from public;
  grant execute on function
    catchmenu_hq.process_hq_approval(
      uuid, uuid, text, text, jsonb,
      text, uuid, text
    ) to authenticated;

  revoke all on function
    catchmenu_hq.get_franchise_dashboard(
      uuid, uuid, date, text
    ) from public;
  grant execute on function
    catchmenu_hq.get_franchise_dashboard(
      uuid, uuid, date, text
    ) to authenticated;
end;
$$;

comment on function
  catchmenu_hq.publish_franchise_policy(
    uuid, uuid, text, text, text, jsonb,
    boolean, boolean, text, jsonb, date,
    date, text, uuid, text
  ) is
  '프랜차이즈 정책 발행.
   is_mandatory = true: 가맹점 강제 적용.
   override_allowed = true: 예외 허용.
   기존 PUBLISHED 정책 → SUPERSEDED.
   버전 자동 증가.
   발행 후 apply_policy_to_stores() 호출.
   정책 타입별 policy_data 구조:
   MENU: {allowed_menus, restricted_menus}
   PRICING: {max_discount_pct, fixed_prices}
   OPERATION: {hours, kds_threshold}
   COMPLIANCE: {audit_frequency, requirements}
   3차 Franchise_OS 정책 배포 기반.
   4차에서 알림 + 강제 적용 완전 구현.';

comment on function
  catchmenu_hq.get_franchise_dashboard(
    uuid, uuid, date, text
  ) is
  '프랜차이즈 브랜드 통합 대시보드.
   포함 데이터:
   - 매장별 오늘 매출/주문/정책준수율
   - 브랜드 전체 합계
   - KPI 달성 현황
   - 정책 준수 현황
   - 미처리 승인 요청
   모든 메시지 = message_catalog i18n.
   3차 Franchise_OS 사전 대시보드.
   4차에서 실시간 알림 + 에스컬레이션 추가.';