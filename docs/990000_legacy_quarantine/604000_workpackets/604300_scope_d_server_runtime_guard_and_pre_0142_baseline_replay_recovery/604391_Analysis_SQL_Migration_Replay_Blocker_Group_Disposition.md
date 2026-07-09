# 604391_Analysis_SQL_Migration_Replay_Blocker_Group_Disposition.md

Status: Complete
Lifecycle: Analysis
Gate Classification: Group A Replay Blocker SQL Residue — Disposition Analysis
Runtime Implementation Authorization: Not Granted
Owner: TBD
Last Updated: 2026-07-05

This is an analysis document only. It classifies Group A replay-blocker SQL
residue and proposes disposition directions. It performs no SQL edit, migration
edit, reset, discard, rename, staging, or commit. It does not create 0069
Analysis and does not resume Scope D mainline.

Authority:

```text
604390_Approval_Gate_SQL_Migration_Residue_Disposition_Before_Scope_D_Resume.md
Final Approval Decision:
  APPROVED_FOR_SQL_RESIDUE_TRACK_SEPARATION_WITH_SCOPE_D_AND_0069_STILL_BLOCKED
```

Prior classification reference:

```text
604389_Analysis_SQL_Migration_Residue_Disposition_Before_Scope_D_Resume.md
(Group A = 0035-0068 replay-blocker review set)
604383-604387 quarantine-policy track: CLOSED / committed
```

See `docs/000015_Korean_Document_And_Encoding_Safety_Rules.md` for encoding rules.

---

## 1. Analysis Scope

### 1.1 In scope — Group A only (9 files)

```text
sql/migrations/0035_verify_schema.sql
sql/migrations/0038_create_toss_webhook_processor_rpc.sql
sql/migrations/0042_create_delivery_order_intake_rpc.sql
sql/migrations/0046_create_context_builder_rpc.sql
sql/migrations/0063_patch_core_rpc_i18n_diagnostics.sql
sql/migrations/0065_create_security_isolation_rpc.sql
sql/migrations/0066_create_ledger_integrity_rpc.sql
sql/migrations/0067_create_cron_scheduler_rpc.sql
sql/migrations/0068_create_realtime_edge_rpc.sql
```

### 1.2 Explicit exclusions

```text
Group B : 0138_patch_integration_functions.sql
Group C : 024/030/032 + 0024/0030/0032 pairs
Group D : 0142_patch_toss_mvp_payment_intent_binding.sql
Group E : 0136, 0139, 0141, seed_yoonsul_menu.sql
tools/* : excluded (4 untracked helper files remain; separate tooling track)
0069 Analysis, runtime code, Scope D mainline resume
```

---

## 2. Commands Executed

All commands below were run from repository root on 2026-07-05:

```powershell
git status --short
git diff --check
git diff --cached --name-only
git diff --name-status -- (9 Group A paths)
git diff -- (each Group A path individually)
git status --short | Select-String '0069|604391|604392|604393|604394|604395'
```

Additional read-only inspection:

```text
git diff --stat -- (9 Group A paths)
git diff --numstat -- (9 Group A paths)
Read-only cross-reference to 604270/604280/604300 lineage docs (approval trace
candidates only; no lane assignment certainty)
```

No staging or commit was performed by this Analysis.

---

## 3. Repository Gate State

```text
git diff --cached --name-only : empty
staged SQL/migration files       : none
git diff --check                 : exit 0 (PASS)
```

All nine Group A paths show `M` (tracked modified) in `git status --short`.

`git diff --name-status` for Group A:

```text
M  sql/migrations/0035_verify_schema.sql
M  sql/migrations/0038_create_toss_webhook_processor_rpc.sql
M  sql/migrations/0042_create_delivery_order_intake_rpc.sql
M  sql/migrations/0046_create_context_builder_rpc.sql
M  sql/migrations/0063_patch_core_rpc_i18n_diagnostics.sql
M  sql/migrations/0065_create_security_isolation_rpc.sql
M  sql/migrations/0066_create_ledger_integrity_rpc.sql
M  sql/migrations/0067_create_cron_scheduler_rpc.sql
M  sql/migrations/0068_create_realtime_edge_rpc.sql
```

Filter scan: no 0069 Analysis artifact; 604392-604395 not yet created.

---

## 4. Per-File Diff Summary Table

