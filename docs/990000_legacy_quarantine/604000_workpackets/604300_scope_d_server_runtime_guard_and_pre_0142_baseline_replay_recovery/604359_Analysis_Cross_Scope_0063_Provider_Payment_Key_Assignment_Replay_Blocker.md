# 604359_Analysis_Cross_Scope_0063_Provider_Payment_Key_Assignment_Replay_Blocker.md

Status: Complete
Lifecycle: Analysis
Gate Classification: Cross-Scope Baseline Migration Replay Blocker — Stage 1 Analysis
Runtime Implementation Authorization: Not Granted
Owner: TBD
Last Updated: 2026-07-05

This is an analysis/scope document only. It performs no implementation and modifies
no SQL, migration, or other file. It does not close 604260 and does not authorize
604250 resume. It does not create 604300 or 604301 — those, if pursued, are separate
future documents.

0046 remains PASS per 604297 Audit (both primary and secondary blockers fixed,
unaffected by this analysis). This analysis addresses ONLY the 0063
`provider_payment_key :=` replay blocker.

---

## 1. Analysis Scope

```text
In scope:
  - Direct review of sql/migrations/0063_patch_core_rpc_i18n_diagnostics.sql.
  - Identification of the exact syntax defect(s) and their PL/pgSQL/SQL context.
  - Confirmation that this blocker is pre-existing and was not introduced by
    604291/604295/604296/604297/604298 (all of which touched only 0046 or created
    documentation).
  - A full-file scan for every occurrence of the same defect pattern, not just the
    single occurrence reported by replay -- because replay under ON_ERROR_STOP=1
    halts at the FIRST error and cannot reveal later occurrences of the same defect
    class further down the same file.
  - Presentation of candidate fixes (analysis only, no implementation).
  - A single recommended minimal fix, and a decision on whether it can proceed
    directly to Codex implementation or requires Human review first.

Out of scope (not performed, not authorized here):
  - Any edit to 0063 or any other migration.
  - Any change to 0046, 0042, 0038, 0035, or 0142.
  - Creating 604300 (Implementation) or 604301 (any successor document).
  - Reopening 604260 closeout or 604250 resume.
```

---

## 2. Inputs Reviewed

```text
sql/migrations/0063_patch_core_rpc_i18n_diagnostics.sql (full file, 1074 lines, read
  in full)
604357_Audit_Cross_Scope_0046_Context_Builder_Secondary_Limit_5_Replay_Blocker.md
  (§7 0063 Replay Blocker Assessment — prior classification and error text)
604356_Verification_Cross_Scope_0046_Context_Builder_Secondary_Limit_5_Replay_Blocker.md
  (§3 verbatim replay failure record)
git diff --stat for sql/migrations/0063_patch_core_rpc_i18n_diagnostics.sql
  (independently re-run in this analysis — confirmed empty, i.e. 0063 is unmodified)
sql/migrations/0062_create_i18n_error_diagnostics.sql header (dependency confirmation
  only)
```

---

## 3. Replay Failure Summary

```text
Reported by 604296 Verification (§3), re-confirmed by 604297 Audit (§7), and
  independently re-confirmed by direct source read in this Analysis:

  Last applied: 0062_create_i18n_error_diagnostics.sql
  Failed at:    0063_patch_core_rpc_i18n_diagnostics.sql
  Error:        syntax error at or near ":="
  Reported location: LINE 105, "provider_payment_key := p_provider_payment_key,"
  Actual current source line (this file's own numbering): line 368

(As already established for the prior 0042/0046 blockers: "LINE 105" is psql's
in-statement line count from the start of the CREATE FUNCTION statement being parsed
-- here, catchmenu_payment.confirm_payment_from_provider, whose signature begins at
absolute file line 264. 368 - 264 = 104, consistent with the reported offset of 105
allowing for psql's exact counting convention. Both numbers describe the same single
statement's defect.)
```

---

## 4. 0063 Migration Identification

