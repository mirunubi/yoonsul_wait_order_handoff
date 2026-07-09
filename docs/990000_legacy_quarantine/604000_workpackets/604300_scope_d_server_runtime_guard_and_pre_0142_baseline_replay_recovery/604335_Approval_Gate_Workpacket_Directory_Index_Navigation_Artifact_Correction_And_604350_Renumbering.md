# 604335_Approval_Gate_Workpacket_Directory_Index_Navigation_Artifact_Correction_And_604350_Renumbering.md

Status: Complete
Lifecycle: Human Approval Gate
Gate Classification: Workpacket Directory Hygiene — Stage 3 Human Approval Gate
Runtime Implementation Authorization: Granted for the bundled scope in §14
Owner: Human
Last Updated: 2026-07-05

This is a documentation-only Approval Gate. It performs no file rename, no file
move, no H1 edit, no link edit, no directory/index/navigation file edit, and no
SQL/migration change. It does not create 604336, 604337, or 604338. It does not
create 0069 Analysis.

---

## 1. Approval Gate Scope

```text
In scope:
  - Recording the Human decision approving a bundled correction covering: the
    residual 604290-604299 -> 604350-604359 renumbering (604334's own proposal);
    the 604300_Index editorial correction; the 604306_NavigationMap lane
    addition; the stale 000005/000007 duplicate-file handling policy; a
    reference-scan-and-correction scope; and a standing, mandatory directory-
    artifact-update rule for all future file/folder operations in this repo.
  - Locking the authorized implementation boundary for a future 604336
    Implementation stage.
  - Confirming the approved target renumbering range (604350-604359) remains
    clear immediately before this Gate is finalized.

Out of scope (not performed, not authorized by this document):
  - Any actual file rename, move, H1 edit, link edit, or directory/index/
    navigation content edit.
  - Any SQL or migration change.
  - Performing the correction itself -- that is 604336's job.
  - Opening 0069 Analysis.
  - Reopening 604260 closeout or 604250 resume.
```

---

## 2. Input Audit Reference

```text
604333_Audit_Workpacket_Directory_Boundary_And_Scope_D_Folder_Merge.md is
adopted here without alteration as the audit basis for this Gate:
  - 604331 Implementation and 604332 Verification both accepted PASS -- the
    604290/604300 merge and 604310/604400 relocation are complete and correct.
  - A distinct, separately-named defect was opened:
    DOCUMENTATION_GOVERNANCE_DEFECT_MISSING_OR_STALE_FOLDER_NAVIGATION_
    ARTIFACTS -- confirmed independently in 604333, not merely asserted.
  - 604300_Index's "604290-604328" contiguous-range line is confirmed still
    present and now factually imprecise.
  - 604306_NavigationMap's lane list is confirmed still limited to four lanes
    (604260, 604250, 604310/604400, future 604316), entirely omitting the
    pre-0142 baseline replay recovery lineage that now comprises roughly 30 of
    the canonical folder's 40 files.
  - Two of the four 000005/000007-series files (000005_Document_Number_Index.md,
    000007_Full_Directory_Map.md) are confirmed stale, predating this entire
    lineage and never updated to reflect any of it.
  - Final Audit Decision: ACCEPT_FOLDER_MERGE_AND_RELOCATION_WITH_DIRECTORY_
    ARTIFACT_GOVERNANCE_DEFECT_OPEN. Required Next Step: this Approval Gate,
    ahead of 0069 Analysis.
```

---

## 3. Input Side Analysis Reference

```text
604334_Analysis_Workpacket_Directory_Link_Impact_And_604350_Renumbering_Plan.md
is adopted here without alteration as the renumbering-scope basis for this Gate:
  - 8 files actually exist in the 604290-604299 range inside the canonical
    folder (604290, 604292, 604293, 604294, 604296, 604297, 604298, 604299);
    604291 and 604295 are confirmed pre-existing gaps.
  - The target range 604350-604359 (Human's own corrected +60 offset,
    superseding the originally-proposed 604450-604459) is confirmed clear.
  - Every reference to these 8 numbers is confirmed confined entirely within the
    canonical 604300 folder's own 37 (now larger) file set -- no external
    workpacket folder, master index, or 000005/000007-series file references
    any of these 8 numbers individually.
  - 604300_Index's single range-description line requires editorial (not purely
    mechanical) correction as part of this renumbering.
  - 604306_NavigationMap requires no update for the renumbering itself (its
    broader lane-omission gap is a separate matter, addressed in §10 of this
    Gate).
  - 604334 itself initially concluded no further 000005/000007 update was needed
    FOR THE RENUMBERING ALONE -- this conclusion is not contradicted by 604333's
    broader governance-defect finding; the two are complementary; the
    renumbering's own reference footprint remains internal to the canonical
    folder, while the STALE-DUPLICATE-FILE problem 604333 identified is a
    separate, pre-existing issue this Gate also addresses (§11).
```

