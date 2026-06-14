# 09590 Trigger View Agent Monitoring Pipeline And Audit Projection Policy

## 1. Purpose

This document adds the Trigger-View-Agent monitoring pipeline to the Foundation architecture.

The purpose is to define how database triggers, audit log tables, monitoring views, pgvector similarity search, and AI daemon monitoring may work together without overloading the main runtime system.

The architecture must follow this principle:

DB organizes signals.
Views expose structured monitoring surfaces.
Rules filter fast.
pgvector retrieves similar patterns.
AI assists classification and reporting.
Containment blocks dangerous propagation.
Humans or authorized workflows resolve.

This document does not authorize coding.

Coding remains deferred unless a specific package has `CODING_ALLOWED`, a completed handoff record, a narrow work order, required tests, and review approval.

---

## 2. Scope

This policy applies to future planning for:

1. Database trigger-based audit signal capture
2. Lightweight audit log append tables
3. Real-time or near-real-time monitoring views
4. Risk score projection views
5. Integration mismatch projection views
6. AI daemon polling or event subscription
7. pgvector anomaly similarity retrieval
8. Rule-based fast filtering
9. Alert candidate creation
10. Evidence packet linkage
11. Audit event linkage
12. Containment and quarantine trigger candidates
13. Patent reinforcement material

This policy applies across POS, payment, settlement, membership, coupon, wallet, identity, KDS, inventory, content, i18n, support/admin, AI, provider, projection, SCM/WMS, workforce, and Franchise OS integrations.

---

## 3. Core Principle

The main business tables must not become the AI daemon’s raw playground.

The AI daemon must not repeatedly parse raw logs, scan hot order/payment tables, or infer operational truth from unstructured records.

The correct pattern is:

- core tables handle business facts
- triggers capture minimal security/audit signals
- audit log tables store append-only monitoring packets
- views project risk-ready summaries
- daemon watches the projection layer
- pgvector is called only for approved ambiguous/high-risk patterns
- containment and alerts are driven by controlled policies

The database prepares the food.

The AI daemon does not rummage through the kitchen.

---

## 4. Trigger-View-Agent Pipeline

The conceptual pipeline is:

    event or state change occurs
        |
        v
    core table INSERT / UPDATE / state transition
        |
        v
    lightweight trigger captures monitoring signal
        |
        v
    append-only audit signal table
        |
        v
    monitoring view / risk projection view
        |
        v
    rule-based daemon filter
        |
        v
    pgvector similarity retrieval if needed
        |
        v
    AI daemon summary/classification if allowed
        |
        v
    alert / evidence / audit / containment candidate
        |
        v
    authorized review / reconciliation / release

The trigger must be light.

The view must be structured.

The daemon must be bounded.

---

## 5. Trigger Role

A trigger may be used to capture lightweight monitoring signals when important state changes occur.

Trigger responsibilities may include:

- capture event family
- capture table/domain
- capture tenant/store context
- capture actor/system actor
- capture correlation id
- capture idempotency key if present
- capture old/new status class
- capture error code
- capture provider event id if applicable
- capture token scope status if applicable
- capture timestamp
- capture source system
- capture sensitive data class
- write append-only audit signal

A trigger must not perform heavy AI logic, pgvector retrieval, external provider calls, long-running network calls, or complex reconciliation.

---

## 6. Trigger Performance Rule

Triggers must be minimal and predictable.

A trigger must not:

- call LLM or AI services
- call pgvector similarity search directly
- call external APIs
- perform heavy aggregation
- run long scans
- mutate unrelated business state
- perform settlement correction
- publish external projection
- send notifications directly
- resolve alerts
- release containment
- perform support/admin action
- include secrets in logs
- block hot transactions unnecessarily

If trigger logic risks slowing core order/payment operations, it must be moved to asynchronous processing.

---

## 7. Audit Signal Table Rule

Trigger output must go to append-only audit signal tables.

Audit signal tables are not final business truth.

They are monitoring/evidence inputs.

Minimum fields:

| Field | Required Meaning |
|---|---|
| Signal ID | Stable audit signal id |
| Source table | Origin table |
| Source domain | POS, payment, membership, etc. |
| Event family | Controlled event family |
| Tenant ID | Tenant scope |
| Store ID | Store scope |
| Actor class | Human, system, provider, AI |
| Actor reference | Masked/scoped actor reference |
| Correlation ID | Cross-system correlation |
| Idempotency key | Duplicate prevention reference |
| Old state class | Prior controlled state |
| New state class | New controlled state |
| Error code | Unix-style/domain error code if any |
| Severity candidate | Initial severity candidate |
| Sensitive data class | Visibility/masking class |
| Evidence packet ID | Optional evidence link |
| Audit event ID | Optional audit link |
| Created at | Signal timestamp |

