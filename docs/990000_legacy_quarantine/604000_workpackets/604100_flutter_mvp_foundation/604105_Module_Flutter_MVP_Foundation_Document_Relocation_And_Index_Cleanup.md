# 604105_Module_Flutter_MVP_Foundation_Document_Relocation_And_Index_Cleanup.md

Status: Implemented  
Lifecycle: Module  
Owner: Codex  
Last Updated: 2026-07-01

## Purpose

Record documentation relocation, renumbering, duplicate index cleanup, and navigation index correction for the `600000_implementation_lifecycle` folder.

## Scope

Documentation-only relocation and index cleanup.

## Runtime Statement

No Flutter/Dart code changed.  
No SQL changed.  
No Supabase function changed.  
No Python tooling created.  
No package/config/lockfile changed.  
No runtime implementation authorized.

## Moved Files

- `600001` → `604101`
- `600002` → `604102`
- `600003` → `604103`
- `600000_Index_Implementation_Lifecycle_Expansion_Wave_1` → `609001`
- `000100` → `602101`
- `000101` → `602102`
- `000102` → `602103`
- `000103` → `602104`
- `000104` → `604201`
- `000105` → `604202`
- `051355` → `600179`

## Updated Index / Directory Files

- `docs/600000_implementation_lifecycle/600000_Index_Implementation_Lifecycle.md`
- `docs/000005_Index_Document_Number.md`
- `docs/000007_Map_Full_Directory.md`

Supporting document link updated:

- `docs/000095_Overview_WP_9B_001_Source_Module_Map_Static_Validation_And_Evidence_Gate.md`

## Verification Commands Executed

- Root misplaced-file scan with `Get-ChildItem`.
- Canonical directory and file existence checks with `Test-Path` and `Get-Item`.
- H1-to-filename checks with `Get-Content -TotalCount 1`.
- Old-reference scans with `rg -n` across `docs/` and the lifecycle folder.
- `git diff --stat -- docs/600000_implementation_lifecycle`.
- `git diff --name-only -- docs/600000_implementation_lifecycle`.
- `git diff --check -- docs/600000_implementation_lifecycle`.

## Remaining Old References

- Former filenames remain in this relocation history, the active Index migration notice, `Former File Name` metadata, and the archived Wave 1 creation list.
- Historical Batch 8A evidence documents outside this lifecycle folder retain the former Expansion Wave 1 path pending a separate decision.
- Alternate navigation files `docs/000005_Index_Document_Number.md` and `docs/000007_Map_Full_Directory.md` were not changed because this task limits directory/index correction to two canonical files.

## Open Questions

- Should the alternate number index and directory map be synchronized in a separately approved documentation task?
- Should historical Batch 8A records add the canonical archive path while preserving their former-path history?

## Rollback

1. Move `604101`, `604102`, and `604103` back to root as `600001`, `600002`, and `600003`; restore their former H1 values and references.
2. Move `609001` back to root as `600000_Index_Implementation_Lifecycle_Expansion_Wave_1.md`; restore its former H1 and remove archive metadata.
3. Move `602101` through `602104` back to root as `000100` through `000103`; restore their former H1 values and references.
4. Move `604201` and `604202` back to root as `000104` and `000105`; restore their former H1 values and references.
5. Move `600179` back to root under its former `051355` filename; restore its former H1 and remove relocation metadata.
6. Restore the active Index and two canonical navigation files to their pre-cleanup content.
7. Remove this relocation record.

## Closeout Decision

PASS
