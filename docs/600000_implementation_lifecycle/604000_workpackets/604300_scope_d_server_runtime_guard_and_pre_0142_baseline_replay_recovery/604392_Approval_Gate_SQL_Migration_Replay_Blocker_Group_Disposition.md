# 604392_Approval_Gate_SQL_Migration_Replay_Blocker_Group_Disposition.md

Status: Complete
Lifecycle: Human Approval Gate
Gate Classification: Group A Replay Blocker SQL Residue — Stage 3 Human Approval Gate (A1 Micro-Fix Only)
Runtime Implementation Authorization: Granted only for the narrow A1 preparation scope in §7
Owner: Human (정영석)
Last Updated: 2026-07-05

This is a documentation-and-preparation-only Approval Gate. It approves the
A1 micro-fix sub-batch (4 files) as the next immediate implementation target
and explicitly rejects a single Group-A-wide commit. It does not itself stage
or commit any SQL file. It performs no SQL edit, migration edit, tools edit,
reset, discard, rename, or commit. It does not create or modify 0069 Analysis
and does not resume Scope D mainline.

---

## 1. Approval Gate Summary

```text
This document authorizes the A1 micro-fix sub-batch
(0038, 0042, 0063, 0068) as the sole next implementation target within Group
A, and defers A2 (0035), A3 (0046), A4 (0065), and A5 (0066+0067, sequential)
to their own separate future Approval Gates.

Final approval decision:
```

```text
APPROVED_FOR_A1_MICRO_FIX_SQL_RESIDUE_DISPOSITION_ONLY_WITH_GROUP_A_SPLIT_ENFORCED
```

```text
Authorized implementer (604393 only, per §7 boundary):
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
- 604390 Approval Gate: CLOSED, approved SQL residue track separation into
  Groups A-E, with Group A recommended as the immediate next track.
- 604391 Analysis: complete. Final Analysis Result:
  GROUP_A_REPLAY_BLOCKER_SQL_RESIDUE_REQUIRES_APPROVAL_GATE_BEFORE_ACTION
- All 9 Group A files remain tracked modified in the working tree.
- No file is currently staged. git diff --check passes.
- Scope D mainline remains blocked; 0069 Analysis remains deferred.
- This Approval Gate independently re-confirmed the current working-tree
  state immediately before being written and found it unchanged from what
  604391 recorded: the same 21 SQL/migration residue paths (including all 9
  Group A files as tracked-modified) and the same 4 tools/* residue paths
  remain present, and the staging area remains empty.
```

---

## 3. Input Analysis Reference

```text
604391_Analysis_SQL_Migration_Replay_Blocker_Group_Disposition.md is accepted
as the basis for this Approval Gate without re-analysis. Its key findings,
adopted here:

- Group A (9 files) cannot be committed as a single batch; a minimum of five
  sub-batches is required.
- No file in Group A is recommended as an unconditional discard candidate;
  reverting any of them to HEAD would reintroduce known, previously-documented
  replay failures (604270/604280/604300 lineage).
- Per-file classification:
  0035 -- verification rewrite, HIGH risk, own sub-batch (A2).
  0038 -- micro syntax fix, MEDIUM risk, A1 candidate.
  0042 -- micro syntax fix (result_payload := -> =), MEDIUM risk, A1 candidate,
    604280 lineage relation.
  0046 -- substantive query/LIMIT restructure, HIGH risk, own sub-batch (A3).
  0063 -- micro syntax fixes, MEDIUM risk, A1 candidate.
  0065 -- large inline-procedure removal, HIGH risk, own sub-batch (A4).
  0066 -- aggregate SQL repair, HIGH risk, sequential sub-batch (A5, first).
  0067 -- duplicate-content removal / no-op replacement, HIGH risk, sequence-
    critical, sequential sub-batch (A5, second; must never share a commit
    with 0066).
  0068 -- micro constraint-definition fix, MEDIUM risk, A1 candidate.
- Proposed sub-batch split (adopted verbatim):
  A1 -- 0038, 0042, 0063, 0068 (micro-fix)
  A2 -- 0035 (verification rewrite, standalone, HIGH)
  A3 -- 0046 (context builder, standalone)
  A4 -- 0065 (security isolation, standalone)
  A5 -- 0066 then 0067, sequential commits, never combined
```

---

## 4. Approved Scope

