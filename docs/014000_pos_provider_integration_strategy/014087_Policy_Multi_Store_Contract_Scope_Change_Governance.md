# 014087_Policy_Multi_Store_Contract_Scope_Change_Governance

## 1. Purpose

This document defines the multi-store contract scope change, module amendment, package change, support tier change, provider cost change, hardware responsibility change, discount amendment, and commercial governance policy for the Yoonsul Wait/Order Handoff documentation project.

The previous document defined multi-store billing operations, invoice support fee, and provider cost allocation policy.

This document defines how commercial scope changes must be governed after a customer has entered paid SaaS operation.

This document does not create legal contract text, execute contract amendment, generate invoice changes, implement billing workflow, or provide legal advice.

It defines contract scope change and commercial amendment governance policy only.

---

## 2. Scope

This document covers:

- contract scope change boundary
- module amendment
- package upgrade
- package downgrade
- store add/remove amendment
- provider cost amendment
- support tier amendment
- hardware responsibility amendment
- discount and pilot credit amendment
- billing effective date
- customer acknowledgement
- amendment evidence
- no-implementation boundary

This document does not cover:

- final legal contract drafting
- final electronic signature workflow
- final invoice automation
- final tax/accounting treatment
- final franchise agreement
- final provider contract
- final payment collection
- final ERP integration

---

## 3. Core Principle

Commercial scope must follow operational truth.

The project must follow this rule:

> A paid SaaS customer’s commercial scope may change only when enabled modules, store count, provider dependency, support obligation, hardware responsibility, billing effect, limitations, and customer acknowledgement are documented.

Commercial change without operational record creates disputes.

Operational change without commercial amendment creates revenue leakage.

---

## 4. Contract Scope Change Meaning

A contract scope change means any change to:

- number of stores covered
- enabled modules
- disabled modules
- package tier
- support tier
- provider gateway scope
- Mini Kiosk scope
- KDS handoff scope
- dashboard scope
- billing entity
- invoice grouping
- provider pass-through cost
- hardware responsibility
- setup/training obligation
- discount or credit
- renewal term
- cancellation or downgrade path

Scope change should not be treated as informal conversation.

---

## 5. Scope Change Types

Recommended scope change types:

- `MODULE_ADD`
- `MODULE_REMOVE`
- `PACKAGE_UPGRADE`
- `PACKAGE_DOWNGRADE`
- `STORE_ADD`
- `STORE_REMOVE`
- `SUPPORT_TIER_UPGRADE`
- `SUPPORT_TIER_DOWNGRADE`
- `PROVIDER_GATEWAY_ADD`
- `PROVIDER_GATEWAY_REMOVE`
- `PROVIDER_COST_CHANGE`
- `HARDWARE_ADD`
- `HARDWARE_REMOVE`
- `SETUP_TRAINING_ADD`
- `DISCOUNT_CHANGE`
- `PILOT_CREDIT_CHANGE`
- `BILLING_ENTITY_CHANGE`
- `INVOICE_GROUPING_CHANGE`
- `LIMITATION_DISCLOSURE_CHANGE`
- `RENEWAL_TERM_CHANGE`
- `CANCELLATION_TERM_CHANGE`

Change type determines review path.

---

## 6. Scope Change Status Values

Recommended status values:

- `CHANGE_REQUESTED`
- `CHANGE_REVIEW_REQUIRED`
- `OPERATIONAL_REVIEW_REQUIRED`
- `COMMERCIAL_REVIEW_REQUIRED`
- `SECURITY_REVIEW_REQUIRED`
- `PROVIDER_REVIEW_REQUIRED`
- `BILLING_REVIEW_REQUIRED`
- `CUSTOMER_ACK_REQUIRED`
- `APPROVED`
- `REJECTED`
- `DEFERRED`
- `IMPLEMENTATION_PENDING`
- `EFFECTIVE`
- `REVERSED`
- `SUPERSEDED`

Scope change must not become effective silently.

---

## 7. Scope Change Record Fields

Each scope change should record:

- scope change id
- customer/tenant
- affected store or HQ scope
- change type
- current scope
- requested scope
- reason
- affected modules
- affected provider stack
- affected support tier
- affected hardware
- operational readiness status
- security impact
- billing impact
- effective date
- customer acknowledgement
- approval decision
- reviewer
- notes

This record links operational and commercial change.

---

## 8. Scope Change ID Format

Recommended format:

    SCOPE-CHANGE-[CUSTOMER]-[YYYYMMDD]-[NUMBER]

Example:

    SCOPE-CHANGE-CUST001-20260612-001

Store-specific alternative:

    SCOPE-CHANGE-[STORE-ID]-[YYYYMMDD]-[NUMBER]

Final format may be normalized later.

---

## 9. Amendment Record Fields

Commercial amendment should record:

- amendment id
- linked scope change id
- customer/tenant
- affected store(s)
- amendment type
- old commercial scope
- new commercial scope
- old price
- new price
- provider pass-through change
- support fee change
- hardware fee change
- discount/credit change
- effective date
- billing period impact
- limitation disclosure
- customer acknowledgement
- approver
- status
- notes

Amendment must be auditable.

---

## 10. Amendment ID Format

Recommended format:

    AMENDMENT-[CUSTOMER]-[YYYYMMDD]-[NUMBER]

Example:

    AMENDMENT-CUST001-20260612-001

Final format may be normalized later.

---

## 11. Module Add Rule

A module may be added only when:

- module is implementation-ready for customer scope
- operational readiness is confirmed
- support path exists
- rollback/disable path exists
- billing impact is clear
- provider dependency is reviewed
- security boundary is reviewed where needed
- customer understands limitation
- effective date is defined
- evidence can confirm activation

Do not add module only because customer requests it.

---

## 12. Module Remove Rule

A module may be removed only when:

- deactivation path exists
- customer impact is understood
- dependent modules are reviewed
- data retention/export rule is known
- support path is updated
- billing reduction or stop rule is clear
- provider cost impact is reviewed
- customer acknowledges changed capability

Remove does not mean delete evidence.

---

## 13. Package Upgrade Rule

Package upgrade may occur when:

- customer is stable in current package
- upgrade value is clear
- added modules are ready
- support tier can handle increased scope
- provider dependency is understood
- price change is transparent
- training need is planned
- rollback or downgrade path is defined

Upgrade must not hide unresolved current-scope issues.

---

## 14. Package Downgrade Rule

Package downgrade may occur when:

- customer needs lower scope
- reduced package remains safe
- disabled modules can be safely removed
- support obligation is updated
- billing adjustment is clear
- customer understands lost capabilities
- data retention/export is handled
- renewal/churn risk is reviewed

Downgrade is a retention tool, not a failure.

---

## 15. Store Add Rule

Adding a store requires:

- expansion readiness review
- target store profile
- provider stack review
- staff training plan
- support capacity review
- billing responsibility review
- hardware/setup review
- scope restriction if needed
- onboarding evidence
- customer acknowledgement

Store add is both operational and commercial change.

---

## 16. Store Remove Rule

Removing a store requires:

- effective date
- enabled module shutdown review
- provider cost stop or continuation review
- hardware return or ownership review
- support scope update
- data retention/export review
- billing adjustment
- customer acknowledgement
- evidence preservation

Store remove must not break audit lineage.

---

## 17. Support Tier Change Rule

Support tier change requires review of:

- support case history
- expected support load
- operating hours
- response expectation
- provider complexity
- payment/KDS support need
- staff training burden
- price impact
- downgrade or upgrade risk
- customer acknowledgement

Support tier should reflect reality.

---

## 18. Provider Gateway Scope Change Rule

Provider Gateway scope change requires:

- provider stack review
- adapter readiness
- webhook/idempotency readiness
- local daemon or cloud API readiness
- mapping evidence
- payment/order/KDS impact review
- provider cost review
- support/dealer dependency review
- rollback/disable path

Provider Gateway scope is high-risk.

---

## 19. Provider Cost Change Rule

Provider cost change may occur when:

- provider pricing changes
- transaction volume changes
- provider module is added or removed
- dealer support fee changes
- hardware maintenance changes
- API usage cost changes
- payment provider fee changes
- provider incident changes support burden

Provider cost change must be disclosed separately when possible.

---

## 20. Hardware Responsibility Change Rule

Hardware responsibility change requires:

- ownership model update
- device assignment update
- loss/damage responsibility
- maintenance responsibility
- replacement responsibility
- return rule
- device trust update
- billing impact
- customer acknowledgement

Hardware responsibility must not remain vague.

---

## 21. Setup Or Training Amendment Rule

Setup or training amendment may occur when:

- new store is added
- new module is added
- staff group changes
- provider stack changes
- KDS workflow changes
- support process changes
- repeated training exceeds included scope
- franchise rollout requires structured onboarding

Training amendment should be linked to operational need.

---

## 22. Discount Amendment Rule

Discount amendment must define:

- reason
- old discount
- new discount
- affected line item
- duration
- expiration date
- standard price reference
- renewal effect
- whether support/provider/hardware is included or excluded
- approver

Discount changes must not become informal promises.

---

## 23. Pilot Credit Amendment Rule

Pilot credit amendment must define:

- pilot contribution basis
- value reduction basis if any
- credit amount
- credit duration
- affected billing period
- affected line item
- expiration
- conversion relationship
- customer acknowledgement

Pilot credit is not permanent discount.

---

## 24. Billing Effective Date Rule

Every commercial amendment must define:

- request date
- approval date
- operational effective date
- billing effective date
- invoice period affected
- proration rule if applicable
- retroactive adjustment if applicable
- next renewal effect

Do not change price without effective date clarity.

---

## 25. Proration Boundary

Proration may apply when:

- store added mid-period
- module added mid-period
- module removed mid-period
- support tier changed mid-period
- hardware returned mid-period
- provider cost starts/stops mid-period
- package upgrade/downgrade occurs mid-period

Proration rule must be documented before invoice.

---

## 26. Customer Acknowledgement Rule

Customer acknowledgement is required when:

- price changes
- provider pass-through cost changes
- module scope changes
- support tier changes
- hardware responsibility changes
- discount expires
- limitation disclosure changes
- store is added or removed
- billing entity changes
- invoice grouping changes

Acknowledgement may be formal or operational depending on later legal policy.

But it must be recorded.

---

## 27. Limitation Disclosure Update Rule

Limitation disclosure must be updated when:

- provider path changes
- unsupported provider remains unsupported
- KDS automation changes
- Mini Kiosk scope changes
- support hours change
- manual fallback reliance changes
- payment/refund/cancel capability changes
- export/report scope changes
- hardware responsibility changes

A customer should not pay under outdated assumptions.

---

## 28. Security Review Trigger

Security review is required when scope change affects:

- tenant/store visibility
- support access
- export/report access
- CI/DI handling
- device trust
- provider credential handling
- webhook secret handling
- dashboard visibility
- role permissions
- cross-store access

Commercial expansion must not outrun security review.

---

## 29. Operational Readiness Review Trigger

Operational readiness review is required when scope change affects:

- payment flow
- order acceptance
- KDS handoff
- Mini Kiosk flow
- support workflow
- fallback path
- provider adapter
- staff training
- dashboard monitoring
- evidence packet

Operational readiness must precede billing activation.

---

## 30. Billing Review Trigger

Billing review is required when scope change affects:

- price
- line item
- support fee
- provider fee
- hardware fee
- setup/training fee
- discount
- pilot credit
- invoice grouping
- billing entity
- billing start/stop date

Billing review prevents disputes.

---

## 31. Scope Change Approval Decision Values

Recommended values:

- `APPROVE`
- `APPROVE_WITH_LIMITATION`
- `APPROVE_WITH_SCOPE_RESTRICTION`
- `APPROVE_AFTER_TRAINING`
- `APPROVE_AFTER_PROVIDER_REVIEW`
- `APPROVE_AFTER_SECURITY_REVIEW`
- `APPROVE_AFTER_BILLING_REVIEW`
- `DEFER`
- `REJECT`
- `REVERSE_CHANGE`

