# 600326_Verification.md

Status: Verified
Lifecycle: Verification
Stage: 5
Owner: Codex (self-check) + Human (4 direct executions) + Claude Code (independent re-execution)
Date: 2026-07-13

## Verification Result

Final result: PASS (Codex self-check + Human's 4 direct executions + Claude Code's independent re-execution of all 4, this turn).

## 1. Codex Self-Check

Reported: the project-ref mismatch safety guard (`confirm_linked_project_ref()`) correctly raises before any `supabase db dump` invocation when the linked ref does not match `EXPECTED_PROJECT_REF`. Not taken at face value — independently re-executed below (§3).

## 2. Human Direct Execution (4 scenarios, per `600323_TestPlan.md`)

1. **Dry-run** (`600323_TestPlan.md` §2) — PASS.
2. **Folder/log creation** — `E:\catchmenu_backups\` and `backup_log.txt` created and populated correctly — PASS.
3. **30-day retention boundary** (§5) — 35-day-old dummy file deleted, 29-day-old dummy file preserved — PASS.
4. **Windows Task Scheduler** create/query/delete (§6) — task registered, queried with correct next-run time, deleted cleanly — PASS.

## 3. Claude Code Independent Re-Execution (this turn)

Human's report was not trusted at face value; all 4 scenarios plus the BOM claim were re-derived directly against the real `E:\catchmenu_backups\` and the real (temporarily forged, then reverted) `supabase/.temp/project-ref`.

| Check | Result |
|---|---|
| BOM presence in `supabase/.temp/project-ref` | PASS — `xxd`/raw-byte read confirmed `EF BB BF` prefix before the ref text; confirmed a plain `.strip()` (no BOM-lstrip) would NOT match `EXPECTED_PROJECT_REF`, and the shipped `.lstrip("﻿").strip()` fix does match. |
| Dry-run (`python tools\pull_secondary_backup.py --dry-run`) | PASS — exit code 0, `linked_project_ref` = `expected_project_ref` = `upzthfwhtvazfftxnyfu`, `backup_log.txt` appended with `status=OK\|mode=DRY_RUN`. |
| Safety-guard REFUSED scenario (`600323_TestPlan.md` §3 procedure: forge `project-ref` → run → revert) | PASS — forged value confirmed written and read back before the run; script printed `REFUSED: linked Supabase project ref mismatch. expected='upzthfwhtvazfftxnyfu', actual='fake-wrong-project-ref-test'.`, exited non-zero (1), logged `status=REFUSED` with the message in `backup_log.txt`; `project-ref` confirmed correctly reverted to `upzthfwhtvazfftxnyfu` immediately after (first attempt with `-Encoding utf8NoBOM` failed to parse in this PowerShell version and silently wrote nothing — caught by checking the exit code and re-running with a supported encoding before drawing any conclusion). |
| 30-day retention boundary (§5), reproduced independently with fresh dummy files (not reusing Human's) | PASS — a 35-day-old dummy (`cloud_backup_dummy_old_verify.sql`) was deleted by `prune_old_backups(dry_run=False)`; a 29-day-old dummy (`cloud_backup_dummy_recent_verify.sql`) was preserved. Cleaned up after. |
| Task Scheduler create/query/delete (§6), independent task name `CatchMenu_CloudSecondaryBackup_VERIFY` | PASS — `schtasks /create` succeeded, `/query` showed `Ready` status with the correct next-run time (2026-07-14 03:00), `/delete` succeeded, and a subsequent `/query` on the same name correctly errored (`ERROR: The system cannot find the file specified.`), confirming the task no longer exists. |
| `cloud_target_config.py` constants vs. `apply_migrations_cloud.py`'s existing constants | PASS — read both files directly; `EXPECTED_PROJECT_REF`/`EXPECTED_HOST`/`EXPECTED_POOLER_USERNAME` values are character-identical. |
| Boundary: `apply_migrations_cloud.py` untouched | PASS — `git status --short` empty for this file throughout. |

## Scenario Summary

| Scenario | Codex | Human | Claude Code (independent) |
|---|---|---|---|
| BOM mismatch discovery/fix | found + fixed | — | re-derived: failure mode + fix both confirmed |
| Dry-run | — | PASS | PASS |
| Folder/log creation | — | PASS | PASS (log format matches design) |
| Safety guard (REFUSED on mismatch) | self-reported PASS | — | PASS, independently reproduced with forge-then-revert |
| 30-day retention boundary (35d/29d) | — | PASS | PASS, reproduced with fresh dummy files |
| Task Scheduler create/query/delete | — | PASS | PASS, reproduced with an independent task name |
| `cloud_target_config.py` value parity | — | — | PASS |
