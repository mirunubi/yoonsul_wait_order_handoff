# 20003_Foundation_Security_Secret_Management_Credential_Vault_And_Key_Rotation_Policy

## 1. Purpose

This document defines the foundation-level secret management, credential vault, and key rotation policy.

The purpose of this policy is to prevent secrets, credentials, service keys, webhook secrets, provider API keys, database keys, encryption keys, device tokens, and internal service tokens from being exposed, reused, over-scoped, hardcoded, logged, exported, or retained beyond necessity.

Secrets are not configuration text.

Secrets are authority-bearing assets.

A leaked secret may allow unauthorized data access, payment manipulation, provider impersonation, webhook forgery, internal RPC abuse, or cross-tenant damage.

---

## 2. Scope

This policy applies to:

```text
provider API keys
payment provider API keys
POS provider credentials
webhook secrets
webhook signature keys
service-to-service tokens
Supabase anon key
Supabase service_role key
database connection secrets
Edge Function secrets
OAuth client secrets
OAuth refresh tokens
device tokens
local agent tokens
KDS bridge tokens
support console privileged tokens
admin console privileged tokens
encryption keys
field-level encryption keys
key-encryption keys
backup encryption keys
test credentials
staging credentials
production credentials
```

This policy applies across:

```text
backend runtime
frontend runtime
Flutter client
Supabase
PostgreSQL
Edge Functions
POS adapters
payment adapters
KDS bridge
local agent
support console
admin console
CI/CD pipeline
developer machines
test fixtures
documentation
logs
audit
```

---

## 3. Core Principle

Secrets must be minimized, isolated, scoped, masked, rotated, revocable, and audited.

The core rule is:

```text
no secret in code
no secret in frontend
no secret in logs
no secret in markdown
no secret in screenshots
no secret in support tickets
no production secret in test
no global secret unless explicitly approved
no long-lived privileged secret without rotation plan
```

A secret must be treated as an authority object.

---

## 4. Secret Classification

All secrets must be classified before use.

Allowed secret classes include:

```text
PUBLIC_CLIENT_KEY
CLIENT_LIMITED_KEY
SERVICE_SECRET
DATABASE_SECRET
PROVIDER_API_KEY
PAYMENT_PROVIDER_SECRET
POS_PROVIDER_SECRET
WEBHOOK_SECRET
SIGNATURE_KEY
OAUTH_CLIENT_SECRET
OAUTH_REFRESH_TOKEN
DEVICE_TOKEN
LOCAL_AGENT_TOKEN
KDS_BRIDGE_TOKEN
SUPPORT_PRIVILEGED_TOKEN
ADMIN_PRIVILEGED_TOKEN
ENCRYPTION_KEY
KEY_ENCRYPTION_KEY
BACKUP_KEY
TEST_SECRET
PRODUCTION_SECRET
```

Unclassified secrets must not be used in runtime.

---

## 5. Secret Risk Level

Each secret must have a risk level.

Allowed risk levels:

```text
LOW
MEDIUM
HIGH
CRITICAL
CATASTROPHIC
```

Examples:

```text
Supabase anon key with RLS-safe public access = MEDIUM
provider read-only API key = HIGH
payment provider payment creation key = CRITICAL
refund-capable payment key = CATASTROPHIC
Supabase service_role key = CATASTROPHIC
field-level encryption master key = CATASTROPHIC
```

Risk level determines rotation, access, logging, review, and incident response requirements.

---

## 6. Secret Scope Rule

Each secret must declare scope.

Required scope fields include:

```text
environment
tenant_scope
store_scope
provider_scope
runtime_scope
allowed_actions
created_at
expires_at if applicable
rotation_owner
revocation_owner
```

Secrets must be scoped as narrowly as possible.

Preferred scope order:

```text
single runtime
single provider integration
single store
single tenant
limited environment
```

Avoid:

```text
all tenants
all stores
all providers
all environments
all actions
```

unless explicitly approved as critical infrastructure secret.

---

## 7. Environment Separation Rule

Secrets must be separated by environment.

Allowed environments:

```text
LOCAL_DEV
TEST
STAGING
PILOT
PRODUCTION
```

The following are prohibited:

```text
using production secret in local development
using production webhook secret in test
using test provider key in production
copying production database key into developer notes
sharing one provider secret across staging and production
```

Environment mixing must be treated as a security defect.

---

## 8. Secret Storage Rule

Secrets must be stored only in approved secure storage.

Approved storage may include:

```text
managed secret manager
encrypted environment variable managed by deployment platform
encrypted credential vault
provider credential vault
database encrypted secret reference
```

Prohibited storage includes:

```text
source code
git repository
markdown document
README
spreadsheet
chat message
support ticket
plain text local file
screenshot
browser local storage
frontend bundle
mobile app bundle
debug log
raw payload archive
```

