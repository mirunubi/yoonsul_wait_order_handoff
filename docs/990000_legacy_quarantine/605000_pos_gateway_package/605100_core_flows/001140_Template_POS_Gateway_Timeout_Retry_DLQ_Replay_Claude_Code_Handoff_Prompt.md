# 001140_Template_POS_Gateway_Timeout_Retry_DLQ_Replay_Claude_Code_Handoff_Prompt.md

## 1. Document Control

| Field | Value |
|---|---|
| Project | yoonsul_wait_order_handoff / CatchMenu-Catch&Order |
| Band | 00100_project_foundation |
| Document Type | Template |
| Document Role | POS Gateway Timeout / Retry / DLQ / Replay Claude Code Handoff Prompt |
| Related Overview | 001090_Spec_Overview_POS_Gateway_Timeout_Retry_DLQ_And_Replay_Main_Flow.md |
| Related Logic | 001100_Spec_Logic_POS_Gateway_Timeout_Retry_DLQ_Replay_State_Transition_And_Exception_Rule.md |
| Related Module | 001110_Spec_Module_POS_Gateway_Timeout_Retry_DLQ_Replay_API_Data_Model_And_Test_Map.md |
| Related Traceability Matrix | 001120_Matrix_POS_Gateway_Timeout_Retry_DLQ_Replay_Overview_Logic_Module_To_Flow_Bundle_Traceability.md |
| Related Handoff Readiness | 001130_Checklist_POS_Gateway_Timeout_Retry_DLQ_Replay_Code_Handoff_Readiness.md |
| Related Approval Claude Prompt | 000960_Template_POS_Gateway_Approval_Claude_Code_Handoff_Prompt.md |
| Related Cancel Refund Claude Prompt | 001050_Template_POS_Gateway_Cancel_Refund_Claude_Code_Handoff_Prompt.md |
| Related Runtime Flow Bundle | 064120_Flow_POS_Gateway_Timeout_Retry_DLQ_And_Replay.md |
| Related Flow Handoff Gate | 064300_Checklist_Flow_Bundle_Code_Handoff_Readiness_Gate.md |
| Related No-AI-Solo Governance | 064370_Governance_Flow_Bundle_Human_Approval_And_No_AI_Solo_Zone_Control.md |
| Status | Draft / Pending Hydration |
| Owner | Architecture / Engineering / QA / Compliance / Operations |
| AI Solo Change | Handoff prompt allowed; runtime retry/replay implementation approval prohibited |

---

## 2. Purpose

This template provides bounded Claude Code prompts for POS Gateway Timeout / Retry / DLQ / Replay work.

It is not a broad implementation command.

The prompt must enforce:

```text
Overview → Logic → Module → File → Test → Evidence
```

and:

```text
Flow Step → Module → File → Test → Evidence
```

The default mode is read-only or documentation mapping until actual source paths, tests, owners, restricted files, retry budgets, DLQ ownership, replay approval policy, upstream dependencies, and human approvals are complete.

---

## 3. Use Modes

| Mode | When To Use | File Modification Allowed? |
|---|---|---:|
| Mode A — Read-Only Hydration | Actual source paths are unknown | No |
| Mode B — Documentation Mapping | Hydration found paths but docs need update | Docs only |
| Mode C — Narrow Runtime Implementation | 01130 passes and approvals exist | Conditional |
| Mode D — Diff Review | Retry/DLQ/replay change already made | No unless explicitly asked |
| Mode E — Rollback Assistance | Duplicate approval/refund, unsafe replay, retry storm, or unapproved diff detected | Conditional, human-approved |

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

## 5. Mode A — Read-Only Hydration Prompt

Use this when actual source paths are unknown.

