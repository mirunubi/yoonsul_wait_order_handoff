# 09760 Catch Menu Status Surface And Order Handoff Message Mapping Policy

## 1. Purpose

This document defines the Catch Menu Status Surface and Order Handoff Message Mapping Policy.

The previous artifact `09750` defined the Catch & Order status message catalog and customer-safe state mapping policy.

This document applies the same customer-safe status principles specifically to the Catch Menu surface.

Catch Menu is the customer-facing menu access surface.

Catch Menu must remain simple, friendly, and fast, while still preserving controlled source projection, order handoff boundaries, safe status wording, i18n keys, support handoff, and customer recovery rules.

The purpose is to ensure that Catch Menu does not accidentally become a raw runtime surface for POS, payment, KDS, provider, security, AI, pgvector, archive, or support/admin internals.

This document is planning-only.

It does not authorize coding.

---

## 2. Scope

This policy applies to Catch Menu customer-facing status and handoff messaging for:

1. QR entry
2. NFC entry
3. Table menu entry
4. Store menu entry
5. Waiting-stage menu entry
6. Menu loading state
7. Menu projection state
8. Item availability state
9. Sold-out state
10. Price display state
11. Allergen/safety display state
12. Cart handoff state
13. Order handoff to Catch & Order
14. Customer-safe order status handoff
15. Payment status handoff if visible
16. KDS/fulfillment status handoff if visible
17. Provider delay/fallback message
18. Support/staff assistance handoff
19. Customer recovery notice
20. External projection fallback

This document does not create UI, screens, translation files, runtime APIs, QR/NFC logic, order logic, or customer-facing production text.

---

## 3. Core Principle

Catch Menu must show only safe customer-facing meaning.

The correct rule is:

Menu view is not order.
Cart is not accepted order.
Order handoff is not POS acceptance.
POS acceptance is not payment confirmation.
KDS status is not financial truth.
Provider delay is not customer blame.
Security state is not customer text.
AI/vector state is not customer text.

Catch Menu must guide the customer without exposing internal architecture.

---

## 4. Catalog Header

| Field | Value |
|---|---|
| Document ID | `09760` |
| Package ID | `catch_menu.status_surface.order_handoff_message_mapping.v1` |
| Artifact Type | `CATCH_MENU_STATUS_SURFACE_POLICY` |
| Version | `v1` |
| Planning Status | `FOUNDATION_CANDIDATE` |
| Coding Status | `CODING_DEFERRED` |
| Runtime Authority | `SURFACE_MAPPING_PLANNING_ONLY` |
| Owner | `Product / Catch Menu / i18n / Customer Experience / Security` |
| Dependencies | `09560` to `09750` |
| Provider Evidence Status | `CARRY_FORWARD_IF_PROVIDER_STATUS_VISIBLE` |
| i18n Requirement | `REQUIRED_FOR_ALL_VISIBLE_STATUS_MESSAGES` |
| Audit Requirement | `REQUIRED_FOR_HIGH_RISK_VISIBLE_STATUS_OR_RECOVERY` |
| Security Requirement | `CUSTOMER_SURFACE_STATUS_BOUNDARY_REQUIRED` |
| Review Requirement | `PRODUCT_I18N_SECURITY_SUPPORT_REVIEW_REQUIRED` |
| Blocker Status | `CATCH_MENU_STATUS_SURFACE_REVIEW_REQUIRED` |

---

## 5. Catch Menu Status Surface Definition

A Catch Menu status surface is any customer-facing screen, message, label, badge, banner, modal, button state, fallback text, or external projection text that communicates menu, order, availability, payment, fulfillment, support, or recovery status.

Examples:

- menu loading banner
- unavailable item badge
- sold-out label
- price review fallback
- allergen notice
- order handoff confirmation
- staff review notice
- temporary delay notice
- support assistance notice
- payment checking notice
- pickup-ready notice
- external projection stale notice

A status surface must always map to a controlled i18n key.

---

## 6. Catch Menu Status Layer Catalog

Catch Menu should separate status layers.

| Layer | Meaning |
|---|---|
| `MENU_SURFACE_INTERNAL_STATE` | Internal menu/projection/entry state |
| `MENU_SURFACE_CUSTOMER_SAFE_STATE` | Customer-safe visible state |
| `MENU_SURFACE_HANDOFF_STATE` | Handoff to Catch & Order |
| `MENU_SURFACE_SUPPORT_STATE` | Staff/support assistance state |
| `MENU_SURFACE_EXTERNAL_STATE` | External projection state |
| `MENU_SURFACE_FALLBACK_STATE` | Degraded/fallback state |

