# 014050_Policy_Implementation_Backlog_Extraction_Cutline

## 1. Purpose

This document defines the implementation backlog extraction queue, phase cutline control, requirement extraction rule, implementation candidate review, deferred scope handling, and no-direct-implementation policy for the Yoonsul Wait/Order Handoff documentation project.

The previous document defined the data flow index, runtime ownership matrix, provider dependency matrix, UI surface matrix, evidence path matrix, test linkage matrix, and implementation extraction matrix.

This document defines how reviewed documentation should become controlled implementation backlog items.

This document does not implement any backend, frontend, database, provider adapter, KDS runtime, Mini Kiosk, SaaS billing, or Franchise OS module.

It defines backlog extraction and phase control policy only.

---

## 2. Scope

This document covers:

- implementation backlog extraction
- extraction queue
- phase cutline
- requirement candidate review
- backlog item structure
- implementation readiness
- deferred item handling
- rejected item handling
- security priority
- provider priority
- UI priority
- test linkage
- no-implementation boundary

This document does not cover:

- final project management tool
- final sprint planning tool
- final database schema
- final Flutter implementation
- final provider adapter implementation
- final payment implementation
- final KDS implementation
- final Mini Kiosk implementation
- final production deployment
- final CI/CD pipeline

---

## 3. Core Principle

Implementation must be extracted, not improvised.

The project must follow this rule:

> No implementation item should be created directly from memory or excitement. It must be extracted from reviewed documentation, mapped to data flow, assigned to runtime owner, linked to test requirement, and placed inside a controlled phase cutline.

Documentation creates options.

Backlog extraction creates controlled work.

Implementation begins only after extraction and authorization.

---

## 4. Why Backlog Extraction Is Required

The project may produce thousands of Markdown documents.

If implementation begins directly from those documents, risks include:

- uncontrolled scope
- duplicate work
- wrong priority
- security gaps
- provider overreach
- UI authority mistakes
- payment truth confusion
- KDS state conflict
- support workflow gaps
- Franchise OS premature expansion
- Phase 2/3 features entering Phase 1
- implementation without test coverage

Backlog extraction prevents document volume from turning into execution chaos.

---

## 5. Extraction Queue Definition

The extraction queue is the controlled list of documents waiting to be converted into backlog items.

A document enters extraction queue only after:

- document is complete
- document number is stable
- folder is assigned
- primary data flow is known
- runtime owner is known
- security impact is reviewed at least lightly
- phase candidate is known
- priority candidate is known
- duplicate/superseded status is checked

Unreviewed drafts should not enter extraction queue.

---

## 6. Extraction Queue Status Values

Recommended extraction queue status values:

- `NOT_QUEUED`
- `QUEUE_CANDIDATE`
- `QUEUED`
- `UNDER_EXTRACTION_REVIEW`
- `EXTRACTION_BLOCKED`
- `EXTRACTED_TO_BACKLOG`
- `PARTIALLY_EXTRACTED`
- `DEFERRED_FROM_EXTRACTION`
- `REJECTED_FROM_EXTRACTION`
- `SUPERSEDED_BEFORE_EXTRACTION`
- `ARCHIVED`

Most high-speed documents should remain `NOT_QUEUED` until review.

---

## 7. Extraction Queue Entry Fields

Each extraction queue entry should include:

- queue id
- document number
- document title
- file path
- primary data flow
- runtime owner
- provider dependency
- UI surface
- evidence path
- test family
- phase candidate
- priority candidate
- extraction status
- extraction reviewer
- blocker status
- duplicate status
- superseded status
- notes
- next action

This record may be stored in Markdown, CSV, spreadsheet, or project management tool later.

---

## 8. Queue ID Format

Recommended queue id format:

    EXTRACT-QUEUE-[DOCUMENT-NUMBER]

Examples:

    EXTRACT-QUEUE-05290
    EXTRACT-QUEUE-05420
    EXTRACT-QUEUE-05540

