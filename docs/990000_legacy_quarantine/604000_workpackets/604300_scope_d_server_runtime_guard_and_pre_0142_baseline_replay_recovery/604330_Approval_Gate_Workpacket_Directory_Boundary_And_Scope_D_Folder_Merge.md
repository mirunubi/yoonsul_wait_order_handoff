# 604330_Approval_Gate_Workpacket_Directory_Boundary_And_Scope_D_Folder_Merge.md

Status: Complete
Lifecycle: Human Approval Gate
Gate Classification: Workpacket Directory Hygiene — Stage 3 Human Approval Gate
Runtime Implementation Authorization: Granted for the narrow directory-hygiene scope in §14
Owner: Human
Last Updated: 2026-07-05

This is a documentation-only Approval Gate. It performs no file move, no folder
move, no rename, and no content edit. It does not create 604331, 604332, or
604333. Its current location (inside the 604290 folder) is temporary; 604331
Implementation must move this file into the final canonical 604300-family folder
as part of its own scope.

---

## 1. Approval Gate Scope

```text
In scope:
  - Recording the Human decision approving the 604290 -> 604300 folder merge and
    the 604310 -> 604400 relocation, as recommended in 604329 Analysis.
  - Locking the approved partial-renumbering policy for the four hard-collision
    604290-originated files (604301, 604302, 604303, 604306 -> 604341, 604342,
    604343, 604344).
  - Confirming the approved replacement number range (604341-604344) does not
    already exist anywhere in the workpackets tree, per 604329's own
    precondition.
  - Locking the authorized implementation boundary for a future 604331
    Implementation stage.
  - Recording that 0069's own Analysis remains explicitly deferred until this
    directory-hygiene work completes.

Out of scope (not performed, not authorized by this document):
  - Any actual file move, folder move, rename, or content edit.
  - Any SQL or migration change.
  - Performing the hygiene implementation itself -- that is 604331's job.
  - Opening 0069 Analysis.
  - Reopening 604260 closeout or 604250 resume.
```

---

## 2. Input Analysis Reference

```text
604329_Analysis_Workpacket_Directory_Boundary_And_Scope_D_Folder_Merge.md is the
sole analytical basis for this Approval Gate. Its findings, adopted here without
alteration:
  - 604290 (29 files, spanning the 0046-0069 replay-blocker lineage) and 604300
    (6-file Scope D master pack) share exactly 4 hard, filesystem-blocking
    collisions (604301, 604302, 604303, 604306), since both are slated to occupy
    the same canonical folder.
  - 604290 and 604310 (6-file Payment Confirm Idempotency slice) share 4 more,
    softer, non-blocking collisions (604311, 604312, 604313, 604315), resolved
    automatically once 604310 physically relocates to a separate 604400 folder.
  - 604300's own four colliding numbers are referenced by six or more other
    workpacket folders (the master index, 604250, 604260, 604270, 604280, and
    604310 itself); 604290's four colliding files are referenced almost
    exclusively within 604290's own internal lineage -- justifying renumbering
    604290's side, not 604300's.
  - 604300_Index and 604306_NavigationMap both currently reserve/describe a
    scope that does not account for the merged content, and will need their own
    content updated as part of this hygiene work (not merely files moved).
  - 604329 explicitly deferred selecting exact replacement numbers and the final
    canonical folder names to this Approval Gate.
```

---

## 3. Directory Boundary Problem

```text
604290_cross_scope_0046_context_builder_baseline_replay_blocker/ was originally
scoped to a single migration (0046), but its lineage organically expanded through
0063, 0065, 0066, 0067, 0068, and now 0069 -- becoming, in substance, the pre-0142
baseline replay recovery effort for Scope D's own runtime-guard verification. Its
folder name and location no longer reflect its actual scope, and its sequential
file numbering (604290-604328) drifted into the 604301-604306 and 604311-604315
ranges that 604300_Index and 604310 had already claimed for the Scope D master
pack and the Payment Confirm Idempotency slice respectively -- creating the 8
collisions 604329 Analysis identified and this Gate now resolves.
```

---

## 4. Approved Canonical Folder

