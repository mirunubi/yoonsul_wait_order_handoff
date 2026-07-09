# 001410_Template_POS_Gateway_Settlement_Dispute_Evidence_Export_Claude_Code_Handoff_Prompt.md

## 1. Document Control

| Field | Value |
|---|---|
| Project | yoonsul_wait_order_handoff / CatchMenu-Catch&Order |
| Band | 00100_project_foundation |
| Document Type | Template |
| Document Role | POS Gateway Settlement / Dispute / Evidence Export Claude Code Handoff Prompt |
| Related Overview | 001360_Spec_Overview_POS_Gateway_Settlement_Dispute_And_Evidence_Export_Main_Flow.md |
| Related Logic | 001370_Spec_Logic_POS_Gateway_Settlement_Dispute_Evidence_Export_State_Transition_And_Exception_Rule.md |
| Related Module | 001380_Spec_Module_POS_Gateway_Settlement_Dispute_Evidence_Export_API_Data_Model_And_Test_Map.md |
| Related Traceability Matrix | 001390_Matrix_POS_Gateway_Settlement_Dispute_Evidence_Export_Overview_Logic_Module_To_Flow_Bundle_Traceability.md |
| Related Handoff Readiness | 001400_Checklist_POS_Gateway_Settlement_Dispute_Evidence_Export_Code_Handoff_Readiness.md |
| Related Runtime Flow Bundle | 064150_Flow_POS_Gateway_Settlement_Dispute_And_Evidence_Export.md |
| Related Flow Handoff Gate | 064300_Checklist_Flow_Bundle_Code_Handoff_Readiness_Gate.md |
| Related No-AI-Solo Governance | 064370_Governance_Flow_Bundle_Human_Approval_And_No_AI_Solo_Zone_Control.md |
| Status | Draft / Pending Hydration |
| Owner | Architecture / Engineering / QA / Compliance / Finance / Security / Operations |
| AI Solo Change | Handoff prompt allowed; settlement/dispute/evidence export runtime implementation approval prohibited |

---

## 2. Purpose

This template provides bounded Claude Code prompts for POS Gateway Settlement / Dispute / Evidence Export work.

It is not a broad implementation command.

The prompt must enforce:

```text
Overview → Logic → Module → File → Test → Evidence
```

and:

```text
Flow Step → Module → File → Test → Evidence
```

The default mode is read-only or documentation mapping until actual source paths, tests, owners, restricted files, settlement/dispute/export policies, variance tolerance, redaction/masking policy, legal hold/retention policy, export manifest/hash format, upstream dependencies, and human approvals are complete.

---

## 3. Use Modes

| Mode | When To Use | File Modification Allowed? |
|---|---|---:|
| Mode A — Read-Only Hydration | Actual source paths are unknown | No |
| Mode B — Documentation Mapping | Hydration found paths but docs need update | Docs only |
| Mode C — Narrow Runtime Implementation | 01400 passes and approvals exist | Conditional |
| Mode D — Diff Review | Settlement/dispute/export change already made | No unless explicitly asked |
| Mode E — Rollback Assistance | False closeout, hidden variance, unauthorized export, secret leak, legal hold breach, or audit gap detected | Conditional, human-approved |

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
Do not fabricate settlement records.
Do not create fake internal ledger entries for orphan provider settlement records.
Do not silently close settlement variance.
Do not close settlement without source ledger, provider record, match/approved variance, audit, and evidence.
Do not hide amount, currency, fee, tax, commission, timing, missing, orphan, or duplicate variance.
Do not auto-resolve disputes without exact correlation.
Do not choose one target when dispute correlation is ambiguous.
Do not build evidence bundles with missing source records or audit-chain gaps.
Do not approve evidence export without authorized role, purpose, scope, and evidence bundle.
Do not bypass redaction or masking.
Do not export raw secrets, raw signatures, credentials, or unnecessary sensitive data.
Do not bypass legal hold or retention rules.
Do not generate export file without hash, manifest, and access control.
Do not allow unlogged export access.
Do not mutate audit history.
Return blockers instead of guessing.
```

---

## 5. Mode A — Read-Only Hydration Prompt

Use this when actual source paths are unknown.

```text
[POS GATEWAY SETTLEMENT / DISPUTE / EVIDENCE EXPORT — READ-ONLY HYDRATION]

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
Find the actual source paths, tests, data models, queues, jobs, schemas, provider settlement/dispute policies, export policies, retention/legal hold paths, and restricted files needed to map POS Gateway Settlement / Dispute / Evidence Export implementation.

