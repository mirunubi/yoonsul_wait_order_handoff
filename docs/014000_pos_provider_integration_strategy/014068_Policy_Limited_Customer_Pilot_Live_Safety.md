# 014068_Policy_Limited_Customer_Pilot_Live_Safety

## 1. Purpose

This document defines the limited customer pilot, customer-facing scope restriction, live safety boundary, customer communication rule, pilot pause condition, staff supervision rule, payment uncertainty handling, KDS handoff safety, support escalation, and evidence capture policy for the Yoonsul Wait/Order Handoff documentation project.

The previous document defined staff-only dry run, store role rehearsal, and operational fallback training policy.

This document defines the controlled transition from staff-only rehearsal to limited customer pilot exposure.

This document does not start a real customer pilot, create customer scripts, implement UI, connect payment systems, connect KDS, or approve production release.

It defines limited customer pilot scope and live safety policy only.

---

## 2. Scope

This document covers:

- limited customer pilot purpose
- pilot scope restriction
- customer eligibility
- pilot time window
- staff supervision
- customer communication
- payment uncertainty handling
- Mini Kiosk live safety
- KDS live safety
- support escalation
- manual fallback
- pilot pause
- customer recovery
- evidence capture
- no-production boundary

This document does not cover:

- final pilot launch date
- final store contract
- final customer consent wording
- final payment provider certification
- final KDS hardware setup
- final marketing campaign
- final production rollout
- final customer success automation
- final Franchise OS launch

---

## 3. Core Principle

A limited customer pilot is controlled exposure, not public launch.

The project must follow this rule:

> Real customers may be introduced only within restricted scope, supervised operation, clear customer communication, active evidence capture, and immediate pause capability.

The pilot must protect customers, staff, kitchen, payment truth, and store trust.

---

## 4. Limited Customer Pilot Definition

A limited customer pilot means:

- real customer interaction may occur
- scope is intentionally narrow
- staff supervision is active
- customer-facing promises are limited
- failure path is prepared
- manual fallback exists
- support escalation exists
- evidence capture is mandatory
- pause/exit condition is clear

A limited customer pilot is not:

- full launch
- production release
- franchise launch
- marketing campaign
- unsupervised operation
- permanent feature release
- proof that all edge cases are solved

---

## 5. Entry Preconditions

Limited customer pilot may begin only after:

1. internal simulation is complete
2. staff-only dry run is complete
3. critical staff blockers are resolved
4. payment uncertainty rehearsal passed
5. KDS duplicate rehearsal passed
6. support escalation rehearsal passed
7. manual fallback rehearsal passed
8. required pilot tests passed or waived
9. evidence packet template is ready
10. pilot scope restriction is recorded
11. pause condition is agreed
12. store manager or pilot owner approves entry

No real customer exposure without these preconditions.

---

## 6. Pilot Scope Restriction Dimensions

Pilot scope may be restricted by:

| Dimension | Restriction Example |
| --------- | ------------------- |
| Store | one store only |
| Time | limited hours |
| Customer Type | invited or staff-known customers only |
| Order Type | limited menu only |
| Payment Type | controlled payment method only |
| KDS Mode | monitored KDS handoff only |
| Mini Kiosk | supervised use only |
| Support | live support standby |
| Provider | one provider path only |
| Volume | limited order count |
| Fallback | manual fallback ready |
| Export | disabled or restricted |

Scope should be as small as needed to protect safety.

---

## 7. Recommended Initial Pilot Scope

Recommended first customer pilot scope:

- one store or simulated store zone
- limited time window
- low-volume period
- staff-supervised customers
- limited menu set
- no complex discounts
- no group orders
- no split payment unless explicitly tested
- no high-risk provider path
- no unsupervised Mini Kiosk use
- KDS monitored by staff
- support standby
- manual fallback ready

The first pilot should be boring and safe.

---

## 8. Customer Eligibility

Initial pilot customers may include:

- internal staff acting as customer
- family/friends with awareness
- invited friendly customers
- low-risk repeat customers
- customers willing to wait briefly if needed

Avoid initial pilot with:

- peak-hour rush customers
- impatient queue customers
- large group orders
- delivery app orders
- complex refund/cancel cases
- VIP/complaint-sensitive customers
- customers with accessibility needs not yet supported
- customers requiring multilingual edge cases not rehearsed

Customer selection protects both customer and project.

---

## 9. Pilot Time Window

Recommended pilot time window:

- non-peak hours
- short duration
- staff availability confirmed
- support availability confirmed
- store manager present
- kitchen not overloaded
- provider status normal
- rollback path ready

Avoid:

- lunch peak
- dinner rush
- new staff shift
- provider maintenance window
- unstable network period
- after major system change
- immediately after unresolved blocker

