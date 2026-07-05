# 604520_Analysis_SQL_Migration_Replay_Blocker_A4_0065_Security_Isolation_Disposition.md

Status: Complete
Lifecycle: Analysis
Gate Classification: Group A4 — 0065 Security Isolation Replay Blocker Disposition
Runtime Implementation Authorization: Not Granted
Owner: TBD
Last Updated: 2026-07-06

This is an **analysis document only**. It classifies the A4 replay-blocker SQL
residue for `0065_create_security_isolation_rpc.sql` only. It performs no SQL
edit, migration edit, reset, discard, rename, staging, or commit. It does not
create 0069 Analysis and does not resume Scope D mainline.

Authority:

```text
604390_Approval_Gate_SQL_Migration_Residue_Disposition_Before_Scope_D_Resume.md
Final Approval Decision:
  APPROVED_FOR_SQL_RESIDUE_TRACK_SEPARATION_WITH_SCOPE_D_AND_0069_STILL_BLOCKED

604391_Analysis_SQL_Migration_Replay_Blocker_Group_Disposition.md
  Sub-batch A4 — Security isolation refactor (0065 only); Risk: HIGH

Prior cross-scope 0065 blocker lineage (analysis/verification/audit only):
  604343–604344 (primary inline procedure add_check syntax blocker)
  604305 (verification record for primary blocker)
  604307–604311 (secondary scan_cross_tenant jsonb_agg inline limit syntax blocker)
  604309 (verification record for secondary blocker)
```

Prior committed sub-batches (must not be re-opened in this Analysis):

```text
A1 SQL (0038, 0042, 0063, 0068) : committed (70181253)
A2 SQL (0035)                     : committed (f89c70e0)
A3 SQL (0046)                     : committed (6847d69b)
Metadata sync (604506–604510)     : committed (fc7797c5)
0143 no-payment KDS policy        : committed (cb2147ce)
```

See `docs/000015_Korean_Document_And_Encoding_Safety_Rules.md` for encoding rules.

---

## 1. Analysis Scope

### 1.1 In scope — A4 single file

```text
sql/migrations/0065_create_security_isolation_rpc.sql
```

### 1.2 Explicit exclusions

```text
0035           — A2 committed (f89c70e0), excluded
0038, 0042, 0063, 0068 — A1 committed (70181253), excluded
0046           — A3 committed (6847d69b), excluded
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

All commands below were run from repository root on 2026-07-06:

```powershell
git status --short
git diff --check
git diff --cached --name-only
git diff --numstat -- sql/migrations/0065_create_security_isolation_rpc.sql
git diff --name-status -- sql/migrations/0065_create_security_isolation_rpc.sql
git diff -- sql/migrations/0065_create_security_isolation_rpc.sql
git status --short | Select-String '0065|0066|0067|0138|0142|0024|0030|0032|0136|0139|0141|seed|tools|0069|604520|604521|604522'
git log --oneline -1 -- sql/migrations/0065_create_security_isolation_rpc.sql
git log --oneline -1 -- sql/migrations/0046_create_context_builder_rpc.sql
git log --oneline -1 -- sql/migrations/0035_verify_schema.sql
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

**0065 only:**

```text
git status --short : M  sql/migrations/0065_create_security_isolation_rpc.sql
git diff --numstat : 388  146  sql/migrations/0065_create_security_isolation_rpc.sql
git diff --name-status : M  sql/migrations/0065_create_security_isolation_rpc.sql
```

**Other Group A residue visible in working tree (excluded from A4 scope):**

```text
M  sql/migrations/0066_create_ledger_integrity_rpc.sql
M  sql/migrations/0067_create_cron_scheduler_rpc.sql
(+ other sql/migrations/* paths per git status — not analyzed here)
```

**Filtered status (Select-String pattern):**

```text
M  sql/migrations/0065_create_security_isolation_rpc.sql
M  sql/migrations/0066_create_ledger_integrity_rpc.sql
M  sql/migrations/0067_create_cron_scheduler_rpc.sql
M  sql/migrations/0138_patch_integration_functions.sql
A  sql/migrations/0142_patch_toss_mvp_payment_intent_binding.sql
?? sql/migrations/0024_create_store_bootstrap_rpc.sql
?? sql/migrations/0030_create_manual_fallback_rpc.sql
?? sql/migrations/0032_create_agent_action_rpc.sql
?? sql/migrations/0136_create_dev_audit_log.sql
?? sql/migrations/0139_create_ai_inference_log.sql
?? sql/migrations/0141_hyper_personalization_menu_customization.sql
?? sql/migrations/seed_yoonsul_menu.sql
?? tools/*
(no 604520/604521/604522 paths yet — this Analysis creates 604520 only)
```

