# Low-Confidence DocumentType Classification Wave 01 Report

## Summary
- Low-confidence files selected: 30
- Files renamed: 10
- Files moved: 0
- Files skipped/manual: 20
- New DocumentType decision candidates: 20
- Special exceptions identified: 0
- Remaining low-confidence files unprocessed: 59
- Remaining medium manual-review files: 5
- Remaining repository-wide duplicate prefix groups: 0
- Remaining Markdown paths over 240 chars: 0
- Remaining Markdown paths over 220 chars: 47
- Remaining non-compliant filenames: 633

## Classified By Category
- needs_new_document_type_decision: 20
- safe_rename: 10

## Files Renamed
| From | To | DocumentType | Reason |
|---|---|---|---|
| `docs/20000_validation_security_audit/20060_Anonymization_And_Pseudonymization_Standard.md` | `docs/20000_validation_security_audit/20060_Policy_Anonymization_And_Pseudonymization_Standard.md` | `Policy` | Standard defines conceptual rules in validation/security context; Standard safely maps to Policy. |
| `docs/20000_validation_security_audit/20110_Retention_Deletion_Anonymization_Consolidation.md` | `docs/20000_validation_security_audit/20110_Governance_Retention_Deletion_Anonymization_Consolidation.md` | `Governance` | Document states it is governance-only consolidation of retention/deletion/anonymization rules. |
| `docs/21000_financial_security_monitoring_catalog/09632_Containment_Status_And_Trigger_Map_Catalog.md` | `docs/21000_financial_security_monitoring_catalog/09632_Index_Containment_Status_And_Trigger_Map_Catalog.md` | `Index` | Catalog-only status/trigger map is an index-style controlled catalog. |
| `docs/21000_financial_security_monitoring_catalog/09633_Quarantine_Status_And_Trigger_Map_Catalog.md` | `docs/21000_financial_security_monitoring_catalog/09633_Index_Quarantine_Status_And_Trigger_Map_Catalog.md` | `Index` | Catalog-only status/trigger map is an index-style controlled catalog. |
| `docs/21000_financial_security_monitoring_catalog/09634_Security_Control_Records_And_Security_Class_Catalog.md` | `docs/21000_financial_security_monitoring_catalog/09634_Index_Security_Control_Records_And_Security_Class_Catalog.md` | `Index` | Security control records/security class catalog is an index-style catalog, not an operational register instance. |
| `docs/21000_financial_security_monitoring_catalog/09635_Security_Event_Alert_Families_And_Severity_Routing_Catalog.md` | `docs/21000_financial_security_monitoring_catalog/09635_Index_Security_Event_Alert_Families_And_Severity_Routing_Catalog.md` | `Index` | Event/alert family catalog is an index-style catalog. |
| `docs/21000_financial_security_monitoring_catalog/09638_Monitoring_View_And_Risk_Projection_Contract.md` | `docs/21000_financial_security_monitoring_catalog/09638_Spec_Monitoring_View_And_Risk_Projection_Contract.md` | `Spec` | Contract defines future projection/monitoring view contract; Contract safely maps to Spec. |
| `docs/21000_financial_security_monitoring_catalog/09641_Retention_Tier_Archive_Naming_Manifest_And_Lifecycle_Catalog.md` | `docs/21000_financial_security_monitoring_catalog/09641_Index_Retention_Tier_Archive_Naming_Manifest_And_Lifecycle_Catalog.md` | `Index` | Retention/archive lifecycle catalog is an index-style controlled catalog. |
| `docs/21000_financial_security_monitoring_catalog/09642_Legal_Hold_Deletion_Anonymization_And_Retention_Review_Catalog.md` | `docs/21000_financial_security_monitoring_catalog/09642_Index_Legal_Hold_Deletion_Anonymization_And_Retention_Review_Catalog.md` | `Index` | Legal hold/deletion/anonymization review catalog is an index-style controlled catalog. |
| `docs/26000_analytics_reporting_bi/26020_Operational_Metrics_Catalog.md` | `docs/26000_analytics_reporting_bi/26020_Index_Operational_Metrics_Catalog.md` | `Index` | Operational metrics catalog is an index of conceptual metric families. |

