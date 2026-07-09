# 001060_Template_POS_Gateway_Cancel_Refund_Cursor_IDE_File_Level_Assist_Prompt.md

## 1. Document Control

| Field | Value |
|---|---|
| Project | yoonsul_wait_order_handoff / CatchMenu-Catch&Order |
| Band | 00100_project_foundation |
| Document Type | Template |
| Document Role | POS Gateway Cancel / Refund Cursor IDE File-Level Assist Prompt |
| Related Overview | 001000_Spec_Overview_POS_Gateway_Cancel_Refund_Recovery_Main_Flow.md |
| Related Logic | 001010_Spec_Logic_POS_Gateway_Cancel_Refund_State_Transition_And_Exception_Rule.md |
| Related Module | 001020_Spec_Module_POS_Gateway_Cancel_Refund_API_Data_Model_And_Test_Map.md |
| Related Traceability Matrix | 001030_Matrix_POS_Gateway_Cancel_Refund_Overview_Logic_Module_To_Flow_Bundle_Traceability.md |
| Related Handoff Readiness | 001040_Checklist_POS_Gateway_Cancel_Refund_Code_Handoff_Readiness.md |
| Related Claude Handoff Prompt | 001050_Template_POS_Gateway_Cancel_Refund_Claude_Code_Handoff_Prompt.md |
| Related Approval Cursor Prompt | 000970_Template_POS_Gateway_Approval_Cursor_IDE_File_Level_Assist_Prompt.md |
| Related General Cursor Prompt | 064320_Template_Flow_Bundle_Cursor_IDE_Assist_Prompt.md |
| Related Runtime Flow Bundle | 064110_Flow_POS_Gateway_Cancel_Refund_Recovery_And_Audit.md |
| Related No-AI-Solo Governance | 064370_Governance_Flow_Bundle_Human_Approval_And_No_AI_Solo_Zone_Control.md |
| Status | Draft / Pending Hydration |
| Owner | Architecture / Engineering / QA |
| AI Solo Change | Cursor file-level assist allowed only within approved scope; refund runtime approval prohibited |

---

## 2. Purpose

This template provides Cursor IDE prompts for POS Gateway Cancel / Refund / Recovery work.

Cursor is treated as a file-level assistant, not as a refund implementation owner.

The controlling chain remains:

```text
Overview → Logic → Module → File → Test → Evidence
```

Cursor may assist with:

- explaining a specific file,
- mapping a specific file to Logic/Module/Trace rows,
- proposing a narrow single-file patch,
- updating a specific test file,
- reviewing a specific diff,
- extracting blockers.

Cursor must not be used to implement the whole cancel/refund flow broadly.

---

## 3. Cursor Use Principle

Refund work must be narrower than ordinary feature work.

Default Cursor rule:

```text
one task
one file or narrow file set
one Logic rule
one Trace ID
one test target
no broad refactor
no restricted approval bypass
```

If target file, Logic rule, test, or approval is unknown, Cursor must not perform runtime modification.

---

## 4. Absolute Prohibitions

Every Cursor prompt must include:

```text
Do not expand scope.
Do not modify files outside the allowed list.
Do not refactor unrelated code.
Do not run migrations.
Do not change secrets, tokens, credentials, vault, env, CI/CD, deploy, infra, or production release files.
Do not commit.
Do not deploy.
Do not create duplicate refund behavior.
Do not allow refund greater than remaining refundable amount.
Do not mark UNKNOWN provider state as Cancelled or Refunded.
Do not bypass policy or manager approval.
Do not weaken idempotency.
Do not mutate audit history.
Return blockers instead of guessing.
```

---

## 5. Cursor Mode A — File Explanation Only

Use when inspecting a candidate file.

