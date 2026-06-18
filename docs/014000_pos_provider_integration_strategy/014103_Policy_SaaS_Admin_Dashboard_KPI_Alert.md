# 014103_Policy_SaaS_Admin_Dashboard_KPI_Alert

## 1. Purpose

This document defines the SaaS Admin Console dashboard card, KPI widget, alert widget, drilldown, status summary, operational signal, commercial signal, evidence linkage, and no-direct-mutation boundary policy for the Yoonsul Wait/Order Handoff documentation project.

The previous document defined Admin Console surface map, navigation, information architecture, and screen grouping policy.

This document defines how dashboard cards and widgets should behave inside Admin Console surfaces before wireframe, backlog extraction, or implementation begins.

This document does not implement dashboard UI, frontend widgets, backend queries, KPI formulas, alert engines, APIs, database views, or analytics pipelines.

It defines dashboard card and widget governance policy only.

---

## 2. Scope

This document covers:

- dashboard card purpose
- KPI widget boundary
- alert widget boundary
- drilldown boundary
- status summary card
- operational KPI
- payment KPI
- KDS KPI
- provider KPI
- support KPI
- billing KPI
- renewal KPI
- expansion KPI
- security KPI
- evidence linkage
- no-implementation boundary

This document does not cover:

- final dashboard design
- final card layout
- final graph type
- final KPI formula
- final alert automation
- final analytics implementation
- final query optimization
- final data warehouse
- final BI tool integration

---

## 3. Core Principle

A dashboard card is a signal, not an authority.

The project must follow this rule:

> Dashboard cards, KPI widgets, alerts, and drilldowns may summarize operational, commercial, support, provider, payment, KDS, security, and expansion signals only within context and role scope, and must not directly mutate runtime or commercial truth.

A red alert does not approve an action.

A green KPI does not prove readiness by itself.

A drilldown does not grant broader permission.

---

## 4. Dashboard Card Meaning

A dashboard card is a compact surface that summarizes:

- status
- count
- trend
- risk
- alert
- pending action
- blocker
- review item
- evidence completeness
- forecast
- readiness
- capacity

Dashboard card should guide user attention.

It should not replace evidence review.

---

## 5. KPI Widget Meaning

A KPI widget is a dashboard element that displays a measurable indicator.

KPI may represent:

- store health
- support load
- payment uncertainty
- KDS issue count
- provider incident count
- billing dispute count
- renewal risk
- churn risk
- expansion readiness
- evidence completeness
- security review status
- device trust status

KPI should be tied to defined meaning.

Undefined KPI creates false confidence.

---

## 6. Alert Widget Meaning

An alert widget shows a condition requiring attention.

Alert may represent:

- critical incident
- payment uncertainty
- duplicate risk
- KDS handoff risk
- provider outage
- support overload
- billing dispute
- churn risk
- security incident
- device trust risk
- evidence gap
- expansion blocker

Alert must include next safe workflow, not unsafe shortcut.

---

## 7. Drilldown Meaning

Drilldown means clicking or opening from a summary card into a more detailed surface.

Drilldown may lead to:

- store detail
- support case
- incident detail
- payment review
- KDS review
- provider incident
- billing dispute
- renewal forecast
- expansion review
- evidence packet
- audit event

Drilldown must re-check permission and context.

---

## 8. Card Status Values

Recommended dashboard card status values:

- `CARD_NOT_DEFINED`
- `CARD_DRAFT`
- `CARD_REVIEW_REQUIRED`
- `CARD_ROLE_MAPPING_REQUIRED`
- `CARD_DATA_SOURCE_REVIEW_REQUIRED`
- `CARD_SECURITY_REVIEW_REQUIRED`
- `CARD_READY_FOR_WIREFRAME`
- `CARD_READY_FOR_BACKLOG`
- `CARD_DEFERRED`
- `CARD_REJECTED`

Card should not proceed to wireframe without data and authority review.

---

## 9. KPI Confidence Values

Recommended KPI confidence values:

- `KPI_CONFIDENCE_UNKNOWN`
- `KPI_CONFIDENCE_LOW`
- `KPI_CONFIDENCE_MEDIUM`
- `KPI_CONFIDENCE_HIGH`
- `KPI_CONFIDENCE_EVIDENCE_BACKED`
- `KPI_CONFIDENCE_STALE`

Confidence should be visible when KPI may be incomplete.

---

## 10. KPI Freshness Values

Recommended freshness values:

- `FRESHNESS_REAL_TIME`
- `FRESHNESS_NEAR_REAL_TIME`
- `FRESHNESS_DELAYED`
- `FRESHNESS_MANUAL_REVIEW`
- `FRESHNESS_STALE`
- `FRESHNESS_UNKNOWN`

