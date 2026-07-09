# 604286_Approval_Cross_Scope_0042_Delivery_Order_Intake_Baseline_Replay_Blocker.md

Status: Approved (strict boundary)
Lifecycle: Human Approval
Gate Classification: Cross-Scope Baseline Migration Replay Blocker — Stage 3 Human Approval
Runtime Implementation Authorization: Granted — strictly limited to §5 Approved Files
Owner: Human
Last Updated: 2026-07-05

This is a Human Approval document. It authorizes a narrow, specific implementation.
It does not resolve 604260's or 604250's own status questions. It does not create
604287, 604288, or 604289 — those remain separate documents authored later by Codex,
Cursor/Local Verification Runner, and Claude respectively.

---

## 0. Purpose

Record the Human decision on `604280`'s fix strategy for the `0042` baseline migration
replay blocker exposed after `604270`'s 0035/0038 corrections, and grant a strictly
bounded implementation authorization consistent with that decision.

---

## 1. Approval Summary

```text
604286 approves:
  1. sql/migrations/0042_create_delivery_order_intake_rpc.sql — a single, direct,
     in-place historical correction of the one known syntax defect
     (result_payload := ... -> result_payload = ...), with no other change.

604286 does not approve anything beyond this one correction. It does not approve 0142
changes, delivery migration changes (0057/0074), or any action regarding 604250/604260
resumption or closure.
```

---

## 2. Approval Source

```text
Reviewed before this decision:
  - 604280 Index — workpacket framing, Preliminary Classification (0042 = A)
  - 604281 ImpactScope — Cursor's investigation; confirmed defect location and
    dependency mapping (0043 header-depends on 0042; 0057/0074 call
    intake_delivery_order in function bodies; 0078/0106 later redefine two of 0042's
    three functions)
  - 604282 Overview — why this is cross-scope, not a 604260/604270 implementation
    failure
  - 604283 Logic — Decision Matrix (Options A/B/C/D); recommended Option A (direct
    one-line correction)
  - 604284 TestPlan — TC-042-001 through TC-042-062, required post-implementation
  - 604285 ChangeContract — change boundary, candidate files
  - 604278 Verification (604270) — clean replay reached and applied 0035/0038, then
    halted at 0042
  - 604279 Audit (604270) — PASS_WITH_NEW_BASELINE_BLOCKER; 0042 identified as a new,
    separately-scoped blocker outside the 604276 Approval boundary
  - sql/migrations/0042_create_delivery_order_intake_rpc.sql — confirmed line 396,
    inside catchmenu_integrations.intake_delivery_order's body:
    `result_payload := jsonb_build_object(...)` in a plain SQL
    `update catchmenu_common.idempotency_keys set ...` statement

Human decision direction, as given for this Approval:
  - Approve 604286.
  - 0042: approve direct in-place one-line historical correction.
  - Forward-patch-only and replay-skip alternatives are rejected as insufficient/
    unsafe, per 604283 §5/§6.
```

---

## 3. Human Decision

```text
1. Option selected from 604283 §9 Decision Matrix: Option A — direct one-line
   historical correction.
2. Divergent-already-applied-state question (604283 §7, 604285 §5): the 0042 defect
   is an unconditional parse-time SQL syntax error. Human accepts, for the purpose of
   granting this Approval, that the file could not have been successfully applied as
   currently written in any environment, and therefore authorizes in-place correction
   without requiring further proof-of-no-divergence before implementation begins. If
   Codex's implementation (604287) or Cursor's verification (post-604288) surfaces any
   evidence of a prior successful application of the file in its current broken form,
   implementation must stop and this Approval must be revisited.
3. Allowed Files list narrows 604285 §2's candidate list to exactly the 2 files in §5
   below — no replay-harness/migration-runner config change is approved, since no
   skip policy was selected (and 604283 §6 found a skip policy unsuitable for 0042
   regardless).
```

---

## 4. Approved Strategy

```text
sql/migrations/0042_create_delivery_order_intake_rpc.sql:
  - One-line direct historical correction.
  - Change result_payload := jsonb_build_object(...) to
    result_payload = jsonb_build_object(...), inside the idempotency-completion
    UPDATE statement in catchmenu_integrations.intake_delivery_order.
  - No other logic change of any kind.
```

---

## 5. Approved Files

