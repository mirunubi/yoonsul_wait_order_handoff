# 14089_Policy_Multi_Store_Revenue_Recognition_Billing_Audit

## 1. Purpose

This document defines the multi-store SaaS revenue recognition boundary, deferred revenue consideration, billing audit evidence, provider pass-through separation, support fee evidence, setup fee boundary, hardware fee boundary, discount and credit traceability, billing adjustment evidence, and finance-readiness governance policy for the Yoonsul Wait/Order Handoff documentation project.

The previous document defined renewal forecast, revenue risk, and expansion pipeline governance.

This document defines how billing and revenue-related records should remain auditable as SaaS customers, stores, modules, provider costs, support tiers, discounts, and amendments grow.

This document does not provide legal, tax, or accounting advice.

This document does not implement accounting software, ERP integration, invoice automation, tax calculation, payment collection, or revenue recognition logic.

It defines billing and revenue evidence boundary policy only.

---

## 2. Scope

This document covers:

- SaaS revenue boundary
- provider pass-through boundary
- setup and onboarding fee boundary
- support fee boundary
- hardware fee boundary
- discount and credit evidence
- billing adjustment evidence
- deferred revenue consideration
- invoice audit evidence
- revenue risk evidence
- multi-store billing audit trail
- no-accounting-implementation boundary

This document does not cover:

- final accounting standards interpretation
- final tax treatment
- final statutory reporting
- final ERP posting rules
- final revenue recognition automation
- final payment collection workflow
- final financial statement preparation
- final external audit process
- final legal contract clause drafting

---

## 3. Core Principle

Revenue records must be traceable to delivered scope and billing evidence.

The project must follow this rule:

> SaaS revenue, provider pass-through cost, hardware cost, setup fee, support fee, discount, credit, adjustment, deferred amount, and commercial amendment must be separately traceable so that revenue growth does not hide billing confusion, unsupported scope, or unearned operational claims.

Revenue credibility depends on evidence.

---

## 4. Revenue Boundary Meaning

Revenue boundary means defining whether a billed item belongs to:

- Yoonsul SaaS fee
- Yoonsul support fee
- setup/onboarding fee
- training fee
- provider gateway fee
- provider pass-through cost
- payment provider fee
- hardware sale or rental fee
- installation fee
- discount
- credit
- billing adjustment
- deferred or future-period amount
- non-billable pilot evidence contribution

Every billing line should have a boundary.

---

## 5. Revenue Category Values

Recommended revenue category values:

- `SAAS_SUBSCRIPTION_REVENUE`
- `STORE_OS_REVENUE`
- `MINI_KIOSK_REVENUE`
- `KDS_HANDOFF_REVENUE`
- `PROVIDER_GATEWAY_REVENUE`
- `SUPPORT_SERVICE_REVENUE`
- `SETUP_ONBOARDING_REVENUE`
- `TRAINING_REVENUE`
- `REPORT_EXPORT_REVENUE`
- `HARDWARE_REVENUE`
- `HARDWARE_RENTAL_REVENUE`
- `PROVIDER_PASS_THROUGH`
- `PAYMENT_PROVIDER_PASS_THROUGH`
- `DISCOUNT`
- `PILOT_CREDIT`
- `SERVICE_CREDIT`
- `BILLING_ADJUSTMENT`
- `DEFERRED_REVENUE_PLACEHOLDER`
- `NON_BILLABLE`

Final accounting categories may be changed by finance/legal/accounting review.

---

## 6. Billing Line Revenue Boundary Fields

Each billing line should record:

- line item id
- invoice or billing record id
- customer/tenant
- store or HQ scope
- revenue category
- operational module
- billing period
- service period
- amount
- discount or credit reference
- provider pass-through indicator
- hardware indicator
- setup/onboarding indicator
- support tier reference
- amendment reference
- activation evidence
- delivery evidence
- reviewer
- notes

Line item must explain why it exists.

---

## 7. Billing Line ID Format

Recommended format:

    BILLING-LINE-[BILLING-RECORD-ID]-[NUMBER]

Example:

    BILLING-LINE-BILLING-RECORD-CUST001-202606-001

Final format may be normalized later.

---

## 8. SaaS Subscription Revenue Boundary

SaaS subscription revenue should be tied to:

- active subscription period
- enabled package
- enabled modules
- store or HQ scope
- customer acknowledgement
- billing period
- commercial amendment if changed
- limitation disclosure
- service availability expectation
- deactivation or pause record if any

Do not treat inactive or unsafe module as normal subscription revenue without review.

---

## 9. Module Revenue Boundary

Module revenue should be tied to module activation.

Examples:

| Module | Evidence Needed |
| ------ | --------------- |
| Mini Kiosk | activation, customer session capability, support path |
| KDS Handoff | KDS handoff enabled, safety guard, fallback path |
| Provider Gateway | provider adapter scope, validation evidence |
| Store OS | store operational dashboard or workflow scope |
| Support Add-On | support tier and case scope |
| Export/Report | approved export/report scope |

A module should not be billed as active if it is not safely enabled.

---

## 10. Provider Gateway Revenue Boundary

Provider Gateway revenue may be recognized as Yoonsul service revenue only when it is Yoonsul’s operational service layer.

Provider Gateway revenue may cover:

- provider event validation
- mapping maintenance
- idempotency handling
- webhook/callback control
- provider evidence capture
- provider incident support coordination
- provider adapter maintenance
- provider stack monitoring

Provider Gateway revenue is separate from provider pass-through cost.

---

## 11. Provider Pass-Through Boundary

Provider pass-through means cost charged by or for an external provider.

Examples:

- POS subscription fee
- payment provider fee
- KDS provider fee
- kiosk provider fee
- local daemon fee
- dealer support fee
- provider setup fee
- provider API usage fee
- notification/SMS provider fee

Provider pass-through should be disclosed separately where possible.

Do not present provider pass-through as pure Yoonsul SaaS value.

---

## 12. Payment Provider Pass-Through Boundary

Payment provider pass-through may include:

- transaction fee
- payment service fee
- refund fee
- cancel fee
- settlement-related fee
- gateway fee
- payment terminal fee
- payment account fee

Payment provider fee must not obscure payment truth.

Payment fee billing must not incentivize unsafe payment flow.

---

## 13. Support Service Revenue Boundary

Support service revenue should be tied to:

- support tier
- support hours
- support scope
- support case volume expectation
- provider support coordination
- payment/KDS recovery support
- onboarding support
- premium support if any
- after-hours support if any

Support service revenue should reflect actual support obligation.

Underpriced support creates hidden operational debt.

---

## 14. Setup Onboarding Revenue Boundary

Setup/onboarding revenue may cover:

- tenant/store setup
- provider stack review
- payment path setup
- KDS handoff setup
- Mini Kiosk configuration
- staff training preparation
- evidence packet preparation
- pilot readiness review
- initial dashboard configuration
- support playbook setup

Setup fee should be linked to setup completion evidence.

---

## 15. Training Revenue Boundary

Training revenue may cover:

- initial staff training
- new store training
- new module training
- KDS workflow training
- provider change training
- support escalation training
- manual fallback training
- franchise rollout training

Training revenue should not hide product usability failures.

Repeated training caused by unclear product should be reviewed separately.

---

## 16. Hardware Revenue Boundary

Hardware revenue should identify:

- hardware type
- sale or rental
- ownership
- installation status
- device trust registration
- maintenance responsibility
- replacement responsibility
- return rule
- loss/damage responsibility
- provider dependency

Hardware revenue must not be confused with software subscription revenue.

---

## 17. Hardware Rental Boundary

Hardware rental should define:

- rental period
- device list
- monthly fee
- ownership remains with provider/Yoonsul/vendor
- return condition
- damage condition
- replacement condition
- device trust revocation
- subscription dependency if any

Rental revenue may differ from hardware sale.

Final accounting treatment requires finance review.

---

## 18. Discount Boundary

Discount must be recorded as separate commercial decision.

Discount evidence should include:

- discount id
- reason
- affected line item
- amount or percentage
- start date
- end date
- standard price reference
- approver
- customer acknowledgement
- renewal effect
- expiration notice

Discount should not silently rewrite standard price.

---

## 19. Credit Boundary

Credit may include:

- pilot credit
- service credit
- incident credit
- billing correction credit
- goodwill credit
- provider incident credit
- support delay credit

Credit evidence should include:

- credit id
- reason
- affected billing period
- affected line item
- amount
- expiration if any
- approval
- customer communication
- linked incident if any

Credit must be traceable.

---

## 20. Pilot Credit Boundary

Pilot credit should be tied to:

- pilot participation
- early adopter risk
- limited scope
- evidence contribution
- instability compensation if applicable
- conversion agreement
- fixed duration
- standard price reference

Pilot credit is not a permanent discount.

---

## 21. Service Credit Boundary

Service credit may be considered when:

- Yoonsul-controlled outage reduced value
- support delay caused impact
- enabled module was unavailable
- provider incident was not disclosed properly
- billing scope was unclear
- customer experienced documented operational disruption

Service credit requires evidence.

Credit must not replace root-cause correction.

---

## 22. Billing Adjustment Boundary

Billing adjustment may occur when:

- wrong module was billed
- wrong store was billed
- discount was omitted
- credit was omitted
- provider pass-through was misclassified
- support tier was misapplied
- hardware charge was incorrect
- effective date was wrong
- proration was wrong

