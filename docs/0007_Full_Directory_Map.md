# 0007 Full Directory Map

## 1 Purpose

This document maps only paths inside `yoonsul_wait_order_handoff`.

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
  0000_Project_Overview.md
  0001_Md_Rules.md
  0002_Naming_Rules.md
  0003_Project_Context.md
  0005_Document_Number_Index.md
  0007_Full_Directory_Map.md
  0099_Docs_Governance_Checklist.md
  directory_tree.txt
  tree_directory_view.txt
  0100_project_foundation/
    0100_Project_Foundation_Readme.md
    0110_Project_Identity_And_Overview.md
    0120_BM_Patent_Linkage.md
    0130_Non_Implementation_Boundary.md
  1000_mvp_scope/
    1000_MVP_Scope_Readme.md
    1010_MVP_Scope.md
    1020_Store_Type_And_Product_Package_Strategy.md
    1030_Competitive_Positioning_And_Market_Context.md
  2000_saas_runtime/
    2000_SaaS_Runtime_Readme.md
    2010_Tenant_Store_Runtime_And_Package_Model.md
  3000_customer_handoff_flow/
    3000_Customer_Handoff_Flow_Readme.md
    3010_User_Flow.md
  4000_admin_console/
    4000_Admin_Console_Readme.md
    4010_Admin_Console_Context_And_Role_Model.md
    4020_Admin_Store_Runtime_Configuration_Model.md
    4030_Admin_Operational_Monitoring_And_Recovery_Model.md
    4040_Admin_Screen_Inventory_And_Navigation_Model.md
    4050_Admin_Approval_Workflow_Model.md
    4060_Admin_Audit_And_Recovery_Queue_Governance.md
  5000_data_model_state_machine/
    5000_Data_Model_State_Machine_Readme.md
    5010_Data_Model_Draft.md
    5020_Handoff_State_Machine.md
  6000_integration_boundary/
    6000_Integration_Boundary_Readme.md
    6010_POS_Payment_Printer_Integration_Boundary.md
  7000_app_api_projection/
    7000_App_Api_Projection_Readme.md
    7010_App_Surface_And_Channel_Projection.md
    7020_Customer_Webapp_Projection.md
    7030_Store_Console_Projection.md
    7040_Admin_Console_Projection.md
    7050_Api_Contract_Projection_Boundary.md
  8000_validation_security_audit/
    8000_Validation_Security_Audit_Readme.md
    8010_SaaS_Data_Capture_And_Governance_Principle.md
    8020_Cross_Entity_Data_Sharing_And_Privacy_Boundary.md
    8030_Data_Retention_And_Deletion_Policy.md
    8040_Admin_Access_And_Support_Access_Governance.md
    8050_Data_Export_And_Report_Approval_Governance.md
    8060_Anonymization_And_Pseudonymization_Standard.md
    8070_Audit_Evidence_And_Compliance_Record_Model.md
  9000_future_expansion/
    9000_Future_Expansion_Readme.md
    9020_Membership_Loyalty_Point_Future_Model.md
    9030_Point_Bridge_And_Exchange_Future_Boundary.md
    9040_Data_Ad_CRM_AI_Future_Expansion_Model.md
    9050_Franchise_OS_Data_Handoff_Future_Boundary.md
    9060_Franchise_Intelligence_Feedback_Loop_Model.md
```

`directory_tree.txt` and `tree_directory_view.txt` are temporary local snapshots. They are not governance documents.

## 4 Folder Purposes

| folder | purpose |
| --- | --- |
| `docs/0100_project_foundation` | Project identity, BM boundary, patent linkage, and non-implementation boundary. |
| `docs/1000_mvp_scope` | MVP definition, service scenario, and initial market-facing scope. |
| `docs/2000_saas_runtime` | Future SaaS tenant, account, billing, multi-store runtime, and store runtime boundary. |
| `docs/3000_customer_handoff_flow` | Customer waiting, preorder, arrival, seat/table, Mini Kiosk, and multilingual flow. |
| `docs/4000_admin_console` | Admin console scope for SaaS operator, store owner, store manager, and HQ/operator roles. |
| `docs/5000_data_model_state_machine` | Conceptual data model and state machine only. |
| `docs/6000_integration_boundary` | POS, KDS, payment, printer, tablet order, and external system boundary. |
| `docs/7000_app_api_projection` | Future customer web, store console, admin console, and API contract projection. |
| `docs/8000_validation_security_audit` | Validation, audit, security, privacy, and operational safety principles. |
| `docs/9000_future_expansion` | Future franchise_os, Agent, Logical AI, Physical AI, analytics, multi-brand, and SaaS expansion references. |

## 5 Current Status

Status: active root governance map.

## 6 External Boundary Note

`yoonsul_os` may reference `yoonsul_wait_order_handoff`.
`yoonsul_wait_order_handoff` implementation must remain outside `yoonsul_os`.

`yoonsul_os` is not indexed in this project's `0007_Full_Directory_Map.md`.
