# 09770_Policy_Support_Admin_Visible_Message_Boundary_And_Review_Surface_Mapping

## 1. Purpose

This document defines the Support Admin Visible Message Boundary and Review Surface Mapping Policy.

The previous artifact `09760` defined the Catch Menu status surface and order handoff message mapping policy.

This document defines how support/admin-facing messages, review states, operational explanations, customer recovery notes, provider issue summaries, payment/KDS/POS mismatch notices, AI-drafted notes, pgvector similarity context, and archive/evidence references may be shown to support/admin users without becoming unauthorized authority.

The purpose is to prevent support/admin surfaces from becoming uncontrolled mutation or truth surfaces.

Support/admin may see more detail than customers.

Support/admin must still remain bounded by role, authority, masking, evidence, audit, review ownership, and domain-specific approval rules.

This document is planning-only.

It does not authorize coding.

---

## 2. Scope

This policy applies to support/admin visible message and review surface planning for:

1. Order issue review
2. POS handoff issue review
3. Payment status issue review
4. KDS/fulfillment issue review
5. Provider callback issue review
6. Customer recovery review
7. Membership/coupon/wallet/point issue review
8. Identity/session linking review
9. Menu projection issue review
10. Catch Menu customer surface issue review
11. Catch & Order status mapping review
12. AI-drafted support note review
13. pgvector similarity context review
14. Archive/evidence retrieval review
15. Legal hold/deletion/anonymization review visibility
16. Staff/store escalation review
17. Owner/HQ escalation review
18. Franchise OS support review surface

This document does not create support/admin UI, permissions, RPCs, tables, dashboards, workflows, message catalogs, or runtime actions.

---

## 3. Core Principle

Support/admin visibility is not authority.

The correct rule is:

Support may observe.
Support may classify.
Support may request.
Support may recommend.
Support may route.
Support may prepare recovery.
Support may not directly mutate authority domains unless a controlled authority function allows it.

Support/admin messages must preserve:

- masking
- role scope
- audit
- evidence linkage
- customer-safe translation
- authority separation
- escalation path
- review status
- blocker visibility

---

## 4. Catalog Header

| Field | Value |
|---|---|
| Document ID | `09770` |
| Package ID | `support_admin.visible_message_boundary.review_surface_mapping.v1` |
| Artifact Type | `SUPPORT_ADMIN_VISIBLE_MESSAGE_POLICY` |
| Version | `v1` |
| Planning Status | `FOUNDATION_CANDIDATE` |
| Coding Status | `CODING_DEFERRED` |
| Runtime Authority | `REVIEW_SURFACE_PLANNING_ONLY` |
| Owner | `Support / Admin / Security / Customer Recovery / Product` |
| Dependencies | `09560` to `09760` |
| Provider Evidence Status | `CARRY_FORWARD_IF_PROVIDER_CONTEXT_VISIBLE` |
| i18n Requirement | `REQUIRED_IF_SUPPORT_MESSAGE_CAN_BE_CUSTOMER_FORWARDED` |
| Audit Requirement | `REQUIRED_FOR_HIGH_RISK_SUPPORT_REVIEW` |
| Security Requirement | `SUPPORT_VISIBILITY_AUTHORITY_SEPARATION_REQUIRED` |
| Review Requirement | `SUPPORT_SECURITY_PRIVACY_LEGAL_REVIEW_REQUIRED` |
| Blocker Status | `SUPPORT_ADMIN_VISIBLE_MESSAGE_REVIEW_REQUIRED` |

---

## 5. Support Admin Surface Definition

A support/admin surface is any internal surface that shows operational messages, issue summaries, error context, recovery recommendations, evidence references, audit links, provider records, AI summaries, pgvector similarity context, or customer-facing draft responses to support, store staff, owner, HQ, legal, finance, provider ops, or admin users.

Support/admin surfaces may include:

- support inbox
- incident review panel
- order issue timeline
- payment review panel
- KDS mismatch panel
- provider callback review panel
- customer recovery panel
- archive/evidence viewer
- AI summary panel
- pgvector similar-case panel
- legal hold review panel
- admin escalation panel

A support/admin surface must not silently execute authority.

---

## 6. Support Visibility Layer Catalog

