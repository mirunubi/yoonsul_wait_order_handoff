# 604526_Human_Decision_Gate_A4_0065_SQL_Selective_Staging_Manifest.md

Status: Complete
Lifecycle: Human Decision Gate — Commit Readiness Manifest
Gate Classification: A4 0065 Security Isolation — Single-File SQL Selective Staging
Runtime Implementation Authorization: Not Granted By This Manifest
Owner: Human (pending staging decision)
Last Updated: 2026-07-06

This manifest prepares the Human Decision for selective staging and commit of
**one** SQL file only: `sql/migrations/0065_create_security_isolation_rpc.sql`.
It performs no staging and no commit.

---

## 1. Authority And Prior Closeout

```text
604520–604524 A4 documentation track : CLOSED / committed (25b620a4)
604524 Final Audit Decision:
  ACCEPT_A4_0065_SECURITY_ISOLATION_REPLAY_BLOCKER_DISPOSITION_AND_CLOSE_604520_604524_TRACK_WITH_STAGING_STILL_REQUIRING_HUMAN_DECISION

604521 governing Approval (A4 single-file boundary):
  APPROVED_FOR_A4_0065_SECURITY_ISOLATION_REPLAY_BLOCKER_DISPOSITION_ONLY_WITH_HIGH_RISK_SINGLE_FILE_SQL_BOUNDARY

604343/604307 lineage: Candidate A inline procedure removal (13 call sites) +
  subquery LIMIT relocation for scan_cross_tenant_risk sample_ids;
  HEAD revert/discard prohibited (HEAD retains nested-procedure and
  jsonb_agg-internal LIMIT parse blockers).
```

Separate tracks already committed (must not be mixed into this staging):

```text
A1 SQL (0038, 0042, 0063, 0068) : committed (70181253)
A2 SQL (0035)                     : committed (f89c70e0)
A3 SQL (0046)                     : committed (6847d69b)
No-payment KDS (604500–604504 + 0143) : committed (cb2147ce)
Metadata sync (604506–604510)     : committed (fc7797c5)
A4 docs (604520–604524)           : committed (25b620a4)
```

---

## 2. Commit Readiness Decision

```text
COMMIT_READY
```

Human may proceed with selective `git add` of the single 0065 path below,
followed by commit, after explicit Human approval **and** after satisfying
604521 §6 replay/parse-gate and security-isolation-compile preconditions (or
explicit Human waiver documented in the commit decision). This manifest does
not execute staging.

---

## 3. Git Gate Evidence (2026-07-06)

Commands executed:

```powershell
git status --short
git diff --check
git diff --cached --name-only
git diff --numstat -- sql/migrations/0065_create_security_isolation_rpc.sql
git diff --name-status -- sql/migrations/0065_create_security_isolation_rpc.sql
git diff -- sql/migrations/0065_create_security_isolation_rpc.sql
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

**0065 metrics (working tree vs HEAD):**

```text
git status --short : M  sql/migrations/0065_create_security_isolation_rpc.sql
git diff --numstat : 388  146  sql/migrations/0065_create_security_isolation_rpc.sql
git diff --name-status : M  sql/migrations/0065_create_security_isolation_rpc.sql
```

**Working-tree content checks (0065 only):**

```text
nested procedure add_check (WT)              : 0
remaining call add_check(...) (WT)           : 0
removed call add_check lines (diff)          : 13
added v_total := v_total + 1 blocks (diff) : 13 (run_isolation_audit inline expansions)
jsonb_agg(... limit ...) inside aggregate (WT): 0
row-level LIMIT 5 in sample subquery (WT)    : 1 (scan_cross_tenant_risk sample_ids)
SECURITY DEFINER functions preserved (WT)    : 4
HEAD: nested procedure add_check             : 1 (parse blocker — primary)
HEAD: call add_check                         : 13
HEAD: jsonb_agg(order_id limit 5)            : 1 (parse blocker — secondary)
```

**Other SQL paths with working-tree diffs (excluded — do not stage with 0065):**

```text
0066, 0067, 0138, 0142 (+ other sql/migrations/* M paths per git status)
```

Selective `git add` of `0065_create_security_isolation_rpc.sql` alone is
feasible without pulling A5 residue or other SQL groups.

---

## 4. Included Files Manifest (1)

| # | Path | Git state | Diff summary (working tree vs HEAD) |
|---:|---|:---:|---|
| 1 | `sql/migrations/0065_create_security_isolation_rpc.sql` | `M` | +388/−146 — nested `procedure add_check` removed; 13 `call add_check` sites expanded to IF/ELSE inline blocks; `jsonb_agg(order_id limit 5)` replaced with subquery + row-level `LIMIT 5`; 4 SECURITY DEFINER functions preserved |

Character matches 604520/604522/604523/604524 disposition record and 604521
single-file A4 boundary.

---

## 5. Excluded Files Manifest

### 5.1 A5 Group A residue (separate future gates — never combine with 0065)

```text
sql/migrations/0066_create_ledger_integrity_rpc.sql     (M)
sql/migrations/0067_create_cron_scheduler_rpc.sql       (M)
```

### 5.2 A1 / A2 / A3 committed SQL (do not restage)

```text
sql/migrations/0035_verify_schema.sql
sql/migrations/0038_create_toss_webhook_processor_rpc.sql
sql/migrations/0042_create_delivery_order_intake_rpc.sql
sql/migrations/0046_create_context_builder_rpc.sql
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
604520–604524 (committed 25b620a4)
604525 manifest (untracked — not part of A4 SQL commit)
604396, 604397, 604403, 604505, 604511, 604512, 604518, 604519 manifests
tools/* (4 untracked helper files)
runtime / Flutter / KDS / POS application code
0069 Analysis (deferred — do not create)
Scope D mainline lifecycle docs
This manifest (604526) — optional separate doc commit
```

---

## 6. File-Level git add Command

Run from repository root. **Not executed by this manifest.**

```powershell
git add "sql/migrations/0065_create_security_isolation_rpc.sql"
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
sql/migrations/0065_create_security_isolation_rpc.sql
```

Confirm exclusions not staged:

```powershell
git diff --cached --name-only | Select-String '0035|0038|0042|0046|0063|0066|0067|0068|0138|0142|0143|0024|0030|0032|0136|0139|0141|seed|tools|0069|docs/'
```

Expected: empty (no matches other than 0065).

Expected cached set:

```powershell
(git diff --cached --name-only).Count   # 1
git diff --cached --name-only           # sql/migrations/0065_create_security_isolation_rpc.sql only
```

Optional diff review:

```powershell
git diff --cached --stat
git diff --cached -- sql/migrations/0065_create_security_isolation_rpc.sql
```

---

## 8. Recommended Commit Message

```text
fix: rewrite 0065 security isolation checks
```

Suggested commit body (optional):

```text
Apply approved A4 0065 security-isolation replay-blocker correction only.
Authority: 604521 Approval Gate, 604524 Audit closeout, 604343/604307 lineage.
Removes nested procedure add_check and jsonb_agg-internal LIMIT parse blockers;
13 inline IF/ELSE check expansions; SECURITY DEFINER preserved on 4 functions.
Excludes A5 residue (0066/0067), A1/A2/A3 (already committed), 0143, tools,
Scope D / 0069.
Replay/parse-gate and security-isolation-compile evidence per 604521 §6
reviewed or waived by Human.
```

---

## 9. Human Decision Checklist

Before staging, Human confirms:

```text
[ ] 604521 §6 replay/parse-gate AND security-isolation-compile preconditions
    reviewed OR explicitly waived
[ ] Only sql/migrations/0065_create_security_isolation_rpc.sql will be staged
[ ] No A5 (0066/0067), A1 restage, A2 restage, A3 restage, 0143, 0138/0142
    residue, zero-pad pairs, seed, tools, or docs mixed in
[ ] HEAD revert/discard of 0065 WT rewrite is NOT chosen (prohibited by
    604521/604524)
[ ] Group A split remains enforced — A5 requires separate future gates;
    0066 and 0067 must never share one commit
[ ] Scope D mainline and 0069 remain blocked/deferred after this commit
[ ] A4 documentation track (604520–604524) is not restaged in this SQL commit
```

---

## 10. Boundary Confirmation

Not performed by this manifest:

```text
staging     : NO
commit      : NO
0065 staging (by this manifest) : NO — Human executes after checklist
non-0065 SQL staging : NO
tools staging : NO
0069 Analysis creation : NO
Scope D mainline resume : NO
```

---

## 11. Final Rule

This manifest records staging **readiness only**. Commit of 0065 does not
authorize A5 SQL disposition, Scope D mainline resume, or 0069 Analysis.

604521 §6 requires replay/parse-gate and security-isolation-compile
verification outcome before commit unless Human explicitly documents waiver.
This manifest does not substitute for that evidence.

If this manifest conflicts with 604524 Audit, 604521 Approval Gate, or
604343/604307 lineage, the stricter boundary wins.
