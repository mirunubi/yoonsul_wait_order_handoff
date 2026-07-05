# 604398_Analysis_SQL_Migration_Replay_Blocker_A2_0035_Verification_Rewrite_Disposition.md

Status: Complete
Lifecycle: Analysis
Gate Classification: Group A2 — 0035 Verification Rewrite SQL Residue Disposition
Runtime Implementation Authorization: Not Granted
Owner: TBD
Last Updated: 2026-07-05

This is an **analysis-only** document. It classifies the A2 sub-batch residue for
`0035_verify_schema.sql` and proposes disposition direction. It performs no SQL
edit, migration edit, reset, discard, rename, staging, or commit. It does not
create 0069 Analysis and does not resume Scope D mainline.

Authority chain (read-only reference):

```text
604391_Analysis_SQL_Migration_Replay_Blocker_Group_Disposition.md
  (A2 = 0035 deferred sub-batch)
604392_Approval_Gate — A1 only (committed)
604395_Audit — A1 closed; A2–A5 remain deferred
604276_Approval_Cross_Scope_Local_Migration_Replay_Baseline_Blockers.md
  (0035 rewrite approved; skip-policy rejected)
604278_Verification — 0035 rewrite verified 85/0 in 604270 lane (WT pattern)
```

Prior closeout (not reopened here):

```text
A1 SQL (0038, 0042, 0063, 0068) : committed (70181253)
604391–604395 documentation     : committed
604500–604504 + 0143            : committed (cb2147ce)
```

See `docs/000015_Korean_Document_And_Encoding_Safety_Rules.md` for encoding rules.

---

## 1. Analysis Scope

### 1.1 In scope — A2 only

```text
sql/migrations/0035_verify_schema.sql
```

### 1.2 Explicit exclusions

```text
A1 committed : 0038, 0042, 0063, 0068
A3 deferred  : 0046
A4 deferred  : 0065
A5 deferred  : 0066, 0067 (sequential)
Group B–E residue : 0138, 0142, zero-pad pairs, 0136/0139/0141/seed
tools/*, runtime code, 0069 Analysis, Scope D mainline resume
```

---

## 2. Commands Executed

All commands run from repository root on 2026-07-05:

```powershell
git status --short
git diff --check
git diff --cached --name-only
git diff --name-status -- sql/migrations/0035_verify_schema.sql
git diff --stat -- sql/migrations/0035_verify_schema.sql
git status --short | Select-String '0035|0046|0065|0066|0067|0138|0142|0024|0030|0032|0136|0139|0141|seed|tools|0069|604398|604399|604400'
git log -1 --oneline -- sql/migrations/0035_verify_schema.sql
git log -1 --oneline -- sql/migrations/0038_create_toss_webhook_processor_rpc.sql
```

Read-only diff inspection:

```powershell
git diff -- sql/migrations/0035_verify_schema.sql  (pattern spot-check)
git show HEAD:sql/migrations/0035_verify_schema.sql  (HEAD structure)
```

No staging or commit was performed by this Analysis.

---

## 3. Repository Gate State

```text
git diff --check                 : exit 0 (PASS)
git diff --cached --name-only    : empty
staged files                     : none
staged SQL                       : none
```

0035 git state:

```text
git diff --name-status : M  sql/migrations/0035_verify_schema.sql
git diff --stat        : 1 file changed, 681 insertions(+), 187 deletions(-)
Last committed rev     : d482163e  "sql: add catchmenu schema migrations 0001-0035 MVP foundation"
Working tree           : tracked modified (unstaged)
```

Filter scan: `604398` not yet present before this document; `604399`/`604400`
(workpacket numbering) not created; 0069 not present; A2–A5 residue paths remain
separate `M`/`??` states.

A1 confirmation:

```text
0038 last commit : 70181253  "fix: apply A1 SQL micro-fix residue corrections"
0035 not included in A1 commit — correct A2 isolation
```

---

## 4. Diff Character And Classification

### 4.1 Diff scale and primary change type

| Metric | Value |
|---|---|
| Lines changed | +681 / −187 |
| Change class | **Verification rewrite** — DO-block body refactor |
| DDL/DML objects created | None (preserved) |
| Persistent side effects | None when checks pass |

### 4.2 Structural change (HEAD → working tree)

**HEAD (committed, broken):**

```text
DO $$ ... DECLARE
  procedure assert_true(...) IS BEGIN ... END;
  ...
  call assert_true('schema catchmenu_common', exists(...));
  ...
END; $$;
```

