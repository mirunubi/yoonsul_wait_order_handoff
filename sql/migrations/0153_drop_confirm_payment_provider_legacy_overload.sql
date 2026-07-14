-- 0153_drop_confirm_payment_provider_legacy_overload.sql
-- Purpose: Remove the dormant 9-param overload of
--          catchmenu_payment.confirm_payment_from_provider()
--          (added in 0063, p_locale extra), leaving the 8-param
--          original (0027) as the single canonical function.
--
-- Background:
--   Two live overloads caused every real caller (0038 Toss webhook,
--   0056 VAN integration) to fail with "function ... is not unique"
--   since both use identical 8 named arguments that PostgreSQL could
--   not resolve between the two candidates. Direct reproduction
--   further showed the 9-param overload independently crashes on
--   its own first write statement (phantom/missing columns), so
--   there is no working functionality being removed.
--
-- Human decision (2026-07-14): single canonical 8-param function,
-- no p_locale, no JSONB extension field (YAGNI).
--
-- Depends on:
--   - 0152_add_orders_pickup_ready_timing_columns.sql

drop function if exists catchmenu_payment.confirm_payment_from_provider(
  uuid, uuid, uuid, text, text, int, uuid, text, text
);
