04580 Log Masking Error Disclosure And Diagnostic Data Policy

\#\# 1\. Purpose

This document defines the log masking, error disclosure, diagnostic data, troubleshooting visibility, and sensitive failure handling policy for the Yoonsul Wait/Order Handoff project.

Logs and error messages are necessary for debugging, incident response, degraded recovery, POS/KDS troubleshooting, support review, payment reconciliation, and audit evidence.

However, logs and errors can easily expose secrets, CI / DI, customer identity, payment references, tenant data, store data, internal system structure, and authority boundaries.

Therefore, logging and diagnostics must be designed as a security boundary.

\---

\#\# 2\. Scope

This policy applies to:

\- application logs
\- API logs
\- RPC logs
\- POS/KDS bridge logs
\- local agent logs
\- KDS device logs
\- POS terminal logs
\- customer web logs
\- staff web logs
\- admin web logs
\- Flutter/mobile logs
\- kiosk logs
\- support tool logs
\- payment webhook logs
\- identity provider logs
\- database logs
\- edge function logs
\- deployment logs
\- error messages
\- stack traces
\- diagnostic snapshots
\- troubleshooting attachments
\- incident evidence packets

This document does not define the final logging vendor.

It defines the mandatory masking and disclosure rules that later implementation, infrastructure, support, audit, and security operation documents must follow.

\---

\#\# 3\. Core Principle

Logs must support recovery without becoming sensitive data storage.

The project must follow this rule:

\> Log enough to reconstruct and diagnose, but never log secrets, raw CI / DI, payment secrets, or unnecessary customer identity.

Diagnostic usefulness must not override security.

\---

\#\# 4\. Logging Purpose

Logs may be used for:

\- debugging
\- runtime health monitoring
\- incident response
\- POS/KDS mismatch review
\- degraded mode recovery
\- replay comparison
\- payment reconciliation
\- support troubleshooting
\- suspicious activity detection
\- audit support
\- deployment verification
\- performance analysis

Logs must not be used as a shortcut for storing business records, secrets, identity records, or final audit truth.

\---

\#\# 5\. Data That Must Never Be Logged Raw

The following must never be logged raw:

\- service role key
\- API secret
\- database password
\- payment provider secret
\- webhook signing secret
\- OAuth client secret
\- access token
\- refresh token
\- authorization header
\- session token
\- private signing key
\- deployment token
\- cloud provider credential
\- POS bridge credential
\- KDS bridge credential
\- local agent credential
\- raw CI
\- raw DI
\- full payment token
\- full card data
\- full identity provider payload
\- production \`.env\` content
\- full database connection string

If any of these appear in logs, the event must be treated as a security incident.

\---

\#\# 6\. Data That Must Be Masked Or Minimized

The following must be masked, partially redacted, tokenized, hashed, or excluded unless a stronger approved reason exists:

\- phone number
\- email address
\- customer account id
\- membership id
\- payment provider reference
\- refund reference
\- receipt reference
\- customer support case identity
\- staff personal identifier
\- device identifier where sensitive
\- source IP where not needed in full
\- user agent where not needed in full
\- customer message content
\- support note content
\- location data
\- order memo containing personal data
\- delivery or pickup personal note
\- identity linkage keys
\- table session token
\- waiting token
\- order session token

Masking must preserve diagnostic value without exposing unnecessary identity.

\---

\#\# 7\. Safe Log References

Logs should prefer safe references.

Recommended safe references include:

\- audit\_event\_id
\- correlation\_id
\- request\_id
\- idempotency\_key
\- tenant\_id where authorized
\- store\_id where authorized
\- order\_id
\- ticket\_id
\- masked customer reference
\- masked payment reference
\- device role
\- runtime type
\- error category
\- state transition category
\- result status
\- retry count
\- queue status
\- reconciliation case id
\- incident id

Safe references should allow investigation without exposing raw sensitive data.

\---

\#\# 8\. Correlation ID Policy

Every important runtime path should support correlation.

Correlation is required for:

\- waiting to order handoff
\- POS accepted order
\- KDS ticket creation
\- POS/KDS bridge event
\- retry event
\- replay event
\- degraded mode fallback
\- local agent sync
\- payment webhook
\- refund request
\- support case
\- recovery approval
\- deployment event
\- incident event

Correlation ID must not contain customer identity, phone number, CI, DI, or secret-derived values.

\---

\#\# 9\. Error Message Disclosure Policy

User-facing and staff-facing error messages must be safe.

Error messages must not reveal:

\- database schema
\- SQL query
\- stack trace
\- secret value
\- internal service key
\- raw token
\- raw CI / DI
\- payment provider secret
\- webhook signing detail
\- internal endpoint path where unnecessary
\- another tenant record existence
\- another store record existence
\- permission rule internals
\- infrastructure topology

Error messages should explain what the user or staff can do next without exposing internal details.

\---

\#\# 10\. Safe Error Categories

Errors should be mapped into safe categories.

Recommended safe categories include:

\- invalid request
\- unauthorized
\- forbidden
\- session expired
\- device not trusted
\- role not allowed
\- tenant context invalid
\- store context invalid
\- duplicate request
\- stale request
\- conflict detected
\- retry required
\- replay required
\- reconciliation required
\- payment verification pending
\- degraded mode active
\- manual review required
\- support required
\- temporarily unavailable
\- recovery pending

Detailed diagnostics must be kept in restricted logs, not shown broadly.

\---

\#\# 11\. Stack Trace Policy

Stack traces are sensitive.

Stack traces may reveal:

\- file paths
\- code structure
\- database names
\- table names
\- environment variables
\- internal endpoints
\- library versions
\- secrets accidentally embedded in errors
\- request payloads

Stack traces must not be shown to:

\- customers
\- ordinary staff
\- kitchen users
\- public pages
\- unauthenticated users
\- ordinary support users without need

Stack traces may be available only to authorized technical operators under controlled access.

\---

\#\# 12\. POS/KDS Log Policy

POS/KDS logs must support operational recovery while preserving security.

POS/KDS logs may include:

\- tenant context
\- store context
\- order reference
\- ticket reference
\- runtime type
\- device role
\- transition attempt
\- transition result
\- retry count
\- rejection reason category
\- correlation id
\- timestamp
\- degraded marker
\- reconciliation marker

POS/KDS logs must not include:

\- raw CI
\- raw DI
\- full customer phone number
\- payment secret
\- service role key
\- bridge credential
\- raw customer token
\- full payment identity
\- unrelated tenant data
\- unrelated store data

\---

\#\# 13\. Bridge Log Policy

Bridge logs must be security-aware.

Bridge logs may include:

\- event received
\- event validated
\- event rejected
\- event queued
\- event retried
\- event quarantined
\- event replay requested
\- tenant/store validation result
\- runtime identity validation result
\- idempotency result
\- correlation id

Bridge logs must not include:

\- bridge credential
\- raw authorization header
\- raw service token
\- raw payment token
\- raw identity linkage value
\- full customer personal data

Bridge rejection logs must be detailed enough for review but safe enough for restricted diagnostics.

\---

\#\# 14\. Local Agent Log Policy

Local Agent logs are sensitive because they may exist in store-local environments.

Local Agent logs may include:

\- queue status
\- retry status
\- sync status
\- fallback-originated marker
\- cache uncertainty marker
\- Primary/Secondary status
\- promotion event
\- local event reference
\- central sync result
\- conflict marker
\- evidence packet reference

Local Agent logs must not include:

\- broad production credentials
\- raw CI / DI
\- payment secrets
\- full customer identity
\- unnecessary customer message content
\- unrelated store data
\- unrelated tenant data

If Local Agent device is lost or compromised, local logs must be considered during incident review.

\---

\#\# 15\. Payment Log Policy

Payment logs are high-risk.

Payment logs may include:

\- payment state
\- masked payment reference
\- refund state
\- masked refund reference
\- provider event id where safe
\- webhook validation result
\- idempotency result
\- reconciliation case id
\- amount where appropriate
\- currency where appropriate
\- timestamp
\- result category

Payment logs must not include:

\- payment secret
\- webhook signing secret
\- raw payment token
\- full card data
\- raw authorization header
\- full payment provider payload if it contains sensitive data
\- raw customer identity
\- raw CI / DI

Payment log exposure may become financial security incident.

\---

\#\# 16\. Identity Log Policy

Identity logs must be minimized.

Identity logs may include:

\- masked customer reference
\- identity event category
\- consent event category
\- unmasking audit reference
\- support case reference
\- verification result category
\- tenant/store scope
\- timestamp

Identity logs must not include:

\- raw CI
\- raw DI
\- full identity provider payload
\- full phone number
\- full email address
\- raw identity linkage key
\- raw customer document value
\- raw payment identity

Identity troubleshooting must use masked or tokenized references.

\---

\#\# 17\. Support Tool Log Policy

Support tool logs must record access while avoiding sensitive storage.

Support logs should include:

\- support session id
\- actor
\- role
\- case reference
\- tenant scope
\- store scope
\- data category accessed
\- masking status
\- unmasking event
\- export event
\- break-glass event
\- action result

Support logs must not include:

\- raw CI / DI in note logs
\- raw secrets
\- payment secrets
\- copied customer identity values
\- unnecessary support attachment content
\- unrelated customer data

Support misuse detection depends on safe but complete access logging.

\---

\#\# 18\. Admin And HQ Log Policy

Admin and HQ logs may contain high-risk operational context.

Admin logs must record:

\- role change
\- permission change
\- configuration change
\- device trust change
\- tenant policy change
\- store policy change
\- support access change
\- secret reference change
\- deployment-related action
\- export action

Admin logs must not contain:

\- raw secret values
\- raw CI / DI
\- full payment secrets
\- production \`.env\` content
\- unmasked customer identity unless separately justified and audited

Admin authority must be visible, but sensitive values must remain masked.

\---

\#\# 19\. Deployment Log Policy

Deployment logs must not expose secrets.

Deployment logs may include:

\- release id
\- environment
\- runtime
\- migration reference
\- deployment status
\- health check result
\- rollback result
\- configuration reference
\- secret reference name

Deployment logs must not include:

\- production secret value
\- \`.env\` content
\- service role key
\- database password
\- payment secret
\- deployment token
\- cloud credential
\- full connection string

A deployment log containing secrets must trigger secret exposure response.

\---

\#\# 20\. Database Log Policy

Database logs can expose sensitive data through queries or parameters.

Database logging must avoid:

\- logging raw query parameters containing identity
\- logging full SQL with embedded secrets
\- logging raw CI / DI
\- logging payment tokens
\- logging full customer personal data
\- logging service role keys
\- logging production connection string

If verbose database logging is needed during incident response, access must be restricted and logs must be reviewed for sensitive exposure.

\---

\#\# 21\. Diagnostic Snapshot Policy

Diagnostic snapshots may be useful for incident response.

Diagnostic snapshots may include:

\- runtime state summary
\- queue status
\- retry status
\- recent error categories
\- masked event references
\- POS/KDS mismatch summary
\- local agent sync status
\- degraded mode markers
\- audit event references

Diagnostic snapshots must not include:

\- raw secrets
\- raw CI / DI
\- full customer personal data
\- payment secrets
\- raw tokens
\- unrestricted customer messages
\- unrelated tenant data
\- unrelated store data

Snapshots must be scoped to incident or case.

\---

\#\# 22\. Troubleshooting Attachment Policy

Troubleshooting attachments may contain screenshots, exported logs, queue dumps, or evidence files.

Before attachment is stored or shared, it must be checked for:

\- secrets
\- raw CI / DI
\- payment tokens
\- full customer identity
\- full phone numbers
\- full email addresses
\- unrelated customer data
\- unrelated tenant data
\- unrelated store data
\- internal keys or credentials

Sensitive attachments must be restricted, masked, or replaced with safer summaries where possible.

\---

\#\# 23\. Customer-Facing Error Policy

Customer-facing errors must be simple and safe.

Customer-facing errors may say:

\- payment verification is pending
\- order status is being checked
\- store confirmation is delayed
\- session expired
\- request could not be completed
\- staff assistance is required
\- refund request is under review
\- temporary connection issue

Customer-facing errors must not say:

\- database error details
\- internal service failed with key name
\- payment provider secret validation failed
\- another customer or tenant record exists
\- role policy rejected specific internal rule
\- stack trace
\- raw status payload

Customer trust requires clarity without exposure.

\---

\#\# 24\. Staff-Facing Error Policy

Staff-facing errors must be operationally useful but safe.

Staff-facing errors may show:

\- retry needed
\- manager approval required
\- support required
\- payment verification pending
\- KDS sync delayed
\- POS/KDS mismatch detected
\- degraded mode active
\- manual recovery required
\- device not trusted
\- session expired

Staff-facing errors must not show:

\- secrets
\- raw CI / DI
\- raw SQL
\- stack trace
\- internal tokens
\- unrelated tenant/store information
\- payment provider secret details

Operational usefulness must remain scoped.

\---

\#\# 25\. Support-Facing Error Policy

Support-facing errors may be more detailed than staff-facing errors but must still be masked.

Support-facing errors may include:

\- error category
\- correlation id
\- affected runtime
\- affected tenant/store scope
\- case reference
\- rejection category
\- retry count
\- recovery requirement
\- masked payment reference
\- masked customer reference

Support-facing errors must not include:

\- raw secrets
\- raw CI / DI
\- raw payment tokens
\- full stack trace unless technical support scope permits
\- database credentials
\- internal signing keys

Support detail must be case-scoped.

\---

\#\# 26\. Technical Diagnostic Access

Technical diagnostic access must be role-scoped.

Technical operators may need:

\- stack trace
\- structured error details
\- runtime metadata
\- queue details
\- deployment logs
\- database diagnostic summaries
\- bridge logs
\- local agent logs

Technical diagnostic access must be:

\- role-based
\- environment-scoped
\- tenant/store-scoped where applicable
\- audited for sensitive logs
\- masked by default where possible
\- time-bound for incident-specific deep access where possible

Technical access must not become broad customer identity access.

\---

\#\# 27\. Log Retention Direction

Log retention must be risk-based.

Retention must consider:

\- incident response need
\- payment dispute need
\- operational recovery need
\- audit support need
\- privacy minimization
\- storage risk
\- tenant contract requirement
\- legal requirement

Logs containing sensitive operational data should not be retained longer than needed.

Final retention periods must be defined in later compliance documents.

\---

\#\# 28\. Log Access Control

Log access must be controlled.

Log access should be separated by role:

\- developer
\- technical operator
\- support agent
\- security operator
\- auditor
\- HQ admin
\- store owner

Not every role needs raw logs.

Customer support usually needs case summaries, not infrastructure logs.

Store owner usually needs operational summaries, not security diagnostics.

Security operator may need suspicious activity logs.

Access to sensitive logs must be auditable.

\---

\#\# 29\. Log Export Policy

Log export is sensitive.

Log export requires:

\- actor authority
\- purpose
\- scope
\- masking rule
\- tenant/store boundary
\- case or incident reference where applicable
\- secure delivery method
\- retention rule
\- audit event

Log export must not include raw secrets, raw CI / DI, raw payment tokens, or unrelated tenant data.

\---

\#\# 30\. Sensitive Data Detection In Logs

The system should support detection of sensitive data in logs.

Detection targets include:

\- API key pattern
\- service role key pattern
\- token pattern
\- authorization header
\- database connection string
\- raw CI / DI pattern where detectable
\- full phone number pattern
\- full email pattern
\- payment token pattern
\- webhook secret pattern

Detection should create security review event when sensitive exposure is suspected.

\---

\#\# 31\. Log Exposure Response

If sensitive data appears in logs:

1\. Identify data type.
2\. Classify severity.
3\. Restrict log access.
4\. Rotate secret if a secret is exposed.
5\. Assess customer identity exposure if identity is exposed.
6\. Assess payment exposure if payment data is exposed.
7\. Purge, quarantine, or mask logs where possible.
8\. Identify who accessed the logs.
9\. Create incident record.
10\. Preserve safe evidence.
11\. Fix logging source.
12\. Verify prevention update.

Log deletion alone is not sufficient when secrets or identity were exposed.

\---

\#\# 32\. Safe Diagnostics For AI Tools

AI tools may help analyze errors, but diagnostic data must be sanitized.

Before sharing with AI tools, remove:

\- secrets
\- service role keys
\- database passwords
\- access tokens
\- refresh tokens
\- raw CI / DI
\- full customer identity
\- payment secrets
\- full payment tokens
\- production connection strings
\- private URLs containing tokens
\- full \`.env\` content

AI tools may receive:

\- masked error message
\- safe stack summary
\- pseudonymized correlation id
\- schema shape without data
\- dummy configuration
\- redacted log excerpt
\- reproduction steps with fake values

AI troubleshooting must not become data leakage.

\---

\#\# 33\. Logging And Audit Separation

Logs and audit are related but not the same.

Logs support diagnostics.

Audit supports evidence of authority and action.

A log entry must not replace required audit event.

An audit event must not store unnecessary diagnostic payload.

High-risk actions require audit even if logs exist.

Diagnostic logs may be rotated according to retention.

Audit retention follows evidence policy.

\---

\#\# 34\. Secure Logging Checklist

Before implementation, confirm:

\- Secrets are never logged raw.
\- Raw CI / DI is never logged.
\- Payment secrets are never logged.
\- Authorization headers are masked.
\- Phone numbers are masked.
\- Emails are masked where unnecessary.
\- Correlation IDs contain no identity.
\- User-facing errors are safe.
\- Staff-facing errors are scoped.
\- Support-facing errors are masked.
\- Stack traces are restricted.
\- POS/KDS logs are safe.
\- Bridge logs are safe.
\- Local Agent logs are safe.
\- Payment logs are safe.
\- Identity logs are minimized.
\- Deployment logs do not expose secrets.
\- Diagnostic snapshots are scoped.
\- Troubleshooting attachments are reviewed.
\- Log access is role-scoped.
\- Log export is audited.
\- Sensitive log exposure response exists.
\- Logs do not replace audit.

If any item fails, implementation must not proceed.

\---

\#\# 35\. Non-Goals

This document does not define:

\- final logging vendor
\- final SIEM product
\- final log storage schema
\- final redaction library
\- final log retention period
\- final alerting product
\- final dashboard UI
\- final tracing system
\- final stack trace collection tool
\- final observability vendor
\- final incident response runbook

Those must be defined in later infrastructure, observability, security operation, compliance, or implementation documents.

\---

\#\# 36\. Readiness Check

This policy is ready when the project can answer:

1\. What must never be logged?
2\. How are secrets masked?
3\. How are CI / DI values prevented from logs?
4\. How are payment logs masked?
5\. What error details are shown to customers?
6\. What error details are shown to staff?
7\. What error details are shown to support?
8\. Who can see stack traces?
9\. How are POS/KDS logs protected?
10\. How are bridge logs protected?
11\. How are local agent logs protected?
12\. How are deployment logs checked for secrets?
13\. How are diagnostic snapshots scoped?
14\. How are troubleshooting attachments reviewed?
15\. Who can export logs?
16\. How are log exports audited?
17\. How is sensitive data detected in logs?
18\. What happens if a secret appears in logs?
19\. What happens if CI / DI appears in logs?
20\. How are logs separated from audit?

If these questions cannot be answered, implementation must not proceed.

\---

\#\# 37\. Conclusion

Logging is necessary for a reliable operational platform.

However, unsafe logging can expose the very data the system is supposed to protect.

The Yoonsul Wait/Order Handoff system must preserve the following rules:

\- logs support diagnostics, not sensitive storage
\- secrets must never be logged
\- raw CI / DI must never be logged
\- payment secrets must never be logged
\- correlation IDs must not contain identity
\- customer-facing errors must be safe
\- staff-facing errors must be scoped
\- support-facing errors must be masked
\- technical diagnostics must be role-scoped
\- POS/KDS logs must preserve security boundaries
\- local agent logs must account for offline risk
\- diagnostic snapshots must be scoped
\- troubleshooting attachments must be reviewed
\- log export must be audited
\- log exposure must trigger incident response
\- logs do not replace audit

A system that logs carelessly can fail securely even when its business logic is correct.
