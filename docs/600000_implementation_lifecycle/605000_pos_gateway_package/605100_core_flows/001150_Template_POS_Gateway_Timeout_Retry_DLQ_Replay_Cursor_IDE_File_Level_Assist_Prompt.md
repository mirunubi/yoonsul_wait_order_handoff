# 001150_Template_POS_Gateway_Timeout_Retry_DLQ_Replay_Cursor_IDE_File_Level_Assist_Prompt.md

## 1. Document Control

| Field | Value |
|---|---|
| Project | yoonsul_wait_order_handoff / CatchMenu-Catch&Order |
| Band | 00100_project_foundation |
| Document Type | Template |
| Document Role | POS Gateway Timeout / Retry / DLQ / Replay Cursor IDE File-Level Assist Prompt |
| Related Overview | 001090_Spec_Overview_POS_Gateway_Timeout_Retry_DLQ_And_Replay_Main_Flow.md |
| Related Logic | 001100_Spec_Logic_POS_Gateway_Timeout_Retry_DLQ_Replay_State_Transition_And_Exception_Rule.md |
| Related Module | 001110_Spec_Module_POS_Gateway_Timeout_Retry_DLQ_Replay_API_Data_Model_And_Test_Map.md |
| Related Traceability Matrix | 001120_Matrix_POS_Gateway_Timeout_Retry_DLQ_Replay_Overview_Logic_Module_To_Flow_Bundle_Traceability.md |
| Related Handoff Readiness | 001130_Checklist_POS_Gateway_Timeout_Retry_DLQ_Replay_Code_Handoff_Readiness.md |
| Related Claude Handoff Prompt | 001140_Template_POS_Gateway_Timeout_Retry_DLQ_Replay_Claude_Code_Handoff_Prompt.md |
| Related General Cursor Prompt | 064320_Template_Flow_Bundle_Cursor_IDE_Assist_Prompt.md |
| Related Runtime Flow Bundle | 064120_Flow_POS_Gateway_Timeout_Retry_DLQ_And_Replay.md |
| Related No-AI-Solo Governance | 064370_Governance_Flow_Bundle_Human_Approval_And_No_AI_Solo_Zone_Control.md |
| Status | Draft / Pending Hydration |
| Owner | Architecture / Engineering / QA / Compliance / Operations |
| AI Solo Change | Cursor file-level assist allowed only within approved scope; retry/replay runtime approval prohibited |

---

## 2. Purpose

This template provides Cursor IDE prompts for POS Gateway Timeout / Retry / DLQ / Replay work.

Cursor is treated as a file-level assistant, not as a runtime owner.

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

Cursor must not be used to implement retry/replay broadly.

---

## 3. Cursor Use Principle

Timeout/retry/DLQ/replay work must be narrower than ordinary backend work.

Default Cursor rule:

```text
one task
one file or narrow file set
one Logic rule
one Trace ID
one test target
one policy reference
no broad refactor
no restricted approval bypass
```

If target file, Logic rule, test, retry budget, DLQ owner, replay policy, or approval is unknown, Cursor must not perform runtime modification.

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
Do not create duplicate approval behavior.
Do not create duplicate refund behavior.
Do not replay a money-moving operation as a new independent command.
Do not mark UNKNOWN external state as final success or final failure.
Do not bypass replay approval.
Do not bypass retry budget.
Do not bypass DLQ ownership and review.
Do not weaken idempotency or payload-hash checks.
Do not mutate audit history.
Return blockers instead of guessing.
```

---

## 5. Cursor Mode A — File Explanation Only

Use when inspecting a candidate file.

```text
[CURSOR — POS GATEWAY TIMEOUT / RETRY / DLQ / REPLAY FILE EXPLANATION ONLY]

Explain this file in the context of POS Gateway Timeout / Retry / DLQ / Replay.

Do not edit.
Do not apply changes.
Do not format.
Do not run migrations.
Do not change secrets.
Do not commit.

