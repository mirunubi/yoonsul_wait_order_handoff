# 09900 Controlled Implementation Candidate Template And First Package Selection Policy

## 1. Purpose

This document defines the Controlled Implementation Candidate Template and First Package Selection Policy.

The previous artifact `09890` defined the Post-Incident Coding Readiness Review and Controlled Implementation Gate Policy.

This document converts the planning gates into a reusable implementation candidate template and defines how the first narrow implementation package should be selected without opening broad runtime coding.

The purpose is to ensure that any first implementation step is small, reviewable, reversible, catalog-first, and safe.

This document is planning-only.

It does not authorize coding.

---

## 2. Scope

This policy applies to first implementation candidate selection for:

1. Static catalog registry
2. Boundary test matrix artifact
3. Provider evidence registry
4. i18n message key registry
5. Catch Menu status mapping catalog
6. Catch & Order status mapping catalog
7. Support/admin visible message boundary catalog
8. Customer recovery message catalog
9. Compensation authority catalog
10. Value recovery evidence/idempotency catalog
11. Mass recovery event family catalog
12. Incident learning handoff catalog
13. AI governance catalog
14. pgvector source traceability catalog
15. Archive/legal hold catalog
16. Franchise OS policy inheritance catalog

This document does not implement any runtime function, UI, API, provider adapter, daemon, database mutation, customer message delivery, payment action, POS handoff, KDS action, AI workflow, pgvector ingestion, or archive operation.

---

## 3. Core Principle

The first implementation package should reduce risk, not maximize feature count.

The correct rule is:

Catalog before runtime.
Tests before execution.
Evidence before provider integration.
i18n keys before visible text.
Authority matrix before mutation.
Idempotency before value action.
Rollback before coding.
Scope before enthusiasm.

The first package must be intentionally boring.

---

## 4. Catalog Header

| Field | Value |
|---|---|
| Document ID | `09900` |
| Package ID | `controlled_implementation.candidate_template.first_package_selection.v1` |
| Artifact Type | `IMPLEMENTATION_CANDIDATE_SELECTION_POLICY` |
| Version | `v1` |
| Planning Status | `FOUNDATION_CANDIDATE` |
| Coding Status | `CODING_DEFERRED` |
| Runtime Authority | `IMPLEMENTATION_SELECTION_PLANNING_ONLY` |
| Owner | `Product / Security / QA / Engineering / Support` |
| Dependencies | `09560` to `09890` |
| Provider Evidence Status | `REQUIRED_IF_PROVIDER_RELATED` |
| i18n Requirement | `REQUIRED_IF_VISIBLE_TEXT_RELATED` |
| Audit Requirement | `REQUIRED_FOR_IMPLEMENTATION_DECISIONS` |
| Security Requirement | `FIRST_PACKAGE_SCOPE_LOCK_REQUIRED` |
| Review Requirement | `PRODUCT_SECURITY_QA_ENGINEERING_REVIEW_REQUIRED` |
| Blocker Status | `FIRST_PACKAGE_SELECTION_REVIEW_REQUIRED` |

---

## 5. Implementation Candidate Template Definition

An implementation candidate template is a reusable planning structure used before any coding decision.

It must force the package owner to declare:

- exact package identity
- source documents
- target artifacts
- scope
- non-scope
- authority boundary
- provider dependency
- i18n dependency
- audit dependency
- test dependency
- rollback/fallback
- review route
- blockers
- coding decision

The template prevents vague handoffs.

---

## 6. Candidate Template

A future implementation candidate should use the following structure:

    Implementation Candidate:
    <candidate_id>

    Package Name:
    <package_name>

    Candidate Family:
    <candidate_family>

    Source Documents:
    <document references>

    Source Evidence:
    <evidence references or N/A>

    Scope:
    <exact included work>

    Non-Scope:
    <explicit exclusions>

    Target Artifacts:
    <files, catalogs, docs, data structures, or tests>

    Runtime Authority:
    <none / catalog-only / test-only / runtime candidate>

    Provider Dependency:
    <none / required / blocked / evidence packet id>

    i18n Dependency:
    <none / required / blocked / key registry ref>

    Audit Dependency:
    <none / required / review only>

    Boundary Tests:
    <test families and required assertions>

    Rollback Or Fallback:
    <rollback/fallback plan>

    Review Route:
    <reviewers>

    Blockers:
    <blocker ids>

    Coding Decision:
    CODING_NOT_AUTHORIZED

    Notes:
    <additional constraints>

