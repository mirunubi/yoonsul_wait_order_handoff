# 14026_Policy_Pilot_To_Paid_SaaS_Conversion_Commitment

## 1. Purpose

This document defines the pilot-to-paid SaaS conversion, early customer commitment, paid pilot boundary, conversion decision record, pricing transition, scope confirmation, support commitment, and early customer risk control policy for the Yoonsul Wait/Order Handoff project.

The previous document defined how pilot incidents must be converted into blockers, requirements, deferred items, support rules, and next-store learning.

This document defines what happens when a pilot store shows enough value to move toward paid SaaS.

This document does not sell SaaS, create billing, execute contracts, collect payment, or implement subscription logic.

It defines conversion and commitment policy only.

---

## 2. Scope

This document covers:

- free pilot to paid pilot conversion
- paid pilot to SaaS subscription conversion
- early customer commitment
- conversion eligibility
- conversion blockers
- pricing transition
- module scope confirmation
- support commitment
- data use confirmation
- provider fee separation
- hardware fee separation
- Franchise OS future upgrade path
- no-implementation boundary

This document does not cover:

- final SaaS price
- final billing system
- final contract language
- final tax/accounting policy
- final payment collection
- final legal approval
- final franchise agreement
- final subscription code
- final customer success system

---

## 3. Core Principle

A pilot must not become paid SaaS by accident.

The project must follow this rule:

> A store may convert from pilot to paid SaaS only when value, scope, support, pricing, provider boundary, data responsibility, and rollback path are clearly recorded.

Free test success does not automatically mean paid SaaS readiness.

Paid commitment requires controlled scope.

---

## 4. Conversion Stages

Recommended conversion stages:

| Stage | Meaning |
| ----- | ------- |
| Free Discovery | early observation, no paid promise |
| Free Controlled Pilot | defined pilot with scope and evidence |
| Paid Pilot | limited paid use with controlled support |
| Early SaaS Subscription | paid recurring use with defined package |
| Standard SaaS Customer | normal package after product maturity |
| Franchise SaaS Customer | HQ/store SaaS under franchise structure |

Do not skip scope review between stages.

---

## 5. Free Discovery

Free Discovery is the earliest stage.

Purpose:

- understand store operation
- inspect provider stack
- observe pain points
- assess pilot eligibility
- collect low-risk feedback
- determine whether controlled pilot is worthwhile

Free Discovery should not include:

- production SLA
- custom integration
- paid SaaS promise
- permanent discount promise
- full provider implementation
- full KDS/Mini Kiosk deployment
- Franchise OS promise

Free Discovery may lead to Free Controlled Pilot or rejection.

---

## 6. Free Controlled Pilot

Free Controlled Pilot includes:

- written pilot scope
- included modules
- excluded modules
- pilot period
- evidence permission
- support boundary
- rollback path
- owner feedback
- staff feedback
- incident recording
- retrospective

Free Controlled Pilot is useful for learning.

It is not yet a commercial customer relationship unless explicitly agreed.

---

## 7. Paid Pilot

Paid Pilot is a limited paid stage.

Paid Pilot may be used when:

- pilot value is visible
- store wants continued use
- support burden exists
- provider stack is manageable
- scope is controlled
- pricing is experimental
- product is not yet standard SaaS
- both sides understand limitations

Paid Pilot should have:

- pilot price
- pilot duration
- modules included
- support scope
- excluded features
- provider fee separation
- hardware fee separation
- data handling rule
- cancellation path
- conversion review date

Paid Pilot is not full standard SaaS.

---

## 8. Early SaaS Subscription

Early SaaS Subscription begins when:

- package scope is stable enough
- support scope is known
- store receives recurring value
- pricing can be explained
- provider integration is reliable enough
- support burden is sustainable
- rollback is defined
- billing responsibility is clear
- customer accepts limitations

Early SaaS Subscription may still have early-adopter conditions.

