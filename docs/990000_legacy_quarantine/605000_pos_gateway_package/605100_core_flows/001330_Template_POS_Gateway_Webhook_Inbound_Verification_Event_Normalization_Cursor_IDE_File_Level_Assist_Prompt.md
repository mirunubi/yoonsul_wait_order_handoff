# 001330_Template_POS_Gateway_Webhook_Inbound_Verification_Event_Normalization_Cursor_IDE_File_Level_Assist_Prompt.md

## 1. Document Control

| Field | Value |
|---|---|
| Project | yoonsul_wait_order_handoff / CatchMenu-Catch&Order |
| Band | 00100_project_foundation |
| Document Type | Template |
| Document Role | POS Gateway Webhook Inbound Verification / Event Normalization Cursor IDE File-Level Assist Prompt |
| Related Overview | 001270_Spec_Overview_POS_Gateway_Webhook_Inbound_Verification_And_Event_Normalization_Main_Flow.md |
| Related Logic | 001280_Spec_Logic_POS_Gateway_Webhook_Inbound_Verification_Event_Normalization_State_Transition_And_Exception_Rule.md |
| Related Module | 001290_Spec_Module_POS_Gateway_Webhook_Inbound_Verification_Event_Normalization_API_Data_Model_And_Test_Map.md |
| Related Traceability Matrix | 001300_Matrix_POS_Gateway_Webhook_Inbound_Verification_Event_Normalization_Overview_Logic_Module_To_Flow_Bundle_Traceability.md |
| Related Handoff Readiness | 001310_Checklist_POS_Gateway_Webhook_Inbound_Verification_Event_Normalization_Code_Handoff_Readiness.md |
| Related Claude Handoff Prompt | 001320_Template_POS_Gateway_Webhook_Inbound_Verification_Event_Normalization_Claude_Code_Handoff_Prompt.md |
| Related Runtime Flow Bundle | 064140_Flow_POS_Gateway_Webhook_Inbound_Verification_And_Event_Normalization.md |
| Related General Cursor Prompt | 064320_Template_Flow_Bundle_Cursor_IDE_Assist_Prompt.md |
| Related No-AI-Solo Governance | 064370_Governance_Flow_Bundle_Human_Approval_And_No_AI_Solo_Zone_Control.md |
| Status | Draft / Pending Hydration |
| Owner | Architecture / Engineering / QA / Compliance / Security / Operations |
| AI Solo Change | Cursor file-level assist allowed only within approved scope; webhook verification/event normalization runtime approval prohibited |

---

## 2. Purpose

This template provides Cursor IDE prompts for POS Gateway Webhook Inbound Verification / Event Normalization work.

Cursor is treated as a file-level assistant, not as a provider-security, signature-verification, or financial-state owner.

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

Cursor must not be used to implement webhook verification, event normalization, or ledger mutation broadly.

---

## 3. Cursor Use Principle

Webhook verification/event normalization work must be narrower than ordinary backend work.

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

If target file, Logic rule, Trace ID, test, provider policy, signature policy, timestamp/replay/key policy, canonical event schema, mutation policy, quarantine/DLQ policy, or approval is unknown, Cursor must not perform runtime modification.

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

## 5. Cursor Mode A — File Explanation Only

Use when inspecting a candidate file.

```text
[CURSOR — POS GATEWAY WEBHOOK INBOUND VERIFICATION / EVENT NORMALIZATION FILE EXPLANATION ONLY]

Explain this file in the context of POS Gateway Webhook Inbound Verification / Event Normalization.

Do not edit.
Do not apply changes.
Do not format.
Do not run migrations.
Do not change secrets.
Do not commit.

Related docs:
- 001270_Spec_Overview_POS_Gateway_Webhook_Inbound_Verification_And_Event_Normalization_Main_Flow.md
- 001280_Spec_Logic_POS_Gateway_Webhook_Inbound_Verification_Event_Normalization_State_Transition_And_Exception_Rule.md
- 001290_Spec_Module_POS_Gateway_Webhook_Inbound_Verification_Event_Normalization_API_Data_Model_And_Test_Map.md
- 001300_Matrix_POS_Gateway_Webhook_Inbound_Verification_Event_Normalization_Overview_Logic_Module_To_Flow_Bundle_Traceability.md
- 001310_Checklist_POS_Gateway_Webhook_Inbound_Verification_Event_Normalization_Code_Handoff_Readiness.md

Target file:
- <actual file path>

Explain:
1. what this file does
2. which webhook verification/event normalization module it likely belongs to
3. which Logic rule it may implement
4. which Trace ID it may support
5. whether it touches provider identity, signature, timestamp, replay, key version, schema, dedup, ordering, normalization, correlation, routing, quarantine, audit, DB, security, or release behavior
6. whether it depends on approval, cancel/refund, timeout/retry/DLQ, or offline/resync package state
7. whether it depends on provider policy, signature policy, timestamp/replay policy, canonical schema, mutation policy, or quarantine policy
8. candidate tests
9. candidate evidence
10. whether this file is safe for implementation handoff
```

