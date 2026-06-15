# 00002_Naming_Rules

## 0 Scope

This document applies only to `yoonsul_wait_order_handoff`.

## 1 File Number Prefix Rule

- This project uses five-digit document numbering because it is SaaS-oriented and may outgrow the former `0000~9999` numbering space.
- The project uses approximately **2,000-slot domain bands** so major SaaS domains have wider spacing and future documents are less likely to crowd a narrow band.
- Markdown governance and design files use a five-digit numeric prefix.
- The prefix should reflect the document band and read order.
- Do not reuse a file number for a different purpose inside the same folder.
- File names must start with a numeric prefix inside `docs/`.
- New docs must not use 4-digit prefixes.

## 1.1 Markdown Filename Canonical Format

The canonical Markdown filename format is:

```text
xxxxx_DocumentType_Title_In_English_Title_Case.md
```

Where:

- `xxxxx` is the mandatory five-digit numeric prefix.
- `DocumentType` is an approved DocumentType Prefix.
- `Title_In_English_Title_Case` is the English document title with words separated by underscores.
- `.md` is the lowercase Markdown extension.

DocumentType must appear immediately after the numeric prefix.

Correct:

```text
06511_Policy_Entrance_Waiting_Assist_Device_Customer_Link_Web_App_Native_App_And_Order_Runtime_Boundary.md
00300_SOP_Entrance_Waiting_Assist_Device_Operation.md
05420_Checklist_First_Store_POS_Equipment_Decision_And_Provider_Procurement.md
```

Wrong:

```text
06511_Policy_Entrance_Waiting_Assist_Device_Customer_Link_Web_App_Native_App_And_Order_Runtime_Boundary.md
05420_Policy_First_Store_POS_Equipment_Decision_And_Provider_Procurement_Checklist.md
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
| `ADR` | Architecture Decision Record. |

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
- The five-digit numeric prefix remains mandatory.
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

Kebab-case is not adopted for this project because the current repository already uses five-digit underscore-based document governance.

## 1.5 Migration Policy

Existing files do not need to be renamed immediately.

Future migration must be performed by controlled waves. Each migration wave must:

1. Select a bounded folder or prefix range.
2. Generate a dry-run manifest.
3. Detect duplicate numeric prefixes.
4. Detect case-only conflicts.
5. Rename files using safe file operations.
6. Update the document heading if it mirrors the filename.
7. Update `docs/00005_Document_Number_Index.md`.
8. Update `docs/00007_Full_Directory_Map.md` if present.
9. Update folder README/index files.
10. Validate UTF-8.
11. Validate Korean readability.
12. Report remaining bad filenames.
13. Do not stage or commit unless explicitly instructed.

This naming-rule update does not rename existing files. Large filename migration must happen in a separate task with an explicit manifest and validation report.

## 2 Folder Number Prefix Rule

- Documentation domain folders under `docs/` use a numeric prefix.
- Folder names should be lower snake case after the numeric prefix.
- Folder names must start with a numeric prefix inside `docs/`.
- Current folders remain flat unless a domain grows large enough to require subfolders.

## 3 Root Governance Reservation

Root governance numbers are reserved for `00000~00099`.

Root governance files:

- `00000_Project_Overview.md`
- `00001_Md_Rules.md`
- `00002_Naming_Rules.md`
- `00003_Project_Context.md`
- `00005_Document_Number_Index.md`
- `00007_Full_Directory_Map.md`
- `00015_Korean_Document_And_Encoding_Safety_Rules.md`
- `00099_Docs_Governance_Checklist.md`

## 4 Docs Domain Bands

The **2,000-slot band model** was adopted because this is a SaaS-oriented project and 999-slot domains were too narrow.

- `00000~00999`: governance / project foundation
- `01000~02999`: MVP scope / market / package strategy
- `03000~04999`: SaaS runtime / tenant / store runtime
- `05000~06999`: customer handoff flow
- `07000~08999`: admin console
- `09000~10999`: data model / state machine
- `11000~12999`: integration boundary
- `13000~14999`: app/API projection
- `15000~16999`: membership / loyalty / coupon / point
- `17000~19999`: UI screen composition / wording / wireframe / design
- `20000~21999`: validation / security / audit / privacy / export
- `22000~23999`: implementation planning / build sequence / QA
- `24000~25999`: deployment / operations / support planning
- `26000~27999`: analytics / report / BI
- `28000~29999`: future expansion / long-term reserved
- `30000~99999`: future SaaS modules / reserved

Reserved band landing folders:

- `docs/15000_membership_loyalty/` — membership / loyalty / coupon / point band reserved.
- `docs/17000_ui_screen_composition/` — UI screen composition / wording / wireframe / design band reserved.
- `docs/22000_implementation_planning/` — implementation planning / build sequence / QA band reserved.
- `docs/24000_deployment_operations/` — deployment / operations / support planning band reserved.
- `docs/26000_analytics_reporting_bi/` — analytics / report / BI band reserved.
- `docs/28000_future_expansion/` — active future expansion reference folder.
- `docs/30000_future_saas_modules/` — future SaaS modules / long-term reserved band.

New docs must use the final 2,000-slot band model.

## 5 Readme Naming Rule

Readme documents use the folder number and domain name.

Examples:

- `00100_Readme_Project_Foundation.md`
- `01000_Readme_MVP_Scope.md`
- `05000_Readme_Customer_Handoff_Flow.md`
- `03000_Readme_SaaS_Runtime.md`

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
