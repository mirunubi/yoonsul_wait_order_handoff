# 600616_Verification.md

Status: Verified
Lifecycle: Verification
Stage: 5
Owner: Claude + Cursor (§39/§40 dual verification, Antigravity parallel reference-only per §40.1 "3중 검토")
Date: 2026-07-13

## Verification Result

Final result: PASS for the approved scope (6-point `'ONLINE'`→`'TAKEOUT'` unification, both files). One **separate, newly-discovered, out-of-scope** defect (`requested_pickup_at`) confirmed to block full end-to-end success on the very path this fix was meant to unblock — not a regression from this fix.

## 1. Claude Code Stage 5 — Independent Re-Verification

Nothing below was assumed from Codex's implementation report; each item was independently re-derived against the local Supabase Docker container.

| Check | Result |
|---|---|
| 6-point diff, live vs. source (`pg_get_functiondef`) | PASS — all 6 points present live: `0081` L303 (`'TAKEOUT', 'ORDER_CONFIRMED'`); `0063` L18 (validation array), L118/149/179/222 (4x `when 'TAKEOUT' then 'ORDERING'`). |
| Residual `'ONLINE'` literal count, both live function bodies | PASS — 0 in each. |
| Checksum integrity, both files | PASS — SHA-256 (CRLF-normalized) matches `catchmenu_meta.migration_history` exactly for `0081` and `0063`, `success = true`, no drift. |
| Boundary — only the two approved functions/locations changed | PASS — `0025` unmodified; `0063`'s `DELIVERY`-branch omission and `WALK_IN` mismatch confirmed still present, untouched. |
| `600710` 11-point scalar-variable preservation inside `place_takeout_order()` | PASS — 0 live `v_customer.`/`v_coupon.` dot-access remains inside the function's actual boundary (L504-1026); `v_customer record` found at two OTHER, unrelated functions (`bootstrap_customer_app()` L207-503, `get_customer_home()` L1197-1390) — confirmed out of `600710`'s and this workpacket's scope, not contamination. |
| `0081` DROP→CREATE signature match | PASS — `drop function if exists` signature (11 params) matches the `create or replace` signature exactly; single live overload confirmed (`count(*) = 1`). |
| `EXECUTE` grant survival after DROP→CREATE | PASS — `authenticated`/`postgres` EXECUTE confirmed live via schema default privileges. |
| **Test B** — `create_order_session()` 2nd overload accepts `'TAKEOUT'`, independently re-run (`correlation_id = verify-600615-testB-rerun`) | PASS — `order_sessions.session_status`, `session_events.to_status`, `ledger.events.to_state`, and RPC return `data.session_status` **all four** consistently `'ORDERING'`. |
| **Test C** — `create_order_session()` rejects `'ONLINE'` at function-level validation, independently re-run (`correlation_id = verify-600615-testC-rerun`) | PASS — rejected with `error_key: invalid_input` at the explicit `p_session_type not in (...)` check; not a `chk_session_type` table-constraint error. |
| **Test A** — `place_takeout_order()` reaches past `chk_session_type`, independently re-run (`correlation_id = verify-600615-testA-rerun`) | PASS on the approved PASS condition (no `chk_session_type`/`'ONLINE'` error) — execution reaches the `catchmenu_pos.orders` INSERT that follows the now-fixed session INSERT. **New finding**: that INSERT fails with `column "requested_pickup_at" of relation "orders" does not exist` (§2 below). |

## 2. New Defect Confirmed — `requested_pickup_at` (Urgent, Out Of Scope For This Workpacket)

Not a regression from this fix — an independently pre-existing, previously undiscovered defect, surfaced only now because this fix lets execution reach the code region where it lives (`catchmenu_pos.orders` INSERT, immediately after the session INSERT this workpacket fixed).

- **Exact live columns of `catchmenu_pos.orders`** (`information_schema.columns`, live, full 28-column list captured): no column named `requested_pickup_at`, and no column containing the substring `pickup` anywhere in the entire live schema (cross-schema search, 0 hits).
- **Not a rename/stale-column drift** (different category from `point_type`/`point_amount` or `case_severity`): those had a correctly-named real column under a different name. `requested_pickup_at` has **no equivalent under any name** — confirmed by the zero-hit `pickup` search across all tables. The identifier appears in exactly two places repo-wide: `0081`'s `place_takeout_order()` itself (parameter `p_requested_pickup_at` + the broken INSERT), and `0092` (Flutter client example text, non-executing documentation). Diagnosis: an unmigrated column — the RPC-level parameter and INSERT reference were written for a "customer-requested pickup time" feature, but the corresponding `ALTER TABLE catchmenu_pos.orders ADD COLUMN requested_pickup_at ...` migration was never authored.
- **Blast radius — broader than any single prior defect**: the failing INSERT is unconditional (not gated by any `if`), executing immediately after every successful session creation regardless of coupon/points branch. It therefore blocks **100% of call paths** that get past the session INSERT, unlike `point_ledger`/`discount_pct`, which are each specific to one input branch.
- **Reproduction**: `begin; select catchmenu_store.place_takeout_order(...); rollback;` — hard error, uncaught, transaction-aborting (`ERROR: column "requested_pickup_at" of relation "orders" does not exist`, followed by `current transaction is aborted, commands ignored until end of transaction block`). Same failure class (hard error, not silent undercount) as `chk_session_type`/`discount_pct`/`point_ledger`.

See `600404_PlaceTakeoutOrder_Defect_Roadmap.md` for this defect's position relative to the other three known blockers of `place_takeout_order()`.

## 3. Cursor Independent Verification (§39/§40)

Per `000701` §40.1 standard "3중 검토" procedure, the same verification scope (6-point diff, Test A/B/C, `600710` 11-point preservation check) was dispatched to Cursor (official, binding) in parallel; Antigravity received the same dispatch as reference-only, non-binding. As with prior workpackets in this series (`600446_Verification.md`, `600716_Verification.md`), this document does not have direct access to Cursor's or Antigravity's raw output — only confirmation that the same scope was dispatched under the standard procedure.

## Scenario Summary

| Scenario | Result |
|---|---|
| 6-point diff, live = source | PASS |
| Residual `'ONLINE'` | PASS — 0 |
| Checksum integrity (both files) | PASS |
| Boundary (only approved 2 functions/locations) | PASS |
| `600710` 11-point scalar preservation | PASS |
| DROP→CREATE signature/grant integrity | PASS |
| Test B (`TAKEOUT` accepted, 4-output consistency) | PASS |
| Test C (`ONLINE` rejected at function level) | PASS |
| Test A (`chk_session_type`/`ONLINE` error gone) | PASS |
| `place_takeout_order()` end-to-end completion | Fails — new, out-of-scope `requested_pickup_at` defect |
