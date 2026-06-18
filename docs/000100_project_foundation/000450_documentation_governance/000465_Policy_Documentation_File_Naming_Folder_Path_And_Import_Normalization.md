# 000465_Policy_Documentation_File_Naming_Folder_Path_And_Import_Normalization

\#\# 1\. Purpose

This document defines the file naming, folder path, import normalization, temporary draft handling, and repository placement policy for the Yoonsul Wait/Order Handoff project documentation corpus.

The project will generate many Markdown documents through mobile drafting, Google Docs temporary storage, and later PC-side repository import.

As the document count grows, inconsistent filenames, unstable folder paths, duplicate numbers, mismatched titles, and unclear directory placement can make the document corpus difficult to use.

Therefore, file names and folder paths must be normalized before implementation begins.

\---

\#\# 2\. Scope

This policy applies to:

\- Markdown file naming
\- document number preservation
\- H1 title matching
\- folder path assignment
\- temporary import folders
\- Google Docs draft import
\- mobile draft normalization
\- PC-side sorting
\- document rename decisions
\- folder rename decisions
\- duplicate filename handling
\- obsolete draft handling
\- index update
\- directory map update
\- Cursor-assisted verification
\- pre-implementation documentation cleanup

This document does not define the final full directory tree.

It defines the rules for normalizing files and folders as the documentation corpus matures.

\---

\#\# 3\. Core Principle

A document must remain traceable even when its folder or filename changes.

The project must follow this rule:

\> Document number and title identity must survive import, rename, move, merge, and folder restructuring.

Folders may change.

File names may change.

But document identity must remain clear.

\---

\#\# 4\. Document Identity Rule

The stable identity of a document is:

\- document number
\- H1 title
\- document purpose
\- active index entry

The filename is important, but it is not the only identity.

The folder path is important, but it may change as lanes mature.

Document number must be preserved unless a deliberate renumbering policy is applied.

\---

\#\# 5\. Standard Filename Format

The recommended filename format is:

    {document\_number}\_{Title\_In\_Pascal\_Underscore}.md

Example:

    04750\_Documentation\_File\_Naming\_Folder\_Path\_And\_Import\_Normalization\_Policy.md

Filename should avoid:

\- spaces
\- Korean punctuation
\- special symbols
\- duplicate numbering
\- overly vague title
\- temporary mobile title
\- Google Docs auto-title
\- unsupported filesystem characters

Filename should remain readable by humans and AI tools.

\---

\#\# 6\. Document Number Rule

Every active document must have a unique document number.

Document number must appear in:

\- filename
\- H1 title
\- index entry
\- directory map where applicable
\- cross-reference where applicable

Example:

    filename:
    04750\_Documentation\_File\_Naming\_Folder\_Path\_And\_Import\_Normalization\_Policy.md

    H1:
    \# 00466_Policy_Documentation_File_Naming_Folder_Path_And_Import_Normalization

If number mismatch exists, the file must be reviewed before indexing.

\---

\#\# 7\. H1 Title Rule

Every Markdown document must begin with one clear H1 title.

The H1 title should follow:

    \# {document\_number} {Document Title}

Example:

    \# 00466_Policy_Documentation_File_Naming_Folder_Path_And_Import_Normalization

A file with missing H1, duplicate H1, mismatched H1, or title without document number must be flagged during import review.

\---

\#\# 8\. Temporary Filename Rule

Temporary filenames are allowed during mobile import.

Examples:

\- \`04750\_temp.md\`
\- \`mobile\_draft\_04750.md\`
\- \`unsorted\_04750.md\`
\- \`google\_docs\_import\_04750.md\`

Temporary filenames must not remain final.

Temporary files must be normalized before final repository placement.

\---

\#\# 9\. Incoming Draft Folder Rule

Mobile-generated drafts may first be placed in an incoming folder.

Recommended path:

    docs/\_incoming\_mobile\_drafts/

This folder is for unsorted drafts only.

Files in this folder should have one of these statuses:

\- not reviewed
\- needs rename
\- needs folder assignment
\- duplicate candidate
\- needs merge
\- imported but not indexed
\- rejected or obsolete

No file should remain permanently in the incoming folder without review status.

\---

\#\# 10\. Folder Path Rule

Folder path should reflect the document lane or cluster.

Folder path may be based on:

\- document number range
\- security cluster
\- runtime cluster
\- POS/KDS cluster
\- payment cluster
\- tenant/store cluster
\- support cluster
\- audit cluster
\- SOP cluster
\- testing cluster
\- implementation mapping cluster
\- compliance cluster
\- documentation governance cluster

A folder should help humans and AI tools understand where the document belongs.

\---

\#\# 11\. Folder Naming Style

Recommended folder naming style:

\- lowercase
\- underscores instead of spaces
\- short but meaningful
\- stable enough for index reference
\- aligned with documentation lane

Examples:

    docs/security\_foundation/
    docs/pos\_kds\_security/
    docs/degraded\_recovery/
    docs/payment\_boundary/
    docs/support\_access/
    docs/documentation\_governance/
    docs/implementation\_mapping/
    docs/testing\_verification/

Folder names may change before implementation, but changes must update index and directory map.

\---

\#\# 12\. Folder Evolution Rule

Folder names may evolve as the corpus grows.

Folder changes may happen when:

\- document clusters become clearer
\- a lane becomes too large
\- a folder mixes unrelated documents
\- a folder name is misleading
\- implementation mapping needs separate folder
\- SOPs need separate folder
\- readiness checks need separate folder
\- security foundation needs stronger separation

Folder evolution is allowed.

Untracked folder drift is not allowed.

\---

\#\# 13\. File Move Rule

When a document is moved to another folder, update:

\- index entry
\- directory map
\- cross-reference if path-specific
\- continuation register if item was tracked
\- import status if from Google Docs
\- obsolete path marker where needed

Moving a file without updating navigation creates hidden documentation debt.

\---

\#\# 14\. File Rename Rule

A file may be renamed when:

\- filename does not match H1 title
\- title changed
\- typo exists
\- folder naming convention changed
\- document was moved to another lane
\- duplicate title was clarified
\- document scope was narrowed
\- document number was corrected

Rename must preserve document number unless the number itself was wrong.

Rename should be recorded in index or change note where needed.

\---

\#\# 15\. Document Number Conflict Rule

If two files use the same document number:

1\. Compare H1 titles.
2\. Compare contents.
3\. Identify which is active.
4\. Mark duplicate, obsolete, or merge candidate.
5\. Assign new number if both are valid but different.
6\. Update index.
7\. Update directory map.
8\. Preserve decision in review notes.

Duplicate numbers must not remain active.

\---

\#\# 16\. Title Conflict Rule

If two files have similar or identical titles:

1\. Check whether they are duplicates.
2\. Check whether one is policy and one is SOP.
3\. Check whether one is mapping and one is readiness.
4\. Check whether one should be renamed.
5\. Check whether one should be merged.
6\. Update index to clarify scope.

Similar title is not always duplicate.

But it requires review.

\---

\#\# 17\. Document Type Suffix Rule

Where useful, document title may include a type suffix.

Common suffixes:

\- Policy
\- SOP
\- Governance
\- Readiness Check
\- Implementation Mapping
\- Test Catalog
\- Evidence Register
\- Index
\- Handoff Policy
\- Continuation Register

The suffix should clarify the document's role.

Example:

    00466_Policy_Documentation_File_Naming_Folder_Path_And_Import_Normalization

\---

\#\# 18\. Policy Versus SOP Filename Rule

Policy documents should describe rules and boundaries.

SOP documents should describe operational steps.

Filename should make this clear.

Examples:

    04620\_Security\_Incident\_Response\_Severity\_Classification\_And\_Recovery\_Governance\_Policy.md

    05xxx\_Security\_Incident\_Response\_Store\_Operator\_SOP.md

A SOP should not be hidden under a policy filename.

A policy should not pretend to be an SOP.

\---

\#\# 19\. Implementation Mapping Filename Rule

Implementation mapping documents must clearly say they are mapping documents.

Recommended pattern:

    {number}\_{Runtime\_Or\_Feature}\_Implementation\_Security\_Mapping.md

Examples:

    05xxx\_POS\_KDS\_RPC\_Implementation\_Security\_Mapping.md
    05xxx\_Supabase\_RLS\_Tenant\_Store\_Implementation\_Mapping.md
    05xxx\_Payment\_Webhook\_Refund\_Implementation\_Security\_Mapping.md

Mapping documents bridge policy to implementation.

They must not be confused with implementation code.

\---

\#\# 20\. Test Catalog Filename Rule

Test catalog documents must clearly identify test coverage.

Recommended pattern:

    {number}\_{Feature\_Or\_Lane}\_Security\_Test\_Catalog.md

Examples:

    05xxx\_POS\_KDS\_RPC\_Security\_Test\_Catalog.md
    05xxx\_Payment\_Webhook\_Idempotency\_And\_Replay\_Test\_Catalog.md
    05xxx\_Tenant\_Store\_Isolation\_RLS\_Test\_Catalog.md

Test catalogs should be easy to find before implementation.

\---

\#\# 21\. Evidence Register Filename Rule

Evidence register documents must clearly identify evidence category.

Recommended pattern:

    {number}\_{Control\_Area}\_Evidence\_Register.md

Examples:

    05xxx\_Payment\_Boundary\_Evidence\_Register.md
    05xxx\_CI\_DI\_Protection\_Evidence\_Register.md
    05xxx\_Support\_Access\_Break\_Glass\_Evidence\_Register.md

Evidence register documents support compliance readiness.

\---

\#\# 22\. Index Filename Rule

Index documents should be easy to locate.

Recommended patterns:

    {range}\_Index\_And\_Readiness\_Check.md
    {lane}\_Document\_Index.md
    {lane}\_Coverage\_Index.md

Examples:

    04700\_Security\_Foundation\_Final\_Index\_And\_Next\_Phase\_Handoff\_Policy.md
    04740\_Documentation\_Lane\_Coverage\_Matrix\_And\_Missing\_Document\_Detection\_Policy.md

Indexes must not be buried in unrelated folders.

\---

\#\# 23\. Readiness Check Filename Rule

Readiness check documents should clearly indicate gate function.

Recommended pattern:

    {number}\_{Lane\_Or\_Feature}\_Index\_And\_Readiness\_Check.md

or:

    {number}\_{Lane\_Or\_Feature}\_Readiness\_Gate.md

Readiness check documents should contain questions that determine whether implementation may proceed.

\---

\#\# 24\. Obsolete File Rule

Obsolete files must not silently remain active.

An obsolete file should be:

\- moved to archive folder
\- marked obsolete in index
\- merged into active document
\- deleted only after review where appropriate
\- recorded as replaced by another document where needed

Recommended archive path:

    docs/\_archive\_obsolete/

Obsolete documents must not confuse AI tools during implementation.

\---

\#\# 25\. Merged File Rule

If two documents are merged:

1\. Create or choose active merged document.
2\. Preserve important content.
3\. Mark old document as merged or obsolete.
4\. Update index.
5\. Update directory map.
6\. Update cross-references.
7\. Note replacement relationship.

Merging must not erase important constraints.

\---

\#\# 26\. Google Docs Import Marker Rule

After a Google Docs draft is imported, the draft should be marked.

Recommended markers:

\- \`IMPORTED\_TO\_REPO\`
\- \`IMPORTED\_NEEDS\_REVIEW\`
\- \`DUPLICATE\_CANDIDATE\`
\- \`MERGED\_TO\_{document\_number}\`
\- \`OBSOLETE\`
\- \`DEFERRED\`
\- \`NOT\_IMPORTED\`

This prevents repeat imports and confusion.

\---

\#\# 27\. Imported File Header Check

After import, each file should be checked for:

\- one H1 title
\- document number in H1
\- title matches filename
\- no broken Markdown fence
\- no accidental mobile artifacts
\- no writing block fence
\- no Google Docs metadata
\- no real secret
\- no raw CI / DI
\- no production credential
\- no duplicated sections from copy error

Files failing header check must be corrected before final placement.

\---

\#\# 28\. Mobile Artifact Cleanup Rule

Mobile-generated content may include artifacts.

Artifacts may include:

\- broken code fences
\- copied UI labels
\- duplicated paragraphs
\- missing section breaks
\- inconsistent list indentation
\- repeated title
\- unexpected smart punctuation
\- writing block markers
\- temporary assistant comments
\- Google Docs formatting artifacts

Artifacts should be cleaned during PC import.

Content meaning should not be changed unnecessarily.

\---

\#\# 29\. File Path Cross-Reference Rule

Cross-references should prefer document number and title over fragile path.

Good reference:

    See 04551_Policy_Payment_Boundary_Refund_Correction_And_Settlement_Security.

Path-specific reference may be used after folder structure stabilizes.

Early-stage documents should avoid relying too heavily on exact folder path.

\---

\#\# 30\. Directory Map Synchronization Rule

Directory map must be synchronized after major file movement.

Directory map should reflect:

\- current folders
\- folder purpose
\- document ranges
\- major lanes
\- incoming draft folder
\- archive folder
\- implementation mapping folder
\- testing folder
\- SOP folder
\- index folder where applicable

Directory map must not describe a folder structure that no longer exists.

\---

\#\# 31\. Index Synchronization Rule

Index must be synchronized after import, rename, move, merge, or obsolete marking.

Index entry should include:

\- document number
\- title
\- filename
\- folder path
\- lane
\- status
\- related documents where needed

Index is the primary navigation control.

A document missing from index is not fully governed.

\---

\#\# 32\. Cursor Verification Rule

Cursor or AI verification may be used to check file consistency.

Allowed verification tasks:

\- identify filename and H1 mismatch
\- identify duplicate numbers
\- identify duplicate titles
\- identify files missing index entry
\- identify files in wrong folder
\- identify broken Markdown fences
\- identify mobile artifacts
\- identify obsolete candidates
\- identify cross-reference issues
\- suggest rename list
\- suggest move list

Cursor must not implement code during documentation normalization.

\---

\#\# 33\. Cursor Prompt For Filename Verification

Recommended prompt:

    TASK:
    Review Markdown files for filename, H1 title, document number, folder path, and index consistency.
    Do not rewrite documents.
    Do not implement code.
    Do not delete files.
    Return:
    1\. files with matching filename and H1
    2\. files needing rename
    3\. files with duplicate numbers
    4\. files with duplicate or similar titles
    5\. files in likely wrong folder
    6\. files missing from index
    7\. files that appear obsolete or duplicate
    8\. recommended safe next actions

This prompt keeps verification controlled.

\---

\#\# 34\. Batch Normalization Workflow

Recommended batch normalization workflow:

1\. Import mobile drafts to incoming folder.
2\. Run header check.
3\. Extract document number and H1 title.
4\. Generate recommended filename.
5\. Detect number conflict.
6\. Detect title conflict.
7\. Assign lane.
8\. Assign folder.
9\. Move file.
10\. Update index.
11\. Update directory map if needed.
12\. Mark Google Docs draft as imported.
13\. Review duplicates.
14\. Commit batch.

Batch size should be manageable.

Small clean batches are safer than one massive import.

\---

\#\# 35\. Pre-Commit Documentation Check

Before committing documentation changes, check:

\- all new files have \`.md\` extension
\- all new files have H1 title
\- H1 begins with document number
\- filenames match document numbers
\- no duplicate document numbers
\- no obvious duplicate titles
\- no file remains in incoming folder without review status
\- index is updated or update is explicitly queued
\- directory map is updated if folder changed
\- no real secret is present
\- no raw CI / DI is present
\- no implementation code appears in policy-only document unless intended

Pre-commit check prevents documentation drift.

\---

\#\# 36\. Large Rename Warning

Large rename operations should be handled carefully.

Before large rename:

\- export current file list
\- review index
\- review directory map
\- confirm naming rule
\- group changes by lane
\- avoid simultaneous content rewrite
\- commit rename separately where possible
\- verify cross-references after rename

Large rename plus content rewrite creates review difficulty.

\---

\#\# 37\. Folder Restructure Warning

Folder restructuring should be handled as its own operation.

Before folder restructure:

\- define target folder map
\- identify affected files
\- update directory map
\- update index paths
\- preserve document numbers
\- avoid deleting content
\- run duplicate check after move
\- commit restructure separately where possible

Folder restructure should improve navigation, not hide documents.

\---

\#\# 38\. File Naming Quality Checklist

A good final filename should answer:

\- What is the document number?
\- What is the document about?
\- What type of document is it?
\- Is it readable?
\- Is it unique?
\- Does it match H1?
\- Does it avoid special characters?
\- Does it belong to its folder?
\- Can AI tools understand it?
\- Can a human find it later?

If not, rename is recommended.

\---

\#\# 39\. Non-Goals

This document does not define:

\- final complete folder tree
\- final document number allocation
\- final index schema
\- final directory map schema
\- final automation script
\- final pre-commit hook
\- final Cursor extension
\- final file archival policy
\- final git branching strategy
\- final implementation schedule

Those must be defined in later documentation governance or repository operation documents.

\---

\#\# 40\. Readiness Check

This policy is ready when the project can answer:

1\. What is the standard filename format?
2\. How is document number preserved?
3\. How should H1 title be formatted?
4\. Where do incoming mobile drafts go?
5\. How are temporary filenames handled?
6\. How are folders named?
7\. Can folder names change later?
8\. What happens when a file is moved?
9\. What happens when a file is renamed?
10\. How are duplicate document numbers handled?
11\. How are duplicate titles handled?
12\. How are obsolete files marked?
13\. How are merged files handled?
14\. How are Google Docs drafts marked after import?
15\. How are mobile artifacts cleaned?
16\. How is index synchronized?
17\. How is directory map synchronized?
18\. What can Cursor verify?
19\. What must Cursor not do?
20\. What is checked before commit?

If these questions cannot be answered, file naming and import normalization governance is incomplete.

\---

\#\# 41\. Conclusion

A large documentation-first project requires stable document identity.

The Yoonsul Wait/Order Handoff project will generate many Markdown documents through mobile drafting and later PC import.

The system must preserve the following rules:

\- document number and H1 title define identity
\- filenames must be normalized
\- temporary filenames are allowed only during import
\- incoming drafts must be reviewed
\- folders may evolve but must be synchronized
\- duplicate numbers must be resolved
\- duplicate titles must be reviewed
\- obsolete files must be marked
\- merged files must preserve traceability
\- Google Docs drafts must be marked after import
\- mobile artifacts must be cleaned
\- index must be synchronized
\- directory map must be synchronized
\- Cursor may verify but must not implement
\- pre-commit checks must prevent documentation drift

Good documentation architecture is not only about what the documents say.

It is also about whether the right document can be found, trusted, and used when implementation begins.