---

## 4. Directory Artifact Governance Defect

```text
Adopted from 604333 without alteration: this project has a recurring pattern
where mechanical path/reference corrections (updating an old folder path to a
new one) are performed reliably, but substantive documentation additions
(adding a new lane to a NavigationMap; correcting a range description that no
longer holds true; retiring or reconciling a stale duplicate index file) are
not. This Gate exists specifically to close this gap for the current state of
the canonical 604300 folder, and to establish a standing rule (§13) so it does
not recur the next time files move or are created anywhere in this repository.
```

---

## 5. Approved 604350 Renumbering Scope

```text
APPROVED. The 8 files currently numbered 604290, 604292, 604293, 604294, 604296,
604297, 604298, and 604299 inside the canonical 604300 folder are renumbered to
604350, 604352, 604353, 604354, 604356, 604357, 604358, and 604359 respectively,
using a +60 offset and preserving the existing gaps at 604291/604295 (no
604351 or 604355 file is created). Every other file in the canonical folder
(604300-604306 master pack, 604307-604344 unaffected lineage documents,
604329-604334 hygiene documents) is explicitly NOT renumbered under this scope.
```

---

## 6. Approved Rename Mapping

```text
604350_Analysis_Cross_Scope_0046_Context_Builder_Baseline_Replay_Blocker.md
  -> 604350_Analysis_Cross_Scope_0046_Context_Builder_Baseline_Replay_Blocker.md

604352_Verification_Cross_Scope_0046_Context_Builder_Baseline_Replay_Blocker.md
  -> 604352_Verification_Cross_Scope_0046_Context_Builder_Baseline_Replay_Blocker.md

604353_Audit_Cross_Scope_0046_Context_Builder_Baseline_Replay_Blocker.md
  -> 604353_Audit_Cross_Scope_0046_Context_Builder_Baseline_Replay_Blocker.md

604354_Analysis_Cross_Scope_0046_Context_Builder_Secondary_Limit_5_Replay_Blocker.md
  -> 604354_Analysis_Cross_Scope_0046_Context_Builder_Secondary_Limit_5_Replay_Blocker.md

604356_Verification_Cross_Scope_0046_Context_Builder_Secondary_Limit_5_Replay_Blocker.md
  -> 604356_Verification_Cross_Scope_0046_Context_Builder_Secondary_Limit_5_Replay_Blocker.md

604357_Audit_Cross_Scope_0046_Context_Builder_Secondary_Limit_5_Replay_Blocker.md
  -> 604357_Audit_Cross_Scope_0046_Context_Builder_Secondary_Limit_5_Replay_Blocker.md

604358_Document_Hygiene_Cross_Scope_0046_Context_Builder_Secondary_Limit_5_Verification_Filename_Correction.md
  -> 604358_Document_Hygiene_Cross_Scope_0046_Context_Builder_Secondary_Limit_5_Verification_Filename_Correction.md

604359_Analysis_Cross_Scope_0063_Provider_Payment_Key_Assignment_Replay_Blocker.md
  -> 604359_Analysis_Cross_Scope_0063_Provider_Payment_Key_Assignment_Replay_Blocker.md

No source file exists for 604291 or 604295 -- 604351 and 604355 must NOT be
created. If 604336 discovers, at implementation time, that 604350/604352-604354/
604356-604359 (or any subset) have come to exist in the interim, it must stop
and report for a fresh Human decision rather than silently choosing a different
number -- independently re-confirmed clear immediately before this Gate (§1).
```

---

## 7. H1 Update Authorization

```text
AUTHORIZED, for exactly the 8 files in §6, and no others. Each renamed file's H1
must be updated to exactly match its new filename, character for character,
mirroring the discipline already correctly applied to the 604341-604344 renames
under 604331 Implementation. No H1 belonging to any 604300-origin master-pack
file, any 604341-604344 file, any 604329-604334 hygiene document, or any 604400-
relocated file may be touched under this authorization.
```

---

## 8. Link Reference Update Authorization

