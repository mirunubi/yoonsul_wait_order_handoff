# 604202_Report_Batch_10B_WP_10A_001_Implementation_Authorization_Packet.md

## 1. Purpose

Define the exact future allowed file list and command boundary for WP-10A-001 Minimal Static Validation Tooling For Hydration Registry And Source Module Map.

Batch 10B is documentation and authorization only. It does not create tooling files, Python scripts, package/config files, or runtime behavior.

## 2. WorkPackage ID

| Field | Value |
| --- | --- |
| WorkPackage ID | WP-10A-001 |
| Title | Minimal Static Validation Tooling For Hydration Registry And Source Module Map |
| Authorization batch | Batch 10B |
| Implementation batch (future) | Batch 10C — Minimal Static Validation Tooling Creation |

## 3. Reviewed Decision Artifact

| Artifact | Purpose |
| --- | --- |
| `604201_Report_Batch_10A_Runtime_Stack_Decision_And_First_Real_Implementation_Lane_Selection.md` | Selected Option B — Minimal Python validation tooling lane |
| `docs/000092_*` through `docs/000094_*` | WP-9A-001 PASS-GATE evidence |
| `docs/000101_*` through `docs/000103_*` | WP-9B-001 PASS-GATE evidence |
| `docs/000087_*`, `docs/000096_*` | Validation rule logic for HR and SMM cases |
| `packages/hydration_registry/*` | Committed skeleton inputs (read-only) |
| `packages/source_module_map/*` | Committed skeleton inputs (read-only) |

## 4. Proposed Implementation Lane

| Field | Value |
| --- | --- |
| Lane | Option B — Minimal Python validation tooling |
| Stack commitment | Python stdlib only for Batch 10C unless human explicitly approves dependency files in a later batch |
| Runtime class | Local static validation tooling — non-runtime |
| Product surfaces touched | None |
| Database touched | None |
| Payment/provider touched | None |

## 5. Exact Future Allowed File List

Batch 10C may create **only** these six files after human approval. No other files may be created in Batch 10C without a new authorization packet.

| # | Path | Type | Purpose |
| --- | --- | --- | --- |
| 1 | `tools/static_validation/README.md` | Markdown | Tooling boundary, usage notes, forbidden behavior |
| 2 | `tools/static_validation/validate_hydration_registry.py` | Python | Read-only validation of hydration registry JSON against schema and HR rules |
| 3 | `tools/static_validation/validate_source_module_map.py` | Python | Read-only validation of source module map JSON against schema and SMM rules |
| 4 | `tools/static_validation/static_validation_manifest.json` | JSON | Neutral manifest listing validation targets, rule references, and non-runtime boundary |
| 5 | `tests/static_validation/README.md` | Markdown | Non-executable test lane boundary for static validation |
| 6 | `tests/static_validation/static_validation_cases.md` | Markdown | Executable-tooling case descriptions and expected outcomes |

**Total allowed new files in Batch 10C:** 6

### Allowed Directory Creation

Batch 10C may create these directories only as parents of the six allowed files:

- `tools/static_validation/`
- `tests/static_validation/`

## 6. Explicit Forbidden File List

Forbidden in Batch 10C and until separately approved:

| Path / Class | Status | Reason |
| --- | --- | --- |
| `apps/` | Forbidden | App runtime not approved |
| `supabase/` | Forbidden | Backend/SQL not approved |
| `data/` | Forbidden | Data lane not approved |
| `docs-generated/` | Forbidden | Generated output lane not approved |
| Root `package.json`, `pyproject.toml`, `requirements.txt`, `Pipfile`, lockfiles | Forbidden | Package manager boundary not approved in Batch 10B |
| `packages/hydration_registry/*` modification | Forbidden | Skeleton read-only |
| `packages/source_module_map/*` modification | Forbidden | Skeleton read-only |
| `tests/hydration_registry/*` modification | Forbidden | Skeleton read-only |
| `tests/source_module_map/*` modification | Forbidden | Skeleton read-only |
| SQL files (`.sql`) | Forbidden | Database not approved |
| Flutter/Dart files | Forbidden | App stack not approved |
| TS/JS files | Forbidden | Node stack not approved |
| CI config (`.github/workflows/*`, etc.) | Forbidden | CI wiring not approved |
| Production runtime logic | Forbidden | Out of scope |
| Provider/payment integration code | Forbidden | High risk |

## 7. Allowed Commands For Future Batch 10C

