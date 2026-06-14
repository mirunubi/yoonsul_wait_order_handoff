# 04450 POS RPC Communication Security And Provider Trust Boundary Policy

## 1. Purpose

This document defines the POS RPC communication security and provider trust boundary policy.

The purpose of this policy is to secure RPC, webhook, adapter, bridge, provider callback, local agent, store device, support action, replay request, reconciliation action, payment runtime, KDS runtime, and customer display runtime communication.

The system must not allow external POS events, payment provider callbacks, internal RPC calls, bridge messages, device messages, support-triggered actions, or replay requests to mutate operational state unless the message is authenticated, authorized, scoped, fresh, idempotent, capability-checked, privacy-safe, and auditable.

This is an integration-level enforcement document under Foundation Security.

---

## 2. Foundation Security Inheritance

This document inherits and must comply with:

```text
Foundation Security 001 Customer Identifier CI DI And Sensitive Identity Protection Policy
Foundation Security 002 Secure Coding And DevSecOps Gate Policy
Foundation Security 003 Secret Management Credential Vault And Key Rotation Policy
Foundation Security 004 Cloud Security Financial Sector Alignment Policy
Foundation Security 005 Access Control RBAC ABAC And Least Privilege Policy
Foundation Security 006 Logging Audit Evidence And Tamper Resistance Policy
Foundation Security 007 Vulnerability Patch Dependency And Incident Response Policy
Foundation Security 008 Data Retention Deletion Export And Privacy Response Policy
Foundation Security 009 Security Governance Index And Financial-Grade Readiness Check
```

This document may add stricter rules for POS, payment, KDS, and provider RPC.

It must not weaken Foundation Security.

---

## 3. Scope

This policy applies to:

```text
POS adapter RPC
payment provider webhook
payment provider callback
payment runtime RPC
KDS bridge RPC
customer display status RPC
order runtime RPC
provider polling callback
provider file import callback
local agent to central RPC
store device to server RPC
support action RPC
admin configuration RPC
replay request RPC
reconciliation action RPC
adapter capability change RPC
provider configuration RPC
credential reference update RPC
```

This policy does not define CI/DI storage or identity vault design.

Sensitive identity handling is governed by Foundation Security 001.

Secret and credential handling is governed by Foundation Security 003 and 04460.

---

## 4. Core Principle

Every RPC call must prove:

```text
who sent it
which runtime sent it
which tenant it belongs to
which store it belongs to
which provider it relates to
what action it requests
what authority scope it claims
whether the message is fresh
whether the message is duplicated
whether the caller is allowed to perform the action
whether sensitive data is minimized
whether the result must be audited
```

The core rule is:

```text
unauthenticated message = reject
unscoped message = reject
unverified provider event = no authority change
duplicate message = idempotent handling
stale message = review or reject
authority-sensitive RPC = audit required
identity-bearing RPC = minimized and masked
credential-bearing RPC = prohibited unless controlled
```

RPC is not just transport.

RPC is an authority boundary.

---

## 5. Trust Boundary Model

The system must distinguish trust zones:

```text
External Provider Zone
Store Device Zone
Local Agent Zone
Internal Runtime Zone
Support/Admin Zone
Audit Zone
Security Governance Zone
```

Examples:

```text
External Provider Zone = POS vendor, Toss, PAYCO, delivery provider
Store Device Zone = counter tablet, table tablet, kiosk, KDS screen
Local Agent Zone = store-side bridge, local cache, emergency relay
Internal Runtime Zone = order, payment, KDS, display, reconciliation
Support/Admin Zone = HQ support, developer tools, vendor escalation tools
Audit Zone = append-only event memory
Security Governance Zone = credential control, access review, incident response
```

Each zone must have different permissions.

A message crossing zones must be verified.

---

## 6. Provider RPC Rule

External provider calls must be verified before processing.

Verification should include:

```text
provider identity
merchant reference
store reference
tenant reference if available
integration reference
event type
event timestamp
signature or secret
payload integrity
duplicate event check
contract capability check
rate limit check
known provider status
```

