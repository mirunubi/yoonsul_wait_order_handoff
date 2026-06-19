-- 0022_create_rls_policies.sql
-- Purpose: JWT helper functions and tenant/store-scoped RLS policies.
--          All access is scoped by tenant_id and store_id from JWT claims.
--          Ledger tables (audit, events) are insert-only for clients.
--          Gateway and payment tables are service-role only.
-- Depends on: 0021_enable_rls.sql
-- Creates:
--   catchmenu_common.current_tenant_id()
--   catchmenu_common.current_store_id()
--   catchmenu_common.current_actor_id()
--   catchmenu_common.current_actor_type()
--   catchmenu_common.is_service_role()
--   RLS policies on all tables

-- =============================================
-- JWT helper functions
-- =============================================

create or replace function catchmenu_common.current_tenant_id()
returns uuid
language sql
stable
security definer
set search_path = pg_catalog
as $$
  select nullif(
    current_setting('request.jwt.claims', true)::jsonb
      -> 'app_metadata'
      ->> 'tenant_id',
    ''
  )::uuid;
$$;

create or replace function catchmenu_common.current_store_id()
returns uuid
language sql
stable
security definer
set search_path = pg_catalog
as $$
  select nullif(
    current_setting('request.jwt.claims', true)::jsonb
      -> 'app_metadata'
      ->> 'store_id',
    ''
  )::uuid;
$$;

create or replace function catchmenu_common.current_actor_id()
returns uuid
language sql
stable
security definer
set search_path = pg_catalog
as $$
  select nullif(
    current_setting('request.jwt.claims', true)::jsonb
      ->> 'sub',
    ''
  )::uuid;
$$;

create or replace function catchmenu_common.current_actor_type()
returns text
language sql
stable
security definer
set search_path = pg_catalog
as $$
  select nullif(
    current_setting('request.jwt.claims', true)::jsonb
      -> 'app_metadata'
      ->> 'actor_type',
    ''
  );
$$;

create or replace function catchmenu_common.is_service_role()
returns boolean
language sql
stable
security definer
set search_path = pg_catalog
as $$
  select coalesce(
    current_setting('request.jwt.claims', true)::jsonb
      ->> 'role',
    ''
  ) = 'service_role';
$$;

create or replace function catchmenu_common.is_manager_or_above()
returns boolean
language sql
stable
security definer
set search_path = pg_catalog
as $$
  select coalesce(
    current_setting('request.jwt.claims', true)::jsonb
      -> 'app_metadata'
      ->> 'actor_type',
    ''
  ) in ('MANAGER', 'OWNER', 'HQ_ADMIN');
$$;

comment on function catchmenu_common.current_tenant_id() is
  'Extracts tenant_id from JWT app_metadata claims.
   Used as foundation for all tenant-scoped RLS policies.';
comment on function catchmenu_common.current_store_id() is
  'Extracts store_id from JWT app_metadata claims.
   Used for store-scoped RLS policies on operational tables.';
comment on function catchmenu_common.is_service_role() is
  'True when request is from service_role key.
   Service role bypasses RLS for internal server operations.
   Never expose service_role key to client applications.';
comment on function catchmenu_common.is_manager_or_above() is
  'True when actor_type is MANAGER, OWNER, or HQ_ADMIN.
   Used for elevated access policies on sensitive tables.';

-- =============================================
-- catchmenu_hq policies
-- =============================================

drop policy if exists tenants_select_own
  on catchmenu_hq.tenants;
create policy tenants_select_own
  on catchmenu_hq.tenants
  for select to authenticated
  using (id = catchmenu_common.current_tenant_id());

drop policy if exists stores_select_own
  on catchmenu_hq.stores;
create policy stores_select_own
  on catchmenu_hq.stores
  for select to authenticated
  using (tenant_id = catchmenu_common.current_tenant_id());

-- =============================================
-- catchmenu_store policies
-- =============================================

drop policy if exists device_registry_store_isolation
  on catchmenu_store.device_registry;
