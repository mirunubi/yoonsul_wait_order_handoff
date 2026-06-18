# 013010_App_Surface_And_Channel_Projection

## 1 Purpose

This document defines app/channel projection only.

It does not approve implementation.

It distinguishes customer webapp, store console, admin console, support console, and future surfaces.

This document does not define routing, UI components, API functions, authentication implementation, database schema, payment integration, POS integration, or production app structure.

## 2 App Surfaces

Conceptual app surfaces:

- `customer_webapp`: customer-facing waiting, menu browsing, cart, order candidate, handoff, and notification surface.
- `mini_kiosk_webapp`: customer-facing but store-assisted tablet or shared-device surface for menu browsing and order candidate creation.
- `store_console`: operational staff and store manager surface for waiting, order candidate review, confirmation, printer, POS API status, and recovery.
- `admin_console`: configuration, governance, package, feature flag, approval, audit, report, and export surface.
- `support_console`: scoped and audited support surface for platform support actions.
- `future_owner_mobile_view`: future owner-facing mobile visibility surface for store health and reports.
- `future_analytics_dashboard`: future-reserved analytics surface for approved aggregate or governed data.

## 3 Channel Entry Points

Conceptual channel entry points:

- QR entry.
- NFC entry.
- tablet Mini Kiosk.
- staff-shared link.
- waiting link.
- store admin login.
- platform admin login.
- support scoped access.

## 4 Surface Ownership

- customer_webapp is customer-facing.
- mini_kiosk_webapp is customer-facing but store-assisted.
- store_console is operational.
- admin_console is configuration/governance.
- support_console is scoped and audited.
- analytics dashboard is future-reserved.

## 5 Non-Implementation Boundary

This projection does not include:

- routing implementation.
- UI components.
- API functions.
- auth implementation.
- database schema.
- payment integration.
- POS integration.

## 6 Open Decisions

- whether customer_webapp and mini_kiosk_webapp share one shell.
- whether store_console and admin_console are separate apps.
- mobile-first vs desktop-first admin.
- kiosk tablet lock mode.
- login method for store staff.
- anonymous customer session depth.

## 7 Current Status

Status: active app/channel projection only. No implementation approval.
