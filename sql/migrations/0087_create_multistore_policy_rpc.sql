-- 0087_create_multistore_policy_rpc.sql
-- Purpose: Multi-store policy distribution and compliance RPCs.
--          Policy version management, compliance monitoring,
--          violation detection, escalation workflow.
--          3차 Franchise_OS 사전 작업.
--          1-C차 완전 SaaS 공통 모듈.
--          i18n: 모든 메시지 = message_catalog 참조.
-- Depends on: 0086_create_hq_menu_distribution_rpc.sql
-- Creates:
--   catchmenu_hq.policy_compliance_checks (table)
--   catchmenu_hq.policy_violations (table)
--   catchmenu_hq.escalation_log (table)
--   function catchmenu_hq.run_compliance_check(...)
--   function catchmenu_hq.detect_policy_violations(...)
--   function catchmenu_hq.escalate_violation(...)
--   function catchmenu_hq.get_policy_compliance_summary(...)
--   function catchmenu_hq.rollback_policy(...)
--   function catchmenu_hq.bulk_policy_distribution(...)

-- =============================================
-- i18n 메시지 등록
-- =============================================
insert into catchmenu_common.message_catalog (
  message_key, locale, message_text
) values
('compliance_check_passed', 'ko',
  '정책 준수 검사를 통과했습니다'),
('compliance_check_passed', 'en',
  'Compliance check passed'),
('compliance_check_failed', 'ko',
  '정책 준수 검사에서 위반이 발견되었습니다'),
('compliance_check_failed', 'en',
  'Compliance violations detected'),
('violation_detected', 'ko',
  '정책 위반이 감지되었습니다'),
('violation_detected', 'en',
  'Policy violation detected'),
('violation_escalated', 'ko',
  '정책 위반이 에스컬레이션되었습니다'),
('violation_escalated', 'en',
  'Policy violation escalated'),
('policy_rolled_back', 'ko',
  '정책이 이전 버전으로 복구되었습니다'),
('policy_rolled_back', 'en',
  'Policy rolled back to previous version'),
('bulk_distribution_completed', 'ko',
  '{policy_count}개 정책이 배포되었습니다'),
('bulk_distribution_completed', 'en',
  '{policy_count} policies distributed'),
('compliance_summary_loaded', 'ko',
  '컴플라이언스 현황이 로드되었습니다'),
('compliance_summary_loaded', 'en',
  'Compliance summary loaded'),
('policy_rollback_not_available', 'ko',
  '복구할 이전 버전 정책이 없습니다'),
('policy_rollback_not_available', 'en',
  'No previous version available for rollback'),
('violation_not_found', 'ko',
  '위반 항목을 찾을 수 없습니다'),
('violation_not_found', 'en',
  'Violation not found'),
('no_policies_to_distribute', 'ko',
  '배포할 정책이 없습니다'),
('no_policies_to_distribute', 'en',
  'No policies to distribute')
on conflict (message_key, locale) do nothing;

insert into catchmenu_common.error_codes (
  code, error_key, error_domain,
  error_category, http_status, severity
) values
(11015, 'violation_not_found',
  'FRANCHISE', 'NOT_FOUND', 404, 'WARNING'),
(11016, 'policy_rollback_not_available',
  'FRANCHISE', 'BUSINESS_RULE', 409, 'WARNING'),
(11017, 'no_policies_to_distribute',
  'FRANCHISE', 'NOT_FOUND', 404, 'INFO'),
(11018, 'compliance_check_in_progress',
  'FRANCHISE', 'CONFLICT', 409, 'INFO')
on conflict (code) do nothing;


-- =============================================
-- policy_compliance_checks table
-- 정책 준수 검사 결과
-- =============================================
create table if not exists
  catchmenu_hq.policy_compliance_checks (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  brand_id uuid not null
    references catchmenu_hq.franchise_brands(id),
  store_id uuid not null
    references catchmenu_hq.stores(id),
  policy_id uuid not null
    references catchmenu_hq.franchise_policies(id),

  -- 검사 결과
  check_status text not null default 'PENDING',
  compliance_status text
    not null default 'PENDING',
  check_score int not null default 0,

  -- 검사 항목
  total_items int not null default 0,
  passed_items int not null default 0,
  failed_items int not null default 0,
  warning_items int not null default 0,

  -- 상세 결과
  check_results jsonb default '[]'::jsonb,
  violations_found jsonb default '[]'::jsonb,

  -- 타임스탬프
  checked_at timestamptz not null default now(),
  next_check_at timestamptz,
  check_duration_ms int,

  created_at timestamptz not null default now(),

  constraint chk_check_status check (
    check_status in (
      'PENDING', 'RUNNING',
      'COMPLETED', 'FAILED'
    )
  ),
  constraint chk_check_compliance check (
    compliance_status in (
      'PENDING', 'COMPLIANT',
      'NON_COMPLIANT', 'PARTIAL',
      'EXCEPTION_GRANTED'
    )
  )
);

create index if not exists idx_compliance_checks_store
  on catchmenu_hq.policy_compliance_checks(
    store_id, policy_id, checked_at desc
  );
create index if not exists idx_compliance_checks_brand
  on catchmenu_hq.policy_compliance_checks(
    brand_id, compliance_status, checked_at desc
  );

alter table
  catchmenu_hq.policy_compliance_checks
  enable row level security;
alter table
  catchmenu_hq.policy_compliance_checks
  force row level security;

drop policy if exists compliance_checks_isolation
  on catchmenu_hq.policy_compliance_checks;
create policy compliance_checks_isolation
  on catchmenu_hq.policy_compliance_checks
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
  );

comment on table
  catchmenu_hq.policy_compliance_checks is
  '정책 준수 검사 결과.
   check_score: 0~100 (100 = 완전 준수).
   COMPLIANT: 전 항목 통과.
   PARTIAL: 일부 항목 통과.
   NON_COMPLIANT: 주요 항목 위반.
   EXCEPTION_GRANTED: 예외 승인.
   3차 Franchise_OS 컴플라이언스 기반.
   1-C차 완전 SaaS 공통 모듈.';


