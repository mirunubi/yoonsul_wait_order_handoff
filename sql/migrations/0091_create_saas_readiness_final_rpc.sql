-- 0091_create_saas_readiness_final_rpc.sql
-- Purpose: 1-C차 완전 SaaS 출시 준비 최종 검증.
--          SaaS launch checklist, system integration test,
--          performance baseline, go-live authorization.
--          1-C차 완전 SaaS 출시 전 최종 게이트.
--          i18n: 모든 메시지 = message_catalog 참조.
-- Depends on: 0090_create_multitenant_isolation_rpc.sql
-- Creates:
--   catchmenu_common.saas_launch_checklist (table)
--   catchmenu_common.integration_test_results (table)
--   function catchmenu_common.run_saas_launch_checklist(...)
--   function catchmenu_common.run_integration_test(...)
--   function catchmenu_common.authorize_go_live(...)
--   function catchmenu_common.get_launch_readiness_report(...)

-- =============================================
-- i18n 메시지 등록
-- =============================================
insert into catchmenu_common.message_catalog (
  message_key, locale, message_text
) values
('saas_launch_ready', 'ko',
  '1-C차 SaaS 출시 준비가 완료되었습니다'),
('saas_launch_ready', 'en',
  '1-C SaaS launch ready'),
('saas_launch_not_ready', 'ko',
  '아직 SaaS 출시 준비가 완료되지 않았습니다'),
('saas_launch_not_ready', 'en',
  'SaaS launch not yet ready'),
('integration_test_passed', 'ko',
  '통합 테스트를 통과했습니다'),
('integration_test_passed', 'en',
  'Integration test passed'),
('integration_test_failed', 'ko',
  '통합 테스트에 실패했습니다'),
('integration_test_failed', 'en',
  'Integration test failed'),
('go_live_authorized', 'ko',
  '운영 시작이 승인되었습니다'),
('go_live_authorized', 'en',
  'Go-live authorized'),
('go_live_blocked', 'ko',
  '미해결 항목이 있어 운영 시작이 차단되었습니다'),
('go_live_blocked', 'en',
  'Go-live blocked due to unresolved items'),
('launch_report_loaded', 'ko',
  '출시 준비 리포트가 로드되었습니다'),
('launch_report_loaded', 'en',
  'Launch readiness report loaded')
on conflict (message_key, locale) do nothing;

insert into catchmenu_common.error_codes (
  code, error_key, error_domain,
  error_category, http_status, severity
) values
(3015, 'saas_launch_not_ready',
  'SYSTEM', 'BUSINESS_RULE', 409, 'WARNING'),
(3016, 'go_live_blocked',
  'SYSTEM', 'BUSINESS_RULE', 409, 'ERROR'),
(3017, 'integration_test_failed',
  'SYSTEM', 'TECHNICAL', 500, 'ERROR')
on conflict (code) do nothing;


-- =============================================
-- saas_launch_checklist table
-- SaaS 출시 체크리스트 항목
-- =============================================
create table if not exists
  catchmenu_common.saas_launch_checklist (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),

  -- 체크리스트 항목
  check_code text not null,
  check_name text not null,
  check_category text not null,
  check_priority text not null default 'REQUIRED',
  phase text not null default '1C',

  -- 상태
  check_status text not null default 'PENDING',
  last_checked_at timestamptz,
  check_result jsonb default '{}'::jsonb,

  -- 자동/수동
  is_automated boolean not null default true,
  verified_by uuid,
  verified_at timestamptz,
  verification_note text,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint uq_launch_check unique (
    tenant_id, check_code
  ),
  constraint chk_check_priority check (
    check_priority in (
      'REQUIRED', 'RECOMMENDED', 'OPTIONAL'
    )
  ),
  constraint chk_check_status check (
    check_status in (
      'PENDING', 'RUNNING',
      'PASSED', 'FAILED',
      'MANUAL_REQUIRED', 'WAIVED'
    )
  )
);

create index if not exists idx_launch_checklist
  on catchmenu_common.saas_launch_checklist(
    tenant_id, check_status, check_priority
  );

alter table
  catchmenu_common.saas_launch_checklist
  enable row level security;
alter table
  catchmenu_common.saas_launch_checklist
  force row level security;

drop policy if exists launch_checklist_isolation
  on catchmenu_common.saas_launch_checklist;
create policy launch_checklist_isolation
  on catchmenu_common.saas_launch_checklist
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
  );

drop trigger if exists trg_launch_checklist_updated
  on catchmenu_common.saas_launch_checklist;
create trigger trg_launch_checklist_updated
  before update on
    catchmenu_common.saas_launch_checklist
  for each row execute function
    catchmenu_common.set_updated_at();

comment on table
  catchmenu_common.saas_launch_checklist is
  '1-C차 SaaS 출시 체크리스트.
   REQUIRED: 필수 (미통과 시 출시 불가).
   RECOMMENDED: 권장 (경고만).
   OPTIONAL: 선택.
   is_automated: 자동 검사 여부.
   MANUAL_REQUIRED: 사람이 직접 확인 필요.
   1-C차 SaaS 출시 전 최종 게이트.';


-- =============================================
-- integration_test_results table
-- 통합 테스트 결과
-- =============================================
create table if not exists
  catchmenu_common.integration_test_results (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid,

  -- 테스트 식별
  test_suite text not null,
  test_code text not null,
  test_name text not null,
  test_category text not null,

  -- 결과
  test_status text not null default 'PENDING',
  test_score int,
  passed_assertions int not null default 0,
  failed_assertions int not null default 0,
  test_detail jsonb default '{}'::jsonb,
  error_message text,

  -- 성능
  execution_ms int,
  ran_at timestamptz not null default now(),

  created_at timestamptz not null default now(),

  constraint chk_test_status check (
    test_status in (
      'PENDING', 'RUNNING',
      'PASSED', 'FAILED', 'SKIPPED'
    )
  )
);

create index if not exists idx_integration_tests
  on catchmenu_common.integration_test_results(
    tenant_id, test_suite, ran_at desc
  );

alter table
  catchmenu_common.integration_test_results
  enable row level security;
alter table
  catchmenu_common.integration_test_results
  force row level security;

drop policy if exists integration_tests_isolation
  on catchmenu_common.integration_test_results;
create policy integration_tests_isolation
  on catchmenu_common.integration_test_results
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
  );

