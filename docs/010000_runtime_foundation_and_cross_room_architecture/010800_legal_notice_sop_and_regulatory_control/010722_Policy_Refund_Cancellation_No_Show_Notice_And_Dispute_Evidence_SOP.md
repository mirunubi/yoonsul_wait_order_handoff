# 010722_Policy_Refund_Cancellation_No_Show_Notice_And_Dispute_Evidence_SOP

## 1. Purpose

This document defines the Refund, Cancellation, No-Show, Deposit, Order Change, Sold-Out, Payment Error, Customer Mistake, Store Mistake, System Failure, Dispute Evidence, and Support Escalation SOP Policy for Catch Menu.

The previous document `10721 Alcohol Age Gate Legal Notice And Staff Verification SOP Policy` defined alcohol age-gate, adult confirmation, staff ID verification, alcohol blocking, alcohol evidence, and regulated alcohol order governance.

This document focuses on refund and cancellation risk because table order, app order, reservation deposit, pickup, delivery, fast track, and immediate-cooking food orders create frequent disputes.

This document defines how refund/cancellation notices must be shown, when acknowledgement is needed, how evidence must be captured, and how support must handle disputes.

This document is planning-only.

It does not provide legal advice.

It does not authorize coding.

---

## 2. Core Position

Refund and cancellation policy must follow actual order state.

The correct rule is:

Order requested is not kitchen accepted.  
Kitchen accepted is not payment captured.  
Payment authorized is not payment settled.  
Customer mistake is not always refundable.  
Store mistake is not customer fault.  
Sold-out is not customer cancellation.  
No-show deposit is not ordinary payment.  
Refund notice must appear before the irreversible point.  
Refund evidence must record the exact policy version shown.  
Support must judge based on order state, payment state, KDS state, notice evidence, and store policy version.  

A refund policy is unsafe if it is only text and not connected to order/payment/KDS state.

---

## 3. Scope

This policy applies to:

- table order
- app order
- mini kiosk order
- full kiosk order
- pickup order
- delivery order
- waiting order
- reservation order
- fast track order
- prepaid order
- postpaid order
- split payment
- deposit payment
- market-price order
- alcohol order
- coupon/point order
- sold-out cancellation
- kitchen accepted order
- customer mistake order
- store mistake order
- system failure order
- refund support case
- dispute evidence packet

This policy defines SOP governance only.

It is not a runtime implementation.

---

## 4. Refund And Cancellation State Registry

Recommended refund/cancellation states:

| State | Meaning |
|---|---|
| `CANCEL_AVAILABLE` | Customer can cancel |
| `CANCEL_REVIEW_REQUIRED` | Staff review required |
| `CANCEL_LOCKED_KITCHEN_SENT` | Kitchen has received order |
| `CANCEL_LOCKED_PREP_STARTED` | Preparation started |
| `CANCEL_LOCKED_COMPLETED` | Food completed |
| `CANCELLED_BY_CUSTOMER` | Customer cancelled |
| `CANCELLED_BY_STORE` | Store cancelled |
| `CANCELLED_BY_SOLD_OUT` | Sold-out cancellation |
| `CANCELLED_BY_SYSTEM_FAILURE` | System failure cancellation |
| `CANCELLED_BY_NO_SHOW` | No-show cancellation |
| `CANCELLED_BY_POLICY` | Policy-based cancellation |
| `REFUND_PENDING` | Refund pending |
| `REFUND_APPROVED` | Refund approved |
| `REFUND_REJECTED` | Refund rejected |
| `PARTIAL_REFUND_PENDING` | Partial refund pending |
| `PARTIAL_REFUND_APPROVED` | Partial refund approved |
| `REFUND_PROVIDER_PENDING` | PG/provider processing |
| `REFUND_COMPLETED` | Refund complete |
| `DISPUTE_OPEN` | Dispute opened |
| `DISPUTE_ESCALATED` | Escalated |
| `RECONCILIATION_REQUIRED` | Payment/order mismatch |

