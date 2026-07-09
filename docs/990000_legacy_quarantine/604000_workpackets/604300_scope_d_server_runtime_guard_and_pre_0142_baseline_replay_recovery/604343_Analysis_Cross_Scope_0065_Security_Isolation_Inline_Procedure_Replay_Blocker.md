# 604343_Analysis_Cross_Scope_0065_Security_Isolation_Inline_Procedure_Replay_Blocker.md

Status: Complete
Lifecycle: Analysis
Gate Classification: Cross-Scope Baseline Migration Replay Blocker — Stage 1 Analysis
Runtime Implementation Authorization: Not Granted
Owner: TBD
Last Updated: 2026-07-05

This is an analysis/scope document only. It performs no implementation and modifies
no SQL, migration, or other file. It does not close 604260 and does not authorize
604250 resume. It does not create 604304 or 604305 — those, if pursued, are separate
future documents.

0046 remains PASS per 604297 Audit. 0063 remains PASS per 604342 Audit. This analysis
addresses ONLY the 0065 inline procedure `add_check(...)` replay blocker.

---

## 1. Analysis Scope

```text
In scope:
  - Direct review of sql/migrations/0065_create_security_isolation_rpc.sql.
  - Identification of the exact syntax defect and its PL/pgSQL context inside
    catchmenu_audit.run_isolation_audit.
  - A full accounting of every add_check(...) call site, what it accumulates, and
    what payload structure it produces.
  - Confirmation that this blocker is pre-existing and was not introduced by
    604291/604295 (0046) or 604300 (0063).
  - Presentation of candidate fixes (analysis only, no implementation).
  - A single recommended minimal fix, and a decision on whether it can proceed
    directly to Codex implementation or requires Human review first.

Out of scope (not performed, not authorized here):
  - Any edit to 0065 or any other migration.
  - Any change to 0063, 0046, 0042, 0038, 0035, or 0142.
  - Creating 604304 (Implementation) or 604305 (any successor document).
  - Reopening 604260 closeout or 604250 resume.
```

---

## 2. Inputs Reviewed

```text
sql/migrations/0065_create_security_isolation_rpc.sql (full file, 1139 lines, read in
  full for the affected function and its full call-site inventory)
604341_Verification_Cross_Scope_0063_Provider_Payment_Key_Assignment_Replay_Blocker.md
  (§5 verbatim 0065 failure record)
604342_Audit_Cross_Scope_0063_Provider_Payment_Key_Assignment_Replay_Blocker.md (§9
  0065 Replay Blocker Assessment — prior classification and line reconciliation)
git diff --stat for sql/migrations/0065_create_security_isolation_rpc.sql
  (independently re-run in this analysis — confirmed empty, i.e. 0065 is unmodified)
sql/migrations/0035_verify_schema.sql, post-604277 state (referenced as the directly
  analogous already-approved-and-implemented precedent for this exact defect class
  and remedy shape)
```

---

## 3. Replay Failure Summary

```text
Reported by 604341 Verification (§5), re-confirmed by 604342 Audit (§9), and
  independently re-confirmed by direct source read in this Analysis:

  Last applied: 0064_create_menu_i18n_allergen.sql
  Failed at:    0065_create_security_isolation_rpc.sql
  Error:        syntax error at or near "text"
  Reported location: LINE 30, "p_check_name text,"
  Reported CONTEXT: invalid type name "add_check( p_check_name text, p_passed
    boolean, p_severity text, p_detail text, p_remediation text "
  Actual current source line (this file's own numbering) of the procedure
    declaration: line 269, inside catchmenu_audit.run_isolation_audit (function
    signature at line 242).

(As already established for the 0042/0046/0063 blockers in this lineage: psql's
reported line number is an in-statement/in-context count from where the parser began
interpreting the malformed construct as an unexpected type name, not the file's
absolute line number. Both numbers describe the same single defect: the inline
`procedure add_check(...)` declaration.)
```

---

