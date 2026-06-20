# 010202_Policy_Catch_Menu_Customer_Surface_Projection_And_I18n_Naming.md

## Purpose

This document defines the customer-facing surface, projection, naming, and i18n policy for:

`Catch Menu / 캐치메뉴`

The previous artifact `09660` defined `Catch & Order / 캐치앤오더` as the SaaS-facing integrated menu, order, POS/KDS handoff, provider, support, monitoring, and franchise-ready runtime boundary.

This document defines `Catch Menu / 캐치메뉴` as the simpler customer-facing menu access surface.

Catch Menu must be easy for customers to understand.

Catch Menu must also remain controlled internally because customer-visible menu, price, allergen, availability, order status, payment status, fallback messages, and AI-generated content can create legal, operational, and trust risk.

This document is planning-only.

It does not authorize coding.

---

## 2. Scope

This policy applies to Catch Menu planning for:

1. Customer-facing menu access
2. QR/NFC entry
3. Table/session entry
4. Menu browsing
5. Menu availability display
6. Sold-out display
7. Price display
8. Allergen and nutrition warning display
9. Language and locale display
10. Customer-safe order entry handoff
11. Customer-safe order status
12. Customer-safe KDS/fulfillment status
13. Customer-safe payment status
14. Coupon/membership/wallet display boundary
15. Customer recovery notice
16. External projection surfaces
17. AI-generated visible text boundary
18. i18n key namespace
19. Fallback text
20. Catch & Order handoff boundary

This document does not create UI, screens, code, API, schema, translation files, menu catalogs, QR/NFC implementation, or production customer surface.

---

## 3. Core Principle

Catch Menu is simple outside and controlled inside.

The customer should feel:

- easy menu access
- quick understanding
- safe order path
- clear status
- localized language
- no confusing technical terms

The system must preserve:

- source-approved menu projection
- i18n message key control
- price and allergen accuracy
- availability accuracy
- safe fallback messages
- customer status safety
- no unverified provider capability display
- no AI-generated visible text without approval
- no payment/KDS/POS authority confusion

Catch Menu is customer-facing.

Customer-facing does not mean low-risk.

---

## 4. Catalog Header

| Field | Value |
|---|---|
| Document ID | `09670` |
| Package ID | `catch_menu.customer_surface_projection_i18n.v1` |
| Artifact Type | `CUSTOMER_SURFACE_PROJECTION_I18N_POLICY` |
| Version | `v1` |
| Planning Status | `FOUNDATION_CANDIDATE` |
| Coding Status | `CODING_DEFERRED` |
| Runtime Authority | `SURFACE_POLICY_ONLY` |
| Owner | `Architecture / Product / i18n / Customer Experience` |
| Dependencies | `09560` to `09660` |
| Provider Evidence Status | `CARRY_FORWARD_IF_PROVIDER_VISIBLE` |
| i18n Requirement | `REQUIRED_FOR_ALL_VISIBLE_SURFACES` |
| Audit Requirement | `REQUIRED_FOR_HIGH_RISK_VISIBLE_STATUS_OR_CUSTOMER_RECOVERY` |
| Security Requirement | `CUSTOMER_VISIBLE_PROJECTION_CONTROL_REQUIRED` |
| Review Requirement | `PRODUCT_I18N_SECURITY_CONTENT_REVIEW_REQUIRED` |
| Blocker Status | `CATCH_MENU_SURFACE_REVIEW_REQUIRED` |

---

## 5. Naming Policy

| Name | Korean | Use |
|---|---|---|
| `Catch Menu` | `캐치메뉴` | Customer-facing menu access surface |
| `Catch & Order` | `캐치앤오더` | SaaS runtime and integrated order handoff module |
| `Catch Menu Surface` | `캐치메뉴 서피스` | Internal UI/projection planning term |
| `Catch Menu Entry` | `캐치메뉴 진입` | QR/NFC/menu entry flow |
| `Catch Menu Projection` | `캐치메뉴 프로젝션` | Approved customer-visible menu display |
| `Catch Menu i18n` | `캐치메뉴 다국어` | Customer-visible language/message namespace |

