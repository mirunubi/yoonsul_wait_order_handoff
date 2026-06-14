# 10410_Payment_Intent_And_Authorization_Boundary_Policy

## 1. Purpose

This document defines the Payment Intent and Authorization Boundary Policy.

The previous artifact `10400` defined the Financial Trust Room Framing and Domain Boundary Index.

This document frames the first Financial Trust room:

`Payment Intent And Authorization Room`

The purpose is to define the boundary where a customer, staff, kiosk, POS-connected flow, order candidate, or recovery-related flow may create a payment intent or authorization candidate without treating that candidate as payment confirmation, settlement, receipt truth, refund authority, wallet mutation, or compensation execution.

This document is planning-only.

It does not authorize coding.

---

## 2. Room Definition

The Payment Intent and Authorization Room governs the beginning of a payment attempt.

It may later coordinate:

- payment intent candidate
- payment amount snapshot
- order reference
- customer/session reference
- tenant/store context
- payment method eligibility
- provider profile reference
- idempotency key
- authorization request candidate
- authorization pending state
- authorization failed state
- authorization timeout state
- customer-safe payment message
- payment evidence reference
- reconciliation requirement

Payment intent is not payment confirmed.

Authorization requested is not settlement.

---

## 3. Core Principle

Payment intent creates a controlled payment attempt boundary.

It does not create financial truth.

The correct rule is:

Order exists is not payment intent.  
Payment intent is not payment authorization.  
Authorization requested is not authorization approved.  
Authorization approved is not always captured payment.  
Payment pending is not paid.  
Payment timeout is not payment failed or paid by itself.  
Receipt candidate is not receipt truth.  
Customer clicked pay is not payment confirmed.  
Provider UI shown is not payment confirmed.  

Payment intent and authorization must be tenant-scoped, store-scoped, amount-locked, idempotent, provider-bound, evidence-bound, auditable, and safely projected.

---

## 4. Scope

The Payment Intent and Authorization Room may define planning boundaries for:

- payment intent creation
- authorization candidate
- amount snapshot
- tax/service/fee reference if applicable
- order reference
- customer/session reference
- provider profile selection
- payment method eligibility
- surface/device eligibility
- idempotency key
- authorization request
- authorization pending state
- authorization rejection
- authorization timeout
- duplicate authorization risk
- payment evidence reference
- customer-safe projection
- tenant/store isolation

This room does not implement payment runtime.

---

## 5. Payment Intent Input Boundary

Payment intent input may include:

| Input | Meaning |
|---|---|
| `tenant_id` | Tenant context |
| `store_id` | Store context |
| `order_reference` | Related order or order candidate |
| `validation_reference` | Validated price/order reference if applicable |
| `pos_reference` | POS reference if applicable |
| `customer_session_id` | Customer/session reference |
| `surface_id` | Source surface |
| `device_id` | Device if applicable |
| `amount_snapshot` | Amount candidate |
| `currency` | Currency |
| `payment_method_candidate` | Candidate method |
| `provider_profile_id` | Payment provider profile |
| `idempotency_key` | Duplicate prevention key |
| `safe_message_key` | Customer-safe message key |

Input must be tenant/store scoped.

Input must not come from unvalidated or unsafe context.

---

## 6. Payment Intent Output Boundary

Payment intent output may include:

| Output | Meaning |
|---|---|
| `payment_intent_id` | Payment intent reference |
| `payment_intent_status` | Intent state |
| `authorization_candidate_id` | Authorization candidate if created |
| `amount_snapshot_reference` | Locked amount reference |
| `provider_profile_reference` | Provider profile reference |
| `idempotency_reference` | Idempotency reference |
| `authorization_required` | Whether authorization is required |
| `customer_action_required` | Whether customer must act |
| `retry_review_required` | Whether retry requires review |
| `reconciliation_required` | Whether reconciliation may be needed |
| `evidence_reference` | Payment intent evidence |
| `safe_projection_reference` | Customer-safe projection |
| `audit_placeholder` | Future audit reference |

Output must not claim payment confirmation.

---

## 7. Payment Intent State Skeleton

Recommended payment intent states:

