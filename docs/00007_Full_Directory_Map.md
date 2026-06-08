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
  03000_saas_runtime/
    03000_SaaS_Runtime_Readme.md
    03010_Tenant_Store_Runtime_And_Package_Model.md
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
  09000_data_model_state_machine/
    09000_Data_Model_State_Machine_Readme.md
    09010_Data_Model_Draft.md
    09020_Handoff_State_Machine.md
    09030_Conceptual_Entity_Master.md
    09040_State_And_Event_Ownership_Model.md
    09050_Audit_Recovery_Event_Lineage_Model.md
    09060_Implementation_Deferred_Data_Model_Boundary.md
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
  24000_deployment_operations/
    24000_Deployment_Operations_Readme.md
  26000_analytics_reporting_bi/
    26000_Analytics_Reporting_Bi_Readme.md
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
| docs/01000_mvp_scope | MVP definition, service scenario, market-facing scope, and package strategy. |
| docs/03000_saas_runtime | Future SaaS tenant, account, billing, multi-store runtime, and store runtime boundary. |
| docs/05000_customer_handoff_flow | Customer waiting, preorder, arrival, seat/table, Mini Kiosk, and multilingual flow. |
| docs/07000_admin_console | Admin console scope for SaaS operator, store owner, store manager, and HQ/operator roles. |
| docs/09000_data_model_state_machine | Conceptual data model and state machine only. |
| docs/11000_integration_boundary | POS, KDS, payment, printer, tablet order, and external system boundary. |
| docs/13000_app_api_projection | Future customer web, store console, admin console, and API contract projection. |
| docs/15000_membership_loyalty | Reserved membership, loyalty, coupon, stamp, and point documentation band. |
| docs/17000_ui_screen_composition | UI screen composition for customer webapp, Mini Kiosk, store console, admin console, support console, shared wording, and wireframe boundary. Documentation only; not implementation. |
| docs/20000_validation_security_audit | Validation, audit, security, privacy, and operational safety principles. |
| docs/22000_implementation_planning | Reserved implementation planning, build sequence, and QA planning band. |
| docs/24000_deployment_operations | Reserved deployment, operations, and support planning band. |
| docs/26000_analytics_reporting_bi | Reserved analytics, reporting, and BI documentation band. |
| docs/28000_future_expansion | Future franchise_os, Agent, Logical AI, Physical AI, analytics, multi-brand, and SaaS expansion references. |
| docs/30000_future_saas_modules | Long-term reserved future SaaS module documentation band. |

## 5 Reserved Band Notes

`15000~16999` is a reserved landing band. Membership and point future references currently remain in `docs/28000_future_expansion/`.

`17000~19999` holds the initial UI screen composition detail wave. This band is documentation projection only, not UI implementation.

`22000~23999`, `24000~25999`, `26000~27999`, and `30000~99999` are reserved landing bands with readme landing documents only.

`28000~29999` is the active future expansion band. `docs/28000_future_expansion/` holds the current future expansion reference documents.

## 6 Current Status

Status: active root governance map.

## 7 External Boundary Note

`yoonsul_os` may reference `yoonsul_wait_order_handoff`.
`yoonsul_wait_order_handoff` implementation must remain outside `yoonsul_os`.

`yoonsul_os` is not indexed in this project's `00007_Full_Directory_Map.md`.
`yoonsul_franchise_os` is a future external solution context only and is not mapped as an internal path.
