# 701210_Template_Flow_Bundle_Claude_Code_Handoff_Prompt.md

## 1. Document Control

| Field | Value |
|---|---|
| Document Number | 701210 |
| Document Type | Template |
| Document Title | Flow Bundle Claude Code Handoff Prompt |
| Project | yoonsul_wait_order_handoff / CatchMenu-Catch&Order |
| Band | 700900 Runtime Flow Bundle Registry |
| Status | Draft |
| Owner | System Architecture / Implementation Governance |
| Related Index | 700900_Index_Runtime_Flow_Bundle_Registry.md |
| Previous Gate | 701200_Checklist_Flow_Bundle_Code_Handoff_Readiness_Gate.md |

---

## 2. Purpose

This template defines the standard handoff prompt used when a Runtime Flow Bundle is assigned to Claude Code for implementation analysis, code planning, or controlled code modification.

The purpose is to prevent the unsafe pattern of asking an AI coding agent to modify a single Markdown-defined feature in isolation.

For CatchMenu / Catch & Order, implementation must be handled at the Flow Bundle level because POS, PG/VAN, approval, cancellation, settlement, audit ledger, local ledger, retry, replay, security, migration, and evidence boundaries are tightly coupled.

---

## 3. Core Rule

A Claude Code task must not start from a single MD file.

It must start from a Flow Bundle package containing at least the following four control artifacts:

1. MD Dependency Graph
2. Runtime Flow Diagram
3. Module Impact Map
4. Test Coverage Map

If any of these four artifacts is missing, incomplete, or inconsistent, Claude Code must stop and produce a gap report instead of modifying code.

---

## 4. Intended Use

This template is used when preparing a controlled implementation handoff for one of the following Flow Bundle documents:

| Flow Document | Scope |
|---|---|
| 701000_Flow_POS_Gateway_Approval_To_Audit_Ledger_And_Reconciliation.md | Approval to audit ledger and reconciliation |
| 701010_Flow_POS_Gateway_Cancel_Refund_Recovery_And_Audit.md | Cancel, refund, recovery, and audit |
| 701020_Flow_POS_Gateway_Timeout_Retry_DLQ_And_Replay.md | Timeout, retry, DLQ, and replay |
| 701030_Flow_POS_Gateway_Store_Offline_Local_Ledger_And_Resync.md | Store offline local ledger and resync |
| 701040_Flow_POS_Gateway_Webhook_Inbound_Verification_And_Event_Normalization.md | Webhook verification and event normalization |
| 701050_Flow_POS_Gateway_Settlement_Dispute_And_Evidence_Export.md | Settlement, dispute, and evidence export |

This template may also be reused for future 700900-band Flow Bundles.

---

## 5. Mandatory Input Package

Before Claude Code receives a task, prepare the following input package.

```text
FLOW_BUNDLE_ID:
FLOW_BUNDLE_DOCUMENT:
PRIMARY_OBJECTIVE:
IMPLEMENTATION_MODE: analysis_only | plan_only | controlled_patch | test_only | evidence_only
CODEBASE_PATH:
BRANCH_NAME:
ALLOWED_DIRECTORIES:
PROHIBITED_DIRECTORIES:
RELATED_MD_FILES:
RELATED_MODULES:
RELATED_TESTS:
RELATED_EVIDENCE_OUTPUTS:
HUMAN_APPROVER:
```

---

## 6. Standard Claude Code Handoff Prompt

Copy the following block and fill in the placeholders.