Audit signal tables must be append-only.

Correction must create new signals.

---

## 8. Monitoring View Role

Monitoring views must project audit signals into daemon-readable surfaces.

Views may aggregate and normalize:

- recent error counts
- repeated token failures
- callback verification failures
- provider timeout patterns
- store-level risk scores
- device-level risk scores
- integration mismatch counts
- unresolved reconciliation counts
- alert candidate counts
- quarantine candidates
- containment candidates
- external projection drift
- membership identity conflicts
- coupon/wallet duplicate value risk
- KDS/order/payment mismatch
- missing i18n/content keys
- AI governance anomalies

Views reduce daemon workload.

Views must not create business authority.

---

## 9. Risk Projection View Rule

Risk projection views may compute risk-ready summaries.

Examples of projected fields:

| Field | Meaning |
|---|---|
| Tenant/store scope | Affected scope |
| Domain | POS/payment/membership/etc. |
| Time window | Last 1 minute, 5 minutes, 1 hour, etc. |
| Event count | Number of signals |
| Error family count | Count by error family |
| Repeated source count | Repeated actor/device/provider |
| Severity max | Highest severity observed |
| Risk score candidate | Calculated risk candidate |
| Containment candidate | Whether containment may be needed |
| Quarantine candidate | Whether quarantine may be needed |
| Reconciliation candidate | Whether mismatch exists |
| pgvector review needed | Whether vector review is recommended |
| AI review allowed | Whether AI review is allowed |
| Alert family candidate | Candidate alert family |

Risk score is a signal.

Risk score is not final truth.

---

## 10. View Freshness Rule

Monitoring views must define freshness expectations.

Freshness classes:

| Freshness Class | Meaning |
|---|---|
| `VIEW_REAL_TIME_REQUIRED` | Must reflect near-immediate critical signals |
| `VIEW_NEAR_REAL_TIME` | Short delay acceptable |
| `VIEW_BATCH_REFRESH` | Periodic refresh acceptable |
| `VIEW_MANUAL_REVIEW` | Used only for manual review |
| `VIEW_ARCHIVE_ANALYSIS` | Historical analysis only |

Not every view must be real-time.

Critical deterministic containment signals should use the fastest reliable path.

AI/pgvector review may operate near-real-time to control latency and cost.

---

## 11. View Type Catalog

Foundation catalogs should include view type categories.

| View Type | Meaning |
|---|---|
| `VIEW_AUDIT_SIGNAL_RAW_SAFE` | Safe structured audit signal view |
| `VIEW_SECURITY_RISK_SCORE` | Security risk projection |
| `VIEW_PROVIDER_CALLBACK_MONITOR` | Provider callback monitoring |
| `VIEW_POS_CONTAMINATION_MONITOR` | POS abnormality monitoring |
| `VIEW_PAYMENT_RECON_MONITOR` | Payment mismatch monitoring |
| `VIEW_LEDGER_RECON_MONITOR` | Ledger/settlement monitoring |
| `VIEW_MEMBERSHIP_CONFLICT_MONITOR` | Membership identity/value conflict |
| `VIEW_COUPON_WALLET_VALUE_MONITOR` | Coupon/wallet value risk |
| `VIEW_KDS_ORDER_MISMATCH_MONITOR` | KDS/order/payment mismatch |
| `VIEW_INVENTORY_PROJECTION_MONITOR` | Inventory/projection mismatch |
| `VIEW_CONTENT_I18N_MONITOR` | Content/i18n missing key/stale text |
| `VIEW_AI_GOVERNANCE_MONITOR` | AI boundary violations |
| `VIEW_PGVECTOR_SOURCE_MONITOR` | Vector source eligibility |
| `VIEW_ALERT_CANDIDATE_QUEUE` | Alert candidates |
| `VIEW_CONTAINMENT_CANDIDATE_QUEUE` | Containment candidates |
| `VIEW_QUARANTINE_CANDIDATE_QUEUE` | Quarantine candidates |

These are planning view categories.

They do not create SQL implementation.

---

## 12. Unix-Style Error Code Mapping

Audit signals should include controlled error code families.

Recommended pattern:

`ERR_<DOMAIN>_<FAMILY>_<DETAIL>`

Examples:

| Error Code | Meaning |
|---|---|
| `ERR_SEC_AUTH_FAIL_401` | Authentication failure |
| `ERR_SEC_TOKEN_SCOPE_VIOLATION` | Token scope violation |
| `ERR_POS_CROSS_STORE_EVENT` | POS event crossed store boundary |
| `ERR_PROVIDER_CALLBACK_SIGNATURE_FAILED` | Provider callback signature failed |
| `ERR_PROVIDER_CALLBACK_DUPLICATE` | Duplicate provider callback |
| `ERR_PAYMENT_STATE_UNCERTAIN` | Payment state uncertain |
| `ERR_LEDGER_RECON_MISMATCH` | Ledger reconciliation mismatch |
| `ERR_MEMBERSHIP_IDENTITY_CONFLICT` | Membership identity conflict |
| `ERR_COUPON_DUPLICATE_USE` | Coupon duplicate use risk |
| `ERR_WALLET_DUPLICATE_VALUE` | Wallet duplicate value risk |
| `ERR_KDS_PAYMENT_ORDER_MISMATCH` | KDS/payment/order mismatch |
| `ERR_PROJECTION_ALLERGEN_MISMATCH` | Allergen projection mismatch |
| `ERR_I18N_MESSAGE_KEY_MISSING` | i18n message key missing |
| `ERR_AI_AUTHORITY_OVERREACH` | AI authority overreach |
| `ERR_PGVECTOR_SOURCE_NOT_APPROVED` | Vector source not approved |

Error codes must map to event families, alert families, severity, and routing.

---

## 13. Daemon View Access Boundary

The AI daemon should access monitoring views, not raw hot business tables by default.

Allowed daemon access:

- monitoring views
- risk projection views
- alert candidate views
- approved audit metadata
- approved evidence summaries
- approved pgvector metadata
- approved SOP/content references

Blocked daemon access by default:

- raw payment secrets
- raw provider secrets
- raw customer payment data
- unmasked identity data
- unrestricted support notes
- hot business tables without view boundary
- cross-tenant data outside scope
- unapproved legal content
- full sensitive provider payloads

The daemon must follow least privilege.

---

## 14. Daemon Polling And Subscription Boundary

The daemon may observe views through:

- polling
- queue subscription
- logical event subscription
- scheduled scan
- materialized view refresh review
- alert candidate queue consumption

Implementation is deferred.

Planning must distinguish:

| Mode | Meaning |
|---|---|
| `DAEMON_POLLING_VIEW` | Daemon periodically selects from monitoring view |
| `DAEMON_QUEUE_CONSUMER` | Daemon consumes event queue |
| `DAEMON_SUBSCRIPTION` | Daemon receives event notifications |
| `DAEMON_BATCH_REVIEW` | Daemon reviews batch summaries |
| `DAEMON_MANUAL_ASSIST` | Daemon assists manual review |

Critical containment must not depend on slow polling when deterministic inline blocking is required.

---

## 15. pgvector Feeding Rule

pgvector must be fed from approved monitoring summaries, not raw sensitive logs.

Vectorizable content may include:

- event metadata summary
- alert metadata summary
- evidence summary
- support case summary
- provider error summary
- reconciliation exception summary
- approved SOP text
- approved content/i18n references
- security incident summary
- daemon incident report draft after review status

Blocked from vectorization:

- secrets
- provider credentials
- raw payment data
- unmasked identity data
- sensitive full logs
- raw support notes
- unapproved legal content
- raw screenshots
- unrestricted provider payloads
- customer-private data outside approved scope

Vectors must preserve source traceability.

---

## 16. pgvector Similarity Score Boundary

A pgvector similarity score may influence review priority.

It must not be treated as proof.

Similarity result may support:

- “similar to previous provider callback failure”
- “similar to previous POS replay pattern”
- “similar to previous membership identity conflict”
- “similar to previous coupon duplicate use”
- “similar to previous projection mismatch”
- “similar to previous AI governance alert”

Similarity result must not directly:

- resolve incident
- approve containment release
- mutate state
- confirm provider capability
- approve refund
- adjust points/wallet/coupon
- link identity
- publish projection

Similarity is advisory.

---

## 17. Trigger Safety Classes

Trigger use must be classified.

