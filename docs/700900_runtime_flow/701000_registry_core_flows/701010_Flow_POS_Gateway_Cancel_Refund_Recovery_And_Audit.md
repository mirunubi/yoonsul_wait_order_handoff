# 701010_Flow_POS_Gateway_Cancel_Refund_Recovery_And_Audit.md

## 1. Document Control

| Field | Value |
|---|---|
| Document Number | 701010 |
| Document Type | Flow |
| Document Band | 700900 Runtime Flow Bundle Registry |
| Title | POS Gateway Cancel Refund Recovery And Audit |
| System | yoonsul_wait_order_handoff / CatchMenu / Catch & Order |
| Scope | POS cancel, refund, partial refund, reversal, recovery, audit ledger, and evidence handoff |
| Status | Draft |
| Owner | Runtime Architecture / POS Gateway / Financial Audit Governance |
| Related Index | 700900_Index_Runtime_Flow_Bundle_Registry.md |
| Previous Flow | 701000_Flow_POS_Gateway_Approval_To_Audit_Ledger_And_Reconciliation.md |

---

## 2. Purpose

This document defines the Flow Bundle for POS Gateway cancellation, refund, reversal, and recovery events.

The purpose of this Flow Bundle is to prevent refund handling from being treated as a small patch on top of approval handling. In CatchMenu / Catch & Order, a cancellation or refund is a financial correction event that must be linked to the original approval, reflected in payment state, projected into the audit ledger, reconciled against PG/VAN settlement data, and preserved as evidence.

This file defines the required dependency graph, runtime flow, module impact, test coverage, and AI tool boundary before Claude Code, Cursor, or any AI-assisted coding tool is allowed to modify cancellation or refund code.

---

## 3. Flow Bundle Summary

| Item | Definition |
|---|---|
| Flow Bundle ID | FLOW-701010 |
| Flow Name | POS Gateway Cancel Refund Recovery And Audit |
| Runtime Class | Financial correction runtime / refund ledger / audit evidence |
| Primary Trigger | POS cancel request, PG/VAN cancel result, provider reversal, operator refund request, or recovery replay |
| Primary Output | Immutable cancel/refund ledger entry linked to original approval |
| Secondary Output | Audit projection, reconciliation candidate, dispute/evidence seed, and customer/operator support boundary event |
| Risk Class | Critical |
| AI Direct Modification | Prohibited for refund amount logic, ledger mutation, DB migration, settlement, secret, and production deployment areas |

---

## 4. Flow Entry Criteria

This Flow Bundle may be implemented only after the following are available.

| Required Artifact | Required Status | Notes |
|---|---:|---|
| MD Dependency Graph | Required | Approval, cancel, refund, recovery, audit, reconciliation, consumer-protection, and evidence docs must be mapped |
| Runtime Flow Diagram | Required | Runtime sequence from cancel/refund trigger to audit and reconciliation candidate must be drawn |
| Module Impact Map | Required | POS gateway, payment state, ledger, audit, reconciliation, support, queue, and monitoring impact must be listed |
| Test Coverage Map | Required | Full cancel, partial refund, duplicate cancel, timeout recovery, replay, and settlement mismatch tests must be mapped |
| Original Approval Link Rule | Required | Every cancel/refund must link to a canonical approval ledger event or be classified as orphan/recovery exception |
| Compensating Event Rule | Required | Ledger deletion or silent overwrite is prohibited |
| Evidence Path | Required | Evidence output naming, retention, and legal hold owner must be known |
| Rollback Plan | Required | Refund rollback must be compensating-event based; financial ledger hard rollback is prohibited |

---

## 5. MD Dependency Graph

### 5.1 Required Source Document Groups

This Flow Bundle depends on multiple document groups. The exact repository filenames may evolve, but implementation must not proceed unless the following groups have been reviewed and mapped.

