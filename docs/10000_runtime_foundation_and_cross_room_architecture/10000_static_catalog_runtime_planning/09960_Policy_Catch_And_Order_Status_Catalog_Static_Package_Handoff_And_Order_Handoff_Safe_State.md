# 09960_Policy_Catch_And_Order_Status_Catalog_Static_Package_Handoff_And_Order_Handoff_Safe_State

## 1. Purpose

This document defines the Catch & Order Status Catalog Static Package Handoff and Order Handoff Safe State Policy.

The previous artifact `09950` defined the Catch Menu Status Catalog Static Package Handoff and Customer Safe Surface Policy.

This document prepares the sixth recommended implementation candidate as a narrow static Catch & Order status catalog handoff.

The purpose is to define how Catch & Order order states, POS handoff states, payment-checking states, KDS fulfillment states, provider-delay states, recovery-review states, staff-review states, degraded-operation states, and customer-safe order status messages should be represented before any Catch & Order runtime order flow begins.

This document is planning-only.

It does not authorize coding.

---

## 2. Scope

This policy applies to the candidate package:

`catch_order_status_catalog_static_v1`

The package may later include static status catalog records for:

1. Order draft
2. Order submitted
3. Order checking
4. POS handoff pending
5. POS accepted for review
6. POS handoff failed safely
7. Payment checking
8. Payment review required
9. KDS routing pending
10. KDS preparing
11. KDS delayed
12. KDS ready
13. Staff review required
14. Duplicate order risk
15. Provider delay
16. Degraded operation
17. Customer recovery review
18. Compensation review reference
19. Safe correction notice reference
20. Customer-safe fallback

This package must remain static, reference-only, and non-runtime.

---

## 3. Core Principle

Catch & Order is an order handoff surface, not automatic truth authority.

The correct rule is:

Order submitted is not POS accepted.
POS accepted is not payment confirmed.
Payment checking is not payment settled.
KDS preparing is not settlement truth.
KDS completed is not compensation approval.
Provider callback is not verified internal state.
Customer status is not root cause proof.
AI suggestion is not order authority.

Catch & Order must expose only customer-safe states while preserving internal authority boundaries.

---

## 4. Catalog Header

| Field | Value |
|---|---|
| Document ID | `09960` |
| Package ID | `catch_order_status_catalog_static_v1.handoff_draft` |
| Artifact Type | `STATIC_CATCH_ORDER_STATUS_CATALOG_HANDOFF_POLICY` |
| Version | `v1` |
| Planning Status | `HANDOFF_DRAFT` |
| Coding Status | `CODING_DEFERRED` |
| Runtime Authority | `CATCH_ORDER_RUNTIME_USE_NOT_AUTHORIZED` |
| Owner | `Product / i18n / Support / Security / Engineering / QA` |
| Dependencies | `09560` to `09950` |
| Provider Evidence Status | `REFERENCE_ONLY_IF_PROVIDER_RELATED` |
| i18n Requirement | `REQUIRED_FOR_ALL_CUSTOMER_SAFE_ORDER_STATUS_KEYS` |
| Audit Requirement | `IMPLEMENTATION_DECISION_AUDIT_REQUIRED_IF_CODED_LATER` |
| Security Requirement | `ORDER_HANDOFF_AUTHORITY_BOUNDARY_REQUIRED` |
| Review Requirement | `PRODUCT_I18N_SUPPORT_SECURITY_QA_ENGINEERING_REVIEW_REQUIRED` |
| Blocker Status | `CATCH_ORDER_STATUS_CATALOG_HANDOFF_REVIEW_REQUIRED` |

---

## 5. Candidate Package Identity

