# 064200_Matrix_Flow_To_MD_Dependency_Graph.md

## 1. Document Control

| Field | Value |
|---|---|
| Document ID | 64200 |
| DocumentType | Matrix |
| Filename | 064200_Matrix_Flow_To_MD_Dependency_Graph.md |
| Project | yoonsul_wait_order_handoff |
| Service Names | CatchMenu / Catch & Order |
| Band | 64000 Runtime Flow Registry |
| Parent Index | 064000_Index_Runtime_Flow_Bundle_Registry.md |
| Audience | Architecture, Backend, POS Gateway, QA, Security, DevOps, Audit Owner, Implementation Agent Operator |
| Status | Draft |
| Governance Level | Financial-grade flow dependency control |
| Related SOP Range | Operation SOP: 00010~49999 / System SOP: 50000~99999 |

---

## 2. Purpose

This matrix defines the Markdown dependency graph for Runtime Flow Bundles in the `yoonsul_wait_order_handoff` / CatchMenu-Catch&Order project.

The project must not treat a single Markdown document as a complete implementation unit. Each Markdown file remains a policy, contract, SOP, evidence, checklist, matrix, audit, governance, or work package unit. Actual development must be controlled by Flow Bundles that gather all relevant documents and translate them into implementation, test, and evidence requirements.

This document answers one question before any AI coding agent is allowed to modify runtime code:

```text
Which Markdown documents govern this Flow Bundle, and what must be reviewed or updated together?
```

---

## 3. Dependency Graph Rule

Every Runtime Flow Bundle must maintain a document dependency graph with the following layers:

```text
Flow Bundle
 ├─ Primary Flow Definition MD
 ├─ Domain Policy / WorkPackage MDs
 ├─ Contract / Boundary / Interface MDs
 ├─ Security / Secret / Trust Boundary MDs
 ├─ Audit Ledger / Evidence / Retention MDs
 ├─ SOP / Runbook / Operation Control MDs
 ├─ Test / Checklist / Verification MDs
 └─ Required New MDs / Open Gaps
```

A Flow Bundle is not ready for implementation until its dependency graph has been checked and all blocking gaps are either resolved or formally waived.

---

## 4. Mandatory Review Gate

### 4.1 Implementation Gate

Claude Code, Cursor, or any AI-assisted coding tool must not be assigned production-facing code changes until the target Flow Bundle has completed:

1. MD Dependency Graph
2. Runtime Flow Diagram
3. Module Impact Map
4. Test Coverage Map

This document covers item 1 only.

### 4.2 Restricted AI Solo-Change Domains

The following domains must not be modified by AI alone:

- Payment approval state transition
- Cancel, refund, partial refund, and reversal logic
- Settlement and reconciliation calculation
- Audit ledger immutability and tamper-evidence logic
- DB migration, backfill, cutover, and production schema change
- Secret, webhook credential, key rotation, and environment isolation
- Production deployment, rollback, failover, and incident runbook logic
- Evidence retention, legal hold, and export authorization

AI may assist only after the Flow Bundle dependency graph and human review gate are complete.

---

## 5. Runtime Flow Bundle Registry Dependency Matrix

| Flow ID | Flow Bundle Document | Primary Runtime Area | Dependency Graph Status | Implementation Readiness |
|---:|---|---|---|---|
| 64100 | 064100_Flow_POS_Gateway_Approval_To_Audit_Ledger_And_Reconciliation.md | Approval, internal ledger, audit ledger, reconciliation | Draft dependency group defined in this matrix | Not ready until 64210 and 64220 complete |
| 64110 | 064110_Flow_POS_Gateway_Cancel_Refund_Recovery_And_Audit.md | Cancel, refund, recovery, audit reversal | Draft dependency group defined in this matrix | Not ready until 64210 and 64220 complete |
| 64120 | 064120_Flow_POS_Gateway_Timeout_Retry_DLQ_And_Replay.md | Timeout, retry, DLQ, replay, duplicate prevention | Draft dependency group defined in this matrix | Not ready until 64210 and 64220 complete |
| 64130 | 064130_Flow_POS_Gateway_Store_Offline_Local_Ledger_And_Resync.md | Store offline local ledger, resync, conflict recovery | Draft dependency group defined in this matrix | Not ready until 64210 and 64220 complete |
| 64140 | 064140_Flow_POS_Gateway_Webhook_Inbound_Verification_And_Event_Normalization.md | Webhook verification, inbound event normalization, quarantine | Draft dependency group defined in this matrix | Not ready until 64210 and 64220 complete |
| 64150 | 064150_Flow_POS_Gateway_Settlement_Dispute_And_Evidence_Export.md | Settlement, dispute, evidence export, legal hold | Draft dependency group defined in this matrix | Not ready until 64210 and 64220 complete |

