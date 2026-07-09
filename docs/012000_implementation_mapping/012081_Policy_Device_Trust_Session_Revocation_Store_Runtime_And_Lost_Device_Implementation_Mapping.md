# 012081_Policy_Device_Trust_Session_Revocation_Store_Runtime_And_Lost_Device_Implementation_Mapping.md

## Purpose

This document defines the implementation mapping policy for device trust, store runtime access, device-bound sessions, lost device handling, compromised device response, session revocation, and runtime access control in the Yoonsul Wait/Order Handoff project.

Store operations depend on devices.

POS terminals, KDS screens, store tablets, staff mobiles, owner mobiles, support workstations, kiosks, local agents, and bridge services may all access operational data.

If device trust is weak, a valid user account may still become a security risk.

Therefore, device trust and session revocation must be mapped before implementation.

This document does not implement device registry, session service, RLS policy, device approval workflow, revocation engine, or mobile application code.

It defines the constraints that future device trust implementation must obey.

---

## 2. Scope

This mapping applies to:

- device registration
- device approval
- device trust state
- device role
- device-bound session
- store runtime access
- lost device response
- compromised device response
- suspicious device handling
- device session revocation
- staff mobile access
- store tablet access
- POS terminal access
- KDS screen access
- kiosk access
- owner mobile access
- HQ admin device access
- support workstation access
- local agent identity
- bridge service identity
- device audit
- device evidence
- testing requirements
- implementation blockers

This document does not define final device implementation code.

---

## 3. Core Principle

User authority and device trust are separate controls.

The project must follow this rule:

> A valid user on an untrusted, lost, compromised, or wrong-scope device must not receive the same authority as the same user on a trusted device.

Access decisions must evaluate both actor authority and device trust.

---

## 4. Related Policy Documents

This mapping depends on:

- 04471_Policy_Financial_Grade_Security_Baseline_And_Secret_Coding
- 04491_Policy_Degraded_Security_Recovery_And_Evidence_Boundary
- 04521_Policy_Support_Access_Masking_Break_Glass_And_Scoped_Session
- 04531_Policy_Security_Audit_Event_Immutability_And_Tamper_Evidence
- 04541_Policy_Device_Trust_Session_Revocation_And_Store_Runtime_Access
- 04561_Policy_Tenant_Store_Boundary_Isolation_And_Cross_Context_Access
- 04571_Policy_Secure_Deployment_Environment_Separation_And_Release_Gate
- 04581_Policy_Log_Masking_Error_Disclosure_And_Diagnostic_Data
- 04621_Policy_Security_Incident_Response_Severity_Classification_And_Recovery_Governance
- 04631_Policy_Compliance_Readiness_Evidence_Control_And_Financial_Grade_Security_Review
- 04661_Policy_Security_Testing_Abuse_Case_Threat_Modeling_And_Verification
- 04831_Implementation_Mapping_Lane_Start_And_Policy_To_Code_Constraint_Handoff_Policy
- 04841_Policy_Tenant_Store_Context_RLS_And_Access_Control_Implementation_Mapping
- 04851_Audit_Event_Taxonomy_Append_Only_And_Evidence_Implementation_Mapping_Policy
- 04861_Policy_POS_KDS_RPC_Bridge_Idempotency_Replay_Implementation_Mapping
- 04891_Policy_Support_Access_Masking_Break_Glass_And_Scoped_Session_Implementation_Mapping

Future device implementation must inherit these constraints.

---

## 5. Affected Runtime

This mapping affects:

- Customer Web Runtime
- Customer Mobile Runtime
- Staff Runtime
- Store Tablet Runtime
- POS Runtime
- KDS Runtime
- Kiosk Runtime
- Owner Runtime
- HQ Admin Runtime
- Support Runtime
- Local Agent Runtime
- POS/KDS Bridge Runtime
- Audit Runtime
- Incident Runtime
- Deployment Runtime

Device trust affects any runtime that reads, writes, displays, syncs, or mutates operational data.

---

## 6. Device Category Mapping

Device categories may include:

- POS Terminal
- KDS Screen
- Store Tablet
- Kitchen Tablet
- Staff Mobile
- Owner Mobile
- HQ Admin Workstation
- Support Workstation
- Customer Mobile
- Customer Web Browser
- Kiosk
- Local Agent Primary
- Local Agent Secondary
- POS/KDS Bridge Service
- Vendor Remote Device
- Temporary Replacement Device

