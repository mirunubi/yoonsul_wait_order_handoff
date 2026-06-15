# 10044_Policy_Mini_Kiosk_To_Full_Kiosk_CMS_Payment_And_Device_Expansion

## 1. Purpose

This document defines the Mini Kiosk to Full Kiosk CMS, Payment, and Device Expansion Policy.

The previous artifact `10043` defined the Catch Menu, Mini Kiosk, Admin Surface Reuse, and Franchise OS Upgrade Path Policy.

This document narrows the upgrade path from Mini Kiosk to Full Kiosk.

Mini Kiosk begins as a device-based extension of Catch Menu.

Full Kiosk adds higher-risk and higher-value capabilities such as CMS screen control, payment mode, POS handoff, KDS visibility, staff assist, device health, degraded operation, provider profiles, and admin-managed runtime configuration.

The purpose of this document is to ensure that Mini Kiosk can grow into Full Kiosk without becoming an isolated hardware product, without duplicating business logic, and without bypassing the shared SaaS core.

This document is planning-only.

It does not authorize coding.

---

## 2. Core Principle

Mini Kiosk is the safe base.

Full Kiosk is the expanded surface.

The correct rule is:

Mini Kiosk reuses Catch Menu projection.
Full Kiosk extends Mini Kiosk through capability control.
CMS adds controlled content.
Payment adds financial-grade gates.
POS/KDS adds provider evidence boundaries.
Device expansion adds provisioning and runtime control.
Admin Surface manages configuration.
Use Case API decides execution.
Safe Projection decides visibility.

Full Kiosk must not become a separate source of truth.

---

## 3. Mini Kiosk Base Definition

Mini Kiosk may include:

- device identity
- customer-facing menu display
- approved menu projection
- approved item availability display
- approved price display
- approved allergen notice if available
- i18n message key rendering
- customer session start
- cart or order intent capture
- staff assistance request
- safe degraded notice
- basic CMS notice if approved
- Android device provisioning
- runtime configuration
- device revoke handling

Mini Kiosk should remain lightweight.

Mini Kiosk should avoid high-risk financial execution unless explicitly expanded.

---

## 4. Full Kiosk Expansion Definition

Full Kiosk may add:

- CMS screen composition
- kiosk payment mode
- payment verification
- POS handoff
- KDS visibility
- order status tracking
- receipt or printer routing
- staff call workflow
- accessibility mode
- multilingual mode
- campaign display
- provider-specific behavior
- offline/degraded safe mode
- device health monitoring
- remote disable
- admin-managed feature control
- franchise policy inheritance
- store-specific configuration
- tenant-specific plan control

Each expansion must be capability-gated.

Expansion does not automatically grant authority.

---

## 5. Upgrade Layer Model

The upgrade model is:

    Catch Menu Projection
      ↓
    Mini Kiosk Surface
      ↓
    Device Profile
      ↓
    Runtime Configuration
      ↓
    CMS Expansion
      ↓
    Payment Mode Expansion
      ↓
    POS/KDS Provider Expansion
      ↓
    Staff Assist Expansion
      ↓
    Admin Surface Management
      ↓
    Franchise OS Assembly

Each layer must be independently controlled.

Each layer must be removable or disabled without breaking the core.

---

## 6. CMS Expansion Rule

CMS expansion may add customer-facing content surfaces to Full Kiosk.

Allowed CMS content may include:

- home screen banner
- menu promotion panel
- store notice
- campaign notice
- seasonal message
- outage notice
- degraded operation notice
- allergen notice
- payment notice
- wait/order guidance
- franchise policy notice
- emergency announcement

CMS content must be controlled by:

- content status
- approval status
- publication status
- locale status
- effective time
- expiry time
- rollback status
- audience
- surface type
- tenant/store/franchise policy
- legal/security review if required
- audit event

CMS is not free-form text publication.

CMS is controlled operational content.

---

## 7. CMS To Kiosk Projection Rule

Full Kiosk must not render raw CMS content directly.

The safe pattern is:

    CMSContentObject
      ↓
    CMSPublicationReviewAPI
      ↓
    PolicyContext
      ↓
    i18n MessageKey
      ↓
    AuditEvent
      ↓
    KioskCMSProjection
      ↓
    Full Kiosk Surface

Full Kiosk receives approved CMS projection.

It must not render draft, expired, revoked, unreviewed, or policy-blocked content.

---

## 8. Payment Expansion Rule

Payment expansion is high-risk.

Payment mode must be controlled through:

- provider capability
- tenant feature plan
- store runtime configuration
- policy gate
- runtime feature flag
- authority boundary
- evidence requirement
- audit requirement
- idempotency requirement
- reconciliation requirement
- Safe Projection

Full Kiosk may show payment only when all required gates pass.

Payment button visibility is not payment authority.

Payment request is not payment confirmation.

Payment checking is not settlement.

---

## 9. Payment Mode Catalog

Recommended payment modes:

| Payment Mode | Meaning |
|---|---|
| `PAYMENT_DISABLED` | No payment surface |
| `PAYMENT_STAFF_ASSISTED` | Staff-assisted payment only |
| `PAYMENT_EXTERNAL_TERMINAL` | External terminal required |
| `PAYMENT_KIOSK_REQUEST_ONLY` | Kiosk may request payment flow |
| `PAYMENT_KIOSK_VERIFY_ALLOWED` | Kiosk payment verification allowed if server approves |
| `PAYMENT_PROVIDER_DEGRADED` | Provider degraded; fallback required |
| `PAYMENT_REVIEW_REQUIRED` | Payment state requires review |
| `PAYMENT_BLOCKED` | Payment blocked by policy or incident |

Payment mode must be server-issued.

Local Kiosk setting must not override payment policy.

---

## 10. POS Handoff Expansion Rule

Full Kiosk may support POS handoff only through approved Use Case API.

Safe pattern:

    KioskOrderSubmitAPI
      ↓
    OrderObject
      ↓
    PolicyContext
      ↓
    ProviderCapability
      ↓
    POSHandoffObject
      ↓
    AuditEvent
      ↓
    Customer-Safe Order Projection

Full Kiosk must not call POS provider directly.

POS handoff requested is not POS accepted.

POS accepted is not payment confirmed.

Provider callback is not verified internal state.

---

## 11. KDS Visibility Expansion Rule

Full Kiosk may expose KDS-related customer-safe status only when allowed.

Allowed KDS-related customer-safe statuses may include:

- order received
- preparing
- delayed
- staff checking
- ready for pickup if approved
- ask staff
- kitchen status unavailable

Full Kiosk must not expose:

- raw KDS error
- kitchen internal note
- remake internal reason
- staff blame
- provider fault confirmation
- settlement implication
- compensation implication

KDS completed is not settlement truth.

KDS visibility is not financial authority.

---

## 12. Staff Assist Expansion Rule

Full Kiosk should support staff assist for blocked or uncertain flows.

Staff assist may be used for:

- payment uncertainty
- POS handoff failure
- KDS delay
- allergen information unavailable
- item availability uncertainty
- customer confusion
- coupon/point issue
- device error
- offline/degraded mode
- provider outage
- recovery case initiation

Staff assist must create traceable evidence where appropriate.

Staff assist is not automatic compensation approval.

---

## 13. Device Health Expansion Rule

Full Kiosk should report device health.

Device health may include:

- app version
- config version
- device status
- network status
- last sync time
- token status
- provisioning status
- surface mode
- kiosk lock status
- peripheral status if any
- local cache status
- offline mode status
- error category
- emergency disable status

Device health is operational visibility.

Device health must not expose secrets or raw sensitive payloads.

---

## 14. Device Role Expansion Rule

A Mini Kiosk may be upgraded to Full Kiosk by Device Profile update.

Required controls:

- device role change approval
- runtime configuration update
- capability control evaluation
- app version compatibility check
- provider profile check
- payment mode check
- CMS profile check
- offline mode check
- audit event
- rollback path

Device role upgrade must not be local-only.

Device role upgrade must be server-side and auditable.

---

## 15. Android Full Kiosk Expansion Rule

For Android devices, Full Kiosk expansion should use:

- common app package
- server-side provisioning
- Device Profile update
- Runtime Configuration update
- Kiosk Mode lock
- config refresh
- remote disable
- offline cached config if approved
- device revoke
- forced update if needed

Android must not rely on installer-time feature selection.

Android code presence must not activate capability.

---

## 16. Windows Full Kiosk Expansion Rule

For Windows-based kiosk or counter terminals, Full Kiosk expansion may use:

- installer package option
- local agent
- peripheral driver setup
- printer bridge
- POS bridge
- KDS bridge
- local cache
- update agent
- local admin utility

However, installer options must remain preparation only.

Runtime authority remains server-side.

---

## 17. Full Kiosk Admin Configuration Rule

Full Kiosk configuration should be managed through reusable Admin Surfaces.

Admin configuration may include:

- device role
- surface type
- payment mode
- CMS profile
- provider profile
- menu projection mode
- staff assist route
- KDS visibility mode
- POS handoff mode
- degraded mode
- offline cache eligibility
- emergency disable status
- update channel
- locale set

Admin visibility must not imply authority.

Configuration changes require policy and audit.

---

## 18. Store Profile Rule

Full Kiosk behavior should be driven by Store Profile.

Store Profile may define:

- store service type
- dine-in availability
- takeout availability
- table order availability
- kiosk availability
- staff-assisted payment
- self-payment
- KDS use
- POS provider
- payment provider
- CMS content scope
- locale set
- fallback mode
- opening hours
- campaign rules
- franchise policy inheritance

Store Profile must be server-controlled.

Store Profile must not be hardcoded in Kiosk.

---

## 19. Provider Profile Rule

Full Kiosk provider behavior must reference Provider Profile.

Provider Profile may define:

- POS provider capability
- payment provider capability
- KDS provider capability
- CMS provider capability
- messaging provider capability
- callback support
- idempotency support
- retry support
- known limitations
- degraded behavior
- evidence status
- verification status

Provider Profile must be evidence-based.

Provider Profile must not be inferred from provider name alone.

---

## 20. Franchise Policy Inheritance Rule

Full Kiosk must be compatible with future Franchise OS policy inheritance.

Franchise policy may define:

- allowed kiosk modes
- required CMS templates
- allowed payment modes
- prohibited payment modes
- provider assignment rules
- campaign rules
- discount rules
- coupon rules
- recovery route
- support route
- locale requirements
- accessibility requirements
- emergency disable rules
- data retention rules

Full Kiosk must not hardcode store-only policy.

Franchise policy may override or constrain store configuration.

---

## 21. Safe Projection Rule

Full Kiosk must render only safe projections.

Projection categories may include:

| Projection | Purpose |
|---|---|
| `KioskHomeProjection` | Home screen |
| `KioskMenuProjection` | Menu display |
| `KioskCartProjection` | Cart state |
| `KioskOrderProjection` | Order state |
| `KioskPaymentProjection` | Payment status |
| `KioskCMSProjection` | Approved CMS content |
| `KioskAssistProjection` | Staff assist route |
| `KioskDegradedProjection` | Degraded mode state |
| `KioskDeviceStatusProjection` | Device-safe status |
| `KioskLocaleProjection` | Locale text mapping |

Projection must not expose raw internal state.

---

## 22. Kiosk Upgrade Compatibility Rule

Before upgrading Mini Kiosk to Full Kiosk, compatibility must be checked.

Compatibility dimensions:

- app version
- device hardware
- display size
- operating system
- network stability
- provider profile
- payment mode
- POS/KDS availability
- CMS profile
- local cache eligibility
- store policy
- tenant plan
- franchise policy
- staff assist readiness
- support route readiness
- rollback capability

Unknown compatibility must default to review required.

---

## 23. Rollback Rule

Full Kiosk expansion must support rollback.

Rollback examples:

- Full Kiosk to Mini Kiosk
- self-payment to staff-assisted payment
- CMS enabled to CMS fallback only
- POS handoff to staff confirmation
- KDS visibility to staff-managed status
- online mode to degraded mode
- new provider profile to previous profile
- new app version to approved rollback version if possible
- active campaign to previous CMS content

Rollback must be auditable.

Rollback must not delete evidence.

---

## 24. Emergency Disable Rule

Emergency disable must be available for Full Kiosk.

Targets may include:

- entire device
- payment mode
- order submit
- POS handoff
- KDS visibility
- CMS content
- campaign content
- coupon/point/wallet display
- staff assist route
- provider profile
- offline mode
- AI-assisted support reference
- vector context reference

Emergency disable is containment.

Emergency disable is not resolution.

---

## 25. Customer Message Safety Rule

Full Kiosk must not show unsafe customer messages.

Customer messages must not:

- blame provider before verification
- promise refund before approval
- promise coupon before issuance
- confirm payment before verification
- confirm POS acceptance before evidence
- confirm KDS completion as settlement
- expose internal incident state
- expose security state
- expose legal conclusion
- expose AI reasoning
- expose pgvector similarity

Customer-visible messages must use approved i18n keys.

---

## 26. Accessibility And Locale Rule

Full Kiosk should support accessibility and locale control.

Potential controls:

- language selection
- large text mode
- high contrast mode if supported
- simplified flow
- audio guidance if approved
- staff assist prompt
- allergen notice clarity
- payment instruction clarity
- timeout warning
- error recovery guidance

All visible text must use i18n keys or approved CMS projections.

Accessibility does not bypass policy gates.

