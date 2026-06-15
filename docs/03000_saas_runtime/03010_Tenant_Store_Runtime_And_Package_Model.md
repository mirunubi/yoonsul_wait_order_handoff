# 03010_Tenant_Store_Runtime_And_Package_Model

## 1 Purpose

`yoonsul_wait_order_handoff` is SaaS-oriented.

One tenant may operate one or more stores.
Each store may use different package modes.
Store runtime must determine which features are enabled.

This document is conceptual only.
It does not define SQL, migrations, app code, Supabase functions, payment implementation, POS implementation, or package billing implementation.

## 2 Core Runtime Entities

Conceptual runtime entities:

- `tenant`
- `tenant_account`
- `tenant_user`
- `store`
- `store_runtime`
- `store_package_plan`
- `store_feature_flags`
- `store_integration_profile`
- `store_payment_profile`
- `store_language_profile`
- `store_menu_profile`
- `store_agent_profile`
- `store_audit_profile`

## 3 Tenant Principle

Tenant is the SaaS customer boundary.

Tenant may be:

- single independent restaurant.
- small restaurant group.
- franchise operator.
- Yoonsul-operated internal store group.

Tenant is not the same as store.
Tenant is not necessarily the legal seller of food.
Tenant can have multiple stores.

Billing, admin access, package contract, and feature entitlement are tenant-level concerns.

## 4 Store Principle

Store is the operational unit.

Waiting, Mini Kiosk, staff confirmation, Store Agent, printer, POS API, and payment mode are store-level settings.

Two stores under the same tenant may use different package modes.

## 5 Store Runtime Principle

Store runtime is the active operating mode of a store.

It determines:

- whether waiting is enabled.
- whether Mini Kiosk is enabled.
- whether staff confirmation is required.
- whether Store Agent is enabled.
- whether printer option is enabled.
- whether POS API integration is enabled.
- whether our payment mode is enabled.
- which languages are exposed.
- whether manual recovery is required.

Store runtime must not imply POS/payment authority unless explicitly configured.

## 6 Package Plan Model

### 6.1 MINI_KIOSK_ONLY

Target store type:

- Type 0 or Type 1 stores that need multilingual menu and order candidate support without waiting.

Enabled features:

- Mini Kiosk.
- multilingual menu.
- photo menu.
- cart.
- order candidate.
- staff confirmation.

Disabled features:

- waiting management.
- POS API order creation.
- platform payment.
- membership, coupon, and points; future-reserved only.

Integration assumptions:

- staff screen only by default.
- manual POS entry when POS exists.

Customer-facing wording:

- order candidate.
- preorder request.
- staff review required.

Staff responsibility:

- review customer intent.
- confirm or reject.
- manually enter POS when needed.

Risk notes:

- must not imply automatic order completion.
- language content quality affects customer understanding.

### 6.2 WAITING_MINI_KIOSK

Target store type:

- Type 1 stores with waiting and strong peak-time table turnover pressure.

Enabled features:

- waiting.
- Mini Kiosk.
- multilingual menu.
- photo menu.
- cart.
- order candidate.
- preorder request.
- staff confirmation.

Disabled features:

- POS API order creation unless separately enabled.
- platform payment.
- membership, coupon, and points; future-reserved only.

Integration assumptions:

- staff/admin handoff screen.
- manual POS input by default.

Customer-facing wording:

- preorder request.
- order candidate.
- handoff pending.

Staff responsibility:

- call customer.
- assign table or pickup context.
- confirm order candidate.
- manually enter POS when needed.

Risk notes:

- no-show and table-change recovery must be visible.

### 6.3 WAITING_STORE_AGENT_PRINTER

Target store type:

- Type 1B stores that want optional ticket output or local Store Agent support without POS API.

Enabled features:

- waiting.
- Mini Kiosk.
- order candidate.
- staff confirmation.
- Store Agent option.
- printer output option.
- audit required.
- manual recovery.

Disabled features:

- automatic POS sales creation.
- platform payment unless separately approved.

Integration assumptions:

- Store Agent or printer gateway may receive order candidate.
- existing POS still requires manual or after input.

Customer-facing wording:

- preorder request.
- staff-confirmed order.
- handoff pending.

Staff responsibility:

- confirm order candidate.
- check printed ticket.
- reconcile POS entry and printed/order candidate records.

