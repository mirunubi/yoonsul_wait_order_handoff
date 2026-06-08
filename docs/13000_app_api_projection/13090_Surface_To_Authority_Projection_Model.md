# 13090 Surface To Authority Projection Model

## 1 Purpose

Surface visibility must not imply mutation authority.

App/API projection must preserve authority boundaries from `07000`, `09000`, `11000`, and `20000`.

This document defines projection only and does not create routes, endpoints, or UI code.

This document is projection governance only.
It does not approve app implementation, auth middleware, or permission schema.

## 2 Surface Families

| surface family | projection scope |
| --- | --- |
| customer webapp | Customer session, waiting, handoff, order candidate visibility. |
| Mini Kiosk | Lightweight no-waiting order intent surface. |
| store console | Staff review, operational confirmation, integration operational states. |
| admin console | Runtime configuration, approval, audit, support governance. |
| support console | Scoped support session visibility and assist actions. |
| future analytics dashboard | Aggregate/governed analytics visibility per `26000`. |
| future membership/benefit surface | Placeholder visibility per `15000`; not ledger runtime. |

## 3 Authority Projection Types

| authority type | meaning |
| --- | --- |
| visible only | Surface may display state without mutation. |
| requestable | Surface may submit request for review or approval. |
| staff-reviewable | Store staff may review within operational scope. |
| admin-reviewable | Admin may review within role/context scope. |
| approval-required | Matching authority must approve before activation. |
| activation-required | Approved change requires explicit activation step. |
| support-assist-only | Support may assist within scoped session; not approval. |
| audit-read-only | Audit/change history visible without mutation. |
| export-approval-required | Export requires separate approval governance. |

## 4 Required Rules

- view authority does not equal mutation authority.
- support action does not equal approval.
- approval does not equal activation.
- audit visibility does not equal export authority.
- feature flag visibility does not equal implementation.
- customer-facing state must match real confirmation authority.
- integration attempt must not be projected as integration success.

## 5 UI Composition Cross-Reference

- UI surface-to-authority composition is refined in `docs/17000_ui_screen_composition/17080_UI_Surface_To_Authority_Composition_Model.md`.
- UI button/status governance is defined in `docs/17000_ui_screen_composition/17100_Action_Button_And_Status_Badge_Governance.md`.
- Surface projection does not create UI implementation.

## 6 Cross-References

- `docs/13000_app_api_projection/13060_Surface_State_Visibility_And_Authority_Matrix.md`
- `docs/13000_app_api_projection/13080_Store_Admin_Support_Action_Authority_Matrix.md`
- `docs/07000_admin_console/07070_Admin_Context_Navigation_And_Scope_Model.md`
- `docs/20000_validation_security_audit/20040_Admin_Access_And_Support_Access_Governance.md`

## 7 Open Decisions

- whether authority is surfaced in UI labels.
- whether customer sees staff-confirmed state.
- whether support console is separate app or admin mode.
- whether export request is visible to tenant admin.
- whether future analytics dashboard has separate roles.

## 8 Current Status

Status: active surface-to-authority projection model. Not implementation approval.