```text
You are working on the yoonsul_wait_order_handoff / CatchMenu-Catch&Order project.

This is not a single-file implementation task.
You must treat the requested work as a Runtime Flow Bundle implementation task.

FLOW_BUNDLE_ID:
{{FLOW_BUNDLE_ID}}

FLOW_BUNDLE_DOCUMENT:
{{FLOW_BUNDLE_DOCUMENT}}

PRIMARY_OBJECTIVE:
{{PRIMARY_OBJECTIVE}}

IMPLEMENTATION_MODE:
{{IMPLEMENTATION_MODE}}

CODEBASE_PATH:
{{CODEBASE_PATH}}

BRANCH_NAME:
{{BRANCH_NAME}}

Before touching code, read and summarize the following control documents:

1. 700900_Index_Runtime_Flow_Bundle_Registry.md
2. 701200_Checklist_Flow_Bundle_Code_Handoff_Readiness_Gate.md
3. {{FLOW_BUNDLE_DOCUMENT}}
4. 701100_Matrix_Flow_To_MD_Dependency_Graph.md
5. 701110_Matrix_Flow_To_Module_Implementation_Map.md
6. 701120_Matrix_Flow_To_Test_Coverage_Map.md
7. All RELATED_MD_FILES listed below

RELATED_MD_FILES:
{{RELATED_MD_FILES}}

RELATED_MODULES:
{{RELATED_MODULES}}

RELATED_TESTS:
{{RELATED_TESTS}}

RELATED_EVIDENCE_OUTPUTS:
{{RELATED_EVIDENCE_OUTPUTS}}

ALLOWED_DIRECTORIES:
{{ALLOWED_DIRECTORIES}}

PROHIBITED_DIRECTORIES:
{{PROHIBITED_DIRECTORIES}}

HUMAN_APPROVER:
{{HUMAN_APPROVER}}

Hard rules:

1. Do not treat one MD file as one implementation unit.
2. Do not modify payment, settlement, audit, security, secret, database migration, or production deployment logic without explicit human approval.
3. Do not modify schema migrations unless the task explicitly includes a migration approval record.
4. Do not add or rotate secrets.
5. Do not bypass idempotency, audit logging, reconciliation, DLQ, replay, or evidence requirements.
6. Do not remove tests to make the build pass.
7. Do not silently change public API contracts, webhook contracts, event names, ledger state names, or settlement status names.
8. Do not make speculative architecture changes outside the Flow Bundle scope.
9. If required documents, modules, tests, or evidence paths are missing, stop and produce a gap report.
10. Every proposed change must map to Flow Step → Module → File → Test → Evidence.

First response required:

Produce a Flow Bundle Readiness Report with the following sections:

A. Flow Bundle Summary
B. MD Dependency Graph Summary
C. Runtime Flow Step Summary
D. Module Impact Map
E. Test Coverage Map
F. Evidence Output Map
G. Forbidden Area Check
H. Open Gaps / Required Human Decisions
I. Safe Next Action

Do not edit code until the readiness report is complete.
```

---

## 7. Controlled Patch Prompt Add-On

Use this add-on only after the Readiness Report is reviewed and approved.

```text
The Flow Bundle Readiness Report has been reviewed.
You may now prepare a controlled patch within the approved scope only.

Approved scope:
{{APPROVED_SCOPE}}

Approved files/directories:
{{APPROVED_FILES_OR_DIRECTORIES}}

Explicitly prohibited files/directories:
{{EXPLICITLY_PROHIBITED_FILES_OR_DIRECTORIES}}

Patch rules:

1. Make the smallest safe change that satisfies the approved Flow Bundle step.
2. Keep all changes traceable to Flow Step → Module → File → Test → Evidence.
3. Update or add tests before claiming implementation completion.
4. Do not alter financial, settlement, audit, security, secret, migration, or deployment behavior outside the approved scope.
5. After changes, produce a Patch Evidence Report.

Patch Evidence Report must include:

A. Changed Files
B. Flow Steps Covered
C. Tests Added or Updated
D. Tests Run
E. Evidence Generated
F. Remaining Risk
G. Human Review Required
```

---

## 8. Analysis-Only Prompt Add-On

Use this when Claude Code is allowed to inspect but not modify code.

```text
This is an analysis-only task.
Do not edit, create, delete, rename, or format any file.
Do not run destructive commands.
Do not run migrations.
Do not change dependencies.

Your output must be a report only.

Required report sections:

A. Current Implementation Discovery
B. Existing Module Boundaries
C. Existing Test Coverage
D. Missing Flow Steps
E. Risky Couplings
F. Suggested Implementation Plan
G. Files That Would Need Human Review Before Modification
```

---

## 9. Test-Only Prompt Add-On

Use this when Claude Code is allowed to add or update tests but not production logic.

```text
This is a test-only task.
You may add or update tests inside the approved test directories only.
Do not modify production logic.
Do not modify schema migrations.
Do not modify secrets, deployment scripts, or environment files.

The goal is to improve test coverage for the following Flow Bundle:

{{FLOW_BUNDLE_DOCUMENT}}

Required mapping:

Each test must identify:

1. Flow Step
2. Module
3. Contract or behavior tested
4. Expected evidence output
5. Failure condition covered

After writing tests, produce a Test Coverage Evidence Report.
```

---

## 10. Evidence-Only Prompt Add-On

Use this when Claude Code is allowed to generate evidence reports from existing code/tests without changing runtime behavior.

```text
This is an evidence-only task.
Do not modify runtime logic.
Do not modify tests unless explicitly approved.
Do not run migrations.
Do not alter secrets or deployment configuration.

Generate evidence for:

{{FLOW_BUNDLE_DOCUMENT}}

Evidence must include:

A. Flow Step Coverage
B. Module Coverage
C. Test Coverage
D. Audit/Event Log Coverage
E. Reconciliation Coverage
F. Known Gaps
G. Evidence File Paths
```

