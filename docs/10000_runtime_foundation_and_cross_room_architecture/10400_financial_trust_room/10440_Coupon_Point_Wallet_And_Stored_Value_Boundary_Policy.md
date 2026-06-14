# 10440_Coupon_Point_Wallet_And_Stored_Value_Boundary_Policy

## 1. Purpose

This document defines the Coupon, Point, Wallet, and Stored Value Boundary Policy.

The previous artifact `10430` defined the Refund, Cancellation, and Void Boundary Policy.

This document frames the fourth Financial Trust room:

`Coupon Point Wallet And Stored Value Room`

The purpose is to define the boundary where non-cash value instruments, customer benefits, loyalty points, coupons, prepaid balances, stored value, goodwill credits, subscription credits, recovery credits, and promotional value are issued, reserved, redeemed, reversed, expired, audited, reconciled, and safely projected without being confused with payment confirmation, refund execution, settlement, compensation approval, Store Runtime action, or CMS campaign visibility.

This document is planning-only.

It does not authorize coding.

---

## 2. Room Definition

The Coupon, Point, Wallet, and Stored Value Room governs customer value instruments.

It may later coordinate:

- coupon issuance
- coupon redemption
- coupon cancellation
- coupon expiration
- point accrual
- point redemption
- point adjustment
- wallet credit
- wallet debit
- prepaid/stored value balance
- subscription credit
- recovery value credit
- value reservation
- value release
- value reversal
- fraud/abuse review
- value ledger evidence
- customer-safe projection

Coupons, points, wallet balances, and stored value are financial/value records.

They must not be mutated by Store Runtime rooms.

---

## 3. Core Principle

Value instruments are financial records, not marketing decorations.

The correct rule is:

Coupon visible is not coupon issued.  
Coupon issued is not coupon redeemed.  
Coupon selected is not coupon consumed.  
Point expected is not point accrued.  
Point shown is not point available unless ledger-verified.  
Wallet balance shown is not wallet truth unless ledger-verified.  
Recovery review is not wallet credit.  
Staff promise is not point adjustment.  
CMS campaign is not value issuance.  
AI recommendation is not value authority.  

Coupon, point, wallet, and stored value operations must be tenant-scoped, customer-scoped, ledger-bound, idempotent, auditable, reversible by policy, and safely projected.

---

## 4. Scope

This room may define planning boundaries for:

- coupon issuance
- coupon redemption
- coupon reservation
- coupon release
- coupon cancellation
- coupon expiration
- point accrual
- point redemption
- point adjustment
- wallet credit
- wallet debit
- stored value balance
- subscription credit
- recovery value credit
- promotional value
- fraud/abuse review
- value evidence packet
- customer-safe projection
- reconciliation routing
- tenant/store/customer isolation

This room does not implement value ledger runtime.

---

## 5. Value Instrument Catalog

Recommended value instrument catalog:

| Instrument | Meaning |
|---|---|
| `COUPON` | Discount or benefit coupon |
| `POINT` | Loyalty point value |
| `WALLET_BALANCE` | Customer wallet balance |
| `PREPAID_VALUE` | Prepaid stored value |
| `SUBSCRIPTION_CREDIT` | Subscription or plan-linked credit |
| `RECOVERY_CREDIT` | Recovery-related value candidate |
| `PROMOTIONAL_CREDIT` | Campaign or promotion value |
| `GIFT_CREDIT` | Gift-linked stored value if later authorized |
| `MANUAL_ADJUSTMENT` | Manual value adjustment requiring review |
| `VALUE_REVERSAL` | Reversal of prior value movement |

Instrument type determines authority, evidence, expiration, and reconciliation.

---

## 6. Value Ledger Principle

Every value movement must be ledger-bound.

A value ledger entry should record:

- tenant id
- store id if store-scoped
- customer/account id
- instrument type
- movement type
- amount or value unit
- currency if monetary
- point unit if non-monetary
- source reference
- reason category
- authority reference
- idempotency key
- previous balance reference
- resulting balance reference
- evidence reference
- audit reference

