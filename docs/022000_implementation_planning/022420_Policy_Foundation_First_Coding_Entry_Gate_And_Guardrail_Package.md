# 022420_Policy_Foundation_First_Coding_Entry_Gate_And_Guardrail_Package

## 1. Purpose

This document defines the foundation-first coding entry gate for the first future implementation wave.

The purpose is to prevent runtime-heavy development from starting before the foundational guardrails exist.

After candidate selection in `22410`, the first coding entry candidates must be limited to packages that reduce future implementation risk.

This document does not authorize coding.

It defines which guardrail packages may be considered first when a later explicit coding entry approval document is prepared.

---

## 2. Scope

This policy applies to foundation-first guardrail package families, including:

1. i18n message key catalog
2. Locale and audience policy catalog
3. Content registry catalog
4. SOP/content traceability catalog
5. Contract catalog
6. Provider capability registry
7. Audit event catalog
8. Evidence packet catalog
9. Data visibility and masking catalog
10. Error/message key catalog
11. Degraded operation state catalog
12. Package readiness/blocker inventory
13. Package handoff record template
14. No-hardcoded-operational-string guardrail
15. Test boundary planning catalog

This document does not implement any database schema, UI screen, API, RPC, provider adapter, AI runtime, or external projection connector.

Coding remains deferred.

---

## 3. Core Principle

The first implementation wave should build the gates before building the business runtime.

Foundation-first means:

- define keys before screens
- define contracts before APIs
- define audit families before mutations
- define provider capability states before adapters
- define content source traceability before runtime content
- define masking classes before support/admin access
- define evidence families before refund/support execution
- define degraded states before fallback handling
- define blocker tracking before coding entry

The project must not start with payment, KDS, support mutation, AI automation, or external partner publication.

---

## 4. Foundation-First Gate Rule

A package may be considered for first-wave coding entry only if it satisfies all of the following:

| Gate | Required Meaning |
|---|---|
| Low runtime authority | Package does not execute business mutation |
| Registry/catalog purpose | Package creates controlled reference structure |
| No provider dependency or explicit evidence-required state | Does not assume external support |
| No customer-facing automation | Does not directly affect customer runtime |
| No payment execution | Does not authorize/capture/refund payment |
| No KDS live connector | Does not send live kitchen tickets |
| No support mutation | Does not approve/execute support action |
| No AI autonomous response | Does not send customer-facing AI output |
| No external publication | Does not publish partner-facing content |
| Testable as boundary | Can be tested as catalog/guardrail |
| Coding still separately approved | Requires later `CODING_ALLOWED` document |

---

## 5. Preferred First-Wave Guardrail Packages

The following package families are preferred as first-wave candidates:

| Package ID | Purpose | Risk Level |
|---|---|---|
| `foundation.i18n.message_catalog.v1` | Defines message key families | Low |
| `foundation.locale.audience_catalog.v1` | Defines locale/audience matrix | Low |
| `foundation.content.registry_catalog.v1` | Defines content key families | Low |
| `foundation.sop.traceability_catalog.v1` | Defines SOP source metadata requirements | Low |
| `foundation.contract.catalog.v1` | Defines planned API/RPC/event identifiers | Low |
| `foundation.provider.capability_registry.v1` | Defines provider capability statuses | Low |
| `foundation.audit.event_catalog.v1` | Defines audit event families | Low |
| `foundation.evidence.packet_catalog.v1` | Defines evidence packet families | Low |
| `foundation.security.visibility_catalog.v1` | Defines masking/data visibility classes | Low |
| `foundation.error.message_key_catalog.v1` | Defines error/message key mapping families | Low |
| `foundation.degraded.state_catalog.v1` | Defines degraded operation states | Low |
| `foundation.readiness.blocker_inventory.v1` | Tracks readiness blockers | Low |
| `foundation.package.handoff_record.v1` | Defines package handoff template | Low |
| `foundation.no_hardcoded_string_guard.v1` | Defines operational string guardrail | Low |

These are candidate guardrails only.

They are not yet approved for coding by this document.

---

## 6. Packages Excluded From First-Wave Entry

The following must not be included in the first foundation-first coding entry wave:

1. Live payment provider adapter
2. Payment authorization/capture implementation
3. Refund execution implementation
4. Settlement finalization implementation
5. Live KDS provider connector
6. POS-to-KDS live bridge
7. Provider webhook final-state mutation
8. Support/admin mutation console
9. Support refund execution screen
10. Customer-facing AI support automation
11. Production pgvector retrieval pipeline
12. AI prompt/tool production runtime
13. External menu publication adapter
14. Redtable-type partner adapter
15. Global payment bridge
16. Alipay/WeChat Pay/overseas card implementation
17. Google Maps-linked publishing
18. NFC/QR provider runtime
19. Customer identity sharing with partners
20. External projection rollback executor

