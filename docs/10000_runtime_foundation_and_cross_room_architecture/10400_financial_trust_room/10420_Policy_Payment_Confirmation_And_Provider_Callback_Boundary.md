# 10420_Policy_Payment_Confirmation_And_Provider_Callback_Boundary

## 1. Purpose

This document defines the Payment Confirmation and Provider Callback Boundary Policy.

The previous artifact `10410` defined the Payment Intent and Authorization Boundary Policy.

This document frames the second Financial Trust room:

`Payment Confirmation And Provider Callback Room`

The purpose is to define the boundary where payment provider events, authorization results, capture results, approval responses, failure responses, delayed callbacks, duplicate callbacks, webhook events, status checks, and reconciliation candidates may be verified before any payment state is treated as confirmed financial truth.

This document is planning-only.

It does not authorize coding.

---

## 2. Room Definition

The Payment Confirmation and Provider Callback Room governs verification of payment outcome.

It may later coordinate:

- provider callback intake
- provider event matching
- payment authorization result
- payment capture result
- payment approval verification
- payment failure verification
- payment unknown state
- delayed callback handling
- duplicate callback handling
- provider event quarantine
- callback signature verification if applicable
- idempotency verification
- reconciliation requirement
- payment evidence packet
- customer-safe projection

Provider callback is not verified truth by itself.

Payment confirmation requires verified matching, scope, evidence, and reconciliation rules.

---

## 3. Core Principle

Provider event received is not payment confirmed.

The correct rule is:

Provider callback received is not verified truth.  
Authorization approved is not always captured payment.  
Provider success message is not settlement.  
Provider failure message is not always final failure.  
Delayed callback is not duplicate truth.  
Duplicate callback is not duplicate payment by itself.  
Local pending state is not paid.  
Receipt print is not payment confirmation.  
POS accepted is not payment confirmation.  
Customer screen success is not payment truth.  

Payment confirmation must be verified, matched, tenant-scoped, store-scoped, idempotent, audited, and reconcilable.

---

## 4. Scope

The Payment Confirmation and Provider Callback Room may define planning boundaries for:

- provider callback intake
- payment status verification
- authorization confirmation
- capture confirmation
- payment failure confirmation
- payment unknown state
- delayed callback handling
- duplicate callback handling
- provider event matching
- provider event quarantine
- callback signature/reference verification
- amount/currency verification
- tenant/store scope verification
- idempotency verification
- evidence packet creation
- customer-safe projection
- reconciliation routing

This room does not implement webhook or payment runtime.

---

## 5. Provider Callback Input Boundary

Provider callback input may include:

| Input | Meaning |
|---|---|
| `provider_id` | Payment provider |
| `provider_profile_id` | Provider profile reference |
| `provider_event_id` | Provider event reference |
| `provider_transaction_id` | Provider transaction reference |
| `payment_intent_id` | Internal payment intent reference if available |
| `authorization_reference` | Authorization reference if available |
| `order_reference` | Related order if available |
| `tenant_id` | Tenant context if derivable |
| `store_id` | Store context if derivable |
| `amount` | Provider amount |
| `currency` | Provider currency |
| `event_type` | Provider event type |
| `event_status` | Provider status |
| `event_timestamp` | Provider event time |
| `signature_reference` | Signature/verifier reference if applicable |
| `idempotency_key` | Idempotency reference if available |

Input is untrusted until verified.

---

## 6. Verification Output Boundary

Verification output may include:

| Output | Meaning |
|---|---|
| `payment_confirmation_id` | Confirmation reference |
| `payment_status` | Verified payment state |
| `provider_event_match_status` | Match status |
| `amount_match_status` | Amount verification status |
| `scope_match_status` | Tenant/store match status |
| `idempotency_status` | Idempotency verification |
| `duplicate_event_marker` | Duplicate marker |
| `delayed_event_marker` | Delayed event marker |
| `quarantine_required` | Whether event must be quarantined |
| `reconciliation_required` | Whether reconciliation is required |
| `evidence_reference` | Payment evidence reference |
| `safe_projection_reference` | Customer-safe projection |
| `audit_placeholder` | Future audit reference |

Output may confirm payment only if verification passes.

---

## 7. Payment Confirmation State Skeleton

Recommended payment confirmation states:

| State | Meaning |
|---|---|
| `PAYMENT_CONFIRMATION_NOT_STARTED` | Confirmation not started |
| `PAYMENT_PROVIDER_EVENT_RECEIVED` | Provider event received |
| `PAYMENT_PROVIDER_EVENT_UNMATCHED` | Event could not be matched |
| `PAYMENT_PROVIDER_EVENT_QUARANTINED` | Event quarantined |
| `PAYMENT_VERIFICATION_IN_PROGRESS` | Verification in progress |
| `PAYMENT_AUTHORIZATION_CONFIRMED` | Authorization verified |
| `PAYMENT_CAPTURE_CONFIRMED` | Capture/payment verified |
| `PAYMENT_FAILED_VERIFIED` | Failure verified |
| `PAYMENT_CANCELED_VERIFIED` | Cancellation verified |
| `PAYMENT_STATUS_UNKNOWN` | Status unknown |
| `PAYMENT_DUPLICATE_EVENT_DETECTED` | Duplicate event detected |
| `PAYMENT_DELAYED_CALLBACK_DETECTED` | Delayed callback detected |
| `PAYMENT_AMOUNT_MISMATCH` | Amount mismatch |
| `PAYMENT_SCOPE_MISMATCH` | Tenant/store/order mismatch |
| `PAYMENT_RECONCILIATION_REQUIRED` | Reconciliation required |
| `PAYMENT_CONFIRMATION_UNKNOWN` | Confirmation uncertain |

These states are skeleton states only.

They do not authorize runtime.

---

## 8. Tenant And Store Isolation Boundary

Every provider event must be attached to the correct tenant/store context before use.

A Store A payment event must never confirm Store B payment.

A Tenant A provider event must never appear in Tenant B visibility.

Provider event must fail closed when:

- tenant context cannot be resolved
- store context cannot be resolved where required
- payment intent match fails
- order reference match fails
- amount/currency mismatch exists
- provider profile mismatch exists
- idempotency mismatch exists
- duplicate event status is unsafe
- callback verification fails
- cross-tenant/store anomaly is detected

Default:

`CROSS_TENANT_ACCESS_DENIED`

Payment confirmation must follow `10141`.

---

## 9. Provider Event Matching Boundary

Provider event matching may use:

- provider id
- provider profile id
- payment intent id
- provider transaction id
- order reference
- customer/session reference if available
- tenant id
- store id
- amount
- currency
- idempotency key
- timestamp
- callback signature/reference if applicable

Provider event must not be matched by one weak key alone.

External transaction id alone is insufficient when tenant/store context is ambiguous.

---

## 10. Amount And Currency Verification Boundary

Payment confirmation must verify:

- expected amount
- provider amount
- expected currency
- provider currency
- authorized amount
- captured amount if applicable
- partial capture rules if applicable
- discount/coupon/point/wallet reference if applicable
- price snapshot reference
- rounding/fee rule if applicable

Amount mismatch must trigger review or quarantine.

Amount mismatch must not be silently corrected.

---

## 11. Authorization Versus Capture Boundary

Authorization and capture must be distinguished.

Possible states include:

- authorization approved
- authorization declined
- authorization canceled
- capture pending
- capture completed
- capture failed
- partial capture
- capture unknown

Authorization approved is not always captured payment.

Capture confirmation is stronger payment truth, but still not settlement.

Settlement remains separate.

---

## 12. Success Event Boundary

A success event may be accepted as payment confirmation only when:

- provider event is verified
- tenant/store scope matches
- payment intent matches
- amount/currency matches
- idempotency matches
- duplicate risk is controlled
- callback verification passes if applicable
- no containment block exists
- evidence packet is created
- audit route exists

Success event without verification must not become payment truth.

---

## 13. Failure Event Boundary

Failure event may represent:

- customer cancellation
- provider decline
- payment method failure
- expired authorization
- amount mismatch
- merchant/store mismatch
- risk block
- timeout converted to failure
- unknown provider error

Failure must be verified before final projection.

Failure must not automatically blame customer.

Failure may require retry review, staff assist, or incident if customer impacted.

---

## 14. Unknown Payment State Boundary

Unknown payment state may occur when:

- callback delayed
- provider unreachable
- status check unavailable
- timeout occurred
- duplicate event conflict exists
- amount mismatch exists
- scope mismatch exists
- manual fallback occurred
- provider event is quarantined
- local/central divergence exists

Unknown state must not be projected as paid.

Unknown state must not be projected as failed unless verified.

Unknown state requires safe projection and review.

---

## 15. Delayed Callback Boundary

Delayed callback must be handled carefully.

Delayed callback may arrive after:

- customer retry
- staff retry
- POS/KDS attempt
- manual fallback
- incident creation
- customer left
- recovery review began
- cancellation attempt
- refund attempt

