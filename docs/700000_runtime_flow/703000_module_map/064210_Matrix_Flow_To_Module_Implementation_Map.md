# 064210_Matrix_Flow_To_Module_Implementation_Map.md

## 1. Document Control

| Field | Value |
|---|---|
| Document ID | 64210 |
| Document Type | Matrix |
| File Name | 064210_Matrix_Flow_To_Module_Implementation_Map.md |
| Runtime Band | 64000 Runtime Flow Bundle Registry |
| Project | yoonsul_wait_order_handoff |
| Service Names | CatchMenu / Catch & Order |
| Scope | Flow Bundle to Runtime Module Implementation Mapping |
| Status | Draft |
| Owner | System Architecture / POS Gateway / Financial Audit Governance |
| Related Index | 064000_Index_Runtime_Flow_Bundle_Registry.md |
| Previous Document | 064200_Matrix_Flow_To_MD_Dependency_Graph.md |
| Next Document | 064220_Matrix_Flow_To_Test_Coverage_Map.md |

---

## 2. Purpose

This matrix defines how each Runtime Flow Bundle is mapped to implementation modules.

The purpose is to prevent the mistake of treating one Markdown document as one implementation unit.
In CatchMenu / Catch & Order, a real implementation unit is a Flow Bundle that crosses multiple policy, contract, ledger, audit, payment, retry, settlement, and evidence documents.

This document must be used before assigning implementation work to Claude Code, Cursor, or any human developer.

---

## 3. Core Rule

Implementation must be managed in the following order:

```text
Flow Step
→ Module
→ File
→ Test
→ Evidence
```

No module may be changed directly from a single MD instruction unless the related Flow Bundle mapping has already been reviewed.

---

## 4. AI Tool Boundary

| Tool | Allowed Role | Not Allowed Role |
|---|---|---|
| Claude Code | Flow Bundle implementation agent | Independent financial/security/database decision maker |
| Cursor | IDE assistant, local refactor, small patch support | Flow owner, payment logic owner, migration owner |
| Human Architect | Flow acceptance, module approval, financial/security boundary decision | None |
| Human Operator | Evidence review, release approval, incident acknowledgement | Direct code mutation without approved task |

Claude Code and Cursor may not independently modify the following areas:

- Payment approval semantics
- Cancel/refund semantics
- Settlement logic
- Audit ledger immutability
- DB migration
- Secret handling
- Webhook signature verification
- Production deployment workflow
- Recovery replay policy
- Financial reconciliation logic

---

## 5. Runtime Module Families

| Module Family | Description |
|---|---|
| POS Gateway Adapter | Provider-specific POS/PG/VAN request and response adaptation |
| Payment Orchestrator | Approval, cancel, refund, timeout, and recovery state orchestration |
| Idempotency Service | Duplicate prevention, request fingerprinting, idempotency key control |
| Event Normalizer | External event normalization into canonical internal event format |
| Ledger Writer | Append-only financial and operational ledger write path |
| Audit Ledger Service | Immutable audit evidence, tamper detection, legal hold, export control |
| Reconciliation Engine | Internal ledger vs POS/PG/VAN/settlement file reconciliation |
| Retry Scheduler | Retry timing, backoff, retry eligibility, exhaustion handling |
| DLQ Processor | Dead letter queue classification, quarantine, replay authorization |
| Local Store Ledger | Offline store-side temporary ledger and deferred synchronization |
| Resync Coordinator | Offline-to-online merge, conflict handling, replay sequencing |
| Webhook Receiver | Inbound webhook verification, replay protection, event intake |
| Settlement Processor | Settlement import, fee adjustment, dispute correlation, closeout |
| Evidence Exporter | Evidence packet generation, export, retention, and access logging |
| Admin Console | Human review, approval, override, incident, and evidence visibility |
| Monitoring & Alerting | Metrics, anomaly detection, incident trigger, audit alerting |
| Secret & Credential Boundary | Secret vault, credential rotation, provider credential isolation |
| Test Harness | Contract tests, replay tests, financial scenario tests, regression suite |

---

## 6. Flow Bundle to Module Implementation Matrix

