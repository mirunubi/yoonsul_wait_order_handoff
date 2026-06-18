# 000085_Report_Batch_9A_Next_WorkPackage_Candidate_Selection.md

## 1. Purpose

Select the next candidate WorkPackage for controlled development entry after WP-8A-001 planning and neutral skeleton closeout.

Batch 9A is selection and planning only. It does not authorize runtime implementation, skeleton modification, executable test creation, or any file mutation outside this new report.

## 2. Current Repository State

| Check | Result |
| --- | --- |
| Latest commit | `9182288` — `docs: close out WP-8A-001 verification and temp tree disposition` |
| Prior WP commit | `11d768d` — WP-8A-001 planning docs and neutral skeleton |
| `git status --short` | Clean |
| Tracked docs Markdown (on disk) | 2354 |
| Tracked docs Markdown at WP-8A-001 closeout | 2335+ |
| Batch 7 documentation expansion | Complete |
| WP-8A-001 phase | Closed — Planning And Neutral Skeleton Phase |
| Runtime implementation | **Not approved** |
| Tracked SQL / Dart / TS / JS runtime source | None |
| Committed neutral skeleton paths | `packages/hydration_registry/`, `packages/source_module_map/`, `tests/hydration_registry/`, `tests/source_module_map/` |

## 3. Prior WorkPackage Closeout Context

WP-8A-001 delivered:

| Deliverable | Status |
| --- | --- |
| Planning docs `000066`–`000082` | Committed |
| Neutral JSON schema and example skeletons | Committed |
| Markdown validation case documents | Committed |
| Read-only repository hydration evidence | Captured in Batch 8C |
| First implementation gate | Skeleton creation authorized and executed in Batch 8G–8I only |
| Runtime implementation authorization | **Not granted** |

Batch 8E explicitly deferred `packages/evidence_registry/` until after hydration registry work. Batch 8E forbids first-skeleton work under `apps/`, `supabase/`, `data/`, and payment-adjacent runtime paths.

Batch 8K disposition (`000084`) closed the `directory_only_tree.txt` hygiene track. No remaining untracked root hygiene blockers affect WorkPackage selection.

## 4. Candidate Selection Criteria

Candidates were reviewed against the following criteria, consistent with Batch 8A (`000066`):

| Criterion | Weight |
| --- | --- |
| Low blast radius | Required |
| High dependency clarity | Required |
| Alignment with committed skeleton boundaries | Required |
| High static testability without runtime stack | High |
| Minimal external provider dependency | High |
| Strong documentation coverage | High |
| Clear rollback boundary | High |
| Direct leverage from WP-8A-001 outputs | High |
| No direct payment mutation risk | Required |
| No production runtime risk | Required |

## 5. Candidate WorkPackage List

| Candidate ID | Candidate WorkPackage | Representative Documentation / Artifact Coverage |
| --- | --- | --- |
| N01 | Hydration registry schema validation | `packages/hydration_registry/hydration_registry.schema.json`, `packages/hydration_registry/hydration_registry.example.json`, `tests/hydration_registry/hydration_registry_validation_cases.md`, `docs/000067_Overview_WP_8A_001_*`, `docs/000075_Report_WP_8A_001_Read_Only_Repository_Hydration_Evidence_Capture.md` |
| N02 | Source module map static validation | `packages/source_module_map/source_module_map.schema.json`, `packages/source_module_map/source_module_map.example.json`, `tests/source_module_map/source_module_map_validation_cases.md`, `docs/000068_Matrix_WP_8A_001_Dependency_Graph_And_Source_To_Module_Map.md` |
| N03 | Evidence registry skeleton | `docs/000066` C07, `docs/023000_implementation_planning/023177_Checklist_Evidence_Packet_Readiness_Check.md`, `docs/600000_implementation_lifecycle/605000_pos_gateway_package/605600_ticket_closeout/002300_Template_POS_Gateway_Runtime_Flow_Bundle_Change_Evidence_Packet_Template.md`, Batch 8E deferral note for `packages/evidence_registry/` |
| N04 | Admin read-only registry projection | `docs/000066` C05, `docs/016000_admin_console_saas_operations_control/016000_Index_Admin_Console_And_SaaS_Operations_Control_Expansion_Wave_1.md`, `docs/016000_admin_console_saas_operations_control/016172_Overview_Implementation_Handoff_Admin_View.md` |
| N05 | POS Gateway read-only status projection | `docs/000066` C02, `docs/600000_implementation_lifecycle/605000_pos_gateway_package/605100_core_flows/000910_Spec_Overview_POS_Gateway_Approval_Main_Flow.md`, `docs/600000_implementation_lifecycle/605000_pos_gateway_package/605100_core_flows/000930_Spec_Module_POS_Gateway_Approval_API_Data_Model_And_Test_Map.md` |

