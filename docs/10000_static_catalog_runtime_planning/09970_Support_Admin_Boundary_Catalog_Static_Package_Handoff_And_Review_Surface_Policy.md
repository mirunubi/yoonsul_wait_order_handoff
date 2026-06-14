# 09970 Support Admin Boundary Catalog Static Package Handoff And Review Surface Policy

## 1. Purpose

This document defines the Support Admin Boundary Catalog Static Package Handoff and Review Surface Policy.

The previous artifact `09960` defined the Catch & Order Status Catalog Static Package Handoff and Order Handoff Safe State Policy.

This document prepares the seventh recommended implementation candidate as a narrow static Support/Admin boundary catalog handoff.

The purpose is to define how support/admin-visible states, review surfaces, masking rules, escalation routes, allowed actions, prohibited actions, AI draft labels, pgvector context labels, recovery review states, compensation review references, and security/legal boundaries should be represented before any support/admin runtime workflow begins.

This document is planning-only.

It does not authorize coding.

---

## 2. Scope

This policy applies to the candidate package:

`support_admin_boundary_catalog_static_v1`

The package may later include static support/admin boundary records for:

1. Support case visibility
2. Order review visibility
3. POS handoff review visibility
4. Payment review visibility
5. KDS delay review visibility
6. Customer recovery review visibility
7. Compensation request review visibility
8. Coupon/point/wallet review visibility
9. Mass recovery review visibility
10. Provider evidence review visibility
11. i18n/customer message review visibility
12. AI draft review visibility
13. pgvector context review visibility
14. Security containment visibility
15. Quarantine visibility
16. Archive/legal hold visibility
17. Privacy masking visibility
18. Escalation route visibility
19. Franchise policy review visibility
20. Store/owner/HQ authority separation visibility

This package must remain static, reference-only, and non-runtime.

---

## 3. Core Principle

Support visibility is not support authority.

The correct rule is:

Support view does not mutate.
Support note does not approve.
Support draft does not send.
Support escalation does not close.
Support context does not prove.
Support visibility does not override finance, legal, security, or HQ authority.
Support cannot turn AI or pgvector into authority.

Support/Admin surfaces must help humans review and route issues without silently becoming execution layers.

---

## 4. Catalog Header

| Field | Value |
|---|---|
| Document ID | `09970` |
| Package ID | `support_admin_boundary_catalog_static_v1.handoff_draft` |
| Artifact Type | `STATIC_SUPPORT_ADMIN_BOUNDARY_CATALOG_HANDOFF_POLICY` |
| Version | `v1` |
| Planning Status | `HANDOFF_DRAFT` |
| Coding Status | `CODING_DEFERRED` |
| Runtime Authority | `SUPPORT_ADMIN_RUNTIME_USE_NOT_AUTHORIZED` |
| Owner | `Support / Product / Security / QA / Engineering / Legal / Finance` |
| Dependencies | `09560` to `09960` |
| Provider Evidence Status | `REFERENCE_ONLY_IF_PROVIDER_RELATED` |
| i18n Requirement | `REQUIRED_IF_SUPPORT_OR_CUSTOMER_MESSAGE_RELATED` |
| Audit Requirement | `IMPLEMENTATION_DECISION_AUDIT_REQUIRED_IF_CODED_LATER` |
| Security Requirement | `SUPPORT_VISIBILITY_AUTHORITY_SEPARATION_REQUIRED` |
| Review Requirement | `SUPPORT_SECURITY_PRODUCT_QA_ENGINEERING_LEGAL_FINANCE_REVIEW_AS_NEEDED` |
| Blocker Status | `SUPPORT_ADMIN_BOUNDARY_CATALOG_HANDOFF_REVIEW_REQUIRED` |

---

## 5. Candidate Package Identity

| Field | Value |
|---|---|
| Candidate ID | `CAND-09970-SUPPORT-ADMIN-BOUNDARY-001` |
| Package Name | `support_admin_boundary_catalog_static_v1` |
| Candidate Family | `CAND_SUPPORT_ADMIN_BOUNDARY_CATALOG` |
| Runtime Class | `STATIC_SUPPORT_BOUNDARY_REFERENCE_ONLY` |
| Mutation Class | `NO_RUNTIME_MUTATION` |
| Customer Visibility | `NO_CUSTOMER_VISIBLE_PUBLICATION` |
| Provider Interaction | `NO_PROVIDER_CALL` |
| POS Interaction | `NO_POS_CALL` |
| Payment Interaction | `NO_PAYMENT_CALL` |
| KDS Interaction | `NO_KDS_CALL` |
| AI Interaction | `NO_AI_RUNTIME` |
| pgvector Interaction | `NO_VECTOR_INGESTION_OR_RETRIEVAL` |
| Archive Interaction | `NO_ARCHIVE_RESTORE_OR_DELETE` |
| Compensation Interaction | `NO_VALUE_ACTION` |
| Franchise OS Interaction | `REFERENCE_ONLY` |

