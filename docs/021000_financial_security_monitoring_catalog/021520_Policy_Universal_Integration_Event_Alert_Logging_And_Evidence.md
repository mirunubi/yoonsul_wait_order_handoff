# 021520_Policy_Universal_Integration_Event_Alert_Logging_And_Evidence

## 1. Purpose

This document generalizes the alert, logging, evidence, and automatic warning policy beyond financial events.

The previous policy focused on financial, POS, settlement, provider callback, and reconciliation-risk events.

However, the same architectural pattern must apply to all system integrations.

This includes membership, loyalty, coupons, wallet, customer identity linking, external ordering, delivery, menu projection, inventory, KDS, POS, support, AI, partner modules, franchise systems, workforce systems, and future Franchise OS integrations.

The purpose is to ensure that every cross-system integration event is:

- structured
- logged
- classified
- correlated
- auditable where required
- alertable where risk exists
- evidence-linked where operationally meaningful
- i18n/message-key based where visible
- reviewed through controlled authority
- never silently overwritten

This document does not authorize coding.

Coding remains deferred unless a specific package has `CODING_ALLOWED`, a completed handoff record, a narrow work order, required tests, and review approval.

---

## 2. Scope

This policy applies to integration events across all runtime domains, including:

1. Membership integration
2. Loyalty point integration
3. Coupon and promotion integration
4. Wallet or prepaid card integration
5. Customer identity linking
6. Waiting/order handoff
7. POS integration
8. Payment integration
9. KDS integration
10. External menu projection
11. Delivery platform integration
12. Redtable-type partner integration
13. Google Maps/NFC/QR projection
14. Inventory and sold-out integration
15. Supplier/SCM/WMS integration
16. Support/admin integration
17. AI support gateway integration
18. Content registry/i18n integration
19. Franchise OS integration
20. Workforce/HR integration
21. Audit/evidence integration
22. External provider callback integration

Financial events are one subset of this policy.

They are not the whole policy.

---

## 3. Core Principle

Any system boundary can fail.

Any integration can create drift.

The architecture must assume that cross-system events may be:

- delayed
- duplicated
- missing
- stale
- partially applied
- applied to the wrong identity
- applied to the wrong store
- mapped to the wrong tenant
- translated incorrectly
- projected incorrectly
- accepted by one system but rejected by another
- visible to the wrong audience
- treated as final when only provisional
- silently overwritten by retry logic

Therefore, all integration events must be treated as structured operational signals, not casual logs.

---

## 4. Universal Integration Boundary Rule

Every integration boundary must define:

| Boundary Field | Required Meaning |
|---|---|
| Source system | Where the event originated |
| Target system | Where the event is consumed |
| Domain | Membership, payment, KDS, inventory, support, etc. |
| Authority | Read, propose, request, execute, approve, reconcile |
| Identity scope | Customer, staff, store, tenant, partner, provider |
| Locale/audience | Required if visible |
| Event family | Controlled event type |
| Correlation id | Cross-system linkage |
| Idempotency key | Duplicate prevention |
| Evidence requirement | Required where review is needed |
| Audit requirement | Required where authority is affected |
| Alert threshold | When automatic warning is raised |
| Reconciliation rule | How mismatch is resolved |
| Fallback rule | What happens when integration fails |

Integration without boundary definition is not ready for implementation.

---

## 5. Universal Event Families

All integration packages should classify events into controlled families.

Recommended universal event families:

