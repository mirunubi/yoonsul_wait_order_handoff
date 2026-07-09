# 604514_Approval_Gate_SQL_Migration_Replay_Blocker_A3_0046_Context_Builder_Disposition.md

Status: Complete
Lifecycle: Human Approval Gate
Gate Classification: Group A3 — 0046 Context Builder Replay Blocker — Stage 3 Human Approval Gate
Runtime Implementation Authorization: Not Granted By This Document
Owner: Human (정영석)
Last Updated: 2026-07-05

This is a documentation-only Approval Gate. It approves the A3 (0046) sub-batch
DISPOSITION DIRECTION only. It does not itself stage or commit
sql/migrations/0046_create_context_builder_rpc.sql. It performs no SQL edit,
migration edit, reset, discard, rename, staging, or commit. It does not create
or modify 0069 Analysis and does not resume Scope D mainline.

---

## 1. Approval Gate Summary

```text
This document approves KEEP_AND_APPROVE_FOR_SEPARATE_SQL_COMMIT as the
disposition direction for the A3 sub-batch (0046_create_context_builder_
rpc.sql only), consistent with the 604391 five-way Group A split and the
604392 approval that only A1 was authorized for immediate action at that
time. A3 remains its own standalone, single-file track -- this Gate
authorizes preparation (604515 Implementation) toward a future, separately-
approved staging/commit decision; it does not authorize that staging/commit
itself.

Final approval decision:
```

```text
APPROVED_FOR_A3_0046_CONTEXT_BUILDER_REPLAY_BLOCKER_DISPOSITION_ONLY_WITH_HIGH_RISK_SINGLE_FILE_SQL_BOUNDARY
```

```text
Authorized implementer (604515 only):
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
- A2 SQL (0035_verify_schema.sql) is committed: f89c70e0
  "fix: rewrite 0035 schema verification replay gate".
- The 604506-604510 metadata index/navigation sync is committed: fc7797c5
  "docs: sync metadata indexes after A1 A2 and no-payment tracks".
- sql/migrations/0046_create_context_builder_rpc.sql remains tracked
  modified (M), unstaged, with diff +67/-60, exactly as 604513 recorded.
- git diff --check passes. No file is currently staged.
- Scope D mainline remains blocked; 0069 Analysis remains deferred.
- This Approval Gate independently re-confirmed the current working-tree
  state immediately before being written: 0046's diff stat is unchanged
  (67 insertions, 60 deletions) since 604513 was authored, A1/A2 no longer
  appear in the residue list (both committed), the remaining A4/A5 and
  Group B/C/D/E residue paths are unchanged, tools residue is unchanged,
  and the staging area remains empty.
```

---

## 3. Input Documents Reference

```text
604391_Analysis_SQL_Migration_Replay_Blocker_Group_Disposition.md
  -- adopted: A3 (0046) is its own deferred sub-batch, HIGH risk, a
  substantive query/LIMIT restructure (not a micro-fix), requiring its own
  standalone Approval Gate before any action.
604392_Approval_Gate_SQL_Migration_Replay_Blocker_Group_Disposition.md
  -- adopted: only A1 was authorized for immediate action at that stage;
  A2-A5 were deferred to their own future gates. A2 has since been
  separately approved and committed (604399-604402, f89c70e0); A3 is now
  taken up in its own turn per that same split.
604513_Analysis_SQL_Migration_Replay_Blocker_A3_0046_Context_Builder_Disposition.md
  -- accepted as the basis for this Approval Gate without re-analysis. Its
  key findings, adopted here:
    - 0046 contains TWO independent, confirmed HEAD parse-time blockers
      inside catchmenu_knowledge.build_ai_context: a primary blocker
      (`LIMIT p_max_documents` used directly inside a
      `jsonb_agg(... ORDER BY ...)` aggregate call for context documents)
      and a secondary blocker (`LIMIT 5` used the same invalid way for
      related exceptions). PostgreSQL's aggregate-call grammar does not
      permit LIMIT inside jsonb_agg(...) ORDER BY ... as a direct argument.
    - The working-tree fix addresses BOTH blockers using the same
      structural pattern: a subquery selects/filters/sorts/limits the
      candidate rows, and the outer jsonb_agg() aggregates the subquery's
      already-limited result set. This is the same subquery-wrapper-with-
      LIMIT-at-subquery-level pattern already approved in principle by the
      604350/604354 lineage (Candidate B).
    - The diff's change categories are: query restructuring, LIMIT
      placement, sort/candidate-selection semantics, and JSON-aggregation
      wrapper correction -- not a mechanical one-line syntax fix. Filters,
      payload masking (INTERNAL_ONLY vs masked summary), and JSON field
      sets are preserved unchanged; only the query structure around LIMIT
      placement changes.
    - Reverting the working tree to HEAD would reintroduce both parse-time
      failures and halt sequential replay at position 0046, before 0047
      and everything after it (including 0063, 0065, 0066, 0067, 0068,
      0069, and 0142).
    - 0046 is not a discard candidate: HEAD is broken, not merely
      suboptimal, and a skip-in-automated-replay policy is not applicable
      because 0046 creates real runtime RPC objects that must parse and
      apply during sequential replay.
    - Risk remains HIGH: higher semantic risk than an A1-class syntax
      micro-fix, because LIMIT placement changes which rows enter the
      aggregate (retrieval-selection semantics), even though the diff's
      raw line count (+67/-60) is smaller than A2's (+681/-187).
    - A3 must never be bundled with A4 (0065) or A5 (0066/0067) in any
      single Approval, Implementation, Verification, Audit, or commit.
```

