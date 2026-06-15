# 14042_Policy_Mobile_Documentation_Workflow_Transition_Gate

## 1. Purpose

This document defines the index, readiness check, transition gate, operational discipline, and continuation policy for the mobile Obsidian, GitHub, PC import, and documentation normalization workflow in the Yoonsul Wait/Order Handoff documentation project.

The previous documents established:

- mobile Obsidian Git draft capture workflow
- PC documentation import and normalization workflow
- mobile/PC Git conflict prevention and recovery workflow

This document consolidates those policies into a workflow index and transition gate.

This document does not configure Obsidian, Git, GitHub, Termux, PC repository, or automation.

It defines workflow readiness and transition governance only.

---

## 2. Scope

This document covers:

- mobile documentation workflow index
- workflow readiness check
- mobile production gate
- PC import gate
- Git sync gate
- conflict recovery gate
- mobile inbox management gate
- source-of-truth confirmation
- Google Docs fallback boundary
- future automation candidates
- no-implementation boundary

This document does not cover:

- final mobile Git installation
- final Obsidian plugin setup
- final SSH key setup
- final GitHub authentication setup
- final PC directory tree
- final documentation automation
- final implementation workflow
- final CI validation

---

## 3. Core Principle

Mobile documentation production must be fast, but repository integrity must remain controlled.

The project must follow this rule:

> Mobile may accelerate document creation, but GitHub remains the source of truth and PC remains the structural normalization authority.

Speed without synchronization creates loss.

Synchronization without structure creates clutter.

The workflow must support both speed and control.

---

## 4. Workflow Document Index

This workflow cluster consists of:

| Document | Title | Purpose |
| -------- | ----- | ------- |
| 05470 | Mobile Obsidian Git Draft Capture And PC Import Workflow Policy | Defines mobile-first Markdown capture and GitHub sync |
| 05480 | PC Documentation Import Normalization Index And Mobile Inbox Cleanup Policy | Defines PC-side pull, sorting, naming, indexing, and cleanup |
| 05490 | Mobile PC Git Conflict Prevention Recovery And Documentation Safety Policy | Defines conflict prevention, recovery, and documentation safety |
| 05500 | Mobile Documentation Workflow Index Readiness Check And Transition Gate Policy | Consolidates workflow readiness and transition gate |

This cluster should be treated as the mobile documentation workflow foundation.

---

## 5. Source Of Truth Confirmation

The source of truth is:

    GitHub repository

The working roles are:

| Tool | Role |
| ---- | ---- |
| ChatGPT | Markdown document generation |
| Obsidian Mobile | Markdown capture and light editing |
| Mobile Git / Termux / Git App | commit and push |
| GitHub | remote source of truth |
| PC Git | pull and normalize |
| Cursor / VSCode | review, folder movement, index, implementation readiness |
| Google Docs | fallback or legacy import only |

No other sync layer should silently override GitHub.

---

## 6. Recommended Operating Model

Recommended operating model:

    Mobile:
      create new Markdown documents

    GitHub:
      preserve source and history

    PC:
      pull, normalize, index, and prepare implementation

    Google Docs:
      no longer primary for numbered policy documents

This model supports travel, mobile drafting, and PC-side control.

---

## 7. Mobile Production Gate

Mobile production is ready when:

1. mobile repository is cloned
2. Obsidian can open docs folder or mobile inbox
3. Git pull works
4. Git commit works
5. Git push works
6. new .md file can be created
7. file can be opened on PC after pull
8. file naming rule is understood
9. secret safety rule is understood
10. mobile drafts can be placed in inbox if folder uncertain

Do not rely on mobile workflow until pull/commit/push has been tested.

---

## 8. PC Import Gate

PC import is ready when:

1. PC can pull mobile commits
2. mobile inbox folder is visible
3. PC can move files
4. PC can rename files
5. PC can update index
6. PC can check duplicates
7. PC can check for chat artifacts
8. PC can check for secrets
9. PC can commit normalization
10. PC can push normalized structure

PC import must be tested before large mobile production batches.

---

## 9. Git Sync Gate

Git sync is ready when the following loop succeeds:

    PC push
        -> mobile pull
        -> mobile creates md
        -> mobile push
        -> PC pull
        -> PC moves file
        -> PC push
        -> mobile pull

This loop proves bidirectional workflow.

Do not scale mobile document production before this loop is proven.

---

## 10. Mobile Inbox Gate

