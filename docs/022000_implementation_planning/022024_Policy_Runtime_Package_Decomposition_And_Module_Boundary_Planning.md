# 022024_Policy_Runtime_Package_Decomposition_And_Module_Boundary_Planning

## 1. Purpose

This document defines runtime package decomposition, module boundary planning, runtime ownership, cross-runtime dependency, authority boundary, state/event ownership, implementation package separation, i18n dependency, evidence dependency, fallback dependency, rollback dependency, and coding entry deferral policy for the Yoonsul Wait/Order Handoff operating system.

The previous document opened the 09300 Controlled Implementation Planning and Package Decomposition lane and defined package decomposition rules, package types, package dependency mapping, i18n mapping, error message mapping, security/legal/provider mapping, fallback/rollback mapping, and no-code boundary.

This document focuses on splitting approved scope into runtime-owned packages and defining module boundaries before any data model, API, UI, or implementation planning deepens.

This document does not authorize coding, schema creation, API creation, provider adapter build, payment integration, KDS integration, AI support implementation, pgvector/RAG implementation, or external partner integration.

It defines runtime package decomposition and module boundary planning policy only.

---

## 2. Scope

This document covers:

- runtime package decomposition
- runtime owner rule
- module boundary rule
- state ownership
- event ownership
- command/query boundary
- cross-runtime dependency
- authority boundary
- package split/merge rule
- runtime package registry
- i18n dependency
- evidence/audit dependency
- fallback/rollback dependency
- no-code boundary

This document does not cover:

- final database schema
- final API implementation
- final event bus implementation
- final UI implementation
- final payment gateway implementation
- final KDS connector
- final POS connector
- final provider adapter
- final AI support gateway
- final pgvector/RAG implementation
- final external partner integration

---

## 3. Core Principle

Runtime package must be owned before it is implemented.

The project must follow this rule:

> Every implementation package must know which runtime owns the truth, which module only projects or requests action, which states and events belong to that runtime, which dependencies are external, and which actions are prohibited.

A module without owner becomes authority drift.

A shared state without owner becomes reconciliation failure.

A UI action without runtime boundary becomes unsafe mutation.

A provider event without owner becomes false truth.

---

## 4. Runtime Package Meaning

Runtime package means a bounded implementation planning unit that owns or coordinates a specific operational truth domain.

A runtime package should define:

- runtime name
- owner
- canonical state candidates
- event candidates
- command candidates
- query candidates
- authority boundary
- dependencies
- evidence output
- audit output if needed
- UI surfaces
- i18n messages
- fallback
- rollback
- excluded scope

Runtime package is not code.

Runtime package is implementation planning structure.

---

## 5. Module Boundary Meaning

Module boundary means the line separating what a module owns, what it reads, what it requests, what it projects, and what it must never mutate.

Module boundary should answer:

- does this module own truth?
- does it only display truth?
- does it request action?
- does it translate provider data?
- does it create evidence?
- does it create audit?
- does it route workflow?
- does it require approval?
- does it depend on another runtime?
- what must it never do?

Module boundary prevents accidental authority expansion.

---

## 6. Runtime Package Status Values

Recommended runtime package status values:

- `RUNTIME_PACKAGE_DRAFT`
- `RUNTIME_SOURCE_REQUIRED`
- `RUNTIME_OWNER_REQUIRED`
- `RUNTIME_STATE_REVIEW_REQUIRED`
- `RUNTIME_EVENT_REVIEW_REQUIRED`
- `RUNTIME_AUTHORITY_REVIEW_REQUIRED`
- `RUNTIME_DEPENDENCY_REVIEW_REQUIRED`
- `RUNTIME_I18N_REVIEW_REQUIRED`
- `RUNTIME_EVIDENCE_REVIEW_REQUIRED`
- `RUNTIME_FALLBACK_REVIEW_REQUIRED`
- `RUNTIME_ROLLBACK_REVIEW_REQUIRED`
- `RUNTIME_BLOCKED`
- `RUNTIME_READY_FOR_PLANNING`
- `RUNTIME_APPROVED_WITH_CONDITIONS`
- `RUNTIME_DEFERRED`
- `RUNTIME_REJECTED`
- `RUNTIME_SUPERSEDED`

