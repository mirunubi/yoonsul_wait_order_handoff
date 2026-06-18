# 000001_Md_Rules

## 0 Scope

This document applies only to `yoonsul_wait_order_handoff`.

## 1 Encoding Rule

- All Markdown documents must be UTF-8.
- Korean text must be preserved without encoding corruption.
- Special characters must not be rewritten through unsafe encodings.
- All documentation tasks must preserve UTF-8.
- All tasks must include the Korean/encoding safety block defined in `docs/000015_Korean_Document_And_Encoding_Safety_Rules.md`.
- Cursor must not edit Korean body text.
- Do not use PowerShell Set-Content.
- Do not normalize encoding.
- Do not run formatters.

See `docs/000015_Korean_Document_And_Encoding_Safety_Rules.md` for mandatory Korean documentation and encoding safety rules.

## 2 Heading Rule

- Use clear Markdown headings.
- Prefer numbered major sections for governance and design documents.
- A document should expose its purpose near the top.

## 3 Authority Rule

- One document should have one clear authority purpose.
- Avoid duplicate documents with overlapping ownership.
- Move or rename existing documents instead of recreating them when possible.

## 4 Implementation Boundary Rule

- Keep implementation details out of BM patent documents.
- BM patent documents must remain high-level.
- Implementation details belong in development design docs, not BM patent boundary docs.
- Documentation may describe architecture, boundaries, and intent.
- Documentation must not silently become SQL, migration, app, or API implementation.
- Documentation tasks must not create SQL, migrations, app code, Supabase functions, package changes, or runtime implementation.

## 5 Move And Index Rule

- All new documentation files must use six-digit prefixes according to `docs/000002_Naming_Rules.md`.
- Do not create new 4-digit-prefixed or 5-digit-prefixed docs.
- Existing 5-digit-prefixed docs are migration targets and must not be renamed except through an approved migration batch.
- Update `000005_Document_Number_Index.md` whenever documents move, are created, or are renamed.
- Update `000007_Full_Directory_Map.md` whenever folders move, are created, or are renamed.
- After moving or renaming docs, update `docs/000005_Document_Number_Index.md` and `docs/000007_Full_Directory_Map.md`.
- Internal titles should match the filename meaning after a move.

## 5.0 Six-Digit Canonical Numbering Rule

- The canonical documentation numeric prefix is six digits.
- The canonical Markdown filename format is `xxxxxx_DocumentType_Title_In_English_Title_Case.md`.
- `xxxxxx` is the mandatory six-digit numeric prefix.
- New governed Markdown documents must use six-digit prefixes.
- New five-digit-prefixed Markdown documents are not allowed.
- Existing five-digit-prefixed documents remain valid only as migration targets.
- The default migration mapping for existing five-digit numbers is `xxxxx` to `0xxxxx`.
- Actual migration must happen only in a separate approved rename batch with a dry-run manifest.

## 5.0.1 Unified Docs And SOP Numbering Rule

- `docs` and `sop` use the same six-digit numbering discipline.
- `docs` is for development documentation, architecture, specifications, boundaries, implementation lifecycle, validation, security, financial control, and audit documentation.
- `sop` is for operation SOP, system SOP, temporary QC SOP, field training SOP, and repeated operating procedure documentation.
- SOP documents must not be mixed into `docs` except for explicit cross-reference stubs when approved.
- Recipe SOP, operation SOP, and system SOP documents must be separated from development documentation.

## 5.1 Readme Index 000005 000007 Authority Rule

- A folder `Readme` is the folder-level semantic authority.
- A folder `Readme` explains what the folder is responsible for, what it owns, and what it does not own.
- A folder `Readme` should describe folder purpose, ownership boundary, internal number band, subfolder policy, add rule, and move rule.
- An `Index` document is a document list, number list, controlled registry, or reference catalog.
- Subfolder `Index` documents must not be created by default.
- Project-wide document numbers and document lists are centrally governed by `docs/000005_Document_Number_Index.md`.
- The complete directory structure is centrally governed by `docs/000007_Full_Directory_Map.md`.
- Subfolders should use `Readme` by default.
- Subfolder `Index` documents are allowed only when a bounded controlled registry is required.
- If `000005`, `000007`, and a folder `Readme` disagree, stop file movement and update the governance documents together.

