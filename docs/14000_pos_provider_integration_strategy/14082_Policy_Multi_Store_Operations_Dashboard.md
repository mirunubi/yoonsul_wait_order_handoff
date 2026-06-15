# 14082_Policy_Multi_Store_Operations_Dashboard

## 1. Purpose

This document defines the multi-store operations dashboard, store health monitoring, support load visibility, provider stack status, payment/KDS safety indicators, expansion control, renewal risk visibility, and operational governance policy for the Yoonsul Wait/Order Handoff documentation project.

The previous document defined multi-store expansion readiness, repeatable onboarding, and provider stack replication policy.

This document defines how multiple stores should be monitored after expansion begins so that operational risk, support burden, customer value, and expansion readiness remain visible.

This document does not implement a dashboard, analytics pipeline, database view, BI report, alerting system, or customer success tool.

It defines multi-store operations dashboard policy only.

---

## 2. Scope

This document covers:

- multi-store dashboard purpose
- store health indicator
- support load indicator
- provider stack status
- payment safety indicator
- KDS safety indicator
- Mini Kiosk usage indicator
- staff adoption indicator
- customer trust indicator
- evidence completeness indicator
- renewal and churn risk indicator
- expansion control indicator
- dashboard status values
- no-implementation boundary

This document does not cover:

- final dashboard UI
- final database schema
- final analytics implementation
- final BI platform
- final alert engine
- final CRM integration
- final billing automation
- final SLA dashboard
- final franchise command center

---

## 3. Core Principle

Multi-store operation requires visibility before scale.

The project must follow this rule:

> Once multiple stores are active, store health, support burden, provider reliability, payment/KDS safety, staff adoption, evidence completeness, and expansion risk must be visible before additional rollout decisions are made.

A system that cannot see store health cannot safely scale.

---

## 4. Multi-Store Dashboard Meaning

A multi-store operations dashboard is a governance surface that shows:

- which stores are active
- which modules are enabled
- which provider stack each store uses
- whether payment/KDS flows are stable
- whether support burden is rising
- whether staff adoption is healthy
- whether customer trust risk exists
- whether evidence is complete
- whether renewal/churn risk is rising
- whether expansion should continue, pause, or narrow

The dashboard is not merely a sales report.

It is an operational control surface.

---

## 5. Dashboard User Groups

Recommended dashboard user groups:

| User Group | Primary Need |
| ---------- | ------------ |
| HQ Operator | store health and support load |
| Support Lead | support cases and escalation |
| Provider Integration Owner | provider status and failures |
| Payment Runtime Owner | payment certainty and exceptions |
| KDS Runtime Owner | kitchen handoff safety |
| Customer Success Owner | renewal, churn, value, adoption |
| Expansion Owner | next-store readiness and risk |
| Security Owner | masking, device, tenant boundary |
| Store Owner | store-specific operational summary |

Different users should see different scope and detail.

---

## 6. Dashboard Scope Boundary

Dashboard must respect:

- tenant boundary
- store boundary
- role boundary
- support scope boundary
- export boundary
- masking boundary
- provider secret boundary
- CI/DI protection boundary
- payment data protection boundary

Dashboard visibility is not export authority.

Dashboard visibility is not mutation authority.

---

## 7. Store Health Status Values

Recommended store health status values:

- `STORE_HEALTH_UNKNOWN`
- `STORE_HEALTH_GOOD`
- `STORE_HEALTH_WATCH`
- `STORE_HEALTH_WARNING`
- `STORE_HEALTH_CRITICAL`
- `STORE_HEALTH_PAUSED`
- `STORE_HEALTH_EXITING`
- `STORE_HEALTH_OFFBOARDED`

Store health should reflect operational condition, not only subscription status.

---

## 8. Store Health Inputs

Store health may be derived from:

- payment uncertainty frequency
- payment incident severity
- KDS issue frequency
- duplicate KDS suspicion
- provider incident frequency
- support case volume
- support case severity
- fallback frequency
- staff adoption status
- customer complaint count
- evidence completeness
- unresolved blockers
- renewal/churn risk
- rollback readiness
- security incident status

Store health should be conservative.

---