Status must not imply coding approval.

---

## 7. Runtime Package Record Fields

Each runtime package record should include:

- runtime package id
- runtime name
- source references
- linked backlog ids
- linked build gate packet
- runtime owner
- secondary runtimes
- included scope
- excluded scope
- state candidates
- event candidates
- command candidates
- query candidates
- authority boundary
- dependency map
- evidence requirements
- audit requirements
- i18n/message requirements
- fallback path
- rollback path
- blockers
- status
- notes

Runtime package record must be reviewable.

---

## 8. Runtime Package ID Format

Recommended format:

    RUNTIME-PACKAGE-[RUNTIME]-[YYYYMMDD]-[NUMBER]

Examples:

    RUNTIME-PACKAGE-PAY-20260612-001
    RUNTIME-PACKAGE-KDS-20260612-001
    RUNTIME-PACKAGE-AIG-20260612-001

Final format may be normalized later.

---

## 9. Core Runtime Families

Recommended core runtime families:

- Customer Session Runtime
- Table Session Runtime
- Order Runtime
- Payment Runtime
- Refund/Cancel Runtime
- KDS Runtime
- POS Runtime
- Provider Adapter Runtime
- Mini Kiosk Runtime
- Delivery Platform Adapter Runtime
- Support Runtime
- Admin Runtime
- Evidence Runtime
- Audit Runtime
- Security Runtime
- I18n Content Runtime
- Menu Content Runtime
- AI Support Gateway Runtime
- Knowledge Retrieval Runtime
- External Menu Projection Runtime
- Redtable-Type Partner Runtime
- Commercial Runtime
- Billing Runtime
- Pilot Runtime
- Documentation Governance Runtime

Runtime families may be decomposed further later.

---

## 10. Runtime Owner Rule

Each runtime package must have one primary owner.

Primary owner controls:

- canonical state
- accepted events
- rejected events
- transition rules
- authority rules
- evidence output
- audit requirement if any
- fallback and rollback responsibility

Secondary runtimes may depend on it.

Secondary runtime does not own its truth.

---

## 11. Runtime Authority Rule

Runtime authority defines what a runtime may do.

Authority types:

- own state
- accept command
- emit event
- reject event
- request review
- create evidence
- append audit
- project read model
- notify support
- trigger fallback
- request rollback
- block action

Authority must be explicit.

---

## 12. Runtime Prohibition Rule

Each runtime package must define what it must not do.

Examples:

- Provider Adapter must not become payment truth
- Admin must not directly mutate payment truth
- Support must not browse all tenant data
- KDS must not own payment status
- Payment must not own kitchen execution
- AI Support must not mutate runtime state
- External Menu Projection must not own menu source truth
- Redtable-type Partner must not own Yoonsul canonical settlement truth
- I18n Content Runtime must not change operational authority

Prohibition prevents drift.

---

## 13. State Ownership Rule

Each state belongs to one runtime owner.

State ownership should define:

- state name
- meaning
- owner runtime
- allowed previous states
- allowed next states
- event that changes it
- who may request change
- evidence if needed
- audit if needed
- UI display rule
- i18n message if user-facing

Shared state without owner is prohibited.

---

## 14. Event Ownership Rule

Each event belongs to one event owner or accepted event handler.

Event ownership should define:

- event name
- source
- receiving runtime
- validation rule
- idempotency rule
- duplicate rule
- stale rule
- accepted result
- rejected result
- evidence output
- audit output if needed

Event without owner must be quarantined or blocked.

---

## 15. Command Boundary Rule

Command means a request to change state or begin a workflow.

Command boundary should define:

- command name
- requester
- target runtime
- preconditions
- validation
- authority
- expected state change
- prohibited state change
- error message
- evidence output
- audit output