| Flow ID | Flow Bundle | Primary Modules | Supporting Modules | AI Direct Edit Allowed |
|---|---|---|---|---|
| 64100 | POS Gateway Approval To Audit Ledger And Reconciliation | POS Gateway Adapter, Payment Orchestrator, Ledger Writer, Audit Ledger Service, Reconciliation Engine | Idempotency Service, Event Normalizer, Admin Console, Monitoring & Alerting, Test Harness | No |
| 64110 | POS Gateway Cancel Refund Recovery And Audit | Payment Orchestrator, Ledger Writer, Audit Ledger Service, Reconciliation Engine | POS Gateway Adapter, Idempotency Service, Admin Console, Evidence Exporter, Monitoring & Alerting | No |
| 64120 | POS Gateway Timeout Retry DLQ And Replay | Retry Scheduler, DLQ Processor, Idempotency Service, Payment Orchestrator | Ledger Writer, Audit Ledger Service, Monitoring & Alerting, Admin Console, Test Harness | No |
| 64130 | POS Gateway Store Offline Local Ledger And Resync | Local Store Ledger, Resync Coordinator, Ledger Writer, Audit Ledger Service | Idempotency Service, Event Normalizer, Admin Console, Monitoring & Alerting, Test Harness | No |
| 64140 | POS Gateway Webhook Inbound Verification And Event Normalization | Webhook Receiver, Event Normalizer, Secret & Credential Boundary, Ledger Writer | Idempotency Service, Audit Ledger Service, Monitoring & Alerting, DLQ Processor, Test Harness | No |
| 64150 | POS Gateway Settlement Dispute And Evidence Export | Settlement Processor, Reconciliation Engine, Evidence Exporter, Audit Ledger Service | Ledger Writer, Admin Console, Monitoring & Alerting, Secret & Credential Boundary, Test Harness | No |

---

## 7. Module Responsibility Details

### 7.1 POS Gateway Adapter

Responsible for translating provider-specific POS, PG, VAN, or payment partner requests into the internal canonical command format.

Required responsibilities:

- Provider command mapping
- Provider response mapping
- Provider error code mapping
- Provider timeout classification
- Provider capability declaration
- Provider version compatibility record

Not responsible for:

- Final approval decision
- Internal ledger mutation policy
- Settlement adjustment
- Audit evidence export

---

### 7.2 Payment Orchestrator

Responsible for controlling payment state transitions across approval, cancel, refund, timeout, recovery, and replay.

Required responsibilities:

- Approval state transition
- Cancel/refund state transition
- Timeout state classification
- Recovery state transition
- Duplicate transition rejection
- Financial state machine enforcement

Not responsible for:

- Provider credential storage
- Raw webhook signature verification
- Final settlement fee calculation
- Manual evidence export approval

---

### 7.3 Idempotency Service

Responsible for preventing duplicate approval, duplicate cancel, duplicate refund, and duplicate replay.

Required responsibilities:

- Idempotency key generation and validation
- Request fingerprinting
- Duplicate command detection
- Replay eligibility check
- Retry correlation
- Conflict reason recording

Not responsible for:

- Changing financial outcome manually
- Deleting audit ledger records
- Replaying DLQ without approval

---

### 7.4 Event Normalizer

Responsible for converting external provider events and internal command results into canonical event objects.

Required responsibilities:

- Event schema normalization
- Provider status normalization
- Error class normalization
- Timestamp normalization
- Source identity tagging
- Event version tagging

Not responsible for:

- Trusting unsigned inbound events
- Writing final financial ledger without orchestration
- Approving settlement disputes

---

### 7.5 Ledger Writer

Responsible for append-only writing of operational and financial ledger records.

Required responsibilities:

- Append-only event write
- Ledger sequence control
- Ledger correlation ID preservation
- State transition evidence reference
- Write failure escalation

Not responsible for:

- Mutating historical ledger rows
- Hiding failed writes
- Performing manual reconciliation judgement

---

### 7.6 Audit Ledger Service

Responsible for immutable audit trail, tamper evidence, legal hold, export readiness, and financial-grade evidence control.

Required responsibilities:

- Audit event append
- Tamper evidence generation
- Hash chain or integrity marker management
- Legal hold marking
- Export access logging
- Retention class tagging

Not responsible for:

- Business state transition decision
- Provider-specific payment call
- UI-only approval without ledger basis

---

### 7.7 Reconciliation Engine

Responsible for comparing internal ledgers against POS, PG, VAN, settlement, and store-side records.

Required responsibilities:

- Approval reconciliation
- Cancel/refund reconciliation
- Settlement reconciliation
- Fee and amount mismatch detection
- Missing event detection
- Exception register generation

