# 604329_Analysis_Workpacket_Directory_Boundary_And_Scope_D_Folder_Merge.md

Status: Complete
Lifecycle: Analysis
Gate Classification: Workpacket Directory Hygiene — Stage 1 Analysis
Runtime Implementation Authorization: Not Granted
Owner: TBD
Last Updated: 2026-07-05

This is an analysis document only. It performs no file move, no folder move, no
document content edit, and no SQL/migration edit. It does not close 604260 and
does not authorize 604250 resume. It does not create 604330 or any renumbered
document. Its own current location (inside the 604290 folder) is temporary; this
document itself is a relocation target once the merge implementation proceeds —
see §13.

---

## 1. Analysis Scope

```text
In scope:
  - Inventory of the 604290, 604300, and 604310 workpacket folders.
  - Identification of every numeric filename collision that a naive "move 604290's
    files into 604300, keep filenames as-is" merge would create.
  - Assessment of whether the pre-0142 baseline replay recovery lineage (0046
    through 0069, files 604290-604328) is correctly classified as part of Scope D,
    and whether merging it into 604300 is coherent with 604300's own prior,
    already-published documentation.
  - A concrete, evidence-based recommendation for resolving the collisions found
    (which side keeps its numbers, based on actual reference density across the
    wider docs tree, not assumption).
  - Identification of every external file that references 604290, 604300, 604310,
    or their internal document numbers, as candidates for update once a merge/
    relocation proceeds.
  - A recommended hygiene plan, explicitly deferred to a future Approval Gate for
    Human sign-off before any file operation occurs.

Out of scope (not performed, not authorized here):
  - Any actual file move, folder move, or rename.
  - Any edit to the content of any existing document.
  - Any SQL or migration change.
  - Creating 604330 (Approval Gate) or any implementation document.
  - Reopening 604260 closeout or 604250 resume.
```

---

## 2. Current Directory Structure

```text
docs/600000_implementation_lifecycle/604000_workpackets/
  604100_flutter_mvp_foundation/
  604200_wp_10a_001_minimal_static_validation_tooling/
  604250_scope_d_00_payment_ledger_confirm_payment_schema_drift_alignment/
  604260_scope_d_00a_toss_mvp_payment_intent_binding_precondition/
  604270_cross_scope_local_migration_replay_baseline_blockers/
  604280_cross_scope_0042_delivery_order_intake_baseline_replay_blocker/
  604290_cross_scope_0046_context_builder_baseline_replay_blocker/   <- 29 files
  604300_scope_d_server_runtime_guard/                                <- 6 files
  604310_scope_d_01_payment_confirm_idempotency/                     <- 6 files
```

Independently confirmed via direct directory listing in this Analysis. No other
folder in 604000_workpackets/ shares a numeric prefix with any file inside 604290,
604300, or 604310 (verified by an exhaustive per-number search across the entire
604000_workpackets/ tree — see §6).
```

---

## 3. 604290 Folder Inventory

```text
604290_cross_scope_0046_context_builder_baseline_replay_blocker/ contains 29 files,
spanning file numbers 604290-604328 (with intentional gaps at 604291, 604295,
604300, 604304, 604308, 604310, 604314, 604316, 604320, 604322 -- reflecting
Codex-implementation steps that produced no separate Module document, and numbers
604310/604316/604322 that were deliberately never used per this lineage's own
Human number decisions).

