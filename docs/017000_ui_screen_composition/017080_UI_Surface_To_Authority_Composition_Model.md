# 017080_UI_Surface_To_Authority_Composition_Model

## 1 Purpose

UI visibility must not imply action authority.

Buttons, badges, labels, and status cards must reflect real authority boundaries.

This document aligns with `13090` and does not create UI implementation.

This document is UI composition governance only.
It does not approve UI components, routes, or design assets.

## 2 UI Surface Families

| surface family | composition scope |
| --- | --- |
| customer webapp | Customer session, waiting, handoff, order candidate screens. |
| Mini Kiosk | Lightweight no-waiting order intent screens. |
| store console | Staff review, operational confirmation, integration operational UI. |
| admin console | Runtime configuration, approval, audit, support governance UI. |
| support console | Scoped support session visibility and assist controls. |
| future analytics dashboard | Aggregate/governed analytics UI per `26000`. |
| future membership/benefit surface | Placeholder UI per `15000`; not ledger runtime. |

## 3 UI Authority Composition Types

| composition type | UI meaning |
| --- | --- |
| visible only | Control or label displays state without mutation. |
| request action | User may submit request for review or approval. |
| staff review action | Store staff may review within operational scope. |
| admin review action | Admin may review within role/context scope. |
| approval-required action | Matching authority must approve before activation. |
| activation-required action | Approved change requires explicit activation step. |
| support-assist-only action | Support may assist within scoped session; not approval. |
| audit-read-only view | Audit/change history visible without mutation. |
| export-approval-required action | Export requires separate approval governance. |

## 4 Required Rules

- button visibility does not equal action authority.
- view authority does not equal mutation authority.
- support action does not equal approval.
- approval does not equal activation.
- audit visibility does not equal export authority.
- customer-facing state must match real confirmation authority.
- feature flag visibility does not equal implementation.
- future placeholder does not equal active runtime.

## 5 Cross-References

- `docs/13000_app_api_projection/013090_Surface_To_Authority_Projection_Model.md`
- `docs/17000_ui_screen_composition/017100_Governance_Action_Button_And_Status_Badge.md`
- `docs/07000_admin_console/007070_Admin_Context_Navigation_And_Scope_Model.md`

## 6 Open Decisions

- whether disabled buttons show reason.
- whether authority labels are shown to admins.
- whether customers see staff-confirmed state.
- whether future placeholders are hidden or visible.
- whether support console is separate or admin mode.

## 7 Current Status

Status: active UI surface-to-authority composition model. Not implementation approval.
