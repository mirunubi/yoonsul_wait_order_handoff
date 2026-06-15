# 14088_Policy_Multi_Store_Renewal_Revenue_Risk_Pipeline

## 1. Purpose

This document defines the multi-store renewal forecast, revenue risk, churn risk, downgrade risk, expansion pipeline, upsell opportunity, next-store candidate, renewal readiness, and commercial governance policy for the Yoonsul Wait/Order Handoff documentation project.

The previous document defined multi-store contract scope change, module amendment, and commercial governance policy.

This document defines how renewal and expansion pipeline should be forecasted after multiple stores and commercial amendments exist.

This document does not implement CRM, sales forecasting, accounting forecast, invoice automation, renewal contract workflow, or revenue recognition.

It defines renewal forecast and expansion pipeline governance policy only.

---

## 2. Scope

This document covers:

- renewal forecast
- revenue risk forecast
- churn risk forecast
- downgrade risk forecast
- upgrade opportunity
- expansion pipeline
- next-store candidate tracking
- commercial amendment impact
- support burden impact
- provider dependency impact
- renewal readiness
- expansion governance
- no-implementation boundary

This document does not cover:

- final CRM implementation
- final sales pipeline automation
- final accounting revenue recognition
- final invoice collection forecast
- final tax reporting
- final legal renewal terms
- final franchise sales process
- final investor reporting
- final production business intelligence

---

## 3. Core Principle

Revenue forecast must be tied to operational evidence.

The project must follow this rule:

> Renewal, expansion, upsell, downgrade, and churn forecasts must be based on store health, value evidence, support burden, provider reliability, payment/KDS safety, commercial scope, and customer acknowledgement rather than sales optimism alone.

Commercial forecast without operational evidence is fragile.

Operational risk without revenue visibility causes surprise churn.

---

## 4. Renewal Forecast Meaning

Renewal forecast means estimating whether an active SaaS customer is likely to:

- renew current package
- renew with upgrade
- renew with downgrade
- request discount
- request scope change
- pause subscription
- cancel subscription
- expand to another store
- require intervention before renewal

Renewal forecast should be reviewed before renewal date, not after invoice dispute.

---

## 5. Revenue Risk Meaning

Revenue risk means any condition that may reduce expected revenue.

Revenue risk may include:

- churn risk
- downgrade risk
- discount extension risk
- billing dispute
- support overload cost
- provider incident impact
- module deactivation
- store removal
- unpaid invoice
- renewal objection
- scope mismatch
- customer value uncertainty

Revenue risk is broader than cancellation.

---

## 6. Forecast Time Horizons

Recommended forecast horizons:

| Horizon | Purpose |
| ------- | ------- |
| 7 days | urgent renewal or churn intervention |
| 30 days | near-term renewal, invoice, support risk |
| 60 days | downgrade/expansion preparation |
| 90 days | standard renewal and expansion planning |
| 180 days | franchise or multi-store pipeline review |
| 12 months | strategic revenue and capacity planning |

Forecast accuracy should improve as evidence accumulates.

---

## 7. Renewal Forecast Status Values

Recommended values:

- `RENEWAL_NOT_DUE`
- `RENEWAL_HEALTHY`
- `RENEWAL_WATCH`
- `RENEWAL_RISK`
- `RENEWAL_HIGH_RISK`
- `RENEWAL_DISCOUNT_REQUEST_EXPECTED`
- `RENEWAL_DOWNGRADE_EXPECTED`
- `RENEWAL_UPGRADE_CANDIDATE`
- `RENEWAL_EXPANSION_CANDIDATE`
- `RENEWAL_CANCEL_EXPECTED`
- `RENEWAL_COMPLETED`
- `RENEWAL_LOST`

Forecast status must be evidence-linked.

---

## 8. Revenue Risk Status Values

Recommended values:

- `REVENUE_RISK_NONE`
- `REVENUE_RISK_WATCH`
- `REVENUE_RISK_MEDIUM`
- `REVENUE_RISK_HIGH`
- `REVENUE_RISK_CRITICAL`
- `REVENUE_RISK_REALIZED`
- `REVENUE_RISK_RESOLVED`

