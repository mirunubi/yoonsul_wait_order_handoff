# 04590_Policy_Webhook_Signature_Idempotency_Replay_And_External_Integration_Security

\#\# 1\. Purpose

This document defines the webhook, signature verification, idempotency, replay protection, and external integration security policy for the Yoonsul Wait/Order Handoff project.

External integration is a high-risk boundary.

The project may connect with POS vendors, KDS vendors, payment providers, CI / DI providers, notification providers, delivery platforms, reservation platforms, CRM tools, support tools, analytics tools, and future SaaS tenant integrations.

Every external event must be treated as untrusted until verified.

\---

\#\# 2\. Scope

This policy applies to:

\- payment webhooks
\- POS integration webhooks
\- KDS integration webhooks
\- delivery platform callbacks
\- CI / DI provider callbacks
\- SMS provider callbacks
\- email provider callbacks
\- push notification provider callbacks
\- reservation platform callbacks
\- support tool webhooks
\- CRM integration webhooks
\- analytics export callbacks
\- partner API callbacks
\- bridge runtime inbound calls
\- local agent sync callbacks
\- retry processing
\- replay processing
\- duplicate event handling
\- external signature verification
\- external credential rotation

This document does not define the final webhook endpoint implementation.

It defines the mandatory external integration security boundary that later API, bridge, payment, POS/KDS, notification, identity, and deployment documents must follow.

\---

\#\# 3\. Core Principle

External events are not trusted by default.

The project must follow this rule:

\> An external event may request a state change, but it must not mutate trusted state until identity, signature, context, freshness, idempotency, and authority are verified.

Integration convenience must not bypass runtime authority.

\---

\#\# 4\. External Integration Trust Boundary

Every external integration must cross a trust boundary.

The system must verify:

\- external provider identity
\- endpoint purpose
\- tenant context where applicable
\- store context where applicable
\- runtime context where applicable
\- event type
\- event timestamp
\- signature or equivalent authenticity proof
\- event id
\- idempotency key
\- replay risk
\- allowed transition
\- affected resource
\- audit requirement

An integration event without sufficient verification must be rejected or quarantined.

\---

\#\# 5\. Webhook Endpoint Classification

Webhook endpoints must be classified by risk.

\#\#\# 5.1 Critical Webhook

Critical webhook includes:

\- payment confirmation
\- refund confirmation
\- payment failure
\- payment cancellation
\- CI / DI verification result
\- identity provider callback
\- POS accepted order mutation
\- settlement-related callback
\- security incident callback
\- secret rotation callback where applicable

Critical webhooks require strict verification, idempotency, replay protection, and audit.

\---

\#\#\# 5.2 High-Risk Webhook

High-risk webhook includes:

\- POS status callback
\- KDS status callback
\- delivery order status callback
\- reservation state callback
\- customer notification delivery result
\- support case state callback
\- local agent sync callback
\- bridge queue callback

High-risk webhooks require verification and scoped mutation.

\---

\#\#\# 5.3 Low-Risk Webhook

Low-risk webhook may include:

\- non-sensitive delivery status summary
\- non-sensitive analytics callback
\- non-sensitive marketing event
\- test-mode notification event

Low-risk does not mean no validation.

Even low-risk webhook must not allow privilege escalation or cross-context leakage.

\---

\#\# 6\. Signature Verification Policy

Webhook signature verification is mandatory where the provider supports it.

Signature verification should confirm:

\- sender authenticity
\- payload integrity
\- timestamp freshness where supported
\- signing secret validity
\- expected provider
\- expected endpoint

Signature verification must be performed server-side.

Signature verification must not expose signing secrets in logs, errors, documents, screenshots, prompts, or test data.

Invalid signature must reject or quarantine the event.

\---

\#\# 7\. Unsigned Webhook Policy

Unsigned webhook is risky.

If a provider does not support signature verification, the system must apply compensating controls.

Compensating controls may include:

\- provider IP allowlist where stable and reliable
\- mutual TLS where available
\- provider-issued event id verification
\- server-to-server confirmation pull
\- strict endpoint secrecy
\- short-lived callback token
\- tenant/store mapping validation
\- limited allowed action
\- quarantine before mutation
\- manual review for high-risk events

Unsigned webhook must not directly perform high-risk mutation.

\---

\#\# 8\. Webhook Secret Handling

Webhook signing secrets are high-risk secrets.

Webhook secrets must:

\- remain server-side
\- be separated by environment
\- be rotated if exposed
\- never be committed
\- never be logged
\- never be placed in markdown
\- never be pasted into prompts
\- never be exposed to frontend
\- be stored in approved secret storage
\- have owner and rotation policy

Webhook secret exposure must trigger secret exposure response.

\---

\#\# 9\. Environment Separation

Webhook endpoints and secrets must be separated by environment.

Required separation:

\- local test webhook
\- development webhook
\- staging webhook
\- production webhook

Production webhook secret must not be used in:

\- local
\- development
\- staging
\- documentation
\- examples
\- tests
\- AI prompts

Test webhook events must not mutate production.

Production webhook events must not be sent to development endpoints.

\---

\#\# 10\. Idempotency Policy

Every external event capable of mutation must be idempotent.

Idempotency is required for:

\- payment confirmation
\- refund confirmation
\- POS accepted order event
\- KDS ticket status event
\- delivery order state event
\- identity verification result
\- customer notification event where state-changing
\- support case callback
\- local agent sync event
\- retry event
\- replay-derived event where applicable

Duplicate event must not create duplicate mutation.

The system should record processed event id or idempotency key.

\---

\#\# 11\. Duplicate Event Handling

Duplicate external events are normal.

The system must handle duplicates safely.

Duplicate event may occur because of:

\- provider retry
\- network timeout
\- webhook delivery retry
\- bridge retry
\- local agent retry
\- queue replay
\- manual resend
\- provider delayed delivery
\- event ordering issue

When duplicate is detected, the system may:

\- return previous result
\- ignore safely
\- mark duplicate
\- append duplicate audit event where sensitive
\- compare payload for inconsistency
\- quarantine if duplicate payload differs

Duplicate event must not create duplicate payment, refund, ticket, order, or settlement mutation.

\---

\#\# 12\. Replay Protection Policy

Replay attack or replay error must be prevented.

Replay risk exists when:

\- old webhook is resent
\- captured event is reused
\- delayed event arrives after state changed
\- local queue replays stale event
\- bridge retries beyond safe window
\- provider sends duplicate with old timestamp
\- attacker attempts reused signature

Replay protection may include:

\- timestamp freshness check
\- nonce where supported
\- event id uniqueness
\- idempotency key
\- processed event registry
\- allowed time window
\- state transition validation
\- provider confirmation pull
\- quarantine of stale events

Replay must not overwrite current verified state.

\---

\#\# 13\. Event Freshness Policy

External events must be evaluated for freshness.

Freshness should consider:

\- event created timestamp
\- provider sent timestamp
\- server received timestamp
\- retry count
\- allowed delay window
\- current resource state
\- state transition validity

Old events must not blindly mutate current state.

Stale event may be:

\- rejected
\- ignored
\- quarantined
\- used only as evidence
\- marked for reconciliation

Freshness failure must be auditable for high-risk events.

\---

\#\# 14\. State Transition Validation

A verified webhook still must pass state transition validation.

Signature verification proves origin and integrity.

It does not prove the requested state change is allowed.

The system must validate:

\- current state
\- requested next state
\- event type
\- runtime authority
\- tenant context
\- store context
\- payment or order reference
\- duplicate status
\- replay risk
\- recovery requirement

Invalid transition must be rejected or quarantined.

\---

\#\# 15\. Context Validation

External events must include or derive valid context.

Context may include:

\- tenant id
\- store id
\- provider account id
\- external merchant id
\- external store id
\- POS terminal id
\- KDS device id
\- payment reference
\- order reference
\- customer reference where needed
\- environment marker

Context mismatch must be treated as security-sensitive.

Context mismatch must not be silently corrected.

\---

