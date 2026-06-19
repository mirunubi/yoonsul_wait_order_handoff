# 000050_Plan_Batch_6A_Staged_Commit_Planning_For_Completed_Six_Digit_Migration_Batches.md

## 1. Purpose

This document defines **Batch 6A — Staged Commit Planning For Completed Six-Digit Migration Batches** for the `yoonsul_wait_order_handoff` documentation migration.

Batch 6A does not rename, move, delete, rewrite links, or implement runtime code.

Its purpose is to safely prepare the already completed six-digit migration work for reviewable staged commits.

---

## 2. Current Closeout State

### 2.1 Completed Migration Batches

The following batches are considered completed before Batch 6A:

| Batch | Status |
|---|---|
| Cursor project rules | Completed and committed separately |
| Batch 5B RootGovernance rename | Completed |
| Batch 5C LowDensityDomain rename | Completed |
| Batch 5D MediumDensityDomain rename | Completed |
| Batch 5E DenseDomain rename | Completed |
| Batch 5F ManualReview / Exclusion planning | Completed as planning / hold |
| Batch 5G Global internal link integrity scan | Completed |
| Batch 5H Global H1 mismatch closeout | Completed |

Cursor project rules commit:

```text
9cff90e chore: add cursor project documentation rules
```

---

## 3. Batch 5H Final State Snapshot

Batch 5H reported:

| Metric | Count |
|---|---:|
| Total markdown files scanned | 2,517 |
| H1 matches filename | 2,482 |
| H1 updated | 10 |
| Intended title skipped | 32 |
| Missing H1 | 0 |
| Ambiguous / manual-review | 3 |

The 10 H1 updates were root governance files whose H1 still mirrored the pre-5B five-digit basename after Batch 5G content revert.

The 3 ambiguous/manual-review files were not modified:

```text
docs/02910_downloadfile.md
docs/03200_Report_...Readiness_Report-1.md
docs/03220_downloadfile-2.md
```

These remain part of the Batch 5F excluded/manual-review lane.

---

## 4. Reference Integrity Final State

Batch 5G / 5H closeout state:

| Metric | Count |
|---|---:|
| Active old 5-digit full-path references remaining | 0 |
| Broken link candidates | 0 |
| Double-prefix active patterns | 0 |
| Double-prefix historical/provenance records | 1 |

The remaining double-prefix historical/provenance record is the Batch 5G `000047` manifest `OldReference` record and is closed as `HistoricalReference`.

It must not be modified as part of Batch 6A.

---

## 5. Migration Summary

| Batch | Renamed |
|---|---:|
| Batch 5B | 39 |
| Batch 5C | 466 |
| Batch 5D | 185 |
| Batch 5E | 381 |
| AlreadyClosedHighRange | 336 |
| ManualReview / Excluded remaining | 52 |

Overall closeout status:

```text
Closed_With_ManualReview_Hold
```

Reason:

The active auto-rename lane is closed. Batch 5F manual-review/excluded items remain held for a later human-approved action batch.

---

## 6. Batch 6A Scope

### 6.1 Allowed

Batch 6A may only perform:

1. `git status` review.
2. `git diff --stat` review.
3. `git diff --name-status` review.
4. `git diff --check` validation.
5. Commit grouping plan.
6. Rollback plan.
7. Review checklist.
8. Final staged commit instruction document.

### 6.2 Forbidden

Batch 6A must not perform:

- file rename
- folder rename
- file move
- file delete
- internal link edit
- H1 edit
- formatter execution
- PowerShell `Set-Content`
- runtime implementation
- SQL migration
- Flutter / Dart implementation
- Supabase runtime change
- POS Gateway runtime change

---

## 7. Recommended Validation Commands

Run these commands from repository root.

### 7.1 Status

```bash
git status --short
```

Purpose:

- confirm all expected migration files are visible
- confirm no unexpected runtime files are modified
- confirm new `000048` and `000049` report/matrix files are untracked or staged as intended

### 7.2 Diff Stat

```bash
git diff --stat
```

Purpose:

- review migration size
- detect unexpected large non-doc changes

### 7.3 Name Status

```bash
git diff --name-status
```

Purpose:

- verify rename/move patterns from completed batches
- detect unexpected deletes
- detect unexpected source/runtime modifications

### 7.4 Whitespace Check

```bash
git diff --check
```

Expected result:

- no new whitespace errors from migration batches
- one known pre-existing trailing-whitespace warning may exist in unrelated `10005_Report_...`
- if present, classify as pre-existing and do not modify in Batch 6A

### 7.5 Focused Report Check

```bash
git diff --check -- docs/000048* docs/000049*
```

Expected result:

```text
clean
```

---

## 8. Recommended Commit Strategy

Because this migration touched a large number of files, use staged commits grouped by completed batch or risk surface.

Recommended commit grouping:

### Commit 1 — Root Governance Rename

```text
docs: migrate root governance docs to six-digit prefixes
```

Include:

- Batch 5B rename result
- root governance H1-only corrections from Batch 5H if they directly belong to root governance

### Commit 2 — Low Density Domain Rename

```text
docs: migrate low-density domains to six-digit prefixes
```

Include:

- Batch 5C result

### Commit 3 — Medium Density Domain Rename

```text
docs: migrate medium-density domains to six-digit prefixes
```

Include:

- Batch 5D result

### Commit 4 — Dense Domain Rename

```text
docs: migrate dense domains to six-digit prefixes
```

Include:

- Batch 5E result

### Commit 5 — Link Integrity And Closeout Reports

