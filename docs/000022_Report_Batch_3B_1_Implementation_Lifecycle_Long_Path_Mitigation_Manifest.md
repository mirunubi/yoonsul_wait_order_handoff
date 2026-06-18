# Report: Batch 3B-1 Implementation Lifecycle Long Path Mitigation Manifest

## Scope

This report is a planning and manifest artifact only.

- No folder rename was performed.
- No file move was performed.
- No file rename was performed.
- No delete was performed.
- No runtime implementation was created.
- No H1, body, or internal link update was performed.

## Reference Inputs

- `docs/000001_Md_Rules.md`
- `docs/000002_Naming_Rules.md`
- `docs/000005_Document_Number_Index.md`
- `docs/000007_Full_Directory_Map.md`
- `docs/000016_Report_Docs_Folder_File_Count_And_Number_Density_Audit.md`
- `docs/000017_Report_Docs_Six_Digit_Domain_Band_Redesign_v0_4_Plan.md`
- `docs/000018_Matrix_Current_To_Proposed_Domain_Folder_Mapping_v0_4.md`
- `docs/000019_Report_Batch_3A_High_Range_Implementation_Lifecycle_Planning_Manifest.md`
- `docs/000020_Matrix_Batch_3A_Implementation_Lifecycle_Move_Manifest.md`
- `docs/000021_Report_Batch_3B_High_Range_Implementation_Lifecycle_POS_Gateway_Package_Move.md`

## Long Path Risk Increase Cause

Batch 3B moved the POS Gateway runtime flow implementation package under a high-range implementation lifecycle parent:

`docs/600000_implementation_lifecycle/605000_pos_gateway_package/`

The move preserved file basenames and existing `012091` through `012099` subfolder names, which was correct for Batch 3B safety. However, the new parent folder is longer than the previous `docs/012000_implementation_mapping/012090_pos_gateway_runtime_flow_implementation_package/` path. As a result, Windows long path risk increased.

## Current Path Length Risk Summary

| Metric | Count |
|---|---:|
| POS Gateway Markdown files scanned | 316 |
| POS Gateway subfolders scanned | 9 |
| Current paths over 240 characters | 289 |
| Current paths over 260 characters | 181 |
| Current max path length | 305 |

## Recommended Shortened Target Names

| CurrentPath | ProposedPath | Recommendation |
|---|---|---|
| `docs/600000_implementation_lifecycle/` | `docs/600000_implementation_lifecycle/` | Rename in next execution batch. |
| `docs/600000_implementation_lifecycle/605000_pos_gateway_package/` | `docs/600000_implementation_lifecycle/605000_pos_gateway_package/` | Rename in next execution batch with the root folder. |

## Recommended High-Range Subfolder Shortening

| CurrentFolder | ProposedFolder |
|---|---|
| `600100_readme_governance/` | `600100_readme_governance/` |
| `601000_olm_model/` | `601000_olm_model/` |
| `602000_source_map/` | `602000_source_map/` |
| `603000_ai_handoff/` | `603000_ai_handoff/` |
| `604000_workpackets/` | `604000_workpackets/` |
| `606000_evidence_diff/` | `606000_evidence_diff/` |
| `607000_repair_closeout/` | `607000_repair_closeout/` |
| `608000_release_gate/` | `608000_release_gate/` |
| `609000_archive_review/` | `609000_archive_review/` |

## POS Gateway Subfolder Shortening Analysis

| CurrentFolder | ProposedFolder | Recommendation |
|---|---|---|
| `605100_core_flows/` | `605100_core_flows/` | Consider in the same execution batch if approved. |
| `605200_read_only_dry_run/` | `605200_read_only_dry_run/` | Consider in the same execution batch if approved. |
| `605300_authorization_execution/` | `605300_authorization_execution/` | Consider in the same execution batch if approved. |
| `605400_breach_hold/` | `605400_breach_hold/` | Consider in the same execution batch if approved. |
| `605500_future_hold_lift/` | `605500_future_hold_lift/` | Consider in the same execution batch if approved. |
| `605600_ticket_closeout/` | `605600_ticket_closeout/` | Consider in the same execution batch if approved. |
| `605700_repair_hold_lift/` | `605700_repair_hold_lift/` | Consider in the same execution batch if approved. |
| `605800_release_monitoring/` | `605800_release_monitoring/` | Consider in the same execution batch if approved. |
| `605900_final_closeout_archive/` | `605900_final_closeout_archive/` | Consider in the same execution batch if approved. |

## Estimated Length Reduction

If the root folder, package folder, and POS Gateway subfolders are shortened as proposed:

| Metric | Current | Proposed |
|---|---:|---:|
| Paths over 240 characters | 289 | 0 |
| Paths over 260 characters | 181 | 0 |
| Max path length | 305 | 221 |
| Average path length reduction | n/a | 82.8 characters |

## Rename Timing Recommendation

Recommended for the next execution batch:

- Rename the top-level `600000` implementation lifecycle folder.
- Rename the `605000` POS Gateway package folder.
- Rename the `012091` through `012099` package subfolders in the same batch if the user approves full mitigation.

Reason:

- Renaming only the two top-level folders reduces risk substantially but leaves some avoidable path length pressure.
- Renaming the POS Gateway subfolders at the same time eliminates the current over-240 and over-260 path risk candidates in the scanned package.
- All proposed names preserve six-digit prefixes.

## 000005 And 000007 Impact

The following files will need path reference updates in an execution batch:

- `docs/000005_Document_Number_Index.md`
- `docs/000007_Full_Directory_Map.md`
- `docs/000019_Report_Batch_3A_High_Range_Implementation_Lifecycle_Planning_Manifest.md`
- `docs/000020_Matrix_Batch_3A_Implementation_Lifecycle_Move_Manifest.md`
- `docs/000021_Report_Batch_3B_High_Range_Implementation_Lifecycle_POS_Gateway_Package_Move.md`
- `docs/000022_Report_Batch_3B_1_Implementation_Lifecycle_Long_Path_Mitigation_Manifest.md`
- `docs/000023_Matrix_Batch_3B_1_Long_Path_Mitigation_Rename_Manifest.md`

The execution batch should update only structural path references and should not rewrite general document prose.

## Rollback Note

This Batch 3B-1 work creates only planning artifacts, so rollback is limited to removing the two generated files if the mitigation plan is rejected.

For a future execution batch, use `git mv` with long path support and keep the batch limited to approved folder renames. Do not rename file basenames in the same batch.

## Next Batch Recommendation

`Batch 3B-2: Execute approved implementation lifecycle folder shortening.`

