# Yoonsul Wait-Order Handoff MVP

Focused MVP/PoC for reducing the lead time between customer seating and order placement.

This repository is not the full `yoonsul_os` system. It is a narrow development project for the BM patent idea:

> waiting customer -> menu browsing -> cart -> order candidate/pre-order -> seating/table match -> store handoff

## Primary Goal

Allow customers to prepare an order while waiting so staff can confirm it immediately after seating.

## Secondary Goal

Because the MVP includes menu browsing, photos, options, and multilingual UI foundations, it can also operate as a lightweight Mini Kiosk for stores that do not need waiting management.

## First MVP Boundary

The first MVP stops at order candidate creation and staff confirmation. Existing POS input can remain manual.

Do not implement these in the first MVP:

- Full POS API integration
- Payment settlement
- Membership points or loyalty logic
- KDS automation
- Inventory deduction
- Payroll or HR linkage
- Franchise OS expansion
- Agent server automation
- AI recommendation engine
- Complex multi-tenant SaaS architecture

## MVP Flow

1. Customer enters store context via QR, NFC, or URL.
2. Customer creates or joins a waiting session.
3. Customer browses the store menu.
4. Customer adds menu items and options to cart.
5. Customer creates an order candidate.
6. Staff seats the customer and assigns a table number.
7. Staff reviews the order candidate.
8. Staff confirms it and manually enters it into the existing POS if needed.

## Document Index

- [Project Overview](docs/00000_Project_Overview.md)
- [Markdown Rules](docs/00001_Md_Rules.md)
- [Naming Rules](docs/00002_Naming_Rules.md)
- [Project Context](docs/00003_Project_Context.md)
- [Document Number Index](docs/00005_Document_Number_Index.md)
- [Full Directory Map](docs/00007_Full_Directory_Map.md)
- [Docs Governance Checklist](docs/00099_Docs_Governance_Checklist.md)
- [Project Identity And Overview](docs/00100_project_foundation/00110_Project_Identity_And_Overview.md)
- [MVP Scope](docs/01000_mvp_scope/01010_MVP_Scope.md)
- [User Flow](docs/05000_customer_handoff_flow/05010_User_Flow.md)
- [Data Model Draft](docs/09000_data_model_state_machine/09010_Data_Model_Draft.md)
- [Non-Implementation Boundary](docs/00100_project_foundation/00130_Non_Implementation_Boundary.md)
- [BM Patent Linkage](docs/00100_project_foundation/00120_BM_Patent_Linkage.md)

## Proposed Directory Structure

```text
yoonsul_wait_order_handoff/
  README.md
  docs/
    00000_Project_Overview.md
    00001_Md_Rules.md
    00002_Naming_Rules.md
    00003_Project_Context.md
    00005_Document_Number_Index.md
    00007_Full_Directory_Map.md
    00099_Docs_Governance_Checklist.md
    00100_project_foundation/
    01000_mvp_scope/
    03000_saas_runtime/
    05000_customer_handoff_flow/
    07000_admin_console/
    09000_data_model_state_machine/
    11000_integration_boundary/
    13000_app_api_projection/
    20000_validation_security_audit/
    28000_future_expansion/
  apps/
    customer-web/
    staff-web/
  packages/
    domain/
    ui/
  data/
    seed/
  tests/
```
