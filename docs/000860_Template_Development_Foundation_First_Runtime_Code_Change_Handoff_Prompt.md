# 000860_Template_Development_Foundation_First_Runtime_Code_Change_Handoff_Prompt.md

## 1. Document Control

| Field | Value |
|---|---|
| Project | yoonsul_wait_order_handoff / CatchMenu-Catch&Order |
| Band | 00100_project_foundation |
| Document Type | Template |
| Document Role | First Runtime Code Change Handoff Prompt Template |
| Related Closeout | 000790_Index_Development_Foundation_Closeout_And_Runtime_Flow_Linkage.md |
| Related Hydration Guide | 000800_Guide_Development_Foundation_First_Codebase_Hydration_And_Module_Discovery.md |
| Related Implementation Ticket Template | 000810_Template_Development_Foundation_First_Flow_Bundle_Implementation_Ticket.md |
| Related Source Tree Matrix | 000820_Matrix_Development_Foundation_Source_Tree_To_Module_Document_Map.md |
| Related Owner Register | 000830_Register_Development_Foundation_Repository_Module_Owner_Map.md |
| Related Hydration Evidence | 000840_Evidence_Development_Foundation_First_Codebase_Hydration_Report.md |
| Related First Runtime Gate | 000850_Checklist_Development_Foundation_First_Runtime_Code_Change_Gate.md |
| Related AI Prompt Pack | 000740_Template_Development_Foundation_AI_Handoff_Prompt_Pack.md |
| Related Restricted Register | 000750_Register_Development_Foundation_Restricted_File_And_Zone_Control.md |
| Related Runtime Flow Registry | 64000_Index_Runtime_Flow_Bundle_Registry.md |
| Status | Draft |
| Owner | Product / Architecture / Engineering / QA |
| AI Solo Change | Prompt drafting allowed; restricted implementation approval prohibited |

---

## 2. Purpose

This template defines the exact prompt structure for the first runtime code change handoff.

It is used only after the first runtime code change gate is complete.

The prompt must prevent uncontrolled implementation by enforcing:

```text
Overview → Logic → Module → File → Test → Evidence
```

and:

```text
Flow Step → Module → File → Test → Evidence
```

The prompt is intentionally narrow. It must not ask AI to “make the system work” broadly.

---

## 3. Use Conditions

Use this prompt only when:

| Condition | Required |
|---|---:|
| First codebase hydration report exists | Yes |
| Source tree to module map exists | Yes |
| Module owner map exists | Yes |
| Restricted register is checked | Yes |
| Related Flow Bundle is identified | Yes |
| Overview / Logic / Module chain is complete | Yes |
| Allowed files are listed | Yes |
| Prohibited files are listed | Yes |
| Tests are identified | Yes |
| Evidence target is identified | Yes |
| Human approval exists for restricted zone | Required when touched |

If any required item is missing, use read-only inspection or documentation update instead of code change.

---

## 4. Universal First Runtime Code Change Prompt

Copy and fill the following prompt.

```text
[FIRST RUNTIME CODE CHANGE HANDOFF]

You are assisting with yoonsul_wait_order_handoff / CatchMenu-Catch&Order.

This is the first controlled runtime code change handoff.

Critical rule:
Do not treat a single Markdown file as the implementation unit.

Use the approved chain:
Overview → Logic → Module → File → Test → Evidence.

Use the approved Flow Bundle chain:
Flow Step → Module → File → Test → Evidence.

Do not expand scope.
Do not modify files outside the allowed list.
Do not perform broad refactor.
Do not run migrations.
Do not change secrets, tokens, credentials, vault, env, CI/CD, deploy, infra, or production release files.
Do not commit.
Do not deploy.
Return blockers instead of guessing.

## Task
<clear narrow task>

## Related Documents
- Flow Bundle: <filename>
- Overview: <filename>
- Logic: <filename>
- Module: <filename>
- Hydration Report: 000840_Evidence_Development_Foundation_First_Codebase_Hydration_Report.md or actual hydration evidence filename
- Source Tree Map: 000820_Matrix_Development_Foundation_Source_Tree_To_Module_Document_Map.md
- Owner Map: 000830_Register_Development_Foundation_Repository_Module_Owner_Map.md
- First Runtime Gate: 000850_Checklist_Development_Foundation_First_Runtime_Code_Change_Gate.md
- Restricted Register: 000750_Register_Development_Foundation_Restricted_File_And_Zone_Control.md
- AI Change Audit: 000760_Audit_Development_Foundation_AI_Assisted_Change_Control.md
- Exception/Waiver Log: 000770_Register_Development_Foundation_AI_Assisted_Change_Exception_And_Waiver_Log.md

## Allowed Files
- <file path 1>
- <file path 2>

## Prohibited Files / Areas
- any file not listed above
- payment/cancel/refund/settlement/audit/security/DB migration/secret/release areas unless explicitly approved
- unrelated refactor
- formatting-only broad changes
- production config
- migration execution

## Restricted Zone Status
- Restricted zone touched: Yes / No
- Zone code: <RZ-PAY / RZ-SETTLE / RZ-AUDIT / RZ-SEC / RZ-SECRET / RZ-DB / RZ-DEPLOY / RZ-OPS / RZ-PII / RZ-CONTRACT / N/A>
- Human approval included: Yes / No / N/A
- Approval evidence: <filename / ticket / note / N/A>

## Required Implementation Behavior
1. Implement only the approved narrow change.
2. Preserve existing public behavior unless the Logic document explicitly changes it.
3. Preserve idempotency and duplicate protection.
4. Preserve audit/evidence traceability.
5. Do not mark unknown external state as success.
6. Do not mutate existing audit history.
7. Do not log secrets or sensitive payment payloads.
8. Do not introduce migration or release changes.

## Required Tests
- <test file / test type / scenario>
- <test file / test type / scenario>

## Required Output
Return:
1. documents_read
2. allowed_files_confirmed
3. changed_files
4. unchanged_restricted_files
5. tests_added_or_updated
6. tests_run
7. test_results
8. evidence_packet_notes
9. restricted_area_touch_report
10. unresolved_questions
11. merge_risk_summary
```

