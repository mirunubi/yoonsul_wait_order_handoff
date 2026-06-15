# 10450_Policy_Settlement_Allocation_And_Reconciliation_Boundary

## 1. Purpose

This document defines the Settlement, Allocation, and Reconciliation Boundary Policy.

The previous artifact `10440` defined the Coupon, Point, Wallet, and Stored Value Boundary Policy.

This document frames the fifth Financial Trust room:

`Settlement Allocation And Reconciliation Room`

The purpose is to define the boundary where payment confirmations, refunds, coupons, points, wallet movements, delivery/provider fees, store revenue, tenant revenue, legal entity allocation, operating group allocation, payout candidates, settlement reports, mismatches, corrections, and reconciliation evidence are governed without being confused with order fulfillment, POS acceptance, payment confirmation alone, refund execution alone, or owner/admin visibility.

This document is planning-only.

It does not authorize coding.

---

## 2. Room Definition

The Settlement, Allocation, and Reconciliation Room governs financial finalization and value allocation.

It may later coordinate:

- settlement candidate
- provider settlement report
- payment settlement reference
- refund settlement adjustment
- coupon/point/wallet allocation
- store allocation
- tenant allocation
- legal entity allocation
- operating group allocation
- provider fee allocation
- delivery/channel fee allocation
- payout candidate
- reconciliation mismatch
- correction/amendment
- settlement evidence packet
- financial audit reference

Settlement calculated is not settlement paid.

Provider settlement is not internal truth until reconciled.

---

## 3. Core Principle

Settlement is not the same as payment confirmation.

The correct rule is:

Payment confirmed is not settlement completed.  
Refund executed is not settlement adjusted.  
Coupon redeemed is not allocation settled.  
Wallet used is not revenue recognized by itself.  
POS accepted is not settlement truth.  
KDS completed is not settlement truth.  
Provider report is not internal truth by itself.  
Payout candidate is not payout executed.  
Reconciliation mismatch is not correction.  
Correction is not silent overwrite.  

Settlement must be tenant-scoped, store-scoped, legal-entity aware, provider-reconciled, ledger-bound, auditable, append-only, and export-controlled.

---

## 4. Scope

This room may define planning boundaries for:

- payment settlement candidate
- refund adjustment candidate
- value instrument allocation
- store revenue allocation
- tenant/platform fee allocation
- legal entity allocation
- operating group allocation
- provider fee allocation
- delivery/channel fee allocation
- payout candidate
- payout verification
- settlement mismatch
- reconciliation review
- correction/amendment
- settlement evidence
- settlement export
- tenant/store/legal isolation

This room does not implement settlement runtime.

---

## 5. Settlement Object Catalog

Recommended settlement object catalog:

| Object | Meaning |
|---|---|
| `SETTLEMENT_CANDIDATE` | Candidate settlement record |
| `PROVIDER_SETTLEMENT_REPORT` | External provider settlement report |
| `PAYMENT_SETTLEMENT_LINE` | Payment-related settlement line |
| `REFUND_ADJUSTMENT_LINE` | Refund-related adjustment |
| `VALUE_ALLOCATION_LINE` | Coupon/point/wallet/stored value allocation |
| `FEE_ALLOCATION_LINE` | Provider/channel/platform fee allocation |
| `STORE_REVENUE_LINE` | Store revenue allocation |
| `TENANT_REVENUE_LINE` | Tenant/platform revenue allocation |
| `LEGAL_ENTITY_ALLOCATION_LINE` | Legal entity allocation |
| `PAYOUT_CANDIDATE` | Payout candidate |
| `PAYOUT_VERIFICATION` | Payout verification reference |
| `RECONCILIATION_CASE` | Mismatch/reconciliation case |
| `SETTLEMENT_AMENDMENT` | Reviewed correction/amendment |

Settlement objects are financial records.

They require strict authority and evidence.

---

## 6. Settlement State Skeleton

