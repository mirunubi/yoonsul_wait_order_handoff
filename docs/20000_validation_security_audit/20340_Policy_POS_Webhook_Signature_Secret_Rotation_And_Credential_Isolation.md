# 20340_Policy_POS_Webhook_Signature_Secret_Rotation_And_Credential_Isolation

Legacy path: $old.
1. Purpose
This document defines the POS webhook signature, secret rotation, and credential isolation policy.
The purpose of this policy is to prevent POS, payment, table order, kiosk, delivery, KDS bridge, local agent, device, support, admin, and provider integration credentials from becoming uncontrolled operational secrets.
Provider credentials, webhook secrets, API keys, merchant tokens, service tokens, device tokens, bridge credentials, and local agent credentials must be scoped, isolated, masked, rotated, revocable, audited, environment-separated, and never exposed through logs, support screens, customer displays, raw payloads, exported diagnostics, markdown documents, screenshots, or frontend code.
This is an integration-level enforcement document under Foundation Security.

2. Foundation Security Inheritance
This document inherits and must comply with:
Foundation Security 001 Customer Identifier CI DI And Sensitive Identity Protection Policy
Foundation Security 002 Secure Coding And DevSecOps Gate Policy
Foundation Security 003 Secret Management Credential Vault And Key Rotation Policy
Foundation Security 004 Cloud Security Financial Sector Alignment Policy
Foundation Security 005 Access Control RBAC ABAC And Least Privilege Policy
Foundation Security 006 Logging Audit Evidence And Tamper Resistance Policy
Foundation Security 007 Vulnerability Patch Dependency And Incident Response Policy
Foundation Security 008 Data Retention Deletion Export And Privacy Response Policy
Foundation Security 009 Security Governance Index And Financial-Grade Readiness Check

This document may add stricter rules for POS, PG, KDS, provider, webhook, device, and local agent credentials.
It must not weaken Foundation Security.

3. Scope
This policy applies to:
POS provider API keys
payment provider API keys
PAYCO or equivalent provider credentials
Toss or equivalent provider credentials
webhook secrets
webhook signature keys
merchant tokens
store tokens
terminal tokens
adapter service tokens
KDS bridge credentials
local agent credentials
table order provider credentials
kiosk provider credentials
delivery provider credentials
support tool credentials
admin tool credentials
device tokens
test credentials
staging credentials
pilot credentials
production credentials

This policy does not define CI/DI or customer identity vault rules.
Sensitive customer identity is governed by Foundation Security 001.
General secret management is governed by Foundation Security 003.
RPC trust enforcement is governed by 04450.

4. Core Principle
Credentials are authority-bearing objects.
The core rule is:
credential exposure = authority exposure
webhook secret exposure = event trust exposure
provider key exposure = integration control exposure
service token exposure = internal runtime risk
device token exposure = store operation risk
local agent credential exposure = offline/bridge risk

Therefore, credentials must be:
scoped
isolated
masked
rotatable
revocable
audited
environment-separated
least-privilege by default

A credential must never be treated as ordinary configuration text.

5. Credential Classification
Credentials must be classified by type.
Allowed credential classes include:
PROVIDER_API_KEY
PROVIDER_SECRET
PAYMENT_PROVIDER_SECRET
POS_PROVIDER_SECRET
WEBHOOK_SECRET
WEBHOOK_SIGNATURE_KEY
MERCHANT_TOKEN
STORE_TOKEN
TERMINAL_TOKEN
SERVICE_TOKEN
DEVICE_TOKEN
LOCAL_AGENT_TOKEN
KDS_BRIDGE_TOKEN
OAUTH_CLIENT_SECRET
OAUTH_REFRESH_TOKEN
DATABASE_SERVICE_SECRET
TEST_CREDENTIAL
STAGING_CREDENTIAL
PILOT_CREDENTIAL
PRODUCTION_CREDENTIAL

Each credential must have a class before use.
Unclassified credentials must not be loaded into runtime.

6. Credential Risk Level
Each credential must have a risk level.
Allowed risk levels:
LOW
MEDIUM
HIGH
CRITICAL
CATASTROPHIC

Examples:
store-scoped read-only POS key = HIGH
payment provider payment creation key = CRITICAL
refund-capable payment provider key = CATASTROPHIC
Supabase service_role key = CATASTROPHIC
webhook secret for payment authority event = CRITICAL
local agent store relay token = HIGH
KDS bridge token = HIGH

Risk level determines access, rotation, revocation, monitoring, and incident response.

