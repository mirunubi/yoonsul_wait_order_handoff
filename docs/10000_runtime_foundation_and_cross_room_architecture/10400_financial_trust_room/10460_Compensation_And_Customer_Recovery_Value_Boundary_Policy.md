# 10460_Compensation_And_Customer_Recovery_Value_Boundary_Policy

## 1. Purpose

This document defines the Compensation and Customer Recovery Value Boundary Policy.

The previous artifact `10450` defined the Settlement, Allocation, and Reconciliation Boundary Policy.

This document frames the sixth Financial Trust room:

`Compensation And Customer Recovery Value Room`

The purpose is to define the boundary where customer-impact recovery candidates, goodwill actions, apology-related value, replacement value, refund-linked recovery, coupon compensation, point compensation, wallet credit, stored value recovery, manager-approved recovery, HQ-approved compensation, legal/compliance review, execution evidence, and customer-safe recovery communication are governed without being confused with incident detection, staff apology, Store Recovery Route review, fulfillment visibility, refund execution, or settlement completion.

This document is planning-only.

It does not authorize coding.

---

## 2. Room Definition

The Compensation and Customer Recovery Value Room governs value-bearing customer recovery decisions.

It may later coordinate:

- compensation candidate
- customer recovery value candidate
- recovery reason category
- compensation review
- compensation approval
- compensation rejection
- value action selection
- refund-linked compensation
- coupon compensation
- point compensation
- wallet compensation
- replacement value
- goodwill adjustment
- legal/compliance review
- execution handoff
- evidence packet
- audit reference
- customer-safe projection

Compensation review is not compensation approval.

Compensation approval is not compensation execution.

Compensation execution requires the proper Financial Trust room and verified evidence.

---

## 3. Core Principle

Customer recovery value must be authorized before execution.

The correct rule is:

Customer complaint is not compensation.  
Incident is not compensation.  
Recovery route is not compensation.  
Staff apology is not compensation approval.  
Manager sympathy is not value execution.  
KDS delay is not automatic coupon.  
Wrong item is not automatic wallet credit.  
Refund review is not compensation approval.  
Approved compensation is not executed compensation.  
AI recommendation is not compensation authority.  

Compensation must be evidence-based, authority-controlled, tenant/store scoped, customer/account scoped, auditable, value-ledger aware, and safely projected.

---

## 4. Scope

This room may define planning boundaries for:

- customer recovery value candidate
- compensation reason classification
- compensation eligibility review
- approval authority
- rejection reason
- refund-linked recovery value
- coupon compensation
- point compensation
- wallet/stored value compensation
- replacement item value
- goodwill adjustment
- legal/compliance review
- abuse/fraud review
- execution handoff
- evidence packet
- customer-safe projection
- settlement allocation impact
- tenant/store/customer isolation

This room does not implement compensation runtime.

---

## 5. Compensation Trigger Catalog

Recommended compensation trigger catalog:

| Trigger | Meaning |
|---|---|
| `SEVERE_DELAY` | Severe customer-impacting delay |
| `WRONG_ITEM` | Wrong item prepared or delivered |
| `MISSING_ITEM` | Missing item |
| `ITEM_UNAVAILABLE_AFTER_ORDER` | Item became unavailable after customer action |
| `REMAKE_FAILED` | Remake failed or caused material impact |
| `SUBSTITUTION_FAILURE` | Substitution caused impact |
| `PAYMENT_CONFUSION` | Payment confusion affected customer |
| `DUPLICATE_PAYMENT_RISK` | Duplicate payment risk affected customer |
| `MANUAL_FALLBACK_CONFUSION` | Manual fallback confused customer |
| `DEGRADED_OPERATION_IMPACT` | Degraded operation caused impact |
| `STAFF_SERVICE_FAILURE` | Staff/service failure requires review |
| `ALLERGEN_SAFETY_CONCERN` | Safety/allergen concern requires review |
| `SUPPORT_ESCALATION` | Support escalation requires recovery review |
| `LEGAL_COMPLIANCE_REVIEW` | Legal/compliance review required |

Trigger is not approval.

