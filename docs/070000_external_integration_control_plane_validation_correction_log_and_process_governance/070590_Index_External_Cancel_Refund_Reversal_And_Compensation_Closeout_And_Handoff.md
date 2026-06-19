# 070590_Index_External_Cancel_Refund_Reversal_And_Compensation_Closeout_And_Handoff.md

## 1. Purpose

This document closes the 70500 External Cancel, Refund, Reversal, and Compensation Control document set for the yoonsul_wait_order_handoff project.

The purpose of this closeout is to confirm that external cancel/refund/reversal handling is no longer treated as a simple API retry problem. It is a controlled financial recovery process that must preserve payment integrity, customer trust, store operational continuity, reconciliation accuracy, and audit evidence.

This document hands off unresolved and downstream concerns to settlement reconciliation, payment integrity architecture, double-entry ledger governance, and distributed transaction self-healing controls.

## 2. Scope

This closeout covers the 70500 family:

- 70500_Index_External_Cancel_Refund_Reversal_And_Compensation_Control.md
- 70510_Policy_External_Cancel_Refund_State_Authority_And_Request_Eligibility_Control.md
- 70520_Policy_External_Reversal_Net_Cancel_And_Compensation_Request_Control.md
- 70530_Policy_External_Refund_Method_Limit_Partial_Cancel_And_Customer_Return_Control.md
- 70540_Runbook_External_Cancel_Refund_Reversal_Failure_Recovery_And_Manager_Action.md
- 70550_Matrix_External_Cancel_Refund_Reversal_Failure_Mode_Action_And_Escalation_Map.md
- 70560_Audit_External_Cancel_Refund_Reversal_Evidence_Manager_Approval_And_Customer_Notice_Log.md
- 70570_Register_External_Cancel_Refund_Reversal_Exception_Gap_And_Open_Issue.md

This closeout does not close the entire external integration lane. It closes only the cancel/refund/reversal/compensation control slice and prepares the next handoff to settlement, deposit, fee, and ledger audit controls.

## 3. Control Position

The 70500 family establishes the following position:

1. A cancel is not the same as a refund.
2. A refund is not the same as a reversal.
3. A reversal is not the same as a delayed net cancel.
4. A compensation transaction is not a casual operational fix.
5. A failed cancel/refund/reversal must not be hidden by manual status editing.
6. Customer notice must be evidence-backed.
7. Accounting hold and reconciliation exception workflows are mandatory when money movement cannot be proven.

The system must distinguish customer-driven cancellation from system-driven financial recovery.

## 4. Completion Criteria

The 70500 family is considered complete when all of the following are defined:

| Area | Closeout Requirement | Status |
|---|---|---|
| Request authority | Who may request cancel/refund/reversal is defined | Closed |
| State eligibility | Which payment/order states permit cancel/refund/reversal is defined | Closed |
| UNKNOWN protection | UNKNOWN payments cannot be cancelled or refunded blindly | Closed |
| Reversal control | Net cancel and recovery reversal are separated from ordinary refund | Closed |
| Refund limits | Method-specific refund constraints are identified | Closed |
| Manual customer return | Fallback customer return path is governed | Closed |
| Failure handling | Failure modes and escalation paths are mapped | Closed |
| Evidence chain | Raw request/response, approval, customer notice, and ledger hold are logged | Closed |
| Open issues | Provider-specific and method-specific gaps are registered | Closed |

## 5. Required State Model Alignment

Cancel/refund/reversal decisions must align with the external payment state model.

Allowed control states include:

- CANCEL_REQUESTED
- CANCEL_PENDING
- CANCEL_CONFIRMED
- CANCEL_FAILED
- REFUND_REQUESTED
- REFUND_PENDING
- REFUND_CONFIRMED
- REFUND_FAILED
- REVERSAL_PENDING
- REVERSAL_CONFIRMED
- REVERSAL_FAILED
- COMPENSATION_REQUIRED
- MANUAL_RETURN_REQUIRED
- ACCOUNTING_HOLD
- RECONCILIATION_EXCEPTION
- VENDOR_ESCALATION

Disallowed shortcuts:

- Directly changing CONFIRMED to CANCELLED without external proof
- Directly changing REFUND_PENDING to REFUNDED without provider confirmation
- Treating timeout as cancel success
- Treating provider not-found as cancel success
- Treating manual cash return as external refund success
- Removing a reconciliation exception without audit approval