These conditions must be written.

---

## 9. Standard SaaS Customer

A store becomes standard SaaS customer when:

- package is standardized
- onboarding is repeatable
- support model is repeatable
- provider stack is supported
- pricing is standard
- contract terms are standard
- billing is stable
- downgrade/cancellation policy exists
- data retention/export policy exists

Standard SaaS should not begin before enough pilot evidence exists.

---

## 10. Franchise SaaS Customer

Franchise SaaS Customer involves:

- HQ billing
- store billing
- Franchise OS governance
- multi-store dashboard
- SOP/training linkage
- provider performance comparison
- store compliance
- owner role separation
- support escalation
- franchise contract linkage

Franchise SaaS conversion should occur only after store-level SaaS evidence is stable.

---

## 11. Conversion Eligibility

A pilot store is eligible for paid conversion when:

1. pilot evidence packet is complete
2. retrospective is complete
3. critical blockers are resolved or accepted
4. store owner sees clear value
5. staff adoption is adequate
6. support burden is measurable
7. provider stack is manageable
8. payment/refund boundary is clear
9. KDS/kitchen path is safe
10. data permission is confirmed
11. module scope is clear
12. excluded scope is clear
13. price expectation is discussed
14. rollback/cancellation path is known
15. next review date is defined

Eligibility must be recorded.

---

## 12. Conversion Blockers

Do not convert to paid SaaS when:

- payment truth is unclear
- refund/cancel ownership is unclear
- duplicate order risk remains high
- duplicate payment risk remains high
- KDS/kitchen output is unsafe
- provider stack is unsupported
- data access is insufficient
- staff refuses to use system
- owner value is weak
- support burden is unknown
- store expects unsupported custom development
- pilot discount expectation is unclear
- hardware reliability is poor
- rollback path is missing
- legal/data permission is unclear

Conversion must pause until blockers are addressed.

---

## 13. Conversion Decision Record

Each conversion decision should create record.

Recommended ID format:

    CONV-[PILOT-STORE-ID]-[YYYYMMDD]-[NUMBER]

Required fields:

- conversion id
- pilot store id
- evidence packet id
- retrospective id
- decision date
- current stage
- target stage
- selected package
- included modules
- excluded modules
- provider stack
- device stack
- price type
- pilot price
- expected standard price
- duration
- support scope
- provider fee responsibility
- hardware fee responsibility
- data responsibility
- unresolved blockers
- accepted risks
- cancellation path
- next review date
- reviewer
- approval status

---

## 14. Conversion Decision Status

Recommended status values:

- `DRAFT`
- `UNDER_REVIEW`
- `NEEDS_OWNER_CONFIRMATION`
- `NEEDS_PRICE_CONFIRMATION`
- `NEEDS_SUPPORT_CONFIRMATION`
- `NEEDS_PROVIDER_CONFIRMATION`
- `NEEDS_LEGAL_REVIEW`
- `BLOCKED`
- `APPROVED_FOR_PAID_PILOT`
- `APPROVED_FOR_EARLY_SAAS`
- `REJECTED`
- `DEFERRED`
- `SUPERSEDED`

Do not mark approved until scope and fee responsibility are clear.

---

## 15. Package Selection Rule

Paid conversion should map to a package.

Possible package mapping:

| Pilot Value Observed | Likely Package |
| -------------------- | -------------- |
| basic dashboard only | Store OS Basic |
| POS/KDS/payment recovery value | Store OS Plus |
| Mini Kiosk + provider gateway value | Store OS Pro |
| multi-store owner value | Store OS Pro + multi-store add-on |
| HQ governance value | Franchise OS HQ |
| integration-heavy value | Provider Gateway add-on |
| kitchen-heavy value | KDS add-on |
| customer self-order value | Mini Kiosk add-on |
| issue-heavy store | Support package |

Package should follow observed value.

Do not sell modules that were not tested or clearly explained.

---