---

## 5. Claude Code Version

Use this version when Claude Code is the primary implementation agent.

```text
[CLAUDE CODE — FIRST RUNTIME CODE CHANGE]

Act as a Flow Bundle implementation agent, not as a broad project refactor agent.

Before editing:
- Read the listed documents.
- Confirm the allowed files.
- Confirm prohibited files.
- Confirm restricted-zone status.
- Confirm required tests.

During editing:
- Modify only allowed files.
- Keep the diff minimal.
- Do not touch restricted zones unless approval is included.
- Do not run migrations.
- Do not change secrets.
- Do not commit.
- Do not deploy.

After editing:
- Summarize the exact changes.
- List changed files.
- List tests added/updated.
- Report tests run and results.
- Report any restricted-zone touch.
- Report evidence packet notes.
- Report unresolved questions.
```

---

## 6. Cursor Version

Use this version when Cursor is used as a narrow IDE/file-level assistant.

```text
[CURSOR — FIRST RUNTIME CODE CHANGE ASSIST]

Assist only with this narrow file-level task.

Do not expand scope.
Do not infer missing Flow Bundle context.
Do not modify any file not listed.
Do not modify restricted files.
Do not refactor unrelated code.
Do not run migrations.
Do not change secrets.
Do not commit.

Allowed file:
- <file path>

Task:
<single narrow edit>

Context documents:
- Logic: <filename>
- Module: <filename>
- Source tree mapping row: <Map ID>
- First runtime gate: 000850_Checklist_Development_Foundation_First_Runtime_Code_Change_Gate.md

Return:
- minimal diff summary
- whether any unlisted file was touched
- tests affected
- risk note
- unresolved questions
```

---

## 7. Documentation-Only Fallback Prompt

If the first runtime code change gate is not ready, use this instead.

```text
[DOCUMENTATION-ONLY FALLBACK]

Do not modify source code.
Do not modify tests.
Do not modify migrations.
Do not modify secrets.
Do not modify deployment files.

Task:
Update the documentation needed to make the first runtime code change safe.

Missing item:
<Overview / Logic / Module / Source Tree Map / Owner Map / Restricted Register / Test Map / Evidence Packet>

Use the chain:
Overview → Logic → Module → File → Test → Evidence.

Return:
- document updated
- remaining blockers
- whether code handoff is still blocked
```

---

## 8. Read-Only Fallback Prompt

If files are unknown, use this instead.

```text
[READ-ONLY FALLBACK]

Perform read-only inspection only.

Do not modify files.
Do not run formatters.
Do not run migrations.
Do not stage or commit.
Do not deploy.

Goal:
Find the exact files, tests, and restricted zones needed for the first runtime code change.

Return:
- candidate files
- candidate tests
- restricted zones
- missing module documentation
- recommended next step
```

---

## 9. Unsafe Prompt Examples

Do not use:

```text
Read these docs and implement the POS Gateway.
Make the payment flow work.
Fix all related files.
Refactor anything needed.
Update DB and tests as needed.
Deploy after tests pass.
You decide the right behavior.
```

These prompts are rejected because they skip scope, ownership, tests, evidence, and restricted-zone approval.

---

## 10. First Runtime Handoff Completion Record

After the prompt is used, record:

| Field | Value |
|---|---|
| Prompt Used? | Yes / No |
| Tool Used | Claude Code / Cursor / Human / Mixed |
| Related Flow Bundle | TBD |
| Allowed Files | TBD |
| Changed Files | TBD |
| Restricted Zone Touched? | Yes / No |
| Human Approval Evidence | TBD |
| Tests Run | TBD |
| Test Results | TBD |
| Evidence Packet | TBD |
| Merge Risk | Low / Medium / High / Critical |
| Reviewer | TBD |
| Decision | Accept / Revise / Block |

---

## 11. Summary

This template turns the first runtime code change into a controlled handoff.

The handoff must remain narrow, mapped, owned, tested, and evidenced.

The controlling rule remains:

```text
Overview → Logic → Module → File → Test → Evidence
```

No first runtime code change may bypass the source tree map, restricted register, owner map, test plan, evidence packet, or human approval where required.
