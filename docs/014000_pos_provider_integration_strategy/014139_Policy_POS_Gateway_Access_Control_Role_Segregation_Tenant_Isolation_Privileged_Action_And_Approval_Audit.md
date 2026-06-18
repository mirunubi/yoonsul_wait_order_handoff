# 014139_Policy_POS_Gateway_Access_Control_Role_Segregation_Tenant_Isolation_Privileged_Action_And_Approval_Audit

## 1. Purpose

This document defines the access control, role segregation, tenant isolation, privileged action, and approval audit policy for the POS Gateway.

The POS Gateway handles transaction-critical and evidence-sensitive operations.  
It can affect orders, payments, refunds, cancellations, receipts, settlement evidence, provider routing, menu mapping, availability, customer communication, incidents, and reconciliation.

Therefore, access control must not be treated as a simple login check.

This policy exists to ensure that:

- users can access only the tenant, store, role, and action scope they are authorized for;
- privileged actions require stronger controls;
- tenant isolation prevents cross-tenant data exposure;
- store-level staff cannot affect other stores without explicit authority;
- refunds, cancellations, overrides, routing changes, and evidence exports are approval-controlled;
- access decisions are auditable;
- emergency access is controlled, time-bounded, and reviewed;
- internal operators, tenant admins, store staff, support users, and technical users operate under separated authority.

---

## 2. Scope

This policy applies to all POS Gateway access-controlled surfaces, including:

- Admin Console;
- Store Operations Console;
- Staff Tablet;
- Manager Approval UI;
- Support Console;
- Reconciliation Console;
- Incident Console;
- Provider Configuration Console;
- Credential Reference Console;
- Monitoring Dashboard;
- Evidence Archive;
- API endpoints;
- worker/admin tasks;
- automation jobs;
- manual fallback tools;
- audit/evidence export tools.

This document governs authorization, role segregation, tenant/store isolation, privileged action approval, access audit, and emergency access for POS Gateway operations.

---

## 3. Core Principle

POS Gateway access must be least-privilege, scoped, auditable, and reversible.

The system must know:

```text
who is acting
which tenant they belong to
which store they are acting on
which role they are using
which device/session they are using
which action they are attempting
whether the action is privileged
whether approval is required
whether the action affects money, customer, evidence, or routing
whether the action is allowed under current restrictions
```

If access scope is uncertain, the action must be denied or require stronger verification.

---

## 4. Access Scope Model

Every access decision must include scope.

Required scope dimensions:

```text
actor_id
actor_type
tenant_id
store_id
role_id
permission_id
device_id
session_id
action_type
resource_type
resource_id
transaction_id
provider_code
approval_requirement
risk_level
created_at
```

Access must not be granted globally unless the role is explicitly designed for global platform operation.

---

## 5. Actor Type Model

The POS Gateway must distinguish actor types.

Recommended actor types:

| Actor Type | Description |
|---|---|
| `platform_admin` | Internal platform-level administrator |
| `platform_operator` | Internal operational support user |
| `technical_operator` | Internal technical/runtime operator |
| `security_operator` | Internal security/access control user |
| `reconciliation_owner` | User responsible for reconciliation and settlement review |
| `incident_commander` | User responsible for incident response |
| `tenant_admin` | Tenant-level administrator |
| `tenant_operator` | Tenant-level operations user |
| `store_manager` | Store-level manager |
| `shift_lead` | Store-level delegated manager during shift |
| `cashier` | Front/payment handling role |
| `front_staff` | Customer-facing order handling role |
| `kitchen_staff` | KDS/preparation role |
| `support_agent` | Customer or store support role |
| `system_worker` | Background job or worker identity |
| `provider_service` | External provider callback or service actor |

Actor type must be part of access evaluation.

---

## 6. Role Segregation Policy

Roles must be separated by responsibility.

The system must avoid giving one operational role unrestricted access to:

- provider routing;
- credential references;
- refunds;
- cancellations;
- manual adjustments;
- evidence export;
- tenant configuration;
- store configuration;
- audit log access;
- reconciliation closure;
- incident closure;
- restriction removal.

Role segregation must preserve accountability and prevent accidental or abusive changes.

---