```text
[CURSOR — POS GATEWAY CANCEL / REFUND FILE EXPLANATION ONLY]

Explain this file in the context of POS Gateway Cancel / Refund / Recovery.

Do not edit.
Do not apply changes.
Do not format.
Do not run migrations.
Do not change secrets.
Do not commit.

Related docs:
- 001000_Spec_Overview_POS_Gateway_Cancel_Refund_Recovery_Main_Flow.md
- 001010_Spec_Logic_POS_Gateway_Cancel_Refund_State_Transition_And_Exception_Rule.md
- 001020_Spec_Module_POS_Gateway_Cancel_Refund_API_Data_Model_And_Test_Map.md
- 001030_Matrix_POS_Gateway_Cancel_Refund_Overview_Logic_Module_To_Flow_Bundle_Traceability.md
- 001040_Checklist_POS_Gateway_Cancel_Refund_Code_Handoff_Readiness.md

Target file:
- <actual file path>

Explain:
1. what this file does
2. which cancel/refund module it likely belongs to
3. which Logic rule it may implement
4. whether it touches restricted refund/payment/audit/security behavior
5. whether it depends on original approval state
6. candidate tests
7. candidate evidence
8. whether this file is safe for implementation handoff
```

---

## 6. Cursor Mode B — Narrow Documentation Mapping

Use when Cursor has identified a file and you want documentation rows.

```text
[CURSOR — POS GATEWAY CANCEL / REFUND DOC MAPPING ONLY]

Do not edit source code.
Do not edit tests.
Do not run formatters.
Do not run migrations.
Do not change secrets.
Do not commit.

Target file:
- <actual file path>

Map this file to:
- 01020 module row
- 01030 traceability row
- 00820 source tree map row
- 00830 owner map row
- 00750 restricted register row if needed

Return only proposed documentation rows.

Required output:
1. source_path
2. likely_module
3. related_logic_rule
4. related_trace_id
5. related_flow_step
6. original_approval_dependency
7. candidate_tests
8. restricted_zone
9. owner_candidate
10. evidence_target
11. readiness_status
```

---

## 7. Cursor Mode C — Single-File Patch Proposal

Use only after 01040 passes for the target task.

```text
[CURSOR — POS GATEWAY CANCEL / REFUND SINGLE-FILE PATCH]

Assist with one narrow file-level change.

Do not modify files outside the allowed file.
Do not refactor unrelated code.
Do not run migrations.
Do not change secrets.
Do not commit.
Do not deploy.

Approved documents:
- Overview: 001000_Spec_Overview_POS_Gateway_Cancel_Refund_Recovery_Main_Flow.md
- Logic: 001010_Spec_Logic_POS_Gateway_Cancel_Refund_State_Transition_And_Exception_Rule.md
- Module: 001020_Spec_Module_POS_Gateway_Cancel_Refund_API_Data_Model_And_Test_Map.md
- Traceability: 001030_Matrix_POS_Gateway_Cancel_Refund_Overview_Logic_Module_To_Flow_Bundle_Traceability.md
- Handoff Readiness: 001040_Checklist_POS_Gateway_Cancel_Refund_Code_Handoff_Readiness.md

Allowed file:
- <actual file path>

Task:
<single narrow task>

Related Logic Rule:
- <LOGIC-POS-CREF-Rxxx>

Related Trace ID:
- <POSCREF-TRACE-xxx>

Required behavior:
- Prevent duplicate refund.
- Prevent over-refund.
- Do not show UNKNOWN as Cancelled or Refunded.
- Do not bypass policy or manager approval.
- Do not mutate payment/refund/audit history.
- Do not log secrets or sensitive payment payloads.
- Keep diff minimal.

Required output:
1. patch summary
2. changed lines/functions
3. logic rule addressed
4. trace id addressed
5. tests that must be run
6. restricted-zone note
7. remaining blockers
```

---

## 8. Cursor Mode D — Test File Assist

Use when the target is a test file.

```text
[CURSOR — POS GATEWAY CANCEL / REFUND TEST ASSIST]

Assist only with the listed test file.

Do not modify production source files.
Do not modify migrations.
Do not change secrets.
Do not commit.

Allowed test file:
- <actual test path>

Related production file:
- <actual source path>

Related Logic Rule:
- <LOGIC-POS-CREF-Rxxx>

Related Trace ID:
- <POSCREF-TRACE-xxx>

Scenario:
<original payment validation / amount guard / over-refund / authority / duplicate / conflict / provider success / provider rejection / timeout / mismatch / audit / reconciliation / projection>

Required test behavior:
- verify expected state transition,
- verify no duplicate refund is created,
- verify over-refund is blocked,
- verify UNKNOWN is not treated as Cancelled or Refunded,
- verify policy/manager approval is not bypassed where required,
- verify evidence or audit side effect where applicable.

Return:
1. test intent
2. proposed test cases
3. patch summary if changed
4. tests to run
5. remaining gaps
```

