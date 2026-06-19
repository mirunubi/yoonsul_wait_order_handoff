# 009710_Policy_Controlled_Catalog_Registry_Handoff_And_Static_Reference_Package

## 1. Purpose

This document defines the controlled catalog registry handoff and static reference package policy after the non-runtime catalog schema planning policy.

The previous artifact `09700` defined how non-runtime catalog schemas may be planned without authorizing runtime implementation.

This document defines the next controlled handoff layer for a future static catalog registry package.

The purpose is to prepare a safe package that may later consolidate Foundation-controlled values into a static reference registry before any runtime trigger, monitoring view, daemon, pgvector ingestion, archive job, provider adapter, Catch & Order runtime, or Catch Menu customer surface is implemented.

This document is handoff-planning only.

It does not authorize coding.

---

## 2. Scope

This policy applies to a future static catalog registry package for:

1. Bulkhead IDs
2. Security classes
3. Control families
4. Control IDs
5. Containment statuses
6. Containment actions
7. Quarantine statuses
8. Quarantine actions
9. Event families
10. Alert families
11. Severity values
12. Route values
13. Error codes
14. Retryability classes
15. Evidence requirement values
16. Audit requirement values
17. Provider evidence statuses
18. AI output classes
19. pgvector source statuses
20. Retention tiers
21. Legal hold statuses
22. Deletion/anonymization statuses
23. Boundary test IDs
24. Catch & Order module candidates
25. Catch Menu surface/message class candidates

This document does not create files, tables, enums, migrations, seed data, code, or runtime registry services.

---

## 3. Core Principle

A static catalog registry is a controlled reference package.

It must centralize vocabulary.

It must not create behavior.

The correct rule is:

Registry values may describe allowed states.
Registry values may map relationships.
Registry values may support validation.
Registry values may support documentation consistency.
Registry values must not mutate runtime truth.

A static registry is a dictionary.

It is not an executor.

---

## 4. Catalog Header

| Field | Value |
|---|---|
| Document ID | `09710` |
| Package ID | `foundation.static_catalog_registry_handoff.v1` |
| Artifact Type | `CATALOG_REGISTRY_HANDOFF_POLICY` |
| Version | `v1` |
| Planning Status | `HANDOFF_DRAFT_CANDIDATE` |
| Coding Status | `CODING_DEFERRED` |
| Runtime Authority | `STATIC_REFERENCE_ONLY` |
| Owner | `Architecture / Documentation Governance / Security Foundation` |
| Dependencies | `09560` to `09700` |
| Provider Evidence Status | `CARRY_FORWARD_IF_PROVIDER_VALUES_INCLUDED` |
| i18n Requirement | `CARRY_FORWARD_IF_MESSAGE_KEYS_INCLUDED` |
| Audit Requirement | `REQUIRED_IF_REGISTRY_CHANGES_AFFECT_RUNTIME_ENTRY` |
| Security Requirement | `STATIC_REGISTRY_BOUNDARY_REQUIRED` |
| Review Requirement | `ARCHITECTURE_SECURITY_DATA_MODEL_REVIEW_REQUIRED` |
| Blocker Status | `STATIC_CATALOG_REGISTRY_HANDOFF_REVIEW_REQUIRED` |

---

## 5. Static Registry Definition

A static catalog registry is a controlled collection of stable keys and mappings extracted from approved planning documents.

It may include:

- key
- label
- description
- source document
- domain
- status
- owner
- related controls
- related tests
- related blockers
- authority boundary
- review requirement

It must not include:

- secrets
- personal data
- raw provider payloads
- raw customer records
- raw support notes
- payment credentials
- service role keys
- production endpoint secrets
- executable business logic
- mutation rules that bypass authority

---

## 6. Static Registry Candidate Package

Candidate package name:

`security_monitoring_catalog_registry_static_v1`

Purpose:

- collect stable Foundation vocabulary
- make later package handoffs consistent
- support validation matrix references
- support README/index consistency
- support future non-runtime schema review
- support later controlled implementation packages

Initial status:

`HANDOFF_DRAFT_CANDIDATE`

Coding status:

`CODING_DEFERRED`

---

## 7. Registry Boundary

The static registry may be used for:

- documentation consistency
- package handoff references
- validation matrix mapping
- design review
- provider evidence mapping
- Catch & Order module planning
- Catch Menu surface planning
- i18n key planning
- future schema planning

The static registry must not be used for:

- payment approval
- ledger mutation
- wallet/coupon/membership adjustment
- identity linking
- provider callback verification
- KDS ticket execution
- AI decision execution
- pgvector retrieval authority
- archive deletion
- legal hold release
- support case closure
- customer-facing runtime display without i18n review

---

## 8. Registry Source Document Map

| Registry Area | Source Document |
|---|---|
| Bulkheads | `09631` |
| Containment | `09632` |
| Quarantine | `09633` |
| Security controls | `09634` |
| Event and alert families | `09635` |
| Error codes | `09636` |
| Trigger signal fields | `09637` |
| Monitoring view types | `09638` |
| AI daemon outputs/rules | `09639` |
| pgvector source classes | `09640` |
| Retention/archive values | `09641` |
| Legal hold/delete/anonymize values | `09642` |
| Boundary tests | `09643` |
| Closure rules | `09645`, `09646` |
| Candidate selection | `09650` |
| Catch & Order modules | `09660` |
| Catch Menu surfaces/i18n | `09670` |
| Provider evidence values | `09680` |
| README/index status labels | `09690` |
| Catalog schema candidates | `09700` |

Registry values must preserve source traceability.

---

## 9. Registry Record Schema

Every registry record should include:

| Field | Required Meaning |
|---|---|
| `registry_id` | Stable registry id |
| `registry_family` | Bulkhead, control, event, error, etc. |
| `value_key` | Stable key |
| `value_label` | Human-readable label |
| `description` | Meaning |
| `domain` | Domain if applicable |
| `source_doc_id` | Source document |
| `source_section` | Source section if applicable |
| `status` | Draft, review, approved, deprecated |
| `authority_boundary` | What the value cannot do |
| `security_class` | Security class if applicable |
| `provider_evidence_status` | Provider status if applicable |
| `i18n_requirement` | i18n rule if visible |
| `related_controls` | Control references |
| `related_events` | Event family references |
| `related_alerts` | Alert family references |
| `related_error_codes` | Error code references |
| `related_tests` | Boundary test references |
| `related_blockers` | Blocker references |
| `review_owner` | Review route |
| `notes` | Controlled notes |

A registry record without `source_doc_id` is invalid.

---

## 10. Registry Family Catalog

| Registry Family | Meaning |
|---|---|
| `REGISTRY_BULKHEAD` | Bulkhead IDs and trust boundaries |
| `REGISTRY_SECURITY_CLASS` | Security classes |
| `REGISTRY_CONTROL` | Security control records |
| `REGISTRY_CONTAINMENT_STATUS` | Containment statuses |
| `REGISTRY_CONTAINMENT_ACTION` | Containment actions |
| `REGISTRY_QUARANTINE_STATUS` | Quarantine statuses |
| `REGISTRY_QUARANTINE_ACTION` | Quarantine actions |
| `REGISTRY_EVENT_FAMILY` | Event families |
| `REGISTRY_ALERT_FAMILY` | Alert families |
| `REGISTRY_ERROR_CODE` | Error codes |
| `REGISTRY_SEVERITY` | Severity values |
| `REGISTRY_ROUTE` | Alert/review routes |
| `REGISTRY_RETRYABILITY` | Retryability classes |
| `REGISTRY_EVIDENCE_REQUIREMENT` | Evidence requirement values |
| `REGISTRY_AUDIT_REQUIREMENT` | Audit requirement values |
| `REGISTRY_PROVIDER_EVIDENCE` | Provider evidence statuses |
| `REGISTRY_AI_BOUNDARY` | AI output/input classes |
| `REGISTRY_PGVECTOR_BOUNDARY` | Vector source/use classes |
| `REGISTRY_RETENTION` | Retention/archive values |
| `REGISTRY_LEGAL_HOLD` | Legal hold/delete/anonymize values |
| `REGISTRY_BOUNDARY_TEST` | Boundary test ids |
| `REGISTRY_CATCH_ORDER` | Catch & Order module/state/event candidates |
| `REGISTRY_CATCH_MENU` | Catch Menu surface/i18n/message candidates |
| `REGISTRY_BLOCKER` | Blocker ids |