**Working tree (rewrite):**

```text
DO $$ ... DECLARE
  v_error_count int := 0;
  v_pass_count int := 0;
  ...
  if exists(...) then
    v_pass_count := v_pass_count + 1;
    raise notice '[PASS] %', 'schema catchmenu_common';
  else
    v_error_count := v_error_count + 1;
    raise warning '[FAIL] %', 'schema catchmenu_common';
  end if;
  ...
  if v_error_count > 0 then
    raise exception 'SCHEMA_VERIFICATION_FAILED: ...';
  end if;
END; $$;
```

**Root cause of replay blocker:** PostgreSQL does not allow nested `procedure`
declarations inside a DO block's DECLARE section. HEAD fails at **parse/compile
time** before any verification logic runs.

### 4.3 Why classified as verification rewrite (604391 A2)

```text
1. File header declares "Creates: (none) — verification only".
2. 604271/604273/604275 document no persisted side effects on success path.
3. 604276 Human approved REWRITE branch (not skip-in-automated-replay).
4. WT removes invalid inline-procedure pattern; preserves PASS/FAIL/EXCEPTION
   termination semantics via inline counters and RAISE NOTICE/WARNING.
5. 604278 recorded 85 PASS / 0 FAIL when WT rewrite pattern was applied in
   604270 verification lane (evidence candidate — not repo commit authorization).
```

This is **not** a feature migration. It is a **parser-valid verification migration**
that still executes during sequential `supabase migration up` / psql replay at
position 0035.

---

## 5. Verification Helper vs Replay-Blocking Migration

| Question | Finding |
|---|---|
| Is it only a post-apply helper script? | **No** — it is a numbered migration file executed in chain order after 0034. |
| Does it block replay if broken? | **Yes** — HEAD parse error stops replay before 0036+. |
| Does it block replay if checks fail? | **Yes** — `RAISE EXCEPTION` on `v_error_count > 0` aborts migration apply. |
| Does WT fix unblock parse? | **Expected yes** — inline pattern is valid PL/pgSQL (604278 evidence). |
| Does WT change schema objects? | **No** — read-only existence checks against `information_schema` / catalogs. |

**Conclusion:** 0035 is a **verification migration** that doubles as a **mandatory
replay gate** at its sequence slot. Fixing HEAD is required for trustworthy
sequential replay; skipping without Human-approved harness policy is rejected
(604276).

---

## 6. HEAD Revert / Failure Recurrence (Documented)

If working-tree changes are discarded and HEAD (`d482163e`) is restored:

| Failure mode | Expected recurrence |
|---|---|
| Parse/compile error | **Yes** — nested `procedure assert_true` inside DO DECLARE |
| Error class | Unconditional syntax error (604276: "could not have been successfully applied as currently written") |
| Replay stop point | Migration **0035** — before 0036+ |
| Downstream impact | 604260/604268 baseline replay classification: **0035 Failed — PL/pgSQL syntax error** |
| 0038+ chain | Not reached on clean replay from HEAD until 0035 passes parse |
| 0142 / Scope D evidence | Replay-to-0142 remains **untrustworthy** while HEAD 0035 remains |

**Note:** Functional check failures (85 checks with some FAIL) are a **separate**
failure mode from parse failure. HEAD never reaches functional checks because
parse fails first. WT must pass both parse and functional gates before commit.

---

## 7. Disposition Analysis

### 7.1 Standalone commit feasibility

```text
YES — as A2-only single-file commit, consistent with 604391 five-way split.
Must NOT be bundled with A3–A5, 0142 residue, tools, or 604500 track.
Requires 604399 Approval Gate before staging/commit.
```

### 7.2 Risk level

```text
HIGH — maintained
```

Rationale:

```text
- Largest remaining Group A diff (+681/−187)
- Full-chain verification semantics; any check drift affects replay trust
- Human diff review burden; not a one-line micro-fix
- Must re-verify PASS/FAIL counts after commit (604278 used 85/0 baseline)
```

### 7.3 Discard candidate?

```text
NOT recommended as default discard candidate
```

| Option | Assessment |
|---|---|
| **KEEP working-tree rewrite** | **Recommended** — aligns with 604276 approved strategy and 604278 verification evidence pattern |
| **DISCARD to HEAD** | **Not recommended** — reintroduces known parse-time replay blocker |
| **DISCARD + skip-policy** | **Deferred alternative only** — 604276 explicitly rejected skip branch for 0035; requires new Human decision in 604399 if re-proposed |

