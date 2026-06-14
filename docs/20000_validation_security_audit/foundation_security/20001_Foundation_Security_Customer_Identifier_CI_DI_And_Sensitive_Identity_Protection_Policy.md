# 20001_Foundation_Security_Customer_Identifier_CI_DI_And_Sensitive_Identity_Protection_Policy

## 1. Purpose

This document defines the foundation-level customer identifier, CI, DI, and sensitive identity protection policy.

The purpose of this policy is to prevent high-risk customer identifiers from spreading across operational runtimes, provider integrations, support tools, logs, exports, diagnostics, AI runtimes, analytics, POS adapters, payment runtimes, KDS runtimes, and customer display runtimes.

This policy applies across the entire system.

It is not owned by POS, payment, KDS, membership, support, or AI runtime.

All runtimes must obey this Foundation Security policy.

---

## 2. Scope

This policy applies to sensitive identity fields such as:

```text
CI
DI
phone number
email address
bank account reference
payment customer reference
provider customer reference
membership identity
external login identity
customer token
customer session
support identity view
raw provider payload containing identity
logs containing identity
exports containing identity
AI or Agent input containing identity
```

This policy applies to all major runtime families:

```text
POS Adapter Runtime
Payment Runtime
KDS Runtime
Customer Display Runtime
Membership Runtime
Support Runtime
Audit Runtime
Analytics Runtime
Agent Runtime
Reconciliation Runtime
Provider Integration Runtime
```

---

## 3. Core Principle

Sensitive identity must be minimized, isolated, tokenized, masked, and audited.

The core rule is:

```text
do not collect if not needed
do not store if not required
do not log raw identity
do not export raw identity
do not send raw identity to AI
do not show raw identity to support by default
do not copy identity into every runtime
```

CI and DI must be treated as high-risk persistent identifiers.

They are not ordinary customer profile fields.

---

## 4. Default CI/DI Rule

The default policy is:

```text
raw CI must not be stored
raw DI must not be stored
raw CI/DI must not be copied into operational tables
raw CI/DI must not be included in logs
raw CI/DI must not be included in diagnostic errors
raw CI/DI must not be shown in support tools
raw CI/DI must not be exported by default
raw CI/DI must not be sent to AI/Agent runtime
```

If the service can operate without CI/DI, CI/DI must not be collected.

---

## 5. Exceptional CI/DI Handling

CI/DI may be handled only when all conditions are met:

```text
legal basis exists
business necessity is documented
data minimization review passes
identity vault exists
field-level encryption is enabled
access control is enforced
purpose-based access is recorded
audit logging is enabled
retention period is defined
deletion or separation policy exists
breach response is defined
```

If these conditions are not met, CI/DI must be rejected, masked, dropped, or not collected.

---

## 6. Identity Vault Rule

If high-risk identity is stored, it must be stored only in a controlled identity vault.

The identity vault should be separated from ordinary operational tables.

Operational runtimes should use:

```text
vault_identity_id
customer_token
customer_session_id
provider_customer_reference
masked_phone
masked_email
short_customer_reference
```

Operational runtimes should not use:

```text
raw_ci
raw_di
full_phone
full_email
full_bank_account
raw_provider_identity_payload
```

---

## 7. Tokenization Rule

Most system operations must use tokenized identity.

Allowed identifiers:

```text
customer_token
customer_session_id
membership_reference_id
provider_customer_reference
vault_identity_id
masked_phone
masked_email
short_order_reference
```

Prohibited identifiers in ordinary runtime:

```text
raw_ci
raw_di
full_phone_without_need
full_email_without_need
full_bank_account_without_need
resident_identifier
raw_identity_payload
```

Tokens should be purpose-scoped and tenant-scoped where possible.

---

## 8. Runtime Separation Rule

The following runtimes must not require raw CI/DI:

```text
POS Adapter Runtime
Payment Runtime
KDS Runtime
Customer Display Runtime
Agent Runtime
Diagnostic Runtime
Support Runtime
Analytics Runtime
Audit Runtime
Reconciliation Runtime
```

