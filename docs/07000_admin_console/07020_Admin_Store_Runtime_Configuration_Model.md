# 07020 Admin Store Runtime Configuration Model

## 1 Purpose

Store runtime configuration determines what each store can actually use.

Package plan is the commercial adoption model.

Feature flags are explicit runtime switches.

High-risk functions must not be enabled silently.

This document is conceptual only.
It does not define SQL, migrations, app code, Supabase functions, final permission schema, or UI implementation.

## 2 Package Plan Management

Package plans align with `docs/03000_saas_runtime/03010_Tenant_Store_Runtime_And_Package_Model.md`.

### 2.1 MINI_KIOSK_ONLY

- package name: `MINI_KIOSK_ONLY`.
- target store type: stores needing multilingual/photo menu and order candidate support without waiting.
- enabled feature summary: Mini Kiosk, multilingual menu, photo menu, cart, order candidate, staff confirmation.
- disabled feature summary: waiting, POS API, platform payment, active membership/coupon/points.
- required validation: menu content and language readiness.
- customer wording mode: order candidate, preorder request, staff review required.
- staff responsibility: review and manually enter POS when needed.
- risk note: must not imply automatic order completion.

### 2.2 WAITING_MINI_KIOSK

- package name: `WAITING_MINI_KIOSK`.
- target store type: stores with waiting and table turnover pressure.
- enabled feature summary: waiting, Mini Kiosk, multilingual/photo menu, cart, preorder request, staff confirmation.
- disabled feature summary: POS API unless separately enabled, platform payment, active membership/coupon/points.
- required validation: waiting flow and menu content readiness.
- customer wording mode: preorder request, order candidate, handoff pending.
- staff responsibility: call customer, assign table/pickup context, confirm order candidate.
- risk note: no-show and table-change recovery must be visible.

### 2.3 WAITING_STORE_AGENT_PRINTER

- package name: `WAITING_STORE_AGENT_PRINTER`.
- target store type: stores needing optional ticket output or Store Agent support without POS API.
- enabled feature summary: waiting, Mini Kiosk, Store Agent option, printer output option, audit, manual recovery.
- disabled feature summary: automatic POS sales creation, platform payment unless separately approved.
- required validation: Store Agent runtime validation and printer device test.
- customer wording mode: preorder request, staff-confirmed order, handoff pending.
- staff responsibility: check printed ticket and reconcile POS entry.
- risk note: duplicate, missing, and failed-print safeguards are required.

### 2.4 POS_API_INTEGRATED

- package name: `POS_API_INTEGRATED`.
- target store type: stores with validated POS order API.
- enabled feature summary: POS API, order number mapping, staff confirmation, audit, fallback/recovery.
- disabled feature summary: platform payment unless separately enabled, active membership/coupon/points.
- required validation: POS integration validation.
- customer wording mode: staff-confirmed order, POS-confirmed order after POS response.
- staff responsibility: monitor API results and recover failures.
- risk note: POS API enabled does not imply platform payment.

### 2.5 FULL_OS

- package name: `FULL_OS`.
- target store type: stores where POS, KDS, membership, CMS, Agent, and Audit are controlled or deeply coordinated.
- enabled feature summary: broad OS-controlled operation where explicitly approved.
- disabled feature summary: no high-risk feature is enabled by package name alone.
- required validation: full runtime, legal, payment, integration, and audit validation.
- customer wording mode: staff-confirmed, POS-confirmed, or paid preorder only when configured.
- staff responsibility: operate within configured authority and recovery rules.
- risk note: not the default MVP path.

## 3 Feature Flag Management

Feature flags:

- `waiting_enabled`
- `mini_kiosk_enabled`
- `multilingual_menu_enabled`
- `photo_menu_enabled`
- `cart_enabled`
- `order_candidate_enabled`
- `preorder_request_enabled`
- `staff_confirmation_required`
- `store_agent_enabled`
- `printer_output_enabled`
- `pos_api_enabled`
- `payment_by_platform_enabled`
- `payment_by_store_pos_required`
- `audit_required`
- `manual_recovery_enabled`

