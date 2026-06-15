# 03040_Governance_Package_Plan_And_Feature_Flag_Runtime

## 1 Purpose

Package plans and feature flags are runtime configuration concepts.

They must be governed because they can imply customer/store behavior.

This document aligns with `docs/01000_mvp_scope/01050_Boundary_MVP_Package_And_Feature_Flag.md`.

This document is runtime governance only.
It does not approve implementation or define flag storage schema.

## 2 Package Plans

| package plan | scope |
| --- | --- |
| Mini Kiosk Only | Kiosk/tablet ordering without waiting spine assumption. |
| Waiting + Mini Kiosk | Waiting handoff plus Mini Kiosk customer path. |
| Waiting + Store Agent / Printer | Waiting plus Store Agent/printer integration option. |
| POS API Integrated | POS API attempt path with validation and truth separation. |
| Full OS Future Package | Future OS-controlled package; not generic SaaS MVP default. |

Aligns with `docs/01000_mvp_scope/01060_MVP_Store_Type_Adoption_Sequence.md`.

## 3 Feature Flag Categories

| category | examples |
| --- | --- |
| waiting flags | waiting registration, call/arrival, handoff visibility. |
| Mini Kiosk flags | kiosk mode, language selection, show-to-staff assist. |
| language/menu flags | multilingual menu, photo menu visibility. |
| store console flags | candidate review, staff confirmation, recovery queue. |
| admin console flags | package request, feature request, config visibility. |
| Store Agent flags | agent status visibility, activation request. |
| printer flags | print retry eligibility, print failure visibility. |
| POS API flags | API attempt visibility, manual fallback marker. |
| payment future flags | `payment_by_platform_enabled` and related paths. |
| membership future flags | membership, coupon, point placeholders per `15000`. |
| analytics future flags | reporting/dashboard placeholders per `26000`. |
| support future flags | scoped support session placeholders per `20040`/`24020`. |
| export/report future flags | export request and approval placeholders per `20050`. |

## 4 Runtime Governance Rules

- feature flag does not equal implementation.
- feature flag enabled does not equal approved high-risk runtime.
- high-risk flags require approval.
- flag change must be auditable.
- emergency disable must be allowed for risky runtime.
- platform payment flags default false.
- point ledger/wallet flags are not active MVP flags.
- external membership bridge flags are not active MVP flags.
- analytics-to-action flags must not mutate runtime automatically.

## 5 Cross-References

- `docs/03000_saas_runtime/03010_Tenant_Store_Runtime_And_Package_Model.md`
- `docs/03000_saas_runtime/03050_Governance_Runtime_Profile_Change_And_Audit.md`
- `docs/15000_membership_loyalty/15030_Boundary_Point_Ledger_And_Wallet_Non_Implementation.md`
- `docs/26000_analytics_reporting_bi/26050_Governance_Analytics_To_Action.md`
- `docs/22000_implementation_planning/22010_Implementation_Readiness_Gate.md`

## 6 Open Decisions

- flag naming convention.
- default package.
- tenant-level vs store-level flag scope.
- flag approval workflow.
- rollback behavior.
- emergency disable owner.

## 7 Current Status

Status: active package plan and feature flag runtime governance. Not implementation approval.
