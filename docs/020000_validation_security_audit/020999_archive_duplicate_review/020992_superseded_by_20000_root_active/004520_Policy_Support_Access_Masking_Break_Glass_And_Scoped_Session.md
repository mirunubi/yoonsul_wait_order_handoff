# 004520_Policy_Support_Access_Masking_Break_Glass_And_Scoped_Session

\#\# 1\. Purpose

This document defines the support access, masking, break-glass, scoped session, and audit policy for the Yoonsul Wait/Order Handoff project.

Support access is necessary for incident handling, customer recovery, store recovery, POS/KDS mismatch review, degraded mode support, identity issue handling, and operational troubleshooting.

However, support access can become a hidden privilege escalation path if it is not scoped, masked, time-bound, and audited.

Therefore, support access must be treated as a security-sensitive runtime.

\---

\#\# 2\. Scope

This policy applies to:

\- HQ support access
\- technical support access
\- customer support access
\- store recovery support
\- POS/KDS mismatch support
\- payment issue support
\- identity issue support
\- CI / DI related support
\- degraded mode recovery support
\- local agent support
\- bridge support
\- emergency break-glass access
\- support session recording
\- support data masking
\- support audit evidence

This document does not define the final support UI.

It defines the mandatory support access boundary that later admin, support, incident, audit, identity, POS/KDS, and degraded recovery documents must follow.

\---

\#\# 3\. Core Principle

Support access must be narrow by default.

The project must follow this rule:

\> Support may inspect what is necessary for a case, but support must not receive broad production authority by default.

Support access must be:

\- case-based
\- purpose-based
\- role-based
\- time-bound where possible
\- masked by default
\- audited
\- revocable
\- reviewable

Support convenience must not override customer trust, tenant isolation, or audit integrity.

\---

\#\# 4\. Support Access Types

\#\#\# 4.1 Customer Support Access

Customer support access may be used for:

\- waiting issue
\- order issue
\- pickup issue
\- table session issue
\- coupon issue
\- membership issue
\- payment inquiry
\- refund inquiry
\- customer recovery case

Customer support view must be masked by default.

Customer support must not access raw CI/DI unless exceptional approval exists.

\---

\#\#\# 4.2 Store Operation Support Access

Store operation support access may be used for:

\- POS/KDS mismatch
\- kitchen ticket issue
\- degraded mode event
\- manual recovery review
\- local agent queue issue
\- staff operation issue
\- owner/admin operation issue
\- store configuration issue

Store support access must be limited to the affected tenant and store.

\---

\#\#\# 4.3 Technical Support Access

Technical support access may be used for:

\- bridge failure
\- RPC rejection
\- queue failure
\- sync failure
\- local agent failure
\- webhook failure
\- deployment incident
\- log review
\- runtime health review

Technical support must not receive unnecessary customer identity data.

Technical diagnostics must use masked references wherever possible.

\---

\#\#\# 4.4 Security Support Access

Security support access may be used for:

\- suspected account compromise
\- suspicious access pattern
\- secret exposure
\- identity leakage
\- cross-tenant leakage
\- unauthorized role change
\- device compromise
\- support misuse review

Security support access may require deeper visibility, but every sensitive access must be audited.

\---

\#\#\# 4.5 Break-Glass Access

Break-glass access is emergency access beyond normal support scope.

Break-glass access may be used only when immediate action is required to prevent or contain serious operational, security, payment, or customer harm.

Break-glass access must be exceptional, time-limited, audited, and reviewed afterward.

\---

\#\# 5\. Default Masking Rule

Support views must be masked by default.

The following must be masked or hidden unless explicitly unmasked through approved flow:

\- CI
\- DI
\- full phone number
\- full email address
\- payment identity
\- payment provider reference where sensitive
\- raw customer account linkage key
\- raw identity provider reference
\- service secrets
\- API keys
\- access tokens
\- refresh tokens
\- database credentials
\- staff personal identifiers not needed for the case
\- unrelated customer history
\- unrelated tenant data
\- unrelated store data

Support UI must show only what is needed to resolve the case.

\---

\#\# 6\. Unmasking Policy

Unmasking is security-sensitive.

Unmasking may be allowed only when:

\- a valid case exists
\- the actor has role authority
\- the purpose is recorded
\- the data category is allowed for that support role
\- the session is active and scoped
\- audit event is created
\- approval exists where required

Unmasking must not be casual.

