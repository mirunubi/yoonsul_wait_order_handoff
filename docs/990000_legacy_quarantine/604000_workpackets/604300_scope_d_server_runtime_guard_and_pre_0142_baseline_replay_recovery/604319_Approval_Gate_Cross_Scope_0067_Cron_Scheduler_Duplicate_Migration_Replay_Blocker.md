# 604319_Approval_Gate_Cross_Scope_0067_Cron_Scheduler_Duplicate_Migration_Replay_Blocker.md

Status: Complete
Lifecycle: Human Approval Gate
Gate Classification: Cross-Scope Baseline Migration Replay Blocker — Stage 3 Human Approval Gate
Runtime Implementation Authorization: Granted for Candidate C, strictly bounded (§11)
Owner: Human
Last Updated: 2026-07-05

This is a documentation-only Approval Gate. It performs no implementation and
modifies no SQL, migration, or other file, including 0067. It does not create
604320. Per explicit Human number decision, 604310 and 604316 remain unused/
forbidden in this lineage.

---

## 1. Approval Gate Scope

```text
In scope:
  - Recording the Human decision among Candidates A/B/C/D (604318 Analysis §11) for
    remediating 0067's confirmed duplicate-migration-content/wrong-purpose defect.
  - Locking the authorized implementation boundary for Candidate C (the selected
    path) ahead of a future 604320 Implementation.
  - Explicitly deferring any real cron scheduler implementation out of this
    lineage's scope.

Out of scope (not performed, not authorized by this document):
  - Any edit to 0067 or any other migration.
  - Any change to 0066, 0065, 0063, 0046, 0042, 0038, 0035, or 0142.
  - Implementing Candidate C itself -- that is 604320's job, not this Gate's.
  - Reopening 604260 closeout or 604250 resume.
  - Using 604310 or 604316, both of which remain unused/forbidden.
```

---

## 2. Input Analysis Reference

```text
604318_Analysis_Cross_Scope_0067_Cron_Scheduler_Duplicate_Migration_Replay_Blocker.md
is the sole analytical basis for this Approval Gate. Its findings, adopted here
without alteration:
  - 0067's filename (0067_create_cron_scheduler_rpc.sql) implies a cron/job-
    scheduling migration; its header comment literally reads
    "0066_create_ledger_integrity_rpc.sql" and describes ledger integrity
    validation.
  - No cron/scheduler object, extension, or logic of any kind exists anywhere in
    0067 -- confirmed by an independent search for pg_cron, cron.schedule, create
    extension, job_id, and schedule(, all returning zero matches.
  - A full line-by-line diff between the current (post-604314-fixed) 0066 and 0067
    shows the two files differ at EXACTLY 15 locations -- the same 15 aggregate-
    inline-limit occurrences 604314 already corrected in 0066 -- and nowhere else.
    0067 is, in substance, a saved copy of 0066's pre-fix state under an unrelated
    number and purpose.
  - Root Cause Classification: DUPLICATE_MIGRATION_CONTENT_MISMATCH -- broader and
    more consequential than a plain AGGREGATE_INLINE_LIMIT_SYNTAX_ERROR, because a
    syntax-only fix would leave duplicate ledger-function redefinition risk and the
    missing cron-scheduler capability both unresolved.
  - Recommended path: PROCEED_TO_604319_APPROVAL_GATE_FOR_0067_CONTENT_DECISION --
    this document is that Gate.
```

---

## 3. Duplicate Migration Finding

```text
Independently established in 604318 §6-§7 and accepted here without modification:
0067's body declares the same table (catchmenu_ledger.integrity_check_results,
via CREATE TABLE IF NOT EXISTS) and the same four functions
(verify_event_ledger_integrity, verify_audit_chain, run_state_projection_check,
reconcile_ledger_gaps, each via CREATE OR REPLACE FUNCTION) that 0066 already
creates and that 604317 Audit already independently confirmed present and correct
after 604314's fix. If 0067 were applied as-is (once syntactically valid), it would
either harmlessly no-op on the table (IF NOT EXISTS) or -- more consequentially --
redefine the four functions via CREATE OR REPLACE, silently overwriting 0066's
already-audited, already-correct bodies with whatever 0067's own copy contains.
```

---

## 4. Filename / Header / Purpose Mismatch

```text
Filename: 0067_create_cron_scheduler_rpc.sql (implies cron/job-scheduling content).
Header comment: literally "-- 0066_create_ledger_integrity_rpc.sql" and a "Purpose"
line describing ledger integrity validation -- not cron scheduling.
Actual content: ledger integrity table + four ledger integrity functions, matching
0066's own declared "Creates" list verbatim.
No cron/scheduler object, extension, or logic exists anywhere in the file. This
three-way mismatch (filename vs. header vs. actual content) is the core finding
this Gate is built around, not merely the downstream syntax error it causes.
```

---

## 5. 0066 vs 0067 Comparison Summary

