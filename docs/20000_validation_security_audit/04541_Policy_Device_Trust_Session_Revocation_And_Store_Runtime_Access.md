# 04541_Policy_Device_Trust_Session_Revocation_And_Store_Runtime_Access

## 1. Purpose

This document defines the device trust, session control, revocation, and store runtime access policy for the Yoonsul Wait/Order Handoff project.

The project uses multiple runtime devices, including POS terminals, KDS screens, store tablets, staff mobiles, owner mobiles, HQ admin web, support sessions, local agents, and bridge runtimes.

Device trust must not be confused with user authority.

A trusted device may still be used by an unauthorized user.

An authorized user may still be using an untrusted or compromised device.

Therefore, device trust and user authority must be separately verified, separately audited, and separately revocable.

---

## 2. Scope

This policy applies to:

- POS terminal
- KDS device
- store tablet
- kitchen tablet
- staff mobile
- owner mobile
- HQ admin web device
- support access session
- kiosk device
- local agent device
- POS/KDS bridge runtime
- customer-facing order device where applicable
- browser session
- mobile app session
- degraded mode local session
- device registration
- device approval
- device revocation
- session invalidation
- lost or stolen device response
- suspicious device access

This document does not define the final device registration UI.

It defines the mandatory trust and revocation rules that later runtime, admin, POS/KDS, local agent, support, and security documents must follow.

---

## 3. Core Principle

Device trust is not user authority.

The project must follow this rule:

> A device may be trusted to participate in a runtime, but every sensitive action must still verify user, role, tenant, store, session, and action authority.

Device trust must never become a shortcut around access control.

---

## 4. Device Role Classification

Devices must be classified by runtime role.

Recommended device roles include:

- POS Terminal
- KDS Screen
- Store Tablet
- Kitchen Tablet
- Staff Mobile
- Owner Mobile
- HQ Admin Web
- Support Workstation
- Kiosk Device
- Local Agent Primary
- Local Agent Secondary
- POS Bridge Runtime
- KDS Bridge Runtime
- Customer Web Session
- Customer Mobile Session

Each device role has different authority, visibility, risk, and revocation requirements.

---

## 5. Device Trust Levels

Device trust should be represented explicitly.

Recommended trust levels include:

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

A device without valid trust status must not perform sensitive runtime actions.

Trust level must be auditable.

---

## 6. User Role And Device Role Separation

The system must separately evaluate:

- who the user is
- what role the user has
- which tenant the user belongs to
- which store the user is operating in
- which device is being used
- what device role the device has
- whether the session is valid
- whether the requested action is allowed

Examples:

- A store tablet may be trusted, but a crew member must not perform owner-only settlement action.
- An owner may be authorized, but a new unknown device may require reauthentication or approval.
- A KDS screen may be trusted for kitchen visibility, but it must not execute payment correction.
- A support user may have support role, but support access must still be case-scoped.

Device role and user role must not collapse into one permission.

---

## 7. Store Tablet Policy

Store Tablet is a high-authority in-store operational device.

Store Tablet may support:

- store operation dashboard
- staff operation support
- order visibility
- waiting visibility
- KDS/POS status review
- manual recovery request
- degraded mode visibility
- owner or manager action where authenticated
- evidence attachment where authorized
- store configuration where authorized

Store Tablet must not bypass:

- user authentication
- role authority
- tenant context
- store context
- audit requirement
- reauthentication for sensitive actions
- approval for high-risk actions

Store Tablet loss must be treated as high-risk.

---

## 8. POS Terminal Policy

POS Terminal is transaction-sensitive.

POS Terminal may participate in:

- accepted order creation
- payment handoff
- cancellation within authority
- receipt issuance
- transaction status reporting
- POS/KDS ticket boundary

POS Terminal must not:

- expose service role keys
- expose raw customer CI/DI
- allow arbitrary bridge mutation
- bypass payment audit
- accept untrusted local replay as final truth
- allow unauthorized user to perform sensitive correction

POS Terminal trust change must be audited.

---

## 9. KDS Device Policy

KDS Device is kitchen execution-sensitive.

KDS Device may display and mutate kitchen execution state within allowed boundary.

KDS may handle:

- ticket received
- cooking started
- hold
- delay
- remake request
- ready
- served
- manual kitchen note

KDS Device must not:

- rewrite payment state
- expose raw CI/DI
- expose full customer identity
- approve refund
- approve settlement correction
- close recovery case
- act as POS transaction authority

KDS Device trust must be scoped to tenant and store.

---

## 10. Staff Mobile Policy

Staff Mobile may be useful for movement and field handling.

Staff Mobile may support:

- check assigned tasks
- view scoped store operation
- receive alerts
- attach recovery note where authorized
- perform low-risk staff actions
- confirm assigned operational status

Staff Mobile must not automatically receive full store tablet authority.

