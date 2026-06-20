# 000008_Report_Docs_Directory_Redesign_v0_2_Audit_And_Move_Plan

## 0. Safety Contract

This report is an audit and planning document only.

- No files were moved by this report.
- No files were deleted by this report.
- No existing Markdown body text was edited by this report.
- No H1 text was changed by this report.
- No internal links were rewritten by this report.
- No formatting or encoding normalization was run.
- Future execution batches must use `git mv` for file moves.
- Future execution batches must not use PowerShell `Set-Content`.

Encoding safety boundary:

- Treat all Korean Markdown files as UTF-8 source files.
- Do not run broad formatters over documentation.
- Do not rewrite files just to normalize line endings, whitespace, or encoding.
- Review generated diffs before committing any documentation move or index update.

## 1. Scope

This report audits the current `docs/` directory against the proposed v0.2 top-level directory model and produces a move plan. It does not execute the plan.

Primary source references:

- `docs/00001_Md_Rules.md`
- `docs/00002_Naming_Rules.md`
- `docs/00005_Document_Number_Index.md`
- `docs/00007_Full_Directory_Map.md`
- `docs/00015_Korean_Document_And_Encoding_Safety_Rules.md`
- Current `docs/` directory tree

Explicitly excluded from move mapping:

- `*-1.md` duplicate files
- Recipe, mobile, temporary, and SOP files such as `2026-06-14_*sop*.md`, `30010_SOP_*`, and `sop_2026-06-14_*`
- Image files such as `.jpg`, `.jpeg`, `.png`, and `.webp`
- Tree, temporary, download, and test files such as `directory_only_tree.txt`, `directory_tree.txt`, `downloadfile*.md`, and `termux_visible_test.md`

## 2. Current State Findings

The current `docs/` tree already contains several stable top-level lanes, but the lane model is inconsistent. Some folders use older short names, some use domain names, and some high-volume packages are still sitting in temporary or transitional locations.

Observed top-level lanes include:

- `00100_project_foundation`
- `00999_conflicts`
- `01000_mvp_scope`
- `03000_saas_runtime`
- `04000_store_runtime_pos_kds_operations`
- `04900_security_runtime_test_catalog`
- `05000_customer_handoff_and_implementation_readiness`
- `07000_admin_console`
- `08000_ai_customer_center`
- `09000_data_model_state_machine`
- `10000_runtime_foundation_and_cross_room_architecture`
- `11000_integration_boundary`
- `12000_implementation_mapping`
- `13000_app_api_projection`
- `14000_pos_provider_integration_strategy`
- `15000_membership_loyalty`
- `17000_ui_screen_composition`
- `20000_validation_security_audit`
- `21000_financial_security_monitoring_catalog`
- `22000_implementation_planning`
- `24000_deployment_operations`
- `26000_analytics_reporting_bi`
- `28000_future_expansion`
- `30000_future_saas_modules`
- `40000_menu_taxonomy_and_ai_classification`
- `64000_runtime_flow_bundle`

The main structural issue is that the directory tree mixes these concepts:

- Governance and document-control files in root
- Implementation handoff files under `12000_implementation_mapping`
- Runtime-flow bundle files under `64000_runtime_flow_bundle`
- Security test catalogs split between `04900_security_runtime_test_catalog` and `20000_validation_security_audit`
- Customer handoff, waiting/order runtime, display runtime, and implementation readiness mixed under `05000_customer_handoff_and_implementation_readiness`
- Runtime foundation files grouped by repeated `10000_*` folder names rather than by stable domain lanes

## 3. Proposed v0.2 Top-Level Directory Model

Recommended target top-level folders:

```text
00000_project_governance_and_document_control/
01000_mvp_scope_and_product_boundary/
02000_business_model_strategy_and_patent_context/
03000_saas_runtime_and_tenant_operation/
04000_store_runtime_pos_kds_operations/
05000_customer_handoff_waiting_order_and_readiness/
06000_recipe_menu_sop_and_store_operation/
07000_admin_console_and_backoffice/
08000_ai_customer_center_and_support_runtime/
09000_data_model_state_machine_and_event_contract/
10000_runtime_foundation_and_cross_room_architecture/
11000_external_integration_gateway_boundary/
12000_implementation_mapping_and_code_handoff/
13000_app_api_projection_and_client_contract/
14000_pos_provider_integration_strategy/
15000_membership_loyalty_and_customer_account/
16000_payment_billing_settlement_and_reconciliation/
17000_ui_screen_composition_and_frontend_flow/
18000_kiosk_did_device_and_edge_runtime/
19000_store_staff_workspace_and_workforce_interface/
20000_validation_security_audit_and_compliance/
21000_financial_security_monitoring_catalog/
22000_implementation_planning_and_delivery_control/
23000_release_change_migration_and_backfill_control/
24000_deployment_operations_and_infra_runbook/
25000_observability_incident_and_dr_runtime/
26000_analytics_reporting_bi_and_metric_catalog/
27000_legal_policy_privacy_and_consumer_protection/
28000_future_expansion_and_reserved_modules/
29000_archive_duplicate_conflict_and_reclassification/
30000_operation_sop_catalog/
40000_menu_taxonomy_recipe_ai_and_classification/
50000_system_sop_catalog/
60000_system_governance_registry_and_evidence/
70000_runtime_flow_bundle_and_dependency_graph/
80000_agent_ai_automation_and_knowledge_evolution/
90000_patent_bm_claim_and_external_submission/
99000_legacy_quarantine_and_import_archive/
```

## 4. Focused Audit Decisions

| Area | Current Location | Recommended Target | Decision |
| --- | --- | --- | --- |
| Root governance files `00000~00099` | `docs/` root | `00000_project_governance_and_document_control/` | Move into a dedicated governance lane. These files define rules, indexes, maps, and document-control policy. |
| Development foundation files `00640~00900` | `docs/` root | `12000_implementation_mapping_and_code_handoff/12010_development_foundation_and_codebase_entry/` | Move as implementation foundation, not general governance. These are closer to codebase entry and development handoff. |
| Formal root foundation files | `docs/` root | Case-by-case under `00000`, `12000`, `50000`, or `60000` | Require human confirmation if the filename does not clearly identify the lane. |
| `Foundation I18n...` file | `docs/` root | `50000_system_sop_catalog/50010_i18n_content_registry_and_sop_parsing/` | Preferred because it combines I18n, content registry, SOP parsing, and multilingual runtime policy. Cross-reference from `40000` if menu taxonomy depends on it. |
| `12000_implementation_mapping` | Existing top-level lane | `12000_implementation_mapping_and_code_handoff/` | Rename the lane in a later batch with `git mv`. Keep implementation maps, handoff prompts, and code-facing packages here. |
| `048xx/049xx` mapping docs | `12000_implementation_mapping` | `12000_implementation_mapping_and_code_handoff/12020_security_runtime_and_adapter_mapping/` | Subdivide because the range mixes implementation mapping, security runtime, adapter contracts, and test readiness. |
| POS Gateway implementation package | `12000_implementation_mapping/12090_pos_gateway_runtime_flow_implementation_package` | Keep temporarily; optional final lane `12100_pos_gateway_runtime_flow_implementation_package/` | Current grouping is usable. Rebalance only if the project wants cleaner `12100~12190` folder numbers. Do not renumber files. |
| Runtime Flow Bundle `64000~64390` | `64000_runtime_flow_bundle` | `70000_runtime_flow_bundle_and_dependency_graph/70010_pos_gateway_runtime_flow_bundle/` | Move to the proposed runtime-flow lane. The bundle is a runtime flow and dependency graph package, not a top-level `64000` lane in v0.2. |
| Conflict review files | `00999_conflicts` | `29000_archive_duplicate_conflict_and_reclassification/29010_root_conflict_review/` | Move to the conflict/reclassification archive lane. Prefer `29000` over `99000` because these are active duplicate/conflict review records, not legacy import quarantine. |
| Runtime foundation high-volume tree | `10000_runtime_foundation_and_cross_room_architecture` | Same top-level lane, with domain sublanes | Keep the top-level lane but split repeated `10000_*` folders into stable domain groups. |
| Customer handoff and readiness tree | `05000_customer_handoff_and_implementation_readiness` | `05000_customer_handoff_waiting_order_and_readiness/` | Rename top lane and subdivide. Separate customer handoff, waiting/order, display runtime, implementation readiness, and POS/payment readiness. |
| Security runtime test catalog | `04900_security_runtime_test_catalog` | `20000_validation_security_audit_and_compliance/20090_security_runtime_test_catalog/` | Integrate into validation/security. Keep a temporary source folder only during migration. |
| POS provider integration strategy | `14000_pos_provider_integration_strategy` | Same top-level lane | Keep the lane. Add subfolders for strategy, provider assessment, provider handoff, and archive review. |
| `70650_...External_Settlement...` | `docs/` root | `16000_payment_billing_settlement_and_reconciliation/16070_external_settlement_reconciliation_exception_matrix/` | Move to settlement/reconciliation. Add a later index cross-reference from `21000` if monitoring controls consume it. |