| Field | Value |
|---|---|
| Candidate ID | `CAND-09960-CATCH-ORDER-STATUS-001` |
| Package Name | `catch_order_status_catalog_static_v1` |
| Candidate Family | `CAND_CATCH_ORDER_STATUS_CATALOG` |
| Runtime Class | `STATIC_ORDER_STATUS_REFERENCE_ONLY` |
| Mutation Class | `NO_RUNTIME_MUTATION` |
| Customer Visibility | `NO_CUSTOMER_VISIBLE_PUBLICATION` |
| Provider Interaction | `NO_PROVIDER_CALL` |
| POS Interaction | `NO_POS_CALL` |
| Payment Interaction | `NO_PAYMENT_CALL` |
| KDS Interaction | `NO_KDS_CALL` |
| AI Interaction | `NO_AI_RUNTIME` |
| pgvector Interaction | `NO_VECTOR_INGESTION` |
| Archive Interaction | `NO_ARCHIVE_RESTORE_OR_DELETE` |
| Compensation Interaction | `NO_VALUE_ACTION` |
| Franchise OS Interaction | `REFERENCE_ONLY` |

This identity must be preserved if later coding is authorized.

---

## 6. Source Document Range

The package may reference:

- `09660 Catch & Order SaaS Runtime Boundary And Module Naming Policy`
- `09670 Catch Menu Customer Surface Projection And i18n Naming Policy`
- `09740 i18n Message Key Registry And Customer Visible Text Review Policy`
- `09750 Catch & Order Status Message Catalog And Customer Safe State Mapping Policy`
- `09760 Catch Menu Status Surface And Order Handoff Message Mapping Policy`
- `09770 Support Admin Visible Message Boundary And Review Surface Mapping Policy`
- `09780 Customer Recovery Message Catalog And Compensation Review Boundary Policy`
- `09800 Value Recovery Evidence Audit And Idempotency Review Packet Policy`
- `09810 Value Recovery Reconciliation And Partial Execution Closure Policy`
- `09850 Mass Recovery Event Grouping And Customer Communication Control Policy`
- `09880 Incident Learning Boundary Test Matrix Update And Policy Patch Handoff`
- `09920 Boundary Test Matrix Static Package Handoff And Validation Mapping Policy`
- `09940 i18n Message Key Registry Static Package Handoff And Locale Review Policy`
- `09950 Catch Menu Status Catalog Static Package Handoff And Customer Safe Surface Policy`
- `09560` through `09960`

Status records must cite source document and order handoff boundary context.

---

## 7. Allowed Work

If a later authorization grants coding, allowed work may be limited to:

1. Create static Catch & Order status catalog records.
2. Create order domain catalog references.
3. Create customer-safe order state catalog.
4. Create internal-to-safe-state mapping references.
5. Create POS/payment/KDS dependency references.
6. Create provider evidence dependency references.
7. Create i18n key references.
8. Create boundary test references.
9. Create validation checklist.
10. Create README/index references.

Allowed work must not execute order handoff.

---

## 8. Explicit Non-Scope

The following are excluded:

1. Runtime order flow
2. POS handoff execution
3. Payment execution
4. KDS ticket creation
5. Provider adapter
6. Webhook/callback handling
7. Customer UI rendering
8. Customer status publication
9. Support/admin workflow
10. Customer recovery workflow
11. Compensation/refund/coupon/point/wallet action
12. Runtime i18n loading
13. AI recommendation execution
14. pgvector retrieval execution
15. Archive/legal hold mutation
16. Franchise OS policy engine
17. Store staff task routing
18. Daemon/monitoring runtime
19. Database trigger/function
20. Production deployment

This package is status-catalog-only.

---

## 9. Catch & Order Status Record Schema

Each Catch & Order status record should include:

| Field | Required Meaning |
|---|---|
| `catch_order_status_id` | Stable status id |
| `status_key` | Stable status key |
| `surface` | Catch & Order surface |
| `domain` | Order, POS, payment, KDS, provider, recovery, etc. |
| `safe_state` | Customer-safe order state |
| `internal_state_refs` | Internal state references if any |
| `message_key` | i18n message key |
| `fallback_message_key` | Fallback i18n key |
| `customer_action` | Suggested customer action |
| `staff_action_required` | Whether staff action is required |
| `support_action_required` | Whether support action is required |
| `pos_dependency` | POS dependency |
| `payment_dependency` | Payment dependency |
| `kds_dependency` | KDS dependency |
| `provider_dependency` | Provider dependency |
| `recovery_dependency` | Recovery dependency |
| `compensation_dependency` | Compensation dependency |
| `runtime_use_status` | Runtime use status |
| `boundary_test_refs` | Boundary tests |
| `blocker_id` | Blocker if incomplete |

A Catch & Order status without message key and fallback key is incomplete.

---

## 10. Status ID Pattern

Recommended status id pattern:

`CO-STATUS-<DOMAIN>-<NUMBER>`

Examples:

| Status ID | Meaning |
|---|---|
| `CO-STATUS-ORDER-0001` | Order draft/submitted/checking |
| `CO-STATUS-POS-0001` | POS handoff status |
| `CO-STATUS-PAYMENT-0001` | Payment checking status |
| `CO-STATUS-KDS-0001` | KDS fulfillment status |
| `CO-STATUS-PROVIDER-0001` | Provider delay status |
| `CO-STATUS-STAFF-0001` | Staff review status |
| `CO-STATUS-SUPPORT-0001` | Support review status |
| `CO-STATUS-RECOVERY-0001` | Customer recovery status |
| `CO-STATUS-CORRECTION-0001` | Correction notice status |
| `CO-STATUS-FALLBACK-0001` | Safe fallback status |

Status ids must remain stable once referenced.

---

## 11. Catch & Order Domain Catalog

Initial domains may include:

| Domain | Meaning |
|---|---|
| `CO_DOMAIN_ORDER` | Order draft/submission/checking |
| `CO_DOMAIN_POS_HANDOFF` | POS handoff |
| `CO_DOMAIN_PAYMENT` | Payment checking/review |
| `CO_DOMAIN_KDS` | KDS fulfillment |
| `CO_DOMAIN_PROVIDER` | Provider delay/fallback |
| `CO_DOMAIN_STAFF_REVIEW` | Store staff review |
| `CO_DOMAIN_SUPPORT_REVIEW` | Support review |
| `CO_DOMAIN_RECOVERY` | Customer recovery |
| `CO_DOMAIN_COMPENSATION` | Compensation review reference |
| `CO_DOMAIN_CORRECTION` | Correction notice |
| `CO_DOMAIN_DEGRADED` | Degraded operation |
| `CO_DOMAIN_DUPLICATE_RISK` | Duplicate order/payment risk |
| `CO_DOMAIN_FALLBACK` | Safe fallback |

Domain does not imply runtime execution.

---

## 12. Customer Safe Order State Catalog

Initial customer-safe order states may include:

| Safe State | Meaning |
|---|---|
| `CO_SAFE_DRAFT` | Draft state |
| `CO_SAFE_SUBMITTED` | Submitted for checking |
| `CO_SAFE_CHECKING` | Checking order |
| `CO_SAFE_POS_REVIEW` | POS handoff under review |
| `CO_SAFE_PAYMENT_CHECKING` | Payment checking |
| `CO_SAFE_PAYMENT_REVIEW_REQUIRED` | Payment review required |
| `CO_SAFE_PREPARING` | Preparing, if verified safe |
| `CO_SAFE_DELAYED` | Delayed |
| `CO_SAFE_READY` | Ready, if verified safe |
| `CO_SAFE_STAFF_REVIEW_REQUIRED` | Staff review required |
| `CO_SAFE_SUPPORT_REVIEW_REQUIRED` | Support review required |
| `CO_SAFE_DUPLICATE_RISK_REVIEW` | Duplicate risk review |
| `CO_SAFE_PROVIDER_DELAY` | Temporary provider delay |
| `CO_SAFE_RECOVERY_REVIEW` | Recovery review |
| `CO_SAFE_CORRECTION_PENDING` | Correction pending |
| `CO_SAFE_DEGRADED_MODE` | Degraded operation |
| `CO_SAFE_FALLBACK` | Generic safe fallback |