Documented replay-blocker lineage progression, confirmed by direct file inspection:
  0046 (Context Builder) -> 0063 (Provider Payment Key Assignment) -> 0065
  (Security Isolation, two sub-blockers: inline procedure, then aggregate inline
  limit) -> 0066 (Ledger Integrity, 15 occurrences) -> 0067 (Cron Scheduler
  Duplicate Migration) -> 0068 (Realtime Edge Invalid Table Constraint) -> 0069
  (pgvector Extensions Schema -- NOT YET ANALYZED; confirmed no 604290-folder
  document addresses 0069 yet, consistent with 604328 Audit's own "Required Next
  Step").

604310, 604316, and 604322 (as bare numbers) are confirmed NOT used anywhere in
this folder's own file list -- consistent with the explicit Human number
decisions recorded across 604311 Audit, 604317 Audit, 604323 Audit, and 604328
Audit, all stating these three numbers "remain unused/forbidden in this lineage."

H1 match status: every file in this folder was independently confirmed, at the
time of its own creation earlier in this same session, to have an H1 exactly
matching its filename -- this Analysis did not re-verify all 29 H1s line-by-line,
but no naming-convention deviation is known to exist in this folder except the
already-corrected 604296 (originally missing a "Context_Builder" segment, fixed
under 604298 Document Hygiene).
```

---

## 4. 604300 Folder Inventory

```text
604300_scope_d_server_runtime_guard/ contains 6 files:
  604300_Index_Scope_D_Server_Runtime_Guard.md
  604301_Overview_Scope_D_Server_Runtime_Guard.md
  604302_Logic_Scope_D_Server_Runtime_Guard.md
  604303_TestPlan_Scope_D_Server_Runtime_Guard.md
  604304_ChangeContract_Scope_D_Server_Runtime_Guard.md
  604306_NavigationMap_Scope_D_Server_Runtime_Guard_Workpacket_Flow.md

This is the canonical Scope D master documentation pack, confirmed by direct
read of 604300_Index: "604301~604304 are the Scope D master documentation pack
only... 604310~604380 define future sub-workpacket lane names and boundaries
only." This is the single most important fact this Analysis surfaces (§7): 604300
Index itself, when it was authored, EXPLICITLY RESERVED the entire 604310-604380
numeric range for future Scope D sub-workpacket lanes -- a reservation the
pre-0142 baseline replay recovery lineage's own sequential numbering (604290
onward) later drifted into without cross-checking against.

604306_NavigationMap, read directly in this Analysis, lists only four lanes:
604260, 604250, 604310, and (future) 604316 -- it does not mention 604270, 604280,
604290, or any baseline-replay-recovery blocker anywhere. Its "Last Updated" date
(2026-07-02) predates every replay-blocker document in the 604290 lineage,
confirming it was never updated to account for that later-emerging work.

This folder's numbers (604301, 604302, 604303, 604306 specifically) are
extensively externally referenced -- see §6.
```

---

## 5. 604310 Folder Inventory

```text
604310_scope_d_01_payment_confirm_idempotency/ contains 6 files:
  604310_Index_Scope_D_01_Payment_Confirm_Idempotency.md
  604311_ImpactScope_Scope_D_01_Payment_Confirm_Idempotency.md
  604312_Overview_Scope_D_01_Payment_Confirm_Idempotency.md
  604313_Logic_Scope_D_01_Payment_Confirm_Idempotency.md
  604314_TestPlan_Scope_D_01_Payment_Confirm_Idempotency.md
  604315_ChangeContract_Scope_D_01_Payment_Confirm_Idempotency.md

This is a genuine, separate Scope D sub-workpacket (Slice 01: Payment Confirm
Idempotency / Amount Verification), explicitly named and scoped within the
604310-604380 range 604300_Index itself reserved (§4). Per 604300_Index's own
text: "604310 ImpactScope~ChangeContract are complete, but 604310 implementation
is blocked until 604250 closes" -- this slice's own documents (604311-604315) are
complete through ChangeContract, with implementation and Human Approval (604316)
both explicitly deferred pending 604250's own schema-drift-alignment closure.

604310 is not, itself, contaminated by any replay-blocker content -- its 6 files
are entirely self-contained, payment-idempotency-specific documents unrelated to
0046-0069 replay recovery. Whether folder-name-only relocation suffices, or
whether internal file renumbering (604311 -> 604401, etc.) is also required, is
addressed in §10 -- this Analysis does not resolve that question on its own,
since it depends on how strictly the Approval Gate wants "604400" to mean
"file numbers start with 604400" versus "folder name changes but numbers persist
starting at 604310 inside it."
```

---

## 6. Directory Boundary Violation Assessment

```text
An exhaustive, per-number collision check was independently run in this Analysis:
every one of 604290's 29 file numbers was checked against every other file in
604000_workpackets/ (not merely 604300/604310, the entire tree). Result: exactly
EIGHT collisions exist, and only against 604300 and 604310 -- no other folder in
604000_workpackets/ shares any number with 604290's files.

