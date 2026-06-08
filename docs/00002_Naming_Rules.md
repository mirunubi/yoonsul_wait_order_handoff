# 00002 Naming Rules

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

- `00100_Project_Foundation_Readme.md`
- `01000_MVP_Scope_Readme.md`
- `05000_Customer_Handoff_Flow_Readme.md`
- `03000_SaaS_Runtime_Readme.md`

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
