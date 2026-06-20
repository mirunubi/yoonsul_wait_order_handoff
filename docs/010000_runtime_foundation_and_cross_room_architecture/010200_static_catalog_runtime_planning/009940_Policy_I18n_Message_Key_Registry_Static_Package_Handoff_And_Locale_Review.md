# 009940_Policy_I18n_Message_Key_Registry_Static_Package_Handoff_And_Locale_Review

## 1. Purpose

This document defines the i18n Message Key Registry Static Package Handoff and Locale Review Policy.

The previous artifact `09930` defined the Provider Evidence Registry Static Package Handoff and Capability Traceability Policy.

This document prepares the fourth recommended implementation candidate as a narrow static i18n message key registry handoff.

The purpose is to define how visible text keys, message classes, locale status, fallback rules, customer-safe wording boundaries, support/admin-visible messages, recovery messages, compensation messages, correction notices, and provider/status messages should be represented before any customer-visible text is published.

This document is planning-only.

It does not authorize coding.

---

## 2. Scope

This policy applies to the candidate package:

`i18n_message_key_registry_static_v1`

The package may later include static i18n key registry records for:

1. Catch Menu customer status messages
2. Catch & Order customer status messages
3. Support/admin visible messages
4. Customer recovery messages
5. Compensation review messages
6. Value recovery messages
7. Refund/coupon/point/wallet review messages
8. Rollback/reversal correction notices
9. Non-reversible action notices
10. High-risk escalation messages
11. Mass recovery customer messages
12. Provider delay/fallback messages
13. Payment checking/review messages
14. KDS fulfillment status messages
15. Menu price/availability/allergen messages
16. Legal/privacy-sensitive messages
17. AI draft labels and warnings
18. pgvector similarity/context warnings
19. Franchise OS policy messages
20. Workforce/applicant-facing messages if later connected

This package must remain static, reference-only, and non-runtime.

---

## 3. Core Principle

An i18n key is a controlled message identity, not a published customer message.

The correct rule is:

Key existence does not publish text.
Draft copy does not equal approved copy.
Machine translation does not equal locale approval.
AI draft does not equal customer-safe message.
Provider status does not equal customer-visible claim.
Payment review does not equal payment confirmation.
Recovery message does not equal compensation approval.

Every visible message must be keyed, reviewed, fallback-safe, and audience-bounded before publication.

---

## 4. Catalog Header

| Field | Value |
|---|---|
| Document ID | `09940` |
| Package ID | `i18n_message_key_registry_static_v1.handoff_draft` |
| Artifact Type | `STATIC_I18N_MESSAGE_KEY_REGISTRY_HANDOFF_POLICY` |
| Version | `v1` |
| Planning Status | `HANDOFF_DRAFT` |
| Coding Status | `CODING_DEFERRED` |
| Runtime Authority | `MESSAGE_RUNTIME_USE_NOT_AUTHORIZED` |
| Owner | `Product / i18n / Content / Support / Security` |
| Dependencies | `09560` to `09930` |
| Provider Evidence Status | `REFERENCE_ONLY_IF_PROVIDER_VISIBLE` |
| i18n Requirement | `STATIC_KEY_REGISTRY_ONLY` |
| Audit Requirement | `IMPLEMENTATION_DECISION_AUDIT_REQUIRED_IF_CODED_LATER` |
| Security Requirement | `CUSTOMER_VISIBLE_TEXT_REVIEW_BOUNDARY_REQUIRED` |
| Review Requirement | `PRODUCT_I18N_CONTENT_SECURITY_SUPPORT_LEGAL_FINANCE_REVIEW_AS_NEEDED` |
| Blocker Status | `I18N_MESSAGE_KEY_REGISTRY_HANDOFF_REVIEW_REQUIRED` |

---

## 5. Candidate Package Identity

