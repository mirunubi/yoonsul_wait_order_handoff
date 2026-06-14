# 09580 AI Daemon Security Monitoring Agent And Autonomous Containment Policy

## 1. Purpose

This document adds the AI daemon-based security monitoring agent architecture to the Foundation layer.

The purpose is to define how a lightweight background monitoring agent may observe structured logs, alert streams, provider callbacks, POS events, settlement anomalies, membership conflicts, KDS mismatches, AI governance risks, pgvector similarity signals, and integration drift in near real time.

The system must not depend on a human continuously watching logs.

A financial-grade SaaS operating system requires automated monitoring, structured detection, controlled containment, alerting, evidence capture, audit linkage, and pgvector-assisted anomaly review.

This document defines the policy boundary for an AI-assisted monitoring daemon.

It does not authorize coding.

Coding remains deferred unless a specific package has `CODING_ALLOWED`, a completed handoff record, a narrow work order, required tests, and review approval.

---

## 2. Scope

This policy applies to future planning for:

1. AI monitoring daemon
2. Rule-based security filter
3. Real-time structured log pipeline
4. Alert event stream
5. pgvector anomaly similarity search
6. Autonomous containment trigger
7. Token/session invalidation candidate
8. Provider gateway temporary block candidate
9. POS module quarantine candidate
10. Membership/coupon/wallet value mutation block
11. Customer identity link block
12. KDS duplicate ticket block
13. External projection block
14. Support/admin authority block
15. AI output block
16. Evidence packet auto-creation
17. Audit event auto-linking
18. Owner/HQ emergency alerting
19. Incident report generation
20. Patent reinforcement material

This policy applies across all integration domains.

It is not limited to payment or settlement.

---

## 3. Core Principle

The monitoring agent may detect, classify, summarize, and trigger pre-approved containment controls.

The monitoring agent must not become unrestricted runtime authority.

The correct architecture is:

- rules detect obvious threats quickly
- pgvector helps identify similar patterns
- AI summarizes and classifies uncertain events
- containment blocks dangerous propagation
- alerts notify responsible actors
- evidence and audit preserve accountability
- human or authorized workflow releases containment

The agent may close the door.

The agent must not rewrite the truth.

---

## 4. AI Daemon Definition

An AI daemon is a lightweight background monitoring process or service that observes controlled event streams and performs security/operational analysis.

It may be implemented later as:

- backend worker
- queue consumer
- scheduled monitor
- edge worker
- containerized daemon
- Supabase-adjacent service
- log pipeline consumer
- event bus subscriber

Implementation form is deferred.

The Foundation requirement is that the agent must operate under controlled contracts, not free-form access to all data.

---

## 5. Monitoring Pipeline Concept

The conceptual monitoring pipeline is:

    [External POS / Provider / KDS / Membership / Support / AI / Projection]
                                  |
                                  v
                     [Structured Event And Log Collector]
                                  |
                                  v
                         [Central Event Queue]
                                  |
                                  v
             [Rule-Based Fast Filter And Severity Classifier]
                                  |
                    ambiguous / pattern-sensitive events only
                                  |
                                  v
                  [pgvector Similarity And Anomaly Retrieval]
                                  |
                                  v
                     [AI Monitoring Daemon Review Layer]
                                  |
          -------------------------------------------------
          |                                               |
          v                                               v
    [Pre-Approved Containment Control]              [Alert / Evidence / Audit]
          |                                               |
          v                                               v
    [Block / Quarantine / Hold]                    [Owner / HQ / Domain Route]

The AI daemon does not directly mutate business truth.

It triggers pre-approved containment controls only when policy thresholds are met.

---

## 6. Two-Stage Detection Rule

The monitoring architecture must use two-stage detection.

### Stage 1: Rule-Based Fast Filter

The first stage must be deterministic and fast.

It should detect obvious conditions such as:

- invalid token attempts above threshold
- provider callback signature failure
- duplicate provider callback
- cross-tenant event risk
- cross-store event risk
- malformed POS event
- missing idempotency key
- duplicate coupon/wallet use
- unapproved customer-facing AI output
- restricted data access attempt
- unverified payment capability shown externally
- allergen projection mismatch
- secret-like value in logs
- pgvector restricted source ingestion attempt

Stage 1 must not require LLM reasoning.

### Stage 2: pgvector And AI-Assisted Pattern Review

The second stage is for ambiguous, subtle, or pattern-sensitive events.

It may use:

- pgvector similarity search
- anomaly cluster comparison
- historical incident retrieval
- approved SOP retrieval
- evidence packet similarity
- provider error pattern comparison
- AI-generated internal summary
- AI-suggested alert classification

Stage 2 output is advisory unless connected to a pre-approved containment threshold.

---

## 7. Rule-Based Filter Requirement

The rule-based filter must be the first line of defense.

It must define:

| Field | Required Meaning |
|---|---|
| Rule id | Stable rule identifier |
| Event family | Triggering event |
| Domain | POS, payment, membership, KDS, etc. |
| Threshold | Numeric or state threshold |
| Severity | Default severity |
| Bulkhead | Affected compartment |
| Action | Log, alert, quarantine, contain, block |
| Evidence | Evidence packet requirement |
| Audit | Audit requirement |
| Escalation | Escalation route |
| pgvector use | Whether vector review is needed |
| AI use | Whether AI review is allowed |

Obvious critical events must not wait for AI.

---

## 8. pgvector Similarity Requirement

pgvector must be used for pattern-aware monitoring.

Allowed pgvector use cases:

- similar incident retrieval
- repeated POS anomaly clustering
- provider callback pattern matching
- payment/ledger mismatch similarity
- membership identity conflict similarity
- coupon/wallet duplicate pattern similarity
- KDS/order mismatch clustering
- projection mismatch clustering
- support case similarity
- AI governance incident similarity
- security incident similarity
- SOP/evidence retrieval

pgvector must not be used as final proof.

Similarity score does not equal truth.

---

## 9. AI Monitoring Agent Requirement

The AI monitoring agent may perform controlled review actions.

Allowed actions:

- summarize incident context
- classify likely event family
- suggest severity
- suggest missing evidence
- suggest similar prior incident
- suggest likely affected bulkhead
- suggest escalation route
- draft internal incident report
- draft support/admin note
- draft owner/HQ alert text from approved keys/content
- suggest containment candidate
- identify whether provider evidence is missing

Prohibited actions:

- approve refund
- execute settlement correction
- mutate ledger
- mutate payment state
- mutate membership points
- mutate wallet balance
- mutate coupon state
- link customer identity
- create or complete KDS ticket
- publish external projection
- confirm provider capability
- resolve alert
- release containment
- release quarantine
- suppress critical alert
- expose restricted data
- bypass audit

---

## 10. Autonomous Containment Rule

The system may allow autonomous containment only for pre-approved defensive actions.

Autonomous containment means the agent triggers a defensive block to prevent spread.

Allowed autonomous containment candidates:

| Containment | Meaning |
|---|---|
| `AUTO_BLOCK_TOKEN` | Invalidate scoped token/session |
| `AUTO_BLOCK_PROVIDER_CALLBACK` | Block unverified callback from mutation |
| `AUTO_QUARANTINE_POS_EVENT` | Quarantine suspicious POS event |
| `AUTO_BLOCK_CROSS_TENANT_EVENT` | Block cross-tenant propagation |
| `AUTO_BLOCK_CROSS_STORE_EVENT` | Block cross-store propagation |
| `AUTO_BLOCK_DUPLICATE_VALUE_EVENT` | Block duplicate coupon/wallet/point value event |
| `AUTO_BLOCK_IDENTITY_LINK` | Block risky identity link |
| `AUTO_BLOCK_PROJECTION_PUBLICATION` | Block risky external projection |
| `AUTO_BLOCK_AI_CUSTOMER_OUTPUT` | Block unapproved AI customer-facing output |
| `AUTO_BLOCK_SUPPORT_MUTATION` | Block unauthorized support/admin mutation |
| `AUTO_HOLD_LEDGER_FINALIZATION` | Hold ledger finalization pending review |
| `AUTO_HOLD_SETTLEMENT_ALLOCATION` | Hold settlement allocation pending reconciliation |

