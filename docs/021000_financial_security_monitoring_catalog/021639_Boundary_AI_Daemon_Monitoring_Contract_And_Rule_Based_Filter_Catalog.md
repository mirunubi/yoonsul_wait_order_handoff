# 021639_Boundary_AI_Daemon_Monitoring_Contract_And_Rule_Based_Filter_Catalog

## 1. Purpose

This document defines the AI Daemon Monitoring Boundary Contract for the Financial-Grade Security Monitoring Foundation Package.

The previous artifact `21638` defined monitoring views and risk projection contracts.

This document defines how a future AI-assisted monitoring daemon may observe approved monitoring views, apply deterministic rule-based filters, request pgvector-assisted similarity review, generate incident summaries, and recommend controlled routes without becoming business authority.

The AI daemon is a monitoring assistant.

The AI daemon is not a payment approver.

The AI daemon is not a ledger writer.

The AI daemon is not a support resolver.

The AI daemon is not a quarantine or containment release authority.

This document is contract-only.

It does not authorize coding.

Coding remains deferred unless a specific package has `CODING_ALLOWED`, a completed handoff record, a narrow work order, required tests, and review approval.

---

## 2. Scope

This contract applies to future daemon planning for:

1. Monitoring view observation
2. Deterministic rule-based filtering
3. AI-assisted classification
4. pgvector-assisted similarity review
5. Alert candidate enrichment
6. Containment candidate recommendation
7. Quarantine candidate recommendation
8. Reconciliation candidate recommendation
9. Evidence gap detection
10. Audit requirement detection
11. Incident report drafting
12. Owner/HQ/support/security routing
13. Degraded-mode operation
14. False-positive review support
15. Rule tuning governance
16. Daemon output classification
17. Daemon access boundary
18. Autonomous containment pre-approval catalog

This document does not implement daemon runtime, queue consumers, workers, scheduled jobs, LLM calls, vector search, alert delivery, containment executors, or dashboards.

---

## 3. Core Principle

The daemon may detect risk.

The daemon may summarize risk.

The daemon may recommend review.

The daemon may trigger only pre-approved defensive containment candidates if a later runtime package explicitly authorizes it.

The daemon must not decide final truth.

The daemon must not mutate business records.

The daemon must not release containment or quarantine.

The daemon must not approve money, identity, content publication, provider capability, or support resolution.

The correct rule is:

Rule first.
Similarity second.
AI summary third.
Human or authorized system review fourth.
Mutation only through domain authority.

---

## 4. Catalog Header

| Field | Value |
|---|---|
| Document ID | `21639` |
| Package ID | `foundation.security_monitoring.financial_grade.v1` |
| Artifact Type | `CONTRACT` |
| Version | `v1` |
| Planning Status | `FOUNDATION_CANDIDATE` |
| Coding Status | `CODING_DEFERRED` |
| Runtime Authority | `CATALOG_ONLY` |
| Owner | `Architecture / Security Foundation / AI Governance` |
| Dependencies | `21631`, `21632`, `21633`, `21634`, `21635`, `21636`, `21637`, `21638`, `21630`, `21620`, `21610` |
| Provider Evidence Status | `APPLIES_IF_PROVIDER_RELATED` |
| i18n Requirement | `APPLIES_IF_DAEMON_OUTPUT_FEEDS_VISIBLE_MESSAGE` |
| Audit Requirement | `REQUIRED_FOR_HIGH_RISK_DAEMON_OUTPUT_OR_CONTAINMENT_TRIGGER` |
| Security Requirement | `AI_ASSISTANCE_ONLY_DAEMON_BOUNDARY_REQUIRED` |
| Review Requirement | `ARCHITECTURE_SECURITY_AI_GOVERNANCE_REVIEW_REQUIRED` |
| Blocker Status | `AI_DAEMON_CONTRACT_REVIEW_REQUIRED` |

---

## 5. Daemon Definition

An AI monitoring daemon is a future background observer that may read approved monitoring views and create derived review outputs.

A daemon may:

- read approved monitoring views
- read approved risk projection views
- apply deterministic rules
- detect repeated error-code patterns
- classify alert candidates
- suggest route and escalation
- request approved pgvector similarity review
- generate internal incident summaries
- identify evidence gaps
- identify audit requirement gaps
- mark output as derived
- create review candidates
- recommend containment/quarantine/reconciliation routes
- operate in degraded deterministic mode when AI/pgvector is unavailable