7. Credential Scope Rule
Every credential must declare its scope.
Required scope fields include:
tenant_id
store_id if store-scoped
provider_id
integration_id
environment
credential_class
allowed_runtime
allowed_actions
capability_level
created_at
expires_at if applicable
rotation_status
revocation_status

A credential without tenant, store, provider, or runtime scope must be treated as high risk.
A global credential must require explicit security approval.

8. Environment Separation Rule
Test, staging, pilot, and production credentials must be separated.
Allowed environments:
LOCAL_DEV
TEST
STAGING
PILOT
PRODUCTION

The following are prohibited:
using production credential in test
using test credential in production
copying production webhook secret into development logs
using shared merchant token across environments
mixing sandbox provider events with production order events
placing production credential in developer notebook

Environment mixing is a security defect.

9. Credential Storage Rule
Credentials must be isolated from ordinary operational data.
Provider credentials must not be stored in:
order table
payment event table
KDS ticket table
support ticket text
diagnostic error text
raw payload memo
customer display state
audit memo text
markdown document
screenshot
frontend bundle
Flutter app bundle

Provider credentials should be referenced through:
credential_reference
secret_manager_reference
vault_reference
integration_credential_id

Operational records must not contain raw secrets.

10. Frontend And Flutter Secret Rule
Frontend and Flutter applications must never contain authority-bearing secrets.
Frontend may contain only:
public client key
limited anonymous key
publishable payment key if provider explicitly permits it
public configuration

Frontend and Flutter must not contain:
service_role key
provider API secret
webhook secret
database password
refund-capable key
admin override token
KDS bridge secret
local agent master secret
encryption key

UI hiding is not credential protection.

11. Supabase Service Role Boundary
Supabase service_role key is catastrophic risk.
Rules:
service_role key must never be in frontend
service_role key must never be in Flutter
service_role key must never be committed
service_role key must never appear in logs
service_role key must never appear in screenshots
service_role key must never be sent to support
service_role key must be available only to trusted backend or controlled server runtime
service_role use must be minimized
service_role actions must be audited where authority-sensitive

If service_role key exposure is suspected, emergency rotation and incident response are required.

12. Webhook Secret Rule
Webhook secrets must be used only to verify provider events.
Webhook secret rules:
do not expose webhook secret to client
do not log webhook secret
do not show webhook secret in support
do not store webhook secret in plain text
do not include webhook secret in diagnostic event
do not copy webhook secret into provider payload archive
do not paste webhook secret into vendor ticket

If webhook secret is suspected to be exposed, rotate immediately.

13. Webhook Signature Verification Rule
Webhook signature verification should validate:
provider identity
signature header
timestamp header if available
payload hash
secret or public key reference
allowed time window
duplicate event status
provider event ID
merchant/store reference

If signature verification fails, the event must not mutate authority-sensitive state.
The event should be marked:
WEBHOOK_SIGNATURE_VERIFICATION_FAILED
RPCSEC-SIGN-001 signature verification failed

Payment or KDS authority must not be updated from an unverified webhook.

14. Dual Secret Window Rule
When webhook providers support two active secrets, a dual secret window may be used.
Dual secret window rules:
old secret accepted only during transition
new secret preferred
window must expire
both verification paths must be logged safely
old secret must be revoked after validation

Dual secret window must not become permanent.
If expiration is missed, create a credential control incident.

15. Provider Credential Isolation
Provider credentials must be scoped to the provider integration.
Provider secret types include:
POS provider API key
payment provider API key
webhook secret
merchant token
terminal token
partner credential
OAuth secret

Provider secrets must be linked to:
provider_id
tenant_id if applicable
store_id if applicable
integration_id
environment
capability_level
allowed_actions

A read-only adapter must not receive write-capable credentials unless exception is approved and audited.

16. Payment Provider Credential Rule
Payment provider credentials are high risk.
Payment provider credentials may allow:
payment request creation
payment status query
webhook verification
refund request if separately authorized
settlement status query if available

Refund-capable credentials must be classified as:
PAYMENT_REFUND_CAPABLE_HIGH_RISK

or:
CATASTROPHIC

depending on provider authority.
Refund-capable credentials require stricter access, rotation, monitoring, and incident response.

17. POS Provider Credential Rule
POS provider credentials must be capability-scoped.
Credential permission should match adapter level:
LEVEL_1_READ_ONLY_INTAKE = read credential only
LEVEL_2_EVENT_SYNC = event read or sync credential
LEVEL_3_OPERATIONAL_AUTHORITY_INTEGRATION = limited write credential if approved
LEVEL_4_CERTIFIED_DEEP_INTEGRATION = certified scoped credential

