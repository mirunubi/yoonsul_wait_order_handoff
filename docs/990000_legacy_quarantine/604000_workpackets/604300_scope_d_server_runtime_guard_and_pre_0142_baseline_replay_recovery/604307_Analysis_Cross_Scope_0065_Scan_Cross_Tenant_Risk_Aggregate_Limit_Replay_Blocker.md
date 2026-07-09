# 604307_Analysis_Cross_Scope_0065_Scan_Cross_Tenant_Risk_Aggregate_Limit_Replay_Blocker.md

Status: Complete
Lifecycle: Analysis
Gate Classification: Cross-Scope Baseline Migration Replay Blocker — Stage 1 Analysis
Runtime Implementation Authorization: Not Granted
Owner: TBD
Last Updated: 2026-07-05

This is an analysis/scope document only. It performs no implementation and modifies
no SQL, migration, or other file. It does not close 604260 and does not authorize
604250 resume. It does not create 604308 or 604309 — those, if pursued, are separate
future documents.

0046 remains PASS per 604297 Audit. 0063 remains PASS per 604342 Audit. 0065's
`run_isolation_audit` add_check fix remains PASS per 604344 Audit. This analysis
addresses ONLY the 0065 `scan_cross_tenant_risk` secondary blocker
(`jsonb_agg(order_id limit 5)`).

---

## 1. Analysis Scope

```text
In scope:
  - Direct review of sql/migrations/0065_create_security_isolation_rpc.sql, focused
    on catchmenu_audit.scan_cross_tenant_risk.
  - Identification of the exact syntax defect, its JSON/diagnostics payload role, and
    its row-set/ordering context.
  - Confirmation that this blocker is pre-existing and was not introduced by
    604291/604295 (0046), 604300 (0063), or 604304 (0065's run_isolation_audit fix).
  - Independent re-confirmation that this is a single, isolated occurrence within
    scan_cross_tenant_risk (not a repeated pattern across its other five scans).
  - Presentation of candidate fixes (analysis only, no implementation).
  - A single recommended minimal fix, and a decision on whether it can proceed
    directly to Codex implementation or requires Human review first.

Out of scope (not performed, not authorized here):
  - Any edit to 0065 or any other migration.
  - Any change to 0063, 0046, 0042, 0038, 0035, or 0142.
  - Any change to run_isolation_audit (already fixed and accepted under 604304/604306).
  - Creating 604308 (Implementation) or 604309 (any successor document).
  - Reopening 604260 closeout or 604250 resume.
```

---

## 2. Inputs Reviewed

```text
sql/migrations/0065_create_security_isolation_rpc.sql (current, post-604304 state,
  read in full for catchmenu_audit.scan_cross_tenant_risk, lines 890-1101)
604305_Verification_Cross_Scope_0065_Security_Isolation_Inline_Procedure_Replay_Blocker.md
  (§5 verbatim secondary-failure record)
604344_Audit_Cross_Scope_0065_Security_Isolation_Inline_Procedure_Replay_Blocker.md
  (§7 0065 Secondary jsonb_agg Limit Blocker Assessment — prior classification and
  isolated-occurrence confirmation)
git diff --stat for sql/migrations/0065_create_security_isolation_rpc.sql
  (independently re-run in this analysis — confirmed the diff is limited to
  run_isolation_audit; scan_cross_tenant_risk is untouched)
604273/604283 (this lineage's own precedent Logic documents for the identical
  AGGREGATE_INLINE_LIMIT_SYNTAX_ERROR class already resolved twice for 0046)
```

---

## 3. Replay Failure Summary

```text
Reported by 604305 Verification (§5), re-confirmed by 604344 Audit (§7), and
  independently re-confirmed by direct source read in this Analysis:

  Last applied: 0064_create_menu_i18n_allergen.sql
  0065 partial apply: run_isolation_audit and preceding objects succeeded; failure
    occurred later in the same file
  Error:        syntax error at or near "limit"
  Reported location: LINE 37, "'sample_ids', jsonb_agg(order_id limit 5),"
  Actual current source line (this file's own numbering): line 926, inside
    catchmenu_audit.scan_cross_tenant_risk (function signature at line 890-893)

(As already established for the 0042/0046/0063/0065-primary blockers in this
lineage: psql's reported line number is an in-statement/in-context count from where
the parser began interpreting the malformed construct, not the file's absolute line
number. Both numbers describe the same single defect.)
```

