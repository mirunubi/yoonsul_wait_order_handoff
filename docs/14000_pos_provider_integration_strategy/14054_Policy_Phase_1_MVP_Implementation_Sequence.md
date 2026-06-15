# 14054_Policy_Phase_1_MVP_Implementation_Sequence

## 1. Purpose

This document defines the Phase 1 MVP implementation sequence, dependency order, build layering, runtime dependency control, test-first entry order, and no-skip build policy for the Yoonsul Wait/Order Handoff documentation project.

The previous document defined Phase 1 MVP build authorization, runtime scope, and no-scope-creep control.

This document defines the recommended order in which Phase 1 implementation should later proceed after build authorization is explicitly granted.

This document does not implement SQL, Flutter, provider adapters, payment integration, KDS integration, Mini Kiosk screens, deployment, or production configuration.

It defines implementation sequence policy only.

---

## 2. Scope

This document covers:

- Phase 1 build sequence
- runtime dependency order
- security-first dependency
- audit-first dependency
- tenant/store context dependency
- provider boundary dependency
- payment dependency
- KDS dependency
- Mini Kiosk dependency
- support recovery dependency
- UI dependency
- pilot evidence dependency
- no-skip policy

This document does not cover:

- final sprint schedule
- final database schema
- final API contracts
- final Flutter screen implementation
- final provider SDK use
- final KDS hardware configuration
- final payment certification
- final CI/CD pipeline
- final production deployment

---

## 3. Core Principle

Implementation order must follow runtime dependency, not feature excitement.

The project must follow this rule:

> Phase 1 must build foundation, identity, security, audit, runtime state, provider boundary, payment certainty, KDS handoff, support recovery, UI visibility, and pilot evidence in dependency order.

A later layer must not be built on an unsafe earlier layer.

---

## 4. Why Build Order Matters

Wrong build order creates:

- payment state ambiguity
- duplicate KDS tickets
- provider signal confusion
- support overreach
- unmasked data exposure
- audit gaps
- rollback difficulty
- UI displaying false certainty
- pilot evidence gaps
- implementation rework

Correct build order reduces rework.

---

## 5. Recommended Phase 1 Build Layers

Recommended Phase 1 build layers:

| Layer | Name | Purpose |
| ----- | ---- | ------- |
| 0 | Repository And Environment Safety | ensure safe implementation environment |
| 1 | Tenant Store Context Foundation | establish context boundary |
| 2 | Auth Role Device Trust Foundation | establish access boundary |
| 3 | Audit Evidence Foundation | establish append-only traceability |
| 4 | Runtime State Model | establish state vocabulary |
| 5 | Provider Boundary Skeleton | establish external event intake boundary |
| 6 | Payment Certainty Boundary | establish approval/uncertainty/refund safety |
| 7 | Order Intent And Session Boundary | establish customer/Mini Kiosk intent flow |
| 8 | KDS Handoff Boundary | establish kitchen ticket safety |
| 9 | Support Recovery Boundary | establish scoped masked recovery |
| 10 | UI Minimum Visibility | expose state safely |
| 11 | Test And Evidence Packets | verify runtime and failure handling |
| 12 | Pilot Readiness Gate | prepare first controlled pilot |

The sequence may be adjusted, but dependency order must be respected.

---

## 6. Layer 0 Repository And Environment Safety

Layer 0 should confirm:

- repository is clean
- branch policy is understood
- documentation is separated from implementation
- environment files are excluded
- secrets are not committed
- development environment is separated from production
- rollback strategy is documented
- build authorization exists
- implementation backlog exists
- Phase 1 scope is fixed

Do not begin runtime implementation before Layer 0 is clean.

---

## 7. Layer 1 Tenant Store Context Foundation

Layer 1 should define and later implement:

- tenant context
- store context
- legal/company context where needed
- operating group context where needed
- role-to-context mapping
- store boundary
- tenant isolation baseline
- context audit fields

Tenant/store context must exist before provider, payment, KDS, support, or UI state is trusted.

No context, no safe runtime.

---

## 8. Layer 2 Auth Role Device Trust Foundation

Layer 2 should define and later implement:

- user authentication boundary
- role authority
- device trust
- session revocation
- lost device response
- store device access control
- support access separation
- staff/owner/HQ/support role distinction
- reauthentication for sensitive action

User authority and device trust must be separate controls.

Role access must not imply trusted device.

---

## 9. Layer 3 Audit Evidence Foundation

Layer 3 should define and later implement:

- append-only audit event pattern
- event family naming
- actor/context fields
- source runtime
- target runtime
- evidence payload boundary
- masking rule
- tamper-resistance expectation
- incident/evidence packet linkage

Audit must exist before critical state changes.

If the system cannot prove what happened, it is not pilot-ready.

---

## 10. Layer 4 Runtime State Model

Layer 4 should define and later implement state vocabulary for:

- customer session
- order intent
- payment status
- payment uncertainty
- refund/cancel status
- provider event status
- KDS ticket status
- support case status
- device session status
- export/report status
- pilot evidence status

Runtime states must be explicit.

UI must not invent states.

Support must not mutate states outside authority.

---

## 11. Layer 5 Provider Boundary Skeleton

Layer 5 should define and later implement:

- provider adapter interface boundary
- provider event intake
- idempotency key strategy
- replay detection
- signature verification placeholder
- timestamp tolerance policy
- merchant/store mapping
- provider event quarantine
- provider failure state
- canonical event candidate output
- provider disable/rollback path

Provider signal is not Yoonsul truth until validated.

Provider boundary must be built before payment or KDS integration relies on provider events.

---

## 12. Layer 6 Payment Certainty Boundary

Layer 6 should define and later implement:

- payment approved state
- payment pending state
- payment uncertain state
- duplicate payment prevention
- refund/cancel request boundary
- refund/cancel confirmation boundary
- provider callback validation
- reconciliation candidate
- payment evidence packet
- support-visible payment state
- no hidden payment mutation

Payment truth must be protected before order is allowed to proceed into irreversible kitchen execution.

---

## 13. Layer 7 Order Intent And Session Boundary

Layer 7 should define and later implement:

- customer session creation
- waiting/session continuity
- Mini Kiosk session context
- order intent capture
- order intent validation
- table/waiting context linkage
- session timeout
- abandoned order handling
- order intent evidence
- no payment truth ownership by customer UI

Order intent is not the same as accepted order.

Accepted order requires valid runtime conditions.

---

## 14. Layer 8 KDS Handoff Boundary

Layer 8 should define and later implement:

- KDS ticket candidate
- accepted kitchen ticket condition
- payment/order readiness check
- duplicate kitchen ticket prevention
- cancellation impact rule
- retry/remake boundary
- degraded kitchen note path
- KDS evidence packet
- KDS unavailable state
- no bridge ownership of kitchen truth

KDS handoff must occur only when upstream state is sufficiently safe.

KDS owns kitchen execution truth.

---

## 15. Layer 9 Support Recovery Boundary

Layer 9 should define and later implement:

- support case creation
- case-scoped access
- masked data display
- support session start/end
- break-glass request boundary
- support note
- recovery recommendation
- evidence review
- escalation path
- no silent mutation

Support helps recover.

Support does not secretly rewrite truth.

---

## 16. Layer 10 UI Minimum Visibility

Layer 10 should define and later implement minimum UI for:

- customer order intent
- payment pending/approved/uncertain state
- provider unavailable state
- KDS status
- support recovery state
- owner/store pilot evidence view
- device/session error
- safe retry or cancel request where allowed
- no forbidden authority button

UI must be built after runtime state and authority boundary are clear.

UI must show uncertainty honestly.

---

## 17. Layer 11 Test And Evidence Packets

Layer 11 should define and later implement verification for:

- tenant/store boundary test
- role/device trust test
- audit append-only test
- provider idempotency test
- replay test
- payment uncertainty test
- refund/cancel boundary test
- duplicate KDS ticket test
- support masking test
- Mini Kiosk session timeout test
- provider failure test
- pilot evidence packet completeness test

Test coverage must follow critical runtime risk.

---

## 18. Layer 12 Pilot Readiness Gate

Layer 12 should confirm:

- Phase 1 flow can run in controlled environment
- provider assumptions are documented
- payment uncertainty is visible
- duplicate prevention is tested
- KDS handoff is safe
- support recovery is scoped
- audit/evidence is produced
- rollback/disable path exists
- pilot evidence packet can be generated
- unresolved blockers are known

Pilot readiness is not the same as production readiness.

---

## 19. Strict Dependency Rules

Strict dependency rules:

- no provider integration before tenant/store context
- no payment trust before provider validation
- no KDS ticket before payment/order readiness
- no UI action before runtime authority is defined
- no support recovery before masking and scope
- no export before approval and audit
- no pilot before evidence packet
- no production before pilot evidence review

Dependency skips create hidden risk.

---

## 20. Parallel Work Allowed