### 7.4 Disposition recommendation

```text
KEEP_AND_APPROVE_FOR_SEPARATE_SQL_COMMIT
  + REQUIRES_REPLAY_VERIFICATION
  + SPLIT_TO_SEPARATE_APPROVAL_GATE (A2 standalone)
  + REQUIRES_DIFF_REDUCTION Human review (large diff)
```

Not authorized by this Analysis — 604399 Approval Gate required.

---

## 8. Scope D Mainline And 0069 Blocking

```text
Scope D mainline : BLOCKED (unchanged)
0069 Analysis    : DEFERRED (unchanged)
```

While 0035 working-tree rewrite remains uncommitted:

```text
- Repository HEAD still contains parse-broken 0035 at replay position 0035.
- A1 commit (0038+) does not repair HEAD 0035; replay from committed tree still
  fails at 0035 unless WT is applied locally without commit.
- Remaining A3–A5 residue and 0142 WT further block full replay-to-0142 evidence.
- Closing A2 alone does not authorize Scope D resume or 0069 Analysis.
```

---

## 9. Lineage Cross-Reference (Read-Only)

| Document | Relevance to 0035 |
|---|---|
| 604268 Verification (604260) | First classified 0035 as baseline replay blocker; inline procedure |
| 604270 Index / 604271 Analysis | Class B verification rewrite vs Class A syntax |
| 604276 Approval | Approved in-place rewrite; rejected skip-policy |
| 604277 Implementation | Lane implementation of rewrite (604270 track) |
| 604278 Verification | 85 PASS / 0 FAIL on rewritten 0035 |
| 604391 Analysis | A2 deferred; HIGH risk; own sub-batch |
| 604395 Audit | A1 closed; A2–A5 staging still requires separate Human gates |

604277 lane fix and repository HEAD diverge: **0035 WT matches approved rewrite
pattern but is not yet committed to main repo.**

---

## 10. Boundary Confirmation

Confirmed not performed:

```text
SQL modification                          : NO
migration modification                    : NO
SQL reset / discard / rename              : NO
SQL staging                               : NO
tools modification / staging              : NO
runtime code modification                 : NO
0069 Analysis creation                    : NO
Scope D mainline resume                   : NO
staging                                   : NO
commit                                      : NO
```

Only this Markdown Analysis artifact is created.

---

## 11. 604399 Approval Gate Requirement

**Finding: YES — 604399 Approval Gate is required before any A2 SQL action.**

604399 must authorize:

```text
- KEEP WT rewrite vs DISCARD to HEAD vs re-open skip-policy (Human choice)
- replay verification commands and pass criteria (parse + functional; 85-check baseline)
- single-file 0035-only commit boundary
- forbidden mixing with A3–A5, 0142, zero-pad pairs, seed, tools
- post-commit re-run scope (0035 only vs partial chain)
```

Recommended numbering:

```text
604398 Analysis (this document)
604399 Approval Gate
604400 Implementation (documentation record or SQL commit prep per gate decision)
604401 Verification
604402 Audit
```

---

## 12. Final Analysis Result

```text
A2_0035_VERIFICATION_REWRITE_REQUIRES_APPROVAL_GATE_BEFORE_ACTION
```

```text
Summary:
  - 0035 is tracked modified (+681/−187); unstaged; git diff --check PASS.
  - Verification rewrite removes invalid nested procedure; preserves check intent.
  - File is verification-only but executes as migration 0035 — replay gate.
  - HEAD revert reintroduces parse-time replay failure at 0035.
  - Standalone A2 commit feasible; HIGH risk; not a default discard candidate.
  - KEEP + replay verification recommended; 604399 Approval Gate required.
  - Scope D mainline and 0069 remain blocked/deferred.
  - A1 committed; A3–A5 and other residue untouched by this Analysis.
```

---

## 13. Required Next Step

```text
604399_Approval_Gate_SQL_Migration_Replay_Blocker_A2_0035_Verification_Rewrite_Disposition.md
```

---

## 14. Final Rule

This Analysis does not authorize SQL/migration remediation or commit.

If this Analysis conflicts with 604276 Approval or 604391 classification, the
stricter boundary wins.

Scope D mainline and 0069 Analysis must not resume automatically from this
Analysis.