Do not use `Catch & Menu` as the primary surface name.

Catch Menu is the simplest customer wording.

---

## 6. Catch Menu Surface Definition

Catch Menu is the customer-facing surface that allows a customer to access and understand the menu.

It may later support:

- QR scan
- NFC tap
- table marker access
- store menu browsing
- multilingual menu display
- menu search/filter
- allergen warning
- sold-out notice
- price display
- recommended menu display
- cart handoff to Catch & Order
- customer-safe order status
- customer-safe pickup/dine-in status
- customer recovery notice

Catch Menu is not itself:

- payment authority
- POS authority
- KDS authority
- provider authority
- inventory authority
- membership value authority
- customer identity authority
- AI text authority

Catch Menu projects approved information.

It does not create source truth.

---

## 7. Surface Type Catalog

| Surface Type | Meaning |
|---|---|
| `SURFACE_QR_MENU` | QR-based menu entry |
| `SURFACE_NFC_MENU` | NFC-based menu entry |
| `SURFACE_TABLE_MENU` | Table-associated menu surface |
| `SURFACE_STORE_MENU` | Store-level menu surface |
| `SURFACE_WAITING_MENU` | Waiting-stage menu surface |
| `SURFACE_ORDER_HANDOFF` | Customer handoff to order flow |
| `SURFACE_STATUS_VIEW` | Customer-safe order/status view |
| `SURFACE_RECOVERY_NOTICE` | Customer recovery notice |
| `SURFACE_EXTERNAL_MENU_PROJECTION` | External map/search/partner menu projection |
| `SURFACE_PROMOTION_PROJECTION` | Promotion/coupon display |
| `SURFACE_LANGUAGE_SELECTION` | Language/locale selection |
| `SURFACE_FALLBACK_NOTICE` | Degraded/fallback notice |

Every surface type requires source and i18n mapping.

---

## 8. Customer Entry Boundary

Catch Menu entry may come from:

- QR code
- NFC tag
- table object
- web link
- store page
- external search/map page
- waiting page
- customer app
- staff-shared link

Entry boundary rules:

- entry token must be scoped
- store context must be clear
- tenant/store mismatch must be blocked or reviewed
- table/session context must not expose other customers
- expired or stale entry must show safe message
- external entry must not bypass menu source approval
- QR/NFC surface must not expose secrets
- customer link must not grant admin access

Entry is access.

Entry is not identity proof.

---

## 9. Menu Projection Source Rule

Catch Menu may display only approved menu projection sources.

A visible menu item should trace to:

- tenant
- store
- menu item source
- menu version
- price source
- availability source
- allergen source
- locale source
- content approval status
- projection timestamp
- fallback status if stale

Menu projection must not be assembled from unapproved free text.

AI-generated menu text must be reviewed before visible use.

---

## 10. Menu Projection Status Catalog

| Status | Meaning |
|---|---|
| `MENU_PROJECTION_NOT_READY` | Projection not ready |
| `MENU_PROJECTION_APPROVED` | Approved for customer display |
| `MENU_PROJECTION_STALE` | Projection may be stale |
| `MENU_PROJECTION_BLOCKED` | Projection blocked |
| `MENU_PROJECTION_SOURCE_MISSING` | Source missing |
| `MENU_PROJECTION_PRICE_REVIEW_REQUIRED` | Price review required |
| `MENU_PROJECTION_ALLERGEN_REVIEW_REQUIRED` | Allergen review required |
| `MENU_PROJECTION_AVAILABILITY_REVIEW_REQUIRED` | Availability review required |
| `MENU_PROJECTION_LOCALE_REVIEW_REQUIRED` | Locale review required |
| `MENU_PROJECTION_AI_TEXT_REVIEW_REQUIRED` | AI text review required |
| `MENU_PROJECTION_PROVIDER_EVIDENCE_REQUIRED` | Provider-visible capability unverified |
| `MENU_PROJECTION_FALLBACK_ACTIVE` | Safe fallback is active |

