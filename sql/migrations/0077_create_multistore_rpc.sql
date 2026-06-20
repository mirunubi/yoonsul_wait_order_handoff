-- 0077_create_multistore_rpc.sql
-- Purpose: Multi-store management RPCs.
--          Store group management, cross-store inventory,
--          store performance comparison,
--          inter-store stock transfer.
--          3차 Franchise_OS 사전 작업 기반.
-- Depends on: 0076_create_staff_advanced_rpc.sql
-- Creates:
--   catchmenu_hq.store_groups (table)
--   catchmenu_hq.store_group_members (table)
--   catchmenu_store.stock_transfer_requests (table)
--   catchmenu_store.stock_transfer_items (table)
--   function catchmenu_hq.create_store_group(...)
--   function catchmenu_hq.get_store_group_dashboard(...)
--   function catchmenu_store.request_stock_transfer(...)
--   function catchmenu_store.approve_stock_transfer(...)
--   function catchmenu_store.get_multistore_inventory(...)
--   function catchmenu_hq.compare_store_performance(...)

-- =============================================
-- store_groups table
-- 매장 그룹 (지역별/브랜드별)
-- 3차 Franchise_OS 사전 구조
-- =============================================
create table if not exists
  catchmenu_hq.store_groups (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),

  group_code text not null,
  group_name text not null,
  group_type text not null default 'REGION',

  -- 계층 구조 (프랜차이즈 대비)
  parent_group_id uuid
    references catchmenu_hq.store_groups(id),
  depth int not null default 0,

  -- 관리자
  group_manager_id uuid,
  group_manager_name text,

  -- 설정
  shared_menu_enabled boolean
    not null default false,
  shared_inventory_enabled boolean
    not null default false,
  cross_store_transfer_enabled boolean
    not null default false,

  -- 성과 집계 기준
  performance_metric text
    not null default 'REVENUE',

  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint uq_store_group_code unique (
    tenant_id, group_code
  ),
  constraint chk_group_type check (
    group_type in (
      'REGION',      -- 지역 그룹
      'BRAND',       -- 브랜드 그룹
      'FRANCHISE',   -- 프랜차이즈 (4차)
      'DISTRICT',    -- 권역 (프랜차이즈 하위)
      'CUSTOM'
    )
  ),
  constraint chk_performance_metric check (
    performance_metric in (
      'REVENUE', 'ORDER_COUNT',
      'CUSTOMER_COUNT', 'PROFIT'
    )
  )
);

create index if not exists idx_store_groups_tenant
  on catchmenu_hq.store_groups(
    tenant_id, group_type
  ) where is_active = true;
create index if not exists idx_store_groups_parent
  on catchmenu_hq.store_groups(parent_group_id)
  where parent_group_id is not null;

alter table catchmenu_hq.store_groups
  enable row level security;
alter table catchmenu_hq.store_groups
  force row level security;

drop policy if exists store_groups_isolation
  on catchmenu_hq.store_groups;
create policy store_groups_isolation
  on catchmenu_hq.store_groups
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
  );

drop trigger if exists trg_store_groups_updated
  on catchmenu_hq.store_groups;
create trigger trg_store_groups_updated
  before update on catchmenu_hq.store_groups
  for each row execute function
    catchmenu_common.set_updated_at();

comment on table catchmenu_hq.store_groups is
  '매장 그룹 관리.
   3차 Franchise_OS 사전 구조.
   REGION: 지역별 그룹 (울산, 부산 등)
   BRAND: 브랜드별 그룹 (윤슬김밥 등)
   FRANCHISE: 가맹점 그룹 (4차 구현)
   DISTRICT: 권역 (프랜차이즈 지역 관리자)
   parent_group_id: 계층 구조
   (FRANCHISE → DISTRICT → STORE).
   cross_store_transfer_enabled:
   매장간 재고 이동 허용 여부.';


-- =============================================
-- store_group_members table
-- 매장 그룹 멤버
-- =============================================
create table if not exists
  catchmenu_hq.store_group_members (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  group_id uuid not null
    references catchmenu_hq.store_groups(id),
  store_id uuid not null
    references catchmenu_hq.stores(id),

  -- 그룹 내 역할
  member_role text not null default 'MEMBER',
  joined_at timestamptz not null default now(),
  joined_by uuid,

  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint uq_group_member unique (
    group_id, store_id
  ),
  constraint chk_member_role check (
    member_role in (
      'LEADER',   -- 그룹 대표 매장
      'MEMBER',   -- 일반 멤버
      'HQ'        -- 본사 (4차)
    )
  )
);

create index if not exists idx_group_members_group
  on catchmenu_hq.store_group_members(
    group_id
  ) where is_active = true;
create index if not exists idx_group_members_store
  on catchmenu_hq.store_group_members(
    store_id
  ) where is_active = true;

