# 022410_Policy_Controlled_Coding_Entry_Candidate_Package_Selection

## 1. Purpose

This document defines the policy for selecting candidate packages for a future controlled coding entry phase.

The purpose is to prevent the project from moving directly from readiness review into broad implementation.

After the readiness review and blocker inventory in `22400`, only carefully selected packages may become candidates for coding entry review.

A candidate package is not yet approved for coding.

A candidate package is only eligible for a later explicit coding entry decision.

---

## 2. Scope

This policy applies to all package families that may later enter controlled implementation:

1. Foundation registry packages
2. i18n/message key packages
3. Content registry packages
4. Contract catalog packages
5. Audit baseline packages
6. Evidence packet baseline packages
7. Security/masking baseline packages
8. Data model skeleton packages
9. API/RPC contract skeleton packages
10. UI surface skeleton packages
11. Provider capability registry packages
12. Payment/KDS planning packages
13. AI Support Gateway planning packages
14. External projection planning packages
15. Redtable-type partner planning packages

This document does not approve implementation.

Coding remains deferred.

---

## 3. Core Principle

Candidate selection must prefer low-risk foundation packages before high-authority runtime packages.

The first coding candidates should not be payment execution, refund execution, KDS provider integration, AI customer-facing automation, global payment bridge, or external partner publication.

The first coding candidates should be the packages that make later implementation safer:

- contract catalog
- i18n key registry
- content source registry
- provider capability registry
- audit event catalog
- evidence packet planning catalog
- readiness/blocker tracking
- no-hardcoded-string guardrails
- package handoff records

The project should build the gates before building the runtime roads.

---

## 4. Candidate Does Not Mean Approved

A package marked as a candidate has only passed selection for further review.

It does not mean:

- SQL may be written
- RPC may be created
- UI may be implemented
- provider SDK may be connected
- AI retrieval may be deployed
- pgvector index may be created
- payment flow may be built
- KDS connector may be built
- support/admin mutation may be exposed
- external projection may be published

Coding is allowed only when a later document explicitly grants `CODING_ALLOWED` to a specific package.

---

## 5. Candidate Selection Criteria

A package may be selected as a coding entry candidate only if it satisfies the following minimum criteria:

| Criterion | Required Meaning |
|---|---|
| Planning boundary exists | Package is defined in prior planning documents |
| Runtime owner exists | Authority owner is identified |
| Blockers are known | Open blockers are listed, not hidden |
| Authority risk is low or controlled | Package does not create hidden mutation |
| i18n impact is known | Text surfaces are mapped or absent |
| Content dependency is known | Registry dependency is mapped |
| Audit impact is known | Audit requirement is mapped |
| Security impact is known | Data/role/secret risk is identified |
| Provider dependency is known | Provider evidence state is explicit |
| Degraded behavior is known | Failure/stale/blocked state is defined |
| Test intent is known | Boundary tests can be planned |
| Coding status remains deferred | Candidate does not equal approval |

---

## 6. Preferred First Candidate Families

The first candidate packages should normally come from Foundation and control-plane families.

Preferred first candidates:

1. `foundation.i18n.message_catalog.v1`
2. `foundation.content.registry_catalog.v1`
3. `foundation.contract.catalog.v1`
4. `foundation.provider.capability_registry.v1`
5. `foundation.audit.event_catalog.v1`
6. `foundation.evidence.packet_catalog.v1`
7. `foundation.readiness.blocker_inventory.v1`
8. `foundation.package.handoff_record.v1`
9. `foundation.no_hardcoded_operational_string_guard.v1`
10. `foundation.locale_audience_surface_map.v1`

These candidates make later runtime implementation safer.

They should be considered before payment, KDS, AI automation, support mutation, or external projection execution.

---

## 7. High-Risk Package Deferral Rule

The following package types should not be selected as first coding candidates unless there is a later explicit exception:

- payment provider execution
- refund execution
- settlement finalization
- KDS provider connector
- POS/KDS live bridge
- support/admin mutation console
- AI customer-facing automation
- pgvector production retrieval
- external menu publication
- Redtable-type partner adapter
- global payment bridge
- Google Maps/NFC/QR provider integration
- customer identity sharing with partners
- provider callback final-state mutation

These packages require stronger evidence, security, audit, reconciliation, and rollback readiness.

---

## 8. Candidate Selection Record

Every candidate package must have a selection record.

The record must include:

| Field | Required Meaning |
|---|---|
| Candidate id | Stable identifier |
| Package id | Related package |
| Package family | Foundation, UI, API, adapter, support, AI, projection, etc. |
| Reason for selection | Why this is a safe/needed candidate |
| Runtime owner | Authority owner |
| Related documents | Planning docs that define it |
| Known blockers | Open blockers |
| Deferred blockers | Blockers intentionally carried forward |
| Required review | Architecture/security/i18n/provider/audit review |
| Test planning need | Boundary test requirement |
| Coding status | Must remain `CODING_DEFERRED` unless later approved |

---

## 9. Candidate Status Categories

Candidate packages must use explicit statuses.

| Status | Meaning |
|---|---|
| `CANDIDATE_NOT_SELECTED` | Not selected for entry review |
| `CANDIDATE_PROPOSED` | Proposed for entry review |
| `CANDIDATE_NEEDS_REVIEW` | Requires readiness/security/i18n review |
| `CANDIDATE_BLOCKED` | Cannot proceed due to blocker |
| `CANDIDATE_DEFERRED` | Intentionally postponed |
| `CANDIDATE_READY_FOR_ENTRY_DECISION` | Ready for later coding entry decision |
| `CANDIDATE_REJECTED` | Not suitable for entry |
| `CANDIDATE_CODING_ALLOWED` | Only after later explicit approval |

Default status:

`CANDIDATE_PROPOSED`

This status does not allow coding.

---

## 10. Foundation-First Selection Rule

Foundation packages should be selected before runtime-heavy packages because they reduce future implementation risk.

Foundation-first means prioritizing:

- message key structure
- content key structure
- contract naming registry
- provider capability status registry
- audit event family catalog
- evidence packet family catalog
- locale/audience classification
- readiness status tracking
- package handoff template
- no-hardcoded-string rules

Foundation-first does not mean implementing business logic.

Foundation-first creates the guardrails for business logic.

---

## 11. i18n Candidate Selection

i18n-related candidates should be selected early if they do not create runtime authority.

Candidate examples:

- `foundation.i18n.message_key_catalog.v1`
- `foundation.i18n.locale_policy.v1`
- `foundation.i18n.audience_message_map.v1`
- `foundation.i18n.error_message_key_map.v1`
- `foundation.i18n.degraded_message_key_map.v1`
- `foundation.i18n.provider_status_message_key_map.v1`

These packages may later support UI, API, support/admin, AI, KDS, payment, and external projection packages.

No hardcoded operational strings may be introduced.

---

## 12. Content Registry Candidate Selection

Content registry candidates should be selected early if they preserve traceability and do not publish external content yet.

Candidate examples:

- `foundation.content.registry_index.v1`
- `foundation.content.source_traceability_map.v1`
- `foundation.content.menu_key_catalog.v1`
- `foundation.content.sop_content_key_map.v1`
- `foundation.content.training_content_key_map.v1`
- `foundation.content.support_template_key_map.v1`
- `foundation.content.external_projection_key_map.v1`

These packages prepare content authority.

They do not authorize runtime publication.

---

## 13. Contract Catalog Candidate Selection

Contract catalog candidates should be selected before API/RPC implementation.

Candidate examples:

- `foundation.contract.catalog.v1`
- `foundation.contract.api_boundary_map.v1`
- `foundation.contract.rpc_boundary_map.v1`
- `foundation.contract.event_family_map.v1`
- `foundation.contract.audit_dependency_map.v1`
- `foundation.contract.provider_dependency_map.v1`

The contract catalog may list future contracts.

