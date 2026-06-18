# 021650_Policy_Controlled_Implementation_Candidate_Selection_And_Package_Prioritization

## 1. Purpose

This document defines the controlled implementation candidate selection and package prioritization policy after completion of the Financial-Grade Security Monitoring Foundation Package post-closure direction.

The previous artifact `21646` established that the security monitoring Foundation may be used as a reference spine, but does not authorize coding.

This document defines how future implementation candidates should be selected, ranked, narrowed, delayed, or rejected.

The purpose is to prevent broad, unsafe implementation requests such as:

- implement security monitoring
- implement AI daemon
- implement pgvector
- implement archive
- implement provider integration
- implement POS monitoring
- implement Catch & Order

Those requests are too broad.

Future implementation must be selected as narrow packages with clear scope, imported Foundation rules, boundary tests, blocker resolution, and explicit `CODING_ALLOWED` approval.

This document is planning-only.

It does not authorize coding.

---

## 2. Scope

This policy applies to future candidate packages related to:

1. Security monitoring catalog schema
2. Event/alert/error code registry
3. Trigger Signal Audit Packet storage
4. Monitoring view projections
5. Rule-only daemon prototype
6. pgvector approved-source registry
7. Archive manifest schema
8. Legal hold review state catalog
9. Provider evidence collection
10. POS/payment/provider handoff observation
11. KDS/order mismatch observation
12. Support/admin review surface
13. Catch & Order SaaS runtime boundary
14. Catch Menu customer surface projection
15. Boundary test matrix generation
16. Patent evidence packet preparation

This document does not implement any package.

---

## 3. Core Principle

Implementation priority must follow risk reduction, not excitement.

The correct order is:

1. Define static catalogs.
2. Define read-only records.
3. Define append-only evidence.
4. Define validation tests.
5. Define read-only projections.
6. Define deterministic rules.
7. Only then consider AI/pgvector.
8. Only then consider containment/quarantine executors.
9. Only then consider customer-facing surfaces.
10. Only then consider full SaaS runtime.

A package that mutates money, identity, value, provider state, archive state, or customer-visible state must be later than read-only and catalog packages.

---

## 4. Catalog Header

| Field | Value |
|---|---|
| Document ID | `21650` |
| Package ID | `foundation.security_monitoring.implementation_selection.v1` |
| Artifact Type | `IMPLEMENTATION_SELECTION_POLICY` |
| Version | `v1` |
| Planning Status | `FOUNDATION_CANDIDATE` |
| Coding Status | `CODING_DEFERRED` |
| Runtime Authority | `SELECTION_POLICY_ONLY` |
| Owner | `Architecture / Program Governance / Security Foundation` |
| Dependencies | `21560` to `21646` |
| Provider Evidence Status | `CARRY_FORWARD_REQUIRED` |
| i18n Requirement | `APPLIES_IF_VISIBLE_SURFACE_SELECTED` |
| Audit Requirement | `REQUIRED_FOR_CODING_ENTRY_APPROVAL` |
| Security Requirement | `NARROW_PACKAGE_SELECTION_REQUIRED` |
| Review Requirement | `ARCHITECTURE_SECURITY_PROGRAM_REVIEW_REQUIRED` |
| Blocker Status | `IMPLEMENTATION_SELECTION_REVIEW_REQUIRED` |

---

## 5. Candidate Selection Status Catalog

| Status | Meaning |
|---|---|
| `CANDIDATE_NOT_SELECTED` | Candidate exists but not selected |
| `CANDIDATE_SELECTED_FOR_PLANNING` | Selected for planning only |
| `CANDIDATE_READY_FOR_HANDOFF_DRAFT` | Ready to draft handoff |
| `CANDIDATE_BLOCKED` | Blocked by dependency |
| `CANDIDATE_DEFERRED` | Deferred with reason |
| `CANDIDATE_REJECTED_AS_TOO_BROAD` | Rejected because scope is too broad |
| `CANDIDATE_REQUIRES_PROVIDER_EVIDENCE` | Provider evidence required |
| `CANDIDATE_REQUIRES_LEGAL_REVIEW` | Legal/compliance review required |
| `CANDIDATE_REQUIRES_SECURITY_REVIEW` | Security review required |
| `CANDIDATE_REQUIRES_AI_GOVERNANCE` | AI governance review required |
| `CANDIDATE_REQUIRES_DATA_GOVERNANCE` | Data governance review required |
| `CANDIDATE_HANDOFF_REQUIRED` | Handoff required before coding |
| `CODING_NOT_AUTHORIZED` | Coding not authorized |
| `CODING_ALLOWED_BY_SEPARATE_DECISION_ONLY` | Coding possible only by later approval |

