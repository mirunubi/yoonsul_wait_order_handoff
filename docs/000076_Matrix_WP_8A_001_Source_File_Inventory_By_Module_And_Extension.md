# 000076_Matrix_WP_8A_001_Source_File_Inventory_By_Module_And_Extension.md

## Purpose

Map tracked source, placeholder, config, test, SQL, and Dart/Flutter file inventory for WP-8A-001.

## Source-To-Module Inventory Table

| Path | Extension | CandidateModule | CurrentRole | Owner |
|---|---|---|---|---|
| apps/customer-web/.gitkeep | <none> | apps | Tracked placeholder/source inventory item | TBD |
| apps/staff-web/.gitkeep | <none> | apps | Tracked placeholder/source inventory item | TBD |
| data/seed/.gitkeep | <none> | data | Tracked placeholder/source inventory item | TBD |
| packages/domain/.gitkeep | <none> | packages | Tracked placeholder/source inventory item | TBD |
| packages/ui/.gitkeep | <none> | packages | Tracked placeholder/source inventory item | TBD |
| tests/.gitkeep | <none> | tests | Tracked placeholder/source inventory item | TBD |

## Extension Count Table

| Extension | TrackedFileCount |
|---|---|
| .md | 2393 |
| .json | 59 |
| .sql | 0 |
| .dart | 0 |
| .ts | 0 |
| .js | 0 |
| .yaml | 0 |
| .yml | 0 |
| .toml | 0 |
| .mdc | 1 |
| .txt | 1 |
| <none> | 7 |

## Candidate Module Table

| CandidateModule | PathPattern | TrackedFiles | InspectionFinding | Notes |
|---|---|---|---|---|
| Repository root governance | root | 118 | README, gitignore, migration evidence artifacts | Documentation/evidence only |
| Apps placeholder surface | apps/ | 2 | customer-web, staff-web placeholders | No runtime files tracked |
| Packages placeholder surface | packages/ | 2 | domain/ui placeholders | No runtime files tracked |
| Data seed placeholder surface | data/ | 1 | seed placeholder | No SQL/data mutation |
| Tests placeholder surface | tests/ | 1 | test root placeholder | No test execution |
| Documentation corpus | docs/ | 2336 | six-digit docs corpus | Docs-only inspection |
| Migration evidence archive | migration_* | 116 | historical root migration evidence | No edits |

## Test File Mapping Table

