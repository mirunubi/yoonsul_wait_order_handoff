# 014084_Policy_Multi_Store_Support_Queue_Control

## 1. Purpose

This document defines the multi-store support operations queue, support case prioritization, escalation path, capacity control, support load governance, payment/KDS/provider support routing, customer recovery coordination, and expansion safety policy for the Yoonsul Wait/Order Handoff documentation project.

The previous document defined multi-store operations dashboard, store health, support load, and expansion control policy.

This document defines how support operations must behave when multiple stores generate support requests at the same time.

This document does not implement a support ticket system, CRM, call center workflow, chat tool, automation, or SLA engine.

It defines multi-store support queue and capacity control policy only.

---

## 2. Scope

This document covers:

- multi-store support queue
- support case classification
- support priority
- escalation path
- payment support routing
- KDS support routing
- provider support routing
- Mini Kiosk support routing
- staff support routing
- customer recovery coordination
- support capacity control
- support overload handling
- expansion stop rule
- no-implementation boundary

This document does not cover:

- final support tool
- final CRM
- final helpdesk automation
- final call center staffing
- final legal customer compensation
- final production SLA
- final billing dispute workflow
- final provider contract escalation
- final franchise support center

---

## 3. Core Principle

Support must be governed before scale.

The project must follow this rule:

> Multi-store support requests must be classified, prioritized, routed, evidenced, escalated, and capacity-controlled so that payment, KDS, provider, security, and customer trust risks are handled before general convenience issues.

Support is not a message inbox.

Support is an operational safety layer.

---

## 4. Multi-Store Support Meaning

Multi-store support means:

- multiple stores may request help at the same time
- support issues may affect different runtimes
- support capacity may become constrained
- one provider incident may affect many stores
- payment/KDS incidents may require immediate handling
- staff confusion may repeat across stores
- support evidence must remain traceable
- support access must remain scoped
- expansion must stop if support load becomes unsafe

Support must scale with operational risk.

---

## 5. Support Queue Definition

A support queue is the controlled list of support cases waiting for review, action, escalation, or closure.

The queue should show:

- support case id
- store
- tenant
- runtime affected
- severity
- priority
- customer impact
- payment impact
- KDS impact
- provider impact
- security impact
- assigned owner
- status
- age
- escalation status
- evidence status

Queue visibility must follow role and scope rules.

---

## 6. Support Case Source Types

Support case may originate from:

- store staff request
- owner request
- customer complaint
- Mini Kiosk issue
- payment uncertainty
- KDS issue
- provider failure
- device trust issue
- dashboard alert
- pilot incident
- evidence gap
- security incident
- billing question
- renewal/churn risk
- expansion onboarding issue

Source type helps prioritize response.

---

## 7. Support Case Classification Values

Recommended support case classifications:

- `PAYMENT_SUPPORT_CASE`
- `KDS_SUPPORT_CASE`
- `PROVIDER_SUPPORT_CASE`
- `MINI_KIOSK_SUPPORT_CASE`
- `ORDER_STATE_SUPPORT_CASE`
- `CUSTOMER_RECOVERY_SUPPORT_CASE`
- `STAFF_TRAINING_SUPPORT_CASE`
- `DEVICE_TRUST_SUPPORT_CASE`
- `TENANT_STORE_BOUNDARY_SUPPORT_CASE`
- `EXPORT_SUPPORT_CASE`
- `SECURITY_SUPPORT_CASE`
- `BILLING_SUPPORT_CASE`
- `RENEWAL_CHURN_SUPPORT_CASE`
- `EXPANSION_ONBOARDING_SUPPORT_CASE`
- `GENERAL_USAGE_SUPPORT_CASE`

Classification determines routing.

---

## 8. Support Severity Values

Recommended severity values:

- `SUPPORT_SEVERITY_CRITICAL`
- `SUPPORT_SEVERITY_HIGH`
- `SUPPORT_SEVERITY_MEDIUM`
- `SUPPORT_SEVERITY_LOW`
- `SUPPORT_OBSERVATION`

Severity should reflect operational risk, not user emotion alone.

