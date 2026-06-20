# 005041_Policy_Device_Trust_Session_Revocation_Lost_Device_Test_Catalog

## 1. Purpose

This document defines the test catalog policy for device trust, device registration, device role boundary, device-scoped session, session freshness, session revocation, lost device response, compromised device response, suspicious device handling, Store Tablet authority, POS terminal scope, KDS device scope, staff mobile limits, owner mobile limits, support workstation control, local agent identity, bridge service identity, audit, evidence, and deployment gate requirements in the Yoonsul Wait/Order Handoff project.

Device trust is separate from user authority.

A valid user on an untrusted, revoked, stolen, compromised, or wrong-scope device must not be treated as safe.

Therefore, device trust behavior must have explicit positive tests, negative tests, abuse-case tests, revocation tests, lost device tests, compromised device tests, session tests, audit tests, evidence tests, and deployment gate tests before implementation is allowed.

This document does not implement device registration, session service, revocation logic, mobile app policy, POS/KDS device binding, local agent identity, RLS policies, or automated test code.

It defines the test catalog that future device trust implementation must satisfy.

---

## 2. Scope

This test catalog applies to:

- device registration
- device approval
- device trust state
- device role
- device-bound session
- session freshness
- session expiration
- session revocation
- trusted device access
- untrusted device denial
- revoked device denial
- lost device response
- compromised device response
- suspicious device review
- Store Tablet authority
- POS terminal scope
- KDS device scope
- staff mobile boundary
- owner mobile boundary
- support workstation boundary
- HQ admin device boundary
- kiosk device boundary
- local agent device identity
- bridge service identity
- offline cache behavior
- degraded mode device behavior
- audit
- evidence packet linkage
- deployment gate requirements
- implementation blockers

This document focuses on test catalog design, not device implementation.

---

## 3. Core Principle

User authority and device trust are separate controls.

The project must follow this rule:

> A valid role on an untrusted or revoked device is not enough. A trusted device with no valid role is also not enough. Access requires actor authority, device trust, session validity, context scope, and runtime permission.

Tests must prove device trust is enforced under normal, revoked, lost, compromised, offline, degraded, and wrong-device-role conditions.

---

## 4. Source Mapping Documents

This test catalog verifies constraints from:

- 04831_Implementation_Mapping_Lane_Start_And_Policy_To_Code_Constraint_Handoff_Policy
- 04841_Policy_Tenant_Store_Context_RLS_And_Access_Control_Implementation_Mapping
- 04851_Audit_Event_Taxonomy_Append_Only_And_Evidence_Implementation_Mapping_Policy
- 04861_Policy_POS_KDS_RPC_Bridge_Idempotency_Replay_Implementation_Mapping
- 04871_Policy_Payment_Webhook_Refund_Settlement_And_Reconciliation_Implementation_Mapping
- 04891_Policy_Support_Access_Masking_Break_Glass_And_Scoped_Session_Implementation_Mapping
- 04901_Policy_Device_Trust_Session_Revocation_Store_Runtime_And_Lost_Device_Implementation_Mapping
- 04911_Policy_Local_Agent_Degraded_Recovery_Sync_Conflict_And_Manual_Evidence_Implementation_Mapping
- 04951_Policy_Secure_Deployment_Environment_Separation_Release_Gate_And_Rollback_Implementation_Mapping
- 04971_Policy_Security_And_Runtime_Test_Catalog_Lane_Start_And_Verification_Governance
- 04981_Policy_Tenant_Store_RLS_Access_Control_Test_Catalog
- 04991_Audit_Append_Only_Evidence_And_Tamper_Resistance_Test_Catalog_Policy
- 05001_Policy_POS_KDS_RPC_Bridge_Idempotency_Replay_Test_Catalog
- 05031_Policy_Support_Access_Masking_Break_Glass_Scoped_Session_Test_Catalog

---

## 5. Affected Runtime

This test catalog affects:

- Customer Runtime
- Staff Runtime
- Store Tablet Runtime
- Owner Runtime
- HQ Admin Runtime
- Support Runtime
- POS Runtime
- KDS Runtime
- POS/KDS Bridge Runtime
- Payment Runtime
- Identity Runtime
- Local Agent Runtime
- Export Runtime
- AI Analytics Runtime
- Audit Runtime
- Incident Runtime
- Deployment Runtime

Device trust must be enforced consistently across all runtime entry points.

---

## 6. Risk Categories

This catalog covers the following risk categories:

- valid user on untrusted device
- valid user on revoked device
- trusted device with invalid user
- stolen Store Tablet access
- lost staff mobile access
- compromised support workstation access
- POS terminal wrong-store event
- KDS device wrong-store access
- local agent wrong identity
- bridge service credential misuse
- stale session remains active
- session not revoked after device loss
- offline cache leakage
- degraded mode bypassing device trust
- staff mobile performing Store Tablet action
- owner mobile performing restricted admin action
- support workstation accessing without case scope
- device role escalation
- device registration without approval
- device audit missing
- deployment weakening device controls