Unknown state must not be treated as refund approved.

---

## 5. Order State Inputs

Refund decision must consider:

| Input | Example |
|---|---|
| Order request state | Draft, submitted, accepted |
| KDS state | Not sent, sent, accepted, cooking, completed |
| Payment state | Not paid, authorized, captured, cancelled, refunded |
| POS state | Accepted, failed, unknown |
| Menu state | Available, sold out, market price |
| Customer action | Mistake, cancel request, no-show |
| Store action | Store cancellation, substitution |
| System action | Timeout, retry, duplicate |
| Delivery/pickup state | Not prepared, prepared, handed off |
| Reservation state | Before cutoff, after cutoff, no-show |
| Notice evidence | Refund notice shown/acknowledged |
| Policy version | Active policy at order time |

Refund rules must be state-based.

---

## 6. Cancellation Notice Timing

Cancellation notice must appear before irreversible action.

Recommended timing:

| Flow | Notice Surface |
|---|---|
| Immediate cooking table order | Cart / checkout before order send |
| Prepaid pickup | Checkout before payment |
| Reservation deposit | Reservation payment screen |
| Fast track order | Fast track confirmation |
| Alcohol order | Alcohol confirmation and checkout |
| Market-price order | Price confirmation screen |
| Delivery order | Checkout and delivery rule screen |
| Set/course order | Set confirmation |
| Coupon/point order | Cart before final apply |
| Split payment | Split payment confirmation |
| Postpaid table order | Order send confirmation |

Notice shown after the irreversible point is weak evidence.

---

## 7. Immediate Cooking Cancellation Boundary

Immediate cooking items require clear cancellation rule.

Recommended notice:

    Food preparation may begin immediately after order transmission. Once the kitchen accepts or starts preparation, cancellation due to simple change of mind may be restricted according to store policy.

System behavior must define:

| State | Recommended Handling |
|---|---|
| Before order submit | Customer can edit/cancel |
| Submitted but not KDS accepted | Cancel may be available |
| KDS accepted | Cancel locked or staff review |
| Prep started | Cancel locked except store mistake |
| Completed | Cancel locked |
| Store mistake | Refund/replacement review |
| Customer mistake | Store policy applies |
| System error | Support/reconciliation |

KDS state must be part of refund decision.

---

## 8. Customer Mistake Order Boundary

Customer mistake examples:

- wrong menu tapped
- wrong quantity selected
- wrong table selected
- wrong temperature selected
- wrong option selected
- duplicate item added
- coupon not applied before payment
- spicy level selected incorrectly
- alcohol item selected accidentally

Recommended handling:

| Situation | Handling |
|---|---|
| Before submit | Customer can edit |
| Immediately after submit before kitchen accept | Cancel/change may be allowed |
| After kitchen accept | Staff review |
| After prep start | Refund usually restricted |
| Store UI ambiguity | Support review |
| System duplicate caused by bug | System/store responsibility review |

Customer mistake must be judged with UI evidence and order state.

---

## 9. Store Mistake Boundary

Store mistake examples:

- wrong item served
- wrong option prepared
- missing item
- delayed beyond policy
- quality issue
- allergen exclusion ignored
- sold-out item accepted
- staff manual error
- menu price configured incorrectly by store
- customer request confirmed but not followed

Recommended handling:

| Situation | Handling |
|---|---|
| Wrong item before consumption | Replacement or refund review |
| Missing item | Fulfill or refund item |
| Allergen exclusion ignored | Escalate high-risk |
| Sold-out accepted | Refund/substitute with consent |
| Store delay | Compensation/recovery policy |
| Menu price error | Price correction policy and evidence |

Store mistake must not be hidden behind generic no-refund wording.

---

## 10. Sold-Out Cancellation Boundary

Sold-out cancellation is store/system cancellation.

Flow:

1. Customer orders item.
2. KDS/POS/store marks item sold out.
3. System checks payment state.
4. Customer receives sold-out notice.
5. Store may offer substitute.
6. If customer refuses or no substitute exists, refund is initiated.
7. Evidence records sold-out event and refund state.

Sold-out is not customer cancellation.

Refund should follow provider/payment state.

---

## 11. Substitution Boundary

Substitution requires customer consent.

Example:

    Salmon poke sold out. Store offers shrimp poke at same price.

Substitution evidence should capture:

| Field | Meaning |
|---|---|
| original_item | Sold-out item |
| substitute_item | Proposed item |
| price_difference | Difference |
| customer_choice | Accept/refuse |
| consent_time | Time |
| staff_actor | If staff-assisted |
| refund_if_refused | Refund action |
| audit_ref | Audit reference |

No silent substitution.

---

## 12. Reservation Deposit Boundary

Reservation deposit is not ordinary menu payment.

Deposit policy must define:

- reservation time
- cancellation cutoff
- refund tiers
- no-show condition
- grace period
- group size threshold
- deposit amount
- applied-to-bill behavior
- forfeiture reason
- store override authority
- customer notice version
- evidence retention

Deposit forfeiture requires stronger notice evidence.

---

## 13. No-Show Policy Boundary

No-show can occur in:

- waiting
- reservation
- pickup
- group booking
- fast track pickup
- deposit reservation
- table arrival after call
- delivery handoff failure

Recommended no-show states:

| State | Meaning |
|---|---|
| `NO_SHOW_WARNING_SENT` | Warning sent |
| `NO_SHOW_GRACE_RUNNING` | Grace period active |
| `NO_SHOW_CONFIRMED` | No-show confirmed |
| `NO_SHOW_CANCELLED_BY_STORE` | Store cancelled |
| `NO_SHOW_PENALTY_APPLIED` | Penalty applied |
| `NO_SHOW_DISPUTE_OPEN` | Customer disputes |
| `NO_SHOW_RECOVERY_GRANTED` | Store grants recovery |
| `NO_SHOW_REVERSED` | Penalty reversed |

No-show penalty requires timestamp evidence.

---

## 14. Waiting No-Show Flow

Waiting no-show flow:

1. Customer joins waitlist.
2. Waiting notice and call expiry rule are shown.
3. Customer is called.
4. Grace timer starts.
5. Customer fails to arrive within configured time.
6. Waiting entry is auto-cancelled.
7. Evidence records call time, notice, grace period, cancellation.
8. Customer may rejoin according to policy.

Waiting no-show usually should not involve payment unless deposit exists.

---

## 15. Pickup No-Show Flow

Pickup no-show flow:

1. Customer places pickup order.
2. Pickup time and freshness notice are shown.
3. Store prepares item.
4. Customer does not arrive.
5. Store may hold for configured time.
6. After hold time, food may be discarded.
7. Refund eligibility follows policy and food state.
8. Evidence records ready time, notification, hold period, disposal if any.

Fresh food pickup no-show is high dispute risk.

---

## 16. Group Reservation No-Show Flow

Group reservation flow:

1. Customer reserves group table.
2. Deposit/no-show policy is shown.
3. Customer pays deposit if required.
4. Cancellation cutoff applies.
5. Store prepares seats/materials/ingredients.
6. Customer arrives late or not at all.
7. Grace period runs.
8. No-show penalty or deposit forfeiture may apply.
9. Evidence packet records all timestamps.

Group reservation policy must be visible before deposit payment.

---

## 17. Market Price Refund Boundary

Market-price item requires price confirmation.

Flow:

1. Menu shows market price.
2. Customer requests item.
3. Store confirms current price.
4. Customer accepts confirmed price.
5. Payment/order proceeds.
6. Refund/cancel follows confirmed price evidence.

If price was not confirmed, dispute risk is high.

Market price must not be charged silently.

---

## 18. Price Typo Correction Boundary

Price typo example:

    20,000 item displayed as 2,000.

Correction flow:

1. Store/system detects price typo.
2. Order is paused if possible.
3. Customer receives correction notice.
4. Customer may accept corrected price or cancel.
5. If payment occurred, cancel/refund/recharge path is governed.
6. Evidence records original display, correction notice, customer response.

Price correction must not be silent.

---

## 19. Payment Error Refund Boundary

Payment error cases:

| Case | Handling |
|---|---|
| Duplicate payment | Verify provider records and refund duplicate |
| Authorized but order failed | Cancel authorization or refund |
| Order accepted but payment failed | Ask customer for payment or cancel |
| PG/VAN pending | Wait/reconcile before duplicate charge |
| Split payment mismatch | Lock final order until balanced |
| Refund provider delay | Show provider delay notice |
| Partial refund needed | Item-level refund review |
| Unknown provider state | Reconciliation required |

Payment state must be source-of-truth through provider evidence.

---

## 20. Split Payment Boundary

Split payment disputes may occur when:

- one participant fails to pay
- total split amount mismatch
- table leaves before payment complete
- partial refund needed
- coupon applied unevenly
- item ownership unclear

Required evidence:

- table order total
- participant payments
- unpaid balance
- split rule
- payment state
- refund allocation
- notice shown
- audit

Split payment must not mark order settled until fully reconciled.

---

## 21. Coupon Point Refund Boundary

Refund involving benefits must define:

| Benefit | Refund Handling |
|---|---|
| Coupon | Restore or expire according policy |
| Point used | Return points or not according policy |
| Point earned | Cancel earned points if refund |
| Gift item | Return/charge/recover rule |
| 1+1 promotion | Reverse both paid/free component if needed |
| Store event | Store-specific policy |
| Franchise coupon | Franchise/HQ policy |

Benefit reversal must be auditable.

---

## 22. Alcohol Refund Boundary

Alcohol refund must consider:

- adult verification failed
- ID check refused
- alcohol delivery blocked
- alcohol set cannot split
- alcohol component can be removed
- payment already captured
- staff mistake
- customer mistake
- legal policy

Alcohol refund should reference `10721`.

Alcohol item must not proceed if verification fails.

---

## 23. Refund Evidence Packet

Refund dispute evidence should include:

| Field | Meaning |
|---|---|
| `case_id` | Support/dispute case |
| `tenant_id` | Tenant |
| `store_id` | Store |
| `order_id` | Order |
| `payment_id` | Payment |
| `customer_id` | Customer if known |
| `session_id` | Session |
| `order_state` | State at dispute |
| `kds_state` | Kitchen state |
| `payment_state` | Payment/provider state |
| `refund_state` | Refund state |
| `notice_id` | Refund/no-show notice |
| `notice_version_id` | Exact notice version |
| `notice_shown_at` | When shown |
| `acknowledged_at` | When acknowledged |
| `customer_request_time` | Cancel/refund request time |
| `store_action_time` | Store action time |
| `reason_code` | Reason |
| `decision` | Approved/rejected/partial |
| `decision_actor` | Staff/support/HQ |
| `audit_ref` | Audit reference |

Evidence must reconstruct the decision.

---

## 24. Reason Code Registry

Recommended refund/cancel reason codes:

| Code | Meaning |
|---|---|
| `CUSTOMER_CHANGED_MIND` | Simple change of mind |
| `CUSTOMER_ORDER_MISTAKE` | Customer selected wrong item |
| `DUPLICATE_ORDER` | Duplicate order |
| `STORE_SOLD_OUT` | Store sold out |
| `STORE_WRONG_ITEM` | Wrong item prepared |
| `STORE_MISSING_ITEM` | Missing item |
| `STORE_QUALITY_ISSUE` | Quality issue |
| `ALLERGEN_REQUEST_FAILED` | Allergen/exclusion request failed |
| `PAYMENT_DUPLICATE` | Duplicate payment |
| `PAYMENT_PROVIDER_ERROR` | Provider error |
| `POS_ORDER_MISMATCH` | POS/order mismatch |
| `KDS_DELAY` | Kitchen delay |
| `NO_SHOW_WAITING` | Waiting no-show |
| `NO_SHOW_RESERVATION` | Reservation no-show |
| `NO_SHOW_PICKUP` | Pickup no-show |
| `ALCOHOL_ID_FAIL` | Alcohol ID failed |
| `DELIVERY_FAILURE` | Delivery failure |
| `FORCE_MAJEURE` | Disaster/force majeure |
| `PRICE_TYPO` | Price typo |
| `MARKET_PRICE_DISPUTE` | Market price dispute |
| `MANUAL_COMPENSATION` | Manual customer recovery |

