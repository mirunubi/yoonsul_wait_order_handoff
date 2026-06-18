# 014040_Policy_Mobile_PC_Git_Conflict_Prevention_Recovery

## 1. Purpose

This document defines the Git conflict prevention, conflict recovery, duplicate file handling, accidental deletion recovery, partial mobile capture recovery, PC/mobile sync discipline, and documentation safety policy for the Yoonsul Wait/Order Handoff documentation project.

The previous documents defined:

- mobile Obsidian Git draft capture workflow
- PC import and mobile inbox cleanup workflow

This document defines how to prevent and recover from Git conflicts between mobile and PC environments.

This document does not configure Git, implement automation, create recovery scripts, or modify repository settings.

It defines safety and recovery policy only.

---

## 2. Scope

This document covers:

- mobile and PC sync discipline
- Git pull-before-work rule
- Git push-after-work rule
- conflict prevention
- conflict detection
- conflict recovery
- duplicate file recovery
- accidental deletion recovery
- partial capture recovery
- stale branch recovery
- offline work safety
- Obsidian vault safety
- documentation integrity
- no-implementation boundary

This document does not cover:

- final Git setup
- final SSH key setup
- final Termux setup
- final Obsidian Git plugin setup
- final conflict resolution script
- final CI validation
- final repository protection rule
- final GitHub branch policy

---

## 3. Core Principle

Mobile and PC must never compete for the same file without synchronization.

The project must follow this rule:

> Before editing, pull. After editing, commit and push. Do not edit the same file on mobile and PC without syncing.

Most conflicts are preventable by disciplined workflow.

---

## 4. Source Of Truth

The source of truth is:

    GitHub repository

Local copies are working copies.

This means:

- mobile local files are not final until pushed
- PC local files are not final until pushed
- GitHub remote represents shared project state
- Obsidian is editor, not source of truth
- Google Docs is fallback or legacy source, not source of truth

---

## 5. Daily Safety Rule

Daily safety rule:

    Work starts with pull.
    Work ends with commit and push.

Mobile:

    git pull
    edit/create docs
    git add docs
    git commit
    git push

PC:

    git pull
    sort/review docs
    git add docs
    git commit
    git push

Skipping pull increases conflict risk.

Skipping push increases data loss risk.

---

## 6. Role Separation Rule

Recommended role separation:

| Device | Primary Role |
| ------ | ------------ |
| Mobile | create new Markdown drafts |
| PC | normalize folders, filenames, index, duplicate review |
| GitHub | shared source of truth |
| Obsidian | local Markdown editor |
| Cursor / VSCode | structured repository review |

Mobile should avoid large-scale moves.

PC should avoid editing a file that mobile may still be drafting.

---

## 7. Safe Mobile Work Pattern

Safe mobile pattern:

1. pull latest repository
2. create new file in mobile inbox
3. paste one document
4. verify H1 and filename
5. save
6. commit small batch
7. push

Safe mobile document type:

- new policy document
- minor typo fix in file created during same session
- mobile note marked as draft
- temporary inbox file

Risky mobile document type:

- mass file rename
- folder movement
- index rewrite
- cross-reference rewrite
- editing old documents not recently pulled
- deleting documents
- editing files PC may have moved

---

## 8. Safe PC Work Pattern

Safe PC pattern:

1. pull latest repository
2. inspect mobile inbox
3. move files into clusters
4. normalize filenames
5. update index
6. check duplicates
7. commit
8. push

Safe PC document type:

- folder movement
- filename normalization
- index update
- duplicate merge
- superseded marking
- archive movement
- cross-reference cleanup

Risky PC document type:

- editing same draft mobile is still working on
- deleting mobile inbox files without review
- rewriting many files without commit
- mixing docs cleanup with implementation code
- pushing before checking staged changes

---

## 9. Conflict Prevention Checklist

Before working on mobile or PC:

1. Did I pull latest?
2. Did the other device recently push?
3. Am I editing a new file or existing file?
4. Is this file likely moved by PC?
5. Is this file likely edited by mobile?
6. Am I about to rename or delete many files?
7. Do I need to commit current work first?
8. Is network stable enough to push?
9. Is the work limited to docs?
10. Are secrets excluded?

If uncertain, create a new draft file instead of editing an existing file.

