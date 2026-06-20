# 010060_Policy_Device_Runtime_Room_Boundary.md

## Purpose

This document defines the Device Runtime Room Boundary Policy.

The previous artifact `10260` defined the Staff Assist Room Boundary Policy.

This document frames the seventh Side B room:

`Device Runtime Room`

The purpose is to define the boundary where store devices, customer-facing devices, staff devices, KDS displays, printer bridge devices, Windows local agents, Android provisioned devices, CMS displays, and admin devices participate in Store Runtime without becoming uncontrolled authority, cross-tenant leakage points, payment truth sources, POS/KDS truth sources, or security infection paths.

This document is planning-only.

It does not authorize coding.

---

## 2. Room Definition

The Device Runtime Room governs device participation in store operations.

It may later coordinate:

- device registration
- Device Profile
- device role
- surface type
- tenant/store binding
- runtime configuration
- config version
- app version
- device health
- device suspension
- device revocation
- emergency disable
- degraded device mode
- replacement workflow
- local cache boundary
- device evidence reference

Device Runtime does not grant authority by itself.

A device is a participant.

A device is not trust.

---

## 3. Core Principle

Device role is not authority.

The correct rule is:

Installed device is not trusted device.  
Registered device is not unrestricted device.  
Device role is not authority.  
Kiosk mode is not payment authority.  
Staff tablet is not refund authority.  
Kitchen display is not KDS truth by itself.  
Printer bridge is not transaction truth.  
Local agent is not central truth.  
Device cache is not source of truth.  
Device possession is not tenant/store authorization.  

Device Runtime must be tenant-bound, store-bound, scoped, revocable, auditable, and safely projected.

---

## 4. Scope

The Device Runtime Room may define planning boundaries for:

- customer QR/NFC session device
- Mini Kiosk device
- Full Kiosk device
- staff tablet
- owner/admin tablet
- kitchen display
- CMS display
- printer/peripheral bridge
- Windows local agent
- Android provisioned device
- support/admin web device
- device profile
- runtime configuration
- device health
- offline/degraded state
- device suspension/revocation
- device replacement
- device evidence packet
- tenant/store isolation

This room does not implement device runtime.

---

## 5. Device Type Catalog

Recommended device type catalog:

| Device Type | Role |
|---|---|
| `CUSTOMER_QR_NFC_SESSION` | Customer phone/browser session |
| `MINI_KIOSK_DEVICE` | Lightweight customer ordering/menu device |
| `FULL_KIOSK_DEVICE` | Expanded Kiosk with richer capabilities if authorized |
| `STAFF_TABLET` | Store staff operation assist |
| `OWNER_ADMIN_TABLET` | Owner/admin review surface |
| `KITCHEN_DISPLAY` | Kitchen ticket/status display |
| `CMS_DISPLAY` | Approved content display |
| `PRINTER_BRIDGE_DEVICE` | Printer/peripheral bridge |
| `WINDOWS_LOCAL_AGENT` | Local bridge/cache/agent candidate |
| `ANDROID_PROVISIONED_DEVICE` | Provisioned Android device |
| `SUPPORT_ADMIN_WEB_DEVICE` | Support/admin browser device |

Device type defines expected participation.

It does not define authority.

---

## 6. Device Profile Boundary

A Device Profile should define:

| Field | Meaning |
|---|---|
| `tenant_id` | Tenant binding |
| `store_id` | Store binding |
| `device_id` | Device identity |
| `device_type` | Device type |
| `device_role` | Operational role |
| `surface_id` | Surface served |
| `allowed_modules` | Allowed module families |
| `config_version` | Runtime configuration version |
| `app_version` | App/runtime version if applicable |
| `provider_profile_reference` | Provider profile reference if applicable |
| `locale_set` | Allowed locales |
| `status` | Device status |
| `revoked` | Revocation flag |
| `emergency_disabled` | Emergency disable flag |
| `last_verified_at` | Last verification time |

Device Profile is required before trusted participation.

---

## 7. Tenant And Store Isolation Boundary

Every device must be tenant/store scoped.

A device assigned to Store A must not operate as Store B.

A device assigned to Tenant A must not operate under Tenant B.

Device profile must fail closed when:

- tenant context is missing
- store context is missing
- device profile is missing
- config version is unknown
- device is revoked
- emergency disable is active
- tenant/store mismatch exists
- surface mismatch exists
- provider profile mismatch exists

Default:

`CROSS_TENANT_ACCESS_DENIED`

Device Runtime must follow `10141`.

---

## 8. Device Registration Boundary

Device registration may later include:

- registration code
- QR enrollment
- admin approval
- store assignment
- device fingerprint if allowed
- device role selection
- surface assignment
- config assignment
- initial status
- audit event
- expiration of registration code