Not responsible for:

- Directly changing payment state without approved correction flow
- Suppressing mismatch without waiver evidence
- Creating provider credentials

---

### 7.8 Retry Scheduler

Responsible for controlled retry timing and retry eligibility.

Required responsibilities:

- Retry schedule calculation
- Backoff policy enforcement
- Retry limit enforcement
- Timeout-to-retry classification
- Retry attempt ledger link

Not responsible for:

- Infinite retry
- Payment replay without idempotency check
- Manual override without evidence

---

### 7.9 DLQ Processor

Responsible for dead-letter classification, quarantine, review, and approved replay.

Required responsibilities:

- DLQ intake
- DLQ reason tagging
- Replay safety check
- Manual approval link
- Replay result recording
- Permanent failure classification

Not responsible for:

- Blind automatic replay of financial events
- Deleting failed events to reduce noise
- Provider settlement correction

---

### 7.10 Local Store Ledger

Responsible for store-side temporary ledger capture during offline or degraded operation.

Required responsibilities:

- Local event capture
- Local sequence numbering
- Offline state marker
- Store device identity tagging
- Sync pending queue maintenance

Not responsible for:

- Final central financial confirmation
- Independent settlement confirmation
- Unverified local overwrite of central ledger

---

### 7.11 Resync Coordinator

Responsible for safe merge between offline local ledger and central ledger.

Required responsibilities:

- Resync sequencing
- Conflict detection
- Duplicate detection
- Central ledger merge request
- Resync result audit link
- Manual review escalation

Not responsible for:

- Silently resolving financial conflict
- Discarding local ledger without evidence
- Approving missing payment state by assumption

---

### 7.12 Webhook Receiver

Responsible for inbound provider event intake and trust-boundary enforcement.

Required responsibilities:

- Signature verification
- Timestamp freshness validation
- Replay attack prevention
- Source IP or provider identity control
- Raw event quarantine before trust
- Verification failure evidence logging

Not responsible for:

- Accepting unsigned event as final truth
- Directly modifying settlement state
- Exposing secrets in logs

---

### 7.13 Settlement Processor

Responsible for settlement import, amount comparison, fee adjustment, and dispute correlation.

Required responsibilities:

- Settlement file ingestion
- Settlement row normalization
- Fee/tax/commission comparison
- Dispute candidate detection
- Closeout readiness record
- Settlement exception packet generation

Not responsible for:

- Changing approval history
- Removing mismatch without waiver
- Legal evidence deletion

---

### 7.14 Evidence Exporter

Responsible for creating controlled evidence packets for audit, dispute, legal hold, or operator review.

Required responsibilities:

- Evidence packet assembly
- Export scope control
- PII minimization check
- Access authorization
- Export hash generation
- Export access log writing

Not responsible for:

- Free-form database dump
- Secret export
- Unlogged evidence access

---

### 7.15 Admin Console

Responsible for human-facing review, approval, incident, waiver, and evidence visibility.

Required responsibilities:

- Manual review queue
- Approval/waiver capture
- Incident linkage
- Exception register visibility
- Evidence packet request
- Role-based access control

Not responsible for:

- Direct production DB edit
- Secret display
- Financial replay without backend approval flow

---

### 7.16 Monitoring & Alerting

Responsible for detecting abnormal states, operational degradation, and financial risk.

Required responsibilities:

- Retry spike detection
- DLQ growth detection
- Webhook failure detection
- Reconciliation mismatch alert
- Settlement delay alert
- Audit ledger write failure alert

Not responsible for:

- Auto-resolving financial mismatch
- Masking alerts to avoid noise
- Acting as source of financial truth

---

### 7.17 Secret & Credential Boundary

Responsible for protecting provider credentials, webhook secrets, API keys, and signing materials.

Required responsibilities:

- Secret vault integration
- Credential rotation
- Provider credential separation
- Secret access logging
- Redaction policy
- Environment separation

Not responsible for:

- Application business logic
- Hardcoded secret fallback
- Developer-local secret sharing

---

### 7.18 Test Harness

Responsible for validating Flow Bundle behavior before implementation merge or release.

Required responsibilities:

- Contract tests
- State machine tests
- Retry/replay tests
- Ledger integrity tests
- Reconciliation tests
- Evidence export tests

Not responsible for:

- Replacing production audit
- Faking provider certification
- Approving release alone

---

## 8. Flow Step to Module Mapping

### 8.1 64100 Approval Flow

| Step | Runtime Step | Primary Module | Evidence Required |
|---|---|---|---|
| 1 | Receive approval command | POS Gateway Adapter | Request capture evidence |
| 2 | Normalize command | Event Normalizer | Canonical command snapshot |
| 3 | Check idempotency | Idempotency Service | Idempotency decision log |
| 4 | Execute provider approval | Payment Orchestrator / POS Gateway Adapter | Provider response evidence |
| 5 | Write financial ledger | Ledger Writer | Append-only ledger record |
| 6 | Write audit event | Audit Ledger Service | Tamper evidence marker |
| 7 | Reconcile result | Reconciliation Engine | Reconciliation status |
| 8 | Display operator status | Admin Console | UI decision trace |

---

### 8.2 64110 Cancel / Refund Flow

| Step | Runtime Step | Primary Module | Evidence Required |
|---|---|---|---|
| 1 | Receive cancel/refund request | Payment Orchestrator | Request basis |
| 2 | Validate original approval | Ledger Writer / Reconciliation Engine | Original approval link |
| 3 | Check duplicate cancellation | Idempotency Service | Duplicate check log |
| 4 | Execute provider cancel/refund | POS Gateway Adapter | Provider response evidence |
| 5 | Write reversal ledger | Ledger Writer | Reversal ledger record |
| 6 | Write audit trail | Audit Ledger Service | Audit trail marker |
| 7 | Reconcile reversal | Reconciliation Engine | Reversal reconciliation status |
| 8 | Prepare dispute evidence if mismatch | Evidence Exporter | Evidence packet reference |

---

### 8.3 64120 Timeout / Retry / DLQ / Replay Flow

| Step | Runtime Step | Primary Module | Evidence Required |
|---|---|---|---|
| 1 | Detect timeout | Payment Orchestrator | Timeout classification |
| 2 | Decide retry eligibility | Retry Scheduler | Retry decision log |
| 3 | Check idempotency | Idempotency Service | Duplicate prevention log |
| 4 | Execute retry | POS Gateway Adapter | Retry attempt evidence |
| 5 | Exhaust retry | Retry Scheduler | Retry exhaustion log |
| 6 | Move to DLQ | DLQ Processor | DLQ classification record |
| 7 | Request replay approval | Admin Console | Human approval record |
| 8 | Replay safely | DLQ Processor / Payment Orchestrator | Replay result evidence |

---

### 8.4 64130 Offline Local Ledger / Resync Flow

| Step | Runtime Step | Primary Module | Evidence Required |
|---|---|---|---|
| 1 | Detect offline state | Monitoring & Alerting | Offline detection log |
| 2 | Capture local event | Local Store Ledger | Local sequence record |
| 3 | Mark sync pending | Local Store Ledger | Pending sync record |
| 4 | Restore connectivity | Resync Coordinator | Connectivity recovery log |
| 5 | Compare local and central state | Resync Coordinator / Reconciliation Engine | Conflict check record |
| 6 | Merge safe records | Ledger Writer | Central append evidence |
| 7 | Escalate conflict | Admin Console | Manual review queue |
| 8 | Close resync | Audit Ledger Service | Resync audit marker |

---

### 8.5 64140 Webhook Inbound Verification Flow

| Step | Runtime Step | Primary Module | Evidence Required |
|---|---|---|---|
| 1 | Receive inbound webhook | Webhook Receiver | Raw event capture |
| 2 | Verify signature | Webhook Receiver / Secret & Credential Boundary | Signature verification log |
| 3 | Reject stale/replayed event | Webhook Receiver | Replay rejection evidence |
| 4 | Normalize event | Event Normalizer | Canonical event snapshot |
| 5 | Check idempotency | Idempotency Service | Duplicate event record |
| 6 | Route event | Payment Orchestrator / Ledger Writer | Routing decision |
| 7 | Write ledger/audit | Ledger Writer / Audit Ledger Service | Ledger and audit markers |
| 8 | Alert abnormal state | Monitoring & Alerting | Alert reference |

---

### 8.6 64150 Settlement / Dispute / Evidence Export Flow

