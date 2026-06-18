# 000468_Policy_Documentation_Index_Directory_Map_And_Cross_Reference_Synchronization

## 1. Purpose

This document defines the index synchronization, directory map synchronization, cross-reference management, broken reference detection, and navigation governance policy for the Yoonsul Wait/Order Handoff documentation corpus.

The project will generate a large number of Markdown documents before implementation.

A large document corpus becomes useful only when documents can be found, trusted, traced, and connected.

Therefore, index files, directory maps, and cross-references must be maintained as first-class documentation controls.

---

## 2. Scope

This policy applies to:

- document number index
- document title index
- lane index
- folder index
- readiness index
- security foundation index
- SOP index
- implementation mapping index
- test catalog index
- evidence register index
- directory map
- folder purpose description
- document cross-references
- broken reference detection
- renamed file synchronization
- moved file synchronization
- obsolete document synchronization
- merged document synchronization
- mobile draft import synchronization
- Cursor-assisted index verification

This document does not define the final index file format.

It defines the synchronization rules that must apply as the document corpus grows.

---

## 3. Core Principle

A document is not fully governed until it is indexed and reachable.

The project must follow this rule:

> A Markdown file that exists in the repository but is missing from the index or directory map is not yet fully controlled documentation.

Documents must not only exist.

They must be discoverable, correctly located, and connected to related documents.

---

## 4. Index Definition

An index is a controlled navigation document that lists active documents by number, title, lane, folder, status, and purpose.

An index may exist at several levels:

- global document index
- lane-specific index
- folder index
- security foundation index
- SOP index
- implementation mapping index
- readiness index
- test catalog index
- evidence register index

Indexes help humans and AI tools understand the documentation system.

---

## 5. Directory Map Definition

A directory map describes the folder structure of the documentation corpus.

The directory map should show:

- folder path
- folder purpose
- document number ranges
- major document types
- active lanes
- incoming draft folder
- archive folder
- implementation mapping folder
- SOP folder
- testing folder
- evidence folder
- index folder where applicable

Directory map answers where documents belong.

Index answers what documents exist.

Both are needed.

---

## 6. Cross-Reference Definition

A cross-reference is any document reference to another document.

Cross-reference may include:

- document number
- document title
- document family
- document range
- related policy
- related SOP
- related mapping
- related test catalog
- related evidence register
- related readiness check

Cross-references must remain accurate after rename, move, merge, or obsolete marking.

---

## 7. Global Index Rule

The project should maintain a global document index.

The global index should include:

- document number
- document title
- filename
- folder path
- lane
- document type
- status
- related documents where useful

The global index does not need to repeat full document content.

It should provide enough information to locate and understand each document.

---

## 8. Lane Index Rule

Each major lane may maintain its own lane index.

Lane index should include:

- lane name
- lane purpose
- document number range
- active documents
- missing documents
- duplicate candidates
- implementation blockers
- readiness status
- related lanes

Lane index helps determine whether a lane is implementation-ready.

---

## 9. Folder Index Rule

A folder may contain a local README or index when the folder grows large.

Folder index should explain:

- folder purpose
- document types in the folder
- document number range
- active documents
- deprecated or moved documents
- related folders
- implementation status

Folder index prevents folders from becoming unstructured document dumps.

---

## 10. Readiness Index Rule

Readiness index should track implementation readiness by lane.

Readiness index should include:

- lane
- required policies
- required SOPs
- required mappings
- required tests
- required evidence
- open blockers
- readiness status
- next required document

Readiness index is not merely a document list.

It is an implementation gate control.

---

## 11. Security Foundation Index Rule

Security foundation index should track all security baseline documents.

It should include:

- 04470~04700 security foundation documents
- continuation register
- open gap documents
- review SOP documents
- testing documents
- vulnerability documents
- training documents
- vendor documents
- implementation handoff references

Security foundation index must remain stable because future implementation will rely on it.

---

## 12. SOP Index Rule

SOP index should track operator-facing procedures.

SOP index should include:

- store staff SOPs
- manager SOPs
- owner SOPs
- support SOPs
- payment SOPs
- refund SOPs
- POS/KDS SOPs
- degraded recovery SOPs
- device lost SOPs
- incident SOPs
- export SOPs
- vendor incident SOPs
- training SOPs

