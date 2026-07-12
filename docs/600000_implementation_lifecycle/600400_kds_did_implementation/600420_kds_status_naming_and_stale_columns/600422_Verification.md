# 600422_Verification.md

Status: Verified
Lifecycle: Verification
Stage: 5
Owner: Claude + Cursor (§35 dual verification)
Date: 2026-07-13

## Verification Result

Final result: PASS (both independent verification passes) for the specific `is_late`/`priority`/`kds_capacity_threshold_per_zone` fix. See Open Items in `600423_Audit.md` for issues found outside this fix's scope.

## 1. Claude Code Stage 5 — Independent Re-Verification

Codex's self-report was not trusted at face value.

| Check | Result |
|---|---|
| `git diff` read in full for `0099` | PASS — exactly the 3 column/naming fixes described, applied consistently across 4 locations (3 in `get_kds_realtime_state()`, 1 in `get_staff_alert_feed()`) |
| Live `pg_get_functiondef()` vs. source, for both `get_kds_realtime_state()` and `get_staff_alert_feed()` | PASS — occurrence counts of the strict `is_late` expression matched exactly (3 + 1) between source and live; `kds_capacity_threshold_per_zone` and `kt.priority`/`priority asc` present in live body |
| `0099` checksum vs. `catchmenu_meta.migration_history` | PASS — recomputed hash matched exactly, confirming the live function was actually re-executed (not a checksum-only update) |
| 3 scenarios reproduced independently (transaction + rollback): `estimated_minutes_snapshot = 999` (not late), `= NULL` (not late, guarded), 1-minute-elapsed (late) | PASS — `is_late` values `false / false / true`, `late_count = 1`, matching expected results exactly |
| `check_kds_capacity()` call site / `kds_status` filter logic in `0099` | PASS — confirmed absent from the diff, unmodified |
| **Caveat found during this pass**: full end-to-end RPC calls to `get_kds_realtime_state()` and `get_staff_alert_feed()` fail before returning, on 2 defects unrelated to this fix (`orders.request_memo` does not exist; `reconciliation_cases.case_severity` does not exist and `'INVESTIGATING'` is not a valid `case_status`). The 3-scenario reproduction above was therefore done via a raw query isolating the `is_late` expression, not via the full RPC. See `600423_Audit.md` Open Item (a). | Recorded, not blocking this fix's PASS |

## 2. Cursor Independent Re-Verification

1. **NULL handling** — confirmed `estimated_minutes_snapshot is not null` correctly guards the expression; a ticket with `NULL` never evaluates as late regardless of how much time has passed.
2. **`estimated_minutes_snapshot = 0` boundary** — confirmed the formula reduces to `committed_at < now()`, i.e. a ticket becomes late immediately once committed, with no grace period. This is a direct, correct consequence of the formula for a zero-minute estimate (not a special-cased branch, not a defect) — items genuinely expected to be immediately ready (e.g., pre-made items) would correctly show as "late" the instant they are not served, which is a product-logic question, not a code-correctness one.
3. **`priority` sort direction** — confirmed `order by priority asc` is consistent with `chk_kds_priority` (`1`–`10`, default `5`) under the "lower number = more urgent" convention; no comment in `0016` states this explicitly, so this is an inferred-but-unchallenged convention, not independently provable from schema comments alone.
4. **`priority_score` not referenced by the Flutter client** — `grep -rn "priority_score|is_late|kds_capacity_threshold_per_station" catchmenu_app/lib/` returns 0 matches (independently re-confirmed by Claude Code as well) — the rename introduces no client-side breakage. Note: the Flutter client does not currently consume this RPC's response at all (per `600200` module scope), so this check is precautionary rather than urgent.

## Scenario Summary

| Scenario | Result |
|---|---|
| `is_late`, `= 999` (not late) | PASS |
| `is_late`, `= NULL` (not late, guarded) | PASS |
| `is_late`, 1-minute elapsed (late) | PASS |
| `is_late`, `= 0` boundary (immediately late) | PASS (Cursor) |
| `late_count` aggregate | PASS |
| `priority` sort direction convention | PASS (inferred, not schema-documented) |
| Live = source (occurrence-count match) | PASS |
| Checksum sync (live re-executed, not checksum-only) | PASS |
| `priority_score` absent from Flutter client | PASS |
| Full RPC end-to-end execution | **BLOCKED by 2 unrelated pre-existing defects — out of this fix's scope, carried to Open Items** |