A read-only POS adapter must not use full admin POS credential.
Write-capable POS credentials require stronger review.

18. KDS Bridge Credential Rule
KDS bridge credentials must be scoped to kitchen integration.
KDS bridge may receive or emit:
KDS release request
KDS hold request
KDS cancel projection
KDS ticket state update
KDS bridge health report

KDS bridge credentials must not allow:
payment verification
refund approval
settlement mutation
customer identity reveal
provider credential access
support admin action

KDS bridge is kitchen execution boundary, not payment authority.

19. Local Agent Credential Rule
Local agent credentials must be store-scoped.
Local agent may support:
store event relay
local cache sync
device health report
fallback event upload
KDS bridge relay

Local agent credentials must not allow:
cross-store mutation
payment verification authority
refund execution
credential management
audit deletion
identity reveal

Offline local agent replay must be marked and reconciled if authority-sensitive.

20. Device Token Rule
Device tokens must be scoped and revocable.
Device token scope should include:
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

Device examples:
counter tablet
table tablet
kiosk
KDS screen
manager device
local agent device

Lost, stolen, retired, or reassigned devices must have tokens revoked.

21. Support Tool Credential Rule
Support tools must never reveal raw credentials.
Support may show:
credential status
credential class
provider name
environment
masked key suffix
last rotated at
expires at
rotation required flag
verification failure count

Support must not show:
raw API key
raw webhook secret
OAuth refresh token
database service secret
service token
device token
local agent token

Support may request rotation, but must not directly copy secrets.

22. Admin Credential Operation Rule
Admin credential operations are privileged actions.
Admin credential operations include:
create credential reference
rotate credential
revoke credential
change provider credential mapping
change webhook secret reference
change device token policy
change local agent credential

These actions require:
authorized role
reauthentication
change reason
audit event
rollback or recovery plan where applicable

Admin convenience must not override credential control.

23. Credential Capability Mismatch Rule
If credential authority exceeds adapter capability, the system must flag:
CREDENTIAL_CAPABILITY_MISMATCH

Example:
adapter level = read-only
credential permission = write/refund/full admin

This condition must be reviewed before production use.
Capability mismatch must create audit and may block production readiness.

24. Secret Injection Rule
Runtime services should receive secrets through controlled secret injection.
Allowed methods:
secret manager
environment variable from secure deployment
encrypted vault
runtime credential reference
scoped token issuance

Prohibited methods:
hardcoded secrets
secrets committed to git
secrets in markdown documents
secrets in screenshots
secrets in support chats
secrets in local plain text files
secrets in frontend code
secrets in Flutter app bundle

Secret injection must be environment-specific.

25. Git And Documentation Rule
Credentials must never be committed to repository or documentation.
Prohibited:
API keys in README
webhook secrets in markdown
.env files committed
screenshots showing secrets
curl examples with real tokens
provider credential JSON in docs
database URL with password

Documentation may use placeholders:
<PROVIDER_API_KEY>
<WEBHOOK_SECRET>
<MERCHANT_ID>
<STORE_TOKEN>
<SERVICE_ROLE_KEY>
<DATABASE_URL>

A committed secret must be rotated even if later removed.

26. Logging Rule
Logs must not contain secrets.
Prohibited log contents:
Authorization header
API key
Bearer token
webhook secret
signature secret
OAuth refresh token
database service key
provider password
raw credential JSON
service_role key

Allowed safe references:
credential_reference
provider_id
integration_id
masked_key_suffix
credential_class
verification_result
diagnostic_error_code

If a secret appears in logs, it must be treated as credential exposure.

27. Raw Payload Rule
Raw provider payloads must not include credentials.
If a provider sends credential-like material inside payload, the system must classify and mask it.
Credential-like fields include:
access_token
refresh_token
secret
api_key
authorization
password
client_secret
signature_secret
merchant_secret

Such values must be masked before general storage.
Restricted evidence storage may preserve reference, not general exposure.

28. Credential Rotation Trigger
Credentials must be rotatable.
Rotation triggers include:
scheduled rotation
provider recommendation
employee role change
store ownership change
provider integration change
suspected exposure
confirmed exposure
log leakage
vendor request
security incident
environment migration
adapter compromise
device loss
local agent compromise
support tool compromise

Rotation must be planned so live store operation is not silently broken.
Emergency rotation may prioritize containment.