## New DocumentType Decision Candidates
| File | Reason |
|---|---|
| `docs/13000_app_api_projection/13010_App_Surface_And_Channel_Projection.md` | Projection is not an approved DocumentType; mapping to Spec/Report/Policy would be subjective without a project-level decision. |
| `docs/13000_app_api_projection/13020_Customer_Webapp_Projection.md` | Projection is not an approved DocumentType; mapping to Spec/Report/Policy would be subjective without a project-level decision. |
| `docs/13000_app_api_projection/13030_Store_Console_Projection.md` | Projection is not an approved DocumentType; mapping to Spec/Report/Policy would be subjective without a project-level decision. |
| `docs/13000_app_api_projection/13040_Admin_Console_Projection.md` | Projection is not an approved DocumentType; mapping to Spec/Report/Policy would be subjective without a project-level decision. |
| `docs/13000_app_api_projection/13090_Surface_To_Authority_Projection_Model.md` | Projection is not an approved DocumentType; mapping to Spec/Report/Policy would be subjective without a project-level decision. |
| `docs/17000_ui_screen_composition/17010_Customer_Webapp_UI_Composition.md` | UI Composition is not an approved DocumentType; mapping to Spec/Guide/Policy needs a project-level decision. |
| `docs/17000_ui_screen_composition/17020_Mini_Kiosk_UI_Composition.md` | UI Composition is not an approved DocumentType; mapping to Spec/Guide/Policy needs a project-level decision. |
| `docs/17000_ui_screen_composition/17030_Store_Console_UI_Composition.md` | UI Composition is not an approved DocumentType; mapping to Spec/Guide/Policy needs a project-level decision. |
| `docs/17000_ui_screen_composition/17040_Admin_Console_UI_Composition.md` | UI Composition is not an approved DocumentType; mapping to Spec/Guide/Policy needs a project-level decision. |
| `docs/17000_ui_screen_composition/17050_Support_Console_UI_Composition.md` | UI Composition is not an approved DocumentType; mapping to Spec/Guide/Policy needs a project-level decision. |
| `docs/17000_ui_screen_composition/17080_UI_Surface_To_Authority_Composition_Model.md` | Model is not an approved DocumentType; mapping to Spec/Implementation/Matrix/Policy is context-dependent. |
| `docs/17000_ui_screen_composition/17090_Integration_Status_UI_Wording_Model.md` | Model is not an approved DocumentType; mapping to Spec/Implementation/Matrix/Policy is context-dependent. |
| `docs/21000_financial_security_monitoring_catalog/09630_Financial-Grade_Security_Monitoring_Foundation_Catalog_Execution_Plan_And_Artifact_Map.md` | Plan/Map is not an approved DocumentType; this item needs a project-level type decision. |
| `docs/21000_financial_security_monitoring_catalog/09644_Patent_Security_Monitoring_Architecture_Summary_And_Claim_Support_Feature_Map.md` | Plan/Map is not an approved DocumentType; this item needs a project-level type decision. |
| `docs/28000_future_expansion/28020_Membership_Loyalty_Point_Future_Model.md` | Model is not an approved DocumentType; mapping to Spec/Implementation/Matrix/Policy is context-dependent. |
| `docs/28000_future_expansion/28040_Data_Ad_CRM_AI_Future_Expansion_Model.md` | Model is not an approved DocumentType; mapping to Spec/Implementation/Matrix/Policy is context-dependent. |
| `docs/28000_future_expansion/28060_Franchise_Intelligence_Feedback_Loop_Model.md` | Model is not an approved DocumentType; mapping to Spec/Implementation/Matrix/Policy is context-dependent. |
| `docs/30000_future_saas_modules/30090_Dual_Track_External_Alliance_And_Native_Service_Strategy.md` | Strategy is not an approved DocumentType; mapping to Policy/Assessment/Report is subjective here. |
| `docs/07000_admin_console/07010_Admin_Console_Context_And_Role_Model.md` | Model is not an approved DocumentType; mapping to Spec/Implementation/Matrix/Policy is context-dependent. |
| `docs/09000_data_model_state_machine/09010_Data_Model_Draft.md` | Model is not an approved DocumentType; mapping to Spec/Implementation/Matrix/Policy is context-dependent. |