Safe states must not expose raw internal states.

---

## 13. Runtime Use Status Catalog

Allowed runtime use statuses:

| Status | Meaning |
|---|---|
| `CATCH_ORDER_RUNTIME_USE_NOT_AUTHORIZED` | Runtime use prohibited |
| `CATCH_ORDER_REFERENCE_ONLY` | Reference only |
| `CATCH_ORDER_DRAFT_ONLY` | Draft only |
| `CATCH_ORDER_REVIEW_REQUIRED` | Review required |
| `CATCH_ORDER_BLOCKED` | Blocked |
| `CATCH_ORDER_DEPRECATED` | Deprecated |
| `CATCH_ORDER_RUNTIME_ALLOWED_BY_SEPARATE_PACKAGE` | Later separate approval only |

Default:

`CATCH_ORDER_RUNTIME_USE_NOT_AUTHORIZED`

No status may become runtime-active in this package.

---

## 14. Order Submission Status Rule

Order submission statuses must preserve:

- draft is not submitted
- submitted is not POS accepted
- submitted is not payment started
- submitted is not KDS created
- submitted is not inventory reserved unless separately confirmed
- submitted is not compensation/recovery eligibility
- duplicate submission risk must route to review
- customer-safe wording must remain conservative

Order submission is customer intent crossing into handoff review.

---

## 15. POS Handoff Status Rule

POS handoff statuses must preserve:

- handoff pending is not POS accepted
- POS accepted is not payment confirmed
- POS rejection must not expose raw POS error
- POS timeout must not blame customer
- POS duplicate risk must route to staff/support review
- POS accepted must remain separate from KDS and settlement
- offline/local state must not silently overwrite central truth

POS is transaction authority for order acceptance, not payment truth.

---

## 16. Payment Status Rule

Payment statuses must preserve:

- payment checking is not payment confirmed
- provider callback is not verified payment state
- refund requested is not refund confirmed
- wallet/point/coupon value is not applied until authority confirms
- duplicate payment risk must route to finance/support review
- payment uncertainty must not be hidden
- customer message must not overpromise

Payment-facing status requires strict evidence.

---

## 17. KDS Fulfillment Status Rule

KDS statuses must preserve:

- KDS routing pending is not preparing
- KDS ticket created is not settlement
- KDS preparing is not delivery/serving completion
- KDS ready must be verified before customer-visible use
- KDS completed is not compensation closure
- remake is not refund
- KDS delay does not prove provider/payment fault

KDS is kitchen execution visibility, not financial authority.

---

## 18. Provider Delay Status Rule

Provider delay statuses must preserve:

- provider delay cannot be named without evidence
- provider callback failure must not be shown raw
- provider timeout must use generic safe wording
- provider evidence remains internal
- provider-related customer message requires i18n key
- provider root cause must not be communicated before review

Provider state is not customer truth by default.

---

## 19. Staff Review Status Rule

Staff review statuses must preserve:

- staff review is not compensation approval
- staff review is not payment resolution
- staff review is not legal admission
- staff review is safe operational assistance
- staff-facing guidance must not expose security internals to customer
- staff review must not silently mutate order/payment/value

Staff review is a controlled human checkpoint.

---

## 20. Support Review Status Rule

Support review statuses must preserve:

- support view is not mutation authority
- support note is not compensation approval
- support draft is not customer-send
- support escalation is not closure
- support cannot release security containment
- support cannot override finance/legal/security gates

Support review is visibility and routing, not final authority.

---

## 21. Duplicate Risk Status Rule

Duplicate risk statuses must preserve:

- duplicate order risk must block blind repeat submission
- duplicate payment risk must block customer payment confirmation
- duplicate coupon/point/wallet risk must block value action
- idempotency reference is required before execution
- customer message must avoid blame and panic
- staff/support review should be routed safely