| Group | Expected Document Type | Purpose |
|---|---|---|
| Runtime Flow Registry | Index / Flow / Matrix | Defines Flow Bundle implementation control and cross-flow governance |
| POS Gateway WorkPackage | WorkPackage / Policy | Defines provider boundary, approval link, cancel/refund behavior, idempotency, queue, retry, and recovery constraints |
| Financial Audit Ledger | SOP / Audit / Governance | Defines immutable event identity, tamper evidence, correction event handling, retention, export, and legal hold |
| Data Model State Machine | Spec / Matrix / Policy | Defines order, payment, approval, cancel, refund, reversal, dispute, and reconciliation state transitions |
| Runtime Foundation | Policy / Boundary / ADR | Defines event normalization, gateway trust boundary, failure containment, and failover assumptions |
| Security Runtime Test Catalog | Checklist / Evidence / Test | Defines webhook verification, replay protection, credential handling, refund abuse tests, and audit integrity tests |
| Customer Handoff Readiness | Checklist / Evidence / Report | Defines first-store rollout, refund support evidence, and operator training acceptance |
| AI Customer Center | Policy / SOP | Defines what the AI customer center may explain and when refund cases must be escalated to human support |
| Consumer Protection / Legal | Policy / Evidence / SOP | Defines refund notice, dispute handling, customer communication, and evidence preservation obligations |

### 5.2 Dependency Graph Rule

A Markdown document is not an implementation unit. It is a source of contractual, legal, financial, operational, or evidence constraints.

Each referenced Markdown document must be mapped to at least one of the following dependency roles.

| Dependency Role | Meaning |
|---|---|
| Source Contract | Defines required provider/API behavior or system boundary |
| Runtime Constraint | Defines what the runtime must or must not do |
| Ledger Constraint | Defines immutable ledger, correction event, and audit projection behavior |
| State Constraint | Defines allowed state transitions and rejected transitions |
| Security Constraint | Defines verification, authorization, credential, replay, and abuse-prevention rules |
| Evidence Constraint | Defines records, logs, exports, retention, and legal hold evidence |
| Test Constraint | Defines tests required before implementation acceptance |
| Operation Constraint | Defines rollout, operator support, escalation, and incident handling |

### 5.3 Minimum Dependency Nodes

The dependency graph for FLOW-701010 must include, at minimum, the following nodes.

| Node ID | Node Name | Required Role |
|---|---|---|
| MD-701000 | Approval To Audit Ledger Flow | Original approval event dependency and previous flow context |
| MD-701010 | Cancel Refund Recovery And Audit Flow | Current Flow Bundle root |
| MD-701100 | Flow To MD Dependency Graph Matrix | Cross-flow dependency registry |
| MD-701110 | Flow To Module Implementation Map | Module ownership and implementation boundary |
| MD-701120 | Flow To Test Coverage Map | Required test coverage and acceptance mapping |
| POS-GW-CANCEL | POS Gateway cancel/refund policy group | Provider request/result contract |
| LEDGER-CORRECTION | Financial audit ledger correction policy group | Immutable correction event rule |
| STATE-PAYMENT | Payment state machine group | Allowed state transitions |
| SECURITY-REFUND | Refund security and abuse-prevention group | Authorization, replay, duplicate, and fraud control |
| EVIDENCE-REFUND | Refund evidence and export group | Refund evidence, dispute packet, and legal hold readiness |

---

## 6. Runtime Flow Diagram

### 6.1 Runtime Sequence

The runtime flow must be implemented as a controlled sequence, not as isolated handler edits.

```mermaid
sequenceDiagram
    autonumber
    participant Actor as Operator / POS / Provider
    participant POSGW as POS Gateway
    participant Verify as Verification And Idempotency Layer
    participant State as Payment State Machine
    participant Ledger as Financial Ledger
    participant Audit as Audit Ledger Projection
    participant Recon as Reconciliation Candidate Store
    participant Evidence as Evidence Packet Store
    participant Support as Support / AI Customer Center Boundary
    participant Monitor as Monitoring And Incident Queue

    Actor->>POSGW: Cancel / refund / reversal / recovery event
    POSGW->>Verify: Verify signature, credential scope, idempotency key, and original approval reference
    Verify->>State: Load canonical approval and current payment state
    State->>State: Validate allowed cancel/refund transition and amount boundary
    State->>Ledger: Append immutable cancel/refund correction event
    Ledger->>Audit: Project correction into audit ledger
    Audit->>Recon: Create or update reconciliation candidate
    Audit->>Evidence: Seed refund evidence packet and legal-hold-ready records
    Audit->>Support: Publish safe support boundary event
    Audit->>Monitor: Publish risk, mismatch, duplicate, timeout, or orphan signals
```

### 6.2 Runtime Flow Steps

