# 000077_Matrix_WP_8A_001_Allowed_And_Forbidden_File_Boundary_Map

## Purpose

Define allowed read-only inspection boundaries and forbidden modification boundaries for WP-8A-001.

## Allowed Read-Only Inspection Paths

| Path Pattern | Allowed Action | Notes |
|---|---|---|
| `docs/` | Read documentation references | No existing docs edits |
| `apps/` | Read-only inventory only | Current tracked files are placeholders |
| `packages/` | Read-only inventory only | Current tracked files are placeholders |
| `data/` | Read-only inventory only | No data mutation |
| `tests/` | Read-only inventory only | No test execution without approval |
| `.cursor/` | Read cursor rule metadata | No edits |
| root tracked evidence files | Read-only inventory only | No edits |

## Forbidden Modification Paths

| Path Pattern | Forbidden Modification |
|---|---|
| `apps/` | No runtime/app code edits |
| `packages/` | No package/domain/UI code edits |
| `data/` | No seed/data edits |
| `tests/` | No test edits and no test execution without approval |
| SQL or migration paths | No SQL edits and no migration execution |
| Supabase-related paths | No Supabase runtime edits or deploys |
| Flutter/Dart paths | No Dart edits and no formatter |
| `.gitignore` | No edits |
| existing docs | No H1 or internal link edits |

## Forbidden Command List

| Command Class | Status |
|---|---|
| `git add` | Forbidden in Batch 8C |
| `git commit` | Forbidden in Batch 8C |
| `git clean` | Forbidden |
| `git mv` | Forbidden |
| `rm`, `del`, `Remove-Item` | Forbidden |
| formatter commands | Forbidden |
| package install commands | Forbidden |
| app build commands | Forbidden |
| database migration commands | Forbidden |
| test execution commands | Forbidden unless approved later |

## Candidate Future Allowed Implementation Files Placeholder

No future implementation file is approved yet.

| Future File | Allowed Action | Approval Required |
|---|---|---|
| TBD | TBD | Yes |

## Candidate Future Forbidden Implementation Files Placeholder

| File Class | Default Status | Reason |
|---|---|---|
| Payment mutation files | Forbidden | Direct financial risk |
| Provider integration files | Forbidden | External dependency risk |
| SQL migrations | Forbidden | Data mutation risk |
| Supabase runtime | Forbidden | Backend runtime risk |
| Flutter/Dart runtime | Forbidden | App runtime risk |
| Secret/env files | Forbidden | Security risk |

## Human Approval Gate

Human approval is required before:

- any source edit;
- any SQL edit;
- any Flutter/Dart edit;
- any Supabase edit;
- any test execution;
- any staging or commit;
- any rename, move, delete, or archive action.

## Rollback Boundary Notes

Because Batch 8C is read-only plus new docs only, rollback should be limited to discarding the new Batch 8C docs if the user rejects them. Any unexpected non-doc mutation must stop the workflow and trigger human review.