Unmasking must not be permanent.

Unmasking must not export raw identity unless separately approved.

\---

\#\# 7\. Case-Based Access Boundary

Support access should start from a case.

A case may include:

\- customer support case
\- store operation incident
\- POS/KDS mismatch case
\- degraded mode recovery case
\- payment inquiry case
\- refund recovery case
\- identity verification issue
\- security incident
\- technical incident
\- audit review case

Support access without a case must be limited to low-risk dashboard views.

Sensitive detail access requires case reference.

\---

\#\# 8\. Purpose-Based Access Boundary

Support actor must declare or inherit purpose.

Examples of support purpose:

\- customer inquiry
\- order recovery
\- waiting recovery
\- payment review
\- refund investigation
\- POS/KDS mismatch review
\- degraded mode recovery
\- identity linkage issue
\- tenant isolation review
\- security incident response
\- technical troubleshooting
\- audit review

The same data may be allowed for one purpose and denied for another.

Purpose must be included in audit.

\---

\#\# 9\. Role-Based Support Boundary

Support roles must be separated.

Possible support roles:

\- Customer Support Agent
\- Store Operation Support
\- Technical Support
\- Security Support
\- HQ Admin
\- Incident Commander
\- Break Glass Operator
\- Auditor

Each role must have a limited access profile.

Customer Support Agent must not receive infrastructure secrets.

Technical Support must not receive raw CI/DI by default.

Store Operation Support must not access other tenant data.

Auditor may inspect evidence but must not mutate operational state unless separately authorized.

\---

\#\# 10\. Tenant And Store Scope

Support access must respect tenant and store scope.

A support session must specify:

\- tenant scope
\- store scope where applicable
\- case scope
\- time scope
\- action scope
\- data visibility scope

Support user must not browse across tenants without explicit authority.

Support user must not browse across unrelated stores without explicit authority.

Cross-tenant access must be exceptional and audited.

\---

\#\# 11\. Time-Bound Session Policy

Sensitive support sessions should be time-bound.

A support session should include:

\- start time
\- expiration time
\- actor
\- role
\- case reference
\- purpose
\- tenant scope
\- store scope
\- allowed actions
\- masking level
\- approval reference where applicable

When the session expires, sensitive access must be revoked.

Long-running support access must be reviewed periodically.

\---

\#\# 12\. Support Session Actions

Support sessions may allow different action classes.

\#\#\# 12.1 Read-Only Support

Read-only support may inspect scoped data but cannot mutate state.

This is the default support mode for sensitive cases.

\---

\#\#\# 12.2 Evidence Attachment Support

Evidence attachment support may add support notes, screenshots references, queue snapshots, or recovery observations.

Evidence attachment must be append-only.

\---

\#\#\# 12.3 Recovery Request Support

Recovery request support may request correction or escalation.

Request is not approval.

Recovery request must not finalize state.

\---

\#\#\# 12.4 Limited Correction Support

Limited correction support may perform low-risk correction within approved boundary.

Examples:

\- update support note
\- correct non-sensitive display label
\- resend notification
\- mark case information as incomplete
\- request customer re-confirmation

Limited correction must be audited.

\---

\#\#\# 12.5 High-Risk Mutation Support

High-risk mutation requires stronger approval.

Examples:

\- refund trigger
\- payment correction
\- settlement adjustment
\- order cancellation after payment
\- customer compensation
\- identity merge
\- role permission change
\- device revocation
\- tenant policy change
\- secret rotation
\- degraded mode recovery approval

High-risk mutation must not be allowed through ordinary support access.

\---

\#\# 13\. Break-Glass Conditions

Break-glass may be used only for exceptional events.

Examples:

\- active security incident
\- suspected secret exposure requiring immediate containment
\- customer identity leakage containment
\- payment incident requiring urgent mitigation
\- cross-tenant leakage containment
\- production outage affecting store operation
\- degraded mode recovery failure causing severe operational harm
\- compromised support account containment
\- legal or compliance emergency

Break-glass must not be used for convenience.

Break-glass must not become normal admin workflow.

\---

\#\# 14\. Break-Glass Requirements

Break-glass access must include:

\- actor identity
\- reason
\- incident reference
\- emergency scope
\- start time
\- expiration time
\- allowed actions
\- masking level
\- affected tenant
\- affected store if applicable
\- approval if available
\- post-use review requirement

