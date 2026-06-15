# 20005_Policy_Foundation_Security_Access_Control_RBAC_ABAC_And_Least_Privilege

## 1. Purpose

This document defines the foundation-level access control, RBAC, ABAC, and least privilege policy.

The purpose of this policy is to ensure that every actor, runtime, device, provider, support user, admin user, and internal service can access only the data and actions required for its role, context, and authority.

Access control must be enforced by server-side, database-side, or trusted runtime-side logic.

UI hiding is not access control.

Client-side role checks are not access control.

---

## 2. Scope

This policy applies to:

```text
customer access
staff access
manager access
owner access
HQ support access
developer access
admin access
provider access
device access
local agent access
service-to-service access
AI/Agent runtime access
audit access
export access
configuration access
credential access
```

This policy applies across:

```text
tenant
store
company
legal entity
operating group
role
assignment
device
runtime
provider integration
order
payment
KDS ticket
support ticket
incident
reconciliation case
audit event
credential reference
```

---

## 3. Core Principle

Access must be denied by default and granted only by explicit authority.

The core rule is:

```text
deny by default
grant by role
limit by tenant
limit by store
limit by assignment
limit by purpose
limit by runtime
limit by action
audit high-risk access
expire temporary access
```

Least privilege is the default.

Broad access is an exception.

---

## 4. Access Control Layers

The system must enforce access through multiple layers.

Required layers:

```text
authentication
role-based access control
attribute-based access control
tenant isolation
store isolation
runtime authority boundary
object-level authorization
state-based authorization
audit and monitoring
```

No single layer is sufficient.

A user being authenticated does not mean the user is authorized.

---

## 5. Authentication And Authorization Separation

Authentication answers:

```text
who is this actor?
```

Authorization answers:

```text
what is this actor allowed to do here?
```

The system must never treat authentication as authorization.

Examples:

```text
logged-in customer ≠ access to all orders
store staff ≠ access to all stores
manager ≠ refund authority
support user ≠ payment truth mutation
developer ≠ unrestricted production data access
```

---

## 6. Actor Types

The system must classify actors.

Actor types include:

```text
CUSTOMER
STAFF
STORE_MANAGER
OWNER
HQ_SUPPORT
HQ_OPERATOR
HQ_ADMIN
DEVELOPER
SECURITY_REVIEWER
AUDIT_REVIEWER
PROVIDER_SYSTEM
INTERNAL_RUNTIME
STORE_DEVICE
LOCAL_AGENT
AI_AGENT
```

Actor type alone does not grant access.

It must be combined with scope, role, assignment, and action.

---

## 7. RBAC Rule

Role-Based Access Control defines what an actor may generally do.

Example roles:

```text
customer
store_staff
store_manager
owner
hq_support
hq_operations
developer
security_admin
audit_reviewer
system_runtime
provider_adapter
```

RBAC must be used for broad permission grouping.

However, RBAC alone is not enough.

A store manager role must still be limited to assigned stores.

A support role must still be limited by purpose and audit.

---

## 8. ABAC Rule

Attribute-Based Access Control must refine access based on context.

Attributes may include:

```text
tenant_id
store_id
company_id
legal_entity_id
operating_group_id
employee_id
role
assignment_status
device_id
provider_id
runtime_family
object_state
authority_scope
time_window
purpose
risk_level
```

ABAC prevents broad role abuse.

Example:

```text
manager role + assigned_store_id + active_assignment = store manager access
```

not merely:

```text
manager role = all store access
```

---

## 9. Tenant Isolation Rule

Tenant isolation is mandatory.

Every tenant-scoped object must check tenant boundary.

Tenant-scoped objects include:

```text
customer
employee
store
order
payment
KDS ticket
provider integration
support ticket
incident
reconciliation case
credential reference
audit event
analytics projection
```

Cross-tenant access must be denied by default.

HQ-level cross-tenant access, if ever needed, must require explicit authority, purpose, and audit.

---

## 10. Store Isolation Rule

Store isolation is mandatory for store-level operations.

Store-scoped objects include:

```text
order
payment request
KDS ticket
table session
device token
local agent
staff action
manager approval
store support view
provider integration
store incident
```

Store staff may access only assigned store context.

Owner access must be limited to owned or authorized stores.

HQ support access must be logged and purpose-based.

---

## 11. Object-Level Authorization Rule

Every object access must verify object-level permission.

Protected objects include:

```text
order
payment
customer profile
employee profile
KDS ticket
support ticket
incident
reconciliation case
provider integration
credential reference
audit event
raw provider payload
```

Knowing an object ID must never grant access.

Object ID is a reference, not permission.

---

## 12. BOLA And IDOR Defense

Broken Object Level Authorization and IDOR must be explicitly prevented.

Required checks:

```text
actor tenant matches object tenant
actor store scope matches object store
actor role allows action
actor assignment is active
object state allows action
runtime authority allows action
```

The following are prohibited:

```text
fetch by ID without tenant check
fetch by order number without store check
payment lookup without order ownership check
support ticket view without tenant/store scope
raw payload view without purpose and audit
```

---

## 13. Runtime Authority Boundary

Each runtime has limited authority.

Examples:

```text
Payment Runtime owns payment verification.
KDS Runtime owns kitchen execution.
Customer Display Runtime owns visibility.
Support Runtime owns assistance workflow.
Audit Runtime owns append-only memory.
Reconciliation Runtime owns accepted post-incident conclusion.
POS Adapter Runtime owns provider normalization.
```

A runtime must not perform actions outside its authority boundary.

Example:

```text
Customer Display Runtime cannot mark PAYMENT_DONE.
KDS Runtime cannot approve refund.
Support Runtime cannot rewrite provider event.
POS Adapter cannot close reconciliation.
```

---

## 14. Authority Scope Model

Authority scopes include:

```text
READ_ONLY
VISIBILITY_UPDATE
PROJECTION_UPDATE
ORDER_STATE_UPDATE
PAYMENT_VERIFICATION
KDS_RELEASE
MANUAL_FALLBACK
RECONCILIATION
SUPPORT_ACTION
AUDIT_APPEND
CONFIG_CHANGE
CREDENTIAL_ROTATION
EXPORT
IDENTITY_REVEAL
```

Every authority-sensitive action must declare required scope.

Actors and runtimes must be checked against that scope.

---

## 15. State-Based Authorization

Some actions are allowed only in specific states.

Examples:

```text
KDS release allowed only when payment eligibility is verified.
Manual fallback allowed only when fallback condition exists.
Refund review allowed only after payment record exists.
Reconciliation closure allowed only after evidence is attached.
Credential rotation allowed only by authorized operator.
Support closure with exception requires reason and audit.
```

Authorization must check state, not only role.

---

## 16. Least Privilege Rule

Every actor and runtime must receive the minimum permission needed.

Least privilege applies to:

```text
database grants
RLS policies
RPC permissions
API scopes
device tokens
service tokens
provider credentials
support console permissions
admin console permissions
developer production access
```

Broad access must expire or be reviewed.

---

## 17. Privileged Access Rule

Privileged access must be restricted and audited.

Privileged actions include:

```text
role change
permission change
credential reveal
credential rotation
provider configuration change
payment status override
manual payment confirmation
KDS release override
reconciliation conclusion
raw payload access
identity reveal
export
RLS policy change
production migration
```

Privileged actions require stronger controls.

---

## 18. Reauthentication Rule

High-risk actions must require reauthentication.

Reauthentication should be required for:

```text
identity reveal
credential reveal
credential rotation
role permission change
export
refund-related action
manual payment confirmation
KDS release override
reconciliation closure
production configuration change
```

Reauthentication must be audited.

---

## 19. Purpose-Based Access Rule

Sensitive access must require purpose.

Purpose must be recorded for:

```text
support identity reveal
raw payload access
restricted evidence access
export
developer production data access
security incident investigation
manual reconciliation
```

Purpose values may include:

```text
CUSTOMER_SUPPORT
PAYMENT_RECONCILIATION
SECURITY_INCIDENT
VENDOR_ESCALATION
AUDIT_REVIEW
LEGAL_REVIEW
OPERATIONS_RECOVERY
```

Purpose must be stored in audit.

---

## 20. Temporary Access Rule

Temporary access must expire.

Temporary access may be granted for:

```text
incident response
developer investigation
support escalation
vendor issue review
security review
migration recovery
```

Temporary access must include:

```text
actor
scope
reason
approved_by
started_at
expires_at
audit_reference
```

Expired temporary access must be revoked.

---

## 21. Break-Glass Access Rule

Break-glass access is emergency access.

Break-glass requires:

```text
emergency reason
actor identity
reauthentication
scope limit
time limit
audit event
post-access review
```