| Step | Runtime Step | Primary Module | Evidence Required |
|---|---|---|---|
| 1 | Import settlement file | Settlement Processor | Import log |
| 2 | Normalize settlement rows | Settlement Processor | Normalized settlement snapshot |
| 3 | Match internal ledger | Reconciliation Engine | Match result |
| 4 | Detect mismatch/dispute | Reconciliation Engine | Exception register |
| 5 | Assemble evidence packet | Evidence Exporter | Evidence packet hash |
| 6 | Review dispute | Admin Console | Review decision |
| 7 | Apply approved correction path | Payment Orchestrator / Ledger Writer | Correction evidence |
| 8 | Close settlement period | Audit Ledger Service | Closeout audit marker |

---

## 9. Module Change Control Classification

| Module | Change Risk | Required Approval |
|---|---|---|
| POS Gateway Adapter | High | Flow Owner + Provider Integration Owner |
| Payment Orchestrator | Critical | Flow Owner + Financial Control Owner |
| Idempotency Service | Critical | Flow Owner + Financial Control Owner |
| Event Normalizer | High | Flow Owner + Integration Owner |
| Ledger Writer | Critical | Flow Owner + Audit Owner + DB Owner |
| Audit Ledger Service | Critical | Audit Owner + Security Owner |
| Reconciliation Engine | Critical | Financial Control Owner + Audit Owner |
| Retry Scheduler | High | Flow Owner + Operations Owner |
| DLQ Processor | Critical | Flow Owner + Operations Owner + Audit Owner |
| Local Store Ledger | High | Store Runtime Owner + Audit Owner |
| Resync Coordinator | Critical | Store Runtime Owner + Financial Control Owner |
| Webhook Receiver | Critical | Security Owner + Integration Owner |
| Settlement Processor | Critical | Financial Control Owner + Audit Owner |
| Evidence Exporter | Critical | Audit Owner + Legal/Privacy Owner |
| Admin Console | Medium/High | Product Owner + Security Owner |
| Monitoring & Alerting | Medium/High | Operations Owner |
| Secret & Credential Boundary | Critical | Security Owner |
| Test Harness | Medium | QA Owner + Flow Owner |

---

## 10. Repository Implementation Projection

The following repository paths are proposed implementation zones.
Actual path names may be changed by the repository owner, but every final path must be mapped back to this matrix.

| Module | Suggested Path Pattern |
|---|---|
| POS Gateway Adapter | `src/modules/pos_gateway/adapters/*` |
| Payment Orchestrator | `src/modules/pos_gateway/payment_orchestrator/*` |
| Idempotency Service | `src/modules/pos_gateway/idempotency/*` |
| Event Normalizer | `src/modules/pos_gateway/event_normalizer/*` |
| Ledger Writer | `src/modules/ledger/writer/*` |
| Audit Ledger Service | `src/modules/audit_ledger/*` |
| Reconciliation Engine | `src/modules/reconciliation/*` |
| Retry Scheduler | `src/modules/retry_scheduler/*` |
| DLQ Processor | `src/modules/dlq/*` |
| Local Store Ledger | `src/modules/store_offline/local_ledger/*` |
| Resync Coordinator | `src/modules/store_offline/resync/*` |
| Webhook Receiver | `src/modules/webhook_receiver/*` |
| Settlement Processor | `src/modules/settlement/*` |
| Evidence Exporter | `src/modules/evidence_export/*` |
| Admin Console | `src/apps/admin_console/*` |
| Monitoring & Alerting | `src/modules/observability/*` |
| Secret & Credential Boundary | `src/modules/security/secrets/*` |
| Test Harness | `tests/flow_bundles/*` |

---

## 11. Required Implementation Ticket Template

Every Flow Bundle implementation ticket must include the following fields:

```yaml
flow_bundle_id:
flow_bundle_name:
target_modules:
target_files:
blocked_modules:
related_md_documents:
runtime_flow_steps:
state_machine_impact:
ledger_impact:
audit_impact:
security_impact:
db_migration_required:
secret_change_required:
test_files:
evidence_outputs:
human_approval_required:
rollback_plan:
release_gate:
```

---

## 12. Claude Code Work Instruction Format

Claude Code must be given Flow Bundle work in this format:

```text
Implement only the approved Flow Bundle scope.

Flow Bundle:
- ID:
- Name:

Allowed modules:
-

Forbidden areas:
- Payment semantics not listed in the approved flow
- Settlement logic outside approved scope
- Audit ledger mutation outside append-only path
- DB migration unless explicitly approved
- Secret handling unless explicitly approved
- Production deployment scripts

Required output:
1. Modified files
2. New tests
3. Flow Step coverage explanation
4. Evidence output mapping
5. Risk notes
6. Items requiring human review
```

