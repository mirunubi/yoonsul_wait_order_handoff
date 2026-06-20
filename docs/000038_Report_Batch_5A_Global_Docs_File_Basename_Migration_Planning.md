# 000038_Report_Batch_5A_Global_Docs_File_Basename_Migration_Planning

## Scope

- Planning/manifest only across `docs/`.
- No file rename, folder rename, file move, delete, H1 edit, body edit, internal link edit, or runtime implementation.

High-range closed folders are scanned but marked `AlreadyClosedHighRange` and excluded from auto-rename execution:

- `docs/600000_implementation_lifecycle/`
- `docs/700000_runtime_flow/`

## Scan Scope

| ScopeRoot | Notes |
| --- | --- |
| `docs/` (recursive) | Global Markdown basename dry-run manifest for six-digit prefix migration. |

## Scan Summary

| Metric | Count |
| --- | ---: |
| Total markdown files scanned | 1459 |
| 5-digit basename files (needs rename) | 1071 |
| Already 6-digit basename files | 371 |
| Already closed high-range 6-digit files | 336 |
| 4-digit prefix anomalies | 0 |
| No-prefix anomalies | 7 |
| Excluded/manual-review files | 12 |
| Additional anomaly/manual-review (non-excluded, no rename) | 5 |
| Duplicate target risks | 0 |
| Case-only conflict risks | 0 |
| Long path risks before | 60 |
| Long path risks after | 62 |
| Root-level remaining files (rename or manual review) | 51 |
| Files under old 5-digit folder paths | 1080 |
| `*-1.md` duplicate copies | 1 |
| SOP/recipe/mobile/temp/delete-candidate-like exclusions | 10 |

## Rename Planning Rule

| Current Pattern | Proposed Pattern | Action |
| --- | --- | --- |
| `xxxxx_Title.md` | `0xxxxx_Title.md` | Add one leading zero to five-digit basename prefixes in a later execution batch. |
| `xxxxxx_Title.md` | unchanged | Already six-digit. |
| High-range closed 6-digit files | unchanged | AlreadyClosedHighRange; do not rename again. |
| `xxxx_Title.md` or no numeric prefix | manual review | Record as anomaly; do not auto rename. |
| `*-1.md`, download/tree/temp artifacts, delete candidates | excluded | Manual review or delete handling outside auto-rename. |

Long path risk threshold: absolute path length greater than 240 characters.

## Top 20 Highest-Risk Paths

1. `docs/600000_implementation_lifecycle/605000_pos_gateway_package/605900_final_closeout_archive/003320_Report_POS_Gateway_Runtime_Flow_Bundle_Post_Implementation_Repair_Post_Release_Monitoring_Evidence_Completeness_Report.md` (len=262)
2. `docs/600000_implementation_lifecycle/605000_pos_gateway_package/605900_final_closeout_archive/003300_Report_POS_Gateway_Runtime_Flow_Bundle_Post_Implementation_Repair_Post_Release_Monitoring_Activation_Decision_Report.md` (len=260)
3. `docs/600000_implementation_lifecycle/605000_pos_gateway_package/605900_final_closeout_archive/003310_Register_POS_Gateway_Runtime_Flow_Bundle_Post_Implementation_Repair_Post_Release_Monitoring_Final_Open_Item_Register.md` (len=260)
4. `docs/600000_implementation_lifecycle/605000_pos_gateway_package/605800_release_monitoring/003080_Checklist_POS_Gateway_Runtime_Flow_Bundle_Post_Implementation_Repair_Release_Gate_Review_Packet_Completeness_Checklist.md` (len=258)
5. `docs/600000_implementation_lifecycle/605000_pos_gateway_package/605700_repair_hold_lift/002870_Report_POS_Gateway_Runtime_Flow_Bundle_Post_Implementation_Repair_Final_Post_Hold_Lift_Archive_And_Preservation_Report.md` (len=256)
6. `docs/600000_implementation_lifecycle/605000_pos_gateway_package/605800_release_monitoring/003240_Template_POS_Gateway_Runtime_Flow_Bundle_Post_Implementation_Repair_Post_Release_Monitoring_Evidence_Packet_Template.md` (len=256)
7. `docs/600000_implementation_lifecycle/605000_pos_gateway_package/605800_release_monitoring/003270_Report_POS_Gateway_Runtime_Flow_Bundle_Post_Implementation_Repair_Post_Release_Monitoring_Packet_Completeness_Report.md` (len=256)
8. `docs/600000_implementation_lifecycle/605000_pos_gateway_package/605700_repair_hold_lift/002940_Report_POS_Gateway_Runtime_Flow_Bundle_Post_Implementation_Repair_Post_Hold_Lift_Final_Evidence_Preservation_Summary.md` (len=254)
9. `docs/600000_implementation_lifecycle/605000_pos_gateway_package/605700_repair_hold_lift/002690_Checklist_POS_Gateway_Runtime_Flow_Bundle_Post_Implementation_Repair_Hold_Lift_Review_Packet_Completeness_Checklist.md` (len=253)
10. `docs/600000_implementation_lifecycle/605000_pos_gateway_package/605800_release_monitoring/003030_Checklist_POS_Gateway_Runtime_Flow_Bundle_Post_Implementation_Repair_Release_Gate_Preparation_Readiness_Checklist.md` (len=253)
11. `docs/600000_implementation_lifecycle/605000_pos_gateway_package/605800_release_monitoring/003040_Report_POS_Gateway_Runtime_Flow_Bundle_Post_Implementation_Repair_Release_Gate_Preparation_Routing_Result_Report.md` (len=252)
12. `docs/600000_implementation_lifecycle/605000_pos_gateway_package/605800_release_monitoring/003120_Checklist_POS_Gateway_Runtime_Flow_Bundle_Post_Implementation_Repair_Formal_Release_Decision_Readiness_Checklist.md` (len=252)
13. `docs/600000_implementation_lifecycle/605000_pos_gateway_package/605800_release_monitoring/003170_Checklist_POS_Gateway_Runtime_Flow_Bundle_Post_Implementation_Repair_Post_Release_Monitoring_Readiness_Checklist.md` (len=252)
14. `docs/600000_implementation_lifecycle/605000_pos_gateway_package/605700_repair_hold_lift/002740_Checklist_POS_Gateway_Runtime_Flow_Bundle_Post_Implementation_Repair_Hold_Lift_Post_Decision_Compliance_Checklist.md` (len=251)
15. `docs/600000_implementation_lifecycle/605000_pos_gateway_package/605700_repair_hold_lift/002770_Report_POS_Gateway_Runtime_Flow_Bundle_Post_Implementation_Repair_Hold_Lift_Decision_Evidence_Preservation_Report.md` (len=251)
16. `docs/600000_implementation_lifecycle/605000_pos_gateway_package/605700_repair_hold_lift/002960_Report_POS_Gateway_Runtime_Flow_Bundle_Post_Implementation_Repair_Post_Hold_Lift_Final_Lane_Close_Decision_Report.md` (len=251)
17. `docs/600000_implementation_lifecycle/605000_pos_gateway_package/605800_release_monitoring/003050_Register_POS_Gateway_Runtime_Flow_Bundle_Post_Implementation_Repair_Release_Gate_Preparation_Open_Item_Register.md` (len=251)
18. `docs/600000_implementation_lifecycle/605000_pos_gateway_package/605800_release_monitoring/003230_Report_POS_Gateway_Runtime_Flow_Bundle_Post_Implementation_Repair_Post_Release_Monitoring_Entry_Decision_Report.md` (len=251)
19. `docs/600000_implementation_lifecycle/605000_pos_gateway_package/605800_release_monitoring/003290_Gate_POS_Gateway_Runtime_Flow_Bundle_Post_Implementation_Repair_Post_Release_Monitoring_Closeout_Entry_Decision.md` (len=251)
20. `docs/600000_implementation_lifecycle/605000_pos_gateway_package/605800_release_monitoring/003150_Register_POS_Gateway_Runtime_Flow_Bundle_Post_Implementation_Repair_Formal_Release_Decision_Condition_Register.md` (len=250)