Command does not guarantee success.

---

## 16. Query Boundary Rule

Query means a request to view state or projection.

Query boundary should define:

- query name
- requester
- target runtime or projection
- permission
- context
- masking
- stale state rule
- visible fields
- hidden fields
- i18n message if user-facing
- audit if sensitive

Query permission is not action permission.

---

## 17. Projection Boundary Rule

Projection means displaying or transforming runtime-owned data for another surface.

Projection boundary should define:

- source runtime
- projection target
- freshness
- stale indicator
- masking
- field mapping
- i18n mapping
- external exposure rule
- prohibited fields
- evidence/audit if needed

Projection is not ownership.

---

## 18. Customer Session Runtime Boundary

Customer Session Runtime may own:

- customer session
- entry channel
- locale preference
- waiting context
- table join candidate
- customer-visible session status

It must not own:

- payment truth
- KDS truth
- POS truth
- provider truth
- support case truth
- identity verification truth

Customer session coordinates customer flow.

---

## 19. Table Session Runtime Boundary

Table Session Runtime may own:

- table session
- shared table context
- participant context
- table order grouping
- split settlement context
- seated flow status

It must not own:

- individual payment truth
- KDS execution truth
- provider event truth
- refund truth

Table session is context owner, not money owner.

---

## 20. Order Runtime Boundary

Order Runtime may own:

- order intent
- order candidate
- order accepted state
- order item grouping
- customer order display
- order lifecycle before handoff

It must not own:

- payment provider truth
- POS ledger truth
- KDS execution truth
- provider callback truth

Order Runtime coordinates handoff.

---

## 21. Payment Runtime Boundary

Payment Runtime may own:

- payment attempt
- payment status
- provider payment reference mapping
- payment uncertainty
- payment reconciliation requirement
- payment evidence requirement

It must not own:

- KDS preparation state
- POS item truth
- refund approval if separated
- provider raw event truth without validation
- commercial margin truth

Payment Runtime protects money state.

---

## 22. Refund Cancel Runtime Boundary

Refund/Cancel Runtime may own:

- refund request
- cancel request
- review state
- approval/rejection state
- refund/cancel evidence
- refund/cancel support path

It must not own:

- original payment provider truth
- KDS preparation truth
- customer identity truth
- provider settlement truth

Refund/Cancel must coordinate with Payment and KDS.

---

## 23. KDS Runtime Boundary

KDS Runtime may own:

- kitchen ticket
- ticket hold
- ticket release
- preparation state
- ready state
- served state
- remake/retry state
- kitchen execution evidence

It must not own:

- payment confirmation
- customer identity
- provider validation
- refund approval
- POS ledger truth

KDS owns kitchen execution only.

---

## 24. POS Runtime Boundary

POS Runtime may own:

- POS accepted order state
- POS transaction boundary
- POS receipt or ledger reference
- POS reconciliation requirement
- POS provider mapping if applicable

It must not own:

- external provider truth before validation
- KDS internal preparation truth
- AI recommendation
- support decision
- commercial package truth

POS owns transaction acceptance boundary.

---

## 25. Provider Adapter Runtime Boundary

Provider Adapter Runtime may own:

- provider event receipt
- authentication/signature validation
- idempotency check
- duplicate classification
- stale classification
- mapping candidate
- quarantine
- provider incident

It must not own:

- payment truth
- KDS truth
- POS truth
- support resolution truth
- menu source truth

Provider Adapter validates and translates.

---

## 26. Mini Kiosk Runtime Boundary

Mini Kiosk Runtime may own:

- kiosk session
- device context
- customer interaction flow
- cart candidate
- timeout state
- abandoned flow
- staff call request

It must not own:

- payment truth
- POS truth
- KDS truth
- identity verification truth
- final order truth without handoff

Mini Kiosk is self-service interaction, not transaction authority.

---

## 27. Delivery Platform Adapter Runtime Boundary

