# 604519_Human_Decision_Gate_A3_0046_SQL_Selective_Staging_Manifest.md

Status: Complete
Lifecycle: Human Decision Gate — Commit Readiness Manifest
Gate Classification: A3 0046 Context Builder — Single-File SQL Selective Staging
Runtime Implementation Authorization: Not Granted By This Manifest
Owner: Human (pending staging decision)
Last Updated: 2026-07-06

This manifest prepares the Human Decision for selective staging and commit of
**one** SQL file only: `sql/migrations/0046_create_context_builder_rpc.sql`.
It performs no staging and no commit.

---

## 1. Authority And Prior Closeout

```text
604513–604517 A3 documentation track : CLOSED / committed (f6ed47be)
604517 Final Audit Decision:
  ACCEPT_A3_0046_CONTEXT_BUILDER_REPLAY_BLOCKER_DISPOSITION_AND_CLOSE_604513_604517_TRACK_WITH_STAGING_STILL_REQUIRING_HUMAN_DECISION

604514 governing Approval (A3 single-file boundary):
  APPROVED_FOR_A3_0046_CONTEXT_BUILDER_REPLAY_BLOCKER_DISPOSITION_ONLY_WITH_HIGH_RISK_SINGLE_FILE_SQL_BOUNDARY

604350/604354 lineage: Candidate B subquery wrapper + LIMIT-at-subquery-level;
  HEAD revert/discard prohibited (HEAD retains jsonb_agg-internal LIMIT parse blockers).
```

Separate tracks already committed (must not be mixed into this staging):

```text
A1 SQL (0038, 0042, 0063, 0068) : committed (70181253)
A2 SQL (0035)                     : committed (f89c70e0)
No-payment KDS (604500–604504 + 0143) : committed (cb2147ce)
Metadata sync (604506–604510)     : committed (fc7797c5)
A3 docs (604513–604517)           : committed (f6ed47be)
```

---

## 2. Commit Readiness Decision

```text
COMMIT_READY
```

Human may proceed with selective `git add` of the single 0046 path below,
followed by commit, after explicit Human approval **and** after satisfying
604514 §6 replay/parse-gate preconditions (or explicit Human waiver documented
in the commit decision). This manifest does not execute staging.

---

## 3. Git Gate Evidence (2026-07-06)

Commands executed:

```powershell
git status --short
git diff --check
git diff --cached --name-only
git diff --numstat -- sql/migrations/0046_create_context_builder_rpc.sql
git diff --name-status -- sql/migrations/0046_create_context_builder_rpc.sql
git diff -- sql/migrations/0046_create_context_builder_rpc.sql
git diff --cached --name-only -- sql/
git diff --cached --name-only -- tools/
```

Results:

```text
git diff --check                 : exit 0 (PASS; LF/CRLF warnings only)
git diff --cached --name-only    : empty
staged files                     : none
staged SQL/migration             : none
staged tools                     : none
0069 Analysis artifact           : not found (replay-blocker 0069 Analysis)
Scope D mainline resume          : not observed
```

**0046 metrics (working tree vs HEAD):**

```text
git status --short : M  sql/migrations/0046_create_context_builder_rpc.sql
git diff --numstat : 67  60  sql/migrations/0046_create_context_builder_rpc.sql
git diff --name-status : M  sql/migrations/0046_create_context_builder_rpc.sql
```

**Working-tree content checks (0046 only):**

```text
LIMIT inside jsonb_agg(...) blocks (WT)     : 0
Row-level LIMIT p_max_documents (WT)        : 1 (subquery block — document retrieval)
Row-level LIMIT 5 (WT)                      : 1 (subquery block — related exceptions)
Subquery wrapper pattern                    : present for both corrected blocks
HEAD: limit p_max_documents inside jsonb_agg : yes (parse blocker — primary)
HEAD: limit 5 inside jsonb_agg               : yes (parse blocker — secondary)
```

**Other SQL paths with working-tree diffs (excluded — do not stage with 0046):**

```text
0065, 0066, 0067 (+ other sql/migrations/* M paths per git status)
```

Selective `git add` of `0046_create_context_builder_rpc.sql` alone is feasible
without pulling A4/A5 residue or other SQL groups.

---

## 4. Included Files Manifest (1)

| # | Path | Git state | Diff summary (working tree vs HEAD) |
|---:|---|:---:|---|
| 1 | `sql/migrations/0046_create_context_builder_rpc.sql` | `M` | +67/−60 — Candidate B subquery wrapper; jsonb_agg-internal LIMIT blockers removed; row-level `LIMIT p_max_documents` and `LIMIT 5` in subqueries |

Character matches 604513/604515/604516/604517 disposition record and 604514
single-file A3 boundary.

---

## 5. Excluded Files Manifest

