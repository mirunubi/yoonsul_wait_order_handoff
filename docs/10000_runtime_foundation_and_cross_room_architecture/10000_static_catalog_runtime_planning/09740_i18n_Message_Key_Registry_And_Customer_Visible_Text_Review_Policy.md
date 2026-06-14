# 09740 i18n Message Key Registry And Customer Visible Text Review Policy

## 1. Purpose

This document defines the i18n Message Key Registry and Customer Visible Text Review Policy for Catch Menu, Catch & Order, provider-related customer status, support/admin surfaces, and future Franchise OS customer-facing surfaces.

The previous artifact `09730` defined the Provider Evidence Review Packet and Capability Acceptance Matrix Policy.

This document defines how customer-visible and support-visible text must be registered, reviewed, localized, approved, versioned, and mapped to events, alerts, errors, provider statuses, order states, payment states, KDS states, recovery cases, and degraded operation messages.

The purpose is to prevent unsafe visible text such as:

- raw provider errors
- raw POS errors
- raw payment gateway failures
- raw KDS internal states
- unreviewed AI-generated messages
- misleading payment promises
- unverified provider capability claims
- legally conclusive recovery statements
- allergen or price messages without review

This document is planning-only.

It does not authorize coding.

---

## 2. Scope

This policy applies to i18n and visible text planning for:

1. Catch Menu customer surface
2. Catch & Order customer status
3. Store staff-visible order support
4. Support/admin review surface
5. Payment status messages
6. KDS/fulfillment status messages
7. Provider delay/failure messages
8. Menu availability and sold-out messages
9. Price and discount messages
10. Allergen and nutrition warning messages
11. Membership, coupon, wallet, point, and benefit messages
12. Customer recovery messages
13. Legal/privacy notices
14. Degraded operation messages
15. External projection messages
16. AI-drafted message candidates
17. Franchise OS customer-facing policy messages
18. Workforce/applicant-facing messages if later connected

This document does not create translation files, UI copy, locale bundles, database tables, code, screens, or production text.

---

## 3. Core Principle

Customer-visible text is operational behavior.

A message can create trust, confusion, legal exposure, customer recovery obligation, or financial dispute.

The correct rule is:

Raw internal state must be translated into safe customer meaning.
Every visible message must use a key.
Every key must have source, owner, audience, locale, review status, and fallback.
AI may draft but must not publish.
Provider text must not be shown raw.
Payment, allergen, price, legal, and recovery text require stricter review.

Hardcoded visible operational strings are prohibited.

---

## 4. Catalog Header

| Field | Value |
|---|---|
| Document ID | `09740` |
| Package ID | `i18n.message_key_registry.customer_visible_review.v1` |
| Artifact Type | `I18N_MESSAGE_KEY_REGISTRY_POLICY` |
| Version | `v1` |
| Planning Status | `FOUNDATION_CANDIDATE` |
| Coding Status | `CODING_DEFERRED` |
| Runtime Authority | `MESSAGE_KEY_PLANNING_ONLY` |
| Owner | `Product / i18n / Content / Security / Customer Experience` |
| Dependencies | `09560` to `09730` |
| Provider Evidence Status | `CARRY_FORWARD_IF_PROVIDER_STATUS_VISIBLE` |
| i18n Requirement | `REQUIRED_FOR_ALL_VISIBLE_TEXT` |
| Audit Requirement | `REQUIRED_FOR_HIGH_RISK_VISIBLE_TEXT` |
| Security Requirement | `VISIBLE_TEXT_SOURCE_CONTROL_REQUIRED` |
| Review Requirement | `PRODUCT_CONTENT_I18N_SECURITY_LEGAL_REVIEW_REQUIRED` |
| Blocker Status | `I18N_MESSAGE_KEY_REGISTRY_REVIEW_REQUIRED` |

---

## 5. Message Key Registry Definition

