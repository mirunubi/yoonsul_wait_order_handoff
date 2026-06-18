# Report Six Digit Documentation Numbering Governance Update

Status: Implemented
Lifecycle: Module
Owner: TBD
Last Updated: 2026-06-18

## 0 Scope

This report records the governance rule update that changes the canonical documentation numeric prefix from five digits to six digits.

This task updated governance rules only.

- No file rename was executed.
- No folder rename was executed.
- No file move was executed.
- No delete was executed.
- No runtime implementation was created.
- No SQL, migration, application code, Supabase function, or package change was created.
- No formatter was run.
- PowerShell `Set-Content` was not used.

## 1 Why The Project Is Moving To Six Digits

The project has grown beyond a simple documentation tree. It now needs stable numbering space for:

- Development documentation
- SOP namespaces
- Implementation lifecycle documents
- Runtime flow bundles
- Dependency graphs
- Audit and evidence packets
- Agent and AI automation documentation
- Patent and BM claim packets
- Reclassification and duplicate review
- Legacy quarantine and delete candidate hold

Six digits provide enough separation between development docs, SOPs, evidence, implementation lifecycle, runtime flow bundles, automation, patent packets, and quarantine areas without crowding narrow bands.

## 2 Why Docs And SOP Use One Numbering Discipline

`docs` and `sop` are different content domains, but they should follow the same six-digit naming discipline.

The separation rule is:

- `docs` is for development documentation, architecture, specifications, boundaries, implementation lifecycle, validation, security, financial control, and audit documents.
- `sop` is for operation SOP, system SOP, temporary QC SOP, field training SOP, and repeated operating procedure documents.
- SOP documents should not be mixed into `docs` except for explicit cross-reference stubs when approved.

Using one six-digit discipline across both paths prevents future collision, reduces ambiguous numbering, and allows SOP packages to grow without consuming development documentation bands.

## 3 Five-Digit To Six-Digit Migration Policy

Existing five-digit files are migration targets.

The default migration rule is:

```text
xxxxx -> 0xxxxx
```

Examples:

```text
000001_Md_Rules.md -> 000001_Md_Rules.md
000002_Naming_Rules.md -> 000002_Naming_Rules.md
12090_pos_gateway_runtime_flow_implementation_package/ -> 012090_pos_gateway_runtime_flow_implementation_package/
```

Existing five-digit files remain in place until a separate approved migration batch is executed.

## 4 Six-Digit Namespace Reservation

The reserved namespace model is:

- `000000~099999`: docs development governance, domain design, architecture, security, runtime, validation.
- `100000~199999`: operation SOP.
- `200000~299999`: system SOP.
- `300000~399999`: recipe, menu, QC, and kitchen SOP.
- `400000~499999`: franchise, training, and field operation SOP.
- `500000~599999`: evidence, audit, legal hold, export, retention, and compliance packet.
- `600000~699999`: implementation lifecycle, code handoff, Overview, Logic, Module, WorkPackage, and implementation evidence.
- `700000~799999`: runtime flow bundle, dependency graph, execution trace, and runtime mapping.
- `800000~899999`: agent, AI automation, knowledge evolution, and NPU readiness.
- `900000~949999`: patent, BM claim, external submission, and attorney packet.
- `950000~989999`: reclassification, duplicate, conflict, and manual review.
- `990000~999999`: legacy, quarantine, import archive, and delete candidate hold.

## 5 Overview Logic Module Rationale

The six-digit model reserves `600000~699999` for implementation lifecycle and code handoff records.

`Overview`, `Logic`, and `Module` are approved lifecycle DocumentTypes because implementation work needs three distinct documentation layers:

- `Overview`: what must be reviewed together before implementation or modification.
- `Logic`: how the implementation or correction should work.
- `Module`: how the module is currently implemented and evidenced.

These types are not `Spec` subtypes. `Spec` remains reserved for formal contracts, schemas, protocols, event payloads, state contracts, and interface details.

## 6 Why Rename Was Not Performed In This Task

Actual file and folder rename was intentionally not performed because migration has high blast radius.

Before any rename batch, the project must produce a dry-run manifest that detects:

- Duplicate target paths
- Case-only conflicts
- Path length risks
- Existing six-digit files
- Bad four-digit and five-digit files
- Korean filename risks
- Internal link references to old paths
- Required `00005` updates
- Required `00007` updates
- Required folder `Readme` updates

This governance update only defines the future rule. It does not execute migration.

## 7 Next Dry-Run Manifest Task Summary

The next approved task should:

1. Run `git status --short`.
2. Scan all governed Markdown files and governed folders.
3. Produce a source path to target path dry-run manifest.
4. Apply the `xxxxx -> 0xxxxx` default mapping for existing five-digit paths.
5. Detect duplicate target paths.
6. Detect case-only conflicts.
7. Detect path length risks.
8. Detect existing six-digit paths.
9. Detect bad four-digit and five-digit paths.
10. Detect Korean filename risks.
11. Detect internal links that point to old paths.
12. Produce separate update plans for `00005`, `00007`, and folder `Readme` files.
13. Stop before any actual rename.

## 8 Files Changed By This Governance Update

- `docs/000001_Md_Rules.md`
- `docs/000002_Naming_Rules.md`
- `docs/000010_Report_Six_Digit_Documentation_Numbering_Governance_Update.md`

## 9 Safety Result

- UTF-8 was preserved.
- No PowerShell `Set-Content` was used.
- No formatter was used.
- No rename was executed.
- No delete was executed.
- No runtime implementation was created.