A daemon must not:

- mutate source-of-truth records
- approve refund
- approve compensation
- capture or refund payment
- post ledger correction
- adjust membership points
- adjust wallet balance
- issue/reissue coupon
- link or merge identity
- publish projection
- approve content
- close support case
- confirm provider capability
- release containment
- release quarantine
- delete archive
- override legal hold
- change role/permission
- bypass audit
- suppress alert without review

---

## 6. Daemon Pipeline Contract

Recommended conceptual pipeline:

1. Monitoring view read
2. Deterministic rule-based filter
3. Severity and route candidate assignment
4. Evidence/audit gap detection
5. pgvector similarity request if eligible
6. AI summary/classification if eligible
7. Derived incident summary creation
8. Alert candidate enrichment
9. Containment/quarantine/reconciliation recommendation
10. Human/domain review routing
11. False-positive and rule-tuning feedback capture

This is a planning pipeline only.

It does not authorize runtime implementation.

---

## 7. Daemon Input Source Catalog

Allowed daemon input sources:

| Source | Eligibility |
|---|---|
| Approved monitoring views | Allowed |
| Approved risk projection views | Allowed |
| Approved alert candidate views | Allowed |
| Approved containment candidate views | Allowed |
| Approved quarantine candidate views | Allowed |
| Approved reconciliation candidate views | Allowed |
| Approved pgvector result summaries | Allowed |
| Approved event/error-code summaries | Allowed |
| Redacted evidence summaries | Conditional |
| Redacted support summaries | Conditional |
| Archive summaries | Conditional |
| Raw hot business tables | Blocked by default |
| Raw payment payloads | Blocked |
| Raw identity data | Blocked |
| Provider secrets | Blocked |
| Service role keys | Blocked |
| Raw legal hold content | Blocked unless legal-approved summary |
| Unrestricted support notes | Blocked |
| Raw AI prompts containing restricted data | Blocked |

The daemon reads projections, not unrestricted source tables.

---

## 8. Daemon Output Catalog

Daemon outputs must be classified.

| Output Type | Meaning | Authority |
|---|---|---|
| `DAEMON_OUTPUT_OBSERVATION` | Observed risk pattern | Advisory |
| `DAEMON_OUTPUT_CLASSIFICATION` | Suggested event/alert classification | Advisory |
| `DAEMON_OUTPUT_ROUTE_SUGGESTION` | Suggested route/escalation | Advisory |
| `DAEMON_OUTPUT_EVIDENCE_GAP` | Missing evidence detected | Advisory |
| `DAEMON_OUTPUT_AUDIT_GAP` | Missing audit detected | Advisory |
| `DAEMON_OUTPUT_SIMILAR_INCIDENTS` | Similar incident references | Advisory |
| `DAEMON_OUTPUT_INCIDENT_SUMMARY` | Internal incident summary | Derived |
| `DAEMON_OUTPUT_CONTAINMENT_CANDIDATE` | Candidate for containment | Advisory unless pre-approved executor exists |
| `DAEMON_OUTPUT_QUARANTINE_CANDIDATE` | Candidate for quarantine | Advisory unless pre-approved executor exists |
| `DAEMON_OUTPUT_RECONCILIATION_CANDIDATE` | Candidate for reconciliation | Advisory |
| `DAEMON_OUTPUT_CUSTOMER_RECOVERY_CANDIDATE` | Customer recovery may be needed | Advisory |
| `DAEMON_OUTPUT_RULE_TUNING_CANDIDATE` | Rule threshold needs review | Advisory |
| `DAEMON_OUTPUT_DEGRADED_MODE_NOTICE` | AI/pgvector unavailable | Advisory |
| `DAEMON_OUTPUT_BLOCKED_BY_POLICY` | Daemon action blocked by policy | Audit-relevant |

No daemon output is final business truth.

---

## 9. Deterministic Rule-Based Filter Catalog

The first stage must be deterministic.

Rules may evaluate:

- error code
- event family
- alert family
- severity candidate
- risk score band
- repeated event count
- cross-tenant risk count
- cross-store risk count
- idempotency conflict count
- provider verification failure count
- evidence-required count
- audit-required count
- stale view status
- restricted access attempt
- AI authority overreach
- pgvector restricted source risk
- archive legal hold conflict
- support unauthorized mutation
- payment duplicate capture risk
- ledger imbalance risk

AI must not be the first and only line of detection for critical financial/security conditions.

---

## 10. Deterministic Rule Examples

| Rule ID | Trigger | Daemon Output |
|---|---|---|
| `RULE-DAEMON-SEC-CROSS-TENANT` | `ERR_SEC_TENANT_BOUNDARY_RISK` count > 0 | `DAEMON_OUTPUT_CONTAINMENT_CANDIDATE` |
| `RULE-DAEMON-PROVIDER-SIGNATURE` | `ERR_PROVIDER_CALLBACK_SIGNATURE_FAILED` count > 0 | `DAEMON_OUTPUT_QUARANTINE_CANDIDATE` |
| `RULE-DAEMON-PAYMENT-DUP-CAPTURE` | `ERR_PAYMENT_DUPLICATE_CAPTURE_RISK` count > 0 | `DAEMON_OUTPUT_CONTAINMENT_CANDIDATE` |
| `RULE-DAEMON-LEDGER-IMBALANCE` | `ERR_LEDGER_IMBALANCE_DETECTED` count > 0 | `DAEMON_OUTPUT_RECONCILIATION_CANDIDATE` |
| `RULE-DAEMON-AI-OVERREACH` | `ERR_AI_AUTHORITY_OVERREACH` count > 0 | `DAEMON_OUTPUT_CONTAINMENT_CANDIDATE` |
| `RULE-DAEMON-PGVECTOR-RESTRICTED` | `ERR_PGVECTOR_RESTRICTED_DATA_RISK` count > 0 | `DAEMON_OUTPUT_CONTAINMENT_CANDIDATE` |
| `RULE-DAEMON-ARCHIVE-LEGAL-HOLD` | `ERR_ARCHIVE_LEGAL_HOLD_CONFLICT` count > 0 | `DAEMON_OUTPUT_ROUTE_SUGGESTION` |
| `RULE-DAEMON-SUPPORT-UNAUTH` | `ERR_SUPPORT_UNAUTHORIZED_MUTATION` count > 0 | `DAEMON_OUTPUT_CONTAINMENT_CANDIDATE` |
| `RULE-DAEMON-VIEW-STALE` | Monitoring view stale beyond threshold | `DAEMON_OUTPUT_DEGRADED_MODE_NOTICE` |
| `RULE-DAEMON-EVIDENCE-GAP` | Evidence required count > 0 and no evidence reference | `DAEMON_OUTPUT_EVIDENCE_GAP` |

Rules must be reviewed before runtime use.

---

## 11. AI-Assisted Classification Boundary

AI may assist only after deterministic filtering or approved view selection.

AI may:

- summarize the incident
- suggest event/alert family
- identify missing evidence
- identify similar risk patterns
- suggest review route
- draft internal reviewer note
- explain why containment/quarantine may be needed
- identify possible false-positive causes
- suggest rule tuning for review

AI must not:

- approve the classification as final
- suppress alerts
- release containment
- release quarantine
- resolve support case
- decide refund/compensation
- mutate records
- create provider truth
- approve customer-facing text
- finalize reconciliation

AI output must remain derived and review-required.

---

## 12. pgvector Similarity Review Boundary

pgvector may be used only with approved summaries.

pgvector may help:

- find similar prior incidents
- find repeated error-code clusters
- retrieve related SOP/control documents
- retrieve prior false-positive patterns
- retrieve related provider failure patterns
- retrieve similar support evidence gaps
- retrieve archive lifecycle anomalies
- retrieve AI governance incidents

pgvector must not:

- retrieve unrestricted sensitive data
- cross tenant without authority
- cross store without authority
- use restricted raw data
- treat similarity as proof
- become source of truth
- release containment/quarantine
- suppress alerts

Similarity is context, not authority.

---

## 13. Autonomous Containment Candidate Boundary

The daemon may later trigger automatic containment only if:

1. the containment rule is pre-approved
2. the scope is narrow
3. the action is defensive only
4. the action is reversible through authority
5. evidence/audit is generated
6. the daemon output is logged
7. customer impact is controlled
8. release authority is not the daemon
9. the package-specific runtime gate allows it

