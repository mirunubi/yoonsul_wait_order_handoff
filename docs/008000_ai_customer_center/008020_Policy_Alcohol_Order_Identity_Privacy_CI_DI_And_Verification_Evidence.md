# 008020_Policy_Alcohol_Order_Identity_Privacy_CI_DI_And_Verification_Evidence.md

## Purpose

This document defines the alcohol order identity privacy, CI/DI handling, adult verification evidence, identity data minimization, masking, storage boundary, support visibility, Admin Console visibility, audit evidence, and leakage prevention policy for the Yoonsul Wait/Order Handoff documentation project.

The previous document defined alcohol sales adult verification and legal sale boundary policy.

This document focuses on privacy and evidence handling when adult verification or identity linkage is required for alcohol-related ordering.

This document does not implement identity verification, CI/DI storage, ID scanning, database schema, encryption, provider integration, or legal compliance workflow.

It defines identity privacy and verification evidence boundary policy only.

---

## 2. Scope

This document covers:

- identity data boundary
- CI/DI boundary
- adult verification evidence
- identity minimization
- masking
- support visibility
- Admin Console visibility
- KDS visibility
- payment visibility
- log visibility
- export restriction
- retention placeholder
- leakage response boundary
- no-implementation boundary

This document does not cover:

- final identity provider
- final CI/DI implementation
- final encryption design
- final database schema
- final ID image capture
- final government API integration
- final legal retention rule
- final privacy notice
- final consent wording
- final production security control

---

## 3. Core Principle

Adult verification evidence must prove eligibility without exposing identity unnecessarily.

The project must follow this rule:

> Alcohol-related identity verification must store and display the minimum evidence needed to prove verification status, while preventing raw CI/DI, ID document data, provider payloads, and sensitive identity details from appearing in operational screens, KDS, support views, logs, exports, or customer-facing flows.

Verification status is operationally useful.

Raw identity data is not.

---

## 4. Identity Privacy Boundary Meaning

Identity privacy boundary means defining:

- what identity data may be received
- what identity data may be stored
- what identity data must be discarded
- what identity data may be displayed
- what identity data must be masked
- who may view verification status
- who may request unmasking
- what evidence is sufficient
- what logs must avoid
- what export is prohibited
- how leakage is handled

This boundary must be defined before any identity verification integration.

---

## 5. Identity Data Categories

Recommended identity data categories:

- `IDENTITY_NONE`
- `VERIFICATION_STATUS_ONLY`
- `VERIFICATION_PROVIDER_REFERENCE`
- `AGE_ELIGIBILITY_RESULT`
- `NAME_MASKED`
- `BIRTHDATE_MASKED`
- `PHONE_MASKED`
- `CI_DI_LINKAGE_MASKED`
- `CI_DI_RAW`
- `ID_DOCUMENT_IMAGE`
- `ID_DOCUMENT_NUMBER`
- `PROVIDER_RAW_PAYLOAD`
- `MANUAL_STAFF_CONFIRMATION`
- `IDENTITY_UNKNOWN`

Operational systems should prefer status-only evidence.

---

## 6. CI DI Boundary

CI/DI or similar identity linkage must be treated as sensitive identity data.

Rules:

- raw CI/DI must not be shown in operational UI
- raw CI/DI must not be shown in KDS
- raw CI/DI must not be shown in support case view by default
- raw CI/DI must not be exported through normal reports
- raw CI/DI must not appear in logs
- raw CI/DI must not be used as visible customer identifier
- raw CI/DI must be separated from order display identifiers
- raw CI/DI access requires explicit security/legal policy

CI/DI is identity linkage, not store operation information.

---

## 7. Adult Verification Evidence Meaning

Adult verification evidence means the minimal proof that alcohol sale eligibility was checked.

It may include:

- verification required status
- verification result
- verification method
- verification timestamp
- verification provider reference
- staff confirmation if manual
- verification failure reason category
- verification uncertainty reason category
- verification expiration status
- linked order/session reference
- masking status
- reviewer if any

