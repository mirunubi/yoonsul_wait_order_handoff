# 003030_Guide_Store_Runtime_Profile_Model.md

## 1 Purpose

store_runtime is the active operating mode for a store.

It determines which surfaces, package modes, integration visibility, payment posture, support posture, and recovery posture are allowed.

store_runtime does not create implementation by itself.

This document is runtime profile consolidation only.
It does not define database schema, API endpoints, or production runtime code.

## 2 Store Runtime Components

| component | purpose |
| --- | --- |
| store_runtime | Active operating mode container for a store. |
| store_runtime_status | Lifecycle state of runtime activation and health. |
| store_package_plan | Assigned package plan boundary per `01050`/`03040`. |
| store_feature_flags | Feature flag set governing visible/runtime-eligible capabilities. |
| store_integration_profile | Integration level visibility (none, staff screen, Store Agent, printer, POS API, Full OS future). |
| store_payment_profile | Payment posture; platform payment not default MVP. |
| store_language_profile | Language and menu display configuration. |
| store_menu_profile | Menu snapshot and content configuration boundary. |
| store_agent_profile | Store Agent visibility and validation posture. |
| store_support_profile | Support access and escalation posture per `20040`/`24020`. |
| store_analytics_profile | Analytics/reporting visibility posture per `26000`; not BI runtime. |
| store_membership_profile | Membership/loyalty placeholder posture per `15000`; not ledger runtime. |

## 3 Status Concepts

| status | meaning |
| --- | --- |
| draft | Profile drafted; not active. |
| pending approval | Change requested; awaiting approval workflow. |
| active | Approved profile in operational use. |
| degraded | Partial outage or integration degradation; safe fallback required. |
| suspended | Runtime suspended by policy or incident response. |
| emergency disabled | High-risk capability disabled under emergency rule. |
| archived | Store runtime retired from active operation. |

## 4 Runtime Profile Rules

- package plan does not equal feature implementation.
- feature flag does not equal implementation.
- integration profile does not equal integration success.
- payment profile does not equal platform payment enabled.
- membership profile does not equal point ledger/wallet active.
- analytics profile does not equal BI runtime active.
- support profile does not equal support approval.

Additional rules align with `docs/01000_mvp_scope/001050_Boundary_MVP_Package_And_Feature_Flag.md` and `docs/11000_integration_boundary/011010_Boundary_POS_Payment_Printer_Integration.md`.

## 5 Cross-References

- `docs/03000_saas_runtime/003010_Tenant_Store_Runtime_And_Package_Model.md`
- `docs/03000_saas_runtime/003040_Governance_Package_Plan_And_Feature_Flag_Runtime.md`
- `docs/03000_saas_runtime/003060_Boundary_Runtime_Profile_Non_MVP_And_Future_Flag.md`
- `docs/07000_admin_console/007020_Admin_Store_Runtime_Configuration_Model.md`

## 6 Open Decisions

- whether store_runtime is versioned.
- whether profile changes require approval.
- whether emergency disable is runtime status or feature flag.
- whether profile history is append-only.
- who can activate runtime profile.

## 7 Current Status

Status: active store runtime profile model. Not implementation approval.