If multiple extraction passes are needed:

    EXTRACT-QUEUE-05290-PASS-01

Final format may be normalized later.

---

## 9. Extraction Candidate Types

Documents may produce different extraction candidate types.

Recommended values:

- `RUNTIME_REQUIREMENT`
- `SECURITY_REQUIREMENT`
- `PROVIDER_REQUIREMENT`
- `PAYMENT_REQUIREMENT`
- `KDS_REQUIREMENT`
- `MINI_KIOSK_REQUIREMENT`
- `SUPPORT_REQUIREMENT`
- `UI_REQUIREMENT`
- `TEST_REQUIREMENT`
- `EVIDENCE_REQUIREMENT`
- `BILLING_REQUIREMENT`
- `FRANCHISE_OS_REQUIREMENT`
- `DOCUMENTATION_REQUIREMENT`
- `DEFERRED_REQUIREMENT`
- `NON_IMPLEMENTATION_NOTE`

Not every section becomes implementation.

---

## 10. Requirement Extraction Rule

A document section may become requirement when it defines:

- required runtime behavior
- required state transition
- required validation
- required security control
- required audit event
- required evidence packet
- required test case
- required UI boundary
- required provider handling
- required recovery path
- required support action
- required billing lifecycle behavior
- required Franchise OS linkage later

A section should not become requirement merely because it is interesting.

---

## 11. Non-Implementation Note Rule

Some sections should remain notes.

Examples:

- strategy context
- market observation
- long-term possibility
- naming idea
- future research
- deferred provider idea
- optional revenue idea
- folder recommendation
- tool suggestion
- pilot learning note

These may inform future planning but should not create immediate backlog.

---

## 12. Backlog Item Structure

Each implementation backlog item should include:

- backlog id
- title
- source document
- source section
- requirement summary
- affected runtime
- data flow
- provider dependency
- UI surface
- evidence path
- test requirement
- security impact
- phase
- priority
- dependency
- acceptance criteria
- non-goals
- deferred scope
- owner
- status

Backlog item must be traceable to source document.

---

## 13. Backlog ID Format

Recommended backlog id format:

    IMPL-[PHASE]-[RUNTIME]-[NUMBER]

Examples:

    IMPL-P1-PAYMENT-001
    IMPL-P1-KDS-002
    IMPL-P1-PROVIDER-003
    IMPL-P2-PROVIDER-001
    IMPL-P3-FRANCHISE-001

Alternative document-based format:

    IMPL-EXTRACT-05290-001

Final format may be normalized later.

---

## 14. Backlog Status Values

Recommended backlog status values:

- `DRAFT`
- `UNDER_REVIEW`
- `READY_FOR_PHASE_REVIEW`
- `APPROVED_FOR_IMPLEMENTATION`
- `BLOCKED`
- `DEFERRED`
- `REJECTED`
- `IN_PROGRESS`
- `IMPLEMENTED`
- `TEST_READY`
- `TESTED`
- `RELEASE_READY`
- `RELEASED`
- `SUPERSEDED`

During documentation phase, items should not pass `READY_FOR_PHASE_REVIEW` unless implementation is explicitly authorized.

---

## 15. Phase Cutline Purpose

Phase cutline prevents all good ideas from entering Phase 1.

The cutline answers:

- must this be built now?
- can Phase 1 operate without it?
- is it security-critical?
- is it payment-critical?
- is it KDS-critical?
- is it provider-critical?
- is it pilot-critical?
- is it only nice-to-have?
- does it belong to Franchise OS later?
- does it require external provider access not yet confirmed?

Cutline keeps implementation realistic.

---

## 16. Phase Values

Recommended phase values:

- `PHASE_0_DOCUMENTATION`
- `PHASE_1_CORE_RUNTIME`
- `PHASE_1_SECURITY_MINIMUM`
- `PHASE_1_PROVIDER_TOSS`
- `PHASE_1_PROVIDER_OKPOS_COMPATIBILITY`
- `PHASE_1_PAYMENT_RECOVERY`
- `PHASE_1_KDS_HANDOFF`
- `PHASE_1_MINI_KIOSK_BOUNDARY`
- `PHASE_1_PILOT_READINESS`
- `PHASE_2_PROVIDER_EXPANSION`
- `PHASE_2_UI_EXPANSION`
- `PHASE_2_SAAS_PACKAGING`
- `PHASE_3_FRANCHISE_OS`
- `PHASE_3_HARDWARE_PARTNER`
- `DEFERRED`
- `REJECTED`

Phase values may be consolidated later.

---

## 17. Phase 1 Inclusion Rule

A backlog item may enter Phase 1 only if it is required for:

- core order handoff
- payment certainty
- refund/cancel safety
- KDS handoff safety
- provider adapter minimum for Toss
- OKPOS compatibility boundary
- Mini Kiosk boundary where needed
- audit/evidence
- support recovery
- tenant/store isolation
- security baseline
- pilot readiness
- rollback/safe disable

Phase 1 should be survivable, safe, and testable.

---

## 18. Phase 1 Exclusion Rule

Do not include in Phase 1 by default:

- broad 30-POS compatibility
- full Franchise OS
- advanced analytics
- hardware partner program
- AI automation
- advanced benchmark/export business
- multi-store HQ governance
- full billing system
- complex discount automation
- full customer success CRM
- Phase 2 provider expansion
- Phase 3 dealer ecosystem
- custom pilot store requests
- deep UI polish beyond required runtime visibility

These may be deferred.

---

## 19. Phase 2 Inclusion Rule

Phase 2 may include:

- selected provider expansion
- Smartro/KICC/NICE/Hyphen investigation outcomes
- improved Mini Kiosk features
- expanded KDS states
- richer owner dashboard
- SaaS package refinement
- customer success workflow
- analytics/reporting with governance
- pilot cluster improvement
- support workflow improvement
- provider gateway hardening

Phase 2 begins after Phase 1 evidence and core runtime stability.

---

## 20. Phase 3 Inclusion Rule

Phase 3 may include:

- Franchise OS linkage
- HQ dashboard
- multi-store governance
- hardware partner bundle
- dealer network strategy
- broad provider ecosystem
- advanced AI/analytics
- standardized launch kit
- franchise billing system
- cross-store benchmark
- certified hardware program

Phase 3 must not invade Phase 1.

---

## 21. Priority Values

Recommended priority values:

- `P0_CRITICAL_SECURITY`
- `P1_PAYMENT_OR_ORDER_BLOCKER`
- `P2_PHASE1_REQUIRED`
- `P3_PILOT_REQUIRED`
- `P4_PHASE2_REQUIRED`
- `P5_STRATEGIC`
- `P6_DEFERRED`
- `P7_REJECTED`

Priority must not be inflated.

If everything is P1, nothing is P1.

---

## 22. Security Priority Rule

Security-related items may become P0 or P1 when they affect:

- payment truth
- customer identity
- CI/DI handling
- tenant isolation
- support masking
- export authority
- webhook signature
- credential storage
- device trust
- audit immutability
- provider secret handling
- production deployment

Security priority must be specific.

Do not mark vague security notes as P0.

---

## 23. Payment Priority Rule

Payment-related items become high priority when they affect:

- approval truth
- refund/cancel authority
- duplicate payment
- uncertain payment
- reconciliation
- provider callback validation
- payment evidence
- customer trust
- settlement visibility

Payment uncertainty is not cosmetic.

It may block pilot readiness.

---

## 24. KDS Priority Rule

KDS-related items become high priority when they affect:

- duplicate kitchen ticket
- missing kitchen ticket
- cancellation after kitchen start
- retry/remake handling
- kitchen delay visibility
- POS/KDS handoff boundary
- external printer conflict
- degraded kitchen operation

