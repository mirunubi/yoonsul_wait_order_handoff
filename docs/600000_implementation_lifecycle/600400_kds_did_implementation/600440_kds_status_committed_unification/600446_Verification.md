# 600446_Verification.md

Status: Verified
Lifecycle: Verification
Stage: 5
Owner: Claude + Cursor (§39 mandatory dual verification)
Date: 2026-07-13

## Verification Result

Final result: PASS (Claude Code independent pass + Cursor independent pass, both required per `000701` §39).

## 1. Claude Code Stage 5 — Independent Re-Verification

Codex's self-report was not trusted at face value; everything below was re-derived directly against the local Supabase Docker container.

| Check | Result |
|---|---|
| All 13 file diffs read in full (`git diff`) | PASS — 46 insertions/46 deletions total, matching exactly 2× the planned 46-occurrence count; zero residual `READY_TO_COMMIT` across all 13 files (`grep -c` per file). |
| Live `pg_get_functiondef()` vs. source for `bootstrap_app()`, `bootstrap_kds_app()`, `track_takeout_order()` | PASS — statement-for-statement identical (formatting/tag differences only). |
| `0070` base+wrapper: both functions actually updated together | PASS — confirmed via diff (both `bootstrap_app()` L292/L301 and `bootstrap_kds_app()` L586-equivalent changed in the same commit-worthy diff). |
| `0028`/`0039` pairing: `commit_kds_ticket()`'s return value correctly parsed by `bulk_commit_kds_tickets()` | PASS — diff shows both L275 (`0028`) and L80/L97 (`0039`) changed together. |
| `0070`/`0081` checksum mismatch: is the underlying live state actually safe? | **Independently investigated, not assumed** — recomputed both files' checksums, confirmed they differed from `migration_history`, then directly `pg_get_functiondef()`-verified the 3 target functions were byte-identical to current source despite the stale checksum. Conclusion: safe (live already correct), but the bookkeeping gap was real and needed fixing before the next `apply_migrations.py` run — not merely a cosmetic mismatch to leave alone. |
| `bootstrap_staff_app()`/`get_customer_home()` failures: new or pre-existing? | **Directly reproduced and root-caused, not assumed unrelated** — see §2 below. |
| `600443_TestPlan.md` §1-§5 | All 5 reproduced independently, all PASS — see §3 below. |
| Checksum remediation + `apply_migrations.py` re-run | PASS — `UPDATE catchmenu_meta.migration_history` for `0070`/`0081` executed, then `python tools/apply_migrations.py` re-run end-to-end: `0070`/`0081` both report `(already applied, checksum matches)`, run continues cleanly through `0151`, ends `All sequence-numbered migrations applied or already up to date.`, exit code 0, no `FAIL`/`Stopping` line anywhere in the output. |

## 2. `bootstrap_staff_app()`/`get_customer_home()` — Root-Caused, Confirmed Pre-Existing and Unrelated

Both functions were called directly (not merely inspected) to observe their actual failure mode:

- **`bootstrap_staff_app()`** (`0070`, owned by that file, unrelated to this batch's `0070` edits which only touch `bootstrap_app()`/`bootstrap_kds_app()`): fails with `column "staff_name" does not exist`. Confirmed the function body (`0070` L718-887) contains zero `kds_status`/`COMMITTED` references. Further confirmed this is not a simple stale-column typo but a **substantial live/source divergence**: current source queries `staff_code, display_name, staff_role, authority_level, can_observe, can_override_kds, can_approve_refund, can_manage_menu, can_manage_staff, can_view_reports, can_change_store_mode`, while the live function still queries the older `staff_name, staff_role, staff_status, allowed_features` shape — this function appears to have never been re-executed since a prior source refactor.
- **`get_customer_home()`** (`0081`, unrelated to this batch's `0081` edits which only touch `track_takeout_order()`): fails with `column os.pre_order_amount does not exist`. Function body (`0081` L1153-1344) also has zero `kds_status`/`COMMITTED` references. Same pattern: current source implements a membership/points-focused home screen (`customers`, `point_ledger`, coupons), while the live function still implements an older waiting-queue-focused version (`order_sessions`, `wait_number`, `pre_order_amount`) — also apparently never redeployed since a prior rewrite.

**Conclusion**: both are genuine, likely long-standing defects, entirely unrelated to `kds_status`/`COMMITTED`, and not introduced or worsened by this workpacket. Flagged as new Open Items (`600447_Audit.md`) — not fixed here, per `000701` §0 (one defect at a time) and this ChangeContract's boundary.

## 3. `600443_TestPlan.md` §1-§5 — Full Reproduction

| Scenario | Result |
|---|---|
| §1.1 `chk_kds_status`: `'COMMITTED'` INSERT | PASS — succeeds, returns `kds_status = 'COMMITTED'`. |
| §1.2 `chk_kds_status`: `'READY_TO_COMMIT'` INSERT | PASS — fails with `violates check constraint "chk_kds_status"`, exactly as required. |
| §2 Partial index definitions | PASS — both `idx_kds_tickets_store_zone`/`idx_kds_tickets_device` predicates contain `'COMMITTED'`, zero `'READY_TO_COMMIT'`. |
| §3 `0028`↔`0039` pairing (3 dummy tickets: 2 fully-conditioned, 1 deliberately incomplete) | PASS — `bulk_commit_kds_tickets()` returned `committed_count: 2, pending_count: 1`; independent `SELECT ... GROUP BY kds_status` on the actual table confirmed the identical split (`COMMITTED` 2, `CAPACITY_CHECKING` 1) — self-report and real state agree. |
| §4.1 `0070` boolean pair-check | PASS — `base_still_stale = false`, `wrapper_still_stale = false`. |
| §4.2 `0070` functional test | PASS (after one iteration — first attempt used a non-registered `p_device_id` and correctly failed `device_not_found`; retried with a real `device_registry` row) — `bootstrap_kds_app()` returned `success: true`, both the indirect `v_base` path and the wrapper's own ticket query correctly included/labeled the `COMMITTED` dummy ticket. |
| §5 `0151` `UNASSIGNED` re-test with `COMMITTED` | PASS — 8 `COMMITTED` null-zone tickets → `cooking_count: 8, capacity_ok: false, is_overloaded: true`, exactly reproducing today's established `600413_TestPlan.md` §1.2 pattern with the new status value. |

## 4. Cursor Independent Verification (§39)

Per Human report, Cursor independently reviewed the same scope (13-file diff, checksum safety judgment) and reached the same conclusion: `0070`/`0081` checksum mismatch is safe to resolve via checksum-only update, no live re-execution needed. This Verification document's §1-§3 above is Claude Code's own independent re-derivation — as with `600916_Verification.md`, this document does not have direct access to Cursor's raw report text, only the Human-relayed agreement on the checksum-safety conclusion.

## Scenario Summary

| Scenario | Result |
|---|---|
| 13-file diff correctness | PASS |
| Live function = source (3 functions directly checked) | PASS |
| `0070`/`0081` checksum safety judgment | PASS (independently investigated) + Cursor agreement |
| `bootstrap_staff_app()`/`get_customer_home()` cause | Root-caused: pre-existing, unrelated, substantial live/source drift |
| TestPlan §1-§5 | PASS (5/5) |
| Checksum remediation + `apply_migrations.py` re-run | PASS, exit code 0, clean through `0151` |
