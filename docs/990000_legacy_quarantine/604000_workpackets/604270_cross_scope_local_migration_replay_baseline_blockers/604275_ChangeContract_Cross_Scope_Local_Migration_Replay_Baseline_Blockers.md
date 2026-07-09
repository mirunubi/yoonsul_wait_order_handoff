# 604275_ChangeContract_Cross_Scope_Local_Migration_Replay_Baseline_Blockers.md

Status: Draft
Lifecycle: ChangeContract
Gate Classification: Cross-Scope Baseline Migration Replay Blocker — Stage 1 Design
Runtime Implementation Authorization: Not Granted
Owner: TBD
Last Updated: 2026-07-04

**This document does not approve implementation.** It defines the candidate change
boundary and the policy questions Human Approval (`604276`, not yet created) must
resolve before any SQL, migration, or runtime change is made to `0035` or `0038`.
`0035`/`0038` must not be modified until `604276` Human Approval is created.

604260 must not be closed by this document. 604250 must not resume by this document. A
604276 Human Approval is required before implementation.

---

## 0. Purpose

Give Human Approval a complete, self-contained boundary and policy-question set for
deciding how (not whether, in isolation of that decision) `0035` and `0038` should be
corrected so that full valid sequential migration replay can reach `0142`.

---

## 1. Change Boundary

```text
In scope for a FUTURE authorized change (not this document):
  - sql/migrations/0035_verify_schema.sql
  - sql/migrations/0038_create_toss_webhook_processor_rpc.sql
  - Possibly sql/migrations/0073_final_verification.sql (same defect pattern, per
    604271 §4.4 and 604273 §4 -- Human must decide whether to include it in the same
    approval or defer to a follow-up)
  - A migration-runner/replay-harness configuration file, ONLY if Option C or D's
    skip-policy branch is selected for 0035 (604273 §7)

Out of scope, unconditionally:
  - sql/migrations/0142_patch_toss_mvp_payment_intent_binding.sql
  - Any 604250, 604260, or 604310 document or Approval
  - Any Flutter, Edge Function, Python, or config file
  - Any file not explicitly named in a future 604276 Allowed Files list
```

---

## 2. Approved Files Candidate

```text
CANDIDATE ONLY -- not authorized by this document. Final Allowed Files list is set by
604276 Human Approval, which may narrow (but should not widen) this candidate list:

  1. sql/migrations/0035_verify_schema.sql          (rewrite OR skip-policy, per 604276)
  2. sql/migrations/0038_create_toss_webhook_processor_rpc.sql  (one-line correction)
  3. [conditional] sql/migrations/0073_final_verification.sql   (same pattern; Human
     decides whether in-scope now or deferred)
  4. [conditional] replay-harness/migration-runner config       (only if a skip policy
     for 0035 is selected)
  5. A future 604277 Module document (implementation self-report, authored after 604276)
  6. A future 604278 Verification document (post-fix replay re-run evidence)
```

---

## 3. Forbidden Files

```text
The following must NOT be touched under any 604270/604276 authorization:
  - 0142_patch_toss_mvp_payment_intent_binding.sql
  - Any 0014, 0027, 0098, 0103 content (append-only historical migrations already
    governed by 604250/604300's own boundaries -- 604270 does not reopen them)
  - 604250, 604255, 604256, 604257 (Scope D 00 documents)
  - 604260-604269 (Scope D 00A documents) -- 604270 may READ these as evidence but
    must not edit them
  - 604310-604319 (Scope D 01 documents)
  - Any Flutter/Dart, Edge Function (Deno/TS), Python, or CI/CD config file
```

---

## 4. 0035 Change Contract

```text
Candidate action (Human selects, per 604273 §9 Decision Matrix): rewrite the DO block
  to valid PL/pgSQL (e.g., extract assert_true to a standalone, separately-created
  helper function, or restructure using nested anonymous blocks without an inline
  procedure declaration), OR adopt an explicit, logged skip policy for automated/CI
  replay while preserving the verification intent through some other mechanism.

Constraint: whichever form is chosen, the corrected 0035 must remain verification-only
  -- it must not gain any CREATE/ALTER/INSERT/UPDATE/DELETE/DROP side effect it did not
  have before, since that would silently expand this workpacket's blast radius beyond
  what 604276 is asked to approve.

Constraint: Human must explicitly confirm, before approving an in-place edit, whether
  any environment has ever successfully applied the current (broken) 0035 file as-is.
  Per 604273 §2 and §6, this is believed not possible given the parse error, but that
  belief must be confirmed by Human, not assumed by Claude/Cursor/Codex.
```