Risk notes:

- duplicate, missing, and failed-print safeguards are required.
- reconciliation report is required.

### 6.4 POS_API_INTEGRATED

Target store type:

- Type 2 stores whose POS provides a reliable external order API.

Enabled features:

- POS API integration.
- order number mapping.
- staff confirmation.
- audit required.
- fallback/manual recovery.

Disabled features:

- platform payment unless separately enabled.
- membership, coupon, and points; future-reserved only.

Integration assumptions:

- Store Order Gateway may create POS order.
- POS handles kitchen printer or KDS when supported.

Customer-facing wording:

- staff-confirmed order.
- POS-confirmed order after POS response.

Staff responsibility:

- monitor API result and failures.
- recover failed or duplicate order attempts.

Risk notes:

- POS capability must be validated per store.
- POS API enabled does not imply platform payment.

### 6.5 FULL_OS

Target store type:

- Type 4 stores where POS, KDS, membership, CMS, Agent, and Audit are controlled or deeply coordinated.

Enabled features:

- waiting.
- Mini Kiosk.
- POS/KDS coordination.
- payment where approved.
- membership only when a future-reserved loyalty model is separately approved.
- CMS.
- Agent.
- audit.
- AI analysis where approved.

Disabled features:

- none by package name alone; each high-risk feature still requires explicit flag and approval.

Integration assumptions:

- broader operating stack can be controlled.

Customer-facing wording:

- staff-confirmed order.
- POS-confirmed order.
- paid preorder only if platform payment is enabled and approved.

Staff responsibility:

- operate within configured OS authority and recovery rules.

Risk notes:

- highest operational scope.
- must not be treated as the default MVP path.

## 7 Feature Flag Model

Conceptual feature flags:

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
- `membership_enabled` future-reserved only.
- `coupon_enabled` future-reserved only.
- `points_enabled` future-reserved only.
- `audit_required`
- `manual_recovery_enabled`

Feature flags must be explicit.

No package should silently imply high-risk features such as platform payment or POS auto-sync.

Payment and POS authority must be separately enabled.

Membership, coupon, and points flags are future-reserved and must not be treated as active MVP runtime flags.

## 8 Store Integration Profile

### 8.1 NONE

Our system may show store menu or planning context only.

It must not claim order handoff, POS creation, printer output, or payment.

Staff must operate existing store systems independently.

Audit/reconciliation needs are minimal.

### 8.2 STAFF_SCREEN_ONLY

Our system may capture order candidate and show it to staff.

It must not claim automatic POS creation or printer output.

Staff must confirm and manually enter POS when needed.

Audit should record staff confirmation and manual recovery.

### 8.3 STORE_AGENT_ONLY

Our system may send order candidate context to a Store Agent for local visibility or fallback.

It must not claim POS sales creation.

Staff must still confirm operational outcome.

Audit and reconciliation should record agent receipt and staff action.

### 8.4 STORE_AGENT_PRINTER

Our system may send order candidate to Store Agent or printer gateway for optional ticket output.

It must not claim POS sales creation.

Staff must check printed ticket and POS entry.

Audit and reconciliation must cover duplicate, missing, failed print, and manual recovery cases.

### 8.5 POS_API

Our system may create POS order through validated POS API.

It must not claim platform payment unless payment profile separately enables it.

Staff must monitor API result and recover failures.

Audit and reconciliation must preserve POS order number mapping and failure result.

### 8.6 FULL_OS_CONTROLLED

Our system may coordinate broader OS-controlled flows where POS, KDS, membership, CMS, Agent, and Audit are controlled or deeply integrated.

It must not bypass explicit feature flags or legal/tax approvals.

Staff must follow configured recovery and override rules.

Audit and reconciliation are required.

## 9 Payment Profile

### 9.1 STORE_POS_PAYMENT_DEFAULT

Store POS payment is the early default.

The store receives payment through its existing POS or store process.

### 9.2 PLATFORM_PAYMENT_OPTIONAL_FUTURE

Platform payment is an advanced option only.

It requires legal, tax, settlement, receipt, refund, seller-of-record, VAT reporting, and POS reflection design.

### 9.3 FULL_OS_PAYMENT_CONTROLLED

