04930 AI Analytics Dataset Minimization Model Output And Recommendation Boundary Implementation Mapping Policy

\#\# 1\. Purpose

This document defines the implementation mapping policy for AI analytics, dataset minimization, model input restriction, model output control, recommendation boundary, prompt safety, leakage prevention, audit evidence, and AI incident response in the Yoonsul Wait/Order Handoff project.

AI may support store operations, delay prediction, POS/KDS mismatch detection, support summarization, degraded recovery review, menu analytics, and operational insight.

However, AI must not become hidden authority, uncontrolled data export, raw identity processor, payment executor, or security bypass.

Therefore, AI analytics implementation must be mapped before implementation.

This document does not implement AI pipelines, model calls, dataset builders, embedding systems, vector databases, prompt templates, or model output automation.

It defines the constraints that future AI implementation must obey.

\---

\#\# 2\. Scope

This mapping applies to:

\- AI analytics dataset extraction
\- AI input minimization
\- AI prompt construction
\- AI model output handling
\- recommendation boundary
\- delay prediction
\- POS/KDS mismatch analysis
\- support case summarization
\- degraded recovery summarization
\- payment issue classification
\- refund recommendation boundary
\- menu and operations analytics
\- customer flow analytics
\- export-to-AI boundary
\- AI dataset masking
\- AI output leakage prevention
\- AI audit mapping
\- AI evidence packet
\- AI incident response
\- testing requirements
\- implementation blockers

This document does not define final AI provider, model, architecture, or code.

\---

\#\# 3\. Core Principle

AI may recommend, summarize, classify, and predict, but it must not execute authority.

The project must follow this rule:

\> AI output is not operational truth, payment truth, identity truth, refund approval, recovery approval, legal conclusion, audit closure, or final human decision.

AI may support decisions.

AI must not silently make controlled decisions.

\---

\#\# 4\. Related Policy Documents

This mapping depends on:

\- 04470 Financial Grade Security Baseline And Secret Coding Policy
\- 04490 Degraded Security Recovery And Evidence Boundary Policy
\- 04510 CI DI Identity Linkage Data Protection And Leakage Response Policy
\- 04520 Support Access Masking Break Glass And Scoped Session Policy
\- 04530 Security Audit Event Immutability And Tamper Evidence Policy
\- 04550 Payment Boundary Refund Correction And Settlement Security Policy
\- 04560 Tenant Store Boundary Isolation And Cross Context Access Policy
\- 04580 Log Masking Error Disclosure And Diagnostic Data Policy
\- 04600 Data Export Report Benchmark And External Sharing Security Policy
\- 04610 AI Analytics Dataset Minimization And Model Output Security Policy
\- 04620 Security Incident Response Severity Classification And Recovery Governance Policy
\- 04630 Compliance Readiness Evidence Control And Financial Grade Security Review Policy
\- 04660 Security Testing Abuse Case Threat Modeling And Verification Policy
\- 04690 Vendor Partner Access Third Party Risk And Integration Review Policy
\- 04830 Implementation Mapping Lane Start And Policy To Code Constraint Handoff Policy
\- 04840 Tenant Store Context RLS And Access Control Implementation Mapping Policy
\- 04850 Audit Event Taxonomy Append Only And Evidence Implementation Mapping Policy
\- 04870 Payment Webhook Refund Settlement And Reconciliation Implementation Mapping Policy
\- 04880 CI DI Identity Linkage Callback Masking And Leakage Response Implementation Mapping Policy
\- 04890 Support Access Masking Break Glass And Scoped Session Implementation Mapping Policy
\- 04910 Local Agent Degraded Recovery Sync Conflict And Manual Evidence Implementation Mapping Policy
\- 04920 Export Report Benchmark External Sharing And Data Extraction Implementation Mapping Policy

Future AI implementation must inherit these constraints.

\---

\#\# 5\. Affected Runtime

This mapping affects:

\- AI Analytics Runtime
\- Support Runtime
\- Store Tablet Runtime
\- Owner Runtime
\- HQ Admin Runtime
\- POS/KDS Bridge Runtime
\- Local Agent Runtime
\- Export Runtime
\- Incident Runtime
\- Audit Runtime
\- Customer Runtime where AI output is customer-facing
\- Staff Runtime where AI recommendation is shown

