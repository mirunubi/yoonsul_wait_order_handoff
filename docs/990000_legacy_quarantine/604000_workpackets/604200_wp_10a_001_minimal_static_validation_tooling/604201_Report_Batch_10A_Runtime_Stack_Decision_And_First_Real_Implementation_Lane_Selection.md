# 604201_Report_Batch_10A_Runtime_Stack_Decision_And_First_Real_Implementation_Lane_Selection.md

## 1. Purpose

Decide the first real implementation lane and runtime stack direction after WP-8A-001, WP-9A-001, and WP-9B-001 static validation closeout.

Batch 10A is decision and report only. It does not authorize runtime implementation, executable tooling creation, package/config creation, or any file mutation outside this report.

## 2. Current Repository State

| Check | Result |
| --- | --- |
| Latest commit | `1be4f33` — `docs: close out WP-9B-001 source module map validation artifact pack and evidence` |
| Worktree | Clean |
| Batch 7 documentation expansion | Complete |
| 2300+ docs milestone | Complete |
| Tracked SQL / Dart / TS / JS runtime source | None |
| Root package/config files | None approved |
| Executable test framework | None approved |
| `tools/` directory | Does not exist |
| Committed neutral skeletons | `packages/hydration_registry/`, `packages/source_module_map/` |
| Committed non-executable validation cases | `tests/hydration_registry/`, `tests/source_module_map/` |
| Runtime implementation authorization | **Not granted** |

## 3. Closed WorkPackages

| WorkPackage | Phase | Result | Commit Reference |
| --- | --- | --- | --- |
| WP-8A-001 | Read-only hydration foundation and neutral skeleton | Closed | `11d768d` |
| WP-9A-001 | Hydration registry schema validation and static evidence gate | PASS-GATE — HR-001 through HR-009 | `742c62e` |
| WP-9B-001 | Source module map static validation and evidence gate | PASS-GATE — SMM-001 through SMM-009 | `1be4f33` |

Both validation lanes completed with zero skeleton edits required and zero implementation blockers from findings.

## 4. Runtime Implementation Status

| Lane | Status |
| --- | --- |
| App runtime (`apps/`) | Not approved |
| Supabase / SQL | Not approved |
| Flutter/Dart | Not approved |
| TS/JS / Node | Not approved |
| Root package/config | Not approved |
| Executable test framework | Not approved |
| Payment/provider runtime | Not approved |
| Production runtime logic | Not approved |

The repository remains documentation-first with neutral JSON skeletons and manual/static validation evidence only.

## 5. Decision Options

| Option | Lane | Summary |
| --- | --- | --- |
| **A** | Python-free / docs-only static validation | Continue manual JSON/schema validation in documentation only |
| **B** | Minimal Python validation tooling | Add small Python scripts under approved tooling paths to validate committed JSON skeletons |
| **C** | Supabase-first | Start database schema design and migration |
| **D** | Flutter app-first | Start app shell and UI runtime |
| **E** | Admin console read-only | Start read-only admin projection (requires stack choice) |
| **F** | POS Gateway | Payment/provider-adjacent runtime projection |

## 6. Option Scoring Matrix

Score scale: 1 is weak/high risk, 5 is strong/low risk for first real implementation entry.

| Option | Blast Radius | Dependency Clarity | WP-8A/9A/9B Leverage | Testability | Rollback Simplicity | Stack Lock-In Risk | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| **A** | 5 | 5 | 5 | 3 | 5 | 5 | **28** |
| **B** | 5 | 5 | 5 | 5 | 5 | 4 | **29** |
| **C** | 2 | 3 | 2 | 4 | 2 | 2 | 15 |
| **D** | 2 | 2 | 2 | 3 | 2 | 1 | 12 |
| **E** | 3 | 2 | 3 | 3 | 3 | 2 | 16 |
| **F** | 1 | 3 | 2 | 3 | 2 | 2 | 13 |

Tie-break: Option B over Option A because WP-9A-001 and WP-9B-001 already defined executable validation blockers and execution plans. The next incremental step is authorized tooling design, not indefinite manual-only repetition.

## 7. Recommended First Real Implementation Lane

**Recommended option: B — Minimal Python validation tooling lane**

**Recommended WorkPackage:**

`WP-10A-001 Minimal Static Validation Tooling For Hydration Registry And Source Module Map`

### Reason For Selection