SOP index should show which operational roles are covered and which remain missing.

---

## 13. Implementation Mapping Index Rule

Implementation mapping index should track all policy-to-code bridge documents.

Mapping index should include:

- schema mapping
- RLS mapping
- API mapping
- RPC mapping
- audit event mapping
- POS/KDS mapping
- payment webhook mapping
- local agent mapping
- support access mapping
- export mapping
- AI dataset mapping
- deployment mapping
- test mapping

Implementation mapping index is required before controlled implementation.

---

## 14. Test Catalog Index Rule

Test catalog index should track all security and operational test documents.

Test index should include:

- threat model catalog
- abuse case catalog
- tenant isolation tests
- store isolation tests
- CI / DI tests
- payment tests
- POS/KDS tests
- webhook tests
- idempotency tests
- replay tests
- degraded recovery tests
- support access tests
- device trust tests
- audit integrity tests
- export tests
- AI tests
- incident exercises

Test catalog index helps determine whether implementation can be verified.

---

## 15. Evidence Register Index Rule

Evidence register index should track all compliance and control evidence documents.

Evidence index should include:

- access evidence
- tenant isolation evidence
- store isolation evidence
- identity evidence
- payment evidence
- POS/KDS evidence
- degraded recovery evidence
- support evidence
- break-glass evidence
- secret rotation evidence
- deployment evidence
- export evidence
- AI evidence
- incident evidence
- vendor evidence

Evidence index supports compliance readiness.

---

## 16. Index Entry Status Values

Recommended index status values:

- `DRAFT`
- `ACTIVE`
- `NEEDS_REVIEW`
- `NEEDS_RENAME`
- `NEEDS_FOLDER_MOVE`
- `MISSING_CROSS_REFERENCE`
- `DUPLICATE_CANDIDATE`
- `MERGED`
- `OBSOLETE`
- `DEFERRED`
- `IMPLEMENTATION_BLOCKER`
- `READY_FOR_MAPPING`
- `READY_FOR_IMPLEMENTATION`

Index status must reflect actual document condition.

---

## 17. Directory Map Status Values

Recommended directory map status values:

- `STABLE`
- `EVOLVING`
- `NEEDS_REVIEW`
- `TEMPORARY`
- `TO_BE_SPLIT`
- `TO_BE_MERGED`
- `ARCHIVE`
- `INCOMING_ONLY`

Folder status helps prevent accidental reliance on unstable paths.

---

## 18. Cross-Reference Style Rule

Cross-references should prefer document number and title.

Recommended style:

    See 04551_Policy_Payment_Boundary_Refund_Correction_And_Settlement_Security.

Avoid relying only on file path during early documentation phase.

Path references may be added after folder structure stabilizes.

Document number and title are more stable than folder path.

---

## 19. Cross-Reference Required Cases

Cross-reference is required when a document depends on another document.

Required cases include:

- SOP depends on policy
- implementation mapping depends on policy
- test catalog depends on boundary document
- evidence register depends on audit policy
- readiness check depends on required documents
- incident runbook depends on incident policy
- payment mapping depends on payment policy
- POS/KDS mapping depends on POS/KDS boundary policy
- AI mapping depends on AI minimization policy
- vendor mapping depends on vendor access policy

Dependency should be visible.

---

## 20. Cross-Reference Avoidance Rule

Do not overuse cross-references.

Avoid cross-reference when:

- reference is obvious and not needed
- document would become unreadable
- folder structure is not stable
- referencing too many documents creates maintenance burden
- the target document is still temporary
- the target document is duplicate candidate

Cross-references should clarify dependency, not create noise.

---

## 21. Broken Reference Detection

A broken reference exists when:

- referenced document number does not exist
- referenced title does not match actual title
- referenced document was renamed and not updated
- referenced document was moved and path-specific link broke
- referenced document was merged or obsolete
- referenced range is wrong
- referenced policy conflicts with current policy

Broken references must be fixed before implementation mapping.

---

## 22. Rename Synchronization Rule

When a document is renamed, synchronize:

- global index
- lane index
- folder index
- directory map if path changes
- cross-references where title is included
- readiness index
- continuation register if tracked
- Google Docs imported marker where useful

