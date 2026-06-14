# 09330 API RPC Event Contract Planning Boundary Policy

## 1. Purpose

This document defines the planning boundary for API, RPC, and event contract design before controlled implementation begins.

The purpose is to prevent premature coding by forcing every runtime interaction to be described as a contract first.

This policy applies to API endpoints, RPC calls, event messages, audit events, adapter calls, AI gateway calls, content registry reads, menu projection calls, payment callbacks, KDS handoff calls, support actions, and external provider integrations.

No implementation package may proceed to coding unless its API, RPC, and event contract boundary is explicitly planned.

---

## 2. Scope

This policy covers the following contract families:

1. Internal API contracts
2. Supabase RPC contracts
3. Runtime event contracts
4. Audit event contracts
5. Adapter interface contracts
6. Provider capability contracts
7. Content registry lookup contracts
8. i18n message key contracts
9. AI support gateway contracts
10. External menu projection contracts
11. Payment/KDS/provider callback contracts
12. Support/admin evidence contracts

This document does not define actual SQL, TypeScript, Dart, HTTP handlers, Edge Functions, or provider API implementation.

Those are deferred until coding entry is explicitly allowed.

---

## 3. Core Principle

API/RPC/Event contract planning is not coding.

A contract defines:

* what may be requested
* who may request it
* what context must be present
* what content source is allowed
* what event must be emitted
* what audit trace must remain
* what fallback state is possible
* what must not be mutated silently

A contract does not define implementation code.

---

## 4. Contract-First Rule

Every runtime action must have a contract before implementation.

The minimum contract must define:

| Field             | Required Meaning                                              |
| ----------------- | ------------------------------------------------------------- |
| Contract name     | Stable contract identifier                                    |
| Runtime owner     | Which module owns the authority                               |
| Caller            | Which surface or module may call it                           |
| Input context     | Tenant, store, user, role, locale, audience, provider context |
| Output shape      | Allowed response family, not final DTO code                   |
| Authority level   | Read, propose, execute, approve, mutate                       |
| Event emission    | Required event or reason for no event                         |
| Audit requirement | Required audit trace                                          |
| i18n surface      | Message key/content key requirement                           |
| Fallback behavior | Degraded mode, retry, evidence required, or blocked           |
| Provider evidence | Required if external capability is claimed                    |
| Coding status     | Planned only / blocked / allowed later                        |

---

## 5. API Boundary

Internal APIs must be treated as runtime boundary contracts, not convenience functions.

An API contract must not expose raw database assumptions to UI, partner modules, AI support, or provider adapters.

APIs must preserve:

* tenant boundary
* store context
* role context
* locale
* audience
* content registry source
* event lineage
* audit trace
* provider capability status
* degraded state

APIs must not return hardcoded operational strings.

All user-visible strings must resolve through i18n message keys or content registry keys.

---

## 6. RPC Boundary

RPC calls are authority-bearing runtime contracts.

RPC planning must identify whether the RPC is:

1. read-only projection
2. state transition
3. controlled mutation
4. evidence packet creation
5. audit append
6. provider callback normalization
7. AI gateway retrieval
8. content registry lookup
9. fallback recovery action

RPCs must not be created merely because the UI needs convenience.

An RPC must exist only when authority, consistency, security, audit, or cross-module boundary requires it.

---

## 7. Event Boundary

Events represent runtime facts or runtime observations.

Events must not be used as vague logs.

Every event contract must define:

* event family
* event producer
* event consumer
* event authority level
* correlation id
* source module
* affected tenant/store
* actor or system actor
* timestamp source
* locale/content references if user-facing
* evidence reference if needed
* replay behavior
* audit relationship

Events must distinguish:

* requested
* accepted
* rejected
* emitted
* projected
* acknowledged
* failed
* retried
* recovered
* reconciled

---

## 8. Audit Boundary

Audit events are not the same as operational events.

Operational events describe runtime flow.

Audit events describe accountability.

An action may emit both.

Audit planning must define:

* who initiated the action
* what authority was used
* whether backup/override authority was involved
* what previous state existed
* what new state was requested
* whether the mutation was accepted
* whether evidence is attached
* whether the action is reversible
* whether the action requires later review

Silent mutation is prohibited.

---

## 9. i18n Contract Boundary

i18n is Foundation-level policy.

All API/RPC/Event contracts that can produce user-visible, staff-visible, owner-visible, support-visible, AI-visible, or partner-visible text must use i18n or content registry references.

Hardcoded operational strings are prohibited.

This includes:

* error messages
* status labels
* menu names
* option names
* support responses
* AI customer service responses
* training text
* admin warning messages
* provider-facing display labels
* external menu projection text
* KDS display text
* payment failure messages
* fallback instructions

The contract must identify whether the text source is:

1. i18n message key
2. content registry key
3. SOP-derived content key
4. menu registry content key
5. provider evidence label
6. blocked until translation source exists

