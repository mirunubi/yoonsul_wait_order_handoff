# 000740_Template_Development_Foundation_AI_Handoff_Prompt_Pack.md

## 1. Document Control

| Field | Value |
|---|---|
| Project | yoonsul_wait_order_handoff / CatchMenu-Catch&Order |
| Band | 00100_project_foundation |
| Document Type | Template |
| Document Role | AI Handoff Prompt Pack Template |
| Related Policy | 000640_Policy_Development_Foundation_Overview_Logic_Module_Documentation_Model.md |
| Related Registry | 000650_Index_Development_Foundation_Overview_Logic_Module_Registry.md |
| Related Matrix | 000690_Matrix_Development_Foundation_Overview_Logic_Module_Traceability.md |
| Related Checklist | 000700_Checklist_Development_Foundation_Code_Handoff_Readiness.md |
| Related Inspection Runbook | 000710_Runbook_Development_Foundation_Codebase_Read_Only_Inspection.md |
| Related Role Guide | 000730_Guide_Development_Foundation_Claude_Cursor_Role_Separation.md |
| Related Runtime Flow Registry | 64000_Index_Runtime_Flow_Bundle_Registry.md |
| Status | Draft |
| Owner | Product / Architecture / Engineering |
| AI Solo Change | Prompt drafting allowed; restricted implementation approval prohibited |

---

## 2. Purpose

This template provides copy-ready prompt packs for assigning work to Claude Code, Cursor, or another AI-assisted development tool.

The prompt pack enforces the project rule:

```text
Do not implement from one MD file.
Implement from a Flow Bundle and the development foundation chain.
```

Required chain:

```text
Overview → Logic → Module → File → Test → Evidence
```

Required Flow Bundle implementation chain:

```text
Flow Step → Module → File → Test → Evidence
```

---

## 3. Prompt Pack Types

| Prompt Pack | Use Case | Primary Tool |
|---|---|---|
| Pack A | Read-only codebase inspection | Claude Code / Cursor |
| Pack B | Claude Code Flow Bundle implementation | Claude Code |
| Pack C | Cursor narrow IDE/file assist | Cursor |
| Pack D | Diff review and restricted-zone check | Claude Code / Cursor / Human reviewer |
| Pack E | Test and evidence completion | Claude Code / Human QA |
| Pack F | Documentation-only update | ChatGPT / Claude / Cursor |

---

## 4. Universal Safety Header

Paste this at the top of every AI development prompt.

```text
You are assisting with yoonsul_wait_order_handoff / CatchMenu-Catch&Order.

Critical project rule:
Do not treat a single Markdown file as the implementation unit.

Use the approved chain:
Overview → Logic → Module → File → Test → Evidence.

Use the approved Flow Bundle chain:
Flow Step → Module → File → Test → Evidence.

Do not modify payment, cancel, refund, settlement, reconciliation, audit ledger, security, webhook signature, secret, credential, DB migration, production deployment, or release configuration unless explicit human approval is included in this prompt.

Do not expand scope.
Do not modify files outside the approved scope.
Do not run destructive commands.
Do not commit unless explicitly instructed.
Return all uncertainty and blockers instead of guessing.
```

---

## 5. Pack A — Read-Only Codebase Inspection Prompt

Use this when the module/file/test surface is unknown.

```text
[READ-ONLY INSPECTION TASK]

You are performing read-only codebase inspection only.

Do not modify files.
Do not run formatters.
Do not run migrations.
Do not change secrets.
Do not stage or commit.
Do not deploy.
Do not create broad refactors.

Project:
yoonsul_wait_order_handoff / CatchMenu-Catch&Order

Task objective:
<task objective>

Related documents:
- Overview: <filename or TBD>
- Logic: <filename or TBD>
- Module: <filename or TBD>
- Runtime Flow Bundle: <filename or TBD>
- Traceability Matrix: 000690_Matrix_Development_Foundation_Overview_Logic_Module_Traceability.md
- Read-Only Inspection Runbook: 000710_Runbook_Development_Foundation_Codebase_Read_Only_Inspection.md
- Inspection Report Template: 000720_Template_Development_Foundation_Read_Only_Inspection_Report.md

Find and report:
1. candidate modules
2. candidate source files
3. candidate APIs / handlers
4. candidate DB tables / migrations
5. candidate queues / jobs / events
6. candidate tests
7. restricted-zone files
8. missing documents
9. risks and blockers
10. recommended next step

Return using this structure:
- inspection_scope
- repository_state
- candidate_modules
- candidate_files
- candidate_apis
- candidate_tables_or_migrations
- candidate_events_queues_jobs
- candidate_tests
- restricted_zone_findings
- missing_documents
- implementation_risk_notes
- recommended_next_step

Do not produce a code diff.
```

