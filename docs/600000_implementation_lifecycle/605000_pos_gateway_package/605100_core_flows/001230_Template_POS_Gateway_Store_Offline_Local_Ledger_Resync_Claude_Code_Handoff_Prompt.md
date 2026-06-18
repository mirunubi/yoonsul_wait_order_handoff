# 001230_Template_POS_Gateway_Store_Offline_Local_Ledger_Resync_Claude_Code_Handoff_Prompt.md

## 1. Document Control

| Field | Value |
|---|---|
| Project | yoonsul_wait_order_handoff / CatchMenu-Catch&Order |
| Band | 00100_project_foundation |
| Document Type | Template |
| Document Role | POS Gateway Store Offline / Local Ledger / Resync Claude Code Handoff Prompt |
| Related Overview | 001180_Spec_Overview_POS_Gateway_Store_Offline_Local_Ledger_And_Resync_Main_Flow.md |
| Related Logic | 001190_Spec_Logic_POS_Gateway_Store_Offline_Local_Ledger_Resync_State_Transition_And_Exception_Rule.md |
| Related Module | 001200_Spec_Module_POS_Gateway_Store_Offline_Local_Ledger_Resync_API_Data_Model_And_Test_Map.md |
| Related Traceability Matrix | 001210_Matrix_POS_Gateway_Store_Offline_Local_Ledger_Resync_Overview_Logic_Module_To_Flow_Bundle_Traceability.md |
| Related Handoff Readiness | 001220_Checklist_POS_Gateway_Store_Offline_Local_Ledger_Resync_Code_Handoff_Readiness.md |
| Related Runtime Flow Bundle | 064130_Flow_POS_Gateway_Store_Offline_Local_Ledger_And_Resync.md |
| Related Flow Handoff Gate | 064300_Checklist_Flow_Bundle_Code_Handoff_Readiness_Gate.md |
| Related No-AI-Solo Governance | 064370_Governance_Flow_Bundle_Human_Approval_And_No_AI_Solo_Zone_Control.md |
| Status | Draft / Pending Hydration |
| Owner | Architecture / Engineering / QA / Compliance / Operations / Security |
| AI Solo Change | Handoff prompt allowed; offline ledger/resync/canonical merge implementation approval prohibited |

---

## 2. Purpose

This template provides bounded Claude Code prompts for POS Gateway Store Offline / Local Ledger / Resync work.

It is not a broad implementation command.

The prompt must enforce:

```text
Overview → Logic → Module → File → Test → Evidence
```

and:

```text
Flow Step → Module → File → Test → Evidence
```

The default mode is read-only or documentation mapping until actual source paths, tests, owners, restricted files, offline policy, device trust, local ledger boundary, hash-chain model, conflict policy, upstream dependencies, and human approvals are complete.

---

## 3. Use Modes

| Mode | When To Use | File Modification Allowed? |
|---|---|---:|
| Mode A — Read-Only Hydration | Actual source paths are unknown | No |
| Mode B — Documentation Mapping | Hydration found paths but docs need update | Docs only |
| Mode C — Narrow Runtime Implementation | 01220 passes and approvals exist | Conditional |
| Mode D — Diff Review | Offline/resync change already made | No unless explicitly asked |
| Mode E — Rollback Assistance | Duplicate, tamper, unsafe merge, unapproved diff, or local-secret leak detected | Conditional, human-approved |

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

## 5. Mode A — Read-Only Hydration Prompt

Use this when actual source paths are unknown.