Delayed callback must trigger:

- idempotency review
- duplicate payment risk review
- order/payment state comparison
- reconciliation requirement
- evidence packet
- safe projection if customer impacted

Delayed callback must not silently overwrite current state.

---

## 16. Duplicate Callback Boundary

Duplicate provider callbacks may occur.

Duplicate callback must not create duplicate payment state.

Duplicate callback handling must consider:

- provider event id
- transaction id
- idempotency key
- amount
- event type
- event timestamp
- previous processed event
- current payment state
- reconciliation marker

Duplicate event is evidence.

It is not a duplicate charge by itself unless verified.

---

## 17. Provider Event Quarantine Boundary

Provider event must be quarantined when:

- tenant/store match fails
- payment intent not found
- amount/currency mismatch exists
- provider profile mismatch exists
- signature/reference verification fails
- event is malformed
- duplicate state is unsafe
- callback arrives after incompatible state
- cross-tenant risk exists
- security containment is active

Quarantined event must not be customer-visible as verified truth.

Quarantine is not deletion.

Quarantine is not resolution.

---

## 18. Status Check Boundary

A status check may be used later if authorized.

Status check must:

- use provider profile
- preserve tenant/store scope
- use payment intent/reference
- avoid duplicate mutation
- create evidence
- preserve audit
- handle provider mismatch
- handle stale result
- route reconciliation if needed

Status check result is provider evidence.

It still requires verification.

---

## 19. Idempotency Boundary

Payment confirmation must be idempotent.

Idempotency must handle:

- repeated callback
- retry after timeout
- customer double tap
- staff-assisted retry
- provider duplicate event
- status check replay
- webhook replay
- manual fallback reconciliation
- delayed success after failure path

No duplicate financial confirmation may occur.

Idempotency failure is a critical financial incident.

---

## 20. Reconciliation Boundary

Payment confirmation may require reconciliation with:

- payment intent
- order state
- POS state
- KDS state
- kitchen state
- provider callback
- provider status check
- receipt record
- manual fallback record
- incident record
- recovery route
- settlement record later

Reconciliation must be append-only.

Reconciliation must not silently mutate financial truth.

---

## 21. Payment Evidence Boundary

Payment confirmation evidence may include:

- tenant id
- store id
- payment intent id
- payment confirmation id
- provider id
- provider profile id
- provider event id
- provider transaction id
- authorization reference
- capture reference
- amount/currency
- verification result
- match result
- idempotency key
- duplicate marker
- delayed marker
- quarantine marker
- reconciliation marker
- safe message key
- audit reference

Payment evidence is high-risk.

It must be masked and access-controlled.

---

## 22. Customer-Safe Payment Projection Boundary

Customer-safe payment projection may show:

- payment completed if verified
- payment could not be completed if verified
- payment is being checked
- payment status is uncertain and under review
- staff will assist
- payment service is temporarily unavailable
- refund or cancellation review is separate

Customer-safe projection must not show:

- raw provider callback
- raw payment payload
- card/credential detail
- fraud/risk signal
- security containment detail
- settlement detail
- internal financial rule
- duplicate event detail
- compensation promise
- cross-tenant/store information
- AI reasoning
- vector similarity

Payment messages must be i18n-controlled.

---

## 23. Staff/Admin Visibility Boundary

Staff/Admin visibility may include:

- verified payment status
- unknown payment status
- provider event match category
- amount match category
- idempotency status
- duplicate/delayed marker
- quarantine marker
- reconciliation marker
- evidence reference
- incident reference if applicable

Staff/Admin visibility must not expose:

- raw credentials
- unrestricted raw provider payload
- card data
- fraud/risk detail without authority
- unrelated tenant/store data
- unmasked customer data without authority

Visibility is not financial mutation authority.

---

## 24. Relationship To Payment Intent Room

Payment Intent Room creates payment attempt boundary.

Payment Confirmation Room verifies payment outcome.

Payment intent is not payment confirmed.

Authorization requested is not payment confirmed.

Payment confirmation must reference and verify the payment intent where applicable.

---

## 25. Relationship To Refund Cancellation And Void Room

Payment Confirmation Room may create candidates for:

- cancellation review
- void review
- refund review
- duplicate payment review
- failed payment follow-up
- unknown payment incident

It must not execute refund, void, or cancellation directly.

Refund/Cancellation/Void Room owns reversal boundary.

---

## 26. Relationship To Coupon Point Wallet Stored Value Room

Payment confirmation may interact with value instruments when:

- coupon was applied
- points were used
- wallet/stored value was used
- compensation value was applied
- loyalty accrual depends on paid status

