# 017120_Admin_Support_UI_Authority_And_Recovery_Model

## 1 Purpose

Admin/support UI must expose authority, recovery, audit, and support scope without enabling silent mutation.

This document consolidates `07070`~`07110`, `13090`, `13110`, `17100`, and `24020`.

It does not create admin/support UI implementation.

This document is UI composition governance only.
It does not approve admin console code or support tooling.

## 2 Admin/Support UI Areas

| UI area | composition focus |
| --- | --- |
| context selector | Tenant/company/store context navigation without authority collapse. |
| runtime profile detail | View and request profile changes within role scope. |
| package/feature flag change request | Draft and submit change requests. |
| approval inbox | Review pending approvals; approval does not activate. |
| activation/rollback screen | Activate approved changes or rollback with audit. |
| emergency disable screen | Disable risky capability with reason and audit. |
| support session panel | Scoped session visibility, reason, and action log. |
| recovery queue | Recovery items linked to original events. |
| audit history | Append-only change and event history. |
| export request screen | Export request and approval tracking. |

## 3 Authority Rules

- context switch does not equal approval.
- view authority does not equal mutation authority.
- approval does not equal activation.
- emergency disable does not erase audit.
- rollback does not erase audit.
- support action does not equal approval.
- support access must be scoped and time-bounded.
- audit visibility does not equal export authority.

## 4 Recovery UI Rules

- recovery does not overwrite original event.
- retry does not erase previous attempt.
- close recovery item must require reason.
- dismissed does not equal resolved.
- duplicate suspected must not create duplicate confirmed order.
- support-assisted recovery must show support scope.

## 5 Cross-References

- `docs/007000_admin_console/007110_Boundary_Admin_Support_And_BreakGlass.md`
- `docs/013000_app_api_projection/013110_Idempotency_Recovery_And_Audit_Envelope_Projection.md`
- `docs/017000_ui_screen_composition/017100_Governance_Action_Button_And_Status_Badge.md`
- `docs/024000_deployment_operations/024020_Boundary_Runtime_Operations_And_Support.md`

## 6 Open Decisions

- approval inbox layout.
- runtime profile diff view.
- emergency disable confirmation depth.
- rollback comparison view.
- support session review UI.
- audit evidence packet display.

## 7 Current Status

Status: active admin support UI authority and recovery model. Not implementation approval.