Rename without synchronization creates navigation drift.

---

## 23. Move Synchronization Rule

When a document is moved to a new folder, synchronize:

- global index path
- folder index source and target
- directory map
- cross-references if path-specific
- lane assignment if changed
- continuation register if affected

Moving documents must not make them invisible.

---

## 24. Merge Synchronization Rule

When documents are merged:

1. Choose active document.
2. Mark old document status as `MERGED`.
3. Record target merged document number.
4. Update index.
5. Update directory map if folder changed.
6. Update cross-references to point to active document.
7. Preserve important constraints.
8. Remove duplicate from active readiness count.

Merged documents should not remain active blockers unless unresolved content remains.

---

## 25. Obsolete Synchronization Rule

When a document becomes obsolete:

1. Mark status as `OBSOLETE`.
2. Move to archive if appropriate.
3. Record replacement document if any.
4. Update index.
5. Update readiness matrix.
6. Remove from active implementation mapping.
7. Update cross-references.

Obsolete documents must not guide implementation.

---

## 26. Incoming Draft Synchronization Rule

Documents in incoming mobile draft folder must be tracked.

Incoming draft index should identify:

- document number
- temporary filename
- H1 title
- import source
- review status
- duplicate status
- proposed folder
- next action

Incoming drafts should not be invisible to the corpus.

---

## 27. Google Docs Synchronization Rule

Google Docs drafts should be marked after repository import.

Markers may include:

- `IMPORTED_TO_REPO`
- `IMPORTED_NEEDS_REVIEW`
- `DUPLICATE_CANDIDATE`
- `MERGED_TO_{document_number}`
- `OBSOLETE`
- `DEFERRED`
- `NOT_IMPORTED`

This prevents repeated import and duplicate generation.

---

## 28. Index Update Trigger

Index must be updated when:

- new document is added
- document is renamed
- document is moved
- document is merged
- document is marked obsolete
- document status changes
- folder is created
- folder is renamed
- lane assignment changes
- readiness status changes
- implementation blocker is found
- duplicate candidate is found

Index update is not optional for active documents.

---

## 29. Directory Map Update Trigger

Directory map must be updated when:

- new folder is created
- folder is renamed
- folder is merged
- folder is split
- document range changes
- folder purpose changes
- incoming folder is added
- archive folder is added
- implementation mapping folder is added
- SOP folder is added
- test folder is added
- evidence folder is added

Directory map must reflect reality.

---

## 30. Cross-Reference Update Trigger

Cross-references must be reviewed when:

- target document is renamed
- target document is moved with path-specific reference
- target document is merged
- target document is obsolete
- target document number changes
- target document scope changes
- dependent document is converted from policy to SOP
- implementation mapping references a new policy
- readiness gate changes required documents

Cross-reference review prevents outdated dependency chains.

---

## 31. Cursor-Assisted Index Review

Cursor or AI may assist index review.

Allowed tasks:

- compare file list to index
- detect missing index entries
- detect index entries with missing files
- detect filename and H1 mismatch
- detect duplicate document numbers
- detect duplicate titles
- detect broken references by number
- detect obsolete references
- suggest index updates
- suggest directory map updates

Cursor must not implement code or rewrite documents during index review unless explicitly instructed.

---

## 32. Cursor Prompt For Index Synchronization

Recommended prompt:

    TASK:
    Review the Markdown documentation repository.
    Do not implement code.
    Do not rewrite document bodies.
    Compare actual files against the global index, lane indexes, and directory map.
    Detect:
    1. files missing from index
    2. index entries with missing files
    3. filename and H1 mismatch
    4. duplicate document numbers
    5. duplicate or similar titles
    6. likely wrong folder placement
    7. broken document-number references
    8. obsolete references
    9. directory map mismatch
    Return a safe synchronization report only.

This keeps AI in verification mode.

---

## 33. Synchronization Report Format

A synchronization report should include:

- report date
- reviewed folders
- total files reviewed
- files missing from index
- index entries missing files
- duplicate numbers
- duplicate titles
- folder mismatch candidates
- broken references
- obsolete references
- directory map mismatches
- recommended rename actions
- recommended move actions
- recommended index updates
- recommended directory map updates
- unresolved blockers

Report must not rewrite files automatically unless requested.