KDS safety is operational, not decorative.

---

## 25. Provider Priority Rule

Provider-related items become high priority when they affect:

- Toss first integration
- OKPOS compatibility
- merchant/store mapping
- idempotency
- webhook/callback validation
- local daemon timeout
- provider disable/rollback
- provider evidence
- Phase 1 pilot readiness

Phase 2 providers should not consume Phase 1 priority unless explicitly authorized.

---

## 26. UI Priority Rule

UI-related items become Phase 1 priority only when they are required to display or control:

- payment uncertainty
- KDS state
- provider failure
- support recovery
- Mini Kiosk session state
- audit/evidence review
- staff-safe action
- owner-safe visibility

UI polish and advanced dashboard features should be deferred.

---

## 27. SaaS Priority Rule

SaaS-related items become Phase 1 priority only when they affect:

- pilot paid conversion
- package boundary clarity
- support scope clarity
- billing responsibility clarity
- customer lifecycle safety
- cancellation/downgrade runtime safety

Full billing automation may be deferred.

---

## 28. Franchise OS Priority Rule

Franchise OS items should normally be Phase 3 unless they define:

- future linkage boundary
- data ownership model
- HQ/store billing split
- multi-store signal tracking
- pilot evidence requirement

Franchise OS strategy can be documented early.

Franchise OS implementation should wait.

---

## 29. Acceptance Criteria Rule

Every backlog item must define acceptance criteria.

Acceptance criteria should answer:

- what must work?
- what must be prevented?
- what evidence proves it?
- what test must pass?
- what state is expected?
- what role is allowed?
- what role is prohibited?
- what failure mode is handled?
- what is out of scope?

No acceptance criteria means no implementation readiness.

---

## 30. Test Linkage Rule

Every implementation backlog item must link to at least one test family or verification method.

Examples:

- webhook signature test
- idempotency test
- duplicate payment test
- KDS duplicate ticket test
- support masking test
- export approval test
- Mini Kiosk session timeout test
- provider disable test
- billing downgrade safety test

Backlog without test linkage is incomplete.

---

## 31. Evidence Linkage Rule

Every implementation backlog item should define evidence output.

Examples:

- audit event
- provider event evidence
- payment evidence
- KDS ticket evidence
- support case evidence
- pilot evidence packet
- billing lifecycle evidence
- security incident evidence

If implementation cannot produce evidence, it may be hard to operate.

---

## 32. Deferred Item Rule

Deferred item must include:

- reason deferred
- target phase
- dependency
- risk if delayed
- revisit trigger
- source document
- related backlog items

Deferred does not mean forgotten.

---

## 33. Rejected Item Rule

Rejected item must include:

- reason rejected
- safety concern if any
- scope concern if any
- duplicate/superseded relation
- future reconsideration condition if any

Rejected items should not quietly return through another document.

---

## 34. Backlog Anti-Duplication Rule

When extracting backlog:

- search for similar item
- merge if duplicate
- split if too broad
- link related items
- mark superseded if replaced
- avoid creating same work from multiple docs
- use source references to preserve traceability

Backlog duplication causes implementation waste.

---

## 35. Extraction Review Queue

Recommended extraction review queues:

- `PAYMENT_EXTRACTION_REVIEW`
- `KDS_EXTRACTION_REVIEW`
- `PROVIDER_EXTRACTION_REVIEW`
- `MINI_KIOSK_EXTRACTION_REVIEW`
- `SUPPORT_EXTRACTION_REVIEW`
- `SECURITY_EXTRACTION_REVIEW`
- `UI_EXTRACTION_REVIEW`
- `SAAS_EXTRACTION_REVIEW`
- `FRANCHISE_OS_EXTRACTION_REVIEW`
- `DEFERRED_EXTRACTION_REVIEW`

