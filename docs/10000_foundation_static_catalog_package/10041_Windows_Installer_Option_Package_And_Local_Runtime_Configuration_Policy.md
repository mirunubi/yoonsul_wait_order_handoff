# 10041_Windows_Installer_Option_Package_And_Local_Runtime_Configuration_Policy

## 1. Purpose

This document defines the Windows Installer Option Package and Local Runtime Configuration Policy.

The previous artifact `10040` defined the Domain Capability Control Plane and Runtime Feature Assembly Policy.

This document narrows the installation and runtime configuration model for Windows-based store devices, local agents, POS bridge machines, KDS bridge machines, printer/peripheral controllers, and administrator workstations.

Windows may support installation-time options.

However, installer options must not become final runtime authority.

The Windows installation package may prepare local components, but server-side policy, provider capability, tenant feature plan, store runtime configuration, runtime feature flag, authority boundary, and audit requirement must still decide execution.

This document is planning-only.

It does not authorize coding.

---

## 2. Core Principle

Windows installation may assemble local components.

Windows runtime must still obey the central control plane.

The correct rule is:

Installer option prepares capability.
Local runtime loads configuration.
Server policy decides authority.
Use Case API decides execution.
Safe Projection decides visibility.
Audit records action.
Fallback protects operation.

A Windows installer may install modules.

It must not permanently authorize modules.

---

## 3. Scope

This policy applies to Windows-based components such as:

- local store agent
- POS bridge service
- KDS bridge service
- printer bridge
- kitchen display bridge
- local cache service
- offline fallback tool
- provider connector package
- admin utility
- local diagnostic tool
- update agent
- watchdog service
- Windows kiosk shell if used
- staff counter terminal
- back-office workstation
- local network integration machine

This policy does not apply to Android device provisioning, which is defined separately.

---

## 4. Windows Installation Model

Windows installation may support selectable package options.

Examples:

| Installer Option | Purpose |
|---|---|
| `Local Store Agent` | Local runtime coordination |
| `POS Bridge Service` | POS handoff bridge |
| `KDS Bridge Service` | KDS visibility bridge |
| `Printer Bridge` | Receipt/kitchen print bridge |
| `Provider Plugin Pack` | Provider-specific local connector |
| `Local Cache` | Emergency or degraded cache |
| `Admin Utility` | Local diagnostic/admin tool |
| `Watchdog Service` | Local process monitoring |
| `Auto Update Agent` | Controlled update channel |
| `Peripheral Driver Setup` | Printer/scanner/display driver support |
| `Firewall Rule Setup` | Local network permission setup |

These options prepare local capability only.

They do not grant runtime authority.

---

## 5. Installer Option Boundary

Installer options must not decide:

- tenant entitlement
- provider capability verification
- payment authority
- POS acceptance truth
- KDS completion truth
- refund authority
- coupon/point/wallet execution
- customer message publication
- AI runtime authorization
- pgvector runtime authorization
- support/admin mutation authority
- legal hold/archive mutation
- franchise policy override
- production readiness

The installer installs.

It does not govern.

---

## 6. Installation-Time Configuration

Installation-time configuration may collect:

- tenant registration code
- store registration code
- device registration code
- device role candidate
- local network mode
- provider profile candidate
- peripheral profile candidate
- local cache eligibility
- auto-start preference
- update channel candidate
- diagnostic mode candidate
- fallback mode candidate

These values are candidates until verified by the server.

A local value must not override central policy.

---

## 7. Device Registration Rule

Every Windows runtime component must resolve a registered device identity.

Required registration fields may include:

| Field | Meaning |
|---|---|
| `device_id` | Unique device identity |
| `tenant_id` | Tenant identity |
| `store_id` | Store identity |
| `device_role` | Local agent, POS bridge, admin workstation, etc. |
| `machine_fingerprint` | Controlled device fingerprint |
| `installer_version` | Installed package version |
| `component_set` | Installed component list |
| `provider_profile_candidate` | Candidate provider profile |
| `local_network_profile` | Local network profile |
| `config_version` | Current config version |
| `device_status` | Active, suspended, revoked, pending |

Device registration must be auditable.

Unregistered devices must not operate.

---

## 8. Local Runtime Configuration

After installation, the Windows component must load Local Runtime Configuration.

Local Runtime Configuration may include:

- enabled local services
- provider bridge mode
- POS handoff mode
- KDS visibility mode
- printer routing mode
- local cache mode
- offline fallback eligibility
- sync interval
- retry interval
- log upload interval
- diagnostic permission
- update policy
- emergency disable state
- config version
- expiry or refresh deadline

Local Runtime Configuration must be server-issued or server-verified.

---

## 9. Server Authority Rule

The server remains authoritative for:

- tenant plan
- store configuration
- provider capability evidence
- policy gate
- runtime feature flag
- authority boundary
- customer-safe projection
- audit rules
- compensation rules
- AI/pgvector runtime rules
- archive/legal rules
- franchise policy inheritance

The Windows local runtime may cache configuration.

It must not become the source of truth.

---

## 10. Local Agent Role

A Windows Local Store Agent may coordinate local continuity.

It may:

- receive server configuration
- maintain local process status
- monitor POS/KDS bridge health
- queue local events if offline
- upload logs
- provide degraded operation support
- assist printer routing
- expose local diagnostic status
- enforce local emergency disable
- maintain local cache within approved limits

It must not:

- create payment truth
- create POS truth
- create settlement truth
- approve compensation
- publish customer messages
- override provider capability
- override tenant plan
- override policy gate
- silently reconcile conflicts
- mutate central truth without approved API

Local agent is continuity support.

It is not central authority.

---

## 11. POS Bridge Service Rule

A Windows POS Bridge Service may exist when required by provider or store environment.

It may:

- relay approved order handoff requests
- receive local POS response if supported
- report POS bridge health
- log request/response metadata
- queue retry candidate if permitted
- detect timeout or degraded status
- emit evidence packet candidate

It must not:

- mark payment confirmed
- mark settlement complete
- fabricate POS acceptance
- rewrite order amount
- suppress failed handoff
- retry without idempotency
- bypass provider evidence requirement
- expose raw POS errors to customers
- become direct customer-facing truth

POS accepted is not payment confirmed.

Provider callback is not verified internal state.

---

## 12. KDS Bridge Service Rule

A Windows KDS Bridge Service may exist when required.

It may:

- relay approved kitchen ticket candidate
- receive KDS status if supported
- expose staff-safe kitchen visibility
- report bridge health
- detect KDS delay
- support degraded kitchen notes
- upload evidence packet candidate

It must not:

- create settlement truth
- create compensation authority
- decide refund eligibility
- silently remake order
- rewrite payment/order state
- expose raw KDS errors to customers
- override POS/payment authority

KDS completed is not settled.

KDS visibility is not financial authority.

---

## 13. Printer And Peripheral Rule

Windows may be used for printers and peripherals.

Printer/peripheral components may:

- route kitchen print jobs
- route receipt print jobs
- report printer status
- report peripheral status
- retry print if permitted
- support local fallback printing
- log print evidence

They must not:

- decide order acceptance
- decide payment confirmation
- decide compensation
- create customer-visible status by themselves
- become source of truth for fulfillment
- bypass KDS/POS/payment boundaries

Printer output is evidence or operational aid.

Printer output is not authority.

---

## 14. Local Cache Rule

Windows local cache may support survivability.

Local cache may store approved limited data such as:

- device profile
- current runtime config
- approved menu projection snapshot
- approved i18n keys
- local queue metadata
- offline event candidates
- limited provider bridge state
- diagnostic logs
- retry candidates

Local cache must not store unrestricted sensitive data.

Local cache must not become permanent truth.

Local cache must declare:

- cache source
- issued time
- expiry
- config version
- stale status
- offline status
- sync status
- deletion/retention rule
- encryption requirement if applicable

Stale cache must be visible to the system.

---

## 15. Offline And Degraded Mode Rule

Windows local runtime may support degraded operation.

Allowed degraded actions may include:

- show staff-safe status
- print local kitchen note
- queue order candidate if approved
- queue evidence packet
- preserve local logs
- show provider unavailable status
- route to manual staff review
- continue local display with stale warning if approved

Prohibited degraded actions include:

- payment confirmation without verification
- refund execution
- wallet credit
- coupon mass issue
- provider capability verification
- customer legal/fault confirmation
- AI automatic customer response
- silent reconciliation
- central truth overwrite

Degraded operation is survival.

It is not authority expansion.

---

## 16. Update Channel Rule

Windows installer and local runtime must support controlled update channels.

Examples:

| Update Channel | Purpose |
|---|---|
| `stable` | Normal production release |
| `pilot` | Limited pilot store release |
| `provider_test` | Provider-specific test |
| `security_hotfix` | Urgent security update |
| `rollback` | Controlled rollback |
| `disabled` | Update disabled pending review |

Updates must be auditable.

Update does not imply feature activation.

A new component version may be installed but remain disabled by runtime config.

---

## 17. Component Version Rule

Each installed component must declare version metadata.

Required metadata may include:

- component name
- component version
- installer version
- build id
- provider profile
- installation time
- last update time
- update channel
- rollback target
- compatibility status
- config version
- runtime status

Version mismatch must not be ignored.

Version mismatch may require safe degraded mode.

---

## 18. Local Firewall And Network Rule

Windows installation may configure local firewall or network rules.

Allowed use:

- POS local network bridge
- KDS local network bridge
- printer network access
- local diagnostic endpoint
- outbound server sync
- update download
- log upload