| Layer | Meaning |
|---|---|
| `SUPPORT_VISIBLE_SUMMARY` | Human-readable issue summary |
| `SUPPORT_VISIBLE_STATUS` | Support-safe status |
| `SUPPORT_VISIBLE_EVIDENCE` | Evidence references |
| `SUPPORT_VISIBLE_AUDIT` | Audit references |
| `SUPPORT_VISIBLE_PROVIDER_CONTEXT` | Provider context |
| `SUPPORT_VISIBLE_PAYMENT_CONTEXT` | Payment review context |
| `SUPPORT_VISIBLE_KDS_CONTEXT` | KDS/fulfillment context |
| `SUPPORT_VISIBLE_CUSTOMER_CONTEXT` | Masked customer context |
| `SUPPORT_VISIBLE_AI_DRAFT` | AI-drafted internal note |
| `SUPPORT_VISIBLE_VECTOR_CONTEXT` | Similarity/retrieval context |
| `SUPPORT_VISIBLE_LEGAL_CONTEXT` | Legal/compliance review-only context |
| `SUPPORT_VISIBLE_ESCALATION` | Escalation route/status |

Each layer must define role access and authority boundary.

---

## 7. Support Audience Catalog

| Audience | Meaning |
|---|---|
| `AUD_SUPPORT_AGENT` | Basic support agent |
| `AUD_SUPPORT_LEAD` | Support lead |
| `AUD_STORE_STAFF` | Store staff |
| `AUD_STORE_MANAGER` | Store manager |
| `AUD_OWNER` | Store owner |
| `AUD_HQ_ADMIN` | HQ admin |
| `AUD_PROVIDER_OPS` | Provider operations reviewer |
| `AUD_FINANCE_REVIEWER` | Finance/payment reviewer |
| `AUD_PRIVACY_REVIEWER` | Privacy reviewer |
| `AUD_LEGAL_COMPLIANCE` | Legal/compliance reviewer |
| `AUD_SECURITY_REVIEWER` | Security reviewer |
| `AUD_AI_GOVERNANCE` | AI governance reviewer |
| `AUD_DATA_GOVERNANCE` | Data/archive reviewer |
| `AUD_FRANCHISE_OPS` | Franchise operations reviewer |

Audience must match role and scope.

---

## 8. Support Message Class Catalog

| Message Class | Meaning |
|---|---|
| `SUPPORT_MSG_SUMMARY` | Issue summary |
| `SUPPORT_MSG_STATUS` | Review status |
| `SUPPORT_MSG_WARNING` | Warning |
| `SUPPORT_MSG_ERROR_CONTEXT` | Internal error context |
| `SUPPORT_MSG_PROVIDER_CONTEXT` | Provider evidence/context |
| `SUPPORT_MSG_PAYMENT_CONTEXT` | Payment review context |
| `SUPPORT_MSG_KDS_CONTEXT` | KDS/fulfillment review context |
| `SUPPORT_MSG_CUSTOMER_RECOVERY` | Customer recovery note |
| `SUPPORT_MSG_ESCALATION` | Escalation guidance |
| `SUPPORT_MSG_AI_DRAFT` | AI-drafted note |
| `SUPPORT_MSG_VECTOR_CONTEXT` | Similar case context |
| `SUPPORT_MSG_LEGAL_HOLD` | Legal hold/deletion context |
| `SUPPORT_MSG_AUDIT_EVIDENCE` | Audit/evidence reference |
| `SUPPORT_MSG_CUSTOMER_REPLY_DRAFT` | Draft customer reply |

Message class determines visibility, review, and action boundary.

---

## 9. Support Message Record Schema

Each support/admin message mapping should include:

| Field | Required Meaning |
|---|---|
| `message_id` | Stable message id |
| `surface` | Support/admin surface |
| `audience` | Intended audience |
| `message_class` | Message class |
| `source_domain` | Order, payment, KDS, provider, etc. |
| `source_event_family` | Related event family |
| `source_error_code` | Related error code |
| `source_status` | Related status |
| `visibility_level` | Visibility level |
| `masking_required` | Whether masking applies |
| `unmask_authority_required` | Whether unmasking requires authority |
| `evidence_ref_required` | Evidence requirement |
| `audit_required` | Audit requirement |
| `customer_forwardable` | Whether text may be forwarded to customer |
| `i18n_key_required` | Whether i18n key is required |
| `ai_generated` | Whether AI drafted |
| `pgvector_context_used` | Whether vector context used |
| `legal_review_required` | Legal review requirement |
| `provider_evidence_status` | Provider evidence status if relevant |
| `allowed_actions` | Actions allowed from this surface |
| `prohibited_actions` | Actions prohibited from this surface |
| `review_owner` | Review owner |
| `status` | Message mapping status |
| `blocker_id` | Blocker if incomplete |

