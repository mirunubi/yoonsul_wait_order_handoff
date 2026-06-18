# 014038_Policy_PC_Documentation_Import_Mobile_Inbox_Cleanup

## 1. Purpose

This document defines the PC-side documentation import, mobile inbox cleanup, filename normalization, folder placement, index update, duplicate detection, cross-reference review, and documentation readiness workflow policy for the Yoonsul Wait/Order Handoff documentation project.

The previous document defined the mobile Obsidian Git draft capture workflow.

This document defines what must happen after mobile-created Markdown files are pulled into the PC environment.

The PC becomes the structural control point.

Mobile produces drafts.

PC normalizes, indexes, reviews, and prepares the documentation set for future implementation.

This document does not create scripts, move files, run automation, or implement a documentation toolchain.

It defines PC import and normalization policy only.

---

## 2. Scope

This document covers:

- PC git pull workflow
- mobile inbox review
- document completeness check
- filename normalization
- folder placement
- index update
- README update
- numbering review
- duplicate detection
- superseded document handling
- cross-reference review
- commit discipline
- no-implementation boundary

This document does not cover:

- final automation script
- final folder tree generator
- final Markdown linter
- final CI validation
- final documentation publishing
- final implementation planning
- final code generation
- final SQL or Flutter changes

---

## 3. Core Principle

PC import must turn mobile drafts into repository-controlled documentation.

The project must follow this rule:

> Mobile drafts are production input. PC import converts them into structured, indexed, traceable project documents.

A document is not fully repository-ready until it is placed, named, indexed, and checked.

---

## 4. PC Import Role

PC import is responsible for:

- pulling latest mobile commits
- reviewing newly added Markdown files
- detecting incomplete documents
- detecting duplicate document numbers
- detecting duplicate topics
- normalizing filenames
- moving documents to correct folder cluster
- updating index files
- updating README or directory map where needed
- preserving document lineage
- committing normalized changes
- pushing final structure back to GitHub

PC is the structural authority.

---

## 5. Recommended Import Flow

Recommended PC import flow:

    1. git pull
    2. inspect mobile draft folder
    3. verify new files
    4. check document numbers
    5. check document titles
    6. check completeness
    7. check for accidental chat commentary
    8. check for secrets
    9. decide folder destination
    10. move files
    11. normalize filenames
    12. update index
    13. update cross-references if needed
    14. commit
    15. push

This flow may be batched.

---

## 6. Mobile Inbox Folder

Recommended temporary mobile inbox:

    docs/_mobile_inbox/

Alternative:

    docs/mobile_drafts/

The mobile inbox is a temporary landing area.

It should not become a permanent archive.

PC should periodically empty or reduce the mobile inbox by moving documents into final folders.

---

## 7. PC Import Status Values

Recommended import status values:

- `NOT_IMPORTED`
- `PULLED_TO_PC`
- `INBOX_REVIEWED`
- `FILENAME_NORMALIZED`
- `FOLDER_ASSIGNED`
- `INDEX_UPDATED`
- `DUPLICATE_CHECKED`
- `SECRET_CHECKED`
- `CROSS_REFERENCE_CHECKED`
- `COMMITTED`
- `ARCHIVED`
- `SUPERSEDED`

These statuses may be tracked later in an index or review file.

---

## 8. Document Completeness Check

Each imported document must be checked for completeness.

Checklist:

1. file is not empty
2. file begins with one H1 title
3. H1 includes document number
4. H1 title matches file title
5. document has Purpose section
6. document has Scope section
7. document has Core Principle or equivalent
8. document has Non-Goals where appropriate
9. document has Readiness Check
10. document has Conclusion
11. document does not end abruptly
12. document does not include chat intro
13. document does not include accidental duplicate paste
14. document does not include unrelated text
15. document does not include secrets

Incomplete documents should be marked for review.

---

## 9. Filename Normalization Rule

Filename should follow:

    [NUMBER]_[English_Title_With_Underscores].md

Example:

    05480_PC_Documentation_Import_Normalization_Index_And_Mobile_Inbox_Cleanup_Policy.md

Rules:

- number must be first
- title should match H1
- use underscores
- avoid spaces
- avoid special characters where possible
- use .md extension
- no duplicate filename
- no vague names such as draft.md or next.md