```text
File: sql/migrations/0063_patch_core_rpc_i18n_diagnostics.sql
Header: "Depends on: 0062_create_i18n_error_diagnostics.sql"
Total length: 1074 lines
Functions created/replaced in this file (3, each a separate top-level
  CREATE OR REPLACE FUNCTION statement):
  1. catchmenu_payment.confirm_payment_from_provider(...)  -- signature at line 264
  2. catchmenu_payment.mark_payment_uncertain(...)          -- signature at line 551
  3. catchmenu_kds.authorize_kds_release(...)               -- signature at line 773
(A fourth function, catchmenu_pos.create_order_session(...), begins at line 16; it
  contains no UPDATE statement and no instance of the defect described in §5-6.)
```

---

## 5. Failure Location

```text
The reported failure is the FIRST invalid token PostgreSQL's parser encounters when
sequentially reading the file -- but it is not the ONLY one. Because psql with
ON_ERROR_STOP=1 aborts the entire script at the first parse error, no replay attempt
to date has been able to reveal what lies beyond it. A full-file scan performed
directly in this Analysis (not relying on replay output alone) found EIGHT separate
UPDATE statements in this file, spanning all three functions, and FIFTEEN total
occurrences of the same invalid `:=` construct across them:

1. confirm_payment_from_provider (lines 264-...):
   a. L365-372 `update catchmenu_payment.payment_intents ... where id = p_intent_id;`
      -- intent_status = 'CONFIRMED' (L367, valid) followed by
      provider_payment_key := (L368, INVALID -- the reported blocker),
      confirmed_amount := (L369, INVALID), confirmed_at := (L370, INVALID),
      updated_at := (L371, INVALID).
   b. L402-407 `update catchmenu_pos.orders ... where id = v_intent.order_id;` --
      order_status = 'PAID' (L404, valid) followed by payment_completed_at :=
      (L405, INVALID), updated_at := (L406, INVALID).
   c. L410-414 `update catchmenu_pos.order_sessions ... where id =
      v_intent.session_id;` -- payment_completed_at := (L412, INVALID, first
      assignment in this SET list), updated_at := (L413, INVALID).
   d. L418-425 `update catchmenu_kds.kds_tickets ... where order_id = ...;` --
      conditions_met = conditions_met || jsonb_build_object(...) (L420-421, valid)
      followed by updated_at := (L422, INVALID).

2. mark_payment_uncertain (lines 551-...):
   e. L621-625 `update catchmenu_payment.payment_intents ... where id =
      p_intent_id;` -- intent_status = 'UNCERTAIN' (L623, valid) followed by
      updated_at := (L624, INVALID).
   f. L629-639 `update catchmenu_kds.kds_tickets ... where order_id = ...;` --
      kds_status = 'HOLD' (L631, valid), hold_reason = 'PAYMENT_UNCERTAIN' (L632,
      valid), conditions_met = conditions_met || jsonb_build_object(...) (L633-634,
      valid) followed by updated_at := (L635, INVALID).

3. authorize_kds_release (lines 773-...):
   g. L868-874 `update catchmenu_payment.payment_ledger ... where id =
      v_ledger.id;` -- kds_release_authorized = true (L870, valid) followed by
      kds_release_authorized_by := (L871, INVALID), kds_release_authorized_at :=
      (L872, INVALID), updated_at := (L873, INVALID).
   h. L877-882 `update catchmenu_kds.kds_tickets ... where order_id = ...;` --
      conditions_met = conditions_met || jsonb_build_object(...) (L879-880, valid)
      followed by updated_at := (L881, INVALID).

Pattern observed in all 8 statements: the FIRST assignment in each SET list correctly
uses `=`; every SUBSEQUENT assignment in the same SET list incorrectly uses `:=` --
except statement (c), L410-414, where the first (and only non-`updated_at`)
assignment is itself `:=`. This is a highly consistent, mechanical pattern across the
whole file, not an isolated one-off typo.

No other `:=` in this file is invalid -- all remaining occurrences (confirmed by the
full grep in this Analysis) are either PL/pgSQL variable assignment (e.g.
`v_business_day := ...`, `v_amount_diff := ...`, `v_audit_id :=
catchmenu_audit.append_audit_record(...)`) or valid named-parameter function-call
syntax (e.g. `p_tenant_id := p_tenant_id` inside calls to
catchmenu_common.raise_i18n_error / catchmenu_common.log_diagnostic /
catchmenu_audit.append_audit_record / notification-send helpers) -- both legitimate
uses of `:=` in PostgreSQL, unlike its use inside a SQL UPDATE...SET column list.
```