| Path | Category | ExecutionAuthorized | Notes |
|---|---|---|---|
| docs/000100_project_foundation/000450_documentation_governance/000456_Policy_Test_Extraction_Evidence_Packet_And_Verification_Case_Mapping.md | test-like path/name | No | Read-only discovery only |
| docs/003000_saas_runtime/003140_Policy_Entry_Media_Test_Field_Sample_And_Production_Separation.md | test-like path/name | No | Read-only discovery only |
| docs/004000_store_runtime_pos_kds_operations/004300_pos_provider_adapter_governance/004350_Policy_POS_Adapter_Test_Harness_And_Certification_Scenario.md | test-like path/name | No | Read-only discovery only |
| docs/004900_security_runtime_test_catalog/004900_Readme_Security_Runtime_Test_Catalog.md | test-like path/name | No | Read-only discovery only |
| docs/004900_security_runtime_test_catalog/004970_Policy_Security_And_Runtime_Test_Catalog_Lane_Start_And_Verification_Governance.md | test-like path/name | No | Read-only discovery only |
| docs/004900_security_runtime_test_catalog/004971_Policy_Security_And_Runtime_Test_Catalog_Lane_Start_And_Verification_Governance.md | test-like path/name | No | Read-only discovery only |
| docs/004900_security_runtime_test_catalog/004980_Policy_Tenant_Store_RLS_Access_Control_Test_Catalog.md | test-like path/name | No | Read-only discovery only |
| docs/004900_security_runtime_test_catalog/004981_Policy_Tenant_Store_RLS_Access_Control_Test_Catalog.md | test-like path/name | No | Read-only discovery only |
| docs/004900_security_runtime_test_catalog/004990_Audit_Append_Only_Evidence_And_Tamper_Resistance_Test_Catalog_Policy.md | test-like path/name | No | Read-only discovery only |
| docs/004900_security_runtime_test_catalog/004991_Audit_Append_Only_Evidence_And_Tamper_Resistance_Test_Catalog.md | test-like path/name | No | Read-only discovery only |
| docs/004900_security_runtime_test_catalog/004999_archive_duplicate_review/005106_Policy_Test_Catalog_Lane_Index_Readiness_Check_And_Evidence_Handoff.md | test-like path/name | No | Read-only discovery only |
| docs/004900_security_runtime_test_catalog/004999_archive_duplicate_review/005111_Implementation_Readiness_Backlog_And_Test_Execution_Planning.md | test-like path/name | No | Read-only discovery only |
| docs/004900_security_runtime_test_catalog/004999_archive_duplicate_review/005121_Policy_Runtime_Owner_Registry_And_Implementation_Responsibility_Matrix.md | test-like path/name | No | Read-only discovery only |
| docs/004900_security_runtime_test_catalog/004999_archive_duplicate_review/005131_Evidence_Packet_Template_And_Test_Result_Recording.md | test-like path/name | No | Read-only discovery only |
| docs/004900_security_runtime_test_catalog/004999_archive_duplicate_review/005141_Policy_Blocker_Register_Waiver_Deferred_Scope_And_Risk_Acceptance.md | test-like path/name | No | Read-only discovery only |
| docs/004900_security_runtime_test_catalog/005000_Policy_POS_KDS_RPC_Bridge_Idempotency_Replay_Test_Catalog.md | test-like path/name | No | Read-only discovery only |
| docs/004900_security_runtime_test_catalog/005001_Policy_POS_KDS_RPC_Bridge_Idempotency_Replay_Test_Catalog.md | test-like path/name | No | Read-only discovery only |
| docs/004900_security_runtime_test_catalog/005010_Policy_Payment_Webhook_Refund_Settlement_Reconciliation_Test_Catalog.md | test-like path/name | No | Read-only discovery only |
| docs/004900_security_runtime_test_catalog/005011_Policy_Payment_Webhook_Refund_Settlement_Reconciliation_Test_Catalog.md | test-like path/name | No | Read-only discovery only |
| docs/004900_security_runtime_test_catalog/005020_Policy_CI_DI_Identity_Callback_Masking_Leakage_Test_Catalog.md | test-like path/name | No | Read-only discovery only |
| docs/004900_security_runtime_test_catalog/005021_Policy_CI_DI_Identity_Callback_Masking_Leakage_Test_Catalog.md | test-like path/name | No | Read-only discovery only |
| docs/004900_security_runtime_test_catalog/005030_Policy_Support_Access_Masking_Break_Glass_Scoped_Session_Test_Catalog.md | test-like path/name | No | Read-only discovery only |
| docs/004900_security_runtime_test_catalog/005031_Policy_Support_Access_Masking_Break_Glass_Scoped_Session_Test_Catalog.md | test-like path/name | No | Read-only discovery only |
| docs/004900_security_runtime_test_catalog/005040_Policy_Device_Trust_Session_Revocation_Lost_Device_Test_Catalog.md | test-like path/name | No | Read-only discovery only |
| docs/004900_security_runtime_test_catalog/005041_Policy_Device_Trust_Session_Revocation_Lost_Device_Test_Catalog.md | test-like path/name | No | Read-only discovery only |
| docs/004900_security_runtime_test_catalog/005050_Policy_Local_Agent_Degraded_Recovery_Sync_Conflict_Test_Catalog.md | test-like path/name | No | Read-only discovery only |
| docs/004900_security_runtime_test_catalog/005051_Policy_Local_Agent_Degraded_Recovery_Sync_Conflict_Test_Catalog.md | test-like path/name | No | Read-only discovery only |
| docs/004900_security_runtime_test_catalog/005060_Policy_Export_Report_Benchmark_External_Sharing_Test_Catalog.md | test-like path/name | No | Read-only discovery only |
| docs/004900_security_runtime_test_catalog/005061_Policy_Export_Report_Benchmark_External_Sharing_Test_Catalog.md | test-like path/name | No | Read-only discovery only |
| docs/004900_security_runtime_test_catalog/005070_Policy_AI_Analytics_Dataset_Minimization_Recommendation_Boundary_Test_Catalog.md | test-like path/name | No | Read-only discovery only |
| docs/004900_security_runtime_test_catalog/005071_Policy_AI_Analytics_Dataset_Minimization_Recommendation_Boundary_Test_Catalog.md | test-like path/name | No | Read-only discovery only |
| docs/004900_security_runtime_test_catalog/005080_Policy_Vendor_Partner_Access_External_Integration_Test_Catalog.md | test-like path/name | No | Read-only discovery only |
| docs/004900_security_runtime_test_catalog/005081_Policy_Vendor_Partner_Access_External_Integration_Test_Catalog.md | test-like path/name | No | Read-only discovery only |
| docs/004900_security_runtime_test_catalog/005090_Policy_Secure_Deployment_Release_Gate_Rollback_Test_Catalog.md | test-like path/name | No | Read-only discovery only |
| docs/004900_security_runtime_test_catalog/005091_Policy_Secure_Deployment_Release_Gate_Rollback_Test_Catalog.md | test-like path/name | No | Read-only discovery only |
| docs/004900_security_runtime_test_catalog/005095_Policy_Toss_POS_Integration_Implementation_Approach_And_Test_Mapping.md | test-like path/name | No | Read-only discovery only |
| docs/004900_security_runtime_test_catalog/005096_Policy_Toss_POS_Integration_Implementation_Approach_And_Test_Mapping.md | test-like path/name | No | Read-only discovery only |
| docs/004900_security_runtime_test_catalog/005100_Policy_Test_Catalog_Lane_Index_Readiness_Check_And_Evidence_Handoff.md | test-like path/name | No | Read-only discovery only |
| docs/005000_customer_handoff_and_implementation_readiness/005000_customer_handoff_flow/006790_Runbook_Customer_Runtime_Display_QA_Execution_Defect_Retest_Acceptance_And_Rollout_Handoff.md | test-like path/name | No | Read-only discovery only |
| docs/005000_customer_handoff_and_implementation_readiness/005000_customer_handoff_flow/006800_Template_Customer_Runtime_Display_QA_Defect_Retest_Acceptance_Rollout_Handoff_And_Evidence_Record.md | test-like path/name | No | Read-only discovery only |
| docs/005000_customer_handoff_and_implementation_readiness/005000_customer_handoff_flow/006810_Register_Customer_Runtime_Display_QA_Defect_Retest_Waiver_Blocker_Rollout_And_Backlog_Control.md | test-like path/name | No | Read-only discovery only |
| docs/005000_customer_handoff_and_implementation_readiness/005100_implementation_readiness_and_provider_verification/005106_Policy_Test_Catalog_Lane_Index_Readiness_Check_And_Evidence_Handoff.md | test-like path/name | No | Read-only discovery only |
| docs/005000_customer_handoff_and_implementation_readiness/005100_implementation_readiness_and_provider_verification/005110_Implementation_Readiness_Backlog_And_Test_Execution_Planning_Policy.md | test-like path/name | No | Read-only discovery only |
| docs/005000_customer_handoff_and_implementation_readiness/005100_implementation_readiness_and_provider_verification/005111_Implementation_Readiness_Backlog_And_Test_Execution_Planning.md | test-like path/name | No | Read-only discovery only |
| docs/005000_customer_handoff_and_implementation_readiness/005100_implementation_readiness_and_provider_verification/005130_Evidence_Packet_Template_And_Test_Result_Recording_Policy.md | test-like path/name | No | Read-only discovery only |
| docs/005000_customer_handoff_and_implementation_readiness/005100_implementation_readiness_and_provider_verification/005131_Evidence_Packet_Template_And_Test_Result_Recording.md | test-like path/name | No | Read-only discovery only |
| docs/005000_customer_handoff_and_implementation_readiness/005200_pos_payment_provider_and_kiosk_reuse/005250_Policy_OKPOS_OKDC_Integration_Implementation_Approach_And_Test_Mapping.md | test-like path/name | No | Read-only discovery only |
| docs/005000_customer_handoff_and_implementation_readiness/005200_pos_payment_provider_and_kiosk_reuse/005251_Policy_OKPOS_OKDC_Integration_Implementation_Approach_And_Test_Mapping.md | test-like path/name | No | Read-only discovery only |
| docs/010000_runtime_foundation_and_cross_room_architecture/010000_static_catalog_runtime_planning/009720_Boundary_Test_Matrix_Artifact_Planning_And_Review_Packet.md | test-like path/name | No | Read-only discovery only |
| docs/010000_runtime_foundation_and_cross_room_architecture/010000_static_catalog_runtime_planning/009880_Boundary_Incident_Learning_Test_Matrix_Update_And_Policy_Patch_Handoff.md | test-like path/name | No | Read-only discovery only |
| docs/010000_runtime_foundation_and_cross_room_architecture/010000_static_catalog_runtime_planning/009920_Boundary_Test_Matrix_Static_Package_Handoff_And_Validation_Mapping.md | test-like path/name | No | Read-only discovery only |
| docs/011000_integration_boundary/011160_Policy_OKPOS_OKDC_Integration_Implementation_Approach_And_Test_Mapping.md | test-like path/name | No | Read-only discovery only |
| docs/014000_pos_provider_integration_strategy/005390_Policy_Pilot_Store_Register_Test_Partner_Selection_And_Scope_Control.md | test-like path/name | No | Read-only discovery only |
| docs/014000_pos_provider_integration_strategy/005400_Policy_Pilot_Evidence_Packet_Template_And_Store_Test_Result_Recording.md | test-like path/name | No | Read-only discovery only |
| docs/014000_pos_provider_integration_strategy/014021_Policy_Pilot_Store_Register_Test_Partner_Scope_Control.md | test-like path/name | No | Read-only discovery only |
| docs/014000_pos_provider_integration_strategy/014023_Policy_Pilot_Evidence_Packet_Test_Result_Recording.md | test-like path/name | No | Read-only discovery only |
| docs/014000_pos_provider_integration_strategy/014041_Policy_POS_Provider_Test_Fixture_And_Simulation_Scenario.md | test-like path/name | No | Read-only discovery only |
| docs/014000_pos_provider_integration_strategy/014060_Policy_Phase_1_Runtime_Transition_Test_Evidence.md | test-like path/name | No | Read-only discovery only |
| docs/014000_pos_provider_integration_strategy/014062_Register_Phase_1_Pilot_Readiness_Gate_Test_Blocker.md | test-like path/name | No | Read-only discovery only |
| docs/014000_pos_provider_integration_strategy/014116_Policy_POS_Gateway_Provider_Route_Certification_Sandbox_Test_Result_And_Production_Approval_Evidence.md | test-like path/name | No | Read-only discovery only |
| docs/014000_pos_provider_integration_strategy/014121_Policy_POS_Gateway_Production_Readiness_Checklist_Smoke_Test_And_Operational_Acceptance.md | test-like path/name | No | Read-only discovery only |
| docs/014000_pos_provider_integration_strategy/archive_duplicate_review/005250_Policy_OKPOS_OKDC_Integration_Implementation_Approach_And_Test_Mapping.md | test-like path/name | No | Read-only discovery only |
| docs/019000_data_model_state_machine_runtime_event_contract/019176_Overview_Test_Fixture_Mock_Event_Model.md | test-like path/name | No | Read-only discovery only |
| docs/019000_data_model_state_machine_runtime_event_contract/019177_Matrix_Test_Fixture_Mock_Event_Field_Map.md | test-like path/name | No | Read-only discovery only |
| docs/019000_data_model_state_machine_runtime_event_contract/019178_Checklist_Test_Fixture_Mock_Event_Model_Check.md | test-like path/name | No | Read-only discovery only |
| docs/020000_validation_security_audit/020999_archive_duplicate_review/020993_duplicate_copy_xx01/004661_Policy_Security_Testing_Abuse_Case_Threat_Modeling_And_Verification.md | test-like path/name | No | Read-only discovery only |
| docs/020000_validation_security_audit/020999_archive_duplicate_review/020996_keep_archive_only/004660_Policy_Security_Testing_Abuse_Case_Threat_Modeling_And_Verification.md | test-like path/name | No | Read-only discovery only |
| docs/021000_financial_security_monitoring_catalog/021643_Boundary_Test_Checklist_And_Security_Monitoring_Validation_Matrix.md | test-like path/name | No | Read-only discovery only |
| docs/022000_implementation_planning/022005_Policy_Test_Evidence_Backlog_Linkage_And_Verification_Candidate_Register.md | test-like path/name | No | Read-only discovery only |
| docs/022000_implementation_planning/022014_Policy_Test_Evidence_Readiness_And_Manual_Review_Gate.md | test-like path/name | No | Read-only discovery only |
| docs/022000_implementation_planning/022050_Boundary_QA_Smoke_Test_And_Rollback_Planning.md | test-like path/name | No | Read-only discovery only |
| docs/023000_implementation_planning/023130_Plan_Claude_Overview_Logic_Test_Preparation_Plan.md | test-like path/name | No | Read-only discovery only |
| docs/023000_implementation_planning/023131_Template_Claude_Overview_Logic_Test_Prompt_Template.md | test-like path/name | No | Read-only discovery only |
| docs/023000_implementation_planning/023132_Checklist_Claude_Overview_Logic_Test_Readiness_Check.md | test-like path/name | No | Read-only discovery only |
| docs/023000_implementation_planning/023134_Report_Claude_Overview_Logic_Test_Findings_Report.md | test-like path/name | No | Read-only discovery only |
| docs/023000_implementation_planning/023172_Checklist_Test_Data_Readiness_Check.md | test-like path/name | No | Read-only discovery only |
| docs/023000_implementation_planning/023173_Matrix_Test_Data_Source_To_Verification_Matrix.md | test-like path/name | No | Read-only discovery only |
| docs/024000_deployment_operations/024070_Policy_Secure_Deployment_Release_Gate_Rollback_Test_Catalog.md | test-like path/name | No | Read-only discovery only |
| docs/024000_deployment_operations/024120_Policy_Pilot_Store_Register_Test_Partner_Selection_And_Scope_Control.md | test-like path/name | No | Read-only discovery only |
| docs/024000_deployment_operations/024130_Policy_Pilot_Evidence_Packet_Template_And_Store_Test_Result_Recording.md | test-like path/name | No | Read-only discovery only |

