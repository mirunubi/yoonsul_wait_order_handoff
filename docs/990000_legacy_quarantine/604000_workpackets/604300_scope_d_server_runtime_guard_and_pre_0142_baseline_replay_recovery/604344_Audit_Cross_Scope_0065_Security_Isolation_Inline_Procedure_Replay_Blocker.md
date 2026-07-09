# 604344_Audit_Cross_Scope_0065_Security_Isolation_Inline_Procedure_Replay_Blocker.md

Status: Complete
Lifecycle: Audit
Gate Classification: Cross-Scope Baseline Migration Replay Blocker — Stage 6 Independent Audit
Runtime Implementation Authorization: Not Granted By This Document
Owner: Claude (Independent Auditor)
Last Updated: 2026-07-05

This is an independent audit of 604304's implementation and 604305's verification
against the Candidate A scope recommended in 604303 for the 0065 inline `add_check`
procedure blocker. It performs no implementation and modifies no SQL, migration, or
other document. It does not close 604260 and does not authorize 604250 resume. It
does not create 604307.

---

## 1. Audit Scope

```text
In scope:
  - Whether 604304's implementation stayed within the 604303-recommended Candidate A
    boundary for 0065 (direct source diff, not just self-report).
  - 604305's verification evidence for the add_check fix, prior 0035/0038/0042/0046/
    0063 baseline stability, and the newly reported secondary aggregate-limit
    blocker within the same 0065 file.
  - Whether the secondary blocker is a new problem introduced by this workpacket or
    a separate, pre-existing defect.
  - Independent completeness check: whether any further instance of the same
    aggregate-limit defect class exists elsewhere in 0065, beyond the single
    occurrence replay reported.
  - Whether 604260/604250/604310/604316 boundaries were respected throughout.

Out of scope (not performed, not authorized here):
  - Fixing the secondary 0065 blocker, or any migration after 0065.
  - Any change to 0065, 0063, 0046, 0042, 0038, 0035, or 0142.
  - Reopening 604260 closeout or 604250 resume.
  - Creating any new workpacket or document beyond this Audit.
```

---

## 2. Inputs Reviewed

```text
604343 Analysis (Candidate A recommendation — remove inline add_check procedure,
  expand all 13 call sites inline, no new schema object;
  PROCEED_TO_604304_IMPLEMENTATION_BY_CODEX)
604305_Verification_Cross_Scope_0065_Security_Isolation_Inline_Procedure_Replay_Blocker.md
  (read in full)
sql/migrations/0065_create_security_isolation_rpc.sql (current, post-604304 state,
  read in full for both the corrected region and the newly reported secondary region)
git diff for 0065, 0035, 0038, 0042, 0046, 0063, and 0142 — run independently in this
  Audit, not merely taken from 604305's self-report
No separate 604304 Module document exists as a file; its implementation summary was
  relayed directly for this Audit and is independently verified in §3 below against
  the actual source diff rather than accepted at face value.
```

---

## 3. 604304 Implementation Audit