| Command Class | Allowed | Condition |
| --- | --- | --- |
| `python tools/static_validation/validate_hydration_registry.py` | Yes | After Batch 10C file creation and human approval |
| `python tools/static_validation/validate_source_module_map.py` | Yes | After Batch 10C file creation and human approval |
| Read-only file open/read for JSON under `packages/` | Yes | No write |
| `git add` for the six allowed files only | Yes | After validation passes |
| `git commit` for Batch 10C tooling | Yes | After explicit human approval |

## 8. Forbidden Commands For Future Batch 10C

| Command Class | Forbidden |
| --- | --- |
| `pip install`, `npm install`, `pub get`, package manager installs | Yes |
| Database migration or Supabase CLI commands | Yes |
| App build/run commands | Yes |
| `git add .`, `git add -A` | Yes |
| `git clean` | Yes |
| Formatter commands on repo-wide scope | Yes |
| Any command that writes to skeleton paths under `packages/` or existing `tests/hydration_registry/`, `tests/source_module_map/` | Yes |
| Network calls to providers, webhooks, or external APIs | Yes |
| Secret/env file reads beyond public committed JSON | Yes |

## 9. Validation Scope

Future Batch 10C tooling must validate read-only against committed skeleton inputs:

| Target | Validation Scope |
| --- | --- |
| Hydration registry | JSON syntax; schema alignment; HR-001 through HR-009 rules per `000087`, `000092` |
| Source module map | JSON syntax; schema alignment; SMM-001 through SMM-009 rules per `000096`, `000101` |
| Forbidden content | Secret, credential, production ID, provider, SQL, runtime endpoint scans |
| Output | Stdout/stderr and exit code only — no generated runtime artifacts |
| Side effects | Must not mutate skeleton JSON, database, or filesystem outside the six allowed new files |

Tooling must use Python stdlib only in Batch 10C unless a later batch explicitly approves dependencies.

## 10. Runtime Boundary

| Boundary | Rule |
| --- | --- |
| Runtime class | Local static validation tooling only |
| Network | No outbound network required or permitted |
| Database | No connections |
| App/UI | No creation or invocation |
| Payment/provider | No integration |
| Skeleton mutation | Forbidden |
| Production behavior | Forbidden |

Batch 10C tooling is validation infrastructure, not product runtime.

## 11. Rollback Boundary

If Batch 10C tooling is approved and later must be reverted:

| Action | Rollback Method |
| --- | --- |
| Remove tooling files | Delete only the six allowed Batch 10C files and empty `tools/static_validation/`, `tests/static_validation/` if no other approved files exist |
| Skeleton impact | None expected — skeletons must remain unchanged |
| Docs impact | Batch 10B/10A authorization docs remain as governance history |
| Commit rollback | Revert Batch 10C commit only; do not revert WP-9A/WP-9B evidence commits |

## 12. Human Approval Requirement

Human approval is required before Batch 10C may:

- create any of the six allowed files;
- run newly created validation scripts for the first staged commit;
- stage or commit tooling files;
- add Python dependencies or config files;
- expand scope beyond the six-file list.

Batch 10B records authorization packet only. **Implementation is not executed in Batch 10B.**

## 13. Authorization Status

| Item | Batch 10B Status |
| --- | --- |
| Option B lane selected | Recorded — via `000104` |
| Exact future file list defined | Yes — six files |
| Batch 10C tooling creation authorized | **Conditional — awaiting human approval to start Batch 10C** |
| Tooling files created | **No** |
| Python files created | **No** |
| Runtime implementation authorized | **No** |
| Skeleton modification authorized | **No** |

**Authorization summary:** Batch 10B authorizes a **future exact file list** for Batch 10C. It does **not** execute implementation.

## 14. Proposed Next Batch

**Recommended next batch:**

`Batch 10C Minimal Static Validation Tooling Creation`

Batch 10C may create only the six exact files listed in Section 5 after human approval.

Batch 10C must not create:

- `apps/`, `supabase/`, `data/`, `docs-generated/`
- root package/config files
- SQL, Flutter/Dart, TS/JS
- production runtime logic

Batch 10C tooling must remain local static validation only and must not mutate skeleton files.

## 15. Safety Statement

- Documentation/authorization only
- No tooling creation in Batch 10B
- No Python file creation in Batch 10B
- No package/config creation
- No runtime implementation
- No SQL, Flutter/Dart, TS/JS, Supabase
- No `apps/`, `data/`, or `docs-generated/` artifacts
- No `packages/` or existing `tests/` skeleton modification
- No rename, move, delete, formatter
- UTF-8 preserved
