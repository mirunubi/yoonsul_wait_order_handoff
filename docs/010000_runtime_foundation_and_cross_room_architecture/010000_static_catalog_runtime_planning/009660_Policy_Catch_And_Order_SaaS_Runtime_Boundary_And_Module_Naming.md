# 009660_Policy_Catch_And_Order_SaaS_Runtime_Boundary_And_Module_Naming

## 1. Purpose

This document defines the SaaS runtime boundary and module naming policy for:

`Catch & Order / 캐치앤오더`

The previous artifact `09650` defined controlled implementation candidate selection and package prioritization.

This document begins the next planning direction by defining Catch & Order as the SaaS-facing integrated menu, order, handoff, POS/KDS, provider, support, monitoring, and franchise-ready service boundary.

Catch & Order is not the same as Catch Menu.

Catch & Order is the SaaS module.

Catch Menu is the simpler customer-facing menu access surface.

This document defines naming, scope, module boundaries, runtime authority limits, external integration boundaries, security Foundation imports, and future package sequencing.

This document is planning-only.

It does not authorize coding.

---

## 2. Scope

This policy applies to Catch & Order planning for:

1. SaaS tenant boundary
2. Store boundary
3. Customer session boundary
4. Menu-to-order handoff
5. Order-to-POS handoff
6. POS-to-payment state boundary
7. POS-to-KDS handoff
8. KDS fulfillment visibility
9. Provider callback handling
10. Membership, coupon, wallet, and point interaction
11. Customer identity and consent
12. Table/session/order continuity
13. Support/admin correction boundary
14. Customer recovery boundary
15. AI monitoring boundary
16. pgvector review boundary
17. Archive/legal retention boundary
18. i18n/customer-visible message boundary
19. Franchise OS extension boundary
20. Future SaaS pricing and tenant packaging boundary

This document does not create runtime implementation, UI, APIs, schema, provider adapters, POS adapters, KDS adapters, payment flows, or customer-facing screens.

---

## 3. Core Principle

Catch & Order is the integrated SaaS runtime name.

Catch Menu is the customer-friendly menu surface.

The correct naming structure is:

- `Catch Menu / 캐치메뉴`: customer-facing menu access surface
- `Catch & Order / 캐치앤오더`: SaaS-facing integrated order and handoff module
- `Catch Menu & Order Handoff System`: formal architecture, patent-support, or specification name

Catch & Order must be designed as a controlled SaaS module, not as a simple QR menu.

The system must preserve:

- tenant boundary
- store boundary
- customer/session boundary
- POS boundary
- payment boundary
- KDS boundary
- provider evidence boundary
- support/admin authority boundary
- AI/pgvector non-authority boundary
- archive/legal lifecycle boundary

---

## 4. Catalog Header

| Field | Value |
|---|---|
| Document ID | `09660` |
| Package ID | `catch_order.saas_runtime_boundary.v1` |
| Artifact Type | `SAAS_RUNTIME_BOUNDARY_POLICY` |
| Version | `v1` |
| Planning Status | `FOUNDATION_CANDIDATE` |
| Coding Status | `CODING_DEFERRED` |
| Runtime Authority | `BOUNDARY_POLICY_ONLY` |
| Owner | `Architecture / SaaS Platform / Catch & Order` |
| Dependencies | `09560` to `09650` |
| Provider Evidence Status | `CARRY_FORWARD_REQUIRED` |
| i18n Requirement | `REQUIRED_FOR_VISIBLE_SURFACES` |
| Audit Requirement | `REQUIRED_FOR_AUTHORITY_AND_VALUE_EVENTS` |
| Security Requirement | `FINANCIAL_GRADE_SECURITY_FOUNDATION_IMPORTED` |
| Review Requirement | `ARCHITECTURE_SECURITY_SAAS_PRODUCT_REVIEW_REQUIRED` |
| Blocker Status | `CATCH_ORDER_BOUNDARY_REVIEW_REQUIRED` |

---

## 5. Naming Policy