## 6. Candidate Scoring Matrix

Score scale: 1 is weak/high risk, 5 is strong/low risk.

| Candidate ID | Implementation Risk | Documentation Readiness | Dependency Clarity | Static Testability | Rollback Simplicity | WP-8A-001 Leverage | Skeleton Boundary Fit | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| N01 | 5 | 5 | 5 | 5 | 5 | 5 | 5 | **35** |
| N02 | 5 | 5 | 5 | 5 | 5 | 5 | 5 | **35** |
| N03 | 4 | 5 | 4 | 4 | 5 | 4 | 4 | 30 |
| N04 | 3 | 5 | 3 | 3 | 4 | 3 | 2 | 23 |
| N05 | 2 | 5 | 4 | 4 | 3 | 3 | 2 | 23 |

Tie-break between N01 and N02 applied below.

## 7. Recommended Next WorkPackage

**Selected candidate:** N01 — Hydration registry schema validation

**Proposed WorkPackage ID and name:**

`WP-9A-001 Hydration Registry Schema Validation And Static Evidence Gate`

### Reason For Selection

Hydration registry schema validation is the best next WorkPackage because it is the direct continuation of the committed WP-8A-001 skeleton lane with the lowest incremental risk.

Specific reasons:

1. **Committed skeleton already exists.** Schema, example JSON, README, and nine markdown validation cases (`HR-001`–`HR-009`) are in place and committed.
2. **Within approved boundary.** Batch 8E and Batch 8F authorized only `packages/hydration_registry/` and `tests/hydration_registry/` for the first skeleton wave. N01 extends that lane without opening new top-level runtime surfaces.
3. **Upstream dependency order.** Hydration registry is the evidence container that feeds source-to-module mapping, evidence packet governance, and later projection WorkPackages. Validating hydration shape first reduces rework for N02 and N03.
4. **No runtime stack required.** Validation can remain static (JSON parse, schema conformance, forbidden-field scan) without choosing Flutter, Node, Supabase, or package manager conventions.
5. **Direct leverage from WP-8A-001.** Batch 8C hydration evidence (`000075`, `000076`, `000077`) provides the inspection outputs that a validated registry would eventually reference.
6. **Clear rollback boundary.** Changes stay confined to hydration registry artifacts and validation notes. No app, backend, SQL, or provider behavior is implied.

### Tie-Break: N01 Over N02

N01 and N02 score equally on the matrix. N01 is selected first because:

- `000080` Batch 8E ordered hydration registry before evidence registry; the same ordering applies between hydration validation and source-module-map validation.
- Hydration registry `evidence` and `restrictions` fields are prerequisites for trustworthy source-module-map ownership and forbidden-path mapping.
- N02 remains the **immediate second candidate** (proposed `WP-9B-001`), not a deferred distant option.

## 8. Deferred Candidates And Reasons

