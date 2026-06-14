# 09780 Customer Recovery Message Catalog And Compensation Review Boundary Policy

## 1. Purpose

This document defines the Customer Recovery Message Catalog and Compensation Review Boundary Policy.

The previous artifact `09770` defined support/admin visible message boundaries and review surface mapping.

This document defines how customer recovery messages, recovery candidates, compensation review states, refund-related wording, coupon/point recovery, apology language, staff assistance messages, and customer reply drafts must be controlled before any customer-facing recovery flow is implemented.

The purpose is to prevent customer recovery from becoming an uncontrolled financial, legal, support, or brand-risk surface.

Customer recovery must be warm and helpful.

Customer recovery must also preserve:

- evidence
- approval
- authority
- audit
- finance review
- legal review where needed
- i18n review
- provider evidence
- support/admin boundaries
- AI draft boundaries
- pgvector similarity boundaries

This document is planning-only.

It does not authorize coding.

---

## 2. Scope

This policy applies to customer recovery planning for:

1. Order failure recovery
2. POS handoff failure recovery
3. Payment uncertainty recovery
4. Duplicate payment risk recovery
5. Refund/cancel request wording
6. KDS delay or fulfillment issue recovery
7. Missing item or remake issue recovery
8. Menu price/allergen/availability mismatch recovery
9. Coupon/point/wallet/membership benefit issue recovery
10. Provider delay/failure recovery
11. QR/NFC/Catch Menu entry failure recovery
12. Catch & Order order status uncertainty recovery
13. Support/admin customer reply drafts
14. AI-drafted recovery candidates
15. pgvector similar-case recovery context
16. Legal/privacy-sensitive recovery
17. Franchise OS customer recovery policy inheritance

This document does not create customer recovery UI, compensation workflows, refund APIs, coupon issuance, wallet adjustments, support ticket systems, or runtime messages.

---

## 3. Core Principle

Customer recovery is not compensation authority.

The correct rule is:

A customer may receive help.
A customer may receive a safe explanation.
A customer may receive an apology.
A customer may receive a recovery path.
But compensation, refund, coupon, wallet, point, or benefit changes require controlled authority.

Customer recovery message does not equal financial approval.

Support draft does not equal customer promise.

AI suggestion does not equal recovery decision.

---

## 4. Catalog Header

| Field | Value |
|---|---|
| Document ID | `09780` |
| Package ID | `customer_recovery.message_catalog.compensation_boundary.v1` |
| Artifact Type | `CUSTOMER_RECOVERY_MESSAGE_POLICY` |
| Version | `v1` |
| Planning Status | `FOUNDATION_CANDIDATE` |
| Coding Status | `CODING_DEFERRED` |
| Runtime Authority | `RECOVERY_MESSAGE_PLANNING_ONLY` |
| Owner | `Support / Customer Recovery / Product / Finance / Legal` |
| Dependencies | `09560` to `09770` |
| Provider Evidence Status | `CARRY_FORWARD_IF_PROVIDER_CAUSED_OR_PROVIDER_VISIBLE` |
| i18n Requirement | `REQUIRED_FOR_ALL_CUSTOMER_VISIBLE_RECOVERY_MESSAGES` |
| Audit Requirement | `REQUIRED_FOR_VALUE_OR_LEGAL_RECOVERY` |
| Security Requirement | `RECOVERY_AUTHORITY_BOUNDARY_REQUIRED` |
| Review Requirement | `SUPPORT_FINANCE_LEGAL_PRODUCT_I18N_REVIEW_REQUIRED` |
| Blocker Status | `CUSTOMER_RECOVERY_MESSAGE_REVIEW_REQUIRED` |

---

## 5. Customer Recovery Definition

Customer recovery is the controlled process of responding to customer harm, confusion, delay, mismatch, inconvenience, or trust loss caused by operational, technical, provider, payment, menu, KDS, POS, support, or service issues.

Customer recovery may include:

- apology
- explanation
- staff assistance
- support review
- correction request
- refund review
- compensation review
- coupon review
- point review
- wallet review
- replacement/remake review
- escalation
- follow-up message

Customer recovery does not automatically include:

- refund approval
- coupon issuance
- point adjustment
- wallet adjustment
- legal admission
- fault admission
- provider blame
- staff blame
- customer blame

---

## 6. Recovery Message Layer Catalog

