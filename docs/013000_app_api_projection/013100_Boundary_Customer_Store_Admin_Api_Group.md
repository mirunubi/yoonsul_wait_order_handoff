# 013100_Boundary_Customer_Store_Admin_Api_Group

## 1 Purpose

API groups must be separated by authority, context, and truth family.

This document does not implement endpoints.

It defines conceptual grouping only.

This document is projection governance only.
It does not approve URL paths, RPC names, or request/response schema.

## 2 Conceptual API Groups

| API group | authority/context |
| --- | --- |
| customer session API group | Customer session lifecycle and surface context. |
| waiting/session API group | Waiting registration and session linkage. |
| menu snapshot API group | Read-only menu content for customer surfaces. |
| order candidate API group | Draft order intent; not confirmed order. |
| preorder request API group | Preorder intent submission; not paid order. |
| store review API group | Staff review, confirm, reject operational actions. |
| store console API group | Store operational console actions within staff scope. |
| admin runtime configuration API group | Runtime profile change request/approval context. |
| admin approval API group | Approval workflow actions within admin authority. |
| support session API group | Scoped support session lifecycle and actions. |
| audit/recovery API group | Append-only audit and recovery queue visibility. |
| integration status API group | Integration attempt/status projection per `13120`. |
| report/export request API group | Export request and approval tracking. |
| future membership API group | Placeholder per `15000`; not MVP active API. |
| future analytics API group | Placeholder per `26000`; not MVP active API. |

## 3 Group Boundary Rules

- customer API must not mutate admin runtime profile.
- store console API is not POS API.
- admin configuration API does not equal activation unless approved.
- support API must be scoped and audited.
- integration status API does not create integration success.
- audit API must not overwrite source events.
- export API requires approval governance.
- future membership/analytics APIs are not MVP active APIs.

## 4 Non-Implementation Boundary

- no endpoint implementation.
- no URL paths.
- no RPC names.
- no request/response schema.
- no auth middleware.
- no database schema.
- no API versioning implementation.

## 5 Cross-References

- `docs/13000_app_api_projection/013050_Boundary_Api_Contract_Projection.md`
- `docs/11000_integration_boundary/011020_Boundary_POS_API_Integration_Truth.md`
- `docs/09000_data_model_state_machine/009100_Admin_Support_Audit_Entity_Lineage_Model.md`

## 6 Open Decisions

- REST vs RPC vs Edge Function.
- API versioning strategy.
- session token model.
- role/context propagation.
- idempotency key strategy.
- rate limiting.
- audit envelope shape.

## 7 Current Status

Status: active customer store admin API group boundary. Not implementation approval.
