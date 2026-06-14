# Foundation Security 004 Cloud Security Financial Sector Alignment Policy

## 1. Purpose

This document defines the foundation-level cloud security and financial-sector alignment policy.

The purpose of this policy is to ensure that the system’s cloud, SaaS, database, storage, runtime, API, integration, monitoring, backup, audit, and incident response architecture follows financial-grade security discipline.

The project may not initially be a licensed financial institution.

However, the platform handles payment flow, settlement candidates, refund review, customer identity, POS integration, provider credentials, webhook authority, store revenue impact, and audit evidence.

Therefore, the system must be designed with financial-sector-grade security discipline from the beginning.

---

## 2. Scope

This policy applies to:

```text
cloud infrastructure
Supabase
PostgreSQL
storage buckets
Edge Functions
serverless functions
API gateways
webhook endpoints
POS provider integrations
payment provider integrations
KDS bridge
local agent
support console
admin console
CI/CD pipeline
logging and monitoring
backup and restore
audit evidence
security incident response
```

This policy applies across:

```text
development
test
staging
pilot
production
```

---

## 3. Core Principle

Cloud security must be designed as a control system, not a hosting choice.

The core rule is:

```text
cloud convenience
        ≠
security readiness

SaaS flexibility
        ≠
uncontrolled access

managed database
        ≠
automatic compliance

payment integration
        ≠
financial-grade trust
```

Every cloud component must have defined responsibility, access control, auditability, isolation, backup, monitoring, and incident response.

---

## 4. Financial-Grade Alignment Principle

The system should align with financial-grade security principles even before formal regulatory obligation applies.

Financial-grade alignment means:

```text
least privilege
segregation of duties
strong authentication
strong authorization
tenant isolation
data minimization
encryption
key management
secure development lifecycle
change control
auditability
log integrity
incident response
backup and recovery
vulnerability management
vendor risk management
```

This alignment reduces future rework when payment, settlement, franchise SaaS, or regulated partnerships expand.

---

## 5. Cloud Responsibility Model

The system must distinguish cloud provider responsibility and service operator responsibility.

Cloud provider may provide:

```text
physical infrastructure security
managed database platform
storage platform
network controls
availability infrastructure
managed authentication features
monitoring primitives
backup primitives
```

The project remains responsible for:

```text
application security
tenant isolation
RLS policies
authorization logic
secret management
data classification
provider credential protection
audit events
secure configuration
access review
incident response
privacy handling
backup policy
deployment safety
```

Managed cloud does not remove operator responsibility.

---

## 6. Environment Separation

Cloud environments must be separated.

Allowed environments:

```text
LOCAL_DEV
TEST
STAGING
PILOT
PRODUCTION
```

Required separation:

```text
separate credentials
separate secrets
separate provider keys
separate database data
separate storage buckets where needed
separate webhook endpoints where possible
separate logs or log labels
separate access control
```

Production data must not be copied into lower environments unless masked, minimized, and approved.

---

## 7. Production Data Rule

Production data must be treated as restricted.

Production data must not be used casually for:

```text
local debugging
test fixtures
demo screenshots
AI prompt examples
support training
developer convenience
performance testing
```

If production data is needed for investigation, use:

```text
masked extract
restricted evidence reference
temporary access
audit event
purpose record
expiration
```

---

## 8. Tenant Isolation Rule

Tenant isolation is mandatory.

Every tenant-scoped object must enforce tenant boundary through application logic, database RLS, RPC validation, or trusted runtime checks.

Tenant isolation must apply to:

```text
customer
order
payment
KDS ticket
store
staff
support ticket
provider integration
credential reference
audit event
reconciliation case
raw provider payload
analytics projection
```

Cross-tenant access must be denied by default.

---

## 9. Store Isolation Rule

Store isolation is mandatory where store-level operation exists.

Store isolation must apply to:

```text
order
payment request
KDS ticket
table session
device token
local agent
staff action
manager authority
provider integration
store support view
store incident
```

Owner, HQ, support, and developer access must be explicitly scoped.

Store staff must not access other stores unless role and assignment allow it.

---

## 10. Supabase RLS Rule

Supabase/PostgreSQL client-accessible tables must use RLS.

Required rules:

```text
RLS enabled
deny-by-default
tenant_id enforced
store_id enforced where applicable
role and assignment checked
anonymous access blocked unless public by design
service_role key not exposed
RPC authority checked internally
audit events for authority-sensitive mutation
```

