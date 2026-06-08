# 07050 Admin Approval Workflow Model

## 1 Purpose

Not every admin-visible setting can be changed directly.

High-risk changes require request, validation, approval, audit, and rollback path.

Package selection must not silently enable high-risk features.

This document is conceptual only.
It does not define SQL, migrations, app code, Supabase functions, final permission schema, or UI implementation.

## 2 Change Request Types

Conceptual change request types:

- `PACKAGE_PLAN_CHANGE`
- `FEATURE_FLAG_CHANGE`
- `INTEGRATION_PROFILE_CHANGE`
- `POS_API_ACTIVATION`
- `STORE_AGENT_ACTIVATION`
- `PRINTER_OUTPUT_ACTIVATION`
- `PAYMENT_PROFILE_CHANGE`
- `PLATFORM_PAYMENT_ACTIVATION`
- `MANUAL_RECOVERY_ACTION`
- `SUPPORT_ACCESS_REQUEST`
- `EMERGENCY_DISABLE`
- `FUTURE_MEMBERSHIP_POINT_ACTIVATION_REQUEST`

`FUTURE_MEMBERSHIP_POINT_ACTIVATION_REQUEST` is reserved only.
It cannot activate MVP membership/point runtime.

## 3 Approval Levels

Conceptual approval levels:

- `STORE_MANAGER_CONFIRM`
- `STORE_OWNER_APPROVAL`
- `TENANT_ADMIN_APPROVAL`
- `PLATFORM_ADMIN_APPROVAL`
- `LEGAL_TAX_REVIEW_REQUIRED`
- `INTEGRATION_VALIDATION_REQUIRED`
- `DEVICE_TEST_REQUIRED`
- `AUDIT_ONLY`

## 4 Workflow Stages

Conceptual workflow stages:

- `REQUESTED`
- `VALIDATION_PENDING`
- `APPROVAL_PENDING`
- `APPROVED`
- `REJECTED`
- `ACTIVATION_PENDING`
- `ACTIVE`
- `ROLLBACK_REQUIRED`
- `DISABLED`
- `CANCELLED`

## 5 High-Risk Change Rules

- `payment_by_platform_enabled` requires legal/tax review and platform approval.
- `pos_api_enabled` requires integration validation.
- `printer_output_enabled` requires device test.
- `store_agent_enabled` requires runtime validation.
- package plan change must not automatically enable payment or POS API.
- future membership/point activation remains reserved and cannot become active MVP feature.

## 6 Emergency Disable

Can be disabled quickly:

- POS API.
- Store Agent.
- printer output.
- platform payment.
- preorder request.
- Mini Kiosk.
- waiting registration.

Emergency disable must create audit event.

Emergency disable does not erase existing sessions.

Recovery queue must show affected items.

## 7 Rollback Principles

- rollback does not delete audit history.
- rollback creates a new config change event.
- sessions created under old config remain traceable.
- admin must see config version if relevant.

## 8 Open Decisions

- approval SLA.
- multi-store batch approval.
- support operator approval authority.
- legal/tax reviewer role.
- device validation checklist depth.

## 9 Current Status

Status: active admin console governance design.


