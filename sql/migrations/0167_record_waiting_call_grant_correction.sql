-- 0167_record_waiting_call_grant_correction.sql
--
-- Purpose:
--   Correct EXECUTE privileges for the waiting-call internal helper and
--   automatic next-customer public RPC.
--
-- Depends on: 0166_canonical_kds_release_orchestration.sql
--   Sequential-numbering convention only; no functional dependency.

revoke all on function catchmenu_pos._record_waiting_call(
  uuid, uuid, uuid, text, int, text, text, uuid,
  boolean, int, text, timestamptz, text, uuid, text, text
) from public;

revoke all on function catchmenu_pos.call_next_waiting_customer(
  uuid, uuid, uuid, text, text
) from public;

grant execute on function catchmenu_pos.call_next_waiting_customer(
  uuid, uuid, uuid, text, text
) to authenticated;