Only customer-safe states may be displayed.

---

## 7. Catch Menu Customer Safe State Families

| Safe State Family | Meaning |
|---|---|
| `CATCH_MENU_STATUS_LOADING` | Menu is loading |
| `CATCH_MENU_STATUS_READY` | Menu is ready |
| `CATCH_MENU_STATUS_REFRESHING` | Menu is being refreshed |
| `CATCH_MENU_STATUS_ITEM_AVAILABLE` | Item is available |
| `CATCH_MENU_STATUS_ITEM_UNAVAILABLE` | Item is unavailable |
| `CATCH_MENU_STATUS_SOLD_OUT` | Item is sold out |
| `CATCH_MENU_STATUS_LIMITED` | Item is limited |
| `CATCH_MENU_STATUS_PRICE_CHECKING` | Price information is being checked |
| `CATCH_MENU_STATUS_ALLERGEN_NOTICE` | Allergen/safety notice |
| `CATCH_MENU_STATUS_CART_READY` | Cart can continue |
| `CATCH_MENU_STATUS_ORDER_HANDOFF_READY` | Order handoff can continue |
| `CATCH_MENU_STATUS_ORDER_CONFIRMING` | Order is being confirmed |
| `CATCH_MENU_STATUS_PAYMENT_CHECKING` | Payment is being checked |
| `CATCH_MENU_STATUS_PREPARING` | Order is being prepared |
| `CATCH_MENU_STATUS_READY_FOR_PICKUP` | Ready for pickup |
| `CATCH_MENU_STATUS_STAFF_REVIEW` | Staff review is required |
| `CATCH_MENU_STATUS_SUPPORT_REVIEW` | Support review is in progress |
| `CATCH_MENU_STATUS_TEMPORARY_DELAY` | Temporary delay |
| `CATCH_MENU_STATUS_SAFE_FALLBACK` | Safe fallback |

These are customer-facing families, not runtime authority states.

---

## 8. Catch Menu Status Mapping Record Schema

Each Catch Menu status mapping should include:

| Field | Required Meaning |
|---|---|
| `mapping_id` | Stable mapping id |
| `surface_type` | QR, NFC, table, store, waiting, external, etc. |
| `internal_state` | Internal source state |
| `source_domain` | Menu, order, payment, KDS, provider, support, etc. |
| `source_authority` | Authority boundary |
| `safe_state_family` | Customer-safe state |
| `message_key` | i18n key |
| `fallback_key` | Fallback i18n key |
| `customer_action` | Customer action if any |
| `staff_action` | Staff/support action if any |
| `support_route` | Support route if needed |
| `customer_visibility` | Visibility class |
| `content_review_status` | Content review |
| `i18n_review_status` | i18n review |
| `legal_review_status` | Legal review if needed |
| `provider_evidence_status` | Provider evidence if relevant |
| `audit_required` | Audit requirement |
| `status` | Mapping status |
| `blocker_id` | Blocker if incomplete |

Visible mappings without `message_key` and `fallback_key` are incomplete.

---

## 9. Message Key Namespace

Recommended Catch Menu namespace:

`catch_menu.<surface>.<domain>.<safe_state>.<message_type>`

Examples:

| Key | Meaning |
|---|---|
| `catch_menu.qr.entry.loading.status` | QR entry loading |
| `catch_menu.nfc.entry.invalid.notice` | NFC entry invalid |
| `catch_menu.menu.loading.status` | Menu loading |
| `catch_menu.menu.ready.status` | Menu ready |
| `catch_menu.menu.refreshing.notice` | Menu refreshing |
| `catch_menu.item.unavailable.notice` | Item unavailable |
| `catch_menu.item.sold_out.notice` | Sold-out notice |
| `catch_menu.price.checking.notice` | Price checking notice |
| `catch_menu.allergen.notice.warning` | Allergen warning |
| `catch_menu.cart.ready.status` | Cart ready |
| `catch_menu.order.handoff.ready.status` | Order handoff ready |
| `catch_menu.order.confirming.status` | Order confirming |
| `catch_menu.support.staff_review.notice` | Staff review notice |
| `catch_menu.fallback.temporary_delay.notice` | Temporary delay fallback |

