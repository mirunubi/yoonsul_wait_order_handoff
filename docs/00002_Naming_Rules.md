# 00002 Naming Rules

## 0 Scope

This document applies only to `yoonsul_wait_order_handoff`.

## 1 File Number Prefix Rule

- This project uses five-digit document numbering because it is SaaS-oriented and may outgrow the former `0000~9999` numbering space.
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

- `00000~00099`: docs governance spine
- `00100~00999`: project foundation / BM / patent boundary
- `01000~01999`: MVP scope / market / package strategy
- `02000~02999`: SaaS runtime / tenant / store runtime
- `03000~03999`: customer handoff flow
- `04000~04999`: admin console
- `05000~05999`: data model / state machine
- `06000~06999`: integration boundary
- `07000~07999`: app/API projection
- `08000~08999`: validation / security / audit
- `09000~09999`: future expansion
- `10000~10999`: UI screen composition
- `11000~11999`: wireframe / prototype / design system
- `12000~12999`: implementation planning boundary
- `13000~13999`: testing / smoke / QA planning
- `14000~14999`: deployment / operations planning
- `15000~19999`: reserved product expansion
- `20000~99999`: future SaaS modules / reserved

`10000~10999` is reserved for UI/screen composition, but the folder must not be created until a dedicated documentation wave approves it.

## 5 Readme Naming Rule

Readme documents use the folder number and domain name.

Examples:

- `00100_Project_Foundation_Readme.md`
- `01000_MVP_Scope_Readme.md`
- `03000_Customer_Handoff_Flow_Readme.md`

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

