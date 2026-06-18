# 064390_Checklist_Flow_Bundle_Pre_Merge_And_Release_Gate.md

## 1. Document Control

| Field | Value |
|---|---|
| Project | yoonsul_wait_order_handoff |
| Service Surface | CatchMenu / Catch & Order |
| Document Band | 64000 Runtime Flow Bundle Registry |
| Document Type | Checklist |
| Document Status | Draft |
| Owner | Runtime Flow Bundle Governance Owner |
| Related Index | 064000_Index_Runtime_Flow_Bundle_Registry.md |
| Previous Document | 064380_Register_Flow_Bundle_No_AI_Solo_Zone_Owner_And_Approval_Matrix.md |
| Next Candidate | 64400_Index_Runtime_Flow_Bundle_Extension_And_Change_Intake.md |

---

## 2. Purpose

This checklist defines the mandatory pre-merge and release gate for any implementation performed under a Runtime Flow Bundle.

The purpose is to prevent individual MD documents, isolated code edits, or AI-generated patches from being treated as complete implementation units.

For CatchMenu / Catch & Order, the merge and release decision must be based on the following chain:

```text
Flow Bundle
→ Flow Step
→ Module
→ File
→ Test
→ Evidence
→ Human Approval
→ Merge
→ Release
```

No code change related to POS, PG/VAN, settlement, reconciliation, audit ledger, security, secret, database migration, webhook verification, or production deployment may bypass this checklist.

---

## 3. Stage Boundary

### 3.1 Current Stage Definition

The current stage is defined as:

```text
64000~64390
Runtime Flow Bundle Architecture / Code Handoff Gate
```

This stage is not a feature implementation stage.

It is the control architecture stage that decides whether Claude Code, Cursor, or any human developer may safely begin implementation on a Flow Bundle.

### 3.2 Stage Completion Criteria

This stage is complete only when all of the following documents exist and are internally consistent:

| Document | Role | Required Before Code? |
|---|---:|---:|
| 064000_Index_Runtime_Flow_Bundle_Registry.md | Flow Bundle registry index | Yes |
| 064100_Flow_POS_Gateway_Approval_To_Audit_Ledger_And_Reconciliation.md | Approval-to-ledger flow | Yes |
| 064110_Flow_POS_Gateway_Cancel_Refund_Recovery_And_Audit.md | Cancel/refund/recovery flow | Yes |
| 064120_Flow_POS_Gateway_Timeout_Retry_DLQ_And_Replay.md | Timeout/retry/DLQ/replay flow | Yes |
| 064130_Flow_POS_Gateway_Store_Offline_Local_Ledger_And_Resync.md | Offline local ledger/resync flow | Yes |
| 064140_Flow_POS_Gateway_Webhook_Inbound_Verification_And_Event_Normalization.md | Webhook verification/normalization flow | Yes |
| 064150_Flow_POS_Gateway_Settlement_Dispute_And_Evidence_Export.md | Settlement/dispute/evidence export flow | Yes |
| 064200_Matrix_Flow_To_MD_Dependency_Graph.md | MD dependency graph | Yes |
| 064210_Matrix_Flow_To_Module_Implementation_Map.md | Module impact map | Yes |
| 064220_Matrix_Flow_To_Test_Coverage_Map.md | Test coverage map | Yes |
| 064300_Checklist_Flow_Bundle_Code_Handoff_Readiness_Gate.md | Code handoff readiness gate | Yes |
| 064310_Template_Flow_Bundle_Claude_Code_Handoff_Prompt.md | Claude Code handoff prompt | Yes |
| 064320_Template_Flow_Bundle_Cursor_IDE_Assist_Prompt.md | Cursor IDE assist prompt | Yes |
| 064330_Runbook_Flow_Bundle_Code_Review_And_Diff_Control.md | Diff review runbook | Yes |
| 064340_Evidence_Flow_Bundle_Implementation_Review_Packet.md | Implementation evidence packet | Yes |
| 064350_Register_Flow_Bundle_Implementation_Exception_And_Waiver_Log.md | Exception and waiver log | Yes |
| 064360_Audit_Flow_Bundle_AI_Assisted_Implementation_Governance.md | AI-assisted implementation audit | Yes |
| 064370_Governance_Flow_Bundle_Human_Approval_And_No_AI_Solo_Zone_Control.md | No-AI-solo governance | Yes |
| 064380_Register_Flow_Bundle_No_AI_Solo_Zone_Owner_And_Approval_Matrix.md | Owner/approval matrix | Yes |
| 064390_Checklist_Flow_Bundle_Pre_Merge_And_Release_Gate.md | Pre-merge/release gate | Yes |