If a runtime needs identity, it should receive a tokenized or masked reference.

Raw identity access must be exceptional, purpose-limited, reauthenticated, and audited.

---

## 9. Raw Payload Rule

Provider payloads may contain sensitive identity.

Raw provider payload handling must follow:

```text
detect sensitive fields
mask before normal log storage
store restricted raw payload only when necessary
encrypt restricted raw payload
control access by purpose
link through raw_payload_reference
do not expose raw payload in support view
```

Raw payloads must not become uncontrolled debug archives.

---

## 10. Logging Rule

Normal logs must not contain:

```text
raw CI
raw DI
full phone number
full email
full bank account
payment credential
provider secret
webhook secret
identity document number
unmasked provider customer profile
```

Logs may contain:

```text
customer_token
masked_phone
masked_email
provider_reference
payment_reference
order_reference
diagnostic_error_code
```

Logs are operational traces, not identity storage.

---

## 11. Diagnostic Error Rule

Diagnostic errors must not expose raw identity.

Allowed diagnostic references:

```text
customer_token
customer_session_id
provider_customer_reference
masked contact
order_id
payment_request_id
provider_event_id
```

Prohibited diagnostic references:

```text
raw CI
raw DI
full phone
full email
full bank account
raw identity payload
```

If raw identity is required for investigation, diagnostic records must link to restricted evidence storage.

---

## 12. Support View Rule

Support view must be masked by default.

Default support view may show:

```text
customer short reference
masked phone
masked email
order reference
payment reference
membership status
last activity time
```

Support view must not show:

```text
raw CI
raw DI
full identity payload
full bank account
provider credential
webhook secret
```

Sensitive identity reveal must require:

```text
elevated permission
purpose entry
reauthentication
time-limited access
audit event
post-access review if needed
```

---

## 13. Export Rule

Default exports must exclude:

```text
CI
DI
full phone
full email
full bank account
raw provider identity payload
payment credentials
provider secrets
```

If export requires personal data, it must be marked:

```text
IDENTITY_EXPORT_RESTRICTED
```

and require approval, audit, retention purpose, and expiration.

---

## 14. AI And Agent Rule

AI and Agent runtimes must not receive raw CI/DI.

Agent may receive:

```text
customer behavior summary
order pattern
masked customer reference
risk flag
support category
```

Agent must not receive:

```text
raw CI
raw DI
full phone
full email
raw provider identity payload
payment credential
```

AI recommendations must operate on minimized and purpose-limited data.

---

## 15. Provider Integration Rule

Provider onboarding must document identity scope.

Each provider must declare:

```text
which identity fields are received
whether CI/DI is included
whether provider customer ID is stable
whether identity can be masked
whether raw payload can be minimized
retention requirement
deletion or unlink rule
breach notification obligation
```

If a provider sends unnecessary high-risk identity, ingestion must minimize, mask, drop, or vault according to policy.

---

## 16. Access Control Rule

Sensitive identity access must follow least privilege.

Required controls:

```text
role-based access
purpose-based access
tenant isolation
store isolation
reauthentication for reveal
break-glass access
time-limited access
audit logging
access review
```

Raw CI/DI access is blocked by default.

---

## 17. Break-Glass Rule

Emergency access to sensitive identity may be allowed only through break-glass.

Break-glass requires:

```text
reason
actor identity
reauthentication
time limit
scope limit
audit event
post-access review
```

Break-glass must not become routine support workflow.

---

## 18. Encryption And Key Rule

Sensitive identity must be encrypted at rest and in transit.

Required controls:

```text
field-level encryption where necessary
separate key management
key rotation
restricted decryption path
encrypted backups
no plaintext replication
secure transport
```

Encryption alone is not enough.

Minimization, isolation, masking, access control, and audit are also required.

---

## 19. Hashing Rule

If lookup is required, the system should use purpose-specific tokenization or tenant-scoped keyed hash.

