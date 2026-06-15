# 00458_Policy_Mobile_Draft_Archive_Git_Source_Of_Truth_And_Google_Docs_Fallback

## 1. Purpose

This document defines the mobile draft archive, Git source of truth, Google Docs fallback, temporary copy handling, archive labeling, source verification, import confirmation, post-import cleanup, and implementation deferral policy for the Yoonsul Wait/Order Handoff documentation project.

The previous document defined provider, legal, security, payment, KDS, POS, Mini Kiosk, support, pilot, commercial, UI, and cross-runtime review handoff packet policy.

This document defines how mobile-generated drafts, copied Markdown blocks, Obsidian notes, Google Docs fallback copies, local PC files, and Git repository files should be treated during documentation production and PC import so that source confusion, duplicate truth, lost drafts, accidental overwrites, and stale fallback documents do not damage the project.

This document does not move files, create archives, run Git commands, create Google Docs, or implement project code.

It defines mobile draft archive and source-of-truth policy only.

---

## 2. Scope

This document covers:

- mobile draft meaning
- Git source of truth
- Google Docs fallback
- Obsidian Mobile usage
- clipboard copy handling
- temporary archive
- imported draft marking
- stale copy labeling
- source verification
- post-import cleanup
- duplicate copy prevention
- no-code boundary

This document does not cover:

- final repository tree
- final sync automation
- final import script
- final Google Docs workflow automation
- final Obsidian plugin setup
- final Git command execution
- final implementation planning
- final production documentation portal

---

## 3. Core Principle

There must be only one canonical source after import.

The project must follow this rule:

> Mobile drafts, Obsidian notes, copied Markdown blocks, Google Docs copies, exported text files, and local scratch files are temporary sources until verified in Git. After verified Git import, the Git repository becomes the source of truth.

Temporary copy is useful.

Multiple truths are dangerous.

---

## 4. Mobile Draft Meaning

Mobile draft means documentation content created or stored outside the PC repository during high-velocity drafting.

Mobile draft may include:

- ChatGPT response copied on mobile
- Obsidian Mobile note
- Android clipboard text
- Google Docs draft
- temporary Markdown file
- pasted text message
- screenshot-assisted draft
- exported mobile note
- draft stored in cloud note app

Mobile draft is useful for speed but must be imported carefully.

---

## 5. Git Source Of Truth Meaning

Git source of truth means the repository version that is:

- stored in the project folder
- placed under correct docs path
- named consistently
- indexed or ready for index
- committed or staged for controlled commit
- reviewed for duplicate/missing files
- checked for secrets
- checked for implementation leakage
- verified after commit

After this point, Git copy is canonical.

---

## 6. Google Docs Fallback Meaning

Google Docs fallback means a non-canonical copy used for:

- temporary reading
- review
- archive
- emergency copy
- mobile accessibility
- non-technical viewing
- backup during transfer

Google Docs fallback is not source of truth after Git import.

Google Docs should not contain secrets.

---

## 7. Obsidian Mobile Role

Obsidian Mobile may be used for:

- mobile drafting
- quick Markdown storage
- numbering continuity
- offline review
- lightweight linking
- copy buffer
- temporary range folders
- import staging

Obsidian Mobile must not become permanent source of truth unless synchronized into Git and verified.

---

## 8. Clipboard Copy Rule

Clipboard copy is volatile.

When copying Markdown from mobile:

- paste into stable note quickly
- preserve fenced code block
- preserve H1 title
- preserve document number
- avoid partial copy
- check beginning and ending sections
- check conclusion exists
- avoid copying UI artifacts
- avoid duplicate paste into wrong document

Clipboard should not be trusted after long delay.

---

## 9. Temporary Source Categories

Recommended temporary source categories:

- `MOBILE_CHATGPT_DRAFT`
- `OBSIDIAN_MOBILE_DRAFT`
- `GOOGLE_DOCS_FALLBACK`
- `CLIPBOARD_COPY`
- `LOCAL_PC_SCRATCH`
- `EXPORTED_TEXT_COPY`
- `ARCHIVE_COPY`
- `DUPLICATE_REVIEW_COPY`
- `SUPERSEDED_DRAFT`
- `UNKNOWN_SOURCE_COPY`

Temporary source category should be recorded if confusion occurs.

---

## 10. Draft Status Values

Recommended draft status values:

- `DRAFT_CREATED`
- `DRAFT_COPIED`
- `DRAFT_STORED_MOBILE`
- `DRAFT_READY_FOR_IMPORT`
- `DRAFT_IMPORTED_TO_PC`
- `DRAFT_IMPORTED_TO_GIT`
- `DRAFT_COMMITTED`
- `DRAFT_VERIFIED`
- `DRAFT_ARCHIVED`
- `DRAFT_SUPERSEDED`
- `DRAFT_DUPLICATE_REVIEW_REQUIRED`
- `DRAFT_STALE`
- `DRAFT_DO_NOT_USE`

Draft status prevents source confusion.

---

## 11. Canonical Status Values

Recommended canonical status values:

- `CANONICAL_NOT_ASSIGNED`
- `CANONICAL_MOBILE_TEMPORARY`
- `CANONICAL_PC_IMPORTED`
- `CANONICAL_GIT_STAGED`
- `CANONICAL_GIT_COMMITTED`
- `CANONICAL_GIT_VERIFIED`
- `CANONICAL_ARCHIVED`
- `CANONICAL_SUPERSEDED`

Canonical status must be explicit during transition.

---

## 12. Source Verification Rule

Before marking a document as Git source of truth, verify:

- document number
- document title
- H1 title
- full content
- section continuity
- conclusion exists
- filename matches title
- file is in correct range folder
- no obvious truncation
- no duplicate conflict
- no secret leakage
- no implementation leakage
- index or import register updated if applicable

Verification protects against mobile copy errors.

---

## 13. Mobile Draft Import Record Fields

Each imported mobile draft should record:

- draft id
- source type
- original title
- document number
- target filename
- target path
- import date
- import status
- canonical status
- duplicate status
- verification status
- commit hash if any
- notes

Import record prevents lost drafts.

---

## 14. Draft ID Format

Recommended format:

    DRAFT-[YYYYMMDD]-[NUMBER]

Example:

    DRAFT-20260612-001

Final format may be normalized later.

---

## 15. Archive Copy Rule

Archive copy may be kept when:

- mobile draft was important
- imported file needs safety backup
- Google Docs fallback was used
- document was superseded
- duplicate review is pending
- PC import not fully verified
- user wants readable non-Git copy

Archive copy must be labeled as archive.

---

## 16. Archive Label Rule

Archive copy should include clear label:

    Archive copy.
    Git repository is source of truth after verified import.
    Do not edit this copy as canonical.

Label should be visible near top of document.

---

## 17. Stale Copy Rule

A stale copy is any copy that no longer matches Git source of truth.

Stale copy may exist in:

- Google Docs
- mobile note
- clipboard
- exported text file
- old PC folder
- backup drive
- chat history
- local scratch file

Stale copy should not be used for future edits unless re-verified.

---

## 18. Stale Copy Label Rule

Stale copy should be labeled:

    Stale copy.
    Check Git repository before editing or reusing.

Stale copy without label creates confusion.

---

## 19. Google Docs Fallback Rule

Google Docs fallback may be used only when:

- mobile copying is easier
- PC import is delayed
- external review needs readable format
- emergency backup is needed
- long document needs temporary viewing

Google Docs fallback must not become final editing source after Git import.

---

## 20. Google Docs Prohibited Content

Google Docs fallback should not contain:

- secrets
- API keys
- service role keys
- provider credentials
- webhook secrets
- raw CI/DI
- raw payment identifiers
- full identity documents
- production incident sensitive details
- private customer/staff data

Fallback documents should remain safe.

---

## 21. Google Docs Status Values

Recommended Google Docs status values:

- `GDOC_NOT_USED`
- `GDOC_TEMPORARY_DRAFT`
- `GDOC_REVIEW_COPY`
- `GDOC_ARCHIVE_COPY`
- `GDOC_STALE_COPY`
- `GDOC_IMPORTED_TO_GIT`
- `GDOC_DO_NOT_EDIT`
- `GDOC_DELETE_REVIEW_REQUIRED`

Status should be visible if Google Docs is used.

---

## 22. Obsidian Note Rule

Obsidian note should preserve Markdown integrity.

When using Obsidian Mobile:

- keep document number in filename
- keep H1 title
- avoid mixing multiple documents in one note unless temporary
- mark imported notes
- avoid editing stale notes after Git import
- use folders by range if possible
- do not store secrets
- do not store implementation commands unless build phase permits later

Obsidian is a drafting tool, not final governance source unless Git-backed.

---

## 23. Local PC Scratch Rule

Local PC scratch files may be used during import.

Scratch files should:

- be clearly named
- not be committed accidentally
- not contain secrets
- not be treated as canonical
- be deleted or archived after import review
- not mix code and documentation