Evidence should not include raw identity payload unless legally required and approved.

---

## 8. Verification Evidence Categories

Recommended verification evidence categories:

- `EVIDENCE_STATUS_ONLY`
- `EVIDENCE_PROVIDER_REFERENCE`
- `EVIDENCE_MANUAL_STAFF_CONFIRMATION`
- `EVIDENCE_FAILURE_REASON_CATEGORY`
- `EVIDENCE_UNCERTAINTY_REASON_CATEGORY`
- `EVIDENCE_EXPIRATION_RECORD`
- `EVIDENCE_SERVICE_REFUSAL_LINK`
- `EVIDENCE_SUPPORT_ESCALATION_LINK`
- `EVIDENCE_LEGAL_REVIEW_REQUIRED`
- `EVIDENCE_RAW_IDENTITY_RESTRICTED`

Default should be status-only or provider reference.

---

## 9. Data Minimization Rule

Identity data collection must follow minimization.

Collect only what is required to determine:

- adult eligibility
- verification status
- verification method
- verification time
- verification failure or uncertainty category
- evidence reference
- staff confirmation if any

Do not collect identity details merely because a provider offers them.

Do not store raw data merely because it was received.

---

## 10. Verification Result Abstraction Rule

Operational screens should display abstracted status.

Allowed examples:

- `Adult verification passed`
- `Verification required`
- `Verification failed`
- `Staff confirmation required`
- `Verification provider unavailable`
- `Manual confirmation recorded`

Avoid displaying:

- full name
- full birthdate
- ID document number
- raw CI/DI
- provider raw response
- detailed government verification payload
- ID image

Staff needs decision status, not raw identity.

---

## 11. Verification Failure Reason Category

Failure reason should be categorized safely.

Recommended categories:

- `FAILURE_UNDERAGE_OR_NOT_ELIGIBLE`
- `FAILURE_DOCUMENT_INVALID`
- `FAILURE_USER_CANCELLED`
- `FAILURE_PROVIDER_REJECTED`
- `FAILURE_MANUAL_REVIEW_FAILED`
- `FAILURE_RECIPIENT_MISMATCH`
- `FAILURE_EXPIRED_VERIFICATION`
- `FAILURE_UNKNOWN`

Customer-facing wording should be even safer and less accusatory.

---

## 12. Verification Uncertainty Reason Category

Uncertainty reason should be categorized safely.

Recommended categories:

- `UNCERTAIN_PROVIDER_TIMEOUT`
- `UNCERTAIN_PROVIDER_UNAVAILABLE`
- `UNCERTAIN_NETWORK_ERROR`
- `UNCERTAIN_DATA_MISMATCH`
- `UNCERTAIN_MANUAL_REVIEW_REQUIRED`
- `UNCERTAIN_STAFF_NOT_AVAILABLE`
- `UNCERTAIN_DEVICE_RISK`
- `UNCERTAIN_SESSION_MISMATCH`
- `UNCERTAIN_UNKNOWN`

Uncertainty must not become pass.

---

## 13. Staff-Facing Identity Rule

Staff-facing screens may show:

- verification required
- verification passed
- verification failed
- verification uncertain
- staff confirmation required
- service refusal review required
- manual confirmation recorded
- safe reason category
- next action

Staff-facing screens must not show:

- raw CI/DI
- full identity payload
- raw ID document
- full birthdate
- full ID number
- provider raw response
- customer private data unrelated to sale

Staff authority is operational, not identity browsing.

---

## 14. KDS Identity Rule

KDS must not receive identity data.

KDS may receive only:

- alcohol hold status
- release allowed status
- staff approval required status
- service refusal/cancel status if operationally needed
- safe order reference
- kitchen-safe note

KDS must not receive:

- customer age
- customer name unless already ordinary order label and allowed
- raw CI/DI
- ID verification payload
- failure reason detail
- ID document data