---

## 10. Content Registry Contract Boundary

Menu, error, support, training, AI customer center, and external menu board content must be resolved through a content registry.

Content registry contracts must preserve:

* source document
* source traceability
* locale
* audience
* tenant/store applicability
* runtime boundary
* effective date
* version
* approval status
* projection target
* fallback content
* provider-specific transformation rule if any

The content registry is not a loose CMS.

It is a runtime content authority layer.

---

## 11. SOP Parser Contract Boundary

SOP parser output must not flatten operational meaning into plain text.

The parser must preserve:

* source traceability
* source document id
* section id
* locale
* audience
* runtime boundary
* authority boundary
* actionability level
* evidence requirement
* fallback condition
* i18n/content key linkage

SOP-derived content may support AI customer service, staff guidance, training, support/admin workflow, and external projection only when the runtime boundary permits it.

SOP content must not automatically become executable authority.

---

## 12. AI Support Gateway Contract Boundary

AI Support Gateway contracts must be read/propose-first unless explicitly approved otherwise.

The AI gateway may:

* retrieve SOP-aware content
* retrieve menu-aware content
* retrieve support knowledge
* summarize evidence
* suggest next steps
* classify issue families
* prepare support response drafts
* reference i18n/content keys

The AI gateway must not:

* silently mutate runtime state
* approve refunds
* finalize legal conclusions
* override store authority
* invent provider capability
* expose untranslated internal content
* bypass content registry
* bypass audit
* bypass tenant/store boundary

Any AI-generated response that reaches a customer, staff member, owner, support operator, or partner surface must be tied to content registry or approved message keys where operationally relevant.

---

## 13. Provider Adapter Contract Boundary

Provider adapter contracts must separate capability claim from capability evidence.

No provider capability may be treated as available until provider evidence is confirmed.

External provider capability status must use one of the following states:

* `CAPABILITY_NOT_PLANNED`
* `CAPABILITY_PLANNED`
* `CAPABILITY_PROVIDER_EVIDENCE_REQUIRED`
* `CAPABILITY_CONFIRMED`
* `CAPABILITY_LIMITED`
* `CAPABILITY_REJECTED`
* `CAPABILITY_DEPRECATED`

Provider contracts must define:

* provider name
* capability family
* evidence source
* API documentation status
* commercial condition status
* settlement condition status
* security review status
* localization support status
* fallback behavior
* adapter owner
* audit requirement

---

## 14. Redtable-Type Partner Contract Boundary

Redtable-type partner modules are treated as external menu projection and foreigner-facing commerce candidates.

Candidate capabilities include:

* foreigner menu translation
* external menu projection
* Google Maps-linked discovery
* NFC/QR menu entry
* global payment bridge
* tourism-friendly ordering surface
* partner-side content projection
* potential Alipay/WeChat Pay/overseas card support

However, the following must remain blocked until provider evidence is confirmed:

* actual Redtable API availability
* Alipay support
* WeChat Pay support
* overseas card support
* settlement terms
* commission model
* refund responsibility
* customer identity sharing
* content ownership
* translation responsibility
* API rate limit
* support responsibility
* data retention
* legal/compliance boundary

Default status:

`CAPABILITY_PROVIDER_EVIDENCE_REQUIRED`

---

## 15. Payment Contract Boundary

Payment-related API/RPC/Event contracts must be authority-restricted.

Payment contracts must distinguish:

* payment intent
* payment request
* payment authorization
* payment capture
* payment failure
* partial settlement
* split payment
* refund request
* refund approval
* refund execution
* reconciliation
* provider callback
* settlement allocation

Payment status text must be i18n/message-key based.

Payment provider claims require provider evidence.

No payment adapter implementation may proceed from assumption alone.

---

## 16. KDS Contract Boundary

KDS-related API/RPC/Event contracts must preserve the kitchen execution boundary.

KDS contracts must distinguish:

* order accepted by POS
* kitchen ticket created
* ticket routed
* ticket displayed
* ticket acknowledged
* preparation started
* item delayed
* remake requested
* ticket completed
* ticket cancelled
* degraded/manual kitchen note used

KDS is not payment authority.

KDS is not customer identity authority.

KDS is not final settlement authority.

KDS events may provide evidence, but evidence does not equal approval.

---

## 17. Support/Admin Contract Boundary

Support/admin APIs and RPCs must preserve accountability.

Support/admin contracts must define:

* support actor
* authority scope
* customer/store/owner visibility
* evidence packet requirement
* masking requirement
* audit event requirement
* escalation path
* whether the action is draft, recommendation, request, approval, or execution

Support operators must not gain hidden mutation authority through convenience APIs.

Admin UI text must be i18n/message-key based.

---

## 18. External Menu Projection Contract Boundary

External menu projection contracts apply to:

* QR menu
* NFC menu
* Google Maps-linked menu
* partner menu board
* foreigner menu surface
* multilingual menu display
* tourism-facing ordering surface
* Redtable-type partner modules

Projection contracts must preserve:

* menu source
* content registry key
* locale
* translation source
* price source
* availability source
* allergen source
* image source
* audience
* provider projection target
* last published version
* rollback version
* provider capability status

External projection must not become a separate menu authority.

The internal menu/content registry remains the source of truth unless a later architecture explicitly changes that authority.

---

## 19. Error Contract Boundary

Errors are runtime communication surfaces.

Errors must not be hardcoded.

Every error contract must define:

* error code
* message key
* audience
* severity
* retryability
* fallback instruction
* support escalation condition
* audit requirement if security/authority-related
* provider evidence requirement if provider-related
* AI-safe explanation boundary

Internal error detail and user-facing message must be separated.

---

## 20. Contract Naming Rule

Contract names should follow a stable pattern.

Recommended pattern:

`<runtime>.<domain>.<action>.<version>`

Examples:

* `pos.order.accept.v1`
* `kds.ticket.route.v1`
* `payment.intent.create.v1`
* `support.case.evidence.create.v1`
* `content.menu.lookup.v1`
* `i18n.message.resolve.v1`
* `ai.support.retrieve_context.v1`
* `partner.redtable.project_menu.v1`

Contract names are planning identifiers first.

They do not imply code exists.

---

## 21. Contract Readiness Levels

Each contract must have a readiness status.

| Status                                       | Meaning                                    |
| -------------------------------------------- | ------------------------------------------ |
| `CONTRACT_IDEA`                              | Candidate only                             |
| `CONTRACT_PLANNED`                           | Boundary described                         |
| `CONTRACT_REVIEW_REQUIRED`                   | Needs architecture/security review         |
| `CONTRACT_PROVIDER_EVIDENCE_REQUIRED`        | External provider capability not confirmed |
| `CONTRACT_I18N_REQUIRED`                     | Message/content keys not ready             |
| `CONTRACT_AUDIT_REQUIRED`                    | Audit lineage not complete                 |
| `CONTRACT_READY_FOR_IMPLEMENTATION_PLANNING` | Ready for package planning, not coding     |
| `CONTRACT_CODING_ALLOWED`                    | Only after explicit coding entry approval  |

Default status for this phase:

`CONTRACT_PLANNED`

Coding is not allowed by this document.

---

## 22. Prohibited Shortcuts

The following are prohibited:

1. Creating APIs before contract planning
2. Creating RPCs for UI convenience only
3. Returning hardcoded operational strings
4. Treating SOP text as executable authority
5. Treating AI output as approved operational content
6. Claiming provider capability without evidence
7. Mixing audit events with vague logs
8. Allowing support/admin APIs to mutate without evidence
9. Letting external menu projection become source of truth
10. Hiding provider fallback behavior
11. Skipping tenant/store/locale/audience context
12. Merging degraded/manual/fallback events silently
13. Treating KDS evidence as approval
14. Treating payment callback as final reconciliation without settlement rule
15. Coding adapters before capability confirmation

---

## 23. Minimum Planning Checklist

Before implementation package planning continues, each API/RPC/Event candidate must answer:

* What runtime owns this contract?
* Who may call it?
* What authority does it carry?
* What tenant/store/user context is required?
* What locale/audience context is required?
* What content registry or i18n key is required?
* What event is emitted?
* What audit event is required?
* What fallback state is possible?
* What provider evidence is required?
* What must be blocked?
* What must never be hardcoded?
* What coding entry status applies?

If any answer is missing, the contract remains planning-only.

---

## 24. Relationship To Previous Documents

This document follows:

* `09300 Controlled Implementation Planning README And Package Decomposition Index`
* `09310 Runtime Package Decomposition And Module Boundary Planning Policy`
* `09320 Data Model Planning Boundary And Schema Design Readiness Policy`

This document prepares the boundary for:

* `09340 UI Implementation Package Planning And I18n Surface Mapping Policy`
* `09350 Payment KDS Provider Adapter Package Planning Policy`
* `09360 Support Admin Evidence Audit Package Planning Policy`
* `09370 AI Support Gateway pgvector RAG Package Planning Policy`
* `09380 External Menu Projection Redtable Partner Package Planning Policy`
* `09390 Controlled Implementation Planning Closure And Coding Entry Deferral Policy`

---

## 25. Final Rule

API, RPC, and event contracts are the gate between architecture and implementation.

At this stage, the correct output is not code.

The correct output is a controlled contract map that prevents UI, database, provider adapters, AI support, KDS, payment, support/admin, and external projection modules from creating hidden authority, hardcoded strings, untranslated content, unaudited mutation, or provider assumptions.

Coding remains deferred.

Implementation begins only after contract readiness, i18n/content readiness, provider evidence, audit boundary, and package entry gates are explicitly approved.