An i18n message key registry is a controlled reference catalog for visible or semi-visible messages.

It records:

- message key
- surface
- audience
- domain
- message class
- source event/error/status
- visibility level
- review owner
- locale status
- fallback behavior
- AI-generation status
- legal/security/content review status
- customer recovery impact
- prohibited raw internal text mapping

The registry is not final production copy by itself.

It defines controlled message identity and review workflow.

---

## 6. Message Key Naming Pattern

Recommended key pattern:

`<surface>.<domain>.<state_or_error>.<message_type>`

Examples:

| Key | Meaning |
|---|---|
| `catch_menu.entry.loading.status` | Catch Menu entry loading |
| `catch_menu.menu.item_unavailable.notice` | Item unavailable notice |
| `catch_menu.menu.allergen.warning` | Allergen warning |
| `catch_menu.menu.price_review.fallback` | Price review fallback |
| `catch_order.order.confirming.status` | Order confirming |
| `catch_order.payment.checking.status` | Payment checking |
| `catch_order.kds.preparing.status` | Preparing status |
| `catch_order.provider.delay.notice` | Provider delay notice |
| `catch_order.recovery.staff_review.notice` | Staff review recovery |
| `support.order.issue_review.status` | Support review status |
| `admin.security.review_required.notice` | Admin security review notice |

Keys must be stable.

Visible copy may change by locale/version, but key identity should not be casually renamed.

---

## 7. Surface Catalog

| Surface | Meaning |
|---|---|
| `SURFACE_CATCH_MENU_CUSTOMER` | Customer-facing menu surface |
| `SURFACE_CATCH_ORDER_CUSTOMER` | Customer-facing order/status surface |
| `SURFACE_STORE_STAFF` | Store staff operational surface |
| `SURFACE_SUPPORT_ADMIN` | Support/admin review surface |
| `SURFACE_OWNER_ADMIN` | Owner/admin surface |
| `SURFACE_HQ_ADMIN` | HQ/admin surface |
| `SURFACE_EXTERNAL_PROJECTION` | External menu/search/partner projection |
| `SURFACE_MESSAGING` | SMS/Kakao/push/email message |
| `SURFACE_LEGAL_PRIVACY` | Legal/privacy notice |
| `SURFACE_WORKFORCE_APPLICANT` | Workforce/applicant surface if later used |
| `SURFACE_FRANCHISE_OS` | Franchise OS surface |

Each surface requires audience and visibility classification.

---

## 8. Audience Catalog

| Audience | Meaning |
|---|---|
| `AUDIENCE_CUSTOMER_ANONYMOUS` | Anonymous customer |
| `AUDIENCE_CUSTOMER_SESSION` | Customer with session context |
| `AUDIENCE_CUSTOMER_MEMBER` | Authenticated/member customer |
| `AUDIENCE_STORE_STAFF` | Store staff |
| `AUDIENCE_STORE_MANAGER` | Store manager |
| `AUDIENCE_SUPPORT_AGENT` | Support agent |
| `AUDIENCE_SUPPORT_LEAD` | Support lead |
| `AUDIENCE_OWNER` | Store owner |
| `AUDIENCE_HQ_ADMIN` | HQ admin |
| `AUDIENCE_PROVIDER_OPS` | Provider operations reviewer |
| `AUDIENCE_LEGAL_COMPLIANCE` | Legal/compliance reviewer |
| `AUDIENCE_APPLICANT` | Workforce applicant if later used |

A message safe for support may not be safe for customer.

---

## 9. Message Class Catalog

