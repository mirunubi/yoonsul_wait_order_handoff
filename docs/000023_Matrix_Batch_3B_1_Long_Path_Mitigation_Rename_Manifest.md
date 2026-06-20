# 000023_Matrix_Batch_3B_1_Long_Path_Mitigation_Rename_Manifest

This matrix is a planning manifest only. It does not execute folder renames, file moves, file renames, deletes, H1 edits, body edits, internal link edits, or runtime implementation.

| CurrentPath | ProposedPath | ItemType | CurrentLength | ProposedLength | LengthReduction | RenameNowRecommended | RenameLaterRecommended | RiskLevel | Requires000005Update | Requires000007Update | RequiresReadmeUpdate | Notes |
|---|---|---|---:|---:|---:|---|---|---|---|---|---|---|
| `docs/600000_implementation_lifecycle/` | `docs/600000_implementation_lifecycle/` | TopFolder | 75 | 37 | 38 | Yes | No | High | Yes | Yes | Yes | Shorten high-range root first. |
| `docs/600000_implementation_lifecycle/605000_pos_gateway_package/` | `docs/600000_implementation_lifecycle/605000_pos_gateway_package/` | PackageFolder | 130 | 64 | 66 | Yes | No | High | Yes | Yes | Yes | Shorten package folder with root rename. |
| `docs/600000_implementation_lifecycle/605000_pos_gateway_package/605100_core_flows/` | `docs/600000_implementation_lifecycle/605000_pos_gateway_package/605100_core_flows/` | Subfolder | 153 | 82 | 71 | Consider | Yes | Medium | Yes | Yes | Yes | Subfolder shortening further reduces path risk; execute with package rename if approved. |
| `docs/600000_implementation_lifecycle/605000_pos_gateway_package/605200_read_only_dry_run/` | `docs/600000_implementation_lifecycle/605000_pos_gateway_package/605200_read_only_dry_run/` | Subfolder | 172 | 89 | 83 | Consider | Yes | Medium | Yes | Yes | Yes | Subfolder shortening further reduces path risk; execute with package rename if approved. |
| `docs/600000_implementation_lifecycle/605000_pos_gateway_package/605300_authorization_execution/` | `docs/600000_implementation_lifecycle/605000_pos_gateway_package/605300_authorization_execution/` | Subfolder | 180 | 95 | 85 | Consider | Yes | Medium | Yes | Yes | Yes | Subfolder shortening further reduces path risk; execute with package rename if approved. |
| `docs/600000_implementation_lifecycle/605000_pos_gateway_package/605400_breach_hold/` | `docs/600000_implementation_lifecycle/605000_pos_gateway_package/605400_breach_hold/` | Subfolder | 171 | 83 | 88 | Consider | Yes | Medium | Yes | Yes | Yes | Subfolder shortening further reduces path risk; execute with package rename if approved. |
| `docs/600000_implementation_lifecycle/605000_pos_gateway_package/605500_future_hold_lift/` | `docs/600000_implementation_lifecycle/605000_pos_gateway_package/605500_future_hold_lift/` | Subfolder | 165 | 88 | 77 | Consider | Yes | Medium | Yes | Yes | Yes | Subfolder shortening further reduces path risk; execute with package rename if approved. |
| `docs/600000_implementation_lifecycle/605000_pos_gateway_package/605600_ticket_closeout/` | `docs/600000_implementation_lifecycle/605000_pos_gateway_package/605600_ticket_closeout/` | Subfolder | 182 | 87 | 95 | Consider | Yes | Medium | Yes | Yes | Yes | Subfolder shortening further reduces path risk; execute with package rename if approved. |
| `docs/600000_implementation_lifecycle/605000_pos_gateway_package/605700_repair_hold_lift/` | `docs/600000_implementation_lifecycle/605000_pos_gateway_package/605700_repair_hold_lift/` | Subfolder | 178 | 88 | 90 | Consider | Yes | Medium | Yes | Yes | Yes | Subfolder shortening further reduces path risk; execute with package rename if approved. |
| `docs/600000_implementation_lifecycle/605000_pos_gateway_package/605800_release_monitoring/` | `docs/600000_implementation_lifecycle/605000_pos_gateway_package/605800_release_monitoring/` | Subfolder | 178 | 90 | 88 | Consider | Yes | Medium | Yes | Yes | Yes | Subfolder shortening further reduces path risk; execute with package rename if approved. |
| `docs/600000_implementation_lifecycle/605000_pos_gateway_package/605900_final_closeout_archive/` | `docs/600000_implementation_lifecycle/605000_pos_gateway_package/605900_final_closeout_archive/` | Subfolder | 175 | 94 | 81 | Consider | Yes | Medium | Yes | Yes | Yes | Subfolder shortening further reduces path risk; execute with package rename if approved. |

## Estimated Package-Level Effect

| Scenario | PathsOver240 | PathsOver260 | MaxPathLength | Notes |
|---|---:|---:|---:|---|
| Current Batch 3B path | 289 | 181 | 305 | Current long path risk after moving under `600000_implementation_lifecycle`. |
| Proposed root, package, and subfolder shortening | 0 | 0 | 221 | Estimated result if all rename candidates in this matrix are approved. |

