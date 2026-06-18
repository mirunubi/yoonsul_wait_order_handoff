# 000059_Plan_Batch_6G_Commit_6F_Manifest_And_Untracked_Migration_Evidence_Disposition.md

## 1. Purpose

This document defines **Batch 6G — Commit 6F Manifest And Untracked Migration Evidence Disposition** for the `yoonsul_wait_order_handoff` six-digit documentation migration cleanup.

Batch 6F-1 + 6F-3 safely reverted tracked root noise and deleted one stale temporary artifact.

Batch 6G exists to:

1. commit the Batch 6F root evidence disposition manifest,
2. classify the remaining 5 untracked root `migration_*` files,
3. avoid accidental deletion of useful migration evidence,
4. keep the repository clean without mixing unrelated SOP or runtime work.

Batch 6G must not modify docs migration content.

---

## 2. Starting State

### 2.1 Prior Commits

| Batch | Commit | Message |
|---|---|---|
| Cursor project rules | `9cff90e` | `chore: add cursor project documentation rules` |
| Batch 6B | `c7663736` | `docs: close out six-digit basename migration (Batch 5B-5H)` |
| Batch 6D | `15361afb` | `docs: add Batch 6C legacy cleanup approval gate and manifest` |
| Batch 6E | `968e635` | `docs: add Batch 5F-1 manual-review hold resolution manifest` |

### 2.2 Batch 6F-1 + 6F-3 Result

Batch 6F-1 + 6F-3 confirmed:

| Check | Result |
|---|---|
| `.gitignore` reverted | Yes |
| Modified tracked `migration_*` reverted | 15 files |
| `directory_only_tree.txt` deleted | Yes |
| Untracked `migration_*` preserved | 5 files remain |
| `sop/` untouched | Yes; re-hidden by restored `.gitignore` |
| `docs/` untouched | Yes; tracked docs diff empty |

Safety confirmed:

- no `git clean`
- no `rm -rf`
- no PowerShell `Remove-Item`
- no broad restore
- no tracked docs edits
- no H1/internal link edits
- no runtime implementation
- no formatter

---

## 3. Current Remaining Worktree State

After Batch 6F-1 + 6F-3, the only remaining untracked items are:

```text
docs/000058_Matrix_Batch_6F_Root_Migration_Evidence_Disposition_Manifest.md
migration_folder_20000_security_archive_disposition_plan.json
migration_folder_20000_security_archive_disposition_plan.md
migration_manifest_md_naming_prefix.json
migration_manifest_md_naming_prefix.md
migration_precleanup_execution_plan.md
```

`directory_only_tree.txt` is deleted.

`sop/` is ignored again through restored `.gitignore`.

Tracked docs diff is empty except for no pending tracked changes.

---

## 4. Batch 6G Scope

### 4.1 Allowed

Batch 6G may perform:

1. read-only status check,
2. read-only review of the five untracked `migration_*` files,
3. stage and commit only `docs/000058...` if approved,
4. create a disposition decision for the five untracked root `migration_*` files,
5. request human approval before deleting or committing those five files.

### 4.2 Forbidden Without Separate Approval

Batch 6G must not:

- delete the five untracked `migration_*` files,
- commit the five untracked `migration_*` files,
- modify the five untracked `migration_*` files,
- edit `.gitignore`,
- touch `sop/`,
- edit docs migration files,
- edit H1 lines,
- edit internal links,
- run formatter,
- use PowerShell `Set-Content`,
- use PowerShell `Remove-Item`,
- run `git clean`,
- run `rm -rf`,
- implement runtime code.

---

## 5. Recommended Step 1 — Commit 000058 Manifest Only

### 5.1 Pre-Check

Run:

```bash
git status --short
git diff --name-only -- docs
git diff --check -- docs/000058*
```

Expected:

- `docs/000058...` is untracked.
- No tracked docs are modified.
- `docs/000058...` is clean.

### 5.2 Stage Only 000058

```bash
git add docs/000058_Matrix_Batch_6F_Root_Migration_Evidence_Disposition_Manifest.md
```

Review:

```bash
git diff --cached --stat
git diff --cached --name-status
git diff --cached --check
```

### 5.3 Commit

Recommended commit message:

```bash
git commit -m "docs: record root migration evidence disposition manifest"
```

---

## 6. Recommended Step 2 — Classify Remaining 5 Untracked Migration Files

Remaining files:

```text
migration_folder_20000_security_archive_disposition_plan.json
migration_folder_20000_security_archive_disposition_plan.md
migration_manifest_md_naming_prefix.json
migration_manifest_md_naming_prefix.md
migration_precleanup_execution_plan.md
```

### 6.1 Read-Only Review

Run:

```bash
git ls-files --others --exclude-standard
```

For each file, inspect enough to classify:

```bash
python - <<'PY'
from pathlib import Path

files = [
    "migration_folder_20000_security_archive_disposition_plan.json",
    "migration_folder_20000_security_archive_disposition_plan.md",
    "migration_manifest_md_naming_prefix.json",
    "migration_manifest_md_naming_prefix.md",
    "migration_precleanup_execution_plan.md",
]

for raw in files:
    p = Path(raw)
    print("---")
    print(f"path={raw}")
    print(f"exists={p.exists()}")
    if p.exists():
        print(f"bytes={p.stat().st_size}")
        text = p.read_text(encoding="utf-8", errors="replace")
        print("preview:")
        print("\n".join(text.splitlines()[:20]))
PY
```

### 6.2 Classification Values

| Classification | Meaning |
|---|---|
| `delete_local_temp_candidate` | Local migration planning artifact superseded by committed reports |
| `archive_under_docs_candidate` | Useful evidence that should be moved/copied into docs under six-digit name |
| `commit_root_evidence_candidate` | Useful root-level evidence to commit as-is |
| `hold` | Keep untracked for now |
| `unknown_do_not_touch` | Insufficient confidence |

Default:

```text
hold
```

---

## 7. Recommended Default Disposition

Given current reports:

| File | Recommended Classification | Recommended Action |
|---|---|---|
| `migration_folder_20000_security_archive_disposition_plan.json` | `delete_local_temp_candidate` | hold for approval |
| `migration_folder_20000_security_archive_disposition_plan.md` | `delete_local_temp_candidate` | hold for approval |
| `migration_manifest_md_naming_prefix.json` | `delete_local_temp_candidate` | hold for approval |
| `migration_manifest_md_naming_prefix.md` | `delete_local_temp_candidate` | hold for approval |
| `migration_precleanup_execution_plan.md` | `delete_local_temp_candidate` | hold for approval |

Reason:

These are untracked root migration planning/evidence artifacts and appear superseded by committed documentation trail:

- `000039` and related migration reports
- Batch 5B through 6E reports/manifests
- committed six-digit canonical docs tree

However, deletion should still require explicit human approval.

---

## 8. Approval Options

After committing `000058`, ask the human to choose:

### Option 1 — Delete Remaining 5 Root Migration Artifacts

```text
Approved: delete the five untracked root migration_* files only.
```

### Option 2 — Hold Remaining 5

```text
Hold the five untracked root migration_* files.
```

### Option 3 — Archive Under Docs

```text
Approved: create a docs archive plan for the five untracked migration_* files.
```

Recommended:

```text
Option 1
```

Only if the human accepts that committed reports already preserve the migration evidence.

---

## 9. Safe Deletion Template After Approval Only

If approved, delete exact untracked files only.

```bash
python - <<'PY'
from pathlib import Path
import subprocess

approved_delete = [
    "migration_folder_20000_security_archive_disposition_plan.json",
    "migration_folder_20000_security_archive_disposition_plan.md",
    "migration_manifest_md_naming_prefix.json",
    "migration_manifest_md_naming_prefix.md",
    "migration_precleanup_execution_plan.md",
]

for raw in approved_delete:
    p = Path(raw)
    if not p.exists():
        print(f"SKIP missing: {p}")
        continue

    r = subprocess.run(
        ["git", "ls-files", "--error-unmatch", p.as_posix()],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )
    if r.returncode == 0:
        raise SystemExit(f"REFUSE tracked file: {p}")

    p.unlink()
    print(f"deleted untracked root artifact: {p}")
PY
```

