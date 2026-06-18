# 022450_Policy_Foundation_Catalog_Implementation_Order_And_Dependency

## 1. Purpose

This document defines the recommended implementation order and dependency policy for foundation-first catalog packages.

The purpose is to prevent foundation implementation from becoming fragmented, circular, or prematurely coupled to runtime-heavy packages.

After controlled handoff and work order rules are defined in `22440`, the next step is to define the safe order in which foundation catalogs should be prepared.

This document does not authorize coding.

Coding remains allowed only through a package-specific `CODING_ALLOWED` decision and completed work order.

---

## 2. Scope

This policy applies to foundation catalog and guardrail packages, including:

1. i18n message catalog
2. Locale and audience catalog
3. Content registry catalog
4. SOP traceability catalog
5. Contract catalog
6. Event family catalog
7. Audit event catalog
8. Evidence packet catalog
9. Provider capability registry
10. Error/message key catalog
11. Degraded state catalog
12. Security visibility and masking catalog
13. AI source/output catalog
14. External projection source/status catalog
15. Readiness and blocker inventory
16. Package handoff record template
17. No-hardcoded-string guardrail
18. Boundary test catalog

This policy does not apply to live runtime implementation.

Payment execution, KDS integration, support/admin mutation, AI production RAG, external projection publication, and provider adapters remain deferred.

---

## 3. Core Principle

Foundation catalogs must be implemented in dependency order.

A later catalog must not assume an earlier catalog exists unless it is explicitly created or stubbed.

For example:

- message keys depend on locale/audience structure
- content registry depends on source traceability
- AI retrieval depends on source classification
- support templates depend on content registry and audit/evidence classes
- external projection depends on content registry, translation status, provider capability, and rollback status
- payment/KDS provider planning depends on provider capability registry and error/audit catalogs

The foundation sequence must build the lowest-level shared vocabularies first.

---

## 4. Recommended Foundation Order

The recommended order is:

1. `foundation.locale.audience_catalog.v1`
2. `foundation.status.value_catalog.v1`
3. `foundation.provider.capability_registry.v1`
4. `foundation.i18n.message_catalog.v1`
5. `foundation.error.message_key_catalog.v1`
6. `foundation.content.registry_catalog.v1`
7. `foundation.sop.traceability_catalog.v1`
8. `foundation.contract.catalog.v1`
9. `foundation.event.family_catalog.v1`
10. `foundation.audit.event_catalog.v1`
11. `foundation.evidence.packet_catalog.v1`
12. `foundation.security.visibility_catalog.v1`
13. `foundation.degraded.state_catalog.v1`
14. `foundation.ai.source_output_catalog.v1`
15. `foundation.projection.status_catalog.v1`
16. `foundation.readiness.blocker_inventory.v1`
17. `foundation.package.handoff_record.v1`
18. `foundation.no_hardcoded_string_guard.v1`
19. `foundation.boundary.test_catalog.v1`

This order may be adjusted only when the dependency reason is documented.

---

## 5. Dependency Rule

Each foundation package must declare its dependencies.

Dependency types include:

| Dependency Type | Meaning |
|---|---|
| `NONE` | No prior package required |
| `CATALOG_DEPENDENCY` | Requires another catalog |
| `STATUS_DEPENDENCY` | Requires status value definitions |
| `I18N_DEPENDENCY` | Requires message key structure |
| `CONTENT_DEPENDENCY` | Requires content registry structure |
| `TRACEABILITY_DEPENDENCY` | Requires source traceability fields |
| `PROVIDER_DEPENDENCY` | Requires provider capability states |
| `AUDIT_DEPENDENCY` | Requires audit family catalog |
| `EVIDENCE_DEPENDENCY` | Requires evidence family catalog |
| `SECURITY_DEPENDENCY` | Requires visibility/masking classes |
| `TEST_DEPENDENCY` | Requires test/check catalog |

A package must not be implemented if a required dependency is missing or undefined.

---

## 6. Foundation Dependency Table

The following table defines initial dependency expectations.

