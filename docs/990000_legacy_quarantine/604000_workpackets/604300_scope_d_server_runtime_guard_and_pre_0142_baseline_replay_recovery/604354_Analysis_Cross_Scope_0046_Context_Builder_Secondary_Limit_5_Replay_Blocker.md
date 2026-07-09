# 604354_Analysis_Cross_Scope_0046_Context_Builder_Secondary_Limit_5_Replay_Blocker.md

Status: Complete
Lifecycle: Analysis
Gate Classification: Cross-Scope Baseline Migration Replay Blocker — Stage 1 Analysis
Runtime Implementation Authorization: Not Granted
Owner: TBD
Last Updated: 2026-07-05

This is an analysis/scope document only. It performs no implementation and modifies
no SQL, migration, or other file. It does not close 604260 and does not authorize
604250 resume. It does not create 604295 or 604296 — those, if pursued, are separate
future documents.

604291's primary `limit p_max_documents` fix is already accepted (604292 Verification
PARTIAL/PASSED-for-scope; 604293 Audit ACCEPT_604291_PRIMARY_0046_FIX). This analysis
addresses ONLY the secondary, separately-scoped `limit 5` blocker at (psql-reported)
LINE 153, per the Human approval to open this next analysis module.

---

## 1. Analysis Scope

```text
In scope:
  - Direct review of sql/migrations/0046_create_context_builder_rpc.sql, specifically
    the related-exceptions retrieval block containing the secondary `limit 5` failure.
  - Identification of the exact syntax defect and its PL/pgSQL/SQL context.
  - Confirmation that this secondary blocker is pre-existing and was not introduced by
    604291, 604292, or 604293.
  - Presentation of candidate fixes (analysis only, no implementation).
  - A single recommended minimal fix, and a decision on whether it can proceed
    directly to Codex implementation or requires Human review first.

Out of scope (not performed, not authorized here):
  - Any edit to 0046 or any other migration.
  - Any change to 0042, 0035, 0038, or 0142.
  - Creating 604295 (Implementation) or 604296 (any successor document).
  - Reopening 604260 closeout or 604250 resume.
  - Reopening or modifying the already-accepted 604291 primary fix.
```

---

## 2. Inputs Reviewed

```text
sql/migrations/0046_create_context_builder_rpc.sql (current, post-604291 state, read
  in full for the affected region)
604350_Analysis_Cross_Scope_0046_Context_Builder_Baseline_Replay_Blocker.md (primary
  blocker analysis and the Candidate A/B tradeoff reasoning this analysis re-applies)
604352_Verification_Cross_Scope_0046_Context_Builder_Baseline_Replay_Blocker.md
  (§4-5 verbatim secondary-failure record, §6 prior-baseline recheck)
604353_Audit_Cross_Scope_0046_Context_Builder_Baseline_Replay_Blocker.md (§6 Secondary
  0046 Blocker Assessment — classification and line-number reconciliation)
git diff --stat for sql/migrations/0046_create_context_builder_rpc.sql (independently
  re-run in this analysis — confirmed the diff is limited to the primary-blocker
  region; the secondary block is untouched)
```

---

## 3. Replay Failure Summary

```text
Reported by 604292 Verification (§4), re-confirmed by 604293 Audit (§6), and
  independently re-confirmed by direct source read in this Analysis:

  Last applied before this failure: 0045_create_daily_summary_rpc.sql (unchanged from
    the prior analysis; the primary blocker no longer halts replay)
  Failed at:    0046_create_context_builder_rpc.sql (again, at a later point in the
    same file)
  Error:        syntax error at or near "limit"
  Reported location: LINE 153, "limit 5"
  Actual current source line (this file's own numbering): line 165

(As already reconciled in 604293 §6.5: "LINE 153" is psql's in-statement line count
from the start of the CREATE FUNCTION statement being parsed, not the file's absolute
line number -- the same numbering-offset phenomenon already observed for the original
primary 0046 blocker and for 0042. The implementation-stage estimate of "line 167"
mentioned prior to 604292's precise verification is off by 2 lines from the confirmed
absolute location (165); all three numbers describe the same single construct.)
```

---

## 4. Secondary 0046 Failure Location