| Field | Value |
|---|---|
| Candidate ID | `CAND-09940-I18N-MESSAGE-001` |
| Package Name | `i18n_message_key_registry_static_v1` |
| Candidate Family | `CAND_I18N_MESSAGE_KEY_REGISTRY` |
| Runtime Class | `STATIC_MESSAGE_KEY_REFERENCE_ONLY` |
| Mutation Class | `NO_RUNTIME_MUTATION` |
| Customer Visibility | `NO_CUSTOMER_VISIBLE_PUBLICATION` |
| Provider Interaction | `NO_PROVIDER_CALL` |
| AI Interaction | `NO_AI_RUNTIME` |
| pgvector Interaction | `NO_VECTOR_INGESTION` |
| Archive Interaction | `NO_ARCHIVE_RESTORE_OR_DELETE` |
| Compensation Interaction | `NO_VALUE_ACTION` |
| Franchise OS Interaction | `REFERENCE_ONLY` |

This identity must be preserved if later coding is authorized.

---

## 6. Source Document Range

The package may reference:

- `09670 Catch Menu Customer Surface Projection And i18n Naming Policy`
- `09740 i18n Message Key Registry And Customer Visible Text Review Policy`
- `09750 Catch & Order Status Message Catalog And Customer Safe State Mapping Policy`
- `09760 Catch Menu Status Surface And Order Handoff Message Mapping Policy`
- `09770 Support Admin Visible Message Boundary And Review Surface Mapping Policy`
- `09780 Customer Recovery Message Catalog And Compensation Review Boundary Policy`
- `09820 Value Recovery Rollback Reversal And Customer Correction Notice Policy`
- `09850 Mass Recovery Event Grouping And Customer Communication Control Policy`
- `09880 Incident Learning Boundary Test Matrix Update And Policy Patch Handoff`
- `09900 Controlled Implementation Candidate Template And First Package Selection Policy`
- `09910` through `09930`
- `09560` through `09940`

Message records must cite source document and policy context.

---

## 7. Allowed Work

If a later authorization grants coding, allowed work may be limited to:

1. Create static i18n message key registry records.
2. Create message class catalog.
3. Create audience catalog.
4. Create surface catalog.
5. Create locale status catalog.
6. Create fallback rule catalog.
7. Create review route mapping.
8. Create customer promise boundary mapping.
9. Create visible text blocker mappings.
10. Create validation checklist.
11. Create README/index references.

Allowed work must not publish text to customers.

---

## 8. Explicit Non-Scope

The following are excluded:

1. Customer-visible publication
2. Production locale bundles
3. UI text rendering
4. Runtime translation loading
5. Automated message sending
6. SMS/Kakao/push/email delivery
7. Support reply sending
8. AI-generated message publication
9. Machine translation approval
10. Provider status publication
11. Payment/refund confirmation messages
12. Coupon/point/wallet confirmation messages
13. Legal notice publication
14. Customer correction notice sending
15. Runtime i18n fallback logic
16. Database-backed message service
17. Customer UI implementation
18. Support/admin message workflow
19. Franchise OS policy message engine
20. Any runtime message authority

This package is registry-only.

---

## 9. Message Key Record Schema

Each message key registry record should include:

| Field | Required Meaning |
|---|---|
| `message_key` | Stable i18n key |
| `surface` | Surface |
| `audience` | Audience |
| `domain` | Domain |
| `message_class` | Message class |
| `message_intent` | What the message communicates |
| `source_doc_ref` | Source document |
| `source_section_ref` | Source section if known |
| `source_status_or_event` | Source status/event if applicable |
| `customer_visibility` | Visibility classification |
| `customer_promise_boundary` | What may or may not be promised |
| `fallback_key` | Fallback key |
| `default_locale_status` | Default locale status |
| `locale_review_status` | Locale review status |
| `content_review_status` | Content review |
| `legal_review_status` | Legal review if needed |
| `finance_review_status` | Finance review if value-related |
| `security_review_status` | Security review if risk-related |
| `provider_evidence_status` | Provider evidence if provider-related |
| `ai_generated_status` | AI draft status |
| `runtime_use_status` | Runtime use status |
| `blocker_id` | Blocker if incomplete |

A message key without fallback key is incomplete.

---

## 10. Message Key Naming Pattern

Recommended key pattern:

`<surface>.<domain>.<state_or_case>.<message_type>`

Examples:

| Key | Meaning |
|---|---|
| `catch_menu.menu.loading.status` | Catch Menu loading |
| `catch_menu.item.sold_out.notice` | Sold-out notice |
| `catch_menu.allergen.review_required.warning` | Allergen review warning |
| `catch_order.order.confirming.status` | Order confirming |
| `catch_order.payment.checking.status` | Payment checking |
| `catch_order.kds.preparing.status` | Preparing |
| `support.order.review_required.notice` | Support review notice |
| `recovery.payment_uncertain.review.customer` | Payment recovery review |
| `compensation.refund.review.customer` | Refund review message |
| `rollback.customer_correction.pending.notice` | Correction notice |
| `mass_recovery.provider_delay.safe_notice.customer` | Mass provider delay notice |

Keys must remain stable after reference.

---

## 11. Surface Catalog

Initial surfaces may include:

| Surface | Meaning |
|---|---|
| `SURFACE_CATCH_MENU` | Catch Menu customer surface |
| `SURFACE_CATCH_ORDER` | Catch & Order customer/order status |
| `SURFACE_SUPPORT_ADMIN` | Support/admin surface |
| `SURFACE_STORE_STAFF` | Store staff surface |
| `SURFACE_OWNER_ADMIN` | Owner/admin surface |
| `SURFACE_HQ_ADMIN` | HQ admin surface |
| `SURFACE_CUSTOMER_RECOVERY` | Customer recovery message surface |
| `SURFACE_COMPENSATION_REVIEW` | Compensation review message surface |
| `SURFACE_CORRECTION_NOTICE` | Customer correction notice surface |
| `SURFACE_MASS_RECOVERY` | Mass recovery communication surface |
| `SURFACE_EXTERNAL_PROJECTION` | External projection/partner surface |
| `SURFACE_LEGAL_PRIVACY` | Legal/privacy notice surface |
| `SURFACE_AI_DRAFT` | AI-drafted candidate surface |
| `SURFACE_PGVECTOR_CONTEXT` | Similarity/context warning surface |
| `SURFACE_FRANCHISE_OS` | Franchise OS policy message surface |
| `SURFACE_WORKFORCE_APPLICANT` | Workforce/applicant surface if later used |

Surface does not imply runtime publication.

---

## 12. Audience Catalog

Initial audiences may include:

| Audience | Meaning |
|---|---|
| `AUD_CUSTOMER_ANONYMOUS` | Anonymous customer |
| `AUD_CUSTOMER_SESSION` | Session customer |
| `AUD_CUSTOMER_MEMBER` | Member customer |
| `AUD_STORE_STAFF` | Store staff |
| `AUD_STORE_MANAGER` | Store manager |
| `AUD_SUPPORT_AGENT` | Support agent |
| `AUD_SUPPORT_LEAD` | Support lead |
| `AUD_OWNER` | Owner |
| `AUD_HQ_ADMIN` | HQ admin |
| `AUD_PROVIDER_OPS` | Provider operations |
| `AUD_FINANCE` | Finance reviewer |
| `AUD_LEGAL` | Legal/compliance reviewer |
| `AUD_SECURITY` | Security reviewer |
| `AUD_AI_GOVERNANCE` | AI governance reviewer |
| `AUD_DATA_GOVERNANCE` | Data/pgvector/archive reviewer |
| `AUD_FRANCHISE_OPS` | Franchise operations reviewer |
| `AUD_APPLICANT` | Workforce applicant if later used |

Audience controls visibility and review route.

---

## 13. Message Class Catalog

Initial message classes may include:

| Message Class | Meaning |
|---|---|
| `MSG_STATUS` | General status |
| `MSG_NOTICE` | Informational notice |
| `MSG_WARNING` | Warning |
| `MSG_ERROR_SAFE` | Customer-safe error |
| `MSG_FALLBACK` | Fallback message |
| `MSG_RECOVERY` | Customer recovery |
| `MSG_COMPENSATION_REVIEW` | Compensation review |
| `MSG_PAYMENT_SAFE` | Payment-safe status |
| `MSG_KDS_SAFE` | KDS-safe fulfillment |
| `MSG_PROVIDER_SAFE` | Provider-safe message |
| `MSG_ALLERGEN_SAFETY` | Allergen/safety |
| `MSG_PRICE_VALUE` | Price/value |
| `MSG_LEGAL_PRIVACY` | Legal/privacy |
| `MSG_CORRECTION_NOTICE` | Correction notice |
| `MSG_MASS_RECOVERY` | Mass recovery notice |
| `MSG_SUPPORT_INTERNAL` | Support internal |
| `MSG_AI_DRAFT_LABEL` | AI draft label |
| `MSG_VECTOR_CONTEXT_LABEL` | pgvector context label |