| Name | Korean | Use |
|---|---|---|
| `Catch Menu` | `캐치메뉴` | Simple customer-facing menu access surface |
| `Catch & Order` | `캐치앤오더` | SaaS-facing integrated menu/order/POS/KDS handoff module |
| `Catch Menu & Order Handoff System` | `캐치 메뉴 앤 오더 핸드오프 시스템` | Formal architecture/patent/specification name |
| `Catch & Order Runtime` | `캐치앤오더 런타임` | Internal runtime package name |
| `Catch & Order Admin` | `캐치앤오더 관리자` | Tenant/store/admin management surface |
| `Catch & Order Bridge` | `캐치앤오더 브릿지` | POS/KDS/provider bridge layer |
| `Catch & Order Monitor` | `캐치앤오더 모니터` | Monitoring/review layer |

Do not use `Catch & Menu` as the primary product name.

Reason:

- `Catch Menu` is intuitive.
- `Catch & Order` expresses two linked technical actions.
- `Catch & Menu` sounds less natural and less action-oriented.

---

## 6. Product Boundary Definition

Catch & Order is the SaaS module that connects:

1. Menu access
2. Customer order session
3. Store order intake
4. POS handoff
5. Payment state visibility
6. KDS/kitchen ticket handoff
7. Customer status visibility
8. Store support/admin review
9. Provider callback review
10. Security monitoring
11. Evidence/audit linkage
12. Franchise OS extension

Catch & Order is not merely:

- QR menu
- table order screen
- POS adapter
- KDS adapter
- payment gateway
- customer app
- support dashboard
- AI chatbot
- analytics dashboard

It is a controlled SaaS handoff runtime across these surfaces.

---

## 7. Catch Menu Relationship

Catch Menu is a surface of Catch & Order.

Catch Menu may provide:

- QR/NFC menu access
- customer menu browsing
- i18n menu display
- allergen display
- price display
- availability display
- simple order entry handoff
- customer-safe status messages
- promotional projection
- external menu projection

Catch Menu must not independently become:

- payment authority
- POS authority
- KDS authority
- membership value authority
- coupon/wallet authority
- identity merge authority
- provider capability authority
- AI content authority

Catch Menu is customer-visible.

Catch & Order is the SaaS runtime boundary behind it.

---

## 8. SaaS Tenant Boundary

Catch & Order must support SaaS tenancy from the beginning.

Tenant boundary must separate:

- tenant configuration
- tenant stores
- tenant menus
- tenant order sessions
- tenant provider integrations
- tenant POS configuration
- tenant KDS configuration
- tenant support/admin access
- tenant customer recovery cases
- tenant archives
- tenant monitoring summaries
- tenant vector summaries if later used

Cross-tenant data access is blocked by default.

Any HQ/global analytics must use approved aggregate summaries.

---

## 9. Store Boundary

Within tenant, Catch & Order must preserve store boundary.

Store boundary applies to:

- menu availability
- order acceptance
- POS device/session
- KDS station routing
- staff actions
- customer table/session
- local fallback
- store support cases
- store settlement context
- store incident logs
- store-specific provider configuration

Cross-store propagation is blocked unless explicitly authorized.

Store-level visibility does not automatically grant tenant-wide authority.

---

## 10. Customer Session Boundary

Catch & Order must preserve customer session continuity.

Customer session may include:

- waiting session
- menu browsing session
- cart/order draft
- table participation
- order submission
- payment visibility
- KDS/fulfillment status visibility
- customer recovery case
- membership interaction
- coupon/wallet interaction

Customer session does not automatically equal:

- legal identity
- payment identity
- membership identity
- table owner identity
- support case identity

Identity linking must follow consent and authority rules.

---

## 11. Menu To Order Handoff Boundary

Menu access becomes order intent only when the customer explicitly creates or confirms order content.

Menu view is not order.

Cart is not accepted order.

Submitted order is not POS accepted order.

POS accepted order is not payment confirmed order.

KDS ticket is not payment truth.

Recommended state distinction:

| State | Meaning |
|---|---|
| `MENU_VIEWED` | Customer viewed menu |
| `CART_CREATED` | Customer created cart |
| `ORDER_DRAFTED` | Order draft exists |
| `ORDER_SUBMITTED` | Customer submitted order |
| `ORDER_RECEIVED_BY_CATCH_ORDER` | SaaS received order |
| `ORDER_SENT_TO_POS` | Sent to POS/POS bridge |
| `ORDER_ACCEPTED_BY_POS` | POS accepted order |
| `ORDER_REJECTED_BY_POS` | POS rejected order |
| `KDS_TICKET_CREATED` | Kitchen ticket created |
| `PAYMENT_STATE_OBSERVED` | Payment state observed |
| `CUSTOMER_STATUS_VISIBLE` | Safe status shown to customer |