```text
[POS GATEWAY TIMEOUT / RETRY / DLQ / REPLAY — READ-ONLY HYDRATION]

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
Find the actual source paths, tests, data models, queues, jobs, and restricted files needed to map POS Gateway Timeout / Retry / DLQ / Replay implementation.

Read these documents first:
- 001090_Spec_Overview_POS_Gateway_Timeout_Retry_DLQ_And_Replay_Main_Flow.md
- 001100_Spec_Logic_POS_Gateway_Timeout_Retry_DLQ_Replay_State_Transition_And_Exception_Rule.md
- 001110_Spec_Module_POS_Gateway_Timeout_Retry_DLQ_Replay_API_Data_Model_And_Test_Map.md
- 001120_Matrix_POS_Gateway_Timeout_Retry_DLQ_Replay_Overview_Logic_Module_To_Flow_Bundle_Traceability.md
- 001130_Checklist_POS_Gateway_Timeout_Retry_DLQ_Replay_Code_Handoff_Readiness.md
- 000910_Spec_Overview_POS_Gateway_Approval_Main_Flow.md
- 000920_Spec_Logic_POS_Gateway_Approval_State_Transition_And_Exception_Rule.md
- 000930_Spec_Module_POS_Gateway_Approval_API_Data_Model_And_Test_Map.md
- 001000_Spec_Overview_POS_Gateway_Cancel_Refund_Recovery_Main_Flow.md
- 001010_Spec_Logic_POS_Gateway_Cancel_Refund_State_Transition_And_Exception_Rule.md
- 001020_Spec_Module_POS_Gateway_Cancel_Refund_API_Data_Model_And_Test_Map.md
- 000820_Matrix_Development_Foundation_Source_Tree_To_Module_Document_Map.md
- 000830_Register_Development_Foundation_Repository_Module_Owner_Map.md
- 000750_Register_Development_Foundation_Restricted_File_And_Zone_Control.md
- 064120_Flow_POS_Gateway_Timeout_Retry_DLQ_And_Replay.md

Find candidate files and folders for:
1. timeout classifier
2. ambiguous response classifier
3. retry state and idempotency guard
4. retry budget manager
5. retry scheduler
6. DLQ router
7. DLQ entry repository
8. replay request API boundary
9. replay approval guard
10. replay executor
11. outcome verifier
12. UNKNOWN recovery task service
13. audit append service
14. reconciliation marker service
15. safe status projector
16. tests
17. DB/schema/migration
18. queue/job/event definitions
19. secrets/config/deploy/restricted paths
20. upstream approval/cancel/refund dependency paths

Return only a report with:
- repository path and git status
- candidate source paths
- candidate test paths
- candidate queue/job/event paths
- candidate DB/schema paths
- candidate restricted paths
- upstream dependency paths
- missing documents
- rows to add to 00820
- rows to add to 00830
- rows to add to 00750
- rows to add to 01120
- whether runtime implementation is still blocked
```

---

## 6. Mode B — Documentation Mapping Prompt

Use this after hydration finds paths but before code implementation.

```text
[POS GATEWAY TIMEOUT / RETRY / DLQ / REPLAY — DOCUMENTATION MAPPING ONLY]

Do not modify source code.
Do not modify tests.
Do not run formatters.
Do not run migrations.
Do not change secrets.
Do not stage or commit.
Do not deploy.

Task:
Update or propose updates to the documentation mapping for POS Gateway Timeout / Retry / DLQ / Replay.

Use the chain:
Overview → Logic → Module → File → Test → Evidence.

Documents:
- 001110_Spec_Module_POS_Gateway_Timeout_Retry_DLQ_Replay_API_Data_Model_And_Test_Map.md
- 001120_Matrix_POS_Gateway_Timeout_Retry_DLQ_Replay_Overview_Logic_Module_To_Flow_Bundle_Traceability.md
- 001130_Checklist_POS_Gateway_Timeout_Retry_DLQ_Replay_Code_Handoff_Readiness.md
- 000820_Matrix_Development_Foundation_Source_Tree_To_Module_Document_Map.md
- 000830_Register_Development_Foundation_Repository_Module_Owner_Map.md
- 000750_Register_Development_Foundation_Restricted_File_And_Zone_Control.md

Use the hydration findings:
<paste hydration report or path references>

Return:
1. proposed document rows
2. source path mapping
3. test path mapping
4. queue/job/event mapping
5. DB/schema mapping
6. restricted-zone mapping
7. upstream approval/refund dependency mapping
8. policy gaps: retry budget / DLQ owner / replay approval
9. remaining blockers
10. whether narrow runtime handoff is allowed
```

---

## 7. Mode C — Narrow Runtime Implementation Prompt

Use only if 01130 passes and human approval exists for restricted areas.