Adjustment must preserve original and adjusted values.

---

## 23. Deferred Revenue Consideration

Deferred revenue consideration may apply when:

- payment is received before service period
- annual or multi-month subscription is prepaid
- setup/service delivery is not yet complete
- module activation is pending
- customer pays before store launch
- hardware delivery is pending
- provider integration is pending
- support period has not yet occurred

Final accounting treatment requires professional review.

This policy only requires evidence separation.

---

## 24. Deferred Revenue Placeholder Fields

If deferred revenue tracking is needed later, recommended fields include:

- deferred record id
- billing record id
- customer/tenant
- amount
- related line item
- service period start
- service period end
- recognition trigger placeholder
- delivery evidence
- activation evidence
- status
- reviewer
- notes

This document does not define final accounting recognition rule.

---

## 25. Deferred Record ID Format

Recommended format:

    DEFERRED-REVENUE-[CUSTOMER]-[YYYYMM]-[NUMBER]

Example:

    DEFERRED-REVENUE-CUST001-202606-001

Final format may be normalized later.

---

## 26. Revenue Evidence Packet

Revenue evidence packet should include:

- billing record
- billing line items
- customer acknowledgement
- enabled module evidence
- service period
- package scope
- support tier
- provider pass-through evidence
- hardware evidence
- discount/credit evidence
- amendment evidence
- activation/deactivation evidence
- limitation disclosure
- dispute or adjustment record if any

Revenue evidence protects finance and customer trust.

---

## 27. Revenue Evidence Packet ID Format

Recommended format:

    REVENUE-EVIDENCE-[CUSTOMER]-[YYYYMM]

Example:

    REVENUE-EVIDENCE-CUST001-202606

Final format may be normalized later.

---

## 28. Multi-Store Revenue Allocation Rule

For multi-store customers, revenue allocation should define:

- store-level subscription amount
- HQ-level amount
- shared module amount
- shared support amount
- provider gateway amount
- provider pass-through by store
- hardware by store
- setup/training by store
- discount by store or group
- credit by store or group

Allocation should be understandable to customer and reviewer.

---

## 29. Store Add Revenue Boundary

When adding a store, revenue evidence should include:

- store add amendment
- onboarding date
- activation date
- billing effective date
- module scope
- provider stack
- setup/training fee
- hardware fee
- support tier impact
- proration if any

Store add revenue must follow activation and agreement evidence.

---

## 30. Store Remove Revenue Boundary

When removing a store, revenue evidence should include:

- store remove amendment
- deactivation date
- billing stop date
- module shutdown evidence
- provider cost stop or continuation
- hardware return or ownership decision
- data retention/export status
- credit or adjustment if any

Store removal must preserve audit lineage.

---

## 31. Module Activation Revenue Boundary

A module may become revenue-active only when:

- module scope is agreed
- module is safely enabled
- customer understands limitations
- support path exists
- rollback path exists
- billing start condition is met
- activation evidence exists

Do not recognize revenue for a module that is only promised.

---

## 32. Module Pause Revenue Boundary

When module is paused:

- pause reason must be recorded
- customer impact must be reviewed
- billing impact must be reviewed
- credit or adjustment must be considered
- support path must be updated
- reactivation condition must be defined
- evidence must be preserved

Paused module is not normal active scope.

---

## 33. Provider Incident Revenue Impact Review

Provider incident may affect revenue evidence when:

- provider-dependent module was unavailable
- provider limitation reduced value
- support burden increased
- customer requested credit
- renewal risk increased
- paid conversion promise changed
- module scope was temporarily reduced
- workaround replaced normal service

Provider incident does not automatically reduce revenue.

But it must be reviewed.

---

## 34. Support Overload Revenue Impact Review

Support overload may affect revenue when:

- support tier is underpriced
- support delivery failed expectation
- support cases delayed customer recovery
- support burden exceeds package assumption
- expansion should pause
- pricing model needs revision
- customer requests discount or credit

Support overload is both operational and commercial signal.

---

## 35. Billing Dispute Revenue Impact Review

Billing dispute may affect:

- invoice amount
- revenue category
- discount
- credit
- provider pass-through classification
- module activation date
- support tier fee
- hardware fee
- renewal forecast
- churn risk

Dispute must be linked to evidence.

---

## 36. Revenue Risk Linkage

Revenue evidence should link to revenue risk when:

- churn risk exists
- downgrade risk exists
- discount extension risk exists
- billing dispute exists
- provider cost risk exists
- support cost risk exists
- unpaid invoice exists
- scope mismatch exists
- module deactivation risk exists

Revenue risk should not be separated from billing evidence.

---