---

## 9. Critical Support Cases

Critical support cases include:

- duplicate payment suspected
- false payment approval shown
- customer charged but order state unclear
- duplicate KDS ticket prepared
- cancelled order prepared
- support masking failure
- raw CI/DI exposure
- tenant/store data leakage
- provider replay accepted as valid
- invalid provider callback accepted
- device revocation failure
- rollback/disable path failed
- multiple stores affected by same provider failure

Critical support cases require immediate escalation.

---

## 10. High Support Cases

High support cases include:

- payment uncertainty delaying customer recovery
- KDS ticket missing but food not yet prepared
- KDS duplicate suspected but caught
- provider timeout affecting active order flow
- Mini Kiosk failure during live pilot
- support evidence missing for important incident
- staff cannot determine safe state
- fallback required during customer interaction
- owner reports repeated trust issue
- customer recovery required

High cases require same-day review.

---

## 11. Medium Support Cases

Medium support cases include:

- staff confusion over state label
- customer confused but not harmed
- KDS wording unclear
- provider status unclear but not blocking
- support case needs evidence cleanup
- training refresh needed
- Mini Kiosk timeout confusion
- owner asks for usage clarification
- renewal concern but no cancellation request

Medium cases should be reviewed in normal queue cadence.

---

## 12. Low Support Cases

Low support cases include:

- cosmetic UI feedback
- minor report question
- general usage question
- non-urgent training request
- feature suggestion
- package explanation
- future provider inquiry
- non-blocking dashboard question

Low cases must not block critical operational support.

---

## 13. Support Priority Values

Recommended priority values:

- `P0_IMMEDIATE`
- `P1_SAME_DAY`
- `P2_NEXT_BUSINESS_DAY`
- `P3_NORMAL`
- `P4_BACKLOG`
- `P5_OBSERVATION`

Priority may differ from severity when capacity is constrained.

---

## 14. Priority Assignment Rule

Priority should consider:

- customer currently waiting
- payment money at risk
- kitchen execution at risk
- data exposure risk
- multiple stores affected
- active pilot or paid customer
- renewal/churn risk
- provider outage impact
- support capacity
- availability of workaround
- evidence completeness

Payment, KDS, security, and customer recovery risks should outrank convenience issues.

---

## 15. Support Queue Record Fields

Each support queue item should include:

- queue item id
- support case id
- tenant id
- store id
- source type
- classification
- severity
- priority
- customer impact
- payment impact
- KDS impact
- provider impact
- security impact
- affected runtime
- evidence packet id
- assigned owner
- escalation owner
- status
- created time
- last updated time
- target response expectation
- notes

Queue item must be operationally useful.

---

## 16. Queue Item ID Format

Recommended format:

    SUPPORT-QUEUE-[YYYYMMDD]-[NUMBER]

Example:

    SUPPORT-QUEUE-20260612-001

Store-specific alternative:

    SUPPORT-QUEUE-[STORE-ID]-[YYYYMMDD]-[NUMBER]

Final format may be normalized later.

---

## 17. Support Queue Status Values

Recommended status values:

- `QUEUED`
- `TRIAGE_REQUIRED`
- `ASSIGNED`
- `IN_REVIEW`
- `WAITING_STORE`
- `WAITING_PROVIDER`
- `WAITING_PAYMENT_REVIEW`
- `WAITING_KDS_REVIEW`
- `WAITING_SECURITY_REVIEW`
- `CUSTOMER_RECOVERY_REQUIRED`
- `ESCALATED`
- `RESOLUTION_PROPOSED`
- `RESOLVED`
- `CLOSED`
- `REOPENED`
- `DEFERRED`

Status must not hide waiting state.

---

## 18. Triage Rule

Support triage should determine:

- what happened
- which store is affected
- which customer/order/payment/KDS context is affected
- whether customer is waiting
- whether payment money is at risk
- whether kitchen execution is at risk
- whether data exposure risk exists
- whether provider is involved
- whether evidence exists
- whether immediate pause is required
- who owns next action

Triage is not final resolution.

---

