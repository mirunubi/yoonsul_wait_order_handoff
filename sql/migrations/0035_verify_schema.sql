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

  if exists(
    select 1 from information_schema.schemata
    where schema_name = 'catchmenu_common'
  ) then
    v_pass_count := v_pass_count + 1;
    raise notice '[PASS] %', 'schema catchmenu_common';
  else
    v_error_count := v_error_count + 1;
    raise warning '[FAIL] %', 'schema catchmenu_common';
  end if;
  if exists(
    select 1 from information_schema.schemata
    where schema_name = 'catchmenu_hq'
  ) then
    v_pass_count := v_pass_count + 1;
    raise notice '[PASS] %', 'schema catchmenu_hq';
  else
    v_error_count := v_error_count + 1;
    raise warning '[FAIL] %', 'schema catchmenu_hq';
  end if;
  if exists(
    select 1 from information_schema.schemata
    where schema_name = 'catchmenu_store'
  ) then
    v_pass_count := v_pass_count + 1;
    raise notice '[PASS] %', 'schema catchmenu_store';
  else
    v_error_count := v_error_count + 1;
    raise warning '[FAIL] %', 'schema catchmenu_store';
  end if;
  if exists(
    select 1 from information_schema.schemata
    where schema_name = 'catchmenu_pos'
  ) then
    v_pass_count := v_pass_count + 1;
    raise notice '[PASS] %', 'schema catchmenu_pos';
  else
    v_error_count := v_error_count + 1;
    raise warning '[FAIL] %', 'schema catchmenu_pos';
  end if;
  if exists(
    select 1 from information_schema.schemata
    where schema_name = 'catchmenu_kds'
  ) then
    v_pass_count := v_pass_count + 1;
    raise notice '[PASS] %', 'schema catchmenu_kds';
  else
    v_error_count := v_error_count + 1;
    raise warning '[FAIL] %', 'schema catchmenu_kds';
  end if;
  if exists(
    select 1 from information_schema.schemata
    where schema_name = 'catchmenu_payment'
  ) then
    v_pass_count := v_pass_count + 1;
    raise notice '[PASS] %', 'schema catchmenu_payment';
  else
    v_error_count := v_error_count + 1;
    raise warning '[FAIL] %', 'schema catchmenu_payment';
  end if;
  if exists(
    select 1 from information_schema.schemata
    where schema_name = 'catchmenu_ledger'
  ) then
    v_pass_count := v_pass_count + 1;
    raise notice '[PASS] %', 'schema catchmenu_ledger';
  else
    v_error_count := v_error_count + 1;
    raise warning '[FAIL] %', 'schema catchmenu_ledger';
  end if;
  if exists(
    select 1 from information_schema.schemata
    where schema_name = 'catchmenu_agent'
  ) then
    v_pass_count := v_pass_count + 1;
    raise notice '[PASS] %', 'schema catchmenu_agent';
  else
    v_error_count := v_error_count + 1;
    raise warning '[FAIL] %', 'schema catchmenu_agent';
  end if;
  if exists(
    select 1 from information_schema.schemata
    where schema_name = 'catchmenu_knowledge'
  ) then
    v_pass_count := v_pass_count + 1;
    raise notice '[PASS] %', 'schema catchmenu_knowledge';
  else
    v_error_count := v_error_count + 1;
    raise warning '[FAIL] %', 'schema catchmenu_knowledge';
  end if;
  if exists(
    select 1 from information_schema.schemata
    where schema_name = 'catchmenu_gateway'
  ) then
    v_pass_count := v_pass_count + 1;
    raise notice '[PASS] %', 'schema catchmenu_gateway';
  else
    v_error_count := v_error_count + 1;
    raise warning '[FAIL] %', 'schema catchmenu_gateway';
  end if;
  if exists(
    select 1 from information_schema.schemata
    where schema_name = 'catchmenu_integrations'
  ) then
    v_pass_count := v_pass_count + 1;
    raise notice '[PASS] %', 'schema catchmenu_integrations';
  else
    v_error_count := v_error_count + 1;
    raise warning '[FAIL] %', 'schema catchmenu_integrations';
  end if;
  if exists(
    select 1 from information_schema.schemata
    where schema_name = 'catchmenu_audit'
  ) then
    v_pass_count := v_pass_count + 1;
    raise notice '[PASS] %', 'schema catchmenu_audit';
  else
    v_error_count := v_error_count + 1;
    raise warning '[FAIL] %', 'schema catchmenu_audit';
  end if;

  -- =============================================
  -- 2. Core tables
  -- =============================================
  raise notice '';
  raise notice '--- 2. Core Tables ---';

  if exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_hq'
      and table_name = 'tenants'
  ) then
    v_pass_count := v_pass_count + 1;
    raise notice '[PASS] %', 'table catchmenu_hq.tenants';
  else
    v_error_count := v_error_count + 1;
    raise warning '[FAIL] %', 'table catchmenu_hq.tenants';
  end if;
  if exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_hq'
      and table_name = 'stores'
  ) then
    v_pass_count := v_pass_count + 1;
    raise notice '[PASS] %', 'table catchmenu_hq.stores';
  else
    v_error_count := v_error_count + 1;
    raise warning '[FAIL] %', 'table catchmenu_hq.stores';
  end if;
  if exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_store'
      and table_name = 'device_registry'
  ) then
    v_pass_count := v_pass_count + 1;
    raise notice '[PASS] %', 'table catchmenu_store.device_registry';
  else
    v_error_count := v_error_count + 1;
    raise warning '[FAIL] %', 'table catchmenu_store.device_registry';
  end if;
  if exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_store'
      and table_name = 'agent_registry'
  ) then
    v_pass_count := v_pass_count + 1;
    raise notice '[PASS] %', 'table catchmenu_store.agent_registry';
  else
    v_error_count := v_error_count + 1;
    raise warning '[FAIL] %', 'table catchmenu_store.agent_registry';
  end if;
  if exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_store'
      and table_name = 'dining_tables'
  ) then
    v_pass_count := v_pass_count + 1;
    raise notice '[PASS] %', 'table catchmenu_store.dining_tables';
  else
    v_error_count := v_error_count + 1;
    raise warning '[FAIL] %', 'table catchmenu_store.dining_tables';
  end if;
  if exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_common'
      and table_name = 'idempotency_keys'
  ) then
    v_pass_count := v_pass_count + 1;
    raise notice '[PASS] %', 'table catchmenu_common.idempotency_keys';
  else
    v_error_count := v_error_count + 1;
    raise warning '[FAIL] %', 'table catchmenu_common.idempotency_keys';
  end if;

  -- =============================================
  -- 3. 4-Ledger tables (특허4 core)
  -- =============================================
  raise notice '';
  raise notice '--- 3. 4-Ledger Tables (특허4) ---';

  if exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_ledger'
      and table_name = 'tasks'
  ) then
    v_pass_count := v_pass_count + 1;
    raise notice '[PASS] %', 'table catchmenu_ledger.tasks';
  else
    v_error_count := v_error_count + 1;
    raise warning '[FAIL] %', 'table catchmenu_ledger.tasks';
  end if;
  if exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_ledger'
      and table_name = 'events'
  ) then
    v_pass_count := v_pass_count + 1;
    raise notice '[PASS] %', 'table catchmenu_ledger.events';
  else
    v_error_count := v_error_count + 1;
    raise warning '[FAIL] %', 'table catchmenu_ledger.events';
  end if;
  if exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_ledger'
      and table_name = 'exceptions'
  ) then
    v_pass_count := v_pass_count + 1;
    raise notice '[PASS] %', 'table catchmenu_ledger.exceptions';
  else
    v_error_count := v_error_count + 1;
    raise warning '[FAIL] %', 'table catchmenu_ledger.exceptions';
  end if;
  if exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_ledger'
      and table_name = 'audit_records'
  ) then
    v_pass_count := v_pass_count + 1;
    raise notice '[PASS] %', 'table catchmenu_ledger.audit_records';
  else
    v_error_count := v_error_count + 1;
    raise warning '[FAIL] %', 'table catchmenu_ledger.audit_records';
  end if;
  if exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_ledger'
      and table_name = 'local_temporary_ledger'
  ) then
    v_pass_count := v_pass_count + 1;
    raise notice '[PASS] %', 'table catchmenu_ledger.local_temporary_ledger';
  else
    v_error_count := v_error_count + 1;
    raise warning '[FAIL] %', 'table catchmenu_ledger.local_temporary_ledger';
  end if;

  -- =============================================
  -- 4. Gateway tables (특허1 core)
  -- =============================================
  raise notice '';
  raise notice '--- 4. Gateway Tables (특허1) ---';

  if exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_gateway'
      and table_name = 'provider_raw_events'
  ) then
    v_pass_count := v_pass_count + 1;
    raise notice '[PASS] %', 'table catchmenu_gateway.provider_raw_events';
  else
    v_error_count := v_error_count + 1;
    raise warning '[FAIL] %', 'table catchmenu_gateway.provider_raw_events';
  end if;
  if exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_gateway'
      and table_name = 'gateway_sessions'
  ) then
    v_pass_count := v_pass_count + 1;
    raise notice '[PASS] %', 'table catchmenu_gateway.gateway_sessions';
  else
    v_error_count := v_error_count + 1;
    raise warning '[FAIL] %', 'table catchmenu_gateway.gateway_sessions';
  end if;

  -- =============================================
  -- 5. POS tables (특허1 Handoff)
  -- =============================================
  raise notice '';
  raise notice '--- 5. POS Tables (특허1 Handoff) ---';

  if exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_pos'
      and table_name = 'menu_categories'
  ) then
    v_pass_count := v_pass_count + 1;
    raise notice '[PASS] %', 'table catchmenu_pos.menu_categories';
  else
    v_error_count := v_error_count + 1;
    raise warning '[FAIL] %', 'table catchmenu_pos.menu_categories';
  end if;
  if exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_pos'
      and table_name = 'menus'
  ) then
    v_pass_count := v_pass_count + 1;
    raise notice '[PASS] %', 'table catchmenu_pos.menus';
  else
    v_error_count := v_error_count + 1;
    raise warning '[FAIL] %', 'table catchmenu_pos.menus';
  end if;
  if exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_pos'
      and table_name = 'menu_option_groups'
  ) then
    v_pass_count := v_pass_count + 1;
    raise notice '[PASS] %', 'table catchmenu_pos.menu_option_groups';
  else
    v_error_count := v_error_count + 1;
    raise warning '[FAIL] %', 'table catchmenu_pos.menu_option_groups';
  end if;
  if exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_pos'
      and table_name = 'menu_option_items'
  ) then
    v_pass_count := v_pass_count + 1;
    raise notice '[PASS] %', 'table catchmenu_pos.menu_option_items';
  else
    v_error_count := v_error_count + 1;
    raise warning '[FAIL] %', 'table catchmenu_pos.menu_option_items';
  end if;
  if exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_pos'
      and table_name = 'order_sessions'
  ) then
    v_pass_count := v_pass_count + 1;
    raise notice '[PASS] %', 'table catchmenu_pos.order_sessions';
  else
    v_error_count := v_error_count + 1;
    raise warning '[FAIL] %', 'table catchmenu_pos.order_sessions';
  end if;
  if exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_pos'
      and table_name = 'session_events'
  ) then
    v_pass_count := v_pass_count + 1;
    raise notice '[PASS] %', 'table catchmenu_pos.session_events';
  else
    v_error_count := v_error_count + 1;
    raise warning '[FAIL] %', 'table catchmenu_pos.session_events';
  end if;
  if exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_pos'
      and table_name = 'orders'
  ) then
    v_pass_count := v_pass_count + 1;
    raise notice '[PASS] %', 'table catchmenu_pos.orders';
  else
    v_error_count := v_error_count + 1;
    raise warning '[FAIL] %', 'table catchmenu_pos.orders';
  end if;
  if exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_pos'
      and table_name = 'order_items'
  ) then
    v_pass_count := v_pass_count + 1;
    raise notice '[PASS] %', 'table catchmenu_pos.order_items';
  else
    v_error_count := v_error_count + 1;
    raise warning '[FAIL] %', 'table catchmenu_pos.order_items';
  end if;
  if exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_pos'
      and table_name = 'order_events'
  ) then
    v_pass_count := v_pass_count + 1;
    raise notice '[PASS] %', 'table catchmenu_pos.order_events';
  else
    v_error_count := v_error_count + 1;
    raise warning '[FAIL] %', 'table catchmenu_pos.order_events';
  end if;

  -- =============================================
  -- 6. Payment tables (특허1 금융 대사)
  -- =============================================
  raise notice '';
  raise notice '--- 6. Payment Tables (특허1 금융대사) ---';

  if exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_payment'
      and table_name = 'payment_intents'
  ) then
    v_pass_count := v_pass_count + 1;
    raise notice '[PASS] %', 'table catchmenu_payment.payment_intents';
  else
    v_error_count := v_error_count + 1;
    raise warning '[FAIL] %', 'table catchmenu_payment.payment_intents';
  end if;
  if exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_payment'
      and table_name = 'payment_ledger'
  ) then
    v_pass_count := v_pass_count + 1;
    raise notice '[PASS] %', 'table catchmenu_payment.payment_ledger';
  else
    v_error_count := v_error_count + 1;
    raise warning '[FAIL] %', 'table catchmenu_payment.payment_ledger';
  end if;
  if exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_payment'
      and table_name = 'payment_events'
  ) then
    v_pass_count := v_pass_count + 1;
    raise notice '[PASS] %', 'table catchmenu_payment.payment_events';
  else
    v_error_count := v_error_count + 1;
    raise warning '[FAIL] %', 'table catchmenu_payment.payment_events';
  end if;
  if exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_payment'
      and table_name = 'reconciliation_cases'
  ) then
    v_pass_count := v_pass_count + 1;
    raise notice '[PASS] %', 'table catchmenu_payment.reconciliation_cases';
  else
    v_error_count := v_error_count + 1;
    raise warning '[FAIL] %', 'table catchmenu_payment.reconciliation_cases';
  end if;

  -- =============================================
  -- 7. KDS tables (특허2 Late Binding)
  -- =============================================
  raise notice '';
  raise notice '--- 7. KDS Tables (특허2 Late Binding) ---';

  if exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_kds'
      and table_name = 'kds_tickets'
  ) then
    v_pass_count := v_pass_count + 1;
    raise notice '[PASS] %', 'table catchmenu_kds.kds_tickets';
  else
    v_error_count := v_error_count + 1;
    raise warning '[FAIL] %', 'table catchmenu_kds.kds_tickets';
  end if;
  if exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_kds'
      and table_name = 'kds_events'
  ) then
    v_pass_count := v_pass_count + 1;
    raise notice '[PASS] %', 'table catchmenu_kds.kds_events';
  else
    v_error_count := v_error_count + 1;
    raise warning '[FAIL] %', 'table catchmenu_kds.kds_events';
  end if;

  -- KDS ticket starts in HOLD check
  if (
    select column_default = '''HOLD''::text'
    from information_schema.columns
    where table_schema = 'catchmenu_kds'
      and table_name = 'kds_tickets'
      and column_name = 'kds_status'
  ) then
    v_pass_count := v_pass_count + 1;
    raise notice '[PASS] %', 'kds_tickets default status is HOLD';
  else
    v_error_count := v_error_count + 1;
    raise warning '[FAIL] %', 'kds_tickets default status is HOLD';
  end if;

  -- payment_ledger kds_release_authorized defaults false
  if (
    select column_default = 'false'
    from information_schema.columns
    where table_schema = 'catchmenu_payment'
      and table_name = 'payment_ledger'
      and column_name = 'kds_release_authorized'
  ) then
    v_pass_count := v_pass_count + 1;
    raise notice '[PASS] %', 'payment_ledger kds_release_authorized default false';
  else
    v_error_count := v_error_count + 1;
    raise warning '[FAIL] %', 'payment_ledger kds_release_authorized default false';
  end if;

  -- =============================================
  -- 8. Agent tables (특허4 Human Authority)
  -- =============================================
  raise notice '';
  raise notice '--- 8. Agent Tables (특허4 Human Authority) ---';

  if exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_agent'
      and table_name = 'evidence_packets'
  ) then
    v_pass_count := v_pass_count + 1;
    raise notice '[PASS] %', 'table catchmenu_agent.evidence_packets';
  else
    v_error_count := v_error_count + 1;
    raise warning '[FAIL] %', 'table catchmenu_agent.evidence_packets';
  end if;
  if exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_agent'
      and table_name = 'manual_fallback_log'
  ) then
    v_pass_count := v_pass_count + 1;
    raise notice '[PASS] %', 'table catchmenu_agent.manual_fallback_log';
  else
    v_error_count := v_error_count + 1;
    raise warning '[FAIL] %', 'table catchmenu_agent.manual_fallback_log';
  end if;
  if exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_agent'
      and table_name = 'agent_actions'
  ) then
    v_pass_count := v_pass_count + 1;
    raise notice '[PASS] %', 'table catchmenu_agent.agent_actions';
  else
    v_error_count := v_error_count + 1;
    raise warning '[FAIL] %', 'table catchmenu_agent.agent_actions';
  end if;
  if exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_agent'
      and table_name = 'agent_approvals'
  ) then
    v_pass_count := v_pass_count + 1;
    raise notice '[PASS] %', 'table catchmenu_agent.agent_approvals';
  else
    v_error_count := v_error_count + 1;
    raise warning '[FAIL] %', 'table catchmenu_agent.agent_approvals';
  end if;

  -- agent_registry can_execute defaults false
  if (
    select column_default = 'false'
    from information_schema.columns
    where table_schema = 'catchmenu_store'
      and table_name = 'agent_registry'
      and column_name = 'can_execute'
  ) then
    v_pass_count := v_pass_count + 1;
    raise notice '[PASS] %', 'agent_registry can_execute default false';
  else
    v_error_count := v_error_count + 1;
    raise warning '[FAIL] %', 'agent_registry can_execute default false';
  end if;

  -- =============================================
  -- 9. Knowledge tables (특허3 자가진화)
  -- =============================================
  raise notice '';
  raise notice '--- 9. Knowledge Tables (특허3 자가진화) ---';

  if exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_knowledge'
      and table_name = 'documents'
  ) then
    v_pass_count := v_pass_count + 1;
    raise notice '[PASS] %', 'table catchmenu_knowledge.documents';
  else
    v_error_count := v_error_count + 1;
    raise warning '[FAIL] %', 'table catchmenu_knowledge.documents';
  end if;
  if exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_knowledge'
      and table_name = 'document_versions'
  ) then
    v_pass_count := v_pass_count + 1;
    raise notice '[PASS] %', 'table catchmenu_knowledge.document_versions';
  else
    v_error_count := v_error_count + 1;
    raise warning '[FAIL] %', 'table catchmenu_knowledge.document_versions';
  end if;
  if exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_knowledge'
      and table_name = 'knowledge_gaps'
  ) then
    v_pass_count := v_pass_count + 1;
    raise notice '[PASS] %', 'table catchmenu_knowledge.knowledge_gaps';
  else
    v_error_count := v_error_count + 1;
    raise warning '[FAIL] %', 'table catchmenu_knowledge.knowledge_gaps';
  end if;

  -- is_ai_retrievable defaults false (외부 미노출)
  if (
    select column_default = 'false'
    from information_schema.columns
    where table_schema = 'catchmenu_knowledge'
      and table_name = 'documents'
      and column_name = 'is_ai_retrievable'
  ) then
    v_pass_count := v_pass_count + 1;
    raise notice '[PASS] %', 'knowledge docs is_ai_retrievable default false';
  else
    v_error_count := v_error_count + 1;
    raise warning '[FAIL] %', 'knowledge docs is_ai_retrievable default false';
  end if;

  -- =============================================
  -- 10. Integration tables
  -- =============================================
  raise notice '';
  raise notice '--- 10. Integration Tables ---';

  if exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_integrations'
      and table_name = 'toss_payments'
  ) then
    v_pass_count := v_pass_count + 1;
    raise notice '[PASS] %', 'table catchmenu_integrations.toss_payments';
  else
    v_error_count := v_error_count + 1;
    raise warning '[FAIL] %', 'table catchmenu_integrations.toss_payments';
  end if;
  if exists(
    select 1 from information_schema.tables
    where table_schema = 'catchmenu_integrations'
      and table_name = 'toss_webhooks'
  ) then
    v_pass_count := v_pass_count + 1;
    raise notice '[PASS] %', 'table catchmenu_integrations.toss_webhooks';
  else
    v_error_count := v_error_count + 1;
    raise warning '[FAIL] %', 'table catchmenu_integrations.toss_webhooks';
  end if;

  -- =============================================
  -- 11. RLS enabled check
  -- =============================================
  raise notice '';
  raise notice '--- 11. RLS Enabled ---';

  if (
    select rowsecurity
    from pg_tables
    where schemaname = 'catchmenu_hq'
      and tablename = 'tenants'
  ) then
    v_pass_count := v_pass_count + 1;
    raise notice '[PASS] %', 'RLS enabled catchmenu_hq.tenants';
  else
    v_error_count := v_error_count + 1;
    raise warning '[FAIL] %', 'RLS enabled catchmenu_hq.tenants';
  end if;
  if (
    select rowsecurity
    from pg_tables
    where schemaname = 'catchmenu_payment'
      and tablename = 'payment_ledger'
  ) then
    v_pass_count := v_pass_count + 1;
    raise notice '[PASS] %', 'RLS enabled catchmenu_payment.payment_ledger';
  else
    v_error_count := v_error_count + 1;
    raise warning '[FAIL] %', 'RLS enabled catchmenu_payment.payment_ledger';
  end if;
  if (
    select rowsecurity
    from pg_tables
    where schemaname = 'catchmenu_kds'
      and tablename = 'kds_tickets'
  ) then
    v_pass_count := v_pass_count + 1;
    raise notice '[PASS] %', 'RLS enabled catchmenu_kds.kds_tickets';
  else
    v_error_count := v_error_count + 1;
    raise warning '[FAIL] %', 'RLS enabled catchmenu_kds.kds_tickets';
  end if;
  if (
    select rowsecurity
    from pg_tables
    where schemaname = 'catchmenu_ledger'
      and tablename = 'audit_records'
  ) then
    v_pass_count := v_pass_count + 1;
    raise notice '[PASS] %', 'RLS enabled catchmenu_ledger.audit_records';
  else
    v_error_count := v_error_count + 1;
    raise warning '[FAIL] %', 'RLS enabled catchmenu_ledger.audit_records';
  end if;
  if (
    select rowsecurity
    from pg_tables
    where schemaname = 'catchmenu_gateway'
      and tablename = 'provider_raw_events'
  ) then
    v_pass_count := v_pass_count + 1;
    raise notice '[PASS] %', 'RLS enabled catchmenu_gateway.provider_raw_events';
  else
    v_error_count := v_error_count + 1;
    raise warning '[FAIL] %', 'RLS enabled catchmenu_gateway.provider_raw_events';
  end if;

  -- =============================================
  -- 12. Core functions
  -- =============================================
  raise notice '';
  raise notice '--- 12. Core Functions ---';

  if exists(
    select 1 from information_schema.routines
    where routine_schema = 'catchmenu_common'
      and routine_name = 'set_updated_at'
  ) then
    v_pass_count := v_pass_count + 1;
    raise notice '[PASS] %', 'fn catchmenu_common.set_updated_at';
  else
    v_error_count := v_error_count + 1;
    raise warning '[FAIL] %', 'fn catchmenu_common.set_updated_at';
  end if;
  if exists(
    select 1 from information_schema.routines
    where routine_schema = 'catchmenu_common'
      and routine_name = 'current_tenant_id'
  ) then
    v_pass_count := v_pass_count + 1;
    raise notice '[PASS] %', 'fn catchmenu_common.current_tenant_id';
  else
    v_error_count := v_error_count + 1;
    raise warning '[FAIL] %', 'fn catchmenu_common.current_tenant_id';
  end if;
  if exists(
    select 1 from information_schema.routines
    where routine_schema = 'catchmenu_audit'
      and routine_name = 'append_audit_record'
  ) then
    v_pass_count := v_pass_count + 1;
    raise notice '[PASS] %', 'fn catchmenu_audit.append_audit_record';
  else
    v_error_count := v_error_count + 1;
    raise warning '[FAIL] %', 'fn catchmenu_audit.append_audit_record';
  end if;
  if exists(
    select 1 from information_schema.routines
    where routine_schema = 'catchmenu_common'
      and routine_name = 'get_store_bootstrap'
  ) then
    v_pass_count := v_pass_count + 1;
    raise notice '[PASS] %', 'fn catchmenu_common.get_store_bootstrap';
  else
    v_error_count := v_error_count + 1;
    raise warning '[FAIL] %', 'fn catchmenu_common.get_store_bootstrap';
  end if;
  if exists(
    select 1 from information_schema.routines
    where routine_schema = 'catchmenu_pos'
      and routine_name = 'create_order_session'
  ) then
    v_pass_count := v_pass_count + 1;
    raise notice '[PASS] %', 'fn catchmenu_pos.create_order_session';
  else
    v_error_count := v_error_count + 1;
    raise warning '[FAIL] %', 'fn catchmenu_pos.create_order_session';
  end if;
  if exists(
    select 1 from information_schema.routines
    where routine_schema = 'catchmenu_pos'
      and routine_name = 'bind_table_to_session'
  ) then
    v_pass_count := v_pass_count + 1;
    raise notice '[PASS] %', 'fn catchmenu_pos.bind_table_to_session';
  else
    v_error_count := v_error_count + 1;
    raise warning '[FAIL] %', 'fn catchmenu_pos.bind_table_to_session';
  end if;
  if exists(
    select 1 from information_schema.routines
    where routine_schema = 'catchmenu_pos'
      and routine_name = 'create_order'
  ) then
    v_pass_count := v_pass_count + 1;
    raise notice '[PASS] %', 'fn catchmenu_pos.create_order';
  else
    v_error_count := v_error_count + 1;
    raise warning '[FAIL] %', 'fn catchmenu_pos.create_order';
  end if;
  if exists(
    select 1 from information_schema.routines
    where routine_schema = 'catchmenu_pos'
      and routine_name = 'confirm_order'
  ) then
    v_pass_count := v_pass_count + 1;
    raise notice '[PASS] %', 'fn catchmenu_pos.confirm_order';
  else
    v_error_count := v_error_count + 1;
    raise warning '[FAIL] %', 'fn catchmenu_pos.confirm_order';
  end if;
  if exists(
    select 1 from information_schema.routines
    where routine_schema = 'catchmenu_payment'
      and routine_name = 'create_payment_intent'
  ) then
    v_pass_count := v_pass_count + 1;
    raise notice '[PASS] %', 'fn catchmenu_payment.create_payment_intent';
  else
    v_error_count := v_error_count + 1;
    raise warning '[FAIL] %', 'fn catchmenu_payment.create_payment_intent';
  end if;
  if exists(
    select 1 from information_schema.routines
    where routine_schema = 'catchmenu_payment'
      and routine_name = 'confirm_payment_from_provider'
  ) then
    v_pass_count := v_pass_count + 1;
    raise notice '[PASS] %', 'fn catchmenu_payment.confirm_payment_from_provider';
  else
    v_error_count := v_error_count + 1;
    raise warning '[FAIL] %', 'fn catchmenu_payment.confirm_payment_from_provider';
  end if;
  if exists(
    select 1 from information_schema.routines
    where routine_schema = 'catchmenu_payment'
      and routine_name = 'mark_payment_uncertain'
  ) then
    v_pass_count := v_pass_count + 1;
    raise notice '[PASS] %', 'fn catchmenu_payment.mark_payment_uncertain';
  else
    v_error_count := v_error_count + 1;
    raise warning '[FAIL] %', 'fn catchmenu_payment.mark_payment_uncertain';
  end if;
  if exists(
    select 1 from information_schema.routines
    where routine_schema = 'catchmenu_kds'
      and routine_name = 'commit_kds_ticket'
  ) then
    v_pass_count := v_pass_count + 1;
    raise notice '[PASS] %', 'fn catchmenu_kds.commit_kds_ticket';
  else
    v_error_count := v_error_count + 1;
    raise warning '[FAIL] %', 'fn catchmenu_kds.commit_kds_ticket';
  end if;
  if exists(
    select 1 from information_schema.routines
    where routine_schema = 'catchmenu_kds'
      and routine_name = 'authorize_kds_release'
  ) then
    v_pass_count := v_pass_count + 1;
    raise notice '[PASS] %', 'fn catchmenu_kds.authorize_kds_release';
  else
    v_error_count := v_error_count + 1;
    raise warning '[FAIL] %', 'fn catchmenu_kds.authorize_kds_release';
  end if;
  if exists(
    select 1 from information_schema.routines
    where routine_schema = 'catchmenu_kds'
      and routine_name = 'start_cooking'
  ) then
    v_pass_count := v_pass_count + 1;
    raise notice '[PASS] %', 'fn catchmenu_kds.start_cooking';
  else
    v_error_count := v_error_count + 1;
    raise warning '[FAIL] %', 'fn catchmenu_kds.start_cooking';
  end if;
  if exists(
    select 1 from information_schema.routines
    where routine_schema = 'catchmenu_agent'
      and routine_name = 'activate_manual_fallback'
  ) then
    v_pass_count := v_pass_count + 1;
    raise notice '[PASS] %', 'fn catchmenu_agent.activate_manual_fallback';
  else
    v_error_count := v_error_count + 1;
    raise warning '[FAIL] %', 'fn catchmenu_agent.activate_manual_fallback';
  end if;
  if exists(
    select 1 from information_schema.routines
    where routine_schema = 'catchmenu_knowledge'
      and routine_name = 'detect_knowledge_gap'
  ) then
    v_pass_count := v_pass_count + 1;
    raise notice '[PASS] %', 'fn catchmenu_knowledge.detect_knowledge_gap';
  else
    v_error_count := v_error_count + 1;
    raise warning '[FAIL] %', 'fn catchmenu_knowledge.detect_knowledge_gap';
  end if;
  if exists(
    select 1 from information_schema.routines
    where routine_schema = 'catchmenu_knowledge'
      and routine_name = 'publish_knowledge_document'
  ) then
    v_pass_count := v_pass_count + 1;
    raise notice '[PASS] %', 'fn catchmenu_knowledge.publish_knowledge_document';
  else
    v_error_count := v_error_count + 1;
    raise warning '[FAIL] %', 'fn catchmenu_knowledge.publish_knowledge_document';
  end if;

  -- =============================================
  -- 13. Seed data verification
  -- =============================================
  raise notice '';
  raise notice '--- 13. Seed Data ---';

  if exists(
    select 1 from catchmenu_hq.tenants
    where tenant_code = 'YOONSUL_TEST'
  ) then
    v_pass_count := v_pass_count + 1;
    raise notice '[PASS] %', 'seed tenant YOONSUL_TEST exists';
  else
    v_error_count := v_error_count + 1;
    raise warning '[FAIL] %', 'seed tenant YOONSUL_TEST exists';
  end if;
  if exists(
    select 1 from catchmenu_hq.stores
    where store_code = 'ULSAN_01'
  ) then
    v_pass_count := v_pass_count + 1;
    raise notice '[PASS] %', 'seed store ULSAN_01 exists';
  else
    v_error_count := v_error_count + 1;
    raise warning '[FAIL] %', 'seed store ULSAN_01 exists';
  end if;
  if (
    select count(*) = 6
    from catchmenu_store.dining_tables
    where store_id = '00000000-0000-0000-0000-000000000002'
  ) then
    v_pass_count := v_pass_count + 1;
    raise notice '[PASS] %', 'seed dining tables count = 6';
  else
    v_error_count := v_error_count + 1;
    raise warning '[FAIL] %', 'seed dining tables count = 6';
  end if;
  if (
    select count(*) = 9
    from catchmenu_pos.menus
    where store_id = '00000000-0000-0000-0000-000000000002'
  ) then
    v_pass_count := v_pass_count + 1;
    raise notice '[PASS] %', 'seed menus count = 9';
  else
    v_error_count := v_error_count + 1;
    raise warning '[FAIL] %', 'seed menus count = 9';
  end if;
  if (
    select count(*) = 4
    from catchmenu_store.device_registry
    where store_id = '00000000-0000-0000-0000-000000000002'
  ) then
    v_pass_count := v_pass_count + 1;
    raise notice '[PASS] %', 'seed devices count = 4';
  else
    v_error_count := v_error_count + 1;
    raise warning '[FAIL] %', 'seed devices count = 4';
  end if;
  if (
    select count(*) = 5
    from catchmenu_store.agent_registry
    where store_id = '00000000-0000-0000-0000-000000000002'
  ) then
    v_pass_count := v_pass_count + 1;
    raise notice '[PASS] %', 'seed agents count = 5';
  else
    v_error_count := v_error_count + 1;
    raise warning '[FAIL] %', 'seed agents count = 5';
  end if;

  -- =============================================
  -- 14. Architecture invariants
  -- =============================================
  raise notice '';
  raise notice '--- 14. Architecture Invariants ---';

  -- all dining tables start AVAILABLE
  if (
    select count(*) = 6
    from catchmenu_store.dining_tables
    where store_id = '00000000-0000-0000-0000-000000000002'
      and table_status = 'AVAILABLE'
  ) then
    v_pass_count := v_pass_count + 1;
    raise notice '[PASS] %', 'all seed tables AVAILABLE';
  else
    v_error_count := v_error_count + 1;
    raise warning '[FAIL] %', 'all seed tables AVAILABLE';
  end if;

  -- no KDS release authorized by default
  if (
    select count(*) = 0
    from catchmenu_payment.payment_ledger
    where store_id = '00000000-0000-0000-0000-000000000002'
      and kds_release_authorized = true
  ) then
    v_pass_count := v_pass_count + 1;
    raise notice '[PASS] %', 'no kds_release_authorized in payment_ledger';
  else
    v_error_count := v_error_count + 1;
    raise warning '[FAIL] %', 'no kds_release_authorized in payment_ledger';
  end if;

  -- no published knowledge docs (clean start)
  if (
    select count(*) = 0
    from catchmenu_knowledge.documents
    where tenant_id = '00000000-0000-0000-0000-000000000001'
      and document_status = 'PUBLISHED'
  ) then
    v_pass_count := v_pass_count + 1;
    raise notice '[PASS] %', 'no published knowledge docs';
  else
    v_error_count := v_error_count + 1;
    raise warning '[FAIL] %', 'no published knowledge docs';
  end if;

  -- all agents can_execute = false except RECOVERY
  if (
    select count(*) = 0
    from catchmenu_store.agent_registry
    where store_id = '00000000-0000-0000-0000-000000000002'
      and agent_type <> 'RECOVERY'
      and can_execute = true
  ) then
    v_pass_count := v_pass_count + 1;
    raise notice '[PASS] %', 'non-recovery agents cannot execute';
  else
    v_error_count := v_error_count + 1;
    raise warning '[FAIL] %', 'non-recovery agents cannot execute';
  end if;

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