Ledger movement must be append-only.

Balance must be derived from verified ledger entries.

---

## 7. Value Movement Type Catalog

Recommended movement types:

| Movement | Meaning |
|---|---|
| `ISSUE` | Issue new value |
| `RESERVE` | Reserve value for pending use |
| `REDEEM` | Consume value |
| `RELEASE` | Release reserved value |
| `EXPIRE` | Expire value by policy |
| `CANCEL` | Cancel issued value |
| `ADJUST_CREDIT` | Manual/admin credit adjustment |
| `ADJUST_DEBIT` | Manual/admin debit adjustment |
| `REVERSAL` | Reverse prior movement |
| `RECOVERY_CREDIT` | Credit from recovery decision |
| `PROMOTIONAL_CREDIT` | Credit from approved campaign |
| `MIGRATION_IMPORT` | Imported balance if later authorized |

Movement type must be explicit.

Silent balance mutation is prohibited.

---

## 8. Coupon Boundary

Coupon may include:

- coupon template
- coupon issue event
- coupon owner/customer
- coupon validity period
- coupon usage condition
- coupon reservation state
- coupon redemption state
- coupon cancellation state
- coupon expiration state
- coupon evidence

Coupon visible in UI is not coupon issued.

Coupon selected at checkout is not coupon redeemed.

Coupon redeemed requires ledger/evidence confirmation.

---

## 9. Coupon Issue Boundary

Coupon issuance requires:

- tenant context
- customer/account context
- coupon template
- issue reason
- issue authority
- validity period
- usage policy
- idempotency key
- evidence reference
- audit reference

Coupon issuance must not be performed by CMS publication alone.

CMS may advertise coupon.

Financial Trust issues coupon.

---

## 10. Coupon Redemption Boundary

Coupon redemption may require:

- coupon exists
- coupon owner matches customer/account
- coupon is active
- coupon is not expired
- coupon has not been redeemed
- coupon policy applies
- order/payment context matches
- tenant/store scope matches
- idempotency key exists
- reservation or redemption evidence exists

Coupon redemption must not occur silently.

Coupon redemption must not be duplicated by retry.

---

## 11. Coupon Reservation And Release Boundary

Coupon may be reserved during checkout or payment attempt.

Reservation must define:

- coupon id
- order/payment reference
- reservation time
- expiry
- idempotency key
- release rule
- redemption rule
- evidence reference

Reservation is not redemption.

If payment fails or order is canceled, reservation may need release.

Release must be ledger-traceable.

---

## 12. Point Accrual Boundary

Point accrual may depend on:

- verified payment
- eligible order
- customer/account eligibility
- promotion policy
- store/tenant policy
- accrual rate
- exclusion rules
- refund/reversal impact
- fraud/abuse review if applicable

Expected points are not accrued points.

Points should accrue only after verified eligible event.

---

## 13. Point Redemption Boundary

Point redemption requires:

- customer/account ownership
- sufficient available balance
- eligible order/payment context
- redemption policy
- reservation if needed
- idempotency key
- evidence reference
- audit reference

Point selected is not point consumed.

Point redemption must be ledger-bound.

---

## 14. Point Adjustment Boundary

Point adjustment may be needed for:

- correction
- recovery
- promotion
- fraud/abuse correction
- refund reversal
- migration correction
- admin review

Point adjustment requires explicit authority.

Staff promise is not point adjustment.

AI recommendation is not point adjustment.

---

## 15. Wallet Boundary

Wallet balance is high-risk.

Wallet may include:

- wallet credit
- wallet debit
- wallet hold/reservation
- prepaid balance
- recovery credit
- promotional credit if allowed
- expiration if policy applies
- reversal
- reconciliation

Wallet balance must be ledger-derived.

Wallet mutation must not occur outside Financial Trust.

---

## 16. Wallet Credit Boundary

