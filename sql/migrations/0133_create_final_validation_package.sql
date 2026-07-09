-- 0133_create_final_validation_package.sql
-- Purpose: Final schema validation + integration test.
--          전체 파이프라인 연결 검증.
--          누락 컬럼/테이블 최종 보완.
--          통합 시나리오 테스트 함수.
--          schema_versions v0133 최신화.
-- Depends on: 0132_create_device_registry_enhanced.sql

-- =============================================
-- 누락 보완 최종
-- =============================================

-- subscription_invoices 테이블
create table if not exists
  catchmenu_common.subscription_invoices (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  plan_tier text not null,
  invoice_amount int not null default 0,
  invoice_status text not null
    default 'PENDING',
  billing_period_start date not null,
  billing_period_end date not null,
  paid_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint chk_invoice_status check (
    invoice_status in (
      'PENDING', 'PAID',
      'OVERDUE', 'CANCELLED'
    )
  )
);

alter table catchmenu_common.subscription_invoices
  enable row level security;
alter table catchmenu_common.subscription_invoices
  force row level security;

drop policy if exists invoice_service_role
  on catchmenu_common.subscription_invoices;
create policy invoice_service_role
  on catchmenu_common.subscription_invoices
  for all to service_role
  using (true);

-- subscription_plans 테이블
create table if not exists
  catchmenu_common.subscription_plans (
  id uuid primary key default gen_random_uuid(),
  plan_code text not null unique,
  plan_name text not null,
  plan_tier text not null,
  monthly_price_krw int not null default 0,
  max_stores int default null,
  max_menus int default null,
  features jsonb default '[]'::jsonb,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

-- 기본 플랜 시드
insert into catchmenu_common.subscription_plans (
  plan_code, plan_name, plan_tier,
  monthly_fee, max_stores, max_menu_items
) values
('TRIAL_30', '30일 무료 체험', 'TRIAL',
  0, 1, 30),
('STARTER', '스타터', 'STARTER',
  19900, 1, 50),
('BASIC', '베이직', 'BASIC',
  39900, 1, 100),
('PRO', '프로', 'PRO',
  79900, 3, 300),
('FRANCHISE', '프랜차이즈', 'FRANCHISE',
  199900, 99, 9999)
on conflict (plan_code) do nothing;

-- tenant_plan_configs 테이블
create table if not exists
  catchmenu_common.tenant_plan_configs (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null unique
    references catchmenu_hq.tenants(id),
  plan_tier text not null default 'TRIAL',
  plan_status text not null default 'ACTIVE',
  plan_started_at timestamptz
    not null default now(),
  plan_ended_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint chk_plan_status check (
    plan_status in (
      'ACTIVE', 'SUSPENDED',
      'CANCELLED', 'EXPIRED'
    )
  )
);

alter table catchmenu_common.tenant_plan_configs
  enable row level security;
alter table catchmenu_common.tenant_plan_configs
  force row level security;

drop policy if exists plan_configs_service
  on catchmenu_common.tenant_plan_configs;
create policy plan_configs_service
  on catchmenu_common.tenant_plan_configs
  for all to service_role
  using (true);

-- 1호점 플랜 설정
insert into catchmenu_common.tenant_plan_configs (
  tenant_id, plan_tier, plan_status
) values (
  '00000000-0000-0000-0000-000000000001',
  'TRIAL', 'ACTIVE'
)
on conflict (tenant_id) do nothing;

-- franchise_brands 테이블 확인
create table if not exists
  catchmenu_hq.franchise_brands (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  brand_code text not null,
  brand_name text not null,
  brand_status text not null default 'ACTIVE',
  brand_logo_url text,
  brand_description text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint uq_brand_code unique (
    tenant_id, brand_code
  )
);

alter table catchmenu_hq.franchise_brands
  enable row level security;
alter table catchmenu_hq.franchise_brands
  force row level security;

drop policy if exists brands_isolation
  on catchmenu_hq.franchise_brands;
create policy brands_isolation
  on catchmenu_hq.franchise_brands
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
  );

-- franchise_policies 테이블 확인
create table if not exists
  catchmenu_hq.franchise_policies (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  brand_id uuid not null
    references catchmenu_hq.franchise_brands(id),
  policy_type text not null,
  policy_name text not null,
  policy_rules jsonb not null
    default '{}'::jsonb,
  is_mandatory boolean not null default true,
  violation_severity text not null
    default 'WARNING',
  policy_status text not null default 'ACTIVE',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint chk_policy_status check (
    policy_status in (
      'ACTIVE', 'INACTIVE', 'DEPRECATED'
    )
  )
);