---

## 11. Registry Status Catalog

| Status | Meaning |
|---|---|
| `REGISTRY_DRAFT` | Draft value |
| `REGISTRY_IMPORTED_FROM_FOUNDATION` | Imported from Foundation doc |
| `REGISTRY_REVIEW_REQUIRED` | Review required |
| `REGISTRY_APPROVED_FOR_PLANNING` | Approved for planning reference |
| `REGISTRY_APPROVED_FOR_STATIC_USE` | Approved for static reference use |
| `REGISTRY_RUNTIME_USE_NOT_AUTHORIZED` | Not authorized for runtime |
| `REGISTRY_REQUIRES_HANDOFF_FOR_RUNTIME` | Runtime use requires later handoff |
| `REGISTRY_PROVIDER_EVIDENCE_REQUIRED` | Provider evidence required |
| `REGISTRY_I18N_REVIEW_REQUIRED` | i18n/content review required |
| `REGISTRY_LEGAL_REVIEW_REQUIRED` | Legal review required |
| `REGISTRY_SECURITY_REVIEW_REQUIRED` | Security review required |
| `REGISTRY_DEPRECATED` | Deprecated |
| `REGISTRY_BLOCKED` | Blocked |

Default status:

`REGISTRY_RUNTIME_USE_NOT_AUTHORIZED`

---

## 12. Authority Boundary Field Rule

Each registry value must define what it does not authorize.

Examples:

| Registry Value Type | Authority Boundary |
|---|---|
| Bulkhead | Does not execute isolation by itself |
| Control | Does not enforce without implementation |
| Event family | Does not emit event by itself |
| Alert family | Does not notify by itself |
| Error code | Does not handle failure by itself |
| Containment status | Does not block by itself |
| Quarantine status | Does not isolate by itself |
| AI boundary | Does not call AI by itself |
| pgvector source class | Does not ingest vector by itself |
| Retention tier | Does not archive/delete by itself |
| Provider evidence status | Does not verify provider by itself |
| i18n key family | Does not create final copy by itself |
| Boundary test id | Does not run test by itself |

The registry is descriptive.

Runtime enforcement requires separate implementation.

---

## 13. Provider Evidence Carry-Forward

Provider-related registry values must include:

- provider evidence status
- provider category
- capability status
- evidence type if known
- security review status
- legal review status
- customer visibility class
- retryability class
- internal error mapping
- boundary tests

Default for provider capability values:

`CAPABILITY_PROVIDER_EVIDENCE_REQUIRED`

No registry value may mark provider capability as production verified without evidence package review.

---

## 14. i18n Carry-Forward

Customer-visible or support-visible registry values must include:

- message key family
- surface
- audience
- locale requirement
- customer visibility class
- fallback rule
- AI-generated text boundary
- content review owner
- legal review status if needed

Hardcoded visible text must not be placed in the registry as final production copy unless content/i18n review explicitly approves it.

---

## 15. AI And pgvector Carry-Forward

AI-related registry values must preserve:

- AI assistance-only boundary
- derived-output marking
- prohibited authority
- input source class
- output class
- audit requirement if high-risk

pgvector-related registry values must preserve:

- approved source requirement
- blocked source classes
- tenant/store scope
- traceability requirement
- lifecycle dependency
- deletion/anonymization dependency
- similarity-only boundary

Registry values must not enable AI/vector runtime.

---

## 16. Archive Legal Carry-Forward

Archive/legal registry values must preserve:

- retention tier
- legal hold status
- deletion candidate status
- anonymization candidate status
- manifest requirement
- checksum requirement
- secret scan requirement
- archive restore boundary
- pgvector dependency
- AI-derived dependency
- legal review requirement

