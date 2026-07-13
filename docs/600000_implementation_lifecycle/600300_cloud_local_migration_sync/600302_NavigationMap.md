# 600302_NavigationMap.md

Per `000701` §32 — single structured index, not a narrative log (`600301_ChangeHistory.md` owns "why"; this owns "what exists and what state"). One row per change.

| Change ID | Date | Tier | Status | Links |
|---|---|---|---|---|
| `initial_cloud_state_audit` | 2026-07-11/12 | Full (audit + replay + backfill, no separate Logic/TestPlan/ChangeContract — Human-executed cloud queries directly, see `600300_Readme` §In Scope) | **documented** | `600310_initial_cloud_state_audit/600311_Overview.md` |
| `scheduled_pull_based_secondary_backup` (`cloud_target_config.py` + `pull_secondary_backup.py`; BOM fix in `read_linked_project_ref()`; real `--execute` dump still pending) | 2026-07-13 | Full (Overview/Logic/TestPlan/ChangeContract/Module/Verification/Audit, 7 separate files) | **audited** (progression: drafted(1.5/2) → approved(3) → implemented(4) → verified(5, Codex self-check + Human 4 direct executions + Claude Code independent re-execution) → audited(6, ACCEPT), see `600301_ChangeHistory.md` 2026-07-13 항목) | `600320_scheduled_pull_based_secondary_backup/600321_Overview.md`, `600322_Logic.md`, `600323_TestPlan.md`, `600324_ChangeContract.md`, `600325_Module.md`, `600326_Verification.md`, `600327_Audit.md` |
