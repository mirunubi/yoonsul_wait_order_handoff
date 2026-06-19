-- 0021_enable_rls.sql
-- Purpose: Enable deny-by-default RLS on all catchmenu operational tables.
--          No table is readable or writable without explicit policy.
--          All access goes through RLS policies or SECURITY DEFINER RPCs.
-- Depends on: 0001~0020
-- Creates: (none)
-- Changes: ENABLE ROW LEVEL SECURITY + FORCE ROW LEVEL SECURITY

-- catchmenu_hq
alter table catchmenu_hq.tenants
  enable row level security;
alter table catchmenu_hq.tenants
  force row level security;

alter table catchmenu_hq.stores
  enable row level security;
alter table catchmenu_hq.stores
  force row level security;

-- catchmenu_store
alter table catchmenu_store.device_registry
  enable row level security;
alter table catchmenu_store.device_registry
  force row level security;

alter table catchmenu_store.agent_registry
  enable row level security;
alter table catchmenu_store.agent_registry
  force row level security;

alter table catchmenu_store.dining_tables
  enable row level security;
alter table catchmenu_store.dining_tables
  force row level security;

-- catchmenu_common
alter table catchmenu_common.idempotency_keys
  enable row level security;
alter table catchmenu_common.idempotency_keys
  force row level security;

-- catchmenu_ledger
alter table catchmenu_ledger.tasks
  enable row level security;
alter table catchmenu_ledger.tasks
  force row level security;

alter table catchmenu_ledger.events
  enable row level security;
alter table catchmenu_ledger.events
  force row level security;

alter table catchmenu_ledger.exceptions
  enable row level security;
alter table catchmenu_ledger.exceptions
  force row level security;

alter table catchmenu_ledger.audit_records
  enable row level security;
alter table catchmenu_ledger.audit_records
  force row level security;

alter table catchmenu_ledger.local_temporary_ledger
  enable row level security;
alter table catchmenu_ledger.local_temporary_ledger
  force row level security;

-- catchmenu_gateway
alter table catchmenu_gateway.provider_raw_events
  enable row level security;
alter table catchmenu_gateway.provider_raw_events
  force row level security;

alter table catchmenu_gateway.gateway_sessions
  enable row level security;
alter table catchmenu_gateway.gateway_sessions
  force row level security;

-- catchmenu_pos
alter table catchmenu_pos.menu_categories
  enable row level security;
alter table catchmenu_pos.menu_categories
  force row level security;

alter table catchmenu_pos.menus
  enable row level security;
alter table catchmenu_pos.menus
  force row level security;

alter table catchmenu_pos.menu_option_groups
  enable row level security;
alter table catchmenu_pos.menu_option_groups
  force row level security;

alter table catchmenu_pos.menu_option_items
  enable row level security;
alter table catchmenu_pos.menu_option_items
  force row level security;

alter table catchmenu_pos.order_sessions
  enable row level security;
alter table catchmenu_pos.order_sessions
  force row level security;

alter table catchmenu_pos.session_events
  enable row level security;
alter table catchmenu_pos.session_events
  force row level security;

alter table catchmenu_pos.orders
  enable row level security;
alter table catchmenu_pos.orders
  force row level security;

alter table catchmenu_pos.order_items
  enable row level security;
alter table catchmenu_pos.order_items
  force row level security;

alter table catchmenu_pos.order_events
  enable row level security;
alter table catchmenu_pos.order_events
  force row level security;

-- catchmenu_payment
alter table catchmenu_payment.payment_intents
  enable row level security;
alter table catchmenu_payment.payment_intents
  force row level security;

alter table catchmenu_payment.payment_ledger
  enable row level security;
alter table catchmenu_payment.payment_ledger
  force row level security;

alter table catchmenu_payment.payment_events
  enable row level security;
alter table catchmenu_payment.payment_events
  force row level security;

alter table catchmenu_payment.reconciliation_cases
  enable row level security;
alter table catchmenu_payment.reconciliation_cases
  force row level security;

-- catchmenu_kds
alter table catchmenu_kds.kds_tickets
  enable row level security;
alter table catchmenu_kds.kds_tickets
  force row level security;

alter table catchmenu_kds.kds_events
  enable row level security;
alter table catchmenu_kds.kds_events
  force row level security;

-- catchmenu_agent
alter table catchmenu_agent.evidence_packets
  enable row level security;
alter table catchmenu_agent.evidence_packets
  force row level security;

alter table catchmenu_agent.manual_fallback_log
  enable row level security;
alter table catchmenu_agent.manual_fallback_log
  force row level security;

alter table catchmenu_agent.agent_actions
  enable row level security;
alter table catchmenu_agent.agent_actions
  force row level security;

alter table catchmenu_agent.agent_approvals
  enable row level security;
alter table catchmenu_agent.agent_approvals
  force row level security;

-- catchmenu_knowledge
alter table catchmenu_knowledge.documents
  enable row level security;
alter table catchmenu_knowledge.documents
  force row level security;

alter table catchmenu_knowledge.document_versions
  enable row level security;
alter table catchmenu_knowledge.document_versions
  force row level security;

alter table catchmenu_knowledge.knowledge_gaps
  enable row level security;
alter table catchmenu_knowledge.knowledge_gaps
  force row level security;

-- catchmenu_integrations
alter table catchmenu_integrations.toss_payments
  enable row level security;
alter table catchmenu_integrations.toss_payments
  force row level security;

alter table catchmenu_integrations.toss_webhooks
  enable row level security;
alter table catchmenu_integrations.toss_webhooks
  force row level security;