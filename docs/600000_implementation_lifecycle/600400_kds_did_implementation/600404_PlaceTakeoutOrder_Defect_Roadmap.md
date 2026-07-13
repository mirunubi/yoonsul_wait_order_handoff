# 600404_PlaceTakeoutOrder_Defect_Roadmap.md

Status: Living Document
Owner: Claude (cross-workpacket tracking, not tied to a single change)
Last Updated: 2026-07-13

## Purpose

`catchmenu_store.place_takeout_order()` (`sql/migrations/0081_create_customer_app_rpc.sql`) has never completed an end-to-end call for any input combination. Five distinct, non-overlapping defects have been discovered across `600450_place_takeout_order_unassigned_record_fix`, `600460_takeout_session_type_fix`, and `600470_orders_pickup_ready_timing_columns_migration`. Two closely-related sibling functions in the same takeout-order-fulfillment pipeline (`track_takeout_order()`, `catchmenu_store.call_customer_pickup()`) share some of these defects or have their own — tracked in the Secondary section below. This document tracks all of it in one place so the next session has a single, current starting point instead of having to re-derive it from multiple Audit documents.

This is a **living document** — update it in place as each defect is fixed or as new ones are discovered, rather than creating a new numbered file per update.

## Defect Map — Ordered By Code Position (Execution Order)

The five defects occupy disjoint, non-overlapping line ranges inside `place_takeout_order()`, in this fixed order top-to-bottom:

| # | Defect | Location | Trigger Condition | Status |
|---|---|---|---|---|
| 1 | `point_ledger` stale columns (`point_type`/`point_amount` → actual `transaction_type`/`points_change`; `'USE'` → actual `'DEDUCT'`) | L627-630 | `p_use_points > 0` **and** a customer is identified (`v_customer_id is not null`) | **OPEN** |
| 2 | `discount_pct` column does not exist on `catchmenu_store.coupons` (real columns: `discount_type`/`discount_value`) | L684+ | `p_coupon_issue_id` provided (guest or member — not member-only) | **OPEN** |
| 3 | `session_type = 'ONLINE'` violates `chk_session_type` (`0012`) | L826 | Unconditional — every call reaches this INSERT | **FIXED** (`600460_takeout_session_type_fix`, `600467_Audit.md` ACCEPT) |
| 4 | `requested_pickup_at`/`ready_at` columns did not exist on `catchmenu_pos.orders` (no equivalent under any name — unmigrated columns, not a rename drift) | L839/845/854 | Unconditional — every call that passes #3 reaches this INSERT | **FIXED** (`600470_orders_pickup_ready_timing_columns_migration`, `0152`, `600477_Audit.md` ACCEPT) |
| 5 | `order_items` stale/phantom columns: `unit_price`→real `unit_price_snapshot`, `subtotal`→real `item_amount` (has a `CHECK` tying it to `options_amount`), `is_kds_required`→real `is_kds_required_snapshot`, `display_order`→**no such column under any name** | L874 (INSERT, `place_takeout_order()`) | Unconditional — every call that passes #4 reaches this INSERT | **OPEN** (newly discovered, `600477_Audit.md` Open Item (a)) |

## How Far The Function Actually Reaches, Per Input Combination

Because #1/#2 are conditional (only evaluated when their trigger input is present) while #3/#4/#5 are unconditional, "how far execution gets" depends on which inputs are supplied — this is the more useful ordering for deciding what to fix next:

| Input combination | Current stopping point | Reasoning |
|---|---|---|
| Guest, no coupon, no points | **#5 `order_items`** (furthest reached, up from #4 last session) | Skips #1 (no points+customer) and #2 (no coupon); #3/#4 now fixed; stops at #5. |
| Any (guest/member), points requested + customer identified | **#1 `point_ledger`** | Fires before #2/#3/#4/#5 are ever evaluated (`if p_use_points > 0 and v_customer_id is not null` gate). |
| Any (guest/member), coupon provided, no points-triggering condition | **#2 `discount_pct`** | Fires before #3/#4/#5 are evaluated. |
| Member, points + coupon both provided | **#1 `point_ledger`** | #1's code position precedes #2's; the points branch is checked first regardless of coupon presence. |

**Conclusion**: the simplest, most common path (guest, no coupon, no points) continues to be the one that travels furthest — it advanced from #4 to #5 this session as a direct result of `600470`'s fix. Fixing #5 next is what's required to let that path fully succeed; #1 and #2 remain independent blockers for their respective branches regardless of #5's status. This is the second consecutive session where fixing the current frontier blocker immediately revealed the next one — expect this pattern to continue.