-- =============================================
-- policy_violations table
-- 정책 위반 기록
-- =============================================
create table if not exists
  catchmenu_hq.policy_violations (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  brand_id uuid not null
    references catchmenu_hq.franchise_brands(id),
  store_id uuid not null
    references catchmenu_hq.stores(id),
  policy_id uuid not null
    references catchmenu_hq.franchise_policies(id),
  check_id uuid
    references catchmenu_hq
      .policy_compliance_checks(id),

  -- 위반 정보
  violation_code text not null,
  violation_type text not null,
  violation_severity text
    not null default 'WARNING',
  violation_description text not null,

  -- 위반 상세
  violated_rule text,
  actual_value jsonb,
  expected_value jsonb,

  -- 상태
  violation_status text
    not null default 'OPEN',
  detected_at timestamptz
    not null default now(),
  resolved_at timestamptz,
  resolved_by uuid,
  resolution_note text,

  -- 에스컬레이션
  is_escalated boolean not null default false,
  escalated_at timestamptz,
  escalation_level int not null default 0,

  -- 반복 횟수
  occurrence_count int not null default 1,
  first_detected_at timestamptz
    not null default now(),
  last_detected_at timestamptz
    not null default now(),

  business_day date,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint chk_violation_type check (
    violation_type in (
      'MENU_NON_COMPLIANCE',
      'PRICE_VIOLATION',
      'QUALITY_VIOLATION',
      'OPERATION_VIOLATION',
      'STAFF_VIOLATION',
      'PROMOTION_VIOLATION',
      'COMPLIANCE_BREACH',
      'CUSTOM'
    )
  ),
  constraint chk_violation_severity check (
    violation_severity in (
      'INFO', 'WARNING', 'ERROR',
      'CRITICAL', 'FATAL'
    )
  ),
  constraint chk_violation_status check (
    violation_status in (
      'OPEN', 'ACKNOWLEDGED',
      'IN_REMEDIATION', 'RESOLVED',
      'EXCEPTION_GRANTED', 'DISMISSED'
    )
  )
);

create index if not exists idx_violations_store
  on catchmenu_hq.policy_violations(
    store_id, violation_status,
    violation_severity
  ) where violation_status in (
    'OPEN', 'ACKNOWLEDGED', 'IN_REMEDIATION'
  );
create index if not exists idx_violations_brand
  on catchmenu_hq.policy_violations(
    brand_id, violation_severity, detected_at desc
  );