If verification fails, the event must be rejected or quarantined.

It must not mutate order, payment, KDS, customer display, reconciliation, support, audit, or credential state.

---

## 7. Internal RPC Rule

Internal runtime RPC must be authenticated and scoped.

Internal RPC calls must carry:

```text
caller_runtime
target_runtime
tenant_id
store_id
request_id
idempotency_key
authority_scope
timestamp
signature_or_service_token
trace_id
runtime_version if applicable
```

A runtime must not perform an action outside its authority scope.

Example:

```text
Customer Display Runtime may request display update.
Customer Display Runtime must not mark payment as verified.
```

---

## 8. Tenant And Store Scope Rule

Every RPC that affects operational state must be tenant-scoped and store-scoped where applicable.

Required scope fields:

```text
tenant_id
store_id
provider_id if applicable
integration_id if applicable
terminal_id if applicable
device_id if applicable
runtime_family
```

If scope is missing or ambiguous, the RPC must be rejected or quarantined.

Cross-store mutation is prohibited unless explicitly authorized by HQ-level policy.

Cross-tenant mutation is prohibited unless explicitly authorized by system-level policy and audited.

---

## 9. Authority Scope Rule

RPC calls must declare authority scope.

Allowed authority scopes include:

```text
READ_ONLY
VISIBILITY_UPDATE
PROJECTION_UPDATE
ORDER_STATE_UPDATE
PAYMENT_VERIFICATION
KDS_RELEASE
MANUAL_FALLBACK
RECONCILIATION
REPLAY_REQUEST
SUPPORT_ACTION
AUDIT_APPEND
CONFIG_CHANGE
CREDENTIAL_REFERENCE_CHANGE
CREDENTIAL_ROTATION
CAPABILITY_CHANGE
EXPORT
IDENTITY_REVEAL
```

A caller may only use scopes granted to it.

Authority scope must be checked before state change.

---

## 10. Access Control Enforcement

RPC authorization must follow Foundation Security 005.

Each authority-sensitive RPC must check:

```text
actor identity
actor role
tenant scope
store scope
runtime authority
object ownership
object state
requested action
allowed authority scope
```

Forbidden patterns:

```text
trusting client-provided tenant_id
trusting client-provided role
checking role only in UI
allowing object access by ID alone
using service_role path for ordinary client flow
allowing support note to mutate runtime truth
```

Object ID knowledge is not permission.

---

## 11. Payment RPC Boundary

Payment-related RPC is high risk.

Only Payment Runtime or approved payment authority may emit:

```text
PAYMENT_DONE
PAYMENT_FAILED
PAYMENT_EXPIRED
PAYMENT_AMOUNT_MISMATCH
PAYMENT_DUPLICATE_SUSPECTED
PAYMENT_RECONCILIATION_REQUIRED
```

POS Adapter, KDS Runtime, Customer Display Runtime, Support Runtime, Agent Runtime, or Local Agent Runtime must not directly emit verified payment truth.

They may emit:

```text
PAYMENT_STATUS_OBSERVED
PAYMENT_CONFIRMATION_REQUIRED
PAYMENT_VISIBILITY_UPDATED
PAYMENT_SOURCE_UNCERTAIN
```

but not final payment authority.

---

## 12. KDS Release RPC Boundary

KDS release RPC must require verified eligibility.

KDS release request must include:

```text
internal_order_id
payment_status_reference
release_eligibility_reason
source_runtime
idempotency_key
audit_reference
```

KDS release must not be accepted from:

```text
unverified provider webhook
customer display
customer claim
staff note without fallback approval
external POS paid label without verification
payment pending state
support note
AI recommendation
```

KDS release is authority-sensitive and must be audited.

---

## 13. Customer Display RPC Boundary

Customer Display Runtime owns visibility only.

Customer Display Runtime may receive:

```text
payment screen state
QR display state
payment checking state
payment complete state
kitchen received state
staff assistance required state
```