Each device category must have different authority and trust requirements.

---

## 7. Device Role Mapping

Device role should define what the device is allowed to do.

Possible device roles:

- `POS_TERMINAL`
- `KDS_SCREEN`
- `STORE_TABLET`
- `KITCHEN_TABLET`
- `STAFF_MOBILE`
- `OWNER_MOBILE`
- `HQ_ADMIN_DEVICE`
- `SUPPORT_WORKSTATION`
- `CUSTOMER_DEVICE`
- `KIOSK_DEVICE`
- `LOCAL_AGENT_PRIMARY`
- `LOCAL_AGENT_SECONDARY`
- `BRIDGE_SERVICE`
- `VENDOR_DEVICE`
- `TEMPORARY_REPLACEMENT`

Device role must not be inferred only from UI route.

Device role must be registered, verified, and auditable.

---

## 8. Device Trust State Mapping

Recommended device trust states:

- `UNREGISTERED`
- `REGISTERED`
- `PENDING_APPROVAL`
- `TRUSTED`
- `LIMITED_TRUST`
- `SUSPICIOUS`
- `REVOKED`
- `LOST`
- `COMPROMISED`
- `REPLACED`
- `EXPIRED`
- `DECOMMISSIONED`

Trust state must affect access immediately or as close to immediately as practical.

---

## 9. Device Registration Mapping

Device registration should define:

- device_id
- tenant_id
- store_id where applicable
- device_role
- registered_by
- registered_at
- device fingerprint or trusted identifier
- platform
- app version where applicable
- runtime type
- approval status
- last_seen_at
- trust_state
- audit_event_id

Device registration is not the same as device approval.

---

## 10. Device Approval Mapping

Device approval should define:

- approving actor
- approval authority
- tenant scope
- store scope
- device role
- approved actions
- expiration where applicable
- reason
- audit event
- evidence record

High-authority devices should require stronger approval.

Store Tablet, POS Terminal, KDS Screen, Local Agent, Bridge, and Support Workstation are high-risk device categories.

---

## 11. Store Tablet Authority Mapping

Store Tablet is considered a high-function in-store operational device.

Store Tablet may support:

- store operational dashboard
- waiting management
- order visibility
- table/session handling
- staff operational handling
- KDS status visibility
- degraded recovery support
- incident capture
- manual recovery note
- owner or manager action where authenticated

Store Tablet must be treated as high-risk if lost, stolen, or compromised.

---

## 12. POS Terminal Device Mapping

POS Terminal access must be tightly scoped.

POS Terminal may:

- process POS order flow
- confirm POS accepted order
- relay payment visibility
- create POS transaction references
- communicate with bridge
- support transaction correction under authority

POS Terminal must not:

- act as support admin
- browse unrelated store data
- access raw CI / DI
- expose provider secrets
- bypass payment authority
- override KDS state silently

POS Terminal identity must be store-bound.

---

## 13. KDS Screen Device Mapping

KDS Screen access must be kitchen-scoped.

KDS Screen may:

- display kitchen tickets
- update kitchen execution status where allowed
- show hold/delay/remake/ready/served status
- show filtered kitchen notes
- show operational payment signal where allowed
- display manual recovery indicator

KDS Screen must not:

- mutate payment
- approve refund
- access raw identity
- browse customer history
- access support notes
- browse unrelated store tickets
- access owner settlement

KDS device loss must be treated seriously because it can expose kitchen operations and order data.

---

## 14. Staff Mobile Device Mapping

Staff mobile access should be limited.

Staff mobile may:

- view assigned shift where applicable
- access staff self-service
- view assigned store operational tasks where role permits
- receive staff notifications
- submit limited incident or recovery note where allowed
- perform check-in/out where supported

Staff mobile must not automatically receive full Store Tablet authority.

Staff mobile should be restricted if device trust is weak.

---

## 15. Owner Mobile Device Mapping

Owner mobile may access owner-scoped views.

Owner mobile may see:

- authorized store summary
- sales summary
- settlement summary
- incident summary
- staff operational summary where allowed
- support case summary where allowed

Owner mobile must not automatically see:

- raw CI / DI
- payment secrets
- unrestricted audit
- unrelated tenant data
- unrelated store data
- full support notes
- staff private data beyond policy

Owner mobile may require stronger reauthentication for sensitive views.

---

## 16. Support Workstation Mapping

