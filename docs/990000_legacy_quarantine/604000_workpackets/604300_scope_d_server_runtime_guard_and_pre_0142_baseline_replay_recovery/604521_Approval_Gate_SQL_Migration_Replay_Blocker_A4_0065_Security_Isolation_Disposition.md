# 604521_Approval_Gate_SQL_Migration_Replay_Blocker_A4_0065_Security_Isolation_Disposition.md

Status: Complete
Lifecycle: Human Approval Gate
Gate Classification: Group A4 — 0065 Security Isolation Replay Blocker — Stage 3 Human Approval Gate
Runtime Implementation Authorization: Not Granted By This Document
Owner: Human (정영석)
Last Updated: 2026-07-06

This is a documentation-only Approval Gate. It approves the A4 (0065) sub-batch
DISPOSITION DIRECTION only. It does not itself stage or commit
sql/migrations/0065_create_security_isolation_rpc.sql. It performs no SQL
edit, migration edit, reset, discard, rename, staging, or commit. It does not
create or modify 0069 Analysis and does not resume Scope D mainline.

---

## 1. Approval Gate Summary

```text
This document approves KEEP_AND_APPROVE_FOR_SEPARATE_SQL_COMMIT as the
disposition direction for the A4 sub-batch
(0065_create_security_isolation_rpc.sql only), consistent with the 604391
five-way Group A split and the 604392 approval that only A1 was authorized
for immediate action at that time. A2 (0035) and A3 (0046) have since been
separately approved and committed; A4 is now taken up in its own turn per
that same split. A4 remains its own standalone, single-file track -- this
Gate authorizes preparation (604522 Implementation) toward a future,
separately-approved staging/commit decision; it does not authorize that
staging/commit itself.

Final approval decision:
```

```text
APPROVED_FOR_A4_0065_SECURITY_ISOLATION_REPLAY_BLOCKER_DISPOSITION_ONLY_WITH_HIGH_RISK_SINGLE_FILE_SQL_BOUNDARY
```

```text
Authorized implementer (604522 only):
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
- A1 SQL micro-fix (0038, 0042, 0063, 0068) is committed: 70181253.
- A2 SQL (0035_verify_schema.sql) is committed: f89c70e0.
- A3 SQL (0046_create_context_builder_rpc.sql) is committed: 6847d69b
  "fix: correct 0046 context builder aggregation limits".
- The 604506-604510 metadata index/navigation sync is committed: fc7797c5.
- sql/migrations/0065_create_security_isolation_rpc.sql remains tracked
  modified (M), unstaged, with diff +388/-146, exactly as 604520 recorded.
- git diff --check passes. No file is currently staged.
- Scope D mainline remains blocked; 0069 Analysis remains deferred.
- This Approval Gate independently re-confirmed the current working-tree
  state immediately before being written: 0065's diff stat is unchanged
  (388 insertions, 146 deletions) since 604520 was authored, A1/A2/A3 no
  longer appear in the residue list (all committed), the remaining A5 and
  Group B/C/D/E residue paths are unchanged, tools residue is unchanged,
  and the staging area remains empty.
```

---

## 3. Input Documents Reference

