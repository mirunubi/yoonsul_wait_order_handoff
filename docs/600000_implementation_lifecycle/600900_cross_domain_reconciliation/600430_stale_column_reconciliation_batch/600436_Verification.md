# 600436_Verification.md

Status: Verified
Lifecycle: Verification
Stage: 5
Owner: Claude + Cursor (§35 dual verification)
Date: 2026-07-13

## Verification Result

Final result: PASS (both independent verification passes).

## 1. Claude Code Stage 5 — Independent Re-Verification

Codex's self-report was not trusted at face value; everything below was re-derived directly against the local Supabase Docker container (`docker exec -i supabase_db_yoonsul_wait_order_handoff psql -U postgres -d postgres`) — no cloud credentials involved, since this batch was never pushed to the cloud project.

| Check | Result |
|---|---|
| All 10 file diffs read in full (`git diff`) against the approved 3 replacement families + A안 output-key unification | PASS — every substitution matches `600434_ChangeContract.md` §2 exactly; `0109` L878 and `gap_amount`/`layer_number`/`amount_difference`/`case_description` confirmed absent from all 10 diffs |
| Live `pg_get_functiondef()` vs. source, for `place_takeout_order()`, `track_takeout_order()`, `get_kds_realtime_state()`, `get_staff_alert_feed()` | PASS — statement-for-statement identical (comment/formatting differences only: Postgres header canonicalization and a `docker exec > file` redirect encoding artifact on 2 Korean string literals, confirmed cosmetic via `client_encoding`/`server_encoding` both `UTF8`) |
| **Race condition independently caught mid-verification**: first `pg_get_functiondef()` dump of `get_kds_realtime_state()` showed the live output key still as `'request_memo'` while the source file had just been updated to `'memo'` (the A안 extension to `0099`, applied by Codex concurrently with this verification pass) | **Live≠source caught at that instant** — re-snapshotted both source and live fresh immediately after; final state confirmed fully consistent (`'memo'` in both). Demonstrates the value of re-fetching fresh state rather than trusting a single snapshot when verification and implementation can run concurrently. |
| Checksum re-computation (SHA-256, CRLF-normalized) for all 10 files vs. `catchmenu_meta.migration_history` | PASS — all 10 matched exactly, all `success = true` |
| §3 — `0099`'s prior `600420` repairs (`is_late`, `priority`, `kds_capacity_threshold_per_zone`) preserved | PASS — reproduced via a fresh boolean query directly against the live function definition (not reusing Codex's reported query), all 3 plus this batch's `no_stale_request_memo_column`/`has_memo_output_key` checks returned `true` |
| §4 — `get_staff_alert_feed()` `UNDER_INVESTIGATION`+`CRITICAL` fixture test | PASS — inserted a real fixture row (via the live `chk_recon_severity`/`chk_recon_layer`/`chk_recon_case_status` constraints, corrected after an initial invalid-value attempt) inside a rolled-back transaction; `critical_recon_cases: 1` returned, confirming the row is no longer silently excluded by the old `'INVESTIGATING'` string-literal filter |
| §4 — out-of-scope stop points for `place_takeout_order()`, `health_check()`, `get_reconciliation_report()` | All 3 reproduced independently, all confirmed out of this batch's scope (see §1.1 below) |
| §5 — boundary: `0015`/`0121` untouched, `gap_amount`/`layer_number`/`amount_difference`/`case_description` untouched | PASS — `git status --short` empty for `0015`/`0121`; diffs confirmed clean of the 4 excluded identifiers |
| §5 — `DROP FUNCTION` blast radius | PASS — live `pg_proc.prosrc` scan across all `catchmenu_%` schemas for any function body calling `place_takeout_order(` other than its own definition returned 0 rows (stronger evidence than source-level `grep` alone) |

### 1.1 Out-of-Scope Stop Points — Reproduced, Not Regressions

- `catchmenu_payment.get_reconciliation_report(...)` (0084, 4-param overload, called via named parameters to disambiguate from the 5-param overload): fails with `column "layer_number" does not exist` — the query's `case_severity`/`case_status` handling (this batch's scope) executes correctly first, confirmed via the error `CONTEXT` showing `severity`/`UNDER_INVESTIGATION` already substituted; failure occurs strictly on the pre-existing, explicitly out-of-scope `layer_number` reference.
- `catchmenu_common.health_check()` (0092): fails with `relation "pg_temp.health_check_items" does not exist`. Root cause confirmed by reading source (0092 L1052-comment): the backing temp table is created only by a top-level `CREATE TEMP TABLE IF NOT EXISTS` statement in the migration script itself (executed once, at migration-apply time), not inside `health_check()` or `add_health_check_item()` — so any fresh session invoking these functions will hit this every time. Structural, session-lifetime defect, unrelated to this batch's substitutions. **Newly identified this workpacket** (not previously documented).
- `catchmenu_store.place_takeout_order(...)` (0081, called with a real menu item and the renamed `p_memo` parameter, which bound successfully with no parameter-name error): fails with `record "v_customer"`/`"v_coupon" is not assigned yet` depending on which optional argument (`p_customer_id`, `p_coupon_issue_id`) is omitted — a pre-existing conditional-record-assignment defect in the optional customer/coupon code paths, unrelated to `memo`. **Newly identified this workpacket** (not previously documented).

## 2. Cursor Independent Verification (§35)

Per Human report: Cursor independently ran the equivalent of §2-§4 (live=source comparison, `0099`'s prior `600420` preservation, TestPlan scenario reproduction) against the same local container and reported PASS on all three. This Verification document's §1 above is Claude Code's own independent re-derivation, not a restatement of Cursor's run — the two passes were not shown each other's intermediate results before completion. Unlike `600416_Verification.md` (where Cursor's pass surfaced 2 discrepancies Claude Code's pass had missed), this round's raw Cursor output/transcript was not available to this Verification document at authoring time — only the Human's summary confirmation that Cursor's §2-§4 passed. This is recorded as a fact about this Verification's evidentiary basis, not asserted as a Cursor-authored finding.

## Scenario Summary

| Scenario | Result |
|---|---|
| 10-file diff match against `600434_ChangeContract.md` | PASS |
| Live function = source (4 functions) | PASS (after re-snapshot; live/source race caught and resolved mid-verification) |
| `0099` prior `600420` repairs preserved | PASS |
| `get_staff_alert_feed()` `UNDER_INVESTIGATION`+`CRITICAL` fixture | PASS |
| `place_takeout_order`/`health_check`/`get_reconciliation_report` out-of-scope stop points | Reproduced, all confirmed unrelated to this batch (2 newly identified: `health_check()` temp-table lifetime, `place_takeout_order()` unassigned-record) |
| Boundary (`0015`/`0121`, 4 excluded identifiers, `DROP FUNCTION` blast radius) | PASS |
| Checksum accuracy (10 files) | PASS |
| Cursor independent pass (§2-§4) | PASS, per Human report (raw transcript not available to this document) |