## Special Exceptions
- None

## Files Skipped
- `docs/13000_app_api_projection/13010_App_Surface_And_Channel_Projection.md` (needs_new_document_type_decision): Projection is not an approved DocumentType; mapping to Spec/Report/Policy would be subjective without a project-level decision.
- `docs/13000_app_api_projection/13020_Customer_Webapp_Projection.md` (needs_new_document_type_decision): Projection is not an approved DocumentType; mapping to Spec/Report/Policy would be subjective without a project-level decision.
- `docs/13000_app_api_projection/13030_Store_Console_Projection.md` (needs_new_document_type_decision): Projection is not an approved DocumentType; mapping to Spec/Report/Policy would be subjective without a project-level decision.
- `docs/13000_app_api_projection/13040_Admin_Console_Projection.md` (needs_new_document_type_decision): Projection is not an approved DocumentType; mapping to Spec/Report/Policy would be subjective without a project-level decision.
- `docs/13000_app_api_projection/13090_Surface_To_Authority_Projection_Model.md` (needs_new_document_type_decision): Projection is not an approved DocumentType; mapping to Spec/Report/Policy would be subjective without a project-level decision.
- `docs/17000_ui_screen_composition/17010_Customer_Webapp_UI_Composition.md` (needs_new_document_type_decision): UI Composition is not an approved DocumentType; mapping to Spec/Guide/Policy needs a project-level decision.
- `docs/17000_ui_screen_composition/17020_Mini_Kiosk_UI_Composition.md` (needs_new_document_type_decision): UI Composition is not an approved DocumentType; mapping to Spec/Guide/Policy needs a project-level decision.
- `docs/17000_ui_screen_composition/17030_Store_Console_UI_Composition.md` (needs_new_document_type_decision): UI Composition is not an approved DocumentType; mapping to Spec/Guide/Policy needs a project-level decision.
- `docs/17000_ui_screen_composition/17040_Admin_Console_UI_Composition.md` (needs_new_document_type_decision): UI Composition is not an approved DocumentType; mapping to Spec/Guide/Policy needs a project-level decision.
- `docs/17000_ui_screen_composition/17050_Support_Console_UI_Composition.md` (needs_new_document_type_decision): UI Composition is not an approved DocumentType; mapping to Spec/Guide/Policy needs a project-level decision.
- `docs/17000_ui_screen_composition/17080_UI_Surface_To_Authority_Composition_Model.md` (needs_new_document_type_decision): Model is not an approved DocumentType; mapping to Spec/Implementation/Matrix/Policy is context-dependent.
- `docs/17000_ui_screen_composition/17090_Integration_Status_UI_Wording_Model.md` (needs_new_document_type_decision): Model is not an approved DocumentType; mapping to Spec/Implementation/Matrix/Policy is context-dependent.
- `docs/21000_financial_security_monitoring_catalog/09630_Financial-Grade_Security_Monitoring_Foundation_Catalog_Execution_Plan_And_Artifact_Map.md` (needs_new_document_type_decision): Plan/Map is not an approved DocumentType; this item needs a project-level type decision.
- `docs/21000_financial_security_monitoring_catalog/09644_Patent_Security_Monitoring_Architecture_Summary_And_Claim_Support_Feature_Map.md` (needs_new_document_type_decision): Plan/Map is not an approved DocumentType; this item needs a project-level type decision.
- `docs/28000_future_expansion/28020_Membership_Loyalty_Point_Future_Model.md` (needs_new_document_type_decision): Model is not an approved DocumentType; mapping to Spec/Implementation/Matrix/Policy is context-dependent.
- `docs/28000_future_expansion/28040_Data_Ad_CRM_AI_Future_Expansion_Model.md` (needs_new_document_type_decision): Model is not an approved DocumentType; mapping to Spec/Implementation/Matrix/Policy is context-dependent.
- `docs/28000_future_expansion/28060_Franchise_Intelligence_Feedback_Loop_Model.md` (needs_new_document_type_decision): Model is not an approved DocumentType; mapping to Spec/Implementation/Matrix/Policy is context-dependent.
- `docs/30000_future_saas_modules/30090_Dual_Track_External_Alliance_And_Native_Service_Strategy.md` (needs_new_document_type_decision): Strategy is not an approved DocumentType; mapping to Policy/Assessment/Report is subjective here.
- `docs/07000_admin_console/07010_Admin_Console_Context_And_Role_Model.md` (needs_new_document_type_decision): Model is not an approved DocumentType; mapping to Spec/Implementation/Matrix/Policy is context-dependent.
- `docs/09000_data_model_state_machine/09010_Data_Model_Draft.md` (needs_new_document_type_decision): Model is not an approved DocumentType; mapping to Spec/Implementation/Matrix/Policy is context-dependent.

