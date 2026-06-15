# 14076_Policy_Early_Paid_SaaS_Churn_Intervention

## 1. Purpose

This document defines the early paid SaaS customer monitoring, churn risk detection, retention intervention, support burden review, value confirmation, downgrade prevention, cancellation risk review, and post-conversion customer success policy for the Yoonsul Wait/Order Handoff documentation project.

The previous document defined pilot-to-paid SaaS conversion, operational proof, and commercial readiness policy.

This document defines what must happen after a pilot customer converts into a paid SaaS customer.

This document does not implement customer success software, billing automation, CRM, analytics dashboard, or cancellation workflow.

It defines early paid SaaS monitoring and retention policy only.

---

## 2. Scope

This document covers:

- early paid customer monitoring
- churn risk detection
- retention intervention
- owner value review
- staff adoption review
- support burden review
- provider dependency review
- payment/KDS reliability review
- Mini Kiosk usage review
- downgrade risk
- cancellation risk
- pricing objection handling
- post-conversion evidence review
- no-implementation boundary

This document does not cover:

- final CRM implementation
- final billing engine
- final invoice process
- final legal cancellation terms
- final automated retention scoring
- final customer success dashboard
- final marketing automation
- final franchise rollout
- final production SLA

---

## 3. Core Principle

Paid conversion is not completion.

The project must follow this rule:

> The first paid SaaS period must be monitored as an operational retention period, not treated as a finished sale.

Early customers leave when:

- value is unclear
- support burden is higher than expected
- staff do not adopt the system
- payment/KDS trust is weak
- provider limitations are misunderstood
- price feels disconnected from value
- promised scope and delivered scope differ

Retention begins immediately after conversion.

---

## 4. Early Paid Customer Definition

An early paid SaaS customer means:

- the store has accepted paid use after pilot
- package scope is limited or early-stage
- support expectations may still be high
- product maturity is not full production maturity
- provider dependency may still be constrained
- staff adoption is still being formed
- churn risk is higher than mature customers

Early paid customer is not the same as stable long-term customer.

---

## 5. Early Monitoring Period

Recommended early monitoring periods:

| Period | Purpose |
| ------ | ------- |
| First 7 days | detect urgent adoption and trust issues |
| First 30 days | confirm value, support burden, staff usage |
| First 60 days | detect retention or downgrade signal |
| First 90 days | decide stable subscription, upgrade, downgrade, or churn risk |

The first 30 days are especially important.

---

## 6. Early Customer Status Values

Recommended status values:

- `PAID_CONVERSION_STARTED`
- `EARLY_MONITORING_ACTIVE`
- `VALUE_CONFIRMATION_REQUIRED`
- `SUPPORT_BURDEN_REVIEW_REQUIRED`
- `STAFF_ADOPTION_REVIEW_REQUIRED`
- `PAYMENT_TRUST_REVIEW_REQUIRED`
- `KDS_RELIABILITY_REVIEW_REQUIRED`
- `PROVIDER_REVIEW_REQUIRED`
- `CHURN_RISK_DETECTED`
- `RETENTION_INTERVENTION_ACTIVE`
- `STABLE_EARLY_CUSTOMER`
- `DOWNGRADE_REQUESTED`
- `CANCELLATION_REQUESTED`
- `CHURNED`
- `GRADUATED_TO_STANDARD_CUSTOMER`

Status should be visible.

---

## 7. Early Customer Monitoring Record Fields

Each early paid customer should have monitoring record.

Recommended fields:

- customer id
- store id
- conversion date
- package
- price
- discount
- support tier
- provider path
- enabled modules
- excluded modules
- open limitations
- open blockers
- first week status
- first month status
- usage summary
- support summary
- payment issue summary
- KDS issue summary
- staff adoption summary
- owner value summary
- churn risk score or category
- intervention status
- next review date
- notes

This record supports retention and product learning.

---

## 8. Monitoring Record ID Format

Recommended format:

    EARLY-SAAS-MONITOR-[STORE-ID]-[YYYYMMDD]

Example:

    EARLY-SAAS-MONITOR-STORE001-20260612

Final format may be normalized later.

---

## 9. Churn Risk Categories

Recommended churn risk categories:

