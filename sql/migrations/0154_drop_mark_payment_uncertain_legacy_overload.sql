-- =============================================
-- Migration: 0154_drop_mark_payment_uncertain_legacy_overload
-- Purpose:
--   Drop the dormant 0063-era 6-param mark_payment_uncertain() overload
--   and leave the 0027-era 5-param function as the single canonical
--   catchmenu_payment.mark_payment_uncertain() implementation.
--
-- Background:
--   600530_mark_payment_uncertain_overload_ambiguity confirmed that the
--   0063 overload adds p_locale and creates overload ambiguity while also
--   failing independently against live constraints:
--     - intent_status = 'UNCERTAIN' violates chk_intent_status.
--     - catchmenu_ledger.exceptions.exception_code is NOT NULL, but the
--       0063 overload omits exception_code in its INSERT.
--
-- Depends on:
--   0153_drop_confirm_payment_provider_legacy_overload.sql
--
-- Creates/Changes:
--   Removes only:
--     catchmenu_payment.mark_payment_uncertain(
--       uuid, uuid, uuid, text, text, text
--     )
--
-- Non-goals:
--   - Do not modify 0027_create_payment_intent_rpc.sql.
--   - Do not modify 0063_patch_core_rpc_i18n_diagnostics.sql.
--   - Do not modify 0070_create_flutter_bootstrap_rpc.sql.
--   - Do not change chk_intent_status.
--   - Do not add p_locale or p_options jsonb.
--   - Do not fix the carried-forward 0027 dashboard invisibility,
--     i18n/diagnostic-log gap, real call-chain absence, or
--     authorize_kds_release() overload issue in this migration.
-- =============================================

drop function if exists catchmenu_payment.mark_payment_uncertain(
  uuid, uuid, uuid, text, text, text
);