This template does not authorize coding.

---

## 7. Candidate Family Selection Rule

Candidate families should be ranked by safety and dependency value.

Recommended first-package priority:

| Rank | Candidate Family | Reason |
|---:|---|---|
| 1 | `CAND_STATIC_CATALOG_REGISTRY` | Lowest runtime risk, high traceability value |
| 2 | `CAND_BOUNDARY_TEST_MATRIX` | Creates safety net before runtime |
| 3 | `CAND_PROVIDER_EVIDENCE_REGISTRY` | Prevents unsupported provider assumptions |
| 4 | `CAND_I18N_MESSAGE_KEY_REGISTRY` | Prevents hardcoded visible text |
| 5 | `CAND_CATCH_MENU_STATUS_CATALOG` | Customer surface safety without runtime |
| 6 | `CAND_CATCH_ORDER_STATUS_CATALOG` | Order status safety without provider execution |
| 7 | `CAND_SUPPORT_ADMIN_BOUNDARY_CATALOG` | Prevents hidden support authority |
| 8 | `CAND_RECOVERY_MESSAGE_CATALOG` | Controls customer recovery language |
| 9 | `CAND_COMPENSATION_AUTHORITY_CATALOG` | Controls value authority before action |
| 10 | `CAND_VALUE_IDEMPOTENCY_CATALOG` | Prepares duplicate prevention |
| 11 | `CAND_AI_GOVERNANCE_CATALOG` | Controls AI before use |
| 12 | `CAND_PGVECTOR_SOURCE_CATALOG` | Controls vector source before ingestion |

Runtime candidates should not be first.

---

## 8. First Package Selection Criteria

The first implementation package should satisfy:

- no runtime mutation
- no customer-visible publication
- no payment/POS/KDS/provider call
- no AI autonomous action
- no pgvector ingestion
- no archive restore/delete
- no support/admin authority expansion
- no legal hold bypass
- clear file or catalog targets
- clear validation checklist
- clear rollback by deletion/revert
- high reuse across later packages
- low risk of customer impact

If a candidate fails these criteria, it should not be first.

---

## 9. Recommended First Package

Recommended first package:

`security_monitoring_catalog_registry_static_v1`

Reason:

- static-only
- non-runtime
- supports security bulkheads
- supports provider evidence
- supports boundary tests
- supports i18n and recovery catalogs later
- supports Catch Menu and Catch & Order planning
- supports audit traceability
- can remain `REGISTRY_RUNTIME_USE_NOT_AUTHORIZED`
- easier to review than runtime logic

This recommendation does not authorize coding.

---

## 10. Static Catalog Registry Candidate Scope

The first package may include planning for a static registry that references:

- bulkhead domain map
- trust boundary map
- security class catalog
- control catalog
- containment status catalog
- quarantine status catalog
- event/alert family catalog
- error code catalog
- provider evidence status catalog
- i18n message class catalog
- boundary test family catalog
- archive/retention tier catalog
- pgvector source class catalog
- AI governance class catalog
- Catch Menu/Catch & Order module boundary catalog
- recovery/compensation status catalogs

Scope must remain reference-only.

---

## 11. Static Catalog Registry Non-Scope

The first package must exclude:

- runtime enforcement
- database triggers
- RPC functions
- provider calls
- payment actions
- POS handoff
- KDS mutation
- customer message publication
- support/admin mutation buttons
- AI daemon behavior
- pgvector ingestion
- archive restore/delete
- legal hold mutation
- compensation action
- refund/coupon/point/wallet action
- mass recovery workflow

Non-scope must be explicit in the handoff.

---

## 12. Candidate Artifact Types

Allowed artifact types for first package planning:

| Artifact Type | Allowed |
|---|---|
| Static catalog file | Candidate only |
| Markdown registry | Candidate only |
| JSON/YAML schema | Candidate only |
| Validation checklist | Candidate only |
| Boundary test matrix draft | Candidate only |
| README/index patch | Candidate only |
| Runtime API | Not allowed |
| Database table | Not allowed unless separate approval |
| Trigger/function | Not allowed |
| Provider adapter | Not allowed |
| AI daemon | Not allowed |
| Customer UI | Not allowed |
| Payment/KDS/POS integration | Not allowed |

This document does not choose actual file format.

---

## 13. Target Directory Candidate

If future implementation chooses files, candidate paths may be:

| Path Candidate | Purpose |
|---|---|
| `catalogs/foundation/security_monitoring/` | Foundation security catalog registry |
| `catalogs/foundation/provider_evidence/` | Provider evidence references |
| `catalogs/foundation/boundary_tests/` | Boundary test references |
| `catalogs/foundation/i18n/` | i18n registry references |
| `catalogs/catch_order/` | Catch & Order references |
| `catalogs/catch_menu/` | Catch Menu references |
| `docs/implementation_candidates/` | Candidate records |
| `docs/foundation/security_monitoring/` | Human-readable index |

This is a path candidate only.

No files are authorized by this document.

---

## 14. Minimum Static Registry Record Schema

A static registry record should include:

| Field | Required Meaning |
|---|---|
| `registry_id` | Stable registry id |
| `registry_family` | Registry family |
| `name` | Human-readable name |
| `description` | Description |
| `source_doc_ref` | Source document |
| `source_section_ref` | Source section if available |
| `authority_boundary` | Authority boundary |
| `runtime_use_status` | Runtime use status |
| `security_class` | Security class |
| `bulkhead_ref` | Bulkhead reference if applicable |
| `provider_dependency` | Provider dependency if any |
| `i18n_dependency` | i18n dependency if any |
| `audit_dependency` | Audit dependency if any |
| `test_family_refs` | Related test families |
| `status` | Registry status |
| `blocker_id` | Blocker if incomplete |

Default runtime use status:

`REGISTRY_RUNTIME_USE_NOT_AUTHORIZED`

---

## 15. Registry Family Catalog

Initial registry families may include:

| Registry Family | Meaning |
|---|---|
| `REGISTRY_BULKHEAD` | Bulkhead domains |
| `REGISTRY_TRUST_BOUNDARY` | Trust boundaries |
| `REGISTRY_SECURITY_CLASS` | Security classes |
| `REGISTRY_CONTROL` | Security/control records |
| `REGISTRY_EVENT_ALERT` | Event/alert families |
| `REGISTRY_ERROR_CODE` | Error code families |
| `REGISTRY_PROVIDER_STATUS` | Provider capability/evidence statuses |
| `REGISTRY_I18N_MESSAGE_CLASS` | i18n message classes |
| `REGISTRY_CUSTOMER_SAFE_STATE` | Customer-safe state families |
| `REGISTRY_SUPPORT_BOUNDARY` | Support/admin boundary rules |
| `REGISTRY_RECOVERY_STATUS` | Recovery status families |
| `REGISTRY_COMPENSATION_AUTHORITY` | Compensation authority classes |
| `REGISTRY_VALUE_IDEMPOTENCY` | Idempotency/reconciliation statuses |
| `REGISTRY_MASS_RECOVERY` | Mass recovery families |
| `REGISTRY_AI_GOVERNANCE` | AI governance classes |
| `REGISTRY_PGVECTOR_SOURCE` | pgvector source classes |
| `REGISTRY_ARCHIVE_RETENTION` | Archive/retention classes |
| `REGISTRY_FRANCHISE_POLICY` | Franchise policy layers |

Registry family may be expanded later by patch.

---

## 16. First Package Gate Checklist

The first package may proceed to a later coding decision only if:

- candidate id exists
- package name exists
- scope is locked
- non-scope is locked
- target artifact type is declared
- no runtime authority is included
- no provider call is included
- no customer-visible publication is included
- no value mutation is included
- no AI/pgvector runtime is included
- rollback is simple
- validation checklist exists
- review route exists
- blockers are recorded
- coding decision is explicit

Until then:

`CODING_NOT_AUTHORIZED`

---

## 17. Review Route For First Package

Minimum review route:

| Reviewer | Review Focus |
|---|---|
| Product | Scope and naming |
| Security | Boundary and bulkhead correctness |
| QA | Validation and test references |
| Engineering | File/data feasibility |
| Support | Support/recovery terminology |
| i18n Owner | Message class references if included |
| Provider Ops | Provider status references if included |
| Finance | Value/compensation references if included |
| Legal | Legal/privacy references if included |

Not every reviewer must approve every low-risk record, but inclusion of their domain must trigger review.

---

## 18. Rollback Rule For First Package

Rollback should be simple.

Possible rollback:

- remove candidate file
- revert registry record
- revert index patch
- restore previous catalog version
- mark record deprecated
- mark runtime use not authorized
- block downstream candidate

