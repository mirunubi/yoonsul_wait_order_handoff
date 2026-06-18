# 064320_Template_Flow_Bundle_Cursor_IDE_Assist_Prompt.md

## 1. Document Control

- Document Number: 64320
- Document Type: Template
- Document Title: Flow Bundle Cursor IDE Assist Prompt
- Project: yoonsul_wait_order_handoff
- Service Names: CatchMenu / Catch & Order
- Registry Band: 64000 Runtime Flow Bundle Registry
- Related Index: 064000_Index_Runtime_Flow_Bundle_Registry.md
- Related Handoff Template: 064310_Template_Flow_Bundle_Claude_Code_Handoff_Prompt.md
- Status: Draft
- Owner: Runtime Flow / POS Gateway / Financial Audit Architecture

---

## 2. Purpose

This template defines the standard prompt to be given to Cursor when assisting with implementation work for a Runtime Flow Bundle.

Cursor must not be treated as the primary architecture or autonomous implementation agent for CatchMenu / Catch & Order financial-grade runtime flows.

Cursor is used only as an IDE-level assistant for:

1. limited file inspection,
2. local refactoring assistance,
3. diff review,
4. test gap identification,
5. small bounded edits,
6. evidence checklist support.

Cursor must not independently redefine Flow Bundle boundaries, payment logic, settlement rules, audit ledger behavior, secret handling, database migration, or production deployment behavior.

---

## 3. Core Principle

The implementation unit is not a single Markdown file.

The implementation unit is a Flow Bundle.

Each Flow Bundle must already have the following four artifacts before Cursor is used:

1. MD Dependency Graph,
2. Runtime Flow Diagram,
3. Module Impact Map,
4. Test Coverage Map.

Cursor may assist only after these artifacts are prepared and reviewed.

---

## 4. Cursor Role Definition

Cursor is a controlled IDE assistant.

Cursor may:

- inspect files named in the approved Flow Bundle handoff,
- explain how an existing module behaves,
- propose small edits within the approved module boundary,
- identify missing tests mapped to the Flow Bundle,
- generate local test scaffolding when explicitly instructed,
- review diffs against the Flow Step → Module → File → Test → Evidence chain,
- detect accidental edits outside the approved scope.

Cursor must not:

- invent a new runtime flow,
- edit payment approval logic without explicit human approval,
- edit cancellation/refund logic without explicit human approval,
- edit settlement or reconciliation logic without explicit human approval,
- edit audit ledger immutability logic without explicit human approval,
- edit database migrations without explicit human approval,
- edit secrets, credentials, vault references, or environment variable contracts,
- edit production deployment scripts,
- modify security boundaries,
- silently change idempotency keys,
- remove or loosen tests,
- collapse multiple financial states into a simplified boolean status,
- replace evidence requirements with log-only behavior.

---

## 5. Standard Cursor Prompt

Copy the following prompt into Cursor when requesting IDE-level assistance.

```text
You are assisting with the yoonsul_wait_order_handoff project.

Service context:
- Customer-facing name: CatchMenu
- SaaS/provider-facing name: Catch & Order
- Runtime domain: POS Gateway / PG/VAN / settlement / audit ledger / reconciliation
- Architecture rule: implementation is controlled by Flow Bundle, not by a single Markdown file.

Your role:
You are not the autonomous implementation owner.
You are an IDE-level assistant only.
You must work within the approved Flow Bundle boundary.
You must not redesign the runtime architecture.
You must not expand the edit scope unless explicitly instructed by the human owner.

Approved Flow Bundle:
- Flow Bundle ID: {{FLOW_BUNDLE_ID}}
- Flow Bundle File: {{FLOW_BUNDLE_FILE}}
- Related Index: 064000_Index_Runtime_Flow_Bundle_Registry.md
- MD Dependency Graph: {{MD_DEPENDENCY_GRAPH_FILE}}
- Runtime Flow Diagram: {{RUNTIME_FLOW_DIAGRAM_FILE}}
- Module Impact Map: {{MODULE_IMPACT_MAP_FILE}}
- Test Coverage Map: {{TEST_COVERAGE_MAP_FILE}}

Allowed files/modules:
{{ALLOWED_FILE_LIST}}

Forbidden areas unless separately approved by the human owner:
- payment approval state machine
- cancel/refund state machine
- settlement and reconciliation rules
- audit ledger immutability rules
- database migration files
- secret, credential, vault, and environment variable contracts
- production deployment scripts
- security boundary policies
- idempotency key format changes
- webhook signature verification weakening
- evidence retention rules

Required working order:
1. Read the Flow Bundle file first.
2. Read the MD Dependency Graph.
3. Read the Runtime Flow Diagram.
4. Read the Module Impact Map.
5. Read the Test Coverage Map.
6. Confirm the exact files you will inspect.
7. Before editing, list the Flow Step → Module → File → Test → Evidence chain affected by the proposed change.
8. Do not edit outside the allowed file list.
9. After any proposed change, provide a diff summary and test impact summary.
10. Mark any unresolved risk as BLOCKED, not as completed.

Task requested:
{{TASK_REQUEST}}

Output format:
1. Scope confirmation
2. Files inspected
3. Proposed change summary
4. Flow Step impact
5. Module impact
6. File impact
7. Test impact
8. Evidence impact
9. Risk / blocked items
10. Diff summary

Important:
If the requested change touches a forbidden area, stop and return:
"BLOCKED — human approval required before editing this area."
```