Reason codes must be controlled.

---

## 25. Decision Authority Matrix

Refund decisions require authority.

| Decision | Authority |
|---|---|
| Customer cancel before submit | Customer |
| Cancel before KDS accept | System/store policy |
| Cancel after KDS accept | Staff/manager |
| Refund store mistake | Manager/store owner |
| Refund system failure | Support/HQ |
| Refund payment duplicate | Payment support |
| No-show deposit forfeiture | Store policy + evidence |
| Reverse no-show penalty | Manager/HQ |
| Alcohol ID failure refund | Staff/manager + policy |
| Manual compensation | Manager/HQ depending amount |
| Large refund | Owner/HQ |
| Legal dispute refund | Legal/HQ |

AI cannot approve refund.

---

## 26. Support Dispute Flow

Support dispute flow:

1. Customer opens dispute.
2. Support retrieves order state.
3. Support retrieves KDS state.
4. Support retrieves payment state.
5. Support retrieves notice evidence.
6. Support retrieves store policy version.
7. Support identifies reason code.
8. Support checks authority matrix.
9. Support approves, rejects, partially refunds, or escalates.
10. Decision is audited.
11. Customer is notified.

Support decision must be evidence-based.

---

## 27. Store Manager Flow

Store manager flow:

1. Refund/cancel request arrives.
2. Manager views order state.
3. Manager views kitchen state.
4. Manager views payment state.
5. Manager chooses reason code.
6. Manager selects action:
   - approve cancel
   - reject cancel
   - partial refund
   - replacement
   - substitute
   - compensation
   - escalate
7. System records decision.
8. Customer receives notice.

Manager authority may be amount-limited.

---

## 28. Customer UX Requirements

Customer screen should clearly show:

- cancellation availability
- irreversible order point
- expected prep status
- refund eligibility
- deposit/no-show rule
- pickup hold time
- sold-out refund behavior
- payment refund processing delay
- coupon/point reversal rule
- support contact route
- dispute status

Customer should not need to guess refund status.

---

## 29. Admin Configuration Requirements

Admin refund settings should include:

| Setting | Meaning |
|---|---|
| Immediate cooking cancel policy | When cancel locks |
| KDS acceptance cancel rule | State-based behavior |
| Prep start cancel rule | State-based behavior |
| Pickup hold time | Hold before no-show |
| Waiting grace time | Grace before cancellation |
| Reservation cancellation tiers | Deposit refund tiers |
| Group reservation deposit | Required amount/rule |
| Sold-out substitution policy | Offer substitute or auto refund |
| Customer mistake policy | Store policy |
| Payment error support route | Support or store |
| Manual compensation limit | Manager authority |
| Coupon reversal policy | Benefit handling |
| Alcohol verification failure policy | Refund/remove/cancel |
| Force majeure policy | Refund/cancel behavior |

Admin settings must be versioned and auditable.

---

## 30. Notification Requirements

Refund/cancel notifications may include:

- cancel request received
- cancel approved
- cancel rejected
- partial refund approved
- sold-out cancellation
- substitution proposal
- refund provider pending
- refund completed
- no-show warning
- no-show confirmed
- deposit forfeited
- dispute opened
- dispute decision
- support escalation

Notifications must use i18n keys and policy version references where needed.

---

## 31. Reconciliation Boundary

Refund/cancel flow must reconcile:

- order ledger
- payment provider
- POS
- KDS
- coupon/points
- settlement
- receipt
- support case

If any state conflicts, mark:

    RECONCILIATION_REQUIRED

Do not silently mark refund complete without provider confirmation.

---

## 32. Receipt Boundary

Receipts should reflect:

- original order
- cancellation if any
- refund if any
- partial refund if any
- coupon/point reversal
- VAT/tax impact
- PG cancellation reference
- no-show deposit status
- final paid amount
- final settlement amount

Receipt must not lie about payment state.

---

## 33. Audit Event Catalog

Recommended events:

| Event Type | Meaning |
|---|---|
| `REFUND_NOTICE_SHOWN` | Refund notice shown |
| `REFUND_NOTICE_ACKNOWLEDGED` | Refund notice confirmed |
| `ORDER_CANCEL_REQUESTED` | Cancel requested |
| `ORDER_CANCEL_APPROVED` | Cancel approved |
| `ORDER_CANCEL_REJECTED` | Cancel rejected |
| `ORDER_CANCEL_LOCKED_BY_KDS` | KDS state locked cancel |
| `ORDER_CANCELLED_BY_SOLD_OUT` | Sold-out cancellation |
| `SUBSTITUTE_OFFERED` | Substitute offered |
| `SUBSTITUTE_ACCEPTED` | Substitute accepted |
| `SUBSTITUTE_REJECTED` | Substitute rejected |
| `REFUND_REQUESTED` | Refund requested |
| `REFUND_APPROVED` | Refund approved |
| `REFUND_REJECTED` | Refund rejected |
| `PARTIAL_REFUND_APPROVED` | Partial refund approved |
| `REFUND_PROVIDER_PENDING` | Provider pending |
| `REFUND_COMPLETED` | Refund complete |
| `NO_SHOW_WARNING_SENT` | No-show warning sent |
| `NO_SHOW_CONFIRMED` | No-show confirmed |
| `NO_SHOW_PENALTY_APPLIED` | Penalty applied |
| `DEPOSIT_FORFEITED` | Deposit forfeited |
| `PAYMENT_RECONCILIATION_REQUIRED` | Reconciliation needed |
| `REFUND_DISPUTE_OPENED` | Dispute opened |
| `REFUND_DISPUTE_ESCALATED` | Dispute escalated |
| `REFUND_DECISION_RECORDED` | Decision recorded |

Events must route through `10610`.

---

## 34. Security Boundary

Refund and no-show evidence is financial/compliance-sensitive.

Rules:

- support access must be case-scoped
- refund approval requires authority
- large refunds require reauthentication
- manual compensation requires audit
- payment provider IDs must be protected
- customer personal data must be masked where possible
- refund decision cannot be overwritten silently
- old policy versions must remain readable
- tenant/store scope mandatory
- export requires authority and audit

Refund evidence must be protected like financial records.

---

## 35. Anti-Patterns

Avoid:

- using one generic no-refund text for every state
- showing cancellation restriction only after payment
- ignoring KDS state in refund decision
- refunding without payment provider confirmation
- treating sold-out as customer cancellation
- silently substituting menu without consent
- treating market price as zero-price
- forfeiting deposit without notice evidence
- applying no-show penalty without timestamp evidence
- letting AI approve refund
- allowing support to edit refund evidence
- hiding refund state from customer
- failing to reverse coupon/points during refund
- marking refund complete while provider state is pending
- changing historical refund policy text

These anti-patterns must be blocked in future runtime design.

---

## 36. Runtime Deferral

This document defines refund, cancellation, no-show, deposit, payment error, substitution, dispute evidence, and support SOP governance only.

It does not authorize:

- refund runtime implementation
- cancellation engine implementation
- no-show automation
- deposit payment implementation
- payment provider refund integration
- coupon reversal implementation
- support console implementation
- KDS/POS state integration
- database schema
- RLS/security rules
- production deployment

All runtime remains deferred.

---

