# 09700_Policy_Controlled_Non_Runtime_Catalog_Schema_Planning

## 1. Purpose

This document defines the controlled non-runtime catalog schema planning policy after the Security Monitoring Foundation README and index patch policy.

The previous artifact `09690` defined how the Financial-Grade Security Monitoring Foundation should be referenced in READMEs, indexes, and future package maps.

This document defines how future catalog schemas may be planned without authorizing runtime implementation.

The goal is to prepare stable, reviewable, non-runtime catalog structures for:

- controls
- bulkheads
- containment statuses
- quarantine statuses
- event families
- alert families
- error codes
- severity values
- route values
- provider capability evidence
- i18n message key families
- boundary test ids
- archive manifest metadata
- pgvector source classes

This document is planning-only.

It does not authorize coding.

---

## 2. Scope

This policy applies to future non-runtime catalog planning for:

1. Security control catalog
2. Bulkhead catalog
3. Containment status catalog
4. Quarantine status catalog
5. Event family catalog
6. Alert family catalog
7. Error code catalog
8. Severity and routing catalog
9. Trigger signal packet schema catalog
10. Monitoring view contract catalog
11. AI daemon rule catalog
12. pgvector source class catalog
13. Retention and archive catalog
14. Legal hold and deletion review catalog
15. Provider evidence catalog
16. Catch & Order module catalog
17. Catch Menu surface and i18n catalog
18. Boundary test matrix catalog
19. Runtime handoff blocker catalog
20. Future Franchise OS integration catalog

This document does not implement actual database tables, migrations, seed files, JSON files, TypeScript types, Dart models, RPCs, triggers, views, or runtime workers.

---

## 3. Core Principle

A catalog schema is not runtime behavior.

A catalog schema defines controlled vocabulary and relationships.

The correct sequence is:

1. Define catalog meaning in documents.
2. Define catalog schema planning.
3. Review naming and relationships.
4. Map blockers and tests.
5. Create a narrow handoff if catalog files or tables will be created.
6. Only then allow implementation.

A catalog must not secretly become an executor.

---

## 4. Catalog Header

| Field | Value |
|---|---|
| Document ID | `09700` |
| Package ID | `foundation.non_runtime_catalog_schema_planning.v1` |
| Artifact Type | `NON_RUNTIME_CATALOG_SCHEMA_PLANNING_POLICY` |
| Version | `v1` |
| Planning Status | `FOUNDATION_CANDIDATE` |
| Coding Status | `CODING_DEFERRED` |
| Runtime Authority | `SCHEMA_PLANNING_ONLY` |
| Owner | `Architecture / Documentation Governance / Security Foundation` |
| Dependencies | `09560` to `09690` |
| Provider Evidence Status | `CARRY_FORWARD_IF_PROVIDER_CATALOG_INCLUDED` |
| i18n Requirement | `CARRY_FORWARD_IF_MESSAGE_KEY_CATALOG_INCLUDED` |
| Audit Requirement | `REQUIRED_FOR_RUNTIME_ENTRY_HANDOFF_REFERENCES` |
| Security Requirement | `NON_RUNTIME_CATALOG_BOUNDARY_REQUIRED` |
| Review Requirement | `ARCHITECTURE_SECURITY_DATA_MODEL_REVIEW_REQUIRED` |
| Blocker Status | `NON_RUNTIME_CATALOG_SCHEMA_REVIEW_REQUIRED` |

---

## 5. Non-Runtime Catalog Definition

A non-runtime catalog is a controlled reference set.

It may describe:

- allowed values
- prohibited values
- relationships between values
- severity mappings
- route mappings
- blocker mappings
- test mappings
- source-of-truth mappings
- authority restrictions
- i18n key families
- provider evidence statuses
- review requirements

A non-runtime catalog must not:

- execute business logic
- approve state changes
- mutate payment
- mutate ledger
- adjust membership/coupon/wallet value
- link identity
- release containment
- release quarantine
- call provider APIs
- call AI
- call pgvector
- archive/delete/anonymize records
- publish customer-facing messages
- bypass review

---

## 6. Catalog Implementation Forms

Future catalog implementation may take one or more forms, but only after explicit handoff.

Possible forms:

| Form | Meaning |
|---|---|
| Markdown table | Documentation-only catalog |
| YAML file | Structured config candidate |
| JSON file | Structured config candidate |
| CSV file | Portable reference catalog |
| Database table | Runtime-readable catalog, high review required |
| TypeScript enum | Application code reference, coding required |
| Dart enum/model | Flutter code reference, coding required |
| SQL enum/check | Database enforcement, high review required |
| Seed file | Controlled catalog loading, coding required |
| Admin UI registry | Runtime management surface, high review required |

