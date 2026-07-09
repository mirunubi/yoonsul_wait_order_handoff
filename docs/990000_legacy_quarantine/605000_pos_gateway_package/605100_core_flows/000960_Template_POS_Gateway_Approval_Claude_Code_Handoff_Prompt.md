# 000960_Template_POS_Gateway_Approval_Claude_Code_Handoff_Prompt.md

## 1. Document Control

| Field | Value |
|---|---|
| Project | yoonsul_wait_order_handoff / CatchMenu-Catch&Order |
| Band | 00100_project_foundation |
| Document Type | Template |
| Document Role | POS Gateway Approval Claude Code Handoff Prompt |
| Related Overview | 000910_Spec_Overview_POS_Gateway_Approval_Main_Flow.md |
| Related Logic | 000920_Spec_Logic_POS_Gateway_Approval_State_Transition_And_Exception_Rule.md |
| Related Module | 000930_Spec_Module_POS_Gateway_Approval_API_Data_Model_And_Test_Map.md |
| Related Traceability Matrix | 000940_Matrix_POS_Gateway_Approval_Overview_Logic_Module_To_Flow_Bundle_Traceability.md |
| Related Handoff Readiness | 000950_Checklist_POS_Gateway_Approval_Code_Handoff_Readiness.md |
| Related General Handoff Prompt | 000860_Template_Development_Foundation_First_Runtime_Code_Change_Handoff_Prompt.md |
| Related Runtime Flow Bundle | 064100_Flow_POS_Gateway_Approval_To_Audit_Ledger_And_Reconciliation.md |
| Related Flow Handoff Gate | 064300_Checklist_Flow_Bundle_Code_Handoff_Readiness_Gate.md |
| Related No-AI-Solo Governance | 064370_Governance_Flow_Bundle_Human_Approval_And_No_AI_Solo_Zone_Control.md |
| Status | Draft / Pending Hydration |
| Owner | Architecture / Engineering / QA / Compliance |
| AI Solo Change | Handoff prompt allowed; runtime implementation approval prohibited |

---

## 2. Purpose

This template provides a bounded Claude Code prompt for POS Gateway Approval work.

It is not a blanket implementation command.

The prompt must enforce:

```text
Overview → Logic → Module → File → Test → Evidence
```

and:

```text
Flow Step → Module → File → Test → Evidence
```

The default mode is read-only or documentation mapping until real source paths, tests, owners, restricted files, and approvals are complete.

---

## 3. Use Modes

| Mode | When To Use | File Modification Allowed? |
|---|---|---:|
| Mode A — Read-Only Hydration | Actual source paths are unknown | No |
| Mode B — Documentation Mapping | Hydration found paths but docs need update | Docs only |
| Mode C — Narrow Runtime Implementation | 00950 passes and approvals exist | Conditional |
| Mode D — Diff Review | Runtime change already made | No unless explicitly asked |
| Mode E — Rollback Assistance | Unapproved or unsafe diff detected | Conditional, human-approved |

If unsure, use Mode A.

---

## 4. Absolute Prohibitions

The Claude Code prompt must always include:

```text
Do not expand scope.
Do not modify files outside the allowed list.
Do not perform broad refactor.
Do not run migrations.
Do not change secrets, tokens, credentials, vault, env, CI/CD, deploy, infra, or production release files.
Do not commit.
Do not deploy.
Do not mark UNKNOWN provider state as success.
Do not create duplicate payment approval behavior.
Do not mutate audit history.
Return blockers instead of guessing.
```

---

## 5. Mode A — Read-Only Hydration Prompt

Use this when actual source paths are unknown.

