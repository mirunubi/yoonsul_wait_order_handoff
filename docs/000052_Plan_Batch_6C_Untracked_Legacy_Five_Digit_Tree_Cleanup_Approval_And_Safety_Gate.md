# 000052_Plan_Batch_6C_Untracked_Legacy_Five_Digit_Tree_Cleanup_Approval_And_Safety_Gate.md

## 1. Purpose

This document defines **Batch 6C — Untracked Legacy Five-Digit Tree Cleanup Approval And Safety Gate** for the `yoonsul_wait_order_handoff` documentation six-digit migration.

Batch 6B successfully committed the canonical six-digit documentation tree.

Batch 6C exists because legacy five-digit folders/files still exist on disk as untracked files after the index-only cleanup.

Batch 6C must not immediately delete anything.

Its purpose is to:

1. identify untracked legacy five-digit duplicates,
2. prove that canonical six-digit counterparts exist in git,
3. produce a deletion approval manifest,
4. require explicit human approval before any filesystem removal.

---

## 2. Starting State

### 2.1 Batch 6B Commit

Batch 6B completed with:

| Field | Value |
|---|---|
| Commit hash | `c7663736` |
| Commit message | `docs: close out six-digit basename migration (Batch 5B-5H)` |
| Parent | `9cff90e` Cursor rules commit |

### 2.2 Batch 6B Closeout State

| Item | State |
|---|---|
| Six-digit migration in git | Committed |
| Git HEAD legacy five-digit tracked paths | 0 |
| Canonical six-digit tree | Active |
| Batch 5F manual-review hold | Still active |
| Manual-review manifest items | 52 remaining |
| Manual-review H1 files | untouched |
| On-disk legacy five-digit tree | still present as untracked |
| Runtime implementation | none |

### 2.3 Safety Baseline

Batch 6B confirmed:

- UTF-8 preserved.
- No PowerShell `Set-Content` used.
- No formatter used.
- No H1 or internal link edits in Batch 6B.
- No runtime implementation created.
- No file/folder rename, move, or delete performed in Batch 6B.

---

## 3. Batch 6C Scope

### 3.1 Allowed In Batch 6C Planning Phase

Batch 6C planning phase may perform:

1. Read-only `git status --short`.
2. List untracked legacy five-digit paths.
3. Build cleanup candidate manifest.
4. Verify each cleanup candidate has a canonical six-digit counterpart tracked in git.
5. Classify candidates:
   - safe duplicate cleanup candidate
   - manual-review hold
   - unknown / do-not-delete
6. Produce approval report.
7. Ask for human approval before deletion.

### 3.2 Forbidden Without Explicit Human Approval

Batch 6C must not perform any of the following before approval:

- delete untracked files
- delete untracked folders
- run `git clean`
- run `rm -rf`
- run PowerShell `Remove-Item`
- rename files
- rename folders
- move files
- modify internal links
- modify H1 lines
- run formatter
- modify runtime code

### 3.3 Strictly Forbidden Even After Approval

Batch 6C must not:

- delete canonical six-digit tracked files
- delete Batch 5F manual-review hold files
- delete root migration evidence unless separately approved
- modify runtime implementation
- alter git history
- force push

---

## 4. Do-Not-Touch Items

The following must remain untouched unless a later human-approved manual-review batch says otherwise.

### 4.1 Batch 5F Manual-Review H1 Files

```text
docs/02910_downloadfile.md
docs/03200_Report_...Readiness_Report-1.md
docs/03220_downloadfile-2.md
```

### 4.2 Batch 5F Manual-Review / Excluded Manifest Items

```text
52 manual-review/excluded items from 000045
```

### 4.3 Batch 5G Historical Provenance

```text
000047 manifest OldReference provenance record
```

### 4.4 Root Local Evidence Unless Approved

Do not delete unless explicitly approved:

```text
migration_*
directory_only_tree.txt
.gitignore
```

---

## 5. Candidate Detection Rule

A cleanup candidate is a path that satisfies all of the following:

1. It is untracked in `git status --short`.
2. It is under `docs/` or another approved documentation root.
3. Its basename or folder segment begins with a legacy five-digit numeric prefix.
4. A canonical six-digit counterpart exists in git.
5. It is not part of Batch 5F manual-review hold.
6. It is not a root evidence/report file intentionally kept outside git.
7. It is not a local-only file that has no canonical counterpart.