Payment Confirmation Room must not mutate coupon, point, wallet, or stored value directly unless separately authorized through value ledger policy.

---

## 27. Relationship To Settlement Reconciliation Room

Payment confirmed is not settlement.

Payment confirmation may feed settlement candidate later.

Settlement Room owns:

- settlement calculation
- provider settlement matching
- payout reconciliation
- fee allocation
- legal entity allocation
- correction/amendment

Provider success is not settlement paid.

---

## 28. Relationship To Store Runtime

Store Runtime may consume safe payment status projection.

Store Runtime must not:

- infer payment from POS/KDS/kitchen state
- infer payment from receipt print
- infer payment from customer screen
- mutate payment confirmation
- bypass unknown payment review

Store Runtime can react to verified projection only.

---

## 29. Relationship To Data Governance

Payment Confirmation uses Side D for:

- i18n payment messages
- masking
- retention
- support/admin visibility
- evidence classification
- export restriction
- AI summary restriction if later authorized
- pgvector source restriction if later authorized
- analytics/read model governance

Data Governance supports safe visibility.

Financial Trust owns payment truth.

---

## 30. Payment Confirmation Anti-Patterns

Avoid:

- provider callback treated as verified truth
- success event accepted without tenant/store match
- amount mismatch silently corrected
- authorization approved treated as capture
- payment pending shown as paid
- payment timeout shown as failed without verification
- delayed callback overwriting current state silently
- duplicate callback creating duplicate payment
- provider transaction id matched without tenant/store scope
- receipt print treated as confirmation
- customer success screen treated as payment truth
- raw provider callback shown to customer
- AI deciding payment status
- pgvector similarity treated as payment proof

These anti-patterns must be blocked in future runtime design.

---

## 31. Runtime Deferral

This document defines the Payment Confirmation and Provider Callback Room boundary only.

It does not authorize:

- webhook endpoint
- provider callback processing
- provider status check
- payment confirmation API
- payment database schema
- idempotency implementation
- reconciliation engine
- refund/cancellation runtime
- settlement runtime
- AI runtime
- pgvector runtime
- production deployment

All runtime remains deferred.

---

## 32. Validation Checklist

Validation must confirm:

1. Payment Confirmation and Provider Callback Room definition is clear.
2. Provider event received is not payment confirmed.
3. Provider callback input boundary is defined.
4. Verification output boundary is defined.
5. State skeleton is defined.
6. Tenant/store isolation is defined.
7. Provider event matching boundary is defined.
8. Amount/currency verification boundary is defined.
9. Authorization versus capture boundary is defined.
10. Success event boundary is defined.
11. Failure event boundary is defined.
12. Unknown payment state boundary is defined.
13. Delayed callback boundary is defined.
14. Duplicate callback boundary is defined.
15. Quarantine boundary is defined.
16. Status check boundary is defined.
17. Idempotency boundary is defined.
18. Reconciliation boundary is defined.
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

## 33. Relationship To Previous Documents

This document follows:

- `10410 Payment Intent And Authorization Boundary Policy`

It references:

- `10141 SaaS Tenant Isolation And Cross-Tenant Data Containment Beam Policy`
- `10350 Store Runtime Room Framing Closure And Next Axis Handoff Policy`
- `10400 Financial Trust Room Framing And Domain Boundary Index`
- `10410 Payment Intent And Authorization Boundary Policy`
- `10320 Operational Evidence Room Boundary Policy`
- `10330 Fulfillment Visibility Room Boundary Policy`

It prepares:

- `10430 Refund Cancellation And Void Boundary Policy`
- `10440 Coupon Point Wallet And Stored Value Boundary Policy`
- `10450 Settlement Allocation And Reconciliation Boundary Policy`

This document is room boundary planning only.

It does not authorize coding.

---

## 34. Final Rule

The Payment Confirmation and Provider Callback Room verifies payment outcome.

Provider callback received is not verified truth.

Authorization approved is not always captured payment.

Provider success is not settlement.

Payment pending is not paid.

Payment timeout is uncertain.

Delayed callback must not silently overwrite current state.

Duplicate callback must not create duplicate payment.

Payment confirmation must preserve tenant/store isolation, provider verification, amount/currency matching, idempotency, duplicate prevention, quarantine, evidence, audit, reconciliation, i18n, Safe Projection, and separation from refund, cancellation, wallet, coupon, point, compensation, settlement, and Store Runtime authority.

Runtime implementation remains deferred until a separate explicit authorization packet is approved.