Wallet credit may originate from:

- prepaid purchase
- recovery value approval
- promotional campaign approval
- refund-to-wallet if legally/policy allowed
- manual adjustment approval
- migration import if later authorized

Wallet credit requires:

- authority
- customer/account scope
- value amount
- reason category
- idempotency key
- evidence
- audit

Recovery review is not wallet credit.

Wallet credit is executed value action.

---

## 17. Wallet Debit Boundary

Wallet debit may occur when:

- customer uses wallet for payment
- stored value is consumed
- prepaid balance is used
- correction requires debit
- reversal applies

Wallet debit requires:

- available balance
- customer/account ownership
- payment/order reference
- idempotency key
- evidence
- audit

Wallet shown in UI must not be treated as available unless ledger-verified.

---

## 18. Stored Value Boundary

Stored value may include prepaid value, gift credit, subscription credit, or other value instruments if later authorized.

Stored value must consider:

- legal/compliance classification
- expiration policy
- refundability
- transferability
- tenant/store restriction
- customer/account ownership
- ledger movement
- reconciliation
- export/reporting requirement

Stored value is not ordinary CMS benefit.

It is financial/value infrastructure.

---

## 19. Subscription Credit Boundary

Subscription credit may apply to future planned recurring pickup/delivery or membership products.

Subscription credit must define:

- subscription plan
- credit cycle
- eligible use
- unused credit rule
- expiration/carryover rule
- cancellation impact
- refund impact
- ledger treatment
- customer-safe projection

Subscription credit must not be manually adjusted without authority.

---

## 20. Recovery Credit Boundary

Recovery credit may originate from Store Recovery Route.

Recovery credit requires:

- recovery review completed
- value action approved
- customer/account identified
- amount/unit defined
- reason category
- authority reference
- evidence reference
- idempotency key
- audit reference

Recovery candidate is not recovery credit.

Approved recovery is not executed credit until ledger entry exists.

---

## 21. Promotional Credit Boundary

Promotional credit may originate from marketing campaign or membership policy.

Promotional credit requires:

- approved campaign
- target scope
- customer/account eligibility
- issuance rule
- usage rule
- expiry rule
- budget/control rule
- evidence
- audit

CMS campaign visibility is not promotional credit issuance.

---

## 22. Fraud And Abuse Review Boundary

Value instruments require abuse controls.

Review may be needed for:

- repeated coupon issuance
- repeated recovery credit
- abnormal point adjustment
- wallet debit/credit mismatch
- multiple accounts using same benefit
- device/session abuse
- refund plus coupon duplication
- promotion stacking abuse
- staff/manual adjustment abuse

Fraud/abuse signal is not guilt.

Review requires evidence and authority.

---

## 23. Value Expiration Boundary

Expiration must be policy-driven.

Expiration should define:

- instrument type
- issue date
- expiry date
- grace period if any
- customer notice if required
- legal/compliance constraint
- expiration ledger entry
- audit reference

Expiration must not silently delete value record.

Expiration should be ledger-traceable.

---

## 24. Value Reversal Boundary

Value reversal may occur when:

- order canceled
- refund issued
- coupon reservation released
- point accrual reversed
- wallet debit reversed
- wallet credit canceled
- promotion canceled
- fraud/abuse confirmed
- migration error corrected

Reversal must reference original movement.

Reversal must be append-only.

Reversal must not erase original ledger entry.

---

## 25. Tenant Store Customer Isolation Boundary

Every value instrument must be scoped.

Required scope may include:

- tenant id
- customer/account id
- store id if store-specific
- brand id if brand-specific
- membership program id if applicable
- instrument id
- ledger movement id
- source policy
- authority reference

A Tenant A customer value record must not appear in Tenant B.

A Store A-only benefit must not be redeemed in Store B unless policy allows it.

Default:

`CROSS_TENANT_ACCESS_DENIED`

Value instruments must follow `10141`.

---

## 26. Customer-Safe Value Projection Boundary