A delayed KPI must not be presented as live truth.

---

## 11. Alert Severity Values

Recommended alert severity values:

- `ALERT_CRITICAL`
- `ALERT_HIGH`
- `ALERT_MEDIUM`
- `ALERT_LOW`
- `ALERT_INFO`
- `ALERT_OBSERVATION`

Alert severity must be consistent with operational policy.

---

## 12. Alert Status Values

Recommended alert status values:

- `ALERT_OPEN`
- `ALERT_ACK_REQUIRED`
- `ALERT_ACKNOWLEDGED`
- `ALERT_UNDER_REVIEW`
- `ALERT_ESCALATED`
- `ALERT_CONTAINMENT_ACTIVE`
- `ALERT_RESOLVED`
- `ALERT_SUPPRESSED_WITH_REASON`
- `ALERT_FALSE_POSITIVE`
- `ALERT_CLOSED`

Alert closure must require evidence when risk is significant.

---

## 13. Dashboard Card Record Fields

Each dashboard card should record:

- card id
- card name
- surface family
- purpose
- required context
- allowed roles
- KPI or signal displayed
- data source placeholder
- freshness expectation
- confidence rule
- sensitive fields
- masking rule
- drilldown target
- allowed actions
- prohibited actions
- alert rule if any
- evidence link
- audit requirement
- status
- owner
- notes

This record becomes future UI planning input.

---

## 14. Card ID Format

Recommended format:

    ADMIN-CARD-[SURFACE]-[NUMBER]

Examples:

    ADMIN-CARD-HOME-001
    ADMIN-CARD-PAYMENT-001
    ADMIN-CARD-KDS-001
    ADMIN-CARD-SUPPORT-001
    ADMIN-CARD-BILLING-001

Final format may be normalized later.

---

## 15. Home Dashboard Card Examples

Home dashboard may include:

- assigned support cases
- critical alerts
- payment uncertainty count
- KDS warning count
- provider incident count
- billing dispute count
- renewal risk count
- expansion blocker count
- security review count
- pending approvals

Home must be role-scoped.

Home should not expose all-store data to all users.

---

## 16. Store Health Card

Store Health Card may show:

- store health status
- last review date
- critical blocker count
- support load status
- payment safety status
- KDS safety status
- provider stack status
- evidence completeness
- next review requirement

Store health card must drill down to evidence and blockers.

It must not mark store healthy without evidence.

---

## 17. Support Load Card

Support Load Card may show:

- open support case count
- critical support cases
- high support cases
- aging cases
- support capacity status
- overloaded queue indicator
- assigned owner
- escalation count

Support load card must not hide case age.

---

## 18. Payment Safety Card

Payment Safety Card may show:

- payment uncertainty count
- duplicate suspicion count
- reconciliation required count
- invalid callback rejection count
- refund/cancel review count
- customer recovery required count
- evidence completeness

Payment safety card must not show false certainty.

Payment card should never include direct “approve payment” shortcut.

---

## 19. KDS Safety Card

KDS Safety Card may show:

- KDS warning count
- held ticket count
- duplicate ticket suspicion
- degraded kitchen note count
- manual kitchen fallback count
- stale bridge event count
- KDS evidence completeness

KDS safety card must protect kitchen execution truth.

It must not include direct “complete ticket” shortcut unless KDS runtime authority separately governs it.

---

## 20. Provider Incident Card

Provider Incident Card may show:

- open provider incidents
- affected store count
- provider stack status
- webhook/callback issue count
- local daemon issue count
- cloud API issue count
- provider limitation records
- containment active status

Provider incident card must drill down to provider incident review.

It must not expose provider secrets.

---

## 21. Mini Kiosk Health Card

Mini Kiosk Health Card may show:

- active sessions
- timeout count
- abandonment count
- staff intervention count
- unsupported path attempts
- customer confusion signal
- disabled path count
- support linkage

Mini Kiosk card must distinguish low usage from safe operation.

---

## 22. Billing Dispute Card

Billing Dispute Card may show:

- open billing disputes
- critical disputes
- dispute aging
- disputed amount placeholder
- affected line item category
- adjustment review count
- credit review count
- revenue risk linkage

Billing dispute card must not allow silent invoice modification.

---

## 23. Renewal Risk Card

Renewal Risk Card may show:

- upcoming renewals
- high-risk renewals
- churn risk count
- downgrade risk count
- discount expiration count
- provider cost risk count
- support cost risk count
- next intervention due

Renewal risk card must be evidence-linked.

It must not mark customer healthy from payment status only.

---

## 24. Expansion Readiness Card

Expansion Readiness Card may show:

- expansion candidates
- readiness review required
- provider review required
- support capacity review required
- training readiness gap
- payment/KDS blocker count
- expansion approved count
- expansion paused count