## 16. Pricing Transition Rule

Pricing transition must be explicit.

Possible pricing types:

- free pilot
- paid pilot discount
- early adopter discount
- standard price
- custom pilot price
- store-specific setup fee
- provider setup fee
- hardware lease/purchase
- support package fee

Required pricing notes:

- start date
- end date
- renewal rule
- standard price after discount
- included modules
- excluded modules
- provider fees
- hardware fees
- cancellation rule
- tax/legal review if needed

Do not allow temporary discount to become unclear permanent price.

---

## 17. Early Adopter Discount

Early adopter discount may be allowed when:

- customer accepts limited product maturity
- customer provides feedback
- customer allows evidence use where permitted
- support scope is controlled
- discount period is limited
- conversion path is written

Early adopter discount must not:

- hide true cost
- create permanent low-price anchor
- force unsupported custom work
- bypass support limits
- bypass provider blockers

---

## 18. Provider Fee Separation

Paid conversion must separate provider fees.

Provider fees may include:

- Toss fee
- OKPOS / OKDC fee
- PAYCO fee
- VAN/PG fee
- payment terminal fee
- kiosk vendor fee
- dealer support fee
- API access fee
- hardware maintenance fee

Yoonsul SaaS fee must not be confused with provider fee unless bundled transparently and legally reviewed.

---

## 19. Hardware Fee Separation

Hardware fees must be separated.

Hardware costs may include:

- kiosk device
- tablet
- payment terminal
- printer
- scanner
- kitchen display
- mount
- network equipment
- installation
- warranty
- replacement

Hardware ownership must be recorded.

Hardware failure responsibility must be recorded.

---

## 20. Support Commitment

Paid conversion requires support commitment.

Support commitment should define:

- support channel
- support hours
- expected response type
- included support categories
- excluded support categories
- provider escalation boundary
- dealer escalation boundary
- emergency handling
- payment issue handling
- hardware issue handling
- training support
- support fee if separate

Support promise must match actual capacity.

---

## 21. Data Commitment

Paid conversion requires data commitment.

Data commitment should define:

- data collected
- data not collected
- data used for operations
- data used for pilot learning
- data used for anonymized improvement
- data retained
- data export rights
- data deletion rights
- sensitive data masking
- customer identity minimization
- payment data boundary
- staff data boundary

No paid SaaS conversion should proceed without data clarity.

---

## 22. Feature Commitment

Paid conversion must define feature commitment.

Feature categories:

- available now
- available during paid pilot
- planned later
- not included
- explicitly deferred
- unsupported

Do not imply that deferred features are included.

Do not convert wish list into commitment.

---

## 23. SLA Boundary

Early paid pilot should avoid full production SLA unless support capacity exists.

Recommended status:

    Limited support commitment, not full SLA.

Full SLA may require:

- mature product
- provider support contract
- incident response plan
- monitoring
- staffing
- legal agreement
- compensation policy
- billing maturity

Do not promise SLA prematurely.

---

## 24. Cancellation And Exit

Paid conversion must define exit path.

Exit path should include:

- cancellation notice
- billing stop date
- hardware return or ownership
- data export
- data retention
- provider fee termination
- device deactivation
- Mini Kiosk shutdown
- KDS shutdown
- support end date
- pending incident handling
- refund if applicable

Exit path prevents pilot relationship conflict.

---

## 25. Conversion Review Cadence

Paid pilot should be reviewed:

- at start
- after first week
- monthly
- after major incident
- before discount expires
- before standard pricing conversion
- before adding modules
- before expanding to another store

Review should update:

- value evidence
- support burden
- pricing fit
- module usage
- incident history
- blockers
- next decision

---

## 26. Conversion Outcome Values

Recommended outcome values:

- `CONVERT_TO_PAID_PILOT`
- `CONVERT_TO_EARLY_SAAS`
- `CONTINUE_FREE_PILOT`
- `EXTEND_PAID_PILOT`
- `CONVERT_TO_STANDARD_SAAS`
- `PAUSE_CONVERSION`
- `REJECT_CONVERSION`
- `DEFER_UNTIL_PROVIDER_READY`
- `DEFER_UNTIL_SUPPORT_READY`
- `DEFER_UNTIL_PRODUCT_READY`
- `EXIT_PILOT`

Outcome must be recorded.

---

## 27. Early Customer Risk Register

Risks:

| Risk | Description |
| ---- | ----------- |
| Scope Misunderstanding | customer thinks future feature is included |
| Permanent Discount Trap | pilot discount becomes expected standard |
| Support Overload | support demand exceeds capacity |
| Provider Dependency | provider issue blocks paid value |
| Hardware Failure | device issue harms SaaS perception |
| Staff Non-Adoption | staff stops using system |
| Owner Value Gap | owner does not see recurring value |
| Payment Incident | payment uncertainty damages trust |
| Data Concern | customer worries about data usage |
| Custom Demand | customer expects store-specific development |

Risks must be reviewed before conversion.

---

## 28. Sales Message Boundary

Early paid SaaS message should emphasize:

- controlled pilot
- limited scope
- real operational value
- support boundary
- future roadmap
- provider compatibility under verification
- no universal POS promise
- no full Franchise OS promise yet
- no guaranteed sales increase
- no unsafe automation

Be honest about maturity.

Trust is more important than early revenue.

---

## 29. Anti-Patterns

The following are prohibited:

- converting pilot to paid without evidence packet
- converting pilot to paid without retrospective
- charging before module scope is clear
- promising full SaaS while product is pilot-grade
- hiding provider fees
- hiding hardware fees
- promising standard SLA too early
- letting pilot discount become permanent accidentally
- bundling unsupported features into paid scope
- ignoring staff adoption
- ignoring support burden
- ignoring payment uncertainty
- converting weak value pilot just for revenue
- allowing custom development to define paid pilot

---

## 30. Non-Goals

This document does not define:

- final SaaS price
- final customer contract
- final invoice
- final payment method
- final subscription system
- final SLA
- final legal agreement
- final franchise fee
- final tax treatment

Those belong to later business planning and legal review.

---

## 31. Readiness Check

This document is ready when the project can answer:

1. What conversion stages exist?
2. What is Free Discovery?
3. What is Free Controlled Pilot?
4. What is Paid Pilot?
5. What is Early SaaS Subscription?
6. What is Standard SaaS Customer?
7. What is Franchise SaaS Customer?
8. When is pilot eligible for paid conversion?
9. What blocks paid conversion?
10. What conversion decision record is required?
11. What status values exist?
12. How is package selected?
13. How is pricing transition controlled?
14. When is early adopter discount allowed?
15. How are provider fees separated?
16. How are hardware fees separated?
17. What support commitment is required?
18. What data commitment is required?
19. What feature commitment is required?
20. What SLA boundary applies?
21. How is cancellation handled?
22. What review cadence applies?
23. What outcome values exist?
24. What early customer risks exist?
25. What sales message boundaries apply?
26. What anti-patterns are prohibited?

If these questions cannot be answered, pilot-to-paid SaaS conversion planning is incomplete.

---

## 32. Conclusion

A pilot should become paid SaaS only when operational value is proven and scope is controlled.

The correct flow is:

    Free Discovery
        -> Free Controlled Pilot
        -> Paid Pilot
        -> Early SaaS Subscription
        -> Standard SaaS Customer
        -> Franchise SaaS Customer

Each conversion step must record:

- evidence
- retrospective
- blockers
- package scope
- price type
- support commitment
- data commitment
- provider fee separation
- hardware fee separation
- cancellation path
- next review date

This document prevents free pilots from becoming uncontrolled obligations and prepares early SaaS revenue without damaging trust, support discipline, or future Franchise OS expansion.