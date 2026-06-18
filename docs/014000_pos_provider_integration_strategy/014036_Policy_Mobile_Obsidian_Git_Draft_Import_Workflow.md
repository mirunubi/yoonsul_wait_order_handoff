# 014036_Policy_Mobile_Obsidian_Git_Draft_Import_Workflow

## 1. Purpose

This document defines the mobile Obsidian, Git, Markdown draft capture, GitHub sync, PC import, folder normalization, and post-processing workflow policy for the Yoonsul Wait/Order Handoff documentation project.

The project has been producing a large number of Markdown policy documents.

Google Docs may become unstable or inefficient for long Markdown drafting, file naming, indexing, and later Git import.

This document defines the new workflow:

    Generate Markdown draft
        -> save directly as .md in mobile Obsidian
        -> commit and push through mobile Git
        -> pull on PC
        -> normalize folder, index, and references later

This document does not implement Git setup, configure Obsidian, create folders, or move files.

It defines documentation workflow policy only.

---

## 2. Scope

This document covers:

- mobile Markdown drafting
- Obsidian vault usage
- mobile Git usage
- GitHub as source of truth
- PC-side pull and normalization
- folder movement deferral
- filename discipline
- commit discipline
- conflict prevention
- Google Docs fallback boundary
- no-implementation boundary

This document does not cover:

- final mobile Git app selection
- final Termux setup
- final Obsidian plugin setup
- final GitHub credential setup
- final folder creation
- final PC import script
- final index generator
- final documentation build pipeline

---

## 3. Core Principle

Markdown files must become the primary documentation artifact.

The project must follow this rule:

> From this workflow onward, new policy documents should be captured as Markdown files first, and folder/index normalization may be deferred to PC-side review.

The priority is continuous document production without losing copy fidelity.

---

## 4. Workflow Shift

Previous workflow:

    ChatGPT
        -> Google Docs
        -> later manual export/copy
        -> PC-side Markdown normalization

New workflow:

    ChatGPT
        -> Obsidian mobile Markdown file
        -> mobile Git commit/push
        -> PC git pull
        -> PC-side folder/index normalization

The new workflow reduces:

- Google Docs formatting breakage
- copy button dependency
- large document instability
- later conversion effort
- unclear document boundaries
- filename loss
- duplicate paste risk

---

## 5. Source Of Truth

The source of truth should be:

    GitHub repository

Recommended role split:

| Layer | Role |
| ----- | ---- |
| ChatGPT | Markdown document generation |
| Obsidian Mobile | Markdown capture and light editing |
| Mobile Git | commit and push |
| GitHub | remote source of truth |
| PC Git | pull and normalize |
| Cursor / VSCode | folder, index, duplicate, and reference cleanup |
| Google Docs | legacy backup or temporary fallback only |

Google Docs should no longer be the primary destination for newly generated Markdown documents.

---

## 6. Mobile Working Model

Mobile device should be used for:

- capturing new Markdown documents
- creating one file per policy document
- light filename correction
- light typo correction
- local reading
- commit/push after drafting
- emergency backup through GitHub

Mobile device should not be used as primary tool for:

- large folder restructuring
- mass renaming
- cross-document index generation
- duplicate detection across hundreds of files
- implementation edits
- code changes
- SQL changes
- Flutter changes
- provider credential management

Mobile is for production and capture.

PC is for normalization and control.

---

## 7. PC Working Model

PC should be used for:

- git pull
- folder placement
- filename normalization
- index update
- README update
- cross-reference cleanup
- duplicate detection
- numbering gap detection
- document cluster review
- batch commits
- implementation readiness review
- future controlled implementation

PC remains the main environment for structural correctness.

---

## 8. Recommended Vault Boundary

Recommended structure:

    Git repository:
      yoonsul_wait_order_handoff/

    Obsidian vault:
      yoonsul_wait_order_handoff/docs/

Reason:

- Obsidian sees only documentation files.
- Code, SQL, Flutter, environment files, and .git internals are not mixed into the vault view.
- Mobile drafting remains focused.
- PC can still manage the entire repository.

If needed, mobile may temporarily store new documents in a flat draft folder.