| Candidate ID | Status | Reason |
| --- | --- | --- |
| N02 | **Next in queue** | Same risk profile as N01 but logically follows hydration registry validation. Proposed as `WP-9B-001 Source Module Map Static Validation`. |
| N03 | Deferred | Batch 8E explicitly deferred `packages/evidence_registry/` until hydration registry is stable. Strong documentation exists (C07) but canonical storage shape depends on validated hydration evidence. |
| N04 | Deferred | Admin read-only projection implies `apps/admin_console/` or equivalent UI surface. Batch 8E forbids app skeletons. No runtime stack is established. Requires validated registry projections first. |
| N05 | Deferred | POS Gateway status projection is payment/provider-adjacent. Batch 8A scored C02 lowest on implementation risk. Still valuable later, but should wait until hydration, source map, and evidence registry lanes are validated. |

## 9. Required Pre-Implementation Artifacts

Before any implementation work on `WP-9A-001`, the following artifacts must be produced in a planning batch (proposed Batch 9B):

| Artifact | Required Output |
| --- | --- |
| Overview | Purpose, scope, non-goals, and static validation boundary for hydration registry schema validation |
| Logic | Validation rules mapping `HR-001`–`HR-009` to concrete pass/fail criteria |
| Schema conformance plan | How example JSON is checked against `hydration_registry.schema.json` without runtime stack selection |
| Forbidden content scan plan | Rules for detecting secrets, credentials, runtime endpoints, SQL, and provider behavior in registry JSON |
| Allowed file boundary map | Exact paths and extensions permitted for Batch 9C+ implementation (if later approved) |
| Test plan | Static validation steps only; no executable test runner until separately authorized |
| Rollback plan | How to revert validation artifacts without affecting committed skeleton baseline |
| Gate checklist | Human approval checklist before any non-markdown file creation or modification |

## 10. Implementation Blocker Statement

Implementation remains blocked until human approval.

Batch 9A does not authorize:

- runtime code creation or modification;
- SQL, Flutter/Dart, TS/JS, or Supabase files;
- executable test runners or package manager files;
- skeleton modification in `packages/hydration_registry/` or sibling paths;
- `apps/`, `data/`, `supabase/`, or `docs-generated/` artifacts;
- staging or commit of implementation files;
- POS Gateway, admin console, or provider integration behavior.

The only output of Batch 9A is this selection report.

## 11. Recommended WorkPackage Queue

| Priority | Proposed ID | WorkPackage | Proposed Batch |
| --- | --- | --- | --- |
| 1 | WP-9A-001 | Hydration Registry Schema Validation And Static Evidence Gate | Batch 9B (artifact pack) → Batch 9C+ (implementation gate, if approved) |
| 2 | WP-9B-001 | Source Module Map Static Validation | After WP-9A-001 gate |
| 3 | WP-9C-001 | Evidence Registry Skeleton | After WP-9A-001 and WP-9B-001 validation lanes stable |
| 4 | WP-9D-001 | Admin Read-Only Registry Projection | After registry validation foundation; requires app boundary decision |
| 5 | WP-9E-001 | POS Gateway Read-Only Status Projection | After registry foundation and stack/boundary decisions |

## 12. Next Batch Recommendation

Recommended next batch:

`Batch 9B Hydration Registry Schema Validation WorkPackage Artifact Pack`

Batch 9B should create Overview, Logic, Test Plan, Allowed File Boundary Map, and Gate Checklist for `WP-9A-001`. It should remain documentation-only unless a later human approval explicitly permits static validation file creation.

Do not approve runtime implementation in Batch 9B without a separate implementation authorization packet.

## 13. Safety Statement

- Report-only batch; no staging, commit, delete, rename, or move
- No skeleton file modification
- No runtime implementation
- No SQL, Flutter/Dart, TS/JS, or Supabase files created
- No `apps/`, `data/`, or `docs-generated/` artifacts
- No root package/config files created
- No executable tests created
- No formatter run
- UTF-8 preserved
