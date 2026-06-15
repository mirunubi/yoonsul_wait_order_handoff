# 01020_Store_Type_And_Product_Package_Strategy

## 1 Overall Direction

`yoonsul_wait_order_handoff` is not one identical feature for every store.

The product has two adoption branches:

- BM 3-A: Waiting-to-order lead time reduction system.
- BM 3-B: Foreign visitor / non-face-to-face Mini Kiosk system.

BM 3-A naturally includes Mini Kiosk capabilities because waiting customers need menu browsing, photos, options, multilingual display, and order candidate creation while waiting.

BM 3-B can be used alone without waiting features. A store may turn off waiting while keeping menu, order candidate, multilingual, and staff confirmation functions.

## 2 BM 3-A: Waiting-To-Order Lead Time Reduction

### 2.1 Target Stores

- stores with waiting.
- stores with strong lunch or dinner peaks.
- stores where table turnover matters.
- stores where customers spend time choosing menus after seating.
- stores where waiting system and order system are separated.

### 2.2 Core Problem

- waiting and ordering are separated.
- actual order starts only after seating.

### 2.3 Target Flow

```text
QR / NFC waiting
  -> menu browsing during waiting
  -> cart / order candidate creation
  -> preorder intent or order candidate before entry
  -> store-side handoff
  -> table matching after entry
  -> prep / service
```

### 2.4 Goals

- reduce menu selection time after seating.
- reduce order transmission delay.
- secure prep lead time.
- improve turnover.
- reduce staff order-taking burden.
- reduce no-show and order-uncertainty risk.

## 3 BM 3-B: Foreign / Non-Face-To-Face Mini Kiosk

### 3.1 Target Stores

- stores with little or no waiting.
- stores with foreign visitors.
- stores where menu explanations are difficult.
- stores with multilingual menu needs.
- stores without physical kiosk due to cost.
- tourist zones, stations, markets, alley restaurants, and cafes.

### 3.2 Core Problem

- lack of foreign-language menu.
- staff language burden.
- insufficient menu photos and options.
- difficulty communicating customer intent.
- kiosk installation cost.

### 3.3 Target Flow

```text
tablet Mini Kiosk or QR / web entry
  -> language selection
  -> photo menu / options
  -> order candidate creation
  -> staff confirmation
  -> manual POS input or printer output
  -> store-side payment
```

### 3.4 Positioning

This is not necessarily an automatic order system.

It is a sales expansion tool that lets foreign customers understand menus and create order candidates.

## 4 Inclusion Relationship

- Stores using waiting function naturally include Mini Kiosk-like menu browsing and multilingual menu features.
- Stores without waiting can use Mini Kiosk only.
- Waiting feature can be off while menu, order-candidate, and multilingual support remains on.

## 5 Store Type Classification

### 5.1 Type 0: No POS Or Dislikes Systems

- Not a primary target.
- Can approach with a foreign-order Mini Kiosk package.
- No POS auto integration.
- No KDS.
- No prepayment.
- No membership.
- No settlement automation.

### 5.2 Type 1: Has POS But No External API

- Most realistic initial target.
- Uses customer QR/NFC or Mini Kiosk.
- Creates order candidate in our system.
- Staff sees it in admin or store screen.
- Staff manually enters POS.
- Existing POS handles payment and receipt or kitchen printer.
- Must not call it "order completed".

Correct wording:

- order candidate.
- preorder request.
- confirmed after staff review.

### 5.3 Type 1B: No POS API But Uses Store Agent / Printer Option

- Store Agent or printer gateway receives order candidate.
- Optional order ticket print.
- Existing POS still requires manual or after input.
- Needs daily/monthly reconciliation report.
- Printer is optional, not mandatory.

### 5.4 Type 2: POS Provides External Order API

- Store Order Gateway can create POS order.
- POS handles kitchen printer or KDS.
- POS order number can be mapped.
- Store Agent is optional for fallback, audit, or local backup.

### 5.5 Type 3: Our System Receives Payment

- Powerful but high legal, tax, and settlement risk.
- Not default for early MVP.

Requires:

- PG structure.
- seller-of-record decision.
- receipt issuer.
- VAT reporting data.
- refund policy.
- settlement cycle.
- platform fee tax invoice.
- POS reflection method.

### 5.6 Type 4: Full OS Adoption Store

Type 4 applies to stores where the operating stack is controlled end to end, such as a Yoonsul-operated store.

It can support:

- waiting.
- preorder.
- payment.
- temporary KDS order.
- table matching.
- membership.
- CMS.
- Agent.
- Audit.
- AI analysis.

## 6 Payment Option Separation

Payment must be separate from waiting/order handoff.

Early default:

- no payment by our system.
- store POS payment.
- our system handles waiting, menu, order candidate, and admin screen only.

Advanced option:

- our system takes prepayment.
- requires tax, legal, settlement, receipt, and refund design.

Payment-performing mode is a patent/future option, not the early default.

## 7 Allowed Claims

We may say:

- waiting stores can reduce after-seating order time.
- non-waiting stores can use Mini Kiosk for foreign customers.
- POS API stores can support POS auto order creation.
- non-POS-API stores can use staff screen, Store Agent, printer option, and manual POS entry.
- initial payment model is safer with store POS payment.

## 8 Forbidden Claims

We must not say:

- all stores can auto-create POS orders.
- no-POS-API stores auto-reflect into POS.
- printers always connect automatically.
- our payment is default.
- all stores can immediately use prepayment, points, or membership.
- POS sales reconciliation is automatically guaranteed.

## 9 Product Packages

### 9.1 Mini Kiosk Only

For stores that mainly need multilingual menu, photo menu, option selection, and order candidate creation without waiting management.

### 9.2 Waiting + Mini Kiosk

For stores that need waiting registration plus menu browsing and order candidate preparation during waiting.

### 9.3 Waiting + Store Agent / Printer

For stores that need waiting and order candidate handoff plus optional ticket printing or local Store Agent assistance.

### 9.4 POS API Integrated

For stores whose POS provides external order API support and can receive orders through a Store Order Gateway.

### 9.5 Full OS

For stores where the broader operating stack is controlled and can include POS, KDS, membership, CMS, Agent, Audit, and AI analysis.

## 10 Initial MVP Product Recommendation

Realistic initial products:

1. Mini Kiosk Only.
2. Waiting + Mini Kiosk.
3. Waiting + Store Agent / Printer.

Not initial defaults:

- our payment-performing mode.
- platform points.
- franchise membership integration.
- guaranteed POS sales auto-reconciliation.

## 11 Current Status

Status: active MVP product package strategy.

This document is development design only. It does not create SQL, migrations, app code, payment code, POS integration, printer protocol, or Store Agent implementation.

## 12 MVP Consolidation Cross-Reference

- Store-type adoption sequence is consolidated in `docs/01000_mvp_scope/01060_MVP_Store_Type_Adoption_Sequence.md`.
- Package/feature flag boundary is consolidated in `docs/01000_mvp_scope/01050_Boundary_MVP_Package_And_Feature_Flag.md`.
- Full OS and platform payment remain non-default MVP paths.

## 13 Runtime Model Cross-Reference

Package names must align with `docs/03000_saas_runtime/03010_Tenant_Store_Runtime_And_Package_Model.md`.

Store type classification in this document is business-facing.

Package plan and feature flags are SaaS runtime-facing.