Read these documents first:
- 001360_Spec_Overview_POS_Gateway_Settlement_Dispute_And_Evidence_Export_Main_Flow.md
- 001370_Spec_Logic_POS_Gateway_Settlement_Dispute_Evidence_Export_State_Transition_And_Exception_Rule.md
- 001380_Spec_Module_POS_Gateway_Settlement_Dispute_Evidence_Export_API_Data_Model_And_Test_Map.md
- 001390_Matrix_POS_Gateway_Settlement_Dispute_Evidence_Export_Overview_Logic_Module_To_Flow_Bundle_Traceability.md
- 001400_Checklist_POS_Gateway_Settlement_Dispute_Evidence_Export_Code_Handoff_Readiness.md
- 000910_Spec_Overview_POS_Gateway_Approval_Main_Flow.md
- 000920_Spec_Logic_POS_Gateway_Approval_State_Transition_And_Exception_Rule.md
- 000930_Spec_Module_POS_Gateway_Approval_API_Data_Model_And_Test_Map.md
- 001000_Spec_Overview_POS_Gateway_Cancel_Refund_Recovery_Main_Flow.md
- 001010_Spec_Logic_POS_Gateway_Cancel_Refund_State_Transition_And_Exception_Rule.md
- 001020_Spec_Module_POS_Gateway_Cancel_Refund_API_Data_Model_And_Test_Map.md
- 001100_Spec_Logic_POS_Gateway_Timeout_Retry_DLQ_Replay_State_Transition_And_Exception_Rule.md
- 001190_Spec_Logic_POS_Gateway_Store_Offline_Local_Ledger_Resync_State_Transition_And_Exception_Rule.md
- 001280_Spec_Logic_POS_Gateway_Webhook_Inbound_Verification_Event_Normalization_State_Transition_And_Exception_Rule.md
- 000820_Matrix_Development_Foundation_Source_Tree_To_Module_Document_Map.md
- 000830_Register_Development_Foundation_Repository_Module_Owner_Map.md
- 000750_Register_Development_Foundation_Restricted_File_And_Zone_Control.md
- 064150_Flow_POS_Gateway_Settlement_Dispute_And_Evidence_Export.md

Find candidate files and folders for:
1. settlement candidate builder
2. provider settlement ingestion service
3. provider settlement validator
4. settlement record normalizer
5. reconciliation engine
6. settlement variance detector
7. finance review task service
8. settlement closeout service
9. dispute intake service
10. dispute validator
11. dispute correlation resolver
12. evidence bundle builder
13. legal hold service
14. retention guard
15. evidence export request service
16. export approval gate
17. export redaction/masking service
18. export manifest/hash/index service
19. export access logger
20. settlement/dispute audit append service
21. settlement/dispute/export status projector
22. tests
23. DB/schema/migration candidates
24. queue/job/event definitions
25. provider settlement/dispute policy/config definitions
26. export policy/config definitions
27. retention/legal hold policy/config definitions
28. secrets/config/deploy/restricted paths
29. upstream approval/cancel-refund/retry/offline/webhook dependency paths

Return only a report with:
- repository path and git status
- candidate source paths
- candidate test paths
- candidate DB/schema paths
- candidate queue/job/event paths
- candidate provider settlement/dispute policy/config paths
- candidate export policy/config paths
- candidate retention/legal hold paths
- candidate restricted paths
- upstream dependency paths
- missing documents
- rows to add to 00820
- rows to add to 00830
- rows to add to 00750
- rows to add to 01390
- policy gaps: settlement scope / dispute scope / export scope / settlement identity / variance tolerance / fee-tax normalization / dispute correlation / evidence bundle / export approval / redaction / legal hold / retention / manifest-hash
- whether runtime implementation is still blocked
```

---

## 6. Mode B — Documentation Mapping Prompt

Use this after hydration finds paths but before code implementation.

```text
[POS GATEWAY SETTLEMENT / DISPUTE / EVIDENCE EXPORT — DOCUMENTATION MAPPING ONLY]

Do not modify source code.
Do not modify tests.
Do not run formatters.
Do not run migrations.
Do not change secrets.
Do not stage or commit.
Do not deploy.

Task:
Update or propose updates to the documentation mapping for POS Gateway Settlement / Dispute / Evidence Export.

Use the chain:
Overview → Logic → Module → File → Test → Evidence.

Documents:
- 001380_Spec_Module_POS_Gateway_Settlement_Dispute_Evidence_Export_API_Data_Model_And_Test_Map.md
- 001390_Matrix_POS_Gateway_Settlement_Dispute_Evidence_Export_Overview_Logic_Module_To_Flow_Bundle_Traceability.md
- 001400_Checklist_POS_Gateway_Settlement_Dispute_Evidence_Export_Code_Handoff_Readiness.md
- 000820_Matrix_Development_Foundation_Source_Tree_To_Module_Document_Map.md
- 000830_Register_Development_Foundation_Repository_Module_Owner_Map.md
- 000750_Register_Development_Foundation_Restricted_File_And_Zone_Control.md

