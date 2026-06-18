# 010040_Policy_Domain_Capability_Control_Plane_And_Runtime_Feature_Assembly

## 1. Purpose

This document defines the Domain Capability Control Plane and Runtime Feature Assembly Policy.

The previous artifact `10030` defined the Domain Object Core, Use Case API, and Safe Projection Architecture Policy.

This document defines how feature availability must be controlled across tenant, store, provider, device, service type, operating mode, and runtime condition.

Not every tenant uses every feature.

Not every store uses every module.

Not every provider supports the same capability.

Not every device may expose the same surface.

Not every runtime condition allows the same action.

Therefore, feature availability must not be decided by frontend code, installer choice alone, provider claim alone, or simple feature flag alone.

The system must use a controlled capability plane.

This document is planning-only.

It does not authorize coding.

---

## 2. Core Principle

Feature execution must be decided by multiple control layers.

The correct rule is:

Provider capability defines what is technically supported.
Tenant feature plan defines what is contractually allowed.
Store runtime configuration defines what is operationally enabled.
Policy gate defines what is legally, financially, and operationally permitted.
Runtime feature flag defines temporary operating state.
Authority boundary defines who may request or execute.
Use Case API makes the final decision.
Safe Projection exposes only what the surface may show.

Feature flag alone must not authorize execution.

Installer option alone must not authorize execution.

Provider capability alone must not authorize execution.

Frontend visibility alone must not authorize execution.

---

## 3. Scope

This policy applies to feature control for:

- Catch Menu
- Catch & Order
- Kiosk
- Mini Kiosk
- POS handoff
- payment checking
- payment verification
- KDS bridge
- CMS content
- customer message surface
- i18n surface
- support/admin review
- recovery case review
- compensation request
- coupon, point, wallet, prepaid value
- provider adapter
- AI advisory
- pgvector context retrieval
- franchise policy inheritance
- workforce interface
- store tablet
- owner admin
- HQ admin
- Windows local agent
- Android kiosk app
- future Franchise OS

This policy does not implement any feature.

---

## 4. Control Plane Model

Feature availability must be evaluated through the following layered model:

    Request
      ↓
    Tenant / Store / Device / Surface Context
      ↓
    Provider Capability Matrix
      ↓
    Tenant Feature Plan
      ↓
    Store Runtime Configuration
      ↓
    Policy Gate
      ↓
    Runtime Feature Flag
      ↓
    Authority Boundary
      ↓
    Use Case API
      ↓
    Domain Object Core
      ↓
    Safe Projection
      ↓
    Frontend / Kiosk / CMS / Support Surface

The Use Case API must evaluate the control layers before returning an allowed action or safe projection.

---

## 5. Provider Capability Matrix

Provider Capability Matrix defines what an external provider can actually support.

Examples:

| Capability | Meaning |
|---|---|
| `pos.order_handoff.supported` | POS can receive order handoff |
| `pos.order_cancel.supported` | POS can support order cancellation |
| `payment.verify.supported` | Payment verification is supported |
| `payment.refund.supported` | Refund API exists or is supported |
| `payment.callback.supported` | Payment callback/webhook is supported |
| `payment.idempotency.supported` | Idempotency is supported |
| `menu.sync.supported` | Menu sync is supported |
| `kds.ticket_create.supported` | KDS ticket creation is supported |
| `kds.status_callback.supported` | KDS status callback is supported |
| `cms.publish.supported` | CMS publication integration is supported |
| `messaging.send.supported` | Customer message sending is supported |
| `ai.provider.supported` | AI provider use is supported |
| `vector.embedding.supported` | Embedding provider is supported |

Provider capability must be evidence-based.

Provider claim is not enough.

Default status must be:

`CAPABILITY_PROVIDER_EVIDENCE_REQUIRED`

---

## 6. Tenant Feature Plan

Tenant Feature Plan defines what the tenant is allowed to use by contract, plan, or service tier.

Examples:

| Feature | Meaning |
|---|---|
| `catch_menu.enabled` | Tenant may use Catch Menu |
| `catch_order.enabled` | Tenant may use Catch & Order |
| `kiosk.enabled` | Tenant may use Kiosk |
| `pos_integration.enabled` | Tenant may use POS integration |
| `kds_integration.enabled` | Tenant may use KDS integration |
| `cms.enabled` | Tenant may use CMS |
| `coupon.enabled` | Tenant may use coupon feature |
| `point.enabled` | Tenant may use point feature |
| `wallet.enabled` | Tenant may use wallet/prepaid feature |
| `support_admin.enabled` | Tenant may use support/admin review |
| `ai_support.enabled` | Tenant may use AI support assistance |
| `pgvector_context.enabled` | Tenant may use vector context retrieval |
| `franchise_os.enabled` | Tenant may use Franchise OS layer |

Technical support does not imply tenant entitlement.

---

## 7. Store Runtime Configuration

Store Runtime Configuration defines what is enabled for a specific store.

Examples:

| Configuration | Meaning |
|---|---|
| `store.kiosk.enabled` | Kiosk is active at this store |
| `store.table_qr.enabled` | Table QR/NFC is active |
| `store.order_handoff.enabled` | Order handoff is active |
| `store.kiosk_payment.mode` | Kiosk payment mode |
| `store.kds.mode` | KDS mode |
| `store.cms_surface.enabled` | CMS surface enabled |
| `store.menu_projection.mode` | Menu projection mode |
| `store.staff_assist.enabled` | Staff assist enabled |
| `store.offline_mode.allowed` | Offline mode allowed |
| `store.fallback_mode` | Fallback operation mode |

Store configuration may differ even inside the same tenant.

A franchise tenant may run different store profiles.

---

## 8. Policy Gate

Policy Gate defines whether a feature is permitted under operational, financial, legal, security, or franchise policy.

Examples:

| Policy Gate | Meaning |
|---|---|
| `policy.refund.finance_review_required` | Refund requires finance review |
| `policy.wallet.financial_review_required` | Wallet/prepaid requires financial review |
| `policy.allergen.review_required` | Allergen text requires review |
| `policy.customer_message.review_required` | Customer message requires review |
| `policy.mass_coupon.hq_review_required` | Mass coupon issue requires HQ review |
| `policy.provider_fault.not_auto_confirmed` | Provider fault cannot be auto-confirmed |
| `policy.ai.auto_send.prohibited` | AI auto-send prohibited |
| `policy.vector.not_proof` | Vector similarity not proof |
| `policy.franchise.inheritance_required` | Franchise policy inheritance required |
| `policy.security.bulkhead_required` | Security bulkhead required |

Policy Gate is stronger than feature flag.

If policy blocks execution, runtime flag cannot override it.

---

## 9. Runtime Feature Flag

Runtime Feature Flag controls temporary or gradual operation.

Examples:

| Runtime Flag | Meaning |
|---|---|
| `kiosk.payment.enabled` | Kiosk payment currently enabled |
| `kiosk.order_submit.enabled` | Kiosk order submit enabled |
| `catch_order.pos_handoff.enabled` | Catch & Order POS handoff enabled |
| `catch_menu.menu_projection.enabled` | Catch Menu projection enabled |
| `coupon.issue.enabled` | Coupon issue currently enabled |
| `coupon.redeem.enabled` | Coupon redeem currently enabled |
| `point.earn.enabled` | Point earn currently enabled |
| `point.redeem.enabled` | Point redeem currently enabled |
| `wallet.credit.enabled` | Wallet credit currently enabled |
| `ai.support_draft.enabled` | AI support draft enabled |
| `pgvector.support_context.enabled` | pgvector support context enabled |
| `provider.okpos.order_handoff.enabled` | OKPOS order handoff enabled |
| `provider.smartro.payment_verify.enabled` | Smartro payment verify enabled |

Runtime flags are useful for:

- phased rollout
- incident response
- provider outage
- store-specific disable
- temporary restriction
- emergency shutdown
- A/B or pilot deployment
- operational fallback

Runtime flags must not create authority by themselves.

---

## 10. Authority Boundary

Authority Boundary defines who may request, review, approve, or execute a function.

Examples:

| Action | Authority Boundary |
|---|---|
| Customer order submit | Customer session allowed |
| Kiosk payment request | Customer session plus device context |
| Staff payment assist | Staff role required |
| Coupon issue | Owner/HQ/support policy required |
| Refund request | Support/finance review required |
| Refund execution | Finance authority required |
| Wallet credit | Financial authority required |
| CMS publication | Content approval and policy review required |
| Customer recovery message | Support/admin review required |
| AI draft | Review-only authority |
| Provider capability verification | Provider evidence reviewer required |
| Franchise policy override | HQ/franchise authority required |