It must not create runtime handlers.

---

## 14. Provider Capability Registry Candidate Selection

Provider capability registry candidates should be selected before provider adapter coding.

Candidate examples:

- `foundation.provider.capability_registry.v1`
- `foundation.provider.evidence_record.v1`
- `foundation.provider.status_catalog.v1`
- `foundation.provider.redtable_capability_blocker_map.v1`
- `foundation.provider.payment_method_evidence_map.v1`
- `foundation.provider.projection_capability_evidence_map.v1`

Provider capability registry implementation must not imply capability confirmation.

Default unresolved status remains:

`CAPABILITY_PROVIDER_EVIDENCE_REQUIRED`

---

## 15. Audit And Evidence Candidate Selection

Audit and evidence candidates should be selected early because they protect future support/admin, payment, KDS, AI, and projection packages.

Candidate examples:

- `foundation.audit.event_family_catalog.v1`
- `foundation.audit.reason_code_catalog.v1`
- `foundation.audit.authority_marker_map.v1`
- `foundation.evidence.packet_family_catalog.v1`
- `foundation.evidence.source_traceability_map.v1`
- `foundation.evidence.integrity_status_catalog.v1`

These packages define accountability structure.

They do not yet implement support/admin mutation.

---

## 16. Security And Masking Candidate Selection

Security/masking candidates may be selected early if they are boundary catalogs or rules.

Candidate examples:

- `foundation.security.data_visibility_catalog.v1`
- `foundation.security.masking_policy_map.v1`
- `foundation.security.provider_secret_boundary.v1`
- `foundation.security.webhook_verification_requirement_map.v1`
- `foundation.security.export_restriction_catalog.v1`

These packages must not create broad admin access.

They define constraints for later access implementation.

---

## 17. AI Candidate Selection

AI packages should normally remain planning-only until content registry, traceability, masking, and audit foundations are ready.

Early AI candidates may include:

- `ai.planning.source_classification_catalog.v1`
- `ai.planning.output_state_catalog.v1`
- `ai.planning.human_review_rule_map.v1`
- `ai.planning.provider_evidence_notice_map.v1`

The following should remain deferred:

- production pgvector retrieval
- customer-facing AI response automation
- AI support case automation
- AI refund/recovery recommendation execution
- AI external projection translation publication

AI remains assistance, not authority.

---

## 18. Payment Candidate Selection

Payment packages should be selected conservatively.

Early payment candidates may include:

- `payment.planning.state_catalog.v1`
- `payment.planning.provider_evidence_map.v1`
- `payment.planning.refund_authority_map.v1`
- `payment.planning.reconciliation_boundary_map.v1`
- `payment.planning.error_key_map.v1`

The following should remain deferred:

- live payment provider adapter
- payment capture implementation
- refund execution
- settlement finalization
- global payment bridge
- provider callback final mutation

Payment success must not be treated as final settlement.

---

## 19. KDS Candidate Selection

KDS packages should be selected conservatively.

Early KDS candidates may include:

- `kds.planning.ticket_state_catalog.v1`
- `kds.planning.pos_handoff_contract_map.v1`
- `kds.planning.degraded_state_map.v1`
- `kds.planning.message_key_map.v1`
- `kds.planning.evidence_boundary_map.v1`

The following should remain deferred:

- live KDS provider connector
- live POS/KDS bridge
- kitchen ticket mutation implementation
- provider callback sync
- degraded replay implementation

KDS remains kitchen execution evidence, not financial authority.

---

## 20. External Projection Candidate Selection

External projection packages should remain mostly deferred until content, translation, provider evidence, audit, rollback, and security foundations are ready.

Early candidates may include:

- `projection.planning.source_authority_map.v1`
- `projection.planning.translation_status_catalog.v1`
- `projection.planning.rollback_rule_map.v1`
- `projection.planning.redtable_blocker_map.v1`
- `projection.planning.provider_status_key_map.v1`

The following should remain deferred:

- external menu publication
- Redtable adapter
- Google Maps integration
- NFC/QR provider runtime
- global payment bridge
- customer identity sharing with partners

External projection remains projection only.

---

## 21. Support/Admin Candidate Selection

Support/admin packages should be selected only when evidence, audit, masking, and authority boundaries are ready.

Early candidates may include:

- `support.planning.case_state_catalog.v1`
- `support.planning.evidence_requirement_map.v1`
- `support.planning.masking_requirement_map.v1`
- `support.planning.escalation_path_catalog.v1`
- `support.planning.ai_assist_boundary_map.v1`

The following should remain deferred:

- support/admin mutation console
- refund execution from support surface
- unmasking workflow implementation
- evidence export implementation
- AI-assisted automatic case closure

Support/admin is not a backdoor.

---

## 22. Candidate Prioritization Matrix

Candidate selection should use the following prioritization logic:

| Priority | Package Type | Reason |
|---|---|---|
| P0 | Foundation catalogs and registries | Enables safe future implementation |
| P1 | Readiness/blocker tracking | Prevents hidden blockers |
| P2 | i18n/content traceability | Prevents hardcoded strings |
| P3 | Audit/evidence/security catalogs | Prevents hidden authority |
| P4 | Low-authority planning skeletons | Prepares implementation safely |
| P5 | Runtime APIs/UI skeletons | Only after contracts and keys exist |
| P6 | Provider/payment/KDS adapters | Only after evidence/security review |
| P7 | AI automation/external projection | Only after strong traceability and approval |

High-risk packages must not jump ahead of foundation packages.

---

## 23. Candidate Table Template

Candidate selection should be recorded using this table.

| Candidate ID | Package ID | Family | Reason Selected | Status | Primary Blocker | Coding Status |
|---|---|---|---|---|---|---|
| `CAND-0001` | `foundation.contract.catalog.v1` | Foundation | Needed before API/RPC implementation | `CANDIDATE_PROPOSED` | None identified yet | `CODING_DEFERRED` |

This table is a planning artifact.

It does not allow coding.

---

## 24. Rejection And Deferral Rule

A package may be rejected or deferred from candidate selection.

Reasons include:

- provider evidence missing
- i18n/content source missing
- audit/evidence model incomplete
- security review incomplete
- payment reconciliation incomplete
- AI traceability incomplete
- external rollback missing
- support/admin authority unclear
- too much runtime authority for first wave
- implementation would create hardcoded strings
- implementation would rely on assumptions

Rejected or deferred packages must remain visible in the blocker inventory.

---

## 25. Candidate Review Checklist

Before a package is marked `CANDIDATE_READY_FOR_ENTRY_DECISION`, the following must be answered:

- Is the package boundary defined?
- Is the runtime owner defined?
- Is the authority level low or controlled?
- Are API/RPC/event dependencies known?
- Are data model dependencies known?
- Are i18n/content dependencies known?
- Are provider dependencies known?
- Are audit/evidence dependencies known?
- Are security/masking dependencies known?
- Are degraded states known?
- Are open blockers listed?
- Are deferred blockers listed?
- Is the test intent known?
- Is coding still deferred?
- Is this package safer than implementing a runtime-heavy feature first?

If any answer is missing, the package remains a proposed candidate only.

---

## 26. Relationship To Previous Documents

This document follows:

- `22390 Controlled Implementation Planning Closure And Coding Entry Deferral Policy`
- `22400 Controlled Implementation Readiness Review And Blocker Inventory Policy`

This document prepares the project for a later controlled coding entry decision document.

It does not authorize coding.

---

## 27. Final Rule

Candidate package selection is a planning step, not an implementation step.

The project must select safe, foundation-first candidates before attempting runtime-heavy implementation.

The first candidates should build the guardrails: i18n, content registry, contract catalog, provider capability registry, audit/evidence catalogs, readiness/blocker inventory, and package handoff records.

Coding remains deferred.

Only a later explicit coding entry document may grant `CODING_ALLOWED` to a specific package.
