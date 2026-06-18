# 000002_Naming_Rules

## 0 Scope

This document applies only to `yoonsul_wait_order_handoff`.

## 1 File Number Prefix Rule

- This project uses six-digit document numbering as the canonical documentation numbering model.
- The six-digit model supports development documentation, SOP namespaces, implementation lifecycle documents, runtime-flow bundles, audit evidence, agent automation, patent packets, reclassification, and legacy quarantine without crowding narrow bands.
- Markdown governance and design files use a six-digit numeric prefix.
- The prefix should reflect the document band and read order.
- Do not reuse a file number for a different purpose inside the same folder.
- File names must start with a numeric prefix inside `docs/`.
- New docs must use six-digit prefixes.
- New docs must not use 5-digit prefixes.
- New docs must not use 4-digit prefixes.
- Existing 5-digit-prefixed files are migration targets and must not be renamed except through an approved migration batch.

## 1.1 Markdown Filename Canonical Format

The canonical Markdown filename format is:

```text
xxxxxx_DocumentType_Title_In_English_Title_Case.md
```

Where:

- `xxxxxx` is the mandatory six-digit numeric prefix.
- `DocumentType` is an approved DocumentType Prefix.
- `Title_In_English_Title_Case` is the English document title with words separated by underscores.
- `.md` is the lowercase Markdown extension.

DocumentType must appear immediately after the numeric prefix.

Correct:

```text
0006511_Policy_Entrance_Waiting_Assist_Device_Customer_Link_Web_App_Native_App_And_Order_Runtime_Boundary.md
100300_SOP_Entrance_Waiting_Assist_Device_Operation.md
005420_Checklist_First_Store_POS_Equipment_Decision_And_Provider_Procurement.md
```

Wrong:

```text
006511_Policy_Entrance_Waiting_Assist_Device_Customer_Link_Web_App_Native_App_And_Order_Runtime_Boundary.md
005420_Policy_First_Store_POS_Equipment_Decision_And_Provider_Procurement_Checklist.md
06510 Entrance Waiting Assist Device Policy.md
06510-Policy-Entrance-Waiting-Assist-Device.md
06510_Korean_Title_Policy.md
```

## 1.2 Approved DocumentType Prefix Values

Approved DocumentType Prefix values:

- `Policy`
- `SOP`
- `Checklist`
- `Readme`
- `Index`
- `Runbook`
- `Evidence`
- `Audit`
- `Governance`
- `Boundary`
- `Matrix`
- `Template`
- `Register`
- `Report`
- `Assessment`
- `WorkPackage`
- `Implementation`
- `Guide`
- `Spec`
- `Overview`
- `Logic`
- `Module`
- `ADR`

Definitions:

| DocumentType | Definition |
| --- | --- |
| `Policy` | Business rule, operational rule, compliance rule, architecture rule, or decision boundary. |
| `SOP` | Step-by-step operating procedure for staff, owner, operator, or system operator execution. |
| `Checklist` | Verification list, readiness list, procurement list, setup list, or review checklist. |
| `Readme` | Folder-level overview, purpose, scope, numbering map, and local authority note. |
| `Index` | Numbered list or controlled catalog of documents, files, sections, or references. |
| `Runbook` | Incident, recovery, failover, operation, or troubleshooting execution playbook. |
| `Evidence` | Proof packet, test evidence, validation evidence, audit evidence, or recorded result artifact. |
| `Audit` | Audit rule, audit trail definition, audit event policy, or inspection scenario. |
| `Governance` | Ownership, authority, approval, lifecycle, responsibility, or control model. |
| `Boundary` | Scope boundary, runtime boundary, integration boundary, channel boundary, or responsibility boundary. |
| `Matrix` | Mapping table, responsibility matrix, priority matrix, compatibility matrix, or decision matrix. |
| `Template` | Reusable document structure, evidence form, report form, or standard packet format. |
| `Register` | Controlled list of risks, blockers, exceptions, waivers, decisions, incidents, or records. |
| `Report` | Investigation report, assessment result, field report, analysis report, or final finding. |
| `Assessment` | Evaluation, comparison, readiness assessment, provider assessment, or feasibility assessment. |
| `WorkPackage` | Implementation work unit, delivery package, milestone package, or grouped execution scope. |
| `Implementation` | Technical design, API behavior, runtime model, data model, interface design, or build-level detail. |
| `Guide` | Instructional guide, usage guide, setup guide, migration guide, or operator guide. |
| `Spec` | Formal specification, protocol specification, interface specification, schema specification, or contract detail. |
| `Overview` | Implementation context map that connects related Markdown, Flutter, SQL, RPC, API, test, evidence, and source files before implementation or correction work. |
| `Logic` | Implementation design and change logic that defines affected tables, fields, states, events, exceptions, permissions, fallback paths, audit behavior, and reconciliation behavior. |
| `Module` | Implemented module result and maintenance record covering source files, Flutter files, SQL, RPC, API, classes, functions, test result, evidence, known risk, and rollback notes. |
| `ADR` | Architecture Decision Record. |