## 4. 0065 Migration Identification

```text
File: sql/migrations/0065_create_security_isolation_rpc.sql
Header: "Depends on: 0064_create_menu_i18n_allergen.sql"
Total length: 1139 lines
Objects created in this file:
  - table catchmenu_audit.security_scan_results (with RLS policy)
  - function catchmenu_audit.verify_rls_coverage(...)       -- signature line 113
  - function catchmenu_audit.run_isolation_audit(...)       -- signature line 241
    (THE AFFECTED FUNCTION)
  - function catchmenu_audit.scan_cross_tenant_risk(...)    -- signature ~line 655
  - function catchmenu_audit.generate_security_report(...)  -- signature ~line 862
Only run_isolation_audit contains the defect; the other three functions were
  independently scanned in this Analysis and contain no inline procedure/function
  declaration inside any DECLARE section.
```

---

## 5. Failure Location

```text
Within catchmenu_audit.run_isolation_audit (lines 241-654), the DECLARE section
  (lines 257-307) declares six items: five ordinary variables (v_scan_id, v_start,
  v_checks, v_critical, v_warnings, v_total, v_passed, v_failed, v_risk_score -- nine,
  precisely) and then, at lines 269-307:

  procedure add_check(
    p_check_name text,
    p_passed boolean,
    p_severity text,
    p_detail text,
    p_remediation text default null
  ) as
  $inner$
  begin
    v_total := v_total + 1;
    if p_passed then
      v_passed := v_passed + 1;
      v_checks := v_checks || jsonb_build_array(
        jsonb_build_object('check', p_check_name, 'status', 'PASS',
          'detail', p_detail)
      );
    else
      v_failed := v_failed + 1;
      v_risk_score := v_risk_score + case p_severity
        when 'CRITICAL' then 25 when 'HIGH' then 15
        when 'MEDIUM' then 5 else 1 end;
      v_critical := v_critical || jsonb_build_array(
        jsonb_build_object('check', p_check_name, 'status', 'FAIL',
          'severity', p_severity, 'detail', p_detail,
          'remediation', p_remediation)
      );
    end if;
  end;
  $inner$;

This is a procedure declared inside a DECLARE section -- the identical grammatical
position already found invalid for pre-fix 0035 (604269/604273/604290's own prior
classification), just inside a named function's body here rather than a DO block's.
```

---

## 6. SQL / PLpgSQL Syntax Assessment

```text
Confirmed: add_check is declared with the keyword `procedure`, followed by a
parameter list and an `as $inner$ ... $inner$;` body -- exactly the same construct
already diagnosed as invalid for 0035 (604273 §2): a PL/pgSQL DECLARE section may
declare variables only; it cannot declare a nested procedure or function. PostgreSQL
raises a parse error at the first token that cannot be interpreted as a variable
declaration -- here, `text` following the parenthesized parameter list, because the
parser has already committed to interpreting `add_check(...)` as an attempted type
name/cast rather than a procedure signature (matching the reported CONTEXT string
"invalid type name \"add_check( p_check_name text, ...\""). This is a parse-time
failure with no dependency on runtime data or the security_scan_results table's
content.

This is not a JSON_BUILD_OBJECT syntax error (every jsonb_build_object/jsonb_
build_array call inside add_check's body and throughout the rest of this file is
well-formed), not a plain UPDATE...SET assignment-operator error (the finalize-scan
UPDATE at lines 574-594 uses `=` correctly throughout, unrelated to the 0063 defect
class), and not an ambiguous case requiring human interpretation to identify -- it is
unambiguously the same DECLARE-section procedure-declaration defect already fully
understood and already fixed once in this lineage for 0035.
```

---

## 7. Root Cause Classification

```text
INLINE_PROCEDURE_DECLARATION_NOT_SUPPORTED
```