Use the hydration findings:
<paste hydration report or path references>

Return:
1. proposed document rows
2. source path mapping
3. test path mapping
4. DB/schema mapping
5. queue/job/event mapping
6. provider settlement/dispute policy/config mapping
7. export policy/config mapping
8. retention/legal hold mapping
9. restricted-zone mapping
10. upstream approval/cancel-refund/retry/offline/webhook dependency mapping
11. policy gaps
12. remaining blockers
13. whether narrow runtime handoff is allowed
```

---

## 7. Mode C — Narrow Runtime Implementation Prompt

Use only if 01400 passes and human approval exists for restricted areas.

```text
[POS GATEWAY SETTLEMENT / DISPUTE / EVIDENCE EXPORT — NARROW RUNTIME IMPLEMENTATION]

You are implementing one narrow POS Gateway Settlement / Dispute / Evidence Export change.

This is a restricted financial, legal, evidence-export, compliance, and audit flow.
AI solo implementation approval is prohibited.
Human approval is required for settlement candidate generation, provider settlement validation, reconciliation, variance detection, settlement closeout, dispute correlation, evidence bundle scope, export approval, redaction/masking, legal hold, retention, manifest/hash, audit, DB, security, and release changes.

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
- Overview: 001360_Spec_Overview_POS_Gateway_Settlement_Dispute_And_Evidence_Export_Main_Flow.md
- Logic: 001370_Spec_Logic_POS_Gateway_Settlement_Dispute_Evidence_Export_State_Transition_And_Exception_Rule.md
- Module: 001380_Spec_Module_POS_Gateway_Settlement_Dispute_Evidence_Export_API_Data_Model_And_Test_Map.md
- Traceability: 001390_Matrix_POS_Gateway_Settlement_Dispute_Evidence_Export_Overview_Logic_Module_To_Flow_Bundle_Traceability.md
- Handoff Readiness: 001400_Checklist_POS_Gateway_Settlement_Dispute_Evidence_Export_Code_Handoff_Readiness.md
- Runtime Flow: 064150_Flow_POS_Gateway_Settlement_Dispute_And_Evidence_Export.md

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
- Provider settlement scope: <approved policy reference>
- Provider dispute scope: <approved policy reference>
- Evidence export scope: <approved policy reference>
- Settlement identity fields: <approved policy reference>
- Variance tolerance: <approved policy reference>
- Fee/tax/commission normalization: <approved policy reference>
- Settlement closeout authority: <approved policy reference>
- Dispute correlation policy: <approved policy reference>
- Evidence bundle scope: <approved policy reference>
- Export approval role: <approved policy reference>
- Export purpose/scope: <approved policy reference>
- Redaction/masking: <approved policy reference>
- Secret/signature leak block: <approved policy reference>
- Legal hold/retention: <approved policy reference>
- Export manifest/hash/index: <approved policy reference>
- Export access logging: <approved policy reference>

## Restricted Zone Status
- Restricted zones touched: <list>
- Human approval evidence: <ticket/document/reference>
- Approval owner: <name/role>

## Required Logic Rules
- <LOGIC-POS-SET-Rxxx>
- <LOGIC-POS-SET-Rxxx>

## Required Tests
- <test path and scenario>
- <test path and scenario>

## Required Evidence
- <evidence target>
- <review packet target>

## Implementation Rules
1. Do not fabricate settlement records.
2. Do not create fake internal ledger entries for orphan provider settlement records.
3. Do not silently close settlement variance.
4. Do not close settlement without source ledger, provider record, match/approved variance, audit, and evidence.
5. Do not hide amount, currency, fee, tax, commission, timing, missing, orphan, or duplicate variance.
6. Do not auto-resolve disputes without exact correlation.
7. Do not choose one target when dispute correlation is ambiguous.
8. Do not build evidence bundles with missing source records or audit-chain gaps.
9. Do not approve evidence export without authorized role, purpose, scope, and evidence bundle.
10. Do not bypass redaction or masking.
11. Do not export raw secrets, raw signatures, credentials, or unnecessary sensitive data.
12. Do not bypass legal hold or retention rules.
13. Do not generate export file without hash, manifest, and access control.
14. Do not allow unlogged export access.
15. Do not mutate audit history.
16. Keep the diff minimal.