alter table catchmenu_hq.store_group_members
  enable row level security;
alter table catchmenu_hq.store_group_members
  force row level security;

drop policy if exists group_members_isolation
  on catchmenu_hq.store_group_members;
create policy group_members_isolation
  on catchmenu_hq.store_group_members
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
  );

drop trigger if exists trg_group_members_updated
  on catchmenu_hq.store_group_members;
create trigger trg_group_members_updated
  before update on catchmenu_hq.store_group_members
  for each row execute function
    catchmenu_common.set_updated_at();


-- =============================================
-- stock_transfer_requests table
-- 매장간 재고 이동 요청
-- =============================================
create table if not exists
  catchmenu_store.stock_transfer_requests (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),

  -- 이동 경로
  from_store_id uuid not null
    references catchmenu_hq.stores(id),
  to_store_id uuid not null
    references catchmenu_hq.stores(id),
  group_id uuid
    references catchmenu_hq.store_groups(id),

  -- 요청 정보
  transfer_reason text not null,
  request_status text not null default 'PENDING',
  priority text not null default 'NORMAL',

  -- 처리
  requested_by uuid,
  requested_at timestamptz not null default now(),
  approved_by uuid,
  approved_at timestamptz,
  rejected_reason text,
  completed_at timestamptz,

  -- 증빙
  transfer_note text,

  business_day date,
  business_timezone text default 'Asia/Seoul',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint chk_transfer_stores check (
    from_store_id <> to_store_id
  ),
  constraint chk_request_status check (
    request_status in (
      'PENDING', 'APPROVED', 'REJECTED',
      'IN_TRANSIT', 'COMPLETED', 'CANCELLED'
    )
  ),
  constraint chk_transfer_priority check (
    priority in ('URGENT', 'HIGH', 'NORMAL', 'LOW')
  )
);

create index if not exists idx_transfer_from_store
  on catchmenu_store.stock_transfer_requests(
    from_store_id, request_status
  );
create index if not exists idx_transfer_to_store
  on catchmenu_store.stock_transfer_requests(
    to_store_id, request_status
  );
create index if not exists idx_transfer_tenant
  on catchmenu_store.stock_transfer_requests(
    tenant_id, business_day desc
  );

alter table catchmenu_store.stock_transfer_requests
  enable row level security;
alter table catchmenu_store.stock_transfer_requests
  force row level security;

drop policy if exists transfer_requests_isolation
  on catchmenu_store.stock_transfer_requests;
create policy transfer_requests_isolation
  on catchmenu_store.stock_transfer_requests
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
  );

drop trigger if exists trg_transfer_requests_updated
  on catchmenu_store.stock_transfer_requests;
create trigger trg_transfer_requests_updated
  before update on
    catchmenu_store.stock_transfer_requests
  for each row execute function
    catchmenu_common.set_updated_at();

comment on table
  catchmenu_store.stock_transfer_requests is
  '매장간 재고 이동 요청.
   from_store → to_store 재고 이동.
   PENDING → APPROVED → IN_TRANSIT → COMPLETED.
   승인자 (approved_by): 그룹 관리자 또는 HQ.
   특허4: 재고 이동 = 감사 추적 가능 원장 기록.
   3차 Franchise_OS 재고 공유 기반.';


-- =============================================
-- stock_transfer_items table
-- 재고 이동 항목별 상세
-- =============================================
create table if not exists
  catchmenu_store.stock_transfer_items (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  transfer_id uuid not null
    references catchmenu_store
      .stock_transfer_requests(id),

  -- 재료
  ingredient_id uuid not null
    references catchmenu_store.ingredients(id),
  ingredient_name_snapshot text not null,
  unit_snapshot text not null,

  -- 수량
  requested_quantity numeric(10,3) not null,
  approved_quantity numeric(10,3),
  actual_quantity numeric(10,3),

  -- 상태
  item_status text not null default 'PENDING',

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint chk_item_status check (
    item_status in (
      'PENDING', 'APPROVED',
      'TRANSFERRED', 'PARTIAL', 'REJECTED'
    )
  ),
  constraint chk_requested_qty check (
    requested_quantity > 0
  )
);

create index if not exists idx_transfer_items
  on catchmenu_store.stock_transfer_items(
    transfer_id
  );
create index if not exists idx_transfer_ingredient
  on catchmenu_store.stock_transfer_items(
    ingredient_id
  );

alter table catchmenu_store.stock_transfer_items
  enable row level security;
alter table catchmenu_store.stock_transfer_items
  force row level security;

drop policy if exists transfer_items_isolation
  on catchmenu_store.stock_transfer_items;
create policy transfer_items_isolation
  on catchmenu_store.stock_transfer_items
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
  );

