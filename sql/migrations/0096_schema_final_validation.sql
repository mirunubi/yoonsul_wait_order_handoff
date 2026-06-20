-- 0096_schema_final_validation.sql
-- Purpose: Final schema validation and migration
--          completion declaration.
--          전체 스키마 무결성 검증.
--          마이그레이션 완료 선언.
--          스키마 버전 등록.
--          0001~0095 전체 검증.
-- Depends on: 0095_create_pgcron_monitoring_rpc.sql

-- =============================================
-- 스키마 버전 등록
-- =============================================
create table if not exists
  catchmenu_common.schema_versions (
  id uuid primary key default gen_random_uuid(),
  version_code text not null unique,
  migration_count int not null,
  description text,
  applied_at timestamptz not null default now(),
  applied_by text default 'SYSTEM',
  is_current boolean not null default false,
  validation_result jsonb default '{}'::jsonb
);

-- 현재 버전을 이전 버전으로
update catchmenu_common.schema_versions
set is_current = false
where is_current = true;

-- 새 버전 등록
insert into catchmenu_common.schema_versions (
  version_code, migration_count,
  description, is_current
) values (
  '0096',
  96,
  '1-C차 완전 SaaS 기반 스키마 완성. '
  || 'POS/KDS/대기/결제/배달/CMS/DID/'
  || 'AI고객센터/Digital SOP/Franchise_OS/'
  || '멀티테넌트격리/i18n/SOP런북 포함.',
  true
);


