# 070530_Policy_External_Refund_Method_Limit_Partial_Cancel_And_Customer_Return_Control.md

## Document Metadata

- Project: yoonsul_wait_order_handoff
- Document Type: Policy
- Lane: 70000 External Integration Control Plane
- Sub-Lane: 70500 External Cancel Refund Reversal And Compensation Control
- Status: Draft
- Owner: Payment Integrity / External Integration Governance
- Parent Index: [70500_Index_External_Cancel_Refund_Reversal_And_Compensation_Control.md](./070500_Index_External_Cancel_Refund_Reversal_And_Compensation_Control.md)
- Previous: [70520_Policy_External_Reversal_Net_Cancel_And_Compensation_Request_Control.md](./070520_Policy_External_Reversal_Net_Cancel_And_Compensation_Request_Control.md)
- Next: [70540_Runbook_External_Cancel_Refund_Reversal_Failure_Recovery_And_Manager_Action.md](./070540_Runbook_External_Cancel_Refund_Reversal_Failure_Recovery_And_Manager_Action.md)
- Related:
  - [70150_Policy_External_Payment_Timeout_Unknown_State_Inquiry_And_Ambiguous_Result_Control.md](./070150_Policy_External_Payment_Timeout_Unknown_State_Inquiry_And_Ambiguous_Result_Control.md)
  - [70320_Policy_External_Payment_Inquiry_Channel_Requirement_And_Response_Authority.md](./070320_Policy_External_Payment_Inquiry_Channel_Requirement_And_Response_Authority.md)
  - [70440_Policy_External_Response_Field_Mismatch_Conflict_And_Manual_Review_Control.md](./070440_Policy_External_Response_Field_Mismatch_Conflict_And_Manual_Review_Control.md)
  - `75000_Index_Payment_Integrity_Architecture_Self_Healing_Distributed_Transaction_And_Ledger_Governance.md` (미작성)

## 1. Purpose

This policy defines how external refund, partial cancel, customer return, and alternative refund flows are controlled when the original payment method or provider imposes limits.

The purpose is to prevent customer loss, merchant settlement mismatch, tax/accounting distortion, duplicate refund, unauthorized cash return, and untraceable manual compensation.

## 2. Core Principle

A refund is not merely the opposite of a payment.

A refund must be treated as a new financial event with its own eligibility check, provider capability check, state authority, evidence requirement, ledger impact, and reconciliation obligation.

No refund, partial cancel, manual return, point restoration, coupon restoration, cash return, bank transfer refund, or external provider refund may be finalized unless it is linked to an original payment intent, original approval evidence, refund request record, refund method decision, and reconciliation path.

## 3. Scope

This policy applies to refund and return flows involving:

- POS card approval cancel
- VAN cancel
- PG cancel
- partial cancel
- full cancel
- same-day cancel
- post-settlement refund
- simple pay refund
- Alipay / WeChatPay cross-border refund
- virtual account refund
- mobile carrier billing refund
- membership point restoration
- coupon and voucher restoration
- delivery app mediated refund
- external order app refund
- manual bank transfer refund
- customer cash return prohibition and exception handling

## 4. Refund Method Categories

| Category | Description | Primary Control |
|---|---|---|
| Full cancel | Entire original approved amount is cancelled through original provider | Provider cancel response validation |
| Partial cancel | Only part of original approved amount is cancelled | Provider capability and remaining balance validation |
| Post-settlement refund | Original payment already settled or deposited | Ledger offset and settlement reconciliation |
| Alternative refund | Original method cannot be used, bank transfer or other return needed | Manager approval and customer account evidence |
| Point/coupon restoration | Non-cash benefit is restored or reversed | Benefit ledger and fraud check |
| Delivery/app mediated refund | External channel controls refund path | Channel-specific evidence and reconciliation |
| Reversal / net cancel | System recovery cancel after incomplete transaction | 70520 policy applies |

## 5. Refund Eligibility Gate

A refund request must pass the following eligibility gate before provider call or manual return.

| Gate | Required Check | Failure Result |
|---|---|---|
| Original payment exists | Valid original payment intent and confirmed approval | Reject or manual investigation |
| Original amount known | Approved amount, tax, discount, service charge known | Hold |
| Refundable amount available | Requested refund <= remaining refundable amount | Reject |
| Provider capability known | Provider supports requested refund type | Route to alternative refund review |
| Payment state stable | Not UNKNOWN, not AMBIGUOUS, not unresolved conflict | Hold / Inquiry |
| Customer identity sufficient | Customer and order relationship verified | Manual review |
| Settlement impact known | Pre-settlement or post-settlement identified | Ledger routing |
| Duplicate refund check | Same order/refund amount/time not already processed | Reject / idempotent return |

## 6. Payment Method Limit Rules

### 6.1 Card / VAN / POS Payment

Card payment cancel must use the original approval information whenever possible.

Required fields:

- original approval number
- original approval date/time
- terminal id
- merchant id
- VAN trace id where available
- approved amount
- remaining refundable amount
- cancel amount
- cancel reason
- operator or manager id when manual

Partial cancel must not be assumed. Provider-specific support must be confirmed.

### 6.2 PG Card Payment

PG card refund must be initiated through the PG API or approved provider console process.

The internal system must store:

- PG payment key / transaction id
- refund request id
- refund id from PG
- refund response payload
- refund amount
- supply amount / VAT / fee impact where available
- refund status

### 6.3 Virtual Account