drop trigger if exists trg_transfer_items_updated
  on catchmenu_store.stock_transfer_items;
create trigger trg_transfer_items_updated
  before update on
    catchmenu_store.stock_transfer_items
  for each row execute function
    catchmenu_common.set_updated_at();


-- =============================================
-- RPCs
-- =============================================
create or replace function
  catchmenu_hq.create_store_group(
  p_tenant_id uuid,
  p_group_code text,
  p_group_name text,
  p_group_type text,
  p_store_ids jsonb,
  p_parent_group_id uuid default null,
  p_cross_store_transfer boolean default false,
  p_shared_menu boolean default false,
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
  v_group_id uuid;
  v_member_count int := 0;
  v_store_id uuid;
  v_audit_id uuid;
  v_business_day date;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  -- 그룹 생성
  insert into catchmenu_hq.store_groups (
    tenant_id, group_code, group_name,
    group_type, parent_group_id,
    cross_store_transfer_enabled,
    shared_menu_enabled
  ) values (
    p_tenant_id, p_group_code, p_group_name,
    p_group_type, p_parent_group_id,
    p_cross_store_transfer,
    p_shared_menu
  )
  on conflict (tenant_id, group_code) do update set
    group_name = excluded.group_name,
    cross_store_transfer_enabled =
      excluded.cross_store_transfer_enabled,
    shared_menu_enabled =
      excluded.shared_menu_enabled,
    updated_at = now()
  returning id into v_group_id;

  -- 멤버 추가
  for v_store_id in
    select jsonb_array_elements_text(p_store_ids)
  loop
    insert into catchmenu_hq.store_group_members (
      tenant_id, group_id, store_id,
      member_role, joined_by
    ) values (
      p_tenant_id, v_group_id, v_store_id::uuid,
      case v_member_count
        when 0 then 'LEADER'
        else 'MEMBER'
      end,
      p_actor_id
    )
    on conflict (group_id, store_id) do update set
      is_active = true,
      updated_at = now();

    v_member_count := v_member_count + 1;
  end loop;

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
    'franchise', 'store_group_created', 1,
    'store_group', v_group_id,
    null, 'ACTIVE',
    p_actor_type, p_actor_id,
    jsonb_build_object(
      'group_code', p_group_code,
      'group_type', p_group_type,
      'member_count', v_member_count,
      'cross_store_transfer',
        p_cross_store_transfer,
      'shared_menu', p_shared_menu
    ),
    p_correlation_id,
    v_business_day, 'Asia/Seoul', now()
  );

  -- audit
  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_audit_domain := 'franchise',
    p_audit_type := 'store_group_created',
    p_audit_category := 'OPERATIONAL',
    p_actor_type := p_actor_type,
    p_actor_id := p_actor_id,
    p_subject_type := 'store_group',
    p_subject_id := v_group_id,
    p_decision := 'COMPLETED',
    p_decision_payload := jsonb_build_object(
      'group_code', p_group_code,
      'group_type', p_group_type,
      'member_count', v_member_count
    ),
    p_correlation_id := p_correlation_id,
    p_business_day := v_business_day,
    p_business_timezone := 'Asia/Seoul'
  );

  return jsonb_build_object(
    'success', true,
    'group_id', v_group_id,
    'group_code', p_group_code,
    'group_type', p_group_type,
    'member_count', v_member_count,
    'audit_id', v_audit_id,
    'message_code', 'store_group_created'
  );
end;
$$;


