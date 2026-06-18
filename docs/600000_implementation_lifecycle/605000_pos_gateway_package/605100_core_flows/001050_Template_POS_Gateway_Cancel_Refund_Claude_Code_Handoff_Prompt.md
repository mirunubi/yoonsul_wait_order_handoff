# 001050_Template_POS_Gateway_Cancel_Refund_Claude_Code_Handoff_Prompt.md

## 1. Document Control

| Field | Value |
|---|---|
| Project | yoonsul_wait_order_handoff / CatchMenu-Catch&Order |
| Band | 00100_project_foundation |
| Document Type | Template |
| Document Role | POS Gateway Cancel / Refund Claude Code Handoff Prompt |
| Related Overview | 001000_Spec_Overview_POS_Gateway_Cancel_Refund_Recovery_Main_Flow.md |
| Related Logic | 001010_Spec_Logic_POS_Gateway_Cancel_Refund_State_Transition_And_Exception_Rule.md |
| Related Module | 001020_Spec_Module_POS_Gateway_Cancel_Refund_API_Data_Model_And_Test_Map.md |
| Related Traceability Matrix | 001030_Matrix_POS_Gateway_Cancel_Refund_Overview_Logic_Module_To_Flow_Bundle_Traceability.md |
| Related Handoff Readiness | 001040_Checklist_POS_Gateway_Cancel_Refund_Code_Handoff_Readiness.md |
| Related Approval Claude Prompt | 000960_Template_POS_Gateway_Approval_Claude_Code_Handoff_Prompt.md |
| Related Runtime Flow Bundle | 064110_Flow_POS_Gateway_Cancel_Refund_Recovery_And_Audit.md |
| Related Flow Handoff Gate | 064300_Checklist_Flow_Bundle_Code_Handoff_Readiness_Gate.md |
| Related No-AI-Solo Governance | 064370_Governance_Flow_Bundle_Human_Approval_And_No_AI_Solo_Zone_Control.md |
| Status | Draft / Pending Hydration |
| Owner | Architecture / Engineering / QA / Compliance |
| AI Solo Change | Handoff prompt allowed; runtime refund implementation approval prohibited |

---

## 2. Purpose

This template provides bounded Claude Code prompts for POS Gateway cancel/refund/recovery work.

It is not a broad implementation command.

The prompt must enforce:

```text
Overview → Logic → Module → File → Test → Evidence
```

and:

```text
Flow Step → Module → File → Test → Evidence
```

The default mode is read-only or documentation mapping until real source paths, tests, owners, restricted files, original approval dependencies, and human approvals are complete.

---

## 3. Use Modes

| Mode | When To Use | File Modification Allowed? |
|---|---|---:|
| Mode A — Read-Only Hydration | Actual source paths are unknown | No |
| Mode B — Documentation Mapping | Hydration found paths but docs need update | Docs only |
| Mode C — Narrow Runtime Implementation | 01040 passes and approvals exist | Conditional |
| Mode D — Diff Review | Cancel/refund change already made | No unless explicitly asked |
| Mode E — Rollback Assistance | Duplicate refund, over-refund, UNKNOWN, or unapproved diff detected | Conditional, human-approved |

If unsure, use Mode A.

---

## 4. Absolute Prohibitions

Every Claude Code prompt must include:

```text
Do not expand scope.
Do not modify files outside the allowed list.
Do not perform broad refactor.
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

## 5. Mode A — Read-Only Hydration Prompt

Use this when actual source paths are unknown.

```text
[POS GATEWAY CANCEL / REFUND — READ-ONLY HYDRATION]

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
Find the actual source paths, tests, data models, and restricted files needed to map POS Gateway Cancel / Refund / Recovery implementation.

Read these documents first:
- 001000_Spec_Overview_POS_Gateway_Cancel_Refund_Recovery_Main_Flow.md
- 001010_Spec_Logic_POS_Gateway_Cancel_Refund_State_Transition_And_Exception_Rule.md
- 001020_Spec_Module_POS_Gateway_Cancel_Refund_API_Data_Model_And_Test_Map.md
- 001030_Matrix_POS_Gateway_Cancel_Refund_Overview_Logic_Module_To_Flow_Bundle_Traceability.md
- 001040_Checklist_POS_Gateway_Cancel_Refund_Code_Handoff_Readiness.md
- 000910_Spec_Overview_POS_Gateway_Approval_Main_Flow.md
- 000920_Spec_Logic_POS_Gateway_Approval_State_Transition_And_Exception_Rule.md
- 000930_Spec_Module_POS_Gateway_Approval_API_Data_Model_And_Test_Map.md
- 000820_Matrix_Development_Foundation_Source_Tree_To_Module_Document_Map.md
- 000830_Register_Development_Foundation_Repository_Module_Owner_Map.md
- 000750_Register_Development_Foundation_Restricted_File_And_Zone_Control.md
- 064110_Flow_POS_Gateway_Cancel_Refund_Recovery_And_Audit.md

Find candidate files and folders for:
1. cancel/refund API boundary
2. original payment validator
3. refund policy and authority guard
4. refundable amount guard
5. cancel/refund attempt ledger
6. cancel/refund idempotency guard
7. provider cancel/refund adapter
8. provider response normalizer
9. refund audit append service
10. reconciliation/dispute marker service
11. recovery task service
12. safe status projector
13. tests
14. DB/schema/migration
15. secrets/config/deploy/restricted paths