```text
604300_scope_d_server_runtime_guard_and_pre_0142_baseline_replay_recovery

If a folder still named 604300_scope_d_server_runtime_guard exists at
implementation time, it is renamed to this canonical name as part of 604331. This
canonical folder becomes the single home for both the original Scope D master
pack (604300-604304, 604306, unchanged) and the entire 0046-0069 replay-recovery
lineage (604290, 604292-604328 with the four renumbered exceptions in §7), plus
this 604330 Approval Gate document itself once relocated.
```

---

## 5. 604290 to 604300 Merge Approval

```text
APPROVED. All files currently in
docs/600000_implementation_lifecycle/604000_workpackets/604290_cross_scope_0046_context_builder_baseline_replay_blocker/
are approved to move into the canonical folder named in §4, EXCEPT the four
hard-collision files, which move under their new numbers per §7. Every other
604290 file (604290, 604292, 604293, 604294, 604296, 604297, 604298, 604299,
604305, 604307, 604309, 604312, 604313, 604315, 604317, 604318, 604319, 604321,
604323, 604324, 604325, 604326, 604327, 604328, and this 604330 document itself)
moves with its filename and H1 entirely unchanged.

Note on 604312, 604313, and 604315: these three are the soft-collision files
identified in 604329 §6 (colliding with 604310's own files, not 604300's). Since
604310 is relocating out of the 604300-family folder space entirely (§9), these
three 604290-originated files move into the canonical 604300 folder UNCHANGED,
under their original numbers -- no renumbering is required or authorized for
them in this pass, consistent with 604329's own finding that this collision
resolves automatically once 604310 is no longer a 604300-family sibling folder.
```

---

## 6. Hard Collision Assessment

```text
Confirmed, per 604329 §6 and independently re-verified in this Gate: exactly four
files create a genuine, filesystem-blocking naming conflict if 604290 merges into
604300 as-is --

  604301: 604300's Overview_Scope_D_Server_Runtime_Guard vs 604290's
    Verification_Cross_Scope_0063_Provider_Payment_Key_Assignment_Replay_Blocker
  604302: 604300's Logic_Scope_D_Server_Runtime_Guard vs 604290's
    Audit_Cross_Scope_0063_Provider_Payment_Key_Assignment_Replay_Blocker
  604303: 604300's TestPlan_Scope_D_Server_Runtime_Guard vs 604290's
    Analysis_Cross_Scope_0065_Security_Isolation_Inline_Procedure_Replay_Blocker
  604306: 604300's NavigationMap_Scope_D_Server_Runtime_Guard_Workpacket_Flow vs
    604290's
    Audit_Cross_Scope_0065_Security_Isolation_Inline_Procedure_Replay_Blocker

Independently re-confirmed in this Gate: a search of
docs/600000_implementation_lifecycle/604000_workpackets/ for any file matching
604341*, 604342*, 604343*, or 604344* returns zero matches -- the approved
replacement range (§7) is confirmed clear and available.
```

---

## 7. Approved Partial Renumbering Policy

```text
APPROVED. Only the four 604290-originated colliding files are renumbered, in
ascending source-number order, with their original title suffix (everything after
the numeric prefix) preserved exactly:

  604301_Verification_Cross_Scope_0063_Provider_Payment_Key_Assignment_Replay_Blocker.md
    -> 604341_Verification_Cross_Scope_0063_Provider_Payment_Key_Assignment_Replay_Blocker.md

  604302_Audit_Cross_Scope_0063_Provider_Payment_Key_Assignment_Replay_Blocker.md
    -> 604342_Audit_Cross_Scope_0063_Provider_Payment_Key_Assignment_Replay_Blocker.md

  604303_Analysis_Cross_Scope_0065_Security_Isolation_Inline_Procedure_Replay_Blocker.md
    -> 604343_Analysis_Cross_Scope_0065_Security_Isolation_Inline_Procedure_Replay_Blocker.md

  604306_Audit_Cross_Scope_0065_Security_Isolation_Inline_Procedure_Replay_Blocker.md
    -> 604344_Audit_Cross_Scope_0065_Security_Isolation_Inline_Procedure_Replay_Blocker.md

604300's own four files (604301_Overview, 604302_Logic, 604303_TestPlan,
604306_NavigationMap) are NOT renumbered and move nowhere -- they already reside
in the folder that becomes canonical (§4) and keep their existing numbers
unchanged. 604331 must update the H1 of each of the four renamed files to exactly
match its new filename, and must update every reference to these four files
identified in 604329 §12 and re-confirmed at implementation time via a fresh
repo-wide search (not merely the pre-move snapshot already taken).

If 604331 discovers, at the moment of implementation, that 604341-604344 (or any
subset) have come to exist in the interim, it must stop and report for a fresh
Human decision rather than silently choosing a different number.
```