1. **Direct continuation of closed validation WorkPackages.** WP-9A-001 and WP-9B-001 passed all cases manually. Executable tooling automates repeatable checks without changing skeleton semantics.
2. **Lowest incremental runtime risk.** Python scripts can validate JSON syntax, schema alignment, forbidden-pattern scans, and cross-reference rules without touching Supabase, apps, or payment surfaces.
3. **No payment mutation.** Tooling reads committed skeleton JSON only; no provider integration.
4. **No Supabase mutation.** No SQL, migrations, or database connections required.
5. **No Flutter/Node stack commitment.** Python tooling does not select app framework or frontend stack.
6. **Confidence before product runtime.** Repeatable validation produces evidence before database or UI work begins.
7. **Aligns with Batch 8E/8F boundary precedent.** First approved implementation was skeleton-only and language-neutral; tooling under `tools/static_validation/` is the next bounded step, not app runtime.

## 8. Why Other Options Are Deferred

| Option | Status | Reason |
| --- | --- | --- |
| A | Deferred as primary | Safe but delays first executable implementation indefinitely; manual validation already complete for current skeletons |
| C | Deferred | Supabase-first requires frozen table/domain boundaries; high rollback cost; contradicts docs-first staged entry |
| D | Deferred | Flutter app-first creates UI/runtime complexity and stack lock-in before validation tooling and domain boundaries are executable |
| E | Deferred | Admin read-only projection requires stack choice (Flutter web, TS/Next, or other) not yet approved |
| F | Deferred | POS Gateway is payment/provider-adjacent; Batch 9A and 9F scoring consistently rank this last |

## 9. Proposed Next WorkPackage

| Field | Value |
| --- | --- |
| WorkPackage ID | WP-10A-001 |
| Title | Minimal Static Validation Tooling For Hydration Registry And Source Module Map |
| Scope | Design authorization for small Python scripts that validate hydration registry and source module map JSON against committed schemas and SMM/HR rules |
| Non-goals | App runtime, Supabase, SQL, Flutter, TS/JS, package managers, CI wiring, production logic |

**Recommended next batch:**

`Batch 10B WP-10A-001 Implementation Authorization Packet`

Batch 10B must define exact allowed files, command boundaries, rollback plan, and human approval checklist before any executable tooling is created.

## 10. Allowed Future Paths

These paths are **candidates only** for Batch 10B authorization review. They are **not approved** in Batch 10A.

| Path | Future Use | Condition |
| --- | --- | --- |
| `tools/static_validation/` | Python validation scripts (read-only JSON checks) | Requires Batch 10B explicit file list approval |
| `tests/static_validation/` | Non-runtime validation fixtures, expected-fail samples, markdown evidence hooks | Requires Batch 10B explicit file list approval |

Allowed tooling behavior in WP-10A-001 scope (future, if approved):

- read committed JSON under `packages/hydration_registry/` and `packages/source_module_map/`;
- validate syntax and schema alignment;
- run forbidden-pattern scans per `000087` and `000096` logic;
- emit stdout/report evidence only;
- exit non-zero on validation failure.

## 11. Forbidden Future Paths

Forbidden until a separate batch explicitly approves otherwise:

| Path / Class | Status |
| --- | --- |
| `apps/` | Forbidden |
| `supabase/` | Forbidden |
| `data/` | Forbidden |
| `docs-generated/` | Forbidden |
| Root `package.json`, `pyproject.toml`, `requirements.txt`, lockfiles | Forbidden unless Batch 10B explicitly approves minimal Python dependency boundary |
| Flutter/Dart source | Forbidden |
| TS/JS source | Forbidden |
| SQL / migrations | Forbidden |
| Production runtime logic | Forbidden |
| Provider/payment integration | Forbidden |
| Modification of committed skeleton JSON without approved skeleton batch | Forbidden |

## 12. Human Approval Gate

Human approval is required before Batch 10B or any later batch may:

- create files under `tools/static_validation/` or `tests/static_validation/`;
- create Python scripts or executable validation runners;
- create dependency/config files for Python;
- wire tooling into CI;
- stage or commit implementation files;
- authorize Supabase, Flutter, TS/JS, or app runtime work.

Batch 10A records the decision only. No approval is granted in this batch.

## 13. Implementation Blocker Statement

**Implementation is not approved in Batch 10A.**

Batch 10A does not authorize:

- runtime code creation;
- Python script creation;
- package/config file creation;
- SQL, Flutter/Dart, TS/JS, or Supabase files;
- skeleton modification;
- staging or commit of implementation artifacts.

The only permitted output is this decision report.

Batch 10B must define the exact allowed file list before any executable tooling is created.

## 14. Safety Statement

- Report-only batch
- No stage
- No commit
- No runtime implementation
- No tooling creation
- No package/config creation
- No SQL
- No Flutter/Dart
- No TS/JS
- No Supabase
- No `apps/`, `data/`, or `docs-generated/` artifacts
- No `packages/` or `tests/` skeleton modification
- No rename
- No move
- No delete
- No formatter
- UTF-8 preserved
