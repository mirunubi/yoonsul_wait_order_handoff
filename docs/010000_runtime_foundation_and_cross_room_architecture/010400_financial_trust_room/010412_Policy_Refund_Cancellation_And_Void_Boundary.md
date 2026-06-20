# 010412_Policy_Refund_Cancellation_And_Void_Boundary.md

## Purpose

This document defines the Refund, Cancellation, and Void Boundary Policy.

The previous artifact `10420` defined the Payment Confirmation and Provider Callback Boundary Policy.

This document frames the third Financial Trust room:

`Refund Cancellation And Void Room`

The purpose is to define the boundary where payment reversal, order cancellation, authorization void, capture reversal, partial refund, full refund, failed refund, duplicate refund prevention, customer-safe refund communication, financial evidence, audit, and reconciliation are governed separately from Store Runtime, incident review, recovery review, staff assist, POS/KDS state, kitchen state, and customer complaint handling.

This document is planning-only.

It does not authorize coding.

---

## 2. Room Definition

The Refund, Cancellation, and Void Room governs financial reversal and non-capture pathways.

It may later coordinate:

- cancellation candidate
- void candidate
- refund candidate
- refund review
- refund approval
- refund execution
- partial refund
- full refund
- refund failure
- duplicate refund risk
- delayed provider refund callback
- refund reconciliation
- customer-safe refund projection
- financial evidence packet
- audit reference

Refund review is not refund approval.

Refund approval is not refund execution.

Refund execution requires verified provider and ledger evidence.

---

## 3. Core Principle

Value reversal must be explicit, authorized, verified, and reconcilable.

The correct rule is:

Customer complaint is not refund approval.  
Incident is not refund approval.  
Recovery review is not refund execution.  
Staff note is not refund authority.  
KDS delay is not automatic refund.  
Wrong item is not automatic refund.  
Payment failure is not refund unless value was captured.  
Authorization void is not refund.  
Refund requested is not refund completed.  
Refund provider callback is not verified truth by itself.  

Refund, cancellation, and void actions must be tenant-scoped, store-scoped, authority-controlled, idempotent, evidence-bound, audited, and safely projected.

---

## 4. Scope

The Refund, Cancellation, and Void Room may define planning boundaries for:

- order cancellation candidate
- payment cancellation candidate
- authorization void candidate
- refund candidate
- refund review
- refund approval
- refund execution
- partial refund
- full refund
- refund failure
- refund timeout
- duplicate refund prevention
- provider reversal event verification
- refund evidence packet
- customer-safe projection
- reconciliation routing
- tenant/store isolation

This room does not implement refund runtime.

---

## 5. Reversal Type Catalog

Recommended reversal type catalog:

| Type | Meaning |
|---|---|
| `ORDER_CANCELLATION` | Cancel order workflow before or after payment context depending on policy |
| `PAYMENT_CANCELLATION` | Cancel payment attempt before confirmed capture if provider supports it |
| `AUTHORIZATION_VOID` | Void authorization before capture |
| `FULL_REFUND` | Refund full captured amount |
| `PARTIAL_REFUND` | Refund partial captured amount |
| `REFUND_REVERSAL_REVIEW` | Review exceptional reversal correction |
| `DUPLICATE_PAYMENT_REFUND_REVIEW` | Review duplicate payment reversal |
| `CUSTOMER_RECOVERY_REFUND_REVIEW` | Refund review from recovery route |
| `MANUAL_REFUND_REVIEW` | Refund review from manual/fallback evidence |
| `PROVIDER_REFUND_RECONCILIATION` | Reconcile provider refund event |

Reversal type determines required authority and evidence.

---

## 6. Refund Input Boundary

Refund/cancellation/void input may include:

| Input | Meaning |
|---|---|
| `tenant_id` | Tenant context |
| `store_id` | Store context if applicable |
| `order_reference` | Related order reference |
| `payment_intent_id` | Payment intent reference |
| `payment_confirmation_id` | Payment confirmation reference |
| `provider_transaction_id` | Provider transaction reference |
| `recovery_reference` | Recovery route reference if applicable |
| `incident_reference` | Incident reference if applicable |
| `evidence_reference` | Evidence packet reference |
| `requested_reversal_type` | Cancellation/void/refund type |
| `requested_amount` | Requested refund amount if applicable |
| `currency` | Currency |
| `reason_category` | Safe reason category |
| `requesting_actor_id` | Requesting actor |
| `authority_reference` | Authority reference if approval exists |
| `idempotency_key` | Duplicate prevention key |

Input must be tenant/store scoped and evidence-linked.

---

## 7. Refund Output Boundary

Refund/cancellation/void output may include:

| Output | Meaning |
|---|---|
| `reversal_id` | Reversal reference |
| `reversal_status` | Reversal state |
| `approved_amount` | Approved amount if applicable |
| `executed_amount` | Executed amount if applicable |
| `provider_reversal_reference` | Provider reversal reference |
| `approval_reference` | Approval reference |
| `execution_reference` | Execution reference |
| `duplicate_risk_marker` | Duplicate risk marker |
| `provider_callback_marker` | Provider callback marker |
| `reconciliation_required` | Whether reconciliation is required |
| `customer_notification_key` | Customer-safe message key |
| `evidence_reference` | Financial evidence reference |
| `audit_placeholder` | Future audit reference |

Output must not claim completed refund unless verified.

---

## 8. Refund Cancellation Void State Skeleton

Recommended states:

| State | Meaning |
|---|---|
| `REVERSAL_NOT_REQUESTED` | No reversal requested |
| `REVERSAL_CANDIDATE` | Candidate detected |
| `REVERSAL_REVIEW_REQUIRED` | Review required |
| `REVERSAL_IN_REVIEW` | Review in progress |
| `REVERSAL_EVIDENCE_REQUIRED` | More evidence required |
| `REVERSAL_APPROVAL_REQUIRED` | Approval required |
| `REVERSAL_APPROVED` | Approved by authority |
| `REVERSAL_REJECTED` | Rejected after review |
| `REVERSAL_EXECUTION_READY` | Ready for execution |
| `REVERSAL_EXECUTION_REQUESTED` | Provider/ledger execution requested |
| `REVERSAL_PROVIDER_PENDING` | Provider pending |
| `REVERSAL_EXECUTED_VERIFIED` | Execution verified |
| `REVERSAL_FAILED_VERIFIED` | Failure verified |
| `REVERSAL_TIMEOUT` | Timeout occurred |
| `REVERSAL_DUPLICATE_RISK` | Duplicate risk detected |
| `REVERSAL_RECONCILIATION_REQUIRED` | Reconciliation required |
| `REVERSAL_CLOSED` | Closed after review |
| `REVERSAL_UNKNOWN` | State uncertain |

These states are skeleton states only.

They do not authorize runtime.

---

## 9. Tenant And Store Isolation Boundary

Every refund, cancellation, void, or reversal record must be tenant/store scoped.

A Store A refund candidate must never appear in Store B financial queue.

A Tenant A refund record must never appear in Tenant B visibility.

Reversal processing must fail closed when:

- tenant context is missing
- store context is missing where required
- payment reference scope does not match
- order reference scope does not match
- provider transaction scope does not match
- recovery/incident reference scope does not match
- authority reference is missing
- evidence reference is missing
- idempotency key is missing
- cross-tenant/store anomaly is detected

Default:

`CROSS_TENANT_ACCESS_DENIED`

Refund/Cancellation/Void Room must follow `10141`.

---

## 10. Cancellation Boundary

Cancellation may apply to order or payment attempt depending on timing.

Cancellation must distinguish:

- order cancellation before payment
- order cancellation after payment intent
- order cancellation after authorization
- order cancellation after capture
- order cancellation after kitchen start
- order cancellation after fulfillment
- payment cancellation before provider confirmation
- cancellation blocked by policy

Order cancellation is not refund by itself.

Payment cancellation is not refund by itself.

Cancellation must not silently mutate payment truth.

---

## 11. Authorization Void Boundary

Authorization void applies when authorization exists but capture has not occurred or provider policy allows void.

Void must verify:

- authorization exists
- capture has not occurred or void is provider-supported
- amount/currency scope
- provider transaction reference
- tenant/store scope
- idempotency key
- approval authority if required
- provider response
- evidence packet

Authorization void is not refund.

Void completion requires provider verification.

---

## 12. Refund Candidate Boundary

Refund candidate may be created from:

- customer recovery route
- incident review
- duplicate payment risk
- wrong item
- order cancellation after payment
- payment capture mismatch
- provider reconciliation mismatch
- manual fallback confusion
- support/admin review
- legal/compliance review

Refund candidate is not refund approval.

Refund candidate must require review and authority.

---

## 13. Refund Approval Boundary

Refund approval requires explicit authority.

Approval must consider:

- verified payment capture
- refund eligibility
- amount
- currency
- reason category
- customer impact evidence
- incident/recovery evidence
- provider capability
- prior refund history
- duplicate refund risk
- policy limit
- audit requirement

Staff assist does not grant refund approval.

Manager review may not be enough unless authority policy allows it.

---

## 14. Refund Execution Boundary

Refund execution may be attempted only when:

- refund approved
- captured payment verified
- provider profile verified
- refund amount approved
- idempotency key exists
- duplicate refund risk controlled
- no containment block exists
- evidence packet exists
- audit route exists
- customer-safe projection prepared

This document does not authorize execution implementation.

It only defines the future gate.

---

## 15. Partial Refund Boundary

Partial refund must verify:

- original captured amount
- prior refunded amount
- remaining refundable amount
- requested partial amount
- approved partial amount
- currency
- reason category
- item/order relation if applicable
- provider support
- customer-safe message

Partial refund must not exceed remaining refundable amount.

Partial refund must not silently alter item/order truth.

---

## 16. Full Refund Boundary

Full refund must verify:

- captured payment exists
- no prior full refund exists
- partial refunds already applied if any
- refundable balance
- provider support
- approval authority
- customer impact evidence
- refund reason
- idempotency

Full refund does not automatically cancel operational records.

Operational state and financial reversal remain separate.

---

## 17. Duplicate Refund Prevention Boundary

Duplicate refund prevention is mandatory.

Duplicate risk may arise from:

- customer repeated complaint
- staff repeated request
- provider timeout
- delayed provider callback
- support/admin retry
- webhook replay
- incident reopened
- recovery reopened
- manual fallback reconciliation

Duplicate refund must be blocked unless explicitly reviewed.

Refund retry requires idempotency and prior state review.

---

## 18. Refund Timeout Boundary

Refund timeout is uncertain.

Timeout must not be treated as executed.

Timeout must not be treated as failed if provider may later complete.

Timeout must trigger:

- duplicate refund prevention
- provider callback wait
- status check if later authorized
- reconciliation requirement
- safe customer message
- incident if customer impacted
- support/admin review if needed

Refund timeout is not safe success.

Refund timeout is not safe failure.

---

## 19. Refund Failure Boundary

Refund failure may occur because of:

- provider rejection
- expired refund window
- amount mismatch
- duplicate request
- insufficient captured balance
- provider unavailable
- merchant/store mismatch
- policy block
- unknown provider error

Refund failure must be verified.

Raw provider failure must not be exposed to customer by default.

Failure may require manual financial review.

---

## 20. Provider Reversal Callback Boundary

Provider reversal callback must be verified before use.

Verification should consider:

- provider id
- provider profile
- reversal id
- payment reference
- provider transaction reference
- amount/currency
- tenant/store scope
- idempotency key
- event type
- event timestamp
- duplicate event status
- signature/reference verification if applicable

Provider callback is not verified truth by itself.

Unmatched reversal callback must be quarantined.

---

## 21. Customer-Safe Refund Projection Boundary

Customer-safe projection may show:

- cancellation is under review
- refund is under review
- refund has been approved if approval is verified and message policy allows
- refund is being processed
- refund has been completed if execution is verified
- refund could not be completed if verified
- staff/support is reviewing
- payment status is being checked

Customer-safe projection must not show:

- raw provider error
- raw payment payload
- internal fraud/risk signal
- security containment detail
- settlement detail
- legal conclusion
- unapproved compensation promise
- cross-tenant/store information
- AI reasoning
- vector similarity

Refund messages must be i18n-controlled.

---

## 22. Staff/Admin Visibility Boundary

Staff/Admin visibility may include:

- reversal type
- refund candidate status
- approval status
- execution status
- safe provider category
- duplicate risk marker
- reconciliation marker
- evidence reference
- incident/recovery reference
- customer communication status

Staff/Admin visibility must not expose:

- raw payment credentials
- unrestricted provider payload
- fraud/risk detail without authority
- unrelated tenant/store data
- unmasked customer data without authority

Visibility is not refund execution authority.

---

## 23. Refund Evidence Boundary

Refund/reversal evidence may include:

- tenant id
- store id
- reversal id
- payment intent id
- payment confirmation id
- provider transaction reference
- reversal type
- reason category
- requested amount
- approved amount
- executed amount
- approval actor
- execution actor/system
- provider reversal reference
- idempotency key
- timeout/failure marker
- duplicate risk marker
- reconciliation marker
- customer notification key
- audit reference

Refund evidence is high-risk.

It must be masked and access-controlled.

---

## 24. Relationship To Payment Confirmation Room

Refund, cancellation, and void must depend on verified payment state.

Unknown payment state should not produce automatic refund.

Captured payment may allow refund candidate.

Authorization without capture may allow void candidate.

Payment confirmation remains separate from reversal execution.

---

## 25. Relationship To Coupon Point Wallet Stored Value Room

Refund may interact with coupon, point, wallet, or stored value when:

- coupon was used
- points were redeemed
- wallet balance was used
- stored value was used
- loyalty accrual must be reversed
- recovery value was applied

Refund Room must not mutate value instruments directly unless policy delegates through the value ledger boundary.

Value ledger consistency is required.

---

## 26. Relationship To Settlement Reconciliation Room

Refunds may affect settlement.

Refund execution may later feed:

- provider settlement adjustment
- store allocation adjustment
- legal entity allocation adjustment
- fee adjustment
- payout reconciliation
- amendment/correction

Settlement Room owns settlement truth.

