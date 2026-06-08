# 20200 Staff Privacy And Operational Monitoring Governance

## 1 Purpose

Define boundaries for staff privacy, operational monitoring, and misuse prevention.

Staff monitoring exists for operational safety and accountability, not personal surveillance.

This document defines governance only.
It does not create workforce monitoring products, disciplinary systems, or HR integration.

## 2 Scope

In scope:

- Staff data categories and monitoring boundaries.
- Prohibited surveillance patterns.
- Fairness and review requirements for staff-related signals.
- Store, HQ, and platform visibility boundaries.
- Relationship to suspicious activity review.

Out of scope:

- Employment law compliance finalization.
- Payroll or HR disciplinary workflow.
- Biometric or physical surveillance.
- Automated termination or compensation adjustment.

## 3 Staff Data Categories

| category | governance meaning |
| --- | --- |
| staff identity | Staff account or role-linked identity within tenant/store scope. |
| role/permission context | Assigned roles and operational authority scope. |
| action logs | Staff confirmations, queue actions, manual POS markers, recovery actions. |
| support/session logs | Support-assisted actions involving staff context. |
| queue/order manipulation events | Staff changes to waiting, handoff, or order candidate state. |
| review/escalation records | Misuse or suspicious activity review involving staff actor. |

## 4 Monitoring Principles

- monitoring is for operational safety, not personal surveillance.
- monitoring must be purpose-limited to handoff and store operations.
- staff action logs must support accountability, not ambient behavior tracking.
- aggregate operational metrics must not expose individual staff PII by default.
- monitoring signals feed review; they do not auto-discipline.

## 5 Prohibited Staff Surveillance Patterns

- continuous off-duty or off-system behavior monitoring.
- using handoff logs for unrelated performance scoring without policy basis.
- sharing individual staff action detail across tenants.
- exposing staff identity to customers without operational need.
- using support session to browse unrelated staff personal data.
- covert monitoring without audit and policy basis.

## 6 Fairness and Review Requirements

- suspicion is not proof.
- detection does not equal discipline.
- disciplinary or financial consequences require human review and proper authority.
- staff must be reviewable through append-only escalation per `20160`.
- false positive marking must be auditable.
- repeated accusations against same staff actor require review cadence.

## 7 Store Owner/HQ/Platform Visibility Boundaries

| visibility level | may see | may not imply |
| --- | --- | --- |
| store owner/manager | Store-scoped staff action and review context. | Cross-store staff surveillance without policy. |
| HQ | Tenant-scoped operational patterns and escalation summaries. | Individual disciplinary authority without process. |
| platform | Policy-bound isolation and support review context. | Unrestricted staff browsing across tenants. |

## 8 Relationship to Suspicious Activity Review

- staff-related misuse signals route to `20160` review states.
- staff review records must link to original operational events.
- store reviewer authority is store-scoped unless escalated.
- platform review does not bypass tenant HR or policy authority by default.
- support-assisted staff review must show support scope.

## 9 Required Audit Events

- staff action affecting queue, handoff, or order candidate.
- staff-related suspicious signal detection and review state change.
- escalation involving staff actor.
- staff visibility access outside normal store console scope.
- correction or rollback of staff-attributed action.
- export request containing staff-identifiable operational detail.

## 10 Non-Implementation Boundary

- no workforce analytics product.
- no disciplinary workflow engine.
- no SQL, migrations, or schema.
- no RLS or auth middleware.
- no biometric integration.
- no automated sanction runtime.

## 11 Cross-References

- `docs/20000_validation_security_audit/20150_Runtime_Misuse_And_Abuse_Prevention_Governance.md`
- `docs/20000_validation_security_audit/20160_Suspicious_Activity_Review_And_Escalation_Governance.md`
- `docs/20000_validation_security_audit/20080_Access_Context_And_Data_Visibility_Governance.md`

## 12 Open Decisions

- staff identity depth at MVP.
- store manager review SLA.
- staff notification after review outcome.
- HR policy integration boundary.
- retention period for staff action logs.

## 13 Current Status

Status: active staff privacy and operational monitoring governance. Not implementation approval.