---

## 5. 0038 Change Contract

```text
Candidate action (Human selects, per 604273 §9 Decision Matrix): correct line ~397 of
  sql/migrations/0038_create_toss_webhook_processor_rpc.sql from
  `processing_error := 'unknown_toss_status: ' || v_status` to
  `processing_error = 'unknown_toss_status: ' || v_status`, in place, with no other
  change to the file's logic, tables touched, or function signatures.

Constraint: this is a single-token class of correction (`:=` -> `=`). Any future 604277
  Module report that reflects a broader rewrite of 0038 beyond this one assignment
  operator is out of the boundary this ChangeContract anticipates and would require a
  ChangeContract revision, not a same-boundary Module report.

Constraint: 0038 must NOT be skipped in place of a fix (604273 §7) -- it creates
  process_toss_webhook and verify_toss_signature, which 0039 and later migrations
  depend on and assert exist; skipping would silently remove load-bearing objects from
  the replayed schema. 0038 is not safely skippable for 604260 webhook-convergence
  runtime closeout, consistent with 604268/604269's own findings.

Constraint: Human must explicitly confirm, before approving an in-place edit, whether
  any environment has ever successfully applied the current (broken) 0038 file as-is
  (e.g. under check_function_bodies = off). Per 604273 §3 and §6, this is believed not
  possible given the parse-time validation default, but that belief must be confirmed
  by Human, not assumed.
```

---

## 6. Migration History Policy

```text
Policy Question 1 (may 0035/0038 be edited in place?): Not by this document. This
  ChangeContract identifies it as a candidate action requiring explicit 604276 Human
  Approval, narrower than the general append-only rule would otherwise allow, because
  both defects are unconditional parse-time errors (604273 §6). It is not self-
  authorizing.

Policy Question 2 (risk of editing an already-applied historical migration): the
  general risk is environment divergence -- an environment that already has the object
  from the original file would not automatically pick up a corrected rewrite, and a
  fresh bootstrap from repo would silently differ from that already-provisioned
  environment. This specific risk is reduced, but not eliminated, for 0035/0038 because
  both are unconditional parse errors with no plausible successful prior application
  (604273 §6) -- Human confirmation of this is still required (see §4/§5 constraints
  above), not assumed.

Policy Question 3 (is a historical edit needed for clean replay / CI / new developer
  bootstrap?): Yes, for 0038 -- per §5 above and 604273 §5/§7, there is no viable
  alternative that both (a) preserves the intended webhook-processing objects and (b)
  gets a strict sequential replay runner past 0038's file-level parse failure, other
  than correcting the file (or an equivalent skip+recreate mechanism that Human must
  separately evaluate and has not been proposed as viable in 604273). For 0035, a
  historical edit is one valid option but not the only one (see Policy Question 6/7).
```

---

## 7. Replay Policy