```text
Reasoning: PostgreSQL's PL/pgSQL grammar does not permit a procedure or function to
be declared inside another PL/pgSQL block's DECLARE section -- only variables may be
declared there. `add_check` is declared exactly this way (line 269, "procedure
add_check(...) as $inner$ ... $inner$;" inside run_isolation_audit's DECLARE
section). This is not a PLPGSQL_NESTED_FUNCTION_DECLARATION_ERROR in the sense of a
different or ambiguous nesting problem -- it is precisely this one, well-defined,
already-once-resolved defect: an inline procedure declaration where only variable
declarations are legal. It is not a broader FUNCTION_BODY_SYNTAX_ERROR (the $$ ... $$
delimiters for all four functions in this file are correctly balanced) and not a
PROCEDURE_SIGNATURE_SYNTAX_ERROR in the sense of malformed parameter types (all five
parameters -- p_check_name text, p_passed boolean, p_severity text, p_detail text,
p_remediation text default null -- are individually well-formed; the error is their
declaration's placement, not their content).
```

---

## 8. Pre-Existing Replay Blocker Confirmation

```text
604291/604295 modified only sql/migrations/0046_create_context_builder_rpc.sql.
604300 modified only sql/migrations/0063_patch_core_rpc_i18n_diagnostics.sql.
604301 created only a Verification document; no SQL edit (604301 §11, independently
  corroborated by this Analysis's own git diff check).
604302 created only an Audit document; no SQL or migration file was touched.

`git diff --stat -- sql/migrations/0065_create_security_isolation_rpc.sql`, run
  independently in this Analysis, returns empty output -- 0065 is byte-for-byte
  identical to its original, pre-604291 state. Its header ("Depends on:
  0064_create_menu_i18n_allergen.sql") places it in the original migration sequence,
  2 numbers after 0063 and entirely unrelated to 0063's confirm_payment_from_provider/
  mark_payment_uncertain/authorize_kds_release functions or to 0046's
  build_ai_context/search_knowledge/record_ai_query functions.

Conclusion: 0065 is confirmed a PRE-EXISTING replay blocker, not something introduced
during 0046's or 0063's correction process. It was simply unreached by replay until
0063's blocker was cleared -- the same repeating pattern already observed at every
prior stage of this lineage (0035/0038 -> 0042 -> 0046 primary -> 0046 secondary ->
0063 -> now 0065).
```

---

## 9. add_check Usage Assessment

```text
add_check is called 13 times within run_isolation_audit, across 12 named checks
  (one check, "store-level isolation," expands to 2 calls guarded by
  `if p_store_id is not null then ... end if;`, lines 518-544):

  1. tenant_exists_and_active (CRITICAL)              -- L330
  2. orders_tenant_isolation (CRITICAL)                -- L345
  3. payment_ledger_tenant_isolation (CRITICAL)        -- L363
  4. kds_tickets_tenant_isolation (CRITICAL)           -- L381
  5. no_orphaned_sessions (HIGH)                       -- L399
  6. audit_records_append_only (CRITICAL)              -- L418
  7. no_untrusted_devices_online (CRITICAL)            -- L438
  8. agent_execute_permission_restricted (HIGH)        -- L457
  9. kds_release_requires_authorization (CRITICAL)     -- L477
  10. uncertain_payment_blocks_kds (CRITICAL)          -- L499
  11a. store_belongs_to_tenant (CRITICAL, conditional) -- L519
  11b. store_data_boundary (CRITICAL, conditional)     -- L532
  12. knowledge_docs_tenant_isolated (HIGH)            -- L549

Each call passes (p_check_name, p_passed <a boolean expression, often an EXISTS/NOT
  EXISTS subquery>, p_severity, p_detail, p_remediation).

Accumulation structure: add_check mutates five outer-scope variables declared in the
  SAME DECLARE section it is nested in -- v_total (int, always incremented),
  v_passed / v_checks (int / jsonb array, incremented/appended only when p_passed is
  true), v_failed / v_risk_score / v_critical (int / int / jsonb array,
  incremented/appended only when p_passed is false, with v_risk_score's increment
  weighted by p_severity: CRITICAL=25, HIGH=15, MEDIUM=5, else=1).

This closure-style mutation of the enclosing block's variables is only possible
  because add_check is (invalidly) declared as a NESTED procedure sharing the same
  variable scope as run_isolation_audit's own DECLARE block -- this is precisely why
  a simple "extract to a standalone function" fix is not free: a standalone,
  separately-created function or procedure cannot mutate the caller's local PL/pgSQL
  variables by closure the way a nested declaration would (if it were legal); it
  would need explicit INOUT parameters or a return-and-reassign pattern at every call
  site instead.

After all 13 calls, run_isolation_audit finalizes: an UPDATE to
  security_scan_results (lines 574-594, using correct `=` assignment throughout,
  unrelated to the 0063 defect class) records the accumulated totals and findings, a
  diagnostic log call is made, and a jsonb summary is returned (lines 623-653) -- all
  of this consumes v_total/v_passed/v_failed/v_checks/v_critical/v_risk_score exactly
  as accumulated by the 13 add_check calls.
```