## 37. Validation Checklist

Validation must confirm:

1. Refund and cancellation state registry is defined.
2. Order state inputs are defined.
3. Cancellation notice timing is defined.
4. Immediate cooking cancellation boundary is defined.
5. Customer mistake order boundary is defined.
6. Store mistake boundary is defined.
7. Sold-out cancellation boundary is defined.
8. Substitution boundary is defined.
9. Reservation deposit boundary is defined.
10. No-show policy boundary is defined.
11. Waiting no-show flow is defined.
12. Pickup no-show flow is defined.
13. Group reservation no-show flow is defined.
14. Market price refund boundary is defined.
15. Price typo correction boundary is defined.
16. Payment error refund boundary is defined.
17. Split payment boundary is defined.
18. Coupon/point refund boundary is defined.
19. Alcohol refund boundary is defined.
20. Refund evidence packet is defined.
21. Reason code registry is defined.
22. Decision authority matrix is defined.
23. Support dispute flow is defined.
24. Store manager flow is defined.
25. Customer UX requirements are defined.
26. Admin configuration requirements are defined.
27. Notification requirements are defined.
28. Reconciliation boundary is defined.
29. Receipt boundary is defined.
30. Audit event catalog is defined.
31. Security boundary is defined.
32. Anti-patterns are listed.
33. Coding remains unauthorized.
34. Runtime remains deferred.

---

## 38. Relationship To Previous Documents

This document supplements:

- `10716 Legal Notice Master Toggle Disclosure Consent And Compliance Governance Policy`
- `10717 Legal Notice Master Data Usage Flow And Runtime Retrieval Governance Policy`
- `10718 Legal Notice Master Data Table Static Specification Policy`
- `10719 Legal Notice Trigger Matrix And UI Surface Mapping Policy`
- `10720 Privacy Consent Evidence Packet And Retention Policy`
- `10721 Alcohol Age Gate Legal Notice And Staff Verification SOP Policy`

It also references:

- `10410 Payment Intent And Authorization Boundary Policy`
- `10420 Payment Confirmation And Provider Callback Boundary Policy`
- `10430 Refund Cancellation And Void Boundary Policy`
- `10440 Coupon Point Wallet And Stored Value Boundary Policy`
- `10450 Settlement Allocation And Reconciliation Boundary Policy`
- `10610 Cross-Room Event Bus And Evidence Packet Routing Policy`
- `10620 Command Query Projection Separation Policy`
- `10630 Authority Capability Gate Policy`
- `10640 Tenant Scope Envelope Policy`
- `10680 Audit Correlation Nightly Batch Policy`
- `10701 Five-Minute Smart Order Fast Track KDS Throttling No-Show Penalty And Abuse Control Boundary Policy`
- `10715 AI Menu Review Option Builder Set Combo Course And Special Sales Pattern Governance Policy`

It prepares possible future documents:

- `10723 Legal Notice i18n Review And Controlled Translation Policy`
- `10724 Legal Notice Admin Toggle Permission And HQ Lock Policy`
- `10725 Refund Payment Provider Reconciliation And Evidence Packet Policy`
- `10726 No-Show Deposit Penalty And Customer Recovery SOP Policy`

This document is architecture boundary planning only.

It does not authorize coding.

---

## 39. Final Rule

Catch Menu refund, cancellation, and no-show policy must be state-based, evidence-backed, and aligned with POS, KDS, payment provider, coupon, point, reservation, and support workflows.

Refund notices must be shown before irreversible order or payment points.

No-show penalties and deposit forfeiture require clear notice, timing evidence, and policy version evidence.

Sold-out, store mistake, customer mistake, payment error, market price dispute, alcohol verification failure, and force majeure must be handled as separate reason-coded flows.

AI may classify risk and recommend policy routes.

AI cannot approve refunds, deny refunds, apply penalties, or mutate evidence.

Historical notice and refund evidence must never be rewritten.

Runtime implementation remains deferred until a separate explicit authorization packet is approved.