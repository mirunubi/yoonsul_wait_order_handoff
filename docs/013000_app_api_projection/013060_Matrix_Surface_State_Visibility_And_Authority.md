# 013060_Matrix_Surface_State_Visibility_And_Authority.md

## Purpose

Surface visibility must not imply mutation authority.

Each surface sees only the state required for its role and context.

This document is projection only and does not define implementation.

It does not define UI implementation, API endpoint implementation, RLS policy implementation, physical permission schema, database schema, or production authorization behavior.

## 2 Surfaces

Conceptual surfaces:

- `customer_webapp`: customer-facing state, wording, order candidate, and handoff visibility.
- `mini_kiosk_webapp`: customer-facing but store-assisted current kiosk session visibility.
- `store_console`: operational store-level queue, confirmation, integration status, and recovery visibility.
- `admin_console`: scoped tenant, store, configuration, governance, approval, audit, and export visibility.
- `support_console`: scoped and audited support session visibility.
- `future_analytics_dashboard`: future aggregate, anonymized, or pseudonymized analytics visibility only.

## 3 State Families

State families covered by this projection:

- `customer_session`.
- `waiting_session`.
- `handoff_session`.
- `mini_kiosk_session`.
- `store_runtime`.
- `order_candidate`.
- `preorder_request`.
- Store Agent status.
- printer status.
- POS API status.
- `manual_recovery_item`.
- `audit_event`.
- `export_request`.
- `future_membership_point_placeholder`.

## 4 Visibility Rules

- customer sees only their own session state.
- Mini Kiosk user sees only current kiosk session context.
- store_console sees operational store-level states.
- admin_console sees scoped tenant/store/config states based on role.
- support_console sees only scoped support session data.
- future_analytics_dashboard must use aggregate/anonymized/pseudonymized data only.
- customer cannot see audit event internals.
- store staff cannot see export request internals unless authorized.
- future membership/point placeholder may be visible only as reserved status, not active ledger, wallet, point balance, or redemption state.

## 5 Mutation Authority Rules

- customer may create order candidate but cannot confirm POS order.
- store staff may review/confirm order candidate but cannot enable platform payment.
- store manager may resolve recovery item but cannot silently mutate audit history.
- tenant admin may request package/feature changes but high-risk changes require approval.
- support operator may assist but cannot approve own support action.
- admin console mutation requires audit event.
- export action requires approval and audit.
- analytics dashboard must not mutate runtime state.

## 6 Matrix

| surface | visible states | requestable actions | direct mutation allowed? | approval required? | audit required? | forbidden actions |
| --- | --- | --- | --- | --- | --- | --- |
| `customer_webapp` | Own `customer_session`, own `waiting_session`, own `handoff_session`, own `order_candidate`, own `preorder_request`, customer-facing `store_runtime`, customer-facing recovery status. | Create/edit/cancel order candidate where allowed, submit preorder request, cancel own waiting/handoff where allowed, request help. | Limited customer-owned session actions only. | Staff confirmation required for operational order confirmation. | Audit may be required for submitted candidate, cancellation, recovery, or dispute-sensitive events. | Cannot confirm POS order, see audit internals, see other customers, approve payment, or mutate store runtime. |
| `mini_kiosk_webapp` | Current kiosk session, menu snapshot, cart/order candidate, language state, staff help state. | Create order candidate, request staff help, cancel current kiosk session. | Limited current session actions only. | Staff confirmation required before store-executable order. | Audit may be required for submitted candidate and staff-assisted events. | Cannot see other kiosk sessions, audit internals, POS status internals, or export requests. |
| `store_console` | Store-level waiting, handoff, Mini Kiosk, order candidate, preorder request, Store Agent, printer, POS API if available, manual recovery, limited audit/change visibility. | Review/confirm/reject candidate, mark manual POS input, retry printer, flag duplicate, resolve recovery, request support. | Operational store actions only. | Required for high-risk recovery, integration, payment, package, feature, or export actions. | Required for confirmation, recovery, printer retry, POS API retry, manual POS marking, and support request. | Cannot enable platform payment, change package without workflow, delete audit history, or export without approval. |
| `admin_console` | Scoped tenant/store/config/package/feature/integration/payment, operational summary, audit, support, reports/export, future placeholders. | Request/approve changes where authorized, emergency disable, open support session, review audit, approve export request. | Only within role/context authority and approval workflow. | Required for high-risk config, payment, POS API, printer, Store Agent, support, and export actions. | Required for all high-risk admin mutations and exports. | Cannot bypass approval workflow, silently enable high-risk flags, or treat visibility as export authority. |
| `support_console` | Scoped support session data, operational status needed for support, recovery status, relevant audit trail. | Assist recovery, request escalation, document support action, recommend next action. | Limited support actions only when scoped. | Approval required for sensitive actions; support operator cannot approve own support action. | Required for all support access and support actions. | Cannot silently mutate order state, approve own support action, export raw customer data, or change payment/package without authority. |
| `future_analytics_dashboard` | Aggregate/anonymized/pseudonymized analytics, approved metrics, governed future intelligence material. | Request governed report or analysis where policy allows. | No runtime mutation. | Required for restricted export, cross-entity sharing, or future intelligence handoff. | Required for exports and restricted dataset access. | Cannot show raw customer/session data by default, mutate runtime state, target ads, or imply Franchise OS authority. |

## 7 App/API Projection Consolidation Cross-Reference

- Surface-to-authority projection is refined in `docs/13000_app_api_projection/013090_Surface_To_Authority_Projection_Model.md`.
- Integration status projection is refined in `docs/13000_app_api_projection/013120_Boundary_Integration_Status_Projection.md`.
- Future surface/API non-MVP boundary is refined in `docs/13000_app_api_projection/013130_Boundary_Future_Surface_And_Api_Non_MVP.md`.
- Surface visibility must still not imply mutation authority.

## 8 Non-Implementation Boundary

This document does not include:

- UI implementation.
- API endpoint implementation.
- RLS policy implementation.
- physical permission schema.

## 9 Open Decisions

- whether support_console is separate app or admin mode.
- customer session identity depth.
- store staff permission tiers.
- analytics visibility granularity.
- export approval UI location.

## 10 Current Status

Status: active surface visibility and authority projection. No implementation approval.