Critical failures in these categories block implementation.

---

## 7. Test Data Setup Requirement

Future tests should include at least:

- Tenant A
- Tenant B
- Store A1
- Store A2
- Store Tablet A1 trusted
- Store Tablet A1 lost
- Store Tablet A1 revoked
- POS Terminal A1 trusted
- POS Terminal A2 trusted
- KDS Device A1 trusted
- KDS Device A2 trusted
- Staff Mobile A1 trusted
- Staff Mobile untrusted
- Owner Mobile trusted
- Support Workstation trusted
- Support Workstation compromised
- HQ Admin Workstation trusted
- Kiosk Device A1
- Local Agent Primary A1
- Local Agent Secondary A1
- Bridge Service Identity A1
- Staff User A1
- Owner User A1
- Support Agent S
- HQ Operator
- Active session
- Expired session
- Revoked session
- Offline cache candidate
- Device incident candidate
- Audit event candidate
- Evidence packet candidate

Test data must include trusted, untrusted, revoked, lost, compromised, and wrong-scope devices.

---

## 8. Test ID Naming Rule

Recommended test id format:

    TC-DEVICE-[NUMBER]-[TYPE]

Examples:

    TC-DEVICE-001-POSITIVE
    TC-DEVICE-002-NEGATIVE
    TC-DEVICE-003-SESSION
    TC-DEVICE-004-REVOCATION
    TC-DEVICE-005-LOST
    TC-DEVICE-006-COMPROMISED
    TC-DEVICE-007-ROLE
    TC-DEVICE-008-AUDIT
    TC-DEVICE-009-DEPLOY

Final test IDs may change later.

Traceability must remain stable.

---

## 9. Positive Tests

### TC-DEVICE-001-POSITIVE: Trusted Store Tablet Allows Scoped Store Operation

Precondition:

- Store Tablet A1 is trusted.
- Staff or manager has valid Store A1 authority.
- Session is valid.

Action:

- Actor performs allowed Store A1 operation.

Expected result:

- Operation succeeds.
- Device identity is included in context.
- Store scope is enforced.
- Audit event is created where required.

Evidence:

- successful operation record
- device context record
- audit event where required

---

### TC-DEVICE-002-POSITIVE: Trusted POS Terminal Sends Store-Scoped POS Event

Precondition:

- POS Terminal A1 is trusted and bound to Store A1.
- POS event is valid.

Action:

- POS Terminal A1 sends accepted order event.

Expected result:

- Event is accepted.
- Tenant/store context is validated.
- Device identity is recorded.
- No wrong-store mutation occurs.

Evidence:

- POS event record
- device binding proof
- audit event

---

### TC-DEVICE-003-POSITIVE: Trusted KDS Device Updates Own Store Ticket

Precondition:

- KDS Device A1 is trusted and bound to Store A1.
- KDS ticket belongs to Store A1.

Action:

- KDS Device A1 updates allowed kitchen status.

Expected result:

- Update succeeds.
- Payment state is unchanged.
- Device identity is recorded.

Evidence:

- KDS status update
- payment unchanged proof
- device context record

---

### TC-DEVICE-004-POSITIVE: Support Workstation With Valid Case Scope Allows Masked Support View

Precondition:

- Support Workstation is trusted.
- Support Agent S is assigned to Case A1.
- Session is valid.

Action:

- Support Agent S views case.

Expected result:

- Case-scoped masked view is shown.
- Device identity and session are recorded.
- Audit event is created.

Evidence:

- support view sample
- session record
- audit event

---

## 10. Negative Tests

### TC-DEVICE-005-NEGATIVE: Valid User On Untrusted Device Is Denied For Protected Action

Precondition:

- User has valid role.
- Device is untrusted or unknown.

Action:

- User attempts protected staff/store/admin action.

Expected result:

- Access is denied.
- Role alone is insufficient.
- Audit event is created where required.

Failure severity:

- HIGH to CRITICAL depending action

Evidence:

- denial response
- device trust evaluation
- audit event

---

### TC-DEVICE-006-NEGATIVE: Trusted Device With Invalid User Is Denied

Precondition:

- Device is trusted.
- User lacks valid role or affiliation.

Action:

- User attempts protected action.

Expected result:

- Access is denied.
- Device trust alone is insufficient.

Failure severity:

- HIGH

Evidence:

- denial response
- role evaluation
- device context

---

### TC-DEVICE-007-NEGATIVE: Revoked Device Is Denied Even With Valid User

Precondition:

- Device was revoked.
- User has valid role.

Action:

- User attempts protected action from revoked device.

Expected result:

- Access is denied.
- Session is invalidated.
- Revocation audit is created.

Failure severity:

- CRITICAL

Evidence:

- denial response
- session invalidation record
- audit event

---

### TC-DEVICE-008-NEGATIVE: Staff Mobile Cannot Perform Store Tablet Only Action

Precondition:

- Staff Mobile is trusted.
- Staff user has store role.
- Action requires Store Tablet.

Action:

- Staff Mobile attempts Store Tablet-only action.

Expected result:

- Action is denied.
- Device role boundary is enforced.

Failure severity:

- HIGH

Evidence:

- denial response
- device role evaluation

---

### TC-DEVICE-009-NEGATIVE: Owner Mobile Cannot Perform Restricted Production Configuration Change

Precondition:

- Owner Mobile is trusted.
- Restricted configuration action requires stronger device or approval.

Action:

- Owner attempts restricted configuration from mobile.

Expected result:

- Action is denied or requires stronger approval/reauthentication.
- Audit event is created where required.

Failure severity:

- HIGH

Evidence:

- denial or approval-required result
- audit event

---

## 11. Device Registration Tests

### TC-DEVICE-010-REGISTRATION: New Device Starts Untrusted

Precondition:

- New device appears.

Action:

- Device attempts protected action before approval.

Expected result:

- Device is treated as untrusted.
- Protected access is denied.
- Registration or approval flow is required.

Failure severity:

- HIGH

Evidence:

- untrusted device record
- denial response

---

### TC-DEVICE-011-REGISTRATION: Device Approval Is Scoped

Precondition:

- New Store Tablet is approved for Store A1.

Action:

- Device attempts Store A2 operation.

Expected result:

- Store A2 action is denied.
- Approval scope remains Store A1.

Failure severity:

- HIGH

Evidence:

- approval record
- wrong-store denial

---

### TC-DEVICE-012-REGISTRATION: Device Role Cannot Be Self-Assigned

Precondition:

- Device is registered as Staff Mobile.

Action:

- Device attempts to self-change role to Store Tablet or POS Terminal.

Expected result:

- Role change is denied.
- Approval workflow is required.
- Audit event is created.

Failure severity:

- CRITICAL if self-escalation succeeds

Evidence:

- denial response
- device role unchanged
- audit event

---

### TC-DEVICE-013-REGISTRATION: Device Reapproval Requires Review After Risk State

Precondition:

- Device was marked lost, compromised, or suspicious.

Action:

- Device attempts reactivation.

Expected result:

- Device remains blocked until review/approval.
- Reactivation is audited.

Failure severity:

- HIGH

Evidence:

- reactivation denial or approval record
- audit event

---

## 12. Session Tests

### TC-DEVICE-014-SESSION: Device-Bound Session Includes Device Identity

Precondition:

- Actor signs in on trusted device.

Action:

- Protected action is performed.

Expected result:

- Session includes actor identity and device identity.
- Device context is used in access decision.

Evidence:

- session record
- access decision context

---

### TC-DEVICE-015-SESSION: Session Expires

Precondition:

- Session has expiration.

Action:

- Actor attempts action after expiration.

Expected result:

- Access is denied.
- Reauthentication is required.

Failure severity:

- HIGH

Evidence:

- expired session record
- denial response

---

### TC-DEVICE-016-SESSION: Sensitive Action Requires Fresh Session

Precondition:

- Session is valid but stale.
- Actor attempts sensitive action such as unmask, refund approval, role change, or device approval.

Action:

- Sensitive action is requested.

Expected result:

- Fresh reauthentication is required.
- Action does not proceed until freshness requirement is met.

Failure severity:

- HIGH

Evidence:

- reauthentication required result

---

### TC-DEVICE-017-SESSION: Revocation Invalidates Existing Sessions

Precondition:

- Device has active sessions.
- Device is revoked.

Action:

- Existing session attempts further action.

Expected result:

- Access is denied.
- Existing session is invalidated.

Failure severity:

- CRITICAL

Evidence:

- revocation record
- session invalidation record
- denial response

---

## 13. Lost Device Tests

### TC-DEVICE-018-LOST: Lost Store Tablet Is Immediately Blocked

Precondition:

- Store Tablet A1 is reported lost.
- It has active session or cached data.

Action:

- Lost device attempts access.

Expected result:

- Access is denied.
- Session is revoked.
- Device state is lost or revoked.
- Audit event and evidence record are created.

Failure severity:

- CRITICAL

Evidence:

- lost device record
- session revocation
- denial response
- audit event

---

### TC-DEVICE-019-LOST: Lost Staff Mobile Cannot Access Staff Runtime

Precondition:

- Staff Mobile is reported lost.

Action:

- Device attempts staff action.

Expected result:

- Access is denied.
- Session is revoked.
- Staff runtime access is blocked.

Failure severity:

- HIGH

Evidence:

- lost device record
- denial response

---

### TC-DEVICE-020-LOST: Lost Device Offline Cache Is Marked Risk

Precondition:

- Device is reported lost.
- Device previously had offline cache.