RLS must be tested, not assumed.

---

## 11. Service Role Key Rule

The Supabase service_role key is catastrophic risk.

Rules:

```text
must never be in frontend
must never be in Flutter
must never be committed
must never appear in logs
must never appear in screenshots
must never be sent to support
must be limited to trusted backend or controlled server runtime
must be rotated if exposed
```

Using service_role must be exceptional and justified.

---

## 12. Cloud Storage Security

Cloud storage must classify buckets and objects.

Storage classes may include:

```text
PUBLIC_ASSET
PRIVATE_OPERATIONAL_FILE
RESTRICTED_EVIDENCE
SENSITIVE_IDENTITY_EVIDENCE
SUPPORT_ATTACHMENT
PROVIDER_PAYLOAD_ARCHIVE
BACKUP_OBJECT
```

Default storage must be private.

Public access must require explicit classification.

Restricted evidence must require access control, audit, retention, and deletion policy.

---

## 13. Raw Provider Payload Storage

Raw provider payloads may contain sensitive identity, payment references, provider references, or operational evidence.

Raw payload storage must follow:

```text
restricted access
masking where possible
raw_payload_reference instead of direct exposure
encryption where needed
retention policy
audit on access
no support-screen raw display by default
```

Raw payload is evidence.

It is not ordinary application data.

---

## 14. Encryption Rule

Cloud data must be protected in transit and at rest.

Required encryption controls:

```text
TLS for transport
managed encryption at rest
field-level encryption for high-risk identity where needed
separate key management
backup encryption
restricted decryption path
no plaintext secret storage
```

Encryption alone is not sufficient.

Access control, minimization, isolation, logging, and incident response are also required.

---

## 15. Key Management Rule

Keys and secrets must follow Foundation Security 003.

Key management must include:

```text
key classification
environment separation
key scope
rotation
revocation
access audit
backup key control
no key in code
no key in frontend
```

Encryption keys must not be stored beside encrypted data without protection.

---

## 16. Network And Endpoint Exposure Rule

External endpoints must be minimized and classified.

Endpoint classes:

```text
PUBLIC_CUSTOMER_ENDPOINT
PUBLIC_WEBHOOK_ENDPOINT
AUTHENTICATED_APP_ENDPOINT
STORE_DEVICE_ENDPOINT
INTERNAL_SERVICE_ENDPOINT
SUPPORT_ADMIN_ENDPOINT
DEVELOPER_ADMIN_ENDPOINT
```

Public endpoints require stronger validation, rate limiting, monitoring, and abuse controls.

Internal endpoints must not be accidentally exposed as public endpoints.

---

## 17. Webhook Endpoint Rule

Webhook endpoints are public attack surfaces.

Webhook endpoints must include:

```text
provider identity verification
signature or secret verification where available
timestamp freshness
replay protection
idempotency
payload validation
rate limiting
safe logging
quarantine for suspicious payload
audit for authority-sensitive outcome
```

Webhook received does not mean webhook trusted.

---

## 18. API Gateway And RPC Rule

API and RPC calls must enforce:

```text
authentication
authorization
tenant scope
store scope
authority scope
input validation
idempotency where needed
audit where authority-sensitive
safe error response
rate limiting
```

API security must align with 04450 POS RPC Communication Security And Provider Trust Boundary Policy.

---

## 19. Admin And Support Access Rule

Admin and support access must be tightly controlled.

Required controls:

```text
role-based access
least privilege
tenant/store scope
reauthentication for sensitive actions
purpose entry for sensitive reveal
masked identity by default
no raw credential display
audit on sensitive access
access review
```

Support tools must not become hidden mutation tools.

---

## 20. Developer Access Rule

Developer access to production must be limited.

Developer production access must require:

```text
reason
approval if high risk
time limit
least privilege
audit
no bulk export by default
no raw identity reveal by default
no secret reveal by default
```

Developer convenience must not override production security.

---

## 21. CI/CD Cloud Security Rule

CI/CD pipeline must be controlled.

Required controls:

```text
environment-specific deployment
production deployment approval
secret scanning
dependency scanning
migration review
RLS review
test gate
rollback plan
build log masking
restricted production secrets
```

CI/CD must not print secrets, tokens, database URLs, or provider credentials.

---

## 22. Change Control Rule

Production cloud changes must be controlled.

Controlled changes include:

```text
database migration
RLS policy change
RPC function change
provider credential change
webhook endpoint change
storage bucket policy change
role permission change
admin access change
logging retention change
backup configuration change
```

