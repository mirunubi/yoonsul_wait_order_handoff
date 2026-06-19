-- 0035_verify_schema.sql
-- Purpose: Full schema verification after 0001~0034 migration.
--          Checks tables, functions, RLS, indexes, and seed data.
--          Run after all migrations to confirm schema integrity.
-- Depends on: 0034_seed_data.sql
-- Creates: (none) — verification only

do $$
declare
  v_error_count int := 0;
  v_pass_count int := 0;
  v_check text;

  procedure assert_true(
    p_label text,
    p_condition boolean
  ) as
  $inner$
  begin
    if p_condition then
      v_pass_count := v_pass_count + 1;
      raise notice '[PASS] %', p_label;
    else
      v_error_count := v_error_count + 1;
      raise warning '[FAIL] %', p_label;
    end if;
  end;
  $inner$;

begin
  raise notice '';
  raise notice '==============================================';
  raise notice '  catchmenu schema verification 0001~0034';
  raise notice '==============================================';
  raise notice '';

  -- =============================================
  -- 1. Schema existence
  -- =============================================
  raise notice '--- 1. Schemas ---';

  call assert_true('schema catchmenu_common', exists(
    select 1 from information_schema.schemata
    where schema_name = 'catchmenu_common'
  ));
  call assert_true('schema catchmenu_hq', exists(
    select 1 from information_schema.schemata
    where schema_name = 'catchmenu_hq'
  ));
  call assert_true('schema catchmenu_store', exists(
    select 1 from information_schema.schemata
    where schema_name = 'catchmenu_store'
  ));
  call assert_true('schema catchmenu_pos', exists(
    select 1 from information_schema.schemata
    where schema_name = 'catchmenu_pos'
  ));
  call assert_true('schema catchmenu_kds', exists(
    select 1 from information_schema.schemata
    where schema_name = 'catchmenu_kds'
  ));
  call assert_true('schema catchmenu_payment', exists(
    select 1 from information_schema.schemata
    where schema_name = 'catchmenu_payment'
  ));
  call assert_true('schema catchmenu_ledger', exists(
    select 1 from information_schema.schemata
    where schema_name = 'catchmenu_ledger'
  ));
  call assert_true('schema catchmenu_agent', exists(
    select 1 from information_schema.schemata
    where schema_name = 'catchmenu_agent'
  ));
  call assert_true('schema catchmenu_knowledge', exists(
    select 1 from information_schema.schemata
    where schema_name = 'catchmenu_knowledge'
  ));
  call assert_true('schema catchmenu_gateway', exists(
    select 1 from information_schema.schemata
    where schema_name = 'catchmenu_gateway'
  ));
  call assert_true('schema catchmenu_integrations', exists(
    select 1 from information_schema.schemata
    where schema_name = 'catchmenu_integrations'
  ));
  call assert_true('schema catchmenu_audit', exists(
    select 1 from information_schema.schemata
    where schema_name = 'catchmenu_audit'
  ));

  -- =============================================
  -- 2. Core tables
  -- =============================================
  raise notice '';
  raise notice '--- 2. Core Tables ---';

  call assert_true('table catchmenu_hq.tenants', exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_hq'
      and table_name = 'tenants'
  ));
  call assert_true('table catchmenu_hq.stores', exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_hq'
      and table_name = 'stores'
  ));
  call assert_true('table catchmenu_store.device_registry', exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_store'
      and table_name = 'device_registry'
  ));
  call assert_true('table catchmenu_store.agent_registry', exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_store'
      and table_name = 'agent_registry'
  ));
  call assert_true('table catchmenu_store.dining_tables', exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_store'
      and table_name = 'dining_tables'
  ));
  call assert_true('table catchmenu_common.idempotency_keys', exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_common'
      and table_name = 'idempotency_keys'
  ));

  -- =============================================
  -- 3. 4-Ledger tables (특허4 core)
  -- =============================================
  raise notice '';
  raise notice '--- 3. 4-Ledger Tables (특허4) ---';

  call assert_true('table catchmenu_ledger.tasks', exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_ledger'
      and table_name = 'tasks'
  ));
  call assert_true('table catchmenu_ledger.events', exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_ledger'
      and table_name = 'events'
  ));
  call assert_true('table catchmenu_ledger.exceptions', exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_ledger'
      and table_name = 'exceptions'
  ));
  call assert_true('table catchmenu_ledger.audit_records', exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_ledger'
      and table_name = 'audit_records'
  ));
  call assert_true('table catchmenu_ledger.local_temporary_ledger', exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_ledger'
      and table_name = 'local_temporary_ledger'
  ));

  -- =============================================
  -- 4. Gateway tables (특허1 core)
  -- =============================================
  raise notice '';
  raise notice '--- 4. Gateway Tables (특허1) ---';

  call assert_true('table catchmenu_gateway.provider_raw_events', exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_gateway'
      and table_name = 'provider_raw_events'
  ));
  call assert_true('table catchmenu_gateway.gateway_sessions', exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_gateway'
      and table_name = 'gateway_sessions'
  ));

  -- =============================================
  -- 5. POS tables (특허1 Handoff)
  -- =============================================
  raise notice '';
  raise notice '--- 5. POS Tables (특허1 Handoff) ---';

  call assert_true('table catchmenu_pos.menu_categories', exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_pos'
      and table_name = 'menu_categories'
  ));
  call assert_true('table catchmenu_pos.menus', exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_pos'
      and table_name = 'menus'
  ));
  call assert_true('table catchmenu_pos.menu_option_groups', exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_pos'
      and table_name = 'menu_option_groups'
  ));
  call assert_true('table catchmenu_pos.menu_option_items', exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_pos'
      and table_name = 'menu_option_items'
  ));
  call assert_true('table catchmenu_pos.order_sessions', exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_pos'
      and table_name = 'order_sessions'
  ));
  call assert_true('table catchmenu_pos.session_events', exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_pos'
      and table_name = 'session_events'
  ));
  call assert_true('table catchmenu_pos.orders', exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_pos'
      and table_name = 'orders'
  ));
  call assert_true('table catchmenu_pos.order_items', exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_pos'
      and table_name = 'order_items'
  ));
  call assert_true('table catchmenu_pos.order_events', exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_pos'
      and table_name = 'order_events'
  ));

  -- =============================================
  -- 6. Payment tables (특허1 금융 대사)
  -- =============================================
  raise notice '';
  raise notice '--- 6. Payment Tables (특허1 금융대사) ---';

  call assert_true('table catchmenu_payment.payment_intents', exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_payment'
      and table_name = 'payment_intents'
  ));
  call assert_true('table catchmenu_payment.payment_ledger', exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_payment'
      and table_name = 'payment_ledger'
  ));
  call assert_true('table catchmenu_payment.payment_events', exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_payment'
      and table_name = 'payment_events'
  ));
  call assert_true('table catchmenu_payment.reconciliation_cases', exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_payment'
      and table_name = 'reconciliation_cases'
  ));

  -- =============================================
  -- 7. KDS tables (특허2 Late Binding)
  -- =============================================
  raise notice '';
  raise notice '--- 7. KDS Tables (특허2 Late Binding) ---';

  call assert_true('table catchmenu_kds.kds_tickets', exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_kds'
      and table_name = 'kds_tickets'
  ));
  call assert_true('table catchmenu_kds.kds_events', exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_kds'
      and table_name = 'kds_events'
  ));

  -- KDS ticket starts in HOLD check
  call assert_true('kds_tickets default status is HOLD', (
    select column_default = '''HOLD''::text'
    from information_schema.columns
    where table_schema = 'catchmenu_kds'
      and table_name = 'kds_tickets'
      and column_name = 'kds_status'
  ));

  -- payment_ledger kds_release_authorized defaults false
  call assert_true('payment_ledger kds_release_authorized default false', (
    select column_default = 'false'
    from information_schema.columns
    where table_schema = 'catchmenu_payment'
      and table_name = 'payment_ledger'
      and column_name = 'kds_release_authorized'
  ));

  -- =============================================
  -- 8. Agent tables (특허4 Human Authority)
  -- =============================================
  raise notice '';
  raise notice '--- 8. Agent Tables (특허4 Human Authority) ---';

  call assert_true('table catchmenu_agent.evidence_packets', exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_agent'
      and table_name = 'evidence_packets'
  ));
  call assert_true('table catchmenu_agent.manual_fallback_log', exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_agent'
      and table_name = 'manual_fallback_log'
  ));
  call assert_true('table catchmenu_agent.agent_actions', exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_agent'
      and table_name = 'agent_actions'
  ));
  call assert_true('table catchmenu_agent.agent_approvals', exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_agent'
      and table_name = 'agent_approvals'
  ));

  -- agent_registry can_execute defaults false
  call assert_true('agent_registry can_execute default false', (
    select column_default = 'false'
    from information_schema.columns
    where table_schema = 'catchmenu_store'
      and table_name = 'agent_registry'
      and column_name = 'can_execute'
  ));

  -- =============================================
  -- 9. Knowledge tables (특허3 자가진화)
  -- =============================================
  raise notice '';
  raise notice '--- 9. Knowledge Tables (특허3 자가진화) ---';

  call assert_true('table catchmenu_knowledge.documents', exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_knowledge'
      and table_name = 'documents'
  ));
  call assert_true('table catchmenu_knowledge.document_versions', exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_knowledge'
      and table_name = 'document_versions'
  ));
  call assert_true('table catchmenu_knowledge.knowledge_gaps', exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_knowledge'
      and table_name = 'knowledge_gaps'
  ));

  -- is_ai_retrievable defaults false (외부 미노출)
  call assert_true('knowledge docs is_ai_retrievable default false', (
    select column_default = 'false'
    from information_schema.columns
    where table_schema = 'catchmenu_knowledge'
      and table_name = 'documents'
      and column_name = 'is_ai_retrievable'
  ));

  -- =============================================
  -- 10. Integration tables
  -- =============================================
  raise notice '';
  raise notice '--- 10. Integration Tables ---';

  call assert_true('table catchmenu_integrations.toss_payments', exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_integrations'
      and table_name = 'toss_payments'
  ));
  call assert_true('table catchmenu_integrations.toss_webhooks', exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_integrations'
      and table_name = 'toss_webhooks'
  ));

  -- =============================================
  -- 11. RLS enabled check
  -- =============================================
  raise notice '';
  raise notice '--- 11. RLS Enabled ---';

  call assert_true('RLS enabled catchmenu_hq.tenants', (
    select rowsecurity
    from pg_tables
    where schemaname = 'catchmenu_hq'
      and tablename = 'tenants'
  ));
  call assert_true('RLS enabled catchmenu_payment.payment_ledger', (
    select rowsecurity
    from pg_tables
    where schemaname = 'catchmenu_payment'
      and tablename = 'payment_ledger'
  ));
  call assert_true('RLS enabled catchmenu_kds.kds_tickets', (
    select rowsecurity
    from pg_tables
    where schemaname = 'catchmenu_kds'
      and tablename = 'kds_tickets'
  ));
  call assert_true('RLS enabled catchmenu_ledger.audit_records', (
    select rowsecurity
    from pg_tables
    where schemaname = 'catchmenu_ledger'
      and tablename = 'audit_records'
  ));
  call assert_true('RLS enabled catchmenu_gateway.provider_raw_events', (
    select rowsecurity
    from pg_tables
    where schemaname = 'catchmenu_gateway'
      and tablename = 'provider_raw_events'
  ));

  -- =============================================
  -- 12. Core functions
  -- =============================================
  raise notice '';
  raise notice '--- 12. Core Functions ---';

  call assert_true('fn catchmenu_common.set_updated_at', exists(
    select 1 from information_schema.routines
    where routine_schema = 'catchmenu_common'
      and routine_name = 'set_updated_at'
  ));
  call assert_true('fn catchmenu_common.current_tenant_id', exists(
    select 1 from information_schema.routines
    where routine_schema = 'catchmenu_common'
      and routine_name = 'current_tenant_id'
  ));
  call assert_true('fn catchmenu_audit.append_audit_record', exists(
    select 1 from information_schema.routines
    where routine_schema = 'catchmenu_audit'
      and routine_name = 'append_audit_record'
  ));
  call assert_true('fn catchmenu_common.get_store_bootstrap', exists(
    select 1 from information_schema.routines
    where routine_schema = 'catchmenu_common'
      and routine_name = 'get_store_bootstrap'
  ));
  call assert_true('fn catchmenu_pos.create_order_session', exists(
    select 1 from information_schema.routines
    where routine_schema = 'catchmenu_pos'
      and routine_name = 'create_order_session'
  ));
  call assert_true('fn catchmenu_pos.bind_table_to_session', exists(
    select 1 from information_schema.routines
    where routine_schema = 'catchmenu_pos'
      and routine_name = 'bind_table_to_session'
  ));
  call assert_true('fn catchmenu_pos.create_order', exists(
    select 1 from information_schema.routines
    where routine_schema = 'catchmenu_pos'
      and routine_name = 'create_order'
  ));
  call assert_true('fn catchmenu_pos.confirm_order', exists(
    select 1 from information_schema.routines
    where routine_schema = 'catchmenu_pos'
      and routine_name = 'confirm_order'
  ));
  call assert_true('fn catchmenu_payment.create_payment_intent', exists(
    select 1 from information_schema.routines
    where routine_schema = 'catchmenu_payment'
      and routine_name = 'create_payment_intent'
  ));
  call assert_true('fn catchmenu_payment.confirm_payment_from_provider', exists(
    select 1 from information_schema.routines
    where routine_schema = 'catchmenu_payment'
      and routine_name = 'confirm_payment_from_provider'
  ));
  call assert_true('fn catchmenu_payment.mark_payment_uncertain', exists(
    select 1 from information_schema.routines
    where routine_schema = 'catchmenu_payment'
      and routine_name = 'mark_payment_uncertain'
  ));
  call assert_true('fn catchmenu_kds.commit_kds_ticket', exists(
    select 1 from information_schema.routines
    where routine_schema = 'catchmenu_kds'
      and routine_name = 'commit_kds_ticket'
  ));
  call assert_true('fn catchmenu_kds.authorize_kds_release', exists(
    select 1 from information_schema.routines
    where routine_schema = 'catchmenu_kds'
      and routine_name = 'authorize_kds_release'
  ));
  call assert_true('fn catchmenu_kds.start_cooking', exists(
    select 1 from information_schema.routines
    where routine_schema = 'catchmenu_kds'
      and routine_name = 'start_cooking'
  ));
  call assert_true('fn catchmenu_agent.activate_manual_fallback', exists(
    select 1 from information_schema.routines
    where routine_schema = 'catchmenu_agent'
      and routine_name = 'activate_manual_fallback'
  ));
  call assert_true('fn catchmenu_knowledge.detect_knowledge_gap', exists(
    select 1 from information_schema.routines
    where routine_schema = 'catchmenu_knowledge'
      and routine_name = 'detect_knowledge_gap'
  ));
  call assert_true('fn catchmenu_knowledge.publish_knowledge_document', exists(
    select 1 from information_schema.routines
    where routine_schema = 'catchmenu_knowledge'
      and routine_name = 'publish_knowledge_document'
  ));

  -- =============================================
  -- 13. Seed data verification
  -- =============================================
  raise notice '';
  raise notice '--- 13. Seed Data ---';

  call assert_true('seed tenant YOONSUL_TEST exists', exists(
    select 1 from catchmenu_hq.tenants
    where tenant_code = 'YOONSUL_TEST'
  ));
  call assert_true('seed store ULSAN_01 exists', exists(
    select 1 from catchmenu_hq.stores
    where store_code = 'ULSAN_01'
  ));
  call assert_true('seed dining tables count = 6', (
    select count(*) = 6
    from catchmenu_store.dining_tables
    where store_id = '00000000-0000-0000-0000-000000000002'
  ));
  call assert_true('seed menus count = 9', (
    select count(*) = 9
    from catchmenu_pos.menus
    where store_id = '00000000-0000-0000-0000-000000000002'
  ));
  call assert_true('seed devices count = 4', (
    select count(*) = 4
    from catchmenu_store.device_registry
    where store_id = '00000000-0000-0000-0000-000000000002'
  ));
  call assert_true('seed agents count = 5', (
    select count(*) = 5
    from catchmenu_store.agent_registry
    where store_id = '00000000-0000-0000-0000-000000000002'
  ));

  -- =============================================
  -- 14. Architecture invariants
  -- =============================================
  raise notice '';
  raise notice '--- 14. Architecture Invariants ---';

  -- all dining tables start AVAILABLE
  call assert_true('all seed tables AVAILABLE', (
    select count(*) = 6
    from catchmenu_store.dining_tables
    where store_id = '00000000-0000-0000-0000-000000000002'
      and table_status = 'AVAILABLE'
  ));

  -- no KDS release authorized by default
  call assert_true('no kds_release_authorized in payment_ledger', (
    select count(*) = 0
    from catchmenu_payment.payment_ledger
    where store_id = '00000000-0000-0000-0000-000000000002'
      and kds_release_authorized = true
  ));

  -- no published knowledge docs (clean start)
  call assert_true('no published knowledge docs', (
    select count(*) = 0
    from catchmenu_knowledge.documents
    where tenant_id = '00000000-0000-0000-0000-000000000001'
      and document_status = 'PUBLISHED'
  ));

  -- all agents can_execute = false except RECOVERY
  call assert_true('non-recovery agents cannot execute', (
    select count(*) = 0
    from catchmenu_store.agent_registry
    where store_id = '00000000-0000-0000-0000-000000000002'
      and agent_type <> 'RECOVERY'
      and can_execute = true
  ));

  -- =============================================
  -- Final report
  -- =============================================
  raise notice '';
  raise notice '==============================================';
  raise notice '  VERIFICATION COMPLETE';
  raise notice '  PASS: %   FAIL: %   TOTAL: %',
    v_pass_count, v_error_count,
    v_pass_count + v_error_count;
  raise notice '==============================================';

  if v_error_count > 0 then
    raise exception
      'SCHEMA_VERIFICATION_FAILED: % checks failed. Review warnings above.',
      v_error_count;
  else
    raise notice '  ALL CHECKS PASSED. Schema is ready.';
    raise notice '==============================================';
  end if;
end;
$$;