---

## 4. 0065 Migration Identification

```text
File: sql/migrations/0065_create_security_isolation_rpc.sql
Function containing the defect: catchmenu_audit.scan_cross_tenant_risk(p_tenant_id
  uuid) returns jsonb, signature at lines 890-902, body through line ~1101.
Position in file: the third of four functions declared in this file
  (verify_rls_coverage, run_isolation_audit -- already fixed under 604304/604306 --
  scan_cross_tenant_risk -- THIS analysis's subject -- and generate_security_report,
  not yet reached by replay).
Depends on (file header): 0064_create_menu_i18n_allergen.sql (unchanged from the
  0065-primary analysis; this is the same file, not a different migration).
```

---

## 5. Failure Location

```text
scan_cross_tenant_risk runs six independent "Scan N" blocks, each following the same
  shape: a CTE selecting candidate mismatch rows (capped with a valid, correctly-
  placed `limit 10` on the CTE itself), followed by a
  `select case when count(*) > 0 then jsonb_build_object(...) else <prior value or
  null> end into v_risks from <cte>;` statement that folds the scan's finding into
  the accumulating v_risks jsonb array/value.

Only the FIRST scan ("Scan 1: orders with mismatched tenant/store", lines 908-932)
  includes a per-mismatch "sample_ids" field:

  with mismatched as (
    select o.id as order_id, o.tenant_id as order_tenant,
           s.tenant_id as store_tenant, o.store_id
    from catchmenu_pos.orders o
    join catchmenu_hq.stores s on s.id = o.store_id
    where o.tenant_id = p_tenant_id and s.tenant_id <> p_tenant_id
    limit 10                                    -- valid: CTE-level LIMIT
  )
  select case when count(*) > 0 then
    jsonb_build_object(
      'risk_type', 'ORDER_TENANT_MISMATCH',
      'severity', 'CRITICAL',
      'count', count(*),
      'sample_ids', jsonb_agg(order_id limit 5),  -- line 926: invalid
      'detail', 'Orders assigned to stores of different tenant'
    )
    else null
  end
  into v_risks
  from mismatched;

None of the other five scans (payment_risk, kds_risk, staff_risk, coupon_risk,
  device_risk -- lines 942-1101) include a "sample_ids" field or any jsonb_agg call;
  they report only 'count' from `count(*)` over their own similarly-shaped CTE.
```

---

## 6. SQL / PLpgSQL Syntax Assessment

```text
Payload role: 'sample_ids' is a diagnostic convenience field -- a short list of
  actual order IDs (from the `mismatched` CTE) included alongside the aggregate
  'count', presumably so a human or downstream tool reviewing a CRITICAL
  ORDER_TENANT_MISMATCH finding can look up specific offending rows without a
  separate query.

Row set: `order_id` comes from the `mismatched` CTE (lines 909-919), itself capped
  at `limit 10` (a valid, CTE-level LIMIT -- confirmed unaffected by this defect;
  it already works correctly and is not being changed by any candidate fix below).

Ordering: NO ORDER BY is present anywhere in this construct -- neither on the
  `mismatched` CTE nor inside the `jsonb_agg(...)` call. "Top-5" is therefore not a
  ranked top-N by any criterion; it is simply "up to 5 sample rows from whichever up
  to 10 rows the CTE happened to select" -- an arbitrary sample, not an ordered one.
  This is a materially different situation from 0046's blockers, both of which had
  an explicit ORDER BY whose row-selection meaning had to be preserved; here there is
  no existing ordering semantic to preserve, only a row-COUNT cap (5, out of the
  CTE's own up-to-10 candidate set) to preserve.

Is `limit 5` a row-level cap? Yes, in intent -- the developer's evident intent was
  to include at most 5 sample IDs, distinct from (and smaller than) the CTE's own
  detection cap of 10. Because 'count' in the same jsonb_build_object reads
  `count(*)` over the FULL (up-to-10-row) `mismatched` set, the 5-cap is specific to
  the SAMPLE list, not to the detection/counting itself -- the two caps (10 for
  detection/counting, 5 for the sample list) are deliberately different and must
  both be preserved independently by any fix.

Would simply moving `limit 5` outside jsonb_agg(...) (to the end of the outer
  statement) preserve this? NO. The outer `select case when ... end into v_risks
  from mismatched;` has no GROUP BY, so it already returns exactly one row (per CTE);
  appending an outer-query LIMIT is a no-op on a single-row result, identical in
  mechanism to the risk already established for 0046's primary and secondary
  blockers (604273 §2-3, 604283 §2-3). If the invalid `limit 5` inside jsonb_agg(...)
  were simply deleted (rather than relocated), 'sample_ids' would silently become
  "all order_ids from the mismatched CTE" -- i.e. up to 10, not 5, since the CTE's
  own cap is the only remaining bound. This is a smaller behavior change than 0046's
  cases (where removing the cap entirely meant "unbounded" instead of "N"), because
  the CTE's own limit 10 still bounds the result -- but it is still a change from the
  evidently intended 5-item sample to a potential 10-item one, and must be flagged,
  not silently accepted.

Same isolated-occurrence confirmation, independently re-run in this Analysis: a
  full-file search for jsonb_agg/array_agg/string_agg in 0065 again finds exactly
  ONE call (line 926) -- confirming 604306 §7's finding still holds; none of the
  other five scans in scan_cross_tenant_risk, and no construct in
  generate_security_report (not yet reached by replay, read directly in this
  Analysis for this check), contains a similar aggregate-inline-LIMIT pattern.
```