These remain deferred until later readiness and evidence gates are satisfied.

---

## 7. i18n Guardrail Package Boundary

The i18n guardrail package may define:

- message key naming convention
- message key family catalog
- locale code policy
- fallback locale policy
- audience-specific message family
- error message key family
- payment message key family
- KDS message key family
- support message key family
- AI response key family
- provider status key family
- external projection message key family

The i18n package must not hardcode final operational messages into runtime surfaces.

It may define structure and placeholders.

Runtime text remains controlled through message/content registries.

---

## 8. Locale And Audience Catalog Boundary

The locale/audience catalog may define:

- supported locale candidates
- default locale
- fallback locale
- customer audience
- staff audience
- kitchen/KDS audience
- owner audience
- HQ audience
- support audience
- AI internal audience
- partner audience
- foreign tourist audience

The catalog must support future separation of wording, visibility, and authority by audience.

The same runtime fact must not be assumed to have one universal message.

---

## 9. Content Registry Guardrail Boundary

The content registry guardrail package may define content key families for:

- menu names
- menu descriptions
- option groups
- modifiers
- ingredients
- allergens
- support templates
- SOP-derived guidance
- training content
- customer support content
- AI approved response references
- external projection content
- provider capability labels
- degraded operation instructions

The package must preserve source traceability.

It must not publish runtime content or external projection.

---

## 10. SOP Traceability Guardrail Boundary

The SOP traceability package may define required metadata:

- source document id
- source section id
- source hash or version marker
- locale
- audience
- runtime boundary
- authority boundary
- actionability level
- evidence requirement
- fallback condition
- content registry linkage
- approval status
- effective date

The package must not transform SOP text into executable authority.

SOP-derived content remains guidance unless a runtime contract grants action authority.

---

## 11. Contract Catalog Guardrail Boundary

The contract catalog may define stable identifiers for:

- API contracts
- RPC contracts
- event contracts
- audit contracts
- provider callback contracts
- AI retrieval contracts
- content lookup contracts
- support/evidence contracts
- external projection contracts

The contract catalog must not implement handlers, functions, or mutations.

It only provides the controlled naming and dependency map for later implementation.

---

## 12. Provider Capability Registry Guardrail Boundary

The provider capability registry may define status values and evidence tracking fields.

Allowed capability statuses:

- `CAPABILITY_NOT_PLANNED`
- `CAPABILITY_PLANNED`
- `CAPABILITY_PROVIDER_EVIDENCE_REQUIRED`
- `CAPABILITY_CONFIRMED`
- `CAPABILITY_LIMITED`
- `CAPABILITY_REJECTED`
- `CAPABILITY_DEPRECATED`

The registry must default external claims to:

`CAPABILITY_PROVIDER_EVIDENCE_REQUIRED`

This includes Redtable-type partner modules, Alipay, WeChat Pay, overseas cards, Google Maps-linked projection, NFC/QR provider capability, and settlement conditions.

The registry must not imply provider integration exists.

---

## 13. Audit Event Catalog Guardrail Boundary

The audit event catalog may define audit families for:

- restricted data view
- unmasking
- evidence creation
- evidence attachment
- support action request
- support action approval
- refund approval
- refund execution
- override authority use
- provider capability status change
- external projection publication
- external projection rollback
- AI response approval
- content approval
- export/report action

The catalog must not implement audit storage or runtime triggers unless a later coding entry explicitly approves it.

---

## 14. Evidence Packet Catalog Guardrail Boundary

The evidence packet catalog may define evidence families such as:

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
- AI summary
- admin approval
- audit reference
- reconciliation reference

The package must distinguish original evidence from derived evidence.

AI summaries must remain derived evidence only.

---

## 15. Security Visibility Catalog Boundary

The security visibility catalog may define:

- public operational data
- customer masked data
- staff masked data
- payment masked data
- provider diagnostic data
- evidence-only data
- restricted full view
- legal review only data
- blocked data

The catalog may define masking classes and access review requirements.

It must not grant actual broad admin access.

---

## 16. Error Message Key Catalog Boundary

The error message key catalog may define:

- internal error code family
- user-facing message key family
- staff-facing message key family
- support diagnostic key family
- provider error mapping family
- severity family
- retryability family
- escalation family
- fallback instruction key family

Provider raw errors must not be shown directly to customers.

The catalog must preserve separation between internal diagnostics and customer-facing messages.

---

## 17. Degraded State Catalog Boundary

The degraded state catalog may define controlled state families such as:

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

