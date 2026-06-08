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

- [Project Overview](docs/0000_Project_Overview.md)
- [MVP Scope](docs/0010_MVP_Scope.md)
- [User Flow](docs/0020_User_Flow.md)
- [Data Model Draft](docs/0030_Data_Model_Draft.md)
- [Non-Implementation Boundary](docs/0040_Non_Implementation_Boundary.md)
- [BM Patent Linkage](docs/0050_BM_Patent_Linkage.md)

## Proposed Directory Structure

```text
yoonsul_wait_order_handoff/
  README.md
  docs/
    0000_Project_Overview.md
    0010_MVP_Scope.md
    0020_User_Flow.md
    0030_Data_Model_Draft.md
    0040_Non_Implementation_Boundary.md
    0050_BM_Patent_Linkage.md
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