Mobile inbox is ready when:

- inbox folder exists
- mobile can save new files there
- PC can see inbox after pull
- PC can move files out
- index can record moved files
- mobile pulls after PC movement
- no stale duplicate path remains

Recommended inbox:

    docs/_mobile_inbox/

The inbox is temporary, not permanent archive.

---

## 11. Filename Gate

Filename readiness requires:

- document number at beginning
- English title
- underscores instead of spaces
- .md extension
- no duplicate number
- H1 matches filename
- no vague names such as draft.md

Example:

    05500_Mobile_Documentation_Workflow_Index_Readiness_Check_And_Transition_Gate_Policy.md

Filename can be normalized on PC, but mobile should preserve number and title as much as possible.

---

## 12. Content Gate

A mobile-captured document is acceptable when:

- it starts with H1
- it has Purpose
- it has Scope
- it has Core Principle
- it has Non-Goals if appropriate
- it has Readiness Check
- it has Conclusion
- it contains no chat intro
- it contains no outer code fence
- it contains no conflict marker
- it contains no secrets

PC can clean minor formatting issues.

PC should not accept incomplete or unsafe content as ready.

---

## 13. Sync Discipline Gate

The workflow is disciplined when:

- mobile pulls before work
- mobile commits and pushes after work
- PC pulls before sorting
- PC commits and pushes after sorting
- mobile pulls after PC cleanup
- PC does not recreate mobile-produced docs
- mobile does not edit files PC is sorting
- conflicts are resolved on PC when possible

This discipline is more important than tool choice.

---

## 14. Conflict Recovery Gate

Conflict recovery is ready when:

- conflicted files can be identified
- user knows not to continue editing conflicted files
- PC can compare versions
- duplicate files can be merged or archived
- accidental deletion can be restored
- partial capture can be marked
- wrong filename can be corrected
- wrong folder can be corrected
- wrong number can be corrected carefully
- secret exposure response is understood

If conflict recovery is not understood, mobile workflow should remain limited to new files only.

---

## 15. Google Docs Transition Gate

Google Docs should move to fallback status when:

- Obsidian mobile capture works
- Git push works
- PC pull works
- PC import works
- mobile/PC conflict prevention is understood
- new documents can be created directly as .md

Google Docs may remain for:

- legacy documents
- external sharing
- patent/business collaboration
- emergency temporary capture
- non-repository writing

Numbered project policy docs should be Markdown-first.

---

## 16. Mobile Document Batch Gate

Mobile batch production is allowed when:

- sync loop tested
- inbox exists
- filenames are stable
- Git push works
- PC import cadence is planned
- batch size is manageable
- no large PC cleanup is pending
- mobile has pulled after latest PC changes

Recommended batch size:

    1 to 5 documents per mobile commit

Larger batches are allowed only if all files are new and simple.

---

## 17. PC Cleanup Batch Gate

PC cleanup batch is allowed when:

- latest mobile commits are pulled
- working tree is understood
- cleanup scope is limited
- backup/snapshot commit exists if needed
- moved files are intentional
- deleted files are intentional
- no code files are accidentally staged
- index update is planned
- commit message is clear

Large moves should be done after a clean commit.

---

## 18. Index Readiness Gate

Index is ready when it can answer:

- what documents exist
- where each document is stored
- which documents are draft
- which are reviewed
- which are superseded
- which are mobile-imported
- which cluster each document belongs to
- which document comes next
- which documents need cleanup
- which documents need cross-reference review

Index does not need to be perfect during drafting, but it must not become misleading.

---

## 19. Repository Safety Gate

Repository safety requires:

- no secrets in docs
- no mobile app cache staged
- no environment files staged
- no accidental binary files staged
- no code implementation mixed into documentation commits
- no destructive delete without review
- no duplicate document numbers left unresolved
- no conflict markers committed
- no partial documents marked ready

Safety gates protect future implementation.

---

## 20. Implementation Boundary

This mobile workflow is for documentation production.

It does not authorize:

- SQL implementation
- Flutter implementation
- provider integration
- payment integration
- KDS runtime implementation
- Mini Kiosk runtime implementation
- security configuration
- deployment changes
- production credential handling

The project remains in documentation and readiness phase unless separately authorized.

---

## 21. Future Automation Candidates

Future automation may support:

- mobile inbox scanner
- filename validator
- H1 validator
- duplicate number checker
- duplicate title checker
- index generator
- secret scanner
- Markdown table checker
- cross-reference checker
- superseded document detector
- import review report generator
- docs readiness dashboard