Scratch file must not become hidden source of truth.

---

## 24. Duplicate Copy Rule

Duplicate copies should be expected during mobile drafting.

Duplicate handling should:

- compare document number
- compare title
- compare length
- compare last section
- compare conclusion
- identify newest or most complete version
- preserve both until verified
- mark one as duplicate or superseded
- update import register

Duplicate deletion must be careful.

---

## 25. Superseded Draft Rule

A draft may be superseded when:

- corrected version exists
- addendum replaced it
- final Git copy exists
- range closure changed title
- wrong-range version was replaced
- duplicate was resolved
- mobile copy was incomplete

Superseded draft should be labeled, not silently erased.

---

## 26. Imported Draft Marking Rule

After successful import, mobile or fallback copy should be marked:

    Imported to Git.
    Canonical path: [target path]
    Import date: [date]
    Do not edit this copy unless re-importing intentionally.

This prevents editing the wrong copy later.

---

## 27. Re-Import Rule

Re-import is allowed when:

- Git copy is incomplete
- mobile copy is more complete
- typo correction is needed
- missing section found
- duplicate conflict resolved
- source range changed
- title normalization required

Re-import must record reason.

---

## 28. Re-Import Record Fields

Each re-import should record:

- re-import id
- original import id
- document number
- reason
- source copy
- target path
- changed sections
- reviewer
- status
- notes

Re-import must not silently overwrite.

---

## 29. Re-Import ID Format

Recommended format:

    REIMPORT-[YYYYMMDD]-[NUMBER]

Example:

    REIMPORT-20260612-001

Final format may be normalized later.

---

## 30. Post-Import Cleanup Rule

After Git import verification:

- mark mobile draft as imported
- mark Google Docs as archive or stale
- remove duplicate scratch copies if safe
- keep archive if needed
- update import register
- update range README if needed
- confirm Git commit
- avoid immediate deletion if uncertainty remains

Cleanup should be conservative.

---

## 31. Deletion Review Rule

Deletion of draft copy should require review when:

- Git import not verified
- duplicate resolution incomplete
- mobile copy may be newer
- Google Docs used for external review
- document has legal/security relevance
- document has high-risk policy
- file count mismatch exists
- title mismatch exists

Deletion should not be rushed.

---

## 32. Source Conflict Rule

Source conflict occurs when two copies differ.

Conflict should be resolved by:

- comparing document number
- comparing title
- comparing section count
- comparing conclusion
- checking latest approved response
- checking Git commit date
- checking import record
- preserving both until resolved
- marking final canonical copy

Source conflict must not be resolved by memory alone.

---

## 33. Source Conflict Status Values

Recommended values:

- `CONFLICT_NOT_CHECKED`
- `CONFLICT_NONE`
- `CONFLICT_MINOR_FORMAT`
- `CONFLICT_TITLE_MISMATCH`
- `CONFLICT_SECTION_MISSING`
- `CONFLICT_CONTENT_DIFFERENCE`
- `CONFLICT_DUPLICATE_NUMBER`
- `CONFLICT_CANONICAL_UNKNOWN`
- `CONFLICT_RESOLVED`
- `CONFLICT_REVIEW_REQUIRED`

Conflict status helps PC import.

---

## 34. Long-Term Archive Rule

Long-term archive may be kept for:

- milestone documentation
- patent-supportive planning material
- legal-sensitive design history
- major range closure
- superseded but important policy
- early concept evolution
- audit of planning decisions

Long-term archive should be clearly separated from active docs.

---

## 35. Archive Folder Recommendation

Recommended archive structure:

    docs/_archive/
      mobile_drafts/
      google_docs_exports/
      superseded_docs/
      duplicate_review/
      stale_copies/
      milestone_snapshots/

Archive folder may be created later during PC normalization.

---

## 36. Archive Index Rule

Archive should include index when it grows.

Archive index should include:

- archived file
- original number
- original title
- archive reason
- canonical replacement if any
- archive date
- status
- notes

Archive without index becomes document graveyard.

---

## 37. Source Of Truth Transition Rule

The transition should be:

    mobile draft
        -> PC import
        -> file verification
        -> Git staging
        -> Git commit
        -> commit verification
        -> mobile/archive marking
        -> Git source of truth

Skipping transition steps creates uncertainty.

---

## 38. Git Verification Rule

Git verification should check:

- file exists in target path
- file content complete
- filename correct
- H1 title correct
- Git status expected
- commit exists if committed
- no unexpected deletions
- no secrets
- no code leakage
- index updated if expected