State names are planning candidates only.

---

## 12. POS Boundary

Catch & Order may hand off order data to POS.

POS boundary rules:

- POS accepted order is not payment confirmation.
- POS cancellation is not provider refund confirmation.
- POS state must be mapped, not blindly trusted.
- POS device/session must be scoped to tenant/store.
- POS event replay must be detected.
- POS duplicate payload mismatch must be reviewed.
- POS offline/local cache state must be marked uncertain.
- POS cannot overwrite ledger without authority.
- POS cannot become customer identity authority.

Relevant Foundation imports:

- `09631` bulkhead map
- `09635` event/alert families
- `09636` POS error codes
- `09637` trigger signal contract
- `09643` boundary tests

---

## 13. Payment Boundary

Catch & Order may observe or route payment state, depending on future approved integration.

Payment boundary rules:

- payment capture/refund requires payment authority
- provider callback requires verification
- duplicate capture risk must be contained
- amount mismatch requires reconciliation
- refund mismatch requires review
- payment state uncertainty must be visible internally
- customer-facing payment messages must be safe and approved
- POS/KDS/support/AI/pgvector must not approve payment action

Catch & Order must not collapse order acceptance and payment confirmation.

---

## 14. KDS Boundary

Catch & Order may create or route kitchen ticket data.

KDS boundary rules:

- KDS executes kitchen work
- KDS is not payment authority
- KDS completion is not settlement truth
- KDS remake/void/manual fallback requires evidence
- KDS duplicate ticket risk must be detected
- KDS order/payment mismatch must be reviewable
- KDS status visible to customer must be safe and i18n-controlled

KDS visibility may improve customer experience, but must not create financial authority.

---

## 15. Provider Boundary

Catch & Order may integrate external providers such as POS vendors, payment providers, menu providers, map/search providers, delivery partners, or table-order partners.

Provider boundary rules:

- provider capability is evidence-required until verified
- callback signature must be verified
- replay detection is required
- idempotency is required for value-bearing events
- provider settlement reports must be reconciled
- provider state must not silently overwrite internal truth
- provider contract drift must create review
- provider sandbox behavior must not be assumed equal to production

Default status:

`CAPABILITY_PROVIDER_EVIDENCE_REQUIRED`

---

## 16. Membership Coupon Wallet Boundary

Catch & Order may interact with membership, coupon, point, wallet, prepaid, or benefit logic.

Value boundary rules:

- membership point adjustment requires value authority
- coupon use requires idempotency
- wallet/prepaid balance change requires value ledger authority
- benefit calculation must be traceable
- duplicate use/charge must be blocked or reviewed
- support/admin cannot directly mutate value without authority
- AI/pgvector cannot adjust value
- customer recovery must preserve evidence

Catch & Order may display value state only from approved source.

---

## 17. Identity Consent Boundary

Catch & Order may need customer identity continuity across:

- waiting
- menu browsing
- order
- table session
- payment visibility
- membership
- coupon/wallet
- support recovery

Identity boundary rules:

- session id is not legal identity
- payment identity is not automatically membership identity
- partner identity is not internal truth
- identity linking requires consent and authority
- duplicate identity candidate enters review
- wrong-account risk blocks linking
- AI/pgvector cannot link identity
- unmasking requires authority and audit

Catch & Order must preserve session continuity without unsafe identity merging.

---

## 18. Support Admin Boundary

Catch & Order admin/support surfaces may handle:

- order issue review
- payment issue review
- KDS mismatch review
- customer recovery case
- provider dispute routing
- manual fallback evidence
- refund request preparation
- correction request routing

Support/admin boundary rules:

- support note is not authority
- refund requires approval/evidence
- compensation requires authority
- case closure requires evidence for high-risk cases
- unmasking requires authority and audit
- support cannot directly mutate ledger/value/identity
- AI draft cannot be sent without review