| Package ID | Depends On | Reason |
|---|---|---|
| `foundation.locale.audience_catalog.v1` | `NONE` | Base classification for all visible surfaces |
| `foundation.status.value_catalog.v1` | `NONE` | Shared status vocabulary |
| `foundation.provider.capability_registry.v1` | `foundation.status.value_catalog.v1` | Provider status values must be controlled |
| `foundation.i18n.message_catalog.v1` | `foundation.locale.audience_catalog.v1` | Message keys depend on locale/audience |
| `foundation.error.message_key_catalog.v1` | `foundation.i18n.message_catalog.v1` | Errors must map to message keys |
| `foundation.content.registry_catalog.v1` | `foundation.locale.audience_catalog.v1` | Content must preserve locale/audience |
| `foundation.sop.traceability_catalog.v1` | `foundation.content.registry_catalog.v1` | SOP content must link to registry |
| `foundation.contract.catalog.v1` | `foundation.status.value_catalog.v1` | Contracts need readiness/status values |
| `foundation.event.family_catalog.v1` | `foundation.contract.catalog.v1` | Events depend on contract families |
| `foundation.audit.event_catalog.v1` | `foundation.event.family_catalog.v1` | Audit relates to event lineage |
| `foundation.evidence.packet_catalog.v1` | `foundation.audit.event_catalog.v1` | Evidence must link to audit where needed |
| `foundation.security.visibility_catalog.v1` | `foundation.status.value_catalog.v1` | Visibility classes require controlled values |
| `foundation.degraded.state_catalog.v1` | `foundation.i18n.message_catalog.v1` | Degraded states require message keys |
| `foundation.ai.source_output_catalog.v1` | `foundation.content.registry_catalog.v1`, `foundation.security.visibility_catalog.v1` | AI needs source and masking classes |
| `foundation.projection.status_catalog.v1` | `foundation.content.registry_catalog.v1`, `foundation.provider.capability_registry.v1` | Projection needs content and provider status |
| `foundation.readiness.blocker_inventory.v1` | All prior catalogs | Readiness tracks blockers across catalogs |
| `foundation.package.handoff_record.v1` | `foundation.readiness.blocker_inventory.v1` | Handoff must reference blockers |
| `foundation.no_hardcoded_string_guard.v1` | `foundation.i18n.message_catalog.v1`, `foundation.content.registry_catalog.v1` | Guard must know key structures |
| `foundation.boundary.test_catalog.v1` | All prior catalogs | Tests validate foundation boundaries |

---

## 7. Locale And Audience First Rule

Locale and audience catalog should be prepared before i18n, content, UI, AI, support, and projection catalogs.

Minimum audience classes should include:

- `CUSTOMER`
- `FOREIGN_CUSTOMER`
- `STAFF`
- `KITCHEN_KDS`
- `STORE_OWNER`
- `HQ_ADMIN`
- `SUPPORT_OPERATOR`
- `AI_INTERNAL`
- `PARTNER`
- `LEGAL_COMPLIANCE`

Minimum locale planning should include:

- default locale
- fallback locale
- supported locale candidate list
- untranslated content behavior
- audience-specific wording behavior
- external projection locale behavior

This catalog creates the base language and audience map.

---

## 8. Status Value Catalog Rule

A shared status value catalog should be prepared early.

It may include status families for:

- package readiness
- coding entry
- provider capability
- translation readiness
- content approval
- audit requirement
- evidence integrity
- AI output state
- degraded state
- projection publication
- blocker lifecycle

Status values must be stable and explicit.

Ambiguous statuses such as `OK`, `done`, `maybe`, or `active` must be avoided for authority-sensitive domains.

---

## 9. Provider Capability Registry Dependency

Provider capability registry should be prepared before any provider adapter planning moves further.

The registry must include capability status values:

- `CAPABILITY_NOT_PLANNED`
- `CAPABILITY_PLANNED`
- `CAPABILITY_PROVIDER_EVIDENCE_REQUIRED`
- `CAPABILITY_CONFIRMED`
- `CAPABILITY_LIMITED`
- `CAPABILITY_REJECTED`
- `CAPABILITY_DEPRECATED`

Default unresolved external provider status:

`CAPABILITY_PROVIDER_EVIDENCE_REQUIRED`

This applies to Redtable-type modules, global payment candidates, Google Maps-linked projection, QR/NFC provider capability, Alipay, WeChat Pay, overseas card support, settlement terms, and refund responsibility.

---

## 10. i18n Message Catalog Dependency

The i18n message catalog depends on locale and audience classification.

It should define message key families for:

- common status
- common action
- common error
- payment
- refund
- settlement
- KDS
- order handoff
- waiting/seating
- support
- admin
- AI support
- external projection
- provider capability
- degraded operation
- fallback instruction