Default status for all candidates:

`CODING_NOT_AUTHORIZED`

---

## 6. Candidate Evaluation Criteria

Each implementation candidate must be evaluated against:

| Criterion | Question |
|---|---|
| Narrowness | Is the package small enough to review safely? |
| Runtime Risk | Does it mutate runtime truth? |
| Security Risk | Does it touch restricted domains? |
| Value Risk | Does it affect payment, ledger, wallet, coupon, membership, or settlement? |
| Identity Risk | Does it affect customer/staff identity or consent? |
| Provider Risk | Does it rely on unverified provider capability? |
| AI Risk | Does it involve AI output or model calls? |
| pgvector Risk | Does it ingest or retrieve vector data? |
| Archive Risk | Does it archive, delete, restore, or anonymize data? |
| i18n Risk | Does it create visible messages? |
| Testability | Are boundary tests defined? |
| Reversibility | Can the change be rolled back safely? |
| Dependency Completeness | Are imported Foundation artifacts mapped? |
| Business Value | Does it unlock important future work? |
| Sequencing | Does it belong before or after safer packages? |

If narrowness and testability fail, the package must not enter coding.

---

## 7. Priority Score Model

A simple planning score may be used.

| Dimension | Score Meaning |
|---|---|
| Risk Reduction | Higher if package reduces critical operational risk |
| Foundation Dependency | Higher if later packages depend on it |
| Low Mutation Risk | Higher if read-only/catalog-only |
| Testability | Higher if easy to test |
| Reversibility | Higher if easy to rollback |
| Provider Independence | Higher if no provider evidence needed |
| AI Independence | Higher if no AI governance needed |
| Legal Simplicity | Higher if no legal deletion/identity issue |
| Business Enablement | Higher if it unlocks Catch & Order / Catch Menu safely |

Priority should favor high enablement with low mutation risk.

---

## 8. Candidate Package Ranking

Initial recommended ranking:

| Rank | Candidate Package | Reason | Status |
|---|---|---|---|
| 1 | `security_monitoring_catalog_registry_v1` | Static registry for controls, events, alerts, error codes | `CANDIDATE_SELECTED_FOR_PLANNING` |
| 2 | `boundary_test_matrix_artifact_v1` | Converts `21643` into executable/reviewable matrix later | `CANDIDATE_SELECTED_FOR_PLANNING` |
| 3 | `provider_evidence_collection_template_v1` | Needed before provider-specific assumptions | `CANDIDATE_SELECTED_FOR_PLANNING` |
| 4 | `archive_manifest_schema_planning_v1` | Non-mutating archive metadata foundation | `CANDIDATE_SELECTED_FOR_PLANNING` |
| 5 | `pgvector_source_registry_planning_v1` | Source registry before vector ingestion | `CANDIDATE_SELECTED_FOR_PLANNING` |
| 6 | `trigger_signal_packet_schema_planning_v1` | Append-only signal shape before triggers | `CANDIDATE_READY_FOR_HANDOFF_DRAFT` |
| 7 | `monitoring_view_contract_planning_v1` | Read-only projection before daemon | `CANDIDATE_READY_FOR_HANDOFF_DRAFT` |
| 8 | `catch_order_runtime_boundary_planning_v1` | SaaS boundary planning before runtime | `CANDIDATE_SELECTED_FOR_PLANNING` |
| 9 | `catch_menu_surface_projection_planning_v1` | Customer surface planning before UI | `CANDIDATE_SELECTED_FOR_PLANNING` |
| 10 | `daemon_rule_only_planning_v1` | Deterministic rule-only planning before AI | `CANDIDATE_DEFERRED` |
| 11 | `pgvector_ingestion_mvp_v1` | Requires source registry and lifecycle tests first | `CANDIDATE_DEFERRED` |
| 12 | `ai_daemon_mvp_v1` | Requires deterministic rule layer and governance first | `CANDIDATE_DEFERRED` |
| 13 | `containment_executor_mvp_v1` | High-risk runtime executor | `CANDIDATE_DEFERRED` |
| 14 | `quarantine_processor_mvp_v1` | High-risk runtime processor | `CANDIDATE_DEFERRED` |

Ranking is planning-only.

It does not authorize coding.

---

## 9. First Safe Candidate: Static Catalog Registry