Duplicate prevention is part of customer trust.

---

## 22. Recovery And Compensation Reference Rule

Catch & Order statuses may reference recovery/compensation review only as safe status.

They must not:

- approve refund
- issue coupon
- adjust points
- credit wallet
- promise compensation
- confirm provider liability
- close recovery

Recovery and compensation require separate authority.

---

## 23. Degraded Operation Status Rule

Degraded operation statuses must preserve:

- degraded does not mean failed
- degraded does not expose containment/quarantine
- degraded does not expose provider/security root cause
- degraded may route to staff assistance
- degraded may use manual fallback wording
- degraded must not create silent duplicate order/payment

Degraded status supports continuity without unsafe disclosure.

---

## 24. AI And pgvector Status Rule

Catch & Order must not display:

- AI operational conclusion
- AI confidence
- AI blame suggestion
- AI compensation suggestion
- pgvector similar case
- pgvector similarity score
- internal recovery pattern
- raw support evidence

AI and pgvector must not become customer-facing order authority.

---

## 25. Franchise Policy Status Rule

Franchise-related Catch & Order statuses must preserve:

- HQ policy ceiling
- tenant/franchise policy layer
- owner/store policy boundary
- compensation authority matrix
- customer message consistency
- legal/finance/security precedence
- local override prohibition for high-risk states

Franchise OS policy cannot create inconsistent customer status truth.

---

## 26. Validation Checklist Candidate

Validation should confirm:

1. Status ids are unique.
2. Status keys are stable.
3. Domain is controlled.
4. Safe state is controlled.
5. Message key exists.
6. Fallback message key exists.
7. Runtime use status is not authorized.
8. POS state is not mapped as payment truth.
9. Payment state is not overpromised.
10. KDS state is not mapped as settlement truth.
11. Provider state is customer-safe.
12. Recovery/compensation state is review-only.
13. Boundary test references exist.
14. No customer data is included.
15. No raw provider/POS/payment/KDS payload is included.
16. No secrets are included.
17. Blockers are explicit.

Validation failure blocks Catch & Order runtime publication.

---

## 27. File Layout Candidate

If later authorized, the package may use a file layout such as:

| Path Candidate | Purpose |
|---|---|
| `catalogs/catch_order/status_catalog_index.md` | Human-readable Catch & Order status catalog index |
| `catalogs/catch_order/status_records.json` | Static status records |
| `catalogs/catch_order/domains.json` | Catch & Order domain catalog |
| `catalogs/catch_order/customer_safe_states.json` | Customer-safe order state catalog |
| `catalogs/catch_order/runtime_statuses.json` | Runtime use status catalog |
| `catalogs/catch_order/validation_checklist.md` | Validation checklist |
| `docs/implementation_candidates/CAND-09960-CATCH-ORDER-STATUS-001.md` | Candidate record |

This is a layout candidate only.

No files are authorized by this document.

---

## 28. Rollback Plan Candidate

Rollback for the static Catch & Order status catalog should be:

1. Revert added status catalog files.
2. Revert index references.
3. Mark incorrect status records as deprecated if already referenced.
4. Add blocker for downstream Catch & Order packages.
5. Restore previous static version.
6. Preserve review note if already circulated.

Rollback must not require customer notification because no publication is allowed.

---

## 29. Handoff Blockers