```text
[POS GATEWAY STORE OFFLINE / LOCAL LEDGER / RESYNC — READ-ONLY HYDRATION]

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
Find the actual source paths, tests, data models, queues, jobs, local storage boundaries, and restricted files needed to map POS Gateway Store Offline / Local Ledger / Resync implementation.

Read these documents first:
- 001180_Spec_Overview_POS_Gateway_Store_Offline_Local_Ledger_And_Resync_Main_Flow.md
- 001190_Spec_Logic_POS_Gateway_Store_Offline_Local_Ledger_Resync_State_Transition_And_Exception_Rule.md
- 001200_Spec_Module_POS_Gateway_Store_Offline_Local_Ledger_Resync_API_Data_Model_And_Test_Map.md
- 001210_Matrix_POS_Gateway_Store_Offline_Local_Ledger_Resync_Overview_Logic_Module_To_Flow_Bundle_Traceability.md
- 001220_Checklist_POS_Gateway_Store_Offline_Local_Ledger_Resync_Code_Handoff_Readiness.md
- 000910_Spec_Overview_POS_Gateway_Approval_Main_Flow.md
- 000920_Spec_Logic_POS_Gateway_Approval_State_Transition_And_Exception_Rule.md
- 000930_Spec_Module_POS_Gateway_Approval_API_Data_Model_And_Test_Map.md
- 001000_Spec_Overview_POS_Gateway_Cancel_Refund_Recovery_Main_Flow.md
- 001010_Spec_Logic_POS_Gateway_Cancel_Refund_State_Transition_And_Exception_Rule.md
- 001020_Spec_Module_POS_Gateway_Cancel_Refund_API_Data_Model_And_Test_Map.md
- 001100_Spec_Logic_POS_Gateway_Timeout_Retry_DLQ_Replay_State_Transition_And_Exception_Rule.md
- 000820_Matrix_Development_Foundation_Source_Tree_To_Module_Document_Map.md
- 000830_Register_Development_Foundation_Repository_Module_Owner_Map.md
- 000750_Register_Development_Foundation_Restricted_File_And_Zone_Control.md
- 064130_Flow_POS_Gateway_Store_Offline_Local_Ledger_And_Resync.md

Find candidate files and folders for:
1. offline condition classifier
2. offline policy guard
3. device identity guard
4. local ledger session manager
5. local sequence manager
6. local payload hash service
7. local hash-chain service
8. local idempotency guard
9. local secret masking guard
10. local status projection guard
11. resync snapshot API boundary
12. resync integrity verifier
13. local record classifier
14. duplicate detector
15. conflict resolver
16. canonical merge service
17. recovery task service
18. offline/resync audit append service
19. reconciliation marker service
20. safe status projector
21. tests
22. DB/schema/migration
23. local storage paths
24. queue/job/event definitions
25. secrets/config/deploy/restricted paths
26. upstream approval/cancel/refund/retry dependency paths

Return only a report with:
- repository path and git status
- candidate source paths
- candidate test paths
- candidate local storage paths
- candidate queue/job/event paths
- candidate DB/schema paths
- candidate restricted paths
- upstream dependency paths
- missing documents
- rows to add to 00820
- rows to add to 00830
- rows to add to 00750
- rows to add to 01210
- policy gaps: offline operation / device trust / local ledger boundary / hash-chain / conflict approval
- whether runtime implementation is still blocked
```

---

## 6. Mode B — Documentation Mapping Prompt

Use this after hydration finds paths but before code implementation.

```text
[POS GATEWAY STORE OFFLINE / LOCAL LEDGER / RESYNC — DOCUMENTATION MAPPING ONLY]

Do not modify source code.
Do not modify tests.
Do not run formatters.
Do not run migrations.
Do not change secrets.
Do not stage or commit.
Do not deploy.

Task:
Update or propose updates to the documentation mapping for POS Gateway Store Offline / Local Ledger / Resync.

Use the chain:
Overview → Logic → Module → File → Test → Evidence.

Documents:
- 001200_Spec_Module_POS_Gateway_Store_Offline_Local_Ledger_Resync_API_Data_Model_And_Test_Map.md
- 001210_Matrix_POS_Gateway_Store_Offline_Local_Ledger_Resync_Overview_Logic_Module_To_Flow_Bundle_Traceability.md
- 001220_Checklist_POS_Gateway_Store_Offline_Local_Ledger_Resync_Code_Handoff_Readiness.md
- 000820_Matrix_Development_Foundation_Source_Tree_To_Module_Document_Map.md
- 000830_Register_Development_Foundation_Repository_Module_Owner_Map.md
- 000750_Register_Development_Foundation_Restricted_File_And_Zone_Control.md

Use the hydration findings:
<paste hydration report or path references>

Return:
1. proposed document rows
2. source path mapping
3. test path mapping
4. local storage mapping
5. queue/job/event mapping
6. DB/schema mapping
7. restricted-zone mapping
8. upstream approval/cancel-refund/retry dependency mapping
9. policy gaps: offline operation / device trust / local ledger boundary / hash-chain / conflict approval
10. remaining blockers
11. whether narrow runtime handoff is allowed
```

---

## 7. Mode C — Narrow Runtime Implementation Prompt

Use only if 01220 passes and human approval exists for restricted areas.