```text
[POS GATEWAY TIMEOUT / RETRY / DLQ / REPLAY — NARROW RUNTIME IMPLEMENTATION]

You are implementing one narrow POS Gateway Timeout / Retry / DLQ / Replay change.

This is a restricted financial runtime safety flow.
AI solo implementation approval is prohibited.
Human approval is required for retry/replay of money-moving events, idempotency, payload-hash guard, terminal state guard, DLQ replay, audit, reconciliation, security, DB, secret, and release changes.

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
- Overview: 001090_Spec_Overview_POS_Gateway_Timeout_Retry_DLQ_And_Replay_Main_Flow.md
- Logic: 001100_Spec_Logic_POS_Gateway_Timeout_Retry_DLQ_Replay_State_Transition_And_Exception_Rule.md
- Module: 001110_Spec_Module_POS_Gateway_Timeout_Retry_DLQ_Replay_API_Data_Model_And_Test_Map.md
- Traceability: 001120_Matrix_POS_Gateway_Timeout_Retry_DLQ_Replay_Overview_Logic_Module_To_Flow_Bundle_Traceability.md
- Handoff Readiness: 001130_Checklist_POS_Gateway_Timeout_Retry_DLQ_Replay_Code_Handoff_Readiness.md
- Runtime Flow: 064120_Flow_POS_Gateway_Timeout_Retry_DLQ_And_Replay.md

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

## Required Policies
- Retry budget: <approved policy reference>
- DLQ owner/SLA: <approved policy reference>
- Replay approval policy: <approved policy reference>

## Restricted Zone Status
- Restricted zones touched: <list>
- Human approval evidence: <ticket/document/reference>
- Approval owner: <name/role>

## Required Logic Rules
- <LOGIC-POS-TRDR-Rxxx>
- <LOGIC-POS-TRDR-Rxxx>

## Required Tests
- <test path and scenario>
- <test path and scenario>

## Required Evidence
- <evidence target>
- <review packet target>

## Implementation Rules
1. Do not create duplicate approval behavior.
2. Do not create duplicate refund behavior.
3. Do not replay a money-moving operation as a new independent command.
4. Do not show UNKNOWN as final success or final failure.
5. Do not bypass replay approval.
6. Do not bypass retry budget.
7. Do not bypass DLQ ownership and review.
8. Do not weaken idempotency or payload-hash checks.
9. Do not overwrite payment/refund/audit history.
10. Do not log raw secrets or sensitive payment payloads.
11. Keep the diff minimal.

## Required Output
Return:
1. documents_read
2. allowed_files_confirmed
3. changed_files
4. restricted_zone_touch_report
5. policies_checked
6. logic_rules_implemented
7. tests_added_or_updated
8. tests_run
9. test_results
10. evidence_notes
11. unresolved_blockers
12. merge_risk_summary
```

---

## 8. Mode D — Diff Review Prompt

Use after a change has been made.

```text
[POS GATEWAY TIMEOUT / RETRY / DLQ / REPLAY — DIFF REVIEW ONLY]

Review the current diff only.

Do not modify files.
Do not auto-fix.
Do not format.
Do not run migrations.
Do not change secrets.
Do not commit.
Do not deploy.

Compare the diff against:
- 01090 Overview
- 01100 Logic
- 01110 Module
- 01120 Traceability
- 01130 Handoff Readiness
- allowed file list
- restricted file register
- retry budget policy
- DLQ owner/SLA
- replay approval policy
- upstream approval/refund dependencies
- test requirements
- evidence requirements

Return:
1. changed_files
2. unapproved_changed_files
3. restricted_zone_touched
4. missing_approval
5. policy_mismatch
6. logic_mismatch
7. duplicate_approval_risk
8. duplicate_refund_risk
9. unsafe_replay_risk
10. retry_storm_risk
11. UNKNOWN_projection_risk
12. DLQ_visibility_gap
13. audit_gap
14. reconciliation_gap
15. missing_tests
16. missing_evidence
17. rollback_or_split_recommendation
18. merge_risk_summary
```

---

## 9. Mode E — Rollback Assistance Prompt

Use only with human approval when rollback is needed.

```text
[POS GATEWAY TIMEOUT / RETRY / DLQ / REPLAY — ROLLBACK ASSISTANCE]

Assist with rollback planning for the current diff.

Do not execute destructive commands unless the human owner explicitly approves.
Do not use git reset --hard.
Do not use git clean.
Do not delete untracked files.
Do not remove unrelated user changes.
Do not commit.
Do not deploy.

Goal:
Identify the minimal rollback needed to remove unapproved or unsafe timeout/retry/DLQ/replay changes.

Return:
1. files_to_revert
2. hunks_to_revert
3. files_to_preserve
4. duplicate_approval_or_refund_reason
5. unsafe_replay_reason
6. retry_storm_reason
7. restricted_zone_reason
8. post_rollback_tests
9. post_rollback_evidence
10. residual_risk
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
| Policy References Checked | Retry Budget / DLQ Owner / Replay Approval |
| Approval Evidence | TBD |
| Tests Run | TBD |
| Evidence Updated | TBD |
| Result | Report Only / Docs Updated / Runtime Change / Blocked / Rolled Back |
| Next Action | TBD |

---

## 11. Unsafe Prompt Examples

Reject prompts like:

```text
Implement retry.
Fix DLQ.
Make replay work.
Update all needed files.
Replay failed payments.
Retry failed refunds.
Run migrations if needed.
Commit the fix.
```

These prompts violate scope, restricted-zone, retry budget, replay approval, test, and evidence controls.

---

## 12. Summary

This prompt template allows Claude Code to assist the POS Gateway Timeout / Retry / DLQ / Replay package without causing uncontrolled replay or duplicate money movement.

The safe default is read-only hydration.

Runtime implementation requires:

```text
01090 Overview
01100 Logic
01110 Module
01120 Traceability
01130 Handoff Readiness
actual source paths
actual tests
retry budget policy
DLQ owner/SLA
replay approval policy
restricted approvals
upstream dependency validation
evidence target
```

No Claude Code session may bypass:

```text
Overview → Logic → Module → File → Test → Evidence
```