Customer Display Runtime must not emit:

```text
PAYMENT_DONE
KDS_RELEASED
ORDER_ACCEPTED_BY_KITCHEN
REFUND_APPROVED
RECONCILIATION_CLOSED
```

Customer display state is what the customer saw.

It is not proof of operational truth.

---

## 14. POS Adapter RPC Boundary

POS Adapter Runtime owns provider normalization.

POS Adapter may emit:

```text
PROVIDER_EVENT_RECEIVED
PROVIDER_EVENT_VERIFIED
CANONICAL_ORDER_CREATED
CANONICAL_ORDER_UPDATED
PAYMENT_STATUS_OBSERVED
ITEM_MAPPING_REQUIRED
TABLE_REFERENCE_UNCERTAIN
DIAGNOSTIC_ERROR_DETECTED
```

POS Adapter must not directly emit:

```text
PAYMENT_DONE
KDS_RELEASED
REFUND_APPROVED
SETTLEMENT_FINALIZED
RECONCILIATION_CLOSED
```

External provider data must pass through internal authority rules.

---

## 15. Support RPC Boundary

Support actions must be controlled.

Support may:

```text
view diagnostic state
attach evidence
request replay
create support ticket
escalate incident
request reconciliation
record vendor response
```

Support must not directly:

```text
mark payment verified
release KDS
approve refund
rewrite provider event
delete audit
clear fallback-originated state
close reconciliation without authority
view raw credentials
view raw CI/DI by default
```

Support authority must follow role, policy, purpose, and audit.

---

## 16. Admin RPC Boundary

Admin actions are high risk.

Admin RPC may include:

```text
provider configuration change
role permission change
integration capability change
device token revocation
credential reference update
storage policy change
RLS-related configuration
```

Admin RPC must require:

```text
role authority
tenant or global scope
reauthentication for sensitive action
change reason
audit event
rollback path where applicable
```

Admin RPC must not bypass Foundation Security.

---

## 17. Replay RPC Rule

Replay RPC must be separated from mutation RPC.

Replay may request:

```text
projection rebuild
event sequence review
diagnostic reconstruction
KDS projection replay
payment status projection replay
customer display projection replay
```

Replay must not:

```text
rewrite raw provider event
rewrite audit event
change payment truth directly
change KDS release history directly
erase fallback-originated flag
delete evidence packet
```

Replay result may create a reconciliation requirement.

---

## 18. Reconciliation RPC Rule

Reconciliation RPC is authority-sensitive.

Only approved reconciliation roles or runtimes may emit:

```text
RECONCILIATION_CONCLUSION_RECORDED
RECONCILIATION_CLOSED
RECONCILIATION_CLOSED_WITH_EXCEPTION
```

Reconciliation RPC must include:

```text
case_id
affected_order_id
evidence_reference
conclusion_type
actor
authority_scope
reason
audit_reference
```

Reconciliation conclusion must be append-only.

---

## 19. Webhook Security Rule

Webhook endpoints must verify provider authenticity.

Webhook handling must include:

```text
signature verification where available
secret verification where available
timestamp tolerance
replay detection
duplicate event detection
payload hash
provider event ID
provider identity
merchant/store reference
rate limiting
IP allowlist if applicable
raw payload masking
```

Webhook failure must create diagnostic error and audit event when relevant.

Unverified webhook must not change authority-sensitive state.

---

## 20. Replay Attack Protection

The system must detect replayed messages.

Replay protection may use:

```text
timestamp tolerance
nonce
provider_event_id
request_id
idempotency_key
payload_hash
signature timestamp
processed event registry
```

If replay is detected, the event must be ignored or quarantined.

Authority-sensitive replayed messages must never be reprocessed.

---

## 21. Idempotency Rule

All authority-sensitive RPC calls must be idempotent.

Required idempotency targets:

```text
payment provider event
payment verification result
KDS release request
order creation from provider event
manual fallback confirmation
reconciliation conclusion
support action
refund review trigger
capability downgrade
credential reference change
credential rotation request
```