Time window matters.

---

## 10. Volume Limit

Pilot volume limit should be defined.

Examples:

- first 5 customer sessions
- first 10 order intents
- first 3 paid orders
- 1-hour limited run
- Mini Kiosk supervised use only
- KDS handoff monitored for each ticket

Volume limit prevents hidden scaling risk.

Do not increase volume before evidence review.

---

## 11. Customer Communication Principle

Customer communication must be:

- truthful
- calm
- short
- non-technical
- uncertainty-aware
- not overpromising
- not blaming external provider
- not exposing internal architecture
- not implying production maturity

Customers should not be burdened with system complexity.

But they must not be misled.

---

## 12. Pilot Customer Notice Boundary

For limited pilot, customer notice may be light but honest.

Possible message:

    현재 주문 흐름을 더 빠르고 정확하게 만들기 위해 제한적으로 테스트 운영 중입니다.
    직원이 옆에서 도와드리며, 문제가 생기면 바로 일반 주문 방식으로 처리해드리겠습니다.

Do not say:

    완성된 시스템입니다.
    오류가 없습니다.
    결제는 무조건 바로 됩니다.
    주문은 자동으로 주방에 들어갑니다.

Pilot wording must preserve trust.

---

## 13. Payment Uncertainty Communication

If payment is uncertain, staff should say:

    결제 확인이 잠시 지연되고 있습니다.
    중복 결제나 잘못된 주문이 생기지 않도록 확인 후 안내드리겠습니다.

Staff should not say:

    결제됐습니다.

unless payment is confirmed.

Staff should not send order to KDS if payment/order readiness is unsafe.

Payment uncertainty must be visible to staff and calmly explained to customer.

---

## 14. Order Intent Communication

If order intent is captured but not accepted:

    주문 내용은 확인되었습니다.
    결제와 접수 상태를 확인한 뒤 주방으로 전달됩니다.

Do not say:

    주문이 들어갔습니다.

unless accepted order condition is met.

Order intent is not accepted order.

---

## 15. KDS Handoff Communication

If KDS handoff is pending:

    주방 전달 상태를 확인 중입니다.
    중복 주문이 생기지 않도록 직원이 확인하고 있습니다.

If KDS ticket is accepted:

    주문이 주방에 정상 전달되었습니다.

Staff should not imply kitchen start until KDS state supports it.

---

## 16. Mini Kiosk Customer Safety Rule

Mini Kiosk during limited pilot should:

- be supervised
- show clear session state
- show payment uncertainty honestly
- avoid unsupported options
- avoid hidden provider failure
- avoid direct final authority wording
- allow staff help
- provide safe timeout message
- provide fallback path

Mini Kiosk must not create ghost order or false payment success.

---

## 17. KDS Live Safety Rule

During limited pilot:

- each KDS ticket should be monitored
- duplicate ticket risk should be checked
- held tickets must not be prepared
- uncertain payment should block or hold kitchen handoff
- cancellation after kitchen start should trigger review
- degraded kitchen note must be marked
- manual kitchen fallback must be evidenced

Kitchen trust is operational trust.

---

## 18. Payment Live Safety Rule

During limited pilot:

- payment approval must be verified
- uncertain payment must be visible
- duplicate payment suspicion must pause flow
- invalid provider callback must not approve payment
- refund/cancel must not be improvised
- customer should not be charged twice
- payment evidence must be captured

Payment failure can destroy customer trust quickly.

---

## 19. Support Live Safety Rule

During limited pilot:

- support standby should be available
- support access must be case-scoped
- support view must be masked
- support session must be time-bound
- break-glass must require reason
- support cannot silently mutate payment/order/KDS truth
- support action must produce evidence

Support is recovery guardrail, not hidden admin shortcut.

---

## 20. Manual Fallback Live Rule

Manual fallback may be used when:

- Mini Kiosk fails
- payment uncertainty persists
- provider path is unavailable
- KDS handoff is unsafe
- support recommends fallback
- staff cannot determine safe state
- customer waiting risk increases

Manual fallback must include:

- reason
- staff/manager awareness
- fallback-originated marker
- customer communication
- later reconciliation
- evidence capture

Fallback must not bypass security.

---

## 21. Pilot Pause Conditions

Pilot must pause if:

- duplicate payment occurs or is strongly suspected
- payment uncertainty is hidden
- duplicate KDS ticket occurs or is strongly suspected
- KDS prepares unsafe ticket
- provider replay is accepted
- invalid provider event is accepted
- support masking fails
- tenant/store leakage occurs
- raw CI/DI exposure occurs
- device revocation fails
- rollback path fails
- staff cannot explain current state
- customer trust risk becomes high
- store manager requests pause

