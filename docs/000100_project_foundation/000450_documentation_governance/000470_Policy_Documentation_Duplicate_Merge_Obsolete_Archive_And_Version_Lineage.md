# 000470_Policy_Documentation_Duplicate_Merge_Obsolete_Archive_And_Version_Lineage

## 1. Purpose

This document defines the duplicate detection, merge decision, obsolete marking, archive handling, replacement tracking, and version lineage policy for the Yoonsul Wait/Order Handoff documentation corpus.

The project will generate a large number of Markdown documents before implementation.

Because many documents will be created through mobile drafting, Google Docs temporary storage, PC import, AI-assisted review, and folder restructuring, duplicate or overlapping documents are expected.

Duplicates are not always errors.

Some duplicates are early drafts, some are narrower SOP versions, some are implementation mappings, and some are legitimate successor documents.

Therefore, duplicate handling must preserve important constraints while preventing implementation confusion.

---

## 2. Scope

This policy applies to:

- duplicate document detection
- overlapping policy detection
- near-duplicate title review
- same document number conflict
- same topic with different document number
- mobile draft duplication
- Google Docs repeated import
- policy and SOP overlap
- policy and implementation mapping overlap
- readiness checklist overlap
- merged document handling
- obsolete document marking
- archive folder usage
- replacement lineage
- cross-reference update
- index synchronization
- directory map synchronization
- implementation safety review

This document does not define the final archive tooling.

It defines the governance rules for keeping the document corpus clean enough for implementation.

---

## 3. Core Principle

A duplicate must not silently remain as an active source of truth.

The project must follow this rule:

> Duplicate documents may exist during drafting, but only one active source of truth may guide implementation for the same policy scope.

If duplicates remain active, AI tools and developers may follow the wrong version.

---

## 4. Duplicate Definition

A duplicate exists when two or more documents share:

- same document number
- same or nearly same title
- same purpose
- same policy scope
- same SOP scope
- same implementation mapping scope
- same readiness gate scope
- same evidence register scope
- same test catalog scope
- same document body with minor wording changes

Duplicate detection must consider meaning, not only filename.

---

## 5. Overlap Definition

Overlap exists when documents are not exact duplicates but cover related scope.

Examples:

- one document defines payment boundary
- another defines refund SOP
- another defines payment implementation mapping
- another defines payment test catalog

This is not a duplicate if each document has a different role.

Overlap becomes a problem when two documents give conflicting or redundant active instructions for the same role and same scope.

---

## 6. Same Number Conflict Rule

If two documents use the same number, this is a critical documentation conflict.

Resolution steps:

1. Compare filenames.
2. Compare H1 titles.
3. Compare body content.
4. Determine whether one is accidental duplicate.
5. Determine whether both are valid but different.
6. Keep one number for the intended original document.
7. Assign a new number to the other valid document if needed.
8. Mark obsolete or merged document where applicable.
9. Update index.
10. Update directory map.
11. Update cross-references.

Two active documents must not share the same document number.

---

## 7. Same Title Conflict Rule

If two documents have same or near-same title, review is required.

Possible outcomes:

- exact duplicate
- earlier draft and final version
- policy and SOP pair
- policy and mapping pair
- index and readiness pair
- same topic but different lane
- one should be renamed
- one should be merged
- one should be archived

Same title does not always mean deletion.

But it must not remain ambiguous.

---

## 8. Same Topic Different Type Rule

Some documents may cover the same topic but must remain separate because they serve different functions.

Example valid set:

- Payment Boundary Policy
- Payment Refund SOP
- Payment Webhook Implementation Mapping
- Payment Security Test Catalog
- Payment Evidence Register
- Payment Readiness Check

These are not duplicates if their document type is clear.

Document titles must make the type difference visible.

---

## 9. Policy Versus SOP Distinction

Policy documents define rules, boundaries, and prohibitions.

SOP documents define step-by-step operational actions.

A document should be marked as duplicate or weak if:

- a SOP only repeats policy without operational steps
- a policy contains detailed operator steps without boundary framing
- a SOP contradicts its policy
- a policy and SOP both claim to be final authority for the same action

If both are needed, keep both and clarify references.

---

## 10. Policy Versus Implementation Mapping Distinction

Policy documents define what must be true.

Implementation mapping documents define how policy maps to schema, API, RPC, UI, audit, masking, tests, and evidence.

A mapping document is weak if it merely repeats policy.