---

## 9. Mobile Draft Folder

Recommended mobile draft folder:

    docs/mobile_drafts/

or:

    docs/_mobile_inbox/

The mobile draft folder may temporarily contain new Markdown files before PC-side sorting.

Purpose:

- avoid deciding final folder on mobile
- prevent wrong folder placement
- keep drafting fast
- allow PC-side controlled import
- reduce mobile errors

PC later moves documents into final folders.

---

## 10. Draft File Naming Rule

Even in mobile draft folder, filenames should preserve document number and title.

Recommended filename format:

    05470_Mobile_Obsidian_Git_Draft_Capture_And_PC_Import_Workflow_Policy.md

Rules:

- start with document number
- use English title
- use underscores
- avoid spaces
- avoid Korean filename for core policy docs
- use .md extension
- one document per file
- do not combine multiple policy docs in one file

Filename may be normalized later on PC.

---

## 11. Mobile Draft Header Rule

Each mobile draft should begin with:

    # [Document Number] [Document Title]

Example:

    # 05470 Mobile Obsidian Git Draft Capture And PC Import Workflow Policy

The first heading must match the intended filename.

This helps PC-side import and duplicate detection.

---

## 12. Copy Capture Rule

When copying from ChatGPT to Obsidian:

1. copy only the Markdown document body
2. preserve heading
3. preserve tables
4. preserve indentation
5. avoid adding chat commentary inside the file
6. verify file begins with one H1 title
7. verify file ends after conclusion
8. save as .md

Do not paste multiple documents into one file.

---

## 13. Chat Commentary Exclusion Rule

The following should not be included inside the .md file:

- Korean assistant introduction
- "다음은..." explanation
- chat conversation text
- copy instruction
- ads or UI text
- tool output
- unrelated commentary
- raw citations unless part of document evidence
- temporary mobile notes unless clearly marked

Only the Markdown policy document should be stored.

---

## 14. Mobile Git Start Rule

Before mobile drafting session:

    git pull

Purpose:

- align with PC changes
- avoid editing stale files
- reduce conflicts
- confirm repository is reachable
- confirm mobile branch is current

Do not start mobile drafting against stale repo if PC recently pushed changes.

---

## 15. Mobile Git End Rule

After mobile drafting session:

    git status
    git add docs
    git commit -m "docs: add mobile policy drafts"
    git push

Commit message may be more specific:

    docs: add mobile obsidian git workflow policy
    docs: add saas pricing and pilot policies
    docs: add provider rollout policy drafts

Mobile commits should be small enough to review.

---

## 16. PC Git Start Rule

Before PC sorting session:

    git pull

Purpose:

- receive mobile drafts
- avoid overwriting mobile work
- review new files
- normalize folders
- update indexes

PC should not start folder movement without pulling latest mobile commits.

---

## 17. PC Git End Rule

After PC sorting:

    git status
    git add docs
    git commit -m "docs: organize mobile draft policies"
    git push

PC commit should include:

- moved files
- renamed files
- updated index
- updated README
- duplicate cleanup where applicable

PC should remain the authority for structure.

---

## 18. Conflict Prevention Rule

To avoid Git conflicts:

- mobile creates new files
- PC moves and normalizes files
- mobile avoids editing files recently moved by PC
- PC pulls before moving
- mobile pulls after PC push
- do not edit the same file on both devices before sync
- do not use Google Drive or OneDrive sync on the same repo folder
- do not run multiple sync tools against the same vault

Simple rule:

    Work before pull is risky.
    Work after pull is safer.
    Work after push is preserved.

---

## 19. Obsidian Sync Boundary

If Obsidian Sync is used later, it must not conflict with Git.

Recommended rule:

    Do not combine Obsidian Sync and Git on the same active repository folder unless carefully tested.

Preferred for this project:

    GitHub handles source synchronization.
    Obsidian handles local editing.

This avoids multi-sync conflict.

---

## 20. Google Docs Boundary

Google Docs may still be used for:

- legacy document backup
- external sharing
- legal/patent draft sharing
- non-technical business writing
- temporary emergency capture
- review with non-Git users

