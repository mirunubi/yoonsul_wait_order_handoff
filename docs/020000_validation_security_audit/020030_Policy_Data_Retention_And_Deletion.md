# 020030_Policy_Data_Retention_And_Deletion

## 1 Purpose

Retention must be defined before production.

SaaS operational data should not be kept forever by default.

Different data categories require different retention rules.

Retention must distinguish operational recovery needs, audit needs, tenant reporting, legal/tax needs, and future analytics.

This document is conceptual only.
It does not define SQL, migrations, app code, Supabase functions, storage implementation, or final legal retention periods.

## 2 Retention Classes

Conceptual retention classes:

- `transient_session_data`: short-lived customer/session data used for active browsing, waiting, Mini Kiosk, and handoff continuity.
- `active_operational_data`: waiting, handoff, order candidate, staff confirmation, and store runtime data needed for current operations.
- `recovery_support_data`: support, recovery, failed integration, and operational issue data needed to resolve incidents.
- `admin_config_history`: package, feature flag, integration profile, payment profile, and admin configuration change history.
- `audit_event_data`: audit-visible records of access, change, recovery, export, and support actions.
- `tenant_report_data`: tenant or store reporting data prepared for operational review.
- `customer_identifiable_data`: data that can identify or contact a customer directly or indirectly.
- `anonymized_analytics_data`: analytics material that no longer identifies an individual under the approved process.
- `pseudonymized_analytics_data`: analytics material where identifiers are replaced but re-identification remains controlled.
- `future_franchise_intelligence_data`: future sanitized intelligence material for Franchise OS or franchise analytics contexts.
- `export_log_data`: export request, approval, delivery, recipient, and audit accountability records.

## 3 Suggested Initial Retention Direction

This section is non-binding and conceptual.

- transient session data should have short retention.
- operational handoff data should have medium retention for recovery and reporting.
- audit and configuration history should have longer retention.
- customer-identifiable data should be minimized and time-limited.
- anonymized aggregate data can be retained longer if policy permits.
- pseudonymized data must remain controlled and policy-bound.
- export logs should be retained for accountability.

Exact retention periods are not final in this document.
Exact periods require legal and policy review before production.

## 4 Deletion / Archival Rules

- deletion must not break audit integrity.
- deleted customer-identifiable data should not erase required audit trail.
- archive must preserve context without unnecessary personal data.
- recovery records must distinguish resolved operational issue from financial truth.
- tenant offboarding must define export, deletion, and archival process.
- deletion should preserve distinction between order candidate, staff-confirmed order, POS API attempt, and POS-confirmed result where required for accountability.
- archival should avoid keeping raw customer session data where aggregate or masked context is enough.

## 5 Tenant Offboarding

Tenant offboarding should define:

- export request.
- admin approval.
- data package scope.
- deletion request.
- retention hold if legal or audit review is required.
- final archival or deletion confirmation.
- audit event.

Offboarding must not transfer another tenant's data.

Offboarding export must not silently include future Franchise OS, CRM, ad, AI, membership, point, or third-party data unless separately approved.

## 6 Non-MVP Boundary

The current documentation does not include:

- automated retention engine.
- physical storage implementation.
- production deletion job.
- data lake retention policy.

## 7 Open Decisions

- exact retention periods.
- tenant offboarding SLA.
- customer deletion request handling.
- retention hold authority.
- anonymized dataset retention.
- backup deletion behavior.

## 8 Current Status

Status: active retention and deletion governance draft.