```text
[POS GATEWAY APPROVAL — READ-ONLY HYDRATION]

You are assisting with yoonsul_wait_order_handoff / CatchMenu-Catch&Order.

Operate in read-only mode.

Do not modify files.
Do not run formatters.
Do not run migrations.
Do not install packages.
Do not change secrets.
Do not stage or commit.
Do not deploy.
Do not run destructive commands.

Goal:
Find the actual source paths, tests, data models, and restricted files needed to map POS Gateway Approval implementation.

Read these documents first:
- 000910_Spec_Overview_POS_Gateway_Approval_Main_Flow.md
- 000920_Spec_Logic_POS_Gateway_Approval_State_Transition_And_Exception_Rule.md
- 000930_Spec_Module_POS_Gateway_Approval_API_Data_Model_And_Test_Map.md
- 000940_Matrix_POS_Gateway_Approval_Overview_Logic_Module_To_Flow_Bundle_Traceability.md
- 000950_Checklist_POS_Gateway_Approval_Code_Handoff_Readiness.md
- 000820_Matrix_Development_Foundation_Source_Tree_To_Module_Document_Map.md
- 000830_Register_Development_Foundation_Repository_Module_Owner_Map.md
- 000750_Register_Development_Foundation_Restricted_File_And_Zone_Control.md
- 064100_Flow_POS_Gateway_Approval_To_Audit_Ledger_And_Reconciliation.md

Find candidate files and folders for:
1. approval API boundary
2. approval validation
3. payment attempt ledger
4. idempotency guard
5. provider approval adapter
6. provider response normalizer
7. audit append service
8. reconciliation marker service
9. recovery task service
10. status projection
11. tests
12. DB/schema/migration
13. secrets/config/deploy/restricted paths

Return only a report with:
- repository path and git status
- candidate source paths
- candidate test paths
- candidate restricted paths
- missing documents
- rows to add to 00820
- rows to add to 00830
- rows to add to 00750
- rows to add to 00940
- whether runtime implementation is still blocked
```

---

## 6. Mode B — Documentation Mapping Prompt

Use this after hydration finds paths but before code implementation.

```text
[POS GATEWAY APPROVAL — DOCUMENTATION MAPPING ONLY]

Do not modify source code.
Do not modify tests.
Do not run migrations.
Do not change secrets.
Do not stage or commit.
Do not deploy.

Task:
Update or propose updates to the documentation mapping for POS Gateway Approval.

Use the chain:
Overview → Logic → Module → File → Test → Evidence.

Documents:
- 000930_Spec_Module_POS_Gateway_Approval_API_Data_Model_And_Test_Map.md
- 000940_Matrix_POS_Gateway_Approval_Overview_Logic_Module_To_Flow_Bundle_Traceability.md
- 000950_Checklist_POS_Gateway_Approval_Code_Handoff_Readiness.md
- 000820_Matrix_Development_Foundation_Source_Tree_To_Module_Document_Map.md
- 000830_Register_Development_Foundation_Repository_Module_Owner_Map.md
- 000750_Register_Development_Foundation_Restricted_File_And_Zone_Control.md

Use the hydration findings:
<paste hydration report or path references>

Return:
1. proposed document rows
2. source path mapping
3. test path mapping
4. restricted-zone mapping
5. remaining blockers
6. whether narrow runtime handoff is allowed
```

---

## 7. Mode C — Narrow Runtime Implementation Prompt

Use only if 00950 passes and human approval exists for restricted areas.

```text
[POS GATEWAY APPROVAL — NARROW RUNTIME IMPLEMENTATION]

You are implementing one narrow POS Gateway Approval change.

This is a restricted financial/audit flow.
AI solo implementation approval is prohibited.
Human approval is required for payment, idempotency, provider adapter, ledger, audit, reconciliation, security, DB, secret, and release changes.

Do not expand scope.
Do not modify files outside the allowed list.
Do not perform broad refactor.
Do not run migrations.
Do not change secrets, tokens, credentials, vault, env, CI/CD, deploy, infra, or production release files.
Do not commit.
Do not deploy.
Return blockers instead of guessing.

## Task
<single narrow implementation task>

## Approved Documents
- Overview: 000910_Spec_Overview_POS_Gateway_Approval_Main_Flow.md
- Logic: 000920_Spec_Logic_POS_Gateway_Approval_State_Transition_And_Exception_Rule.md
- Module: 000930_Spec_Module_POS_Gateway_Approval_API_Data_Model_And_Test_Map.md
- Traceability: 000940_Matrix_POS_Gateway_Approval_Overview_Logic_Module_To_Flow_Bundle_Traceability.md
- Handoff readiness: 000950_Checklist_POS_Gateway_Approval_Code_Handoff_Readiness.md
- Runtime Flow: 064100_Flow_POS_Gateway_Approval_To_Audit_Ledger_And_Reconciliation.md

## Allowed Files
- <actual file path 1>
- <actual file path 2>

## Prohibited Files / Areas
- Any file not listed above
- Secrets, credentials, env, vault
- Migration execution
- Deployment/release/CI changes
- Unrelated refactor
- Formatting-only broad changes

## Restricted Zone Status
- Restricted zones touched: <list>
- Human approval evidence: <ticket/document/reference>
- Approval owner: <name/role>

## Required Logic Rules
- <LOGIC-POS-APP-Rxxx>
- <LOGIC-POS-APP-Rxxx>

## Required Tests
- <test path and scenario>
- <test path and scenario>

## Required Evidence
- <evidence target>
- <review packet target>

## Implementation Rules
1. Do not mark UNKNOWN external provider state as Approved.
2. Do not retry provider approval in a way that can create duplicate charge.
3. Do not overwrite payment/audit history.
4. Do not log raw secrets or sensitive payment payloads.
5. Preserve idempotency semantics.
6. Preserve audit append requirement.
7. Preserve reconciliation readiness rule.
8. Keep the diff minimal.

## Required Output
Return:
1. documents_read
2. allowed_files_confirmed
3. changed_files
4. restricted_zone_touch_report
5. logic_rules_implemented
6. tests_added_or_updated
7. tests_run
8. test_results
9. evidence_notes
10. unresolved_blockers
11. merge_risk_summary
```

