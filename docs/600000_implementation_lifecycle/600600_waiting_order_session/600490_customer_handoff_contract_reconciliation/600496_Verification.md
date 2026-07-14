# 600496_Verification.md

Status: Verified (final — Cursor result received, see §3)
Lifecycle: Verification
Stage: 5
Owner: Claude Code + Antigravity + Codex self-check + Cursor (official, binding)
Date: 2026-07-14

## Verification Result

PASS for the approved scope (both Correction items). Three-way independent verification (Claude Code, Antigravity, Codex self-check) plus Cursor's official, binding result (`000701` §39/§40) all agree: live=source match for both functions, Test A/B PASS, `600420` preservation confirmed, `600494_ChangeContract.md` §6.1's predicted blocker reproduced consistently, boundary clean. `600497_Audit.md`'s status is now final.

## 1. Claude Code Stage 5 — Independent Re-Verification

Nothing below was assumed from Codex's or Antigravity's reports; each item was independently re-derived against the local Supabase Docker container, using fresh test data distinct from what was used when the fix was designed.

| Check | Result |
|---|---|
| `0099`/`0115` checksum integrity | PASS — both SHA-256 (CRLF-normalized) match `catchmenu_meta.migration_history` exactly, `success = true`. |
| `0099`/`0115` live = source (`pg_get_functiondef`) | PASS — both function bodies match source exactly. |
| `0099` boundary — only `get_waiting_realtime_state()` touched | PASS — diff hunks (`@@ -609,7` / `@@ -730,14`) confined to that function's line range (580-756); `get_kds_realtime_state()`/`get_staff_alert_feed()`/`broadcast_store_event()` byte-identical. |
| `0115` boundary — only the `kds_tickets` INSERT touched | PASS — the `orders`/`order_items` INSERTs in the same function are unchanged (confirmed both via diff and via reproduction, see below). |
| `600420`'s prior fix (`is_late`/`kds_capacity_threshold_per_zone`) preserved in `0099` | PASS — 0 occurrences of stale `priority_score`/`kds_capacity_threshold_per_station` remain. |
| Test A — `kds_tickets` INSERT correction, re-run with **new** data (menu `참치김밥`, quantity 2, new order/correlation id) | PASS — succeeded cleanly, returned `ticket_number = 'W-REVERIFY-600495-2-01'`, `kds_status = 'HOLD'`. |
| Test B — `get_waiting_realtime_state()` progress, re-run against the **real, live** function (no simulation/patch needed this time — the fix is now actually implemented) | PASS — `max_wait_number`-related error is gone; function now fails precisely at `os.arrival_confirmed_at` (the next, still-open drift), confirming genuine forward progress, not a full fix. |
| `pre_order_while_waiting()` still fails at `order_source` first (per `600494_ChangeContract.md` §6.1's prediction), re-run with **new** data (different session, menu `051`, quantity 2, new correlation id) | PASS (confirms the predicted, still-open blocker) — identical `column "order_source" of relation "orders" does not exist` error, same statement, unaffected by the `kds_tickets` fix since execution never reaches that code. |

## 2. Antigravity + Codex — Reported Results (Prior To This Turn)

Per this workpacket's dispatch, Antigravity (reference-only observer, `000701` §40) and Codex (self-check on its own implementation) both reported **ACCEPT** before this document was written. This document does not have direct access to their raw output — only confirmation that both were dispatched against the same scope (the two Correction items) and both returned ACCEPT, consistent with Claude Code's independent findings in §1.

## 3. Cursor — Official Result Received, Including One Finding That Did Not Survive Re-Verification

Per `000701` §39/§40, Cursor is the official, binding verifier in this project's standard "3중 검토" procedure. Cursor's report has now been received.

### 3.1 Findings That Agree With §1/§2 (Accepted Without Re-Verification)

Cursor independently confirmed: live=source match for both `0099`/`0115`, Test A/B PASS, `600420`'s prior fix preserved, `pre_order_while_waiting()`'s predicted `order_source` blocker reproduced, boundary clean. These match Claude Code's/Antigravity's/Codex's own findings in §1/§2 exactly — no disagreement, no re-verification performed for these specific items (consistent with this document's original policy: only re-verify where a disagreement or new claim appears).

### 3.2 Checksum Finding — Reported As A Mismatch, Re-Verified As A False Positive

Cursor's report separately flagged `0115`'s `migration_history.checksum` as stale, citing a specific alternate value (`c588014b...`) that allegedly did not match the source file's CRLF-normalized checksum. Per instruction, this specific claim was investigated **before being written into this document as fact** — per `000701` §37/§39's dual-verification principle, a verifier's report is evidence to check, not a conclusion to transcribe.

Three independent methods were used, all agreeing the reported mismatch **does not exist**:

1. **Direct recomputation**: `sed 's/\r$//' sql/migrations/0115_create_waiting_pipeline_rpc.sql | sha256sum` → `7eba4434...`, identical to the value recorded in `catchmenu_meta.migration_history`.
2. **Tool source inspection**: `tools/apply_migrations.py`'s `checksum()` function was read directly — `path.read_bytes().replace(b"\r\n", b"\n")` then `hashlib.sha256` — confirmed to be the exact same normalization method used in method 1, ruling out a normalization-mismatch explanation.
3. **Actual tool execution**: `python tools/apply_migrations.py` was run for real (not simulated) — output: `OK 0115_create_waiting_pipeline_rpc.sql (already applied, checksum matches)`, and all 153 sequence-numbered migrations passed with zero mismatches.

**No `UPDATE` was performed on `migration_history.checksum`** — none was needed, since the recorded value already matched. Had the `UPDATE` been executed on the basis of Cursor's reported value alone, it would have **overwritten a correct checksum with an incorrect one**, introducing the exact kind of drift this project's checksum-tracking system exists to prevent.

**This is recorded here explicitly as a positive case of the `000701` §37/§39 dual-verification principle working as intended**: a verifier (Cursor) flagged a finding, that finding was checked independently rather than transcribed on trust, and the check disproved it before it could cause harm. This is not a criticism of Cursor's overall report — the other findings in §3.1 were all confirmed correct — it is a record that the specific checksum claim, and only that claim, did not survive re-verification.

## Scenario Summary

| Scenario | Result |
|---|---|
| Checksum integrity (both files) | PASS — `0115`'s checksum additionally re-verified 3 independent ways after Cursor's mismatch report; reported mismatch not reproduced (§3.2) |
| Live = source (both functions) | PASS |
| Boundary (only the 2 approved statements) | PASS |
| `600420` preservation | PASS |
| Test A (`kds_tickets` fix, new data) | PASS |
| Test B (`get_waiting_realtime_state()` progress, real function) | PASS |
| `pre_order_while_waiting()` still blocked at `order_source` (expected, not a failure of this fix) | Confirmed, matches prediction |
| Antigravity | ACCEPT (reference-only) |
| Codex self-check | ACCEPT |
| **Cursor (official, binding)** | **ACCEPT** — checksum finding investigated and not confirmed (§3.2), all other findings agree with §1/§2 |