Action:

- Lost device response is processed.

Expected result:

- Offline cache risk is recorded.
- Incident or review path is created where required.
- No silent assumption of safety occurs.

Failure severity:

- HIGH

Evidence:

- offline cache risk record
- incident/review link

---

### TC-DEVICE-021-LOST: Replacement Device Does Not Inherit Trust Automatically

Precondition:

- Store Tablet A1 is lost.
- Replacement Store Tablet A1-R is introduced.

Action:

- Replacement attempts protected action.

Expected result:

- Replacement requires registration and approval.
- Lost device trust is not transferred automatically.

Failure severity:

- HIGH

Evidence:

- replacement registration record
- approval requirement

---

## 14. Compromised Device Tests

### TC-DEVICE-022-COMPROMISED: Compromised Device Is Revoked And Sessions Terminated

Precondition:

- Device is marked compromised.

Action:

- Containment runs.

Expected result:

- Device is revoked.
- Active sessions are terminated.
- Access is denied.
- Incident or security review is created.

Failure severity:

- CRITICAL

Evidence:

- compromised device record
- session termination
- incident/review record

---

### TC-DEVICE-023-COMPROMISED: Compromised Support Workstation Cannot Access Cases

Precondition:

- Support Workstation is marked compromised.
- Support agent has valid case assignment.

Action:

- Support agent attempts case access from compromised workstation.

Expected result:

- Access is denied.
- Case assignment does not override device compromise.

Failure severity:

- CRITICAL

Evidence:

- denial response
- device state record

---

### TC-DEVICE-024-COMPROMISED: Compromised POS Terminal Cannot Send Events

Precondition:

- POS Terminal A1 is marked compromised.

Action:

- POS Terminal A1 sends accepted order event.

Expected result:

- Event is denied or quarantined.
- No KDS ticket is created.
- Audit event is created.

Failure severity:

- CRITICAL

Evidence:

- quarantine or denial record
- no ticket proof
- audit event

---

### TC-DEVICE-025-COMPROMISED: Compromised KDS Device Cannot Update Ticket

Precondition:

- KDS Device A1 is compromised.

Action:

- KDS Device A1 attempts status update.

Expected result:

- Update is denied.
- Ticket remains unchanged.
- Audit event is created.

Failure severity:

- HIGH

Evidence:

- denial response
- ticket state unchanged
- audit event

---

## 15. Suspicious Device Tests

### TC-DEVICE-026-SUSPICIOUS: Suspicious Device Requires Review Before Sensitive Action

Precondition:

- Device is marked suspicious due to unusual activity.

Action:

- Actor attempts sensitive action.

Expected result:

- Action is denied or requires review/reauthentication.
- Suspicious status is visible to authorized reviewer.

Failure severity:

- HIGH

Evidence:

- denial or review-required result
- suspicious device record

---

### TC-DEVICE-027-SUSPICIOUS: Repeated Wrong-Store Attempts Mark Device Suspicious

Precondition:

- Device repeatedly attempts wrong-store access.

Action:

- Suspicious device detection runs.

Expected result:

- Device is marked suspicious or security review is triggered.
- Further access may be restricted.

Failure severity:

- HIGH

Evidence:

- suspicious marker
- security review record

---

### TC-DEVICE-028-SUSPICIOUS: Suspicious Device Event Creates Audit

Precondition:

- Suspicious device behavior occurs.

Action:

- Detection or review occurs.

Expected result:

- Audit event records suspicious device signal and affected scope.
- Audit excludes secrets.

Evidence:

- audit event

---

## 16. Device Role Boundary Tests

### TC-DEVICE-029-ROLE: Store Tablet Has High In-Store Authority But Store-Scoped

Precondition:

- Store Tablet A1 is trusted.
- Actor has Store A1 manager role.

Action:

- Actor performs allowed high in-store operation.

Expected result:

- Action succeeds only for Store A1.
- Store A2 action is denied.

Evidence:

- Store A1 success
- Store A2 denial

---

### TC-DEVICE-030-ROLE: POS Terminal Cannot Perform Admin Actions

Precondition:

- POS Terminal A1 is trusted.

Action:

- POS Terminal attempts admin configuration or export.

Expected result:

- Action is denied.
- POS terminal remains transaction-scoped.

Failure severity:

- HIGH

Evidence:

- denial response
- device role evaluation

---

### TC-DEVICE-031-ROLE: KDS Device Cannot Access Customer Identity Or Payment Detail

Precondition:

- KDS Device A1 is trusted.

Action:

- KDS Device requests customer identity or payment detail.

Expected result:

- Access is denied or limited to operational signal.
- Raw identity and payment secrets are not visible.

Failure severity:

- CRITICAL if sensitive data visible

Evidence:

- denial or masked response
- masking verification

---

### TC-DEVICE-032-ROLE: Kiosk Device Cannot Access Staff Or Admin Runtime

