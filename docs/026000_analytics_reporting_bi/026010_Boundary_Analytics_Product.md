# 026010_Boundary_Analytics_Product

## 1 Purpose

Analytics may become a future SaaS value layer.

Analytics must distinguish operational signals from financial truth.

This document defines product boundary only and does not approve analytics runtime.

This document is analytics/reporting boundary only.
It does not create analytics runtime, dashboards, data warehouse, SQL, BI code, or AI recommendation engine.

## 2 Analytics Scope

Future analytics domains:

| domain | description |
| --- | --- |
| waiting conversion analytics | Waiting registration to order candidate or handoff conversion signals. |
| waiting abandonment analytics | Abandonment, no-show candidate, and cancellation patterns. |
| order candidate completion analytics | Candidate submission, edit, cancel, and staff review outcomes. |
| preorder request analytics | Preorder request volume and review timing. |
| staff confirmation delay analytics | Time from candidate submission to staff confirmation. |
| Mini Kiosk language/menu analytics | Language selection and kiosk session patterns. |
| menu/photo interaction analytics | Menu browse and photo interaction signals. |
| Store Agent reliability analytics | Agent health, validation, and degradation patterns. |
| printer attempt/failure analytics | Print attempt, success, failure, and retry patterns. |
| POS API attempt/success/failure analytics | API attempt and response outcome patterns. |
| manual recovery analytics | Recovery reason, resolution time, and recurrence patterns. |
| package plan performance analytics | Package adoption and operational correlation signals. |
| feature flag performance analytics | Feature flag enablement and operational effect signals. |
| tenant/store operational reports | Scoped operational summaries for tenant and store roles. |

All domains are future-reserved conceptual scope only.

## 3 Critical Distinction Rules

- order candidate does not equal confirmed order.
- preorder request does not equal paid order.
- printer output does not equal POS sales creation.
- POS API attempt does not equal POS success.
- staff confirmation does not equal financial truth.
- operational signal does not equal revenue.
- benefit/coupon preview does not equal redemption.
- analytics insight does not equal runtime mutation.

Analytics must label truth family on every metric and report surface.

## 4 Non-MVP Boundary

- no analytics runtime in MVP.
- no BI dashboard in MVP.
- no cross-tenant benchmark product in MVP.
- no external data warehouse in MVP.
- no AI recommendation runtime in MVP.
- no ad targeting runtime in MVP.
- no CRM automation in MVP.

Operational data capture for handoff may exist in future runtime, but analytics products are not MVP deliverables.

## 5 Cross-References

- `docs/020000_validation_security_audit/020010_Governance_SaaS_Data_Capture_And_Principle.md`
- `docs/020000_validation_security_audit/020050_Governance_Data_Export_And_Report_Approval.md`
- `docs/022000_implementation_planning/022060_Boundary_Mvp_Implementation_Non_Goals.md`
- `docs/026000_analytics_reporting_bi/026020_Index_Operational_Metrics_Catalog.md`
- `docs/026000_analytics_reporting_bi/026050_Governance_Analytics_To_Action.md`

## 6 Open Decisions

- whether analytics is core SaaS or add-on.
- whether store owner sees analytics in MVP.
- whether tenant benchmark is allowed.
- whether analytics uses anonymized/aggregated data only.
- whether analytics belongs to this project or future product.

## 7 Current Status

Status: active analytics product boundary. Not analytics runtime approval.
