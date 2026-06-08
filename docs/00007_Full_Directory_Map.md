# 00007 Full Directory Map

## 1 Purpose

This document maps only paths inside `yoonsul_wait_order_handoff`.

Documentation paths use five-digit prefixes.

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
  02000_saas_runtime/
    02000_SaaS_Runtime_Readme.md
    02010_Tenant_Store_Runtime_And_Package_Model.md
  03000_customer_handoff_flow/
    03000_Customer_Handoff_Flow_Readme.md
    03010_User_Flow.md
  04000_admin_console/
    04000_Admin_Console_Readme.md
    04010_Admin_Console_Context_And_Role_Model.md
    04020_Admin_Store_Runtime_Configuration_Model.md
    04030_Admin_Operational_Monitoring_And_Recovery_Model.md
    04040_Admin_Screen_Inventory_And_Navigation_Model.md
    04050_Admin_Approval_Workflow_Model.md
    04060_Admin_Audit_And_Recovery_Queue_Governance.md
  05000_data_model_state_machine/
    05000_Data_Model_State_Machine_Readme.md
    05010_Data_Model_Draft.md
    05020_Handoff_State_Machine.md
    05030_Conceptual_Entity_Master.md
    05040_State_And_Event_Ownership_Model.md
    05050_Audit_Recovery_Event_Lineage_Model.md
    05060_Implementation_Deferred_Data_Model_Boundary.md
  06000_integration_boundary/
    06000_Integration_Boundary_Readme.md
    06010_POS_Payment_Printer_Integration_Boundary.md
  07000_app_api_projection/
    07000_App_Api_Projection_Readme.md
    07010_App_Surface_And_Channel_Projection.md
    07020_Customer_Webapp_Projection.md
    07030_Store_Console_Projection.md
    07040_Admin_Console_Projection.md
    07050_Api_Contract_Projection_Boundary.md
    07060_Surface_State_Visibility_And_Authority_Matrix.md
    07070_Customer_Surface_State_Wording_Matrix.md
    07080_Store_Admin_Support_Action_Authority_Matrix.md
  08000_validation_security_audit/
    08000_Validation_Security_Audit_Readme.md
    08010_SaaS_Data_Capture_And_Governance_Principle.md
    08020_Cross_Entity_Data_Sharing_And_Privacy_Boundary.md
    08030_Data_Retention_And_Deletion_Policy.md
    08040_Admin_Access_And_Support_Access_Governance.md
    08050_Data_Export_And_Report_Approval_Governance.md
    08060_Anonymization_And_Pseudonymization_Standard.md
    08070_Audit_Evidence_And_Compliance_Record_Model.md
  09000_future_expansion/
    09000_Future_Expansion_Readme.md
    09020_Membership_Loyalty_Point_Future_Model.md
    09030_Point_Bridge_And_Exchange_Future_Boundary.md
    09040_Data_Ad_CRM_AI_Future_Expansion_Model.md
    09050_Franchise_OS_Data_Handoff_Future_Boundary.md
    09060_Franchise_Intelligence_Feedback_Loop_Model.md
```

`directory_tree.txt` and `tree_directory_view.txt` are temporary local snapshots when present. They are not governance documents.

## 4 Folder Purposes

| folder | purpose |
| --- | --- |
| docs/00100_project_foundation | Project identity, BM boundary, patent linkage, and non-implementation boundary. |
| docs/01000_mvp_scope | MVP definition, service scenario, market-facing scope, and package strategy. |
| docs/02000_saas_runtime | Future SaaS tenant, account, billing, multi-store runtime, and store runtime boundary. |
| docs/03000_customer_handoff_flow | Customer waiting, preorder, arrival, seat/table, Mini Kiosk, and multilingual flow. |
| docs/04000_admin_console | Admin console scope for SaaS operator, store owner, store manager, and HQ/operator roles. |
| docs/05000_data_model_state_machine | Conceptual data model and state machine only. |
| docs/06000_integration_boundary | POS, KDS, payment, printer, tablet order, and external system boundary. |
| docs/07000_app_api_projection | Future customer web, store console, admin console, and API contract projection. |
| docs/08000_validation_security_audit | Validation, audit, security, privacy, and operational safety principles. |
| docs/09000_future_expansion | Future franchise_os, Agent, Logical AI, Physical AI, analytics, multi-brand, and SaaS expansion references. |

## 5 Reserved Band Note

`10000~10999` is reserved for future UI screen composition, but `docs/10000_ui_screen_composition/` does not exist yet.

## 6 Current Status

Status: active root governance map.

## 7 External Boundary Note

`yoonsul_os` may reference `yoonsul_wait_order_handoff`.
`yoonsul_wait_order_handoff` implementation must remain outside `yoonsul_os`.

`yoonsul_os` is not indexed in this project's `00007_Full_Directory_Map.md`.
`yoonsul_franchise_os` is a future external solution context only and is not mapped as an internal path.