Support workstation is high-risk.

Support workstation must support:

- case-scoped access
- masked default view
- unmask approval enforcement
- break-glass session handling
- audit creation
- session expiration
- export restriction

Support workstation must not store local unmasked data unnecessarily.

Lost or compromised support workstation may create security incident.

---

## 17. HQ Admin Device Mapping

HQ admin device is high-risk.

HQ admin device may support:

- tenant operations
- store operations
- configuration review
- support review
- incident response
- export approval
- deployment visibility
- security review

HQ admin actions may require:

- trusted device
- fresh session
- MFA or reauthentication where applicable
- audit
- approval where sensitive
- device posture check where available

HQ admin device compromise is a high-severity incident candidate.

---

## 18. Kiosk Device Mapping

Kiosk device should be customer-facing and limited.

Kiosk may:

- display menu
- create customer order request
- initiate payment flow where allowed
- show customer-safe status
- support simple language selection

Kiosk must not:

- access admin screens
- expose staff functions
- access support functions
- show other customers' data
- expose payment secrets
- expose raw identity
- bypass POS/payment authority

Kiosk session must reset safely between customers.

---

## 19. Local Agent Device Mapping

Local Agent identity is critical during degraded operation.

Local Agent may be:

- Primary
- Secondary
- Promoted Primary
- Recovery Pending

Local Agent must be bound to:

- tenant_id
- store_id
- device_id or service identity
- trust_state
- role state
- issued credential
- last verified state
- central sync status

Local Agent must not operate across store boundary.

Secondary must not overwrite Primary-derived state.

---

## 20. Bridge Service Device Mapping

Bridge service identity must be tightly scoped.

Bridge may:

- receive POS/KDS events
- validate events
- translate events
- queue events
- retry events
- detect mismatch
- create audit and evidence

Bridge must not:

- approve refund
- mutate payment truth
- settle funds
- silently overwrite POS/KDS truth
- bypass tenant/store context
- delete audit

Bridge credential must be protected and revocable.

---

## 21. Device-Bound Session Mapping

Session should bind actor and device.

Session may include:

- session_id
- actor_id
- actor_role
- tenant scope
- store scope
- device_id
- device_role
- trust_state at session start
- runtime_type
- authentication time
- last activity time
- reauthentication status
- support_case_id where applicable
- break_glass flag where applicable
- expiration time

If device trust changes, session authority must be re-evaluated.

---

## 22. Session Freshness Mapping

Sensitive actions may require fresh authentication.

Sensitive actions include:

- payment correction
- refund approval
- support unmasking
- break-glass request
- role change
- device approval
- export approval
- CI / DI access
- deployment action
- local agent promotion
- audit export
- settlement adjustment

Freshness requirement should depend on risk.

---

## 23. Session Revocation Mapping

Session revocation should occur when:

- user logs out
- device is revoked
- device is marked lost
- device is marked compromised
- role is removed
- assignment is removed
- support case closes
- break-glass session expires
- suspicious behavior detected
- password or authentication factor reset
- incident containment requires revocation
- device replacement occurs

Revocation must be auditable.

---

## 24. Lost Device Response Mapping

When a device is lost:

1. Mark device as `LOST`.
2. Revoke active sessions.
3. Disable refresh where applicable.
4. Restrict cached data use where possible.
5. Notify responsible manager or owner where needed.
6. Create audit event.
7. Create incident or security review if high-risk.
8. Require replacement device approval.
9. Review recent access.
10. Confirm closure.

Lost high-authority device is a security event.

---

## 25. Compromised Device Response Mapping

When a device is compromised:

1. Mark device as `COMPROMISED`.
2. Revoke active sessions immediately.
3. Revoke device credential.
4. Rotate related service credentials where needed.
5. Disable local cache trust.
6. Open security incident.
7. Preserve audit.
8. Review recent actions.
9. Check exports, unmasking, payment, support, and admin activity.
10. Approve replacement only after review.

Compromised device may require severity escalation.

---

## 26. Suspicious Device Mapping

Suspicious device signals may include:

- unusual location or network
- repeated failed authentication
- repeated denied context access
- device fingerprint change
- impossible travel
- outdated app version with high-risk action
- jailbreak/root indicator where detectable
- local agent heartbeat anomaly
- support workstation abnormal access pattern
- bridge credential misuse
- KDS/POS identity mismatch