Membership/coupon/point flags are future-reserved and must not be active MVP switches.

Feature flag changes must be audited.

`payment_by_platform_enabled` default must be false.

`payment_by_store_pos_required` default should be true for early MVP.

## 4 Integration Profile Management

### 4.1 NONE

- admin visibility: store has no active integration.
- validation required: none beyond display readiness.
- staff responsibility: operate existing store systems independently.
- forbidden claim: system-mediated order handoff or POS creation.

### 4.2 STAFF_SCREEN_ONLY

- admin visibility: order candidates visible in staff/admin screen.
- validation required: staff workflow validation.
- staff responsibility: review and manually enter POS when needed.
- forbidden claim: automatic POS creation.

### 4.3 STORE_AGENT_ONLY

- admin visibility: Store Agent status and receipt visibility.
- validation required: Store Agent runtime validation.
- staff responsibility: confirm operational outcome.
- forbidden claim: POS sales creation.

### 4.4 STORE_AGENT_PRINTER

- admin visibility: Store Agent and printer status.
- validation required: device test and failed-print recovery test.
- staff responsibility: check print output and reconcile POS entry.
- forbidden claim: printer output equals POS sales creation.

### 4.5 POS_API

- admin visibility: POS API status, order number mapping, failures.
- validation required: POS integration validation.
- staff responsibility: monitor and recover failed API events.
- forbidden claim: platform payment is enabled.

### 4.6 FULL_OS_CONTROLLED

- admin visibility: controlled OS surfaces and recovery/audit status.
- validation required: full runtime validation.
- staff responsibility: follow configured authority and recovery rules.
- forbidden claim: bypassing explicit feature flags or approvals.

## 5 Payment Profile Management

Payment profiles:

- `STORE_POS_PAYMENT_DEFAULT`
- `PLATFORM_PAYMENT_OPTIONAL_FUTURE`
- `FULL_OS_PAYMENT_CONTROLLED`

Store POS payment is early default.

Platform payment is future/advanced, not active MVP default.

Payment profile must be independent from POS API profile.

## 6 Change Control

- who can request change: store owner, store manager, operating group manager, tenant admin, support operator, or platform admin depending on context.
- who can approve change: role with matching authority and required validation.
- validation before activation: package, integration, payment, printer, Store Agent, and language validations as applicable.
- audit event required: every runtime setting change must append audit evidence.
- rollback / disable rule: high-risk flags must have a disable path and rollback record.

## 7 SaaS Runtime Cross-Reference

Admin store runtime configuration must follow `docs/03000_saas_runtime/03030_Store_Runtime_Profile_Model.md`, `docs/03000_saas_runtime/03040_Package_Plan_And_Feature_Flag_Runtime_Governance.md`, and `docs/03000_saas_runtime/03050_Runtime_Profile_Change_And_Audit_Governance.md`.

Admin visibility does not equal activation authority.

Feature flag change does not equal approval.

## 7.1 Admin Console Consolidation Cross-Reference

- Runtime profile configuration governance is defined in `docs/07000_admin_console/07080_Admin_Runtime_Profile_Configuration_Governance.md`.
- Feature flag approval/emergency disable is defined in `docs/07000_admin_console/07090_Admin_Feature_Flag_Approval_And_Emergency_Disable_Model.md`.
- Runtime profile change/audit must align with `docs/03000_saas_runtime/03050_Runtime_Profile_Change_And_Audit_Governance.md`.
- Admin visibility does not equal activation authority.

## 8 Open Decisions

- feature flag UI granularity.
- package downgrade behavior.
- emergency disable.
- batch changes across stores.
- default settings per package.

## 9 Current Status

Status: active admin console governance design.