| Message Class | Meaning |
|---|---|
| `MSG_STATUS` | General status |
| `MSG_NOTICE` | Informational notice |
| `MSG_WARNING` | Caution or risk notice |
| `MSG_ERROR_SAFE` | Customer-safe error |
| `MSG_FALLBACK` | Degraded/fallback message |
| `MSG_RECOVERY` | Customer recovery message |
| `MSG_PAYMENT_SAFE` | Payment-safe message |
| `MSG_KDS_SAFE` | Fulfillment-safe message |
| `MSG_PROVIDER_SAFE` | Provider-safe customer message |
| `MSG_ALLERGEN_SAFETY` | Allergen/safety message |
| `MSG_PRICE_DISCOUNT` | Price/discount message |
| `MSG_MEMBERSHIP_VALUE` | Membership/coupon/wallet value message |
| `MSG_LEGAL_PRIVACY` | Legal/privacy message |
| `MSG_SUPPORT_INTERNAL` | Support-only internal explanation |
| `MSG_ADMIN_INTERNAL` | Admin-only internal explanation |
| `MSG_AI_DRAFT` | AI-drafted candidate text |

Message class determines review strictness.

---

## 10. Message Registry Record Schema

Each message key record should include:

| Field | Required Meaning |
|---|---|
| `message_key` | Stable i18n key |
| `surface` | Surface |
| `audience` | Audience |
| `domain` | Domain |
| `message_class` | Message class |
| `source_event_family` | Related event family |
| `source_alert_family` | Related alert family if any |
| `source_error_code` | Related error code if any |
| `source_status` | Related status if any |
| `customer_visibility` | Visibility level |
| `default_locale` | Default locale |
| `supported_locales` | Supported locales |
| `fallback_key` | Fallback key |
| `copy_status` | Draft/review/approved |
| `translation_status` | Translation status |
| `ai_generated` | Whether AI drafted |
| `content_review_status` | Content review |
| `legal_review_status` | Legal review if needed |
| `security_review_status` | Security review if needed |
| `provider_evidence_status` | Provider evidence status if provider-related |
| `customer_recovery_impact` | Whether recovery may be triggered |
| `audit_required` | Whether audit is required |
| `blocker_id` | Blocker if incomplete |
| `status` | Registry status |

A customer-visible key without fallback is incomplete.

---

## 11. Copy Status Catalog

| Status | Meaning |
|---|---|
| `COPY_NOT_STARTED` | Copy not written |
| `COPY_DRAFT` | Draft copy |
| `COPY_AI_DRAFT` | AI-drafted copy |
| `COPY_CONTENT_REVIEW_REQUIRED` | Content review required |
| `COPY_I18N_REVIEW_REQUIRED` | i18n review required |
| `COPY_SECURITY_REVIEW_REQUIRED` | Security review required |
| `COPY_LEGAL_REVIEW_REQUIRED` | Legal review required |
| `COPY_PROVIDER_EVIDENCE_REQUIRED` | Provider evidence required |
| `COPY_APPROVED_FOR_PLANNING` | Approved for planning only |
| `COPY_APPROVED_FOR_STAGING` | Approved for staging later |
| `COPY_APPROVED_FOR_PRODUCTION` | Approved for production later |
| `COPY_BLOCKED` | Blocked |
| `COPY_DEPRECATED` | Deprecated |

Default status:

`COPY_CONTENT_REVIEW_REQUIRED`

---

## 12. Translation Status Catalog

| Status | Meaning |
|---|---|
| `TRANSLATION_NOT_STARTED` | Translation not started |
| `TRANSLATION_DRAFT` | Translation draft |
| `TRANSLATION_MACHINE_DRAFT` | Machine translation draft |
| `TRANSLATION_REVIEW_REQUIRED` | Review required |
| `TRANSLATION_NATIVE_REVIEW_REQUIRED` | Native or expert review required |
| `TRANSLATION_LEGAL_REVIEW_REQUIRED` | Legal review required |
| `TRANSLATION_APPROVED_FOR_PLANNING` | Approved for planning |
| `TRANSLATION_APPROVED_FOR_PRODUCTION` | Approved for production later |
| `TRANSLATION_BLOCKED` | Blocked |
| `TRANSLATION_DEPRECATED` | Deprecated |

