# 000051_Plan_Batch_6B_Staged_Commit_Execution_And_Post_Commit_Verification.md

## 1. Purpose

This document defines **Batch 6B — Staged Commit Execution And Post-Commit Verification** for the `yoonsul_wait_order_handoff` six-digit documentation migration.

Batch 6B is the execution companion to Batch 6A.

Its purpose is to commit the already completed six-digit migration work safely, with reviewable staging, validation, and post-commit checks.

Batch 6B must not introduce new migration behavior.

---

## 2. Current Approved Starting State

### 2.1 Completed Before Batch 6B

The following are already completed:

| Area | Status |
|---|---|
| Cursor project rules | Completed and committed separately |
| Batch 5B RootGovernance rename | Completed |
| Batch 5C LowDensityDomain rename | Completed |
| Batch 5D MediumDensityDomain rename | Completed |
| Batch 5E DenseDomain rename | Completed |
| Batch 5F ManualReview / Exclusion planning | Completed as hold |
| Batch 5G Global internal link integrity scan | Completed |
| Batch 5H Global H1 mismatch closeout | Completed |
| Batch 6A staged commit planning | Completed |

Cursor project rules commit:

```text
9cff90e chore: add cursor project documentation rules
```

---

## 3. Batch 5H / 6A Closeout Baseline

### 3.1 H1 Closeout Summary

| Metric | Count |
|---|---:|
| Total markdown files scanned | 2,517 |
| H1 matches filename | 2,482 |
| H1 updated | 10 |
| Intended title skipped | 32 |
| Missing H1 | 0 |
| Ambiguous / manual-review | 3 |

The 3 ambiguous H1 files remain held under the Batch 5F excluded/manual-review lane:

```text
docs/02910_downloadfile.md
docs/03200_Report_...Readiness_Report-1.md
docs/03220_downloadfile-2.md
```

### 3.2 Reference Integrity Summary

| Metric | Count |
|---|---:|
| Active old 5-digit full-path references remaining | 0 |
| Broken link candidates | 0 |
| Double-prefix active patterns | 0 |
| Double-prefix historical/provenance records | 1 |

The remaining double-prefix historical/provenance record is the Batch 5G `000047` manifest `OldReference` record.

It is closed as `HistoricalReference`.

It must not be modified in Batch 6B.

### 3.3 Migration Summary

| Batch | Renamed |
|---|---:|
| Batch 5B | 39 |
| Batch 5C | 466 |
| Batch 5D | 185 |
| Batch 5E | 381 |
| AlreadyClosedHighRange | 336 |
| ManualReview / Excluded remaining | 52 |

Overall migration status:

```text
Closed_With_ManualReview_Hold
```

---

## 4. Batch 6B Scope

### 4.1 Allowed

Batch 6B may perform:

1. Final pre-commit validation.
2. Git staging.
3. Git commit creation.
4. Post-commit verification.
5. Final commit report.

### 4.2 Forbidden

Batch 6B must not perform:

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
- manual-review/excluded item resolution

The Batch 5F manual-review hold must remain untouched.

---

## 5. Pre-Commit Validation Commands

Run from repository root.

### 5.1 Status

```bash
git status --short
```

Expected:

- completed documentation migration changes are visible
- no unexpected runtime/source files are modified
- new reports such as `000048`, `000049`, and `000050` are present if created in the repository
- no manual-review/excluded actions are accidentally included

### 5.2 Diff Stat

```bash
git diff --stat
```

Review:

- migration volume is expected to be large
- no runtime implementation files should appear
- no SQL/runtime files should appear unless documentation-only

### 5.3 Name Status

```bash
git diff --name-status
```

Review:

- renamed docs match completed 5B–5E batches
- deleted files must correspond only to git rename tracking, not actual deletion intent
- no unexpected source implementation files are listed

### 5.4 Whitespace Check

```bash
git diff --check
```

Expected:

- no new whitespace errors from Batch 6B
- one known pre-existing trailing-whitespace warning in unrelated `10005_Report_...` may remain
- do not fix unrelated pre-existing whitespace in Batch 6B