Autonomous containment must be reversible through authorized review.

---

## 11. Autonomous Action Boundary

The monitoring agent may trigger containment.

The monitoring agent may not execute irreversible business action.

The following are prohibited as autonomous agent actions:

- final refund approval
- final settlement allocation
- ledger correction posting
- customer compensation issuance
- membership point adjustment
- wallet adjustment
- coupon reissue
- identity merge
- provider capability confirmation
- permanent account ban
- legal/compliance decision
- support case closure
- production content publication
- final incident resolution

The agent can stop harm.

The agent cannot decide final truth.

---

## 12. Session Kill And Token Invalidation Rule

Session/token invalidation is allowed only under pre-approved containment controls.

Required conditions:

- token scope defined
- affected tenant/store/session known
- trigger event classified
- severity threshold met
- audit event created
- evidence packet created or linked
- alert routed
- customer/store impact assessed
- replay/recovery path defined
- false positive release path defined

Session kill must be scoped.

Global shutdown must be avoided unless emergency policy requires it.

---

## 13. Gateway Drop And Temporary Block Rule

Temporary provider/API gateway blocking may be planned as a containment measure.

Examples:

- block payment requests from one compromised store session
- block provider callback mutation until signature verified
- block external POS events from a specific device
- block partner projection publish from one integration route
- block suspicious membership sync source
- block wallet/coupon value mutation path
- block AI output surface

Gateway drop must be:

- scoped
- logged
- auditable
- reversible
- tied to evidence
- tied to alert
- tied to review owner

The system must prefer precise compartment blocking over broad outage.

---

## 14. Incident Report Generation

When containment occurs, the monitoring agent may generate an internal incident report draft.

The report may include:

- incident id
- event family
- alert family
- severity
- affected bulkhead
- affected tenant/store
- affected provider/system
- trigger condition
- rule-based findings
- pgvector similar incidents
- AI summary
- evidence packet ids
- audit event ids
- containment action
- customer impact candidate
- required review
- unresolved questions
- recommended next actions

The report is a draft until reviewed.

AI-generated report content must be marked as derived.

---

## 15. Owner/HQ Emergency Alerting

The system must support owner/HQ emergency alerting for high-risk containment.

Emergency alert content must include:

- what happened
- where it happened
- which bulkhead was contained
- what was automatically blocked
- what evidence was preserved
- whether customer impact is suspected
- what review is required
- what actions are prohibited until review
- link/reference to incident report
- safe next step

Emergency alerts must use approved message keys/content templates.

Sensitive diagnostics must not be sent through insecure channels.

---

## 16. Alert Message Example Boundary

A future alert message may follow this structure:

    Security containment activated.
    Store: {store_display_name}
    Domain: {bulkhead}
    Trigger: {alert_family}
    Action: {containment_action}
    Status: blocked pending review.
    Evidence: {evidence_packet_reference}
    Review required: {review_route}

This is a structural template only.

Actual runtime text must use i18n/message keys or content registry keys.

---

## 17. Daemon Access Boundary

The monitoring daemon must have limited access.

It may read:

- approved structured event metadata
- approved alert metadata
- approved audit metadata
- approved evidence summaries
- approved provider error metadata
- approved SOP/content references
- approved vector metadata

It must not read by default:

- raw payment secrets
- provider secrets
- service role keys
- raw customer payment data
- unmasked identity data
- unrestricted support notes
- raw credentials
- unapproved legal content
- full sensitive payloads
- cross-tenant data outside scope

The daemon must operate under least privilege.

---

## 18. Daemon Output Classification