This identity must be preserved if later coding is authorized.

---

## 6. Source Document Range

The package may reference:

- `09770 Support Admin Visible Message Boundary And Review Surface Mapping Policy`
- `09780 Customer Recovery Message Catalog And Compensation Review Boundary Policy`
- `09790 Compensation Review Authority Matrix And Value Recovery Control Policy`
- `09800 Value Recovery Evidence Audit And Idempotency Review Packet Policy`
- `09810 Value Recovery Reconciliation And Partial Execution Closure Policy`
- `09820 Value Recovery Rollback Reversal And Customer Correction Notice Policy`
- `09830 Non-Reversible Value Action And Preventive Control Escalation Policy`
- `09840 High-Risk Compensation Escalation And Franchise Policy Inheritance Boundary Policy`
- `09850 Mass Recovery Event Grouping And Customer Communication Control Policy`
- `09860 Mass Recovery Root Cause Evidence Packet And Recurrence Prevention Policy`
- `09870 Mass Recovery Closure Decision And Incident Learning Handoff Policy`
- `09880 Incident Learning Boundary Test Matrix Update And Policy Patch Handoff`
- `09920 Boundary Test Matrix Static Package Handoff And Validation Mapping Policy`
- `09940 i18n Message Key Registry Static Package Handoff And Locale Review Policy`
- `09960 Catch And Order Status Catalog Static Package Handoff And Order Handoff Safe State Policy`
- `09560` through `09970`

Boundary records must cite source document and authority separation context.

---

## 7. Allowed Work

If a later authorization grants coding, allowed work may be limited to:

1. Create static support/admin boundary records.
2. Create support review surface catalog.
3. Create support visibility level catalog.
4. Create allowed action catalog.
5. Create prohibited action catalog.
6. Create escalation route reference catalog.
7. Create masking and unmasking boundary references.
8. Create AI draft and pgvector context label references.
9. Create boundary test references.
10. Create validation checklist.
11. Create README/index references.

Allowed work must not create support/admin runtime actions.

---

## 8. Explicit Non-Scope

The following are excluded:

1. Support/admin UI implementation
2. Support case workflow
3. Customer reply sending
4. Refund/coupon/point/wallet action
5. Payment review execution
6. POS/KDS mutation
7. Provider call
8. Unmasking workflow
9. Security containment release
10. Quarantine release
11. Archive restore/delete
12. Legal hold mutation
13. AI draft execution
14. pgvector retrieval execution
15. Runtime escalation routing
16. Compensation approval workflow
17. Mass recovery workflow
18. Franchise OS policy engine
19. Database triggers/functions
20. Production deployment

This package is boundary-catalog-only.

---

## 9. Support Admin Boundary Record Schema

Each support/admin boundary record should include:

| Field | Required Meaning |
|---|---|
| `support_boundary_id` | Stable boundary id |
| `boundary_key` | Stable boundary key |
| `surface` | Support/admin surface |
| `review_domain` | Order, payment, recovery, security, etc. |
| `visibility_level` | Visibility level |
| `allowed_actions` | Allowed action references |
| `prohibited_actions` | Prohibited action references |
| `masking_requirement` | Masking requirement |
| `unmask_authority_required` | Unmask authority requirement |
| `escalation_route` | Escalation route |
| `message_key_refs` | Support/admin message keys |
| `customer_message_allowed` | Whether customer message may be drafted |
| `customer_send_allowed` | Default false |
| `ai_draft_allowed` | Whether AI draft may appear as draft |
| `pgvector_context_allowed` | Whether similarity context may appear |
| `audit_requirement` | Audit requirement |
| `runtime_use_status` | Runtime use status |
| `boundary_test_refs` | Boundary tests |
| `blocker_id` | Blocker if incomplete |

A boundary record without allowed and prohibited actions is incomplete.

---

## 10. Boundary ID Pattern

Recommended boundary id pattern:

`SA-BND-<DOMAIN>-<NUMBER>`

Examples:

| Boundary ID | Meaning |
|---|---|
| `SA-BND-ORDER-0001` | Order review boundary |
| `SA-BND-PAYMENT-0001` | Payment review boundary |
| `SA-BND-KDS-0001` | KDS review boundary |
| `SA-BND-RECOVERY-0001` | Recovery review boundary |
| `SA-BND-COMP-0001` | Compensation review boundary |
| `SA-BND-PROVIDER-0001` | Provider review boundary |
| `SA-BND-I18N-0001` | i18n/message review boundary |
| `SA-BND-AI-0001` | AI draft boundary |
| `SA-BND-VECTOR-0001` | pgvector context boundary |
| `SA-BND-SECURITY-0001` | Security containment boundary |
| `SA-BND-ARCHIVE-0001` | Archive/legal hold boundary |
| `SA-BND-FRANCHISE-0001` | Franchise policy boundary |

Boundary ids must remain stable once referenced.

---

## 11. Support Review Domain Catalog

Initial review domains may include:

| Review Domain | Meaning |
|---|---|
| `SA_DOMAIN_ORDER` | Order review |
| `SA_DOMAIN_POS_HANDOFF` | POS handoff review |
| `SA_DOMAIN_PAYMENT` | Payment review |
| `SA_DOMAIN_KDS` | KDS fulfillment review |
| `SA_DOMAIN_PROVIDER` | Provider evidence review |
| `SA_DOMAIN_MENU` | Menu projection review |
| `SA_DOMAIN_I18N_MESSAGE` | Message/i18n review |
| `SA_DOMAIN_CUSTOMER_RECOVERY` | Customer recovery review |
| `SA_DOMAIN_COMPENSATION` | Compensation review |
| `SA_DOMAIN_VALUE_RECOVERY` | Refund/coupon/point/wallet review |
| `SA_DOMAIN_MASS_RECOVERY` | Mass recovery review |
| `SA_DOMAIN_SECURITY` | Security containment/quarantine visibility |
| `SA_DOMAIN_PRIVACY` | Privacy masking/unmasking |
| `SA_DOMAIN_ARCHIVE_LEGAL` | Archive/legal hold |
| `SA_DOMAIN_AI_DRAFT` | AI draft review |
| `SA_DOMAIN_PGVECTOR_CONTEXT` | pgvector context review |
| `SA_DOMAIN_FRANCHISE_POLICY` | Franchise policy review |

Domain does not imply mutation authority.

---

## 12. Visibility Level Catalog

Allowed visibility levels:

| Visibility Level | Meaning |
|---|---|
| `VIS_NONE` | Not visible |
| `VIS_SUMMARY_ONLY` | Summary only |
| `VIS_MASKED_DETAIL` | Masked details |
| `VIS_REVIEW_DETAIL` | Review details |
| `VIS_EVIDENCE_REF_ONLY` | Evidence reference only |
| `VIS_ESCALATION_ONLY` | Escalation route only |
| `VIS_LEAD_REVIEW_ONLY` | Support lead review only |
| `VIS_FINANCE_REVIEW_ONLY` | Finance review only |
| `VIS_LEGAL_REVIEW_ONLY` | Legal review only |
| `VIS_SECURITY_REVIEW_ONLY` | Security review only |
| `VIS_HQ_REVIEW_ONLY` | HQ review only |
| `VIS_BLOCKED` | Blocked |

Visibility level must never imply authority.

---

## 13. Allowed Action Catalog

Allowed actions may include:

| Action | Meaning |
|---|---|
| `SA_ACTION_VIEW_MASKED` | View masked record |
| `SA_ACTION_VIEW_SUMMARY` | View summary |
| `SA_ACTION_ADD_NOTE` | Add support note |
| `SA_ACTION_REQUEST_EVIDENCE` | Request evidence |
| `SA_ACTION_ROUTE_TO_STORE` | Route to store |
| `SA_ACTION_ROUTE_TO_SUPPORT_LEAD` | Route to support lead |
| `SA_ACTION_ROUTE_TO_FINANCE` | Route to finance |
| `SA_ACTION_ROUTE_TO_LEGAL` | Route to legal |
| `SA_ACTION_ROUTE_TO_SECURITY` | Route to security |
| `SA_ACTION_ROUTE_TO_PROVIDER_OPS` | Route to provider ops |
| `SA_ACTION_ROUTE_TO_HQ` | Route to HQ |
| `SA_ACTION_PREPARE_DRAFT_REPLY` | Prepare draft reply |
| `SA_ACTION_REQUEST_RECOVERY_REVIEW` | Request recovery review |
| `SA_ACTION_REQUEST_POLICY_REVIEW` | Request policy review |

