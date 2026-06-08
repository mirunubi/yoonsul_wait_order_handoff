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
| `docs/7000_app_api_projection/7010_App_Surface_And_Channel_Projection.md` | Conceptual app surfaces, channel entry points, ownership boundaries, and non-implementation limits. | active |
| `docs/7000_app_api_projection/7020_Customer_Webapp_Projection.md` | Customer-facing webapp modes, screens, wording rules, and privacy projection. | active |
| `docs/7000_app_api_projection/7030_Store_Console_Projection.md` | Store console screens, staff actions, role access, and POS/payment claim boundaries. | active |
| `docs/7000_app_api_projection/7040_Admin_Console_Projection.md` | Admin Console screen group, action, and authority projection based on 4000 governance. | active |
| `docs/7000_app_api_projection/7050_Api_Contract_Projection_Boundary.md` | Conceptual API contract groups, authority principles, audit boundaries, and forbidden implementation. | active |
| `docs/7000_app_api_projection/7060_Surface_State_Visibility_And_Authority_Matrix.md` | Surface state visibility, requestable action, mutation authority, approval, audit, and forbidden action matrix. | active |
| `docs/7000_app_api_projection/7070_Customer_Surface_State_Wording_Matrix.md` | Customer-facing wording by state, integration level, recovery/delay condition, and multilingual/Mini Kiosk boundary. | active |
| `docs/7000_app_api_projection/7080_Store_Admin_Support_Action_Authority_Matrix.md` | Store, admin, support, legal, platform, and auditor action authority matrix. | active |

## 11 docs/8000_validation_security_audit

| file path | purpose | current status |
| --- | --- | --- |
| `docs/8000_validation_security_audit/8000_Validation_Security_Audit_Readme.md` | Validation, audit, security, privacy, and operational safety principles. | initial |
| `docs/8000_validation_security_audit/8010_SaaS_Data_Capture_And_Governance_Principle.md` | SaaS runtime data capture categories, distinction rules, governance requirements, and non-MVP secondary use boundaries. | active |
| `docs/8000_validation_security_audit/8020_Cross_Entity_Data_Sharing_And_Privacy_Boundary.md` | Cross-entity data movement, privacy, export, support access, and future Franchise OS sharing boundary. | active |
| `docs/8000_validation_security_audit/8030_Data_Retention_And_Deletion_Policy.md` | Conceptual data retention, deletion, archival, and tenant offboarding governance. | active |
| `docs/8000_validation_security_audit/8040_Admin_Access_And_Support_Access_Governance.md` | Admin access, scoped support session, sensitive data visibility, and access boundary governance. | active |
| `docs/8000_validation_security_audit/8050_Data_Export_And_Report_Approval_Governance.md` | Data export/report approval, risk level, lifecycle, and audit governance. | active |
| `docs/8000_validation_security_audit/8060_Anonymization_And_Pseudonymization_Standard.md` | Conceptual anonymization, pseudonymization, aggregation, and re-identification risk standard. | active |
| `docs/8000_validation_security_audit/8070_Audit_Evidence_And_Compliance_Record_Model.md` | Audit evidence and compliance record model for access, export, retention, recovery, and future handoff review. | active |

## 12 docs/9000_future_expansion

| file path | purpose | current status |
| --- | --- | --- |
| `docs/9000_future_expansion/9000_Future_Expansion_Readme.md` | Future franchise_os, Agent, Logical AI, Physical AI, analytics, and expansion references. | initial |
| `docs/9000_future_expansion/9020_Membership_Loyalty_Point_Future_Model.md` | Future-reserved membership, loyalty, coupon, stamp, and point model boundary. | future-reserved |
| `docs/9000_future_expansion/9030_Point_Bridge_And_Exchange_Future_Boundary.md` | Future-reserved point bridge and exchange boundary. | future-reserved |
| `docs/9000_future_expansion/9040_Data_Ad_CRM_AI_Future_Expansion_Model.md` | Future-reserved data, advertising, CRM, analytics, and AI expansion boundary. | future-reserved |
| `docs/9000_future_expansion/9050_Franchise_OS_Data_Handoff_Future_Boundary.md` | Future-reserved Franchise OS data handoff boundary and authority limits. | future-reserved |
| `docs/9000_future_expansion/9060_Franchise_Intelligence_Feedback_Loop_Model.md` | Future-reserved franchise intelligence feedback loop and recommendation authority boundary. | future-reserved |

## 13 External Boundary Reference

`yoonsul_os` is an external project separation reference only.
It is not part of the `yoonsul_wait_order_handoff` document index.

`yoonsul_franchise_os` is a long-term future expansion reference only.
It is not part of this document index.