29. Rotation State Model
Credential rotation may use the following states:
ACTIVE
ROTATION_REQUIRED
ROTATION_SCHEDULED
ROTATION_IN_PROGRESS
NEW_SECRET_ISSUED
DUAL_VALIDATION_WINDOW
OLD_SECRET_DEPRECATED
OLD_SECRET_REVOKED
ROTATION_COMPLETED
ROTATION_FAILED
EMERGENCY_REVOKED

Dual validation may be allowed temporarily when provider supports overlapping secrets.
Dual validation must have an expiration time.

30. Rotation Procedure
Standard rotation procedure:
1. identify credential and scope
2. create new credential
3. store new credential securely
4. update runtime credential reference
5. validate provider connection
6. validate webhook signature if applicable
7. monitor failures
8. revoke old credential
9. record audit event
10. close rotation task

Emergency rotation may skip scheduling but must not skip audit.

31. Credential Revocation Rule
Credentials must be revocable.
Revocation triggers include:
suspected compromise
confirmed compromise
store contract termination
provider contract termination
employee offboarding
device loss
local agent compromise
support tool breach
production migration
integration decommission

Revocation must create an audit event.
If revocation affects live operation, fallback and incident policy must be activated.

32. Store Ownership Change Rule
When store ownership or merchant account ownership changes, provider credentials must be reviewed.
Required actions:
review provider account owner
review merchant credential
review webhook endpoint
review store tokens
review terminal tokens
review support access
rotate or revoke old credentials
confirm new authority
audit completion

Old owner credentials must not remain active.

33. Device Loss Rule
If a store device is lost, stolen, or retired, related device tokens must be revoked.
Device examples:
counter tablet
table tablet
KDS screen
manager tablet
local agent device
kiosk device

Device token revocation must not require changing unrelated provider credentials unless exposure risk exists.
Device loss must create security or operational incident depending on risk.

34. Credential Access Rule
Credential access must follow least privilege.
Allowed access purposes include:
runtime verification
provider API call
webhook signature verification
credential rotation
credential revocation
security incident response

Prohibited access purposes include:
manual debugging convenience
support screen display
copy-paste into chat
copy-paste into ticket
export for vendor without approval
logging for trace analysis

Credential reveal should be blocked by default.

35. Credential Audit Requirements
The system must create append-only audit events for:
credential created
credential accessed
credential rotated
credential revoked
credential failed verification
credential capability mismatch detected
webhook secret rotated
webhook signature verification failed
device token revoked
local agent token rotated
payment credential accessed
refund-capable credential accessed
secret exposure suspected
secret exposure confirmed
emergency revocation performed

Audit events must not contain raw secrets.
Audit must link tenant, store, provider, integration, credential reference, actor, and purpose where applicable.

36. Monitoring Requirements
The system should monitor:
signature verification failure count
credential authentication failure count
provider permission denied count
expired credential usage count
revoked credential usage attempt
credential capability mismatch count
secret rotation failure count
webhook verification failure spike
unknown credential reference count
device token failure count
local agent token failure count
support credential access attempt

Monitoring should feed incident runbooks and support diagnostics.

37. Error Codes
Credential and webhook security failures may use diagnostic codes such as:
RPCSEC-SIGN-001 signature verification failed
RPCSEC-AUTH-001 missing authentication
RPCSEC-AUTH-002 invalid service token
RPCSEC-CAP-001 capability contract violation
RPCSEC-SECRET-001 credential missing
RPCSEC-SECRET-002 credential expired
RPCSEC-SECRET-003 revoked credential used
RPCSEC-SECRET-004 credential capability mismatch
RPCSEC-SECRET-005 secret exposure suspected
RPCSEC-SECRET-006 rotation failed
RPCSEC-WEBHOOK-001 webhook secret mismatch
RPCSEC-WEBHOOK-002 webhook timestamp outside tolerance

These codes must not expose raw secret values.

38. Incident Handling For Secret Exposure
If a credential is exposed, the incident must be handled as a security incident.
Required actions:
identify exposed credential
classify credential scope
classify credential risk level
contain access
rotate or revoke credential
review logs
review affected provider calls
review affected stores
check unauthorized actions
notify internal owner
preserve evidence
create post-incident remediation

If payment-capable, refund-capable, service_role, encryption key, or cross-tenant credential is exposed, escalation must be immediate.

39. Retention Rule
Credential records, audit records, and exposure evidence must follow Foundation Security 008.
Retention must distinguish:
credential inventory
credential status
rotation record
revocation record
secret exposure evidence
webhook verification logs
support credential access attempts

Raw secrets must not be retained in evidence packets unless absolutely necessary and restricted.
Prefer secret reference and masked suffix.