Precondition:

- Kiosk Device A1 is trusted for customer self-service.

Action:

- Kiosk attempts staff/admin/POS/KDS privileged action.

Expected result:

- Access is denied.
- Kiosk remains customer self-service scoped.

Failure severity:

- HIGH

Evidence:

- denial response

---

## 17. Local Agent Device Identity Tests

### TC-DEVICE-033-LOCALAGENT: Primary Local Agent Identity Is Store-Scoped

Precondition:

- Local Agent Primary A1 is registered for Store A1.

Action:

- Local Agent attempts Store A2 sync.

Expected result:

- Sync is denied or quarantined.
- No Store A2 state is changed.

Failure severity:

- CRITICAL

Evidence:

- sync denial
- audit event

---

### TC-DEVICE-034-LOCALAGENT: Secondary Local Agent Cannot Self-Promote

Precondition:

- Secondary Local Agent exists.

Action:

- Secondary attempts to promote itself to Primary without approved condition.

Expected result:

- Promotion is denied.
- Audit event is created.
- Primary state remains unchanged.

Failure severity:

- CRITICAL

Evidence:

- promotion denial
- audit event

---

### TC-DEVICE-035-LOCALAGENT: Promoted Primary Requires Evidence And Audit

Precondition:

- Primary is unavailable.
- Promotion condition is met.

Action:

- Secondary is promoted through approved workflow.

Expected result:

- Promoted Primary state is recorded.
- Evidence and audit exist.
- Recovery Pending status is tracked where applicable.

Evidence:

- promotion record
- evidence packet
- audit event

---

### TC-DEVICE-036-LOCALAGENT: Revoked Local Agent Cannot Sync

Precondition:

- Local Agent A1 is revoked.

Action:

- Local Agent attempts sync.

Expected result:

- Sync is denied.
- No local records are accepted.
- Audit event is created.

Failure severity:

- CRITICAL

Evidence:

- sync denial
- audit event

---

## 18. Bridge Service Identity Tests

### TC-DEVICE-037-BRIDGE: Bridge Service Identity Is Runtime-Scoped

Precondition:

- Bridge Service Identity A1 exists.

Action:

- Bridge service performs POS/KDS relay.

Expected result:

- Allowed relay succeeds.
- Non-bridge actions are denied.

Evidence:

- relay success
- non-bridge denial

---

### TC-DEVICE-038-BRIDGE: Bridge Credential Misuse Is Denied

Precondition:

- Bridge credential or service identity is used outside approved context.

Action:

- Request attempts unrelated payment/refund/export/admin action.

Expected result:

- Request is denied.
- Audit or incident candidate is created.

Failure severity:

- CRITICAL

Evidence:

- denial response
- audit event

---

### TC-DEVICE-039-BRIDGE: Revoked Bridge Identity Cannot Relay Events

Precondition:

- Bridge Service Identity A1 is revoked.

Action:

- Bridge attempts POS/KDS relay.

Expected result:

- Relay is denied.
- No mutation occurs.
- Audit event is created.

Failure severity:

- CRITICAL

Evidence:

- relay denial
- no mutation proof
- audit event

---

## 19. Offline Cache Tests

### TC-DEVICE-040-CACHE: Offline Cache Is Scoped To Device And Store

Precondition:

- Trusted Store Tablet A1 has offline cache for Store A1.

Action:

- Cache is accessed.

Expected result:

- Cache contains only allowed Store A1 data.
- Sensitive data is minimized.
- No Store A2 or Tenant B data exists.

Failure severity:

- CRITICAL if cross-tenant data cached

Evidence:

- cache scope inspection

---

### TC-DEVICE-041-CACHE: Revoked Device Cannot Sync Cached Data As Trusted

Precondition:

- Device has cached offline records.
- Device is revoked before sync.

Action:

- Device attempts to sync cache.

Expected result:

- Sync is denied or quarantined.
- Records are not accepted as trusted.
- Review may be required.

Failure severity:

- CRITICAL

Evidence:

- sync denial/quarantine record
- audit event

---

### TC-DEVICE-042-CACHE: Cache Uncertainty Is Visible After Offline Operation

Precondition:

- Device operates offline or degraded.

Action:

- Records are created locally.

Expected result:

- Cache uncertainty marker is present.
- Central verification required where applicable.

Failure severity:

- HIGH if treated as final verified state

Evidence:

- local record marker
- verification status

---

## 20. Degraded Mode Device Tests

### TC-DEVICE-043-DEGRADED: Degraded Mode Does Not Trust Revoked Device

Precondition:

- Store is in degraded mode.
- Device is revoked.

Action:

- Device attempts degraded operation.

Expected result:

- Access is denied.
- Degraded mode does not bypass revocation.

Failure severity:

- CRITICAL

Evidence:

- denial result
- degraded audit

---