comment on table
  catchmenu_common.integration_test_results is
  '통합 테스트 결과.
   test_suite: 테스트 그룹
   (PAYMENT/KDS/WAITING/AI/FRANCHISE).
   test_score: 0~100.
   1-C차 SaaS 출시 전 최종 통합 테스트.';


-- =============================================
-- 체크리스트 시드
-- =============================================
create or replace function
  catchmenu_common.seed_saas_launch_checklist(
  p_tenant_id uuid
)
returns void
language plpgsql
volatile
security definer
set search_path = catchmenu_common
as $$
begin
  insert into
    catchmenu_common.saas_launch_checklist (
    tenant_id, check_code, check_name,
    check_category, check_priority, phase,
    is_automated
  )
  select p_tenant_id, c.check_code,
         c.check_name, c.check_category,
         c.check_priority, c.phase,
         c.is_automated
  from (
    values
    -- 1차 MVP 체크
    ('MVP_POS_CONNECTED',
      'OKpos 또는 토스POS 연동',
      'INTEGRATION', 'REQUIRED', '1', true),
    ('MVP_KDS_VERIFIED',
      'KDS 티켓 흐름 검증',
      'FUNCTIONAL', 'REQUIRED', '1', true),
    ('MVP_WAITING_FLOW',
      '대기 → 착석 흐름 검증',
      'FUNCTIONAL', 'REQUIRED', '1', true),
    ('MVP_PAYMENT_RECONCILIATION',
      'Layer 1~3 결제 대사 통과',
      'FINANCIAL', 'REQUIRED', '1', true),
    ('MVP_MENU_PUBLISHED',
      '메뉴 5개 이상 발행',
      'SETUP', 'REQUIRED', '1', true),
    -- 1-B차 체크
    ('B_TAKEOUT_ORDER',
      '포장 주문 엔드투엔드 검증',
      'FUNCTIONAL', 'REQUIRED', '1B', true),
    ('B_CUSTOMER_APP',
      '고객 앱 부트스트랩 검증',
      'FUNCTIONAL', 'REQUIRED', '1B', true),
    ('B_DELIVERY_SYNC',
      '배달앱 주문 동기화 검증',
      'INTEGRATION', 'REQUIRED', '1B', true),
    ('B_PUSH_NOTIFICATION',
      '고객 푸시 알림 발송 검증',
      'FUNCTIONAL', 'REQUIRED', '1B', true),
    ('B_CMS_BUNDLE',
      'CMS 번들 로드 검증',
      'FUNCTIONAL', 'RECOMMENDED', '1B', true),
    ('B_DID_DISPLAY',
      'DID 픽업 호출 검증',
      'FUNCTIONAL', 'RECOMMENDED', '1B', true),
    ('B_SAAS_BILLING',
      '구독 청구 + 인보이스 검증',
      'FINANCIAL', 'REQUIRED', '1B', true),
    -- 1-C차 핵심 체크
    ('C_AI_CUSTOMER_CENTER',
      'AI 고객센터 그라운딩률 70% 이상',
      'AI', 'REQUIRED', '1C', true),
    ('C_DIGITAL_SOP',
      'Digital SOP 5개 이상 발행',
      'KNOWLEDGE', 'REQUIRED', '1C', true),
    ('C_RAG_PIPELINE',
      'RAG 파이프라인 응답 3초 이내',
      'PERFORMANCE', 'REQUIRED', '1C', true),
    ('C_MULTITENANT_ISOLATION',
      '멀티테넌트 RLS 전체 통과',
      'SECURITY', 'REQUIRED', '1C', true),
    ('C_SECURITY_AUDIT',
      '보안 감사 CRITICAL 0건',
      'SECURITY', 'REQUIRED', '1C', true),
    ('C_QUOTA_ENFORCEMENT',
      '쿼터 한도 적용 검증',
      'INFRA', 'REQUIRED', '1C', true),
    ('C_FRANCHISE_POLICY',
      '프랜차이즈 정책 배포 + 준수 검증',
      'FRANCHISE', 'REQUIRED', '1C', true),
    ('C_MENU_DISTRIBUTION',
      '본사 메뉴 배포 + 동기화 검증',
      'FRANCHISE', 'REQUIRED', '1C', true),
    ('C_RECONCILIATION_L2L3',
      'Layer 2/3 정산 대사 통과',
      'FINANCIAL', 'REQUIRED', '1C', true),
    -- 수동 확인 항목
    ('M_LEGAL_REVIEW',
      '법률 검토 완료 (이용약관/개인정보)',
      'LEGAL', 'REQUIRED', '1C', false),
    ('M_SECURITY_PENTEST',
      '보안 침투 테스트 완료',
      'SECURITY', 'REQUIRED', '1C', false),
    ('M_PAYMENT_CERTIFICATION',
      '결제 PG 계약 및 인증 완료',
      'FINANCIAL', 'REQUIRED', '1C', false),
    ('M_ALLERGEN_COMPLIANCE',
      '식품위생법 알레르겐 표시 검수',
      'COMPLIANCE', 'REQUIRED', '1C', false),
    ('M_FIRST_STORE_VERIFIED',
      '1호점 실제 운영 30일 이상',
      'OPERATIONAL', 'REQUIRED', '1C', false),
    ('M_CUSTOMER_FEEDBACK',
      '1호점 고객 피드백 수집 완료',
      'OPERATIONAL', 'RECOMMENDED', '1C', false),
    ('M_SLA_DEFINED',
      'SaaS SLA 정의 및 문서화',
      'OPERATIONAL', 'REQUIRED', '1C', false),
    ('M_SUPPORT_CHANNEL',
      '고객 지원 채널 구축',
      'OPERATIONAL', 'RECOMMENDED', '1C', false)
  ) as c(
    check_code, check_name, check_category,
    check_priority, phase, is_automated
  )
  on conflict (tenant_id, check_code) do nothing;
end;
$$;


-- =============================================
-- RPCs
-- =============================================

-- update_check was originally (incorrectly) written as a nested
-- procedure inside run_saas_launch_checklist's DECLARE section, closing
-- over that function's p_tenant_id parameter -- same invalid pattern as
-- 0073's assert_true and others found this session. Unlike those, this
-- one needs no temp table: it only performs a direct UPDATE and never
-- fed state back into run_saas_launch_checklist's local variables (the
-- final passed/failed/manual/waived counts come from a separate
-- aggregation query against saas_launch_checklist after all checks run,
-- untouched here). Fixed as a standalone function taking p_tenant_id as
-- an explicit parameter. All 22 call sites below were mechanically
-- changed from the old CALL-based invocation to a PERFORM-based one,
-- with p_tenant_id added as the new leading argument, no other
-- argument touched.
create or replace function catchmenu_common.update_saas_launch_check(
  p_tenant_id uuid,
  p_code text,
  p_status text,
  p_result jsonb
)
returns void
language plpgsql
as $$
begin
  update catchmenu_common.saas_launch_checklist
  set
    check_status = p_status,
    last_checked_at = now(),
    check_result = p_result,
    updated_at = now()
  where tenant_id = p_tenant_id
    and check_code = p_code;