| Event Family | Meaning |
|---|---|
| `INTEGRATION_EVENT_RECEIVED` | Event received from source |
| `INTEGRATION_EVENT_VALIDATED` | Event passed validation |
| `INTEGRATION_EVENT_REJECTED` | Event rejected |
| `INTEGRATION_EVENT_DUPLICATE` | Duplicate detected |
| `INTEGRATION_EVENT_DELAYED` | Event delayed beyond threshold |
| `INTEGRATION_EVENT_STALE` | Event is stale |
| `INTEGRATION_EVENT_UNMAPPED` | Cannot map to internal identity/context |
| `INTEGRATION_EVENT_PARTIAL_APPLY` | Partially applied |
| `INTEGRATION_EVENT_APPLY_FAILED` | Failed to apply |
| `INTEGRATION_EVENT_REPLAY_REQUIRED` | Replay needed |
| `INTEGRATION_EVENT_RECONCILIATION_REQUIRED` | Mismatch requires reconciliation |
| `INTEGRATION_EVENT_EVIDENCE_REQUIRED` | Evidence required |
| `INTEGRATION_EVENT_ALERT_CREATED` | Alert created |
| `INTEGRATION_EVENT_RESOLVED` | Reviewed and resolved |

These are universal planning families.

Domain-specific catalogs may extend them.

---

## 6. Membership Integration Boundary

Membership integration must be treated as an authority-sensitive system boundary.

Membership events may involve:

- customer identity
- store-specific visit count
- membership grade
- coupon eligibility
- loyalty point balance
- prepaid wallet balance
- subscription/regular pickup benefits
- customer consent
- duplicate account linking
- partner identity mapping
- 자리찜 identity
- tenant white-label identity
- store-specific benefit rules

Membership integration must not be treated as a simple profile update.

Incorrect membership linkage can create financial, customer recovery, legal, privacy, and franchise trust issues.

---

## 7. Membership Event Families

Membership-related integration events should include:

| Event Family | Meaning |
|---|---|
| `MEMBERSHIP_IDENTITY_LINK_REQUESTED` | Identity link requested |
| `MEMBERSHIP_IDENTITY_LINKED` | Identity linked |
| `MEMBERSHIP_IDENTITY_LINK_FAILED` | Identity link failed |
| `MEMBERSHIP_DUPLICATE_IDENTITY_DETECTED` | Possible duplicate account |
| `MEMBERSHIP_VISIT_COUNT_UPDATED` | Visit/order count updated |
| `MEMBERSHIP_VISIT_COUNT_MISMATCH` | Visit/order count mismatch |
| `MEMBERSHIP_GRADE_CHANGED` | Grade changed |
| `MEMBERSHIP_GRADE_MISMATCH` | Grade differs across systems |
| `MEMBERSHIP_POINT_EARNED` | Points earned |
| `MEMBERSHIP_POINT_USED` | Points used |
| `MEMBERSHIP_POINT_MISMATCH` | Point balance mismatch |
| `MEMBERSHIP_COUPON_ISSUED` | Coupon issued |
| `MEMBERSHIP_COUPON_USED` | Coupon used |
| `MEMBERSHIP_COUPON_DUPLICATE_USE_RISK` | Duplicate coupon use detected |
| `MEMBERSHIP_WALLET_BALANCE_MISMATCH` | Wallet/prepaid balance mismatch |
| `MEMBERSHIP_CONSENT_REQUIRED` | Consent missing |
| `MEMBERSHIP_PARTNER_SYNC_DELAYED` | Partner membership sync delayed |
| `MEMBERSHIP_RECONCILIATION_REQUIRED` | Membership mismatch requires review |

These events may require alerts depending on severity.

---

## 8. Membership Alert Families

Membership alert families should include:

| Alert Family | Meaning |
|---|---|
| `ALERT_MEMBERSHIP_IDENTITY_CONFLICT` | Identity conflict detected |
| `ALERT_MEMBERSHIP_DUPLICATE_ACCOUNT` | Duplicate account risk |
| `ALERT_MEMBERSHIP_POINT_MISMATCH` | Point balance mismatch |
| `ALERT_MEMBERSHIP_COUPON_DUPLICATE_USE` | Duplicate coupon use risk |
| `ALERT_MEMBERSHIP_GRADE_MISMATCH` | Grade mismatch across systems |
| `ALERT_MEMBERSHIP_VISIT_COUNT_MISMATCH` | Visit count mismatch |
| `ALERT_MEMBERSHIP_WALLET_BALANCE_MISMATCH` | Wallet/prepaid balance mismatch |
| `ALERT_MEMBERSHIP_CONSENT_MISSING` | Consent required before linking |
| `ALERT_MEMBERSHIP_PARTNER_SYNC_STALE` | External membership sync stale |
| `ALERT_MEMBERSHIP_CROSS_STORE_RULE_CONFLICT` | Store-specific benefit rule conflict |
| `ALERT_MEMBERSHIP_CUSTOMER_RECOVERY_REQUIRED` | Customer-facing recovery may be required |

Membership alerts must not automatically mutate points, coupons, wallet balances, or customer identity without authority.

---

## 9. Coupon And Promotion Integration Boundary

Coupon and promotion systems must be logged and alertable because they affect customer trust and financial value.

Coupon events must distinguish:

- coupon issued
- coupon activated
- coupon reserved
- coupon applied
- coupon rejected
- coupon used
- coupon cancelled
- coupon expired
- duplicate use detected
- benefit rule mismatch
- campaign rule conflict
- partner coupon sync delayed

Coupon use must be idempotent.

Duplicate coupon use must create alert/evidence/reconciliation rather than silent overwrite.

---

## 10. Wallet And Prepaid Balance Boundary

Wallet, prepaid card, stored value, or future 윤슬채움카드-style systems must be treated as financial-adjacent even when not a payment gateway.

Wallet events must distinguish:

- balance created
- balance charged
- balance used
- balance refunded
- balance expired
- balance adjusted
- balance hold placed
- balance hold released
- balance mismatch
- duplicate charge/use
- reconciliation required

Wallet/prepaid balance logs must be append-only or ledger-compatible.

Silent balance UPDATE is prohibited for value-bearing records.

---

## 11. Customer Identity Linking Boundary

Customer identity linking is a high-risk integration boundary.

This applies to:

- 자리찜 customer identity
- tenant/store membership identity
- white-label app identity
- POS customer identity
- partner customer identity
- Redtable-type foreign customer identity
- delivery platform customer identity
- phone/email/social login identity
- temporary QR/NFC session identity

Identity linking must preserve:

- consent
- source system
- link reason
- link confidence
- duplicate risk
- unlink path
- audit
- customer recovery path
- privacy boundary

Identity link failure or conflict must generate alert candidates.

---

## 12. Inventory And Sold-Out Integration Boundary

Inventory and sold-out events must also use the universal alert/logging pattern.

Inventory events may include:

- stock update received
- stock update delayed
- sold-out marked
- sold-out released
- menu availability changed
- POS availability mismatch
- external projection availability mismatch
- KDS order accepted for unavailable item
- supplier delivery mismatch
- waste/disposal event
- manual fallback inventory note

Inventory mismatch can create customer dissatisfaction, waste, refund, and support cases.

Therefore, it must be logged, evidenced, and alertable.

---

## 13. KDS And Order Integration Boundary

KDS and order events must remain correlated.

Alertable mismatches include:

- POS accepted order but KDS ticket missing
- KDS ticket created twice
- KDS completed but payment unresolved
- order cancelled but kitchen ticket active
- remake requested but support case missing
- manual kitchen fallback used without evidence
- ticket stale beyond threshold
- station routing mismatch

KDS alerts remain operational evidence.

They do not automatically approve refunds, compensation, or settlement correction.

---

## 14. Content Registry And i18n Integration Boundary

Content registry and i18n changes can create operational incidents.

Alertable content events include:

- missing message key
- missing content key
- wrong locale projection
- untranslated customer-facing text
- unsupported audience fallback
- stale menu description
- allergen translation missing
- external projection using unapproved content
- AI response using unapproved content
- provider status label missing
- hardcoded operational string detected