Trigger only opens review.

---

## 6. Compensation State Skeleton

Recommended compensation states:

| State | Meaning |
|---|---|
| `COMPENSATION_NOT_REQUIRED` | No compensation required |
| `COMPENSATION_CANDIDATE` | Candidate detected |
| `COMPENSATION_REVIEW_REQUIRED` | Review required |
| `COMPENSATION_IN_REVIEW` | Review in progress |
| `COMPENSATION_EVIDENCE_REQUIRED` | Evidence required |
| `COMPENSATION_MANAGER_REVIEW_REQUIRED` | Manager review required |
| `COMPENSATION_HQ_REVIEW_REQUIRED` | HQ review required |
| `COMPENSATION_LEGAL_REVIEW_REQUIRED` | Legal/compliance review required |
| `COMPENSATION_APPROVAL_REQUIRED` | Approval required |
| `COMPENSATION_APPROVED` | Approved by authority |
| `COMPENSATION_REJECTED` | Rejected after review |
| `COMPENSATION_EXECUTION_PENDING` | Execution pending in value room |
| `COMPENSATION_EXECUTED_VERIFIED` | Execution verified |
| `COMPENSATION_CUSTOMER_NOTIFIED` | Customer notified |
| `COMPENSATION_CLOSED` | Closed after review |
| `COMPENSATION_REOPENED` | Reopened due to new evidence |
| `COMPENSATION_UNKNOWN` | State uncertain |

These states are skeleton states only.

They do not authorize runtime.

---

## 7. Tenant Store Customer Isolation Boundary

Every compensation record must be scoped.

Required scope may include:

- tenant id
- store id
- customer/account id
- order reference if applicable
- incident reference if applicable
- recovery route reference
- evidence packet reference
- approved value action
- approval authority
- execution reference
- audit reference

A Store A compensation case must never appear in Store B visibility.

A Tenant A compensation case must never appear in Tenant B visibility.

A customer value action must never be applied to the wrong customer/account.

Default:

`CROSS_TENANT_ACCESS_DENIED`

Compensation Room must follow `10141`.

---

## 8. Compensation Candidate Boundary

Compensation candidate may be created from:

- Store Recovery Route
- Store Incident Room
- Operational Evidence Room
- Fulfillment Visibility conflict
- Staff Assist unresolved case
- Manual Fallback confusion
- Payment uncertainty
- Refund review
- Support/Admin review
- Legal/compliance review

Compensation candidate is not compensation approval.

Candidate must be evidence-linked and reviewed.

---

## 9. Evidence Requirement Boundary

Compensation review must link evidence.

Evidence may include:

- order intake record
- validation record
- POS handoff record
- KDS ticket record
- kitchen execution record
- payment confirmation record
- refund/cancellation record
- value ledger record if applicable
- manual fallback record
- incident record
- recovery route record
- staff note
- customer communication record
- audit event

Evidence supports review.

Evidence is not approval.

---

## 10. Authority Boundary

Compensation authority must be explicit.

Possible authority levels:

| Authority | Example Boundary |
|---|---|
| `STAFF_RECOMMEND_ONLY` | Staff may recommend, not approve value |
| `SHIFT_LEAD_LIMITED_REVIEW` | Shift lead may review minor cases if policy allows |
| `MANAGER_APPROVAL_LIMITED` | Manager may approve limited recovery value |
| `OWNER_APPROVAL` | Owner may approve store-level value |
| `HQ_APPROVAL` | HQ may approve broader or policy-sensitive compensation |
| `FINANCE_APPROVAL` | Finance approves financial/value execution |
| `LEGAL_COMPLIANCE_REVIEW` | Legal/compliance reviews sensitive cases |

Authority must be amount-limited, scope-limited, and auditable.

---

## 11. Value Action Catalog

Possible value actions:

| Action | Meaning |
|---|---|
| `NO_VALUE_ACTION` | No value action after review |
| `APOLOGY_ONLY` | Non-value customer communication |
| `REMAKE_OR_REPLACE_ITEM` | Operational service correction |
| `REFUND_REVIEW` | Refund route candidate |
| `COUPON_COMPENSATION` | Coupon value action |
| `POINT_COMPENSATION` | Point value action |
| `WALLET_CREDIT_COMPENSATION` | Wallet/stored value credit |
| `PREPAID_VALUE_COMPENSATION` | Stored value compensation |
| `SUBSCRIPTION_CREDIT_COMPENSATION` | Subscription credit |
| `MANUAL_GOODWILL_REVIEW` | Exceptional goodwill review |
| `LEGAL_COMPLIANCE_ROUTE` | Sensitive route requiring review |

Value action selection is not execution.

Execution belongs to the proper Financial Trust room.

---

## 12. Refund-Linked Compensation Boundary

Refund-linked compensation may occur when:

- refund is the chosen recovery action
- refund plus additional value is considered
- duplicate payment requires refund review
- payment confusion caused customer impact
- legal/compliance requires payment reversal review

Refund-linked compensation must route to:

`10430 Refund Cancellation And Void Boundary Policy`

Compensation Room may approve or propose value recovery.

Refund Room executes refund only under refund authority.

---

## 13. Coupon Compensation Boundary

Coupon compensation requires:

- approved compensation action
- coupon template
- customer/account scope
- tenant/store scope
- validity period
- usage rule
- idempotency key
- evidence reference
- audit reference

Coupon compensation must route to:

`10440 Coupon Point Wallet And Stored Value Boundary Policy`

Approved compensation is not coupon issued until value ledger confirms issuance.

---

## 14. Point Compensation Boundary

Point compensation requires:

- approved compensation action
- point amount
- customer/account scope
- reason category
- authority reference
- evidence reference
- idempotency key
- audit reference

Point compensation must not be performed from Staff Assist or Store Runtime.

Point movement requires value ledger.

---

## 15. Wallet And Stored Value Compensation Boundary

Wallet/stored value compensation is high-risk.

It requires:

- approved compensation action
- monetary amount or stored value unit
- customer/account scope
- legal/compliance compatibility
- refund interaction check
- duplicate compensation check
- value ledger entry
- evidence reference
- audit reference

Wallet credit is financial value execution.

Recovery review is not wallet credit.

---

## 16. Replacement Item Boundary

Replacement item may be operational or value-bearing.

Replacement item must define:

- original item
- replacement item
- reason category
- customer confirmation if required
- kitchen execution relation
- POS/payment relation if applicable
- settlement/cost allocation impact if applicable
- evidence reference

Replacement item is not refund.

Replacement item may still require cost allocation.

---

## 17. Goodwill Adjustment Boundary

Goodwill adjustment may be exceptional.

Goodwill adjustment must require:

- explicit authority
- reason category
- amount/value limit
- customer/account scope
- evidence packet
- abuse review if repeated
- audit reference
- settlement/cost allocation review if applicable

Goodwill must not become informal staff-controlled money.

---

## 18. Abuse And Duplicate Compensation Boundary

Duplicate compensation risk may occur when:

- same incident creates multiple recovery cases
- refund and coupon both issued unintentionally
- customer repeats complaint
- staff repeats adjustment
- support/admin duplicates action
- delayed provider callback changes outcome
- incident is reopened
- recovery is reopened
- customer account mismatch occurs

Duplicate compensation must be controlled through idempotency and evidence matching.

Abuse signal is not guilt.

Review is required.

---

## 19. Customer-Safe Compensation Projection Boundary

Customer-safe projection may show:

- staff is reviewing
- support is reviewing
- recovery review is in progress
- approved action is being processed if approved
- coupon has been issued if verified
- points have been updated if verified
- wallet credit has been applied if verified
- refund has been completed if verified

Customer-safe projection must not show:

- unapproved compensation promise
- internal compensation limit
- staff blame
- provider blame
- legal conclusion
- fraud/abuse signal
- raw incident detail
- raw financial payload
- AI reasoning
- vector similarity
- cross-tenant/store information

Compensation messages must be i18n-controlled.

---

## 20. Staff/Admin Visibility Boundary

Staff/Admin visibility may include:

- compensation trigger
- customer impact category
- evidence packet
- recovery route reference
- incident reference
- proposed value action
- approval status
- execution status
- duplicate risk marker
- customer notification status

Staff/Admin visibility must not expose unrelated customer/tenant/store data.

Visibility is not approval authority.

---

## 21. Compensation Evidence Boundary

Compensation evidence may include:

- tenant id
- store id
- customer/account id
- compensation id
- trigger category
- recovery reference
- incident reference
- evidence packet reference
- proposed action
- approved action
- approval actor
- execution room reference
- execution result reference
- duplicate risk marker
- customer notification key
- audit reference

Compensation evidence is financial/value evidence.

It must be masked and access-controlled.

---

## 22. Execution Handoff Boundary

Compensation execution must be handed to the correct room:

| Compensation Type | Execution Room |
|---|---|
| Refund | Refund/Cancellation/Void Room |
| Coupon | Coupon/Point/Wallet/Stored Value Room |
| Point | Coupon/Point/Wallet/Stored Value Room |
| Wallet Credit | Coupon/Point/Wallet/Stored Value Room |
| Stored Value | Coupon/Point/Wallet/Stored Value Room |
| Replacement Item | Store Runtime/Kitchen with cost evidence |
| Settlement Adjustment | Settlement/Reconciliation Room |
| Legal/Compliance | Legal/Compliance review route |

Compensation Room approves or routes.

It does not directly mutate value unless future policy explicitly merges execution authority.

---

## 23. Settlement Impact Boundary

Compensation may affect settlement.

Settlement impact may include:

- store-funded recovery cost
- HQ-funded recovery cost
- platform-funded goodwill
- coupon cost allocation
- point liability
- wallet liability
- refund adjustment
- replacement item cost
- promotional budget impact

Settlement impact must route to Settlement Room.

Compensation approval is not settlement adjustment.

---

## 24. Closure Boundary

Compensation closure may occur only when:

- review completed
- evidence linked
- approved/rejected decision recorded
- execution completed if approved
- customer notification completed if needed
- settlement impact routed if applicable
- audit trail complete
- no duplicate risk unresolved
- no legal/compliance review pending

Compensation closure is not incident closure unless incident closure also occurs.

Closure is not legal conclusion.

---

## 25. Reopen Boundary

Compensation may be reopened when:

- new evidence appears
- customer disputes outcome
- execution failed
- coupon/point/wallet issuance failed
- refund failed
- incident reopened
- recovery route reopened
- provider callback arrived late
- duplicate compensation discovered
- wrong customer/account linkage suspected

Reopen must preserve prior state.

Reopen must be append-only.

---

## 26. Relationship To Store Recovery Route Room

Store Recovery Route creates recovery candidates.

Compensation Room evaluates value-bearing recovery.

Recovery review is not compensation approval.

Recovery closure and compensation closure are separate unless explicitly linked.

---

## 27. Relationship To Refund Cancellation Void Room

Refund compensation must route to Refund/Cancellation/Void Room for execution.

Refund review is not refund execution.

Refund execution requires payment verification, refund authority, provider verification, evidence, audit, and idempotency.

---

## 28. Relationship To Coupon Point Wallet Stored Value Room

Coupon, point, wallet, stored value, subscription credit, and recovery credit compensation must route to Value Room.

Value Room owns ledger movement.

Compensation approval is not value ledger mutation.

---

## 29. Relationship To Settlement Allocation Reconciliation Room

Settlement Room consumes executed compensation value for allocation and reconciliation.

Compensation approval is not settlement adjustment.

Executed value action may create settlement impact.

---

## 30. Relationship To Store Runtime

Store Runtime may display safe compensation/recovery status.

Store Runtime must not:

- approve compensation
- execute compensation
- issue coupon
- grant points
- mutate wallet
- approve refund
- promise value action
- infer compensation from incident or delay

Store Runtime consumes safe projections only.

---

## 31. Relationship To Data Governance

Compensation Room uses Side D for:

- i18n compensation messages
- masking policy
- retention policy
- support/admin visibility
- customer-safe communication
- abuse/fraud signal governance
- AI recommendation restrictions if later authorized
- pgvector related-case restrictions if later authorized
- analytics/read model governance