---

## 34. Safe Update Order

Recommended safe update order:

1. Generate current file list.
2. Compare file list to global index.
3. Resolve duplicate numbers.
4. Resolve missing H1 or filename mismatch.
5. Assign lane and folder.
6. Update global index.
7. Update lane indexes.
8. Update directory map.
9. Review cross-references.
10. Mark obsolete or merged files.
11. Update continuation register.
12. Commit changes.

This order reduces confusion.

---

## 35. Index Drift Warning

Index drift occurs when files and index disagree.

Examples:

- file exists but index missing
- index lists file that no longer exists
- index title differs from file H1
- index path differs from actual path
- index status says active but file is obsolete
- index says ready but required mapping missing

Index drift must be corrected before implementation.

---

## 36. Directory Drift Warning

Directory drift occurs when folder structure and directory map disagree.

Examples:

- folder exists but map missing
- map lists folder that no longer exists
- folder purpose is outdated
- document range changed but map not updated
- archive folder contains active document
- incoming folder contains reviewed final document
- implementation mapping folder contains policy-only document

Directory drift must be corrected before implementation.

---

## 37. Cross-Reference Drift Warning

Cross-reference drift occurs when dependency references no longer match reality.

Examples:

- SOP references obsolete policy
- mapping references old title
- readiness check expects missing document
- test catalog references merged document
- evidence register references wrong audit policy
- policy refers to document number that was reused
- index points to inactive document as active requirement

Cross-reference drift can cause implementation mistakes.

---

## 38. Pre-Implementation Navigation Gate

Before implementation, navigation must be reliable.

Confirm:

- global index exists
- directory map exists
- high-risk lane indexes exist
- security foundation index exists
- implementation mapping index exists
- test catalog index exists
- SOP index exists where needed
- duplicate numbers are resolved
- obsolete documents are not active
- broken references are resolved or tracked
- implementation blockers are visible
- folder paths are stable enough

If navigation is unreliable, implementation remains deferred.

---

## 39. Synchronization Checklist

Before closing a PC-side import batch, confirm:

- new files are indexed
- moved files have updated paths
- renamed files have updated entries
- merged files are marked
- obsolete files are marked
- directory map reflects folder changes
- lane indexes are updated where applicable
- readiness index reflects new status
- cross-references are reviewed where required
- continuation register captures remaining gaps
- no duplicate number remains active

If any item fails, synchronization is incomplete.

---

## 40. Non-Goals

This document does not define:

- final index file name
- final directory map file name
- final automated index generator
- final cross-reference parser
- final documentation dashboard
- final CI validation script
- final folder taxonomy
- final document number allocation
- final implementation roadmap

Those must be defined later if needed.

---

## 41. Readiness Check

This policy is ready when the project can answer:

1. What is the global index?
2. What is the directory map?
3. What lane indexes are needed?
4. What status values are used in the index?
5. What status values are used for folders?
6. When must index be updated?
7. When must directory map be updated?
8. When must cross-references be reviewed?
9. How are renamed files synchronized?
10. How are moved files synchronized?
11. How are merged files synchronized?
12. How are obsolete files synchronized?
13. How are incoming drafts tracked?
14. How are Google Docs drafts marked?
15. How does Cursor assist synchronization?
16. What should a synchronization report include?
17. What is index drift?
18. What is directory drift?
19. What is cross-reference drift?
20. What navigation gate is required before implementation?

If these questions cannot be answered, index and directory synchronization governance is incomplete.

---

## 42. Conclusion

A documentation-first project depends on reliable navigation.

The Yoonsul Wait/Order Handoff project will generate many Markdown documents before implementation, but those documents must remain indexed, mapped, and cross-referenced.

The system must preserve the following rules:

- a file is not fully governed until indexed
- directory map must reflect real folder structure
- document number and title references are preferred early
- cross-references must remain accurate
- renamed files must update index
- moved files must update directory map
- merged files must be marked
- obsolete files must not guide implementation
- incoming drafts must be tracked
- Google Docs drafts must be marked after import
- Cursor may verify synchronization but must not implement
- synchronization reports must guide cleanup
- navigation must pass a gate before implementation

A large design corpus is useful only when the right document can be found at the right time, and trusted when implementation begins.