Filename is part of document identity.

---

## 10. Numbering Review

PC import must check numbering.

Check:

- no duplicated number
- no missing expected number unless intentional
- inserted numbers are recorded
- superseded numbers are marked
- number sequence remains understandable
- related documents remain clustered
- future gap is preserved where useful

Numbering is more important than perfect folder placement during early drafting.

---

## 11. Folder Placement Rule

Documents should be moved from mobile inbox to the most appropriate folder cluster.

Possible clusters:

    docs/04000_pos_kds_security/
    docs/04700_documentation_governance/
    docs/04800_implementation_mapping/
    docs/04900_test_catalog/
    docs/05000_provider_integration_and_kiosk_reuse/
    docs/05400_saas_pilot_pricing_and_mobile_workflow/
    docs/_index/

Final folder names may be normalized later.

Folder placement should follow topic cluster, not only number range.

---

## 12. Folder Assignment Criteria

Assign folder by primary document purpose.

Examples:

| Document Type | Likely Folder |
| ------------- | ------------- |
| Security policy | 04000 security cluster |
| Documentation workflow | documentation governance cluster |
| Implementation mapping | implementation mapping cluster |
| Test catalog | test catalog cluster |
| Provider / POS / Kiosk | provider integration cluster |
| SaaS pricing / pilot | SaaS pilot and pricing cluster |
| Mobile Obsidian / Git workflow | documentation governance or mobile workflow cluster |
| Index / readiness | index cluster or relevant cluster |

If unclear, place in a review folder and decide later.

---

## 13. Mobile Inbox Cleanup Rule

Mobile inbox cleanup should occur after:

- file is reviewed
- destination folder is decided
- filename is normalized
- index entry is added
- duplicate check is complete
- commit is ready

The mobile inbox should not contain already-sorted files.

If a file remains in inbox, reason should be clear.

---

## 14. Index Update Rule

Index must be updated after moving documents.

Index entry should include:

- document number
- document title
- file path
- cluster
- status
- short purpose
- related documents if needed

Index may be simple at first.

Example:

    05480 PC Documentation Import Normalization Index And Mobile Inbox Cleanup Policy
    Path: docs/05400_saas_pilot_pricing_and_mobile_workflow/
    Status: Draft
    Purpose: PC import and mobile inbox normalization workflow.

Index quality can improve over time.

---

## 15. Cluster README Update Rule

If a cluster README exists, update it when:

- new document is added
- document order changes
- major topic is introduced
- superseded document appears
- folder purpose changes
- readiness state changes

README should help future reviewers understand the folder.

README does not need to be perfect during rapid drafting, but must not become misleading.

---

## 16. Cross-Reference Review

Cross-reference review should check:

- previous document mentions correct next document
- document refers to related policies correctly
- superseded docs are identified
- provider strategy docs align
- SaaS pricing docs align
- pilot docs align
- mobile workflow docs align
- no broken internal path claims
- no outdated folder path instruction remains unmarked

Cross-reference cleanup may be deferred if batch is large, but must be tracked.

---

## 17. Duplicate Detection

Duplicate detection should check:

- duplicate document number
- duplicate title
- duplicate purpose
- repeated policy under different number
- superseded content not marked
- copied document accidentally pasted twice
- mobile/Google Docs duplicate version
- old draft and normalized draft both active

Duplicates should be resolved by:

- merge
- mark superseded
- archive
- rename
- split
- keep both with clear distinction

Do not silently delete without review.

---

## 18. Superseded Document Handling

A document may become superseded when:

- provider strategy changed
- MVP cutline changed
- numbering corrected
- better document replaced it
- duplicate was merged
- scope moved to another cluster
- policy was split into multiple documents

Superseded document should be marked, not silently erased.

Recommended marker:

    Status: Superseded
    Superseded By: [Document Number And Title]
    Reason: [Short reason]

Later PC cleanup may archive it.

---

## 19. Archive Rule

Archive may be used for:

- obsolete drafts
- duplicate drafts
- replaced Google Docs imports
- partial mobile captures
- failed paste documents
- old strategy versions preserved for lineage