Rollback must not require runtime data correction.

If rollback would require runtime correction, the package is too risky for first implementation.

---

## 19. Validation Rule For First Package

Validation should confirm:

- registry records have required fields
- source docs exist
- runtime use status is non-authorized
- no secrets are included
- no personal data is included
- no raw provider payloads are included
- no customer data is included
- no payment data is included
- no legal hold data is included
- no AI generated customer text is included
- no pgvector raw source data is included
- cross-references are valid
- blockers are explicit

Static registry validation is the first safety net.

---

## 20. Prohibited First Package Claims

The first package must not claim:

- security monitoring is implemented
- financial-grade certification is achieved
- daemon is active
- AI monitoring is running
- provider integration is verified
- POS/KDS/payment integration is complete
- customer recovery is automated
- compensation is executable
- pgvector search is live
- archive/legal hold workflow is implemented
- Franchise OS policy engine is implemented

Allowed wording:

- planned
- cataloged
- candidate
- reviewed
- static reference
- runtime deferred
- coding not authorized

---

## 21. AI Assistance Boundary

AI may assist with:

- drafting registry descriptions
- finding duplicate terms
- suggesting missing fields
- summarizing source documents
- preparing review checklist

AI must not:

- approve records
- mark runtime use allowed
- decide provider capability
- decide security class finally
- decide customer-visible wording finally
- authorize coding
- close blockers

AI is drafting support only.

---

## 22. pgvector Assistance Boundary

pgvector may later assist with:

- finding related policies
- finding similar registry entries
- finding source references
- detecting duplicate concepts

pgvector must not:

- approve registry correctness
- decide authority boundary
- prove provider capability
- classify security risk finally
- authorize runtime use
- authorize coding

Similarity is not validation.

---

## 23. First Package Candidate Record

Initial recommended candidate record:

| Field | Value |
|---|---|
| `candidate_id` | `CAND-09900-STATIC-REGISTRY-001` |
| `candidate_family` | `CAND_STATIC_CATALOG_REGISTRY` |
| `package_name` | `security_monitoring_catalog_registry_static_v1` |
| `source_docs` | `09560` to `09900` |
| `scope` | Static registry records and index references only |
| `non_scope` | Runtime enforcement, provider calls, DB mutation, UI, AI/vector runtime, payment/POS/KDS actions |
| `runtime_authority` | `REGISTRY_RUNTIME_USE_NOT_AUTHORIZED` |
| `provider_dependency` | Reference-only |
| `i18n_dependency` | Reference-only |
| `audit_dependency` | Implementation decision audit only |
| `boundary_tests` | Reference-only to boundary test families |
| `rollback` | Revert files/records or mark deprecated |
| `coding_decision` | `CODING_NOT_AUTHORIZED` |
| `status` | `CANDIDATE_APPROVED_FOR_PLANNING` |

This record is a planning recommendation only.

---

## 24. Second Package Candidate Direction

After the first package is reviewed, the second safest package may be:

`boundary_test_matrix_static_v1`

Reason:

- test matrix creates enforcement vocabulary
- still no runtime behavior
- improves future coding safety
- maps incident learning to test families
- can block unsafe runtime packages

Second package should not begin until the first package is reviewed or explicitly deferred.

---

## 25. Third Package Candidate Direction

The third safest package may be:

`provider_evidence_registry_static_v1`

Reason:

- provider assumptions are high-risk
- payment/POS/KDS/provider integration depends on evidence
- capability status must be known before runtime adapters
- supports Catch & Order and Catch Menu safely

Provider registry must remain evidence-only until runtime integration is separately authorized.

---

## 26. Candidate Selection Anti-Patterns

Avoid selecting first packages that:

- combine catalog and runtime
- combine provider adapter and payment logic
- combine customer UI and recovery logic
- create DB triggers before catalog review
- create support/admin action buttons before authority matrix
- publish customer messages before i18n review
- ingest vectors before source registry
- call AI before governance
- implement refund/coupon/wallet before idempotency
- implement Franchise OS policy before inheritance rules

Broad packages create hidden risk.

---

## 27. File Layout Candidate

If future implementation chooses files, candidate paths may be:

| Path Candidate | Purpose |
|---|---|
| `docs/implementation_candidates/09900_candidate_template.md` | Candidate template |
| `docs/implementation_candidates/first_package_selection.md` | First package selection review |
| `catalogs/foundation/security_monitoring/registry_index.*` | Static registry index candidate |
| `catalogs/foundation/security_monitoring/registry_records.*` | Static registry records candidate |
| `catalogs/foundation/security_monitoring/validation_checklist.*` | Validation checklist candidate |

This is a layout candidate only.

No files are authorized.

---

## 28. Database Layout Candidate

If future implementation chooses database-backed candidate tracking, candidate table families may be:

| Table Family Candidate | Purpose |
|---|---|
| `implementation_candidate_templates` | Candidate templates |
| `implementation_candidate_records` | Candidate records |
| `implementation_candidate_reviews` | Review records |
| `implementation_candidate_blockers` | Blockers |
| `implementation_candidate_decisions` | Coding decisions |

This is a data-model candidate only.

No tables are authorized.

---

## 29. Readiness Blockers

| Blocker ID | Meaning |
|---|---|
| `BLOCKER-FIRST-PACKAGE-0001` | First package policy not reviewed |
| `BLOCKER-FIRST-PACKAGE-TEMPLATE-0001` | Candidate template missing |
| `BLOCKER-FIRST-PACKAGE-SELECTION-0001` | First package selection not approved |
| `BLOCKER-FIRST-PACKAGE-SCOPE-0001` | Scope/non-scope not locked |
| `BLOCKER-FIRST-PACKAGE-REGISTRY-SCHEMA-0001` | Registry schema not reviewed |
| `BLOCKER-FIRST-PACKAGE-REVIEW-ROUTE-0001` | Review route missing |
| `BLOCKER-FIRST-PACKAGE-VALIDATION-0001` | Validation rule missing |
| `BLOCKER-FIRST-PACKAGE-ROLLBACK-0001` | Rollback rule missing |
| `BLOCKER-FIRST-PACKAGE-CLAIM-0001` | Prohibited claims not reviewed |
| `BLOCKER-FIRST-PACKAGE-CODING-0001` | Coding not authorized |

Open blockers prevent first package implementation.

---

## 30. Validation Checklist

Validation must confirm:

- candidate template definition exists
- candidate template content exists
- candidate family selection rule exists
- first package selection criteria exist
- recommended first package is identified
- static catalog registry scope exists
- static catalog registry non-scope exists
- allowed artifact types exist
- target directory candidate exists
- minimum registry record schema exists
- registry family catalog exists
- first package gate checklist exists
- review route exists
- rollback rule exists
- validation rule exists
- prohibited claims list exists
- AI boundary exists
- pgvector boundary exists
- first package candidate record exists
- second package direction exists
- third package direction exists
- anti-pattern list exists
- layout candidates are non-authorizing
- coding remains deferred

---

## 31. Relationship To Previous Documents

This document follows:

- `09890 Post-Incident Coding Readiness Review And Controlled Implementation Gate Policy`

It references:

- `09631 Bulkhead Domain Map Source Of Truth And Trust Boundary Catalog`
- `09634 Security Control Records And Security Class Catalog`
- `09635 Security Event Alert Families And Severity Routing Catalog`
- `09636 Unix-Style Error Code Catalog And Domain Fault Mapping Policy`
- `09643 Boundary Test Checklist And Security Monitoring Validation Matrix`
- `09680 Provider Evidence Collection Template And Capability Review Policy`
- `09740 i18n Message Key Registry And Customer Visible Text Review Policy`
- `09880 Incident Learning Boundary Test Matrix Update And Policy Patch Handoff`
- `09890 Post-Incident Coding Readiness Review And Controlled Implementation Gate Policy`
- `09560` through `09890`

It prepares later planning for:

- first static catalog registry handoff
- boundary test matrix static handoff
- provider evidence registry static handoff
- explicit coding authorization packet
- future implementation execution package

This document is controlled implementation candidate template and first package selection planning only.

It does not authorize coding.

---

## 32. Final Rule

The first implementation package must be narrow, static, reviewable, reversible, non-runtime, and traceable to source documents.

The recommended first package is a static security monitoring catalog registry with runtime use explicitly unauthorized.

No runtime behavior, provider call, POS/KDS/payment action, customer-visible publication, AI/vector execution, support/admin mutation, archive/legal mutation, compensation action, or Franchise OS policy engine may be included in the first package.

No first package implementation may proceed until a separate narrow handoff grants `CODING_ALLOWED`, declares target files or data structures, maps validation, resolves blockers, and defines rollback.