Forbidden even after approval:

```text
git clean
rm -rf
PowerShell Remove-Item
broad delete patterns
```

---

## 10. Post-Action Verification

Run:

```bash
git status --short
git ls-files --others --exclude-standard
git log --oneline -5
```

Expected after committing `000058` and deleting the five root artifacts:

```text
clean working tree
```

or clean except ignored `sop/`.

---

## 11. Cursor Instruction Block

```text
Continue yoonsul_wait_order_handoff docs six-digit migration cleanup.

Current task:
Batch 6G Commit 6F Manifest And Untracked Migration Evidence Disposition.

Starting state:
- Batch 6B committed:
  - c7663736 docs: close out six-digit basename migration (Batch 5B-5H)
- Batch 6D committed:
  - 15361afb docs: add Batch 6C legacy cleanup approval gate and manifest
- Batch 6E committed:
  - 968e635 docs: add Batch 5F-1 manual-review hold resolution manifest
- Batch 6F-1 + 6F-3 executed:
  - .gitignore reverted
  - 15 modified tracked migration_* reverted
  - directory_only_tree.txt deleted
  - untracked migration_* preserved
  - sop/ untouched and ignored again
  - docs/ tracked diff empty
- Remaining untracked:
  - docs/000058_Matrix_Batch_6F_Root_Migration_Evidence_Disposition_Manifest.md
  - migration_folder_20000_security_archive_disposition_plan.json
  - migration_folder_20000_security_archive_disposition_plan.md
  - migration_manifest_md_naming_prefix.json
  - migration_manifest_md_naming_prefix.md
  - migration_precleanup_execution_plan.md

Allowed step 1:
- Stage and commit only:
  - docs/000058_Matrix_Batch_6F_Root_Migration_Evidence_Disposition_Manifest.md

Forbidden:
- Do not stage or commit root migration_* files.
- Do not delete root migration_* files before approval.
- Do not edit .gitignore.
- Do not touch sop/.
- Do not edit docs except staging 000058.
- Do not edit H1 lines.
- Do not edit internal links.
- Do not run formatter.
- Do not use PowerShell Set-Content.
- Do not use PowerShell Remove-Item.
- Do not run git clean.
- Do not run rm -rf.
- Do not implement runtime code.

Commands:
git status --short
git diff --name-only -- docs
git diff --check -- docs/000058*

git add docs/000058_Matrix_Batch_6F_Root_Migration_Evidence_Disposition_Manifest.md

git diff --cached --stat
git diff --cached --name-status
git diff --cached --check

git commit -m "docs: record root migration evidence disposition manifest"

After commit:
git status --short
git ls-files --others --exclude-standard

Then classify the remaining five untracked migration_* files and stop for approval.

Required report:
1. 000058 commit hash.
2. Confirmation only 000058 was staged/committed.
3. Remaining untracked root migration_* list.
4. Recommended disposition for each remaining root migration_* file.
5. Explicit safety statement:
   - no deletion
   - no root migration_* staging
   - no .gitignore edits
   - no sop edits
   - no runtime implementation
   - no formatter
   - no git clean/rm-rf/Remove-Item
6. Ask for approval before deleting or archiving the five root migration_* files.
```

---

## 12. Recommended Next Batch After 6G

After Batch 6G:

### Batch 6G-1 Root Migration Artifact Cleanup Execution

Delete or archive the remaining five root `migration_*` files after approval.

### Batch 5F-2 Canonical Mobile-Draft Delete Candidate Link Audit

Audit tracked canonical mobile-draft delete candidates and their references.

### SOP Lane Planning

Handle ignored `sop/` separately.

---

## 13. Closeout Judgment

Batch 6F-1 + 6F-3 successfully removed tracked/root noise without touching docs or runtime.

Batch 6G should first commit `000058`, then stop for approval on the remaining five untracked root migration artifacts.

The safest final cleanup path is:

```text
commit 000058 → classify five root artifacts → approve → exact-path delete or archive
```