create policy device_registry_store_isolation
  on catchmenu_store.device_registry
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id = catchmenu_common.current_store_id()
  );

drop policy if exists agent_registry_store_isolation
  on catchmenu_store.agent_registry;
create policy agent_registry_store_isolation
  on catchmenu_store.agent_registry
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id = catchmenu_common.current_store_id()
  );

drop policy if exists dining_tables_store_isolation
  on catchmenu_store.dining_tables;
create policy dining_tables_store_isolation
  on catchmenu_store.dining_tables
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id = catchmenu_common.current_store_id()
  );

-- =============================================
-- catchmenu_common policies
-- =============================================

drop policy if exists idempotency_keys_store_isolation
  on catchmenu_common.idempotency_keys;
create policy idempotency_keys_store_isolation
  on catchmenu_common.idempotency_keys
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
  );

-- =============================================
-- catchmenu_ledger policies
-- =============================================

-- tasks: store-scoped read + insert
-- no client UPDATE or DELETE on ledger tables
drop policy if exists tasks_store_select
  on catchmenu_ledger.tasks;
create policy tasks_store_select
  on catchmenu_ledger.tasks
  for select to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id = catchmenu_common.current_store_id()
  );

drop policy if exists tasks_store_insert
  on catchmenu_ledger.tasks;
create policy tasks_store_insert
  on catchmenu_ledger.tasks
  for insert to authenticated
  with check (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id = catchmenu_common.current_store_id()
  );

-- events: store-scoped read + insert only
drop policy if exists events_store_select
  on catchmenu_ledger.events;
create policy events_store_select
  on catchmenu_ledger.events
  for select to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id = catchmenu_common.current_store_id()
  );

drop policy if exists events_store_insert
  on catchmenu_ledger.events;
create policy events_store_insert
  on catchmenu_ledger.events
  for insert to authenticated
  with check (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id = catchmenu_common.current_store_id()
  );

-- exceptions: store-scoped all
drop policy if exists exceptions_store_isolation
  on catchmenu_ledger.exceptions;
create policy exceptions_store_isolation
  on catchmenu_ledger.exceptions
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id = catchmenu_common.current_store_id()
  );

-- audit_records: insert only for authenticated
-- select only for manager or above
drop policy if exists audit_records_insert
  on catchmenu_ledger.audit_records;
create policy audit_records_insert
  on catchmenu_ledger.audit_records
  for insert to authenticated
  with check (
    tenant_id = catchmenu_common.current_tenant_id()
  );

drop policy if exists audit_records_select_manager
  on catchmenu_ledger.audit_records;
create policy audit_records_select_manager
  on catchmenu_ledger.audit_records
  for select to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id = catchmenu_common.current_store_id()
    and catchmenu_common.is_manager_or_above()
  );

-- local_temporary_ledger: device-scoped
drop policy if exists local_ledger_device_isolation
  on catchmenu_ledger.local_temporary_ledger;
create policy local_ledger_device_isolation
  on catchmenu_ledger.local_temporary_ledger
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id = catchmenu_common.current_store_id()
  );

-- =============================================
-- catchmenu_gateway policies
-- service_role only — never expose to clients
-- =============================================

drop policy if exists provider_raw_events_service_only
  on catchmenu_gateway.provider_raw_events;
create policy provider_raw_events_service_only
  on catchmenu_gateway.provider_raw_events
  for all to authenticated
  using (catchmenu_common.is_service_role());

drop policy if exists gateway_sessions_service_only
  on catchmenu_gateway.gateway_sessions;
create policy gateway_sessions_service_only
  on catchmenu_gateway.gateway_sessions
  for all to authenticated
  using (catchmenu_common.is_service_role());

-- =============================================
-- catchmenu_pos policies
-- =============================================

drop policy if exists menu_categories_store_isolation
  on catchmenu_pos.menu_categories;
create policy menu_categories_store_isolation
  on catchmenu_pos.menu_categories
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id = catchmenu_common.current_store_id()
  );

drop policy if exists menus_store_isolation
  on catchmenu_pos.menus;
