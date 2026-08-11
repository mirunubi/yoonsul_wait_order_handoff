# 070480_Register_External_Response_Correction_Exception_Gap_And_Open_Issue.md

## Document Control

- Document Type: Register
- Domain: External Integration Control Plane
- Parent Index: [70400_Index_External_Response_Validation_Correction_And_Canonical_Mapping.md](070400_Index_External_Response_Validation_Correction_And_Canonical_Mapping.md)
- Previous: [70470_Audit_External_Response_Correction_Evidence_Manager_Approval_And_Replay_Log.md](070470_Audit_External_Response_Correction_Evidence_Manager_Approval_And_Replay_Log.md)
- Next: [70490_Index_External_Response_Validation_Correction_And_Canonical_Mapping_Closeout_And_Handoff.md](070490_Index_External_Response_Validation_Correction_And_Canonical_Mapping_Closeout_And_Handoff.md)
- Related Root: [70000_Index_External_Integration_Control_Plane_Validation_Correction_Log_And_Process_Governance.md](070000_Readme_External_Integration_Control_Plane_Validation_Correction_Log_And_Process_Governance.md)
- Related Rules: [70005_Governance_External_Integration_And_Payment_Integrity_Document_Generation_Rules.md](070005_Governance_External_Integration_And_Payment_Integrity_Document_Generation_Rules.md)

## 1. Purpose

This register records unresolved exceptions, gaps, provider-specific limitations, mapping uncertainties, and open issues discovered during external response validation, correction, normalization, quarantine, and canonical mapping.

The purpose is not to hide uncertainty inside confirmed policy. Any provider response field, response code, timestamp, trace metadata, amount field, receipt field, cancellation field, or settlement field that cannot be safely accepted, corrected, normalized, or mapped must be recorded in this register until resolved.

## 2. Scope

This register applies to external responses from:

- POS providers
- VAN providers
- PG providers
- Simple payment providers
- Cross-border payment providers
- Card acquirers
- Settlement file providers
- Webhook providers
- Delivery app providers
- External order channels
- External membership, coupon, voucher, and point providers
- Kiosk and KDS vendors when they return financial or operational state events
- Accounting, tax, ERP, or deposit reconciliation providers

## 3. Register Principles

External responses are not corrected silently. Every unresolved or risky response issue must be tracked until one of the following outcomes is reached:

- Provider documentation confirms the mapping.
- Provider certification test confirms the mapping.
- Internal validation confirms the mapping through repeated evidence.
- Manual review approves a temporary workaround.
- The field is marked unsupported and blocked from state authority.
- The provider is rejected or escalated as non-compliant.

## 4. Open Issue Severity Levels

| Severity | Meaning | Default Action |
|---|---|---|
| S0 | Direct money, settlement, refund, or legal evidence risk | Block automatic state release and escalate immediately |
| S1 | Payment or order state ambiguity risk | Quarantine and require manager or integration owner review |
| S2 | Mapping or reporting inconsistency risk | Allow non-financial processing only after evidence tagging |
| S3 | Cosmetic, naming, display, or non-authoritative metadata issue | Track and resolve in normal backlog |

## 5. Register Columns

Each entry must contain at least the following fields.

| Field | Description |
|---|---|
| issue_id | Unique register identifier |
| discovered_at | Detection timestamp |
| provider | External provider name |
| channel | POS, VAN, PG, Webhook, settlement file, delivery app, membership, etc. |
| related_document | Policy, Spec, Audit, Matrix, or Runbook that surfaced the issue |
| issue_type | Mapping gap, correction exception, unsupported code, timestamp ambiguity, duplicate ambiguity, etc. |
| severity | S0/S1/S2/S3 |
| raw_field_or_code | Original provider field or code |
| canonical_candidate | Proposed internal canonical mapping, if any |
| risk_summary | Why this issue is dangerous or unresolved |
| temporary_control | Quarantine, manual review, no-state-authority, provider escalation, etc. |
| evidence_reference | Raw payload hash, trace id, receipt, inquiry response, settlement file, test case |
| owner | Internal owner responsible for resolution |
| target_resolution | Expected resolution path |
| status | OPEN, INVESTIGATING, PROVIDER_PENDING, WORKAROUND_APPROVED, RESOLVED, REJECTED |
| closed_at | Closure timestamp |
| closure_evidence | Evidence proving closure |

## 6. Issue Types

### 6.1 Provider Mapping Gap

A provider response code, status value, receipt field, trace field, terminal identifier, or settlement field has no confirmed canonical mapping.

Default action:

- Preserve raw payload.
- Do not silently map to SUCCESS, FAILED, CANCELLED, or REFUNDED.
- Assign `MAPPING_GAP` canonical status.
- Route to manual review or provider clarification.

### 6.2 Correction Exception

