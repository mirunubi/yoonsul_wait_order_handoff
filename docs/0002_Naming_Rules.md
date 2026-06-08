# 0002 Naming Rules

## 0 Scope

This document applies only to `yoonsul_wait_order_handoff`.

## 1 File Number Prefix Rule

- Markdown governance and design files use a numeric prefix.
- The prefix should reflect the document band and read order.
- Do not reuse a file number for a different purpose inside the same folder.
- File names must start with a numeric prefix inside `docs/`.

## 2 Folder Number Prefix Rule

- Documentation domain folders under `docs/` use a numeric prefix.
- Folder names should be lower snake case after the numeric prefix.
- Folder names must start with a numeric prefix inside `docs/`.

## 3 Root Governance Reservation

Root governance numbers are reserved for `0000~0099`.

Root governance files:

- `0000_Project_Overview.md`
- `0001_Md_Rules.md`
- `0002_Naming_Rules.md`
- `0003_Project_Context.md`
- `0005_Document_Number_Index.md`
- `0007_Full_Directory_Map.md`
- `0099_Docs_Governance_Checklist.md`

## 4 Docs Domain Bands

- `0100~0999`: project foundation / BM / patent boundary
- `1000~1999`: MVP scope / service scenario
- `2000~2999`: SaaS runtime / tenant / account / store runtime
- `3000~3999`: customer handoff flow / waiting / preorder / Mini Kiosk
- `4000~4999`: admin console / operator console
- `5000~5999`: data model / conceptual schema / state machine
- `6000~6999`: integration boundary / POS / KDS / payment / printer
- `7000~7999`: app and API projection / implementation planning
- `8000~8999`: validation / security / audit / compliance
- `9000~9999`: future expansion / franchise_os / Agent / AI linkage

## 5 Readme Naming Rule

Readme documents use the folder number and domain name.

Examples:

- `0100_Project_Foundation_Readme.md`
- `1000_MVP_Scope_Readme.md`
- `3000_Customer_Handoff_Flow_Readme.md`

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
