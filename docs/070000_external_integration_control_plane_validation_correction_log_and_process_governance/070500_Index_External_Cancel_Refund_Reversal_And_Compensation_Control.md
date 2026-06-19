# 070500_Index_External_Cancel_Refund_Reversal_And_Compensation_Control.md

## 1. Purpose

This document opens the 70500 External Cancel, Refund, Reversal, and Compensation Control lane for `yoonsul_wait_order_handoff`.

This lane governs how the system handles external cancellation, refund, net cancel, reversal, and compensation events across POS, VAN, PG, easy payment providers, cross-border payment providers, delivery/order channels, external membership/coupon systems, and settlement providers.

The primary objective is to prevent money accidents when an external transaction must be reversed, cancelled, refunded, compensated, or held for manual review.

## 2. Scope

This lane covers:

- normal customer-requested cancellation
- partial cancellation and partial refund constraints
- payment approval reversal after internal order failure
- net cancel after timeout or unknown result
- refund after settlement has already occurred
- refund method fallback when provider API cancellation is unavailable
- duplicate cancellation prevention
- cancellation inquiry and refund inquiry
- external provider cancellation response validation
- compensation transaction design
- store manager approval and customer claim evidence
- reconciliation handoff after cancellation/refund/reversal

This lane does not replace the 75000 Payment Integrity Architecture lane. The 70500 lane defines the external operational control surface; the 75000 lane defines the deeper architectural mechanisms such as idempotency, Saga orchestration, transactional outbox, ledger, and self-healing recovery.

## 3. Parent And Related Documents

| Relationship | Document |
|---|---|
| Parent root | `70000_Index_External_Integration_Control_Plane_Validation_Correction_Log_And_Process_Governance.md` |
| Generation rule | `70005_Governance_External_Integration_And_Payment_Integrity_Document_Generation_Rules.md` |
| Payment integration parent | `70100_Index_POS_VAN_PG_And_External_Payment_Integration_Governance.md` |
| RPC/API/Webhook contract | `70200_Index_External_RPC_API_Webhook_Response_Contract_And_Event_Control.md` |
| Unknown state and inquiry | `70300_Index_External_Payment_Inquiry_Unknown_State_And_Recovery_Governance.md` |
| Response validation and correction | `70400_Index_External_Response_Validation_Correction_And_Canonical_Mapping.md` |
| Payment integrity architecture | `75000_Index_Payment_Integrity_Architecture_Self_Healing_Distributed_Transaction_And_Ledger_Governance.md` |

## 4. Control Principle

External cancellation and refund events must never be treated as simple inverse operations of approval.

A payment approval, cancellation, refund, reversal, or compensation action may touch multiple systems:

- internal order ledger
- payment intent ledger
- external provider approval ledger
- POS local ledger
- VAN/PG transaction ledger
- membership point ledger
- coupon/voucher ledger
- inventory or kitchen fulfillment state
- settlement and accounting ledger
- customer claim evidence packet

Therefore, every cancellation or refund action must pass through a controlled decision layer before internal final state is changed.

## 5. State Separation

The system must distinguish the following concepts:

| Concept | Meaning |
|---|---|
| Cancel | Normal cancellation of an approved transaction before or after order confirmation, depending on provider rules |
| Refund | Returning money to the customer after payment and possibly after settlement |
| Partial Refund | Refunding only part of the approved amount, subject to provider and payment-method limitations |
| Reversal | System-level rollback of an approval when internal workflow failed or external result was ambiguous |
| Net Cancel | Network/payment-provider-level cancellation after timeout or uncertain approval completion |
| Compensation | Business-level counter-transaction used to restore consistency after partial failure |
| Manual Refund | Non-API refund path such as bank transfer when provider cancellation is impossible |
| Settlement Set-off | Deduction from future settlement due to post-settlement refund |

## 6. Canonical Cancellation And Refund States

The following canonical states must be used across this lane:

```text
CANCEL_REQUESTED
CANCEL_SENT_TO_PROVIDER
CANCEL_RESPONSE_RECEIVED
CANCEL_CONFIRMED
CANCEL_DECLINED
CANCEL_UNKNOWN
CANCEL_INQUIRY_PENDING
CANCEL_RETRY_PENDING
REVERSAL_REQUIRED
REVERSAL_PENDING
REVERSAL_CONFIRMED
REFUND_REQUESTED
REFUND_PENDING
REFUND_CONFIRMED
REFUND_DECLINED
REFUND_MANUAL_REQUIRED
PARTIAL_REFUND_BLOCKED
SETTLEMENT_OFFSET_PENDING
MANUAL_REVIEW_REQUIRED
RECONCILIATION_EXCEPTION
```

External provider-specific states must be mapped into these canonical states before they are allowed to affect the internal order, payment, or settlement ledger.

## 7. Required Ledgers

Every cancellation/refund/reversal flow must write to the following ledgers or equivalent tables:

| Ledger | Required Purpose |
|---|---|
| Payment intent ledger | Original payment request and expected amount |
| External approval response ledger | Raw approval response and provider trace |
| Cancel/refund request ledger | Who requested the action and why |
| Cancel/refund response ledger | Raw provider response and canonical interpretation |
| Compensation ledger | Logical business reversal and Saga compensation action |
| Manager decision log | Manual approval, rejection, override, or escalation |
| Customer communication log | What was told to the customer and when |
| Reconciliation exception ledger | Any unresolved external/internal mismatch |
| Accounting ledger | Settlement, fee, VAT, offset, receivable/payable impact |

## 8. Mandatory Validation Before Cancellation Or Refund

Before sending a cancellation/refund request to an external provider, the system must validate:

1. original approval exists and is canonical-confirmed;
2. approval amount matches the internal order/payment ledger;
3. cancellation/refund amount is allowed for the payment method;
4. cancellation/refund window has not expired;
5. the transaction has not already been cancelled or refunded;
6. settlement status is known or explicitly marked unknown;
7. membership point/coupon/inventory/kitchen states are eligible for compensation;
8. idempotency key is generated for the cancellation/refund action;
9. provider supports the requested operation;
10. manual approval is obtained if required by severity or amount threshold.

## 9. Mandatory Validation After Provider Response

After receiving a cancellation/refund/reversal response, the system must validate:

- provider transaction identifier
- original approval number
- cancellation/refund transaction identifier
- approved cancellation/refund amount
- response code and mapped canonical state
- terminal, merchant, store, or channel identifier
- provider timestamp and local received timestamp
- duplicate response status
- raw payload hash
- settlement and accounting impact

A provider response must not directly finalize the internal state until this validation gate passes.

## 10. Prohibited Actions

The following actions are prohibited:

- marking payment as cancelled because a provider API call timed out;
- treating cancellation timeout as cancellation failure without inquiry;
- issuing a second cancellation without idempotency and duplicate check;
- refunding manually before verifying whether provider cancellation already succeeded;
- changing order status to cancelled without payment state validation;
- deleting raw external cancellation/refund payloads;
- correcting financial fields without manager approval and audit log;
- completing customer claim handling without evidence packet generation;
- ignoring provider-specific partial refund restrictions;
- treating post-settlement refund as the same as pre-settlement cancellation.

## 11. Required Subdocuments

The 70500 lane is expected to contain the following documents:

| No. | Document |
|---:|---|
| 70500 | `70500_Index_External_Cancel_Refund_Reversal_And_Compensation_Control.md` |
| 70510 | `70510_Policy_External_Cancel_Refund_State_Authority_And_Request_Eligibility_Control.md` |
| 70520 | `70520_Spec_External_Cancel_Refund_Response_Field_Registry_And_Provider_Mapping.md` |
| 70530 | `70530_Policy_External_Reversal_Net_Cancel_Timeout_And_Unknown_Result_Control.md` |
| 70540 | `70540_Policy_External_Refund_Method_Window_Partial_Refund_And_Fallback_Control.md` |
| 70550 | `70550_Matrix_External_Cancel_Refund_Reversal_Failure_Mode_And_Recovery_Action.md` |
| 70560 | `70560_Runbook_External_Cancel_Refund_Reversal_Manager_Action_And_Customer_Claim.md` |
| 70570 | `70570_Audit_External_Cancel_Refund_Reversal_Evidence_Raw_Log_And_Approval_Record.md` |
| 70580 | `70580_Register_External_Cancel_Refund_Reversal_Exception_Gap_And_Open_Issue.md` |
| 70590 | `70590_Index_External_Cancel_Refund_Reversal_And_Compensation_Closeout_And_Handoff.md` |

## 12. Handoff To 75000 Payment Integrity Architecture

This lane must hand off the following items to the 75000 lane:

- idempotency design for cancellation/refund/reversal requests
- delayed net cancel architecture
- Saga compensation ordering
- transactional outbox event delivery for cancellation and refund events
- double-entry ledger postings for refund, receivable, payable, and settlement offset
- reconciliation exception handling after refund or cancellation
- self-healing retry and batch repair jobs

## 13. Handoff To 70600 Settlement And Ledger Audit

This lane must hand off the following items to the 70600 lane:

- post-settlement refund impact
- fee reversal or non-reversal handling
- VAT and supply amount recalculation
- settlement offset and provider claim receivable tracking
- daily closing mismatch after cancellation/refund
- bank deposit variance after refund set-off

## 14. Closeout Criteria

This lane can be considered complete only when:

1. every cancellation/refund/reversal state has a canonical state;
2. every provider response has raw payload preservation and field mapping;
3. timeout and unknown cancellation results are handled through inquiry;
4. duplicate cancellation/refund requests are prevented by idempotency;
5. partial refund restrictions are documented by payment method;
6. manual refund fallback is controlled by approval and audit evidence;
7. settlement and accounting impact is handed off to 70600;
8. deeper architectural controls are handed off to 75000;
9. manager and customer claim runbooks are linked;
10. open provider gaps are registered in the 70580 register.

## 15. Status

Draft status: Initial index created for 70500 lane opening.

Next document: `70510_Policy_External_Cancel_Refund_State_Authority_And_Request_Eligibility_Control.md`
