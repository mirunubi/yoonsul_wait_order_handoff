# 04440 Customer Identifier CI DI And Sensitive Identity Protection Policy

## 1. Purpose

This document defines the customer identifier, CI, DI, and sensitive identity protection policy.

The purpose of this policy is to prevent high-risk customer identifiers from becoming widely stored, logged, copied, exported, exposed through support tools, leaked through provider payloads, or reused across runtime boundaries.

The system must treat CI, DI, phone number, email, payment reference, provider customer ID, membership identity, and external identity linkage as sensitive identity data.

CI and DI must be treated as high-risk persistent identifiers.

They must not be handled like ordinary customer profile fields.

---

## 2. Scope

This policy applies to:

* Customer identity
* CI
* DI
* Phone number
* Email address
* Provider customer reference
* Payment provider customer reference
* Membership provider customer reference
* POS customer reference
* Delivery app customer reference
* Table order customer session
* Customer mobile web session
* Login identity
* Consent-linked identity
* Support view identity
* Exported identity
* Raw provider payload containing identity
* Audit and diagnostic events that may reference identity

This policy does not define final database schema, final encryption implementation, legal privacy notice wording, or full personal information processing agreement.

---

## 3. Core Principle

Sensitive identity must be minimized, isolated, tokenized, and protected from operational spread.

The core principle is:

```text id="f7erw0"
do not collect if not needed
do not store if not required
do not expose if reference is enough
do not log raw identity
do not copy identity into every runtime
do not treat CI or DI as normal profile data
```

Customer identity must support operation, but it must not become a universal leakage surface.

---

## 4. CI And DI Classification

CI and DI must be classified as high-risk persistent identifiers.

They should be treated as:

```text id="k4agqx"
SENSITIVE_IDENTITY_HIGH_RISK
PERSISTENT_CROSS_SERVICE_IDENTIFIER
VAULT_REQUIRED_IF_STORED
RAW_LOG_PROHIBITED
EXPORT_RESTRICTED
SUPPORT_MASKING_REQUIRED
```

CI and DI must not be stored in ordinary customer, order, POS, payment, KDS, display, support, or diagnostic tables.

If stored at all, they must be stored only in a controlled identity vault.

---

## 5. Default Rule: Do Not Store CI/DI

The default policy is:

```text id="k8cvq1"
Do not store raw CI.
Do not store raw DI.
Do not copy CI/DI into operational tables.
Do not include CI/DI in logs.
Do not expose CI/DI to support screens.
Do not export CI/DI unless legally and operationally required.
```

If CI/DI is not strictly needed for the current service, it must not be collected.

If a provider sends CI/DI unnecessarily, the system must drop, mask, or vault it according to ingestion policy.

---

## 6. Exceptional Storage Rule

CI/DI may be stored only when all of the following are true:

```text id="t0ckfz"
legal basis exists
business necessity is documented
data minimization review passes
identity vault is available
encryption is enabled
access control is enforced
audit logging is enabled
retention period is defined
deletion or separation policy is defined
breach response rule is defined
```

If these conditions are not met, CI/DI must not be stored.

---

## 7. Identity Vault Rule

If high-risk identity is stored, it must be stored in an identity vault.

The vault must be separated from ordinary operational data.

The identity vault should hold:

```text id="47bkyv"
vault_identity_id
tenant_id
customer_identity_reference
encrypted_ci_if_required
encrypted_di_if_required
encrypted_phone_if_required
encrypted_email_if_required
provider_identity_reference
consent_reference
created_at
updated_at
retention_status
```

Operational systems should reference:

```text id="jas6me"
vault_identity_id
customer_token
masked_customer_reference
```

not raw CI/DI.

---

## 8. Tokenization Rule

Operational runtimes must use tokenized references.

Allowed operational identifiers include:

```text id="0kom6j"
customer_token
customer_session_id
membership_reference_id
provider_customer_reference
vault_identity_id
masked_phone
masked_email
short_customer_reference
```

Prohibited operational identifiers include:

```text id="f2z39b"
raw_ci
raw_di
raw_resident_identifier
full_phone_number_without_need
full_email_without_need
raw_bank_account_without_need
```

The system should be designed so most runtimes never need raw identity.

---

## 9. Runtime Boundary Rule

Sensitive identity must not spread across runtimes.