```text
1. sql/migrations/0042_create_delivery_order_intake_rpc.sql
2. docs/600000_implementation_lifecycle/604000_workpackets/604280_cross_scope_0042_delivery_order_intake_baseline_replay_blocker/604287_Module_Cross_Scope_0042_Delivery_Order_Intake_Baseline_Replay_Blocker.md
   (to be authored by Codex AFTER implementation, as the self-report of what was
   actually changed in file 1 — not created by this Approval)

No other file may be created or modified under this Approval.
```

---

## 6. Forbidden Files

```text
The following must NOT be touched under this Approval, in this implementation pass:

sql/migrations/0142_patch_toss_mvp_payment_intent_binding.sql
sql/migrations/0035_verify_schema.sql
sql/migrations/0038_create_toss_webhook_processor_rpc.sql
sql/migrations/0014_create_payment_ledger.sql
sql/migrations/0027_create_payment_intent_rpc.sql
sql/migrations/0052_create_kiosk_session_rpc.sql
sql/migrations/0098_create_payment_confirm_pipeline_rpc.sql
sql/migrations/0103_create_toss_payments_pipeline_rpc.sql
sql/migrations/0057_create_delivery_platform_rpc.sql
sql/migrations/0074_create_pos_provider_registry.sql
docs/600000_implementation_lifecycle/604000_workpackets/604250_scope_d_00_payment_ledger_confirm_payment_schema_drift_alignment/**
docs/600000_implementation_lifecycle/604000_workpackets/604260_scope_d_00a_toss_mvp_payment_intent_binding_precondition/**
docs/600000_implementation_lifecycle/604000_workpackets/604270_cross_scope_local_migration_replay_baseline_blockers/**
docs/600000_implementation_lifecycle/604000_workpackets/604400_scope_d_01_payment_confirm_idempotency/**

Also forbidden, implicitly, since not listed in §5:
sql/migrations/0078_create_delivery_sync_rpc.sql
sql/migrations/0106_create_delivery_platform_pipeline_rpc.sql
sql/migrations/0073_final_verification.sql
Any replay-harness / migration-runner configuration file
```

---

## 7. 0042 Approval Contract

```text
- 0042 is a load-bearing delivery order intake migration.
- 0042 must not be skipped.
- Only the known syntax defect may be corrected.
- Allowed exact correction:
    result_payload := jsonb_build_object(...)
  to
    result_payload = jsonb_build_object(...)
- No delivery business logic change is approved.
- No function signature change is approved.
- No idempotency table design change is approved.
- No delivery status mapping change is approved.
- No caller/callee change is approved.
- No 0057/0074 change is approved.
```

---

## 8. Implementation Instructions

```text
For Codex, upon receiving this Approval:

1. Modify ONLY the file in §5 item 1. Do not touch any file in §6.
2. Apply the exact one-line correction per §4/§7. Do not modify any other line,
   function signature, grant, or comment in the file.
3. After the change, author 604287_Module_Cross_Scope_0042_Delivery_Order_Intake_
   Baseline_Replay_Blocker.md as a self-report: what was changed, the exact diff, and
   an explicit statement that no file outside §5 was touched.
4. Do not attempt to run a full Supabase local replay as part of 604287 authorship if
   Codex lacks that environment — that is 604288's responsibility (Cursor / Local
   Verification Runner), not a precondition for writing 604287.
5. 604287 must report only what Codex implemented in 0042. It must not assert any
   conclusion about 0142's reachability, or about the status of 604260 or 604250 --
   those are outside 604287's own scope and are 604288/604289's responsibility.
```

---

## 9. Verification Requirements

```text
604288 Verification (Cursor / Local Verification Runner), after 604287 exists, must:
  1. Re-run a full clean Supabase local migration replay from 0001 through the highest
     available migration number, on a fresh disposable database
     (catchmenu_local_verify_* naming; container supabase_db_yoonsul_wait_order_handoff,
     not reusing any previously-failed database), per 604284 TestPlan TC-042-010.
  2. Confirm 0042 applies without a parse/apply error, and specifically exercise the
     previously-broken idempotency-completion UPDATE to confirm it succeeds
     (604284 TC-042-020/021), and confirm 0043 applies immediately after
     (TC-042-022).
  3. Continue the replay past 0042 and confirm whether any further pre-existing
     baseline blocker halts it before 0142 (604284 TC-042-030) -- if one is found, it
     must be recorded with the same rigor as 0042 itself and treated as its own
     separately-scoped follow-up, not fixed under this Approval.
  4. If no further blocker is found, confirm the replay reaches and applies
     0142_patch_toss_mvp_payment_intent_binding.sql without error (604284 TC-042-040).
  5. Confirm 0142's expected objects exist: toss_payment_requests.payment_intent_id
     column (nullable, FK to payment_intents), the bind_toss_payment_intent() BEFORE
     INSERT trigger, and the renamed *_legacy_604260 functions plus their
     same-signature wrapper replacements (604284 TC-042-050).
  6. Run the boundary checks in 604284 §9 (TC-042-060/061/062) to confirm no file
     outside §5 changed, and that 0057/0074/0078/0106 remain unmodified.
  7. Record all evidence per 604284 §11 (database name, halt point if any, verbatim
     error text, git diff scoped to §5's Approved Files, tool/container versions).
```

