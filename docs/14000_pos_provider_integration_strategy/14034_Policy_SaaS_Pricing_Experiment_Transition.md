# 14034_Policy_SaaS_Pricing_Experiment_Transition

## 1. Purpose

This document defines the SaaS pricing experiment, pilot discount, early adopter discount, paid pilot price, standard price transition, discount expiration, value proof, and pricing evidence governance policy for the Yoonsul Wait/Order Handoff project.

The previous document defined churn reason taxonomy and product/pricing feedback loop.

This document defines how pricing should be tested without creating permanent discount traps, unclear customer expectations, or unsafe revenue pressure.

This document does not define final prices, billing implementation, tax treatment, legal contract, or payment collection.

It defines pricing experiment governance only.

---

## 2. Scope

This document covers:

- pricing experiment structure
- pilot discount rule
- early adopter discount rule
- paid pilot pricing
- standard price transition
- discount expiration
- value proof requirement
- pricing objection recording
- provider fee separation
- hardware fee separation
- support fee separation
- franchise pricing transition
- no-implementation boundary

This document does not cover:

- final SaaS price
- final franchise fee
- final billing system
- final payment method
- final invoice design
- final legal contract
- final tax/accounting policy
- final discount automation
- final sales deck

---

## 3. Core Principle

Pricing experiments must create learning, not confusion.

The project must follow this rule:

> A discount is useful only if it helps measure value, adoption, support burden, and conversion likelihood. A discount that hides weak value or creates permanent expectation is dangerous.

Pricing should be tested with written scope, duration, and transition path.

---

## 4. Pricing Experiment Types

Recommended pricing experiment types:

| Experiment Type | Meaning |
| --------------- | ------- |
| Free Discovery | no charge, observation only |
| Free Controlled Pilot | limited free test with evidence |
| Paid Pilot | limited paid use with reduced price |
| Early Adopter Discount | temporary discount for early SaaS users |
| Module Trial | specific add-on tested for limited period |
| Support Trial | support tier tested temporarily |
| Launch Kit Discount | setup/onboarding discount |
| Hardware Subsidy | temporary hardware cost support |
| Provider Setup Waiver | temporary provider setup discount |
| Standard Price Transition | move from discount to normal price |

Each experiment must have explicit end condition.

---

## 5. Pricing Experiment Record

Every pricing experiment should create a record.

Recommended ID format:

    PRICE-EXP-[STORE-ID]-[YYYYMMDD]-[NUMBER]

Examples:

    PRICE-EXP-PSTORE-001-20260612-001
    PRICE-EXP-PSTORE-002-20260612-001

Required fields:

- pricing experiment id
- customer/store id
- package
- modules
- current stage
- experiment type
- experiment price
- standard price reference
- discount amount
- discount reason
- start date
- end date
- conversion date
- included scope
- excluded scope
- support scope
- provider fee treatment
- hardware fee treatment
- evidence expected
- success criteria
- renewal rule
- owner
- review status

---

## 6. Pricing Experiment Status Values

Recommended status values:

- `DRAFT`
- `UNDER_REVIEW`
- `APPROVED`
- `ACTIVE`
- `NEEDS_REVIEW`
- `CONVERSION_PENDING`
- `CONVERTED_TO_STANDARD`
- `EXTENDED_WITH_APPROVAL`
- `EXPIRED`
- `CANCELLED`
- `REJECTED`
- `SUPERSEDED`

A pricing experiment must not remain active indefinitely without review.

---

## 7. Free Discovery Pricing Rule

Free Discovery should be used for:

- store observation
- provider stack discovery
- pain point interview
- operational fit assessment
- pilot eligibility assessment

Free Discovery should not include:

- production support
- full module use
- custom integration
- provider adapter development
- SLA
- permanent discount promise
- hardware subsidy commitment

Free Discovery has no price, but also no paid service obligation.

---

## 8. Free Controlled Pilot Pricing Rule

Free Controlled Pilot may be used when:

- store can produce useful evidence
- scope is limited
- support burden is manageable
- pilot duration is short
- data permission is clear
- conversion review is planned

Free Controlled Pilot must define:

- pilot period
- included modules
- excluded modules
- support scope
- evidence expected
- conversion review date
- whether future price may apply

Free pilot must not imply permanent free use.

---

## 9. Paid Pilot Pricing Rule

Paid Pilot may be used when:

- value is visible but product is not yet standard
- support burden exists
- customer wants continued use
- modules are controlled
- limitations are understood
- pricing is still experimental

Paid Pilot must define:

- paid pilot price
- duration
- included modules
- excluded modules
- support level
- provider fees
- hardware fees
- standard price reference
- conversion decision date
- cancellation rule

Paid Pilot price is not final standard price.

---

## 10. Early Adopter Discount Rule

Early Adopter Discount may be used when customer accepts early product maturity and provides feedback.

Required conditions:

- limited duration
- written discount reason
- standard price reference
- feedback obligation where appropriate
- support boundary
- conversion path
- no permanent discount promise
- review date

Early adopter discount should reward learning partnership.

It should not hide weak product value.