Related docs:
- 001090_Spec_Overview_POS_Gateway_Timeout_Retry_DLQ_And_Replay_Main_Flow.md
- 001100_Spec_Logic_POS_Gateway_Timeout_Retry_DLQ_Replay_State_Transition_And_Exception_Rule.md
- 001110_Spec_Module_POS_Gateway_Timeout_Retry_DLQ_Replay_API_Data_Model_And_Test_Map.md
- 001120_Matrix_POS_Gateway_Timeout_Retry_DLQ_Replay_Overview_Logic_Module_To_Flow_Bundle_Traceability.md
- 001130_Checklist_POS_Gateway_Timeout_Retry_DLQ_Replay_Code_Handoff_Readiness.md

Target file:
- <actual file path>

Explain:
1. what this file does
2. which timeout/retry/DLQ/replay module it likely belongs to
3. which Logic rule it may implement
4. which Trace ID it may support
5. whether it touches restricted retry/payment/refund/audit/security behavior
6. whether it depends on approval or cancel/refund package state
7. whether it depends on retry budget / DLQ owner / replay policy
8. candidate tests
9. candidate evidence
10. whether this file is safe for implementation handoff
```

---

## 6. Cursor Mode B — Narrow Documentation Mapping

Use when Cursor has identified a file and you want documentation rows.

```text
[CURSOR — POS GATEWAY TIMEOUT / RETRY / DLQ / REPLAY DOC MAPPING ONLY]

Do not edit source code.
Do not edit tests.
Do not run formatters.
Do not run migrations.
Do not change secrets.
Do not commit.

Target file:
- <actual file path>

Map this file to:
- 01110 module row
- 01120 traceability row
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
6. upstream approval/refund dependency
7. candidate_tests
8. restricted_zone
9. owner_candidate
10. policy_dependency: retry budget / DLQ owner / replay approval / none
11. evidence_target
12. readiness_status
```

---

## 7. Cursor Mode C — Single-File Patch Proposal

Use only after 01130 passes for the target task.

```text
[CURSOR — POS GATEWAY TIMEOUT / RETRY / DLQ / REPLAY SINGLE-FILE PATCH]

Assist with one narrow file-level change.

Do not modify files outside the allowed file.
Do not refactor unrelated code.
Do not run migrations.
Do not change secrets.
Do not commit.
Do not deploy.

Approved documents:
- Overview: 001090_Spec_Overview_POS_Gateway_Timeout_Retry_DLQ_And_Replay_Main_Flow.md
- Logic: 001100_Spec_Logic_POS_Gateway_Timeout_Retry_DLQ_Replay_State_Transition_And_Exception_Rule.md
- Module: 001110_Spec_Module_POS_Gateway_Timeout_Retry_DLQ_Replay_API_Data_Model_And_Test_Map.md
- Traceability: 001120_Matrix_POS_Gateway_Timeout_Retry_DLQ_Replay_Overview_Logic_Module_To_Flow_Bundle_Traceability.md
- Handoff Readiness: 001130_Checklist_POS_Gateway_Timeout_Retry_DLQ_Replay_Code_Handoff_Readiness.md

Allowed file:
- <actual file path>

Task:
<single narrow task>

Related Logic Rule:
- <LOGIC-POS-TRDR-Rxxx>

Related Trace ID:
- <POSTRDR-TRACE-xxx>

Policy References:
- Retry budget: <reference or N/A>
- DLQ owner/SLA: <reference or N/A>
- Replay approval: <reference or N/A>

Required behavior:
- Prevent duplicate approval.
- Prevent duplicate refund.
- Do not replay money movement as a new independent command.
- Do not show UNKNOWN as final success or final failure.
- Do not bypass retry budget.
- Do not bypass DLQ ownership.
- Do not bypass replay approval.
- Do not weaken idempotency or payload-hash checks.
- Do not mutate payment/refund/audit history.
- Do not log secrets or sensitive payment payloads.
- Keep diff minimal.

