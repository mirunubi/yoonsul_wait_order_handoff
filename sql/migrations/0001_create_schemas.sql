-- 0001_create_schemas.sql
-- Purpose: Create all domain schemas for catchmenu operational OS.
-- Depends on: (none)
-- Creates:
--   schemas: catchmenu_common, catchmenu_hq, catchmenu_store,
--            catchmenu_pos, catchmenu_kds, catchmenu_payment,
--            catchmenu_ledger, catchmenu_agent, catchmenu_knowledge,
--            catchmenu_gateway, catchmenu_integrations, catchmenu_audit

create extension if not exists pgcrypto;

comment on extension pgcrypto is
  'Required for gen_random_uuid() on all primary keys.';

create schema if not exists catchmenu_common;
create schema if not exists catchmenu_hq;
create schema if not exists catchmenu_store;
create schema if not exists catchmenu_pos;
create schema if not exists catchmenu_kds;
create schema if not exists catchmenu_payment;
create schema if not exists catchmenu_ledger;
create schema if not exists catchmenu_agent;
create schema if not exists catchmenu_knowledge;
create schema if not exists catchmenu_gateway;
create schema if not exists catchmenu_integrations;
create schema if not exists catchmenu_audit;

comment on schema catchmenu_common is
  'Cross-domain utilities: shared triggers, helpers, idempotency. No business ownership.';
comment on schema catchmenu_hq is
  'HQ tenant graph: tenants, stores, brand configuration, SaaS boundary.';
comment on schema catchmenu_store is
  'Physical store runtime: dining tables, seating, device registry, agent registry.';
comment on schema catchmenu_pos is
  'POS domain: menus, order sessions, orders, order items. Handoff core.';
comment on schema catchmenu_kds is
  'KDS domain: kitchen tickets, station routing, Late Binding control. 특허2 core.';
comment on schema catchmenu_payment is
  'Payment domain: payment intents, provider integration, reconciliation cases.';
comment on schema catchmenu_ledger is
  'Internal canonical ledgers: task ledger, event ledger, audit ledger, exception ledger.
   These are the source of truth. Current state is derived from these via projections.
   특허4 core: Task/Event/Audit/Exception 4-ledger architecture.';
comment on schema catchmenu_agent is
  'Agent runtime domain: agent actions, approvals, SOP handoff, recovery records.
   Agents observe and recommend. Final authority belongs to humans.';
comment on schema catchmenu_knowledge is
  'Operational knowledge runtime: SOP, Policy, Checklist, Incident Guide, Runbook.
   특허3 core: self-evolving knowledge generation system.';
comment on schema catchmenu_gateway is
  'External integration gateway: provider raw events, gateway sessions, sandbox boundary.
   All external inputs enter here before reaching internal ledgers.';
comment on schema catchmenu_integrations is
  'Provider-specific integration tables: Toss, VAN, PG, delivery apps, kiosk vendors.';
comment on schema catchmenu_audit is
  'Immutable audit trail. Append-only. No UPDATE or DELETE ever allowed.
   Covers all high-risk actions: payment, KDS release, agent override, staff action.';

-- shared updated_at trigger
create or replace function catchmenu_common.set_updated_at()
returns trigger
language plpgsql
security definer
set search_path = pg_catalog
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

comment on function catchmenu_common.set_updated_at() is
  'Generic before-update trigger that refreshes updated_at on mutable operational tables.
   Not applied to append-only ledger tables.';