Virtual account flows are constrained by deposit state.

| State | Policy |
|---|---|
| Account issued, not deposited | Partial cancel is prohibited unless provider supports amount update explicitly |
| Deposited | Refund must follow provider refund or manual bank transfer process |
| Customer refund account needed | Customer account collection must follow privacy and evidence rules |
| Deposit mismatch | Hold and reconciliation exception |

### 6.4 Mobile Carrier Billing

Mobile carrier billing may impose month-bound cancel limits.

If provider cancel is no longer available due to carrier policy, the case must be routed to alternative refund review.

Manual bank transfer may be used only with manager approval, customer identity verification, refund account evidence, and ledger offset entry.

### 6.5 Simple Pay

Simple pay refund must follow the original provider path unless the provider declares the transaction non-refundable through the original method.

Simple pay provider response must be mapped to canonical refund status before internal state release.

### 6.6 Cross-Border Payment

Alipay / WeChatPay / cross-border refund may involve FX, settlement timing, provider-specific delay, and foreign currency customer notification.

The internal ledger must store both:

- merchant settlement currency amount
- customer-facing foreign currency amount when provided

No FX-adjusted manual refund may be executed without finance approval.

### 6.7 Membership Point / Coupon / Voucher

Benefit restoration must be treated as a separate ledger event.

A payment refund does not automatically restore all benefits unless the benefit ledger confirms eligibility.

Examples:

- used coupon may be restored if order failed before fulfillment
- expired coupon may require policy decision
- promotional point may be reversed rather than restored
- paid point balance must be treated differently from bonus point balance

## 7. Customer Return Control

Customer return means any money or value returned to the customer outside the original payment provider flow.

Customer return is allowed only when:

1. provider refund path is unavailable or inappropriate,
2. original payment and customer claim are verified,
3. refund amount is calculated and approved,
4. manager approval is recorded,
5. customer return method is captured,
6. accounting ledger entry is created,
7. reconciliation exception is linked.

Cash return at store level is prohibited unless explicitly approved by emergency SOP and later reconciled by finance.

## 8. Partial Cancel Control

Partial cancel must observe the following constraints.

| Constraint | Policy |
|---|---|
| Remaining refundable amount | Must be recalculated before every request |
| Tax and discount allocation | Must be recomputed or explicitly mapped |
| Service charge | Must follow store/provider policy |
| Coupon interaction | Must not create negative payable amount |
| Split payment | Each payment leg must be refunded separately |
| 1/N payment | Payer-level refund mapping is required |
| Delivery app order | Channel refund policy may override internal preference |
| Cross-border payment | Provider FX refund policy must be checked |

## 9. Split Payment and Multi-Tender Refund

If an order was paid using multiple tenders, refund must be allocated by tender.

Examples:

- card + point
- simple pay + coupon
- delivery app payment + store coupon
- card + gift voucher
- multiple customers 1/N payment

Refund must not exceed the amount originally collected per tender.

When automatic allocation is uncertain, the refund must be routed to manual review.

## 10. Canonical Refund States

All provider refund statuses must be mapped to canonical internal states.

```text
REFUND_REQUESTED
REFUND_ELIGIBILITY_CHECKED
REFUND_PROVIDER_REQUESTED
REFUND_PROVIDER_ACCEPTED
REFUND_CONFIRMED
REFUND_PARTIAL_CONFIRMED
REFUND_DECLINED
REFUND_TIMEOUT_UNKNOWN
REFUND_INQUIRY_PENDING
REFUND_CONFLICT
REFUND_ALTERNATIVE_REVIEW
REFUND_MANUAL_RETURN_PENDING
REFUND_MANUAL_RETURN_COMPLETED
REFUND_RECONCILIATION_PENDING
REFUND_RECONCILED
REFUND_FAILED_FINAL
```

## 11. Prohibited Actions

The following actions are prohibited.

- Marking a refund completed only because a refund button was clicked
- Treating refund timeout as confirmed failure
- Issuing manual customer return before original payment is verified
- Refunding more than the remaining refundable amount
- Refunding through cash without evidence and approval
- Restoring coupon/point without benefit ledger validation
- Manually editing approved amount or refund amount without audit trail
- Closing a customer claim before reconciliation confirms refund impact
- Assuming provider supports partial cancel without certification

## 12. Required Evidence

Every refund or customer return must preserve:

- original payment intent id
- original approval evidence
- refund request id
- refund method decision
- provider refund request payload
- provider refund response payload
- raw payload hash
- operator id
- manager approval id where applicable
- customer communication record
- accounting ledger entry id
- reconciliation result id

## 13. Reconciliation Requirement

A refund is not finally closed until settlement reconciliation verifies its impact.

The system must verify:

- original approval amount
- refund amount
- remaining refundable amount
- settlement deduction or provider chargeback impact
- fee reversal or non-reversal
- tax and VAT treatment
- bank deposit impact
- accounting ledger balance

## 14. Handoff

This policy hands off to:

- 70540 for operational failure recovery and manager action
- 70550 for refund/reversal evidence and audit logging
- 70600 for settlement, deposit, fee, and ledger reconciliation
- 75000 lane for idempotency, delayed net cancel, Saga, Outbox, and double-entry ledger architecture

## 15. Closeout Criteria

This policy is complete when:

- refund method categories are defined,
- partial cancel limits are documented,
- alternative customer return is controlled,
- canonical refund states are defined,
- prohibited actions are explicit,
- evidence and reconciliation requirements are linked.