Message class determines review strictness.

---

## 14. Customer Visibility Status Catalog

Allowed visibility statuses:

| Status | Meaning |
|---|---|
| `VIS_CUSTOMER_NOT_ALLOWED` | Must not be shown to customer |
| `VIS_CUSTOMER_SAFE_DRAFT` | Draft customer-safe candidate |
| `VIS_CUSTOMER_REVIEW_REQUIRED` | Customer visibility review required |
| `VIS_CUSTOMER_SUPPORT_MEDIATED` | Support-mediated only |
| `VIS_CUSTOMER_LEGAL_REVIEW_REQUIRED` | Legal review required |
| `VIS_CUSTOMER_FINANCE_REVIEW_REQUIRED` | Finance review required |
| `VIS_CUSTOMER_PROVIDER_EVIDENCE_REQUIRED` | Provider evidence required |
| `VIS_CUSTOMER_APPROVED_FOR_PLANNING` | Planning approval only |
| `VIS_CUSTOMER_APPROVED_FOR_RUNTIME_BY_SEPARATE_PACKAGE` | Later separate approval only |

Default:

`VIS_CUSTOMER_NOT_ALLOWED`

This package may not approve runtime customer visibility.

---

## 15. Runtime Use Status Catalog

Allowed runtime use statuses:

| Status | Meaning |
|---|---|
| `MESSAGE_RUNTIME_USE_NOT_AUTHORIZED` | Runtime use prohibited |
| `MESSAGE_REFERENCE_ONLY` | Reference only |
| `MESSAGE_DRAFT_ONLY` | Draft only |
| `MESSAGE_REVIEW_REQUIRED` | Review required |
| `MESSAGE_BLOCKED` | Blocked |
| `MESSAGE_DEPRECATED` | Deprecated |
| `MESSAGE_RUNTIME_ALLOWED_BY_SEPARATE_PACKAGE` | Later separate approval only |

Default:

`MESSAGE_RUNTIME_USE_NOT_AUTHORIZED`

No message may become runtime-active in this package.

---

## 16. Locale Review Status Catalog

Allowed locale review statuses:

| Status | Meaning |
|---|---|
| `LOCALE_NOT_STARTED` | Locale not started |
| `LOCALE_DRAFT` | Draft locale copy |
| `LOCALE_MACHINE_DRAFT` | Machine translation draft |
| `LOCALE_NATIVE_REVIEW_REQUIRED` | Native review required |
| `LOCALE_CONTENT_REVIEW_REQUIRED` | Content review required |
| `LOCALE_LEGAL_REVIEW_REQUIRED` | Legal review required |
| `LOCALE_FINANCE_REVIEW_REQUIRED` | Finance review required |
| `LOCALE_SECURITY_REVIEW_REQUIRED` | Security review required |
| `LOCALE_APPROVED_FOR_PLANNING` | Planning approval only |
| `LOCALE_RUNTIME_NOT_AUTHORIZED` | Runtime not authorized |
| `LOCALE_BLOCKED` | Blocked |

Machine translation must not be production approval.

---

## 17. Fallback Key Rule

Every customer-visible or support-visible key must define fallback.

Fallback hierarchy:

1. exact locale key
2. language fallback
3. default locale key
4. safe generic fallback key
5. support/staff review if no safe fallback exists

If no safe fallback exists, customer visibility is blocked.

Fallback text must not show raw internal state.

---

## 18. Customer Promise Boundary Rule

Each message must define what it may promise.

Examples:

| Message Area | Allowed Before Confirmation |
|---|---|
| Order | Received/checking/confirming |
| Payment | Checking/reviewing |
| Refund | Review requested |
| Coupon | Being checked |
| Points | Being checked |
| Wallet | Being reviewed |
| KDS | Preparing/delayed/ready only if confirmed |
| Provider | Temporary delay/status checking |
| Recovery | Support review/staff assistance |
| Compensation | Review, not approval |
| Correction | Checking/correction pending |

A message must not promise more than authority confirms.

---

## 19. Provider-Related Message Rule

Provider-related messages must not expose:

- raw provider error
- provider blame without evidence
- provider contract limitation
- provider callback failure
- provider replay/signature failure
- provider internal incident details
- provider capability claim without evidence

Customer-safe wording should use delay, checking, unavailable, or support-review framing.

Provider evidence status must be linked.

---

## 20. Payment-Related Message Rule

Payment-related messages require stricter review.

Payment messages must not say:

- paid
- refunded
- canceled
- charged
- wallet credited
- duplicate resolved

unless authority and evidence confirm.

Before confirmation, safe states include:

- checking
- under review
- support review
- finance review
- final status pending

Payment text requires finance/security review when value-bearing.

---

## 21. Allergen Safety Message Rule

Allergen/safety messages require:

- approved source
- approved locale
- legal/product review if customer-visible
- no AI-only wording
- conservative fallback
- staff assistance route if uncertain
- external projection restriction if unverified

Allergen text must not be casual or ambiguous.

---

## 22. Recovery Compensation Message Rule

Recovery/compensation messages must distinguish:

- apology
- acknowledgement
- review
- approval
- execution
- reconciliation
- closure
- correction

A compensation review message must not become compensation approval.

A customer recovery message must not become refund/coupon/wallet action.

---

## 23. AI Draft Message Rule

AI-drafted message records must include:

- `ai_generated_status`
- source data approval status
- human review route
- customer-send blocked status
- legal/finance/security review if applicable

AI draft labels must be visible to support reviewers.

AI draft must not be sent automatically.

---

## 24. pgvector Context Message Rule

pgvector-related messages must label similarity context.

Required meaning:

- similar case
- reference only
- not proof
- review required
- evidence still required

pgvector context must not be customer-visible unless specifically reviewed as generic explanatory text.

---

## 25. Franchise OS Message Rule

Franchise OS policy messages must preserve:

- HQ policy ceiling
- legal/security/finance precedence
- owner/store policy boundary
- policy exception audit
- customer message consistency
- locale/legal jurisdiction review

Local policy text must not override higher authority text.

---

## 26. Validation Checklist Candidate

Validation should confirm:

1. Message keys are unique.
2. Key naming pattern is valid.
3. Surface is controlled.
4. Audience is controlled.
5. Message class is controlled.
6. Source document reference exists.
7. Customer visibility status exists.
8. Runtime use status is not authorized.
9. Fallback key exists where required.
10. Promise boundary exists where required.
11. Locale review status exists.
12. Provider evidence status exists when provider-related.
13. Finance/legal/security review status exists when needed.
14. AI draft status exists when AI-related.
15. No raw internal text is included.
16. No customer data is included.
17. No secrets are included.
18. Blockers are explicit.

Validation failure blocks message runtime publication.

---

## 27. File Layout Candidate

If later authorized, the package may use a file layout such as:

| Path Candidate | Purpose |
|---|---|
| `catalogs/foundation/i18n/message_key_registry_index.md` | Human-readable message key registry index |
| `catalogs/foundation/i18n/message_key_records.json` | Static message key records |
| `catalogs/foundation/i18n/surfaces.json` | Surface catalog |
| `catalogs/foundation/i18n/audiences.json` | Audience catalog |
| `catalogs/foundation/i18n/message_classes.json` | Message class catalog |
| `catalogs/foundation/i18n/visibility_statuses.json` | Visibility statuses |
| `catalogs/foundation/i18n/locale_statuses.json` | Locale statuses |
| `catalogs/foundation/i18n/validation_checklist.md` | Validation checklist |
| `docs/implementation_candidates/CAND-09940-I18N-MESSAGE-001.md` | Candidate record |

This is a layout candidate only.

No files are authorized by this document.

---

## 28. Rollback Plan Candidate

Rollback for the static i18n message key registry should be:

1. Revert added message key registry files.
2. Revert index references.
3. Mark incorrect message keys as deprecated if already referenced.
4. Add blocker for downstream message packages.
5. Restore previous static version.
6. Preserve review note if already circulated.

Rollback must not require customer notification because no publication is allowed.

---

## 29. Handoff Blockers