---

## 6. Flow 64100 Dependency Graph

### 6.1 Flow

```text
064100_Flow_POS_Gateway_Approval_To_Audit_Ledger_And_Reconciliation.md
```

### 6.2 Primary Dependency Group

| Dependency Type | Document / Band | Reason |
|---|---|---|
| Parent Registry | 064000_Index_Runtime_Flow_Bundle_Registry.md | Establishes Flow Bundle implementation rule |
| Runtime Flow | 064100_Flow_POS_Gateway_Approval_To_Audit_Ledger_And_Reconciliation.md | Defines approval-to-ledger-to-reconciliation flow |
| POS Gateway WorkPackage | 06300~06390 POS Gateway WorkPackage band | Defines implementation planning, approval state, idempotency, retry, monitoring, reconciliation, and closeout boundaries |
| POS Gateway Resilience | 05300~05640 POS Gateway Resilience / Compliance policy band | Defines provider resilience, financial audit, regulatory, and consumer protection readiness |
| Store Runtime POS/KDS | 04000_store_runtime_pos_kds_operations band | Defines store operation boundary between POS, KDS, order, kitchen ticket, and recovery state |
| Customer Handoff Readiness | 05000_customer_handoff_and_implementation_readiness band | Defines first-store onboarding, evidence handoff, provider readiness, and rollout controls |
| Runtime Foundation | 10000_runtime_foundation_and_cross_room_architecture band | Defines cross-room event architecture and runtime federation rules |
| Data Model / State Machine | 09000_data_model_state_machine band | Defines canonical order, payment, event, ledger, and reconciliation states |
| Audit Ledger SOP | 50700_SOP_Index_Financial_Grade_Audit_Ledger_Legal_Hold_Export_Retention_And_Governance.md | Defines financial-grade audit ledger governance |
| Audit Ledger Source Registry | 50710_SOP_Audit_Ledger_Source_Registry_Event_Identity_Immutability_And_Tamper_Evidence_Governance_Operation.md | Defines event identity, immutability, and tamper-evidence controls |
| Security Runtime Test Catalog | 04900_security_runtime_test_catalog band | Defines security test catalog and runtime verification evidence |
| RPC Security | 04450 POS RPC security / trusted boundary document family | Defines POS-to-gateway secure communication boundary |
| Credential Governance | 04460 Webhook credential / secret rotation document family | Defines webhook and provider credential isolation requirements |
| Foundation Security | 00100_project_foundation security policy family | Defines secure coding, CI/DI protection, vault, RBAC/ABAC, patch, retention, and security governance |

### 6.3 Blocking Dependency Questions

- Is the approval event source of truth the POS, PG/VAN, internal gateway, or audit ledger for each state?
- Which event ID is canonical for approval deduplication?
- Which ledger entry is created before PG/VAN confirmation and which entry is created after confirmation?
- Which reconciliation discrepancy can be auto-classified and which requires human review?
- Which approval state transitions are allowed during provider timeout?

### 6.4 Required Update When 64100 Changes

Any material change to 64100 must trigger review of:

```text
064210_Matrix_Flow_To_Module_Implementation_Map.md
064220_Matrix_Flow_To_Test_Coverage_Map.md
50700+ Audit Ledger SOP family
06300~06390 POS Gateway WorkPackage family
09000 Data Model / State Machine family
04900 Security Runtime Test Catalog family
```

