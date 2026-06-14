# 07000 Admin Console Readme

## 1 Purpose

This folder defines admin console scope for SaaS operator, store owner, store manager, and HQ/operator roles.

This wave consolidates Admin Console governance after the `03000` SaaS runtime consolidation.

## 2 In Scope

- Role and authority boundaries.
- Context navigation and scope model.
- Store runtime profile configuration governance.
- Feature flag approval and emergency disable.
- Audit review and change history.
- Support and break-glass boundary.
- Operational monitoring and recovery visibility.

## 3 Document List

| document | description |
| --- | --- |
| `07010_Admin_Console_Context_And_Role_Model.md` | Defines admin context axes, role types, authority principles, role boundary examples, and open role decisions. |
| `07020_Admin_Store_Runtime_Configuration_Model.md` | Defines Admin Console handling for store runtime configuration, package plans, feature flags, integration profiles, payment profiles, and change control. |
| `07030_Admin_Operational_Monitoring_And_Recovery_Model.md` | Defines operational monitoring and recovery visibility for order candidates, handoff sessions, Store Agent/printer/POS status, manual recovery, and audit. |
| `07040_Admin_Screen_Inventory_And_Navigation_Model.md` | Defines conceptual Admin Console screens, navigation groups, role-based navigation, and future membership/point placeholder limits. |
| `07050_Admin_Approval_Workflow_Model.md` | Defines request, validation, approval, activation, emergency disable, and rollback workflow for runtime changes. |
| `07060_Admin_Audit_And_Recovery_Queue_Governance.md` | Defines audit event categories, recovery queue item types, recovery lifecycle, recovery action rules, role visibility, and export/report governance. |
| `07070_Admin_Context_Navigation_And_Scope_Model.md` | Context navigation levels and scope rules aligned with `03020`; view authority does not equal mutation authority. |
| `07080_Admin_Runtime_Profile_Configuration_Governance.md` | Admin governance for runtime profile configuration aligned with `03030`~`03050`. |
| `07090_Admin_Feature_Flag_Approval_And_Emergency_Disable_Model.md` | Feature flag risk levels, approval rules, and emergency disable boundary. |
| `07100_Admin_Audit_Review_And_Change_History_Model.md` | Audit review areas, change history rules, and admin review actions. |
| `07110_Admin_Support_And_BreakGlass_Boundary.md` | Support modes, boundary rules, and future break-glass candidate boundary. |

`07010`~`07060` are existing admin governance foundations.

`07070`~`07110` consolidate runtime context navigation, runtime profile configuration, feature flag approval, audit review, and support/break-glass boundaries.

## 4 Folder Structure Rule

The `07000_admin_console` namespace currently stays flat with no subfolders.

Subfolders should be introduced only when the number of docs grows or separate admin domains become large.

## 5 Out Of Scope

- UI implementation, Flutter, web app code, RPC, auth/RLS, and final permission schema.
- Active membership/point ledger operations, analytics runtime, and support tooling implementation.

## 6 Current Status

Status: Admin Console consolidation wave complete. Governance only. Not implementation approval.