| Blocker ID | Meaning |
|---|---|
| `BLOCKER-09940-REVIEW-0001` | Handoff draft not reviewed |
| `BLOCKER-09940-SCOPE-0001` | Scope/non-scope not accepted |
| `BLOCKER-09940-SCHEMA-0001` | Message key schema not accepted |
| `BLOCKER-09940-SURFACE-0001` | Surface catalog not accepted |
| `BLOCKER-09940-AUDIENCE-0001` | Audience catalog not accepted |
| `BLOCKER-09940-CLASS-0001` | Message class catalog not accepted |
| `BLOCKER-09940-FALLBACK-0001` | Fallback rule not accepted |
| `BLOCKER-09940-PROMISE-0001` | Promise boundary not accepted |
| `BLOCKER-09940-FORMAT-0001` | File/data format not selected |
| `BLOCKER-09940-PATH-0001` | Target path not selected |
| `BLOCKER-09940-VALIDATION-0001` | Validation checklist not accepted |
| `BLOCKER-09940-CODING-0001` | Coding not authorized |

Open blockers prevent coding.

---

## 30. Coding Authorization Requirements

A future coding authorization packet must declare:

| Field | Required Value |
|---|---|
| Candidate ID | `CAND-09940-I18N-MESSAGE-001` |
| Package Name | `i18n_message_key_registry_static_v1` |
| Allowed Operations | Static message key registry file/catalog creation only |
| Prohibited Operations | Customer publication, runtime i18n loading, message sending, DB mutation, UI, AI/vector, provider/payment/POS/KDS |
| Target Paths | Explicit paths |
| File Format | Explicit format |
| Validation Command | Explicit or manual checklist |
| Rollback Plan | Explicit |
| Reviewers | Explicit |
| Final Decision | `CODING_ALLOWED_NARROW_SCOPE` |

Without this packet, coding remains unauthorized.

---

## 31. Relationship To Previous Documents

This document follows:

- `09930 Provider Evidence Registry Static Package Handoff And Capability Traceability Policy`

It references:

- `09670 Catch Menu Customer Surface Projection And i18n Naming Policy`
- `09740 i18n Message Key Registry And Customer Visible Text Review Policy`
- `09750 Catch & Order Status Message Catalog And Customer Safe State Mapping Policy`
- `09760 Catch Menu Status Surface And Order Handoff Message Mapping Policy`
- `09770 Support Admin Visible Message Boundary And Review Surface Mapping Policy`
- `09780 Customer Recovery Message Catalog And Compensation Review Boundary Policy`
- `09820 Value Recovery Rollback Reversal And Customer Correction Notice Policy`
- `09850 Mass Recovery Event Grouping And Customer Communication Control Policy`
- `09880 Incident Learning Boundary Test Matrix Update And Policy Patch Handoff`
- `09900 Controlled Implementation Candidate Template And First Package Selection Policy`
- `09910 Static Security Monitoring Catalog Registry Handoff And Coding Authorization Draft Policy`
- `09920 Boundary Test Matrix Static Package Handoff And Validation Mapping Policy`
- `09930 Provider Evidence Registry Static Package Handoff And Capability Traceability Policy`
- `09560` through `09930`

It prepares later planning for:

- explicit coding authorization packet
- static i18n message key registry creation
- Catch Menu status message catalog
- Catch & Order status message catalog
- support/admin message catalog
- recovery/compensation message catalog
- future customer-visible runtime message gates

This document is a static i18n message key registry handoff draft only.

It does not authorize coding.

---

## 32. Final Rule

The static i18n message key registry may become the fourth implementation package only if it remains static, non-runtime, reference-only, scope-locked, validation-ready, rollback-simple, and explicitly reviewed.

Every message key must declare surface, audience, message class, source reference, customer visibility status, runtime use status, fallback key, promise boundary, locale review status, and blockers.

Default status must remain `MESSAGE_RUNTIME_USE_NOT_AUTHORIZED` and `VIS_CUSTOMER_NOT_ALLOWED` unless a later separate package proves otherwise.

No customer-visible publication, runtime locale loading, support reply sending, AI-generated message sending, provider status publication, payment/refund confirmation, compensation promise, legal notice publication, or Franchise OS message engine may be included.

No static i18n message key registry implementation may proceed until a separate narrow authorization grants `CODING_ALLOWED_NARROW_SCOPE`, declares target paths and format, maps validation, resolves blockers, and defines rollback.
