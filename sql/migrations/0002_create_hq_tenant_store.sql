-- 0002_create_hq_tenant_store.sql
-- Purpose: Create tenant and store master tables. SaaS boundary root.
-- Depends on: 0001_create_schemas.sql
-- Creates:
--   catchmenu_hq.tenants
--   catchmenu_hq.stores

create table if not exists catchmenu_hq.tenants (
  id uuid primary key default gen_random_uuid(),
  tenant_code text not null unique,
  tenant_name text not null,
  tenant_type text not null default 'BRAND',
  plan_tier text not null default 'STANDARD',
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint chk_tenants_type check (
    tenant_type in ('BRAND', 'FRANCHISE', 'INDEPENDENT', 'TEST')
  ),
  constraint chk_tenants_plan check (
    plan_tier in ('LITE', 'STANDARD', 'PRO', 'ENTERPRISE')
  )
);

drop trigger if exists trg_tenants_updated_at on catchmenu_hq.tenants;
create trigger trg_tenants_updated_at
  before update on catchmenu_hq.tenants
  for each row execute function catchmenu_common.set_updated_at();

comment on table catchmenu_hq.tenants is
  'Top-level SaaS tenant boundary. One row per brand or franchise group.
   All operational tables reference tenant_id for isolation.';
comment on column catchmenu_hq.tenants.tenant_type is
  'BRAND = single brand owner,
   FRANCHISE = multi-store franchise group,
   INDEPENDENT = single independent store,
   TEST = internal test tenant.';
comment on column catchmenu_hq.tenants.plan_tier is
  'SaaS subscription tier. Controls feature flags and rate limits.';


create table if not exists catchmenu_hq.stores (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references catchmenu_hq.tenants(id),
  store_code text not null,
  store_name text not null,
  store_type text not null default 'DINE_IN',
  store_status text not null default 'PREPARING',
  address text,
  phone text,
  timezone text not null default 'Asia/Seoul',
  business_hours jsonb,
  is_active boolean not null default true,
  opened_on date,
  closed_on date,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint uq_stores_tenant_code unique (tenant_id, store_code),
  constraint chk_stores_type check (
    store_type in ('DINE_IN', 'TAKEOUT', 'HYBRID', 'DELIVERY_ONLY')
  ),
  constraint chk_stores_status check (
    store_status in (
      'PREPARING',
      'ACTIVE',
      'SUSPENDED',
      'CLOSED'
    )
  ),
  constraint chk_stores_hours_object check (
    business_hours is null
    or jsonb_typeof(business_hours) = 'object'
  )
);

create index if not exists idx_stores_tenant_id
  on catchmenu_hq.stores(tenant_id);

create index if not exists idx_stores_tenant_status
  on catchmenu_hq.stores(tenant_id, store_status)
  where is_active = true;

drop trigger if exists trg_stores_updated_at on catchmenu_hq.stores;
create trigger trg_stores_updated_at
  before update on catchmenu_hq.stores
  for each row execute function catchmenu_common.set_updated_at();

comment on table catchmenu_hq.stores is
  'Physical store master under a tenant.
   All runtime tables (orders, sessions, kds, payments) reference store_id.
   Store timezone is used for business_day calculation in all ledgers.';
comment on column catchmenu_hq.stores.store_status is
  'PREPARING = not yet open,
   ACTIVE = operating,
   SUSPENDED = temporarily closed or under review,
   CLOSED = permanently closed.';
comment on column catchmenu_hq.stores.business_hours is
  'Optional json structure for operating hours by day of week.
   Used by agent capacity checks and KDS Late Binding control.';
comment on column catchmenu_hq.stores.timezone is
  'Store local timezone. Default Asia/Seoul.
   Used for business_day snapshot in all ledger tables.';