| Trigger Class | Meaning |
|---|---|
| `TRIGGER_AUDIT_SIGNAL_ONLY` | Writes lightweight audit signal |
| `TRIGGER_STATUS_GUARD` | Blocks invalid status transition |
| `TRIGGER_SECURITY_GUARD` | Blocks obvious security violation |
| `TRIGGER_IDEMPOTENCY_GUARD` | Prevents duplicate event effect |
| `TRIGGER_APPEND_ONLY_GUARD` | Prevents mutation/deletion where prohibited |
| `TRIGGER_RECON_SIGNAL` | Creates reconciliation candidate signal |
| `TRIGGER_BLOCKED_HEAVY_LOGIC` | Heavy logic prohibited |

Foundation-first trigger planning should prefer signal and guard triggers only.

Heavy logic must be deferred.

---

## 18. View Safety Classes

View use must be classified.

| View Class | Meaning |
|---|---|
| `VIEW_READ_ONLY_MONITORING` | Read-only monitoring view |
| `VIEW_RISK_PROJECTION` | Risk score projection |
| `VIEW_ALERT_CANDIDATE` | Alert candidate projection |
| `VIEW_RECONCILIATION_CANDIDATE` | Reconciliation candidate projection |
| `VIEW_CONTAINMENT_CANDIDATE` | Containment candidate projection |
| `VIEW_QUARANTINE_CANDIDATE` | Quarantine candidate projection |
| `VIEW_AI_REVIEW_INPUT` | Approved AI input view |
| `VIEW_PGVECTOR_INPUT` | Approved vector input view |
| `VIEW_RUNTIME_AUTHORITY_PROHIBITED` | View cannot mutate or approve state |

Views must remain read-only projections.

---

## 19. Materialized View Boundary

Some monitoring views may later require materialization for performance.

Materialized view planning must define:

- refresh frequency
- staleness tolerance
- source tables
- tenant/store scope
- data sensitivity
- invalidation rule
- refresh failure alert
- AI/daemon use
- pgvector use
- retention
- access policy

Materialized views must not become stale source of truth.

If materialized data is stale, alerts and daemon outputs must reflect that uncertainty.

---

## 20. Trigger Failure Rule

Trigger failure must not be ignored.

Trigger failure planning must define:

- whether business transaction should fail
- whether audit signal can be retried
- whether fallback queue is used
- whether alert is raised
- whether evidence is created
- whether degraded state is entered
- whether manual review is required

For critical financial/security audit triggers, failure may require blocking or containment.

For lower-risk monitoring triggers, failure may require degraded logging and alert.

---

## 21. Monitoring View Failure Rule

Monitoring view failure or staleness must create its own alert.

Alert families may include:

| Alert Family | Meaning |
|---|---|
| `ALERT_MONITORING_VIEW_STALE` | Monitoring view stale |
| `ALERT_MONITORING_VIEW_REFRESH_FAILED` | View refresh failed |
| `ALERT_MONITORING_SIGNAL_MISSING` | Expected signal missing |
| `ALERT_MONITORING_RISK_SCORE_UNAVAILABLE` | Risk score unavailable |
| `ALERT_DAEMON_VIEW_ACCESS_FAILED` | Daemon cannot access view |
| `ALERT_PGVECTOR_INPUT_VIEW_BLOCKED` | Vector input view blocked |
| `ALERT_AI_REVIEW_INPUT_VIEW_BLOCKED` | AI review input view blocked |

The monitoring layer must itself be monitored.

---

## 22. Trigger-View-Agent Security Rule

The Trigger-View-Agent pipeline must preserve security.

Security requirements:

- triggers do not log secrets
- audit signals are scoped by tenant/store
- views enforce visibility/masking
- daemon access is least-privilege
- pgvector sources are approved
- AI receives only allowed summaries
- alert messages use i18n keys
- restricted data remains masked
- cross-tenant view leakage is blocked
- cross-store view leakage is controlled
- support/admin views are authority-limited
- monitoring views cannot mutate state

The monitoring system must not become a new attack surface.

---

## 23. Trigger-View-Agent Readiness Blockers

The blocker inventory must include Trigger-View-Agent blockers.

| Blocker ID Pattern | Family | Meaning |
|---|---|---|
| `BLOCKER-TVA-0001` | Trigger-View-Agent | Trigger signal contract missing |
| `BLOCKER-TVA-0002` | Trigger-View-Agent | Audit signal table fields missing |
| `BLOCKER-TVA-0003` | Trigger-View-Agent | Monitoring view catalog missing |
| `BLOCKER-TVA-0004` | Trigger-View-Agent | Risk projection view rule missing |
| `BLOCKER-TVA-0005` | Trigger-View-Agent | Unix-style error code map missing |
| `BLOCKER-TVA-0006` | Trigger-View-Agent | Daemon view access boundary missing |
| `BLOCKER-TVA-0007` | Trigger-View-Agent | pgvector feed boundary missing |
| `BLOCKER-TVA-0008` | Trigger-View-Agent | Trigger performance rule missing |
| `BLOCKER-TVA-0009` | Trigger-View-Agent | View freshness rule missing |
| `BLOCKER-TVA-0010` | Trigger-View-Agent | Monitoring failure alert missing |
| `BLOCKER-TVA-0011` | Trigger-View-Agent | Trigger/view security rule missing |