Authority must be evaluated server-side.

Frontend must not infer authority.

---

## 11. Final Feature Decision Formula

A feature may be exposed or executed only when the required control layers pass.

Recommended decision formula:

    FeatureAllowed =
      ProviderCapability
      AND TenantFeaturePlan
      AND StoreRuntimeConfiguration
      AND PolicyGate
      AND RuntimeFeatureFlag
      AND AuthorityBoundary
      AND EvidenceRequirement
      AND AuditRequirement

For customer-facing surfaces, add:

    CustomerVisible =
      FeatureAllowed
      AND SafeProjectionAvailable
      AND i18nMessageKeyReady
      AND FallbackMessageReady

If any required condition fails, the feature must be hidden, disabled, routed to staff review, or replaced with a safe fallback state.

---

## 12. Domain-Level Feature Control

Feature control must be domain-aware.

A single global feature table is not enough.

Each domain must define its own capability family.

---

## 13. Menu Domain Capability Examples

Menu domain feature controls may include:

| Feature Key | Meaning |
|---|---|
| `menu.view.enabled` | Menu can be viewed |
| `menu.price_display.enabled` | Price can be displayed |
| `menu.availability_display.enabled` | Availability can be displayed |
| `menu.allergen_display.enabled` | Allergen can be displayed |
| `menu.soldout_sync.enabled` | Sold-out sync enabled |
| `menu.external_projection.enabled` | External menu projection enabled |
| `menu.cms_banner.enabled` | Menu CMS banner enabled |
| `menu.locale_projection.enabled` | Locale projection enabled |

Menu display must not bypass i18n, price, allergen, availability, or policy gates.

---

## 14. Order Domain Capability Examples

Order domain feature controls may include:

| Feature Key | Meaning |
|---|---|
| `order.draft.enabled` | Draft order allowed |
| `order.submit.enabled` | Order submit allowed |
| `order.pos_handoff.enabled` | POS handoff allowed |
| `order.duplicate_guard.enabled` | Duplicate guard enabled |
| `order.staff_review.enabled` | Staff review route enabled |
| `order.customer_status.enabled` | Customer-safe status enabled |
| `order.cancel_request.enabled` | Cancel request allowed |
| `order.degraded_mode.enabled` | Degraded order mode allowed |

Order submitted is not POS accepted.

POS accepted is not payment confirmed.

---

## 15. Payment Domain Capability Examples

Payment domain feature controls may include:

| Feature Key | Meaning |
|---|---|
| `payment.kiosk.enabled` | Kiosk payment allowed |
| `payment.verify.enabled` | Payment verification allowed |
| `payment.callback.enabled` | Payment callback supported |
| `payment.cancel.enabled` | Payment cancellation allowed |
| `payment.refund_request.enabled` | Refund request allowed |
| `payment.refund_execute.enabled` | Refund execution allowed |
| `payment.wallet.enabled` | Wallet/prepaid allowed |
| `payment.staff_assist.enabled` | Staff-assisted payment allowed |

Payment execution and refund execution must have stronger controls than payment display.

---

## 16. KDS Domain Capability Examples

KDS domain feature controls may include:

| Feature Key | Meaning |
|---|---|
| `kds.ticket_create.enabled` | KDS ticket creation allowed |
| `kds.status_view.enabled` | KDS status view allowed |
| `kds.delay_notice.enabled` | Delay notice allowed |
| `kds.remake_request.enabled` | Remake request allowed |
| `kds.staff_note.enabled` | Staff note allowed |
| `kds.degraded_mode.enabled` | Degraded KDS mode allowed |

KDS completed is not settlement truth.

KDS status must not create payment or compensation authority.

---

## 17. Recovery And Compensation Domain Capability Examples

Recovery and compensation feature controls may include:

| Feature Key | Meaning |
|---|---|
| `recovery.case_open.enabled` | Recovery case open allowed |
| `recovery.customer_message.enabled` | Customer message allowed after review |
| `recovery.support_route.enabled` | Support route enabled |
| `compensation.request.enabled` | Compensation request allowed |
| `compensation.review.enabled` | Compensation review allowed |
| `compensation.execute.enabled` | Compensation execution allowed |
| `coupon.issue.enabled` | Coupon issue allowed |
| `point.adjust.enabled` | Point adjustment allowed |
| `wallet.credit.enabled` | Wallet credit allowed |

