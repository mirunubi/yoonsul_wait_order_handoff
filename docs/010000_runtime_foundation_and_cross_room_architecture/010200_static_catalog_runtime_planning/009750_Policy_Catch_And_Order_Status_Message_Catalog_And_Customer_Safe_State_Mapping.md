# 009750_Policy_Catch_And_Order_Status_Message_Catalog_And_Customer_Safe_State_Mapping

## 1. Purpose

This document defines the Catch & Order Status Message Catalog and Customer Safe State Mapping Policy.

The previous artifact `09740` defined the i18n Message Key Registry and Customer Visible Text Review Policy.

This document applies the i18n and customer-visible text rules specifically to Catch & Order order/session/payment/KDS/provider/support status flows.

The purpose is to ensure that Catch & Order does not expose raw internal operational states directly to customers, staff, support, or external surfaces without controlled mapping.

Catch & Order status must be:

- source-aware
- authority-aware
- customer-safe
- localized
- recoverable
- auditable where needed
- separated from payment, POS, KDS, provider, AI, pgvector, archive, and support authority

This document is planning-only.

It does not authorize coding.

---

## 2. Scope

This policy applies to Catch & Order status mapping for:

1. Customer session state
2. Menu-to-order handoff state
3. Cart and order draft state
4. Order submission state
5. POS handoff state
6. POS acceptance/rejection state
7. Payment observed state
8. KDS ticket and fulfillment state
9. Provider callback state
10. Store staff review state
11. Support/admin review state
12. Customer recovery state
13. Degraded operation state
14. Duplicate submit/order risk state
15. Value/membership/coupon/wallet display state
16. Identity/session linking state
17. AI/pgvector internal review state
18. Archive/evidence/legal hold status visibility

This document does not create status enums, tables, APIs, UI messages, translation files, runtime workflows, or customer-facing screens.

---

## 3. Core Principle

Catch & Order must separate internal state from customer-safe state.

The correct rule is:

Internal state may be precise.
Customer-visible state must be safe.
Support-visible state may be more detailed.
Admin-visible state may include review signals.
No visible state may create false authority.

A customer must not see raw security, provider, ledger, daemon, vector, containment, quarantine, or legal-hold states.

A customer should see a calm, useful, localized status and a next step where needed.

---

## 4. Catalog Header

| Field | Value |
|---|---|
| Document ID | `09750` |
| Package ID | `catch_order.status_message_catalog.customer_safe_mapping.v1` |
| Artifact Type | `STATUS_MESSAGE_MAPPING_POLICY` |
| Version | `v1` |
| Planning Status | `FOUNDATION_CANDIDATE` |
| Coding Status | `CODING_DEFERRED` |
| Runtime Authority | `STATUS_MAPPING_PLANNING_ONLY` |
| Owner | `Product / Catch & Order / i18n / Security / Support` |
| Dependencies | `09560` to `09740` |
| Provider Evidence Status | `CARRY_FORWARD_IF_PROVIDER_STATUS_VISIBLE` |
| i18n Requirement | `REQUIRED_FOR_ALL_VISIBLE_STATUS_MESSAGES` |
| Audit Requirement | `REQUIRED_FOR_HIGH_RISK_STATUS_AND_RECOVERY` |
| Security Requirement | `CUSTOMER_SAFE_STATUS_MAPPING_REQUIRED` |
| Review Requirement | `PRODUCT_I18N_SECURITY_SUPPORT_REVIEW_REQUIRED` |
| Blocker Status | `CATCH_ORDER_STATUS_MAPPING_REVIEW_REQUIRED` |

---

## 5. Status Mapping Definition

A Catch & Order status mapping converts an internal system state into an audience-safe message state.

The mapping must define:

- internal source state
- source system
- authority boundary
- audience
- customer-safe status family
- i18n key
- fallback key
- customer action if any
- support route if any
- audit requirement
- provider evidence dependency if any
- review owner
- blocker if incomplete