```text
Full line-by-line diff (604318 §6, independently re-confirmed as input to this
Gate): 15 differences total, all at the exact locations already catalogued in
604312/604313's 15-occurrence inventory for 0066's own aggregate-inline-limit fix.
Every other line -- every column, constraint, index, RLS policy, function
signature, WHERE/JOIN condition, and comment -- is identical between the two
files. This is the evidentiary basis for classifying 0067 as a duplicate of 0066's
pre-fix state, not an independently-authored file that coincidentally shares one
defect pattern.
```

---

## 6. Candidate A Assessment

```text
Candidate A: Apply the same Candidate B aggregate-inline-limit fix already used for
0066 to 0067's 15 duplicate occurrences.

Decision: REJECT

Reason:
  - Replay syntax would pass, but the duplicate ledger function redefinition risk
    (§3) remains -- 0067 would still CREATE OR REPLACE the same four functions
    0066 already created and 604317 already audited as correct.
  - Cron scheduler capability, which 0067's filename promises, would still not
    exist anywhere in the repository.
  - The wrong-purpose migration problem (§4) is not addressed at all -- 0067 would
    remain a mislabeled, redundant file even after this fix.
```

---

## 7. Candidate B Assessment

```text
Candidate B: Replace 0067's content with the actual, intended cron scheduler
migration content.

Decision: HOLD / NOT SELECTED

Reason:
  - No correct source for the intended cron scheduler content has been identified
    anywhere in this repository or its documentation (604318 §11).
  - Authoring new cron scheduler functionality is a content-creation task, not a
    replay-blocker cleanup -- it materially exceeds this workpacket's own scope
    (pre-0142 baseline replay blocker remediation) and would require its own
    separate design/ImpactScope/Overview/Logic/TestPlan/ChangeContract/Approval
    sequence, consistent with how every other new-capability decision in this
    lineage has been gated.
  - Held for potential future consideration, not rejected outright -- if real cron
    scheduler capability is later required, it should be scoped and approved
    separately (§13).
```

---

## 8. Candidate C Assessment

```text
Candidate C: Convert 0067 into a duplicate/no-op safety migration -- remove the
duplicated ledger-integrity object definitions and replace them with an explicit,
clearly-commented no-op, while preserving the file's number and correcting its
header to match its actual (now no-op) purpose.

Decision: APPROVED

Reason:
  - Removes the duplicate ledger redefinition risk (§3) entirely -- once 0067 no
    longer contains CREATE OR REPLACE statements for the four ledger functions,
    there is no risk of it overwriting 0066's already-correct, already-audited
    bodies, now or if either file is touched independently in the future.
  - Opens the 0142 replay path -- a no-op migration that documents its own
    quarantine reason parses and applies trivially, letting sequential replay
    continue past 0067.
  - Cron scheduler capability, if still needed, can be cleanly separated into its
    own future workpacket (§13) rather than being conflated with this remediation.
  - Matches this lineage's own stated purpose: this workpacket exists to clean up
    pre-0142 baseline replay blockers, not to author new capabilities. A duplicate-
    quarantine no-op is the narrowest change that satisfies that purpose without
    expanding scope into new-feature authorship (which Candidate B would require).
```

---

## 9. Candidate D Assessment

```text
Candidate D: Leave 0067 unmodified in this lineage; open a separate, distinctly-
scoped workpacket for the duplicate-migration-content incident.

Decision: REJECT FOR CURRENT REPLAY PATH

Reason:
  - 0142 replay would remain blocked indefinitely while a separate workpacket is
    scoped and executed, directly conflicting with this 604280/604290 lineage's
    own purpose of clearing pre-0142 baseline replay blockers.
  - The underlying diagnosis (604318) is already complete and unambiguous; nothing
    about deferring to a separate workpacket would change what needs to happen to
    0067 itself -- it would only delay it.
  - Not rejected as a governance pattern in general (this lineage has used exactly
    this kind of workpacket-separation approach before, e.g. 604270 -> 604280 ->
    604290), but rejected here specifically because the fix itself (Candidate C) is
    already fully scoped and does not require a separate workpacket to execute
    safely.
```

---

## 10. Approved Remediation Path

```text
APPROVE_CANDIDATE_C_DUPLICATE_NO_OP_SAFETY_MIGRATION_FOR_604320_IMPLEMENTATION
```

```text
0067_create_cron_scheduler_rpc.sql is to be converted into an explicit, clearly-
documented no-op/duplicate-quarantine migration under 604320 Implementation. Real
cron scheduler functionality is deferred out of this lineage entirely (§13). This
Gate does not implement Candidate C itself.
```

---

## 11. Authorized Implementation Boundary

