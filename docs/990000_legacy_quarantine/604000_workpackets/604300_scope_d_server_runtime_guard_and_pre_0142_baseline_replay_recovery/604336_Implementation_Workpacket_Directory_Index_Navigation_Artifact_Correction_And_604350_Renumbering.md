# 604336_Implementation_Workpacket_Directory_Index_Navigation_Artifact_Correction_And_604350_Renumbering.md

## 1. Implementation Scope

Apply the directory/index/navigation artifact correction and the approved residual 604290-origin file renumbering within the canonical 604300 folder. This was a Markdown filename, H1, link, Index, NavigationMap, and forwarding-artifact task only.

## 2. Human Approval Reference

`604335_Approval_Gate_Workpacket_Directory_Index_Navigation_Artifact_Correction_And_604350_Renumbering.md` authorized this implementation and locked its file and numbering boundaries.

## 3. Input Audit and Analysis References

- 604333 Audit accepted the canonical folder merge and identified follow-up artifact work.
- 604334 Analysis defined link impact, collision handling, and the 604350 renumbering plan.
- 604335 Approval Gate authorized the exact implementation performed here.

## 4. Renamed File Mapping

| Old prefix | New prefix | Result |
| --- | --- | --- |
| 604290 | 604350 | Renamed |
| 604292 | 604352 | Renamed |
| 604293 | 604353 | Renamed |
| 604294 | 604354 | Renamed |
| 604296 | 604356 | Renamed |
| 604297 | 604357 | Renamed |
| 604298 | 604358 | Renamed |
| 604299 | 604359 | Renamed |

604291 and 604295 were pre-existing gaps. No 604351 or 604355 file was created. The 604300-origin master pack, 604329-604335 sequence, 604341-604344 collision-resolution records, and 604400 internal files were not renumbered.

## 5. H1 Update Summary

Each renamed 60435x file now has an H1 exactly matching its new filename. Existing title suffixes were preserved; only the approved numeric prefix changed.

## 6. Link Reference Update Summary

Direct old filename-prefix references within the canonical folder were updated to the corresponding 60435x names. Historical folder-name narratives remain only where they explicitly describe pre-merge or old paths; they are not active links. Active directory artifacts point to the canonical 604300 folder and the separate 604400 payment-confirm-idempotency folder.

## 7. 604300_Index Correction

The Index now describes the combined Scope D Server Runtime Guard and pre-0142 replay-recovery role without claiming a false contiguous number range. It records the 604350 renumbering, intentional 604351/604355 gaps, 604341-604344 collision records, 604329-604336 directory-hygiene sequence, and the deferred 0069 state.

## 8. 604306_NavigationMap Lane Addition

Added the `Pre-0142 Baseline Replay Recovery / Cross-Scope Replay Blocker Chain` lane covering 0042, both 0046 blockers, 0063, both 0065 blockers, 0066, 0067, and 0068. The lane records 0069 as deferred, 0142 as not reached, the 604328/604329-604336 governance chain, canonical 604300 ownership, and separation from the 604400 Scope D 01 slice.

## 9. 000005 / 000007 Stale Duplicate Handling

Confirmed active counterparts first:

- `docs/000005_Index_Document_Number.md`
- `docs/000007_Map_Full_Directory.md`

Both active artifacts already contain the canonical 604300 and separate 604400 folders and contain no active stale 604290 or 604310 folder entry. They use a folder/master-pack tracking schema rather than enumerating every replay-lineage document.

The stale `docs/000005_Document_Number_Index.md` and `docs/000007_Full_Directory_Map.md` files were retained as deprecated forwarding documents, with H1s matching their filenames and links to their active canonical counterparts. They are explicitly not sources of truth.

## 10. Active Directory Artifact Policy

The active 000005 artifact is the document-number/directory index and the active 000007 artifact is the full directory/navigation map. Folder-local 604300 Index and NavigationMap documents own detailed lineage numbering and navigation when the global artifacts intentionally track only folder-level or master-pack entries.

## 11. Mandatory Directory Artifact Rule

Any future folder creation, folder rename, folder merge, file move, or file renumbering must update, where applicable:

- active 000005 directory/document number index;
- active 000007 full directory/navigation map;
- folder-local Index;
- folder-local NavigationMap;
- parent index/tree;
- direct links; and
- affected H1s.

## 12. Forbidden Scope Compliance

- No SQL or migration file was intentionally modified by 604336.
- No 0069 Analysis or correction was created.
- No replay verification was run.
- 604300 master-pack files, 604341-604344, 604329-604335, and 604400 files were not renumbered.
- 604250 was not resumed and 604260 was not closed.
- Stale 000005/000007 files were not deleted.
- 604337 Verification and 604338 Audit were not created.

## 13. Self-Check Results

- Exact rename mapping: passed.
- Renamed H1-to-filename match: passed.
- 604351/604355 absence: passed.
- Direct old filename-prefix scan: no active stale reference.
- Active old folder-path scan: historical/pre-merge narrative only.
- 604300 Index correction: passed.
- 604306 replay-recovery lane addition: passed.
- Stale forwarding and active canonical artifact check: passed.
- `git diff --check`: required after document creation.

## 14. Verification Required

604337 Verification by Cursor / Local Verification Runner must independently verify filenames, H1s, references, folder maps, Index/NavigationMap content, stale forwarding behavior, and the SQL/migration no-touch boundary.

## 15. Next Step

Proceed to 604337 Verification. Keep 0069 analysis and replay work deferred until this artifact correction is verified and independently audited.