A support message without authority boundary is incomplete.

---

## 10. Support Message Status Catalog

| Status | Meaning |
|---|---|
| `SUPPORT_MESSAGE_DRAFT` | Draft |
| `SUPPORT_MESSAGE_REVIEW_REQUIRED` | Review required |
| `SUPPORT_MESSAGE_SECURITY_REVIEW_REQUIRED` | Security review required |
| `SUPPORT_MESSAGE_PRIVACY_REVIEW_REQUIRED` | Privacy review required |
| `SUPPORT_MESSAGE_LEGAL_REVIEW_REQUIRED` | Legal review required |
| `SUPPORT_MESSAGE_FINANCE_REVIEW_REQUIRED` | Finance review required |
| `SUPPORT_MESSAGE_PROVIDER_REVIEW_REQUIRED` | Provider review required |
| `SUPPORT_MESSAGE_AI_REVIEW_REQUIRED` | AI governance review required |
| `SUPPORT_MESSAGE_APPROVED_FOR_PLANNING` | Planning approval only |
| `SUPPORT_MESSAGE_APPROVED_FOR_INTERNAL_USE` | Internal use approval later |
| `SUPPORT_MESSAGE_CUSTOMER_REPLY_REVIEW_REQUIRED` | Customer reply review required |
| `SUPPORT_MESSAGE_BLOCKED` | Blocked |
| `SUPPORT_MESSAGE_DEPRECATED` | Deprecated |

Default status:

`SUPPORT_MESSAGE_REVIEW_REQUIRED`

---

## 11. Visibility Level Catalog

| Visibility Level | Meaning |
|---|---|
| `VIS_SUPPORT_MASKED` | Support can see masked context |
| `VIS_SUPPORT_UNMASKED_WITH_AUTHORITY` | Unmasking requires authority |
| `VIS_STORE_SCOPED` | Store-scoped visibility |
| `VIS_OWNER_SCOPED` | Owner/tenant-scoped visibility |
| `VIS_HQ_SCOPED` | HQ-scoped visibility |
| `VIS_FINANCE_ONLY` | Finance-only visibility |
| `VIS_SECURITY_ONLY` | Security-only visibility |
| `VIS_LEGAL_ONLY` | Legal/compliance-only visibility |
| `VIS_PROVIDER_OPS_ONLY` | Provider ops-only visibility |
| `VIS_AI_GOVERNANCE_ONLY` | AI governance-only visibility |
| `VIS_DATA_GOVERNANCE_ONLY` | Data/archive governance only |
| `VIS_CUSTOMER_FORWARDABLE_AFTER_REVIEW` | Can become customer response after review |
| `VIS_BLOCKED` | Must not be shown |

Default for sensitive context:

`VIS_SUPPORT_MASKED`

---

## 12. Order Issue Support Mapping Rule

Order issue support messages may show:

- order reference
- store context
- session context
- order status summary
- POS handoff status summary
- customer-safe issue class
- evidence reference
- recommended next route

They must not directly allow:

- forced order acceptance
- payment mutation
- refund approval
- KDS completion override
- customer identity merge
- value adjustment

Order support message must clearly separate observation from action.

---

## 13. POS Handoff Support Mapping Rule

POS handoff support messages may show:

- POS handoff attempt status
- POS acceptance uncertainty
- duplicate submit risk
- POS offline/local cache marker
- POS store mapping issue
- provider evidence status
- internal error mapping

They must not imply:

- POS accepted equals payment confirmed
- POS cancellation equals refund confirmed
- POS state is internal ledger truth

Support may route to store/provider/technical review.

---

## 14. Payment Support Mapping Rule

Payment support messages require stricter review.

Support payment messages may show:

- payment checking status
- provider verification status
- amount mismatch summary
- duplicate risk summary
- refund request status
- settlement/reconciliation requirement
- finance review route
- customer recovery route

They must not directly allow:

- refund execution without authority
- capture/cancel execution without authority
- ledger correction without finance path
- customer promise without confirmation
- raw gateway error exposure to customer

Finance/security review is required for high-risk payment messages.

---

## 15. KDS Fulfillment Support Mapping Rule

KDS support messages may show:

- ticket created/accepted status
- delay detected
- duplicate ticket risk
- remake required
- station routing issue
- manual fallback marker
- evidence requirement

They must not imply:

- KDS completed equals payment settled
- remake equals compensation approved
- kitchen action equals refund authority

Store operations review may be required.

---

## 16. Provider Context Support Mapping Rule

Provider context messages may show:

- provider capability status
- callback received
- signature failure
- replay risk
- timeout/rate limit
- sandbox-only status
- production verification pending
- provider error mapping
- provider evidence packet reference

They must not show raw provider payloads unless authorized.

They must not treat provider state as internal truth without verification.

---

## 17. Customer Recovery Support Mapping Rule

Customer recovery messages may show:

- issue class
- customer-safe summary
- recovery candidate
- evidence requirement
- support route
- approval requirement
- compensation review status
- customer reply draft

They must not:

- promise compensation before approval
- blame customer/staff/provider without evidence
- reveal internal security states
- expose raw provider/payment/KDS errors
- close recovery case without evidence

Recovery messages require support lead review when value is involved.

---

## 18. Value And Membership Support Mapping Rule

Membership, coupon, wallet, point, and benefit support messages may show:

- value display uncertainty
- coupon duplicate risk
- point earning pending
- wallet balance review
- benefit eligibility review
- value ledger mismatch summary
- finance/support route

They must not directly allow:

- wallet balance adjustment
- coupon issuance/reissue
- point mutation
- membership merge
- benefit override

Value mutation must go through controlled authority path.

---

## 19. Identity And Privacy Support Mapping Rule

Identity/privacy support messages may show:

- masked session reference
- masked customer reference
- identity link candidate
- wrong-account risk
- consent review status
- duplicate identity candidate
- privacy review route

They must not:

- expose full identity by default
- link identity without consent/authority
- reveal another customer’s session
- use AI/pgvector as identity proof
- bypass privacy review

Unmasking requires audit.

---

## 20. AI Draft Support Mapping Rule

AI-drafted support messages must be labeled.

AI may draft:

- issue summary
- evidence checklist
- route suggestion
- customer reply candidate
- similar incident explanation
- internal triage note

AI must not:

- approve refund
- approve compensation
- close case
- send customer reply automatically
- confirm provider capability
- mutate order/payment/value/identity state
- suppress alert
- release containment/quarantine

AI-drafted text requires human review.

---

## 21. pgvector Context Support Mapping Rule

pgvector similarity context may show:

- similar incident references
- similar provider error patterns
- similar recovery patterns
- SOP references
- evidence checklist suggestions

pgvector must not:

- prove the current case
- replace evidence
- decide outcome
- approve refund/compensation
- identify customer
- confirm provider status
- become source of truth

Similarity is context only.

---

## 22. Archive Evidence Support Mapping Rule

Archive/evidence messages may show:

- archive object reference
- evidence packet reference
- checksum status
- retrieval status
- legal hold status to authorized users
- audit trail reference
- retention tier

They must not:

- restore archive into runtime truth
- delete evidence
- bypass legal hold
- expose legal hold to customer
- expose restricted archive content to unauthorized support
- treat archived record as current runtime state without reconciliation

Archive restore is evidence retrieval only.

---

## 23. Customer Reply Draft Boundary

Support/admin may prepare customer reply drafts.

Customer reply drafts must:

- use customer-safe wording
- avoid raw internal states
- use approved i18n keys where reusable
- avoid unapproved refund/payment promises
- avoid legal conclusions
- avoid blame without evidence
- route high-risk text for review
- mark AI-generated drafts if applicable

Customer reply draft is not customer message until approved/sent through controlled workflow.

---

## 24. Allowed Support Actions Catalog