\#\# 16\. Provider Account Mapping Policy

External provider account must be mapped safely.

Mapping may include:

\- tenant to provider merchant id
\- store to provider store id
\- POS terminal to store id
\- KDS runtime to store id
\- payment gateway account to tenant
\- notification sender to tenant
\- CI / DI provider project to tenant
\- delivery platform account to store

Mapping must be server-side and auditable.

External provider id alone must not grant authority without validation.

\---

\#\# 17\. Payment Webhook Policy

Payment webhook is critical.

Payment webhook must verify:

\- provider identity
\- signature
\- event id
\- payment reference
\- amount
\- currency
\- merchant or tenant mapping
\- store mapping where applicable
\- payment state
\- idempotency
\- duplicate status
\- replay risk
\- current payment state
\- audit requirement

Payment webhook must not expose secrets in logs.

Invalid payment webhook must not mutate payment truth.

\---

\#\# 18\. Refund Webhook Policy

Refund webhook is critical.

Refund webhook must verify:

\- provider identity
\- signature
\- refund reference
\- original payment reference
\- amount
\- currency
\- tenant mapping
\- store mapping where applicable
\- refund state
\- idempotency
\- duplicate status
\- current refund state
\- audit requirement

Refund webhook must not create duplicate refund.

Refund webhook must not silently correct settlement without approved reconciliation.

\---

\#\# 19\. POS Webhook Policy

POS webhook may affect transaction and order authority.

POS webhook must verify:

\- POS provider identity
\- store mapping
\- terminal or service identity
\- accepted order reference
\- transaction reference where applicable
\- event id
\- idempotency
\- allowed state transition
\- replay risk
\- bridge validation
\- audit requirement

POS webhook must not create KDS ticket without accepted order boundary.

POS webhook must not cross tenant or store context.

\---

\#\# 20\. KDS Webhook Policy

KDS webhook may affect kitchen execution state.

KDS webhook must verify:

\- KDS provider identity
\- store mapping
\- device or runtime identity
\- ticket reference
\- event id
\- idempotency
\- allowed kitchen transition
\- replay risk
\- audit requirement

KDS webhook must not mutate payment, refund, or settlement state.

KDS webhook must not expose unnecessary customer identity.

\---

\#\# 21\. CI / DI Provider Callback Policy

CI / DI provider callback is critical identity data.

CI / DI callback must verify:

\- provider identity
\- signature or equivalent verification
\- request/session binding
\- customer account binding where applicable
\- event id
\- freshness
\- idempotency
\- consent boundary
\- tenant context
\- audit requirement

CI / DI values must not be logged raw.

CI / DI callback failure must not expose identity details in error response.

\---

\#\# 22\. Notification Provider Callback Policy

Notification callbacks may include SMS, email, push, or messenger delivery status.

Notification callback must verify:

\- provider identity
\- message reference
\- tenant context
\- customer reference masked where possible
\- delivery result
\- idempotency
\- event freshness

Notification callback must not expose full message content unnecessarily.

Notification delivery failure must not leak phone number or email in logs.

\---

\#\# 23\. Delivery Platform Callback Policy

Delivery platform callback may affect order state.

Delivery callback must verify:

\- platform identity
\- store mapping
\- order reference
\- external order reference
\- event id
\- state transition
\- idempotency
\- replay risk
\- audit requirement

Delivery platform state must not directly override POS payment truth.

Delivery callback mismatch must create reconciliation or review event.

\---

\#\# 24\. Support Tool Webhook Policy

Support tool webhook may affect support cases.

Support webhook must verify:

\- provider identity
\- case reference
\- tenant context
\- store context where applicable
\- actor or system identity
\- event id
\- idempotency
\- allowed case transition
\- data masking requirement
\- audit requirement

Support webhook must not create hidden support access or unmask identity without audit.

\---

\#\# 25\. Webhook Error Response Policy

Webhook error responses must be safe.

Webhook responses must not reveal:

\- signing secret
\- signature validation internals
\- raw payload secrets
\- database schema
\- stack trace
\- raw CI / DI
\- payment secret
\- tenant record existence
\- store record existence
\- full authorization logic

