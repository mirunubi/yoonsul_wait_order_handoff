# 070510_Policy_External_Cancel_Refund_State_Authority_And_Request_Eligibility_Control.md

## Document Control

- Project: yoonsul_wait_order_handoff
- Document Type: Policy
- Number: 70510
- Domain: External Integration Control Plane
- Parent Index: 70500_Index_External_Cancel_Refund_Reversal_And_Compensation_Control.md
- Previous: 70500_Index_External_Cancel_Refund_Reversal_And_Compensation_Control.md
- Next: 70520_Policy_External_Reversal_Net_Cancel_And_Compensation_Request_Control.md
- Status: Draft
- Owner: External Integration Governance / Payment Integrity Owner

## 1. Purpose

This policy defines when an external cancel, refund, reversal, or compensation request may be created, approved, transmitted, retried, blocked, or escalated.

The policy exists to prevent unsafe cancellation behavior, including:

- cancelling a payment that was never confirmed;
- declaring a refund complete before external confirmation;
- issuing duplicate cancellations for the same approval;
- treating payment timeout as payment failure;
- mixing business refund with system recovery reversal;
- allowing store operators or automated jobs to override payment state without evidence.

## 2. Scope

This policy applies to all external payment and value-affecting integrations, including:

- POS payment cancellation;
- VAN approval cancellation;
- PG cancel and refund API;
- simple payment cancel and refund;
- cross-border payment reversal;
- membership point refund or rollback;
- coupon/voucher restoration;
- delivery app order cancellation with payment impact;
- settlement adjustment caused by cancellation or refund;
- manager-approved manual recovery action.

## 3. Core Principle

External cancel or refund must never be treated as a local database update.

A local order status change does not prove that an external financial network has cancelled, refunded, reversed, or settled the transaction.

The internal system may only mark cancel/refund as final after the relevant external evidence has passed validation.

## 4. Terminology

| Term | Meaning |
|---|---|
| Business Cancel | Customer or store-requested cancellation before or after fulfillment according to business policy. |
| Refund | Return of captured/settled or partially settled value to the customer. |
| Reversal | System-level rollback of a financial transaction that became unsafe, ambiguous, duplicated, or inconsistent. |
| Net Cancel | Network-level cancel used when a payment was possibly approved externally but did not complete safely inside our system. |
| Compensation | Logical correction transaction that offsets an already committed action. |
| UNKNOWN | State where the system cannot confirm whether external payment was approved, declined, cancelled, or still pending. |
| Authority | Component or role allowed to request, approve, transmit, or finalize cancellation/refund state. |

## 5. State Authority Model

External cancel/refund state authority is split into five layers.

| Layer | Authority |
|---|---|
| Request Authority | May create a cancel/refund/reversal intent. |
| Transmission Authority | May transmit the request to external provider. |
| Evidence Authority | May accept external response, inquiry result, webhook, or settlement file as evidence. |
| State Authority | May update canonical internal payment/order state. |
| Audit Authority | May seal evidence and approve final closeout. |

No single external response may bypass these layers.

## 6. Eligible Request States

| Current Canonical State | Business Cancel Allowed | Refund Allowed | Reversal / Net Cancel Allowed | Notes |
|---|---:|---:|---:|---|
| PAYMENT_REQUESTED | No | No | No | No external payment evidence exists yet. |
| SENT_TO_EXTERNAL | No | No | Conditional | Only if timeout/unsafe result is detected. |
| PAYMENT_CONFIRMED | Yes | Conditional | Conditional | Requires approval evidence and policy check. |
| ORDER_CONFIRMED | Yes | Conditional | Conditional | Fulfillment status must be checked. |
| FULFILLMENT_STARTED | Conditional | Conditional | No automatic cancel | Store/manager policy applies. |
| FULFILLED | No normal cancel | Conditional refund | No automatic reversal | Refund policy applies. |
| PAYMENT_DECLINED | No | No | No | Nothing to refund unless later inquiry contradicts this. |
| TIMEOUT_UNKNOWN | No | No | Inquiry first | Cannot cancel/refund without inquiry evidence. |
| AMBIGUOUS | No | No | Inquiry and review first | State must be resolved before final action. |
| MISMATCHED | No | No | Manual review | Amount/order/provider conflict must be resolved. |
| REVERSAL_PENDING | No | No | Already in progress | Duplicate reversal forbidden. |
| CANCEL_PENDING | No | No | No | Await cancel result. |
| REFUND_PENDING | No | No | No | Await refund result. |
| CANCEL_CONFIRMED | No | No | No | Final unless settlement dispute appears. |
| REFUND_CONFIRMED | No | No | No | Final unless settlement dispute appears. |

## 7. Prohibited Actions

The following actions are prohibited:

1. Marking an order as cancelled only because the local POS screen shows a cancel button result.
2. Marking a refund as complete before external confirmation is received and validated.
3. Running cancel API repeatedly without idempotency key or duplicate protection.
4. Issuing refund while payment is in UNKNOWN, AMBIGUOUS, or MISMATCHED state.
5. Cancelling an approval whose approval number, provider transaction id, or trace id cannot be matched.
6. Reusing a business cancel workflow for net cancel or reversal.
7. Manually editing settlement status to hide unresolved cancel/refund mismatch.
8. Restoring coupon, point, or membership benefit before payment refund authority is determined.
9. Providing final customer notice without audit evidence.

