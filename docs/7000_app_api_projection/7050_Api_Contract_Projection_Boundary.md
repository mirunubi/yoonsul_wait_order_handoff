# 7050 Api Contract Projection Boundary

## 1 Purpose

API projection defines contract groups only.

No endpoint implementation.

No RPC creation.

No database schema.

No code.

This document is projection only and does not approve implementation.

## 2 Conceptual API Groups

Conceptual API groups:

- `customer_session_api`.
- `waiting_session_api`.
- `menu_snapshot_api`.
- `order_candidate_api`.
- `handoff_session_api`.
- `mini_kiosk_session_api`.
- `store_console_api`.
- `admin_runtime_config_api`.
- `approval_workflow_api`.
- `integration_profile_api`.
- `store_agent_status_api`.
- `printer_status_api`.
- `pos_api_gateway_boundary`.
- `manual_recovery_api`.
- `audit_event_api`.
- `export_request_api`.
- `support_access_api`.

## 3 Contract Principles

- API action authority must follow role/context scope.
- mutation APIs require audit.
- high-risk config APIs require approval workflow.
- customer APIs must not expose admin data.
- support APIs must be scoped and time-bound.
- export APIs require approval and audit.
- POS API gateway boundary does not assume POS API exists.
- printer status API does not equal POS sales truth.
- API contracts must preserve wording distinctions between order candidate, staff-confirmed order, POS-confirmed order, and paid preorder.

## 4 Forbidden Implementation

- do not create endpoints now.
- do not create Supabase RPC now.
- do not create database schema now.
- do not create auth middleware now.
- do not create payment API now.
- do not create POS integration now.
- do not create printer driver now.

## 5 Open Decisions

- REST vs RPC vs GraphQL.
- Supabase RPC boundary.
- Edge Functions use.
- tenant context propagation.
- idempotency model.
- API versioning.
- rate limiting.
- audit event envelope.

## 6 Current Status

Status: active API contract projection boundary. No implementation approval.