Delivery Platform Adapter Runtime may own:

- platform order event candidate
- platform cancellation candidate
- platform status candidate
- platform provider mapping
- delivery incident candidate

It must not own:

- internal POS truth
- payment truth
- KDS execution truth
- customer recovery truth
- sold-out truth unless projected from authorized runtime

Delivery adapter must validate external events.

---

## 28. Support Runtime Boundary

Support Runtime may own:

- support case
- support session
- case notes
- customer recovery workflow
- escalation workflow
- support evidence reference
- support closure state

It must not own:

- payment truth
- KDS truth
- provider truth
- legal conclusion
- audit mutation
- unrestricted data browsing

Support owns recovery workflow.

---

## 29. Admin Runtime Boundary

Admin Runtime may own:

- Admin task queue
- review workflow
- approval request workflow
- blocker visibility
- status dashboard projection
- operational coordination view

It must not own:

- runtime truth directly
- payment mutation
- KDS completion
- provider event trust
- raw sensitive data by default
- high-risk activation without gate

Admin coordinates; it does not override.

---

## 30. Evidence Runtime Boundary

Evidence Runtime may own:

- evidence packet
- evidence link
- evidence status
- masked evidence view
- evidence review state
- evidence retention placeholder

It must not own:

- runtime state truth
- approval truth by itself
- audit mutation
- customer identity display
- provider raw payload display without masking

Evidence proves; it does not decide.

---

## 31. Audit Runtime Boundary

Audit Runtime may own:

- append-only audit event
- actor/action/context/time record
- audit correlation
- audit search projection
- immutable history reference

It must not own:

- business state
- evidence content
- approval decision
- support note
- mutable correction

Audit records what happened.

---

## 32. Security Runtime Boundary

Security Runtime may own:

- access rule
- masking policy
- export/unmask review
- session trust
- device trust
- secret handling policy
- security incident classification

It must not own:

- business operation decision
- payment truth
- KDS truth
- commercial pricing
- customer recovery outcome

Security enforces control boundary.

---

## 33. I18n Content Runtime Boundary

I18n Content Runtime may own:

- content key
- message key
- locale version
- fallback rule
- translation status
- glossary key
- content version
- content approval state

It must not own:

- runtime state
- payment truth
- KDS truth
- legal decision
- provider capability truth

I18n Runtime owns localized content infrastructure.

---

## 34. Menu Content Runtime Boundary

Menu Content Runtime may own:

- menu item key
- menu display content
- menu description
- allergen/diet indicators
- translated menu content
- public menu projection content
- menu content version

It must not own:

- real-time POS transaction
- payment
- KDS execution
- provider event
- external partner canonical override

Menu Content is canonical content owner.

---

## 35. AI Support Gateway Runtime Boundary

AI Support Gateway Runtime may own:

- AI query admission
- support case scope enforcement
- masking
- source routing
- freshness metadata
- confidence display
- human review requirement
- AI access audit

It must not own:

- payment approval
- KDS release
- provider event acceptance
- legal conclusion
- customer identity truth
- runtime mutation

AI Gateway controls AI access.

---

## 36. Knowledge Retrieval Runtime Boundary

Knowledge Retrieval Runtime may own:

- approved source retrieval
- vector index source registry
- content citation
- freshness metadata
- access-scoped retrieval
- retrieval failure state

It must not own:

- operational truth
- final customer answer
- payment/KDS/provider action
- legal conclusion
- sensitive raw data

Knowledge Retrieval retrieves; it does not decide.

---

## 37. External Menu Projection Runtime Boundary

External Menu Projection Runtime may own:

- public menu package
- external menu content projection
- Google Maps landing content package
- QR/NFC public menu projection
- partner display package
- content version projection

It must not own:

- canonical menu source
- POS truth
- payment truth
- KDS truth
- support case
- customer identity
- internal evidence

External projection publishes approved public content.

---

## 38. Redtable-Type Partner Runtime Boundary