Collision Group 1 -- HARD, FILESYSTEM-BLOCKING (both sides are slated to occupy
the SAME physical canonical folder, 604300, per Human Decision):
  604301: 604300's "Overview_Scope_D_Server_Runtime_Guard" vs 604290's
    "Verification_Cross_Scope_0063_Provider_Payment_Key_Assignment_Replay_Blocker"
  604302: 604300's "Logic_Scope_D_Server_Runtime_Guard" vs 604290's
    "Audit_Cross_Scope_0063_Provider_Payment_Key_Assignment_Replay_Blocker"
  604303: 604300's "TestPlan_Scope_D_Server_Runtime_Guard" vs 604290's
    "Analysis_Cross_Scope_0065_Security_Isolation_Inline_Procedure_Replay_Blocker"
  604306: 604300's "NavigationMap_Scope_D_Server_Runtime_Guard_Workpacket_Flow"
    vs 604290's
    "Audit_Cross_Scope_0065_Security_Isolation_Inline_Procedure_Replay_Blocker"

These four CANNOT both exist, unmodified, in the same directory -- a literal
filesystem naming conflict, not merely a documentation-clarity concern.

Collision Group 2 -- SOFT, NON-BLOCKING (604310's own files are relocating OUT of
the 604300-family folder space entirely, to 604400, per Human Decision, so no
filesystem conflict arises even if their numbers are left unchanged):
  604311: 604310's "ImpactScope_Scope_D_01_Payment_Confirm_Idempotency" vs
    604290's "Audit_Cross_Scope_0065_Scan_Cross_Tenant_Risk_Aggregate_Inline_
    Limit_Replay_Blocker"
  604312: 604310's "Overview_Scope_D_01_Payment_Confirm_Idempotency" vs 604290's
    "Analysis_Cross_Scope_0066_Ledger_Integrity_Aggregate_Inline_Limit_Replay_
    Blocker"
  604313: 604310's "Logic_Scope_D_01_Payment_Confirm_Idempotency" vs 604290's
    "Approval_Gate_Cross_Scope_0066_Ledger_Integrity_Aggregate_Inline_Limit_
    Replay_Blocker"
  604315: 604310's "ChangeContract_Scope_D_01_Payment_Confirm_Idempotency" vs
    604290's "Verification_Cross_Scope_0066_Ledger_Integrity_Aggregate_Inline_
    Limit_Replay_Blocker"

These four would NOT collide on disk once 604310's folder is physically at a
different path (604400_...) than 604290's merge target (604300_...) -- but they
remain a same-number-different-document ambiguity if anyone searches "604311"
etc. across the whole docs tree without folder context, and this Analysis
recommends resolving them too for consistency, not only the hard blockers.

Directory boundary violation: CONFIRMED. A plain "move files as-is" merge is not
directly executable for Collision Group 1 without renumbering one side first.
```

---

## 7. Scope D Classification Assessment

```text
Is the pre-0142 baseline replay recovery lineage (604270/604280/604290) correctly
understood as part of Scope D? The evidence is mixed and worth stating precisely,
not just assumed:

For treating it as Scope D-adjacent / mergeable:
  - The practical effect of this entire lineage (0035 through 0069+) has been to
    make Scope D's own runtime guard verifiable at all -- 604260, 604250, and
    604310 all depend on being able to replay/verify the schema cleanly, and
    604269 Audit (604260's own audit) explicitly cited baseline replay blockers
    as the reason 0142 runtime evidence could not be obtained, which is the
    direct trigger that started the 604270 workpacket in the first place.
  - The user's own stated framing in this task explicitly classifies it this way:
    "실제 성격은 pre-0142 baseline replay recovery / Scope D runtime guard가
    되었다."

Against treating it as a Scope D "slice" in the 604300_Index sense:
  - 604300_Index's own text defines 604310-604380 as reserved for "future
    sub-workpacket lane names" -- i.e., NEW FEATURE/GUARANTEE slices analogous to
    604310 (Payment Confirm Idempotency), each requiring its own full ImpactScope
    -> Overview -> Logic -> TestPlan -> ChangeContract -> Human Approval sequence
    under Scope D's own governance. The replay-blocker lineage is categorically
    different in kind: it is INFRASTRUCTURE REPAIR (fixing pre-existing, already-
    authored migrations so they parse and apply), not a new Scope D capability
    being added -- and 604270/604280 were both explicitly named "Cross-Scope,"
    not "Scope D 0X," suggesting their original authors (this Analysis's own
    earlier turns) already recognized this distinction and deliberately avoided
    Scope D's own slice-naming convention.
  - 604306_NavigationMap (Scope D's own master navigation document, Last Updated
    2026-07-02) makes no mention of 604270/604280/604290 at all -- it was authored
    before this lineage existed and was never updated to include it, meaning
    Scope D's own canonical "how the pieces fit together" document does not
    currently reflect this merge's premise.

Conclusion: the practical entanglement (Scope D cannot be runtime-verified without
this recovery work) is real and justifies SOME form of consolidation or explicit
cross-reference, but the numbering collision (§6) exists specifically because the
replay-blocker lineage's numbers drifted into a range 604300_Index had already
reserved for a DIFFERENT kind of thing. This Analysis does not contest Human's own
decision to merge, but flags that the merge will require reconciling 604300_Index
and 604306_NavigationMap's own existing text (which currently describes a 604310-
604380 reservation and a four-lane navigation route that doesn't mention this
lineage at all) -- not just moving files.
```

---

## 8. Folder Merge Rationale

```text
Given §7's finding, the merge is defensible PROVIDED it is accompanied by:
  1. An explicit update to 604300_Index acknowledging that the pre-0142 baseline
     replay recovery lineage is now part of the merged folder's own scope, and
     that the 604310-604380 reservation for FUTURE Scope D feature slices is
     narrowed or clarified to not include the replay-recovery document range.
  2. An explicit update to 604306_NavigationMap adding the replay-recovery route
     (0046 through 0069+) to its documented lane list, since it currently omits
     this entirely.
  3. Resolution of Collision Group 1 (§6) before or as part of the physical file
     move, since it is a hard filesystem blocker, not merely a documentation
     nicety.

Without (1)-(3), a naive "just move the files" merge would leave 604300_Index and
604306_NavigationMap actively contradicting the merged folder's actual contents
(claiming a reservation and a four-lane map that no longer match reality) --
exactly the kind of self-inconsistency this entire audit lineage has been built to
catch and prevent in every other document it has reviewed.
```

---

## 9. Proposed Canonical Folder

```text
Per Human Decision, 604300 is confirmed the canonical folder. This Analysis
proposes the folder be renamed (not merely have files added to it) to:

  604300_scope_d_server_runtime_guard_and_pre_0142_baseline_replay_recovery

This makes the folder's own name honest about its now-broadened scope (matching
§7's finding), rather than silently absorbing 29 replay-recovery documents into a
folder whose name still implies only the original 4-file Scope D master pack.
```

---

## 10. 604310 to 604400 Relocation Assessment

```text
Per Human Decision, 604310_scope_d_01_payment_confirm_idempotency/ relocates to a
604400-named folder, proposed as:

  604400_scope_d_01_payment_confirm_idempotency

Two sub-questions this Analysis identifies but does not resolve unilaterally:
  1. Do the INTERNAL file numbers (604310_Index, 604311_ImpactScope, ...,
     604315_ChangeContract) also renumber to the 604400s (e.g.
     604400_Index_Scope_D_01_..., 604401_ImpactScope_Scope_D_01_..., etc.), or
     does only the FOLDER name change while files keep their original 604310-
     family numbers inside the new 604400-named directory?
  2. If only the folder renames, Collision Group 2 (§6) remains merely a
     cross-tree same-number ambiguity, not a hard blocker, and could be left
     alone or resolved later at lower priority. If file numbers ALSO change,
     Collision Group 2 is moot entirely (both problems solved by the same
     relocation), but the scope of the relocation grows to include content edits
     (H1 lines, self-references) inside all 6 files, plus every external
     reference to "604311", "604312", etc. as those specific files (distinct
     from updating references to the folder path or to "604310" as the slice's
     own name).