---

## 10. Conflict Risk Levels

Recommended risk levels:

| Risk | Meaning |
| ---- | ------- |
| LOW | creating new numbered file after pull |
| MEDIUM | editing recently created file |
| HIGH | editing file already sorted by PC |
| HIGH | renaming/moving files on mobile |
| HIGH | editing index on mobile |
| CRITICAL | deleting files without pull/review |
| CRITICAL | resolving conflict blindly on mobile |

Mobile should stay mostly in LOW risk work.

PC can handle HIGH risk work after pull and review.

---

## 11. Conflict Detection

Git conflict may appear when:

- pull fails
- merge conflict markers appear
- same file changed on mobile and PC
- file renamed on PC but edited on mobile
- file deleted on PC but edited on mobile
- index updated on both devices
- Obsidian saved stale version after pull

Conflict markers may look like:

    <<<<<<< HEAD
    current local version
    =======
    incoming version
    >>>>>>> branch

Do not leave conflict markers in final documents.

---

## 12. Immediate Conflict Response

When conflict occurs:

1. stop editing
2. do not paste new content into conflicted file
3. identify conflicted files
4. preserve both versions if unsure
5. resolve on PC if possible
6. check document number and title
7. remove conflict markers only after comparing content
8. run document completeness check
9. commit resolved version
10. push resolved state

Conflict recovery should be calm and deliberate.

---

## 13. Preferred Conflict Resolution Location

Preferred location for conflict resolution:

    PC

Reason:

- larger screen
- better diff tools
- easier file movement
- safer comparison
- easier backup
- easier index update
- easier duplicate detection

Mobile conflict resolution should be avoided unless simple and obvious.

---

## 14. Conflict Resolution Decision Types

Possible conflict resolution decisions:

- keep mobile version
- keep PC version
- merge both versions
- split into two documents
- mark one as superseded
- archive duplicate
- recreate from ChatGPT output
- regenerate document
- restore from Git history

Decision should preserve content before deletion.

---

## 15. Duplicate File Recovery

Duplicate files may occur when:

- mobile creates document already created on PC
- Google Docs version imported after mobile version
- same document pasted twice
- filename changed but old file remains
- PC move creates copy instead of move
- conflict resolved by duplicating file

Duplicate recovery steps:

1. compare titles
2. compare document numbers
3. compare content length
4. compare completeness
5. choose canonical version
6. merge missing content if needed
7. mark duplicate as superseded or archive
8. update index
9. commit cleanup

Do not delete duplicate without checking content.

---

## 16. Duplicate Number Rule

If two files have same document number:

1. determine whether they are same document
2. if same, merge or choose canonical
3. if different, renumber one document
4. update filename and H1
5. update index
6. update cross-references
7. record reason if needed

Document number collision must be resolved before final indexing.

---

## 17. Duplicate Title Rule

If two files have same or nearly same title:

1. check if one is older draft
2. check if one is superseded
3. check if one has broader scope
4. check if one should be split
5. keep both only if scope differs clearly
6. update title to distinguish purpose

Ambiguous duplicate titles create future confusion.

---

## 18. Accidental Deletion Recovery

Accidental deletion may occur during:

- mobile cleanup
- PC folder movement
- Obsidian file deletion
- Git conflict resolution
- archive cleanup
- Google Docs migration
- batch renaming

Recovery steps:

1. stop further cleanup
2. check git status
3. if deletion not committed, restore file
4. if deletion committed, restore from Git history
5. check whether file was moved instead of deleted
6. verify index
7. commit recovery
8. record if deletion affected document lineage

Do not panic-delete additional files.

---

## 19. Partial Capture Recovery

Partial capture may occur when:

- ChatGPT output was copied incompletely
- Obsidian crashed
- mobile paste stopped
- file saved before full document
- network interrupted
- app memory issue truncated text

Recovery steps:

1. mark file as partial
2. do not index as complete
3. compare with chat output if available
4. regenerate document if necessary
5. replace or complete file
6. verify conclusion exists
7. verify readiness check exists
8. commit complete version

Partial documents should not be treated as final.

---

## 20. Stale Branch Recovery

Stale branch risk occurs when mobile or PC works without pulling for a long time.

Signs:

- many files changed locally
- pull creates many conflicts
- PC folder changed but mobile still uses old paths
- index mismatch
- mobile creates files in old folder structure

Recovery:

1. commit local work if safe
2. pull carefully
3. resolve conflicts on PC
4. move stale-path files into current inbox
5. update index
6. push clean state
7. pull on mobile after PC cleanup

Avoid long unsynced periods.

---

## 21. Offline Work Safety

Offline work may be necessary during travel.

Rules:

- create new files only
- avoid editing old files
- avoid deleting files
- avoid renaming files
- avoid index changes
- commit locally if possible
- push when network returns
- pull before starting next online session
- resolve conflicts on PC if any

Offline work should be additive.

---

## 22. Obsidian Save Safety

Obsidian may autosave files.

Risks:

- stale file overwritten after Git pull
- conflicted file rendered oddly
- mobile app reopens older buffer
- file renamed externally while open
- vault cache not refreshed

Safety rules:

- close file before large Git operations if possible
- after pull, refresh/reopen vault if needed
- avoid editing files during Git pull
- avoid keeping same file open on two devices
- confirm file path after PC move

Obsidian is a powerful editor but not a Git safety system by itself.

---

## 23. Obsidian Plugin Boundary

If Obsidian Git plugin is used:

- test with small files first
- disable overly aggressive auto-push if unstable
- verify commit messages
- ensure pull happens before edit
- check conflict behavior
- do not assume plugin resolves conflicts safely
- keep manual Git knowledge as fallback

Plugin convenience must not replace Git discipline.

---

## 24. Termux / Mobile Git Boundary

If Termux or mobile Git app is used:

- confirm repo path
- confirm branch
- run git status before add
- add docs only, not entire phone storage
- avoid staging app cache
- avoid staging secrets
- commit small batches
- push after commit
- handle authentication securely

Mobile Git must be treated as real Git, not a sync toy.

---

## 25. Wrong Folder Recovery

Wrong folder placement may happen on mobile.

Recovery:

- do not worry during drafting
- PC moves file later
- update index
- update cross-reference if needed
- keep document number unchanged
- commit move separately if large batch

Wrong folder is not critical if document number and title are correct.

---

## 26. Wrong Filename Recovery

Wrong filename may happen when:

- title is too long
- typo occurs
- number missing
- spaces used
- Korean filename used accidentally
- duplicate name created

Recovery:

1. compare H1 title
2. rename file on PC
3. preserve document number
4. update index
5. commit rename

Filename can be corrected later.

Content loss is more serious than filename imperfection.

---

## 27. Wrong Document Number Recovery

Wrong number is more serious.

Recovery:

1. identify intended sequence
2. check if number already used
3. decide whether to renumber
4. update H1
5. update filename
6. update index
7. update related references
8. record if document was inserted

Avoid reusing numbers.

---

## 28. Chat Commentary Recovery

If chat commentary is accidentally saved inside .md file:

1. remove Korean intro/commentary from file
2. keep only policy document body
3. remove outer code fence if included
4. remove code block id artifact
5. verify H1
6. verify conclusion
7. commit cleanup

Chat commentary belongs outside repository policy file unless intentionally stored as note.

---

## 29. Code Fence Artifact Recovery

If whole document is wrapped in:

    ```markdown
    ...
    ```

then PC cleanup should remove outer fence.

Policy file should be pure Markdown.

Nested code examples inside document should remain only if intentional and safely indented or fenced according to project style.

---

## 30. Secret Exposure Recovery

If secret is accidentally committed:

1. stop using exposed secret
2. rotate credential immediately
3. remove secret from current file
4. consider Git history cleanup if necessary
5. document incident if appropriate
6. review mobile clipboard and notes
7. check whether secret was pushed to remote
8. update secret safety practice

Do not simply delete secret from latest commit and assume safe if already pushed.

---

## 31. Branch Strategy

Recommended early strategy:

    main branch only for documentation drafting

Reason:

- simpler mobile workflow
- fewer branch conflicts
- easier pull/push
- less cognitive load

Later, branches may be introduced for implementation.

During mobile documentation phase, simplicity is safer.

---

## 32. Commit Granularity

Recommended commit granularity:

- mobile: 1 to 5 new documents
- PC: one normalization batch
- index: separate commit if large
- archive/superseded cleanup: separate commit
- conflict resolution: separate commit

