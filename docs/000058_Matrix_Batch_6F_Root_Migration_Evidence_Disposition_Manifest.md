# 000058_Matrix_Batch_6F_Root_Migration_Evidence_Disposition_Manifest

Root migration evidence and worktree noise disposition manifest after six-digit docs migration closeout.
Planning and approval gate only. No staging, commit, delete, revert, rename, move, or content edit executed.

Reference commits: `c7663736` (Batch 6B), `15361afb` (Batch 6D), `968e635` (Batch 6E).
Baseline: canonical `docs/` six-digit tree committed; no docs migration files pending.

## Worktree Noise Summary

| Category | Count | GitState | RecommendedBatch |
| --- | ---: | --- | --- |
| `.gitignore` modified | 1 | Tracked modified | 6F-1 |
| `migration_*` tracked modified | 15 | Tracked modified | 6F-1 |
| `migration_*` tracked unchanged | 101 | Tracked clean | No action |
| `migration_*` untracked | 5 | Untracked | 6F-2 |
| `directory_only_tree.txt` | 1 | Untracked | 6F-3 |
| `sop/` | 14 files | Untracked | 6F-4 |

## Classification Legend

| Classification | Meaning |
| --- | --- |
| `worktree_noise_revert_to_head` | Uncommitted drift; restore committed version to clear worktree noise |
| `gitignore_sop_unignore_hold` | `.gitignore` change removes `sop/` ignore entry; requires explicit user decision |
| `untracked_evidence_add_candidate` | Optional commit as root migration evidence archive |
| `untracked_evidence_delete_candidate` | Optional delete; superseded by committed Batch 5A–6E audit trail in `docs/` |
| `temp_artifact_stale_delete_candidate` | Stale generated tree listing; safe delete after approval |
| `sop_lane_gitignore_restore_hold` | Keep `sop/` local-only via restored `.gitignore` entry (recommended) |
| `no_action_required` | Tracked clean; leave as historical evidence |

## Human Approval Gate

**STOP — no staging, commit, delete, or revert until explicit approval.**

---

## Group A — `.gitignore` (1 item)

| Path | GitState | Classification | DiffSummary | RecommendedResolution | RequiresUserApproval | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| `.gitignore` | Tracked modified | `gitignore_sop_unignore_hold` | Removes `sop/` ignore line; trailing newline-only delta at EOF; diff shows prior `Set-Content` artifact | `Revert_To_HEAD` (restore `sop/` ignore) **or** `Commit_SOP_Unignore` (explicit opt-in) | Yes | Restoring HEAD re-hides untracked `sop/` from worktree noise. Do not commit without user decision. |

---

## Group B — Tracked `migration_*` modified (15 items)

All 15 files show **path-reference-only drift** (five-digit / legacy `docs/` paths updated to six-digit paths in JSON/MD evidence). No new migration execution implied. Net diff: 73 insertions, 73 deletions across 15 files.

| Path | GitState | Classification | RecommendedResolution | RequiresUserApproval | Notes |
| --- | --- | --- | --- | --- | --- |
| `migration_direct_md_rename_heading_folder_placement_report.json` | Tracked modified | `worktree_noise_revert_to_head` | `Revert_To_HEAD` | Yes | Path refs only |
| `migration_direct_md_rename_heading_folder_placement_report.md` | Tracked modified | `worktree_noise_revert_to_head` | `Revert_To_HEAD` | Yes | Path refs only |
| `migration_final_critical_cleanup_pass_01_report.md` | Tracked modified | `worktree_noise_revert_to_head` | `Revert_To_HEAD` | Yes | Path refs only |
| `migration_final_docs_tree_validation_scan_02_report.json` | Tracked modified | `worktree_noise_revert_to_head` | `Revert_To_HEAD` | Yes | Path refs only |
| `migration_final_docs_tree_validation_scan_03_report.json` | Tracked modified | `worktree_noise_revert_to_head` | `Revert_To_HEAD` | Yes | Path refs only |
| `migration_final_docs_tree_validation_scan_report.json` | Tracked modified | `worktree_noise_revert_to_head` | `Revert_To_HEAD` | Yes | Path refs only |
| `migration_final_docs_tree_validation_scan_report.md` | Tracked modified | `worktree_noise_revert_to_head` | `Revert_To_HEAD` | Yes | Path refs only |
| `migration_high_confidence_doctype_prefix_wave_02_report.json` | Tracked modified | `worktree_noise_revert_to_head` | `Revert_To_HEAD` | Yes | Path refs only |
| `migration_high_confidence_doctype_prefix_wave_03_report.json` | Tracked modified | `worktree_noise_revert_to_head` | `Revert_To_HEAD` | Yes | Path refs only |
| `migration_high_confidence_doctype_prefix_wave_03_report.md` | Tracked modified | `worktree_noise_revert_to_head` | `Revert_To_HEAD` | Yes | Path refs only |
| `migration_precleanup_type_review_report.json` | Tracked modified | `worktree_noise_revert_to_head` | `Revert_To_HEAD` | Yes | Path refs only |
| `migration_precleanup_type_review_report.md` | Tracked modified | `worktree_noise_revert_to_head` | `Revert_To_HEAD` | Yes | Path refs only |
| `migration_root_markdown_normalization_and_placement_wave_01_report.json` | Tracked modified | `worktree_noise_revert_to_head` | `Revert_To_HEAD` | Yes | Path refs only |
| `migration_root_non_exception_folder_move_pass_01_report.json` | Tracked modified | `worktree_noise_revert_to_head` | `Revert_To_HEAD` | Yes | Path refs only |
| `migration_root_non_exception_folder_move_pass_01_report.md` | Tracked modified | `worktree_noise_revert_to_head` | `Revert_To_HEAD` | Yes | Path refs only |