---

## 10. Candidate Fixes

```text
- Candidate A:
  - 변경 요약: Remove the inline `procedure add_check(...)` declaration entirely;
    replace each of the 13 `call add_check(p_check_name, p_passed, p_severity,
    p_detail, p_remediation);` invocations with the equivalent IF/ELSE block inlined
    directly at that call site, using add_check's own body verbatim (total
    increment; pass branch appending to v_checks; fail branch computing the
    severity-weighted risk_score increment and appending to v_critical) with the
    call's own literal arguments substituted in place of add_check's parameters.
  - 예상 수정 위치: Remove lines 268-307 (comment + procedure declaration). Replace
    each of the 13 `call add_check(...)` statements (L330, L345, L363, L381, L399,
    L418, L438, L457, L477, L499, L519, L532, L549) with its own expanded IF/ELSE
    block.
  - replay 영향: Resolves the syntax error; run_isolation_audit would compile.
  - behavior preservation 여부: PRESERVED, if every one of the 13 expansions
    faithfully reproduces add_check's exact original body (same total/pass/fail/
    risk_score arithmetic, same jsonb_build_object key sets for PASS vs FAIL). This
    is exactly the same transformation shape already Human-approved and Codex-
    implemented for 0035 (604276/604277): remove an inline DECLARE-section
    procedure, replace each call site with its equivalent inlined logic, add no new
    schema object.
  - risk: No new schema object; no signature change; no new migration dependency.
    Residual risk is purely one of manual-expansion completeness and correctness
    across 13 sites (larger than 0035's per-check logic, which was a simple
    increment + RAISE NOTICE/WARNING with no severity-weighted scoring or
    differently-shaped JSON per branch) -- each of the 13 expansions must correctly
    reproduce the risk-score weighting and the correct JSON shape for its branch.

- Candidate B:
  - 변경 요약: Extract add_check into a new, separately-created standalone helper
    (e.g. catchmenu_audit.add_isolation_audit_check(...)), created as its own
    schema object in this migration, called from run_isolation_audit in place of the
    removed inline procedure.
  - 예상 수정 위치: New CREATE FUNCTION or CREATE PROCEDURE statement added to the
    file (or a later migration); each of the 13 call sites updated to call the new
    object instead of the removed nested procedure.
  - replay 영향: Resolves the syntax error; run_isolation_audit would compile,
    provided the new object and the call-site adaptation are both correct.
  - behavior preservation 여부: Requires additional structural change to preserve
    behavior -- because a standalone function/procedure cannot mutate
    run_isolation_audit's local variables by closure (§9), each call site would need
    to either (a) use PostgreSQL's CALL syntax with INOUT parameters (v_total,
    v_passed, v_failed, v_checks, v_critical passed and reassigned at every call), or
    (b) capture a return value and manually reassign the five variables at every call
    site. Either preserves behavior if done correctly, but is a materially larger
    structural change than Candidate A's direct inlining.
  - risk: Creates a new, permanent schema object not present in the original design;
    adds a migration dependency; requires additional object-existence verification
    before any future closeout; and the INOUT/return-reassignment restructuring at
    every one of the 13 call sites is itself a new source of correctness risk beyond
    what Candidate A requires. Not recommended given the "새 schema object 생성
    최소화" selection criterion.

- Candidate C:
  - 변경 요약: Functionally identical outcome to Candidate A (no new schema object;
    inline expansion at all 13 call sites) but implemented as a more compact,
    single-expression substitution per call site (e.g. computing the resulting
    v_checks/v_critical append and the v_risk_score increment as a single derived
    expression per branch) rather than literally reproducing add_check's original
    multi-line IF/ELSE/END IF structure verbatim.
  - 예상 수정 위치: Same 13 call sites as Candidate A.
  - replay 영향: Same as Candidate A.
  - behavior preservation 여부: Preservable in principle, but harder to verify by
    direct visual comparison against add_check's original body than Candidate A,
    since the logic is restated in a different (more compact) form at each site
    rather than copied verbatim.
  - risk: Marginally higher verification risk than Candidate A for no correctness or
    scope benefit -- Candidate A's verbatim-copy approach is strictly easier to
    audit line-by-line against the original add_check body (as this Analysis itself
    did in §5/§9). Not recommended over Candidate A.
```