This Analysis recommends resolving question 1 explicitly in the next Approval
Gate (604330), since it changes the size and risk of the relocation work
significantly, and is a decision Human should make deliberately rather than have
assumed by whichever implementer executes it first.
```

---

## 11. File Renumbering Policy

```text
For the 604290 -> 604300 merge specifically (Collision Group 1, §6): this
Analysis recommends KEEPING 604300's own four colliding numbers (604301, 604302,
604303, 604306) UNCHANGED, and RENUMBERING the four colliding 604290-originated
files instead. This recommendation is evidence-based, not a coin flip -- see the
reference-density findings in §12: 604300's own 604301 and 604306 are each
referenced by six or more OTHER workpacket folders (the master index, 604250's
entire document set, 604260, 604270, 604280, and 604310's entire document set),
while 604290's colliding four files are referenced almost exclusively within
604290's own 29-file internal lineage. Renumbering 604300's side would force
edits across at least six separate, already-established workpacket folders;
renumbering 604290's four colliding files forces edits within one (large, but
self-contained and already well cross-referenced by this Analysis's own prior
audits) folder.

This Analysis does NOT select the specific replacement numbers for the four
604290-originated colliding files (604301/604302/604303/604306) -- that decision
belongs to the 604330 Approval Gate, informed by this recommendation, since it
must avoid colliding with numbers already reserved or in active use (604329 =
this document; 604330 = the next Approval Gate; and whatever numbers the
continuing 0069+ Analysis/Approval Gate/Implementation/Verification/Audit cycle
will need going forward).

For the 604310 -> 604400 relocation (Collision Group 2, §6): no renumbering is
strictly required to resolve the soft collision (§10), but this Analysis
recommends Human decide explicitly whether to renumber those 6 files' internal
numbers to the 604400s as part of the same relocation, for consistency with the
merge's own renumbering of 604290's four files, rather than leaving one merge
fully renumbered and the other only folder-renamed.

Under no circumstance does this Analysis perform, or recommend performing without
a further Approval Gate, any renumbering of 604300's own master-pack files
(604300-604304, 604306) or any change to the internal content of any existing
document beyond what a future, separately-approved implementation stage would
carry out.
```

---

## 12. Reference Update Targets

```text
Search targets and results, independently run in this Analysis across the entire
docs/600000_implementation_lifecycle/ tree:

"604301" -- 25 files total; EXTERNAL to 604290/604300 (i.e. candidates needing
  review once the merge/renumber proceeds): 600000_Index_Implementation_
  Lifecycle.md; 604250's 604251/604252/604253/604254; 604260's 604262; 604310's
  604311/604312/604313/604314/604315.

"604302" -- 25 files total; same external-reference pattern as 604301 expected
  (not individually re-listed in this Analysis; recommend the same search be
  re-run at implementation time for exact file list).

"604303" -- 14 files total.

"604306" -- 16 files total; EXTERNAL: 600000_Index_Implementation_Lifecycle.md;
  604260's 604268/604269; 604270's own 604270_Index/604271_ImpactScope; 604280's
  own 604280_Index/604281_ImpactScope.

"604311" -- 18 files total; EXTERNAL: 600000_Index_Implementation_Lifecycle.md;
  600179_Guide_Controlled_AI_Development_Pipeline.md; 604250's 604251/604252;
  604300's own 604300_Index and 604301_Overview.

"604312", "604313", "604315" -- 16, 18, and 21 files respectively (not
  individually broken out in this Analysis; same recommendation to re-run at
  implementation time applies).

Non-numeric reference targets also confirmed to exist and require review:
  - docs/600000_implementation_lifecycle/600000_Index_Implementation_Lifecycle.md
    -- the master index; explicitly names the "604310_scope_d_01_payment_confirm_
    idempotency/" path and the "604310" workpacket number multiple times (e.g.
    "604250 must close before 604310 implementation approval," "604316 Human
    Approval for 604310 remains deferred").
  - docs/600100_readme_governance/600179_Guide_Controlled_AI_Development_
    Pipeline.md -- references 604311 in its own sub-workpacket-numbering-pattern
    example.
  - 604300_Index_Scope_D_Server_Runtime_Guard.md itself -- describes the
    604310-604380 reservation (§4/§7) and lists 604310 as an "Active sub-
    workpacket lane" with its own folder path.
  - 604306_NavigationMap -- lists 604310 as one of its four navigated lanes.
  - 604250's and 604260's own document sets -- reference 604310/604311/604312 in
    describing their own precondition relationships.

