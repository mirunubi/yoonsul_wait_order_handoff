# 07000 Admin Console Readme

## 1 Purpose

This folder defines admin console scope for SaaS operator, store owner, store manager, and HQ/operator roles.

## 2 In Scope

- Role and authority boundaries.
- Future console planning.
- Store owner and manager operational surfaces.

## 3 Document List

| document | description |
| --- | --- |
| `07010_Admin_Console_Context_And_Role_Model.md` | Defines admin context axes, role types, authority principles, role boundary examples, and open role decisions. |
| `07020_Admin_Store_Runtime_Configuration_Model.md` | Defines Admin Console handling for store runtime configuration, package plans, feature flags, integration profiles, payment profiles, and change control. |
| `07030_Admin_Operational_Monitoring_And_Recovery_Model.md` | Defines operational monitoring and recovery visibility for order candidates, handoff sessions, Store Agent/printer/POS status, manual recovery, and audit. |
| `07040_Admin_Screen_Inventory_And_Navigation_Model.md` | Defines conceptual Admin Console screens, navigation groups, role-based navigation, and future membership/point placeholder limits. |
| `07050_Admin_Approval_Workflow_Model.md` | Defines request, validation, approval, activation, emergency disable, and rollback workflow for runtime changes. |
| `07060_Admin_Audit_And_Recovery_Queue_Governance.md` | Defines audit event categories, recovery queue item types, recovery lifecycle, recovery action rules, role visibility, and export/report governance. |

## 4 Folder Structure Rule

The `4000_admin_console` namespace currently stays flat with no subfolders.

Subfolders should be introduced only when the number of docs grows or separate admin domains become large.

## 5 Out Of Scope

- UI implementation, Flutter, web app code, RPC, and final permission schema.
- Active membership/point ledger operations.

## 6 Current Status

Status: initial admin console namespace. No UI implementation.