Allowed action is still subject to review.

---

## 14. Prohibited Action Catalog

Prohibited actions include:

| Action | Meaning |
|---|---|
| `SA_PROHIBIT_DIRECT_REFUND` | No direct refund |
| `SA_PROHIBIT_DIRECT_COUPON` | No direct coupon issuance |
| `SA_PROHIBIT_DIRECT_POINT_ADJUST` | No direct point adjustment |
| `SA_PROHIBIT_DIRECT_WALLET_CREDIT` | No direct wallet/prepaid credit |
| `SA_PROHIBIT_PAYMENT_STATE_MUTATION` | No payment state mutation |
| `SA_PROHIBIT_POS_STATE_MUTATION` | No POS state mutation |
| `SA_PROHIBIT_KDS_STATE_MUTATION` | No KDS state mutation |
| `SA_PROHIBIT_SECURITY_RELEASE` | No containment/quarantine release |
| `SA_PROHIBIT_ARCHIVE_DELETE` | No archive deletion |
| `SA_PROHIBIT_LEGAL_HOLD_CHANGE` | No legal hold mutation |
| `SA_PROHIBIT_CUSTOMER_SEND_UNREVIEWED` | No unreviewed customer send |
| `SA_PROHIBIT_AI_AUTO_SEND` | No AI auto-send |
| `SA_PROHIBIT_VECTOR_PROOF_USE` | No pgvector proof use |
| `SA_PROHIBIT_CLOSE_WITHOUT_RECON` | No closure without reconciliation |
| `SA_PROHIBIT_OVERRIDE_HQ_POLICY` | No HQ policy override |

Prohibited actions protect authority boundaries.

---

## 15. Runtime Use Status Catalog

Allowed runtime use statuses:

| Status | Meaning |
|---|---|
| `SUPPORT_ADMIN_RUNTIME_USE_NOT_AUTHORIZED` | Runtime use prohibited |
| `SUPPORT_ADMIN_REFERENCE_ONLY` | Reference only |
| `SUPPORT_ADMIN_DRAFT_ONLY` | Draft only |
| `SUPPORT_ADMIN_REVIEW_REQUIRED` | Review required |
| `SUPPORT_ADMIN_BLOCKED` | Blocked |
| `SUPPORT_ADMIN_DEPRECATED` | Deprecated |
| `SUPPORT_ADMIN_RUNTIME_ALLOWED_BY_SEPARATE_PACKAGE` | Later separate approval only |

Default:

`SUPPORT_ADMIN_RUNTIME_USE_NOT_AUTHORIZED`

No support/admin boundary may become runtime-active in this package.

---

## 16. Order POS KDS Review Boundary Rule

Support/admin review of order/POS/KDS states must preserve:

- support note is not order mutation
- POS accepted is not payment confirmed
- KDS completed is not settlement truth
- duplicate order risk must route to review
- raw POS/KDS error must not become customer reply
- staff route must be separated from support closure
- support cannot silently replay or remake without authority

Order/POS/KDS review is visibility and routing.

---

## 17. Payment Review Boundary Rule

Support/admin payment review must preserve:

- support view is not payment authority
- support note is not refund approval
- provider callback is not verified payment state
- duplicate payment risk requires finance review
- ledger mismatch blocks closure
- customer reply must not confirm refund/payment unless verified
- payment data must be masked where required

Payment review requires finance/security boundaries.

---

## 18. Recovery Compensation Review Boundary Rule

Support/admin recovery and compensation review must preserve:

- recovery message does not approve compensation
- apology does not create value action
- compensation request does not issue value
- coupon/point/wallet/refund actions require authority
- idempotency is required before value action
- non-reversible action requires preventive control
- high-risk cases escalate

Support can request review.

Support cannot execute value action by default.

---

## 19. Customer Message Boundary Rule

Support/admin customer message handling must preserve:

- draft is not sent
- AI draft is labeled
- pgvector context is not copied as proof
- legal-sensitive messages route to legal
- finance/value messages route to finance
- provider blame is blocked without evidence
- correction notices require review
- mass recovery messages require approved strategy

Customer message sending is not authorized by this static package.

---