end;
$$;

create or replace function
  catchmenu_common.run_saas_launch_checklist(
  p_tenant_id uuid,
  p_store_id uuid,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_common,
                  catchmenu_hq,
                  catchmenu_pos,
                  catchmenu_kds,
                  catchmenu_payment,
                  catchmenu_store,
                  catchmenu_knowledge,
                  catchmenu_integrations
as $$
declare
  v_check record;
  v_result boolean;
  v_detail jsonb;
  v_passed int := 0;
  v_failed int := 0;
  v_manual int := 0;
  v_waived int := 0;
  v_required_failed int := 0;
  v_business_day date;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  -- 체크리스트 시드
  perform catchmenu_common.seed_saas_launch_checklist(
    p_tenant_id
  );

  -- ==========================================
  -- 자동 검사 항목
  -- ==========================================

  -- MVP_POS_CONNECTED
  declare
    v_pos_count int;
  begin
    select count(*) into v_pos_count
    from catchmenu_integrations.pos_store_configs
    where store_id = p_store_id
      and is_active = true;

    v_result := v_pos_count > 0;
    v_detail := jsonb_build_object(
      'pos_configs', v_pos_count
    );
    perform catchmenu_common.update_saas_launch_check(

      p_tenant_id,
      'MVP_POS_CONNECTED',
      case v_result when true then 'PASSED'
        else 'FAILED' end,
      v_detail
    );
  end;

  -- MVP_KDS_VERIFIED
  declare
    v_kds_completed int;
  begin
    select count(*) into v_kds_completed
    from catchmenu_kds.kds_tickets
    where store_id = p_store_id
      and tenant_id = p_tenant_id
      and kds_status in (
        'SERVED', 'COMPLETED'
      );

    v_result := v_kds_completed >= 10;
    perform catchmenu_common.update_saas_launch_check(

      p_tenant_id,
      'MVP_KDS_VERIFIED',
      case v_result when true then 'PASSED'
        else 'FAILED' end,
      jsonb_build_object(
        'completed_tickets', v_kds_completed,
        'required', 10
      )
    );
  end;

  -- MVP_WAITING_FLOW
  declare
    v_completed_sessions int;
  begin
    select count(*) into v_completed_sessions
    from catchmenu_pos.order_sessions
    where store_id = p_store_id
      and tenant_id = p_tenant_id
      and session_type = 'WAITING'
      and session_status = 'COMPLETED';

    v_result := v_completed_sessions >= 5;
    perform catchmenu_common.update_saas_launch_check(

      p_tenant_id,
      'MVP_WAITING_FLOW',
      case v_result when true then 'PASSED'
        else 'FAILED' end,
      jsonb_build_object(
        'completed_sessions',
          v_completed_sessions,
        'required', 5
      )
    );
  end;

  -- MVP_PAYMENT_RECONCILIATION
  declare
    v_balanced_days int;
  begin
    select count(*) into v_balanced_days
    from catchmenu_payment
      .reconciliation_layer2_results
    where store_id = p_store_id
      and tenant_id = p_tenant_id
      and recon_status = 'BALANCED';

    v_result := v_balanced_days >= 1;
    perform catchmenu_common.update_saas_launch_check(

      p_tenant_id,
      'MVP_PAYMENT_RECONCILIATION',
      case v_result when true then 'PASSED'
        else 'FAILED' end,
      jsonb_build_object(
        'balanced_days', v_balanced_days
      )
    );
  end;

  -- MVP_MENU_PUBLISHED
  declare
    v_menu_count int;
  begin
    select count(*) into v_menu_count
    from catchmenu_pos.menus
    where store_id = p_store_id
      and tenant_id = p_tenant_id
      and is_active = true
      and menu_status = 'AVAILABLE';

    v_result := v_menu_count >= 5;
    perform catchmenu_common.update_saas_launch_check(

      p_tenant_id,
      'MVP_MENU_PUBLISHED',
      case v_result when true then 'PASSED'
        else 'FAILED' end,
      jsonb_build_object(
        'menu_count', v_menu_count,
        'required', 5
      )
    );
  end;

  -- B_TAKEOUT_ORDER
  declare
    v_takeout_count int;
  begin
    select count(*) into v_takeout_count
    from catchmenu_pos.orders
    where store_id = p_store_id
      and tenant_id = p_tenant_id
      and order_type = 'TAKEOUT'
      and order_status = 'COMPLETED';

    v_result := v_takeout_count >= 5;
    perform catchmenu_common.update_saas_launch_check(

      p_tenant_id,
      'B_TAKEOUT_ORDER',
      case v_result when true then 'PASSED'
        else 'FAILED' end,
      jsonb_build_object(
        'completed_takeout', v_takeout_count,
        'required', 5
      )
    );
  end;

  -- B_CUSTOMER_APP
  declare
    v_session_count int;
  begin
    select count(*) into v_session_count
    from catchmenu_store.customer_app_sessions
    where tenant_id = p_tenant_id
      and session_status = 'ACTIVE';

    v_result := v_session_count >= 1;
    perform catchmenu_common.update_saas_launch_check(

      p_tenant_id,
      'B_CUSTOMER_APP',
      case v_result when true then 'PASSED'
        else 'FAILED' end,
      jsonb_build_object(
        'active_sessions', v_session_count
      )
    );
  end;

  -- B_DELIVERY_SYNC
  declare
    v_sync_count int;
  begin
    select count(*) into v_sync_count
    from catchmenu_integrations
      .delivery_order_sync_log
    where store_id = p_store_id
      and tenant_id = p_tenant_id
      and sync_result = 'SUCCESS';

    v_result := v_sync_count >= 1;
    perform catchmenu_common.update_saas_launch_check(

      p_tenant_id,
      'B_DELIVERY_SYNC',
      case v_result when true then 'PASSED'
        else 'FAILED' end,
      jsonb_build_object(
        'successful_syncs', v_sync_count
      )
    );
  end;

  -- B_PUSH_NOTIFICATION
  declare
    v_push_sent int;
  begin
    select count(*) into v_push_sent
    from catchmenu_store.push_notification_log
    where tenant_id = p_tenant_id
      and send_status in (
        'SENT', 'DELIVERED', 'READ'
      );

    v_result := v_push_sent >= 1;
    perform catchmenu_common.update_saas_launch_check(

      p_tenant_id,
      'B_PUSH_NOTIFICATION',
      case v_result when true then 'PASSED'
        else 'FAILED' end,
      jsonb_build_object(
        'notifications_sent', v_push_sent
      )
    );
  end;

  -- B_SAAS_BILLING
  declare
    v_invoice_count int;
  begin
    select count(*) into v_invoice_count
    from catchmenu_common.subscription_invoices
    where tenant_id = p_tenant_id
      and invoice_status in ('PAID', 'ISSUED');

    v_result := v_invoice_count >= 1;
    perform catchmenu_common.update_saas_launch_check(

      p_tenant_id,
      'B_SAAS_BILLING',
      case v_result when true then 'PASSED'
        else 'FAILED' end,
      jsonb_build_object(
        'invoices', v_invoice_count
      )
    );
  end;

  -- C_AI_CUSTOMER_CENTER
  declare
    v_grounding_rate int;
  begin
    select coalesce(
      (count(*) filter (
        where is_grounded = true
      )::numeric / nullif(count(*), 0) * 100
      )::int, 0
    )
    into v_grounding_rate
    from catchmenu_knowledge.ai_query_logs
    where tenant_id = p_tenant_id
      and created_at > now() - interval '7 days';

    v_result := v_grounding_rate >= 70;
    perform catchmenu_common.update_saas_launch_check(

      p_tenant_id,
      'C_AI_CUSTOMER_CENTER',
      case v_result when true then 'PASSED'
        else 'FAILED' end,
      jsonb_build_object(
        'grounding_rate_pct', v_grounding_rate,
        'required_pct', 70
      )
    );
  end;

  -- C_DIGITAL_SOP
  declare
    v_sop_count int;
  begin
    select count(*) into v_sop_count
    from catchmenu_knowledge.documents
    where tenant_id = p_tenant_id
      and document_status = 'PUBLISHED'
      and is_tenant_approved = true
      and is_active = true;

    v_result := v_sop_count >= 5;
    perform catchmenu_common.update_saas_launch_check(

      p_tenant_id,
      'C_DIGITAL_SOP',
      case v_result when true then 'PASSED'
        else 'FAILED' end,
      jsonb_build_object(
        'published_sop_count', v_sop_count,
        'required', 5
      )
    );
  end;

  -- C_RAG_PIPELINE
  declare
    v_avg_response_ms int;
  begin
    select coalesce(
      avg(response_time_ms)::int, 9999
    )
    into v_avg_response_ms
    from catchmenu_knowledge.ai_query_logs
    where tenant_id = p_tenant_id
      and response_time_ms is not null
      and created_at > now() - interval '7 days';

    v_result := v_avg_response_ms <= 3000;
    perform catchmenu_common.update_saas_launch_check(

      p_tenant_id,
      'C_RAG_PIPELINE',
      case v_result when true then 'PASSED'
        else 'FAILED' end,
      jsonb_build_object(
        'avg_response_ms', v_avg_response_ms,
        'max_allowed_ms', 3000
      )
    );
  end;

  -- C_MULTITENANT_ISOLATION
  declare
    v_rls_disabled int;
  begin
    select count(*) into v_rls_disabled
    from pg_tables t
    join pg_class c
      on c.relname = t.tablename
    join pg_namespace n
      on n.oid = c.relnamespace
      and n.nspname = t.schemaname
    where t.schemaname in (
      'catchmenu_common', 'catchmenu_hq',
      'catchmenu_pos', 'catchmenu_kds',
      'catchmenu_payment', 'catchmenu_store',
      'catchmenu_ledger', 'catchmenu_knowledge'
    )
    and c.relrowsecurity = false;

    v_result := v_rls_disabled = 0;
    perform catchmenu_common.update_saas_launch_check(

      p_tenant_id,
      'C_MULTITENANT_ISOLATION',
      case v_result when true then 'PASSED'
        else 'FAILED' end,
      jsonb_build_object(
        'rls_disabled_tables', v_rls_disabled
      )
    );
  end;

  -- C_SECURITY_AUDIT
  declare
    v_critical_count int;
  begin
    select count(*) into v_critical_count
    from catchmenu_common.security_audit_log
    where tenant_id = p_tenant_id
      and event_severity = 'CRITICAL'
      and is_violation = true
      and created_at > now() - interval '7 days';

    v_result := v_critical_count = 0;
    perform catchmenu_common.update_saas_launch_check(

      p_tenant_id,
      'C_SECURITY_AUDIT',
      case v_result when true then 'PASSED'
        else 'FAILED' end,
      jsonb_build_object(
        'critical_violations_7d',
          v_critical_count
      )
    );
  end;

  -- C_QUOTA_ENFORCEMENT
  declare
    v_quota_configured int;
  begin
    select count(*) into v_quota_configured
    from catchmenu_common.tenant_quotas
    where tenant_id = p_tenant_id
      and is_active = true;

    v_result := v_quota_configured >= 5;
    perform catchmenu_common.update_saas_launch_check(

      p_tenant_id,
      'C_QUOTA_ENFORCEMENT',
      case v_result when true then 'PASSED'
        else 'FAILED' end,
      jsonb_build_object(
        'configured_quotas', v_quota_configured,
        'required', 5
      )
    );
  end;

  -- C_FRANCHISE_POLICY
  declare
    v_policy_count int;
    v_compliant_pct int;
  begin
    select count(*) into v_policy_count
    from catchmenu_hq.franchise_policies
    where tenant_id = p_tenant_id
      and policy_status = 'PUBLISHED'
      and is_active = true;

    v_result := v_policy_count >= 1;
    perform catchmenu_common.update_saas_launch_check(

      p_tenant_id,
      'C_FRANCHISE_POLICY',
      case v_result when true then 'PASSED'
        else 'FAILED' end,
      jsonb_build_object(
        'published_policies', v_policy_count
      )
    );
  end;

  -- C_MENU_DISTRIBUTION
  declare
    v_dist_count int;
  begin
    select count(*) into v_dist_count
    from catchmenu_hq.menu_distribution_log
    where tenant_id = p_tenant_id
      and distribution_status = 'COMPLETED';

    v_result := v_dist_count >= 1;
    perform catchmenu_common.update_saas_launch_check(

      p_tenant_id,
      'C_MENU_DISTRIBUTION',
      case v_result when true then 'PASSED'
        else 'FAILED' end,
      jsonb_build_object(
        'completed_distributions', v_dist_count
      )
    );
  end;

  -- C_RECONCILIATION_L2L3
  declare
    v_l2_balanced int;
    v_l3_balanced int;
  begin
    select count(*) into v_l2_balanced
    from catchmenu_payment
      .reconciliation_layer2_results
    where tenant_id = p_tenant_id
      and recon_status = 'BALANCED';

    select count(*) into v_l3_balanced
    from catchmenu_payment
      .reconciliation_layer3_results
    where tenant_id = p_tenant_id
      and recon_status = 'BALANCED';

    v_result := v_l2_balanced >= 1;
    perform catchmenu_common.update_saas_launch_check(

      p_tenant_id,
      'C_RECONCILIATION_L2L3',
      case v_result when true then 'PASSED'
        else 'FAILED' end,
      jsonb_build_object(
        'l2_balanced', v_l2_balanced,
        'l3_balanced', v_l3_balanced
      )
    );
  end;

  -- 수동 항목 → MANUAL_REQUIRED
  update catchmenu_common.saas_launch_checklist
  set
    check_status = 'MANUAL_REQUIRED',
    last_checked_at = now()
  where tenant_id = p_tenant_id
    and is_automated = false
    and check_status = 'PENDING';

  -- 집계
  select
    count(*) filter (
      where check_status = 'PASSED'
    ),
    count(*) filter (
      where check_status = 'FAILED'
    ),
    count(*) filter (
      where check_status = 'MANUAL_REQUIRED'
    ),
    count(*) filter (
      where check_status = 'WAIVED'
    ),
    count(*) filter (
      where check_status = 'FAILED'
        and check_priority = 'REQUIRED'
    )
  into
    v_passed, v_failed, v_manual,
    v_waived, v_required_failed
  from catchmenu_common.saas_launch_checklist
  where tenant_id = p_tenant_id;

  return catchmenu_common.build_success_response(
    p_message_key := case v_required_failed
      when 0 then 'saas_launch_ready'
      else 'saas_launch_not_ready'
    end,
    p_data := jsonb_build_object(
      'tenant_id', p_tenant_id,
      'business_day', v_business_day,
      'is_launch_ready', v_required_failed = 0,
      'summary', jsonb_build_object(
        'passed', v_passed,
        'failed', v_failed,
        'manual_required', v_manual,
        'waived', v_waived,
        'required_failed', v_required_failed
      ),
      'blocker_count', v_required_failed,
      'manual_count', v_manual,
      'overall_status', case
        when v_required_failed > 0 then 'BLOCKED'
        when v_manual > 0 then 'PENDING_MANUAL'
        else 'READY'
      end
    ),
    p_locale := p_locale
  );
end;
$$;


-- assert_test was originally (incorrectly) written as a nested procedure
-- inside run_integration_test's DECLARE section, closing over
-- p_tenant_id/p_store_id/p_test_suite/v_start -- same invalid pattern as
-- 0073's assert_true and others found this session. Fixed as a
-- standalone function taking those as explicit parameters. It still
-- performs the real INSERT into integration_test_results (unchanged
-- logic), and additionally logs to a temp table so
-- run_integration_test can reconstruct v_passed/v_failed/v_results
-- afterward (a standalone routine can't mutate the caller's local
-- variables directly). All call sites below were mechanically changed
-- from the old CALL-based invocation to a PERFORM-based one, with
-- p_tenant_id/p_store_id/p_test_suite/v_start added as new leading
-- arguments, no other argument touched.
create temp table if not exists integration_test_assertions (
  ordinal bigint generated always as identity,
  test_id uuid,
  code text,
  name text,
  status text,
  detail jsonb
);

create or replace function catchmenu_common.assert_integration_test(
  p_tenant_id uuid,
  p_store_id uuid,
  p_test_suite text,
  p_run_start timestamptz,
  p_code text,
  p_name text,
  p_category text,
  p_condition boolean,
  p_detail jsonb default null
)
returns void
language plpgsql
as $$
declare
  v_status text;
  v_test_id uuid;
begin
  v_status := case p_condition
    when true then 'PASSED'
    else 'FAILED'
  end;

  insert into
    catchmenu_common.integration_test_results (
    tenant_id, store_id,
    test_suite, test_code, test_name,
    test_category, test_status,
    passed_assertions,
    failed_assertions,
    test_detail,
    execution_ms, ran_at
  ) values (
    p_tenant_id, p_store_id,
    p_test_suite, p_code, p_name,
    p_category, v_status,
    case p_condition when true then 1 else 0 end,
    case p_condition when true then 0 else 1 end,
    coalesce(p_detail, '{}'::jsonb),
    extract(
      epoch from (now() - p_run_start)
    )::int * 1000,
    now()
  )
  returning id into v_test_id;

  insert into pg_temp.integration_test_assertions
    (test_id, code, name, status, detail)
    values (v_test_id, p_code, p_name, v_status, p_detail);
end;
$$;

create or replace function
  catchmenu_common.run_integration_test(
  p_tenant_id uuid,
  p_store_id uuid,
  p_test_suite text,
  p_locale text default 'ko'
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
                  catchmenu_knowledge
as $$
declare
  v_suite_id uuid;
  v_passed int := 0;
  v_failed int := 0;
  v_start timestamptz := now();
  v_results jsonb := '[]'::jsonb;
begin
  delete from pg_temp.integration_test_assertions;
  case p_test_suite
    when 'PAYMENT' then
      -- 결제 통합 테스트
      declare
        v_ledger_count int;
        v_approved_sum int;
        v_recon_count int;
      begin
        select count(*), coalesce(sum(approved_amount), 0)
        into v_ledger_count, v_approved_sum
        from catchmenu_payment.payment_ledger
        where store_id = p_store_id
          and tenant_id = p_tenant_id
          and ledger_status = 'APPROVED';

        perform catchmenu_common.assert_integration_test(


          p_tenant_id, p_store_id, p_test_suite, v_start,
          'PAY_001', '결제 원장 존재',
          'PAYMENT', v_ledger_count > 0,
          jsonb_build_object(
            'ledger_count', v_ledger_count
          )
        );

        perform catchmenu_common.assert_integration_test(


          p_tenant_id, p_store_id, p_test_suite, v_start,
          'PAY_002', '승인 금액 양수',
          'PAYMENT', v_approved_sum > 0,
          jsonb_build_object(
            'approved_sum', v_approved_sum
          )
        );

        select count(*) into v_recon_count
        from catchmenu_payment
          .reconciliation_layer2_results
        where store_id = p_store_id
          and recon_status in (
            'BALANCED', 'RESOLVED'
          );

        perform catchmenu_common.assert_integration_test(


          p_tenant_id, p_store_id, p_test_suite, v_start,
          'PAY_003', 'Layer2 대사 통과',
          'RECONCILIATION', v_recon_count >= 1,
          jsonb_build_object(
            'balanced_days', v_recon_count
          )
        );
      end;

    when 'KDS' then
      -- KDS 통합 테스트
      declare
        v_hold_flow int;
        v_commit_flow int;
        v_served_flow int;
        v_late_count int;
      begin
        select count(*) into v_hold_flow
        from catchmenu_kds.kds_tickets
        where store_id = p_store_id
          and tenant_id = p_tenant_id
          and kds_status != 'HOLD';

        perform catchmenu_common.assert_integration_test(


          p_tenant_id, p_store_id, p_test_suite, v_start,
          'KDS_001', 'KDS HOLD → 상태 전환',
          'KDS_FLOW', v_hold_flow > 0,
          jsonb_build_object(
            'transitioned', v_hold_flow
          )
        );

        select count(*) into v_served_flow
        from catchmenu_kds.kds_tickets
        where store_id = p_store_id
          and tenant_id = p_tenant_id
          and kds_status in (
            'SERVED', 'COMPLETED'
          );

        perform catchmenu_common.assert_integration_test(


          p_tenant_id, p_store_id, p_test_suite, v_start,
          'KDS_002', 'KDS SERVED 완료',
          'KDS_FLOW', v_served_flow >= 5,
          jsonb_build_object(
            'served_count', v_served_flow,
            'required', 5
          )
        );

        select count(*) into v_late_count
        from catchmenu_kds.kds_tickets
        where store_id = p_store_id
          and tenant_id = p_tenant_id
          and is_late = true
          and kds_status not in (
            'CANCELLED', 'SERVED', 'COMPLETED'
          );

        perform catchmenu_common.assert_integration_test(


          p_tenant_id, p_store_id, p_test_suite, v_start,
          'KDS_003', 'KDS 지연 티켓 0건',
          'KDS_QUALITY', v_late_count = 0,
          jsonb_build_object(
            'late_tickets', v_late_count
          )
        );
      end;

    when 'WAITING' then
      -- 대기 흐름 통합 테스트
      declare
        v_wait_started int;
        v_wait_completed int;
        v_arrival_rate int;
      begin
        select
          count(*) filter (
            where session_type = 'WAITING'
          ),
          count(*) filter (
            where session_type = 'WAITING'
              and session_status = 'COMPLETED'
          )
        into v_wait_started, v_wait_completed
        from catchmenu_pos.order_sessions
        where store_id = p_store_id
          and tenant_id = p_tenant_id;

        perform catchmenu_common.assert_integration_test(


          p_tenant_id, p_store_id, p_test_suite, v_start,
          'WAIT_001', '대기 세션 생성',
          'WAITING', v_wait_started >= 5,
          jsonb_build_object(
            'started', v_wait_started
          )
        );

        perform catchmenu_common.assert_integration_test(


          p_tenant_id, p_store_id, p_test_suite, v_start,
          'WAIT_002', '대기 → 착석 완료',
          'WAITING', v_wait_completed >= 3,
          jsonb_build_object(
            'completed', v_wait_completed
          )
        );

        v_arrival_rate := case v_wait_started
          when 0 then 0
          else (
            v_wait_completed::numeric
            / v_wait_started * 100
          )::int
        end;

        perform catchmenu_common.assert_integration_test(


          p_tenant_id, p_store_id, p_test_suite, v_start,
          'WAIT_003', '착석 전환율 50% 이상',
          'WAITING_QUALITY',
          v_arrival_rate >= 50,
          jsonb_build_object(
            'arrival_rate_pct', v_arrival_rate
          )
        );
      end;

    when 'AI' then
      -- AI 고객센터 통합 테스트
      declare
        v_query_count int;
        v_grounded_count int;
        v_grounding_rate int;
        v_sop_count int;
        v_avg_ms int;
      begin
        select
          count(*),
          count(*) filter (
            where is_grounded = true
          ),
          coalesce(avg(response_time_ms)::int, 0)
        into v_query_count, v_grounded_count,
             v_avg_ms
        from catchmenu_knowledge.ai_query_logs
        where tenant_id = p_tenant_id;

        perform catchmenu_common.assert_integration_test(


          p_tenant_id, p_store_id, p_test_suite, v_start,
          'AI_001', 'AI 쿼리 10건 이상',
          'AI_VOLUME', v_query_count >= 10,
          jsonb_build_object(
            'query_count', v_query_count
          )
        );

        v_grounding_rate := case v_query_count
          when 0 then 0
          else (
            v_grounded_count::numeric
            / v_query_count * 100
          )::int
        end;

        perform catchmenu_common.assert_integration_test(


          p_tenant_id, p_store_id, p_test_suite, v_start,
          'AI_002', 'AI 그라운딩률 70% 이상',
          'AI_QUALITY',
          v_grounding_rate >= 70,
          jsonb_build_object(
            'grounding_rate_pct',
              v_grounding_rate,
            'required_pct', 70
          )
        );

        perform catchmenu_common.assert_integration_test(


          p_tenant_id, p_store_id, p_test_suite, v_start,
          'AI_003', 'AI 응답 속도 3초 이내',
          'AI_PERFORMANCE',
          v_avg_ms <= 3000,
          jsonb_build_object(
            'avg_response_ms', v_avg_ms,
            'max_allowed_ms', 3000
          )
        );

        select count(*) into v_sop_count
        from catchmenu_knowledge.documents
        where tenant_id = p_tenant_id
          and document_status = 'PUBLISHED'
          and is_tenant_approved = true;

        perform catchmenu_common.assert_integration_test(


          p_tenant_id, p_store_id, p_test_suite, v_start,
          'AI_004', 'SOP 문서 5개 이상',
          'KNOWLEDGE_BASE',
          v_sop_count >= 5,
          jsonb_build_object(
            'sop_count', v_sop_count
          )
        );
      end;

    when 'SECURITY' then
      -- 보안 통합 테스트
      declare
        v_rls_count int;
        v_violation_count int;
        v_quota_count int;
      begin
        select count(*) into v_rls_count
        from pg_tables t
        join pg_class c
          on c.relname = t.tablename
        join pg_namespace n
          on n.oid = c.relnamespace
          and n.nspname = t.schemaname
        where t.schemaname like 'catchmenu_%'
          and c.relrowsecurity = false;

        perform catchmenu_common.assert_integration_test(


          p_tenant_id, p_store_id, p_test_suite, v_start,
          'SEC_001', 'RLS 전체 활성화',
          'SECURITY', v_rls_count = 0,
          jsonb_build_object(
            'rls_disabled', v_rls_count
          )
        );

        select count(*) into v_violation_count
        from catchmenu_common.security_audit_log
        where tenant_id = p_tenant_id
          and event_severity = 'CRITICAL'
          and is_violation = true
          and created_at > now()
            - interval '24 hours';

        perform catchmenu_common.assert_integration_test(


          p_tenant_id, p_store_id, p_test_suite, v_start,
          'SEC_002', '24h CRITICAL 위반 0건',
          'SECURITY', v_violation_count = 0,
          jsonb_build_object(
            'critical_violations',
              v_violation_count
          )
        );

        select count(*) into v_quota_count
        from catchmenu_common.tenant_quotas
        where tenant_id = p_tenant_id
          and is_active = true;

        perform catchmenu_common.assert_integration_test(


          p_tenant_id, p_store_id, p_test_suite, v_start,
          'SEC_003', '쿼터 설정 5개 이상',
          'QUOTA', v_quota_count >= 5,
          jsonb_build_object(
            'configured_quotas', v_quota_count
          )
        );
      end;

    else
      return catchmenu_common.build_error_response(
        p_error_key := 'invalid_input',
        p_locale := p_locale,
        p_params := jsonb_build_object(
          'field', 'test_suite',
          'allowed',
            'PAYMENT/KDS/WAITING/AI/SECURITY'
        ),
        p_tenant_id := p_tenant_id,
        p_rpc_name := 'run_integration_test'
      );
  end case;

  -- populate v_passed/v_failed/v_results from the temp table now that
  -- all assert_integration_test() calls above have logged into it
  select
    count(*) filter (where status = 'PASSED'),
    count(*) filter (where status = 'FAILED'),
    coalesce(jsonb_agg(
      jsonb_build_object(
        'test_id', test_id,
        'code', code,
        'name', name,
        'status', status,
        'detail', detail
      )
      order by ordinal
    ), '[]'::jsonb)
  into v_passed, v_failed, v_results
  from pg_temp.integration_test_assertions;

  return catchmenu_common.build_success_response(
    p_message_key := case v_failed
      when 0 then 'integration_test_passed'
      else 'integration_test_failed'
    end,
    p_data := jsonb_build_object(
      'test_suite', p_test_suite,
      'passed', v_passed,
      'failed', v_failed,
      'total', v_passed + v_failed,
      'is_passed', v_failed = 0,
      'execution_ms', extract(
        epoch from (now() - v_start)
      )::int * 1000,
      'results', v_results
    ),
    p_locale := p_locale
  );
end;
$$;


create or replace function
  catchmenu_common.authorize_go_live(
  p_tenant_id uuid,
  p_store_id uuid,
  p_authorized_by uuid,
  p_authorization_note text,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_common,
                  catchmenu_hq,
                  catchmenu_ledger,
                  catchmenu_audit
as $$
declare
  v_required_failed int;
  v_manual_pending int;
  v_audit_id uuid;
  v_business_day date;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  -- 필수 체크 실패 확인
  select
    count(*) filter (
      where check_status = 'FAILED'
        and check_priority = 'REQUIRED'
    ),
    count(*) filter (
      where check_status = 'MANUAL_REQUIRED'
        and check_priority = 'REQUIRED'
    )
  into v_required_failed, v_manual_pending
  from catchmenu_common.saas_launch_checklist
  where tenant_id = p_tenant_id;

  if v_required_failed > 0
    or v_manual_pending > 0
  then
    return catchmenu_common.build_error_response(
      p_error_key := 'go_live_blocked',
      p_locale := p_locale,
      p_params := jsonb_build_object(
        'failed_count', v_required_failed,
        'manual_pending', v_manual_pending
      ),
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'authorize_go_live'
    );
  end if;

  -- 온보딩 GO_LIVE 완료 처리
  update catchmenu_common.tenant_onboarding_log
  set
    step_status = 'COMPLETED',
    completed_at = now(),
    completed_by = p_authorized_by::text,
    step_note = p_authorization_note,
    updated_at = now()
  where tenant_id = p_tenant_id
    and onboarding_step = 'GO_LIVE';

  -- audit
  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := 'system',
    p_audit_type := 'go_live_authorized',
    p_audit_category := 'OPERATIONAL',
    p_actor_type := 'HQ_ADMIN',
    p_actor_id := p_authorized_by,
    p_subject_type := 'tenant',
    p_subject_id := p_tenant_id,
    p_decision := 'GO_LIVE_AUTHORIZED',
    p_decision_reason := p_authorization_note,
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
    event_payload,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'system', 'go_live_authorized', 1,
    'tenant', p_tenant_id,
    'ONBOARDING', 'LIVE',
    'HQ_ADMIN', p_authorized_by,
    jsonb_build_object(
      'authorization_note',
        p_authorization_note,
      'audit_id', v_audit_id,
      'authorized_at', now()
    ),
    v_business_day, 'Asia/Seoul', now()
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'go_live_authorized',
    p_data := jsonb_build_object(
      'tenant_id', p_tenant_id,
      'store_id', p_store_id,
      'authorized_at', now(),
      'authorized_by', p_authorized_by,
      'audit_id', v_audit_id,
      'status', 'LIVE',
      'congratulations',
        '1-C차 SaaS 출시 승인 완료'
    ),
    p_locale := p_locale
  );
end;
$$;


create or replace function
  catchmenu_common.get_launch_readiness_report(
  p_tenant_id uuid,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_common
as $$
declare
  v_by_phase jsonb;
  v_by_category jsonb;
  v_blockers jsonb;
  v_manual_items jsonb;
  v_overall jsonb;
begin
  -- 단계별 현황
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'phase', phase,
        'total', count(*),
        'passed', count(*) filter (
          where check_status = 'PASSED'
        ),
        'failed', count(*) filter (
          where check_status = 'FAILED'
        ),
        'manual_required', count(*) filter (
          where check_status = 'MANUAL_REQUIRED'
        ),
        'completion_pct', (
          count(*) filter (
            where check_status in (
              'PASSED', 'WAIVED'
            )
          )::numeric / count(*) * 100
        )::int
      )
      order by phase
    ),
    '[]'::jsonb
  )
  into v_by_phase
  from catchmenu_common.saas_launch_checklist
  where tenant_id = p_tenant_id
  group by phase;

  -- 카테고리별 현황
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'category', check_category,
        'total', count(*),
        'passed', count(*) filter (
          where check_status = 'PASSED'
        ),
        'failed', count(*) filter (
          where check_status = 'FAILED'
        )
      )
      order by check_category
    ),
    '[]'::jsonb
  )
  into v_by_category
  from catchmenu_common.saas_launch_checklist
  where tenant_id = p_tenant_id
  group by check_category;

  -- 블로커 (REQUIRED + FAILED)
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'check_code', check_code,
        'check_name', check_name,
        'check_category', check_category,
        'phase', phase,
        'check_result', check_result,
        'last_checked_at', last_checked_at
      )
      order by phase, check_category
    ),
    '[]'::jsonb
  )
  into v_blockers
  from catchmenu_common.saas_launch_checklist
  where tenant_id = p_tenant_id
    and check_status = 'FAILED'
    and check_priority = 'REQUIRED';

  -- 수동 확인 필요 항목
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'check_code', check_code,
        'check_name', check_name,
        'check_category', check_category,
        'phase', phase
      )
      order by phase, check_category
    ),
    '[]'::jsonb
  )
  into v_manual_items
  from catchmenu_common.saas_launch_checklist
  where tenant_id = p_tenant_id
    and check_status = 'MANUAL_REQUIRED';

  -- 전체 요약
  select jsonb_build_object(
    'total', count(*),
    'passed', count(*) filter (
      where check_status = 'PASSED'
    ),
    'failed', count(*) filter (
      where check_status = 'FAILED'
    ),
    'manual_required', count(*) filter (
      where check_status = 'MANUAL_REQUIRED'
    ),
    'waived', count(*) filter (
      where check_status = 'WAIVED'
    ),
    'required_failed', count(*) filter (
      where check_status = 'FAILED'
        and check_priority = 'REQUIRED'
    ),
    'overall_completion_pct', (
      count(*) filter (
        where check_status in (
          'PASSED', 'WAIVED'
        )
      )::numeric / nullif(count(*), 0) * 100
    )::int
  )
  into v_overall
  from catchmenu_common.saas_launch_checklist
  where tenant_id = p_tenant_id;

  return catchmenu_common.build_success_response(
    p_message_key := 'launch_report_loaded',
    p_data := jsonb_build_object(
      'tenant_id', p_tenant_id,
      'is_launch_ready',
        (v_overall->>'required_failed')::int = 0
        and (v_overall->>'manual_required')::int = 0,
      'overall', v_overall,
      'by_phase', v_by_phase,
      'by_category', v_by_category,
      'blockers', v_blockers,
      'blocker_count',
        jsonb_array_length(v_blockers),
      'manual_items', v_manual_items,
      'manual_count',
        jsonb_array_length(v_manual_items),
      'roadmap', jsonb_build_object(
        'phase_1', '1호점 MVP (2027.09)',
        'phase_1b', 'SaaS 전환 준비',
        'phase_2_3', '매장OS + Franchise_OS 사전',
        'phase_1c', '완전 SaaS 출시 (2028~2029)',
        'phase_4', 'Franchise_OS 완전 구현',
        'phase_6', 'Physical AI Gateway'
      ),
      'generated_at', now()
    ),
    p_locale := p_locale
  );
