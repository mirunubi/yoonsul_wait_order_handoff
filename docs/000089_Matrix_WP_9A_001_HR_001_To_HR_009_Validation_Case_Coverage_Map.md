# 000089_Matrix_WP_9A_001_HR_001_To_HR_009_Validation_Case_Coverage_Map.md

## Purpose

Map HR-001 through HR-009 validation cases to schema fields, evidence requirements, and static validation boundaries for WP-9A-001.

## WorkPackage ID

`WP-9A-001 Hydration Registry Schema Validation And Static Evidence Gate`

## Coverage Matrix

| Case ID | Validation Purpose | Expected Input | Expected Result | Related Schema Field | Evidence Requirement | Allowed / Forbidden Boundary | Current Status |
| --- | --- | --- | --- | --- | --- | --- | --- |
| HR-001 | Confirm registry JSON is syntactically valid | `packages/hydration_registry/hydration_registry.example.json` | JSON parser accepts file; root is object | Root document | Record parser pass in future execution report; cite commit hash of input file | **Allowed:** read-only parse review. **Forbidden:** mutating example file in Batch 9B | Designed — not executed |
| HR-002 | Confirm `registry_version` present and usable | Same example JSON | Field present, non-empty string | `registry_version` | Note field value matches placeholder-safe pattern | **Allowed:** static field review. **Forbidden:** production semver implying live deployment | Designed — not executed |
| HR-003 | Confirm `generated_at` present and placeholder-safe | Same example JSON | Field present; placeholder timestamp acceptable | `generated_at` | Note placeholder format (for example `YYYY-MM-DDTHH:MM:SSZ`) | **Allowed:** placeholder timestamp. **Forbidden:** live system timestamp used as identity | Designed — not executed |
| HR-004 | Confirm `source_scope` defines included and excluded paths | Same example JSON | `included_paths` and `excluded_paths` arrays present and non-empty | `source_scope`, `source_scope.included_paths`, `source_scope.excluded_paths` | List paths reviewed; confirm alignment with WP-8A-001 boundaries | **Allowed:** skeleton and docs paths in included list. **Forbidden:** undeclared secret or runtime paths | Designed — not executed |
| HR-005 | Confirm `modules` entries are placeholder-safe | Same example JSON | Each module has `module_id`, `module_name`, `source_paths`, `owner`, `status`; values placeholder-safe | `modules[]`, `modules[].module_id`, `modules[].module_name`, `modules[].source_paths`, `modules[].owner`, `modules[].status` | Record module IDs and owners reviewed against placeholder policy | **Allowed:** `TBD`, `placeholder` status. **Forbidden:** live tenant/store/user IDs | Designed — not executed |
| HR-006 | Confirm `evidence` paths point to documentation evidence only | Same example JSON | Each evidence item has `evidence_id`, `description`, `path`; paths under `docs/` | `evidence[]`, `evidence[].evidence_id`, `evidence[].description`, `evidence[].path` | Confirm referenced docs path exists on disk at execution time | **Allowed:** `docs/` references (for example `docs/000075_*`). **Forbidden:** `apps/`, `supabase/`, URLs, runtime output paths | Designed — not executed |
| HR-007 | Confirm `restrictions` explicitly declare forbidden paths | Same example JSON | Each restriction has `restriction_id`, `path_pattern`, `rule`; patterns match forbidden boundaries | `restrictions[]`, `restrictions[].restriction_id`, `restrictions[].path_pattern`, `restrictions[].rule` | Cross-check against `000077` forbidden paths | **Allowed:** rules forbidding `apps/`, `supabase/`, `data/`. **Forbidden:** rules that grant runtime access | Designed — not executed |
| HR-008 | Confirm registry excludes secrets and credentials | Same example JSON | No secret, credential, token, or production ID strings | All string fields (recursive review) | Document forbidden-pattern scan result | **Allowed:** static string scan. **Forbidden:** reading live secret stores or env files | Designed — not executed |
| HR-009 | Confirm registry excludes runtime behavior markers | Same example JSON | No endpoint, SQL, provider, or app runtime behavior appears | All string fields (recursive review) | Document forbidden-runtime scan result | **Allowed:** static content review. **Forbidden:** provider calls, DB queries, app endpoint definitions | Designed — not executed |

## Aggregate Coverage Summary

| Metric | Value |
| --- | --- |
| Total cases | 9 |
| Cases mapped to schema fields | 9 |
| Cases with evidence requirement defined | 9 |
| Cases with allowed/forbidden boundary defined | 9 |
| Cases executed | 0 |
| Cases passed (execution) | N/A |
| Cases failed (execution) | N/A |

## Static Evidence Gate Linkage

| Gate Step | Related Cases |
| --- | --- |
| G-01 Syntax | HR-001 |
| G-02 Required fields | HR-002, HR-003, HR-004, HR-005, HR-006, HR-007 |
| G-03 Type conformance | HR-002 through HR-007 (implicit in schema alignment) |
| G-04 Evidence objects | HR-006 |
| G-05 Restrictions | HR-007 |
| G-06 Placeholder safety | HR-003, HR-005 |
| G-07 Forbidden content | HR-008, HR-009 |
| G-08 Coverage complete | HR-001 through HR-009 |
| G-09 Aggregate gate | All cases must pass for PASS-GATE |

## Current Status Notes

All nine cases are **Designed — not executed** as of Batch 9B artifact pack creation.

Execution requires a future batch with explicit human approval for validation execution. Batch 9B modifies no skeleton files and produces no execution evidence.
