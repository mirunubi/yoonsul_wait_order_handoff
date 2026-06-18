# 014310_Policy_First_Store_Payment_Order_Separation_And_Reconciliation.md

## 1. Purpose

This policy defines how the first store separates order state, payment state, POS entry state, kitchen handoff state, and reconciliation state.

It is required because Catch & Order may operate before deep POS/payment integration is available.

The goal is to prevent unsafe assumptions such as treating order intent as payment completion, treating manual POS entry as payment approval, or treating kitchen handoff as financial settlement.

## 2. Core Principle

Order state and payment state must be separated.

Catch & Order may record:

- customer order intent
- staff POS entry confirmation
- kitchen handoff confirmation
- manual correction evidence
- cancellation/refund request evidence
- reconciliation status

But payment completion must only be marked when payment evidence exists from an approved source.

## 3. State Domains

| Domain | Meaning | Source Of Truth |
|---|---|---|
| Order Intent | Customer/session requested order | Catch & Order |
| POS Entry | Staff entered order into POS | POS + staff confirmation |
| Kitchen Handoff | Order was sent to kitchen | KDS/printer/manual note evidence |
| Payment | Payment approved/cancelled/refunded | POS/payment terminal/VAN/PG/official event |
| Fulfillment | Food prepared/served/picked up | Store staff/kitchen confirmation |
| Reconciliation | Daily comparison of records | Store manager/finance review |

## 4. Non-Mixing Rule

Do not infer one state from another.

| Do Not Infer | From |
|---|---|
| Payment complete | order created |
| Payment complete | POS entry confirmed |
| POS entry complete | customer submitted order |
| Kitchen handoff complete | POS entry confirmed |
| Refund complete | cancellation request |
| Settlement complete | payment approval |
| Order completed | payment approved |
| Customer served | kitchen ready |

Each state must have its own evidence.

## 5. Approved Payment Evidence

Payment state may be confirmed only by:

| Evidence Source | Allowed |
|---|---|
| POS payment receipt/reference | Yes |
| payment terminal/CAT approval reference | Yes |
| VAN/PG/PAYCO official event | Yes if integrated/verified |
| staff confirmation with receipt reference | Yes |
| customer claim only | No |
| order intent only | No |
| kitchen prepared state | No |
| screen memory without evidence | No |

## 6. Manual Mode Payment Rules

In first-store manual mode:

1. Catch & Order does not execute payment.
2. POS/payment terminal handles payment.
3. Staff may record payment status only with evidence.
4. Refund and cancellation follow store POS/payment terminal procedure.
5. Daily reconciliation verifies Catch & Order, POS, payment, and manual correction records.

## 7. Payment State Values

Allowed payment states:

| State | Meaning |
|---|---|
| Payment Not Required Yet | Order has not reached payment point |
| Payment Pending | Payment expected but not confirmed |
| Payment Confirmed By POS | POS/payment terminal evidence exists |
| Payment Observed Officially | Official payment event received |
| Payment Cancelled | Cancel evidence exists |
| Refund Requested | Refund requested but not confirmed |
| Refund Confirmed | Refund evidence exists |
| Payment Unknown | Staff/system cannot confirm |
| Reconciliation Required | Payment/order mismatch exists |

## 8. Order State Values

Allowed order states:

| State | Meaning |
|---|---|
| Order Intent Created | Customer/session created order |
| Staff Reviewing | Staff is reviewing before POS entry |
| POS Entry Pending | Not yet entered into POS |
| POS Entry Confirmed | Staff confirmed POS entry |
| Kitchen Handoff Pending | Not yet sent to kitchen |
| Kitchen Handoff Confirmed | Kitchen received handoff |
| In Preparation | Kitchen started work |
| Ready | Food ready |
| Served / Picked Up | Customer/store completed fulfillment |
| Cancel Requested | Cancellation requested |
| Cancel Confirmed | Cancellation evidence exists |
| Correction Required | Manual mismatch/correction needed |
| Reconciliation Required | Order/payment/POS mismatch exists |

## 9. Cancellation Policy

Cancellation must be separated into:

| Cancellation Stage | Required Evidence |
|---|---|
| Before POS Entry | Catch & Order cancellation note |
| After POS Entry | POS cancellation reference or staff evidence |
| After Kitchen Handoff | kitchen cancellation confirmation |
| After Payment | payment cancellation/refund evidence |
| After Preparation | manager decision and waste/remake note |

Do not mark cancellation complete until the affected state domains are updated.

## 10. Refund Policy

Refund must be confirmed only when payment-side evidence exists.

Required refund evidence:

- payment reference
- refund reference if available
- staff id
- refund reason
- refund time
- POS/payment terminal evidence
- manager approval if required
- reconciliation status

Catch & Order may store refund request before refund confirmation, but must not display refund complete until confirmed.

## 11. Reconciliation Rule

Daily reconciliation must compare:

| Source | What To Check |
|---|---|
| Catch & Order order records | order intent and staff states |
| POS records | entered sales/orders |
| payment terminal/VAN/PG | payment, cancel, refund |
| kitchen handoff records | fulfillment movement |
| manual corrections | operational differences |
| incident log | unresolved mismatch |
| customer support notes | customer-impacting cases |

## 12. Reconciliation Outcomes

| Outcome | Meaning |
|---|---|
| Matched | All relevant records align |
| Matched With Correction | Difference corrected and recorded |
| Pending Evidence | Waiting for POS/payment/support evidence |
| Mismatch Open | Difference unresolved |
| Accepted Operational Difference | Manager accepted with note |
| Escalated | Requires finance/security/support review |

## 13. Mismatch Types

| Type | Meaning |
|---|---|
| ORDER_WITHOUT_POS | Catch & Order order not found in POS |
| POS_WITHOUT_ORDER | POS record not found in Catch & Order |
| PAYMENT_WITHOUT_ORDER | Payment record lacks matching order |
| ORDER_WITHOUT_PAYMENT | Order requires payment but no evidence |
| CANCEL_MISMATCH | Cancellation states differ |
| REFUND_MISMATCH | Refund states differ |
| KITCHEN_WITHOUT_POS | Kitchen acted without POS confirmation |
| POS_WITHOUT_KITCHEN | POS entry not handed to kitchen |
| STAFF_CORRECTION_MISMATCH | Correction not reflected across systems |

## 14. Escalation Rules

Escalate immediately when:

- payment exists but order cannot be matched
- customer paid but kitchen did not receive order
- order was fulfilled but payment is unknown
- refund/cancel state is ambiguous
- duplicate paid order exists
- staff manually corrected without evidence
- customer-facing status was wrong
- settlement total differs from POS/payment evidence

## 15. Customer-Facing Wording

Use safe wording:

| Internal State | Customer-Safe Wording |
|---|---|
| Order Intent Created | 주문 접수 중입니다 |
| Staff Reviewing | 매장에서 주문을 확인 중입니다 |
| POS Entry Pending | 매장 입력 확인 중입니다 |
| POS Entry Confirmed | 매장에서 주문을 확인했습니다 |
| Kitchen Handoff Pending | 주방 전달 준비 중입니다 |
| Kitchen Handoff Confirmed | 주방에 전달되었습니다 |
| Payment Pending | 결제 확인 중입니다 |
| Payment Unknown | 매장에서 결제 상태를 확인 중입니다 |
| Refund Requested | 환불 요청을 확인 중입니다 |
| Refund Confirmed | 환불 처리가 확인되었습니다 |

Avoid unsafe wording:

- paid
- completed
- refunded
- cancelled
- kitchen received
- POS accepted

unless supporting evidence exists.

## 16. Evidence Retention

Keep evidence for:

- order id
- POS reference
- payment reference
- cancellation/refund reference
- staff confirmation
- kitchen handoff
- correction note
- manager approval
- reconciliation outcome

## 17. First Store Policy Defaults

Until official provider/payment integration is approved:

| Capability | Default |
|---|---|
| Payment execution | POS/payment terminal only |
| Payment observation | manual evidence only |
| Order handoff | staff manual entry |
| KDS handoff | KDS/printer/manual note |
| Refund confirmation | POS/payment evidence |
| Settlement | daily reconciliation |
| Customer status | conservative wording |

## 18. Non-Goals

This policy does not define:

- payment gateway implementation
- PG/VAN contract
- provider-specific API mapping
- settlement accounting system
- tax/accounting treatment
- franchise-wide finance policy

It only defines first-store payment/order separation and reconciliation rules.

## 19. Related Documents

- 14290_SOP_First_Store_Manual_POS_Entry_And_Order_Confirmation.md
- 14300_SOP_First_Store_Manual_KDS_Kitchen_Note_And_Fulfillment_Handoff.md
- 14320_Checklist_First_Store_POS_KDS_Staff_Training_And_Fallback_Readiness.md
- 14330_Template_First_Store_Daily_Reconciliation_And_Manual_Correction_Log.md
- 14160_Register_POS_Provider_Incident_Reconciliation_And_Mismatch_Tracking.md
- 14070_Spec_POS_Provider_Adapter_Boundary_And_Evidence_Contract.md
- 20400_foundation_security