create index if not exists idx_violations_policy
  on catchmenu_hq.policy_violations(
    policy_id, violation_type
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

drop trigger if exists trg_violations_updated
  on catchmenu_hq.policy_violations;
create trigger trg_violations_updated
  before update on catchmenu_hq.policy_violations
  for each row execute function
    catchmenu_common.set_updated_at();

comment on table catchmenu_hq.policy_violations is
  '정책 위반 기록.
   occurrence_count: 동일 위반 반복 횟수.
   OPEN → ACKNOWLEDGED → IN_REMEDIATION → RESOLVED.
   is_escalated: 에스컬레이션 여부.
   escalation_level: 1=팀장, 2=점장, 3=HQ.
   CRITICAL/FATAL 위반 → 자동 에스컬레이션.
   3차 Franchise_OS 컴플라이언스 핵심.
   1-C차 완전 SaaS 공통 감사 모듈.';


-- =============================================
-- escalation_log table
-- 위반 에스컬레이션 이력
-- =============================================
create table if not exists
  catchmenu_hq.escalation_log (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  violation_id uuid not null
    references catchmenu_hq.policy_violations(id),
  store_id uuid not null
    references catchmenu_hq.stores(id),
  brand_id uuid not null
    references catchmenu_hq.franchise_brands(id),

  -- 에스컬레이션 정보
  escalation_level int not null,
  escalation_reason text not null,
  escalated_to_type text not null,
  escalated_to_id uuid,

  -- 결과
  escalation_status text
    not null default 'PENDING',
  resolved_at timestamptz,
  resolution_note text,

  -- 자동/수동
  is_auto_escalated boolean
    not null default false,
  triggered_by_occurrence_count int,

  escalated_at timestamptz
    not null default now(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint chk_escalation_status check (
    escalation_status in (
      'PENDING', 'ACKNOWLEDGED',
      'RESOLVED', 'DISMISSED'
    )
  ),
  constraint chk_escalated_to_type check (
    escalated_to_type in (
      'STORE_MANAGER', 'DISTRICT_MANAGER',
      'HQ_ADMIN', 'SYSTEM'
    )
  )
);

create index if not exists idx_escalation_violation
  on catchmenu_hq.escalation_log(
    violation_id, escalation_level
  );
create index if not exists idx_escalation_pending
  on catchmenu_hq.escalation_log(
    brand_id, escalation_status, escalated_at desc
  ) where escalation_status = 'PENDING';

alter table catchmenu_hq.escalation_log
  enable row level security;
alter table catchmenu_hq.escalation_log
  force row level security;

drop policy if exists escalation_log_isolation
  on catchmenu_hq.escalation_log;
create policy escalation_log_isolation
  on catchmenu_hq.escalation_log
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
  );

drop trigger if exists trg_escalation_updated
  on catchmenu_hq.escalation_log;
create trigger trg_escalation_updated
  before update on catchmenu_hq.escalation_log
  for each row execute function
    catchmenu_common.set_updated_at();

comment on table catchmenu_hq.escalation_log is
  '위반 에스컬레이션 이력.
   escalation_level:
     1: 매장 관리자 알림
     2: 지역 관리자 알림
     3: HQ 자동 보고
   CRITICAL 위반 3회 이상: 자동 에스컬레이션.
   is_auto_escalated: 자동 에스컬레이션 여부.
   3차 Franchise_OS 사전 기반.
   4차에서 자동 알림 + 페널티 완전 구현.';


-- =============================================
-- RPCs
-- =============================================
create or replace function
  catchmenu_hq.run_compliance_check(
  p_tenant_id uuid,
  p_brand_id uuid,
  p_store_id uuid,
  p_policy_id uuid,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_hq,
                  catchmenu_pos,
                  catchmenu_store,
                  catchmenu_ledger,
                  catchmenu_common
as $$
declare
  v_check_id uuid;
  v_start timestamptz;
  v_policy record;
  v_check_results jsonb := '[]'::jsonb;
  v_violations_found jsonb := '[]'::jsonb;
  v_total int := 0;
  v_passed int := 0;
  v_failed int := 0;
  v_warnings int := 0;
  v_compliance_status text;
  v_check_score int;
  v_business_day date;

  procedure add_check_item(
    p_rule text,
    p_status text,
    p_actual jsonb,
    p_expected jsonb,
    p_severity text default 'WARNING'
  ) as
  $inner$
  begin
    v_total := v_total + 1;
    case p_status
      when 'PASS' then
        v_passed := v_passed + 1;
      when 'FAIL' then
        v_failed := v_failed + 1;
        v_violations_found :=
          v_violations_found
          || jsonb_build_array(
            jsonb_build_object(
              'rule', p_rule,
              'severity', p_severity,
              'actual', p_actual,
              'expected', p_expected
            )
          );
      when 'WARN' then
        v_warnings := v_warnings + 1;
      else null;
    end case;

    v_check_results := v_check_results
      || jsonb_build_array(
        jsonb_build_object(
          'rule', p_rule,
          'status', p_status,
          'actual', p_actual,
          'expected', p_expected,
          'severity', p_severity
        )
      );
  end;
  $inner$;

begin
  v_start := now();
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  -- 정책 조회
  select id, policy_code, policy_type,
         policy_data, is_mandatory,
         effective_from, effective_until
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
      p_rpc_name := 'run_compliance_check'
    );
  end if;

  -- 유효 기간 확인
  call add_check_item(
    'policy_effective_period',
    case
      when v_business_day
        >= v_policy.effective_from
        and (
          v_policy.effective_until is null
          or v_business_day
            <= v_policy.effective_until
        )
        then 'PASS'
      else 'FAIL'
    end,
    to_jsonb(v_business_day::text),
    jsonb_build_object(
      'from', v_policy.effective_from,
      'until', v_policy.effective_until
    ),
    'ERROR'
  );

  -- 정책 타입별 검사
  case v_policy.policy_type
    when 'MENU' then
      -- 필수 메뉴 항목 존재 여부
      declare
        v_required_menus jsonb;
        v_menu_code text;
        v_exists boolean;
      begin
        v_required_menus := coalesce(
          v_policy.policy_data->'required_menus',
          '[]'::jsonb
        );

        for v_menu_code in
          select jsonb_array_elements_text(
            v_required_menus
          )
        loop
          select exists (
            select 1
            from catchmenu_pos.menus
            where store_id = p_store_id
              and tenant_id = p_tenant_id
              and (
                menu_code = v_menu_code
                or menu_code like 'HQ_%'
                  || v_menu_code
              )
              and is_active = true
              and menu_status = 'AVAILABLE'
          ) into v_exists;

          call add_check_item(
            'required_menu_present:'
              || v_menu_code,
            case v_exists
              when true then 'PASS'
              else 'FAIL'
            end,
            to_jsonb(v_exists),
            to_jsonb(true),
            'CRITICAL'
          );
        end loop;
      end;

    when 'PRICING' then
      -- 가격 정책 준수
      declare
        v_max_discount_pct numeric;
        v_violation_count int;
      begin
        v_max_discount_pct := coalesce(
          (v_policy.policy_data
            ->>'max_discount_pct')::numeric,
          100
        );

        -- 실제 할인율 확인
        select count(*) into v_violation_count
        from catchmenu_store.promotions
        where store_id = p_store_id
          and tenant_id = p_tenant_id
          and promotion_status = 'ACTIVE'
          and benefit_type = 'PCT_DISCOUNT'
          and discount_pct > v_max_discount_pct;

        call add_check_item(
          'max_discount_pct_compliance',
          case v_violation_count
            when 0 then 'PASS'
            else 'FAIL'
          end,
          to_jsonb(v_violation_count),
          to_jsonb(0),
          'ERROR'
        );
      end;

    when 'OPERATION' then
      -- 운영 정책 준수 (KDS threshold 등)
      declare
        v_required_kds_threshold int;
        v_actual_threshold int;
      begin
        v_required_kds_threshold := coalesce(
          (v_policy.policy_data
            ->>'min_kds_threshold')::int,
          0
        );

        select coalesce(
          kds_capacity_threshold_total, 0
        )
        into v_actual_threshold
        from catchmenu_store.store_settings
        where store_id = p_store_id
          and tenant_id = p_tenant_id;

        call add_check_item(
          'kds_threshold_compliance',
          case
            when v_actual_threshold
              >= v_required_kds_threshold
              then 'PASS'
            else 'WARN'
          end,
          to_jsonb(v_actual_threshold),
          to_jsonb(v_required_kds_threshold),
          'WARNING'
        );
      end;

    when 'QUALITY' then
      -- 품질 기준 (KDS 응답시간 등)
      declare
        v_max_avg_cook_minutes int;
        v_actual_avg_minutes numeric;
      begin
        v_max_avg_cook_minutes := coalesce(
          (v_policy.policy_data
            ->>'max_avg_cook_minutes')::int,
          999
        );

        select coalesce(
          avg(
            extract(epoch from (
              served_at - committed_at
            )) / 60
          ), 0
        )
        into v_actual_avg_minutes
        from catchmenu_kds.kds_tickets
        where store_id = p_store_id
          and tenant_id = p_tenant_id
          and business_day = v_business_day
          and kds_status in (
            'SERVED', 'COMPLETED'
          )
          and served_at is not null
          and committed_at is not null;

        call add_check_item(
          'avg_cook_time_compliance',
          case
            when v_actual_avg_minutes::int
              <= v_max_avg_cook_minutes
              then 'PASS'
            else 'WARN'
          end,
          to_jsonb(v_actual_avg_minutes::int),
          to_jsonb(v_max_avg_cook_minutes),
          'WARNING'
        );
      end;

    else
      -- 기본: 배정 여부만 확인
      call add_check_item(
        'policy_assigned',
        case when exists (
          select 1
          from catchmenu_hq
            .franchise_policy_assignments
          where policy_id = p_policy_id
            and store_id = p_store_id
            and assignment_status = 'APPLIED'
        ) then 'PASS' else 'FAIL' end,
        to_jsonb(true),
        to_jsonb(true),
        'ERROR'
      );
  end case;

  -- 점수 계산
  v_check_score := case v_total
    when 0 then 100
    else (v_passed::numeric / v_total * 100)::int
  end;

  -- 준수 상태 결정
  v_compliance_status := case
    when v_failed = 0 and v_warnings = 0
      then 'COMPLIANT'
    when v_failed = 0
      then 'PARTIAL'
    when v_check_score >= 70
      then 'PARTIAL'
    else 'NON_COMPLIANT'
  end;

  -- 검사 결과 저장
  insert into
    catchmenu_hq.policy_compliance_checks (
    tenant_id, brand_id, store_id, policy_id,
    check_status, compliance_status,
    check_score,
    total_items, passed_items,
    failed_items, warning_items,
    check_results, violations_found,
    checked_at, check_duration_ms,
    next_check_at
  ) values (
    p_tenant_id, p_brand_id,
    p_store_id, p_policy_id,
    'COMPLETED', v_compliance_status,
    v_check_score,
    v_total, v_passed, v_failed, v_warnings,
    v_check_results, v_violations_found,
    now(),
    extract(
      epoch from (now() - v_start)
    )::int * 1000,
    now() + interval '24 hours'
  )
  returning id into v_check_id;

  -- 정책 배정 상태 업데이트
  update catchmenu_hq.franchise_policy_assignments
  set
    compliance_status = v_compliance_status,
    last_verified_at = now(),
    updated_at = now()
  where policy_id = p_policy_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id;

  -- 위반 항목 기록
  if v_failed > 0 then
    declare
      v_viol jsonb;
    begin
      for v_viol in
        select * from jsonb_array_elements(
          v_violations_found
        )
      loop
        insert into
          catchmenu_hq.policy_violations (
          tenant_id, brand_id, store_id,
          policy_id, check_id,
          violation_code, violation_type,
          violation_severity,
          violation_description,
          violated_rule,
          actual_value, expected_value,
          violation_status,
          detected_at, business_day
        ) values (
          p_tenant_id, p_brand_id, p_store_id,
          p_policy_id, v_check_id,
          v_policy.policy_code || '_'
            || (v_viol->>'rule'),
          case v_policy.policy_type
            when 'MENU'
              then 'MENU_NON_COMPLIANCE'
            when 'PRICING'
              then 'PRICE_VIOLATION'
            when 'OPERATION'
              then 'OPERATION_VIOLATION'
            when 'QUALITY'
              then 'QUALITY_VIOLATION'
            else 'COMPLIANCE_BREACH'
          end,
          coalesce(
            v_viol->>'severity', 'WARNING'
          ),
          v_viol->>'rule',
          v_viol->>'rule',
          v_viol->'actual',
          v_viol->'expected',
          'OPEN',
          now(), v_business_day
        )
        on conflict do nothing;
      end loop;
    end;
  end if;

  -- 진단 로그
  perform catchmenu_common.log_diagnostic(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_log_level := case v_compliance_status
      when 'COMPLIANT' then 'INFO'
      when 'PARTIAL' then 'WARNING'
      else 'ERROR'
    end,
    p_log_domain := 'SYSTEM',
    p_log_event := 'compliance_check_completed',
    p_message :=
      v_policy.policy_code
      || ' | score=' || v_check_score
      || ' | status=' || v_compliance_status,
    p_rpc_name := 'run_compliance_check',
    p_correlation_id := p_correlation_id,
    p_details := jsonb_build_object(
      'check_id', v_check_id,
      'policy_id', p_policy_id,
      'score', v_check_score,
      'passed', v_passed,
      'failed', v_failed
    )
  );

  return catchmenu_common.build_success_response(
    p_message_key := case v_failed
      when 0 then 'compliance_check_passed'
      else 'compliance_check_failed'
    end,
    p_data := jsonb_build_object(
      'check_id', v_check_id,
      'policy_id', p_policy_id,
      'policy_code', v_policy.policy_code,
      'store_id', p_store_id,
      'compliance_status', v_compliance_status,
      'check_score', v_check_score,
      'results', jsonb_build_object(
        'total', v_total,
        'passed', v_passed,
        'failed', v_failed,
        'warnings', v_warnings
      ),
      'violations_found',
        jsonb_array_length(v_violations_found)
    ),
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );
end;
$$;


create or replace function
  catchmenu_hq.detect_policy_violations(
  p_tenant_id uuid,
  p_brand_id uuid,
  p_store_id uuid default null,
  p_policy_type text default null,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_hq,
                  catchmenu_common
as $$
declare
  v_policy record;
  v_store record;
  v_check_result jsonb;
  v_total_checks int := 0;
  v_violations_found int := 0;
  v_stores_checked int := 0;
  v_results jsonb := '[]'::jsonb;
begin
  -- 브랜드 내 활성 정책 순회
  for v_policy in
    select id, policy_code, policy_type,
           applies_to, target_store_ids
    from catchmenu_hq.franchise_policies
    where brand_id = p_brand_id
      and tenant_id = p_tenant_id
      and policy_status = 'PUBLISHED'
      and is_active = true
      and (
        p_policy_type is null
        or policy_type = p_policy_type
      )
    order by policy_type
  loop
    -- 대상 매장 결정
    for v_store in
      select s.id, s.store_name
      from catchmenu_hq.store_group_members sgm
      join catchmenu_hq.stores s
        on s.id = sgm.store_id
      where sgm.group_id = p_brand_id
        and sgm.tenant_id = p_tenant_id
        and sgm.is_active = true
        and s.is_active = true
        and (
          p_store_id is null
          or s.id = p_store_id
        )
      loop
        v_stores_checked := v_stores_checked + 1;
        v_total_checks := v_total_checks + 1;

        v_check_result :=
          catchmenu_hq.run_compliance_check(
            p_tenant_id := p_tenant_id,
            p_brand_id := p_brand_id,
            p_store_id := v_store.id,
            p_policy_id := v_policy.id,
            p_locale := p_locale
          );

        if not (
          v_check_result->>'success'
        )::boolean
        then
          continue;
        end if;

        if (
          v_check_result->'data'
            ->>'violations_found'
        )::int > 0 then
          v_violations_found :=
            v_violations_found + (
              v_check_result->'data'
                ->>'violations_found'
            )::int;
        end if;

        v_results := v_results
          || jsonb_build_array(
            jsonb_build_object(
              'store_id', v_store.id,
              'store_name', v_store.store_name,
              'policy_code',
                v_policy.policy_code,
              'policy_type',
                v_policy.policy_type,
              'compliance_status',
                v_check_result->'data'
                  ->>'compliance_status',
              'check_score',
                v_check_result->'data'
                  ->>'check_score',
              'violations',
                v_check_result->'data'
                  ->>'violations_found'
            )
          );
      end loop;
  end loop;

  return catchmenu_common.build_success_response(
    p_message_key := case v_violations_found
      when 0 then 'compliance_check_passed'
      else 'violation_detected'
    end,
    p_data := jsonb_build_object(
      'brand_id', p_brand_id,
      'store_filter', p_store_id,
      'policy_type_filter', p_policy_type,
      'total_checks', v_total_checks,
      'stores_checked', v_stores_checked,
      'total_violations', v_violations_found,
      'has_violations', v_violations_found > 0,
      'results', v_results
    ),
    p_locale := p_locale
  );
end;
$$;


create or replace function
  catchmenu_hq.escalate_violation(
  p_tenant_id uuid,
  p_violation_id uuid,
  p_escalation_reason text,
  p_escalated_to_type text
    default 'STORE_MANAGER',
  p_escalated_to_id uuid default null,
  p_is_auto boolean default false,
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
  v_violation record;
  v_escalation_id uuid;
  v_next_level int;
  v_business_day date;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  select id, brand_id, store_id,
         policy_id, violation_type,
         violation_severity, violation_status,
         escalation_level, occurrence_count
  into v_violation
  from catchmenu_hq.policy_violations
  where id = p_violation_id
    and tenant_id = p_tenant_id
  for update;

  if v_violation.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'violation_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_rpc_name := 'escalate_violation'
    );
  end if;

  v_next_level := v_violation.escalation_level + 1;

  -- 에스컬레이션 기록
  insert into catchmenu_hq.escalation_log (
    tenant_id, violation_id,
    store_id, brand_id,
    escalation_level, escalation_reason,
    escalated_to_type, escalated_to_id,
    escalation_status, is_auto_escalated,
    triggered_by_occurrence_count,
    escalated_at
  ) values (
    p_tenant_id, p_violation_id,
    v_violation.store_id, v_violation.brand_id,
    v_next_level, p_escalation_reason,
    p_escalated_to_type, p_escalated_to_id,
    'PENDING', p_is_auto,
    v_violation.occurrence_count,
    now()
  )
  returning id into v_escalation_id;

  -- 위반 상태 업데이트
  update catchmenu_hq.policy_violations
  set
    is_escalated = true,
    escalated_at = now(),
    escalation_level = v_next_level,
    violation_status = 'ACKNOWLEDGED',
    updated_at = now()
  where id = p_violation_id;

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
    p_tenant_id, v_violation.store_id,
    'franchise', 'violation_escalated', 1,
    'policy_violation', p_violation_id,
    'OPEN', 'ACKNOWLEDGED',
    case p_is_auto
      when true then 'SYSTEM'
      else 'STAFF'
    end,
    jsonb_build_object(
      'escalation_id', v_escalation_id,
      'escalation_level', v_next_level,
      'escalated_to_type', p_escalated_to_type,
      'violation_type', v_violation.violation_type,
      'violation_severity',
        v_violation.violation_severity,
      'is_auto', p_is_auto
    ),
    p_correlation_id,
    v_business_day, 'Asia/Seoul', now()
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'violation_escalated',
    p_data := jsonb_build_object(
      'escalation_id', v_escalation_id,
      'violation_id', p_violation_id,
      'escalation_level', v_next_level,
      'escalated_to_type', p_escalated_to_type,
      'is_auto', p_is_auto
    ),
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );
end;
$$;


create or replace function
  catchmenu_hq.get_policy_compliance_summary(
  p_tenant_id uuid,
  p_brand_id uuid,
  p_period_start date default null,
  p_period_end date default null,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_hq,
                  catchmenu_common
as $$
declare
  v_period_start date;
  v_period_end date;
  v_brand record;
  v_overall jsonb;
  v_by_policy_type jsonb;
  v_by_store jsonb;
  v_top_violations jsonb;
  v_pending_escalations jsonb;
begin
  v_period_start := coalesce(
    p_period_start,
    (date_trunc('month', now()))::date
  );
  v_period_end := coalesce(
    p_period_end, current_date
  );

  select id, brand_code, brand_name
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
      p_rpc_name := 'get_policy_compliance_summary'
    );
  end if;

  -- 전체 준수율 요약
  select jsonb_build_object(
    'total_checks', count(*),
    'compliant', count(*) filter (
      where compliance_status = 'COMPLIANT'
    ),
    'non_compliant', count(*) filter (
      where compliance_status = 'NON_COMPLIANT'
    ),
    'partial', count(*) filter (
      where compliance_status = 'PARTIAL'
    ),
    'avg_score', coalesce(
      avg(check_score)::int, 0
    ),
    'compliance_rate_pct', case count(*)
      when 0 then 100
      else (
        count(*) filter (
          where compliance_status = 'COMPLIANT'
        )::numeric / count(*) * 100
      )::int
    end
  )
  into v_overall
  from catchmenu_hq.policy_compliance_checks
  where brand_id = p_brand_id
    and tenant_id = p_tenant_id
    and checked_at::date between
      v_period_start and v_period_end;

  -- 정책 유형별 준수율
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'policy_type', fp.policy_type,
        'total_checks', count(pcc.*),
        'compliant', count(pcc.*) filter (
          where pcc.compliance_status
            = 'COMPLIANT'
        ),
        'avg_score',
          coalesce(avg(pcc.check_score)::int, 0),
        'compliance_rate_pct', case count(pcc.*)
          when 0 then 100
          else (
            count(pcc.*) filter (
              where pcc.compliance_status
                = 'COMPLIANT'
            )::numeric / count(pcc.*) * 100
          )::int
        end
      )
      order by fp.policy_type
    ),
    '[]'::jsonb
  )
  into v_by_policy_type
  from catchmenu_hq.franchise_policies fp
  left join catchmenu_hq.policy_compliance_checks
    pcc on pcc.policy_id = fp.id
    and pcc.checked_at::date between
      v_period_start and v_period_end
  where fp.brand_id = p_brand_id
    and fp.tenant_id = p_tenant_id
    and fp.policy_status = 'PUBLISHED'
  group by fp.policy_type;

  -- 매장별 준수 현황
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'store_id', s.id,
        'store_name', s.store_name,
        'total_checks', coalesce(
          checks.total_checks, 0
        ),
        'avg_score', coalesce(
          checks.avg_score, 0
        ),
        'compliance_rate_pct', coalesce(
          checks.compliance_rate_pct, 0
        ),
        'open_violations',
          coalesce(viols.open_count, 0),
        'critical_violations',
          coalesce(viols.critical_count, 0)
      )
      order by
        coalesce(checks.avg_score, 0) asc
    ),
    '[]'::jsonb
  )
  into v_by_store
  from catchmenu_hq.store_group_members sgm
  join catchmenu_hq.stores s
    on s.id = sgm.store_id
  left join lateral (
    select
      count(*) as total_checks,
      avg(check_score)::int as avg_score,
      (count(*) filter (
        where compliance_status = 'COMPLIANT'
      )::numeric / nullif(count(*), 0)
        * 100)::int as compliance_rate_pct
    from catchmenu_hq.policy_compliance_checks
    where store_id = s.id
      and brand_id = p_brand_id
      and checked_at::date between
        v_period_start and v_period_end
  ) checks on true
  left join lateral (
    select
      count(*) filter (
        where violation_status in (
          'OPEN', 'ACKNOWLEDGED'
        )
      ) as open_count,
      count(*) filter (
        where violation_severity in (
          'CRITICAL', 'FATAL'
        )
        and violation_status in (
          'OPEN', 'ACKNOWLEDGED'
        )
      ) as critical_count
    from catchmenu_hq.policy_violations
    where store_id = s.id
      and brand_id = p_brand_id
  ) viols on true
  where sgm.group_id = p_brand_id
    and sgm.tenant_id = p_tenant_id
    and sgm.is_active = true
    and s.is_active = true;

  -- 주요 위반 유형
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'violation_type', violation_type,
        'count', count(*),
        'severity', max(violation_severity),
        'affected_stores',
          count(distinct store_id)
      )
      order by count(*) desc
    ),
    '[]'::jsonb
  )
  into v_top_violations
  from catchmenu_hq.policy_violations
  where brand_id = p_brand_id
    and tenant_id = p_tenant_id
    and violation_status in (
      'OPEN', 'ACKNOWLEDGED', 'IN_REMEDIATION'
    )
    and detected_at::date between
      v_period_start and v_period_end
  group by violation_type
  limit 5;

  -- 미처리 에스컬레이션
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'escalation_id', el.id,
        'violation_id', el.violation_id,
        'store_id', el.store_id,
        'escalation_level', el.escalation_level,
        'escalated_to_type',
          el.escalated_to_type,
        'is_auto', el.is_auto_escalated,
        'escalated_at', el.escalated_at
      )
      order by el.escalated_at asc
    ),
    '[]'::jsonb
  )
  into v_pending_escalations
  from catchmenu_hq.escalation_log el
  where el.brand_id = p_brand_id
    and el.tenant_id = p_tenant_id
    and el.escalation_status = 'PENDING'
  limit 10;

  return catchmenu_common.build_success_response(
    p_message_key := 'compliance_summary_loaded',
    p_data := jsonb_build_object(
      'brand', jsonb_build_object(
        'id', v_brand.id,
        'brand_code', v_brand.brand_code,
        'brand_name', v_brand.brand_name
      ),
      'period_start', v_period_start,
      'period_end', v_period_end,
      'overall', v_overall,
      'by_policy_type', v_by_policy_type,
      'by_store', v_by_store,
      'top_violations', v_top_violations,
      'pending_escalations',
        v_pending_escalations,
      'pending_escalation_count',
        jsonb_array_length(v_pending_escalations)
    ),
    p_locale := p_locale
  );