Plain unsalted hash of CI/DI is not sufficient.

Recommended approach:

```text
purpose-specific token
tenant-scoped keyed hash
rotatable secret
limited lookup context
no cross-context reuse
```

CI/DI must not become a universal join key across all services.

---

## 20. Retention Rule

Sensitive identity must have retention states:

```text
ACTIVE
PURPOSE_EXPIRED
DELETION_REQUESTED
DELETED
ANONYMIZED
LEGAL_HOLD
RETENTION_EXCEPTION
```

High-risk identity must not be retained indefinitely by default.

---

## 21. Breach Response Rule

If CI/DI or equivalent high-risk identity may be exposed, security incident response is required.

Response should include:

```text
contain access
preserve evidence
identify affected fields
identify affected users
review access logs
rotate credentials if needed
notify internal owner
legal/privacy review
regulator notification review
customer notification review
post-incident remediation
```

Operational support closure is not security incident closure.

---

## 22. Audit Requirements

The system must create append-only audit events for:

```text
sensitive identity stored
sensitive identity accessed
sensitive identity revealed
identity linked
identity unlinked
identity exported
identity masked
identity deleted
break-glass access used
provider payload containing high-risk identity received
sensitive identity incident detected
```

Audit must not contain raw CI/DI.

---

## 23. Prohibited Handling

The following are prohibited:

```text
storing raw CI/DI in customer profile table
storing raw CI/DI in order table
storing raw CI/DI in POS adapter event table
storing raw CI/DI in payment event table
logging CI/DI
showing CI/DI in support screens
exporting CI/DI by default
using CI/DI as analytics join key
sending CI/DI to AI/Agent runtime
copying raw provider identity into audit text
treating encryption as sufficient by itself
```

---

## 24. MVP Cutline

For MVP, the system should support:

```text
no raw CI/DI storage by default
customer_session_id
customer_token
masked phone
masked email
provider_customer_reference
identity field classification
raw payload masking rule
support masking rule
diagnostic masking rule
audit event for identity access
provider identity scope checklist
```

Excluded from MVP:

```text
full CI/DI storage
full identity vault implementation
advanced consent management
automatic privacy risk scoring
full data subject request automation
AI privacy redaction engine
```

MVP should avoid high-risk identity collection rather than building complex storage first.

---

## 25. Relationship To Runtime Documents

This Foundation policy governs:

```text
POS integration
payment integration
KDS integration
membership integration
customer display
support
diagnostics
audit
analytics
AI/Agent runtime
provider onboarding
```

Provider-specific or runtime-specific documents may reference this policy, but must not weaken it.

---

## 26. Relationship To 04000 Integration Security

04000 integration security documents must reference this Foundation policy.

The relationship is:

```text
Foundation Security = what data must be protected
04000 Integration Security = how provider/runtime messages and credentials are trusted
```

04450 and 04460 are therefore not standalone security constitutions.

They are integration-level enforcement documents under Foundation Security.

---

## 27. Readiness Check

This policy is ready when:

```text
CI/DI is classified as high-risk identity
default rule is no raw CI/DI storage
identity vault is required if stored
operational runtimes use token references
raw payload masking is required
logs cannot contain raw identity
support view is masked by default
exports exclude high-risk identity
AI/Agent cannot receive raw identity
provider identity scope is reviewed
access is audited
break-glass is controlled
breach response is defined
MVP avoids high-risk identity collection
04000 integration security references this policy
```

---

## 28. Summary

CI and DI are not normal customer fields.

The safest foundation rule is:

```text
do not collect CI/DI
do not store CI/DI
do not log CI/DI
do not export CI/DI
do not send CI/DI to AI
do not show CI/DI to support
```

If future requirements force CI/DI handling, it must happen only through controlled vault, encryption, masking, purpose limitation, access audit, retention control, and breach response.

This is a Foundation Security policy.

All POS, payment, KDS, membership, support, analytics, and AI runtimes must follow it.