The following runtimes should not need raw CI/DI:

```text id="kz3uqf"
POS Adapter Runtime
Payment Runtime
KDS Runtime
Customer Display Runtime
Agent Runtime
Audit Runtime
Diagnostic Runtime
Support Runtime
Analytics Runtime
Reconciliation Runtime
```

If a runtime needs identity, it should receive a tokenized or masked reference.

Raw identity access must be exceptional and audited.

---

## 10. POS Adapter Identity Rule

POS providers may send customer identifiers.

The POS Adapter must classify incoming identity fields as:

```text id="sccl5w"
OPERATIONAL_REFERENCE
CONTACT_REFERENCE
PROVIDER_CUSTOMER_REFERENCE
SENSITIVE_IDENTITY
HIGH_RISK_IDENTIFIER
UNKNOWN_IDENTITY_FIELD
```

If provider payload contains CI/DI or equivalent high-risk identity, the adapter must not copy it into canonical order.

The raw payload must be masked, vaulted, or rejected according to provider contract and legal basis.

---

## 11. Payment Provider Identity Rule

Payment providers may provide payment customer references or payer information.

Payment Runtime should store only what is necessary for payment verification, reconciliation, and legal retention.

Allowed payment identity references may include:

```text id="ho4m0y"
payment_customer_reference
provider_payment_reference
masked_payment_method
masked payer reference if needed
```

Payment Runtime must not become a general customer identity master.

Payment provider identity must not overwrite internal customer identity without explicit linking and consent.

---

## 12. Membership Identity Rule

Membership identity may require stronger customer linkage.

However, membership identity must be separated by context:

```text id="ocrnp8"
internal membership identity
store membership identity
tenant membership identity
PAYCO or external membership identity
윤슬 자리찜 identity
white-label tenant app identity
```

External identity must not automatically merge with internal identity.

Identity linking requires consent, purpose limitation, and audit.

---

## 13. Customer Session Rule

For order and payment flow, most use cases should rely on session identity.

Allowed session fields include:

```text id="i40x4j"
customer_session_id
table_session_id
seating_session_id
mobile_web_session_id
payment_session_id
short_order_reference
```

Session identity should expire or rotate according to retention policy.

Session identity must not expose CI/DI.

---

## 14. Raw Payload Handling Rule

Raw provider payload may contain sensitive identity.

Raw payload handling must follow:

```text id="g1yxpx"
detect sensitive fields
mask before general log storage
store raw only in restricted evidence storage if necessary
encrypt restricted raw payload
control access by purpose
link raw payload through reference
avoid direct display in support tools
```

Raw payload must not be casually stored in debug logs.

---

## 15. Logging Rule

The following must not appear in normal application logs:

```text id="3o5b5c"
raw CI
raw DI
full phone number
full email
full bank account number
payment credential
provider secret
webhook secret
identity document number
unmasked customer profile payload
```

Logs may contain:

```text id="jfv8iw"
customer_token
masked_phone
masked_email
provider_reference
payment_reference
order_reference
diagnostic_error_code
```

Logs are operational tools, not identity storage.

---

## 16. Diagnostic Error Rule

Diagnostic errors must not expose raw identity.

Diagnostic error context may include:

```text id="hct0d0"
customer_token
customer_session_id
provider_customer_reference
masked contact
order_id
payment_request_id
provider_event_id
```

Diagnostic error context must not include:

```text id="0e9ntr"
raw CI
raw DI
full phone
full email
full bank account
raw identity payload
```

If diagnostic evidence needs raw identity, it must link to restricted evidence storage.

---

## 17. Support View Rule

Support staff should see only masked identity unless elevated access is justified.

Default support view may show:

```text id="gibuu6"
customer short reference
masked phone
masked email
order reference
payment reference
membership status
last activity time
```

Support view must not show:

```text id="67u62p"
raw CI
raw DI
full identity payload
unmasked provider customer data
full bank account
provider credential
```

Sensitive identity reveal must require elevated permission, purpose entry, reauthentication, and audit.

---

## 18. Export Rule

Exports must minimize identity.

Default exports must exclude:

```text id="0qbbm5"
CI
DI
full phone
full email
full bank account
raw provider identity payload
payment credentials
```

If export requires personal data, it must be classified as:

```text id="v9zbie"
IDENTITY_EXPORT_RESTRICTED
```

and must require approval, audit, retention purpose, and expiration.

---

## 19. Analytics Rule

Analytics must use de-identified, tokenized, or aggregated identity.

Analytics should use:

```text id="thzt3w"
anonymous_customer_key
rotating_customer_token
aggregated segment
store-level metric
tenant-level metric
```

Analytics must not use CI/DI as a join key.

Cross-service tracking must be avoided unless there is explicit consent and legal basis.

---

## 20. AI And Agent Rule

AI/Agent Runtime must not receive raw CI/DI.

Agent may receive:

```text id="duze7z"
customer behavior summary
order pattern
masked customer reference
risk flag
support category
```

Agent must not receive:

```text id="mi7dd0"
raw CI
raw DI
full phone
full email
raw provider identity payload
payment credential
```

AI recommendations must operate on minimized and purpose-limited data.

---

## 21. Consent And Linking Rule

Identity linking requires consent and purpose limitation.

A linking record should include:

```text id="sd69hz"
internal_customer_id
external_provider_name
external_customer_reference
consent_reference
link_purpose
linked_at
unlink_status
retention_policy
```

CI/DI must not be used as hidden universal link key across services.

The customer must not be silently merged across unrelated service contexts.

---

## 22. Provider Contract Rule

Provider contracts must define identity data scope.

Provider integration must document:

```text id="gvn44x"
which identity fields are received
why they are needed
whether CI or DI is included
whether provider customer ID is stable
whether identity can be masked
whether raw payload can be minimized
retention requirement
deletion or unlinking rule
breach notification obligation
```

If the provider sends unnecessary high-risk identity, the integration must request minimization or apply ingestion filtering.

---

## 23. Credential And Identity Separation

Provider credentials and customer identity must be stored separately.

The system must not store:

```text id="qx365o"
provider credential
customer identity
payment identity
webhook secret
raw provider payload
```

in the same unrestricted operational area.

Credential exposure and identity exposure must be treated as separate but serious incidents.

---

## 24. Access Control Rule

Access to sensitive identity must follow least privilege.

Access control should include:

```text id="0t9jo0"
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

Raw CI/DI access should be blocked by default.

---

## 25. Break-Glass Rule

Emergency access to sensitive identity may be allowed only through break-glass procedure.

Break-glass must require:

```text id="f5f612"
reason
actor identity
reauthentication
time limit
scope limit
audit event
post-access review
```

Break-glass access must not be normalized into routine support workflow.

---

## 26. Encryption Rule

Sensitive identity must be encrypted at rest and protected in transit.

Encryption policy should include:

```text id="g7qz0y"
field-level encryption where necessary
separate key management
key rotation
restricted decryption path
no plaintext replication
encrypted backups
secure transport
```

Encryption alone is not enough.

Minimization, isolation, masking, and access control are also required.

---

## 27. Hashing Rule

If a lookup key is needed, use keyed hash or tokenization rather than raw identity.

Plain unsalted hash of CI/DI is not sufficient if it can be matched or reused.

Recommended approach:

```text id="zsu0yv"
purpose-specific token
tenant-scoped keyed hash
rotatable secret
limited lookup context
no cross-context reuse
```

The same identifier must not become a universal join key across all services.

---

## 28. Retention Rule

Sensitive identity must have a retention policy.

Retention states may include:

```text id="1wjzpg"
ACTIVE
PURPOSE_EXPIRED
DELETION_REQUESTED
DELETED
ANONYMIZED
LEGAL_HOLD
RETENTION_EXCEPTION
```

CI/DI must not be retained indefinitely by default.

If retention is required, the reason must be documented.

---

## 29. Deletion And Unlink Rule

Customer identity unlinking must be supported where applicable.

Unlinking may include:

```text id="q1x6v2"
remove external provider link
delete vault identity if no legal retention
rotate customer token
anonymize analytics reference
preserve order record without direct identity
preserve audit without raw identity
```

Operational order history may remain, but direct identity link should be removed or minimized according to policy.

---

## 30. Breach Impact Classification

If sensitive identity is exposed, impact must be classified.

High-risk exposure includes:

```text id="wmzijc"
raw CI exposed
raw DI exposed
identity vault accessed
full phone and name exposed
payment identity exposed
provider identity link exposed
raw payload containing identity exposed
support export containing identity exposed
```

Such incidents must trigger security incident handling, notification review, and access audit review.

---

## 31. Security Incident Response

If CI/DI or equivalent high-risk identity may be exposed, the incident must enter security incident response.

Response should include:

```text id="6sg5hl"
contain access
preserve evidence
identify affected data fields
identify affected users
review access logs
rotate credentials if needed
notify internal owner
legal/privacy review
regulator notification review
customer notification review
post-incident remediation
```

Operational support closure is not enough for identity breach closure.

---

## 32. Audit Requirements

The system must create append-only audit events for:

```text id="rjl0by"
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

