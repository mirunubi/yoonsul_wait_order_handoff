# 604399_Approval_Gate_SQL_Migration_Replay_Blocker_A2_0035_Verification_Rewrite_Disposition.md

Status: Complete
Lifecycle: Human Approval Gate
Gate Classification: Group A2 — 0035 Verification Rewrite SQL Residue — Stage 3 Human Approval Gate
Runtime Implementation Authorization: Not Granted By This Document
Owner: Human (정영석)
Last Updated: 2026-07-05

This is a documentation-only Approval Gate. It approves the A2 (0035) sub-batch
DISPOSITION DIRECTION only. It does not itself stage or commit
sql/migrations/0035_verify_schema.sql. It performs no SQL edit, migration edit,
reset, discard, rename, staging, or commit. It does not create or modify 0069
Analysis and does not resume Scope D mainline.

---

## 1. Approval Gate Summary

```text
This document approves KEEP_AND_APPROVE_FOR_SEPARATE_SQL_COMMIT as the
disposition direction for the A2 sub-batch (0035_verify_schema.sql only),
consistent with the 604391 five-way Group A split and the 604392 approval
that only A1 was authorized for immediate action. A2 remains its own
standalone, single-file track -- this Gate authorizes preparation
(604400 Implementation) toward a future, separately-approved staging/commit
decision; it does not authorize that staging/commit itself.

Final approval decision:
```

```text
APPROVED_FOR_A2_0035_VERIFICATION_REWRITE_DISPOSITION_ONLY_WITH_HIGH_RISK_SINGLE_FILE_SQL_BOUNDARY
```

```text
Authorized implementer (604400 only):
```

```text
Codex
```

```text
Human owner:
```

```text
정영석
```

---

## 2. Current State Basis

```text
- A1 SQL micro-fix (0038, 0042, 0063, 0068) is committed: 70181253
  "fix: apply A1 SQL micro-fix residue corrections".
- 604391-604395 A1 disposition documentation is committed.
- 604500-604504 (store-level no-payment KDS release policy) plus 0143 is
  committed: cb2147ce "feat: add no-payment KDS release policy".
- sql/migrations/0035_verify_schema.sql remains tracked modified (M),
  unstaged, with diff +681/-187, exactly as 604398 recorded.
- git diff --check passes. No file is currently staged.
- Scope D mainline remains blocked; 0069 Analysis remains deferred.
- This Approval Gate independently re-confirmed the current working-tree
  state immediately before being written: 0035's diff stat is unchanged
  (681 insertions, 187 deletions) since 604398 was authored, the remaining
  A3-A5 and Group B/C/D/E residue paths are unchanged, tools residue is
  unchanged, and the staging area remains empty.
```

---

## 3. Input Documents Reference

```text
604391_Analysis_SQL_Migration_Replay_Blocker_Group_Disposition.md
  -- adopted: A2 (0035) is its own deferred sub-batch, HIGH risk, requiring
  its own standalone Approval Gate before any action.
604392_Approval_Gate_SQL_Migration_Replay_Blocker_Group_Disposition.md
  -- adopted: only A1 was authorized for immediate action; A2-A5 remain
  deferred to their own future gates.
604395_Audit_SQL_Migration_Replay_Blocker_A1_Micro_Fix_Disposition.md
  -- adopted: A1 track closed; A2-A5 confirmed still deferred and untouched.
604398_Analysis_SQL_Migration_Replay_Blocker_A2_0035_Verification_Rewrite_Disposition.md
  -- accepted as the basis for this Approval Gate without re-analysis. Its
  key findings, adopted here:
    - 0035 is verification-only in intent (no persisted schema objects) but
      executes as a real, sequence-position migration during replay -- a
      broken 0035 blocks 0036+ at parse time, not merely at check time.
    - HEAD (d482163e) contains a nested `procedure assert_true` declared
      inside a DO block's DECLARE section, which PostgreSQL does not permit
      -- this is an unconditional parse/compile-time syntax error, not a
      runtime check failure.
    - The working-tree rewrite replaces the nested-procedure pattern with
      inline PASS/FAIL counters and RAISE NOTICE/WARNING/EXCEPTION logic,
      preserving the original verification intent without invalid syntax.
    - This rewrite direction was already approved in principle by 604276
      (in the 604270 lane), which explicitly rejected a skip-in-automated-
      replay policy for this file; 604278 recorded 85 PASS / 0 FAIL against
      the same rewrite pattern as evidence (not itself repo-commit
      authorization).
    - Reverting the working tree to HEAD would reintroduce the parse-time
      failure and stop replay at position 0035, before 0036 and everything
      after it, including before 0038 (now committed) and well before 0069.
    - 0035 is not a discard candidate. The only sound directions are KEEP
      (rewrite, then verify, then commit) or a fresh Human-approved
      skip-policy decision -- and 604276 already rejected skip once for
      this exact file, so re-opening skip requires new, explicit
      justification, not assumed default.
    - Risk remains HIGH: largest remaining Group A diff, full-chain
      verification semantics, requires Human diff review and a
      replay/parse-gate re-verification before commit.
```

