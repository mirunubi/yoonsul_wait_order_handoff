# 604513_Analysis_SQL_Migration_Replay_Blocker_A3_0046_Context_Builder_Disposition.md

Status: Complete
Lifecycle: Analysis
Gate Classification: Group A3 — 0046 Context Builder Replay Blocker Disposition
Runtime Implementation Authorization: Not Granted
Owner: TBD
Last Updated: 2026-07-05

This is an **analysis document only**. It classifies the A3 replay-blocker SQL
residue for `0046_create_context_builder_rpc.sql` only. It performs no SQL
edit, migration edit, reset, discard, rename, staging, or commit. It does not
create 0069 Analysis and does not resume Scope D mainline.

Authority:

```text
604390_Approval_Gate_SQL_Migration_Residue_Disposition_Before_Scope_D_Resume.md
Final Approval Decision:
  APPROVED_FOR_SQL_RESIDUE_TRACK_SEPARATION_WITH_SCOPE_D_AND_0069_STILL_BLOCKED

604391_Analysis_SQL_Migration_Replay_Blocker_Group_Disposition.md
  Sub-batch A3 — Context builder restructure (0046 only); Risk: HIGH

Prior cross-scope 0046 blocker lineage (analysis/verification/audit only):
  604350–604353 (primary limit p_max_documents syntax blocker)
  604354–604357 (secondary limit 5 syntax blocker)
```

Prior committed sub-batches (must not be re-opened in this Analysis):

```text
A1 SQL (0038, 0042, 0063, 0068) : committed (70181253)
A2 SQL (0035)                     : committed (f89c70e0)
Metadata sync (604506–604510)     : committed (fc7797c5)
```

See `docs/000015_Korean_Document_And_Encoding_Safety_Rules.md` for encoding rules.

---

## 1. Analysis Scope

### 1.1 In scope — A3 single file

```text
sql/migrations/0046_create_context_builder_rpc.sql
```

### 1.2 Explicit exclusions

```text
0035           — A2 committed (f89c70e0), excluded
0038, 0042, 0063, 0068 — A1 committed (70181253), excluded
0065           — A4, excluded
0066, 0067     — A5 sequential, excluded
0138, 0142
024/0024, 030/0030, 032/0032 pairs
0136, 0139, 0141, seed_yoonsul_menu.sql
tools/*
0069 Analysis creation
Scope D mainline resume
```

---

## 2. Commands Executed

All commands below were run from repository root on 2026-07-05:

```powershell
git status --short
git diff --check
git diff --cached --name-only
git diff --numstat -- sql/migrations/0046_create_context_builder_rpc.sql
git diff --name-status -- sql/migrations/0046_create_context_builder_rpc.sql
git diff -- sql/migrations/0046_create_context_builder_rpc.sql
git status --short | Select-String '0046|0065|0066|0067|0138|0142|0024|0030|0032|0136|0139|0141|seed|tools|0069|604513|604514|604515'
git log --oneline -1 -- sql/migrations/0035_verify_schema.sql
git log --oneline -1 -- sql/migrations/0046_create_context_builder_rpc.sql
```

No staging or commit was performed by this Analysis.

---

## 3. Repository Gate State

```text
git diff --check                 : exit 0 (PASS)
git diff --cached --name-only    : empty
staged files                     : none
staged SQL/migration             : none
staged tools                     : none
```

**0046 only:**

```text
git status --short : M  sql/migrations/0046_create_context_builder_rpc.sql
git diff --numstat : 67  60  sql/migrations/0046_create_context_builder_rpc.sql
git diff --name-status : M  sql/migrations/0046_create_context_builder_rpc.sql
```

**Other Group A residue visible in working tree (excluded from A3 scope):**

```text
M  sql/migrations/0065_create_security_isolation_rpc.sql
M  sql/migrations/0066_create_ledger_integrity_rpc.sql
M  sql/migrations/0067_create_cron_scheduler_rpc.sql
(+ other sql/migrations/* paths per git status — not analyzed here)
```

---

## 4. Current Git State Summary

| Attribute | Value |
|---|---|
| Path | `sql/migrations/0046_create_context_builder_rpc.sql` |
| Git state | `M` (tracked modified, unstaged) |
| Diff size | +67 / −60 lines |
| Last commit touching file | `7e3ba4aa` sql: add catchmenu schema migrations 0036-0073 |
| Working-tree vs HEAD | substantive query/LIMIT restructure in `catchmenu_knowledge.build_ai_context` |

The working-tree change is **not committed**. HEAD retains both documented
parse-time replay blockers.

---

## 5. Why 0046 Is Classified as a Context-Builder Replay Blocker

### 5.1 Primary blocker (document retrieval)

Prior lineage (`604350`, `604352`, `604353`) established:

```text
Failed at: 0046_create_context_builder_rpc.sql
Error:     syntax error at or near "limit"
Location:  limit p_max_documents inside jsonb_agg(...) order by ... clause
Function:  catchmenu_knowledge.build_ai_context(...)
```

PostgreSQL aggregate call grammar does not permit `LIMIT` inside the
`jsonb_agg(...) ORDER BY ...` construct when used as a direct aggregate
argument. Migration apply halts at position 0046 before 0047+.

### 5.2 Secondary blocker (related exceptions)

Prior lineage (`604354`, `604356`, `604357`) established a **second independent**
syntax defect in the same function:

```text
Failed at:  same file, later statement in build_ai_context
Error:     syntax error at or near "limit"
Location:  limit 5 inside jsonb_agg(...) order by e.detected_at desc
Guard:     p_store_id is not null AND p_query_type in ('EXCEPTION_GUIDANCE', 'INCIDENT_RESPONSE')
```

After the primary defect is hypothetically fixed in HEAD alone, replay would
still fail at this secondary construct unless both are corrected.

### 5.3 Relation to 604391 Group A disposition

604391 classified 0046 as:

```text
Substantive query/limit restructure (+67/−60), not a one-line syntax fix.
SPLIT_TO_SEPARATE_APPROVAL_GATE (A3 sub-batch).
REQUIRES_REPLAY_VERIFICATION through 0046 primary/secondary scenarios.
Risk: HIGH.
```

604391 explicitly warned against confusing 604350-series **documentation**
corrections with this **SQL** working-tree diff.

---

## 6. Diff Character and Change Classification

The working-tree diff addresses **both** primary and secondary blockers in one
file using the same structural pattern recommended in 604350/604354 (subquery
wrapper with `LIMIT` applied at the subquery level, not inside `jsonb_agg`).

### 6.1 Block 1 — context documents (`v_context_documents`)

| Aspect | HEAD (broken) | Working tree (fix) |
|---|---|---|
| Structure | `jsonb_agg(jsonb_build_object(...) ORDER BY ... LIMIT p_max_documents)` | Subquery selects filtered rows with `ORDER BY` + `LIMIT p_max_documents`, outer `jsonb_agg` on subquery result |
| Change class | Query restructuring + LIMIT placement | Query restructuring + LIMIT placement |
| JSON shape | Built inside aggregate | Built inside aggregate (same field keys) |
| Filters | tenant, status, audience, query-type mapping | Preserved unchanged in subquery WHERE |
| Sort | effectiveness_score desc nulls last, published_at desc | Preserved in subquery ORDER BY |

**Primary categories touched:** query structure, LIMIT placement, sort order
preservation, JSON object construction (unchanged field set).

### 6.2 Block 2 — related exceptions (`v_related_exceptions`)

| Aspect | HEAD (broken) | Working tree (fix) |
|---|---|---|
| Structure | `jsonb_agg(jsonb_build_object(...) ORDER BY ... LIMIT 5)` | Subquery builds `doc` jsonb objects, `ORDER BY detected_at DESC LIMIT 5`, outer `jsonb_agg(related_exception.doc)` |
| Change class | Query restructuring + LIMIT placement | Query restructuring + LIMIT placement |
| Payload masking | INTERNAL_ONLY vs masked summary CASE | Preserved |
| Filters | store_id, tenant_id, status, 24h window | Preserved |

**Primary categories touched:** query structure, LIMIT placement, candidate
selection (top 5 by detected_at), JSON construction.

### 6.3 What the diff does NOT change

```text
- No new tables, schemas, or grants
- No changes outside build_ai_context in this diff hunk set
- No edits to operational snapshot or downstream function bodies in the diff
- No Flutter/KDS/POS/runtime code
```

---

## 7. HEAD Revert Assessment

If the working tree were reverted to HEAD:

```text
Primary replay failure reintroduced:
  syntax error at or near "limit" — limit p_max_documents (document block)

Secondary replay failure reintroduced (after primary hypothetically patched alone):
  syntax error at or near "limit" — limit 5 (exceptions block)

Sequential migration replay would halt at position 0046 again.
Downstream migrations (0047 … 0062 … 0069 … 0142) would not be reached.
0142 reachability remains blocked upstream — NOT because of 0142 itself.
```

604350/604354 analyses and 604288/604292 verification records document these
failures as **pre-existing HEAD defects**, not regressions introduced by A1/A2
commits. A1 (70181253) and A2 (f89c70e0) did not modify 0046 per git history.

**Discard/revert is NOT recommended** for A3 disposition: it restores known
parse-time replay blockers without resolving context-builder retrieval logic.

---

## 8. Standalone Commit Feasibility