Recommended first candidate:

`security_monitoring_catalog_registry_v1`

Purpose:

- represent security controls
- represent bulkhead ids
- represent event families
- represent alert families
- represent error codes
- represent severity values
- represent route values
- represent blocker values
- represent test ids

Why first:

- low mutation risk
- no provider dependency
- no AI dependency
- no pgvector dependency
- no customer-facing message dependency
- supports later validation
- creates controlled vocabulary for future packages

Still not authorized for coding by this document.

---

## 10. Second Safe Candidate: Boundary Test Matrix Artifact

Recommended second candidate:

`boundary_test_matrix_artifact_v1`

Purpose:

- turn checklist from `21643` into package-specific validation matrix
- define required evidence
- define review owner
- define pass/fail/defer status
- connect blockers to tests
- prevent implementation without validation

Why early:

- protects future runtime
- prevents scope drift
- makes “coding allowed” harder to misuse
- supports architecture/security review

This may be a document artifact before any executable test.

---

## 11. Third Safe Candidate: Provider Evidence Collection Template

Recommended third candidate:

`provider_evidence_collection_template_v1`

Purpose:

- collect provider capability evidence
- document callback behavior
- document payment/refund/settlement behavior
- document failure behavior
- document sandbox/production differences
- document contract/legal limits

Why early:

- provider claims remain unverified
- POS/payment/global payment integrations depend on evidence
- prevents false assumptions
- supports Catch & Order SaaS credibility

This is especially important before Redtable, Toss, global payment, POS vendor, or map/NFC/QR assumptions are treated as verified.

---

## 12. Fourth Safe Candidate: Archive Manifest Schema Planning

Recommended fourth candidate:

`archive_manifest_schema_planning_v1`

Purpose:

- define manifest fields
- define checksum/secret-scan fields
- define legal hold fields
- define pgvector dependency fields
- define retrieval audit fields
- define archive naming rules

Why early:

- non-mutating
- helps later evidence retention
- supports legal/security review
- protects logs and incident records

This should remain schema-planning or config-planning before archive jobs are built.

---

## 13. Fifth Safe Candidate: pgvector Source Registry Planning

Recommended fifth candidate:

`pgvector_source_registry_planning_v1`

Purpose:

- define approved source types
- define blocked source types
- define traceability fields
- define visibility classes
- define lifecycle dependency
- define deletion/anonymization dependency
- define prohibited-use rules

Why early:

- vector ingestion must not start without source registry
- prevents raw sensitive data ingestion
- preserves AI/pgvector non-authority boundary
- supports future daemon and support review

This package must not create vector ingestion yet.

---

## 14. Trigger Signal Candidate Sequencing

`trigger_signal_packet_schema_planning_v1` may be considered after static catalogs.

Allowed planning focus:

- packet schema
- allowed metadata
- hash/reference fields
- evidence/audit flags
- retention class
- AI/pgvector eligibility flags
- append-only rule

Not allowed yet:

- live database triggers
- provider callback hooks
- payment mutation hooks
- ledger mutation hooks
- AI calls
- pgvector calls
- notification workers

Trigger implementation must be later and narrow.

---

## 15. Monitoring View Candidate Sequencing

`monitoring_view_contract_planning_v1` may follow trigger signal planning.

Allowed planning focus:

- view names
- input signal fields
- output safe fields
- masking rules
- tenant/store scope
- freshness status
- failure alert rules
- risk projection formula placeholder

Not allowed yet:

- production SQL views
- unrestricted raw table scans
- materialized view refresh jobs
- daemon execution
- AI/vector ingestion

Read-only must remain explicit.

---

## 16. Catch & Order Candidate Sequencing

`Catch & Order / 캐치앤오더` should be planned as a SaaS module after Foundation reference is stable.

Initial planning should focus on:

- tenant boundary
- store boundary
- menu access to order handoff
- order to POS boundary
- POS to payment boundary
- POS to KDS boundary
- provider evidence boundary
- customer session identity boundary
- support/customer recovery boundary
- event/error/alert mapping
- i18n visible message key mapping

Not allowed yet:

- full SaaS runtime
- external provider mutation
- payment state mutation
- automatic settlement logic
- AI support runtime
- pgvector runtime
- customer-facing production UI

Catch & Order planning should start with boundary, not screens.

---

## 17. Catch Menu Candidate Sequencing

`Catch Menu / 캐치메뉴` should be planned as a customer-facing menu access surface.

