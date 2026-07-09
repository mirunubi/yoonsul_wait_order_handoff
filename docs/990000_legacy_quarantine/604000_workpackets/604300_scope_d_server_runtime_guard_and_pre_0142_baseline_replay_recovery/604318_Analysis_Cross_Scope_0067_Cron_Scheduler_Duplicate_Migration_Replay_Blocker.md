# 604318_Analysis_Cross_Scope_0067_Cron_Scheduler_Duplicate_Migration_Replay_Blocker.md

Status: Complete
Lifecycle: Analysis
Gate Classification: Cross-Scope Baseline Migration Replay Blocker — Stage 1 Analysis
Runtime Implementation Authorization: Not Granted
Owner: TBD
Last Updated: 2026-07-05

This is an analysis document only. It performs no implementation and modifies no
SQL, migration, or other file. It does not close 604260 and does not authorize
604250 resume. Per explicit Human number decision, 604310 and 604316 remain
unused/forbidden. It does not create 604319 — that, if pursued, is a separate future
document. The first 604317 Audit is treated as canonical; this Analysis does not
create a second 604317.

---

## 1. Analysis Scope

```text
In scope:
  - Direct review of sql/migrations/0067_create_cron_scheduler_rpc.sql: its actual
    declared objects, header comment, and whether any cron/scheduler logic exists
    anywhere in it.
  - A direct, independent comparison between the current (post-604314-fixed)
    0066_create_ledger_integrity_rpc.sql and 0067, to confirm or refute the
    duplication finding already flagged in 604317 Audit §8.
  - Classification of the true nature of the 0067 problem: a simple repeat of the
    AGGREGATE_INLINE_LIMIT_SYNTAX_ERROR class, or a deeper migration-content/
    filename/purpose mismatch.
  - Impact analysis of what a naive syntax-only fix would and would not accomplish.
  - Presentation of candidate remediation paths (analysis only, no implementation).
  - A recommendation on whether this should proceed straight to a syntax-only
    implementation, or must first go through an Approval Gate (or remain held) given
    the duplication finding.

Out of scope (not performed, not authorized here):
  - Any edit to 0067 or any other migration.
  - Any change to 0066, 0065, 0063, 0046, 0042, 0038, 0035, or 0142.
  - Creating 604319 or any other successor document.
  - Reopening 604260 closeout or 604250 resume.
  - Using 604310 or 604316, both of which remain unused/forbidden per Human number
    decision.
```

---

## 2. Inputs Reviewed

```text
sql/migrations/0067_create_cron_scheduler_rpc.sql (full file, read in full)
sql/migrations/0066_create_ledger_integrity_rpc.sql (current, post-604314-fixed
  state, read in full for comparison)
604317_Audit_Cross_Scope_0066_Ledger_Integrity_Aggregate_Inline_Limit_Replay_Blocker.md
  (the first/canonical instance — §8's duplication finding is the direct trigger
  for this Analysis)
604315_Verification_Cross_Scope_0066_Ledger_Integrity_Aggregate_Inline_Limit_Replay_Blocker.md
  (§5 verbatim 0067 replay failure record, 7 reported occurrence lines)
git diff --stat for sql/migrations/0067_create_cron_scheduler_rpc.sql (independently
  re-run in this Analysis — confirmed empty, i.e. 0067 is unmodified)
git diff (full) between current-fixed 0066 and 0067 (independently re-run in this
  Analysis — confirmed the two files differ ONLY at the 15 locations 604314 already
  corrected in 0066)
Repo-wide search in 0067 for pg_cron / cron.schedule / create extension / job_id /
  schedule( -- confirmed zero matches
```

---

## 3. 604317 Audit Reference

```text
This Analysis is triggered directly by 604317 Audit (the first, canonical instance)
§8 "0067 Replay Blocker Assessment," which independently found -- beyond the 7
occurrence lines 604315 had already reported -- that 0067's own content is a
near-total byte-level duplicate of 0066's pre-604314-fix state, under a filename and
declared purpose ("cron scheduler") that has no relationship to that content. 604317
§15/§16 explicitly recommended that the next analysis module investigate this
duplication finding before assuming a straightforward Candidate B reapplication is
the correct next step. This Analysis is that next module, and independently
re-verifies (rather than merely restates) 604317's finding.
```

---

## 4. 0067 Migration Identification

