# 600416_Verification.md

Status: Verified
Lifecycle: Verification
Stage: 5
Owner: Claude + Cursor (§35/§36 dual verification)
Date: 2026-07-13

## Verification Result

Final result: PASS (both independent verification passes).

## 1. Claude Code Stage 5 — Independent Re-Verification

Codex's self-report was not trusted at face value; everything below was re-derived directly.

| Check | Result |
|---|---|
| `0151.sql` read in full, `array_agg(distinct ... order by ...)` syntax tested directly against live Postgres | PASS — `{a,b,UNASSIGNED}` returned correctly for a `(a, NULL, b, a)` input set |
| Live `pg_get_functiondef()` vs. source file body | PASS — statement-for-statement identical |
| `§1` (multi-zone), `§1.1` (GRILL boundary overload), `§1.2` (`UNASSIGNED` group), `§2` (`release_kds_after_payment()` re-run) re-executed independently inside a transaction, rolled back after | All 4 PASS. Notably `§1.2` returned `UNASSIGNED{cooking_count: 8, capacity_ok: false}` — proving the null-zone group is actually counted (not silently zero, which is exactly the failure mode the design was built to avoid). `§2` failed at `chk_kds_status` exactly as predicted — one step further than before this change (previously failed at `check_kds_capacity() does not exist`). |
| Boundary: `evaluate_kds_capacity()` (`0028`), `0098`, `0099`, `0106`, `0016`, `0029` | PASS — `git diff --stat` empty for all six files |
| `0081`/`0108`/`0116` checksum re-computation vs. `catchmenu_meta.migration_history` | PASS — all three matched exactly |

## 2. Cursor Independent Design Re-Verification (§36) — 2 Discrepancies Found

Cursor's Eyes-Only re-verification of the design/implementation pair found 2 items that Claude Code's Stage 5 pass had not flagged:

1. **`sync_checksums_lf.sql` contains stale (pre-2026-07-11-fix) checksums for `0081`/`0108`/`0116`.** Re-confirmed directly: the file's `UPDATE` statements carry checksum values that do **not** match the values currently recorded in `catchmenu_meta.migration_history` (which this Stage 5 pass just independently verified as correct). If this file were ever executed, it would overwrite the correct checksums with stale ones. No functional/live impact today since the file was never re-run after the `0081`/`0108`/`0116` fixes — but it is a live hazard sitting in the repo. See `600417_Audit.md` Open Item (a).
2. **`0151`'s zone-list query has no `kds_status` filter**, unlike the design description in `600413_TestPlan.md` §0 which states the zone list is derived "consistently with `evaluate_kds_capacity()`'s active-ticket criteria." The actual `0151.sql` query is `select array_agg(...) from kds_tickets where store_id = ... and tenant_id = ...` — no `kds_status not in (...)` clause. This means completed/cancelled tickets' zones remain in the zone list indefinitely (an inefficiency — extra loop iterations calling `evaluate_kds_capacity()` for zones that may have no more active tickets — but each such call would correctly return `cooking_count: 0, capacity_ok: true` for a zone with no active tickets, so **result accuracy is not affected**, only efficiency). This is also a documentation/implementation mismatch: `600413_TestPlan.md` §0 describes a filter that the shipped code does not actually have. See `600417_Audit.md` Open Item (b).

## Scenario Summary

| Scenario | Result |
|---|---|
| `array_agg` DISTINCT/ORDER BY syntax | PASS |
| Live function = source | PASS |
| §1 / §1.1 / §1.2 / §2 independent re-execution | PASS (4/4) |
| Boundary (6 files untouched) | PASS |
| `0081`/`0108`/`0116` checksum accuracy | PASS |
| `sync_checksums_lf.sql` staleness (Cursor) | **FOUND — carried to Open Items, no functional impact today** |
| `0151` zone-list missing `kds_status` filter (Cursor) | **FOUND — inefficiency only, result accuracy unaffected, carried to Open Items** |