Pause protects the pilot.

---

## 22. Pilot Pause Procedure

When pilot pauses:

1. stop accepting new pilot sessions
2. preserve current state
3. complete or safely cancel active customer flows
4. switch to manual or normal ordering
5. notify staff
6. notify support if needed
7. capture incident evidence
8. classify blocker
9. decide fix, waiver, or exit
10. record pause decision

Pause must be orderly.

---

## 23. Pilot Resume Conditions

Pilot may resume only when:

- blocker is identified
- correction or waiver is recorded
- retest is passed where required
- staff is briefed
- support is ready
- rollback path is confirmed
- affected scope is restricted if needed
- pilot entry decision is updated

Do not resume based only on confidence.

Resume must be evidence-based.

---

## 24. Customer Recovery Rule

If customer is affected:

- apologize plainly
- avoid technical excuse
- avoid blaming provider
- resolve order/payment safely
- prevent duplicate charge
- offer reasonable recovery if needed
- record evidence
- escalate if payment or refund issue exists

Customer recovery should be humane and controlled.

---

## 25. Customer Recovery Message Examples

Possible messages:

    불편을 드려 죄송합니다.
    중복 주문이나 결제 문제가 생기지 않도록 직원이 직접 확인해드리겠습니다.

    현재 시스템 확인이 필요해 일반 주문 방식으로 바로 도와드리겠습니다.

    결제 상태를 확인한 후 필요한 조치를 안내드리겠습니다.

Do not say:

    외부 업체 문제입니다.
    저희는 모릅니다.
    시스템상 어쩔 수 없습니다.
    아마 결제됐을 겁니다.

Customer trust comes first.

---

## 26. Live Pilot Evidence Packet

Each limited pilot run should produce evidence packet.

Minimum fields:

- pilot run id
- date/time
- store
- scope restriction
- staff on duty
- support standby
- customer session count
- order intent count
- payment success count
- payment uncertainty count
- KDS handoff count
- KDS issue count
- support case count
- fallback count
- pause event count
- customer recovery count
- blocker list
- waiver list
- decision
- notes

Evidence converts pilot experience into learning.

---

## 27. Pilot Run ID Format

Recommended format:

    PILOT-RUN-[YYYYMMDD]-[STORE]-[NUMBER]

Example:

    PILOT-RUN-20260612-STORE001-001

Final format may be normalized later.

---

## 28. Pilot Incident Record Fields

Pilot incident should record:

- incident id
- pilot run id
- time
- customer impact
- affected runtime
- affected data flow
- affected provider
- affected UI
- affected staff role
- state before
- state after
- action taken
- support case id
- evidence packet
- blocker category
- severity
- recovery action
- next action

Incident record must be useful for correction.

---

## 29. Pilot Incident Severity

Recommended severity values:

- `PILOT_INCIDENT_CRITICAL`
- `PILOT_INCIDENT_HIGH`
- `PILOT_INCIDENT_MEDIUM`
- `PILOT_INCIDENT_LOW`
- `PILOT_OBSERVATION`

Critical examples:

- duplicate charge
- false payment success
- duplicate kitchen ticket
- customer data exposure
- support masking failure
- tenant/store data leakage
- rollback failure

Critical incident should pause pilot.

---

## 30. Pilot Customer Feedback Boundary

Customer feedback may be collected, but should not become uncontrolled feature request.

Feedback categories:

- flow confusion
- wording confusion
- speed
- payment trust
- order confidence
- staff help quality
- kiosk usability
- perceived reliability
- recovery experience
- general comment

Do not implement new features directly from pilot feedback without backlog extraction.

---

## 31. Staff Feedback Boundary

Staff feedback should be collected for:

- unclear state labels
- unclear button
- unclear customer script
- KDS confusion
- payment uncertainty confusion
- fallback burden
- support delay
- evidence capture burden
- stop/pause clarity
- training gap

Staff feedback may become blocker, UI improvement, SOP change, or backlog item.

---

## 32. Pilot Metrics

Recommended pilot metrics:

- sessions started
- order intents captured
- orders accepted
- payment approvals
- payment uncertainties
- payment failures
- KDS tickets created
- KDS tickets held
- KDS duplicate suspicions
- support cases
- fallback uses
- customer recovery cases
- pilot pause events
- average staff intervention count
- customer confusion count
- staff confusion count

Pilot metrics should measure safety, not only speed.

---

## 33. Pilot Success Criteria

Limited customer pilot may be considered successful when:

- no critical incident occurs
- payment uncertainty is visible
- no duplicate charge occurs
- no duplicate KDS ticket is prepared
- support masking is maintained
- staff can explain states
- fallback works when needed
- customer recovery is handled well
- evidence packets are complete
- blockers are converted to action items
- next scope increase decision is evidence-based