```text
Standalone single-file commit: FEASIBLE (in principle)
  - One path only: sql/migrations/0046_create_context_builder_rpc.sql
  - Selective git add mirrors A1 (4-file) and A2 (1-file) patterns
  - Must not be bundled with 0065/0066/0067 or any other residue

Prerequisite before commit (not satisfied by this Analysis):
  - 604514 Approval Gate with explicit single-file boundary
  - Replay verification through 0046 primary AND secondary scenarios
  - Confirmation that subquery LIMIT semantics match intended retrieval policy
  - Human selective-staging decision (manifest stage, not this Analysis)
```

This Analysis does **not** authorize staging or commit.

---

## 9. Risk Classification

```text
Severity        : HIGH
Blast radius    : catchmenu_knowledge.build_ai_context document + exception retrieval
Change type     : substantive SQL/PLpgSQL query restructure (not micro-fix)
Reversibility   : git-revertable, but revert reintroduces replay blockers
Runtime impact  : AI context document selection and related-exception surfacing
Coupling        : independent of A4 (0065) and A5 (0066/0067) — must stay split
Evidence gap    : working-tree fix present; replay PASS through 0046+ not re-run in this Analysis
```

Risk is **higher than A1 micro-fix** (+19/−19 aggregate) and **lower line-count
than A2 0035** (+681/−187), but **higher semantic risk than syntax-only micro-fix**
because LIMIT placement changes which rows enter the aggregate.

---

## 10. Discard Candidate Assessment

```text
DISCARD_CANDIDATE: NO
```

Rationale:

```text
- HEAD contains two confirmed parse-time defects (604350/604354 lineage).
- Working-tree change applies the documented Candidate-B subquery pattern for both.
- Reverting would restore replay halt at 0046 — opposite of residue disposition goal.
- 604391 assigned A3 "KEEP with separate gate," not discard.
- Skip-in-automated-replay policy is NOT applicable — 0046 creates runtime RPC objects
  and must parse/apply during sequential replay.
```

---

## 11. Approval Gate Requirement

```text
SEPARATE_APPROVAL_GATE_REQUIRED: YES
Recommended next document:
  604514_Approval_Gate_SQL_Migration_Replay_Blocker_A3_0046_Context_Builder_Disposition.md
```

The Approval Gate must:

```text
- authorize exactly one file: 0046
- require replay verification through primary + secondary limit scenarios
- forbid bundling with A4/A5 residue, tools, docs, or Scope D work
- preserve 0069 deferred and Scope D mainline blocked language
- define whether Implementation is doc-only record or SQL edit confirmation
  (WT fix already present — gate may authorize commit-only path after verification)
```

---

## 12. 0069 Analysis and Scope D Mainline

```text
0069 Analysis creation     : NOT authorized by this Analysis; remains deferred
Scope D mainline resume    : NOT authorized; remains blocked

Relationship:
  - 0046 sits upstream of 0069 in sequential replay order.
  - Committing a verified 0046 fix advances replay evidence toward later blockers
    (0063, 0065, 0066, 0067, 0068, then 0069) but does NOT itself:
      * create 0069 Analysis
      * close 0069 deferral
      * resume Scope D mainline (604250/604260/604310 implementation lanes)
  - 604390/604391 Group A split remains enforced for A4/A5.
```

---

## 13. Recommended Correction Lane

```text
604513 Analysis   (this document)
604514 Approval Gate
604515 Implementation (or commit-readiness record if WT already matches approved fix)
604516 Verification
604517 Audit
604518 Human Decision manifest (optional, for selective 0046 SQL staging — pattern 604512)
```

---

## 14. Final Analysis Result

```text
A3_0046_CONTEXT_BUILDER_REPLAY_BLOCKER_REQUIRES_APPROVAL_GATE_BEFORE_ACTION
```

```text
Summary:
  - 0046 git state: M, +67/−60, unstaged.
  - Two HEAD parse blockers: primary (limit p_max_documents) and secondary (limit 5).
  - WT fix: subquery + LIMIT placement for both blocks inside build_ai_context.
  - Change class: query restructuring, LIMIT placement, sort/candidate selection, JSON agg wrapper.
  - HEAD revert: reintroduces replay halt at 0046 — discard NOT recommended.
  - Standalone single-file commit: feasible under A3 boundary after Approval Gate + replay evidence.
  - Risk: HIGH; separate from A4 (0065) and A5 (0066/0067).
  - Approval Gate 604514 required before any staging/commit action.
  - 0069 Analysis and Scope D mainline remain blocked/deferred.
  - No SQL edit, staging, or commit performed by this Analysis.
```

---

## 15. Required Next Step

```text
604514_Approval_Gate_SQL_Migration_Replay_Blocker_A3_0046_Context_Builder_Disposition.md
```

This Analysis performs no further action.
