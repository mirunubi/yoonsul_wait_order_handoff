# 000970_Template_POS_Gateway_Approval_Cursor_IDE_File_Level_Assist_Prompt.md

## 1. Document Control

| Field | Value |
|---|---|
| Project | yoonsul_wait_order_handoff / CatchMenu-Catch&Order |
| Band | 00100_project_foundation |
| Document Type | Template |
| Document Role | POS Gateway Approval Cursor IDE File-Level Assist Prompt |
| Related Overview | 000910_Spec_Overview_POS_Gateway_Approval_Main_Flow.md |
| Related Logic | 000920_Spec_Logic_POS_Gateway_Approval_State_Transition_And_Exception_Rule.md |
| Related Module | 000930_Spec_Module_POS_Gateway_Approval_API_Data_Model_And_Test_Map.md |
| Related Traceability Matrix | 000940_Matrix_POS_Gateway_Approval_Overview_Logic_Module_To_Flow_Bundle_Traceability.md |
| Related Handoff Readiness | 000950_Checklist_POS_Gateway_Approval_Code_Handoff_Readiness.md |
| Related Claude Handoff Prompt | 000960_Template_POS_Gateway_Approval_Claude_Code_Handoff_Prompt.md |
| Related General Cursor Prompt | 064320_Template_Flow_Bundle_Cursor_IDE_Assist_Prompt.md |
| Related Runtime Flow Bundle | 064100_Flow_POS_Gateway_Approval_To_Audit_Ledger_And_Reconciliation.md |
| Related No-AI-Solo Governance | 064370_Governance_Flow_Bundle_Human_Approval_And_No_AI_Solo_Zone_Control.md |
| Status | Draft / Pending Hydration |
| Owner | Architecture / Engineering / QA |
| AI Solo Change | Cursor file-level assist allowed only within approved file scope; restricted runtime approval prohibited |

---

## 2. Purpose

This template provides Cursor IDE prompts for POS Gateway Approval work.

Cursor is treated as a file-level and symbol-level assistant, not as a broad implementation owner.

The controlling chain remains:

```text
Overview → Logic → Module → File → Test → Evidence
```

Cursor may assist with:

- reading a specific file
- explaining a specific function
- proposing a narrow patch
- updating a specific test
- checking a specific diff
- identifying a blocker

Cursor must not be used to implement the whole POS Gateway approval flow at once.

---

## 3. Cursor Use Principle

Cursor is useful when the target file is known.

If the target file is not known, do not ask Cursor to implement.  
Use read-only hydration first.

Default Cursor mode:

```text
one task
one file or narrow file set
one logic rule or test scenario
no broad refactor
no restricted approval bypass
```

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
Do not mark UNKNOWN provider state as Approved.
Do not weaken idempotency.
Do not mutate audit history.
Return blockers instead of guessing.
```

---

## 5. Cursor Mode A — File Explanation Only

Use when inspecting a candidate file.

```text
[CURSOR — POS GATEWAY APPROVAL FILE EXPLANATION ONLY]

Explain this file in the context of POS Gateway Approval.

Do not edit.
Do not apply changes.
Do not format.
Do not run migrations.
Do not change secrets.
Do not commit.

Related docs:
- 000910_Spec_Overview_POS_Gateway_Approval_Main_Flow.md
- 000920_Spec_Logic_POS_Gateway_Approval_State_Transition_And_Exception_Rule.md
- 000930_Spec_Module_POS_Gateway_Approval_API_Data_Model_And_Test_Map.md
- 000940_Matrix_POS_Gateway_Approval_Overview_Logic_Module_To_Flow_Bundle_Traceability.md

Target file:
- <actual file path>

Explain:
1. what this file does
2. which POS Gateway Approval module it likely belongs to
3. which Logic rule it may implement
4. whether it touches restricted payment/audit/security behavior
5. candidate tests
6. candidate evidence
7. whether this file is safe for implementation handoff
```

---

## 6. Cursor Mode B — Narrow Documentation Mapping

Use when Cursor has identified a file and you want documentation rows.

```text
[CURSOR — POS GATEWAY APPROVAL DOC MAPPING ONLY]

Do not edit source code.
Do not edit tests.
Do not run formatters.
Do not run migrations.
Do not change secrets.
Do not commit.

Target file:
- <actual file path>

