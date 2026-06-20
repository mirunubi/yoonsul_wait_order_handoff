# 001040_Matrix_MVP_Active_Optional_Future_NonGoal.md

## 1 Purpose

MVP scope must be separated from optional packages, future-reserved concepts, and non-goals.

This document consolidates boundaries after the `15000`, `17000`, `22000`, `24000`, `26000`, and `28000` domains were opened.

This document does not approve implementation.

## 2 Classification Definitions

| classification | meaning |
| --- | --- |
| Active MVP | Core handoff spine expected in first MVP unless a separate decision defers a specific item. |
| MVP Optional | May ship in MVP as optional capability with explicit scope and risk review. |
| Post-MVP Optional Package | Optional SaaS package after MVP proof; not default runtime. |
| Future-Reserved | Documented future concept only; no active runtime. |
| Explicit Non-Goal | Must not be implemented in MVP by default. |
| Forbidden Until Separately Approved | Requires dedicated boundary review, readiness gates, and explicit approval. |

## 3 Active MVP Candidates

- tenant/store runtime context.
- package plan visibility.
- feature flag visibility.
- customer QR/NFC entry.
- waiting/session spine.
- menu browsing snapshot.
- cart/order candidate.
- preorder request boundary.
- staff review/confirmation boundary.
- store console visibility.
- manual POS input marker.
- admin runtime configuration visibility.
- audit/recovery envelope.

## 4 MVP Optional Candidates

- Mini Kiosk basic mode.
- multilingual menu display.
- staff-assisted show-to-staff screen.
- Store Agent status visibility.
- printer option visibility.
- POS API attempt visibility.
- basic manual recovery queue.

## 5 Post-MVP Optional Package Candidates

- Store Agent/printer operation.
- POS API integrated package.
- analytics/reporting view.
- support console.
- advanced admin approval workflow.
- lightweight coupon/stamp.
- tenant-level white-label loyalty.

## 6 Future-Reserved

- point ledger.
- wallet.
- external membership bridge.
- cross-store/cross-tenant point exchange.
- analytics-to-action recommendation.
- AI/CRM/ad runtime.
- cross-tenant benchmark product.
- Franchise OS handoff.
- Franchise intelligence feedback loop.

## 7 Explicit Non-Goals

- platform payment by default.
- point ledger in MVP.
- wallet in MVP.
- coupon redemption engine in MVP.
- CRM automation in MVP.
- AI recommendation runtime in MVP.
- ad targeting runtime in MVP.
- Franchise OS ingestion in MVP.
- full POS replacement.
- financial truth ownership without explicit POS/payment authority.

## 8 Cross-References

- `docs/22000_implementation_planning/022060_Boundary_Mvp_Implementation_Non_Goals.md`
- `docs/15000_membership_loyalty/015010_Boundary_Membership_Loyalty_Product.md`
- `docs/26000_analytics_reporting_bi/026010_Boundary_Analytics_Product.md`
- `docs/28000_future_expansion/028000_Readme_Future_Expansion.md`
- `docs/01000_mvp_scope/001050_Boundary_MVP_Package_And_Feature_Flag.md`
- `docs/01000_mvp_scope/001060_MVP_Store_Type_Adoption_Sequence.md`

## 9 Open Decisions

- Mini Kiosk MVP inclusion.
- Store Agent MVP inclusion.
- printer option timing.
- POS API integration timing.
- support console timing.
- customer identity depth.
- analytics visibility timing.

## 10 Current Status

Status: active MVP active/optional/future/non-goal matrix. Not implementation approval.