---

## 4. Current Git State Summary

| Attribute | Value |
|---|---|
| Path | `sql/migrations/0065_create_security_isolation_rpc.sql` |
| Git state | `M` (tracked modified, unstaged) |
| Diff size | +388 / −146 lines |
| Last commit touching file | `7e3ba4aa` sql: add catchmenu schema migrations 0036-0073 |
| Working-tree vs HEAD | substantive security-isolation RPC body refactor in `run_isolation_audit` plus aggregate LIMIT repair in `scan_cross_tenant_risk` |

The working-tree change is **not committed**. HEAD retains both documented
parse-time replay blockers (primary and secondary).

---

## 5. Why 0065 Is Classified as a Security-Isolation Replay Blocker

### 5.1 Primary blocker (inline procedure in DECLARE)

Prior lineage (`604343`, `604344`, `604305`) established:

```text
Last applied: 0064_create_menu_i18n_allergen.sql
Failed at:    0065_create_security_isolation_rpc.sql
Error:        syntax error at or near "text"
Location:     procedure add_check(...) inside DECLARE of catchmenu_audit.run_isolation_audit
CONTEXT:      invalid type name "add_check( p_check_name text, ..."
Function:     catchmenu_audit.run_isolation_audit(...)
Root cause:   INLINE_PROCEDURE_DECLARATION_NOT_SUPPORTED
```

PostgreSQL PL/pgSQL DECLARE sections permit variables only; a nested
`procedure add_check(...)` declaration is invalid — the same defect class
already resolved for 0035 (604276/604277). Migration apply halts during
`run_isolation_audit` compilation before later objects in the same file
complete.

### 5.2 Secondary blocker (aggregate inline LIMIT)

Prior lineage (`604307`, `604311`, `604309`) established a **second independent**
syntax defect in the same migration file:

```text
Failed at:  same file, later in apply order (after primary hypothetically fixed)
Error:     syntax error at or near "limit"
Location:  'sample_ids', jsonb_agg(order_id limit 5),
Function:  catchmenu_audit.scan_cross_tenant_risk(...)
Root cause: AGGREGATE_INLINE_LIMIT_SYNTAX_ERROR
```

After the primary defect is hypothetically fixed in HEAD alone, replay would
still fail at this secondary construct unless both are corrected. This is the
same aggregate-LIMIT placement class already resolved for 0046 (604350-series)
and 0035 verification patterns.

### 5.3 Relation to 604391 Group A disposition

604391 classified 0065 as:

```text
Substantive inline-procedure removal / guard refactor (+388/−146), not a one-line fix.
SPLIT_TO_SEPARATE_APPROVAL_GATE (A4 sub-batch).
REQUIRES_REPLAY_VERIFICATION through 0065 primary AND secondary scenarios.
Risk: HIGH.
```

604391 explicitly assigned 0065 to isolated sub-batch A4, separate from A5
(0066/0067 sequential commits).

---

## 6. Diff Character and Change Classification

The working-tree diff addresses **both** primary and secondary blockers in one
file. The dominant change is Candidate A from 604343: remove the nested
`procedure add_check` declaration and replace each of **13 `call add_check(...)`
sites** with equivalent IF/ELSE blocks that mutate `v_total`, `v_passed`,
`v_failed`, `v_checks`, `v_critical`, and `v_risk_score` inline.

### 6.1 Block 1 — `run_isolation_audit` inline procedure removal (primary)

| Aspect | HEAD (broken) | Working tree (fix) |
|---|---|---|
| Structure | Nested `procedure add_check(...)` in DECLARE (~40 lines) + 13 `call add_check(...)` | Nested procedure removed; 13 explicit IF/ELSE expansions at call sites |
| Change class | PL/pgSQL guard refactor / check-accumulation inlining | PL/pgSQL guard refactor / check-accumulation inlining |
| `procedure add_check` count | 1 declaration + 13 calls | 0 (verified: no nested procedure in WT) |
| Check semantics | Severity-weighted risk_score; PASS/FAIL jsonb arrays | Preserved per 604343 Candidate A verbatim-body pattern |
| Security objects | `security_scan_results` insert/update, scan finalization | Preserved; UPDATE uses `=` assignment (unrelated to 0063 defect class) |

**Checks inlined (13 call sites, 12 named checks):**