Safe response categories include:

\- accepted
\- duplicate
\- invalid signature
\- invalid event
\- unauthorized
\- forbidden
\- stale event
\- conflict
\- queued
\- quarantined
\- retry later

Detailed diagnostics must remain in restricted logs.

\---

\#\# 26\. Quarantine Policy

Unsafe external events must be quarantined when rejection alone is insufficient.

Quarantine may be required for:

\- signature valid but transition invalid
\- context mismatch
\- stale but potentially relevant event
\- duplicate event with changed payload
\- payment amount mismatch
\- refund amount mismatch
\- POS/KDS state conflict
\- provider mapping mismatch
\- degraded mode conflict
\- replay risk
\- suspicious source

Quarantined event must not mutate final state.

Quarantine must create evidence and audit event.

\---

\#\# 27\. Server-To-Server Confirmation Pull

For high-risk uncertainty, the system should confirm with provider directly where possible.

Confirmation pull may be used for:

\- payment status uncertainty
\- refund status uncertainty
\- CI / DI verification uncertainty
\- POS accepted order uncertainty
\- delivery state uncertainty
\- duplicate or stale webhook
\- suspicious payload mismatch

Confirmation pull must use server-side credentials.

Confirmation result must be audited where high-risk.

\---

\#\# 28\. Retry Policy

Webhook retry must be safe.

Retry may occur from provider or internal queue.

Retry must preserve:

\- event id
\- idempotency key
\- original event timestamp
\- retry count
\- correlation id
\- tenant/store context
\- original payload hash where applicable
\- result history

Retry must not create duplicate mutation.

Excessive retry must trigger review or quarantine.

\---

\#\# 29\. Payload Storage Policy

Webhook payload may contain sensitive data.

Raw payload storage must be minimized.

If payload is stored for evidence:

\- store only where necessary
\- mask secrets
\- mask raw CI / DI
\- mask payment tokens
\- restrict access
\- set retention rule
\- link to audit event
\- avoid unrelated data

For many cases, storing normalized safe fields is preferable to storing raw payload.

\---

\#\# 30\. Webhook Logging Policy

Webhook logs must be safe.

Logs may include:

\- event id
\- provider
\- endpoint category
\- tenant/store scope
\- result
\- rejection reason category
\- idempotency status
\- replay status
\- correlation id
\- timestamp

Logs must not include:

\- signing secret
\- raw authorization header
\- raw CI / DI
\- payment secret
\- raw payment token
\- full sensitive payload
\- database credentials
\- service role key

Webhook log exposure must trigger incident response when sensitive data is leaked.

\---

\#\# 31\. Webhook Audit Requirements

Audit is required for:

\- critical webhook received
\- critical webhook accepted
\- critical webhook rejected
\- invalid signature
\- duplicate event detected
\- stale event detected
\- replay risk detected
\- context mismatch
\- payment webhook mutation
\- refund webhook mutation
\- CI / DI callback processed
\- POS accepted order callback processed
\- KDS state callback processed
\- webhook quarantined
\- server-to-server confirmation pull
\- webhook secret rotation

Audit must include:

\- provider
\- endpoint category
\- event id
\- tenant id where applicable
\- store id where applicable
\- affected resource
\- action
\- result
\- reason
\- idempotency status
\- replay status
\- timestamp
\- evidence reference where applicable

Audit must not store secrets.

\---

\#\# 32\. External Credential Rotation

External integration credentials must be rotatable.

Rotation may be required for:

\- webhook signing secret
\- provider API key
\- POS bridge credential
\- KDS bridge credential
\- payment gateway credential
\- CI / DI provider credential
\- notification provider credential
\- delivery platform credential
\- support tool credential

Rotation must include:

\- new credential deployment
\- old credential invalidation
\- dependent endpoint update
\- verification
\- audit event
\- incident reference where applicable

Credential rotation must not break production without rollback or containment plan.

\---

\#\# 33\. External Integration Access Review

External integrations must be reviewed periodically.

Review should check:

\- active integrations
\- credential owner
\- credential age
\- unused integrations
\- tenant/store mapping
\- webhook endpoint list
\- allowed event types
\- allowed mutation scope
\- log masking
\- audit coverage
\- last rotation date
\- incident history

Unused or stale integrations should be disabled or removed.

\---

\#\# 34\. Development And Testing Policy

Webhook testing must not use production secrets or production customer data.

Testing should use:

\- dummy payloads
\- test provider mode
\- test signatures
\- synthetic tenant/store ids
\- synthetic customer references
\- synthetic payment references
\- staging endpoint
\- safe replay samples

Production webhook payloads must not be pasted into prompts, issues, or documentation without redaction.

\---

\#\# 35\. Secure Webhook Checklist

Before implementation, confirm:

\- External events are untrusted by default.
\- Critical webhooks verify signature.
\- Unsigned webhooks have compensating controls.
\- Webhook secrets are server-side only.
\- Environments are separated.
\- Mutation-capable events are idempotent.
\- Duplicate events do not duplicate mutation.
\- Replay protection exists.
\- Event freshness is checked.
\- State transition is validated.
\- Tenant/store context is validated.
\- Provider account mapping is server-side.
\- Payment webhook is critical.
\- Refund webhook is critical.
\- POS webhook cannot bypass accepted order boundary.
\- KDS webhook cannot mutate payment.
\- CI / DI callback does not log raw values.
\- Unsafe events can be quarantined.
\- Webhook logs are masked.
\- Webhook audit exists.
\- External credentials are rotatable.

If any item fails, implementation must not proceed.

\---

\#\# 36\. Non-Goals

This document does not define:

\- final webhook endpoint names
\- final signature algorithm
\- final provider list
\- final queue technology
\- final raw payload storage schema
\- final payment provider API
\- final POS vendor API
\- final KDS vendor API
\- final CI / DI provider API
\- final notification provider API
\- final delivery platform API
\- final support tool integration
\- final incident response runbook

Those must be defined in later integration, payment, identity, POS/KDS, notification, infrastructure, or implementation documents.

\---

\#\# 37\. Readiness Check

This policy is ready when the project can answer:

1\. Which webhook endpoints exist?
2\. Which webhooks are critical?
3\. Which webhooks require signature verification?
4\. What happens if signature verification fails?
5\. How are unsigned webhooks controlled?
6\. Where are webhook secrets stored?
7\. Are webhook secrets separated by environment?
8\. How are duplicate webhooks handled?
9\. How is idempotency enforced?
10\. How is replay prevented?
11\. How is event freshness checked?
12\. How is tenant/store context validated?
13\. How is provider account mapping maintained?
14\. How are payment webhooks verified?
15\. How are refund webhooks verified?
16\. How are POS/KDS webhooks bounded?
17\. How are CI / DI callbacks protected?
18\. When is webhook quarantine used?
19\. How are webhook logs masked?
20\. How are webhook events audited?
21\. How are external credentials rotated?

If these questions cannot be answered, implementation must not proceed.

\---

\#\# 38\. Conclusion

External integration is one of the most important security boundaries in the Yoonsul Wait/Order Handoff system.

A webhook or callback may look like a simple message, but it may affect payment, refund, identity, POS/KDS state, support access, customer notification, degraded recovery, or settlement.

Therefore, the system must preserve the following rules:

\- external events are untrusted by default
\- signature verification is mandatory where supported
\- unsigned webhooks require compensating controls
\- webhook secrets are server-side only
\- environments are separated
\- mutation events are idempotent
\- duplicates must not duplicate mutation
\- replay must not overwrite current state
\- stale events must be reviewed or quarantined
\- context mismatch must not be silently corrected
\- payment and refund webhooks are critical
\- KDS callbacks cannot mutate payment
\- CI / DI callbacks must not leak identity
\- unsafe events are quarantined
\- webhook logs are masked
\- webhook processing is audited
\- external credentials are rotatable

A secure SaaS platform does not merely receive external events.

It verifies, scopes, records, and controls them before trust is granted.
