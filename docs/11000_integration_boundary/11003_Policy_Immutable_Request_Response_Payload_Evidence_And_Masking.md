# 11003_Policy_Immutable_Request_Response_Payload_Evidence_And_Masking

## 1. Purpose

This document defines immutable request/response payload evidence, masked raw payload preservation, payload hashing, canonical payload evidence, provider response preservation, sensitive data masking, restricted evidence access, support/Admin summary boundary, dispute proof, and no-code boundary policy for the Yoonsul Wait/Order Handoff operating system.

The previous document defined Gateway correlation id and transaction lifecycle traceability.

This document focuses on preserving evidence of what Yoonsul sent to and received from external black-box systems, including POS, PG, VAN, payment provider, provider adapter, Redtable-type partner, delivery platform, local daemon, store POS PC, and store network boundary.

This document does not implement payload storage, schema, object storage, encryption, hashing, masking engine, audit storage, Gateway connector, provider adapter, POS connector, support console, or Admin console.

It defines immutable payload evidence and masking policy only.

---

## 2. Scope

This document covers:

- immutable request payload evidence
- immutable response payload evidence
- masked raw payload preservation
- payload hash
- canonical payload hash
- request/response metadata
- provider code preservation
- sensitive field masking
- restricted raw evidence access
- support/Admin summary boundary
- AI support evidence boundary
- dispute evidence
- evidence correction/supersession
- no-code boundary

This document does not cover:

- final storage design
- final encryption design
- final object storage bucket
- final database schema
- final log pipeline
- final masking implementation
- final hash algorithm selection
- final provider connector implementation
- final production monitoring

---

## 3. Core Principle

Payload evidence must be preserved without exposing sensitive data.

The project must follow this rule:

> Every external Gateway request and response that can affect order, payment, refund/cancel, POS, KDS, provider mapping, delivery platform, Redtable-type partner, support recovery, or settlement must produce immutable, correlation-linked, idempotency-linked, masked request/response evidence and payload hash so that Yoonsul can prove what was sent, what was received, what was accepted, what was rejected, and what remained uncertain.

Parsed logs are not enough.

Summary logs are not enough.

Mutable logs are not enough.

Unmasked raw logs are unsafe.

---

## 4. Immutable Payload Evidence Meaning

Immutable payload evidence means a record of request/response content and metadata that cannot be silently modified after creation.

Payload evidence may include:

- masked raw payload
- payload hash
- canonical payload hash
- request headers after masking
- response headers after masking
- provider status code
- provider error code
- timestamp
- target endpoint or logical operation
- attempt number
- correlation id
- idempotency key
- evidence reference
- audit reference

Immutable does not mean every sensitive value is stored raw.

Immutable means evidence integrity is preserved.

---

## 5. Request Payload Evidence Meaning

Request payload evidence means proof of what Yoonsul attempted to send externally.

It should answer:

- who sent it?
- when was it sent?
- what runtime created it?
- what external system was targeted?
- what logical operation was requested?
- what correlation id applied?
- what idempotency key applied?
- what attempt number was it?
- what masked payload was sent?
- what hash proves payload integrity?
- what headers or metadata existed?
- what timeout/retry policy applied?

Request evidence proves Yoonsul handoff behavior.

---

## 6. Response Payload Evidence Meaning

Response payload evidence means proof of what the external system returned or failed to return.

It should answer:

- when was response received?
- what provider/system returned it?
- what status code was returned?
- what error code was returned?
- what response body was returned?
- what provider reference was returned?
- what correlation mapping existed?
- was response success, failure, timeout, malformed, duplicate, stale, or uncertain?
- what hash proves response integrity?
- what canonical event mapping happened?

Response evidence proves external boundary behavior.

---

## 7. Payload Evidence Status Values

Recommended status values:

- `PAYLOAD_EVIDENCE_NOT_CREATED`
- `PAYLOAD_EVIDENCE_CREATED`
- `PAYLOAD_EVIDENCE_MASKED`
- `PAYLOAD_EVIDENCE_HASHED`
- `PAYLOAD_EVIDENCE_STORED`
- `PAYLOAD_EVIDENCE_RESTRICTED`
- `PAYLOAD_EVIDENCE_SUMMARY_AVAILABLE`
- `PAYLOAD_EVIDENCE_REDACTION_REQUIRED`
- `PAYLOAD_EVIDENCE_CORRECTION_REQUIRED`
- `PAYLOAD_EVIDENCE_BLOCKED`
- `PAYLOAD_EVIDENCE_SUPERSEDED`
- `PAYLOAD_EVIDENCE_RETENTION_REVIEW_REQUIRED`

