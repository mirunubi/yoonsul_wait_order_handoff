# 001320_Template_POS_Gateway_Webhook_Inbound_Verification_Event_Normalization_Claude_Code_Handoff_Prompt.md

## 1. Document Control

| Field | Value |
|---|---|
| Project | yoonsul_wait_order_handoff / CatchMenu-Catch&Order |
| Band | 00100_project_foundation |
| Document Type | Template |
| Document Role | POS Gateway Webhook Inbound Verification / Event Normalization Claude Code Handoff Prompt |
| Related Overview | 001270_Spec_Overview_POS_Gateway_Webhook_Inbound_Verification_And_Event_Normalization_Main_Flow.md |
| Related Logic | 001280_Spec_Logic_POS_Gateway_Webhook_Inbound_Verification_Event_Normalization_State_Transition_And_Exception_Rule.md |
| Related Module | 001290_Spec_Module_POS_Gateway_Webhook_Inbound_Verification_Event_Normalization_API_Data_Model_And_Test_Map.md |
| Related Traceability Matrix | 001300_Matrix_POS_Gateway_Webhook_Inbound_Verification_Event_Normalization_Overview_Logic_Module_To_Flow_Bundle_Traceability.md |
| Related Handoff Readiness | 001310_Checklist_POS_Gateway_Webhook_Inbound_Verification_Event_Normalization_Code_Handoff_Readiness.md |
| Related Runtime Flow Bundle | 064140_Flow_POS_Gateway_Webhook_Inbound_Verification_And_Event_Normalization.md |
| Related Flow Handoff Gate | 064300_Checklist_Flow_Bundle_Code_Handoff_Readiness_Gate.md |
| Related No-AI-Solo Governance | 064370_Governance_Flow_Bundle_Human_Approval_And_No_AI_Solo_Zone_Control.md |
| Status | Draft / Pending Hydration |
| Owner | Architecture / Engineering / QA / Compliance / Security / Operations |
| AI Solo Change | Handoff prompt allowed; webhook verification/final-state mutation/audit/security/release implementation approval prohibited |

---

## 2. Purpose

This template provides bounded Claude Code prompts for POS Gateway Webhook Inbound Verification / Event Normalization work.

It is not a broad implementation command.

The prompt must enforce:

```text
Overview → Logic → Module → File → Test → Evidence
```

and:

```text
Flow Step → Module → File → Test → Evidence
```

The default mode is read-only or documentation mapping until actual source paths, tests, owners, restricted files, provider policies, signature scheme, replay policy, canonical event schema, final-state mutation rules, quarantine/DLQ owner, and human approvals are complete.

---

## 3. Use Modes

| Mode | When To Use | File Modification Allowed? |
|---|---|---:|
| Mode A — Read-Only Hydration | Actual source paths are unknown | No |
| Mode B — Documentation Mapping | Hydration found paths but docs need update | Docs only |
| Mode C — Narrow Runtime Implementation | 01310 passes and approvals exist | Conditional |
| Mode D — Diff Review | Webhook verification/normalization change already made | No unless explicitly asked |
| Mode E — Rollback Assistance | Forgery, replay, duplicate mutation, stale overwrite, secret leak, or unapproved diff detected | Conditional, human-approved |

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
Do not accept unsigned or forged webhook events.
Do not bypass provider identity resolution.
Do not bypass endpoint/store/merchant policy mapping.
Do not bypass signature verification.
Do not bypass timestamp freshness checks.
Do not bypass nonce/replay protection.
Do not bypass key version policy.
Do not normalize unknown provider events into final financial states.
Do not reapply duplicate provider events.
Do not allow stale webhook events to overwrite newer terminal state.
Do not correlate events to ambiguous internal targets.
Do not route unverified or uncorrelated events to ledger mutation.
Do not create duplicate approval behavior.
Do not create duplicate refund behavior.
Do not create duplicate settlement mutation.
Do not mark webhook-derived payment/refund state as final without explicit provider proof.
Do not store raw secrets, raw signatures, credentials, or unmasked sensitive payloads in logs, local storage, DLQ, or evidence.
Do not mutate audit history.
Return blockers instead of guessing.
```

---

## 5. Mode A — Read-Only Hydration Prompt

Use this when actual source paths are unknown.

```text
[POS GATEWAY WEBHOOK INBOUND VERIFICATION / EVENT NORMALIZATION — READ-ONLY HYDRATION]

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
Find the actual source paths, tests, data models, queues, jobs, schemas, provider policies, and restricted files needed to map POS Gateway Webhook Inbound Verification / Event Normalization implementation.