Claude Code must not be instructed with a single MD file alone.
It must always receive the Flow Bundle, module map, test coverage map, and evidence requirement.

---

## 13. Cursor Work Instruction Format

Cursor must be used for local editing support only.

Allowed Cursor tasks:

- Rename local symbols within approved module
- Add tests within approved test file
- Fix lint/type issues
- Apply small refactor approved by Flow Owner
- Generate boilerplate after module boundaries are fixed

Forbidden Cursor tasks:

- Decide payment state machine
- Rewrite ledger model
- Edit secret handling
- Edit migration scripts without approval
- Change deployment scripts
- Apply broad repository-wide patch
- Modify settlement logic without Flow Bundle ticket

---

## 14. Blocked Until Mapping Complete

The following work is blocked until this matrix and the related test coverage map are reviewed:

- POS approval implementation
- Cancel/refund implementation
- Timeout retry replay implementation
- Store offline ledger implementation
- Webhook inbound verification implementation
- Settlement/dispute evidence export implementation
- DB migration touching financial ledgers
- Audit ledger schema implementation
- Secret rotation automation
- Production release workflow

---

## 15. Evidence Requirements Per Module

| Module | Evidence Output |
|---|---|
| POS Gateway Adapter | Provider request/response mapping evidence |
| Payment Orchestrator | State transition evidence |
| Idempotency Service | Duplicate prevention decision evidence |
| Event Normalizer | Canonical event snapshot |
| Ledger Writer | Append-only ledger write reference |
| Audit Ledger Service | Tamper evidence marker |
| Reconciliation Engine | Match/mismatch report |
| Retry Scheduler | Retry schedule and exhaustion log |
| DLQ Processor | DLQ classification and replay approval record |
| Local Store Ledger | Local sequence ledger |
| Resync Coordinator | Resync merge/conflict report |
| Webhook Receiver | Signature and replay protection log |
| Settlement Processor | Settlement import and comparison report |
| Evidence Exporter | Evidence packet hash and access log |
| Admin Console | Human review and approval record |
| Monitoring & Alerting | Alert event reference |
| Secret & Credential Boundary | Secret access and rotation log |
| Test Harness | Test execution report |

---

## 16. Acceptance Criteria

This matrix is accepted only when:

- Every Flow Bundle has a primary module owner.
- Every critical module has a human approval owner.
- Every module has an evidence output.
- Every AI edit boundary is explicitly marked.
- Every proposed implementation path is mapped to a module.
- Every implementation ticket follows Flow Step → Module → File → Test → Evidence.
- The next test coverage matrix is created and linked.

---

## 17. Cross References

| Document | Relationship |
|---|---|
| 064000_Index_Runtime_Flow_Bundle_Registry.md | Parent runtime registry |
| 064100_Flow_POS_Gateway_Approval_To_Audit_Ledger_And_Reconciliation.md | Approval flow source |
| 064110_Flow_POS_Gateway_Cancel_Refund_Recovery_And_Audit.md | Cancel/refund flow source |
| 064120_Flow_POS_Gateway_Timeout_Retry_DLQ_And_Replay.md | Timeout/retry/replay flow source |
| 064130_Flow_POS_Gateway_Store_Offline_Local_Ledger_And_Resync.md | Offline/resync flow source |
| 064140_Flow_POS_Gateway_Webhook_Inbound_Verification_And_Event_Normalization.md | Webhook verification flow source |
| 064150_Flow_POS_Gateway_Settlement_Dispute_And_Evidence_Export.md | Settlement/dispute/evidence source |
| 064200_Matrix_Flow_To_MD_Dependency_Graph.md | MD dependency matrix |
| 064220_Matrix_Flow_To_Test_Coverage_Map.md | Required next test coverage matrix |

---

## 18. Final Rule

No implementation agent may be given code ownership over CatchMenu / Catch & Order POS Gateway financial flows unless this module implementation map is included in the task packet.

The minimum implementation packet is:

```text
1. Flow Bundle document
2. MD Dependency Graph
3. Module Implementation Map
4. Test Coverage Map
5. Evidence Output Requirement
6. Human Approval Boundary
```