Required output:
1. patch summary
2. changed lines/functions
3. logic rule addressed
4. trace id addressed
5. policy references checked
6. tests that must be run
7. restricted-zone note
8. remaining blockers
```

---

## 8. Cursor Mode D — Test File Assist

Use when the target is a test file.

```text
[CURSOR — POS GATEWAY TIMEOUT / RETRY / DLQ / REPLAY TEST ASSIST]

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
- <LOGIC-POS-TRDR-Rxxx>

Related Trace ID:
- <POSTRDR-TRACE-xxx>

Scenario:
<timeout classification / ambiguous response / missing idempotency / payload conflict / terminal state block / retry eligibility / retry budget exhausted / DLQ routing / replay request / replay block / replay execution / audit / outcome verification / UNKNOWN recovery / safe projection>

Required test behavior:
- verify expected state transition,
- verify no duplicate approval/refund is created,
- verify replay is same-attempt only,
- verify UNKNOWN is not treated as final success or final failure,
- verify retry budget is enforced,
- verify DLQ routing is visible and owned,
- verify replay approval is required where applicable,
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
[CURSOR — POS GATEWAY TIMEOUT / RETRY / DLQ / REPLAY DIFF REVIEW]

Review the current diff only.

Do not edit.
Do not auto-fix.
Do not format.
Do not run migrations.
Do not change secrets.
Do not commit.
Do not deploy.

Review against:
- 01090 Overview
- 01100 Logic
- 01110 Module
- 01120 Traceability
- 01130 Handoff Readiness
- allowed file list
- prohibited file list
- restricted register
- retry budget policy
- DLQ owner/SLA
- replay approval policy
- upstream approval/refund dependency
- required tests
- required evidence

Return:
1. changed_files
2. any_unapproved_file_changes
3. related_logic_rules
4. related_trace_ids
5. duplicate_approval_risk
6. duplicate_refund_risk
7. unsafe_replay_risk
8. retry_storm_risk
9. UNKNOWN_projection_risk
10. DLQ_visibility_or_owner_gap
11. audit_mutation_or_gap
12. secret_log_risk
13. missing_tests
14. missing_evidence
15. recommendation: accept / revise / rollback / split
```

---

## 10. Cursor Mode F — Blocker Extraction

Use when Cursor cannot safely implement.

```text
[CURSOR — POS GATEWAY TIMEOUT / RETRY / DLQ / REPLAY BLOCKER EXTRACTION]

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
5. missing upstream approval/refund dependency
6. missing retry budget
7. missing DLQ owner/SLA
8. missing replay approval policy
9. missing test
10. missing evidence
11. missing approval
12. restricted-zone concern
13. recommended next safe action
```

---

## 11. Unsafe Cursor Prompts

Do not use:

```text
Implement retry.
Fix DLQ.
Make replay work.
Replay failed payments.
Retry failed refunds.
Update anything needed.
Refactor retry flow.
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
| Retry Budget Checked? | Yes / No / N/A |
| DLQ Owner/SLA Checked? | Yes / No / N/A |
| Replay Approval Checked? | Yes / No / N/A |
| Upstream Dependency Checked? | Approval / Cancel-Refund / Both / N/A |
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
- [ ] Related Trace ID is specified in 01120.
- [ ] Upstream approval/cancel-refund dependency is known.
- [ ] Retry budget policy is approved or not applicable.
- [ ] DLQ owner/SLA is approved or not applicable.
- [ ] Replay approval policy is approved or not applicable.
- [ ] Test file is known or test gap is explicitly recorded.
- [ ] Evidence target is known.
- [ ] Human approval exists if restricted zone is touched.
- [ ] Prompt includes all absolute prohibitions.

---

## 14. Summary

Cursor may help the POS Gateway Timeout / Retry / DLQ / Replay implementation only as a narrow file-level assistant.

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
broadly implement retry/replay runtime
```

No Cursor task may bypass:

```text
Overview → Logic → Module → File → Test → Evidence
```