```text
File: sql/migrations/0046_create_context_builder_rpc.sql
Function: catchmenu_knowledge.build_ai_context(...) (same function as the already-
  fixed primary blocker, but a later, independent statement within it)
Statement: the second document-retrieval SELECT ... INTO v_related_exceptions block
  (current lines 145-176), guarded by
  `if p_store_id is not null and p_query_type in ('EXCEPTION_GUIDANCE',
  'INCIDENT_RESPONSE') then ... end if;`

Exact failing construct (current lines 145-168):

  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'exception_domain', e.exception_domain,
        'exception_type', e.exception_type,
        'exception_severity', e.exception_severity,
        'exception_status', e.exception_status,
        'occurrence_count', e.occurrence_count,
        'detected_at', e.detected_at,
        'summary', case
          when p_audience = 'INTERNAL_ONLY'
          then e.exception_payload
          else jsonb_build_object(
            'domain', e.exception_domain,
            'type', e.exception_type
          )
        end
      )
      order by e.detected_at desc
      limit 5                          -- line 165: invalid here
    ),
    '[]'::jsonb
  )
  into v_related_exceptions
  from catchmenu_ledger.exceptions e
  where e.store_id = p_store_id
    and e.tenant_id = p_tenant_id
    and e.exception_status in ('OPEN', 'ACKNOWLEDGED', 'IN_RECOVERY')
    and e.detected_at >= now() - interval '24 hours';

JSON payload section produced: v_related_exceptions, the "related recent exceptions"
context block (operational/incident context surfaced to the AI Engine Interface for
EXCEPTION_GUIDANCE and INCIDENT_RESPONSE query types).

Row-set ordering: `order by e.detected_at desc` -- most recently detected exceptions
first.

Cap semantics: `limit 5` is a fixed literal, not a function parameter (unlike the
primary blocker's `p_max_documents`) -- it is unambiguously a top-5-most-recent-
exceptions cap, hardcoded rather than caller-configurable.
```

---

## 5. SQL / PLpgSQL Syntax Assessment

```text
Context identified: a single `SELECT ... INTO` statement (no CTE, no RETURN QUERY),
  structurally identical in shape to the already-fixed primary blocker -- an
  aggregate expression (jsonb_agg(...) with an internal ORDER BY) assigned directly
  to a PL/pgSQL variable (v_related_exceptions). No CTE/parentheses mismatch, no
  PL/pgSQL variable-binding problem, no reserved-word/alias collision, and no
  function-body delimiter issue -- the enclosing `$$ ... $$` for build_ai_context
  remains correctly balanced (confirmed already in 604290 §5 and unaffected by the
  604291 edit, which only touched the primary-blocker region).

The defect is the SAME keyword-placement problem as the primary blocker:
  PostgreSQL's aggregate function call grammar is:
    aggregate_name ( expression [ , ... ] [ order_by_clause ] )
      [ FILTER ( WHERE filter_clause ) ]
  There is no LIMIT clause permitted inside an aggregate function call's own
  parentheses. Here, `limit 5` sits after the `order by e.detected_at desc` clause
  but still inside `jsonb_agg(...)`'s closing paren -- the identical malformed
  construct PostgreSQL's parser rejects, just with a literal `5` instead of a
  parameter and a different table/field set.

This is unambiguously the same class of keyword-placement / aggregate-call-structure
error already diagnosed for the primary blocker in 604290 §5-6, not a new or
different syntax phenomenon.

Semantic note (relevant to fix selection, §8-10): as with the primary blocker, this
statement has no GROUP BY, so jsonb_agg collapses all matching rows into exactly one
output row. Relocating `limit 5` to the end of the outer statement (mirroring
search_knowledge's L364 pattern) would parse successfully but would not bound how
many exceptions are aggregated into the JSON array -- it would return ALL exceptions
matching the WHERE filter (store, tenant, open/acknowledged/in-recovery status,
detected within the last 24 hours) rather than only the 5 most recently detected.
```

---

## 6. Root Cause Classification

```text
SQL_LIMIT_PLACEMENT_ERROR
```

```text
Reasoning: identical in kind to the primary blocker's classification (604290 §6) --
the LIMIT keyword is placed inside an aggregate function call's argument list
(jsonb_agg(... ORDER BY ...) LIMIT 5), a position PostgreSQL's grammar does not
allow. It is not a CTE/parentheses bracketing mismatch (no CTE involved; all
parentheses are balanced), not a PL/pgSQL variable usage error (p_audience,
e.exception_payload, etc. are all correctly referenced; no `:=`/`=` confusion), and
not a function body delimiter error (the $$ pair is untouched by 604291 and remains
balanced).
```

---

## 7. Pre-Existing Secondary Blocker Confirmation

```text
604291 modified only the primary-blocker region of 0046 (the first SELECT ... INTO
  v_context_documents statement, current lines 69-134) -- independently re-confirmed
  in this Analysis via `git diff` for 0046, which shows exactly one contiguous hunk,
  entirely within that first statement. The second statement (containing `limit 5`,
  lines 145-176) does not appear anywhere in the diff.
604292 created only a Verification document; it performed no SQL edit (604292 §9,
  independently corroborated by this Analysis's own git diff check).
604293 created only an Audit document; no SQL or migration file was touched.

Conclusion: the secondary `limit 5` blocker is confirmed PRE-EXISTING. It was present
in 0046 before 604291's edit (it is visible, unchanged, in the diff context as the
statement immediately following the one 604291 modified) and was simply unreached by
replay until the primary blocker in front of it was cleared. It is not something
introduced by 604291, 604292, or 604293, and it sits outside 604291's approved
Candidate B scope (which was limited to the primary blocker only).
```