- `VALUE_UNCLEAR`
- `PRICE_TOO_HIGH`
- `STAFF_NON_ADOPTION`
- `OWNER_LOW_USAGE`
- `SUPPORT_BURDEN_HIGH`
- `PAYMENT_TRUST_ISSUE`
- `KDS_TRUST_ISSUE`
- `PROVIDER_INSTABILITY`
- `MINI_KIOSK_LOW_USAGE`
- `FEATURE_MISUNDERSTANDING`
- `SCOPE_MISMATCH`
- `TRAINING_GAP`
- `HARDWARE_FRICTION`
- `CUSTOMER_COMPLAINT`
- `BILLING_CONFUSION`
- `STORE_OPERATION_CHANGE`
- `COMPETITOR_SWITCH_RISK`
- `UNKNOWN`

Churn risk must be categorized before intervention.

---

## 10. Churn Risk Severity Values

Recommended severity values:

- `CHURN_RISK_CRITICAL`
- `CHURN_RISK_HIGH`
- `CHURN_RISK_MEDIUM`
- `CHURN_RISK_LOW`
- `CHURN_OBSERVATION`

Severity should reflect likelihood of cancellation, downgrade, or non-renewal.

---

## 11. Critical Churn Signals

Critical churn signals include:

- owner requests cancellation
- owner says value is not visible
- payment incident damages trust
- KDS duplicate or missing ticket repeats
- staff refuses or avoids system
- support cases exceed agreed support level
- provider failure blocks core use
- customer complaints increase
- price objection appears before value confirmed
- store reverts fully to old process
- unresolved blocker affects paid module
- limitation was misunderstood at purchase

Critical churn signals require immediate intervention.

---

## 12. High Churn Signals

High churn signals include:

- staff uses system only when forced
- owner stops checking dashboard/evidence
- repeated support questions
- fallback used too often
- Mini Kiosk usage remains low
- payment uncertainty causes repeated anxiety
- KDS state labels still confuse kitchen
- provider unavailable state appears repeatedly
- owner asks for discount extension
- owner asks why they are paying
- scope expectation mismatch appears

High churn signals should be reviewed within the same week.

---

## 13. Medium And Low Churn Signals

Medium churn signals include:

- some staff confusion remains
- training refresh requested
- minor UI wording complaint
- support response could be faster
- owner wants more reports
- customer usage is lower than expected
- specific menu flow is confusing

Low signals include:

- cosmetic requests
- future feature ideas
- minor dashboard preference
- non-blocking inconvenience

Medium/low signals can become high if repeated.

---

## 14. Value Confirmation Review

Value confirmation should answer:

- what value did the customer expect?
- what value was actually delivered?
- what evidence supports delivered value?
- does owner see the value?
- do staff feel reduced friction?
- does kitchen trust the flow?
- does support evidence help resolution?
- did customer experience improve?
- is value tied to paid package?
- is value repeatable?

If value cannot be explained clearly, churn risk rises.

---

## 15. Owner Value Confirmation

Owner value confirmation should check:

- owner understands enabled modules
- owner sees operational visibility
- owner trusts payment/KDS state
- owner understands support tier
- owner understands provider limitations
- owner understands excluded features
- owner accepts price for current scope
- owner knows downgrade/cancel path
- owner has clear next review date

Owner confusion is retention risk.

---

## 16. Staff Adoption Review

Staff adoption review should check:

- staff use the system voluntarily
- staff understand state labels
- staff understand fallback
- staff understand support escalation
- staff trust KDS handoff
- staff do not bypass Mini Kiosk flow unnecessarily
- staff can explain payment uncertainty
- staff can capture evidence
- new staff can be trained quickly

Staff adoption determines operational survival.

---

## 17. Support Burden Review

Support burden review should check:

- support case volume
- support case type
- repeated support reason
- support response time
- support session safety
- masked view effectiveness
- break-glass frequency
- unresolved support backlog
- support cost versus package price
- need for higher support tier

Support burden must match pricing.

---

## 18. Payment Trust Review

Payment trust review should check:

- payment uncertainty frequency
- duplicate payment suspicion
- refund/cancel confusion
- provider callback reliability
- payment evidence completeness
- customer recovery quality
- staff confidence
- owner confidence
- support ability to review payment state

Payment trust issues can cause fast churn.

---

## 19. KDS Reliability Review

KDS reliability review should check:

- KDS handoff success rate
- duplicate ticket prevention
- missing ticket incidents
- held ticket understanding
- cancel impact review
- kitchen trust
- KDS evidence completeness
- degraded kitchen note usage
- staff confidence

KDS unreliability directly affects operations.

---

## 20. Provider Dependency Review

Provider dependency review should check:

- provider path actually used
- provider incidents
- provider timeout frequency
- provider support responsiveness
- provider limitations affecting paid scope
- OKPOS compatibility gap if applicable
- Toss path stability if applicable
- PAYCO channel issue if applicable
- provider disable path readiness

Provider problems should not be hidden as Yoonsul product mystery.

---

## 21. Mini Kiosk Usage Review

Mini Kiosk usage review should check:

- customer sessions started
- abandoned sessions
- timeout frequency
- staff intervention count
- customer confusion
- unsupported path attempts
- order intent success rate
- payment state display clarity
- support handoff use
- repeat customer usage

Low Mini Kiosk usage may indicate UX, training, location, or trust issue.

---

## 22. Pricing Objection Review

Pricing objection review should answer:

- is objection about price level?
- is objection about unclear value?
- is objection about support burden?
- is objection about provider/hardware fee confusion?
- is objection about discount expiration?
- is objection about comparing with POS/kiosk vendor?
- is objection about missing feature?
- is objection about limited scope?
- is objection about cashflow timing?

Do not respond to all pricing objections with discount.

First identify cause.

---

## 23. Discount Extension Rule

Discount extension may be considered only when:

- value exists but adoption needs more time
- unresolved issue is Yoonsul responsibility
- scope is limited
- extension has clear end date
- standard price remains visible
- support burden is manageable
- extension is recorded
- renewal review date is set

Discount extension must not become permanent hidden pricing.

---

## 24. Downgrade Review

Downgrade may be appropriate when:

- customer wants to keep some value
- full package exceeds current need
- staff adoption is partial
- provider limitation blocks module
- KDS module is not ready
- support tier is too high
- Mini Kiosk only scope is enough
- store is low volume
- churn can be prevented with honest scope reduction

Downgrade is better than churn if scope remains safe.

---

## 25. Cancellation Review

Cancellation review should capture:

- reason
- unresolved blocker
- value gap
- pricing issue
- support issue
- provider issue
- staff issue
- customer issue
- feature gap
- competitor issue
- store closure or operation change
- recovery attempt
- final decision
- reactivation possibility

Cancellation should feed product learning.

---

## 26. Retention Intervention Types

Recommended intervention types:

- owner value review call
- staff retraining
- support tier adjustment
- package downgrade
- temporary discount extension
- UI wording fix
- SOP update
- provider review
- payment trust review
- KDS reliability review
- Mini Kiosk placement or flow adjustment
- evidence review session
- scope clarification
- blocker fix
- cancellation save offer

Intervention must match churn cause.

---

## 27. Retention Intervention Record Fields

Each intervention should record:

- intervention id
- customer/store
- churn risk category
- severity
- trigger
- intervention type
- action taken
- responsible owner
- customer response
- result
- follow-up date
- status
- notes

This prevents vague retention efforts.

---

## 28. Intervention ID Format

Recommended format:

    RETENTION-[STORE-ID]-[YYYYMMDD]-[NUMBER]

Example:

    RETENTION-STORE001-20260612-001

Final format may be normalized later.

---

## 29. Intervention Status Values

Recommended values:

- `NOT_STARTED`
- `PLANNED`
- `IN_PROGRESS`
- `CUSTOMER_CONTACTED`
- `ACTION_TAKEN`
- `FOLLOW_UP_REQUIRED`
- `SUCCESSFUL`
- `UNSUCCESSFUL`
- `DOWNGRADE_ACCEPTED`
- `CANCELLATION_PREVENTED`
- `CANCELLED`
- `DEFERRED`

Intervention status should be visible.

---

## 30. Retention Success Criteria

Retention intervention may be successful when:

- owner confirms value
- staff adoption improves
- support cases reduce
- payment trust improves
- KDS reliability improves
- Mini Kiosk usage improves
- downgrade accepted instead of cancel
- customer accepts corrected scope
- pricing objection resolved without hiding fees
- next review date agreed

Success must be evidenced.

---

## 31. Retention Failure Criteria

Retention intervention fails when:

- customer cancels
- customer stops using system
- value remains unclear
- staff rejects system
- critical blocker remains
- support burden remains too high
- payment/KDS trust remains low
- provider issue blocks paid scope
- pricing remains unacceptable
- customer refuses scope correction

Failure should feed churn taxonomy.

---

## 32. Early Churn Record Fields

If churn occurs, record:

- churn id
- store
- package
- conversion date
- churn date
- days active
- primary reason
- secondary reasons
- support cases
- incidents
- blockers
- provider issues
- payment/KDS issues
- pricing issues
- staff adoption issues
- retention attempts
- final decision
- reactivation possibility
- lessons learned

