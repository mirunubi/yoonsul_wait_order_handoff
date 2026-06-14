# 13000 App Api Projection Readme

## 1 Purpose

This folder defines customer web, store console, admin console, support console, and API contract projection.

This wave consolidates App/API projection after the Integration Boundary consolidation wave.

## 2 In Scope

- App surface and channel projection.
- Customer, store, admin, and support surface boundaries.
- API contract projection and conceptual API groups.
- Surface-to-authority projection.
- Idempotency, recovery, and audit envelope projection.
- Integration status projection.
- Future/non-MVP surface and API boundaries.
- Surface state visibility, wording, and action authority matrices.

## 3 Document List

| document | description |
| --- | --- |
| `13010_App_Surface_And_Channel_Projection.md` | Defines conceptual app surfaces, channel entry points, ownership boundaries, and non-implementation limits. |
| `13020_Customer_Webapp_Projection.md` | Defines customer-facing webapp modes, conceptual screens, wording rules, and privacy notes. |
| `13030_Store_Console_Projection.md` | Defines store console screens, staff actions, role access, and forbidden POS/payment claims. |
| `13040_Admin_Console_Projection.md` | Projects admin governance into conceptual admin screen groups, actions, and authority constraints. |
| `13050_Api_Contract_Projection_Boundary.md` | Defines conceptual API contract groups, contract principles, and forbidden implementation boundaries. |
| `13060_Surface_State_Visibility_And_Authority_Matrix.md` | Defines surface-by-surface state visibility, requestable actions, mutation authority, approval, audit, and forbidden actions. |
| `13070_Customer_Surface_State_Wording_Matrix.md` | Defines customer-facing wording by state, integration level, recovery/delay condition, and multilingual/Mini Kiosk boundary. |
| `13080_Store_Admin_Support_Action_Authority_Matrix.md` | Defines action authority across store, admin, support, legal, platform, and auditor roles. |
| `13090_Surface_To_Authority_Projection_Model.md` | Maps surfaces to visibility, request, mutation, approval, and audit authority types. |
| `13100_Customer_Store_Admin_Api_Group_Boundary.md` | Conceptual API group boundaries by authority, context, and truth family. |
| `13110_Idempotency_Recovery_And_Audit_Envelope_Projection.md` | Idempotency, recovery, and audit envelope projection across surfaces. |
| `13120_Integration_Status_Projection_Boundary.md` | Integration state projection without overstating truth per `11020`~`11060`. |
| `13130_Future_Surface_And_Api_Non_MVP_Boundary.md` | Future membership, analytics, payment, Franchise OS, and benchmark API/surface boundaries. |

`13010`~`13080` are existing app/API projection foundations.

`13090`~`13130` consolidate authority projection, conceptual API groups, idempotency/recovery/audit envelopes, integration status projection, and future non-MVP surface/API boundaries.

This domain remains projection-only and does not create endpoints.

## 4 Out Of Scope

- App implementation, package files, Supabase functions, RPC implementation, and production API code.
- Routing, UI components, auth implementation, endpoint creation, database schema, payment integration, POS integration, and printer driver implementation.

## 5 Current Status

Status: App/API projection consolidation wave complete. Projection only. Not implementation approval.