Registry values must not perform archive migration, deletion, anonymization, or legal hold release.

---

## 17. Catch & Order Registry Boundary

Catch & Order registry values may include:

- module ids
- state family ids
- event family candidates
- error code candidates
- boundary labels
- provider dependency flags
- i18n dependency flags
- imported control references
- boundary test references

Catch & Order registry values must not:

- create runtime module
- create customer session
- send order to POS
- observe payment
- create KDS ticket
- mutate customer/order state
- execute provider integration

---

## 18. Catch Menu Registry Boundary

Catch Menu registry values may include:

- surface ids
- surface type ids
- message class ids
- i18n key families
- projection status values
- customer-safe status families
- prohibited content classes
- support handoff classes
- event/error candidates

Catch Menu registry values must not:

- publish customer UI
- display live menu
- create QR/NFC entry
- show customer-facing production text
- call provider
- create order
- mutate session
- publish external projection

---

## 19. Static Registry Change Control

A static registry change must record:

| Field | Meaning |
|---|---|
| `change_id` | Stable change id |
| `registry_family` | Affected family |
| `value_key` | Affected value |
| `change_type` | Add, update, deprecate, remove |
| `reason` | Reason |
| `source_doc_id` | Source document |
| `impact_summary` | Expected impact |
| `runtime_impact` | Whether runtime package may be affected later |
| `review_owner` | Reviewer |
| `review_status` | Review status |
| `effective_status` | Effective registry status |

Even static values may affect future runtime handoffs.

---

## 20. Registry Versioning Rule

Registry packages should define:

- registry package version
- value version
- source document version
- import date
- review date
- deprecated date if applicable
- replacement key if deprecated
- compatibility note
- migration note if future runtime exists

A value must not be silently renamed once referenced by later documents.

---

## 21. Registry File Layout Candidate

If a future coding handoff chooses file-based registry, candidate layout may be:

| Path Candidate | Purpose |
|---|---|
| `catalogs/security/bulkheads.*` | Bulkhead values |
| `catalogs/security/controls.*` | Security controls |
| `catalogs/security/containment.*` | Containment values |
| `catalogs/security/quarantine.*` | Quarantine values |
| `catalogs/security/events.*` | Event families |
| `catalogs/security/alerts.*` | Alert families |
| `catalogs/security/errors.*` | Error codes |
| `catalogs/security/routes.*` | Route values |
| `catalogs/security/tests.*` | Boundary tests |
| `catalogs/provider/evidence_status.*` | Provider evidence statuses |
| `catalogs/i18n/message_key_families.*` | i18n key families |
| `catalogs/catch_order/modules.*` | Catch & Order modules |
| `catalogs/catch_menu/surfaces.*` | Catch Menu surfaces |
| `catalogs/archive/retention.*` | Retention/archive values |
| `catalogs/ai/vector_boundaries.*` | AI/pgvector boundaries |

This is only a layout candidate.

No files are authorized.

---

## 22. Registry Database Layout Candidate

If a future coding handoff chooses database-backed registry, candidate table families may be:

| Table Family Candidate | Purpose |
|---|---|
| `catalog_registry_families` | Registry family definitions |
| `catalog_registry_values` | Generic value registry |
| `catalog_registry_relationships` | Value relationships |
| `catalog_registry_sources` | Source document references |
| `catalog_registry_reviews` | Review records |
| `catalog_registry_blockers` | Blocker mapping |
| `catalog_registry_tests` | Test mapping |
| `catalog_registry_i18n_refs` | i18n reference mapping |
| `catalog_registry_provider_refs` | Provider evidence mapping |

This is only a data-model candidate.

No tables are authorized.

---

## 23. Registry Validation Candidate

Future validation may check:

- every value has source document
- every value has registry family
- every value has authority boundary
- every provider value has evidence status
- every visible value has i18n requirement
- every AI/vector value has non-authority boundary
- every archive/legal value has lifecycle status
- every error code maps to event family
- every alert maps to route/severity
- every control maps to test
- every blocker maps to review owner
- deprecated keys have replacement or reason

