# Migration Folder 20000 Security Archive Physical Split Report

Generated: 2026-06-15T19:11:28.205327+00:00

## Summary

Moved 53 archived security files from `20999_archive_duplicate_review/` root into six disposition subfolders.

| subfolder | count |
| --- | ---: |
| `20991_superseded_by_foundation_security` | 3 |
| `20992_superseded_by_20000_root_active` | 5 |
| `20993_duplicate_copy_xx01` | 25 |
| `20994_deferred_merge_review` | 10 |
| `20995_deferred_move_review` | 4 |
| `20996_keep_archive_only` | 6 |

## Validation

| check | result |
| --- | --- |
| loose files at archive root | 0 |
| total archived files | 53 |
| subfolder counts match expected | True |
| duplicate prefix groups | 0 |
| heading mismatches | 0 |
| 00005 stale paths | 0 |
| 00007 stale paths | 0 |
| paths > 220 chars | 0 |
| paths > 240 chars | 0 |
| UTF-8 invalid | 0 |
| validation pass | **True** |

## Safety

- No files deleted; filenames unchanged
- Archived file bodies not edited
- No code/SQL/Flutter/migrations touched
- Nothing staged or committed