Suspicious device may be restricted, challenged, reviewed, or revoked.

---

## 27. Device Replacement Mapping

Device replacement should define:

- old device id
- replacement device id
- reason
- replaced_by actor
- approved_by actor
- old device state
- new device trust state
- session migration rule
- cache invalidation rule
- audit event
- evidence where high-risk

Replacement should not silently transfer unlimited authority.

---

## 28. Offline Cache And Device Trust Mapping

Offline cache may be necessary for store continuity.

Offline cache must follow:

- tenant/store scope
- device role scope
- expiration
- encryption where applicable
- minimal data
- masking
- fallback-originated marker
- cache_state_uncertain marker
- sync verification
- revocation behavior
- no raw CI / DI
- no payment secrets

Offline cache must not become uncontrolled local database.

---

## 29. Device Trust During Degraded Mode

During degraded mode:

- device trust still matters
- revoked devices should not gain authority
- lost devices should not participate
- Secondary local agent must not overwrite Primary
- local provisional records must be marked
- support unmasking must not bypass central approval
- payment truth must not be finalized locally
- audit/evidence must capture device identity

Degraded mode is not device trust bypass.

---

## 30. Store Runtime Access Mapping

Store runtime access must validate:

- actor role
- device role
- device trust state
- tenant_id
- store_id
- runtime type
- current session
- requested action
- data category
- degraded mode status
- support case or approval where applicable

Store runtime access must not rely on UI-only role selection.

---

## 31. Device Audit Mapping

Device audit events should include:

- device registered
- device approval requested
- device approved
- device denied
- device trust changed
- device session created
- session revoked
- device marked lost
- device marked compromised
- device replaced
- device decommissioned
- suspicious device detected
- local agent promoted
- bridge credential rotated
- POS/KDS device mismatch detected
- support workstation high-risk access

Audit must link actor, tenant, store, device, session, and action where applicable.

---

## 32. Device Evidence Packet Mapping

Device evidence packet may include:

- device id
- device role
- trust state timeline
- session records
- actor records
- tenant/store scope
- lost or compromised report
- recent high-risk actions
- revocation record
- replacement record
- audit event references
- incident reference
- closure status

Evidence packet must not expose secrets or unnecessary raw identity.

---

## 33. Device Log Masking Mapping

Device logs must not expose:

- service role key
- refresh token
- access token
- API key
- payment secret
- webhook secret
- raw CI / DI
- raw payment payload
- customer full phone/email
- authorization header
- local agent credential
- bridge credential

Device diagnostics should use masked identifiers.

---

## 34. Export And Device Data Mapping

Device data export is sensitive.

Export may include:

- device inventory
- trust state history
- lost device report
- compromised device report
- session revocation report
- local agent status report

Export must require authority, scope, masking, audit, and retention rule.

---

## 35. Support Device Handling Mapping

Support may assist device issues only under case scope.

Support may see:

- device role
- trust state
- last seen time
- masked actor reference
- store scope
- lost or compromised status
- recommended next action

Support must not see device credentials or secrets.

Support cannot restore trust without required authority.

---

## 36. AI Device Assistance Mapping

AI may assist by:

- summarizing device incident
- detecting abnormal patterns
- suggesting revocation checklist
- classifying risk level
- identifying missing evidence
- drafting support response
- recommending replacement process

AI must not:

- approve device trust
- revoke device without authority
- restore compromised device
- expose credentials
- override lost device state
- promote local agent
- close incident as final authority

AI output is recommendation only.

---

## 37. Testing Requirements

Future tests must include:

- unregistered device cannot access store runtime
- pending device has limited access
- revoked device loses access
- lost device session is revoked
- compromised device credential is revoked
- device role mismatch is denied
- staff mobile cannot perform Store Tablet-only action
- KDS screen cannot mutate payment
- POS terminal cannot browse support data
- support workstation requires case scope
- local agent cannot cross store boundary
- Secondary local agent cannot overwrite Primary
- device trust change invalidates session
- sensitive action requires fresh session
- offline cache expires or is marked uncertain
- logs do not expose secrets
- device audit events are created

Testing must include abuse cases.

---

## 38. Evidence Requirements

Evidence must prove:

- device registry exists
- device approval exists for high-risk devices
- device trust state affects access
- device-bound session exists
- lost device revokes sessions
- compromised device opens incident path
- device replacement is auditable
- offline cache is scoped and limited
- degraded mode does not bypass device trust
- local agent role boundary is enforced
- bridge credential is protected
- support workstation access is scoped
- device audit events are created
- device logs are masked
- tests verify revocation behavior