---

## 6. Read-Only Detection Commands

Run from repository root.

### 6.1 Current Status

```bash
git status --short
```

### 6.2 List Untracked Paths Only

```bash
git ls-files --others --exclude-standard
```

### 6.3 Filter Possible Legacy Five-Digit Paths

```bash
python - <<'PY'
from pathlib import Path
import subprocess
import re

out = subprocess.check_output(
    ["git", "ls-files", "--others", "--exclude-standard"],
    text=True,
    encoding="utf-8",
    errors="replace",
)

legacy_re = re.compile(r"(^|/)[0-9]{5}(?:_|$)")
candidates = []

for line in out.splitlines():
    p = line.strip()
    if legacy_re.search(p):
        candidates.append(p)

print(f"untracked_legacy_5_digit_candidates={len(candidates)}")
for p in candidates:
    print(p)
PY
```

This command is read-only.

---

## 7. Canonical Counterpart Verification

For each legacy five-digit candidate, derive likely six-digit counterpart by adding one leading zero to the first five-digit prefix segment.

Example:

```text
docs/01000_example/01230_File.md
```

becomes:

```text
docs/001000_example/001230_File.md
```

or, depending on the actual migration mapping, use the authoritative Batch 5B–5E manifest mapping rather than simple prefix transformation.

Because some files may have been moved by domain band strategy before the six-digit migration, do not rely only on string transformation.

Use the migration manifests and current git-tracked six-digit tree as the source of truth.

---

## 8. Recommended Manifest Columns

Create a report table with the following columns:

| Column | Meaning |
|---|---|
| legacy_untracked_path | Current untracked on-disk path |
| candidate_type | file or directory |
| likely_six_digit_counterpart | Expected canonical path |
| counterpart_tracked_in_git | yes/no |
| content_hash_match | yes/no/not_checked |
| classification | safe_cleanup_candidate / manual_review_hold / unknown_do_not_delete |
| action | hold / approve_delete_later |
| reason | Short reason |

---

## 9. Optional Content Hash Check

Before deleting any file, compare content hash where possible.

```bash
python - <<'PY'
from pathlib import Path
import hashlib

def sha256(path: Path):
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()

# Fill these from manifest after review.
pairs = [
    # ("legacy_path.md", "canonical_six_digit_path.md"),
]

for legacy, canonical in pairs:
    lp = Path(legacy)
    cp = Path(canonical)
    if not lp.exists() or not cp.exists():
        print("MISSING", legacy, canonical)
        continue
    print(legacy)
    print("  legacy  ", sha256(lp))
    print("  canonical", sha256(cp))
    print("  match   ", sha256(lp) == sha256(cp))
PY
```

If hashes do not match, classify as:

```text
unknown_do_not_delete
```

unless a human explicitly approves otherwise.

---

## 10. Approval Gate

Before any deletion, Batch 6C must output:

1. total untracked paths
2. total five-digit legacy cleanup candidates
3. safe cleanup candidates
4. manual-review hold candidates
5. unknown / do-not-delete candidates
6. exact deletion command preview
7. explicit human approval request

No deletion is allowed before the user says one of the following clearly:

```text
Approved: delete safe cleanup candidates only.
```

or:

```text
Approved: proceed with Batch 6C cleanup using the generated manifest.
```

---

## 11. Deletion Method After Approval Only

After approval, prefer deleting only exact manifest-listed safe candidates.

Do not use broad `git clean -fd`.

Do not use broad `rm -rf docs/*`.

Do not use broad PowerShell `Remove-Item -Recurse`.

Preferred deletion method after approval:

```bash
python - <<'PY'
from pathlib import Path

safe_delete_paths = [
    # exact paths from approved manifest only
]

for raw in safe_delete_paths:
    p = Path(raw)
    if not p.exists():
        print(f"SKIP missing: {p}")
        continue

    # Safety: refuse to delete tracked files
    import subprocess
    result = subprocess.run(
        ["git", "ls-files", "--error-unmatch", p.as_posix()],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )
    if result.returncode == 0:
        raise SystemExit(f"REFUSE tracked file: {p}")

    if p.is_file():
        p.unlink()
        print(f"deleted file: {p}")
    elif p.is_dir():
        # Directory deletion should only occur when all descendants are approved.
        # Prefer deleting files first, then empty dirs.
        raise SystemExit(f"REFUSE directory delete without explicit directory-safe handling: {p}")
PY
```