Recommended settlement states:

| State | Meaning |
|---|---|
| `SETTLEMENT_NOT_STARTED` | Settlement not started |
| `SETTLEMENT_CANDIDATE_CREATED` | Candidate created |
| `SETTLEMENT_PROVIDER_REPORT_RECEIVED` | Provider report received |
| `SETTLEMENT_MATCHING_IN_PROGRESS` | Matching in progress |
| `SETTLEMENT_MATCHED` | Matched at review level |
| `SETTLEMENT_MISMATCH_DETECTED` | Mismatch detected |
| `SETTLEMENT_RECONCILIATION_REQUIRED` | Reconciliation required |
| `SETTLEMENT_IN_RECONCILIATION` | Reconciliation active |
| `SETTLEMENT_AMENDMENT_REQUIRED` | Amendment required |
| `SETTLEMENT_AMENDED` | Amendment appended |
| `SETTLEMENT_APPROVAL_REQUIRED` | Approval required |
| `SETTLEMENT_APPROVED` | Approved by authority |
| `SETTLEMENT_PAYOUT_PENDING` | Payout pending |
| `SETTLEMENT_PAYOUT_VERIFIED` | Payout verified |
| `SETTLEMENT_CLOSED` | Closed after review |
| `SETTLEMENT_UNKNOWN` | State uncertain |

These states are skeleton states only.

They do not authorize runtime.

---

## 7. Tenant Store Legal Entity Isolation Boundary

Settlement records require multi-axis isolation.

Required context may include:

- tenant id
- store id
- legal entity id
- operating group id if applicable
- brand id if applicable
- provider id
- provider profile id
- payment reference
- refund reference if applicable
- value ledger reference if applicable
- settlement period
- payout account reference if applicable
- authority reference
- evidence reference
- audit reference

A Store A settlement line must never appear in Store B settlement visibility.

A Tenant A settlement record must never appear in Tenant B visibility.

A Legal Entity A allocation must not be merged with Legal Entity B without explicit policy.

Default:

`CROSS_TENANT_ACCESS_DENIED`

Settlement must follow `10141`.

---

## 8. Payment Settlement Boundary

Payment settlement may reference:

- verified payment confirmation
- provider transaction reference
- capture amount
- currency
- provider settlement report
- settlement date
- fee amount
- net amount
- store allocation
- tenant/platform allocation
- legal entity allocation
- evidence packet

Payment confirmed is not settlement completed.

Settlement requires provider report and reconciliation.

---

## 9. Refund Settlement Adjustment Boundary

Refund settlement adjustment may reference:

- verified refund execution
- provider refund reference
- original payment reference
- refunded amount
- refund timing
- provider adjustment
- store allocation impact
- tenant/platform allocation impact
- fee reversal if applicable
- reconciliation marker

Refund executed is not settlement adjusted.

Adjustment must be explicitly recorded and reconciled.

---

## 10. Coupon Allocation Boundary

Coupon allocation may define:

- discount amount
- funded by store
- funded by tenant/HQ
- funded by brand campaign
- funded by provider/partner
- recovery-related coupon
- promotional coupon
- settlement impact
- accounting category if applicable

Coupon redeemed is not allocation settled.

Coupon cost responsibility must be explicit.

---

## 11. Point Allocation Boundary

Point allocation may define:

- point accrual liability
- point redemption value
- point reversal impact
- tenant-funded point
- store-funded point
- promotion-funded point
- recovery-funded point
- settlement impact
- liability recognition if applicable

Expected points are not liability by themselves.

Point movement must be ledger-derived and settlement-aware.

---

## 12. Wallet And Stored Value Allocation Boundary

Wallet/stored value allocation may define:

- prepaid liability
- wallet credit source
- wallet debit usage
- stored value usage
- recovery credit usage
- subscription credit usage
- liability release
- revenue recognition candidate
- settlement impact

Wallet balance is not settlement truth.

