# 014091_Policy_Multi_Store_Commercial_Risk_Pricing_Margin

## 1. Purpose

This document defines the multi-store commercial risk register, pricing governance, discount discipline, provider cost risk, support cost risk, margin protection, package boundary control, renewal pricing review, and commercial decision evidence policy for the Yoonsul Wait/Order Handoff documentation project.

The previous document defined commercial audit trail, invoice dispute, and customer trust recovery policy.

This document defines how commercial risks must be tracked before pricing confusion, unmanaged discounts, hidden provider costs, support overload, or unstable package promises damage SaaS margin and customer trust.

This document does not implement financial modeling, pricing software, accounting margin calculation, CRM automation, contract approval workflow, or legal terms.

It defines commercial risk and pricing governance policy only.

---

## 2. Scope

This document covers:

- commercial risk register
- pricing governance
- discount control
- pilot credit control
- provider cost risk
- support cost risk
- hardware cost risk
- package boundary risk
- margin protection
- renewal pricing review
- expansion pricing review
- commercial approval evidence
- no-implementation boundary

This document does not cover:

- final price list
- final legal pricing terms
- final accounting margin calculation
- final tax treatment
- final invoice automation
- final CRM discount workflow
- final revenue recognition rule
- final franchise royalty model
- final investor financial model

---

## 3. Core Principle

Commercial growth must not destroy margin or trust.

The project must follow this rule:

> Pricing, discounts, provider costs, support obligations, hardware responsibility, package scope, renewal terms, and commercial exceptions must be governed with evidence so that growth does not produce hidden losses, customer disputes, or unscalable support burden.

Revenue without margin discipline is fragile.

Discount without expiration becomes hidden standard price.

Support without pricing becomes operational debt.

---

## 4. Commercial Risk Meaning

Commercial risk means any condition that may damage:

- SaaS revenue quality
- gross margin
- support capacity
- customer trust
- renewal probability
- pricing credibility
- provider cost stability
- hardware cost recovery
- package clarity
- franchise scalability
- expansion economics
- commercial audit trail

Commercial risk may originate from product, provider, support, pricing, billing, sales, onboarding, or customer expectation.

---

## 5. Commercial Risk Categories

Recommended commercial risk categories:

- `PRICING_CONFUSION_RISK`
- `DISCOUNT_OVERUSE_RISK`
- `PILOT_CREDIT_DRIFT_RISK`
- `PROVIDER_COST_INCREASE_RISK`
- `PROVIDER_PASS_THROUGH_OPACITY_RISK`
- `SUPPORT_COST_UNDERPRICING_RISK`
- `HARDWARE_COST_RECOVERY_RISK`
- `PACKAGE_SCOPE_MISMATCH_RISK`
- `MODULE_MARGIN_RISK`
- `SETUP_TRAINING_UNDERCHARGE_RISK`
- `BILLING_DISPUTE_RISK`
- `RENEWAL_PRICE_OBJECTION_RISK`
- `DOWNGRADE_PRESSURE_RISK`
- `CHURN_PRICE_RISK`
- `EXPANSION_UNPROFITABLE_RISK`
- `FRANCHISE_SCALE_PRICING_RISK`
- `CUSTOM_DEAL_COMPLEXITY_RISK`
- `UNKNOWN_COMMERCIAL_RISK`

Risk category guides decision.

---

## 6. Commercial Risk Severity Values

Recommended severity values:

- `COMMERCIAL_RISK_CRITICAL`
- `COMMERCIAL_RISK_HIGH`
- `COMMERCIAL_RISK_MEDIUM`
- `COMMERCIAL_RISK_LOW`
- `COMMERCIAL_OBSERVATION`

Severity should reflect impact on revenue, margin, retention, support capacity, and repeatability.

---

## 7. Commercial Risk Status Values

Recommended status values:

- `RISK_OPEN`
- `RISK_UNDER_REVIEW`
- `EVIDENCE_REQUIRED`
- `PRICING_REVIEW_REQUIRED`
- `SUPPORT_REVIEW_REQUIRED`
- `PROVIDER_REVIEW_REQUIRED`
- `BILLING_REVIEW_REQUIRED`
- `APPROVAL_REQUIRED`
- `MITIGATION_DEFINED`
- `MITIGATION_ACTIVE`
- `RISK_ACCEPTED`
- `RISK_RESOLVED`
- `RISK_DEFERRED`
- `RISK_SUPERSEDED`

Risk status must remain visible until closed or accepted.

---

## 8. Commercial Risk Record Fields

Each commercial risk record should include:

- commercial risk id
- customer/tenant if applicable
- store or store group if applicable
- risk category
- severity
- status
- affected package
- affected module
- affected provider
- affected support tier
- affected billing line
- estimated revenue impact
- estimated cost impact
- margin impact placeholder
- root cause
- evidence reference
- proposed mitigation
- approval owner
- decision
- next review date
- notes

This record connects commercial risk to evidence.

---

## 9. Commercial Risk ID Format

Recommended format:

    COMMERCIAL-RISK-[YYYYMMDD]-[NUMBER]

Example:

    COMMERCIAL-RISK-20260612-001

Customer-specific alternative:

    COMMERCIAL-RISK-[CUSTOMER]-[YYYYMMDD]-[NUMBER]

Final format may be normalized later.

---

## 10. Pricing Governance Meaning

Pricing governance means controlling:

- standard price
- pilot price
- early adopter price
- renewal price
- expansion price
- support tier price
- provider gateway fee
- hardware fee
- setup/training fee
- discount
- credit
- exception
- amendment

Pricing must be understandable, repeatable, and evidence-based.

---

## 11. Standard Price Boundary

Standard price should represent the normal price for a defined package under defined scope.

Standard price should include:

- package name
- included modules
- excluded modules
- store count assumption
- support tier assumption
- provider dependency assumption
- hardware exclusion or inclusion
- setup fee assumption
- billing period
- limitation disclosure
- effective date
- approval owner

Standard price must not be rewritten silently by discount.

---

## 12. Package Price Record Fields

Each package price record should include:

- package price id
- package name
- module scope
- store scope
- support tier
- provider gateway inclusion
- hardware inclusion or exclusion
- setup/training inclusion or exclusion
- standard price
- pilot price if any
- early adopter price if any
- renewal price rule
- effective date
- expiration or review date
- approval owner
- notes

Package price must remain traceable.

---

## 13. Package Price ID Format

Recommended format:

    PACKAGE-PRICE-[PACKAGE]-[YYYYMMDD]

Example:

    PACKAGE-PRICE-STOREOSPLUS-20260612

Final format may be normalized later.

---

## 14. Discount Governance Rule

Discount may be used only when:

- reason is clear
- duration is defined
- affected line item is defined
- standard price remains visible
- support/provider/hardware inclusion is clear
- renewal effect is defined
- approval owner is recorded
- customer acknowledgement exists
- expiration notice path exists

Discount must not be used to avoid explaining value.

---

## 15. Discount Risk Examples

Discount risk appears when:

- discount has no end date
- discount covers provider cost accidentally
- discount covers support burden accidentally
- pilot discount becomes renewal expectation
- customer compares discounted price to standard price later
- salesperson promises custom price informally
- discount hides unresolved product weakness
- discount makes multi-store expansion unprofitable

Discount must be disciplined.

---

## 16. Pilot Credit Governance Rule

Pilot credit may be granted only when:

- pilot contribution is documented
- credit amount is defined
- credit duration is defined
- affected line item is defined
- standard price remains visible
- conversion record links to credit
- expiration is clear
- renewal effect is clear

Pilot credit is not general discount.

---

## 17. Provider Cost Risk Rule