| Layer | Meaning |
|---|---|
| `RECOVERY_CUSTOMER_SAFE_MESSAGE` | Customer-visible recovery message |
| `RECOVERY_SUPPORT_INTERNAL_NOTE` | Support-only explanation |
| `RECOVERY_STAFF_ACTION_GUIDE` | Store staff action guidance |
| `RECOVERY_FINANCE_REVIEW_NOTE` | Finance review note |
| `RECOVERY_LEGAL_REVIEW_NOTE` | Legal/compliance note |
| `RECOVERY_PROVIDER_OPS_NOTE` | Provider ops note |
| `RECOVERY_AI_DRAFT` | AI-drafted candidate |
| `RECOVERY_VECTOR_CONTEXT` | Similar-case context |
| `RECOVERY_AUDIT_EVIDENCE` | Evidence/audit reference |

Only `RECOVERY_CUSTOMER_SAFE_MESSAGE` may be shown to customers.

---

## 7. Recovery Case Family Catalog

| Case Family | Meaning |
|---|---|
| `RECOVERY_ORDER_UNCERTAIN` | Order status uncertain |
| `RECOVERY_ORDER_FAILED` | Order failed or could not proceed |
| `RECOVERY_DUPLICATE_ORDER_RISK` | Duplicate order risk |
| `RECOVERY_PAYMENT_UNCERTAIN` | Payment status uncertain |
| `RECOVERY_PAYMENT_DUPLICATE_RISK` | Duplicate payment risk |
| `RECOVERY_REFUND_REVIEW` | Refund review |
| `RECOVERY_KDS_DELAY` | Kitchen delay |
| `RECOVERY_KDS_MISSING_ITEM` | Missing item |
| `RECOVERY_KDS_REMAKE_REVIEW` | Remake review |
| `RECOVERY_MENU_PRICE_MISMATCH` | Price mismatch |
| `RECOVERY_MENU_ALLERGEN_RISK` | Allergen/safety issue |
| `RECOVERY_MENU_AVAILABILITY_MISMATCH` | Availability mismatch |
| `RECOVERY_PROVIDER_DELAY` | Provider delay |
| `RECOVERY_PROVIDER_FAILURE` | Provider failure |
| `RECOVERY_COUPON_VALUE_REVIEW` | Coupon/value review |
| `RECOVERY_WALLET_POINT_REVIEW` | Wallet/point review |
| `RECOVERY_IDENTITY_ACCOUNT_REVIEW` | Identity/account review |
| `RECOVERY_SUPPORT_ESCALATION` | Support escalation |

Each case family must define allowed messages and authority boundary.

---

## 8. Recovery Message Class Catalog

| Message Class | Meaning |
|---|---|
| `RECOVERY_MSG_ACKNOWLEDGEMENT` | Acknowledges issue |
| `RECOVERY_MSG_APOLOGY_GENERAL` | General apology |
| `RECOVERY_MSG_STATUS_CHECKING` | Status is being checked |
| `RECOVERY_MSG_STAFF_ASSISTANCE` | Staff will assist |
| `RECOVERY_MSG_SUPPORT_REVIEW` | Support review in progress |
| `RECOVERY_MSG_REFUND_REVIEW` | Refund review, not approval |
| `RECOVERY_MSG_COMPENSATION_REVIEW` | Compensation review, not approval |
| `RECOVERY_MSG_COUPON_REVIEW` | Coupon review, not issuance |
| `RECOVERY_MSG_POINT_REVIEW` | Point review, not adjustment |
| `RECOVERY_MSG_REMAKE_REVIEW` | Remake review |
| `RECOVERY_MSG_RESOLUTION_CONFIRMED` | Resolution confirmed by authority |
| `RECOVERY_MSG_FOLLOW_UP` | Follow-up message |
| `RECOVERY_MSG_LEGAL_PRIVACY` | Legal/privacy-sensitive recovery |
| `RECOVERY_MSG_SAFE_FALLBACK` | Safe fallback |

Message class determines review strictness.

---

## 9. Recovery Message Record Schema

Each recovery message mapping should include:

| Field | Required Meaning |
|---|---|
| `recovery_message_id` | Stable message id |
| `case_family` | Recovery case family |
| `message_class` | Recovery message class |
| `audience` | Customer, support, staff, finance, legal |
| `message_key` | i18n key |
| `fallback_key` | fallback i18n key |
| `source_event_family` | Source event |
| `source_error_code` | Source error code |
| `source_status` | Source status |
| `customer_visibility` | Visibility classification |
| `value_impact` | Whether money/value may be affected |
| `finance_review_required` | Finance review |
| `legal_review_required` | Legal review |
| `provider_evidence_required` | Provider evidence |
| `support_lead_review_required` | Support lead review |
| `ai_generated` | Whether AI drafted |
| `pgvector_context_used` | Whether vector context used |
| `evidence_ref_required` | Evidence requirement |
| `audit_required` | Audit requirement |
| `allowed_customer_promise` | What may be promised |
| `prohibited_customer_promise` | What must not be promised |
| `status` | Message mapping status |
| `blocker_id` | Blocker if incomplete |

A recovery message without prohibited promise boundary is incomplete.

---

## 10. Recovery Message Status Catalog

| Status | Meaning |
|---|---|
| `RECOVERY_MESSAGE_DRAFT` | Draft |
| `RECOVERY_MESSAGE_REVIEW_REQUIRED` | Review required |
| `RECOVERY_MESSAGE_CONTENT_REVIEW_REQUIRED` | Content review required |
| `RECOVERY_MESSAGE_I18N_REVIEW_REQUIRED` | i18n review required |
| `RECOVERY_MESSAGE_FINANCE_REVIEW_REQUIRED` | Finance review required |
| `RECOVERY_MESSAGE_LEGAL_REVIEW_REQUIRED` | Legal review required |
| `RECOVERY_MESSAGE_PROVIDER_REVIEW_REQUIRED` | Provider review required |
| `RECOVERY_MESSAGE_SUPPORT_LEAD_REVIEW_REQUIRED` | Support lead review required |
| `RECOVERY_MESSAGE_AI_REVIEW_REQUIRED` | AI governance review required |
| `RECOVERY_MESSAGE_APPROVED_FOR_PLANNING` | Planning approval only |
| `RECOVERY_MESSAGE_APPROVED_FOR_CUSTOMER_USE` | Customer use approval later |
| `RECOVERY_MESSAGE_BLOCKED` | Blocked |
| `RECOVERY_MESSAGE_DEPRECATED` | Deprecated |

Default status:

`RECOVERY_MESSAGE_REVIEW_REQUIRED`

---

## 11. Recovery Authority Boundary Catalog

| Authority Boundary | Meaning |
|---|---|
| `RECOVERY_AUTH_MESSAGE_ONLY` | Message only |
| `RECOVERY_AUTH_STAFF_ASSISTANCE` | Staff assistance only |
| `RECOVERY_AUTH_SUPPORT_REVIEW` | Support review |
| `RECOVERY_AUTH_SUPPORT_LEAD_APPROVAL_REQUIRED` | Support lead approval required |
| `RECOVERY_AUTH_FINANCE_APPROVAL_REQUIRED` | Finance approval required |
| `RECOVERY_AUTH_LEGAL_APPROVAL_REQUIRED` | Legal approval required |
| `RECOVERY_AUTH_PROVIDER_REVIEW_REQUIRED` | Provider review required |
| `RECOVERY_AUTH_VALUE_AUTHORITY_REQUIRED` | Coupon/wallet/point authority required |
| `RECOVERY_AUTH_PAYMENT_AUTHORITY_REQUIRED` | Payment/refund authority required |
| `RECOVERY_AUTH_BLOCKED` | Not allowed |

Default:

`RECOVERY_AUTH_MESSAGE_ONLY`

---

## 12. Safe Promise Catalog

Customer recovery messages may safely promise only what is controlled.

| Promise Class | Allowed Meaning |
|---|---|
| `PROMISE_ACKNOWLEDGE` | Acknowledge the issue |
| `PROMISE_CHECKING` | We are checking |
| `PROMISE_STAFF_ASSISTANCE` | Staff will assist |
| `PROMISE_SUPPORT_REVIEW` | Support will review |
| `PROMISE_CONFIRMED_ACTION` | Only if authority confirmed |
| `PROMISE_FOLLOW_UP` | Follow-up if process exists |
| `PROMISE_SAFE_FALLBACK` | Safe fallback |

Unsafe unless approved:

- refund guaranteed
- coupon guaranteed
- compensation guaranteed
- payment canceled
- provider at fault
- staff at fault
- legal responsibility admitted
- exact time guaranteed without reliable source

---

## 13. Order Recovery Message Rule

Order recovery messages must distinguish order request, POS acceptance, and store confirmation.

Examples:

| Internal Issue | Customer-Safe Recovery Direction |
|---|---|
| `ORDER_STATUS_UNCERTAIN` | Staff is confirming your order |
| `ORDER_DUPLICATE_RISK` | Staff is checking to prevent duplicate order |
| `ORDER_REJECTED_BY_POS` | Staff assistance may be needed |
| `ORDER_CANCEL_REQUESTED` | Cancel request is being reviewed |
| `ORDER_HANDOFF_FAILED` | We are checking your order with the store |

Do not promise cancellation unless confirmed by authority.

---

## 14. Payment Recovery Message Rule

Payment recovery messages require finance/security review.

Examples:

| Internal Issue | Customer-Safe Recovery Direction |
|---|---|
| `PAYMENT_STATE_UNCERTAIN` | Payment status is being reviewed |
| `PAYMENT_DUPLICATE_RISK` | We are checking to prevent duplicate payment |
| `PAYMENT_REFUND_REQUESTED` | Refund request is being reviewed |
| `PAYMENT_REFUND_CONFIRMED` | Refund confirmed only if provider-verified |
| `PAYMENT_LEDGER_MISMATCH` | Payment status is under review |

Do not promise refund timing unless verified and approved.

---

## 15. KDS Fulfillment Recovery Message Rule

KDS recovery messages must avoid blame and overpromising.

Examples:

| Internal Issue | Customer-Safe Recovery Direction |
|---|---|
| `KDS_DELAY_DETECTED` | Preparation may take a little longer |
| `KDS_MISSING_ITEM_REPORTED` | Staff will check the order |
| `KDS_REMAKE_REQUIRED` | Staff is reviewing preparation |
| `KDS_DUPLICATE_TICKET_RISK` | Staff is confirming the order |
| `KDS_OFFLINE_FALLBACK` | Store is handling preparation locally |

Remake does not equal compensation approval.

---

## 16. Menu Projection Recovery Message Rule

Menu projection recovery messages must protect price/allergen/availability trust.

Examples:

| Internal Issue | Customer-Safe Recovery Direction |
|---|---|
| `PRICE_MISMATCH_DETECTED` | Price information is being checked |
| `ALLERGEN_REVIEW_REQUIRED` | Staff can help confirm safety information |
| `AVAILABILITY_MISMATCH` | Availability is being checked |
| `MENU_PROJECTION_STALE` | Menu information is being refreshed |
| `EXTERNAL_SYNC_MISMATCH` | Menu information may be updated soon |

Allergen recovery requires strict review.

---

## 17. Provider Recovery Message Rule

Provider-related recovery must avoid raw provider blame.

Examples:

| Internal Issue | Customer-Safe Recovery Direction |
|---|---|
| `PROVIDER_TIMEOUT` | There is a temporary delay |
| `PROVIDER_CALLBACK_FAILED` | Status is being checked |
| `PROVIDER_RATE_LIMITED` | Status update may take longer |
| `PROVIDER_CAPABILITY_UNVERIFIED` | This feature is not currently available |
| `PROVIDER_REPLAY_DETECTED` | Status is under review |

Provider-specific claims require evidence.

---

## 18. Value Recovery Message Rule

Coupon, wallet, point, membership, and benefit recovery requires value authority.

Examples:

| Internal Issue | Customer-Safe Recovery Direction |
|---|---|
| `COUPON_APPLY_FAILED` | Coupon use is being checked |
| `COUPON_DUPLICATE_RISK` | Coupon status is being reviewed |
| `POINT_EARN_PENDING` | Points are being checked |
| `WALLET_BALANCE_UNCERTAIN` | Balance is being reviewed |
| `BENEFIT_ELIGIBILITY_UNVERIFIED` | Benefit eligibility is being checked |

Do not promise value adjustment until approved.

---

## 19. Identity And Privacy Recovery Message Rule

Identity/account recovery must preserve privacy.

Examples:

| Internal Issue | Customer-Safe Recovery Direction |
|---|---|
| `SESSION_IDENTITY_MISMATCH` | Account/session information is being checked |
| `WRONG_ACCOUNT_RISK` | Support review is required |
| `IDENTITY_LINK_PENDING` | Sign-in or confirmation may be needed |
| `IDENTITY_LINK_BLOCKED` | Support review is required |
| `CONSENT_REVIEW_REQUIRED` | Additional confirmation may be needed |

Do not reveal other customer data.

---