Revenue risk should be reviewed with both commercial and operational owners.

---

## 9. Expansion Pipeline Status Values

Recommended values:

- `EXPANSION_NOT_IDENTIFIED`
- `EXPANSION_SIGNAL_FOUND`
- `EXPANSION_QUALIFICATION_REQUIRED`
- `EXPANSION_READINESS_REVIEW_REQUIRED`
- `EXPANSION_PROVIDER_REVIEW_REQUIRED`
- `EXPANSION_SUPPORT_CAPACITY_REVIEW_REQUIRED`
- `EXPANSION_PROPOSAL_READY`
- `EXPANSION_PILOT_READY`
- `EXPANSION_APPROVED`
- `EXPANSION_BLOCKED`
- `EXPANSION_DEFERRED`
- `EXPANSION_REJECTED`
- `EXPANSION_COMPLETED`

Expansion pipeline should not skip readiness review.

---

## 10. Renewal Forecast Record Fields

Each renewal forecast record should include:

- forecast id
- customer/tenant
- store or store group
- current package
- current monthly or periodic fee
- renewal date
- forecast horizon
- renewal status
- revenue risk status
- churn risk category
- downgrade risk
- upgrade signal
- expansion signal
- open blockers
- provider incidents
- support burden
- payment/KDS safety status
- owner value status
- staff adoption status
- billing dispute status
- forecast decision
- next action
- reviewer
- notes

Forecast record must connect operational and commercial signals.

---

## 11. Forecast ID Format

Recommended format:

    RENEWAL-FORECAST-[CUSTOMER]-[YYYYMMDD]

Example:

    RENEWAL-FORECAST-CUST001-20260612

Store-specific alternative:

    RENEWAL-FORECAST-[STORE-ID]-[YYYYMMDD]

Final format may be normalized later.

---

## 12. Revenue Risk Record Fields

Revenue risk record should include:

- risk id
- customer/tenant
- store
- risk category
- risk status
- affected revenue line
- estimated impact
- root cause
- operational evidence
- commercial evidence
- support evidence
- provider evidence
- intervention owner
- target resolution date
- decision
- notes

Revenue risk must be traceable to cause.

---

## 13. Revenue Risk ID Format

Recommended format:

    REVENUE-RISK-[CUSTOMER]-[YYYYMMDD]-[NUMBER]

Example:

    REVENUE-RISK-CUST001-20260612-001

Final format may be normalized later.

---

## 14. Revenue Risk Categories

Recommended revenue risk categories:

- `CHURN_RISK`
- `DOWNGRADE_RISK`
- `DISCOUNT_EXTENSION_RISK`
- `BILLING_DISPUTE_RISK`
- `SUPPORT_COST_RISK`
- `PROVIDER_COST_RISK`
- `PROVIDER_INCIDENT_RISK`
- `PAYMENT_TRUST_RISK`
- `KDS_TRUST_RISK`
- `STAFF_NON_ADOPTION_RISK`
- `OWNER_VALUE_UNCLEAR_RISK`
- `MODULE_DEACTIVATION_RISK`
- `STORE_REMOVAL_RISK`
- `UNPAID_INVOICE_RISK`
- `SCOPE_MISMATCH_RISK`
- `COMPETITOR_SWITCH_RISK`
- `EXPANSION_DELAY_RISK`
- `UNKNOWN_REVENUE_RISK`

Risk category guides intervention.

---

## 15. Renewal Health Inputs

Renewal health should be based on:

- usage stability
- owner value confirmation
- staff adoption
- support burden
- payment trust
- KDS reliability
- provider stability
- customer complaint trend
- evidence completeness
- open blocker count
- billing dispute status
- price objection
- expansion interest
- downgrade request
- churn signal

Renewal health should not rely only on payment status.

---

## 16. Churn Forecast Rule

Churn forecast should be raised when:

- cancellation request appears
- owner questions value repeatedly
- staff avoids system
- payment trust issue repeats
- KDS issue repeats
- provider instability harms operation
- support burden exceeds expectation
- billing dispute remains unresolved
- price objection has no value support
- customer reverts to old process
- competitor comparison appears
- scope mismatch remains unresolved

Churn forecast must trigger intervention.

---

## 17. Downgrade Forecast Rule

Downgrade forecast should be raised when:

- customer uses only part of package
- price concern exists but value remains
- module adoption is partial
- KDS or Mini Kiosk remains unused
- provider limitation disables module
- support tier feels excessive
- store volume is lower than expected
- customer asks for lower-cost option
- renewal would fail without scope reduction

Downgrade may preserve relationship.

---

## 18. Upgrade Forecast Rule

Upgrade forecast should be raised when:

- usage is stable
- owner asks for more visibility
- staff adoption is strong
- support burden is manageable
- Mini Kiosk usage is healthy
- KDS flow is stable
- payment recovery is trusted
- owner asks for analytics
- next-store interest appears
- customer wants higher support tier
- manual work remains in adjacent module

Upgrade forecast must not ignore readiness.

---

## 19. Expansion Forecast Rule

Expansion forecast should be raised when:

- current store is stable
- owner has another store
- customer asks about multi-store use
- same provider stack can repeat
- staff training can be reused
- support capacity is available
- onboarding package exists
- payment/KDS/provider risks are controlled
- pricing model is clear
- expansion economics make sense

Expansion forecast must be gated by readiness.

---

## 20. Discount Request Forecast Rule

Discount request forecast should be raised when:

- early adopter discount is expiring
- owner says price feels high
- value evidence is weak
- support burden feels visible to customer
- provider incident reduced value
- competitor price comparison appears
- module adoption is partial
- store volume is low
- billing dispute occurred

Discount response should follow value and scope review.

---

## 21. Billing Dispute Forecast Rule

Billing dispute forecast should be raised when:

- scope changed recently
- module added or removed
- store added or removed
- provider fee changed
- support tier changed
- discount expired
- pilot credit ended
- hardware fee appeared
- invoice grouping changed
- limitation disclosure was unclear

Billing disputes are often caused before invoice is sent.

---

## 22. Support Cost Forecast Rule

Support cost forecast should be raised when:

- support cases are increasing
- high severity cases repeat
- provider coordination is frequent
- staff retraining repeats
- payment review burden is high
- KDS review burden is high
- after-hours expectation appears
- multi-store support overlaps
- support tier underprices reality

Support cost risk may affect pricing or expansion.

---

## 23. Provider Cost Forecast Rule

Provider cost forecast should be raised when:

- provider fee changes
- API usage cost increases
- local daemon/dealer support fee appears
- hardware maintenance cost changes
- payment fee structure changes
- KDS provider fee changes
- provider incident increases support cost
- new store uses different provider stack

Provider cost must be disclosed before renewal or expansion.

---

## 24. Forecast Decision Values

Recommended forecast decision values:

- `NO_ACTION`
- `MONITOR`
- `CREATE_RETENTION_INTERVENTION`
- `CREATE_RENEWAL_REVIEW`
- `CREATE_DOWNGRADE_OFFER`
- `CREATE_UPGRADE_REVIEW`
- `CREATE_EXPANSION_REVIEW`
- `CREATE_DISCOUNT_REVIEW`
- `CREATE_BILLING_CLARIFICATION`
- `CREATE_SUPPORT_COST_REVIEW`
- `CREATE_PROVIDER_COST_REVIEW`
- `CREATE_SCOPE_AMENDMENT`
- `PAUSE_EXPANSION`
- `BLOCK_RENEWAL_UNTIL_REVIEW`
- `EXIT_PLANNED`

Forecast should produce action when risk exists.

---

## 25. Renewal Intervention Types

Recommended renewal intervention types:

- owner value review
- staff adoption review
- support burden review
- payment trust review
- KDS reliability review
- provider limitation disclosure
- billing clarification
- package fit review
- downgrade offer
- upgrade proposal
- discount review
- support tier adjustment
- scope amendment
- renewal meeting
- cancellation save review

Intervention must match risk category.

---

## 26. Expansion Pipeline Record Fields

Expansion pipeline record should include:

- pipeline id
- source customer/store
- target store candidate
- expansion type
- provider stack assumption
- support capacity status
- onboarding package status
- payment/KDS readiness
- staff training requirement
- commercial opportunity
- revenue estimate placeholder
- risk level
- readiness status
- next action
- owner
- notes

Expansion pipeline must not become sales-only list.

---

## 27. Expansion Pipeline ID Format

Recommended format:

    EXPANSION-PIPELINE-[CUSTOMER]-[YYYYMMDD]-[NUMBER]

Example:

    EXPANSION-PIPELINE-CUST001-20260612-001

Final format may be normalized later.

---

## 28. Expansion Qualification Criteria

Expansion candidate qualifies only when:

- current store value is proven
- target store need is clear
- provider stack is known or reviewable
- support capacity exists
- onboarding package is reusable
- pricing model is explainable
- operational owner is identified
- store manager readiness can be assessed
- scope restriction is possible
- rollback path can be defined

Qualification comes before proposal.

---

## 29. Expansion Disqualification Conditions

Expansion candidate should be disqualified or deferred when:

- current store unstable
- critical blocker open
- support capacity overloaded
- provider stack unknown
- target store expects unsupported scope
- pricing expectation unrealistic
- payment/KDS risk unresolved
- staff training cannot be provided
- onboarding package incomplete
- commercial owner wants speed over safety

Disqualification protects long-term scalability.

---

## 30. Renewal Forecast Review Cadence

Recommended cadence:

| Review | Cadence |
| ------ | ------- |
| Critical churn risk | immediate |
| High revenue risk | weekly |
| Renewal due within 30 days | weekly |
| Renewal due within 60 days | biweekly |
| Renewal due within 90 days | monthly |
| Expansion pipeline | weekly during growth phase |
| Billing dispute forecast | before invoice |
| Support cost forecast | monthly |
| Provider cost forecast | before renewal or expansion |

Cadence should match risk and renewal date.

---

## 31. Forecast Confidence Values

Recommended confidence values:

- `CONFIDENCE_LOW`
- `CONFIDENCE_MEDIUM`
- `CONFIDENCE_HIGH`
- `CONFIDENCE_EVIDENCE_BACKED`
- `CONFIDENCE_UNKNOWN`

Forecast confidence should be visible.

Low-confidence forecast should trigger evidence collection.

---

## 32. Forecast Evidence Requirement

Forecast evidence may include:

- daily/weekly review records
- store health dashboard
- support case history
- incident history
- payment/KDS safety records
- provider incident records
- billing records
- customer feedback
- owner value review
- staff adoption review
- renewal conversation notes
- usage metrics
- blocker and waiver records

Forecast without evidence should be marked low confidence.

---

## 33. Forecast Owner Roles

Recommended owner roles:

- customer success owner
- support lead
- store operations owner
- provider integration owner
- payment runtime owner
- KDS runtime owner
- billing owner
- expansion owner
- business owner

Forecast ownership may be shared, but decision owner must be clear.

---

## 34. Renewal Forecast Dashboard Recommendation

A future renewal forecast dashboard may show:

- customers due for renewal
- renewal health status
- revenue risk status
- churn risk category
- downgrade risk
- upgrade candidates
- expansion candidates
- support cost risk
- provider cost risk
- billing dispute risk
- next action
- owner

This document only recommends dashboard concepts.

---

## 35. Expansion Pipeline Dashboard Recommendation

A future expansion pipeline dashboard may show:

- target stores
- expansion type
- readiness status
- risk level
- provider stack
- support capacity
- onboarding readiness
- expected package
- blocked reason
- next action
- owner

Pipeline dashboard must include readiness, not just opportunity.

---

