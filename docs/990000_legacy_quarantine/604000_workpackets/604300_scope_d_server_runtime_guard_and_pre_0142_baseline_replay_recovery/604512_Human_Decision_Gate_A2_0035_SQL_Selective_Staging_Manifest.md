# 604512_Human_Decision_Gate_A2_0035_SQL_Selective_Staging_Manifest.md

Status: Complete
Lifecycle: Human Decision Gate — Commit Readiness Manifest
Gate Classification: A2 0035 Verification Rewrite — Single-File SQL Selective Staging
Runtime Implementation Authorization: Not Granted By This Manifest
Owner: Human (pending staging decision)
Last Updated: 2026-07-05

This manifest prepares the Human Decision for selective staging and commit of
**one** SQL file only: `sql/migrations/0035_verify_schema.sql`. It performs no
staging and no commit.

---

## 1. Authority And Prior Closeout

```text
604398–604402 A2 documentation track : CLOSED / committed (199dfc02)
604402 Final Audit Decision:
  ACCEPT_A2_0035_VERIFICATION_REWRITE_DISPOSITION_AND_CLOSE_604398_604402_TRACK_WITH_STAGING_STILL_REQUIRING_HUMAN_DECISION

604399 governing Approval (A2 single-file boundary):
  APPROVED_FOR_A2_0035_VERIFICATION_REWRITE_DISPOSITION_ONLY_WITH_HIGH_RISK_SINGLE_FILE_SQL_BOUNDARY

604276 lineage: 0035 DO-block verification rewrite previously approved;
  discard/revert to HEAD prohibited (HEAD retains nested-procedure parse blocker).

604506–604510 metadata sync lane : CLOSED / committed (fc7797c5)
604510 Final Audit Decision:
  ACCEPT_METADATA_INDEX_NAVIGATION_SYNC_AFTER_A1_A2_NO_PAYMENT_COMMITS_AND_CLOSE_604506_604510_TRACK_WITH_STAGING_STILL_REQUIRING_HUMAN_DECISION
```

Separate tracks already committed (must not be mixed into this staging):

```text
A1 SQL micro-fix (0038, 0042, 0063, 0068) : committed (70181253)
No-payment KDS policy (604500–604504 + 0143) : committed (cb2147ce)
Metadata corrections (000005, 000007, 604001, 604300_Index, 604306) : committed (fc7797c5)
```

---

## 2. Commit Readiness Decision

```text
COMMIT_READY
```

Human may proceed with selective `git add` of the single 0035 path below,
followed by commit, after explicit Human approval **and** after satisfying
604399 §6 replay/parse-gate preconditions (or explicit Human waiver documented
in the commit decision). This manifest does not execute staging.

---

## 3. Git Gate Evidence (2026-07-05)

Commands executed:

```powershell
git status --short
git diff --check
git diff --cached --name-only
git diff --numstat -- sql/migrations/0035_verify_schema.sql
git diff --name-status -- sql/migrations/0035_verify_schema.sql
git diff -- sql/migrations/0035_verify_schema.sql
git diff --cached --name-only -- sql/
git diff --cached --name-only -- tools/
git diff --name-only -- sql/
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

**0035 metrics (working tree vs HEAD):**

```text
git status --short : M  sql/migrations/0035_verify_schema.sql
git diff --numstat : 681  187  sql/migrations/0035_verify_schema.sql
git diff --name-status : M  sql/migrations/0035_verify_schema.sql
```

**Working-tree content checks (0035 only):**

```text
assert_true / procedure assert_true in WT 0035 : 0 occurrences
assert_true references in HEAD 0035            : 86 call/reference occurrences
procedure assert_true in HEAD 0035             : 1 nested-procedure definition (parse blocker)
inline PASS/FAIL structure in WT               : present (v_pass_count, v_error_count, [PASS], [FAIL])
DO $$ verification block                       : present; verification-only (Creates: none)
```

**HEAD revert assessment:**

```text
Reverting WT 0035 to HEAD would reintroduce the nested assert_true procedure
and the documented parse-time replay blocker at migration position 0035.
604399 and 604402 prohibit discard/revert policy for this file.
```

**Other SQL paths with working-tree diffs (excluded — do not stage with 0035):**

```text
0046, 0065, 0066, 0067, 0142, 024, 030, 032
(and any other sql/migrations/* M paths visible in git status)
```

Selective `git add` of `0035_verify_schema.sql` alone is feasible without
pulling A3/A4/A5 residue or other SQL groups.

---

## 4. Included Files Manifest (1)

| # | Path | Git state | Diff summary (working tree vs HEAD) |
|---:|---|:---:|---|
| 1 | `sql/migrations/0035_verify_schema.sql` | `M` | +681/−187 — DO-block verification rewrite; nested `assert_true` procedure removed; inline PASS/FAIL counters |

Character matches 604398/604400/604401/604402 disposition record and 604399
single-file A2 boundary.

---

## 5. Excluded Files Manifest

### 5.1 A3 / A4 / A5 Group A residue (separate future gates)

```text
sql/migrations/0046_create_context_builder_rpc.sql   (M)
sql/migrations/0065_create_security_isolation_rpc.sql (M)
sql/migrations/0066_create_ledger_integrity_rpc.sql  (M)
sql/migrations/0067_create_cron_scheduler_rpc.sql      (M)
```

### 5.2 A1 SQL (already committed — do not restage)

```text
sql/migrations/0038_create_toss_webhook_processor_rpc.sql
sql/migrations/0042_create_delivery_order_intake_rpc.sql
sql/migrations/0063_patch_core_rpc_i18n_diagnostics.sql
sql/migrations/0068_create_realtime_edge_rpc.sql
(committed 70181253 — clean vs HEAD)
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
604398–604402 (committed)
604506–604510 (committed)
604396, 604397, 604403, 604505, 604511 manifests (untracked or separate commits)
604390 parent gate (untracked)
tools/* (4 untracked helper files)
runtime / Flutter / KDS / POS application code
0069 Analysis (deferred — do not create)
Scope D mainline lifecycle docs
This manifest (604512) — optional separate doc commit
```

---

## 6. File-Level git add Command

Run from repository root. **Not executed by this manifest.**

```powershell
git add "sql/migrations/0035_verify_schema.sql"
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
sql/migrations/0035_verify_schema.sql
```

Confirm exclusions not staged:

```powershell
git diff --cached --name-only | Select-String '0038|0042|0046|0063|0065|0066|0067|0068|0138|0142|0143|0024|0030|0032|0136|0139|0141|seed|tools|0069|docs/'
```

Expected: empty.

Optional diff review:

```powershell
git diff --cached --stat
git diff --cached -- sql/migrations/0035_verify_schema.sql
```

---

## 8. Recommended Commit Message

```text
fix: rewrite 0035 schema verification replay gate
```

Suggested commit body (optional):

```text
Apply approved A2 0035 verification rewrite only.
Authority: 604399 Approval Gate, 604402 Audit closeout, 604276 lineage.
Removes nested assert_true parse blocker; inline PASS/FAIL DO-block rewrite.
Excludes A3/A4/A5 residue, A1 (already committed), 0143, tools, Scope D / 0069.
Replay/parse-gate evidence per 604399 §6 reviewed or waived by Human.
```

---

## 9. Human Decision Checklist

Before staging, Human confirms:

```text
[ ] 604399 §6 replay/parse-gate preconditions reviewed OR explicitly waived
[ ] Only sql/migrations/0035_verify_schema.sql will be staged
[ ] No A3/A4/A5, A1 restage, 0143, 0138/0142 residue, zero-pad pairs, seed, tools, or docs mixed in
[ ] HEAD revert/discard of 0035 WT rewrite is NOT chosen (prohibited by 604399/604402)
[ ] Group A split remains enforced — A3/A4/A5 each require separate future gates
[ ] Scope D mainline and 0069 remain blocked/deferred after this commit
[ ] Metadata sync (604506–604510) is not restaged in this SQL commit
```

---

## 10. Boundary Confirmation

Not performed by this manifest:

```text
staging    : NO
commit     : NO
0035 staging (by this manifest) : NO — Human executes after checklist
non-0035 SQL staging : NO
tools staging : NO
0069 Analysis creation : NO
Scope D mainline resume : NO
```

---

## 11. Final Rule

This manifest records staging **readiness only**. Commit of 0035 does not
authorize A3/A4/A5 SQL disposition, Scope D mainline resume, or 0069 Analysis.

604399 §6 requires replay/parse-gate verification outcome before commit unless
Human explicitly documents waiver. This manifest does not substitute for that
evidence.

If this manifest conflicts with 604402 Audit, 604399 Approval Gate, or 604276
lineage, the stricter boundary wins.