---

## 4. Approved Disposition Direction

```text
1. KEEP_AND_APPROVE_FOR_SEPARATE_SQL_COMMIT is the approved direction for
   0046's current working-tree fix, applying the subquery-wrapper +
   LIMIT-at-subquery-level pattern to both the primary (context documents)
   and secondary (related exceptions) blockers. DISCARD to HEAD is
   explicitly NOT approved -- it would reintroduce both documented
   parse-time replay blockers.
2. This approval covers DISPOSITION DIRECTION and PREPARATION only. It does
   NOT itself authorize staging or committing 0046. That remains a
   separate, later, explicit Human selective-staging decision, made only
   after 604515-604517 (Implementation, Verification, Audit) closes.
3. A3 is a single-file, single-commit track. sql/migrations/0046_create_
   context_builder_rpc.sql is the ONLY file approved for any disposition
   action under this Gate.
```

---

## 5. Approved Scope

```text
A. Approved file (exactly 1 file):

   sql/migrations/0046_create_context_builder_rpc.sql

B. Approved 604515 Implementation scope: independently re-confirm the
   exact diff content for BOTH blocks (context-document retrieval and
   related-exception retrieval), confirm the subquery-wrapper pattern is
   correctly applied in each, confirm no filter/masking/field-set
   regression, record it for traceability, and prepare (but not execute)
   the file for a future selective staging/commit decision.

C. Required subsequent lifecycle documents (all in the canonical 604300
   folder):
   604515_Implementation_SQL_Migration_Replay_Blocker_A3_0046_Context_Builder_Disposition.md
   604516_Verification_SQL_Migration_Replay_Blocker_A3_0046_Context_Builder_Disposition.md
   604517_Audit_SQL_Migration_Replay_Blocker_A3_0046_Context_Builder_Disposition.md
```

---

## 6. Required Replay/Parse-Gate Verification (For A Future Stage, Not This Gate)

```text
Before any actual staging/commit of 0046 is considered (not authorized by
this Gate), a later verification stage must confirm, at minimum:

- The rewritten build_ai_context function parses and compiles without
  error (no LIMIT used directly inside a jsonb_agg(...) ORDER BY ...
  aggregate call, in either the primary or secondary block).
- Both the context-document subquery and the related-exception subquery
  preserve their original filters (tenant, status, audience, query-type
  mapping; store_id, tenant_id, status, 24h window respectively), their
  original sort order (effectiveness_score desc nulls last, published_at
  desc; detected_at desc respectively), and their original payload/masking
  logic.
- A re-run against a representative environment demonstrates clean
  sequential replay through position 0046 into 0047+ without a parse-time
  abort, for both the primary and secondary scenarios documented in
  604350-604357.
- Any discrepancy from the expected retrieval semantics (e.g. wrong row
  count, wrong sort, masked field leaking) is explicitly reported and
  explained, not silently accepted.

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
- sql/migrations/0065_create_security_isolation_rpc.sql -- A4, deferred.
- sql/migrations/0066_create_ledger_integrity_rpc.sql and
  0067_create_cron_scheduler_rpc.sql -- A5, deferred, sequential-only,
  never combined with each other or with A3.
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
604515-604517 must preserve:

- Every other SQL/migration residue path (A4, A5, Groups B/C/D/E) exactly
  as currently present, untouched by this track.
- The 4 tools/* residue paths, exactly as currently present, untouched.
- The already-committed A1 files (0038, 0042, 0063, 0068), the
  already-committed A2 file (0035), and the already-committed 0143,
  unmodified and unre-staged.
- The already-committed metadata sync files (000005, 000007, 604001,
  604300_Index, 604306), unmodified.
- 0069 Analysis in its deferred, uncreated state.
- Scope D mainline in its current not-resumed state.
- The empty staging area.
```