A status mapping does not mutate runtime state.

It only controls what can be shown or routed.

---

## 6. Audience-Specific Status Layers

Catch & Order should define separate status layers.

| Layer | Meaning |
|---|---|
| `INTERNAL_STATE` | Raw operational state used by systems |
| `STORE_STAFF_STATE` | Store staff-safe operational state |
| `SUPPORT_STATE` | Support/admin review state |
| `CUSTOMER_SAFE_STATE` | Customer-visible state |
| `EXTERNAL_PROJECTION_STATE` | Partner/external projection state |
| `AUDIT_EVIDENCE_STATE` | Evidence/audit state |
| `LEGAL_REVIEW_STATE` | Legal/compliance review-only state |

A single internal state may map to different visible states per audience.

---

## 7. Customer Safe State Family Catalog

| Customer Safe State Family | Meaning |
|---|---|
| `CUSTOMER_STATUS_LOADING` | Status is loading |
| `CUSTOMER_STATUS_MENU_READY` | Menu is ready |
| `CUSTOMER_STATUS_ORDER_DRAFT` | Order is being prepared by customer |
| `CUSTOMER_STATUS_ORDER_RECEIVED` | Order request received |
| `CUSTOMER_STATUS_ORDER_CONFIRMING` | Store/system is confirming order |
| `CUSTOMER_STATUS_ORDER_ACCEPTED` | Store accepted order |
| `CUSTOMER_STATUS_PREPARING` | Order is being prepared |
| `CUSTOMER_STATUS_READY_SOON` | Order is near ready |
| `CUSTOMER_STATUS_READY_FOR_PICKUP` | Pickup ready |
| `CUSTOMER_STATUS_SERVED_OR_COMPLETED` | Fulfillment completed |
| `CUSTOMER_STATUS_PAYMENT_CHECKING` | Payment status is being checked |
| `CUSTOMER_STATUS_PAYMENT_CONFIRMED` | Payment confirmed by approved source |
| `CUSTOMER_STATUS_PAYMENT_REVIEW` | Payment needs review |
| `CUSTOMER_STATUS_TEMPORARY_DELAY` | Temporary delay |
| `CUSTOMER_STATUS_STAFF_REVIEW` | Staff review is in progress |
| `CUSTOMER_STATUS_SUPPORT_REVIEW` | Support review is in progress |
| `CUSTOMER_STATUS_ACTION_NEEDED` | Customer or staff action may be needed |
| `CUSTOMER_STATUS_SAFE_FALLBACK` | Safe fallback message |
| `CUSTOMER_STATUS_UNAVAILABLE` | Service/menu/action unavailable |
| `CUSTOMER_STATUS_RECOVERY_AVAILABLE` | Recovery/support path available |

Customer safe state family is not the same as internal runtime state.

---

## 8. Internal State Families

Catch & Order internal state families may include:

| Internal State Family | Meaning |
|---|---|
| `SESSION_STATE` | Customer/session/table continuity |
| `MENU_PROJECTION_STATE` | Menu availability/projection |
| `CART_STATE` | Cart and draft order |
| `ORDER_STATE` | Order submission and acceptance |
| `POS_HANDOFF_STATE` | POS bridge/handoff |
| `PAYMENT_OBSERVED_STATE` | Payment observation |
| `KDS_TICKET_STATE` | Kitchen ticket/fulfillment |
| `PROVIDER_SYNC_STATE` | Provider callback/sync |
| `VALUE_DISPLAY_STATE` | Coupon/wallet/point display |
| `IDENTITY_LINK_STATE` | Session/identity continuity |
| `SUPPORT_REVIEW_STATE` | Staff/support review |
| `RECOVERY_STATE` | Customer recovery |
| `SECURITY_MONITORING_STATE` | Security signal/containment/quarantine |
| `AI_REVIEW_STATE` | AI-derived internal review |
| `VECTOR_REVIEW_STATE` | pgvector-derived review context |
| `ARCHIVE_EVIDENCE_STATE` | Archive/legal/evidence state |