It must not define hardcoded runtime strings as implementation.

It defines key families and structure.

---

## 11. Error Message Key Dependency

Error message key catalog depends on i18n message key structure.

It must separate:

- internal error code
- customer-facing message key
- staff-facing message key
- support diagnostic key
- severity
- retryability
- escalation condition
- provider mapping
- audit requirement
- fallback instruction

Raw provider error text must not become customer-facing text.

---

## 12. Content Registry Dependency

The content registry catalog depends on locale/audience structure.

It should define content key families for:

- menu names
- menu descriptions
- option groups
- modifiers
- allergens
- ingredients
- training content
- SOP-derived content
- support templates
- AI approved response references
- external projection content
- provider status labels
- degraded operation instructions

The content registry catalog must preserve source traceability and version planning.

---

## 13. SOP Traceability Dependency

SOP traceability depends on content registry structure.

It must preserve:

- source document id
- source section id
- source version
- locale
- audience
- runtime boundary
- authority boundary
- actionability level
- evidence requirement
- fallback condition
- content registry key
- approval status
- effective date

SOP parser output must not flatten operational meaning into plain text.

---

## 14. Contract Catalog Dependency

Contract catalog depends on status values and planning identifiers.

It should define contract families for:

- API
- RPC
- event
- audit
- provider callback
- content lookup
- i18n resolution
- support/evidence
- AI retrieval
- external projection
- payment
- KDS

The contract catalog must not implement handlers or runtime functions.

---

## 15. Event Family Dependency

Event family catalog depends on contract catalog.

It should define event families for:

- requested
- accepted
- rejected
- emitted
- projected
- acknowledged
- failed
- retried
- recovered
- reconciled
- stale
- blocked
- evidence-attached
- audit-required

Events must not be vague logs.

---

## 16. Audit Event Dependency

Audit catalog depends on event family catalog.

It should define audit families for:

- restricted data view
- unmasking
- evidence creation
- support action request
- support approval
- refund approval
- refund execution
- override authority use
- provider capability status change
- content approval
- AI response approval
- external projection publication
- export/report action

Audit must describe accountability.

It is not the same as operational event logging.

---

## 17. Evidence Packet Dependency

Evidence packet catalog depends on audit event catalog.

It should define evidence classes such as:

- customer message
- customer image
- receipt
- order event
- payment event
- provider callback
- KDS event
- staff note
- manual fallback note
- support note
- SOP reference
- content registry reference
- AI summary
- admin approval
- audit reference
- reconciliation reference

Original and derived evidence must be distinguished.

AI summary is derived evidence only.

---

## 18. Security Visibility Dependency

Security visibility catalog depends on shared status values.

It should define:

- public operational data
- customer masked data
- staff masked data
- payment masked data
- provider diagnostic data
- evidence-only data
- restricted full view
- legal review only data
- blocked data

The catalog must not grant broad admin access.

It defines classification only.

---

## 19. Degraded State Dependency

Degraded state catalog depends on i18n message keys because degraded states require controlled visible messages.

It should define states such as:

- provider unavailable
- callback delayed
- payment state uncertain
- settlement reconciliation required
- KDS bridge degraded
- duplicate ticket risk
- content registry unavailable
- translation unavailable
- external projection stale
- local cache uncertain
- manual fallback required
- AI unavailable
- audit write delayed
- support escalation required

Uncertainty must not be hidden as normal operation.

---

## 20. AI Source And Output Dependency

AI source/output catalog depends on content registry and security visibility classes.

It should define:

- source classes
- blocked source classes
- output states
- human review states
- traceability requirements
- masking requirements
- provider evidence notice states
- customer-facing approval requirements

AI remains assistance only.

No AI package may execute mutation or customer-facing automation from this catalog.

---

## 21. External Projection Status Dependency

External projection status catalog depends on content registry and provider capability registry.

It should define:

- projection target classes
- publication status
- translation status
- provider capability status
- stale projection status
- rollback status
- payment evidence status
- customer identity mode
- data sharing status

External projection remains projection only.

It does not become source of truth.

---

## 22. Readiness And Blocker Inventory Dependency

Readiness/blocker inventory should depend on all major catalogs so it can track blockers consistently.

It must classify blockers for:

- i18n
- content registry
- SOP traceability
- contract
- provider evidence
- audit
- evidence
- security
- AI traceability
- translation
- rollback
- degraded operation
- testing
- coding entry

The blocker inventory must not approve coding.

It only tracks readiness.

---

## 23. Package Handoff Dependency

Package handoff record depends on blocker inventory.

The handoff must reference:

- package id
- decision id
- allowed scope
- excluded scope
- related blockers
- related contracts
- related i18n/content keys
- provider evidence status
- audit/evidence rule
- security rule
- tests/checks
- coding status

A handoff must exist before future coding work.

---

## 24. No-Hardcoded-String Guard Dependency

No-hardcoded-string guard depends on i18n and content key structures.

It should check or define checks against:

- UI operational strings
- API response strings
- RPC error strings
- support/admin messages
- payment/KDS status strings
- AI customer response strings
- external projection strings
- provider capability labels
- degraded operation instructions

The guardrail must prevent runtime-visible text from bypassing message/content keys.

---

## 25. Boundary Test Catalog Dependency

Boundary test catalog depends on prior catalogs.

It should define test families for:

- catalog id uniqueness
- status value validity
- required field presence
- provider capability default state
- no confirmed provider capability without evidence
- no missing i18n key family
- no missing content key family
- no hardcoded operational string
- no package marked coding-ready with blockers
- audit family reference validity
- evidence class reference validity
- visibility class validity
- degraded state reference validity
- AI output customer-ready restriction
- external projection rollback requirement

Tests protect future runtime implementation.

---

## 26. Dependency Violation Rule

A dependency violation occurs when a package:

- references an undefined status value
- references an undefined audience
- references an undefined locale behavior
- references an undefined provider status
- references an undefined message key family
- references an undefined content key family
- references an undefined audit family
- references an undefined evidence class
- references an undefined visibility class
- references an undefined degraded state
- marks provider capability confirmed without evidence
- marks coding allowed with unresolved blockers

Dependency violations must block package entry.

---

## 27. Implementation Order Table Template

Foundation implementation order should be tracked using this table.

| Order | Package ID | Depends On | Status | Blocker | Coding Status |
|---|---|---|---|---|---|
| 1 | `foundation.locale.audience_catalog.v1` | `NONE` | `ENTRY_REVIEW_REQUIRED` | Review required | `CODING_DEFERRED` |
| 2 | `foundation.status.value_catalog.v1` | `NONE` | `ENTRY_REVIEW_REQUIRED` | Review required | `CODING_DEFERRED` |
| 3 | `foundation.provider.capability_registry.v1` | `foundation.status.value_catalog.v1` | `ENTRY_REVIEW_REQUIRED` | Evidence default review | `CODING_DEFERRED` |

This table is a planning artifact.

It does not permit coding.

---

## 28. Prohibited Dependency Shortcuts

The following are prohibited:

1. Building UI before i18n/message key catalog
2. Building content runtime before content registry catalog
3. Building provider adapter before provider capability registry
4. Building AI retrieval before source/visibility catalogs
5. Building support mutation before audit/evidence catalogs
6. Building payment execution before provider/reconciliation catalogs
7. Building KDS connector before event/degraded catalogs
8. Building external projection before content/provider/rollback catalogs
9. Referencing undefined status values
10. Marking provider capability confirmed without evidence
11. Treating catalog existence as runtime authority
12. Treating dependency order as coding approval

---

## 29. Relationship To Previous Documents

This document follows:

- `22400 Controlled Implementation Readiness Review And Blocker Inventory Policy`
- `22410 Controlled Coding Entry Candidate Package Selection Policy`
- `22420 Foundation-First Coding Entry Gate And Guardrail Package Policy`
- `22430 Controlled Foundation Coding Entry Decision And Limited Allowance Policy`
- `22440 Controlled Foundation Implementation Handoff And Work Order Policy`

This document prepares the dependency order for possible later foundation implementation.

It does not authorize coding.

---

## 30. Final Rule

Foundation-first implementation must proceed in dependency order.

The project must define shared vocabularies, statuses, i18n structures, content traceability, provider evidence states, contract identifiers, audit/evidence families, visibility classes, degraded states, readiness blockers, handoff records, and boundary tests before runtime-heavy implementation begins.

This document defines the order and dependency logic.

Coding remains deferred unless a specific package has a `CODING_ALLOWED` decision, a completed handoff record, and a narrow work order.
