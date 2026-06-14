# 09430 Controlled Foundation Coding Entry Decision And Limited Allowance Policy

## 1. Purpose

This document defines the controlled decision boundary for allowing a limited first coding entry wave after foundation-first guardrail review.

The purpose is to ensure that any future coding begins only with low-authority foundation packages that reduce implementation risk.

This document may identify which foundation packages can be considered for limited coding entry, but it does not automatically approve all runtime implementation.

Only packages explicitly marked `CODING_ALLOWED` in a later execution handoff may be coded.

All other packages remain deferred.

---

## 2. Scope

This policy applies only to foundation-first guardrail packages.

Eligible package families include:

1. i18n message catalog
2. Locale and audience catalog
3. Content registry catalog
4. SOP traceability catalog
5. Contract catalog
6. Provider capability registry
7. Audit event catalog
8. Evidence packet catalog
9. Data visibility and masking catalog
10. Error message key catalog
11. Degraded state catalog
12. Readiness and blocker inventory
13. Package handoff record
14. No-hardcoded-operational-string guardrail
15. Boundary test planning catalog

This policy does not authorize:

- payment execution
- refund execution
- settlement finalization
- KDS live connector
- POS/KDS bridge implementation
- support/admin mutation console
- customer-facing AI automation
- production pgvector RAG
- external menu publication
- Redtable-type partner adapter
- global payment bridge
- Google Maps/NFC/QR provider integration

Those remain deferred.

---

## 3. Core Principle

Limited coding entry must start with guardrails, not runtime power.

The first approved implementation wave, when later explicitly allowed, should create controlled structures that prevent unsafe development.

It should not create business mutation, payment authority, provider dependency, customer-facing automation, or external publication.

The correct first implementation target is the control plane.

Not the runtime engine.

---

## 4. Limited Coding Allowance Rule

A foundation package may be granted limited coding allowance only if all of the following are true:

| Requirement | Meaning |
|---|---|
| Package is foundation-first | It belongs to a guardrail/catalog family |
| Runtime mutation is absent | It does not change orders, payments, KDS, support, or provider state |
| Provider execution is absent | It does not call external provider APIs |
| Customer automation is absent | It does not send customer-facing automated responses |
| Publication is absent | It does not publish external menu/projection content |
| Secrets are absent | It does not store or expose provider secrets |
| i18n/content structure is central | It supports key/catalog/traceability control |
| Audit/evidence structure is central | It supports future accountability |
| Tests can verify boundaries | It can be tested without business runtime side effects |
| Explicit package approval exists | `CODING_ALLOWED` is granted per package, not globally |

---

## 5. Coding Allowance Is Package-Specific

Coding allowance must never be global.

Each package must be individually reviewed and marked.

Allowed format:

| Package ID | Decision | Scope | Coding Status |
|---|---|---|---|
| `foundation.i18n.message_catalog.v1` | Allow limited foundation coding | Catalog only | `CODING_ALLOWED` |
| `foundation.contract.catalog.v1` | Allow limited foundation coding | Identifier catalog only | `CODING_ALLOWED` |
| `payment.provider.adapter.v1` | Not allowed | Runtime/provider execution | `CODING_DEFERRED` |

A package not listed as `CODING_ALLOWED` remains deferred.

---

## 6. Candidate Packages For Limited Foundation Coding

The following packages may be considered as first limited coding candidates if reviewed and explicitly approved later:

| Package ID | Allowed Scope Candidate | Default Status |
|---|---|---|
| `foundation.i18n.message_catalog.v1` | Message key family catalog only | `ENTRY_REVIEW_REQUIRED` |
| `foundation.locale.audience_catalog.v1` | Locale/audience classification catalog only | `ENTRY_REVIEW_REQUIRED` |
| `foundation.content.registry_catalog.v1` | Content key family catalog only | `ENTRY_REVIEW_REQUIRED` |
| `foundation.sop.traceability_catalog.v1` | SOP metadata requirement catalog only | `ENTRY_REVIEW_REQUIRED` |
| `foundation.contract.catalog.v1` | Contract identifier catalog only | `ENTRY_REVIEW_REQUIRED` |
| `foundation.provider.capability_registry.v1` | Provider capability status catalog only | `ENTRY_REVIEW_REQUIRED` |
| `foundation.audit.event_catalog.v1` | Audit event family catalog only | `ENTRY_REVIEW_REQUIRED` |
| `foundation.evidence.packet_catalog.v1` | Evidence family catalog only | `ENTRY_REVIEW_REQUIRED` |
| `foundation.security.visibility_catalog.v1` | Visibility/masking class catalog only | `ENTRY_REVIEW_REQUIRED` |
| `foundation.error.message_key_catalog.v1` | Error key family catalog only | `ENTRY_REVIEW_REQUIRED` |
| `foundation.degraded.state_catalog.v1` | Degraded state catalog only | `ENTRY_REVIEW_REQUIRED` |
| `foundation.readiness.blocker_inventory.v1` | Readiness/blocker tracker only | `ENTRY_REVIEW_REQUIRED` |
| `foundation.package.handoff_record.v1` | Package handoff template only | `ENTRY_REVIEW_REQUIRED` |
| `foundation.no_hardcoded_string_guard.v1` | Guardrail/check rule planning only | `ENTRY_REVIEW_REQUIRED` |