Content/i18n alerts must route to content, localization, support, or projection review depending on severity.

---

## 15. External Projection Integration Boundary

External projection events must use the same alert/logging model.

Projection events include:

- menu projected
- projection failed
- projection stale
- rollback required
- price mismatch
- availability mismatch
- allergen mismatch
- translation unapproved
- partner sync delayed
- payment capability displayed without evidence
- customer identity sharing risk

Projection remains projection only.

External partner state must not become source of truth.

---

## 16. Support/Admin Integration Boundary

Support/admin actions must be logged and alertable when authority is affected.

Alertable support/admin events include:

- restricted data view
- unmasking attempt
- unauthorized mutation attempt
- refund request without evidence
- refund execution without approval
- case closure without required evidence
- evidence packet modified
- override authority used
- export requested
- AI draft sent without approval
- provider capability manually changed

Support/admin alerts must preserve audit.

Support convenience must not become backdoor authority.

---

## 17. AI Integration Boundary

AI integration events must be logged and alertable across all domains.

AI-related alertable events include:

- restricted source requested
- untraceable output generated
- customer-facing response without approval
- financial authority attempted
- membership point/coupon mutation attempted
- provider capability invented
- evidence summary treated as original evidence
- masking boundary risk
- wrong-locale content used
- unapproved SOP content used
- external projection text generated without approval

AI remains assistance only.

AI must not resolve, mutate, approve, suppress, reconcile, or publish.

---

## 18. Universal Alert Severity

Universal alert severity should use the same core model across domains.

| Severity | Meaning |
|---|---|
| `INFO` | Log only |
| `NOTICE` | Low-risk abnormal event |
| `WARNING` | Operational risk |
| `HIGH_RISK` | Financial, identity, support, privacy, or trust risk |
| `CRITICAL` | Security, value-bearing, identity, or legal-critical event |
| `REVIEW_REQUIRED` | Human review required |
| `RECONCILIATION_REQUIRED` | Cross-system mismatch requires reconciliation |
| `CUSTOMER_RECOVERY_REQUIRED` | Customer impact likely |
| `PROVIDER_REVIEW_REQUIRED` | External provider issue likely |
| `LEGAL_COMPLIANCE_REVIEW_REQUIRED` | Legal/privacy/compliance review required |

Severity must be mapped by event family.

It must not be ad hoc free text.

---

## 19. Universal Structured Log Fields

All integration logs should use a shared minimum field family.

| Field | Required Meaning |
|---|---|
| Log id | Stable log identifier |
| Event id | Related event |
| Event family | Controlled event family |
| Domain | Membership, payment, KDS, inventory, support, etc. |
| Source system | Origin system |
| Target system | Destination system |
| Tenant/store context | Scoped operational context |
| Actor/system actor | Human, system, provider, AI |
| Customer/staff identity token | Tokenized or scoped reference |
| Correlation id | Cross-system relationship |
| Idempotency key | Duplicate prevention |
| Timestamp observed | Source time |
| Timestamp received | Internal receive time |
| Severity | Controlled severity |
| Alert status | Alert lifecycle state |
| Evidence packet id | Evidence linkage if any |
| Audit event id | Audit linkage if any |
| Resolution status | Open, acknowledged, resolved, etc. |
| Sensitive data class | Visibility/masking class |
| Retention class | Retention policy |

Each domain may extend fields, but should not bypass shared structure.

---

## 20. Universal Alert Lifecycle

Alert lifecycle must remain consistent across domains.

