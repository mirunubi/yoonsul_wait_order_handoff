# 09950_Policy_Catch_Menu_Status_Catalog_Static_Package_Handoff_And_Customer_Safe_Surface

## 1. Purpose

This document defines the Catch Menu Status Catalog Static Package Handoff and Customer Safe Surface Policy.

The previous artifact `09940` defined the i18n Message Key Registry Static Package Handoff and Locale Review Policy.

This document prepares the fifth recommended implementation candidate as a narrow static Catch Menu status catalog handoff.

The purpose is to define how Catch Menu customer-facing states, QR/NFC entry states, menu loading states, item availability states, price/allergen review states, order handoff states, payment-checking states, staff-review states, degraded operation states, and customer-safe fallback states should be represented before any Catch Menu runtime UI or customer-visible publication begins.

This document is planning-only.

It does not authorize coding.

---

## 2. Scope

This policy applies to the candidate package:

`catch_menu_status_catalog_static_v1`

The package may later include static status catalog records for:

1. Catch Menu QR entry
2. Catch Menu NFC entry
3. Menu loading
4. Menu ready
5. Menu stale/rechecking
6. Item available
7. Item sold out
8. Item temporarily unavailable
9. Price checking
10. Allergen review required
11. Cart available
12. Cart blocked
13. Order handoff checking
14. Order handoff accepted-for-review
15. Payment checking
16. Staff assistance required
17. Provider delay
18. Degraded operation
19. Customer-safe error
20. Customer-safe fallback

This package must remain static, reference-only, and non-runtime.

---

## 3. Core Principle

Catch Menu is a customer-safe surface, not the source of operational truth.

The correct rule is:

Menu projection is not source of truth.
Customer status is not provider truth.
Item shown is not item guaranteed.
Price displayed is not settlement truth without review.
Payment checking is not payment confirmed.
Order handoff request is not POS acceptance.
AI suggestion is not customer status.
Fallback message is not operational closure.

Catch Menu must hide unsafe internal states and expose only reviewed customer-safe states.

---

## 4. Catalog Header

| Field | Value |
|---|---|
| Document ID | `09950` |
| Package ID | `catch_menu_status_catalog_static_v1.handoff_draft` |
| Artifact Type | `STATIC_CATCH_MENU_STATUS_CATALOG_HANDOFF_POLICY` |
| Version | `v1` |
| Planning Status | `HANDOFF_DRAFT` |
| Coding Status | `CODING_DEFERRED` |
| Runtime Authority | `CATCH_MENU_RUNTIME_USE_NOT_AUTHORIZED` |
| Owner | `Product / i18n / Support / Security / Engineering` |
| Dependencies | `09560` to `09940` |
| Provider Evidence Status | `REFERENCE_ONLY_IF_PROVIDER_RELATED` |
| i18n Requirement | `REQUIRED_FOR_ALL_CUSTOMER_SAFE_STATUS_KEYS` |
| Audit Requirement | `IMPLEMENTATION_DECISION_AUDIT_REQUIRED_IF_CODED_LATER` |
| Security Requirement | `CUSTOMER_SAFE_SURFACE_BOUNDARY_REQUIRED` |
| Review Requirement | `PRODUCT_I18N_SUPPORT_SECURITY_QA_ENGINEERING_REVIEW_REQUIRED` |
| Blocker Status | `CATCH_MENU_STATUS_CATALOG_HANDOFF_REVIEW_REQUIRED` |

---

## 5. Candidate Package Identity

| Field | Value |
|---|---|
| Candidate ID | `CAND-09950-CATCH-MENU-STATUS-001` |
| Package Name | `catch_menu_status_catalog_static_v1` |
| Candidate Family | `CAND_CATCH_MENU_STATUS_CATALOG` |
| Runtime Class | `STATIC_CUSTOMER_STATUS_REFERENCE_ONLY` |
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