Examples of possible pre-approved defensive actions:

- block unverified provider callback mutation
- block cross-tenant event propagation
- block duplicate value mutation
- block AI output release
- block pgvector source ingestion
- block external projection publication
- hold ledger finalization
- hold settlement allocation
- invalidate scoped token when clear violation is detected

This document does not approve any runtime executor.

---

## 14. Daemon Prohibited Authority Catalog

| Prohibited Authority | Reason |
|---|---|
| Payment capture/refund approval | Financial authority |
| Ledger correction posting | Ledger authority |
| Settlement finalization | Finance/reconciliation authority |
| Membership point/grade adjustment | Value authority |
| Wallet balance adjustment | Value authority |
| Coupon issue/reissue/use override | Value authority |
| Identity link/merge/unlink | Privacy/identity authority |
| Provider capability confirmation | Provider evidence authority |
| KDS ticket completion/void/remake approval | Store/kitchen authority |
| Inventory stock adjustment | Inventory/QC authority |
| External projection publication | Content/provider/legal authority |
| Support case closure | Support authority |
| Customer compensation | Support/finance/legal authority |
| Archive deletion/legal hold release | Data/legal authority |
| Role/permission change | Security/HR authority |
| Alert final resolution | Domain owner authority |
| Containment/quarantine release | Domain/security authority |

The daemon may recommend review only.

---

## 15. Daemon Incident Report Draft Template

A daemon-generated incident report draft should include:

| Field | Meaning |
|---|---|
| `incident_draft_id` | Draft id |
| `source_view_id` | Monitoring view source |
| `time_window` | Observed window |
| `tenant_scope` | Tenant scope |
| `store_scope` | Store scope if applicable |
| `bulkhead_id` | Affected bulkhead |
| `event_families` | Related event families |
| `error_codes` | Related error codes |
| `severity_candidate` | Candidate severity |
| `risk_score_candidate` | Candidate risk score |
| `route_suggestion` | Suggested route |
| `evidence_gap_summary` | Missing evidence |
| `audit_gap_summary` | Missing audit |
| `similar_incident_refs` | Approved similar references |
| `containment_candidate` | Candidate only |
| `quarantine_candidate` | Candidate only |
| `reconciliation_candidate` | Candidate only |
| `customer_impact_candidate` | Candidate only |
| `ai_summary_text` | Internal derived summary |
| `review_required` | Always true for high-risk |
| `derived_status` | Must mark AI/daemon output as derived |

Incident drafts must not be final evidence.

---

## 16. Daemon Degraded Mode

The daemon must support degraded modes.

| Degraded Mode | Meaning |
|---|---|
| `DAEMON_DEGRADED_AI_UNAVAILABLE` | AI unavailable; deterministic rules continue |
| `DAEMON_DEGRADED_PGVECTOR_UNAVAILABLE` | Vector retrieval unavailable; rules continue |
| `DAEMON_DEGRADED_VIEW_STALE` | Monitoring view stale; alert platform |
| `DAEMON_DEGRADED_PROVIDER_DATA_MISSING` | Provider data missing; route provider review |
| `DAEMON_DEGRADED_ARCHIVE_UNAVAILABLE` | Archive reference unavailable; route data governance |
| `DAEMON_DEGRADED_RULE_ONLY` | Rule-only mode active |
| `DAEMON_DEGRADED_MANUAL_REVIEW_ONLY` | Automatic recommendations disabled |

AI/pgvector failure must not stop deterministic security monitoring.

---

## 17. False Positive Review

False positives must be reviewable.

A false-positive review record should include:

- daemon output id
- triggering rule id
- event/error codes
- source monitoring view
- affected scope
- reviewer
- false-positive reason
- evidence reviewed
- customer impact
- containment/quarantine impact
- rule tuning recommendation
- whether similar future cases should be suppressed
- audit event
- review timestamp

False-positive review must not silently suppress critical alerts.

Suppression rules require separate approval.

---

## 18. Rule Tuning Governance

Daemon rules must not be changed casually.

Rule tuning must define:

| Field | Meaning |
|---|---|
| Rule ID | Rule being changed |
| Current threshold | Existing threshold |
| Proposed threshold | New threshold |
| Reason | Why change is needed |
| Evidence | Incident/false-positive data |
| Risk | Possible under-detection |
| Reviewer | Required approver |
| Rollback plan | How to revert |
| Effective date | When applied |
| Audit event | Required |

AI may suggest rule tuning.

AI may not approve or apply rule tuning.

---

## 19. Daemon Access Boundary

The daemon must access only approved sources.

The daemon must not use:

- unrestricted database service role access
- raw unrestricted table scans
- cross-tenant raw queries
- direct provider credential access
- raw support notes
- raw payment payloads
- raw identity data
- raw archive payloads
- unrestricted legal hold records

The daemon should read:

- approved monitoring views
- approved risk projection views
- approved redacted summaries
- approved vector result summaries
- approved event/error-code summaries

Daemon access must be auditable.

---

## 20. Daemon Audit Requirements

Audit is required when daemon output:

- triggers containment candidate
- triggers quarantine candidate
- recommends reconciliation
- influences support/admin review
- uses AI summary in high-risk context
- uses pgvector similarity in high-risk context
- detects cross-tenant/cross-store risk
- detects provider callback risk
- detects payment/ledger risk
- detects identity/privacy risk
- detects restricted data access
- detects archive/legal hold risk
- enters degraded mode in critical domain
- requests rule tuning

Daemon audit must record source views, rules, output type, scope, and derived status.

---

## 21. Daemon Alert Families

| Alert Family | Meaning |
|---|---|
| `ALERT_DAEMON_RULE_MATCHED` | Deterministic daemon rule matched |
| `ALERT_DAEMON_HIGH_RISK_PATTERN` | High-risk pattern detected |
| `ALERT_DAEMON_CONTAINMENT_CANDIDATE` | Containment candidate detected |
| `ALERT_DAEMON_QUARANTINE_CANDIDATE` | Quarantine candidate detected |
| `ALERT_DAEMON_RECONCILIATION_CANDIDATE` | Reconciliation candidate detected |
| `ALERT_DAEMON_EVIDENCE_GAP` | Evidence gap detected |
| `ALERT_DAEMON_AUDIT_GAP` | Audit gap detected |
| `ALERT_DAEMON_AI_OUTPUT_BLOCKED` | AI output blocked by policy |
| `ALERT_DAEMON_PGVECTOR_BLOCKED` | pgvector request blocked by policy |
| `ALERT_DAEMON_DEGRADED_MODE` | Degraded mode active |
| `ALERT_DAEMON_RULE_TUNING_REQUESTED` | Rule tuning requested |
| `ALERT_DAEMON_SCOPE_VIOLATION` | Daemon attempted disallowed scope |

---

## 22. Daemon Status Catalog

| Status | Meaning |
|---|---|
| `DAEMON_NOT_ENABLED` | Daemon not enabled |
| `DAEMON_PLANNED_ONLY` | Planning only |
| `DAEMON_RULE_ONLY_READY_CANDIDATE` | Deterministic rules candidate-ready |
| `DAEMON_AI_ASSIST_READY_CANDIDATE` | AI assist candidate-ready |
| `DAEMON_PGVECTOR_ASSIST_READY_CANDIDATE` | pgvector assist candidate-ready |
| `DAEMON_DEGRADED_MODE` | Degraded mode active |
| `DAEMON_BLOCKED_BY_POLICY` | Blocked by policy |
| `DAEMON_REVIEW_REQUIRED` | Review required |
| `DAEMON_OUTPUT_DERIVED_ONLY` | Outputs derived only |
| `DAEMON_RUNTIME_NOT_AUTHORIZED` | Runtime not authorized |

Default status for this document:

`DAEMON_RUNTIME_NOT_AUTHORIZED`

---

## 23. i18n Rule For Daemon Outputs

Daemon outputs are internal by default.

If daemon output feeds visible alerts or support/customer messages, it must use approved message keys.

The daemon must not create final customer-facing text.

AI-generated text may be drafted only under support/content approval.

Message key pattern:

`daemon.<domain>.<output_type>.<surface>.<message_type>`

Hardcoded customer-visible daemon text is prohibited.

---

## 24. Retention And Archive Rule

Daemon outputs must carry retention class.

Suggested retention classes:

- `RETENTION_HOT_LIVE`
- `RETENTION_SECURITY_LONG_TERM`
- `RETENTION_FINANCIAL_LONG_TERM`
- `RETENTION_LEGAL_HOLD_CANDIDATE`
- `RETENTION_AI_DERIVED_REVIEW`
- `RETENTION_VECTOR_DERIVED_REVIEW`

Daemon outputs that influence high-risk decisions must be archived with traceability.

AI-derived and vector-derived outputs must remain linked to source summaries and lifecycle.

---

## 25. Daemon Readiness Blockers

| Blocker ID | Meaning |
|---|---|
| `BLOCKER-DAEMON-CONTRACT-0001` | Daemon contract not reviewed |
| `BLOCKER-DAEMON-INPUT-SOURCE-0001` | Input source catalog incomplete |
| `BLOCKER-DAEMON-OUTPUT-0001` | Output classification incomplete |
| `BLOCKER-DAEMON-RULE-FILTER-0001` | Deterministic rule catalog incomplete |
| `BLOCKER-DAEMON-AI-BOUNDARY-0001` | AI boundary incomplete |
| `BLOCKER-DAEMON-PGVECTOR-BOUNDARY-0001` | pgvector boundary incomplete |
| `BLOCKER-DAEMON-AUTHORITY-0001` | Prohibited authority catalog incomplete |
| `BLOCKER-DAEMON-DEGRADED-0001` | Degraded mode policy incomplete |
| `BLOCKER-DAEMON-FALSE-POSITIVE-0001` | False-positive review missing |
| `BLOCKER-DAEMON-RULE-TUNING-0001` | Rule tuning governance missing |
| `BLOCKER-DAEMON-AUDIT-0001` | Daemon audit rule missing |
| `BLOCKER-DAEMON-RUNTIME-0001` | Daemon runtime not authorized |

Open daemon blockers prevent daemon implementation.

---

## 26. Validation Checklist

Validation must confirm:

- daemon reads only approved monitoring views
- daemon does not scan raw hot tables by default
- daemon has deterministic first-stage rules
- daemon AI use is assistance-only
- daemon pgvector use is similarity-only
- daemon output is marked derived
- daemon cannot mutate source truth
- daemon cannot approve money/value/identity action
- daemon cannot publish projection/content
- daemon cannot resolve support case
- daemon cannot confirm provider capability
- daemon cannot release containment
- daemon cannot release quarantine
- degraded mode exists
- false-positive review exists
- rule tuning governance exists
- high-risk daemon output has audit requirement
- coding remains deferred

---

## 27. Relationship To Previous Documents

This document implements Artifact Group F from:

- `21630 Financial-Grade Security Monitoring Foundation Catalog Execution Plan And Artifact Map`

It follows:

- `21638 Monitoring View And Risk Projection Contract`

It depends on:

- `21631 Bulkhead Domain Map Source Of Truth And Trust Boundary Catalog`
- `21632 Containment Status And Trigger Map Catalog`
- `21633 Quarantine Status And Trigger Map Catalog`
- `21634 Security Control Records And Security Class Catalog`
- `21635 Security Event Alert Families And Severity Routing Catalog`
- `21636 Unix-Style Error Code Catalog And Domain Fault Mapping Policy`
- `21637 Trigger Signal Audit Packet Contract And Lightweight Capture Policy`
- `21580 AI Daemon Security Monitoring Agent And Autonomous Containment Policy`
- `21590 Trigger View Agent Monitoring Pipeline And Audit Projection Policy`

This document is Foundation-grade and contract-only.

It does not authorize coding.

---

## 28. Final Rule

The AI daemon is a monitoring assistant, not an authority.

It may observe approved monitoring views, apply deterministic rules, request approved pgvector similarity review, create derived summaries, identify evidence/audit gaps, and recommend review routes.

It must not mutate runtime truth, approve financial/value/identity actions, confirm provider capability, publish content/projection, close support cases, release containment, release quarantine, suppress alerts without review, or bypass audit.

Critical financial/security detection must not depend only on AI.

The daemon must begin with deterministic rules and remain bounded by Foundation security controls.

Coding remains deferred until this daemon boundary contract and rule-based filter catalog are reviewed, validated, and attached to package-specific entry gates.