Machine translation must not be treated as production approval.

---

## 13. Customer Visibility Classification

| Visibility | Meaning |
|---|---|
| `VIS_CUSTOMER_SAFE` | Safe for customer |
| `VIS_CUSTOMER_SUPPORT_MEDIATED` | Customer should receive support-safe message |
| `VIS_CUSTOMER_RECOVERY_REQUIRED` | Recovery path required |
| `VIS_CUSTOMER_LEGAL_REVIEW_REQUIRED` | Legal review required |
| `VIS_CUSTOMER_BLOCKED` | Must not be shown |
| `VIS_STAFF_ONLY` | Staff only |
| `VIS_SUPPORT_ONLY` | Support only |
| `VIS_ADMIN_ONLY` | Admin only |
| `VIS_SECURITY_ONLY` | Security/internal only |

Internal states default to non-customer-visible.

---

## 14. Internal To Customer-Safe Mapping Rule

Raw internal state must map to customer-safe meaning.

Examples:

| Internal State | Customer-Safe Direction |
|---|---|
| `PROVIDER_CALLBACK_SIGNATURE_FAILED` | “We are checking your order status.” |
| `PAYMENT_LEDGER_MISMATCH` | “Payment status is being reviewed.” |
| `KDS_TICKET_DUPLICATE_RISK` | “Staff is confirming your order.” |
| `MENU_PROJECTION_STALE` | “Menu information is being refreshed.” |
| `AI_OUTPUT_BLOCKED` | Do not expose AI state |
| `PGVECTOR_RETRIEVAL_BLOCKED` | Do not expose vector state |
| `CONTAINMENT_ACTIVE` | Do not expose containment label |
| `QUARANTINE_ACTIVE` | Do not expose quarantine label |
| `LEGAL_HOLD_ACTIVE` | Do not expose legal hold label |
| `SUPPORT_AUTHORITY_MISSING` | “Staff review is required.” |

The final copy requires content/i18n review.

---

## 15. Prohibited Customer Text

Customer-visible text must not include:

- raw provider error codes
- raw database ids
- raw payment gateway codes
- raw POS/KDS station codes
- containment/quarantine labels
- daemon or pgvector details
- security incident details
- legal conclusions
- blame toward customer, staff, or provider
- unverified payment/refund promises
- unverified coupon/wallet value promises
- unverified provider capability claims
- unreviewed AI-generated text
- other customer data
- internal support notes

Customer text should describe safe status and next step.

---

## 16. Payment Message Rule

Payment-related messages require stricter review.

Payment messages must:

- avoid implying capture/refund unless confirmed
- avoid showing raw gateway failures
- avoid blaming customer without verification
- avoid promising refund timing without evidence
- distinguish checking, confirmed, failed, review-required, and support-required states
- map to provider evidence and finance review
- include customer recovery path where needed

Payment message keys require finance/security review.

---

## 17. KDS Fulfillment Message Rule

KDS/fulfillment messages must:

- avoid exposing kitchen station internals
- avoid promising exact timing unless reliable
- distinguish preparing, delayed, ready, staff-review-required
- avoid conflating KDS completion with payment/settlement
- avoid showing remake/duplicate internal reasons directly
- provide staff assistance path if uncertain

KDS status is kitchen progress, not financial truth.

---

## 18. Provider Delay Message Rule

Provider-related visible messages must:

- avoid raw provider names if not helpful
- avoid raw provider errors
- avoid claiming provider failure without verification
- avoid exposing integration architecture
- use safe delay/checking/fallback wording
- map to provider evidence status
- map to support route if customer action is needed

Provider evidence status must be reviewed before customer-facing provider capability claims are shown.

---

## 19. Allergen And Safety Message Rule

Allergen and safety messages require stricter review.

Allergen messages must:

- come from approved source
- be reviewed per locale
- avoid AI-only wording
- use conservative fallback if source is missing
- block or warn when safety data is incomplete
- avoid casual or ambiguous phrasing
- preserve legal/safety meaning across translations

