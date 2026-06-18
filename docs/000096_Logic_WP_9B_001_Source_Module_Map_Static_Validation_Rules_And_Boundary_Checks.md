# 000096_Logic_WP_9B_001_Source_Module_Map_Static_Validation_Rules_And_Boundary_Checks.md

## Purpose

Define validation rules, boundary checks, and static evidence gate logic for WP-9B-001 source module map static validation.

This document is logic design only. It does not execute validation and does not modify skeleton files.

## WorkPackage ID

`WP-9B-001 Source Module Map Static Validation And Evidence Gate`

## Source File Entry Validation Rule Categories

| Rule ID | Category | Rule |
| --- | --- | --- |
| SF-01 | Presence | `source_files` array must exist |
| SF-02 | Item shape | Each item must include `path`, `module_id`, `file_role` |
| SF-03 | Path safety | `path` must use placeholder-safe repository-relative paths |
| SF-04 | Module linkage | `module_id` must reference a module defined in `modules[]` |
| SF-05 | Role neutrality | `file_role` must describe documentation or placeholder role, not runtime behavior |
| SF-06 | Forbidden paths | No `source_files[].path` may start with forbidden prefixes unless explicitly marked as inventory-only read in boundary map |
| SF-07 | Existence (execution phase) | Referenced paths should exist on disk when execution batch runs |

Violation of SF-01 through SF-06 is **FAIL-SOURCE-FILE** unless otherwise classified.

## Module Entry Validation Rule Categories

| Rule ID | Category | Rule |
| --- | --- | --- |
| MOD-01 | Presence | `modules` array must exist and contain at least one entry in example fixture |
| MOD-02 | Item shape | Each item must include `module_id`, `module_name`, `domain` |
| MOD-03 | ID format | `module_id` must be placeholder-safe (for example `MODULE-PLACEHOLDER-001`) |
| MOD-04 | Domain reference | `domain` must reference approved WorkPackage or documentation domain, not live production tenant |
| MOD-05 | Uniqueness | `module_id` values must be unique within the map |
| MOD-06 | Cross-reference | Every `source_files[].module_id` and `ownership[].module_id` must resolve to a `modules[].module_id` |

Violation of MOD-01 through MOD-06 is **FAIL-MODULE** unless otherwise classified.

## Ownership Validation Rule Categories

| Rule ID | Category | Rule |
| --- | --- | --- |
| OWN-01 | Presence | `ownership` array must exist |
| OWN-02 | Item shape | Each item must include `module_id` and `owner` |
| OWN-03 | Owner neutrality | `owner` must be explicit role or `TBD`; no personal email or live account |
| OWN-04 | Module linkage | `module_id` must reference a defined module |
| OWN-05 | Coverage | Each module should have an ownership entry in complete maps; example fixture may use one placeholder entry |

Violation of OWN-01 through OWN-04 is **FAIL-OWNERSHIP**.

## Test Mapping Validation Rule Categories

| Rule ID | Category | Rule |
| --- | --- | --- |
| TM-01 | Presence | `test_mapping` array must exist |
| TM-02 | Item shape | Each item must include `module_id`, `test_path`, `test_status` |
| TM-03 | Non-executable path | `test_path` must point to markdown validation notes or approved non-executable placeholder |
| TM-04 | Status neutrality | `test_status` must indicate manual/static placeholder, not CI or runtime test execution |
| TM-05 | Module linkage | `module_id` must reference a defined module |
| TM-06 | Forbidden targets | `test_path` must not point to executable test runners, package configs, or provider scripts |

Violation of TM-01 through TM-06 is **FAIL-TEST-MAP**.

## Forbidden Path Validation Rule Categories

| Rule ID | Category | Rule |
| --- | --- | --- |
| FP-01 | Presence | `forbidden_paths` array must exist and be non-empty in example fixture |
| FP-02 | App boundary | Must include `apps/` or equivalent app runtime prefix |
| FP-03 | Backend boundary | Must include `supabase/` or equivalent backend prefix |
| FP-04 | Data boundary | Must include `data/` or equivalent data prefix |
| FP-05 | Package config boundary | Must include package manager config markers (for example `package.json`, `pubspec.yaml`) per committed example |
| FP-06 | Consistency | Forbidden paths must align with `docs/000077_*` forbidden modification boundaries |
| FP-07 | No grant language | Forbidden path list must not include permissive runtime rules |

Violation of FP-01 through FP-07 is **FAIL-FORBIDDEN-PATH**.

## Placeholder-Only Data Boundary

Placeholder-safe values are required for the committed example fixture.

| Area | Placeholder-Safe Examples | Not Placeholder-Safe |
| --- | --- | --- |
| `map_version` | `0.1-placeholder` | Production semver implying live deployment |
| Module IDs | `MODULE-PLACEHOLDER-001` | Live tenant/store/user IDs |
| Module owner | `TBD`, role name | Personal email, API key owner |
| Test status | `manual-static-placeholder` | `passed`, `ci-green`, `production-verified` |
| File roles | `documentation-placeholder` | `runtime-entrypoint`, `api-handler` |
| Domains | `WP-8A-001`, documentation band IDs | Live customer or store identifiers |

