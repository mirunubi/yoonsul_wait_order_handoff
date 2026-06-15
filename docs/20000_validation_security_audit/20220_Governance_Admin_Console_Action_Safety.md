# 20220_Governance_Admin_Console_Action_Safety

## 1 Purpose

Define safety governance for admin console actions across store, HQ, and platform administration.

Admin console actions must be auditable, authority-bound, and recoverable without silent mutation.

This document defines governance only.
It does not create admin UI, auth middleware, or approval workflow runtime.

## 2 Scope

In scope:

- Admin action categories and dangerous action rules.
- Confirmation and dual-control candidate requirements.
- Audit, rollback, and correction principles.
- Relationship to support, export, and suspicious activity governance.

Out of scope:

- Admin console UI implementation.
- RBAC schema and RLS policies.
- Break-glass tooling implementation.
- Automated rollback runtime.

Aligns with `docs/07000_admin_console/07080_Governance_Admin_Runtime_Profile_Configuration.md` and related admin governance docs at console level.

## 3 Admin Action Categories

| action category | governance meaning |
| --- | --- |
| read-only visibility | View state within role/context scope. |
| configuration change | Draft or request runtime profile, package, or flag change. |
| support access | Open or extend scoped support session. |
| masking override request | Request elevated visibility with audit; not default path. |
| export/report request | Submit governed export or report request. |
| suspicious activity review action | Transition review state per `20160`. |
| tenant/store role management | Change role or context assignment with audit. |
| emergency/break-glass action | Future-only high-risk path; rare, scoped, time-limited. |

## 4 Dangerous Action Rules

- admin visibility is not mutation authority.
- configuration changes must be auditable.
- approval does not equal activation.
- emergency disable does not erase audit.
- support action does not equal approval.
- export request does not equal export delivery.
- role change does not retroactively rewrite prior audit actor context.
- break-glass access must be rare, scoped, time-limited, and reviewed.

## 5 Confirmation Requirements

High-risk actions require explicit confirmation context:

- runtime profile activation.
- emergency disable.
- rollback of approved configuration.
- masking override request.
- export/report approval.
- tenant/store role elevation.
- break-glass or future emergency support candidate.

Confirmation UI is not implementation approval; confirmation must preserve reason and actor in audit.

## 6 Dual-Control Candidates

Dual-control may be required for:

- platform-level high-risk flag activation.
- cross-store configuration batch change.
- masking override for customer-identifiable data.
- export of sensitive operational datasets.
- break-glass access approval.
- tenant offboarding data actions.

Dual-control policy owner remains open; governance requires separation of requester and approver.

## 7 Audit Requirements

- every admin mutation appends audit event.
- context switch is auditable separately from mutation.
- approval, activation, and rollback form linkable lineage.
- support-assisted admin action must reference support session.
- suspicious activity review transitions must preserve DETECTED origin.
- failed or cancelled dangerous action must still audit attempt where policy requires.

## 8 Rollback/Correction Principles

- rollback is not silent deletion.
- correction must preserve original audit context.
- rollback does not erase prior activation or approval events.
- correction of customer-facing wording does not rewrite financial markers without authority.
- emergency disable rollback requires separate review from original disable reason.

## 9 Non-Implementation Boundary

- no admin console code.
- no approval inbox implementation.
- no SQL, migrations, or schema.
- no RLS or auth middleware.
- no break-glass product.
- no automatic rollback jobs.

## 10 Cross-References

- `docs/07000_admin_console/07110_Boundary_Admin_Support_And_BreakGlass.md`
- `docs/20000_validation_security_audit/20040_Governance_Admin_Access_And_Support_Access.md`
- `docs/20000_validation_security_audit/20080_Governance_Access_Context_And_Data_Visibility.md`
- `docs/20000_validation_security_audit/20160_Governance_Suspicious_Activity_Review_And_Escalation.md`

## 11 Open Decisions

- dual-control action list at MVP.
- confirmation modal depth by action type.
- break-glass approval owner.
- store vs tenant vs platform admin split.
- rollback comparison view requirements.

## 12 Current Status

Status: active admin console action safety governance. Not implementation approval.