Provider cost risk must be opened when:

- provider fee changes
- provider pass-through is unclear
- provider cost is bundled invisibly
- provider incident increases support burden
- provider usage fee increases with volume
- provider dealer support cost appears
- local daemon licensing cost appears
- payment provider fee structure changes
- KDS/kiosk provider cost changes
- customer expects Yoonsul to absorb provider cost

Provider cost risk must be disclosed before renewal or expansion.

---

## 18. Provider Cost Evidence Fields

Provider cost evidence should include:

- provider name
- provider stack id
- cost type
- cost basis
- affected store
- affected module
- start date
- end date if any
- pass-through status
- margin or referral status if any
- customer disclosure status
- billing line reference
- notes

Provider cost must not remain vague.

---

## 19. Support Cost Risk Rule

Support cost risk must be opened when:

- support case volume exceeds package assumption
- high-severity support cases repeat
- provider coordination consumes support time
- payment/KDS recovery support is frequent
- staff training repeats
- customer expects premium support on basic plan
- after-hours support expectation appears
- multi-store support overlap increases
- support margin becomes unclear

Support cost risk may require price or tier adjustment.

---

## 20. Support Cost Evidence Fields

Support cost evidence should include:

- support tier
- support case count
- support severity mix
- support hours estimate
- provider coordination count
- payment review count
- KDS review count
- training sessions
- after-hours requests
- package price reference
- support margin concern
- notes

Support cost must be visible before scale.

---

## 21. Hardware Cost Risk Rule

Hardware cost risk must be opened when:

- hardware is subsidized
- ownership is unclear
- rental period is unclear
- replacement responsibility is unclear
- maintenance cost is unclear
- device loss/damage rule is unclear
- hardware installation cost is underestimated
- provider hardware dependency changes
- customer expects free replacement

Hardware cost can silently damage margin.

---

## 22. Setup And Training Undercharge Rule

Setup/training undercharge risk appears when:

- onboarding takes longer than expected
- provider setup is complex
- staff training repeats
- KDS training requires multiple sessions
- support playbook setup is custom
- store profile is complex
- franchise rollout requires structured materials
- customer expects unlimited onboarding

Setup/training must be priced or scoped.

---

## 23. Package Scope Risk Rule

Package scope risk must be opened when:

- package name implies unsupported function
- customer expects provider compatibility not included
- customer expects KDS automation not enabled
- support tier expectation differs from package
- hardware inclusion is unclear
- Mini Kiosk scope is misunderstood
- export/report scope is misunderstood
- HQ dashboard scope is misunderstood
- franchise governance scope is assumed but not included

Package clarity protects retention.

---

## 24. Module Margin Risk Rule

Module margin risk should be reviewed for:

- Mini Kiosk module
- KDS handoff module
- Provider Gateway module
- Support add-on
- Store OS package
- HQ dashboard package
- setup/training fee
- hardware rental
- export/report fee
- franchise module

Each module should eventually prove price supports cost and support burden.

---

## 25. Custom Deal Complexity Risk

Custom deal risk appears when:

- customer has special price
- customer has special support term
- customer has special provider setup
- customer has special hardware ownership
- customer has special discount
- customer has custom module bundle
- customer has unique invoice grouping
- customer has informal exception

Custom deal complexity should be minimized early.

---

## 26. Commercial Approval Levels

Recommended approval levels:

- `APPROVAL_NOT_REQUIRED`
- `CUSTOMER_SUCCESS_APPROVAL`
- `BILLING_OWNER_APPROVAL`
- `SUPPORT_OWNER_APPROVAL`
- `PROVIDER_OWNER_APPROVAL`
- `BUSINESS_OWNER_APPROVAL`
- `FINANCE_REVIEW_REQUIRED`
- `LEGAL_REVIEW_REQUIRED`
- `EXECUTIVE_REVIEW_REQUIRED`

Approval level should match commercial risk.

