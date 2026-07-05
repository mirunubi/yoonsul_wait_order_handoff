# 604350_Analysis_Cross_Scope_0046_Context_Builder_Baseline_Replay_Blocker.md

Status: Complete
Lifecycle: Analysis
Gate Classification: Cross-Scope Baseline Migration Replay Blocker — Stage 1 Analysis
Runtime Implementation Authorization: Not Granted
Owner: TBD
Last Updated: 2026-07-05

This is an analysis/scope document only. It performs no implementation and modifies
no SQL, migration, or other file. It does not close 604260 and does not authorize
604250 resume. It does not create 604291 or 604292 — those, if pursued, are separate
future documents.

---

## 1. Analysis Scope

```text
In scope:
  - Direct review of sql/migrations/0046_create_context_builder_rpc.sql.
  - Identification of the exact syntax defect and its PL/pgSQL/SQL context.
  - Confirmation that 0046 is a pre-existing blocker, not something introduced by
    604287/604288/604289.
  - Presentation of candidate fixes (analysis only, no implementation).
  - A single recommended minimal fix, and a decision on whether it can proceed
    directly to Codex implementation or requires Human review first.

Out of scope (not performed, not authorized here):
  - Any edit to 0046 or any other migration.
  - Any change to 0042, 0035, 0038, or 0142.
  - Creating 604291 (Implementation) or 604292 (any successor document).
  - Reopening 604260 closeout or 604250 resume.
```

---

## 2. Inputs Reviewed

```text
sql/migrations/0046_create_context_builder_rpc.sql (full file, 539 lines, read in full)
604289_Audit_Cross_Scope_0042_Delivery_Order_Intake_Baseline_Replay_Blocker.md
  (§8 0046 Replay Blocker Assessment — prior classification and error text)
604288_Verification_Cross_Scope_0042_Delivery_Order_Intake_Baseline_Replay_Blocker.md
  (§5, §11 — verbatim replay failure record)
604287_Module_Cross_Scope_0042_Delivery_Order_Intake_Baseline_Replay_Blocker.md
  (§2 — confirms only 0042 was modified)
git diff --stat for sql/migrations/0046_create_context_builder_rpc.sql (independently
  run in this analysis — confirmed empty, i.e. 0046 is unmodified relative to its
  original, pre-604287 state)
sql/migrations/0045_create_daily_summary_rpc.sql header (dependency confirmation only)
```

---

## 3. Replay Failure Summary

```text
Reported by 604288 Verification (§5), independently re-confirmed by direct source
  read in this Analysis:

  Last applied: 0045_create_daily_summary_rpc.sql
  Failed at:    0046_create_context_builder_rpc.sql
  Error:        syntax error at or near "limit"
  Reported location: LINE 81, "limit p_max_documents"
  Actual source line (this file's own numbering): line 93

(The reported "LINE 81" is psql's in-query line count from the start of the failing
CREATE FUNCTION statement/body context, not this file's absolute line count — the same
kind of numbering offset already observed and explained for 0042 in 604281/604289.
Both point to the same single defect.)
```

---

## 4. 0046 Failure Location

```text
File: sql/migrations/0046_create_context_builder_rpc.sql
Function: catchmenu_knowledge.build_ai_context(...)  (first function in the file,
  L13-268)
Statement: the first document-retrieval SELECT ... INTO v_context_documents
  (L69-128)

Exact failing construct (L69-96):

  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'document_id', d.id,
        ... (9 more fields) ...
      )
      order by
        d.effectiveness_score desc nulls last,
        d.published_at desc
      limit p_max_documents          -- L93: invalid here
    ),
    '[]'::jsonb
  )
  into v_context_documents
  from catchmenu_knowledge.documents d
  where ... (L99-128, tenant/status/audience/query-type filters) ...
```

---

## 5. SQL / PLpgSQL Syntax Assessment