A malformed or incomplete field appears correctable, but the correction rule is not formally approved.

Default action:

- Do not apply permanent correction.
- If the issue is non-financial and non-state-authoritative, mark as `NORMALIZATION_CANDIDATE`.
- If the issue affects amount, approval number, cancellation state, provider transaction id, terminal id, or settlement amount, quarantine.

### 6.3 Conflicting Provider Evidence

Two or more external responses or files disagree with one another.

Examples:

- Webhook says payment approved, inquiry says not found.
- POS response says approved, settlement file excludes the transaction.
- Cancellation response says success, refund file does not include the refund.
- Provider transaction id appears under two internal orders.

Default action:

- Freeze automatic state release.
- Create reconciliation exception.
- Link all raw payloads and hashes.
- Escalate to payment integrity owner.

### 6.4 Timestamp Ambiguity

Provider event time, server receive time, approval time, settlement time, or business day boundary cannot be interpreted reliably.

Default action:

- Preserve all timestamps separately.
- Do not overwrite canonical event time without approved rule.
- Require timezone, business day, and provider settlement cycle confirmation.

### 6.5 Duplicate Ambiguity

Duplicate events cannot be safely identified as retry, replay, provider redelivery, duplicate approval, or fraud-risk signal.

Default action:

- Route to duplicate/idempotency review.
- Link to 70250 and 75000 payment integrity documents.
- Do not collapse duplicates unless idempotency key, provider transaction id, or trace identity proves equivalence.

### 6.6 Unsupported Provider Feature

A provider does not support required inquiry, cancellation inquiry, last transaction inquiry, settlement export, webhook signature, or raw evidence retrieval.

Default action:

- Record as provider capability gap.
- Mark provider integration as restricted.
- Require compensating operational SOP.
- Escalate to provider onboarding/certification lane.

## 7. Sample Register Entries

| issue_id | provider | channel | issue_type | severity | temporary_control | status |
|---|---|---|---|---|---|---|
| EXT-CORR-GAP-0001 | TBD_POS_A | POS RPC | Missing approval timestamp timezone | S1 | Quarantine until provider confirms timezone | OPEN |
| EXT-CORR-GAP-0002 | TBD_PG_B | Webhook | Webhook approved but inquiry not found | S0 | Freeze release and create reconciliation exception | INVESTIGATING |
| EXT-CORR-GAP-0003 | TBD_VAN_C | Settlement file | Settlement file lacks internal order id | S1 | Match only by provider trace + amount + terminal + date window | PROVIDER_PENDING |
| EXT-CORR-GAP-0004 | TBD_MEMBERSHIP_D | Membership API | Point reversal code not mapped | S1 | Block automatic point refund release | OPEN |

## 8. Resolution Workflow

1. Detect mismatch, mapping gap, correction exception, or unsupported provider behavior.
2. Store raw payload, raw file, response header, receipt data, or inquiry result.
3. Create register entry.
4. Assign severity.
5. Apply temporary control.
6. Link to relevant audit and runbook documents.
7. Request provider clarification or run certification test.
8. Approve mapping, correction rule, quarantine rule, or rejection.
9. Update canonical registry if resolved.
10. Close register entry only with evidence.

## 9. Prohibited Actions

The following actions are prohibited:

- Closing an issue without evidence.
- Mapping unknown provider code to success by assumption.
- Correcting amount, approval number, transaction id, cancellation state, refund state, or settlement amount without approved rule.
- Deleting raw payload after correction.
- Using display text as authoritative state.
- Treating provider documentation as final if live evidence contradicts it.
- Allowing unresolved S0 or S1 issue to bypass quarantine.

## 10. Required Links

Every issue in this register must link to at least one of the following where applicable:

- Raw payload audit record
- Provider mapping registry entry
- Validation gate decision
- Quarantine record
- Manager approval log
- Inquiry response record
- Replay log
- Reconciliation exception
- Provider support ticket
- Certification test evidence
- Contract or SLA gap record

## 11. Closeout Criteria

An issue may be closed only when:

- Canonical mapping is approved and documented.
- Correction or normalization rule is approved and tested.
- Provider limitation is documented and compensated by process control.
- The issue is rejected as unsupported and the integration path is blocked or restricted.
- Evidence is linked and immutable audit record is preserved.

## 12. Handoff

This register hands off unresolved provider and response correction risks to:

- [70490_Index_External_Response_Validation_Correction_And_Canonical_Mapping_Closeout_And_Handoff.md](070490_Index_External_Response_Validation_Correction_And_Canonical_Mapping_Closeout_And_Handoff.md)
- 70500 External Cancel Refund Reversal And Compensation Control lane
- 70600 External Settlement Reconciliation Deposit Fee And Ledger Audit lane
- 70800 External Provider Onboarding Certification And Contract Readiness lane
- 75000 Payment Integrity Architecture lane