| File | Git state | Diff scale (+/− lines) | Primary change type | Diff character (read-only) |
|---|---|---:|---|---|
| 0035 | modified | +681 / −187 | DO-block / verification rewrite | Removes nested `procedure assert_true` helper; large verification migration body refactor |
| 0038 | modified | +1 / −1 | UPDATE SET assignment syntax | `processing_error :=` → `processing_error =` in Toss webhook processor |
| 0042 | modified | +1 / −1 | UPDATE SET assignment syntax | `result_payload :=` → `result_payload =` in delivery order intake RPC |
| 0046 | modified | +67 / −60 | Query / LIMIT restructuring | Context-builder document fetch query reshaped (LIMIT placement / subquery) |
| 0063 | modified | +15 / −15 | UPDATE SET assignment syntax | Multiple `:=` → `=` in payment-intent / order update paths |
| 0065 | modified | +388 / −146 | Inline-procedure removal / guard refactor | Removes nested `add_check` procedure helpers; large security-isolation RPC body change |
| 0066 | modified | +139 / −60 | Aggregate SQL syntax repair | Replaces invalid `jsonb_agg(id limit 5)` with subquery-limited aggregates |
| 0067 | modified | +11 / −1319 | Duplicate-content removal / no-op replacement | Replaces mistaken duplicate of 0066 body with short no-op safety migration note |
| 0068 | modified | +2 / −2 | UNIQUE constraint definition | `UNIQUE (...)` → `UNIQUE NULLS NOT DISTINCT (...)` on tenant_id + function_code |

**Note on approval trace:** Several files have **candidate** Human approval references
in closed documentation lanes (e.g. 604276 for 0035/0038, 604286 for 0042,
604319+ for 0067). This Analysis does **not** treat those as repository commit
authorization. Each file still requires **604392+ explicit SQL commit Approval**
linked to replay evidence.

---

## 5. Per-File Risk And Disposition Table

| File | Replay relation | Risk | Disposition recommendation | Blocks Scope D | Blocks 0069 | Approval requirement |
|---|---|---:|---|---|---|---|
| 0035 | **Direct** pre-0142 baseline blocker | HIGH | REQUIRES_REPLAY_VERIFICATION + SPLIT_TO_SEPARATE_APPROVAL_GATE | YES | YES | must be split; cannot decide without human |
| 0038 | **Direct** baseline syntax blocker | MEDIUM | KEEP_AND_APPROVE_FOR_SEPARATE_SQL_COMMIT (after replay pass) | YES | YES | must be split (micro-fix batch) |
| 0042 | **Direct** 0042 replay blocker | MEDIUM | KEEP_AND_APPROVE_FOR_SEPARATE_SQL_COMMIT (after replay pass) | YES | YES | must be split (micro-fix batch) |
| 0046 | **Direct** 0046 context-builder blocker | HIGH | REQUIRES_REPLAY_VERIFICATION + SPLIT_TO_SEPARATE_APPROVAL_GATE | YES | YES | must be split |
| 0063 | **Direct** 0063 replay blocker | MEDIUM | KEEP_AND_APPROVE_FOR_SEPARATE_SQL_COMMIT (after replay pass) | YES | YES | must be split |
| 0065 | **Direct** 0065 security-isolation blocker | HIGH | REQUIRES_DIFF_REDUCTION review + REQUIRES_REPLAY_VERIFICATION + SPLIT | YES | YES | must be split |
| 0066 | **Direct** 0066 ledger-integrity blocker | HIGH | REQUIRES_REPLAY_VERIFICATION + SPLIT_TO_SEPARATE_APPROVAL_GATE | YES | YES | must be split |
| 0067 | **Direct** 0067 sequence/duplicate blocker | HIGH | REQUIRES_REPLAY_VERIFICATION + SPLIT_TO_SEPARATE_APPROVAL_GATE | YES | YES | must be split; cannot bundle with 0066 |
| 0068 | **Direct** 0068 constraint blocker | MEDIUM | KEEP_AND_APPROVE_FOR_SEPARATE_SQL_COMMIT (after replay pass) | YES | YES | must be split (micro-fix batch) |

**Discard candidates:** No file is recommended as an unconditional
`DISCARD_CANDIDATE` in this Analysis. Reverting any working-tree change back to
HEAD would reintroduce known replay failures documented in 604270/604280/604300
lineage. If Human explicitly chooses a skip/discard policy for a specific file,
that is a **604392** decision, not enacted here.