Device registration must not:

- auto-grant high-risk authority
- bypass tenant/store binding
- bypass admin approval where required
- store secrets insecurely
- allow cross-store reuse
- ignore revocation history

Registration is not unrestricted trust.

---

## 9. Device Provisioning Boundary

Provisioning may issue:

- device profile
- runtime configuration
- allowed surface list
- locale set
- feature status
- Kiosk mode instruction
- CMS display profile
- provider references if allowed
- emergency disable capability
- update channel reference
- fallback mode setting

Provisioning must not issue:

- raw provider credentials to client surfaces
- payment secrets
- unrestricted admin authority
- cross-tenant visibility
- global data access
- unreviewed CMS content

Provisioning prepares device operation.

It does not create authority.

---

## 10. Runtime Configuration Boundary

Device runtime configuration may define:

- enabled surfaces
- allowed features
- disabled features
- menu projection mode
- order intent mode
- staff assist mode
- CMS display mode
- payment mode
- POS/KDS mode
- fallback mode
- degraded mode
- locale set
- refresh interval
- emergency disable state
- config expiry
- config version

High-risk features must default disabled unless separately authorized.

Config is not policy override.

---

## 11. Device Health Boundary

Device health may include:

- online/offline state
- app version
- config version
- battery/power status if applicable
- network quality
- last heartbeat
- storage health
- display status
- printer/peripheral connection if applicable
- Kiosk lock status
- error category
- degraded status

Device health is evidence.

Device health is not transaction truth.

---

## 12. Device Status Skeleton

Recommended device states:

| State | Meaning |
|---|---|
| `DEVICE_UNREGISTERED` | Device not registered |
| `DEVICE_REGISTRATION_PENDING` | Registration pending |
| `DEVICE_REGISTERED` | Device registered |
| `DEVICE_PROVISIONED` | Device provisioned |
| `DEVICE_ACTIVE` | Device active |
| `DEVICE_CONFIG_STALE` | Config stale |
| `DEVICE_DEGRADED` | Device degraded |
| `DEVICE_OFFLINE` | Device offline |
| `DEVICE_SUSPENDED` | Device suspended |
| `DEVICE_REVOKED` | Device revoked |
| `DEVICE_REPLACEMENT_REQUIRED` | Replacement required |
| `DEVICE_EMERGENCY_DISABLED` | Emergency disabled |
| `DEVICE_UNKNOWN` | State uncertain |

These states are skeleton states only.

They do not authorize runtime.

---

## 13. Customer Device Boundary

Customer device participation may include:

- QR/NFC entry
- session continuation
- menu view
- order intent
- locale selection
- staff assist request
- safe status projection

Customer device must not:

- store secrets
- access raw internal state
- confirm payment without verified projection
- access another tenant/store
- bypass session/policy rules
- become trusted admin surface

Customer device is a low-trust surface.

---

## 14. Mini Kiosk Device Boundary

Mini Kiosk may later support:

- menu display
- order intent
- staff assist
- CMS notice slot
- locale selection
- safe degraded messages
- device health reporting
- runtime config refresh

Mini Kiosk must not by default:

- confirm payment
- execute refund
- call POS directly
- call KDS directly
- publish CMS
- expose admin data
- access cross-store data
- act without Device Profile

Mini Kiosk is device-shaped customer surface, not authority.

---

## 15. Full Kiosk Device Boundary

Full Kiosk may later support richer capabilities if separately authorized:

- expanded menu/order flow
- CMS home screen
- payment request surface
- POS handoff request route
- KDS visibility route
- staff assist route
- device health
- degraded operation

Full Kiosk must not automatically gain:

- payment truth
- refund authority
- POS/KDS direct authority
- wallet/prepaid authority
- compensation authority
- provider credential access
- unrestricted admin access

Full Kiosk expansion requires explicit capability gates.

---

## 16. Staff Tablet Boundary

Staff Tablet may later support:

- staff assist queue
- order/kitchen context
- manual confirmation
- fallback capture
- incident note
- recovery route initiation
- device health view
- store status

Staff Tablet must not:

- approve refund by default
- approve compensation by default
- access other stores without authority
- expose payment payloads
- bypass validation/POS/KDS evidence
- suppress audit
- silently overwrite system state

Staff Tablet is operational support, not unrestricted command center.

---

## 17. Kitchen Display Boundary

Kitchen Display may later support:

- KDS ticket visibility
- station routing
- preparation status
- delay marker
- remake marker
- kitchen note
- manual fallback marker

Kitchen Display must not:

- confirm payment
- confirm settlement
- approve compensation
- access non-kitchen data unnecessarily
- expose customer personal data unnecessarily
- display another store’s tickets
- replace physical kitchen judgment

Kitchen display is operational visibility.

---

## 18. CMS Display Boundary

CMS Display may later show:

- approved notice
- campaign content
- emergency message
- degraded operation notice
- store policy notice
- locale-specific message

CMS Display must not:

- show draft content
- show unapproved content
- show wrong tenant/store content
- show raw incident detail
- promise refund/compensation without authority
- expose provider blame without review

CMS target scope must be enforced.

---

## 19. Printer Bridge Device Boundary

Printer Bridge Device may later coordinate:

- kitchen printer
- receipt printer
- label printer
- fallback print
- device/printer health
- print evidence

Printer Bridge must not:

- treat print success as POS acceptance
- treat receipt print as payment confirmation unless verified
- print another store’s order
- expose secrets
- bypass tenant/store config
- create duplicate tickets without idempotency

Printer success is evidence, not truth.

---

## 20. Windows Local Agent Boundary

Windows Local Agent may later support:

- POS bridge
- KDS bridge
- printer bridge
- local cache
- health watchdog
- provider plugin candidate
- degraded operation support
- offline evidence capture

Windows Local Agent must not:

- become unrestricted central authority
- overwrite central truth silently
- store secrets without approved controls
- access cross-tenant data
- bypass provider evidence
- bypass financial verification
- release containment

Local agent is a controlled participant.

It is not central truth.

---

## 21. Android Provisioned Device Boundary

Android provisioned device may later support:

- common APK/AAB
- QR/code registration
- Device Profile
- Runtime Config
- Kiosk mode
- remote disable
- config refresh
- offline cached config if approved
- safe projection

Android installation is not feature assembly.

Android provisioning is feature assembly.

Android runtime remains deferred until authorized.

---

## 22. Device Suspension And Revocation Boundary

Device suspension/revocation may be required when:

- device lost
- device stolen
- device compromised
- tenant/store mismatch
- config stale beyond limit
- suspicious activity
- cross-tenant anomaly
- emergency disable
- device replacement
- staff misuse
- provider/security incident

Suspension/revocation must preserve evidence.

Revoked device must fail closed.

Revocation is not incident resolution.

---

## 23. Device Replacement Boundary

Device replacement should preserve:

- tenant/store binding
- old device evidence
- revocation record
- new device profile
- config version
- role assignment
- audit trail
- operator approval if required

Replacement must not clone authority blindly.

Replacement must not transfer secrets insecurely.

---

## 24. Offline And Cached Config Boundary

Offline/cached config may support survival mode.

Cached config must include:

- tenant/store scope
- config version
- expiry
- allowed actions
- prohibited actions
- fallback mode
- degraded state
- safe messages
- reconciliation requirement

Cached config must not allow:

- payment confirmation
- refund/compensation execution
- cross-store operation
- stale unlimited operation
- secret exposure
- silent mutation

Offline mode is constrained survival, not normal mode.

---

## 25. Device Evidence Boundary

Device evidence may include:

- tenant id
- store id
- device id
- device type
- device role
- surface id
- config version
- app version
- device status
- heartbeat timestamp
- error category
- degraded marker
- suspension/revocation marker
- fallback marker
- actor/admin reference if changed
- audit reference

Device evidence supports review.

Device evidence is not transaction truth.

---

## 26. Device Safe Projection Boundary

Device safe projection may show:

- device ready
- device unavailable
- device needs staff assistance
- device is updating
- service temporarily unavailable
- kiosk temporarily unavailable
- please ask staff
- configuration is being refreshed

Device safe projection must not show:

- secrets
- raw internal errors
- provider credentials
- cross-tenant data
- payment truth
- POS/KDS raw state
- security containment details
- AI reasoning
- vector similarity

Safe Projection protects users and operators.

---

## 27. Relationship To Order Intake Room

Device Runtime supports Order Intake by providing:

- surface identity
- device identity
- tenant/store context
- config version
- allowed intake mode
- locale set
- degraded/fallback state

Order Intake must not trust device input without context validation.

---

## 28. Relationship To Staff Assist Room

Device Runtime may trigger Staff Assist when:

- device unavailable
- config stale
- customer cannot proceed
- kiosk locked/unusable
- payment/POS/KDS mode unavailable
- device suspended
- printer/peripheral issue detected
- manual fallback needed

Staff Assist must not override device revocation.

---

## 29. Relationship To POS/KDS/Kitchen Rooms

Device Runtime supports POS/KDS/Kitchen rooms through:

- device health
- local bridge status
- display status
- printer/peripheral status
- KDS display status
- local agent status
- degraded/fallback indicators