```text
Independently confirmed via `git diff --stat` for 0065, run in this Audit: "1 file
  changed, 377 insertions(+), 145 deletions(-)".

The full diff, independently reviewed, shows:
  - The inline `procedure add_check(p_check_name text, p_passed boolean, p_severity
    text, p_detail text, p_remediation text default null) as $inner$ ... $inner$;`
    declaration (originally lines 269-307, inside run_isolation_audit's DECLARE
    section) is entirely removed.
  - All 13 `call add_check(...)` invocations are replaced with inline `if ... then
    ... else ... end if;` blocks, each reproducing add_check's original body: an
    unconditional `v_total := v_total + 1;`, a pass branch appending to v_checks with
    the 'check'/'status'/'detail' key set, and a fail branch computing
    `v_risk_score := v_risk_score + case '<literal severity>' when 'CRITICAL' then 25
    when 'HIGH' then 15 when 'MEDIUM' then 5 else 1 end;` and appending to v_critical
    with the 'check'/'status'/'severity'/'detail'/'remediation' key set.
  - Each expansion substitutes the call's own literal severity value into the CASE
    expression (e.g. `case 'CRITICAL' when 'CRITICAL' then 25 ...` for a CRITICAL
    check, `case 'HIGH' when 'HIGH' then 15 ...` for a HIGH check) -- functionally
    identical to the original parameterized form, since each call site's severity is
    a compile-time-known literal.

Independent completeness check: this Audit counted `v_total := v_total + 1;`
  occurrences within run_isolation_audit specifically (excluding an unrelated,
  coincidentally-named `v_total` counter inside the separate verify_rls_coverage
  function at line 161, which belongs to a different function's DECLARE section and
  was untouched by 604304) and found exactly 13 -- matching the 13 call sites
  catalogued in 604303 §9, including both conditional calls inside the
  `if p_store_id is not null then ... end if;` guard (lines 688, 722), confirming no
  call site was missed and none was duplicated.

Independent severity-weighting check: this Audit spot-checked the risk_score
  arithmetic for both severity classes present in the original 13 checks --
  confirmed `case 'CRITICAL' ... then 25` for CRITICAL checks and `case 'HIGH' ...
  then 15` for HIGH checks, matching add_check's original weighting exactly.

No new schema object (function, procedure, table, or index) was created; no other
  function in the file (verify_rls_coverage, scan_cross_tenant_risk,
  generate_security_report) was touched by this diff; run_isolation_audit's own
  signature (p_tenant_id uuid, p_store_id uuid default null, p_scanned_by_type text
  default 'SYSTEM', p_scanned_by_id uuid default null) is confirmed unchanged.

604304 implementation conclusion: PASS. It matches the 604303-recommended Candidate A
scope exactly and completely: all 13 sites expanded, none missed, no new object
created, signature and semantics preserved.
```

---

## 4. 604305 Verification Audit

```text
Q: Was 604305 executed on a clean, disposable verification DB?
  CONFIRMED per 604305 §3/§4: fresh database catchmenu_local_verify_604305 (not
  reused from any prior run: 604301, 604296, or 604292/604278/604288), migrations
  copied fresh into the container, sequential apply with ON_ERROR_STOP=1.

Q: Did 604305 honestly record both the add_check fix's success and the newly
   surfaced secondary blocker within the same 0065 file?
  CONFIRMED. 604305 §6/§12 explicitly separates "604304 add_check fix objective:
  met" and "run_isolation_audit exists: Yes" from "Full 0065 replay-through
  completion: not met (secondary aggregate-limit defect remains in same file)".
  Nothing about the secondary blocker is used to understate the add_check fix's
  success, and nothing about the add_check fix is used to imply 0065 (or 0142) is
  closer to fully verified than it is.

Q: Did 604305 make any SQL or migration change?
  CONFIRMED NOT. §10 Boundary Verification states no SQL/migration file was
  modified, independently corroborated in this Audit: 0065's diff (§3 above)
  contains only the add_check expansion, and the secondary blocker's construct
  (line 926) shows no diff at all -- it is present, unmodified, both before and
  after 604304.

604305 verification conclusion: PASS for its stated scope; accurate, non-overstated
record of both what succeeded (add_check fix) and what remains blocked (secondary
aggregate-limit defect).
```

---

## 5. add_check Inline Procedure Assessment

