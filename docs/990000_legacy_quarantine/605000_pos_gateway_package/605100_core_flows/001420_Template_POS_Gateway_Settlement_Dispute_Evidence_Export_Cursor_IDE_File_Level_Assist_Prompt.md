# 001420_Template_POS_Gateway_Settlement_Dispute_Evidence_Export_Cursor_IDE_File_Level_Assist_Prompt.md

## 1. Document Control

| Field | Value |
|---|---|
| Project | yoonsul_wait_order_handoff / CatchMenu-Catch&Order |
| Band | 00100_project_foundation |
| Document Type | Template |
| Document Role | POS Gateway Settlement / Dispute / Evidence Export Cursor IDE File-Level Assist Prompt |
| Related Overview | 001360_Spec_Overview_POS_Gateway_Settlement_Dispute_And_Evidence_Export_Main_Flow.md |
| Related Logic | 001370_Spec_Logic_POS_Gateway_Settlement_Dispute_Evidence_Export_State_Transition_And_Exception_Rule.md |
| Related Module | 001380_Spec_Module_POS_Gateway_Settlement_Dispute_Evidence_Export_API_Data_Model_And_Test_Map.md |
| Related Traceability Matrix | 001390_Matrix_POS_Gateway_Settlement_Dispute_Evidence_Export_Overview_Logic_Module_To_Flow_Bundle_Traceability.md |
| Related Handoff Readiness | 001400_Checklist_POS_Gateway_Settlement_Dispute_Evidence_Export_Code_Handoff_Readiness.md |
| Related Claude Handoff Prompt | 001410_Template_POS_Gateway_Settlement_Dispute_Evidence_Export_Claude_Code_Handoff_Prompt.md |
| Related Runtime Flow Bundle | 064150_Flow_POS_Gateway_Settlement_Dispute_And_Evidence_Export.md |
| Related General Cursor Prompt | 064320_Template_Flow_Bundle_Cursor_IDE_Assist_Prompt.md |
| Related No-AI-Solo Governance | 064370_Governance_Flow_Bundle_Human_Approval_And_No_AI_Solo_Zone_Control.md |
| Status | Draft / Pending Hydration |
| Owner | Architecture / Engineering / QA / Compliance / Finance / Security / Operations |
| AI Solo Change | Cursor file-level assist allowed only within approved scope; settlement/dispute/evidence export runtime approval prohibited |

---

## 2. Purpose

This template provides Cursor IDE prompts for POS Gateway Settlement / Dispute / Evidence Export work.

Cursor is treated as a file-level assistant, not as a settlement closeout, dispute correlation, evidence export approval, legal hold, redaction, or audit owner.

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

Cursor must not be used to broadly implement settlement, dispute, evidence export, legal hold, or audit behavior.

---

## 3. Cursor Use Principle

Settlement / Dispute / Evidence Export work must be narrower than ordinary backend work.

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

If target file, Logic rule, Trace ID, test, provider settlement scope, dispute scope, export scope, settlement identity policy, variance tolerance, redaction policy, legal hold policy, manifest/hash policy, or approval is unknown, Cursor must not perform runtime modification.

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

## 5. Cursor Mode A — File Explanation Only

Use when inspecting a candidate file.

