# Report Docs Six Digit Domain Band Redesign v0.4 Plan

Status: Draft
Lifecycle: Overview
Owner: TBD
Last Updated: 2026-06-18

## 0 Scope

This report proposes the v0.4 six-digit domain band design for `docs` development documentation after Batch 2 folder zero-padding.

This is planning only.

- No folder move was executed.
- No file move was executed.
- No file rename was executed.
- No delete was executed.
- No runtime implementation was created.
- No SQL, migration, app code, Supabase function, or package change was created.
- No formatter was run.
- PowerShell `Set-Content` was not used.

## 1 Inputs

Reference inputs:

- `docs/000001_Md_Rules.md`
- `docs/000002_Naming_Rules.md`
- `docs/000005_Document_Number_Index.md`
- `docs/000007_Full_Directory_Map.md`
- `docs/000011_Report_Six_Digit_Documentation_Numbering_Dry_Run_Manifest.md`
- `docs/000012_Register_Six_Digit_Rename_Dry_Run_Manifest.md`
- `docs/000013_Register_Six_Digit_Rename_Anomaly_And_Manual_Review.md`
- `docs/000015_Report_Six_Digit_Migration_Batch_2_Folder_Zero_Padding.md`
- `docs/000016_Report_Docs_Folder_File_Count_And_Number_Density_Audit.md`

Density findings used:

- Folders with 300+ Markdown files: 2.
- Folders with 100~299 Markdown files: 2.
- Folders with long path risk: 11.
- Suggested 4000-slot domains: `docs/012000_implementation_mapping`, `docs/012000_implementation_mapping/012090_pos_gateway_runtime_flow_implementation_package`.
- Suggested 2000-slot domains: `docs/010000_runtime_foundation_and_cross_room_architecture`, `docs/014000_pos_provider_integration_strategy`.

## 2 v0.4 Domain Band Proposal

Recommended `docs` development domain bands:

```text
000000_project_governance_and_document_control/
002000_product_scope_market_and_mvp_boundary/
004000_saas_runtime_tenant_and_service_operation/
006000_store_runtime_pos_kds_and_local_operations/
008000_customer_handoff_waiting_order_and_entry_runtime/
010000_menu_content_taxonomy_recipe_and_i18n_runtime/
014000_admin_console_backoffice_and_owner_operation/
018000_ai_customer_center_support_and_knowledge_runtime/
022000_data_model_state_machine_event_and_ledger_contract/
026000_runtime_foundation_cross_room_and_system_architecture/
030000_external_integration_gateway_and_provider_boundary/
034000_app_api_projection_client_contract_and_frontend_bridge/
038000_pos_provider_pg_van_and_device_integration_strategy/
042000_membership_loyalty_coupon_point_and_customer_account/
046000_payment_billing_settlement_reconciliation_and_financial_runtime/
050000_ui_screen_composition_wording_and_frontend_flow/
054000_kiosk_did_device_edge_and_local_agent_runtime/
058000_store_staff_workspace_workforce_and_field_operation_interface/
062000_validation_security_audit_privacy_and_compliance/
066000_financial_security_monitoring_audit_ledger_and_legal_hold/
070000_release_change_migration_backfill_cutover_and_deployment/
074000_observability_incident_dr_resilience_and_operations/
078000_analytics_reporting_bi_metric_and_benchmark_catalog/
082000_legal_policy_privacy_consumer_protection_and_regulatory/
086000_future_expansion_reserved_modules_and_long_term_options/
090000_development_tooling_ai_handoff_cursor_claude_codex_and_qa_control/
095000_reclassification_duplicate_conflict_and_manual_review/
099000_legacy_quarantine_import_archive_and_delete_candidate_hold/
```

Special high-range domains:

```text
600000_implementation_lifecycle_code_handoff_and_development_packages/
700000_runtime_flow_bundle_dependency_graph_and_execution_trace/
800000_agent_ai_automation_knowledge_evolution_and_npu_readiness/
900000_patent_bm_claim_external_submission_and_attorney_packet/
950000_reclassification_duplicate_conflict_and_manual_review/
990000_legacy_quarantine_import_archive_and_delete_candidate_hold/
```

Reserved non-docs namespaces:

- `100000~499999`: SOP namespace outside `docs`.
- `500000~599999`: evidence, audit, legal hold, export, retention, and compliance packet expansion namespace.

## 3 Key Decisions

### 3.1 Implementation Lifecycle Separation

Recommendation: separate the current `docs/012000_implementation_mapping` lane into the `600000` high-range domain.

Reason:

- It has 345 recursive Markdown files.
- It is already identified as a 4000-slot candidate.
- It contains implementation mapping, code handoff, package closeout, Overview / Logic / Module style material, and implementation evidence.
- Keeping it inside the low `000000~099999` development domain would consume too much local numbering space.

Recommended target:

```text
docs/600000_implementation_lifecycle_code_handoff_and_development_packages/
```

### 3.2 POS Gateway Implementation Package Separation

Recommendation: move `docs/012000_implementation_mapping/012090_pos_gateway_runtime_flow_implementation_package` into a dedicated subdomain under `600000`, with a short path.

