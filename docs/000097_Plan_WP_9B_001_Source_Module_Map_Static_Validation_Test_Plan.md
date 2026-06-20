# 000097_Plan_WP_9B_001_Source_Module_Map_Static_Validation_Test_Plan

## Purpose

Define the manual and static validation test plan for WP-9B-001 source module map static validation.

This plan describes how validation is performed without executable tests. Batch 9F does not execute this plan against live files unless a later batch explicitly authorizes execution.

## WorkPackage ID

`WP-9B-001 Source Module Map Static Validation And Evidence Gate`

## Manual And Static Validation Scenarios

| Scenario ID | Scenario | Method | Authorized In Batch 9F |
| --- | --- | --- | --- |
| SC-01 | Review committed schema structure | Read-only file review | Design only |
| SC-02 | Review committed example JSON structure | Read-only file review | Design only |
| SC-03 | Map SMM cases to schema fields | Documentation matrix | Yes |
| SC-04 | Define JSON syntax validation procedure | Manual step list | Yes |
| SC-05 | Define schema alignment procedure | Manual step list | Yes |
| SC-06 | Define forbidden content scan procedure | Manual checklist | Yes |
| SC-07 | Define forbidden path coverage procedure | Boundary cross-check | Yes |
| SC-08 | Define static evidence gate procedure | Gate logic reference | Yes |
| SC-09 | Execute validation against example JSON | Manual or tool-assisted | No — deferred to Batch 9G |
| SC-10 | Record validation execution evidence | Report artifact | No — deferred to Batch 9G |

## JSON Syntax Validation

Procedure VAL-SYNTAX-01 (design; execution deferred):

| Step | Action | Expected Result |
| --- | --- | --- |
| 1 | Read target map JSON file as UTF-8 | File readable without encoding error |
| 2 | Parse JSON with standards-compliant parser | No parse error |
| 3 | Confirm root value is object | Root type is object, not array or scalar |
| 4 | Record parser result in validation evidence | Pass or FAIL-STRUCT documented |

Primary fixtures for future execution:

- `packages/source_module_map/source_module_map.schema.json`
- `packages/source_module_map/source_module_map.example.json`

Maps to SMM-001.

## Schema / Example Alignment Validation

Procedure VAL-SCHEMA-01 (design; execution deferred):

| Step | Action | Expected Result |
| --- | --- | --- |
| 1 | Load committed schema | Schema readable and valid JSON |
| 2 | Confirm required top-level fields | `map_version`, `source_files`, `modules`, `ownership`, `test_mapping`, `forbidden_paths` |
| 3 | Validate example JSON against schema shape | All required fields present; types match; no extra top-level properties |
| 4 | Validate nested arrays | Source file, module, ownership, and test mapping items satisfy item schemas |
| 5 | Cross-reference module IDs | All referenced module IDs resolve across arrays |
| 6 | Record alignment result | Pass or FAIL-ALIGNMENT documented |

Maps to SMM-009.

No JSON Schema validator library may be installed. Alignment is manual/static or approved inline review tooling in a future batch only.

## SMM-001 Through SMM-009 Case Execution Plan

| Case ID | Execution Step Summary | Validation Procedure | Expected Pass Evidence |
| --- | --- | --- | --- |
| SMM-001 | Parse example JSON | VAL-SYNTAX-01 | Parser success note |
| SMM-002 | Check `map_version` | Required field + non-empty string check | Field present and placeholder-safe |
| SMM-003 | Check `source_files` | SF-01 through SF-06 from `000096` | Entries use placeholder-safe paths and valid shape |
| SMM-004 | Check `modules` | MOD-01 through MOD-06 from `000096` | Module records complete with ID, name, domain |
| SMM-005 | Check `ownership` | OWN-01 through OWN-04 from `000096` | Owner explicit or TBD; module linkage valid |
| SMM-006 | Check `test_mapping` | TM-01 through TM-06 from `000096` | Test path points to non-executable validation notes |
| SMM-007 | Check `forbidden_paths` | FP-01 through FP-07 from `000096` | App, backend, data, and package config boundaries covered |
| SMM-008 | Forbidden secret/production/provider scan | Forbidden content scan from `000096` | No secrets, production IDs, or provider runtime markers |
| SMM-009 | Schema/example alignment and non-runtime status | VAL-SCHEMA-01 + README boundary review | Example conforms to schema; map remains non-runtime |

Detailed field mapping is in `docs/000098_Matrix_WP_9B_001_SMM_001_To_SMM_009_Validation_Case_Coverage_Map.md`.

## Non-Executable Test Boundary

Batch 9F and WP-9B-001 artifact pack explicitly forbid:

| Forbidden Test Behavior | Reason |
| --- | --- |
| Executable unit/integration tests | No runtime stack approved |
| CI test runner configuration | No package/config files approved |
| Python/Node/shell validation scripts | Executable validation deferred |
| Database-backed validation | No Supabase/SQL approved |
| Provider API calls | No provider integration approved |
| Auto-generated validation output under `docs-generated/` | Generated output lane not approved |
| Mutation of example JSON to simulate failures | Skeleton modification forbidden in Batch 9F |

Negative test fixtures may be designed in documentation but must not be created as files until a later approved batch.

## Evidence Capture Expectations

When validation execution is authorized in Batch 9G or later, evidence must capture:

| Evidence Item | Required Content |
| --- | --- |
| Validation batch ID | Batch identifier and date |
| Input files reviewed | Schema and example paths with commit hash |
| SMM case results | Pass/fail per SMM-001 through SMM-009 |
| Failure codes | Any FAIL-* codes from `000096` |
| Gate result | PASS-GATE or FAIL-GATE |
| Cross-reference checks | Module ID linkage and forbidden path coverage notes |
| Reviewer | Human reviewer identity or role |
| Mutation confirmation | Skeleton files unchanged unless approved |

Batch 9F captures design evidence only through the artifact pack itself.

## Blockers Before Executable Validation

Executable validation remains blocked until all of the following are satisfied:

| Blocker | Status After Batch 9F |
| --- | --- |
| WP-9B-001 artifact pack complete | Pending closeout confirmation |
| Human approval for validation execution | Not granted |
| Allowed execution method defined | Not defined |
| Allowed file mutation boundary for negative fixtures | Not approved |
| Rollback plan for any validation script creation | Not approved |
| Staging and commit authorization for execution artifacts | Not granted |
| Runtime implementation authorization | Not granted |
| Package/config file creation authorization | Not granted |

## Implementation Status

Implementation and executable validation are not authorized by WP-9B-001 or Batch 9F.
