# 00007 Full Directory Map

## 1 Purpose

This document maps only paths inside `yoonsul_wait_order_handoff`.

Documentation paths use five-digit prefixes and approximately 2,000-slot domain bands.

## 2 Root Files

```text
yoonsul_wait_order_handoff/
  README.md
  .gitignore
  apps/
  data/
  docs/
  packages/
  tests/
```

Governance markdown files live under `docs/`, not at the project root.

## 3 Docs Directory Tree

```text
docs/
  00000_Project_Overview.md
  00001_Md_Rules.md
  00002_Naming_Rules.md
  00003_Project_Context.md
  00010_Korean_Document_And_Encoding_Safety_Rules.md
  00005_Document_Number_Index.md
  00007_Full_Directory_Map.md
  00099_Docs_Governance_Checklist.md
  00100_project_foundation/
    00100_Project_Foundation_Readme.md
    00110_Project_Identity_And_Overview.md
    00120_BM_Patent_Linkage.md
    00130_Non_Implementation_Boundary.md
  01000_mvp_scope/
    01000_MVP_Scope_Readme.md
    01010_MVP_Scope.md
    01020_Store_Type_And_Product_Package_Strategy.md
    01030_Competitive_Positioning_And_Market_Context.md
    01040_MVP_Active_Optional_Future_NonGoal_Matrix.md
    01050_MVP_Package_And_Feature_Flag_Boundary.md
    01060_MVP_Store_Type_Adoption_Sequence.md
  03000_saas_runtime/
    03000_SaaS_Runtime_Readme.md
    03010_Tenant_Store_Runtime_And_Package_Model.md
    03020_Tenant_Company_Legal_Operating_Group_Context_Model.md
    03030_Store_Runtime_Profile_Model.md
    03040_Package_Plan_And_Feature_Flag_Runtime_Governance.md
    03050_Runtime_Profile_Change_And_Audit_Governance.md
    03060_Runtime_Profile_Non_MVP_And_Future_Flag_Boundary.md
  05000_customer_handoff_flow/
    05000_Customer_Handoff_Flow_Readme.md
    05010_User_Flow.md
  07000_admin_console/
    07000_Admin_Console_Readme.md
    07010_Admin_Console_Context_And_Role_Model.md
    07020_Admin_Store_Runtime_Configuration_Model.md
    07030_Admin_Operational_Monitoring_And_Recovery_Model.md
    07040_Admin_Screen_Inventory_And_Navigation_Model.md
    07050_Admin_Approval_Workflow_Model.md
    07060_Admin_Audit_And_Recovery_Queue_Governance.md
    07070_Admin_Context_Navigation_And_Scope_Model.md
    07080_Admin_Runtime_Profile_Configuration_Governance.md
    07090_Admin_Feature_Flag_Approval_And_Emergency_Disable_Model.md
    07100_Admin_Audit_Review_And_Change_History_Model.md
    07110_Admin_Support_And_BreakGlass_Boundary.md
  09000_data_model_state_machine/
    09000_Data_Model_State_Machine_Readme.md
    09010_Data_Model_Draft.md
    09020_Handoff_State_Machine.md
    09030_Conceptual_Entity_Master.md
    09040_State_And_Event_Ownership_Model.md
    09050_Audit_Recovery_Event_Lineage_Model.md
    09060_Implementation_Deferred_Data_Model_Boundary.md
    09070_Context_Entity_Alignment_Model.md
    09080_Runtime_Profile_And_Change_Request_Entity_Model.md
    09090_Order_Candidate_And_Confirmation_State_Refinement.md
    09100_Admin_Support_Audit_Entity_Lineage_Model.md
    09110_Future_Profile_And_Analytics_State_Boundary.md
  11000_integration_boundary/
    11000_Integration_Boundary_Readme.md
    11010_POS_Payment_Printer_Integration_Boundary.md
  13000_app_api_projection/
    13000_App_Api_Projection_Readme.md
    13010_App_Surface_And_Channel_Projection.md
    13020_Customer_Webapp_Projection.md
    13030_Store_Console_Projection.md
    13040_Admin_Console_Projection.md
    13050_Api_Contract_Projection_Boundary.md
    13060_Surface_State_Visibility_And_Authority_Matrix.md
    13070_Customer_Surface_State_Wording_Matrix.md
    13080_Store_Admin_Support_Action_Authority_Matrix.md
  15000_membership_loyalty/
    15000_Membership_Loyalty_Readme.md
    15010_Membership_Loyalty_Product_Boundary.md
    15020_Lightweight_Coupon_And_Stamp_Future_Model.md
    15030_Point_Ledger_And_Wallet_Non_Implementation_Boundary.md
    15040_External_Membership_Bridge_Future_Boundary.md
    15050_Membership_Admin_And_UI_Reserved_Surface.md
  17000_ui_screen_composition/
    17000_Ui_Screen_Composition_Readme.md
    17010_Customer_Webapp_UI_Composition.md
    17020_Mini_Kiosk_UI_Composition.md
    17030_Store_Console_UI_Composition.md
    17040_Admin_Console_UI_Composition.md
    17050_Support_Console_UI_Composition.md
    17060_UI_State_Wording_And_Empty_State_Guideline.md
    17070_Wireframe_Prototype_Boundary.md
  20000_validation_security_audit/
    20000_Validation_Security_Audit_Readme.md
    20010_SaaS_Data_Capture_And_Governance_Principle.md
    20020_Cross_Entity_Data_Sharing_And_Privacy_Boundary.md
    20030_Data_Retention_And_Deletion_Policy.md
    20040_Admin_Access_And_Support_Access_Governance.md
    20050_Data_Export_And_Report_Approval_Governance.md
    20060_Anonymization_And_Pseudonymization_Standard.md
    20070_Audit_Evidence_And_Compliance_Record_Model.md
  22000_implementation_planning/
    22000_Implementation_Planning_Readme.md
    22010_Implementation_Readiness_Gate.md
    22020_Build_Sequence_And_Phase_Boundary.md
    22030_Schema_Design_Readiness_Checklist.md
    22040_Api_App_Implementation_Readiness_Checklist.md
    22050_QA_Smoke_Test_And_Rollback_Planning_Boundary.md
    22060_Mvp_Implementation_Non_Goals.md
  24000_deployment_operations/
    24000_Deployment_Operations_Readme.md
    24010_Deployment_Readiness_And_Release_Governance.md
    24020_Runtime_Operations_And_Support_Boundary.md
    24030_Incident_Response_And_Degraded_Operation_Boundary.md
    24040_Operational_Runbook_Boundary.md
    24050_Environment_And_Config_Non_Implementation_Boundary.md
  26000_analytics_reporting_bi/
    26000_Analytics_Reporting_Bi_Readme.md
    26010_Analytics_Product_Boundary.md
    26020_Operational_Metrics_Catalog.md
    26030_Report_And_Dashboard_Boundary.md
    26040_Cross_Tenant_Benchmark_And_Data_Sharing_Boundary.md
    26050_Analytics_To_Action_Governance.md
  28000_future_expansion/
    28000_Future_Expansion_Readme.md
    28020_Membership_Loyalty_Point_Future_Model.md
    28030_Point_Bridge_And_Exchange_Future_Boundary.md
    28040_Data_Ad_CRM_AI_Future_Expansion_Model.md
    28050_Franchise_OS_Data_Handoff_Future_Boundary.md
    28060_Franchise_Intelligence_Feedback_Loop_Model.md
  30000_future_saas_modules/
    30000_Future_Saas_Modules_Readme.md
```