---

## 9. Frontend Secret Rule

Frontend applications must never contain authority-bearing secrets.

Frontend may contain:

```text
public client key
limited anonymous key
publishable payment key if provider explicitly allows it
public configuration
```

Frontend must not contain:

```text
service_role key
provider API secret
webhook secret
database password
refund-capable key
admin override token
KDS bridge secret
local agent master secret
encryption key
```

Frontend checks are not security boundaries.

---

## 10. Supabase Key Rule

Supabase keys must be handled carefully.

The Supabase anon key may be used only when RLS and policies enforce access correctly.

The Supabase service_role key must be treated as catastrophic risk.

Rules:

```text
service_role key must never be in Flutter
service_role key must never be in browser frontend
service_role key must never be committed
service_role key must never appear in logs
service_role key must be available only to trusted backend or controlled server runtime
service_role use must be minimized
service_role actions must be audited where authority-sensitive
```

RLS must not be bypassed casually.

---

## 11. Database Secret Rule

Database credentials must be restricted.

Database secret handling must include:

```text
least privilege user where possible
separate migration credential
separate application credential
separate read-only credential where needed
no shared personal DBA password for runtime
rotation procedure
backup access control
connection string masking
```

Database connection strings must never appear in logs, docs, support messages, or screenshots.

---

## 12. Provider Secret Rule

Provider secrets must be scoped to the provider integration.

Provider secret types include:

```text
POS provider API key
payment provider API key
webhook secret
merchant token
terminal token
partner credential
OAuth secret
```

Provider secrets must be linked to:

```text
provider_id
tenant_id if applicable
store_id if applicable
integration_id
environment
capability_level
allowed_actions
```

A read-only adapter should not receive write-capable credentials.

---

## 13. Webhook Secret Rule

Webhook secrets must be used only to verify incoming provider events.

Webhook secret rules:

```text
do not expose to frontend
do not expose to support
do not log
do not include in raw payload archive
do not include in diagnostic error text
do not copy into audit memo
rotate if suspected exposure
support dual-secret rotation where provider allows
```

Webhook verification failure must not update authority-sensitive state.

---

## 14. Service-To-Service Token Rule

Internal service tokens must be scoped by runtime and authority.

Service tokens should define:

```text
caller_runtime
target_runtime
authority_scope
tenant_scope
store_scope if applicable
expiration
rotation policy
```

A service token for Customer Display Runtime must not allow Payment Runtime mutation.

A KDS bridge token must not allow payment verification.

A support token must not allow raw provider event rewrite.

---

## 15. Device Token Rule

Device tokens must be scoped and revocable.

Device token scope should include:

```text
tenant_id
store_id
device_id
device_type
allowed_runtime
allowed_actions
issued_at
expires_at if applicable
last_seen_at
revoked_at
```

Device examples:

```text
counter tablet
table tablet
kiosk
KDS screen
manager device
local agent device
```

Lost, stolen, retired, or reassigned devices must have tokens revoked.

---

## 16. Local Agent Secret Rule

Local agent secrets are high risk because the agent may bridge offline store operation and central runtime.

Local agent secrets must be:

```text
store-scoped
device-bound where possible
rotatable
revocable
limited to relay/cache actions
audited on sensitive sync
```

Local agent secrets must not allow:

```text
cross-store mutation
payment verification authority
refund execution
credential management
audit deletion
identity reveal
```

---

## 17. Encryption Key Rule

Encryption keys must be handled separately from encrypted data.

Encryption key policy must include:

```text
separate key storage
restricted key access
key rotation plan
key revocation or retirement plan
backup key protection
no plaintext key logging
no plaintext key documentation
no key exposure to support tools
```

Field-level encryption keys and key-encryption keys are critical or catastrophic secrets.

---

## 18. Key Hierarchy Rule

The system should distinguish:

```text
data encryption key
field encryption key
key encryption key
backup encryption key
signing key
verification key
transport credential
```

Key hierarchy should avoid using one key for all purposes.

One key must not be reused for:

```text
encryption
signing
webhook verification
database access
service authentication
backup encryption
```

Purpose separation reduces breach impact.

---

## 19. Secret Injection Rule

Secrets must be injected into runtime through controlled channels.

Allowed methods:

```text
deployment secret manager
encrypted environment variable
runtime secret reference
vault lookup
short-lived token issuance
```

Prohibited methods:

```text
hardcoded string
checked-in .env file
manual copy into source file
frontend build-time injection of server secret
chat copy-paste
spreadsheet copy-paste
support ticket copy-paste
```

Secret injection must be environment-specific.

---

## 20. Secret Access Rule

Secret access must follow least privilege.

Access must be limited by:

```text
role
runtime
purpose
environment
tenant or store where applicable
time
approval where high risk
```

High-risk secret reveal must require:

```text
reauthentication
reason
audit event
time limit
post-access review if needed
```

Direct human access to raw secrets should be exceptional.

---

## 21. Secret Rotation Rule

Secrets must be rotatable.

Rotation triggers include:

```text
scheduled rotation
suspected exposure
confirmed exposure
employee offboarding
vendor support event
provider recommendation
store ownership change
device loss
environment migration
dependency compromise
runtime compromise
credential scope change
```

Rotation must create audit event.

Rotation must include validation and old secret revocation.

---

## 22. Rotation State Model

Secret rotation may use:

```text
ACTIVE
ROTATION_REQUIRED
ROTATION_SCHEDULED
ROTATION_IN_PROGRESS
NEW_SECRET_ISSUED
DUAL_SECRET_WINDOW
OLD_SECRET_DEPRECATED
OLD_SECRET_REVOKED
ROTATION_COMPLETED
ROTATION_FAILED
EMERGENCY_REVOKED
```

Dual-secret window must have expiration.

Old secrets must not remain active indefinitely.

---

## 23. Rotation Procedure

Standard rotation procedure:

```text
1. identify secret and scope
2. issue new secret
3. store new secret securely
4. update runtime reference
5. validate connection or verification
6. monitor failures
7. revoke old secret
8. record audit event
9. close rotation record
```

Emergency rotation may skip scheduling but must not skip audit.

---

## 24. Revocation Rule

Secrets must be revocable.

Revocation triggers include:

```text
confirmed compromise
store contract termination
provider contract termination
device loss
employee offboarding
support tool compromise
local agent compromise
production migration
integration decommission
```

Revoked secret usage must be detected and alerted.

---

## 25. Secret Exposure Incident Rule

If a secret is exposed, treat it as a security incident.

Response must include:

```text
identify exposed secret
classify risk level
determine scope
contain access
rotate or revoke secret
review logs
review affected provider calls
review affected tenants and stores
check unauthorized actions
preserve evidence
notify internal owner
create remediation task
```

For catastrophic secrets, immediate emergency response is required.

---

## 26. Logging Rule

Logs must not contain secrets.

Prohibited log contents:

```text
Authorization header
Bearer token
API key
service_role key
database password
webhook secret
OAuth refresh token
provider secret
encryption key
raw credential JSON
```

Allowed safe references:

```text
secret_reference
provider_id
integration_id
masked_key_suffix
secret_class
verification_result
diagnostic_error_code
```

If a secret appears in logs, it is secret exposure.

---

## 27. Documentation Rule

Documentation must never contain real secrets.

Prohibited:

```text
real API key in README
real webhook secret in markdown
real .env file in docs
provider credential JSON in document
screenshot showing secret
curl example with live token
database URL with password
```

Allowed placeholders:

```text
<PROVIDER_API_KEY>
<WEBHOOK_SECRET>
<SUPABASE_ANON_KEY>
<SUPABASE_SERVICE_ROLE_KEY>
<DATABASE_URL>
<MERCHANT_ID>
<STORE_TOKEN>
```

---

## 28. Git Rule

Secrets must never be committed to git.

Required controls:

```text
.gitignore for local env files
secret scanning before commit
secret scanning in CI
blocked commit or deployment on detected secret
rotation if secret is committed
history review if secret exposure occurred
```

A secret committed and removed later is still exposed.

It must be rotated.

---

## 29. Test Data And Fixture Rule

Test fixtures must not contain production secrets.

Allowed:

```text
fake secret placeholders
sandbox credentials stored securely
synthetic provider payload
masked examples
```

Prohibited:

```text
production API key
production webhook secret
real customer token
real payment token
real database connection string
real service_role key
```

---

## 30. CI/CD Secret Rule

CI/CD systems must protect secrets.

Required controls:

```text
repository secret storage
environment-specific secret separation
restricted workflow access
no secret echo
no secret printing
masked build logs
deployment approval for production secrets
secret rotation after CI compromise
```

CI/CD logs must be treated as potential exposure surfaces.

---

## 31. Backup Secret Rule

Backups may contain sensitive encrypted data.

Backup key handling must include:

```text
backup encryption
backup key isolation
restricted restore access
restore audit
no plaintext backup key in docs
backup retention policy
restore drill security review
```

Backup access may expose historical data.

It must be controlled.

---

## 32. Secret Masking Rule

Secrets must be masked when displayed.

Support/admin display may show:

```text
secret class
status
environment
last rotated at
expires at
masked suffix
owner runtime
```

Must not show:

```text
full secret value
full token
full connection string
full private key
OAuth refresh token
service_role key
```

---

## 33. Secret Ownership Rule

Each secret must have an owner.

Owner types include:

```text
runtime owner
provider integration owner
security owner
platform owner
store integration owner
deployment owner
```

Secret owner responsibilities:

```text
scope review
rotation
revocation
incident response
access review
documentation of usage
```

Unowned secrets must be removed or assigned.

---

## 34. Secret Inventory Rule

The system must maintain a secret inventory.

Inventory fields should include:

```text
secret_reference
secret_class
risk_level
environment
runtime_owner
provider_id if applicable
tenant_scope
store_scope
allowed_actions
created_at
last_rotated_at
expires_at
rotation_status
revocation_status
```

Secret inventory must not contain raw secret values.

---

## 35. Access Review Rule

Secret access must be reviewed periodically.

Review should check:

```text
who can access
which runtime can access
whether scope is still valid
whether secret is over-privileged
whether rotation is overdue
whether owner is still valid
whether environment is correct
```

High-risk secrets require more frequent review.

---

## 36. Separation Of Duties Rule

High-risk secret operations should separate duties where possible.

Examples:

```text
developer may request secret
security/platform owner approves
deployment system injects secret
runtime uses secret
support cannot reveal secret
audit records access
```

No single ordinary operator should casually reveal, rotate, and deploy catastrophic secrets without trace.

---

## 37. Financial-Grade Alignment

This policy follows financial-grade security discipline.

Financial-grade secret management requires:

```text
least privilege
strong access control
environment separation
change control
auditability
rotation
revocation
incident response
key management
segregation of duties
```

Payment, refund, settlement, identity, and provider credentials must be treated as high-risk assets even if the platform is not initially a licensed financial institution.

---

## 38. Prohibited Handling

The following are prohibited:

```text
hardcoding secrets
committing secrets to git
placing secrets in frontend code
placing service_role key in Flutter
logging Authorization headers
showing secrets in support screen
copying secrets into chat
copying secrets into tickets
using production secrets in test
using one global provider secret without approval
leaving old webhook secret active indefinitely
using write-capable secret for read-only adapter
storing encryption key beside encrypted data
treating masking as rotation
```

---

## 39. MVP Cutline

For MVP, the system must support:

```text
no secrets in code
no secrets in frontend
no secrets in logs
no secrets in markdown
environment separation
secret references instead of raw values
manual secret inventory
manual rotation procedure
manual revocation procedure
secret scanning before commit
CI secret scanning
masked support/admin display
audit event for high-risk secret access
Supabase service_role key protection
provider webhook secret protection
```

Excluded from MVP:

```text
full enterprise key management platform
automatic rotation for every provider
hardware security module
complete just-in-time secret issuance
full service mesh identity
formal key ceremony
automated secret owner review
```

MVP must still prevent catastrophic secret exposure.

---

## 40. Relationship To Foundation Security 001

Foundation Security 001 protects sensitive customer identity.

This document protects secrets and credentials.

The relationship is:

```text
Foundation Security 001 = protect customer identity
Foundation Security 003 = protect authority credentials and keys
```

A customer identifier leak harms privacy.

A secret leak may allow unauthorized system action.

Both must be handled as high-risk security issues.

---

## 41. Relationship To Foundation Security 002

Foundation Security 002 defines secure coding and DevSecOps gates.

This document defines secret management rules that must be enforced by those gates.

Examples:

```text
secret scanning before commit
no hardcoded secrets
no frontend authority secrets
no secret logs
rotation on exposure
secret access audit
```

Secure coding is incomplete without secret control.

---

## 42. Relationship To 04000 Integration Security

04000 integration security documents must reference this policy.

Examples:

```text
04450 RPC security depends on service tokens and webhook verification
04460 POS webhook signature and credential isolation must follow this foundation
payment provider integration must protect API keys
KDS bridge must use scoped credentials
local agent must use store-scoped tokens
```

Integration security cannot be trusted if secret management is weak.

---

## 43. Readiness Check

This policy is ready when:

```text
secret classes are defined
secret risk levels are defined
secret scopes are required
environment separation is required
approved storage is defined
frontend secrets are prohibited
Supabase service_role protection is explicit
provider secrets are scoped
webhook secrets are protected
service-to-service tokens are scoped
device tokens are revocable
local agent secrets are restricted
encryption key rules are defined
secret injection is controlled
rotation and revocation are defined
secret exposure incident response exists
logging and documentation prohibitions are defined
git secret rules are defined
CI/CD secret handling is defined
secret inventory is required
financial-grade alignment is stated
MVP cutline is explicit
```

---

## 44. Summary

Secrets are authority.

A leaked customer identifier exposes privacy.

A leaked secret exposes control.

Therefore, the system must ensure:

```text
secrets are not in code
secrets are not in frontend
secrets are not in logs
secrets are not in docs
secrets are scoped
secrets are rotated
secrets are revocable
secrets are audited
secrets are environment-separated
```

No POS, payment, KDS, support, AI, or provider integration can be considered secure unless its secrets are controlled.
