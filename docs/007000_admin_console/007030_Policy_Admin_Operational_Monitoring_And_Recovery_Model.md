# 007030_Policy_Admin_Operational_Monitoring_And_Recovery_Model.md

## 1 Purpose

Admin Console must show operational state without becoming the source of POS/payment truth.

It helps staff and operators see what needs confirmation, recovery, or support.

This document is conceptual only.
It does not define SQL, migrations, app code, Supabase functions, final permission schema, or UI implementation.

## 2 Operational Objects

Admin Console may show visibility for:

- `customer_session`
- `waiting_session`
- `handoff_session`
- `mini_kiosk_session`
- `order_candidate`
- `preorder_request`
- `staff_action`
- Store Agent status.
- printer status.
- POS API status.
- manual recovery item.
- audit event.

## 3 Order Candidate / Preorder Request Monitoring

Admin should show:

- new order candidate.
- staff review required.
- customer waiting status.
- table/pickup mode.
- language used.
- integration level.
- whether POS input is manual or automatic.
- whether printer output was attempted.
- whether customer wording should remain "order candidate" or "staff-confirmed order".

## 4 Store Agent / Printer Monitoring

Statuses:

- `ONLINE`
- `OFFLINE`
- `DEGRADED`
- `PRINT_PENDING`
- `PRINT_SUCCEEDED`
- `PRINT_FAILED`
- `MANUAL_REVIEW_REQUIRED`

Printer output does not equal POS sales creation.

Store Agent status does not equal order confirmation.

Failed print must create recovery visibility.

## 5 Manual Recovery

Recovery cases:

- order candidate not reviewed.
- duplicate candidate suspected.
- printer failed.
- POS API failed.
- customer called but not arrived.
- staff confirmed wrong item.
- integration uncertain.
- payment profile mismatch.

## 6 Audit Principles

- all runtime setting changes audited.
- all manual recovery actions audited.
- support actions audited.
- no silent mutation.
- recovery does not overwrite original event.
- correction must append an event.

## 7 Membership / Point Reserved Visibility

membership/point is future-reserved under 9000.

Admin Console may show reserved placeholders in future.

Active MVP must not show point balance, point redemption, wallet, or loyalty ledger as active operations.

## 8 Open Decisions

- recovery queue ownership.
- support escalation model.
- notification channels.
- SLA display.
- export/report needs.

## 9 Current Status

Status: active admin console governance design.