Recovery is not compensation.

Compensation request is not execution.

Execution requires authority, evidence, idempotency, audit, and reconciliation.

---

## 18. AI And pgvector Domain Capability Examples

AI and pgvector feature controls may include:

| Feature Key | Meaning |
|---|---|
| `ai.support_summary.enabled` | AI support summary enabled |
| `ai.customer_reply_draft.enabled` | AI customer reply draft enabled |
| `ai.incident_summary.enabled` | AI incident summary enabled |
| `ai.evidence_gap_suggestion.enabled` | AI missing evidence suggestion enabled |
| `ai.auto_send.enabled` | AI auto-send |
| `ai.compensation_decision.enabled` | AI compensation decision |
| `pgvector.support_context.enabled` | Vector support context enabled |
| `pgvector.policy_lookup.enabled` | Vector policy lookup enabled |
| `pgvector.case_similarity.enabled` | Case similarity enabled |

The following must remain prohibited unless a separate future policy explicitly changes them:

- `ai.auto_send.enabled`
- `ai.compensation_decision.enabled`
- `ai.provider_fault_confirmation.enabled`
- `ai.security_release.enabled`

AI is not authority.

pgvector is not proof.

---

## 19. CMS Domain Capability Examples

CMS feature controls may include:

| Feature Key | Meaning |
|---|---|
| `cms.banner.enabled` | Banner content enabled |
| `cms.notice.enabled` | Notice content enabled |
| `cms.kiosk_surface.enabled` | Kiosk CMS surface enabled |
| `cms.catch_menu_surface.enabled` | Catch Menu CMS surface enabled |
| `cms.degraded_notice.enabled` | Degraded operation notice enabled |
| `cms.allergen_notice.enabled` | Allergen notice enabled |
| `cms.campaign.enabled` | Campaign content enabled |
| `cms.publish.enabled` | Publication allowed |
| `cms.rollback.enabled` | Rollback allowed |

CMS publication must pass i18n, policy, legal/security review if needed, and audit.

---

## 20. Provider-Specific Feature Profiles

Each provider may have a different feature profile.

Examples:

### 20.1 OKPOS Profile Example

    Provider Capability:
    - POS order handoff: enabled if verified
    - POS cancel: limited or evidence required
    - Payment verification: external provider required
    - KDS status callback: not assumed
    - Menu sync: evidence required

    Tenant Plan:
    - Catch & Order: enabled if contracted
    - Kiosk: enabled if contracted
    - KDS bridge: disabled unless separately verified

    Store Configuration:
    - Kiosk order: enabled
    - Kiosk payment: staff-assisted
    - Table QR: enabled

    Policy Gate:
    - Refund execution: finance review only
    - Coupon issue: owner/HQ review

    Runtime Flag:
    - Order handoff: on
    - Self-service payment: off

Result:

- Kiosk may accept order intent.
- Payment may route to staff assistance.
- KDS status may be simplified.
- Refund and compensation remain review-only.

### 20.2 Smartro Profile Example

    Provider Capability:
    - Payment verification: enabled if verified
    - Payment callback: enabled if verified
    - Cancel/refund: evidence required
    - Idempotency: evidence required

    Tenant Plan:
    - Kiosk payment: enabled if contracted

    Store Configuration:
    - Self-payment: enabled

    Policy Gate:
    - Refund execution: finance review
    - Payment verification: allowed

    Runtime Flag:
    - kiosk.payment.enabled: on

Result:

- Kiosk payment may be exposed if all gates pass.
- Refund remains review-controlled.
- Payment verification does not automatically create refund authority.

---

## 21. Installation-Time Configuration Rule

Some configuration may be selected at installation or onboarding time.

Examples:

- provider selection
- tenant plan
- store operating type
- device role
- initial module set
- POS usage
- KDS usage
- payment mode
- CMS usage
- offline mode eligibility
- fallback mode
- local agent requirement
- printer/peripheral requirement

Installation-time configuration defines the initial assembly.

It must not be treated as permanent truth.

Runtime configuration and policy gate must still control execution.

---

## 22. Runtime Configuration Rule