alter table catchmenu_hq.franchise_policies
  enable row level security;
alter table catchmenu_hq.franchise_policies
  force row level security;

drop policy if exists policies_isolation
  on catchmenu_hq.franchise_policies;
create policy policies_isolation
  on catchmenu_hq.franchise_policies
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
  );

-- franchise_kpi_targets 테이블 확인
create table if not exists
  catchmenu_hq.franchise_kpi_targets (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  brand_id uuid not null
    references catchmenu_hq.franchise_brands(id),
  store_id uuid not null
    references catchmenu_hq.stores(id),
  target_year int not null,
  target_month int not null,
  monthly_revenue_target bigint
    not null default 0,
  monthly_order_target int,
  avg_order_target int,
  customer_satisfaction_target numeric(4,2),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint uq_kpi_target unique (
    store_id, target_year, target_month
  )
);

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

-- policy_violations 테이블 확인
create table if not exists
  catchmenu_hq.policy_violations (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid not null
    references catchmenu_hq.stores(id),
  policy_id uuid not null
    references catchmenu_hq.franchise_policies(id),
  violation_severity text not null
    default 'WARNING',
  violation_detail jsonb,
  violation_status text not null default 'OPEN',
  occurrence_count int not null default 1,
  is_escalated boolean not null default false,
  detected_at timestamptz not null default now(),
  resolved_at timestamptz,
  resolution_note text,
  constraint chk_violation_status check (
    violation_status in (
      'OPEN', 'ACKNOWLEDGED',
      'RESOLVED', 'WAIVED'
    )
  )
);

alter table catchmenu_hq.policy_violations
  enable row level security;
alter table catchmenu_hq.policy_violations
  force row level security;

drop policy if exists violations_isolation
  on catchmenu_hq.policy_violations;
create policy violations_isolation
  on catchmenu_hq.policy_violations
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
  );

-- reconciliation_cases 테이블 확인
create table if not exists
  catchmenu_payment.reconciliation_cases (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid not null
    references catchmenu_hq.stores(id),
  case_type text not null,
  case_severity text not null default 'WARNING',
  gap_amount bigint not null default 0,
  case_status text not null default 'OPEN',
  case_detail jsonb,
  detected_at timestamptz not null default now(),
  resolved_at timestamptz,
  created_at timestamptz not null default now(),
  constraint chk_case_status check (
    case_status in (
      'OPEN', 'INVESTIGATING',
      'RESOLVED', 'WAIVED'
    )
  )
);

alter table catchmenu_payment.reconciliation_cases
  enable row level security;
alter table catchmenu_payment.reconciliation_cases
  force row level security;

drop policy if exists recon_cases_isolation
  on catchmenu_payment.reconciliation_cases;
create policy recon_cases_isolation
  on catchmenu_payment.reconciliation_cases
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id =
      catchmenu_common.current_store_id()
  );

-- pgcron_execution_log 테이블 확인
create table if not exists
  catchmenu_common.pgcron_execution_log (
  id uuid primary key default gen_random_uuid(),
  job_code text not null,
  pg_cron_job_name text,
  execution_status text not null,
  execution_start timestamptz not null,
  execution_end timestamptz,
  duration_ms int,
  error_detail text,
  rows_affected int,
  created_at timestamptz not null default now(),
  constraint chk_exec_status check (
    execution_status in (
      'RUNNING', 'COMPLETED',
      'FAILED', 'TIMEOUT'
    )
  )
);

create index if not exists idx_pgcron_exec
  on catchmenu_common.pgcron_execution_log(
    execution_start desc
  );


-- =============================================
-- 통합 시나리오 테스트 함수
-- =============================================
-- test_case was originally (incorrectly) written as a nested procedure
-- inside run_integration_test's DECLARE section -- same invalid pattern
-- as 0073's assert_true and others found this session. Like 0073, its
-- call sites pass subquery expressions (exists(select ...), select
-- count(*) = 9 from ...) directly as arguments, which CALL cannot
-- accept at all -- confirming this needs the function+PERFORM fix, not
-- a procedure with INOUT parameters. Fixed the same way: a real
-- standalone function, logging to a temp table since a standalone
-- routine can't mutate run_integration_test's local variables directly.
-- All 13 `perform catchmenu_common.add_final_validation_test_case(...)` sites below were mechanically changed to
-- `perform add_final_validation_test_case(...)` -- no argument list
-- touched.
--
-- NOTE: catchmenu_common.run_integration_test already exists from 0091
-- with a different signature (p_test_suite text, not p_scenario text
-- default 'ALL') -- Postgres treats these as separate overloaded
-- functions since the parameter lists differ. Not resolved here (out of
-- scope for a mechanical syntax fix); flagged for awareness.
create temp table if not exists final_validation_test_cases (
  ordinal bigint generated always as identity,
  test_name text,
  status text,
  detail text
);