---

## 4. Pre-Merge Gate

A pull request, patch set, or AI-generated implementation may not be merged unless every item in this section is checked.

### 4.1 Flow Bundle Identification

| Check Item | Required Evidence | Pass/Fail |
|---|---|---|
| Flow Bundle ID is declared | Flow document reference |  |
| Flow steps are listed | Flow Step table |  |
| Related MD dependency graph is linked | 64200 reference |  |
| Impacted modules are listed | 64210 reference |  |
| Test coverage is mapped | 64220 reference |  |
| Implementation evidence packet exists | 64340 reference |  |

### 4.2 Scope Control

| Check Item | Required Evidence | Pass/Fail |
|---|---|---|
| Code changes are limited to approved Flow Bundle scope | Diff summary |  |
| Out-of-scope files are either absent or justified | Diff review note |  |
| No unrelated refactor is bundled into the change | Reviewer confirmation |  |
| No hidden migration is included | Migration review |  |
| No production secret or credential is changed | Secret review |  |
| No runtime deployment configuration is changed without approval | Deployment approval |  |

### 4.3 AI-Assisted Work Control

| Check Item | Required Evidence | Pass/Fail |
|---|---|---|
| Claude Code prompt is archived | 64310 output or transcript reference |  |
| Cursor assist prompt is archived if used | 64320 output or transcript reference |  |
| AI-generated changes are marked in review packet | 64340 evidence |  |
| Human reviewer reviewed the actual diff | Reviewer signoff |  |
| AI did not self-approve test results | Test evidence signed by human reviewer |  |
| AI did not modify No-AI-Solo Zone without approval | 64370/64380 approval reference |  |

---

## 5. No-AI-Solo Zone Merge Blockers

Any change touching the following areas is blocked from merge until a human approval record exists.

| Zone | Examples | Merge Rule |
|---|---|---|
| Payment authorization | approval request, approval response, idempotency key, duplicate charge guard | Human approval required |
| Cancel/refund | refund state, reversal, compensation, customer refund evidence | Human approval required |
| Settlement/reconciliation | settlement import, settlement match, dispute evidence, accounting export | Human approval required |
| Audit ledger | immutable event ledger, WORM export, audit hash chain, retention record | Human approval required |
| Webhook security | signature verification, replay protection, provider secret, inbound normalization | Human approval required |
| DB migration | schema, migration, backfill, rollback, data correction | Human approval required |
| Secrets | vault path, key rotation, provider credential, webhook secret | Human approval required |
| Production deployment | release config, environment variable, rollout switch, feature flag | Human approval required |
| Security policy | RBAC, ABAC, token boundary, encryption, retention/deletion rule | Human approval required |

A change that touches these zones without the approval matrix is considered a release blocker, not a review comment.

---

## 6. Required Test Gate

### 6.1 Minimum Test Classes

Each Flow Bundle must include the following minimum test classes unless explicitly marked not applicable in the evidence packet.

| Test Class | Required For | Evidence |
|---|---|---|
| Unit test | Pure module logic | Test report |
| Contract test | POS/PG/VAN boundary | Request/response fixture |
| Integration test | Runtime flow across modules | Integration run log |
| Idempotency test | Approval/cancel/retry/replay | Duplicate prevention result |
| Failure-mode test | Timeout/offline/DLQ/webhook replay | Failure evidence |
| Ledger consistency test | Audit ledger and reconciliation | Ledger comparison report |
| Security test | Signature, secret, auth boundary | Security test result |
| Migration test | Schema/backfill/rollback | Migration dry-run result |
| Evidence export test | Audit/dispute/settlement export | Export sample hash/reference |

### 6.2 Flow-Specific Test Requirements

| Flow Document | Mandatory Focus |
|---|---|
| 64100 | Approval result must match audit ledger and reconciliation candidate |
| 64110 | Cancel/refund must not create orphan approval or duplicate refund |
| 64120 | Timeout/retry/DLQ/replay must preserve idempotency |
| 64130 | Offline local ledger must resync without overwriting canonical ledger incorrectly |
| 64140 | Webhook must fail closed on invalid signature/replay/timestamp drift |
| 64150 | Settlement dispute evidence must be exportable and traceable |

