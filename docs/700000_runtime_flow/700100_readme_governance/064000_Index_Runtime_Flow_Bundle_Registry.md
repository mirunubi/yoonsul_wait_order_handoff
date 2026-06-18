# 064000_Index_Runtime_Flow_Bundle_Registry.md

## 1. Document Control

| Field | Value |
|---|---|
| Document ID | 64000 |
| DocumentType | Index |
| Filename | 064000_Index_Runtime_Flow_Bundle_Registry.md |
| Project | yoonsul_wait_order_handoff |
| Service Names | CatchMenu / Catch & Order |
| Band | 64000 Runtime Flow Registry |
| Audience | Architecture, Backend, POS Gateway, Security, QA, DevOps, Audit Owner |
| Status | Draft |
| Governance Level | Financial-grade runtime implementation control |
| Related SOP Range | Operation SOP: 00010~49999 / System SOP: 50000~99999 |

---

## 2. Purpose

This index establishes the Runtime Flow Bundle Registry for CatchMenu / Catch & Order.

The project no longer treats one Markdown document as one implementation unit. Individual Markdown files remain policy, contract, SOP, evidence, audit, checklist, matrix, and governance units. Actual implementation must be managed as a Flow Bundle that groups multiple related Markdown documents, runtime modules, database objects, tests, evidence packets, and deployment controls.

This rule is mandatory because CatchMenu / Catch & Order is no longer a simple waiting or ordering application. It now touches POS, PG/VAN, payment approval, cancellation, refund, settlement, reconciliation, audit ledger, event immutability, security credentials, webhook verification, and operational evidence. Therefore, the implementation boundary must be controlled at the flow level.

---

## 3. Core Principle

### 3.1 Previous Incorrect Assumption

```text
One MD file = one implementation unit
```

This assumption is not allowed for financial-grade runtime areas.

A single Markdown file may define one policy or one contract, but real implementation normally crosses multiple areas such as gateway routing, approval state, idempotency, retry, webhook verification, local ledger, settlement, audit ledger, reconciliation, monitoring, and evidence export.

### 3.2 New Required Assumption

```text
One Flow Bundle = one controlled implementation unit
```

A Flow Bundle must connect the following layers before code modification begins:

```text
Flow Step → Module → File → Test → Evidence
```

No AI coding agent, including Claude Code or Cursor, may modify production-facing payment, settlement, audit, security, migration, secret, or deployment logic before the related Flow Bundle control artifacts are prepared.

---

## 4. Scope

This registry applies to all runtime flows that affect or may affect:

- POS Gateway integration
- PG/VAN approval and cancellation flows
- Payment timeout, retry, duplicate prevention, DLQ, and replay
- Store offline local ledger and resync
- Webhook inbound verification and event normalization
- Settlement, dispute, evidence export, and accounting support
- Financial-grade audit ledger
- Reconciliation and tamper-evidence governance
- Security credentials, webhook secrets, key rotation, and environment isolation
- DB migration, schema change, backfill, and cutover
- Runtime deployment, rollback, degraded mode, and incident evidence

---

## 5. Runtime Flow Registry Band

The 64000 band is reserved for Runtime Flow Bundle Architecture and implementation-control mapping.

| Number | Filename | DocumentType | Purpose | Status |
|---:|---|---|---|---|
| 64000 | 064000_Index_Runtime_Flow_Bundle_Registry.md | Index | Registry root for Flow Bundle implementation governance | Draft |
| 64100 | 064100_Flow_POS_Gateway_Approval_To_Audit_Ledger_And_Reconciliation.md | Flow | Approval-to-ledger-to-reconciliation runtime bundle | Planned |
| 64110 | 064110_Flow_POS_Gateway_Cancel_Refund_Recovery_And_Audit.md | Flow | Cancellation, refund, recovery, and audit bundle | Planned |
| 64120 | 064120_Flow_POS_Gateway_Timeout_Retry_DLQ_And_Replay.md | Flow | Timeout, retry, dead-letter queue, replay, and duplicate prevention bundle | Planned |
| 64130 | 064130_Flow_POS_Gateway_Store_Offline_Local_Ledger_And_Resync.md | Flow | Store offline local ledger and server resync bundle | Planned |
| 64140 | 064140_Flow_POS_Gateway_Webhook_Inbound_Verification_And_Event_Normalization.md | Flow | Webhook signature verification and inbound event normalization bundle | Planned |
| 64150 | 064150_Flow_POS_Gateway_Settlement_Dispute_And_Evidence_Export.md | Flow | Settlement, dispute, accounting support, and evidence export bundle | Planned |
| 64200 | 064200_Matrix_Flow_To_MD_Dependency_Graph.md | Matrix | Cross-flow Markdown dependency graph | Planned |
| 64210 | 064210_Matrix_Flow_To_Module_Implementation_Map.md | Matrix | Flow-to-module implementation impact map | Planned |
| 64220 | 064220_Matrix_Flow_To_Test_Coverage_Map.md | Matrix | Flow-to-test coverage and evidence map | Planned |