## Config File Mapping Table

| Path | Extension | Category | MutationAllowed |
|---|---|---|---|
| .cursor/rules/yoonsul_wait_order_handoff_cursor_rules.mdc | .mdc | config/evidence candidate | No |
| .gitignore | <none> | config/evidence candidate | No |
| README.md | .md | config/evidence candidate | No |
| migration_direct_md_rename_heading_folder_placement_report.json | .json | config/evidence candidate | No |
| migration_duplicate_prefix_resolution_wave_01_report.json | .json | config/evidence candidate | No |
| migration_duplicate_prefix_resolution_wave_02_report.json | .json | config/evidence candidate | No |
| migration_duplicate_prefix_resolution_wave_03_report.json | .json | config/evidence candidate | No |
| migration_duplicate_prefix_resolution_wave_04_10609_report.json | .json | config/evidence candidate | No |
| migration_duplicate_prefix_resolution_wave_05_report.json | .json | config/evidence candidate | No |
| migration_duplicate_prefix_resolution_wave_06_root_05300_05900_report.json | .json | config/evidence candidate | No |
| migration_final_critical_cleanup_pass_01_report.json | .json | config/evidence candidate | No |
| migration_final_docs_tree_validation_scan_02_report.json | .json | config/evidence candidate | No |
| migration_final_docs_tree_validation_scan_03_report.json | .json | config/evidence candidate | No |
| migration_final_docs_tree_validation_scan_report.json | .json | config/evidence candidate | No |
| migration_final_long_path_240_cleanup_report.json | .json | config/evidence candidate | No |
| migration_fix_08000_duplicate_prefix_report.json | .json | config/evidence candidate | No |
| migration_folder_00100_recursive_filename_heading_pass_report.json | .json | config/evidence candidate | No |
| migration_folder_01000_recursive_filename_heading_pass_report.json | .json | config/evidence candidate | No |
| migration_folder_03000_recursive_filename_heading_pass_report.json | .json | config/evidence candidate | No |
| migration_folder_04000_recursive_filename_heading_pass_report.json | .json | config/evidence candidate | No |
| migration_folder_04900_recursive_filename_heading_pass_report.json | .json | config/evidence candidate | No |
| migration_folder_05000_recursive_filename_heading_pass_report.json | .json | config/evidence candidate | No |
| migration_folder_07000_recursive_filename_heading_pass_report.json | .json | config/evidence candidate | No |
| migration_folder_08000_recursive_filename_heading_pass_report.json | .json | config/evidence candidate | No |
| migration_folder_09000_recursive_filename_heading_pass_report.json | .json | config/evidence candidate | No |
| migration_folder_10000_recursive_filename_heading_pass_report.json | .json | config/evidence candidate | No |
| migration_folder_11000_recursive_filename_heading_pass_report.json | .json | config/evidence candidate | No |
| migration_folder_12000_recursive_filename_heading_pass_report.json | .json | config/evidence candidate | No |
| migration_folder_13000_recursive_filename_heading_pass_report.json | .json | config/evidence candidate | No |
| migration_folder_14000_recursive_filename_heading_pass_report.json | .json | config/evidence candidate | No |
| migration_folder_15000_recursive_filename_heading_pass_report.json | .json | config/evidence candidate | No |
| migration_folder_17000_recursive_filename_heading_pass_report.json | .json | config/evidence candidate | No |
| migration_folder_20000_044xx_archive_cleanup_report.json | .json | config/evidence candidate | No |
| migration_folder_20000_foundation_security_rename_report.json | .json | config/evidence candidate | No |
| migration_folder_20000_readme_archive_reference_cleanup_report.json | .json | config/evidence candidate | No |
| migration_folder_20000_recursive_filename_heading_pass_report.json | .json | config/evidence candidate | No |
| migration_folder_20000_security_archive_p1_marker_report.json | .json | config/evidence candidate | No |
| migration_folder_20000_security_archive_physical_split_report.json | .json | config/evidence candidate | No |
| migration_folder_21000_22000_40000_local_number_cleanup_report.json | .json | config/evidence candidate | No |
| migration_folder_21000_recursive_filename_heading_pass_report.json | .json | config/evidence candidate | No |
| migration_folder_22000_recursive_filename_heading_pass_report.json | .json | config/evidence candidate | No |
| migration_folder_24000_recursive_filename_heading_pass_report.json | .json | config/evidence candidate | No |
| migration_folder_26000_recursive_filename_heading_pass_report.json | .json | config/evidence candidate | No |
| migration_folder_28000_recursive_filename_heading_pass_report.json | .json | config/evidence candidate | No |
| migration_folder_30000_recursive_filename_heading_pass_report.json | .json | config/evidence candidate | No |
| migration_folder_40000_recursive_filename_heading_pass_report.json | .json | config/evidence candidate | No |
| migration_high_confidence_doctype_prefix_wave_01_report.json | .json | config/evidence candidate | No |
| migration_high_confidence_doctype_prefix_wave_02_report.json | .json | config/evidence candidate | No |
| migration_high_confidence_doctype_prefix_wave_03_report.json | .json | config/evidence candidate | No |
| migration_long_path_reduction_wave_01_report.json | .json | config/evidence candidate | No |
| migration_long_path_reduction_wave_02_report.json | .json | config/evidence candidate | No |
| migration_low_confidence_classification_wave_01_report.json | .json | config/evidence candidate | No |
| migration_medium_confidence_doctype_prefix_wave_01_report.json | .json | config/evidence candidate | No |
| migration_medium_manual_review_resolution_wave_01_report.json | .json | config/evidence candidate | No |
| migration_precleanup_duplicate_prefix_report.json | .json | config/evidence candidate | No |
| migration_precleanup_long_path_report.json | .json | config/evidence candidate | No |
| migration_precleanup_root_bad_filename_report.json | .json | config/evidence candidate | No |
| migration_precleanup_type_review_report.json | .json | config/evidence candidate | No |
| migration_root_bad_filename_normalization_wave_01_report.json | .json | config/evidence candidate | No |
| migration_root_conflict_review_numbered_archive_report.json | .json | config/evidence candidate | No |
| migration_root_markdown_normalization_and_placement_wave_01_report.json | .json | config/evidence candidate | No |
| migration_root_non_exception_folder_move_pass_01_report.json | .json | config/evidence candidate | No |

## SQL File Mapping Table

| Path | Category | MutationAllowed |
|---|---|---|
| None tracked | SQL | No |

## Dart / Flutter File Mapping Table

| Path | Category | MutationAllowed |
|---|---|---|
| None tracked | Dart/Flutter | No |

## Unknown Owner Table

| Area | Reason | Required Confirmation |
|---|---|---|
| apps/ | Only .gitkeep placeholders tracked | Confirm intended app owner before implementation |
| packages/ | Only .gitkeep placeholders tracked | Confirm package owner before implementation |
| tests/ | Only .gitkeep placeholder tracked | Confirm QA/test owner before test execution |
| docs/ | Large docs corpus | Confirm doc owner for future link/H1 updates |
| migration_* | Historical evidence files tracked at root | Confirm no future mutation needed |

## No-Mutation Statement

This matrix is produced from tracked file inventory only. It does not authorize edits to any source, SQL, Dart/Flutter, Supabase, config, or test file.