## Required Output
Return:
1. documents_read
2. allowed_files_confirmed
3. changed_files
4. restricted_zone_touch_report
5. policies_checked
6. upstream_dependencies_checked
7. logic_rules_implemented
8. tests_added_or_updated
9. tests_run
10. test_results
11. evidence_notes
12. unresolved_blockers
13. merge_risk_summary
```

---

## 8. Mode D — Diff Review Prompt

Use after a change has been made.

```text
[POS GATEWAY SETTLEMENT / DISPUTE / EVIDENCE EXPORT — DIFF REVIEW ONLY]

Review the current diff only.

Do not modify files.
Do not auto-fix.
Do not format.
Do not run migrations.
Do not change secrets.
Do not commit.
Do not deploy.

Compare the diff against:
- 01360 Overview
- 01370 Logic
- 01380 Module
- 01390 Traceability
- 01400 Handoff Readiness
- allowed file list
- restricted file register
- provider settlement scope
- provider dispute scope
- evidence export scope
- settlement identity policy
- variance tolerance policy
- fee/tax/commission normalization policy
- dispute correlation policy
- evidence bundle scope policy
- export approval role policy
- redaction/masking policy
- legal hold/retention policy
- export manifest/hash policy
- export access logging policy
- upstream approval/refund/retry/offline/webhook dependencies
- test requirements
- evidence requirements

Return:
1. changed_files
2. unapproved_changed_files
3. restricted_zone_touched
4. missing_approval
5. policy_mismatch
6. logic_mismatch
7. false_settlement_closeout_risk
8. hidden_variance_risk
9. duplicate_settlement_closeout_risk
10. wrong_dispute_correlation_risk
11. ambiguous_dispute_target_risk
12. evidence_source_missing_risk
13. audit_chain_gap_risk
14. unauthorized_export_risk
15. redaction_or_secret_leak_risk
16. legal_hold_or_retention_violation_risk
17. export_manifest_hash_gap
18. export_access_logging_gap
19. audit_gap
20. missing_tests
21. missing_evidence
22. rollback_or_split_recommendation
23. merge_risk_summary
```

---

## 9. Mode E — Rollback Assistance Prompt

Use only with human approval when rollback is needed.

```text
[POS GATEWAY SETTLEMENT / DISPUTE / EVIDENCE EXPORT — ROLLBACK ASSISTANCE]

Assist with rollback planning for the current diff.

Do not execute destructive commands unless the human owner explicitly approves.
Do not use git reset --hard.
Do not use git clean.
Do not delete untracked files.
Do not remove unrelated user changes.
Do not commit.
Do not deploy.

Goal:
Identify the minimal rollback needed to remove unapproved or unsafe settlement/dispute/evidence export changes.

Return:
1. files_to_revert
2. hunks_to_revert
3. files_to_preserve
4. false_settlement_closeout_reason
5. hidden_variance_reason
6. duplicate_settlement_reason
7. wrong_dispute_correlation_reason
8. evidence_source_missing_reason
9. unauthorized_export_reason
10. redaction_or_secret_leak_reason
11. legal_hold_or_retention_reason
12. audit_gap_reason
13. restricted_zone_reason
14. post_rollback_tests
15. post_rollback_evidence
16. residual_risk
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
| Policy References Checked | Settlement / Dispute / Export / Variance / Redaction / Legal Hold / Retention / Manifest |
| Upstream Dependencies Checked | Approval / Cancel-Refund / Retry-DLQ / Offline-Resync / Webhook |
| Approval Evidence | TBD |
| Tests Run | TBD |
| Evidence Updated | TBD |
| Result | Report Only / Docs Updated / Runtime Change / Blocked / Rolled Back |
| Next Action | TBD |

---

## 11. Unsafe Prompt Examples

Reject prompts like:

```text
Implement settlement handling.
Close settlement records.
Resolve disputes.
Export evidence.
Make dispute evidence work.
Add settlement reconciliation.
Fix settlement variance.
Generate export files.
Run migrations if needed.
Update all needed files.
Commit the fix.
```

These prompts violate scope, restricted-zone, financial, legal, evidence, privacy, test, and audit controls.

---

## 12. Summary

This prompt template allows Claude Code to assist the POS Gateway Settlement / Dispute / Evidence Export package without causing uncontrolled settlement closeout, dispute resolution, evidence export, legal hold violation, sensitive data leakage, or audit-chain corruption.

The safe default is read-only hydration.

Runtime implementation requires:

```text
01360 Overview
01370 Logic
01380 Module
01390 Traceability
01400 Handoff Readiness
actual source paths
actual tests
provider settlement/dispute/export policies
settlement identity policy
variance tolerance policy
fee/tax normalization policy
dispute correlation policy
evidence bundle scope policy
export approval policy
redaction/masking policy
legal hold/retention policy
export manifest/hash policy
restricted approvals
upstream dependency validation
evidence target
```

No Claude Code session may bypass:

```text
Overview → Logic → Module → File → Test → Evidence
```