```text
604391_Analysis_SQL_Migration_Replay_Blocker_Group_Disposition.md
  -- adopted: A4 (0065) is its own deferred sub-batch, HIGH risk, a
  substantive inline-procedure removal / guard refactor (not a
  micro-fix), requiring its own standalone Approval Gate before any action.
604392_Approval_Gate_SQL_Migration_Replay_Blocker_Group_Disposition.md
  -- adopted: only A1 was authorized for immediate action at that stage;
  A2-A5 were deferred to their own future gates. A2 and A3 have since been
  separately approved and committed; A4 is now taken up in its own turn.
604520_Analysis_SQL_Migration_Replay_Blocker_A4_0065_Security_Isolation_Disposition.md
  -- accepted as the basis for this Approval Gate without re-analysis. Its
  key findings, adopted here:
    - 0065 contains TWO independent, confirmed HEAD parse-time blockers.
      Primary: a nested `procedure add_check(...)` declared inside the
      DECLARE section of `catchmenu_audit.run_isolation_audit` -- PL/pgSQL
      DECLARE sections permit variables only, so this is the same defect
      class already resolved for 0035 (604276/604277 lineage), producing a
      "syntax error at or near \"text\"" parse failure. Secondary: an
      aggregate-inline `jsonb_agg(order_id limit 5)` inside
      `catchmenu_audit.scan_cross_tenant_risk` -- the same aggregate-LIMIT
      placement defect class already resolved for 0046 (604350-series
      lineage).
    - The working-tree fix addresses both blockers: (a) removes the nested
      `procedure add_check(...)` declaration and replaces all 13
      `call add_check(...)` sites with equivalent explicit IF/ELSE blocks
      that mutate the same accumulator variables (v_total, v_passed,
      v_failed, v_checks, v_critical, v_risk_score) inline, following the
      already-approved Candidate A pattern from 604343; (b) wraps the
      `order_id` sample-collection query in a subquery with `ORDER BY` +
      `LIMIT 5`, aggregating the already-limited result via an outer
      `jsonb_agg(sample.order_id)`, following the same subquery-wrapper
      pattern already approved and committed for 0046 (604513 §6).
    - The change touches the security-domain categories of RLS, tenant
      isolation, audit guard, SECURITY DEFINER preservation, and
      exception/risk-score accumulation. JWT claim handling is confirmed
      NOT applicable to this file -- 0065 uses `current_tenant_id()` and
      explicit tenant/store parameters, not JWT claims directly.
    - Reverting the working tree to HEAD would reintroduce both parse-time
      failures and halt sequential replay at position 0065, before 0066
      and everything after it (including 0067, 0068, 0069, and 0142) --
      and would leave tenant-isolation audit, RLS coverage scanning, and
      cross-tenant risk scanning permanently non-compiling in baseline
      replay, not merely reverted to a neutral prior state.
    - 0065 is not a discard candidate: HEAD is broken, not merely
      suboptimal, and a skip-in-automated-replay policy is not applicable
      because 0065 creates real runtime security RPC objects that must
      parse and apply during sequential replay.
    - Risk remains HIGH, and is assessed as higher semantic/verification
      surface than A3 (0046, +67/-60) because the primary fix expands 13
      distinct check sites with severity-weighted scoring and differently-
      shaped PASS/FAIL JSON branches, not merely a LIMIT-placement change.
    - A4 must never be bundled with A5 (0066/0067) in any single Approval,
      Implementation, Verification, Audit, or commit.
```

---

## 4. Approved Disposition Direction

```text
1. KEEP_AND_APPROVE_FOR_SEPARATE_SQL_COMMIT is the approved direction for
   0065's current working-tree fix: (a) removal of the nested
   `procedure add_check(...)` declaration with all 13 call sites inlined
   as explicit IF/ELSE blocks, and (b) the subquery-wrapper +
   LIMIT-at-subquery-level correction for the `scan_cross_tenant_risk`
   sample_ids aggregate. DISCARD to HEAD is explicitly NOT approved -- it
   would reintroduce both documented parse-time replay blockers and leave
   security-isolation validation non-compiling.
2. This approval covers DISPOSITION DIRECTION and PREPARATION only. It does
   NOT itself authorize staging or committing 0065. That remains a
   separate, later, explicit Human selective-staging decision, made only
   after 604522-604524 (Implementation, Verification, Audit) closes.
3. A4 is a single-file, single-commit track. sql/migrations/0065_create_
   security_isolation_rpc.sql is the ONLY file approved for any
   disposition action under this Gate.
```

---

## 5. Approved Scope

