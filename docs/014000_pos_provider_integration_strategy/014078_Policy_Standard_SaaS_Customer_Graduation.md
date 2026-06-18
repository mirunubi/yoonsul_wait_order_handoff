# 014078_Policy_Standard_SaaS_Customer_Graduation

## 1. Purpose

This document defines the standard SaaS customer graduation, renewal readiness, expansion eligibility, stable operations, support cadence reduction, package fit review, upgrade signal, downgrade prevention, long-term retention, and operational maturity policy for the Yoonsul Wait/Order Handoff documentation project.

The previous document defined early paid SaaS customer monitoring, churn risk, and retention intervention policy.

This document defines when an early paid SaaS customer may graduate into a standard SaaS customer and how renewal, expansion, and stable operations should be governed.

This document does not implement billing automation, renewal contracts, CRM workflows, customer success software, or production SLA monitoring.

It defines standard customer graduation and stable operations policy only.

---

## 2. Scope

This document covers:

- early customer graduation
- standard customer criteria
- renewal readiness
- package fit review
- support cadence adjustment
- upgrade eligibility
- expansion eligibility
- downgrade prevention
- stable operations monitoring
- operational maturity signals
- next-store expansion readiness
- long-term customer success boundary
- no-implementation boundary

This document does not cover:

- final legal renewal terms
- final invoice automation
- final tax handling
- final CRM implementation
- final SLA contract
- final franchise agreement
- final production monitoring stack
- final customer success platform
- final sales automation

---

## 3. Core Principle

A customer should graduate only after stable operational evidence.

The project must follow this rule:

> Standard SaaS customer status should be granted only when the customer has demonstrated stable use, clear value recognition, manageable support burden, acceptable payment/KDS/provider reliability, and low churn risk over a defined monitoring period.

Graduation is not automatic after payment.

Graduation means the customer is no longer treated as a fragile early paid customer.

---

## 4. Standard Customer Definition

A standard SaaS customer means:

- the customer uses the product under a defined package
- operating scope is stable
- support burden is within expected range
- staff can use the system without constant intervention
- owner understands value and limitations
- payment/KDS/provider risks are controlled
- open blockers are not critical
- renewal risk is manageable
- monitoring cadence may be reduced

Standard customer does not mean no issues.

It means issues are manageable within normal operations.

---

## 5. Graduation Time Window

Recommended graduation time window:

| Period | Meaning |
| ------ | ------- |
| 30 days | early value confirmation possible |
| 60 days | operational pattern begins to stabilize |
| 90 days | standard customer graduation may be considered |
| 90+ days | renewal/expansion readiness may be evaluated |

A customer should not graduate only because 90 days passed.

Evidence matters more than time.

---

## 6. Graduation Readiness Status Values

Recommended values:

- `NOT_ELIGIBLE`
- `EARLY_MONITORING_CONTINUES`
- `GRADUATION_REVIEW_REQUIRED`
- `GRADUATION_BLOCKED`
- `GRADUATION_DEFERRED`
- `READY_FOR_STANDARD_CUSTOMER`
- `STANDARD_CUSTOMER_APPROVED`
- `STANDARD_CUSTOMER_ACTIVE`
- `STANDARD_CUSTOMER_WITH_RESTRICTION`
- `REMAIN_EARLY_CUSTOMER`
- `DOWNGRADE_REVIEW_REQUIRED`
- `CANCELLATION_RISK_REVIEW_REQUIRED`

Graduation status must be explicit.

---

## 7. Graduation Review Record Fields

Each graduation review should record:

- graduation review id
- store id
- customer id
- package
- conversion date
- review date
- monitoring period
- usage summary
- owner value confirmation
- staff adoption status
- support burden status
- payment trust status
- KDS reliability status
- provider stability status
- Mini Kiosk usage status
- open blockers
- waivers
- churn risk status
- renewal risk status
- expansion signal
- decision
- next review date
- notes

This record preserves customer lifecycle evidence.

---

## 8. Graduation Review ID Format

Recommended format:

    STANDARD-GRADUATION-[STORE-ID]-[YYYYMMDD]

Example:

    STANDARD-GRADUATION-STORE001-20260612

Final format may be normalized later.

---

## 9. Graduation Criteria

A customer may graduate when:

1. customer has operated under paid scope for sufficient period
2. no critical unresolved blocker remains
3. payment trust is acceptable
4. KDS reliability is acceptable for enabled scope
5. support burden is within package expectation
6. staff adoption is stable
7. owner confirms value
8. provider limitations are understood
9. package scope still fits
10. evidence is complete enough
11. churn risk is low or managed
12. renewal path is clear