---

## 9. Cursor Mode E — Diff Review

Use after Cursor or another tool produces a diff.

```text
[CURSOR — POS GATEWAY CANCEL / REFUND DIFF REVIEW]

Review the current diff only.

Do not edit.
Do not auto-fix.
Do not format.
Do not run migrations.
Do not change secrets.
Do not commit.
Do not deploy.

Review against:
- 01000 Overview
- 01010 Logic
- 01020 Module
- 01030 Traceability
- 01040 Handoff Readiness
- allowed file list
- prohibited file list
- restricted register
- original approval dependency
- required tests
- required evidence

Return:
1. changed_files
2. any_unapproved_file_changes
3. related_logic_rules
4. related_trace_ids
5. duplicate_refund_risk
6. over_refund_risk
7. UNKNOWN_state_risk
8. policy_authority_bypass_risk
9. audit_mutation_risk
10. secret_log_risk
11. missing_tests
12. missing_evidence
13. recommendation: accept / revise / rollback / split
```

---

## 10. Cursor Mode F — Blocker Extraction

Use when Cursor cannot safely implement.

```text
[CURSOR — POS GATEWAY CANCEL / REFUND BLOCKER EXTRACTION]

Do not edit.
Do not guess.

Explain why this task cannot safely proceed.

Task:
<requested task>

Allowed files:
- <file path or TBD>

Return:
1. missing source path
2. missing logic rule
3. missing trace id
4. missing module mapping
5. missing original approval dependency
6. missing test
7. missing evidence
8. missing approval
9. restricted-zone concern
10. recommended next safe action
```

---

## 11. Unsafe Cursor Prompts

Do not use:

```text
Implement refund.
Fix cancel/refund.
Make refund work.
Update anything needed.
Refactor refund flow.
Allow partial refunds.
Make tests pass.
Run migrations if needed.
Commit it.
```

These prompts violate file-level scope and restricted-zone controls.

---

## 12. Cursor Handoff Record

After a Cursor session, record:

| Field | Value |
|---|---|
| Cursor Mode Used | A / B / C / D / E / F |
| Date | YYYY-MM-DD |
| Operator | TBD |
| Target File(s) | TBD |
| Related Logic Rule | TBD |
| Related Trace ID | TBD |
| Original Approval Dependency Checked? | Yes / No |
| Source Modified? | Yes / No |
| Test Modified? | Yes / No |
| Restricted Zone Touched? | Yes / No |
| Human Approval Evidence | TBD |
| Tests Run | TBD |
| Evidence Updated | TBD |
| Result | Explanation / Mapping / Patch / Test / Review / Blocked |
| Next Action | TBD |

---

## 13. Cursor Readiness Checklist

Before using Cursor for runtime modification:

- [ ] Target file is known.
- [ ] Target file is listed in allowed files.
- [ ] Target file is mapped in 00820.
- [ ] Module owner is known in 00830.
- [ ] Restricted status is known in 00750.
- [ ] Related Logic rule is specified.
- [ ] Related Trace ID is specified in 01030.
- [ ] Original approval dependency is known.
- [ ] Test file is known or test gap is explicitly recorded.
- [ ] Evidence target is known.
- [ ] Human approval exists if restricted zone is touched.
- [ ] Prompt includes all absolute prohibitions.

---

## 14. Summary

Cursor may help the POS Gateway Cancel / Refund / Recovery implementation only as a narrow file-level assistant.

The safe default is:

```text
read
explain
map
review
propose narrow change
```

The unsafe pattern is:

```text
broadly implement refund runtime
```

No Cursor task may bypass:

```text
Overview → Logic → Module → File → Test → Evidence
```