Read these documents first:
- 001270_Spec_Overview_POS_Gateway_Webhook_Inbound_Verification_And_Event_Normalization_Main_Flow.md
- 001280_Spec_Logic_POS_Gateway_Webhook_Inbound_Verification_Event_Normalization_State_Transition_And_Exception_Rule.md
- 001290_Spec_Module_POS_Gateway_Webhook_Inbound_Verification_Event_Normalization_API_Data_Model_And_Test_Map.md
- 001300_Matrix_POS_Gateway_Webhook_Inbound_Verification_Event_Normalization_Overview_Logic_Module_To_Flow_Bundle_Traceability.md
- 001310_Checklist_POS_Gateway_Webhook_Inbound_Verification_Event_Normalization_Code_Handoff_Readiness.md
- 000910_Spec_Overview_POS_Gateway_Approval_Main_Flow.md
- 000920_Spec_Logic_POS_Gateway_Approval_State_Transition_And_Exception_Rule.md
- 000930_Spec_Module_POS_Gateway_Approval_API_Data_Model_And_Test_Map.md
- 001000_Spec_Overview_POS_Gateway_Cancel_Refund_Recovery_Main_Flow.md
- 001010_Spec_Logic_POS_Gateway_Cancel_Refund_State_Transition_And_Exception_Rule.md
- 001020_Spec_Module_POS_Gateway_Cancel_Refund_API_Data_Model_And_Test_Map.md
- 001100_Spec_Logic_POS_Gateway_Timeout_Retry_DLQ_Replay_State_Transition_And_Exception_Rule.md
- 001190_Spec_Logic_POS_Gateway_Store_Offline_Local_Ledger_Resync_State_Transition_And_Exception_Rule.md
- 000820_Matrix_Development_Foundation_Source_Tree_To_Module_Document_Map.md
- 000830_Register_Development_Foundation_Repository_Module_Owner_Map.md
- 000750_Register_Development_Foundation_Restricted_File_And_Zone_Control.md
- 064140_Flow_POS_Gateway_Webhook_Inbound_Verification_And_Event_Normalization.md

Find candidate files and folders for:
1. inbound webhook endpoint
2. provider identity resolver
3. endpoint/store/merchant context resolver
4. signature verifier
5. timestamp freshness guard
6. nonce/replay guard
7. key version guard
8. payload schema validator
9. raw event store
10. payload hash service
11. secret masking guard
12. deduplication guard
13. ordering/state guard
14. provider event normalizer
15. correlation resolver
16. event router
17. quarantine/DLQ router
18. webhook audit append service
19. webhook status projector
20. tests
21. DB/schema/migration candidates
22. queue/job/event definitions
23. provider policy/config definitions
24. secrets/config/deploy/restricted paths
25. upstream approval/cancel-refund/retry/offline dependency paths

Return only a report with:
- repository path and git status
- candidate source paths
- candidate test paths
- candidate DB/schema paths
- candidate queue/job/event paths
- candidate provider policy/config paths
- candidate restricted paths
- upstream dependency paths
- missing documents
- rows to add to 00820
- rows to add to 00830
- rows to add to 00750
- rows to add to 01300
- policy gaps: provider list / signature / timestamp / replay / key version / canonical event schema / mutation policy / quarantine SLA
- whether runtime implementation is still blocked
```

---

## 6. Mode B — Documentation Mapping Prompt

Use this after hydration finds paths but before code implementation.

```text
[POS GATEWAY WEBHOOK INBOUND VERIFICATION / EVENT NORMALIZATION — DOCUMENTATION MAPPING ONLY]

Do not modify source code.
Do not modify tests.
Do not run formatters.
Do not run migrations.
Do not change secrets.
Do not stage or commit.
Do not deploy.