Recommended target:

```text
docs/605000_pos_gateway_runtime_flow_implementation_package/
```

Reason:

- It has 316 recursive Markdown files.
- It has 189 long path risk candidates through its parent lane.
- Keeping the package deeply nested will continue to create path length risk.
- A direct high-range folder reduces path depth while preserving domain meaning.

### 3.3 Runtime Flow Bundle Separation

Recommendation: move `docs/064000_runtime_flow_bundle` into the `700000` high-range runtime flow domain.

Recommended target:

```text
docs/700000_runtime_flow_bundle_dependency_graph_and_execution_trace/
```

Reason:

- It is semantically a runtime flow bundle and dependency graph package.
- It should not compete with normal low-range domain design folders.
- It has 20 Markdown files and low volume, but the content type is high-range by governance.

### 3.4 Runtime Foundation Remap

Recommendation: move `docs/010000_runtime_foundation_and_cross_room_architecture` to `docs/026000_runtime_foundation_cross_room_and_system_architecture`.

Reason:

- It has 180 recursive Markdown files.
- It is a 2000-slot candidate.
- The proposed `026000` slot better matches runtime foundation and system architecture than the temporary zero-padded `010000` location.

### 3.5 POS Provider Integration Remap

Recommendation: move `docs/014000_pos_provider_integration_strategy` to `docs/038000_pos_provider_pg_van_and_device_integration_strategy`.

Reason:

- It has 201 recursive Markdown files.
- It is a 2000-slot candidate.
- The target domain name explicitly covers POS provider, PG, VAN, and device integration strategy.

### 3.6 No-Prefix Anomaly

Current anomaly:

```text
docs/014000_pos_provider_integration_strategy/archive_duplicate_review
```

Recommendation: move this content with its parent domain during the POS provider migration, but assign it a numbered archive subfolder inside the domain unless the content is cross-domain.

Preferred target:

```text
docs/038000_pos_provider_pg_van_and_device_integration_strategy/038900_archive_duplicate_review/
```

Use `950000_reclassification_duplicate_conflict_and_manual_review/` only if the folder is meant to become a cross-domain manual review queue.

## 4 Long Path Mitigation Strategy

Long path risk is concentrated in the POS Gateway implementation package under the current implementation mapping lane.

Mitigation rules:

- Move the POS Gateway implementation package to a shallow high-range root folder.
- Keep file basenames unchanged until a separate file-level rename batch is approved.
- Shorten intermediate folder names before renaming files.
- Avoid adding new nested layers under implementation package folders.
- Review any path at or above 220 characters before file-level migration.
- Treat any path at or above 240 characters as high risk.

## 5 Recommended Move Batches

Batch A: planning approval only.

- Review this report and the mapping matrix.
- Do not move files or folders.

Batch B: high-range implementation lifecycle folder migration.

- Move `docs/012000_implementation_mapping` to `docs/600000_implementation_lifecycle_code_handoff_and_development_packages`.
- Consider extracting POS Gateway directly to `docs/605000_pos_gateway_runtime_flow_implementation_package` in the same batch only if a manifest proves there is no collision.

Batch C: runtime flow bundle migration.

- Move `docs/064000_runtime_flow_bundle` to `docs/700000_runtime_flow_bundle_dependency_graph_and_execution_trace`.

Batch D: 2000-slot domain remaps.

- Move runtime foundation to `026000`.
- Move POS provider integration to `038000`.

Batch E: low-range domain alignment.

- Align customer handoff, UI, analytics, deployment, validation, and future expansion domains to the v0.4 names.

Batch F: anomaly handling.

- Resolve `archive_duplicate_review` as either `038900_archive_duplicate_review` or high-range `950000`.

## 6 Files And Folders Not To Move Yet

Do not move these until a later approved manifest exists:

- Root governance files already renamed in Batch 1.
- Individual Markdown file basenames.
- `sop/` content.
- `500000~599999` evidence/legal-hold namespace.
- `800000`, `900000`, `950000`, and `990000` high-range domains with no current approved source package.
- Any `*-1.md`, temp, download, tree output, image, or manual-delete candidate.

## 7 Risks And Rollback Notes

Risks:

- Large folder moves will appear as many file path renames in Git.
- Long path risk is high under POS Gateway implementation package paths.
- `000005` and `000007` must be updated carefully after every approved move batch.
- Some folders contain duplicate file prefixes and should not be file-renamed until duplicate-prefix review is complete.

Rollback notes:

- Each future move batch should be bounded to one or two domains.
- Use `git mv` only.
- Keep a manifest with source path, target path, and reason.
- Validate with `git diff --check`.
- If conflicts appear, stop the batch and do not continue broad moves.

## 8 Recommended Next Batch

Recommended next batch:

```text
Batch 3A: High-Range Implementation Lifecycle Planning Manifest
```

Purpose:

- Produce a manifest for `012000 -> 600000`.
- Decide whether `012090 -> 605000` is included or separated.
- Measure long path reduction before executing the move.