---

## 27. Full Kiosk Anti-Patterns

Avoid:

- Mini Kiosk rewritten as separate Kiosk product
- Kiosk directly calling payment provider
- Kiosk directly calling POS provider
- Kiosk directly calling KDS provider
- CMS draft displayed on customer screen
- payment button controlled only by local config
- provider name treated as capability evidence
- Kiosk deciding refund eligibility
- Kiosk showing raw internal errors
- Kiosk upgrade granting authority automatically
- device role changed locally without audit
- store policy hardcoded in app
- franchise policy ignored
- rollback not supported
- emergency disable deleting evidence

These anti-patterns create financial, operational, and security risk.

---

## 28. Upgrade Validation Checklist

Before Mini Kiosk is upgraded to Full Kiosk, verify:

1. Device Profile supports Full Kiosk role.
2. Runtime Configuration is current.
3. App version is compatible.
4. Store Profile allows Full Kiosk.
5. Tenant Feature Plan allows Kiosk expansion.
6. Provider Capability Matrix supports required providers.
7. Payment mode is explicitly defined.
8. POS handoff mode is explicitly defined.
9. KDS visibility mode is explicitly defined.
10. CMS profile is approved.
11. i18n keys are available.
12. Customer-safe projections are available.
13. Staff assist route is ready.
14. Emergency disable is ready.
15. Rollback path exists.
16. Audit event mapping exists.
17. Policy Gate allows expansion.
18. Franchise policy does not block expansion.
19. No high-risk feature is activated by code presence alone.
20. Runtime remains deferred unless separately authorized.

---

## 29. Relationship To Previous Documents

This document follows:

- `10043 Catch Menu Mini Kiosk Admin Surface Reuse And Franchise OS Upgrade Path Policy`

It references:

- `09660 Catch & Order SaaS Runtime Boundary And Module Naming Policy`
- `09670 Catch Menu Customer Surface Projection And i18n Naming Policy`
- `09740 i18n Message Key Registry And Customer Visible Text Review Policy`
- `09750 Catch & Order Status Message Catalog And Customer Safe State Mapping Policy`
- `09760 Catch Menu Status Surface And Order Handoff Message Mapping Policy`
- `09770 Support Admin Visible Message Boundary And Review Surface Mapping Policy`
- `09790 Compensation Review Authority Matrix And Value Recovery Control Policy`
- `09930 Provider Evidence Registry Static Package Handoff And Capability Traceability Policy`
- `09940 i18n Message Key Registry Static Package Handoff And Locale Review Policy`
- `09950 Catch Menu Status Catalog Static Package Handoff And Customer Safe Surface Policy`
- `09960 Catch And Order Status Catalog Static Package Handoff And Order Handoff Safe State Policy`
- `09970 Support Admin Boundary Catalog Static Package Handoff And Review Surface Policy`
- `10020 Modular SaaS Core And Future Kiosk Reuse Principle Policy`
- `10030 Domain Object Core Use Case API And Safe Projection Architecture Policy`
- `10040 Domain Capability Control Plane And Runtime Feature Assembly Policy`
- `10041 Windows Installer Option Package And Local Runtime Configuration Policy`
- `10042 Android Device Provisioning Runtime Configuration And Kiosk Mode Policy`
- `10043 Catch Menu Mini Kiosk Admin Surface Reuse And Franchise OS Upgrade Path Policy`

It prepares later planning for:

- `10045 Franchise OS Capability Inheritance And Tenant Store Assembly Policy`
- `10046 Surface Evolution Roadmap And Product Line Continuity Policy`
- Full Kiosk device profile schema
- Full Kiosk CMS projection schema
- Full Kiosk payment mode registry
- Full Kiosk POS/KDS expansion matrix
- Full Kiosk rollout checklist
- Full Kiosk rollback and emergency disable runbook

This document is architecture planning only.

It does not authorize coding.

---

## 30. Final Rule

Mini Kiosk must be designed as the safe upgrade base for Full Kiosk.

Full Kiosk may add CMS, payment, POS handoff, KDS visibility, staff assist, device health, degraded mode, provider profile, store profile, franchise policy, and admin-managed configuration only through controlled capability gates.

The Kiosk must remain a surface.

The server must remain authoritative.

The Use Case API must coordinate execution.

The Safe Projection must control visibility.

CMS must be approved.

Payment must be verified.

POS/KDS must be evidence-bound.

Device role changes must be auditable.

Franchise policy must be compatible.

Rollback and emergency disable must exist.

Runtime implementation remains deferred until separately authorized.