| State | Meaning |
|---|---|
| `PAYMENT_INTENT_NOT_CREATED` | No intent exists |
| `PAYMENT_INTENT_CANDIDATE` | Candidate prepared |
| `PAYMENT_INTENT_BLOCKED` | Intent blocked before creation |
| `PAYMENT_INTENT_CREATED` | Intent created |
| `PAYMENT_INTENT_CUSTOMER_ACTION_REQUIRED` | Customer action required |
| `PAYMENT_INTENT_AUTHORIZATION_READY` | Authorization may be attempted |
| `PAYMENT_INTENT_AUTHORIZATION_REQUESTED` | Authorization requested |
| `PAYMENT_INTENT_AUTHORIZATION_PENDING` | Authorization pending |
| `PAYMENT_INTENT_AUTHORIZATION_REJECTED` | Authorization rejected |
| `PAYMENT_INTENT_AUTHORIZATION_TIMEOUT` | Authorization timed out |
| `PAYMENT_INTENT_DUPLICATE_RISK` | Duplicate risk detected |
| `PAYMENT_INTENT_RETRY_REVIEW_REQUIRED` | Retry review required |
| `PAYMENT_INTENT_RECONCILIATION_REQUIRED` | Reconciliation required |
| `PAYMENT_INTENT_EXPIRED` | Intent expired |
| `PAYMENT_INTENT_UNKNOWN` | State uncertain |

These states are skeleton states only.

They do not authorize runtime.

---

## 8. Tenant And Store Isolation Boundary

Every payment intent must be tenant/store scoped.

A Store A payment intent must never appear in Store B context.

A Tenant A payment intent must never appear in Tenant B visibility.

Payment intent must fail closed when:

- tenant context is missing
- store context is missing where required
- amount snapshot is missing
- provider profile is missing
- idempotency key is missing
- source surface is unauthorized
- device context is unsafe
- customer/session context is unresolved
- order reference scope is mismatched
- financial authority is missing

Default:

`CROSS_TENANT_ACCESS_DENIED`

Payment intent must follow `10141`.

---

## 9. Amount Snapshot Boundary

Payment intent must use a locked amount snapshot.

Amount snapshot may include:

- item subtotal
- option subtotal
- discount reference if applicable
- coupon reference if applicable
- point/wallet reference if applicable
- tax/reference if applicable
- service/packaging/delivery fee if applicable
- total amount
- currency
- price version
- timestamp
- order reference
- validation reference

Amount snapshot must not be silently changed after authorization begins.

Amount change requires new review or new intent depending on future policy.

---

## 10. Payment Method Eligibility Boundary

Payment method eligibility may check:

- allowed provider
- allowed method
- store payment configuration
- tenant package entitlement
- device/surface eligibility
- customer action requirement
- minimum/maximum amount
- offline/degraded restrictions
- fraud/risk placeholder
- legal/compliance placeholder if applicable

Eligibility is not authorization.

Eligibility only allows an authorization attempt candidate.

---

## 11. Provider Profile Boundary

Payment provider profile must be evidence-based.

Provider profile may include:

- provider id
- merchant/store mapping
- supported methods
- supported currency
- authorization behavior
- capture behavior
- callback behavior
- refund/void behavior
- idempotency support
- timeout behavior
- retry behavior
- degraded mode behavior
- evidence/certification status

Provider profile is not provider truth.

Provider capability requires evidence.

---

## 12. Authorization Request Boundary

Authorization request may be attempted only when:

- tenant/store context is resolved
- order/amount snapshot is valid
- provider profile is verified
- payment method is eligible
- source surface/device is allowed
- idempotency key exists
- customer action requirement is satisfied if needed
- no containment block exists
- no degraded payment block exists
- audit/evidence route exists

This document does not authorize authorization request implementation.

It only defines the future gate.

---

## 13. Idempotency Boundary

Payment intent and authorization must be idempotent.

Idempotency must handle:

- customer double tap
- kiosk retry
- app refresh
- provider UI refresh
- network retry
- delayed provider response
- duplicate provider callback
- staff-assisted retry
- manual fallback after payment uncertainty
- support-assisted retry

Duplicate authorization or duplicate charge is a critical failure.

Retry must be controlled.

---

## 14. Authorization Pending Boundary

Authorization pending is uncertain.

Pending must not be projected as paid.

Pending may require:

- customer-safe message
- provider callback wait
- status check if later authorized
- staff assist if prolonged
- timeout review
- duplicate-risk prevention
- reconciliation requirement
- incident if customer impacted

Pending is not payment confirmed.

---

## 15. Authorization Rejection Boundary

Authorization rejection may occur because of:

- customer cancellation
- provider rejection
- payment method failure
- amount mismatch
- merchant/store mismatch
- duplicate risk
- provider unavailable
- policy block
- fraud/risk block if later authorized
- unknown provider error

Rejection must be safe-projected.

Raw provider reason must not be exposed by default.

Rejected authorization is not customer fault by default.

---

## 16. Authorization Timeout Boundary

Authorization timeout is uncertain.

Timeout must not be treated as paid.

Timeout must not be treated as safely failed if provider may later confirm.

Timeout may require:

- duplicate-risk review
- provider callback wait
- reconciliation requirement
- staff assist
- incident if customer impacted
- customer-safe message
- retry review

Timeout is not safe success.

Timeout is not safe failure.

---

## 17. Customer Action Boundary

Customer action may include:

- selecting payment method
- confirming amount
- completing provider UI
- approving authorization
- retrying after failure
- cancelling payment attempt

Customer action must not be treated as provider confirmation.

Customer clicked pay is not payment confirmed.

Provider UI completed is not payment confirmed until verified through Financial Trust.

---

## 18. Surface And Device Boundary

Payment intent may originate from:

- customer mobile web/app
- Mini Kiosk if authorized
- Full Kiosk if authorized
- staff tablet if authorized
- POS-linked surface if authorized
- owner/admin assisted flow if authorized

Surface/device must not:

- store raw secrets
- bypass provider profile
- bypass tenant/store scope
- bypass idempotency
- bypass amount snapshot
- bypass customer-safe projection
- confirm payment by local display alone

Device role is not payment authority.

---

## 19. Degraded Payment Boundary

Payment degraded mode is high-risk.

When payment provider, device, network, or configuration is degraded:

- high-risk payment actions should fail closed
- authorization may be blocked
- customer-safe message should be shown
- staff assist may be required
- manual fallback may be restricted
- reconciliation marker may be required
- incident may be opened

Payment unavailable is not free order approval.

Payment unknown is not paid.

---

## 20. Manual Fallback Boundary

Manual fallback around payment must be tightly controlled.

Manual fallback may record:

- payment not attempted
- payment unavailable
- payment state unknown
- customer asked to pay later if policy allows
- offline/manual payment note if separately authorized
- reconciliation required

Manual fallback must not:

- claim payment confirmed
- create wallet mutation
- approve refund
- execute compensation
- print final paid receipt without verification

Manual payment note is not financial truth.

---

## 21. Payment Intent Evidence Boundary

Payment intent evidence may include:

- tenant id
- store id
- payment intent id
- order reference
- amount snapshot reference
- provider profile id
- payment method candidate
- surface/device reference
- customer/session reference
- idempotency key
- authorization request marker
- authorization pending/rejected/timeout marker
- customer action marker
- degraded marker
- fallback marker
- reconciliation marker
- safe message key
- audit reference

Evidence supports verification.

Evidence is not payment confirmation.

---

## 22. Customer-Safe Payment Projection Boundary

Customer-safe payment projection may show:

- payment is being prepared
- please confirm payment
- payment is being checked
- payment could not be completed
- payment service is temporarily unavailable
- staff will assist
- try again later
- payment status is uncertain and being reviewed

Customer-safe projection must not show:

- raw provider error
- raw payment payload
- card or credential detail
- fraud/risk signal
- security containment detail
- settlement detail
- internal financial rule
- compensation promise
- cross-tenant/store information
- AI reasoning
- vector similarity

Payment messages must be i18n-controlled.

---

## 23. Staff/Admin Visibility Boundary

Staff/Admin visibility may include:

- payment intent status
- safe provider category
- amount snapshot reference
- idempotency reference
- authorization pending/rejected/timeout category
- reconciliation marker
- incident marker
- evidence reference

Staff/Admin visibility must not expose:

- raw payment credentials
- raw payment payload by default
- unrestricted provider response
- fraud/risk detail without authority
- unrelated tenant/store data
- unmasked customer data without authority

Visibility is not payment mutation authority.

---

## 24. Relationship To Store Runtime

Store Runtime may request payment intent only through controlled boundary.

Store Runtime must not:

- confirm payment
- mutate payment state
- approve refund
- mutate wallet
- issue coupon
- grant points
- approve compensation

Order state may reference payment intent.

Order state must not become financial truth.

---

## 25. Relationship To Payment Confirmation Room

Payment Intent and Authorization Room prepares authorization candidates.

Payment Confirmation and Provider Callback Room verifies actual payment outcome later.

Authorization requested is not confirmation.

Pending authorization must route to confirmation/callback verification.

---

## 26. Relationship To Refund/Cancellation/Void Room

Refund, cancellation, and void must not originate as side effects of failed intent unless separately authorized.

Failed intent may create review candidate.

It does not execute refund or void.

Refund/Cancellation/Void Room owns value reversal boundary.

---

## 27. Relationship To Coupon Point Wallet Stored Value Room

Coupon, point, wallet, and stored value may affect amount snapshot if authorized.

However:

- coupon application must be verified
- point usage must be locked/verified
- wallet usage must be financially controlled
- stored value usage must be ledger-bound

Payment Intent must not mutate these balances directly.