If prior approval is impossible due to urgency, post-use review is mandatory.

Break-glass must create audit event immediately.

\---

\#\# 15\. Break-Glass Prohibited Uses

Break-glass must not be used for:

\- ordinary support convenience
\- routine customer inquiry
\- routine store operation
\- normal refund workflow
\- browsing customer data
\- bypassing role review
\- bypassing tenant boundary
\- debugging without incident
\- development testing
\- analytics exploration
\- data export convenience

Emergency authority must not become operational habit.

\---

\#\# 16\. Support Audit Requirements

Support access must be audited.

Audit is required for:

\- support session creation
\- support session expiration
\- support session extension
\- support role elevation
\- data unmasking
\- CI/DI access
\- payment identity access
\- cross-tenant access
\- cross-store access
\- support note creation
\- evidence attachment
\- recovery request
\- high-risk mutation request
\- break-glass activation
\- break-glass action
\- break-glass closure
\- post-use review

Audit must include:

\- actor
\- role
\- tenant scope
\- store scope
\- case reference
\- purpose
\- action
\- data category accessed
\- masking status
\- before state if mutated
\- after state if mutated
\- timestamp
\- approval reference if applicable
\- incident reference if applicable

Audit must be append-only.

\---

\#\# 17\. Support Note Policy

Support notes are evidence.

Support notes must be:

\- factual
\- time-stamped
\- actor-attributed
\- case-linked
\- append-only where possible

Support notes must not include:

\- raw secrets
\- raw CI
\- raw DI
\- unnecessary full phone numbers
\- unnecessary payment secrets
\- abusive or speculative blame language
\- unsupported legal conclusions
\- unsupported staff fault conclusions

Support notes may record observations and actions.

Support notes must not become uncontrolled sensitive data storage.

\---

\#\# 18\. Support Attachment Policy

Support attachments may contain sensitive information.

Attachments may include:

\- screenshot reference
\- receipt reference
\- queue snapshot
\- KDS screen reference
\- POS screen reference
\- customer message reference
\- incident evidence file
\- local agent evidence packet

Attachments must be reviewed for:

\- secrets
\- CI/DI
\- payment identity
\- unrelated customer data
\- unrelated tenant data
\- staff personal data
\- excessive exposure

Sensitive attachments must have restricted access and retention rules.

\---

\#\# 19\. Export And Copy Policy

Support must not casually export sensitive data.

Export or copy of support data requires:

\- case purpose
\- actor authority
\- tenant scope
\- store scope if applicable
\- data minimization
\- masking rule
\- secure delivery method
\- audit event
\- retention rule

Raw CI/DI export must be exceptional.

Secret export is prohibited unless through approved secure secret management process.

\---

\#\# 20\. Support Access To Logs

Support access to logs must be restricted.

Logs may contain operational and security-sensitive information.

Support log access must:

\- be scoped by case
\- mask secrets
\- mask identity linkage values
\- avoid raw token exposure
\- avoid unnecessary production-wide browsing
\- create audit event for sensitive log views

Technical support may need logs.

Customer support usually should not access raw technical logs.

\---

\#\# 21\. Support Access To Degraded Mode Data

Degraded mode data may contain provisional, conflicting, or uncertain state.

Support view must distinguish:

\- verified state
\- provisional local state
\- fallback-originated state
\- cache-uncertain state
\- replay-derived state
\- recovery-pending state
\- conflict state

Support must not present provisional state as final truth.

Support must not silently merge degraded records.

Recovery approval must follow separate boundary.

\---

\#\# 22\. Support Access To POS/KDS Mismatch

POS/KDS mismatch support must preserve authority boundaries.

Support may inspect:

\- POS accepted order reference
\- KDS ticket reference
\- bridge event
\- retry queue
\- rejection reason
\- local agent evidence
\- staff recovery note
\- audit event

Support must not:

\- directly rewrite payment state without approval
\- directly rewrite kitchen state without evidence
\- delete mismatch record
\- hide failed event
\- mark recovery complete without authority
\- treat bridge state as final truth

Mismatch support must create or update evidence, not erase conflict.

\---

\#\# 23\. Support Access To Payment Issues

Payment support is high-risk.

Support may inspect masked payment status and provider reference where allowed.

Support must not access or expose:

\- payment secrets
\- raw payment tokens
\- full card data
\- gateway secret
\- webhook signing secret
\- unrelated payment records