---

## 7. Flow 64110 Dependency Graph

### 7.1 Flow

```text
064110_Flow_POS_Gateway_Cancel_Refund_Recovery_And_Audit.md
```

### 7.2 Primary Dependency Group

| Dependency Type | Document / Band | Reason |
|---|---|---|
| Runtime Flow | 064110_Flow_POS_Gateway_Cancel_Refund_Recovery_And_Audit.md | Defines cancellation, refund, recovery, and audit reversal bundle |
| Upstream Approval Flow | 064100_Flow_POS_Gateway_Approval_To_Audit_Ledger_And_Reconciliation.md | Cancel/refund cannot exist without original approval and ledger reference |
| Timeout / Retry Flow | 064120_Flow_POS_Gateway_Timeout_Retry_DLQ_And_Replay.md | Cancel/refund must be idempotent under retry and provider uncertainty |
| POS Gateway WorkPackage | 06300~06390 POS Gateway WorkPackage band | Defines cancel/refund handling, queue, replay, and monitoring boundaries |
| Settlement Flow | 064150_Flow_POS_Gateway_Settlement_Dispute_And_Evidence_Export.md | Refund status affects settlement and dispute evidence |
| Audit Ledger SOP | 50700+ Financial Grade Audit Ledger SOP family | Defines reversal, append-only logging, evidence export, and retention |
| Consumer Protection | 05640_POS_Gateway_Compliance_Financial_Audit_Regulatory_And_Consumer_Protection_Readiness_Policy.md | Defines consumer protection and regulatory readiness constraints |
| Store Runtime Operation | 04000_store_runtime_pos_kds_operations band | Defines manual recovery and store-facing operational handling |
| Customer Support / AI Center | 08000_ai_customer_center band | May explain cancel/refund status but must not mutate financial state directly |
| Admin Console | 07000_admin_console band | Defines operator approval, dispute handling, and support escalation UI |

### 7.3 Blocking Dependency Questions

- Is a refund full, partial, same-day cancel, post-settlement refund, or provider reversal?
- Which actor is allowed to initiate each cancel/refund class?
- Which event proves that the refund was accepted by PG/VAN?
- How is an uncertain refund state represented without falsely showing success to the customer?
- What evidence is required for store dispute, customer dispute, and PG/VAN dispute?

### 7.4 Required Update When 64110 Changes

Any material change to 64110 must trigger review of:

```text
64100 approval flow
64120 retry / DLQ flow
64150 settlement / dispute flow
50700+ audit ledger SOP family
07000 admin console operator permission documents
08000 AI customer center answer boundary documents
```

---

## 8. Flow 64120 Dependency Graph

### 8.1 Flow

```text
064120_Flow_POS_Gateway_Timeout_Retry_DLQ_And_Replay.md
```

### 8.2 Primary Dependency Group

| Dependency Type | Document / Band | Reason |
|---|---|---|
| Runtime Flow | 064120_Flow_POS_Gateway_Timeout_Retry_DLQ_And_Replay.md | Defines timeout, retry, DLQ, replay, and duplicate prevention bundle |
| Approval Flow | 064100_Flow_POS_Gateway_Approval_To_Audit_Ledger_And_Reconciliation.md | Approval must be protected from duplicate charges |
| Cancel / Refund Flow | 064110_Flow_POS_Gateway_Cancel_Refund_Recovery_And_Audit.md | Refund and cancel retries must be idempotent and auditable |
| Webhook Flow | 064140_Flow_POS_Gateway_Webhook_Inbound_Verification_And_Event_Normalization.md | Provider callbacks may resolve pending timeout state |
| Offline Flow | 064130_Flow_POS_Gateway_Store_Offline_Local_Ledger_And_Resync.md | Offline replay and central DLQ replay must not conflict |
| POS Gateway Resilience | 05300~05640 resilience and compliance band | Defines capacity, load shedding, recovery, and consumer protection controls |
| Monitoring / Incident | 06390 POS Gateway monitoring, incident, DR, pilot readiness, closeout work package | Defines runtime incident and closeout criteria |
| Audit Ledger SOP | 50700+ audit ledger SOP family | Defines retry, replay, DLQ, and tamper-evident audit events |
| Security Runtime Test Catalog | 04900 security runtime test catalog | Defines attack/fault simulation requirements |
| Deployment Operations | 24000_deployment_operations band | Defines rollout, rollback, degraded mode, and incident deployment controls |