```text
Filename: sql/migrations/0067_create_cron_scheduler_rpc.sql
Total length: 1345 lines (0066's current fixed file is 1346 lines -- the 1-line
  difference is accounted for entirely by 0066's 15 fixes each adding a small,
  varying number of lines relative to 0067's unfixed originals; confirmed via the
  diff in §6).
Header comment (verbatim, lines 1-15):
  -- 0066_create_ledger_integrity_rpc.sql
  -- Purpose: Event ledger integrity validation and replay verification.
  --          verify_event_ledger_integrity: checks event chain consistency.
  --          verify_audit_chain: validates audit record immutability.
  --          run_state_projection_check: verifies current state matches
  --            event log projection.
  --          reconcile_ledger_gaps: detects and reports missing events.
  --          특허4 core: 4원장 무결성 검증 + Event Replay 일관성 확인.
  -- Depends on: 0065_create_security_isolation_rpc.sql
  -- Creates:
  --   catchmenu_ledger.integrity_check_results (table)
  --   function catchmenu_ledger.verify_event_ledger_integrity(...)
  --   function catchmenu_ledger.verify_audit_chain(...)
  --   function catchmenu_ledger.run_state_projection_check(...)
  --   function catchmenu_ledger.reconcile_ledger_gaps(...)
Objects actually declared in the file body (confirmed by direct read of every
  CREATE statement): the exact same table and four functions listed in the header
  above -- NOT a cron scheduler table, extension, or job-scheduling RPC of any kind.
```

---

## 5. Filename / Header / Purpose Assessment

```text
- Filename: 0067_create_cron_scheduler_rpc.sql -- names imply a cron/job-scheduling
  migration.
- Header comment: literally reads "0066_create_ledger_integrity_rpc.sql" and
  describes ledger integrity validation -- does NOT match the file's own filename
  or imply anything cron/scheduler-related.
- Does the header match the filename? NO -- confirmed a direct mismatch.
- Is there any cron/scheduler object, extension, or logic anywhere in the file?
  NO -- an independent search in this Analysis for pg_cron, cron.schedule, create
  extension, job_id, and schedule( found zero matches anywhere in the 1345-line
  file. The only occurrence of the word "cron" anywhere in the file is inside an
  incidental Korean comment string ("Daily cron 권장: run after business close.")
  carried over verbatim from 0066's own function-comment text -- descriptive prose
  about when a human/ops process might schedule a manual run of the (ledger
  integrity) RPCs, not actual scheduling code.
- Does the file instead contain ledger-integrity content? YES -- table
  catchmenu_ledger.integrity_check_results and all four ledger integrity functions
  (verify_event_ledger_integrity, verify_audit_chain, run_state_projection_check,
  reconcile_ledger_gaps) are present, with the same signatures as 0066's own.

Conclusion: 0067's filename/declared purpose (cron scheduler) is entirely
disconnected from its actual content (ledger integrity, duplicating 0066). No cron
scheduler capability exists anywhere in this file.
```

---

## 6. 0066 vs 0067 Content Comparison

```text
A full, line-by-line diff between the CURRENT (post-604314-fixed)
sql/migrations/0066_create_ledger_integrity_rpc.sql and
sql/migrations/0067_create_cron_scheduler_rpc.sql, independently run in this
Analysis, shows the two files differ at EXACTLY 15 locations -- and at no others.
Every one of those 15 locations corresponds precisely to one of the 15 aggregate-
inline-limit occurrences 604313/604314 already catalogued and corrected in 0066
(604312 §5's inventory). At each location, 0066's side of the diff shows the
Candidate B nested-subquery correction; 0067's side shows the original, invalid
`jsonb_agg(<arg> limit 5)` construct -- i.e., 0067 is exactly what 0066 looked like
BEFORE 604314's fix was applied.

Every other line in both 1345/1346-line files -- every table column, constraint,
index, RLS policy, function signature, WHERE/JOIN condition, CTE structure, comment,
and grant statement -- is identical between the two files.

This is not a case of two independently-authored files that happen to share a
common bug pattern. It is a near-total content duplication: 0067 is, for all
practical purposes, a saved copy of 0066's pre-fix state, filed under an unrelated
number and an unrelated declared purpose.
```

---

## 7. Object Duplication Assessment