| Step | Name | Required Behavior | Failure Handling |
|---:|---|---|---|
| 1 | Receive Cancel/Refund Trigger | Accept only from approved POS, provider webhook, operator console, or recovery replay path | Unknown source is rejected and logged |
| 2 | Verify Event Authenticity | Verify signature, credential scope, timestamp, nonce/idempotency key, and provider identity | Verification failure is fail-closed |
| 3 | Resolve Original Approval | Find canonical approval ledger event and provider approval reference | Missing approval becomes orphan recovery exception |
| 4 | Load Current State | Load order, payment, approval, cancel/refund, and reconciliation state | State read failure blocks financial mutation |
| 5 | Validate Transition | Validate full cancel, partial refund, repeated refund, reversal, and amount boundary | Invalid transition creates rejection evidence |
| 6 | Append Correction Event | Append immutable cancel/refund ledger event; never overwrite original approval | Append failure blocks downstream projection |
| 7 | Project Audit Ledger | Project correction into financial audit ledger with source identity and hash chain reference | Projection failure enters audit recovery queue |
| 8 | Create Reconciliation Candidate | Mark original approval and correction event for PG/VAN settlement comparison | Candidate failure enters reconciliation recovery queue |
| 9 | Seed Evidence Packet | Store request, response, state snapshot, operator/provider identity, and trace IDs | Evidence failure raises high-risk incident |
| 10 | Publish Support Boundary | Expose only safe refund status to AI customer center or operator support | Ambiguous cases must escalate to human support |
| 11 | Monitor And Alert | Detect duplicate refund, amount mismatch, orphan cancel, timeout, and replay anomalies | Critical anomaly opens incident and blocks automation |

---

## 7. Module Impact Map

### 7.1 Primary Modules

| Module | Impact | Implementation Rule |
|---|---|---|
| POS Gateway Adapter | Cancel/refund request and provider callback normalization | Provider-specific logic must terminate at adapter boundary |
| Verification Layer | Signature, credential scope, timestamp, idempotency, and replay verification | Fail-closed for financial correction events |
| Payment State Machine | Cancel/refund transition validation and amount boundary checks | State transition must be deterministic and test-covered |
| Financial Ledger | Immutable correction event append and original approval link | No hard delete, no silent overwrite, no direct balance mutation |
| Audit Ledger Projection | Tamper-evident audit projection for correction event | Projection must include source, trace, hash, and event identity |
| Reconciliation Module | Settlement and dispute candidate creation | Must link original approval and correction event pair |
| Evidence Export Module | Refund/cancel evidence packet generation | Evidence must be legal-hold-ready |
| Support Boundary Module | AI customer center and operator-safe message boundary | AI may explain status, not decide refund validity |
| Monitoring / Incident Module | Duplicate, mismatch, orphan, timeout, replay, and abuse signals | Critical risk must create incident evidence |

### 7.2 Data Stores

| Store | Impact | Mutation Rule |
|---|---|---|
| Order Store | May reflect post-refund customer/order-facing state | State update must derive from canonical payment event |
| Payment Store | Holds current payment aggregate state | Aggregate is projection, not source of truth |
| Approval Ledger | Original approval event reference | Original approval must remain immutable |
| Cancel/Refund Ledger | Correction event source of truth | Append-only; correction-of-correction allowed only by new event |
| Audit Ledger | Tamper-evident financial audit projection | Append/projection only; no manual correction without event |
| Reconciliation Store | Settlement comparison candidate | Must include provider reference and internal event identity |
| Evidence Store | Refund/cancel evidence packet | Retention and legal hold rules apply |
| Incident Store | Security/financial anomaly records | Incident linkage to trace ID and ledger event is required |

---

## 8. Test Coverage Map

### 8.1 Required Test Classes

| Test Class | Required Coverage |
|---|---|
| Unit Test | Amount boundary, state transition, idempotency key, original approval link, duplicate refund prevention |
| Contract Test | POS/provider cancel request, refund response, webhook reversal, and provider error normalization |
| Integration Test | Approval-to-refund, partial refund, full cancel, reversal, and audit projection end-to-end flow |
| Security Test | Signature failure, stale timestamp, replay, wrong credential scope, forged provider identity, operator privilege abuse |
| Ledger Test | Immutable append, correction link, hash/reference continuity, projection recovery, no overwrite guarantee |
| Reconciliation Test | Approval/refund pair matching, settlement mismatch, provider-side cancel without internal match, orphan correction |
| Recovery Test | Timeout during cancel, provider result unknown, duplicate callback, DLQ replay, manual recovery approval |
| Evidence Test | Evidence packet completeness, traceability, export readiness, retention marker, legal hold marker |
| Support Boundary Test | AI customer center sees only safe status and cannot approve or alter refund state |
| Regression Test | Approval flow behavior from FLOW-701000 remains unchanged by refund implementation |