---

## 28. Relationship To Settlement Reconciliation Room

Payment intent does not equal settlement.

Authorization or payment provider result may later feed settlement/reconciliation.

Settlement Room owns settlement truth.

Payment Intent Room only creates attempt boundary and evidence.

---

## 29. Relationship To Compensation Recovery Value Room

Recovery value candidate may later create payment/refund/coupon/wallet/point flow.

Payment Intent Room must not approve compensation.

Compensation Review Room owns recovery value decision.

---

## 30. Relationship To Data Governance

Payment Intent uses Side D for:

- i18n payment messages
- masking policy
- support/admin visibility
- evidence classification
- retention policy
- export restriction
- AI summary restriction if later authorized
- pgvector source restriction if later authorized

Data Governance supports safe visibility.

Financial Trust owns value truth.

---

## 31. Payment Intent Anti-Patterns

Avoid:

- order created treated as payment intent
- payment intent treated as payment confirmed
- authorization requested treated as paid
- authorization pending projected as paid
- authorization timeout treated as success
- customer clicked pay treated as provider confirmation
- provider UI shown treated as payment confirmation
- device display treated as payment truth
- receipt candidate treated as receipt truth
- manual payment note treated as payment confirmed
- idempotency missing from authorization
- duplicate authorization from retry
- raw provider error shown to customer
- AI deciding payment status
- pgvector similarity treated as fraud or payment proof

These anti-patterns must be blocked in future runtime design.

---

## 32. Runtime Deferral

This document defines the Payment Intent and Authorization Room boundary only.

It does not authorize:

- payment intent API
- provider payment integration
- authorization request
- payment UI
- Kiosk payment runtime
- staff-assisted payment runtime
- idempotency implementation
- database schema
- webhook/callback processing
- refund/cancellation flow
- wallet/point/coupon mutation
- settlement engine
- AI runtime
- pgvector runtime
- production deployment

All runtime remains deferred.

---

## 33. Validation Checklist

Validation must confirm:

1. Payment Intent and Authorization Room definition is clear.
2. Payment intent is not financial confirmation.
3. Input boundary is defined.
4. Output boundary is defined.
5. State skeleton is defined.
6. Tenant/store isolation is defined.
7. Amount snapshot boundary is defined.
8. Payment method eligibility boundary is defined.
9. Provider profile boundary is defined.
10. Authorization request gate is defined.
11. Idempotency boundary is defined.
12. Authorization pending boundary is defined.
13. Authorization rejection boundary is defined.
14. Authorization timeout boundary is defined.
15. Customer action boundary is defined.
16. Surface/device boundary is defined.
17. Degraded payment boundary is defined.
18. Manual fallback boundary is defined.
19. Evidence boundary is defined.
20. Customer-safe projection boundary is defined.
21. Staff/Admin visibility boundary is defined.
22. Relationships to Financial Trust rooms are defined.
23. Relationship to Store Runtime is defined.
24. Relationship to Data Governance is defined.
25. Anti-patterns are listed.
26. Coding remains unauthorized.
27. Runtime remains deferred.

---

## 34. Relationship To Previous Documents

This document follows:

- `10400 Financial Trust Room Framing And Domain Boundary Index`

It references:

- `10141 SaaS Tenant Isolation And Cross-Tenant Data Containment Beam Policy`
- `10350 Store Runtime Room Framing Closure And Next Axis Handoff Policy`
- `10400 Financial Trust Room Framing And Domain Boundary Index`
- `10320 Operational Evidence Room Boundary Policy`
- `10330 Fulfillment Visibility Room Boundary Policy`
- `10340 Store Recovery Route Room Boundary Policy`

It prepares:

- `10420 Payment Confirmation And Provider Callback Boundary Policy`
- `10430 Refund Cancellation And Void Boundary Policy`
- `10440 Coupon Point Wallet And Stored Value Boundary Policy`

This document is room boundary planning only.

It does not authorize coding.

---

## 35. Final Rule

The Payment Intent and Authorization Room governs controlled creation of payment attempt boundaries.

Payment intent is not payment confirmed.

Authorization requested is not paid.

Authorization pending is not paid.

Authorization timeout is uncertain.

Customer clicked pay is not provider confirmation.

Device display is not payment truth.

Manual payment note is not financial truth.

Payment intent and authorization must preserve tenant/store isolation, amount snapshot integrity, provider profile evidence, idempotency, duplicate prevention, evidence, audit, degraded handling, manual fallback caution, i18n, Safe Projection, and separation from confirmation, refund, wallet, coupon, point, compensation, and settlement authority.

Runtime implementation remains deferred until a separate explicit authorization packet is approved.