Google Docs should not be used as primary source for numbered Markdown policy documents after this workflow shift.

If Google Docs is used temporarily, the document should later be converted to .md and stored in Git.

---

## 21. Mobile Draft Status Values

Recommended mobile draft status values:

- `MOBILE_CAPTURED`
- `MOBILE_COMMITTED`
- `PC_PULLED`
- `PC_SORTED`
- `INDEXED`
- `REVIEWED`
- `DUPLICATE_CHECKED`
- `ARCHIVED`
- `SUPERSEDED`

These may be tracked later in an index file.

---

## 22. Draft Inbox Review Rule

PC-side draft inbox review should check:

1. file exists
2. file has correct number
3. file has correct title
4. file has one H1
5. document is complete
6. no chat commentary included
7. no duplicate document number
8. no duplicate topic
9. no secret or credential included
10. final folder destination identified
11. index update needed
12. cross-reference update needed

This review can be batched.

---

## 23. Temporary Folder Movement Deferral

During mobile production phase, it is acceptable to defer folder placement.

Allowed:

    save all new docs into docs/_mobile_inbox/

Then later on PC:

    move docs into correct folder cluster

This prevents mobile workflow from slowing down document production.

---

## 24. Index Update Deferral

Index update may be deferred during mobile production.

Allowed:

- create files now
- update index later
- update README later
- update directory map later
- update cross-reference later

But PC must eventually reconcile index.

Unindexed documents should not remain untracked indefinitely.

---

## 25. Numbering Discipline

Even if folder movement is deferred, numbering must remain disciplined.

Rules:

- do not reuse document number
- do not skip intentionally without note
- use inserted numbers only when needed
- keep sequence visible
- record superseded documents later
- PC should detect gaps and duplicates

Mobile drafting must preserve document number.

---

## 26. Secret Safety Rule

Mobile Markdown files must never include:

- Supabase service role key
- GitHub token
- SSH private key
- Toss secret key
- PAYCO secret
- OKPOS partner credential
- payment provider secret
- webhook secret
- customer CI/DI
- raw card data
- production database password
- local environment secrets

If such data is needed later, reference it as:

    [SECRET STORED OUTSIDE DOCS]

Do not paste secrets into Obsidian or Git.

---

## 27. Mobile Device Risk Rule

Mobile device may be lost, stolen, or compromised.

Required discipline:

- device lock enabled
- avoid storing secrets
- use GitHub authentication carefully
- avoid plaintext tokens in notes
- avoid copying provider credentials
- revoke mobile credentials if device is lost
- do not store production keys in vault
- prefer SSH key with passphrase where feasible

Documentation files are less sensitive than credentials, but still valuable.

---

## 28. Commit Message Rule

Commit message should be simple and useful.

Examples:

    docs: add mobile obsidian git workflow policy
    docs: add pilot-to-paid saas conversion policy
    docs: add early saas customer success policy
    docs: add pricing experiment policy drafts
    docs: organize mobile inbox provider docs

Avoid vague messages like:

    update
    fix
    docs
    mobile
    tmp

Commit messages help later recovery.

---

## 29. Daily Mobile Routine

Recommended daily mobile routine:

    1. git pull
    2. open Obsidian
    3. create new .md files
    4. paste Markdown documents
    5. verify headings and filenames
    6. git status
    7. git add docs
    8. git commit
    9. git push

If network is unavailable:

    save locally
    commit locally if possible
    push when network returns

---

## 30. Daily PC Routine

Recommended PC routine:

    1. git pull
    2. review docs/_mobile_inbox/
    3. move files into folder clusters
    4. normalize filenames
    5. update index
    6. check duplicates
    7. run lightweight review
    8. git status
    9. git add docs
    10. git commit
    11. git push

PC session should turn mobile drafts into structured repository content.

---

## 31. Offline Work Rule

If mobile is offline:

- continue drafting in Obsidian
- avoid editing files likely changed on PC
- do not delete files
- commit locally if possible
- push later
- after reconnect, pull carefully if local commits exist

If conflict occurs, resolve on PC where possible.

---

## 32. Conflict Handling Rule

If Git conflict occurs:

1. stop additional editing
2. identify conflicted files
3. preserve both versions if unsure
4. do not delete conflict markers blindly
5. resolve on PC if possible
6. verify document number and title
7. commit resolved version
8. update index if needed

Conflict resolution should be careful.

Documentation conflicts can create silent content loss.

---

## 33. Mobile Draft Batch Rule

Mobile may produce batches of documents.

Recommended batch size:

- 1 to 5 documents per mobile commit
- larger batch acceptable if only new files
- avoid mixing new docs with major edits
- avoid mixing docs and code
- avoid mixing multiple unrelated folder moves

For long document production sessions, commit every few documents.

---

## 34. File Integrity Check

Before commit, check:

- file opens in Obsidian
- Markdown heading is visible
- tables are not broken
- file is not empty
- content is complete
- no chat introduction included
- no accidental duplicate paste
- no secret included
- filename matches document title

This check prevents later cleanup burden.

---

## 35. PC Import Checklist

When PC pulls mobile drafts, check:

1. Are new files in mobile inbox?
2. Are file numbers unique?
3. Are titles consistent?
4. Are documents complete?
5. Are folder destinations clear?
6. Are index entries needed?
7. Are related documents adjacent?
8. Are superseded documents marked?
9. Are duplicates detected?
10. Are cross-references needed?
11. Are secrets absent?
12. Is commit ready?

PC import should be systematic.

---

## 36. Future Automation Candidate

Later automation may include:

- numbering validator
- filename validator
- duplicate title detector
- missing index detector
- mobile inbox importer
- README updater
- document cluster report
- secret scanner
- Markdown lint
- cross-reference checker

Automation is deferred.

Manual discipline comes first.

---

## 37. Anti-Patterns

The following are prohibited:

- using Google Docs as hidden primary source after switching to Markdown
- storing multiple documents in one .md file
- saving ChatGPT commentary inside policy document
- editing same file on PC and mobile without pull/push
- using Obsidian Sync and Git together without testing
- storing secrets in Obsidian vault
- making massive mobile folder moves
- pushing vague commits repeatedly
- leaving mobile drafts unindexed forever
- deleting conflicted files without review
- treating GitHub as backup only instead of source of truth
- relying only on phone storage without Git push

---

## 38. Non-Goals

This document does not define:

- final Termux setup
- final Obsidian Git plugin setup
- final GitHub authentication method
- final PC automation script
- final folder tree
- final index generator
- final Markdown lint rule
- final CI validation
- final documentation publication pipeline

Those belong to later tooling setup and documentation operations.

---

## 39. Readiness Check

This document is ready when the project can answer:

1. What is the new mobile Markdown workflow?
2. What is the source of truth?
3. What is mobile responsible for?
4. What is PC responsible for?
5. What folder should Obsidian open?
6. What mobile draft folder may be used?
7. What filename rule applies?
8. What content should not be pasted into .md?
9. What must be done before mobile work?
10. What must be done after mobile work?
11. What must be done before PC sorting?
12. How are conflicts prevented?
13. What is the Google Docs boundary?
14. How is numbering preserved?
15. What secret safety rule applies?
16. What daily mobile routine applies?
17. What daily PC routine applies?
18. How is offline work handled?
19. How are conflicts handled?
20. What PC import checklist applies?
21. What anti-patterns are prohibited?

If these questions cannot be answered, mobile Obsidian Git workflow planning is incomplete.

---

## 40. Conclusion

The documentation workflow should shift from Google Docs-centered drafting to Markdown-first mobile capture.

The recommended flow is:

    ChatGPT
        -> Obsidian Mobile .md file
        -> mobile Git commit/push
        -> GitHub
        -> PC git pull
        -> folder normalization
        -> index update
        -> review and future implementation preparation

The key rules are:

- GitHub is source of truth
- mobile creates and commits drafts
- PC normalizes and indexes
- work starts with pull
- work ends with commit and push
- Google Docs becomes fallback, not primary
- secrets must never enter Markdown docs
- folder movement can be deferred to PC
- document production should continue without being blocked by Google Docs instability

This document preserves ubiquitous mobile documentation production while keeping PC-side structural control.