```text
A. Approved file (exactly 1 file):

   sql/migrations/0065_create_security_isolation_rpc.sql

B. Approved 604522 Implementation scope: independently re-confirm the
   exact diff content for BOTH blocks (the run_isolation_audit
   inline-procedure removal and the scan_cross_tenant_risk aggregate-LIMIT
   correction), spot-check that all 13 inlined IF/ELSE check expansions
   preserve the original add_check severity/PASS/FAIL semantics, confirm
   the subquery-wrapper pattern is correctly applied to sample_ids, confirm
   SECURITY DEFINER is preserved on all four functions
   (verify_rls_coverage, run_isolation_audit, scan_cross_tenant_risk,
   generate_security_report), record it for traceability, and prepare (but
   not execute) the file for a future selective staging/commit decision.

C. Required subsequent lifecycle documents (all in the canonical 604300
   folder):
   604522_Implementation_SQL_Migration_Replay_Blocker_A4_0065_Security_Isolation_Disposition.md
   604523_Verification_SQL_Migration_Replay_Blocker_A4_0065_Security_Isolation_Disposition.md
   604524_Audit_SQL_Migration_Replay_Blocker_A4_0065_Security_Isolation_Disposition.md
```

---

## 6. Required Replay/Parse-Gate And Security-Isolation-Compile Verification (For A Future Stage, Not This Gate)

```text
Before any actual staging/commit of 0065 is considered (not authorized by
this Gate), a later verification stage must confirm, at minimum:

- The rewritten run_isolation_audit function parses and compiles without
  error (no nested procedure declaration inside a DECLARE section).
- The rewritten scan_cross_tenant_risk function parses and compiles
  without error (no LIMIT used directly inside a jsonb_agg(...) aggregate
  call).
- All 13 inlined IF/ELSE check expansions produce the same accumulator
  effects (v_total, v_passed, v_failed, v_checks, v_critical,
  v_risk_score) and the same severity-weighted risk_score outcome as the
  original add_check(...) procedure body would have, for both PASS and
  FAIL branches.
- verify_rls_coverage, run_isolation_audit, scan_cross_tenant_risk, and
  generate_security_report all retain SECURITY DEFINER.
- The scan_cross_tenant_risk sample_ids field preserves its original
  field name, diagnostic role, and row content after the subquery-wrapper
  correction.
- A re-run against a representative environment demonstrates clean
  sequential replay through position 0065 into 0066+ without a parse-time
  abort, for both the primary and secondary scenarios documented in
  604343/604307.
- Any discrepancy from the expected isolation-audit or risk-scan semantics
  is explicitly reported and explained, not silently accepted.

This Gate does not authorize running that replay/verification against a
live database; it only establishes what a future verification stage must
demonstrate before staging/commit can be separately authorized.
```

---

## 7. Explicitly Excluded From This Scope

```text
- sql/migrations/0035_verify_schema.sql -- A2, already committed
  (f89c70e0); no further modification or staging.
- sql/migrations/0038_create_toss_webhook_processor_rpc.sql,
  0042_create_delivery_order_intake_rpc.sql,
  0063_patch_core_rpc_i18n_diagnostics.sql,
  0068_create_realtime_edge_rpc.sql -- A1, already committed (70181253);
  no further modification or staging.
- sql/migrations/0046_create_context_builder_rpc.sql -- A3, already
  committed (6847d69b); no further modification or staging.
- sql/migrations/0066_create_ledger_integrity_rpc.sql and
  0067_create_cron_scheduler_rpc.sql -- A5, deferred, sequential-only,
  never combined with each other or with A4.
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
604522-604524 must preserve:

- Every other SQL/migration residue path (A5, Groups B/C/D/E) exactly as
  currently present, untouched by this track.
- The 4 tools/* residue paths, exactly as currently present, untouched.
- The already-committed A1 files (0038, 0042, 0063, 0068), the
  already-committed A2 file (0035), the already-committed A3 file (0046),
  and the already-committed 0143, unmodified and unre-staged.
- The already-committed metadata sync files (000005, 000007, 604001,
  604300_Index, 604306), unmodified.
- 0069 Analysis in its deferred, uncreated state.
- Scope D mainline in its current not-resumed state.
- The empty staging area.
```

---

## 9. Final Approval Decision

```text
APPROVED_FOR_A4_0065_SECURITY_ISOLATION_REPLAY_BLOCKER_DISPOSITION_ONLY_WITH_HIGH_RISK_SINGLE_FILE_SQL_BOUNDARY
```

---

## 10. Explicitly Forbidden Work