- `09660 Catch & Order SaaS Runtime Boundary And Module Naming Policy`
- `09670 Catch Menu Customer Surface Projection And i18n Naming Policy`
- `09740 i18n Message Key Registry And Customer Visible Text Review Policy`
- `09750 Catch & Order Status Message Catalog And Customer Safe State Mapping Policy`
- `09760 Catch Menu Status Surface And Order Handoff Message Mapping Policy`
- `09780 Customer Recovery Message Catalog And Compensation Review Boundary Policy`
- `09850 Mass Recovery Event Grouping And Customer Communication Control Policy`
- `09880 Incident Learning Boundary Test Matrix Update And Policy Patch Handoff`
- `09910 Static Security Monitoring Catalog Registry Handoff And Coding Authorization Draft Policy`
- `09920 Boundary Test Matrix Static Package Handoff And Validation Mapping Policy`
- `09940 i18n Message Key Registry Static Package Handoff And Locale Review Policy`
- `09560` through `09950`

Status records must cite source document and customer-safe mapping context.

---

## 7. Allowed Work

If a later authorization grants coding, allowed work may be limited to:

1. Create static Catch Menu status catalog records.
2. Create Catch Menu surface catalog references.
3. Create customer-safe state catalog.
4. Create internal-to-safe-state mapping references.
5. Create i18n key references.
6. Create fallback status references.
7. Create provider evidence dependency references.
8. Create boundary test references.
9. Create validation checklist.
10. Create README/index references.

Allowed work must not render customer UI.

---

## 8. Explicit Non-Scope

The following are excluded:

1. Customer UI implementation
2. QR/NFC runtime handling
3. Menu projection runtime
4. Menu cache refresh runtime
5. POS handoff runtime
6. Payment runtime
7. KDS runtime
8. Provider adapter
9. Customer message publication
10. Support/admin workflow
11. AI recommendation display
12. pgvector retrieval display
13. Runtime i18n loading
14. Customer recovery workflow
15. Coupon/point/wallet/refund action
16. Archive/legal hold mutation
17. Franchise OS policy engine
18. Live availability calculation
19. Live price calculation
20. Live allergen publication

This package is status-catalog-only.

---

## 9. Catch Menu Status Record Schema

Each Catch Menu status record should include:

| Field | Required Meaning |
|---|---|
| `catch_menu_status_id` | Stable status id |
| `status_key` | Stable status key |
| `surface` | Catch Menu surface |
| `domain` | Menu, item, cart, order handoff, payment, etc. |
| `safe_state` | Customer-safe state |
| `internal_state_refs` | Internal state references if any |
| `message_key` | i18n message key |
| `fallback_message_key` | Fallback i18n key |
| `customer_action` | Suggested customer action |
| `staff_action_required` | Whether staff action is required |
| `provider_dependency` | Provider dependency |
| `payment_dependency` | Payment dependency |
| `pos_dependency` | POS dependency |
| `kds_dependency` | KDS dependency |
| `allergen_review_status` | Allergen review if applicable |
| `price_review_status` | Price review if applicable |
| `runtime_use_status` | Runtime use status |
| `boundary_test_refs` | Boundary tests |
| `blocker_id` | Blocker if incomplete |

A Catch Menu status without message key and fallback key is incomplete.

---

## 10. Status ID Pattern

Recommended status id pattern:

`CM-STATUS-<DOMAIN>-<NUMBER>`

Examples:

| Status ID | Meaning |
|---|---|
| `CM-STATUS-ENTRY-0001` | QR/NFC entry status |
| `CM-STATUS-MENU-0001` | Menu loading/ready status |
| `CM-STATUS-ITEM-0001` | Item availability status |
| `CM-STATUS-PRICE-0001` | Price checking status |
| `CM-STATUS-ALLERGEN-0001` | Allergen review status |
| `CM-STATUS-CART-0001` | Cart status |
| `CM-STATUS-ORDER-0001` | Order handoff status |
| `CM-STATUS-PAYMENT-0001` | Payment checking status |
| `CM-STATUS-FALLBACK-0001` | Safe fallback status |
| `CM-STATUS-STAFF-0001` | Staff assistance status |

Status ids must remain stable once referenced.

---

## 11. Catch Menu Domain Catalog

Initial domains may include:

| Domain | Meaning |
|---|---|
| `CM_DOMAIN_ENTRY` | QR/NFC entry |
| `CM_DOMAIN_SESSION` | Customer session |
| `CM_DOMAIN_MENU` | Menu projection |
| `CM_DOMAIN_CATEGORY` | Category display |
| `CM_DOMAIN_ITEM` | Item display |
| `CM_DOMAIN_PRICE` | Price display |
| `CM_DOMAIN_ALLERGEN` | Allergen/safety display |
| `CM_DOMAIN_AVAILABILITY` | Availability/sold-out |
| `CM_DOMAIN_CART` | Cart |
| `CM_DOMAIN_ORDER_HANDOFF` | Order handoff request |
| `CM_DOMAIN_PAYMENT` | Payment checking |
| `CM_DOMAIN_PROVIDER` | Provider delay/fallback |
| `CM_DOMAIN_STAFF_REVIEW` | Staff assistance/review |
| `CM_DOMAIN_DEGRADED` | Degraded operation |
| `CM_DOMAIN_FALLBACK` | Safe fallback |

Domain does not imply runtime execution.

---

## 12. Customer Safe State Catalog

Initial customer-safe states may include:

| Safe State | Meaning |
|---|---|
| `CM_SAFE_LOADING` | Loading safely |
| `CM_SAFE_READY` | Ready for viewing |
| `CM_SAFE_REFRESHING` | Refreshing/checking |
| `CM_SAFE_TEMPORARILY_UNAVAILABLE` | Temporarily unavailable |
| `CM_SAFE_SOLD_OUT` | Sold out |
| `CM_SAFE_PRICE_CHECKING` | Price checking |
| `CM_SAFE_ALLERGEN_REVIEW_REQUIRED` | Allergen review needed |
| `CM_SAFE_CART_AVAILABLE` | Cart available |
| `CM_SAFE_CART_BLOCKED` | Cart blocked safely |
| `CM_SAFE_ORDER_CHECKING` | Order request checking |
| `CM_SAFE_ORDER_REVIEW_REQUIRED` | Order review required |
| `CM_SAFE_PAYMENT_CHECKING` | Payment checking |
| `CM_SAFE_STAFF_ASSISTANCE_REQUIRED` | Staff assistance needed |
| `CM_SAFE_PROVIDER_DELAY` | Temporary delay |
| `CM_SAFE_DEGRADED_MODE` | Degraded mode |
| `CM_SAFE_FALLBACK` | Generic safe fallback |

Safe state must not expose raw internal errors.

---

## 13. Runtime Use Status Catalog

Allowed runtime use statuses:

| Status | Meaning |
|---|---|
| `CATCH_MENU_RUNTIME_USE_NOT_AUTHORIZED` | Runtime use prohibited |
| `CATCH_MENU_REFERENCE_ONLY` | Reference only |
| `CATCH_MENU_DRAFT_ONLY` | Draft only |
| `CATCH_MENU_REVIEW_REQUIRED` | Review required |
| `CATCH_MENU_BLOCKED` | Blocked |
| `CATCH_MENU_DEPRECATED` | Deprecated |
| `CATCH_MENU_RUNTIME_ALLOWED_BY_SEPARATE_PACKAGE` | Later separate approval only |

Default:

`CATCH_MENU_RUNTIME_USE_NOT_AUTHORIZED`

No status may become runtime-active in this package.

---

## 14. QR NFC Entry Status Rule

QR/NFC entry statuses must preserve:

- scanned does not equal authenticated
- scanned does not equal table confirmed
- QR/NFC availability does not equal ordering enabled
- invalid QR/NFC should use safe fallback
- expired QR/NFC should route to staff assistance
- table/session mismatch must not expose internal identifiers
- re-entry should not create duplicate order authority

Entry status is customer-safe navigation only.

---

## 15. Menu Loading And Ready Status Rule

Menu loading/ready statuses must preserve:

- menu loading does not imply fresh provider sync
- menu ready does not guarantee item availability
- stale menu must be safe and refreshable
- projection source must not be exposed raw
- external projection mismatch must route to safe fallback
- menu version issues must not expose internal version data
- degraded operation should show safe guidance

Menu projection is not source of truth.

---

## 16. Item Availability Status Rule

Item availability statuses must preserve:

- item visible does not guarantee availability
- sold-out state must be customer-safe
- temporary unavailable state must not blame provider/store unfairly
- availability uncertainty should route to staff review
- unavailable item should not silently remain orderable
- replacement recommendation must not override allergen/safety review

Availability is customer guidance, not final operational truth.

---

## 17. Price Status Rule

Price statuses must preserve:

- displayed price is projection until confirmed
- price checking must not promise final settlement
- price mismatch must route to review
- discount/coupon/wallet price must not be confirmed before value authority
- external provider price mismatch must not be blamed without evidence
- customer-safe correction wording must be reviewed