Expansion card must not be sales-only.

---

## 25. Commercial Risk Card

Commercial Risk Card may show:

- open commercial risks
- pricing confusion risk
- support cost risk
- provider cost risk
- margin risk
- discount risk
- custom deal risk
- price exception review

Commercial risk card must preserve standard price and exception evidence.

---

## 26. Security Alert Card

Security Alert Card may show:

- open security incidents
- device trust risk
- support masking review
- export requests
- unmask requests
- permission conflicts
- suspicious access
- provider secret exposure risk

Security alert card must be highly role-restricted.

---

## 27. Evidence Completeness Card

Evidence Completeness Card may show:

- incomplete evidence packets
- critical evidence gaps
- stale evidence
- disputed evidence
- pending reviewer count
- missing audit linkage
- unresolved closure evidence

Evidence card should prevent false green dashboards.

---

## 28. Pilot Readiness Card

Pilot Readiness Card may show:

- active pilot stores
- pilot blockers
- pilot incidents
- daily review missing
- weekly consolidation due
- customer feedback status
- staff feedback status
- pilot-to-paid readiness

Pilot card must show limited scope clearly.

---

## 29. Dashboard Drilldown Rule

Every drilldown must:

- re-check role permission
- re-check tenant/store context
- re-check support case scope
- clear stale filters
- preserve current context where safe
- mask sensitive fields
- block unauthorized data
- avoid revealing hidden record existence
- audit sensitive access if required

Drilldown is not permission inheritance.

---

## 30. Drilldown Target Types

Recommended drilldown target types:

- `STORE_DETAIL`
- `SUPPORT_CASE_DETAIL`
- `INCIDENT_DETAIL`
- `PAYMENT_REVIEW_DETAIL`
- `KDS_REVIEW_DETAIL`
- `PROVIDER_INCIDENT_DETAIL`
- `BILLING_DISPUTE_DETAIL`
- `RENEWAL_FORECAST_DETAIL`
- `EXPANSION_REVIEW_DETAIL`
- `EVIDENCE_PACKET_DETAIL`
- `AUDIT_EVENT_DETAIL`
- `SECURITY_REVIEW_DETAIL`

Each target type must have access policy.

---

## 31. Card Action Boundary

Dashboard card may allow safe actions such as:

- view detail
- request review
- create support case
- escalate case
- create blocker
- acknowledge alert
- open evidence packet
- create billing clarification request
- create expansion review request

Dashboard card must not directly:

- approve payment
- complete KDS ticket
- issue refund
- trust provider event
- unmask sensitive data
- export data
- delete evidence
- close critical incident
- change billing amount
- approve expansion

Card actions must start workflows, not bypass them.

---

## 32. Alert Acknowledgement Rule

Alert acknowledgement means:

- user saw the alert
- user accepts responsibility for next review or routing
- alert is no longer unseen

Acknowledgement does not mean:

- issue is resolved
- risk is gone
- customer recovered
- payment reconciled
- KDS safe
- provider fixed
- evidence complete

Acknowledgement must be separate from resolution.

---

## 33. Alert Suppression Rule

Alert suppression may be allowed only when:

- reason is recorded
- duration is defined
- approver is defined
- risk owner accepts
- evidence exists
- recurrence is tracked
- suppression does not hide critical safety issue

Suppression without reason is prohibited.

---

## 34. Alert Grouping Rule

Alert grouping may be used to reduce noise.

Grouping must not hide:

- critical severity
- payment risk
- KDS risk
- tenant/store boundary issue
- raw CI/DI exposure
- support masking failure
- provider mapping issue
- customer trust damage

Grouped alerts must allow drilldown.

---

## 35. KPI Trend Rule

KPI trend should show direction when reliable:

- increasing
- decreasing
- stable
- unknown
- stale

Trend must not be shown when data quality is poor.

Trend should not overstate precision.

---

## 36. KPI Threshold Rule

Thresholds may define:

- green
- watch
- warning
- critical
- unknown
- stale

Thresholds must be domain-specific.

Do not use one universal threshold for payment, KDS, support, billing, and security.

---

## 37. KPI Data Quality Rule

KPI should show data quality when:

- data is delayed
- evidence incomplete
- manual review pending
- provider data uncertain
- local daemon data stale
- support case missing classification
- billing record disputed
- pilot sample too small

Data quality prevents false confidence.

---

## 38. Sensitive KPI Rule

Some KPIs may be sensitive.

Sensitive KPI examples:

- churn risk
- billing dispute amount
- support overload
- security incident count
- payment duplicate suspicion
- provider limitation
- store underperformance
- staff adoption issue

Sensitive KPI must be role-scoped and masked where needed.