Daemon outputs must be classified.

| Output State | Meaning |
|---|---|
| `DAEMON_OBSERVATION` | Non-authoritative observation |
| `DAEMON_CLASSIFICATION_DRAFT` | Suggested classification |
| `DAEMON_SEVERITY_SUGGESTION` | Suggested severity |
| `DAEMON_CONTAINMENT_CANDIDATE` | Suggested containment |
| `DAEMON_CONTAINMENT_TRIGGERED` | Pre-approved containment triggered |
| `DAEMON_ALERT_DRAFT` | Draft alert content |
| `DAEMON_INCIDENT_REPORT_DRAFT` | Draft incident report |
| `DAEMON_EVIDENCE_SUMMARY_DERIVED` | Derived evidence summary |
| `DAEMON_REVIEW_REQUIRED` | Human/system review required |
| `DAEMON_AUTHORITY_BLOCKED` | Attempted authority action blocked |

Daemon outputs must not be treated as final truth.

---

## 19. Daemon Audit Requirement

The monitoring daemon must be auditable.

Audit is required for:

- containment trigger
- token/session invalidation
- gateway block
- quarantine activation
- alert suppression suggestion
- incident report creation
- pgvector retrieval used in review
- AI-generated severity suggestion
- restricted source blocked
- false positive override
- containment release request
- human release approval

The daemon itself must be treated as a system actor.

---

## 20. False Positive And Release Rule

Autonomous containment may create false positives.

Therefore, every containment must have a release process.

Release requires:

- review owner
- evidence review
- audit event
- reason code
- affected scope
- customer/store impact review
- replay/recovery plan if needed
- pgvector/AI report marked advisory
- containment release status
- future rule tuning if needed

The daemon must not release its own containment.

---

## 21. Daemon Rule Tuning Governance

Rule thresholds and AI/pgvector behavior must be governed.

Rule tuning must require:

- change request
- reason
- affected domains
- expected false positive/false negative impact
- test evidence
- reviewer
- effective version
- rollback plan
- audit event

The monitoring daemon must not silently change its own detection policy.

---

## 22. Real-Time Versus Near-Real-Time Boundary

The project may describe the monitoring goal as real-time or near-real-time, but implementation must distinguish:

| Mode | Meaning |
|---|---|
| `REAL_TIME_BLOCKING` | Inline blocking before action proceeds |
| `NEAR_REAL_TIME_MONITORING` | Fast asynchronous review after event |
| `BATCH_RECONCILIATION_MONITORING` | Periodic mismatch detection |
| `POST_INCIDENT_ANALYSIS` | After-the-fact analysis |
| `MANUAL_REVIEW_ASSIST` | Human-driven review support |

Not every event should use inline AI.

Critical deterministic rules should block inline.

AI/pgvector may often run near-real-time to avoid latency and cost.

---

## 23. Cost And Latency Control Rule

The monitoring architecture must avoid sending every log to an LLM.

Cost and latency controls include:

- structured log filtering
- severity thresholding
- sampling for low-risk events
- rule-based prefilter
- vectorization of approved metadata only
- pgvector retrieval before LLM
- LLM only for ambiguous/high-risk summaries
- domain-specific prompts/templates
- caching of similar incident patterns
- rate limits
- backpressure handling
- degraded mode without AI

AI monitoring must not make the core system fragile.

---

## 24. Degraded Mode Rule

If AI or pgvector is unavailable, deterministic security controls must still work.

Degraded mode must preserve:

- rule-based filter
- provider callback verification
- token invalidation
- cross-tenant/cross-store block
- idempotency
- quarantine
- containment for critical deterministic triggers
- structured logging
- audit/evidence creation
- alert routing

AI/pgvector absence must not disable core security.

---

## 25. Daemon Event Families

Foundation catalogs must include daemon event families.

