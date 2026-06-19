# 070570_Register_External_Cancel_Refund_Reversal_Exception_Gap_And_Open_Issue.md

## 1. Document Control

| Field | Value |
|---|---|
| Document ID | 70570 |
| Document Type | Register |
| Domain | External Integration Control Plane |
| Lane | External Cancel / Refund / Reversal / Compensation Control |
| Parent Index | [70500_Index_External_Cancel_Refund_Reversal_And_Compensation_Control.md](./70500_Index_External_Cancel_Refund_Reversal_And_Compensation_Control.md) |
| Previous | [70560_Audit_External_Cancel_Refund_Reversal_Evidence_Manager_Approval_And_Customer_Notice_Log.md](./70560_Audit_External_Cancel_Refund_Reversal_Evidence_Manager_Approval_And_Customer_Notice_Log.md) |
| Next | [70590_Index_External_Cancel_Refund_Reversal_And_Compensation_Closeout_And_Handoff.md](./70590_Index_External_Cancel_Refund_Reversal_And_Compensation_Closeout_And_Handoff.md) |
| Related Root | [70000_Index_External_Integration_Control_Plane_Validation_Correction_Log_And_Process_Governance.md](./70000_Index_External_Integration_Control_Plane_Validation_Correction_Log_And_Process_Governance.md) |
| Related Integrity Root | [75000_Index_Payment_Integrity_Architecture_Self_Healing_Distributed_Transaction_And_Ledger_Governance.md](./75000_Index_Payment_Integrity_Architecture_Self_Healing_Distributed_Transaction_And_Ledger_Governance.md) |
| Status | Draft |

---

## 2. Purpose

This register tracks open exceptions, unresolved gaps, provider-specific limitations, and follow-up issues related to external cancel, refund, reversal, net-cancel, and compensation processing.

The purpose is to prevent unresolved payment recovery issues from being hidden inside operational notes, support tickets, vendor emails, or one-time manager decisions. Every unresolved cancel/refund/reversal limitation must remain visible until one of the following occurs:

1. It is resolved by provider contract, API capability, or operational procedure.
2. It is accepted as a known limitation with approved risk treatment.
3. It is transferred to Payment Integrity Architecture under the 75000 lane.
4. It is converted into a new Policy, Runbook, Audit, Matrix, or SOP document.

---

## 3. Register Scope

This register covers open issues involving:

- normal customer refund;
- card approval cancel;
- payment method specific cancel limits;
- partial cancel limitations;
- same-day versus post-settlement refund behavior;
- net cancel / reversal for incomplete transactions;
- compensation transaction for order/payment mismatch;
- vendor inquiry limitation;
- delayed provider response;
- customer return method outside original payment rail;
- manager override;
- accounting hold and release;
- reconciliation exception after refund or reversal.

This register does not replace the operational runbook. The operational procedure remains governed by:

- [70540_Runbook_External_Cancel_Refund_Reversal_Failure_Recovery_And_Manager_Action.md](./70540_Runbook_External_Cancel_Refund_Reversal_Failure_Recovery_And_Manager_Action.md)
- [70550_Matrix_External_Cancel_Refund_Reversal_Failure_Mode_Action_And_Escalation_Map.md](./70550_Matrix_External_Cancel_Refund_Reversal_Failure_Mode_Action_And_Escalation_Map.md)
- [70560_Audit_External_Cancel_Refund_Reversal_Evidence_Manager_Approval_And_Customer_Notice_Log.md](./70560_Audit_External_Cancel_Refund_Reversal_Evidence_Manager_Approval_And_Customer_Notice_Log.md)

---

## 4. Register Principles

### 4.1 No Hidden Refund Exception

No unresolved refund, cancel, reversal, or compensation exception may remain only in chat, email, phone call, spreadsheet, or vendor portal memo. It must be registered here or in the system equivalent of this register.

### 4.2 No Silent Manual Settlement

If a customer is returned money through a manual method outside the original payment rail, the event must be registered as an exception and linked to the accounting ledger and customer notice evidence.

### 4.3 No Assumed Provider Capability

If a provider does not explicitly support a required inquiry, cancel, partial cancel, refund, or reversal operation, the capability must be marked as unknown or unavailable. It must not be assumed.

### 4.4 No Auto-Close Without Evidence

An exception cannot be closed only because an operator believes the matter is handled. Closure requires evidence such as provider response, ledger match, customer notice record, manager approval, and reconciliation result.

### 4.5 Transfer to 75000 When It Becomes Architecture

If a recurring exception reveals a systemic architecture problem, it must be transferred to the 75000 Payment Integrity Architecture lane rather than being repeatedly handled as an operations issue.

