# 604272_Overview_Cross_Scope_Local_Migration_Replay_Baseline_Blockers.md

Status: Draft
Lifecycle: Overview
Gate Classification: Cross-Scope Baseline Migration Replay Blocker — Stage 1 Design
Runtime Implementation Authorization: Not Granted
Owner: TBD
Last Updated: 2026-07-04

This Overview does not authorize implementation. It restates and organizes the
verified facts from `604271` ImpactScope into a design-facing narrative. It does not
approve any SQL, migration, or runtime change to `0035`, `0038`, or `0142`.

---

## 0. Purpose

Explain, for Human decision-making, why **604270** exists as its own cross-scope
workpacket rather than as a sub-item of 604260 or 604250, and what the confirmed
baseline blockers mean for both.

---

## 1. Why This Workpacket Exists

`604260` (Scope D 00A, Toss MVP PaymentIntent Binding Precondition) attempted a
Supabase local + Docker migration replay to obtain the runtime evidence its own
`604269` Audit required. That replay did not fail on anything 604260 authored. It
failed on two **pre-existing baseline migrations** — `0035_verify_schema.sql` and
`0038_create_toss_webhook_processor_rpc.sql` — that predate 604260, 604250, and every
other Scope D workpacket in this lifecycle. Because the blockers sit outside every
existing workpacket's Approval boundary, no existing document (604255, 604265, 604266)
can authorize touching them. 604270 is the minimum-scope container for investigating
and eventually proposing a fix policy for exactly these two files, without expanding
scope into 604260's or 604250's own boundaries.

---

## 2. Relationship To 604260

```text
604260 did not cause 0035/0038 to be broken.
604260's replay attempt is what *discovered* them, by being the first documented
  attempt at a full sequential Supabase local migration replay in this lifecycle.
604260's own implementation (0142) was independently audited in 604269 and found free
  of structural defects; that finding is unaffected by 0035/0038.
604260 remains Not Ready for closeout only because its own required runtime evidence
  (0142 compile/apply/dry-run) cannot be produced while replay is blocked upstream.
```

---

## 3. Confirmed Baseline Blockers

| # | File | Confirmed defect | Verified by |
| --- | --- | --- | --- |
| 1 | `sql/migrations/0035_verify_schema.sql` (L14–28) | Inline `procedure assert_true(...)` declared inside a `DO $$ ... DECLARE` block — PostgreSQL does not permit procedure/function declarations inside a DO block's DECLARE section, only variables | `604268` Addendum, `604269` Audit, `604271` §4, independently re-read in this workpacket |
| 2 | `sql/migrations/0038_create_toss_webhook_processor_rpc.sql` (L397) | `update ... set processing_error := 'unknown_toss_status: ' \|\| v_status` — `:=` is PL/pgSQL assignment syntax, invalid inside a plain SQL `UPDATE ... SET` list; correct form is `processing_error = ...` | `604268` Addendum, `604269` Audit, `604271` §5, independently re-read in this workpacket |

Both defects were independently re-confirmed by direct line-level source read in this
workpacket, not merely re-stated from 604268/604269/604271.

---

## 4. Cross-Scope Nature

```text
0035 and 0038 are not owned by any single Scope D slice:
  - 0035 verifies the cumulative schema after 0001-0034 (pre-Scope-D baseline).
  - 0038 creates the original Toss webhook processor RPC, later partially superseded
    by 0103's redefinition of process_toss_webhook and confirm_toss_payment.
  - Neither file is listed in any 604250, 604260, or 604310 Allowed Files section.
This is why the fix decision cannot be made under 604255, 604265, or 604315 alone --
it needs its own ChangeContract (604275) and its own Human Approval (604276).
```

---

## 5. Why This Is Not A 604260 Implementation Failure

```text
604269 Audit already performed the deepest available static cross-reference of 0142
  against every function/table it calls or renames (0103, 0027, 0013, 0062) and found
  zero structural, signature, or contract defects.
0035 and 0038 predate 0142 by 100+ and 104+ migration numbers respectively.
0142 was never executed in the blocked replay -- there is no evidence, static or
  runtime, that 0142 itself is defective. The absence of evidence is caused entirely by
  what comes before it in migration order, not by 0142's own content.
```

---

## 6. Why This Blocks 604260 Runtime Closeout

```text
604269 Required Fix #1: obtain SQL compile / migration apply / runtime dry-run evidence
  for 0142, or an explicit Human waiver.
A full valid sequential replay is the only path to that evidence that has been
  attempted so far, and it cannot pass 0035 (first) or 0038 (second) to reach 0142.
Until 0035/0038 are resolved by a separately approved fix, OR a Human waiver is granted
  for 604260 instead, 604260 cannot produce the runtime evidence 604269 requires.
```

---

## 7. Why This Blocks 604250 Resume

```text
604250 (Scope D 00, schema drift alignment) already recorded, in its own Index, that
  implementation stopped pending 604260's Toss MVP PaymentIntent Binding precondition.
604260 in turn cannot close without either 0035/0038 resolution or a Human waiver.
Therefore 604250 resume is now transitively blocked behind 604270's outcome as well as
604260's own closeout -- but 604270 itself does not authorize 604250 resume under any
circumstance; that remains a separate, later Human decision even after 0035/0038 are
resolved and 604260 closes.
```

---

## 8. Non-Goals

```text
604270 does NOT:
  - Modify 0035, 0038, or 0142.
  - Resume 604250 implementation.
  - Close 604260.
  - Implement 604310.
  - Create 604276 Human Approval (that is a Human-authored document, not Claude/Cursor).
  - Decide, on its own authority, whether historical in-place edit or forward-patch-only
    is the correct fix strategy -- 604273 Logic proposes options and a recommendation;
    only Human Approval (604276) can select and authorize one.
```

---

## 9. Recommended Path

```text
Design-only recommendation (subject to Human decision in 604276, not self-authorizing):
  1. 0038: because its defect is a single invalid assignment operator inside a function
     body that could not have compiled successfully anywhere as written, a direct,
     minimal historical correction is the lowest-risk path -- but this still requires
     Human Approval before any edit, and the Human should confirm no environment has a
     divergent already-applied copy of 0038 before approving in-place correction.
  2. 0035: because it is verification-only (no persisted DDL/DML), it can either be
     rewritten to valid PL/pgSQL or governed by an explicit replay-harness skip policy
     for automated/CI replay, provided manual verification intent is preserved some
     other way. 0073_final_verification.sql shares the same inline-procedure defect
     pattern and should be reviewed under the same policy once one is approved.
  3. Neither action is authorized by this Overview. See 604273 Logic §9 Decision Matrix
     and 604275 ChangeContract for the full policy question set Human Approval must
     resolve.
```

---

## 10. Final Overview

```text
604270 exists solely to investigate and design a fix policy for two pre-existing,
cross-scope baseline migration replay blockers (0035, 0038) discovered via 604260's
runtime replay attempt. It confirms these blockers are not a 604260 implementation
defect, explains why they transitively block both 604260 closeout and 604250 resume,
and defers the actual fix-strategy decision to 604273 Logic's Decision Matrix and a
future 604276 Human Approval. No SQL, migration, or runtime change is made or
authorized by this document.
```