## 5.2 Folder Readme Mandatory Rule

- Every governed top-level documentation folder should have a `Readme` document.
- The `Readme` document should use the folder number and domain name.
- The `Readme` document should define the local semantic boundary before new documents are added.
- A folder without a `Readme` should not receive high-volume move batches until its ownership boundary is clear.

## 5.3 Index Concentration Rule

- Do not create local index files just to list files in a folder.
- Use `000005_Document_Number_Index.md` for the project-wide document number registry.
- Use `000007_Full_Directory_Map.md` for the project-wide directory map.
- Create local `Index` documents only for controlled registries, evidence catalogs, reference catalogs, exception logs, or traceability maps that need independent review.

## 5.4 Overview Logic Module Lifecycle Rule

- `Overview`, `Logic`, and `Module` are approved implementation lifecycle DocumentType values.
- `Overview` defines implementation context and scope mapping. It shows which Markdown, Flutter, SQL, RPC, API, test, evidence, and source files must be reviewed together.
- `Logic` defines implementation design and change logic. It records affected tables, fields, states, events, exceptions, permissions, fallback behavior, audit behavior, and reconciliation behavior.
- `Module` records the implemented result and maintenance state. It identifies source files, Flutter files, SQL, RPC, API, classes, functions, tests, evidence, known risks, and rollback notes.
- `Overview`, `Logic`, and `Module` are implementation lifecycle documents. They do not replace `Spec`.
- `Spec` remains reserved for formal contracts, interfaces, schemas, protocols, event payloads, state contracts, and other specification details.
- A small work package may include Overview, Logic, and Module sections inside one document.
- Core flow, financial, payment, POS, KDS, audit, and security documents should prefer separate Overview, Logic, and Module files when traceability matters.

## 5.5 Status Tag Rule

- Development lifecycle documents should declare status near the top when practical.
- Allowed status values are `Draft`, `In_Progress`, `Implemented`, `Verified`, `Archived`, and `Deprecated`.
- Lifecycle documents should identify the lifecycle class when practical: `Overview`, `Logic`, or `Module`.
- Owner may be `TBD` when ownership is not yet assigned.

Example:

```text
Status: In_Progress
Lifecycle: Logic
Owner: TBD
Last Updated: YYYY-MM-DD
```

## 5.6 ADR PR Evidence Relationship Rule

- `ADR` documents record why an architectural decision was made.
- `Overview`, `Logic`, and `Module` documents do not replace ADRs.
- Important decisions should link to a related ADR when one exists.
- Pull request descriptions and code review records should be linked as evidence from `Module` documents when relevant.
- `Report` documents should be used for audit, analysis, review, closeout, or completion findings.
- Do not use `Overview` as a generic plan document. Use it only as a formal implementation lifecycle context map.

## 5.7 Conflict Resolution Rule

- If folder `Readme`, local `Index`, `000005`, and `000007` disagree, treat `00005` and `00007` as the central governance sources until a correction task resolves the conflict.
- Do not continue broad file movement while a document-number or directory-map conflict is unresolved.
- Correction tasks should update the smallest necessary governance files and report the decision.

## 5.8 Six-Digit Migration Safety Rule

Before any five-digit to six-digit migration:

1. Generate a dry-run rename manifest.
2. Detect duplicate target paths.
3. Detect case-only conflicts.
4. Detect path length risks.
5. Detect existing six-digit files.
6. Detect bad four-digit and five-digit files.
7. Detect Korean filename risks.
8. Detect internal link references to old paths.
9. Prepare an update plan for `docs/000005_Document_Number_Index.md`.
10. Prepare an update plan for `docs/000007_Full_Directory_Map.md`.
11. Prepare an update plan for folder `Readme` files.
12. Do not stage or commit unless explicitly instructed.

Migration batches must not modify runtime implementation, SQL, migrations, app code, Supabase functions, or package files.

## 6 Quality Rule

- Do not create placeholder nonsense documents.
- Each document should clearly state its scope and current status when appropriate.
- Keep documents readable by both humans and machine-assisted tools.

## 7 External Project Rule

- `yoonsul_os` may be referenced only as external context.
- Do not merge `yoonsul_wait_order_handoff` implementation into `yoonsul_os`.
- Do not index `yoonsul_os` files as internal project documents.

## 8 Current Status

Status: active root governance rule.