---

## 8. Mode D — Diff Review Prompt

Use after a change has been made.

```text
[POS GATEWAY APPROVAL — DIFF REVIEW ONLY]

Review the current diff only.

Do not modify files.
Do not auto-fix.
Do not format.
Do not run migrations.
Do not change secrets.
Do not commit.
Do not deploy.

Compare the diff against:
- 00910 Overview
- 00920 Logic
- 00930 Module
- 00940 Traceability
- 00950 Handoff Readiness
- allowed file list
- restricted file register
- test requirements
- evidence requirements

Return:
1. changed_files
2. unapproved_changed_files
3. restricted_zone_touched
4. missing_approval
5. logic_mismatch
6. idempotency_risk
7. UNKNOWN_state_risk
8. audit_gap
9. reconciliation_gap
10. missing_tests
11. missing_evidence
12. rollback_or_split_recommendation
13. merge_risk_summary
```

---

## 9. Mode E — Rollback Assistance Prompt

Use only with human approval when rollback is needed.

```text
[POS GATEWAY APPROVAL — ROLLBACK ASSISTANCE]

Assist with rollback planning for the current diff.

Do not execute destructive commands unless the human owner explicitly approves.
Do not use git reset --hard.
Do not use git clean.
Do not delete untracked files.
Do not remove unrelated user changes.
Do not commit.
Do not deploy.

Goal:
Identify the minimal rollback needed to remove unapproved or unsafe POS Gateway Approval changes.

Return:
1. files_to_revert
2. hunks_to_revert
3. files_to_preserve
4. restricted_zone_reason
5. post_rollback_tests
6. post_rollback_evidence
7. residual_risk
```

---

## 10. Handoff Completion Record

After any Claude Code session, record:

| Field | Value |
|---|---|
| Mode Used | A / B / C / D / E |
| Date | YYYY-MM-DD |
| Operator | TBD |
| Claude Code Prompt Location | TBD |
| Documents Read | TBD |
| Files Inspected | TBD |
| Files Changed | TBD |
| Restricted Zone Touched | Yes / No |
| Approval Evidence | TBD |
| Tests Run | TBD |
| Evidence Updated | TBD |
| Result | Report Only / Docs Updated / Runtime Change / Blocked / Rolled Back |
| Next Action | TBD |

---

## 11. Unsafe Prompt Examples

Reject prompts like:

```text
Implement POS Gateway approval.
Fix the payment flow.
Update all needed files.
Refactor payment module.
Make tests pass.
Run migrations if needed.
Deploy after success.
```

These prompts violate scope, restricted-zone, test, and evidence controls.

---

## 12. Summary

This prompt template allows Claude Code to assist the POS Gateway Approval package without breaking the project control model.

The safe default is read-only hydration.

Runtime implementation requires:

```text
00910 Overview
00920 Logic
00930 Module
00940 Traceability
00950 Handoff Readiness
actual source paths
actual tests
restricted approvals
evidence target
```

No Claude Code session may bypass:

```text
Overview → Logic → Module → File → Test → Evidence
```
