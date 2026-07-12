# 026020_Index_Operational_Metrics_Catalog

## 1 Purpose

Metrics must be defined before reports/dashboards.

Metrics are conceptual and not SQL queries.

This document is conceptual metrics catalog only.
It does not define SQL, warehouse schema, dashboard queries, or BI implementation.

## 2 Metric Families

| family | scope |
| --- | --- |
| waiting metrics | Waiting registration, status, call, arrival, abandonment. |
| customer entry/channel metrics | QR, NFC, URL, Mini Kiosk entry patterns. |
| menu browsing metrics | Category, item, photo, and language interaction. |
| order candidate metrics | Create, edit, submit, cancel, review pending. |
| preorder request metrics | Submit, review, confirm, reject patterns. |
| staff confirmation metrics | Review start, confirm, reject, delay. |
| Mini Kiosk metrics | Session start, language, cart, staff assist. |
| Store Agent metrics | Health, validation, degradation events. |
| printer metrics | Attempt, success, failure, retry. |
| POS API metrics | Attempt, success, failure, manual fallback. |
| manual recovery metrics | Open, resolve, dismiss, reason distribution. |
| package plan metrics | Plan assignment, change request, activation. |
| feature flag metrics | Flag enablement by store/tenant scope. |
| support access metrics | Scoped session start, action, revoke. |
| export/report metrics | Export request, approval, download, expiry. |

## 3 Example Metrics

| family | example metrics |
| --- | --- |
| waiting metrics | waiting registration count; waiting abandonment count; waiting-to-order-candidate conversion rate. |
| customer entry/channel metrics | QR entry count; NFC entry count; Mini Kiosk entry count. |
| menu browsing metrics | menu category view count; menu photo interaction rate. |
| order candidate metrics | order candidate submission count; order candidate completion ratio. |
| preorder request metrics | preorder request count; preorder review pending count. |
| staff confirmation metrics | staff confirmation median delay; staff rejection count. |
| Mini Kiosk metrics | Mini Kiosk session count; Mini Kiosk language selection ratio. |
| Store Agent metrics | Store Agent offline event count; validation failure count. |
| printer metrics | printer attempt count; printer failure rate. |
| POS API metrics | POS API attempt count; POS API success rate. |
| manual recovery metrics | manual recovery reason count; recovery resolution median delay. |
| package plan metrics | package plan activation count; package change request count. |
| feature flag metrics | feature flag enabled store count. |
| support access metrics | support session count; support action count. |
| export/report metrics | export request count; export approval count. |

Examples are conceptual definitions only.
They are not approved report queries.

## 4 Metric Truth Boundary

- metric source must be documented.
- metric denominator must be explicit.
- metric cannot combine incompatible truth families.
- financial metrics require POS/payment authority.
- customer-identifiable metrics require privacy review.
- benchmark metrics require tenant/policy basis.

Additional rules:

- order candidate metrics must not be labeled as confirmed-order or revenue metrics.
- printer metrics must not be labeled as POS sales metrics.
- benefit preview metrics must not be labeled as redemption metrics.

## 5 Cross-References

- `docs/026000_analytics_reporting_bi/026010_Boundary_Analytics_Product.md`
- `docs/09000_data_model_state_machine/009040_State_And_Event_Ownership_Model.md`
- `docs/009000_data_model_state_machine/009050_Audit_Recovery_Event_Lineage_Model.md`
- `docs/020000_validation_security_audit/020020_Boundary_Cross_Entity_Data_Sharing_And_Privacy.md`

## 6 Open Decisions

- metric naming convention.
- time bucket standard.
- tenant/store scope.
- minimum sample threshold.
- dashboard priority.
- exportability.

## 7 Current Status

Status: active operational metrics catalog. Conceptual only. Not analytics runtime approval.