Redtable-Type Partner Runtime may own:

- partner capability record
- partner evidence record
- partner menu mapping candidate
- global payment route candidate
- partner settlement evidence candidate
- partner incident candidate

It must not own:

- Yoonsul canonical menu source
- Yoonsul Payment Runtime truth
- KDS truth
- POS truth
- customer identity
- internal support truth
- internal settlement finality without reconciliation

Partner runtime is external integration boundary.

---

## 39. Commercial Runtime Boundary

Commercial Runtime may own:

- package definition
- pricing candidate
- support tier
- billing responsibility candidate
- contract scope candidate
- renewal/churn signal
- commercial promise boundary

It must not own:

- payment transaction truth
- provider settlement truth
- KDS truth
- legal approval
- product readiness truth

Commercial must follow operational proof.

---

## 40. Billing Runtime Boundary

Billing Runtime may own:

- invoice candidate
- fee allocation
- support fee
- provider cost pass-through candidate
- billing dispute
- credit/refund commercial adjustment
- revenue recognition placeholder

It must not own:

- customer payment gateway truth
- store operation truth
- KDS truth
- provider event truth

Billing must reconcile with payment/settlement evidence.

---

## 41. Pilot Runtime Boundary

Pilot Runtime may own:

- pilot scope
- dry run record
- go/no-go record
- pilot incident
- daily learning
- rollback/pause state
- pilot evidence summary

It must not own:

- production readiness truth
- runtime state truth
- commercial promise truth
- provider capability truth

Pilot Runtime structures learning.

---

## 42. Documentation Governance Runtime Boundary

Documentation Governance Runtime may own:

- source-of-truth register
- numbering register
- open gap register
- blocker register
- deferred register
- NFI register
- package register
- correction/supersession record

It must not own:

- business runtime state
- implementation code
- provider capability truth
- legal conclusion

Documentation governance protects traceability.

---

## 43. Cross-Runtime Dependency Rule

Cross-runtime dependency must be explicit.

Dependency record should identify:

- source runtime
- target runtime
- dependency type
- event or query
- permission
- expected result
- prohibited result
- evidence requirement
- fallback
- blocker if unavailable

Implicit dependency is prohibited.

---

## 44. Cross-Runtime Authority Rule

Cross-runtime calls must preserve authority.

Examples:

- Order may request Payment, but Payment owns payment state
- Payment may block KDS release, but KDS owns kitchen execution
- Provider Adapter may propose event mapping, but target runtime validates
- Support may request refund review, but Refund/Cancel Runtime owns review state
- Admin may display blocker, but runtime owner resolves it
- AI Support may recommend, but human/runtime owner acts

Authority must remain clear.

---

## 45. Runtime Package Split Rule

Split runtime package when:

- states belong to different owners
- events come from different authority domains
- provider dependency differs
- UI surface differs significantly
- evidence/test requirements differ
- fallback/rollback differs
- legal/security review differs
- i18n audience differs
- external partner boundary appears

Split prevents runtime confusion.

---

## 46. Runtime Package Merge Rule

Merge runtime packages only when:

- same runtime owner
- same state/event family
- same authority boundary
- same evidence family
- same test family
- same fallback/rollback family
- same security/legal/provider condition
- no UI authority confusion

Merge should simplify, not hide responsibility.

---

## 47. Runtime Package Blocker Rule

Create blocker when:

- runtime owner missing
- state owner unclear
- event owner unclear
- command boundary unclear
- query masking unclear
- authority prohibition missing
- provider event mutates truth directly
- Admin or Support can mutate runtime truth incorrectly
- AI can mutate runtime truth
- external partner can own canonical truth
- fallback/rollback missing

Runtime blocker stops package planning.

---

## 48. Registers Recommendation

