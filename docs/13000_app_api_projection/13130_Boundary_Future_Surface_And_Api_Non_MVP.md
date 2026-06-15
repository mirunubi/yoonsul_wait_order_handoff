# 13130_Boundary_Future_Surface_And_Api_Non_MVP

## 1 Purpose

Future surfaces and API groups must not become MVP active APIs accidentally.

This document aligns `15000`, `26000`, `28000`, and `22060` with `13000` projection.

This document is projection boundary only.
It does not approve future endpoint implementation or product runtime.

## 2 Future Surface/API Families

| future family | conceptual meaning |
| --- | --- |
| active point balance surface future | Point balance display; not MVP. |
| wallet surface future | Wallet balance display; not MVP. |
| coupon redemption API future | Coupon redemption path; not MVP. |
| external membership bridge API future | External membership bridge; not MVP. |
| analytics dashboard API future | Analytics dashboard data; not MVP runtime. |
| analytics-to-action recommendation API future | Recommendation API per `26050`; not execution. |
| CRM/ad targeting API future | CRM/ad runtime; not MVP. |
| platform payment API future | Platform payment path; not default MVP. |
| cross-tenant benchmark API future | Benchmark insight API; not export authority. |
| Franchise OS handoff API future | Franchise OS recommendation; not runtime mutation. |

## 3 Non-MVP Rules

- no point ledger API in MVP.
- no wallet API in MVP.
- no coupon redemption API in MVP.
- no external membership bridge API in MVP.
- no analytics-to-action API in MVP.
- no CRM/ad runtime API in MVP.
- no platform payment API by default.
- no Franchise OS handoff API in MVP.
- no cross-tenant benchmark API in MVP.

## 4 Projection Rules

- placeholder surface does not equal active runtime.
- future API group does not equal endpoint approval.
- recommendation does not equal runtime mutation.
- benefit preview does not equal redemption.
- benchmark insight does not equal export authority.
- payment future flag does not equal payment API.

## 5 Cross-References

- `docs/15000_membership_loyalty/15030_Boundary_Point_Ledger_And_Wallet_Non_Implementation.md`
- `docs/26000_analytics_reporting_bi/26050_Analytics_Insight_To_Action_Governance.md`
- `docs/28000_future_expansion/28000_Readme_Future_Expansion.md`
- `docs/03000_saas_runtime/03060_Boundary_Runtime_Profile_Non_MVP_And_Future_Flag.md`
- `docs/22000_implementation_planning/22060_MVP_Non_Goal_And_Future_Expansion_Boundary.md`

## 6 Open Decisions

- whether future placeholders appear in admin UI.
- whether future API groups appear in docs.
- whether tenant waitlist exists.
- whether non-MVP API groups are hidden entirely.
- whether separate future product domain is needed.

## 7 Current Status

Status: active future surface and API non-MVP boundary. Not implementation approval.
