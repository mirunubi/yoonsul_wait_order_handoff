# 007010_Admin_Console_Context_And_Role_Model

## 1 Purpose

Admin Console manages SaaS runtime configuration and operational visibility.

It is not a POS.
It is not a payment settlement console.
It is not a membership/point ledger console.

It controls package, feature, integration, payment profile visibility, and operational recovery.

This document is conceptual only.
It does not define SQL, migrations, app code, Supabase functions, final permission schema, or UI implementation.

## 2 Context Axes

Admin Console uses separate but related context axes:

- `tenant`
- `company`
- `legal_entity`
- `operating_group`
- `store`

Definitions:

- `tenant` = SaaS customer/contract boundary.
- `company` = operating company or brand operating entity.
- `legal_entity` = tax/contract/settlement legal entity.
- `operating_group` = operational grouping such as region, direct-operated group, franchise group, tourist-zone group.
- `store` = actual operating store.

`company`, `legal_entity`, and `operating_group` are not always a strict parent-child chain.

`operating_group` is operational.

`legal_entity` is legal/tax/settlement.

`store` is where runtime settings actually apply.

## 3 Admin Role Types

### 3.1 platform_admin

Can view:

- tenant/package/integration/payment profile visibility.
- store runtime status.
- audit and recovery status.

Can request:

- package entitlement setup.
- support escalation.

Can approve:

- package entitlement configuration when policy allows.
- platform-level configuration change.

Must not control:

- silent order state mutation.
- payment activation without legal/tax approval.
- membership/point active ledger behavior.

### 3.2 tenant_admin

Can view:

- tenant-level stores.
- package plan.
- feature entitlement.
- operational summaries.

Can request:

- package changes.
- store runtime configuration changes.
- integration activation.

Can approve:

- tenant-level settings that do not require platform, legal, or integration validation.

Must not control:

- POS API activation without validation.
- platform payment activation.
- point ledger or loyalty bridge activation.

### 3.3 company_admin

Can view:

- stores and operating groups under the company context.
- company-level operational summaries.

Can request:

- store package or feature changes for company-operated stores.

Can approve:

- company operational policy changes when tenant policy allows.

Must not control:

- legal settlement identity.
- platform payment authority.
- POS API activation without validation.

### 3.4 legal_admin

Can view:

- legal/tax/settlement-relevant profile visibility.
- payment profile requests.

Can request:

- payment policy review.
- legal entity correction.

Can approve:

- legal/tax prerequisites for future payment profile activation.

Must not control:

- operational order state.
- store runtime settings unrelated to legal/tax/settlement.

### 3.5 operating_group_manager

Can view:

- stores within an operating group.
- operational status and recovery queue.

Can request:

- store-level support.
- package or feature changes for grouped stores.

Can approve:

- operating actions delegated by tenant policy.

Must not control:

- tenant contract.
- legal entity.
- platform payment.

### 3.6 store_owner

Can view:

- own store runtime.
- order candidates and handoff sessions.
- staff actions and recovery status.

Can request:

- feature changes.
- package upgrade or downgrade.
- printer or Store Agent activation.

Can approve:

- store operational settings allowed by tenant policy.

Must not control:

- platform payment activation.
- POS API activation without validation.
- membership/point active runtime.

### 3.7 store_manager

Can view:

- waiting sessions.
- order candidates.
- handoff sessions.
- Store Agent/printer/POS API visibility.

Can request:

- manual recovery.
- support assistance.
- staff-facing correction.

Can approve:

- staff confirmation and store-side operational recovery where policy allows.

Must not control:

- package plan.
- platform payment.
- POS API activation.
- feature entitlement.

### 3.8 store_staff

Can view:

- assigned store operational queue.
- order candidates requiring review.
- handoff and recovery prompts.

Can request:

- manager review.
- manual recovery escalation.

Can approve:

- staff confirmation only when store policy allows.

Must not control:

- package, feature flag, payment profile, integration profile, or audit policy.

### 3.9 support_operator

Can view:

- support-scoped tenant/store context.
- operational recovery status.
- audit trail required for support.

Can request:

- recovery action from store or tenant admin.
- escalation.

Can approve:

- support actions explicitly delegated by platform policy.

Must not control:

- silent mutation of order state.
- payment profile.
- POS API activation.
- customer-facing state correction without audit.

### 3.10 read_only_auditor

Can view:

- audit logs.
- runtime setting changes.
- recovery event history.

Can request:

- audit clarification.

Can approve:

- nothing by default.

Must not control:

- runtime settings.
- order state.
- payment, integration, package, or feature settings.

## 4 Authority Principles

- view authority does not equal mutation authority.
- package plan change requires higher approval.
- payment profile change requires legal/tax approval.
- POS API activation requires integration validation.
- printer activation requires device test.
- Store Agent activation requires runtime validation.
- membership/point remains future-reserved.

## 5 Role Boundary Examples

- `store_manager` can view order candidates but cannot enable platform payment.
- `tenant_admin` can request package change but may not enable POS API without validation.
- `support_operator` can assist recovery but cannot silently mutate order state.
- `platform_admin` can configure package entitlement but must audit all changes.

## 6 Open Decisions

- whether `company_admin` and `tenant_admin` are separate in MVP.
- whether `legal_admin` exists in early MVP.
- whether `support_operator` can impersonate store view.
- whether `store_owner` can control feature flags directly.
- approval workflow depth.

## 7 Current Status

Status: active admin console governance design.
