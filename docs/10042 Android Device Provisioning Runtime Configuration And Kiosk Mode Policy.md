# 10042 Android Device Provisioning Runtime Configuration And Kiosk Mode Policy

## 1. Purpose

This document defines the Android Device Provisioning, Runtime Configuration, and Kiosk Mode Policy.

The previous artifact `10041` defined the Windows Installer Option Package and Local Runtime Configuration Policy.

This document narrows the Android installation and runtime configuration model for Android-based Kiosk devices, staff tablets, owner tablets, store operation tablets, customer-facing Android terminals, and future Mini Kiosk devices.

Android does not follow the Windows-style installer option model.

Android must use a common application package and server-side provisioning.

The Android application may contain multiple surfaces, but actual feature availability must be decided by Device Profile, Runtime Configuration, Domain Capability Control Plane, Use Case API, and Safe Projection.

This document is planning-only.

It does not authorize coding.

---

## 2. Core Principle

Android installation is not feature assembly.

Android provisioning is feature assembly.

The correct rule is:

Common app is installed.
Device is registered.
Device Profile is issued.
Runtime Configuration is downloaded.
Kiosk Mode or surface role is applied.
Use Case API decides execution.
Safe Projection decides visibility.
Remote policy remains authoritative.

An Android app may contain multiple modes.

It must not activate modes merely because the code exists.

---

## 3. Scope

This policy applies to Android-based devices such as:

- customer-facing Kiosk
- Mini Kiosk
- table-side order terminal
- staff tablet
- kitchen tablet if Android-based
- owner tablet
- manager tablet
- mobile store operation device
- QR/NFC support terminal
- Android payment assist device
- Android customer check-in device
- Android local fallback device
- Android CMS display device if used

This document does not define Windows installer behavior.

Windows installation behavior is defined separately in `10041`.

---

## 4. Android Installation Model

Android should use a common APK or AAB package.

The installed app may include code for multiple surfaces such as:

- Kiosk mode
- Mini Kiosk mode
- Staff tablet mode
- Owner review mode
- Store operation mode
- Payment assist mode
- Catch Menu support mode
- Local fallback mode
- CMS display mode
- Diagnostic mode

However, the installed package must not decide active features by itself.

Active feature set must come from server-side provisioning and runtime configuration.

---

## 5. Installation Versus Provisioning

Android installation and provisioning must be separated.

| Stage | Meaning |
|---|---|
| Installation | App package is installed on device |
| Provisioning | Device is registered to tenant/store/role |
| Runtime configuration | Server sends current feature and policy config |
| Kiosk mode lock | Device is locked to approved surface |
| Safe projection | Server sends safe screen data |
| Execution | Use Case API decides whether action is allowed |

The Android app is only a shell until provisioning is complete.

---

## 6. Device Provisioning Flow

Recommended Android provisioning flow:

    App installed
      ↓
    First launch provisioning screen
      ↓
    QR scan or registration code entry
      ↓
    Server validates registration code
      ↓
    Device identity is created or matched
      ↓
    Tenant, store, device role, and surface type are assigned
      ↓
    Device Profile is issued
      ↓
    Runtime Configuration is downloaded
      ↓
    Kiosk Mode or device role lock is applied
      ↓
    Safe Projection APIs become available

Until provisioning succeeds, the device must not show operational screens.

---

## 7. Registration Method Rule

Android device registration may support:

- QR code scan
- one-time registration code
- admin approval flow
- owner/admin pairing
- MDM enrollment if used
- device replacement flow
- support-assisted provisioning
- store bootstrap code
- franchise onboarding code

Registration method must be auditable.

Registration code must expire or be revocable.

A leaked registration code must not grant permanent authority.

---

## 8. Device Profile Rule

Every Android operational device must receive a Device Profile.

Required Device Profile fields may include:

| Field | Meaning |
|---|---|
| `device_id` | Unique device identity |
| `tenant_id` | Tenant identity |
| `store_id` | Store identity |
| `brand_id` | Brand identity if applicable |
| `device_role` | Kiosk, staff tablet, owner tablet, etc. |
| `surface_type` | Active surface mode |
| `provider_profile` | Provider profile |
| `payment_mode` | Payment mode |
| `kds_mode` | KDS mode |
| `cms_profile` | CMS profile |
| `locale_set` | Allowed locales |
| `allowed_modules` | Allowed module families |
| `offline_mode_allowed` | Offline mode eligibility |
| `fallback_mode` | Fallback behavior |
| `config_version` | Runtime config version |
| `device_status` | Active, suspended, revoked, etc. |