---

## 39. KPI Export Rule

Dashboard KPI export requires separate export approval.

Export must define:

- KPI set
- date range
- tenant/store scope
- masking rule
- purpose
- recipient
- retention expectation
- approval
- audit

Viewing KPI does not grant export.

---

## 40. Dashboard Empty State Rule

Dashboard empty state should explain safely:

- no assigned cases
- no current alerts
- no selected store
- no authorized data
- no evidence yet
- no pilot active
- no expansion candidate

Empty state must not reveal unauthorized records.

---

## 41. Dashboard Error State Rule

Dashboard error state must avoid:

- raw stack traces
- secrets
- provider tokens
- raw webhook data
- raw CI/DI
- payment secrets
- unauthorized tenant/store identifiers
- sensitive operational detail

Error should provide safe next action.

---

## 42. Dashboard Stale State Rule

If dashboard data is stale:

- show stale status
- show last updated time if safe
- avoid green certainty
- block risky action if needed
- allow manual review request
- link to evidence if available

Stale data must not look fresh.

---

## 43. Dashboard Card Dependency Rule

Dashboard card should list dependency on:

- source policy
- source data domain
- evidence packet
- permission matrix
- surface map
- masking rule
- export policy
- runtime owner
- commercial owner if applicable

Card dependency prevents disconnected widgets.

---

## 44. Dashboard Card Register Recommendation

Recommended future files:

    docs/_index/
      Admin_Dashboard_Card_Register.md
      Admin_KPI_Widget_Register.md
      Admin_Alert_Widget_Register.md
      Admin_Drilldown_Target_Register.md
      Admin_KPI_Data_Quality_Register.md
      Admin_Alert_Suppression_Register.md
      Admin_Card_Action_Boundary_Register.md
      Admin_KPI_Export_Register.md

This document only recommends these files.

It does not create them.

---

## 45. Anti-Patterns

The following are prohibited:

- treating dashboard card as authority
- showing green KPI without evidence
- hiding stale data
- using one threshold for all domains
- allowing payment approval from card
- allowing KDS completion from card
- allowing export from KPI card without approval
- hiding critical alert inside grouped alert
- suppressing alert without reason
- treating acknowledgement as resolution
- showing sensitive KPI to unauthorized roles
- using drilldown to bypass permission
- showing pilot KPI as production proof
- showing delayed provider data as real-time truth

---

## 46. Non-Goals

This document does not define:

- final dashboard UI
- final KPI formulas
- final alert engine
- final chart components
- final query logic
- final database view
- final analytics warehouse
- final BI integration
- final notification system

Those belong to later UI/UX, analytics, and implementation planning.

---

## 47. Readiness Check

This document is ready when the project can answer:

1. What is dashboard card?
2. What is KPI widget?
3. What is alert widget?
4. What is drilldown?
5. What card status values exist?
6. What KPI confidence values exist?
7. What KPI freshness values exist?
8. What alert severity values exist?
9. What alert status values exist?
10. What fields should card record include?
11. What Home dashboard cards may exist?
12. What Store Health card may show?
13. What Support Load card may show?
14. What Payment Safety card may show?
15. What KDS Safety card may show?
16. What Provider Incident card may show?
17. What Mini Kiosk Health card may show?
18. What Billing Dispute card may show?
19. What Renewal Risk card may show?
20. What Expansion Readiness card may show?
21. What Commercial Risk card may show?
22. What Security Alert card may show?
23. What Evidence Completeness card may show?
24. What Pilot Readiness card may show?
25. What dashboard drilldown rule applies?
26. What drilldown target types exist?
27. What card action boundary applies?
28. What alert acknowledgement rule applies?
29. What alert suppression rule applies?
30. What alert grouping rule applies?
31. What KPI trend rule applies?
32. What KPI threshold rule applies?
33. What KPI data quality rule applies?
34. What sensitive KPI rule applies?
35. What KPI export rule applies?
36. What empty state rule applies?
37. What error state rule applies?
38. What stale state rule applies?
39. What dashboard card dependency rule applies?
40. What anti-patterns are prohibited?

If these questions cannot be answered, SaaS Admin dashboard card, KPI widget, alert, and drilldown planning is incomplete.

---

## 48. Conclusion

Admin dashboards must focus attention without becoming unsafe control panels.

The safe dashboard design flow is:

    surface context
        -> dashboard card
        -> KPI or alert signal
        -> data freshness and confidence
        -> masking and role scope
        -> drilldown target
        -> evidence link
        -> workflow request
        -> audited review if sensitive

This document ensures that future Admin Console cards, KPIs, alerts, and drilldowns remain evidence-linked, role-scoped, context-aware, and separated from runtime or commercial mutation authority.