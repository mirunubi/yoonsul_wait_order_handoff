# 014052_Policy_Phase_1_MVP_Build_Authorization_Scope

## 1. Purpose

This document defines the Phase 1 MVP build authorization, runtime scope, implementation entry boundary, no-scope-creep rule, approved build surface, deferred scope, and controlled execution policy for the Yoonsul Wait/Order Handoff documentation project.

The previous document defined implementation backlog extraction and phase cutline control.

This document defines the authorization boundary for Phase 1 MVP implementation.

This document does not authorize actual SQL, Flutter, provider API, payment integration, KDS runtime, Mini Kiosk, deployment, or production build.

It defines what Phase 1 may include when implementation is later approved.

---

## 2. Scope

This document covers:

- Phase 1 MVP scope
- build authorization gate
- runtime inclusion rule
- runtime exclusion rule
- provider scope boundary
- payment scope boundary
- KDS scope boundary
- Mini Kiosk scope boundary
- support scope boundary
- security minimum scope
- UI minimum scope
- pilot readiness scope
- deferred scope
- no-scope-creep policy

This document does not cover:

- final implementation schedule
- final sprint plan
- final database schema
- final API design
- final Flutter implementation
- final provider contract
- final payment certification
- final KDS hardware selection
- final production deployment
- final Franchise OS implementation

---

## 3. Core Principle

Phase 1 must prove the core runtime safely, not build the full company vision.

The project must follow this rule:

> Phase 1 MVP may include only the minimum runtime, security, provider, payment, KDS, Mini Kiosk, support, evidence, and pilot-readiness features required to prove controlled wait/order handoff operation.

Anything not required for safe proof must be deferred.

---

## 4. Phase 1 Goal

Phase 1 goal is to prove:

- customer order intent can be captured
- POS/provider boundary can be controlled
- payment status can be safely interpreted
- KDS handoff can be safely created or withheld
- duplicate order and duplicate payment can be prevented
- uncertain states can be surfaced
- support recovery can be case-scoped
- audit/evidence can be produced
- provider failure can be survived
- pilot store operation can be reviewed

Phase 1 is not a full Franchise OS.

---

## 5. Phase 1 Approved Runtime Families

Phase 1 may include the following runtime families:

| Runtime Family | Phase 1 Role |
| -------------- | ------------ |
| Customer Session Runtime | lightweight session continuity |
| Mini Kiosk Runtime | order intent and customer-facing entry |
| POS / Provider Boundary Runtime | provider event validation and mapping |
| Payment Runtime | payment certainty, uncertainty, refund/cancel boundary |
| KDS Handoff Runtime | safe kitchen ticket candidate creation |
| KDS Bridge Runtime | controlled handoff, not ownership |
| Support Runtime | scoped recovery and evidence review |
| Audit Runtime | append-only event and evidence recording |
| Security Runtime | tenant, device, secret, masking, access boundary |
| Pilot Evidence Runtime | operational evidence packet collection |

These are allowed only within MVP boundaries.

---

## 6. Phase 1 Explicit Non-Goals

Phase 1 does not include:

- full Franchise OS
- full multi-store HQ optimization
- broad provider ecosystem
- 30-POS compatibility
- hardware partner program
- full billing automation
- advanced AI automation
- advanced benchmark export
- complex CRM automation
- advanced inventory optimization
- full staff HR system
- full WMS/SCM integration
- full analytics suite
- full white-label app platform
- large custom pilot development
- permanent provider marketplace

These may be documented but not implemented in Phase 1.

---

## 7. Build Authorization Gate

Implementation may begin only when:

1. source documents are reviewed
2. implementation backlog items are extracted
3. Phase 1 items are approved
4. runtime owners are assigned
5. acceptance criteria exist
6. test linkage exists
7. evidence linkage exists
8. security baseline is mapped
9. provider dependency is verified or bounded
10. rollback/disable path exists
11. deferred scope is recorded
12. no unresolved contradiction blocks implementation

No item enters implementation because it is merely interesting.

---

## 8. Phase 1 Runtime Inclusion Criteria

A runtime feature may enter Phase 1 when it is required to:

- prevent unsafe order state
- prevent unsafe payment state
- prevent duplicate KDS ticket
- prevent provider ambiguity
- prevent support overreach
- preserve audit evidence
- protect tenant/store boundary
- support pilot operation
- support safe rollback
- support minimal customer journey
- support minimal store operation
- support minimal provider integration

If a feature does not protect or prove the MVP, defer it.

---

## 9. Phase 1 Runtime Exclusion Criteria

A runtime feature should be excluded from Phase 1 when:

- it is primarily commercial expansion
- it is advanced analytics
- it is provider ecosystem expansion
- it is Franchise OS enhancement
- it is UI polish only
- it is custom for one pilot store
- it requires unverified provider access
- it introduces new payment risk
- it increases support burden without MVP proof
- it has no test linkage
- it has no evidence output
- it lacks runtime owner

Exclusion protects delivery.

---

## 10. Customer Session Scope

Phase 1 customer session scope may include:

- session creation
- session continuation
- lightweight customer context
- waiting/order handoff continuity
- Mini Kiosk session context
- timeout handling
- abandoned session handling
- audit event for session transition
- no raw sensitive identity exposure

Phase 1 does not require:

- full loyalty system
- full coupon system
- full membership ranking
- full wallet
- full recurring order subscription
- full customer CRM

Customer session must remain minimal.

---

## 11. Mini Kiosk Scope

Phase 1 Mini Kiosk scope may include:

- customer entry
- menu display candidate
- order intent capture
- table/waiting context capture where needed
- payment handoff boundary
- session timeout
- error display
- provider unavailable state
- support handoff display
- no direct provider daemon trust
- no hidden payment truth ownership

Mini Kiosk must not become uncontrolled POS.

---

## 12. POS / Provider Boundary Scope

Phase 1 provider boundary may include:

- Toss primary base investigation and integration boundary
- OKPOS compatibility boundary
- PAYCO secondary channel boundary where needed
- provider event intake
- provider validation
- idempotency
- replay protection
- merchant/store mapping
- provider failure state
- provider disable/rollback
- canonical event candidate mapping
- evidence capture

Phase 1 must not attempt broad provider compatibility.

---

## 13. Toss Scope

Phase 1 Toss scope may include:

- primary base provider path
- API/webhook verification
- idempotency and replay handling
- provider signature validation
- rate limit awareness
- merchant/store mapping
- failure/timeout handling
- provider evidence capture
- safe disable path

Toss does not own Yoonsul runtime truth.

Toss signal becomes usable only after validation.

---

## 14. OKPOS Scope

Phase 1 OKPOS scope may include:

- compatibility assessment
- OKDC/local daemon boundary understanding
- partner/dealer evidence collection
- local daemon failure handling policy
- duplicate event risk control
- POS ledger coexistence assessment
- Mini Kiosk indirect handoff boundary

OKPOS compatibility is required strategically.

But Phase 1 should not become full OKPOS implementation unless officially verified and authorized.

---

## 15. PAYCO Scope

Phase 1 PAYCO scope may include:

- secondary payment or smart-order channel assessment
- callback/payment state boundary
- refund/cancel boundary
- provider evidence collection
- channel-specific risk review

PAYCO should not displace Toss/OKPOS Phase 1 cutline unless strategy changes.

---

## 16. Payment Scope

Phase 1 payment scope may include:

- payment approval certainty
- payment uncertainty state
- duplicate payment prevention
- refund/cancel boundary
- reconciliation candidate tracking
- provider callback validation
- payment evidence
- support-visible payment status
- rollback/disable handling

Phase 1 payment scope must not include:

- advanced settlement automation
- complex accounting integration
- multi-provider optimization
- payment margin experimentation in runtime
- hidden payment fee manipulation
- unsupported refund automation

Payment truth must remain protected.

---

## 17. KDS Scope

Phase 1 KDS scope may include:

- KDS ticket candidate creation
- duplicate ticket prevention
- ticket withheld when payment/order state uncertain
- retry/remake policy boundary
- cancellation impact visibility
- kitchen delay visibility
- POS/KDS handoff boundary
- KDS evidence capture
- degraded kitchen note path

KDS owns kitchen execution truth.

Bridge or Agent must not override KDS truth.

---

## 18. KDS Bridge Scope

Phase 1 KDS Bridge scope may include:

- provider/POS-to-KDS handoff boundary
- canonical event routing
- idempotency
- retry
- failure state
- degraded routing
- stale event detection
- evidence packet
- no silent mutation

KDS Bridge validates and routes.

It does not own transaction truth or kitchen execution truth.

---

## 19. Support Runtime Scope

Phase 1 support scope may include:

- case-scoped access
- masked data view
- scoped session
- break-glass boundary
- support note
- incident evidence packet
- payment uncertainty review
- provider failure review
- KDS handoff issue review
- export restriction

Support must not silently mutate runtime truth.

Support action must produce evidence.

---

## 20. Audit Runtime Scope

Phase 1 audit scope may include:

- append-only event recording
- state transition evidence
- provider event evidence
- payment evidence
- support session evidence
- export request evidence
- Mini Kiosk session evidence
- KDS ticket evidence
- security incident evidence