AI Analytics Runtime must remain recommendation and analysis layer unless explicitly mapped otherwise.

\---

\#\# 6\. AI Use Case Mapping

Allowed AI use cases may include:

\- delay risk prediction
\- kitchen bottleneck classification
\- POS/KDS mismatch summarization
\- degraded recovery summary
\- support case summary
\- customer-safe response draft
\- refund policy candidate suggestion
\- menu demand analysis
\- inventory risk signal
\- store performance anomaly detection
\- export risk classification
\- incident evidence summary
\- training content suggestion
\- operational checklist suggestion

Each use case must define input, output, authority boundary, masking, audit, and review requirement.

\---

\#\# 7\. Prohibited AI Authority

AI must not:

\- confirm payment
\- approve refund
\- submit refund
\- release settlement
\- approve support unmasking
\- approve break-glass
\- merge customer accounts
\- correct CI / DI linkage
\- mutate POS truth
\- mutate KDS truth
\- approve degraded recovery
\- close incident
\- delete audit
\- grant role
\- revoke device as final authority
\- approve export
\- generate legal conclusion
\- make final compliance decision
\- silently message customer in sensitive cases

AI may recommend these actions for human or system-authorized review.

\---

\#\# 8\. AI Dataset Definition

An AI dataset is any data package, prompt context, embedding corpus, retrieved context, feature table, event sequence, or analytics extract used by an AI model or AI pipeline.

AI dataset may include:

\- operational events
\- POS/KDS events
\- delay metrics
\- support case summaries
\- degraded recovery evidence summaries
\- payment status classes
\- menu performance aggregates
\- customer flow aggregates
\- incident summaries
\- training material
\- masked audit summaries

AI dataset must be treated as export-like extraction.

\---

\#\# 9\. AI Dataset Classification

Recommended AI dataset classes:

\- \`PUBLIC\_AI\_CONTEXT\`
\- \`LOW\_RISK\_AGGREGATE\`
\- \`STORE\_OPERATIONAL\_SUMMARY\`
\- \`TENANT\_OPERATIONAL\_SUMMARY\`
\- \`SUPPORT\_CASE\_SUMMARY\`
\- \`PAYMENT\_STATUS\_CLASS\_ONLY\`
\- \`DEGRADED\_RECOVERY\_SUMMARY\`
\- \`AUDIT\_SUMMARY\`
\- \`INCIDENT\_SUMMARY\`
\- \`SENSITIVE\_RESTRICTED\_AI\_DATASET\`
\- \`PROHIBITED\_AI\_DATASET\`

Dataset class determines approval, masking, retention, and model usage boundary.

\---

\#\# 10\. Prohibited AI Inputs

AI datasets and prompts must exclude by default:

\- raw CI
\- raw DI
\- identity provider callback payload
\- service role key
\- API secret
\- webhook secret
\- database password
\- payment token
\- card data
\- raw authorization header
\- production \`.env\`
\- raw provider payload
\- unrestricted support notes
\- unrestricted audit logs
\- full customer phone/email
\- account linkage key
\- private key
\- local agent credential
\- bridge credential

AI must not become a secret or identity processing sink.

\---

\#\# 11\. Restricted AI Inputs

Restricted inputs may require approval, masking, and specific purpose.

Restricted inputs include:

\- support case summary
\- payment status class
\- refund status class
\- incident summary
\- degraded recovery summary
\- masked audit summary
\- masked customer communication
\- store-level operational details
\- staff operational notes
\- device trust summary
\- export request summary

Restricted inputs should be minimized before model use.

\---

\#\# 12\. AI Input Minimization Mapping

AI input minimization should define:

\- purpose
\- use case
\- required fields
\- excluded fields
\- masking transformation
\- aggregation level
\- time window
\- tenant/store scope
\- retention direction
\- prompt visibility
\- model provider
\- audit event
\- approval where needed

AI should receive the least data necessary to perform the defined task.

\---

\#\# 13\. AI Prompt Construction Mapping

Prompt construction should avoid:

\- secrets
\- raw identity
\- raw payment payload
\- raw provider payload
\- raw audit logs
\- unrelated tenant data
\- unrelated store data
\- unnecessary customer detail
\- unrestricted support notes
\- hidden authority instruction

Prompt should include:

\- task
\- scope
\- allowed output
\- prohibited output
\- uncertainty requirement
\- recommendation-only boundary
\- masking reminder
\- escalation condition where applicable

Prompt itself is a data exposure surface.

\---

\#\# 14\. AI Output Classification

AI outputs should be classified.

Recommended output classes:

\- \`SUMMARY\`
\- \`CLASSIFICATION\`
\- \`PREDICTION\`
\- \`RECOMMENDATION\`
\- \`DRAFT\_RESPONSE\`
\- \`RISK\_SIGNAL\`
\- \`ANOMALY\_SIGNAL\`
\- \`EVIDENCE\_SUMMARY\`
\- \`ESCALATION\_SUGGESTION\`
\- \`BLOCKED\_OUTPUT\`
\- \`UNSAFE\_OUTPUT\`

Output class determines whether human review, audit, or approval is required.

\---

\#\# 15\. Recommendation Boundary Mapping

AI recommendation must be labeled as recommendation.

AI recommendation should include:

\- confidence or uncertainty where possible
\- supporting evidence references
\- missing data warning
\- suggested next action
\- required human/system authority
\- prohibited automatic execution
\- escalation path where needed

Recommendation must not be stored as final decision unless accepted by authorized actor or controlled workflow.

\---

\#\# 16\. AI Delay Prediction Mapping

AI may predict delay risk.

Input may include:

\- ticket age
\- kitchen queue length
\- menu preparation class
\- historical aggregate timing
\- current KDS state
\- staffing signal where allowed
\- degraded marker
\- inventory delay flag where allowed

Output may include:

\- low/medium/high delay risk
\- estimated delay class
\- recommended staff attention
\- customer-safe delay message draft

AI delay prediction must not become final promise without operational review.

\---

\#\# 17\. POS/KDS Mismatch AI Mapping

AI may summarize POS/KDS mismatch.

Input may include:

\- POS event summary
\- KDS event summary
\- bridge retry summary
\- mismatch type
\- replay status
\- degraded marker
\- evidence packet summary

Output may include:

\- mismatch explanation
\- likely cause category
\- recommended review path
\- missing evidence list

AI must not overwrite POS or KDS truth.

\---

\#\# 18\. Degraded Recovery AI Mapping

AI may assist degraded recovery by summarizing:

\- local agent status
\- fallback-originated records
\- sync conflicts
\- cache uncertainty
\- replay output
\- reconciliation candidates
\- manual evidence completeness
\- customer impact

AI may recommend:

\- review required
\- evidence missing
\- escalation candidate
\- possible customer message

AI must not approve recovery or merge records.

\---

\#\# 19\. Support AI Mapping

AI may support support agents by:

\- summarizing case
\- drafting customer-safe response
\- classifying issue type
\- identifying missing evidence
\- suggesting escalation
\- identifying refund policy candidate
\- summarizing POS/KDS mismatch
\- summarizing degraded recovery state

AI must not:

\- unmask data
\- approve refund
\- approve account merge
\- approve break-glass
\- close support case as final authority
\- send sensitive customer response without review
\- access raw CI / DI or payment secrets

Support AI must follow support scope.

\---

\#\# 20\. Payment AI Mapping

AI may classify payment issue type.

Allowed AI input should be limited to:

\- payment status class
\- refund status class
\- reconciliation status
\- masked payment reference
\- customer-safe failure category
\- support case summary
\- evidence summary

AI must not receive:

\- payment token
\- card data
\- provider secret
\- webhook secret
\- raw provider payload
\- raw CI / DI

AI must not confirm payment, approve refund, or submit refund.

\---

\#\# 21\. Identity AI Mapping

AI must be highly restricted around identity.

AI may use only masked or derived identity status where approved.

AI must not receive:

\- raw CI
\- raw DI
\- identity provider callback payload
\- account linkage key
\- full verified phone/email
\- legal identity reference
\- unmasked duplicate candidate evidence

AI must not approve account merge, identity correction, or unmasking.

\---

\#\# 22\. Export AI Mapping

AI may classify export risk or summarize export request.

AI may help identify:

\- sensitivity class
\- missing purpose
\- missing approval
\- masking requirement
\- possible prohibited fields
\- benchmark risk
\- AI dataset risk

AI must not approve export.

AI must not generate export file.

AI must not bypass export authority.

\---

\#\# 23\. Incident AI Mapping

AI may assist incident response by:

\- summarizing timeline
\- grouping evidence
\- identifying missing containment action
\- drafting internal summary
\- suggesting severity candidate
\- listing affected systems
\- listing open questions

AI must not:

\- assign final legal/regulatory conclusion
\- close incident
\- delete evidence
\- notify external party without review
\- expose secrets or raw identity
\- override incident commander

Incident AI is assistant, not commander.

\---

\#\# 24\. Customer-Facing AI Output Mapping

Customer-facing AI output is high-risk.

Customer-facing AI output must be reviewed or constrained when it involves:

\- payment
\- refund
\- identity
\- delay compensation
\- incident
\- degraded recovery
\- legal/compliance explanation
\- complaint escalation
\- account merge
\- sensitive support issue

Customer-facing output must be safe, truthful, and not overpromise.

AI should not invent status.

\---

\#\# 25\. Staff-Facing AI Output Mapping

Staff-facing AI may provide:

\- queue risk
\- delay warning
\- checklist suggestion
\- mismatch review suggestion
\- degraded recovery instruction draft
\- manual evidence reminder

Staff-facing AI must clearly distinguish:

\- verified fact
\- prediction
\- recommendation
\- missing evidence
\- required approval

Staff should not treat AI output as authority override.

\---

\#\# 26\. Owner-Facing AI Output Mapping

Owner-facing AI may provide:

\- aggregate store insights
\- operational risk summary
\- settlement issue summary
\- degraded impact summary
\- customer flow trend
\- support trend summary

Owner-facing AI must avoid exposing:

\- raw identity
\- payment secrets
\- unrestricted support notes
\- unrelated tenant/store data
\- internal security diagnostics

Owner-facing AI should be based on scoped and masked data.

\---

\#\# 27\. HQ-Facing AI Output Mapping

HQ-facing AI may support:

\- multi-store aggregate analysis
\- incident trend analysis
\- vendor risk summary
\- support backlog classification
\- operational anomaly detection
\- readiness dashboard assistance
\- training content suggestion

HQ-facing AI must still respect role, purpose, scope, and masking.

HQ access does not justify unrestricted AI input.

\---

\#\# 28\. AI Output Leakage Mapping

AI output leakage may include:

\- revealing raw identity
\- revealing payment secret
\- revealing provider payload
\- revealing another tenant/store data
\- revealing support confidential note
\- revealing internal security detail
\- hallucinating private data
\- reconstructing masked data
\- exposing prompt-injected content
\- producing unauthorized export-like summary

Leakage output must be blocked, redacted, reviewed, or escalated.

\---

\#\# 29\. Prompt Injection Mapping

Prompt injection risk may come from:

\- customer messages
\- support notes
\- staff notes
\- vendor payload
\- POS/KDS notes
\- uploaded attachments
\- incident notes
\- external documents
\- menu descriptions
\- customer complaints

AI pipeline must treat user-provided text as untrusted.

Instructions inside data must not override system or policy instructions.

\---

\#\# 30\. AI Dataset Approval Mapping

AI dataset approval should define:

\- dataset purpose
\- data source
\- data category
\- tenant/store scope
\- masking
\- excluded fields
\- retention
\- model provider
\- model usage
\- external sharing risk
\- approver
\- audit event
\- evidence record

Sensitive dataset generation without approval must be denied.

\---

\#\# 31\. AI Dataset Version Mapping

AI datasets should be versioned where useful.

Dataset version record may include:

\- dataset\_id
\- dataset\_version
\- created\_at
\- created\_by
\- source range
\- masking rule
\- excluded fields
\- tenant/store scope
\- approval id
\- model usage
\- retention
\- deletion status
\- audit event

Versioning helps incident review and reproducibility.

\---

\#\# 32\. AI Retention Mapping

AI input and output retention must be defined.

Retention should consider:

\- dataset class
\- sensitivity
\- model provider policy
\- support case lifecycle
\- incident lifecycle
\- compliance need
\- deletion requirement
\- customer request where applicable
\- operational usefulness

Sensitive AI inputs should not be retained casually.

\---

\#\# 33\. AI Provider Boundary Mapping

If external AI provider is used, mapping must define:

\- provider risk classification
\- data sent to provider
\- data retention setting
\- training usage restriction
\- region or jurisdiction where relevant
\- contract or DPA where needed
\- logging behavior
\- prompt storage behavior
\- output storage behavior
\- incident notification path
\- credential management
\- fallback behavior

AI provider is a vendor boundary.

\---

\#\# 34\. AI Audit Mapping

AI audit events should include:

\- AI dataset requested
\- AI dataset approved
\- AI dataset denied
\- AI dataset generated
\- AI prompt generated
\- AI inference requested
\- AI output generated
\- AI output blocked
\- AI output reviewed
\- AI recommendation accepted
\- AI recommendation rejected
\- AI leakage suspected
\- AI leakage confirmed
\- AI dataset purged
\- AI provider error
\- AI prompt injection detected

Audit must include purpose, scope, dataset class, and actor where applicable.

\---

\#\# 35\. AI Evidence Packet Mapping

AI evidence packet may include:

\- dataset request
\- approval
\- data scope
\- masking rule
\- excluded fields
\- prompt template reference
\- model/provider reference
\- output class
\- reviewer
\- accepted or rejected recommendation
\- leakage review
\- audit references
\- incident link where applicable

Evidence packet must not store raw prohibited data.

\---

\#\# 36\. AI Misuse Detection Mapping

AI misuse indicators may include:

\- repeated requests for raw identity
\- prompt requests containing secrets
\- support notes with raw CI / DI entering prompt
\- AI output exposing masked data
\- AI recommendation executed without approval
\- AI used to approve refund
\- AI used to close incident
\- cross-tenant data included in AI context
\- benchmark dataset generated without approval
\- provider retention setting incorrect
\- prompt injection detected

Misuse indicators should trigger review or incident path.

\---

\#\# 37\. AI Incident Response Mapping

AI incident response should define:

\- detection source
\- affected dataset
\- affected output
\- affected tenant/store/customer scope
\- data categories exposed
\- provider involved
\- containment
\- dataset purge
\- output deletion or restriction
\- credential rotation where needed
\- audit preservation
\- evidence packet
\- customer/legal/compliance review where needed
\- corrective action
\- prompt or dataset rule update

AI leakage may be a security incident.

\---

\#\# 38\. AI Error Handling Mapping

AI errors must be safe.

AI error messages must not reveal:

\- hidden prompt
\- secret policy content
\- raw dataset detail
\- other tenant/store data
\- provider credentials
\- internal stack trace
\- raw payment or identity data

User-facing error may say:

\- "AI analysis is unavailable."
\- "Recommendation could not be generated."
\- "This case requires manual review."

Manual review is safer than unsafe AI output.

\---

\#\# 39\. AI Testing Requirements

Future tests must include:

\- AI dataset excludes raw CI / DI
\- AI dataset excludes payment secrets
\- AI dataset excludes provider payload
\- AI prompt excludes raw support notes where restricted
\- AI cannot approve refund
\- AI cannot confirm payment
\- AI cannot merge account
\- AI cannot approve break-glass
\- AI cannot close degraded recovery
\- AI output is labeled recommendation
\- prompt injection does not override policy
\- cross-tenant data is not included
\- AI output leakage is detected or blocked
\- AI dataset approval is required for sensitive data
\- AI audit events are created
\- AI provider settings match policy

Testing must include abuse cases.

\---

\#\# 40\. Evidence Requirements

Evidence must prove:

\- AI use cases are classified
\- prohibited AI inputs are excluded
\- AI input minimization exists
\- AI output class exists
\- recommendation boundary is visible
\- AI does not execute authority
\- sensitive dataset approval exists
\- AI dataset versioning exists where needed
\- AI provider boundary is reviewed
\- AI audit events exist
\- prompt injection tests exist
\- AI leakage response path exists
\- support AI is case-scoped
\- payment AI cannot mutate payment
\- identity AI cannot access raw CI / DI
\- export AI cannot approve export

Evidence must be reviewable without exposing sensitive AI input.

\---

\#\# 41\. Implementation Blockers

Implementation must be blocked if:

\- AI use cases are undefined
\- prohibited input list is undefined
\- AI dataset classification is undefined
\- AI input minimization is undefined
\- AI recommendation boundary is unclear
\- AI can execute payment/refund/identity/support authority
\- AI prompt construction is uncontrolled
\- AI output leakage handling is undefined
\- AI provider boundary is undefined
\- AI audit mapping is missing
\- AI dataset approval is missing for sensitive data
\- prompt injection control is missing
\- AI retention is undefined
\- tests are missing

These blockers must be added to the implementation blocker register.

\---

\#\# 42\. Mapping Status

Recommended status for this mapping:

\- \`DRAFT\`
\- \`POLICY\_LINKED\`
\- \`RUNTIME\_DEFINED\`
\- \`USE\_CASE\_MAPPED\`
\- \`DATASET\_CLASSIFIED\`
\- \`INPUT\_MINIMIZED\`
\- \`OUTPUT\_CLASSIFIED\`
\- \`RECOMMENDATION\_BOUNDARY\_MAPPED\`
\- \`PROMPT\_SAFETY\_MAPPED\`
\- \`PROVIDER\_BOUNDARY\_MAPPED\`
\- \`AUDIT\_MAPPED\`
\- \`EVIDENCE\_MAPPED\`
\- \`MISUSE\_RESPONSE\_MAPPED\`
\- \`TEST\_MAPPED\`
\- \`BLOCKED\`
\- \`READY\_FOR\_REVIEW\`
\- \`READY\_FOR\_IMPLEMENTATION\`

This document starts as \`DRAFT\`.

It becomes implementation-ready only after AI use case design, dataset mapping, prompt safety, provider review, audit mapping, incident response, and test catalogs are completed.

\---

\#\# 43\. Non-Goals

This document does not define:

\- final AI provider
\- final model
\- final vector database
\- final embedding pipeline
\- final prompt templates
\- final support AI assistant
\- final analytics dashboard
\- final AI API implementation
\- final dataset builder
\- final model evaluation framework
\- final production AI deployment
\- final automated test code

Those belong to later controlled implementation phase.

\---

\#\# 44\. Readiness Check

This mapping is ready when the project can answer:

1\. What AI use cases are allowed?
2\. What authority is prohibited for AI?
3\. What is an AI dataset?
4\. What AI dataset classes exist?
5\. What inputs are prohibited?
6\. What inputs are restricted?
7\. How is AI input minimized?
8\. How is prompt construction controlled?
9\. What AI output classes exist?
10\. How is recommendation boundary shown?
11\. How is delay prediction controlled?
12\. How is POS/KDS mismatch AI controlled?
13\. How is degraded recovery AI controlled?
14\. How is support AI controlled?
15\. How is payment AI controlled?
16\. How is identity AI controlled?
17\. How is export AI controlled?
18\. How is incident AI controlled?
19\. What customer-facing AI output is restricted?
20\. What staff-facing AI output is allowed?
21\. What owner-facing AI output is allowed?
22\. How is output leakage handled?
23\. How is prompt injection handled?
24\. How is AI dataset approval handled?
25\. How is AI dataset versioned?
26\. How is AI retention controlled?
27\. How is AI provider boundary reviewed?
28\. What audit events are required?
29\. What evidence packet is created?
30\. How is AI misuse detected?
31\. How is AI incident response handled?
32\. What tests prove AI safety?
33\. What evidence proves AI controls?
34\. What blocks implementation?

If these questions cannot be answered, AI analytics implementation mapping is incomplete.

\---

\#\# 45\. Conclusion

AI can be powerful in the Yoonsul Wait/Order Handoff project, but only when its authority is constrained.

The system must preserve the following rules:

\- AI may summarize, classify, predict, and recommend
\- AI must not execute authority
\- AI must not confirm payment
\- AI must not approve refund
\- AI must not merge identity
\- AI must not approve unmasking
\- AI must not approve break-glass
\- AI must not close degraded recovery
\- AI must not delete audit
\- AI datasets must be minimized
\- prohibited inputs must be excluded
\- raw CI / DI must not enter AI by default
\- payment secrets must not enter AI
\- support AI must be case-scoped
\- customer-facing AI must be safe and reviewed where sensitive
\- prompt injection must be handled
\- AI output must be classified
\- recommendation boundary must be visible
\- AI provider is a vendor boundary
\- AI audit and evidence must exist
\- AI misuse must trigger review or incident response
\- implementation is blocked until AI use case, dataset, prompt, output, provider, audit, incident, and test controls are mapped

This mapping does not implement AI runtime.

It defines the constraints that future AI analytics implementation must obey.
