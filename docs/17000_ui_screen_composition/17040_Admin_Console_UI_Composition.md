# 17040 Admin Console Ui Composition

## 1 Purpose

Admin Console UI composition follows `docs/07000_admin_console/` governance and `docs/13000_app_api_projection/13040_Admin_Console_Projection.md`.

It configures and monitors SaaS runtime but is not POS, payment settlement, or membership ledger.

This document is UI screen composition projection only.
It does not define UI components, routing, API endpoints, auth implementation, or production admin behavior.

## 2 Screen Groups

### 2.1 Admin Dashboard

| field | composition |
| --- | --- |
| primary information | Scoped operational summary, open recovery count, integration health, pending approvals. |
| primary roles | platform_admin, tenant_admin, operating_group_manager, store_owner, store_manager, support_operator. |
| view vs mutation | View scoped dashboard; no direct high-risk mutation from dashboard tiles. |
| forbidden UI | Do not show hidden payment/POS truth beyond configured profiles. |

### 2.2 Tenant / Company / Legal Entity / Operating Group / Store Views

| field | composition |
| --- | --- |
| primary information | Hierarchy list and detail for tenant, company, legal entity, operating group, and store context. |
| primary roles | platform_admin, tenant_admin, company_admin, legal_admin, operating_group_manager, store_owner. |
| view vs mutation | View scoped by role; mutation through workflow only. |
| forbidden UI | Do not mutate store runtime or legal authority without approval workflow. |

### 2.3 Store Runtime Configuration

| field | composition |
| --- | --- |
| primary information | Package, feature flags, integration profile, payment profile, language, recovery settings. |
| primary roles | platform_admin, tenant_admin, store_owner. |
| view vs mutation | View configuration; change through approval workflow. |
| forbidden UI | Do not bypass validation or silently enable high-risk flags. |

### 2.4 Package Plan / Feature Flag Change Request

| field | composition |
| --- | --- |
| primary information | Current plan, requested change, approval state, risk classification. |
| primary roles | tenant_admin, store_owner, platform_admin request; approval roles per policy. |
| view vs mutation | Request visible to authorized roles; activation requires approval. |
| forbidden UI | Package change does not automatically enable POS API, printer, or payment. |

### 2.5 Integration Profile Detail

| field | composition |
| --- | --- |
| primary information | Integration level, validation status, Store Agent, printer, POS API state. |
| primary roles | platform_admin, tenant_admin, store_owner, support_operator scoped. |
| view vs mutation | View status; activation through workflow. |
| forbidden UI | Do not claim POS API exists before validation. |

### 2.6 Payment Profile Detail

| field | composition |
| --- | --- |
| primary information | Payment profile, approval state, legal/tax review context. |
| primary roles | platform_admin, legal_admin, tenant_admin. |
| view vs mutation | View profile; enable through legal/tax and platform approval. |
| forbidden UI | platform payment remains future/advanced unless separately approved. |

### 2.7 Order Candidate / Preorder Review

| field | composition |
| --- | --- |
| primary information | Store-scoped candidate and preorder queues for admin visibility. |
| primary roles | store_manager, store_staff, store_owner, support_operator scoped. |
| view vs mutation | Staff confirmation where allowed; admin visibility does not bypass store authority. |
| forbidden UI | Do not claim POS completion unless POS confirms. |

### 2.8 Waiting / Mini Kiosk Monitoring

| field | composition |
| --- | --- |
| primary information | Waiting sessions, Mini Kiosk sessions, operational counts. |
| primary roles | store_manager, store_staff, store_owner, operating_group_manager. |
| view vs mutation | Monitor and limited staff actions; no silent cancellation without audit. |
| forbidden UI | Do not treat browsing as confirmed order. |

### 2.9 Store Agent / Printer Monitoring

