# 604276_Approval_Cross_Scope_Local_Migration_Replay_Baseline_Blockers.md

Status: Approved (strict boundary)
Lifecycle: Human Approval
Gate Classification: Cross-Scope Baseline Migration Replay Blocker — Stage 3 Human Approval
Runtime Implementation Authorization: Granted — strictly limited to §5 Approved Files
Owner: Human
Last Updated: 2026-07-04

This is a Human Approval document. It authorizes a narrow, specific implementation. It
does not close 604260. It does not authorize 604250 resume. It does not authorize
604310 implementation. It does not create 604277, 604278, or 604279 — those remain
separate documents authored later by Codex, Cursor/Local Verification Runner, and
Claude respectively.

---

## 0. Purpose

Record the Human decision on `604270`'s fix strategy for the two pre-existing baseline
migration replay blockers (`0035`, `0038`) identified via `604260`'s Supabase local
replay attempt, and grant a strictly bounded implementation authorization consistent
with that decision.

---

## 1. Approval Summary

```text
604276 approves:
  1. sql/migrations/0035_verify_schema.sql — a verification-only rewrite that removes
     the parser-invalid inline procedure declaration while preserving all existing
     validation intent. Rewrite is approved in preference to a skip-in-automated-replay
     policy.
  2. sql/migrations/0038_create_toss_webhook_processor_rpc.sql — a single, direct,
     in-place historical correction of the one known syntax defect
     (processing_error := ... -> processing_error = ...), with no other change.

604276 does not approve anything beyond these two corrections. It does not approve
0142 changes, 604250 resumption, 604260 closeout, or 604310 implementation.
```

---

## 2. Approval Source

```text
Reviewed before this decision:
  - 604270 Index — workpacket framing, Preliminary Classifications (0035=B, 0038=A)
  - 604271 ImpactScope — Cursor's investigation; confirmed defect locations and
    dependency mapping (0039 depends on 0038; 0073 shares 0035's pattern)
  - 604272 Overview — why this is cross-scope, not a 604260 implementation failure
  - 604273 Logic — Decision Matrix (Options A/B/C/D); recommended Option D (Hybrid)
  - 604274 TestPlan — TC-BLK-001 through TC-BLK-061, required post-implementation
  - 604275 ChangeContract — change boundary, 8 policy questions, candidate files
  - 604268 Verification (604260) — Addendum "Supabase Local Migration Replay Attempt";
    Updated Verification Result: PARTIAL — BLOCKED_BY_BASELINE_MIGRATION_REPLAY
  - 604269 Audit (604260) — PASS_WITH_GAPS; gap specifically attributed to 0035/0038
    baseline replay blockers, outside 604266 Approval boundary
  - sql/migrations/0035_verify_schema.sql — confirmed L14-28 inline
    `procedure assert_true(...)` inside a DO block DECLARE section
  - sql/migrations/0038_create_toss_webhook_processor_rpc.sql — confirmed L395-399
    `processing_error := 'unknown_toss_status: ' || v_status` inside the unknown-status
    branch of `process_toss_webhook`

Human decision direction, as given for this Approval:
  - Approve 604276.
  - 0038: approve direct in-place one-line historical correction.
  - 0035: approve rewrite in preference to a skip-in-automated-replay policy.
```

---

## 3. Human Decision

```text
1. Option selected from 604273 §9 Decision Matrix: Option D (Hybrid), with the 0035
   branch resolved specifically as REWRITE (not the skip-policy alternative Option D
   also allowed).
2. Divergent-already-applied-state question (604273 §6, 604275 §4/§5): both 0035 and
   0038 are unconditional parse-time syntax errors. Human accepts, for the purpose of
   granting this Approval, that neither file could have been successfully applied as
   currently written in any environment, and therefore authorizes in-place correction
   of both without requiring further proof-of-no-divergence before implementation
   begins. If Codex's implementation (604277) or Cursor's verification (post-604278)
   surfaces any evidence of a prior successful application of either file in its
   current broken form, implementation must stop and this Approval must be revisited.
3. 0073_final_verification.sql (same inline-procedure pattern as 0035, per 604271 §4.4/
   604273 §4): NOT included in this Approval's scope. It is out of scope and forbidden
   under this document (see §6).
4. Allowed Files list narrows 604275 §2's candidate list to exactly the 3 files in §5
   below — no replay-harness/migration-runner config change is approved, since the
   skip-policy branch for 0035 was not selected.
```

---

## 4. Approved Strategy

```text
sql/migrations/0035_verify_schema.sql:
  - Verification-only rewrite.
  - Purpose: make the DO block parser-valid while preserving the existing validation
    intent (same checks, same PASS/FAIL reporting behavior via RAISE NOTICE/WARNING,
    same terminating RAISE EXCEPTION on failure).
  - No persistent object creation. No DDL/DML additions. No seed/data changes.

sql/migrations/0038_create_toss_webhook_processor_rpc.sql:
  - One-line direct historical correction.
  - Change processing_error := 'unknown_toss_status: ' || v_status to
    processing_error = 'unknown_toss_status: ' || v_status.
  - No other logic change of any kind.
```