end;
$$;


create or replace function
  catchmenu_hq.rollback_policy(
  p_tenant_id uuid,
  p_policy_id uuid,
  p_rollback_reason text,
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
  v_current_policy record;
  v_previous_policy record;
  v_audit_id uuid;
  v_business_day date;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  -- 현재 정책
  select id, policy_code, policy_type,
         brand_id, version_number, supersedes
  into v_current_policy
  from catchmenu_hq.franchise_policies
  where id = p_policy_id
    and tenant_id = p_tenant_id
    and is_active = true;

  if v_current_policy.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'policy_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_rpc_name := 'rollback_policy'
    );
  end if;

  -- 이전 버전 확인
  if v_current_policy.supersedes is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'policy_rollback_not_available',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_rpc_name := 'rollback_policy'
    );
  end if;

  select id, policy_code, version_number
  into v_previous_policy
  from catchmenu_hq.franchise_policies
  where id = v_current_policy.supersedes
    and tenant_id = p_tenant_id;

  -- 현재 버전 아카이브
  update catchmenu_hq.franchise_policies
  set
    policy_status = 'ARCHIVED',
    updated_at = now()
  where id = p_policy_id;

  -- 이전 버전 복구
  update catchmenu_hq.franchise_policies
  set
    policy_status = 'PUBLISHED',
    superseded_by = null,
    published_at = now(),
    updated_at = now()
  where id = v_current_policy.supersedes;

  -- audit
  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_audit_domain := 'franchise',
    p_audit_type := 'policy_rolled_back',
    p_audit_category := 'OPERATIONAL',
    p_actor_type := 'STAFF',
    p_actor_id := p_actor_id,
    p_subject_type := 'franchise_policy',
    p_subject_id := p_policy_id,
    p_decision := 'ROLLED_BACK',
    p_decision_reason := p_rollback_reason,
    p_decision_payload := jsonb_build_object(
      'current_version',
        v_current_policy.version_number,
      'restored_version',
        v_previous_policy.version_number,
      'policy_code', v_current_policy.policy_code
    ),
    p_correlation_id := p_correlation_id,
    p_business_day := v_business_day,
    p_business_timezone := 'Asia/Seoul'
  );

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
    'franchise', 'policy_rolled_back', 1,
    'franchise_policy', p_policy_id,
    'PUBLISHED', 'ARCHIVED',
    'STAFF', p_actor_id,
    jsonb_build_object(
      'policy_code', v_current_policy.policy_code,
      'rolled_back_from',
        v_current_policy.version_number,
      'restored_to',
        v_previous_policy.version_number,
      'rollback_reason', p_rollback_reason
    ),
    p_correlation_id,
    v_business_day, 'Asia/Seoul', now()
  );

  -- 브랜드 전체 매장에 이전 버전 재배포
  perform catchmenu_hq.apply_policy_to_stores(
    p_tenant_id := p_tenant_id,
    p_policy_id := v_current_policy.supersedes,
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'policy_rolled_back',
    p_data := jsonb_build_object(
      'policy_id', p_policy_id,
      'policy_code', v_current_policy.policy_code,
      'rolled_back_from',
        v_current_policy.version_number,
      'restored_to',
        v_previous_policy.version_number,
      'restored_policy_id',
        v_current_policy.supersedes,
      'rollback_reason', p_rollback_reason,
      'audit_id', v_audit_id
    ),
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );
end;
$$;