## 6. Evidence Requirements

Every cancel/refund/reversal/compensation action must preserve an evidence chain.

Minimum evidence:

- original payment intent id
- original order id
- provider transaction id
- approval number or external trace id when available
- cancel/refund/reversal request payload
- raw provider response payload
- response timestamp
- normalized canonical result
- manager approval id when required
- customer notice log when customer-facing impact exists
- accounting hold id when settlement is uncertain
- reconciliation exception id when unresolved after provider response
- tamper hash of original and corrected payloads

Evidence must be immutable after financial state release except through an approved correction event.

## 7. Handoff to 70600 Settlement, Deposit, Fee, and Ledger Audit

The next lane must verify whether cancel/refund/reversal/compensation results are reflected in settlement and deposit flows.

Handoff items:

1. Whether cancelled transactions are excluded from settlement.
2. Whether refunded transactions are properly netted against later settlement.
3. Whether reversal results are distinguishable from ordinary refund in settlement files.
4. Whether manual customer return creates accounting liability or expense records.
5. Whether provider fee refunds are expected, partial, delayed, or unavailable.
6. Whether tax/VAT impact is reversed or adjusted correctly.
7. Whether settlement files reflect the same payment state as internal canonical state.
8. Whether D+N settlement cycle and holiday handling affect refund/reversal timing.
9. Whether chargeback/dispute events should be separated from ordinary refund.
10. Whether cross-store set-off or provider-level netting creates reconciliation gaps.

Recommended next document:

- 70600_Index_External_Settlement_Reconciliation_Deposit_Fee_And_Ledger_Audit.md

## 8. Handoff to 75000 Payment Integrity Architecture

The 70500 family identifies several concerns that belong to the 75000 architecture lane rather than the 70000 external integration lane.

Handoff items:

- idempotent cancel/refund/reversal commands
- delayed net cancel worker design
- reversal queue state machine
- Saga compensation transaction sequence
- transactional outbox event publication for cancel/refund/reversal
- double-entry ledger entries for refunds, liabilities, holds, and manual returns
- CDC/event replay integrity
- self-healing recovery after provider timeout
- payment lifecycle state machine hardening
- accounting-grade immutable audit ledger integration

Recommended 75000 references:

- 75000_Index_Payment_Integrity_Architecture_Self_Healing_Distributed_Transaction_And_Ledger_Governance.md

## 9. Residual Risks

The following risks remain open for downstream lanes:

| Risk | Required Downstream Control |
|---|---|
| Provider says refund success but settlement does not reflect it | 70600 reconciliation |
| Customer receives manual refund but external payment remains approved | 70600/75000 ledger controls |
| Cancel response is timeout but provider later confirms cancel | 70300 inquiry and 75000 self-healing |
| Same refund command is submitted multiple times | 75000 idempotency |
| Refund success event is lost after DB update | 75000 transactional outbox |
| Reversal fails after order compensation | 75000 Saga orchestration |
| Provider fee is not returned after refund | 70600 fee audit |
| Tax/VAT correction is inconsistent | 71500 accounting/tax integration |

## 10. Governance Rules

1. A financial recovery action must never be treated as a UI status correction.
2. A provider response must be validated before state release.
3. Any customer-facing refund claim must be backed by provider evidence or clearly labeled as pending.
4. Manual return is a separate accounting action, not a substitute for provider refund confirmation.
5. Reversal and net cancel must be traceable to the original failed or ambiguous transaction.
6. All unresolved recovery events must enter reconciliation or vendor escalation.
7. Any correction after customer notice must create a new audit event.

## 11. Closeout Decision

The 70500 External Cancel, Refund, Reversal, and Compensation Control family is closed for first-pass documentation.

The lane is ready to hand off to:

- 70600 External Settlement Reconciliation Deposit Fee And Ledger Audit
- 75000 Payment Integrity Architecture
- 71500 External Accounting Tax And ERP Integration
- 72400 External Integration Data Retention Privacy And Legal Hold

## 12. Next Document

Next recommended file:

- 70600_Index_External_Settlement_Reconciliation_Deposit_Fee_And_Ledger_Audit.md