create or replace function
  catchmenu_hq.get_store_group_dashboard(
  p_tenant_id uuid,
  p_group_id uuid,
  p_business_day date default null
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_hq,
                  catchmenu_pos,
                  catchmenu_payment,
                  catchmenu_store,
                  catchmenu_common
as $$
declare
  v_group record;
  v_target_day date;
  v_stores jsonb;
  v_group_totals jsonb;
begin
  v_target_day := coalesce(
    p_business_day,
    (timezone('Asia/Seoul', now()))::date
  );

  -- 그룹 정보
  select id, group_code, group_name,
         group_type, cross_store_transfer_enabled,
         shared_menu_enabled
  into v_group
  from catchmenu_hq.store_groups
  where id = p_group_id
    and tenant_id = p_tenant_id
    and is_active = true;

  if v_group.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'store_not_found',
      p_locale := 'ko',
      p_tenant_id := p_tenant_id,
      p_rpc_name := 'get_store_group_dashboard'
    );
  end if;

  -- 멤버 매장별 오늘 성과
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'store_id', s.id,
        'store_code', s.store_code,
        'store_name', s.store_name,
        'store_status', s.store_status,
        'member_role', sgm.member_role,

        -- 오늘 매출
        'today_revenue', coalesce((
          select sum(net_amount)
          from catchmenu_payment.payment_ledger
          where store_id = s.id
            and business_day = v_target_day
            and ledger_status = 'APPROVED'
        ), 0),

        -- 오늘 주문수
        'today_orders', coalesce((
          select count(*)
          from catchmenu_pos.orders
          where store_id = s.id
            and business_day = v_target_day
            and order_status = 'COMPLETED'
        ), 0),

        -- 현재 대기
        'current_waiting', coalesce((
          select count(*)
          from catchmenu_pos.order_sessions
          where store_id = s.id
            and session_status in (
              'WAITING', 'ARRIVAL_PENDING'
            )
        ), 0),

        -- 저재고 식재료
        'low_stock_count', coalesce((
          select count(*)
          from catchmenu_store.ingredients
          where store_id = s.id
            and ingredient_status in (
              'LOW_STOCK', 'OUT_OF_STOCK'
            )
            and is_active = true
        ), 0),

        -- 직원 현황
        'clocked_in_staff', coalesce((
          select count(distinct staff_id)
          from catchmenu_store.staff_shifts
          where store_id = s.id
            and shift_date = v_target_day
            and shift_status = 'CLOCKED_IN'
        ), 0)
      )
      order by
        case sgm.member_role
          when 'LEADER' then 0
          else 1
        end,
        s.store_name
    ),
    '[]'::jsonb
  )
  into v_stores
  from catchmenu_hq.store_group_members sgm
  join catchmenu_hq.stores s
    on s.id = sgm.store_id
  where sgm.group_id = p_group_id
    and sgm.tenant_id = p_tenant_id
    and sgm.is_active = true
    and s.is_active = true;

  -- 그룹 전체 합계
  select jsonb_build_object(
    'total_stores', count(*),
    'total_revenue', coalesce(
      sum((m->>'today_revenue')::numeric), 0
    ),
    'total_orders', coalesce(
      sum((m->>'today_orders')::int), 0
    ),
    'total_waiting', coalesce(
      sum((m->>'current_waiting')::int), 0
    ),
    'stores_with_low_stock', count(*)
      filter (
        where (m->>'low_stock_count')::int > 0
      ),
    'total_staff_in', coalesce(
      sum((m->>'clocked_in_staff')::int), 0
    )
  )
  into v_group_totals
  from jsonb_array_elements(v_stores) m;

  return jsonb_build_object(
    'success', true,
    'group_id', p_group_id,
    'group_code', v_group.group_code,
    'group_name', v_group.group_name,
    'group_type', v_group.group_type,
    'business_day', v_target_day,
    'stores', v_stores,
    'totals', v_group_totals,
    'features', jsonb_build_object(
      'cross_store_transfer',
        v_group.cross_store_transfer_enabled,
      'shared_menu', v_group.shared_menu_enabled
    ),
    'message_code', 'store_group_dashboard_loaded'
  );
end;
$$;


