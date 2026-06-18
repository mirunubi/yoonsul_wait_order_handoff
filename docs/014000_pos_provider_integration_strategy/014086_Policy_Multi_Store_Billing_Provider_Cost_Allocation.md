# 014086_Policy_Multi_Store_Billing_Provider_Cost_Allocation

## 1. Purpose

This document defines the multi-store SaaS billing operations, invoice grouping, store-level fee allocation, support fee allocation, provider cost separation, hardware cost visibility, setup fee handling, discount control, and billing evidence policy for the Yoonsul Wait/Order Handoff documentation project.

The previous document defined multi-store provider incident broadcast, shared risk, and cross-store containment policy.

This document defines how billing must remain transparent when multiple stores, providers, modules, support tiers, hardware costs, and franchise or HQ responsibilities overlap.

This document does not implement billing automation, invoice generation, payment collection, accounting, tax reporting, or legal contract terms.

It defines billing operations and cost allocation policy only.

---

## 2. Scope

This document covers:

- multi-store billing boundary
- store-level invoice grouping
- HQ-level invoice grouping
- franchise billing responsibility
- provider cost separation
- support fee allocation
- hardware and setup fee visibility
- module-based billing
- discount and pilot credit control
- billing evidence
- billing dispute review
- expansion billing readiness
- no-implementation boundary

This document does not cover:

- final tax treatment
- final accounting system
- final invoice automation
- final PG payment collection
- final legal contract language
- final franchise royalty structure
- final settlement system
- final corporate accounting policy
- final external accountant workflow

---

## 3. Core Principle

Billing must not hide operational truth or provider cost.

The project must follow this rule:

> SaaS billing must clearly separate Yoonsul software fee, provider fee, payment provider fee, hardware fee, setup fee, support fee, discount, pilot credit, and franchise or HQ-paid responsibility so that stores understand what they are paying for and why.

Billing confusion creates churn.

Hidden provider cost creates distrust.

---

## 4. Multi-Store Billing Meaning

Multi-store billing means:

- more than one store may be billed under one customer relationship
- each store may have different enabled modules
- each store may use different provider stack
- each store may require different support load
- some fees may be paid by store
- some fees may be paid by HQ
- some fees may be paid by franchise owner
- some fees may be pass-through provider costs
- some fees may be one-time onboarding or hardware costs

Billing must reflect actual operational scope.

---

## 5. Billing Responsibility Layers

Recommended billing responsibility layers:

| Layer | Description |
| ----- | ----------- |
| Store-Level Fee | fee tied to one store’s operational use |
| HQ-Level Fee | fee tied to headquarters visibility or governance |
| Franchise-Level Fee | fee paid by franchisor or franchisee depending on model |
| Provider Pass-Through Fee | external provider cost separated from Yoonsul SaaS |
| Hardware Fee | device, kiosk, tablet, printer, KDS screen, or installation cost |
| Support Fee | support tier, onboarding, incident handling, or premium support |
| Setup Fee | initial configuration, training, provider mapping, onboarding |
| Optional Add-On Fee | module-specific paid option |
| Discount/Credit | temporary reduction with expiration and reason |

A billing line must belong to a clear responsibility layer.

---

## 6. Billing Entity Types

Recommended billing entity types:

- `STORE_OPERATOR`
- `FRANCHISEE`
- `FRANCHISOR_HQ`
- `MULTI_STORE_OWNER`
- `TENANT_HQ`
- `DIRECT_STORE`
- `PILOT_CUSTOMER`
- `EARLY_SAAS_CUSTOMER`
- `STANDARD_SAAS_CUSTOMER`
- `PROVIDER_PARTNER`
- `HARDWARE_VENDOR`

Billing entity must be known before invoice issue.

---

## 7. Billing Scope Values

Recommended billing scope values:

- `SINGLE_STORE`
- `MULTI_STORE_GROUP`
- `HQ_LEVEL`
- `FRANCHISE_LEVEL`
- `STORE_PLUS_HQ`
- `PILOT_SCOPE`
- `LIMITED_MODULE_SCOPE`
- `PROVIDER_GATEWAY_SCOPE`
- `SUPPORT_ONLY_SCOPE`
- `HARDWARE_ONLY_SCOPE`
- `SETUP_ONLY_SCOPE`

Billing scope should match enabled scope.

---

## 8. Invoice Grouping Options

Recommended invoice grouping options:

- one invoice per store
- one invoice for all stores under owner
- one HQ invoice plus store invoices
- one franchise HQ invoice for governance modules
- separate provider pass-through invoice
- separate hardware/setup invoice
- separate support invoice
- consolidated invoice with detailed line items

The grouping must be understandable and auditable.

---

## 9. Invoice Grouping Decision Rule

Invoice grouping should consider:

- who receives value
- who controls budget
- who owns store operations
- who pays provider costs
- who pays support costs
- who pays hardware costs
- whether stores are direct or franchise
- whether modules are store-level or HQ-level
- whether cost allocation must be visible
- whether tax/accounting handling differs

Do not choose grouping only for convenience.

---

## 10. Billing Line Item Categories

Recommended line item categories:

- `STORE_OS_BASE_FEE`
- `STORE_OS_PLUS_FEE`
- `MINI_KIOSK_MODULE_FEE`
- `KDS_HANDOFF_MODULE_FEE`
- `PROVIDER_GATEWAY_FEE`
- `SUPPORT_TIER_FEE`
- `ONBOARDING_SETUP_FEE`
- `TRAINING_FEE`
- `HARDWARE_DEVICE_FEE`
- `HARDWARE_INSTALLATION_FEE`
- `PAYMENT_PROVIDER_FEE`
- `POS_PROVIDER_FEE`
- `KDS_PROVIDER_FEE`
- `KIOSK_PROVIDER_FEE`
- `PILOT_CREDIT`
- `EARLY_ADOPTER_DISCOUNT`
- `INCIDENT_SUPPORT_SURCHARGE`
- `CUSTOM_REPORT_FEE`
- `EXPORT_REVIEW_FEE`

Line items should avoid vague naming.

---

## 11. Store-Level Billing Rule

Store-level billing may include:

- store OS module
- Mini Kiosk module
- KDS handoff module
- provider gateway module for that store
- store support tier
- store onboarding/training
- store hardware
- store-specific add-ons
- store-specific provider pass-through cost

Store-level fee should reflect store-level operational use.

---

## 12. HQ-Level Billing Rule

HQ-level billing may include:

- multi-store dashboard
- owner/HQ visibility
- franchise governance
- cross-store reporting
- provider portfolio management
- support command center
- compliance review
- HQ analytics
- renewal/churn dashboard
- expansion planning dashboard

HQ-level billing should not be charged to an individual store without agreement.

---

## 13. Franchise Billing Rule

Franchise billing may be split into:

- franchisor-paid governance fee
- franchisee-paid store operation fee
- shared provider gateway fee
- store-level support fee
- HQ-level dashboard fee
- training/onboarding fee
- hardware fee
- brand system fee if applicable

The policy must define who pays what.

Franchise billing must not blur operational responsibility.

---

## 14. Provider Cost Separation Rule

Provider costs must be separated from Yoonsul SaaS fees when possible.

Provider costs may include:

- POS provider subscription
- payment provider transaction fee
- kiosk provider fee
- KDS provider fee
- local daemon/license fee
- dealer support fee
- hardware maintenance fee
- provider setup fee
- provider API usage fee
- SMS/notification fee if provider-related

Provider cost should not be hidden inside vague SaaS fee unless clearly disclosed.

---

## 15. Payment Provider Fee Rule

Payment provider fee should be disclosed separately when applicable.

Billing should clarify:

- who charges the payment fee
- whether Yoonsul receives referral or margin
- whether fee is pass-through
- whether fee varies by transaction volume
- whether refund/cancel cost exists
- whether settlement visibility is included
- whether payment support is included

Payment fee opacity creates disputes.

---

## 16. Provider Gateway Fee Rule

Provider Gateway fee may be charged for:

- adapter maintenance
- provider event validation
- webhook/idempotency handling
- provider evidence capture
- provider error handling
- provider incident coordination
- provider mapping management
- provider compatibility maintenance

Provider Gateway fee is not the same as provider pass-through fee.

---

## 17. Support Fee Rule

Support fee should reflect support scope.

Support fee may depend on:

- number of stores
- support tier
- operating hours
- provider complexity
- payment/KDS support need
- staff training need
- incident history
- onboarding stage
- premium response expectation
- after-hours coverage

Support fee must not be underpriced if it absorbs provider and payment uncertainty.

---

## 18. Support Fee Allocation Rule

Support fee may be allocated by:

- store count
- active module count
- incident volume
- support tier
- provider complexity
- franchise HQ share
- store operator share
- onboarding phase
- premium support usage

Allocation method must be disclosed.

---

## 19. Hardware Fee Rule

Hardware fee should identify:

- device type
- ownership model
- purchase or rental
- installation fee
- maintenance responsibility
- replacement responsibility
- loss/damage responsibility
- provider dependency
- return rule
- device trust revocation requirement

Hardware cost must not be confused with SaaS subscription.

---

## 20. Setup Fee Rule

Setup fee may include:

- tenant/store setup
- provider stack review
- payment path configuration
- KDS handoff setup
- Mini Kiosk configuration
- staff training
- support playbook preparation
- evidence template setup
- pilot readiness review

Setup fee should be one-time unless repeated for new store or major provider change.

---

## 21. Training Fee Rule

Training fee may apply when:

- new store onboarding occurs
- new staff group is trained
- major module is added
- KDS workflow changes
- provider stack changes
- support workflow changes
- repeated retraining is needed outside included support
- franchise rollout requires structured training

Training fee should not replace necessary product usability fixes.

---

## 22. Discount And Credit Rule

Discount and credit must define:

- reason
- amount
- duration
- expiration date
- affected line item
- whether support fee included
- whether provider fee excluded
- whether hardware fee excluded
- standard price reference
- renewal condition

Discount must not become silent permanent pricing.

---

## 23. Pilot Credit Rule

Pilot credit may be used when:

- customer contributed meaningful pilot evidence
- early instability reduced value
- pilot-to-paid conversion needs bridge
- scope was intentionally limited
- customer accepted early adopter risk
- Yoonsul wants reference relationship

Pilot credit must be documented.

Pilot credit must not hide unresolved blocker.

---

## 24. Billing Evidence Requirement

Billing evidence should include:

- enabled modules
- active stores
- billing period
- package scope
- support tier
- provider cost basis
- hardware cost basis
- setup/training basis
- discounts/credits
- approved waivers
- customer acknowledgement
- invoice grouping decision
- limitation disclosure

Billing evidence protects trust.

---

## 25. Billing Record Fields

Each billing record should include:

- billing record id
- customer/tenant
- store or HQ scope
- billing entity
- billing period
- package
- enabled modules
- disabled modules
- line items
- provider pass-through items
- support tier
- hardware items
- discounts
- credits
- total amount
- tax handling placeholder
- payment status
- dispute status
- reviewer
- notes

Final tax/accounting fields may be added later.

---

## 26. Billing Record ID Format

Recommended format:

    BILLING-RECORD-[CUSTOMER]-[YYYYMM]

Example:

    BILLING-RECORD-CUST001-202606

Store-specific alternative:

    BILLING-RECORD-[STORE-ID]-[YYYYMM]

Final format may be normalized later.

---

## 27. Billing Status Values