---

## 6. Pack B — Claude Code Flow Bundle Implementation Prompt

Use this only after readiness gates are complete.

```text
[CLAUDE CODE FLOW BUNDLE IMPLEMENTATION TASK]

You are implementing one approved Flow Bundle.

Do not treat a single MD file as the implementation unit.

Use the chain:
Overview → Logic → Module → File → Test → Evidence.

Use the Flow Bundle chain:
Flow Step → Module → File → Test → Evidence.

Project:
yoonsul_wait_order_handoff / CatchMenu-Catch&Order

Flow Bundle:
<641xx or other Flow Bundle filename>

Approved documents to read:
- Overview: <overview filename>
- Logic: <logic filename>
- Module: <module filename>
- Traceability Matrix: <matrix filename>
- Runtime Flow Bundle: <flow bundle filename>
- MD Dependency Graph: <dependency graph filename>
- Module Impact Map: <module map filename>
- Test Coverage Map: <test coverage map filename>
- No-AI-Solo Zone Matrix: <owner/approval matrix filename>
- Code Review Runbook: <runbook filename>
- Evidence Packet Template: <evidence filename>

Allowed scope:
- <module/file/path 1>
- <module/file/path 2>
- <test file/path 1>

Explicitly prohibited scope:
- any file not listed above
- payment/cancel/refund/settlement/audit/security/DB migration/secret/release areas unless explicitly approved below
- broad refactor
- production deployment
- secret changes
- migration execution

Human approval included for restricted zones?
- Yes / No
- Approval record: <filename / ticket / note>

Implementation requirements:
1. Implement only the approved Flow Bundle step(s).
2. Preserve idempotency, auditability, and traceability.
3. Add or update required tests.
4. Do not silently change public contracts.
5. Do not create financial state transitions not defined in the Logic document.
6. Do not mark unknown external state as success.
7. Do not mutate audit ledger history.
8. Do not log secrets or sensitive payment payloads.

Required output:
- summary
- changed_files
- unchanged_restricted_files
- tests_added_or_updated
- tests_run
- test_results
- evidence_packet_notes
- restricted_area_touch_report
- unresolved_questions
- recommended_human_review_items
```

---

## 7. Pack C — Cursor Narrow IDE/File Assist Prompt

Use this when the work is specific and file-scoped.

```text
[CURSOR LIMITED IDE ASSIST TASK]

Assist only with the approved narrow file-level task.

Do not expand scope.
Do not infer missing Flow Bundle context.
Do not modify restricted areas.
Do not refactor unrelated code.
Do not create or edit migrations.
Do not change secrets.
Do not commit.

Project:
yoonsul_wait_order_handoff / CatchMenu-Catch&Order

Approved context:
- Overview: <filename>
- Logic: <filename>
- Module: <filename>
- Related Flow Bundle: <filename>
- Traceability row: <Trace ID>

Allowed file(s):
- <file path>

Restricted files that must not be touched:
- <file path>
- <file path>

Task:
<specific narrow task>

Expected output:
1. minimal diff summary
2. tests affected
3. risk note
4. whether any restricted area was touched
5. unresolved questions

If the task requires additional files or broader context, stop and report the blocker.
```

---

## 8. Pack D — Diff Review And Restricted-Zone Check Prompt

Use this after code changes are produced.