Initial planning should focus on:

- menu projection source
- customer QR/NFC entry
- locale/i18n keys
- menu availability
- allergen visibility
- price visibility
- order entry handoff if integrated
- external projection safety
- customer-safe error messages
- fallback text

Not allowed yet:

- live customer production surface
- unapproved AI-generated menu text
- unverified payment capability display
- unverified provider integration display
- hardcoded operational visible strings

Catch Menu must remain simple externally, but controlled internally.

---

## 18. Deferred Candidate: Rule-Only Daemon

`daemon_rule_only_planning_v1` should be deferred until:

- catalog registry exists
- boundary test matrix exists
- trigger signal planning exists
- monitoring view planning exists
- error/event/alert codes are structured
- daemon input sources are approved
- audit requirement is clear

Rule-only daemon is safer than AI daemon, but still runtime-sensitive.

No daemon runtime should be implemented before read-only signals and views exist.

---

## 19. Deferred Candidate: pgvector Ingestion MVP

`pgvector_ingestion_mvp_v1` should be deferred until:

- source registry exists
- blocked sources are validated
- redaction rules exist
- deletion/anonymization lifecycle exists
- legal hold interaction exists
- AI consumption boundary exists
- tenant/store retrieval boundary exists
- boundary tests exist

Vector ingestion before governance is unsafe.

---

## 20. Deferred Candidate: AI Daemon MVP

`ai_daemon_mvp_v1` should be deferred until:

- rule-only daemon is designed
- monitoring views exist
- pgvector registry exists if vector is used
- AI input/output classes exist
- prompt/output security rules exist
- false-positive review exists
- rule tuning governance exists
- support/customer visible output approval exists

AI daemon must not be the first implementation.

---

## 21. Deferred Candidate: Containment Executor

`containment_executor_mvp_v1` should be deferred until:

- containment catalog exists
- release authority exists
- evidence/audit exists
- boundary tests exist
- domain-specific behavior exists
- false-positive review exists
- support/customer recovery path exists

Containment executor is high-risk because it can block operations.

It requires domain-by-domain approval.

---

## 22. Deferred Candidate: Quarantine Processor

`quarantine_processor_mvp_v1` should be deferred until:

- quarantine catalog exists
- release/reject authority exists
- evidence/audit exists
- provider/identity/value-specific quarantine rules exist
- boundary tests exist
- monitoring visibility exists
- support/admin review path exists

Quarantine processor is safer than mutation, but still blocks or delays data flow.

It requires narrow implementation.

---

## 23. Rejection Rule For Overbroad Packages

Reject packages with names such as:

- `implement_security_monitoring`
- `implement_ai_daemon`
- `implement_pgvector`
- `implement_archive`
- `implement_provider_integration`
- `implement_catch_order`
- `implement_pos_handoff`
- `implement_customer_support`
- `implement_runtime`

These are not acceptable implementation packages.

They must be decomposed.

---

## 24. Narrow Package Naming Pattern

Recommended pattern:

`<domain>_<artifact_or_runtime_slice>_<scope>_v1`

Examples:

- `security_catalog_registry_config_v1`
- `boundary_test_matrix_docs_v1`
- `provider_evidence_template_docs_v1`
- `archive_manifest_schema_planning_v1`
- `pgvector_source_registry_config_v1`
- `trigger_signal_packet_schema_docs_v1`
- `monitoring_view_contract_docs_v1`
- `catch_order_boundary_docs_v1`
- `catch_menu_projection_i18n_docs_v1`

Use names that reveal scope and avoid runtime ambiguity.

---

## 25. Candidate Handoff Record Schema

Each selected candidate must define:

| Field | Required Meaning |
|---|---|
| `candidate_id` | Candidate package id |
| `candidate_status` | Candidate status |
| `purpose` | Why it exists |
| `scope` | Allowed scope |
| `non_scope` | Explicitly prohibited scope |
| `imported_foundation_refs` | Imported artifacts |
| `affected_bulkheads` | Bulkheads touched |
| `controls_required` | Controls imported |
| `event_error_alert_mapping` | Values imported |
| `data_targets` | Data artifacts touched |
| `file_targets` | File paths if coding later |
| `test_ids` | Tests from `21643` |
| `blockers` | Open blockers |
| `review_owner` | Reviewer |
| `rollback_plan` | Required if coding later |
| `coding_status` | Must be explicit |

If this record is missing, coding is blocked.

---

## 26. Candidate Approval Gates

A candidate may move through gates:

| Gate | Meaning |
|---|---|
| `GATE_0_NOT_SELECTED` | Candidate not selected |
| `GATE_1_PLANNING_SELECTED` | Selected for planning |
| `GATE_2_HANDOFF_DRAFT_READY` | Handoff draft may be written |
| `GATE_3_SECURITY_REVIEW_READY` | Ready for security review |
| `GATE_4_TEST_MAPPING_READY` | Test mapping complete |
| `GATE_5_CODING_DECISION_READY` | Coding decision may be considered |
| `GATE_6_CODING_ALLOWED` | Coding explicitly allowed by separate decision |
| `GATE_7_IMPLEMENTATION_REVIEW` | Implementation review |
| `GATE_8_CLOSED` | Package closed |

This document does not move any candidate to `GATE_6`.

---

## 27. Initial Recommended Next Package

The next safest planning package is:

`09660 Catch & Order SaaS Runtime Boundary And Module Naming Policy`

Reason:

- The user has confirmed naming strategy.
- Catch & Order is the SaaS-facing integrated module.
- Catch Menu is the simpler customer-facing surface.
- Runtime boundary should be documented before any UI/provider/POS planning.
- It can import security monitoring Foundation without authorizing coding.

Alternative safe next package:

`09680 Provider Evidence Collection Template And Capability Review Policy`

If provider verification becomes urgent, `09680` may move earlier.

---

## 28. Readiness Blockers

| Blocker ID | Meaning |
|---|---|
| `BLOCKER-IMPLEMENTATION-SELECTION-0001` | Candidate selection policy not reviewed |
| `BLOCKER-CANDIDATE-SCOPE-0001` | Candidate scope too broad |
| `BLOCKER-CANDIDATE-HANDOFF-0001` | Candidate handoff record missing |
| `BLOCKER-CANDIDATE-FOUNDATION-IMPORT-0001` | Foundation references missing |
| `BLOCKER-CANDIDATE-TEST-MAP-0001` | Boundary tests not mapped |
| `BLOCKER-CANDIDATE-PROVIDER-EVIDENCE-0001` | Provider evidence missing |
| `BLOCKER-CANDIDATE-AI-GOVERNANCE-0001` | AI governance missing |
| `BLOCKER-CANDIDATE-PGVECTOR-GOVERNANCE-0001` | pgvector governance missing |
| `BLOCKER-CANDIDATE-ARCHIVE-LEGAL-0001` | Archive/legal review missing |
| `BLOCKER-CANDIDATE-CODING-ENTRY-0001` | Coding entry not authorized |

Open candidate blockers prevent coding.

---

## 29. Validation Checklist

Validation must confirm:

- candidates are narrow
- candidate statuses are controlled
- ranking favors low-risk foundation work
- static catalog registry is prioritized before runtime
- boundary test matrix is prioritized early
- provider evidence collection is prioritized before provider assumptions
- pgvector registry precedes ingestion
- rule-only daemon precedes AI daemon
- trigger signal schema precedes triggers
- monitoring view contract precedes daemon
- containment/quarantine executors are deferred
- Catch & Order begins with boundary planning
- Catch Menu begins with projection/i18n planning
- overbroad packages are rejected
- coding remains deferred

---

## 30. Relationship To Previous Documents

This document follows:

- `21646 Foundation Closure Index Update And Post-Closure Handoff Direction Policy`

It references:

- `21560` through `21646`

It prepares later planning for:

- `09660 Catch & Order SaaS Runtime Boundary And Module Naming Policy`
- `09670 Catch Menu Customer Surface Projection And i18n Naming Policy`
- `09680 Provider Evidence Collection Template And Capability Review Policy`
- `09690 Security Monitoring Foundation README Insert And Index Patch Policy`
- `09700 Controlled Non-Runtime Catalog Schema Planning Policy`

This document is implementation-selection policy only.

It does not authorize coding.

---

## 31. Final Rule

Future implementation must be selected, narrowed, mapped, reviewed, and tested before coding.

Priority must favor static catalogs, boundary test matrices, provider evidence templates, archive manifest planning, pgvector source registry planning, trigger signal schema planning, monitoring view contracts, Catch & Order boundary planning, and Catch Menu projection planning before any runtime daemon, vector ingestion, containment executor, quarantine processor, provider adapter, or customer-facing production surface.

Broad implementation requests are rejected by default.

Coding remains deferred until a separate narrow package handoff explicitly grants `CODING_ALLOWED`.