## 19. Assignment Rule

Support case should be assigned based on runtime:

| Case Type | Primary Owner |
| --------- | ------------- |
| Payment uncertainty | Payment support owner |
| KDS ticket issue | KDS support owner |
| Provider callback issue | Provider integration owner |
| Mini Kiosk session issue | Mini Kiosk/runtime owner |
| Support masking issue | Security/support governance owner |
| Tenant/store data issue | Security/runtime owner |
| Staff training issue | Operations/training owner |
| Customer recovery | Store manager/support owner |
| Billing question | SaaS billing owner |

Owner must be explicit.

---

## 20. Escalation Rule

Escalation is required when:

- case severity is critical
- payment money is at risk
- customer trust is at risk
- KDS execution is unsafe
- provider issue affects multiple stores
- support masking fails
- tenant/store boundary issue appears
- staff cannot determine safe state
- case remains unresolved beyond expected time
- repeated similar case appears

Escalation must create evidence.

---

## 21. Escalation Levels

Recommended escalation levels:

- `L0_STORE_SELF_HELP`
- `L1_SUPPORT_TRIAGE`
- `L2_RUNTIME_OWNER_REVIEW`
- `L3_PROVIDER_OR_PAYMENT_REVIEW`
- `L4_SECURITY_OR_INCIDENT_REVIEW`
- `L5_BUSINESS_OWNER_DECISION`
- `L6_PILOT_OR_SCOPE_PAUSE_DECISION`

Escalation level must match risk.

---

## 22. Escalation Record Fields

Each escalation should record:

- escalation id
- support case id
- from level
- to level
- reason
- severity
- affected runtime
- affected store
- customer impact
- evidence packet
- assigned owner
- decision needed
- status
- timestamp
- notes

Escalation without decision is incomplete.

---

## 23. Escalation ID Format

Recommended format:

    SUPPORT-ESCALATION-[YYYYMMDD]-[NUMBER]

Example:

    SUPPORT-ESCALATION-20260612-001

Final format may be normalized later.

---

## 24. Payment Support Routing

Payment support must handle:

- payment pending too long
- payment approved but order unclear
- order accepted but payment uncertain
- duplicate payment suspicion
- refund/cancel confusion
- invalid callback
- replay event
- provider approval mismatch
- customer asks whether charged
- evidence missing

Payment support must not guess.

Payment truth requires evidence.

---

## 25. KDS Support Routing

KDS support must handle:

- ticket not created
- ticket pending too long
- duplicate ticket suspected
- held ticket misunderstood
- cancelled order reached kitchen
- KDS bridge stale event
- KDS unavailable
- degraded kitchen note
- manual fallback
- kitchen staff confusion

KDS support must protect kitchen execution.

---

## 26. Provider Support Routing

Provider support must handle:

- callback delay
- duplicate callback
- provider timeout
- invalid signature
- mapping failure
- local daemon issue
- cloud API issue
- provider unavailable
- refund/cancel provider limitation
- dealer/support dependency

Provider issue must be separated from Yoonsul runtime truth.

---

## 27. Mini Kiosk Support Routing

Mini Kiosk support must handle:

- session start failure
- timeout confusion
- abandonment issue
- order intent not captured
- unsupported option attempt
- payment handoff confusion
- customer needs staff help
- provider unavailable display
- UI wording confusion

Mini Kiosk support should not promise final payment or order truth.

---

## 28. Customer Recovery Coordination

Customer recovery support should coordinate:

- customer apology
- safe payment confirmation
- order state confirmation
- refund/cancel review
- manual fallback if needed
- store manager action
- support evidence
- customer follow-up
- recovery note

Customer recovery must be humane and evidence-based.

---

## 29. Staff Training Support Routing

Staff training support should handle:

- repeated staff confusion
- unclear state label
- unclear fallback path
- unclear customer script
- unclear KDS state
- unclear payment uncertainty
- unclear support escalation
- poor evidence capture
- stop/pause misunderstanding

Repeated training cases may become SOP update.

---

## 30. Security Support Routing

Security support must handle:

- support masking failure
- raw CI/DI exposure
- tenant/store boundary issue
- device trust issue
- lost device
- suspicious access
- export concern
- secret exposure
- break-glass misuse

Security cases may override normal support queue order.

---

## 31. Support Evidence Requirement

Support case evidence should include:

- support case id
- store
- tenant
- affected runtime
- source type
- severity
- state before
- state after
- action taken
- support actor
- escalation path
- customer impact
- evidence packet
- masking status
- resolution status
- notes

Support evidence must avoid raw sensitive data.

---

## 32. Support Masking Rule

Support view must mask:

- raw CI/DI
- customer sensitive identity data
- payment secrets
- provider secrets
- raw tokens
- staff private data beyond need
- cross-store data
- unrelated customer data

Support access must remain case-scoped and time-bound.

---

## 33. Support Capacity Status Values

Recommended capacity status values:

- `SUPPORT_CAPACITY_UNKNOWN`
- `SUPPORT_CAPACITY_NORMAL`
- `SUPPORT_CAPACITY_TIGHT`
- `SUPPORT_CAPACITY_OVERLOADED`
- `SUPPORT_CAPACITY_CRITICAL`
- `SUPPORT_CAPACITY_UNAVAILABLE`

Capacity should be visible to expansion decision makers.

---

## 34. Support Capacity Inputs

Support capacity may be derived from:

- active support case count
- critical case count
- high case count
- unresolved case age
- support owner availability
- provider wait time
- payment review queue
- KDS review queue
- security review queue
- active pilot count
- active paid store count
- expansion onboarding count
- after-hours support expectation

Capacity is operational reality, not intention.

---

## 35. Support Overload Rule

Support overload exists when:

- critical cases wait too long
- high cases accumulate
- support owner unavailable
- multiple stores affected simultaneously
- payment review queue blocks customer recovery
- KDS review queue blocks kitchen trust
- provider wait time blocks resolution
- evidence is incomplete across many cases
- expansion onboarding competes with live support

Overload must trigger scope control.

---

## 36. Support Overload Actions

When support overload occurs:

1. pause non-critical expansion
2. prioritize payment/KDS/security cases
3. defer low-priority feature questions
4. assign runtime owners
5. notify affected store managers
6. restrict pilot scope if needed
7. create support capacity blocker
8. review staffing or process gap
9. update dashboard support load status
10. review pricing/support tier if recurring

Overload should not be hidden.

---

## 37. Expansion Impact Rule

Expansion must pause or slow when:

- support capacity is overloaded
- critical support cases are unresolved
- multiple stores show high support load
- provider issue affects more than one store
- support evidence is incomplete
- support masking issue is unresolved
- staff training cases repeat across stores
- support response misses customer recovery needs

Support capacity is a gate for growth.

---

## 38. Queue Aging Rule

Queue aging should be visible.

Recommended aging buckets:

- `UNDER_15_MINUTES`
- `15_TO_60_MINUTES`
- `1_TO_4_HOURS`
- `SAME_DAY`
- `NEXT_DAY`
- `OVER_2_DAYS`
- `OVER_1_WEEK`

Aging expectations should vary by priority.

P0/P1 cases should not age silently.

---

## 39. Reopen Rule

Support case may reopen when:

- same issue recurs
- evidence was incomplete
- customer recovery failed
- staff says resolution did not work
- provider response contradicts resolution
- payment state changes
- KDS issue reappears
- support masking issue remains
- owner disputes closure

Reopened cases should review root cause.

---

## 40. Support Trend Review

Support trends should be reviewed by:

- case classification
- severity
- store
- provider stack
- runtime
- staff role
- customer impact
- repeated issue
- time of day
- module
- package
- support owner

Trends inform product, SOP, training, pricing, and expansion.

---

## 41. Support To Backlog Rule

Support case should create backlog when:

- repeated issue appears
- UI wording causes confusion
- staff training cannot solve issue
- provider adapter needs guard
- payment uncertainty path is unclear
- KDS handoff guard is insufficient
- evidence packet is hard to collect
- support workflow is too manual
- dashboard lacks needed signal