### 8.3 Blocking Dependency Questions

- What is the canonical idempotency key for approval, cancel, refund, webhook, and replay?
- What timeout is user-visible and what timeout is provider-internal?
- Which failed events enter DLQ and which remain pending?
- Who can replay a DLQ event and under what approval condition?
- How is duplicate replay blocked after a delayed provider success callback?

### 8.4 Required Update When 64120 Changes

Any material change to 64120 must trigger review of:

```text
64100 approval flow
64110 cancel/refund flow
64130 offline resync flow
64140 webhook normalization flow
04900 runtime security test catalog
24000 deployment operation runbooks
```

---

## 9. Flow 64130 Dependency Graph

### 9.1 Flow

```text
064130_Flow_POS_Gateway_Store_Offline_Local_Ledger_And_Resync.md
```

### 9.2 Primary Dependency Group

| Dependency Type | Document / Band | Reason |
|---|---|---|
| Runtime Flow | 064130_Flow_POS_Gateway_Store_Offline_Local_Ledger_And_Resync.md | Defines store offline local ledger and resync bundle |
| Timeout / Retry Flow | 064120_Flow_POS_Gateway_Timeout_Retry_DLQ_And_Replay.md | Offline retry and central retry must not create duplicate financial events |
| Approval Flow | 064100_Flow_POS_Gateway_Approval_To_Audit_Ledger_And_Reconciliation.md | Offline events must reconcile back to approval and ledger state |
| Store Runtime POS/KDS | 04000_store_runtime_pos_kds_operations band | Defines store operational recovery and POS/KDS continuity |
| Runtime Foundation | 10000 runtime foundation / cross-room architecture band | Defines event replay, cross-room sync, and runtime federation principles |
| Data Model / State Machine | 09000 data model and state machine band | Defines offline pending, provisional, synced, rejected, and conflict states |
| Audit Ledger SOP | 50700+ audit ledger SOP family | Defines offline event identity, immutability, and resync evidence |
| Deployment Operations | 24000 deployment operations band | Defines degraded operation, rollback, and incident runbook interaction |
| Admin Console | 07000 admin console band | Defines conflict review, manual correction, and resync visibility |
| Customer Support / AI Center | 08000 AI customer center band | Defines customer/store-facing explanation for pending or uncertain state |

### 9.3 Blocking Dependency Questions

- Is offline payment allowed, or only offline order capture and later payment resolution?
- Which local ledger fields are allowed to exist without server confirmation?
- What is the conflict rule when the same order changes on both local and central sides?
- Which resync failure becomes a store operation alert, and which becomes a financial incident?
- How long may an offline provisional state remain visible?

### 9.4 Required Update When 64130 Changes

Any material change to 64130 must trigger review of:

```text
64120 retry / DLQ / replay flow
64100 approval / reconciliation flow
04000 store runtime operation documents
09000 data model / state machine documents
50700+ audit ledger SOP family
24000 degraded operation runbooks
```

---

## 10. Flow 64140 Dependency Graph

### 10.1 Flow

```text
064140_Flow_POS_Gateway_Webhook_Inbound_Verification_And_Event_Normalization.md
```

### 10.2 Primary Dependency Group