## Recommended Execution Batch Split

| SuggestedExecutionBatch | Count | Description |
| --- | ---: | --- |
| Batch5B_RootGovernance | 39 | Root-level governance/report files with remaining 5-digit basenames. |
| Batch5C_LowDensityDomain | 466 | Domain folders with fewer than 50 Markdown files. |
| Batch5D_MediumDensityDomain | 185 | Domain folders with 50–149 Markdown files. |
| Batch5E_DenseDomain | 381 | Dense legacy/domain folders with 150+ Markdown files. |
| Batch5F_ManualReview | 41 | Anomalies and non-excluded manual-review items. |
| AlreadyClosedHighRange | 336 | Closed 600000/700000 six-digit files; no rename. |
| Excluded_DuplicateCopy | 1 | `*-1.md` duplicate copies. |
| Excluded_TempArtifact | 2 | Download/tree/temp artifacts. |
| Excluded_DeleteCandidate | 8 | Manual delete-candidate lanes. |
| Hold_ConflictRisk | 0 | Duplicate target or case-only conflict hold. |

### Suggested Wave Order

1. **Batch 5B** — Root governance/report remaining 5-digit basenames (lowest blast radius).
2. **Batch 5C** — Low-density domain folders.
3. **Batch 5D** — Medium-density domain folders.
4. **Batch 5E** — Dense legacy folders (especially `docs/012000_implementation_mapping/` and large runtime/provider lanes).
5. **Batch 5F** — Anomaly/manual-review handling (4-digit, no-prefix, unresolved items).
6. **Batch 5G** — Global internal link integrity scan (after rename waves).
7. **Batch 5H** — H1 mismatch closeout (after rename waves).

Already closed `600000`/`700000` high-range folders must not be renamed again.

## Rollback Notes

- Batch 5A is planning only. Rollback is limited to removing `000038` and `000039`.
- No file rename, folder rename, move, delete, H1 edit, body edit, internal link edit, or runtime implementation was performed.

## Files Created

- docs/000038_Report_Batch_5A_Global_Docs_File_Basename_Migration_Planning.md
- docs/000039_Matrix_Batch_5A_Global_Docs_File_Basename_Rename_Manifest.md

## Validation Plan

- Run `git diff --check` for the two Batch 5A documents.
- Run `git status --short`.
- Confirm no rename, move, delete, H1/body/link edit, or runtime implementation occurred.

## Recommended Next Batch

Batch 5B: Root governance/report files remaining 5-digit basename rename.