## Recommended Fix Priority

1. **`order_items` stale/phantom columns** (#5) — highest priority. Unconditional; blocks every path that clears #3/#4, including the simplest/most common one, which is currently one fix away from a full success run (through `place_takeout_order()`'s INSERT side — `track_takeout_order()`'s read side is a second, separate query hitting the same root cause, see Secondary section). Note `display_order` has no target column at all — this fix needs a real design decision (drop the ordering attempt, or add a column), not a pure rename.
2. **`point_ledger`** (#1) — unblocks the points-usage path. Independent of #5.
3. **`discount_pct`** (#2) — unblocks the coupon-usage path. Independent of #5 and #1.

None of the three has been found to interact with the others (disjoint code regions, independent trigger conditions) — they can be fixed in one batch with low interaction risk, consistent with the priority analysis originally established in `600457_Audit.md` §2.4 (updated here to mark #4 FIXED, insert #5, and re-derive the "furthest reach" framing now that #3/#4 are both fixed).

## Secondary, Related Findings In Sibling Functions (Same Pipeline, Not `place_takeout_order()` Itself)

### Confirmed to block a sibling function today

| Item | Function / Location | Status |
|---|---|---|
| `order_items` stale/phantom columns (same root cause as #5 above, separate query) | `track_takeout_order()` (`0081`) — item-list SELECT | OPEN — confirmed live-blocking via direct reproduction (`600476_Verification.md` §3), same fix as #5 should resolve both. |
| `chk_event_domain` — `event_domain := 'store'` not an allowed value | `catchmenu_store.call_customer_pickup()` (live-owning file: `0094_fix_i18n_hardcoded_strings.sql`) — `catchmenu_ledger.events` INSERT | OPEN — confirmed live-blocking via direct reproduction (`600476_Verification.md` §4). Fires on **every** call, before the (now-fixed) `ready_at` UPDATE — this function's benefit from `600470` has not yet been observed in a successful run. |

### Low-urgency, zero live callers

Discovered incidentally while investigating #3/#4; these live in a *different* function (`catchmenu_pos.create_order_session()`, `0063`'s second overload) that currently has zero live callers:

| Item | Location | Status |
|---|---|---|
| `0063` L202-206 — `DELIVERY` branch missing from the ledger-event `case p_session_type` block | `0063_patch_core_rpc_i18n_diagnostics.sql` | OPEN, low urgency (zero live callers) |
| `0025` vs `0063` `WALK_IN` mapping mismatch (`'SEATED'` vs `'ORDERING'`) | `0025_create_session_rpc.sql` / `0063_patch_core_rpc_i18n_diagnostics.sql` | OPEN, low urgency (zero live callers) |
| `call_customer_pickup()`'s `order_status not in (..., 'PICKED_UP', ...)` — `'PICKED_UP'` not in `chk_order_status` | `0094_fix_i18n_hardcoded_strings.sql` | OPEN, not a hard error (dead WHERE-clause condition, no-op) |

## Change History Of This Roadmap

| Date | Update |
|---|---|
| 2026-07-13 | Created. Defect #3 (`session_type`) marked FIXED following `600460_takeout_session_type_fix` (`600467_Audit.md` ACCEPT). Defect #4 (`requested_pickup_at`) added — newly discovered during `600460`'s Stage 5 re-verification (`600466_Verification.md` §2). Defects #1/#2 (`point_ledger`/`discount_pct`) carried forward from `600457_Audit.md`. |
| 2026-07-13 | Defect #4 (`requested_pickup_at`/`ready_at`) marked FIXED following `600470_orders_pickup_ready_timing_columns_migration` (`0152`, `600477_Audit.md` ACCEPT). Defect #5 (`order_items` stale/phantom columns) added — newly discovered via direct reproduction during `600470`'s Stage 5/6 (`600476_Verification.md` §2-3, `600477_Audit.md` Open Item (a)); note this defect is broader than a single `unit_price` rename — `display_order` has no target column at all. New Secondary entries added for `track_takeout_order()` (shares #5's root cause) and `call_customer_pickup()` (`chk_event_domain = 'store'`, fires before this migration's `ready_at` fix would ever be exercised). Simplest-path frontier advanced from #4 to #5. |