Only mapped safe states may be shown.

---

## 9. Status Mapping Record Schema

Each mapping record should include:

| Field | Required Meaning |
|---|---|
| `mapping_id` | Stable mapping id |
| `internal_state_family` | Internal state family |
| `internal_state` | Internal state |
| `source_system` | Catch & Order, POS, KDS, provider, support, etc. |
| `source_authority` | Authority boundary |
| `audience` | Customer, staff, support, admin, etc. |
| `safe_state_family` | Safe state family |
| `message_key` | i18n key |
| `fallback_key` | Fallback i18n key |
| `customer_action` | None, wait, ask staff, retry, contact support |
| `support_route` | Support route if needed |
| `provider_evidence_status` | Provider evidence if relevant |
| `security_review_status` | Security review status |
| `content_review_status` | Content review status |
| `legal_review_status` | Legal review if needed |
| `audit_required` | Audit requirement |
| `recovery_required` | Recovery path required |
| `prohibited_display` | What must not be shown |
| `status` | Mapping status |
| `blocker_id` | Blocker if incomplete |

A mapping record without i18n key is incomplete for visible audiences.

---

## 10. Mapping Status Catalog

| Status | Meaning |
|---|---|
| `STATUS_MAPPING_DRAFT` | Draft mapping |
| `STATUS_MAPPING_REVIEW_REQUIRED` | Review required |
| `STATUS_MAPPING_CONTENT_REVIEW_REQUIRED` | Content review required |
| `STATUS_MAPPING_I18N_REVIEW_REQUIRED` | i18n review required |
| `STATUS_MAPPING_SECURITY_REVIEW_REQUIRED` | Security review required |
| `STATUS_MAPPING_LEGAL_REVIEW_REQUIRED` | Legal review required |
| `STATUS_MAPPING_PROVIDER_EVIDENCE_REQUIRED` | Provider evidence required |
| `STATUS_MAPPING_APPROVED_FOR_PLANNING` | Approved for planning only |
| `STATUS_MAPPING_APPROVED_FOR_STAGING` | Approved for staging later |
| `STATUS_MAPPING_APPROVED_FOR_PRODUCTION` | Approved for production later |
| `STATUS_MAPPING_BLOCKED` | Blocked |
| `STATUS_MAPPING_DEPRECATED` | Deprecated |

Default status:

`STATUS_MAPPING_REVIEW_REQUIRED`

---

## 11. Session Status Mapping Rule

Session-related internal states must avoid identity overclaim.

Examples:

| Internal State | Customer Safe Direction |
|---|---|
| `SESSION_CREATED` | Menu/order session started |
| `SESSION_TABLE_LINKED` | Table context available |
| `SESSION_TABLE_UNCERTAIN` | Staff may confirm table |
| `SESSION_EXPIRED` | Session expired; restart may be needed |
| `SESSION_SCOPE_MISMATCH` | This link cannot be used |
| `SESSION_IDENTITY_LINK_PENDING` | Sign-in or confirmation may be needed |
| `SESSION_IDENTITY_LINK_BLOCKED` | Staff/support review required |

Customer session is not legal identity.

---

## 12. Menu And Cart Status Mapping Rule

Menu/cart states must distinguish browsing from ordering.

Examples:

| Internal State | Customer Safe Direction |
|---|---|
| `MENU_PROJECTION_APPROVED` | Menu is available |
| `MENU_PROJECTION_STALE` | Menu information is being refreshed |
| `MENU_ITEM_UNAVAILABLE` | Item is currently unavailable |
| `MENU_PRICE_REVIEW_REQUIRED` | Item information is being checked |
| `MENU_ALLERGEN_REVIEW_REQUIRED` | Staff review required before display |
| `CART_CREATED` | Cart started |
| `CART_INVALID_ITEM_REMOVED` | Some item needs to be checked |
| `CART_PRICE_CHANGED` | Price/selection needs confirmation |

