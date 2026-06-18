# 001240_Template_POS_Gateway_Store_Offline_Local_Ledger_Resync_Cursor_IDE_File_Level_Assist_Prompt.md

## 1. Document Control

| Field | Value |
|---|---|
| Project | yoonsul_wait_order_handoff / CatchMenu-Catch&Order |
| Band | 00100_project_foundation |
| Document Type | Template |
| Document Role | POS Gateway Store Offline / Local Ledger / Resync Cursor IDE File-Level Assist Prompt |
| Related Overview | 001180_Spec_Overview_POS_Gateway_Store_Offline_Local_Ledger_And_Resync_Main_Flow.md |
| Related Logic | 001190_Spec_Logic_POS_Gateway_Store_Offline_Local_Ledger_Resync_State_Transition_And_Exception_Rule.md |
| Related Module | 001200_Spec_Module_POS_Gateway_Store_Offline_Local_Ledger_Resync_API_Data_Model_And_Test_Map.md |
| Related Traceability Matrix | 001210_Matrix_POS_Gateway_Store_Offline_Local_Ledger_Resync_Overview_Logic_Module_To_Flow_Bundle_Traceability.md |
| Related Handoff Readiness | 001220_Checklist_POS_Gateway_Store_Offline_Local_Ledger_Resync_Code_Handoff_Readiness.md |
| Related Claude Handoff Prompt | 001230_Template_POS_Gateway_Store_Offline_Local_Ledger_Resync_Claude_Code_Handoff_Prompt.md |
| Related Runtime Flow Bundle | 064130_Flow_POS_Gateway_Store_Offline_Local_Ledger_And_Resync.md |
| Related General Cursor Prompt | 064320_Template_Flow_Bundle_Cursor_IDE_Assist_Prompt.md |
| Related No-AI-Solo Governance | 064370_Governance_Flow_Bundle_Human_Approval_And_No_AI_Solo_Zone_Control.md |
| Status | Draft / Pending Hydration |
| Owner | Architecture / Engineering / QA / Compliance / Operations / Security |
| AI Solo Change | Cursor file-level assist allowed only within approved scope; offline ledger/resync runtime approval prohibited |

---

## 2. Purpose

This template provides Cursor IDE prompts for POS Gateway Store Offline / Local Ledger / Resync work.

Cursor is treated as a file-level assistant, not as a local-ledger or canonical-state owner.

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

Cursor must not be used to implement offline/local-ledger/resync broadly.

---

## 3. Cursor Use Principle

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

If target file, Logic rule, Trace ID, test, offline policy, device trust model, local ledger boundary, hash-chain model, conflict policy, or approval is unknown, Cursor must not perform runtime modification.

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
Do not create duplicate order behavior.
Do not create duplicate approval behavior.
Do not create duplicate refund behavior.
Do not treat local temporary ledger data as canonical financial truth.
Do not mark local pending state as provider-approved payment or completed refund.
Do not bypass device identity trust checks.
Do not bypass local sequence, payload hash, or hash-chain validation.
Do not bypass idempotency checks.
Do not overwrite verified canonical server state.
Do not bypass conflict review approval.
Do not store raw secrets or unmasked payment credentials in local ledger, DLQ, logs, or evidence.
Do not mutate audit history.
Return blockers instead of guessing.
```

---

## 5. Cursor Mode A — File Explanation Only

```text
[CURSOR — POS GATEWAY STORE OFFLINE / LOCAL LEDGER / RESYNC FILE EXPLANATION ONLY]

Explain this file in the context of POS Gateway Store Offline / Local Ledger / Resync.

Do not edit.
Do not apply changes.
Do not format.
Do not run migrations.
Do not change secrets.
Do not commit.

Related docs:
- 001180_Spec_Overview_POS_Gateway_Store_Offline_Local_Ledger_And_Resync_Main_Flow.md
- 001190_Spec_Logic_POS_Gateway_Store_Offline_Local_Ledger_Resync_State_Transition_And_Exception_Rule.md
- 001200_Spec_Module_POS_Gateway_Store_Offline_Local_Ledger_Resync_API_Data_Model_And_Test_Map.md
- 001210_Matrix_POS_Gateway_Store_Offline_Local_Ledger_Resync_Overview_Logic_Module_To_Flow_Bundle_Traceability.md
- 001220_Checklist_POS_Gateway_Store_Offline_Local_Ledger_Resync_Code_Handoff_Readiness.md