Duplicate RPC must not create:

```text
duplicate order
duplicate payment
duplicate KDS ticket
duplicate support case
duplicate reconciliation case
duplicate audit conclusion
```

Duplicate messages should be marked, not silently hidden.

---

## 22. Message Freshness Rule

RPC calls must be fresh.

Freshness checks should consider:

```text
event timestamp
received_at
processed_at
provider_event_time
store_local_time
clock drift tolerance
timeout policy
```

If freshness is uncertain, mark:

```text
RPC_FRESHNESS_UNCERTAIN
EVENT_CHRONOLOGY_UNCERTAIN
```

Stale messages must not overwrite newer verified state.

---

## 23. Capability Contract Check

Provider RPC must be checked against integration capability.

Example:

```text
Level 1 read-only adapter cannot write POS state.
Level 2 event sync cannot force refund.
Payment provider cannot release KDS directly.
Customer display cannot update payment truth.
KDS bridge cannot approve payment.
Support tool cannot rewrite provider event.
```

If a call exceeds capability, block it and emit:

```text
POSADP-CAP-001 operation not allowed by integration level
POSADP-AUTH-010 unauthorized state promotion blocked
RPCSEC-CAP-001 capability contract violation
```

---

## 24. Local Agent RPC Rule

Local agent or store bridge RPC must be scoped and auditable.

Local agent may support:

```text
store-side cache
offline queue
KDS bridge relay
device health report
fallback event relay
emergency local status sync
```

Local agent must not silently overwrite central truth.

If offline events are replayed, they must be marked:

```text
LOCAL_AGENT_REPLAYED
FALLBACK_ORIGINATED if applicable
RECONCILIATION_REQUIRED if authority affected
```

Local agent replay is not the same as provider truth.

---

## 25. Store Device RPC Rule

Store devices must have limited authority.

Device types:

```text
counter customer display
table tablet
kiosk
KDS screen
staff tablet
manager device
local agent device
```

Customer-facing devices may not perform authority-sensitive actions.

Manager device may approve fallback only within policy and audit.

Device tokens must be store-scoped, role-scoped, and revocable.

---

## 26. RPC Payload Minimization

RPC payloads must include only required data.

Avoid sending:

```text
raw CI
raw DI
full customer identity
provider secret
webhook secret
service token
unneeded payment data
unneeded staff data
full raw provider payload
```

Use references:

```text
order_id
payment_request_id
provider_event_id
raw_payload_reference
customer_token
masked_contact
trace_id
request_id
```

Identity protection follows Foundation Security 001.

Secret protection follows Foundation Security 003.

---

## 27. Safe Logging Rule

RPC logs must be structured and safe.

Allowed log fields:

```text
trace_id
request_id
tenant_id
store_id
runtime_family
provider_id
adapter_version
authority_scope
diagnostic_error_code
result
duration_ms
```

Prohibited log fields:

```text
raw CI
raw DI
full phone
full email
service_role key
API key
webhook secret
OAuth refresh token
database password
raw access token
raw provider identity payload
```

If RPC logs contain secrets or raw identity, it is a security defect and may be a security incident.

---

## 28. Audit Rule

Every authority-sensitive RPC must create audit.

Authority-sensitive RPC includes:

```text
payment verification
KDS release
manual fallback approval
capability downgrade
replay request
reconciliation conclusion
support closure with exception
provider credential reference change
configuration change
identity reveal
export
```

Audit event must record:

```text
caller
target
tenant_id
store_id
action
authority_scope
request_id
idempotency_key
timestamp
result
reason if applicable
```

Audit must be append-only.

RPC without required audit must be blocked or quarantined.

---

## 29. Quarantine Rule

Untrusted or suspicious RPC messages may be quarantined.

Quarantine cases:

```text
signature failure
unknown provider
missing scope
replay suspected
payload malformed
capability violation
identity leakage detected
rate limit abuse
invalid device token
invalid service token
```