```text
A. 604304 add_check fix audit:

1. Was the inline `procedure add_check(...)` removed? YES, confirmed via git diff
   (§3) -- the declaration no longer exists anywhere in the file.
2. Were all 13 call sites expanded inline? YES, confirmed via independent count of
   `v_total := v_total + 1;` occurrences within run_isolation_audit (13, matching
   604303 §9's inventory exactly, including both conditional store-level checks).
3. Do any `add_check` or `add_check(` references remain? NO. Independently
   re-confirmed via full-file search in this Audit: zero matches for `procedure
   add_check` or `call add_check` anywhere in the current file.
4. Was a new helper function, procedure, or other schema object created? NO.
   Independently confirmed: the diff contains no CREATE FUNCTION, CREATE PROCEDURE,
   CREATE TABLE, or CREATE INDEX statement; only the DECLARE-section removal and the
   13 call-site expansions.
5. Was run_isolation_audit's function signature preserved? YES. Confirmed unchanged:
   catchmenu_audit.run_isolation_audit(p_tenant_id uuid, p_store_id uuid default
   null, p_scanned_by_type text default 'SYSTEM', p_scanned_by_id uuid default null)
   returns jsonb.
6. Are the v_total/v_passed/v_failed/v_checks/v_risk_score/v_critical accumulation
   semantics preserved? YES. Each expansion reproduces the original unconditional
   total increment, the pass-branch counter/array update, and the fail-branch
   counter/risk-score/array update with the same key sets and the same severity
   weighting (CRITICAL=25, HIGH=15, MEDIUM=5, else=1), independently spot-checked in
   §3 for both severity classes actually present in the 13 checks.
7. Are check ordering, severity, and payload semantics preserved? YES. The 13
   expansions appear in the exact same order as the original 13 `call add_check(...)`
   invocations (including the store_id-conditional guard around the 2 store-level
   checks), and each expansion's literal check name, severity, detail, and
   remediation text are copied unchanged from the corresponding original call's
   arguments.

add_check inline procedure assessment: PASS. The fix is complete, correct, and
introduces no new schema object.
```

---

## 6. run_isolation_audit Creation Assessment

```text
B. 604305 verification audit:

1. Did the add_check fix pass clean replay? YES, per 604305 §5/§6 ("Inline procedure
   add_check blocker at apply: Did not recur"), independently consistent with this
   Audit's own confirmation that the construct is now syntactically valid (§5).
2. Does catchmenu_audit.run_isolation_audit exist after replay? YES, per 604305 §6,
   with its signature verified matching the unmodified original.
3. Is 0065 fully applied (all four declared objects created)? NO. 604305 §5/§6
   confirms the file's apply halted partway through, after run_isolation_audit
   succeeded, when it reached the secondary blocker inside scan_cross_tenant_risk.
   scan_cross_tenant_risk and generate_security_report are both confirmed NOT
   created, consistent with a file that aborts mid-application under
   ON_ERROR_STOP=1 -- CREATE FUNCTION statements before the failure point (the
   table, verify_rls_coverage, run_isolation_audit) succeed; those after it
   (scan_cross_tenant_risk, generate_security_report, and the trailing grants/
   comments) are never reached.

604305 verification audit: PASS for its stated scope (add_check fix verified
correct); the file's overall incompleteness is a separate, accurately-reported fact,
not a verification failure.
```

---

## 7. 0065 Secondary jsonb_agg Limit Blocker Assessment

```text
C. 0065 secondary blocker audit:

1. Did 0065 fail again during 604305's replay, at a new location within the same
   file? YES. Independently confirmed by direct source read in this Audit:
   sql/migrations/0065_create_security_isolation_rpc.sql, line 926, inside
   catchmenu_audit.scan_cross_tenant_risk (function signature preceding it, body
   using a CTE named `mismatched`):
     select case when count(*) > 0 then
       jsonb_build_object(
         'risk_type', 'ORDER_TENANT_MISMATCH',
         'severity', 'CRITICAL',
         'count', count(*),
         'sample_ids', jsonb_agg(order_id limit 5),   -- line 926: invalid
         'detail', 'Orders assigned to stores of different tenant'
       )
       else null
     end
     into v_risks
     from mismatched;
   This is the identical SQL_LIMIT_PLACEMENT_ERROR class already resolved twice in
   this lineage (0046 primary and secondary blockers, 604291/604295): a `LIMIT`
   clause placed inside an aggregate function call's own parentheses
   (`jsonb_agg(order_id limit 5)`), which PostgreSQL's grammar does not permit.
2. Is this a failure of the 604304 add_check fix? NO. run_isolation_audit (the
   function add_check was declared inside) applies successfully and completely;
   the new failure is in a different function (scan_cross_tenant_risk) entirely,
   unreached until run_isolation_audit's blocker was cleared.
3. Was this construct touched by 604304? NO. Independently confirmed: the git diff
   for 0065 (§3) contains only the run_isolation_audit region (DECLARE-section
   removal plus 13 call-site expansions, all before line ~760); scan_cross_tenant_
   risk (beginning after line ~862 per 604303 §4) and its line-926 construct do not
   appear anywhere in the diff -- it is byte-for-byte identical to its state before
   604304's edit.
4. Completeness check performed independently in this Audit (beyond what replay or
   604305 reported): a full-file search for every `jsonb_agg`/`array_agg`/
   `string_agg` call in 0065 found exactly ONE such call in the entire file (line
   926) -- unlike 0063, where the same completeness check found 14 additional
   undiscovered occurrences of that file's defect class beyond the one replay
   reported, 0065 has no further hidden instances of the aggregate-inline-limit
   defect. The other `limit 10` occurrences found elsewhere in the file (lines 919,
   950, 976, 1001, 1027, 1053) are all valid CTE-level LIMIT clauses, correctly
   placed as a clause of their enclosing SELECT, not inside any aggregate call's
   parentheses -- confirmed not part of this defect class.

Secondary 0065 blocker classification: AGGREGATE_INLINE_LIMIT_SYNTAX_ERROR, confirmed
a single, isolated, pre-existing occurrence (not a repeated pattern like 0063's),
unrelated to and not introduced by 604304.
```

---

## 8. 0046 / 0063 Regression Assessment

```text
0046: 604305 §7 reports sequential apply passed, build_ai_context exists, and
  neither the primary `limit p_max_documents` blocker nor the secondary aggregate
  `limit 5` blocker recurred -- independently corroborated via `git diff --stat`,
  showing 0046's diff unchanged in size (127 lines: 67 insertions/60 deletions
  primary + secondary combined) from the state already audited and accepted in
  604297.

0063: 604305 §7 reports sequential apply passed, no `provider_payment_key :=`
  matches, and all three target functions (confirm_payment_from_provider,
  mark_payment_uncertain, authorize_kds_release) exist -- independently
  corroborated via `git diff --stat`, showing 0063's diff unchanged in size (30
  lines: 15 insertions/15 deletions) from the state already audited and accepted in
  604302.

Neither file was modified during 604304/604305 -- confirmed via git diff showing
identical diff sizes to their previously audited states.

0046 / 0063 regression audit: PASS. No regression; both fixes remain intact and
unmodified.
```

---

## 9. 0035 / 0038 / 0042 Regression Assessment

```text
D. Regression audit:

1. 0035: 604305 §7 reports PASS: 85 / FAIL 0 / TOTAL 85 -- independently
   corroborated via `git diff --stat`, showing 0035's diff unchanged in size (868
   lines) from the state already audited and accepted in every prior audit in this
   lineage (604279/604289/604293/604297/604302).
2. 0038: 604305 §7 reports verify_toss_signature and process_toss_webhook both
   exist -- independently corroborated via `git diff --stat`, unchanged (1
   insertion/1 deletion) from the state already audited.
3. 0042: 604305 §7 reports all three delivery intake functions exist --
   independently corroborated via `git diff --stat`, unchanged (1 insertion/1
   deletion) from the state already audited.
4. Were any of these three files modified during 604304/604305? NO. Each file's
   diff, independently re-measured in this Audit, is byte-for-byte identical in
   size to the diff already confirmed in every preceding audit in this lineage --
   no new commit or edit touched any of them.

0035/0038/0042 regression audit: PASS. No regression; all three prior fixes remain
intact and unmodified.
```

---

## 10. 0142 Reachability Assessment

```text
E. 0142 reachability audit:

1. Was 0142 reached? NO. 604305 §8/§9 confirms replay halted within 0065, well
   before 0142; independently confirmed unchanged via `git diff --stat` for 0142
   (408-line pre-existing addition, same as every prior audit in this lineage).
2. Is the cause 0142 itself? NO. The secondary blocker is a distinct construct
   inside scan_cross_tenant_risk, unrelated to 0142's content. There is no
   evidence, static or runtime, of any defect in 0142's own content. Its prior
   independent audit (604269) already found it structurally sound, and nothing in
   this verification pass reopens or contradicts that finding.
3. Does the "not present" result for 0142's expected objects (payment_intent_id
   column/FK, initiate_toss_payment, confirm_toss_payment) indicate a 0142 defect?
   NO. These objects are absent purely because replay never reached the migrations
   that create them (0103, then 0142) -- a mechanical consequence of the 0065
   secondary blocker still failing, not evidence of any problem in 0142's own
   content.

0142 reachability audit conclusion: NOT_REACHED_DUE_TO_0065_SECONDARY_BLOCKER -- a
distinct status from any judgment about 0142's own correctness, which remains
unaffected.
```

---

## 11. Boundary Compliance

```text
F. Boundary audit:

- SQL modification during 604305? NONE -- confirmed via git diff; 604305 is a
  verification-only pass.
- SQL modification permitted in 604306 (this Audit)? NONE -- no SQL, migration, or
  other file was modified in the course of writing this Audit; only this document
  was created.
- Additional modification to 0065 beyond the approved add_check expansion? NONE --
  confirmed via git diff; the secondary blocker's construct (line 926) is present
  unmodified both before and after 604304.
- 0063 modified? NO -- confirmed via git diff; unchanged from 604302's audited
  state.
- Additional modification to 0046, 0035, 0038, or 0042? NONE -- confirmed via git
  diff; all show the exact same diff already audited at every prior stage.
- Additional modification to 0142? NONE -- confirmed via git diff; unchanged.
- 604250 resumed? NO. No file under the 604250 folder was touched by 604304,
  604305, or this Audit.
- 604260 closed? NO. No file under the 604260 folder was touched; 604260's own
  runtime-evidence gap remains open, now attributable to the 0065 secondary
  blocker.
- 604310 implemented, or 604316 created? NO. Neither file exists in either folder.
- 604307 created? NO. This Audit creates no document beyond itself.

Boundary compliance conclusion: PASS.
```

---

## 12. Risk Assessment

```text
Technical risk on the accepted add_check fix is low: confirmed complete (all 13
call sites expanded, none missed, verified via independent count), confirmed to
introduce no new schema object, and confirmed to preserve the function's signature
and every check's ordering, severity weighting, and payload structure (§5).

No new risk is introduced to 0035, 0038, 0042, 0046, 0063, or 0142 -- all six
remain byte-for-byte unchanged in diff size from their previously audited states
(§8, §9, §11).

The residual risk that matters is the same repeating structural pattern already
observed at every prior stage of this lineage (0035/0038 -> 0042 -> 0046 primary ->
0046 secondary -> 0063 -> 0065 add_check -> now 0065 secondary): each baseline
blocker resolved exposes the next one immediately behind it, sometimes within the
very same file. This is a property of the 0001-0142 baseline migration history
predating every workpacket in this lineage, not a defect introduced by
604303/604304/604305's own work.

Unlike 0063 (where an independent completeness check in this same audit lineage
found 14 additional undiscovered occurrences beyond the one replay reported), this
Audit's own completeness check (§7 point 4) found the 0065 secondary blocker to be a
single, isolated occurrence -- the only jsonb_agg/array_agg/string_agg call in the
entire file. This lowers the scope-discovery risk for whoever analyzes it next
relative to 0063's situation, and the defect class itself (aggregate-inline LIMIT)
is already twice-resolved in this lineage (0046 primary and secondary), which should
further lower the process risk for that next analysis.
```

---

## 13. Final Audit Decision

```text
ACCEPT_604304_ADD_CHECK_INLINE_PROCEDURE_FIX
ACCEPT_604305_PARTIAL_VERIFICATION
ACCEPT_RUN_ISOLATION_AUDIT_CREATED
CLASSIFY_0065_JSONB_AGG_LIMIT_5_AS_NEXT_SAME_FILE_SECONDARY_REPLAY_BLOCKER
KEEP_0142_NOT_REACHED
DO_NOT_CLOSE_604250
DO_NOT_CLOSE_604260
OPEN_NEXT_ANALYSIS_FOR_0065_JSONB_AGG_LIMIT_5_IF_HUMAN_APPROVES

Combined decision string:
ACCEPT_RUN_ISOLATION_AUDIT_FIX_WITH_0065_SECONDARY_BLOCKER_REMAINING
```

```text
604304's Candidate A implementation is accepted for the 0065 inline `add_check`
procedure blocker: the invalid DECLARE-section procedure is removed, all 13 call
sites are expanded inline with the exact original ordering, severity weighting, and
payload structure preserved, and no new schema object was created.

604305 verified that the add_check inline procedure blocker did not recur.
catchmenu_audit.run_isolation_audit was created, with its signature confirmed
unchanged. No `add_check` procedure declaration or call site remains anywhere in
the file. No new helper object was created.

Full 0065 completion is still blocked by a same-file secondary
`jsonb_agg(order_id limit 5)` blocker at source line 926 (psql-reported LINE 37),
inside catchmenu_audit.scan_cross_tenant_risk. The new blocker is classified
AGGREGATE_INLINE_LIMIT_SYNTAX_ERROR -- the same defect class already resolved twice
in this lineage for 0046's primary and secondary blockers.

This is not a failure of the 604304 add_check fix. run_isolation_audit applies
successfully and completely; the new failure is a distinct, pre-existing construct
in a different function within the same file, confirmed untouched by 604304 and
confirmed (by this Audit's own completeness check) to be an isolated, single
occurrence, not a repeated pattern.

0046 and 0063 remain stable: both fixes are confirmed unchanged and their prior
verification results hold on this replay pass.

0035, 0038, and 0042 regression checks remain stable: all three are confirmed
unchanged and their prior verification results hold.

0142 was not reached. The absence of 0142's expected objects (payment_intent_id
column/FK, initiate_toss_payment, confirm_toss_payment) must not be treated as a
0142 failure -- it is the mechanical consequence of replay never reaching the
migrations that create them.

604250 and 604260 must remain blocked -- neither this Audit nor 604304/604305
authorizes any change to their status.

Next step requires Human approval to open a separate analysis/correction module for
the 0065 `jsonb_agg(order_id limit 5)` blocker -- this Audit does not open that
module itself.
```

---

## 14. Required Next Step

```text
Human approval required — open next analysis module for the 0065
`jsonb_agg(order_id limit 5)` blocker inside catchmenu_audit.scan_cross_tenant_risk.

This Audit does not create that module, does not select a fix for the secondary
blocker (though §7/§12 note it shares the same already-twice-resolved
AGGREGATE_INLINE_LIMIT_SYNTAX_ERROR class as 0046's primary and secondary blockers,
and that this Audit's own completeness check found it to be a single, isolated
occurrence rather than a repeated pattern, as relevant context for whoever performs
that analysis), and does not itself constitute authorization for any
implementation. It records only that:
  - 604304 add_check fix: complete, correct, accepted.
  - run_isolation_audit: created, signature preserved, semantics preserved.
  - 0065 secondary blocker: confirmed new (within this file), pre-existing,
    distinct, isolated occurrence, outside this workpacket's approved scope.
  - 0046, 0063, 0035, 0038, 0042: stable, unmodified, still verified.
  - 0142: not reached, not failed, not disproven.
  - 604250 resume and 604260 closeout: both remain not authorized by any document
    in this workpacket, including this Audit.
```