## 9. Store Health Calculation Boundary

Store health calculation may be automated later, but early stage may be manually reviewed.

Rules:

- critical payment risk should increase severity
- critical KDS risk should increase severity
- support masking failure should become critical
- tenant/store leakage should become critical
- evidence gap should prevent healthy classification
- unresolved high blockers should prevent good status
- low usage alone should not always mean critical
- high support burden should trigger watch or warning

Health score must not hide serious incidents behind averages.

---

## 10. Support Load Status Values

Recommended support load status values:

- `SUPPORT_LOAD_UNKNOWN`
- `SUPPORT_LOAD_NORMAL`
- `SUPPORT_LOAD_ELEVATED`
- `SUPPORT_LOAD_HIGH`
- `SUPPORT_LOAD_CRITICAL`
- `SUPPORT_LOAD_UNSUSTAINABLE`

Support load must be tracked before adding stores.

---

## 11. Support Load Inputs

Support load may be derived from:

- support case count
- support case severity
- unresolved support cases
- support session count
- break-glass count
- repeated issue count
- payment review requests
- KDS review requests
- provider review requests
- staff retraining requests
- customer recovery cases
- support response time
- support owner capacity

Support burden affects pricing, expansion, and retention.

---

## 12. Provider Stack Status Values

Recommended provider stack status values:

- `PROVIDER_STACK_UNKNOWN`
- `PROVIDER_STACK_STABLE`
- `PROVIDER_STACK_WATCH`
- `PROVIDER_STACK_WARNING`
- `PROVIDER_STACK_BLOCKED`
- `PROVIDER_STACK_DEGRADED`
- `PROVIDER_STACK_DISABLED`
- `PROVIDER_STACK_UNSUPPORTED`

Provider status should be store-specific.

Same provider may behave differently by store setup.

---

## 13. Provider Stack Inputs

Provider status may be derived from:

- POS provider
- payment provider
- kiosk provider
- KDS provider
- cloud API status
- local daemon status
- webhook reliability
- callback duplication
- mapping failure
- provider timeout
- refund/cancel support
- dealer/support responsiveness
- hardware dependency
- disable path availability

Provider stack must not be treated as a single brand label.

---

## 14. Payment Safety Status Values

Recommended payment safety status values:

- `PAYMENT_SAFETY_UNKNOWN`
- `PAYMENT_SAFETY_STABLE`
- `PAYMENT_SAFETY_WATCH`
- `PAYMENT_SAFETY_WARNING`
- `PAYMENT_SAFETY_CRITICAL`
- `PAYMENT_SAFETY_RECONCILIATION_REQUIRED`
- `PAYMENT_SAFETY_DISABLED`

Payment safety should be visible per store and per provider path.

---

## 15. Payment Safety Inputs

Payment safety may be derived from:

- payment approval count
- payment uncertainty count
- payment failure count
- duplicate payment suspicion
- invalid callback rejection
- replay detection
- refund/cancel issue
- payment evidence completeness
- customer recovery case
- support payment review count
- provider payment delay

Payment safety weakness can block expansion.

---

## 16. KDS Safety Status Values

Recommended KDS safety status values:

- `KDS_SAFETY_UNKNOWN`
- `KDS_SAFETY_STABLE`
- `KDS_SAFETY_WATCH`
- `KDS_SAFETY_WARNING`
- `KDS_SAFETY_CRITICAL`
- `KDS_SAFETY_DEGRADED`
- `KDS_SAFETY_DISABLED`

KDS status must reflect kitchen execution safety.

---

## 17. KDS Safety Inputs

KDS safety may be derived from:

- KDS ticket count
- KDS ticket accepted count
- KDS held count
- duplicate KDS suspicion
- missing KDS ticket incident
- cancelled order kitchen impact
- stale bridge event
- degraded kitchen note use
- manual kitchen fallback count
- KDS evidence completeness
- kitchen staff confusion
- KDS support case count

KDS issue is operational risk, not only technical error.

---

## 18. Mini Kiosk Usage Status Values

Recommended values:

- `MINI_KIOSK_UNKNOWN`
- `MINI_KIOSK_ACTIVE_STABLE`
- `MINI_KIOSK_LOW_USAGE`
- `MINI_KIOSK_CONFUSION_WATCH`
- `MINI_KIOSK_TIMEOUT_HIGH`
- `MINI_KIOSK_SUPPORT_HEAVY`
- `MINI_KIOSK_DISABLED`

Mini Kiosk health should combine usage and safety.

---

## 19. Mini Kiosk Inputs

Mini Kiosk status may be derived from:

- session starts
- order intent captures
- abandoned sessions
- timeout count
- staff intervention count
- customer confusion count
- provider failure display count
- payment uncertainty display count
- support handoff count
- unsupported path attempts
- completed flow count

Low usage may indicate placement, training, wording, or trust issue.

---

## 20. Staff Adoption Status Values

Recommended values:

- `STAFF_ADOPTION_UNKNOWN`
- `STAFF_ADOPTION_GOOD`
- `STAFF_ADOPTION_WATCH`
- `STAFF_ADOPTION_TRAINING_REQUIRED`
- `STAFF_ADOPTION_RESISTANCE`
- `STAFF_ADOPTION_CRITICAL`

Staff adoption must remain visible after onboarding.

---

## 21. Staff Adoption Inputs

Staff adoption may be derived from:

- staff intervention count
- staff confusion log
- training completion
- fallback misuse
- support escalation correctness
- evidence capture quality
- KDS state understanding
- payment uncertainty handling
- customer script use
- system bypass frequency

Staff behavior is part of system health.

---

## 22. Customer Trust Status Values

Recommended values:

- `CUSTOMER_TRUST_UNKNOWN`
- `CUSTOMER_TRUST_STABLE`
- `CUSTOMER_TRUST_WATCH`
- `CUSTOMER_TRUST_WARNING`
- `CUSTOMER_TRUST_CRITICAL`

Customer trust status should not be reduced to satisfaction score only.

---

## 23. Customer Trust Inputs

Customer trust may be derived from:

- customer complaint count
- payment concern count
- order confusion count
- KDS wait concern
- customer recovery count
- repeat usage
- refusal to use Mini Kiosk
- refund/cancel concern
- staff communication issue
- negative pilot feedback

Customer trust can be damaged faster than product metrics show.

---

## 24. Evidence Completeness Status Values

Recommended values:

- `EVIDENCE_UNKNOWN`
- `EVIDENCE_COMPLETE`
- `EVIDENCE_MINOR_GAPS`
- `EVIDENCE_MAJOR_GAPS`
- `EVIDENCE_UNRELIABLE`
- `EVIDENCE_REVIEW_REQUIRED`

Evidence completeness determines whether dashboard signals can be trusted.

---

## 25. Evidence Completeness Inputs

Evidence completeness may be derived from:

- payment evidence packets
- KDS evidence packets
- support evidence packets
- provider evidence packets
- incident records
- blocker records
- fallback records
- pilot run records
- daily/weekly reviews
- renewal reviews
- masking confirmation
- missing field count

If evidence is unreliable, status should not be marked healthy.

---

## 26. Renewal And Churn Risk Status Values

Recommended values:

- `RENEWAL_NOT_DUE`
- `RENEWAL_HEALTHY`
- `RENEWAL_WATCH`
- `RENEWAL_RISK`
- `DOWNGRADE_RISK`
- `CANCELLATION_RISK`
- `CHURNED`
- `EXPANSION_CANDIDATE`

Commercial status should be linked to operational evidence.

---

## 27. Renewal And Churn Inputs

Renewal/churn risk may be derived from:

- owner value feedback
- staff adoption
- support burden
- pricing objection
- downgrade request
- cancellation request
- usage decrease
- unresolved blocker
- repeated incidents
- provider instability
- payment/KDS trust issue
- customer complaints
- expansion interest

Churn risk must be visible before renewal date.

---

## 28. Expansion Control Status Values

Recommended values:

- `EXPANSION_ALLOWED`
- `EXPANSION_WATCH`
- `EXPANSION_REVIEW_REQUIRED`
- `EXPANSION_PAUSED`
- `EXPANSION_BLOCKED`
- `EXPANSION_REDUCE_SCOPE`
- `EXPANSION_EXIT_CANDIDATE`