---

## 11. Module Trial Rule

Module Trial may apply to:

- Mini Kiosk
- KDS
- Analytics
- Provider Gateway
- Support Package
- Franchise OS discovery
- multi-store dashboard

Module Trial must define:

- trial module
- trial duration
- trial success metric
- module price after trial
- deactivation rule
- support scope
- evidence required

Module trial must not create unsafe partial runtime.

---

## 12. Support Trial Rule

Support Trial may test support tier value.

Support Trial may include:

- operations support
- provider support coordination
- payment recovery support
- KDS issue review
- monthly report review
- owner dashboard review

Support Trial must define:

- support scope
- response expectation
- excluded support
- provider/dealer boundary
- trial duration
- support price after trial

Support trial must not promise full SLA unless ready.

---

## 13. Launch Kit Discount Rule

Launch Kit Discount may be used for:

- first store
- pilot store
- strategic partner
- nearby friendly test store
- hardware partner validation
- franchise candidate test

Launch Kit Discount must define:

- setup services included
- hardware included or excluded
- provider setup included or excluded
- training included or excluded
- evidence expected
- discount expiration

Launch Kit discount should not hide real onboarding cost.

---

## 14. Hardware Subsidy Rule

Hardware subsidy may be used carefully.

Hardware subsidy may apply to:

- tablet
- kiosk device
- KDS screen
- printer
- payment terminal
- scanner
- mount
- network accessory

Hardware subsidy must define:

- hardware owner
- subsidy amount
- return obligation
- warranty owner
- replacement owner
- device trust removal
- condition after cancellation
- conversion to paid hardware arrangement

Hardware subsidy can create hidden cost if not tracked.

---

## 15. Provider Setup Waiver Rule

Provider setup waiver may apply to:

- Toss setup
- OKPOS/OKDC setup
- PAYCO setup
- provider gateway configuration
- dealer coordination
- test environment setup

Provider setup waiver must define:

- provider involved
- setup scope
- waived fee
- future fee
- support boundary
- provider access limitation
- blocker status

Provider setup waiver must not hide complex provider cost.

---

## 16. Standard Price Reference

Every discount should reference a future standard price or standard price placeholder.

If final standard price is not known, use:

    STANDARD_PRICE_PENDING

But still record:

- expected pricing tier
- expected module family
- expected future review
- reason final price is pending
- what evidence is needed

Do not leave discount disconnected from future pricing.

---

## 17. Standard Price Transition

Standard price transition should occur when:

- product scope is stable
- support burden is known
- customer value is proven
- module usage is sufficient
- provider stack is stable
- customer understands package
- discount period ends
- conversion review is complete

Transition should record:

- old price
- new price
- effective date
- reason
- customer notice
- package scope
- support scope
- provider fee treatment
- hardware fee treatment
- renewal decision

---

## 18. Discount Extension Rule

Discount extension may be allowed when:

- product limitation remains
- provider blocker delayed value
- hardware issue interrupted use
- support review is pending
- customer provided strong evidence value
- standard price is not ready

Discount extension must require:

- written reason
- new end date
- owner approval
- impact on support cost
- conversion review date

Do not extend discount silently.

---

## 19. Discount Expiration Rule

When discount expires:

- notify customer before expiration
- review value evidence
- review support burden
- review module usage
- review provider issues
- confirm standard price
- offer upgrade/downgrade if appropriate
- record decision

Expiration outcomes:

- convert to standard price
- extend with approval
- downgrade
- cancel
- pause
- continue paid pilot
- revise package

Discount expiration is a lifecycle event.

---

## 20. Pricing Evidence Required

Pricing decision should use evidence:

- module usage
- owner satisfaction
- staff adoption
- payment recovery value
- KDS value
- Mini Kiosk value
- support burden
- provider reliability
- hardware reliability
- pricing objection
- alternative vendor comparison
- willingness to pay
- renewal intention
- churn risk

Pricing must follow evidence, not guesswork.

---

## 21. Pricing Objection Record

Pricing objection should be recorded.

Required fields:

- objection id
- customer/store id
- package
- module
- quoted price
- objection type
- customer statement summary
- compared alternative
- perceived value gap
- provider fee confusion
- hardware fee confusion
- support fee confusion
- response given
- follow-up action
- discount offered
- outcome

Pricing objection must feed the churn/pricing feedback loop.

---

## 22. Provider Fee Separation

Provider fees must be separated from SaaS pricing.

Provider fees may include:

- POS provider fee
- payment provider fee
- VAN/PG fee
- OKDC/API access fee
- dealer support fee
- payment terminal fee
- smart order channel fee
- kiosk vendor fee

Customer-facing quote should clarify:

    Yoonsul SaaS Fee
    Provider Fee
    Hardware Fee
    Support Fee
    Setup Fee

Do not hide provider cost inside confusing SaaS price.

---

## 23. Hardware Fee Separation

Hardware fees must be separated.

Hardware fee categories:

- purchase
- lease
- rental
- deposit
- maintenance
- replacement
- warranty
- installation
- return penalty

Hardware cost should not obscure SaaS value.