## 7. Tenant Isolation Policy

Tenant isolation is mandatory.

A tenant user must not access:

- another tenant’s store configuration;
- another tenant’s transaction records;
- another tenant’s customer disputes;
- another tenant’s provider credentials or credential references;
- another tenant’s reconciliation cases;
- another tenant’s incident records;
- another tenant’s evidence archive;
- another tenant’s staff records;
- another tenant’s dashboard data.

Tenant isolation must apply to:

- UI views;
- API queries;
- background jobs;
- exports;
- logs;
- metrics;
- support tools;
- cached data;
- notifications.

Cross-tenant access is allowed only for platform roles with explicit purpose, audit, and scope.

---

## 8. Store Isolation Policy

Store-level isolation is mandatory.

A store user must not access or modify another store’s:

- orders;
- payments;
- cancellations;
- refunds;
- receipts;
- table sessions;
- QR/NFC objects;
- kiosk devices;
- staff actions;
- menu overrides;
- sold-out state;
- manual fallback cases;
- incidents;
- reconciliation cases.

Tenant-level roles may access multiple stores only when explicitly authorized.

Store manager authority must be scoped to assigned stores.

---

## 9. Resource Permission Model

Permissions must be resource-specific.

Recommended resource categories:

```text
order
payment
cancel
refund
receipt
menu_mapping
price_rule
availability
table_session
qr_nfc_object
kiosk_device
staff_device
provider_route
credential_reference
runtime_flag
manual_fallback
manager_approval
reconciliation_case
incident_case
customer_dispute
evidence_archive
audit_event
monitoring_dashboard
onboarding_record
rollout_record
```

Each resource category must define read, create, update, approve, export, and close permissions where applicable.

---

## 10. Privileged Action Classification

Certain actions must be classified as privileged.

Privileged actions include:

- refund execution;
- refund completion confirmation;
- cancellation after payment;
- manual price adjustment;
- manual discount override;
- manual POS correction;
- manual reconciliation adjustment;
- accounting export release;
- reconciliation case closure;
- incident closure for S3 or higher;
- provider route change;
- fallback route removal;
- production flag change;
- credential reference activation;
- restriction removal;
- QR/NFC object reassignment;
- table/session correction after payment;
- evidence export;
- audit evidence access for sensitive cases;
- legal/forensic hold release;
- emergency override removal.

Privileged actions require additional controls.

---

## 11. Approval Requirement Policy

Privileged actions may require approval.

Approval requirement must consider:

- action type;
- amount;
- tenant;
- store;
- role;
- risk level;
- customer impact;
- financial impact;
- incident linkage;
- reconciliation state;
- business day status;
- time of day;
- current restrictions;
- prior failed attempts.

Approval may be:

```text
not_required
self_allowed_with_audit
manager_approval_required
second_approval_required
platform_approval_required
security_approval_required
reconciliation_owner_required
incident_commander_required
blocked
```

Approval policy must be machine-readable where possible.

---

## 12. Two-Person Control

High-risk actions may require two-person control.

Actions that may require two-person control:

- high-value refund;
- refund after provider state uncertainty;
- reconciliation closure with known variance;
- accounting export release after variance;
- provider route change in production;
- production credential activation;
- restriction removal for refund automation;
- legal/forensic hold release;
- evidence export for legal or regulatory purpose;
- emergency override removal after incident.

The requester and approver should be different actors unless a documented emergency exception exists.

---

## 13. Reauthentication Policy

Sensitive actions should require reauthentication.

Reauthentication may be required for:

- refund;
- cancellation after payment;
- manager approval;
- provider route change;
- production flag change;
- credential reference action;
- evidence export;
- audit log access;
- emergency override removal;
- restriction removal;
- manual accounting adjustment.

Reauthentication must be recorded with action audit.

---

## 14. Session and Device Trust

Access decisions must consider session and device trust.

Session/device signals:

- authenticated actor;
- active role;
- store assignment;
- device ID;
- device trust status;
- session age;
- last activity;
- network or location risk where applicable;
- suspicious behavior;
- offline mode;
- lost/compromised device status.

Untrusted devices must not perform privileged actions.

Offline mode must restrict financial and evidence-sensitive actions unless a controlled offline policy exists.