### 1.2.1 Spec And Implementation Lifecycle Distinction

- `Spec` is reserved for formal contracts and specifications such as API contracts, schemas, event payloads, state contracts, protocols, interface details, or interoperability requirements.
- `Overview` is an implementation context map. It answers: what must be reviewed together before changing or fixing the implementation?
- `Logic` is implementation change logic. It answers: what control logic, data logic, exception logic, permission logic, fallback logic, audit logic, or reconciliation logic will be changed?
- `Module` is an implemented result record. It answers: what was actually implemented, where, with what evidence, tests, risks, and rollback notes?
- `Overview`, `Logic`, and `Module` are independent approved DocumentType values. They must not be treated as subtypes of `Spec`.
- A small implementation or work package may include Overview, Logic, and Module sections inside one governed document when separate files would add unnecessary overhead.
- Core flow, financial, payment, POS, KDS, audit, and security documents should prefer separate Overview, Logic, and Module files when traceability and review evidence matter.

## 1.3 Markdown Filename Format Rules

- File names must use English only.
- File names must use underscores only as word separators.
- File names must not contain spaces.
- File names must not contain Korean characters.
- File names must not contain parentheses.
- File names must not contain commas.
- File names must not contain colons.
- File names must not contain shell-sensitive special characters.
- File names must use `.md` lowercase extension.
- The six-digit numeric prefix is mandatory for new governed Markdown files.
- Existing five-digit numeric prefixes are migration targets.
- DocumentType must appear immediately after the numeric prefix.
- DocumentType must be one of the approved values.
- DocumentType must not appear again at the end unless it is naturally part of the title, which should be avoided.
- Do not use `Work_Package`; use `WorkPackage`.
- Do not use lowercase document type prefixes such as `policy`, `sop`, or `checklist`.
- Do not use kebab-case for governed Markdown filenames.
- Do not rename existing files without index and README synchronization.
- Do not perform bulk rename without a dry-run manifest and duplicate-prefix check.

## 1.4 Linux And Cross-Platform Filename Safety

The naming rule is designed for future Linux-based operation and cross-platform Git safety.

Avoid:

- spaces.
- Korean file names.
- special characters.
- case-only filename differences.
- path names that differ only by uppercase/lowercase.
- very long paths where avoidable.
- punctuation-heavy filenames.
- shell-sensitive characters.

Underscores are allowed and remain the project standard.

Kebab-case is not adopted for this project because the repository uses numeric-prefix underscore-based document governance.

## 1.5 Migration Policy

Existing files do not need to be renamed immediately.

Existing five-digit files are migration targets. The default migration rule is:

```text
xxxxx -> 0xxxxx
```

Examples:

```text
000001_Md_Rules.md -> 000001_Md_Rules.md
000002_Naming_Rules.md -> 000002_Naming_Rules.md
12090_pos_gateway_runtime_flow_implementation_package/ -> 012090_pos_gateway_runtime_flow_implementation_package/
```

Future migration must be performed by controlled waves. Each migration wave must:

1. Select a bounded folder or prefix range.
2. Generate a dry-run manifest.
3. Detect duplicate target paths.
4. Detect case-only conflicts.
5. Detect path length risks.
6. Detect existing six-digit files.
7. Detect bad four-digit and five-digit files.
8. Detect Korean filename risks.
9. Detect internal link references to old paths.
10. Prepare an update plan for `docs/000005_Document_Number_Index.md`.
11. Prepare an update plan for `docs/000007_Full_Directory_Map.md`.
12. Prepare an update plan for folder README files.
13. Rename files only with an approved migration batch.
14. Update the document heading only if explicitly approved and required by the batch.
15. Validate UTF-8.
16. Validate Korean readability.
17. Report remaining bad filenames.
18. Do not stage or commit unless explicitly instructed.

This naming-rule update does not rename existing files. Large filename migration must happen in a separate task with an explicit manifest and validation report.

## 2 Folder Number Prefix Rule

- Documentation domain folders under `docs/` use a numeric prefix.
- Folder names should be lower snake case after the numeric prefix.
- Folder names must start with a numeric prefix inside `docs/`.
- New governed folders should use six-digit prefixes.
- Existing five-digit-prefixed folders are migration targets.
- Current folders remain flat unless a domain grows large enough to require subfolders.

## 3 Root Governance Reservation

Root governance numbers are reserved for `000000~000099`.

Root governance files:

- `000000_Project_Overview.md`
- `000001_Md_Rules.md`
- `000002_Naming_Rules.md`
- `000003_Project_Context.md`
- `000005_Document_Number_Index.md`
- `000007_Full_Directory_Map.md`
- `000015_Korean_Document_And_Encoding_Safety_Rules.md`
- `000099_Docs_Governance_Checklist.md`

Existing five-digit root governance files are migration targets and must not be renamed in this governance-rule update.

## 4 Six-Digit Namespace Reservation

The six-digit namespace reservation is:

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

Legacy five-digit landing folders are migration targets:

- `docs/15000_membership_loyalty/` — membership / loyalty / coupon / point band reserved.
- `docs/17000_ui_screen_composition/` — UI screen composition / wording / wireframe / design band reserved.
- `docs/22000_implementation_planning/` — implementation planning / build sequence / QA band reserved.
- `docs/24000_deployment_operations/` — deployment / operations / support planning band reserved.
- `docs/26000_analytics_reporting_bi/` — analytics / report / BI band reserved.
- `docs/28000_future_expansion/` — active future expansion reference folder.
- `docs/30000_future_saas_modules/` — future SaaS modules / long-term reserved band.

New docs must use the six-digit namespace reservation.

## 4.1 Docs And SOP Separation Principle

- `docs` is for development documentation only.
- `docs` owns development documents, architecture, specifications, boundaries, implementation lifecycle, validation, security, financial control, and audit documents.
- `sop` owns operation SOP, system SOP, temporary QC SOP, field training SOP, and repeated operating procedure documents.
- SOP documents must not be mixed into `docs` except for cross-reference stubs when explicitly required.
- Recipe SOP, operation SOP, and system SOP must be separated from development docs.
- `docs` and `sop` use the same six-digit naming discipline even when their paths are different.

## 5 Readme Naming Rule

Readme documents use the folder number and domain name.

Examples:

- `000100_Readme_Project_Foundation.md`
- `0001000_Readme_MVP_Scope.md`
- `0005000_Readme_Customer_Handoff_Flow.md`
- `0003000_Readme_SaaS_Runtime.md`

## 5.1 Filename Casing Note

- Filename casing may use readable Title Case for acronyms such as Ui, Api, Pos, Scm unless a domain later standardizes otherwise.
- Filename casing must remain consistent with actual paths in `00005` and `00007`.
- Case-only renames should be handled manually and carefully because Git/Windows may not detect them reliably.

## 6 Internal Title Rule

Internal document title should match the filename meaning after a move.

Do not use `yoonsul_os` document numbers as canonical numbers in this project.

## 7 Project Terminology

Preferred terms:

- waiting handoff
- order handoff
- Mini Kiosk
- SaaS tenant
- store runtime
- customer session
- waiting session
- handoff session
- integration boundary

## 8 Current Status

Status: active root governance rule.