Map this file to:
- 00930 module row
- 00940 traceability row
- 00820 source tree map row
- 00830 owner map row
- 00750 restricted register row if needed

Return only proposed documentation rows.

Required output:
1. source_path
2. likely_module
3. related_logic_rule
4. related_flow_step
5. candidate_tests
6. restricted_zone
7. owner_candidate
8. evidence_target
9. readiness_status
```

---

## 7. Cursor Mode C — Single-File Patch Proposal

Use only after 00950 passes for the target task.

```text
[CURSOR — POS GATEWAY APPROVAL SINGLE-FILE PATCH]

Assist with one narrow file-level change.

Do not modify files outside the allowed file.
Do not refactor unrelated code.
Do not run migrations.
Do not change secrets.
Do not commit.
Do not deploy.

Approved documents:
- Overview: 000910_Spec_Overview_POS_Gateway_Approval_Main_Flow.md
- Logic: 000920_Spec_Logic_POS_Gateway_Approval_State_Transition_And_Exception_Rule.md
- Module: 000930_Spec_Module_POS_Gateway_Approval_API_Data_Model_And_Test_Map.md
- Traceability: 000940_Matrix_POS_Gateway_Approval_Overview_Logic_Module_To_Flow_Bundle_Traceability.md
- Handoff Readiness: 000950_Checklist_POS_Gateway_Approval_Code_Handoff_Readiness.md

Allowed file:
- <actual file path>

Task:
<single narrow task>

Related Logic Rule:
- <LOGIC-POS-APP-Rxxx>

Required behavior:
- Preserve idempotency.
- Do not mark UNKNOWN as Approved.
- Do not mutate audit history.
- Do not log secrets or sensitive payment payloads.
- Keep diff minimal.

Required output:
1. patch summary
2. changed lines/functions
3. logic rule addressed
4. tests that must be run
5. restricted-zone note
6. remaining blockers
```

---

## 8. Cursor Mode D — Test File Assist

Use when the target is a test file.

```text
[CURSOR — POS GATEWAY APPROVAL TEST ASSIST]

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
- <LOGIC-POS-APP-Rxxx>

Scenario:
<validation / duplicate / conflict / timeout / approved / rejected / audit / reconciliation / projection>

Required test behavior:
- verify expected state transition
- verify evidence or audit side effect where applicable
- verify UNKNOWN is not treated as Approved
- verify duplicate approval is not created
- verify restricted behavior is not weakened

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
[CURSOR — POS GATEWAY APPROVAL DIFF REVIEW]

Review the current diff only.

Do not edit.
Do not auto-fix.
Do not format.
Do not run migrations.
Do not change secrets.
Do not commit.
Do not deploy.

Review against:
- 00910 Overview
- 00920 Logic
- 00930 Module
- 00940 Traceability
- 00950 Handoff Readiness
- allowed file list
- prohibited file list
- restricted register
- required tests
- required evidence

Return:
1. changed_files
2. any_unapproved_file_changes
3. related_logic_rules
4. idempotency_risk
5. UNKNOWN_state_risk
6. audit_mutation_risk
7. secret_log_risk
8. missing_tests
9. missing_evidence
10. recommendation: accept / revise / rollback / split
```

---

## 10. Cursor Mode F — Blocker Extraction

Use when Cursor cannot safely implement.

```text
[CURSOR — POS GATEWAY APPROVAL BLOCKER EXTRACTION]

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
3. missing module mapping
4. missing test
5. missing evidence
6. missing approval
7. restricted-zone concern
8. recommended next safe action
```

---

## 11. Unsafe Cursor Prompts

Do not use:

```text
Implement the approval flow.
Fix payment approval.
Refactor the gateway.
Update whatever files are needed.
Make tests pass.
Change DB if needed.
Commit the fix.
```

These are unsafe because they violate the project’s file-level scope and restricted-zone controls.

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
- [ ] Related Trace ID is specified in 00940.
- [ ] Test file is known or test gap is explicitly recorded.
- [ ] Evidence target is known.
- [ ] Human approval exists if restricted zone is touched.
- [ ] Prompt includes all absolute prohibitions.

---

## 14. Summary

Cursor may help the POS Gateway Approval implementation only as a narrow file-level assistant.

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
broadly implement payment runtime
```

No Cursor task may bypass:

```text
Overview → Logic → Module → File → Test → Evidence
```