create or replace function
  catchmenu_hq.bulk_policy_distribution(
  p_tenant_id uuid,
  p_brand_id uuid,
  p_policy_type text default null,
  p_force_reapply boolean default false,
  p_locale text default 'ko',
  p_actor_id uuid default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_hq,
                  catchmenu_common,
                  catchmenu_ledger
as $$
declare
  v_policy record;
  v_apply_result jsonb;
  v_policy_count int := 0;
  v_applied_count int := 0;
  v_failed_count int := 0;
  v_skipped_count int := 0;
  v_results jsonb := '[]'::jsonb;
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
      p_rpc_name := 'bulk_policy_distribution'
    );
  end if;

  -- 배포할 정책 목록
  for v_policy in
    select id, policy_code, policy_type,
           version_number, is_mandatory
    from catchmenu_hq.franchise_policies
    where brand_id = p_brand_id
      and tenant_id = p_tenant_id
      and policy_status = 'PUBLISHED'
      and is_active = true
      and effective_from <= current_date
      and (
        effective_until is null
        or effective_until >= current_date
      )
      and (
        p_policy_type is null
        or policy_type = p_policy_type
      )
    order by policy_type, version_number
  loop
    v_policy_count := v_policy_count + 1;

    begin
      -- 이미 적용된 최신 버전이면 스킵
      if not p_force_reapply then
        if exists (
          select 1
          from catchmenu_hq
            .franchise_policy_assignments
          where policy_id = v_policy.id
            and tenant_id = p_tenant_id
            and assignment_status = 'APPLIED'
        ) then
          v_skipped_count :=
            v_skipped_count + 1;
          v_results := v_results
            || jsonb_build_array(
              jsonb_build_object(
                'policy_code',
                  v_policy.policy_code,
                'status', 'SKIPPED',
                'reason',
                  'already_applied'
              )
            );
          continue;
        end if;
      end if;

      -- 매장에 정책 적용
      v_apply_result :=
        catchmenu_hq.apply_policy_to_stores(
          p_tenant_id := p_tenant_id,
          p_policy_id := v_policy.id,
          p_locale := p_locale,
          p_correlation_id := p_correlation_id
        );

      if (v_apply_result->>'success')::boolean
      then
        v_applied_count :=
          v_applied_count + 1;
        v_results := v_results
          || jsonb_build_array(
            jsonb_build_object(
              'policy_code',
                v_policy.policy_code,
              'policy_type',
                v_policy.policy_type,
              'status', 'APPLIED',
              'applied_stores',
                v_apply_result
                  ->'data'->>'applied_count'
            )
          );
      else
        v_failed_count := v_failed_count + 1;
        v_results := v_results
          || jsonb_build_array(
            jsonb_build_object(
              'policy_code',
                v_policy.policy_code,
              'status', 'FAILED',
              'error',
                v_apply_result->>'error_key'
            )
          );
      end if;

    exception when others then
      v_failed_count := v_failed_count + 1;
      v_results := v_results
        || jsonb_build_array(
          jsonb_build_object(
            'policy_code', v_policy.policy_code,
            'status', 'FAILED',
            'error', sqlerrm
          )
        );
    end;
  end loop;

  if v_policy_count = 0 then
    return catchmenu_common.build_error_response(
      p_error_key := 'no_policies_to_distribute',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_rpc_name := 'bulk_policy_distribution'
    );
  end if;

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
    'franchise', 'bulk_policy_distributed', 1,
    'franchise_brand', p_brand_id,
    null, 'DISTRIBUTED',
    'STAFF', p_actor_id,
    jsonb_build_object(
      'brand_id', p_brand_id,
      'policy_type_filter', p_policy_type,
      'total_policies', v_policy_count,
      'applied', v_applied_count,
      'failed', v_failed_count,
      'skipped', v_skipped_count,
      'force_reapply', p_force_reapply
    ),
    p_correlation_id,
    v_business_day, 'Asia/Seoul', now()
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'bulk_distribution_completed',
    p_data := jsonb_build_object(
      'brand_id', p_brand_id,
      'policy_type_filter', p_policy_type,
      'total_policies', v_policy_count,
      'applied', v_applied_count,
      'failed', v_failed_count,
      'skipped', v_skipped_count,
      'results', v_results
    ),
    p_locale := p_locale,
    p_params := jsonb_build_object(
      'policy_count', v_applied_count
    ),
    p_correlation_id := p_correlation_id
  );
