# 600494_ChangeContract.md

Status: Draft
Lifecycle: ChangeContract
Stage: 2 (Claude review / boundary contract)
Owner: TBD
Last Updated: 2026-07-14

## Change ID

`customer_handoff_contract_reconciliation`

## §0 Authority

Based on `600491_Overview.md`, `600492_Logic.md`, `600493_TestPlan.md`. This contract covers only the two items explicitly classified as Correction this turn:

1. `catchmenu_kds.kds_tickets` INSERT inside `catchmenu_pos.pre_order_while_waiting()` (`0115`).
2. `max_waiting_count` → `max_wait_number` inside `catchmenu_pos.get_waiting_realtime_state()` (`0099`).

**Classification note (transparency)**: `600492_Logic.md` §2 originally classified `order_sessions.cancel_reason`/`no_show_at` as **Correction** (simple new-column-add, alongside `arrival_confirmed_at` as Alignment and the other 5 as Redesign). This turn's task text groups `cancel_reason`/`no_show_at` into the **Redesign** bucket instead ("table_number, called_at, call_count, pre_order_amount, cancel_reason/no_show_at/memo 등"). This is a genuine discrepancy between the two documents, not silently resolved here — `cancel_reason`/`no_show_at` are **not** in this contract's Allowed scope either way, so the discrepancy has no effect on what is approved this turn, but it should be reconciled in `600492_Logic.md` before any future workpacket relies on that classification table.

## §1 Allowed Files

Exactly two existing files may be modified. No new file is created.

| File | Allowed scope |
|---|---|
| `sql/migrations/0115_create_waiting_pipeline_rpc.sql` | **`catchmenu_pos.pre_order_while_waiting()`'s `kds_tickets` INSERT statement only** (`600493_TestPlan.md` §2 Before/After): remove the `menu_id` column/value; add a `ticket_number` column/value generated as `v_order_number \|\| '-' \|\| lpad(v_ticket_count::text, 2, '0')`; add one new loop-scoped counter variable (`v_ticket_count int := 0;`) to the function's existing `declare` block, incremented once per loop iteration immediately before the INSERT. No other statement in `pre_order_while_waiting()`, and no other function in `0115`, may be touched. |
| `sql/migrations/0099_create_realtime_pipeline_rpc.sql` | **`catchmenu_pos.get_waiting_realtime_state()`'s `max_waiting_count` references only** — rename all 4 occurrences (`select ... into v_store_settings` column list, plus 3 later usages of `v_store_settings.max_waiting_count`) to `max_wait_number`. No other function in `0099` (`get_kds_realtime_state()`, `get_staff_alert_feed()`, `broadcast_store_event()`) may be touched. |

## §2 Forbidden Files And Operations

| Forbidden item | Reason |
|---|---|
| `pre_order_while_waiting()`'s `orders` INSERT (`order_source`, `order_type := 'TABLE'`) | Newly discovered this turn (`600493_TestPlan.md` §0.5/§4), not approved — separate Open Item (§4). |
| `pre_order_while_waiting()`'s `order_items` INSERT (`unit_price`/`subtotal`/`item_options`/missing `menu_code_snapshot`/missing `returning id`) | Newly discovered this turn, not approved — separate Open Item (§4), same class of defect already resolved for `place_takeout_order()` in `600477_Audit.md` but not yet addressed here. |
| `order_sessions.arrival_confirmed_at` ↔ `arrived_at` alignment | Classified Alignment, requires its own Human decision on whether the two are the same concept — not approved this turn (`600492_Logic.md` §2). |
| `order_sessions.table_number`/`called_at`/`call_count`/`pre_order_amount`/`memo` (and `cancel_reason`/`no_show_at` per this turn's Redesign grouping, see §0 classification note) | All 5(+2) Redesign items — Source-of-Truth decisions not made, explicitly out of scope (`600492_Logic.md` §2/§3). |
| `catchmenu_pos.orders.order_source` anywhere else it may be referenced | Confirmed drift (`600492_Logic.md` §1.4) but not approved for correction this turn. |
| `mark_no_show()` (`0050`/`0115`) / `get_did_display_state()` (`0043`/`0117`) overloads | Discovered in `600491_Overview.md` §2.1 — separate investigation needed, not approved. |
| `mark_payment_uncertain()` / `authorize_kds_release()` | Payment Confirmation Boundary territory, `600480`'s scope — explicitly excluded from this workpacket (`600491_Overview.md` §0). |
| Any other `sql/migrations/*.sql` file | Out of scope. |
| Flutter/runtime code, tools scripts | Out of scope. |

Implementation must not:

- Add `order_item_id` to the `kds_tickets` INSERT (would require also fixing the `order_items` INSERT to `returning id into ...`, which is out of scope — `600493_TestPlan.md` §0.5 explains why the simpler `menu_id`-removal design was chosen over the `order_item_id`-based alternative from `600492_Logic.md` §1.2.1).
- Touch `catchmenu_kds.kds_tickets`, `catchmenu_pos.order_items`, `catchmenu_store.store_settings`, or `catchmenu_pos.order_sessions` table schema (DDL) — this is a function-body-only fix, no `ALTER TABLE`.
- Add a `CHECK` constraint, `NOT NULL`, or default value to any column as a side effect of this fix.

## §3 Required Behavior Preservation

- `pre_order_while_waiting()`'s existing signature, `orders`/`order_items` INSERT logic (bugs and all — out of scope), coupon/point logic, and response shape are unchanged except for the one `kds_tickets` INSERT.
- `get_waiting_realtime_state()`'s existing signature, all other jsonb fields it builds, and response shape are unchanged except for the `max_waiting_count`→`max_wait_number` rename.
- `get_kds_realtime_state()`/`get_staff_alert_feed()`/`broadcast_store_event()` (siblings in the same `0099` file) remain byte-identical.

## §4 Required New Behavior

- `pre_order_while_waiting()`'s `kds_tickets` INSERT, when reached (i.e., once the separate, out-of-scope `orders`/`order_items` blockers are independently fixed in a future workpacket), must succeed without a `menu_id`-does-not-exist or `ticket_number`-NOT-NULL error.
- `get_waiting_realtime_state()` must progress past the `store_settings` lookup and fail (if at all) only on the still-open `arrival_confirmed_at`/`table_number`/`memo` drift — not on `max_waiting_count`.

## §5 Verification Requirements

Per `600493_TestPlan.md`:

1. Test A — isolated `kds_tickets` INSERT succeeds with the corrected column list (already verified in the TestPlan itself via a rolled-back transaction; Stage 5 must re-verify against the actually-implemented function body).
2. Test B — `get_waiting_realtime_state()`'s failure point moves from `max_waiting_count` to `arrival_confirmed_at` (already verified in the TestPlan itself; Stage 5 must re-verify against the actually-implemented function body).
3. Test C — the full blocker chain for `pre_order_while_waiting()` is recorded, not silently dropped.
4. Static boundary — only `0115`'s `kds_tickets` INSERT and `0099`'s `max_waiting_count` references differ from current source.

## §6 Open Items Not Approved In This Contract

### §6.1 `pre_order_while_waiting()`'s `orders`/`order_items` Defects — Blocks Any Real E2E Success

Newly discovered this turn (`600493_TestPlan.md` §0.5/§4). Even after this contract's fix lands, calling `pre_order_while_waiting()` end-to-end will still fail immediately at the `orders` INSERT (`order_source` phantom column, then `order_type := 'TABLE'` hidden behind it), before ever reaching the `order_items` INSERT (its own 4-part defect cluster) or the now-fixed `kds_tickets` INSERT. A follow-up workpacket covering both statements is needed before this function can complete end-to-end for the first time.

### §6.2 `get_waiting_realtime_state()`'s Remaining 3 `order_sessions` Phantom Columns

After this contract's fix, the function will still fail on `arrival_confirmed_at` (Alignment — likely the same concept as the existing `arrived_at` column, `600492_Logic.md` §2 row 5), then (once that's resolved) `table_number` and `memo` (both Redesign, SoT undecided). None approved this turn.