| Event Family | Meaning |
|---|---|
| `DAEMON_LOG_STREAM_OBSERVED` | Daemon observed log/event stream |
| `DAEMON_RULE_MATCHED` | Rule-based filter matched |
| `DAEMON_VECTOR_SEARCH_REQUESTED` | pgvector search requested |
| `DAEMON_VECTOR_SIMILARITY_FOUND` | Similar incident found |
| `DAEMON_AI_REVIEW_REQUESTED` | AI review requested |
| `DAEMON_CLASSIFICATION_CREATED` | Classification draft created |
| `DAEMON_CONTAINMENT_CANDIDATE_CREATED` | Containment candidate created |
| `DAEMON_CONTAINMENT_TRIGGERED` | Pre-approved containment triggered |
| `DAEMON_ALERT_DRAFT_CREATED` | Alert draft created |
| `DAEMON_INCIDENT_REPORT_CREATED` | Incident report draft created |
| `DAEMON_AUTHORITY_ACTION_BLOCKED` | Prohibited authority attempt blocked |
| `DAEMON_DEGRADED_MODE_ENTERED` | AI/vector unavailable or degraded |
| `DAEMON_RULE_TUNING_REQUESTED` | Rule tuning requested |

---

## 26. Daemon Alert Families

Foundation catalogs must include daemon alert families.

| Alert Family | Trigger | Severity | Route |
|---|---|---|---|
| `ALERT_DAEMON_CONTAINMENT_TRIGGERED` | Containment triggered | `HIGH_RISK` | Security/HQ |
| `ALERT_DAEMON_CRITICAL_BLOCK_APPLIED` | Critical block applied | `CRITICAL` | Security/HQ |
| `ALERT_DAEMON_AUTHORITY_ATTEMPT_BLOCKED` | Prohibited authority action attempted | `CRITICAL` | AI/security |
| `ALERT_DAEMON_VECTOR_SOURCE_BLOCKED` | Vector source blocked | `WARNING` | AI/security |
| `ALERT_DAEMON_DEGRADED_MODE` | AI/vector degraded | `WARNING` | Platform/security |
| `ALERT_DAEMON_FALSE_POSITIVE_REVIEW_REQUIRED` | Containment may be false positive | `REVIEW_REQUIRED` | Domain owner |
| `ALERT_DAEMON_RULE_TUNING_REQUIRED` | Rule threshold may need tuning | `NOTICE` | Architecture/security |
| `ALERT_DAEMON_INCIDENT_REPORT_READY` | Incident report ready | `NOTICE` | Domain owner/HQ |

---

## 27. Daemon Readiness Blockers

The blocker inventory must include daemon blockers.

| Blocker ID Pattern | Family | Meaning |
|---|---|---|
| `BLOCKER-DAEMON-0001` | Daemon | Monitoring daemon contract missing |
| `BLOCKER-DAEMON-0002` | Daemon | Rule-based filter catalog missing |
| `BLOCKER-DAEMON-0003` | Daemon | pgvector source approval missing |
| `BLOCKER-DAEMON-0004` | Daemon | AI authority boundary missing |
| `BLOCKER-DAEMON-0005` | Daemon | Autonomous containment control missing |
| `BLOCKER-DAEMON-0006` | Daemon | Token/session invalidation policy missing |
| `BLOCKER-DAEMON-0007` | Daemon | Gateway block policy missing |
| `BLOCKER-DAEMON-0008` | Daemon | Incident report template missing |
| `BLOCKER-DAEMON-0009` | Daemon | False positive release policy missing |
| `BLOCKER-DAEMON-0010` | Daemon | Degraded mode policy missing |
| `BLOCKER-DAEMON-0011` | Daemon | Rule tuning governance missing |
| `BLOCKER-DAEMON-0012` | Daemon | Daemon audit mapping missing |

Open daemon blockers must prevent runtime daemon coding.

---

## 28. Boundary Test Additions

Future tests/checks should verify:

- rule-based filter exists before AI review
- critical deterministic events do not wait for AI
- AI cannot execute irreversible business actions
- daemon can trigger only pre-approved containment controls
- daemon cannot release its own containment
- token/session kill is scoped
- gateway block is scoped and reversible
- pgvector source is approved
- pgvector output is advisory only
- restricted data is not sent to AI/vector layer
- daemon output is classified as draft/advisory/containment
- containment creates alert/log/evidence/audit
- false positive release requires review
- daemon degraded mode preserves deterministic security
- rule tuning requires approval/audit
- no package marked coding-ready with daemon blocker open

These tests are planning expectations until implementation approval.

---

## 29. Patent Reinforcement Boundary

This daemon architecture may support patent reinforcement, but claim language must be reviewed by a patent professional.

Technical reinforcement may emphasize:

- autonomous monitoring agent on log/event pipeline
- two-stage rule and pgvector anomaly detection
- real-time or near-real-time containment trigger
- external POS contamination isolation
- payment/provider gateway dynamic blocking
- token/session invalidation
- evidence/audit-linked incident reporting
- AI-generated internal report under authority limits
- domain bulkhead containment
- financial-grade integration security

Provider-specific claims must remain evidence-required.

AI authority claims must be carefully bounded to defensive containment, not unrestricted financial decision-making.

---

## 30. Draft Patent Candidate Language

The following is draft candidate language for later patent-attorney review.

This language is not a final claim.

> The system may include an autonomous monitoring agent configured to observe a structured event and log pipeline generated by external POS modules, payment gateways, membership systems, kitchen execution systems, support systems, and external projection systems.
>
> The monitoring agent may apply a first-stage deterministic rule filter to detect predefined abnormal events and a second-stage vector similarity retrieval process using an embedding database to identify semantically similar incident patterns.
>
> When a detected risk exceeds a predefined containment threshold, the monitoring agent may trigger a pre-approved defensive containment action, including token invalidation, provider callback quarantine, external POS event blocking, external projection blocking, or settlement finalization hold, while generating structured alert, audit, and evidence records for subsequent human or authorized workflow review.
>
> The monitoring agent may generate a derived incident summary using AI assistance, but the AI assistance layer is prevented from approving refunds, mutating ledger entries, confirming provider capabilities, resolving alerts, releasing containment, or executing final business authority.

This draft must be reviewed by a patent attorney before filing.

---

## 31. Relationship To Previous Documents

This document extends:

- `09560 Financial-Grade Foundation Security Bulkhead Alert Log And pgvector Observability Policy`
- `09570 Financial-Grade Security Foundation Control Catalog And Bulkhead Readiness Policy`

It also reinforces:

- `09370 AI Support Gateway pgvector RAG Package Planning Policy`
- `09490 External POS Third-Party Financial Security Ledger And Settlement Isolation Reinforcement Policy`
- `09510 Financial Event Alert Logging And Automated Warning System Policy`
- `09520 Universal Integration Event Alert Logging And Evidence Policy`
- `09530 Universal Integration Event Catalog And Alert Family Index Policy`
- `09540 Universal Integration Reconciliation And Idempotency Catalog Policy`
- `09550 Universal Alert Routing Severity Escalation And Acknowledgement Policy`

This document is Foundation-grade.

It does not authorize coding.

---

## 32. Final Rule

The project must include a Foundation-level AI daemon monitoring architecture.

The daemon must continuously or near-real-time observe structured event and log streams, use deterministic rule filtering first, use pgvector and AI only for approved pattern review and summarization, trigger only pre-approved defensive containment controls, generate alerts, preserve logs, create evidence, create audit, and notify the correct route.

The daemon may contain harm.

The daemon may not decide final truth.

The daemon may not approve money movement, mutate ledger, modify membership value, link identity, publish projection, confirm provider capability, resolve alerts, release containment, or bypass audit.

Coding remains deferred until daemon contracts, rule catalogs, pgvector source controls, AI authority boundaries, containment controls, incident report templates, false-positive release policy, degraded mode policy, rule tuning governance, audit mapping, blockers, and boundary tests are reviewed and approved.