---

## 6. Required Variables

Every Cursor handoff must fill the following variables before use.

| Variable | Required | Description |
|---|---:|---|
| `{{FLOW_BUNDLE_ID}}` | Yes | Flow Bundle number, for example `64100` |
| `{{FLOW_BUNDLE_FILE}}` | Yes | Approved Flow document filename |
| `{{MD_DEPENDENCY_GRAPH_FILE}}` | Yes | Dependency graph source file |
| `{{RUNTIME_FLOW_DIAGRAM_FILE}}` | Yes | Runtime flow diagram source or section |
| `{{MODULE_IMPACT_MAP_FILE}}` | Yes | Module impact map source file |
| `{{TEST_COVERAGE_MAP_FILE}}` | Yes | Test coverage map source file |
| `{{ALLOWED_FILE_LIST}}` | Yes | Exact implementation files Cursor may inspect or edit |
| `{{TASK_REQUEST}}` | Yes | Narrow IDE-level task to perform |

---

## 7. Recommended Task Types For Cursor

Cursor is suitable for the following task types.

### 7.1 Read-Only Inspection

Use Cursor to inspect whether a module appears to match the Flow Bundle.

Example task:

```text
Inspect the listed files only and tell me whether the implementation matches Flow Bundle 64120 timeout/retry/DLQ/replay rules. Do not edit anything.
```

### 7.2 Bounded Refactor

Use Cursor for local refactoring when the behavior must not change.

Example task:

```text
Refactor only the retry status naming helper in the approved file list. Do not change state transitions, idempotency keys, settlement rules, or audit ledger behavior.
```

### 7.3 Test Gap Review

Use Cursor to compare tests against the Test Coverage Map.

Example task:

```text
Compare the existing tests with the Flow Bundle 64140 webhook verification test coverage map. List missing tests only. Do not write code yet.
```

### 7.4 Diff Review

Use Cursor to review a patch produced by Claude Code or a human developer.

Example task:

```text
Review this diff against Flow Bundle 64100. Identify any scope creep, forbidden edits, missing tests, or missing evidence outputs. Do not modify files.
```

---

## 8. Cursor Stop Conditions

Cursor must stop immediately if any of the following occurs:

1. the requested change requires a database migration,
2. the requested change touches a secret or credential contract,
3. the requested change modifies production deployment behavior,
4. the requested change weakens webhook verification,
5. the requested change changes payment, cancel, refund, settlement, or audit ledger semantics,
6. the requested change removes evidence output,
7. the requested change requires reading undocumented files outside the allowed file list,
8. the requested change conflicts with the Flow Bundle documents,
9. the requested change lacks a mapped test,
10. the requested change cannot be tied to a Flow Step.

Stop response format:

```text
BLOCKED — human approval required before editing this area.

Reason:
- {{REASON}}

Affected forbidden area:
- {{FORBIDDEN_AREA}}

Required next step:
- Update or approve the relevant Flow Bundle artifact before implementation continues.
```

---

## 9. Evidence Requirements

Cursor must not consider a task complete unless it identifies the evidence affected by the change.

Evidence may include:

- unit test output,
- integration test output,
- contract test output,
- replay test result,
- DLQ recovery evidence,
- webhook verification evidence,
- audit ledger append evidence,
- reconciliation mismatch evidence,
- settlement export evidence,
- manual approval record,
- human review note,
- deployment gate record.

If no evidence exists, Cursor must mark the task as incomplete.

---

## 10. Required Cursor Completion Response

Cursor should end every task with the following structure.

```text
Cursor Assist Completion Report

1. Scope confirmation
- Flow Bundle: {{FLOW_BUNDLE_ID}}
- Files inspected: {{FILES_INSPECTED}}
- Files changed: {{FILES_CHANGED}}

2. Flow Step impact
- {{FLOW_STEP_IMPACT}}

3. Module impact
- {{MODULE_IMPACT}}

4. Test impact
- {{TEST_IMPACT}}

5. Evidence impact
- {{EVIDENCE_IMPACT}}

6. Forbidden area check
- Payment approval logic changed: Yes/No
- Cancel/refund logic changed: Yes/No
- Settlement/reconciliation logic changed: Yes/No
- Audit ledger immutability changed: Yes/No
- DB migration changed: Yes/No
- Secret/credential contract changed: Yes/No
- Production deployment changed: Yes/No
- Security boundary changed: Yes/No

7. Remaining blocked items
- {{BLOCKED_ITEMS}}

8. Final status
- COMPLETE / INCOMPLETE / BLOCKED
```