Churn record must be honest.

---

## 33. Churn ID Format

Recommended format:

    CHURN-[STORE-ID]-[YYYYMMDD]

Example:

    CHURN-STORE001-20260612

Final format may be normalized later.

---

## 34. Reactivation Candidate Rule

A churned customer may become reactivation candidate when:

- blocker is resolved
- provider path improves
- pricing/package changes
- support tier improves
- staff changes
- store operation changes
- customer requested future contact
- limited scope product now fits

Reactivation should not repeat old promise without fix.

---

## 35. Retention Feedback Loop

Retention learning should update:

- package design
- pricing model
- onboarding SOP
- staff training
- customer scripts
- support tier policy
- provider priority
- KDS scope
- Mini Kiosk UI
- payment recovery
- evidence packets
- churn taxonomy
- sales message
- limitation disclosure

Retention is product design feedback.

---

## 36. Weekly Early Customer Review

During early monitoring, weekly review should check:

- usage
- value perception
- support burden
- open issues
- churn risk
- payment/KDS trust
- provider reliability
- staff adoption
- customer feedback
- pricing concerns
- intervention needed
- next action

Weekly review is required until customer stabilizes.

---

## 37. Graduation To Standard Customer

A customer may graduate to standard customer when:

- 60 to 90 days stable use
- no critical unresolved blocker
- staff adoption stable
- support burden normal
- owner value confirmed
- payment/KDS trust acceptable
- provider limitations understood
- package fit confirmed
- renewal risk low

Graduation means monitoring cadence can reduce.

---

## 38. Registers Recommendation

Recommended future files:

    docs/_index/
      Early_Paid_Customer_Monitoring_Register.md
      Churn_Risk_Register.md
      Retention_Intervention_Register.md
      Downgrade_Request_Register.md
      Cancellation_Review_Register.md
      Early_Churn_Register.md
      Reactivation_Candidate_Register.md
      Standard_Customer_Graduation_Register.md

This document only recommends these files.

It does not create them.

---

## 39. Anti-Patterns

The following are prohibited:

- treating paid conversion as final success
- ignoring first 30 days
- responding to every risk with discount
- hiding provider limitations
- hiding support burden
- ignoring staff non-adoption
- ignoring payment trust issues
- ignoring KDS trust issues
- blaming customer for unclear value
- allowing discount to become permanent by silence
- allowing downgrade without safe scope review
- cancelling without recording reason
- losing churn lessons
- promising reactivation without solving root cause

---

## 40. Non-Goals

This document does not define:

- final CRM
- final billing engine
- final invoice automation
- final contract renewal process
- final legal cancellation clause
- final customer success platform
- final NPS survey
- final automated churn model
- final production support SLA

Those belong to later commercial operations.

---

## 41. Readiness Check

This document is ready when the project can answer:

1. What is early paid customer?
2. What monitoring periods apply?
3. What customer statuses exist?
4. What fields should monitoring record include?
5. What churn risk categories exist?
6. What churn severity values exist?
7. What are critical churn signals?
8. What are high churn signals?
9. How is value confirmed?
10. How is owner value reviewed?
11. How is staff adoption reviewed?
12. How is support burden reviewed?
13. How is payment trust reviewed?
14. How is KDS reliability reviewed?
15. How is provider dependency reviewed?
16. How is Mini Kiosk usage reviewed?
17. How is pricing objection reviewed?
18. What discount extension rule applies?
19. When is downgrade appropriate?
20. How is cancellation reviewed?
21. What intervention types exist?
22. What fields must intervention record include?
23. What retention success criteria apply?
24. What retention failure criteria apply?
25. What churn record fields are required?
26. When is reactivation possible?
27. What retention feedback loop applies?
28. What weekly review applies?
29. When can customer graduate to standard customer?
30. What anti-patterns are prohibited?

If these questions cannot be answered, early paid SaaS monitoring and retention intervention planning is incomplete.

---

## 42. Conclusion

Early paid SaaS customers must be monitored closely after conversion.

The safe retention flow is:

    paid conversion
        -> first week monitoring
        -> first month value confirmation
        -> churn risk detection
        -> targeted retention intervention
        -> downgrade or scope correction if needed
        -> cancellation review if needed
        -> retention learning feedback loop
        -> graduation to standard customer when stable

This document protects the project from celebrating conversion too early and losing customers because value, support burden, payment trust, KDS reliability, provider limitations, or pricing expectations were not monitored after the sale.