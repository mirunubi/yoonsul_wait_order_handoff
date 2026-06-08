# 26030 Report And Dashboard Boundary

## 1 Purpose

Reports and dashboards may be future SaaS surfaces.

This document defines boundary only and does not create UI/dashboard implementation.

This document is reporting boundary only.
It does not create dashboard UI code, chart implementation, BI tool integration, SQL/report queries, export runtime, or scheduled report jobs.

## 2 Candidate Report Types

| report type | primary audience | truth label required |
| --- | --- | --- |
| store daily operation report | store_owner, store_manager | operational signal |
| tenant weekly operation report | tenant_admin, operating_group_manager | operational signal |
| waiting conversion report | store_owner, store_manager | operational signal |
| Mini Kiosk language/menu report | store_owner, tenant_admin | operational signal |
| order candidate conversion report | store_owner, store_manager | order candidate, not confirmed order |
| staff confirmation delay report | store_manager, store_owner | staff confirmation, not financial truth |
| Store Agent/printer reliability report | store_owner, tenant_admin | integration reliability |
| POS API reliability report | store_owner, tenant_admin | API attempt/outcome, not POS sales truth |
| manual recovery report | store_manager, tenant_admin | recovery lineage |
| package/feature performance report | tenant_admin, platform_admin | configuration correlation |
| support access report | platform_admin, tenant_admin | audited support session |
| export audit report | platform_admin, read_only_auditor | export approval lifecycle |

All report types are future candidates only.

## 3 Dashboard Surface Boundary

- dashboard does not create financial truth.
- dashboard must label operational signal vs POS/payment truth.
- dashboard must respect tenant/store scope.
- customer-identifiable fields must be minimized.
- exports require 20050 governance.
- analytics visibility does not equal export authority.

Additional boundaries:

- dashboard tiles must not imply revenue without POS/payment authority.
- drill-down must not expose cross-tenant data without policy basis.
- scheduled reports require export approval where sensitive data is included.

## 4 Non-Implementation Boundary

- no dashboard UI code.
- no chart implementation.
- no BI tool integration.
- no SQL/report query.
- no export runtime.
- no scheduled report job.

Future dashboard implementation requires separate wave approval after `26010`, `26020`, and `20050` boundaries are satisfied.

## 5 Cross-References

- `docs/07000_admin_console/07040_Admin_Screen_Inventory_And_Navigation_Model.md`
- `docs/20000_validation_security_audit/20050_Data_Export_And_Report_Approval_Governance.md`
- `docs/26000_analytics_reporting_bi/26040_Cross_Tenant_Benchmark_And_Data_Sharing_Boundary.md`
- `docs/13000_app_api_projection/13060_Surface_State_Visibility_And_Authority_Matrix.md`

## 6 Open Decisions

- dashboard user roles.
- tenant vs platform dashboard.
- owner dashboard depth.
- export formats.
- report schedule.
- data refresh cadence.

## 7 Current Status

Status: active report and dashboard boundary. Not implementation approval.