Runtime configuration controls live operating state.

Examples:

- disable Kiosk payment temporarily
- route payment to staff assist
- disable POS handoff during provider outage
- hide menu category temporarily
- block unreviewed allergen content
- stop coupon issue
- allow coupon redeem only
- stop AI customer reply draft
- disable vector lookup for sensitive case
- put provider integration into degraded mode
- revoke lost device

Runtime configuration is required for SaaS survivability.

Runtime configuration must be auditable.

---

## 23. Windows Installation Model Reference

Windows may support installation-time options.

Examples:

- local agent install
- provider plugin package
- printer driver or peripheral driver
- local DB/cache setup
- admin tool setup
- POS bridge service
- KDS bridge service
- auto-start service
- local firewall rule
- update channel

Windows can use installer options, but installer options must not bypass server policy.

Windows local runtime must still check:

- device identity
- tenant/store context
- provider capability
- tenant feature plan
- store runtime config
- policy gate
- runtime flag
- authority
- audit requirement

A separate Windows installation policy should define this in detail.

---

## 24. Android Installation Model Reference

Android should not rely on installer-time feature selection.

Android should use:

- common APK/AAB
- device registration
- QR or registration code
- Device Profile
- server-side runtime configuration
- kiosk mode lock
- remote disable
- config refresh
- offline cached config
- device revoke

Android installation is not feature assembly.

Android provisioning is feature assembly.

A separate Android provisioning policy should define this in detail.

---

## 25. Device Profile Rule

Every operational device should resolve a Device Profile.

Device Profile may include:

| Field | Meaning |
|---|---|
| `device_id` | Device identity |
| `tenant_id` | Tenant identity |
| `store_id` | Store identity |
| `device_role` | Kiosk, staff tablet, owner admin, etc. |
| `surface_type` | Surface mode |
| `allowed_modules` | Allowed module family |
| `provider_profile` | Provider profile |
| `payment_mode` | Payment mode |
| `kds_mode` | KDS mode |
| `cms_profile` | CMS profile |
| `locale_set` | Locale set |
| `offline_mode_allowed` | Offline mode eligibility |
| `fallback_mode` | Fallback behavior |
| `config_version` | Config version |
| `device_status` | Active, suspended, revoked |

Device Profile is required for Android and recommended for Windows local agents.

---

## 26. Emergency Disable Rule

Emergency disable must be supported.

Examples:

- disable provider integration
- disable Kiosk payment
- disable order submit
- disable customer message send
- disable coupon issue
- disable wallet credit
- disable AI draft
- disable vector lookup
- disable CMS publication
- revoke device

Emergency disable must not delete evidence.

Emergency disable must not close incidents.

Emergency disable must create audit evidence.

Containment is not resolution.

---

## 27. Configuration Versioning Rule

Runtime configuration must be versioned.

Required metadata may include:

- config version
- issued at
- effective at
- issued by
- target tenant
- target store
- target provider
- target device
- target surface
- reason
- related incident id if any
- rollback version
- expiry if temporary
- audit reference

A device or surface must know whether its configuration is current, stale, offline-cached, or revoked.

---

## 28. Safe Projection Rule For Disabled Features

When a feature is unavailable, the surface must receive a safe projection.

Examples:

| Internal Reason | Customer-Safe Projection |
|---|---|
| Provider outage | Staff assistance required |
| Payment callback delay | Payment is being checked |
| POS handoff disabled | Order will be confirmed by staff |
| KDS unavailable | Preparation status will be updated by staff |
| Allergen review missing | Item details unavailable |
| Coupon issue disabled | Coupon currently unavailable |
| Wallet disabled | This payment method is unavailable |
| AI disabled | Support review in progress |
| Device revoked | Service unavailable on this device |

The surface must not show raw internal failure.

---

## 29. Anti-Patterns

Avoid:

- using installer options as permanent authority
- using feature flags as legal/financial authority
- exposing all object APIs to frontend
- allowing Kiosk to judge provider capability
- allowing CMS to publish operational text without review
- allowing Android APK variants to encode tenant logic
- allowing provider claims to enable capabilities without evidence
- allowing local config to override server policy
- allowing staff UI visibility to imply authority
- allowing AI or pgvector feature flags to create decision authority
- mixing refund request and refund execution
- treating POS accepted as payment confirmed