Kitchen needs fulfillment state, not identity data.

---

## 15. Payment Identity Rule

Payment surfaces may show only what is needed for payment safety.

Payment flow may need:

- alcohol verification required before charge
- alcohol item held
- refund/cancel required due to verification failure
- payment uncertainty status
- split non-alcohol order status

Payment surface must not expose raw identity data.

Payment evidence should link to verification status, not identity payload.

---

## 16. Support Visibility Rule

Support view must be masked by default.

Support may see:

- verification status
- safe failure category
- safe uncertainty category
- provider reference if needed and allowed
- support escalation status
- customer recovery status
- staff confirmation status
- evidence packet reference

Support must not see raw CI/DI, full ID data, or provider raw payload by default.

Unmasking requires separate approval.

---

## 17. Admin Console Visibility Rule

Admin Console may show:

- verification counts
- failed verification count
- uncertain verification count
- provider unavailable count
- staff confirmation pending count
- service refusal review count
- evidence status
- support escalation status

Admin Console must not show raw identity data in dashboards or list tables.

Detail pages must enforce field-level masking.

---

## 18. Customer-Facing Identity Rule

Customer-facing flows should show:

- verification required
- verification in progress
- verification passed
- verification could not be completed
- staff assistance available
- alcohol item cannot proceed until verification
- non-alcohol item may continue if safe

Customer-facing flow should not expose internal provider reason or sensitive identity handling.

---

## 19. Manual Verification Evidence Rule

Manual verification evidence should record:

- staff actor
- timestamp
- verification method category
- confirmation result
- sale/session scope
- reason
- service refusal if any
- evidence status
- audit reference

Manual verification evidence should not store ID image or full ID number unless legally required and separately approved.

---

## 20. ID Document Image Rule

ID document image is high-risk.

Default rule:

- do not store ID document image
- do not show ID document image in operational UI
- do not include ID image in support view
- do not export ID image
- do not send ID image to KDS or payment flow

If legally required later, separate policy must define storage, encryption, access, retention, deletion, and audit.

---

## 21. Provider Raw Payload Rule

Provider raw payload may contain sensitive identity data.

Default rule:

- do not display raw payload
- do not log raw payload
- do not export raw payload
- do not attach raw payload to support case
- do not send raw payload to KDS/POS/payment UI

If raw payload must be retained for legal/security reason, it must be isolated and access-controlled.

---

## 22. Log Masking Rule

Logs must avoid:

- raw CI/DI
- ID document number
- full birthdate
- full name if not necessary
- phone number if not necessary
- provider raw payload
- token
- verification secret
- webhook secret
- identity provider credential

Logs may include:

- safe verification status
- safe reason category
- provider reference alias
- order/session safe reference
- timestamp
- error category

Logs are not evidence vaults.

---

## 23. Audit Event Rule

Audit events should record:

- verification status transition
- manual confirmation
- verification failure
- verification uncertainty
- service refusal review
- unmask request
- support access
- export attempt
- evidence packet creation
- leakage incident if any

Audit event must be masked.

Audit event should not carry raw identity payload.

---

## 24. Export Restriction Rule

Identity verification data export is prohibited by default.

Export may be considered only when:

- legal purpose exists
- approval exists
- scope is minimal
- masking/redaction is applied
- recipient is authorized
- retention is defined
- audit is created
- raw identity is excluded unless explicitly approved

Dashboard export must not include verification raw data.

---

## 25. Retention Placeholder

Retention must later define:

- what is retained
- how long it is retained
- what is deleted
- what is anonymized
- what is masked
- what legal hold applies
- what customer request process applies
- what audit evidence remains

This document does not define final retention duration.

It requires retention policy before implementation.

---

## 26. Verification Evidence Packet Fields

Recommended verification evidence packet fields:

- evidence packet id
- alcohol order safe reference
- table/session reference
- verification required flag
- verification status
- verification method category
- verification timestamp
- provider reference alias
- failure category if any
- uncertainty category if any
- manual staff confirmation reference
- service refusal link if any
- payment link if any
- KDS hold/release link if any
- support case link if any
- masking status
- retention category placeholder
- reviewer
- notes

Evidence packet should remain minimal.

---

## 27. Evidence Packet ID Format

Recommended format:

    ALCOHOL-VERIFY-EVIDENCE-[YYYYMMDD]-[NUMBER]

Example:

    ALCOHOL-VERIFY-EVIDENCE-20260612-001

Final format may be normalized later.

---

## 28. Verification Privacy Status Values

Recommended privacy status values:

- `PRIVACY_STATUS_NOT_REVIEWED`
- `PRIVACY_STATUS_MINIMIZED`
- `PRIVACY_STATUS_MASKED`
- `PRIVACY_STATUS_RESTRICTED`
- `PRIVACY_STATUS_UNMASK_REQUESTED`
- `PRIVACY_STATUS_UNMASK_APPROVED`
- `PRIVACY_STATUS_EXPORT_BLOCKED`
- `PRIVACY_STATUS_RETENTION_REVIEW_REQUIRED`
- `PRIVACY_STATUS_LEAKAGE_SUSPECTED`
- `PRIVACY_STATUS_LEAKAGE_CONFIRMED`

Privacy status must be visible to security review.

---

## 29. Unmask Request Fields

Unmask request should include:

- request id
- requester
- role
- reason
- field requested
- scope
- customer/order/session reference
- approval owner
- time limit
- decision
- audit reference
- outcome

Unmask request must not expose raw data in request title or list.

---

## 30. Unmask Request ID Format

Recommended format:

    IDENTITY-UNMASK-[YYYYMMDD]-[NUMBER]

Example:

    IDENTITY-UNMASK-20260612-001

Final format may be normalized later.

---

## 31. Leakage Risk Examples

Leakage may occur when:

- raw CI/DI appears in admin table
- ID document image is attached to support case
- provider payload is logged
- KDS receives customer identity
- payment screen shows verification detail
- export includes identity fields
- support screenshot captures unmasked data
- error message includes provider identity payload
- dashboard card shows sensitive count with identifiable context
- staff note includes ID number

Leakage prevention must be designed before implementation.

---

## 32. Leakage Response Boundary

If leakage is suspected:

- stop further exposure
- preserve evidence
- restrict access
- notify security owner
- identify affected records
- identify exposure surface
- remove exposed data where policy allows
- create incident
- review logs/export/support attachments
- update masking rule
- legal/privacy review may be required

This document does not define final legal notification requirements.

---

## 33. Identity Data Surface Map

Identity data must be mapped across surfaces:

| Surface | Allowed Identity Detail |
| ------- | ----------------------- |
| Customer UI | verification status only |
| Staff UI | safe verification status and next action |
| KDS | hold/release status only |
| Payment | verification dependency status only |
| Support | masked status and safe category |
| Admin Dashboard | aggregated/masked counts |
| Admin Detail | field-level masked evidence |
| Audit | masked transition and access record |
| Export | blocked by default |
| Logs | safe status and error category only |

Surface map prevents accidental leakage.

---

## 34. Provider Integration Boundary

Identity verification provider integration must later ensure:

- secrets are protected
- payload is minimized
- callbacks are validated
- raw payload is not logged
- provider reference is abstracted
- verification result is mapped safely
- failure/uncertainty categories are normalized
- provider outage creates uncertainty, not pass
- evidence packet is minimized

Provider integration is not authorized by this document.

---

## 35. Security Review Trigger

Security review is required when:

- raw identity data may be stored
- raw CI/DI is involved
- ID image capture is proposed
- export is proposed
- support unmask is proposed
- provider raw payload retention is proposed
- logs may include identity data
- new Admin Console identity view is proposed
- delivery alcohol verification is proposed
- legal retention is unclear

Identity features require security review before build.

---

## 36. Legal Privacy Handoff