Validation design is allowed only as planning.

---

## 24. Registry Prohibited Data

The static registry must not contain:

- real customer names
- real phone numbers
- real emails
- real payment identifiers
- provider secret keys
- service role keys
- JWTs
- OAuth secrets
- raw provider callbacks
- raw support notes
- HR sensitive data
- legal dispute details
- production credentials
- hidden test credentials
- environment secrets

Examples must use safe placeholders.

---

## 25. Handoff Readiness Conditions

A future static registry implementation handoff may be drafted only if:

- source documents are identified
- registry families are selected
- schema fields are defined
- file or database form is chosen
- non-runtime boundary is explicit
- prohibited data rule is included
- versioning rule is included
- review owners are defined
- boundary tests are mapped
- coding target files are declared
- rollback plan exists

This document does not satisfy coding entry by itself.

---

## 26. Readiness Blockers

| Blocker ID | Meaning |
|---|---|
| `BLOCKER-STATIC-REGISTRY-HANDOFF-0001` | Static registry handoff policy not reviewed |
| `BLOCKER-STATIC-REGISTRY-SOURCE-0001` | Source document map missing |
| `BLOCKER-STATIC-REGISTRY-SCHEMA-0001` | Registry record schema missing |
| `BLOCKER-STATIC-REGISTRY-FAMILY-0001` | Registry family catalog missing |
| `BLOCKER-STATIC-REGISTRY-AUTHORITY-0001` | Authority boundary missing |
| `BLOCKER-STATIC-REGISTRY-PROVIDER-0001` | Provider carry-forward missing |
| `BLOCKER-STATIC-REGISTRY-I18N-0001` | i18n carry-forward missing |
| `BLOCKER-STATIC-REGISTRY-AI-PGVECTOR-0001` | AI/pgvector carry-forward missing |
| `BLOCKER-STATIC-REGISTRY-ARCHIVE-LEGAL-0001` | Archive/legal carry-forward missing |
| `BLOCKER-STATIC-REGISTRY-PROHIBITED-DATA-0001` | Prohibited data rule missing |
| `BLOCKER-STATIC-REGISTRY-CODING-0001` | Coding not authorized |

Open blockers prevent static registry implementation.

---

## 27. Validation Checklist

Validation must confirm:

- static registry definition exists
- candidate package name exists
- registry boundary exists
- source document map exists
- registry record schema exists
- registry family catalog exists
- registry status catalog exists
- authority boundary field rule exists
- provider evidence carry-forward exists
- i18n carry-forward exists
- AI/pgvector carry-forward exists
- archive/legal carry-forward exists
- Catch & Order registry boundary exists
- Catch Menu registry boundary exists
- change control exists
- versioning rule exists
- file layout candidate is non-authorizing
- database layout candidate is non-authorizing
- validation candidate is planning-only
- prohibited data rule exists
- handoff readiness conditions exist
- coding remains deferred

---

## 28. Relationship To Previous Documents

This document follows:

- `09700 Controlled Non-Runtime Catalog Schema Planning Policy`

It references:

- `09560` through `09700`

It prepares later planning for:

- static catalog registry handoff
- boundary test matrix artifact
- provider evidence registry
- i18n message key registry
- Catch & Order module registry
- Catch Menu surface registry
- future non-runtime catalog implementation candidate

This document is static registry handoff planning only.

It does not authorize coding.

---

## 29. Final Rule

The static catalog registry may become the controlled vocabulary spine for the security monitoring Foundation, Catch & Order, Catch Menu, provider evidence, AI, pgvector, archive/legal, i18n, and boundary test packages.

However, the registry is descriptive, not executable.

It must preserve source documents, authority boundaries, provider evidence requirements, AI/pgvector non-authority, archive/legal lifecycle, i18n review, prohibited data rules, versioning, and review ownership.

No static registry implementation may proceed until a separate narrow handoff grants `CODING_ALLOWED`, declares target files or data structures, maps tests, resolves blockers, and defines rollback.