---

## 10. Downstream Restrictions

```text
- 604286 does not close 604260.
- 604286 does not authorize 604250 resume.
- 604286 does not authorize 604310 implementation.
- After 604287 implementation, 604288 Verification must rerun Supabase local clean
  replay from 0001 through 0142.
- 604288 must verify that 0142 is reached and applied.
- 604288 must verify payment_intent_id column/FK/functions.
- 604289 Audit must review 604287 and 604288 before any closeout decision.
- Any reconsideration of 604260's or 604270's own status happens in a document each of
  those workpackets owns, not in this workpacket's documents.
- 604250 reauthorization remains a distinct, later Human decision regardless of how
  604280 resolves.
```

---

## 11. Rollback / Recovery

```text
If 604288 Verification finds the correction fails its required test:
  1. Revert the specific commit that introduced the failing change (git revert, not an
     ad hoc further edit on top).
  2. Do not represent 604280 as complete or attempt a second uncoordinated correction
     attempt.
  3. Escalate to Human for a revised Approval (a new or amended 604286) before Codex
     re-attempts implementation.
If 604288 finds a divergent-already-applied-state issue that §3.2 anticipated
(evidence that 0042 was successfully applied somewhere in its current broken form):
  1. Stop implementation/verification immediately.
  2. Report the finding back to Human; this Approval does not cover that scenario and
     must be revisited before proceeding.
```

---

## 12. Non-Goals

```text
This Approval does not:
  - Redesign delivery order intake business logic, idempotency-key table design, or
    delivery status mapping.
  - Change the signature of intake_delivery_order, sync_delivery_order_status, or
    reject_delivery_order.
  - Touch 0057, 0074, 0078, or 0106 in any way.
  - Address 0073_final_verification.sql's known defect pattern (out of scope here).
  - Introduce a replay-harness skip mechanism for any migration.
  - Make any determination about 604260's or 604250's own status.
```

---

## 13. Explicitly Not Approved

```text
- Any edit to 0142.
- Any change to 0035, 0038, 0014, 0027, 0052, 0098, or 0103.
- Any file under the 604250, 604260, 604270, or 604310 workpacket folders.
- Any edit, of any kind, to 0057 or 0074.
- Treating 0042 as something a replay harness may bypass instead of correcting.
- A forward-patch-only strategy in place of the direct correction in §4 -- 604283 §5
  established that a forward-patch file is unreachable by a sequential replay halted
  at 0042, so it cannot substitute for the correction this Approval authorizes.
- Any broader cleanup or refactor of delivery-related migrations beyond the single
  line named in §4/§7.
- Any statement, in 604287 or elsewhere under this Approval, that 604260 or 604250's
  own status has changed as a result of this workpacket alone.
```

---

## 14. Final Approval Decision

```text
APPROVED_FOR_CODEX_IMPLEMENTATION_WITH_STRICT_BOUNDARY

Authorized implementer: Codex
Required post-implementation document: 604287 Module
Required verifier: Cursor / Local Verification Runner
Required auditor: Claude

Scope: exactly the one correction defined in §4/§7, against exactly the files listed
in §5. No broader authorization is granted.
```

---

## 15. Final Rule

```text
This Approval grants Codex a narrow, strictly bounded authorization to apply a single
one-line historical correction to 0042_create_delivery_order_intake_rpc.sql. It does
not authorize any change to 0142, 0057, 0074, or any 604250/604260/604270/604310
document. Implementation must produce 604287 Module; verification must produce 604288
Verification rerunning the full Supabase local replay through 0142 (or recording
whatever further baseline blocker, if any, halts it first); and 604289 Audit must
review both before any closeout decision is made anywhere in this lifecycle.
```