---

## 7. Root Cause Classification

```text
AGGREGATE_INLINE_LIMIT_SYNTAX_ERROR
```

```text
Reasoning: `jsonb_agg(order_id limit 5)` places a LIMIT clause inside an aggregate
function call's own argument list, a position PostgreSQL's grammar does not permit
(aggregate_name(expression [ORDER BY ...]) is the only legal form; LIMIT belongs to
a SELECT statement or a row-producing subquery). This is the identical defect class
already fully diagnosed and twice resolved in this lineage for 0046 (604273 §2-3,
604283 §2-3 for the primary and secondary blockers respectively) -- more specific
than the general SQL_LIMIT_PLACEMENT_ERROR label (which also covers UPDATE...SET
misuses of `:=`, a different construct entirely, already resolved for 0038/0042/
0063). It is not a CTE_OR_PARENTHESES_STRUCTURE_ERROR (the `mismatched` CTE and all
surrounding parentheses are correctly balanced and independently valid; the CTE's
own `limit 10` is legitimately placed), not a FUNCTION_BODY_SYNTAX_ERROR (the
enclosing $$ ... $$ delimiters for scan_cross_tenant_risk are balanced, confirmed
unaffected by 604304's edit to a different function), and not an ambiguous case
requiring UNKNOWN_REQUIRES_HUMAN_REVIEW -- the defect and its correct category are
unambiguous and already twice precedented in this exact lineage.
```

---

## 8. Pre-Existing Secondary Blocker Confirmation

```text
604304 modified only the run_isolation_audit region of
  sql/migrations/0065_create_security_isolation_rpc.sql (invalid inline `add_check`
  procedure removal and its 13 call-site expansions), per 604306 §3's independently
  confirmed diff.
604305 created only a Verification document; no SQL edit (604305 §10, independently
  corroborated by this Analysis's own git diff check).
604306 created only an Audit document; no SQL or migration file was touched.

`git diff --stat -- sql/migrations/0065_create_security_isolation_rpc.sql`,
  independently re-run in this Analysis, shows the diff confined entirely to the
  run_isolation_audit function (lines up to roughly 760 in the current file);
  scan_cross_tenant_risk (lines 890-1101, containing line 926's defect) shows no
  diff at all -- it is byte-for-byte identical to its state before 604304's edit,
  and to its original, pre-604291 state.

Conclusion: the `jsonb_agg(order_id limit 5)` blocker is confirmed a PRE-EXISTING,
SEPARATE defect within the same 0065 file, not something introduced during
run_isolation_audit's correction. It was simply unreached by replay until
run_isolation_audit's own blocker was cleared -- the same repeating pattern already
observed at every prior stage of this lineage (0035/0038 -> 0042 -> 0046 primary ->
0046 secondary -> 0063 -> 0065 add_check -> now 0065 scan_cross_tenant_risk). This is
not a failure of the 604304 add_check fix; run_isolation_audit remains PASS per
604306.
```