Status may be normalized later.

---

## 8. Payload Evidence Record Fields

Each payload evidence record should include:

- evidence id
- correlation id
- idempotency key if applicable
- runtime owner
- source system
- target system
- provider name
- logical operation
- direction
- attempt number
- request timestamp
- response timestamp if applicable
- timeout threshold if applicable
- payload type
- masked payload reference
- payload hash
- canonical payload hash if applicable
- header evidence reference
- provider request id if available
- provider response id if available
- provider status code
- provider error code
- sensitivity class
- masking status
- access restriction
- audit event id if applicable
- evidence packet id
- notes

Payload evidence must be traceable.

---

## 9. Payload Evidence ID Format

Recommended format:

    PAYLOAD-EVIDENCE-[DIRECTION]-[YYYYMMDD]-[NUMBER]

Examples:

    PAYLOAD-EVIDENCE-REQ-20260612-001
    PAYLOAD-EVIDENCE-RES-20260612-001

Final format may be normalized later.

---

## 10. Direction Values

Recommended direction values:

- `REQUEST_OUTBOUND`
- `RESPONSE_INBOUND`
- `CALLBACK_INBOUND`
- `WEBHOOK_INBOUND`
- `LOCAL_DAEMON_OUTBOUND`
- `LOCAL_DAEMON_INBOUND`
- `PROVIDER_EVENT_INBOUND`
- `PARTNER_PROJECTION_OUTBOUND`
- `SUPPORT_EXPORT_OUTBOUND`
- `RECONCILIATION_IMPORT_INBOUND`

Direction defines evidence interpretation.

---

## 11. Payload Type Values

Recommended payload type values:

- `POS_ORDER_REQUEST`
- `POS_ORDER_RESPONSE`
- `PAYMENT_REQUEST`
- `PAYMENT_RESPONSE`
- `PAYMENT_CALLBACK`
- `REFUND_REQUEST`
- `REFUND_RESPONSE`
- `KDS_HANDOFF_REQUEST`
- `KDS_HANDOFF_RESPONSE`
- `PROVIDER_EVENT`
- `DELIVERY_PLATFORM_EVENT`
- `REDTABLE_PARTNER_REQUEST`
- `REDTABLE_PARTNER_RESPONSE`
- `GLOBAL_PAYMENT_REQUEST`
- `GLOBAL_PAYMENT_RESPONSE`
- `LOCAL_DAEMON_REQUEST`
- `LOCAL_DAEMON_RESPONSE`
- `EXTERNAL_MENU_PROJECTION_PAYLOAD`
- `SUPPORT_EVIDENCE_EXPORT`
- `RECONCILIATION_REPORT`

Payload type should drive masking and retention.

---

## 12. Immutable Storage Rule

Payload evidence must not be silently overwritten.

Allowed changes:

- append correction record
- append redaction record
- append supersession reference
- append retention review note
- append legal/security hold note
- append access audit

Prohibited changes:

- silent edit
- silent delete
- replacing payload without version link
- editing provider response code
- removing failed attempt
- removing timeout record
- removing duplicate/stale evidence

Evidence integrity requires immutability.

---

## 13. Payload Hash Rule

Every preserved payload evidence record should include a hash.

Hash should prove:

- payload content integrity
- payload evidence reference integrity
- dispute consistency
- no silent alteration
- comparison across retries
- comparison across provider disputes

Hash algorithm may be selected during implementation planning.

This document requires the concept, not the implementation.

---

## 14. Canonical Payload Hash Rule

Canonical payload hash may be used when raw field order, formatting, whitespace, or provider envelope differs.

Canonical hash should apply after:

- field normalization
- stable ordering
- excluded volatile fields
- masking if required
- canonical serialization

Canonical hash helps compare semantically identical payloads.

Canonicalization must be documented.

---

## 15. Masked Raw Payload Rule

Gateway should preserve masked raw payload evidence.

Masked raw payload should retain:

- field names
- non-sensitive values
- structural shape
- provider field order if useful
- status codes
- error codes
- public references
- timing metadata
- amount/currency if allowed and necessary
- masked identifiers
- evidence usability

Masked payload must not expose restricted sensitive values.

---

## 16. Sensitive Field Masking Rule

Sensitive fields must be masked, redacted, tokenized, or excluded according to sensitivity.

Sensitive fields include:

- card number
- card expiry
- card CVC
- account number
- CI
- DI
- resident registration number
- passport number
- phone number
- email
- access token
- refresh token
- API key
- signature secret
- provider secret
- session token
- identity document image
- private staff data
- raw customer personal data

Sensitive fields must not appear in normal evidence views.