Price text affects customer trust and value recovery.

---

## 18. Allergen Safety Status Rule

Allergen/safety statuses must preserve:

- allergen info must use approved source
- uncertain allergen data must block unsafe publication
- missing locale must use conservative fallback
- AI-generated allergen text is not allowed without review
- external allergen projection requires evidence
- customer should be routed to staff assistance when uncertain

Allergen/safety status is high-risk.

---

## 19. Cart Status Rule

Cart statuses must preserve:

- item in cart does not equal item reserved
- cart total does not equal final payment amount
- cart available does not equal POS accepted
- cart blocked must show safe reason
- unavailable item must require customer review
- coupon/point/wallet estimate must not imply value approval
- cart recovery must not duplicate order

Cart is a draft customer intent state.

---

## 20. Order Handoff Status Rule

Order handoff statuses must preserve:

- order request is not POS accepted
- POS accepted is not payment confirmed
- handoff checking must use customer-safe message
- duplicate handoff risk must route to staff review
- provider/POS error must not be shown raw
- fallback must not create silent duplicate order
- customer should receive safe guidance only

Order handoff is a boundary-sensitive state.

---

## 21. Payment Checking Status Rule

Payment statuses in Catch Menu must preserve:

- payment checking is not payment confirmed
- refund/cancel/checking must not overpromise
- provider callback is not verified payment state
- wallet/point/coupon value must not be confirmed without authority
- payment uncertainty routes to support or staff review
- duplicate payment risk must not be hidden

Payment-facing text requires stricter review.

---

## 22. Staff Assistance Status Rule

Staff assistance statuses must preserve:

- staff assistance does not mean fault admitted
- staff assistance does not mean compensation approved
- staff assistance does not mean payment resolved
- staff assistance may help customer continue safely
- staff route must not expose internal security/provider state
- staff message key must be controlled

Staff assistance is safe handoff, not closure.

---

## 23. Provider Delay Status Rule

Provider delay statuses must preserve:

- provider delay cannot be blamed without evidence
- raw provider status must not be shown
- temporary delay wording should be generic
- customer action should be safe and limited
- provider evidence status should remain internal
- escalation route should be internal

Provider state is not customer truth without review.

---

## 24. Degraded Operation Status Rule

Degraded operation statuses must preserve:

- degraded does not mean failed
- degraded does not expose security containment
- degraded does not expose quarantine
- degraded does not expose internal outage cause
- fallback guidance must be safe
- manual staff assistance may be suggested
- customer order/payment promise must remain conservative

Degraded mode is customer continuity, not internal disclosure.

---

## 25. AI And pgvector Surface Rule

Catch Menu must not display:

- AI reasoning
- AI confidence
- AI-generated operational conclusion
- pgvector similar case
- pgvector score
- internal recommendation
- raw support context
- unreviewed AI-generated menu/allergen text

AI and pgvector may not become customer-facing authority.

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
8. Internal state mapping does not expose raw errors.
9. Payment-related statuses use conservative wording.
10. Allergen-related statuses require review.
11. Provider-related statuses link provider evidence status.
12. Boundary test references exist.
13. No customer data is included.
14. No raw provider payload is included.
15. No secrets are included.
16. Blockers are explicit.

Validation failure blocks Catch Menu runtime publication.

---

## 27. File Layout Candidate

If later authorized, the package may use a file layout such as:

| Path Candidate | Purpose |
|---|---|
| `catalogs/catch_menu/status_catalog_index.md` | Human-readable Catch Menu status catalog index |
| `catalogs/catch_menu/status_records.json` | Static status records |
| `catalogs/catch_menu/domains.json` | Catch Menu domain catalog |
| `catalogs/catch_menu/customer_safe_states.json` | Customer-safe state catalog |
| `catalogs/catch_menu/runtime_statuses.json` | Runtime use status catalog |
| `catalogs/catch_menu/validation_checklist.md` | Validation checklist |
| `docs/implementation_candidates/CAND-09950-CATCH-MENU-STATUS-001.md` | Candidate record |

This is a layout candidate only.

No files are authorized by this document.

---

## 28. Rollback Plan Candidate

Rollback for the static Catch Menu status catalog should be:

1. Revert added status catalog files.
2. Revert index references.
3. Mark incorrect status records as deprecated if already referenced.
4. Add blocker for downstream Catch Menu packages.
5. Restore previous static version.
6. Preserve review note if already circulated.

Rollback must not require customer notification because no publication is allowed.

---

## 29. Handoff Blockers

| Blocker ID | Meaning |
|---|---|
| `BLOCKER-09950-REVIEW-0001` | Handoff draft not reviewed |
| `BLOCKER-09950-SCOPE-0001` | Scope/non-scope not accepted |
| `BLOCKER-09950-SCHEMA-0001` | Status record schema not accepted |
| `BLOCKER-09950-DOMAIN-0001` | Domain catalog not accepted |
| `BLOCKER-09950-SAFE-STATE-0001` | Customer-safe state catalog not accepted |
| `BLOCKER-09950-I18N-0001` | i18n key dependency not accepted |
| `BLOCKER-09950-PROVIDER-0001` | Provider dependency rule not accepted |
| `BLOCKER-09950-PAYMENT-0001` | Payment status rule not accepted |
| `BLOCKER-09950-ALLERGEN-0001` | Allergen status rule not accepted |
| `BLOCKER-09950-FORMAT-0001` | File/data format not selected |
| `BLOCKER-09950-PATH-0001` | Target path not selected |
| `BLOCKER-09950-VALIDATION-0001` | Validation checklist not accepted |
| `BLOCKER-09950-CODING-0001` | Coding not authorized |

Open blockers prevent coding.

---

## 30. Coding Authorization Requirements

A future coding authorization packet must declare:

| Field | Required Value |
|---|---|
| Candidate ID | `CAND-09950-CATCH-MENU-STATUS-001` |
| Package Name | `catch_menu_status_catalog_static_v1` |
| Allowed Operations | Static Catch Menu status catalog file/catalog creation only |
| Prohibited Operations | Customer UI, runtime menu projection, message publication, provider/payment/POS/KDS calls, AI/vector, DB mutation |
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

- `09940 i18n Message Key Registry Static Package Handoff And Locale Review Policy`

It references:

- `09660 Catch & Order SaaS Runtime Boundary And Module Naming Policy`
- `09670 Catch Menu Customer Surface Projection And i18n Naming Policy`
- `09740 i18n Message Key Registry And Customer Visible Text Review Policy`
- `09750 Catch & Order Status Message Catalog And Customer Safe State Mapping Policy`
- `09760 Catch Menu Status Surface And Order Handoff Message Mapping Policy`
- `09780 Customer Recovery Message Catalog And Compensation Review Boundary Policy`
- `09850 Mass Recovery Event Grouping And Customer Communication Control Policy`
- `09880 Incident Learning Boundary Test Matrix Update And Policy Patch Handoff`
- `09910 Static Security Monitoring Catalog Registry Handoff And Coding Authorization Draft Policy`
- `09920 Boundary Test Matrix Static Package Handoff And Validation Mapping Policy`
- `09940 i18n Message Key Registry Static Package Handoff And Locale Review Policy`
- `09560` through `09940`

It prepares later planning for:

- explicit coding authorization packet
- static Catch Menu status catalog creation
- Catch Menu customer-safe UI runtime gate
- Catch & Order status catalog
- support/admin recovery surface catalog
- future customer-visible message runtime readiness

This document is a static Catch Menu status catalog handoff draft only.

It does not authorize coding.

---

## 32. Final Rule

The static Catch Menu status catalog may become the fifth implementation package only if it remains static, non-runtime, reference-only, scope-locked, validation-ready, rollback-simple, and explicitly reviewed.

Every Catch Menu status must declare domain, customer-safe state, message key, fallback key, runtime use status, dependency boundaries, boundary test references, and blockers.

Default status must remain `CATCH_MENU_RUNTIME_USE_NOT_AUTHORIZED`.

No customer UI, QR/NFC runtime, menu projection runtime, order handoff, payment/POS/KDS call, provider adapter, message publication, AI/vector display, support/admin workflow, archive/legal mutation, compensation action, or Franchise OS policy execution may be included.

No static Catch Menu status catalog implementation may proceed until a separate narrow authorization grants `CODING_ALLOWED_NARROW_SCOPE`, declares target paths and format, maps validation, resolves blockers, and defines rollback.
