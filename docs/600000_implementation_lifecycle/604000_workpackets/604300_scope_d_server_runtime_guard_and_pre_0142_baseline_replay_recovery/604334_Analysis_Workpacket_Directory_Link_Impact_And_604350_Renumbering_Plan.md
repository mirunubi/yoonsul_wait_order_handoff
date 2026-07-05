# 604334_Analysis_Workpacket_Directory_Link_Impact_And_604350_Renumbering_Plan.md

Status: Complete
Lifecycle: Analysis
Gate Classification: Workpacket Directory Hygiene — Stage 1 Analysis
Runtime Implementation Authorization: Not Granted
Owner: TBD
Last Updated: 2026-07-05

This is an analysis document only. It performs no file rename, no file move, no H1
edit, no link edit, no directory/index edit, and no SQL/migration edit. It does
not create 0069 Analysis.

**Numbering note, resolved with Human before this document was created:** this
task was originally requested as "604331 Analysis." Independent inspection at the
start of this task found that number already in use --
`604331_Implementation_Workpacket_Directory_Boundary_And_Scope_D_Folder_Merge.md`
already exists in this canonical folder, recording that the 604290/604300 merge
and 604310/604400 relocation approved by 604330 have ALREADY been executed, with
"604332 Verification" already declared as that document's own Next Step. To avoid
recreating the same kind of numbering collision this entire workpacket lineage has
been built to prevent, Human was asked and selected: use 604334 for this Analysis
(reserving 604332/604333 for the already-in-flight merge-verification/audit
track), and use a renumbering target range of 604350-604359 (not the originally
proposed 604450-604459, per Human's explicit correction: "604290-> 604350 으로
각각 60만치 늘립시다").

---

## 1. Analysis Scope

```text
In scope:
  - Current state of the canonical 604300 folder, confirming the 604290/604300
    merge and 604310/604400 relocation have already been executed (per 604331
    Implementation's own self-check).
  - Exact inventory of the 8 actually-existing files numbered 604290-604299 still
    sitting inside the canonical folder under their original low numbers.
  - Confirmation that the proposed target range (604350-604359, per Human's
    corrected +60 offset) is currently clear.
  - A precise rename mapping, H1 update targets, and link/reference impact scan
    for those 8 files specifically -- not a re-scan of the already-completed
    604290/604300/604310/604400 folder-level merge, which 604331 Implementation
    already executed and documented.
  - Identification of which directory/index files (000005, 000007 series;
    600000/604000 indexes; 604300_Index; 604306_NavigationMap) actually need
    updating for this specific renumbering -- verified directly, not assumed.

Out of scope (not performed, not authorized here):
  - Any actual file rename, move, H1 edit, or link edit.
  - Any SQL or migration change.
  - Re-litigating or re-verifying the already-completed 604290/604300/604310/
    604400 folder-level merge (604331 Implementation's own scope) -- this
    Analysis treats that as a settled precondition, cross-checked only where its
    own claims bear directly on this new renumbering's correctness.
  - Creating 0069 Analysis.
  - Creating 604332 (already reserved for the merge-verification track) or 604333
    (reserved for that track's Audit).
```

---

## 2. Current Canonical Folder State

```text
Confirmed by direct directory listing in this Analysis:
  docs/600000_implementation_lifecycle/604000_workpackets/
    604300_scope_d_server_runtime_guard_and_pre_0142_baseline_replay_recovery/

exists, contains 37 files, and includes both the original Scope D master pack
(604300, 604301, 604302, 604303, 604304, 604306 -- unrenumbered, per 604330's own
policy) and the full pre-0142 baseline replay recovery lineage (604290 through
604344, with the four hard-collision files already renamed to 604341-604344 per
604331 Implementation).

604400_scope_d_01_payment_confirm_idempotency/ also confirmed to exist, containing
exactly the 6 original 604310-604315 files with unchanged internal numbering, per
604330's own deferred-internal-renumbering policy.

The old 604290 and 604310 folder paths are confirmed absent -- no remaining
604350_cross_scope_0046... or 604310_scope_d_01... folder exists anywhere in
604000_workpackets/.

This Analysis independently spot-checked (not merely trusted) 604331
Implementation's own "Self-Check Results" (§13) against the live filesystem and
found them accurate on every point relevant to this task.
```

---

## 3. 604290-604299 Source File Inventory

```text
Exactly 8 files exist in this numeric range inside the canonical folder (604291
and 604295 are confirmed gaps -- no file exists at either number, consistent with
this lineage's own established pattern of Codex-implementation steps that
produced no separate Module document):

  604350_Analysis_Cross_Scope_0046_Context_Builder_Baseline_Replay_Blocker.md
  604352_Verification_Cross_Scope_0046_Context_Builder_Baseline_Replay_Blocker.md
  604353_Audit_Cross_Scope_0046_Context_Builder_Baseline_Replay_Blocker.md
  604354_Analysis_Cross_Scope_0046_Context_Builder_Secondary_Limit_5_Replay_Blocker.md
  604356_Verification_Cross_Scope_0046_Context_Builder_Secondary_Limit_5_Replay_Blocker.md
  604357_Audit_Cross_Scope_0046_Context_Builder_Secondary_Limit_5_Replay_Blocker.md
  604358_Document_Hygiene_Cross_Scope_0046_Context_Builder_Secondary_Limit_5_Verification_Filename_Correction.md
  604359_Analysis_Cross_Scope_0063_Provider_Payment_Key_Assignment_Replay_Blocker.md

These are exactly the first 8 documents of the 0046 Context Builder replay-blocker
sub-lineage (its full Analysis/Verification/Audit cycle for both the primary and
secondary 0046 blockers, plus the 604298 document-hygiene correction, plus the
first document of the NEXT sub-lineage, 604299's 0063 Analysis) -- i.e. the
earliest chapter of the merged lineage, chronologically and numerically preceding
everything else now in the canonical folder.
```

---

## 4. 604450-604459 Target Range Check

```text
Human's corrected target range is 604350-604359 (not 604450-604459 as originally
requested in this task's own framing). Independently verified in this Analysis: a
search across the entire 604000_workpackets/ tree for any file matching
604350*-604359* returns zero matches -- the corrected target range is confirmed
clear and available.

(The originally-named "604450-604459" range in this task's own title was also
independently checked and found clear, but is not used, per Human's explicit
correction to 604350-604359.)
```

---

## 5. Proposed Rename Mapping

```text
Ascending source-number order, +60 offset, suffix preserved exactly (matching the
same mapping style already successfully applied for the 604301-604306 hard
collisions in 604331 Implementation):

  604350_Analysis_Cross_Scope_0046_Context_Builder_Baseline_Replay_Blocker.md
    -> 604350_Analysis_Cross_Scope_0046_Context_Builder_Baseline_Replay_Blocker.md

  604291 -- NOT PRESENT, no rename needed (604351 remains unused)

  604352_Verification_Cross_Scope_0046_Context_Builder_Baseline_Replay_Blocker.md
    -> 604352_Verification_Cross_Scope_0046_Context_Builder_Baseline_Replay_Blocker.md

  604353_Audit_Cross_Scope_0046_Context_Builder_Baseline_Replay_Blocker.md
    -> 604353_Audit_Cross_Scope_0046_Context_Builder_Baseline_Replay_Blocker.md

  604354_Analysis_Cross_Scope_0046_Context_Builder_Secondary_Limit_5_Replay_Blocker.md
    -> 604354_Analysis_Cross_Scope_0046_Context_Builder_Secondary_Limit_5_Replay_Blocker.md

  604295 -- NOT PRESENT, no rename needed (604355 remains unused)

  604356_Verification_Cross_Scope_0046_Context_Builder_Secondary_Limit_5_Replay_Blocker.md
    -> 604356_Verification_Cross_Scope_0046_Context_Builder_Secondary_Limit_5_Replay_Blocker.md

  604357_Audit_Cross_Scope_0046_Context_Builder_Secondary_Limit_5_Replay_Blocker.md
    -> 604357_Audit_Cross_Scope_0046_Context_Builder_Secondary_Limit_5_Replay_Blocker.md

  604358_Document_Hygiene_Cross_Scope_0046_Context_Builder_Secondary_Limit_5_Verification_Filename_Correction.md
    -> 604358_Document_Hygiene_Cross_Scope_0046_Context_Builder_Secondary_Limit_5_Verification_Filename_Correction.md

  604359_Analysis_Cross_Scope_0063_Provider_Payment_Key_Assignment_Replay_Blocker.md
    -> 604359_Analysis_Cross_Scope_0063_Provider_Payment_Key_Assignment_Replay_Blocker.md

8 files renamed; 2 target numbers (604351, 604355) remain intentionally unused,
mirroring the 2 gaps already present at the source numbers (604291, 604295).

None of the 8 target filenames (604350, 604352, 604353, 604354, 604356, 604357,
604358, 604359) collide with any existing file anywhere in 604000_workpackets/,
independently confirmed via the same search as §4.
```

---

## 6. H1 Update Impact

```text
All 8 source files' current H1 lines were independently re-verified in this
Analysis to exactly match their current filenames (character for character,
including the leading "# " and trailing ".md") -- confirmed by direct read of each
file's first line. This means the required H1 update is purely mechanical: replace
the numeric prefix only, leaving every other character of the H1 (and filename)
unchanged, identical in kind to the H1 updates already correctly performed for the
604341-604344 renames.

| Current filename | Current H1 (verified match) | Expected new H1 |
| --- | --- | --- |
| 604350_Analysis_..._Baseline_Replay_Blocker.md | matches filename | 604350_Analysis_..._Baseline_Replay_Blocker.md |
| 604352_Verification_..._Baseline_Replay_Blocker.md | matches filename | 604352_Verification_..._Baseline_Replay_Blocker.md |
| 604353_Audit_..._Baseline_Replay_Blocker.md | matches filename | 604353_Audit_..._Baseline_Replay_Blocker.md |
| 604354_Analysis_..._Secondary_Limit_5_Replay_Blocker.md | matches filename | 604354_Analysis_..._Secondary_Limit_5_Replay_Blocker.md |
| 604356_Verification_..._Secondary_Limit_5_Replay_Blocker.md | matches filename | 604356_Verification_..._Secondary_Limit_5_Replay_Blocker.md |
| 604357_Audit_..._Secondary_Limit_5_Replay_Blocker.md | matches filename | 604357_Audit_..._Secondary_Limit_5_Replay_Blocker.md |
| 604358_Document_Hygiene_..._Filename_Correction.md | matches filename | 604358_Document_Hygiene_..._Filename_Correction.md |
| 604359_Analysis_..._Provider_Payment_Key_Assignment_Replay_Blocker.md | matches filename | 604359_Analysis_..._Provider_Payment_Key_Assignment_Replay_Blocker.md |

Implementation must update H1 for exactly these 8 files, and no others -- the
same discipline already correctly applied for 604341-604344.
```

---

## 7. Link Reference Search Results

```text
An independent, per-number search was run in this Analysis across the ENTIRE
docs/600000_implementation_lifecycle/ tree for each of the 8 source numbers
(604290, 604292, 604293, 604294, 604296, 604297, 604298, 604299). Result: every
single reference to every one of these 8 numbers is INSIDE the canonical 604300
folder itself -- no external workpacket folder (604250, 604260, 604270, 604280,
604400, or any other), and neither the master index nor the 600179 Guide,
references any of these 8 specific file numbers.

This is a materially smaller and safer blast radius than the 604301-604306 hard-
collision renumbering already completed, which required updating six or more
external workpacket folders and the master index. This renumbering requires
updating references ONLY within the canonical 604300 folder's own 37 files.

Referencing files identified (each is itself one of the 30 replay-recovery-lineage
documents or the 6-file master pack, all already inside the canonical folder;
none is a "historical audit content" file whose past-tense findings should be
preserved untouched -- see §14 for that distinction):
  - 604300_Index_Scope_D_Server_Runtime_Guard.md (one range reference, "604290-
    604328" -- see §11)
  - 604307, 604311, 604312, 604313, 604317, 604318, 604319, 604324, 604325,
    604329, 604330, 604331, 604341, 604342, 604343, 604344 each reference at
    least one of the 8 source numbers, almost always as a citation to a specific
    prior document (e.g. "per 604294 §8" or "already audited in 604297") within
    this same lineage's own internal cross-referencing.

None of these are relative-path hyperlinks (this project's documents use plain
numeric citation text, not markdown links, for cross-document references,
consistent with every prior document reviewed in this lineage) -- all references
are plain-text mentions of the document number, found via literal string search,
not link syntax requiring separate parsing.
```

---

## 8. Directory File Impact — 000005

```text
Two files exist under this five-digit prefix, with near-identical but reversed
titles:
  - docs/000005_Document_Number_Index.md
  - docs/000005_Index_Document_Number.md

Independently investigated in this Analysis: 000005_Document_Number_Index.md is
STALE -- it lists only 604200/604201/604202 (an older, unrelated workpacket) under
604000_workpackets/, with no entry for 604250, 604260, 604270, 604280, 604290,
604300, 604310, or 604400 at all. It predates this entire Scope D / replay-
recovery lineage and was not updated when any of it was created, including by
604331 Implementation's own reference-update pass. This is a pre-existing,
separate staleness issue, out of scope for this specific renumbering (it requires
no update for 604290-604299 specifically, since it never listed them, or any of
this lineage, to begin with).

000005_Index_Document_Number.md is the ACTIVELY MAINTAINED counterpart -- it was
updated by 604331 Implementation and correctly lists the canonical 604300 folder's
604300_Index/604301_Overview/604302_Logic/604303_TestPlan/604304_ChangeContract/
604306_NavigationMap entries and the 604400 folder's 604310-604315 entries.
However, independently confirmed in this Analysis: it does NOT individually list
any of the 604290-604299 (or 604307-604344) replay-recovery-lineage documents at
all -- only the master-pack/slice-defining documents (Index, Overview, Logic,
TestPlan, ChangeContract, NavigationMap-type files) appear to be tracked at
individual-file granularity in this index; Analysis/Verification/Audit/Approval-
Gate/Implementation documents within a lineage are not.

Conclusion: NEITHER 000005 file requires any update for this specific
604290-604299 renumbering. The stale file (Document_Number_Index) needs no change
because it never tracked this lineage; the active file (Index_Document_Number)
needs no change because it does not track individual lineage documents at this
level of granularity, only the folder's master-pack-style entries (which are
unaffected by this renumbering).
```

---

## 9. Directory File Impact — 000007

```text
Two files exist under this five-digit prefix, mirroring the 000005 pattern:
  - docs/000007_Full_Directory_Map.md (STALE -- confirmed via direct read to
    contain only a root-level Purpose/file-tree stub with no 604000_workpackets
    detail at all; not updated by 604331 and not requiring update for this task)
  - docs/000007_Map_Full_Directory.md (ACTIVE -- confirmed to list the canonical
    604300 folder and 604400 folder at the folder level, showing
    "604300_Index_Scope_D_Server_Runtime_Guard.md" and
    "604310_Index_Scope_D_01_Payment_Confirm_Idempotency.md" as representative
    entries, but not itemizing every file inside either folder)

Independently confirmed in this Analysis: 000007_Map_Full_Directory.md contains
zero references to any of the 8 source numbers (604290, 604292-604299). Same
conclusion as §8: neither 000007 file requires any update for this specific
renumbering.
```

---

## 10. 600000 / 604000 Index Impact

```text
docs/600000_implementation_lifecycle/600000_Index_Implementation_Lifecycle.md was
independently searched in this Analysis for all 8 source numbers: zero matches.
This master index does not reference any of the 8 files individually (consistent
with its own role, per 604331 Implementation's own record, of tracking folder-
level and slice-level entries -- 604300, 604310/604400 as slices -- not every
document within a replay-recovery lineage).

No dedicated 604000_workpackets-level index or README file was found to exist in
this Analysis's search (604331 Implementation's own §1 lists this as an
"authorized reference update target if present" but does not claim one exists;
this Analysis independently confirms none exists at this path level).

Conclusion: no update required to the 600000-level master index or any
604000_workpackets-level index for this renumbering.
```

---

## 11. 604300_Index Impact

```text
604300_Index_Scope_D_Server_Runtime_Guard.md contains exactly one reference
touching the 8 source numbers, independently located in this Analysis:

  "pre-0142 baseline replay recovery lineage (formerly 604290, 604290-604328)."

This is a RANGE description, not an individual file citation -- but it will become
inaccurate once the renumbering proceeds, since the lineage's numbering will no
longer be a single contiguous range. After renumbering, the lineage spans:
  604307-604344 (unaffected numbers, unchanged)
  604350, 604352-604354, 604356-604359 (the renamed 0046/early-0063 documents)
  604341-604344 (already-renamed hard collisions, a subset already inside the
    604307-604344 span above)

This is no longer expressible as a single "604290-604328"-style contiguous range.
604331 Implementation must update this single line in 604300_Index to either (a)
a piecewise description (e.g. "604307-604344, plus the renumbered 0046/0063-
opening documents at 604350-604359"), or (b) a simpler, less number-specific
description (e.g. "the merged pre-0142 baseline replay recovery lineage, detailed
in the folder's own file listing") -- this Analysis recommends option (b) as more
durable against any FUTURE renumbering, but leaves the final wording choice to
implementation.
```

---

## 12. 604306_NavigationMap Impact

```text
Independently confirmed in this Analysis: 604306_NavigationMap_Scope_D_Server_
Runtime_Guard_Workpacket_Flow.md contains ZERO references to any of the 8 source
numbers. As already noted in 604329 Analysis §4, this NavigationMap's own lane
list (604260, 604250, 604310/604400, future 604316) has never included the
replay-recovery lineage at all, at any numbering -- so this specific renumbering
requires no update to 604306_NavigationMap. (The broader gap -- that
604306_NavigationMap still does not mention the replay-recovery lineage as a lane
at all -- remains an open item from 604329/604330, unaffected by and not resolved
by this renumbering.)
```

---

## 13. 604310 to 604400 Reference Impact

```text
Independently confirmed in this Analysis: the 604310 to 604400 relocation is
already complete (§2) and unaffected by this renumbering -- none of the 8 source
numbers (604290, 604292-604299) reference 604310, 604400, or the Payment Confirm
Idempotency slice in either direction, and none of that slice's own 6 files
reference any of the 8 source numbers. This renumbering and the already-completed
604310/604400 relocation are independent concerns with no overlap.
```

---

## 14. Historical Audit Reference Policy

```text
Every one of the 16 internal referencing documents identified in §7 (604307
through 604344) is itself a formal Analysis, Verification, Audit, Approval Gate,
or Implementation document recording a historical finding -- e.g. 604297 Audit's
own text says "already audited and accepted in 604297" when referring backward,
or 604307 Analysis cites 604294/604296/604297 as precedent for its own reasoning.
These are NOT broken links in the sense of pointing to something that no longer
exists (the files still exist, only their numeric prefix changes) -- they are
plain-text citations that will become stale in the sense of pointing to a number
that no longer matches the cited document's actual filename, but they remain
historically accurate in substance (the finding they cite still holds; only the
number changed).

Recommended policy, consistent with how 604331 Implementation itself handled the
analogous case for 604341-604344 (per its own §8 "Reference Updates" and §11
listing "Cross-lineage references to renamed 604341-604344 files in 604341,
604342, 604343, 604344, 604307, 604312"): update these citations to the new
numbers as part of implementation, since they are live, actively-maintained audit
trail documents whose cross-references should stay resolvable -- do NOT leave
them pointing to stale numbers on the theory that "it's historical record." The
distinction this Analysis draws is between updating a citation's NUMBER (which
should happen, since it is a mechanical correctness fix) versus editing a
document's SUBSTANTIVE FINDINGS or conclusions (which should never happen without
a separate, explicit authorization) -- this renumbering only requires the former.
```

---

## 15. Proposed Codex Implementation Scope

```text
Recommended for a future 604335 (or similarly-numbered) Approval Gate to
authorize, matching the granularity already successfully used for 604331
Implementation:

A. Rename the 8 files per §5's mapping (604290->604350, 604292->604352,
   604293->604353, 604294->604354, 604296->604356, 604297->604357,
   604298->604358, 604299->604359).
B. Update H1 for exactly these 8 renamed files, per §6.
C. Update the internal cross-references identified in §7/§14 -- confirmed
   confined entirely to the canonical 604300 folder's own 37 files (16 of which
   contain at least one such reference).
D. No 000005 or 000007 series file requires update (§8, §9) -- both the stale and
   active variants of each were checked and neither references these 8 files
   individually.
E. Update 604300_Index's single range-description line (§11) to either a
   piecewise description or a non-number-specific description of the merged
   lineage.
F. No 604306_NavigationMap update is required for this specific renumbering
   (§12) -- its own broader gap (not mentioning the replay-recovery lineage at
   all) remains a separate, already-flagged, unresolved item from 604329/604330.
G. No 604310/604400 path reference update is required (§13) -- already complete
   and unrelated to this renumbering.
```

---

## 16. Forbidden Scope

```text
This Analysis does not, and no future document produced from it may without
separate authorization:
  - Rename, move, or edit any file's H1 or content.
  - Modify any SQL or migration file.
  - Create 0069 Analysis, or modify 0069_create_pgvector_knowledge_rpc.sql.
  - Create 604332 or 604333 (both reserved for the already-in-flight merge-
    verification/audit track per 604331 Implementation's own stated Next Step).
  - Re-verify or reopen the already-completed 604290/604300 merge or 604310/604400
    relocation beyond what is directly relevant to this new renumbering's own
    correctness.
  - Resume 604250 implementation.
  - Close 604260.
  - Create any file other than this Analysis document.
```

---

## 17. Risk Assessment

```text
Technical risk is low and well-bounded: the required change is a pure numeric
prefix substitution across 8 files, with H1 updates and reference updates
confined entirely to the same canonical folder (37 files total) -- no external
workpacket folder, master index, or 000005/000007-series file requires any
change, a materially smaller footprint than the already-completed 604301-604306
hard-collision renumbering (which touched six or more external folders and the
master index).

The main residual risk is the same completeness discipline already exercised
successfully for 604341-604344: every one of the 16 internal referencing
documents identified in §7 must have its citation updated, not just a subset --
this Analysis recommends the implementer re-run the same per-number search this
Analysis performed (not merely trust this document's own list) immediately before
and after the rename, consistent with this entire lineage's established practice
of re-verifying rather than assuming prior findings remain accurate at
implementation time.

604300_Index's own range-description line (§11) is the one piece of prose,
outside the pure file-rename mechanics, that requires editorial judgment (not
just search-and-replace) -- this should be reviewed carefully rather than
mechanically patched, to avoid introducing a new inaccurate description.
```

---

## 18. Required Next Step

```text
604332 Approval Gate, per this task's own original framing -- however, since
"604332" is already reserved by 604331 Implementation's own declared Next Step
(Verification of the ALREADY-completed 604290/604300/604310/604400 merge), this
Analysis recommends the Approval Gate for THIS renumbering be numbered
differently (e.g. 604335, continuing after the merge-verification track's
expected 604332 Verification and 604333 Audit) -- Human should confirm the exact
number at that time, consistent with how this Analysis's own number (604334) was
resolved.

Final Recommendation:
RECOMMEND_APPROVAL_GATE_FOR_604350_TO_604350_RENUMBERING_AND_604300_INDEX_CORRECTION

This Analysis does not create that Gate and does not itself authorize any file
operation. It records only that:
  - The 604290/604300 merge and 604310/604400 relocation are already complete
    (604331 Implementation), independently spot-checked and confirmed accurate.
  - 8 files (604290, 604292-604299) remain to be renumbered to 604350,
    604352-604354, 604356-604359 per Human's corrected +60 offset instruction.
  - All reference updates required are confined to the canonical 604300 folder's
    own 37 files; no 000005/000007-series file, master index, or 604306_
    NavigationMap requires any change.
  - 604300_Index's single range-description line requires editorial (not purely
    mechanical) correction.
  - 0069 Analysis remains deferred and unaffected by this task.
  - 604250 resume and 604260 closeout remain not authorized by any document in
    this workpacket, including this Analysis.
```