---

## 9. Final Approval Decision

```text
APPROVED_FOR_A3_0046_CONTEXT_BUILDER_REPLAY_BLOCKER_DISPOSITION_ONLY_WITH_HIGH_RISK_SINGLE_FILE_SQL_BOUNDARY
```

---

## 10. Explicitly Forbidden Work

```text
- Modification of any SQL/migration file other than 0046.
- Staging of any SQL/migration file other than 0046, and no staging of
  0046 itself under this Gate.
- SQL/migration reset, discard, or rename of any residue path.
- SQL/migration rename of any kind.
- Combining A3 with A4 or A5 in any single Approval, Implementation,
  Verification, or Audit document, or any future commit.
- Combining A3 with 0138, 0142, the zero-pad paired-pending group, or the
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

## 11. Required 604515 Implementation Output

```text
Codex must create:

604515_Implementation_SQL_Migration_Replay_Blocker_A3_0046_Context_Builder_Disposition.md

The H1 must exactly match the full filename including .md.

604515 must record:

1. Independent re-confirmation of 0046's exact working-tree diff for both
   the primary (context-document) and secondary (related-exception)
   blocks, including the exact subquery-wrapper-plus-LIMIT-at-subquery-
   level structure used in each.
2. Confirmation that filters, sort order, and payload/masking logic are
   preserved unchanged in both blocks.
3. Confirmation that no other SQL/migration file was touched.
4. Confirmation that A1 (already committed), A2 (already committed), A4,
   A5, and Groups B/C/D/E remain untouched.
5. Confirmation that tools/*, runtime code, and Flutter were not modified.
6. Confirmation that 0069 Analysis was not created and Scope D mainline was
   not resumed.
7. Confirmation that no staging or commit was performed.
```

---

## 12. Required 604516 Verification

```text
The verifier must create:

604516_Verification_SQL_Migration_Replay_Blocker_A3_0046_Context_Builder_Disposition.md

604516 must independently verify:

- 604515 exists with H1 matching its filename.
- 0046's working-tree diff remains exactly as documented, unmodified by
  604515.
- No other SQL/migration file, tools file, or runtime file was touched.
- 0069 Analysis was not created; Scope D mainline was not resumed.
- No file is staged.
- git diff --check passes.
```

---

## 13. Required 604517 Audit

```text
The independent auditor must create:

604517_Audit_SQL_Migration_Replay_Blocker_A3_0046_Context_Builder_Disposition.md

604517 must decide whether the A3 disposition-preparation record is
accepted, without expanding scope into A4, A5, Groups B-E, tools
remediation, 0069 Analysis, or Scope D mainline resumption, and without
treating its own ACCEPT verdict as authorization to actually stage or
commit 0046.
```

---

## 14. Commit Readiness Note

```text
This Approval Gate does not authorize staging or commit of 0046 or any
other residue path. Any future actual `git add`/`git commit` of 0046
requires its own distinct, explicit Human staging/commit authorization,
issued after 604517 Audit accepts the preparation record, and must not
bundle any file from A1 (already committed), A2 (already committed), A4,
A5, Groups B-E, or tools residue. That future authorization must also
require the replay/parse-gate verification outcome described in §6 as a
precondition.
```

---

## 15. Final Boundary Decision

```text
APPROVED_FOR_A3_0046_CONTEXT_BUILDER_REPLAY_BLOCKER_DISPOSITION_ONLY_WITH_HIGH_RISK_SINGLE_FILE_SQL_BOUNDARY
```

```text
Approved next artifact:

604515_Implementation_SQL_Migration_Replay_Blocker_A3_0046_Context_Builder_Disposition.md

followed by:

604516_Verification_SQL_Migration_Replay_Blocker_A3_0046_Context_Builder_Disposition.md
604517_Audit_SQL_Migration_Replay_Blocker_A3_0046_Context_Builder_Disposition.md

A4 (0065) and A5 (0066 then 0067, sequential) remain deferred to their own
separate future Approval Gates. Groups B, C, D, E, and tools residue remain
excluded. 0069 Analysis remains deferred. Scope D mainline remains blocked.
Staging/commit of 0046 remains a separate, later, explicit Human decision,
not authorized here.
```