### 5.5 Focused Closeout Artifact Check

```bash
git diff --check -- docs/000048* docs/000049* docs/000050*
```

Expected:

```text
clean
```

---

## 6. Recommended Commit Strategy

### 6.1 Preferred Strategy: Consolidated Migration Commit

Because the migration spans many files and internal link integrity was globally closed, the recommended default is a single consolidated commit.

Suggested commit message:

```text
docs: complete six-digit documentation migration closeout
```

Rationale:

- reduces risk of splitting interdependent rename/link changes across commits
- keeps Batch 5G global link integrity state intact
- preserves one clean rollback point
- avoids confusing partial rename history

### 6.2 Commit Body

Recommended commit body:

```text
Complete six-digit documentation basename migration closeout.

Included:
- Batch 5B RootGovernance rename
- Batch 5C LowDensityDomain rename
- Batch 5D MediumDensityDomain rename
- Batch 5E DenseDomain rename
- Batch 5G global internal link integrity closeout
- Batch 5H global H1 mismatch closeout
- Batch 6A staged commit planning artifacts

Validation:
- active old 5-digit full-path references remaining: 0
- broken link candidates: 0
- double-prefix active patterns: 0
- H1 missing count: 0
- active H1 mismatch defects closed
- remaining double-prefix record classified as historical/provenance only

Hold:
- Batch 5F manual-review/excluded items remain held
- 52 manual-review/excluded manifest items are not modified
- 3 ambiguous H1 files are not modified

Safety:
- no runtime implementation
- no SQL migration
- no Flutter/Dart implementation
- no Supabase runtime change
- no POS Gateway runtime change
```

---

## 7. Staging Commands

### 7.1 Review Before Stage

```bash
git status --short
```

### 7.2 Stage Documentation Migration Changes

If the migration is entirely under `docs/`, stage only `docs/`:

```bash
git add docs
```

If SOP files were also part of the migration and confirmed in Batch 5G/5H, stage both:

```bash
git add docs sop
```

Do not stage runtime/source directories.

### 7.3 Review Staged Files

```bash
git diff --cached --stat
git diff --cached --name-status
```

Confirm:

- staged files are documentation/governance only
- no runtime implementation files are included
- no manual-review action lane changes are accidentally included beyond reports/manifests

### 7.4 Staged Whitespace Check

```bash
git diff --cached --check
```

Expected:

- clean, or only known pre-existing unrelated warning if already present and unavoidable
- do not fix unrelated files in Batch 6B

---

## 8. Commit Command

Use:

```bash
git commit -m "docs: complete six-digit documentation migration closeout"
```

If using a multi-line commit body:

```bash
git commit
```

Then paste the commit subject and body from Section 6.2.

---

## 9. Post-Commit Verification

After commit, run:

### 9.1 Status

```bash
git status --short
```

Expected:

- clean, except intentionally untracked local evidence files if any
- no unexpected modified files

### 9.2 Latest Commit

```bash
git log --oneline -3
```

Expected:

- latest commit is the Batch 6B migration closeout commit
- previous Cursor rules commit remains in history as separate commit

### 9.3 Commit Diff Summary

```bash
git show --stat --oneline --summary HEAD
```

Review:

- commit size matches migration expectation
- no runtime implementation files are included

### 9.4 Optional Post-Commit Name Review

```bash
git show --name-status --oneline HEAD
```

Review:

- rename set matches completed migration batches
- closeout report files are included
- no unexpected source/runtime files are included

---

## 10. Rollback Procedure

### 10.1 If Staging Is Wrong Before Commit

```bash
git restore --staged .
```

Then restage only approved files.

### 10.2 If Commit Was Created But Not Pushed

```bash
git reset --soft HEAD~1
```

Then adjust staging.

### 10.3 If Commit Was Pushed

Use a public revert:

```bash
git revert HEAD
```

or:

```bash
git revert <commit_sha>
```

Do not use destructive reset after push unless repository governance explicitly approves it.

---

## 11. Do-Not-Touch List

Batch 6B must not alter:

```text
docs/02910_downloadfile.md
docs/03200_Report_...Readiness_Report-1.md
docs/03220_downloadfile-2.md
```