## 5. Detailed Target Lane Notes

### 5.1 Governance And Root Files

Move root governance files to:

```text
docs/00000_project_governance_and_document_control/
```

Recommended sublanes:

```text
00000_core_governance_rules/
00005_indexes_and_directory_maps/
00010_document_generation_and_handoff_rules/
00015_encoding_and_korean_document_safety/
00090_reports_and_audit_plans/
```

The current root should eventually contain only exceptional project entry files, if any. Indexes and maps should live under the governance lane while still remaining easy to locate.

### 5.2 Implementation Mapping And Code Handoff

Rename:

```text
docs/12000_implementation_mapping/
```

to:

```text
docs/12000_implementation_mapping_and_code_handoff/
```

Recommended sublanes:

```text
12000_lane_readme_and_registry/
12010_development_foundation_and_codebase_entry/
12020_security_runtime_and_adapter_mapping/
12030_implementation_ticket_templates/
12040_code_handoff_prompts_and_review_packets/
12100_pos_gateway_runtime_flow_implementation_package/
```

The existing `12090_pos_gateway_runtime_flow_implementation_package` can remain as a transitional location. If a future cleanup chooses to rebalance folder numbers, move the folder to `12100_pos_gateway_runtime_flow_implementation_package` with `git mv` and update only `00005` and `00007`.

### 5.3 Runtime Flow Bundle

Move:

```text
docs/64000_runtime_flow_bundle/
```

to:

```text
docs/70000_runtime_flow_bundle_and_dependency_graph/70010_pos_gateway_runtime_flow_bundle/
```

Recommended sublanes:

```text
70010_runtime_flow_bundle_registry_and_core_flows/
70020_runtime_flow_bundle_mapping_and_test_coverage/
70030_runtime_flow_bundle_code_handoff_and_governance/
```

This keeps the existing registry, flow, matrix, test coverage, handoff, and governance structure but places it under the v0.2 runtime-flow top-level lane.

### 5.4 Runtime Foundation

Keep:

```text
docs/10000_runtime_foundation_and_cross_room_architecture/
```

Recommended sublanes:

```text
10010_static_catalog_and_foundation_state/
10020_store_runtime_core/
10100_four_side_platform_architecture/
10400_financial_transaction_boundary/
10500_data_governance_and_retention/
10600_cross_room_policy_and_contracts/
10700_security_trust_boundary/
10720_legal_notice_runtime/
10800_store_onboarding_and_activation/
10900_reports_and_audit_findings/
```

This reduces repeated `10000_*` folder names and makes the lane easier to scan.

### 5.5 Customer Handoff, Waiting, Order, And Readiness

Rename:

```text
docs/05000_customer_handoff_and_implementation_readiness/
```

to:

```text
docs/05000_customer_handoff_waiting_order_and_readiness/
```

Recommended sublanes:

```text
05000_customer_handoff_flow/
05100_implementation_readiness_and_provider_verification/
05200_pos_payment_provider_readiness/
05400_waiting_preorder_table_order_runtime/
06400_store_runtime_workpackages/
06700_customer_runtime_display_and_evidence/
06800_customer_display_implementation_specs/
06900_customer_runtime_display_release_and_registry/
```

Documents that are primarily payment, billing, settlement, or provider integration should be reviewed before staying in this lane. Strong payment/provider documents may belong under `14000` or `16000`.

### 5.6 Validation, Security, And Audit

Move:

```text
docs/04900_security_runtime_test_catalog/
```

to:

```text
docs/20000_validation_security_audit_and_compliance/20090_security_runtime_test_catalog/
```

Recommended sublanes:

```text
20000_validation_and_security_readme/
20010_security_runtime_tests/
20020_audit_and_compliance_evidence/
20090_security_runtime_test_catalog/
20990_archive_duplicate_review/
```

The `04900` catalog is semantically a validation/security artifact. Consolidating it under `20000` reduces split ownership.

### 5.7 POS Provider Integration

Keep:

```text
docs/14000_pos_provider_integration_strategy/
```

Recommended sublanes:

```text
14000_strategy_and_provider_assessment/
14100_provider_gateway_contracts/
14200_store_runtime_provider_handoff/
14900_archive_duplicate_review/
```

The lane name is still valid. It should receive provider strategy and provider-integration files, while settlement accounting belongs in `16000`.

### 5.8 Archive, Conflict, And Quarantine

Move:

```text
docs/00999_conflicts/
```