## 20. Legal Sensitive Recovery Rule

Legal-sensitive recovery messages require legal/compliance review.

Legal-sensitive cases include:

- allergen/safety incident
- payment dispute escalation
- privacy issue
- discrimination/harassment complaint
- serious service failure
- injury/health claim
- legal demand
- regulatory complaint
- high-value financial dispute

Customer text must not admit liability without legal approval.

---

## 21. AI Recovery Draft Boundary

AI may draft recovery candidates only if:

- message is marked AI draft
- source data is approved for AI use
- sensitive raw data is excluded
- AI output is not automatically sent
- support/content review is required
- finance/legal review is required where applicable
- customer promise boundary is enforced

AI may suggest tone.

AI may not approve recovery.

---

## 22. pgvector Recovery Context Boundary

pgvector may provide:

- similar incident references
- similar recovery patterns
- SOP references
- prior evidence checklist
- support review context

pgvector must not:

- prove current case
- decide compensation
- approve refund
- determine liability
- identify customer
- replace evidence

Similarity is not proof.

---

## 23. Recovery i18n Key Namespace

Recommended namespace:

`recovery.<case_family>.<message_class>.<audience>`

Examples:

| Key | Meaning |
|---|---|
| `recovery.order_uncertain.status.customer` | Order status checking |
| `recovery.payment_uncertain.review.customer` | Payment review |
| `recovery.duplicate_payment.checking.customer` | Duplicate payment check |
| `recovery.kds_delay.notice.customer` | Kitchen delay notice |
| `recovery.price_mismatch.checking.customer` | Price checking |
| `recovery.allergen_review.staff_assist.customer` | Allergen staff assist |
| `recovery.coupon_review.status.customer` | Coupon review |
| `recovery.support_escalation.notice.customer` | Support escalation |
| `recovery.compensation_review.status.customer` | Compensation review |
| `recovery.safe_fallback.notice.customer` | Safe fallback |

All visible recovery keys must be registered in the i18n registry.

---

## 24. Recovery Review Route Matrix

| Recovery Area | Required Route |
|---|---|
| Order uncertainty | Store/support review |
| POS handoff failure | Store/provider ops/support review |
| Payment/refund | Finance/security/support review |
| KDS delay/missing item | Store ops/support review |
| Price mismatch | Product/store/support review |
| Allergen/safety | Product/legal/support review |
| Provider failure | Provider ops/security/support review |
| Coupon/wallet/point | Finance/value authority/support review |
| Identity/account | Privacy/support review |
| Legal-sensitive issue | Legal/compliance/support lead review |
| AI-drafted recovery | AI governance/content/support review |

Review route must be explicit.

---

## 25. Customer Reply Draft Rule

A customer reply draft must define:

| Field | Meaning |
|---|---|
| `draft_id` | Stable draft id |
| `case_family` | Recovery case family |
| `message_key` | i18n key or draft key |
| `draft_source` | Human, AI, template |
| `customer_promise_class` | Safe promise class |
| `value_impact` | Whether money/value affected |
| `review_required` | Required reviews |
| `approved_to_send` | Must default false |
| `sent_status` | Sent/not sent |
| `audit_required` | Audit requirement |

Default:

`approved_to_send = false`

---

## 26. Recovery Change Control

Recovery message changes must record:

| Field | Meaning |
|---|---|
| `change_id` | Stable change id |
| `recovery_message_id` | Message changed |
| `case_family` | Case family |
| `old_message_key` | Previous key |
| `new_message_key` | New key |
| `old_promise_boundary` | Previous promise boundary |
| `new_promise_boundary` | New promise boundary |
| `reason` | Reason |
| `risk_class` | Risk class |
| `review_owner` | Reviewer |
| `review_status` | Review status |
| `rollback_key` | Rollback key |

Recovery wording changes may affect legal and financial risk.

---

## 27. File Layout Candidate

If future implementation chooses files, candidate paths may be:

| Path Candidate | Purpose |
|---|---|
| `catalogs/recovery/case_families.*` | Recovery case family catalog |
| `catalogs/recovery/message_classes.*` | Recovery message classes |
| `catalogs/recovery/authority_boundaries.*` | Recovery authority boundaries |
| `catalogs/recovery/safe_promises.*` | Safe promise catalog |
| `i18n/registry/recovery_message_keys.*` | Recovery i18n key registry |
| `i18n/locales/ko/recovery.*` | Korean recovery copy |
| `i18n/locales/en/recovery.*` | English recovery copy |
| `docs/recovery/message_review.md` | Recovery review packet |