```text
If 0067 were applied as-is (once its syntax parses), it would execute:
  - `create table if not exists catchmenu_ledger.integrity_check_results (...)` --
    a no-op, since this table already exists (created by 0066); IF NOT EXISTS
    prevents an error, but also means 0067 contributes nothing new here.
  - `create or replace function catchmenu_ledger.verify_event_ledger_integrity(...)`,
    `verify_audit_chain(...)`, `run_state_projection_check(...)`, and
    `reconcile_ledger_gaps(...)` -- each of these would REDEFINE (via CREATE OR
    REPLACE) the exact same functions 0066 already created, with the exact same
    signatures. If 0067's own copy of these bodies were left uncorrected, applying
    0067 would silently roll back 0066's own fix -- 0066's already-corrected
    functions would be overwritten by 0067's still-broken (or, if separately
    "fixed" without care, possibly divergent) versions.
  - The RLS policy `drop policy if exists ... create policy ...` would similarly be
    re-applied, harmlessly but redundantly.
  - No cron scheduler object of any kind would be created, regardless of whether
    0067's syntax is repaired.

This is the central risk this Analysis flags: 0067 is not merely "the next file
with the same bug" -- it is a migration that, once made syntactically valid by any
means, would functionally re-execute (or, worse, silently regress) work 0066 has
already completed and had independently audited, while never delivering the cron
scheduler capability its filename promises.
```

---

## 8. Replay Failure Assessment

```text
604315 Verification reported the replay failure at 0067 as `syntax error at or near
"limit"`, specifically `jsonb_agg(id limit 5)` at psql-reported LINE 84 (source line
185 in this file's own numbering) -- independently re-confirmed in this Analysis at
that exact location, matching one of the 15 duplicated defect sites identified in
§6. This part of 604315's report is accurate as far as it goes: the immediate parse
failure is indeed the same AGGREGATE_INLINE_LIMIT_SYNTAX_ERROR class already twice
resolved in this lineage (0046, 0065, 0066).

However, this Analysis's own finding (§5-§7) establishes that the SYNTAX failure is
not the primary problem to solve here -- it is a symptom of the deeper issue that
0067's entire content is misplaced. Treating this purely as "another instance of
the aggregate-inline-limit bug" and reapplying Candidate B mechanically (as was
correctly done for 0046, 0065, and 0066) would fix the parse error while leaving
the duplication/misfiled-content problem completely unaddressed.
```

---

## 9. Root Cause Classification

```text
DUPLICATE_MIGRATION_CONTENT_MISMATCH
```

```text
Reasoning: 0067's content is a near-total duplicate of 0066's pre-fix state (§6),
its header comment names a different file (0066) than its own filename implies
(§5), and its declared purpose (cron scheduler) has zero corresponding content
anywhere in the file (§5, §7). This is broader and more consequential than a pure
AGGREGATE_INLINE_LIMIT_SYNTAX_ONLY classification, which would understate the
problem to "one more syntax bug" and risk a fix that reintroduces or redefines
duplicate ledger-integrity objects while never producing the intended cron
scheduler capability. It is not merely a MISNUMBERED_COPY_OF_0066 in the narrowest
sense either (though that is mechanically consistent with what likely happened) --
the broader classification captures both the content duplication and the filename/
purpose mismatch together, which is what makes this defect qualitatively different
from every prior AGGREGATE_INLINE_LIMIT_SYNTAX_ERROR blocker in this lineage. It is
not UNKNOWN_REQUIRES_HUMAN_REVIEW for DIAGNOSIS purposes -- the diagnosis itself
(what 0067 actually contains, and how it differs from 0066) is unambiguous and fully
established by direct, independent comparison in this Analysis; what does require
Human review is the REMEDIATION choice (§11-§12), not the diagnosis.
```

---

## 10. Risk Assessment

