# 001050_Boundary_MVP_Package_And_Feature_Flag

## 1 Purpose

Package plans and feature flags define configuration possibility, not implementation approval.

Feature flag visibility must not imply runtime availability.

This document aligns `01000` MVP scope with `docs/03000_saas_runtime/003010_Tenant_Store_Runtime_And_Package_Model.md`.

This document does not approve implementation.

## 2 Package Boundary

| package | scope |
| --- | --- |
| Mini Kiosk Only | Menu browse and order candidate without waiting spine assumption. |
| Waiting + Mini Kiosk | Waiting handoff plus Mini Kiosk-capable customer path. |
| Waiting + Store Agent / Printer | Waiting handoff plus Store Agent/printer integration option. |
| POS API Integrated | POS API attempt path with validation and truth separation. |
| Full OS future package | Future OS-controlled runtime; not generic SaaS MVP default. |

Package names are configuration boundaries only.

## 3 Feature Flag Classes

| class | examples |
| --- | --- |
| waiting flags | waiting registration, call/arrival, handoff visibility. |
| mini kiosk flags | kiosk mode, language selection, show-to-staff assist. |
| store console flags | candidate review, staff confirmation, recovery queue. |
| admin configuration flags | package request, feature request, runtime config visibility. |
| integration visibility flags | Store Agent, printer, POS API status visibility. |
| printer option flags | printer retry eligibility, print failure visibility. |
| POS API option flags | API attempt visibility, manual fallback marker. |
| payment future flags | `payment_by_platform_enabled` and related future payment paths. |
| membership future flags | membership, coupon, point placeholders per `15000`. |
| analytics future flags | reporting/dashboard placeholders per `26000`. |
| support future flags | scoped support session placeholders per `20040`/`24020`. |

## 4 Feature Flag Truth Rules

- feature flag does not equal implementation.
- feature flag enabled does not equal approved high-risk runtime.
- `payment_by_platform_enabled` must default false.
- point ledger flags must not exist as active MVP flags.
- external membership bridge flags must not exist as active MVP flags.
- analytics insight flags must not mutate runtime.
- printer flag does not equal POS sales creation.
- POS API flag does not equal POS integration success.

## 5 Required Approval Rules

- high-risk flags require approval.
- integration flags require validation.
- payment flags require legal/accounting/payment review.
- membership flags require `15000` boundary review.
- analytics flags require `26000` boundary review.
- support flags require `20040`/`24020` boundary review.

## 6 Cross-References

- `docs/03000_saas_runtime/003010_Tenant_Store_Runtime_And_Package_Model.md`
- `docs/01000_mvp_scope/001040_Matrix_MVP_Active_Optional_Future_NonGoal.md`
- `docs/01000_mvp_scope/001060_MVP_Store_Type_Adoption_Sequence.md`
- `docs/22000_implementation_planning/022010_Implementation_Readiness_Gate.md`

## 7 Open Decisions

- package naming.
- initial default package.
- tenant-level vs store-level flags.
- flag audit depth.
- emergency disable rule.
- feature rollout strategy.

## 8 Current Status

Status: active MVP package and feature flag boundary. Not implementation approval.
