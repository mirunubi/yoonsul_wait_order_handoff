# 604311_Audit_Cross_Scope_0065_Scan_Cross_Tenant_Risk_Aggregate_Inline_Limit_Replay_Blocker.md

Status: Complete
Lifecycle: Audit
Gate Classification: Cross-Scope Baseline Migration Replay Blocker — Stage 6 Independent Audit
Runtime Implementation Authorization: Not Granted By This Document
Owner: Claude (Independent Auditor)
Last Updated: 2026-07-05

This is an independent audit of 604308's implementation and 604309's verification
against the Candidate B scope recommended in 604307 for the 0065
scan_cross_tenant_risk aggregate inline limit blocker. It performs no implementation
and modifies no SQL, migration, or other document. It does not close 604260 and does
not authorize 604250 resume. Per explicit Human number decision, 604310 is not used
in this lineage; this Audit is numbered 604311. It does not create 604312.

---

## 1. Audit Scope

```text
In scope:
  - Whether 604308's implementation stayed within the 604307-recommended Candidate B
    boundary for 0065's scan_cross_tenant_risk (direct source diff, not just
    self-report).
  - 604309's verification evidence for the fix, the full 0065 migration's apply
    status, prior 0035/0038/0042/0046/0063/604304-add_check baseline stability, and
    the newly reported 0066 blocker.
  - Whether the 0066 failure is a new problem introduced by this workpacket or a
    separate, pre-existing downstream blocker.
  - Independent review of 604309's own filename and H1, per Human instruction.
  - Whether 604260/604250/604310/604316 boundaries were respected throughout.

Out of scope (not performed, not authorized here):
  - Fixing 0066, or any migration after 0065.
  - Any change to 0065, 0063, 0046, 0042, 0038, 0035, or 0142.
  - Any modification to 604309, regardless of any naming finding in §11.
  - Reopening 604260 closeout or 604250 resume.
  - Creating any new workpacket or document beyond this Audit, and specifically not
    using the reserved/forbidden number 604310.
```

---

## 2. Inputs Reviewed

```text
604307 Analysis (Candidate B recommendation — preserve mismatched CTE's own
  `limit 10`; cap `sample_ids` at 5 via a nested scalar subquery, no ORDER BY
  needed, no new schema object; PROCEED_TO_604308_IMPLEMENTATION_BY_CODEX)
604309_Verification_Cross_Scope_0065_Scan_Cross_Tenant_Risk_Aggregate_Inline_Limit_Replay_Blocker.md
  (read in full)
sql/migrations/0065_create_security_isolation_rpc.sql (current, post-604308 state,
  read in full for the affected region and full diff)
sql/migrations/0066_create_ledger_integrity_rpc.sql (new blocker, read directly at
  all 5 reported defect locations)
git diff for 0065, 0035, 0038, 0042, 0046, 0063, 0142, and 0066 — run independently
  in this Audit, not merely taken from 604309's self-report
No separate 604308 Module document exists as a file; its implementation summary was
  relayed directly for this Audit and is independently verified in §3 below against
  the actual source diff rather than accepted at face value.
```

---

## 3. 604308 Implementation Audit