## 20. Provider Evidence Review Boundary Rule

Support/admin provider evidence review must preserve:

- provider claim is not evidence
- provider outage must be evidenced
- provider callback must be verified
- provider capability status is internal unless approved
- provider blame must not be customer-visible without review
- provider ops owns provider evidence escalation
- support cannot mark provider production-ready

Provider evidence remains controlled.

---

## 21. Security Privacy Boundary Rule

Support/admin security/privacy visibility must preserve:

- containment visibility is not release authority
- quarantine visibility is not deletion authority
- privacy masked detail must not be exposed casually
- unmasking requires authority
- legal hold blocks deletion/anonymization
- security root cause is not customer-visible
- support cannot suppress security alerts

Security and privacy controls override support convenience.

---

## 22. AI Draft Boundary Rule

AI draft support visibility must preserve:

- AI draft must be labeled
- AI draft must not auto-send
- AI draft must not approve compensation
- AI draft must not close case
- AI draft must not confirm root cause
- AI draft must not blame provider/customer/store
- AI draft must route to human review

AI is drafting support only.

---

## 23. pgvector Context Boundary Rule

pgvector context support visibility must preserve:

- similarity is not proof
- similar case is not current entitlement
- retrieved policy is reference only
- vector score is not authority
- pgvector context must not be customer-copied without review
- evidence still required
- reviewer decision must remain human

pgvector is retrieval context only.

---

## 24. Franchise Policy Review Boundary Rule

Support/admin franchise policy review must preserve:

- HQ policy ceiling
- finance/legal/security precedence
- tenant/franchise layer separation
- owner/store local policy boundary
- support discretion as lowest authority
- policy exception audit
- customer message consistency across stores
- high-risk local override prohibition

Support cannot override Franchise OS policy hierarchy.

---

## 25. Validation Checklist Candidate

Validation should confirm:

1. Boundary ids are unique.
2. Boundary keys are stable.
3. Review domain is controlled.
4. Visibility level is controlled.
5. Allowed actions exist.
6. Prohibited actions exist.
7. Runtime use status is not authorized.
8. Masking requirement exists where needed.
9. Escalation route exists where needed.
10. Customer send allowed defaults false.
11. AI draft and pgvector context are labeled as non-authority.
12. Payment/value actions are prohibited unless separate authority exists.
13. Security/legal boundaries are preserved.
14. Boundary test references exist.
15. No customer data is included.
16. No raw provider/payment/POS/KDS payload is included.
17. No secrets are included.
18. Blockers are explicit.

Validation failure blocks support/admin runtime workflow.

---

## 26. File Layout Candidate

If later authorized, the package may use a file layout such as:

| Path Candidate | Purpose |
|---|---|
| `catalogs/support_admin/boundary_catalog_index.md` | Human-readable support/admin boundary index |
| `catalogs/support_admin/boundary_records.json` | Static boundary records |
| `catalogs/support_admin/review_domains.json` | Review domain catalog |
| `catalogs/support_admin/visibility_levels.json` | Visibility level catalog |
| `catalogs/support_admin/allowed_actions.json` | Allowed action catalog |
| `catalogs/support_admin/prohibited_actions.json` | Prohibited action catalog |
| `catalogs/support_admin/runtime_statuses.json` | Runtime use status catalog |
| `catalogs/support_admin/validation_checklist.md` | Validation checklist |
| `docs/implementation_candidates/CAND-09970-SUPPORT-ADMIN-BOUNDARY-001.md` | Candidate record |

This is a layout candidate only.

No files are authorized by this document.

---

## 27. Rollback Plan Candidate

Rollback for the static support/admin boundary catalog should be:

1. Revert added boundary catalog files.
2. Revert index references.
3. Mark incorrect boundary records as deprecated if already referenced.
4. Add blocker for downstream support/admin packages.
5. Restore previous static version.
6. Preserve review note if already circulated.

Rollback must not require customer notification or runtime data correction because no publication or mutation is allowed.

---

## 28. Handoff Blockers