---

## 19. AI Monitoring Boundary

Catch & Order may later use AI monitoring.

AI boundary rules:

- deterministic rules first
- AI summary is derived only
- AI may identify evidence gaps
- AI may suggest route
- AI may draft internal notes
- AI must not approve, mutate, resolve, release, refund, compensate, publish, or confirm provider capability
- AI-generated customer-facing text requires approval
- AI output must be traceable and auditable in high-risk context

AI is not required for early Catch & Order planning.

---

## 20. pgvector Boundary

Catch & Order may later use pgvector for:

- incident similarity
- SOP retrieval
- provider error pattern retrieval
- support review context
- false-positive pattern analysis
- policy retrieval

pgvector boundary rules:

- approved sources only
- blocked raw sensitive sources
- tenant/store scope preserved
- similarity is not proof
- vector output is not authority
- lifecycle follows source lifecycle
- deletion/anonymization dependency is tracked
- legal hold is respected

pgvector ingestion is deferred.

---

## 21. Archive Legal Boundary

Catch & Order must preserve records relevant to:

- order disputes
- payment disputes
- provider disputes
- customer recovery
- identity/consent issues
- KDS/remake/manual fallback
- support/admin actions
- security incidents
- AI/pgvector outputs if later used

Archive/legal boundary rules:

- archive requires manifest
- archive restore is read-only evidence retrieval
- legal hold blocks deletion
- deletion/anonymization requires dependency review
- exact legal retention periods require legal review
- vector and AI-derived dependencies must be checked

---

## 22. i18n Customer Visible Boundary

Catch & Order and Catch Menu must use i18n keys for visible messages.

Visible surfaces include:

- order status
- payment status
- KDS/fulfillment status
- unavailable item notice
- provider delay notice
- customer recovery notice
- coupon/wallet/membership notice
- error/fallback message
- support reply
- legal/privacy notice
- allergen and price text

Hardcoded operational visible strings are prohibited.

Customer-facing text must be safe, localized, and source-approved.

---

## 23. Catch & Order Module Map

Initial module map:

| Module | Role |
|---|---|
| `catch_order_entry` | Customer order entry boundary |
| `catch_order_session` | Session/table/order continuity |
| `catch_order_menu_projection` | Approved menu projection |
| `catch_order_cart` | Cart/draft handling |
| `catch_order_handoff` | Order handoff to POS |
| `catch_order_pos_bridge` | POS adapter boundary |
| `catch_order_payment_observer` | Payment state observation boundary |
| `catch_order_kds_bridge` | KDS ticket handoff boundary |
| `catch_order_provider_registry` | Provider capability/evidence registry |
| `catch_order_support_review` | Support/admin review surface |
| `catch_order_customer_recovery` | Customer recovery workflow boundary |
| `catch_order_monitoring` | Security monitoring integration |
| `catch_order_i18n` | Visible message key namespace |
| `catch_order_archive` | Evidence/archive reference boundary |

This module map is planning-only.

---

## 24. Catch & Order State Family Candidates

Potential state families:

| State Family | Meaning |
|---|---|
| `SESSION_STATE` | Customer/session continuity |
| `MENU_STATE` | Menu projection and availability |
| `CART_STATE` | Cart/draft order |
| `ORDER_STATE` | Order submission/acceptance |
| `POS_HANDOFF_STATE` | POS handoff status |
| `PAYMENT_OBSERVED_STATE` | Payment observation status |
| `KDS_TICKET_STATE` | Kitchen ticket lifecycle |
| `PROVIDER_SYNC_STATE` | Provider sync/callback status |
| `CUSTOMER_RECOVERY_STATE` | Customer recovery workflow |
| `SUPPORT_REVIEW_STATE` | Support/admin review status |
| `SECURITY_MONITORING_STATE` | Security monitoring state |
| `ARCHIVE_RETENTION_STATE` | Archive/legal lifecycle state |

State families must not collapse authority boundaries.

---

## 25. Catch & Order Event Family Candidates

Potential event families:

| Event Family | Meaning |
|---|---|
| `CATCH_ORDER_SESSION_STARTED` | Customer session started |
| `CATCH_ORDER_MENU_VIEWED` | Menu viewed |
| `CATCH_ORDER_CART_CREATED` | Cart created |
| `CATCH_ORDER_SUBMITTED` | Order submitted |
| `CATCH_ORDER_POS_HANDOFF_REQUESTED` | POS handoff requested |
| `CATCH_ORDER_POS_ACCEPTED` | POS accepted |
| `CATCH_ORDER_POS_REJECTED` | POS rejected |
| `CATCH_ORDER_PAYMENT_STATE_OBSERVED` | Payment state observed |
| `CATCH_ORDER_KDS_TICKET_CREATED` | KDS ticket created |
| `CATCH_ORDER_PROVIDER_CALLBACK_RECEIVED` | Provider callback received |
| `CATCH_ORDER_CUSTOMER_STATUS_SHOWN` | Customer-safe status shown |
| `CATCH_ORDER_SUPPORT_REVIEW_CREATED` | Support review created |
| `CATCH_ORDER_CUSTOMER_RECOVERY_REQUIRED` | Customer recovery required |
| `CATCH_ORDER_SECURITY_SIGNAL_CREATED` | Security signal created |

These are planning candidates and must later map to the Foundation event/alert catalog.

---

## 26. Catch & Order Error Code Candidates

Potential Catch & Order error codes:

| Error Code | Meaning |
|---|---|
| `ERR_CATCH_ORDER_SESSION_SCOPE_MISMATCH` | Session scope mismatch |
| `ERR_CATCH_ORDER_MENU_SOURCE_MISSING` | Approved menu source missing |
| `ERR_CATCH_ORDER_CART_STATE_INVALID` | Cart state invalid |
| `ERR_CATCH_ORDER_ORDER_DUPLICATE_SUBMIT` | Duplicate order submit risk |
| `ERR_CATCH_ORDER_POS_HANDOFF_FAILED` | POS handoff failed |
| `ERR_CATCH_ORDER_POS_ACCEPT_STATE_UNCERTAIN` | POS acceptance state uncertain |
| `ERR_CATCH_ORDER_PAYMENT_STATE_UNCERTAIN` | Payment state uncertain |
| `ERR_CATCH_ORDER_KDS_TICKET_MISMATCH` | KDS ticket mismatch |
| `ERR_CATCH_ORDER_PROVIDER_CAPABILITY_UNVERIFIED` | Provider capability unverified |
| `ERR_CATCH_ORDER_CUSTOMER_VISIBLE_STATUS_UNSAFE` | Customer-visible status unsafe |
| `ERR_CATCH_ORDER_SUPPORT_AUTHORITY_MISSING` | Support authority missing |
| `ERR_CATCH_ORDER_I18N_KEY_MISSING` | Visible message key missing |
| `ERR_CATCH_ORDER_CROSS_TENANT_RISK` | Cross-tenant risk |
| `ERR_CATCH_ORDER_CROSS_STORE_RISK` | Cross-store risk |

These codes must be reviewed against `09636`.

---

## 27. Runtime Authority Prohibition

Catch & Order planning must explicitly prohibit unauthorized authority.

Catch & Order must not directly:

- finalize payment
- approve refund
- post ledger correction
- finalize settlement
- adjust wallet balance
- adjust membership points
- issue/reissue coupon
- link/merge identity
- confirm provider capability
- publish unapproved projection
- release containment
- release quarantine
- delete archive
- override legal hold
- send AI-generated customer text without review

Authority actions must go through domain-specific controlled functions in later packages.

---

## 28. SaaS Packaging Boundary

Catch & Order may later be packaged as SaaS with:

- tenant subscription
- store count tier
- POS/KDS adapter tier
- provider integration tier
- support/admin seat tier
- monitoring/audit tier
- franchise OS integration tier
- customer-facing Catch Menu surface
- optional AI support add-on
- optional analytics add-on
- optional archive/compliance add-on

SaaS packaging must not weaken security boundaries.

A lower-tier tenant must still preserve source-of-truth, evidence, audit, and isolation.

---

## 29. Franchise OS Extension Boundary

Catch & Order may later connect to Franchise OS.

Franchise OS extension may include:

- franchise menu policy
- approved menu projection
- store operating group policy
- HQ support review
- provider capability registry
- multi-store monitoring
- royalty/settlement reporting
- customer recovery policy
- staff/workforce integration
- compliance dashboard
- training/SOP visibility