---

## 11. Relationship To Claude Code

Claude Code is the preferred Flow Bundle implementation agent.

Cursor is not the primary implementation agent for financial-grade runtime flows.

Recommended division:

| Area | Claude Code | Cursor |
|---|---:|---:|
| Flow Bundle implementation | Primary | Assist only |
| Multi-file architecture changes | Primary with human review | No |
| IDE navigation | Optional | Primary |
| Local small refactor | Allowed with scope | Allowed with scope |
| Diff review | Allowed | Strongly allowed |
| Test gap review | Allowed | Strongly allowed |
| Payment/settlement/audit logic | Human-gated | Human-gated assist only |
| DB migration | Human-gated | No autonomous edit |
| Secret handling | Human-gated | No autonomous edit |
| Production deployment | Human-gated | No autonomous edit |

---

## 12. Human Approval Requirement

Human approval is mandatory before Cursor edits any file that affects:

1. money movement,
2. payment approval state,
3. cancellation/refund state,
4. settlement calculation,
5. reconciliation matching,
6. audit ledger immutability,
7. webhook verification,
8. idempotency key generation,
9. database schema,
10. secret or credential handling,
11. deployment or rollback.

Approval must be documented in the Evidence chain.

---

## 13. Example Filled Prompt

```text
You are assisting with the yoonsul_wait_order_handoff project.

Service context:
- Customer-facing name: CatchMenu
- SaaS/provider-facing name: Catch & Order
- Runtime domain: POS Gateway / PG/VAN / settlement / audit ledger / reconciliation
- Architecture rule: implementation is controlled by Flow Bundle, not by a single Markdown file.

Your role:
You are an IDE-level assistant only.
Do not redesign the runtime architecture.
Do not expand the edit scope.

Approved Flow Bundle:
- Flow Bundle ID: 64120
- Flow Bundle File: 064120_Flow_POS_Gateway_Timeout_Retry_DLQ_And_Replay.md
- Related Index: 064000_Index_Runtime_Flow_Bundle_Registry.md
- MD Dependency Graph: 064200_Matrix_Flow_To_MD_Dependency_Graph.md
- Runtime Flow Diagram: 64120 section 6
- Module Impact Map: 064210_Matrix_Flow_To_Module_Implementation_Map.md
- Test Coverage Map: 064220_Matrix_Flow_To_Test_Coverage_Map.md

Allowed files/modules:
- src/pos-gateway/retry-policy/*
- src/pos-gateway/dlq/*
- tests/pos-gateway/retry-policy/*
- tests/pos-gateway/dlq/*

Forbidden areas unless separately approved:
- payment approval state machine
- settlement and reconciliation rules
- audit ledger immutability rules
- database migration files
- secret, credential, vault, and environment variable contracts
- production deployment scripts

Task requested:
Inspect the existing retry and DLQ tests. List missing test cases against Flow Bundle 64120. Do not edit files.

Output format:
1. Scope confirmation
2. Files inspected
3. Proposed change summary
4. Flow Step impact
5. Module impact
6. File impact
7. Test impact
8. Evidence impact
9. Risk / blocked items
10. Diff summary
```

---

## 14. Acceptance Criteria

This template is accepted when:

1. Cursor is clearly limited to IDE assistance,
2. Flow Bundle is confirmed as the implementation unit,
3. allowed file boundaries are explicit,
4. forbidden financial/security/deployment areas are explicit,
5. Cursor must stop on human-gated areas,
6. test and evidence impact must be reported,
7. completion status supports COMPLETE / INCOMPLETE / BLOCKED,
8. the template can be copied directly into Cursor.

---

## 15. Cross References

- 064000_Index_Runtime_Flow_Bundle_Registry.md
- 064100_Flow_POS_Gateway_Approval_To_Audit_Ledger_And_Reconciliation.md
- 064110_Flow_POS_Gateway_Cancel_Refund_Recovery_And_Audit.md
- 064120_Flow_POS_Gateway_Timeout_Retry_DLQ_And_Replay.md
- 064130_Flow_POS_Gateway_Store_Offline_Local_Ledger_And_Resync.md
- 064140_Flow_POS_Gateway_Webhook_Inbound_Verification_And_Event_Normalization.md
- 064150_Flow_POS_Gateway_Settlement_Dispute_And_Evidence_Export.md
- 064200_Matrix_Flow_To_MD_Dependency_Graph.md
- 064210_Matrix_Flow_To_Module_Implementation_Map.md
- 064220_Matrix_Flow_To_Test_Coverage_Map.md
- 064300_Checklist_Flow_Bundle_Code_Handoff_Readiness_Gate.md
- 064310_Template_Flow_Bundle_Claude_Code_Handoff_Prompt.md