Smaller commits improve recovery.

---

## 33. Recovery Commit Message Examples

Good examples:

    docs: resolve mobile inbox duplicate policy drafts
    docs: recover partial mobile capture for 05490
    docs: restore accidentally deleted provider policy
    docs: normalize filename after mobile draft
    docs: remove chat artifacts from mobile imported docs
    docs: resolve conflict in mobile workflow policy

Avoid:

    fix
    conflict
    oops
    recovery
    update

Commit messages should explain recovery.

---

## 34. Safety Snapshot Rule

Before large PC cleanup:

- ensure latest mobile changes are pushed
- pull on PC
- commit current clean state
- then perform large moves
- commit after moves
- push
- mobile pulls after cleanup

This gives restore point.

Large cleanup without snapshot increases risk.

---

## 35. Mobile After PC Cleanup Rule

After PC performs folder moves or index cleanup, mobile must:

    git pull

before creating new docs.

If mobile continues from old folder view, duplicate stale paths may appear.

---

## 36. PC After Mobile Batch Rule

After mobile produces a document batch, PC must:

    git pull

before any sorting.

PC should not recreate documents already produced on mobile.

---

## 37. File Lock Discipline

There is no real file lock across mobile and PC.

Therefore:

- do not rely on "I think this file is safe"
- use pull/push discipline
- prefer new files on mobile
- prefer old file edits on PC
- communicate mentally by commit history and index

Git discipline replaces file locking.

---

## 38. Documentation Integrity Checklist

Before marking imported docs ready:

1. correct number
2. correct title
3. correct filename
4. complete body
5. no chat artifact
6. no conflict marker
7. no duplicate number
8. no secret
9. correct folder
10. index updated
11. related docs not broken
12. commit pushed

This checklist should be applied during PC import.

---

## 39. Anti-Patterns

The following are prohibited:

- editing without pulling first
- ending work without pushing
- editing same file on mobile and PC at the same time
- resolving conflict blindly on mobile
- deleting duplicate without comparing
- ignoring conflict markers
- leaving partial documents indexed as complete
- using Google Drive/OneDrive sync on same Git folder
- relying on Obsidian autosave as backup
- storing secrets in mobile vault
- doing massive mobile folder moves
- mixing documentation conflict recovery with implementation changes
- working offline on old files instead of new files
- using vague commit messages for recovery

---

## 40. Non-Goals

This document does not define:

- final Git branch protection
- final merge strategy
- final CI conflict checks
- final mobile Git client
- final Obsidian plugin settings
- final secret scanning automation
- final backup service
- final documentation automation

Those belong to later tooling and repository governance.

---

## 41. Readiness Check

This document is ready when the project can answer:

1. What is the source of truth?
2. What is the daily safety rule?
3. How are mobile and PC roles separated?
4. What is safe mobile work?
5. What is safe PC work?
6. What conflict prevention checklist applies?
7. What conflict risk levels exist?
8. How is conflict detected?
9. What immediate response is required?
10. Where should conflicts be resolved?
11. What conflict resolution decisions exist?
12. How are duplicate files recovered?
13. How is duplicate number handled?
14. How is accidental deletion recovered?
15. How is partial capture recovered?
16. How is stale branch recovered?
17. How is offline work handled?
18. What Obsidian save safety rules apply?
19. What mobile Git boundary applies?
20. How is wrong folder or filename corrected?
21. How is wrong document number corrected?
22. How are chat artifacts removed?
23. How is secret exposure handled?
24. What branch strategy is recommended?
25. What commit granularity is recommended?
26. What safety snapshot rule applies?
27. What anti-patterns are prohibited?

If these questions cannot be answered, mobile/PC Git conflict prevention and recovery planning is incomplete.

---

## 42. Conclusion

Mobile Obsidian plus Git creates a strong ubiquitous documentation workflow, but only if Git discipline is strict.

The safe operating rule is:

    pull before work
    create new files on mobile
    normalize on PC
    commit small batches
    push after work
    resolve conflicts on PC
    never store secrets

The project should treat mobile as a powerful draft production station and PC as the structural normalization station.

This document protects documentation integrity while allowing high-speed mobile Markdown production during travel or away from the main development machine.