---

## 6. Cursor Mode B — Narrow Documentation Mapping

Use when Cursor has identified a file and you want documentation rows.

```text
[CURSOR — POS GATEWAY WEBHOOK INBOUND VERIFICATION / EVENT NORMALIZATION DOC MAPPING ONLY]

Do not edit source code.
Do not edit tests.
Do not run formatters.
Do not run migrations.
Do not change secrets.
Do not commit.

Target file:
- <actual file path>

Map this file to:
- 01290 module row
- 01300 traceability row
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
6. upstream approval/cancel-refund/retry/offline dependency
7. candidate_tests
8. restricted_zone
9. owner_candidate
10. policy_dependency: provider / signature / timestamp / replay / key version / schema / mutation / quarantine / none
11. evidence_target
12. readiness_status
```

---

## 7. Cursor Mode C — Single-File Patch Proposal

Use only after 01310 passes for the target task.

```text
[CURSOR — POS GATEWAY WEBHOOK INBOUND VERIFICATION / EVENT NORMALIZATION SINGLE-FILE PATCH]

Assist with one narrow file-level change.

Do not modify files outside the allowed file.
Do not refactor unrelated code.
Do not run migrations.
Do not change secrets.
Do not commit.
Do not deploy.

Approved documents:
- Overview: 001270_Spec_Overview_POS_Gateway_Webhook_Inbound_Verification_And_Event_Normalization_Main_Flow.md
- Logic: 001280_Spec_Logic_POS_Gateway_Webhook_Inbound_Verification_Event_Normalization_State_Transition_And_Exception_Rule.md
- Module: 001290_Spec_Module_POS_Gateway_Webhook_Inbound_Verification_Event_Normalization_API_Data_Model_And_Test_Map.md
- Traceability: 001300_Matrix_POS_Gateway_Webhook_Inbound_Verification_Event_Normalization_Overview_Logic_Module_To_Flow_Bundle_Traceability.md
- Handoff Readiness: 001310_Checklist_POS_Gateway_Webhook_Inbound_Verification_Event_Normalization_Code_Handoff_Readiness.md

Allowed file:
- <actual file path>

Task:
<single narrow task>

Related Logic Rule:
- <LOGIC-POS-WH-Rxxx>

Related Trace ID:
- <POSWH-TRACE-xxx>

Policy References:
- MVP provider webhook list: <reference or N/A>
- Signature policy: <reference or N/A>
- Timestamp freshness policy: <reference or N/A>
- Nonce/replay policy: <reference or N/A>
- Key version policy: <reference or N/A>
- Payload schema policy: <reference or N/A>
- Canonical event schema: <reference or N/A>
- Event-to-ledger mutation policy: <reference or N/A>
- Quarantine/DLQ policy: <reference or N/A>

Required behavior:
- Do not accept unsigned, forged, unknown-provider, or stale webhook events.
- Enforce provider identity, endpoint, store, and merchant policy mapping.
- Enforce signature, timestamp, nonce/replay, and key version checks.
- Do not normalize unknown provider event types to final financial states.
- Do not reapply duplicate provider events.
- Do not allow stale events to overwrite newer terminal state.
- Do not correlate ambiguous events to financial targets.
- Do not route unverified or uncorrelated events to ledger mutation.
- Do not create duplicate approval/refund/settlement mutation.
- Do not mark payment/refund state as final without explicit provider proof.
- Do not store raw secrets, raw signatures, credentials, or unmasked sensitive payloads.
- Do not mutate audit history.
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

Use when the target is a test file.

```text
[CURSOR — POS GATEWAY WEBHOOK INBOUND VERIFICATION / EVENT NORMALIZATION TEST ASSIST]

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
- <LOGIC-POS-WH-Rxxx>

Related Trace ID:
- <POSWH-TRACE-xxx>

Scenario:
<provider identity / endpoint mismatch / signature invalid / timestamp stale / nonce replay / key version invalid / schema invalid / payload hash / secret masking / duplicate no-op / hash conflict / stale overwrite / unknown event / normalization / correlation / routing / quarantine / audit / projection>