Device Profile must be server-issued.

Local modification must not create authority.

---

## 9. Device Role Catalog

Android device roles may include:

| Device Role | Meaning |
|---|---|
| `ANDROID_KIOSK` | Customer-facing kiosk |
| `ANDROID_MINI_KIOSK` | Lightweight customer order/payment terminal |
| `ANDROID_STAFF_TABLET` | Staff operation tablet |
| `ANDROID_OWNER_TABLET` | Owner/admin tablet |
| `ANDROID_MANAGER_TABLET` | Store manager tablet |
| `ANDROID_KITCHEN_TABLET` | Kitchen visibility tablet |
| `ANDROID_PAYMENT_ASSIST` | Staff-assisted payment device |
| `ANDROID_CHECKIN_DEVICE` | Customer check-in or waiting device |
| `ANDROID_CMS_DISPLAY` | CMS display surface |
| `ANDROID_DIAGNOSTIC` | Diagnostic/support mode |
| `ANDROID_FALLBACK_DEVICE` | Approved fallback surface |

Device role must determine surface access.

Device role must not determine business authority by itself.

---

## 10. Surface Type Rule

Surface type defines what the device may render.

Examples:

| Surface Type | Allowed Purpose |
|---|---|
| `KIOSK_ORDER_SURFACE` | Customer order flow |
| `KIOSK_PAYMENT_SURFACE` | Customer payment flow if allowed |
| `MENU_VIEW_SURFACE` | Menu viewing only |
| `STAFF_REVIEW_SURFACE` | Staff operational review |
| `OWNER_REVIEW_SURFACE` | Owner review and limited config |
| `KITCHEN_VISIBILITY_SURFACE` | Kitchen status visibility |
| `PAYMENT_ASSIST_SURFACE` | Staff-assisted payment |
| `CMS_DISPLAY_SURFACE` | Approved CMS content display |
| `DEGRADED_OPERATION_SURFACE` | Safe fallback operation |
| `DIAGNOSTIC_SURFACE` | Support diagnostic information |

Surface type controls rendering.

Use Case API controls action.

---

## 11. Runtime Configuration Rule

Android Runtime Configuration must be server-issued or server-verified.

It may include:

- active surface
- allowed modules
- feature flags
- provider profile
- payment mode
- order mode
- KDS mode
- CMS content profile
- locale set
- customer message policy
- staff assist route
- degraded mode behavior
- offline cache allowance
- config refresh interval
- emergency disable status
- revoke status
- app minimum version
- update requirement
- support contact route

Runtime Configuration must be versioned.

Runtime Configuration must not be treated as permanent authority.

---

## 12. Config Refresh Rule

Android device must periodically refresh configuration.

Refresh may occur:

- at app launch
- at login or session start
- before customer-facing operation
- before payment flow
- before order submission
- after network restore
- after emergency signal
- after app update
- on scheduled interval
- on server push if supported

If config is stale, high-risk features must be disabled.

---

## 13. Offline Cached Config Rule

Android may cache limited configuration for continuity.

Allowed cached data may include:

- Device Profile
- current config version
- approved menu projection snapshot
- approved i18n keys
- approved CMS content snapshot
- safe degraded mode text
- staff assist route
- limited local queue metadata
- last successful sync status

Cached config must include:

- issued time
- expiry time
- source
- config version
- stale status
- offline status
- permitted actions
- prohibited actions

Offline cached config must not authorize high-risk actions.

---

## 14. Offline Mode Rule

Android offline mode may support limited survivability.

Allowed offline behavior may include:

- show approved cached menu projection
- show staff assistance message
- collect order draft candidate if approved
- show degraded operation notice
- preserve local evidence candidate
- queue non-financial event candidate if approved
- display approved CMS fallback notice

Prohibited offline behavior includes:

- payment confirmation
- refund execution
- wallet credit
- coupon mass issue
- provider capability verification
- customer legal/fault confirmation
- AI customer response
- vector retrieval as proof
- POS acceptance confirmation without provider evidence
- central truth overwrite