```text
Approved Files:
  1. sql/migrations/0067_create_cron_scheduler_rpc.sql -- and ONLY this file.

Within 0067, the following changes are authorized for 604320:
  - Remove the duplicated 0066 ledger-integrity content: the
    catchmenu_ledger.integrity_check_results table statement (CREATE TABLE IF NOT
    EXISTS, indexes, RLS policy) and all four CREATE OR REPLACE FUNCTION statements
    (verify_event_ledger_integrity, verify_audit_chain, run_state_projection_check,
    reconcile_ledger_gaps) may be removed.
  - Convert the file into an explicit no-op / duplicate-quarantine migration --
    either a harmless DO block or a comment-only structure, whichever satisfies
    PostgreSQL's migration-apply requirements with the least content.
  - The file's number (0067) is preserved -- no renumbering, no renaming, no
    deletion of the file.
  - The header comment may be corrected to accurately describe the file's new,
    actual purpose (a documented no-op / duplicate-quarantine migration), replacing
    the current mismatched "0066_create_ledger_integrity_rpc.sql" / cron-scheduler
    header.
  - The no-op's reason -- that this migration number originally contained
    duplicated ledger-integrity content mismatched with its cron-scheduler
    filename, and has been intentionally converted to a no-op pending a possible
    future, separately-scoped cron scheduler migration -- must be recorded in the
    file as a comment, so a future reader of 0067 understands why it exists in this
    form without needing to consult this Gate or 604318 separately.

No new table, function, extension, or job-scheduling object may be created in
0067 under this authorization.
```

---

## 12. Forbidden Scope

```text
- No real cron scheduler implementation in 0067 or anywhere in this lineage.
- No pg_cron extension creation.
- No cron.schedule() call or equivalent job registration.
- No new scheduler/job table.
- No re-creation, re-definition, or re-execution of 0066's ledger functions inside
  0067 (this is the specific risk Candidate C exists to remove).
- No modification to 0066_create_ledger_integrity_rpc.sql.
- No modification to 0065_create_security_isolation_rpc.sql.
- No modification to 0063_patch_core_rpc_i18n_diagnostics.sql.
- No modification to 0046_create_context_builder_rpc.sql.
- No modification to 0035_verify_schema.sql, 0038_create_toss_webhook_processor_rpc.sql,
  or 0042_create_delivery_order_intake_rpc.sql.
- No modification to 0142_patch_toss_mvp_payment_intent_binding.sql.
- No 604250 resume.
- No 604260 closeout.
- No use of 604310.
- No creation of 604316.
- No creation of a 604320 Implementation document by this Gate -- that remains a
  separate, later step.
- No file other than this Approval Gate document may be created by this task.
```

---

## 13. Real Cron Scheduler Deferral

```text
Whatever cron/job-scheduling capability 0067's filename originally implied is
explicitly deferred, not abandoned. If real cron scheduler functionality is still
required, it must be pursued as a separate, later, distinctly-numbered workpacket
with its own ImpactScope/Overview/Logic/TestPlan/ChangeContract/Approval sequence
-- consistent with how every other new-capability decision in this lineage has been
scoped -- rather than being folded into 0067's remediation. This Gate does not
schedule, name, or otherwise commit to that future workpacket; it only notes that
the door remains open for one.
```

---

## 14. Replay Path Impact

```text
Once 604320 converts 0067 into a valid no-op per §11, a future clean sequential
replay is expected to parse and apply 0067 without error and proceed to 0068 (or
whatever migration follows), continuing the same pre-0142 baseline replay blocker
cleanup pattern this workpacket has followed since 0035. This Gate does not itself
perform or claim that replay result -- that is 604320's and its own subsequent
Verification's responsibility. 0142 remains not reached as of this Gate; 0142
object absence continues to be the mechanical consequence of upstream replay
blockers, not a 0142 failure, and this Gate does not change that status.
```

---

## 15. Documentation Traceability Requirement

```text
This Gate exists as a discrete, independently-readable document, consistent with
this lineage's established Documentation Traceability Requirement (604313 §14):
a bare SQL diff converting 0067 to a no-op would show WHAT changed, but not WHY
Candidate C was selected over A, B, or D, what was explicitly forbidden, or that
real cron scheduler capability was deferred rather than abandoned. Without this
Gate, a future investigator encountering a suddenly-empty or no-op
"0067_create_cron_scheduler_rpc.sql" would have no record of the duplicate-content
finding that motivated the change, or of the three rejected alternatives and their
reasons. This document, together with 604318 Analysis, is that record.
```

---

## 16. Human Approval Decision

```text
APPROVE_CANDIDATE_C_DUPLICATE_NO_OP_SAFETY_MIGRATION_FOR_604320_IMPLEMENTATION
```

---

## 17. Required Next Step

```text
PROCEED_TO_604320_IMPLEMENTATION_BY_CODEX
```

```text
604319 does not implement Candidate C itself. 604320 Implementation, once created,
must convert 0067 strictly within the boundary in §11, and must be followed by its
own Verification and Audit before any claim of 0067 closure or 0142 reachability is
made.
```