create or replace function
  catchmenu_store.request_stock_transfer(
  p_tenant_id uuid,
  p_from_store_id uuid,
  p_to_store_id uuid,
  p_transfer_reason text,
  p_items jsonb,
  p_priority text default 'NORMAL',
  p_transfer_note text default null,
  p_requested_by uuid default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_store,
                  catchmenu_hq,
                  catchmenu_ledger,
                  catchmenu_audit,
                  catchmenu_common
as $$
declare
  v_transfer_id uuid;
  v_group_id uuid;
  v_transfer_enabled boolean;
  v_item jsonb;
  v_ingredient record;
  v_item_count int := 0;
  v_audit_id uuid;
  v_business_day date;
  v_timezone text;
begin
  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_from_store_id
    and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  -- 두 매장이 같은 그룹이고
  -- cross_store_transfer 허용 여부 확인
  select sg.id, sg.cross_store_transfer_enabled
  into v_group_id, v_transfer_enabled
  from catchmenu_hq.store_groups sg
  join catchmenu_hq.store_group_members sgm1
    on sgm1.group_id = sg.id
    and sgm1.store_id = p_from_store_id
    and sgm1.is_active = true
  join catchmenu_hq.store_group_members sgm2
    on sgm2.group_id = sg.id
    and sgm2.store_id = p_to_store_id
    and sgm2.is_active = true
  where sg.tenant_id = p_tenant_id
    and sg.is_active = true
    and sg.cross_store_transfer_enabled = true
  limit 1;

  if v_group_id is null or not v_transfer_enabled then
    return jsonb_build_object(
      'success', false,
      'error_key', 'cross_store_transfer_not_allowed',
      'message',
        '두 매장이 같은 그룹에 속하지 않거나 '
        || '재고 이동이 허용되지 않습니다'
    );
  end if;

  if jsonb_array_length(
    coalesce(p_items, '[]'::jsonb)
  ) = 0 then
    return catchmenu_common.build_error_response(
      p_error_key := 'items_required',
      p_locale := 'ko',
      p_tenant_id := p_tenant_id,
      p_store_id := p_from_store_id,
      p_rpc_name := 'request_stock_transfer'
    );
  end if;

  -- 이동 요청 생성
  insert into catchmenu_store.stock_transfer_requests (
    tenant_id, from_store_id, to_store_id,
    group_id, transfer_reason,
    request_status, priority,
    requested_by, requested_at,
    transfer_note,
    business_day, business_timezone
  ) values (
    p_tenant_id, p_from_store_id, p_to_store_id,
    v_group_id, p_transfer_reason,
    'PENDING', p_priority,
    p_requested_by, now(),
    p_transfer_note,
    v_business_day, v_timezone
  )
  returning id into v_transfer_id;

  -- 항목별 추가
  for v_item in
    select * from jsonb_array_elements(p_items)
  loop
    -- 재료 정보 조회
    select id, ingredient_name, unit
    into v_ingredient
    from catchmenu_store.ingredients
    where id = (v_item->>'ingredient_id')::uuid
      and store_id = p_from_store_id
      and tenant_id = p_tenant_id
      and is_active = true;

    if v_ingredient.id is null then
      continue; -- 없는 재료는 skip
    end if;

    insert into catchmenu_store.stock_transfer_items (
      tenant_id, transfer_id,
      ingredient_id,
      ingredient_name_snapshot,
      unit_snapshot,
      requested_quantity,
      item_status
    ) values (
      p_tenant_id, v_transfer_id,
      v_ingredient.id,
      v_ingredient.ingredient_name,
      v_ingredient.unit,
      (v_item->>'requested_quantity')::numeric,
      'PENDING'
    );

    v_item_count := v_item_count + 1;
  end loop;

  if v_item_count = 0 then
    -- 유효한 항목 없음 → 요청 취소
    update catchmenu_store.stock_transfer_requests
    set request_status = 'CANCELLED'
    where id = v_transfer_id;

    return jsonb_build_object(
      'success', false,
      'error_key', 'no_valid_items',
      'message',
        '유효한 재고 항목이 없습니다'
    );
  end if;

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
    'inventory', 'stock_transfer_requested', 1,
    'stock_transfer', v_transfer_id,
    null, 'PENDING',
    'STAFF', p_requested_by,
    jsonb_build_object(
      'from_store_id', p_from_store_id,
      'to_store_id', p_to_store_id,
      'group_id', v_group_id,
      'item_count', v_item_count,
      'priority', p_priority,
      'reason', p_transfer_reason
    ),
    p_correlation_id,
    v_business_day, v_timezone, now()
  );

  return jsonb_build_object(
    'success', true,
    'transfer_id', v_transfer_id,
    'from_store_id', p_from_store_id,
    'to_store_id', p_to_store_id,
    'item_count', v_item_count,
    'request_status', 'PENDING',
    'priority', p_priority,
    'message_code', 'stock_transfer_requested'
  );
end;
$$;