```text
AUTHORIZED. All direct references to the 8 old filenames/numbers (604350_,
604352_, 604353_, 604354_, 604356_, 604357_, 604358_, 604359_) must be updated
to their new numbers, wherever they occur. Per 604334's own confirmed finding
(§3), this is confined entirely to files already inside the canonical 604300
folder -- no external workpacket folder requires any edit for this specific
renumbering.

References to the folder-path strings
604290_cross_scope_0046_context_builder_baseline_replay_blocker,
604300_scope_d_server_runtime_guard (the pre-merge name), and
604310_scope_d_01_payment_confirm_idempotency (the pre-relocation name) are
addressed under §11/§12's broader reference-scan scope, not this renumbering
specifically -- most such references were already updated by 604331
Implementation, but 604336 must re-scan rather than assume completeness (per
604333/604334's own established discipline of independent re-verification).

Historical audit narrative referencing an old number purely as part of a past-
tense explanation (e.g. "already audited in 604297") should have its NUMBER
corrected to the new value, consistent with 604334 §14's own policy: the
citation's substantive finding is preserved; only the number, which is a
mechanical correctness matter, is corrected.
```

---

## 9. 604300_Index Correction Authorization

```text
AUTHORIZED. The line "pre-0142 baseline replay recovery lineage (formerly
604290, 604290-604328)" (or its exact current wording) must be replaced with an
accurate description of the post-hygiene structure. The replacement must:
  - State that the pre-0142 baseline replay recovery lineage (originally its own
    604290-numbered workpacket) was merged into this canonical 604300 folder.
  - State that the earliest documents in that lineage (formerly 604290-604299)
    have been renumbered to 604350-604359.
  - Mention 604341-604344 as the hard-collision-resolution renumbered files,
    where relevant to the surrounding text.
  - Mention that 604329-604334 (and now 604335, and the future 604336) handled
    the folder-hygiene / audit / side-analysis / approval sequence itself.
  - Preserve the existing Scope D master-pack framing and context around this
    line -- this is a targeted correction to one inaccurate description, not a
    rewrite of the document.

604336 must NOT rewrite any other, unrelated section of 604300_Index.
```

---

## 10. 604306_NavigationMap Lane Addition Authorization

```text
AUTHORIZED. A new lane must be added to 604306_NavigationMap's lane list, named
along the lines of "Pre-0142 Baseline Replay Recovery / Cross-Scope Replay
Blocker Chain," summarizing:
  - The 0042/0046/0063/0065/0066/0067/0068 replay-blocker cleanup sequence.
  - 0069 as the currently-deferred next blocker, pending this directory-artifact
    correction.
  - 0142 as not yet reached, specifically because of 0069.
  - 604328 Audit's own acceptance of 0068 and classification of 0069 as the next
    blocker.
  - The 604329-604333 folder-hygiene/audit sequence, 604334's impact analysis,
    and this 604335 Approval Gate / the future 604336 Implementation.

The new lane's description must make explicit:
  - This lane lives inside the same canonical 604300 folder as the Scope D
    master pack, but is NOT the Payment Confirm Idempotency slice.
  - 604400_scope_d_01_payment_confirm_idempotency/ is the separate, already-
    relocated home of that slice (604310-604315, unrenumbered internally).
  - 0069 Analysis remains deferred until this directory-artifact correction
    (this Gate and its 604336 Implementation) is complete.

604336 must NOT remove or alter the existing four lanes (604260, 604250, 604310/
604400, future 604316) beyond what is needed to add this fifth lane cleanly.
```

---

## 11. 000005 / 000007 Stale Duplicate Handling Decision

```text
For the two confirmed-stale files (000005_Document_Number_Index.md,
000007_Full_Directory_Map.md):

  1. 604336 must first identify the active/canonical counterpart for each
     (000005_Index_Document_Number.md and 000007_Map_Full_Directory.md,
     respectively, per 604333/604334's own findings) and confirm no reference
     anywhere in the repository depends specifically on the STALE file's
     content being authoritative.
  2. Do NOT delete either stale file in this pass.
  3. Do NOT rename either stale file in this pass unless an exact active
     replacement path is confirmed and no reference would break as a result.
  4. PREFERRED approach: convert each stale file into an explicit, clearly-
     labeled deprecated forwarding document:
       - The H1 must still exactly match the (unchanged) stale filename.
       - Immediately after the H1, add a clear deprecation notice.
       - The notice must name and point to the active/canonical counterpart
         document.
       - The notice must state that this file predates the Scope D / pre-0142
         replay recovery lineage and must not be treated as the source of
         truth for it.
  5. If 604336 cannot confidently identify the correct active/canonical
     counterpart for either stale file, it must STOP and report back for a
     fresh Human decision rather than guessing or editing further.

For the two active files (000005_Index_Document_Number.md,
000007_Map_Full_Directory.md):
  - If already current, update only as needed so they correctly show the
    canonical 604300 folder name and the 604400 folder name, with no lingering
    reference to the old 604290 or 604310 folder names.
  - If, by design, they track only folder-level/master-pack entries and not
    individual lineage documents (as 604334 §8-§9 already found), 604336 must
    explicitly document this design limitation in its own record -- not leave it
    implicit or undocumented, since that ambiguity is itself part of what
    triggered 604333's governance-defect finding.
```