---

## 6. Special-File Analysis

### 6.1 0042_create_delivery_order_intake_rpc.sql

```text
Read-only diff confirms exactly one assignment correction:
  -    result_payload := jsonb_build_object(
  +    result_payload = jsonb_build_object(
Relation candidate: 604280 cross-scope 0042 delivery-order-intake blocker lane.
Prior lane docs (604286 Module, 604288 Verification, 604289 Audit) describe this
same one-line correction as already implemented in an earlier authorized pass;
working-tree change is present but uncommitted.
0069 mixing: FORBIDDEN — 0042 sits far earlier in baseline chain than 0069.
Disposition: KEEP_AND_APPROVE_FOR_SEPARATE_SQL_COMMIT after clean replay reaches
0042 and beyond under Group A micro-fix sub-batch.
```

### 6.2 0046_create_context_builder_rpc.sql

```text
Diff is a substantive query/limit restructure (+67/−60), not a one-line syntax fix.
Relation candidate: 604350-604359 context-builder replay-recovery documentation
set inside 604300 (SQL change is separate from stale doc correction work).
Stale document correction must not be confused with this SQL diff.
Disposition: SPLIT_TO_SEPARATE_APPROVAL_GATE; REQUIRES_REPLAY_VERIFICATION through
0046 primary/secondary blocker scenarios before commit.
```

### 6.3 0038_create_toss_webhook_processor_rpc.sql

```text
One-line UPDATE SET fix: processing_error := → processing_error =
Relation candidate: 604270 baseline blocker Class A; upstream of 0039 dependency.
Must NOT be bundled with Group D 0142 (Toss payment-intent binding patch).
Disposition: micro-fix sub-batch with 0042/0063/0068 after replay evidence.
```

### 6.4 0035_verify_schema.sql

```text
Largest Group A diff (+681/−187). Functions as a verification migration (DO block
schema checks), not a feature migration — but it still executes during sequential
replay and blocked 604260 local replay per 604270 lineage.
Relation candidate: 604270 Class B verification rewrite approval trace (604276).
Question answered: it is a real migration file that runs at apply time; it is not
merely a post-apply helper script.
Disposition: own sub-batch; REQUIRES_REPLAY_VERIFICATION from clean DB through 0035;
REQUIRES_DIFF_REDUCTION Human review given diff size; must not ship in a single
commit with smaller syntax fixes.
Optional Human alternative (604392 only): DISCARD_CANDIDATE_PENDING_HUMAN_CONFIRMATION
if Human re-selects skip-in-automated-replay policy — 604276 previously rejected
that branch for 0035; not recommended here.
```

### 6.5 0063–0068 cluster

```text
0063 — diagnostics/payment patch lane candidate (604342 Audit context); assignment
       syntax fixes only; MEDIUM risk; micro-fix batch candidate after replay.
0065 — security isolation; large inline-procedure removal; HIGH; isolated sub-batch.
0066 — ledger integrity; aggregate limit SQL repair; HIGH; isolated sub-batch.
0067 — cron scheduler; removes ~1300 lines of duplicated 0066 content, replaces
       with no-op safety stub referencing prior duplicate under "604320"; CRITICAL
       sequence integrity; must never commit together with 0066 in one ambiguous
       commit; own sub-batch with mandatory replay through 0067→0068→… chain.
0068 — realtime edge; UNIQUE NULLS NOT DISTINCT constraint tweak; MEDIUM; micro-fix
       batch candidate; 604328 audit context for 0068 blocker acceptance.
Scope D mainline direct relation: INDIRECT for payment semantics (0063 touches
confirm paths) but DIRECT for trustworthy replay-to-0142 evidence gate.
0069 relation: all six are DIRECT blockers upstream of 0069 in sequential replay.
```

---

## 7. Proposed Sub-Batch Split (Recommendation Only)

604390 forbids folding all Group A paths into one commit. This Analysis proposes
**five sub-batches** for 604392 Human consideration:

```text
Sub-batch A1 — Micro syntax / constraint fixes (4 files):
  0038, 0042, 0063, 0068
  Prerequisite: clean replay evidence through each file's migration number
  Risk aggregate: MEDIUM

Sub-batch A2 — Verification rewrite (1 file):
  0035
  Prerequisite: dedicated replay + diff review; largest blast radius
  Risk: HIGH

Sub-batch A3 — Context builder restructure (1 file):
  0046
  Prerequisite: 0046 primary/secondary replay scenarios per 604350-series docs
  Risk: HIGH

Sub-batch A4 — Security isolation refactor (1 file):
  0065
  Prerequisite: 0065 primary/secondary replay evidence
  Risk: HIGH

Sub-batch A5 — Ledger + cron sequence repair (2 files, sequential commits):
  0066 then 0067 (never one combined commit)
  Prerequisite: replay proves 0067 no-op stub restores correct chain order
  Risk: HIGH
```

**Can Group A be one approval / one commit?** **NO.**

**Split required?** **YES** — at minimum five sub-batches; 0066 and 0067 must not
share a single commit.

---

## 8. Scope D Mainline And 0069 Status

```text
Scope D mainline: BLOCKED (unchanged)
  - Group A residue prevents trustworthy replay judgment for 604260/604250/604400
  - Closing Group A alone does not authorize Scope D resume (Groups B-E remain)

0069 Analysis: DEFERRED (unchanged)
  - Not created by this Analysis
  - 0069 sits after 0068; unresolved 0035-0068 WT changes block clean replay
  - Must not be opened while Group A disposition is incomplete
```

---

## 9. tools Residue (Reference Only)

```text
Four untracked tools files remain per 604389/604390:
  tools/audit_lifecycle_folders.py
  tools/compare_directory_tree_index.py
  tools/missing_from_000005.txt
  tools/sync_docs_index_from_tree.py

Excluded from 604391 scope. Not analyzed beyond existence confirmation.
Must not be mixed into Group A SQL disposition commits.
```

---

## 10. Boundary Confirmation

Confirmed not performed by this Analysis:

```text
- SQL modification                          : NO
- migration modification                    : NO
- SQL reset / discard / rename              : NO
- SQL staging                               : NO
- tools modification / staging              : NO
- runtime code modification                 : NO
- 0069 Analysis creation                    : NO
- Scope D mainline resume                   : NO
- staging                                   : NO
- commit                                      : NO
```

Only this Markdown Analysis artifact is created.

---

## 11. 604392 Approval Gate Requirement

**Finding: YES — 604392 Approval Gate is required before any Group A SQL action.**

604392 must authorize, per sub-batch or per file:

```text
- explicit allowed file list (no cross-group mixing)
- replay verification commands and pass criteria
- whether to KEEP working-tree changes or DISCARD to HEAD (per file, if Human chooses)
- commit boundary (which sub-batch may stage together)
- forbidden mixing with 0142, zero-pad pairs, seed files, 0138, or tools
```

604392 must **not** authorize 0069 Analysis or Scope D mainline resume.

Recommended numbering (from 604390):

```text
604391 Analysis (this document)
604392 Approval Gate
604393 Implementation
604394 Verification
604395 Audit
```

---

## 12. Final Analysis Result

```text
GROUP_A_REPLAY_BLOCKER_SQL_RESIDUE_REQUIRES_APPROVAL_GATE_BEFORE_ACTION
```

```text
Summary:
  - Authority: 604390 track-separation Approval; prior 604389 Group A classification.
  - All 9 Group A files remain tracked modified; unstaged; git diff --check PASS.
  - Per-file diff summaries and dispositions recorded; no unconditional discard
    candidates recommended.
  - One monolithic Group A commit is NOT safe; split into at least five sub-batches.
  - 0042 confirmed as one-line result_payload assignment fix (604280 lineage).
  - 0046 is substantive SQL, distinct from stale doc correction in 604350-series.
  - 0067 duplicate-removal is sequence-critical and must commit separately from 0066.
  - Scope D mainline and 0069 remain blocked/deferred.
  - tools excluded; Groups B-E untouched.
  - Next step: 604392 Approval Gate.
```

---

## 13. Required Next Step

```text
604392_Approval_Gate_SQL_Migration_Replay_Blocker_Group_Disposition.md
```

---

## 14. Final Rule

This Analysis does not authorize SQL/migration remediation.

If this Analysis conflicts with an approved ChangeContract or Approval, the
stricter boundary wins.

Scope D mainline and 0069 Analysis must not resume automatically from this
Analysis.
