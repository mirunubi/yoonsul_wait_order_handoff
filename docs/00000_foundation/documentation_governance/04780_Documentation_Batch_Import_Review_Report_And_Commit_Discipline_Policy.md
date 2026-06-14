04780 Documentation Batch Import Review Report And Commit Discipline Policy

\#\# 1\. Purpose

This document defines the batch import, batch review report, commit discipline, import grouping, review checklist, and repository update policy for the Yoonsul Wait/Order Handoff documentation corpus.

The project will generate a large number of Markdown documents through mobile drafting and Google Docs temporary storage.

When those documents are moved to the PC repository, importing everything at once without batch discipline may create filename conflicts, duplicate numbers, folder drift, broken indexes, broken directory maps, and unclear commit history.

Therefore, document import must be handled in controlled batches.

\---

\#\# 2\. Scope

This policy applies to:

\- Google Docs to repository import
\- mobile Markdown draft import
\- incoming draft folder use
\- batch grouping
\- filename normalization
\- folder placement
\- index update
\- directory map update
\- duplicate review
\- obsolete and archive handling
\- cross-reference review
\- Cursor-assisted verification
\- commit grouping
\- pre-commit documentation checks
\- post-import review reports

This document does not define implementation commit strategy.

It defines documentation import and commit discipline before implementation begins.

\---

\#\# 3\. Core Principle

Large documentation movement must be reviewable.

The project must follow this rule:

\> Import, rename, move, merge, and index updates should be grouped so that each batch can be understood and reversed if needed.

A massive uncontrolled document import may appear productive, but it can destroy traceability.

\---

\#\# 4\. Batch Import Definition

A batch import is a controlled group of documents moved from temporary storage into the repository.

A batch may be grouped by:

\- document number range
\- documentation lane
\- Google Docs folder
\- security cluster
\- POS/KDS cluster
\- payment cluster
\- support cluster
\- SOP cluster
\- implementation mapping cluster
\- test catalog cluster
\- import date
\- review status

Each batch should be small enough to review.

\---

\#\# 5\. Recommended Batch Size

Recommended batch size:

\- small batch: 5 to 10 documents
\- medium batch: 10 to 25 documents
\- large batch: 25 to 50 documents

Large batch should be used only when documents are already well-structured.

Avoid importing hundreds of documents in one commit.

Large imports should be split by lane or number range.

\---

\#\# 6\. Batch Import Folder

All imported drafts may first be placed in:

    docs/\_incoming\_mobile\_drafts/

Then each file should be reviewed, renamed, and moved to the correct folder.

Incoming folder is not final storage.

Incoming folder is a staging area for review.

\---

\#\# 7\. Batch Import Stages

Recommended stages:

1\. Copy drafts from Google Docs.
2\. Create temporary Markdown files.
3\. Preserve document number and H1 title.
4\. Run header and format check.
5\. Normalize filenames.
6\. Assign lane.
7\. Assign folder.
8\. Detect duplicate numbers.
9\. Detect duplicate titles.
10\. Move files to target folders.
11\. Update index.
12\. Update directory map.
13\. Update continuation register if needed.
14\. Create batch review report.
15\. Commit batch.

Each stage should be auditable.

\---

\#\# 8\. Batch Naming Rule

Each batch may have a batch id.

Recommended batch id format:

    DOC\_IMPORT\_YYYYMMDD\_NN

Example:

    DOC\_IMPORT\_20260612\_01

Batch id may be referenced in:

\- review report
\- commit message
\- Google Docs imported marker
\- continuation register
\- cleanup note

Batch id helps trace where documents came from.

\---

\#\# 9\. Batch Review Report Definition

A batch review report records what happened during an import batch.

The report should include:

\- batch id
\- import date
\- source location
\- document count
\- document number range
\- lanes included
\- files imported
\- files renamed
\- files moved
\- duplicates found
\- obsolete candidates
\- index updates
\- directory map updates
\- unresolved issues
\- next actions

The report prevents later confusion.

\---

\#\# 10\. Batch Review Report Location

Batch review reports may be stored in a documentation governance folder.

Recommended path:

    docs/documentation\_governance/import\_reports/

or:

    docs/\_import\_reports/

The final folder can change later.

Reports should remain separate from active policy documents.

\---

\#\# 11\. Batch Review Report Filename

Recommended filename:

    DOC\_IMPORT\_YYYYMMDD\_NN\_Review\_Report.md