---

## 6. SQL / PLpgSQL Syntax Assessment

```text
Context identified: EIGHT separate, self-contained `UPDATE ... SET ... WHERE ...;`
  statements (no CTE, no RETURN QUERY), spread across three CREATE OR REPLACE
  FUNCTION bodies. Each is structurally identical to the already-resolved 0038/0042
  defect: a `:=` operator used where the SQL UPDATE...SET column-assignment operator
  `=` is required.

PostgreSQL's UPDATE statement grammar for its SET clause is:
  UPDATE table SET column = expression [, column = expression ...] WHERE ...
`:=` is PL/pgSQL's variable-assignment operator; it is valid inside a DECLARE/BEGIN
block body when assigning to a local variable, and valid as PostgreSQL's named-
parameter-passing syntax inside a function CALL's argument list -- but it is not a
valid substitute for `=` inside a SQL UPDATE...SET column list, in any of the 8
locations identified in §5.

Because each of these statements sits inside a `create or replace function ...
language plpgsql` body, and PostgreSQL validates PL/pgSQL function bodies at
CREATE-time by default (check_function_bodies = on), the CREATE FUNCTION statement
containing the FIRST such defect (confirm_payment_from_provider, at L368) fails
immediately when 0063 is applied -- the whole file aborts at that point under
ON_ERROR_STOP=1, and the parser never reaches the remaining defects in the same
statement (L369-371) or in the other two functions (mark_payment_uncertain,
authorize_kds_release).

This is unambiguously the same keyword-substitution class of error already resolved
for 0038 and 0042 -- not a CTE/parentheses structure issue, not a JSON_BUILD_OBJECT
syntax issue (jsonb_build_object calls elsewhere in this file, e.g. at L45, L72, L241,
L330, L491, L529, L712, L742, L752, L810, L848, L929, L956, L965, are all correctly
formed and unaffected), not a PL/pgSQL variable-usage error (every genuine variable
assignment and named-parameter call in the file uses `:=` correctly), and not a
function-body delimiter error (all three functions' `$$ ... $$` bodies are correctly
balanced).
```

---

## 7. Root Cause Classification

```text
SQL_UPDATE_SET_ASSIGNMENT_OPERATOR_ERROR
```

```text
Reasoning: every one of the 15 identified defects is `:=` used inside a SQL
UPDATE...SET column list, where PostgreSQL's grammar requires `=`. This is not a
PL/pgSQL assignment-context error (PL/pgSQL variable assignment elsewhere in the
same file correctly uses `:=`, so the operator itself is not misunderstood -- only
its placement inside UPDATE...SET is wrong), not a JSON_BUILD_OBJECT syntax error
(every jsonb_build_object(...) call in the file is well-formed), and not a function
body delimiter error (all $$ pairs are balanced). This is the identical
classification already established and resolved for 0038 and 0042 in this lineage,
recurring here at a larger scale (multiple statements/functions in one file, rather
than a single occurrence).
```

---

## 8. Pre-Existing Replay Blocker Confirmation

```text
604291/604295 modified only sql/migrations/0046_create_context_builder_rpc.sql
  (primary and secondary limit-placement corrections) -- independently re-confirmed
  via `git diff --stat` in this Analysis; neither touched 0063 in any way.
604296 created only a Verification document; it performed no SQL edit (604296 §7,
  independently corroborated by this Analysis's own git diff check showing 0063 has
  zero diff).
604297 created only an Audit document; no SQL or migration file was touched.
604298 performed only a document rename/H1 correction on 604296; no SQL or migration
  file was touched.

`git diff --stat -- sql/migrations/0063_patch_core_rpc_i18n_diagnostics.sql`, run
  independently in this Analysis, returns empty output -- 0063 is byte-for-byte
  identical to its original, pre-604291 state. Its header
  ("Depends on: 0062_create_i18n_error_diagnostics.sql") places it in the original
  migration sequence, 17 numbers after 0046 and entirely unrelated to 0046's
  build_ai_context/search_knowledge/record_ai_query functions.

Conclusion: 0063 is confirmed a PRE-EXISTING replay blocker, not something introduced
during 0046's correction process. It was simply unreached by replay until 0046's two
blockers were cleared -- the same repeating pattern already observed at every prior
stage of this lineage (0035/0038 -> 0042 -> 0046 primary -> 0046 secondary -> now
0063).
```