Blocked/stale/review-required projection must not silently show as normal.

---

## 11. Price Display Boundary

Price display is sensitive.

Price display rules:

- price must come from approved source
- displayed price must match orderable price
- discount/coupon display must be source-approved
- tax/service charge text must be clear if applicable
- external projection price must be synced or marked safe
- stale price must not be shown as final
- AI must not invent price text
- customer-visible price mismatch requires alert/review

Price mismatch may create customer recovery obligation.

---

## 12. Allergen And Safety Display Boundary

Allergen and safety text must be controlled.

Allergen display rules:

- allergen source must be approved
- translated allergen text must be reviewed
- missing allergen source may block projection
- AI-generated allergen text is prohibited without review
- external projection must preserve allergen warnings
- customer-visible allergen mismatch is high-risk
- fallback must be safe and conservative

Allergen text is not decorative content.

It is safety-critical visible information.

---

## 13. Availability And Sold-Out Boundary

Menu availability must be projected safely.

Availability display rules:

- sold-out state must come from approved inventory/menu availability source
- stale availability must show safe fallback or require refresh
- unavailable item must not be orderable unless manual override is approved
- time-limited menu must show correct window
- store-specific availability must not leak across stores
- external projection must not show unavailable items as available
- KDS availability warning must not directly mutate menu truth without authority

Availability is store-scoped by default.

---

## 14. Customer Order Handoff Boundary

Catch Menu may hand a customer to Catch & Order.

Handoff rules:

- menu view is not order
- cart is not POS accepted order
- submitted order is not payment confirmation
- POS accepted order is not KDS completion
- KDS ticket is not settlement
- customer status must use safe wording
- failed handoff must not duplicate order
- duplicate submit risk must be controlled
- order handoff must preserve session/correlation id

Catch Menu should make the customer flow simple while the runtime preserves state separation.

---

## 15. Customer Status Message Boundary

Customer-visible statuses must be safe.

Examples of safe status families:

| Status Family | Customer-Safe Meaning |
|---|---|
| `STATUS_MENU_LOADING` | Menu is loading |
| `STATUS_ITEM_UNAVAILABLE` | Item is currently unavailable |
| `STATUS_ORDER_RECEIVED` | Order request received |
| `STATUS_ORDER_CONFIRMING` | Store is confirming order |
| `STATUS_ORDER_ACCEPTED` | Store accepted order |
| `STATUS_PREPARING` | Order is being prepared |
| `STATUS_READY_SOON` | Order is near ready |
| `STATUS_PICKUP_READY` | Pickup ready |
| `STATUS_PAYMENT_CHECKING` | Payment status is being checked |
| `STATUS_ACTION_NEEDED` | Assistance may be needed |
| `STATUS_SUPPORT_REVIEW` | Staff/support review is in progress |
| `STATUS_TEMPORARY_DELAY` | Temporary delay |
| `STATUS_SAFE_FALLBACK` | Safe fallback message |

Avoid customer-facing raw internal states such as:

- containment active
- quarantine active
- provider callback failed
- ledger mismatch
- pgvector blocked
- daemon degraded
- trigger signal missing

Those are internal.

---

## 16. Customer Visible Error Policy

Customer visible errors must be:

- short
- safe
- localized
- non-technical
- non-accusatory
- not legally conclusive
- not revealing provider/security internals
- not exposing other customer/store data
- linked to support/recovery path if needed

Example safe wording direction:

- “지금은 주문 상태를 확인 중입니다.”
- “일시적으로 메뉴 정보를 불러오지 못했습니다.”
- “현재 이 메뉴는 주문이 어렵습니다.”
- “직원이 확인 후 도와드리겠습니다.”