### 8.2 Minimum Acceptance Conditions

Implementation for FLOW-701010 is not accepted unless all of the following are true.

| Acceptance Condition | Required Result |
|---|---|
| Original approval link exists | Every valid cancel/refund links to a canonical approval event |
| Duplicate refund is blocked | Same idempotency key or same provider correction reference does not create double refund |
| Partial refund boundary is enforced | Total refunded amount cannot exceed approved amount |
| Ledger is immutable | Original approval and prior correction events are not overwritten |
| Audit projection is complete | Audit ledger contains source identity, event identity, trace ID, and correction link |
| Reconciliation is possible | Internal correction can be matched against provider settlement/dispute data |
| Ambiguous provider result is recoverable | Timeout or unknown result enters controlled recovery, not blind retry mutation |
| AI support is bounded | AI customer center cannot approve, deny, or mutate refund state |
| Evidence is exportable | Refund case can be exported as an evidence packet |
| Rollback is compensating-event based | No financial hard rollback or direct ledger edit exists |

---

## 9. Controlled Implementation Order

The implementation must follow this order.

```text
Flow Step -> Module -> File -> Test -> Evidence
```

### 9.1 Work Breakdown

| Order | Work Item | Output |
|---:|---|---|
| 1 | Confirm dependency graph | FLOW-701010 dependency graph entry and source MD references |
| 2 | Draw runtime flow | Runtime sequence and state transition diagram |
| 3 | Confirm module ownership | Module impact map and owner assignment |
| 4 | Confirm data mutation policy | Ledger, state, reconciliation, and evidence mutation rules |
| 5 | Build tests first | Unit, contract, integration, security, recovery, reconciliation, and evidence tests |
| 6 | Implement bounded modules | Adapter, verification, state, ledger, audit, reconciliation, evidence, and support boundary |
| 7 | Generate evidence | Test result, trace sample, ledger sample, reconciliation sample, evidence packet sample |
| 8 | Gate deployment | Human approval for DB migration, secret, production deployment, and financial-risk changes |

---

## 10. AI Tool Boundary

### 10.1 Claude Code Usage

Claude Code may be used as a Flow Bundle implementation agent only after the four pre-implementation artifacts are available.

Allowed Claude Code tasks:

| Allowed Task | Condition |
|---|---|
| Generate module skeletons | Only from approved Flow Step and Module Impact Map |
| Generate tests | Must follow Test Coverage Map |
| Refactor non-financial helper code | Must not change ledger, settlement, secret, or migration logic without human review |
| Produce implementation diff summary | Must map every changed file back to Flow Step and Test |
| Produce evidence draft | Must not fabricate passing results |

### 10.2 Cursor Usage

Cursor may be used as IDE and local edit assistant.

Cursor should be limited to:

| Allowed Task | Condition |
|---|---|
| Navigate repository | Safe |
| Apply small edits | Only inside approved module/file scope |
| Fix lint/type/test failures | Only when failure cause is understood |
| Update documentation links | Must preserve naming rule and H1 rule |

### 10.3 Prohibited AI-Only Areas

AI must not independently modify or approve the following areas.

| Prohibited Area | Reason |
|---|---|
| Refund amount calculation policy | Direct financial loss and legal dispute risk |
| Financial ledger mutation | Source-of-truth integrity risk |
| Audit ledger tamper-evidence logic | Evidence and legal hold risk |
| DB migration | Production data corruption risk |
| Secret or provider credential handling | Credential leakage and unauthorized refund risk |
| Settlement/dispute rule | Financial reconciliation and regulatory risk |
| Production deployment | Operational and financial incident risk |
| Security control downgrade | Abuse, fraud, and replay attack risk |
| Manual recovery approval | Requires human financial authority |

---

## 11. Evidence Requirements

Every implementation of FLOW-701010 must produce evidence.

### 11.1 Evidence Packet Contents