This document does not choose an implementation form.

---

## 7. Catalog Schema Planning Rule

Every catalog schema plan must define:

| Field | Required Meaning |
|---|---|
| `catalog_id` | Stable catalog id |
| `catalog_name` | Human-readable name |
| `catalog_family` | Control, event, error, provider, i18n, etc. |
| `catalog_version` | Version |
| `catalog_status` | Draft, review, approved, deprecated |
| `value_key` | Stable value key |
| `display_name` | Human-readable name |
| `description` | Meaning |
| `domain` | Domain affected |
| `bulkhead_id` | Related bulkhead if applicable |
| `security_class` | Security class if applicable |
| `authority_boundary` | Authority rule |
| `related_controls` | Controls from `09634` |
| `related_events` | Event families from `09635` |
| `related_alerts` | Alert families from `09635` |
| `related_error_codes` | Error codes from `09636` |
| `related_tests` | Test ids from `09643` |
| `provider_evidence_status` | Provider status if applicable |
| `i18n_key_family` | Message key family if visible |
| `retention_class` | Retention class if applicable |
| `review_owner` | Review route |
| `blocker_id` | Blocker if incomplete |
| `notes` | Controlled notes |

A catalog value without authority boundary is incomplete.

---

## 8. Catalog Status Catalog

| Status | Meaning |
|---|---|
| `CATALOG_DRAFT` | Draft value |
| `CATALOG_REVIEW_REQUIRED` | Review required |
| `CATALOG_APPROVED_FOR_PLANNING` | Approved for planning reference |
| `CATALOG_APPROVED_FOR_NON_RUNTIME_USE` | Approved for non-runtime use |
| `CATALOG_RUNTIME_USE_NOT_AUTHORIZED` | Not approved for runtime |
| `CATALOG_RUNTIME_USE_REQUIRES_HANDOFF` | Runtime use requires handoff |
| `CATALOG_DEPRECATED` | Deprecated |
| `CATALOG_BLOCKED` | Blocked |
| `CATALOG_PROVIDER_EVIDENCE_REQUIRED` | Provider evidence required |
| `CATALOG_LEGAL_REVIEW_REQUIRED` | Legal review required |
| `CATALOG_SECURITY_REVIEW_REQUIRED` | Security review required |

Default status:

`CATALOG_RUNTIME_USE_NOT_AUTHORIZED`

---

## 9. Security Control Catalog Schema Candidate

Candidate fields:

| Field | Meaning |
|---|---|
| `control_id` | Stable control id |
| `control_family` | Control family |
| `control_name` | Name |
| `security_class` | Security class |
| `bulkhead_id` | Affected bulkhead |
| `allowed_outcome` | Allowed result |
| `prohibited_outcome` | Prohibited result |
| `evidence_required` | Evidence requirement |
| `audit_required` | Audit requirement |
| `related_error_codes` | Related error codes |
| `related_tests` | Boundary tests |
| `blocker_id` | Blocker if missing |
| `status` | Catalog status |

Source reference:

- `09634 Security Control Records And Security Class Catalog`

---

## 10. Bulkhead Catalog Schema Candidate

Candidate fields:

| Field | Meaning |
|---|---|
| `bulkhead_id` | Stable bulkhead id |
| `bulkhead_name` | Name |
| `domain` | Domain |
| `protected_assets` | Assets protected |
| `source_of_truth_type` | Source-of-truth classification |
| `trust_level` | Trust level |
| `allowed_inbound` | Allowed inbound |
| `allowed_outbound` | Allowed outbound |
| `prohibited_propagation` | Prohibited propagation |
| `default_containment_rule` | Default containment rule |
| `default_quarantine_rule` | Default quarantine rule |
| `related_tests` | Boundary tests |
| `status` | Catalog status |

Source reference:

- `09631 Bulkhead Domain Map Source Of Truth And Trust Boundary Catalog`

---

## 11. Containment Catalog Schema Candidate

Candidate fields:

| Field | Meaning |
|---|---|
| `containment_status` | Controlled status |
| `containment_action` | Controlled action |
| `domain` | Domain |
| `bulkhead_id` | Affected bulkhead |
| `trigger_event_family` | Triggering event family |
| `trigger_error_code` | Triggering error code |
| `severity` | Severity |
| `release_authority` | Who may release |
| `evidence_required` | Evidence requirement |
| `audit_required` | Audit requirement |
| `customer_visibility` | Customer visibility |
| `related_tests` | Boundary tests |
| `status` | Catalog status |

Source reference:

- `09632 Containment Status And Trigger Map Catalog`