## Index / Map / README / Reference Updates
- `docs/00005_Document_Number_Index.md`
- `docs/00007_Full_Directory_Map.md`
- `docs/09000_data_model_state_machine/09110_Boundary_Future_Profile_And_Analytics_State.md`
- `docs/20000_validation_security_audit/20000_Readme_Validation_Security_Audit.md`
- `docs/20000_validation_security_audit/20060_Policy_Anonymization_And_Pseudonymization_Standard.md`
- `docs/20000_validation_security_audit/20110_Governance_Retention_Deletion_Anonymization_Consolidation.md`
- `docs/20000_validation_security_audit/20180_Audit_Evidence_Packet_And_Runtime_Forensics_Governance.md`
- `docs/20000_validation_security_audit/20190_Governance_Customer_Privacy_And_Consent.md`
- `docs/21000_financial_security_monitoring_catalog/09632_Index_Containment_Status_And_Trigger_Map_Catalog.md`
- `docs/21000_financial_security_monitoring_catalog/09633_Index_Quarantine_Status_And_Trigger_Map_Catalog.md`
- `docs/21000_financial_security_monitoring_catalog/09634_Index_Security_Control_Records_And_Security_Class_Catalog.md`
- `docs/21000_financial_security_monitoring_catalog/09635_Index_Security_Event_Alert_Families_And_Severity_Routing_Catalog.md`
- `docs/21000_financial_security_monitoring_catalog/09638_Spec_Monitoring_View_And_Risk_Projection_Contract.md`
- `docs/21000_financial_security_monitoring_catalog/09641_Index_Retention_Tier_Archive_Naming_Manifest_And_Lifecycle_Catalog.md`
- `docs/21000_financial_security_monitoring_catalog/09642_Index_Legal_Hold_Deletion_Anonymization_And_Retention_Review_Catalog.md`
- `docs/21000_financial_security_monitoring_catalog/21000_Readme_Financial_Security_Monitoring_Catalog.md`
- `docs/22000_implementation_planning/22030_Checklist_Schema_Design_Readiness.md`
- `docs/26000_analytics_reporting_bi/26000_Readme_Analytics_Reporting_Bi.md`
- `docs/26000_analytics_reporting_bi/26010_Boundary_Analytics_Product.md`
- `docs/26000_analytics_reporting_bi/26020_Index_Operational_Metrics_Catalog.md`
- `docs/26000_analytics_reporting_bi/26040_Boundary_Cross_Tenant_Benchmark_And_Data_Sharing.md`
- `migration_manifest_md_naming_prefix.json`
- `migration_precleanup_type_review_report.json`
- `migration_precleanup_type_review_report.md`

## Validation
- UTF-8 validation: edited files pass; repo-wide has pre-existing non-UTF-8 exception(s)
- Repo-wide UTF-8 exceptions: docs/directory_tree.txt
- Korean readability check: pass (444 files with Korean text scanned)
- Implementation files touched: none
- SQL/migration/Flutter/code files created or edited: none
- Staged files: none
