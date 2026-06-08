# 7040 Admin Console Projection

## 1 Purpose

Admin Console projection turns 4000 governance into conceptual app surfaces.

It does not create implementation tasks.

This document is projection only.
It does not define UI components, routing, API implementation, auth implementation, database schema, package billing implementation, payment integration, or POS integration.

## 2 Admin Screen Groups

Projected groups follow `docs/4000_admin_console/4040_Admin_Screen_Inventory_And_Navigation_Model.md`:

- Dashboard.
- Tenant / Company / Legal Entity / Operating Group / Store.
- Package Plan / Feature Flags.
- Integration Profiles.
- Payment Profile.
- Order Candidate / Preorder Review.
- Waiting / Mini Kiosk Monitoring.
- Store Agent / Printer Monitoring.
- Manual Recovery Queue.
- Audit / Change History.
- Support Tools.
- Reports / Export.
- Future Reserved: Membership / Point.

## 3 Admin Actions

Conceptual admin actions:

- view context.
- request package change.
- approve/reject change.
- enable/disable feature flag.
- request POS API activation.
- request printer activation.
- emergency disable.
- open support session.
- review audit event.
- approve export request.

These actions are projections of governance needs, not implementation tasks.

## 4 Authority Constraints

- view authority does not equal mutation authority.
- admin visibility does not equal export authority.
- package change does not automatically enable high-risk flags.
- `payment_by_platform_enabled` remains non-MVP/future unless separately approved.
- membership/point remains future-reserved.
- support action does not equal approval.
- emergency disable must be audited.

## 5 Open Decisions

- admin layout.
- approval inbox design.
- report/export UI depth.
- support access modal.
- audit event detail view.
- platform vs tenant admin separation.

## 6 Current Status

Status: active admin console projection only. No implementation approval.
