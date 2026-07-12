# 600401_ChangeHistory.md

Per `000701` §30 — single running file, append-only. One row per change.

| Date | Change Description | Reason/Evidence | Outcome | Linked Audit/Test |
|---|---|---|---|---|
| 2026-07-13 | `kds_capacity_gate_and_status_reconciliation`: created `catchmenu_kds.check_kds_capacity(p_tenant_id, p_store_id)` (`0151`), a zone-aware wrapper around existing `evaluate_kds_capacity()`, including `UNASSIGNED`(null `kitchen_zone`) handling | `check_kds_capacity()` was called by 8 files (3 as real runtime calls: `0098`/`0099`/`0106`) but never defined, causing "does not exist" failures; §0 defect-based document-linking principle applied (no design doc referenced this function) | ACCEPT — `600415_Module.md`(Stage 4)/`600416_Verification.md`(Stage 5, Claude Code + Cursor dual verification, `array_agg` syntax/live-source match/4 TestPlan scenarios/boundary all PASS)/`600417_Audit.md`(Stage 6) all complete. 2 minor Open Items carried forward (`sync_checksums_lf.sql` staleness — resolved by removal this same turn; `0151` zone-list missing `kds_status` filter — inefficiency only) | `600411`–`600417` (Overview/Logic/TestPlan/ChangeContract/Module/Verification/Audit) |