Menu view is not order.

Cart is not accepted order.

---

## 13. Order Submission Status Mapping Rule

Order states must distinguish receipt, confirmation, POS acceptance, and rejection.

Examples:

| Internal State | Customer Safe Direction |
|---|---|
| `ORDER_SUBMITTED` | Order request received |
| `ORDER_RECEIVED_BY_CATCH_ORDER` | Order is being confirmed |
| `ORDER_DUPLICATE_SUBMIT_RISK` | Staff is confirming your order |
| `ORDER_VALIDATION_FAILED` | Some order details need checking |
| `ORDER_SENT_TO_POS` | Store is confirming order |
| `ORDER_ACCEPTED_BY_POS` | Store accepted order |
| `ORDER_REJECTED_BY_POS` | Staff review is required |
| `ORDER_CANCEL_REQUESTED` | Cancel request is being checked |
| `ORDER_CANCEL_CONFIRMED` | Cancel has been confirmed if authority source confirms it |

Order submitted is not payment confirmed.

---

## 14. POS Handoff Status Mapping Rule

POS states must not expose raw POS failure.

Examples:

| Internal State | Customer Safe Direction |
|---|---|
| `POS_HANDOFF_REQUESTED` | Store is confirming order |
| `POS_HANDOFF_PENDING` | Order is being checked |
| `POS_HANDOFF_FAILED` | Staff review is required |
| `POS_ACCEPT_STATE_UNCERTAIN` | Order status is being confirmed |
| `POS_DUPLICATE_RISK` | Staff is confirming your order |
| `POS_OFFLINE_LOCAL_CACHE` | Store is handling order locally |
| `POS_STORE_MAPPING_FAILED` | Staff review is required |

POS accepted order is not payment confirmation.

---

## 15. Payment Status Mapping Rule

Payment states must be stricter.

Examples:

| Internal State | Customer Safe Direction |
|---|---|
| `PAYMENT_NOT_STARTED` | Payment has not started |
| `PAYMENT_AUTH_PENDING` | Payment is being checked |
| `PAYMENT_AUTH_CONFIRMED` | Payment confirmed if provider-verified |
| `PAYMENT_CAPTURE_PENDING` | Payment is being processed |
| `PAYMENT_CAPTURE_CONFIRMED` | Payment confirmed |
| `PAYMENT_STATE_UNCERTAIN` | Payment status is being reviewed |
| `PAYMENT_DUPLICATE_RISK` | Payment is being reviewed |
| `PAYMENT_REFUND_REQUESTED` | Refund request is being reviewed |
| `PAYMENT_REFUND_CONFIRMED` | Refund confirmed if provider-verified |
| `PAYMENT_PROVIDER_CALLBACK_FAILED` | Payment status is being checked |

Payment messages must not promise capture/refund unless verified.

---

## 16. KDS Fulfillment Status Mapping Rule

KDS states must avoid kitchen-internal exposure.

Examples:

| Internal State | Customer Safe Direction |
|---|---|
| `KDS_TICKET_CREATED` | Order is being prepared |
| `KDS_TICKET_ACCEPTED` | Order is being prepared |
| `KDS_ITEM_PREPARING` | Preparing |
| `KDS_DELAY_DETECTED` | There may be a short delay |
| `KDS_READY` | Order is ready |
| `KDS_SERVED` | Order completed |
| `KDS_REMAKE_REQUIRED` | Staff is checking your order |
| `KDS_DUPLICATE_TICKET_RISK` | Staff is confirming your order |
| `KDS_OFFLINE` | Store is handling preparation locally |

KDS completion is not payment or settlement truth.

---

## 17. Provider Status Mapping Rule

Provider states must remain customer-safe.

Examples:

| Internal State | Customer Safe Direction |
|---|---|
| `PROVIDER_CALLBACK_RECEIVED` | Status is being updated |
| `PROVIDER_CALLBACK_SIGNATURE_FAILED` | Status is being checked |
| `PROVIDER_REPLAY_DETECTED` | Status is being reviewed |
| `PROVIDER_TIMEOUT` | Temporary delay |
| `PROVIDER_RATE_LIMITED` | Temporary delay |
| `PROVIDER_CAPABILITY_UNVERIFIED` | This feature is not currently available |
| `PROVIDER_SANDBOX_ONLY` | Do not show as available in production |
| `PROVIDER_CONTRACT_REVIEW_REQUIRED` | Do not show to customer |

Raw provider state is internal.

---

## 18. Value Display Status Mapping Rule

Membership, coupon, wallet, point, and benefit states must not overpromise.

Examples:

| Internal State | Customer Safe Direction |
|---|---|
| `COUPON_AVAILABLE_VERIFIED` | Coupon available |
| `COUPON_APPLY_PENDING` | Coupon is being checked |
| `COUPON_APPLIED_CONFIRMED` | Coupon applied |
| `COUPON_DUPLICATE_USE_RISK` | Coupon is being reviewed |
| `WALLET_BALANCE_UNCERTAIN` | Balance is being checked |
| `POINT_EARN_PENDING` | Points are being checked |
| `BENEFIT_ELIGIBILITY_UNVERIFIED` | Benefit is being checked |
| `VALUE_LEDGER_MISMATCH` | Benefit/payment status is being reviewed |

Value display is not value mutation.

---

## 19. Support And Recovery Status Mapping Rule

Support/recovery states must be clear and non-accusatory.

Examples:

| Internal State | Customer Safe Direction |
|---|---|
| `SUPPORT_REVIEW_CREATED` | Staff/support review is in progress |
| `SUPPORT_ACTION_REQUIRED` | Staff assistance may be needed |
| `CUSTOMER_RECOVERY_REQUIRED` | We will help resolve this |
| `RECOVERY_COMPENSATION_REVIEW` | Support is reviewing the issue |
| `RECOVERY_APPROVED` | Recovery support has been approved if authority confirms |
| `CASE_CLOSED_INTERNAL` | Do not show unless customer-safe closure exists |
| `SUPPORT_AUTHORITY_MISSING` | Staff review is required |

Support note is not customer truth.

---

## 20. Security Monitoring Status Mapping Rule

Security monitoring states must not be shown raw.

Examples:

| Internal State | Customer Safe Direction |
|---|---|
| `CONTAINMENT_ACTIVE` | Staff review is required |
| `QUARANTINE_ACTIVE` | Status is being checked |
| `SECURITY_SIGNAL_CREATED` | Do not show raw |
| `DAEMON_RULE_MATCHED` | Do not show raw |
| `AI_OUTPUT_BLOCKED` | Do not show raw |
| `PGVECTOR_RETRIEVAL_BLOCKED` | Do not show raw |
| `LEGAL_HOLD_ACTIVE` | Do not show raw |
| `ARCHIVE_RETRIEVAL_REQUIRED` | Support review is in progress |

Security state is internal.

---

## 21. Degraded Operation Status Mapping Rule

Degraded operation must be calm and useful.

Examples:

| Internal State | Customer Safe Direction |
|---|---|
| `MENU_SOURCE_UNAVAILABLE` | Menu is temporarily unavailable |
| `POS_BRIDGE_DEGRADED` | Store is confirming order |
| `PAYMENT_PROVIDER_DEGRADED` | Payment status is being checked |
| `KDS_BRIDGE_DEGRADED` | Store is handling preparation |
| `I18N_KEY_MISSING` | Safe fallback message |
| `SUPPORT_QUEUE_DELAYED` | Support review may take a little longer |
| `ARCHIVE_READ_DELAYED` | Support is checking records |

Degraded does not mean uncontrolled.

---

## 22. Status Message Key Namespace

Recommended Catch & Order status key namespace:

`catch_order.<domain>.<safe_state>.<message_type>`