| Evidence Item | Required Content |
|---|---|
| Dependency Evidence | Source MD list and dependency role mapping |
| Flow Evidence | Runtime flow diagram and state transition summary |
| Module Evidence | Module/file impact list and owner assignment |
| Test Evidence | Test list, execution result, failed/passed status, and coverage gaps |
| Ledger Evidence | Sample original approval, cancel/refund correction event, and audit projection |
| Reconciliation Evidence | Sample approval/refund pair and settlement comparison candidate |
| Security Evidence | Signature, replay, duplicate, and privilege-abuse test results |
| Recovery Evidence | Timeout, unknown result, DLQ/replay, and manual recovery case results |
| Support Evidence | AI/customer/operator-safe refund status message samples |
| Deployment Evidence | Human approval record for DB migration, secret, and production rollout if applicable |

### 11.2 Evidence Naming Rule

Evidence files should follow the repository naming rule and remain linked to this Flow Bundle.

```text
701010_Evidence_POS_Gateway_Cancel_Refund_Recovery_And_Audit_<EvidenceTopic>.md
```

Examples:

```text
701010_Evidence_POS_Gateway_Cancel_Refund_Recovery_And_Audit_Test_Result.md
701010_Evidence_POS_Gateway_Cancel_Refund_Recovery_And_Audit_Ledger_Sample.md
701010_Evidence_POS_Gateway_Cancel_Refund_Recovery_And_Audit_Reconciliation_Sample.md
701010_Evidence_POS_Gateway_Cancel_Refund_Recovery_And_Audit_Recovery_Case.md
```

---

## 12. Failure And Recovery Principles

| Failure Case | Required Principle |
|---|---|
| Provider cancel timeout | Do not blindly retry financial mutation; enter unknown-result recovery flow |
| Provider says canceled but internal event missing | Create orphan correction incident and controlled reconciliation case |
| Internal refund recorded but provider settlement does not match | Open reconciliation mismatch and evidence packet |
| Duplicate callback arrives | Idempotency must prevent duplicate ledger correction |
| Partial refund exceeds approved amount | Reject and preserve rejection evidence |
| Approval already fully refunded | Reject further refund unless explicit correction-of-correction flow is approved |
| Audit projection fails | Ledger event remains source of truth; projection recovery queue must repair audit projection |
| Evidence packet fails | Financial event remains valid but incident severity is high because legal defense is weakened |
| AI customer center receives ambiguous refund inquiry | AI must provide safe status only and escalate to human support |

---

## 13. Cross-References

| Related File | Relationship |
|---|---|
| 700900_Index_Runtime_Flow_Bundle_Registry.md | Parent registry for Runtime Flow Bundles |
| 701000_Flow_POS_Gateway_Approval_To_Audit_Ledger_And_Reconciliation.md | Previous approval flow and original approval dependency |
| 701020_Flow_POS_Gateway_Timeout_Retry_DLQ_And_Replay.md | Timeout, retry, unknown-result, DLQ, and replay recovery flow |
| 701030_Flow_POS_Gateway_Store_Offline_Local_Ledger_And_Resync.md | Store offline and local ledger resync dependency |
| 701040_Flow_POS_Gateway_Webhook_Inbound_Verification_And_Event_Normalization.md | Provider webhook verification and normalization dependency |
| 701050_Flow_POS_Gateway_Settlement_Dispute_And_Evidence_Export.md | Settlement, dispute, and evidence export downstream flow |
| 701100_Matrix_Flow_To_MD_Dependency_Graph.md | Dependency graph matrix |
| 701110_Matrix_Flow_To_Module_Implementation_Map.md | Module implementation matrix |
| 701120_Matrix_Flow_To_Test_Coverage_Map.md | Test coverage matrix |

---

## 14. Governance Decision

FLOW-701010 is a critical financial correction Flow Bundle.

No implementation may proceed by editing a single refund handler, cancel endpoint, webhook callback, or ledger file in isolation.

Before coding begins, the team must confirm:

1. MD Dependency Graph is complete.
2. Runtime Flow Diagram is complete.
3. Module Impact Map is complete.
4. Test Coverage Map is complete.
5. Human review is assigned for all refund amount, ledger, audit, DB migration, secret, settlement, and production deployment changes.

This Flow Bundle exists to protect CatchMenu / Catch & Order from double refunds, orphan cancellations, settlement mismatch, audit evidence failure, and AI-assisted unsafe financial code changes.