---

## 9. Aggregate Usage Assessment

```text
The single jsonb_agg call at line 926 produces the 'sample_ids' array inside the
ORDER_TENANT_MISMATCH finding object, which itself becomes part of v_risks (returned
as part of scan_cross_tenant_risk's overall jsonb result, alongside v_risk_count and
v_critical_count -- confirmed by reading the remainder of the function through its
`end;` at line ~1101).

Row set: `order_id` from the `mismatched` CTE, itself filtered to orders whose
tenant_id matches p_tenant_id but whose store's tenant_id does not (a genuine
cross-tenant leakage detector) and capped at 10 rows by the CTE's own (valid) LIMIT.

No ORDER BY exists on this row set at any level -- the "5" in `limit 5` is a sample
size, not a top-N-by-some-criterion selection, distinct from 0046's blockers where an
explicit ORDER BY existed and had to be preserved. Here, there is no ranking to
preserve, only the count (5, not the CTE's 10) of sample IDs to preserve.

Independently reconfirmed single-occurrence status (§6, §8): this is the only
jsonb_agg/array_agg/string_agg call in the entire 0065 file; the other five scans in
scan_cross_tenant_risk report only 'count' with no sample-ID field, and
generate_security_report (read directly in this Analysis) contains no aggregate
call of this shape at all.
```

---

## 10. Candidate Fixes

```text
- Candidate A:
  - 변경 요약: Change `jsonb_agg(order_id limit 5)` to `jsonb_agg(order_id)` and
    append `limit 5` to the end of the outer statement (after `from mismatched`,
    before the terminating semicolon) -- the syntactically smaller option.
  - 예상 수정 위치: Line 926 (remove inline limit) and line 932 (append `limit 5`
    after `from mismatched`).
  - replay 영향: Resolves the syntax error; the statement would parse and apply
    successfully.
  - behavior preservation 여부: NOT PRESERVED. The outer `select case when
    count(*) > 0 then ... end into v_risks from mismatched;` has no GROUP BY, so it
    already returns exactly one row per CTE; an outer-query `limit 5` on that
    single-row result is a no-op, identical in mechanism to the risk already
    established for 0046's blockers. 'sample_ids' would include ALL order_ids from
    the `mismatched` CTE -- up to 10 (the CTE's own cap), not 5 as evidently
    intended. This is a smaller magnitude of change than 0046's cases (bounded by
    10, not unbounded) but is still a real, silent behavior change from the intended
    5-item sample.
  - risk: HIGH functional risk for the same reason already twice established in this
    lineage for the aggregate-inline-limit defect class -- syntactically minimal but
    silently changes the sample size the finding reports.

- Candidate B:
  - 변경 요약: Preserve the CTE's own `limit 10` (unchanged -- this bounds detection/
    counting and is not part of the defect) and apply the 5-item sample cap via a
    nested subquery specific to 'sample_ids', so 'count' continues to reflect the
    full (up to 10-row) mismatched set while 'sample_ids' is independently capped at
    5:
      select case when count(*) > 0 then
        jsonb_build_object(
          'risk_type', 'ORDER_TENANT_MISMATCH',
          'severity', 'CRITICAL',
          'count', count(*),
          'sample_ids', (
            select coalesce(jsonb_agg(sub.order_id), '[]'::jsonb)
            from (select order_id from mismatched limit 5) sub
          ),
          'detail', 'Orders assigned to stores of different tenant'
        )
        else null
      end
      into v_risks
      from mismatched;
  - 예상 수정 위치: Line 926 restructured into a scalar subquery expression in place
    of the single invalid jsonb_agg(...) call; no other line in Scan 1 (or any of
    the other five scans) changes.
  - replay 영향: Resolves the syntax error; the statement would parse and apply
    successfully.
  - behavior preservation 여부: PRESERVED. `count(*)` in the outer query continues to
    run over the full `mismatched` CTE (up to 10 rows, unchanged), while the new
    scalar subquery independently selects order_id from the same `mismatched` CTE,
    applies `limit 5` as a valid clause of that inner SELECT (not inside an
    aggregate call), and aggregates only those (at most 5) rows into 'sample_ids' --
    exactly reproducing the two-tier cap (10 for detection/count, 5 for sample) the
    original code's structure evidently intended. No ORDER BY needs to be
    introduced, since none existed originally -- an arbitrary sample of up to 5 rows
    from the same up-to-10-row set is exactly what the original (broken) code
    would have produced had it parsed, since it had no ORDER BY either.
  - risk: Low. No new schema object; no change to the CTE, to 'count', to any of the
    other five scans, or to the function's signature. The only structural addition
    is one small scalar subquery, self-contained and independently verifiable
    against add_check-style precedent already used for 0046's secondary blocker
    (604294/604295: an inner subquery applying row-level ORDER BY + LIMIT, then
    aggregating in the outer query) -- the same shape, minus an ORDER BY clause
    here since none existed to preserve.

- Candidate C:
  - 변경 요약: Remove the LIMIT entirely (report all order_ids from the `mismatched`
    CTE, i.e. up to 10, with no separate 5-item cap).
  - 예상 수정 위치: Line 926, deleting `limit 5` with no replacement, leaving
    `jsonb_agg(order_id)`.
  - replay 영향: Resolves the syntax error.
  - behavior preservation 여부: NOT PRESERVED (same effective outcome as Candidate A
    in this specific case, since the CTE's own 10-row cap becomes the only bound).
  - risk: Same behavior-change risk as Candidate A. Per the task's own framing, this
    is recorded but NOT RECOMMENDED -- there is no indication in the file, its
    comments, or its surrounding scans that the 5-item sample cap is unnecessary or
    was intended to be removed; 'sample_ids' is explicitly a bounded "sample," and
    silently widening it to match the CTE's own unrelated detection cap changes the
    diagnostic payload's shape without any evidence that is desired.
```