## 8. Required Evidence Before Request

Before sending any external cancel/refund request, the system must collect and link:

- payment intent id;
- order id;
- store id;
- terminal id if applicable;
- provider id;
- approval number if present;
- provider transaction id;
- original approved amount;
- requested cancel/refund amount;
- reason code;
- current fulfillment status;
- current payment canonical state;
- duplicate request check result;
- manager approval if required;
- idempotency key;
- request payload hash.

## 9. Full Cancel Eligibility

Full cancel may be attempted only when:

1. the original payment is confirmed;
2. the cancel amount equals the confirmed payment amount;
3. no previous successful cancel exists;
4. no pending cancel/refund/reversal exists;
5. the fulfillment and store policy permit cancellation;
6. the provider supports the requested cancel type;
7. the request has a unique cancel intent id and idempotency key.

## 10. Partial Refund Eligibility

Partial refund may be attempted only when:

1. the provider supports partial refund for the payment method;
2. the original payment is confirmed;
3. the requested refund amount is greater than zero;
4. cumulative refunded amount plus requested amount does not exceed approved amount;
5. item-level allocation is known;
6. tax, discount, coupon, point, and service charge allocation can be calculated;
7. provider-specific constraints are satisfied;
8. manual review is completed when allocation is ambiguous.

## 11. UNKNOWN State Restriction

UNKNOWN is not a failure state.

If payment state is UNKNOWN, the system must not:

- create a normal refund;
- tell the customer payment failed;
- tell the customer refund is complete;
- re-run payment automatically;
- cancel the order as unpaid;
- release inventory without recovery review;
- restore points or coupons unless a recovery policy permits provisional restoration.

The system must first perform inquiry, evidence validation, and recovery decision according to the 70300 series.

## 12. Reversal and Net Cancel Separation

Reversal and net cancel are not customer refund features.

They are system recovery actions used when a transaction may have affected the external financial network but did not complete safely inside the internal system.

Reversal and net cancel must follow 70520 and 75000-series integrity architecture documents.

## 13. Manager Approval Rules

Manager approval is required when:

- refund amount exceeds configured threshold;
- partial refund allocation is ambiguous;
- payment state was previously UNKNOWN or AMBIGUOUS;
- provider inquiry result conflicts with internal ledger;
- manual compensation is required;
- customer dispute has already been opened;
- the refund is outside normal provider cancel window;
- external provider requires manual support ticket.

Manager approval must be recorded as an audit event, not as a direct database edit.

## 14. Idempotency Requirement

Every cancel/refund/reversal request must have a unique idempotency key scoped by:

- provider;
- merchant/store;
- original payment transaction;
- operation type;
- requested amount;
- sequence number.

Duplicate request with same idempotency key must return the original result or remain pending. It must not create a second external financial action.

## 15. Response Handling

External cancel/refund response must be treated as raw evidence first.

The system must:

1. store raw response;
2. hash response payload;
3. map provider response code to canonical code;
4. validate amount, transaction id, approval id, and status;
5. determine final, pending, failed, unknown, or manual review state;
6. create audit evidence;
7. update internal state only through the state authority gate.

## 16. Failure Handling

If cancel/refund request times out or returns ambiguous result, the system must not retry blindly.

The system must:

- mark operation as CANCEL_UNKNOWN or REFUND_UNKNOWN;
- perform cancel/refund inquiry if available;
- block duplicate manual attempts;
- escalate to provider if inquiry is unavailable;
- keep order/payment state on hold until evidence is obtained;
- include the transaction in reconciliation exception queue.

## 17. Customer Communication Rule

Customer-facing message must reflect evidence level.

| Evidence Level | Allowed Message |
|---|---|
| Request accepted internally | Cancellation request is being checked. |
| External request transmitted | Cancellation is being processed by payment provider. |
| External confirmation received | Cancellation/refund has been confirmed. |
| UNKNOWN | Payment result is being verified. |
| Provider escalation | Provider confirmation is required before final notice. |

Do not claim final refund completion unless external evidence has passed validation.

## 18. Audit Requirements

Every cancel/refund/reversal workflow must produce:

- cancel/refund intent record;
- original payment reference;
- request payload and hash;
- response payload and hash;
- idempotency key;
- operator/manager action log;
- state transition log;
- customer notice log;
- provider inquiry evidence if applicable;
- reconciliation follow-up status.

## 19. Relationship To Other Documents

- 70500_Index_External_Cancel_Refund_Reversal_And_Compensation_Control.md
- 70520_Policy_External_Reversal_Net_Cancel_And_Compensation_Request_Control.md
- 70300_Index_External_Payment_Inquiry_Unknown_State_And_Recovery_Governance.md
- 70400_Index_External_Response_Validation_Correction_And_Canonical_Mapping.md
- 75000_Index_Payment_Integrity_Architecture_Self_Healing_Distributed_Transaction_And_Ledger_Governance.md
- 70005_Governance_External_Integration_And_Payment_Integrity_Document_Generation_Rules.md

## 20. Closeout Criteria

This policy is complete when:

- cancel/refund/reversal eligibility states are defined;
- UNKNOWN and AMBIGUOUS state restrictions are explicit;
- manager approval criteria are documented;
- idempotency requirement is mandatory;
- external response validation is required before final state update;
- customer communication is tied to evidence level;
- audit requirements are linked to later evidence documents.