```text
Context identified: a single `SELECT ... INTO` statement (no CTE, no RETURN QUERY, no
  surrounding subquery) assigning the result of an aggregate expression directly to a
  PL/pgSQL variable (v_context_documents). There is no CTE/parentheses bracketing
  mismatch, no PL/pgSQL variable-binding problem, no reserved-word/alias collision,
  and no function-body delimiter ($$ ... $$) issue -- all `$$` pairs in the file are
  correctly matched (confirmed: 3 function bodies, each opened and closed with $$,
  plus one grants DO block, all balanced).

The defect is a keyword-placement problem specific to aggregate function call syntax:

  PostgreSQL's aggregate function call grammar is:
    aggregate_name ( expression [ , ... ] [ order_by_clause ] )
      [ FILTER ( WHERE filter_clause ) ]

  There is no LIMIT clause permitted inside an aggregate function call's own
  parentheses. LIMIT is a clause of a SELECT statement (or a subquery/CTE providing
  rows to an outer query) -- it cannot bound how many rows are consumed *by* an
  aggregate call itself. Placing `limit p_max_documents` after the `order by` clause
  but still inside `jsonb_agg(...)`'s closing paren is exactly the malformed
  construct PostgreSQL's parser rejects with "syntax error at or near "limit"".

This is unambiguously a keyword-placement / aggregate-call-structure error, not a
values/logic bug, not a PL/pgSQL variable-scope bug, and not a delimiter bug.

Cross-check against this file's own second function (search_knowledge, L271-388) is
instructive: there, `limit p_limit;` (L364) is correctly placed as a clause of the
outer SELECT ... INTO statement, AFTER jsonb_agg(...)'s closing paren -- that
placement parses without error. This confirms the defect in build_ai_context is
purely about WHERE the LIMIT token sits relative to the aggregate call's parentheses,
not a misunderstanding of LIMIT's existence in the file.

Important semantic note (relevant to fix selection, §8/§9): even search_knowledge's
"correctly placed" `limit p_limit` at L364 does not actually bound how many documents
are aggregated into the JSON array -- because the query has no GROUP BY, jsonb_agg
collapses all matching rows into exactly one output row, and an outer-query LIMIT on
a single-row aggregate result is a no-op with respect to array size. The same
would be true if build_ai_context's LIMIT were merely relocated to the outer query
in the same way. This distinction matters for choosing a fix that preserves the
apparent intended behavior (top-N documents by effectiveness score) versus one that
is merely syntactically valid but silently returns all matching documents regardless
of p_max_documents.
```

---

## 6. Root Cause Classification

```text
SQL_LIMIT_PLACEMENT_ERROR
```

```text
Reasoning: the LIMIT keyword is placed inside an aggregate function call's argument
list (jsonb_agg(... ORDER BY ...) LIMIT n), a position PostgreSQL's grammar does not
allow. LIMIT belongs to a SELECT statement or a row-producing subquery, never to an
aggregate function invocation. This is not a CTE/parentheses bracketing mismatch (no
CTE is involved, and all parentheses in the statement are correctly balanced -- the
LIMIT keyword itself is simply in a position no valid clause can occupy), not a
PL/pgSQL variable usage error (no `:=`/`=` confusion, no undeclared variable, no type
mismatch), and not a function body delimiter error (all $$ pairs are balanced).
```

---

## 7. Pre-Existing Blocker Confirmation

```text
604287 modified only sql/migrations/0042_create_delivery_order_intake_rpc.sql (one
  line: result_payload := -> result_payload =) -- independently re-confirmed via
  `git diff --stat` in this Analysis, unchanged from the confirmation already recorded
  in 604289 §3/§9.
604288 created only a Verification document; it performed no SQL edit (confirmed:
  604288 §13 "No SQL or migration files were modified during this verification
  pass", independently corroborated by this Analysis's own git diff check showing
  0046 has zero diff).
604289 created only an Audit document; no SQL or migration file was touched.

`git diff --stat -- sql/migrations/0046_create_context_builder_rpc.sql`, run
  independently in this Analysis, returns empty output -- 0046 is byte-for-byte
  identical to its state before 604287/604288/604289 began. Its header
  ("Depends on: 0045_create_daily_summary_rpc.sql") places it in the original
  migration sequence, long predating this entire workpacket lineage (604270/604280).

Conclusion: 0046 remains classified PRE_EXISTING_REPLAY_BLOCKER. It was not newly
introduced by any document or implementation step in 604270, 604280, 604287, 604288,
or 604289 -- it was simply unreached until the replay progressed past 0042.
```

---

## 8. Candidate Fixes

```text
- Candidate A:
  - 변경 요약: Move `limit p_max_documents` outside jsonb_agg(...)'s closing
    parenthesis, appending it as a clause of the outer SELECT ... INTO statement
    (mirroring search_knowledge's L364 pattern in the same file).
  - 예상 수정 라인: L90-97 restructured to close jsonb_agg(...) immediately after the
    ORDER BY clause, then add `limit p_max_documents` after the statement's WHERE
    clause (i.e. after L128, before the terminating semicolon).
  - replay 영향: Resolves the syntax error; 0046 would parse and apply successfully.
  - downstream 영향: None on other migrations (0046's functions have no header-
    declared dependents found in this Analysis's scope).
  - risk: HIGH functional risk despite being syntactically minimal -- because the
    query has no GROUP BY, jsonb_agg collapses all matching rows into a single output
    row, so an outer-query LIMIT does not bound how many documents are included in
    the aggregated JSON array. This candidate would silently return ALL matching
    documents regardless of p_max_documents, removing the apparent intended top-N-by-
    effectiveness-score cap on AI context size. That is a behavior change, not merely
    a syntax fix, and conflicts with the "no business logic change" requirement.

- Candidate B:
  - 변경 요약: Restructure the statement to apply ORDER BY + LIMIT at the row level in
    an inner subquery, then aggregate the already-limited rows with jsonb_agg in the
    outer query -- i.e.:
      select coalesce(jsonb_agg(sub.doc), '[]'::jsonb)
      into v_context_documents
      from (
        select jsonb_build_object(...) as doc
        from catchmenu_knowledge.documents d
        where <all existing L99-128 filter conditions, unchanged>
        order by d.effectiveness_score desc nulls last, d.published_at desc
        limit p_max_documents
      ) sub;
  - 예상 수정 라인: L69-128 restructured into an outer aggregate query wrapping an
    inner subquery; the jsonb_build_object(...) field list (L71-89) and all WHERE
    filter conditions (L99-128) are relocated into the subquery unchanged in content,
    only their position in the statement moves.
  - replay 영향: Resolves the syntax error; 0046 would parse and apply successfully.
  - downstream 영향: None (same as Candidate A -- no other migration references
    build_ai_context's internal query structure).
  - risk: LOW functional risk -- this preserves the apparent intended behavior
    exactly (only the top p_max_documents rows, ordered by effectiveness_score then
    published_at, are aggregated into the returned JSON array), matching what the
    original ORDER BY + LIMIT combination was clearly designed to do. The larger
    textual diff (a genuine restructuring, not a single-token change) is the tradeoff
    for correctness.
```