Task:
Update or propose updates to the documentation mapping for POS Gateway Webhook Inbound Verification / Event Normalization.

Use the chain:
Overview → Logic → Module → File → Test → Evidence.

Documents:
- 001290_Spec_Module_POS_Gateway_Webhook_Inbound_Verification_Event_Normalization_API_Data_Model_And_Test_Map.md
- 001300_Matrix_POS_Gateway_Webhook_Inbound_Verification_Event_Normalization_Overview_Logic_Module_To_Flow_Bundle_Traceability.md
- 001310_Checklist_POS_Gateway_Webhook_Inbound_Verification_Event_Normalization_Code_Handoff_Readiness.md
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
6. provider policy/config mapping
7. restricted-zone mapping
8. upstream approval/cancel-refund/retry/offline dependency mapping
9. policy gaps: provider list / signature / timestamp / replay / key version / canonical schema / mutation / quarantine
10. remaining blockers
11. whether narrow runtime handoff is allowed
```

---

## 7. Mode C — Narrow Runtime Implementation Prompt

Use only if 01310 passes and human approval exists for restricted areas.

```text
[POS GATEWAY WEBHOOK INBOUND VERIFICATION / EVENT NORMALIZATION — NARROW RUNTIME IMPLEMENTATION]

You are implementing one narrow POS Gateway Webhook Inbound Verification / Event Normalization change.

This is a restricted external-provider and financial-state safety flow.
AI solo implementation approval is prohibited.
Human approval is required for provider identity, signature, timestamp, replay, key version, schema validation, deduplication, ordering, final-state normalization, correlation, ledger routing, quarantine/DLQ, audit, security, DB, secret, and release changes.

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
- Overview: 001270_Spec_Overview_POS_Gateway_Webhook_Inbound_Verification_And_Event_Normalization_Main_Flow.md
- Logic: 001280_Spec_Logic_POS_Gateway_Webhook_Inbound_Verification_Event_Normalization_State_Transition_And_Exception_Rule.md
- Module: 001290_Spec_Module_POS_Gateway_Webhook_Inbound_Verification_Event_Normalization_API_Data_Model_And_Test_Map.md
- Traceability: 001300_Matrix_POS_Gateway_Webhook_Inbound_Verification_Event_Normalization_Overview_Logic_Module_To_Flow_Bundle_Traceability.md
- Handoff Readiness: 001310_Checklist_POS_Gateway_Webhook_Inbound_Verification_Event_Normalization_Code_Handoff_Readiness.md
- Runtime Flow: 064140_Flow_POS_Gateway_Webhook_Inbound_Verification_And_Event_Normalization.md

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
- MVP provider webhook list: <approved policy reference>
- Provider signature scheme: <approved policy reference>
- Timestamp freshness window: <approved policy reference>
- Nonce/replay key policy: <approved policy reference>
- Key version policy: <approved policy reference>
- Payload schema version policy: <approved policy reference>
- Canonical normalized event schema: <approved policy reference>
- Event-to-ledger mutation policy: <approved policy reference>
- Terminal state overwrite policy: <approved policy reference>
- Quarantine/DLQ owner and SLA: <approved policy reference>

## Restricted Zone Status
- Restricted zones touched: <list>
- Human approval evidence: <ticket/document/reference>
- Approval owner: <name/role>

## Required Logic Rules
- <LOGIC-POS-WH-Rxxx>
- <LOGIC-POS-WH-Rxxx>

## Required Tests
- <test path and scenario>
- <test path and scenario>

## Required Evidence
- <evidence target>
- <review packet target>

## Implementation Rules
1. Do not accept unsigned, forged, unknown-provider, or stale webhook events.
2. Do not bypass provider identity, endpoint, store, or merchant policy mapping.
3. Do not bypass signature, timestamp, nonce/replay, or key version checks.
4. Do not normalize unknown provider event types to final financial states.
5. Do not reapply duplicate provider events.
6. Do not allow stale events to overwrite newer terminal state.
7. Do not correlate ambiguous events to financial targets.
8. Do not route unverified or uncorrelated events to ledger mutation.
9. Do not create duplicate approval/refund/settlement mutation.
10. Do not mark payment/refund state as final without explicit provider proof.
11. Do not store raw secrets, raw signatures, credentials, or unmasked sensitive payloads.
12. Do not mutate audit history.
13. Keep the diff minimal.

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
[POS GATEWAY WEBHOOK INBOUND VERIFICATION / EVENT NORMALIZATION — DIFF REVIEW ONLY]