Required test behavior:
- verify expected state transition,
- verify forged webhook is rejected,
- verify stale timestamp is rejected,
- verify replay is blocked,
- verify unknown key version is rejected,
- verify invalid schema is quarantined,
- verify duplicate event does not reapply mutation,
- verify stale event does not overwrite terminal state,
- verify unknown event type is not mapped to final financial state,
- verify ambiguous correlation is blocked,
- verify unverified/unrelated event does not route to ledger mutation,
- verify raw secrets/signatures are masked or absent,
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
[CURSOR — POS GATEWAY WEBHOOK INBOUND VERIFICATION / EVENT NORMALIZATION DIFF REVIEW]

Review the current diff only.

Do not edit.
Do not auto-fix.
Do not format.
Do not run migrations.
Do not change secrets.
Do not commit.
Do not deploy.

Review against:
- 01270 Overview
- 01280 Logic
- 01290 Module
- 01300 Traceability
- 01310 Handoff Readiness
- allowed file list
- prohibited file list
- restricted register
- provider webhook list
- signature policy
- timestamp/replay/key policy
- payload schema policy
- canonical event schema
- event-to-ledger mutation policy
- terminal state overwrite policy
- quarantine/DLQ policy
- upstream approval/cancel-refund/retry/offline dependency
- required tests
- required evidence

Return:
1. changed_files
2. any_unapproved_file_changes
3. related_logic_rules
4. related_trace_ids
5. forged_webhook_acceptance_risk
6. replay_attack_risk
7. duplicate_approval_risk
8. duplicate_refund_risk
9. duplicate_settlement_risk
10. stale_event_overwrite_risk
11. unknown_event_final_state_risk
12. ambiguous_correlation_risk
13. unverified_route_to_ledger_risk
14. raw_secret_or_signature_leak_risk
15. audit_mutation_or_gap
16. missing_tests
17. missing_evidence
18. recommendation: accept / revise / rollback / split
```

---

## 10. Cursor Mode F — Blocker Extraction

Use when Cursor cannot safely implement.

```text
[CURSOR — POS GATEWAY WEBHOOK INBOUND VERIFICATION / EVENT NORMALIZATION BLOCKER EXTRACTION]

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
5. missing upstream approval/cancel-refund/retry/offline dependency
6. missing provider webhook list
7. missing signature policy
8. missing timestamp/replay/key version policy
9. missing canonical event schema
10. missing event-to-ledger mutation policy
11. missing quarantine/DLQ policy
12. missing test
13. missing evidence
14. missing approval
15. restricted-zone concern
16. recommended next safe action
```

---

## 11. Unsafe Cursor Prompts

Do not use:

```text
Implement webhook handling.
Verify all webhooks.
Normalize provider events.
Route webhooks to ledger.
Fix webhook duplicates.
Handle replay attacks.
Make tests pass.
Update anything needed.
Run migrations if needed.
Commit it.
```

These prompts violate file-level scope and restricted-zone controls.

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
| Provider Policy Checked? | Yes / No / N/A |
| Signature Policy Checked? | Yes / No / N/A |
| Timestamp/Replay/Key Policy Checked? | Yes / No / N/A |
| Canonical Event Schema Checked? | Yes / No / N/A |
| Mutation Policy Checked? | Yes / No / N/A |
| Quarantine/DLQ Policy Checked? | Yes / No / N/A |
| Upstream Dependency Checked? | Approval / Cancel-Refund / Retry-DLQ / Offline-Resync / All / N/A |
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
- [ ] Related Trace ID is specified in 01300.
- [ ] Upstream approval/cancel-refund/retry/offline dependency is known.
- [ ] Provider webhook list is approved or not applicable.
- [ ] Signature policy is approved or not applicable.
- [ ] Timestamp/replay/key version policy is approved or not applicable.
- [ ] Payload schema policy is approved or not applicable.
- [ ] Canonical event schema is approved or not applicable.
- [ ] Event-to-ledger mutation policy is approved or not applicable.
- [ ] Quarantine/DLQ policy is approved or not applicable.
- [ ] Test file is known or test gap is explicitly recorded.
- [ ] Evidence target is known.
- [ ] Human approval exists if restricted zone is touched.
- [ ] Prompt includes all absolute prohibitions.

---

## 14. Summary

Cursor may help the POS Gateway Webhook Inbound Verification / Event Normalization implementation only as a narrow file-level assistant.

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
broadly implement webhook verification / event normalization / ledger routing
```

No Cursor task may bypass:

```text
Overview → Logic → Module → File → Test → Evidence
```