create policy menus_store_isolation
  on catchmenu_pos.menus
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id = catchmenu_common.current_store_id()
  );

drop policy if exists menu_option_groups_store_isolation
  on catchmenu_pos.menu_option_groups;
create policy menu_option_groups_store_isolation
  on catchmenu_pos.menu_option_groups
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id = catchmenu_common.current_store_id()
  );

drop policy if exists menu_option_items_store_isolation
  on catchmenu_pos.menu_option_items;
create policy menu_option_items_store_isolation
  on catchmenu_pos.menu_option_items
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id = catchmenu_common.current_store_id()
  );

drop policy if exists order_sessions_store_isolation
  on catchmenu_pos.order_sessions;
create policy order_sessions_store_isolation
  on catchmenu_pos.order_sessions
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id = catchmenu_common.current_store_id()
  );

drop policy if exists session_events_store_isolation
  on catchmenu_pos.session_events;
create policy session_events_store_isolation
  on catchmenu_pos.session_events
  for select to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id = catchmenu_common.current_store_id()
  );

drop policy if exists session_events_insert
  on catchmenu_pos.session_events;
create policy session_events_insert
  on catchmenu_pos.session_events
  for insert to authenticated
  with check (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id = catchmenu_common.current_store_id()
  );

drop policy if exists orders_store_isolation
  on catchmenu_pos.orders;
create policy orders_store_isolation
  on catchmenu_pos.orders
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id = catchmenu_common.current_store_id()
  );

drop policy if exists order_items_store_isolation
  on catchmenu_pos.order_items;
create policy order_items_store_isolation
  on catchmenu_pos.order_items
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id = catchmenu_common.current_store_id()
  );

drop policy if exists order_events_store_select
  on catchmenu_pos.order_events;
create policy order_events_store_select
  on catchmenu_pos.order_events
  for select to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id = catchmenu_common.current_store_id()
  );

drop policy if exists order_events_insert
  on catchmenu_pos.order_events;
create policy order_events_insert
  on catchmenu_pos.order_events
  for insert to authenticated
  with check (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id = catchmenu_common.current_store_id()
  );

-- =============================================
-- catchmenu_payment policies
-- payment_ledger: select manager only, insert service only
-- =============================================

drop policy if exists payment_intents_store_isolation
  on catchmenu_payment.payment_intents;
create policy payment_intents_store_isolation
  on catchmenu_payment.payment_intents
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id = catchmenu_common.current_store_id()
  );

-- payment_ledger: highly restricted
-- clients can only select their own store records
-- insert/update only via service_role (RPC)
drop policy if exists payment_ledger_select
  on catchmenu_payment.payment_ledger;
create policy payment_ledger_select
  on catchmenu_payment.payment_ledger
  for select to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id = catchmenu_common.current_store_id()
  );

drop policy if exists payment_events_store_select
  on catchmenu_payment.payment_events;
create policy payment_events_store_select
  on catchmenu_payment.payment_events
  for select to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id = catchmenu_common.current_store_id()
  );

drop policy if exists payment_events_insert
  on catchmenu_payment.payment_events;
create policy payment_events_insert
  on catchmenu_payment.payment_events
  for insert to authenticated
  with check (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id = catchmenu_common.current_store_id()
  );

-- reconciliation: manager only
drop policy if exists reconciliation_select_manager
  on catchmenu_payment.reconciliation_cases;
create policy reconciliation_select_manager
  on catchmenu_payment.reconciliation_cases
  for select to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id = catchmenu_common.current_store_id()
    and catchmenu_common.is_manager_or_above()
  );

-- =============================================
-- catchmenu_kds policies
-- =============================================

drop policy if exists kds_tickets_store_isolation
  on catchmenu_kds.kds_tickets;
create policy kds_tickets_store_isolation
  on catchmenu_kds.kds_tickets
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id = catchmenu_common.current_store_id()
  );

drop policy if exists kds_events_store_select
  on catchmenu_kds.kds_events;
