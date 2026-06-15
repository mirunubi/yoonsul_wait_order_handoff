# 20002_Policy_Foundation_Security_Secure_Coding_And_DevSecOps_Gate

## 1. Purpose

This document defines the foundation-level secure coding and DevSecOps gate policy.

The purpose of this policy is to ensure that security is embedded into requirements, design, implementation, review, testing, deployment, monitoring, and incident response.

Security must not be treated as a final checklist after development.

Security must be part of the development lifecycle.

This policy applies across all runtimes, including POS, payment, KDS, membership, support, analytics, AI/Agent, provider integration, and customer-facing applications.

---

## 2. Scope

This policy applies to:

```text
application code
backend code
frontend code
Flutter client code
Supabase RPC functions
PostgreSQL SQL migrations
RLS policies
database functions
Edge Functions
provider adapter code
webhook handlers
KDS bridge code
payment integration code
support console code
admin console code
AI/Agent integration code
CI/CD pipeline
dependency management
secret handling
logging and audit behavior
deployment approval
```

This policy does not define final implementation code.

It defines required security gates before code is considered acceptable.

---

## 3. Core Principle

Secure coding is not optional.

The core rule is:

```text
no security review
        ↓
no production deployment

no authorization test
        ↓
no runtime authority

no RLS verification
        ↓
no database release

no secret scan
        ↓
no commit acceptance

no audit path
        ↓
no authority-sensitive feature completion
```

Security must be measurable and enforceable.

---

## 4. Security Development Lifecycle

The project must follow a security development lifecycle.

Required lifecycle stages:

```text
security requirement definition
threat modeling
secure design review
secure coding
code review
automated security testing
manual security review for high-risk areas
migration security review
deployment gate
runtime monitoring
vulnerability response
post-incident improvement
```

A feature is not complete until the relevant security stage is complete.

---

## 5. Security Gate Model

Each feature must pass security gates according to risk.

Gate levels:

```text
GATE_0_DOCUMENT_ONLY
GATE_1_LOW_RISK_IMPLEMENTATION
GATE_2_STANDARD_RUNTIME_FEATURE
GATE_3_AUTHORITY_SENSITIVE_FEATURE
GATE_4_PAYMENT_IDENTITY_CREDENTIAL_FEATURE
GATE_5_SECURITY_CRITICAL_FEATURE
```

Examples:

```text
menu display = GATE_1
store order projection = GATE_2
KDS release = GATE_3
payment verification = GATE_4
credential rotation = GATE_5
CI/DI vault access = GATE_5
```

Higher gates require stronger review.

---

## 6. Threat Modeling Requirement

Authority-sensitive features must include threat modeling.

Threat modeling should identify:

```text
assets
actors
trust boundaries
entry points
authorization rules
abuse cases
data exposure paths
audit requirements
failure modes
fallback risks
replay risks
credential risks
```

Threat modeling is required for:

```text
payment runtime
POS adapter runtime
KDS release
customer identity
support console
admin console
webhook handlers
RPC authority actions
credential management
reconciliation closure
AI/Agent access to operational data
```

---

## 7. Secure Coding Baseline

All code must follow secure coding principles.

Baseline rules:

```text
validate input
encode output
enforce authorization server-side
use parameterized queries
avoid dynamic SQL unless reviewed
fail closed
minimize data returned
do not expose internal errors
do not log secrets
do not log raw identity
handle duplicates idempotently
verify state transitions
audit authority-sensitive actions
```

Client-side checks are not security boundaries.

Server-side enforcement is required.

---

## 8. Authentication Rule

All non-public runtime APIs must require authentication.

Authentication must distinguish:

```text
customer
staff
manager
owner
HQ support
developer
provider
service runtime
device
local agent
```

Authentication identity must not automatically imply authorization.

Authentication answers:

```text
who are you?
```

Authorization answers:

```text
what are you allowed to do here?
```

Both are required.

---

## 9. Authorization Rule

Authorization must be enforced on the server, database, or trusted runtime layer.

Authorization must check:

```text
tenant_id
store_id
role
authority scope
runtime family
object ownership
action type
feature capability
current state
```

Forbidden patterns:

```text
trusting client-provided role
trusting client-provided tenant_id without verification
checking role only in UI
allowing object access by ID alone
using admin RPC for ordinary user flow
returning all rows then filtering on client
```

---

## 10. BOLA And IDOR Defense Rule

Broken Object Level Authorization and IDOR must be explicitly prevented.

Every object access must verify that the actor can access the object.

Protected objects include:

```text
order
payment
customer
employee
store
tenant
KDS ticket
support ticket
incident
reconciliation case
provider integration
credential reference
audit event
```

Required checks:

```text
actor belongs to tenant
actor has store authority if store-scoped
actor has role for action
object belongs to same tenant/store scope
action is allowed for object state
```

Object ID knowledge must never grant access.

---

## 11. Database Security Rule

Database design must follow deny-by-default.

Required rules:

```text
RLS enabled for client-accessible tables
deny-by-default policy
tenant isolation
store isolation where applicable
no broad anonymous access
service_role key never exposed to client
SECURITY DEFINER minimized
SECURITY DEFINER functions recheck authority internally
audit tables append-only
raw payload storage restricted
```

Database security is part of application security.

---

## 12. Supabase RPC Security Rule

Supabase RPC functions must be treated as authority-bearing endpoints.

Each RPC must define:

```text
actor type
allowed roles
tenant scope
store scope
input validation
state transition rule
audit event rule
error handling rule
```

High-risk RPC must not rely only on UI-level protection.

RPC functions must not accept arbitrary tenant_id or store_id without verifying actor authority.

---

## 13. SQL Migration Security Rule

Every SQL migration must be reviewed for security impact.

Review must check:

```text
new tables
new columns containing sensitive data
RLS status
policies
functions
triggers
grants
indexes exposing lookup patterns
views
security definer functions
audit behavior
seed data
```

A migration that creates a client-visible table without RLS must be blocked unless explicitly justified.

---

## 14. Secret Handling Rule

Code must never contain real secrets.

Prohibited:

```text
hardcoded API key
hardcoded webhook secret
service_role key in frontend
provider credential in repository
secret in markdown document
secret in screenshot
secret in test fixture
secret in log statement
```

Required:

```text
secret manager or secure environment variable
test and production separation
masked logging
rotation plan
revocation plan
secret scan before commit
```

Secret management details are governed by Foundation Security credential policy and integration credential policy.

---

## 15. Dependency Security Rule

Dependencies must be reviewed and monitored.

Required checks:

```text
known vulnerability scan
license review where needed
unused dependency removal
pinning or controlled versioning
supply-chain risk review for critical libraries
update policy
patch policy
```

High-risk dependencies include:

```text
authentication library
payment library
crypto library
database client
HTTP client
file upload library
PDF/image parser
AI/LLM connector
admin dashboard package
```

---

## 16. Input Validation Rule

All external input must be validated.

External inputs include:

```text
customer form input
staff input
support input
provider webhook payload
POS payload
payment provider callback
file upload
QR parameter
deep link parameter
RPC input
admin configuration input
AI prompt or tool input
```

Validation must include:

```text
type
length
format
range
enum
ownership
state transition validity
```

Validation failure must not expose internal stack traces.

---

## 17. Output Minimization Rule

APIs must return only necessary data.

Output must exclude:

```text
raw CI
raw DI
full phone unless needed
full email unless needed
credential
secret
internal stack trace
raw provider payload unless restricted
audit internals unless authorized
other tenant data
other store data
```

Default response should be minimal.

Additional fields require explicit authorization.

---

## 18. Error Handling Rule

Errors must be safe and actionable.

User-facing errors should be simple.

Support-facing errors may include diagnostic codes.

Prohibited user-facing exposure:

```text
SQL error
stack trace
provider secret
internal table name
RLS policy name
server file path
raw payload
internal token
```

Allowed support-facing details:

```text
diagnostic error code
trace_id
request_id
provider_id
masked reference
affected runtime
recommended action
```

---

## 19. Logging Rule

Logs must be structured and safe.

Logs may include:

```text
trace_id
request_id
tenant_id
store_id
runtime_family
event_type
diagnostic_error_code
masked customer reference
order reference
payment reference
```

Logs must not include:

```text
raw CI
raw DI
full phone
full email
API key
webhook secret
service_role key
raw access token
refresh token
raw bank account
unmasked provider identity
```

Logging policy must align with Foundation Security 001.

---

## 20. Audit Rule

Authority-sensitive actions must create audit events.

Authority-sensitive actions include:

```text
payment verification
KDS release
manual fallback approval
refund review trigger
reconciliation conclusion
credential rotation
provider configuration change
role change
support reveal
identity reveal
export
RLS bypass action
```

Audit must be append-only.

Audit must not contain raw secrets or raw CI/DI.

---

## 21. Frontend Security Rule

Frontend must not be trusted as authority.

Frontend must not contain:

```text
provider secret
service_role key
admin override key
webhook secret
database secret
refund authority token
```

Frontend may request actions.

Trusted backend or database policy must decide whether actions are allowed.

Frontend must handle:

```text
token expiration
reauthentication
role-based UI hiding
safe error display
local storage minimization
```

UI hiding is usability, not security.

---

## 22. Flutter Client Rule

Flutter client must follow mobile security rules.

Required:

```text
no hardcoded production secrets
no service_role key
secure storage only for allowed tokens
token expiration handling
minimal local cache
masked display for sensitive data
safe crash logs
no sensitive screenshots where restricted
```

Flutter client must not decide payment truth, KDS release authority, or refund authority.

---

## 23. Webhook Handler Rule

Webhook handlers must be security-critical code.

Required:

```text
signature verification where available
timestamp freshness
duplicate event detection
payload hash
provider identity check
merchant or store scope check
capability check
safe raw payload storage
idempotent processing
audit for authority-sensitive result
```

Webhook received does not equal webhook trusted.

---

## 24. Payment Code Rule

Payment code is high risk.

Payment code must enforce:

```text
amount lock
payment request identity
provider verification
duplicate prevention
amount mismatch detection
payment status conflict handling
manual fallback marking
reconciliation requirement
audit event
```

Payment code must not trust customer claim, display state, or unverified webhook as payment truth.

---

## 25. KDS Release Code Rule

KDS release code is authority-sensitive.

KDS release must check:

```text
internal_order_id
payment eligibility
release eligibility
idempotency key
current KDS state
manual fallback status
audit requirement
```

KDS release must not be triggered directly by:

```text
customer display
unverified provider event
external POS paid label without verification
support note
staff claim without fallback approval
```

---

## 26. Support Console Code Rule

Support console must be tightly controlled.

Support console must enforce:

```text
role-based access
tenant/store scope
masked identity
no raw credential display
purpose entry for sensitive reveal
reauthentication for high-risk action
audit on reveal and export
no direct payment truth mutation
no direct KDS release
```

Support is an operational assistance runtime.

It is not a truth mutation runtime.

---

## 27. Admin Console Code Rule

Admin console is high risk.

Admin actions must require:

```text
role authority
tenant scope
configuration scope
reauthentication for sensitive changes
change reason
audit event
rollback path
```

High-risk admin actions include:

```text
provider credential change
payment provider configuration
KDS integration configuration
role permission change
RLS-related setting
identity export
support access grant
```

---

## 28. AI And Agent Code Rule

AI/Agent code must be data-minimized and authority-limited.

AI/Agent must not receive:

```text
raw CI
raw DI
raw credential
full payment credential
full customer identity
unmasked provider payload
```

AI/Agent must not directly execute:

```text
payment verification
refund approval
KDS release
reconciliation closure
credential rotation
role assignment
```

AI may recommend.

Human or approved runtime must execute.

---

## 29. File Upload Rule

File upload must be treated as untrusted input.

Required controls:

```text
file type validation
size limit
malware scanning where applicable
storage isolation
access control
safe filename handling
metadata stripping where needed
restricted preview
audit for sensitive evidence upload
```

Uploaded files must not be executable.

---

## 30. Test Data Rule

Test data must not contain real sensitive data.

Prohibited in test fixtures:

```text
real CI
real DI
real phone
real email
real bank account
real provider credential
real payment token
real customer identity payload
```

Allowed:

```text
synthetic identity
masked examples
fake provider payload
test credential placeholder
sandbox credential stored securely
```

---

## 31. Code Review Security Checklist

Code review must check:

```text
authorization enforced server-side
tenant/store scope checked
input validated
output minimized
RLS applied where needed
no secrets in code
no sensitive data in logs
idempotency for duplicate events
safe error handling
audit for authority-sensitive actions
fallback state preserved
reconciliation required where uncertainty exists
```

Security-critical features require deeper review.

---

## 32. Automated Security Checks

The CI/CD pipeline should include:

```text
secret scanning
dependency vulnerability scanning
static analysis where available
linting for dangerous patterns
SQL migration review checklist
test coverage for authorization
RLS regression tests
webhook signature tests
idempotency tests
```

A failing high-risk security check must block merge or deployment.

---

## 33. Authorization Test Requirement

Every authority-sensitive endpoint or RPC must have authorization tests.

Required test cases:

```text
unauthenticated actor blocked
wrong tenant blocked
wrong store blocked
wrong role blocked
read-only role cannot write
support cannot mutate truth
customer cannot access other order
manager cannot access other tenant
expired token blocked
revoked device token blocked
```

