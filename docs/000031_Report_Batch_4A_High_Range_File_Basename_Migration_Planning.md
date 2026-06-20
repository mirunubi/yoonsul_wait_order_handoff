# 000031_Report_Batch_4A_High_Range_File_Basename_Migration_Planning

## Scope

- Planning/manifest only.
- No file rename.
- No folder rename.
- No file move.
- No delete.
- No H1/body/internal link edit.
- No runtime implementation.

## Scan Scope

| ScopeRoot | MarkdownFiles | Notes |
|---|---:|---|
| `docs/600000_implementation_lifecycle/` | 317 | Stabilized implementation lifecycle high-range folder. |
| `docs/700000_runtime_flow/` | 19 | Stabilized runtime flow high-range folder. |

## Scan Summary

| Metric | Count |
|---|---:|
| Scanned folders | 31 |
| Scanned markdown files | 336 |
| 5-digit basename files | 336 |
| Already 6-digit basename files | 0 |
| Excluded files | 0 |
| Anomaly files | 0 |
| Duplicate target risks | 0 |
| Long path risks before | 54 |
| Long path risks after | 58 |

## Rename Planning Rule

| Current Pattern | Proposed Pattern | Action |
|---|---|---|
| `xxxxx_Title.md` | `0xxxxx_Title.md` | Add one leading zero to 5-digit basename prefixes in a later execution batch. |
| `xxxxxx_Title.md` | unchanged | Already six-digit. |
| `xxxx_Title.md` or no numeric prefix | manual review | Record as anomaly; do not auto rename. |

## Long Path Risk Notes

Long path risk uses an absolute path length threshold greater than 240 characters. Adding one leading zero to 5-digit basenames increases proposed path length by one character, so the after-risk count may increase where current paths are already near the threshold.

## Recommended Execution Batch

Batch 4B: Execute six-digit file basename rename for high-range folders only, using this manifest as the approval source. Batch 4B should update `000005`, `000007`, H1 headings, and internal links only after the actual rename is approved.

## Rollback Notes

- Because Batch 4A is planning only, rollback is limited to removing the two generated Batch 4A documents.
- No file rename, folder rename, move, delete, H1 edit, body edit, internal link edit, or runtime implementation was performed.