`directory_tree.txt` and `tree_directory_view.txt` are temporary local snapshots when present. They are not governance documents.

## 4 Folder Purposes

| folder | purpose |
| --- | --- |
| docs/00100_project_foundation | Project identity, BM boundary, patent linkage, and non-implementation boundary. |
| docs/01000_mvp_scope | MVP definition, active/optional/future/non-goal matrix, package/feature flag boundary, store-type adoption sequence, and market-facing scope. |
| docs/03000_saas_runtime | SaaS context axes, store runtime profiles, package/feature flag governance, change/audit governance, and non-MVP future profile boundaries. |
| docs/05000_customer_handoff_flow | Customer waiting, preorder, arrival, seat/table, Mini Kiosk, and multilingual flow. |
| docs/07000_admin_console | Admin context navigation, runtime profile configuration, feature flag approval, audit review, support/break-glass boundary, and operational monitoring governance. |
| docs/09000_data_model_state_machine | Conceptual entities, state ownership, audit/recovery lineage, context alignment, runtime profile entities, order confirmation refinement, and future state boundaries. Not physical schema. |
| docs/11000_integration_boundary | POS, KDS, payment, printer, tablet order, and external system boundary. |
| docs/13000_app_api_projection | Future customer web, store console, admin console, and API contract projection. |
| docs/15000_membership_loyalty | Membership, loyalty, coupon, stamp, and point boundary governance. Active documentation domain; not active MVP runtime. |
| docs/17000_ui_screen_composition | UI screen composition for customer webapp, Mini Kiosk, store console, admin console, support console, shared wording, and wireframe boundary. Documentation only; not implementation. |
| docs/20000_validation_security_audit | Validation, audit, security, privacy, and operational safety principles. |
| docs/22000_implementation_planning | Implementation readiness gates, build sequence, schema/API checklists, QA/rollback planning, and MVP non-goals. Planning boundary only; not implementation approval. |
| docs/24000_deployment_operations | Deployment readiness, release governance, runtime support, incident/degraded operation, runbook, and environment/config boundaries. Planning boundary only; not deployment approval. |
| docs/26000_analytics_reporting_bi | Analytics product boundary, metrics catalog, report/dashboard boundary, cross-tenant benchmark rules, and insight-to-action governance. Documentation boundary only; not analytics runtime. |
| docs/28000_future_expansion | Long-term future/reference only. Not active MVP runtime. Not Franchise OS implementation. Related active domains: `15000`, `26000`, `20000`, `22000`, `24000`. |
| docs/30000_future_saas_modules | Long-term reserved future SaaS module documentation band. |

## 5 Reserved Band Notes

`15000~16999` is the active membership/loyalty boundary documentation band. Historical future references also remain in `docs/28000_future_expansion/` until a separate migration is approved.

`17000~19999` holds the initial UI screen composition detail wave. This band is documentation projection only, not UI implementation.

`22000~23999` holds the initial implementation planning boundary detail wave. This band is planning boundary only, not implementation approval.

`24000~25999` holds the initial deployment/operations/support planning boundary detail wave. This band is planning boundary only, not deployment approval.

`30000~99999` is a reserved landing band with readme landing document only.

`26000~27999` holds the initial analytics/reporting/BI boundary detail wave. This band is documentation boundary only, not analytics runtime.

`28000~29999` is long-term future/reference only. `docs/28000_future_expansion/` holds historical/future expansion reference documents. Not active MVP runtime. Not Franchise OS implementation. Related active domains: `15000`, `26000`, `20000`, `22000`, `24000`.

## 6 Current Status

Status: active root governance map.

## 7 External Boundary Note

`yoonsul_os` may reference `yoonsul_wait_order_handoff`.
`yoonsul_wait_order_handoff` implementation must remain outside `yoonsul_os`.

`yoonsul_os` is not indexed in this project's `00007_Full_Directory_Map.md`.
`yoonsul_franchise_os` is a future external solution context only and is not mapped as an internal path.