| Blocker ID | Meaning |
|---|---|
| `BLOCKER-09970-REVIEW-0001` | Handoff draft not reviewed |
| `BLOCKER-09970-SCOPE-0001` | Scope/non-scope not accepted |
| `BLOCKER-09970-SCHEMA-0001` | Boundary record schema not accepted |
| `BLOCKER-09970-DOMAIN-0001` | Review domain catalog not accepted |
| `BLOCKER-09970-VISIBILITY-0001` | Visibility level catalog not accepted |
| `BLOCKER-09970-ACTION-0001` | Allowed/prohibited action catalogs not accepted |
| `BLOCKER-09970-MASKING-0001` | Masking rule not accepted |
| `BLOCKER-09970-AI-0001` | AI draft boundary not accepted |
| `BLOCKER-09970-PGVECTOR-0001` | pgvector context boundary not accepted |
| `BLOCKER-09970-FORMAT-0001` | File/data format not selected |
| `BLOCKER-09970-PATH-0001` | Target path not selected |
| `BLOCKER-09970-VALIDATION-0001` | Validation checklist not accepted |
| `BLOCKER-09970-CODING-0001` | Coding not authorized |

Open blockers prevent coding.

---

## 29. Coding Authorization Requirements

A future coding authorization packet must declare:

| Field | Required Value |
|---|---|
| Candidate ID | `CAND-09970-SUPPORT-ADMIN-BOUNDARY-001` |
| Package Name | `support_admin_boundary_catalog_static_v1` |
| Allowed Operations | Static support/admin boundary catalog file/catalog creation only |
| Prohibited Operations | Support/admin UI, workflow, customer send, provider/payment/POS/KDS calls, AI/vector, DB mutation, value action |
| Target Paths | Explicit paths |
| File Format | Explicit format |
| Validation Command | Explicit or manual checklist |
| Rollback Plan | Explicit |
| Reviewers | Explicit |
| Final Decision | `CODING_ALLOWED_NARROW_SCOPE` |

Without this packet, coding remains unauthorized.

---

## 30. Relationship To Previous Documents

This document follows:

- `09960 Catch And Order Status Catalog Static Package Handoff And Order Handoff Safe State Policy`

It references:

- `09770 Support Admin Visible Message Boundary And Review Surface Mapping Policy`
- `09780 Customer Recovery Message Catalog And Compensation Review Boundary Policy`
- `09790 Compensation Review Authority Matrix And Value Recovery Control Policy`
- `09800 Value Recovery Evidence Audit And Idempotency Review Packet Policy`
- `09810 Value Recovery Reconciliation And Partial Execution Closure Policy`
- `09820 Value Recovery Rollback Reversal And Customer Correction Notice Policy`
- `09830 Non-Reversible Value Action And Preventive Control Escalation Policy`
- `09840 High-Risk Compensation Escalation And Franchise Policy Inheritance Boundary Policy`
- `09850 Mass Recovery Event Grouping And Customer Communication Control Policy`
- `09860 Mass Recovery Root Cause Evidence Packet And Recurrence Prevention Policy`
- `09870 Mass Recovery Closure Decision And Incident Learning Handoff Policy`
- `09880 Incident Learning Boundary Test Matrix Update And Policy Patch Handoff`
- `09920 Boundary Test Matrix Static Package Handoff And Validation Mapping Policy`
- `09940 i18n Message Key Registry Static Package Handoff And Locale Review Policy`
- `09960 Catch And Order Status Catalog Static Package Handoff And Order Handoff Safe State Policy`
- `09560` through `09960`

It prepares later planning for:

- explicit coding authorization packet
- static support/admin boundary catalog creation
- support/admin runtime review surface gate
- customer recovery review surface package
- compensation review package
- AI/pgvector support context package
- future support/admin workflow readiness

This document is a static support/admin boundary catalog handoff draft only.

It does not authorize coding.

---

## 31. Final Rule

The static Support/Admin boundary catalog may become the seventh implementation package only if it remains static, non-runtime, reference-only, scope-locked, validation-ready, rollback-simple, and explicitly reviewed.

Every support/admin boundary must declare review domain, visibility level, allowed actions, prohibited actions, masking requirement, escalation route, customer-send boundary, AI/pgvector non-authority labels, runtime use status, boundary test references, and blockers.

Default status must remain `SUPPORT_ADMIN_RUNTIME_USE_NOT_AUTHORIZED`, and `customer_send_allowed` must default to false.

No support/admin UI, workflow execution, customer reply sending, payment/POS/KDS/provider call, refund/coupon/point/wallet action, AI/vector execution, archive/legal mutation, security containment release, mass recovery workflow, or Franchise OS policy execution may be included.

No static Support/Admin boundary catalog implementation may proceed until a separate narrow authorization grants `CODING_ALLOWED_NARROW_SCOPE`, declares target paths and format, maps validation, resolves blockers, and defines rollback.
