# 26000 Analytics Reporting Bi Readme

## 1 Purpose

This folder is the active documentation domain for analytics, reporting, and BI boundaries under the `26000~27999` band.

`yoonsul_wait_order_handoff` may collect valuable SaaS operational signals from waiting, Mini Kiosk, order candidates, staff confirmation, Store Agent, printer, POS API attempts, manual recovery, package plans, and feature flags.

This domain defines future analytics/reporting boundaries only.
It does not create analytics runtime.

It follows `docs/20000_validation_security_audit/` security, audit, privacy, and export governance.

## 2 In Scope

- Analytics product boundary and operational signal vs financial truth distinction.
- Conceptual operational metrics catalog.
- Report and dashboard boundary.
- Cross-tenant benchmark and data sharing boundary.
- Analytics-to-action governance without runtime mutation.

## 3 Document List

| document | description |
| --- | --- |
| `26010_Analytics_Product_Boundary.md` | Analytics product scope, critical distinction rules, and non-MVP boundary. |
| `26020_Operational_Metrics_Catalog.md` | Conceptual metric families and examples; metrics are not SQL queries. |
| `26030_Report_And_Dashboard_Boundary.md` | Future report types and dashboard surface boundary with export governance. |
| `26040_Cross_Tenant_Benchmark_And_Data_Sharing_Boundary.md` | Cross-tenant benchmark prohibited by default; data sharing safety rules. |
| `26050_Analytics_To_Action_Governance.md` | Insight-to-action path; analytics insight does not equal execution. |

## 4 Out Of Scope

- Analytics runtime, BI dashboards, data warehouse, SQL, BI code, and AI recommendation engine.
- CRM/ad runtime and unapproved secondary use of operational data.

## 5 Current Status

Status: initial analytics/reporting/BI boundary detail wave. Active documentation domain. Not analytics runtime approval.