to:

```text
docs/29000_archive_duplicate_conflict_and_reclassification/29010_root_conflict_review/
```

Use:

```text
docs/99000_legacy_quarantine_and_import_archive/
```

only for imported legacy files, uncertain external dumps, and content that should not participate in the active document map until reviewed.

## 6. Candidate Move Plan

| Batch | Action | Move Type | Index Update | Risk |
| --- | --- | --- | --- | --- |
| 0 | Freeze exclusions and run preflight status/tree scans | No file move | None | Low |
| 1 | Create v0.2 top-level folders | Directory creation only | `00007` if directories are documented | Low |
| 2 | Move root governance files `00000~00099` | `git mv` | `00005`, `00007` | Medium because indexes move their own references |
| 3 | Move root development foundation files `00640~00900` | `git mv` | `00005`, `00007` | Low |
| 4 | Rename `12000_implementation_mapping` to `12000_implementation_mapping_and_code_handoff` | `git mv` | `00005`, `00007` | Medium because many indexed paths change |
| 5 | Rebalance or keep POS Gateway package | Optional `git mv` | `00005`, `00007` if moved | Medium due file count |
| 6 | Move `64000_runtime_flow_bundle` to `70000_runtime_flow_bundle_and_dependency_graph` | `git mv` | `00005`, `00007` | Low to medium |
| 7 | Move `00999_conflicts` to `29000_archive_duplicate_conflict_and_reclassification` | `git mv` | `00005`, `00007` | Low |
| 8 | Rename and subdivide `05000_customer_handoff...` | `git mv` | `00005`, `00007` | Medium due mixed domain ownership |
| 9 | Restructure `10000_runtime_foundation...` sublanes | `git mv` | `00005`, `00007` | High due volume and repeated folder families |
| 10 | Move `04900_security_runtime_test_catalog` into `20000` | `git mv` | `00005`, `00007` | Medium because archive folders must be preserved |
| 11 | Move `70650_...External_Settlement...` into `16000` | `git mv` | `00005`, `00007` | Low |
| 12 | Final root leftover audit | No file move unless separately approved | None | Low |

## 7. Batch Execution Rules

Every move batch should follow this sequence:

```powershell
git status --short

# Create approved destination folders only.
# Move approved files only with git mv.

git status --short
git diff --check
```

After each batch:

- Verify excluded files remained in their original locations.
- Verify root leftovers by numeric range or naming pattern.
- Verify `00005_Document_Number_Index.md` and `00007_Full_Directory_Map.md` contain only intended path updates.
- Do not modify H1 text.
- Do not modify internal links unless a separate link-update task is approved.

## 8. Exclusion Rules For Future Move Batches

Never move these files as part of broad directory redesign batches unless a later request explicitly names them:

- `*-1.md`
- `2026-06-14_*sop*.md`
- `30010_SOP_*`
- `sop_2026-06-14_*`
- `directory_only_tree.txt`
- `directory_tree.txt`
- `downloadfile*.md`
- `termux_visible_test.md`
- `*.jpg`
- `*.jpeg`
- `*.png`
- `*.webp`

If an excluded file appears to belong to a new lane, record it in the report but leave it in place.

## 9. Open Questions

1. Should root indexes `00005` and `00007` remain physically in root for operator convenience, or should they move into `00000_project_governance_and_document_control` with root shortcuts documented elsewhere?
2. Should `12090_pos_gateway_runtime_flow_implementation_package` remain as the stable package folder, or should it be rebalanced to `12100_pos_gateway_runtime_flow_implementation_package`?
3. Should POS payment provider readiness documents under the `05000` tree stay with customer readiness, move to `14000` provider integration, or move to `16000` payment and settlement?
4. Should archive duplicate-review folders remain inside each domain lane, or should all archive reviews consolidate under `29000`?
5. Should `99000_legacy_quarantine_and_import_archive` be reserved only for files that are not currently trusted enough to index?

## 10. Recommended Next Step

Run the redesign in small approved batches, starting with low-risk moves:

1. Move `64000_runtime_flow_bundle` to `70000_runtime_flow_bundle_and_dependency_graph`.
2. Move `00999_conflicts` to `29000_archive_duplicate_conflict_and_reclassification`.
3. Move `70650_...External_Settlement...` to `16000_payment_billing_settlement_and_reconciliation`.
4. Decide whether root governance indexes should physically move before moving `00000~00099`.

The high-volume `05000`, `10000`, and `12000` restructures should be handled only after the target lane policy is accepted, because those batches will create the largest index diffs.