Example:

    DOC\_IMPORT\_20260612\_01\_Review\_Report.md

The filename should match the batch id.

\---

\#\# 12\. Batch Review Report Template

Recommended template:

    \# DOC\_IMPORT\_YYYYMMDD\_NN Review Report

    \#\# 1\. Source
    \- Source:
    \- Import date:
    \- Imported by:
    \- Review status:

    \#\# 2\. Imported Files
    \- document number
    \- title
    \- temporary filename
    \- final filename
    \- final folder

    \#\# 3\. Rename Actions
    \- old filename
    \- new filename
    \- reason

    \#\# 4\. Move Actions
    \- old path
    \- new path
    \- reason

    \#\# 5\. Duplicate Findings
    \- duplicate number
    \- duplicate title
    \- recommended action

    \#\# 6\. Index Updates
    \- added
    \- updated
    \- pending

    \#\# 7\. Directory Map Updates
    \- added folder
    \- moved folder
    \- pending update

    \#\# 8\. Open Issues
    \- issue
    \- owner
    \- next action

    \#\# 9\. Batch Decision
    \- accepted
    \- accepted with pending review
    \- blocked
    \- deferred

This template can be refined later.

\---

\#\# 13\. Google Docs Source Tracking

Each batch should record its Google Docs source.

Source may include:

\- Google Docs document name
\- Google Docs folder name
\- manual note
\- document group title
\- date created
\- imported marker

Do not rely on Google Docs as final source of truth.

But keep enough source tracking to prevent duplicate import.

\---

\#\# 14\. Imported Marker Policy

After import, Google Docs source should be marked.

Recommended markers:

\- \`IMPORTED\_TO\_REPO\`
\- \`IMPORTED\_IN\_BATCH\_DOC\_IMPORT\_YYYYMMDD\_NN\`
\- \`IMPORTED\_NEEDS\_REVIEW\`
\- \`DUPLICATE\_CANDIDATE\`
\- \`MERGED\`
\- \`OBSOLETE\`
\- \`DEFERRED\`

Marker should prevent repeat import.

\---

\#\# 15\. Commit Discipline Principle

Documentation commits should be understandable.

A commit should answer:

\- what was imported
\- what was renamed
\- what was moved
\- what index was updated
\- what directory map changed
\- whether duplicates were resolved
\- whether obsolete documents were archived

A commit should not mix unrelated massive actions unless intentionally grouped.

\---

\#\# 16\. Recommended Commit Types

Recommended documentation commit types:

\- import mobile drafts
\- normalize filenames
\- move documents to folders
\- update index
\- update directory map
\- resolve duplicates
\- archive obsolete documents
\- add batch review report
\- update continuation register
\- add lane coverage matrix
\- add readiness index

Each commit type should be narrow where practical.

\---

\#\# 17\. Commit Message Style

Recommended commit message style:

    docs: import mobile drafts batch DOC\_IMPORT\_YYYYMMDD\_NN

    docs: normalize filenames for security foundation docs

    docs: move POS KDS security docs to pos\_kds folder

    docs: update document index for 04470-04780

    docs: archive duplicate mobile drafts

    docs: add batch import review report

Commit message should not claim implementation.

Use \`docs:\` for documentation-only work.

\---

\#\# 18\. Import Commit Rule

An import commit should primarily add raw or normalized files.

It should avoid:

\- large content rewriting
\- implementation code
\- unrelated folder restructuring
\- simultaneous duplicate merge
\- simultaneous index overhaul where possible

Import commit preserves original arrival.

Cleanup can happen in later commits.

\---

\#\# 19\. Rename Commit Rule

A rename commit should focus on filename normalization.

It should avoid large content edits.

Before rename commit:

\- list old filenames
\- list new filenames
\- verify document numbers
\- verify H1 titles
\- confirm no duplicate target filename
\- update index if filenames are final

Rename commits should be easy to review.

\---

\#\# 20\. Move Commit Rule

A move commit should focus on folder placement.

Before move commit:

\- define source folder
\- define target folder
\- verify lane assignment
\- update directory map
\- update index path
\- avoid content rewrite

Move commits should preserve file identity.

\---

\#\# 21\. Index Commit Rule

An index commit should update navigation.

Index commit may include:

\- new document entries
\- changed filenames
\- changed folder paths
\- status changes
\- obsolete markers
\- merged markers
\- readiness status
\- related document references

Index commit should not include unrelated content rewriting.

\---

\#\# 22\. Directory Map Commit Rule

Directory map commit should update folder structure.

Directory map commit may include:

\- new folder
\- folder purpose
\- folder range
\- moved folder
\- archive folder
\- incoming folder
\- implementation mapping folder
\- SOP folder
\- testing folder
\- evidence folder

Directory map must reflect real repository state.

\---

\#\# 23\. Duplicate Cleanup Commit Rule

Duplicate cleanup should be separated when possible.

Duplicate cleanup commit may include:

\- marking duplicate candidate
\- merging documents
\- archiving obsolete file
\- updating cross-references
\- updating index status
\- updating directory map if needed

Avoid duplicate cleanup during initial raw import unless simple.

\---

\#\# 24\. Archive Commit Rule

Archive commit should clearly show obsolete movement.

Archive commit should include:

\- files moved to archive
\- obsolete status update
\- replacement document reference
\- index update
\- directory map update if needed

Archive is safer than deletion during early documentation phase.

\---

\#\# 25\. No Implementation In Documentation Commit

Documentation import commits must not include implementation.

Do not include:

\- database migrations
\- schema changes
\- RPC functions
\- API code
\- Flutter code
\- deployment scripts
\- production configuration
\- service role key
\- real \`.env\`
\- payment credential
\- CI / DI credential

Documentation phase remains documentation-only.

\---

\#\# 26\. Pre-Commit Documentation Check

Before committing a documentation batch, check:

\- all files are Markdown where intended
\- each new file has H1
\- H1 includes document number
\- document number is unique
\- filename matches H1 or is intentionally temporary
\- no real secrets
\- no raw CI / DI
\- no production payment data
\- no broken nested code fences
\- no writing block artifacts
\- no Google Docs metadata
\- index update is included or queued
\- directory map update is included or queued
\- batch report exists for large batch

If check fails, fix or mark as pending.

\---

\#\# 27\. Post-Commit Review

After commit, review:

\- git status is clean
\- file count matches expected
\- index references actual files
\- directory map references actual folders
\- incoming folder has no final active files
\- archive folder has only inactive files
\- no duplicate document numbers were introduced
\- cross-reference issues are recorded
\- next actions are clear

Post-commit review prevents hidden drift.

\---

\#\# 28\. Cursor-Assisted Batch Review

Cursor may assist batch review.

Allowed tasks:

\- list imported files
\- compare H1 and filename
\- detect duplicate numbers
\- detect missing index entries
\- detect likely wrong folder placement
\- detect obsolete candidates
\- detect broken code fences
\- suggest batch report content
\- suggest commit grouping
\- suggest next cleanup actions

Cursor must not implement code.

Cursor must not delete files without explicit instruction.

\---

\#\# 29\. Cursor Prompt For Batch Review

Recommended prompt:

    TASK:
    Review the latest documentation import batch.
    Do not implement code.
    Do not rewrite document bodies.
    Do not delete files.
    Check:
    1\. filenames and H1 titles
    2\. duplicate document numbers
    3\. likely wrong folder placement
    4\. missing index entries
    5\. directory map mismatches
    6\. duplicate or obsolete candidates
    7\. broken Markdown fences
    8\. Google Docs or mobile artifacts
    9\. whether commit grouping is clean
    Return a batch review report with safe next actions.

This keeps Cursor in review mode.

\---

\#\# 30\. Batch Failure Handling

A batch may fail review.

Failure reasons include:

\- duplicate document number
\- missing H1
\- wrong document title
\- broken Markdown structure
\- secret accidentally included
\- raw CI / DI included
\- wrong folder assignment
\- index missing
\- directory map mismatch
\- many duplicate documents
\- unclear source

Failed batch should be:

\- corrected
\- split into smaller batch
\- moved back to incoming folder
\- marked \`NEEDS\_REVIEW\`
\- blocked from final index until resolved

Failure must not be hidden.

\---

\#\# 31\. Rollback Policy

Batch import should be reversible where possible.

Rollback may be needed when:

\- wrong files imported
\- duplicate import occurred
\- folder structure was wrong
\- massive rename was incorrect
\- Google Docs source was misunderstood
\- index became inconsistent
\- archive action was wrong

Keeping batch commits small makes rollback safer.

\---

\#\# 32\. Commit Separation Warning

Avoid mixing the following in one commit:

\- import plus implementation
\- import plus large rewrite
\- rename plus content rewrite
\- folder restructure plus policy changes
\- duplicate merge plus new document generation
\- archive plus unrelated index redesign
\- test catalog creation plus payment implementation

Mixed commits are harder to review and rollback.

\---

\#\# 33\. Documentation-Only Branch Rule

A documentation-only branch may be used during large import.

Possible branch name:

    docs/mobile-import-batch

or:

    docs/documentation-normalization

Branching may be useful when:

\- many files are imported
\- folder structure changes
\- index is unstable
\- duplicate cleanup is ongoing
\- review is not complete

Final branch strategy may be defined later.

\---

\#\# 34\. Import Status Values

Recommended batch import statuses:

\- \`RAW\_IMPORTED\`
\- \`HEADER\_CHECKED\`
\- \`RENAMED\`
\- \`MOVED\_TO\_FOLDER\`
\- \`INDEXED\`
\- \`DIRECTORY\_MAPPED\`
\- \`DUPLICATE\_REVIEWED\`
\- \`CROSS\_REFERENCE\_REVIEWED\`
\- \`READY\_TO\_COMMIT\`
\- \`COMMITTED\`
\- \`NEEDS\_REVIEW\`
\- \`BLOCKED\`

Status may be tracked in batch report or incoming index.

\---

\#\# 35\. Large Batch Warning

Large batches require stronger review.

Large batch should include:

\- batch report
\- file list
\- duplicate scan
\- index update
\- directory map update
\- open issue list
\- next cleanup plan

If large batch cannot be reviewed, split it.

A smaller batch that is correct is better than a large batch that is confusing.

\---

\#\# 36\. Emergency Import Rule

Emergency import should be rare.

Emergency import may be needed when:

\- document must be preserved quickly
\- mobile draft is at risk of being lost
\- Google Docs source is unstable
\- critical policy text must be captured

Emergency import should go to incoming folder and be marked \`NEEDS\_REVIEW\`.

Emergency import must not be treated as final placement.

\---

\#\# 37\. Batch Review Checklist

Before closing an import batch, confirm:

\- batch id exists
\- source is recorded
\- file list is recorded
\- document numbers are unique
\- filenames are normalized or marked temporary
\- H1 titles exist
\- folder placement is reviewed
\- index update is done or queued
\- directory map update is done or queued
\- duplicates are reviewed or queued
\- obsolete candidates are marked
\- no secrets exist
\- no raw CI / DI exists
\- no implementation code exists
\- batch report exists for medium or large batch
\- commit message is clear

If any required item is missing, batch remains open.

\---

\#\# 38\. Non-Goals

This document does not define:

\- final git branch strategy
\- final CI validation script
\- final pre-commit hook
\- final automated import tool
\- final Google Docs API sync
\- final documentation dashboard
\- final project management workflow
\- final implementation commit policy
\- final release management workflow

Those must be defined later if needed.

\---

\#\# 39\. Readiness Check

This policy is ready when the project can answer:

1\. What is a batch import?
2\. How large should a batch be?
3\. Where are incoming drafts placed?
4\. How is batch id assigned?
5\. What does a batch review report include?
6\. Where is the batch report stored?
7\. How is Google Docs source tracked?
8\. How is imported marker applied?
9\. What commit types are recommended?
10\. How should commit messages be written?
11\. What belongs in an import commit?
12\. What belongs in a rename commit?
13\. What belongs in a move commit?
14\. What belongs in an index commit?
15\. What belongs in an archive commit?
16\. What must never be included in documentation commit?
17\. What pre-commit checks are required?
18\. How does Cursor assist batch review?
19\. What happens when batch fails review?
20\. Why should large batches be split?

If these questions cannot be answered, batch import and commit governance is incomplete.

\---

\#\# 40\. Conclusion

A documentation-first project must protect its own document history.

The Yoonsul Wait/Order Handoff project will generate many documents through mobile drafting and later import them into a repository.

The system must preserve the following rules:

\- import in reviewable batches
\- assign batch id where useful
\- record source
\- normalize filenames
\- check H1 titles
\- preserve document numbers
\- update index
\- update directory map
\- detect duplicates
\- mark obsolete candidates
\- use clear documentation commits
\- separate import, rename, move, index, and archive work where practical
\- never mix implementation into documentation import commits
\- use Cursor for review, not uncontrolled implementation
\- keep rollback possible
\- split large confusing batches
\- close each batch with a review checklist

A clean document corpus is not created only by writing documents.

It is created by importing, reviewing, committing, and tracing them with discipline.