Target file:
- <actual file path>

Explain:
1. what this file does
2. which offline/local-ledger/resync module it likely belongs to
3. which Logic rule it may implement
4. which Trace ID it may support
5. whether it touches restricted local ledger, canonical ledger, payment/refund, audit, DB, security, or release behavior
6. whether it depends on approval, cancel/refund, or timeout/retry/DLQ package state
7. whether it depends on offline policy, device trust, local ledger boundary, hash-chain model, or conflict policy
8. candidate tests
9. candidate evidence
10. whether this file is safe for implementation handoff
```

---

## 6. Cursor Mode B — Narrow Documentation Mapping

```text
[CURSOR — POS GATEWAY STORE OFFLINE / LOCAL LEDGER / RESYNC DOC MAPPING ONLY]

Do not edit source code.
Do not edit tests.
Do not run formatters.
Do not run migrations.
Do not change secrets.
Do not commit.

Target file:
- <actual file path>

Map this file to:
- 01200 module row
- 01210 traceability row
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
6. upstream approval/cancel-refund/retry dependency
7. candidate_tests
8. restricted_zone
9. owner_candidate
10. policy_dependency: offline operation / device trust / local ledger boundary / hash-chain / conflict approval / none
11. evidence_target
12. readiness_status
```

---

## 7. Cursor Mode C — Single-File Patch Proposal

Use only after 01220 passes for the target task.

```text
[CURSOR — POS GATEWAY STORE OFFLINE / LOCAL LEDGER / RESYNC SINGLE-FILE PATCH]

Assist with one narrow file-level change.

Do not modify files outside the allowed file.
Do not refactor unrelated code.
Do not run migrations.
Do not change secrets.
Do not commit.
Do not deploy.

Approved documents:
- Overview: 001180_Spec_Overview_POS_Gateway_Store_Offline_Local_Ledger_And_Resync_Main_Flow.md
- Logic: 001190_Spec_Logic_POS_Gateway_Store_Offline_Local_Ledger_Resync_State_Transition_And_Exception_Rule.md
- Module: 001200_Spec_Module_POS_Gateway_Store_Offline_Local_Ledger_Resync_API_Data_Model_And_Test_Map.md
- Traceability: 001210_Matrix_POS_Gateway_Store_Offline_Local_Ledger_Resync_Overview_Logic_Module_To_Flow_Bundle_Traceability.md
- Handoff Readiness: 001220_Checklist_POS_Gateway_Store_Offline_Local_Ledger_Resync_Code_Handoff_Readiness.md

Allowed file:
- <actual file path>

Task:
<single narrow task>

Related Logic Rule:
- <LOGIC-POS-OFLR-Rxxx>

Related Trace ID:
- <POSOFLR-TRACE-xxx>

Policy References:
- Offline operation policy: <reference or N/A>
- Device trust model: <reference or N/A>
- Local ledger boundary: <reference or N/A>
- Hash-chain model: <reference or N/A>
- Conflict approval policy: <reference or N/A>

Required behavior:
- Prevent duplicate order, approval, and refund behavior.
- Do not treat local temporary ledger data as canonical financial truth.
- Do not mark local pending state as provider-approved payment or completed refund.
- Enforce device identity trust checks.
- Enforce local sequence, payload hash, and hash-chain validation.
- Enforce idempotency checks.
- Do not overwrite verified canonical server state.
- Do not bypass conflict review approval.
- Do not store raw secrets or unmasked payment credentials locally or in logs.
- Do not mutate payment/refund/audit history.
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