```text
[DIFF REVIEW AND RESTRICTED-ZONE CHECK]

Review the current diff against the approved handoff packet.

Do not modify files unless explicitly asked.
Do not auto-fix.
Do not commit.

Approved documents:
- Flow Bundle: <filename>
- Overview: <filename>
- Logic: <filename>
- Module: <filename>
- Traceability Matrix: <filename>
- Test Coverage Map: <filename>
- No-AI-Solo Zone Matrix: <filename>
- Code Review Runbook: <filename>

Review questions:
1. Are all changed files listed in the approved Module document?
2. Did any restricted-zone file change?
3. Did any payment, settlement, audit, security, DB migration, secret, or release file change without approval?
4. Do changes match the approved Logic rules?
5. Are required tests added or updated?
6. Are public API/schema changes documented?
7. Are audit/evidence requirements preserved?
8. Is any unrelated refactor included?
9. Is there any hidden behavior change?
10. Is the diff safe for human review?

Return:
- approved_scope_match: Yes/No
- changed_files
- unapproved_changed_files
- restricted_zone_touched
- missing_tests
- missing_evidence
- risk_findings
- recommended_action: approve_for_human_review / revise / block
```

---

## 9. Pack E — Test And Evidence Completion Prompt

Use this after implementation when test and evidence must be collected.

```text
[TEST AND EVIDENCE COMPLETION TASK]

Complete test and evidence mapping for the approved Flow Bundle implementation.

Do not modify runtime logic unless explicitly approved.
Do not create fake test results.
Do not claim tests passed unless actually run.
If tests cannot be run, explain why.

Approved documents:
- Flow Bundle: <filename>
- Logic: <filename>
- Module: <filename>
- Test Coverage Map: <filename>
- Evidence Packet: <filename>

Required test categories:
- unit
- integration
- contract
- fault injection
- security
- audit
- migration
- regression

For each category, report:
1. test file
2. scenario covered
3. command used
4. result
5. evidence location
6. missing coverage

Return:
- tests_run
- tests_not_run
- test_results
- coverage_gaps
- evidence_packet_updates
- release_blockers
```

---

## 10. Pack F — Documentation-Only Update Prompt

Use this for safe documentation work.

```text
[DOCUMENTATION-ONLY TASK]

This is a documentation-only task.

Do not modify source code.
Do not modify tests.
Do not modify migrations.
Do not modify secrets.
Do not modify deployment files.
Do not infer runtime behavior beyond the approved documents.

Task:
<documentation task>

Required document rules:
- Use official filename rule: NNNNN_DocumentType_Description.md
- H1 must include the exact full filename with .md
- Keep links to related Flow Bundle and development foundation documents
- Preserve Overview → Logic → Module → File → Test → Evidence chain
- Mark assumptions and open questions explicitly

Return:
- document summary
- created_or_updated_files
- downstream documents affected
- implementation impact: none / possible / confirmed
```

---

## 11. Handoff Packet Assembly Checklist

Before using any implementation prompt, confirm:

| Item | Required | Status |
|---|---:|---|
| Task objective is explicit | Yes | TBD |
| Related Flow Bundle is identified | Yes | TBD |
| Overview document is linked | Yes | TBD |
| Logic document is linked | Yes | TBD |
| Module document or inspection result is linked | Yes | TBD |
| Test Coverage Map is linked | Yes | TBD |
| Evidence target is linked | Yes | TBD |
| Expected changed files are listed | Yes | TBD |
| Restricted files are listed | Yes | TBD |
| Human approval is included when required | Conditional | TBD |
| Output format is specified | Yes | TBD |

---

## 12. Prompt Anti-Patterns

Do not use prompts like these:

```text
Read this MD and implement it.
Fix all related files.
Make the whole system work.
Refactor as needed.
Update the DB and deploy.
You decide the best architecture.
Ignore tests for now.
Just make it pass.
```

These prompts are unsafe because they skip the Flow Bundle and development foundation chain.

---

## 13. Summary

This prompt pack turns AI-assisted coding into a controlled handoff process.

Claude Code should receive Flow Bundle implementation prompts only after readiness is proven.

Cursor should receive narrow IDE/file-assist prompts only after file scope is known.

All implementation remains subordinate to:

```text
Overview → Logic → Module → File → Test → Evidence
```