---

## 17. Partial Masking Rule

Partial masking may be allowed when dispute value requires limited display.

Examples:

- last 4 digits of card if allowed
- last 4 digits of phone if allowed
- masked email domain if allowed
- provider reference suffix
- truncated token fingerprint
- hashed identifier
- amount and currency if needed
- store id if non-sensitive

Partial masking must be deliberate.

---

## 18. Prohibited Raw Storage Rule

Certain data should not be stored raw in Gateway evidence unless explicitly required and approved.

Prohibited by default:

- full card number
- CVC
- full CI/DI
- identity document images
- provider secrets
- API keys
- raw access tokens
- unmasked authentication headers
- raw passwords
- biometric data
- private legal documents
- unrestricted raw support exports

If unavoidable, security/legal review is required.

---

## 19. Header Evidence Rule

Request and response header evidence should be preserved after masking.

Header evidence may include:

- content type
- request id
- correlation id header
- idempotency key header
- provider trace header
- timestamp
- signature presence marker
- authorization presence marker
- user agent if relevant
- retry-after header
- rate limit header

Sensitive header values must be masked.

---

## 20. Provider Status Code Rule

Provider status code and error code must be preserved.

This includes:

- HTTP status if applicable
- provider application status
- provider error code
- provider error message after masking
- POS return code
- PG/VAN response code
- payment network response code if exposed
- local daemon status
- partner module status

Provider code preservation is essential for dispute response.

---

## 21. Timeout Evidence Rule

When no response is received, response payload evidence should still exist as timeout evidence.

Timeout evidence should include:

- request evidence reference
- timeout threshold
- timeout timestamp
- target system
- attempt number
- idempotency key
- retry decision
- uncertainty status
- fallback action
- support/Admin summary

Timeout is evidence.

No response is a response condition.

---

## 22. Malformed Response Evidence Rule

Malformed response must be preserved as evidence after masking.

Malformed evidence should include:

- raw malformed response reference if safe
- parse error summary
- provider status code if available
- response hash
- received timestamp
- mapping failure
- quarantine decision
- support/Admin summary

Malformed response must not be discarded.

---

## 23. Duplicate Response Evidence Rule

Duplicate response or duplicate callback must preserve evidence.

Duplicate evidence should include:

- duplicate detection basis
- idempotency key
- provider event id
- current runtime state
- previous evidence reference
- duplicate evidence reference
- blocked effect
- support/Admin summary

Duplicate evidence proves non-duplication.

---

## 24. Stale Response Evidence Rule

Stale response or stale callback must preserve evidence.

Stale evidence should include:

- provider timestamp
- received timestamp
- current runtime state
- stale threshold
- rejected mutation
- quarantine status
- evidence reference
- support/Admin summary

Stale evidence proves why state was not overwritten.

---

## 25. Retry Payload Evidence Rule

Each retry attempt must have separate payload evidence.

Retry evidence must link:

- correlation id
- idempotency key
- attempt number
- request payload evidence
- response payload evidence
- timeout result
- provider error
- final outcome

Retries should be comparable without creating duplicate state.

---

## 26. Request Response Pairing Rule

Outbound request and inbound response should be paired when possible.

Pairing should use:

- correlation id
- idempotency key
- provider request id
- provider response id
- attempt number
- timestamp window
- target endpoint/logical operation

Unpaired response should become orphan evidence.

---

## 27. Orphan Payload Evidence Rule

Orphan payload evidence means request or response cannot be matched to known transaction.

Orphan evidence should be:

- recorded
- masked
- hashed
- quarantined
- linked to provider reference if available
- searched against correlation records
- investigated
- accepted only after reconciliation

Orphan payload must not mutate truth.

---

## 28. POS Payload Evidence Rule

POS request/response evidence must preserve:

- POS handoff request
- POS accepted/rejected response
- POS return code
- POS transaction reference if available
- POS timeout
- POS retry
- POS reconciliation marker
- local daemon reference if applicable
- masked payload
- payload hash

POS black-box disputes require payload evidence.

---

## 29. Payment Payload Evidence Rule

Payment evidence must preserve:

- payment request
- payment response
- payment callback
- provider payment id
- payment status
- payment error code
- authorization/capture reference if applicable
- refund reference if applicable
- amount/currency if allowed
- duplicate/stale classification
- reconciliation status

Payment payload evidence has high sensitivity.

---

## 30. KDS Handoff Payload Evidence Rule

KDS handoff evidence should preserve:

- ticket request
- ticket response if applicable
- hold/release reason
- item state candidate
- retry/remake reference
- cancel request reference
- staff-visible message key
- payload hash
- evidence packet