Expansion control should be based on store health and support capacity.

---

## 29. Expansion Control Inputs

Expansion control may be derived from:

- current store health
- support load
- provider stack stability
- payment safety
- KDS safety
- staff adoption
- evidence completeness
- open blockers
- current expansion stage
- support owner capacity
- next-store risk
- commercial pressure

Expansion should stop when visibility is weak.

---

## 30. Dashboard Store Summary Record Fields

Each store dashboard summary should include:

- store id
- tenant id
- package
- enabled modules
- provider stack
- store health
- support load status
- payment safety status
- KDS safety status
- Mini Kiosk status
- staff adoption status
- customer trust status
- evidence completeness status
- renewal/churn status
- expansion control status
- open blocker count
- critical incident count
- last review date
- next review date
- notes

This summary gives one-page operational visibility.

---

## 31. Dashboard Summary ID Format

Recommended format:

    STORE-DASHBOARD-[STORE-ID]-[YYYYMMDD]

Example:

    STORE-DASHBOARD-STORE001-20260612

Final format may be normalized later.

---

## 32. Dashboard Alert Levels

Recommended dashboard alert levels:

- `ALERT_NONE`
- `ALERT_INFO`
- `ALERT_WATCH`
- `ALERT_WARNING`
- `ALERT_CRITICAL`
- `ALERT_ACTION_REQUIRED`

Alert level should be tied to action.

---

## 33. Alert Trigger Examples

Critical alert examples:

- duplicate payment suspected
- false payment approval
- duplicate KDS ticket prepared
- support masking failure
- tenant/store data leakage
- raw CI/DI exposure
- rollback disabled
- evidence unreliable for critical incident

Warning alert examples:

- payment uncertainty rising
- KDS held tickets increasing
- support load high
- provider timeout repeated
- staff confusion repeated
- Mini Kiosk abandonment high
- renewal risk rising

Alerts should not become noise.

---

## 34. Dashboard Review Cadence

Recommended cadence:

| Review | Cadence |
| ------ | ------- |
| Critical alert review | immediate |
| Warning alert review | same day or next business day |
| Store health review | weekly during expansion |
| Support load review | weekly |
| Provider stack review | weekly or after incident |
| Payment/KDS safety review | weekly |
| Renewal risk review | monthly or before renewal |
| Expansion control review | before each new store |

Cadence should match risk.

---

## 35. Dashboard User Permission Rule

Dashboard access should follow:

- least privilege
- tenant/store scope
- role scope
- support case scope
- masking by default
- no raw CI/DI
- no provider secrets
- no payment secrets
- no export without approval
- audit for sensitive views

Dashboard is a sensitive operational surface.

---

## 36. Dashboard Action Boundary

Dashboard may support:

- review
- filtering
- status visibility
- evidence link
- blocker link
- support case link
- renewal risk review
- expansion decision review

Dashboard must not silently execute:

- payment approval
- refund completion
- KDS completion
- support break-glass
- device trust override
- export generation
- provider disable
- subscription cancellation

Action surfaces require separate authority.

---

## 37. Store Health Review Decision Values

Recommended values:

- `NO_ACTION`
- `MONITOR`
- `CREATE_BLOCKER`
- `CREATE_SUPPORT_REVIEW`
- `CREATE_PROVIDER_REVIEW`
- `CREATE_PAYMENT_REVIEW`
- `CREATE_KDS_REVIEW`
- `CREATE_TRAINING_ITEM`
- `CREATE_RETENTION_INTERVENTION`
- `PAUSE_STORE_SCOPE`
- `REDUCE_STORE_SCOPE`
- `PAUSE_EXPANSION`
- `BLOCK_EXPANSION`
- `APPROVE_NEXT_SCOPE`

Dashboard review must result in action when needed.

---

## 38. Multi-Store Rollup View

A future multi-store rollup may show:

- total active stores
- stores by health status
- stores by provider stack
- stores by package
- stores by support load
- stores with payment warning
- stores with KDS warning
- stores with churn risk
- stores eligible for expansion
- stores blocking expansion
- support capacity remaining

