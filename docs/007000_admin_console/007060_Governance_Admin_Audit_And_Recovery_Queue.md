# 007060_Governance_Admin_Audit_And_Recovery_Queue.md

## 1 Purpose

Admin Console must provide audit-first recovery.

Recovery actions must not silently overwrite original events.

Recovery queue is an operational safety layer, not a hidden mutation layer.

This document is conceptual only.
It does not define SQL, migrations, app code, Supabase functions, final permission schema, or UI implementation.

## 2 Audit Event Categories

Conceptual audit event categories:

- `CONFIG_CHANGE`
- `PACKAGE_PLAN_CHANGE`
- `FEATURE_FLAG_CHANGE`
- `INTEGRATION_CHANGE`
- `PAYMENT_PROFILE_CHANGE`
- `ORDER_CANDIDATE_REVIEW`
- `PREORDER_CONFIRMATION`
- `STORE_AGENT_EVENT`
- `PRINTER_EVENT`
- `POS_API_EVENT`
- `MANUAL_RECOVERY_ACTION`
- `SUPPORT_ACCESS`
- `EMERGENCY_DISABLE`
- `EXPORT_ACTION`
- `FUTURE_MEMBERSHIP_POINT_RESERVED_EVENT`

## 3 Recovery Queue Item Types

Conceptual recovery queue item types:

- `ORDER_CANDIDATE_UNREVIEWED`
- `DUPLICATE_CANDIDATE_SUSPECTED`
- `PRINTER_FAILED`
- `POS_API_FAILED`
- `STORE_AGENT_OFFLINE`
- `CUSTOMER_CALLED_NOT_ARRIVED`
- `STAFF_CONFIRMED_WRONG_ITEM`
- `INTEGRATION_STATE_UNCERTAIN`
- `PAYMENT_PROFILE_MISMATCH`
- `CONFIG_CHANGE_ROLLBACK_REQUIRED`
- `SUPPORT_REVIEW_REQUIRED`

## 4 Recovery Item Lifecycle

Conceptual lifecycle:

- `OPEN`
- `ASSIGNED`
- `IN_REVIEW`
- `ACTION_TAKEN`
- `CUSTOMER_OR_STORE_CONFIRMATION_REQUIRED`
- `RESOLVED`
- `ESCALATED`
- `CLOSED`
- `REOPENED`

## 5 Recovery Action Rules

- recovery appends events.
- recovery does not overwrite original state.
- dismiss does not mean resolved.
- support action does not equal approval.
- printer retry does not equal POS order creation.
- POS API retry must avoid duplicate order.
- customer notification must match real confirmation state.

## 6 Audit Visibility By Role

- `platform_admin`: broad audit visibility across platform scope.
- `tenant_admin`: tenant-scoped audit and recovery visibility.
- `operating_group_manager`: operating-group-scoped operational audit and recovery visibility.
- `store_owner`: store-scoped audit, recovery, and change visibility.
- `store_manager`: store operational recovery and limited audit visibility.
- `support_operator`: support-session-scoped audit and recovery visibility.
- `read_only_auditor`: read-only audit and export visibility.

## 7 Export / Report Governance

- export action must be audited.
- sensitive customer details should be limited.
- recovery reports should distinguish operational issue from financial/payment truth.
- future membership/point data must not be exported in MVP.

## 8 Open Decisions

- retention period.
- export formats.
- PII masking depth.
- customer-facing recovery message templates.
- escalation policy.
- SLA severity levels.

## 9 Current Status

Status: active admin console governance design.