---

## 9. Recommended Minimal Fix

```text
Recommended: Candidate B (subquery-based ORDER BY + LIMIT), not Candidate A.

Justification against the stated selection criteria:
  - "0046 syntax replay blocker만 해소" -- both candidates satisfy this.
  - "0046의 비즈니스 로직 변경 금지" -- ONLY Candidate B satisfies this. Candidate A is
    smaller in line count, but it silently changes runtime behavior (removes the
    effectiveness-score-based top-N document cap), which is itself a business-logic
    change even though no field, filter, or business rule text is edited. Candidate B
    preserves the exact ordering and row-count-limiting behavior the original code
    was structured to express; only its syntactic packaging (subquery vs. inline
    aggregate LIMIT) changes.
  - "0035/0038/0042 영향 없음" -- both candidates satisfy this; neither touches any
    file other than 0046.
  - "0142 직접 수정 없음" -- both candidates satisfy this.
  - "full replay to 0142를 다시 시도할 수 있게 만드는 것만 목표" -- both candidates
    satisfy the narrow goal of letting 0046 apply; only Candidate B does so without
    an undisclosed side effect on 0046's own behavior.

"Minimal" is read here as "the smallest change that fixes the syntax error without
introducing a behavior change" -- not merely "the fewest characters changed" --
because a smaller diff that silently drops a document-count cap is not actually a
smaller-risk change once its effect is accounted for.
```

---

## 10. Forbidden Scope

```text
This Analysis does not, and no future document produced from it may without separate
authorization:
  - Modify 0046 or any other SQL/migration file.
  - Modify 0042, 0035, 0038, or 0142.
  - Resume 604250 implementation.
  - Close 604260.
  - Implement 604310 or create 604316.
  - Create 604291 (Implementation) or 604292 (any successor) -- this Analysis only
    recommends whether proceeding to a 604291 Implementation stage is appropriate; it
    does not create that document.
  - Create any file other than this Analysis document.
```

---

## 11. Risk Assessment

```text
Technical risk on the recommended fix (Candidate B) itself is low: it is a
restructuring of a single, self-contained SELECT statement, with no change to the
function's signature, its other two sibling functions in the same file
(search_knowledge, record_ai_query), its grants, or any calling migration (none was
found to reference build_ai_context's internal query shape).

Process risk is the more significant consideration here. Every prior fix in this
lineage (0035's rewrite, 0038's one-line correction, 0042's one-line correction) was
gated behind a full Overview/Logic/TestPlan/ChangeContract/Human Approval sequence
before Codex implemented anything -- even for single-token changes. 0046's correct
fix (Candidate B) is qualitatively different from those three: it is not a single-
line/token substitution, it is a genuine restructuring of a query's shape, and -- as
§8 shows -- the syntactically smaller alternative (Candidate A) would silently change
behavior if chosen instead. That divergence between "smallest diff" and "correct
fix" is itself new in this lineage and is exactly the kind of judgment call that
should be confirmed by Human before Codex implements it, rather than Claude
unilaterally treating this Analysis as sufficient authorization on its own.
```

---

## 12. Recommended Next Step

```text
DO_NOT_IMPLEMENT_REQUIRES_HUMAN_REVIEW
```

```text
The root cause and the technically correct fix (Candidate B) are both clearly
identified in this Analysis. However, unlike the three prior fixes in this lineage
(0035, 0038, 0042 -- all single-line/token corrections with no candidate divergence),
0046's correct fix requires a genuine query restructuring, and a syntactically
smaller alternative (Candidate A) exists that would silently alter behavior if chosen
instead. Given that every prior SQL correction in this lineage required explicit
Human Approval before implementation even when the fix was a single token, this
Analysis recommends the same governance step here -- Human should confirm the
Candidate B approach (or select an alternative) before any Overview/Logic/TestPlan/
ChangeContract/Approval package or direct 604291 Implementation is created.
```