| Dependency Type | Document / Band | Reason |
|---|---|---|
| Runtime Flow | 064140_Flow_POS_Gateway_Webhook_Inbound_Verification_And_Event_Normalization.md | Defines webhook verification, quarantine, and normalization bundle |
| Approval Flow | 064100_Flow_POS_Gateway_Approval_To_Audit_Ledger_And_Reconciliation.md | Provider callback may confirm or correct approval state |
| Cancel / Refund Flow | 064110_Flow_POS_Gateway_Cancel_Refund_Recovery_And_Audit.md | Provider callback may confirm or correct refund/cancel state |
| Timeout / Retry Flow | 064120_Flow_POS_Gateway_Timeout_Retry_DLQ_And_Replay.md | Webhook may resolve pending, timed-out, or retried events |
| Settlement Flow | 064150_Flow_POS_Gateway_Settlement_Dispute_And_Evidence_Export.md | Settlement evidence may depend on webhook normalized events |
| RPC / Trust Boundary | 04450 POS RPC security / trusted boundary family | Defines inbound trust boundary and gateway isolation |
| Credential / Secret Governance | 04460 webhook credential / secret rotation family | Defines signature key, secret rotation, and provider credential isolation |
| Security Runtime Test Catalog | 04900 security runtime test catalog | Defines replay attack, forged webhook, signature failure, and quarantine tests |
| Audit Ledger SOP | 50700+ audit ledger SOP family | Defines source identity, event hash, raw payload retention, and tamper-evidence |
| Data Model / Event Schema | 09000 data model and state machine band | Defines normalized event schema and provider-specific raw payload retention |

### 10.3 Blocking Dependency Questions

- Which headers, payload fields, timestamps, and signatures are required per provider?
- Is raw payload preserved before normalization and after rejection?
- What is the provider event identity when the provider sends duplicate callbacks?
- Which webhook failure is a security incident versus a provider retry issue?
- When does a normalized webhook mutate financial state, and when does it only create an audit observation?

### 10.4 Required Update When 64140 Changes

Any material change to 64140 must trigger review of:

```text
04450 trust boundary documents
04460 webhook secret / credential documents
04900 security runtime test catalog
64100 approval flow
64110 cancel/refund flow
64120 retry/DLQ flow
50700+ audit ledger SOP family
```

---

## 11. Flow 64150 Dependency Graph

### 11.1 Flow

```text
064150_Flow_POS_Gateway_Settlement_Dispute_And_Evidence_Export.md
```

### 11.2 Primary Dependency Group

| Dependency Type | Document / Band | Reason |
|---|---|---|
| Runtime Flow | 064150_Flow_POS_Gateway_Settlement_Dispute_And_Evidence_Export.md | Defines settlement, dispute, evidence export, and legal hold bundle |
| Approval Flow | 064100_Flow_POS_Gateway_Approval_To_Audit_Ledger_And_Reconciliation.md | Settlement depends on approved transaction ledger |
| Cancel / Refund Flow | 064110_Flow_POS_Gateway_Cancel_Refund_Recovery_And_Audit.md | Settlement depends on refund, cancel, and reversal status |
| Webhook Flow | 064140_Flow_POS_Gateway_Webhook_Inbound_Verification_And_Event_Normalization.md | Settlement evidence may include provider callbacks and normalized events |
| POS Gateway Compliance | 05640_POS_Gateway_Compliance_Financial_Audit_Regulatory_And_Consumer_Protection_Readiness_Policy.md | Defines financial audit and consumer protection readiness |
| Reconciliation WorkPackage | 06380 POS Gateway reconciliation, audit evidence, settlement, and accounting guard work package | Defines settlement matching and accounting guard boundary |
| Audit Ledger SOP | 50700+ audit ledger SOP family | Defines evidence export, retention, legal hold, immutable event trail |
| Admin Console | 07000 admin console band | Defines dispute review, export approval, and operator permission surface |
| Customer Support / AI Center | 08000 AI customer center band | Defines safe explanation boundary for settlement or refund dispute inquiries |
| Deployment / Operation | 24000 deployment operations band | Defines export job operations, incident handling, and rollback safety |

### 11.3 Blocking Dependency Questions

- Which settlement file is the provider source of truth for each PG/VAN?
- Which fee, adjustment, chargeback, and settlement discrepancy fields are supported in MVP?
- Which export requires legal hold, manager approval, or audit owner approval?
- What evidence packet fields are required for store dispute, customer dispute, and PG/VAN dispute?
- What information must not be exposed to AI customer center or store operators?

### 11.4 Required Update When 64150 Changes

