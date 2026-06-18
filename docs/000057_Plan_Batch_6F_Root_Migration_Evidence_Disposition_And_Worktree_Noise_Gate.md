# 000057_Plan_Batch_6F_Root_Migration_Evidence_Disposition_And_Worktree_Noise_Gate.md

## 1. Purpose

This document defines **Batch 6F — Root Migration Evidence Disposition And Worktree Noise Gate** for the `yoonsul_wait_order_handoff` six-digit documentation migration.

Batch 6E committed the final Batch 5F-1 manual-review manifest.

At this point, the documentation migration lane is closed in git, and the remaining working tree noise is outside the active docs migration lane:

- `.gitignore`
- root `migration_*` files
- `directory_only_tree.txt`
- `sop/`

Batch 6F exists to classify these remaining items before any cleanup, commit, revert, ignore, or deletion action.

Batch 6F is a **disposition planning gate**, not a cleanup execution batch.

---

## 2. Starting State

### 2.1 Prior Commits

| Batch | Commit | Message |
|---|---|---|
| Cursor project rules | `9cff90e` | `chore: add cursor project documentation rules` |
| Batch 6B | `c7663736` | `docs: close out six-digit basename migration (Batch 5B-5H)` |
| Batch 6D | `15361afb` | `docs: add Batch 6C legacy cleanup approval gate and manifest` |
| Batch 6E | `968e635` | `docs: add Batch 5F-1 manual-review hold resolution manifest` |

### 2.2 Batch 6E Result

Batch 6E confirmed:

- `docs/000055_Matrix_Batch_5F_1_ManualReview_Hold_Files_Resolution_Manifest.md` committed.
- Only 1 file committed.
- `.gitignore` not touched.
- `migration_*` not touched.
- `directory_only_tree.txt` not touched.
- `sop/` not touched.
- `docs/000100_project_foundation/` canonical tracked files unchanged.
- No docs migration files remain pending.

---

## 3. Current Remaining Items

The remaining unstaged/untracked items are outside the docs six-digit migration lane.

Expected groups:

```text
.gitignore
migration_* tracked modified files
migration_* untracked files
directory_only_tree.txt
sop/
```

These must be handled by classification, not by bulk cleanup.

---

## 4. Batch 6F Scope

### 4.1 Allowed

Batch 6F may perform only:

1. read-only `git status --short`,
2. read-only `git diff --name-status`,
3. read-only `git diff -- .gitignore migration_*`,
4. read-only untracked listing,
5. classify remaining root artifacts,
6. produce a disposition manifest,
7. recommend next action per group,
8. stop for human approval.

### 4.2 Forbidden In Batch 6F Planning Phase

Batch 6F must not:

- stage files,
- commit files,
- delete files,
- revert files,
- rename files,
- move files,
- edit `.gitignore`,
- edit root `migration_*`,
- edit `sop/`,
- edit docs,
- edit H1 lines,
- edit internal links,
- run formatter,
- use PowerShell `Set-Content`,
- use PowerShell `Remove-Item`,
- run `git clean`,
- run `rm -rf`,
- implement runtime code.

---

## 5. Disposition Categories

Each remaining item must be classified into one of the following.

| Classification | Meaning | Default Action |
|---|---|---|
| `commit_evidence_candidate` | Useful migration evidence worth committing | hold for approval |
| `local_temp_delete_candidate` | Local temporary artifact safe to delete after approval | hold for approval |
| `revert_candidate` | Tracked modified file should be restored to HEAD after approval | hold for approval |
| `ignore_policy_candidate` | Should be ignored via `.gitignore` after review | hold for approval |
| `sop_lane_hold` | SOP files require separate governance lane | hold |
| `unknown_do_not_touch` | Insufficient evidence | hold |

Default classification is:

```text
unknown_do_not_touch
```

unless evidence supports another classification.

---

## 6. Read-Only Commands

Run from repository root.

### 6.1 Status

```bash
git status --short
```

### 6.2 Tracked Modified Files

```bash
git diff --name-status
```

### 6.3 Root Migration Evidence Diff

```bash
git diff -- .gitignore migration_*
```

Do not apply or edit this diff.

### 6.4 Untracked Files

```bash
git ls-files --others --exclude-standard
```

### 6.5 Tracked Root Migration Files

```bash
git ls-files "migration_*"
```

---

## 7. Required Manifest

Create a UTF-8 Markdown manifest only if Batch 6F planning is performed.

Recommended filename:

```text
docs/000058_Matrix_Batch_6F_Root_Migration_Evidence_Disposition_Manifest.md
```

Required H1:

```md
# 000058_Matrix_Batch_6F_Root_Migration_Evidence_Disposition_Manifest.md
```

Required columns:

| Column | Meaning |
|---|---|
| path | file or folder |
| git_state | modified_tracked / untracked / ignored / clean / unknown |
| group | gitignore / root_migration_evidence / directory_tree_temp / sop_lane |
| size_or_count | file size or folder file count |
| content_summary | short summary |
| classification | one of the Batch 6F classifications |
| recommended_action | commit / delete / revert / ignore / hold |
| human_approval_required | yes |
| reason | short reason |

---

## 8. Initial Expected Disposition

### 8.1 `.gitignore`

Expected classification:

```text
revert_candidate or ignore_policy_candidate
```

Required review:

- Is the `.gitignore` modification intentional?
- Does it protect migration artifacts from future accidental commits?
- Does it hide files that should remain visible?

Do not stage or revert until approved.

### 8.2 Root `migration_*` Tracked Modified Files

Expected classification:

```text
commit_evidence_candidate or revert_candidate
```

Required review:

- Are these final evidence reports from migration?
- Are the modifications already superseded by committed docs/ reports?
- Are they temporary scripts/scans that should not remain modified?