Data Governance supports safe visibility.

Compensation Room owns value recovery review.

---

## 32. Compensation Anti-Patterns

Avoid:

- customer complaint treated as compensation approval
- incident treated as compensation execution
- recovery route treated as value mutation
- staff apology treated as legal admission
- manager sympathy treated as wallet credit
- KDS delay treated as automatic coupon
- wrong item treated as automatic point grant
- refund review treated as compensation approval
- approved compensation treated as executed compensation
- coupon compensation issued without value ledger
- wallet credit without financial authority
- duplicate compensation from reopened incidents
- AI deciding compensation
- pgvector similarity treated as compensation proof
- compensation record missing tenant/store/customer scope

These anti-patterns must be blocked in future runtime design.

---

## 33. Runtime Deferral

This document defines the Compensation and Customer Recovery Value Room boundary only.

It does not authorize:

- compensation workflow
- recovery value approval engine
- coupon issuance
- point adjustment
- wallet credit
- refund execution
- goodwill adjustment runtime
- abuse/fraud engine
- settlement adjustment
- database schema
- AI runtime
- pgvector runtime
- production deployment

All runtime remains deferred.

---

## 34. Validation Checklist

Validation must confirm:

1. Compensation Room definition is clear.
2. Customer recovery value requires authorization before execution.
3. Compensation trigger catalog is defined.
4. State skeleton is defined.
5. Tenant/store/customer isolation is defined.
6. Candidate boundary is defined.
7. Evidence requirement boundary is defined.
8. Authority boundary is defined.
9. Value action catalog is defined.
10. Refund-linked compensation boundary is defined.
11. Coupon compensation boundary is defined.
12. Point compensation boundary is defined.
13. Wallet/stored value compensation boundary is defined.
14. Replacement item boundary is defined.
15. Goodwill adjustment boundary is defined.
16. Abuse/duplicate compensation boundary is defined.
17. Customer-safe projection boundary is defined.
18. Staff/Admin visibility boundary is defined.
19. Compensation evidence boundary is defined.
20. Execution handoff boundary is defined.
21. Settlement impact boundary is defined.
22. Closure/reopen boundaries are defined.
23. Relationships to Financial Trust rooms are defined.
24. Relationship to Store Runtime is defined.
25. Relationship to Data Governance is defined.
26. Anti-patterns are listed.
27. Coding remains unauthorized.
28. Runtime remains deferred.

---

## 35. Relationship To Previous Documents

This document follows:

- `10450 Settlement Allocation And Reconciliation Boundary Policy`

It references:

- `10141 SaaS Tenant Isolation And Cross-Tenant Data Containment Beam Policy`
- `10340 Store Recovery Route Room Boundary Policy`
- `10350 Store Runtime Room Framing Closure And Next Axis Handoff Policy`
- `10400 Financial Trust Room Framing And Domain Boundary Index`
- `10430 Refund Cancellation And Void Boundary Policy`
- `10440 Coupon Point Wallet And Stored Value Boundary Policy`
- `10450 Settlement Allocation And Reconciliation Boundary Policy`

It prepares:

- `10470 Financial Evidence Audit And Export Boundary Policy`
- `10480 Financial Trust Closure And Data Governance Handoff Policy`

This document is room boundary planning only.

It does not authorize coding.

---

## 36. Final Rule

The Compensation and Customer Recovery Value Room governs value-bearing customer recovery review and approval.

Customer complaint is not compensation.

Incident is not compensation execution.

Recovery route is not value mutation.

Staff apology is not compensation approval.

Manager sympathy is not wallet credit.

KDS delay is not automatic coupon.

Wrong item is not automatic point grant.

Approved compensation is not executed compensation.

Compensation must preserve tenant/store/customer isolation, explicit authority, evidence, audit, idempotency, duplicate prevention, execution handoff, value ledger separation, refund separation, settlement impact routing, i18n, Safe Projection, Store Runtime separation, and Data Governance handoff.

Runtime implementation remains deferred until a separate explicit authorization packet is approved.