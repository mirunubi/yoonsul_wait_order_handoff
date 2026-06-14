\# 04470 Financial Grade Security Baseline And Secret Coding Policy

\#\# 1\. Purpose

This document defines the baseline security policy for the Yoonsul Wait/Order Handoff project.

The project must be designed as a financial-grade operational system because it handles customer identity, waiting state, order state, payment handoff, POS/KDS communication, degraded operation, recovery evidence, audit trails, and store operation continuity.

Security is not treated as an optional add-on.

Security must be embedded into architecture, coding rules, configuration rules, deployment rules, operation rules, recovery rules, and audit evidence.

\---

\#\# 2\. Scope

This policy applies to the following areas:

\- Customer waiting and order handoff flow
\- POS to KDS communication
\- Store device and staff device communication
\- Tenant, store, customer, and staff identity context
\- Payment-related handoff and settlement boundary
\- API, RPC, webhook, and bridge communication
\- Local agent, degraded mode, retry, replay, and recovery flow
\- Secret management and secure coding practices
\- Audit, evidence, access, and operational traceability
\- CI / DI / identity linkage data protection

This document does not implement security functions directly.

It defines the mandatory security baseline that later implementation documents must follow.

\---

\#\# 3\. Core Security Principles

\#\#\# 3.1 Deny By Default

All access must be denied by default.

Access is allowed only when the following are explicitly verified:

\- authenticated identity
\- tenant context
\- store context
\- role authority
\- device authority
\- session validity
\- request purpose
\- allowed action boundary
\- audit requirement

No API, RPC, webhook, bridge, internal service, local agent, or store network request may assume trust merely because it is internal.

Internal does not mean trusted.

\---

\#\#\# 3.2 Visibility Is Not Authority

A runtime may observe state without having the authority to mutate it.

Examples:

\- KDS may view kitchen execution state but may not rewrite payment authority.
\- Agent may recommend recovery action but may not approve it.
\- Store tablet may initiate operational action but must not bypass audit rules.
\- POS bridge may transmit state but must not become the ownership source of order/payment truth.
\- Support session may inspect a scoped case but must not gain broad production authority.

Visibility must be separated from authority in every runtime boundary.

\---

\#\#\# 3.3 Recommendation Is Not Execution

AI, Agent, or automation may detect, recommend, classify, prioritize, summarize, or simulate.

However, the following actions require explicit authority boundary:

\- order cancellation
\- payment correction
\- settlement adjustment
\- refund execution
\- staff override
\- recovery approval
\- customer compensation
\- audit closure
\- legal confirmation
\- compliance confirmation
\- secret rotation
\- device revocation
\- tenant-level configuration change

AI output must never be treated as final operational authority.

\---

\#\#\# 3.4 Replay Is Not Mutation

Replay is allowed only as reconstruction, verification, comparison, or recovery evidence.

Replay must not silently overwrite current state.

When replay produces a different result from the current state, the system must mark the case as one or more of the following:

\- \`REPLAY\_REQUIRED\`
\- \`CACHE\_STATE\_UNCERTAIN\`
\- \`RECONCILIATION\_REQUIRED\`
\- \`RECOVERY\_PENDING\`
\- \`MANUAL\_REVIEW\_REQUIRED\`

Final correction must be performed through approved append-only amendment or recovery flow.

Replay may explain what happened.

Replay must not erase what happened.

\---

\#\#\# 3.5 Degraded Mode Is Not Security Bypass

Degraded operation may allow minimum operation continuity.

However, degraded mode must not bypass identity, authority, evidence, or audit rules.

When degraded mode is active:

\- local state must be marked as provisional
\- manual input must create evidence
\- fallback-originated records must be marked
\- stale data must not overwrite verified central data
\- recovery must be traceable
\- sync conflict must be reviewed
\- silent merge is prohibited

Fallback-originated data must be marked with:

\- \`FALLBACK\_ORIGINATED\`
\- \`CACHE\_STATE\_UNCERTAIN\`
\- \`RECOVERY\_PENDING\`

\---

\#\# 4\. Financial Grade Security Direction

The project must follow a financial-grade security posture even if the initial service is an F\&B operation system.

The system touches customer identity, order flow, POS/KDS execution, payment boundary, settlement evidence, recovery evidence, and operational audit.

Therefore, the following principles are mandatory:

\- least privilege
\- deny by default
\- separation of duty
\- immutable audit trail
\- append-only correction
\- sensitive action reauthentication
\- secure secret storage
\- no hardcoded secrets
\- no plaintext credential storage
\- no silent privilege escalation
\- scoped support access
\- device/session separation
\- tamper-evident evidence packet
\- traceable approval chain
\- recovery without overwriting history
\- tenant isolation
\- store isolation
\- role isolation
\- runtime authority separation

The goal is not to copy a specific bank system directly.

The goal is to apply financial-grade discipline to identity, access, transaction, evidence, recovery, and audit boundaries.

\---

\#\# 5\. Secret Coding Policy

\#\#\# 5.1 Prohibited Practices

The following practices are prohibited:

\- hardcoding API keys in source code
\- committing \`.env\` files
\- exposing service role keys to client apps
\- storing secrets in markdown documents
\- sharing secrets in screenshots
\- logging access tokens
\- logging refresh tokens
\- logging payment tokens
\- logging customer CI values
\- logging customer DI values
\- logging full personal identifiers
\- embedding database credentials in frontend code
\- using admin keys in mobile or web clients
\- using production secrets in local examples
\- placing real secrets in test fixtures
\- placing real secrets in sample SQL
\- placing real secrets in issue trackers
\- placing real secrets in prompt text
\- placing real secrets in generated documentation

Secrets must not appear in code, docs, screenshots, logs, test data, or chat instructions.

\---

\#\#\# 5.2 Required Practices

The following practices are required:

\- use environment variables for runtime configuration
\- separate development, staging, and production secrets
\- rotate exposed or suspected secrets immediately
\- mask sensitive values in logs
\- use scoped keys whenever possible
\- use short-lived tokens where applicable
\- separate client keys and server-only keys
\- require server-side validation for sensitive actions
\- keep secret access auditable
\- document secret owner and rotation rule
\- maintain separate local sample configuration
\- provide \`.env.example\` only with dummy values
\- block secret commits through pre-commit or CI checks where possible
\- avoid showing real secret values in operational screenshots

\---

\#\#\# 5.3 Secret Exposure Response

If a secret is suspected to be exposed:

1\. Treat the secret as compromised.
2\. Rotate the secret.
3\. Identify affected runtime and deployment surface.
4\. Search code, logs, documents, screenshots, prompts, and commit history.
5\. Create a security incident record.
6\. Record recovery evidence.
7\. Verify that the old secret no longer works.
8\. Review why the exposure happened.
9\. Update coding, deployment, or documentation rules if needed.

Secret exposure must never be handled only by deleting the visible text.

Deletion is not recovery.

Rotation and verification are required.

\---

\#\# 6\. CI / DI And Identity Linkage Data Protection

Customer identity values such as CI, DI, phone number, account identifier, membership identifier, waiting session, order session, and payment reference must be treated as sensitive identity linkage data.

The system must not expose raw identity linkage values unless strictly required.

Required controls:

\- minimize collection
\- minimize display
\- minimize log exposure
\- mask where possible
\- separate identity reference from operational session
\- separate customer account from payment authority
\- prevent cross-tenant identity leakage
\- prevent store-to-store customer identity leakage
\- prevent staff from accessing unnecessary identity values
\- prevent customer identity from leaking through audit views
\- prevent support tools from exposing raw identity linkage values by default

CI / DI leakage must be treated as a serious security incident.

\---

\#\# 7\. Tenant And Store Boundary Security

Tenant and store boundaries are mandatory security boundaries.

Every sensitive request must verify:

\- tenant id
\- store id
\- actor id
\- role mapping
\- device context
\- session context
\- allowed runtime
\- allowed action

A valid user in one tenant must not access another tenant.

A valid store operator in one store must not access another store unless explicitly authorized.

A valid HQ user must not automatically bypass store-level rules unless the action is within an approved HQ authority boundary.

Tenant mismatch must be treated as a security event.

Store context mismatch must be treated as a security event.

\---

\#\# 8\. POS / KDS / RPC Security Boundary

POS and KDS communication must be protected by explicit RPC security rules.

\#\#\# 8.1 POS Authority

POS remains the transaction authority for:

\- accepted order
\- payment
\- cancellation
\- refund trigger
\- settlement-related truth
\- transaction-level correction

KDS must not become transaction authority.

\---

\#\#\# 8.2 KDS Authority

KDS may own kitchen execution state, including:

\- ticket received
\- cooking started
\- hold
\- remake requested
\- delayed
\- ready
\- served
\- kitchen note
\- manual kitchen recovery

KDS must not rewrite POS payment state.

KDS must not silently cancel or refund an order.

\---

\#\#\# 8.3 Bridge Boundary

Bridge runtime may:

\- transmit
\- translate
\- validate
\- queue
\- retry
\- report
\- detect stale state
\- create evidence
\- request recovery

Bridge runtime must not silently mutate transaction authority.

Bridge runtime must not become the owner of POS truth or KDS truth.

\---

\#\#\# 8.4 RPC Security Requirements

Every POS/KDS RPC request must validate:

\- tenant id
\- store id
\- runtime id
\- device id or service identity
\- request timestamp
\- request signature or trusted channel
\- allowed method
\- allowed state transition
\- idempotency key
\- retry scope
\- replay protection
\- audit event requirement

Invalid requests must be rejected and logged.

Suspicious requests must be classified separately from ordinary technical failure.

\---

\#\# 9\. Device And Session Security

The system must distinguish device role and user role.

Examples of device roles:

\- store tablet
\- POS terminal
\- KDS screen
\- kitchen tablet
\- staff mobile
\- owner mobile
\- HQ admin web
\- support session
\- local agent

A trusted device does not automatically mean trusted user authority.

A trusted user does not automatically mean trusted device authority.

Sensitive actions may require:

\- reauthentication
\- device trust check
\- role check
\- store context check
\- tenant context check
\- time-bound session
\- scoped permission
\- audit reason
\- manager approval
\- HQ approval

Lost or broken devices must be handled through:

\- device revocation
\- session invalidation
\- token invalidation
\- local cache invalidation where possible
\- audit event creation
\- recovery review if the device had offline data

\---

\#\# 10\. Support Access Policy

Support access must be scoped, time-bound, and auditable.

Support staff must not receive broad production access by default.

Support access requires:

\- case or incident reference
\- approved purpose
\- limited scope
\- time limit
\- masking rule
\- audit event
\- session record
\- revocation after use

Break-glass access must be exceptional.

Break-glass access must be reviewed afterward.

Support access must not become a hidden administrator path.

\---

\#\# 11\. Audit And Evidence Policy

Security-sensitive actions must generate audit events.

Examples:

\- login failure
\- role change
\- permission change
\- device registration
\- device revocation
\- tenant context switch
\- store context switch
\- manual override
\- degraded mode activation
\- replay request
\- recovery approval
\- refund or compensation trigger
\- POS/KDS mismatch
\- secret rotation
\- support access
\- suspicious access pattern
\- RPC rejection
\- token failure
\- CI / DI exposure suspicion
\- cross-tenant access attempt

Audit records must include:

\- actor
\- role
\- tenant context
\- store context
\- device context
\- runtime context
\- action
\- before state
\- after state
\- reason
\- timestamp
\- source
\- approval reference if applicable
\- evidence reference if applicable

Audit must be append-only.

Audit must not be silently edited.

Audit correction must also be append-only.

\---

\#\# 12\. Logging And Masking Policy

Logs must support debugging, recovery, and audit.

However, logs must not expose sensitive data.

Logs must mask:

\- access token
\- refresh token
\- API key
\- service role key
\- payment token
\- CI
\- DI
\- full phone number
\- full email address where unnecessary
\- customer personal identifiers
\- raw identity linkage values
\- secret configuration values

Error messages shown to users or staff must not reveal internal secrets, database details, stack traces, or security configuration.

Internal diagnostic logs must be access-controlled.

\---

\#\# 13\. Secure Configuration Policy

Configuration changes may affect runtime authority and security posture.

The following configuration changes are security-sensitive:

\- tenant policy change
\- store policy change
\- POS bridge configuration
\- KDS bridge configuration
\- RPC allowlist change
\- webhook endpoint change
\- payment gateway setting
\- secret rotation
\- device trust policy
\- role permission change
\- degraded mode policy
\- support access policy
\- audit retention policy

Security-sensitive configuration changes require:

\- actor identity
\- authority check
\- change reason
\- before/after record
\- approval where needed
\- rollback plan where needed
\- audit event

Configuration change must not be treated as a casual admin action.

\---

\#\# 14\. Degraded Mode Security

Degraded operation must preserve authority boundaries.

When central connectivity fails, local operation may continue only under controlled conditions.

Rules:

\- Primary local agent may hold provisional operational state.
\- Secondary local agent must not overwrite Primary state.
\- Store device must mark offline or degraded input clearly.
\- Manual kitchen note must create evidence.
\- Manual recovery must not become final settlement truth.
\- Central recovery must verify local evidence.
\- Conflict must be marked and reviewed.
\- Silent merge is prohibited.

Degraded mode must prefer continuity with evidence over false certainty.

\---

\#\# 15\. Recovery Security

Recovery is a security-sensitive process.

Recovery may affect order state, payment state, customer trust, staff accountability, and audit history.

Recovery actions require:

\- recovery reason
\- affected order/session/ticket reference
\- actor identity
\- authority check
\- evidence attachment or evidence reference
\- before state
\- proposed after state
\- approval boundary where needed
\- final audit event

Recovery must not delete original failure state.

Recovery must append correction state.

\---

\#\# 16\. Development Security Checklist

Before implementation, each related module must confirm:

\- No secret is hardcoded.
\- No service role key is exposed to frontend.
\- No production secret is used in test data.
\- \`.env.example\` contains dummy values only.
\- RLS or equivalent access control exists.
\- Tenant boundary is validated.
\- Store boundary is validated.
\- Role boundary is validated.
\- Device boundary is validated.
\- Sensitive action is audited.
\- Dangerous mutation has approval boundary.
\- Replay does not overwrite.
\- Recovery creates evidence.
\- Logs mask sensitive values.
\- Errors do not expose secret or identity data.
\- Test data does not contain real personal data.
\- Local, staging, and production config are separated.
\- Support access is scoped.
\- CI / DI values are protected.
\- POS/KDS RPC requests are validated.
\- Degraded mode does not bypass security.

\---

\#\# 17\. Non-Goals

This document does not define:

\- final encryption algorithm choice
\- final cloud vendor implementation
\- exact database schema
\- exact RPC function names
\- final CI / DI provider integration
\- final payment gateway contract
\- final security certification checklist
\- final penetration test procedure
\- final incident response runbook

Those items must be defined in later implementation, compliance, audit, or incident response documents.

\---

\#\# 18\. Related Document Direction

This document should be referenced by later documents covering:

\- POS/KDS RPC security
\- bridge security
\- local agent security
\- tenant boundary security
\- support access governance
\- secret rotation governance
\- CI / DI protection
\- degraded mode recovery
\- audit evidence packet
\- financial-grade compliance readiness
\- secure deployment checklist
\- secure coding standard

This document is a baseline.

Later documents may be more specific, but they must not weaken this baseline.

\---

\#\# 19\. Readiness Check

This policy is considered ready when the project can answer the following questions:

1\. Where are secrets stored?
2\. Who can access production secrets?
3\. How are exposed secrets rotated?
4\. Which runtime owns transaction truth?
5\. Which runtime owns kitchen execution truth?
6\. Which actions require reauthentication?
7\. Which actions require approval?
8\. Which events are audit-only?
9\. Which events can mutate state?
10\. How is degraded operation secured?
11\. How is support access limited?
12\. How is CI / DI leakage prevented?
13\. How is tenant leakage prevented?
14\. How is store leakage prevented?
15\. How is POS/KDS RPC misuse prevented?
16\. How is replay prevented from becoming overwrite?
17\. How is secret exposure handled?
18\. How are logs masked?
19\. How is device loss handled?
20\. How are recovery actions audited?

If these questions cannot be answered, implementation must not proceed.

\---

\#\# 20\. Conclusion

The Yoonsul Wait/Order Handoff system must be designed as a security-first operational platform.

Because the system connects customer identity, waiting state, order state, POS/KDS execution, payment boundary, degraded operation, and recovery evidence, weak security would directly damage trust.

Therefore, every implementation document after this policy must preserve the following principles:

\- deny by default
\- least privilege
\- visibility is not authority
\- recommendation is not execution
\- replay is not mutation
\- degraded mode is not security bypass
\- audit is append-only
\- secret exposure is incident
\- customer identity linkage data is sensitive
\- financial-grade discipline is mandatory

Security must be treated as part of the product architecture, not as a later checklist.