Archive folder may be:

    docs/_archive/

or cluster-specific:

    docs/05000_provider_integration_and_kiosk_reuse/_archive/

Archive should not be used to hide active uncertainty.

---

## 20. Secret And Sensitive Data Check

PC import must check that documents do not contain:

- GitHub token
- Supabase service role key
- SSH private key
- Toss secret key
- PAYCO secret
- OKPOS credential
- payment provider secret
- webhook secret
- raw CI/DI
- raw card data
- customer personal data
- staff private data
- production database password
- local environment secret

If secret is found:

1. stop normal commit if not already committed
2. remove secret
3. rotate credential if exposed
4. create incident note if needed
5. avoid pushing secret to remote

Secret safety is mandatory.

---

## 21. Commit Discipline

PC import commit should be meaningful.

Good examples:

    docs: import mobile workflow policies
    docs: organize saas pilot policy drafts
    docs: normalize provider integration mobile drafts
    docs: update index for mobile imported policies

Avoid:

    update
    fix
    docs
    mobile stuff
    cleanup maybe

Commit message should explain the batch.

---

## 22. Recommended PC Import Commit Types

Recommended commit categories:

- `docs: import mobile drafts`
- `docs: normalize filenames`
- `docs: move provider docs`
- `docs: update index`
- `docs: archive duplicate drafts`
- `docs: mark superseded policies`
- `docs: add mobile workflow policies`
- `docs: organize saas pilot docs`

Commit categories help later history review.

---

## 23. Batch Size Rule

PC import may process documents in batches.

Recommended batch:

- 5 to 20 documents per normalization commit
- smaller batch if files are complex
- larger batch if only new files and straightforward moves
- separate commit for archive/superseded cleanup
- separate commit for large index rewrite

Do not mix unrelated implementation changes with documentation import.

---

## 24. PC Review Checklist

Before PC commit, check:

1. git status reviewed
2. new files identified
3. moved files intentional
4. deleted files intentional
5. filenames normalized
6. document numbers unique
7. headings match filenames
8. secrets absent
9. obvious duplicate absent
10. index updated or update deferred with note
11. README update considered
12. commit message prepared
13. no code files accidentally staged
14. no environment files staged
15. no temporary local files staged

This protects the repository.

---

## 25. Handling Google Docs Legacy Imports

Existing Google Docs content may be imported later.

Rules:

- import one document per .md file
- preserve document number
- preserve original title
- remove Google Docs formatting artifacts
- remove chat commentary
- compare with existing mobile version
- mark duplicate or superseded if needed
- add to index
- do not mix legacy import with active mobile capture unless necessary

Google Docs becomes legacy source, not primary source.

---

## 26. Handling Partial Mobile Captures

Partial mobile captures may occur when:

- app crashed
- paste failed
- document copied incompletely
- network interrupted
- user saved mid-generation
- file duplicated accidentally

Partial capture handling:

- mark file as partial
- recover from chat if possible
- regenerate if necessary
- do not place as final doc
- do not index as ready
- avoid deleting until replacement exists

Recommended marker:

    Status: Partial Draft
    Completion Required: Yes

---

## 27. Handling Out-Of-Order Documents

Mobile may produce documents out of order.

Allowed:

- numbering remains primary
- folder placement can occur later
- index can sort numerically
- next document sequence can continue
- inserted docs can be handled with intermediate numbers

Out-of-order production is acceptable if index catches up.

---

## 28. Handling Topic Drift

A mobile-produced document may drift from expected topic.

PC should classify:

- keep as-is
- rename title
- split into two documents
- move to different cluster
- mark as strategy note
- defer as future candidate
- merge with related document

Do not force wrong folder just because of number.

---

## 29. Handling Long Documents

Long documents should be reviewed for:

- section duplication
- abrupt ending
- repeated heading
- missing conclusion
- table breakage
- unintentional nested code block
- mobile paste truncation
- inconsistent terminology

Long documents may require PC-side cleanup before indexing as ready.

---

## 30. Handling Tables

Markdown tables should be checked for:

- header separator row
- consistent columns
- no broken pipes
- no accidental line wrap inside table
- readable on Obsidian
- readable on GitHub
- no secret in table cells