Firewall/network configuration must not open broad unrestricted access.

Local ports must be documented.

Provider-specific endpoints must be mapped.

Unexpected inbound access must be blocked by default.

---

## 19. Secrets And Credential Rule

Windows installation must not expose secrets.

Rules:

- no hardcoded provider credentials
- no credentials in plain text config
- no payment secrets in installer package
- no tenant-wide secret on store device unless explicitly approved
- rotate local tokens if device is re-registered
- revoke tokens when device is revoked
- encrypt local sensitive configuration if stored
- avoid storing unnecessary raw payloads

Installer package must not carry production secrets.

---

## 20. Local Admin Utility Rule

Windows may include a local admin utility for diagnostics.

It may show:

- device status
- component status
- config version
- sync status
- provider bridge health
- printer status
- local queue length
- stale cache warning
- last successful sync
- last error category
- support code

It must not allow:

- payment state mutation
- refund execution
- provider capability approval
- compensation execution
- customer message send
- security containment release
- archive/legal mutation
- AI auto-send
- raw secret display

Local admin utility is diagnostic by default.

Mutation requires separate server-side authority.

---

## 21. Local Log And Evidence Rule

Windows local runtime must create structured logs.

Log/evidence may include:

- installation event
- update event
- config received event
- config stale event
- service start/stop event
- POS bridge request/response metadata
- KDS bridge metadata
- printer route event
- retry candidate event
- offline queue event
- emergency disable event
- device revoke event
- local error category

Logs must avoid storing unnecessary raw sensitive payloads.

Evidence packet must be uploaded when possible.

Local evidence is not final approval.

---

## 22. Emergency Disable Rule

Windows runtime must support emergency disable.

Emergency disable may target:

- device
- local agent
- POS bridge
- KDS bridge
- payment bridge
- printer bridge
- provider profile
- local cache use
- offline mode
- update channel
- admin utility mutation
- customer-facing projection

Emergency disable must be auditable.

Emergency disable must not delete evidence.

Containment is not resolution.

---

## 23. Device Suspension And Revocation Rule

Windows device status may include:

| Status | Meaning |
|---|---|
| `DEVICE_PENDING` | Registered but not active |
| `DEVICE_ACTIVE` | Active |
| `DEVICE_SUSPENDED` | Temporarily disabled |
| `DEVICE_REVOKED` | Permanently blocked |
| `DEVICE_RECOVERY_REQUIRED` | Needs review |
| `DEVICE_STALE_CONFIG` | Config stale |
| `DEVICE_OFFLINE_ALLOWED` | Offline allowed within limits |
| `DEVICE_OFFLINE_BLOCKED` | Offline not allowed |

A revoked device must not operate.

A suspended device must enter safe mode.

A stale device must not execute high-risk actions.

---

## 24. Windows Surface Types

Windows may host different surface types.

Examples:

| Surface Type | Role |
|---|---|
| `LOCAL_AGENT` | Store local coordination |
| `POS_BRIDGE` | POS handoff relay |
| `KDS_BRIDGE` | KDS relay/visibility |
| `PRINTER_BRIDGE` | Print routing |
| `COUNTER_TERMINAL` | Staff counter workflow |
| `BACK_OFFICE_ADMIN` | Owner/admin review |
| `DIAGNOSTIC_TOOL` | Local troubleshooting |
| `WINDOWS_KIOSK` | Optional Windows kiosk surface |

Each surface type must be registered.

Each surface type must receive a matching runtime configuration.

---

## 25. Windows Installer Package Types

Recommended package types:

| Package Type | Meaning |
|---|---|
| `FULL_STORE_AGENT_PACKAGE` | Local agent plus selected bridges |
| `POS_BRIDGE_ONLY_PACKAGE` | POS bridge only |
| `KDS_BRIDGE_ONLY_PACKAGE` | KDS bridge only |
| `PRINTER_BRIDGE_PACKAGE` | Printer/peripheral routing |
| `ADMIN_UTILITY_PACKAGE` | Diagnostic/admin tool |
| `WATCHDOG_PACKAGE` | Process monitoring |
| `UPDATE_AGENT_PACKAGE` | Update control |
| `PILOT_PACKAGE` | Pilot store package |
| `ROLLBACK_PACKAGE` | Rollback package |

Package type must be compatible with tenant/store/device profile.

---

## 26. Installer Approval Rule

A Windows installer package must not be distributed without approval metadata.

Required approval metadata may include:

- package name
- package version
- target component set
- target provider profile
- target OS version range
- target store profile
- update channel
- rollback package
- reviewer
- security scan status
- no-secret confirmation
- release note
- known limitations
- runtime feature status

Distribution approval is not runtime authorization.

---

## 27. Compatibility Rule

Windows package compatibility must be declared.

Compatibility dimensions may include:

- Windows version
- POS vendor
- KDS vendor
- printer model
- network topology
- provider plugin version
- local DB/cache version
- update agent version
- firewall profile
- device role
- store runtime profile

Unknown compatibility must default to review required.

---

## 28. Safe Failure Rule

If Windows local runtime cannot verify config or authority, it must fail safely.

Safe failure examples:

| Failure | Safe Behavior |
|---|---|
| Server unreachable | Enter approved offline/degraded mode only |
| Config expired | Disable high-risk actions |
| Provider bridge down | Route to staff review |
| POS handoff timeout | Do not mark accepted |
| Payment verify unavailable | Do not mark paid |
| KDS unavailable | Show staff-managed status |
| Printer failure | Alert staff and log evidence |
| Token revoked | Stop operation |
| Component mismatch | Require review or rollback |

Silent continuation is prohibited for high-risk functions.

---

## 29. Anti-Patterns

Avoid:

- installer option treated as feature authority
- local config overriding server policy
- Windows local agent becoming source of truth
- POS bridge marking payment confirmed
- KDS bridge triggering compensation
- printer output treated as order truth
- local admin utility executing refunds
- provider credentials embedded in installer
- raw provider payload stored indefinitely
- unversioned local config
- hidden auto-update without audit
- local retry without idempotency
- offline mode without expiry
- emergency disable deleting evidence

These anti-patterns create financial, operational, and security risk.

---

## 30. Validation Checklist

Validation must confirm:

1. Windows installer options are preparation only.
2. Runtime authority remains server-side.
3. Device registration is required.
4. Local runtime configuration is server-issued or server-verified.
5. Local agent is continuity support, not central authority.
6. POS bridge does not create payment truth.
7. KDS bridge does not create settlement or compensation truth.
8. Printer/peripheral output is not authority.
9. Local cache has expiry and stale status.
10. Offline/degraded mode has strict limits.
11. Update channel is controlled.
12. Component versions are tracked.
13. Firewall/network rules are documented.
14. Secrets are not embedded in installer.
15. Local admin utility is diagnostic by default.
16. Logs and evidence are structured.
17. Emergency disable is supported.
18. Device suspension/revocation is supported.
19. Package approval metadata is required.
20. Compatibility is declared.
21. Safe failure behavior is defined.
22. Runtime remains deferred.

---

## 31. Relationship To Previous Documents

This document follows:

- `10040 Domain Capability Control Plane And Runtime Feature Assembly Policy`

It references:

- `09520 Universal Integration Event Alert Logging And Evidence Policy`
- `09550 Universal Alert Routing Severity Escalation And Acknowledgement Policy`
- `09560 Financial-Grade Foundation Security Bulkhead Alert Log And pgvector Observability Policy`
- `09610 Financial-Grade Security Monitoring Foundation Package Index And Runtime Entry Deferral Policy`
- `09620 Financial-Grade Security Monitoring Foundation Catalog Work Order And Implementation Handoff Policy`
- `09730 Provider Evidence Review Packet And Capability Acceptance Matrix Policy`
- `09930 Provider Evidence Registry Static Package Handoff And Capability Traceability Policy`
- `09960 Catch And Order Status Catalog Static Package Handoff And Order Handoff Safe State Policy`
- `09970 Support Admin Boundary Catalog Static Package Handoff And Review Surface Policy`
- `10000 Foundation Static Catalog Package Closure And Runtime Entry Deferral Policy`
- `10010 Explicit Static Catalog Coding Authorization Packet Template And Approval Boundary Policy`
- `10020 Modular SaaS Core And Future Kiosk Reuse Principle Policy`
- `10030 Domain Object Core Use Case API And Safe Projection Architecture Policy`
- `10040 Domain Capability Control Plane And Runtime Feature Assembly Policy`

It prepares later planning for:

- `10042 Android Device Provisioning Runtime Configuration And Kiosk Mode Policy`
- Windows package manifest template
- Windows local runtime config schema
- Windows device registration schema
- Windows local agent boundary contract
- POS bridge local package policy
- KDS bridge local package policy
- printer bridge local package policy
- update and rollback package policy
- local evidence packet schema

This document is architecture planning only.

It does not authorize coding.

---

## 32. Final Rule

Windows may use installer-time options to prepare local modules, provider bridges, peripheral support, local cache, admin tools, update agents, and diagnostic utilities.

However, Windows installer options must not authorize runtime execution.

All Windows local runtime behavior must remain subordinate to server-side device registration, provider capability, tenant feature plan, store runtime configuration, policy gate, runtime feature flag, authority boundary, evidence requirement, audit requirement, Use Case API decision, and Safe Projection output.

The installer prepares.

The local agent supports continuity.

The server governs.

The Use Case API decides.

The Safe Projection informs the surface.

Runtime implementation remains deferred until separately authorized.
