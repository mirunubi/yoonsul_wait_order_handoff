# 14090_Policy_Multi_Store_Commercial_Audit_Dispute_Recovery

## 1. Purpose

This document defines the multi-store commercial audit trail, invoice dispute handling, billing evidence review, customer trust recovery, commercial correction, credit or adjustment review, provider cost dispute handling, support fee dispute handling, and revenue-risk feedback policy for the Yoonsul Wait/Order Handoff documentation project.

The previous document defined revenue recognition boundary, deferred revenue consideration, and billing audit evidence policy.

This document defines how commercial disputes must be handled when a customer questions invoice amount, enabled module scope, provider pass-through cost, support fee, hardware charge, discount, credit, or billing effective date.

This document does not implement billing dispute software, accounting workflows, legal claim handling, refund execution, or customer compensation automation.

It defines commercial audit trail and invoice dispute governance policy only.

---

## 2. Scope

This document covers:

- commercial audit trail
- invoice dispute classification
- dispute evidence review
- customer trust recovery
- billing adjustment review
- service credit review
- provider cost dispute
- support fee dispute
- module billing dispute
- hardware fee dispute
- discount or pilot credit dispute
- scope amendment dispute
- dispute closure
- no-implementation boundary

This document does not cover:

- final legal dispute clause
- final accounting reversal
- final refund payment execution
- final tax correction
- final ERP posting
- final court or arbitration process
- final consumer law policy
- final franchise legal dispute procedure

---

## 3. Core Principle

Commercial disputes must be resolved with evidence, not memory.

The project must follow this rule:

> Every billing or scope dispute must be linked to commercial scope, enabled module evidence, provider cost evidence, support obligation evidence, discount or credit record, amendment record, and customer acknowledgement before correction or rejection.

A dispute is not only a finance problem.

It may reveal a product, support, provider, onboarding, pricing, or communication problem.

---

## 4. Commercial Audit Trail Meaning

Commercial audit trail means preserving the complete evidence chain for:

- original commercial scope
- package and module scope
- store count
- provider dependency
- provider pass-through cost
- support tier
- hardware responsibility
- setup/training scope
- discount or pilot credit
- amendment history
- billing line items
- invoice communication
- customer acknowledgement
- dispute review
- adjustment or credit decision
- closure outcome

Audit trail must allow the project to explain what was billed and why.

---

## 5. Invoice Dispute Definition

An invoice dispute occurs when customer or internal reviewer questions:

- total invoice amount
- specific line item
- provider pass-through fee
- support fee
- module activation fee
- hardware fee
- setup/training fee
- discount expiration
- pilot credit amount
- billing effective date
- proration
- store count
- package tier
- scope limitation
- value delivered
- invoice grouping
- tax or external charge placeholder

Dispute may be valid or invalid.

Both require evidence review.

---

## 6. Invoice Dispute Classification Values

Recommended dispute classifications:

- `MODULE_BILLING_DISPUTE`
- `PROVIDER_FEE_DISPUTE`
- `PAYMENT_PROVIDER_FEE_DISPUTE`
- `SUPPORT_FEE_DISPUTE`
- `HARDWARE_FEE_DISPUTE`
- `SETUP_TRAINING_FEE_DISPUTE`
- `DISCOUNT_EXPIRATION_DISPUTE`
- `PILOT_CREDIT_DISPUTE`
- `SERVICE_CREDIT_DISPUTE`
- `BILLING_EFFECTIVE_DATE_DISPUTE`
- `PRORATION_DISPUTE`
- `STORE_COUNT_DISPUTE`
- `PACKAGE_SCOPE_DISPUTE`
- `VALUE_DELIVERY_DISPUTE`
- `PROVIDER_INCIDENT_BILLING_DISPUTE`
- `SUPPORT_OVERLOAD_BILLING_DISPUTE`
- `INVOICE_GROUPING_DISPUTE`
- `UNKNOWN_BILLING_DISPUTE`

Classification determines review path.

---

## 7. Dispute Severity Values

Recommended severity values:

- `DISPUTE_CRITICAL`
- `DISPUTE_HIGH`
- `DISPUTE_MEDIUM`
- `DISPUTE_LOW`
- `DISPUTE_OBSERVATION`