Audit must include:

```text id="x9gf1h"
actor
purpose
tenant_id
store_id if applicable
identity_reference
access_scope
timestamp
approval_reference if any
```

Audit must not include raw CI/DI.

---

## 33. Prohibited Handling

The following are prohibited:

```text id="02lwh7"
storing raw CI/DI in customer profile table
storing raw CI/DI in order table
storing raw CI/DI in POS adapter event table
storing raw CI/DI in payment event table
logging CI/DI in application logs
showing CI/DI in support screens
exporting CI/DI by default
using CI/DI as analytics join key
sending CI/DI to AI/Agent runtime
copying raw provider identity into audit text
treating encryption as sufficient by itself
```

---

## 34. MVP Cutline

For MVP, the system should support:

```text id="jid978"
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

```text id="k9sxpe"
full identity vault implementation
full CI/DI storage
advanced consent management
automatic privacy risk scoring
full data subject request automation
multi-country privacy automation
AI privacy redaction engine
```

MVP should avoid collecting high-risk identity rather than building complex storage first.

---

## 35. Relationship To POS And Provider Integration Documents

This document supports:

```text id="dzazpg"
04300 POS Provider Abstraction And Multi-POS Adapter Policy
04310 Canonical Order Model And POS Event Normalization Policy
04320 POS Adapter Capability Level And Integration Contract Policy
04330 POS Adapter Error Code And Diagnostic Message Policy
04360 POS Provider Onboarding Evidence And Contract Checklist Policy
04370 POS Integration Monitoring Replay And Incident Runbook Policy
04380 POS Integration Support Escalation And Vendor Communication Policy
04400 Toss Payments MVP Integration Boundary Policy
04410 PAYCO Payment And Order Provider MVP Boundary Policy
04420 POS Adapter Runtime Data Object And Event Family Policy
04430 OKPOS And Major POS Integration Candidate Policy
```

Identity protection must apply across POS, payment, order, membership, support, diagnostic, and AI runtimes.

---

## 36. Patent And SaaS Relevance

This policy supports SaaS trust and scalability.

The platform may integrate many POS, payment, table order, kiosk, and membership providers.

That increases identity exposure risk unless identity is minimized and isolated.

The strategic structure is:

```text id="gz3aqy"
many providers
many identity references
many store environments
        ↓
identity minimization
vault or token reference
runtime separation
masked diagnostics
controlled support access
audit and breach response
```

The system must not become powerful by becoming dangerous.

A SaaS platform wins only if it can integrate broadly while exposing narrowly.

---

## 37. Known Gaps To Track

The following gaps must remain visible:

```text id="eonjpz"
whether CI/DI is needed at all
legal basis for CI/DI collection
identity vault implementation design
field-level encryption approach
key management approach
consent and unlinking policy
provider-specific identity fields
retention period by identity type
privacy notice wording
incident notification workflow
```

Until these gaps are resolved, raw CI/DI must remain excluded from MVP.

---

## 38. Readiness Check

This policy is ready when:

```text id="z9pk5q"
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
```

---

## 39. Summary

CI and DI are not ordinary customer fields.

They are high-risk persistent identifiers.

The safest MVP policy is:

```text id="pwrqpx"
do not collect CI/DI
do not store CI/DI
do not log CI/DI
do not export CI/DI
do not send CI/DI to AI
do not show CI/DI to support
```

If future business or legal requirements force CI/DI handling, it must be done through a controlled identity vault with encryption, masking, purpose limitation, access audit, retention control, and breach response.

The system should be designed so daily store operation, POS integration, payment verification, KDS release, and support diagnostics can work without raw CI/DI.