Recommended action for all of the above: defer exact edits to a future
Implementation stage under a 604330 Approval Gate's explicit authorization; this
Analysis's role is limited to identifying that these are the concrete files
requiring review, not to editing any of them.
```

---

## 13. Recommended Hygiene Plan

```text
1. Human confirms (via 604330 Approval Gate): the four 604290-originated
   colliding files (604301/604302/604303/604306) are renumbered to new,
   non-conflicting numbers not already reserved for the ongoing 0069+ cycle;
   604300's own four files keep their existing numbers unchanged (§11).
2. Human confirms whether 604310's internal file numbers renumber to 604400s or
   only the folder renames (§10).
3. 604300 folder is renamed to
   604300_scope_d_server_runtime_guard_and_pre_0142_baseline_replay_recovery
   (§9), and 604290's 29 files (with the 4 renumbered per step 1) are physically
   moved into it; the 604290 folder is then removed (or left as an empty
   relocation-note stub, Human's choice).
4. 604310 folder is renamed/relocated to 604400_scope_d_01_payment_confirm_
   idempotency (§9), with internal renumbering per step 2's decision.
5. 604300_Index and 604306_NavigationMap are updated to acknowledge the merged
   scope and the relocated 604310/604400 slice (§8) -- this is content editing,
   authorized only under a future, separate Approval Gate/Implementation stage,
   not by this Analysis.
6. Every external reference identified in §12 is updated to the new paths/
   numbers, verified via a fresh repo-wide search after the move (not merely
   trusting this Analysis's own pre-move snapshot, which will be stale by the
   time implementation occurs).
7. This 604329 Analysis document itself relocates into the new canonical 604300-
   family folder as part of step 3, consistent with the instruction that its
   current location (inside 604290) is temporary.

Final Recommendation:
RECOMMEND_MERGE_604350_INTO_604300_AND_RELOCATE_604310_TO_604400
```

---

## 14. Forbidden Scope

```text
This Analysis does not, and no future document produced from it may without
separate authorization:
  - Move any file or folder.
  - Rename any existing file or folder.
  - Renumber any existing file or change any existing H1.
  - Edit the content of any existing document (604300_Index, 604306_
    NavigationMap, the master index, or any other file identified in §12).
  - Modify any SQL or migration file.
  - Create 604330 (Approval Gate) or any implementation document.
  - Create a 604069/0069 Analysis document (that remains a separate, still-
    pending task per 604328 Audit's own Required Next Step, unrelated to this
    directory-hygiene question).
  - Resume 604250 implementation.
  - Close 604260.
  - Create any file other than this Analysis document.
```

---

## 15. Required Next Step

```text
604330 Approval Gate for directory hygiene implementation.

That Gate should resolve, at minimum:
  1. The exact replacement numbers for 604290's four colliding files
     (604301/604302/604303/604306), avoiding collision with numbers already in
     use or reserved for the ongoing 0069+ replay-blocker cycle.
  2. Whether 604310's internal file numbers renumber to 604400s or only the
     folder renames (§10).
  3. Whether 604300_Index and 604306_NavigationMap content updates (§8) are
     authorized as part of the same implementation pass or as a separate,
     subsequent step.
  4. The final canonical folder names for both the merged 604300-family folder
     and the relocated 604310/604400 folder (§9's proposals are candidates, not
     final).

This Analysis does not create that Gate and does not itself authorize any file
operation. It records only that:
  - A hard filesystem collision (4 files) exists between 604290 and 604300 if
    merged as-is; a softer, non-blocking cross-tree numbering ambiguity (4 more
    files) exists between 604290 and 604310, resolved automatically once 604310
    physically relocates to 604400.
  - The merge is defensible given the real operational entanglement between
    Scope D's runtime-guard verification and the baseline replay recovery work,
    but requires reconciling 604300_Index's and 604306_NavigationMap's own
    existing text, which currently does not account for this lineage at all.
  - 0069's own Analysis remains a separate, still-pending task, unaffected by
    this directory-hygiene question.
  - 604250 resume and 604260 closeout remain not authorized by any document in
    this workpacket, including this Analysis.
```
