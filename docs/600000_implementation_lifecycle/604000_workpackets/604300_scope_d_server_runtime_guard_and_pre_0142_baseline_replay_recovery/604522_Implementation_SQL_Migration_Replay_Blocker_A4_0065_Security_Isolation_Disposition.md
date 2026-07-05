# 604522_Implementation_SQL_Migration_Replay_Blocker_A4_0065_Security_Isolation_Disposition.md

Status: Complete
Lifecycle: Implementation Record
Risk: HIGH
Last Updated: 2026-07-06

## 1. Authority and result

This implementation record accepts `604521_Approval_Gate_SQL_Migration_Replay_Blocker_A4_0065_Security_Isolation_Disposition.md` as its sole authority. The controlling Final Approval Decision is:

```text
APPROVED_FOR_A4_0065_SECURITY_ISOLATION_REPLAY_BLOCKER_DISPOSITION_ONLY_WITH_HIGH_RISK_SINGLE_FILE_SQL_BOUNDARY
```

Implementation result:

```text
IMPLEMENTATION_RECORD_CREATED_FOR_A4_0065_SECURITY_ISOLATION_REPLAY_BLOCKER_DISPOSITION_WITH_NO_STAGING
```

No SQL or migration content was edited during 604522. The existing working-tree diff was inspected read-only and recorded for 604523 Verification.

## 2. A4 single-file disposition confirmation

The only A4 SQL file examined was:

```text
sql/migrations/0065_create_security_isolation_rpc.sql
```

Read-only Git inspection confirmed:

- The file exists and is tracked.
- Git state is `M` (modified), unstaged.
- Diff size is 388 insertions and 146 deletions (`+388/-146`).
- `git diff --name-status` reports `M` for the target path.
- The staging area contains no files.

The A4 high-risk, single-file SQL boundary remains intact.

## 3. Replay blockers and working-tree corrections

The HEAD version contains two independent parse-time blockers:

1. Primary: `catchmenu_audit.run_isolation_audit` declares the nested `procedure add_check(...)` in its PL/pgSQL `DECLARE` section, causing the documented parse error at or near `text`.
2. Secondary: `catchmenu_audit.scan_cross_tenant_risk` uses the invalid aggregate expression `jsonb_agg(order_id limit 5)`.

The working-tree correction removes the nested procedure, expands all 13 former `add_check` call sites into explicit IF/ELSE blocks, and moves the sample cap from inside `jsonb_agg` into a row-producing subquery with `LIMIT 5`. The aggregate then consumes the already limited row set.

Read-only inspection confirmed:

- nested `procedure add_check` declarations: 0;
- remaining `add_check(...)` calls: 0;
- removed call sites in the diff: 13;
- added inline IF branches: 13;
- added `v_total`, `v_passed`, `v_failed`, `v_checks`, `v_risk_score`, and `v_critical` update sites: 13 each;
- inline `jsonb_agg(order_id limit 5)` patterns: 0; and
- the row-level `LIMIT 5` remains present once in the corrected sample subquery.

## 4. Semantic-preservation spot-check

The 13 expansions were spot-checked against the removed helper body. Each expansion preserves the same check-count increment, PASS/FAIL branch, audit-result append, severity-weighted risk-score update, and critical-evidence append pattern. This maintains equivalent audit result accumulation rather than merely removing the invalid procedure declaration.

The corrected sample query retains cross-tenant mismatch detection and caps only the diagnostic `sample_ids` set. The detection CTE and count semantics remain separate from the five-item sample aggregation. No new ordering or broader candidate set was introduced.

All four security RPC functions retain `SECURITY DEFINER`: `verify_rls_coverage`, `run_isolation_audit`, `scan_cross_tenant_risk`, and `generate_security_report`. The rewrite therefore remains within the RLS, tenant-isolation, audit-guard, security-definer, and exception/risk-handling domain while preserving the intended authority and evidence boundaries.

JWT claim handling is not applicable to this change. The file relies on `current_tenant_id()` and explicit tenant/store parameters; no JWT claim expression was added, removed, or modified.

## 5. Revert/discard prohibition and risk

Revert or discard to HEAD was not performed and remains prohibited. HEAD contains both the nested-procedure parse failure and the aggregate-inline LIMIT parse failure. Restoring it could halt sequential replay at 0065 and restore the non-compiling security-isolation, RLS coverage, audit, and cross-tenant risk functions.

Risk remains `HIGH` because the primary correction expands 13 security-audit branches with severity-weighted scoring and evidence payloads. Verification must therefore assess semantic equivalence, not only parse validity.

## 6. Boundary preservation

The following boundaries were preserved:

- A1 files `0038`, `0042`, `0063`, and `0068` remain committed and untouched.
- A2 file `0035` remains committed and untouched.
- A3 file `0046` remains committed and untouched.
- A5 files `0066` and `0067` remain excluded, untouched, and sequentially coupled.
- Group B `0138` remains excluded and untouched.
- Group C zero-pad pairs `024/0024`, `030/0030`, and `032/0032` remain excluded and untouched.
- Group D `0142` remains excluded and untouched.
- Group E `0136`, `0139`, `0141`, and `seed_yoonsul_menu.sql` remain excluded and untouched.
- Already committed migration `0143` remains excluded and untouched.
- `tools/*`, runtime code, Flutter/KDS UI, and POS integration remain untouched.
- 0069 Analysis was not created and remains deferred.
- Scope D mainline was not resumed and remains blocked.
- No reset, discard, rename, staging, or commit was performed.

## 7. Validation evidence

The required read-only status and diff commands were executed. Results:

```text
0065 file exists: yes
0065 git state: M, tracked modified, unstaged
0065 diff size: +388/-146
nested procedure add_check: 0
remaining add_check calls: 0
removed call sites / added inline branches: 13 / 13
SECURITY DEFINER functions preserved: 4
inline aggregate LIMIT pattern: 0
row-level LIMIT 5 retained: 1
staged files: 0
git diff --check: PASS
```

The full 0065 diff was reviewed without editing the file. This disposition record does not constitute runtime replay verification or commit authorization.

## 8. Next step

```text
604523 Verification
```

604523 must verify both corrected blocks and the security semantics within the same A4 single-file boundary before any later selective staging or commit decision is considered.