-- =============================================
-- 전체 스키마 검증
-- =============================================
do $$
declare
  -- 스키마 현황
  v_schema_count int;
  v_table_count int;
  v_function_count int;
  v_index_count int;
  v_rls_enabled_count int;
  v_rls_disabled_count int;

  -- 핵심 테이블 존재 확인
  v_missing_tables text[] := '{}';
  v_required_tables text[] := array[
    -- catchmenu_common
    'catchmenu_common.tenants',
    'catchmenu_common.message_catalog',
    'catchmenu_common.error_codes',
    'catchmenu_common.pg_cron_jobs',
    'catchmenu_common.diagnostic_logs',
    'catchmenu_common.edge_function_registry',
    'catchmenu_common.flutter_sdk_patterns',
    'catchmenu_common.subscription_plans',
    'catchmenu_common.subscription_invoices',
    'catchmenu_common.usage_records',
    'catchmenu_common.tenant_plan_configs',
    'catchmenu_common.tenant_quotas',
    'catchmenu_common.tenant_rate_limits',
    'catchmenu_common.security_audit_log',
    'catchmenu_common.saas_launch_checklist',
    'catchmenu_common.integration_test_results',
    'catchmenu_common.operation_alerts',
    'catchmenu_common.pgcron_execution_log',
    'catchmenu_common.sop_runbooks',
    'catchmenu_common.schema_versions',
    -- catchmenu_hq
    'catchmenu_hq.tenants',
    'catchmenu_hq.stores',
    'catchmenu_hq.store_groups',
    'catchmenu_hq.store_group_members',
    'catchmenu_hq.menu_templates',
    'catchmenu_hq.franchise_brands',
    'catchmenu_hq.franchise_policies',
    'catchmenu_hq.franchise_policy_assignments',
    'catchmenu_hq.franchise_kpi_targets',
    'catchmenu_hq.franchise_approval_requests',
    'catchmenu_hq.menu_distribution_log',
    'catchmenu_hq.policy_compliance_checks',
    'catchmenu_hq.policy_violations',
    'catchmenu_hq.escalation_log',
    -- catchmenu_pos
    'catchmenu_pos.menus',
    'catchmenu_pos.menu_categories',
    'catchmenu_pos.order_sessions',
    'catchmenu_pos.orders',
    'catchmenu_pos.order_items',
    -- catchmenu_kds
    'catchmenu_kds.kds_tickets',
    'catchmenu_kds.kds_station_configs',
    -- catchmenu_payment
    'catchmenu_payment.payment_ledger',
    'catchmenu_payment.reconciliation_cases',
    'catchmenu_payment.reconciliation_layer2_results',
    'catchmenu_payment.reconciliation_layer3_results',
    'catchmenu_payment.pg_settlement_files',
    -- catchmenu_store
    'catchmenu_store.store_settings',
    'catchmenu_store.device_registry',
    'catchmenu_store.customers',
    'catchmenu_store.point_ledger',
    'catchmenu_store.coupons',
    'catchmenu_store.coupon_issues',
    'catchmenu_store.staff',
    'catchmenu_store.staff_shifts',
    'catchmenu_store.did_devices',
    'catchmenu_store.did_display_queue',
    'catchmenu_store.cms_contents',
    'catchmenu_store.store_notices',
    'catchmenu_store.promotions',
    'catchmenu_store.push_notification_templates',
    'catchmenu_store.push_notification_log',
    'catchmenu_store.customer_app_sessions',
    -- catchmenu_ledger
    'catchmenu_ledger.events',
    -- catchmenu_audit
    'catchmenu_audit.audit_records',
    -- catchmenu_integrations
    'catchmenu_integrations.pos_store_configs',
    'catchmenu_integrations.okpos_transactions',
    'catchmenu_integrations.delivery_order_sync_log',
    'catchmenu_integrations.delivery_platform_rules',
    -- catchmenu_knowledge
    'catchmenu_knowledge.documents',
    'catchmenu_knowledge.document_embeddings',
    'catchmenu_knowledge.ai_query_logs',
    'catchmenu_knowledge.customer_inquiries',
    'catchmenu_knowledge.inquiry_categories',
    'catchmenu_knowledge.sop_candidates',
    'catchmenu_knowledge.rag_query_contexts'
  ];

  -- 핵심 함수 존재 확인
  v_missing_functions text[] := '{}';
  v_required_functions text[] := array[
    -- common
    'catchmenu_common.get_message',
    'catchmenu_common.build_success_response',
    'catchmenu_common.build_error_response',
    'catchmenu_common.log_diagnostic',
    'catchmenu_common.notify_channel',
    'catchmenu_common.set_updated_at',
    'catchmenu_common.current_tenant_id',
    'catchmenu_common.current_store_id',
    'catchmenu_common.is_feature_enabled',
    'catchmenu_common.check_tenant_quota',
    'catchmenu_common.enforce_rate_limit',
    'catchmenu_common.run_security_audit',
    'catchmenu_common.get_tenant_health',
    'catchmenu_common.health_check',
    'catchmenu_common.provision_tenant',
    'catchmenu_common.check_saas_readiness',
    'catchmenu_common.run_saas_launch_checklist',
    'catchmenu_common.authorize_go_live',
    'catchmenu_common.get_operation_dashboard',
    -- pos
    'catchmenu_pos.get_menu_catalog_i18n',
    'catchmenu_pos.estimate_wait_time',
    -- kds
    'catchmenu_kds.transition_kds_ticket',
    'catchmenu_kds.check_kds_capacity',
    -- payment
    'catchmenu_payment.run_layer2_reconciliation',
    'catchmenu_payment.run_layer3_reconciliation',
    -- store
    'catchmenu_store.bootstrap_customer_app',
    'catchmenu_store.place_takeout_order',
    'catchmenu_store.call_customer_pickup',
    'catchmenu_store.send_push_notification',
    -- hq
    'catchmenu_hq.create_franchise_brand',
    'catchmenu_hq.publish_franchise_policy',
    'catchmenu_hq.distribute_menu_to_stores',
    'catchmenu_hq.run_compliance_check',
    -- knowledge
    'catchmenu_knowledge.search_knowledge',
    'catchmenu_knowledge.verify_answer_grounding',
    'catchmenu_knowledge.publish_sop_document',
    'catchmenu_knowledge.submit_customer_inquiry',
    -- audit
    'catchmenu_audit.append_audit_record',
    -- integrations
    'catchmenu_integrations.sync_delivery_order_status',
    'catchmenu_integrations.auto_reject_overloaded'
  ];

  -- 메시지 카탈로그 확인
  v_message_count int;
  v_error_code_count int;
  v_runbook_count int;
  v_pgcron_count int;
  v_flutter_pattern_count int;

  -- 검증 결과
  v_checks jsonb := '[]'::jsonb;
  v_passed int := 0;
  v_failed int := 0;
  v_warnings int := 0;
  v_tbl text;
  v_func text;
  v_exists boolean;

  procedure add_check(
    p_check text,
    p_status text,
    p_value text default null
  ) as
  $inner$
  begin
    v_checks := v_checks || jsonb_build_array(
      jsonb_build_object(
        'check', p_check,
        'status', p_status,
        'value', p_value
      )
    );
    case p_status
      when 'PASS' then v_passed := v_passed + 1;
      when 'FAIL' then v_failed := v_failed + 1;
      when 'WARN' then v_warnings := v_warnings + 1;
      else null;
    end case;
  end;
  $inner$;

