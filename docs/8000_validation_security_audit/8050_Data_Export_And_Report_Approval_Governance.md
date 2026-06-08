# 8050 Data Export And Report Approval Governance

## 1 Purpose

Export is higher risk than view.

Reports may contain operational, customer, tenant, or future intelligence data.

Export must be role-limited, scoped, justified, and audited.

This document is conceptual only.
It does not define SQL, migrations, app code, Supabase functions, export implementation, report implementation, or final legal policy.

## 2 Report / Export Categories

Conceptual report and export categories:

- store operational report.
- tenant operational report.
- order candidate report.
- waiting conversion report.
- Mini Kiosk language/menu report.
- recovery incident report.
- audit event report.
- support access report.
- tenant offboarding export.
- anonymized analytics dataset.
- pseudonymized analytics dataset.
- future Franchise OS intelligence export.

## 3 Export Approval Principles

- admin visibility does not equal export authority.
- customer-identifiable export requires stricter approval.
- cross-tenant export is prohibited by default.
- aggregated or anonymized export is preferred for analytics.
- export purpose must be recorded.
- export scope must be recorded.
- export recipient must be recorded.
- export must create audit event.
- export should preserve data meaning and avoid treating order candidates as confirmed sales.

## 4 Export Risk Levels

- LOW: aggregated store report.
- MEDIUM: tenant-scoped operational report.
- HIGH: customer-identifiable data export.
- RESTRICTED: cross-entity, franchise, or third-party export.

## 5 Export Lifecycle

Conceptual lifecycle:

- `REQUESTED`.
- `REVIEW_PENDING`.
- `APPROVED`.
- `REJECTED`.
- `GENERATED`.
- `DELIVERED`.
- `EXPIRED`.
- `REVOKED`.
- `AUDITED`.

## 6 Forbidden Export Assumptions

- raw customer data must not be exported by default.
- support role cannot export without approval.
- Franchise OS export is not automatic.
- analytics export must not imply ad targeting permission.
- CSV availability does not equal policy approval.
- tenant offboarding export must not include another tenant's data.

## 7 Open Decisions

- supported formats.
- export expiration.
- download logging.
- export encryption.
- recipient verification.
- offboarding export package structure.

## 8 Current Status

Status: active export and report approval governance draft.