```text
This Approval Gate approves ONLY the A1 micro-fix sub-batch as the next
implementation target. A2, A3, A4, and A5 remain deferred to their own
separate future Approval Gates and are NOT authorized by this document.

A. Approved A1 file list (exactly 4 files):

  sql/migrations/0038_create_toss_webhook_processor_rpc.sql
  sql/migrations/0042_create_delivery_order_intake_rpc.sql
  sql/migrations/0063_patch_core_rpc_i18n_diagnostics.sql
  sql/migrations/0068_create_realtime_edge_rpc.sql

B. Approved A1 implementation scope (604393): preserve and verify the
   existing working-tree diff for exactly these four files, and PREPARE them
   for selective staging/commit -- i.e. confirm each diff is exactly the
   documented micro-fix, confirm no other file is touched, and record the
   preparation. This Gate does NOT itself authorize the actual `git add` /
   `git commit` action; that remains gated by 604393's own confirmation and
   604394/604395's independent verification and audit, consistent with the
   "staging/commit forbidden" boundary in §10 applying to this Approval Gate
   specifically. Whether 604393 may perform the actual selective stage/commit
   is determined by the explicit wording of 604393's own required output in
   §6 -- 604393 may prepare and recommend, but must not itself execute a
   commit without a distinct, later, explicit Human staging/commit
   authorization.

C. Required subsequent lifecycle documents (all in the canonical 604300
   folder):
   604393_Implementation_SQL_Migration_Replay_Blocker_A1_Micro_Fix_Disposition.md
   604394_Verification_SQL_Migration_Replay_Blocker_A1_Micro_Fix_Disposition.md
   604395_Audit_SQL_Migration_Replay_Blocker_A1_Micro_Fix_Disposition.md
```

---

## 5. Explicitly Deferred (Not Authorized By This Gate)

```text
- A2 -- 0035_verify_schema.sql (verification rewrite). Deferred to its own
  future Approval Gate. Requires dedicated replay evidence and diff-size
  review before any action.
- A3 -- 0046_create_context_builder_rpc.sql (context builder restructure).
  Deferred to its own future Approval Gate. Requires 0046 primary/secondary
  replay-scenario evidence before any action.
- A4 -- 0065_create_security_isolation_rpc.sql (security isolation refactor).
  Deferred to its own future Approval Gate. Requires dedicated replay
  evidence given its large blast radius.
- A5 -- 0066_create_ledger_integrity_rpc.sql and
  0067_create_cron_scheduler_rpc.sql (ledger + cron sequence repair).
  Deferred to its own future Approval Gate. Must remain sequential (0066
  committed and verified before 0067 is even considered); the two must never
  share a single commit or a single Approval Gate action.
- Group B (0138_patch_integration_functions.sql): excluded from this Gate.
- Group C (024/0024, 030/0030, 032/0032 paired-pending): excluded from this
  Gate.
- Group D (0142_patch_toss_mvp_payment_intent_binding.sql): excluded from
  this Gate.
- Group E (0136, 0139, 0141, seed_yoonsul_menu.sql): excluded from this Gate.
- tools/* residue (4 files): excluded from this Gate; separate future tooling
  track per 604388/604390.
```

---

## 6. Approved Preservation And Preparation Rules

```text
604393 Implementation must, for exactly the 4 A1 files:

1. Independently re-confirm each file's working-tree diff matches the
   documented micro-fix character exactly:
     0038: single UPDATE SET assignment fix
       (processing_error := -> processing_error =)
     0042: single UPDATE SET assignment fix
       (result_payload := -> result_payload =)
     0063: multiple UPDATE SET assignment fixes (:= -> =) in diagnostics/
       payment-intent update paths
     0068: UNIQUE constraint definition change
       (UNIQUE (...) -> UNIQUE NULLS NOT DISTINCT (...)) on tenant_id +
       function_code
2. Confirm no other file's working-tree diff was altered as a side effect.
3. Record the exact per-file diff (line counts, before/after snippet) for
   traceability.
4. Explicitly record that 0038 is classified as a Toss-webhook-processor
   micro-fix and must NOT be mixed with Group D's 0142
   (a different Toss-payment-intent-binding migration entirely).
5. Explicitly record that 0042 is classified as a one-line result_payload
   assignment fix in the 604280 cross-scope lineage, and must NOT be mixed
   with 0069 Analysis or any 0069-adjacent judgment.
6. Explicitly record that 0063 is classified as a core-RPC i18n-diagnostics
   patch micro-fix.
7. Explicitly record that 0068 is classified as a realtime-edge RPC
   micro-fix.
8. NOT stage, commit, reset, discard, or rename any of the 4 A1 files, or any
   other SQL/migration/tools/runtime file, as part of 604393 itself. Actual
   staging/commit requires a distinct, later, explicit Human authorization
   beyond this Gate and beyond 604393-604395.
```

---

## 7. Authorized Implementation Boundary

```text
Approved for 604393 Implementation (Codex), preparation-only:

1. Create
   604393_Implementation_SQL_Migration_Replay_Blocker_A1_Micro_Fix_Disposition.md
   in the canonical 604300 folder, per §6.
2. No SQL, migration, runtime, or tools file may be modified, staged,
   committed, discarded, reset, or renamed by 604393.
3. No other Markdown file may be created or modified.

This is a preparation-and-verification-record authorization. It grants no
actual SQL commit authority.
```

---

## 8. Mandatory Preservation Rules