Allergen text is safety-critical.

---

## 20. Price Discount Benefit Message Rule

Price, discount, coupon, wallet, point, and benefit messages must:

- come from approved value source
- avoid stale value display
- avoid implying benefit eligibility unless confirmed
- distinguish estimated, available, applied, pending, rejected
- map to value authority
- map to customer recovery if mismatch occurs
- require review before production

Value display is not value mutation.

---

## 21. Legal Privacy Message Rule

Legal/privacy messages must:

- be reviewed by legal/compliance
- not be casually AI-generated
- preserve meaning across locales
- have version and effective date
- include fallback behavior
- not be mixed with marketing copy without review
- map to consent/privacy flows if applicable

Legal/privacy messages require explicit owner.

---

## 22. AI-Drafted Text Boundary

AI may draft message candidates only if:

- the key is marked `COPY_AI_DRAFT`
- source context is approved for AI use
- sensitive raw data is excluded
- output is not published automatically
- content review is required
- legal/security review is required where applicable
- customer-facing status remains blocked until approved

AI can help draft.

AI cannot approve final customer-visible text.

---

## 23. Locale Fallback Rule

Each message key must define fallback.

Fallback hierarchy should define:

1. exact locale
2. language fallback
3. default locale
4. safe generic fallback
5. support/staff review if no safe fallback exists

No customer-visible surface should display empty, raw, or developer text when a translation is missing.

---

## 24. External Projection Message Rule

External projection messages must:

- use approved source text
- preserve price/allergen/availability safety
- account for provider update delay
- avoid unsupported ordering/payment claims
- map to external projection status
- define stale content fallback
- preserve locale where supported

External projection text is not source of truth.

---

## 25. Message Change Control

Message changes must record:

| Field | Meaning |
|---|---|
| `change_id` | Stable change id |
| `message_key` | Key changed |
| `locale` | Locale changed |
| `change_type` | Add/update/deprecate |
| `old_status` | Previous status |
| `new_status` | New status |
| `reason` | Reason |
| `risk_class` | Risk class |
| `review_owner` | Reviewer |
| `review_status` | Review status |
| `effective_status` | Effective status |
| `rollback_key` | Fallback/rollback key |

High-risk customer-visible text must not change silently.

---

## 26. Message Review Routes

| Message Area | Required Review |
|---|---|
| General menu/status | Product/content review |
| i18n translation | Localization review |
| Payment/refund | Finance/security/content review |
| Allergen/safety | Product/legal/content/localization review |
| Price/discount/benefit | Finance/product/content review |
| Provider status | Provider ops/security/content review |
| KDS/fulfillment | Store ops/product/content review |
| Customer recovery | Support/legal/content review |
| Legal/privacy | Legal/compliance/localization review |
| AI-generated | AI governance/content/security review |

Review route must be explicit.

---

## 27. i18n Registry File Layout Candidate

If future implementation chooses files, candidate paths may be:

| Path Candidate | Purpose |
|---|---|
| `i18n/registry/message_keys.*` | Message key registry |
| `i18n/registry/surfaces.*` | Surface catalog |
| `i18n/registry/message_classes.*` | Message class catalog |
| `i18n/registry/review_routes.*` | Review route mapping |
| `i18n/locales/ko/*.json` | Korean locale files |
| `i18n/locales/en/*.json` | English locale files |
| `i18n/fallbacks/*.json` | Fallback keys |
| `i18n/reviews/*.md` | Review notes |

This is a layout candidate only.

No files are authorized.

---

## 28. i18n Registry Database Layout Candidate

If future implementation chooses database-backed registry, candidate table families may be:

| Table Family Candidate | Purpose |
|---|---|
| `i18n_message_keys` | Message key registry |
| `i18n_message_translations` | Translation values |
| `i18n_message_reviews` | Review status |
| `i18n_message_fallbacks` | Fallback mapping |
| `i18n_message_sources` | Source event/error/status mapping |
| `i18n_message_change_log` | Change history |

This is a data-model candidate only.

No tables are authorized.

---

## 29. Readiness Blockers

| Blocker ID | Meaning |
|---|---|
| `BLOCKER-I18N-REGISTRY-0001` | i18n registry policy not reviewed |
| `BLOCKER-I18N-KEY-NAMING-0001` | Message key naming pattern missing |
| `BLOCKER-I18N-SURFACE-0001` | Surface catalog missing |
| `BLOCKER-I18N-AUDIENCE-0001` | Audience catalog missing |
| `BLOCKER-I18N-MESSAGE-CLASS-0001` | Message class catalog missing |
| `BLOCKER-I18N-RECORD-SCHEMA-0001` | Message registry schema missing |
| `BLOCKER-I18N-CUSTOMER-VIS-0001` | Customer visibility classification missing |
| `BLOCKER-I18N-RAW-INTERNAL-0001` | Internal-to-safe mapping missing |
| `BLOCKER-I18N-PAYMENT-0001` | Payment message rule missing |
| `BLOCKER-I18N-ALLERGEN-0001` | Allergen/safety rule missing |
| `BLOCKER-I18N-AI-TEXT-0001` | AI text boundary missing |
| `BLOCKER-I18N-FALLBACK-0001` | Fallback rule missing |
| `BLOCKER-I18N-CHANGE-CONTROL-0001` | Change control missing |
| `BLOCKER-I18N-CODING-0001` | Coding not authorized |

Open blockers prevent i18n implementation.

---

## 30. Validation Checklist

Validation must confirm:

- message key registry definition exists
- naming pattern exists
- surface catalog exists
- audience catalog exists
- message class catalog exists
- message record schema exists
- copy status catalog exists
- translation status catalog exists
- customer visibility classification exists
- internal-to-customer-safe mapping exists
- prohibited customer text list exists
- payment message rule exists
- KDS fulfillment message rule exists
- provider delay message rule exists
- allergen/safety message rule exists
- price/discount/benefit rule exists
- legal/privacy rule exists
- AI-drafted text boundary exists
- locale fallback rule exists
- external projection rule exists
- change control exists
- review routes exist
- file/database layout candidates are non-authorizing
- coding remains deferred

---

## 31. Relationship To Previous Documents

This document follows:

- `09730 Provider Evidence Review Packet And Capability Acceptance Matrix Policy`

It references:

- `09635 Security Event Alert Families And Severity Routing Catalog`
- `09636 Unix-Style Error Code Catalog And Domain Fault Mapping Policy`
- `09670 Catch Menu Customer Surface Projection And i18n Naming Policy`
- `09680 Provider Evidence Collection Template And Capability Review Policy`
- `09720 Boundary Test Matrix Artifact Planning And Review Packet Policy`
- `09560` through `09730`

It prepares later planning for:

- Catch Menu i18n key catalog
- Catch & Order status message catalog
- support/admin visible message catalog
- external projection message catalog
- customer recovery message catalog
- future i18n implementation handoff

This document is i18n message key registry planning only.

It does not authorize coding.

---

## 32. Final Rule

Every customer-visible and support-visible operational message must be controlled by a stable i18n key, source mapping, audience classification, visibility classification, fallback rule, review route, and approval status.

Raw provider, POS, KDS, payment, security, AI, pgvector, quarantine, containment, archive, legal hold, and internal support states must not be shown directly to customers.

AI may draft visible text candidates but cannot approve or publish them.

Payment, allergen, price, legal, provider, value, and customer recovery text require stricter review.

No i18n message registry implementation may proceed until a separate narrow handoff grants `CODING_ALLOWED`, declares target files or data structures, maps boundary tests, resolves blockers, and defines rollback.
