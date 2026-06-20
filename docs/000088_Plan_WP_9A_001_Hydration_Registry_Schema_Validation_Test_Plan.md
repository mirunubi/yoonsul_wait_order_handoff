# 000088_Plan_WP_9A_001_Hydration_Registry_Schema_Validation_Test_Plan

## Purpose

Define the manual and static validation test plan for WP-9A-001 hydration registry schema validation.

This plan describes how validation is performed without executable tests. Batch 9B does not execute this plan against live files unless a later batch explicitly authorizes execution.

## WorkPackage ID

`WP-9A-001 Hydration Registry Schema Validation And Static Evidence Gate`

## Manual And Static Validation Scenarios

| Scenario ID | Scenario | Method | Authorized In Batch 9B |
| --- | --- | --- | --- |
| SC-01 | Review committed schema structure | Read-only file review | Design only |
| SC-02 | Review committed example JSON structure | Read-only file review | Design only |
| SC-03 | Map HR cases to schema fields | Documentation matrix | Yes |
| SC-04 | Define JSON syntax validation procedure | Manual step list | Yes |
| SC-05 | Define schema alignment procedure | Manual step list | Yes |
| SC-06 | Define forbidden content scan procedure | Manual checklist | Yes |
| SC-07 | Define static evidence gate procedure | Gate logic reference | Yes |
| SC-08 | Execute validation against example JSON | Manual or tool-assisted | No — deferred |
| SC-09 | Record validation execution evidence | Report artifact | No — deferred |

## JSON Syntax Validation

Procedure VAL-SYNTAX-01 (design; execution deferred):

| Step | Action | Expected Result |
| --- | --- | --- |
| 1 | Read target registry JSON file as UTF-8 | File readable without encoding error |
| 2 | Parse JSON with standards-compliant parser | No parse error |
| 3 | Confirm root value is object | Root type is object, not array or scalar |
| 4 | Record parser result in validation evidence | Pass or FAIL-STRUCT documented |

Primary fixture for future execution: `packages/hydration_registry/hydration_registry.example.json`

Maps to HR-001.

## JSON Schema Alignment Validation

Procedure VAL-SCHEMA-01 (design; execution deferred):

| Step | Action | Expected Result |
| --- | --- | --- |
| 1 | Load committed schema | `hydration_registry.schema.json` readable |
| 2 | Confirm schema meta | `$schema`, `$id`, `title`, `type: object` present |
| 3 | Confirm required top-level fields list | Matches CAT-03 in `000087` |
| 4 | Validate example JSON against schema | All required fields present; types match; no extra top-level properties |
| 5 | Validate nested objects | `source_scope`, module items, evidence items, restriction items conform |
| 6 | Record alignment result | Pass or typed failure code documented |

Schema validation may be performed manually by field checklist or by an approved static validator in a later batch. Batch 9B authorizes neither.

## HR-001 Through HR-009 Case Execution Plan

| Case ID | Execution Step Summary | Validation Procedure | Expected Pass Evidence |
| --- | --- | --- | --- |
| HR-001 | Parse example JSON | VAL-SYNTAX-01 | Parser success note |
| HR-002 | Check `registry_version` | Required field + non-empty string check | Field present and non-empty |
| HR-003 | Check `generated_at` | Required field + placeholder-safe check | Field present and placeholder-safe |
| HR-004 | Check `source_scope` | Nested required arrays check | `included_paths` and `excluded_paths` explicit |
| HR-005 | Check `modules` | Array item required fields + placeholder check | Module entries placeholder-safe |
| HR-006 | Check `evidence` | Evidence object rules from `000087` | Paths reference docs evidence only |
| HR-007 | Check `restrictions` | Restriction object rules from `000087` | Forbidden paths explicit |
| HR-008 | Forbidden secret scan | Forbidden content scan procedure | No secret/credential/token patterns |
| HR-009 | Forbidden runtime scan | Forbidden content scan procedure | No endpoint/SQL/provider/runtime patterns |

Detailed field mapping is in `docs/000089_Matrix_WP_9A_001_HR_001_To_HR_009_Validation_Case_Coverage_Map.md`.

## Non-Executable Test Boundary

Batch 9B and WP-9A-001 artifact pack explicitly forbid:

| Forbidden Test Behavior | Reason |
| --- | --- |
| Executable unit/integration tests | No runtime stack approved |
| CI test runner configuration | No package/config files approved |
| Python/Node/shell validation scripts | Executable validation deferred |
| Database-backed validation | No Supabase/SQL approved |
| Provider API calls | No provider integration approved |
| Auto-generated validation output under `docs-generated/` | Generated output lane not approved |
| Mutation of example JSON to simulate failures | Skeleton modification forbidden in Batch 9B |

Negative test cases (invalid JSON fixtures) may be designed in documentation but must not be created as files until a later approved batch.

## Evidence Capture Expectations

When validation execution is authorized in a future batch, evidence must capture:

| Evidence Item | Required Content |
| --- | --- |
| Validation batch ID | Batch identifier and date |
| Input files reviewed | Schema and example paths with commit hash |
| HR case results | Pass/fail per HR-001 through HR-009 |
| Failure codes | Any FAIL-* codes from `000087` |
| Gate result | PASS-GATE or FAIL-GATE |
| Reviewer | Human reviewer identity or role |
| Mutation confirmation | Confirmation skeleton files unchanged unless approved |

Batch 9B captures design evidence only through the artifact pack itself. No execution evidence is produced.

## Blockers Before Executable Validation

Executable validation remains blocked until all of the following are satisfied:

| Blocker | Status After Batch 9B |
| --- | --- |
| WP-9A-001 artifact pack complete | Pending closeout confirmation |
| Human approval for validation execution | Not granted |
| Allowed execution method defined (manual-only vs approved static tool) | Not defined |
| Allowed file mutation boundary for negative fixtures | Not approved |
| Rollback plan for any validation script creation | Not approved |
| Staging and commit authorization for execution artifacts | Not granted |
| Runtime implementation authorization | Not granted |
| Package/config file creation authorization | Not granted |

## Implementation Status

Implementation and executable validation are not authorized by WP-9A-001 or Batch 9B.