All keys must be registered in the i18n message key registry.

---

## 10. QR Entry Status Mapping Rule

QR entry must be scoped and safe.

Examples:

| Internal State | Customer Safe Direction |
|---|---|
| `QR_ENTRY_VALID` | Menu is opening |
| `QR_ENTRY_LOADING` | Menu is loading |
| `QR_TOKEN_STALE` | This menu link needs to be refreshed |
| `QR_STORE_CONTEXT_MISSING` | Store information is being checked |
| `QR_TABLE_CONTEXT_MISSING` | Staff may help confirm your table |
| `QR_SCOPE_MISMATCH` | This link cannot be used here |
| `QR_ENTRY_BLOCKED` | Staff assistance may be needed |

QR entry must not expose token details.

---

## 11. NFC Entry Status Mapping Rule

NFC entry must remain customer-safe.

Examples:

| Internal State | Customer Safe Direction |
|---|---|
| `NFC_ENTRY_VALID` | Menu is opening |
| `NFC_ENTRY_LOADING` | Menu is loading |
| `NFC_TOKEN_STALE` | This menu tap needs to be refreshed |
| `NFC_TAG_UNKNOWN` | Staff assistance may be needed |
| `NFC_STORE_CONTEXT_MISSING` | Store information is being checked |
| `NFC_TABLE_CONTEXT_UNCERTAIN` | Staff may help confirm your table |
| `NFC_ENTRY_BLOCKED` | Staff assistance may be needed |

NFC tag identity is not customer identity.

---

## 12. Menu Loading And Projection Mapping Rule

Menu projection states must not show internal source errors.

Examples:

| Internal State | Customer Safe Direction |
|---|---|
| `MENU_SOURCE_READY` | Menu is ready |
| `MENU_SOURCE_LOADING` | Menu is loading |
| `MENU_PROJECTION_APPROVED` | Menu is ready |
| `MENU_PROJECTION_STALE` | Menu information is being refreshed |
| `MENU_PROJECTION_SOURCE_MISSING` | Menu is temporarily unavailable |
| `MENU_PROJECTION_BLOCKED` | Menu is temporarily unavailable |
| `MENU_EXTERNAL_SYNC_PENDING` | Menu information is being updated |
| `MENU_I18N_KEY_MISSING` | Safe fallback message |

Menu projection is not source of truth.

---

## 13. Item Availability Mapping Rule

Availability messages must be store-scoped.

Examples:

| Internal State | Customer Safe Direction |
|---|---|
| `ITEM_AVAILABLE` | Item is available |
| `ITEM_LIMITED` | Limited quantity available |
| `ITEM_SOLD_OUT` | Sold out |
| `ITEM_UNAVAILABLE_TIME_WINDOW` | Not available at this time |
| `ITEM_STORE_UNAVAILABLE` | Not available at this store |
| `ITEM_AVAILABILITY_STALE` | Availability is being checked |
| `ITEM_MANUAL_REVIEW_REQUIRED` | Staff is checking availability |

Availability must not leak across stores.

---

## 14. Price Mapping Rule

Price text must be controlled.

Examples:

| Internal State | Customer Safe Direction |
|---|---|
| `PRICE_APPROVED` | Price may be displayed |
| `PRICE_DISCOUNT_AVAILABLE` | Discount may be displayed if source-approved |
| `PRICE_CHANGED_REVIEW_REQUIRED` | Price is being checked |
| `PRICE_SOURCE_MISSING` | Price cannot be confirmed right now |
| `PRICE_MISMATCH_DETECTED` | Staff review is required |
| `COUPON_PRICE_PENDING` | Discount is being checked |

Catch Menu must not show stale price as final.

---

## 15. Allergen Safety Mapping Rule

Allergen and safety text must be conservative.

Examples:

| Internal State | Customer Safe Direction |
|---|---|
| `ALLERGEN_SOURCE_APPROVED` | Allergen notice may be shown |
| `ALLERGEN_TRANSLATION_APPROVED` | Locale allergen notice may be shown |
| `ALLERGEN_SOURCE_MISSING` | Staff confirmation may be needed |
| `ALLERGEN_REVIEW_REQUIRED` | Safety information is being reviewed |
| `ALLERGEN_TRANSLATION_REVIEW_REQUIRED` | Translation review required |
| `ALLERGEN_AI_TEXT_UNAPPROVED` | Do not show AI text |

