# Migration Folder 20000 Foundation Security Rename Report

Generated: 2026-06-15T19:20:00+00:00

## Summary

Renamed `foundation_security/` → `20400_foundation_security/` with prefix remap `20000`–`20009` → `20400`–`20490`.

| item | result |
| --- | ---: |
| files renamed | 10 |
| headings synced | 10 |
| reference files updated | 4 |
| post-fix path corrections | 2 patterns |

## Prefix Map

| old | new |
| --- | --- |
| 20000 | 20400 |
| 20001 | 20410 |
| 20002 | 20420 |
| 20003 | 20430 |
| 20004 | 20440 |
| 20005 | 20450 |
| 20006 | 20460 |
| 20007 | 20470 |
| 20008 | 20480 |
| 20009 | 20490 |

## Validation

| check | result |
| --- | ---: |
| duplicate prefix groups | 0 |
| heading mismatches | 0 |
| 00005 stale paths | 0 |
| 00007 stale paths | 0 |
| paths > 240 | 0 |
| validation pass | **true** |

## Notes

- First-line `#` headings synced to filename stems only (no body reads).
- `00005` and `00007` rebuilt from filesystem.
- Archive subfolder `20991_superseded_by_foundation_security` name preserved; only canonical target paths updated.
- Corrected double-replacement artifact `20400_20400_foundation_security` after initial pass.

## Safety

- No staging or commit performed.