Franchise OS must not override tenant/store/legal/entity boundaries without authority.

---

## 30. Implementation Sequence Recommendation

Recommended future sequence:

1. Catch & Order boundary docs
2. Catch Menu projection/i18n docs
3. Provider evidence template docs
4. Static catalog registry planning
5. Boundary test matrix artifact
6. Trigger signal packet schema planning
7. Monitoring view contract planning
8. Support/admin review boundary planning
9. POS/KDS provider evidence mapping
10. Non-runtime schema planning
11. Only then narrow implementation handoff

No full runtime before boundaries and tests.

---

## 31. Readiness Blockers

| Blocker ID | Meaning |
|---|---|
| `BLOCKER-CATCH-ORDER-BOUNDARY-0001` | Catch & Order boundary not reviewed |
| `BLOCKER-CATCH-ORDER-NAMING-0001` | Naming policy not confirmed |
| `BLOCKER-CATCH-ORDER-TENANT-0001` | Tenant boundary missing |
| `BLOCKER-CATCH-ORDER-STORE-0001` | Store boundary missing |
| `BLOCKER-CATCH-ORDER-SESSION-0001` | Customer/session boundary missing |
| `BLOCKER-CATCH-ORDER-POS-0001` | POS boundary missing |
| `BLOCKER-CATCH-ORDER-PAYMENT-0001` | Payment boundary missing |
| `BLOCKER-CATCH-ORDER-KDS-0001` | KDS boundary missing |
| `BLOCKER-CATCH-ORDER-PROVIDER-0001` | Provider evidence boundary missing |
| `BLOCKER-CATCH-ORDER-I18N-0001` | i18n visible message boundary missing |
| `BLOCKER-CATCH-ORDER-AI-PGVECTOR-0001` | AI/pgvector boundary missing |
| `BLOCKER-CATCH-ORDER-ARCHIVE-LEGAL-0001` | Archive/legal boundary missing |
| `BLOCKER-CATCH-ORDER-CODING-0001` | Coding not authorized |

Open blockers prevent Catch & Order runtime implementation.

---

## 32. Validation Checklist

Validation must confirm:

- Catch & Order naming is defined
- Catch Menu distinction is preserved
- SaaS tenant boundary exists
- store boundary exists
- customer session boundary exists
- menu-to-order handoff boundary exists
- POS boundary exists
- payment boundary exists
- KDS boundary exists
- provider evidence boundary exists
- membership/coupon/wallet value boundary exists
- identity/consent boundary exists
- support/admin boundary exists
- AI monitoring boundary exists
- pgvector boundary exists
- archive/legal boundary exists
- i18n customer-visible boundary exists
- runtime authority prohibitions are explicit
- future implementation sequence is narrow
- coding remains deferred

---

## 33. Relationship To Previous Documents

This document follows:

- `09650 Controlled Implementation Candidate Selection And Package Prioritization Policy`

It imports the security Foundation reference spine:

- `09560` through `09646`

It prepares later planning for:

- `09670 Catch Menu Customer Surface Projection And i18n Naming Policy`
- `09680 Provider Evidence Collection Template And Capability Review Policy`
- `09690 Security Monitoring Foundation README Insert And Index Patch Policy`
- `09700 Controlled Non-Runtime Catalog Schema Planning Policy`

This document is SaaS runtime boundary planning only.

It does not authorize coding.

---

## 34. Final Rule

Catch & Order is the SaaS-facing integrated menu, order, handoff, POS/KDS, provider, support, monitoring, and franchise-ready module.

Catch Menu is the simpler customer-facing menu access surface.

Catch & Order must preserve tenant, store, session, POS, payment, KDS, provider, value, identity, support/admin, AI, pgvector, archive/legal, and i18n boundaries.

It must not collapse order acceptance, POS acceptance, payment confirmation, KDS execution, provider callback, support review, AI summary, vector similarity, or archive restore into a single authority state.

No Catch & Order runtime implementation may proceed until a separate narrow handoff grants `CODING_ALLOWED`, imports Foundation controls, maps boundary tests, resolves blockers, and declares target files and data scope.