```text
- Modification of any SQL/migration file other than 0065.
- Staging of any SQL/migration file other than 0065, and no staging of
  0065 itself under this Gate.
- SQL/migration reset, discard, or rename of any residue path.
- SQL/migration rename of any kind.
- Combining A4 with A5 in any single Approval, Implementation,
  Verification, or Audit document, or any future commit.
- Combining A4 with 0138, 0142, the zero-pad paired-pending group, or the
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

## 11. Required 604522 Implementation Output

```text
Codex must create:

604522_Implementation_SQL_Migration_Replay_Blocker_A4_0065_Security_Isolation_Disposition.md

The H1 must exactly match the full filename including .md.

604522 must record:

1. Independent re-confirmation of 0065's exact working-tree diff for both
   the primary (run_isolation_audit inline-procedure removal) and
   secondary (scan_cross_tenant_risk aggregate-LIMIT) blocks.
2. Confirmation that all 13 inlined IF/ELSE check expansions preserve the
   original add_check accumulator and severity semantics.
3. Confirmation that SECURITY DEFINER is preserved on all four functions.
4. Confirmation that the subquery-wrapper LIMIT correction preserves the
   sample_ids field name and diagnostic role.
5. Confirmation that no other SQL/migration file was touched.
6. Confirmation that A1 (already committed), A2 (already committed), A3
   (already committed), A5, and Groups B/C/D/E remain untouched.
7. Confirmation that tools/*, runtime code, and Flutter were not modified.
8. Confirmation that 0069 Analysis was not created and Scope D mainline was
   not resumed.
9. Confirmation that no staging or commit was performed.
```

---

## 12. Required 604523 Verification

```text
The verifier must create:

604523_Verification_SQL_Migration_Replay_Blocker_A4_0065_Security_Isolation_Disposition.md

604523 must independently verify:

- 604522 exists with H1 matching its filename.
- 0065's working-tree diff remains exactly as documented, unmodified by
  604522.
- No other SQL/migration file, tools file, or runtime file was touched.
- 0069 Analysis was not created; Scope D mainline was not resumed.
- No file is staged.
- git diff --check passes.
```

---

## 13. Required 604524 Audit

```text
The independent auditor must create:

604524_Audit_SQL_Migration_Replay_Blocker_A4_0065_Security_Isolation_Disposition.md

604524 must decide whether the A4 disposition-preparation record is
accepted, without expanding scope into A5, Groups B-E, tools remediation,
0069 Analysis, or Scope D mainline resumption, and without treating its own
ACCEPT verdict as authorization to actually stage or commit 0065.
```

---

## 14. Commit Readiness Note

```text
This Approval Gate does not authorize staging or commit of 0065 or any
other residue path. Any future actual `git add`/`git commit` of 0065
requires its own distinct, explicit Human staging/commit authorization,
issued after 604524 Audit accepts the preparation record, and must not
bundle any file from A1 (already committed), A2 (already committed), A3
(already committed), A5, Groups B-E, or tools residue. That future
authorization must also require the replay/parse-gate and security-
isolation-compile verification outcome described in §6 as a precondition.
```

---

## 15. Final Boundary Decision

```text
APPROVED_FOR_A4_0065_SECURITY_ISOLATION_REPLAY_BLOCKER_DISPOSITION_ONLY_WITH_HIGH_RISK_SINGLE_FILE_SQL_BOUNDARY
```

```text
Approved next artifact:

604522_Implementation_SQL_Migration_Replay_Blocker_A4_0065_Security_Isolation_Disposition.md

followed by:

604523_Verification_SQL_Migration_Replay_Blocker_A4_0065_Security_Isolation_Disposition.md
604524_Audit_SQL_Migration_Replay_Blocker_A4_0065_Security_Isolation_Disposition.md

A5 (0066 then 0067, sequential) remains deferred to its own separate future
Approval Gate. Groups B, C, D, E, and tools residue remain excluded. 0069
Analysis remains deferred. Scope D mainline remains blocked. Staging/commit
of 0065 remains a separate, later, explicit Human decision, not authorized
here.
```