Quarantined messages must not mutate operational state.

They may be used for investigation if safely stored and access-controlled.

---

## 30. Rate Limit And Abuse Rule

RPC endpoints must protect against abuse.

Controls may include:

```text
provider rate limit
device rate limit
tenant-level rate limit
store-level rate limit
IP allowlist where applicable
webhook burst handling
duplicate suppression
quarantine for suspicious messages
```

Rate limits must not silently drop authority-sensitive events without diagnostic visibility.

---

## 31. Retry And Replay Distinction

Retries must be safe.

Retry behavior must distinguish:

```text
network retry
provider retry
internal retry
manual retry
replay reconstruction
```

Network retry may reattempt the same action with idempotency.

Provider retry may resend the same provider event.

Replay reconstruction may rebuild projection from existing source events.

Replay must not be confused with mutation.

---

## 32. RPC Diagnostic Error Codes

RPC security failures should map to diagnostic codes.

Recommended codes:

```text
RPCSEC-AUTH-001 missing authentication
RPCSEC-AUTH-002 invalid service token
RPCSEC-AUTH-003 unauthorized authority scope
RPCSEC-SCOPE-001 missing tenant scope
RPCSEC-SCOPE-002 missing store scope
RPCSEC-SCOPE-003 cross-store operation blocked
RPCSEC-REPLAY-001 replayed message detected
RPCSEC-IDEMP-001 idempotency key missing
RPCSEC-TIME-001 stale message rejected
RPCSEC-SIGN-001 signature verification failed
RPCSEC-CAP-001 capability contract violation
RPCSEC-AUDIT-001 authority RPC without audit blocked
RPCSEC-DEVICE-001 device token invalid
RPCSEC-BRIDGE-001 bridge authority exceeded
RPCSEC-PRIVACY-001 raw identity in RPC payload blocked
RPCSEC-SECRET-001 secret in RPC payload blocked
```

These may coexist with POSADP diagnostic codes.

---

## 33. Error Handling Rule

RPC security failure must not be hidden.

Failures must be:

```text
logged safely
audited when authority-sensitive
mapped to diagnostic code
visible to support when operationally relevant
hidden from customer-facing raw detail
```

Customer-facing message should remain simple:

```text
처리 확인 중입니다.
직원 확인이 필요합니다.
```

Do not expose stack trace, provider secret, SQL error, or internal authorization structure to customers.

---

## 34. Secret Handling Rule

RPC secrets must not be exposed.

Prohibited:

```text
logging service tokens
logging webhook secrets
showing provider credentials in support
embedding secrets in customer display
storing secrets in raw error text
copying secrets into audit memo
placing secrets in frontend code
placing secrets in Flutter client
```

Secrets must be scoped, rotated, revocable, and separated between test and production.

Detailed credential handling is defined in Foundation Security 003 and 04460.

---

## 35. Retention Rule

RPC logs, rejected messages, quarantined payloads, and audit records must follow Foundation Security 008.

Retention must distinguish:

```text
diagnostic log
security log
authority audit
restricted evidence
quarantined payload
raw provider payload
```

Do not retain rejected or suspicious raw payload forever by default.

Do not delete authority audit for convenience.

---

## 36. Incident Response Rule

RPC security failures must escalate according to Foundation Security 007.

Security incident triggers include:

```text
repeated signature failure
service token abuse
cross-tenant RPC attempt
cross-store RPC attempt
payment authority bypass attempt
KDS release without authority
raw identity in RPC payload
secret in RPC payload
replay attack detected
audit missing for authority RPC
```

High-risk RPC failures must not be treated as ordinary errors.

---

## 37. Secure Coding And Test Rule

Implementation of this policy must pass Foundation Security 002 gates.

Required tests include:

```text
unauthenticated RPC rejected
invalid service token rejected
wrong tenant rejected
wrong store rejected
unauthorized authority scope rejected
duplicate idempotency key handled safely
stale message rejected or reviewed
webhook signature failure blocks authority
KDS release from customer display rejected
payment verification from support rejected
raw identity payload blocked or masked
secret payload blocked
audit created for authority RPC
```