---

## 15. Background Worker Authority

System workers must have explicit authority.

Worker identities must be scoped by:

- tenant;
- store;
- provider;
- job type;
- resource type;
- environment;
- credential reference;
- runtime mode.

Workers must not use human admin credentials.

Worker actions must emit audit events when they affect transaction state, retries, reconciliation, refunds, cancellations, routing, or evidence lifecycle.

---

## 16. Provider Callback Access

Provider callbacks and webhooks must be authenticated and scoped.

Provider callback validation must include:

- provider identity;
- signature or equivalent verification;
- tenant/store mapping;
- event type;
- replay protection;
- timestamp freshness;
- credential or secret rotation state;
- allowed event scope.

Invalid provider callbacks must be rejected and logged.

A provider callback must not update another tenant/store due to ambiguous mapping.

---

## 17. Support Access Policy

Support users may need access to customer or transaction evidence, but access must be limited.

Support access must be scoped by:

- assigned tenant/store;
- customer dispute case;
- incident case;
- support ticket;
- time-bound session;
- allowed evidence type;
- redaction level.

Support users should see customer-safe and support-necessary evidence, not raw provider secrets, credential references, or unrelated transaction data.

---

## 18. Reconciliation Access Policy

Reconciliation owners require access to financial comparison evidence.

Allowed access may include:

- order/payment/cancel/refund evidence;
- receipt references;
- settlement records;
- closing reports;
- manual fallback records;
- adjustment records;
- provider escalation responses;
- calculation snapshots;
- accounting export blocks.

Reconciliation owners must not automatically gain credential management or provider route change authority.

---

## 19. Incident Access Policy

Incident commanders require temporary broad access to affected scope.

Incident access must be:

- linked to incident ID;
- scoped to affected tenant/store/provider;
- time-bounded;
- logged;
- reviewed after incident closure.

Incident access must not become permanent elevated access.

---

## 20. Evidence Archive Access Policy

Evidence archive access is sensitive.

Access must depend on:

- evidence class;
- sensitivity level;
- case linkage;
- user role;
- tenant/store scope;
- approval requirement;
- legal/forensic hold state.

Evidence export must require stronger controls than evidence view.

Raw payload or sealed evidence access must require special approval.

---

## 21. Emergency Access Policy

Emergency access may be required during severe incidents.

Emergency access may allow:

- route disablement;
- rollback action;
- evidence preservation;
- incident containment;
- provider escalation packet creation;
- temporary dashboard access;
- manual fallback activation.

Emergency access must be:

- time-bounded;
- reason-coded;
- incident-linked;
- logged;
- reviewed after use.

Emergency access must not allow silent deletion, evidence alteration, or unrestricted refund execution unless specifically approved under emergency refund policy.

---

## 22. Break-Glass Policy

Break-glass access is the highest emergency access mode.

Break-glass may be used only when:

- normal approval flow is unavailable;
- customer or financial harm is imminent;
- active production routing is unsafe;
- incident commander or authorized owner declares emergency;
- action is necessary to contain harm.

Break-glass must create:

```text
break_glass_id
actor_id
reason
incident_id
affected_scope
started_at
expires_at
actions_performed
review_required_by
status
```

Break-glass usage must trigger mandatory post-event review.

---

## 23. Access Audit Event Requirements

Every sensitive access or action must emit audit event.

Required audit fields:

```text
audit_event_id
actor_id
actor_type
role_id
tenant_id
store_id
device_id
session_id
resource_type
resource_id
action_type
permission_result
approval_id
risk_level
before_state
after_state
reason
created_at
```

Denied privileged actions should also be logged when security or abuse risk exists.

---

## 24. Approval Audit Record

Every approval must create an approval record.

Required fields:

```text
approval_id
requester_id
approver_id
tenant_id
store_id
resource_type
resource_id
action_type
approval_type
approval_reason
risk_level
requested_at
approved_at
expires_at
status
```

Approval must be linked to the final action.  
An approval that is not used must expire.

---

## 25. Permission Denial Handling

When access is denied, the system must respond safely.

User-facing denial should include:

- that the action is not permitted;
- whether manager approval is required;
- whether the user lacks store scope;
- whether the action is blocked by restriction;
- who may approve or handle the action where appropriate.

Denial messages must not expose sensitive tenant, provider, or security details.

---

## 26. Access Review

Access rights must be reviewed periodically.

Review triggers:

- staff role change;
- staff termination;
- tenant contract change;
- store ownership change;
- incident involving manual action;
- repeated denied privileged actions;
- emergency access use;
- provider credential change;
- rollout to new store;
- role template change.

Access review must remove stale privileges.

---

## 27. Segregation of Duties

Certain duties should be segregated.

Recommended segregation:

- person who requests refund should not approve high-value refund;
- person who creates manual adjustment should not close reconciliation case alone;
- person who changes provider route should not alone approve production cutover;
- person who exports evidence should not approve legal hold release alone;
- support agent should not directly alter payment/refund state;
- technical operator should not silently modify accounting closure.

Segregation may be relaxed only under documented early-stage or emergency policy with audit.

---

## 28. Tenant Admin Boundary

Tenant admins may manage tenant-level operational configuration, but must not automatically control platform-sensitive functions.

Tenant admin may be allowed to:

- view tenant stores;
- manage store contacts;
- view permitted dashboards;
- approve certain store operations;
- assign tenant/store roles within permitted scope;
- view tenant-level incidents and reconciliation summaries.

Tenant admin must not automatically:

- view raw provider credentials;
- access other tenant data;
- change platform adapter code;
- export sealed evidence;
- bypass refund/cancellation controls;
- remove platform-imposed restrictions;
- alter audit events.

---

## 29. Store Manager Boundary

Store manager authority is store-scoped.

Store manager may be allowed to:

- approve manual fallback;
- approve normal refund/cancellation within threshold;
- mark sold-out items;
- approve table/session correction;
- view store transaction state;
- view store incidents;
- coordinate staff operation.

Store manager must not automatically:

- change provider route;
- activate production credentials;
- close accounting export;
- access other stores;
- export sensitive evidence without permission;
- remove platform restrictions.

---

## 30. Technical Operator Boundary

Technical operators may manage runtime diagnostics and routing controls, but financial actions must remain constrained.

Technical operator may be allowed to:

- view adapter health;
- inspect safe logs;
- disable unsafe route;
- pause retry worker;
- trigger reconciliation rerun;
- create provider escalation packet;
- apply emergency containment.

Technical operator must not automatically:

- approve refund;
- alter transaction amount;
- close reconciliation variance;
- edit customer communication outcome;
- access raw customer data beyond need;
- view raw secrets outside secure secret system.

---

## 31. Monitoring Requirements

Access control must be monitored.

Required metrics:

- privileged action attempts;
- privileged action approvals;
- denied action count;
- cross-tenant access attempts;
- cross-store access attempts;
- emergency access count;
- break-glass usage count;
- expired approval usage attempt;
- stale role count;
- sensitive evidence export count;
- raw payload access count;
- suspicious access pattern count.

Critical access anomalies must alert security or operations owner.

---

## 32. Dashboard Requirements

Access governance dashboard must show:

- active privileged roles;
- pending approvals;
- high-risk approvals;
- emergency access sessions;
- break-glass sessions;
- recent sensitive evidence exports;
- denied privileged actions;
- cross-scope access attempts;
- stale role assignments;
- access review due list;
- segregation-of-duties exceptions.

Dashboard must not expose sensitive evidence content unnecessarily.

---

## 33. Incident Requirements

Access control incidents may include:

- unauthorized refund attempt;
- cross-tenant data exposure;
- staff accessing wrong store;
- privileged action without approval;
- break-glass misuse;
- stale account used;
- lost device used for action;
- support user over-access;
- evidence export without approval;
- provider callback spoof attempt;
- worker authority misconfiguration.

Incidents must classify:

- customer impact;
- financial impact;
- privacy impact;
- audit impact;
- tenant impact;
- security impact.

---

## 34. Prohibited Practices

The following practices are prohibited:

- granting global admin access for convenience;
- using shared staff accounts;
- using human admin credentials for workers;
- allowing store staff to access another store by URL manipulation;
- allowing tenant admin to bypass platform restrictions;
- allowing refund approval without actor identity;
- allowing privileged action without audit event;
- allowing emergency access without review;
- exposing raw credentials in support console;
- exporting evidence without purpose and access log;
- closing reconciliation case by the same actor who made high-risk adjustment without approval.

---

## 35. Minimum Acceptance Criteria

Access control and role segregation is acceptable only when:

- access scope model exists;
- actor type model exists;
- role segregation policy exists;
- tenant and store isolation are enforced;
- resource-specific permissions exist;
- privileged actions are classified;
- approval requirements are defined;
- two-person control exists for high-risk actions;
- reauthentication policy exists;
- session/device trust is considered;
- worker and provider callback authority are scoped;
- support/reconciliation/incident/evidence archive access policies exist;
- emergency and break-glass access are controlled;
- access and approval audit records exist;
- access review and segregation-of-duties policies exist;
- monitoring, dashboard, and incident handling exist.

---

## 36. Implementation Notes

Recommended implementation artifacts:

```text
pos_gateway_actor_types
pos_gateway_roles
pos_gateway_permissions
pos_gateway_role_assignments
pos_gateway_authority_scopes
pos_gateway_privileged_actions
pos_gateway_approval_policies
pos_gateway_approval_records
pos_gateway_access_audit_events
pos_gateway_device_trust_access_rules
pos_gateway_worker_authority_scopes
pos_gateway_provider_callback_authorizations
pos_gateway_emergency_access_sessions
pos_gateway_break_glass_records
pos_gateway_access_reviews
pos_gateway_segregation_exceptions
pos_gateway_access_incidents
```

Recommended services:

```text
AccessScopeService
RolePermissionService
TenantIsolationGuard
StoreIsolationGuard
PrivilegedActionService
ApprovalPolicyService
ApprovalAuditService
TwoPersonControlService
ReauthenticationService
DeviceTrustAccessService
WorkerAuthorityService
ProviderCallbackAuthService
SupportAccessService
EvidenceArchiveAccessService
EmergencyAccessService
BreakGlassService
AccessReviewService
SegregationOfDutiesService
AccessMonitoringService
```

Recommended event types:

```text
pos_gateway.access.permission_granted
pos_gateway.access.permission_denied
pos_gateway.access.privileged_action_requested
pos_gateway.access.approval_requested
pos_gateway.access.approval_granted
pos_gateway.access.approval_denied
pos_gateway.access.privileged_action_executed
pos_gateway.access.cross_tenant_attempt_detected
pos_gateway.access.cross_store_attempt_detected
pos_gateway.access.emergency_access_started
pos_gateway.access.break_glass_started
pos_gateway.access.break_glass_ended
pos_gateway.access.review_required
pos_gateway.access.incident_detected
```

---

## 37. Relationship To Adjacent Documents

This document is related to:

- 06130 POS Gateway data retention, archive, privacy, redaction, and forensic evidence lifecycle policy;
- 06120 POS Gateway reconciliation case workflow, variance resolution, manual adjustment, and audit closure policy;
- 06110 POS Gateway customer status message, receipt proof, notification, and dispute communication policy;
- 06100 POS Gateway staff operation, manual fallback, override authority, and manager approval policy;
- POS Gateway security, secret rotation, access control, and production operation hardening policy;
- POS Gateway incident response, dispute investigation, provider escalation, and postmortem policy;
- POS Gateway runtime configuration, environment separation, and production credential activation policy;
- tenant/store SaaS onboarding and operational enablement policy.

Where conflict exists, this document governs POS Gateway access control, tenant/store isolation, privileged action approval, emergency access, and approval audit behavior.

---

## 38. Summary

The POS Gateway is too sensitive for broad, convenient permissions.

It controls or observes transaction state, customer status, refund/cancellation paths, provider routing, evidence archives, reconciliation cases, and store operations.

The correct access standard is:

- least privilege;
- tenant isolation;
- store isolation;
- scoped roles;
- privileged action approval;
- two-person control for high-risk actions;
- audited emergency access;
- reviewed break-glass;
- no shared accounts;
- no silent evidence access.

A secure POS Gateway is not only protected from outsiders.  
It is protected from accidental or excessive authority inside the operation.