---

## 11. Recommended Minimal Fix

```text
Recommended: Candidate B -- preserve the CTE's own limit 10 (detection/count cap,
unaffected) and apply a nested scalar subquery limiting order_id to 5 rows
specifically for 'sample_ids', mirroring the already-approved and already-verified
0046-secondary-blocker fix shape (604294/604295/604296/604297).

Justification against the stated selection criteria:
  - "최소 수정" / "0065 scan_cross_tenant_risk의 syntax blocker만 해소" -- read as
    "the smallest change that fixes the syntax error without altering behavior,"
    consistent with how this criterion was already applied to every prior aggregate-
    limit fix in this lineage (0046 primary/secondary). Candidate B is that fix;
    Candidates A/C are smaller in character count but both silently widen the
    sample from 5 to up to 10.
  - "top-5 sample cap 의미 유지" -- ONLY Candidate B satisfies this; A and C both
    lose the distinct 5-item cap.
  - "기존 risk detection logic 변경 금지" -- satisfied by Candidate B; `count(*)`
    and the `mismatched` CTE's own 10-row detection cap are completely untouched.
  - "기존 diagnostics payload 구조 유지" -- satisfied by Candidate B; the returned
    object's key set ('risk_type', 'severity', 'count', 'sample_ids', 'detail') and
    each key's value type are unchanged; only how 'sample_ids' is computed changes
    internally.
  - "function signature 유지" -- satisfied by all three candidates; none touches
    scan_cross_tenant_risk's parameters or return type.
  - "새 schema object 생성 금지" -- satisfied by Candidate B; the fix is a scalar
    subquery inline within the existing statement, not a new function/procedure/
    table.
  - "run_isolation_audit 수정 금지" -- satisfied; this fix is entirely within
    scan_cross_tenant_risk, a different function, already confirmed unaffected by
    604304's own change.
  - "0046 영향 없음" / "0063 영향 없음" / "0035/0038/0042 영향 없음" -- satisfied;
    the fix touches only 0065's scan_cross_tenant_risk.
  - "0142 직접 수정 없음" -- satisfied.
  - "604250/604260 closeout 금지" -- satisfied; this analysis makes no statement
    about either.
```

---