---

## 9. Candidate Fixes

```text
- Candidate A:
  - 변경 요약: Correct ONLY the single reported occurrence (L368,
    `provider_payment_key :=` -> `provider_payment_key =`), leaving the other 14
    identified occurrences (§5) untouched.
  - 예상 수정 위치: Line 368 only.
  - replay 영향: INSUFFICIENT. Lines 369-371 (`confirmed_amount :=`, `confirmed_at
    :=`, `updated_at :=`) are part of the SAME single UPDATE statement's SET list
    (L365-372) as L368. A SQL statement either parses in its entirety or not at all
    -- correcting only L368 would not allow this statement to parse; the very next
    token error (at L369) would still abort the file at essentially the same
    location. This candidate does not meaningfully advance replay past the current
    blocker at all.
  - behavior preservation 여부: N/A -- the candidate does not produce a parseable
    file, so there is no behavior to evaluate.
  - risk: Not viable as a standalone fix. Recorded here only because the task
    requested a syntactically-smaller option be documented; it is explicitly NOT
    recommended, since it fails to resolve even the reported statement, let alone
    the file.

- Candidate B:
  - 변경 요약: Correct ALL 15 identified `:=` occurrences inside UPDATE...SET column
    lists across all 8 statements in all 3 affected functions (§5), changing each to
    `=`. No other token, clause, function signature, or business-logic expression in
    the file is touched.
  - 예상 수정 위치: L368, L369, L370, L371 (confirm_payment_from_provider,
    payment_intents update); L405, L406 (confirm_payment_from_provider, orders
    update); L412, L413 (confirm_payment_from_provider, order_sessions update); L422
    (confirm_payment_from_provider, kds_tickets update); L624 (mark_payment_uncertain,
    payment_intents update); L635 (mark_payment_uncertain, kds_tickets update); L871,
    L872, L873 (authorize_kds_release, payment_ledger update); L881
    (authorize_kds_release, kds_tickets update).
  - replay 영향: Resolves the syntax error at every location; all three functions
    would compile, and clean sequential replay would progress past 0063 (subject to
    whatever the next, still-undiscovered blocker in the sequence might be).
  - behavior preservation 여부: PRESERVED. Every corrected assignment sets the exact
    same column to the exact same expression already written (e.g.
    `provider_payment_key = p_provider_payment_key`, `confirmed_amount =
    p_approved_amount`, `updated_at = now()`); only the operator changes from
    invalid PL/pgSQL assignment syntax to valid SQL column-assignment syntax. No
    column, value expression, WHERE clause, or business rule changes.
  - risk: Individually, each token change is as low-risk as the already-approved
    0038/0042 corrections. The aggregate risk is one of SCOPE and COVERAGE: 15
    separate corrections across 8 statements in 3 functions in a single pass, inside
    functions that govern payment confirmation, KDS release authorization, and
    payment-uncertain quarantine (특허1/특허2 patent-core, financially and
    operationally sensitive paths). Missing even one of the 15 occurrences would
    leave the file still unable to apply.
```

---

## 10. Recommended Minimal Fix

```text
Recommended: Candidate B -- correcting all 15 occurrences is the only fix that
actually resolves the blocker; Candidate A is not a viable standalone option (§9).

Justification against the stated selection criteria:
  - "최소 수정" -- read as "the smallest change that actually resolves the blocker,"
    not "the fewest characters changed" (consistent with how 604290/604294 already
    interpreted "minimal" for the 0046 blockers). Candidate A changes fewer
    characters but resolves nothing; Candidate B is the true minimum for a working
    file.
  - "0063 syntax replay blocker만 해소" -- satisfied by Candidate B; each of the 15
    corrections is the same narrow syntax-operator fix, nothing broader.
  - "비즈니스 로직 변경 없음" / "provider_payment_key 의미 변경 없음" /
    "provider_tx_id / provider_payment_key 호환 로직 변경 없음" -- satisfied; every
    corrected assignment preserves its original column, value expression, and
    intent exactly. No column semantics, provider-key handling, or compatibility
    logic is touched anywhere in the fix.
  - "0046 영향 없음" / "0035/0038/0042 영향 없음" -- satisfied; the fix touches only
    0063.
  - "0142 직접 수정 없음" -- satisfied.
  - "604250/604260 closeout 금지" -- satisfied; this analysis makes no statement
    about either.
```

