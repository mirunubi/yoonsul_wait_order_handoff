# 070380_Register_External_Payment_Inquiry_Recovery_Exception_Gap_And_Open_Issue.md

## 1. Document Control

- Document Number: 70380
- Document Type: Register
- Domain: External Integration Control Plane / External Payment Inquiry And Recovery
- Parent Index: 70300_Index_External_Payment_Inquiry_Unknown_State_And_Recovery_Governance.md
- Previous Document: 70370_Audit_External_Payment_Inquiry_Recovery_Evidence_And_Manager_Decision_Log.md
- Next Document: 70390_Index_External_Payment_Inquiry_Unknown_State_And_Recovery_Closeout_And_Handoff.md
- Related Documents:
  - 70000_Index_External_Integration_Control_Plane_Validation_Correction_Log_And_Process_Governance.md
  - 70100_Index_POS_VAN_PG_And_External_Payment_Integration_Governance.md
  - 70200_Index_External_RPC_API_Webhook_Response_Contract_And_Event_Control.md
  - 75000_Index_Payment_Integrity_Architecture_Self_Healing_Distributed_Transaction_And_Ledger_Governance.md

## 2. Purpose

This register defines the controlled list of exceptions, gaps, unresolved vendor limitations, open issues, and deferred controls related to external payment inquiry, UNKNOWN state recovery, and payment state release.

The purpose of this document is to prevent unresolved recovery assumptions from being hidden inside implementation code, store operation notes, vendor conversations, or temporary incident handling. Any case where payment state cannot be safely confirmed, corrected, reversed, reconciled, or released must be tracked in this register until formally closed.

## 3. Scope

This register applies to external payment recovery cases involving:

- POS payment inquiry
- VAN approval inquiry
- VAN cancel inquiry
- PG payment inquiry
- PG cancel/refund inquiry
- Simple payment provider inquiry
- Alipay / WeChatPay / cross-border payment inquiry
- Card acquirer inquiry
- Settlement file mismatch
- Unknown approval state
- Unknown cancel state
- Missing receipt evidence
- Duplicate or conflicting approval numbers
- Provider-specific response ambiguity
- Store manager manual decision
- Customer claim recovery
- Reconciliation exception handoff

## 4. Register Principle

No UNKNOWN payment recovery issue may be treated as closed only because the customer left the store, the store operator made a verbal judgment, the vendor verbally replied, or the UI no longer shows the error.

A recovery issue is closed only when one of the following is true:

1. The external inquiry result has been validated against the internal payment intent ledger.
2. The approval or cancel state is confirmed with sufficient external evidence.
3. A compensation or reversal transaction has completed and been audited.
4. A reconciliation result confirms the final state.
5. A manager override has been approved with retained evidence and legal/accounting follow-up.
6. The issue has been formally converted into a separate incident, defect, vendor escalation, or policy gap item.

## 5. Register Fields

Each register item must include the following fields.

| Field | Required | Description |
|---|---:|---|
| register_id | Yes | Unique register item identifier |
| detected_at | Yes | Time the exception or gap was detected |
| detected_by | Yes | System, store operator, support, finance, audit, or vendor |
| store_id | Conditional | Required if related to a store transaction |
| provider_type | Yes | POS, VAN, PG, simple payment, acquirer, delivery app, membership, accounting, other |
| provider_name | Conditional | External provider name if known |
| payment_intent_id | Conditional | Internal payment intent identifier |
| order_id | Conditional | Internal order identifier |
| external_transaction_id | Conditional | External transaction identifier |
| approval_no | Conditional | Approval number if available |
| issue_category | Yes | Inquiry gap, evidence gap, state conflict, provider limitation, recovery failure, process gap |
| current_state | Yes | UNKNOWN, INQUIRY_PENDING, MANUAL_REVIEW, HOLD, REVERSAL_PENDING, RECONCILIATION_EXCEPTION, CLOSED |
| expected_state | Conditional | Target state after resolution |
| evidence_status | Yes | Complete, partial, missing, conflicting, vendor pending |
| customer_impact | Yes | None, possible charge, confirmed charge, refund delay, order delay, dispute risk |
| financial_impact | Yes | None, pending, amount known, amount unknown, settlement risk |
| owner | Yes | Responsible internal owner |
| due_date | Conditional | Required for open high-risk items |
| escalation_level | Yes | Store, support, finance, engineering, vendor, legal, executive |
| closure_condition | Yes | Evidence or action required before closure |
| closure_evidence_uri | Conditional | Link to final evidence packet when closed |
| closed_at | Conditional | Required when closed |

## 6. Issue Categories

### 6.1 Inquiry Channel Gap

Used when the provider does not supply a sufficient inquiry channel.

Examples:

- No approval inquiry API
- No cancel inquiry API
- No last transaction inquiry
- No settlement file access
- Inquiry response does not include approval number
- Inquiry response cannot search by internal order reference
- Inquiry response cannot search by terminal ID and time window

Required action:

- Register provider gap
- Mark provider as limited recovery capable
- Add onboarding or certification blocker
- Define manual fallback procedure

### 6.2 Evidence Gap

Used when recovery decision cannot be supported by sufficient evidence.

Examples:

- Missing raw payload
- Missing receipt data
- Missing VAN trace ID
- Missing PG transaction ID
- Missing cancel receipt
- Missing manager approval log
- Verbal vendor confirmation without written or API evidence

Required action:

- Keep state in MANUAL_REVIEW or HOLD
- Request additional evidence
- Prevent automatic reconciliation closeout

### 6.3 State Conflict

Used when internal and external states disagree.

Examples:

- Internal order failed but external approval succeeded
- Internal payment failed but card approval exists
- Internal cancel succeeded but provider cancel not found
- Provider says approved but settlement file omits the transaction
- Provider says cancelled but customer claim shows charge remains

Required action:

- Block automatic state release
- Route to recovery decision matrix
- Create reconciliation exception if not resolved within the defined window

### 6.4 Recovery Failure

Used when a defined recovery action fails.

Examples:

- Inquiry repeatedly fails
- Reversal request fails
- Net cancel unavailable
- Cancel API returns transaction not found
- Manual refund required
- Provider escalation exceeds SLA

Required action:

- Escalate according to provider severity
- Link to manager decision log
- Link to customer claim or refund evidence if applicable

### 6.5 Provider Limitation

Used when the limitation is structural rather than incident-specific.

Examples:

- Provider cannot expose raw transaction payload
- Provider does not support idempotency key
- Provider does not support duplicate transaction search
- Provider does not provide settlement file by API
- Provider uses ambiguous success code
- Provider cannot support partial cancel for a payment method

Required action:

- Add provider limitation to certification record
- Define adapter-specific guardrail
- Consider provider exclusion from production tier

### 6.6 Process Gap

Used when the internal process is insufficient.

Examples:

- No store operator script for UNKNOWN payment
- No manager approval path
- No finance reconciliation owner
- No customer notification template
- No SLA for vendor escalation
- No retention rule for inquiry evidence

Required action:

- Convert to policy, SOP, runbook, matrix, or template document
- Keep register item open until the document is generated and linked

## 7. Severity Model

| Severity | Meaning | Default Escalation |
|---|---|---|
| S1 | Customer charged but order/service not confirmed | Store manager + support + finance + engineering |
| S2 | Cancel/refund state unknown or delayed | Support + finance + provider |
| S3 | Internal/external state mismatch without immediate customer claim | Finance + engineering |
| S4 | Provider evidence gap or certification weakness | Integration owner + vendor manager |
| S5 | Documentation or process gap without active transaction impact | Documentation owner |

S1 and S2 issues must not be closed without evidence packet attachment.

## 8. Register Lifecycle

```text
DETECTED
→ TRIAGED
→ OWNER_ASSIGNED
→ EVIDENCE_REQUESTED
→ RECOVERY_IN_PROGRESS
→ RESOLUTION_PROPOSED
→ VALIDATION_PENDING
→ CLOSED
```

Alternative paths:

```text
DETECTED
→ TRIAGED
→ VENDOR_ESCALATED
→ RECONCILIATION_EXCEPTION
→ CLOSED
```

```text
DETECTED
→ TRIAGED
→ PROCESS_GAP_IDENTIFIED
→ DOCUMENT_GENERATION_REQUIRED
→ DOCUMENT_LINKED
→ CLOSED
```

## 9. Closure Rules

A register item must not be closed when:

- Only a screenshot exists without transaction identifiers.
- Only a verbal provider response exists.
- The customer has not complained yet but the state remains ambiguous.
- The POS screen shows success but internal ledger validation failed.
- The internal ledger shows cancel success but external cancel evidence is missing.
- The amount differs by even 1 KRW unless an approved fee, rounding, or tax rule explains it.
- The issue is likely to recur but no control or document has been created.

## 10. Required Evidence By Issue Type

| Issue Type | Minimum Evidence |
|---|---|
| Approval unknown | payment intent, request log, inquiry response, provider trace, final state decision |
| Cancel unknown | original approval evidence, cancel request log, cancel inquiry result, refund/customer notice evidence |
| Duplicate approval | all approval numbers, amount comparison, selected valid approval, reversal/cancel evidence for duplicates |
| Missing order after approval | approval evidence, order recovery or cancel evidence, manager decision |
| Settlement mismatch | internal ledger, provider settlement file, bank deposit record, fee/tax calculation |
| Provider limitation | vendor response, contract/API documentation note, workaround or blocker decision |
| Process gap | gap description, owner, required document, generated document link |

## 11. Example Register Items

| register_id | issue_category | current_state | owner | closure_condition |
|---|---|---|---|---|
| EXT-PAY-GAP-0001 | Inquiry Channel Gap | OPEN | Integration Owner | Provider confirms approval inquiry API or manual settlement fallback is documented |
| EXT-PAY-GAP-0002 | Evidence Gap | MANUAL_REVIEW | Audit Owner | Raw response payload and receipt evidence are attached or exception is approved |
| EXT-PAY-GAP-0003 | State Conflict | RECONCILIATION_EXCEPTION | Finance Owner | Internal ledger, provider settlement file, and bank deposit are reconciled |
| EXT-PAY-GAP-0004 | Process Gap | DOCUMENT_GENERATION_REQUIRED | Documentation Owner | Store UNKNOWN payment SOP is generated and linked |

## 12. Handoff To Related Lanes

This register feeds the following lanes:

- 70400 External Response Validation, Correction, And Canonical Mapping
- 70500 External Cancel, Refund, Reversal, And Compensation Control
- 70600 External Settlement, Deposit, Fee, And Ledger Audit
- 70700 External Webhook, Callback, Idempotency, And Event Delivery Control
- 70800 External Provider Onboarding, Certification, And Contract Readiness
- 70900 External Integration Incident, Dispute, And Customer Claim Recovery
- 75000 Payment Integrity Architecture

## 13. Completion Criteria

This document is complete when:

- All UNKNOWN recovery exceptions have a register category.
- All evidence gaps have an owner and closure condition.
- All provider limitations can be escalated into onboarding or certification review.
- All process gaps can be converted into SOP, Runbook, Matrix, Policy, or Template documents.
- No payment recovery issue can disappear without audit closure.