```text
Policy Question 4 (can forward patch migrations alone solve this?): No, not alone.
  Per 604273 §5, a strict sequential replay runner halts at the first file-level parse/
  apply failure and never reaches any later-numbered file, including a new forward
  patch. A forward-patch-only strategy is not proposed as sufficient by this document.

Policy Question 5 (0038 fails to parse at apply -- how could a forward patch after 0038
  ever run?): It cannot, under the replay model in 604273 §1, unless paired with (a) a
  runner-level skip specifically for 0038 (not proposed as viable for 0038, per §5
  above and 604273 §7), (b) evidence of some already-applied environment that bypassed
  0038's defect by hand (not evidenced in this lifecycle), or (c) direct correction of
  0038 itself (§5 above). This ChangeContract's candidate action for 0038 is (c).

Policy Question 6 (is 0035 skippable in the replay harness, since it is verification-
  only?): Yes, as one candidate option -- 0035 has no persisted side effects (604271
  §4.2, 604273 §2), so an explicit, logged skip for automated/CI replay is a defensible
  alternative to rewriting it, provided the loss of its schema-integrity assertions in
  automated runs is an explicit, accepted tradeoff, not a silent one.

Policy Question 7 (is 0038 forbidden to skip because it is a runtime/webhook RPC
  creator?): Yes. Per §5 above and 604273 §7, 0038 must not be skipped as a substitute
  for a fix; it creates objects later migrations and 604260's own webhook-convergence
  narrative depend on. Skipping 0038 is not proposed as an option anywhere in this
  document or in 604273's Decision Matrix.

Policy Question 8 (final recommendation: direct historical correction, replay harness
  policy, or hybrid?): Hybrid (604273 §9, Option D) -- direct in-place correction for
  0038 (§5 above), and either rewrite or an explicit skip-in-automated-replay policy
  for 0035 (§4 above), decided by Human in 604276. This ChangeContract does not select
  the final option on its own authority; it presents Option D as the recommended
  candidate consistent with 604273's analysis.
```

---

## 8. Runtime Verification Contract

```text
Once 604276 authorizes a specific fix, the corresponding tests in 604274 TestPlan
(TC-BLK-001 through TC-BLK-061) define the required evidence before any closeout claim
is made. At minimum: full sequential replay must reach and apply 0142 without error,
and 0142's own object/runtime checks (604274 §7) must pass, before 604260's own
Verification/Audit documents may be updated to reflect closure of the runtime-evidence
gap.
```

---

## 9. Downstream Re-Enablement Contract

```text
Passing 604274's tests authorizes ONLY:
  - A future, separate update to 604260's own 604268 Verification (or a new 604278
    Verification under this workpacket) recording the new evidence.
  - A future, separate 604260 re-audit (updating 604269 or issuing a new audit) that
    may then reconsider 604260 closeout on its own merits.
It does NOT, by itself:
  - Close 604260 (a separate 604260-owned decision, informed by but not made by 604270).
  - Resume 604250 (a separate, later Human reauthorization decision, per 604271 §"Owner
    rule" and 604272 §7 -- 604250 must not resume automatically as a consequence of
    604270's or 604260's closure).
  - Authorize 604310 implementation or 604316 creation.
```

---

## 10. Rollback Contract

```text
If a 604276-authorized fix to 0035/0038 is applied and TestPlan §9 (Regression Checks)
or any earlier test in 604274 fails:
  - The fix must be reverted (git revert of the specific commit, not a fresh undo edit)
    rather than patched further in place mid-investigation.
  - 604270 stays open; a revised ChangeContract or Approval is required before retrying.
  - No partial fix (e.g., 0038 corrected but 0035 left broken, or vice versa) may be
    represented as closing 604270 -- closure requires the full authorized scope to pass.
```

---

## 11. Human Approval Requirements

```text
604276 Human Approval, when created, must at minimum:
  1. Select one option from 604273 §9 Decision Matrix (A/B/C/D) or an explicit variant.
  2. Confirm or refute the "no plausible divergent already-applied 0035/0038 state"
     assumption in §4/§5 above.
  3. Set the final Allowed Files list (may narrow but not widen §2's candidate list).
  4. Decide whether 0073_final_verification.sql is in scope now or deferred.
  5. Explicitly state that it does not, by itself, close 604260 or resume 604250 (per
     §9 above), unless a separate, explicit decision to do so is also documented there.
Only after 604276 exists may Codex or any implementer touch 0035/0038. No 604276
Approval exists at the time this ChangeContract is written.
```

---

## 12. Final ChangeContract

```text
This document does not approve implementation. 0035 and 0038 must not be modified
until 604276 Human Approval is created and names the authorized option.

604260 must not be closed by this document. 604250 must not resume by this document.

This ChangeContract's role is limited to presenting the change boundary, the candidate
files, and the 8 policy questions (§6-§7) Human Approval must resolve, plus a
recommended candidate (Hybrid / Option D) that Human may accept, modify, or reject.
```