High-risk changes require audit and rollback plan.

---

## 23. Logging And Monitoring Rule

Cloud runtime must produce safe and useful logs.

Logs should include:

```text
trace_id
request_id
tenant_id
store_id
runtime_family
event_type
diagnostic_error_code
provider_id
masked reference
```

Logs must not include:

```text
raw CI
raw DI
full phone
full email
service_role key
provider secret
webhook secret
database password
raw access token
raw bank account
```

Monitoring must detect security and operational failures.

---

## 24. Security Monitoring

Security monitoring should track:

```text
authentication failures
authorization failures
cross-tenant denial
cross-store denial
RLS denial spike
webhook signature failures
replay attempts
credential failures
service_role usage
support sensitive reveal
export attempts
admin configuration changes
failed migration
unexpected public access
```

High-risk signals must trigger incident triage.

---

## 25. Audit And Evidence Rule

Audit must be append-only and tamper-resistant by policy.

Audit must record:

```text
who acted
what action occurred
which tenant
which store
which runtime
which object
before or after reference where needed
reason where needed
timestamp
result
```

Audit must not contain raw secrets or raw CI/DI.

Audit deletion or modification must be prohibited except under controlled retention/legal policy.

---

## 26. Backup And Restore Rule

Cloud backup and restore must be controlled.

Backup policy must define:

```text
backup scope
backup frequency
backup retention
backup encryption
backup access control
restore authority
restore audit
restore test
sensitive data handling
```

Restore must not bypass tenant isolation or security controls.

Restore drills should include security review.

---

## 27. Disaster Recovery Rule

Disaster recovery must consider both availability and security.

DR planning should include:

```text
database recovery
storage recovery
credential recovery
provider integration recovery
webhook endpoint recovery
KDS fallback
payment verification fallback
audit preservation
manual operation mode
post-recovery reconciliation
```

Recovery must not silently overwrite uncertain state.

---

## 28. Vulnerability Management

Cloud vulnerabilities must be tracked and remediated.

Vulnerability sources include:

```text
dependency scan
cloud configuration scan
penetration test
security incident
provider notice
framework advisory
database advisory
manual review
```

Vulnerability response must classify severity and assign owner.

Payment, credential, identity, tenant isolation, and audit vulnerabilities are high risk by default.

---

## 29. Vendor And Cloud Provider Risk

Cloud and SaaS providers must be reviewed.

Review should include:

```text
data location
security certification if available
access control features
logging features
backup features
incident notification process
support access model
subprocessor risk
service availability
exit and portability
pricing risk
```

Provider use must not create hidden lock-in without data export and recovery plan.

---

## 30. Data Residency And Transfer Rule

If data location or cross-border processing becomes relevant, it must be documented.

Review should include:

```text
where data is stored
where backups are stored
where support access may occur
where logs are processed
whether subprocessors access data
whether customer notice is required
whether contract terms cover it
```

This is especially important for future franchise SaaS and overseas expansion.

---

## 31. Cloud Exit And Portability Rule

The system should maintain an exit plan for critical cloud dependencies.

Exit plan should consider:

```text
database export
storage export
audit export
identity data export
provider credential revocation
DNS and endpoint migration
backup restoration
alternative runtime path
documentation of dependencies
```

Portability does not mean no cloud dependency.

It means dependency is understood and recoverable.

---

## 32. AI/Agent Cloud Security Rule

AI/Agent cloud use must follow data minimization.

AI/Agent must not receive:

```text
raw CI
raw DI
raw credentials
service_role key
full customer identity
unmasked provider payload
payment secret
```

AI/Agent may receive:

```text
masked operational summary
order pattern
incident category
diagnostic code
anonymized analytics
```

AI/Agent execution must not bypass authority controls.

---

## 33. Financial Data Boundary

Payment and settlement-related data must be classified.

Financially sensitive data includes:

```text
payment request
payment event
payment status
refund review
settlement candidate
provider payment reference
manual payment confirmation
reconciliation conclusion
store revenue projection
```

Financial data must require stronger audit, access control, retention, and incident response.

---

## 34. Financial-Grade Change Approval

High-risk financial changes require stronger approval.

High-risk changes include:

```text
payment status mapping change
refund-related configuration
settlement allocation logic
payment provider credential change
KDS release eligibility tied to payment
manual payment confirmation policy
reconciliation conclusion logic
```

These changes must not be deployed casually.

---