Safety text requires review before production.

---

## 16. Cart And Order Handoff Mapping Rule

Catch Menu may hand off to Catch & Order.

Examples:

| Internal State | Customer Safe Direction |
|---|---|
| `CART_CREATED` | Cart started |
| `CART_READY_FOR_HANDOFF` | Ready to continue order |
| `CART_ITEM_UNAVAILABLE` | Some items need to be checked |
| `CART_PRICE_REVIEW_REQUIRED` | Order details need checking |
| `ORDER_HANDOFF_READY` | Continue to order |
| `ORDER_HANDOFF_REQUESTED` | Order is being sent |
| `ORDER_HANDOFF_PENDING` | Store is confirming order |
| `ORDER_HANDOFF_FAILED` | Staff assistance may be needed |
| `ORDER_DUPLICATE_HANDOFF_RISK` | Staff is confirming your order |

Catch Menu must not say order is accepted unless Catch & Order confirms the appropriate safe state.

---

## 17. Payment Status Handoff Mapping Rule

If Catch Menu displays payment status, it must use Catch & Order approved safe states.

Examples:

| Internal State | Customer Safe Direction |
|---|---|
| `PAYMENT_NOT_STARTED` | Payment has not started |
| `PAYMENT_CHECKING` | Payment status is being checked |
| `PAYMENT_CONFIRMED_PROVIDER_VERIFIED` | Payment confirmed |
| `PAYMENT_REVIEW_REQUIRED` | Payment status is being reviewed |
| `PAYMENT_REFUND_REVIEW` | Refund request is being reviewed |
| `PAYMENT_PROVIDER_DELAY` | Payment status is taking longer than usual |

Catch Menu must not display raw payment gateway errors.

---

## 18. KDS Fulfillment Handoff Mapping Rule

If Catch Menu displays fulfillment status, it must use customer-safe fulfillment wording.

Examples:

| Internal State | Customer Safe Direction |
|---|---|
| `KDS_TICKET_CREATED` | Order is being prepared |
| `KDS_PREPARING` | Preparing |
| `KDS_DELAY_DETECTED` | There may be a short delay |
| `KDS_READY` | Ready for pickup |
| `KDS_SERVED` | Completed |
| `KDS_REMAKE_REQUIRED` | Staff is checking your order |
| `KDS_STATUS_UNAVAILABLE` | Store is confirming preparation status |

KDS status must not imply payment or settlement truth.

---

## 19. Provider Delay And Fallback Mapping Rule

Provider delays must be calm and non-accusatory.

Examples:

| Internal State | Customer Safe Direction |
|---|---|
| `PROVIDER_TIMEOUT` | Temporary delay |
| `PROVIDER_RATE_LIMITED` | Temporary delay |
| `PROVIDER_CALLBACK_FAILED` | Status is being checked |
| `PROVIDER_CAPABILITY_UNVERIFIED` | This feature is not currently available |
| `PROVIDER_EXTERNAL_SYNC_STALE` | Information is being refreshed |
| `PROVIDER_CONTRACT_REVIEW_REQUIRED` | Do not show provider-specific feature |

Provider raw state is internal.

---

## 20. Support Handoff Mapping Rule

When Catch Menu cannot show a safe state, it should route to staff/support.

Examples:

| Internal State | Customer Safe Direction |
|---|---|
| `STAFF_REVIEW_REQUIRED` | Staff assistance may be needed |
| `SUPPORT_REVIEW_REQUIRED` | Support review is in progress |
| `CUSTOMER_RECOVERY_REQUIRED` | We will help resolve this |
| `ORDER_STATUS_UNCERTAIN` | Staff is confirming your order |
| `PAYMENT_STATUS_UNCERTAIN` | Payment status is being reviewed |
| `VALUE_DISPLAY_UNVERIFIED` | Benefit information is being checked |

Support handoff must preserve masking and authority boundaries.

---

## 21. Security Internal State Mapping Rule

Catch Menu must never display raw security states.

Examples:

| Internal State | Customer Safe Direction |
|---|---|
| `CONTAINMENT_ACTIVE` | Staff review is required |
| `QUARANTINE_ACTIVE` | Status is being checked |
| `SECURITY_SIGNAL_CREATED` | Do not show raw |
| `AI_OUTPUT_BLOCKED` | Do not show raw |
| `PGVECTOR_RETRIEVAL_BLOCKED` | Do not show raw |
| `LEGAL_HOLD_ACTIVE` | Do not show raw |
| `ARCHIVE_RETRIEVAL_REQUIRED` | Support review is in progress |

Security internal states are not customer messages.

---

## 22. External Projection Mapping Rule

External projection surfaces must be conservative.

Examples:

| Internal State | External Safe Direction |
|---|---|
| `EXTERNAL_MENU_SYNC_READY` | Menu may be projected |
| `EXTERNAL_PRICE_SYNC_STALE` | Price should be hidden or refreshed |
| `EXTERNAL_AVAILABILITY_SYNC_STALE` | Availability should be hidden or marked |
| `EXTERNAL_ALLERGEN_SYNC_UNVERIFIED` | Allergen text must not be projected |
| `EXTERNAL_ORDER_LINK_UNVERIFIED` | Ordering link must not be shown |
| `EXTERNAL_PROVIDER_CAPABILITY_UNVERIFIED` | Provider capability must not be claimed |

External projection is not source of truth.

---

## 23. Customer Action Catalog

| Customer Action | Meaning |
|---|---|
| `CUSTOMER_ACTION_NONE` | No action needed |
| `CUSTOMER_ACTION_WAIT` | Wait |
| `CUSTOMER_ACTION_REFRESH_MENU` | Refresh menu |
| `CUSTOMER_ACTION_RESCAN_QR` | Rescan QR |
| `CUSTOMER_ACTION_RETAP_NFC` | Tap NFC again |
| `CUSTOMER_ACTION_RESELECT_ITEM` | Select another item |
| `CUSTOMER_ACTION_CHECK_WITH_STAFF` | Ask staff |
| `CUSTOMER_ACTION_CONTINUE_ORDER` | Continue order |
| `CUSTOMER_ACTION_RETRY_SAFE` | Safe retry |
| `CUSTOMER_ACTION_CONTACT_SUPPORT` | Contact support |
| `CUSTOMER_ACTION_RECOVERY_REQUEST` | Request recovery/help |

Customer actions must not create duplicate order or payment risk.

---

## 24. Prohibited Catch Menu Displays

Catch Menu must not display:

- raw provider error code
- raw payment gateway code
- raw POS error code
- raw KDS station code
- raw database id
- raw support note
- ledger mismatch
- settlement mismatch
- duplicate payment risk
- containment active
- quarantine active
- daemon degraded
- pgvector blocked
- AI output blocked
- legal hold active
- provider contract review required
- unverified payment capability claim
- unreviewed AI-generated menu/status text

Customer-facing surface must remain safe and simple.

---

## 25. Status Surface Change Control

Changes to Catch Menu status mappings must record:

| Field | Meaning |
|---|---|
| `change_id` | Stable change id |
| `mapping_id` | Mapping changed |
| `surface_type` | Surface affected |
| `old_safe_state` | Previous safe state |
| `new_safe_state` | New safe state |
| `old_message_key` | Previous message key |
| `new_message_key` | New message key |
| `reason` | Reason |
| `customer_impact` | Customer impact |
| `risk_class` | Risk class |
| `review_owner` | Reviewer |
| `review_status` | Review status |
| `rollback_mapping` | Rollback path |

High-risk messages require stricter review.

---

## 26. File Layout Candidate

If future implementation chooses files, candidate paths may be:

| Path Candidate | Purpose |
|---|---|
| `catalogs/catch_menu/status_surfaces.*` | Surface mapping registry |
| `catalogs/catch_menu/customer_safe_states.*` | Safe state families |
| `catalogs/catch_menu/customer_actions.*` | Customer action catalog |
| `i18n/registry/catch_menu_status_keys.*` | Message key registry |
| `i18n/locales/ko/catch_menu_status.*` | Korean visible copy |
| `i18n/locales/en/catch_menu_status.*` | English visible copy |
| `docs/catch_menu/status_surface_review.md` | Review packet |

This is a layout candidate only.

No files are authorized.

---

## 27. Database Layout Candidate

If future implementation chooses database-backed status mapping, candidate table families may be:

| Table Family Candidate | Purpose |
|---|---|
| `catch_menu_status_surfaces` | Surface mapping records |
| `catch_menu_safe_state_families` | Safe state catalog |
| `catch_menu_status_message_keys` | Message key mapping |
| `catch_menu_customer_actions` | Customer action catalog |
| `catch_menu_status_reviews` | Review records |
| `catch_menu_status_change_log` | Change history |

This is a data-model candidate only.

No tables are authorized.

---

## 28. Readiness Blockers

| Blocker ID | Meaning |
|---|---|
| `BLOCKER-CATCH-MENU-STATUS-0001` | Catch Menu status surface policy not reviewed |
| `BLOCKER-CATCH-MENU-STATUS-LAYER-0001` | Status layers missing |
| `BLOCKER-CATCH-MENU-SAFE-STATE-0001` | Safe state families missing |
| `BLOCKER-CATCH-MENU-MAPPING-SCHEMA-0001` | Mapping schema missing |
| `BLOCKER-CATCH-MENU-I18N-KEY-0001` | Message key namespace missing |
| `BLOCKER-CATCH-MENU-QR-MAP-0001` | QR mapping missing |
| `BLOCKER-CATCH-MENU-NFC-MAP-0001` | NFC mapping missing |
| `BLOCKER-CATCH-MENU-MENU-MAP-0001` | Menu projection mapping missing |
| `BLOCKER-CATCH-MENU-ORDER-HANDOFF-0001` | Order handoff mapping missing |
| `BLOCKER-CATCH-MENU-PAYMENT-HANDOFF-0001` | Payment handoff mapping missing if visible |
| `BLOCKER-CATCH-MENU-KDS-HANDOFF-0001` | KDS handoff mapping missing if visible |
| `BLOCKER-CATCH-MENU-PROVIDER-MAP-0001` | Provider fallback mapping missing |
| `BLOCKER-CATCH-MENU-SECURITY-MAP-0001` | Security internal state mapping missing |
| `BLOCKER-CATCH-MENU-PROHIBITED-DISPLAY-0001` | Prohibited display list missing |
| `BLOCKER-CATCH-MENU-CODING-0001` | Coding not authorized |

Open blockers prevent Catch Menu status implementation.

---

## 29. Validation Checklist

Validation must confirm:

- Catch Menu status surface definition exists
- status layer catalog exists
- customer safe state families exist
- mapping record schema exists
- message key namespace exists
- QR entry mapping rule exists
- NFC entry mapping rule exists
- menu loading/projection mapping exists
- item availability mapping exists
- price mapping exists
- allergen safety mapping exists
- cart/order handoff mapping exists
- payment status handoff mapping exists
- KDS fulfillment handoff mapping exists
- provider delay/fallback mapping exists
- support handoff mapping exists
- security internal state mapping exists
- external projection mapping exists
- customer action catalog exists
- prohibited displays exist
- change control exists
- layout candidates are non-authorizing
- coding remains deferred

---

## 30. Relationship To Previous Documents

This document follows:

- `09750 Catch & Order Status Message Catalog And Customer Safe State Mapping Policy`

It references:

- `09670 Catch Menu Customer Surface Projection And i18n Naming Policy`
- `09740 i18n Message Key Registry And Customer Visible Text Review Policy`
- `09750 Catch & Order Status Message Catalog And Customer Safe State Mapping Policy`
- `09560` through `09750`

It prepares later planning for:

- Catch Menu i18n key catalog
- Catch Menu status surface review
- Catch Menu QR/NFC entry planning
- Catch Menu order handoff planning
- Catch Menu external projection planning
- future Catch Menu implementation handoff

This document is Catch Menu status surface planning only.

It does not authorize coding.

---

## 31. Final Rule

Catch Menu must remain simple for customers and controlled for the system.

Every customer-visible Catch Menu state must map from an internal source state to a safe state family, stable i18n key, fallback key, customer action, review owner, and authority boundary.

Catch Menu must not display raw provider, POS, payment, KDS, database, support, security, AI, pgvector, archive, legal, containment, or quarantine states.

Catch Menu may hand off order, payment, fulfillment, staff review, and recovery states only through approved Catch & Order safe mappings.

No Catch Menu status surface implementation may proceed until a separate narrow handoff grants `CODING_ALLOWED`, declares target files or data structures, maps boundary tests, resolves blockers, and defines rollback.
