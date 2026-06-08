# 20160 Suspicious Activity Review And Escalation Governance

## 1 Purpose

Define how suspicious runtime events are reviewed and escalated.

Suspicious activity review must preserve fairness, append-only lineage, and authority separation.

This document defines governance only.
It does not create review queues, ticketing systems, or automated enforcement runtime.

## 2 Scope

In scope:

- Review workflow from detection through resolution.
- Escalation between store, HQ, and platform authority.
- Evidence packet requirements for suspicious activity.
- Customer and staff fairness principles.
- Audit requirements for review actions.

Out of scope:

- Law enforcement referral workflow.
- Automated punishment or financial adjustment.
- Support tooling implementation.
- Criminal investigation runtime.

## 3 Suspicious Activity Sources

| source | examples |
| --- | --- |
| runtime misuse signals | Patterns defined in `20150`. |
| integration anomaly | Abnormal POS/printer/Store Agent attempt patterns. |
| support session anomaly | Unusual support scope or action frequency. |
| cross-tenant isolation alert | Suspected tenant boundary violation per `20170`. |
| export/report anomaly | Unusual export request or approval pattern. |
| staff override anomaly | Repeated manual recovery or queue override without justification. |
| customer complaint channel | Reported harassment or unfair treatment through approved channels. |

## 4 Review States

| state | meaning |
| --- | --- |
| DETECTED | Signal recorded; no review decision yet. |
| NEEDS_CONTEXT | Additional context required before store or HQ review. |
| STORE_REVIEW | Store-level reviewer examining store-scoped context. |
| HQ_REVIEW | HQ/tenant operator reviewing multi-store or policy context. |
| PLATFORM_REVIEW | Platform reviewer examining cross-tenant or policy-boundary context. |
| RESOLVED_NO_ACTION | Review complete; no corrective action taken. |
| RESOLVED_WITH_ACTION | Review complete; corrective action taken within authority. |
| FALSE_POSITIVE | Signal determined not to represent misuse or abuse. |

Dismiss does not equal resolved.
Detection does not equal enforcement.

## 5 Escalation Rules

- every escalation must preserve original event context.
- escalation does not overwrite prior review state; append review lineage.
- store review may escalate to HQ when multi-store or policy context is required.
- HQ review may escalate to platform when tenant isolation or platform policy is involved.
- platform review does not bypass tenant approval where tenant policy requires it.
- support-assisted review must remain within scoped support session.
- financial or punitive consequence requires explicit authority beyond detection.

## 6 Evidence Packet Requirements

Minimum evidence packet must include:

- detection source and signal summary.
- actor context and role.
- tenant and store context.
- customer/session context where applicable.
- waiting and handoff state snapshot.
- related audit events chronology.
- prior review states and reviewer roles.
- support session reference if support assisted.

Evidence does not equal approval.
Review must be append-only.

## 7 Review Authority Separation

| role | may do | may not do |
| --- | --- | --- |
| store reviewer | Review store-scoped signals, request context, recommend action within store policy. | Approve cross-tenant access, change financial truth, dismiss without reason. |
| HQ reviewer | Review tenant-scoped patterns, escalate to platform, approve tenant-level action. | Bypass platform policy, export raw cross-tenant data without approval. |
| platform reviewer | Review isolation and policy-boundary cases, coordinate tenant notification. | Directly mutate customer financial status, bypass audit lineage. |
| support reviewer | Assist within scoped session; document support action. | Approve own support action, enforce punishment, export without approval. |

## 8 Customer/Staff Fairness Principles

- suspicion is not proof.
- reviewers must consider operational context before action.
- false positives must be recordable without penalty to customer or staff by default.
- customer-facing status must not change on detection alone.
- staff-facing accusations must not be shown without review completion.
- repeated false accusations against same actor require review cadence.
- harassment reports require balanced review of customer and staff context.

## 9 Audit Requirements

- all state transitions must append audit events.
- review comments must not replace original detection event.
- resolved states must include reason and reviewer authority.
- false positive marking must remain auditable.
- corrective action must link to review decision event.
- escalation must preserve chronology from DETECTED forward.

## 10 Non-Implementation Boundary

- no review queue implementation.
- no ticketing integration.
- no automated escalation jobs.
- no SQL, migrations, or schema.
- no RPC, Edge Functions, or API endpoints.
- no notification product.
- no punishment automation.

## 11 Cross-References

- `docs/20000_validation_security_audit/20150_Runtime_Misuse_And_Abuse_Prevention_Governance.md`
- `docs/20000_validation_security_audit/20180_Audit_Evidence_Packet_And_Runtime_Forensics_Governance.md`
- `docs/20000_validation_security_audit/20090_Support_Access_Masking_And_Scoped_Session_Governance.md`
- `docs/07000_admin_console/07100_Admin_Audit_Review_And_Change_History_Model.md`

## 12 Open Decisions

- default first reviewer by signal type.
- SLA for each review state.
- customer/staff notification timing.
- appeal or reopen workflow.
- integration with recovery queue naming.

## 13 Current Status

Status: active suspicious activity review and escalation governance. Not implementation approval.
