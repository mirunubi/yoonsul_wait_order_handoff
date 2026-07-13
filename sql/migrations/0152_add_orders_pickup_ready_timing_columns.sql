-- 0152_add_orders_pickup_ready_timing_columns.sql
-- Purpose: Add order-level pickup/ready timing columns to
--          catchmenu_pos.orders.
--
-- Depends on:
--   - 0151_create_check_kds_capacity_function.sql
--
-- Creates:
--   - catchmenu_pos.orders.requested_pickup_at
--   - catchmenu_pos.orders.ready_at
--
-- Background:
--   catchmenu_store.place_takeout_order() already writes
--   requested_pickup_at into catchmenu_pos.orders, but the column did not
--   exist in the table schema.
--
--   catchmenu_store.track_takeout_order() already reads ready_at and
--   requested_pickup_at from catchmenu_pos.orders for its response timeline,
--   but both columns were missing from the table schema.
--
--   The live catchmenu_store.call_customer_pickup() body from
--   0094_fix_i18n_hardcoded_strings.sql already writes ready_at on
--   PICKUP_READY, but the column did not exist in catchmenu_pos.orders.
--
-- Scope:
--   - Forward schema migration only.
--   - Does not modify function bodies.
--   - Does not modify catchmenu_kds.kds_tickets.ready_at or KDS lifecycle.
--   - Does not resolve PICKED_UP status drift.
--   - Does not resolve point_ledger or discount_pct blockers.
--   - Adds no NOT NULL, DEFAULT, or CHECK constraints.

alter table catchmenu_pos.orders
  add column if not exists requested_pickup_at timestamptz,
  add column if not exists ready_at timestamptz;
