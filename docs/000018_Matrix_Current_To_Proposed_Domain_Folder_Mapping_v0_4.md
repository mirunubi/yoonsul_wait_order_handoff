# Matrix Current To Proposed Domain Folder Mapping v0.4

Status: Draft
Lifecycle: Overview
Owner: TBD
Last Updated: 2026-06-18

## 0 Scope

This matrix maps current post-Batch-2 `docs` folders to proposed v0.4 six-digit domain bands.

This is planning only. No folder move, file move, file rename, delete, H1 edit, body edit, formatter, or runtime implementation was executed.

## 1 Mapping Matrix

| CurrentPath | ProposedPath | MoveType | Reason | CurrentMdCount | RecursiveMdCount | SuggestedSlotSize | Priority | RiskLevel | Requires00005Update | Requires00007Update | RequiresReadmeUpdate | Notes |
| --- | --- | --- | --- | ---: | ---: | --- | --- | --- | --- | --- | --- | --- |
| docs/000100_project_foundation | docs/000000_project_governance_and_document_control/project_foundation | Reclassify | Project foundation belongs under governance/document control. | 43 | 43 | 1000 slots | P2 | Medium | Yes | Yes | Yes | Consider whether some product context moves to 002000. |
| docs/000999_conflicts | docs/095000_reclassification_duplicate_conflict_and_manual_review/root_conflicts | MoveToHighRange | Conflict records belong in reclassification/manual review. | 4 | 4 | 1000 slots | P2 | Low | Yes | Yes | Yes | Could also be kept as 000900 local conflict if not cross-domain. |
| docs/001000_mvp_scope | docs/002000_product_scope_market_and_mvp_boundary | RenameDomain | MVP and product boundary align with 002000. | 33 | 33 | 1000 slots | P2 | Low | Yes | Yes | Yes | Low volume. |
| docs/003000_saas_runtime | docs/004000_saas_runtime_tenant_and_service_operation | RenameDomain | SaaS runtime and tenant operation align with 004000. | 17 | 17 | 1000 slots | P2 | Low | Yes | Yes | Yes | Low volume. |
| docs/004000_store_runtime_pos_kds_operations | docs/006000_store_runtime_pos_kds_and_local_operations | RenameDomain | Store runtime, POS, KDS, and local operation lane. | 48 | 48 | 1000 slots | P2 | Medium | Yes | Yes | Yes | Contains duplicate file prefixes. |
| docs/004900_security_runtime_test_catalog | docs/062000_validation_security_audit_privacy_and_compliance/security_runtime_test_catalog | Reclassify | Security test catalog belongs with validation/security/compliance. | 35 | 35 | 1000 slots | P2 | Medium | Yes | Yes | Yes | Could become 062900 subfolder. |
| docs/005000_customer_handoff_and_implementation_readiness | docs/008000_customer_handoff_waiting_order_and_entry_runtime | RenameDomain | Customer handoff, waiting/order, and entry runtime lane. | 90 | 90 | 1000 slots | P2 | Medium | Yes | Yes | Yes | Contains duplicate file prefixes. |
| docs/007000_admin_console | docs/014000_admin_console_backoffice_and_owner_operation | RenameDomain | Admin console and owner/backoffice operation lane. | 12 | 12 | 1000 slots | P3 | Low | Yes | Yes | Yes | Low volume. |
| docs/008000_ai_customer_center | docs/018000_ai_customer_center_support_and_knowledge_runtime | RenameDomain | AI customer center and support knowledge runtime lane. | 20 | 20 | 1000 slots | P3 | Low | Yes | Yes | Yes | Low volume. |
| docs/009000_data_model_state_machine | docs/022000_data_model_state_machine_event_and_ledger_contract | RenameDomain | Data model, state machine, event, and ledger contracts lane. | 13 | 13 | 1000 slots | P3 | Low | Yes | Yes | Yes | Low volume. |
| docs/010000_runtime_foundation_and_cross_room_architecture | docs/026000_runtime_foundation_cross_room_and_system_architecture | RenameDomain | Runtime foundation is a 2000-slot candidate and fits 026000. | 180 | 180 | 2000 slots | P1 | Medium | Yes | Yes | Yes | Contains duplicate file prefixes. |
| docs/011000_integration_boundary | docs/030000_external_integration_gateway_and_provider_boundary | RenameDomain | External integration gateway and provider boundary lane. | 42 | 42 | 1000 slots | P2 | Low | Yes | Yes | Yes | May split provider-specific content to 038000. |
| docs/012000_implementation_mapping | docs/600000_implementation_lifecycle_code_handoff_and_development_packages | MoveToHighRange | Implementation lifecycle lane is high volume and high-range by governance. | 345 | 345 | 4000 slots | P0 | High | Yes | Yes | Yes | Contains 189 long path risk candidates through nested package. |
| docs/012000_implementation_mapping/012090_pos_gateway_runtime_flow_implementation_package | docs/605000_pos_gateway_runtime_flow_implementation_package | MoveToHighRange | POS Gateway package should be shallow to reduce long path risk. | 316 | 316 | 4000 slots | P0 | High | Yes | Yes | Yes | Strong candidate for separate high-range root. |
| docs/013000_app_api_projection | docs/034000_app_api_projection_client_contract_and_frontend_bridge | RenameDomain | App/API projection, client contract, and frontend bridge lane. | 14 | 14 | 1000 slots | P3 | Low | Yes | Yes | Yes | Low volume. |
| docs/014000_pos_provider_integration_strategy | docs/038000_pos_provider_pg_van_and_device_integration_strategy | RenameDomain | POS provider integration is a 2000-slot candidate. | 201 | 201 | 2000 slots | P1 | Medium | Yes | Yes | Yes | Contains no-prefix archive anomaly. |
| docs/014000_pos_provider_integration_strategy/archive_duplicate_review | docs/038000_pos_provider_pg_van_and_device_integration_strategy/038900_archive_duplicate_review | NumberAnomaly | Prefix-free anomaly should be numbered inside parent domain unless cross-domain. | 0 | 0 | 1000 slots | P1 | Medium | Yes | Yes | Yes | Use 950000 only if cross-domain manual review is intended. |
| docs/015000_membership_loyalty | docs/042000_membership_loyalty_coupon_point_and_customer_account | RenameDomain | Membership, loyalty, coupon, point, and customer account lane. | 6 | 6 | 1000 slots | P3 | Low | Yes | Yes | Yes | Low volume. |
| docs/017000_ui_screen_composition | docs/050000_ui_screen_composition_wording_and_frontend_flow | RenameDomain | UI, wording, and frontend flow lane. | 14 | 14 | 1000 slots | P3 | Low | Yes | Yes | Yes | Low volume. |
| docs/020000_validation_security_audit | docs/062000_validation_security_audit_privacy_and_compliance | RenameDomain | Validation, security, audit, privacy, and compliance lane. | 95 | 95 | 1000 slots | P2 | Medium | Yes | Yes | Yes | Near 100-file threshold. |
| docs/021000_financial_security_monitoring_catalog | docs/066000_financial_security_monitoring_audit_ledger_and_legal_hold | RenameDomain | Financial security monitoring, audit ledger, and legal hold lane. | 32 | 32 | 1000 slots | P2 | Low | Yes | Yes | Yes | Cross-reference payment domain. |
| docs/022000_implementation_planning | docs/070000_release_change_migration_backfill_cutover_and_deployment/implementation_planning | Reclassify | Planning should live with release/change/deployment delivery control. | 47 | 47 | 1000 slots | P3 | Low | Yes | Yes | Yes | Consider 090000 if tooling/AI handoff dominates. |
| docs/024000_deployment_operations | docs/070000_release_change_migration_backfill_cutover_and_deployment/deployment_operations | Reclassify | Deployment operation belongs with release/change/cutover/deployment. | 20 | 20 | 1000 slots | P3 | Low | Yes | Yes | Yes | Operations incident content may move to 074000. |
| docs/026000_analytics_reporting_bi | docs/078000_analytics_reporting_bi_metric_and_benchmark_catalog | RenameDomain | Analytics, reporting, BI, metrics, and benchmark lane. | 6 | 6 | 1000 slots | P3 | Low | Yes | Yes | Yes | Low volume. |
| docs/028000_future_expansion | docs/086000_future_expansion_reserved_modules_and_long_term_options | RenameDomain | Future expansion and reserved module lane. | 6 | 6 | 1000 slots | P3 | Low | Yes | Yes | Yes | Low volume. |
| docs/030000_future_saas_modules | docs/086000_future_expansion_reserved_modules_and_long_term_options/future_saas_modules | Reclassify | Future SaaS modules belong with future expansion/reserved options. | 10 | 10 | 1000 slots | P3 | Low | Yes | Yes | Yes | Could be subfolder under 086000. |
| docs/040000_menu_taxonomy_and_ai_classification | docs/010000_menu_content_taxonomy_recipe_and_i18n_runtime | RenameDomain | Menu taxonomy, recipe-adjacent content, AI classification, and I18n runtime. | 20 | 20 | 1000 slots | P2 | Low | Yes | Yes | Yes | Keep SOP content outside docs. |
| docs/064000_runtime_flow_bundle | docs/700000_runtime_flow_bundle_dependency_graph_and_execution_trace | MoveToHighRange | Runtime flow bundle and dependency graph are high-range by governance. | 20 | 20 | 1000 slots | P1 | Low | Yes | Yes | Yes | Should separate from normal low-range docs design lanes. |
| docs/root_governance_files | docs/000000_project_governance_and_document_control | ConsolidateLater | Root governance files should eventually live under governance/document control. | 0 | 0 | 1000 slots | P3 | Medium | Yes | Yes | Yes | Do not move until root index policy is approved. |

## 2 Batch Notes

- `MoveToHighRange` means the content type belongs outside the low `000000~099999` docs development design range.
- `RenameDomain` means the folder can keep its content but should adopt the v0.4 domain name and band.
- `Reclassify` means a human review should decide whether all files move together or split by subdomain.
- `NumberAnomaly` means the current folder lacks a numeric prefix and should be numbered before later file-level migration.