Git verification should be recorded.

---

## 39. Remote Sync Rule

If remote repository is used:

- push only after local verification
- check remote branch status
- avoid force push unless clearly intended
- do not push secrets
- confirm remote contains expected commit
- avoid mixing unrelated changes
- record remote sync status if needed

Remote sync is not required for draft validity but helps preservation.

---

## 40. Mobile Editing After Import Rule

After Git import, mobile editing should stop unless:

- editing Git-backed synced note
- re-import plan exists
- explicit correction is needed
- source conflict is understood
- canonical path is known

Editing stale mobile copy after import creates drift.

---

## 41. Emergency Recovery Rule

If Git copy is lost or corrupted:

- use latest verified archive
- compare mobile draft
- compare Google Docs fallback
- compare chat transcript if available
- restore document number and title
- record recovery source
- commit correction
- mark recovery in register

Recovery must preserve traceability.

---

## 42. No-Code Boundary

This policy does not authorize:

- SQL creation
- Flutter code
- API implementation
- provider integration
- payment logic
- KDS logic
- Admin Console build
- CI/CD change
- production deployment

This document governs documentation source handling only.

---

## 43. Registers Recommendation

Recommended future files:

    docs/_index/
      Mobile_Draft_Register.md
      Git_Source_Of_Truth_Register.md
      Google_Docs_Fallback_Register.md
      Draft_Import_Record_Register.md
      Draft_Archive_Register.md
      Stale_Copy_Register.md
      Source_Conflict_Register.md
      Reimport_Register.md
      Archive_Index.md
      Remote_Sync_Register.md

This document only recommends these files.

It does not create them.

---

## 44. Anti-Patterns

The following are prohibited:

- treating chat history as canonical after Git import
- editing Google Docs after Git becomes source of truth
- deleting mobile draft before verification
- keeping duplicate copies without labels
- using stale copy for future edit
- overwriting Git file from memory
- resolving source conflict without comparison
- storing secrets in Google Docs or Obsidian
- mixing code into mobile draft archive
- assuming imported file is complete without checking conclusion
- treating archive as active folder
- ignoring remote sync mismatch
- allowing multiple people to edit different canonical copies

---

## 45. Non-Goals

This document does not define:

- final import script
- final Git workflow
- final Obsidian sync setup
- final Google Docs export process
- final archive automation
- final repository branch policy
- final documentation portal
- final implementation process

Those belong to later tooling and PC-side execution.

---

## 46. Readiness Check

This document is ready when the project can answer:

1. What is mobile draft?
2. What is Git source of truth?
3. What is Google Docs fallback?
4. What role does Obsidian Mobile play?
5. What clipboard copy rule applies?
6. What temporary source categories exist?
7. What draft status values exist?
8. What canonical status values exist?
9. What source verification rule applies?
10. What fields should mobile draft import record include?
11. What archive copy rule applies?
12. What archive label rule applies?
13. What stale copy rule applies?
14. What stale copy label rule applies?
15. What Google Docs fallback rule applies?
16. What Google Docs content is prohibited?
17. What Google Docs status values exist?
18. What Obsidian note rule applies?
19. What local PC scratch rule applies?
20. What duplicate copy rule applies?
21. What superseded draft rule applies?
22. What imported draft marking rule applies?
23. What re-import rule applies?
24. What fields should re-import record include?
25. What post-import cleanup rule applies?
26. What deletion review rule applies?
27. What source conflict rule applies?
28. What source conflict statuses exist?
29. What long-term archive rule applies?
30. What archive folder recommendation exists?
31. What archive index rule applies?
32. What source-of-truth transition rule applies?
33. What Git verification rule applies?
34. What remote sync rule applies?
35. What mobile editing after import rule applies?
36. What emergency recovery rule applies?
37. What no-code boundary applies?
38. What registers are recommended?
39. What anti-patterns are prohibited?

If these questions cannot be answered, mobile draft archive, Git source of truth, and Google Docs fallback governance is incomplete.

---

## 47. Conclusion

High-velocity mobile drafting is valuable only when the source-of-truth transition is controlled.

The safe source flow is:

    mobile draft
        -> temporary storage
        -> PC import
        -> Git verification
        -> Git commit
        -> archive or stale labeling
        -> Git repository as source of truth

This document ensures that mobile drafts, Google Docs fallback copies, Obsidian notes, clipboard copies, PC scratch files, archive copies, and Git files do not create competing truths, lost documents, accidental overwrites, or stale edits during the project’s large-scale documentation buildout.