# 0005 Document Number Index

## 1 Purpose

This document indexes only governance files and the `docs/` domain documentation spine inside `yoonsul_wait_order_handoff`.

Status values:

- `active`: current governance or design authority.
- `initial`: created as an initial domain landing document.
- `moved`: existing design content moved into the numbered docs namespace.

## 2 Docs Governance Files

These governance files live under `docs/`. They are not project-root files.

| file path | purpose | current status |
| --- | --- | --- |
| `docs/0000_Project_Overview.md` | Project overview and current phase authority. | active |
| `docs/0001_Md_Rules.md` | Markdown, encoding, move, and document quality rules. | active |
| `docs/0002_Naming_Rules.md` | File, folder, number band, and terminology rules. | active |
| `docs/0003_Project_Context.md` | Project context, assumptions, relationships, and non-goals. | active |
| `docs/0005_Document_Number_Index.md` | Number index for governance and docs domain files. | active |
| `docs/0007_Full_Directory_Map.md` | Directory map and folder purpose reference. | active |
| `docs/0099_Docs_Governance_Checklist.md` | Documentation governance checklist before commit and implementation. | active |

## 3 docs/0100_project_foundation

| file path | purpose | current status |
| --- | --- | --- |
| `docs/0100_project_foundation/0100_Project_Foundation_Readme.md` | Project foundation folder scope. | initial |
| `docs/0100_project_foundation/0110_Project_Identity_And_Overview.md` | Project identity and overview design content. | moved |
| `docs/0100_project_foundation/0120_BM_Patent_Linkage.md` | BM patent linkage design content. | moved |
| `docs/0100_project_foundation/0130_Non_Implementation_Boundary.md` | Explicit non-implementation boundary. | moved |

## 4 docs/1000_mvp_scope

| file path | purpose | current status |
| --- | --- | --- |
| `docs/1000_mvp_scope/1000_MVP_Scope_Readme.md` | MVP scope folder scope. | initial |
| `docs/1000_mvp_scope/1010_MVP_Scope.md` | MVP included, deferred, role, and status scope. | moved |
| `docs/1000_mvp_scope/1020_Store_Type_And_Product_Package_Strategy.md` | Store type classification, BM 3-A/3-B adoption strategy, payment separation, and product package strategy. | active |
| `docs/1000_mvp_scope/1030_Competitive_Positioning_And_Market_Context.md` | Market problem, competitive context, differentiation, messaging rules, and early MVP wedge. | active |

## 5 docs/2000_saas_runtime

| file path | purpose | current status |
| --- | --- | --- |
| `docs/2000_saas_runtime/2000_SaaS_Runtime_Readme.md` | Future SaaS tenant, account, billing, and store runtime boundary. | initial |
| `docs/2000_saas_runtime/2010_Tenant_Store_Runtime_And_Package_Model.md` | SaaS tenant/store runtime, package plan, feature flag, integration profile, and payment profile model. | active |

## 6 docs/3000_customer_handoff_flow

| file path | purpose | current status |
| --- | --- | --- |
| `docs/3000_customer_handoff_flow/3000_Customer_Handoff_Flow_Readme.md` | Customer handoff flow folder scope. | initial |
| `docs/3000_customer_handoff_flow/3010_User_Flow.md` | Customer, staff, Mini Kiosk, and handoff user flow. | moved |

## 7 docs/4000_admin_console

| file path | purpose | current status |
| --- | --- | --- |
| `docs/4000_admin_console/4000_Admin_Console_Readme.md` | Admin console role and scope boundary. | initial |
| `docs/4000_admin_console/4010_Admin_Console_Context_And_Role_Model.md` | Admin Console context axes, role model, authority principles, and role boundaries. | active |
| `docs/4000_admin_console/4020_Admin_Store_Runtime_Configuration_Model.md` | Admin Console package, feature flag, integration profile, payment profile, and change control model. | active |
| `docs/4000_admin_console/4030_Admin_Operational_Monitoring_And_Recovery_Model.md` | Admin Console operational monitoring, manual recovery, Store Agent/printer visibility, and audit model. | active |
| `docs/4000_admin_console/4040_Admin_Screen_Inventory_And_Navigation_Model.md` | Admin Console screen inventory, navigation groups, role-based access, and future placeholder boundaries. | active |
| `docs/4000_admin_console/4050_Admin_Approval_Workflow_Model.md` | Admin Console approval workflow, high-risk change rules, emergency disable, and rollback principles. | active |
| `docs/4000_admin_console/4060_Admin_Audit_And_Recovery_Queue_Governance.md` | Admin audit event categories, recovery queue lifecycle, recovery action rules, and export/report governance. | active |

## 8 docs/5000_data_model_state_machine

| file path | purpose | current status |
| --- | --- | --- |
| `docs/5000_data_model_state_machine/5000_Data_Model_State_Machine_Readme.md` | Conceptual data model and state machine folder scope. | initial |
| `docs/5000_data_model_state_machine/5010_Data_Model_Draft.md` | Conceptual entity and table draft. | moved |
| `docs/5000_data_model_state_machine/5020_Handoff_State_Machine.md` | Conceptual customer, waiting, handoff, Mini Kiosk, and store runtime visibility state machine. | active |

## 9 docs/6000_integration_boundary

| file path | purpose | current status |
| --- | --- | --- |
| `docs/6000_integration_boundary/6000_Integration_Boundary_Readme.md` | POS, KDS, payment, printer, tablet order, and external boundary. | initial |
| `docs/6000_integration_boundary/6010_POS_Payment_Printer_Integration_Boundary.md` | High-level POS API, payment, printer, Store Agent, and Full OS adoption boundary. | active |

## 10 docs/7000_app_api_projection

| file path | purpose | current status |
| --- | --- | --- |
| `docs/7000_app_api_projection/7000_App_Api_Projection_Readme.md` | Future app and API projection boundary. | initial |

## 11 docs/8000_validation_security_audit

| file path | purpose | current status |
| --- | --- | --- |
| `docs/8000_validation_security_audit/8000_Validation_Security_Audit_Readme.md` | Validation, audit, security, privacy, and operational safety principles. | initial |

## 12 docs/9000_future_expansion

| file path | purpose | current status |
| --- | --- | --- |
| `docs/9000_future_expansion/9000_Future_Expansion_Readme.md` | Future franchise_os, Agent, Logical AI, Physical AI, analytics, and expansion references. | initial |
| `docs/9000_future_expansion/9020_Membership_Loyalty_Point_Future_Model.md` | Future-reserved membership, loyalty, coupon, stamp, and point model boundary. | future-reserved |
| `docs/9000_future_expansion/9030_Point_Bridge_And_Exchange_Future_Boundary.md` | Future-reserved point bridge and exchange boundary. | future-reserved |
| `docs/9000_future_expansion/9040_Data_Ad_CRM_AI_Future_Expansion_Model.md` | Future-reserved data, advertising, CRM, analytics, and AI expansion boundary. | future-reserved |

## 13 External Boundary Reference

`yoonsul_os` is an external project separation reference only.
It is not part of the `yoonsul_wait_order_handoff` document index.

`yoonsul_franchise_os` is a long-term future expansion reference only.
It is not part of this document index.