Open Trigger-View-Agent blockers must prevent runtime monitoring implementation.

---

## 24. Boundary Test Additions

Future tests/checks should verify:

- triggers are lightweight
- triggers do not call external providers
- triggers do not call AI/LLM
- triggers do not run heavy scans
- triggers do not log secrets
- audit signal records are append-only
- monitoring views are read-only
- views preserve tenant/store boundary
- views preserve masking/visibility class
- daemon reads approved views only
- pgvector input comes from approved summaries only
- raw sensitive logs are not vectorized
- similarity score is advisory only
- materialized view staleness is visible
- monitoring view failure creates alert
- trigger failure handling is defined
- no package marked coding-ready with Trigger-View-Agent blocker open

These tests are planning expectations until implementation approval.

---

## 25. Patent Reinforcement Boundary

The Trigger-View-Agent architecture may support patent reinforcement, but claim language must be reviewed by a patent professional.

Technical reinforcement may emphasize:

- trigger-based lightweight audit signal capture
- isolated audit signal tables
- real-time or near-real-time monitoring views
- risk projection views
- daemon-based observation of monitoring views
- pgvector-based incident similarity retrieval
- AI-assisted classification and incident report drafting
- autonomous containment only through pre-approved controls
- financial-grade audit/evidence linkage
- external POS contamination prevention
- multi-domain integration monitoring

Provider-specific or certification-specific claims must remain evidence-required.

---

## 26. Draft Patent Candidate Language

The following is draft candidate language for later patent-attorney review.

This language is not a final claim.

> The system may include a trigger-view-agent monitoring architecture in which database triggers associated with one or more operational tables generate lightweight audit signal records upon occurrence of state changes or integration events.
>
> The audit signal records may be accumulated in an append-only audit signal table and projected through one or more monitoring views configured to aggregate risk indicators, error codes, integration mismatches, and containment candidates across multiple runtime domains.
>
> An autonomous monitoring agent may observe the monitoring views rather than raw operational tables, and may apply deterministic rule filters, vector similarity retrieval using an embedding database, and AI-assisted classification to generate alerts, evidence records, audit records, incident summaries, or pre-approved containment candidates.
>
> The monitoring agent may trigger only predefined defensive containment controls and is prevented from approving financial corrections, mutating ledger entries, confirming provider capabilities, resolving alerts, releasing containment, or executing final business authority.

This draft must be reviewed by a patent attorney before filing.

---

## 27. Relationship To Previous Documents

This document extends:

- `09580 AI Daemon Security Monitoring Agent And Autonomous Containment Policy`

It also reinforces:

- `09560 Financial-Grade Foundation Security Bulkhead Alert Log And pgvector Observability Policy`
- `09570 Financial-Grade Security Foundation Control Catalog And Bulkhead Readiness Policy`
- `09540 Universal Integration Reconciliation And Idempotency Catalog Policy`
- `09550 Universal Alert Routing Severity Escalation And Acknowledgement Policy`
- `09330 API RPC Event Contract Planning Boundary Policy`
- `09360 Support Admin Evidence Audit Package Planning Policy`
- `09370 AI Support Gateway pgvector RAG Package Planning Policy`

This document is Foundation-grade.

It does not authorize coding.

---

## 28. Final Rule

The Trigger-View-Agent pipeline must be treated as a Foundation monitoring architecture.

Triggers capture lightweight audit signals.

Audit signal tables preserve append-only monitoring facts.

Views project daemon-readable risk surfaces.

Rules perform fast deterministic filtering.

pgvector supports similarity and anomaly retrieval.

AI assists classification and reporting.

Containment is allowed only through pre-approved defensive controls.

The daemon watches structured monitoring views, not raw sensitive business tables by default.

The pipeline must preserve performance, tenant/store isolation, masking, auditability, evidence linkage, pgvector traceability, and AI authority limits.

Coding remains deferred until trigger contracts, audit signal fields, monitoring view catalogs, risk projection rules, error code maps, daemon access boundaries, pgvector feed boundaries, failure handling, blockers, and boundary tests are reviewed and approved.