Success means controlled learning.

---

## 34. Pilot Failure Criteria

Pilot should be considered failed or paused when:

- critical incident occurs
- staff cannot control flow
- payment uncertainty is hidden
- customer is misled
- duplicate KDS preparation occurs
- support scope fails
- tenant/store data leaks
- evidence is missing
- rollback does not work
- repeated soft blockers create operational burden
- customer trust deteriorates

Failure is useful if recorded early.

---

## 35. Scope Increase Rule

Pilot scope may increase only after:

- current scope evidence reviewed
- blockers resolved or accepted
- staff readiness confirmed
- support readiness confirmed
- rollback confirmed
- customer feedback reviewed
- payment/KDS/provider metrics stable
- updated scope decision recorded

Scope increase examples:

- more customers
- longer time window
- more menu items
- less staff supervision
- more provider path
- more KDS automation
- more payment methods

Scope increase must be gradual.

---

## 36. Scope Increase Decision Values

Recommended values:

- `KEEP_SCOPE`
- `REDUCE_SCOPE`
- `PAUSE_SCOPE`
- `INCREASE_VOLUME_ONLY`
- `INCREASE_TIME_WINDOW`
- `ADD_MENU_SCOPE`
- `ADD_PAYMENT_SCOPE`
- `ADD_KDS_SCOPE`
- `ADD_PROVIDER_SCOPE`
- `EXIT_PILOT`

Decision must be evidence-driven.

---

## 37. No Production Claim Rule

During limited pilot, do not claim:

- fully launched
- production stable
- franchise ready
- provider complete
- payment certified unless true
- KDS fully automated
- customer service fully automated
- SaaS product mature
- no error possible

Pilot wording must remain modest.

---

## 38. Pilot Register Recommendation

Recommended future files:

    docs/_index/
      Limited_Customer_Pilot_Register.md
      Pilot_Run_Evidence_Register.md
      Pilot_Incident_Register.md
      Pilot_Customer_Feedback_Register.md
      Pilot_Staff_Feedback_Register.md
      Pilot_Scope_Decision_Register.md

This document only recommends these files.

It does not create them.

---

## 39. Anti-Patterns

The following are prohibited:

- treating limited pilot as full launch
- running pilot during peak hour first
- running pilot without staff supervision
- allowing unsupervised Mini Kiosk use too early
- hiding payment uncertainty from customer
- sending unsafe order to KDS
- preparing duplicate KDS ticket
- continuing pilot after critical incident
- blaming provider to customer
- collecting feedback without evidence
- increasing scope without review
- implementing customer suggestions directly without backlog
- claiming production readiness from a small pilot

---

## 40. Non-Goals

This document does not define:

- final customer consent form
- final marketing wording
- final real payment certification
- final production launch
- final franchise pilot
- final SLA
- final customer support contract
- final store operating manual

Those belong to later pilot execution and commercial rollout planning.

---

## 41. Readiness Check

This document is ready when the project can answer:

1. What is limited customer pilot?
2. What entry preconditions apply?
3. What scope restriction dimensions exist?
4. What initial pilot scope is recommended?
5. Which customers are eligible?
6. What pilot time window is recommended?
7. What volume limit applies?
8. What customer communication principle applies?
9. How should pilot notice be worded?
10. How is payment uncertainty communicated?
11. How is order intent communicated?
12. How is KDS handoff communicated?
13. What Mini Kiosk live safety rule applies?
14. What KDS live safety rule applies?
15. What payment live safety rule applies?
16. What support live safety rule applies?
17. What manual fallback live rule applies?
18. When must pilot pause?
19. How does pilot pause work?
20. When may pilot resume?
21. How is customer recovery handled?
22. What evidence packet is required?
23. What pilot incident fields are required?
24. How is customer feedback bounded?
25. How is staff feedback bounded?
26. What pilot metrics matter?
27. What success criteria apply?
28. What failure criteria apply?
29. How can scope increase?
30. What anti-patterns are prohibited?

If these questions cannot be answered, limited customer pilot scope restriction and live safety planning is incomplete.

---

## 42. Conclusion

Limited customer pilot is the first controlled exposure to real customer behavior.

The safe progression is:

    staff-only dry run
        -> limited customer scope
        -> supervised live use
        -> honest customer communication
        -> payment/KDS/support safety
        -> fallback readiness
        -> evidence capture
        -> incident review
        -> scope decision

The pilot must learn from real operation without pretending to be full production.

This document protects customer trust, store operations, payment truth, KDS safety, support boundary, and project credibility during the first live customer exposure.