---

## 11. Recommended Minimal Fix

```text
Recommended: Candidate A -- remove the inline procedure declaration and replace each
of the 13 call sites with add_check's own body verbatim, substituting each call's
literal arguments in place of add_check's parameters. Not Candidate B (introduces a
new schema object and a more complex INOUT/return-reassignment restructuring,
contrary to the "새 schema object 생성 최소화" criterion) and not Candidate C (offers
no correctness or scope advantage over A, and is harder to verify against the
original body).

Justification against the stated selection criteria:
  - "최소 수정" / "0065 syntax replay blocker만 해소" -- Candidate A resolves the
    syntax error with no broader change; it is the direct, already-precedented
    (604270/604276/604277's 0035 fix) transformation for this exact defect class.
  - "새 schema object 생성 최소화" -- ONLY Candidate A/C satisfy this; Candidate B
    creates a new function/procedure object. Between A and C, A is preferred for
    verifiability (§10).
  - "catchmenu_audit.run_isolation_audit function signature 유지" -- satisfied by
    all three candidates; none touches the function's parameters or return type.
  - "audit result payload 구조 유지" / "check ordering 유지" /
    "severity/status/message semantics 유지" -- satisfied by Candidate A precisely
    because it reproduces add_check's original body verbatim at each site: the same
    v_checks/v_critical jsonb_build_object key sets, the same severity-weighted
    risk_score arithmetic, and the same 13-call ordering (unchanged call sequence,
    only each call's shape changes from a procedure invocation to an inlined block).
  - "0046 영향 없음" / "0063 영향 없음" / "0035/0038/0042 영향 없음" -- satisfied;
    the fix touches only 0065.
  - "0142 직접 수정 없음" -- satisfied.
  - "604250/604260 closeout 금지" -- satisfied; this analysis makes no statement
    about either.
```

---

## 12. Behavior Preservation Assessment

```text
Candidate A: PRESERVED, if each of the 13 expansions is verified against add_check's
original body (§5) for: (a) the unconditional v_total increment, (b) the pass-branch
v_passed increment and v_checks append with the exact 'check'/'status'/'detail' key
set, (c) the fail-branch v_failed increment, severity-weighted v_risk_score increment
(CRITICAL=25/HIGH=15/MEDIUM=5/else=1), and v_critical append with the exact
'check'/'status'/'severity'/'detail'/'remediation' key set. This is the same
verification rigor 604296/604301 already applied when confirming 0046/0063's
corrections preserved their respective original semantics, and the same rigor 0035's
own fix (604277) received.

Candidate B: Preservable only with correct INOUT or return-reassignment handling at
all 13 call sites in addition to the new object's own correctness -- a larger
verification surface for the same behavioral guarantee.

Candidate C: Preservable in principle but harder to verify directly against the
original body than Candidate A, since the restated form differs from add_check's
literal structure.
```

