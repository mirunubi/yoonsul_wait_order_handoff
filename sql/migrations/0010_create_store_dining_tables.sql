-- 0010_create_store_dining_tables.sql
-- Purpose: Physical table and seat registry per store.
--          Table status is derived from event ledger projection.
--          Direct status update is for operational convenience only —
--          source of truth is always catchmenu_ledger.events.
-- Depends on: 0002_create_hq_tenant_store.sql
-- Creates:
--   catchmenu_store.dining_tables

create table if not exists catchmenu_store.dining_tables (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references catchmenu_hq.tenants(id),
  store_id uuid not null references catchmenu_hq.stores(id),

  table_code text not null,
  table_name text,
  capacity int not null default 4,
  floor_zone text,
  table_section text,
  display_order int not null default 0,

  -- QR/NFC identification
  qr_code text,
  nfc_tag_id text,

  -- current operational status (projection convenience)
  -- source of truth: catchmenu_ledger.events WHERE subject_type = 'dining_table'
  table_status text not null default 'AVAILABLE',
  current_session_id uuid,
  occupied_since timestamptz,
  last_cleaned_at timestamptz,

  -- device linkage
  kds_device_id uuid references catchmenu_store.device_registry(id),
  did_device_id uuid references catchmenu_store.device_registry(id),

  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint uq_dining_table_store_code
    unique (store_id, table_code),
  constraint chk_dining_table_status check (
    table_status in (
      'AVAILABLE',
      'OCCUPIED',
      'RESERVED',
      'CLEANING',
      'BLOCKED'
    )
  ),
  constraint chk_dining_table_capacity check (capacity > 0)
);

create index if not exists idx_dining_tables_store_status
  on catchmenu_store.dining_tables(store_id, table_status)
  where is_active = true;

create index if not exists idx_dining_tables_store_zone
  on catchmenu_store.dining_tables(store_id, floor_zone)
  where is_active = true;

create index if not exists idx_dining_tables_qr_code
  on catchmenu_store.dining_tables(qr_code)
  where qr_code is not null;

create index if not exists idx_dining_tables_nfc_tag
  on catchmenu_store.dining_tables(nfc_tag_id)
  where nfc_tag_id is not null;

create index if not exists idx_dining_tables_current_session
  on catchmenu_store.dining_tables(current_session_id)
  where current_session_id is not null;

drop trigger if exists trg_dining_tables_updated_at
  on catchmenu_store.dining_tables;
create trigger trg_dining_tables_updated_at
  before update on catchmenu_store.dining_tables
  for each row execute function catchmenu_common.set_updated_at();

comment on table catchmenu_store.dining_tables is
  'Physical table and seat registry per store.
   table_status and current_session_id are projection convenience columns.
   They reflect the current state derived from catchmenu_ledger.events.
   If inconsistency is detected, replay events to reconstruct correct state.
   QR code and NFC tag are the physical entry points for customer Late Binding.
   특허1: 고객 단말 기반 대기→장바구니→테이블 Late Binding의 물리적 앵커.';
comment on column catchmenu_store.dining_tables.table_status is
  'AVAILABLE = empty and ready.
   OCCUPIED = customer session active.
   RESERVED = held for upcoming session.
   CLEANING = being cleaned between sessions.
   BLOCKED = out of service.
   This is a projection convenience column.
   Source of truth: ledger events WHERE subject_type = dining_table.';
comment on column catchmenu_store.dining_tables.current_session_id is
  'Active order session linked to this table.
   Null when table is AVAILABLE or CLEANING.
   Set during Late Binding when customer is seated.
   특허1: Late Binding 테이블 후매칭부의 물리적 연결점.';
comment on column catchmenu_store.dining_tables.qr_code is
  'QR code value printed on table card or embedded in table surface.
   Customer scans this to initiate or complete Late Binding.
   Must be unique per store. Never contains internal session or order IDs.';
comment on column catchmenu_store.dining_tables.nfc_tag_id is
  'NFC tag identifier embedded in table surface.
   Alternative to QR for customer device tap-to-link.';
comment on column catchmenu_store.dining_tables.kds_device_id is
  'Optional KDS device assigned to this table zone.
   Used for station-based KDS routing.';