Severity should reflect customer trust risk, revenue impact, renewal risk, and whether the dispute indicates systemic billing confusion.

---

## 8. Critical Dispute Examples

Critical disputes include:

- customer claims they were billed for disabled module
- customer claims provider fee was hidden
- customer claims discount expiration was never disclosed
- customer claims paid scope was not delivered
- customer claims support fee was charged without support availability
- customer claims store was billed after removal
- customer claims hardware ownership was misrepresented
- customer threatens cancellation due to invoice trust issue
- same dispute appears across multiple stores
- invoice exposes sensitive or cross-store information

Critical dispute requires immediate commercial and customer success review.

---

## 9. Dispute Record Fields

Each dispute record should include:

- dispute id
- customer/tenant
- store or store group
- invoice or billing record id
- disputed line item
- dispute classification
- severity
- customer claim
- internal initial assessment
- affected revenue category
- affected module
- affected provider
- affected support tier
- affected hardware
- affected amendment
- evidence required
- evidence status
- reviewer
- decision
- customer response
- status
- notes

Dispute must be traceable.

---

## 10. Dispute ID Format

Recommended format:

    INVOICE-DISPUTE-[CUSTOMER]-[YYYYMMDD]-[NUMBER]

Example:

    INVOICE-DISPUTE-CUST001-20260612-001

Store-specific alternative:

    INVOICE-DISPUTE-[STORE-ID]-[YYYYMMDD]-[NUMBER]

Final format may be normalized later.

---

## 11. Dispute Status Values

Recommended status values:

- `DISPUTE_OPEN`
- `DISPUTE_TRIAGE_REQUIRED`
- `EVIDENCE_REVIEW_REQUIRED`
- `CUSTOMER_CLARIFICATION_REQUIRED`
- `INTERNAL_REVIEW_REQUIRED`
- `PROVIDER_REVIEW_REQUIRED`
- `SUPPORT_REVIEW_REQUIRED`
- `BILLING_ADJUSTMENT_REVIEW_REQUIRED`
- `CREDIT_REVIEW_REQUIRED`
- `DISPUTE_ACCEPTED`
- `DISPUTE_PARTIALLY_ACCEPTED`
- `DISPUTE_REJECTED`
- `ADJUSTMENT_APPLIED`
- `CREDIT_APPLIED`
- `CUSTOMER_COMMUNICATED`
- `DISPUTE_CLOSED`
- `DISPUTE_ESCALATED`

Dispute status must not hide unresolved customer trust issue.

---

## 12. Dispute Evidence Review

Dispute evidence review should check:

- customer agreement or acknowledgement
- package scope
- enabled module record
- activation evidence
- deactivation evidence
- billing effective date
- amendment record
- discount or credit record
- provider pass-through evidence
- support tier evidence
- hardware ownership or rental evidence
- setup/training delivery evidence
- invoice grouping decision
- limitation disclosure
- relevant incident or outage record
- customer communication history

Decision must follow evidence.

---

## 13. Module Billing Dispute Rule

If module billing is disputed, review:

- whether module was enabled
- activation date
- deactivation date if any
- safety readiness
- customer acknowledgement
- limitation disclosure
- support path
- evidence of actual availability
- incident or pause record
- billing start/stop rule

Do not bill normal active module fee for module that was promised but not enabled.

---

## 14. Provider Fee Dispute Rule

If provider fee is disputed, review:

- provider pass-through disclosure
- provider invoice or cost basis
- provider stack record
- affected store
- provider fee start date
- provider fee stop date
- whether Yoonsul margin or referral exists
- whether customer was informed
- whether provider incident reduced value
- whether provider cost was misclassified

Provider cost confusion should be corrected early.

---

## 15. Payment Provider Fee Dispute Rule

If payment provider fee is disputed, review:

- transaction fee basis
- payment provider role
- refund/cancel fee if any
- settlement fee if any
- terminal or gateway fee
- whether fee is pass-through
- whether customer expected it
- whether fee appeared after scope change
- whether payment issue created trust concern

Payment fee dispute may affect payment trust.

---

## 16. Support Fee Dispute Rule

If support fee is disputed, review:

- support tier
- support scope
- support hours
- support case count
- support severity
- premium support expectation
- support burden evidence
- provider coordination work
- support response history
- whether support was available as promised

Support fee must reflect both promise and actual support delivery.

---

## 17. Hardware Fee Dispute Rule

If hardware fee is disputed, review:

- hardware type
- purchase or rental
- ownership
- delivery evidence
- installation evidence
- maintenance responsibility
- replacement responsibility
- return rule
- loss/damage rule
- device trust registration
- customer acknowledgement

Hardware dispute often comes from unclear ownership.

---

## 18. Setup Or Training Fee Dispute Rule

If setup or training fee is disputed, review:

- setup scope
- onboarding checklist
- store profile
- provider stack review
- staff training record
- training date
- participants
- module setup evidence
- whether repeated training was included or extra
- customer acknowledgement

Training fee should not be charged for correcting product confusion without review.

---

## 19. Discount Expiration Dispute Rule

If discount expiration is disputed, review:

- discount record
- start date
- end date
- affected line items
- standard price reference
- customer acknowledgement
- renewal communication
- invoice transition
- whether expiration notice was clear

Discount expiration must not surprise customer.

---

## 20. Pilot Credit Dispute Rule

If pilot credit is disputed, review:

- pilot credit reason
- pilot contribution evidence
- credit amount
- credit duration
- affected billing period
- conversion record
- limitation disclosure
- whether credit was applied correctly
- whether customer expected extension

Pilot credit must remain distinct from permanent discount.

---

## 21. Service Credit Dispute Rule

If service credit is disputed, review:

- incident or outage evidence
- customer impact
- module unavailability
- support delay
- provider incident involvement
- responsible party
- credit policy or precedent
- customer communication
- renewal impact

Service credit should not replace root-cause correction.

---

## 22. Billing Effective Date Dispute Rule

If effective date is disputed, review:

- request date
- approval date
- operational effective date
- billing effective date
- activation or deactivation evidence
- amendment record
- invoice period
- proration rule
- customer acknowledgement

Effective date disputes often reveal amendment gaps.

---

## 23. Proration Dispute Rule

If proration is disputed, review:

- billing period
- effective date
- module add/remove date
- store add/remove date
- support tier change date
- provider cost start/stop date
- hardware rental period
- agreed proration rule
- calculation evidence

Proration should be explainable.

---

## 24. Store Count Dispute Rule

If store count is disputed, review:

- active store list
- store add amendment
- store remove amendment
- activation date
- deactivation date
- module scope per store
- support scope per store
- provider cost per store
- invoice grouping

Multi-store billing must preserve store-level traceability.

---

## 25. Package Scope Dispute Rule

If package scope is disputed, review:

- package definition
- included modules
- excluded modules
- support tier
- provider gateway scope
- dashboard scope
- KDS/Mini Kiosk scope
- limitation disclosure
- upgrade/downgrade amendment
- customer acknowledgement

Package naming must not imply unsupported scope.

---

## 26. Value Delivery Dispute Rule

If customer says value was not delivered, review:

- operational evidence
- usage data
- support cases
- incidents
- customer feedback
- staff adoption
- payment/KDS reliability
- provider limitation
- scope mismatch
- onboarding quality
- training quality
- expectation set during sale

Value dispute may require customer success intervention, not only billing correction.

---

## 27. Provider Incident Billing Dispute Rule

If provider incident caused billing dispute, review:

- provider incident record
- containment period
- affected module
- customer impact
- support burden
- provider responsibility
- Yoonsul responsibility
- workaround used
- service credit possibility
- renewal risk

Provider incident billing dispute must update provider strategy.

---

## 28. Customer Trust Recovery Rule

When billing dispute damages trust:

- acknowledge concern clearly
- avoid defensive language
- explain evidence review process
- separate provider cost from Yoonsul fee
- clarify scope and limitation
- correct error if found
- offer adjustment or credit only with reason
- update documentation if confusion caused dispute
- set next review date

Trust recovery is part of commercial operations.

---

## 29. Customer Communication Boundary

Customer communication should be:

- factual
- calm
- evidence-based
- non-accusatory
- transparent on line items
- clear on provider pass-through
- clear on support scope
- clear on next action
- clear on final decision

