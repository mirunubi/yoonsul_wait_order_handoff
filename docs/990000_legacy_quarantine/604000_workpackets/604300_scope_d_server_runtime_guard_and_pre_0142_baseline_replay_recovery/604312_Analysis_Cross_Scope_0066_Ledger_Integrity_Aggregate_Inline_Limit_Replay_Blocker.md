# 604312_Analysis_Cross_Scope_0066_Ledger_Integrity_Aggregate_Inline_Limit_Replay_Blocker.md

Status: Complete
Lifecycle: Analysis
Gate Classification: Cross-Scope Baseline Migration Replay Blocker — Stage 1 Analysis
Runtime Implementation Authorization: Not Granted
Owner: TBD
Last Updated: 2026-07-05

This is an analysis/scope document only. It performs no implementation and modifies
no SQL, migration, or other file. It does not close 604260 and does not authorize
604250 resume. Per explicit Human number decision, 604310 remains unused in this
lineage. It does not create 604313 or 604314 — those, if pursued, are separate future
documents.

0046 remains PASS per 604297 Audit. 0063 remains PASS per 604342 Audit. 0065 remains
FULL PASS per 604311 Audit. This analysis addresses the 0066 `jsonb_agg(... limit 5)`
blocker family.

**Critical finding, stated up front:** the "5 known occurrences" reported by 604309/
604311 (all matching the literal string `jsonb_agg(id limit 5)`) are NOT the full
defect population in this file. An independent full-file scan performed in this
Analysis found **15 total occurrences** of the same AGGREGATE_INLINE_LIMIT_SYNTAX_ERROR
class, spanning all four functions declared in 0066, in two structurally different
shapes. See §5 and §8.

---

## 1. Analysis Scope

```text
In scope:
  - Direct review of sql/migrations/0066_create_ledger_integrity_rpc.sql, in full.
  - Independent, complete enumeration of every jsonb_agg(...) call in the file --
    not limited to the 5 occurrences already reported -- to determine the true
    defect population, per the lesson already learned from 0063 (where a similar
    completeness check found 14 additional occurrences beyond the 1 replay reported).
  - Per-occurrence analysis of function, block, row source, id/column semantics,
    payload key, ORDER BY presence, and intended cap.
  - Confirmation that this blocker family is pre-existing and was not introduced by
    604308 (0065) or any document in this lineage.
  - Presentation of candidate fixes (analysis only, no implementation).
  - A decision on whether this can proceed directly to Codex implementation or
    requires Human review first -- including explicit consideration of whether the
    discovered scope (15, not 5) itself requires Human review before any
    implementation is authorized.

Out of scope (not performed, not authorized here):
  - Any edit to 0066 or any other migration.
  - Any change to 0065, 0063, 0046, 0042, 0038, 0035, or 0142.
  - Creating 604313 (Implementation) or 604314 (any successor document).
  - Reopening 604260 closeout or 604250 resume.
  - Using 604310, which remains reserved/unused per Human number decision.
```

---

## 2. Inputs Reviewed

```text
sql/migrations/0066_create_ledger_integrity_rpc.sql (full file, 1346 lines, read in
  full)
604309_Verification_Cross_Scope_0065_Scan_Cross_Tenant_Risk_Aggregate_Inline_Limit_Replay_Blocker.md
  (§5 verbatim 0066 failure record; reported 5 occurrence lines)
604311_Audit_Cross_Scope_0065_Scan_Cross_Tenant_Risk_Aggregate_Inline_Limit_Replay_Blocker.md
  (§7 0066 blocker classification and reported line numbers)
git diff --stat for sql/migrations/0066_create_ledger_integrity_rpc.sql
  (independently re-run in this analysis — confirmed empty, i.e. 0066 is unmodified)
604307 Analysis and 604294 Analysis (this lineage's own precedent documents for the
  identical AGGREGATE_INLINE_LIMIT_SYNTAX_ERROR class already resolved for 0046 and
  0065)
604299 Analysis (this lineage's own precedent for a case where an independent
  completeness scan found far more occurrences -- 14 additional -- than the single
  one replay had reported, for 0063)
```