---

## 12. Quarantine Catalog Schema Candidate

Candidate fields:

| Field | Meaning |
|---|---|
| `quarantine_status` | Controlled status |
| `quarantine_action` | Controlled action |
| `domain` | Domain |
| `target_object_type` | Object being quarantined |
| `trigger_event_family` | Triggering event family |
| `trigger_error_code` | Triggering error code |
| `release_authority` | Who may release |
| `reject_authority` | Who may reject |
| `evidence_required` | Evidence requirement |
| `audit_required` | Audit requirement |
| `mutation_allowed` | Must default false |
| `related_tests` | Boundary tests |
| `status` | Catalog status |

Source reference:

- `09633 Quarantine Status And Trigger Map Catalog`

---

## 13. Event Alert Catalog Schema Candidate

Candidate fields:

| Field | Meaning |
|---|---|
| `event_family` | Event family id |
| `alert_family` | Alert family id |
| `domain` | Domain |
| `bulkhead_id` | Affected bulkhead |
| `default_severity` | Severity |
| `route` | Alert route |
| `evidence_required` | Evidence requirement |
| `audit_required` | Audit requirement |
| `customer_visibility` | Customer visibility |
| `i18n_key_family` | Message key family |
| `pgvector_eligibility` | Vector eligibility |
| `ai_summary_eligibility` | AI eligibility |
| `related_tests` | Boundary tests |
| `status` | Catalog status |

Source reference:

- `09635 Security Event Alert Families And Severity Routing Catalog`

---

## 14. Error Code Catalog Schema Candidate

Candidate fields:

| Field | Meaning |
|---|---|
| `error_code` | Stable error code |
| `domain` | Domain |
| `error_family` | Error family |
| `detail` | Error detail |
| `severity` | Severity |
| `related_event_family` | Event mapping |
| `related_alert_family` | Alert mapping |
| `retryability` | Retry class |
| `idempotency_impact` | Idempotency impact |
| `containment_candidate` | Containment candidate |
| `quarantine_candidate` | Quarantine candidate |
| `reconciliation_candidate` | Reconciliation candidate |
| `customer_visibility` | Customer visibility |
| `i18n_key_family` | Message key family |
| `related_tests` | Boundary tests |
| `status` | Catalog status |

Source reference:

- `09636 Unix-Style Error Code Catalog And Domain Fault Mapping Policy`

---

## 15. Provider Evidence Catalog Schema Candidate

Candidate fields:

| Field | Meaning |
|---|---|
| `provider_id` | Provider id |
| `provider_name` | Provider name |
| `provider_category` | Provider category |
| `capability_id` | Capability id |
| `capability_name` | Capability name |
| `capability_status` | Evidence status |
| `evidence_type` | Evidence type |
| `evidence_ref` | Evidence reference |
| `sandbox_status` | Sandbox test status |
| `production_status` | Production confirmation status |
| `security_review_status` | Security review |
| `legal_review_status` | Legal review |
| `authority_class` | Authority classification |
| `failure_modes` | Failure modes |
| `internal_error_mapping` | Internal error mapping |
| `customer_visibility` | Customer visibility |
| `related_tests` | Boundary tests |
| `blocker_id` | Blocker |
| `status` | Catalog status |

Source reference:

- `09680 Provider Evidence Collection Template And Capability Review Policy`

---

## 16. i18n Message Key Catalog Schema Candidate

Candidate fields:

| Field | Meaning |
|---|---|
| `message_key` | Stable i18n key |
| `surface` | Catch Menu, Catch & Order, support, admin, etc. |
| `domain` | Domain |
| `message_class` | Status, error, warning, recovery, legal, etc. |
| `customer_visible` | Whether customer visible |
| `support_visible` | Whether support visible |
| `locale` | Locale |
| `source_text_status` | Draft/review/approved |
| `translation_status` | Translation status |
| `ai_generated` | Whether AI generated |
| `content_review_status` | Content review |
| `legal_review_status` | Legal review if needed |
| `related_event_family` | Event mapping |
| `related_error_code` | Error mapping |
| `fallback_key` | Fallback key |
| `status` | Catalog status |

Source references:

- `09670 Catch Menu Customer Surface Projection And i18n Naming Policy`
- `09635 Security Event Alert Families And Severity Routing Catalog`

---

## 17. Boundary Test Catalog Schema Candidate

Candidate fields:

| Field | Meaning |
|---|---|
| `test_id` | Stable test id |
| `test_family` | Test family |
| `target_domain` | Domain |
| `related_control` | Control id |
| `related_bulkhead` | Bulkhead id |
| `expected_result` | Expected safe result |
| `failure_meaning` | Failure meaning |
| `required_evidence` | Evidence required |
| `review_owner` | Review owner |
| `blocker_if_failed` | Blocker id |
| `coding_entry_impact` | Block/allow/defer |
| `status` | Test status |

Source reference:

- `09643 Boundary Test Checklist And Security Monitoring Validation Matrix`

---

## 18. Archive Manifest Catalog Schema Candidate

Candidate fields:

| Field | Meaning |
|---|---|
| `manifest_id` | Manifest id |
| `archive_object_id` | Archive object id |
| `archive_name` | Archive name |
| `domain` | Domain |
| `log_class` | Log/evidence/audit class |
| `scope` | Tenant/store/provider/legal scope |
| `source_start_at` | Source range start |
| `source_end_at` | Source range end |
| `source_record_count` | Record count |
| `checksum` | Checksum |
| `checksum_method` | Checksum method |
| `secret_scan_status` | Secret scan status |
| `retention_tier` | Retention tier |
| `legal_hold_status` | Legal hold status |
| `pgvector_dependency_status` | Vector dependency |
| `retrieval_policy` | Retrieval policy |
| `restore_policy` | Restore boundary |
| `status` | Catalog status |

Source reference:

- `09641 Retention Tier Archive Naming Manifest And Lifecycle Catalog`

---

## 19. pgvector Source Catalog Schema Candidate

Candidate fields:

| Field | Meaning |
|---|---|
| `vector_source_id` | Vector source id |
| `source_domain` | Source domain |
| `source_object_type` | Source object type |
| `source_object_id` | Source reference |
| `source_version` | Version |
| `tenant_id_scope` | Tenant scope rule |
| `store_id_scope` | Store scope rule |
| `visibility_class` | Visibility class |
| `source_integrity_status` | Source integrity |
| `vectorization_status` | Vectorization status |
| `allowed_use` | Allowed use |
| `prohibited_use` | Prohibited use |
| `retention_class` | Retention class |
| `legal_hold_status` | Legal hold status |
| `deletion_dependency` | Deletion dependency |
| `refresh_rule` | Refresh rule |
| `status` | Catalog status |

Source reference:

- `09640 pgvector Approved Source Traceability Lifecycle And Authority Boundary Catalog`

---

## 20. Catch & Order Catalog Schema Candidate

Candidate fields:

| Field | Meaning |
|---|---|
| `module_id` | Catch & Order module id |
| `module_name` | Module name |
| `module_boundary` | Boundary description |
| `state_family` | State family |
| `event_family` | Event family |
| `error_code` | Error code |
| `authority_boundary` | Authority rule |
| `provider_dependency` | Provider dependency |
| `i18n_dependency` | i18n dependency |
| `security_controls` | Imported controls |
| `related_tests` | Boundary tests |
| `coding_status` | Coding status |
| `status` | Catalog status |

Source reference:

- `09660 Catch & Order SaaS Runtime Boundary And Module Naming Policy`

---

## 21. Catch Menu Catalog Schema Candidate

Candidate fields:

| Field | Meaning |
|---|---|
| `surface_id` | Surface id |
| `surface_type` | QR, NFC, table, menu, status, etc. |
| `message_class` | Message class |
| `projection_source` | Approved source |
| `i18n_key_family` | i18n key family |
| `price_boundary` | Price rule |
| `allergen_boundary` | Allergen rule |
| `availability_boundary` | Availability rule |
| `customer_visibility` | Customer visibility |
| `ai_text_boundary` | AI visible text rule |
| `support_handoff_rule` | Support handoff rule |
| `related_tests` | Boundary tests |
| `coding_status` | Coding status |
| `status` | Catalog status |

Source reference:

- `09670 Catch Menu Customer Surface Projection And i18n Naming Policy`

---

## 22. Non-Runtime Relationship Rules

Catalog schemas may reference each other.

Recommended relationships:

- error code maps to event family
- event family maps to alert family
- alert family maps to route and severity
- control maps to bulkhead
- bulkhead maps to source-of-truth type
- containment maps to event/error
- quarantine maps to event/error
- provider capability maps to error/failure/retryability
- i18n key maps to visible event/error/status
- test maps to control and blocker
- archive manifest maps to retention/legal/vector dependency
- vector source maps to archive/legal/source lifecycle
- Catch & Order module maps to Foundation controls
- Catch Menu surface maps to i18n and projection source

Relationships must not create runtime authority.

---

## 23. Non-Runtime Data Safety Rule

Catalog values must not contain:

- service role keys
- provider secrets
- API tokens
- raw customer identity
- payment secrets
- raw provider callback payloads
- raw support notes
- legal hold sensitive content
- HR sensitive identifiers
- personal phone/email/name values
- production URLs with secrets
- hidden credentials in examples

Catalog samples must use safe placeholders.

---

## 24. Catalog Versioning Rule

Each catalog must define versioning.

Recommended fields:

- catalog version
- value version
- effective status
- deprecated status
- replacement value
- review date
- review owner
- reason for change
- backward compatibility note
- runtime impact note

Catalog value changes may affect runtime behavior later, so changes must be reviewed.

---

## 25. Catalog Review Rule

Catalog review must include:

- architecture review
- security review
- data model review
- provider review if provider-related
- i18n/content review if visible
- legal review if legal/identity/archive-related
- AI governance review if AI/vector-related
- QA review if boundary-test-related

A catalog may be planning-approved without runtime approval.

---

## 26. Catalog To Runtime Handoff Rule

A catalog schema may enter runtime implementation only through a later handoff that defines:

- exact implementation form
- target files
- target database schema if any
- migration/seed plan if any
- test plan
- rollback plan
- ownership
- runtime read/write behavior
- whether catalog is read-only or admin-editable
- audit requirement for catalog changes
- deployment scope
- coding status

This document does not provide that handoff.

---

## 27. Catalog Admin Editability Rule

If a future catalog becomes admin-editable, it becomes higher risk.

Admin-editable catalog must define:

- who can edit
- what can be edited
- approval workflow
- audit event
- rollback
- effective date
- tenant/store/global scope
- runtime impact preview
- conflict detection
- publication rule
- emergency override boundary

Static catalogs are preferred before admin-editable catalogs.

---

## 28. Readiness Blockers

| Blocker ID | Meaning |
|---|---|
| `BLOCKER-NON-RUNTIME-CATALOG-0001` | Non-runtime catalog schema policy not reviewed |
| `BLOCKER-CATALOG-SCHEMA-0001` | Catalog schema fields missing |
| `BLOCKER-CATALOG-STATUS-0001` | Catalog status missing |
| `BLOCKER-CATALOG-AUTHORITY-0001` | Authority boundary missing |
| `BLOCKER-CATALOG-RELATIONSHIP-0001` | Relationship rules missing |
| `BLOCKER-CATALOG-DATA-SAFETY-0001` | Data safety rule missing |
| `BLOCKER-CATALOG-VERSIONING-0001` | Versioning rule missing |
| `BLOCKER-CATALOG-REVIEW-0001` | Review rule missing |
| `BLOCKER-CATALOG-RUNTIME-HANDOFF-0001` | Runtime handoff missing |
| `BLOCKER-CATALOG-ADMIN-EDIT-0001` | Admin editability rule missing |
| `BLOCKER-CATALOG-CODING-0001` | Coding not authorized |

Open blockers prevent catalog implementation.

---

## 29. Validation Checklist

Validation must confirm:

- non-runtime catalog definition exists
- catalog implementation forms are listed
- catalog schema planning rule exists
- catalog status catalog exists
- security control schema candidate exists
- bulkhead schema candidate exists
- containment schema candidate exists
- quarantine schema candidate exists
- event/alert schema candidate exists
- error code schema candidate exists
- provider evidence schema candidate exists
- i18n message key schema candidate exists
- boundary test schema candidate exists
- archive manifest schema candidate exists
- pgvector source schema candidate exists
- Catch & Order schema candidate exists
- Catch Menu schema candidate exists
- relationship rules exist
- data safety rule exists
- versioning rule exists
- review rule exists
- runtime handoff rule exists
- admin editability rule exists
- coding remains deferred

---

## 30. Relationship To Previous Documents

This document follows:

- `09690 Security Monitoring Foundation README Insert And Index Patch Policy`

It references:

- `09560` through `09690`

It prepares later planning for:

- controlled catalog registry handoff
- boundary test matrix artifact
- provider evidence registry
- i18n message key catalog
- Catch & Order module catalog
- Catch Menu surface catalog
- non-runtime schema implementation candidate

This document is non-runtime catalog schema planning only.

It does not authorize coding.

---

## 31. Final Rule

Catalog schema planning is not runtime implementation.

A catalog defines controlled vocabulary, relationships, authority boundaries, review ownership, and blockers.

It must not execute business logic, mutate operational truth, approve financial/value/identity/provider/support actions, call AI, call pgvector, archive/delete/anonymize data, or publish customer-visible messages.

Any future catalog implementation requires a separate narrow handoff with explicit target files, data scope, tests, rollback plan, review owner, and `CODING_ALLOWED` decision.

Coding remains deferred.