---

## 11. Behavior Preservation Assessment

```text
Candidate A: N/A (does not produce a parseable file; no behavior to assess).

Candidate B: Behavior-preserving for all 15 corrections. Each is a pure operator
substitution (`:=` -> `=`) with the same column name and the same right-hand-side
expression on both sides of the change -- no value, condition, or column is added,
removed, or altered. This is the same class of behavior preservation already
confirmed for the 0038 and 0042 corrections in this lineage, simply applied
repeatedly rather than once.
```

---

## 12. Forbidden Scope

```text
This Analysis does not, and no future document produced from it may without separate
authorization:
  - Modify 0063 or any other SQL/migration file.
  - Modify 0046, 0042, 0038, 0035, or 0142.
  - Resume 604250 implementation.
  - Close 604260.
  - Implement 604310 or create 604316.
  - Create 604300 (Implementation) or 604301 (any successor) -- this Analysis only
    recommends whether proceeding to a 604300 Implementation stage is appropriate; it
    does not create that document.
  - Create any file other than this Analysis document.
```

---

## 13. Risk Assessment

```text
Technical risk on each individual correction in Candidate B is low and well-
precedented (identical in kind to the already-approved 0038/0042 fixes). The
aggregate risk is elevated relative to any single prior fix in this lineage, for two
reasons:

1. Scope size: 15 separate token corrections across 8 statements in 3 functions is
   substantially larger than any prior fix (0038: 1 occurrence; 0042: 1 occurrence;
   0046 primary/secondary: 1 restructuring each). A hand-applied correction at this
   scale carries real risk of missing an occurrence or mis-editing an unrelated
   token, especially since 7 of the 15 occurrences were never exposed by any replay
   attempt to date -- they were found only by this Analysis's independent full-file
   scan, not by observed failures.
2. Sensitivity of the affected functions: confirm_payment_from_provider (payment
   confirmation and ledger creation), authorize_kds_release (KDS release
   authorization, explicitly noted in this file's own comments as "특허1: 결제 승인
   ≠ KDS 릴리즈 자동 허용" / "특허1: 결제 승인 후 별도 KDS 릴리즈 권한 부여"), and
   mark_payment_uncertain (payment-uncertain quarantine, "특허1: PAYMENT_UNCERTAIN =
   KDS 전체 HOLD") are all financially and operationally sensitive, patent-core
   paths in this system. A correction here, even a narrow syntactic one, touches
   more consequential code than the delivery-intake (0042) or AI-context-builder
   (0046) functions corrected so far.
```

---

## 14. Recommended Next Step

```text
DO_NOT_IMPLEMENT_REQUIRES_HUMAN_REVIEW
```

```text
Unlike the most recent 0046 secondary-blocker analysis (604294), which recommended
proceeding directly to Codex implementation because the fix was a mechanical repeat
of an already-approved, already-validated pattern in the very same file, this
Analysis recommends Human review first, for two reasons specific to 0063:

1. Scope discovered by this Analysis (15 occurrences across 8 statements in 3
   functions) is far larger than what replay itself has ever reported (1 occurrence).
   Human should confirm the full scope before authorizing an implementation whose
   true correction surface was invisible until this independent static review.
2. The affected functions govern payment confirmation, KDS release authorization,
   and payment-uncertain quarantine -- financially and operationally sensitive,
   patent-core paths (특허1/특허2) more consequential than the delivery-intake or
   AI-context-builder functions already corrected in this lineage. A larger,
   multi-statement correction in this territory warrants the same governance
   checkpoint every SQL correction in this lineage has received before
   implementation, consistent with how 604276/604286 both required explicit Human
   Approval even for single-line fixes in lower-sensitivity files.

0046 remains PASS per 604297 Audit, unaffected by this analysis. 0142 remains not
reached; 0142 object absence continues to be the mechanical consequence of upstream
replay blockers (now 0063), not a 0142 failure. 604250 and 604260 remain blocked and
are unaffected by this Analysis.
```
