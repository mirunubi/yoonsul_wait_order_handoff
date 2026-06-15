# 00130_Boundary_Non_Implementation

## Purpose

This document prevents the first MVP from expanding into the full operating system too early.

The first MVP must validate wait-order handoff only:

```text
waiting customer -> prepared order candidate -> seated table -> staff confirmation
```

## Explicit Non-Goals

### Full POS API Integration

No live POS order creation, POS menu sync, POS payment state, or POS webhook handling.

The MVP may show a staff-friendly summary for manual POS input.

### Payment Processing

No card payment, wallet payment, deposit, refund, settlement, tax settlement, receipt issuance, or payment gateway integration.

### Membership and Loyalty

No points, coupons, membership tiers, stamps, CRM segmentation, or customer account history.

### KDS Automation

No automatic kitchen display routing, station routing, ticket printing, or preparation workflow.

### Inventory Deduction

No stock count, ingredient depletion, out-of-stock automation, purchasing, or warehouse logic.

Menu item availability can be edited manually.

### Payroll and HR Linkage

No staff scheduling, payroll, attendance, labor costing, or HR workflows.

### Franchise OS Expansion

No headquarters console, franchise reporting, multi-store rollout operations, or brand-level policy management.

### Agent Server Automation

No autonomous agent workflows, background agent server, or task automation beyond ordinary application behavior.

### AI Recommendation Engine

No personalized recommendation, upsell model, ranking AI, or language model ordering assistant.

### Complex Multi-Tenant SaaS Architecture

No advanced tenant hierarchy, billing, organization administration, reseller model, or enterprise permission system.

Simple `store_id` scoping is enough for the first MVP.

## Allowed Simplifications

- Seed data instead of full admin management
- Manual staff login or local auth stub
- JSON-based multilingual fields
- Manual menu availability toggles
- Manual POS entry after confirmation
- Basic responsive web UI before native apps