### 5.1 A4 / A5 Group A residue (separate future gates)

```text
sql/migrations/0065_create_security_isolation_rpc.sql   (M)
sql/migrations/0066_create_ledger_integrity_rpc.sql     (M)
sql/migrations/0067_create_cron_scheduler_rpc.sql       (M)
```

### 5.2 A1 / A2 committed SQL (do not restage)

```text
sql/migrations/0035_verify_schema.sql
sql/migrations/0038_create_toss_webhook_processor_rpc.sql
sql/migrations/0042_create_delivery_order_intake_rpc.sql
sql/migrations/0063_patch_core_rpc_i18n_diagnostics.sql
sql/migrations/0068_create_realtime_edge_rpc.sql
```

### 5.3 Other SQL residue

```text
0138, 0142
024/0024, 030/0030, 032/0032 pairs
0136, 0139, 0141, seed_yoonsul_menu.sql
0143_add_no_payment_kds_release_policy.sql (committed cb2147ce — separate track)
Any other sql/migrations/* change
```

### 5.4 Documentation / tools / runtime

```text
604513–604517 (committed f6ed47be)
604518 manifest (untracked — not part of A3 SQL commit)
604396, 604397, 604403, 604505, 604511, 604512 manifests
tools/* (4 untracked helper files)
runtime / Flutter / KDS / POS application code
0069 Analysis (deferred — do not create)
Scope D mainline lifecycle docs
This manifest (604519) — optional separate doc commit
```

---

## 6. File-Level git add Command

Run from repository root. **Not executed by this manifest.**

```powershell
git add "sql/migrations/0046_create_context_builder_rpc.sql"
```

---

## 7. Post-Add Verification Commands

Run immediately after `git add` and before `git commit`. **Not executed by this manifest.**

```powershell
git diff --cached --name-only
git status --short
git diff --cached --name-only -- sql/
git diff --cached --name-only -- tools/
```

**Expected cached set:** exactly one path:

```text
sql/migrations/0046_create_context_builder_rpc.sql
```

Confirm exclusions not staged:

```powershell
git diff --cached --name-only | Select-String '0035|0038|0042|0063|0065|0066|0067|0068|0138|0142|0143|0024|0030|0032|0136|0139|0141|seed|tools|0069|docs/'
```

Expected: empty (no matches other than 0046).

Expected cached set:

```powershell
(git diff --cached --name-only).Count   # 1
git diff --cached --name-only           # sql/migrations/0046_create_context_builder_rpc.sql only
```

Optional diff review:

```powershell
git diff --cached --stat
git diff --cached -- sql/migrations/0046_create_context_builder_rpc.sql
```

---

## 8. Recommended Commit Message

```text
fix: correct 0046 context builder aggregation limits
```

Suggested commit body (optional):

```text
Apply approved A3 0046 context-builder LIMIT correction only.
Authority: 604514 Approval Gate, 604517 Audit closeout, 604350/604354 Candidate B lineage.
Removes jsonb_agg-internal LIMIT parse blockers; row-level subquery caps preserved.
Excludes A4/A5 residue, A1/A2 (already committed), 0143, tools, Scope D / 0069.
Replay/parse-gate evidence per 604514 §6 reviewed or waived by Human.
```

---

## 9. Human Decision Checklist

Before staging, Human confirms:

```text
[ ] 604514 §6 replay/parse-gate preconditions reviewed OR explicitly waived
[ ] Only sql/migrations/0046_create_context_builder_rpc.sql will be staged
[ ] No A4/A5, A1 restage, A2 restage, 0143, 0138/0142 residue, zero-pad pairs, seed, tools, or docs mixed in
[ ] HEAD revert/discard of 0046 WT rewrite is NOT chosen (prohibited by 604514/604517)
[ ] Group A split remains enforced — A4/A5 each require separate future gates
[ ] Scope D mainline and 0069 remain blocked/deferred after this commit
[ ] A3 documentation track (604513–604517) is not restaged in this SQL commit
```

---

## 10. Boundary Confirmation

Not performed by this manifest:

```text
staging    : NO
commit     : NO
0046 staging (by this manifest) : NO — Human executes after checklist
non-0046 SQL staging : NO
tools staging : NO
0069 Analysis creation : NO
Scope D mainline resume : NO
```

---

## 11. Final Rule

This manifest records staging **readiness only**. Commit of 0046 does not
authorize A4/A5 SQL disposition, Scope D mainline resume, or 0069 Analysis.

604514 §6 requires replay/parse-gate verification outcome before commit unless
Human explicitly documents waiver. This manifest does not substitute for that
evidence.

If this manifest conflicts with 604517 Audit, 604514 Approval Gate, or 604350/604354
lineage, the stricter boundary wins.