Final copy must be handled through i18n/content review.

---

## 17. i18n Key Namespace

Recommended key namespace:

`catch_menu.<surface>.<domain>.<message_type>`

Examples:

| Key Pattern | Use |
|---|---|
| `catch_menu.qr.entry.loading` | QR entry loading |
| `catch_menu.nfc.entry.invalid` | NFC entry invalid |
| `catch_menu.menu.item.unavailable` | Item unavailable |
| `catch_menu.menu.price.review_required` | Price review fallback |
| `catch_menu.menu.allergen.notice` | Allergen notice |
| `catch_menu.order.handoff.confirming` | Order handoff confirming |
| `catch_menu.order.status.preparing` | Preparing status |
| `catch_menu.payment.status.checking` | Payment status checking |
| `catch_menu.support.review.in_progress` | Support review |
| `catch_menu.fallback.temporary_delay` | Temporary delay fallback |
| `catch_menu.recovery.staff_assistance` | Staff assistance recovery |

Hardcoded visible strings are prohibited for controlled surfaces.

---

## 18. Locale Policy

Catch Menu must support locale-aware display.

Locale policy must define:

- default locale
- fallback locale
- customer-selected locale
- store-supported locale list
- unsupported locale fallback
- translation source
- content approval status
- date/time/price formatting
- allergen warning translation
- legal/privacy text translation
- right-to-left text readiness if later required

Initial i18n planning may begin with Korean and English, but architecture must not assume Korean-only.

---

## 19. AI-Generated Visible Text Boundary

AI may assist with internal drafting only.

AI-generated customer-visible text must not be published unless:

- source is approved
- content route approves it
- i18n route approves translation
- allergen/price/safety risk is reviewed
- customer recovery/legal wording is reviewed if applicable
- audit exists for high-risk text
- fallback text is approved

AI must not generate final visible menu, price, allergen, payment, legal, or recovery text without review.

---

## 20. External Projection Boundary

Catch Menu content may be projected externally to:

- search/map surfaces
- partner menu surfaces
- reservation/waiting surfaces
- delivery/menu partners
- store landing page
- SNS/marketing snippets
- franchise directory

External projection rules:

- approved source only
- price accuracy required
- allergen safety preserved
- availability status controlled
- provider capability not assumed
- stale projection marked or blocked
- customer-facing language approved
- external partner sync mismatches monitored

External projection is not source of truth.

---

## 21. Membership Coupon Wallet Display Boundary

Catch Menu may show limited value-related customer information.

Display rules:

- customer-specific value display requires identity/session authority
- coupon availability must be source-approved
- wallet/prepaid balance display must be authority-controlled
- membership benefit display must be traceable
- stale value display must be blocked or marked safe
- AI must not invent benefit text
- support path must exist for disputes

Catch Menu display does not mutate value.

---

## 22. Privacy And Identity Boundary

Catch Menu should minimize personal data.

Rules:

- menu browsing should not require identity by default
- order handoff may require session continuity
- membership/coupon/wallet may require authenticated identity
- table participation must not expose other customers
- support/recovery must mask identity by default
- unmasking requires support/admin authority
- wrong-account risk must block display of personal value state

Customer session is not full identity.

---

## 23. Degraded Operation Surface

Catch Menu must have safe degraded messages for:

- menu source unavailable
- availability source stale
- POS handoff unavailable
- payment status uncertain
- KDS status unavailable
- provider delay
- language file missing
- external projection stale
- support review required

Degraded messages should be calm and action-oriented.

They must not expose internal monitoring details.

---

## 24. Catch Menu Event Family Candidates

Potential event families:

| Event Family | Meaning |
|---|---|
| `CATCH_MENU_ENTRY_REQUESTED` | Customer opened menu surface |
| `CATCH_MENU_QR_ENTRY_USED` | QR entry used |
| `CATCH_MENU_NFC_ENTRY_USED` | NFC entry used |
| `CATCH_MENU_PROJECTION_RENDERED` | Menu projection rendered |
| `CATCH_MENU_PROJECTION_BLOCKED` | Projection blocked |
| `CATCH_MENU_ITEM_VIEWED` | Menu item viewed |
| `CATCH_MENU_ITEM_UNAVAILABLE_SHOWN` | Unavailable item shown |
| `CATCH_MENU_ORDER_HANDOFF_REQUESTED` | Customer requested order handoff |
| `CATCH_MENU_STATUS_SHOWN` | Customer status shown |
| `CATCH_MENU_FALLBACK_SHOWN` | Fallback shown |
| `CATCH_MENU_I18N_KEY_MISSING` | Message key missing |
| `CATCH_MENU_EXTERNAL_PROJECTION_SYNC_REQUIRED` | External projection sync issue |
| `CATCH_MENU_CUSTOMER_RECOVERY_NOTICE_SHOWN` | Customer recovery notice shown |

These are planning candidates and must later map to Foundation event/alert/error catalogs.

---

## 25. Catch Menu Error Code Candidates

Potential error codes:

| Error Code | Meaning |
|---|---|
| `ERR_CATCH_MENU_ENTRY_SCOPE_INVALID` | Entry scope invalid |
| `ERR_CATCH_MENU_QR_TOKEN_STALE` | QR token stale |
| `ERR_CATCH_MENU_NFC_TOKEN_STALE` | NFC token stale |
| `ERR_CATCH_MENU_STORE_CONTEXT_MISSING` | Store context missing |
| `ERR_CATCH_MENU_PROJECTION_SOURCE_MISSING` | Projection source missing |
| `ERR_CATCH_MENU_PROJECTION_STALE` | Projection stale |
| `ERR_CATCH_MENU_PRICE_MISMATCH` | Price mismatch |
| `ERR_CATCH_MENU_ALLERGEN_MISMATCH` | Allergen mismatch |
| `ERR_CATCH_MENU_AVAILABILITY_MISMATCH` | Availability mismatch |
| `ERR_CATCH_MENU_I18N_KEY_MISSING` | Visible key missing |
| `ERR_CATCH_MENU_AI_TEXT_UNAPPROVED` | AI visible text unapproved |
| `ERR_CATCH_MENU_EXTERNAL_SYNC_MISMATCH` | External projection sync mismatch |
| `ERR_CATCH_MENU_CUSTOMER_STATUS_UNSAFE` | Customer status unsafe |
| `ERR_CATCH_MENU_VALUE_DISPLAY_UNVERIFIED` | Value display unverified |

These codes must be reviewed against `09636`.

---

## 26. Customer-Safe Message Classes

| Message Class | Meaning |
|---|---|
| `MSG_MENU_INFO` | Menu information |
| `MSG_ITEM_STATUS` | Item availability/status |
| `MSG_ORDER_HANDOFF` | Order handoff status |
| `MSG_PAYMENT_SAFE_STATUS` | Payment-safe status |
| `MSG_KDS_SAFE_STATUS` | Fulfillment-safe status |
| `MSG_SUPPORT_REVIEW` | Support review notice |
| `MSG_CUSTOMER_RECOVERY` | Customer recovery notice |
| `MSG_FALLBACK` | Degraded/fallback notice |
| `MSG_LEGAL_PRIVACY` | Legal/privacy notice |
| `MSG_ALLERGEN_SAFETY` | Allergen/safety notice |
| `MSG_PROMOTION` | Promotion/benefit notice |

Each message class requires i18n key mapping.

---

## 27. Customer Surface Prohibited Content

Catch Menu must not display:

- raw provider errors
- raw POS errors
- raw KDS station errors
- raw payment gateway codes
- ledger mismatch details
- quarantine/containment internal labels
- daemon/pgvector/AI internal states
- other customer data
- staff-only notes
- unapproved refund promises
- legal conclusions
- security incident details
- unverified provider capability claims
- unreviewed AI text
- raw database identifiers

Customer surfaces should show safe status and next step.

---

## 28. Support Handoff Rule

If Catch Menu cannot safely resolve a visible state, it should hand off to support/staff review.

Support handoff may include:

- masked session reference
- store reference
- order reference if available
- visible customer issue class
- safe message key
- timestamp
- locale
- surface type
- customer action attempted

Support handoff must not expose restricted internals to the customer.

---

## 29. Readiness Blockers

| Blocker ID | Meaning |
|---|---|
| `BLOCKER-CATCH-MENU-SURFACE-0001` | Catch Menu surface policy not reviewed |
| `BLOCKER-CATCH-MENU-NAMING-0001` | Naming distinction missing |
| `BLOCKER-CATCH-MENU-SOURCE-0001` | Menu source rule missing |
| `BLOCKER-CATCH-MENU-I18N-0001` | i18n namespace missing |
| `BLOCKER-CATCH-MENU-PRICE-0001` | Price display boundary missing |
| `BLOCKER-CATCH-MENU-ALLERGEN-0001` | Allergen safety boundary missing |
| `BLOCKER-CATCH-MENU-AVAILABILITY-0001` | Availability boundary missing |
| `BLOCKER-CATCH-MENU-STATUS-0001` | Customer status boundary missing |
| `BLOCKER-CATCH-MENU-AI-TEXT-0001` | AI visible text boundary missing |
| `BLOCKER-CATCH-MENU-EXTERNAL-PROJECTION-0001` | External projection boundary missing |
| `BLOCKER-CATCH-MENU-CODING-0001` | Coding not authorized |

Open blockers prevent Catch Menu implementation.

---

## 30. Validation Checklist

Validation must confirm:

- Catch Menu is defined as customer surface
- Catch & Order distinction is preserved
- surface types are listed
- entry boundary is defined
- menu projection source rule exists
- price boundary exists
- allergen boundary exists
- availability boundary exists
- order handoff boundary exists
- customer status message boundary exists
- visible error policy exists
- i18n namespace exists
- locale policy exists
- AI visible text boundary exists
- external projection boundary exists
- value display boundary exists
- privacy/session boundary exists
- degraded surface rule exists
- prohibited content list exists
- support handoff rule exists
- coding remains deferred

---

## 31. Relationship To Previous Documents

This document follows:

- `09660 Catch & Order SaaS Runtime Boundary And Module Naming Policy`

It imports the security Foundation reference spine:

- `09560` through `09646`

It prepares later planning for:

- `09680 Provider Evidence Collection Template And Capability Review Policy`
- `09690 Security Monitoring Foundation README Insert And Index Patch Policy`
- `09700 Controlled Non-Runtime Catalog Schema Planning Policy`
- future Catch Menu i18n key catalog
- future Catch Menu projection contract
- future Catch & Order handoff contract

This document is customer surface projection and i18n planning only.

It does not authorize coding.

---

## 32. Final Rule

Catch Menu is the simple customer-facing menu access surface.

Catch & Order is the SaaS-facing integrated order and handoff runtime.

Catch Menu must remain easy for customers while preserving strict internal controls for source-approved menu projection, price, allergen, availability, i18n, safe status messages, AI-generated text, external projection, value display, privacy, and support handoff.

Catch Menu may show safe customer information.

Catch Menu must not expose raw provider/POS/KDS/payment/security/AI/vector/internal errors or become payment, POS, KDS, provider, value, identity, support, AI, pgvector, archive, or legal authority.

No Catch Menu implementation may proceed until a separate narrow handoff grants `CODING_ALLOWED`, imports Foundation controls, maps boundary tests, resolves blockers, and declares target files and data scope.