## 36. Forecast To Commercial Action Rule

Forecast may lead to:

- renewal proposal
- downgrade proposal
- upgrade proposal
- expansion proposal
- discount review
- scope amendment
- support tier change
- provider cost disclosure
- billing clarification
- cancellation save attempt
- planned exit

Action must be recorded.

---

## 37. Forecast To Product Action Rule

Forecast may lead to:

- backlog item
- support SOP update
- training update
- UI copy change
- provider adapter improvement
- KDS reliability improvement
- payment recovery improvement
- evidence packet improvement
- dashboard metric improvement
- onboarding playbook improvement

Revenue risk often reveals product risk.

---

## 38. Forecast Closure Rule

Forecast item may close when:

- renewal completed
- churn realized
- churn prevented
- downgrade accepted
- upgrade accepted
- expansion approved
- expansion rejected
- billing dispute resolved
- support risk resolved
- provider cost disclosed and accepted
- planned exit completed

Closure must state outcome.

---

## 39. Registers Recommendation

Recommended future files:

    docs/_index/
      Renewal_Forecast_Register.md
      Revenue_Risk_Register.md
      Expansion_Pipeline_Register.md
      Forecast_Intervention_Register.md
      Forecast_Evidence_Register.md
      Renewal_Action_Register.md
      Expansion_Qualification_Register.md
      Forecast_Closure_Register.md

This document only recommends these files.

It does not create them.

---

## 40. Anti-Patterns

The following are prohibited:

- forecasting renewal from payment status only
- forecasting expansion from owner interest only
- ignoring support cost in revenue forecast
- ignoring provider cost in renewal proposal
- hiding downgrade risk
- treating discount request as sales problem only
- waiting for invoice dispute before billing clarification
- ignoring staff adoption in churn forecast
- ignoring payment/KDS trust in renewal forecast
- expanding pipeline without readiness status
- overstating forecast confidence without evidence
- treating churn as surprise when signals existed
- treating expansion as success even if support capacity is overloaded

---

## 41. Non-Goals

This document does not define:

- final CRM pipeline
- final revenue recognition
- final investor forecast
- final accounting forecast
- final invoice collection system
- final legal renewal workflow
- final franchise sales system
- final production BI dashboard

Those belong to later finance, sales, and commercial operations.

---

## 42. Readiness Check

This document is ready when the project can answer:

1. What is renewal forecast?
2. What is revenue risk?
3. What forecast time horizons exist?
4. What renewal forecast statuses exist?
5. What revenue risk statuses exist?
6. What expansion pipeline statuses exist?
7. What fields should renewal forecast include?
8. What fields should revenue risk include?
9. What revenue risk categories exist?
10. What inputs define renewal health?
11. When is churn forecast raised?
12. When is downgrade forecast raised?
13. When is upgrade forecast raised?
14. When is expansion forecast raised?
15. When is discount request forecast raised?
16. When is billing dispute forecast raised?
17. When is support cost forecast raised?
18. When is provider cost forecast raised?
19. What forecast decisions exist?
20. What intervention types exist?
21. What fields should expansion pipeline record include?
22. What qualifies expansion candidate?
23. What disqualifies expansion candidate?
24. What review cadence applies?
25. What confidence values exist?
26. What evidence is required?
27. What owner roles exist?
28. How does forecast become commercial action?
29. How does forecast become product action?
30. When may forecast close?
31. What anti-patterns are prohibited?

If these questions cannot be answered, renewal forecast, revenue risk, and expansion pipeline governance planning is incomplete.

---

## 43. Conclusion

Renewal and expansion forecasting must connect commercial opportunity with operational evidence.

The safe forecast flow is:

    store health evidence
        -> renewal forecast
        -> revenue risk classification
        -> churn/downgrade/upgrade/expansion signal
        -> forecast confidence
        -> intervention or commercial action
        -> product action if needed
        -> closure with outcome

This document ensures that revenue growth does not become detached from store reality, support burden, provider cost, payment/KDS safety, billing clarity, or customer value.