```text
1. Would a naive syntax-only fix (applying the same Candidate B pattern used for
   0066 to 0067's 15 identical occurrences) let replay pass 0067? YES, mechanically
   -- the same nested-subquery restructuring would resolve the parse error the same
   way it did for 0046/0065/0066.
2. Would that alone re-apply duplicate ledger functions? YES -- 0067's `create or
   replace function` statements would still execute, redefining the same four
   functions 0066 already created and had independently audited as correct
   (604317). If the fix is applied carefully (matching 0066's exact corrected
   bodies), the net runtime effect would be harmless (the functions would end up
   with the same, already-correct logic) -- but the migration history would then
   contain two separate files claiming to "create" the same objects, which is
   itself a problem (see point 6).
3. Would cron scheduler functionality still be missing? YES -- nothing in a
   syntax-only fix introduces any actual scheduling capability. The gap implied by
   0067's filename would remain entirely unaddressed.
4. Is 0067 needed at all, given 0066 is already full pass? Not in its current
   form -- 0067 currently contributes zero new capability; it is purely redundant
   with 0066 once (if) it parses.
5. Could 0067, once parseable, overwrite 0066's objects with something worse than
   redundant? YES, conditionally -- if a future correction to 0067 diverges even
   slightly from 0066's own corrected bodies (e.g. a different fix applied
   independently, or a partial/incomplete fix), CREATE OR REPLACE would silently
   swap in the different version, and whichever migration runs LAST (0067, since it
   is numbered after 0066) would win. This is a genuine risk if 0067 is "fixed" in
   isolation without cross-checking against 0066's already-audited, already-correct
   bodies.
6. What does leaving this duplication unresolved cost for future debugging/audit/
   migration history? A significant, ongoing traceability cost -- consistent with
   this lineage's own Documentation Traceability Requirement (604313 §14): a future
   investigator reading "0067_create_cron_scheduler_rpc.sql" would reasonably
   expect cron-scheduling content and find none; anyone diffing or auditing the
   ledger-integrity functions would need to know to check BOTH 0066 and 0067 to
   understand which one is authoritative; and the actual, presumably-intended cron
   scheduler capability (whatever it was meant to be) remains unbuilt and
   undocumented as a gap, hidden behind what looks like a completed migration
   number.
```

---

## 11. Candidate Remediation Paths

```text
- Candidate A: Apply the same Candidate B aggregate-inline-limit fix to 0067's 15
  duplicate occurrences (mirroring 0066's own already-approved correction).
  - Pro: resolves the immediate replay syntax blocker; well-precedented mechanical
    pattern.
  - Con: leaves the duplicate-migration / wrong-purpose-file problem completely
    unresolved; cron scheduler capability remains missing; migration history still
    contains two files claiming to create the same objects; carries the divergence
    risk described in §10 point 5 if not cross-checked meticulously against 0066.
  - NOT RECOMMENDED as a sole remedy -- resolves only the syntax symptom, not the
    root cause this Analysis identifies.

- Candidate B: Replace 0067's content with the actual, intended cron scheduler
  migration content -- but ONLY if a correct source for that content can be
  identified (e.g. an archived draft, a design document describing the intended
  cron scheduler RPCs, or an equivalent record elsewhere in this repository).
  - Pro: resolves the filename/purpose mismatch at its root; delivers the actually-
    intended capability.
  - Con: this is a content replacement, not a syntax fix -- a materially larger
    scope change requiring its own ChangeContract/Approval process; no such source
    content has been located or confirmed in this Analysis; requires Human to first
    confirm whether intended cron-scheduler content exists anywhere, or whether it
    was never written.
  - Requires Human review before any further scoping.

- Candidate C: Convert 0067 into an explicit no-op / duplicate-guard migration --
  e.g., replacing its body with a comment-only marker noting that its originally
  intended content was never authored (or was accidentally duplicated from 0066)
  and that this migration number is intentionally a no-op, preserving append-only
  migration numbering discipline without re-executing any duplicate object
  definitions.
  - Pro: removes the divergence/overwrite risk described in §10 point 5; keeps
    migration numbering sequential and explainable.
  - Con: does not deliver cron scheduler capability (that would need its own,
    later migration if still required); depends on this lineage's own append-only/
    no-op migration policy allowing such a marker, which this Analysis has not
    independently confirmed.
  - Requires Human review before any further scoping.

- Candidate D: Leave 0067 unmodified in this workpacket's own lineage, and open a
  separate, distinctly-scoped workpacket specifically for the "duplicate migration
  content" incident -- decoupling the routine replay-blocker cleanup pattern this
  workpacket has followed (0046, 0065, 0066) from what is, at its core, a
  migration-authoring/content-integrity incident rather than a syntax defect.
  - Pro: keeps this workpacket's own scope (aggregate-inline-limit replay
    blockers) clean and avoids conflating two different problem categories;
    mirrors this lineage's own precedent of opening 604270/604280/604290 as
    successive, narrowly-scoped workpackets rather than expanding one workpacket's
    scope indefinitely.
  - Con: 0142 replay remains blocked for as long as this separate workpacket takes
    to resolve, regardless of which Candidate it eventually selects.
  - Requires Human review before any further scoping.
```