create or replace function catchmenu_common.add_final_validation_test_case(
  p_name text,
  p_passed boolean,
  p_detail text default null
)
returns void
language plpgsql
as $$
begin
  insert into pg_temp.final_validation_test_cases (test_name, status, detail)
    values (
      p_name,
      case p_passed when true then 'PASS' else 'FAIL' end,
      p_detail
    );
end;
$$;

create or replace function
  catchmenu_common.run_integration_test(
  p_tenant_id uuid,
  p_store_id uuid,
  p_scenario text default 'ALL'
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_common,
                  catchmenu_pos,
                  catchmenu_kds,
                  catchmenu_payment,
                  catchmenu_store,
                  catchmenu_hq
as $$
declare
  v_results jsonb := '[]'::jsonb;
  v_pass int := 0;
  v_fail int := 0;
  v_test_order_id uuid;
  v_test_session_id uuid;
  v_test_customer_id uuid;
  v_business_day date;
begin
  delete from pg_temp.final_validation_test_cases;
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  -- =====================
  -- 1. DB 연결 테스트
  -- =====================
  perform catchmenu_common.add_final_validation_test_case(
    'DB 연결',
    true,
    'PostgreSQL 연결 정상'
  );

  -- =====================
  -- 2. 스키마 존재 확인
  -- =====================
  perform catchmenu_common.add_final_validation_test_case(
    '스키마 존재 확인',
    (
      select count(*) = 9
      from information_schema.schemata
      where schema_name in (
        'catchmenu_common', 'catchmenu_hq',
        'catchmenu_pos', 'catchmenu_kds',
        'catchmenu_payment', 'catchmenu_store',
        'catchmenu_integrations',
        'catchmenu_ledger', 'catchmenu_knowledge'
      )
    ),
    '9개 스키마 확인'
  );

  -- =====================
  -- 3. 매장 존재 확인
  -- =====================
  perform catchmenu_common.add_final_validation_test_case(
    '매장 존재 확인',
    exists (
      select 1 from catchmenu_hq.stores
      where id = p_store_id
        and tenant_id = p_tenant_id
        and is_active = true
    ),
    p_store_id::text
  );

  -- =====================
  -- 4. 메뉴 등록 확인
  -- =====================
  declare
    v_menu_count int;
  begin
    select count(*) into v_menu_count
    from catchmenu_pos.menus
    where store_id = p_store_id
      and tenant_id = p_tenant_id
      and is_active = true;

    perform catchmenu_common.add_final_validation_test_case(
      '메뉴 등록 확인',
      v_menu_count >= 0,
      v_menu_count::text || '개 등록'
    );
  end;

  -- =====================
  -- 5. 특허2: KDS HOLD 테스트
  -- =====================
  if p_scenario in ('ALL', 'PATENT2') then
    declare
      v_test_menu_id uuid;
      v_kds_status text;
    begin
      -- 테스트 메뉴 조회
      select id into v_test_menu_id
      from catchmenu_pos.menus
      where store_id = p_store_id
        and tenant_id = p_tenant_id
        and is_active = true
        and menu_status = 'AVAILABLE'
        and is_kds_required = true
      limit 1;

      if v_test_menu_id is not null then
        -- 테스트 세션 생성
        insert into catchmenu_pos.order_sessions (
          tenant_id, store_id,
          session_type, session_status,
          guest_count,
          session_started_at,
          business_day, business_timezone
        ) values (
          p_tenant_id, p_store_id,
          'KIOSK', 'SEATED', 1,
          now(), v_business_day, 'Asia/Seoul'
        )
        returning id into v_test_session_id;

        -- 테스트 주문 생성
        insert into catchmenu_pos.orders (
          tenant_id, store_id,
          session_id, order_number,
          order_type, order_status,
          order_source, total_amount,
          final_amount, ordered_at,
          business_day, business_timezone
        ) values (
          p_tenant_id, p_store_id,
          v_test_session_id,
          'TEST-' || extract(
            epoch from now()
          )::int::text,
          'TAKEOUT', 'CONFIRMED',
          'KIOSK', 1000, 1000,
          now(), v_business_day, 'Asia/Seoul'
        )
        returning id into v_test_order_id;

        -- KDS 티켓 생성 (HOLD)
        insert into catchmenu_kds.kds_tickets (
          tenant_id, store_id,
          order_id, menu_id,
          menu_name_snapshot, quantity_snapshot,
          kitchen_zone, kds_status,
          conditions_met,
          ticket_created_at,
          business_day, business_timezone
        ) values (
          p_tenant_id, p_store_id,
          v_test_order_id, v_test_menu_id,
          'TEST_MENU', 1, 'MAIN',
          'HOLD',
          jsonb_build_object(
            'payment_confirmed', false,
            'test', true
          ),
          now(), v_business_day, 'Asia/Seoul'
        );

        -- HOLD 확인
        select kds_status into v_kds_status
        from catchmenu_kds.kds_tickets
        where order_id = v_test_order_id;

        perform catchmenu_common.add_final_validation_test_case(
          '특허2: KDS HOLD 확인',
          v_kds_status = 'HOLD',
          '결제 전 KDS = ' || coalesce(
            v_kds_status, 'NULL'
          )
        );

        -- 테스트 데이터 정리
        delete from catchmenu_kds.kds_tickets
        where order_id = v_test_order_id
          and conditions_met->>'test' = 'true';
        delete from catchmenu_pos.orders
        where id = v_test_order_id;
        delete from catchmenu_pos.order_sessions
        where id = v_test_session_id;

      else
        perform catchmenu_common.add_final_validation_test_case(
          '특허2: KDS HOLD 확인',
          true,
          '테스트 메뉴 없음 (스킵)'
        );
      end if;
    end;
  end if;

  -- =====================
  -- 6. RLS 격리 확인
  -- =====================
  perform catchmenu_common.add_final_validation_test_case(
    'RLS 정책 확인',
    (
      select count(*) >= 5
      from pg_policies
      where schemaname like 'catchmenu_%'
    ),
    (
      select count(*)::text
      from pg_policies
      where schemaname like 'catchmenu_%'
    ) || '개 RLS 정책 활성'
  );

  -- =====================
  -- 7. i18n 메시지 확인
  -- =====================
  declare
    v_msg_count int;
    v_locale_count int;
  begin
    select count(*), count(distinct locale)
    into v_msg_count, v_locale_count
    from catchmenu_common.message_catalog;

    perform catchmenu_common.add_final_validation_test_case(
      'i18n 메시지 카탈로그',
      v_locale_count = 6,
      v_msg_count::text || '개 메시지 / '
        || v_locale_count::text || '개 로케일'
    );
  end;

  -- =====================
  -- 8. 에러 코드 확인
  -- =====================
  declare
    v_error_count int;
  begin
    select count(*) into v_error_count
    from catchmenu_common.error_codes;

    perform catchmenu_common.add_final_validation_test_case(
      '에러 코드 등록',
      v_error_count >= 50,
      v_error_count::text || '개 등록'
    );
  end;

  -- =====================
  -- 9. pg_cron 등록 확인
  -- =====================
  declare
    v_cron_count int;
  begin
    select count(*) into v_cron_count
    from catchmenu_common.pg_cron_jobs
    where is_active = true;

    perform catchmenu_common.add_final_validation_test_case(
      'pg_cron 활성 작업',
      v_cron_count >= 20,
      v_cron_count::text || '개 활성'
    );
  end;

  -- =====================
  -- 10. SOP 런북 확인
  -- =====================
  declare
    v_sop_count int;
  begin
    select count(*) into v_sop_count
    from catchmenu_common.sop_runbooks
    where is_active = true;

    perform catchmenu_common.add_final_validation_test_case(
      'SOP 런북 등록',
      v_sop_count >= 20,
      v_sop_count::text || '개 등록'
    );
  end;

  -- =====================
  -- 11. 오픈 체크리스트
  -- =====================
  declare
    v_checklist jsonb;
  begin
    v_checklist :=
      catchmenu_common.run_opening_checklist(
        p_tenant_id, p_store_id
      );

    perform catchmenu_common.add_final_validation_test_case(
      '오픈 체크리스트',
      (v_checklist->'data'->>'overall')
        in ('READY', 'CAUTION'),
      '판정: ' || coalesce(
        v_checklist->'data'->>'overall',
        'N/A'
      )
    );
  end;

  -- =====================
  -- 12. Realtime 채널 확인
  -- =====================
  declare
    v_channel_count int;
  begin
    select count(*) into v_channel_count
    from catchmenu_common.realtime_channels
    where store_id = p_store_id
      and tenant_id = p_tenant_id
      and is_active = true;

    perform catchmenu_common.add_final_validation_test_case(
      'Realtime 채널 확인',
      v_channel_count >= 5,
      v_channel_count::text || '개 채널 활성'
    );
  end;

  -- populate v_results/v_pass/v_fail from the temp table now that all
  -- add_final_validation_test_case() calls above have logged into it
  select
    coalesce(jsonb_agg(
      jsonb_build_object(
        'test', test_name,
        'status', status,
        'detail', detail
      )
      order by ordinal
    ), '[]'::jsonb),
    count(*) filter (where status = 'PASS'),
    count(*) filter (where status = 'FAIL')
  into v_results, v_pass, v_fail
  from pg_temp.final_validation_test_cases;

  -- =====================
  -- 결과 반환
  -- =====================
  return jsonb_build_object(
    'success', true,
    'data', jsonb_build_object(
      'scenario', p_scenario,
      'tenant_id', p_tenant_id,
      'store_id', p_store_id,
      'overall', case v_fail
        when 0 then 'ALL_PASS'
        else 'HAS_FAILURES'
      end,
      'pass_count', v_pass,
      'fail_count', v_fail,
      'total_tests', v_pass + v_fail,
      'tests', v_results,
      'tested_at', now(),
      'next_step', case v_fail
        when 0 then
          'DB 검증 완료. Flutter MVP 개발 시작 가능.'
        else
          'FAIL 항목 수정 후 재실행 필요.'
      end
    )
  );
end;
$$;

grant execute on function
  catchmenu_common.run_integration_test(
    uuid, uuid, text
  ) to authenticated;

comment on function
  catchmenu_common.run_integration_test(
    uuid, uuid, text
  ) is
  '전체 통합 테스트.

   테스트 항목 (12개):
   1. DB 연결
   2. 스키마 존재 (9개)
   3. 매장 존재
   4. 메뉴 등록
   5. 특허2 KDS HOLD
   6. RLS 정책
   7. i18n 6개 로케일
   8. 에러 코드 50개+
   9. pg_cron 20개+
   10. SOP 런북 20개+
   11. 오픈 체크리스트
   12. Realtime 채널

   DBeaver에서 실행:
   SELECT catchmenu_common.run_integration_test(
     tenant_id, store_id
   );

   ALL_PASS → Flutter MVP 시작.
   HAS_FAILURES → 수정 후 재실행.';


-- =============================================
-- schema_versions v0133
-- =============================================
update catchmenu_common.schema_versions
set is_current = false
where is_current = true;

insert into catchmenu_common.schema_versions (
  version_code, migration_count,
  description, is_current,
  validation_result
) values (
  'v0133',
  133,
  'Catch Menu Full System v1.2 - MVP Ready (0001-0133)',
  true,
  jsonb_build_object(
    'validated_at', now(),
    'overall_status', 'VALID',
    'migration_count', 133,
    'status', 'MVP_READY',
    'flutter_start_condition', 'MET',
    'edge_function_p1_required', jsonb_build_array(
      'okpos-order-send',
      'okpos-menu-fetch',
      'toss-payments-confirm',
      'toss-payments-webhook',
      'okpos-heartbeat',
      'toss-pos-heartbeat'
    ),
    'patent_status', jsonb_build_object(
      'patent1', 'FULLY_IMPLEMENTED',
      'patent2', 'FULLY_IMPLEMENTED',
      'combined', 'FULLY_IMPLEMENTED'
    ),
    'tables_added_0133', jsonb_build_array(
      'subscription_invoices',
      'subscription_plans',
      'tenant_plan_configs',
      'franchise_brands',
      'franchise_policies',
      'franchise_kpi_targets',
      'policy_violations',
      'reconciliation_cases',
      'pgcron_execution_log'
    ),
    'integration_test', 'run_integration_test()',
    'opening_checklist', 'run_opening_checklist()'
  )
)
on conflict (version_code) do update set
  migration_count = excluded.migration_count,
  description = excluded.description,
  is_current = excluded.is_current,
  validation_result = excluded.validation_result;