Any material change to 64150 must trigger review of:

```text
64100 approval/reconciliation flow
64110 cancel/refund flow
64140 webhook normalization flow
50700+ audit ledger SOP family
06380 reconciliation/audit/settlement work package
07000 admin console permission documents
08000 customer center answer boundary documents
```

---

## 12. Cross-Flow Dependency Edges

The following dependency edges must be treated as implementation constraints.

```text
64100 Approval
 ├─ feeds 64110 Cancel / Refund
 ├─ feeds 64120 Timeout / Retry / DLQ
 ├─ feeds 64130 Offline Resync
 ├─ receives corrections from 64140 Webhook
 └─ feeds 64150 Settlement / Dispute / Evidence

64110 Cancel / Refund
 ├─ depends on 64100 original approval
 ├─ depends on 64120 idempotent retry rule
 ├─ receives confirmations from 64140 webhook
 └─ feeds 64150 settlement netting and dispute evidence

64120 Timeout / Retry / DLQ
 ├─ protects 64100 approval from duplicate charge
 ├─ protects 64110 refund/cancel from duplicate reversal
 ├─ coordinates with 64130 offline replay
 └─ resolves uncertainty with 64140 webhook events

64130 Offline Local Ledger
 ├─ depends on 09000 state machine
 ├─ depends on 10000 runtime event replay architecture
 ├─ coordinates with 64120 DLQ and replay
 └─ returns canonical state to 64100/64150 after resync

64140 Webhook Verification
 ├─ confirms or rejects 64100 approval outcomes
 ├─ confirms or rejects 64110 cancel/refund outcomes
 ├─ resolves 64120 timeout uncertainty
 └─ supplies normalized events to 64150 settlement evidence

64150 Settlement / Dispute / Evidence
 ├─ consumes 64100 approval ledger
 ├─ consumes 64110 refund/cancel ledger
 ├─ consumes 64140 normalized provider events
 ├─ consumes 50700+ audit ledger evidence
 └─ exports approved evidence packets
```

---

## 13. Global Document Families Required Across All Flow Bundles

| Document Family | Required By | Purpose |
|---|---|---|
| 64000 Runtime Flow Registry | All 64100~64150 flows | Establishes Flow Bundle architecture and implementation gate |
| 64200 Dependency Graph Matrix | All 64100~64150 flows | Defines Markdown dependency graph |
| 64210 Module Implementation Map | All 64100~64150 flows | Maps flows to runtime modules and code ownership |
| 64220 Test Coverage Map | All 64100~64150 flows | Maps flows to tests, fixtures, scenarios, and evidence |
| 50700+ Financial Audit Ledger SOP | All payment/settlement/security flows | Defines immutable audit trail, legal hold, retention, export governance |
| 04900 Security Runtime Test Catalog | Webhook, retry, payment, deployment, evidence flows | Defines security and runtime verification cases |
| 09000 Data Model / State Machine | Approval, refund, offline, webhook, settlement flows | Defines canonical state transitions and event schema |
| 10000 Runtime Foundation | Offline, replay, cross-room, event architecture flows | Defines runtime federation and cross-room architecture |
| 04450 / 04460 Security Boundary Documents | Webhook and POS gateway flows | Defines trust boundary, credential, and secret rotation rules |
| 06300~06390 POS Gateway WorkPackages | POS gateway flows | Defines implementation planning and work package constraints |
| 07000 Admin Console | Dispute, recovery, export, manual correction flows | Defines operator actions, permission surfaces, and review workflows |
| 08000 AI Customer Center | Customer/store answer flows | Defines explanation boundary and mutation prohibition |
| 24000 Deployment Operations | Retry, offline, export, incident flows | Defines rollout, rollback, degraded mode, and incident operation |

---

## 14. Gap Register