Stored value requires legal and financial classification.

---

## 13. Provider Fee Allocation Boundary

Provider fees may include:

- payment processing fee
- POS provider fee
- delivery platform fee
- channel commission
- refund fee
- chargeback fee if applicable
- service fee
- integration provider fee

Provider fee report is not automatically internal truth.

Fee allocation must be reconciled and scoped.

---

## 14. Delivery And Channel Allocation Boundary

External channels may affect settlement.

Channel allocation may include:

- delivery app order amount
- channel commission
- promotion cost
- delivery fee
- customer-paid fee
- store-borne fee
- platform-borne fee
- provider adjustment
- cancellation/refund impact

External channel report must be treated as provider evidence until reconciled.

---

## 15. Store Revenue Allocation Boundary

Store revenue allocation may define:

- gross sales
- net sales
- discount impact
- refund impact
- coupon/point/wallet impact
- provider fees
- delivery/channel fees
- tax/reference if applicable
- payout candidate
- owner/admin visibility

Store revenue visible is not payout executed.

Store revenue allocation must be scoped to store and tenant.

---

## 16. Tenant Platform Allocation Boundary

Tenant/platform allocation may define:

- platform fee
- SaaS subscription fee if applicable
- transaction fee if applicable
- HQ campaign cost
- tenant-funded recovery cost
- brand-level allocation
- franchise royalty if later authorized
- service fee allocation

Tenant/platform allocation must not leak across tenants.

Platform-level reports require masking and aggregation policy.

---

## 17. Legal Entity Allocation Boundary

Legal entity allocation may be required for:

- settlement ownership
- tax/accounting basis
- payout account
- contract party
- franchise operator
- operating company
- store-owning company
- HQ company

Legal entity is not always the same as store, tenant, or operating group.

Settlement must respect legal entity context.

---

## 18. Operating Group Allocation Boundary

Operating group allocation may support operational reporting.

Operating group allocation must not override legal entity allocation.

Operating group is operational grouping.

Legal entity is financial/legal ownership context.

Both may be needed in settlement records.

---

## 19. Payout Candidate Boundary

Payout candidate may be created after settlement matching and approval.

Payout candidate should define:

- tenant id
- store id if applicable
- legal entity id
- payout account reference
- settlement period
- gross amount
- adjustments
- fees
- net amount
- approval status
- evidence reference
- audit reference

Payout candidate is not payout executed.

Payout execution requires separate verification.

---

## 20. Payout Verification Boundary

Payout verification may require:

- bank/payout provider reference
- payout amount
- payout date
- account reference
- settlement candidate reference
- legal entity match
- provider confirmation
- reconciliation result
- evidence packet

Payout provider confirmation is evidence.

It must be matched and scoped before becoming payout verified.

---

## 21. Reconciliation Mismatch Boundary

Reconciliation mismatch may occur when:

- provider report differs from internal payment
- refund report differs from refund ledger
- coupon cost allocation missing
- point/wallet ledger mismatch
- settlement fee mismatch
- payout amount mismatch
- legal entity mismatch
- store mapping mismatch
- delayed provider report
- duplicate provider record
- manual fallback affects payment/order state
- incident/recovery action changes value

Mismatch must not be silently corrected.

Mismatch must open reconciliation case.

---

## 22. Reconciliation Case Boundary

Reconciliation case should include:

- tenant id
- store id if applicable
- legal entity id if applicable
- provider reference
- settlement period
- mismatch category
- internal amount
- provider amount
- difference amount
- related payment/refund/value references
- evidence packet
- reviewer
- required action
- audit reference

Reconciliation case is review.

It is not correction by itself.

---

## 23. Amendment Boundary

Settlement amendment must be append-only.

Amendment should record:

- original settlement reference
- amendment reason
- before value
- after value
- reviewer/approver
- evidence reference
- effective period
- audit reference

Amendment must not overwrite original settlement silently.

Correction is not mutation without trace.