Automation is useful later.

Manual workflow should be stable first.

---

## 22. Transition Checklist

Before switching fully from Google Docs to Obsidian/Git:

1. PC repository is clean.
2. GitHub remote is reachable.
3. mobile clone exists.
4. Obsidian opens docs folder.
5. mobile can create .md file.
6. mobile can commit and push.
7. PC can pull mobile file.
8. PC can move and rename file.
9. PC can commit and push.
10. mobile can pull PC changes.
11. no sync conflict appears.
12. Google Docs is treated as fallback.
13. secret safety is understood.
14. mobile inbox is defined.
15. PC import routine is understood.

Only after this checklist should mobile-first production become default.

---

## 23. Daily Operating Checklist

Daily mobile checklist:

    1. git pull
    2. create new document
    3. verify filename and H1
    4. commit
    5. push

Daily PC checklist:

    1. git pull
    2. inspect mobile inbox
    3. normalize files
    4. update index
    5. commit
    6. push

Daily principle:

    pull before work
    push after work

---

## 24. Risk Register

Workflow risks:

| Risk | Description |
| ---- | ----------- |
| Mobile Push Missing | file exists only on phone |
| PC Pull Missing | PC works on stale repo |
| Duplicate Number | same document number reused |
| Partial Capture | mobile paste incomplete |
| Chat Artifact | intro or fence saved into md |
| Secret Exposure | credential pasted into docs |
| Folder Drift | mobile uses outdated folder |
| Index Drift | index does not reflect files |
| Conflict Marker Commit | unresolved merge text committed |
| Google Docs Divergence | Docs and Git versions differ |
| Overlarge Batch | too many files without review |
| Implementation Leakage | code work mixed into docs flow |

Risks must be managed by workflow discipline.

---

## 25. Mitigation

Mitigations:

- small commits
- mobile inbox
- PC normalization
- pull-before-work
- push-after-work
- new files on mobile
- structural edits on PC
- no secrets in docs
- periodic index update
- duplicate number check
- conflict resolution on PC
- Google Docs fallback only
- implementation deferred

The workflow should stay simple until stable.

---

## 26. Anti-Patterns

The following are prohibited:

- assuming Obsidian alone manages Git
- using Google Docs as hidden primary source
- creating many mobile docs without pushing
- PC sorting without pulling
- mobile editing files moved by PC without pulling
- storing secrets in Obsidian
- committing conflict markers
- leaving mobile inbox unmanaged
- leaving index permanently stale
- mixing implementation work with mobile docs
- using multiple sync systems on same folder
- treating fallback documents as canonical

---

## 27. Non-Goals

This document does not define:

- final tooling setup guide
- final Termux commands
- final Obsidian plugin settings
- final SSH key policy
- final GitHub branch protection
- final CI docs validator
- final index generator
- final automation workflow
- final implementation workflow

Those belong to later environment setup and repository operations.

---

## 28. Readiness Check

This document is ready when the project can answer:

1. Which documents define mobile workflow?
2. What is the source of truth?
3. What is the recommended operating model?
4. When is mobile production ready?
5. When is PC import ready?
6. What sync loop must succeed?
7. What is the mobile inbox gate?
8. What filename gate applies?
9. What content gate applies?
10. What sync discipline gate applies?
11. What conflict recovery gate applies?
12. When does Google Docs become fallback?
13. When is mobile batch production allowed?
14. When is PC cleanup batch allowed?
15. What does index readiness mean?
16. What repository safety gate applies?
17. What implementation boundary applies?
18. What future automation candidates exist?
19. What transition checklist must pass?
20. What daily checklist applies?
21. What workflow risks exist?
22. What mitigations apply?
23. What anti-patterns are prohibited?

If these questions cannot be answered, mobile documentation workflow transition is incomplete.

---

## 29. Conclusion

The project can move to a strong ubiquitous documentation workflow:

    ChatGPT document generation
        -> Obsidian mobile Markdown capture
        -> mobile Git commit and push
        -> GitHub source of truth
        -> PC pull
        -> folder normalization
        -> index update
        -> future implementation readiness

The mobile workflow allows document production during travel or away from the main development machine.

The PC workflow preserves structure, index, and safety.

This cluster closes the mobile documentation workflow foundation and prepares the project to continue high-volume Markdown production without relying on Google Docs.