---

## 11. Forbidden Area Declaration

The following areas require explicit human approval before any AI-assisted modification.

| Area | Default AI Permission |
|---|---|
| Payment approval logic | Forbidden unless approved |
| Cancel/refund logic | Forbidden unless approved |
| Settlement calculation | Forbidden unless approved |
| Audit ledger write logic | Forbidden unless approved |
| Reconciliation matching logic | Forbidden unless approved |
| DB migration | Forbidden unless approved |
| Secret handling | Forbidden |
| Production deployment | Forbidden |
| Webhook signature verification | Analysis only unless approved |
| DLQ replay that can affect ledger state | Forbidden unless approved |
| Local ledger resync conflict resolution | Forbidden unless approved |
| Evidence export affecting legal/audit records | Forbidden unless approved |

---

## 12. Required Output Format From Claude Code

Every Claude Code response for this lane must use this structure.

```text
## Flow Bundle Response

### 1. Scope Confirmation

### 2. Documents Read

### 3. Flow Step Mapping

### 4. Module Impact

### 5. File Impact

### 6. Test Impact

### 7. Evidence Impact

### 8. Forbidden Area Check

### 9. Changes Proposed or Made

### 10. Commands Run

### 11. Risks and Gaps

### 12. Human Review Required
```

---

## 13. Flow Step To Evidence Rule

No implementation is complete until every affected Flow Step has an evidence record.

Minimum traceability format:

| Flow Step | Module | File | Test | Evidence |
|---|---|---|---|---|
| FS-001 | TBD | TBD | TBD | TBD |
| FS-002 | TBD | TBD | TBD | TBD |
| FS-003 | TBD | TBD | TBD | TBD |

A Flow Step with `TBD` in test or evidence is not implementation-ready.

---

## 14. Cursor Usage Boundary

Cursor may be used for:

- IDE navigation
- local search
- small refactor assistance
- symbol lookup
- test file editing under approved scope
- formatting under approved scope

Cursor must not be used as the primary implementation decision-maker for:

- payment approval flow
- cancel/refund logic
- settlement logic
- audit ledger logic
- reconciliation logic
- secret handling
- DB migration
- production deployment
- large multi-module flow changes

Claude Code is the Flow Bundle implementation agent.
Cursor is the local IDE assistant.
Human approval remains mandatory for financial, audit, security, migration, and deployment boundaries.

---

## 15. Completion Criteria

A Claude Code handoff is complete only when the following conditions are met:

1. Flow Bundle document has been read.
2. Dependency graph has been summarized.
3. Module impact has been mapped.
4. Test coverage has been mapped.
5. Forbidden areas have been checked.
6. Human approval gaps have been identified.
7. Every proposed change maps to Flow Step → Module → File → Test → Evidence.
8. No prohibited area was modified without approval.
9. Evidence report has been generated or explicitly marked as pending.
10. The handoff result can be reviewed without reading raw code diffs first.

---

## 16. Related Documents

| Document | Relationship |
|---|---|
| 700900_Index_Runtime_Flow_Bundle_Registry.md | Registry index |
| 701000_Flow_POS_Gateway_Approval_To_Audit_Ledger_And_Reconciliation.md | Approval flow |
| 701010_Flow_POS_Gateway_Cancel_Refund_Recovery_And_Audit.md | Cancel/refund flow |
| 701020_Flow_POS_Gateway_Timeout_Retry_DLQ_And_Replay.md | Timeout/retry/replay flow |
| 701030_Flow_POS_Gateway_Store_Offline_Local_Ledger_And_Resync.md | Offline/local ledger flow |
| 701040_Flow_POS_Gateway_Webhook_Inbound_Verification_And_Event_Normalization.md | Webhook normalization flow |
| 701050_Flow_POS_Gateway_Settlement_Dispute_And_Evidence_Export.md | Settlement/dispute/evidence flow |
| 701100_Matrix_Flow_To_MD_Dependency_Graph.md | MD dependency graph matrix |
| 701110_Matrix_Flow_To_Module_Implementation_Map.md | Module implementation map |
| 701120_Matrix_Flow_To_Test_Coverage_Map.md | Test coverage map |
| 701200_Checklist_Flow_Bundle_Code_Handoff_Readiness_Gate.md | Pre-code handoff gate |

---

## 17. Governance Note

This template intentionally slows down implementation.

The purpose is to prevent AI-assisted code changes from breaking financial-grade runtime integrity across POS, PG/VAN, settlement, audit ledger, reconciliation, and evidence boundaries.

In this project, speed is secondary to traceability.