Support queue is a product discovery source.

---

## 42. Support To SOP Rule

Support case should create SOP update when:

- staff response inconsistent
- customer script unclear
- fallback path unclear
- manager approval unclear
- escalation timing unclear
- evidence capture missed
- support handoff poorly understood

SOP update must be paired with training if staff-facing.

---

## 43. Support To Pricing Rule

Support trend may affect pricing when:

- support burden exceeds package expectation
- repeated provider coordination is required
- customer expects premium support on basic package
- support saves payment/KDS incidents frequently
- onboarding support is heavier than planned
- after-hours support is requested
- multi-store support becomes complex

Pricing must reflect real support cost.

---

## 44. Support Case Closure Rule

Support case may close only when:

- resolution is recorded
- evidence is linked
- customer/store impact is handled
- runtime owner review is complete if needed
- escalation is complete if any
- blocker/backlog/SOP decision is made if needed
- sensitive data is masked
- closure reason is recorded

Closure is not simply “no more messages.”

---

## 45. Support Register Recommendation

Recommended future files:

    docs/_index/
      Multi_Store_Support_Queue_Register.md
      Support_Case_Classification_Register.md
      Support_Escalation_Register.md
      Support_Capacity_Register.md
      Support_Overload_Register.md
      Support_To_Backlog_Register.md
      Support_To_SOP_Register.md
      Support_To_Pricing_Register.md

This document only recommends these files.

It does not create them.

---

## 46. Anti-Patterns

The following are prohibited:

- treating support queue as casual chat
- handling payment cases by guessing
- letting KDS cases wait while kitchen is blocked
- exposing raw CI/DI in support view
- allowing support to mutate runtime truth silently
- closing support case without evidence
- hiding support overload
- expanding stores while support is overloaded
- treating all support cases as same priority
- allowing low-priority questions to bury critical cases
- ignoring repeated staff confusion
- ignoring provider trend across stores
- using support heroics instead of fixing product/SOP
- offering cheap package that requires premium support

---

## 47. Non-Goals

This document does not define:

- final helpdesk software
- final CRM implementation
- final support staffing model
- final SLA contract
- final provider escalation contract
- final compensation policy
- final legal customer dispute process
- final franchise support center

Those belong to later operational and commercial planning.

---

## 48. Readiness Check

This document is ready when the project can answer:

1. What does multi-store support mean?
2. What is support queue?
3. What support case source types exist?
4. What support classifications exist?
5. What severity values exist?
6. What are critical support cases?
7. What are high support cases?
8. What priority values exist?
9. How is priority assigned?
10. What fields should support queue record include?
11. What queue statuses exist?
12. What does triage determine?
13. How is assignment made?
14. When is escalation required?
15. What escalation levels exist?
16. What fields should escalation record include?
17. How is payment support routed?
18. How is KDS support routed?
19. How is provider support routed?
20. How is Mini Kiosk support routed?
21. How is customer recovery coordinated?
22. How is staff training support routed?
23. How is security support routed?
24. What evidence is required?
25. What masking rule applies?
26. What capacity statuses exist?
27. What capacity inputs exist?
28. When does overload exist?
29. What actions follow overload?
30. How does support affect expansion?
31. What queue aging rule applies?
32. When may case reopen?
33. How are support trends reviewed?
34. When does support become backlog?
35. When does support become SOP update?
36. When does support affect pricing?
37. When may support case close?
38. What anti-patterns are prohibited?

If these questions cannot be answered, multi-store support queue and capacity control planning is incomplete.

---

## 49. Conclusion

Multi-store support must be structured before the system scales.

The safe support flow is:

    support request
        -> classification
        -> severity
        -> priority
        -> assignment
        -> evidence review
        -> escalation if needed
        -> customer/store recovery
        -> blocker/backlog/SOP/pricing decision
        -> closure with evidence
        -> trend review
        -> expansion capacity decision

This document ensures that support remains a controlled recovery layer rather than an overloaded chat channel, and that payment, KDS, provider, security, staff, and customer trust risks are handled before expansion continues.