This table does not grant coding permission by itself.

---

## 7. Strictly Excluded Implementation Scope

Even if a foundation package receives limited coding allowance, the following remain excluded:

1. Runtime order mutation
2. Runtime payment mutation
3. Refund execution
4. Settlement allocation
5. KDS ticket creation
6. POS/KDS live routing
7. Provider API calls
8. Provider webhook processing
9. Provider credential storage
10. Customer-facing AI response automation
11. AI tool execution against production data
12. pgvector production retrieval
13. External menu publication
14. Redtable-type partner API integration
15. Google Maps publishing
16. NFC/QR provider integration
17. Support/admin mutation
18. Customer identity sharing
19. Unmasking workflow
20. Production export/report generation

Limited foundation coding must remain catalog/control-plane only.

---

## 8. Allowed Artifact Types For Limited Foundation Coding

If later approved, limited foundation coding may create low-authority artifacts such as:

- static catalog files
- typed constants
- enum-like planning catalogs
- JSON/YAML catalog seeds
- markdown-to-catalog mapping templates
- validation schemas
- non-runtime test fixtures
- readiness tracker templates
- handoff record templates
- lint/check rule drafts
- documentation-linked metadata maps

These artifacts must not perform runtime business actions.

---

## 9. Disallowed Artifact Types In Limited Foundation Coding

Limited foundation coding must not create:

- production SQL migrations for business tables
- payment provider adapters
- provider SDK clients
- webhook endpoints
- KDS connectors
- customer UI runtime screens
- support/admin mutation screens
- production AI prompts
- embedding pipelines
- pgvector runtime tables
- external projection publishers
- partner API clients
- secret storage implementation
- refund execution functions
- settlement finalization functions
- production customer notification sender

These require later runtime coding entry policies.

---

## 10. Foundation Coding Entry Decision Record

Every coding entry decision must be recorded.

Required fields:

| Field | Required Meaning |
|---|---|
| Decision id | Stable decision identifier |
| Package id | Package being reviewed |
| Decision | Allow, defer, reject, or require review |
| Allowed scope | Exact scope if allowed |
| Excluded scope | What remains prohibited |
| Required tests | Boundary tests required |
| Required review | Architecture/security/i18n/content review |
| Open blockers | Remaining blockers |
| Deferred blockers | Blockers not resolved but outside allowed scope |
| Approver | Future responsible authority |
| Coding status | `CODING_ALLOWED` or `CODING_DEFERRED` |

No verbal approval is sufficient.

---

## 11. Coding Status Values

Foundation coding entry decisions must use explicit status values.

| Status | Meaning |
|---|---|
| `ENTRY_NOT_REVIEWED` | No entry decision has been made |
| `ENTRY_REVIEW_REQUIRED` | Package requires decision review |
| `ENTRY_ALLOWED_LIMITED_FOUNDATION` | Limited guardrail coding may proceed |
| `ENTRY_DEFERRED` | Coding remains deferred |
| `ENTRY_REJECTED` | Package is not suitable for entry |
| `ENTRY_BLOCKED` | Blocker prevents entry |
| `ENTRY_RUNTIME_SCOPE_PROHIBITED` | Runtime scope is explicitly excluded |
| `CODING_ALLOWED` | Explicit final per-package approval |
| `CODING_DEFERRED` | Coding not allowed |

Only `CODING_ALLOWED` permits coding.

---

## 12. Required Boundary Tests

A package granted limited foundation coding allowance must have boundary tests planned.

Test families may include:

- catalog identifier uniqueness
- status value validity
- message key format validity
- content key format validity
- provider capability default state
- no confirmed provider capability without evidence
- no hardcoded operational string in controlled runtime surfaces
- no package marked coding-ready with open blocking status
- audit family reference validity
- evidence class reference validity
- visibility class validity
- degraded state reference validity
- handoff record required field completeness

Tests should protect gates before runtime implementation expands.

---

## 13. No-Hardcoded-Operational-String Enforcement

The first coding entry wave must preserve the no-hardcoded-operational-string rule.

Any allowed foundation package must support enforcement of:

- message key use
- content key use
- locale mapping
- audience mapping
- provider status label mapping
- error message key mapping
- degraded instruction key mapping

Operational strings must not be embedded into future UI/API/RPC/provider/AI surfaces.

---

## 14. Provider Capability Default Rule

Any provider capability registry work must default unverified external capabilities to:

`CAPABILITY_PROVIDER_EVIDENCE_REQUIRED`

This includes:

- Redtable-type API availability
- Alipay
- WeChat Pay
- overseas cards
- global settlement
- Google Maps-linked projection
- NFC/QR provider support
- partner menu publication
- provider refund responsibility
- customer identity sharing
- data retention terms
- settlement conditions

No provider capability may default to confirmed.

---

## 15. AI Boundary Preservation

Any foundation package related to AI must preserve AI as assistance only.

Allowed foundation AI-related structures may define:

- source classification catalog
- output state catalog
- human review rule map
- provider evidence notice map
- traceability metadata requirement
- masking requirement map

Excluded AI scopes remain:

- production RAG
- production pgvector retrieval
- automatic customer reply
- automatic support case closure
- refund/recovery recommendation execution
- provider capability confirmation
- external projection publication

AI remains non-authoritative.

---

## 16. Audit And Evidence Preservation

Any limited foundation coding must support future audit and evidence lineage.

It may define:

- audit event families
- reason code families
- authority marker families
- evidence packet families
- evidence integrity states
- evidence source classes
- review status values

It must not execute audit-bearing runtime actions unless a later runtime coding entry document explicitly approves implementation.

---

## 17. Security Preservation

Limited foundation coding must not introduce secrets, credentials, live provider calls, or broad admin visibility.

Security-related foundation packages may define:

- visibility classes
- masking classes
- credential boundary requirements
- webhook verification requirement catalog
- export restriction catalog
- data sharing review categories

They must not grant production access.

---

## 18. File And Handoff Discipline

No future coding package may be implemented from memory or chat summary alone.

A package handoff must exist before coding.

The handoff must include:

- package id
- allowed scope
- excluded scope
- planning source documents
- blockers
- dependencies
- test requirements
- i18n/content requirements
- audit/evidence requirements
- security requirements
- coding status

If the handoff is missing, coding remains deferred.

---

## 19. Entry Decision Table Template

Use the following template for future entry decisions.

| Decision ID | Package ID | Decision | Allowed Scope | Excluded Scope | Status |
|---|---|---|---|---|---|
| `ENTRY-0001` | `foundation.i18n.message_catalog.v1` | Allow limited foundation coding | Message key catalog only | Runtime UI/API text implementation | `CODING_ALLOWED` |
| `ENTRY-0002` | `payment.provider.adapter.v1` | Defer | None | Provider execution | `CODING_DEFERRED` |

This table must be maintained as an explicit artifact.

---

## 20. Relationship To Previous Documents

This document follows:

- `09390 Controlled Implementation Planning Closure And Coding Entry Deferral Policy`
- `09400 Controlled Implementation Readiness Review And Blocker Inventory Policy`
- `09410 Controlled Coding Entry Candidate Package Selection Policy`
- `09420 Foundation-First Coding Entry Gate And Guardrail Package Policy`

This document prepares the structure for a later actual implementation handoff.

It does not itself authorize implementation unless a specific package is explicitly marked `CODING_ALLOWED` in a controlled entry record.

---

## 21. Final Rule

Controlled coding entry must be limited, explicit, package-specific, and foundation-first.

The first allowed coding wave, when later approved, must build guardrails and catalogs only.

It must not build payment execution, KDS integration, support/admin mutation, AI automation, external projection publication, Redtable-type partner adapters, global payment bridges, or provider-dependent runtime features.

Coding remains deferred by default.

Only a package-specific `CODING_ALLOWED` decision can change that status.