create or replace function
  catchmenu_store.approve_stock_transfer(
  p_tenant_id uuid,
  p_transfer_id uuid,
  p_approved_by uuid,
  p_approved_by_type text default 'MANAGER',
  p_item_adjustments jsonb default null,
  p_rejected_reason text default null,
  p_approve boolean default true,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_store,
                  catchmenu_hq,
                  catchmenu_ledger,
                  catchmenu_audit,
                  catchmenu_common
as $$
declare
  v_transfer record;
  v_item record;
  v_approved_qty numeric;
  v_audit_id uuid;
  v_business_day date;
  v_timezone text;
begin
  -- 이동 요청 조회
  select id, from_store_id, to_store_id,
         group_id, request_status, priority
  into v_transfer
  from catchmenu_store.stock_transfer_requests
  where id = p_transfer_id
    and tenant_id = p_tenant_id
  for update;

  if v_transfer.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'order_not_found',
      p_locale := 'ko',
      p_tenant_id := p_tenant_id,
      p_rpc_name := 'approve_stock_transfer'
    );
  end if;

  if v_transfer.request_status <> 'PENDING' then
    return jsonb_build_object(
      'success', false,
      'error_key', 'transfer_not_pending',
      'current_status', v_transfer.request_status
    );
  end if;

  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = v_transfer.from_store_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  if not p_approve then
    -- 거절
    update catchmenu_store.stock_transfer_requests
    set
      request_status = 'REJECTED',
      approved_by = p_approved_by,
      approved_at = now(),
      rejected_reason = p_rejected_reason,
      updated_at = now()
    where id = p_transfer_id;

    update catchmenu_store.stock_transfer_items
    set
      item_status = 'REJECTED',
      updated_at = now()
    where transfer_id = p_transfer_id;

    insert into catchmenu_ledger.events (
      tenant_id, store_id,
      event_domain, event_type, event_version,
      subject_type, subject_id,
      from_state, to_state,
      caused_by_type, caused_by_id,
      event_payload, correlation_id,
      business_day, business_timezone, occurred_at
    ) values (
      p_tenant_id, v_transfer.from_store_id,
      'inventory', 'stock_transfer_rejected', 1,
      'stock_transfer', p_transfer_id,
      'PENDING', 'REJECTED',
      p_approved_by_type, p_approved_by,
      jsonb_build_object(
        'rejected_reason', p_rejected_reason
      ),
      p_correlation_id,
      v_business_day, v_timezone, now()
    );

    return jsonb_build_object(
      'success', true,
      'transfer_id', p_transfer_id,
      'request_status', 'REJECTED',
      'message_code', 'stock_transfer_rejected'
    );
  end if;

  -- 승인 처리
  update catchmenu_store.stock_transfer_requests
  set
    request_status = 'APPROVED',
    approved_by = p_approved_by,
    approved_at = now(),
    updated_at = now()
  where id = p_transfer_id;

  -- 항목별 승인 수량 + 재고 이동
  for v_item in
    select id, ingredient_id,
           ingredient_name_snapshot,
           requested_quantity
    from catchmenu_store.stock_transfer_items
    where transfer_id = p_transfer_id
      and item_status = 'PENDING'
  loop
    -- 조정된 수량 확인
    v_approved_qty := coalesce(
      (
        p_item_adjustments
          ->>(v_item.id::text)
      )::numeric,
      v_item.requested_quantity
    );

    if v_approved_qty <= 0 then
      update catchmenu_store.stock_transfer_items
      set item_status = 'REJECTED',
          approved_quantity = 0,
          updated_at = now()
      where id = v_item.id;
      continue;
    end if;

    -- 출고 매장 재고 차감
    insert into catchmenu_store.inventory_movements (
      tenant_id, store_id,
      ingredient_id,
      movement_type, quantity_change,
      quantity_before, quantity_after,
      reference_type, reference_id,
      movement_reason,
      business_day, business_timezone
    )
    select
      p_tenant_id, v_transfer.from_store_id,
      v_item.ingredient_id,
      'TRANSFER_OUT', -v_approved_qty,
      current_quantity,
      current_quantity - v_approved_qty,
      'stock_transfer', p_transfer_id,
      '매장간 이동 출고: '
        || v_item.ingredient_name_snapshot,
      v_business_day, v_timezone
    from catchmenu_store.ingredients
    where id = v_item.ingredient_id
      and store_id = v_transfer.from_store_id;

    -- 출고 매장 재고 차감
    update catchmenu_store.ingredients
    set
      current_quantity =
        current_quantity - v_approved_qty,
      ingredient_status = case
        when current_quantity - v_approved_qty <= 0
          then 'OUT_OF_STOCK'
        when current_quantity - v_approved_qty
          <= low_stock_threshold
          then 'LOW_STOCK'
        else 'NORMAL'
      end,
      updated_at = now()
    where id = v_item.ingredient_id
      and store_id = v_transfer.from_store_id;

    -- 입고 매장 재고 증가
    insert into catchmenu_store.inventory_movements (
      tenant_id, store_id,
      ingredient_id,
      movement_type, quantity_change,
      quantity_before, quantity_after,
      reference_type, reference_id,
      movement_reason,
      business_day, business_timezone
    )
    select
      p_tenant_id, v_transfer.to_store_id,
      v_item.ingredient_id,
      'TRANSFER_IN', v_approved_qty,
      coalesce(current_quantity, 0),
      coalesce(current_quantity, 0) + v_approved_qty,
      'stock_transfer', p_transfer_id,
      '매장간 이동 입고: '
        || v_item.ingredient_name_snapshot,
      v_business_day, v_timezone
    from catchmenu_store.ingredients
    where id = v_item.ingredient_id
      and store_id = v_transfer.to_store_id;

    -- 입고 매장 재고 증가
    update catchmenu_store.ingredients
    set
      current_quantity =
        coalesce(current_quantity, 0)
        + v_approved_qty,
      ingredient_status = case
        when coalesce(current_quantity, 0)
          + v_approved_qty > 0
          then 'NORMAL'
        else ingredient_status
      end,
      updated_at = now()
    where id = v_item.ingredient_id
      and store_id = v_transfer.to_store_id;

    -- 항목 상태 업데이트
    update catchmenu_store.stock_transfer_items
    set
      item_status = case
        when v_approved_qty
          = v_item.requested_quantity
          then 'TRANSFERRED'
        else 'PARTIAL'
      end,
      approved_quantity = v_approved_qty,
      actual_quantity = v_approved_qty,
      updated_at = now()
    where id = v_item.id;
  end loop;

  -- 이동 완료
  update catchmenu_store.stock_transfer_requests
  set
    request_status = 'COMPLETED',
    completed_at = now(),
    updated_at = now()
  where id = p_transfer_id;

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
    p_tenant_id, v_transfer.from_store_id,
    'inventory', 'stock_transfer_completed', 1,
    'stock_transfer', p_transfer_id,
    'APPROVED', 'COMPLETED',
    p_approved_by_type, p_approved_by,
    jsonb_build_object(
      'from_store_id', v_transfer.from_store_id,
      'to_store_id', v_transfer.to_store_id
    ),
    p_correlation_id,
    v_business_day, v_timezone, now()
  );

  -- audit
  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := v_transfer.from_store_id,
    p_audit_domain := 'inventory',
    p_audit_type := 'stock_transfer_approved',
    p_audit_category := 'OPERATIONAL',
    p_actor_type := p_approved_by_type,
    p_actor_id := p_approved_by,
    p_subject_type := 'stock_transfer',
    p_subject_id := p_transfer_id,
    p_decision := 'APPROVED',
    p_correlation_id := p_correlation_id,
    p_business_day := v_business_day,
    p_business_timezone := v_timezone
  );

  return jsonb_build_object(
    'success', true,
    'transfer_id', p_transfer_id,
    'request_status', 'COMPLETED',
    'audit_id', v_audit_id,
    'message_code', 'stock_transfer_completed'
  );