These anti-patterns create operational and security risk.

---

## 30. Validation Checklist

Validation must confirm:

1. Provider Capability Matrix exists.
2. Tenant Feature Plan is separate from provider capability.
3. Store Runtime Configuration is separate from tenant plan.
4. Policy Gate is stronger than runtime flag.
5. Runtime Feature Flag does not create authority.
6. Authority Boundary is server-side.
7. Use Case API makes final decision.
8. Safe Projection controls frontend visibility.
9. Menu, order, payment, KDS, recovery, compensation, AI, pgvector, and CMS domains have separate capability families.
10. Provider-specific profiles are supported.
11. Installation-time configuration is not permanent authority.
12. Runtime configuration is auditable.
13. Windows and Android installation models are separated.
14. Device Profile rule exists.
15. Emergency disable rule exists.
16. Configuration versioning rule exists.
17. Disabled features return safe projections.
18. Runtime remains deferred.

---

## 31. Relationship To Previous Documents

This document follows:

- `10020 Modular SaaS Core And Future Kiosk Reuse Principle Policy`
- `10030 Domain Object Core Use Case API And Safe Projection Architecture Policy`

It references:

- `09520 Universal Integration Event Alert Logging And Evidence Policy`
- `09530 Universal Integration Event Catalog And Alert Family Index Policy`
- `09550 Universal Alert Routing Severity Escalation And Acknowledgement Policy`
- `09560 Financial-Grade Foundation Security Bulkhead Alert Log And pgvector Observability Policy`
- `09660 Catch & Order SaaS Runtime Boundary And Module Naming Policy`
- `09670 Catch Menu Customer Surface Projection And i18n Naming Policy`
- `09730 Provider Evidence Review Packet And Capability Acceptance Matrix Policy`
- `09740 i18n Message Key Registry And Customer Visible Text Review Policy`
- `09750 Catch & Order Status Message Catalog And Customer Safe State Mapping Policy`
- `09760 Catch Menu Status Surface And Order Handoff Message Mapping Policy`
- `09770 Support Admin Visible Message Boundary And Review Surface Mapping Policy`
- `09790 Compensation Review Authority Matrix And Value Recovery Control Policy`
- `09800 Value Recovery Evidence Audit And Idempotency Review Packet Policy`
- `09930 Provider Evidence Registry Static Package Handoff And Capability Traceability Policy`
- `09940 i18n Message Key Registry Static Package Handoff And Locale Review Policy`
- `09950 Catch Menu Status Catalog Static Package Handoff And Customer Safe Surface Policy`
- `09960 Catch And Order Status Catalog Static Package Handoff And Order Handoff Safe State Policy`
- `09970 Support Admin Boundary Catalog Static Package Handoff And Review Surface Policy`
- `09990 AI pgvector Governance Catalog Static Package Handoff And Non Authority Boundary Policy`
- `10000 Foundation Static Catalog Package Closure And Runtime Entry Deferral Policy`
- `10010 Explicit Static Catalog Coding Authorization Packet Template And Approval Boundary Policy`

It prepares later planning for:

- `10041 Windows Installer Option Package And Local Runtime Configuration Policy`
- `10042 Android Device Provisioning Runtime Configuration And Kiosk Mode Policy`
- domain capability registry
- tenant plan schema
- store runtime configuration schema
- feature flag registry
- Device Profile contract
- runtime config audit packet
- future controlled implementation gate

This document is architecture planning only.

It does not authorize coding.

---

## 32. Final Rule

Feature availability must be controlled by a Domain Capability Control Plane.

No feature may be exposed or executed merely because it exists in code, appears in an installer, is claimed by a provider, is enabled by a feature flag, or is visible on a frontend surface.

Execution requires provider capability, tenant feature plan, store runtime configuration, policy gate, runtime feature flag, authority boundary, evidence requirement, audit requirement, Use Case API approval, and Safe Projection output.

Windows may use installer-time options, but server-side runtime policy remains authoritative.

Android must use common app installation followed by device provisioning, Device Profile, and server-side runtime configuration.

The final decision must remain server-side.

The frontend renders.

The Kiosk is a surface.

The CMS is a controlled content layer.

The Use Case API coordinates.

The Domain Object Core owns meaning.

The Control Plane decides availability.

Runtime implementation remains deferred until separately authorized.