## 37. Finance Review Trigger

Finance or commercial review is required when:

- billing category changes
- provider pass-through classification changes
- hardware sale/rental boundary changes
- prepaid period exists
- large discount is applied
- service credit is issued
- billing dispute is significant
- multi-store allocation is unclear
- customer requests special invoice treatment
- accounting treatment is uncertain

Operational team should not guess accounting treatment.

---

## 38. Audit Trail Rule

Revenue-related records must preserve:

- original invoice/billing record
- amendment
- line item
- discount/credit
- adjustment
- customer acknowledgement
- activation evidence
- delivery evidence
- dispute evidence
- reviewer decision
- final outcome

Audit trail must be append-only or append-only-equivalent.

---

## 39. Revenue Evidence Status Values

Recommended status values:

- `REVENUE_EVIDENCE_NOT_STARTED`
- `REVENUE_EVIDENCE_DRAFT`
- `REVENUE_EVIDENCE_REVIEW_REQUIRED`
- `REVENUE_EVIDENCE_COMPLETE`
- `REVENUE_EVIDENCE_MINOR_GAP`
- `REVENUE_EVIDENCE_MAJOR_GAP`
- `REVENUE_EVIDENCE_DISPUTED`
- `REVENUE_EVIDENCE_ADJUSTED`
- `REVENUE_EVIDENCE_CLOSED`

Revenue evidence status should be visible.

---

## 40. Registers Recommendation

Recommended future files:

    docs/_index/
      Revenue_Boundary_Register.md
      Billing_Line_Revenue_Category_Register.md
      Provider_Pass_Through_Register.md
      Discount_Credit_Evidence_Register.md
      Deferred_Revenue_Placeholder_Register.md
      Revenue_Evidence_Packet_Register.md
      Revenue_Adjustment_Audit_Register.md
      Revenue_Risk_Linkage_Register.md

This document only recommends these files.

It does not create them.

---

## 41. Anti-Patterns

The following are prohibited:

- mixing provider pass-through with SaaS revenue without disclosure
- treating prepaid amount as delivered service without evidence
- billing promised module as active module
- hiding discount as new standard price
- issuing credit without reason
- adjusting invoice without preserving original value
- ignoring provider incident revenue impact
- ignoring support overload revenue impact
- recognizing hardware and SaaS as same category without review
- billing paused module as normal active module
- closing billing dispute without evidence
- relying on chat memory for commercial evidence
- letting revenue forecast ignore billing audit trail

---

## 42. Non-Goals

This document does not define:

- final accounting policy
- final revenue recognition method
- final tax treatment
- final ERP journal entries
- final audited financial statement process
- final invoice automation
- final payment collection system
- final legal contract terms

Those belong to later finance, accounting, legal, and ERP planning.

---

## 43. Readiness Check

This document is ready when the project can answer:

1. What does revenue boundary mean?
2. What revenue category values exist?
3. What fields should billing line record include?
4. How is SaaS subscription revenue bounded?
5. How is module revenue bounded?
6. How is Provider Gateway revenue bounded?
7. What is provider pass-through boundary?
8. What is payment provider pass-through boundary?
9. How is support service revenue bounded?
10. How is setup/onboarding revenue bounded?
11. How is training revenue bounded?
12. How is hardware revenue bounded?
13. How is hardware rental bounded?
14. How is discount bounded?
15. How is credit bounded?
16. How is pilot credit bounded?
17. When may service credit apply?
18. What is billing adjustment boundary?
19. When may deferred revenue consideration apply?
20. What fields may deferred placeholder include?
21. What should revenue evidence packet include?
22. How is multi-store revenue allocated?
23. How is store add revenue bounded?
24. How is store remove revenue bounded?
25. When may module become revenue-active?
26. How is paused module revenue handled?
27. How does provider incident affect revenue review?
28. How does support overload affect revenue review?
29. How does billing dispute affect revenue review?
30. How is revenue risk linked?
31. When is finance review triggered?
32. What audit trail rule applies?
33. What revenue evidence status values exist?
34. What anti-patterns are prohibited?

If these questions cannot be answered, revenue recognition boundary, deferred revenue, and billing audit evidence planning is incomplete.

---

## 44. Conclusion

As multi-store SaaS grows, billing must remain commercially clear and auditable.

The safe revenue evidence flow is:

    commercial scope
        -> billing line category
        -> provider/support/hardware separation
        -> discount or credit record
        -> activation and delivery evidence
        -> deferred consideration if needed
        -> billing dispute or adjustment linkage
        -> revenue evidence packet
        -> finance review where required

This document protects the project from hidden provider costs, unclear SaaS revenue, unsupported module billing, silent discounts, undocumented credits, billing disputes, and future finance audit gaps.