| field | composition |
| --- | --- |
| primary information | Agent health, printer output state, retry eligibility. |
| primary roles | platform_admin, tenant_admin, store_owner, store_manager, support_operator scoped. |
| view vs mutation | Status view; retry or disable through workflow/policy. |
| forbidden UI | Printer output does not equal POS sales creation. |

### 2.10 Manual Recovery Queue

| field | composition |
| --- | --- |
| primary information | Open recovery items, assignment, severity, linked sessions. |
| primary roles | platform_admin, tenant_admin, store_owner, store_manager, support_operator scoped. |
| view vs mutation | Assigned recovery action only; dismiss is not resolve. |
| forbidden UI | Dismiss does not mean resolved. |

### 2.11 Audit / Change History

| field | composition |
| --- | --- |
| primary information | Audit events, configuration changes, approval history. |
| primary roles | platform_admin, tenant_admin, read_only_auditor, support_operator scoped. |
| view vs mutation | Read-only by default; no delete or overwrite. |
| forbidden UI | Audit visibility does not equal export authority. |

### 2.12 Support Tools

| field | composition |
| --- | --- |
| primary information | Scoped support session entry, allowed context, session reason. |
| primary roles | support_operator, platform_admin. |
| view vs mutation | Support actions only within scoped session. |
| forbidden UI | support action does not equal approval. |

### 2.13 Reports / Export

| field | composition |
| --- | --- |
| primary information | Export requests, approval state, scoped report visibility. |
| primary roles | platform_admin, tenant_admin, read_only_auditor request where allowed. |
| view vs mutation | Export requires approval and audit. |
| forbidden UI | Report visibility does not imply downloadable export authority. |

### 2.14 Future Reserved Membership / Point Placeholder

| field | composition |
| --- | --- |
| primary information | Reserved navigation label only; no active ledger UI. |
| primary roles | platform_admin, tenant_admin placeholder visibility. |
| view vs mutation | No mutation in MVP. |
| forbidden UI | membership/point remains future-reserved; no balance, wallet, or redemption screens. |

## 3 Authority UI Rules

- view authority does not equal mutation authority.
- admin visibility does not equal export authority.
- high-risk changes need approval workflow.
- platform payment remains future/advanced.
- membership/point remains future-reserved.
- support action does not equal approval.

High-risk changes include package plan, feature flags, payment profile, POS API activation, printer activation, Store Agent activation, support access, and export.

## 4 Admin Console Governance Cross-Reference

Admin UI composition must follow `docs/07000_admin_console/07070_Admin_Context_Navigation_And_Scope_Model.md` through `docs/07000_admin_console/07110_Admin_Support_And_BreakGlass_Boundary.md`.

UI button visibility must not imply action authority.

Emergency disable and rollback UI must preserve audit/review boundaries.

## 5 Cross-References

- `docs/07000_admin_console/07070_Admin_Context_Navigation_And_Scope_Model.md`
- `docs/07000_admin_console/07080_Admin_Runtime_Profile_Configuration_Governance.md`
- `docs/07000_admin_console/07090_Admin_Feature_Flag_Approval_And_Emergency_Disable_Model.md`
- `docs/07000_admin_console/07100_Admin_Audit_Review_And_Change_History_Model.md`
- `docs/07000_admin_console/07110_Admin_Support_And_BreakGlass_Boundary.md`
- `docs/07000_admin_console/07040_Admin_Screen_Inventory_And_Navigation_Model.md`
- `docs/13000_app_api_projection/13040_Admin_Console_Projection.md`
- `docs/13000_app_api_projection/13080_Store_Admin_Support_Action_Authority_Matrix.md`
- `docs/20000_validation_security_audit/20040_Admin_Access_And_Support_Access_Governance.md`
- `docs/17000_ui_screen_composition/17050_Support_Console_UI_Composition.md`

## 6 Open Decisions

- approval inbox design.
- export/report UI depth.
- support access modal.
- audit event detail view.
- platform vs tenant admin separation.

## 7 Current Status

Status: active admin console UI composition projection. No implementation approval.