Payment correction, refund execution, and settlement adjustment require separate approval boundary.

Support inquiry is not payment authority.

\---

\#\# 24\. Support Access To Identity Issues

Identity support is high-risk.

Support may inspect masked identity status where needed.

Raw CI/DI access requires exceptional authority and audit.

Support must not:

\- browse raw CI/DI
\- export identity linkage data casually
\- merge identities without approval
\- expose identity values in notes
\- paste identity values into prompts
\- send identity values through unsafe channel

Identity support must be case-based and masked by default.

\---

\#\# 25\. Support Misuse Detection

The system should detect suspicious support behavior.

Examples:

\- excessive customer lookup
\- repeated unmasking
\- cross-tenant browsing
\- access without case
\- access outside working purpose
\- unusual export volume
\- repeated break-glass use
\- access to VIP or sensitive customer without case
\- access after case closure
\- access from unusual device or location
\- failed attempts to access restricted data

Suspicious support behavior must create security review event.

\---

\#\# 26\. Post-Use Review

Break-glass and high-risk support access require post-use review.

Review should confirm:

\- reason was valid
\- scope was appropriate
\- actions were necessary
\- data access was minimized
\- no unrelated data was accessed
\- no secrets were exposed
\- no raw identity was stored in notes
\- mutations were authorized
\- evidence was created
\- session was closed
\- follow-up actions were completed

Post-use review must be recorded.

\---

\#\# 27\. Support Access Revocation

Support access must be revoked when:

\- session expires
\- case is closed
\- role is changed
\- staff leaves the organization
\- account is compromised
\- incident response requires restriction
\- break-glass period ends
\- approval is withdrawn
\- suspicious behavior is detected

Revocation must be auditable for sensitive roles.

\---

\#\# 28\. Secure Support Checklist

Before implementation, confirm:

\- Support access is case-based.
\- Support views are masked by default.
\- Raw CI/DI access is exceptional.
\- Support sessions are scoped.
\- Sensitive support sessions are time-bound.
\- Support unmasking is audited.
\- Support cannot browse across tenants by default.
\- Support cannot browse across stores by default.
\- Support cannot access secrets through UI.
\- Support notes do not store raw secrets or CI/DI.
\- Support attachments are reviewed for sensitive data.
\- Break-glass access is exceptional.
\- Break-glass access is reviewed afterward.
\- High-risk mutation requires separate approval.
\- Payment support does not expose payment secrets.
\- Degraded support distinguishes provisional and verified state.
\- POS/KDS mismatch support preserves evidence.
\- Suspicious support behavior is detectable.

If any item fails, implementation must not proceed.

\---

\#\# 29\. Non-Goals

This document does not define:

\- final support UI design
\- final customer support workflow
\- final incident response runbook
\- final approval system implementation
\- final log viewer implementation
\- final attachment storage design
\- final break-glass UI
\- final role table schema
\- final audit table schema
\- final support staffing policy

Those must be defined in later support, admin, audit, identity, incident, or implementation documents.

\---

\#\# 30\. Readiness Check

This policy is ready when the project can answer:

1\. Who can open a support session?
2\. What case is the support session tied to?
3\. What tenant scope is allowed?
4\. What store scope is allowed?
5\. What data is masked by default?
6\. Who can unmask identity data?
7\. Who can access raw CI/DI?
8\. Who can access payment details?
9\. Can support access secrets?
10\. How long does support access last?
11\. How is support access revoked?
12\. How is unmasking audited?
13\. How is break-glass activated?
14\. How is break-glass reviewed?
15\. Can support perform payment correction?
16\. Can support approve recovery?
17\. Can support merge identities?
18\. How are support notes controlled?
19\. How are support attachments controlled?
20\. How is support misuse detected?

If these questions cannot be answered, implementation must not proceed.

\---

\#\# 31\. Conclusion

Support access is necessary for service quality and recovery.

However, support access must not become a hidden path around security.

The Yoonsul Wait/Order Handoff project must preserve the following rules:

\- support is scoped by case
\- support is masked by default
\- support is purpose-based
\- support is time-bound where sensitive
\- support unmasking is audited
\- raw CI/DI access is exceptional
\- support notes must not store secrets
\- support attachments must be reviewed
\- break-glass is emergency-only
\- high-risk mutation requires approval
\- support access must preserve tenant and store boundaries
\- support must not erase evidence

Support must help recover trust without weakening the trust boundary.