Tables often break during mobile paste.

PC should verify important tables.

---

## 31. Handling Internal Paths

Documents may include future path recommendations.

PC should verify:

- path does not conflict with actual repo
- path is marked as recommendation if not created
- path does not imply folder already exists
- path aligns with current cluster strategy
- path does not reference wrong project

If path is provisional, document should say so.

---

## 32. Handling English/Korean Boundary

Project docs generally use:

- Korean chat intro outside file
- English document body inside .md
- English filename
- English H1 title
- Korean notes only when intentionally part of strategy or local operation context

PC should remove accidental Korean chat intro from core policy files.

Korean can remain in separate notes or strategy files if intentionally authored.

---

## 33. Handling Copy Fence Artifacts

Mobile capture must not include outer chat code fences.

PC should remove accidental artifacts such as:

    ```markdown
    ```

if they became part of the saved file.

The .md file should contain the Markdown document itself, not a fenced code block wrapping the entire document.

---

## 34. Handling IDs And UI Text

Chat UI artifacts should not be saved.

Remove:

- code block id attributes
- copy button text
- UI labels
- assistant commentary
- generated response labels
- sandbox links unless intentionally part of document
- citation artifacts not relevant to document

The policy document should be clean Markdown.

---

## 35. Import Review Record

For larger batches, create an import review note.

Recommended fields:

    Import Batch ID:
    Date:
    Source:
    Files Imported:
    Files Moved:
    Files Renamed:
    Files Indexed:
    Duplicates Found:
    Superseded Docs:
    Archive Actions:
    Missing Items:
    Secret Check:
    Next Actions:
    Reviewer:

This can be added later if needed.

---

## 36. Future Automation Candidate

Future automation may include:

- mobile inbox scanner
- filename normalizer
- H1/title validator
- duplicate number checker
- duplicate title checker
- index generator
- README updater
- secret scanner
- path checker
- markdown table checker
- broken cross-reference detector
- import review report generator

Automation is deferred.

Manual PC import discipline comes first.

---

## 37. Anti-Patterns

The following are prohibited:

- leaving mobile inbox unmanaged indefinitely
- moving files without checking duplicate numbers
- renaming files without preserving document number
- deleting duplicates without review
- committing secrets
- committing chat commentary inside docs
- mixing code changes with documentation import
- relying on filename only without checking H1
- indexing incomplete documents as ready
- ignoring superseded documents
- letting Google Docs and Obsidian versions diverge silently
- editing the same document on PC and mobile without sync
- using PC import as a place for uncontrolled implementation changes

---

## 38. Non-Goals

This document does not define:

- final directory tree
- final index file format
- final automation script
- final CI validation
- final Markdown linting standard
- final publication pipeline
- final implementation plan
- final code generation process

Those belong to later documentation operations.

---

## 39. Readiness Check

This document is ready when the project can answer:

1. What is PC import responsible for?
2. What is the recommended import flow?
3. What is mobile inbox?
4. What status values exist?
5. How is document completeness checked?
6. How is filename normalized?
7. How is numbering reviewed?
8. How is folder placement decided?
9. How is mobile inbox cleaned?
10. How is index updated?
11. How is README updated?
12. How are cross-references reviewed?
13. How are duplicates detected?
14. How are superseded documents handled?
15. How is archive used?
16. How are secrets checked?
17. What commit discipline applies?
18. What batch size is recommended?
19. How are Google Docs legacy imports handled?
20. How are partial mobile captures handled?
21. How are out-of-order documents handled?
22. How are long documents and tables checked?
23. How are code fence artifacts removed?
24. What future automation candidates exist?
25. What anti-patterns are prohibited?

If these questions cannot be answered, PC documentation import and mobile inbox cleanup planning is incomplete.

---

## 40. Conclusion

Mobile Obsidian and Git allow fast Markdown production.

PC import makes that production structurally reliable.

The correct flow is:

    Mobile Obsidian draft
        -> mobile Git push
        -> PC git pull
        -> mobile inbox review
        -> filename normalization
        -> folder placement
        -> index update
        -> duplicate and secret check
        -> commit and push

This document ensures that mobile-generated policy documents become clean, indexed, traceable repository documents without slowing down document production.