KDS evidence must not expose unnecessary customer identity.

---

## 31. Provider Adapter Payload Evidence Rule

Provider adapter evidence should preserve:

- external event payload
- signature/auth validation result
- provider event id
- provider timestamp
- mapping candidate
- rejected/mapped/quarantined result
- canonical event candidate
- target runtime
- evidence packet
- audit reference if needed

Provider event must not become truth without evidence.

---

## 32. Redtable-Type Partner Payload Evidence Rule

Redtable-type partner evidence should preserve:

- partner request
- partner response
- menu mapping payload
- translated menu dataset reference
- external menu projection payload
- global payment request if applicable
- global payment response if applicable
- partner callback if applicable
- settlement reference if applicable
- provider evidence status

Partner payload evidence must remain public/private separated.

---

## 33. External Menu Projection Payload Evidence Rule

External menu projection evidence should preserve:

- public store package
- public menu package
- locale
- content version
- published timestamp
- partner target
- Google Maps landing reference if applicable
- QR/NFC projection reference
- payload hash
- stale threshold
- unpublish/rollback reference

External projection evidence proves what public content was shown.

---

## 34. Local Daemon Payload Evidence Rule

Local daemon evidence should preserve:

- cloud-to-daemon request
- daemon receipt status
- daemon-to-POS request if available
- POS response received by daemon
- daemon-to-cloud response
- local timeout
- device offline marker
- network issue marker
- attempt number
- payload hash

Local daemon evidence separates cloud and store-side fault.

---

## 35. Store Network Evidence Boundary Rule

Store network evidence should be recorded as observed condition, not unsupported accusation.

Store-side evidence may include:

- daemon offline status
- last heartbeat
- POS PC unavailable
- network unreachable
- timeout to local endpoint
- connection refused
- DNS failure
- TLS failure
- operator restart marker if known
- store support note

Gateway must distinguish evidence from assumption.

---

## 36. Support View Rule

Support default view should show:

- correlation id
- lifecycle summary
- provider/system involved
- status/result
- provider code summary
- timeout/retry summary
- evidence availability
- customer-safe message
- escalation path

Support default view should not show:

- unmasked payload
- secrets
- full card data
- CI/DI
- raw tokens
- restricted identity data
- internal security details

Support needs recovery context, not raw payload freedom.

---

## 37. Admin View Rule

Admin default view should show:

- evidence packet status
- provider incident summary
- POS/payment/KDS status summary
- retry/timeout count
- reconciliation required marker
- blocker status
- support case linkage
- audit linkage
- external partner projection status

Admin default view should not show unrestricted raw payload.

Admin coordinates evidence workflow.

---

## 38. Security View Rule

Security view may access restricted evidence only under policy.

Security access should require:

- role authorization
- reason
- case/reference
- time-bound access
- audit event
- masking policy
- export restriction
- legal review if needed

Security access itself must be audited.

---

## 39. AI Support Evidence Rule

AI support may use payload evidence only as masked summary.

AI support must not receive:

- raw payment payload
- unmasked personal data
- provider secrets
- authentication headers
- full support export
- restricted evidence

AI may receive:

- evidence summary
- provider code summary
- timeline summary
- recovery action
- source reference
- confidence/freshness

AI must not invent payload evidence.

---

## 40. Evidence Export Rule

Export of payload evidence must be restricted.

Export requires review when it includes:

- payment evidence
- provider payload
- POS dispute packet
- support case data
- customer personal data
- security event data
- partner dispute data
- raw or near-raw payload

Export should be masked and audit-linked.

---

## 41. Correction Rule

Payload evidence correction must be append-only.

Correction may include:

- masking correction
- classification correction
- provider mapping correction
- metadata correction
- pairing correction
- retention review correction
- legal hold note

Original evidence must remain traceable unless legally required otherwise.

---

## 42. Supersession Rule

Supersession may occur when:

- better masking version exists
- canonical payload hash recalculated
- corrected metadata added
- provider response later reconciled
- orphan evidence matched to correlation id
- external projection version updated

Supersession must preserve previous reference.

---

## 43. Retention Placeholder Rule

Payload evidence retention should consider:

- payment dispute period
- refund/cancel dispute period
- POS dispute period
- provider dispute period
- partner dispute period
- support case period
- audit retention
- security incident period
- legal hold
- pilot evidence period

Final retention policy may be defined later.

---

## 44. Build Gate Rule

Build gate must block external handoff if:

- request evidence missing
- response evidence missing
- timeout evidence missing
- payload hash missing
- masking rule missing
- sensitive fields unclassified
- provider return code not preserved
- retry attempt evidence missing
- duplicate/stale evidence missing
- raw evidence access boundary missing
- support/Admin summary missing
- evidence correction path missing
- export restriction missing