Audit is not optional.

Evidence must support recovery and pilot review.

---

## 21. Security Minimum Scope

Phase 1 security minimum includes:

- tenant/store isolation
- role-based access control
- device trust boundary
- session revocation
- secret handling
- webhook signature validation
- idempotency and replay protection
- support masking
- export restriction
- CI/DI leakage prevention
- audit immutability
- release gate
- environment separation

Security is not a later decoration.

---

## 22. UI Minimum Scope

Phase 1 UI may include only required runtime visibility and safe actions.

Allowed UI purposes:

- customer order intent
- payment status display
- payment uncertainty display
- provider failure display
- KDS status display
- support case review
- owner/store pilot evidence view
- device/session error display
- minimal admin configuration

Not allowed by default:

- advanced dashboard polish
- broad analytics
- franchise HQ comparison
- deep CRM
- complex promotion engine
- full reporting suite
- AI automation UI

UI must reflect runtime truth.

---

## 23. Pilot Readiness Scope

Phase 1 pilot readiness may include:

- pilot store register
- pilot scope record
- provider stack record
- order/payment/KDS evidence packet
- incident retrospective
- blocker conversion
- support tier record
- pilot-to-paid conversion evidence
- pricing package boundary
- cancellation/downgrade note

Pilot readiness is evidence-oriented.

It should not become broad commercial automation.

---

## 24. SaaS Scope

Phase 1 SaaS scope may include:

- package boundary documentation
- fee transparency
- pilot quote clarity
- support tier clarity
- renewal/downgrade/exit policy
- early customer success signal
- churn reason taxonomy
- pricing experiment record

Phase 1 SaaS implementation should be minimal.

Full SaaS billing automation may be deferred.

---

## 25. Franchise OS Scope

Phase 1 Franchise OS scope may include:

- future linkage boundary
- HQ/store data ownership notes
- franchise billing responsibility policy
- evidence signals from pilot
- no premature implementation

Franchise OS should not be built in Phase 1.

It should remain future-compatible.

---

## 26. AI / Agent Scope

Phase 1 AI or Agent scope should be extremely limited.

Allowed:

- recommendation boundary documentation
- anomaly detection candidate notes
- evidence review support concept
- no execution authority

Not allowed:

- AI auto-refund
- AI payment decision
- AI KDS mutation
- AI provider correction
- AI support approval
- AI hidden customer scoring
- AI autonomous store operation

Agent recommends or observes.

It does not execute authority.

---

## 27. Local Agent / Degraded Scope

Phase 1 degraded operation may include:

- failure state display
- provisional local note
- manual evidence packet
- sync conflict marking
- central verification requirement
- no silent merge
- no local overwrite of central truth

Local continuity is provisional until verified.

Degraded mode is not security bypass.

---

## 28. Export / Report Scope

Phase 1 export/report scope may include:

- restricted operational report
- evidence packet export control
- approval requirement
- masking rule
- no raw CI/DI
- no unrestricted benchmark
- audit event for export

Export authority is separate from view authority.

---

## 29. Provider Expansion Deferral

Phase 1 should defer:

- Smartro full integration
- KICC full integration
- NICE full integration
- I'M U full integration
- Hyphen hub integration
- minor POS ecosystem
- dealer network integration
- hardware partner certification

These can remain Phase 2 or Phase 3 candidates.

---

## 30. Hardware Partner Deferral

Phase 1 should defer:

- hardware partner program
- certified device bundle
- dealer margin model
- kiosk hardware resale program
- complex lease model
- large hardware procurement automation

Hardware should support pilot only.

It should not become primary business model in Phase 1.

---

## 31. Custom Pilot Request Rule

Custom pilot requests should be controlled.

A pilot request may enter Phase 1 only if:

- it supports core proof
- it does not distort architecture
- it does not create one-off provider dependency
- it does not bypass security
- it has test and evidence linkage
- it can be reused or safely discarded

Otherwise, record as deferred.

---

## 32. Scope Creep Detection

Scope creep is detected when:

- Phase 2 provider enters Phase 1 without gate
- UI polish displaces runtime safety
- Franchise OS feature enters store MVP
- analytics expands before evidence base
- custom pilot request becomes core
- support workflow mutates runtime truth
- provider-specific workaround breaks provider-neutral architecture
- payment margin affects runtime truth
- hardware bundle becomes required before software proof

Scope creep must be stopped early.

---

## 33. Scope Change Request

Any Phase 1 scope change should record:

- request id
- requested feature
- source document
- reason
- affected runtime
- affected data flow
- affected provider
- affected UI
- affected test
- security impact
- pilot impact
- phase impact
- decision
- deferred/rejected reason