end;
$$;


create or replace function
  catchmenu_store.get_multistore_inventory(
  p_tenant_id uuid,
  p_group_id uuid,
  p_low_stock_only boolean default false
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_store,
                  catchmenu_hq,
                  catchmenu_common
as $$
declare
  v_inventory jsonb;
begin
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'store_id', s.id,
        'store_name', s.store_name,
        'ingredients', (
          select coalesce(
            jsonb_agg(
              jsonb_build_object(
                'ingredient_id', i.id,
                'ingredient_name',
                  i.ingredient_name,
                'ingredient_code',
                  i.ingredient_code,
                'unit', i.unit,
                'current_quantity',
                  i.current_quantity,
                'low_stock_threshold',
                  i.low_stock_threshold,
                'ingredient_status',
                  i.ingredient_status,
                'linked_menus',
                  jsonb_array_length(
                    coalesce(i.linked_menu_ids,
                      '[]'::jsonb)
                  )
              )
              order by
                case i.ingredient_status
                  when 'OUT_OF_STOCK' then 0
                  when 'LOW_STOCK' then 1
                  else 2
                end,
                i.ingredient_name
            ),
            '[]'::jsonb
          )
          from catchmenu_store.ingredients i
          where i.store_id = s.id
            and i.tenant_id = p_tenant_id
            and i.is_active = true
            and (
              not p_low_stock_only
              or i.ingredient_status in (
                'OUT_OF_STOCK', 'LOW_STOCK'
              )
            )
        )
      )
      order by s.store_name
    ),
    '[]'::jsonb
  )
  into v_inventory
  from catchmenu_hq.store_group_members sgm
  join catchmenu_hq.stores s
    on s.id = sgm.store_id
  where sgm.group_id = p_group_id
    and sgm.tenant_id = p_tenant_id
    and sgm.is_active = true
    and s.is_active = true;

  return jsonb_build_object(
    'success', true,
    'group_id', p_group_id,
    'low_stock_only', p_low_stock_only,
    'store_count', jsonb_array_length(v_inventory),
    'inventory', v_inventory,
    'message_code', 'multistore_inventory_loaded'
  );
end;
$$;