---

## 8. Candidate Fixes

```text
- Candidate A:
  - 변경 요약: Move `limit 5` outside jsonb_agg(...)'s closing parenthesis, appending
    it as a clause of the outer SELECT ... INTO statement (the syntactically smaller
    option, analogous to how search_knowledge's L364 `limit p_limit` is placed in
    this same file).
  - 예상 수정 라인: current lines 145-168 restructured to close jsonb_agg(...)
    immediately after its `order by e.detected_at desc` clause, then add `limit 5`
    after the WHERE clause (after current line 175, before the terminating
    semicolon).
  - replay 영향: Resolves the syntax error; this statement would parse and apply
    successfully.
  - behavior preservation 여부: NOT PRESERVED. Because the statement has no GROUP BY,
    jsonb_agg already collapses all matching rows into one output row; an outer-query
    LIMIT on that single row is a no-op with respect to array size. This candidate
    would silently return ALL matching exceptions (within the last 24 hours, matching
    status/store/tenant filters) instead of only the 5 most recently detected --
    removing the top-5 cap entirely.
  - risk: HIGH functional risk despite being syntactically minimal -- identical
    tradeoff already identified for the primary blocker's Candidate A in 604290 §8,
    now recurring in the secondary blocker.

- Candidate B:
  - 변경 요약: Restructure the statement to apply ORDER BY + LIMIT at the row level in
    an inner subquery, then aggregate the already-limited rows with jsonb_agg in the
    outer query -- the same pattern already implemented for the primary blocker under
    604291 (verified in 604292/604293).
      select coalesce(jsonb_agg(sub.doc), '[]'::jsonb)
      into v_related_exceptions
      from (
        select jsonb_build_object(
          'exception_domain', e.exception_domain,
          'exception_type', e.exception_type,
          'exception_severity', e.exception_severity,
          'exception_status', e.exception_status,
          'occurrence_count', e.occurrence_count,
          'detected_at', e.detected_at,
          'summary', case
            when p_audience = 'INTERNAL_ONLY'
            then e.exception_payload
            else jsonb_build_object(
              'domain', e.exception_domain,
              'type', e.exception_type
            )
          end
        ) as doc
        from catchmenu_ledger.exceptions e
        where e.store_id = p_store_id
          and e.tenant_id = p_tenant_id
          and e.exception_status in ('OPEN', 'ACKNOWLEDGED', 'IN_RECOVERY')
          and e.detected_at >= now() - interval '24 hours'
        order by e.detected_at desc
        limit 5
      ) sub;
  - 예상 수정 라인: current lines 145-176 restructured into an outer aggregate query
    wrapping an inner subquery; the jsonb_build_object(...) field list (including the
    p_audience-based masking CASE expression) and all WHERE filter conditions are
    relocated into the subquery unchanged in content, only their position moves.
  - replay 영향: Resolves the syntax error; this statement would parse and apply
    successfully.
  - behavior preservation 여부: PRESERVED. The subquery selects and orders rows by
    e.detected_at desc, then LIMIT 5 caps the row count before the outer query
    aggregates -- exactly reproducing the top-5-most-recently-detected-exceptions cap
    the original code was structured to express.
  - risk: LOW functional risk -- same shape and risk profile as the primary
    blocker's already-implemented and already-audited-PASS Candidate B fix (604291/
    604292/604293). The p_audience reference inside the masking CASE expression
    remains valid inside the subquery, since PL/pgSQL function parameters are visible
    throughout the function body, including nested subqueries within a single
    statement -- no additional complication beyond what the primary fix already
    demonstrated.
```

---

## 9. Recommended Minimal Fix

```text
Recommended: Candidate B (subquery-based ORDER BY + LIMIT), not Candidate A -- same
selection logic as 604290 §9 applied to this secondary blocker.

Justification against the stated selection criteria:
  - "0046 secondary `limit 5` syntax replay blocker만 해소" -- both candidates satisfy
    this.
  - "기존 top-5 cap 의미 유지" -- ONLY Candidate B satisfies this; Candidate A
    silently removes the cap (§8).
  - "기존 ordering 의미 유지" -- ONLY Candidate B preserves e.detected_at desc as a
    row-level ordering that actually determines which 5 rows are kept; under
    Candidate A the ORDER BY still executes but has no effect on which rows survive,
    since none are excluded.
  - "JSON payload 구조 유지" -- both candidates preserve the same jsonb_build_object
    field list unchanged; Candidate B relocates it into a subquery without altering
    field names, order, or the p_audience masking logic.
  - "function signature 유지" -- both candidates satisfy this; neither touches
    build_ai_context's parameter list or return type.
  - "0035/0038/0042 영향 없음" -- both candidates satisfy this; neither touches any
    file other than 0046, nor any other statement within 0046.
  - "0142 직접 수정 없음" -- both candidates satisfy this.
  - "604250/604260 closeout 금지" -- neither candidate makes any statement about
    604250/604260 status; that remains outside this analysis's scope regardless.

As in 604290, "minimal" is read as "the smallest change that fixes the syntax error
without altering behavior," not merely "the fewest characters changed."
```