Some work may proceed in parallel after foundation is stable.

Allowed parallel streams:

| Stream | Can Start After |
| ------ | --------------- |
| UI wireframe | runtime state vocabulary |
| Test catalog refinement | audit and runtime state model |
| Provider evidence gathering | provider boundary skeleton |
| Pilot store planning | Phase 1 scope fixed |
| Support SOP drafting | support boundary defined |
| Pricing/package refinement | SaaS scope boundary fixed |

Parallel drafting is allowed.

Parallel unsafe implementation is not.

---

## 21. Parallel Work Not Allowed

Do not parallelize:

- payment implementation before provider validation
- KDS ticketing before payment/order readiness
- support console before masking
- export before audit and approval
- Mini Kiosk payment flow before payment boundary
- provider expansion before Phase 1 provider base
- Franchise OS implementation before store runtime proof

Unsafe parallel work creates rework and risk.

---

## 22. Build Order By Runtime

Recommended runtime build order:

1. Tenant/Store Context
2. Auth/Role/Device
3. Audit/Event
4. Runtime State
5. Provider Gateway Skeleton
6. Payment Boundary
7. Customer Session/Order Intent
8. KDS Handoff
9. Support Recovery
10. UI Minimum
11. Test/Evidence
12. Pilot Gate

This order should be treated as default.

---

## 23. Build Order By Data Flow

Recommended data flow build order:

1. Context Flow
2. Auth/Device Flow
3. Audit Flow
4. Provider Event Flow
5. Payment Approval Flow
6. Order Intent Flow
7. KDS Ticket Flow
8. Support Recovery Flow
9. Export/Evidence Flow
10. SaaS/Pilot Evidence Flow

Data flow order must support authority order.

---

## 24. Build Order By Risk

Recommended risk-first order:

1. tenant leakage risk
2. secret exposure risk
3. support overreach risk
4. provider replay risk
5. duplicate payment risk
6. payment uncertainty risk
7. duplicate KDS ticket risk
8. order state mismatch risk
9. export/report leakage risk
10. pilot evidence gap risk

High-risk controls must not be postponed too far.

---

## 25. Build Order By User Experience

User experience should be built after runtime truth.

Recommended UX order:

1. show session state
2. show order intent state
3. show payment status honestly
4. show provider unavailable state
5. show KDS handoff status
6. show support recovery option
7. show owner/store evidence summary
8. show billing/package status later

UX must not hide uncertainty.

---

## 26. Provider Build Order

Recommended provider order:

1. provider register
2. provider evidence record
3. provider adapter skeleton
4. Toss base path
5. OKPOS compatibility assessment
6. PAYCO secondary channel assessment
7. provider failure/disable path
8. Phase 2 provider candidates later

Do not build universal adapter before Phase 1 evidence exists.

---

## 27. Payment Build Order

Recommended payment order:

1. payment state model
2. provider validation dependency
3. idempotency/replay protection
4. approved/pending/uncertain states
5. duplicate payment prevention
6. refund/cancel boundary
7. reconciliation candidate
8. support-visible state
9. evidence packet
10. provider-specific extensions later

Payment safety precedes convenience.

---

## 28. KDS Build Order

Recommended KDS order:

1. KDS ticket state model
2. ticket candidate boundary
3. upstream readiness check
4. duplicate ticket prevention
5. KDS accepted ticket handoff
6. cancellation impact display
7. retry/remake boundary
8. degraded kitchen note
9. KDS evidence packet
10. advanced KDS optimization later

KDS ticketing must not start from UI button only.

---

## 29. Mini Kiosk Build Order

Recommended Mini Kiosk order:

1. session creation
2. menu display candidate
3. order intent capture
4. timeout/abandonment
5. payment handoff boundary
6. payment state display
7. provider failure display
8. KDS handoff display
9. support path
10. advanced UX later

Mini Kiosk creates intent.

It does not own POS or payment truth.

---

## 30. Support Build Order

Recommended support order:

1. support role boundary
2. case creation
3. scoped access
4. masking
5. support session logging
6. evidence review
7. recovery recommendation
8. escalation path
9. break-glass boundary
10. advanced support dashboard later

Support must be safe before powerful.

---

## 31. UI Build Order

Recommended UI order:

1. runtime state labels
2. read-only state display
3. safe action buttons
4. error/uncertainty display
5. support handoff
6. owner/store review
7. pilot evidence summary
8. admin configuration
9. advanced dashboard later

UI must not create authority that runtime has not granted.

---

## 32. Test Build Order