---

## 4. Approved Disposition Direction

```text
1. KEEP_AND_APPROVE_FOR_SEPARATE_SQL_COMMIT is the approved direction for
   0035's current working-tree rewrite. DISCARD to HEAD is explicitly NOT
   approved -- it would reintroduce a known, documented parse-time replay
   blocker. Re-opening a skip-in-automated-replay policy is NOT approved by
   this Gate; 604276 already rejected that branch for this file, and any
   future re-proposal of skip-policy requires its own new, explicit Human
   decision with fresh justification, not a default fallback here.
2. This approval covers DISPOSITION DIRECTION and PREPARATION only. It does
   NOT itself authorize staging or committing 0035. That remains a
   separate, later, explicit Human selective-staging decision, made only
   after 604400-604402 (or 604403 Audit, if the numbering track extends
   that far) closes.
3. A2 is a single-file, single-commit track. sql/migrations/0035_verify_
   schema.sql is the ONLY file approved for any disposition action under
   this Gate.
```

---

## 5. Approved Scope

```text
A. Approved file (exactly 1 file):

   sql/migrations/0035_verify_schema.sql

B. Approved 604400 Implementation scope: independently re-confirm the
   exact diff content (structure, PASS/FAIL/EXCEPTION semantics, absence of
   any nested-procedure pattern in the rewritten version), record it for
   traceability, and prepare (but not execute) the file for a future
   selective staging/commit decision.

C. Required subsequent lifecycle documents (all in the canonical 604300
   folder):
   604400_Implementation_SQL_Migration_Replay_Blocker_A2_0035_Verification_Rewrite_Disposition.md
   604401_Verification_SQL_Migration_Replay_Blocker_A2_0035_Verification_Rewrite_Disposition.md
   604402_Audit_SQL_Migration_Replay_Blocker_A2_0035_Verification_Rewrite_Disposition.md
```

---

## 6. Required Replay/Parse-Gate Verification (For A Future Stage, Not This Gate)

```text
Before any actual staging/commit of 0035 is considered (not authorized by
this Gate), a later verification stage must confirm, at minimum:

- The rewritten DO block parses and compiles without error (no nested
  procedure declaration inside a DECLARE section, or any other invalid
  construct).
- The functional check pattern still exercises the same set of schema/
  catalog assertions as the original intent, using the inline PASS/FAIL/
  RAISE NOTICE-WARNING-EXCEPTION structure.
- A re-run against a representative environment reproduces a result
  consistent with the 604278 baseline (85 PASS / 0 FAIL), or any
  discrepancy from that baseline is explicitly reported and explained, not
  silently accepted.
- Sequential replay from a clean state can proceed past position 0035 into
  0036+ without a parse-time abort.

This Gate does not authorize running that replay/verification against a
live database; it only establishes what a future verification stage must
demonstrate before staging/commit can be separately authorized.
```

---

## 7. Explicitly Excluded From This Scope

```text
- sql/migrations/0038_create_toss_webhook_processor_rpc.sql,
  0042_create_delivery_order_intake_rpc.sql,
  0063_patch_core_rpc_i18n_diagnostics.sql,
  0068_create_realtime_edge_rpc.sql
  -- A1, already committed (70181253); no further modification or staging.
- sql/migrations/0046_create_context_builder_rpc.sql -- A3, deferred.
- sql/migrations/0065_create_security_isolation_rpc.sql -- A4, deferred.
- sql/migrations/0066_create_ledger_integrity_rpc.sql and
  0067_create_cron_scheduler_rpc.sql -- A5, deferred, sequential-only,
  never combined with each other or with A2.
- sql/migrations/0138_patch_integration_functions.sql -- Group B, excluded.
- sql/migrations/0142_patch_toss_mvp_payment_intent_binding.sql -- Group D,
  excluded.
- 024/0024, 030/0030, 032/0032 zero-pad paired-pending paths -- Group C,
  excluded.
- 0136, 0139, 0141, seed_yoonsul_menu.sql -- Group E, excluded.
- sql/migrations/0143_add_no_payment_kds_release_policy.sql -- already
  committed (cb2147ce); not part of this track and not to be re-touched.
- tools/* residue -- excluded, separate future tooling track.
- Runtime code -- excluded.
- Flutter/KDS UI -- excluded.
- POS integration -- excluded.
- 0069 Analysis -- must not be created.
- Scope D mainline -- must not be resumed.
```

---

## 8. Mandatory Preservation Rules

