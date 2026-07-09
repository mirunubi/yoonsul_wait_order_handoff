-- 0000_create_migration_history_table.sql
-- Purpose: Custom migration tracking table, since this project uses
--          sequence-numbered migration files (0001, 0002, ...) instead
--          of the Supabase CLI's timestamp-based naming, and therefore
--          cannot rely on supabase_migrations.schema_migrations.
-- Creates:
--   schema catchmenu_meta
--   catchmenu_meta.migration_history (table)

create schema if not exists catchmenu_meta;

create table if not exists catchmenu_meta.migration_history (
  filename text primary key,
  checksum text not null,
  applied_at timestamptz not null default now(),
  applied_by text default current_user,
  success boolean not null default true,
  error_message text
);