```text
[POS GATEWAY STORE OFFLINE / LOCAL LEDGER / RESYNC — NARROW RUNTIME IMPLEMENTATION]

You are implementing one narrow POS Gateway Store Offline / Local Ledger / Resync change.

This is a restricted local-ledger and canonical-state safety flow.
AI solo implementation approval is prohibited.
Human approval is required for local ledger integrity, device trust, resync, canonical merge, conflict resolution, duplicate prevention, audit, reconciliation, security, DB, secret, and release changes.

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
- Overview: 001180_Spec_Overview_POS_Gateway_Store_Offline_Local_Ledger_And_Resync_Main_Flow.md
- Logic: 001190_Spec_Logic_POS_Gateway_Store_Offline_Local_Ledger_Resync_State_Transition_And_Exception_Rule.md
- Module: 001200_Spec_Module_POS_Gateway_Store_Offline_Local_Ledger_Resync_API_Data_Model_And_Test_Map.md
- Traceability: 001210_Matrix_POS_Gateway_Store_Offline_Local_Ledger_Resync_Overview_Logic_Module_To_Flow_Bundle_Traceability.md
- Handoff Readiness: 001220_Checklist_POS_Gateway_Store_Offline_Local_Ledger_Resync_Code_Handoff_Readiness.md
- Runtime Flow: 064130_Flow_POS_Gateway_Store_Offline_Local_Ledger_And_Resync.md

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
- Offline allowed/prohibited operation policy: <approved policy reference>
- Device identity trust model: <approved policy reference>
- Local ledger storage boundary: <approved policy reference>
- Local payload allowlist/denylist: <approved policy reference>
- Local hash-chain model: <approved policy reference>
- Resync conflict policy: <approved policy reference>
- Conflict approver role: <approved policy reference>

## Restricted Zone Status
- Restricted zones touched: <list>
- Human approval evidence: <ticket/document/reference>
- Approval owner: <name/role>

## Required Logic Rules
- <LOGIC-POS-OFLR-Rxxx>
- <LOGIC-POS-OFLR-Rxxx>

## Required Tests
- <test path and scenario>
- <test path and scenario>

## Required Evidence
- <evidence target>
- <review packet target>

## Implementation Rules
1. Do not create duplicate order, approval, or refund behavior.
2. Do not treat local temporary ledger data as canonical financial truth.
3. Do not mark local pending state as provider-approved payment or completed refund.
4. Do not bypass device identity trust checks.
5. Do not bypass local sequence, payload hash, or hash-chain validation.
6. Do not bypass idempotency checks.
7. Do not overwrite verified canonical server state.
8. Do not bypass conflict review approval.
9. Do not store raw secrets or unmasked payment credentials locally or in logs.
10. Do not mutate payment/refund/audit history.
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
[POS GATEWAY STORE OFFLINE / LOCAL LEDGER / RESYNC — DIFF REVIEW ONLY]

Review the current diff only.

Do not modify files.
Do not auto-fix.
Do not format.
Do not run migrations.
Do not change secrets.
Do not commit.
Do not deploy.

Compare the diff against:
- 01180 Overview
- 01190 Logic
- 01200 Module
- 01210 Traceability
- 01220 Handoff Readiness
- allowed file list
- restricted file register
- offline operation policy
- device trust model
- local ledger boundary
- hash-chain model
- conflict policy
- upstream approval/refund/retry dependencies
- test requirements
- evidence requirements

Return:
1. changed_files
2. unapproved_changed_files
3. restricted_zone_touched
4. missing_approval
5. policy_mismatch
6. logic_mismatch
7. duplicate_order_risk
8. duplicate_approval_risk
9. duplicate_refund_risk
10. local_pending_as_final_risk
11. local_hash_chain_or_sequence_gap
12. device_trust_gap
13. canonical_overwrite_risk
14. local_secret_leak_risk
15. audit_gap
16. reconciliation_gap
17. missing_tests
18. missing_evidence
19. rollback_or_split_recommendation
20. merge_risk_summary
```

---

## 9. Mode E — Rollback Assistance Prompt

Use only with human approval when rollback is needed.

```text
[POS GATEWAY STORE OFFLINE / LOCAL LEDGER / RESYNC — ROLLBACK ASSISTANCE]

Assist with rollback planning for the current diff.

Do not execute destructive commands unless the human owner explicitly approves.
Do not use git reset --hard.
Do not use git clean.
Do not delete untracked files.
Do not remove unrelated user changes.
Do not commit.
Do not deploy.

Goal:
Identify the minimal rollback needed to remove unapproved or unsafe offline/local-ledger/resync changes.

Return:
1. files_to_revert
2. hunks_to_revert
3. files_to_preserve
4. duplicate_order_approval_refund_reason
5. local_pending_as_final_reason
6. device_trust_or_hash_chain_reason
7. canonical_overwrite_reason
8. restricted_zone_reason
9. post_rollback_tests
10. post_rollback_evidence
11. residual_risk
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
| Policy References Checked | Offline Policy / Device Trust / Local Ledger / Hash Chain / Conflict Approval |
| Approval Evidence | TBD |
| Tests Run | TBD |
| Evidence Updated | TBD |
| Result | Report Only / Docs Updated / Runtime Change / Blocked / Rolled Back |
| Next Action | TBD |

---

## 11. Unsafe Prompt Examples

Reject prompts like:

```text
Implement offline mode.
Make local ledger work.
Sync offline records.
Merge local records to server.
Fix resync conflicts.
Update all needed files.
Run migrations if needed.
Commit the fix.
```

These prompts violate scope, restricted-zone, local-ledger, canonical-state, test, and evidence controls.

---

## 12. Summary

This prompt template allows Claude Code to assist the POS Gateway Store Offline / Local Ledger / Resync package without causing uncontrolled local-ledger merge or canonical-state corruption.

The safe default is read-only hydration.

Runtime implementation requires:

```text
01180 Overview
01190 Logic
01200 Module
01210 Traceability
01220 Handoff Readiness
actual source paths
actual tests
offline operation policy
device trust model
local ledger boundary
hash-chain model
conflict approval policy
restricted approvals
upstream dependency validation
evidence target
```

No Claude Code session may bypass:

```text
Overview → Logic → Module → File → Test → Evidence
```
