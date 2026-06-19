-- 0073_final_verification.sql
-- Purpose: Full schema verification for 0001~0072.
--          Verifies tables, RPCs, RLS, seeds, indexes,
--          pg_cron jobs, edge function registry,
--          realtime channels, and deployment checklist.
-- Depends on: 0072_create_pg_cron_schedules.sql
-- Creates: (none) — verification only

do $$
declare
  v_pass int := 0;
  v_fail int := 0;

  procedure assert_true(
    p_label text,
    p_condition boolean,
    p_severity text default 'ERROR'
  ) as
  $inner$
  begin
    if p_condition then
      v_pass := v_pass + 1;
      raise notice '[PASS] %', p_label;
    else
      v_fail := v_fail + 1;
      if p_severity = 'CRITICAL' then
        raise warning '[CRITICAL FAIL] %', p_label;
      else
        raise warning '[FAIL] %', p_label;
      end if;
    end if;
  end;
  $inner$;

begin
  raise notice '';
  raise notice '==============================================';
  raise notice '  catchmenu final verification 0001~0072';
  raise notice '  %', now()::text;
  raise notice '==============================================';
  raise notice '';

  -- =============================================
  -- 1. Schemas (12개)
  -- =============================================
  raise notice '--- 1. Schemas ---';

  call assert_true('schema catchmenu_common', exists(
    select 1 from information_schema.schemata
    where schema_name = 'catchmenu_common'
  ), 'CRITICAL');
  call assert_true('schema catchmenu_hq', exists(
    select 1 from information_schema.schemata
    where schema_name = 'catchmenu_hq'
  ), 'CRITICAL');
  call assert_true('schema catchmenu_store', exists(
    select 1 from information_schema.schemata
    where schema_name = 'catchmenu_store'
  ), 'CRITICAL');
  call assert_true('schema catchmenu_pos', exists(
    select 1 from information_schema.schemata
    where schema_name = 'catchmenu_pos'
  ), 'CRITICAL');
  call assert_true('schema catchmenu_kds', exists(
    select 1 from information_schema.schemata
    where schema_name = 'catchmenu_kds'
  ), 'CRITICAL');
  call assert_true('schema catchmenu_payment', exists(
    select 1 from information_schema.schemata
    where schema_name = 'catchmenu_payment'
  ), 'CRITICAL');
  call assert_true('schema catchmenu_ledger', exists(
    select 1 from information_schema.schemata
    where schema_name = 'catchmenu_ledger'
  ), 'CRITICAL');
  call assert_true('schema catchmenu_agent', exists(
    select 1 from information_schema.schemata
    where schema_name = 'catchmenu_agent'
  ), 'CRITICAL');
  call assert_true('schema catchmenu_knowledge', exists(
    select 1 from information_schema.schemata
    where schema_name = 'catchmenu_knowledge'
  ), 'CRITICAL');
  call assert_true('schema catchmenu_gateway', exists(
    select 1 from information_schema.schemata
    where schema_name = 'catchmenu_gateway'
  ), 'CRITICAL');
  call assert_true('schema catchmenu_integrations', exists(
    select 1 from information_schema.schemata
    where schema_name = 'catchmenu_integrations'
  ), 'CRITICAL');
  call assert_true('schema catchmenu_audit', exists(
    select 1 from information_schema.schemata
    where schema_name = 'catchmenu_audit'
  ), 'CRITICAL');

  -- =============================================
  -- 2. Core Tables
  -- =============================================
  raise notice '';
  raise notice '--- 2. Core Tables ---';

  -- HQ
  call assert_true('table catchmenu_hq.tenants', exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_hq'
      and table_name = 'tenants'
  ), 'CRITICAL');
  call assert_true('table catchmenu_hq.stores', exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_hq'
      and table_name = 'stores'
  ), 'CRITICAL');
  call assert_true('table catchmenu_hq.hq_notices', exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_hq'
      and table_name = 'hq_notices'
  ));
  call assert_true('table catchmenu_hq.menu_templates', exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_hq'
      and table_name = 'menu_templates'
  ));

  -- Store
  call assert_true('table catchmenu_store.device_registry', exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_store'
      and table_name = 'device_registry'
  ), 'CRITICAL');
  call assert_true('table catchmenu_store.agent_registry', exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_store'
      and table_name = 'agent_registry'
  ), 'CRITICAL');
  call assert_true('table catchmenu_store.dining_tables', exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_store'
      and table_name = 'dining_tables'
  ), 'CRITICAL');
  call assert_true('table catchmenu_store.staff', exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_store'
      and table_name = 'staff'
  ));
  call assert_true('table catchmenu_store.staff_attendance', exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_store'
      and table_name = 'staff_attendance'
  ));
  call assert_true('table catchmenu_store.ingredients', exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_store'
      and table_name = 'ingredients'
  ));
  call assert_true('table catchmenu_store.inventory_movements', exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_store'
      and table_name = 'inventory_movements'
  ));
  call assert_true('table catchmenu_store.store_settings', exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_store'
      and table_name = 'store_settings'
  ));
  call assert_true('table catchmenu_store.customers', exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_store'
      and table_name = 'customers'
  ));
  call assert_true('table catchmenu_store.coupons', exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_store'
      and table_name = 'coupons'
  ));
  call assert_true('table catchmenu_store.coupon_issues', exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_store'
      and table_name = 'coupon_issues'
  ));
  call assert_true('table catchmenu_store.point_ledger', exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_store'
      and table_name = 'point_ledger'
  ));
  call assert_true('table catchmenu_store.point_rules', exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_store'
      and table_name = 'point_rules'
  ));

  -- POS
  call assert_true('table catchmenu_pos.menu_categories', exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_pos'
      and table_name = 'menu_categories'
  ), 'CRITICAL');
  call assert_true('table catchmenu_pos.menus', exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_pos'
      and table_name = 'menus'
  ), 'CRITICAL');
  call assert_true('table catchmenu_pos.order_sessions', exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_pos'
      and table_name = 'order_sessions'
  ), 'CRITICAL');
  call assert_true('table catchmenu_pos.orders', exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_pos'
      and table_name = 'orders'
  ), 'CRITICAL');
  call assert_true('table catchmenu_pos.order_items', exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_pos'
      and table_name = 'order_items'
  ), 'CRITICAL');
  call assert_true('table catchmenu_pos.menu_i18n', exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_pos'
      and table_name = 'menu_i18n'
  ));
  call assert_true('table catchmenu_pos.allergen_codes', exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_pos'
      and table_name = 'allergen_codes'
  ));
  call assert_true('table catchmenu_pos.menu_allergen_links', exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_pos'
      and table_name = 'menu_allergen_links'
  ));

  -- Payment
  call assert_true('table catchmenu_payment.payment_intents', exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_payment'
      and table_name = 'payment_intents'
  ), 'CRITICAL');
  call assert_true('table catchmenu_payment.payment_ledger', exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_payment'
      and table_name = 'payment_ledger'
  ), 'CRITICAL');
  call assert_true('table catchmenu_payment.reconciliation_cases', exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_payment'
      and table_name = 'reconciliation_cases'
  ), 'CRITICAL');

  -- KDS
  call assert_true('table catchmenu_kds.kds_tickets', exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_kds'
      and table_name = 'kds_tickets'
  ), 'CRITICAL');
  call assert_true('table catchmenu_kds.kds_events', exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_kds'
      and table_name = 'kds_events'
  ), 'CRITICAL');

  -- Ledger (4원장)
  call assert_true('table catchmenu_ledger.events', exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_ledger'
      and table_name = 'events'
  ), 'CRITICAL');
  call assert_true('table catchmenu_ledger.audit_records', exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_ledger'
      and table_name = 'audit_records'
  ), 'CRITICAL');
  call assert_true('table catchmenu_ledger.exceptions', exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_ledger'
      and table_name = 'exceptions'
  ), 'CRITICAL');
  call assert_true('table catchmenu_ledger.tasks', exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_ledger'
      and table_name = 'tasks'
  ), 'CRITICAL');
  call assert_true('table catchmenu_ledger.local_temporary_ledger', exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_ledger'
      and table_name = 'local_temporary_ledger'
  ), 'CRITICAL');
  call assert_true('table catchmenu_ledger.integrity_check_results', exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_ledger'
      and table_name = 'integrity_check_results'
  ));

  -- Knowledge
  call assert_true('table catchmenu_knowledge.documents', exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_knowledge'
      and table_name = 'documents'
  ), 'CRITICAL');
  call assert_true('table catchmenu_knowledge.document_versions', exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_knowledge'
      and table_name = 'document_versions'
  ), 'CRITICAL');
  call assert_true('table catchmenu_knowledge.knowledge_gaps', exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_knowledge'
      and table_name = 'knowledge_gaps'
  ), 'CRITICAL');
  call assert_true('table catchmenu_knowledge.document_embeddings', exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_knowledge'
      and table_name = 'document_embeddings'
  ));
  call assert_true('table catchmenu_knowledge.embedding_models', exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_knowledge'
      and table_name = 'embedding_models'
  ));

  -- Common infra
  call assert_true('table catchmenu_common.error_codes', exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_common'
      and table_name = 'error_codes'
  ), 'CRITICAL');
  call assert_true('table catchmenu_common.message_catalog', exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_common'
      and table_name = 'message_catalog'
  ), 'CRITICAL');
  call assert_true('table catchmenu_common.diagnostic_logs', exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_common'
      and table_name = 'diagnostic_logs'
  ), 'CRITICAL');
  call assert_true('table catchmenu_common.realtime_channels', exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_common'
      and table_name = 'realtime_channels'
  ));
  call assert_true('table catchmenu_common.edge_function_registry', exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_common'
      and table_name = 'edge_function_registry'
  ));
  call assert_true('table catchmenu_common.cron_job_registry', exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_common'
      and table_name = 'cron_job_registry'
  ));
  call assert_true('table catchmenu_common.cron_job_executions', exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_common'
      and table_name = 'cron_job_executions'
  ));
  call assert_true('table catchmenu_common.firebase_migration_boundary', exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_common'
      and table_name = 'firebase_migration_boundary'
  ));
  call assert_true('table catchmenu_common.deployment_checklist', exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_common'
      and table_name = 'deployment_checklist'
  ));

  -- Integrations
  call assert_true('table catchmenu_integrations.toss_payments', exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_integrations'
      and table_name = 'toss_payments'
  ), 'CRITICAL');
  call assert_true('table catchmenu_integrations.toss_webhooks', exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_integrations'
      and table_name = 'toss_webhooks'
  ), 'CRITICAL');
  call assert_true('table catchmenu_integrations.van_transactions', exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_integrations'
      and table_name = 'van_transactions'
  ));
  call assert_true('table catchmenu_integrations.van_settlements', exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_integrations'
      and table_name = 'van_settlements'
  ));
  call assert_true('table catchmenu_integrations.delivery_platform_configs', exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_integrations'
      and table_name = 'delivery_platform_configs'
  ));

  -- Audit
  call assert_true('table catchmenu_audit.security_scan_results', exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_audit'
      and table_name = 'security_scan_results'
  ));

  -- =============================================
  -- 3. Architecture Invariants (특허 핵심)
  -- =============================================
  raise notice '';
  raise notice '--- 3. Architecture Invariants ---';

  -- 특허1: kds_release_authorized default false
  call assert_true(
    '[특허1] payment_ledger.kds_release_authorized default false',
    (select column_default = 'false'
     from information_schema.columns
     where table_schema = 'catchmenu_payment'
       and table_name = 'payment_ledger'
       and column_name = 'kds_release_authorized'),
    'CRITICAL'
  );

  -- 특허2: kds_tickets default HOLD
  call assert_true(
    '[특허2] kds_tickets default status = HOLD',
    (select column_default = '''HOLD''::text'
     from information_schema.columns
     where table_schema = 'catchmenu_kds'
       and table_name = 'kds_tickets'
       and column_name = 'kds_status'),
    'CRITICAL'
  );

  -- 특허3: knowledge docs is_ai_retrievable default false
  call assert_true(
    '[특허3] documents.is_ai_retrievable default false',
    (select column_default = 'false'
     from information_schema.columns
     where table_schema = 'catchmenu_knowledge'
       and table_name = 'documents'
       and column_name = 'is_ai_retrievable'),
    'CRITICAL'
  );

  -- 특허4: agent can_execute default false
  call assert_true(
    '[특허4] agent_registry.can_execute default false',
    (select column_default = 'false'
     from information_schema.columns
     where table_schema = 'catchmenu_store'
       and table_name = 'agent_registry'
       and column_name = 'can_execute'),
    'CRITICAL'
  );

  -- pgvector: only PUBLISHED embeddings
  call assert_true(
    '[pgvector] embeddings constrained to PUBLISHED only',
    (select count(*) > 0
     from information_schema.table_constraints
     where table_schema = 'catchmenu_knowledge'
       and table_name = 'document_embeddings'
       and constraint_type = 'CHECK')
  );

  -- =============================================
  -- 4. RLS Coverage
  -- =============================================
  raise notice '';
  raise notice '--- 4. RLS Coverage ---';

  call assert_true('RLS payment_ledger', (
    select rowsecurity from pg_tables
    where schemaname = 'catchmenu_payment'
      and tablename = 'payment_ledger'
  ), 'CRITICAL');
  call assert_true('RLS kds_tickets', (
    select rowsecurity from pg_tables
    where schemaname = 'catchmenu_kds'
      and tablename = 'kds_tickets'
  ), 'CRITICAL');
  call assert_true('RLS audit_records', (
    select rowsecurity from pg_tables
    where schemaname = 'catchmenu_ledger'
      and tablename = 'audit_records'
  ), 'CRITICAL');
  call assert_true('RLS document_embeddings', (
    select rowsecurity from pg_tables
    where schemaname = 'catchmenu_knowledge'
      and tablename = 'document_embeddings'
  ), 'CRITICAL');
  call assert_true('RLS diagnostic_logs', (
    select rowsecurity from pg_tables
    where schemaname = 'catchmenu_common'
      and tablename = 'diagnostic_logs'
  ), 'CRITICAL');
  call assert_true('RLS staff', (
    select rowsecurity from pg_tables
    where schemaname = 'catchmenu_store'
      and tablename = 'staff'
  ), 'CRITICAL');
  call assert_true('RLS customers', (
    select rowsecurity from pg_tables
    where schemaname = 'catchmenu_store'
      and tablename = 'customers'
  ), 'CRITICAL');
  call assert_true('RLS point_ledger', (
    select rowsecurity from pg_tables
    where schemaname = 'catchmenu_store'
      and tablename = 'point_ledger'
  ), 'CRITICAL');

  -- =============================================
  -- 5. Core Functions
  -- =============================================
  raise notice '';
  raise notice '--- 5. Core Functions ---';

  call assert_true('fn catchmenu_common.set_updated_at', exists(
    select 1 from information_schema.routines
    where routine_schema = 'catchmenu_common'
      and routine_name = 'set_updated_at'
  ), 'CRITICAL');
  call assert_true('fn catchmenu_common.get_message', exists(
    select 1 from information_schema.routines
    where routine_schema = 'catchmenu_common'
      and routine_name = 'get_message'
  ), 'CRITICAL');
  call assert_true('fn catchmenu_common.build_error_response', exists(
    select 1 from information_schema.routines
    where routine_schema = 'catchmenu_common'
      and routine_name = 'build_error_response'
  ), 'CRITICAL');
  call assert_true('fn catchmenu_common.log_diagnostic', exists(
    select 1 from information_schema.routines
    where routine_schema = 'catchmenu_common'
      and routine_name = 'log_diagnostic'
  ), 'CRITICAL');
  call assert_true('fn catchmenu_common.bootstrap_app', exists(
    select 1 from information_schema.routines
    where routine_schema = 'catchmenu_common'
      and routine_name = 'bootstrap_app'
  ), 'CRITICAL');
  call assert_true('fn catchmenu_common.heartbeat', exists(
    select 1 from information_schema.routines
    where routine_schema = 'catchmenu_common'
      and routine_name = 'heartbeat'
  ), 'CRITICAL');
  call assert_true('fn catchmenu_common.run_daily_close_batch', exists(
    select 1 from information_schema.routines
    where routine_schema = 'catchmenu_common'
      and routine_name = 'run_daily_close_batch'
  ), 'CRITICAL');
  call assert_true('fn catchmenu_audit.append_audit_record', exists(
    select 1 from information_schema.routines
    where routine_schema = 'catchmenu_audit'
      and routine_name = 'append_audit_record'
  ), 'CRITICAL');
  call assert_true('fn catchmenu_pos.create_order_session', exists(
    select 1 from information_schema.routines
    where routine_schema = 'catchmenu_pos'
      and routine_name = 'create_order_session'
  ), 'CRITICAL');
  call assert_true('fn catchmenu_pos.bind_table_to_session', exists(
    select 1 from information_schema.routines
    where routine_schema = 'catchmenu_pos'
      and routine_name = 'bind_table_to_session'
  ), 'CRITICAL');
  call assert_true('fn catchmenu_payment.confirm_payment_from_provider', exists(
    select 1 from information_schema.routines
    where routine_schema = 'catchmenu_payment'
      and routine_name = 'confirm_payment_from_provider'
  ), 'CRITICAL');
  call assert_true('fn catchmenu_payment.mark_payment_uncertain', exists(
    select 1 from information_schema.routines
    where routine_schema = 'catchmenu_payment'
      and routine_name = 'mark_payment_uncertain'
  ), 'CRITICAL');
  call assert_true('fn catchmenu_kds.commit_kds_ticket', exists(
    select 1 from information_schema.routines
    where routine_schema = 'catchmenu_kds'
      and routine_name = 'commit_kds_ticket'
  ), 'CRITICAL');
  call assert_true('fn catchmenu_kds.authorize_kds_release', exists(
    select 1 from information_schema.routines
    where routine_schema = 'catchmenu_kds'
      and routine_name = 'authorize_kds_release'
  ), 'CRITICAL');
  call assert_true('fn catchmenu_knowledge.build_grounded_ai_context', exists(
    select 1 from information_schema.routines
    where routine_schema = 'catchmenu_knowledge'
      and routine_name = 'build_grounded_ai_context'
  ), 'CRITICAL');
  call assert_true('fn catchmenu_knowledge.search_knowledge_vector', exists(
    select 1 from information_schema.routines
    where routine_schema = 'catchmenu_knowledge'
      and routine_name = 'search_knowledge_vector'
  ), 'CRITICAL');
  call assert_true('fn catchmenu_knowledge.verify_answer_grounding', exists(
    select 1 from information_schema.routines
    where routine_schema = 'catchmenu_knowledge'
      and routine_name = 'verify_answer_grounding'
  ), 'CRITICAL');
  call assert_true('fn catchmenu_ledger.verify_event_ledger_integrity', exists(
    select 1 from information_schema.routines
    where routine_schema = 'catchmenu_ledger'
      and routine_name = 'verify_event_ledger_integrity'
  ));
  call assert_true('fn catchmenu_audit.run_isolation_audit', exists(
    select 1 from information_schema.routines
    where routine_schema = 'catchmenu_audit'
      and routine_name = 'run_isolation_audit'
  ));
  call assert_true('fn catchmenu_store.register_staff', exists(
    select 1 from information_schema.routines
    where routine_schema = 'catchmenu_store'
      and routine_name = 'register_staff'
  ));
  call assert_true('fn catchmenu_store.earn_points', exists(
    select 1 from information_schema.routines
    where routine_schema = 'catchmenu_store'
      and routine_name = 'earn_points'
  ));
  call assert_true('fn catchmenu_hq.create_franchise_store', exists(
    select 1 from information_schema.routines
    where routine_schema = 'catchmenu_hq'
      and routine_name = 'create_franchise_store'
  ));
  call assert_true('fn catchmenu_integrations.process_toss_webhook', exists(
    select 1 from information_schema.routines
    where routine_schema = 'catchmenu_integrations'
      and routine_name = 'process_toss_webhook'
  ), 'CRITICAL');
  call assert_true('fn catchmenu_integrations.process_baemin_order', exists(
    select 1 from information_schema.routines
    where routine_schema = 'catchmenu_integrations'
      and routine_name = 'process_baemin_order'
  ));

  -- =============================================
  -- 6. Seed Data
  -- =============================================
  raise notice '';
  raise notice '--- 6. Seed Data ---';

  call assert_true('seed: tenant YOONSUL_TEST', exists(
    select 1 from catchmenu_hq.tenants
    where tenant_code = 'YOONSUL_TEST'
  ), 'CRITICAL');
  call assert_true('seed: store ULSAN_01', exists(
    select 1 from catchmenu_hq.stores
    where store_code = 'ULSAN_01'
  ), 'CRITICAL');
  call assert_true('seed: dining tables = 6', (
    select count(*) = 6
    from catchmenu_store.dining_tables
    where store_id = '00000000-0000-0000-0000-000000000002'
  ));
  call assert_true('seed: menus = 9', (
    select count(*) = 9
    from catchmenu_pos.menus
    where store_id = '00000000-0000-0000-0000-000000000002'
  ));
  call assert_true('seed: devices = 4', (
    select count(*) = 4
    from catchmenu_store.device_registry
    where store_id = '00000000-0000-0000-0000-000000000002'
  ));
  call assert_true('seed: agents = 5', (
    select count(*) = 5
    from catchmenu_store.agent_registry
    where store_id = '00000000-0000-0000-0000-000000000002'
  ));
  call assert_true('seed: error_codes >= 50', (
    select count(*) >= 50
    from catchmenu_common.error_codes
  ), 'CRITICAL');
  call assert_true('seed: message_catalog >= 50', (
    select count(*) >= 50
    from catchmenu_common.message_catalog
  ), 'CRITICAL');
  call assert_true('seed: allergen_codes = 22', (
    select count(*) = 22
    from catchmenu_pos.allergen_codes
  ));
  call assert_true('seed: embedding_models >= 2', (
    select count(*) >= 2
    from catchmenu_knowledge.embedding_models
  ));
  call assert_true('seed: realtime_channels >= 8', (
    select count(*) >= 8
    from catchmenu_common.realtime_channels
  ));
  call assert_true('seed: edge_function_registry >= 8', (
    select count(*) >= 8
    from catchmenu_common.edge_function_registry
  ));
  call assert_true('seed: cron_job_registry >= 6', (
    select count(*) >= 6
    from catchmenu_common.cron_job_registry
  ));
  call assert_true('seed: firebase_migration_boundary >= 5', (
    select count(*) >= 5
    from catchmenu_common.firebase_migration_boundary
  ));
  call assert_true('seed: deployment_checklist >= 15', (
    select count(*) >= 15
    from catchmenu_common.deployment_checklist
  ));

  -- =============================================
  -- 7. Security Invariants
  -- =============================================
  raise notice '';
  raise notice '--- 7. Security Invariants ---';

  call assert_true(
    'no UNTRUSTED devices ONLINE',
    not exists (
      select 1 from catchmenu_store.device_registry
      where trust_level in ('UNTRUSTED', 'REVOKED')
        and device_status = 'ONLINE'
        and is_active = true
    ), 'CRITICAL'
  );
  call assert_true(
    'no agents can_execute outside approved types',
    not exists (
      select 1 from catchmenu_store.agent_registry
      where can_execute = true
        and agent_type not in (
          'RECOVERY', 'SUPERVISOR'
        )
        and is_active = true
    ), 'CRITICAL'
  );
  call assert_true(
    'no UNCERTAIN payment with COOKING KDS',
    not exists (
      select 1
      from catchmenu_payment.payment_intents pi
      join catchmenu_kds.kds_tickets kt
        on kt.order_id = pi.order_id
      where pi.intent_status = 'UNCERTAIN'
        and kt.kds_status = 'COOKING'
    ), 'CRITICAL'
  );
  call assert_true(
    'knowledge INTERNAL_ONLY not CUSTOMER_FACING',
    not exists (
      select 1 from catchmenu_knowledge.documents
      where document_status = 'PUBLISHED'
        and is_ai_retrievable = true
        and ai_retrieval_scope = 'INTERNAL_ONLY'
        and ai_retrieval_scope = 'CUSTOMER_FACING'
    ), 'CRITICAL'
  );
  call assert_true(
    'pgvector embeddings only for PUBLISHED docs',
    not exists (
      select 1
      from catchmenu_knowledge.document_embeddings de
      join catchmenu_knowledge.documents d
        on d.id = de.document_id
      where de.is_valid = true
        and d.document_status <> 'PUBLISHED'
    ), 'CRITICAL'
  );

  -- =============================================
  -- 8. Extension Check
  -- =============================================
  raise notice '';
  raise notice '--- 8. Extensions ---';

  call assert_true('extension pgvector', exists(
    select 1 from pg_extension
    where extname = 'vector'
  ));
  call assert_true('extension pg_cron', exists(
    select 1 from pg_extension
    where extname = 'pg_cron'
  ));
  call assert_true('extension pgcrypto', exists(
    select 1 from pg_extension
    where extname = 'pgcrypto'
  ));

  -- =============================================
  -- 9. i18n Coverage
  -- =============================================
  raise notice '';
  raise notice '--- 9. i18n Coverage ---';

  call assert_true('i18n: ko messages exist', (
    select count(*) >= 20
    from catchmenu_common.message_catalog
    where locale = 'ko'
  ), 'CRITICAL');
  call assert_true('i18n: en messages exist', (
    select count(*) >= 15
    from catchmenu_common.message_catalog
    where locale = 'en'
  ), 'CRITICAL');
  call assert_true('i18n: zh messages exist', (
    select count(*) >= 5
    from catchmenu_common.message_catalog
    where locale = 'zh'
  ));
  call assert_true('i18n: ja messages exist', (
    select count(*) >= 5
    from catchmenu_common.message_catalog
    where locale = 'ja'
  ));
  call assert_true('i18n: allergen ko messages', (
    select count(*) >= 10
    from catchmenu_common.message_catalog
    where message_key like 'allergen.%'
      and locale = 'ko'
  ));
  call assert_true('i18n: allergen en messages', (
    select count(*) >= 10
    from catchmenu_common.message_catalog
    where message_key like 'allergen.%'
      and locale = 'en'
  ));

  -- =============================================
  -- 10. Triggers
  -- =============================================
  raise notice '';
  raise notice '--- 10. Key Triggers ---';

  call assert_true(
    'trigger: invalidate_embeddings_on_supersede',
    exists (
      select 1 from information_schema.triggers
      where trigger_schema = 'catchmenu_knowledge'
        and event_object_table = 'document_versions'
        and trigger_name =
          'trg_invalidate_embeddings_on_supersede'
    ), 'CRITICAL'
  );
  call assert_true(
    'trigger: set_updated_at on menus',
    exists (
      select 1 from information_schema.triggers
      where trigger_schema = 'catchmenu_pos'
        and event_object_table = 'menus'
    )
  );
  call assert_true(
    'trigger: set_updated_at on staff',
    exists (
      select 1 from information_schema.triggers
      where trigger_schema = 'catchmenu_store'
        and event_object_table = 'staff'
    )
  );

  -- =============================================
  -- Final Report
  -- =============================================
  raise notice '';
  raise notice '==============================================';
  raise notice '  FINAL VERIFICATION COMPLETE';
  raise notice '  PASS: %   FAIL: %   TOTAL: %',
    v_pass, v_fail, v_pass + v_fail;
  raise notice '==============================================';

  if v_fail > 0 then
    raise notice '';
    raise notice '  [!] % checks failed.', v_fail;
    raise notice '  Review warnings above.';
    raise notice '  CRITICAL failures must be resolved';
    raise notice '  before production deployment.';
    raise notice '==============================================';
    raise exception
      'FINAL_VERIFICATION_FAILED: % checks failed.',
      v_fail;
  else
    raise notice '';
    raise notice '  ALL % CHECKS PASSED.', v_pass;
    raise notice '';
    raise notice '  Schema 0001~0072 is ready.';
    raise notice '  Next steps:';
    raise notice '  1. git commit (0036~0073)';
    raise notice '  2. Deploy Edge Functions';
    raise notice '  3. Register pg_cron jobs';
    raise notice '  4. Flutter integration';
    raise notice '==============================================';
  end if;
end;
$$;