| Blocker ID | Meaning |
|---|---|
| `BLOCKER-09960-REVIEW-0001` | Handoff draft not reviewed |
| `BLOCKER-09960-SCOPE-0001` | Scope/non-scope not accepted |
| `BLOCKER-09960-SCHEMA-0001` | Status record schema not accepted |
| `BLOCKER-09960-DOMAIN-0001` | Domain catalog not accepted |
| `BLOCKER-09960-SAFE-STATE-0001` | Customer-safe order state catalog not accepted |
| `BLOCKER-09960-I18N-0001` | i18n key dependency not accepted |
| `BLOCKER-09960-POS-0001` | POS boundary rule not accepted |
| `BLOCKER-09960-PAYMENT-0001` | Payment boundary rule not accepted |
| `BLOCKER-09960-KDS-0001` | KDS boundary rule not accepted |
| `BLOCKER-09960-PROVIDER-0001` | Provider boundary rule not accepted |
| `BLOCKER-09960-FORMAT-0001` | File/data format not selected |
| `BLOCKER-09960-PATH-0001` | Target path not selected |
| `BLOCKER-09960-VALIDATION-0001` | Validation checklist not accepted |
| `BLOCKER-09960-CODING-0001` | Coding not authorized |

Open blockers prevent coding.

---

## 30. Coding Authorization Requirements

A future coding authorization packet must declare:

| Field | Required Value |
|---|---|
| Candidate ID | `CAND-09960-CATCH-ORDER-STATUS-001` |
| Package Name | `catch_order_status_catalog_static_v1` |
| Allowed Operations | Static Catch & Order status catalog file/catalog creation only |
| Prohibited Operations | Runtime order flow, customer UI, message publication, provider/payment/POS/KDS calls, AI/vector, DB mutation |
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

- `09950 Catch Menu Status Catalog Static Package Handoff And Customer Safe Surface Policy`

It references:

- `09660 Catch & Order SaaS Runtime Boundary And Module Naming Policy`
- `09670 Catch Menu Customer Surface Projection And i18n Naming Policy`
- `09740 i18n Message Key Registry And Customer Visible Text Review Policy`
- `09750 Catch & Order Status Message Catalog And Customer Safe State Mapping Policy`
- `09760 Catch Menu Status Surface And Order Handoff Message Mapping Policy`
- `09770 Support Admin Visible Message Boundary And Review Surface Mapping Policy`
- `09780 Customer Recovery Message Catalog And Compensation Review Boundary Policy`
- `09800 Value Recovery Evidence Audit And Idempotency Review Packet Policy`
- `09810 Value Recovery Reconciliation And Partial Execution Closure Policy`
- `09850 Mass Recovery Event Grouping And Customer Communication Control Policy`
- `09880 Incident Learning Boundary Test Matrix Update And Policy Patch Handoff`
- `09920 Boundary Test Matrix Static Package Handoff And Validation Mapping Policy`
- `09940 i18n Message Key Registry Static Package Handoff And Locale Review Policy`
- `09950 Catch Menu Status Catalog Static Package Handoff And Customer Safe Surface Policy`
- `09560` through `09950`

It prepares later planning for:

- explicit coding authorization packet
- static Catch & Order status catalog creation
- Catch & Order runtime order flow gate
- POS/payment/KDS provider readiness review
- support/admin recovery surface catalog
- future customer-visible order status runtime readiness

This document is a static Catch & Order status catalog handoff draft only.

It does not authorize coding.

---

## 32. Final Rule

The static Catch & Order status catalog may become the sixth implementation package only if it remains static, non-runtime, reference-only, scope-locked, validation-ready, rollback-simple, and explicitly reviewed.

Every Catch & Order status must declare domain, customer-safe state, message key, fallback key, runtime use status, POS/payment/KDS/provider/recovery boundaries, boundary test references, and blockers.

Default status must remain `CATCH_ORDER_RUNTIME_USE_NOT_AUTHORIZED`.

No runtime order flow, POS handoff, payment call, KDS ticket creation, provider adapter, customer UI, message publication, AI/vector execution, support/admin workflow, archive/legal mutation, compensation action, mass recovery workflow, or Franchise OS policy execution may be included.

No static Catch & Order status catalog implementation may proceed until a separate narrow authorization grants `CODING_ALLOWED_NARROW_SCOPE`, declares target paths and format, maps validation, resolves blockers, and defines rollback.
