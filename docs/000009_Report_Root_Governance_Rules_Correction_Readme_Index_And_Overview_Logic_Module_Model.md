# 000009_Report_Root_Governance_Rules_Correction_Readme_Index_And_Overview_Logic_Module_Model

Status: Implemented
Lifecycle: Module
Owner: TBD
Last Updated: 2026-06-18

## 0 Scope

This report records the root governance rule correction for Readme, Index, `00005`, `00007`, and the Overview / Logic / Module implementation lifecycle model.

This task changed governance rules only.

- No file move was executed.
- No file delete was executed.
- No file rename was executed.
- No runtime implementation was created.
- No SQL, migration, application code, Supabase function, or package change was created.
- No formatter was run.
- PowerShell `Set-Content` was not used.

## 1 Existing Problems

The prior governance rules did not clearly separate these responsibilities:

- Folder-level semantic authority
- Project-wide document number authority
- Project-wide directory map authority
- Local controlled registries
- Implementation lifecycle documents
- Formal specifications
- ADR, PR, evidence, and report relationships

This created room for accidental local index proliferation, ambiguous folder ownership, and confusion between `Spec` documents and implementation lifecycle documents.

## 2 Readme Index 00005 00007 Authority

The corrected governance model is:

- `Readme` is the folder-level semantic authority.
- `Readme` explains folder purpose, ownership boundary, what the folder owns, what it does not own, internal number band, subfolder policy, add rule, and move rule.
- `Index` is a document list, number list, controlled registry, or reference catalog.
- Subfolder `Index` documents are not created by default.
- `docs/00005_Document_Number_Index.md` is the project-wide document number and document list authority.
- `docs/00007_Full_Directory_Map.md` is the project-wide directory map authority.
- Subfolders should use `Readme` by default.
- Subfolder `Index` documents are allowed only when a bounded controlled registry is required.
- If `00005`, `00007`, and folder `Readme` documents conflict, broad file movement must stop until the governance documents are corrected together.

## 3 Overview Logic Module Definitions

`Overview`, `Logic`, and `Module` are now approved independent DocumentType values.

### 3.1 Overview

`Overview` is an implementation context and scope map.

It connects related Markdown, Flutter, SQL, RPC, API, test, evidence, and source files so reviewers can see what must be reviewed together before implementation or correction work.

It answers:

```text
What must be reviewed together before changing or fixing this implementation?
```

### 3.2 Logic

`Logic` is an implementation design and change logic document.

It defines affected tables, fields, states, events, exceptions, permissions, fallback behavior, audit behavior, reconciliation behavior, and other control logic.

It answers:

```text
What control logic will be changed?
```

### 3.3 Module

`Module` is an implemented module result and maintenance record.

It records source files, Flutter files, SQL, RPC, API, classes, functions, test results, evidence, known risk, and rollback notes.

It answers:

```text
What was actually implemented, where, and with what evidence?
```

## 4 Distinction From Spec

`Spec` remains reserved for formal contracts and specifications.

Use `Spec` for:

- API contracts
- Schema specifications
- Event payloads
- State contracts
- Protocols
- Interface details
- Formal interoperability requirements

Use `Overview`, `Logic`, and `Module` for the implementation lifecycle around those contracts.

`Overview`, `Logic`, and `Module` must not be treated as subtypes of `Spec`.

## 5 ADR PR Report Relationship

The corrected relationship is:

- `ADR` records why an architectural decision was made.
- `Overview`, `Logic`, and `Module` do not replace ADRs.
- Important implementation decisions should link to a related ADR when one exists.
- PR descriptions and code review records should be linked as evidence from `Module` documents when relevant.
- `Report` is reserved for audit, analysis, review, closeout, or completion findings.
- `Overview` is not a generic plan document. It is a formal implementation lifecycle context map.

## 6 Status Tag Rule

Development lifecycle documents should declare status near the top when practical.

Allowed status values:

- `Draft`
- `In_Progress`
- `Implemented`
- `Verified`
- `Archived`
- `Deprecated`

Recommended header format:

```text
Status: In_Progress
Lifecycle: Logic
Owner: TBD
Last Updated: YYYY-MM-DD
```

## 7 Future Rename Suggestions

No rename was executed in this task.

Future rename or move waves may consider:

- Adding or correcting folder `Readme` files before high-volume directory moves.
- Avoiding local `Index` documents unless a controlled registry is required.
- Renaming documents that incorrectly use `Spec` when their actual purpose is implementation context, change logic, or implemented module evidence.
- Keeping `Spec` for formal contracts and interfaces.
- Updating `docs/00005_Document_Number_Index.md` and `docs/00007_Full_Directory_Map.md` whenever any future create, move, or rename task is approved.

## 8 Next Move Task Checklist

Before the next move task:

1. Run `git status --short`.
2. Confirm the task has an explicit source range or folder.
3. Confirm excluded files and duplicate files are listed.
4. Confirm the destination folder already has a clear `Readme` boundary or create one in a separate approved governance task.
5. Use `git mv` only for file movement.
6. Do not edit Korean body text unless explicitly requested.
7. Do not use PowerShell `Set-Content`.
8. Do not run formatters.
9. Update `docs/00005_Document_Number_Index.md`.
10. Update `docs/00007_Full_Directory_Map.md`.
11. Run `git diff --check`.
12. Report remaining source-folder leftovers.

## 9 Files Changed By This Governance Correction

- `docs/00001_Md_Rules.md`
- `docs/00002_Naming_Rules.md`
- `docs/000009_Report_Root_Governance_Rules_Correction_Readme_Index_And_Overview_Logic_Module_Model.md`

## 10 Safety Result

- UTF-8 was preserved.
- No PowerShell `Set-Content` was used.
- No formatter was used.
- No file rename was executed.
- No file move was executed.
- No runtime implementation was created.