begin
  -- 스키마 수 확인
  select count(*) into v_schema_count
  from information_schema.schemata
  where schema_name like 'catchmenu_%';

  call add_check(
    '스키마 수 (9개 이상)',
    case when v_schema_count >= 9
      then 'PASS' else 'FAIL' end,
    v_schema_count::text
  );

  -- 테이블 수 확인
  select count(*) into v_table_count
  from information_schema.tables
  where table_schema like 'catchmenu_%'
    and table_type = 'BASE TABLE';

  call add_check(
    '테이블 수 (80개 이상)',
    case when v_table_count >= 80
      then 'PASS' else 'WARN' end,
    v_table_count::text
  );

  -- 함수 수 확인
  select count(*) into v_function_count
  from pg_proc p
  join pg_namespace n on n.oid = p.pronamespace
  where n.nspname like 'catchmenu_%';

  call add_check(
    '함수 수 (150개 이상)',
    case when v_function_count >= 150
      then 'PASS' else 'WARN' end,
    v_function_count::text
  );

  -- RLS 활성화 확인
  select
    count(*) filter (where c.relrowsecurity),
    count(*) filter (where not c.relrowsecurity)
  into v_rls_enabled_count, v_rls_disabled_count
  from pg_class c
  join pg_namespace n on n.oid = c.relnamespace
  where n.nspname like 'catchmenu_%'
    and c.relkind = 'r';

  call add_check(
    'RLS 비활성화 테이블 0개',
    case when v_rls_disabled_count = 0
      then 'PASS' else 'FAIL' end,
    'disabled=' || v_rls_disabled_count
      || ', enabled=' || v_rls_enabled_count
  );

  -- 필수 테이블 존재 확인
  foreach v_tbl in array v_required_tables loop
    select exists (
      select 1
      from information_schema.tables
      where table_schema
          = split_part(v_tbl, '.', 1)
        and table_name
          = split_part(v_tbl, '.', 2)
    ) into v_exists;

    if not v_exists then
      v_missing_tables :=
        v_missing_tables || v_tbl;
    end if;
  end loop;

  call add_check(
    '필수 테이블 존재 ('
      || array_length(v_required_tables, 1)
      || '개)',
    case when array_length(
      v_missing_tables, 1
    ) is null or array_length(
      v_missing_tables, 1
    ) = 0
      then 'PASS' else 'FAIL' end,
    case when array_length(
      v_missing_tables, 1
    ) is null or array_length(
      v_missing_tables, 1
    ) = 0
      then '모두 존재'
      else '누락: '
        || array_to_string(v_missing_tables, ', ')
    end
  );

  -- 필수 함수 존재 확인
  foreach v_func in array v_required_functions loop
    select exists (
      select 1
      from pg_proc p
      join pg_namespace n
        on n.oid = p.pronamespace
      where n.nspname
          = split_part(v_func, '.', 1)
        and p.proname
          = split_part(v_func, '.', 2)
    ) into v_exists;

    if not v_exists then
      v_missing_functions :=
        v_missing_functions || v_func;
    end if;
  end loop;

  call add_check(
    '필수 함수 존재 ('
      || array_length(v_required_functions, 1)
      || '개)',
    case when array_length(
      v_missing_functions, 1
    ) is null or array_length(
      v_missing_functions, 1
    ) = 0
      then 'PASS' else 'FAIL' end,
    case when array_length(
      v_missing_functions, 1
    ) is null or array_length(
      v_missing_functions, 1
    ) = 0
      then '모두 존재'
      else '누락: '
        || array_to_string(
          v_missing_functions, ', '
        )
    end
  );

  -- 메시지 카탈로그 확인
  select count(*) into v_message_count
  from catchmenu_common.message_catalog;

  call add_check(
    '메시지 카탈로그 (200개 이상)',
    case when v_message_count >= 200
      then 'PASS' else 'WARN' end,
    v_message_count::text
  );

  -- 에러 코드 확인
  select count(*) into v_error_code_count
  from catchmenu_common.error_codes;

  call add_check(
    '에러 코드 (60개 이상)',
    case when v_error_code_count >= 60
      then 'PASS' else 'WARN' end,
    v_error_code_count::text
  );

  -- SOP 런북 확인
  select count(*) into v_runbook_count
  from catchmenu_common.sop_runbooks
  where is_active = true;

  call add_check(
    'SOP 런북 (10개 이상)',
    case when v_runbook_count >= 10
      then 'PASS' else 'WARN' end,
    v_runbook_count::text
  );

  -- pg_cron 스케줄 확인
  select count(*) into v_pgcron_count
  from catchmenu_common.pg_cron_jobs
  where is_active = true;

  call add_check(
    'pg_cron 스케줄 (15개 이상)',
    case when v_pgcron_count >= 15
      then 'PASS' else 'WARN' end,
    v_pgcron_count::text
  );

  -- Flutter 패턴 확인
  select count(*) into v_flutter_pattern_count
  from catchmenu_common.flutter_sdk_patterns
  where is_active = true;

  call add_check(
    'Flutter SDK 패턴 (10개 이상)',
    case when v_flutter_pattern_count >= 10
      then 'PASS' else 'WARN' end,
    v_flutter_pattern_count::text
  );

  -- pgvector 인덱스 확인
  call add_check(
    'pgvector HNSW 인덱스',
    case when exists (
      select 1
      from pg_indexes
      where indexname
        = 'idx_embeddings_vector'
    ) then 'PASS' else 'WARN' end,
    'idx_embeddings_vector'
  );

  -- i18n 원칙 준수 확인
  -- (vi, th 로케일 메시지 존재 여부)
  call add_check(
    'i18n vi/th 로케일 메시지',
    case when exists (
      select 1
      from catchmenu_common.message_catalog
      where locale = 'vi'
    ) and exists (
      select 1
      from catchmenu_common.message_catalog
      where locale = 'th'
    ) then 'PASS' else 'WARN' end,
    'vi+th 로케일 확인'
  );

  -- 결과 업데이트
  update catchmenu_common.schema_versions
  set validation_result = jsonb_build_object(
    'validated_at', now(),
    'passed', v_passed,
    'failed', v_failed,
    'warnings', v_warnings,
    'total_checks',
      v_passed + v_failed + v_warnings,
    'schema_count', v_schema_count,
    'table_count', v_table_count,
    'function_count', v_function_count,
    'rls_enabled', v_rls_enabled_count,
    'rls_disabled', v_rls_disabled_count,
    'message_count', v_message_count,
    'error_code_count', v_error_code_count,
    'runbook_count', v_runbook_count,
    'pgcron_count', v_pgcron_count,
    'flutter_pattern_count',
      v_flutter_pattern_count,
    'checks', v_checks,
    'overall_status', case
      when v_failed > 0 then 'FAILED'
      when v_warnings > 0 then 'WARNING'
      else 'PASSED'
    end
  )
  where version_code = '0096';

  -- 진단 로그
  perform catchmenu_common.log_diagnostic(
    p_tenant_id :=
      '00000000-0000-0000-0000-000000000001'::uuid,
    p_log_level := case
      when v_failed > 0 then 'ERROR'
      when v_warnings > 0 then 'WARNING'
      else 'INFO'
    end,
    p_log_domain := 'SYSTEM',
    p_log_event := 'schema_validation_completed',
    p_message :=
      '스키마 검증 완료 v0096'
      || ' | PASS=' || v_passed
      || ' | FAIL=' || v_failed
      || ' | WARN=' || v_warnings
      || ' | 테이블=' || v_table_count
      || ' | 함수=' || v_function_count,
    p_rpc_name := '0096_migration',
    p_details := jsonb_build_object(
      'version', '0096',
      'passed', v_passed,
      'failed', v_failed,
      'warnings', v_warnings,
      'missing_tables', v_missing_tables,
      'missing_functions', v_missing_functions
    )
  );

  raise notice
    '=== 스키마 검증 결과 v0096 ===';
  raise notice
    'PASS: % | FAIL: % | WARN: %',
    v_passed, v_failed, v_warnings;
  raise notice
    '스키마: % | 테이블: % | 함수: %',
    v_schema_count, v_table_count,
    v_function_count;
  raise notice
    '메시지: % | 에러코드: % | 런북: %',
    v_message_count, v_error_code_count,
    v_runbook_count;
  raise notice
    'pg_cron: % | Flutter패턴: %',
    v_pgcron_count, v_flutter_pattern_count;

  if v_failed > 0 then
    raise notice
      '!! 실패 항목 있음 - 확인 필요 !!';
    raise notice
      '누락 테이블: %',
      array_to_string(v_missing_tables, ', ');
    raise notice
      '누락 함수: %',
      array_to_string(v_missing_functions, ', ');
  else
    raise notice
      '✓ 스키마 검증 통과';
  end if;