### TC-DEVICE-044-DEGRADED: Degraded Device Action Is Marked Fallback-Originated

Precondition:

- Trusted device performs allowed degraded operation.

Action:

- Local record is created.

Expected result:

- Record is marked fallback-originated.
- Device identity is recorded.
- Central verification is required where applicable.

Evidence:

- local record
- fallback marker
- device context

---

### TC-DEVICE-045-DEGRADED: Lost Device Cannot Rejoin As Trusted After Network Recovery

Precondition:

- Device was reported lost during offline/degraded period.
- Network recovers.

Action:

- Device attempts to reconnect and sync.

Expected result:

- Device is denied.
- Sync is blocked or quarantined.
- Lost state remains until review.

Failure severity:

- CRITICAL

Evidence:

- reconnect denial
- sync quarantine
- audit event

---

## 21. Export And AI Device Boundary Tests

### TC-DEVICE-046-EXPORT: Device Role Does Not Grant Export Authority

Precondition:

- Store Tablet or Owner Mobile is trusted.
- Actor lacks export authority.

Action:

- Actor requests export.

Expected result:

- Export is denied.
- Device trust does not imply export authority.

Failure severity:

- HIGH

Evidence:

- export denial
- audit event

---

### TC-DEVICE-047-AI: Device Context Is Not Sent To AI With Secrets

Precondition:

- AI support or analytics summary includes device incident context.

Action:

- AI prompt/context is generated.

Expected result:

- Device state and role may be summarized.
- Device credential, session token, auth header, local agent secret, and bridge credential are excluded.

Failure severity:

- CRITICAL if secrets enter AI

Evidence:

- AI context inspection

---

## 22. Audit Tests

### TC-DEVICE-048-AUDIT: Device Registration Creates Audit

Precondition:

- Device is registered or approved.

Action:

- Device approval occurs.

Expected result:

- Audit event records device id, role, scope, approver, and result.

Evidence:

- audit event

---

### TC-DEVICE-049-AUDIT: Device Revocation Creates Audit

Precondition:

- Device is revoked.

Action:

- Revocation is applied.

Expected result:

- Audit event records actor, reason, device, scope, affected sessions, and result.

Failure severity:

- HIGH if missing

Evidence:

- audit event

---

### TC-DEVICE-050-AUDIT: Lost Device Response Creates Evidence And Audit

Precondition:

- Device is reported lost.

Action:

- Lost device workflow runs.

Expected result:

- Audit records report, revocation, session invalidation, and offline cache risk.
- Evidence packet is created where required.

Evidence:

- audit sequence
- evidence packet

---

### TC-DEVICE-051-AUDIT: Compromised Device Response Creates Incident Audit

Precondition:

- Device is marked compromised.

Action:

- Containment runs.

Expected result:

- Audit records compromised marker, revocation, session termination, and incident reference.

Failure severity:

- HIGH if missing

Evidence:

- audit event
- incident reference

---

## 23. Evidence Packet Tests

### TC-DEVICE-052-EVIDENCE: Lost Device Evidence Packet Contains Required Records

Precondition:

- Lost device incident occurs.

Action:

- Evidence packet is created.

Expected result:

- Packet includes device record, report time, actor, scope, active sessions, revocation, offline cache risk, audit references, and containment status.

Evidence:

- lost device evidence packet

---

### TC-DEVICE-053-EVIDENCE: Compromised Device Evidence Packet Links Incident

Precondition:

- Compromised device incident occurs.

Action:

- Evidence packet is created.

Expected result:

- Packet links device state, suspicious activity, containment, session revocation, incident record, and audit references.

Evidence:

- compromised device evidence packet

---

### TC-DEVICE-054-EVIDENCE: Local Agent Promotion Evidence Packet Is Complete

Precondition:

- Secondary local agent promotion occurs.

Action:

- Evidence packet is generated.

Expected result:

- Packet includes promotion trigger, approval or condition, old Primary status, new Promoted Primary status, audit, and recovery pending marker.

Evidence:

- promotion evidence packet

---

## 24. Deployment Gate Tests For Device Trust

### TC-DEVICE-055-DEPLOY: Device Trust Release Requires Revocation Tests

Precondition:

- Release changes device trust or session revocation behavior.

Action:

- Release gate evaluates deployment.

Expected result:

- Release is blocked unless revocation tests exist and are passing or approved.

Failure severity:

- CRITICAL

Evidence:

- release gate result
- revocation test reference

---

### TC-DEVICE-056-DEPLOY: Store Runtime Release Requires Device Role Boundary Tests

Precondition:

- Release changes Store Tablet, POS, KDS, staff mobile, or owner mobile behavior.

Action:

- Release gate evaluates device role tests.

Expected result:

- Release is blocked unless device role boundary tests exist.

Failure severity:

- HIGH

Evidence:

- release gate result

---

### TC-DEVICE-057-DEPLOY: Local Agent Release Requires Device Identity Tests