create policy kds_events_store_select
  on catchmenu_kds.kds_events
  for select to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id = catchmenu_common.current_store_id()
  );

drop policy if exists kds_events_insert
  on catchmenu_kds.kds_events;
create policy kds_events_insert
  on catchmenu_kds.kds_events
  for insert to authenticated
  with check (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id = catchmenu_common.current_store_id()
  );

-- =============================================
-- catchmenu_agent policies
-- =============================================

drop policy if exists evidence_packets_store_isolation
  on catchmenu_agent.evidence_packets;
create policy evidence_packets_store_isolation
  on catchmenu_agent.evidence_packets
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id = catchmenu_common.current_store_id()
  );

drop policy if exists fallback_log_store_isolation
  on catchmenu_agent.manual_fallback_log;
create policy fallback_log_store_isolation
  on catchmenu_agent.manual_fallback_log
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id = catchmenu_common.current_store_id()
  );

drop policy if exists agent_actions_store_isolation
  on catchmenu_agent.agent_actions;
create policy agent_actions_store_isolation
  on catchmenu_agent.agent_actions
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id = catchmenu_common.current_store_id()
  );

drop policy if exists agent_approvals_store_isolation
  on catchmenu_agent.agent_approvals;
create policy agent_approvals_store_isolation
  on catchmenu_agent.agent_approvals
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id = catchmenu_common.current_store_id()
  );

-- =============================================
-- catchmenu_knowledge policies
-- =============================================

drop policy if exists knowledge_docs_tenant_isolation
  on catchmenu_knowledge.documents;
create policy knowledge_docs_tenant_isolation
  on catchmenu_knowledge.documents
  for select to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and document_status = 'PUBLISHED'
  );

drop policy if exists knowledge_docs_manager_all
  on catchmenu_knowledge.documents;
create policy knowledge_docs_manager_all
  on catchmenu_knowledge.documents
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and catchmenu_common.is_manager_or_above()
  );

drop policy if exists doc_versions_tenant_isolation
  on catchmenu_knowledge.document_versions;
create policy doc_versions_tenant_isolation
  on catchmenu_knowledge.document_versions
  for select to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and catchmenu_common.is_manager_or_above()
  );

drop policy if exists knowledge_gaps_store_isolation
  on catchmenu_knowledge.knowledge_gaps;
create policy knowledge_gaps_store_isolation
  on catchmenu_knowledge.knowledge_gaps
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
  );

-- =============================================
-- catchmenu_integrations policies
-- toss_payments: select store, insert/update service only
-- =============================================

drop policy if exists toss_payments_store_select
  on catchmenu_integrations.toss_payments;
create policy toss_payments_store_select
  on catchmenu_integrations.toss_payments
  for select to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id = catchmenu_common.current_store_id()
  );

drop policy if exists toss_webhooks_service_only
  on catchmenu_integrations.toss_webhooks;
create policy toss_webhooks_service_only
  on catchmenu_integrations.toss_webhooks
  for all to authenticated
  using (catchmenu_common.is_service_role());

-- schema usage grants
grant usage on schema catchmenu_common to authenticated;
grant usage on schema catchmenu_hq to authenticated;
grant usage on schema catchmenu_store to authenticated;
grant usage on schema catchmenu_pos to authenticated;
grant usage on schema catchmenu_kds to authenticated;
grant usage on schema catchmenu_payment to authenticated;
grant usage on schema catchmenu_ledger to authenticated;
grant usage on schema catchmenu_agent to authenticated;
grant usage on schema catchmenu_knowledge to authenticated;
grant usage on schema catchmenu_integrations to authenticated;

-- deny gateway and audit schemas to direct client access
revoke usage on schema catchmenu_gateway from authenticated;
revoke usage on schema catchmenu_audit from authenticated;

comment on function catchmenu_common.current_tenant_id() is
  'Extracts tenant_id from JWT app_metadata.
   Foundation of all tenant-scoped RLS policies.
   JWT must include app_metadata.tenant_id set by auth hook.';