Full OS payment control applies only where the operating stack and legal/payment responsibilities are explicitly approved.

Payment profile must be independent from waiting and Mini Kiosk features.

## 10 Customer Wording By Runtime

Allowed wording candidates:

- order candidate.
- preorder request.
- staff-confirmed order.
- POS-confirmed order.
- paid preorder.
- handoff pending.
- staff review required.

A store without POS API or platform payment must not display "order completed" before staff confirmation.

## 11 Runtime Change Rules

- Package changes require tenant/admin approval.
- Enabling payment requires separate legal/tax approval.
- Enabling POS API requires integration validation.
- Enabling printer requires device test.
- Enabling multilingual menu requires menu content review.
- Store runtime changes must be audited.

MVP scope cross-reference:

- MVP package/feature flag boundary is defined in `docs/01000_mvp_scope/01050_Boundary_MVP_Package_And_Feature_Flag.md`.
- Store-type adoption sequence is defined in `docs/01000_mvp_scope/01060_MVP_Store_Type_Adoption_Sequence.md`.
- Feature flags do not equal implementation approval.

## 12 Membership / Point Future Reservation

Membership/loyalty optional SaaS boundary is defined in `docs/15000_membership_loyalty/`.

Primary governance:

- `docs/15000_membership_loyalty/15010_Boundary_Membership_Loyalty_Product.md`
- `docs/15000_membership_loyalty/15030_Boundary_Point_Ledger_And_Wallet_Non_Implementation.md`
- `docs/15000_membership_loyalty/15040_Boundary_External_Membership_Bridge_Future.md`

Historical/future context also remains in `docs/28000_future_expansion/28020_Membership_Loyalty_Point_Future_Model.md` and `docs/28000_future_expansion/28030_Boundary_Point_Bridge_And_Exchange_Future.md` until a separate migration is approved.

Active package flags must not enable point ledger, wallet, or external membership bridge by default.

Any future loyalty feature flag must follow `15030` and `15040` boundaries.

Current package plan must not silently enable:

- membership.
- points.
- coupon redemption.
- wallet.
- point exchange.

Early MVP focuses on:

- waiting.
- Mini Kiosk.
- order candidate.
- staff confirmation.
- Store Agent/printer.
- POS API boundary.
- store POS payment.

## 13 Open Decisions

- Tenant billing unit.
- store-level subscription pricing.
- whether one tenant can operate multiple brands.
- language pack pricing.
- printer rental/support policy.
- Store Agent support policy.
- legal seller-of-record for platform payment mode.
- package downgrade behavior.
- data retention per tenant/store.

## 14 Current Status

Status: active SaaS runtime design.

## 15 Admin Console Cross-Reference

Admin Console role/context handling is defined in `docs/07000_admin_console/07010_Admin_Console_Context_And_Role_Model.md`.

Store runtime configuration handling is defined in `docs/07000_admin_console/07020_Admin_Store_Runtime_Configuration_Model.md`.

Operational monitoring/recovery visibility is defined in `docs/07000_admin_console/07030_Admin_Operational_Monitoring_And_Recovery_Model.md`.

Admin screen inventory is defined in `docs/07000_admin_console/07040_Admin_Screen_Inventory_And_Navigation_Model.md`.

Admin approval workflow is defined in `docs/07000_admin_console/07050_Admin_Approval_Workflow_Model.md`.

Admin audit/recovery queue governance is defined in `docs/07000_admin_console/07060_Governance_Admin_Audit_And_Recovery_Queue.md`.

## 16 SaaS Runtime Consolidation Cross-Reference

- Context axes are expanded in `docs/03000_saas_runtime/03020_Tenant_Company_Legal_Operating_Group_Context_Model.md`.
- Store runtime profiles are defined in `docs/03000_saas_runtime/03030_Store_Runtime_Profile_Model.md`.
- Package/feature flag runtime governance is defined in `docs/03000_saas_runtime/03040_Governance_Package_Plan_And_Feature_Flag_Runtime.md`.
- Runtime profile change/audit governance is defined in `docs/03000_saas_runtime/03050_Governance_Runtime_Profile_Change_And_Audit.md`.
- Non-MVP future runtime profiles are defined in `docs/03000_saas_runtime/03060_Boundary_Runtime_Profile_Non_MVP_And_Future_Flag.md`.