```text
[CURSOR — POS GATEWAY STORE OFFLINE / LOCAL LEDGER / RESYNC TEST ASSIST]

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
- <LOGIC-POS-OFLR-Rxxx>

Related Trace ID:
- <POSOFLR-TRACE-xxx>

Scenario:
<offline classification / offline policy / device trust / local session / local sequence / payload hash / hash-chain / local idempotency / local masking / snapshot submission / snapshot integrity / record classification / duplicate link / canonical conflict / canonical merge / recovery task / audit / reconciliation / safe projection>

Required test behavior:
- verify expected state transition,
- verify local record is not treated as canonical until resync passes,
- verify duplicate order/payment/refund is not created,
- verify device trust is required,
- verify sequence gap and hash-chain mismatch are blocked,
- verify idempotency is required for mutation-like records,
- verify local pending is not shown as final provider success,
- verify secrets are masked or absent,
- verify conflict review is required where applicable,
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

```text
[CURSOR — POS GATEWAY STORE OFFLINE / LOCAL LEDGER / RESYNC DIFF REVIEW]

Review the current diff only.

Do not edit.
Do not auto-fix.
Do not format.
Do not run migrations.
Do not change secrets.
Do not commit.
Do not deploy.

Review against:
- 01180 Overview
- 01190 Logic
- 01200 Module
- 01210 Traceability
- 01220 Handoff Readiness
- allowed file list
- prohibited file list
- restricted register
- offline operation policy
- device trust model
- local ledger boundary
- hash-chain model
- conflict approval policy
- upstream approval/cancel-refund/retry dependency
- required tests
- required evidence

Return:
1. changed_files
2. any_unapproved_file_changes
3. related_logic_rules
4. related_trace_ids
5. duplicate_order_risk
6. duplicate_approval_risk
7. duplicate_refund_risk
8. local_pending_as_final_risk
9. device_trust_gap
10. sequence_or_hash_chain_gap
11. local_secret_leak_risk
12. canonical_overwrite_risk
13. conflict_approval_gap
14. audit_mutation_or_gap
15. missing_tests
16. missing_evidence
17. recommendation: accept / revise / rollback / split
```

---

## 10. Cursor Mode F — Blocker Extraction

```text
[CURSOR — POS GATEWAY STORE OFFLINE / LOCAL LEDGER / RESYNC BLOCKER EXTRACTION]

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
5. missing upstream approval/cancel-refund/retry dependency
6. missing offline operation policy
7. missing device trust model
8. missing local ledger boundary
9. missing hash-chain model
10. missing conflict approval policy
11. missing test
12. missing evidence
13. missing approval
14. restricted-zone concern
15. recommended next safe action
```

---

## 11. Unsafe Cursor Prompts

Do not use:

```text
Implement offline mode.
Make local ledger work.
Sync offline records.
Merge local records to server.
Fix resync conflicts.
Update anything needed.
Refactor local ledger.
Make tests pass.
Run migrations if needed.
Commit it.
```

These prompts violate file-level scope and restricted-zone controls.

---

## 12. Cursor Handoff Record

| Field | Value |
|---|---|
| Cursor Mode Used | A / B / C / D / E / F |
| Date | YYYY-MM-DD |
| Operator | TBD |
| Target File(s) | TBD |
| Related Logic Rule | TBD |
| Related Trace ID | TBD |
| Offline Policy Checked? | Yes / No / N/A |
| Device Trust Model Checked? | Yes / No / N/A |
| Local Ledger Boundary Checked? | Yes / No / N/A |
| Hash-Chain Model Checked? | Yes / No / N/A |
| Conflict Approval Checked? | Yes / No / N/A |
| Upstream Dependency Checked? | Approval / Cancel-Refund / Retry-DLQ / All / N/A |
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
- [ ] Related Trace ID is specified in 01210.
- [ ] Upstream approval/cancel-refund/retry dependency is known.
- [ ] Offline operation policy is approved or not applicable.
- [ ] Device trust model is approved or not applicable.
- [ ] Local ledger boundary is approved or not applicable.
- [ ] Hash-chain model is approved or not applicable.
- [ ] Conflict approval policy is approved or not applicable.
- [ ] Test file is known or test gap is explicitly recorded.
- [ ] Evidence target is known.
- [ ] Human approval exists if restricted zone is touched.
- [ ] Prompt includes all absolute prohibitions.

---

## 14. Summary

Cursor may help the POS Gateway Store Offline / Local Ledger / Resync implementation only as a narrow file-level assistant.

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
broadly implement offline/resync runtime
```

No Cursor task may bypass:

```text
Overview → Logic → Module → File → Test → Evidence
```