---

## 27. Commercial Approval Trigger

Approval is required when:

- discount exceeds allowed range
- credit exceeds allowed range
- provider cost is absorbed
- support obligation increases
- hardware is subsidized
- custom package is created
- multi-store price differs from standard
- renewal price changes materially
- billing dispute requires large adjustment
- contract scope exception is requested
- margin impact is unknown

Approval prevents uncontrolled exceptions.

---

## 28. Margin Protection Principle

Margin protection means:

- do not price below support burden unknowingly
- do not absorb provider cost silently
- do not subsidize hardware without plan
- do not promise unsupported modules
- do not offer unlimited support casually
- do not let discount become permanent
- do not expand unprofitable custom deal
- do not ignore billing dispute patterns

Margin protection is not greed.

It is survivability.

---

## 29. Margin Risk Review Fields

Margin risk review should include:

- package revenue
- module revenue
- support cost estimate
- provider pass-through exposure
- hardware exposure
- setup/training effort
- discount/credit amount
- incident support burden
- expansion impact
- renewal risk
- decision
- notes

Exact margin calculation may be added later.

This policy only requires risk visibility.

---

## 30. Renewal Pricing Review Rule

Before renewal, review:

- current price
- standard price
- discount expiration
- provider cost changes
- support burden
- usage and value evidence
- open billing disputes
- package fit
- downgrade risk
- upgrade signal
- customer price objection
- renewal proposal

Renewal price should reflect value and cost.

---

## 31. Expansion Pricing Review Rule

Before adding store, review:

- additional store fee
- module fee
- provider cost
- support capacity
- onboarding/setup effort
- training cost
- hardware cost
- discount applicability
- multi-store package discount
- scope restriction
- margin risk

Expansion should not be priced as a simple copy if support/provider burden differs.

---

## 32. Price Exception Rule

Price exception may be allowed only when:

- reason is documented
- standard price is preserved
- duration is defined
- affected line item is clear
- margin risk reviewed
- approval owner recorded
- renewal effect defined
- customer acknowledgement exists

Price exception must not become undocumented precedent.

---

## 33. Price Exception Record Fields

Price exception should include:

- exception id
- customer/store
- standard price
- exception price
- affected line item
- reason
- start date
- end date
- margin risk
- approval owner
- renewal effect
- customer acknowledgement
- status
- notes

Exception history is commercial evidence.

---

## 34. Price Exception ID Format

Recommended format:

    PRICE-EXCEPTION-[CUSTOMER]-[YYYYMMDD]-[NUMBER]

Example:

    PRICE-EXCEPTION-CUST001-20260612-001

Final format may be normalized later.

---

## 35. Pricing Review Decision Values

Recommended values:

- `NO_CHANGE`
- `STANDARD_PRICE_CONFIRMED`
- `DISCOUNT_APPROVED`
- `DISCOUNT_REJECTED`
- `CREDIT_APPROVED`
- `CREDIT_REJECTED`
- `PRICE_EXCEPTION_APPROVED`
- `PRICE_EXCEPTION_REJECTED`
- `SUPPORT_TIER_CHANGE_REQUIRED`
- `PROVIDER_COST_DISCLOSURE_REQUIRED`
- `PACKAGE_SCOPE_UPDATE_REQUIRED`
- `MARGIN_REVIEW_REQUIRED`
- `FINANCE_REVIEW_REQUIRED`
- `LEGAL_REVIEW_REQUIRED`

Decision must be recorded.

---

## 36. Commercial Risk Mitigation Options

Possible mitigation options:

- clarify package scope
- separate provider pass-through
- adjust support tier
- limit discount duration
- issue one-time credit
- require setup/training fee
- restrict module scope
- pause unprofitable expansion
- revise renewal proposal
- convert custom deal to standard package
- create billing clarification
- update sales/onboarding script
- escalate to finance/legal review

Mitigation should match risk category.