end;
$$;


-- =============================================
-- 마이그레이션 완료 선언
-- =============================================
do $$
declare
  v_total_migrations int := 96;
  v_current_version text := '0096';
  v_project text := 'catchmenu / yoonsul_wait_order_handoff';
  v_target text := '1-C차 완전 SaaS 기반 스키마';
begin
  raise notice '=========================================';
  raise notice '  마이그레이션 완료 선언';
  raise notice '  프로젝트: %', v_project;
  raise notice '  버전: %', v_current_version;
  raise notice '  총 파일: %개', v_total_migrations;
  raise notice '  목표: %', v_target;
  raise notice '=========================================';
  raise notice '';
  raise notice '[완료된 도메인]';
  raise notice '  0001~0030: Foundation / 공통 / 인프라';
  raise notice '  0031~0050: POS / KDS / 대기 / 결제';
  raise notice '  0051~0073: 재고 / 직원 / 멤버십 / AI지식';
  raise notice '  0074~0087: 배달 / DID / CMS / SaaS / 프랜차이즈';
  raise notice '  0088~0091: AI고객센터 / Digital SOP / 격리 / 체크리스트';
  raise notice '  0092~0096: Flutter / Edge / i18n / pg_cron / 검증';
  raise notice '';
  raise notice '[핵심 특허 구현]';
  raise notice '  특허1: Wait/Order Handoff - order_sessions/orders';
  raise notice '  특허2: KDS Late Binding - kds_tickets HOLD 상태';
  raise notice '  특허3: AI 자가진화 SOP - knowledge/sop_candidates';
  raise notice '  특허4: 감사 원장 - ledger/audit_records';
  raise notice '';
  raise notice '[로드맵]';
  raise notice '  1호점 오픈: 2027년 9월 (울산 김밥집)';
  raise notice '  1-C차 SaaS 출시: 2028년 중~2029년 초';
  raise notice '  4차 Franchise_OS: 1-C차 이후';
  raise notice '=========================================';
  raise notice '  DB 반영은 DBeaver에서 별도 실행';
  raise notice '  git commit 후 DB 적용 분리';
  raise notice '=========================================';
end;
$$;


comment on table catchmenu_common.schema_versions is
  'DB 스키마 버전 관리.
   is_current = true: 현재 적용된 버전.
   validation_result: 검증 결과 상세.
   마이그레이션 파일 완료 선언 기록.';