---

## 6. Mandatory Flow Bundle Artifacts

Every Flow Bundle must prepare the following four artifacts before implementation begins.

### 6.1 MD Dependency Graph

The MD Dependency Graph identifies all policy, SOP, contract, audit, security, runtime, and evidence documents that constrain the flow.

Minimum contents:

- Primary source documents
- Upstream dependencies
- Downstream dependencies
- Security and audit documents
- POS/PG/VAN provider-specific documents
- Settlement and accounting documents
- Evidence and retention documents
- Conflict or ambiguity notes
- Documents that must be updated when the flow changes

Required output form:

```text
Flow Bundle
 ├─ Primary MDs
 ├─ Security / Audit MDs
 ├─ Runtime / Module MDs
 ├─ Test / Evidence MDs
 └─ Open Gaps / Required New MDs
```

### 6.2 Runtime Flow Diagram

The Runtime Flow Diagram describes the actual runtime sequence, not merely the document sequence.

Minimum contents:

- Actor or system initiator
- POS, PG/VAN, gateway, internal service, ledger, audit, and reconciliation boundaries
- Synchronous and asynchronous steps
- Timeout and retry boundaries
- Idempotency key points
- Failure states
- Compensation or recovery path
- Audit event emission points
- Evidence capture points

Required output form:

```text
Step → Runtime Actor → Module → State Change → Event → Audit/Evidence
```

### 6.3 Module Impact Map

The Module Impact Map defines which runtime modules and code areas may be affected.

Minimum contents:

- Backend service modules
- API routes or RPC boundaries
- Queue, worker, scheduler, and replay modules
- Database tables, views, functions, triggers, and migrations
- Secret and credential touchpoints
- Admin console or operator UI impact
- Monitoring, alert, and dashboard impact
- External provider adapter impact
- Files that are allowed to be edited
- Files that are explicitly forbidden without human approval

Required output form:

```text
Flow Step → Module → File Path → Change Type → Risk Level → Approval Required
```

### 6.4 Test Coverage Map

The Test Coverage Map ensures that no flow enters implementation without verification scope.

Minimum contents:

- Unit tests
- Integration tests
- Contract tests
- Idempotency tests
- Retry and timeout tests
- DLQ and replay tests
- Webhook signature tests
- Ledger immutability tests
- Reconciliation tests
- Migration and rollback tests
- Security regression tests
- Evidence packet validation
- Manual QA or pilot-store verification

Required output form:

```text
Flow Step → Test Type → Test File → Expected Evidence → Owner → Gate
```

---

## 7. AI Coding Agent Governance

### 7.1 Claude Code Role

Claude Code may be used as a Flow Bundle implementation agent only after the required four Flow Bundle artifacts are prepared.

Allowed role:

- Implement bounded changes inside an approved Flow Bundle
- Generate implementation plans from Flow Step → Module → File → Test → Evidence maps
- Draft code for non-forbidden areas
- Generate or update tests when the test coverage map is defined
- Produce implementation diffs for human review

Not allowed role:

- Independently redefine payment, settlement, audit, migration, secret, or deployment architecture
- Modify production-facing financial logic without explicit approval
- Decide provider-specific PG/VAN behavior without approved contract documents
- Change database migration or rollback strategy alone
- Change secret handling, key rotation, webhook credentials, or environment isolation alone

### 7.2 Cursor Role

Cursor is treated as an IDE and local partial-modification assistant.

Allowed role:

- Navigate related files
- Apply small reviewed edits
- Refactor approved local code areas
- Help inspect dependency references
- Update comments, tests, and minor implementation details under a prepared Flow Bundle

Not allowed role:

- Act as the primary architecture decision maker
- Modify multiple runtime modules without a Flow Bundle map
- Infer financial-grade behavior from one Markdown file alone
- Perform broad automatic edits across payment, audit, reconciliation, migration, or secret areas

---

## 8. AI Modification Prohibition Zones

The following areas are AI 단독 수정 금지 영역. AI may assist, but human approval and evidence control are mandatory.

