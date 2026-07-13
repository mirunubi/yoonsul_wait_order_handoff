# 600404_PlaceTakeoutOrder_Defect_Roadmap.md

Status: Living Document
Owner: Claude (cross-workpacket tracking, not tied to a single change)
Last Updated: 2026-07-13

## Purpose

`catchmenu_store.place_takeout_order()` (`sql/migrations/0081_create_customer_app_rpc.sql`) has never completed an end-to-end call for any input combination. Four distinct, non-overlapping defects have been discovered across `600450_place_takeout_order_unassigned_record_fix` and `600460_takeout_session_type_fix`. This document tracks all four in one place so the next session has a single, current starting point instead of having to re-derive it from multiple Audit documents.

This is a **living document** — update it in place as each defect is fixed or as new ones are discovered, rather than creating a new numbered file per update.

## Defect Map — Ordered By Code Position (Execution Order)

The four defects occupy disjoint, non-overlapping line ranges inside `place_takeout_order()`, in this fixed order top-to-bottom:

| # | Defect | Location | Trigger Condition | Status |
|---|---|---|---|---|
| 1 | `point_ledger` stale columns (`point_type`/`point_amount` → actual `transaction_type`/`points_change`; `'USE'` → actual `'DEDUCT'`) | L627-630 | `p_use_points > 0` **and** a customer is identified (`v_customer_id is not null`) | **OPEN** |
| 2 | `discount_pct` column does not exist on `catchmenu_store.coupons` (real columns: `discount_type`/`discount_value`) | L684+ | `p_coupon_issue_id` provided (guest or member — not member-only) | **OPEN** |
| 3 | `session_type = 'ONLINE'` violates `chk_session_type` (`0012`) | L826 | Unconditional — every call reaches this INSERT | **FIXED** (`600460_takeout_session_type_fix`, `600467_Audit.md` ACCEPT) |
| 4 | `requested_pickup_at` column does not exist on `catchmenu_pos.orders` (no equivalent under any name — unmigrated column, not a rename drift) | L839 | Unconditional — every call that passes #3 reaches this INSERT | **OPEN** (newly discovered, `600466_Verification.md` §2) |

## How Far The Function Actually Reaches, Per Input Combination

Because #1/#2 are conditional (only evaluated when their trigger input is present) while #3/#4 are unconditional, "how far execution gets" depends on which inputs are supplied — this is the more useful ordering for deciding what to fix next:

| Input combination | Current stopping point | Reasoning |
|---|---|---|
| Guest, no coupon, no points | **#4 `requested_pickup_at`** (furthest reached) | Skips #1 (no points+customer) and #2 (no coupon); #3 now fixed; stops at #4. |
| Any (guest/member), points requested + customer identified | **#1 `point_ledger`** | Fires before #2/#3/#4 are ever evaluated (`if p_use_points > 0 and v_customer_id is not null` gate). |
| Any (guest/member), coupon provided, no points-triggering condition | **#2 `discount_pct`** | Fires before #3/#4 are evaluated. |
| Member, points + coupon both provided | **#1 `point_ledger`** | #1's code position precedes #2's; the points branch is checked first regardless of coupon presence. |

**Conclusion**: the simplest, most common path (guest, no coupon, no points) is the one that currently travels furthest — all the way to #4. Fixing #4 next is what's required to let that path fully succeed; #1 and #2 remain independent blockers for their respective branches regardless of #4's status.

## Recommended Fix Priority

1. **`requested_pickup_at`** (#4) — highest priority. Unconditional; blocks every path that clears #3, including the simplest/most common one, which is currently one fix away from a full success run. Unlike #1/#2, fixing this is a prerequisite for *any* path completing end-to-end, since it is unconditionally downstream of both.
2. **`point_ledger`** (#1) — unblocks the points-usage path. Independent of #4.
3. **`discount_pct`** (#2) — unblocks the coupon-usage path. Independent of #4 and #1.

None of the three has been found to interact with the others (disjoint code regions, independent trigger conditions) — they can be fixed in one batch with low interaction risk, consistent with the priority analysis originally established in `600457_Audit.md` §2.4 (updated here to insert #4 and re-derive the "furthest reach" framing now that #3 is fixed).

## Secondary, Lower-Priority Findings (Not Blockers Of `place_takeout_order()` Itself)

Discovered incidentally while investigating #3/#4; these live in a *different* function (`catchmenu_pos.create_order_session()`, `0063`'s second overload) that currently has zero live callers — tracked here for continuity, not because they block `place_takeout_order()`:

| Item | Location | Status |
|---|---|---|
| `0063` L202-206 — `DELIVERY` branch missing from the ledger-event `case p_session_type` block | `0063_patch_core_rpc_i18n_diagnostics.sql` | OPEN, low urgency (zero live callers) |
| `0025` vs `0063` `WALK_IN` mapping mismatch (`'SEATED'` vs `'ORDERING'`) | `0025_create_session_rpc.sql` / `0063_patch_core_rpc_i18n_diagnostics.sql` | OPEN, low urgency (zero live callers) |

## Change History Of This Roadmap

| Date | Update |
|---|---|
| 2026-07-13 | Created. Defect #3 (`session_type`) marked FIXED following `600460_takeout_session_type_fix` (`600467_Audit.md` ACCEPT). Defect #4 (`requested_pickup_at`) added — newly discovered during `600460`'s Stage 5 re-verification (`600466_Verification.md` §2). Defects #1/#2 (`point_ledger`/`discount_pct`) carried forward from `600457_Audit.md`. |