```text
604393-604395 must preserve:

- All 21 SQL/migration residue paths, exactly as currently present, with the
  4 A1 files subject only to the read-only re-confirmation in §6 -- no
  modification of their content.
- All 4 tools/* residue paths, exactly as currently present, untouched.
- Groups B, C, D, and E, exactly as currently present, untouched and
  unreferenced except as exclusion notes.
- 604300_Index, 604306_NavigationMap, 604001 parent NavigationMap, 604337,
  604338, 604373, and every previously-closed 604335-604391 track document,
  unmodified.
- 0069 Analysis in its deferred, uncreated state.
- Scope D mainline in its current not-resumed state.
- The empty staging area.
```

---

## 9. Final Approval Decision

```text
APPROVED_FOR_A1_MICRO_FIX_SQL_RESIDUE_DISPOSITION_ONLY_WITH_GROUP_A_SPLIT_ENFORCED
```

---

## 10. Explicitly Forbidden Work

```text
- Committing Group A as a single, whole-group batch.
- Modifying, staging, or committing 0035 (A2).
- Modifying, staging, or committing 0046 (A3).
- Modifying, staging, or committing 0065 (A4).
- Modifying, staging, or committing 0066 (A5).
- Modifying, staging, or committing 0067 (A5).
- Any processing of 0138 (Group B).
- Any processing of 0142 (Group D).
- Any processing of the 024/0024, 030/0030, 032/0032 pairs (Group C).
- Any processing of 0136/0139/0141/seed_yoonsul_menu.sql (Group E).
- Any processing of tools/* residue.
- Creation or modification of 0069 Analysis.
- Resuming Scope D mainline (604260, 604250, 604400/604310, 604316) in any
  form.
- Runtime code modification of any kind.
- Staging of any file under this Gate.
- Any git commit under this Gate.
```

---

## 11. Required 604393 Implementation Output

```text
Codex must create:

604393_Implementation_SQL_Migration_Replay_Blocker_A1_Micro_Fix_Disposition.md

The H1 must exactly match the full filename including .md.

604393 must record:

1. Independent re-confirmation of each of the 4 A1 files' exact diff content
   per §6.1.
2. Explicit per-file classification notes for 0038, 0042, 0063, and 0068 per
   §6.4-§6.7.
3. Confirmation that A2 (0035), A3 (0046), A4 (0065), and A5 (0066/0067) were
   not touched.
4. Confirmation that Groups B, C, D, E, and tools residue were not touched.
5. Confirmation that no SQL, migration, runtime, or tools file was modified,
   staged, discarded, reset, or renamed.
6. Confirmation that 0069 Analysis was not created and Scope D mainline was
   not resumed.
7. Confirmation that no staging or commit was performed.
```

---

## 12. Required 604394 Verification

```text
The verifier must create:

604394_Verification_SQL_Migration_Replay_Blocker_A1_Micro_Fix_Disposition.md

604394 must independently verify:

- 604393 exists with H1 matching its filename.
- The 4 A1 files' working-tree diffs remain exactly as documented, unmodified
  by 604393.
- A2/A3/A4/A5 files (0035, 0046, 0065, 0066, 0067) remain untouched.
- Groups B/C/D/E and tools residue remain untouched.
- 0069 Analysis was not created; Scope D mainline was not resumed.
- No file is staged.
- git diff --check passes.
```

---

## 13. Required 604395 Audit

```text
The independent auditor must create:

604395_Audit_SQL_Migration_Replay_Blocker_A1_Micro_Fix_Disposition.md

604395 must decide whether the A1 preparation record is accepted, without
expanding scope into A2-A5, Groups B-E, tools remediation, 0069 Analysis, or
Scope D mainline resumption, and without treating its own ACCEPT verdict as
authorization to actually stage or commit the A1 files.
```

---

## 14. Commit Readiness Note

```text
This Approval Gate does not authorize staging or commit of the A1 files or
any other residue path. Any future actual `git add`/`git commit` of the A1
files requires its own distinct, explicit Human staging/commit authorization,
issued after 604395 Audit accepts the preparation record, and must not bundle
any file from A2-A5, Groups B-E, or tools residue.
```

---

## 15. Final Boundary Decision

```text
APPROVED_FOR_A1_MICRO_FIX_SQL_RESIDUE_DISPOSITION_ONLY_WITH_GROUP_A_SPLIT_ENFORCED
```

```text
Approved next artifact:

604393_Implementation_SQL_Migration_Replay_Blocker_A1_Micro_Fix_Disposition.md

followed by:

604394_Verification_SQL_Migration_Replay_Blocker_A1_Micro_Fix_Disposition.md
604395_Audit_SQL_Migration_Replay_Blocker_A1_Micro_Fix_Disposition.md

A2, A3, A4, and A5 remain deferred to their own separate future Approval
Gates. Groups B, C, D, E, and tools residue remain excluded. 0069 Analysis
remains deferred. Scope D mainline remains blocked. No Scope D mainline or
0069 work may resume until every group and sub-batch's disposition track is
separately closed, and even then only via a further separate explicit Human
decision.
```
