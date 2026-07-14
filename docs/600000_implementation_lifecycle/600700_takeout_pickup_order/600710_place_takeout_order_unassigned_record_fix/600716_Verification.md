# 600716_Verification.md

Status: Verified
Lifecycle: Verification
Stage: 5
Owner: Claude + Cursor (§39/§40 dual verification, Antigravity parallel reference-only)
Date: 2026-07-13

## Verification Result

Final result: PASS for the approved scope (record-unassigned crash class eliminated in all 4 required paths). Three **separate, pre-existing, out-of-scope** defects newly confirmed to block full end-to-end success — none is a record-unassigned regression.

## 1. Claude Code Stage 5 — Independent Re-Verification

Codex's self-report was not trusted at face value; everything below was re-derived directly against the local Supabase Docker container.

| Check | Result |
|---|---|
| Live `pg_get_functiondef()` vs. source for `place_takeout_order()` | PASS — statement-for-statement identical after filtering header/tag formatting differences. |
| `600440` preservation | PASS — `grep -c "READY_TO_COMMIT"` = 0 in the current file; `track_takeout_order()`'s `COMMITTED` output key (from the `600440` workpacket) untouched. |
| Checksum integrity | PASS — current file SHA-256 matches `catchmenu_meta.migration_history` exactly, `success = true`. No drift (unlike `600440`'s `0070`/`0081` gap). |
| Boundary — only `place_takeout_order()` changed | PASS — full diff reviewed; no other function in `0081` touched. |
| Group 1 — Guest + no coupon | PASS (record-unassigned class) — no `record "..." is not assigned yet` error. Execution reached `catchmenu_pos.order_sessions` INSERT and failed there instead, on `chk_session_type` (§2 below — separate, out-of-scope defect). |
| Group 2 — Guest + coupon ID provided | PASS (record-unassigned class) — `L653`'s `ci.customer_id = v_customer_id` comparison against `NULL` correctly returned 0 rows, no crash. Execution reached the coupon SELECT's column list and failed on `column c.discount_pct does not exist` (§2 below — separate, out-of-scope defect, and confirmed to affect this path too, not only member+coupon as originally scoped in `600711_Overview.md` §3). |
| Group 3 — Member + no coupon | PASS (record-unassigned class) — no crash at `L714`/`L852`. Execution reached the same `chk_session_type` wall as Group 1. |
| Group 4 — Member + coupon provided | PASS (record-unassigned class) — no crash. Fails earlier, at the same `discount_pct` column error as Group 2 (confirmed consistent with `600712_Logic.md` §5's prediction). |
| Group 5 — Guest + points requested | PASS (record-unassigned class + A안 policy) — the `elsif v_customer_id is null and p_use_points > 0` branch is reached with no crash; execution then continues to the same `chk_session_type` wall as Group 1/3. The `log_diagnostic()` call itself was independently verified in isolation (below) since the full-function test's later `chk_session_type` failure aborts the whole transaction, rolling back the earlier diagnostic write along with it — this is expected PostgreSQL behavior for a function with no internal `EXCEPTION` handler, and is itself supporting evidence for the newly-adopted `000701` §41 requirement. |
| Group 6 — Member + valid points regression | **Fails, but not on record-unassigned** — `column "point_type" does not exist` at `L609`'s own point-balance query. This is `place_takeout_order()`'s **first** blocker in this specific path (fires before coupon/session issues would even be reached) — a separate, pre-existing stale-schema defect (§2 below), not a regression introduced by this fix. |
| `log_diagnostic()` call correctness, isolated | PASS — called standalone with the exact parameters used in the `L609` `elsif` branch; confirmed a matching row was written to `catchmenu_common.diagnostic_logs` (`log_level=WARNING`, `log_domain=ORDER`, `log_event=points_requested_without_customer`). |
| Static check | PASS — 0 residual `v_customer.`/`v_coupon.` field references outside two pre-existing, unrelated comment lines (about `order_sessions` lacking a `customer_id` column, predating this workpacket). |

## 2. Three Newly-Confirmed Blocking Defects (Urgent Investigation, Prep for Next Session)

None of these three is a record-unassigned regression from this fix — all three are independently reproduced, pre-existing, stale-schema/stale-literal defects that this fix's ChangeContract (`600714_ChangeContract.md` §2/§6) explicitly placed out of scope (`discount_pct`) or had not yet discovered (`chk_session_type`, `point_ledger`).

### 2.1 `chk_session_type` — blocks Groups 1, 3, 5 (any path without a coupon or points)

- **Exact allowed values** (`pg_get_constraintdef`, live): `CHECK ((session_type = ANY (ARRAY['WALK_IN', 'WAITING', 'PRE_ORDER', 'KIOSK', 'TAKEOUT', 'DELIVERY'])))`. `'ONLINE'` — the literal `place_takeout_order()` inserts at `L826` — is not in this list and never was.
- **Origin**: the constraint is defined in `sql/migrations/0012_create_pos_order_sessions.sql` (table creation). A same-named constraint `chk_session_type` also appears in `sql/migrations/0097_create_auth_login_pipeline_rpc.sql`, but that is a **different table** (an auth/login session table using `'STAFF'`/`'CUSTOMER'` values) — a naming collision, not a second constraint on `order_sessions`. Confirmed by reading both files directly.
- **How `register_waiting()` avoids this**: `sql/migrations/0115_create_waiting_pipeline_rpc.sql` inserts into the same `order_sessions` table using `p_session_type` (default `'WAITING'`) — a value that **is** in the allowed list. `register_waiting()` does not have this bug; `place_takeout_order()`'s choice of the literal `'ONLINE'` appears to be simply wrong. `'TAKEOUT'` is the strong candidate correct value — it is both in the allowed list and matches `place_takeout_order()`'s own `orders.order_type := 'TAKEOUT'` used elsewhere in the same function.

### 2.2 `point_ledger` stale columns — blocks Group 6 (member + points), fires **before** any coupon/session issue in that path

- **Actual columns** (`information_schema.columns`, live): `transaction_type text`, `points_change int`, `points_before int`, `points_after int` — no `point_type`/`point_amount` at all. `place_takeout_order()`'s `L609-623` point-balance query (`case point_type when 'EARN' then point_amount ...`) references both non-existent columns.
- **`chk_transaction_type` allowed values**: `'EARN', 'DEDUCT', 'EXPIRE', 'ADJUST', 'BONUS', 'REFUND_EARN'`. The code's `CASE` literals `'EARN'`/`'USE'`/`'EXPIRE'` are only 2/3 correct — `'EARN'` and `'EXPIRE'` match, but `'USE'` does not exist; the correct value is `'DEDUCT'`.
- **Scope check — is this systemic or contained?** `catchmenu_store.deduct_points()` (the function `place_takeout_order()` itself calls at `L869` to actually spend points) was checked independently and **correctly** uses `transaction_type`/`points_change` — it is not broken. The bug is contained to `place_takeout_order()`'s own inline balance-check query; it does not indicate a wider `point_ledger` schema problem across the codebase.

### 2.3 `discount_pct` (carried over from `600711_Overview.md` §3, re-confirmed and scope-corrected)

- Re-confirmed live: `column c.discount_pct does not exist`. `catchmenu_store.coupons`'s real columns are `discount_type` (`'FIXED'`/`'PERCENTAGE'`) and `discount_value` only.
- **Scope correction**: `600711_Overview.md` §3 characterized this as blocking only "member+coupon." Independent testing this turn shows it blocks **any** call with `p_coupon_issue_id` provided, guest or member alike (Group 2 confirmed) — the coupon SELECT is gated by `p_coupon_issue_id is not null`, not by customer identity.

### 2.4 Priority / Overlap Analysis

The three defects occupy **non-overlapping code regions** within the same function and fire in a fixed order determined by which inputs are supplied, not by any interaction between the defects themselves:

1. If `p_use_points > 0` **and** a customer is identified → `point_ledger` (`L609-623`) fires first — earliest in execution order.
2. Else if `p_coupon_issue_id` is provided → `discount_pct` (`L684+`) fires next.
3. Else (no points, no coupon — the simplest/most common guest checkout) → `chk_session_type` (`L826`) fires.

Because the three fixes touch disjoint line ranges (`L609-623`, `L684-786` roughly, and `L826` respectively), they can be fixed **together in one batch** with low interaction risk — there is no evidence any of the three fixes would affect another's correctness. Recommended sequencing for the next session, in order of how quickly each unblocks the most common path: `chk_session_type` (unblocks the plain guest/member no-coupon-no-points happy path — likely the MVP's most common real scenario) → `point_ledger` (unblocks points usage) → `discount_pct` (unblocks coupon usage, already flagged as its own follow-up candidate in `600714_ChangeContract.md` §6.1).

## 3. Cursor Independent Verification (§39/§40)

Per this workpacket's standard "3중 검토" procedure (`000701` §40.1), the same verification scope was dispatched to Cursor (official, binding) in parallel; Antigravity also received the same dispatch as a reference-only, non-binding parallel run. This document's §1-§2 above is Claude Code's own independent re-derivation. As with `600446_Verification.md`, this document does not have direct access to Cursor's or Antigravity's raw output — only confirmation that the same scope was dispatched.

## Scenario Summary

| Scenario | Result |
|---|---|
| Live function = source | PASS |
| `600440` preservation | PASS |
| Checksum integrity | PASS |
| Boundary (only `place_takeout_order()` changed) | PASS |
| Record-unassigned crash class, all 4 required paths (Groups 1-4) | PASS — eliminated |
| A안 point policy (Group 5) | PASS — logging call verified in isolation, order flow continues |
| Points regression (Group 6) | Fails on unrelated `point_ledger` defect, not record-unassigned |
| `chk_session_type` | New finding — blocks 3 of 6 tested paths |
| `discount_pct` | Re-confirmed, scope corrected (affects guest+coupon too, not just member+coupon) |