Graduation must be evidence-based.

---

## 10. Graduation Blockers

Graduation should be blocked when:

- payment trust remains weak
- KDS duplicate or missing ticket risk remains
- support burden is excessive
- staff still avoids system
- owner cannot explain value
- provider instability affects core use
- open critical blocker remains
- evidence is incomplete
- pricing objection remains unresolved
- customer expects unsupported scope
- downgrade or cancellation risk is high
- package scope is misaligned

A blocked graduation should trigger retention or scope review.

---

## 11. Standard Operations Monitoring

After graduation, monitoring continues but cadence may reduce.

Standard monitoring should track:

- usage
- payment uncertainty
- KDS issue count
- support case count
- fallback usage
- provider incidents
- staff adoption changes
- customer complaints
- owner satisfaction
- renewal risk
- upgrade signal
- downgrade signal
- new feature requests

Standard customer monitoring protects retention.

---

## 12. Standard Customer Status Values

Recommended values:

- `STANDARD_ACTIVE`
- `STANDARD_STABLE`
- `STANDARD_MONITORING_REQUIRED`
- `STANDARD_SUPPORT_REVIEW_REQUIRED`
- `STANDARD_PAYMENT_REVIEW_REQUIRED`
- `STANDARD_KDS_REVIEW_REQUIRED`
- `STANDARD_PROVIDER_REVIEW_REQUIRED`
- `STANDARD_UPGRADE_CANDIDATE`
- `STANDARD_EXPANSION_CANDIDATE`
- `STANDARD_DOWNGRADE_RISK`
- `STANDARD_RENEWAL_RISK`
- `STANDARD_CHURN_RISK`
- `STANDARD_EXITED`

Standard status must reflect actual operation.

---

## 13. Support Cadence Adjustment

Support cadence may reduce when:

- support case volume is low
- support cases are routine
- staff can self-handle common cases
- owner understands dashboard/evidence
- no critical support blocker remains
- support masking remains stable
- support tier matches actual burden

Support cadence should not reduce if:

- payment uncertainty remains frequent
- KDS confusion persists
- staff depends heavily on support
- provider incidents recur
- customer complaints require intervention

Support cadence follows evidence.

---

## 14. Support Tier Review

Support tier review should check:

- actual support case count
- support case severity
- response time expectation
- support session usage
- break-glass usage
- support burden cost
- package price alignment
- owner expectation
- staff reliance
- future expansion need

Support tier may be adjusted up or down.

---

## 15. Renewal Readiness

Renewal readiness means:

- customer value is understood
- package scope still fits
- pricing is accepted
- support burden is manageable
- no critical unresolved blocker exists
- owner knows renewal terms
- downgrade/cancel path is clear
- upgrade/expansion options are appropriate
- provider limitations are disclosed
- renewal decision is not rushed

Renewal should not rely only on automatic billing.

---

## 16. Renewal Readiness Status Values

Recommended values:

- `RENEWAL_NOT_DUE`
- `RENEWAL_REVIEW_REQUIRED`
- `RENEWAL_READY`
- `RENEWAL_READY_WITH_LIMITATIONS`
- `RENEWAL_BLOCKED`
- `RENEWAL_RISK_DETECTED`
- `RENEWAL_DISCOUNT_REVIEW_REQUIRED`
- `RENEWAL_DOWNGRADE_REVIEW_REQUIRED`
- `RENEWAL_CANCEL_REQUESTED`
- `RENEWAL_COMPLETED`
- `RENEWAL_DECLINED`

Renewal status should be tracked before billing date.

---

## 17. Renewal Review Record Fields

Renewal review should record:

- renewal review id
- customer/store
- current package
- current price
- renewal period
- usage summary
- value summary
- support summary
- incidents since last review
- open blockers
- churn risk
- upgrade signal
- downgrade risk
- discount request
- provider limitation
- decision
- customer response
- next action
- notes

Renewal review should connect operational value to commercial decision.

---

## 18. Renewal Review ID Format

Recommended format:

    RENEWAL-REVIEW-[STORE-ID]-[YYYYMMDD]

Example:

    RENEWAL-REVIEW-STORE001-20260612

Final format may be normalized later.

---

## 19. Upgrade Signal

Upgrade signal may exist when:

- owner wants more visibility
- staff adoption is strong
- support burden is low
- Mini Kiosk usage is high
- KDS handoff stable
- payment recovery stable
- customer usage increases
- store volume increases
- owner asks for analytics
- owner asks for additional modules
- store considers second location
- franchise linkage discussion begins