Review the current diff only.

Do not modify files.
Do not auto-fix.
Do not format.
Do not run migrations.
Do not change secrets.
Do not commit.
Do not deploy.

Compare the diff against:
- 01270 Overview
- 01280 Logic
- 01290 Module
- 01300 Traceability
- 01310 Handoff Readiness
- allowed file list
- restricted file register
- MVP provider webhook list
- signature policy
- timestamp/replay/key version policy
- payload schema policy
- canonical normalized event schema
- event-to-ledger mutation policy
- terminal state overwrite policy
- quarantine/DLQ policy
- upstream approval/refund/retry/offline dependencies
- test requirements
- evidence requirements

Return:
1. changed_files
2. unapproved_changed_files
3. restricted_zone_touched
4. missing_approval
5. policy_mismatch
6. logic_mismatch
7. forged_webhook_acceptance_risk
8. replay_attack_risk
9. duplicate_approval_risk
10. duplicate_refund_risk
11. duplicate_settlement_risk
12. stale_event_overwrite_risk
13. ambiguous_correlation_risk
14. unknown_event_final_state_risk
15. raw_secret_or_signature_leak_risk
16. audit_gap
17. reconciliation_gap
18. missing_tests
19. missing_evidence
20. rollback_or_split_recommendation
21. merge_risk_summary
```

---

## 9. Mode E — Rollback Assistance Prompt

Use only with human approval when rollback is needed.

```text
[POS GATEWAY WEBHOOK INBOUND VERIFICATION / EVENT NORMALIZATION — ROLLBACK ASSISTANCE]

Assist with rollback planning for the current diff.

Do not execute destructive commands unless the human owner explicitly approves.
Do not use git reset --hard.
Do not use git clean.
Do not delete untracked files.
Do not remove unrelated user changes.
Do not commit.
Do not deploy.

Goal:
Identify the minimal rollback needed to remove unapproved or unsafe webhook verification/event normalization changes.

Return:
1. files_to_revert
2. hunks_to_revert
3. files_to_preserve
4. forged_webhook_acceptance_reason
5. replay_or_duplicate_mutation_reason
6. stale_event_overwrite_reason
7. ambiguous_correlation_reason
8. unknown_event_final_state_reason
9. raw_secret_or_signature_leak_reason
10. restricted_zone_reason
11. post_rollback_tests
12. post_rollback_evidence
13. residual_risk
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
| Policy References Checked | Provider / Signature / Timestamp / Replay / Key / Schema / Mutation / Quarantine |
| Approval Evidence | TBD |
| Tests Run | TBD |
| Evidence Updated | TBD |
| Result | Report Only / Docs Updated / Runtime Change / Blocked / Rolled Back |
| Next Action | TBD |

---

## 11. Unsafe Prompt Examples

Reject prompts like:

```text
Implement webhook handling.
Verify webhooks.
Normalize all provider events.
Make webhook sync work.
Route webhook events to ledger.
Fix webhook duplicates.
Handle replay attacks.
Update all needed files.
Run migrations if needed.
Commit the fix.
```

These prompts violate scope, restricted-zone, provider-security, financial-state, test, and evidence controls.

---

## 12. Summary

This prompt template allows Claude Code to assist the POS Gateway Webhook Inbound Verification / Event Normalization package without causing uncontrolled external-provider event acceptance or financial-state mutation.

The safe default is read-only hydration.

Runtime implementation requires:

```text
01270 Overview
01280 Logic
01290 Module
01300 Traceability
01310 Handoff Readiness
actual source paths
actual tests
provider webhook policy
signature policy
timestamp/replay/key version policy
canonical event schema
event-to-ledger mutation policy
quarantine/DLQ policy
restricted approvals
upstream dependency validation
evidence target
```

No Claude Code session may bypass:

```text
Overview → Logic → Module → File → Test → Evidence
```