```text
604400-604402 must preserve:

- Every other SQL/migration residue path (A3, A4, A5, Groups B/C/D/E)
  exactly as currently present, untouched by this track.
- The 4 tools/* residue paths, exactly as currently present, untouched.
- The already-committed A1 files (0038, 0042, 0063, 0068) and the
  already-committed 0143, unmodified and unre-staged.
- 604300_Index, 604306_NavigationMap, 604001 parent NavigationMap, and
  every previously-closed track document, unmodified.
- 0069 Analysis in its deferred, uncreated state.
- Scope D mainline in its current not-resumed state.
- The empty staging area.
```

---

## 9. Final Approval Decision

```text
APPROVED_FOR_A2_0035_VERIFICATION_REWRITE_DISPOSITION_ONLY_WITH_HIGH_RISK_SINGLE_FILE_SQL_BOUNDARY
```

---

## 10. Explicitly Forbidden Work

```text
- Modification of any SQL/migration file other than 0035.
- Staging of any SQL/migration file other than 0035, and no staging of
  0035 itself under this Gate.
- SQL/migration reset, discard, or rename of any residue path.
- SQL/migration rename of any kind.
- Combining A2 with A3, A4, or A5 in any single Approval, Implementation,
  Verification, or Audit document, or any future commit.
- Combining A2 with 0138, 0142, the zero-pad paired-pending group, or the
  unapproved-new-migration/seed group in any single document or commit.
- tools/* modification of any kind.
- tools/* staging of any kind.
- Runtime code modification of any kind.
- Creation or modification of 0069 Analysis.
- Resuming Scope D mainline (604260, 604250, 604400/604310, 604316) in any
  form.
- Staging of any file under this Gate.
- Any git commit under this Gate.
```

---

## 11. Required 604400 Implementation Output

```text
Codex must create:

604400_Implementation_SQL_Migration_Replay_Blocker_A2_0035_Verification_Rewrite_Disposition.md

The H1 must exactly match the full filename including .md.

604400 must record:

1. Independent re-confirmation of 0035's exact working-tree diff (structure,
   size, and the specific rewrite pattern: inline PASS/FAIL counters and
   RAISE NOTICE/WARNING/EXCEPTION, replacing the invalid nested-procedure
   declaration).
2. Confirmation that no other SQL/migration file was touched.
3. Confirmation that A1 (already committed), A3, A4, A5, and Groups B/C/D/E
   remain untouched.
4. Confirmation that tools/*, runtime code, and Flutter were not modified.
5. Confirmation that 0069 Analysis was not created and Scope D mainline was
   not resumed.
6. Confirmation that no staging or commit was performed.
```

---

## 12. Required 604401 Verification

```text
The verifier must create:

604401_Verification_SQL_Migration_Replay_Blocker_A2_0035_Verification_Rewrite_Disposition.md

604401 must independently verify:

- 604400 exists with H1 matching its filename.
- 0035's working-tree diff remains exactly as documented, unmodified by
  604400.
- No other SQL/migration file, tools file, or runtime file was touched.
- 0069 Analysis was not created; Scope D mainline was not resumed.
- No file is staged.
- git diff --check passes.
```

---

## 13. Required 604402 Audit

```text
The independent auditor must create:

604402_Audit_SQL_Migration_Replay_Blocker_A2_0035_Verification_Rewrite_Disposition.md

604402 must decide whether the A2 disposition-preparation record is
accepted, without expanding scope into A3-A5, Groups B-E, tools remediation,
0069 Analysis, or Scope D mainline resumption, and without treating its own
ACCEPT verdict as authorization to actually stage or commit 0035.
```

---

## 14. Commit Readiness Note

```text
This Approval Gate does not authorize staging or commit of 0035 or any
other residue path. Any future actual `git add`/`git commit` of 0035
requires its own distinct, explicit Human staging/commit authorization,
issued after 604402 Audit (or a further Audit if the track extends) accepts
the preparation record, and must not bundle any file from A1 (already
committed), A3, A4, A5, Groups B-E, or tools residue. That future
authorization must also require the replay/parse-gate verification outcome
described in §6 as a precondition.
```

---

## 15. Final Boundary Decision

```text
APPROVED_FOR_A2_0035_VERIFICATION_REWRITE_DISPOSITION_ONLY_WITH_HIGH_RISK_SINGLE_FILE_SQL_BOUNDARY
```

```text
Approved next artifact:

604400_Implementation_SQL_Migration_Replay_Blocker_A2_0035_Verification_Rewrite_Disposition.md

followed by:

604401_Verification_SQL_Migration_Replay_Blocker_A2_0035_Verification_Rewrite_Disposition.md
604402_Audit_SQL_Migration_Replay_Blocker_A2_0035_Verification_Rewrite_Disposition.md

A3 (0046), A4 (0065), and A5 (0066 then 0067, sequential) remain deferred to
their own separate future Approval Gates. Groups B, C, D, E, and tools
residue remain excluded. 0069 Analysis remains deferred. Scope D mainline
remains blocked. Staging/commit of 0035 remains a separate, later, explicit
Human decision, not authorized here.
```