A policy document is weak if it jumps into code-level details before implementation phase.

If overlap exists, split or clarify:

- policy stays as rule
- mapping becomes bridge to implementation

---

## 11. Readiness Checklist Duplication Rule

Readiness checklists often repeat across documents.

This is acceptable when the checklist is scoped to the document.

It becomes problematic when:

- multiple readiness documents claim the same gate
- readiness questions are identical across unrelated lanes
- a readiness document does not add new decision value
- an index readiness check conflicts with lane readiness check

Duplicate readiness checks should be consolidated or clarified.

---

## 12. Mobile Draft Duplicate Risk

Mobile drafting increases duplicate risk.

Duplicates may happen because:

- same document was generated twice
- Google Docs draft was imported twice
- a temporary title was later forgotten
- number sequence resumed incorrectly
- folder name changed and file was copied again
- AI generated similar document in another lane
- user requested next document after a closure document

Mobile duplicates are expected.

They must be caught during PC import and index review.

---

## 13. Duplicate Detection Methods

Duplicate detection may use:

- document number scan
- filename scan
- H1 title scan
- first paragraph similarity
- Purpose section similarity
- Scope section similarity
- repeated section headings
- repeated conclusion text
- index comparison
- Google Docs imported marker review
- Cursor or AI-assisted similarity review
- manual lane review

No single method is enough.

---

## 14. Duplicate Review Categories

Duplicate candidates should be classified as:

- `EXACT_DUPLICATE`
- `EARLIER_DRAFT`
- `FINAL_VERSION`
- `NEAR_DUPLICATE`
- `OVERLAP_POLICY`
- `OVERLAP_SOP`
- `OVERLAP_MAPPING`
- `TITLE_CONFLICT`
- `NUMBER_CONFLICT`
- `LANE_MISMATCH`
- `MERGE_CANDIDATE`
- `ARCHIVE_CANDIDATE`
- `KEEP_BOTH_WITH_CLARIFICATION`

Classification must guide action.

---

## 15. Duplicate Decision Options

Possible decisions:

- keep active
- rename
- move folder
- merge
- archive
- mark obsolete
- split into policy and SOP
- split into policy and mapping
- assign new document number
- update index only
- keep both with clarified scope
- defer decision with reason

Deletion should not be the first option unless the document is clearly accidental or empty.

---

## 16. Merge Decision Rule

Merge is appropriate when:

- two documents cover same scope
- one contains useful missing sections
- neither should remain separate
- active source of truth should be unified
- cross-references would be clearer
- implementation would be confused by both

Merge must preserve important constraints.

Merge must not delete stronger security rule accidentally.

---

## 17. Merge Procedure

Recommended merge procedure:

1. Identify source documents.
2. Identify active target document.
3. Compare section by section.
4. Preserve stronger policy where conflict exists.
5. Preserve unique readiness questions.
6. Preserve unique prohibited actions.
7. Preserve unique evidence requirements.
8. Remove redundant wording.
9. Update H1 title if needed.
10. Mark old document as merged.
11. Update index.
12. Update cross-references.
13. Update directory map if folder changes.
14. Record merge decision.

Merge must produce one clearer active document.

---

## 18. Stronger Rule Preservation

When merging security or governance documents, the stricter rule should usually prevail.

Examples:

- if one document says masking optional and another says masking required, masking required prevails
- if one allows support access broadly and another requires case scope, case scope prevails
- if one allows replay mutation and another prohibits mutation, replay must not mutate
- if one allows export and another restricts CI / DI export, CI / DI remains restricted
- if one allows AI input and another prohibits secrets, secrets remain prohibited

Security weakening requires explicit review.

---

## 19. Obsolete Document Definition

A document is obsolete when it should no longer guide future work.

A document may become obsolete because:

- replaced by newer version
- merged into another document
- wrong lane
- wrong architecture assumption
- duplicate imported by mistake
- superseded by final index
- temporary mobile draft
- abandoned implementation path
- old folder structure no longer valid

Obsolete does not always mean delete.

Obsolete means not active authority.

---

## 20. Obsolete Marking Rule

An obsolete document must be clearly marked.

Possible marking methods:

- index status `OBSOLETE`
- file moved to archive folder
- top-of-file note
- replacement reference
- merged-to reference
- directory map update
- cross-reference update

Obsolete documents must not remain indistinguishable from active documents.

---

## 21. Archive Folder Rule

Obsolete or historical documents may be moved to archive.