---

## 5. Exception Register Schema

Every register item must include the following fields.

| Field | Required | Description |
|---|---:|---|
| exception_id | Yes | Unique register ID |
| discovered_at | Yes | First detection timestamp |
| provider_type | Yes | POS, VAN, PG, easy-pay, card acquirer, delivery app, membership, accounting, other |
| provider_name | Conditional | Provider name if known |
| store_id | Conditional | Affected store |
| order_id | Conditional | Affected order |
| payment_id | Conditional | Internal payment identifier |
| external_transaction_id | Conditional | Provider transaction ID, approval number, paymentKey, TID, or trace ID |
| exception_type | Yes | Cancel limit, refund failure, reversal failure, inquiry missing, settlement mismatch, etc. |
| severity | Yes | S0, S1, S2, S3, S4 |
| customer_impact | Yes | None, delayed refund, double charge risk, unpaid order, claim risk, legal risk |
| accounting_impact | Yes | None, hold, settlement mismatch, fee mismatch, tax risk |
| current_state | Yes | OPEN, UNDER_REVIEW, VENDOR_PENDING, MANAGER_PENDING, ACCOUNTING_HOLD, TRANSFERRED, RESOLVED, ACCEPTED_RISK |
| required_evidence | Yes | Evidence required for closure |
| owner | Yes | Operational owner |
| due_at | Conditional | Due date if time-bound |
| linked_documents | Yes | Policies/runbooks/audits related to the issue |
| resolution | Conditional | Final resolution details |
| closed_at | Conditional | Closure timestamp |
| approver | Conditional | Required for closure or risk acceptance |

---

## 6. Severity Classification

| Severity | Meaning | Required Action |
|---|---|---|
| S0 | Customer money loss, double charge, large settlement mismatch, or legal exposure likely | Immediate incident escalation, manager hold, provider escalation, accounting hold |
| S1 | Refund/reversal failure with customer impact or unresolved provider state | Same-day review, inquiry/retry, customer notice, manager approval |
| S2 | Provider limitation or mismatch that can be contained operationally | Register, assign owner, define workaround |
| S3 | Documentation gap, mapping ambiguity, or non-critical process gap | Convert to TODO or follow-up document |
| S4 | Improvement item without current operational impact | Backlog and periodic review |

---

## 7. Default Exception Categories

### 7.1 Cancel and Refund Capability Gap

Use this category when a provider or payment method does not support a needed operation.

Examples:

- partial cancel unavailable;
- same-day cancel only;
- post-settlement refund requires manual provider portal action;
- virtual account refund requires customer bank account collection;
- mobile carrier billing cannot be cancelled after month-end;
- cross-border payment refund requires FX-adjusted provider process.

### 7.2 Reversal / Net Cancel Failure

Use this category when a system recovery transaction fails or remains unresolved.

Examples:

- net cancel request returns transaction not found;
- reversal request timeout;
- reversal success response received without matching original approval;
- duplicated reversal request detected;
- provider inquiry cannot prove reversal finality.

### 7.3 Compensation Transaction Gap

Use this category when internal services are inconsistent after an external payment event.

Examples:

- payment succeeded but order creation failed;
- points deducted but payment declined;
- inventory reserved but payment not confirmed;
- refund succeeded but order status was not restored;
- accounting hold was not created after manual customer return.

### 7.4 Evidence Gap

Use this category when the operational action may be correct but the evidence is insufficient.

Examples:

- missing raw provider payload;
- missing approval number;
- missing receipt/slip data;
- missing manager approval;
- missing customer notice log;
- missing inquiry response;
- missing reconciliation result.

### 7.5 Provider Contract Gap

Use this category when the provider contract, onboarding checklist, or API documentation is insufficient.

Examples:

- no SLA for inquiry response;
- no webhook retry policy disclosed;
- no refund limitation matrix;
- no settlement file format guarantee;
- no audit evidence export;
- no sandbox for reversal testing.

---

## 8. Open Issue Table