---

## 24. Settlement Evidence Boundary

Settlement evidence may include:

- verified payment references
- refund references
- value ledger references
- provider settlement report
- fee report
- delivery/channel report
- payout report
- reconciliation case
- amendment record
- approval record
- export record
- audit event

Settlement evidence is high-risk.

It must be masked, scoped, and access-controlled.

---

## 25. Customer-Safe Settlement Projection Boundary

Settlement details are generally not customer-facing.

Customer-safe projection may only show value-relevant verified states such as:

- payment completed
- refund completed
- coupon applied
- points updated
- wallet updated

Customer-facing surfaces must not show:

- store settlement
- provider fees
- payout status
- legal entity allocation
- platform allocation
- internal reconciliation
- financial export detail
- settlement dispute
- cross-tenant/store information

Settlement is mostly admin/finance visibility.

---

## 26. Owner/Admin Visibility Boundary

Owner/Admin may see scoped settlement summaries if authorized.

Owner/Admin visibility may include:

- store sales summary
- refund adjustment summary
- coupon/point/wallet impact summary
- provider fee summary
- net payout candidate
- reconciliation status
- payout verification status

Owner/Admin must not see unrelated tenant/store records.

Visibility is not settlement approval unless authority policy allows it.

---

## 27. Finance Admin Visibility Boundary

Finance Admin may see broader financial details if authorized.

Finance Admin visibility may include:

- settlement lines
- provider reports
- fee allocation
- refund adjustment
- value ledger impact
- legal entity allocation
- reconciliation cases
- amendments
- payout records
- export records

Finance Admin access must be role-scoped, purpose-scoped, masked where needed, and audited.

---

## 28. Export Boundary

Settlement export is high-risk.

Export must define:

- tenant scope
- store scope
- legal entity scope
- settlement period
- data class
- requester
- role
- purpose
- masking requirement
- approval requirement
- audit reference
- expiration if applicable

Export must fail closed when scope is ambiguous.

Export must not include hidden cross-tenant rows.

---

## 29. Relationship To Payment Confirmation Room

Payment Confirmation provides verified payment state.

Settlement consumes verified payment references.

Payment confirmation is not settlement.

Settlement requires allocation, provider report matching, and reconciliation.

---

## 30. Relationship To Refund Cancellation Void Room

Refund Room provides verified reversal state.

Settlement consumes refund references and adjusts settlement lines.

Refund executed is not settlement adjusted.

Settlement adjustment requires explicit settlement line handling.

---

## 31. Relationship To Coupon Point Wallet Stored Value Room

Value Room provides ledger entries.

Settlement consumes value ledger references for allocation.

Value movement is not settlement by itself.

Settlement determines financial allocation impact.

---

## 32. Relationship To Compensation Recovery Value Room

Compensation may create refund, coupon, point, wallet, replacement, or other value action.

Settlement must reflect executed compensation value where applicable.

Compensation approval is not settlement adjustment.

Executed value action feeds settlement only through verified evidence.

---

## 33. Relationship To Store Runtime

Store Runtime may show safe owner/admin summaries if authorized.

Store Runtime must not:

- calculate final settlement truth
- approve payout
- mutate settlement
- hide reconciliation mismatch
- infer settlement from fulfillment
- infer settlement from POS/KDS
- expose settlement to unauthorized staff/customer

Store Runtime consumes safe financial projections only.

---

## 34. Relationship To Data Governance

Settlement Room uses Side D for:

- masking policy
- export governance
- retention policy
- finance/admin visibility policy
- i18n admin messages
- analytics/read model governance
- AI summary restrictions if later authorized
- pgvector source restrictions if later authorized
- compliance/legal review categories

Data Governance supports policy and visibility.

Settlement Room owns settlement truth.

---

## 35. Settlement Anti-Patterns

Avoid:

- payment confirmed treated as settlement completed
- refund executed treated as settlement adjusted
- coupon redeemed treated as cost allocated
- wallet used treated as revenue recognized without rule
- provider report accepted as internal truth
- payout candidate treated as payout executed
- payout provider message accepted without scope verification
- reconciliation mismatch silently corrected
- amendment overwriting original settlement
- owner/admin visibility treated as approval authority
- settlement export without scope
- legal entity ignored
- operating group overriding legal entity
- AI deciding settlement correction
- pgvector similarity treated as reconciliation proof

These anti-patterns must be blocked in future runtime design.

---

## 36. Runtime Deferral

This document defines the Settlement, Allocation, and Reconciliation Room boundary only.

It does not authorize:

- settlement engine
- allocation engine
- payout engine
- reconciliation engine
- amendment workflow
- provider settlement import
- bank/payout integration
- financial export
- database schema
- AI runtime
- pgvector runtime
- production deployment

All runtime remains deferred.

---

## 37. Validation Checklist

Validation must confirm:

1. Settlement/Allocation/Reconciliation Room definition is clear.
2. Settlement is not payment confirmation.
3. Settlement object catalog is defined.
4. State skeleton is defined.
5. Tenant/store/legal entity isolation is defined.
6. Payment settlement boundary is defined.
7. Refund adjustment boundary is defined.
8. Coupon allocation boundary is defined.
9. Point allocation boundary is defined.
10. Wallet/stored value allocation boundary is defined.
11. Provider fee allocation boundary is defined.
12. Delivery/channel allocation boundary is defined.
13. Store revenue allocation boundary is defined.
14. Tenant/platform allocation boundary is defined.
15. Legal entity allocation boundary is defined.
16. Operating group allocation boundary is defined.
17. Payout candidate boundary is defined.
18. Payout verification boundary is defined.
19. Reconciliation mismatch boundary is defined.
20. Reconciliation case boundary is defined.
21. Amendment boundary is defined.
22. Settlement evidence boundary is defined.
23. Projection/visibility boundaries are defined.
24. Export boundary is defined.
25. Relationships to Financial Trust rooms are defined.
26. Relationship to Store Runtime is defined.
27. Relationship to Data Governance is defined.
28. Anti-patterns are listed.
29. Coding remains unauthorized.
30. Runtime remains deferred.

---

## 38. Relationship To Previous Documents

This document follows:

- `10440 Coupon Point Wallet And Stored Value Boundary Policy`

It references:

- `10141 SaaS Tenant Isolation And Cross-Tenant Data Containment Beam Policy`
- `10350 Store Runtime Room Framing Closure And Next Axis Handoff Policy`
- `10400 Financial Trust Room Framing And Domain Boundary Index`
- `10420 Payment Confirmation And Provider Callback Boundary Policy`
- `10430 Refund Cancellation And Void Boundary Policy`
- `10440 Coupon Point Wallet And Stored Value Boundary Policy`

It prepares:

- `10460 Compensation And Customer Recovery Value Boundary Policy`
- `10470 Financial Evidence Audit And Export Boundary Policy`
- `10480 Financial Trust Closure And Data Governance Handoff Policy`

This document is room boundary planning only.

It does not authorize coding.

---

## 39. Final Rule

The Settlement, Allocation, and Reconciliation Room governs financial finalization, allocation, payout candidates, provider report matching, mismatch review, and amendment traceability.

Payment confirmed is not settlement completed.

Refund executed is not settlement adjusted.

Coupon redeemed is not cost allocated.

Wallet used is not revenue recognized without rule.

Provider report is not internal truth by itself.

Payout candidate is not payout executed.

Reconciliation mismatch is not correction.

Correction is not silent overwrite.

Settlement must preserve tenant/store/legal entity isolation, provider reconciliation, value ledger references, fee allocation, payout verification, evidence, audit, amendment traceability, masking, export control, Store Runtime separation, and Data Governance handoff.

Runtime implementation remains deferred until a separate explicit authorization packet is approved.