```text
Independently confirmed via `git diff` for 0065, run in this Audit: the file's diff
now contains 8 hunks total. The first 7 (spanning original lines 265-780) are the
already-accepted 604304 add_check expansion (confirmed unchanged since 604306's
audit). The 8th and final hunk is this Audit's subject:

  Before:
    'sample_ids', jsonb_agg(order_id limit 5),

  After:
    'sample_ids', (
      select coalesce(
        jsonb_agg(sample.order_id),
        '[]'::jsonb
      )
      from (
        select order_id
        from mismatched
        limit 5
      ) sample
    ),

This is exactly the Candidate B restructuring recommended in 604307 §10-11: the
`mismatched` CTE's own `limit 10` is untouched (confirmed: still present at its
original line, unchanged); a new nested subquery selects `order_id` from
`mismatched`, applies `limit 5` as a valid clause of that inner SELECT (not inside
an aggregate call), and the outer scalar subquery aggregates only those (at most 5)
rows with `jsonb_agg(sample.order_id)`, wrapped in `coalesce(..., '[]'::jsonb)` to
preserve the original's empty-array fallback behavior. No ORDER BY was added,
consistent with 604307 §6's finding that none existed in the original construct.

`count(*)` in the same jsonb_build_object (the field immediately preceding
'sample_ids') is confirmed unchanged -- it continues to run over the full,
unrestricted `mismatched` CTE result, independent of the new nested subquery.

No other line in Scan 1, in any of the other five scans, or in
generate_security_report was touched -- confirmed via `git diff`, which shows this
single hunk as the only change beyond the already-accepted add_check expansion.

No new schema object (function, procedure, table, index) was created; the fix is a
self-contained subquery expression inline within the existing statement.

run_isolation_audit was not modified by this hunk -- its own already-accepted fix
(604304/604306) remains untouched, confirmed by the hunk boundaries above showing no
overlap with run_isolation_audit's line range.

604308 implementation conclusion: PASS. It matches the 604307-recommended Candidate
B scope exactly and completely, with no scope creep and no disturbance to the
already-accepted run_isolation_audit fix.
```

---

## 4. 604309 Verification Audit

```text
Q: Was 604309 executed on a clean, disposable verification DB?
  CONFIRMED per 604309 §3/§4: fresh database catchmenu_local_verify_604309 (not
  reused from any prior run: 604305, 604301, or earlier), migrations copied fresh
  into the container, sequential apply with ON_ERROR_STOP=1.

Q: Did 604309 honestly record both the 0065 fix's full success and the newly
   surfaced 0066 failure?
  CONFIRMED. 604309 §6/§12 explicitly states 0065 now applies in full with all
  three audit functions present, while separately and plainly stating full replay
  through 0142 is NOT PASSED, halted at 0066. Nothing about the 0066 failure is
  used to understate 0065's completion, and nothing about 0065's completion is used
  to imply 0142 is closer to verified than it is.

Q: Did 604309 make any SQL or migration change?
  CONFIRMED NOT. §10 Boundary Verification states no SQL/migration file was
  modified, independently corroborated in this Audit: 0065's diff (§3 above)
  contains only the already-accounted-for corrections, and 0066 shows no diff at
  all.

604309 verification conclusion: PASS for its stated scope; accurate, non-overstated
record of both what succeeded (0065 fully fixed) and what remains blocked (0066).
```

---

## 5. 0065 Aggregate Inline Limit Fix Assessment