Rollup should aid governance, not hide details.

---

## 39. Dashboard Data Quality Rule

Dashboard data quality must be monitored.

Risks:

- stale data
- missing evidence
- inconsistent provider mapping
- inconsistent status definitions
- manual status drift
- delayed support case updates
- incomplete incident records
- false green status
- over-alerting

A dashboard is dangerous if trusted blindly.

---

## 40. Dashboard Manual Override Rule

Manual status override may be allowed only when:

- reason is recorded
- actor is authorized
- evidence is linked
- expiration or review date exists
- original status is preserved
- audit event is created
- override does not hide critical issue

Manual override must not become cosmetic status cleanup.

---

## 41. Expansion Stop Rule

Expansion must pause when dashboard shows:

- support load critical
- payment safety critical
- KDS safety critical
- provider stack blocked
- tenant/store boundary issue
- evidence unreliable
- multiple stores warning simultaneously
- unresolved critical blocker
- support capacity insufficient
- current store instability

Growth should stop before system breaks.

---

## 42. Registers Recommendation

Recommended future files:

    docs/_index/
      Multi_Store_Dashboard_Register.md
      Store_Health_Status_Register.md
      Support_Load_Status_Register.md
      Provider_Stack_Status_Register.md
      Payment_Safety_Status_Register.md
      KDS_Safety_Status_Register.md
      Expansion_Control_Status_Register.md
      Dashboard_Alert_Register.md

This document only recommends these files.

It does not create them.

---

## 43. Anti-Patterns

The following are prohibited:

- treating dashboard as sales leaderboard only
- hiding critical incidents behind average score
- marking store healthy with missing evidence
- expanding while support load is critical
- expanding while payment safety is uncertain
- expanding while KDS duplicate risk exists
- showing raw CI/DI on dashboard
- exposing provider secrets
- giving all users all-store visibility
- using dashboard button to mutate runtime truth silently
- ignoring dashboard data quality
- manually overriding status without evidence
- treating low usage as automatically safe
- treating high usage as automatically healthy

---

## 44. Non-Goals

This document does not define:

- final dashboard UI
- final metrics pipeline
- final data warehouse
- final BI tool
- final alert engine
- final CRM integration
- final billing system
- final production SLA dashboard
- final franchise command center

Those belong to later implementation and operations planning.

---

## 45. Readiness Check

This document is ready when the project can answer:

1. What does multi-store dashboard mean?
2. Who are dashboard user groups?
3. What dashboard scope boundary applies?
4. What store health status values exist?
5. What inputs affect store health?
6. What support load values exist?
7. What inputs affect support load?
8. What provider stack values exist?
9. What inputs affect provider stack status?
10. What payment safety values exist?
11. What inputs affect payment safety?
12. What KDS safety values exist?
13. What inputs affect KDS safety?
14. What Mini Kiosk status values exist?
15. What inputs affect Mini Kiosk status?
16. What staff adoption status values exist?
17. What inputs affect staff adoption?
18. What customer trust values exist?
19. What inputs affect customer trust?
20. What evidence completeness values exist?
21. What renewal/churn values exist?
22. What expansion control values exist?
23. What fields should store dashboard summary include?
24. What alert levels exist?
25. What alert triggers exist?
26. What review cadence applies?
27. What dashboard permission rule applies?
28. What dashboard action boundary applies?
29. What store health review decisions exist?
30. What multi-store rollup view may show?
31. What data quality rule applies?
32. What manual override rule applies?
33. When must expansion stop?
34. What anti-patterns are prohibited?

If these questions cannot be answered, multi-store operations dashboard and expansion control planning is incomplete.

---

## 46. Conclusion

Multi-store operation requires operational visibility before growth.

The safe governance flow is:

    store data
        -> store health summary
        -> support load review
        -> payment/KDS/provider safety review
        -> customer/staff/adoption review
        -> evidence completeness review
        -> renewal/churn review
        -> expansion control decision

A dashboard is not decoration.

It is the control surface that prevents multi-store expansion from turning hidden payment, KDS, provider, support, evidence, staff, and customer trust risks into systemic failure.