Do not stage or revert until approved.

### 8.3 Root `migration_*` Untracked Files

Expected classification:

```text
commit_evidence_candidate or local_temp_delete_candidate
```

Required review:

- Are these unique migration evidence files?
- Are they superseded by committed manifests?
- Should they be archived under docs/ or deleted?

Do not delete or commit until approved.

### 8.4 `directory_only_tree.txt`

Expected classification:

```text
local_temp_delete_candidate
```

Required review:

- Is it a temporary local tree snapshot?
- Is it referenced by any committed report?

Do not delete until approved.

### 8.5 `sop/`

Expected classification:

```text
sop_lane_hold
```

Required review:

- Should `sop/` be committed in this repo?
- Should SOP be moved to a separate root lane?
- Should SOP become a separate repository?
- Should existing SOP files be migrated to six-digit naming first?

Do not stage, delete, or move SOP in Batch 6F.

---

## 9. Approval Options After Batch 6F Manifest

After the manifest is created, ask the human to choose one of the following:

### Option 1 — Commit Evidence Only

```text
Approved: commit files classified commit_evidence_candidate only.
```

### Option 2 — Delete Local Temp Only

```text
Approved: delete files classified local_temp_delete_candidate only.
```

### Option 3 — Revert Tracked Noise Only

```text
Approved: revert files classified revert_candidate only.
```

### Option 4 — Hold All

```text
Hold all remaining Batch 6F items.
```

### Option 5 — Mixed Approved Actions

```text
Approved: execute manifest actions exactly as listed for Batch 6F.
```

No action is allowed without explicit approval.

---

## 10. Safety Rules For Later Execution

If deletion is approved later:

- delete exact manifest-listed untracked files only,
- refuse deleting tracked files,
- do not use `git clean`,
- do not use `rm -rf`,
- do not use PowerShell `Remove-Item`.

If revert is approved later:

- use exact file paths only,
- confirm diffs before revert,
- do not revert docs migration commits.

If commit is approved later:

- stage exact manifest-listed files only,
- do not stage `sop/` unless SOP lane is explicitly approved,
- do not stage `.gitignore` unless reviewed and approved.

---

## 11. Cursor Instruction Block

```text
Continue yoonsul_wait_order_handoff docs six-digit migration cleanup.

Current task:
Batch 6F Root Migration Evidence Disposition And Worktree Noise Gate.

Starting state:
- Batch 6B committed:
  - c7663736 docs: close out six-digit basename migration (Batch 5B-5H)
- Batch 6D committed:
  - 15361afb docs: add Batch 6C legacy cleanup approval gate and manifest
- Batch 6E committed:
  - 968e635 docs: add Batch 5F-1 manual-review hold resolution manifest
- No docs migration files remain pending.
- Remaining unstaged/untracked items are:
  - .gitignore
  - migration_* tracked modified files
  - migration_* untracked files
  - directory_only_tree.txt
  - sop/

Rules:
- Planning only.
- Do not stage anything.
- Do not commit anything.
- Do not delete anything.
- Do not revert anything.
- Do not rename/move files.
- Do not edit .gitignore.
- Do not edit migration_* files.
- Do not edit sop/.
- Do not edit docs.
- Do not edit H1 lines.
- Do not edit internal links.
- Do not run formatter.
- Do not use PowerShell Set-Content.
- Do not use PowerShell Remove-Item.
- Do not run git clean.
- Do not run rm -rf.
- Do not implement runtime code.
- Preserve UTF-8.

Allowed:
1. Read-only git status.
2. Read-only git diff.
3. Read-only untracked listing.
4. Classify remaining root artifacts.
5. Create UTF-8 manifest:
   docs/000058_Matrix_Batch_6F_Root_Migration_Evidence_Disposition_Manifest.md
6. Stop for human approval.

Commands:
git status --short
git diff --name-status
git diff -- .gitignore migration_*
git ls-files --others --exclude-standard
git ls-files "migration_*"

Manifest columns:
- path
- git_state
- group
- size_or_count
- content_summary
- classification
- recommended_action
- human_approval_required
- reason

Classification values:
- commit_evidence_candidate
- local_temp_delete_candidate
- revert_candidate
- ignore_policy_candidate
- sop_lane_hold
- unknown_do_not_touch

Required final report:
1. status summary
2. tracked modified count
3. untracked count
4. root migration evidence classification summary
5. .gitignore classification
6. directory_only_tree.txt classification
7. sop/ classification
8. manifest path
9. recommended next action
10. explicit safety statement:
    - no staging
    - no commit
    - no deletion
    - no revert
    - no docs edits
    - no runtime implementation
    - no formatter
    - no git clean/rm-rf/Remove-Item
11. ask for human approval before action.
```

---

## 12. Recommended Next Batch After 6F

After Batch 6F planning, likely next batches are:

### Batch 6F-1 Root Evidence Approved Action Execution

Execute approved commit/delete/revert actions from the Batch 6F manifest.

### Batch 5F-2 Canonical Mobile-Draft Delete Candidate Link Audit

Audit canonical tracked `Delete_Candidate_Later` mobile-draft files and references in:

```text
000450_Readme_Documentation_Governance.md
000479 / 000480 checklists
```

### SOP Lane Planning

Decide the future of `sop/`:

- commit into this repo,
- move to dedicated SOP root governance lane,
- keep untracked,
- separate repository.

---

## 13. Closeout Judgment

Batch 6E completed the remaining docs migration evidence commit.

Batch 6F should not mutate anything.

The correct next move is:

```text
classify remaining root noise → produce manifest → request approval
```

This prevents accidental deletion or staging of root migration evidence, `.gitignore`, or SOP files.