---

## 3. Replay Failure Summary

```text
Reported by 604309 Verification (§5), re-confirmed by 604311 Audit (§7), and
  independently re-confirmed by direct source read in this Analysis:

  Last applied: 0065_create_security_isolation_rpc.sql (full pass, per 604311)
  Failed at:    0066_create_ledger_integrity_rpc.sql
  Error:        syntax error at or near "limit"
  Reported location: LINE 84, "'sample_ids', jsonb_agg(id limit 5)"
  Actual current source line (this file's own numbering) of the FIRST occurrence
    encountered by a strict top-to-bottom parse: line 185, inside
    catchmenu_ledger.verify_event_ledger_integrity's CHECK 1 block.

(As already established for every prior blocker in this lineage: psql's reported
line number is an in-statement/in-context count from where the parser began
interpreting the malformed construct, not the file's absolute line number. Both
numbers describe the same first-encountered defect -- but, critically, NOT the only
one in the file. See §5.)
```

---

## 4. 0066 Migration Identification

```text
File: sql/migrations/0066_create_ledger_integrity_rpc.sql
Header: "Depends on: 0065_create_security_isolation_rpc.sql"
Total length: 1346 lines
Objects created:
  - table catchmenu_ledger.integrity_check_results (with RLS policy)
  - function catchmenu_ledger.verify_event_ledger_integrity(...)   -- sig L102-108
  - function catchmenu_ledger.verify_audit_chain(...)               -- sig L432-437
  - function catchmenu_ledger.run_state_projection_check(...)       -- sig L667-672
  - function catchmenu_ledger.reconcile_ledger_gaps(...)            -- sig L975-980
Because ON_ERROR_STOP=1 halts the whole file at the first parse error (inside
verify_event_ledger_integrity, the first of the four functions), NONE of the other
three functions -- including their own instances of this same defect class -- have
ever been exercised by any replay attempt to date. This is the same structural
situation already encountered for 0063 (604299): the true defect population can only
be found by independent static review, not by iterative replay.
```

---

## 5. Occurrence Inventory

```text
Independently enumerated in this Analysis via a full-file search for every
jsonb_agg(...) call (15 total, not 5). All 15 share the identical defect: a LIMIT
clause placed inside the aggregate function call's own parentheses. Two structural
shapes exist:
  - Type 1 ("bare column"): jsonb_agg(<column> limit 5) -- 7 occurrences.
  - Type 2 ("composite object"): jsonb_agg(jsonb_build_object(...) limit 5) -- 8
    occurrences, where the LIMIT is attached to the whole jsonb_build_object(...)
    expression argument rather than a single column.

Of these 15, only 5 (all Type 1, using the literal column name `id`) match the
"jsonb_agg(id limit 5)" string already reported by 604309/604311. The other 10 (2
more Type 1 occurrences using different column names, plus all 8 Type 2 occurrences)
were undiscovered until this Analysis's independent completeness scan, because
ON_ERROR_STOP=1 replay never got past the first occurrence (line 185) to reach any
of the others, and no prior document searched for the broader pattern class.
```