## 12. Behavior Preservation Assessment

```text
Candidate A: NOT PRESERVED. Silently widens 'sample_ids' from an intended 5-item
sample to up to 10 items (the CTE's own unrelated detection cap), because the outer
query's single-row aggregate collapses any outer-query LIMIT to a no-op.

Candidate B: PRESERVED. `count(*)` continues to reflect the full up-to-10-row
`mismatched` set (detection/counting cap, unchanged); the new scalar subquery
independently caps 'sample_ids' at exactly 5 rows drawn from that same set, with no
ORDER BY needed (none existed originally, so an arbitrary up-to-5-row sample from the
up-to-10-row set is the faithful reproduction of what the original code's structure,
had it parsed, would have produced).

Candidate C: NOT PRESERVED, for the same reason as Candidate A (effectively
equivalent outcome -- up to 10 items instead of 5).
```

---

## 13. Forbidden Scope

```text
This Analysis does not, and no future document produced from it may without
separate authorization:
  - Modify 0065 or any other SQL/migration file.
  - Modify 0063, 0046, 0042, 0038, 0035, or 0142.
  - Modify run_isolation_audit (already fixed and accepted under 604304/604306) or
    generate_security_report (not yet reached, out of this analysis's scope).
  - Resume 604250 implementation.
  - Close 604260.
  - Implement 604310 or create 604316.
  - Create 604308 (Implementation) or 604309 (any successor) -- this Analysis only
    recommends whether proceeding to a 604308 Implementation stage is appropriate;
    it does not create that document.
  - Create any file other than this Analysis document.
```

---

## 14. Risk Assessment

```text
Technical risk on the recommended fix (Candidate B) is low and directly precedented:
it is the same "preserve row-level cap via a nested subquery, aggregate the already-
limited rows in the outer query, no new schema object" shape already Human-approved
and Codex-implemented for 0046's secondary blocker (604294 §8-9, 604295, verified in
604296/604297). The absence of an ORDER BY here (unlike 0046's cases) simplifies the
fix rather than complicating it -- there is no ranking semantic to reproduce, only a
row-count cap distinct from the CTE's own cap.

Scope is narrow and well-bounded: independently reconfirmed in this Analysis (§6,
§8, §9) that this is the ONLY occurrence of this defect class anywhere in 0065 --
unlike 0063, where a similar completeness check found 14 additional undiscovered
occurrences beyond the one replay reported. There is no reason to expect a hidden
multiplicity here.

The function itself, scan_cross_tenant_risk, is a read-only (`stable`) diagnostic/
risk-scan RPC -- lower-stakes than 0063's payment-confirmation/KDS-release-authority
functions (which directly gate financial ledger state and kitchen release) and
comparable in sensitivity to 0046's context-builder functions (informational/
diagnostic payloads, not transactional state changes). This further supports a lower
governance bar than 0063 required.
```

---

## 15. Recommended Next Step

```text
PROCEED_TO_604308_IMPLEMENTATION_BY_CODEX
```

```text
This Analysis recommends proceeding directly to implementation. The governance
question this transformation class raises -- preserving a distinct row-count cap
for an aggregate's JSON output via a nested subquery, rather than naively relocating
LIMIT outside the aggregate call -- was already decided by Human once in this
lineage for 0046's secondary blocker (604294 recommendation, subsequently approved,
implemented under 604295, and verified correct in 604296/604297). The 0065
scan_cross_tenant_risk defect is the same shape, applied to a single, already-
confirmed-isolated occurrence, in a read-only diagnostic function of comparable or
lower sensitivity than the functions already corrected via this exact pattern. No
ORDER BY complicates this instance (simpler than 0046's cases, which required
preserving an explicit ranking), and no new judgment call is introduced beyond what
604294/604295/604296/604297 already exercised successfully.

0046 remains PASS per 604297 Audit. 0063 remains PASS per 604342 Audit.
run_isolation_audit's add_check fix remains PASS per 604344 Audit. None is affected
by this analysis. 0142 remains not reached; 0142 object absence continues to be the
mechanical consequence of upstream replay blockers (now this scan_cross_tenant_risk
defect), not a 0142 failure. 604250 and 604260 remain blocked and are unaffected by
this Analysis.
```