| Action | Meaning |
|---|---|
| `SUPPORT_ACTION_VIEW_MASKED_CONTEXT` | View masked issue context |
| `SUPPORT_ACTION_ADD_INTERNAL_NOTE` | Add internal note |
| `SUPPORT_ACTION_REQUEST_EVIDENCE` | Request evidence |
| `SUPPORT_ACTION_ROUTE_TO_STORE` | Route to store |
| `SUPPORT_ACTION_ROUTE_TO_PROVIDER_OPS` | Route to provider ops |
| `SUPPORT_ACTION_ROUTE_TO_FINANCE` | Route to finance |
| `SUPPORT_ACTION_ROUTE_TO_LEGAL` | Route to legal |
| `SUPPORT_ACTION_ROUTE_TO_SECURITY` | Route to security |
| `SUPPORT_ACTION_PREPARE_CUSTOMER_REPLY` | Prepare reply draft |
| `SUPPORT_ACTION_REQUEST_RECOVERY_REVIEW` | Request recovery review |
| `SUPPORT_ACTION_ESCALATE` | Escalate |

Allowed actions are review or routing actions by default.

---

## 25. Prohibited Support Actions Catalog

| Action | Meaning |
|---|---|
| `SUPPORT_ACTION_DIRECT_LEDGER_MUTATION` | Prohibited |
| `SUPPORT_ACTION_DIRECT_PAYMENT_REFUND` | Prohibited without authority |
| `SUPPORT_ACTION_DIRECT_WALLET_ADJUSTMENT` | Prohibited |
| `SUPPORT_ACTION_DIRECT_COUPON_ISSUE` | Prohibited |
| `SUPPORT_ACTION_DIRECT_POINT_ADJUSTMENT` | Prohibited |
| `SUPPORT_ACTION_DIRECT_IDENTITY_MERGE` | Prohibited |
| `SUPPORT_ACTION_RELEASE_CONTAINMENT` | Prohibited without authority |
| `SUPPORT_ACTION_RELEASE_QUARANTINE` | Prohibited without authority |
| `SUPPORT_ACTION_DELETE_ARCHIVE` | Prohibited |
| `SUPPORT_ACTION_OVERRIDE_LEGAL_HOLD` | Prohibited |
| `SUPPORT_ACTION_SEND_AI_REPLY_UNREVIEWED` | Prohibited |
| `SUPPORT_ACTION_SUPPRESS_ALERT` | Prohibited without review |

Prohibited actions must not appear as ordinary support buttons.

---

## 26. Support Surface Change Control

Support/admin visible message changes must record:

| Field | Meaning |
|---|---|
| `change_id` | Stable change id |
| `message_id` | Message changed |
| `surface` | Surface affected |
| `audience` | Audience affected |
| `old_visibility` | Previous visibility |
| `new_visibility` | New visibility |
| `old_allowed_actions` | Previous allowed actions |
| `new_allowed_actions` | New allowed actions |
| `reason` | Reason |
| `risk_class` | Risk class |
| `review_owner` | Reviewer |
| `review_status` | Review status |
| `audit_required` | Audit requirement |
| `rollback_mapping` | Rollback path |

Authority-affecting changes require security review.

---

## 27. File Layout Candidate

If future implementation chooses files, candidate paths may be:

| Path Candidate | Purpose |
|---|---|
| `catalogs/support_admin/message_boundaries.*` | Support/admin message boundary registry |
| `catalogs/support_admin/visibility_levels.*` | Visibility levels |
| `catalogs/support_admin/allowed_actions.*` | Allowed actions |
| `catalogs/support_admin/prohibited_actions.*` | Prohibited actions |
| `i18n/registry/support_admin_message_keys.*` | Support/admin message key registry |
| `docs/support_admin/message_boundary_review.md` | Review packet |

This is a layout candidate only.

No files are authorized.

---

## 28. Database Layout Candidate

If future implementation chooses database-backed support message mapping, candidate table families may be:

| Table Family Candidate | Purpose |
|---|---|
| `support_admin_message_boundaries` | Message boundary records |
| `support_admin_visibility_levels` | Visibility catalog |
| `support_admin_action_rules` | Allowed/prohibited actions |
| `support_admin_message_reviews` | Review records |
| `support_admin_message_change_log` | Change history |

This is a data-model candidate only.

No tables are authorized.