create or replace function
  catchmenu_hq.compare_store_performance(
  p_tenant_id uuid,
  p_group_id uuid,
  p_period_start date,
  p_period_end date,
  p_metric text default 'REVENUE'
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
  v_performance jsonb;
  v_ranking jsonb;
begin
  -- 매장별 성과 비교
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'rank', row_number() over (
          order by
            case p_metric
              when 'REVENUE' then
                coalesce(total_revenue, 0)
              when 'ORDER_COUNT' then
                coalesce(total_orders, 0)::numeric
              when 'CUSTOMER_COUNT' then
                coalesce(total_customers, 0)::numeric
              else coalesce(total_revenue, 0)
            end desc
        ),
        'store_id', store_id,
        'store_name', store_name,
        'store_code', store_code,
        'member_role', member_role,
        'total_revenue',
          coalesce(total_revenue, 0),
        'total_orders',
          coalesce(total_orders, 0),
        'total_customers',
          coalesce(total_customers, 0),
        'avg_order_value',
          case when coalesce(total_orders, 0) > 0
          then (
            coalesce(total_revenue, 0)
            / total_orders
          )::int
          else 0 end,
        'metric_value', case p_metric
          when 'REVENUE' then
            coalesce(total_revenue, 0)
          when 'ORDER_COUNT' then
            coalesce(total_orders, 0)::numeric
          when 'CUSTOMER_COUNT' then
            coalesce(total_customers, 0)::numeric
          else coalesce(total_revenue, 0)
        end
      )
    ),
    '[]'::jsonb
  )
  into v_ranking
  from (
    select
      s.id as store_id,
      s.store_name,
      s.store_code,
      sgm.member_role,
      sum(pl.net_amount) as total_revenue,
      count(distinct o.id) as total_orders,
      count(distinct os.id) filter (
        where os.session_type in (
          'WALK_IN', 'WAITING', 'KIOSK'
        )
      ) as total_customers
    from catchmenu_hq.store_group_members sgm
    join catchmenu_hq.stores s
      on s.id = sgm.store_id
    left join catchmenu_payment.payment_ledger pl
      on pl.store_id = s.id
      and pl.tenant_id = p_tenant_id
      and pl.business_day between
        p_period_start and p_period_end
      and pl.ledger_status = 'APPROVED'
    left join catchmenu_pos.orders o
      on o.store_id = s.id
      and o.tenant_id = p_tenant_id
      and o.business_day between
        p_period_start and p_period_end
      and o.order_status = 'COMPLETED'
    left join catchmenu_pos.order_sessions os
      on os.store_id = s.id
      and os.tenant_id = p_tenant_id
      and os.business_day between
        p_period_start and p_period_end
    where sgm.group_id = p_group_id
      and sgm.tenant_id = p_tenant_id
      and sgm.is_active = true
      and s.is_active = true
    group by s.id, s.store_name,
             s.store_code, sgm.member_role
  ) perf;

  return jsonb_build_object(
    'success', true,
    'group_id', p_group_id,
    'period_start', p_period_start,
    'period_end', p_period_end,
    'metric', p_metric,
    'ranking', v_ranking,
    'store_count', jsonb_array_length(v_ranking),
    'message_code', 'store_performance_compared'
  );
end;
$$;


-- grants
do $$
begin
  revoke all on function
    catchmenu_hq.create_store_group(
      uuid, text, text, text, jsonb,
      uuid, boolean, boolean, text, uuid, text
    ) from public;
  grant execute on function
    catchmenu_hq.create_store_group(
      uuid, text, text, text, jsonb,
      uuid, boolean, boolean, text, uuid, text
    ) to authenticated;

  revoke all on function
    catchmenu_hq.get_store_group_dashboard(
      uuid, uuid, date
    ) from public;
  grant execute on function
    catchmenu_hq.get_store_group_dashboard(
      uuid, uuid, date
    ) to authenticated;

  revoke all on function
    catchmenu_store.request_stock_transfer(
      uuid, uuid, uuid, text, jsonb,
      text, text, uuid, text
    ) from public;
  grant execute on function
    catchmenu_store.request_stock_transfer(
      uuid, uuid, uuid, text, jsonb,
      text, text, uuid, text
    ) to authenticated;

  revoke all on function
    catchmenu_store.approve_stock_transfer(
      uuid, uuid, uuid, text, jsonb,
      text, boolean, text
    ) from public;
  grant execute on function
    catchmenu_store.approve_stock_transfer(
      uuid, uuid, uuid, text, jsonb,
      text, boolean, text
    ) to authenticated;

  revoke all on function
    catchmenu_store.get_multistore_inventory(
      uuid, uuid, boolean
    ) from public;
  grant execute on function
    catchmenu_store.get_multistore_inventory(
      uuid, uuid, boolean
    ) to authenticated;

  revoke all on function
    catchmenu_hq.compare_store_performance(
      uuid, uuid, date, date, text
    ) from public;
  grant execute on function
    catchmenu_hq.compare_store_performance(
      uuid, uuid, date, date, text
    ) to authenticated;
end;
$$;

comment on function
  catchmenu_hq.create_store_group(
    uuid, text, text, text, jsonb,
    uuid, boolean, boolean, text, uuid, text
  ) is
  '매장 그룹 생성.
   첫 번째 매장 = LEADER 자동 지정.
   cross_store_transfer_enabled = true:
   매장간 재고 이동 허용.
   3차 Franchise_OS 사전 구조:
   REGION → BRAND → FRANCHISE → DISTRICT
   계층 구조로 확장 가능.';

comment on function
  catchmenu_store.approve_stock_transfer(
    uuid, uuid, uuid, text, jsonb,
    text, boolean, text
  ) is
  '재고 이동 승인 + 즉시 재고 반영.
   출고 매장: current_quantity 차감.
   입고 매장: current_quantity 증가.
   inventory_movements 양방향 기록.
   특허4: 재고 이동 = 감사 추적 가능 원장.
   p_approve = false → 거절 처리.';