Device status must not become POS/KDS/Kitchen truth.

It supports evidence and routing.

---

## 30. Relationship To Financial Trust

Device Runtime must defer financial truth to Side C.

Device Runtime must not:

- confirm payment
- confirm settlement
- execute refund
- issue coupon
- adjust points
- mutate wallet
- approve compensation

Payment-capable device still requires financial boundary.

---

## 31. Relationship To Data Governance

Device Runtime uses Side D for:

- i18n device messages
- CMS display content
- safe projection messages
- support/admin visibility
- incident learning
- AI summary if later authorized
- vector context if later authorized
- analytics/read model if later authorized

Data Governance controls messages and visibility.

It does not grant device authority.

---

## 32. Device Anti-Patterns

Avoid:

- installed device treated as trusted
- device role treated as authority
- kiosk mode treated as payment authority
- staff tablet treated as refund authority
- local agent treated as central truth
- cached config treated as permanent config
- revoked device still operating
- device reused across stores without re-provisioning
- device cache leaking another store’s data
- printer bridge creating duplicate tickets
- device logs exposing secrets
- CMS display showing wrong store content
- support/admin device accessing all tenants by default
- AI/vector context running from device without governance

These anti-patterns must be blocked in future runtime design.

---

## 33. Runtime Deferral

This document defines the Device Runtime Room boundary only.

It does not authorize:

- device registration implementation
- provisioning API
- Android app implementation
- Windows agent implementation
- Kiosk runtime
- staff tablet runtime
- device health service
- remote revoke implementation
- config service
- printer bridge
- local cache
- database schema
- production deployment

All runtime remains deferred.

---

## 34. Validation Checklist

Validation must confirm:

1. Device Runtime Room definition is clear.
2. Device role is not authority.
3. Device type catalog is defined.
4. Device Profile boundary is defined.
5. Tenant/store isolation is defined.
6. Device registration boundary is defined.
7. Provisioning boundary is defined.
8. Runtime Configuration boundary is defined.
9. Device health boundary is defined.
10. Device status skeleton is defined.
11. Customer device boundary is defined.
12. Mini Kiosk boundary is defined.
13. Full Kiosk boundary is defined.
14. Staff Tablet boundary is defined.
15. Kitchen Display boundary is defined.
16. CMS Display boundary is defined.
17. Printer Bridge boundary is defined.
18. Windows Local Agent boundary is defined.
19. Android Provisioned Device boundary is defined.
20. Suspension/revocation boundary is defined.
21. Replacement boundary is defined.
22. Offline/cached config boundary is defined.
23. Device evidence boundary is defined.
24. Device Safe Projection boundary is defined.
25. Relationships to other rooms are defined.
26. Anti-patterns are listed.
27. Coding remains unauthorized.
28. Runtime remains deferred.

---

## 35. Relationship To Previous Documents

This document follows:

- `10260 Staff Assist Room Boundary Policy`

It references:

- `10141 SaaS Tenant Isolation And Cross-Tenant Data Containment Beam Policy`
- `10200 Store Room Framing And Runtime Domain Boundary Index`
- `10110 Store Runtime POS KDS Kitchen Execution Skeleton Policy`
- `10120 Payment Settlement Refund Wallet Financial Trust Skeleton Policy`
- `10130 CMS i18n AI pgvector Data Governance Skeleton Policy`
- `10140 Cross-Axis Authority Evidence Audit And Fallback Beam Policy`
- `10150 Four-Side Skeleton Closure And Runtime Deferral Policy`
- `10041 Windows Installer Option Package And Local Runtime Configuration Policy`
- `10042 Android Device Provisioning Runtime Configuration And Kiosk Mode Policy`

It prepares:

- `10280 Printer Peripheral Room Boundary Policy`
- `10290 Degraded Operation Room Boundary Policy`
- `10300 Manual Fallback Room Boundary Policy`
- future Device Profile static specification packet

This document is room boundary planning only.

It does not authorize coding.

---

## 36. Final Rule

The Device Runtime Room governs device participation, not device authority.

Every device must be tenant-bound, store-bound, role-scoped, config-scoped, revocable, auditable, and safely projected.

Device role is not authority.

Kiosk mode is not payment authority.

Staff tablet is not refund authority.

Kitchen display is not KDS truth by itself.

Printer bridge is not transaction truth.

Local agent is not central truth.

Cached config is not permanent authority.

Device Runtime must preserve tenant/store isolation, security containment, evidence, audit, fallback, reconciliation, i18n, Safe Projection, and financial/provider boundary separation.

Runtime implementation remains deferred until a separate explicit authorization packet is approved.