```text
[CURSOR — POS GATEWAY SETTLEMENT / DISPUTE / EVIDENCE EXPORT FILE EXPLANATION ONLY]

Explain this file in the context of POS Gateway Settlement / Dispute / Evidence Export.

Do not edit.
Do not apply changes.
Do not format.
Do not run migrations.
Do not change secrets.
Do not commit.

Related docs:
- 001360_Spec_Overview_POS_Gateway_Settlement_Dispute_And_Evidence_Export_Main_Flow.md
- 001370_Spec_Logic_POS_Gateway_Settlement_Dispute_Evidence_Export_State_Transition_And_Exception_Rule.md
- 001380_Spec_Module_POS_Gateway_Settlement_Dispute_Evidence_Export_API_Data_Model_And_Test_Map.md
- 001390_Matrix_POS_Gateway_Settlement_Dispute_Evidence_Export_Overview_Logic_Module_To_Flow_Bundle_Traceability.md
- 001400_Checklist_POS_Gateway_Settlement_Dispute_Evidence_Export_Code_Handoff_Readiness.md

Target file:
- <actual file path>

Explain:
1. what this file does
2. which settlement/dispute/evidence export module it likely belongs to
3. which Logic rule it may implement
4. which Trace ID it may support
5. whether it touches settlement candidate, provider settlement validation, reconciliation, variance, finance review, closeout, dispute intake, dispute correlation, evidence bundle, legal hold, retention, export approval, redaction, manifest/hash, access logging, audit, DB, security, or release behavior
6. whether it depends on approval, cancel/refund, timeout/retry/DLQ, offline/resync, or webhook package state
7. whether it depends on settlement scope, dispute scope, export scope, settlement identity, variance tolerance, redaction, legal hold, retention, or manifest/hash policy
8. candidate tests
9. candidate evidence
10. whether this file is safe for implementation handoff
```

---

## 6. Cursor Mode B — Narrow Documentation Mapping

Use when Cursor has identified a file and you want documentation rows.

```text
[CURSOR — POS GATEWAY SETTLEMENT / DISPUTE / EVIDENCE EXPORT DOC MAPPING ONLY]

Do not edit source code.
Do not edit tests.
Do not run formatters.
Do not run migrations.
Do not change secrets.
Do not commit.

Target file:
- <actual file path>

Map this file to:
- 01380 module row
- 01390 traceability row
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
6. upstream approval/cancel-refund/retry/offline/webhook dependency
7. candidate_tests
8. restricted_zone
9. owner_candidate
10. policy_dependency: settlement_scope / dispute_scope / export_scope / settlement_identity / variance_tolerance / fee_tax_normalization / dispute_correlation / evidence_bundle / export_approval / redaction / legal_hold / retention / manifest_hash / none
11. evidence_target
12. readiness_status
```

---

## 7. Cursor Mode C — Single-File Patch Proposal

Use only after 01400 passes for the target task.

```text
[CURSOR — POS GATEWAY SETTLEMENT / DISPUTE / EVIDENCE EXPORT SINGLE-FILE PATCH]

Assist with one narrow file-level change.

Do not modify files outside the allowed file.
Do not refactor unrelated code.
Do not run migrations.
Do not change secrets.
Do not commit.
Do not deploy.

Approved documents:
- Overview: 001360_Spec_Overview_POS_Gateway_Settlement_Dispute_And_Evidence_Export_Main_Flow.md
- Logic: 001370_Spec_Logic_POS_Gateway_Settlement_Dispute_Evidence_Export_State_Transition_And_Exception_Rule.md
- Module: 001380_Spec_Module_POS_Gateway_Settlement_Dispute_Evidence_Export_API_Data_Model_And_Test_Map.md
- Traceability: 001390_Matrix_POS_Gateway_Settlement_Dispute_Evidence_Export_Overview_Logic_Module_To_Flow_Bundle_Traceability.md
- Handoff Readiness: 001400_Checklist_POS_Gateway_Settlement_Dispute_Evidence_Export_Code_Handoff_Readiness.md

Allowed file:
- <actual file path>

Task:
<single narrow task>

Related Logic Rule:
- <LOGIC-POS-SET-Rxxx>

Related Trace ID:
- <POSSET-TRACE-xxx>

Policy References:
- Provider settlement scope: <reference or N/A>
- Provider dispute scope: <reference or N/A>
- Evidence export scope: <reference or N/A>
- Settlement identity policy: <reference or N/A>
- Variance tolerance policy: <reference or N/A>
- Fee/tax/commission normalization policy: <reference or N/A>
- Dispute correlation policy: <reference or N/A>
- Evidence bundle scope policy: <reference or N/A>
- Export approval role policy: <reference or N/A>
- Redaction/masking policy: <reference or N/A>
- Legal hold/retention policy: <reference or N/A>
- Export manifest/hash policy: <reference or N/A>

Required behavior:
- Do not fabricate settlement records.
- Do not create fake internal ledger entries for orphan provider settlement records.
- Do not silently close settlement variance.
- Do not close settlement without source ledger, provider record, match/approved variance, audit, and evidence.
- Do not hide amount, currency, fee, tax, commission, timing, missing, orphan, or duplicate variance.
- Do not auto-resolve disputes without exact correlation.
- Do not choose one target when dispute correlation is ambiguous.
- Do not build evidence bundles with missing source records or audit-chain gaps.
- Do not approve evidence export without authorized role, purpose, scope, and evidence bundle.
- Do not bypass redaction or masking.
- Do not export raw secrets, raw signatures, credentials, or unnecessary sensitive data.
- Do not bypass legal hold or retention rules.
- Do not generate export file without hash, manifest, and access control.
- Do not allow unlogged export access.
- Do not mutate audit history.
- Keep diff minimal.

Required output:
1. patch summary
2. changed lines/functions
3. logic rule addressed
4. trace id addressed
5. policy references checked
6. upstream dependencies checked
7. tests that must be run
8. restricted-zone note
9. remaining blockers
```