Recommended future files:

    docs/_index/
      Runtime_Package_Register.md
      Runtime_Owner_Register.md
      State_Ownership_Register.md
      Event_Ownership_Register.md
      Command_Boundary_Register.md
      Query_Boundary_Register.md
      Projection_Boundary_Register.md
      Cross_Runtime_Dependency_Register.md
      Cross_Runtime_Authority_Register.md
      Runtime_Package_Blocker_Register.md

This document only recommends these files.

It does not create them.

---

## 49. Anti-Patterns

The following are prohibited:

- one giant runtime package
- state without owner
- event without owner
- provider event directly mutating truth
- Admin becoming runtime owner
- Support becoming payment/KDS owner
- AI becoming operator
- External Menu Projection owning canonical menu
- Redtable-type partner owning payment truth
- i18n content changing operational meaning
- KDS owning payment state
- Payment owning kitchen execution
- Evidence treated as approval
- Audit treated as business state

---

## 50. No-Code Boundary

This document does not authorize:

- runtime code implementation
- database schema creation
- API implementation
- event bus implementation
- provider adapter implementation
- payment integration
- KDS integration
- POS connector
- Mini Kiosk implementation
- AI support gateway implementation
- pgvector/RAG implementation
- external partner integration
- production pilot

This document governs runtime package and module boundary planning only.

---

## 51. Readiness Check

This document is ready when the project can answer:

1. What is runtime package?
2. What is module boundary?
3. What runtime package statuses exist?
4. What fields should runtime package record include?
5. What core runtime families exist?
6. What runtime owner rule applies?
7. What runtime authority rule applies?
8. What runtime prohibition rule applies?
9. What state ownership rule applies?
10. What event ownership rule applies?
11. What command boundary rule applies?
12. What query boundary rule applies?
13. What projection boundary rule applies?
14. What Customer Session boundary applies?
15. What Table Session boundary applies?
16. What Order Runtime boundary applies?
17. What Payment Runtime boundary applies?
18. What Refund/Cancel boundary applies?
19. What KDS Runtime boundary applies?
20. What POS Runtime boundary applies?
21. What Provider Adapter boundary applies?
22. What Mini Kiosk boundary applies?
23. What Delivery Platform Adapter boundary applies?
24. What Support Runtime boundary applies?
25. What Admin Runtime boundary applies?
26. What Evidence Runtime boundary applies?
27. What Audit Runtime boundary applies?
28. What Security Runtime boundary applies?
29. What I18n Content Runtime boundary applies?
30. What Menu Content Runtime boundary applies?
31. What AI Support Gateway boundary applies?
32. What Knowledge Retrieval boundary applies?
33. What External Menu Projection boundary applies?
34. What Redtable-type Partner boundary applies?
35. What Commercial Runtime boundary applies?
36. What Billing Runtime boundary applies?
37. What Pilot Runtime boundary applies?
38. What Documentation Governance boundary applies?
39. What cross-runtime dependency rule applies?
40. What cross-runtime authority rule applies?
41. What runtime package split rule applies?
42. What runtime package merge rule applies?
43. What runtime package blocker rule applies?
44. What registers are recommended?
45. What anti-patterns are prohibited?
46. What no-code boundary applies?

If these questions cannot be answered, runtime package decomposition and module boundary planning is incomplete.

---

## 52. Conclusion

Runtime package decomposition is where the operating system avoids becoming a tangled application.

The safe runtime planning flow is:

    approved package scope
        -> runtime family
        -> runtime owner
        -> state ownership
        -> event ownership
        -> command/query/projection boundaries
        -> cross-runtime dependencies
        -> authority prohibitions
        -> evidence, audit, i18n, fallback, rollback mapping
        -> package blocker or planning readiness

This document ensures that Customer Session, Table Session, Order, Payment, Refund/Cancel, KDS, POS, Provider Adapter, Mini Kiosk, Support, Admin, Evidence, Audit, Security, I18n Content, Menu Content, AI Support Gateway, Knowledge Retrieval, External Menu Projection, Redtable-type Partner, Commercial, Billing, Pilot, and Documentation Governance runtimes remain clearly separated before implementation planning deepens.