Offline mode is not authority expansion.

---

## 15. Kiosk Mode Lock Rule

Android Kiosk devices should support controlled Kiosk Mode.

Kiosk Mode may include:

- app pinning or lock task mode
- full-screen operation
- home/back restriction if appropriate
- unauthorized app exit prevention
- restart on crash
- startup into assigned surface
- device role lock
- remote unlock for support
- remote revoke
- emergency exit procedure
- physical admin override procedure if allowed

Kiosk Mode protects surface integrity.

Kiosk Mode does not create business authority.

---

## 16. Android Kiosk Customer Surface Rule

Android Kiosk customer surface may:

- render kiosk-safe menu projection
- render approved CMS content
- collect customer order intent
- submit order request to Use Case API
- show payment checking status
- show staff assistance route
- show degraded operation status
- show approved i18n messages
- show safe fallback messages

Android Kiosk customer surface must not:

- call POS provider directly
- call payment provider directly
- call KDS provider directly
- decide payment truth
- decide POS acceptance truth
- decide KDS completion truth
- decide refund or compensation
- publish unreviewed CMS text
- render raw provider error
- render raw security state
- expose internal object state

The Kiosk renders.

The server decides.

---

## 17. Android Staff Tablet Rule

Android Staff Tablet may:

- view staff-safe order status
- view kitchen visibility if allowed
- assist customer payment if allowed
- receive staff assistance requests
- enter manual review notes if allowed
- trigger support route if allowed
- view degraded operation notice
- access approved store operation screens

Android Staff Tablet must not:

- execute refund without authority
- approve compensation without authority
- bypass payment verification
- override POS/KDS truth
- expose raw payment/provider payloads
- release security containment
- bypass customer message review
- override tenant/franchise policy

Staff visibility is not authority.

---

## 18. Android Owner/Admin Tablet Rule

Android Owner/Admin Tablet may support limited review and configuration.

Allowed functions may include:

- store runtime configuration review
- feature visibility review
- menu/CMS review if allowed
- staff operation overview
- incident visibility
- support escalation
- non-financial configuration
- store status toggles within policy

Prohibited by default:

- direct refund execution
- wallet/prepaid mutation
- provider capability approval
- security containment release
- legal hold/archive mutation
- AI auto-send activation
- raw secret display
- cross-tenant data access
- franchise policy override unless approved

Owner/admin tablet authority must be role-based and server-side.

---

## 19. Android CMS Display Rule

Android CMS display surfaces may show approved content only.

CMS display must check:

- audience
- surface type
- locale
- approval status
- publication status
- effective time
- expiry time
- rollback status
- emergency notice priority
- tenant/store/franchise policy
- i18n key status

CMS display must not show draft or unreviewed content.

CMS publication is operational behavior.

---

## 20. Android Payment Mode Rule

Payment mode must be controlled by configuration and server policy.

Examples:

| Payment Mode | Meaning |
|---|---|
| `PAYMENT_DISABLED` | Payment disabled |
| `PAYMENT_STAFF_ASSISTED` | Staff-assisted payment only |
| `PAYMENT_KIOSK_REQUEST_ONLY` | Kiosk may request payment flow |
| `PAYMENT_KIOSK_VERIFY_ALLOWED` | Kiosk payment verify allowed if server approves |
| `PAYMENT_EXTERNAL_DEVICE` | External terminal required |
| `PAYMENT_PROVIDER_DEGRADED` | Provider degraded; safe fallback required |

Payment mode must not be inferred from app build.

Payment mode must not be changed locally without server approval.

---

## 21. Android Provider Profile Rule

Android Provider Profile may define provider-dependent behavior.

Examples:

- OKPOS order handoff profile
- Smartro payment verification profile
- KDS provider profile
- CMS provider profile
- messaging provider profile
- QR/NFC provider profile
- external tablet display profile

Provider profile must reference provider evidence.

Provider profile must not be trusted merely because selected.

Default provider capability status:

`CAPABILITY_PROVIDER_EVIDENCE_REQUIRED`

---

## 22. Android App Variant Rule

The preferred model is one common app with server-side configuration.

Avoid creating many tenant-specific APKs or hardcoded provider-specific APKs.

Allowed exceptions may include:

- regulatory app store requirement
- hardware vendor constraint
- white-label commercial requirement
- MDM-controlled deployment
- emergency hotfix channel
- restricted pilot

Even when variants exist, runtime authority must remain server-side.

APK variant must not encode final business authority.

---

## 23. App Update Rule

Android app update and feature enablement must be separated.

App update means code changes.

Feature enablement means server configuration changes.

A new app version may include code for a feature that remains disabled.

A feature may be disabled without app update.

Minimum version may be enforced for security or compatibility.

Update metadata may include:

- app version
- build id
- update channel
- minimum supported version
- forced update status
- rollback compatibility
- known limitations
- provider compatibility
- config compatibility

App update must not silently enable high-risk features.

---

## 24. Device Suspension And Revocation Rule

Android device status may include:

| Status | Meaning |
|---|---|
| `DEVICE_PENDING` | Provisioning not complete |
| `DEVICE_ACTIVE` | Device active |
| `DEVICE_SUSPENDED` | Temporarily disabled |
| `DEVICE_REVOKED` | Permanently blocked |
| `DEVICE_LOST` | Reported lost |
| `DEVICE_REPLACED` | Replaced by another device |
| `DEVICE_STALE_CONFIG` | Config stale |
| `DEVICE_OFFLINE_ALLOWED` | Offline allowed within limits |
| `DEVICE_OFFLINE_BLOCKED` | Offline not allowed |
| `DEVICE_RECOVERY_REQUIRED` | Requires support review |

A revoked or lost device must not operate.

A stale device must not execute high-risk features.

---

## 25. Device Replacement Rule

Device replacement must be controlled.

Replacement flow must include:

- old device status update
- old device token revocation
- new device registration
- new Device Profile issuance
- config version assignment
- audit event
- store/tenant confirmation
- support review if needed
- local cache invalidation if possible

Device replacement must not duplicate authority.

Two devices must not unknowingly share the same operational identity.

---

## 26. Token And Secret Rule

Android app must avoid local secret exposure.

Rules:

- no hardcoded provider secret
- no tenant-wide secret in APK
- no payment secret in local plain text
- device token must be revocable
- token must be rotated on replacement
- lost device must be revoked
- sensitive local config must be protected
- raw provider/payment payloads must not be stored unnecessarily
- debug logs must not expose secrets

The APK must not contain production secrets.

---

## 27. Android Local Log And Evidence Rule

Android device must create structured local logs where applicable.

Logs may include:

- provisioning event
- config download event
- config stale event
- device role change event
- kiosk mode start/stop event
- app crash event
- order request event metadata
- payment request event metadata
- staff assist request event
- offline mode entry event
- emergency disable event
- device revoke event
- update event
- diagnostic event

Logs must avoid unnecessary sensitive payloads.

Logs must be uploaded when connectivity permits.

Local logs are evidence candidates.

They are not final approval.

---

## 28. Emergency Disable Rule

Android runtime must support emergency disable.

Emergency disable may target:

- device
- tenant
- store
- surface
- Kiosk payment
- order submit
- POS handoff
- customer message display
- CMS publication display
- coupon issue
- wallet credit
- AI draft
- vector context
- provider profile
- offline mode

Emergency disable must be auditable.

Emergency disable must not delete evidence.

Containment is not resolution.

---

## 29. Safe Failure Rule

If Android device cannot verify config or authority, it must fail safely.

Safe failure examples:

| Failure | Safe Behavior |
|---|---|
| No provisioning | Show provisioning screen only |
| Device revoked | Show service unavailable/admin contact |
| Config expired | Disable high-risk actions |
| Server unreachable | Approved offline/degraded mode only |
| Payment config unavailable | Hide payment or route to staff |
| POS handoff unavailable | Route to staff confirmation |
| CMS content invalid | Hide content or show fallback |
| i18n key missing | Use approved fallback key |
| Provider degraded | Show staff assistance |
| App version too old | Require update or restricted mode |
| Token invalid | Stop operation and require re-provisioning |

Silent unsafe continuation is prohibited.

---

## 30. Android Anti-Patterns

Avoid:

- tenant-specific hardcoded APK as default strategy
- provider logic hardcoded in UI
- local config creating authority
- Kiosk directly calling POS provider
- Kiosk directly calling payment provider
- Kiosk deciding payment status
- Kiosk rendering raw provider error
- app update enabling high-risk feature automatically
- offline mode confirming payment
- local cache treated as truth
- lost device remaining active
- registration code with no expiry
- CMS draft rendered on customer screen
- staff tablet executing refund by visibility alone
- AI auto-send enabled by config flag alone

These anti-patterns create financial, security, and operational risk.

---

## 31. Validation Checklist

Validation must confirm:

1. Android uses common app installation where possible.
2. Installation and provisioning are separated.
3. Device provisioning flow is defined.
4. Registration method is auditable.
5. Device Profile is required.
6. Device Role catalog exists.
7. Surface Type rule exists.
8. Runtime Configuration is server-issued or verified.
9. Config refresh is required.
10. Offline cached config is limited.
11. Offline mode does not create authority.
12. Kiosk Mode lock is controlled.
13. Kiosk customer surface is rendering-only.
14. Staff tablet visibility is not authority.
15. Owner/admin authority is server-side.
16. CMS display shows approved content only.
17. Payment mode is controlled by policy/config.
18. Provider profile references provider evidence.
19. App update and feature enablement are separated.
20. Device revocation is supported.
21. Device replacement is controlled.
22. Tokens and secrets are protected.
23. Local logs are structured.
24. Emergency disable is supported.
25. Safe failure behavior is defined.
26. Runtime remains deferred.

---

## 32. Relationship To Previous Documents

This document follows:

- `10040 Domain Capability Control Plane And Runtime Feature Assembly Policy`
- `10041 Windows Installer Option Package And Local Runtime Configuration Policy`

It references:

- `09520 Universal Integration Event Alert Logging And Evidence Policy`
- `09550 Universal Alert Routing Severity Escalation And Acknowledgement Policy`
- `09560 Financial-Grade Foundation Security Bulkhead Alert Log And pgvector Observability Policy`
- `09660 Catch & Order SaaS Runtime Boundary And Module Naming Policy`
- `09670 Catch Menu Customer Surface Projection And i18n Naming Policy`
- `09730 Provider Evidence Review Packet And Capability Acceptance Matrix Policy`
- `09740 i18n Message Key Registry And Customer Visible Text Review Policy`
- `09750 Catch & Order Status Message Catalog And Customer Safe State Mapping Policy`
- `09760 Catch Menu Status Surface And Order Handoff Message Mapping Policy`
- `09770 Support Admin Visible Message Boundary And Review Surface Mapping Policy`
- `09930 Provider Evidence Registry Static Package Handoff And Capability Traceability Policy`
- `09940 i18n Message Key Registry Static Package Handoff And Locale Review Policy`
- `09950 Catch Menu Status Catalog Static Package Handoff And Customer Safe Surface Policy`
- `09960 Catch And Order Status Catalog Static Package Handoff And Order Handoff Safe State Policy`
- `09970 Support Admin Boundary Catalog Static Package Handoff And Review Surface Policy`
- `10000 Foundation Static Catalog Package Closure And Runtime Entry Deferral Policy`
- `10010 Explicit Static Catalog Coding Authorization Packet Template And Approval Boundary Policy`
- `10020 Modular SaaS Core And Future Kiosk Reuse Principle Policy`
- `10030 Domain Object Core Use Case API And Safe Projection Architecture Policy`

It prepares later planning for:

- Android Device Profile contract
- Android runtime configuration schema
- Android Kiosk surface projection schema
- Android Staff Tablet projection schema
- Android CMS display policy
- Android device revoke and replacement runbook
- Android offline cached config policy
- Android kiosk mode implementation gate
- controlled Android package release policy

This document is architecture planning only.

It does not authorize coding.

---

## 33. Final Rule

Android must not rely on Windows-style installer options for feature assembly.

Android should use a common app package, followed by server-side device provisioning, Device Profile issuance, Runtime Configuration download, Kiosk Mode or surface role lock, Use Case API decision, and Safe Projection output.

The Android app may contain multiple surfaces, but active capability must be controlled by tenant, store, provider, device role, surface type, policy gate, runtime feature flag, authority boundary, evidence requirement, audit requirement, and server-side configuration.

The app renders.

The device is provisioned.

The server governs.

The Use Case API decides.

The Safe Projection informs the surface.

Runtime implementation remains deferred until separately authorized.