---

## 8. Cursor Mode D — Test File Assist

Use when the target is a test file.

```text
[CURSOR — POS GATEWAY SETTLEMENT / DISPUTE / EVIDENCE EXPORT TEST ASSIST]

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
- <LOGIC-POS-SET-Rxxx>

Related Trace ID:
- <POSSET-TRACE-xxx>

Scenario:
<settlement candidate / provider settlement validation / settlement match / variance / duplicate closeout / missing provider / orphan provider / dispute validation / dispute correlation / ambiguous dispute / evidence bundle / audit chain gap / legal hold / retention / export request / unauthorized export / scope exceeded / redaction / secret leak / manifest hash / access log / audit / projection>

Required test behavior:
- verify expected state transition,
- verify non-terminal source does not create settlement candidate,
- verify provider settlement context/schema validation,
- verify amount/currency/fee/tax variance is detected,
- verify duplicate settlement does not close twice,
- verify missing/orphan records create variance/review,
- verify dispute without exact correlation is not resolved,
- verify ambiguous dispute target is blocked,
- verify evidence bundle fails when source/audit chain is missing,
- verify legal hold blocks deletion/mutation,
- verify unauthorized export is rejected,
- verify export scope/purpose is required,
- verify redaction/masking blocks secret/signature leakage,
- verify export has hash/manifest,
- verify export access is logged,
- verify audit/evidence side effect where applicable.

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
[CURSOR — POS GATEWAY SETTLEMENT / DISPUTE / EVIDENCE EXPORT DIFF REVIEW]

Review the current diff only.

Do not edit.
Do not auto-fix.
Do not format.
Do not run migrations.
Do not change secrets.
Do not commit.
Do not deploy.

Review against:
- 01360 Overview
- 01370 Logic
- 01380 Module
- 01390 Traceability
- 01400 Handoff Readiness
- allowed file list
- prohibited file list
- restricted register
- settlement scope policy
- dispute scope policy
- export scope policy
- settlement identity policy
- variance tolerance policy
- fee/tax/commission policy
- dispute correlation policy
- evidence bundle policy
- export approval policy
- redaction/masking policy
- legal hold/retention policy
- manifest/hash policy
- upstream approval/cancel-refund/retry/offline/webhook dependency
- required tests
- required evidence

Return:
1. changed_files
2. any_unapproved_file_changes
3. related_logic_rules
4. related_trace_ids
5. false_settlement_closeout_risk
6. hidden_variance_risk
7. duplicate_settlement_closeout_risk
8. missing_or_orphan_provider_record_risk
9. wrong_dispute_correlation_risk
10. ambiguous_dispute_target_risk
11. evidence_source_missing_risk
12. audit_chain_gap_risk
13. unauthorized_export_risk
14. redaction_or_secret_leak_risk
15. legal_hold_or_retention_violation_risk
16. export_manifest_hash_gap
17. export_access_logging_gap
18. audit_gap
19. missing_tests
20. missing_evidence
21. recommendation: accept / revise / rollback / split
```

