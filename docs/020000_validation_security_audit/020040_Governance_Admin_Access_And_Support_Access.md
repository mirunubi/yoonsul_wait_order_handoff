# 020040_Governance_Admin_Access_And_Support_Access

## 1 Purpose

Admin visibility must not become unrestricted data access.

Support access must be scoped, time-bounded, and audited.

Role-based access must respect tenant, store, and context boundaries.

This document is conceptual only.
It does not define SQL, migrations, app code, Supabase functions, authentication implementation, or final permission schema.

## 2 Access Contexts

Conceptual access contexts:

- `platform_admin`.
- `tenant_admin`.
- `company_admin`.
- `legal_admin`.
- `operating_group_manager`.
- `store_owner`.
- `store_manager`.
- `store_staff`.
- `support_operator`.
- `read_only_auditor`.

## 3 Access Scope Principles

- view authority does not equal mutation authority.
- admin visibility does not equal export authority.
- support access does not equal approval.
- tenant admin cannot see other tenant data.
- store manager sees only assigned store context unless explicitly scoped.
- support operator must use scoped support session.
- sensitive customer details should be masked by default where possible.
- legal, payment, package, integration, and runtime authority must remain separated by role and context.

## 4 Scoped Support Session

A scoped support session should define:

- `requested_by`.
- `approved_by`.
- tenant and store scope.
- reason.
- allowed screens.
- allowed actions.
- start and end time.
- audit trail.
- revocation.

Scoped support sessions should be temporary.

Support access should not become standing access unless a separate policy explicitly allows it.

## 5 Sensitive Data Visibility

Conceptual sensitivity classes:

- low sensitivity operational status: runtime status, queue counts, feature availability, and high-level recovery state.
- medium sensitivity session/order candidate data: waiting session, handoff session, Mini Kiosk session, order candidate, and staff confirmation context.
- high sensitivity customer-identifiable data: customer name, contact, identifier, notes, or behavior that can identify a customer.
- restricted payment-related status: payment profile, POS API result, settlement-relevant visibility, and legal/tax review context.
- future membership/point data reserved: future loyalty, coupon, stamp, wallet, point, or bridge data that is not active MVP runtime.

## 6 Forbidden Access Assumptions

- platform admin does not automatically mean raw customer export.
- support operator cannot silently mutate order state.
- read-only auditor cannot perform recovery action.
- legal admin does not operate store runtime.
- store staff cannot change package or payment profile.
- tenant visibility does not imply cross-tenant visibility.
- report visibility does not imply downloadable export authority.

## 6.1 Security Governance Consolidation Cross-Reference

- Access context/data visibility governance is refined in `docs/20000_validation_security_audit/020080_Governance_Access_Context_And_Data_Visibility.md`.
- Support access/masking/scoped session governance is refined in `docs/20000_validation_security_audit/020090_Governance_Support_Access_Masking_And_Scoped_Session.md`.
- Support access does not equal approval.
- Support visibility does not equal mutation authority.

## 7 Open Decisions

- support access approval depth.
- masking policy.
- break-glass access.
- emergency support model.
- PII field list.
- access review cadence.

## 8 Current Status

Status: active admin and support access governance draft.