---

## 8. Soft Collision Resolution

```text
The four soft collisions (604290's 604311, 604312, 604313, 604315 vs 604310's own
604311-604315) are resolved entirely by §9's relocation of 604310 to 604400 --
no renumbering of 604290's three affected files (604312, 604313, 604315; 604290
does not itself contain a file numbered 604311, per 604329's inventory listing
604311 as 604290's Audit_Cross_Scope_0065_Scan_Cross_Tenant_Risk_Aggregate_
Inline_Limit_Replay_Blocker.md -- also unrenumbered) is required or authorized
under this Gate. These three (604311, 604312, 604313, 604315 as they appear in
604290) move into the canonical 604300 folder unchanged, per §5.
```

---

## 9. 604310 to 604400 Relocation Approval

```text
APPROVED.

Source: docs/600000_implementation_lifecycle/604000_workpackets/604310_scope_d_01_payment_confirm_idempotency/
Target: docs/600000_implementation_lifecycle/604000_workpackets/604400_scope_d_01_payment_confirm_idempotency/

All six files currently in the source folder move to the target folder with their
filenames and H1s entirely unchanged in this pass (§10).
```

---

## 10. Internal File Renumbering Policy

```text
DEFERRED, NOT PERFORMED IN THIS PASS. 604310's six internal files
(604310_Index, 604311_ImpactScope, 604312_Overview, 604313_Logic, 604314_TestPlan,
604315_ChangeContract) keep their existing numeric prefixes and H1s exactly as
they are, inside the newly-relocated 604400-named folder. The folder moves;
the files inside it do not renumber in this pass.

If full internal alignment (renumbering these six files to a 604400-prefixed
scheme) is later judged necessary, that is explicitly out of scope here and must
be proposed and approved as a SEPARATE, later 604400-internal-renumber hygiene
module -- not folded into 604331.
```

---

## 11. Reference Update Scope

```text
Authorized for update under 604331 (content edits, not new documents):
  - The 600000-level index / directory tree, if it references the old 604290,
    604300, or 604310 paths or the four renamed hard-collision numbers.
  - Any 604000_workpackets-level index or README, if present.
  - 604300_Index (content update to reflect the merged scope and the relocated
    604310/604400 slice, per 604329 §8).
  - 604306_NavigationMap (content update to add the replay-recovery lineage to
    its lane list, per 604329 §8).
  - 600179_Guide_Controlled_AI_Development_Pipeline.md, if it references the old
    paths or the four renamed numbers.
  - 604250, 604260, 604270, and 604280's own documents, if they reference the
    old 604290/604300/604310 paths or the four renamed numbers.
  - Any other document directly referencing
    604290_cross_scope_0046_context_builder_baseline_replay_blocker,
    604300_scope_d_server_runtime_guard, 604310_scope_d_01_payment_confirm_
    idempotency, or the four renamed hard-collision files by old number.

604331 must re-run a fresh repo-wide search for all of the above at
implementation time rather than relying solely on 604329's pre-move snapshot,
since document content may have changed between analysis and implementation.
```

---

## 12. Relocation Note Requirement