end;
$$;


-- pg_cron: 일일 컴플라이언스 검사
insert into catchmenu_common.pg_cron_jobs (
  job_code, pg_cron_job_name,
  schedule_cron_utc, schedule_cron_kst,
  sql_command, notes
) values
(
  'DAILY_COMPLIANCE_CHECK',
  'catchmenu_compliance_check',
  '0 17 * * *',
  '0 2 * * * (매일 새벽 2시 KST)',
  $sql$
SELECT catchmenu_hq.detect_policy_violations(
  p_tenant_id :=
    '00000000-0000-0000-0000-000000000001'::uuid,
  p_brand_id :=
    '00000000-0000-0000-0000-000000000010'::uuid
);
$sql$,
  '브랜드 전체 정책 준수 검사. 매일 새벽 2시 KST.'
),
(
  'AUTO_ESCALATION_CHECK',
  'catchmenu_auto_escalation',
  '0 */6 * * *',
  '0 */6 * * * (6시간마다)',
  $sql$
-- CRITICAL 위반 3회 이상 자동 에스컬레이션
UPDATE catchmenu_hq.policy_violations
SET
  is_escalated = true,
  escalated_at = now(),
  escalation_level = 1,
  violation_status = 'ACKNOWLEDGED',
  updated_at = now()
WHERE violation_status = 'OPEN'
  AND violation_severity IN ('CRITICAL', 'FATAL')
  AND occurrence_count >= 3
  AND is_escalated = false;
$sql$,
  'CRITICAL 위반 자동 에스컬레이션. 6시간마다.'
)
on conflict (job_code) do nothing;