Batch 6B must not resolve the 52 Batch 5F manual-review/excluded manifest items.

Batch 6B must not alter the Batch 5G `000047` manifest `OldReference` provenance record.

---

## 12. Human Review Checklist

Before committing:

- [ ] `git status --short` reviewed.
- [ ] `git diff --stat` reviewed.
- [ ] `git diff --name-status` reviewed.
- [ ] `git diff --check` reviewed.
- [ ] No runtime/source files included.
- [ ] No SQL migration included.
- [ ] No Flutter / Dart implementation included.
- [ ] No Supabase runtime change included.
- [ ] No POS Gateway runtime change included.
- [ ] No manual-review/excluded actions included.
- [ ] Batch 5F hold remains intact.
- [ ] Batch 5G link integrity closeout remains intact.
- [ ] Batch 5H H1 closeout remains intact.
- [ ] New closeout docs use six-digit prefixes.
- [ ] New closeout docs have H1 equal to filename including `.md`.
- [ ] UTF-8 preserved.
- [ ] No PowerShell `Set-Content` used.
- [ ] No formatter used.

After committing:

- [ ] `git status --short` reviewed.
- [ ] `git log --oneline -3` reviewed.
- [ ] `git show --stat --oneline --summary HEAD` reviewed.
- [ ] Commit message is correct.
- [ ] Manual-review hold is clearly documented.

---

## 13. Cursor Instruction Block

```text
Continue yoonsul_wait_order_handoff docs six-digit migration.

Current task:
Batch 6B Staged Commit Execution And Post-Commit Verification.

Starting status:
- Batch 5B RootGovernance rename complete.
- Batch 5C LowDensityDomain rename complete.
- Batch 5D MediumDensityDomain rename complete.
- Batch 5E DenseDomain rename complete.
- Batch 5F ManualReview/Exclusion planning complete as hold.
- Batch 5G Global internal link integrity scan complete.
- Batch 5H Global H1 mismatch closeout complete.
- Batch 6A staged commit planning complete.
- Cursor project rules already committed separately at 9cff90e.

Known closeout state:
- active old 5-digit full-path references remaining: 0
- broken link candidates: 0
- double-prefix active patterns: 0
- double-prefix historical/provenance records: 1
- H1 missing count: 0
- H1 updated in Batch 5H: 10
- intended title skipped: 32
- ambiguous/manual-review H1 files: 3
- manual-review/excluded items remaining: 52

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
- Do not resolve Batch 5F manual-review/excluded items.
- Preserve UTF-8.

Allowed:
- git status review
- git diff review
- git diff --check validation
- git staging
- git commit
- post-commit verification

Recommended commit:
docs: complete six-digit documentation migration closeout

Required output:
1. Pre-commit status summary.
2. Staged file summary.
3. git diff --cached --check result.
4. Commit SHA after commit.
5. Post-commit status summary.
6. git show --stat summary.
7. Explicit safety statement:
   - no runtime implementation
   - no internal link edit in Batch 6B
   - no H1 edit in Batch 6B
   - no file/folder rename in Batch 6B
   - Batch 5F manual-review hold remains untouched
```

---

## 14. Recommended Next Batch After 6B

After Batch 6B completes, continue with one of the following:

### Option A — Manual Review Resolution

```text
Batch 5F-1 ManualReview Approved Action Execution
```

Use only after the human approves specific actions for the 52 manual-review/excluded items.

### Option B — Final Migration Index / Governance Update

```text
Batch 6C Six-Digit Migration Governance Index Update
```

Use if a final index or README governance update is needed after the commit.

Recommended default:

```text
Batch 6C before Batch 5F-1
```

Reason:

The main migration closeout should be indexed and discoverable before reopening the higher-risk manual-review lane.

---

## 15. Closeout Judgment

Batch 6B is ready when:

- the completed migration diff is staged safely
- validation passes
- the consolidated commit is created
- post-commit verification confirms clean documentation-only state

Batch 6B does not authorize manual-review resolution.

Batch 6B does not authorize runtime implementation.
