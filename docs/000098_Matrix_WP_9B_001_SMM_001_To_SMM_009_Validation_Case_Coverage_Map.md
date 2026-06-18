# 000098_Matrix_WP_9B_001_SMM_001_To_SMM_009_Validation_Case_Coverage_Map.md

## Purpose

Map SMM-001 through SMM-009 validation cases to schema fields, evidence requirements, and static validation boundaries for WP-9B-001.

## WorkPackage ID

`WP-9B-001 Source Module Map Static Validation And Evidence Gate`

## Coverage Matrix

| Case ID | Validation Purpose | Expected Input | Expected Result | Related Schema Field | Evidence Requirement | Allowed / Forbidden Boundary | Current Status |
| --- | --- | --- | --- | --- | --- | --- | --- |
| SMM-001 | Confirm source module map JSON parses as valid JSON | `packages/source_module_map/source_module_map.example.json` | JSON parser accepts file; root is object | Root document | Record parser pass in future execution report; cite commit hash of input file | **Allowed:** read-only parse review. **Forbidden:** mutating example file in Batch 9F | Designed — not executed |
| SMM-002 | Confirm `map_version` present and usable | Same example JSON | Field present, non-empty, placeholder-safe string | `map_version` | Note field value (for example `0.1-placeholder`) | **Allowed:** static field review. **Forbidden:** production semver implying live deployment | Designed — not executed |
| SMM-003 | Confirm `source_files` structure and placeholder-safe paths | Same example JSON | Array present; each item has `path`, `module_id`, `file_role`; paths placeholder-safe | `source_files[]`, `source_files[].path`, `source_files[].module_id`, `source_files[].file_role` | List paths reviewed; confirm module ID linkage | **Allowed:** skeleton/docs paths. **Forbidden:** runtime source paths without approval | Designed — not executed |
| SMM-004 | Confirm `modules` structure complete | Same example JSON | Array present; each item has `module_id`, `module_name`, `domain` | `modules[]`, `modules[].module_id`, `modules[].module_name`, `modules[].domain` | Record module IDs and domain references | **Allowed:** placeholder module IDs and WP domain refs. **Forbidden:** live tenant/store IDs | Designed — not executed |
| SMM-005 | Confirm `ownership` structure and TBD neutrality | Same example JSON | Array present; each item has `module_id`, `owner`; owner explicit or `TBD` | `ownership[]`, `ownership[].module_id`, `ownership[].owner` | Record owner values against placeholder policy | **Allowed:** `TBD`, role names. **Forbidden:** personal email, live account | Designed — not executed |
| SMM-006 | Confirm `test_mapping` points to non-executable validation notes | Same example JSON | Array present; items have `module_id`, `test_path`, `test_status`; path is markdown validation notes | `test_mapping[]`, `test_mapping[].module_id`, `test_mapping[].test_path`, `test_mapping[].test_status` | Confirm test path targets `tests/source_module_map/*.md` | **Allowed:** markdown validation case docs. **Forbidden:** executable test runners, package configs | Designed — not executed |
| SMM-007 | Confirm `forbidden_paths` covers app, backend, data, and package config boundaries | Same example JSON | Array non-empty; includes `apps/`, `supabase/`, `data/`, and package config markers | `forbidden_paths[]` | Cross-check against `docs/000077_*` forbidden boundaries | **Allowed:** forbidden prefix listing. **Forbidden:** permissive runtime grant entries | Designed — not executed |
| SMM-008 | Confirm no secrets, production IDs, or provider runtime behavior | Same example JSON | Static scan finds no secret, credential, production ID, or provider endpoint patterns | All string fields (recursive review) | Document forbidden-pattern scan result | **Allowed:** static string scan. **Forbidden:** secret store access, env file reads | Designed — not executed |
| SMM-009 | Confirm schema/example alignment and non-runtime status | Schema + example JSON + README boundary notes | Example conforms to schema; map remains documentation/control mapping only | All required top-level and nested fields; README boundary statements | Record alignment checklist result and non-runtime confirmation | **Allowed:** manual schema alignment review. **Forbidden:** implying runtime stack selection or executable tests | Designed — not executed |

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
| G-01 Syntax | SMM-001 |
| G-02 Required fields | SMM-002 through SMM-007 |
| G-03 Type conformance | SMM-002 through SMM-007 (implicit in schema alignment) |
| G-04 Source file entries | SMM-003 |
| G-05 Module entries | SMM-004 |
| G-06 Ownership entries | SMM-005 |
| G-07 Test mapping entries | SMM-006 |
| G-08 Forbidden paths | SMM-007 |
| G-09 Placeholder safety | SMM-002, SMM-003, SMM-004, SMM-005 |
| G-10 Forbidden content | SMM-008 |
| G-11 Schema alignment | SMM-009 |
| G-12 Coverage complete | SMM-001 through SMM-009 |
| G-13 Aggregate gate | All cases must pass for PASS-GATE |

## Skeleton Case Alignment Note

Committed `tests/source_module_map/source_module_map_validation_cases.md` defines nine SMM cases with slightly different emphasis on SMM-008 (production IDs) and SMM-009 (runtime exclusion). Batch 9F matrix expands SMM-008 to include secrets and provider runtime behavior and assigns schema alignment to SMM-009. Execution batches should satisfy both the committed skeleton case intent and this matrix.

## Current Status Notes

All nine cases are **Designed — not executed** as of Batch 9F artifact pack creation.

Execution requires a future batch (proposed Batch 9G) with explicit human approval for validation execution.