---

## 12. Recommended Path

```text
PROCEED_TO_604319_APPROVAL_GATE_FOR_0067_CONTENT_DECISION
```

```text
Because 0067 is confirmed (§5-§9), not merely suspected, to be a duplicate-content/
wrong-purpose migration rather than a simple syntax bug, this Analysis does not
recommend proceeding directly to a syntax-only implementation (Candidate A) --
doing so would fix the parse error while leaving the more consequential problem
(duplicate object redefinition risk, missing cron scheduler capability, migration-
history confusion) unaddressed, exactly the outcome §10/§11 caution against.

Consistent with this lineage's own established precedent (604312 Analysis
similarly declined to recommend direct implementation when it discovered a scope
that exceeded what any prior document had approved, and Human then reviewed and
approved a specific path via 604313 Approval Gate before 604314 Implementation
proceeded), this Analysis recommends the next document be an Approval Gate --
not a bare "hold" with no forward motion, and not a syntax-only implementation --
that lays out Candidates B, C, and D (§11) for Human to select among, since the
correct remediation depends on a factual question this Analysis cannot resolve on
its own (whether an intended cron-scheduler content source exists) and a policy
question this Analysis is not positioned to decide alone (whether a no-op
migration marker or a separate workpacket is preferred). Candidate A is explicitly
NOT proposed as an option within that Approval Gate as a standalone remedy, per
§11's rejection rationale.

0066 remains full pass per 604317 Audit (the canonical instance), unaffected by
this Analysis. 0142 remains not reached; 0142 object absence continues to be the
mechanical consequence of upstream replay blockers, not a 0142 failure. 604250 and
604260 remain blocked and are unaffected by this Analysis. 604310 and 604316
remain unused/forbidden per Human number decision.
```

---

## 13. Forbidden Scope

```text
This Analysis does not, and no future document produced from it may without
separate authorization:
  - Modify 0067 or any other SQL/migration file.
  - Modify 0066, 0065, 0063, 0046, 0042, 0038, 0035, or 0142.
  - Resume 604250 implementation.
  - Close 604260.
  - Implement 604310 (remains unused) or create 604316 (remains forbidden).
  - Create 604319 (Approval Gate) or any other successor document -- this Analysis
    only recommends that such a document be created next; it does not create it.
  - Create any file other than this Analysis document.
```

---

## 14. Documentation Traceability Impact

```text
This Analysis itself is an instance of the same documentation-traceability
principle 604313 §14 already articulated for this lineage: the raw fact that
"0067 fails to replay with a syntax error" would, on its own, have led directly
(and incorrectly) to a routine Candidate-B reapplication, exactly as happened for
0046 and 0065's blockers. The independent completeness/comparison work in this
Analysis (§5-§7) is what surfaces the deeper duplicate-content problem -- a finding
that would not exist in the record at all if this Analysis had merely restated
604315/604317's reported occurrence count and classification. This is the direct,
concrete value the Documentation Traceability Requirement is meant to protect:
a future investigator reading this Analysis (rather than only the raw SQL diff or
a bare replay log) can see not just THAT 0067 failed, but WHY the correct next step
is not a routine syntax fix, and WHAT specifically must be decided before one is
attempted.
```

---

## 15. Required Next Step

```text
Human decision required — select among Candidates B, C, or D (§11) for 0067's
remediation, to be recorded in a future 604319 Approval Gate (not created by this
Analysis).

This Analysis does not create 604319, does not select a Candidate on Human's
behalf, and does not itself constitute authorization for any implementation. It
records only that:
  - 0066 remains full pass per 604317 Audit (canonical instance).
  - 0067 is confirmed a duplicate-migration-content / filename-purpose-mismatch
    blocker, not a plain syntax bug, and must not be treated as a routine
    Candidate-B reapplication target.
  - 0142 remains not reached; 0142 object absence is not a 0142 failure.
  - 604250 resume and 604260 closeout remain not authorized by any document in
    this workpacket, including this Analysis.
  - 604310 and 604316 remain unused/forbidden per Human number decision.
```
