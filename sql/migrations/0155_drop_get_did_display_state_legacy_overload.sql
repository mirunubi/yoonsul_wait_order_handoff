-- Migration: 0155_drop_get_did_display_state_legacy_overload.sql
-- Purpose:
--   Drop the legacy 3-param catchmenu_store.get_did_display_state(uuid, uuid, uuid)
--   overload and leave the 0117 4-param p_did_id/p_locale implementation as the
--   single canonical DID display state function.
--
-- Background:
--   The legacy 0043 overload has three independent defects/evidence points:
--   1. Its body contains a nested aggregate pattern that fails at runtime
--      ("aggregate function calls cannot be nested").
--   2. Its p_device_id parameter is not used by the function body.
--   3. Repository/live-call inspection found no actual caller for the 3-param
--      overload, while bootstrap_did_app() calls the 0117 4-param overload by
--      named arguments (p_did_id, p_locale).
--
-- Human decision:
--   2026-07-14 Option A approved for 600820_did_display_state_overload_and_legacy_defect:
--   drop only the legacy 0043 3-param overload and keep 0117 canonical.
--
-- Depends on:
--   0154_drop_mark_payment_uncertain_legacy_overload.sql
--
-- Creates/Changes:
--   Removes catchmenu_store.get_did_display_state(uuid, uuid, uuid).
--
-- Scope exclusions:
--   Does not edit 0043_create_did_display_rpc.sql.
--   Does not edit 0117_create_did_pipeline_rpc.sql.
--   Does not modify bootstrap_did_app().
--   Does not repair the old 0043 nested aggregate body.
--   Does not touch mark_payment_uncertain(), authorize_kds_release(), or mark_no_show().

drop function if exists catchmenu_store.get_did_display_state(
  uuid, uuid, uuid
);