---

## 37. Pricing Feedback Loop

Commercial risk should update:

- package design
- standard price
- discount policy
- support tier policy
- provider pass-through policy
- hardware policy
- setup/training policy
- renewal process
- expansion pricing
- billing line naming
- onboarding disclosure
- customer success scripts

Pricing governance improves through evidence.

---

## 38. Commercial Risk Review Cadence

Recommended cadence:

| Review | Cadence |
| ------ | ------- |
| Critical commercial risk | immediate |
| High commercial risk | weekly |
| Renewal pricing risk | before renewal |
| Expansion pricing risk | before expansion approval |
| Support cost risk | monthly |
| Provider cost risk | before renewal/expansion |
| Discount policy review | monthly during early SaaS |
| Package margin review | quarterly or after major incidents |

Cadence should match risk.

---

## 39. Registers Recommendation

Recommended future files:

    docs/_index/
      Commercial_Risk_Register.md
      Package_Price_Register.md
      Discount_Governance_Register.md
      Pilot_Credit_Register.md
      Provider_Cost_Risk_Register.md
      Support_Cost_Risk_Register.md
      Hardware_Cost_Risk_Register.md
      Price_Exception_Register.md
      Margin_Risk_Review_Register.md

This document only recommends these files.

It does not create them.

---

## 40. Anti-Patterns

The following are prohibited:

- giving discount without expiration
- absorbing provider cost silently
- underpricing support to close deal
- bundling hardware without ownership clarity
- creating custom package for every customer
- hiding package limitations
- using discount to hide weak value
- offering expansion price without support review
- offering renewal price without provider cost review
- treating pilot credit as permanent discount
- ignoring setup/training effort
- approving price exception without evidence
- allowing sales promise to override operational readiness
- treating revenue as healthy while margin is unknown

---

## 41. Non-Goals

This document does not define:

- final pricing table
- final margin formula
- final finance model
- final investor forecast
- final accounting policy
- final tax treatment
- final legal contract pricing clause
- final CRM approval workflow

Those belong to later finance, legal, and commercial operations planning.

---

## 42. Readiness Check

This document is ready when the project can answer:

1. What is commercial risk?
2. What commercial risk categories exist?
3. What severity values exist?
4. What status values exist?
5. What fields should commercial risk record include?
6. What is pricing governance?
7. What is standard price boundary?
8. What fields should package price record include?
9. What discount governance rule applies?
10. What discount risks exist?
11. What pilot credit governance rule applies?
12. When is provider cost risk opened?
13. What fields should provider cost evidence include?
14. When is support cost risk opened?
15. What fields should support cost evidence include?
16. When is hardware cost risk opened?
17. When is setup/training undercharge risk opened?
18. When is package scope risk opened?
19. How is module margin risk reviewed?
20. What is custom deal complexity risk?
21. What approval levels exist?
22. What triggers commercial approval?
23. What is margin protection principle?
24. What fields should margin risk review include?
25. What renewal pricing review applies?
26. What expansion pricing review applies?
27. When may price exception be allowed?
28. What fields should price exception record include?
29. What pricing review decisions exist?
30. What mitigation options exist?
31. What pricing feedback loop applies?
32. What review cadence applies?
33. What anti-patterns are prohibited?

If these questions cannot be answered, commercial risk, pricing governance, and margin protection planning is incomplete.

---

## 43. Conclusion

Multi-store SaaS needs commercial discipline as much as technical discipline.

The safe commercial governance flow is:

    pricing scope
        -> standard price record
        -> discount or credit control
        -> provider/support/hardware cost review
        -> margin risk review
        -> commercial approval
        -> renewal or expansion decision
        -> billing evidence
        -> pricing feedback loop

This document protects the project from growing revenue while silently losing margin through unmanaged discounts, hidden provider costs, underpriced support, unclear hardware responsibility, custom deal complexity, and package scope confusion.