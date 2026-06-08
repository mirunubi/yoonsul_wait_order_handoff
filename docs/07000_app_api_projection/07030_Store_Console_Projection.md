# 07030 Store Console Projection

## 1 Purpose

Store console helps store staff review order candidates, preorder requests, waiting sessions, Mini Kiosk sessions, Store Agent/printer status, and manual recovery items.

Store console is not POS.

Store console is not financial truth.

This document is projection only.
It does not define UI components, routing, API implementation, database schema, POS integration, payment integration, printer driver, or production store app behavior.

## 2 Store Console Screens

Conceptual store console screens:

- store dashboard.
- waiting session list.
- waiting session detail.
- order candidate queue.
- order candidate detail.
- preorder request queue.
- staff confirmation screen.
- Mini Kiosk session monitor.
- Store Agent status.
- printer status.
- POS API status if available.
- manual recovery queue.
- recovery item detail.
- audit/change visibility.

## 3 Staff Actions

Conceptual staff actions:

- review order candidate.
- confirm staff-reviewed order.
- reject/cancel candidate.
- mark manual POS input needed.
- mark POS input completed.
- retry printer output.
- flag duplicate candidate.
- request support.
- resolve recovery item.

Every high-risk action should create audit evidence in the future design.

## 4 Forbidden Claims

- store console confirmation does not equal platform payment.
- printer output does not equal POS sales creation.
- POS API attempt does not equal success.
- recovery action does not overwrite original event.
- support action does not equal approval.
- manual POS input completed does not prove platform-side financial truth.

## 5 Role Access

Conceptual role access:

- `store_staff`: operational queue, waiting, order candidate, Mini Kiosk, and assigned recovery prompts.
- `store_manager`: store operational monitoring, staff confirmation, recovery, printer, POS API status if available, and limited audit visibility.
- `store_owner`: store runtime visibility, reporting visibility, recovery, and request authority according to policy.
- `support_operator`: scoped support view only through approved support access.
- `read_only_auditor`: read-only audit and change visibility.

## 6 Open Decisions

- whether store_staff uses same admin shell.
- mobile/tablet layout.
- sound/notification model.
- printer retry UX.
- duplicate order prevention UX.
- POS manual input checklist.

## 7 Current Status

Status: active store console projection only. No implementation approval.