---

## 12. Active Directory Artifact Policy

```text
604336 must ensure, upon completion, that the ACTIVE 000005 and 000007 files
correctly include:
  - The canonical folder:
    604300_scope_d_server_runtime_guard_and_pre_0142_baseline_replay_recovery/
  - The 604400 folder: 604400_scope_d_01_payment_confirm_idempotency/
  - No remaining reference to the old, now-nonexistent
    604290_cross_scope_0046_context_builder_baseline_replay_blocker/ folder path.
  - No remaining reference to the old, now-nonexistent
    604310_scope_d_01_payment_confirm_idempotency/ folder path (distinct from
    the still-valid slice name "604310 Payment Confirm Idempotency," which may
    still appear in prose referring to the slice itself, not its old folder
    path).
```

---

## 13. Mandatory Directory Artifact Rule

```text
604336 Implementation must explicitly record, as a standing rule (not merely a
one-time correction), the following:

  Any future folder creation, folder rename, folder merge, file move, or file
  renumbering in this repository must update, wherever applicable:
    - The 000005 directory/document-number index.
    - The 000007 full-directory/navigation map.
    - The folder-local index document (if the affected folder has one).
    - The folder-local NavigationMap document (if the affected folder has one).
    - Any parent-level index or directory tree.
    - Every direct link/reference and H1 affected by the change.

This rule must be recorded in 604336 Implementation's own document, and must
also be reflected -- in appropriately summarized form -- in 604300_Index or
604306_NavigationMap, wherever it is most natural to place a durable reminder
for future readers and implementers of this specific folder's own governance
expectations.
```

---

## 14. Authorized Implementation Boundary

```text
Approved for 604336 Implementation (by Codex or equivalent file-operations
implementer):
  A. Rename the 8 files per §6.
  B. Update H1 for exactly those 8 files, per §7.
  C. Update all direct references to the 8 old numbers, confined to the
     canonical 604300 folder per §8.
  D. Correct 604300_Index's range-description line per §9.
  E. Add the new lane to 604306_NavigationMap per §10.
  F. Handle the two stale 000005/000007 files per §11 (deprecation-notice
     conversion, not deletion or blind rename), and confirm/update the two
     active 000005/000007 files per §11/§12.
  G. Record the mandatory directory-artifact rule per §13.

No SQL or migration file may be touched under this authorization. No file
outside the canonical 604300 folder, the 604400 folder (read-only reference
check per §12), and the four 000005/000007-series files may be modified.
```

---

## 15. Forbidden Scope

```text
- No SQL modification of any kind.
- No migration modification of any kind.
- No 0069 Analysis document creation.
- No modification to 0069_create_pgvector_knowledge_rpc.sql.
- No replay verification execution.
- No broad/full renumbering beyond the 8 files named in §6.
- No renumbering of any 604300-origin master-pack file (604300-604304, 604306).
- No renumbering of 604341, 604342, 604343, or 604344.
- No renumbering of 604329, 604330, 604331, 604332, 604333, or 604334.
- No renumbering of any 604400-internal file (604310-604315).
- No 604250 resume.
- No 604260 closeout.
- No deletion of either stale 000005/000007 file in this pass.
- No creation of a 604336 Implementation document by this Gate -- that remains a
  separate, later step.
- No creation of a 604337 Verification document by this Gate.
- No creation of a 604338 Audit document by this Gate.
- No file other than this Approval Gate document may be created by this task.
```

---

## 16. Human Approval Decision

```text
APPROVE_DIRECTORY_INDEX_NAVIGATION_ARTIFACT_CORRECTION_AND_604350_RENUMBERING_FOR_604336_IMPLEMENTATION
```

---

## 17. Required Next Step

```text
PROCEED_TO_604336_IMPLEMENTATION_BY_CODEX
```

```text
604336 must execute strictly within §14's authorized boundary, must re-verify
604350/604352-604354/604356-604359's continued availability immediately before
renaming (per §6's own contingency), must apply §11's stale-file handling
policy rather than deleting or blindly renaming either stale 000005/000007
file, must record the mandatory directory-artifact rule per §13, and must be
followed by its own Verification and Audit before any claim of directory-
artifact correction closure or 0069 Analysis resumption is made.
```