| State | Meaning |
|---|---|
| `ALERT_NOT_REQUIRED` | Log only |
| `ALERT_CANDIDATE_CREATED` | Alert candidate created |
| `ALERT_SUPPRESSED_DUPLICATE` | Duplicate suppressed |
| `ALERT_SENT` | Alert sent |
| `ALERT_DELIVERY_FAILED` | Alert delivery failed |
| `ALERT_ACKNOWLEDGED` | Acknowledged |
| `ALERT_ESCALATED` | Escalated |
| `ALERT_LINKED_TO_CASE` | Linked to support/admin case |
| `ALERT_LINKED_TO_RECONCILIATION` | Linked to reconciliation |
| `ALERT_RESOLVED` | Resolved after review |
| `ALERT_REOPENED` | Reopened |
| `ALERT_REJECTED_FALSE_POSITIVE` | Rejected after review |

Acknowledgement is not resolution.

Resolution must require authority, evidence, or review where applicable.

---

## 21. Universal Evidence Rule

Evidence must be created or linked when an integration event may affect:

- money
- membership value
- coupon value
- wallet/prepaid balance
- customer identity
- privacy/consent
- support case outcome
- refund/compensation
- menu/allergen/customer safety
- KDS/order fulfillment
- external projection accuracy
- provider capability status
- audit accountability

Evidence does not equal approval.

Evidence supports review.

---

## 22. Universal Audit Rule

Audit is required when an integration event involves:

- authority-bearing action
- restricted data access
- identity linking
- membership value change
- coupon/wallet value change
- payment/refund/settlement
- support/admin decision
- provider capability status change
- external projection publication/rollback
- AI output used in customer/support context
- override/backup authority
- export/report action

Audit must capture actor, authority, target, previous state, requested state, result, evidence, reason code, and timestamp.

---

## 23. Universal Reconciliation Rule

Reconciliation is not only financial.

Reconciliation is required whenever two systems disagree on an authority-sensitive fact.

Examples:

| Domain | Reconciliation Example |
|---|---|
| Membership | Point balance differs across app/POS/partner |
| Coupon | Coupon used in one system but active in another |
| Wallet | Stored value differs from ledger |
| Payment | Provider captured but internal ledger missing |
| KDS | POS order accepted but KDS ticket missing |
| Inventory | POS says available but menu projection says sold out |
| Content | Internal menu updated but partner projection stale |
| Identity | Customer linked to wrong membership account |
| Support | Case closed but required evidence missing |
| AI | AI response used without approved source trace |

Reconciliation must be explicit.

Silent overwrite is prohibited.

---

## 24. Universal Idempotency Rule

All integration events that may create state change must define idempotency.

Applies to:

- membership point earn/use
- coupon issue/use
- wallet charge/use/refund
- payment/refund
- KDS ticket creation
- POS order handoff
- external projection publication
- support action request
- provider callback
- inventory sold-out update
- AI-generated support draft attachment

Duplicate events must not create duplicate value, duplicate tickets, duplicate messages, duplicate coupons, or duplicate support actions.

---

## 25. Universal Alert Routing

Alert routing must be domain-specific but policy-controlled.

Recommended routing domains:

| Domain | Primary Route |
|---|---|
| Membership | Membership/support ops |
| Coupon/promotion | CRM/support ops |
| Wallet/prepaid | Finance/support ops |
| Customer identity | Privacy/support/HQ |
| Payment/settlement | Finance/reconciliation |
| KDS/order | Store ops/support |
| Inventory/sold-out | Store ops/inventory |
| Content/i18n | Content/localization |
| External projection | Projection/content ops |
| Provider | Provider ops/security |
| AI | AI governance/support |
| Support/admin | Support lead/audit |
| Security | Security/legal/compliance |

Routing rules must not be scattered across UI code.

They should be controlled by catalog/policy.

---

## 26. Universal Retention And Integrity Rule

Integration logs must define retention and integrity.

Retention must consider:

- domain
- severity
- customer impact
- financial value
- identity/privacy impact
- legal/compliance relevance
- support dispute likelihood
- provider contract requirement
- audit requirement
- evidence requirement

High-risk logs must be append-only or tamper-evident where appropriate.

Corrections must be appended, not silently edited.

---

## 27. Universal i18n Rule