---

## 13. Forbidden Scope

```text
This Analysis does not, and no future document produced from it may without separate
authorization:
  - Modify 0065 or any other SQL/migration file.
  - Modify 0063, 0046, 0042, 0038, 0035, or 0142.
  - Resume 604250 implementation.
  - Close 604260.
  - Implement 604310 or create 604316.
  - Create 604304 (Implementation) or 604305 (any successor) -- this Analysis only
    recommends whether proceeding to a 604304 Implementation stage is appropriate; it
    does not create that document.
  - Create any file other than this Analysis document.
```

---

## 14. Risk Assessment

```text
Technical risk on the recommended fix (Candidate A) is bounded and well-precedented
in KIND: it is the same "remove inline DECLARE-section procedure, inline its body at
each call site, no new schema object" transformation already Human-approved and
Codex-implemented for 0035 in this lineage (604276/604277), and independently
verified correct there (604278/604279: PASS 85/FAIL 0/TOTAL 85).

It differs from 0035's precedent in two respects that raise the SCALE and CARE
required, though not the fundamental approach:
  1. Fewer repetitions (13 vs. 0035's 85), which somewhat lowers the raw
     completeness risk relative to 0035.
  2. Richer per-call logic (severity-weighted risk-score arithmetic and two
     differently-shaped JSON payloads, versus 0035's uniform simple pass/fail
     counting with no scoring), which raises the per-site correctness risk relative
     to 0035.

On balance, these are judged to offset rather than compound: fewer sites to expand,
but each site needs closer attention to the severity/branch-shape details. This is
the same class of "mechanical repetition of an already-validated transformation
pattern" already found low-risk enough to proceed directly for the 0046 secondary
blocker (604294), and the completeness discipline required is the same discipline
604300 already demonstrated correctly across 15 occurrences for 0063 (604302 §3
confirmed all 15, none missed).

The affected function, run_isolation_audit, is a security/compliance audit RPC whose
own results are documented in this file as "evidence for compliance audits" (line
106-107) -- meaningful, but a materially different risk class than 0063's payment-
confirmation/KDS-release-authority functions, which directly gate financial ledger
state and kitchen release. This lowers the case for mandatory Human review relative
to 0063, while the richer per-call logic (point 2 above) argues for care in
verification once implemented.
```

---

## 15. Recommended Next Step

```text
PROCEED_TO_604304_IMPLEMENTATION_BY_CODEX
```

```text
This Analysis recommends proceeding directly to implementation, because the
governance question this exact transformation class raises -- removing an inline
DECLARE-section procedure and replacing it with inlined logic at each call site, with
no new schema object -- was already decided by Human once in this lineage for 0035
(604276 Approval) and independently verified correct (604278/604279). The transform
shape for 0065 is identical; only the call count (13, fewer than 0035's 85) and the
per-call logic (severity-weighted scoring plus two JSON shapes, richer than 0035's
uniform counting) differ, and neither difference introduces a new kind of judgment
call -- it is the same precedented pattern, applied to different, moderately more
detailed input.

The required completeness discipline (verify all 13 expansions individually against
add_check's original body, per §12) mirrors exactly what 604300/604302 already
demonstrated for 0063's 15 occurrences, so this is not asking for a new verification
capability, only a repeat of one already exercised successfully in this lineage.

0046 remains PASS per 604297 Audit. 0063 remains PASS per 604342 Audit; neither is
affected by this analysis. 0142 remains not reached; 0142 object absence continues to
be the mechanical consequence of upstream replay blockers (now 0065), not a 0142
failure. 604250 and 604260 remain blocked and are unaffected by this Analysis.
```