```text
604331 must create or update a relocation note inside the canonical 604300-family
folder (§4), explaining:
  - 604290 was merged into 604300 because its lineage expanded from a single
    0046-scoped replay blocker into the broader Scope D / pre-0142 baseline
    replay recovery effort.
  - 604310 was relocated to 604400 specifically to preserve the 604300-family
    number space for the merged content.
  - Only the four hard-collision 604290-origin files (604301/604302/604303/
    604306 -> 604341/604342/604343/604344) were renumbered; every other file in
    both lineages kept its original number.
  - Full renumbering of the entire merged lineage was deliberately avoided to
    preserve audit traceability -- the dense internal cross-referencing built up
    across 604290's own 29-document lineage (and referenced externally by other
    workpackets, per 604329 §12) was judged more valuable to preserve intact than
    achieving a fully sequential merged numbering scheme.

Suggested filename: 604330_Approval_Gate_Workpacket_Directory_Boundary_And_
Scope_D_Folder_Merge.md may itself serve as (or be accompanied by) this note once
relocated -- 604331 decides the exact final form, but must not skip creating some
form of this explanatory record in the canonical folder.

No implementation or verification document is created by this Approval Gate.
```

---

## 13. 0069 Analysis Deferral

```text
0069_create_pgvector_knowledge_rpc.sql (the MISSING_EXTENSIONS_SCHEMA blocker
identified in 604328 Audit) remains the next pre-0142 replay blocker in sequence.
Its own Analysis is explicitly NOT opened by this Gate and must NOT be opened
until directory hygiene Implementation (604331), Verification, and Audit are all
complete. When that Analysis is eventually opened, it must first resolve --
before proposing any fix -- whether the missing "extensions" schema reflects a
genuine content defect in 0069 itself, or a bootstrap-parity gap specific to the
local Supabase verification harness (which lacks the platform-level schema
pre-provisioning a real Supabase-hosted project would have), per 604328 Audit
§9's own finding.
```

---

## 14. Authorized Implementation Boundary

```text
Approved for 604331 Implementation (by Codex or Cursor file operations):
  - Folder rename / move: 604290 -> canonical 604300-family folder (§4/§5);
    604310 -> 604400 (§9).
  - File move: every file in both source folders, into their respective
    destinations, per §5/§8/§9.
  - Renumbering: EXCLUSIVELY the four hard-collision 604290-origin files
    (604301/604302/604303/604306 -> 604341/604342/604343/604344, §7). No other
    file in either lineage may be renumbered.
  - H1 update: EXCLUSIVELY for the four renamed files, to exactly match their
    new filenames (§7). No other file's H1 may be changed.
  - Path/number reference updates: within the scope named in §11.
  - Directory tree / index / NavigationMap content updates: within the scope
    named in §11/§12.
  - Relocation note creation or update: per §12.

No SQL or migration file may be touched under this authorization.
```

---

## 15. Forbidden Scope

```text
- No SQL modification of any kind.
- No migration modification of any kind.
- No 0069 Analysis document creation.
- No modification to 0069_create_pgvector_knowledge_rpc.sql.
- No replay verification execution, unless explicitly authorized as part of a
  later, separate 604332 Verification stage.
- No renumbering of any 604300-origin file (604300, 604301, 604302, 604303,
  604304, 604306) -- these keep their existing numbers unconditionally.
- No broad/full renumbering of the merged lineage beyond the four files named in
  §7.
- No renumbering of 604310's six internal files in this pass (§10).
- No 604250 resume.
- No 604260 closeout.
- No creation of a 604331 Implementation document by this Gate -- that remains a
  separate, later step.
- No creation of a 604332 Verification document by this Gate.
- No creation of a 604333 Audit document by this Gate.
- No file other than this Approval Gate document may be created by this task.
```

---

## 16. Human Approval Decision

```text
APPROVE_604350_604300_MERGE_AND_604310_TO_604400_RELOCATION_WITH_PARTIAL_HARD_COLLISION_RENUMBERING
```

---

## 17. Required Next Step

```text
PROCEED_TO_604331_IMPLEMENTATION_BY_CODEX_OR_CURSOR_FILE_OPERATIONS
```

```text
604331 must execute strictly within §14's authorized boundary, must re-verify
604341-604344's continued availability immediately before renaming (per §7's
own contingency), must relocate this 604330 document into the final canonical
604300-family folder as part of its own scope, and must be followed by its own
Verification and Audit before any claim of directory-hygiene closure or 0069
Analysis resumption is made.
```
