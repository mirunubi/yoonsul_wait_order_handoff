# 007000_Readme_Admin_Console.md

## 1 Purpose

This folder defines the `007000~007999` Admin Console package for SaaS operator, store owner, store manager, HQ/operator, support, and audit roles.

This folder consolidates Admin Console governance after the SaaS runtime consolidation.

## 2 Folder-Owned Number Range

This folder owns `007000~007999` until the next sibling folder, `008000_ai_customer_center/`, begins.

## 3 In Scope

- Admin console surfaces.
- Support console surfaces.
- HQ/store operator surfaces.
- Review dashboards.
- Evidence review.
- Recovery review.
- Compensation review.
- Provider evidence review.
- Role-based entry.
- Operator-safe visible message surfaces.
- Role and authority boundaries.
- Context navigation and scope model.
- Store runtime profile configuration governance.
- Feature flag approval and emergency disable.
- Audit review and change history.
- Support and break-glass boundary.
- Operational monitoring and recovery visibility.

## 4 Active File Roles

| File | Role |
| --- | --- |
| `007000_Readme_Admin_Console.md` | Defines the Admin Console folder purpose, range, scope, and active file map. |
| `007010_Policy_Admin_Console_Context_And_Role_Model.md` | Defines admin context axes, role types, authority principles, role boundary examples, and open role decisions. |
| `007020_Policy_Admin_Store_Runtime_Configuration_Model.md` | Defines Admin Console handling for store runtime configuration, package plans, feature flags, integration profiles, payment profiles, and change control. |
| `007030_Policy_Admin_Operational_Monitoring_And_Recovery_Model.md` | Defines operational monitoring and recovery visibility for order candidates, handoff sessions, Store Agent/printer/POS status, manual recovery, and audit. |
| `007040_Policy_Admin_Screen_Inventory_And_Navigation_Model.md` | Defines conceptual Admin Console screens, navigation groups, role-based navigation, and future membership/point placeholder limits. |
| `007050_Policy_Admin_Approval_Workflow_Model.md` | Defines request, validation, approval, activation, emergency disable, and rollback workflow for runtime changes. |
| `007060_Governance_Admin_Audit_And_Recovery_Queue.md` | Defines audit event categories, recovery queue item types, recovery lifecycle, recovery action rules, role visibility, and export/report governance. |
| `007070_Policy_Admin_Context_Navigation_And_Scope_Model.md` | Defines context navigation levels and scope rules aligned with SaaS runtime; view authority does not equal mutation authority. |
| `007080_Governance_Admin_Runtime_Profile_Configuration.md` | Defines Admin governance for runtime profile configuration aligned with runtime profile policies. |
| `007090_Policy_Admin_Feature_Flag_Approval_And_Emergency_Disable_Model.md` | Defines feature flag risk levels, approval rules, and emergency disable boundary. |
| `007100_Policy_Admin_Audit_Review_And_Change_History_Model.md` | Defines audit review areas, change history rules, and admin review actions. |
| `007110_Boundary_Admin_Support_And_BreakGlass.md` | Defines support modes, boundary rules, and future break-glass candidate boundary. |

## 5 Relationship Notes

- `007000` owns admin/operator/support-facing UI and control surfaces.
- SaaS runtime owns session/runtime authority.
- Customer handoff owns customer-facing handoff flow.
- `008000_ai_customer_center/` owns AI customer center documents.
- Admin Console must inherit Foundation Security, especially access control, audit/evidence, sensitive identity masking, credential non-reveal, export control, incident response, and retention rules.
- Support/admin screens must not mutate payment truth, KDS release truth, or reconciliation conclusion unless explicitly authorized by lower runtime authority policies.

## 6 Folder Structure Rule

The `007000_admin_console/` namespace currently stays flat with no subfolders.

Subfolders should be introduced only when the number of docs grows or separate admin domains become large.

## 7 Out Of Scope

- UI implementation, Flutter, web app code, RPC, auth/RLS, and final permission schema.
- Active membership/point ledger operations, analytics runtime, and support tooling implementation.

## 8 Current Status

Status: Admin Console consolidation wave complete. Governance only. Not implementation approval.
