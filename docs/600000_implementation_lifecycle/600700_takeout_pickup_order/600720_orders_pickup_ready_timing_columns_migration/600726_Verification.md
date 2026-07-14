# 600726_Verification.md

Status: Verified
Lifecycle: Verification
Stage: 5
Owner: Claude Code (full independent re-verification completed — see note below)
Date: 2026-07-13

## Note On Verification Depth

The task framing allowed for trusting Codex's self-report with transparent disclosure if time-constrained. That fallback was not needed here: Claude Code completed full, direct, independent re-verification against the local Supabase Docker container — schema check, checksum match, and live reproduction of all three affected functions (`place_takeout_order()`, `track_takeout_order()`, `call_customer_pickup()`) with fresh test data. The two new defects reported in `600727_Audit.md` (`order_items` stale columns, `chk_event_domain` `'store'`) were discovered through this direct reproduction, not inferred from Codex's report or carried from prior assumptions.

## Verification Result

PASS for the approved scope (2-column `ALTER TABLE`). Both target functions (`place_takeout_order()`, `track_takeout_order()`) now clear the `requested_pickup_at`/`ready_at` blockers that motivated this migration — but each hits a **new, separate, out-of-scope** defect immediately after. `call_customer_pickup()` was also independently tested and found to fail on a different new defect, one that fires *before* it would ever reach the `ready_at` UPDATE this migration was meant to unblock.

## 1. Schema And Bookkeeping Checks

| Check | Result |
|---|---|
| `requested_pickup_at`/`ready_at` exist live on `catchmenu_pos.orders` | PASS — `information_schema.columns`: both `timestamp with time zone`, `is_nullable = YES`, `column_default = null`. |
| Checksum integrity | PASS — `0152`'s SHA-256 (CRLF-normalized) matches `catchmenu_meta.migration_history` exactly, `success = true`. |
| Design match vs. `600722_Logic.md` §1 | PASS — nullable, no default, no CHECK, matches `0013`'s existing timestamp-column pattern. |
| Boundary — no function body touched | PASS — `0081`/`0079`/`0094` unchanged (only `0152`, a new file, was added). |

## 2. Live Reproduction — `place_takeout_order()`

Re-ran with a fresh `correlation_id` (`verify-600727-testA-rerun2`), `BEGIN`/`ROLLBACK`-wrapped:

- The `requested_pickup_at` failure at the `orders` INSERT (previously blocking, `600616_Verification.md`) is **gone** — execution now proceeds past it.
- **New failure**, immediately after, at the `order_items` INSERT:
  ```
  ERROR: column "unit_price" of relation "order_items" does not exist
  ```
- See `600727_Audit.md` for full root-cause analysis — this is broader than a single stale column name.

## 3. Live Reproduction — `track_takeout_order()`

Independently tested against a manually-inserted minimal `catchmenu_pos.orders` row (since `place_takeout_order()` cannot currently produce one on its own), `BEGIN`/`ROLLBACK`-wrapped:

- The order-level `requested_pickup_at`/`ready_at` SELECT (previously blocking) now succeeds.
- **New failure** in a separate query inside the same function — the item-list SELECT for the response:
  ```
  ERROR: column "unit_price" does not exist
  LINE: 'unit_price', unit_price, 'subtotal', subtotal ... order by display_order
  ```
- Same root defect class as §2 — `order_items` stale/phantom column references, present in **two separate queries within two separate functions**.

## 4. Live Reproduction — `call_customer_pickup()`

Independently tested by manually inserting a minimal `catchmenu_pos.orders` row and calling the function directly with `p_queue_type := 'PICKUP_READY'`, `BEGIN`/`ROLLBACK`-wrapped:

- **New failure**, unrelated to `ready_at`:
  ```
  ERROR: new row for relation "events" violates check constraint "chk_event_domain"
  DETAIL: ... contains (..., store, did_customer_called, ...)
  ```
- **Execution-order finding**: this `catchmenu_ledger.events` INSERT (`event_domain := 'store'`) occurs *before* the `ready_at` UPDATE in the function body. This migration's fix to `ready_at` has therefore **not yet been observed to take effect in any successful run** of `call_customer_pickup()` — the function still fails earlier than the point this migration addressed.

## Scenario Summary

| Scenario | Result |
|---|---|
| `requested_pickup_at`/`ready_at` columns live | PASS |
| Checksum integrity | PASS |
| Boundary (schema-only, no function changed) | PASS |
| `place_takeout_order()` clears `requested_pickup_at` blocker | PASS — new blocker (`order_items`) immediately after |
| `track_takeout_order()` clears `requested_pickup_at`/`ready_at` blocker | PASS — new blocker (`order_items`, same root cause) immediately after |
| `call_customer_pickup()` reaches the `ready_at` UPDATE this migration fixed | **Not yet observed** — blocked earlier by `chk_event_domain` |