**Alternative (not recommended for worktree noise gate):** `Commit_Evidence_Path_Refresh` — stage all 15 as a single evidence refresh commit. Superseded audit trail already lives in `docs/000038`–`docs/000055`.

---

## Group C — Tracked `migration_*` clean (101 items)

| PathPattern | Count | GitState | Classification | RecommendedResolution |
| --- | ---: | --- | --- | --- |
| `migration_*` (all other tracked) | 101 | Tracked clean | `no_action_required` | `Leave_As_Committed_Historical_Evidence` |

Representative prefixes: `migration_duplicate_prefix_*`, `migration_folder_*`, `migration_final_*` (unmodified), `migration_high_confidence_*` (unmodified), `migration_precleanup_*` (unmodified except type_review), `migration_root_*` (unmodified except noted), `migration_long_path_*`, `migration_medium_*`, `migration_low_*`.

---

## Group D — Untracked `migration_*` (5 items)

| Path | GitState | Classification | RecommendedResolution | RequiresUserApproval | Notes |
| --- | --- | --- | --- | --- | --- |
| `migration_folder_20000_security_archive_disposition_plan.json` | Untracked | `untracked_evidence_add_candidate` | `Add_To_Evidence_Archive_Commit` **or** `Delete_Untracked` | Yes | Pre-six-digit path references; superseded by committed docs migration batches |
| `migration_folder_20000_security_archive_disposition_plan.md` | Untracked | `untracked_evidence_add_candidate` | `Add_To_Evidence_Archive_Commit` **or** `Delete_Untracked` | Yes | Same |
| `migration_manifest_md_naming_prefix.json` | Untracked | `untracked_evidence_add_candidate` | `Add_To_Evidence_Archive_Commit` **or** `Delete_Untracked` | Yes | Pre-Batch-5A dry-run manifest; superseded by `docs/000039` |
| `migration_manifest_md_naming_prefix.md` | Untracked | `untracked_evidence_add_candidate` | `Add_To_Evidence_Archive_Commit` **or** `Delete_Untracked` | Yes | Same |
| `migration_precleanup_execution_plan.md` | Untracked | `untracked_evidence_add_candidate` | `Add_To_Evidence_Archive_Commit` **or** `Delete_Untracked` | Yes | Pre-six-digit execution plan; historical only |

---

## Group E — Temp artifact (1 item)

| Path | GitState | Classification | SizeBytes | RecommendedResolution | RequiresUserApproval | Notes |
| --- | --- | --- | ---: | --- | --- | --- |
| `directory_only_tree.txt` | Untracked | `temp_artifact_stale_delete_candidate` | 2835 | `Delete_Untracked` | Yes | Lists legacy five-digit `docs/` tree removed in Batch 6C-1/5F-1; stale |

---

## Group F — `sop/` lane (14 files)

| Path | GitState | Classification | RecommendedResolution | RequiresUserApproval | Notes |
| --- | --- | --- | --- | --- | --- |
| `sop/` (entire tree, 14 files) | Untracked | `sop_lane_gitignore_restore_hold` | `Revert_gitignore_To_HEAD` (re-ignore `sop/`) **or** `Move_To_Dedicated_SOP_Repo_Later` | Yes | Operational SOP content; not part of docs six-digit migration. Batch 5F flagged related root docs for SOP lane. |

File list: `sop/00000_SOP_Readme.md`, `sop/00005_SOP_Number_Index.md`, `sop/000010_operation/00010_SOP_Operation_Readme.md`, `sop/000010_operation/00300_SOP_Entrance_Waiting_Assist_Device_Operation.md`, `sop/050000_system/50000_SOP_System_Readme.md`, `sop/sop_2026-06-14_*.md` (9 recipe/operation SOP files).

---

## Recommended Execution Batches (Post-Approval)

| Batch | Scope | Action |
| --- | --- | --- |
| **6F-1** | `.gitignore` + 15 modified `migration_*` | `git checkout -- .gitignore migration_*` (revert worktree noise only) |
| **6F-2** | 5 untracked `migration_*` | User choice: delete **or** single evidence archive commit |
| **6F-3** | `directory_only_tree.txt` | Delete untracked file |
| **6F-4** | `sop/` visibility | Restore `sop/` in `.gitignore` (included in 6F-1 if revert chosen) |

## Out Of Scope (Unchanged)

| Item | Disposition |
| --- | --- |
| `docs/` canonical six-digit tree | Committed — no action |
| Canonical `Delete_Candidate_Later` mobile-draft policies | Batch 5F-2 hold |
| Batch 6F manifest itself (`000058`) | Commit in Batch 6G after approval |

## Closeout Judgment (Planning)

| Field | Value |
| --- | --- |
| Worktree noise source | Uncommitted `.gitignore` drift + post-migration path-reference edits in 15 root migration evidence files |
| Docs migration status | Closed in git (`Closed_With_ManualReview_Hold` for canonical mobile-draft policies) |
| Recommended first action | **6F-1 revert** to restore clean `git status` without touching `docs/` |