Payload evidence is mandatory for external handoff.

---

## 45. Pilot Rule

Pilot dry run must test payload evidence for:

- successful request/response
- provider error response
- timeout/no response
- malformed response
- duplicate callback
- stale callback
- POS rejection
- local daemon offline
- external menu projection publish/unpublish
- support evidence lookup
- Admin evidence review

Pilot must prove evidence usability.

---

## 46. Registers Recommendation

Recommended future files:

    docs/_index/
      Payload_Evidence_Register.md
      Request_Payload_Evidence_Register.md
      Response_Payload_Evidence_Register.md
      Payload_Hash_Register.md
      Masked_Raw_Payload_Register.md
      Sensitive_Field_Masking_Register.md
      Provider_Return_Code_Evidence_Register.md
      Timeout_Payload_Evidence_Register.md
      Duplicate_Stale_Payload_Evidence_Register.md
      Orphan_Payload_Evidence_Register.md
      Payload_Evidence_Access_Register.md
      Payload_Evidence_Export_Register.md
      Payload_Evidence_Correction_Register.md

This document only recommends these files.

It does not create them.

---

## 47. Anti-Patterns

The following are prohibited:

- keeping parsed logs only
- discarding raw evidence shape
- storing unmasked card data
- storing provider secrets in evidence view
- losing provider error code
- treating timeout as generic failure
- retrying without attempt-level evidence
- overwriting payload evidence
- deleting failed attempt evidence
- letting Support view unrestricted raw payload
- letting Admin mutate truth from evidence
- letting AI read raw payment payload
- publishing external menu without projection evidence
- accepting provider result without evidence

---

## 48. No-Code Boundary

This document does not authorize:

- payload storage implementation
- database schema
- object storage implementation
- encryption implementation
- masking engine
- hash implementation
- Gateway implementation
- provider adapter
- POS connector
- payment connector
- local daemon
- support console
- Admin console
- AI support gateway
- production pilot

This document governs immutable request/response payload evidence and masking policy only.

---

## 49. Readiness Check

This document is ready when the project can answer:

1. What is immutable payload evidence?
2. What is request payload evidence?
3. What is response payload evidence?
4. What payload evidence statuses exist?
5. What fields should payload evidence record include?
6. What direction values exist?
7. What payload type values exist?
8. What immutable storage rule applies?
9. What payload hash rule applies?
10. What canonical payload hash rule applies?
11. What masked raw payload rule applies?
12. What sensitive field masking rule applies?
13. What partial masking rule applies?
14. What prohibited raw storage rule applies?
15. What header evidence rule applies?
16. What provider status code rule applies?
17. What timeout evidence rule applies?
18. What malformed response evidence rule applies?
19. What duplicate response evidence rule applies?
20. What stale response evidence rule applies?
21. What retry payload evidence rule applies?
22. What request/response pairing rule applies?
23. What orphan payload evidence rule applies?
24. What POS payload evidence rule applies?
25. What payment payload evidence rule applies?
26. What KDS handoff payload evidence rule applies?
27. What provider adapter payload evidence rule applies?
28. What Redtable-type partner payload evidence rule applies?
29. What external menu projection payload evidence rule applies?
30. What local daemon payload evidence rule applies?
31. What store network evidence boundary rule applies?
32. What Support view rule applies?
33. What Admin view rule applies?
34. What Security view rule applies?
35. What AI support evidence rule applies?
36. What evidence export rule applies?
37. What correction rule applies?
38. What supersession rule applies?
39. What retention placeholder rule applies?
40. What build gate rule applies?
41. What pilot rule applies?
42. What registers are recommended?
43. What anti-patterns are prohibited?
44. What no-code boundary applies?

If these questions cannot be answered, immutable request/response payload evidence and masking planning is incomplete.

---

## 50. Conclusion

Immutable payload evidence is the factual proof behind Gateway integrity.

The safe evidence flow is:

    Gateway prepares request
        -> correlation id linked
        -> idempotency key linked
        -> request payload masked and hashed
        -> external handoff sent
        -> response, timeout, malformed response, duplicate, or stale event captured
        -> response payload masked and hashed
        -> provider codes preserved
        -> canonical event mapping recorded
        -> evidence packet linked
        -> audit/support/Admin/AI-safe summaries created

This document ensures that Yoonsul can prove what was sent and what was received without exposing sensitive data or relying on mutable, incomplete, or summary-only logs.

Logs are not enough.

Immutable masked payload evidence is the dispute shield.