Review queues allow domain-based extraction.

---

## 36. Implementation Authorization Gate

Implementation may begin only when:

1. backlog item is extracted
2. phase is approved
3. priority is approved
4. runtime owner is assigned
5. acceptance criteria exists
6. test linkage exists
7. evidence linkage exists
8. security impact is reviewed
9. dependencies are known
10. implementation boundary is clear

This gate prevents accidental build.

---

## 37. Backlog Storage Recommendation

Recommended future files:

    docs/_index/
      Implementation_Extraction_Queue.md
      Implementation_Backlog_Draft.md
      Phase_Cutline_Register.md
      Deferred_Item_Register.md
      Rejected_Item_Register.md
      Implementation_Authorization_Gate.md

This is a planning recommendation only.

Final storage may be Markdown, CSV, spreadsheet, issue tracker, or database.

---

## 38. Backlog Review Cadence

Recommended cadence:

| Cadence | Review |
| ------- | ------ |
| Daily during implementation | active backlog review |
| Weekly during documentation | extraction candidates review |
| Weekly | deferred items review |
| Weekly | Phase 1 cutline review |
| Biweekly | provider expansion review |
| Monthly | Franchise OS deferred review |
| Before implementation sprint | authorization gate review |

Cadence may change later.

---

## 39. Anti-Patterns

The following are prohibited:

- implementing directly from unreviewed Markdown
- assigning Phase 1 to every interesting feature
- assigning P0/P1 to vague concerns
- ignoring runtime owner
- ignoring acceptance criteria
- ignoring test linkage
- ignoring evidence linkage
- creating duplicate backlog items from different docs
- allowing Phase 2 provider expansion into Phase 1 without approval
- building UI screens without runtime authority mapping
- building billing automation before lifecycle boundary is clear
- implementing Franchise OS before store runtime is stable
- treating deferred as forgotten
- treating rejected as hidden backlog

---

## 40. Non-Goals

This document does not define:

- final implementation tool
- final sprint plan
- final ticket format
- final project management board
- final database schema
- final code architecture
- final UI specification
- final provider adapter design
- final release schedule

Those belong to later implementation planning.

---

## 41. Readiness Check

This document is ready when the project can answer:

1. What is extraction queue?
2. When can a document enter extraction queue?
3. What extraction queue status values exist?
4. What fields must queue entry include?
5. What extraction candidate types exist?
6. When does a section become requirement?
7. What remains non-implementation note?
8. What fields must backlog item include?
9. What backlog ID format is recommended?
10. What backlog status values exist?
11. What is phase cutline?
12. What phase values exist?
13. What enters Phase 1?
14. What is excluded from Phase 1?
15. What belongs to Phase 2?
16. What belongs to Phase 3?
17. What priority values exist?
18. How are security, payment, KDS, provider, UI, SaaS, and Franchise OS priorities decided?
19. What acceptance criteria rule applies?
20. What test linkage rule applies?
21. What evidence linkage rule applies?
22. How are deferred items handled?
23. How are rejected items handled?
24. How is backlog duplication prevented?
25. What extraction review queues exist?
26. What is implementation authorization gate?
27. What anti-patterns are prohibited?

If these questions cannot be answered, implementation backlog extraction and phase cutline control is incomplete.

---

## 42. Conclusion

The project should not move directly from high-volume Markdown documents into implementation.

The safe flow is:

    Reviewed Document
        -> Extraction Queue
        -> Requirement Candidate
        -> Phase Cutline
        -> Priority Assignment
        -> Acceptance Criteria
        -> Test Linkage
        -> Evidence Linkage
        -> Implementation Authorization Gate
        -> Backlog Item

This document protects Phase 1 from uncontrolled expansion and ensures that implementation work is traceable, testable, evidence-producing, and aligned with runtime ownership.

Documentation creates the map.

Backlog extraction creates the road.

Implementation begins only after the gate.