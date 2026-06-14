# 01030 Competitive Positioning And Market Context

## 1 Purpose

This document defines the market and competitive positioning for `yoonsul_wait_order_handoff`.

The project is not positioned as a full POS replacement, payment company, KDS provider, membership platform, or franchise OS in the early MVP.

The project is positioned as a waiting-to-order handoff and Mini Kiosk SaaS that reduces after-seating order delay and helps stores communicate menu/order intent before staff confirmation.

## 2 Market Problem

Many stores lose time because customer waiting, menu selection, seating, and order capture are separated.

Common problems:

- customers wait before seating but only start menu decisions after seating.
- staff must explain menus repeatedly during peak time.
- foreign visitors may not understand menu names, options, or ordering style.
- physical kiosk/table-order hardware can be expensive or excessive for small stores.
- stores without POS API cannot easily automate order creation.
- staff still needs a safe manual handoff path.

## 3 Competitive Context

Relevant neighboring categories:

- POS systems.
- waiting list systems.
- table order systems.
- kiosk systems.
- mobile order systems.
- QR menu systems.
- reservation systems.
- delivery platform order tools.
- CRM/loyalty tools.

`yoonsul_wait_order_handoff` should not compete head-on as a complete replacement for all of these in the MVP.

It should occupy the gap between waiting, menu browsing, order candidate creation, and staff/store confirmation.

## 4 Differentiation

Primary differentiation:

- waiting-to-order lead time reduction.
- order candidate creation before seating or staff confirmation.
- Mini Kiosk mode without mandatory waiting.
- multilingual/photo/menu option support.
- compatibility with manual POS input.
- package strategy for stores with different integration maturity.
- clear boundary between order candidate, staff-confirmed order, POS-confirmed order, and paid preorder.

## 5 Positioning By Store Type

### 5.1 Waiting Stores

Positioning:

- reduce after-seating order time.
- improve turnover.
- reduce staff order-taking burden.
- capture preorder intent while customer is already waiting.

Best-fit packages:

- `WAITING_MINI_KIOSK`
- `WAITING_STORE_AGENT_PRINTER`
- `POS_API_INTEGRATED` when POS API exists.

### 5.2 Foreign Visitor / Tourist Stores

Positioning:

- help customers understand menu photos, options, and language.
- reduce staff language burden.
- create order candidate for staff confirmation.

Best-fit packages:

- `MINI_KIOSK_ONLY`
- `WAITING_MINI_KIOSK` if waiting also exists.

### 5.3 No-POS-API Stores

Positioning:

- staff screen and manual POS entry remain safe default.
- printer or Store Agent can be optional support.

Best-fit packages:

- `MINI_KIOSK_ONLY`
- `WAITING_MINI_KIOSK`
- `WAITING_STORE_AGENT_PRINTER`

### 5.4 POS-API Stores

Positioning:

- support POS order creation only after validation.
- preserve fallback and audit for failures.

Best-fit package:

- `POS_API_INTEGRATED`

## 6 Messaging Rules

Allowed positioning:

- waiting stores can reduce after-seating order time.
- Mini Kiosk can help non-waiting stores serve foreign or non-face-to-face customers.
- no-POS-API stores can use staff/admin handoff and manual POS input.
- Store Agent/printer is optional, not mandatory.
- POS API integration is store-specific.
- store POS payment is the early default.

Forbidden positioning:

- automatic POS order creation for every store.
- guaranteed printer connection for every store.
- platform payment as default.
- membership/point as active MVP feature.
- POS sales reconciliation guaranteed without integration.
- AI recommendation as early MVP feature.

## 7 Early MVP Market Wedge

The early wedge should focus on:

1. stores with waiting and peak-time order delay.
2. stores with foreign visitor communication problems.
3. stores that want low-cost menu/order candidate support without kiosk hardware.
4. stores where staff confirmation and manual POS input are acceptable.

The first market story should be operationally modest:

```text
Prepare order intent before staff confirmation.
Reduce the gap between waiting and ordering.
Do not force POS/payment integration on day one.
```

## 8 Future Expansion Boundary

Future expansion may include:

- analytics.
- ad/CRM surfaces.
- AI recommendation.
- membership/point.
- franchise OS linkage.
- deeper POS/KDS/payment integrations.

These are not active MVP claims.

Future data, ad, CRM, and AI expansion is reserved in `docs/28000_future_expansion/28040_Data_Ad_CRM_AI_Future_Expansion_Model.md`.

## 9 Open Decisions

- first target segment by region and store type.
- pricing message by package.
- whether Mini Kiosk Only or Waiting + Mini Kiosk should lead sales.
- whether tourist-zone stores should be a separate launch segment.
- what evidence is needed to prove reduced after-seating order time.
- whether printer option should be sold early or treated as support add-on.

## 10 Current Status

Status: active market positioning design.

This document is documentation-only and does not define sales collateral, ads, legal claims, implementation, or pricing finalization.
