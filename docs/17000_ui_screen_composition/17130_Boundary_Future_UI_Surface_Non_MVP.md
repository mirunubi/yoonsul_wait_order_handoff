# 17130_Boundary_Future_UI_Surface_Non_MVP

## 1 Purpose

Future UI placeholders must not become active runtime by accident.

This document aligns `15000`, `26000`, `28000`, and `13130`.

It does not create UI implementation.

This document is UI boundary governance only.
It does not approve future UI components or design assets.

## 2 Future UI Surface Families

| future surface | conceptual meaning |
| --- | --- |
| point balance surface future | Point balance display; not MVP. |
| wallet surface future | Wallet balance display; not MVP. |
| coupon redemption surface future | Coupon redemption path; not MVP. |
| external membership connect surface future | External membership bridge UI; not MVP. |
| analytics dashboard future | Analytics dashboard UI; not MVP runtime. |
| analytics recommendation surface future | Recommendation display per `26050`; not execution. |
| CRM/ad targeting surface future | CRM/ad runtime UI; not MVP. |
| platform payment surface future | Platform payment UI; not default MVP. |
| cross-tenant benchmark surface future | Benchmark insight UI; not export authority. |
| Franchise OS handoff surface future | Franchise OS recommendation UI; not runtime mutation. |

## 3 Non-MVP Rules

- no active point balance UI in MVP.
- no wallet UI in MVP.
- no coupon redemption UI in MVP.
- no external membership bridge UI in MVP.
- no analytics-to-action UI in MVP.
- no CRM/ad targeting UI in MVP.
- no platform payment UI by default.
- no Franchise OS handoff UI in MVP.
- no cross-tenant benchmark UI in MVP.

## 4 Projection Rules

- placeholder does not equal active runtime.
- disabled future card does not equal enabled feature.
- benefit preview does not equal redemption.
- recommendation does not equal runtime mutation.
- analytics dashboard does not create financial truth.
- benchmark insight does not equal export authority.

## 5 Cross-References

- `docs/15000_membership_loyalty/15050_Membership_Admin_And_UI_Reserved_Surface.md`
- `docs/13000_app_api_projection/13130_Boundary_Future_Surface_And_Api_Non_MVP.md`
- `docs/26000_analytics_reporting_bi/26030_Report_And_Dashboard_Boundary.md`
- `docs/28000_future_expansion/28000_Readme_Future_Expansion.md`

## 6 Open Decisions

- whether future cards are hidden entirely.
- whether tenant waitlist UI exists.
- whether future placeholders appear only in platform admin.
- whether membership placeholder appears in customer UI.
- whether analytics preview appears in MVP.

## 7 Current Status

Status: active future UI surface non-MVP boundary. Not implementation approval.