Upgrade signal should be evidence-based.

---

## 20. Upgrade Eligibility

Upgrade may be offered when:

- current package is stable
- customer understands current value
- new module is implementation-ready
- support tier can handle expansion
- pricing is transparent
- provider dependency is understood
- training need is planned
- rollback path exists
- upgrade does not create unsafe scope creep

Upgrade should not be used to distract from unresolved issues.

---

## 21. Upgrade Types

Recommended upgrade types:

- `MINI_KIOSK_MODULE_UPGRADE`
- `KDS_HANDOFF_MODULE_UPGRADE`
- `PROVIDER_GATEWAY_UPGRADE`
- `SUPPORT_TIER_UPGRADE`
- `OWNER_DASHBOARD_UPGRADE`
- `PILOT_EVIDENCE_REPORTING_UPGRADE`
- `MULTI_STORE_PREP_UPGRADE`
- `FRANCHISE_OS_SIGNAL_UPGRADE`
- `ANALYTICS_ADD_ON_UPGRADE`

Upgrade type should match actual readiness.

---

## 22. Expansion Signal

Expansion signal may exist when:

- customer wants another store
- owner asks about franchise model
- multiple stores have similar need
- current store operations stable
- training materials are reusable
- provider path is repeatable
- support load is predictable
- KDS/payment flow is stable
- package economics are acceptable
- customer acts as reference

Expansion is stronger than upgrade.

Expansion affects rollout and support capacity.

---

## 23. Expansion Eligibility

Expansion may be considered when:

1. current store is stable
2. evidence supports repeatability
3. staff training is documented
4. support burden is known
5. provider path is reproducible
6. payment/KDS risks are controlled
7. onboarding process exists
8. scope is not custom-only
9. commercial model is clear
10. operational owner approves expansion

Expansion should not be used to avoid fixing current store issues.

---

## 24. Next Store Expansion Types

Recommended values:

- `SAME_OWNER_SECOND_STORE`
- `FRIENDLY_STORE_REFERRAL`
- `SAME_PROVIDER_STACK_STORE`
- `DIFFERENT_PROVIDER_STACK_STORE`
- `FRANCHISE_CANDIDATE_STORE`
- `INTERNAL_TEST_STORE`
- `DEFERRED_EXPANSION`

Different expansion types carry different risk.

---

## 25. Downgrade Risk Review

Downgrade risk should be reviewed when:

- owner uses only part of package
- support burden is low but price feels high
- provider limitation disables module
- KDS or Mini Kiosk adoption is partial
- owner asks for cheaper plan
- store volume is low
- staff resists higher module
- value is concentrated in one module

Downgrade can preserve customer if handled honestly.

---

## 26. Downgrade Eligibility

Downgrade may be offered when:

- reduced package remains safe
- disabled modules can be safely turned off
- support scope is updated
- billing is transparent
- customer understands limitations
- data retention/export is handled
- rollback/deactivation path exists
- renewal risk is reduced

Downgrade must not leave unsafe half-enabled runtime.

---

## 27. Stable Operations Indicators

Stable operations indicators include:

- predictable usage
- low critical incident count
- low payment uncertainty rate
- KDS handoff reliable
- support cases routine
- staff uses system naturally
- owner checks value periodically
- fallback rare and controlled
- provider incidents manageable
- evidence available when needed
- customer complaints low
- renewal conversation calm

Stable does not mean perfect.

It means controlled.

---

## 28. Unstable Operations Indicators

Unstable operations indicators include:

- repeated payment uncertainty
- repeated KDS confusion
- recurring support escalation
- staff bypasses system
- owner questions value repeatedly
- provider failures disrupt operations
- fallback frequent
- customer complaints repeat
- evidence incomplete
- unresolved blockers stay open
- support burden exceeds tier
- renewal conversation becomes defensive

Unstable operations require intervention.

---

## 29. Standard Customer Review Cadence

Recommended cadence:

| Review | Cadence |
| ------ | ------- |
| Stable operations review | monthly |
| Support burden review | monthly or quarterly |
| Payment/KDS safety review | monthly during early standard phase |
| Owner value review | monthly or quarterly |
| Renewal risk review | before renewal |
| Upgrade review | after stability signal |
| Expansion review | after repeatability evidence |
| Downgrade/churn review | as triggered |

Cadence may adjust by customer maturity.

---

## 30. Long-Term Retention Signals

Long-term retention signals include:

- owner refers others
- staff asks for improvements rather than avoids system
- support cases become predictable
- customer complaints decrease
- store expands usage
- customer accepts renewal without heavy discount
- operational evidence is used in decisions
- provider issues are manageable
- KDS/payment trust remains stable
- package fit remains clear

Retention is earned continuously.

---

## 31. Renewal Discount Rule

Renewal discount may be considered when:

- customer value is real
- price objection is specific
- retention risk exists
- discount has limited duration
- standard price remains clear
- scope is not misrepresented
- support burden remains sustainable
- discount is recorded

Do not use discount to hide product weakness.

---

## 32. Stable Customer Feedback Loop

Stable customer learning should update:

- product roadmap
- package design
- pricing tiers
- support tier structure
- onboarding SOP
- staff training materials
- provider priority
- KDS reliability improvements
- Mini Kiosk UI
- owner dashboard
- evidence reports
- expansion playbook

Stable customers are product strategy sources.

---

## 33. Standard Customer Incident Handling

Standard customer incidents should still follow incident policy.

But review may differ:

- critical incidents trigger immediate review
- recurring incidents trigger renewal risk review
- minor incidents may enter normal support queue
- provider incidents may feed provider review
- payment/KDS incidents remain high priority
- support masking/security incidents remain critical

Standard customer status does not reduce safety requirements.

---

## 34. Standard Customer Exit Review

If standard customer exits, record:

- exit reason
- package
- length of subscription
- unresolved issues
- support burden
- payment/KDS/provider issues
- pricing issue
- staff adoption issue
- competitor issue
- operation change
- retention attempts
- lessons learned
- reactivation possibility

Exit review remains product learning.

---

## 35. Graduation Register Recommendation

Recommended future files:

    docs/_index/
      Standard_Customer_Graduation_Register.md
      Standard_Customer_Monitoring_Register.md
      Renewal_Readiness_Register.md
      Upgrade_Eligibility_Register.md
      Expansion_Eligibility_Register.md
      Downgrade_Review_Register.md
      Standard_Customer_Exit_Review_Register.md

This document only recommends these files.

It does not create them.

---

## 36. Anti-Patterns

The following are prohibited:

- graduating customer because time passed only
- reducing support cadence while issues remain high
- offering upgrade before current scope is stable
- expanding to next store before repeatability proof
- hiding provider limitation during renewal
- treating downgrade as failure
- using discount instead of fixing value gap
- ignoring staff adoption after graduation
- ignoring payment/KDS safety after graduation
- treating standard customer as no longer needing review
- renewing without value discussion
- expanding to franchise signal before store stability

---

## 37. Non-Goals

This document does not define:

- final renewal contract
- final invoice automation
- final CRM workflow
- final customer success software
- final SLA terms
- final franchise expansion contract
- final production monitoring dashboard
- final sales compensation model

Those belong to later commercial operations.

---

## 38. Readiness Check

This document is ready when the project can answer:

1. What is standard SaaS customer?
2. What graduation time window applies?
3. What graduation readiness statuses exist?
4. What fields should graduation review record include?
5. What graduation criteria apply?
6. What blocks graduation?
7. What is standard operations monitoring?
8. What standard customer statuses exist?
9. When may support cadence reduce?
10. How is support tier reviewed?
11. What is renewal readiness?
12. What renewal statuses exist?
13. What fields should renewal review include?
14. What is upgrade signal?
15. When is upgrade eligible?
16. What upgrade types exist?
17. What is expansion signal?
18. When is expansion eligible?
19. What next-store expansion types exist?
20. How is downgrade risk reviewed?
21. When is downgrade eligible?
22. What are stable operations indicators?
23. What are unstable operations indicators?
24. What review cadence applies?
25. What long-term retention signals exist?
26. What renewal discount rule applies?
27. What stable feedback loop applies?
28. How are standard customer incidents handled?
29. How is standard customer exit reviewed?
30. What anti-patterns are prohibited?

If these questions cannot be answered, standard SaaS customer graduation, renewal, expansion, and stable operations planning is incomplete.

---

## 39. Conclusion

A customer becomes standard only after evidence shows stable operation, value recognition, manageable support burden, and controlled payment/KDS/provider risk.

The safe customer lifecycle is:

    paid conversion
        -> early monitoring
        -> churn risk control
        -> value confirmation
        -> graduation review
        -> standard customer operation
        -> renewal readiness
        -> upgrade or downgrade review
        -> expansion eligibility
        -> long-term retention

This document prevents the project from treating payment as proof of maturity and ensures that renewal, expansion, and franchise signals are grounded in stable operations.