```text
docs: close out six-digit migration link and H1 reports
```

Include:

- Batch 5G report artifacts
- Batch 5H report artifacts
- `docs/000048_Report_Batch_5H_Global_H1_And_Six_Digit_Basename_Migration_Closeout.md`
- `docs/000049_Matrix_Batch_5H_Global_H1_Mismatch_Closeout.md`
- this Batch 6A planning document if created inside repository

### Commit 6 — Manual Review Manifest Hold

```text
docs: record six-digit migration manual-review hold
```

Include only if separate manual-review manifest files exist and are not already included.

Do not include actual manual-review rename/edit actions in Batch 6A.

---

## 9. Alternative Single Commit Strategy

If the repository diff is too interdependent to stage safely by batch, use one consolidated commit:

```text
docs: complete six-digit documentation migration closeout
```

Use this only if:

- rename detection becomes confusing
- staged batch commits become too risky
- review confirms no runtime/source code changes
- all migration reports are included

The consolidated commit must explicitly mention:

- Batch 5B through 5H completed
- Batch 5F manual-review hold remains
- broken link candidates after migration: 0
- active old five-digit full-path references remaining: 0
- H1 mismatch active defects: 0, excluding manual-review hold lane

---

## 10. Rollback Strategy

Before committing, capture:

```bash
git status --short > migration_status_before_commit.txt
git diff --stat > migration_diff_stat_before_commit.txt
git diff --name-status > migration_name_status_before_commit.txt
```

If staged commit fails review:

```bash
git restore --staged .
```

If a commit is created but must be reverted before push:

```bash
git reset --soft HEAD~1
```

If the commit was pushed and must be reverted publicly:

```bash
git revert <commit_sha>
```

Do not use destructive reset after push unless repository governance explicitly allows it.

---

## 11. Review Checklist Before Commit

- [ ] Cursor project rules commit remains separate.
- [ ] No runtime implementation files are included.
- [ ] No SQL migration files are included unless they are documentation-only.
- [ ] No Flutter / Dart implementation files are included.
- [ ] No Supabase runtime change is included.
- [ ] No POS Gateway runtime change is included.
- [ ] Batch 5G broken link candidates after migration remains 0.
- [ ] Active old five-digit full-path references remain 0.
- [ ] Double-prefix active patterns remain 0.
- [ ] Remaining double-prefix provenance record remains historical only.
- [ ] Batch 5H H1 active defects are closed.
- [ ] 52 manual-review/excluded items remain explicitly held.
- [ ] 3 ambiguous H1 files remain explicitly held.
- [ ] New documents use six-digit prefixes.
- [ ] New documents have H1 equal to full filename including `.md`.
- [ ] UTF-8 preserved.
- [ ] No PowerShell `Set-Content` used.
- [ ] No formatter used.

---

## 12. Cursor Instruction Block

```text
Continue yoonsul_wait_order_handoff docs six-digit migration.

Current task:
Batch 6A Staged Commit Planning For Completed Six-Digit Migration Batches.

Current closeout status:
- Batch 5B RootGovernance rename completed.
- Batch 5C LowDensityDomain rename completed.
- Batch 5D MediumDensityDomain rename completed.
- Batch 5E DenseDomain rename completed.
- Batch 5F ManualReview/Exclusion planning completed as hold.
- Batch 5G Global internal link integrity scan completed.
- Batch 5H Global H1 mismatch closeout completed.
- Cursor project rules committed separately at 9cff90e.

Known Batch 5H result:
- total markdown files scanned: 2517
- H1 matches filename: 2482
- H1 updated: 10
- intended title skipped: 32
- missing H1: 0
- ambiguous/manual-review: 3

Known link state:
- active old 5-digit full-path references remaining: 0
- broken link candidates: 0
- double-prefix active patterns: 0
- double-prefix historical/provenance records: 1

Rules:
- Do not rename files.
- Do not rename folders.
- Do not move files.
- Do not delete files.
- Do not edit internal links.
- Do not edit H1 lines.
- Do not run formatter.
- Do not use PowerShell Set-Content.
- Do not implement runtime code.
- Preserve UTF-8.
- New documents must use six-digit prefix only.

Allowed:
- git status review
- git diff stat review
- git diff name-status review
- git diff check validation
- staged commit grouping plan
- rollback plan
- final commit instruction report

Required output:
1. git status summary.
2. git diff --stat summary.
3. git diff --name-status risk review.
4. git diff --check result.
5. recommended staged commit groups.
6. rollback instructions.
7. explicit safety statement that no rename/move/delete/link edit/H1 edit/runtime implementation was performed in Batch 6A.
```

---

## 13. Recommended Next Batch After 6A

After Batch 6A, choose one of two paths:

### Path A — Commit Now

Proceed to:

```text
Batch 6B Staged Commit Execution And Post-Commit Verification
```

Use when the migration diff is clean and the human approves committing completed batches.

### Path B — Manual Hold First

Proceed to:

```text
Batch 5F-1 ManualReview Approved Action Execution
```

Use only if the human wants to resolve the 52 manual-review/excluded items before committing.

Recommended default:

```text
Batch 6B first, Batch 5F-1 later.
```

Reason:

The completed six-digit migration lane is already closed with manual-review hold. Committing it now protects the large migration work before performing any higher-risk manual-review actions.

---

## 14. Closeout Judgment For Batch 6A

Batch 6A is a planning and validation batch only.

It authorizes no mutation except creation of this planning report if the human requests it.

Recommended next action:

```text
Run Batch 6A validation, then prepare Batch 6B staged commit execution.
```