This is a layout candidate only.

No files are authorized.

---

## 28. Database Layout Candidate

If future implementation chooses database-backed recovery message mapping, candidate table families may be:

| Table Family Candidate | Purpose |
|---|---|
| `recovery_case_families` | Recovery case family registry |
| `recovery_message_mappings` | Recovery message mapping |
| `recovery_safe_promises` | Safe promise catalog |
| `recovery_review_routes` | Review route mapping |
| `recovery_message_reviews` | Review records |
| `recovery_message_change_log` | Change history |

This is a data-model candidate only.

No tables are authorized.

---

## 29. Readiness Blockers

| Blocker ID | Meaning |
|---|---|
| `BLOCKER-RECOVERY-MESSAGE-0001` | Recovery message policy not reviewed |
| `BLOCKER-RECOVERY-LAYER-0001` | Recovery layer catalog missing |
| `BLOCKER-RECOVERY-CASE-0001` | Case family catalog missing |
| `BLOCKER-RECOVERY-CLASS-0001` | Message class catalog missing |
| `BLOCKER-RECOVERY-SCHEMA-0001` | Recovery message schema missing |
| `BLOCKER-RECOVERY-AUTHORITY-0001` | Recovery authority boundary missing |
| `BLOCKER-RECOVERY-PROMISE-0001` | Safe promise catalog missing |
| `BLOCKER-RECOVERY-PAYMENT-0001` | Payment recovery rule missing |
| `BLOCKER-RECOVERY-VALUE-0001` | Value recovery rule missing |
| `BLOCKER-RECOVERY-LEGAL-0001` | Legal-sensitive rule missing |
| `BLOCKER-RECOVERY-AI-0001` | AI recovery draft boundary missing |
| `BLOCKER-RECOVERY-PGVECTOR-0001` | pgvector recovery boundary missing |
| `BLOCKER-RECOVERY-I18N-0001` | Recovery i18n namespace missing |
| `BLOCKER-RECOVERY-CODING-0001` | Coding not authorized |

Open blockers prevent recovery message implementation.

---

## 30. Validation Checklist

Validation must confirm:

- customer recovery definition exists
- recovery message layers exist
- recovery case family catalog exists
- recovery message class catalog exists
- recovery message record schema exists
- recovery message status catalog exists
- recovery authority boundary exists
- safe promise catalog exists
- order recovery rule exists
- payment recovery rule exists
- KDS recovery rule exists
- menu projection recovery rule exists
- provider recovery rule exists
- value recovery rule exists
- identity/privacy recovery rule exists
- legal-sensitive recovery rule exists
- AI recovery draft boundary exists
- pgvector recovery context boundary exists
- i18n key namespace exists
- review route matrix exists
- customer reply draft rule exists
- change control exists
- layout candidates are non-authorizing
- coding remains deferred

---

## 31. Relationship To Previous Documents

This document follows:

- `09770 Support Admin Visible Message Boundary And Review Surface Mapping Policy`

It references:

- `09670 Catch Menu Customer Surface Projection And i18n Naming Policy`
- `09740 i18n Message Key Registry And Customer Visible Text Review Policy`
- `09750 Catch & Order Status Message Catalog And Customer Safe State Mapping Policy`
- `09760 Catch Menu Status Surface And Order Handoff Message Mapping Policy`
- `09770 Support Admin Visible Message Boundary And Review Surface Mapping Policy`
- `09560` through `09770`

It prepares later planning for:

- customer recovery i18n key catalog
- recovery case review packet
- compensation review authority boundary
- support/admin customer reply workflow
- future customer recovery implementation handoff

This document is customer recovery message planning only.

It does not authorize coding.

---

## 32. Final Rule

Customer recovery must be warm, helpful, and controlled.

Customer recovery messages may acknowledge, explain safely, guide, escalate, and request review.

They must not promise refund, compensation, coupon, wallet adjustment, point adjustment, provider fault, staff fault, legal responsibility, or exact resolution timing without proper authority and evidence.

AI may draft recovery language but cannot approve it.

pgvector may provide similar-case context but cannot decide the case.

No customer recovery message or compensation review implementation may proceed until a separate narrow handoff grants `CODING_ALLOWED`, declares target files or data structures, maps boundary tests, resolves blockers, and defines rollback.