Approval must match readiness.

---

## 32. Scope Change Reversal Rule

Scope change may need reversal when:

- module activation caused critical issue
- provider path failed
- support burden exceeded expectation
- staff could not operate new scope
- customer misunderstood limitation
- billing dispute occurred
- security risk appeared
- rollback was required

Reversal must preserve evidence and billing adjustment trail.

---

## 33. Scope Change Dispute Rule

Dispute may occur when:

- customer says change was not agreed
- customer expected different module
- invoice reflects wrong effective date
- discount expiration misunderstood
- provider fee not disclosed
- support tier expectation differs
- hardware responsibility unclear
- downgrade did not reduce expected fee
- module disabled but still billed

Dispute must link to amendment and acknowledgement evidence.

---

## 34. Amendment Versioning Rule

Each commercial amendment should preserve:

- prior scope
- new scope
- effective date
- reason
- acknowledgement
- billing impact
- superseded amendment if any
- rollback/reversal if any

Commercial history must be traceable.

---

## 35. Registers Recommendation

Recommended future files:

    docs/_index/
      Contract_Scope_Change_Register.md
      Commercial_Amendment_Register.md
      Module_Amendment_Register.md
      Store_Add_Remove_Amendment_Register.md
      Support_Tier_Amendment_Register.md
      Provider_Cost_Amendment_Register.md
      Discount_Credit_Amendment_Register.md
      Scope_Change_Dispute_Register.md

This document only recommends these files.

It does not create them.

---

## 36. Anti-Patterns

The following are prohibited:

- adding module without readiness review
- billing module before activation evidence
- removing module without dependency review
- upgrading customer to hide current issues
- downgrading customer without safe deactivation
- adding store without expansion review
- changing support tier informally
- hiding provider cost change
- allowing discount promise without expiration
- applying pilot credit without record
- changing invoice grouping without customer acknowledgement
- changing commercial scope without billing effective date
- changing operational scope without commercial amendment
- treating amendment as chat memory only

---

## 37. Non-Goals

This document does not define:

- final legal amendment template
- final electronic signature process
- final invoice automation
- final tax handling
- final ERP integration
- final accounting approval workflow
- final franchise contract change process
- final provider contract renegotiation

Those belong to later legal, finance, and commercial operations planning.

---

## 38. Readiness Check

This document is ready when the project can answer:

1. What does contract scope change mean?
2. What scope change types exist?
3. What status values exist?
4. What fields should scope change record include?
5. What fields should amendment record include?
6. When may module be added?
7. When may module be removed?
8. When may package upgrade occur?
9. When may package downgrade occur?
10. What is required to add store?
11. What is required to remove store?
12. How is support tier changed?
13. How is Provider Gateway scope changed?
14. How is provider cost changed?
15. How is hardware responsibility changed?
16. How is setup/training amended?
17. How is discount amended?
18. How is pilot credit amended?
19. What billing effective date rule applies?
20. When does proration apply?
21. When is customer acknowledgement required?
22. When is limitation disclosure updated?
23. When is security review triggered?
24. When is operational readiness review triggered?
25. When is billing review triggered?
26. What approval decisions exist?
27. When may scope change reverse?
28. How is scope change dispute handled?
29. What amendment versioning rule applies?
30. What anti-patterns are prohibited?

If these questions cannot be answered, multi-store contract scope change and commercial amendment governance planning is incomplete.

---

## 39. Conclusion

Multi-store SaaS contracts will change often as stores, modules, providers, support tiers, hardware, discounts, and billing responsibilities evolve.

The safe amendment flow is:

    requested change
        -> operational readiness review
        -> security/provider/support review
        -> billing impact review
        -> limitation disclosure update
        -> customer acknowledgement
        -> amendment record
        -> effective date
        -> evidence preservation

This document ensures that commercial scope remains aligned with operational reality and that module changes, store changes, provider costs, support fees, and billing effects do not become hidden disputes or uncontrolled revenue leakage.