Recommended test order:

1. tenant/store isolation
2. role/device access
3. audit append-only
4. provider idempotency
5. provider replay
6. payment uncertainty
7. duplicate payment
8. duplicate KDS ticket
9. support masking
10. Mini Kiosk timeout
11. rollback/disable
12. pilot evidence packet

Test order should follow risk order.

---

## 33. Evidence Build Order

Recommended evidence order:

1. audit event
2. provider event evidence
3. payment evidence
4. KDS ticket evidence
5. support case evidence
6. Mini Kiosk session evidence
7. export/report evidence
8. pilot evidence packet
9. billing lifecycle evidence later
10. franchise governance evidence later

Evidence must exist before pilot claims are made.

---

## 34. Deferred Build Families

The following should remain deferred until Phase 1 proof:

- broad provider ecosystem
- advanced analytics
- full Franchise OS
- hardware partner program
- AI automation
- full SaaS billing automation
- complex CRM
- multi-store benchmark
- complete inventory/WMS/SCM
- external dealer network

Deferred means tracked, not forgotten.

---

## 35. Build Stop Conditions

Build should stop or pause if:

- tenant/store context is unclear
- provider truth is ambiguous
- payment state cannot be verified
- KDS duplicate risk is unresolved
- support masking is incomplete
- audit is missing
- rollback path is absent
- test linkage is missing
- secret handling is unsafe
- Phase 1 scope is expanding silently

Stop early to avoid deeper rework.

---

## 36. Build Resume Conditions

Build may resume when:

- blocker is documented
- affected runtime is identified
- risk is understood
- fix is mapped
- test is added or updated
- evidence path is updated
- scope impact is reviewed
- dependency order is restored

Resume should be controlled.

---

## 37. Implementation Sequence Register

A future implementation sequence register should include:

- sequence id
- layer
- runtime
- data flow
- backlog item
- prerequisite
- output
- test
- evidence
- status
- blocker
- owner
- notes

Recommended file:

    docs/_index/Phase_1_Implementation_Sequence_Register.md

This document only recommends the register.

---

## 38. Anti-Patterns

The following are prohibited:

- building UI first and inventing state later
- building KDS ticketing before payment readiness
- trusting provider signal before validation
- implementing support recovery before masking
- implementing payment without idempotency
- implementing refund/cancel without authority boundary
- implementing pilot before evidence packets
- adding Phase 2 providers during Phase 1 core build
- starting Franchise OS before store runtime proof
- skipping audit because MVP is small
- treating test as post-launch cleanup
- implementing from memory instead of backlog

---

## 39. Non-Goals

This document does not define:

- final database migration order
- final API endpoint order
- final Flutter route order
- final provider SDK calls
- final KDS device setup
- final deployment checklist
- final production runbook
- final implementation sprint calendar

Those belong to later authorized implementation planning.

---

## 40. Readiness Check

This document is ready when the project can answer:

1. Why does build order matter?
2. What are the Phase 1 build layers?
3. What is Layer 0?
4. What is Layer 1?
5. What is Layer 2?
6. What is Layer 3?
7. What is Layer 4?
8. What is Layer 5?
9. What is Layer 6?
10. What is Layer 7?
11. What is Layer 8?
12. What is Layer 9?
13. What is Layer 10?
14. What is Layer 11?
15. What is Layer 12?
16. What strict dependency rules apply?
17. What parallel work is allowed?
18. What parallel work is not allowed?
19. What runtime build order applies?
20. What data flow build order applies?
21. What risk-first build order applies?
22. What provider build order applies?
23. What payment build order applies?
24. What KDS build order applies?
25. What Mini Kiosk build order applies?
26. What support build order applies?
27. What UI build order applies?
28. What test build order applies?
29. What evidence build order applies?
30. What build stop conditions apply?
31. What build resume conditions apply?
32. What anti-patterns are prohibited?

If these questions cannot be answered, Phase 1 implementation sequence and build order planning is incomplete.

---

## 41. Conclusion

Phase 1 implementation must follow dependency order.

The safe order is:

    environment safety
        -> tenant/store context
        -> auth/role/device trust
        -> audit/evidence
        -> runtime states
        -> provider boundary
        -> payment certainty
        -> order intent/session
        -> KDS handoff
        -> support recovery
        -> UI minimum
        -> tests/evidence packets
        -> pilot readiness

This document prevents the project from building visible features on top of unsafe runtime foundations.

The project should implement only after backlog extraction, phase authorization, and dependency order confirmation.