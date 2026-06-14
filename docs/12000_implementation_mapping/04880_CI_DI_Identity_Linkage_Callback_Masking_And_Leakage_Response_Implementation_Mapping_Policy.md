04880 CI DI Identity Linkage Callback Masking And Leakage Response Implementation Mapping Policy

\#\# 1\. Purpose

This document defines the implementation mapping policy for CI / DI identity linkage, identity provider callback handling, masking, account linkage, leakage prevention, audit evidence, and leakage response in the Yoonsul Wait/Order Handoff project.

CI / DI and verified identity linkage data are highly sensitive.

They may be needed for identity verification, account linkage, duplicate account handling, membership continuity, fraud prevention, or legal compliance, but they must not become ordinary operational data.

Therefore, CI / DI handling must be mapped before implementation.

This document does not implement identity provider integration, callback handlers, database schema, RLS policies, masking functions, or leakage response automation.

It defines the constraints that future identity implementation must obey.

\---

\#\# 2\. Scope

This mapping applies to:

\- CI / DI handling
\- identity provider callback
\- verified identity linkage
\- customer account linkage
\- membership identity linkage
\- customer duplicate resolution
\- phone/email verification linkage
\- identity masking
\- support identity visibility
\- account merge candidate handling
\- identity correction request
\- identity correction approval
\- identity leakage detection
\- identity leakage incident response
\- identity audit mapping
\- identity evidence mapping
\- identity export restriction
\- AI dataset exclusion
\- tenant/store scoped identity visibility
\- testing requirements
\- implementation blockers

This document does not define final provider, schema, or implementation code.

\---

\#\# 3\. Core Principle

CI / DI is not operational display data.

The project must follow this rule:

\> CI / DI may be used for verified identity linkage, but it must not be exposed to staff, kitchen, support browsing, analytics, AI datasets, logs, exports, or customer-facing screens by default.

Identity linkage must be purpose-bound, masked, audited, and minimized.

\---

\#\# 4\. Related Policy Documents

This mapping depends on:

\- 04470 Financial Grade Security Baseline And Secret Coding Policy
\- 04500 Secret Rotation Exposure Response And Secure Configuration Policy
\- 04510 CI DI Identity Linkage Data Protection And Leakage Response Policy
\- 04520 Support Access Masking Break Glass And Scoped Session Policy
\- 04530 Security Audit Event Immutability And Tamper Evidence Policy
\- 04540 Device Trust Session Revocation And Store Runtime Access Policy
\- 04560 Tenant Store Boundary Isolation And Cross Context Access Policy
\- 04580 Log Masking Error Disclosure And Diagnostic Data Policy
\- 04600 Data Export Report Benchmark And External Sharing Security Policy
\- 04610 AI Analytics Dataset Minimization And Model Output Security Policy
\- 04620 Security Incident Response Severity Classification And Recovery Governance Policy
\- 04630 Compliance Readiness Evidence Control And Financial Grade Security Review Policy
\- 04660 Security Testing Abuse Case Threat Modeling And Verification Policy
\- 04830 Implementation Mapping Lane Start And Policy To Code Constraint Handoff Policy
\- 04840 Tenant Store Context RLS And Access Control Implementation Mapping Policy
\- 04850 Audit Event Taxonomy Append Only And Evidence Implementation Mapping Policy

Future identity implementation must inherit these constraints.

\---

\#\# 5\. Affected Runtime

This mapping affects:

\- Customer Web Runtime
\- Customer Mobile Runtime
\- Identity Runtime
\- Membership Runtime
\- Support Runtime
\- HQ Admin Runtime
\- Audit Runtime
\- Export Runtime
\- AI Analytics Runtime
\- Incident Runtime
\- Vendor Integration Runtime
\- Deployment Runtime

CI / DI handling primarily belongs to Identity Runtime.

Other runtimes may receive only derived, masked, or purpose-limited identity status.

\---

\#\# 6\. Sensitive Identity Data Definition

Sensitive identity data includes:

\- CI
\- DI
\- identity provider reference
\- verified identity provider transaction id
\- identity callback payload
\- account linkage key
\- duplicate identity resolution key
\- full verified phone number
\- full verified email where sensitive
\- legal identity verification reference
\- birth date where used for verification
\- name where tied to verified identity
\- identity proof result
\- identity correction record
\- identity leakage evidence

These fields require stronger protection than ordinary customer profile data.

\---

\#\# 7\. Identity Linkage Purpose Mapping

CI / DI may be used only for defined purposes.

Allowed purposes may include:

\- verified account creation
\- duplicate account detection
\- account recovery
\- membership continuity
\- legal identity verification where required
\- fraud or abuse investigation where authorized
\- identity correction under approval
\- regulatory or legal response where required
\- customer-requested identity verification

Not allowed by default:

\- kitchen display
\- staff convenience lookup
\- general marketing segmentation
\- AI model training
\- casual support browsing
\- export for analysis
\- benchmark dataset
\- POS/KDS payload enrichment
\- logging and diagnostics

Purpose must be explicit.

\---

\#\# 8\. CI / DI Storage Mapping

If CI / DI must be stored, mapping must define:

\- whether raw value is stored
\- whether hashed or tokenized value is stored
\- whether encrypted field storage is required
\- whether provider reference can replace raw value
\- key management approach
\- access boundary
\- retention direction
\- deletion or unlinking behavior
\- audit requirement
\- export prohibition
\- support visibility rule

Raw CI / DI storage should be avoided where a safer reference is sufficient.

\---

\#\# 9\. Identity Provider Callback Boundary

Identity provider callback is an external integration boundary.

Callback Runtime must:

\- verify provider identity
\- verify callback signature or trusted mechanism
\- validate state parameter
\- validate nonce where applicable
\- validate session binding
\- validate timestamp freshness
\- validate callback idempotency
\- detect replay
\- map callback to expected customer/session
\- create audit event
\- store only minimized result
\- quarantine invalid callback

Provider callback is untrusted until verified.

\---

\#\# 10\. Identity Callback Required Context

Identity callback mapping should include:

\- tenant\_id where applicable
\- customer\_session\_id
\- customer\_account\_id where applicable
\- provider\_name
\- provider\_transaction\_id
\- callback\_event\_id
\- request\_id
\- correlation\_id
\- idempotency\_key
\- state parameter
\- nonce where applicable
\- callback\_received\_at
\- verification\_result
\- identity\_linkage\_status
\- audit\_event\_id
\- incident\_id where applicable

Callback must not be accepted without context binding.

\---

\#\# 11\. Callback Idempotency Mapping

Identity callback idempotency is required.

Duplicate callback must not create:

\- duplicate account
\- duplicate identity linkage
\- duplicate membership account
\- duplicate verified profile
\- duplicate identity correction
\- duplicate audit mutation
\- duplicate customer notification

Duplicate callback may be recorded as duplicate receipt where useful.

\---

\#\# 12\. Callback Replay Detection

Replay detection should consider:

\- callback event id already processed
\- provider transaction id already used
\- expired timestamp
\- invalid state
\- invalid nonce
\- customer session mismatch
\- account mismatch
\- tenant mismatch
\- identity linkage already final
\- repeated invalid callback attempt

Replay must not silently create or alter identity linkage.

Suspicious replay should create security audit or incident event.

\---

\#\# 13\. Account Linkage Mapping

Account linkage may connect:

\- customer account
\- verified identity reference
\- membership identity
\- phone verification
\- email verification
\- payment customer reference where allowed
\- store-specific membership usage
\- SaaS public service identity
\- tenant-specific benefit rules

Account linkage must not expose raw CI / DI to tenant/store runtime by default.

\---

\#\# 14\. Public Service Identity Versus Tenant Identity

The project may support public service identity and tenant/store-specific benefit rules.

Mapping must distinguish:

\- public customer account
\- tenant customer profile
\- store visit history
\- store benefit eligibility
\- tenant membership record
\- verified identity linkage
\- payment customer reference

A customer may participate in multiple tenant/store contexts.

CI / DI must not be used as a visible cross-tenant tracking key.

\---

\#\# 15\. Duplicate Account Candidate Mapping

Duplicate account detection may create candidate records.

Candidate record should include:

\- candidate\_id
\- account\_a reference
\- account\_b reference
\- linkage reason class
\- confidence class
\- masked identity evidence
\- created\_at
\- review\_required flag
\- customer consent status where applicable
\- support\_case\_id where applicable
\- audit\_event\_id
\- resolution\_status

Duplicate candidate must not automatically merge accounts without authority.

\---

\#\# 16\. Account Merge Authority Mapping

Account merge may require:

\- customer request
\- verified identity match
\- support case
\- approval where sensitive
\- audit event
\- evidence record
\- conflict review
\- rollback or correction path
\- customer notification where appropriate

AI may recommend merge candidate.

AI must not execute account merge.

Support must not merge accounts without required authority.

\---

\#\# 17\. Identity Correction Mapping

Identity correction may be required when:

\- wrong account linked
\- provider callback mismatch
\- phone ownership changed
\- customer disputes identity
\- duplicate account merge error
\- tenant/store benefit history linked incorrectly
\- identity leakage incident affects linkage

Correction must be append-only and auditable.

Original linkage history must remain traceable.

\---

\#\# 18\. Identity Masking Mapping

Identity masking must apply to:

\- CI
\- DI
\- provider transaction id
\- identity reference
\- full phone number
\- full email
\- legal name where sensitive
\- birth date
\- account linkage key
\- duplicate candidate evidence
\- support identity note
\- export fields
\- audit fields
\- logs

Default display should show masked or derived status only.

\---

\#\# 19\. Derived Identity Status Mapping

Most runtimes should receive derived status instead of raw identity.

Derived statuses may include:

\- \`IDENTITY\_NOT\_VERIFIED\`
\- \`IDENTITY\_VERIFICATION\_PENDING\`
\- \`IDENTITY\_VERIFIED\`
\- \`IDENTITY\_LINKED\`
\- \`IDENTITY\_LINKAGE\_REVIEW\_REQUIRED\`
\- \`IDENTITY\_DUPLICATE\_CANDIDATE\`
\- \`IDENTITY\_CORRECTION\_REQUIRED\`
\- \`IDENTITY\_PROVIDER\_UNCERTAIN\`
\- \`IDENTITY\_LEAKAGE\_REVIEW\_REQUIRED\`

Derived status can support workflow without exposing raw identity.

\---

\#\# 20\. Support Identity Visibility Mapping

Support access to identity data must be case-scoped.

Support may see:

\- masked customer reference
\- masked phone/email
\- identity verification status
\- duplicate candidate indicator
\- account linkage status
\- correction request status
\- customer-safe explanation
\- evidence packet reference

Support must not see raw CI / DI by default.

Unmasking or raw access requires exceptional authority, purpose, audit, and time-bound scope.

\---

\#\# 21\. HQ Identity Visibility Mapping

HQ identity visibility must be role-scoped.

HQ may need:

\- identity verification aggregate status
\- duplicate account review queue
\- identity incident review
\- compliance evidence
\- masked identity audit
\- correction approval queue

HQ must not automatically browse raw CI / DI.

Raw access, if ever allowed, must be exceptional, logged, and restricted.

\---

\#\# 22\. Store Staff Identity Visibility Mapping

Store staff should not see CI / DI.

Store staff may see only operationally necessary customer information, such as:

\- display name or nickname where allowed
\- masked phone last digits where needed
\- order pickup identifier
\- membership tier where allowed
\- reservation or waiting name where allowed
\- customer request note after filtering

Staff access must not expose verified legal identity unless explicitly required by business rule and policy.

\---

\#\# 23\. POS/KDS Identity Boundary

POS/KDS payloads must avoid raw identity linkage.

POS/KDS may receive:

\- order reference
\- masked pickup label
\- table/session reference
\- kitchen note after filtering
\- membership benefit flag where needed
\- payment status signal where allowed

POS/KDS must not receive:

\- raw CI
\- raw DI
\- identity provider callback data
\- identity linkage key
\- legal identity record
\- full account linkage graph

Kitchen execution does not require raw identity.

\---

\#\# 24\. Payment Identity Boundary

Payment may require provider customer reference, but payment identity must remain separate from CI / DI.

Mapping must define:

\- payment customer reference
\- verified identity reference
\- whether linkage is allowed
\- purpose of linkage
\- masking
\- audit
\- support visibility
\- export restriction
\- deletion or unlinking behavior

Payment reference must not become a general identity tracking key.

\---

\#\# 25\. Export Restriction Mapping

Identity export is high-risk.

Export must be prohibited by default for:

\- raw CI
\- raw DI
\- identity provider callback payload
\- account linkage key
\- duplicate identity evidence
\- full verified phone/email
\- legal identity verification reference

If export is legally required, it must require:

\- explicit approval
\- purpose
\- scope
\- masking where possible
\- audit
\- secure delivery
\- retention limit
\- incident review where applicable

\---

\#\# 26\. AI Dataset Exclusion Mapping

AI datasets must exclude:

\- raw CI
\- raw DI
\- identity provider callback payload
\- account linkage key
\- full phone/email
\- legal identity reference
\- identity correction evidence
\- support notes containing raw identity
\- unmasked duplicate candidate evidence

AI may use minimized, aggregated, or masked identity status only where approved.

AI must not infer or expose identity linkage.

\---

\#\# 27\. Log And Error Masking Mapping

Logs and errors must not include:

\- raw CI
\- raw DI
\- provider identity callback payload
\- full phone/email
\- raw name and birth date combination
\- account linkage secret
\- identity provider secret
\- callback signature secret
\- authorization header
\- session token

Errors should return safe messages.

Internal diagnostics should use masked references.

\---

\#\# 28\. Identity Leakage Definition

Identity leakage may include:

\- raw CI / DI in logs
\- raw CI / DI in export
\- raw CI / DI in support screen
\- raw CI / DI in AI dataset
\- raw CI / DI in prompt
\- raw identity callback payload stored broadly
\- identity provider secret exposure
\- cross-tenant identity linkage exposure
\- wrong account merge
\- unmasked phone/email exported unexpectedly
\- support unmask without audit

Identity leakage is a security incident candidate.

\---

\#\# 29\. Identity Leakage Response Mapping

Identity leakage response should define:

\- detection source
\- severity classification
\- containment action
\- affected data category
\- affected tenant/store scope
\- affected customer scope
\- audit preservation
\- evidence packet
\- access revocation where needed
\- secret rotation where needed
\- export revocation where needed
\- AI dataset purge where needed
\- customer/legal/regulatory review where needed
\- correction action
\- post-incident review

Leakage response must be evidence-driven.

\---

\#\# 30\. Identity Evidence Packet Mapping

Identity evidence packet may include:

\- identity linkage reference
\- provider transaction reference
\- callback verification result
\- masked customer reference
\- account linkage state
\- duplicate candidate summary
\- support case reference
\- correction request reference
\- audit event references
\- leakage detection evidence
\- containment action
\- review status

Evidence packet must not store raw CI / DI unless strictly required and specially protected.

\---

\#\# 31\. Audit Mapping

Identity audit events should include:

\- identity verification started
\- identity provider callback received
\- callback verified
\- callback rejected
\- callback replay detected
\- identity linkage created
\- identity linkage denied
\- duplicate candidate created
\- account merge requested
\- account merge approved
\- account merge completed
\- account merge denied
\- identity correction requested
\- identity correction approved
\- identity correction completed
\- identity access denied
\- identity unmask requested
\- identity unmask approved
\- identity leakage suspected
\- identity leakage confirmed
\- identity containment completed

Audit must not store raw CI / DI by default.

\---

\#\# 32\. Access Control Mapping

Access control must enforce:

\- customer self-scope
\- tenant/store scope where operational data is involved
\- support case scope
\- HQ role scope
\- unmask approval scope
\- export authority
\- AI dataset approval
\- incident response scope
\- audit read scope
\- service identity scope

Identity data must not be protected only by frontend hiding.

\---

\#\# 33\. Retention And Deletion Direction

Mapping must define retention direction for:

\- raw identity value if stored
\- provider callback payload
\- provider transaction id
\- identity linkage record
\- duplicate candidate record
\- account merge record
\- identity correction record
\- identity leakage evidence
\- audit event
\- support case identity note

Deletion or unlinking must preserve required audit and legal traceability while minimizing unnecessary sensitive data.

\---

\#\# 34\. Customer Request Mapping

Customer may request:

\- identity verification
\- account recovery
\- account merge review
\- phone/email correction
\- identity unlinking where allowed
\- data access request where supported
\- deletion request where legally allowed

Customer request must be verified before sensitive identity change.

Support must not act on unverified request for identity-sensitive action.

\---

\#\# 35\. Degraded Identity Handling

During degraded mode:

\- identity verification should generally pause or remain pending
\- raw CI / DI should not be cached locally
\- identity callback should not be processed by untrusted local agent
\- account merge should not proceed
\- identity correction should not finalize
\- support unmask should not bypass central controls
\- identity uncertainty should be marked
\- audit/evidence must record delayed verification

Degraded mode is not identity authority bypass.

\---

\#\# 36\. Vendor Identity Provider Mapping

Identity provider integration must define:

\- provider risk classification
\- provider credential storage
\- callback verification
\- callback endpoint protection
\- provider event id mapping
\- data retention
\- failure behavior
\- incident notification
\- contract or compliance requirements
\- secret rotation
\- test environment separation
\- production credential access restriction

Vendor identity provider must be treated as high-risk.

\---

\#\# 37\. Testing Requirements

Future tests must include:

\- identity callback without valid state is rejected
\- identity callback without valid nonce is rejected where applicable
\- duplicate callback does not duplicate linkage
\- replay callback is rejected or quarantined
\- wrong customer session callback is rejected
\- raw CI / DI is not visible to store staff
\- raw CI / DI is not visible to ordinary support
\- support unmask requires case scope and audit
\- raw CI / DI is excluded from logs
\- raw CI / DI is excluded from export
\- raw CI / DI is excluded from AI dataset
\- POS/KDS payload excludes raw identity
\- account merge cannot occur without authority
\- identity correction is append-only
\- identity leakage creates incident path
\- degraded mode cannot finalize identity linkage locally

Testing must include abuse cases.

\---

\#\# 38\. Evidence Requirements

Evidence must prove:

\- CI / DI handling is minimized
\- identity callback validation exists
\- callback idempotency exists
\- callback replay detection exists
\- identity data masking exists
\- support access is case-scoped
\- unmasking is audited
\- export restriction exists
\- AI dataset exclusion exists
\- POS/KDS identity exclusion exists
\- account merge requires authority
\- identity correction is append-only
\- leakage incident response path exists
\- logs do not expose raw identity
\- degraded mode does not bypass identity controls

Evidence must not leak the identity data it is proving to protect.

\---

\#\# 39\. Implementation Blockers

Implementation must be blocked if:

\- CI / DI storage approach is undefined
\- identity callback validation is undefined
\- callback idempotency is undefined
\- callback replay detection is undefined
\- account linkage authority is unclear
\- duplicate account handling is unclear
\- account merge authority is unclear
\- support identity visibility is undefined
\- raw CI / DI can appear in POS/KDS payload
\- raw CI / DI can appear in logs
\- raw CI / DI can appear in exports
\- raw CI / DI can enter AI datasets
\- unmasking lacks audit
\- identity leakage response is undefined
\- retention direction is undefined
\- tests are missing

These blockers must be added to the implementation blocker register.

\---

\#\# 40\. Mapping Status

Recommended status for this mapping:

\- \`DRAFT\`
\- \`POLICY\_LINKED\`
\- \`RUNTIME\_DEFINED\`
\- \`DATA\_CLASSIFIED\`
\- \`CALLBACK\_MAPPED\`
\- \`IDEMPOTENCY\_MAPPED\`
\- \`REPLAY\_MAPPED\`
\- \`MASKING\_MAPPED\`
\- \`ACCESS\_MAPPED\`
\- \`AUDIT\_MAPPED\`
\- \`LEAKAGE\_RESPONSE\_MAPPED\`
\- \`TEST\_MAPPED\`
\- \`BLOCKED\`
\- \`READY\_FOR\_REVIEW\`
\- \`READY\_FOR\_IMPLEMENTATION\`

This document starts as \`DRAFT\`.

It becomes implementation-ready only after final provider selection, schema mapping, callback mapping, masking design, RLS mapping, and test catalogs are completed.

\---

\#\# 41\. Non-Goals

This document does not define:

\- final identity provider
\- final CI / DI storage mechanism
\- final callback handler
\- final database schema
\- final encryption implementation
\- final RLS policy
\- final masking function
\- final account merge algorithm
\- final support UI
\- final customer identity UI
\- final AI dataset pipeline
\- final automated leakage scanner
\- final production deployment

Those belong to later controlled implementation phase.

\---

\#\# 42\. Readiness Check

This mapping is ready when the project can answer:

1\. What counts as sensitive identity data?
2\. What purposes may use CI / DI?
3\. What purposes are prohibited by default?
4\. How is CI / DI stored or avoided?
5\. How is identity provider callback verified?
6\. What context is required for callback?
7\. How is callback idempotency handled?
8\. How is callback replay detected?
9\. How is account linkage mapped?
10\. How is public service identity separated from tenant identity?
11\. How are duplicate account candidates handled?
12\. Who may approve account merge?
13\. How is identity correction handled?
14\. What fields are masked?
15\. What derived identity statuses exist?
16\. What can support see?
17\. What can HQ see?
18\. What can store staff see?
19\. What must POS/KDS not receive?
20\. How is payment identity separated?
21\. How is identity export restricted?
22\. How is identity excluded from AI datasets?
23\. How are logs and errors masked?
24\. What is identity leakage?
25\. How is leakage response handled?
26\. What evidence packet is created?
27\. What audit events are required?
28\. How is access controlled?
29\. How is retention handled?
30\. What customer requests are supported?
31\. What changes during degraded mode?
32\. How is identity provider vendor risk mapped?
33\. What tests prove identity safety?
34\. What evidence proves protection?
35\. What blocks implementation?

If these questions cannot be answered, CI / DI identity implementation mapping is incomplete.

\---

\#\# 43\. Conclusion

CI / DI and verified identity linkage are among the most sensitive data categories in the Yoonsul Wait/Order Handoff project.

The system must preserve the following rules:

\- CI / DI is not operational display data
\- identity linkage must be purpose-bound
\- raw CI / DI storage should be avoided where possible
\- identity provider callback is untrusted until verified
\- callback idempotency is required
\- callback replay must be detected
\- account linkage must not expose raw identity
\- duplicate account candidates must not auto-merge
\- account merge requires authority and audit
\- identity correction must be append-only
\- support access must be case-scoped and masked
\- store staff must not see raw CI / DI
\- POS/KDS must not receive raw identity linkage
\- payment identity must remain separately governed
\- export of identity data is prohibited by default
\- AI datasets must exclude raw identity
\- logs and errors must mask identity
\- leakage response must be evidence-driven
\- degraded mode is not identity authority bypass
\- vendor identity provider must be treated as high-risk
\- implementation is blocked until callback, masking, access, audit, leakage response, and tests are mapped

This mapping does not implement identity runtime.

It defines the constraints that future CI / DI and identity linkage implementation must obey.