| Exception ID | Category | Severity | Summary | Current State | Owner | Target Resolution | Linked Evidence |
|---|---|---:|---|---|---|---|---|
| EXT-CRR-0001 | Provider Contract Gap | S2 | Provider-specific partial cancel capability must be confirmed during onboarding. | OPEN | External Integration Owner | Add to provider certification checklist | TBD |
| EXT-CRR-0002 | Evidence Gap | S2 | Minimum raw payload retention fields for refund and reversal responses must be verified against audit storage. | OPEN | Audit Owner | Link to 70560 and storage schema | TBD |
| EXT-CRR-0003 | Compensation Transaction Gap | S1 | Payment success / order creation failure needs 75000 Saga compensation mapping. | TRANSFER_PENDING | Payment Integrity Owner | Transfer to 75000 Saga lane | TBD |
| EXT-CRR-0004 | Reversal / Net Cancel Failure | S1 | Delayed net-cancel retry timing must be validated per provider. | OPEN | Payment Recovery Owner | Provider-specific delay matrix | TBD |
| EXT-CRR-0005 | Accounting Impact | S2 | Manual customer return outside original payment rail requires double-entry ledger handling. | TRANSFER_PENDING | Accounting Owner | Transfer to 75000 double-entry ledger lane | TBD |

---

## 9. Closure Requirements

A register item may be closed only when all applicable conditions are satisfied.

| Condition | Required For Closure |
|---|---|
| Provider final response attached | Required for provider-dependent issues |
| Raw response or inquiry payload retained | Required for payment-state issues |
| Manager approval recorded | Required for customer-impacting refund/reversal decisions |
| Customer notice recorded | Required for delayed refund, manual return, or claim risk |
| Accounting hold released or converted | Required for financial-impacting issues |
| Reconciliation result linked | Required for settlement-impacting issues |
| Follow-up document created or linked | Required for architecture/process gaps |
| Risk acceptance approved | Required when limitation cannot be resolved |

---

## 10. Transfer Rules

### 10.1 Transfer to 70600 Settlement and Reconciliation

Transfer the issue when the primary unresolved impact is settlement amount, fee calculation, deposit timing, or provider settlement file mismatch.

### 10.2 Transfer to 70800 Provider Onboarding

Transfer the issue when the root cause is provider capability, contract terms, certification checklist, or missing API evidence.

### 10.3 Transfer to 70900 Incident / Dispute / Customer Claim

Transfer the issue when the customer has already filed a claim, chargeback, complaint, or formal dispute.

### 10.4 Transfer to 75000 Payment Integrity Architecture

Transfer the issue when the root cause requires architecture-level design such as:

- idempotency;
- delayed net cancel;
- Saga compensation;
- transactional outbox;
- double-entry ledger;
- event sourcing;
- reconciliation engine;
- hardware watchdog;
- provider simulator.

---

## 11. Required Review Cadence

| Review Type | Cadence | Owner |
|---|---|---|
| S0/S1 exception review | Daily until resolved | Incident Manager / Payment Recovery Owner |
| S2 exception review | Weekly | External Integration Owner |
| S3/S4 backlog review | Biweekly or sprint planning | Documentation / Product Owner |
| Provider gap review | Before provider certification and quarterly thereafter | Vendor Owner |
| Architecture transfer review | Before 75000 lane closeout | Payment Integrity Owner |

---

## 12. Non-Negotiable Prohibitions

The following actions are prohibited:

1. Closing a refund/reversal issue without provider or reconciliation evidence.
2. Treating a manual customer return as a normal refund without accounting linkage.
3. Deleting raw payloads after a successful correction.
4. Reusing a reversal idempotency key across unrelated original payments.
5. Reclassifying UNKNOWN as FAILED only because a timeout occurred.
6. Reclassifying UNKNOWN as SUCCESS only because a customer screenshot appears to show payment.
7. Applying automatic correction to amount, approval number, store ID, terminal ID, or settlement amount conflicts.
8. Hiding provider limitations in implementation notes rather than this register.
9. Allowing Cursor or any generation tool to mark an unresolved financial process as fully resolved without explicit human approval.

---

## 13. Handoff

This register hands unresolved issues to the following lanes:

- [70590_Index_External_Cancel_Refund_Reversal_And_Compensation_Closeout_And_Handoff.md](./70590_Index_External_Cancel_Refund_Reversal_And_Compensation_Closeout_And_Handoff.md)
- [70600_Index_External_Settlement_Reconciliation_Deposit_Fee_And_Ledger_Audit.md](./70600_Index_External_Settlement_Reconciliation_Deposit_Fee_And_Ledger_Audit.md)
- [70800_Index_External_Provider_Onboarding_Certification_And_Contract_Readiness.md](./70800_Index_External_Provider_Onboarding_Certification_And_Contract_Readiness.md)
- [75000_Index_Payment_Integrity_Architecture_Self_Healing_Distributed_Transaction_And_Ledger_Governance.md](./75000_Index_Payment_Integrity_Architecture_Self_Healing_Distributed_Transaction_And_Ledger_Governance.md)

The next document in this lane should close the cancel/refund/reversal control bundle and transfer remaining settlement and architecture issues to the appropriate lanes.