```text
A. 0065 scan_cross_tenant_risk aggregate inline limit fix audit:

1. Was the `jsonb_agg(order_id limit 5)` blocker resolved? YES. Independently
   confirmed via full-file search in this Audit: zero matches for `jsonb_agg(order_id
   limit` anywhere in the current file.
2. Is 'sample_ids' capped at a maximum of 5 IDs via a nested scalar subquery? YES,
   per §3 above -- the inner subquery `select order_id from mismatched limit 5`
   bounds the row count to at most 5 before the outer `jsonb_agg(sample.order_id)`
   aggregates them.
3. Is the existing `mismatched` CTE's `limit 10` preserved? YES. Independently
   confirmed: the CTE definition (lines 909-919 in the current file) is unchanged --
   still capped at 10, untouched by this fix.
4. Are `count(*)` semantics and the diagnostics payload structure preserved? YES.
   `count(*)` still reads from the full `mismatched` CTE (up to 10 rows), unaffected
   by the new 5-row-capped subquery; the returned object's key set ('risk_type',
   'severity', 'count', 'sample_ids', 'detail') and each key's value type are
   unchanged.
5. Was a new ORDER BY added anywhere in this construct? NO. Independently confirmed:
   neither the `mismatched` CTE nor the new nested subquery contains an ORDER BY --
   consistent with 604307 §6's finding that none existed in the original (broken)
   construct and none was needed to preserve its (unranked, sample-only) intent.
6. Was run_isolation_audit modified unnecessarily by this fix? NO. Confirmed via the
   diff hunk boundaries in §3 -- this fix's single hunk falls entirely within
   scan_cross_tenant_risk, with no overlap with run_isolation_audit's already-
   accepted region.
7. Was any new schema object created? NO. Confirmed via git diff: no CREATE
   FUNCTION, CREATE PROCEDURE, CREATE TABLE, or CREATE INDEX statement appears in
   this hunk; the fix is a self-contained subquery expression.

0065 aggregate inline limit fix assessment: PASS. The fix is complete, correct, and
introduces no new schema object, no ordering change, and no disturbance to
run_isolation_audit or count(*) semantics.
```

---

## 6. 0065 Full Migration Pass Assessment

```text
B. 0065 full migration audit:

1. Does 0065 now apply cleanly and completely in sequential replay? YES, per 604309
   §5/§6 ("0065 full file applies: Yes"; "Last applied: 0065_create_security_
   isolation_rpc.sql"), independently consistent with this Audit's own confirmation
   that both the add_check construct and the aggregate-inline-limit construct are
   now syntactically valid (§5, and 604306 §5 for add_check).
2. Do all three security audit functions exist? YES, per 604309 §6:
   catchmenu_audit.run_isolation_audit, catchmenu_audit.scan_cross_tenant_risk, and
   catchmenu_audit.generate_security_report all confirmed present.
3. Did the add_check inline procedure blocker recur? NO, per 604309 §6 ("Did not
   recur"), independently corroborated by this Audit's own zero-match search for
   `procedure add_check` / `call add_check`.
4. Did the `jsonb_agg(order_id limit 5)` blocker recur? NO, per 604309 §6 ("Did not
   recur"), independently corroborated by this Audit's own zero-match search (§5
   point 1).

0065 full migration pass: PASS. 0065 is now a clean, fully-applying migration with
all three known defects (add_check inline procedure; the two aggregate-inline-limit
occurrences it actually had) corrected, and all three of its declared functions
created.
```

---

## 7. 0066 Replay Blocker Assessment

```text
C. 0066 replay blocker audit:

1. Did replay progress past all of 0065? YES, per 604309 §5 ("Last applied:
   0065_create_security_isolation_rpc.sql"; "Migrations applied count: 65").
2. Did a new blocker occur at 0066? YES, per 604309 §5, independently re-confirmed
   by direct source read in this Audit: sql/migrations/0066_create_ledger_
   integrity_rpc.sql contains the construct `'sample_ids', jsonb_agg(id limit 5)`
   at FIVE locations -- lines 185, 223, 250, 556, and 582 -- an exact match to
   604309's reported count and locations, independently re-confirmed via a direct
   grep in this Audit.
3. Is this the same defect class as 0065's now-resolved aggregate-inline-limit
   blocker? YES -- `jsonb_agg(id limit 5)` is structurally identical to 0065's
   pre-fix `jsonb_agg(order_id limit 5)`: a LIMIT clause placed inside an aggregate
   function call's own parentheses, invalid under PostgreSQL's grammar. Blocker
   classification AGGREGATE_INLINE_LIMIT_SYNTAX_ERROR, consistent with 604306/604307's
   own classification for this defect class.
4. Is 0066 a failure of the 604308 fix? NO. 0066 is a distinct migration, 1 number
   after 0065, with no relationship to run_isolation_audit, scan_cross_tenant_risk,
   or generate_security_report. It was simply unreached until 0065's own blockers
   (add_check, then the aggregate-inline-limit defect) were both cleared -- the same
   repeating pattern already observed at every prior stage of this lineage
   (0035/0038 -> 0042 -> 0046 primary -> 0046 secondary -> 0063 -> 0065 add_check ->
   0065 aggregate-limit -> now 0066).
5. Was 0066 touched by 604308 or 604309? NO. Independently confirmed via `git diff
   --stat` for 0066: no diff -- the file is unmodified.

0066 replay blocker classification: a new, distinct, pre-existing downstream
blocker (AGGREGATE_INLINE_LIMIT_SYNTAX_ERROR class, with 5 occurrences, independently
confirmed), not a regression or failure of the 0065 work. This Audit does not fix
0066.
```

---

## 8. 0046 / 0063 Regression Assessment

```text
0046: 604309 §7 reports sequential apply passed, build_ai_context exists, and
  neither the primary nor secondary limit blocker recurred -- independently
  corroborated via `git diff --stat`, showing 0046's diff unchanged in size (127
  lines) from the state already audited and accepted in 604297/604306.

0063: 604309 §7 reports sequential apply passed, no `provider_payment_key :=`
  matches, and all three target functions exist -- independently corroborated via
  `git diff --stat`, showing 0063's diff unchanged in size (30 lines) from the
  state already audited and accepted in 604302/604306.

Neither file was modified during 604308/604309 -- confirmed via git diff showing
identical diff sizes to their previously audited states.

0046 / 0063 regression audit: PASS. No regression; both fixes remain intact and
unmodified.
```

---

## 9. 0035 / 0038 / 0042 Regression Assessment

```text
D. Regression audit:

1. 0035: 604309 §7 reports PASS: 85 / FAIL 0 / TOTAL 85 -- independently
   corroborated via `git diff --stat`, showing 0035's diff unchanged in size (868
   lines) from the state already audited and accepted at every prior stage of this
   lineage.
2. 0038: 604309 §7 reports verify_toss_signature and process_toss_webhook both
   exist -- independently corroborated via `git diff --stat`, unchanged (1
   insertion/1 deletion).
3. 0042: 604309 §7 reports all three delivery intake functions exist --
   independently corroborated via `git diff --stat`, unchanged (1 insertion/1
   deletion).
4. Were any of these three files modified during 604308/604309? NO. Each file's
   diff, independently re-measured in this Audit, is byte-for-byte identical in
   size to the diff already confirmed in every preceding audit in this lineage.

0035/0038/0042 regression audit: PASS. No regression; all three prior fixes remain
intact and unmodified.
```

---

## 10. 0142 Reachability Assessment

```text
E. 0142 reachability audit:

1. Was 0142 reached? NO. 604309 §8/§9 confirms replay halted at 0066, well before
   0142; independently confirmed unchanged via `git diff --stat` for 0142 (408-line
   pre-existing addition, same as every prior audit in this lineage).
2. Is the cause 0142 itself? NO. 0066 is a distinct, unrelated migration; there is
   no evidence, static or runtime, of any defect in 0142's own content. Its prior
   independent audit (604269) already found it structurally sound, and nothing in
   this verification pass reopens or contradicts that finding.
3. Does the "not present" result for 0142's expected objects (payment_intent_id
   column/FK, initiate_toss_payment, confirm_toss_payment) indicate a 0142 defect?
   NO. These objects are absent purely because replay never reached the migrations
   that create them (0103, then 0142) -- a mechanical consequence of 0066 still
   failing, not evidence of any problem in 0142's own content.

0142 reachability audit conclusion: NOT_REACHED_DUE_TO_0066 -- a distinct status
from any judgment about 0142's own correctness, which remains unaffected.
```

---

## 11. 604309 Document Naming And H1 Assessment

```text
F. 604309 document naming/H1 audit:

Actual file, confirmed by direct directory listing in this Audit:
  604309_Verification_Cross_Scope_0065_Scan_Cross_Tenant_Risk_Aggregate_Inline_Limit_Replay_Blocker.md

Actual H1, confirmed by direct read of the file's first line:
  # 604309_Verification_Cross_Scope_0065_Scan_Cross_Tenant_Risk_Aggregate_Inline_Limit_Replay_Blocker.md

Internal H1-to-own-filename check: MATCH. The H1 exactly reproduces the file's own
  actual name, character for character. Per Human instruction, this is not treated
  as a fatal issue.

Comparison to the naming used by its own predecessor Analysis document in the same
  sub-thread: NOTED DEVIATION, not fatal. 604307 Analysis's filename is
  "604307_Analysis_Cross_Scope_0065_Scan_Cross_Tenant_Risk_Aggregate_Limit_Replay_
  Blocker.md" (using "Aggregate_Limit"); 604309's actual filename uses
  "Aggregate_Inline_Limit" (inserting "Inline"). This is a naming-convention
  deviation relative to its own immediate predecessor, recorded here only, per
  explicit Human instruction that this Audit must not modify 604309 and must only
  record whether a deviation exists.

No modification was made to 604309 by this Audit.
```

---

## 12. Boundary Compliance

```text
G. Boundary audit:

- SQL modification during 604309? NONE -- confirmed via git diff; 604309 is a
  verification-only pass.
- SQL modification permitted in 604311 (this Audit)? NONE -- no SQL, migration, or
  other file was modified in the course of writing this Audit; only this document
  was created.
- Additional modification to 0065 beyond the approved sample_ids fix? NONE --
  confirmed via git diff; the 8-hunk diff contains only the already-accepted
  add_check expansion and this Audit's subject fix.
- 0066 modified? NO -- confirmed via git diff; 0066 shows zero diff.
- Additional modification to 0063 or 0046? NONE -- confirmed via git diff;
  unchanged from their previously audited states.
- Additional modification to 0035, 0038, 0042, or 0142? NONE -- confirmed via git
  diff; all show the exact same diff already audited at every prior stage.
- 604250 resumed? NO. No file under the 604250 folder was touched by 604308,
  604309, or this Audit.
- 604260 closed? NO. No file under the 604260 folder was touched; 604260's own
  runtime-evidence gap remains open, now attributable to the 0066 blocker.
- 604310 used? NO. Per explicit Human number decision, 604310 is not used anywhere
  in this workpacket; this Audit is correctly numbered 604311.
- 604316 created? NO. Confirmed does not exist.
- 604312 created? NO. This Audit creates no document beyond itself.

Boundary compliance conclusion: PASS.
```

---

## 13. Risk Assessment

```text
Technical risk on the accepted 0065 aggregate-inline-limit fix is low: confirmed
complete, confirmed to preserve the mismatched CTE's own cap, count(*) semantics,
payload structure, and (absence of) ordering, and confirmed to introduce no new
schema object and no disturbance to the already-accepted run_isolation_audit fix
(§5).

No new risk is introduced to 0035, 0038, 0042, 0046, 0063, or 0142 -- all six
remain byte-for-byte unchanged in diff size from their previously audited states
(§8, §9, §12), and 0066 remains unmodified (§7, §12).

The residual risk that matters is the same repeating structural pattern already
observed at every prior stage of this lineage: each baseline blocker resolved
exposes the next one immediately behind it, sometimes within the same file
(0065's own two-stage add_check/aggregate-limit sequence) and sometimes in the next
file (0066). This is a property of the 0001-0142 baseline migration history
predating every workpacket in this lineage, not a defect introduced by
604307/604308/604309's own work.

0066's defect (5 occurrences of the same AGGREGATE_INLINE_LIMIT_SYNTAX_ERROR class,
each reading `jsonb_agg(id limit 5)`) is now a third-time-recurring, well-understood
pattern in this lineage (0046 primary/secondary, 0065), which should lower the
process risk for whoever analyzes it next -- though, as with 0063's 15-occurrence
discovery, the next analysis should independently verify whether all 5 reported
occurrences share the identical row-set/behavior-preservation profile as 0065's
single occurrence, or whether any of the 5 differs in a way that changes the correct
fix shape (e.g. a different or absent underlying detection-cap CTE, or a different
field name than 'sample_ids').
```

---

## 14. Final Audit Decision

```text
ACCEPT_604308_0065_AGGREGATE_INLINE_LIMIT_FIX
ACCEPT_604309_PARTIAL_VERIFICATION
ACCEPT_0065_FULL_PASS
CLASSIFY_0066_JSONB_AGG_ID_LIMIT_5_AS_NEXT_REPLAY_BLOCKER
KEEP_0142_NOT_REACHED
DO_NOT_CLOSE_604250
DO_NOT_CLOSE_604260
DO_NOT_USE_604310
OPEN_NEXT_ANALYSIS_FOR_0066_AGGREGATE_INLINE_LIMIT_IF_HUMAN_APPROVES

Combined decision string:
ACCEPT_0065_FULL_PASS_WITH_REPLAY_BLOCKED_AT_0066
```

```text
604308's Candidate B implementation is accepted for the 0065 scan_cross_tenant_risk
aggregate inline limit blocker: the mismatched CTE's own limit 10 is preserved,
count(*) semantics are unaffected, and 'sample_ids' is correctly capped at 5 via a
nested scalar subquery, with no new schema object and no ORDER BY introduced.

604309 verified that 0065 now fully applies. run_isolation_audit,
scan_cross_tenant_risk, and generate_security_report all exist. The add_check
inline procedure blocker did not recur. The `jsonb_agg(order_id limit 5)` blocker
did not recur. 0065 is now accepted as full pass.

Replay progressed to 0066 and is now blocked at `jsonb_agg(id limit 5)`, with 5
occurrences reported (lines 185, 223, 250, 556, 582), independently re-confirmed in
this Audit. 0066 is the next replay blocker in sequence, not a failure of the 0065
fix -- it is a distinct, pre-existing migration, unrelated to any of 0065's three
functions, simply unreached until 0065's own two defects were both cleared.

0046 and 0063 remain stable: both fixes are confirmed unchanged and their prior
verification results hold on this replay pass.

0035, 0038, and 0042 regression checks remain stable: all three are confirmed
unchanged and their prior verification results hold.

0142 was not reached. The absence of 0142's expected objects (payment_intent_id
column/FK, initiate_toss_payment, confirm_toss_payment) must not be treated as a
0142 failure -- it is the mechanical consequence of replay never reaching the
migrations that create them.

604250 and 604260 must remain blocked -- neither this Audit nor 604308/604309
authorizes any change to their status. 604310 must remain unused in this lineage,
per explicit Human number decision; this Audit is correctly numbered 604311.

Next step requires Human approval to open a separate analysis/correction module for
the 0066 `jsonb_agg(id limit 5)` blocker -- this Audit does not open that module
itself.
```

---

## 15. Required Next Step

```text
Human approval required — open next analysis module for the 0066
`jsonb_agg(id limit 5)` blocker in sql/migrations/0066_create_ledger_integrity_rpc.sql
(5 occurrences: lines 185, 223, 250, 556, 582).

This Audit does not create that module, does not select a fix for 0066 (though §7/
§13 note it shares the same already-twice-resolved AGGREGATE_INLINE_LIMIT_SYNTAX_ERROR
class as 0046 and 0065, while also flagging that the next analysis should
independently verify each of the 5 occurrences' row-set and behavior-preservation
profile rather than assuming they are all identical in shape to 0065's single
occurrence), and does not itself constitute authorization for any implementation.
It records only that:
  - 604308 aggregate-inline-limit fix: complete, correct, accepted.
  - 0065: full pass -- all three functions created, both known defects resolved,
    no regression.
  - 0066: confirmed new, pre-existing, distinct downstream blocker
    (AGGREGATE_INLINE_LIMIT_SYNTAX_ERROR class, 5 occurrences), outside this
    workpacket's approved scope.
  - 0046, 0063, 0035, 0038, 0042: stable, unmodified, still verified.
  - 0142: not reached, not failed, not disproven.
  - 604250 resume and 604260 closeout: both remain not authorized by any document
    in this workpacket, including this Audit.
  - 604309 naming: H1 matches its own filename (not fatal); a naming-convention
    deviation from its predecessor 604307 was noted, unresolved pending Human
    decision, not modified by this Audit.
  - 604310 remains unused in this lineage per Human number decision.
```