Evidence must be reviewable without exposing credentials.

---

## 39. Implementation Blockers

Implementation must be blocked if:

- device registry is undefined
- device role is undefined
- trust state is undefined
- device approval is undefined for high-risk devices
- session is not device-bound
- revocation behavior is undefined
- lost device response is undefined
- compromised device response is undefined
- support workstation trust is undefined
- local agent identity is undefined
- bridge service identity is undefined
- offline cache trust is undefined
- device audit mapping is missing
- device logs may expose secrets
- tests are missing

These blockers must be added to the implementation blocker register.

---

## 40. Mapping Status

Recommended status for this mapping:

- `DRAFT`
- `POLICY_LINKED`
- `RUNTIME_DEFINED`
- `DEVICE_ROLE_MAPPED`
- `TRUST_STATE_MAPPED`
- `SESSION_MAPPED`
- `REVOCATION_MAPPED`
- `LOST_DEVICE_MAPPED`
- `COMPROMISED_DEVICE_MAPPED`
- `DEGRADED_MAPPED`
- `AUDIT_MAPPED`
- `EVIDENCE_MAPPED`
- `TEST_MAPPED`
- `BLOCKED`
- `READY_FOR_REVIEW`
- `READY_FOR_IMPLEMENTATION`

This document starts as `DRAFT`.

It becomes implementation-ready only after device registry, trust state, session, revocation, audit, and test catalogs are mapped in more detail.

---

## 41. Non-Goals

This document does not define:

- final device registry table
- final session table
- final device fingerprint algorithm
- final device approval UI
- final revocation service
- final mobile app device binding
- final POS terminal integration
- final KDS device integration
- final local agent credential implementation
- final bridge credential implementation
- final offline cache encryption implementation
- final automated test code
- final production deployment

Those belong to later controlled implementation phase.

---

## 42. Readiness Check

This mapping is ready when the project can answer:

1. What device categories exist?
2. What device roles exist?
3. What trust states exist?
4. How is a device registered?
5. How is a device approved?
6. Why is Store Tablet high-risk?
7. What can POS Terminal do?
8. What must POS Terminal not do?
9. What can KDS Screen do?
10. What must KDS Screen not do?
11. What can Staff Mobile do?
12. What can Owner Mobile do?
13. What is Support Workstation allowed to do?
14. What is HQ Admin Device allowed to do?
15. What can Kiosk do?
16. How is Local Agent identity mapped?
17. How is Bridge Service identity mapped?
18. What is a device-bound session?
19. What sensitive actions require fresh session?
20. When is session revoked?
21. What happens when a device is lost?
22. What happens when a device is compromised?
23. What makes a device suspicious?
24. How is device replacement handled?
25. How is offline cache controlled?
26. How does degraded mode affect device trust?
27. How is store runtime access validated?
28. What audit events are required?
29. What evidence packet is created?
30. What logs must be masked?
31. How is device export controlled?
32. What can support see about devices?
33. What can AI assist with?
34. What must AI not do?
35. What tests prove device trust?
36. What evidence proves revocation and trust controls?
37. What blocks implementation?

If these questions cannot be answered, device trust implementation mapping is incomplete.

---

## 43. Conclusion

Device trust is a core operational security boundary for the Yoonsul Wait/Order Handoff project.

The system must preserve the following rules:

- user authority and device trust are separate
- device role must be registered and verified
- trust state must affect access
- high-risk devices require approval
- Store Tablet is high-risk
- POS Terminal is store-bound
- KDS Screen is kitchen-scoped
- Staff Mobile must not become full store admin
- Support Workstation is case-scoped
- Local Agent identity must be store-bound
- Bridge Service credential must be protected
- sessions should be device-bound
- sensitive actions may require fresh session
- lost devices must revoke sessions
- compromised devices must trigger incident path
- device replacement must be auditable
- offline cache must be scoped and limited
- degraded mode is not device trust bypass
- device audit must capture high-risk changes
- device logs must not expose secrets
- support and AI may assist but must not override trust authority
- implementation is blocked until device registry, trust state, session revocation, lost device response, audit, evidence, and tests are mapped

This mapping does not implement device trust runtime.

It defines the constraints that future device trust and session revocation implementation must obey.