Recommended billing status values:

- `BILLING_DRAFT`
- `BILLING_REVIEW_REQUIRED`
- `BILLING_APPROVED`
- `BILLING_SENT`
- `BILLING_PAYMENT_PENDING`
- `BILLING_PAID`
- `BILLING_OVERDUE`
- `BILLING_DISPUTED`
- `BILLING_ADJUSTMENT_REQUIRED`
- `BILLING_CREDIT_APPLIED`
- `BILLING_CANCELLED`
- `BILLING_CLOSED`

Billing status must be visible.

---

## 28. Billing Dispute Categories

Recommended dispute categories:

- `VALUE_DISPUTE`
- `SCOPE_DISPUTE`
- `PROVIDER_FEE_DISPUTE`
- `SUPPORT_FEE_DISPUTE`
- `HARDWARE_FEE_DISPUTE`
- `SETUP_FEE_DISPUTE`
- `DISCOUNT_DISPUTE`
- `PILOT_CREDIT_DISPUTE`
- `BILLING_PERIOD_DISPUTE`
- `MODULE_ENABLEMENT_DISPUTE`
- `CHURN_RELATED_DISPUTE`
- `UNKNOWN_DISPUTE`

Dispute category guides review.

---

## 29. Billing Dispute Review Rule

Billing dispute review should check:

- invoice line item
- contracted or agreed scope
- enabled module evidence
- support usage evidence
- provider fee evidence
- hardware evidence
- discount or credit record
- customer limitation disclosure
- owner communication
- renewal or churn risk
- adjustment decision

Billing dispute should feed pricing and packaging review.

---

## 30. Billing Adjustment Rule

Billing adjustment may be allowed when:

- line item was incorrect
- module was not enabled
- provider fee was misclassified
- discount was omitted
- support tier was misapplied
- customer was affected by Yoonsul blocker
- pilot credit was agreed but omitted
- scope limitation was not disclosed clearly

Adjustment must be recorded.

Adjustment is not silent deletion.

---

## 31. Billing Adjustment Record Fields

Billing adjustment should include:

- adjustment id
- billing record id
- reason
- affected line item
- original amount
- adjusted amount
- evidence
- approver
- customer communication
- status
- notes

Adjustment should remain auditable.

---

## 32. Billing Adjustment ID Format

Recommended format:

    BILLING-ADJUSTMENT-[YYYYMMDD]-[NUMBER]

Example:

    BILLING-ADJUSTMENT-20260612-001

Final format may be normalized later.

---

## 33. Multi-Store Cost Allocation Rule

For multi-store customers, cost allocation should define:

- per-store fixed fee
- per-store module fee
- shared HQ fee
- shared support fee
- shared provider gateway fee
- store-specific provider fee
- hardware fee by store
- setup fee by store
- discount by store or group
- invoice grouping method

Allocation should be transparent enough for owner and accounting.

---

## 34. Expansion Billing Rule

Before adding new store, billing review should confirm:

- new store package
- provider stack cost
- support tier change
- setup/training fee
- hardware cost
- pilot credit applicability
- discount policy
- HQ/store split
- billing start date
- scope restriction
- cancellation or downgrade path

Expansion should not create surprise invoice.

---

## 35. Module Activation Billing Rule

Module should become billable only when:

- module is enabled
- scope is documented
- customer understands limitation
- support path exists
- rollback/disable path exists
- evidence can prove activation
- unsafe blockers are not open
- billing start condition is clear

Do not bill for unsafe or hidden module.

---

## 36. Module Deactivation Billing Rule

When module is deactivated:

- deactivation reason must be recorded
- effective date must be recorded
- billing stop or reduction rule must be clear
- data retention/export rule must be known
- support impact must be known
- customer must be informed
- provider cost impact must be reviewed

Deactivation should not leave unclear billing.

---

## 37. Provider Incident Billing Impact Rule

Provider incident may affect billing when:

- paid module was unavailable
- provider cost continued despite outage
- support burden increased
- customer value was reduced
- workaround changed scope
- renewal risk increased
- discount/credit may be needed

Provider incident billing impact must be reviewed, not assumed.

---

## 38. Support Overload Billing Impact Rule

Support overload may affect billing when:

- support tier is underpriced
- customer expects premium support
- provider complexity creates heavy support
- staff training burden is high
- incident recovery consumes excessive time
- expansion adds support load

Support overload should feed pricing model.

---

## 39. Billing Dashboard Recommendation

A future billing dashboard may show:

- active stores
- active packages
- active modules
- provider pass-through items
- support tier
- discounts/credits
- billing disputes
- overdue invoices
- churn risk
- renewal date
- expansion billing impact

This document only recommends the dashboard.

---

## 40. Registers Recommendation

Recommended future files:

    docs/_index/
      Multi_Store_Billing_Register.md
      Billing_Line_Item_Register.md
      Provider_Cost_Allocation_Register.md
      Support_Fee_Allocation_Register.md
      Hardware_Fee_Register.md
      Setup_Training_Fee_Register.md
      Billing_Dispute_Register.md
      Billing_Adjustment_Register.md

This document only recommends these files.

It does not create them.

---

## 41. Anti-Patterns

The following are prohibited:

- hiding provider fee inside vague SaaS fee without disclosure
- billing store for HQ-only value without agreement
- billing unsafe module
- billing disabled module
- applying permanent discount silently
- ignoring support burden in pricing
- hiding hardware ownership responsibility
- mixing pilot credit with standard discount without reason
- issuing invoice without scope evidence
- ignoring billing dispute as customer complaint only
- using billing confusion to force renewal
- charging for unsupported provider compatibility
- treating support heroics as free forever

---

## 42. Non-Goals

This document does not define:

- final invoice template
- final accounting treatment
- final tax handling
- final payment collection system
- final legal terms
- final franchise royalty model
- final settlement automation
- final ERP integration

Those belong to later finance, legal, and accounting planning.

---

## 43. Readiness Check

This document is ready when the project can answer:

1. What does multi-store billing mean?
2. What billing responsibility layers exist?
3. What billing entity types exist?
4. What billing scope values exist?
5. What invoice grouping options exist?
6. How is invoice grouping decided?
7. What line item categories exist?
8. What store-level billing rule applies?
9. What HQ-level billing rule applies?
10. What franchise billing rule applies?
11. What provider cost separation rule applies?
12. How is payment provider fee disclosed?
13. What is Provider Gateway fee?
14. How is support fee defined?
15. How is support fee allocated?
16. How is hardware fee defined?
17. How is setup fee defined?
18. How is training fee defined?
19. What discount and credit rule applies?
20. What pilot credit rule applies?
21. What billing evidence is required?
22. What fields should billing record include?
23. What billing status values exist?
24. What dispute categories exist?
25. How is billing dispute reviewed?
26. When is billing adjustment allowed?
27. What fields should adjustment record include?
28. How is multi-store cost allocated?
29. How is expansion billing reviewed?
30. When does module become billable?
31. How is module deactivation billed?
32. How does provider incident affect billing?
33. How does support overload affect billing?
34. What anti-patterns are prohibited?

If these questions cannot be answered, multi-store billing operations and cost allocation planning is incomplete.

---

## 44. Conclusion

Multi-store SaaS billing must be transparent before it becomes complex.

The safe billing flow is:

    enabled scope
        -> billing responsibility
        -> line item classification
        -> provider cost separation
        -> support fee allocation
        -> hardware/setup visibility
        -> discount or credit control
        -> invoice evidence
        -> dispute and adjustment review

This document ensures that SaaS revenue grows without creating hidden provider costs, unclear support expectations, unfair store/HQ allocation, module billing disputes, or early churn caused by billing confusion.