Recommended archive path:

    docs/_archive_obsolete/

Archive folder may contain:

- obsolete drafts
- replaced policies
- merged documents
- wrong-lane documents kept for traceability
- old indexes
- old directory maps
- outdated roadmap drafts

Archive folder must not be used as active implementation source.

---

## 22. Archive File Naming Rule

Archived files should preserve original identity.

Recommended pattern:

    {original_filename}

or:

    {document_number}_{title}_OBSOLETE.md

or:

    {document_number}_{title}_MERGED_TO_{target_number}.md

The archive name should show why it is archived where practical.

---

## 23. Top-Of-File Obsolete Notice

Archived or obsolete documents may include a top notice.

Recommended notice format:

    OBSOLETE DOCUMENT
    Status: OBSOLETE
    Replaced by: 047xx Target Document Title
    Reason: Merged during documentation normalization.
    Date: YYYY-MM-DD

This makes accidental use less likely.

---

## 24. Replacement Lineage Rule

When a document replaces another, lineage must be recorded.

Lineage should include:

- old document number
- old title
- new document number
- new title
- reason for replacement
- date of replacement
- whether old content was merged
- whether old document is archived

Lineage helps future review understand why a document disappeared.

---

## 25. Version Lineage Rule

Some documents may evolve through versions.

Version lineage may be needed when:

- policy changed significantly
- security rule changed
- implementation gate changed
- folder structure changed
- document number changed
- legal/compliance meaning changed
- incident caused policy revision
- architecture changed

Version lineage must preserve why the change happened.

---

## 26. Versioning Style

The project may use simple version notes rather than formal semantic versioning.

Possible fields:

- status
- version
- updated date
- change reason
- previous document
- replacement document
- related incident or gap

Example:

    Status: ACTIVE
    Version: v1.1
    Updated: YYYY-MM-DD
    Change Reason: Added export masking requirement after coverage review.

Version notes are optional for all documents, but recommended for high-risk policy changes.

---

## 27. Active Source Of Truth Rule

For each policy scope, there must be one active source of truth.

Examples:

- one active payment boundary policy
- one active CI / DI protection policy
- one active POS/KDS RPC boundary policy
- one active support access policy
- one active audit immutability policy
- one active mobile import workflow policy

Supporting documents may exist, but the active source must be clear.

---

## 28. Supporting Document Rule

Supporting documents may include:

- SOP
- implementation mapping
- test catalog
- evidence register
- readiness check
- index
- training matrix

Supporting documents must reference the active policy source.

They must not silently redefine the policy.

---

## 29. Conflict Resolution Rule

If two active documents conflict:

1. Identify both documents.
2. Identify conflict type.
3. Determine which document is higher-level.
4. Determine which document is newer or more specific.
5. Prefer stricter security rule for security conflicts.
6. Update one or both documents.
7. Record decision in index or review note.
8. Update cross-references.

Conflict must not remain unresolved before implementation.

---

## 30. Duplicate Review Report Format

Duplicate review report should include:

- report date
- reviewed folders
- duplicate candidate id
- document A number and title
- document B number and title
- conflict type
- similarity reason
- recommended action
- risk level
- implementation impact
- owner or reviewer
- status

Reports help batch cleanup.

---

## 31. Cursor-Assisted Duplicate Review

Cursor or AI may assist duplicate review.

Allowed tasks:

- find duplicate numbers
- find similar titles
- compare Purpose sections
- compare Scope sections
- identify repeated section headings
- suggest merge candidates
- suggest rename candidates
- suggest obsolete candidates
- identify likely policy/SOP confusion
- identify likely policy/mapping confusion

Cursor must not delete, merge, or rewrite files automatically without explicit instruction.

---

## 32. Cursor Prompt For Duplicate Review

Recommended prompt:

    TASK:
    Review the Markdown documentation corpus for duplicate, overlapping, obsolete, and merge-candidate documents.
    Do not implement code.
    Do not delete files.
    Do not rewrite document bodies.
    Return:
    1. duplicate document numbers
    2. similar or duplicate titles
    3. near-duplicate policy bodies
    4. policy/SOP overlap candidates
    5. policy/mapping overlap candidates
    6. obsolete or replaced candidates
    7. recommended keep/merge/archive/rename decisions
    8. risk if both remain active

This keeps review safe.

---

## 33. Merge Commit Rule

Large merge cleanup should be committed separately from content expansion.

Recommended commit separation:

- import mobile drafts
- normalize filenames
- update index
- merge duplicates
- archive obsolete files
- update cross-references
- update directory map

Mixing merge cleanup with new document creation makes review harder.

---

## 34. Obsolete Retention Rule

Obsolete documents may be retained temporarily.

Retention is useful when:

- document history may matter
- policy evolution is still unstable
- replacement document is newly created
- cross-reference cleanup is not finished
- user may need to compare drafts
- legal or compliance reasoning may matter later

Obsolete documents can be deleted later only after review.

---

## 35. Deletion Warning

Deleting documentation should be done carefully.

Before deletion, confirm:

- document is not active
- document is not referenced
- document is not needed for history
- document is not part of patent evidence
- document is not part of compliance reasoning
- document was not the only source of a constraint
- index and directory map are updated
- deletion is intentional

Archiving is safer than immediate deletion during early documentation phase.

---

## 36. Patent And IP Caution

Some documents may later support patent, BM, or IP reasoning.

Before merging or deleting documents related to invention concepts:

- preserve original concept wording if important
- preserve date/order where meaningful
- avoid deleting unique problem-solution framing
- keep obsolete drafts if they show evolution
- mark as historical rather than deleting where uncertain

Documentation cleanup must not accidentally erase useful invention history.

---

## 37. Implementation Safety Rule

Before implementation begins, active documents must be clear.

Implementation must not proceed if:

- duplicate active policies exist for same authority boundary
- payment rules conflict
- CI / DI handling conflicts
- POS/KDS authority conflicts
- support masking conflicts
- audit immutability conflicts
- tenant/store isolation conflicts
- degraded recovery merge rules conflict
- export authority conflicts
- AI authority conflicts
- vendor access rules conflict

Unresolved duplicate conflict is an implementation blocker.

---

## 38. Duplicate Cleanup Checklist

Before closing duplicate cleanup, confirm:

- duplicate numbers are resolved
- same-title conflicts are reviewed
- near-duplicate policies are reviewed
- policy/SOP overlaps are clarified
- policy/mapping overlaps are clarified
- obsolete documents are marked
- merged documents point to active target
- archive folder is updated
- index statuses are updated
- directory map is updated where needed
- cross-references are updated
- active source of truth is clear
- implementation blockers are recorded

If any item fails, duplicate cleanup is incomplete.

---

## 39. Non-Goals

This document does not define:

- final version control tool
- final automated duplicate detector
- final archive retention period
- final deletion approval workflow
- final semantic versioning scheme
- final patent evidence archive rule
- final legal document retention policy
- final documentation dashboard
- final merge automation script

Those must be defined later if needed.

---

## 40. Readiness Check

This policy is ready when the project can answer:

1. What counts as a duplicate?
2. What counts as overlap?
3. What happens when two documents have same number?
4. What happens when two documents have similar title?
5. How are policy and SOP distinguished?
6. How are policy and implementation mapping distinguished?
7. When should documents be merged?
8. How is stronger security rule preserved?
9. What makes a document obsolete?
10. How is obsolete status marked?
11. Where are obsolete documents archived?
12. How is replacement lineage recorded?
13. What is the active source of truth?
14. How are conflicts resolved?
15. How does Cursor assist duplicate review?
16. What must Cursor not do?
17. Why is archive safer than deletion?
18. What patent/IP caution applies?
19. What duplicate conflicts block implementation?
20. What checklist closes duplicate cleanup?

If these questions cannot be answered, duplicate and archive governance is incomplete.

---

## 41. Conclusion

Large-scale documentation-first work will inevitably create duplicate, overlapping, and obsolete documents.

That is acceptable during drafting.

It becomes dangerous only if those documents remain active without review.

The Yoonsul Wait/Order Handoff project must preserve the following rules:

- duplicate documents must be detected
- same document number conflicts must be resolved
- same title conflicts must be reviewed
- policy, SOP, mapping, test, and evidence documents must be distinguished
- merge must preserve important constraints
- stricter security rule should prevail unless explicitly revised
- obsolete documents must be marked
- archive is safer than immediate deletion
- replacement lineage must be recorded
- active source of truth must be clear
- cross-references must be updated
- Cursor may detect but must not delete or merge automatically
- patent and IP reasoning must be preserved where relevant
- unresolved duplicate conflicts block implementation

A documentation corpus becomes implementation-safe only when the project knows which document is active, which is historical, and which one the code must obey.