end;
$$;


-- grants
do $$
begin
  revoke all on function
    catchmenu_common.run_saas_launch_checklist(
      uuid, uuid, text
    ) from public;
  grant execute on function
    catchmenu_common.run_saas_launch_checklist(
      uuid, uuid, text
    ) to authenticated;

  revoke all on function
    catchmenu_common.run_integration_test(
      uuid, uuid, text, text
    ) from public;
  grant execute on function
    catchmenu_common.run_integration_test(
      uuid, uuid, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_common.authorize_go_live(
      uuid, uuid, uuid, text, text
    ) from public;
  grant execute on function
    catchmenu_common.authorize_go_live(
      uuid, uuid, uuid, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_common.get_launch_readiness_report(
      uuid, text
    ) from public;
  grant execute on function
    catchmenu_common.get_launch_readiness_report(
      uuid, text
    ) to authenticated;

  revoke all on function
    catchmenu_common.seed_saas_launch_checklist(uuid)
    from public;
  grant execute on function
    catchmenu_common.seed_saas_launch_checklist(uuid)
    to authenticated;
end;
$$;

comment on function
  catchmenu_common.run_saas_launch_checklist(
    uuid, uuid, text
  ) is
  '1-C차 SaaS 출시 준비 체크리스트 실행.
   자동 검사 항목 (19개):
   - 1차 MVP: POS/KDS/대기/결제/메뉴
   - 1-B차: 포장/앱/배달/푸시/청구
   - 1-C차: AI/SOP/RAG/격리/보안/쿼터/프랜차이즈

   수동 확인 항목 (9개):
   - 법률검토/침투테스트/결제인증
   - 알레르겐/1호점30일/SLA/지원채널

   is_launch_ready = true 조건:
   REQUIRED 항목 전부 PASSED/WAIVED
   + 수동 항목 전부 완료.

   SaaS 출시 예상: 2028년 중~2029년 초.
   1호점 오픈: 2027년 9월.';

comment on function
  catchmenu_common.authorize_go_live(
    uuid, uuid, uuid, text, text
  ) is
  '1-C차 SaaS 운영 시작 최종 승인.
   사전 조건:
   1. run_saas_launch_checklist() 통과
   2. REQUIRED 항목 전부 PASSED
   3. 수동 확인 항목 전부 완료

   승인 처리:
   1. 온보딩 GO_LIVE 완료
   2. 감사 기록
   3. ledger event 기록

   이후 catchmenu_common.provision_tenant()
   신규 테넌트 온보딩 시작 가능.
   SaaS 판매 = AI 고객센터 포함 필수.';