Customer-safe projection may show:

- available coupon
- coupon reserved
- coupon used
- coupon expired
- points expected
- points available if ledger-verified
- points used
- wallet balance if ledger-verified
- credit under review
- credit applied if verified
- value adjustment completed if verified

Customer-safe projection must not show:

- raw ledger internals
- fraud/abuse signal
- internal recovery note
- provider payload
- staff-only note
- legal conclusion
- unapproved compensation promise
- cross-tenant/store information
- AI reasoning
- vector similarity

Value messages must be i18n-controlled.

---

## 27. Staff/Admin Visibility Boundary

Staff/Admin visibility may include:

- value instrument status
- coupon issue/redemption state
- point movement status
- wallet movement status
- recovery credit status
- adjustment reason category
- evidence reference
- audit reference
- fraud/abuse review marker if authorized

Staff/Admin visibility must not expose:

- unrelated customer accounts
- unrelated tenant/store data
- raw sensitive data
- unrestricted fraud/risk detail
- financial ledger internals beyond role authority

Visibility is not mutation authority.

---

## 28. Value Evidence Boundary

Value evidence may include:

- tenant id
- customer/account id
- store id if applicable
- instrument id
- movement id
- movement type
- amount/unit
- previous balance reference
- resulting balance reference
- source order/payment/recovery reference
- authority reference
- reason category
- idempotency key
- reversal reference if applicable
- safe message key
- audit reference

Value evidence is financial evidence.

It must be access-controlled.

---

## 29. Relationship To Payment Intent Room

Coupon, point, wallet, or stored value may affect payment amount snapshot.

Payment Intent must reference verified value state.

Payment Intent must not mutate value ledger directly unless separately authorized.

Value reservation may occur before payment.

Value redemption should depend on verified rules and final payment/payment outcome policy.

---

## 30. Relationship To Payment Confirmation Room

Payment confirmation may trigger:

- point accrual
- coupon redemption confirmation
- wallet debit finalization
- value reservation release
- promotion eligibility confirmation

Payment confirmation must be verified before value finalization where policy requires it.

Pending payment is not final value movement.

---

## 31. Relationship To Refund Cancellation Void Room

Refund/cancellation may require:

- coupon restoration
- coupon consumption reversal
- point accrual reversal
- point redemption release
- wallet debit reversal
- wallet credit correction
- recovery credit adjustment

Refund is not automatically value reversal.

Value reversal requires ledger rule.

---

## 32. Relationship To Settlement Reconciliation Room

Value instruments may affect settlement and revenue allocation.

Examples:

- coupon discount allocation
- point redemption liability
- wallet prepaid liability
- subscription credit recognition
- promotional expense allocation
- recovery compensation cost

Settlement Room owns settlement and allocation truth.

Value ledger provides input.

---

## 33. Relationship To Compensation Recovery Value Room

Compensation may use coupon, point, wallet, or stored value.

Compensation Room may approve value action.

Coupon/Point/Wallet Room executes ledger-bound value movement when authorized.

Recovery review is not value execution.

---

## 34. Relationship To Store Runtime

Store Runtime may display safe value status.

Store Runtime must not:

- issue coupon
- redeem coupon without Financial Trust boundary
- adjust points
- mutate wallet
- grant recovery credit
- apply stored value without ledger control
- infer value from staff note
- promise value compensation

Store Runtime consumes safe projections only.

---

## 35. Relationship To Data Governance

Value Room uses Side D for:

- i18n value messages
- masking policy
- retention policy
- support/admin visibility
- export restrictions
- promotion content governance
- AI recommendation restriction if later authorized
- pgvector source restriction if later authorized
- analytics/read model governance

Data Governance supports safe visibility.

Financial Trust owns value ledger.

---

## 36. Value Instrument Anti-Patterns

Avoid:

- coupon visible treated as issued
- coupon selected treated as redeemed
- CMS campaign treated as coupon issuance
- expected points treated as accrued
- staff promise treated as point adjustment
- wallet balance display treated as ledger truth without verification
- recovery review treated as wallet credit
- approved compensation treated as executed value movement
- silent balance mutation
- value expiration deleting history
- refund automatically restoring value without policy
- promotion stacking without review
- fraud signal treated as guilt
- AI deciding value issuance
- pgvector similarity treated as abuse proof

These anti-patterns must be blocked in future runtime design.

---

## 37. Runtime Deferral

This document defines the Coupon, Point, Wallet, and Stored Value Room boundary only.

It does not authorize:

- coupon engine
- point ledger
- wallet ledger
- stored value ledger
- subscription credit runtime
- value reservation engine
- value reversal engine
- fraud/abuse engine
- promotional campaign runtime
- database schema
- AI runtime
- pgvector runtime
- production deployment

All runtime remains deferred.

---

## 38. Validation Checklist

Validation must confirm:

1. Coupon/Point/Wallet/Stored Value Room definition is clear.
2. Value instruments are financial/value records.
3. Value instrument catalog is defined.
4. Value ledger principle is defined.
5. Movement type catalog is defined.
6. Coupon boundary is defined.
7. Coupon issue boundary is defined.
8. Coupon redemption boundary is defined.
9. Coupon reservation/release boundary is defined.
10. Point accrual boundary is defined.
11. Point redemption boundary is defined.
12. Point adjustment boundary is defined.
13. Wallet boundary is defined.
14. Wallet credit boundary is defined.
15. Wallet debit boundary is defined.
16. Stored value boundary is defined.
17. Subscription credit boundary is defined.
18. Recovery credit boundary is defined.
19. Promotional credit boundary is defined.
20. Fraud/abuse review boundary is defined.
21. Expiration boundary is defined.
22. Reversal boundary is defined.
23. Tenant/store/customer isolation is defined.
24. Customer-safe projection boundary is defined.
25. Staff/Admin visibility boundary is defined.
26. Value evidence boundary is defined.
27. Relationships to Financial Trust rooms are defined.
28. Relationship to Store Runtime is defined.
29. Relationship to Data Governance is defined.
30. Anti-patterns are listed.
31. Coding remains unauthorized.
32. Runtime remains deferred.

---

## 39. Relationship To Previous Documents

This document follows:

- `10430 Refund Cancellation And Void Boundary Policy`

It references:

- `10141 SaaS Tenant Isolation And Cross-Tenant Data Containment Beam Policy`
- `10340 Store Recovery Route Room Boundary Policy`
- `10350 Store Runtime Room Framing Closure And Next Axis Handoff Policy`
- `10400 Financial Trust Room Framing And Domain Boundary Index`
- `10410 Payment Intent And Authorization Boundary Policy`
- `10420 Payment Confirmation And Provider Callback Boundary Policy`
- `10430 Refund Cancellation And Void Boundary Policy`

It prepares:

- `10450 Settlement Allocation And Reconciliation Boundary Policy`
- `10460 Compensation And Customer Recovery Value Boundary Policy`
- `10470 Financial Evidence Audit And Export Boundary Policy`

This document is room boundary planning only.

It does not authorize coding.

---

## 40. Final Rule

The Coupon, Point, Wallet, and Stored Value Room governs ledger-bound customer value instruments.

Coupon visible is not coupon issued.

Coupon selected is not coupon redeemed.

Expected points are not accrued points.

Wallet display is not ledger truth unless verified.

Recovery review is not wallet credit.

CMS campaign is not value issuance.

Staff promise is not value mutation.

AI recommendation is not value authority.

All coupon, point, wallet, stored value, subscription credit, recovery credit, and promotional value operations must preserve tenant/store/customer isolation, ledger immutability, idempotency, authority control, evidence, audit, reversal traceability, i18n, Safe Projection, Store Runtime separation, and settlement/reconciliation separation.

Runtime implementation remains deferred until a separate explicit authorization packet is approved.