-- grants
do $$
begin
  revoke all on function
    catchmenu_hq.run_compliance_check(
      uuid, uuid, uuid, uuid, text, text
    ) from public;
  grant execute on function
    catchmenu_hq.run_compliance_check(
      uuid, uuid, uuid, uuid, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_hq.detect_policy_violations(
      uuid, uuid, uuid, text, text
    ) from public;
  grant execute on function
    catchmenu_hq.detect_policy_violations(
      uuid, uuid, uuid, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_hq.escalate_violation(
      uuid, uuid, text, text, uuid,
      boolean, text, text
    ) from public;
  grant execute on function
    catchmenu_hq.escalate_violation(
      uuid, uuid, text, text, uuid,
      boolean, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_hq.get_policy_compliance_summary(
      uuid, uuid, date, date, text
    ) from public;
  grant execute on function
    catchmenu_hq.get_policy_compliance_summary(
      uuid, uuid, date, date, text
    ) to authenticated;

  revoke all on function
    catchmenu_hq.rollback_policy(
      uuid, uuid, text, text, uuid, text
    ) from public;
  grant execute on function
    catchmenu_hq.rollback_policy(
      uuid, uuid, text, text, uuid, text
    ) to authenticated;

  revoke all on function
    catchmenu_hq.bulk_policy_distribution(
      uuid, uuid, text, boolean, text, uuid, text
    ) from public;
  grant execute on function
    catchmenu_hq.bulk_policy_distribution(
      uuid, uuid, text, boolean, text, uuid, text
    ) to authenticated;
end;
$$;

comment on function
  catchmenu_hq.run_compliance_check(
    uuid, uuid, uuid, uuid, text, text
  ) is
  '단일 매장 × 단일 정책 준수 검사.
   정책 유형별 검사 로직:
   MENU: 필수 메뉴 존재 여부
   PRICING: 최대 할인율 준수 여부
   OPERATION: KDS threshold 설정 여부
   QUALITY: 평균 조리시간 준수 여부
   check_score: 0~100 (통과율).
   위반 감지 시 policy_violations 자동 기록.
   i18n: 모든 메시지 = message_catalog 참조.
   3차 Franchise_OS 컴플라이언스 기반.
   1-C차 완전 SaaS 공통 모듈.';

comment on function
  catchmenu_hq.bulk_policy_distribution(
    uuid, uuid, text, boolean, text, uuid, text
  ) is
  '브랜드 전체 정책 일괄 배포.
   p_policy_type: 특정 유형만 배포.
   p_force_reapply = false:
     이미 적용된 정책 스킵 (효율적).
   p_force_reapply = true:
     전체 재적용 (버전 업데이트 후 사용).
   내부적으로 apply_policy_to_stores() 호출.
   모든 메시지 = message_catalog i18n.
   3차 Franchise_OS + 1-C차 공통 모듈.
   4차에서 실시간 알림 + 자동화 확장.';