Legal/privacy review must later confirm:

- consent requirement
- privacy notice wording
- identity provider contract
- data retention
- data deletion
- customer rights handling
- adult verification evidence sufficiency
- manual verification evidence
- ID image prohibition or allowance
- export/legal request handling
- incident notification requirements

This document does not make legal conclusion.

---

## 37. Implementation Deferral Boundary

This document does not authorize:

- CI/DI collection
- ID document image storage
- identity provider integration
- adult verification API use
- Admin Console identity screen
- support unmask workflow
- identity export
- ID verification log storage
- delivery alcohol verification
- raw identity evidence retention

Implementation requires separate legal, security, and build authorization.

---

## 38. Registers Recommendation

Recommended future files:

    docs/_index/
      Alcohol_Verification_Evidence_Register.md
      Identity_Data_Category_Register.md
      CI_DI_Privacy_Register.md
      Verification_Privacy_Status_Register.md
      Identity_Unmask_Request_Register.md
      Identity_Leakage_Incident_Register.md
      Alcohol_Verification_Surface_Map.md
      Identity_Data_Retention_Placeholder_Register.md

This document only recommends these files.

It does not create them.

---

## 39. Anti-Patterns

The following are prohibited:

- storing raw CI/DI because it is convenient
- showing raw CI/DI in staff UI
- showing identity detail in KDS
- logging provider raw identity payload
- attaching ID image to support case
- exporting verification identity data by default
- using full birthdate as order label
- treating provider payload as safe evidence
- allowing unmask without reason and audit
- showing sensitive identity field in list table
- making ID document image visible to normal admin
- treating verification failure as customer blame
- letting identity data leak through error message
- collecting identity data before retention rule exists

---

## 40. Non-Goals

This document does not define:

- final CI/DI implementation
- final identity provider
- final encryption design
- final database schema
- final privacy notice
- final consent flow
- final legal retention duration
- final unmask workflow implementation
- final export implementation
- final leakage notification procedure

Those belong to later legal, privacy, security, and implementation planning.

---

## 41. Readiness Check

This document is ready when the project can answer:

1. What does identity privacy boundary mean?
2. What identity data categories exist?
3. What CI/DI boundary applies?
4. What does adult verification evidence mean?
5. What evidence categories exist?
6. What data minimization rule applies?
7. What verification result abstraction rule applies?
8. What failure reason categories exist?
9. What uncertainty reason categories exist?
10. What staff-facing identity rule applies?
11. What KDS identity rule applies?
12. What payment identity rule applies?
13. What support visibility rule applies?
14. What Admin Console visibility rule applies?
15. What customer-facing identity rule applies?
16. What manual verification evidence rule applies?
17. What ID document image rule applies?
18. What provider raw payload rule applies?
19. What log masking rule applies?
20. What audit event rule applies?
21. What export restriction rule applies?
22. What retention placeholder is needed?
23. What fields should verification evidence packet include?
24. What privacy status values exist?
25. What unmask request fields are needed?
26. What leakage risks exist?
27. What leakage response boundary applies?
28. What identity data surface map applies?
29. What provider integration boundary applies?
30. When is security review triggered?
31. What legal privacy handoff is required?
32. What implementation deferral boundary applies?
33. What anti-patterns are prohibited?

If these questions cannot be answered, alcohol order identity privacy, CI/DI, and verification evidence planning is incomplete.

---

## 42. Conclusion

Adult verification requires proof without unnecessary identity exposure.

The safe identity privacy flow is:

    alcohol verification required
        -> minimal identity check
        -> abstracted verification result
        -> masked evidence packet
        -> staff/KDS/payment/support surface minimization
        -> audit without raw identity
        -> export blocked by default
        -> retention and legal review before implementation

This document ensures that alcohol-related adult verification does not leak raw CI/DI, ID document data, provider payloads, or sensitive identity information into operational UI, KDS, support, logs, exports, or Admin Console surfaces.