Precondition:

- Release changes local agent behavior.

Action:

- Release gate evaluates local agent device identity tests.

Expected result:

- Release is blocked unless local agent scope, promotion, revocation, and sync tests exist.

Failure severity:

- CRITICAL

Evidence:

- release gate result
- local agent test reference

---

### TC-DEVICE-058-DEPLOY: Support Release Requires Trusted Workstation And Session Tests

Precondition:

- Release changes support workstation or support session behavior.

Action:

- Release gate evaluates support device tests.

Expected result:

- Release is blocked unless support workstation trust, device revocation, and session invalidation tests exist.

Failure severity:

- HIGH

Evidence:

- release gate result

---

## 25. Regression Tests

Regression tests should be created for every device trust failure.

Regression candidates:

- valid user accessed from untrusted device
- revoked device accessed runtime
- lost Store Tablet remained active
- staff mobile performed Store Tablet action
- POS terminal created wrong-store order
- KDS device viewed wrong-store ticket
- support workstation compromised but still accessed cases
- session remained active after device revocation
- local agent self-promoted
- revoked local agent synced records
- bridge service identity performed refund/export/admin action
- offline cache leaked unrelated tenant/store data
- degraded mode bypassed device trust
- device credential appeared in log, export, audit, or AI
- release skipped device revocation tests

Every device trust incident should generate a regression test.

---

## 26. Coverage Matrix

Recommended coverage matrix:

| Area | Positive | Negative | Session | Revocation | Lost | Compromised | Audit | Deploy |
| ---- | -------- | -------- | ------- | ---------- | ---- | ----------- | ----- | ------ |
| Store Tablet | Required | Required | Required | Required | Required | Required | Required | Required |
| POS Terminal | Required | Required | Required | Required | Conditional | Required | Required | Required |
| KDS Device | Required | Required | Required | Required | Conditional | Required | Required | Required |
| Staff Mobile | Required | Required | Required | Required | Required | Conditional | Required | Conditional |
| Owner Mobile | Required | Required | Required | Required | Required | Conditional | Required | Conditional |
| Support Workstation | Required | Required | Required | Required | Conditional | Required | Required | Required |
| HQ Admin Device | Required | Required | Required | Required | Conditional | Required | Required | Conditional |
| Kiosk Device | Required | Required | Required | Required | Conditional | Conditional | Required | Conditional |
| Local Agent | Required | Required | Required | Required | Conditional | Required | Required | Required |
| Bridge Service Identity | Required | Required | N/A | Required | N/A | Required | Required | Conditional |
| Offline Cache | Required | Required | N/A | Required | Required | Required | Required | Conditional |

Coverage gaps become blockers.

---

## 27. Evidence Requirements

Evidence must prove:

- trusted Store Tablet allows scoped operation
- trusted POS terminal sends only scoped events
- trusted KDS device updates only scoped tickets
- support workstation requires trust and case scope
- valid user on untrusted device is denied
- trusted device with invalid user is denied
- revoked device is denied
- device role boundary is enforced
- new device starts untrusted
- device approval is scoped
- device role cannot be self-assigned
- device-bound session includes device identity
- session expires
- sensitive action requires fresh session
- revocation invalidates sessions
- lost device is blocked
- lost device offline cache risk is recorded
- replacement device does not inherit trust
- compromised device is revoked
- suspicious device triggers review
- Store Tablet, POS, KDS, kiosk, staff mobile, owner mobile boundaries are enforced
- local agent identity is scoped
- Secondary cannot self-promote
- revoked local agent cannot sync
- bridge service identity is runtime-scoped
- offline cache is scoped and uncertain
- degraded mode does not bypass revocation
- device trust does not imply export authority
- AI does not receive device/session secrets
- device audit events exist
- evidence packets link device, session, revocation, incident, and audit
- release gates block unsafe device trust changes

Evidence must not expose device credentials, session tokens, service secrets, raw auth headers, local agent secrets, bridge credentials, payment secrets, or raw CI / DI.

---

## 28. Failure Severity

Critical failures include:

- revoked device can access runtime
- lost Store Tablet remains active
- compromised device accesses support/payment/identity/admin runtime
- POS terminal creates wrong-store event
- KDS device mutates payment or accesses sensitive identity/payment data
- local agent self-promotes without authority
- revoked local agent syncs records
- bridge service identity performs refund/export/admin action
- offline cache contains cross-tenant data
- degraded mode bypasses device revocation
- device/session credential leaks into logs, export, audit, or AI

High failures include:

- valid user on untrusted device can perform protected action
- staff mobile performs Store Tablet-only action
- owner mobile performs restricted configuration without gate
- session does not expire
- sensitive action does not require fresh session
- assignment/device revocation does not invalidate session
- suspicious device is not reviewed
- replacement device inherits trust automatically
- device audit missing for revocation/loss/compromise
- release lacks device boundary tests