Return only a report with:
- repository path and git status
- candidate source paths
- candidate test paths
- candidate restricted paths
- original approval dependency paths
- missing documents
- rows to add to 00820
- rows to add to 00830
- rows to add to 00750
- rows to add to 01030
- whether runtime implementation is still blocked
```

---

## 6. Mode B — Documentation Mapping Prompt

Use this after hydration finds paths but before code implementation.

```text
[POS GATEWAY CANCEL / REFUND — DOCUMENTATION MAPPING ONLY]

Do not modify source code.
Do not modify tests.
Do not run formatters.
Do not run migrations.
Do not change secrets.
Do not stage or commit.
Do not deploy.

Task:
Update or propose updates to the documentation mapping for POS Gateway Cancel / Refund / Recovery.

Use the chain:
Overview → Logic → Module → File → Test → Evidence.

Documents:
- 001020_Spec_Module_POS_Gateway_Cancel_Refund_API_Data_Model_And_Test_Map.md
- 001030_Matrix_POS_Gateway_Cancel_Refund_Overview_Logic_Module_To_Flow_Bundle_Traceability.md
- 001040_Checklist_POS_Gateway_Cancel_Refund_Code_Handoff_Readiness.md
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
5. original approval dependency mapping
6. remaining blockers
7. whether narrow runtime handoff is allowed
```

---

## 7. Mode C — Narrow Runtime Implementation Prompt

Use only if 01040 passes and human approval exists for restricted areas.

```text
[POS GATEWAY CANCEL / REFUND — NARROW RUNTIME IMPLEMENTATION]

You are implementing one narrow POS Gateway Cancel / Refund / Recovery change.

This is a restricted financial reversal flow.
AI solo implementation approval is prohibited.
Human approval is required for cancel/refund, amount guard, idempotency, provider adapter, refund ledger, audit, reconciliation/dispute, security, DB, secret, and release changes.

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
- Overview: 001000_Spec_Overview_POS_Gateway_Cancel_Refund_Recovery_Main_Flow.md
- Logic: 001010_Spec_Logic_POS_Gateway_Cancel_Refund_State_Transition_And_Exception_Rule.md
- Module: 001020_Spec_Module_POS_Gateway_Cancel_Refund_API_Data_Model_And_Test_Map.md
- Traceability: 001030_Matrix_POS_Gateway_Cancel_Refund_Overview_Logic_Module_To_Flow_Bundle_Traceability.md
- Handoff Readiness: 001040_Checklist_POS_Gateway_Cancel_Refund_Code_Handoff_Readiness.md
- Runtime Flow: 064110_Flow_POS_Gateway_Cancel_Refund_Recovery_And_Audit.md

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
- <LOGIC-POS-CREF-Rxxx>
- <LOGIC-POS-CREF-Rxxx>

## Required Tests
- <test path and scenario>
- <test path and scenario>

## Required Evidence
- <evidence target>
- <review packet target>

## Implementation Rules
1. Do not create duplicate refund behavior.
2. Do not allow refund greater than remaining refundable amount.
3. Do not mark UNKNOWN external provider state as Cancelled or Refunded.
4. Do not bypass manager/policy approval.
5. Do not overwrite refund/payment/audit history.
6. Do not log raw secrets or sensitive payment payloads.
7. Preserve idempotency semantics.
8. Preserve audit append requirement.
9. Preserve reconciliation/dispute readiness rule.
10. Keep the diff minimal.

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
[POS GATEWAY CANCEL / REFUND — DIFF REVIEW ONLY]

Review the current diff only.

Do not modify files.
Do not auto-fix.
Do not format.
Do not run migrations.
Do not change secrets.
Do not commit.
Do not deploy.

Compare the diff against:
- 01000 Overview
- 01010 Logic
- 01020 Module
- 01030 Traceability
- 01040 Handoff Readiness
- allowed file list
- restricted file register
- original approval dependency
- test requirements
- evidence requirements

Return:
1. changed_files
2. unapproved_changed_files
3. restricted_zone_touched
4. missing_approval
5. logic_mismatch
6. duplicate_refund_risk
7. over_refund_risk
8. UNKNOWN_state_risk
9. audit_gap
10. reconciliation_or_dispute_gap
11. missing_tests
12. missing_evidence
13. rollback_or_split_recommendation
14. merge_risk_summary
```

---

## 9. Mode E — Rollback Assistance Prompt

Use only with human approval when rollback is needed.

```text
[POS GATEWAY CANCEL / REFUND — ROLLBACK ASSISTANCE]

Assist with rollback planning for the current diff.

Do not execute destructive commands unless the human owner explicitly approves.
Do not use git reset --hard.
Do not use git clean.
Do not delete untracked files.
Do not remove unrelated user changes.
Do not commit.
Do not deploy.

Goal:
Identify the minimal rollback needed to remove unapproved or unsafe cancel/refund changes.

Return:
1. files_to_revert
2. hunks_to_revert
3. files_to_preserve
4. duplicate_refund_or_over_refund_reason
5. restricted_zone_reason
6. post_rollback_tests
7. post_rollback_evidence
8. residual_risk
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
Implement refund.
Fix cancel/refund flow.
Update all needed files.
Make refunds work.
Allow partial refund.
Run migrations if needed.
Commit the fix.
```

These prompts violate scope, restricted-zone, test, evidence, and duplicate-refund controls.

---

## 12. Summary

This prompt template allows Claude Code to assist the POS Gateway Cancel / Refund / Recovery package without breaking financial control.

The safe default is read-only hydration.

Runtime implementation requires:

```text
01000 Overview
01010 Logic
01020 Module
01030 Traceability
01040 Handoff Readiness
actual source paths
actual tests
restricted approvals
original approval dependency validation
evidence target
```

No Claude Code session may bypass:

```text
Overview → Logic → Module → File → Test → Evidence
```