Placeholder violation is **FAIL-PLACEHOLDER**.

## No Runtime Behavior Boundary

Manual content scan must reject source module map JSON containing:

| Forbidden Class | Examples / Patterns | Failure Code |
| --- | --- | --- |
| Secrets | `password`, `secret`, `api_key`, `token`, `credential`, `Bearer ` | FAIL-FORBIDDEN-SECRET |
| Production IDs | Live UUIDs presented as tenant/store/customer IDs | FAIL-FORBIDDEN-PROD-ID |
| Provider runtime | Provider API URLs, webhook endpoints, OAuth endpoints | FAIL-FORBIDDEN-PROVIDER |
| SQL / database | `SELECT `, `INSERT `, `CREATE TABLE`, connection strings | FAIL-FORBIDDEN-SQL |
| App runtime | Service endpoints under app scope | FAIL-FORBIDDEN-RUNTIME |
| Package manager runtime | Lockfile execution config, install scripts as behavior | FAIL-FORBIDDEN-STACK |

Scan is static string and field review only. No secret store access is authorized.

## Static Evidence Gate Logic

### Gate Inputs

1. Committed schema file.
2. Committed example JSON file.
3. SMM-001 through SMM-009 case results (manual review when execution batch runs).
4. WP-8A-001 boundary maps and WP-9A-001 validation precedent.

### Gate Evaluation Steps

| Step | Action | Outcome |
| --- | --- | --- |
| G-01 | Confirm JSON syntax valid for schema and example | Proceed or FAIL-STRUCT |
| G-02 | Confirm required top-level fields present | Proceed or FAIL-STRUCT |
| G-03 | Confirm type conformance for all required paths | Proceed or FAIL-TYPE |
| G-04 | Confirm source file entries valid | Proceed or FAIL-SOURCE-FILE |
| G-05 | Confirm module entries valid | Proceed or FAIL-MODULE |
| G-06 | Confirm ownership entries valid | Proceed or FAIL-OWNERSHIP |
| G-07 | Confirm test mapping entries valid | Proceed or FAIL-TEST-MAP |
| G-08 | Confirm forbidden paths coverage | Proceed or FAIL-FORBIDDEN-PATH |
| G-09 | Confirm placeholder-only data policy | Proceed or FAIL-PLACEHOLDER |
| G-10 | Confirm forbidden content scan clean | Proceed or FAIL-FORBIDDEN-* |
| G-11 | Confirm schema/example alignment | Proceed or FAIL-ALIGNMENT |
| G-12 | Confirm SMM-001 through SMM-009 mapped and reviewed | Proceed or FAIL-COVERAGE |
| G-13 | Classify aggregate gate result | PASS-GATE or FAIL-GATE |

### Gate Pass Rule

Gate passes only if steps G-01 through G-13 complete with no failure classification.

### Gate Fail Rule

Any single failure classification yields **FAIL-GATE**. Failed gate blocks executable validation authorization and downstream WorkPackage implementation gates.

## Failure Classification

| Code | Severity | Meaning | Remediation |
| --- | --- | --- | --- |
| FAIL-STRUCT | High | JSON or required structure invalid | Fix in approved skeleton batch only |
| FAIL-TYPE | High | Field type mismatch | Fix types in approved skeleton batch only |
| FAIL-SOURCE-FILE | High | Source file entry invalid | Correct source file records under approved batch |
| FAIL-MODULE | High | Module entry invalid | Correct module records under approved batch |
| FAIL-OWNERSHIP | Medium | Ownership entry invalid | Correct ownership records under approved batch |
| FAIL-TEST-MAP | Medium | Test mapping invalid | Correct test mapping under approved batch |
| FAIL-FORBIDDEN-PATH | Medium | Forbidden path list incomplete or inconsistent | Correct forbidden paths under approved batch |
| FAIL-PLACEHOLDER | Medium | Production-like values in placeholder fixture | Replace with placeholder-safe values |
| FAIL-ALIGNMENT | High | Example does not align with committed schema | Correct example under approved batch |
| FAIL-FORBIDDEN-SECRET | Critical | Secret or credential pattern detected | Remove forbidden content; security review |
| FAIL-FORBIDDEN-PROD-ID | High | Production identifier detected | Replace with placeholder IDs |
| FAIL-FORBIDDEN-PROVIDER | Critical | Provider runtime reference detected | Remove provider references |
| FAIL-FORBIDDEN-SQL | Critical | SQL or DB runtime reference detected | Remove SQL references |
| FAIL-FORBIDDEN-RUNTIME | Critical | App/runtime endpoint reference detected | Remove runtime references |
| FAIL-FORBIDDEN-STACK | High | Stack/config selection implied as runtime | Remove stack runtime references |
| FAIL-COVERAGE | Medium | SMM case not mapped or reviewed | Complete coverage matrix review |
| FAIL-GATE | High | Aggregate gate failure | Resolve underlying failure codes |
| PASS-GATE | N/A | Aggregate gate pass | Eligible for next planning/execution gate only |

Critical failures block all downstream authorization until human security review is recorded.
