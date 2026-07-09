-- 0067_create_cron_scheduler_rpc.sql
-- No-op safety migration.
-- This migration previously contained duplicated content from
-- 0066_create_ledger_integrity_rpc.sql.
-- The duplicate content was removed under 604320.
-- Real cron scheduler implementation is deferred to a separate approved workpacket.
-- Depends on: 0066_create_ledger_integrity_rpc.sql
-- Creates: (none)

do $$
begin
  -- Intentionally no-op.
  -- Kept to preserve migration numbering and clean sequential replay.
  null;
end;
$$;