| Gap ID | Gap | Affected Flow | Severity | Required Action |
|---|---|---|---|---|
| GAP-64200-001 | Provider-specific webhook signature fields may differ by PG/VAN | 64140 | High | Add provider-specific contract subdocuments or tables before implementation |
| GAP-64200-002 | Canonical idempotency key rule must be fixed across approval, refund, webhook, DLQ, and offline replay | 64100, 64110, 64120, 64130, 64140 | Critical | Lock in data model and test fixtures before coding |
| GAP-64200-003 | Settlement file formats may differ across providers | 64150 | High | Add provider settlement adapter contract or deferred MVP cutline |
| GAP-64200-004 | Offline payment allowance is not yet fully separated from offline order capture | 64130 | Critical | Decide MVP policy before local ledger implementation |
| GAP-64200-005 | Legal hold and evidence export approval roles require admin console permission mapping | 64150 | High | Cross-link with 07000 admin console role matrix |
| GAP-64200-006 | AI customer center must have read-only answer boundary for financial state | 64110, 64150 | High | Add answer boundary policy and mutation prohibition tests |
| GAP-64200-007 | DLQ replay authority and audit approval flow require explicit SOP | 64120 | Critical | Add or link System SOP in 50000+ range |

---

## 15. Claude Code / Cursor Assignment Rule

### 15.1 Claude Code Assignment Unit

Claude Code may be used as a Flow Bundle implementation assistant only when the assignment includes:

```text
1. Target Flow Bundle ID
2. Primary Flow document
3. Dependency graph excerpt from this matrix
4. Module Impact Map reference
5. Test Coverage Map reference
6. Files allowed to edit
7. Files forbidden to edit
8. Required test commands
9. Required evidence outputs
10. Human review gate
```

Claude Code must not be asked to implement a single Markdown file in isolation.

### 15.2 Cursor Assignment Unit

Cursor may be used for:

- Local code navigation
- Partial refactor within an approved module
- Test fixture update
- Type correction
- Interface alignment
- Documentation link correction

Cursor must not be used as the authority for payment, settlement, audit, security, secret, migration, or production deployment logic.

---

## 16. Dependency Review Checklist

Before implementation begins, confirm:

- [ ] The Flow Bundle ID is identified.
- [ ] The primary Flow document exists.
- [ ] All upstream Flow dependencies are listed.
- [ ] All downstream Flow dependencies are listed.
- [ ] Security and secret documents are linked.
- [ ] Audit ledger and evidence documents are linked.
- [ ] Data model and state machine documents are linked.
- [ ] Store operation and support boundary documents are linked.
- [ ] Admin console permission dependencies are linked.
- [ ] Test catalog dependencies are linked.
- [ ] Missing MDs are registered as gaps.
- [ ] AI solo-change restricted domains are marked.
- [ ] Human owner review is required before code modification.

---

## 17. Update Policy

This matrix must be updated whenever:

- A new Flow Bundle is created in the 64000 band.
- A POS Gateway WorkPackage changes implementation boundary.
- A payment, refund, settlement, webhook, or audit document is added.
- A security, secret, or trust boundary document changes.
- A data model or state machine document changes.
- A new PG/VAN provider is added.
- A new settlement or evidence export requirement is introduced.
- Claude Code or Cursor assignment templates are changed.

---

## 18. Next Required Matrix Documents

This dependency graph matrix is not sufficient by itself. The following documents must follow:

```text
064210_Matrix_Flow_To_Module_Implementation_Map.md
064220_Matrix_Flow_To_Test_Coverage_Map.md
```

Together, the required implementation-control chain is:

```text
64200 MD Dependency Graph
 → 64210 Module Implementation Map
 → 64220 Test Coverage Map
 → Flow Step / Module / File / Test / Evidence assignment
 → Claude Code or Cursor controlled implementation
 → Human review and audit evidence capture
```

---

## 19. Final Governance Statement

The 64000 Runtime Flow Registry band exists to prevent unsafe implementation by isolated document interpretation.

For CatchMenu / Catch & Order, financial-grade runtime behavior must be implemented only after the relevant Markdown dependency graph, module impact map, and test coverage map are visible together.

The safe implementation unit is the Flow Bundle.

The safe execution sequence is:

```text
Flow Step → Module → File → Test → Evidence
```

A Markdown file may start the conversation, but it must not be treated as the implementation boundary.