Authorization tests are not optional.

---

## 34. RLS Regression Test Requirement

Client-accessible database objects must have RLS tests.

Required tests:

```text
tenant isolation
store isolation
self access
manager access
owner access
HQ access
support access
anonymous denial
cross-tenant denial
cross-store denial
```

RLS changes must not be accepted without regression checks.

---

## 35. Deployment Gate

Deployment must pass security gates.

Deployment gate should check:

```text
security review completed
migration review completed
RLS review completed
secret scan passed
dependency scan passed or exception approved
high-risk tests passed
audit events verified
rollback plan exists
known vulnerabilities reviewed
```

Production deployment must not occur if critical security gate fails.

---

## 36. Vulnerability Response Rule

When a vulnerability is found, the system must classify and respond.

Severity levels:

```text
LOW
MEDIUM
HIGH
CRITICAL
EMERGENCY
```

Response should include:

```text
triage
impact analysis
temporary mitigation
fix owner
patch
test
deploy
audit
postmortem if high risk
```

Payment, credential, identity, and cross-tenant vulnerabilities are high risk by default.

---

## 37. Security Exception Rule

Security exceptions may be allowed only with explicit record.

Exception record must include:

```text
exception_id
risk description
affected feature
reason
temporary mitigation
owner
approval
expiration date
review date
```

Permanent silent exceptions are prohibited.

---

## 38. Prohibited Handling

The following are prohibited:

```text
shipping feature without authorization checks
shipping client-visible table without RLS
using frontend role checks as security boundary
committing secrets
logging credentials
logging raw CI/DI
returning other tenant data
using service_role key in client
letting support mutate payment truth
letting AI execute authority-sensitive action
closing security issue without evidence
```

---

## 39. MVP Cutline

For MVP, secure coding and DevSecOps must support:

```text
secure coding checklist
code review security checklist
secret scanning
dependency scanning
RLS review
authorization tests for high-risk RPC
webhook signature test
idempotency test
safe logging rule
audit event requirement
deployment security gate
security exception record
```

Excluded from MVP:

```text
full enterprise GRC platform
formal external penetration test for every release
complete SAST/DAST automation across all languages
advanced runtime application self-protection
full bug bounty program
formal ISO certification
formal financial audit certification
```

MVP must still avoid critical security mistakes.

---

## 40. Relationship To Foundation Security 001

Foundation Security 001 defines customer identifier, CI/DI, and sensitive identity protection.

This document defines how coding and delivery must enforce those rules.

The relationship is:

```text
Foundation Security 001 = what sensitive identity must be protected
Foundation Security 002 = how development must prevent insecure handling
```

---

## 41. Relationship To 04000 Integration Security

04000 integration security documents must follow this policy.

Examples:

```text
04450 RPC security must include authorization tests
04460 credential policy must include secret scanning and rotation checks
POS adapter code must pass capability checks
payment webhook code must pass signature and idempotency tests
KDS release code must pass authority tests
```

Integration security is not complete without secure coding gates.

---

## 42. Financial-Grade Alignment

This project should follow financial-grade security discipline even if it is not initially a licensed financial institution.

The reasons are:

```text
payment handling
refund review
settlement candidate data
provider credentials
customer identity
store revenue impact
POS integration
webhook authority
support access
audit evidence
```

Financial-grade alignment means:

```text
least privilege
segregation of duties
strong access control
auditability
secure development lifecycle
vulnerability management
incident response
data minimization
credential protection
change control
```

---

## 43. Readiness Check

This policy is ready when:

```text
security gates are defined
secure coding baseline is defined
authentication and authorization are separated
BOLA/IDOR defense is required
database RLS security is required
Supabase RPC security is defined
SQL migration review is required
secret handling is prohibited in code
logging rules are defined
audit rules are defined
frontend and Flutter limits are defined
webhook code rules are defined
payment and KDS code rules are defined
support and admin console code rules are defined
AI/Agent limits are defined
code review checklist exists
automated checks are defined
deployment gate exists
vulnerability response exists
security exception process exists
financial-grade alignment is stated
```

---

## 44. Summary

Security is not a final inspection.

Security is part of development.

Every feature must prove:

```text
who can call it
what they can access
what they can change
what data is exposed
what is logged
what is audited
what happens on failure
how it is tested
how it is deployed
how it is fixed if vulnerable
```

This policy turns security from a vague promise into a development gate.

If a feature cannot pass the appropriate security gate, it is not ready for production.