No silent Phase 1 expansion.

---

## 34. Scope Change Status Values

Recommended values:

- `REQUESTED`
- `UNDER_REVIEW`
- `APPROVED_FOR_PHASE_1`
- `APPROVED_FOR_PHASE_2`
- `APPROVED_FOR_PHASE_3`
- `DEFERRED`
- `REJECTED`
- `SUPERSEDED`
- `NEEDS_PROVIDER_EVIDENCE`
- `NEEDS_SECURITY_REVIEW`
- `NEEDS_TEST_MAPPING`

Scope change status must be visible.

---

## 35. Phase 1 Done Criteria

Phase 1 MVP may be considered done only when:

1. core order handoff works within defined boundary
2. payment uncertainty is handled
3. duplicate prevention is tested
4. KDS handoff boundary is tested
5. provider failure path is tested
6. support recovery is masked and scoped
7. audit/evidence is produced
8. tenant/store isolation is enforced
9. rollback/disable path exists
10. pilot evidence packet can be produced
11. no Phase 2/3 feature is required for MVP survival

Done means controlled and testable, not feature-complete.

---

## 36. Phase 1 Not Done Indicators

Phase 1 is not done if:

- payment state can be ambiguous without display
- duplicate KDS ticket can occur silently
- provider callback can be replayed
- support can view unmasked sensitive data without scope
- export can occur without approval
- Mini Kiosk can submit unsafe order state
- POS/provider mismatch has no recovery
- audit event is missing
- rollback requires manual database mutation
- tenant/store boundary is unclear
- pilot evidence cannot be collected

These are blockers.

---

## 37. Implementation Start Checklist

Before actual build starts:

1. Phase 1 backlog exists
2. out-of-scope register exists
3. deferred register exists
4. provider assumptions are recorded
5. runtime owners are assigned
6. security minimum is mapped
7. tests are mapped
8. evidence outputs are mapped
9. UI minimum is mapped
10. rollback path is mapped
11. pilot scope is mapped
12. build authorization is explicitly recorded

Without checklist, implementation should not start.

---

## 38. Anti-Patterns

The following are prohibited:

- building full vision in Phase 1
- adding provider integrations because they are interesting
- building UI before runtime truth is clear
- building Franchise OS during store MVP
- treating AI recommendation as execution authority
- treating provider signal as Yoonsul truth without validation
- treating support access as admin mutation
- treating export view as export authority
- treating pilot custom request as core requirement
- letting payment margin influence payment runtime
- skipping audit/evidence because MVP is small
- skipping rollback because implementation is early
- calling Phase 1 done without failure tests

---

## 39. Non-Goals

This document does not define:

- final code architecture
- final database tables
- final API routes
- final Flutter screens
- final provider SDK usage
- final KDS hardware
- final payment contract
- final deployment process
- final sprint calendar

Those belong to later authorized implementation planning.

---

## 40. Readiness Check

This document is ready when the project can answer:

1. What is Phase 1 goal?
2. What runtime families may enter Phase 1?
3. What are Phase 1 non-goals?
4. What is the build authorization gate?
5. What are inclusion criteria?
6. What are exclusion criteria?
7. What is customer session scope?
8. What is Mini Kiosk scope?
9. What is provider boundary scope?
10. What is Toss scope?
11. What is OKPOS scope?
12. What is PAYCO scope?
13. What is payment scope?
14. What is KDS scope?
15. What is KDS Bridge scope?
16. What is support scope?
17. What is audit scope?
18. What is security minimum scope?
19. What is UI minimum scope?
20. What is pilot readiness scope?
21. What is SaaS scope?
22. What is Franchise OS scope?
23. What is AI/Agent scope?
24. What is degraded/local scope?
25. What provider expansion is deferred?
26. How is custom pilot request handled?
27. How is scope creep detected?
28. What is Phase 1 done criteria?
29. What indicates Phase 1 is not done?
30. What implementation start checklist applies?

If these questions cannot be answered, Phase 1 MVP build authorization and no-scope-creep control is incomplete.

---

## 41. Conclusion

Phase 1 MVP must prove the safe runtime spine.

The safe Phase 1 boundary is:

    minimal customer session
    minimal Mini Kiosk intent
    provider boundary validation
    payment certainty and uncertainty handling
    KDS handoff safety
    support recovery
    audit evidence
    security minimum
    pilot evidence

Phase 1 must not become:

    full Franchise OS
    broad provider ecosystem
    advanced AI automation
    full SaaS billing
    hardware partner program
    deep analytics suite
    custom pilot feature factory

This document protects the first build from scope creep and keeps the project aligned with controlled runtime proof, evidence, security, and pilot readiness.