---

## 7. Evidence Gate

A merge request must include evidence sufficient for future audit.

### 7.1 Evidence Packet Contents

| Evidence Item | Required? | Location |
|---|---:|---|
| Flow Bundle ID | Yes | 64340 packet |
| Flow Step to File map | Yes | 64340 packet |
| Test run summary | Yes | 64340 packet |
| Failure-mode evidence | Yes | 64340 packet |
| Human approval record | Conditional | 64380 matrix / approval log |
| Exception or waiver reference | Conditional | 64350 register |
| DB migration dry-run | Conditional | migration evidence |
| Secret approval record | Conditional | secret approval evidence |
| Release rollback plan | Yes | release evidence |
| Post-release monitoring plan | Yes | release evidence |

### 7.2 Evidence Naming Rule

Evidence files should use the following naming style:

```text
{FlowBundleID}_Evidence_{EvidenceType}_{YYYYMMDD}_{ShortDescription}.md
```

Example:

```text
64120_Evidence_Test_DLQ_Replay_Idempotency_20260617_Result.md
```

---

## 8. Release Gate

A Flow Bundle may be released only after pre-merge approval and release readiness approval are both complete.

### 8.1 Release Readiness Checklist

| Check Item | Required Evidence | Pass/Fail |
|---|---|---|
| Merge approval completed | PR approval record |  |
| Flow Bundle test gate passed | Test report |  |
| No-AI-Solo approval complete if applicable | Approval matrix reference |  |
| Rollback plan exists | Rollback runbook |  |
| Monitoring alerts are defined | Monitoring config or checklist |  |
| Reconciliation/audit verification plan exists | Audit verification evidence |  |
| Customer-impact note prepared if needed | Support/operation note |  |
| Production deployment owner assigned | Release owner record |  |
| Post-release validation window defined | Release validation note |  |

### 8.2 Release Blockers

The release must be blocked when any of the following is true:

1. A payment, settlement, audit, security, secret, migration, or production deployment file was changed without human approval.
2. Flow Bundle test coverage is incomplete.
3. Evidence packet is missing or inconsistent with the diff.
4. Exception or waiver is used for a non-waivable zone.
5. Rollback plan is missing.
6. Webhook or retry behavior cannot prove idempotency.
7. Audit ledger cannot prove event traceability.
8. Reconciliation result cannot be reproduced.
9. AI-generated change cannot be distinguished from human-authored change.
10. Production configuration change is mixed with unrelated code change.

---

## 9. Post-Release Validation

After release, the following checks must be completed before the Flow Bundle is closed.

| Validation Item | Required Evidence | Status |
|---|---|---|
| Production health check completed | Health check log |  |
| Error rate checked | Monitoring report |  |
| Duplicate approval/cancel/refund checked | Ledger query result |  |
| Webhook replay or invalid signature spike checked | Security log |  |
| Settlement/reconciliation sample checked | Reconciliation evidence |  |
| Audit ledger trace sample checked | Audit evidence |  |
| Rollback not required or rollback completed | Release note |  |
| Incident register updated if needed | Incident reference |  |

---

## 10. Relationship To Next Stage

This document closes the first Flow Bundle Architecture stage.

The recommended next stage is:

```text
64400~64490
Runtime Flow Bundle Extension / Change Intake / New Document Reflection Stage
```

That stage should be used when new source documents, external legal/compliance notes, POS provider materials, PG/VAN integration findings, patent notes, or security policy additions must be reflected into the Flow Bundle registry.

Recommended next document:

```text
64400_Index_Runtime_Flow_Bundle_Extension_And_Change_Intake.md
```

---

## 11. Final Rule

A Flow Bundle is not ready to merge or release just because the code compiles.

It is ready only when the implementation can be traced through:

```text
Flow Step
→ Module
→ File
→ Test
→ Evidence
→ Human Approval
→ Merge
→ Release
→ Post-Release Validation
```

For CatchMenu / Catch & Order, this rule is mandatory because POS, PG/VAN, settlement, reconciliation, audit ledger, and customer-impacting payment flows carry financial-grade operational risk.