| Zone | Examples | Required Control |
|---|---|---|
| Payment Approval | 승인 요청, 승인 응답, 승인번호, 금액, 통화, provider transaction id | Flow Bundle + human review + test evidence |
| Cancellation / Refund | 부분취소, 전체취소, 중복취소, 환불 실패 복구 | Flow Bundle + provider contract + audit evidence |
| Settlement / Reconciliation | 정산 집계, PG/VAN 대사, 순매출, 수수료, 회계 증빙 | Flow Bundle + accounting/audit review |
| Audit Ledger | 불변 원장, tamper evidence, legal hold, export retention | System SOP + WORM/retention evidence |
| DB Migration | schema change, backfill, cutover, rollback | Migration plan + dry run + rollback evidence |
| Secrets / Credentials | webhook secret, API key, token, key rotation, vault | Security owner approval + rotation evidence |
| Production Deployment | release, rollback, feature flag, incident response | Release gate + monitoring + operator sign-off |
| Security Boundary | signature verification, RBAC/ABAC, provider trust boundary | Security review + regression tests |

---

## 9. Implementation Control Sequence

All implementation work must follow this sequence.

```text
1. Select Flow Bundle
2. Build MD Dependency Graph
3. Build Runtime Flow Diagram
4. Build Module Impact Map
5. Build Test Coverage Map
6. Identify AI Modification Prohibition Zones
7. Prepare Claude Code implementation prompt
8. Restrict Cursor edits to approved files only
9. Execute tests
10. Produce evidence packet
11. Human review and approval
12. Merge / deploy / monitor
13. Update registry and dependent MDs
```

Implementation is blocked if any of steps 2 through 5 are missing.

---

## 10. Flow Bundle Status Model

Each Flow Bundle must have one of the following statuses.

| Status | Meaning | Code Modification Allowed |
|---|---|---|
| Planned | Flow is listed but not analyzed | No |
| Mapping | Dependency and runtime maps are being prepared | No |
| Review Ready | Four required artifacts are prepared | Limited review-only diff generation |
| Implementation Ready | Human owner approved implementation scope | Yes, within approved file map |
| Test Evidence Pending | Code exists, tests/evidence incomplete | No production merge |
| Release Candidate | Tests and evidence complete | Release review required |
| Released | Merged and deployed under governance | Monitoring required |
| Suspended | Risk, conflict, or provider uncertainty found | No |

---

## 11. Evidence Packet Requirements

Every Flow Bundle implementation must produce an evidence packet.

Minimum evidence:

- Flow Bundle ID and filename
- MD Dependency Graph version
- Runtime Flow Diagram version
- Module Impact Map version
- Test Coverage Map version
- AI prompt used for Claude Code, if applicable
- Cursor edit summary, if applicable
- Git diff summary
- Test execution result
- Failed test explanation, if any
- Security review note, if applicable
- Migration dry-run result, if applicable
- Provider sandbox evidence, if applicable
- Audit ledger sample event evidence, if applicable
- Operator or owner approval note
- Release or rollback decision

---

## 12. Relationship To Existing Document Bands

The Runtime Flow Registry does not replace existing policy, SOP, WorkPackage, security, audit, or implementation planning documents. It binds them into implementation-safe bundles.

| Existing Band / Area | Relationship |
|---|---|
| 00100 Project Foundation | Security, naming, governance, and project-level constraints feed into Flow Bundles |
| 04000 Store Runtime POS/KDS Operations | POS/KDS operational boundaries become runtime dependencies |
| 04900 Security Runtime Test Catalog | Security test and evidence requirements feed into Flow Test Coverage Maps |
| 05000 Customer Handoff And Implementation Readiness | First-store/pilot readiness evidence feeds into release gates |
| 06300 POS Gateway WorkPackage Area | POS Gateway work packages become primary source documents for 64100~64150 flows |
| 50000+ System SOP Area | Audit, legal hold, retention, export, and system governance constrain all financial-grade flows |
| 64000 Runtime Flow Registry | Converts MD-level governance into implementation-safe Flow Bundles |

---

## 13. Naming Rule Confirmation

This registry follows the approved naming rule.

```text
{FiveDigitNumber}_{DocumentType}_{Descriptive_Title}.md
```

This document therefore uses:

```text
064000_Index_Runtime_Flow_Bundle_Registry.md
```

Rules applied:

- Five-digit number is retained.
- DocumentType Prefix appears immediately after the number.
- Spaces are not used.
- Underscores are used as separators.
- H1 includes the exact full filename with `.md` extension.
- 64000 band is treated as a System-side runtime governance band.
- Operation SOP remains 00010~49999.
- System SOP remains 50000~99999.

---

## 14. Initial Flow Bundle Backlog

The following Flow Bundles are the initial implementation-control candidates.

### 14.1 64100 Approval To Audit Ledger And Reconciliation

Primary question:

```text
How does an approved POS/PG/VAN payment become an internal authoritative transaction, an audit ledger event, and a reconciliation target without duplicate approval, missing event, or tamper risk?
```

Expected artifacts:

- MD Dependency Graph
- Runtime approval sequence
- Module impact map
- Approval/reconciliation test coverage map

### 14.2 64110 Cancel Refund Recovery And Audit

Primary question:

```text
How does cancellation or refund occur safely when provider state, internal state, local store state, and audit state may diverge?
```

Expected artifacts:

- Cancel/refund dependency graph
- Compensation and recovery flow diagram
- Provider adapter impact map
- Duplicate cancel/refund test map

### 14.3 64120 Timeout Retry DLQ And Replay

Primary question:

```text
How does the system handle timeout, retry, dead-letter queue, replay, and duplicate prevention without creating duplicate payment or ledger corruption?
```

Expected artifacts:

- Retry/idempotency dependency graph
- Timeout and replay runtime diagram
- Queue/worker/module impact map
- Retry, DLQ, replay, and idempotency test map

### 14.4 64130 Store Offline Local Ledger And Resync

Primary question:

```text
How does a store continue or recover operation when network, POS, or server connectivity is degraded, and how is local ledger state safely resynced?
```

Expected artifacts:

- Offline/local ledger dependency graph
- Offline/resync runtime diagram
- Local storage and sync module impact map
- Conflict resolution and resync test map

### 14.5 64140 Webhook Inbound Verification And Event Normalization

Primary question:

```text
How does the system verify inbound provider webhooks, normalize events, prevent spoofing/replay, and preserve audit-grade evidence?
```

Expected artifacts:

- Webhook/security dependency graph
- Signature verification and normalization diagram
- Webhook adapter and event module impact map
- Signature, replay, malformed payload, and normalization test map

### 14.6 64150 Settlement Dispute And Evidence Export

Primary question:

```text
How does the system support settlement, dispute investigation, accounting proof, and evidence export without weakening retention, privacy, or tamper-evidence controls?
```

Expected artifacts:

- Settlement/dispute dependency graph
- Evidence export runtime diagram
- Accounting/audit/export module impact map
- Settlement, dispute, export, and retention test map

---

## 15. Claude Code Prompt Gate

Claude Code prompts must not say:

```text
Read this one MD file and implement it.
```

Claude Code prompts must say:

```text
Implement only the approved scope of Flow Bundle {ID}.
Use the attached MD Dependency Graph, Runtime Flow Diagram, Module Impact Map, and Test Coverage Map.
Do not modify files outside the approved file list.
Do not modify payment, settlement, audit, migration, secret, or deployment logic unless the map explicitly marks it as approved.
Return a diff summary, test commands, test results, and evidence notes.
```

---

## 16. Cursor Prompt Gate

Cursor prompts must not say:

```text
Search the repo and fix related files automatically.
```

Cursor prompts must say:

```text
Within Flow Bundle {ID}, inspect only the approved files listed in the Module Impact Map.
Make only the requested local edit.
Do not infer cross-module changes.
Do not touch forbidden zones.
Report any dependency conflict instead of fixing it automatically.
```

---

## 17. Open Governance Items

The following governance items must be resolved as the 64100~64220 documents are created.

| Item | Required Decision |
|---|---|
| Flow Bundle ID format | Confirm whether runtime flow ID equals filename number or uses separate runtime key |
| Evidence packet folder | Confirm location for Flow Bundle evidence artifacts |
| Mermaid diagram standard | Confirm whether diagrams are embedded in Flow docs or exported separately |
| Module map source | Confirm whether Cursor-generated repo maps are allowed as draft only |
| Claude prompt archive | Confirm whether AI prompts are preserved as implementation evidence |
| Financial review owner | Assign human owner for payment/settlement/audit changes |
| Security review owner | Assign human owner for secret/webhook/migration/security changes |
| Release gate owner | Assign owner for deployment, rollback, and monitoring sign-off |

---

## 18. Next Document

The recommended next document is:

```text
064100_Flow_POS_Gateway_Approval_To_Audit_Ledger_And_Reconciliation.md
```

That document should become the first concrete Flow Bundle and must include:

- MD Dependency Graph
- Runtime Flow Diagram
- Module Impact Map
- Test Coverage Map
- Claude Code prompt gate
- Cursor prompt gate
- AI modification prohibition notes
- Evidence packet checklist

---

## 19. Revision Log

| Version | Date | Summary |
|---|---|---|
| 0.1 | 2026-06-17 | Initial Runtime Flow Bundle Registry created for CatchMenu / Catch & Order financial-grade implementation governance |