---

## 10. Behavior Preservation Assessment

```text
Candidate A: NOT behavior-preserving. Silently changes v_related_exceptions from a
  top-5-most-recent-exceptions list to an unbounded list of all matching exceptions
  within the last 24 hours -- a business-logic change (removal of a cap) disguised as
  a syntax fix.

Candidate B: Behavior-preserving. The row-level ORDER BY + LIMIT 5 inside the
  subquery reproduces the exact same top-5-most-recent-exceptions selection the
  original (broken) code was written to express; the outer aggregation and JSON
  field structure are unchanged.

This is the same asymmetry already established for the primary blocker in 604290
§8-10, now confirmed to recur identically for the secondary blocker -- reinforcing
that Candidate B is the only option meeting the "no business logic change" /
"behavior preservation" requirement in both cases.
```

---

## 11. Forbidden Scope

```text
This Analysis does not, and no future document produced from it may without separate
authorization:
  - Modify 0046 or any other SQL/migration file.
  - Modify 0042, 0035, 0038, or 0142.
  - Resume 604250 implementation.
  - Close 604260.
  - Implement 604310 or create 604316.
  - Create 604295 (Implementation) or 604296 (any successor) -- this Analysis only
    recommends whether proceeding to a 604295 Implementation stage is appropriate; it
    does not create that document.
  - Reopen or modify the already-accepted 604291 primary-blocker fix.
  - Create any file other than this Analysis document.
```

---

## 12. Risk Assessment

```text
Technical risk on the recommended fix (Candidate B) is low, for the same reasons
already validated for the primary blocker: it is a restructuring of a single, self-
contained SELECT statement, with no change to the function's signature, its sibling
functions in the same file, its grants, or any calling migration.

Process risk is lower here than it was for the primary blocker in 604290. There, this
kind of Candidate A/B divergence (syntactically smaller vs. behavior-preserving) was
novel in this lineage, and every prior fix (0035, 0038, 0042) had been a pure single-
line/token substitution with no such divergence -- which is why 604290 recommended
Human review before implementation. Here, the identical divergence, in the identical
file, using the identical fix shape, was already presented to Human, approved, and
Codex-implemented under 604291, then independently verified (604292) and audited
PASS (604293) with no issues found. This is now a validated, precedented pattern
rather than a novel judgment call -- the primary risk this analysis needs to manage
is confirming the fix is applied narrowly (only to the secondary block, per §7) and
correctly (per §8-10), not re-litigating whether Candidate B is the right general
approach.

Residual risk: as already flagged in 604293 §10, resolving this secondary blocker may
expose a further blocker later in the replay sequence (e.g. the previously-noted
0073_final_verification.sql inline-procedure pattern), following the same repeating
structural pattern already seen twice in this lineage (0035/0038 -> 0042 -> 0046
primary -> 0046 secondary). This is a property of the baseline migration history, not
a defect in this analysis or its recommended fix.
```

---

## 13. Recommended Next Step

```text
PROCEED_TO_604295_IMPLEMENTATION_BY_CODEX
```

```text
Unlike 604290's recommendation for the primary blocker, this Analysis recommends
proceeding directly to implementation, because the governance question that
warranted Human review last time -- whether to accept a behavior-preserving
restructuring (Candidate B) over a syntactically smaller but behavior-altering
alternative (Candidate A) -- has already been decided by Human for this exact file
and this exact fix shape (604291's Approval, applied and accepted through 604292/
604293). This secondary blocker is structurally identical: same function, same
"aggregate ORDER BY + LIMIT" defect pattern, same subquery-based remedy, no new
parameter-scoping or correlated-subquery complication introduced by the different
field list or table. Applying the already-validated Candidate B pattern here is a
mechanical repetition of an approved precedent, not a new judgment call, so this
Analysis recommends Codex proceed to implement it under 604295, scoped narrowly to
the secondary block identified in §4/§8, with no change to the already-accepted
primary-blocker fix, 0035, 0038, 0042, or 0142.

0142 remains not reached. 0142 object absence continues to be the mechanical
consequence of upstream replay blockers, not a 0142 failure. 604250 and 604260 remain
blocked and are unaffected by this Analysis.
```