| # | Source Line | Function | Block / Purpose | Payload Key | Row Source | ORDER BY Present | Intended Cap | Recommended Treatment |
|---|---:|---|---|---|---|---|---:|---|
| 1 | 185 | verify_event_ledger_integrity | CHECK 1: Future events | sample_ids | future_events CTE (events, occurred_at > now()+5min, own limit 10) | No | 5 | Type 1 — nested subquery |
| 2 | 223 | verify_event_ledger_integrity | CHECK 2: Orphaned payment events | sample_ids | orphaned_events CTE (events missing payment_ledger ref, own limit 10) | No | 5 | Type 1 — nested subquery |
| 3 | 250 | verify_event_ledger_integrity | CHECK 3: Replay events without origin | sample_ids | bad_replays CTE (events is_replay w/o original_event_id, own limit 10) | No | 5 | Type 1 — nested subquery |
| 4 | 286 | verify_event_ledger_integrity | CHECK 4: Duplicate correlation_ids | correlation_ids | dup_payments CTE (group by correlation_id having count>1; **no CTE-level limit** — unbounded group count) | No | 5 | Type 1 — nested subquery (note: unlike #1-3, no existing 10-row source cap to rely on) |
| 5 | 327 | verify_event_ledger_integrity | CHECK 5: Payment confirmed, no KDS update | order_ids | payment_no_kds CTE (own limit 10) | No | 5 | Type 1 — nested subquery |
| 6 | 556 | verify_audit_chain | CHECK 3: Anonymous financial audit | sample_ids | anon_financial CTE (audit_records, own limit 10) | No | 5 | Type 1 — nested subquery |
| 7 | 582 | verify_audit_chain | CHECK 4: Future audit timestamps | sample_ids | future_audit CTE (audit_records, own limit 10) | No | 5 | Type 1 — nested subquery |
| 8 | 743-749 | run_state_projection_check | PROJECT 1: Payment state mismatch | sample | payment_projection CTE (payment_ledger + LATERAL last event, own limit 20) | No | 5 | Type 2 — nested subquery selecting the object |
| 9 | 797-804 | run_state_projection_check | PROJECT 2: Order state mismatch | sample | order_projection CTE (orders + LATERAL last event, own limit 20) | No | 5 | Type 2 — nested subquery selecting the object |
| 10 | 851-858 | run_state_projection_check | PROJECT 3: KDS state mismatch | sample | kds_projection CTE (kds_tickets + LATERAL last event, own limit 20) | No | 5 | Type 2 — nested subquery selecting the object |
| 11 | 903-909 | run_state_projection_check | PROJECT 4: Session state mismatch | sample | session_projection CTE (order_sessions + LATERAL last event, own limit 20) | No | 5 | Type 2 — nested subquery selecting the object |
| 12 | 1043-1050 | reconcile_ledger_gaps | GAP 1: Order, no payment event | sample | gap_order_payment CTE (orders, own limit 10) | No | 5 | Type 2 — nested subquery selecting the object |
| 13 | 1083-1089 | reconcile_ledger_gaps | GAP 2: KDS ticket, no events | sample | gap_kds CTE (kds_tickets, own limit 10) | No | 5 | Type 2 — nested subquery selecting the object |
| 14 | 1120-1126 | reconcile_ledger_gaps | GAP 3: Session, no events | sample | gap_session CTE (order_sessions, own limit 10) | No | 5 | Type 2 — nested subquery selecting the object |
| 15 | 1161-1167 | reconcile_ledger_gaps | GAP 4: Payment, reconciliation pending | sample | gap_reconciliation CTE (payment_ledger, own limit 10) | No | 5 | Type 2 — nested subquery selecting the object |

```text
Note on the LATERAL-join `limit 1` clauses inside occurrences 8-11's CTEs (e.g.
"order by e.occurred_at desc limit 1" selecting the single latest event per subject):
these are a DIFFERENT, already-valid, unrelated LIMIT usage -- a correctly-placed
LIMIT clause on a correlated subquery's own SELECT, not inside any aggregate call.
They are not part of this defect and must not be touched by any future fix.
```

---

## 6. Occurrence-Level SQL / PLpgSQL Syntax Assessment

```text
All 15 occurrences share the identical grammatical defect already diagnosed for
0046 and 0065 (604273 §2-3, 604283 §2-3, 604307 §6): PostgreSQL's aggregate function
call grammar is `aggregate_name(expression [ORDER BY ...]) [FILTER (WHERE ...)]` --
LIMIT is not a legal clause inside those parentheses. Each of the 15 statements is a
single, self-contained `select case when count(*) > 0 then jsonb_build_object(...)
else <prior value> end into <var> from <cte>;` with no GROUP BY, so each already
collapses to exactly one output row -- identical in mechanism to every prior
aggregate-inline-limit blocker in this lineage.

Type 1 (occurrences 1-7) differs from Type 2 (occurrences 8-15) only in what
argument the invalid LIMIT is attached to: a bare column (id, correlation_id, or
order_id) versus a full jsonb_build_object(...) call. The underlying grammar
violation and required fix shape (row-level LIMIT via a nested subquery, then
aggregate the already-limited rows) is the same for both -- Type 2 simply needs the
nested subquery to select/produce the composite object (or its constituent columns)
rather than a single scalar.

None of the 15 involves a CTE/parentheses bracketing mismatch (every CTE and every
surrounding parenthesis, independently checked in this Analysis, is correctly
balanced), a PL/pgSQL variable-usage error (no `:=`/`=` confusion anywhere in this
file, confirmed by a full-file scan finding zero UPDATE...SET assignment defects),
or a function-body delimiter error (all four `$$ ... $$` pairs are balanced).
```

---

## 7. Root Cause Classification

```text
AGGREGATE_INLINE_LIMIT_SYNTAX_ERROR
```

```text
Reasoning: identical in kind to the already-twice-resolved defect for 0046 (primary
and secondary) and 0065 (scan_cross_tenant_risk) -- a LIMIT clause placed inside an
aggregate function call's own argument list, a position PostgreSQL's grammar does
not permit. All 15 occurrences in 0066 are this same class, confirmed by direct
source read; none is a CTE/parentheses structure error, a function-body syntax
error, or an ambiguous case requiring UNKNOWN_REQUIRES_HUMAN_REVIEW for its
DIAGNOSIS (the diagnosis itself is unambiguous and well-precedented). The scope
question -- whether Human review is required before implementation, given the
discovered 15-vs-5 discrepancy -- is addressed separately in §15, and is not part of
this classification.
```

---

## 8. Pre-Existing Replay Blocker Confirmation

```text
604308 modified only sql/migrations/0065_create_security_isolation_rpc.sql.
604309 created only a Verification document; no SQL edit (604309 §10, independently
  corroborated by this Analysis's own git diff check).
604311 created only an Audit document; no SQL or migration file was touched.

`git diff --stat -- sql/migrations/0066_create_ledger_integrity_rpc.sql`, run
  independently in this Analysis, returns empty output -- 0066 is byte-for-byte
  identical to its original, pre-604291 state. Its header ("Depends on:
  0065_create_security_isolation_rpc.sql") places it immediately after 0065 in the
  original migration sequence, entirely unrelated to any of 0065's four functions.

Conclusion: 0066 -- and specifically all 15 independently-confirmed occurrences of
its aggregate-inline-limit defect, not merely the 5 already reported -- is confirmed
PRE-EXISTING. None was introduced during 0065's correction process. It was simply
unreached by replay (for the reported 5) or entirely unexamined by any prior
document (for the additional 10) until 0065's own blockers were fully cleared. This
is not a failure of the 604308 fix; 0065 remains FULL PASS per 604311.
```

---

## 9. Aggregate Usage And Payload Assessment

```text
Type 1 occurrences (1-7) each cap a "sample" list of raw identifiers (event IDs,
audit record IDs, a business correlation key, or order IDs) drawn from a CTE that
itself already applies its own cap (10 rows for occurrences 1, 2, 3, 5, 6, 7; NO
cap for occurrence 4's dup_payments CTE, since it is a GROUP BY aggregation that
could return an unbounded number of distinct correlation_id groups). In every case,
the outer query's 'count' (or 'total_duplicates' for occurrence 4) reads count(*)/
sum(cnt) over the FULL CTE result, independent of the intended 5-item sample cap --
the same two-tier design (full count vs. capped sample) already established for
0065's single occurrence (604307 §6).

Type 2 occurrences (8-15) each cap a "sample" list of composite diagnostic objects
(e.g. {ledger_id, current, projected} for payment-state mismatches; {order_id,
order_number, order_status, final_amount} for orphaned-payment gaps) drawn from a
CTE capped at 10 or 20 rows. The same two-tier design applies: 'mismatch_count' (or
'count') reads over the full CTE, while 'sample' is meant to cap at 5.

No occurrence, of either type, has an ORDER BY anywhere in its row source or its
aggregate call -- confirmed by full-file review in this Analysis. All 15 samples are
therefore arbitrary (whichever up-to-10-or-20 rows the CTE happens to select), not
ranked -- consistent with 0065's own precedent (604307 §6), where the absence of
ordering simplified rather than complicated the fix.
```

---

## 10. Candidate Fixes

```text
- Candidate A:
  - 변경 요약: For each of the 15 occurrences, change `jsonb_agg(<arg> limit 5)` to
    `jsonb_agg(<arg>)` and append `limit 5` to the end of the outer statement --
    the syntactically smaller option, uniformly applied.
  - 예상 수정 위치: All 15 lines/blocks listed in §5.
  - replay 영향: Resolves all 15 syntax errors; the file would parse and apply.
  - behavior preservation 여부: NOT PRESERVED, for the same reason already
    established at every prior aggregate-inline-limit blocker in this lineage: each
    outer statement collapses to one row (no GROUP BY), so an outer-query LIMIT is a
    no-op. Every sample would silently widen from an intended 5 items to the
    underlying CTE's own cap (10 or 20, or fully unbounded for occurrence 4's
    dup_payments, which has no CTE-level cap at all -- making this candidate's
    behavior change unbounded in that one case, not merely "10 instead of 5").
  - risk: HIGH functional risk, uniformly across all 15, and unboundedly high
    specifically for occurrence 4.

- Candidate B:
  - 변경 요약: For each of the 15 occurrences, preserve the existing CTE's own cap
    (10, 20, or none) unchanged, and cap the sample specifically via a nested
    subquery selecting from the same CTE with its own `limit 5`, then aggregate the
    already-limited rows in the outer expression -- exactly the pattern already
    Human-approved and Codex-implemented for 0065's single occurrence (604307/
    604308, verified in 604309/604311).
  - 예상 수정 위치: All 15 lines/blocks listed in §5. For Type 1 (bare column), the
    restructuring mirrors 0065's exact shape: `(select coalesce(jsonb_agg(sub.<col>),
    '[]'::jsonb) from (select <col> from <cte> limit 5) sub)`. For Type 2 (composite
    object), the nested subquery selects the object expression itself (or its
    constituent columns, then builds the object in the subquery), e.g.: `(select
    coalesce(jsonb_agg(sub.obj), '[]'::jsonb) from (select jsonb_build_object(...) as
    obj from <cte> limit 5) sub)`.
  - replay 영향: Resolves all 15 syntax errors while preserving each occurrence's
    intended 5-item sample cap.
  - behavior preservation 여부: PRESERVED, if each of the 15 restructurings is
    individually verified against its own original construct (per occurrence, per
    §5's inventory) -- a materially larger verification surface than 0065's single
    occurrence or even 0063's 15 single-token corrections, because here each of the
    15 requires a small but non-trivial structural rewrite (not a single character
    change), and 8 of the 15 (Type 2) additionally require correctly relocating a
    multi-field jsonb_build_object(...) expression into the nested subquery.
  - risk: Individually low (same precedented shape as 0065's already-accepted fix).
    In aggregate, this is the largest occurrence count and the most structurally
    varied (two distinct sub-shapes, four different functions, one CTE with no
    pre-existing cap) of any aggregate-inline-limit fix in this lineage to date.

- Candidate C:
  - 변경 요약: Remove the LIMIT entirely at all 15 sites (report the full CTE result
    as the sample, with no separate 5-item cap).
  - 예상 수정 위치: Same 15 locations.
  - replay 영향: Resolves all 15 syntax errors.
  - behavior preservation 여부: NOT PRESERVED -- same outcome as Candidate A for
    occurrences with an existing CTE cap (widens 5 to 10 or 20), and fully unbounded
    for occurrence 4 (dup_payments has no CTE-level cap at all). NOT RECOMMENDED, per
    the task's own framing and consistent with every prior rejection of this option
    in this lineage -- there is no evidence a 5-item sample cap is unnecessary or was
    intended to be removed at any of these 15 sites.
```

---

## 11. Recommended Minimal Fix

```text
Recommended, IN PRINCIPLE: Candidate B, applied individually and separately to all
15 occurrences, mirroring the already-approved 0065 pattern exactly for the 7 Type 1
occurrences and requiring an object-preserving variant for the 8 Type 2 occurrences.

However, this Analysis does NOT recommend proceeding to implementation on this
principle alone (see §15) -- the discovered scope (15 occurrences, not the 5 already
known) and the structural diversity (two shapes, one CTE with no existing cap) place
this squarely in the category this lineage has already established requires
additional Human review before implementation (604299's precedent for 0063), even
though the underlying fix PATTERN itself is well-precedented and mechanically
uniform.

Justification for Candidate B as the eventual correct approach, against the stated
selection criteria:
  - "최소 수정" / "0066 syntax replay blocker만 해소" -- Candidate B resolves the
    syntax error at every site without altering any detection/counting logic.
  - "5개 occurrence 모두 해결" -- reframed by this Analysis's own finding: the
    correct target is 15 occurrences, not 5; Candidate B addresses all 15 uniformly
    in shape.
  - "각 occurrence의 sample-size cap 5 의미 유지" -- ONLY Candidate B satisfies this
    at all 15 sites; A and C both widen the sample (unboundedly, for occurrence 4).
  - "기존 ORDER BY 유무 유지" -- satisfied; no ORDER BY exists at any of the 15
    sites, and Candidate B introduces none.
  - "기존 diagnostics / report payload 구조 유지" -- satisfied by Candidate B; every
    occurrence's returned key set and value types are unchanged.
  - "기존 ledger integrity logic 변경 금지" -- satisfied; count(*)/sum(cnt) and every
    CTE's own detection filter and cap are untouched.
  - "function signature 유지" / "새 schema object 생성 금지" -- satisfied by
    Candidate B for all 15.
  - "0065 수정 금지" / "0063 수정 금지" / "0046 수정 금지" / "0035/0038/0042 영향
    없음" / "0142 직접 수정 없음" -- satisfied; the fix touches only 0066.
  - "604250/604260 closeout 금지" / "604310 계속 미사용" -- satisfied; this analysis
    makes no statement about 604250/604260 status and does not use 604310.
```

---

## 12. Behavior Preservation Assessment

```text
Candidate A / C: NOT PRESERVED at any of the 15 sites -- uniformly widens the sample
from 5 to the CTE's own cap (10 or 20), and unboundedly for occurrence 4 (no
existing cap at all).

Candidate B: PRESERVED at all 15 sites, IF AND ONLY IF each restructuring is
individually verified against its own original construct. This is a materially
larger and more varied verification task than any prior aggregate-inline-limit fix
in this lineage:
  - 7 Type 1 sites, mirroring 0065's exact already-verified shape.
  - 8 Type 2 sites, requiring the nested subquery to correctly reproduce a
    multi-field jsonb_build_object(...) expression rather than a single column --
    a shape not yet exercised anywhere in this lineage.
  - 1 site (occurrence 4) whose source CTE (dup_payments) has no pre-existing
    row-level cap at all, unlike every other occurrence -- the nested subquery's
    LIMIT 5 here is the ONLY cap on the sample list, with no CTE-level backstop; a
    mistake here has a qualitatively different failure mode (unbounded sample if the
    fix is wrong) than the other 14 sites (which would merely revert to their CTE's
    own 10-or-20 cap if the fix were wrong in the same way A/C are wrong).
```

---

## 13. Forbidden Scope

```text
This Analysis does not, and no future document produced from it may without
separate authorization:
  - Modify 0066 or any other SQL/migration file.
  - Modify 0065, 0063, 0046, 0042, 0038, 0035, or 0142.
  - Resume 604250 implementation.
  - Close 604260.
  - Implement 604310 (remains unused per Human number decision) or create 604316.
  - Create 604313 (Implementation) or 604314 (any successor) -- this Analysis only
    recommends whether proceeding to a 604313 Implementation stage is appropriate;
    it does not create that document.
  - Create any file other than this Analysis document.
```

---

## 14. Risk Assessment

```text
Technical risk on the recommended Candidate B pattern, taken site-by-site, is low
and directly precedented (identical shape to 0065's already-accepted fix for the 7
Type 1 sites). The aggregate risk across all 15 sites is materially higher than any
prior single-file aggregate-inline-limit correction in this lineage, for three
compounding reasons:

1. Scope discovered (15) is 3x the scope reported by replay/prior documents (5) --
   the same kind of discrepancy that triggered mandatory Human review for 0063
   (604299), now recurring here at a similar magnitude.
2. Structural diversity: two distinct sub-shapes (Type 1 bare-column vs. Type 2
   composite-object) spanning all four functions in the file, versus 0065's single,
   uniform occurrence.
3. Occurrence 4 (dup_payments, correlation_ids) has no pre-existing CTE-level cap,
   making it the first case in this lineage where the nested-subquery LIMIT is the
   ONLY bound on the sample -- a qualitatively different risk profile than every
   other occurrence in this file or in 0046/0065.

These three factors compound rather than merely add: a 15-site hand-applied fix,
spanning two shapes and one uncapped-source edge case, carries meaningfully more
risk of an incomplete or subtly incorrect application than any single-occurrence or
uniform-shape fix already completed in this lineage (0046 x2, 0065 x1).
```

---

## 15. Recommended Next Step

```text
DO_NOT_IMPLEMENT_REQUIRES_HUMAN_REVIEW
```

```text
Per the task's own explicit trigger conditions, this Analysis must and does select
DO_NOT_IMPLEMENT_REQUIRES_HUMAN_REVIEW, because:
  - The 15 occurrences do NOT all share IDENTICAL semantics -- while the underlying
    grammar defect and general fix shape are uniform, occurrence 4's row source
    (dup_payments) has no pre-existing cap (unlike the other 14), and the 8 Type 2
    occurrences aggregate composite objects rather than bare identifiers, requiring
    a structurally different nested-subquery body than the 7 Type 1 occurrences.
    Applying a single, uniform Candidate-B template across all 15 without Human
    confirmation of this categorization carries real risk.
  - The `id`/key columns across the 15 occurrences point to genuinely different
    domain objects (event ids, audit record ids, a correlation-id business key,
    order ids, and multi-field composite objects describing payment/order/KDS/
    session state mismatches and gaps) -- exactly the condition the task specifies
    as requiring Human review when sample-cap meaning becomes unclear across
    occurrences.
  - No ORDER BY decision is required (none exists anywhere, and none should be
    added, per §9) -- this specific trigger condition does NOT apply, but the other
    two do, and either alone is sufficient per the task's stated criteria.
  - The payload structure cannot be preserved "without difficulty" uniformly across
    both shapes -- Type 2's 8 sites require relocating a multi-field
    jsonb_build_object(...) expression into a nested subquery, a materially more
    involved change than Type 1's single-column relocation, and this Analysis's own
    completeness-driven discovery (15 vs. 5) means Human has not yet had the
    opportunity to confirm the full scope before any implementation proceeds.

0046 remains PASS per 604297 Audit. 0063 remains PASS per 604342 Audit. 0065 remains
FULL PASS per 604311 Audit. None is affected by this analysis. 0142 remains not
reached; 0142 object absence continues to be the mechanical consequence of upstream
replay blockers (now 0066's full 15-occurrence defect population), not a 0142
failure. 604250 and 604260 remain blocked and are unaffected by this Analysis. 604310
remains unused per Human number decision.
```