For directories, delete approved files first, then remove only empty directories:

```bash
python - <<'PY'
from pathlib import Path

for d in sorted(Path("docs").rglob("*"), key=lambda x: len(x.parts), reverse=True):
    if d.is_dir():
        try:
            d.rmdir()
            print(f"removed empty dir: {d}")
        except OSError:
            pass
PY
```

---

## 12. Post-Cleanup Verification

After approved cleanup only, run:

```bash
git status --short
git ls-files --others --exclude-standard
git log --oneline -3
```

Expected:

- canonical six-digit docs remain tracked
- no tracked files deleted
- legacy five-digit untracked duplicates removed or reduced
- manual-review hold remains intact
- root evidence leftovers remain if not approved for deletion

---

## 13. Commit Policy For Batch 6C

If Batch 6C only deletes untracked files, there may be nothing to commit.

If Batch 6C creates a cleanup approval manifest under `docs/`, commit only the manifest/report.

Suggested commit message:

```text
docs: record legacy five-digit cleanup approval gate
```

If no tracked files changed:

```text
No commit required.
```

---

## 14. Cursor Instruction Block

```text
Continue yoonsul_wait_order_handoff docs six-digit migration cleanup.

Current task:
Batch 6C Untracked Legacy Five-Digit Tree Cleanup Approval And Safety Gate.

Starting state:
- Batch 6B committed:
  - c7663736 docs: close out six-digit basename migration (Batch 5B-5H)
- Parent:
  - 9cff90e chore: add cursor project documentation rules
- Six-digit migration in git is committed as Closed_With_ManualReview_Hold.
- Legacy five-digit tracked paths in HEAD: 0.
- Legacy five-digit folders/files remain on disk as untracked.
- Batch 5F manual-review/excluded items remain held.
- Runtime implementation remains forbidden.

Rules:
- Do not delete anything before producing a manifest and receiving human approval.
- Do not run git clean.
- Do not run rm -rf.
- Do not run PowerShell Remove-Item.
- Do not rename files.
- Do not rename folders.
- Do not move files.
- Do not edit internal links.
- Do not edit H1 lines.
- Do not run formatter.
- Do not use PowerShell Set-Content.
- Do not implement runtime code.
- Preserve UTF-8.

Allowed now:
1. Read-only git status.
2. Read-only untracked path listing.
3. Identify untracked five-digit legacy cleanup candidates.
4. Verify canonical six-digit counterparts tracked in git.
5. Produce cleanup approval manifest.
6. Classify each candidate:
   - safe_cleanup_candidate
   - manual_review_hold
   - unknown_do_not_delete
7. Stop and request human approval before deletion.

Do not touch:
- docs/02910_downloadfile.md
- docs/03200_Report_...Readiness_Report-1.md
- docs/03220_downloadfile-2.md
- 52 Batch 5F manual-review/excluded manifest items
- Batch 5G 000047 OldReference provenance record
- root migration_* files unless separately approved
- directory_only_tree.txt unless separately approved
- .gitignore unless separately approved

Required output:
1. total untracked paths
2. total untracked five-digit legacy candidates
3. safe cleanup candidate count
4. manual-review hold count
5. unknown/do-not-delete count
6. manifest file path
7. exact proposed deletion list
8. explicit statement:
   No deletion performed in Batch 6C planning phase.
9. ask for human approval before cleanup.
```

---

## 15. Recommended Next Step

Run Batch 6C planning first.

Do not delete untracked legacy files until the manifest is reviewed.

Recommended approval phrase after review:

```text
Approved: delete safe cleanup candidates only.
```

---

## 16. Closeout Judgment

Batch 6C is necessary because git is already clean/canonical, but the working directory still contains untracked legacy five-digit duplicates.

The correct next move is not immediate deletion.

The correct next move is:

```text
manifest → classify → approve → delete exact safe candidates only
```