---

## 5. Approved Files

```text
1. sql/migrations/0035_verify_schema.sql
2. sql/migrations/0038_create_toss_webhook_processor_rpc.sql
3. docs/600000_implementation_lifecycle/604000_workpackets/604270_cross_scope_local_migration_replay_baseline_blockers/604277_Module_Cross_Scope_Local_Migration_Replay_Baseline_Blockers.md
   (to be authored by Codex AFTER implementation, as the self-report of what was
   actually changed in files 1 and 2 — not created by this Approval)

No other file may be created or modified under this Approval.
```

---

## 6. Forbidden Files

```text
The following must NOT be touched under this Approval, in this implementation pass:

sql/migrations/0142_patch_toss_mvp_payment_intent_binding.sql
sql/migrations/0014_create_payment_ledger.sql
sql/migrations/0027_create_payment_intent_rpc.sql
sql/migrations/0052_create_kiosk_session_rpc.sql
sql/migrations/0098_create_payment_confirm_pipeline_rpc.sql
sql/migrations/0103_create_toss_payments_pipeline_rpc.sql
docs/600000_implementation_lifecycle/604000_workpackets/604250_scope_d_00_payment_ledger_confirm_payment_schema_drift_alignment/**
docs/600000_implementation_lifecycle/604000_workpackets/604260_scope_d_00a_toss_mvp_payment_intent_binding_precondition/**
docs/600000_implementation_lifecycle/604000_workpackets/604400_scope_d_01_payment_confirm_idempotency/**

Also forbidden, implicitly, since not listed in §5:
sql/migrations/0073_final_verification.sql (same defect pattern; deferred, not in
  scope of this Approval per §3.3)
Any replay-harness / migration-runner configuration file (skip-policy branch not
  selected)

Exception (explanatory only, not an authorization to modify now): a future 604278
Verification document may READ and REFERENCE 604268/604269 (604260's Verification and
Audit) as evidence of the original replay blocker. It must not MODIFY either document,
and this exception does not apply to the current 604277 implementation stage — no file
under 604260's folder may be touched during that stage.
```

---

## 7. 0035 Approval Contract

```text
- 0035 is verification-only.
- 0035 must not create persistent objects.
- 0035 must not insert/update/delete business data.
- 0035 must not change schema state.
- The existing validation intent must be preserved.
- Inline procedure declaration inside DO DECLARE must be removed.
- Replacement may use direct repeated IF checks, a helper temp function only if
  dropped within the same transaction/DO block (never left as a persistent object),
  or another parser-valid verification-only structure.
- Preferred implementation: parser-valid DO block without nested procedure
  declaration.
- Any persistent helper function is forbidden.
```

---

## 8. 0038 Approval Contract

```text
- 0038 is runtime/load-bearing webhook migration.
- 0038 must not be skipped.
- Only the known syntax defect may be corrected.
- Allowed exact correction:
    processing_error := 'unknown_toss_status: ' || v_status,
  to
    processing_error = 'unknown_toss_status: ' || v_status,
- No webhook business logic changes are approved.
- No status mapping changes are approved.
- No confirm_toss_payment changes are approved.
- No payment_intents changes are approved.
- No payment_ledger changes are approved.
```

---

## 9. Implementation Instructions

```text
For Codex, upon receiving this Approval:

1. Modify ONLY the two files in §5 (items 1 and 2). Do not touch any file in §6.
2. 0035: rewrite the DO block per §4/§7. Verify locally (or note inability to verify
   locally) that the rewritten block still performs every check the original intended,
   with no persistent side effect introduced.
3. 0038: apply the exact one-line correction per §4/§8. Do not modify any other line.
4. After both changes, author 604277_Module_Cross_Scope_Local_Migration_Replay_
   Baseline_Blockers.md as a self-report: what was changed, in which files, with a
   line-level diff summary and an explicit statement that no file outside §5 was
   touched.
5. Do not attempt to run a full Supabase local replay as part of 604277 authorship if
   Codex lacks that environment — that is 604278's responsibility (Cursor / Local
   Verification Runner), not a precondition for writing 604277.
6. 604277 must not assert that 0142 was reached, must not assert any closure status
   for 604260, and must not assert any resumption status for 604250. 604277 reports
   only what Codex implemented in 0035/0038.
```

---

## 10. Verification Requirements