Do not say:

    그냥 원래 그런 비용입니다.
    계약서에 있습니다.
    시스템상 못 바꿉니다.
    외부 업체 비용이라 저희는 모릅니다.

Trust is protected by clarity.

---

## 30. Dispute Decision Values

Recommended decision values:

- `DISPUTE_ACCEPTED_FULL`
- `DISPUTE_ACCEPTED_PARTIAL`
- `DISPUTE_REJECTED_WITH_EVIDENCE`
- `BILLING_ADJUSTMENT_REQUIRED`
- `SERVICE_CREDIT_REQUIRED`
- `PROVIDER_REVIEW_REQUIRED`
- `SUPPORT_REVIEW_REQUIRED`
- `SCOPE_AMENDMENT_REQUIRED`
- `DISCOUNT_CLARIFICATION_REQUIRED`
- `CUSTOMER_SUCCESS_INTERVENTION_REQUIRED`
- `LEGAL_OR_FINANCE_REVIEW_REQUIRED`
- `RENEWAL_RISK_REVIEW_REQUIRED`

Decision must be linked to evidence.

---

## 31. Billing Adjustment Decision Rule

Billing adjustment may apply when:

- incorrect amount was billed
- module was not enabled
- store was inactive
- discount or credit was omitted
- provider cost was misclassified
- support tier was wrong
- effective date was wrong
- proration was wrong
- hardware fee was incorrect
- customer acknowledgement was missing for scope change

Adjustment must preserve original invoice trail.

---

## 32. Service Credit Decision Rule

Service credit may apply when:

- paid service was unavailable
- Yoonsul-controlled issue reduced value
- support delay caused customer impact
- module pause reduced paid scope
- provider incident was not disclosed or contained properly
- customer trust recovery requires commercial gesture
- billing correction alone is insufficient

Service credit must be documented and time-bound.

---

## 33. Dispute To Product Action Rule

Dispute may create product action when:

- UI caused misunderstanding
- package name caused expectation gap
- module status was unclear
- provider cost was not visible
- support tier was misunderstood
- dashboard did not show enough evidence
- onboarding failed to explain limitation
- invoice line item naming was vague

Billing dispute may reveal design gap.

---

## 34. Dispute To SOP Action Rule

Dispute may create SOP update when:

- sales explanation was inconsistent
- onboarding checklist missed fee disclosure
- support promised unsupported scope
- customer success failed renewal notice
- discount expiration was not explained
- provider pass-through was not clarified
- hardware responsibility was vague

Commercial SOP must improve after dispute.

---

## 35. Dispute To Pricing Action Rule

Dispute may create pricing review when:

- support burden is underpriced
- provider cost is hard to explain
- package boundary is unclear
- discount creates confusion
- module price feels disconnected from value
- hardware cost surprises customers
- setup/training fee is repeatedly questioned
- multi-store allocation is misunderstood

Pricing must be understandable.

---

## 36. Dispute To Revenue Risk Rule

Dispute should create or update revenue risk when:

- customer threatens cancellation
- downgrade request appears
- renewal is near
- dispute amount is significant
- same dispute repeats
- provider cost is unstable
- support cost exceeds plan
- customer trust is damaged
- invoice remains unpaid

Dispute is a revenue signal.

---

## 37. Dispute Closure Rule

Dispute may close only when:

- evidence review is complete
- decision is recorded
- adjustment or credit is applied if required
- customer is informed
- revenue risk updated
- product/SOP/pricing action created if needed
- amendment updated if needed
- billing evidence packet updated
- closure reason recorded

Do not close dispute merely because customer stopped replying.

---

## 38. Dispute Closure Status Values

Recommended closure values:

- `CLOSED_ACCEPTED_ADJUSTED`
- `CLOSED_ACCEPTED_CREDITED`
- `CLOSED_PARTIAL_ADJUSTMENT`
- `CLOSED_REJECTED_WITH_EVIDENCE`
- `CLOSED_CUSTOMER_ACCEPTED_EXPLANATION`
- `CLOSED_CUSTOMER_CANCELLED`
- `CLOSED_CONVERTED_TO_RENEWAL_RISK`
- `CLOSED_ESCALATED_TO_FINANCE_LEGAL`
- `CLOSED_DEFERRED_TO_AMENDMENT`