Examples:

| Key | Meaning |
|---|---|
| `catch_order.session.loading.status` | Session loading |
| `catch_order.menu.refreshing.notice` | Menu refreshing |
| `catch_order.order.received.status` | Order received |
| `catch_order.order.confirming.status` | Order confirming |
| `catch_order.order.accepted.status` | Order accepted |
| `catch_order.pos.confirming.status` | POS confirmation safe status |
| `catch_order.payment.checking.status` | Payment checking |
| `catch_order.payment.review.notice` | Payment review |
| `catch_order.kds.preparing.status` | Preparing |
| `catch_order.kds.delay.notice` | Delay notice |
| `catch_order.provider.delay.notice` | Provider delay |
| `catch_order.support.review.notice` | Support review |
| `catch_order.recovery.available.notice` | Recovery notice |
| `catch_order.fallback.temporary.status` | Temporary fallback |

All visible keys must be registered under the i18n registry.

---

## 23. Customer Action Catalog

| Customer Action | Meaning |
|---|---|
| `CUSTOMER_ACTION_NONE` | No action needed |
| `CUSTOMER_ACTION_WAIT` | Wait |
| `CUSTOMER_ACTION_REFRESH` | Refresh possible |
| `CUSTOMER_ACTION_CONFIRM_WITH_STAFF` | Ask staff |
| `CUSTOMER_ACTION_RETRY_SAFE` | Safe retry allowed |
| `CUSTOMER_ACTION_CONTACT_SUPPORT` | Contact support |
| `CUSTOMER_ACTION_SIGN_IN` | Sign in required |
| `CUSTOMER_ACTION_RESELECT_ITEM` | Select another item |
| `CUSTOMER_ACTION_PAYMENT_RETRY` | Payment retry if safe |
| `CUSTOMER_ACTION_RECOVERY_REQUEST` | Recovery/support request |

Customer actions must not create unsafe duplicate operations.

---

## 24. Prohibited Status Displays

Catch & Order must not display the following raw states to customers:

- provider callback signature failed
- provider replay detected
- ledger mismatch
- settlement mismatch
- POS duplicate payload
- KDS duplicate ticket
- containment active
- quarantine active
- AI output blocked
- pgvector source blocked
- daemon degraded
- legal hold active
- support authority missing
- raw database error
- raw provider error
- raw payment gateway code
- raw staff note
- internal audit state

These may be visible to support/admin only with proper masking and authority.

---

## 25. Status Change Control

Status mapping changes must record:

| Field | Meaning |
|---|---|
| `change_id` | Stable change id |
| `mapping_id` | Mapping changed |
| `old_safe_state` | Previous safe state |
| `new_safe_state` | New safe state |
| `old_message_key` | Previous key |
| `new_message_key` | New key |
| `reason` | Reason |
| `risk_class` | Risk class |
| `review_owner` | Reviewer |
| `review_status` | Review status |
| `customer_impact` | Impact summary |
| `rollback_mapping` | Rollback mapping |

Payment, legal, allergen, provider, and recovery mappings require stricter review.

---

## 26. File Layout Candidate

If future implementation chooses files, candidate paths may be:

| Path Candidate | Purpose |
|---|---|
| `catalogs/catch_order/status_mappings.*` | Status mapping registry |
| `catalogs/catch_order/customer_safe_states.*` | Customer safe state families |
| `catalogs/catch_order/internal_states.*` | Internal state families |
| `i18n/registry/catch_order_status_keys.*` | i18n key registry |
| `i18n/locales/ko/catch_order_status.*` | Korean visible copy |
| `i18n/locales/en/catch_order_status.*` | English visible copy |
| `docs/catch_order/status_mapping_review.md` | Review packet |

This is a layout candidate only.

No files are authorized.

---

## 27. Database Layout Candidate

If future implementation chooses database-backed status mapping, candidate table families may be:

| Table Family Candidate | Purpose |
|---|---|
| `catch_order_status_mappings` | Internal-to-safe mapping |
| `catch_order_safe_state_families` | Safe state catalog |
| `catch_order_status_message_keys` | Message key mapping |
| `catch_order_status_reviews` | Review records |
| `catch_order_status_change_log` | Change history |

This is a data-model candidate only.

No tables are authorized.

---

## 28. Readiness Blockers

| Blocker ID | Meaning |
|---|---|
| `BLOCKER-CATCH-ORDER-STATUS-0001` | Status mapping policy not reviewed |
| `BLOCKER-CATCH-ORDER-STATUS-LAYER-0001` | Audience layers missing |
| `BLOCKER-CATCH-ORDER-SAFE-STATE-0001` | Safe state families missing |
| `BLOCKER-CATCH-ORDER-MAPPING-SCHEMA-0001` | Mapping schema missing |
| `BLOCKER-CATCH-ORDER-I18N-KEY-0001` | Message key namespace missing |
| `BLOCKER-CATCH-ORDER-PAYMENT-MAP-0001` | Payment mapping missing |
| `BLOCKER-CATCH-ORDER-KDS-MAP-0001` | KDS mapping missing |
| `BLOCKER-CATCH-ORDER-PROVIDER-MAP-0001` | Provider mapping missing |
| `BLOCKER-CATCH-ORDER-SECURITY-MAP-0001` | Security state mapping missing |
| `BLOCKER-CATCH-ORDER-PROHIBITED-DISPLAY-0001` | Prohibited status display missing |
| `BLOCKER-CATCH-ORDER-STATUS-CHANGE-0001` | Change control missing |
| `BLOCKER-CATCH-ORDER-STATUS-CODING-0001` | Coding not authorized |

Open blockers prevent status mapping implementation.

---

## 29. Validation Checklist

Validation must confirm:

- status mapping definition exists
- audience-specific status layers exist
- customer safe state family catalog exists
- internal state families exist
- mapping record schema exists
- mapping status catalog exists
- session mapping rule exists
- menu/cart mapping rule exists
- order submission mapping rule exists
- POS mapping rule exists
- payment mapping rule exists
- KDS mapping rule exists
- provider mapping rule exists
- value display mapping rule exists
- support/recovery mapping rule exists
- security monitoring mapping rule exists
- degraded operation mapping rule exists
- message key namespace exists
- customer action catalog exists
- prohibited status displays exist
- change control exists
- layout candidates are non-authorizing
- coding remains deferred

---

## 30. Relationship To Previous Documents

This document follows:

- `09740 i18n Message Key Registry And Customer Visible Text Review Policy`

It references:

- `09660 Catch & Order SaaS Runtime Boundary And Module Naming Policy`
- `09670 Catch Menu Customer Surface Projection And i18n Naming Policy`
- `09730 Provider Evidence Review Packet And Capability Acceptance Matrix Policy`
- `09740 i18n Message Key Registry And Customer Visible Text Review Policy`
- `09560` through `09740`

It prepares later planning for:

- Catch & Order status key catalog
- Catch & Order customer-safe message review
- Catch Menu order-status handoff mapping
- support/admin review message mapping
- provider delay customer message mapping
- future Catch & Order implementation handoff

This document is status message mapping planning only.

It does not authorize coding.

---

## 31. Final Rule

Catch & Order must never expose raw internal operational, provider, POS, payment, KDS, ledger, security, AI, pgvector, archive, legal, support, or daemon states directly to customers.

Every internal state that may become visible must be mapped to an audience-safe state, stable i18n key, fallback key, review owner, customer action, support route, and authority boundary.

Customer-safe status must inform without overpromising.

Payment, provider, value, identity, legal, recovery, and safety-related messages require stricter review.

No Catch & Order status mapping implementation may proceed until a separate narrow handoff grants `CODING_ALLOWED`, declares target files or data structures, maps boundary tests, resolves blockers, and defines rollback.