## 35. Incident Response Rule

Cloud security incidents must have a response flow.

Incident response should include:

```text
detect
triage
contain
preserve evidence
assess affected data
assess affected tenants/stores
rotate credentials if needed
patch or mitigate
communicate internally
legal/privacy review if needed
customer or regulator notification review if needed
postmortem
prevent recurrence
```

Support closure is not security closure.

---

## 36. Security Exception Rule

Cloud security exceptions must be documented.

Exception record must include:

```text
exception_id
risk description
affected environment
affected runtime
reason
temporary mitigation
owner
approval
expiration date
review date
```

Permanent silent exceptions are prohibited.

---

## 37. Prohibited Handling

The following are prohibited:

```text
using production data in local dev without masking
exposing service_role key to frontend
creating client-visible table without RLS
opening storage bucket publicly by default
logging secrets
logging raw CI/DI
using one provider credential across all environments
allowing support to view raw identity by default
deploying high-risk migration without review
disabling audit for convenience
restoring production backup into weak environment
letting AI process raw identity or secrets
```

---

## 38. MVP Cutline

For MVP, cloud security must support:

```text
environment separation
production secret separation
Supabase service_role protection
RLS deny-by-default
tenant/store isolation
private storage by default
safe logging rule
basic security monitoring
manual deployment gate
migration security review
backup policy
manual incident response flow
provider credential isolation
webhook endpoint verification
support masking
no production data in test without masking
```

Excluded from MVP:

```text
formal financial certification
full enterprise SIEM
full zero-trust network
automated cloud posture management
formal external audit
multi-region disaster recovery
hardware security module
advanced DLP platform
```

MVP must still avoid foundational cloud security failures.

---

## 39. Relationship To Foundation Security 001

Foundation Security 001 defines sensitive identity protection.

Cloud storage, logs, backups, support tools, and AI systems must follow that policy.

The relationship is:

```text
Foundation Security 001 = protect identity
Foundation Security 004 = ensure cloud architecture does not leak or overexpose identity
```

---

## 40. Relationship To Foundation Security 002

Foundation Security 002 defines secure coding and DevSecOps gates.

Cloud changes must pass those gates.

Examples:

```text
migration review
RLS review
secret scan
deployment approval
authorization tests
webhook security tests
```

---

## 41. Relationship To Foundation Security 003

Foundation Security 003 defines secret management.

This document applies those rules to cloud operation.

Examples:

```text
production secrets separated
service_role protected
CI/CD secrets masked
provider credentials isolated
backup keys protected
```

---

## 42. Relationship To 04000 Integration Security

04000 integration security documents must follow this cloud policy.

Examples:

```text
04450 RPC security must run on authenticated/scoped cloud endpoints
04460 credential isolation must follow cloud secret policy
webhook endpoints must be monitored
provider payload storage must be restricted
KDS bridge RPC must be tenant/store scoped
```

Integration security cannot be separated from cloud security.

---

## 43. Financial-Grade Readiness Check

Financial-grade cloud readiness requires:

```text
least privilege
environment separation
tenant isolation
store isolation
RLS verification
secret management
encryption
auditability
log safety
backup and restore
incident response
change control
vulnerability management
vendor risk review
data minimization
support access control
```

If any of these are absent, the system may still prototype, but must not be treated as production-ready for payment or settlement-sensitive workflows.

---

## 44. Readiness Check

This policy is ready when:

```text
cloud responsibility model is defined
environment separation is required
production data handling is restricted
tenant isolation is required
store isolation is required
Supabase RLS is required
service_role key risk is explicit
storage classes are defined
raw payload storage is restricted
encryption and key rules are defined
webhook endpoint security is defined
admin/support access is controlled
CI/CD cloud security is defined
change control is required
logging and monitoring are defined
audit is append-only
backup and restore are controlled
vendor/cloud provider risk is considered
AI/Agent cloud security is limited
financial data boundary is defined
incident response exists
MVP cutline is explicit
```

---

## 45. Summary

Cloud does not automatically make the system secure.

Managed services reduce infrastructure burden, but the project remains responsible for:

```text
who can access
which tenant they can access
which store they can access
which data is exposed
which secret is protected
which action is audited
which endpoint is public
which backup can be restored
which incident must be reported
```

Because the system touches payment, settlement candidates, customer identity, POS integration, provider credentials, and store revenue, the correct posture is financial-grade cloud discipline from the beginning.

This policy makes cloud security a foundation requirement, not an afterthought.