All human-visible alert, log, support, warning, and resolution messages must use i18n/message keys or content registry keys.

This includes:

- membership alert messages
- coupon/wallet warning messages
- identity conflict messages
- KDS/order warning messages
- inventory mismatch messages
- content/i18n warnings
- provider issue messages
- AI governance warnings
- support/admin warnings
- customer recovery messages

Hardcoded operational strings remain prohibited.

---

## 28. Universal Alert Blocker Additions

The blocker inventory must include universal integration blockers.

| Blocker ID Pattern | Family | Meaning |
|---|---|---|
| `BLOCKER-INTEGRATION-0001` | Integration | Event family missing |
| `BLOCKER-INTEGRATION-0002` | Integration | Correlation/idempotency missing |
| `BLOCKER-INTEGRATION-0003` | Integration | Reconciliation rule missing |
| `BLOCKER-ALERT-UNIVERSAL-0001` | Alert | Severity mapping missing |
| `BLOCKER-ALERT-UNIVERSAL-0002` | Alert | Routing policy missing |
| `BLOCKER-LOG-UNIVERSAL-0001` | Logging | Structured log fields missing |
| `BLOCKER-EVIDENCE-UNIVERSAL-0001` | Evidence | Evidence linkage missing |
| `BLOCKER-AUDIT-UNIVERSAL-0001` | Audit | Audit linkage missing |
| `BLOCKER-I18N-ALERT-0001` | i18n | Alert message keys missing |
| `BLOCKER-RECON-UNIVERSAL-0001` | Reconciliation | Cross-system mismatch rule missing |
| `BLOCKER-IDEMPOTENCY-0001` | Idempotency | Duplicate prevention missing |

Open universal integration blockers must prevent runtime integration coding.

---

## 29. Universal Boundary Test Additions

Future tests/checks should verify:

- every integration package has event family
- every state-changing event has idempotency key rule
- every cross-system event has correlation id rule
- every alert-capable event has severity
- every high-risk event has routing rule
- every value-bearing event has evidence rule
- every authority-bearing event has audit rule
- every visible warning has message key
- every reconciliation mismatch creates review path
- acknowledgement does not equal resolution
- AI cannot resolve or suppress alerts
- membership point/coupon/wallet changes cannot silently overwrite
- external provider state cannot become source of truth without evidence
- no package marked coding-ready with integration blocker open

These tests are planning expectations until implementation is approved.

---

## 30. Relationship To Previous Documents

This document generalizes:

- `21510 Financial Event Alert Logging And Automated Warning System Policy`

It also reinforces:

- `22330 API RPC Event Contract Planning Boundary Policy`
- `22340 UI Implementation Package Planning And I18n Surface Mapping Policy`
- `22360 Support Admin Evidence Audit Package Planning Policy`
- `22370 AI Support Gateway pgvector RAG Package Planning Policy`
- `22480 Foundation Catalog Validation Checklist And Review Gate Policy`
- `22490 External POS Third-Party Financial Security Ledger And Settlement Isolation Reinforcement Policy`
- `21500 Financial Security Ledger Foundation Catalog And Status Value Addendum Policy`

This document should inform all future integration packages, not only financial packages.

---

## 31. Final Rule

Automatic warning, structured logging, evidence linkage, audit linkage, reconciliation, idempotency, and alert routing must apply to all critical system integrations.

Financial integration is only one case.

Membership, coupon, wallet, identity, inventory, KDS, POS, content, i18n, external projection, AI, support/admin, provider, and Franchise OS integrations must follow the same controlled event discipline.

Every integration event that may affect value, identity, trust, safety, support outcome, customer experience, provider status, or operational truth must be structured, logged, correlated, reviewable, alertable, and protected from silent overwrite.

Coding remains deferred until universal integration event catalogs, alert families, log fields, routing policies, evidence/audit rules, i18n keys, reconciliation rules, idempotency rules, retention policies, and boundary tests are reviewed and approved.