```text
604278 Verification (Cursor / Local Verification Runner), after 604277 exists, must:
  1. Re-run a full clean Supabase local migration replay from 0001 through the highest
     available migration number, on a fresh disposable database
     (catchmenu_local_verify_* naming; container supabase_db_yoonsul_wait_order_handoff),
     per 604274 TestPlan TC-BLK-001.
  2. Confirm 0035 applies without a parse/apply error and its verification checks still
     execute and report PASS/FAIL as intended (604274 TC-BLK-010/011).
  3. Confirm 0038 applies without a parse/apply error, and specifically exercise the
     previously-broken unknown-status branch to confirm the corrected UPDATE succeeds
     (604274 TC-BLK-020/021), and confirm 0039 applies immediately after (TC-BLK-022).
  4. Confirm the replay reaches and applies 0142_patch_toss_mvp_payment_intent_binding.sql
     without error (604274 TC-BLK-030).
  5. Confirm 0142's expected objects exist: toss_payment_requests.payment_intent_id
     column (nullable, FK to payment_intents), the bind_toss_payment_intent() BEFORE
     INSERT trigger, and the renamed *_legacy_604260 functions plus their same-
     signature wrapper replacements (604274 TC-BLK-040).
  6. Run the regression checks in 604274 §9 (TC-BLK-060/061) to confirm no unrelated
     migration in the 0001-0141 range changed behavior as a side effect.
  7. Record all evidence per 604274 §11 (database name, halt point if any, verbatim
     error text, git diff scoped to §5's Approved Files, tool/container versions).
```

---

## 11. Downstream Restrictions

```text
- 604276 does not close 604260.
- 604276 does not authorize 604250 resume.
- 604276 does not authorize 604310 implementation.
- After 604277 implementation, 604278 Verification must rerun Supabase local clean
  replay from 0001 through 0142.
- 604278 must verify that 0142 is reached and applied.
- 604278 must verify payment_intent_id column/FK/functions.
- 604279 Audit must review 604277 and 604278 before any closeout decision.
- Only after 604279 Audit is complete may any separate, later document reconsider
  604260 closeout — and even then, that reconsideration happens in a 604260-owned
  document (e.g. an updated 604268/604269 or a new successor), not in 604270's own
  documents.
- 604250 reauthorization remains a distinct, later Human decision regardless of how
  604270 or 604260 resolve.
```

---

## 12. Rollback / Recovery

```text
If 604278 Verification finds either correction fails its required test:
  1. Revert the specific commit that introduced the failing change (git revert, not an
     ad hoc further edit on top).
  2. Do not mark 604270 closed or attempt a second uncoordinated correction attempt.
  3. Escalate to Human for a revised Approval (a new or amended 604276) before Codex
     re-attempts implementation.
If 604278 finds a divergent-already-applied-state issue that §3.2 anticipated (evidence
that 0035 or 0038 was successfully applied somewhere in its current broken form):
  1. Stop implementation/verification immediately.
  2. Report the finding back to Human; this Approval does not cover that scenario and
     must be revisited before proceeding.
```

---

## 13. Non-Goals

```text
This Approval does not:
  - Redesign 0038's webhook routing, status mapping, or downstream payment/ledger
    behavior.
  - Consolidate 0038's process_toss_webhook with 0103's later redefinition.
  - Address 0073_final_verification.sql's identical inline-procedure pattern (deferred).
  - Introduce a replay-harness skip mechanism for any migration.
  - Decide 604260's or 604250's own closeout/resume questions.
```

---

## 14. Explicitly Not Approved

```text
- 0142 edits of any kind.
- Any change to 0014, 0027, 0052, 0098, or 0103.
- Any file under the 604250, 604260, or 604310 workpacket folders.
- A replay-harness/migration-runner skip policy for 0035 (rewrite was selected instead).
- Any skip of 0038.
- Broad migration cleanup, consolidation, or refactor beyond the two named corrections.
- Forward-patch-only strategy (604273 §5 established this cannot reach 0142 alone;
  it is not what this Approval authorizes).
- 604250 resume, 604260 closeout, or 604310 implementation.
```

---

## 15. Final Approval Decision

```text
APPROVED_FOR_CODEX_IMPLEMENTATION_WITH_STRICT_BOUNDARY

Authorized implementer: Codex
Required post-implementation document: 604277 Module
Required verifier: Cursor / Local Verification Runner
Required auditor: Claude

Scope: exactly the two corrections defined in §4/§7/§8, against exactly the files
listed in §5. No broader authorization is granted.
```

---

## 16. Final Rule

```text
This Approval grants Codex a narrow, strictly bounded authorization to (1) rewrite
0035_verify_schema.sql into a parser-valid, verification-only form preserving its
existing checks, and (2) apply a single one-line historical correction to
0038_create_toss_webhook_processor_rpc.sql. It does not authorize any change to 0142
or to any 604250/604260/604310 document. It does not close 604260 and does not resume
604250. Implementation must produce 604277 Module; verification must produce 604278
Verification rerunning the full Supabase local replay through 0142; and 604279 Audit
must review both before any closeout decision is made anywhere in this lifecycle.
```
