# 7000 App Api Projection Readme

## 1 Purpose

This folder is reserved for future customer web, store console, admin console, and API contract projection.

## 2 In Scope

- Future app surface planning.
- API contract projection.
- Customer web, store console, and admin console boundaries.
- Channel entry and surface ownership projection.
- Customer, store, admin, support, and future analytics surface distinction.

## 3 Document List

| document | description |
| --- | --- |
| `7010_App_Surface_And_Channel_Projection.md` | Defines conceptual app surfaces, channel entry points, ownership boundaries, and non-implementation limits. |
| `7020_Customer_Webapp_Projection.md` | Defines customer-facing webapp modes, conceptual screens, wording rules, and privacy notes. |
| `7030_Store_Console_Projection.md` | Defines store console screens, staff actions, role access, and forbidden POS/payment claims. |
| `7040_Admin_Console_Projection.md` | Projects 4000 admin governance into conceptual admin screen groups, actions, and authority constraints. |
| `7050_Api_Contract_Projection_Boundary.md` | Defines conceptual API contract groups, contract principles, and forbidden implementation boundaries. |
| `7060_Surface_State_Visibility_And_Authority_Matrix.md` | Defines surface-by-surface state visibility, requestable actions, mutation authority, approval, audit, and forbidden actions. |
| `7070_Customer_Surface_State_Wording_Matrix.md` | Defines customer-facing wording by state, integration level, recovery/delay condition, and multilingual/Mini Kiosk boundary. |
| `7080_Store_Admin_Support_Action_Authority_Matrix.md` | Defines action authority across store, admin, support, legal, platform, and auditor roles. |

## 4 Out Of Scope

- App implementation, package files, Supabase functions, RPC implementation, and production API code.
- Routing, UI components, auth implementation, endpoint creation, database schema, payment integration, POS integration, and printer driver implementation.

## 5 Current Status

Status: initial projection namespace. No implementation.