Medium failures include:

- non-sensitive device metadata displayed too broadly
- minor audit category mismatch
- safe device error wording unclear but non-leaking

Critical and high failures block implementation.

---

## 29. Implementation Blockers

Implementation must be blocked if:

- trusted device positive tests are missing
- untrusted device denial tests are missing
- revoked device denial tests are missing
- device role boundary tests are missing
- device registration/approval tests are missing
- session expiration tests are missing
- fresh session tests are missing
- session revocation tests are missing
- lost device tests are missing
- compromised device tests are missing
- suspicious device tests are missing
- Store Tablet authority tests are missing
- POS terminal scope tests are missing
- KDS device scope tests are missing
- staff mobile/owner mobile boundary tests are missing
- support workstation tests are missing
- local agent identity tests are missing
- bridge service identity tests are missing
- offline cache tests are missing
- degraded mode device tests are missing
- export/AI device secret exclusion tests are missing
- audit tests are missing
- evidence packet tests are missing
- deployment gate tests are missing

These blockers must be added to the implementation blocker register.

---

## 30. Test Status Values

Recommended status values:

- `NOT_DEFINED`
- `DRAFT`
- `MAPPED`
- `READY_FOR_REVIEW`
- `READY_FOR_IMPLEMENTATION`
- `IMPLEMENTED`
- `PASS`
- `FAIL`
- `BLOCKED`
- `WAIVED_WITH_APPROVAL`
- `DEFERRED`
- `OBSOLETE`

Critical device trust tests should not be waived unless the device-related feature is removed from implementation scope.

---

## 31. Non-Goals

This document does not define:

- final device table
- final device registration UI
- final session service
- final revocation engine
- final Store Tablet app behavior
- final POS terminal adapter
- final KDS device adapter
- final staff mobile app
- final owner mobile app
- final support workstation policy
- final local agent implementation
- final bridge service credential system
- final offline cache implementation
- final automated test code
- final production deployment

Those belong to later controlled implementation phase.

---

## 32. Readiness Check

This test catalog is ready when the project can answer:

1. How is trusted Store Tablet access tested?
2. How is POS terminal scope tested?
3. How is KDS device scope tested?
4. How is support workstation trust tested?
5. How is valid user on untrusted device denied?
6. How is trusted device with invalid user denied?
7. How is revoked device denied?
8. How are device role boundaries tested?
9. How does new device start untrusted?
10. How is device approval scoped?
11. How is device role self-escalation denied?
12. How is session bound to device?
13. How does session expire?
14. How is fresh session required for sensitive action?
15. How does revocation invalidate existing sessions?
16. How is lost Store Tablet blocked?
17. How is lost staff mobile blocked?
18. How is offline cache risk recorded?
19. How does replacement device require approval?
20. How is compromised device contained?
21. How is suspicious device reviewed?
22. How is Store Tablet high authority still store-scoped?
23. How is POS terminal admin action denied?
24. How is KDS sensitive access denied?
25. How is kiosk boundary tested?
26. How is local agent identity scoped?
27. How is local agent promotion tested?
28. How is bridge service identity scoped?
29. How is offline cache scope tested?
30. How does degraded mode avoid device trust bypass?
31. How is export authority separated from device trust?
32. How are device/session secrets excluded from AI?
33. How are device audit events tested?
34. How are device evidence packets tested?
35. How do release gates protect device trust changes?
36. What regression tests are required?
37. What evidence is required?
38. What failures are critical?
39. What blocks implementation?

If these questions cannot be answered, device trust session revocation lost device test catalog is incomplete.

---

## 33. Conclusion

Device trust is a separate security control in the Yoonsul Wait/Order Handoff project.

The system must preserve the following rules:

- user authority and device trust are separate
- trusted device alone is not enough
- valid user alone is not enough
- sessions must be device-bound
- sessions must expire
- sensitive actions may require fresh session
- revoked devices must be denied
- lost devices must be blocked
- compromised devices must be contained
- suspicious devices must trigger review
- Store Tablet has high in-store authority but remains store-scoped
- staff mobile cannot perform Store Tablet-only actions
- owner mobile cannot bypass restricted gates
- POS terminal is transaction-scoped
- KDS device is kitchen-scoped
- KDS must not access raw identity or payment secrets
- kiosk remains customer self-service scoped
- local agent identity must be scoped
- Secondary local agent cannot self-promote
- bridge service identity must not exceed bridge authority
- offline cache must be scoped and marked uncertain
- degraded mode must not bypass device revocation
- device trust does not grant export authority
- device/session secrets must not enter logs, audit, export, or AI
- device lifecycle actions must be audited
- evidence packets must link device, session, revocation, incident, and audit
- deployment gates must block unsafe device trust changes
- critical failures block implementation

This document does not implement device trust tests.

It defines the device trust session revocation lost device test catalog that future implementation must satisfy.