### §6.3 5 Redesign-Classified `order_sessions` Columns — SoT Decision Needed

`pre_order_amount`, `table_number`, `called_at`, `call_count`, `memo` (and, per this turn's regrouping — see §0 classification note — possibly `cancel_reason`/`no_show_at` as well, pending reconciliation with `600492_Logic.md`'s original Correction classification for those two). Candidates listed in `600492_Logic.md` §2, no decision made.

### §6.4 `arrival_confirmed_at` ↔ `arrived_at` Alignment Decision

`600492_Logic.md` §2 row 5 — strong candidate that this is the same concept referenced under two different names, not a missing feature. Needs a Human decision (rename the code reference vs. treat as genuinely separate) before implementation.

### §6.5 `mark_no_show()` / `get_did_display_state()` Overload Sprawl

Carried from `600491_Overview.md` §2.1 — same pattern as `600480`'s `confirm_payment_from_provider()`/`mark_payment_uncertain()`/`authorize_kds_release()`, not yet investigated for actual call-site ambiguity.

## §7 Risk

Risk level: LOW-MEDIUM.

Reasons:

- Both target functions (`pre_order_while_waiting()`, `get_waiting_realtime_state()`) are already 100% non-functional today (confirmed via direct reproduction) — this fix cannot make either function "more broken" than its current baseline.
- The `kds_tickets` fix is isolated-tested and confirmed working (`600493_TestPlan.md` §2).
- The `get_waiting_realtime_state()` fix is confirmed to produce forward progress, not silently mask remaining defects (§3 of the TestPlan explicitly moves the failure point, doesn't hide it).
- Neither fix touches any table schema — function-body-only, low blast radius.

Risk controls:

- Two-function, two-statement boundary, no schema changes.
- Isolated pre-verification already completed for both fixes before this contract was written (unusual for this stage, but done here because the fixes are small and the verification transactions were cheap to run).
- Explicit Open Items (§6) prevent this fix from being mistaken for a complete resolution of either function.

## §8 Human Boundary Approval

Human approval is required before Stage 4 implementation.

☑ I approve modifying sql/migrations/0115_create_waiting_pipeline_rpc.sql, limited to pre_order_while_waiting()'s kds_tickets INSERT statement exactly as specified in §1.
☑ I approve modifying sql/migrations/0099_create_realtime_pipeline_rpc.sql, limited to the 4 max_waiting_count→max_wait_number renames inside get_waiting_realtime_state() exactly as specified in §1.
☑ I acknowledge that pre_order_while_waiting() will still fail end-to-end after this fix (blocked by order_source/order_type/order_items, §6.1) and that get_waiting_realtime_state() will still fail on arrival_confirmed_at (§6.2) — neither function reaches full success from this contract alone.

## §9 Stage 4 Instruction If Approved

If all three Human approval boxes in §8 are checked, Stage 4 may proceed to implement exactly this contract.

If any box remains unchecked, Stage 4 must stop and report that implementation is not authorized.