Staff Mobile sensitive action may require:

- reauthentication
- device trust check
- role check
- location or store context check where applicable
- manager approval where applicable

Lost staff mobile must trigger session invalidation.

---

## 11. Owner Mobile Policy

Owner Mobile may require higher visibility than staff mobile.

Owner Mobile may support:

- store status monitoring
- order and waiting overview
- incident notification
- approval request review
- limited recovery approval where allowed
- sales and operation summary
- staff issue review where scoped

Owner Mobile must not expose unnecessary raw identity data.

High-risk owner action may require reauthentication.

Owner Mobile loss must trigger immediate revocation or session invalidation.

---

## 12. HQ Admin Web Policy

HQ Admin Web has broad potential authority.

HQ Admin Web must apply stricter controls, including:

- strong authentication
- role-based access
- tenant scope validation
- support case scope where applicable
- reauthentication for sensitive actions
- audit for configuration changes
- audit for role changes
- masking by default
- break-glass separation
- suspicious access detection

HQ Admin Web must not become universal untracked authority.

---

## 13. Support Workstation Policy

Support Workstation must be controlled separately from ordinary web access.

Support Workstation may access support cases, logs, evidence, and scoped operational records.

Support Workstation must enforce:

- case-based access
- masking by default
- support session scope
- time-bound sensitive access
- unmasking audit
- export control
- break-glass review
- suspicious behavior detection

Support Workstation must not expose raw secrets.

---

## 14. Local Agent Device Policy

Local Agent devices are operationally sensitive.

Local Agent may support:

- local queue
- degraded mode continuity
- POS/KDS relay
- evidence capture
- sync preparation
- mismatch detection
- health reporting

Local Agent must not:

- become payment authority
- become settlement authority
- become final recovery authority
- overwrite central state silently
- access cross-tenant data
- access cross-store data unless explicitly scoped
- expose broad credentials

Local Agent credentials must be scoped and revocable.

---

## 15. Primary And Secondary Local Agent Trust

Primary and Secondary Local Agent roles must be explicit.

Primary Local Agent may coordinate provisional local continuity.

Secondary Local Agent may hold backup cache and detect divergence.

Secondary must not overwrite Primary.

Promotion from Secondary to Promoted Primary must require explicit promotion condition and audit.

Device trust state must reflect:

- `PRIMARY`
- `SECONDARY`
- `PROMOTED_PRIMARY`
- `RECOVERY_PENDING`
- `REVOKED`
- `COMPROMISED`

Promotion is a security event.

---

## 16. Bridge Runtime Device Policy

POS/KDS Bridge runtime must be treated as a trusted service identity, not an ordinary client.

Bridge runtime may:

- validate
- translate
- queue
- retry
- reject
- quarantine
- report mismatch
- create evidence

Bridge runtime must not:

- own transaction truth
- own kitchen truth
- silently mutate final state
- bypass tenant/store validation
- expose bridge credential to client devices
- accept unsigned or untrusted mutation request

Bridge credential rotation and revocation must be auditable.

---

## 17. Kiosk Device Policy

Kiosk Device is customer-facing and must be limited.

Kiosk may support:

- menu browsing
- order input
- payment initiation
- waiting participation
- pickup flow
- language selection
- receipt or order reference display

Kiosk must not expose:

- service role key
- admin credential
- raw CI/DI
- other customer data
- internal audit data
- unrestricted POS/KDS mutation path

Kiosk output must pass through POS/order validation before kitchen ticket creation.

---

## 18. Customer Session Policy

Customer sessions must be scoped and limited.

Customer session may include:

- waiting token
- order session
- table session
- cart session
- membership session
- payment return session

Customer session must not allow:

- other customer order access
- other table session access
- tenant boundary bypass
- store boundary bypass
- direct KDS ticket creation
- payment status forgery
- identity linkage exposure

Session tokens must be protected and time-limited where appropriate.

---

## 19. Device Registration Policy

Device registration must create an audit event.

Device registration should capture:

- device id
- device role
- tenant id
- store id where applicable
- registered by
- registration time
- approval status
- device name or label
- runtime type
- trust level
- initial capability scope

Device registration must not automatically grant full authority.

Approval or activation may be required depending on device role.

---

## 20. Device Approval Policy

High-risk devices require approval before trusted operation.

High-risk devices include:

- POS Terminal
- KDS Device
- Store Tablet
- HQ Admin Web device where device trust is used
- Support Workstation
- Local Agent Primary
- Local Agent Secondary
- Bridge Runtime
- Kiosk Device where order/payment is supported

Approval must include:

- approver
- reason
- tenant scope
- store scope
- device role
- allowed capabilities
- approval time
- audit event

---

## 21. Session Creation Policy

Session creation must validate both user and device context where applicable.

Session must include or derive:

- user id
- role
- tenant id
- store id where applicable
- device id
- device role
- trust level
- session start time
- session expiration
- allowed capabilities
- authentication method
- reauthentication requirement where applicable

Session must not outlive revoked device trust.

---

## 22. Session Expiration Policy

Sessions must expire according to risk.

Higher-risk sessions should have shorter expiration or stronger reauthentication.

Examples requiring stricter handling:

- HQ admin session
- support session
- break-glass session
- owner approval session
- payment correction session
- identity unmasking session
- secret rotation session
- device trust management session
- degraded recovery approval session

Expired sessions must not continue sensitive authority.

---

## 23. Reauthentication Policy

Sensitive actions may require reauthentication.

Examples:

- refund trigger
- payment correction
- settlement adjustment
- identity unmasking
- role permission change
- support access elevation
- break-glass activation
- device revocation
- secret rotation
- tenant policy change
- store policy change
- degraded recovery approval
- POS/KDS recovery approval

A valid session alone may not be enough for sensitive action.

---

## 24. Device Revocation Policy

Device revocation must immediately remove trust.

Revocation may be triggered by:

- lost device
- stolen device
- compromised device
- retired device
- replaced device
- suspicious access
- staff termination
- vendor termination
- bridge credential exposure
- local agent compromise
- store closure
- tenant termination
- owner request
- security incident

Revocation must create audit event.

Revoked device must not perform sensitive runtime actions.

---

## 25. Session Invalidation Policy

When device trust is revoked, active sessions tied to the device must be invalidated where possible.

Session invalidation may be required for:

- lost staff mobile
- lost owner mobile
- lost store tablet
- compromised support workstation
- compromised HQ device
- replaced POS terminal
- retired KDS device
- compromised local agent
- exposed bridge runtime credential

Session invalidation must be auditable for sensitive device classes.

---

## 26. Lost Or Stolen Device Response

If a device is lost or stolen:

1. Identify device role.
2. Identify tenant and store scope.
3. Revoke device trust.
4. Invalidate active sessions.
5. Rotate credentials if stored or suspected exposed.
6. Check recent activity.
7. Mark any offline cache as uncertain where applicable.
8. Create security incident or device incident record.
9. Notify responsible owner.
10. Replace device only through approved registration.
11. Review whether customer identity, payment, or store data may have been exposed.

Lost device response must not be limited to buying a replacement.

---

## 27. Compromised Device Response

If a device is suspected compromised:

1. Revoke device trust.
2. Invalidate sessions.
3. Rotate credentials where applicable.
4. Quarantine recent events from the device if needed.
5. Review audit history.
6. Review POS/KDS events if runtime device.
7. Review support access if support workstation.
8. Review identity access if identity-capable device.
9. Create incident record.
10. Require re-registration or replacement before reuse.

A compromised device must not be silently trusted again.

---

## 28. Offline Cache And Device Loss

Devices may hold offline or local cache.

Offline cache risk must be considered for:

- Store Tablet
- POS Terminal
- KDS Device
- Local Agent
- Staff Mobile
- Owner Mobile
- Kiosk Device

If a lost or compromised device may contain offline cache:

- cache status must be marked uncertain
- affected scope must be reviewed
- credential rotation may be required
- customer identity exposure must be evaluated
- local queue integrity must be verified
- recovery evidence must be created

Offline cache must not be ignored during revocation.

---

## 29. Device Trust Audit Requirements

Audit is required for:

- device registration
- device approval
- device trust change
- device revocation
- lost device report
- compromised device report
- device replacement
- session creation for high-risk device
- session invalidation
- local agent promotion
- bridge credential rotation
- suspicious device access
- device access denied
- device reactivation

Audit must include:

- device id
- device role
- tenant id
- store id where applicable
- actor
- action
- previous trust state
- new trust state
- reason
- timestamp
- session ids affected where applicable
- credential rotation reference where applicable

Audit must not store secrets.

---

## 30. Suspicious Device Behavior

Suspicious device behavior must be detectable.

Examples:

- access from unexpected location
- access outside store context
- repeated failed authentication
- repeated tenant mismatch
- repeated store mismatch
- unusual support lookup
- unusual POS/KDS mutation attempt
- excessive retry or replay request
- KDS attempting payment mutation
- kiosk attempting admin action
- local agent attempting cross-store access
- revoked device attempting access
- device clock far outside expected range

Suspicious behavior should create security review event.

---

## 31. Device Capability Scope

Each device must have limited capabilities.

Examples:

### POS Terminal

Allowed:

- accepted order
- payment handoff
- transaction status
- POS/KDS ticket dispatch

Not allowed:

- support browsing
- raw CI/DI browsing
- cross-tenant access

### KDS Device

Allowed:

- kitchen execution state
- ticket visibility
- kitchen notes

Not allowed:

- payment correction
- refund
- settlement

### Store Tablet

Allowed:

- store operation control within user authority
- evidence attachment
- manager action where authenticated

Not allowed:

- bypassing reauthentication
- acting without user authority

### Local Agent

Allowed:

- provisional relay
- degraded queue
- evidence upload

Not allowed:

- final transaction mutation
- silent central overwrite

Capability scope must be enforced, not merely documented.

---

## 32. Device Replacement Policy

Device replacement must not inherit trust blindly.

Replacement must include:

- old device revocation
- new device registration
- approval where required
- credential rotation where needed
- session invalidation for old device
- offline cache review where applicable
- audit event

A new physical device must not simply reuse old credentials without review.

---

## 33. Shared Device Policy

Some store devices may be shared by multiple staff.

Shared device policy must ensure:

- user login remains separate
- staff action is attributed to user
- device identity is recorded
- session switch is controlled
- sensitive action requires user reauthentication
- idle session timeout exists
- logout is possible and visible

Shared device does not mean shared accountability.

---

## 34. Idle And Lock Policy

High-risk devices should support idle timeout or lock behavior.

Examples:

- Store Tablet
- POS Terminal
- HQ Admin Web
- Support Workstation
- Owner Mobile
- Local Agent Admin View

Idle timeout helps prevent unauthorized action when device is unattended.

Sensitive views should lock or require reauthentication after inactivity.

---

## 35. Device Data Minimization

Devices should receive only the data needed for their runtime role.

Examples:

- KDS does not need raw identity.
- Kiosk does not need admin data.
- Staff mobile does not need full owner dashboard.
- Local Agent does not need broad cross-tenant data.
- Support Workstation does not need secrets.
- POS does not need unrelated tenant data.

Device role must shape data visibility.

---

## 36. Secure Device Checklist

Before implementation, confirm:

- Device roles are defined.
- Device trust levels are defined.
- User role and device role are separated.
- Store Tablet is treated as high-authority.
- POS cannot expose server-only secrets.
- KDS cannot mutate payment state.
- Kiosk cannot access admin functions.
- Local Agent credential is scoped.
- Secondary Local Agent cannot overwrite Primary.
- Support Workstation is case-scoped.
- Device registration is audited.
- Device approval is audited.
- Device revocation is audited.
- Lost device triggers session invalidation.
- Compromised device triggers credential rotation review.
- Offline cache risk is reviewed during revocation.
- Sensitive actions require reauthentication.
- Shared device actions remain user-attributed.
- Device capability scope is enforced.
- Suspicious device behavior is detectable.

If any item fails, implementation must not proceed.

---

## 37. Non-Goals

This document does not define:

- final device registration UI
- final MDM solution
- final hardware vendor
- final POS terminal product
- final KDS device product
- final kiosk hardware
- final local agent hardware
- final biometric method
- final browser device fingerprinting method
- final mobile push security design
- final detailed session token implementation

Those must be defined in later runtime, security, admin, infrastructure, or implementation documents.

---

## 38. Readiness Check

This policy is ready when the project can answer:

1. What device roles exist?
2. Which devices require approval?
3. Which devices are high-risk?
4. How is device trust represented?
5. How is device trust separated from user authority?
6. What happens when Store Tablet is lost?
7. What happens when Staff Mobile is lost?
8. What happens when Owner Mobile is lost?
9. What happens when POS Terminal is replaced?
10. What happens when KDS Device is compromised?
11. What happens when Local Agent is compromised?
12. How are active sessions invalidated?
13. Which actions require reauthentication?
14. How is Secondary Local Agent promoted?
15. How is bridge credential revocation handled?
16. How is offline cache risk reviewed?
17. How are shared device actions attributed?
18. How is suspicious device behavior detected?
19. How are device trust changes audited?
20. How is device replacement controlled?

If these questions cannot be answered, implementation must not proceed.

---

## 39. Conclusion

Device trust is a core security boundary in the Yoonsul Wait/Order Handoff system.

The system operates across POS, KDS, Store Tablet, mobile devices, HQ web, support sessions, local agents, bridges, and kiosks.

Therefore, every device must be registered, scoped, trusted, monitored, and revocable according to its runtime role.

The system must preserve the following rules:

- device trust is not user authority
- trusted device still requires authorized user
- authorized user still requires trusted context for sensitive actions
- Store Tablet is high-authority
- POS owns transaction boundary
- KDS owns kitchen execution boundary
- Local Agent is provisional continuity support
- Support Workstation is case-scoped
- Kiosk is customer-facing and limited
- lost device triggers revocation
- compromised device triggers incident review
- sessions must not outlive revoked trust
- offline cache must be reviewed
- device trust changes must be audited

A secure runtime is not only about who logs in.

It is also about which device, which store, which tenant, which session, and which authority boundary is active.