---

## 29. Readiness Blockers

| Blocker ID | Meaning |
|---|---|
| `BLOCKER-SUPPORT-ADMIN-MESSAGE-0001` | Support/admin message policy not reviewed |
| `BLOCKER-SUPPORT-ADMIN-SURFACE-0001` | Support surface definition missing |
| `BLOCKER-SUPPORT-ADMIN-AUDIENCE-0001` | Audience catalog missing |
| `BLOCKER-SUPPORT-ADMIN-CLASS-0001` | Message class catalog missing |
| `BLOCKER-SUPPORT-ADMIN-SCHEMA-0001` | Message record schema missing |
| `BLOCKER-SUPPORT-ADMIN-VISIBILITY-0001` | Visibility level catalog missing |
| `BLOCKER-SUPPORT-ADMIN-PAYMENT-0001` | Payment support rule missing |
| `BLOCKER-SUPPORT-ADMIN-IDENTITY-0001` | Identity/privacy support rule missing |
| `BLOCKER-SUPPORT-ADMIN-AI-0001` | AI draft boundary missing |
| `BLOCKER-SUPPORT-ADMIN-PGVECTOR-0001` | pgvector boundary missing |
| `BLOCKER-SUPPORT-ADMIN-ARCHIVE-0001` | Archive evidence rule missing |
| `BLOCKER-SUPPORT-ADMIN-ACTION-0001` | Allowed/prohibited action catalogs missing |
| `BLOCKER-SUPPORT-ADMIN-CODING-0001` | Coding not authorized |

Open blockers prevent support/admin message implementation.

---

## 30. Validation Checklist

Validation must confirm:

- support/admin surface definition exists
- support visibility layer catalog exists
- support audience catalog exists
- support message class catalog exists
- support message record schema exists
- support message status catalog exists
- visibility level catalog exists
- order support mapping rule exists
- POS support mapping rule exists
- payment support mapping rule exists
- KDS support mapping rule exists
- provider support mapping rule exists
- customer recovery support rule exists
- value/membership support rule exists
- identity/privacy support rule exists
- AI draft support rule exists
- pgvector context rule exists
- archive evidence rule exists
- customer reply draft boundary exists
- allowed support actions catalog exists
- prohibited support actions catalog exists
- change control exists
- layout candidates are non-authorizing
- coding remains deferred

---

## 31. Relationship To Previous Documents

This document follows:

- `09760 Catch Menu Status Surface And Order Handoff Message Mapping Policy`

It references:

- `09631 Bulkhead Domain Map Source Of Truth And Trust Boundary Catalog`
- `09634 Security Control Records And Security Class Catalog`
- `09639 AI Daemon Monitoring Boundary Contract And Rule-Based Filter Catalog`
- `09640 pgvector Approved Source Traceability Lifecycle And Authority Boundary Catalog`
- `09642 Legal Hold Deletion Anonymization And Retention Review Catalog`
- `09670 Catch Menu Customer Surface Projection And i18n Naming Policy`
- `09740 i18n Message Key Registry And Customer Visible Text Review Policy`
- `09750 Catch & Order Status Message Catalog And Customer Safe State Mapping Policy`
- `09760 Catch Menu Status Surface And Order Handoff Message Mapping Policy`
- `09560` through `09760`

It prepares later planning for:

- support/admin review surface catalog
- customer recovery support message catalog
- support/admin authority control handoff
- support/admin i18n key registry
- future support/admin implementation handoff

This document is support/admin visible message boundary planning only.

It does not authorize coding.

---

## 32. Final Rule

Support/admin visibility is not authority.

Support/admin surfaces may show richer internal context than customer surfaces, but they must preserve masking, role scope, evidence linkage, audit, provider evidence status, AI/pgvector non-authority, archive/legal boundaries, and domain-specific approval rules.

Support/admin messages may summarize, classify, recommend, route, and prepare customer replies.

They must not directly mutate ledger, payment, wallet, coupon, point, membership, identity, provider truth, containment, quarantine, archive, legal hold, or customer-facing outcome without controlled authority.

No support/admin message boundary implementation may proceed until a separate narrow handoff grants `CODING_ALLOWED`, declares target files or data structures, maps boundary tests, resolves blockers, and defines rollback.