Break-glass must not become routine access.

Break-glass must be visible to security or audit review.

---

## 22. Support Access Rule

Support access must be limited.

Support may:

```text
view masked customer references
view order status
view payment status projection
view diagnostic error
attach evidence
create support ticket
request replay
request reconciliation
escalate to vendor
```

Support must not directly:

```text
mark payment verified
release KDS
approve refund
rewrite provider event
delete audit
view raw CI/DI
view raw credential
close reconciliation without authority
```

---

## 23. Developer Access Rule

Developer access must be controlled.

Developer may access production only when justified.

Developer production access requires:

```text
purpose
approval if high risk
time limit
least privilege
audit
masked data by default
```

Developer must not casually access:

```text
raw CI/DI
raw credentials
full customer identity
production payment secrets
service_role key
restricted evidence
```

---

## 24. Admin Access Rule

Admin access is high risk.

Admin actions must require:

```text
role authority
tenant or global scope
configuration scope
reauthentication for sensitive change
change reason
audit event
rollback path
```

Admin must not bypass tenant/store isolation without explicit policy.

---

## 25. Device Access Rule

Device access must be scoped.

Device tokens must include:

```text
tenant_id
store_id
device_id
device_type
allowed_runtime
allowed_actions
issued_at
expires_at if applicable
revoked_at
```

Customer display device must not perform payment truth mutation.

KDS screen must not approve payment.

Manager device may approve fallback only within policy.

---

## 26. Local Agent Access Rule

Local agent access must be store-scoped.

Local agent may:

```text
relay store events
sync local cache
upload fallback events
report device health
relay KDS bridge messages
```

Local agent must not:

```text
access other stores
verify payment authority
approve refund
reveal identity
manage credentials
delete audit
```

Offline local events must be marked if replayed.

---

## 27. Provider Access Rule

Provider access must be contract- and capability-scoped.

Provider systems may send or receive only what integration contract allows.

Provider must not gain:

```text
cross-tenant data
other provider data
unrelated customer identity
raw internal audit
credential inventory
support console access
```

Provider event does not automatically become trusted state.

---

## 28. AI/Agent Access Rule

AI/Agent access must be data-minimized and authority-limited.

AI/Agent may receive:

```text
masked operational summary
diagnostic error code
order pattern
incident category
aggregated analytics
```

AI/Agent must not receive:

```text
raw CI
raw DI
raw credentials
full customer identity
raw provider payload unless restricted and approved
service_role key
```

AI/Agent may recommend.

It must not directly execute authority-sensitive actions unless explicitly designed, constrained, audited, and approved by later policy.

---

## 29. Export Access Rule

Export is high-risk access.

Export must require:

```text
role permission
purpose
scope
data classification check
masking review
approval where sensitive
audit event
retention or expiration
```

Default export must exclude:

```text
raw CI
raw DI
raw credentials
raw secrets
unmasked provider identity
full bank account
```

---

## 30. Credential Access Rule

Credential access is highly restricted.

Credential reveal must be blocked by default.

Credential operations include:

```text
create credential
rotate credential
revoke credential
view masked credential status
test credential connection
```

Raw credential reveal should be exceptional and audited.

Support must not see raw credentials.

---

## 31. Audit Access Rule

Audit access must be controlled.

Audit may contain sensitive operational history.

Allowed audit access should depend on:

```text
role
tenant scope
store scope
purpose
risk level
```

Audit records must not be editable by ordinary users.

Audit deletion must be prohibited except through controlled retention/legal process.

---

## 32. Access Review Rule

Access must be reviewed periodically.

Review targets include:

```text
HQ admin roles
support roles
developer production access
provider integration credentials
service tokens
device tokens
local agent tokens
owner access
manager access
temporary access
break-glass history
```

Stale access must be removed.

Role drift must be corrected.

---

## 33. Segregation Of Duties

High-risk workflows should separate duties where possible.

Examples:

```text
developer writes code
reviewer approves code
security reviews high-risk change
deployment gate controls production release
support requests reconciliation
authorized role closes reconciliation
audit reviews exception
```

One person should not casually create, approve, deploy, and audit the same high-risk change without trace.

---

## 34. Access Change Audit

The system must audit access changes.

Audit events include:

```text
role granted
role removed
permission changed
temporary access granted
temporary access expired
break-glass used
support access used
developer production access used
credential access attempted
identity reveal attempted
export performed
```

Audit must include:

```text
actor
target
scope
reason
approved_by if applicable
timestamp
result
```

Audit must not contain raw secrets or raw CI/DI.

---

## 35. Access Denial Monitoring

Access denial is security signal.

The system should monitor:

```text
authentication failures
authorization failures
cross-tenant denial
cross-store denial
invalid device token
invalid service token
expired temporary access attempt
revoked credential use attempt
support unauthorized action attempt
developer unauthorized data access attempt
```

Repeated denial may indicate misconfiguration or attack.

---

## 36. Financial-Grade Alignment

Financial-grade access control requires:

```text
least privilege
segregation of duties
strong authentication
role and attribute based control
auditability
privileged access management
temporary access control
access review
sensitive action reauthentication
incident visibility
```

Because the system handles payment, settlement candidate data, customer identity, provider credentials, and store revenue impact, access control must follow financial-grade discipline.

---

## 37. Prohibited Handling

The following are prohibited:

```text
using login alone as authorization
using UI hiding as security
allowing object access by ID alone
returning all data then filtering client-side
using service_role for ordinary client flow
granting broad support access without purpose
letting support mutate payment truth
letting customer display release KDS
letting KDS verify payment
allowing developer unrestricted production data access
keeping stale admin accounts
leaving temporary access active indefinitely
allowing cross-tenant access without explicit authority
```

---

## 38. MVP Cutline

For MVP, access control must support:

```text
deny-by-default
tenant isolation
store isolation
role-based access
assignment-based store access
server-side authorization
RLS for client-accessible tables
object-level authorization checks
support masking
developer production access restriction
device token scoping
service token scoping
audit for high-risk access
temporary access record
basic access review checklist
```

Excluded from MVP:

```text
full enterprise PAM platform
fully automated ABAC engine
formal IAM certification
advanced behavioral access analytics
complete just-in-time access automation
hardware-backed device identity
```

MVP must still prevent cross-tenant, cross-store, and authority-boundary access failures.

---

## 39. Relationship To Foundation Security 001

Foundation Security 001 defines sensitive identity protection.

This document defines who may access identity, under what scope, and with what audit.

The relationship is:

```text
Foundation Security 001 = what identity must be protected
Foundation Security 005 = who may access protected identity and under what conditions
```

---

## 40. Relationship To Foundation Security 002

Foundation Security 002 defines secure coding and DevSecOps gates.

This document defines access rules that code must enforce.

Examples:

```text
authorization tests
RLS regression tests
object-level access checks
support action restrictions
admin action reauthentication
```

---

## 41. Relationship To Foundation Security 003

Foundation Security 003 defines secret and credential protection.

This document defines who may access, rotate, revoke, or view credential status.

Raw secret reveal remains exceptional.

---

## 42. Relationship To Foundation Security 004

Foundation Security 004 defines cloud security and financial-sector alignment.

This document implements cloud-level least privilege, tenant isolation, store isolation, and privileged access governance.

---

## 43. Relationship To 04000 Integration Security

04000 integration security documents must follow this access policy.

Examples:

```text
04450 RPC security must enforce authority scope
04460 credential isolation must enforce least privilege
POS adapter must be capability-scoped
payment runtime must own payment verification
KDS bridge must not verify payment
support runtime must not mutate truth
```

Integration security is access control applied to runtime communication.

---

## 44. Readiness Check

This policy is ready when:

```text
authentication and authorization are separated
RBAC and ABAC are both defined
tenant isolation is mandatory
store isolation is mandatory
object-level authorization is required
BOLA/IDOR defense is explicit
runtime authority boundaries are defined
authority scopes are defined
state-based authorization is required
least privilege is defined
privileged access is controlled
reauthentication is required for high-risk action
purpose-based access is required
temporary access is controlled
break-glass is defined
support access is limited
developer access is controlled
device and local agent access are scoped
provider access is capability-scoped
AI/Agent access is limited
export and credential access are restricted
audit and access review are required
financial-grade alignment is stated
MVP cutline is explicit
```

---

## 45. Summary

Access control is not a login screen.

Access control is the rule that decides:

```text
who can see
who can change
which tenant
which store
which runtime
which object
which state
which action
for what purpose
under what audit
```

The system must deny by default, grant narrowly, scope strictly, audit high-risk actions, and remove stale access.

This is the only safe way to operate a multi-tenant, multi-store, payment-linked, POS-integrated SaaS platform.