```text
tenant_exists_and_active, orders_tenant_isolation, payment_ledger_tenant_isolation,
kds_tickets_tenant_isolation, no_orphaned_sessions, audit_records_append_only,
no_untrusted_devices_online, agent_execute_permission_restricted,
kds_release_requires_authorization, uncertain_payment_blocks_kds,
store_belongs_to_tenant (conditional), store_data_boundary (conditional),
knowledge_docs_tenant_isolated
```

### 6.2 Block 2 — `scan_cross_tenant_risk` aggregate LIMIT (secondary)

| Aspect | HEAD (broken) | Working tree (fix) |
|---|---|---|
| Structure | `jsonb_agg(order_id limit 5)` inline inside aggregate argument | Subquery selects `order_id` rows with `ORDER BY` + `LIMIT 5`; outer `jsonb_agg(sample.order_id)` |
| Change class | Query restructuring + LIMIT placement | Query restructuring + LIMIT placement |
| Payload field | `sample_ids` in cross-tenant risk JSON | Preserved field name and diagnostic role |
| Other scans in function | Five additional scan blocks without inline LIMIT | Unchanged in diff hunks reviewed |

**Pattern:** Same subquery-wrapper LIMIT placement as A3 0046 (604513 §6).

### 6.3 Security-domain category map

| Category | Relevance to 0065 diff |
|---|---|
| **RLS** | **Direct** — `verify_rls_coverage`, RLS policy on `security_scan_results`, RLS-enabled/forced checks in audit |
| **Tenant isolation** | **Direct** — primary purpose of `run_isolation_audit`; orders/payment/kds/store/knowledge boundary checks |
| **JWT claim** | **Not in scope for this file** — no JWT/claim references in 0065 source; isolation uses `current_tenant_id()` and explicit tenant/store parameters |
| **Security definer** | **Preserved** — `verify_rls_coverage`, `run_isolation_audit`, `scan_cross_tenant_risk`, `generate_security_report` retain SECURITY DEFINER |
| **Audit guard** | **Direct** — `audit_records_append_only` check; `security_scan_results` table + RLS policy; scan result persistence |
| **Exception / risk handling** | **Direct** — check accumulation via `v_checks`/`v_critical` JSON arrays; severity-weighted `v_risk_score`; conditional store-level checks |

### 6.4 What the diff does NOT change

```text
- No new schemas or standalone helper objects (Candidate B from 604343 rejected)
- No changes to verify_rls_coverage or generate_security_report function bodies
- No edits outside 0065 in this Analysis scope
- No Flutter/KDS/POS/runtime code
- No tools/*
```

---

## 7. HEAD Revert Assessment

If the working tree were reverted to HEAD:

```text
Primary replay failure reintroduced:
  syntax error at or near "text" — nested procedure add_check in run_isolation_audit DECLARE

Secondary replay failure reintroduced (after primary hypothetically patched alone):
  syntax error at or near "limit" — jsonb_agg(order_id limit 5) in scan_cross_tenant_risk

Sequential migration replay would halt at position 0065 again.
Downstream migrations (0066 … 0068 … 0069 … 0142) would not be reached.
0142 reachability remains blocked upstream — NOT because of 0142 itself.
```

604343/604307 analyses and 604305/604309 verification records document these
failures as **pre-existing HEAD defects**, not regressions introduced by A1/A2/A3
commits. A1 (70181253), A2 (f89c70e0), and A3 (6847d69b) did not modify 0065
per git history (`7e3ba4aa` remains last commit on this path).

**Security/isolation regression on revert:** Reverting would not merely restore a
neutral baseline — it restores **non-compiling** security-isolation RPC definitions.
No tenant-isolation audit, RLS coverage scan, or cross-tenant risk scan objects
would apply past the parse failure point during replay.

**Discard/revert is NOT recommended** for A4 disposition: it restores known
parse-time replay blockers without resolving security-isolation guard logic.

---

## 8. Standalone Commit Feasibility

```text
Standalone single-file commit: FEASIBLE (in principle)
  - One path only: sql/migrations/0065_create_security_isolation_rpc.sql
  - Selective git add mirrors A1 (4-file), A2 (1-file), and A3 (1-file) patterns
  - Must not be bundled with 0066/0067 or any other residue

Prerequisite before commit (not satisfied by this Analysis):
  - 604521 Approval Gate with explicit single-file boundary
  - Replay verification through 0065 primary (run_isolation_audit compile/apply)
    AND secondary (scan_cross_tenant_risk compile/apply) scenarios
  - Confirmation that all 13 inlined check expansions preserve add_check semantics
  - Human selective-staging decision (manifest stage, not this Analysis)
```

This Analysis does **not** authorize staging or commit.

---