Closure status should preserve outcome.

---

## 39. Audit Trail Preservation Rule

Commercial audit trail must preserve:

- original invoice
- revised invoice if any
- billing line item
- evidence packet
- customer claim
- internal review
- decision
- adjustment or credit
- customer communication
- revenue risk update
- related amendment
- final closure

Audit trail must be append-only or append-only-equivalent.

---

## 40. Dispute Trend Review

Dispute trends should be reviewed by:

- customer
- store
- package
- module
- provider
- support tier
- hardware type
- invoice line item
- discount type
- credit type
- sales/onboarding source
- renewal timing
- dispute category

Recurring disputes indicate structural problem.

---

## 41. Registers Recommendation

Recommended future files:

    docs/_index/
      Invoice_Dispute_Register.md
      Commercial_Audit_Trail_Register.md
      Billing_Adjustment_Decision_Register.md
      Service_Credit_Decision_Register.md
      Dispute_To_Product_Action_Register.md
      Dispute_To_SOP_Action_Register.md
      Dispute_To_Pricing_Action_Register.md
      Dispute_Revenue_Risk_Register.md
      Dispute_Closure_Register.md

This document only recommends these files.

It does not create them.

---

## 42. Anti-Patterns

The following are prohibited:

- resolving invoice dispute from memory
- hiding original invoice after adjustment
- treating provider fee dispute as customer ignorance
- treating value dispute as pure billing problem
- rejecting dispute without evidence
- applying credit without reason
- changing invoice without amendment trail
- closing dispute because customer stopped replying
- blaming provider without explaining pass-through
- using legal language before evidence review
- ignoring repeated dispute pattern
- ignoring renewal risk caused by dispute
- letting billing dispute stay outside product feedback loop

---

## 43. Non-Goals

This document does not define:

- final legal dispute procedure
- final refund execution
- final accounting reversal method
- final tax correction
- final ERP entry
- final consumer compensation policy
- final litigation or arbitration process
- final franchise legal dispute workflow

Those belong to later legal, finance, and accounting planning.

---

## 44. Readiness Check

This document is ready when the project can answer:

1. What does commercial audit trail mean?
2. What is invoice dispute?
3. What dispute classifications exist?
4. What severity values exist?
5. What are critical dispute examples?
6. What fields should dispute record include?
7. What dispute status values exist?
8. What evidence is reviewed?
9. How is module billing dispute reviewed?
10. How is provider fee dispute reviewed?
11. How is payment provider fee dispute reviewed?
12. How is support fee dispute reviewed?
13. How is hardware fee dispute reviewed?
14. How is setup/training fee dispute reviewed?
15. How is discount expiration dispute reviewed?
16. How is pilot credit dispute reviewed?
17. How is service credit dispute reviewed?
18. How is effective date dispute reviewed?
19. How is proration dispute reviewed?
20. How is store count dispute reviewed?
21. How is package scope dispute reviewed?
22. How is value delivery dispute reviewed?
23. How is provider incident billing dispute reviewed?
24. How is customer trust recovered?
25. What communication boundary applies?
26. What dispute decision values exist?
27. When is billing adjustment required?
28. When is service credit required?
29. How does dispute create product action?
30. How does dispute create SOP action?
31. How does dispute create pricing action?
32. How does dispute create revenue risk?
33. When may dispute close?
34. What closure statuses exist?
35. What audit trail preservation rule applies?
36. How are dispute trends reviewed?
37. What anti-patterns are prohibited?

If these questions cannot be answered, commercial audit trail, invoice dispute, and customer trust recovery planning is incomplete.

---

## 45. Conclusion

Billing disputes are not just accounting events.

They are trust, scope, pricing, support, provider, and product evidence events.

The safe dispute flow is:

    customer dispute
        -> classification
        -> evidence review
        -> billing line and scope check
        -> provider/support/hardware/discount review
        -> decision
        -> adjustment or credit if needed
        -> customer communication
        -> revenue risk update
        -> product/SOP/pricing feedback
        -> closure with audit trail

This document ensures that commercial disputes are handled transparently, customers are not dismissed, and every billing conflict improves SaaS pricing, packaging, evidence, support, provider disclosure, and renewal readiness.