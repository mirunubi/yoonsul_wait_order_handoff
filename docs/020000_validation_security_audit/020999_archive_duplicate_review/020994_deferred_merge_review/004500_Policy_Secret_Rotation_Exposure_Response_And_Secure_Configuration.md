# 004500_Policy_Secret_Rotation_Exposure_Response_And_Secure_Configuration

\#\# 1\. Purpose

This document defines the secret rotation, secret exposure response, and secure configuration policy for the Yoonsul Wait/Order Handoff project.

The project must treat secrets, credentials, service keys, API tokens, webhook signing keys, payment configuration, POS/KDS bridge credentials, and production configuration as security-critical assets.

Secret exposure is not a minor coding mistake.

Secret exposure is a security incident.

\---

\#\# 2\. Scope

This policy applies to:

\- API keys
\- service role keys
\- database credentials
\- Supabase keys
\- payment gateway credentials
\- webhook signing secrets
\- POS bridge credentials
\- KDS bridge credentials
\- local agent credentials
\- CI / DI provider credentials
\- admin tokens
\- OAuth client secrets
\- deployment tokens
\- cloud provider keys
\- monitoring tokens
\- log export credentials
\- production environment variables
\- staging environment variables
\- local development secrets

This document does not define the exact vendor-specific secret manager.

It defines the mandatory handling rules that later implementation, deployment, CI/CD, and operation documents must follow.

\---

\#\# 3\. Core Principle

Secrets must never become project content.

The project must follow this rule:

\> A secret may configure a runtime, but it must not appear in code, documents, logs, screenshots, prompts, commits, or test data.

Secret handling must be designed as part of architecture, not as developer habit.

\---

\#\# 4\. Secret Classification

Secrets must be classified by risk level.

\#\#\# 4.1 Critical Secrets

Critical secrets include:

\- production database password
\- service role key
\- production payment gateway secret
\- cloud provider root or admin key
\- production CI / DI provider secret
\- production webhook signing key
\- deployment token with production write authority
\- admin access token
\- private signing key

Critical secrets require strict storage, access control, rotation, and incident response.

\---

\#\#\# 4.2 High-Risk Secrets

High-risk secrets include:

\- staging service key
\- POS bridge credential
\- KDS bridge credential
\- local agent trust credential
\- monitoring export token
\- internal API key
\- OAuth client secret
\- SMS provider secret
\- email provider secret
\- storage bucket write credential

High-risk secrets must not be exposed to client applications or documents.

\---

\#\#\# 4.3 Low-Risk Configuration Values

Some configuration values are not secrets but may still be sensitive.

Examples:

\- public API URL
\- project reference id
\- public anon key where designed for client use
\- feature flag name
\- non-sensitive endpoint path
\- local development port
\- test tenant name

Even low-risk configuration must be reviewed before public exposure if it reveals internal architecture or attack surface.

\---

\#\# 5\. Prohibited Secret Handling

The following are prohibited:

\- hardcoding secrets in source code
\- committing \`.env\` files
\- committing real \`.env.local\` files
\- storing secrets in markdown documents
\- storing secrets in architecture diagrams
\- storing secrets in screenshots
\- pasting secrets into prompts
\- pasting secrets into issue trackers
\- pasting secrets into chat logs
\- logging secrets
\- logging full tokens
\- logging raw authorization headers
\- logging database connection strings
\- storing production secrets in local examples
\- using production secrets in unit tests
\- exposing service role keys to frontend
\- embedding admin keys in Flutter, web, mobile, or kiosk clients
\- placing real credentials in sample SQL
\- placing real credentials in README files
\- sending secrets through ordinary email or messenger without approved secure channel

A secret that appears in any of these places must be treated as exposed.

\---

\#\# 6\. Required Secret Handling

The following are required:

\- use environment variables or approved secret manager
\- separate local, development, staging, and production secrets
\- separate client-safe configuration from server-only secrets
\- keep service role keys server-side only
\- use scoped credentials where possible
\- use short-lived credentials where possible
\- rotate secrets periodically according to risk
\- rotate immediately after suspected exposure
\- mask secrets in logs
\- mask secrets in admin UI
\- restrict secret access by role
\- audit secret access where possible
\- audit secret rotation
\- document secret owner
\- document rotation trigger
\- document recovery procedure
\- maintain \`.env.example\` with dummy values only

\---

\#\# 7\. Client-Side Secret Boundary

Client applications must never contain server-only secrets.

This applies to:

\- customer web
\- staff web
\- admin web
\- Flutter app
\- kiosk UI
\- store tablet UI
\- mobile app
\- public waiting/order page
\- embedded table QR/NFC page

Client-side applications may only contain values that are intentionally safe for client exposure.

Server-only values must remain in:

\- backend runtime
\- edge function
\- server API
\- secure worker
\- deployment secret store
\- controlled server environment

If a key can mutate sensitive data directly, it must not be placed in client code.

\---

\#\# 8\. Service Role Key Policy

Service role keys are critical secrets.

Service role keys must:

\- never be exposed to frontend
\- never be committed
\- never be copied into documentation
\- never be used in client-side Flutter or web code
\- never be used in screenshots
\- never be pasted into prompts
\- be stored only in approved server-side runtime configuration
\- be rotated immediately if exposed
\- be access-restricted to necessary backend services only

Any exposure of a service role key must be treated as a critical security incident.

\---

\#\# 9\. \`.env\` And Configuration File Policy

The project may use local \`.env\` files for development.

However:

\- \`.env\` must be gitignored
\- \`.env.local\` must be gitignored
\- \`.env.production\` must not be committed
\- \`.env.staging\` must not be committed
\- \`.env.example\` may be committed only with dummy values
\- real values must not appear in sample configuration
\- developers must not paste real \`.env\` content into chat or documents

Example allowed \`.env.example\` pattern:

    SUPABASE\_URL=https://example.supabase.co
    SUPABASE\_ANON\_KEY=replace\_with\_dummy\_anon\_key
    SUPABASE\_SERVICE\_ROLE\_KEY=never\_put\_real\_value\_here
    PAYMENT\_PROVIDER\_SECRET=replace\_with\_dummy\_secret
    WEBHOOK\_SIGNING\_SECRET=replace\_with\_dummy\_secret

The example must clearly show structure without exposing real values.

\---

\#\# 10\. Secret Rotation Trigger

Secrets must be rotated when:

\- exposure is confirmed
\- exposure is suspected
\- secret appears in commit history
\- secret appears in screenshot
\- secret appears in prompt or chat
\- secret appears in log
\- secret appears in issue tracker
\- secret appears in documentation
\- developer device is lost
\- staff access is terminated
\- vendor access changes
\- production incident occurs
\- abnormal access is detected
\- periodic rotation interval is reached
\- system owner decides risk has changed

Suspicion is enough to trigger rotation.

Proof is not required before initial containment.

\---

\#\# 11\. Secret Exposure Response

If a secret may have been exposed, the response must follow this order:

1\. Stop further exposure.
2\. Identify the exposed secret type.
3\. Classify risk level.
4\. Rotate or revoke the secret.
5\. Confirm the old secret no longer works.
6\. Identify affected runtime.
7\. Search source code.
8\. Search commit history.
9\. Search documents.
10\. Search logs.
11\. Search screenshots.
12\. Search prompts or chat records where relevant.
13\. Identify whether unauthorized access occurred.
14\. Create security incident record.
15\. Record evidence.
16\. Review root cause.
17\. Update prevention rule.
18\. Close incident only after verification.

Deleting the visible secret is not enough.

Rotation and verification are required.

\---

\#\# 12\. Commit History Exposure Policy

If a secret was committed to git, deleting the file in a later commit is not enough.

The project must assume the secret remains exposed through history.

Required actions:

\- rotate the exposed secret
\- invalidate the old secret
\- search repository history
\- check remote repository exposure
\- check forks or clones where applicable
\- decide whether history rewrite is required
\- document incident
\- add prevention rule
\- add or update secret scanning where possible

The priority is to make the old secret unusable.

History cleanup may reduce exposure but does not replace rotation.

\---

\#\# 13\. Log Exposure Policy

Logs must not contain secrets.

The following must be masked before logging:

\- access tokens
\- refresh tokens
\- API keys
\- service role keys
\- payment secrets
\- webhook signing secrets
\- authorization headers
\- database connection strings
\- CI / DI values
\- full identity linkage values

If a log contains a secret:

\- rotate the secret
\- restrict log access
\- purge or quarantine log if possible
\- document who may have accessed the log
\- create incident record
\- update logging rule

Logs are not safe storage.

\---

\#\# 14\. Screenshot And Screen Sharing Policy

Screenshots may accidentally expose secrets.

The following must be hidden before screenshots:

\- \`.env\` values
\- API key values
\- Supabase service role key
\- database password
\- payment provider secret
\- webhook signing secret
\- admin token
\- OAuth client secret
\- production connection string
\- CI / DI raw values
\- customer personal identifiers

If a screenshot containing a secret is shared, the secret must be rotated.

Screenshot deletion alone is not enough.

\---

\#\# 15\. Prompt And AI Tool Secret Policy

Secrets must not be pasted into AI prompts.

The following must not be shared with AI tools:

\- real service role key
\- real database password
\- real payment secret
\- real webhook secret
\- real OAuth client secret
\- real admin token
\- real production \`.env\`
\- raw CI / DI values
\- full customer identity data
\- production connection strings

AI tools may be given:

\- dummy values
\- masked values
\- example structure
\- error messages with secrets removed
\- configuration names without values

If a real secret is pasted into an AI tool, treat it as exposed and rotate it.

\---

\#\# 16\. Secure Configuration Change Policy

Configuration changes can affect security.

The following configuration changes are security-sensitive:

\- secret value change
\- webhook endpoint change
\- webhook signing secret change
\- payment provider setting change
\- POS bridge credential change
\- KDS bridge credential change
\- local agent trust credential change
\- tenant isolation rule change
\- RLS policy change
\- role permission change
\- support access policy change
\- degraded mode policy change
\- audit retention change
\- log masking rule change
\- production environment variable change

Security-sensitive configuration changes require:

\- actor identity
\- authority validation
\- change reason
\- before/after reference
\- approval where required
\- rollback or recovery plan where applicable
\- audit event

Configuration must not be changed silently.

\---

\#\# 17\. Environment Separation Policy

The project must separate environments.

Required environments:

\- local
\- development
\- staging
\- production

Each environment must have separate:

\- database
\- secret values
\- payment provider mode
\- webhook secret
\- deployment token
\- storage bucket where applicable
\- logging destination where applicable
\- test data
\- tenant/store data

Production secrets must not be used in local, development, or staging.

Production data must not be copied into lower environments without masking or approved procedure.

\---

\#\# 18\. Payment Secret Policy

Payment-related secrets are high-risk or critical.

Payment secrets must:

\- remain server-side
\- never be stored in client code
\- never be logged
\- never be committed
\- never be placed in markdown
\- never be pasted into prompts
\- use vendor-recommended rotation
\- be rotated after exposure
\- be separated by environment
\- be access-restricted
\- be audited where possible

Payment token handling must follow the payment provider boundary.

The project must not store sensitive payment credentials unless explicitly required and approved.

\---

\#\# 19\. POS / KDS Bridge Credential Policy

POS/KDS bridge credentials protect operational state.

Bridge credentials must:

\- be scoped by tenant/store where possible
\- be separated by environment
\- be rotated if exposed
\- be unavailable to customer-side clients
\- be unavailable to ordinary staff UI
\- be masked in logs
\- be audited on change
\- be invalidated when bridge device or service is retired

Bridge credential exposure may allow false ticket, false status, replay, or degraded-mode abuse.

Therefore, bridge credential exposure must be treated as a security incident.

\---

\#\# 20\. Local Agent Credential Policy

Local Agent credentials must be scoped and revocable.

Local Agent credentials must not allow broad central mutation.

Local Agent credentials should be limited to:

\- store-specific context
\- allowed relay methods
\- allowed degraded operation reporting
\- allowed evidence upload
\- allowed queue sync
\- allowed health report

Local Agent credentials must not allow:

\- cross-tenant access
\- cross-store access unless explicitly authorized
\- payment correction
\- refund execution
\- settlement finalization
\- audit deletion
\- support access escalation

If a Local Agent device is lost, replaced, or suspected compromised, its credential must be revoked or rotated.

\---

\#\# 21\. Access To Secrets

Secret access must follow least privilege.

Access should be granted only to:

\- responsible backend operator
\- deployment owner
\- security owner
\- authorized emergency responder
\- approved CI/CD runtime
\- approved production runtime

Secret access must not be given to:

\- ordinary store staff
\- ordinary kitchen staff
\- customer support without need
\- frontend-only runtime
\- public client
\- documentation system
\- unmanaged personal device

Where possible, secret access should be logged.

\---

\#\# 22\. Rotation Evidence

Secret rotation must create evidence.

Rotation evidence should include:

\- secret name or reference
\- environment
\- risk level
\- rotation reason
\- rotation actor
\- rotation time
\- old secret invalidation confirmation
\- affected service
\- deployment confirmation
\- verification result
\- incident reference if applicable

The actual secret value must not be stored in evidence.

Evidence records that a secret changed.

Evidence must not reveal the secret.

\---

\#\# 23\. Incident Record Requirements

A secret exposure incident record must include:

\- incident id
\- discovered time
\- discovered by
\- secret type
\- environment
\- affected runtime
\- exposure location
\- exposure duration if known
\- rotation action
\- verification action
\- suspected access if any
\- recovery evidence
\- prevention update
\- closure reason

Incident record must not include the secret value.

\---

\#\# 24\. Prevention Controls

The project should apply prevention controls where possible:

\- \`.gitignore\` for secret files
\- \`.env.example\` with dummy values
\- pre-commit secret scanning
\- CI secret scanning
\- repository secret scanning
\- log masking
\- screenshot review habit
\- role-based secret access
\- production/development environment separation
\- server-only service role key usage
\- code review checklist
\- deployment checklist
\- incident drill

Prevention controls reduce risk but do not replace rotation after exposure.

\---

\#\# 25\. Secure Coding Checklist

Before code or documentation is committed, confirm:

\- No real secret appears in source code.
\- No real secret appears in markdown.
\- No real secret appears in sample SQL.
\- No real secret appears in screenshots.
\- No real secret appears in test fixtures.
\- No \`.env\` file is staged.
\- \`.env.example\` contains dummy values only.
\- Service role key is server-side only.
\- Client code uses only client-safe values.
\- Logs mask sensitive values.
\- Error messages do not expose secret values.
\- Payment secrets remain server-side.
\- POS/KDS bridge credentials are scoped.
\- Local Agent credentials are scoped.
\- Production secrets are not used in local or staging.
\- Secret rotation process is documented.

If any item fails, commit or deployment must stop.

\---

\#\# 26\. Non-Goals

This document does not define:

\- final vendor secret manager
\- final CI/CD product
\- final secret scanning product
\- final cloud provider IAM design
\- final payment provider integration
\- final POS vendor credential format
\- final KDS vendor credential format
\- final incident response runbook
\- final penetration testing plan

Those must be defined in later implementation, deployment, or security operation documents.

\---

\#\# 27\. Readiness Check

This policy is ready when the project can answer:

1\. Which values are secrets?
2\. Which values are safe client configuration?
3\. Where are production secrets stored?
4\. Who can access production secrets?
5\. How are secrets rotated?
6\. What happens if a secret appears in git?
7\. What happens if a secret appears in a screenshot?
8\. What happens if a secret appears in a prompt?
9\. How are logs masked?
10\. Which keys are server-only?
11\. Which credentials are scoped by tenant/store?
12\. How is Local Agent credential revocation handled?
13\. How is bridge credential exposure handled?
14\. How is payment secret exposure handled?
15\. How is rotation evidence recorded?
16\. How is old secret invalidation verified?

If these questions cannot be answered, implementation must not proceed.

\---

\#\# 28\. Conclusion

Secret management is not only a deployment concern.

It is part of product security, operational trust, incident response, and financial-grade discipline.

The Yoonsul Wait/Order Handoff project must preserve the following rules:

\- secrets must not become project content
\- service role keys are server-only
\- production secrets must not be used in local examples
\- \`.env.example\` must use dummy values
\- exposure suspicion triggers rotation
\- deletion is not recovery
\- rotation must be verified
\- configuration changes must be audited
\- secret evidence must not reveal the secret
\- secure coding must prevent accidental exposure

A system that cannot protect its secrets cannot protect customer trust, transaction integrity, or operational continuity.