40. Secure Coding And Test Rule
Implementation of this policy must pass Foundation Security 002 gates.
Required tests include:
secret not present in frontend bundle
service_role key not accessible from client
webhook signature failure blocks authority
expired credential rejected
revoked credential rejected
credential capability mismatch detected
read-only adapter cannot use write action
credential value not logged
support view masks credentials
rotation audit created
revocation audit created

Credential policy is not complete without tests.

41. Prohibited Handling
The following are prohibited:
hardcoding provider secrets
committing secrets to git
showing raw secrets in support screen
logging Authorization headers
copying secrets into support tickets
using production credentials in test
using one global credential for all stores without approval
using write credential for read-only adapter
leaving old webhook secret active indefinitely
keeping lost device token active
treating encryption as substitute for rotation
placing service_role key in Flutter
placing webhook secret in customer display


42. MVP Cutline
For MVP, credential security must support:
provider credential reference
environment separation
webhook secret verification
secret masking
no frontend secrets
no Flutter authority secrets
no secrets in logs
no secrets in documentation
manual rotation procedure
manual revocation procedure
credential audit events
revoked credential detection
signature failure diagnostic code
credential capability mismatch flag
device token revocation
support credential masking
security incident trigger for exposure

Excluded from MVP:
full enterprise secret manager automation
automatic rotation for all providers
hardware security module
multi-region key management
advanced secret scanning pipeline
full just-in-time credential issuance
complete service mesh identity

MVP must still prevent catastrophic secret exposure.

43. Relationship To 04450 RPC Security
Document 04450 defines RPC communication security and provider trust boundary.
This document defines credential, secret, webhook signature, and rotation policy.
The relationship is:
04450 = how messages are trusted or rejected
04460 = how the secrets and credentials behind trust are protected

04450 cannot work safely without 04460.

44. Relationship To POS Integration Documents
This document supports:
04260 POS Payment Webhook And Kitchen Release Boundary Policy
04270 Payment Failure Timeout Duplicate And Manual Confirmation Policy
04300 POS Provider Abstraction And Multi-POS Adapter Policy
04320 POS Adapter Capability Level And Integration Contract Policy
04330 POS Adapter Error Code And Diagnostic Message Policy
04370 POS Integration Monitoring Replay And Incident Runbook Policy
04400 Toss Payments MVP Integration Boundary Policy
04410 PAYCO Payment And Order Provider MVP Boundary Policy
04430 OKPOS And Major POS Integration Candidate Policy
04440 Major POS API Discovery And Technical Spike Policy
04450 POS RPC Communication Security And Provider Trust Boundary Policy

All provider, payment, POS, KDS, display, support, replay, and reconciliation integrations must protect credentials according to this policy.

45. Financial-Grade Alignment
This policy supports financial-grade security discipline by enforcing:
least privilege
credential scope
environment separation
secret masking
rotation
revocation
auditability
segregation of duties
incident response
support access restriction
provider credential isolation
payment credential protection

Because POS, payment, KDS, and provider credentials may affect store revenue, customer payment, kitchen execution, and operational authority, credential control must be treated as financial-grade security.

46. Readiness Check
This policy is ready when:
Foundation Security inheritance is declared
credential classes are defined
credential risk levels are defined
credential scopes are defined
environment separation is required
credential storage is isolated
frontend and Flutter secrets are prohibited
Supabase service_role boundary is explicit
webhook secret handling is defined
signature verification is required
dual secret window is controlled
provider credentials are scoped
payment credentials are high risk
POS credentials match capability level
KDS bridge credentials are scoped
local agent credentials are scoped
device tokens are revocable
support cannot view raw credentials
admin credential operations are controlled
credential capability mismatch is detected
secret injection is controlled
git and documentation rules are defined
logging rules are defined
rotation and revocation are defined
audit requirements are append-only
monitoring requirements are defined
incident handling for exposure is defined
secure coding tests are required
MVP cutline is explicit
04450 relationship is defined
financial-grade alignment is stated


47. Summary
POS, payment, KDS, and provider integrations are only as safe as their credentials.
Webhook secrets decide whether provider events are trusted.
API keys decide whether external systems can read or write operational data.
Service tokens decide whether internal runtimes can mutate state.
Device tokens decide whether store devices can participate in operation.
Therefore, credentials must be treated as authority-bearing objects.
The system must:
scope credentials
isolate credentials
mask credentials
rotate credentials
revoke credentials
audit credentials
monitor credential failures
respond to exposure immediately
never expose credentials casually

This is the minimum security foundation for safe POS federation.