## 9. Risk Classification

```text
Severity        : HIGH
Blast radius    : catchmenu_audit security isolation RPC cluster (4 functions,
                  security_scan_results table + RLS policy)
Change type     : substantive PL/pgSQL guard refactor (+388/−146), not micro-fix
Reversibility   : git-revertable, but revert reintroduces replay blockers
Runtime impact  : multi-tenant isolation validation, RLS coverage audit,
                  cross-tenant leakage scan, security report generation
Coupling        : independent of A5 (0066/0067) — must stay split
Evidence gap    : working-tree fix present; replay PASS through 0065+ not re-run in this Analysis
Verification    : 13 manual expansions — larger correctness surface than 0035 inline fix
```

Risk is **higher line-count and semantic surface than A3 0046** (+67/−60) because
the primary fix expands 13 check sites with severity-weighted scoring and
differently-shaped PASS vs FAIL JSON branches, not merely LIMIT placement.

---

## 10. Discard Candidate Assessment

```text
DISCARD_CANDIDATE: NO
```

Rationale:

```text
- HEAD contains two confirmed parse-time defects (604343/604307 lineage).
- Working-tree change applies documented Candidate A (primary) and subquery LIMIT
  pattern (secondary) for both blockers in one file.
- Reverting would restore replay halt at 0065 — opposite of residue disposition goal.
- 604391 assigned A4 "KEEP with separate gate," not discard.
- Skip-in-automated-replay policy is NOT applicable — 0065 creates runtime security
  RPC objects and must parse/apply during sequential replay.
- Discarding would leave security-isolation validation permanently unreachable in
  baseline replay — unacceptable for pre-0142 evidence gate.
```

---

## 11. Approval Gate Requirement

```text
SEPARATE_APPROVAL_GATE_REQUIRED: YES
Recommended next document:
  604521_Approval_Gate_SQL_Migration_Replay_Blocker_A4_0065_Security_Isolation_Disposition.md
```

The Approval Gate must:

```text
- authorize exactly one file: 0065
- require replay verification through primary (inline procedure) AND secondary
  (aggregate LIMIT) scenarios
- require spot-check of all 13 inlined check expansions against add_check body
- forbid bundling with A5 residue (0066/0067), tools, docs, or Scope D work
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
  - 0065 sits upstream of 0066/0067/0068/0069 in sequential replay order.
  - Committing a verified 0065 fix advances replay evidence toward A5 blockers
    (0066, 0067) and later positions (0068, 0069, 0142) but does NOT itself:
      * create 0069 Analysis
      * close 0069 deferral
      * resume Scope D mainline (604250/604260/604400 implementation lanes)
  - 604390/604391 Group A split remains enforced for A5 (0066 then 0067, never
    one combined commit).
  - Groups B–E residue and 0142 baseline questions remain outside A4 scope.
```

---

## 13. Recommended Correction Lane

```text
604520 Analysis   (this document)
604521 Approval Gate
604522 Implementation (or commit-readiness record if WT already matches approved fix)
604523 Verification
604524 Audit
604525 Human Decision manifest (optional, for selective 0065 SQL staging — pattern 604519)
```

---

## 14. Final Analysis Result

```text
A4_0065_SECURITY_ISOLATION_REPLAY_BLOCKER_REQUIRES_APPROVAL_GATE_BEFORE_ACTION
```

```text
Summary:
  - 0065 git state: M, +388/−146, unstaged.
  - Two HEAD parse blockers: primary (nested procedure add_check in run_isolation_audit)
    and secondary (jsonb_agg(order_id limit 5) in scan_cross_tenant_risk).
  - WT fix: remove nested procedure; inline 13 call sites; subquery LIMIT for sample_ids.
  - Change class: PL/pgSQL guard refactor, tenant/RLS audit checks, audit guard,
    security definer preserved, exception/risk accumulation via inlined IF/ELSE blocks.
  - JWT claim: not applicable to this migration file.
  - HEAD revert: reintroduces replay halt at 0065 and security-isolation compile failure.
  - Standalone single-file commit: feasible under A4 boundary after Approval Gate + replay evidence.
  - Risk: HIGH; separate from A5 (0066/0067).
  - Discard: NO.
  - Approval Gate 604521 required before any staging/commit action.
  - 0069 Analysis and Scope D mainline remain blocked/deferred.
  - No SQL edit, staging, or commit performed by this Analysis.
```

---

## 15. Required Next Step

```text
604521_Approval_Gate_SQL_Migration_Replay_Blocker_A4_0065_Security_Isolation_Disposition.md
```

This Analysis performs no further action.