Refund execution is not settlement completion.

---

## 27. Relationship To Compensation Recovery Value Room

Recovery Route may create refund candidate.

Compensation Room may approve value action depending on authority.

Refund Room executes refund only when refund-specific authority and payment evidence are satisfied.

Recovery review is not refund execution.

---

## 28. Relationship To Store Runtime

Store Runtime may display safe refund/cancellation status.

Store Runtime must not:

- approve refund
- execute refund
- infer refund from incident
- infer refund from staff note
- infer refund from KDS delay
- infer refund from wrong item
- mutate financial state

Store Runtime consumes safe projection only.

---

## 29. Relationship To Data Governance

Refund/Cancellation/Void Room uses Side D for:

- i18n refund messages
- masking policy
- support/admin visibility
- evidence classification
- retention policy
- export restriction
- legal/compliance review categories
- AI summary restriction if later authorized
- pgvector source restriction if later authorized

Data Governance supports safe visibility.

Financial Trust owns reversal truth.

---

## 30. Refund Cancellation Void Anti-Patterns

Avoid:

- customer complaint treated as refund approval
- incident treated as refund execution
- recovery review treated as compensation execution
- staff note treated as refund authority
- KDS delay treated as automatic refund
- wrong item treated as automatic refund
- authorization void treated as refund
- refund requested treated as refund completed
- refund timeout treated as success
- refund failure shown without verification
- duplicate refund from retry
- provider reversal callback treated as verified truth
- raw provider error shown to customer
- Store Runtime mutating refund state
- AI deciding refund approval
- pgvector similarity treated as refund proof

These anti-patterns must be blocked in future runtime design.

---

## 31. Runtime Deferral

This document defines the Refund, Cancellation, and Void Room boundary only.

It does not authorize:

- refund API
- void API
- cancellation API
- provider reversal integration
- refund approval workflow
- refund execution workflow
- financial ledger mutation
- coupon/point/wallet mutation
- settlement adjustment engine
- database schema
- AI runtime
- pgvector runtime
- production deployment

All runtime remains deferred.

---

## 32. Validation Checklist

Validation must confirm:

1. Refund, Cancellation, and Void Room definition is clear.
2. Value reversal requires explicit authority and verification.
3. Reversal type catalog is defined.
4. Input boundary is defined.
5. Output boundary is defined.
6. State skeleton is defined.
7. Tenant/store isolation is defined.
8. Cancellation boundary is defined.
9. Authorization void boundary is defined.
10. Refund candidate boundary is defined.
11. Refund approval boundary is defined.
12. Refund execution boundary is defined.
13. Partial refund boundary is defined.
14. Full refund boundary is defined.
15. Duplicate refund prevention boundary is defined.
16. Refund timeout boundary is defined.
17. Refund failure boundary is defined.
18. Provider reversal callback boundary is defined.
19. Customer-safe projection boundary is defined.
20. Staff/Admin visibility boundary is defined.
21. Refund evidence boundary is defined.
22. Relationships to Financial Trust rooms are defined.
23. Relationship to Store Runtime is defined.
24. Relationship to Data Governance is defined.
25. Anti-patterns are listed.
26. Coding remains unauthorized.
27. Runtime remains deferred.

---

## 33. Relationship To Previous Documents

This document follows:

- `10420 Payment Confirmation And Provider Callback Boundary Policy`

It references:

- `10141 SaaS Tenant Isolation And Cross-Tenant Data Containment Beam Policy`
- `10340 Store Recovery Route Room Boundary Policy`
- `10350 Store Runtime Room Framing Closure And Next Axis Handoff Policy`
- `10400 Financial Trust Room Framing And Domain Boundary Index`
- `10410 Payment Intent And Authorization Boundary Policy`
- `10420 Payment Confirmation And Provider Callback Boundary Policy`

It prepares:

- `10440 Coupon Point Wallet And Stored Value Boundary Policy`
- `10450 Settlement Allocation And Reconciliation Boundary Policy`
- `10460 Compensation And Customer Recovery Value Boundary Policy`

This document is room boundary planning only.

It does not authorize coding.

---

## 34. Final Rule

The Refund, Cancellation, and Void Room governs controlled value reversal and non-capture pathways.

Customer complaint is not refund approval.

Incident is not refund execution.

Recovery review is not compensation execution.

Staff note is not refund authority.

KDS delay is not automatic refund.

Authorization void is not refund.

Refund requested is not refund completed.

Provider reversal callback is not verified truth by itself.

Refund, cancellation, and void actions must preserve tenant/store isolation, authority control, payment verification, provider verification, idempotency, duplicate prevention, evidence, audit, reconciliation, masking, i18n, Safe Projection, Store Runtime separation, and settlement/value ledger separation.

Runtime implementation remains deferred until a separate explicit authorization packet is approved.