Degraded state must not be hidden as normal operation.

---

## 18. Readiness And Blocker Inventory Boundary

The readiness/blocker inventory package may define tracking structures for:

- package id
- package family
- owner
- status
- primary blocker
- secondary blockers
- required resolution
- coding impact
- deferred status
- review owner
- evidence source
- next review step

This package must not approve coding.

It only makes readiness and blockers visible.

---

## 19. Package Handoff Record Boundary

The package handoff record may define a standard template for future coding entry.

The handoff record must include:

- package id
- owning runtime
- planning document references
- contract dependencies
- data dependencies
- UI/i18n dependencies
- content registry dependencies
- provider evidence dependencies
- audit/evidence requirements
- security requirements
- degraded behavior
- test requirements
- unresolved blockers
- explicit coding approval status

No implementation package should later proceed from informal memory.

---

## 20. No-Hardcoded-String Guardrail Boundary

The no-hardcoded-operational-string guardrail may define rules and future checks for preventing hardcoded runtime text.

The guardrail must apply to:

- UI
- API responses
- RPC error messages
- support messages
- payment/KDS statuses
- AI customer responses
- external projection text
- provider status labels
- degraded operation instructions
- training/SOP guidance

All runtime-visible operational text must resolve through message or content keys.

---

## 21. Test Boundary Planning

Foundation-first packages should include test planning intent.

Tests may later verify:

- message key existence
- content key existence
- contract id uniqueness
- provider status validity
- audit family validity
- evidence class validity
- visibility class validity
- degraded state validity
- no hardcoded operational strings
- no provider capability marked confirmed without evidence
- no customer-facing text without key
- no package marked coding-ready with unresolved blockers

This document does not implement tests.

It defines what future tests must protect.

---

## 22. Foundation Entry Status Categories

Foundation-first packages must use explicit status.

| Status | Meaning |
|---|---|
| `FOUNDATION_NOT_SELECTED` | Not selected for first entry review |
| `FOUNDATION_CANDIDATE` | Candidate for later entry review |
| `FOUNDATION_REVIEW_REQUIRED` | Needs architecture/security/i18n review |
| `FOUNDATION_BLOCKED` | Missing required planning detail |
| `FOUNDATION_READY_FOR_ENTRY_DECISION` | Ready for later coding entry decision |
| `FOUNDATION_CODING_ALLOWED` | Only after later explicit approval |

Default status:

`FOUNDATION_CANDIDATE`

This does not allow coding.

---

## 23. Foundation Entry Table Template

Foundation-first candidate packages should be reviewed using this table.

| Package ID | Guardrail Family | Purpose | Status | Blocker | Coding Status |
|---|---|---|---|---|---|
| `foundation.i18n.message_catalog.v1` | i18n | Define message key families | `FOUNDATION_CANDIDATE` | Review required | `CODING_DEFERRED` |
| `foundation.contract.catalog.v1` | Contract | Define contract identifiers | `FOUNDATION_CANDIDATE` | Review required | `CODING_DEFERRED` |
| `foundation.provider.capability_registry.v1` | Provider | Define capability statuses | `FOUNDATION_CANDIDATE` | Review required | `CODING_DEFERRED` |

This table is a planning artifact only.

---

## 24. Foundation-First Review Checklist

Before any foundation-first package is moved to a later coding entry decision, the following must be answered:

- Does this package reduce future implementation risk?
- Is runtime mutation excluded?
- Is customer-facing automation excluded?
- Is provider capability assumption excluded?
- Are i18n/content boundaries clear?
- Are audit/evidence boundaries clear?
- Are security/masking boundaries clear?
- Are degraded states represented if relevant?
- Are tests possible as boundary checks?
- Are open blockers listed?
- Is coding still deferred?
- Is later explicit approval still required?

If any answer is missing, the package remains candidate-only.

---

## 25. Relationship To Previous Documents

This document follows:

- `22390 Controlled Implementation Planning Closure And Coding Entry Deferral Policy`
- `22400 Controlled Implementation Readiness Review And Blocker Inventory Policy`
- `22410 Controlled Coding Entry Candidate Package Selection Policy`

This document prepares a foundation-first gate for a later controlled coding entry decision.

It does not authorize coding.

---

## 26. Final Rule

The first future implementation wave must not begin with high-authority runtime features.

It must begin, if approved later, with guardrails: i18n, content registry, contract catalog, provider capability registry, audit/evidence catalogs, visibility/masking catalogs, degraded state catalogs, readiness/blocker tracking, handoff templates, and no-hardcoded-string enforcement.

This document defines the foundation-first gate.

Coding remains deferred until a later explicit document grants `CODING_ALLOWED` to specific foundation packages.