RPC security is not complete without tests.

---

## 38. Monitoring Requirements

The system should monitor:

```text
RPC authentication failure count
signature verification failure count
missing scope count
capability violation count
replay detected count
idempotency conflict count
stale message count
KDS release RPC blocked count
payment authority RPC blocked count
quarantined message count
invalid device token count
bridge authority exceeded count
raw identity payload blocked count
secret payload blocked count
audit missing block count
```

Monitoring should feed support, security, and incident runbooks.

---

## 39. Prohibited Handling

The following are prohibited:

```text
accepting webhook without verification for payment authority
accepting KDS release from customer display
allowing support to directly mark payment verified
allowing read-only adapter to write POS state
processing duplicate authority RPC twice
letting stale event overwrite newer verified state
using cross-store RPC without explicit authority
using device token as tenant-wide admin token
logging service token or webhook secret
closing reconciliation through support note alone
sending raw CI/DI through RPC
sending raw credentials through RPC
using AI recommendation as direct authority action
```

---

## 40. MVP Cutline

For MVP, RPC security should support:

```text
service-to-service authentication
provider webhook verification
tenant/store scope requirement
authority scope requirement
idempotency key
timestamp freshness check
duplicate event detection
capability contract check
safe error code
append-only audit for authority RPC
secret masking
identity payload minimization
quarantine for rejected messages
device token revocation
support action restriction
security incident trigger for high-risk RPC failure
```

Excluded from MVP:

```text
full zero-trust service mesh
hardware security module integration
advanced anomaly detection
multi-region RPC attestation
automated formal verification
full mTLS rollout across all devices
complete service mesh identity
```

MVP must still prevent authority-boundary failure.

---

## 41. Relationship To 04460

Document 04460 defines POS webhook signature, secret rotation, and credential isolation.

The relationship is:

```text
04450 = message trust boundary
04460 = secret and credential protection behind that trust
```

04450 checks whether a message can be trusted.

04460 protects the credentials that make trust verification possible.

---

## 42. Relationship To POS Integration Documents

This document supports:

```text
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
```

All provider, POS, payment, KDS, display, support, replay, and reconciliation messages must obey RPC security boundaries.

---

## 43. Financial-Grade Alignment

This policy supports financial-grade security discipline by enforcing:

```text
authenticated runtime communication
least privilege
tenant/store isolation
strong authorization
replay defense
idempotency
webhook verification
auditability
safe logging
incident escalation
secret and identity minimization
```

Because POS, payment, KDS, and support RPC may affect store revenue, customer payment, kitchen execution, and audit evidence, RPC must be treated as a financial-grade authority boundary.

---

## 44. Readiness Check

This policy is ready when:

```text
Foundation Security inheritance is declared
trust zones are defined
provider RPC verification is required
internal RPC authentication is required
tenant/store scope is required
authority scope is checked
access control enforcement is defined
payment RPC boundary is protected
KDS release RPC boundary is protected
customer display boundary is protected
POS adapter boundary is protected
support and admin boundaries are protected
replay RPC is separated from mutation
reconciliation RPC is authority-sensitive
webhook verification is required
replay attack protection exists
idempotency is required
message freshness is checked
capability contract is enforced
payload minimization is required
safe logging is required
audit is required for authority RPC
quarantine is defined
incident response triggers are defined
secure coding tests are required
04460 relationship is defined
financial-grade alignment is stated
```

---

## 45. Summary

POS federation is not safe if every connected system can freely call every other system.

Every provider event, webhook, bridge call, device message, support action, replay request, and runtime RPC must pass through security boundaries.

The rule is simple:

```text
authenticate the caller
authorize the scope
verify the message
check freshness
enforce idempotency
respect capability
minimize payload
protect authority
audit the result
escalate security failures
```

This is how POS, payment, KDS, display, support, replay, and reconciliation can communicate without turning integration into a security hole.