---

## 10. Cursor Mode F — Blocker Extraction

Use when Cursor cannot safely implement.

```text
[CURSOR — POS GATEWAY SETTLEMENT / DISPUTE / EVIDENCE EXPORT BLOCKER EXTRACTION]

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
5. missing upstream approval/cancel-refund/retry/offline/webhook dependency
6. missing provider settlement scope
7. missing provider dispute scope
8. missing evidence export scope
9. missing settlement identity policy
10. missing variance tolerance policy
11. missing fee/tax/commission policy
12. missing dispute correlation policy
13. missing evidence bundle scope policy
14. missing export approval policy
15. missing redaction/masking policy
16. missing legal hold/retention policy
17. missing export manifest/hash policy
18. missing test
19. missing evidence
20. missing approval
21. restricted-zone concern
22. recommended next safe action
```

---

## 11. Unsafe Cursor Prompts

Do not use:

```text
Implement settlement handling.
Close settlement records.
Resolve disputes.
Export evidence.
Make settlement reconciliation work.
Fix dispute evidence.
Generate export files.
Make tests pass.
Update anything needed.
Run migrations if needed.
Commit it.
```

These prompts violate file-level scope and restricted financial/legal/evidence controls.

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
| Settlement Scope Checked? | Yes / No / N/A |
| Dispute Scope Checked? | Yes / No / N/A |
| Export Scope Checked? | Yes / No / N/A |
| Variance Policy Checked? | Yes / No / N/A |
| Dispute Correlation Checked? | Yes / No / N/A |
| Evidence Bundle Policy Checked? | Yes / No / N/A |
| Export Approval Policy Checked? | Yes / No / N/A |
| Redaction Policy Checked? | Yes / No / N/A |
| Legal Hold / Retention Checked? | Yes / No / N/A |
| Manifest / Hash Checked? | Yes / No / N/A |
| Upstream Dependency Checked? | Approval / Cancel-Refund / Retry-DLQ / Offline-Resync / Webhook / All / N/A |
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
- [ ] Related Trace ID is specified in 01390.
- [ ] Upstream approval/cancel-refund/retry/offline/webhook dependency is known.
- [ ] Provider settlement scope is approved or not applicable.
- [ ] Provider dispute scope is approved or not applicable.
- [ ] Evidence export scope is approved or not applicable.
- [ ] Settlement identity policy is approved or not applicable.
- [ ] Variance tolerance policy is approved or not applicable.
- [ ] Fee/tax/commission normalization policy is approved or not applicable.
- [ ] Dispute correlation policy is approved or not applicable.
- [ ] Evidence bundle scope policy is approved or not applicable.
- [ ] Export approval role policy is approved or not applicable.
- [ ] Redaction/masking policy is approved or not applicable.
- [ ] Legal hold/retention policy is approved or not applicable.
- [ ] Export manifest/hash policy is approved or not applicable.
- [ ] Test file is known or test gap is explicitly recorded.
- [ ] Evidence target is known.
- [ ] Human approval exists if restricted zone is touched.
- [ ] Prompt includes all absolute prohibitions.

---

## 14. Summary

Cursor may help the POS Gateway Settlement / Dispute / Evidence Export implementation only as a narrow file-level assistant.

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
broadly implement settlement closeout / dispute resolution / evidence export / legal hold / redaction / audit
```

No Cursor task may bypass:

```text
Overview → Logic → Module → File → Test → Evidence
```