---

## 24. Support Fee Separation

Support fee should be separated or clearly bundled.

Support fee categories:

- Basic Support
- Operations Support
- Provider Support Coordination
- Premium Operations Support
- Franchise Support

If support is included, define included support.

If not included, define excluded support.

Ambiguous support fee creates churn risk.

---

## 25. Franchise Pricing Experiment

Franchise pricing experiment may be needed later.

Potential experiments:

- HQ pays Franchise OS only
- store pays Store OS only
- HQ/store split
- per-store technology fee
- launch kit included
- support package included
- provider gateway included
- KDS/Mini Kiosk add-ons
- analytics included at HQ level

Franchise pricing experiment should not start until store-level value is proven.

---

## 26. Pricing Experiment Success Criteria

Pricing experiment is successful when:

- customer understands scope
- customer sees value
- usage supports value
- support burden is sustainable
- price objection is understood
- conversion path is clear
- discount does not create confusion
- provider/hardware/support fees are separated
- renewal decision is possible

Success is not only customer saying yes.

---

## 27. Pricing Experiment Failure Criteria

Pricing experiment fails when:

- customer accepts only because price is free
- customer does not understand value
- support burden exceeds price
- module usage is low
- staff bypasses system
- provider issues dominate
- customer expects permanent discount
- hardware cost causes conflict
- support scope is unclear
- standard price transition is rejected
- product limitation blocks value

Failure should become pricing feedback.

---

## 28. Pricing Review Cadence

Recommended review cadence:

| Timing | Review Focus |
| ------ | ------------ |
| Start of pilot | scope, discount, evidence expected |
| Mid-pilot | usage, support burden, value signal |
| End of pilot | willingness to pay, conversion |
| First paid month | support cost and value confirmation |
| Discount expiration | standard price transition |
| Renewal | package fit and price acceptance |
| After churn | pricing feedback loop |

Pricing should be reviewed regularly in early stage.

---

## 29. Pricing Decision Outcomes

Recommended outcomes:

- `CONTINUE_FREE_PILOT`
- `START_PAID_PILOT`
- `EXTEND_FREE_PILOT`
- `EXTEND_PAID_PILOT`
- `CONVERT_TO_STANDARD_PRICE`
- `CONVERT_WITH_DISCOUNT`
- `DOWNGRADE_PACKAGE`
- `UPGRADE_PACKAGE`
- `PAUSE_PRICING_DECISION`
- `CANCEL_AFTER_PRICE_REVIEW`
- `REVISE_PACKAGE`
- `REVISE_PRICING_MESSAGE`

Outcome must be recorded.

---

## 30. Anti-Patterns

The following are prohibited:

- giving discount with no end date
- extending discount silently
- using discount to hide weak value
- quoting price without package scope
- hiding provider fees
- hiding hardware fees
- hiding support limits
- making pilot discount permanent accidentally
- changing price based only on emotion
- setting standard price from one store
- promising future module to justify current price
- charging for module with unsafe runtime
- starting franchise pricing before store value proof
- treating customer yes as proof without usage

---

## 31. Non-Goals

This document does not define:

- final price list
- final billing automation
- final payment collection
- final tax policy
- final contract wording
- final discount approval workflow
- final franchise technology fee
- final sales deck

Those belong to later business planning and legal/accounting review.

---

## 32. Readiness Check

This document is ready when the project can answer:

1. What pricing experiment types exist?
2. What fields must pricing experiment record include?
3. What status values exist?
4. How is Free Discovery priced?
5. How is Free Controlled Pilot priced?
6. How is Paid Pilot priced?
7. When is Early Adopter Discount allowed?
8. How is Module Trial controlled?
9. How is Support Trial controlled?
10. How is Launch Kit Discount controlled?
11. How is Hardware Subsidy controlled?
12. How is Provider Setup Waiver controlled?
13. What is standard price reference?
14. When does standard price transition occur?
15. When can discount be extended?
16. How is discount expiration handled?
17. What pricing evidence is required?
18. What pricing objection record is required?
19. How are provider fees separated?
20. How are hardware fees separated?
21. How are support fees separated?
22. How is franchise pricing experiment deferred?
23. What makes pricing experiment successful?
24. What makes pricing experiment fail?
25. What pricing review cadence applies?
26. What pricing decision outcomes exist?
27. What anti-patterns are prohibited?

If these questions cannot be answered, SaaS pricing experiment and standard price transition planning is incomplete.

---

## 33. Conclusion

Yoonsul pricing must be tested carefully.

The project should use:

- Free Discovery
- Free Controlled Pilot
- Paid Pilot
- Early Adopter Discount
- Module Trial
- Support Trial
- Launch Kit Discount
- Hardware Subsidy
- Provider Setup Waiver
- Standard Price Transition

Each pricing experiment must record:

- scope
- duration
- discount reason
- standard price reference
- provider fee separation
- hardware fee separation
- support fee separation
- value evidence
- support burden
- conversion path
- expiration rule

This document prevents discount chaos and prepares disciplined SaaS pricing before broader Franchise OS expansion.