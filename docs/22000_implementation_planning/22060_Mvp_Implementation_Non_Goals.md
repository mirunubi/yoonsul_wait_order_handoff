# 22060 Mvp Implementation Non Goals

## 1 Purpose

MVP implementation must be constrained.

This document prevents scope creep.

This document is planning boundary only.
It does not approve MVP implementation or define implementation tasks.

## 2 MVP Non-Goals

MVP implementation must not include by default:

- no platform payment by default.
- no point ledger.
- no wallet.
- no coupon redemption engine.
- no external membership bridge.
- no CRM automation.
- no advertising runtime.
- no AI recommendation runtime.
- no Franchise OS ingestion.
- no cross-tenant benchmark product.
- no full POS replacement.
- no printer driver implementation as default.
- no financial truth ownership unless explicitly integrated.

These non-goals align with `docs/15000_membership_loyalty/15030_Point_Ledger_And_Wallet_Non_Implementation_Boundary.md` and `docs/01000_mvp_scope/01010_MVP_Scope.md`.

## 3 Allowed MVP Focus

MVP implementation planning may focus on:

- waiting/session spine.
- menu browsing snapshot.
- order candidate.
- staff review.
- manual POS input marker.
- store console visibility.
- admin package/config visibility.
- integration boundary placeholder.
- audit/recovery envelope.

Allowed focus is handoff and operational visibility.
It is not payment settlement, loyalty ledger, or full OS replacement.

## 4 Future Expansion Cross-Reference

`docs/28000_future_expansion/` documents do not override MVP non-goals.

Data/Ad/CRM/AI, Franchise OS handoff, point bridge, and intelligence feedback loop remain non-MVP unless separately approved.

See `docs/28000_future_expansion/28000_Future_Expansion_Readme.md`.

## 5 Analytics Cross-Reference

Analytics/reporting/BI runtime is not MVP by default.

Future analytics boundaries are defined in `docs/26000_analytics_reporting_bi/`.

Analytics insight must not become runtime mutation.

See `docs/26000_analytics_reporting_bi/26050_Analytics_To_Action_Governance.md`.

## 6 Cross-References

- `docs/01000_mvp_scope/01010_MVP_Scope.md`
- `docs/28000_future_expansion/28000_Future_Expansion_Readme.md`
- `docs/28000_future_expansion/28040_Data_Ad_CRM_AI_Future_Expansion_Model.md`
- `docs/26000_analytics_reporting_bi/26010_Analytics_Product_Boundary.md`
- `docs/15000_membership_loyalty/15010_Membership_Loyalty_Product_Boundary.md`
- `docs/22000_implementation_planning/22010_Implementation_Readiness_Gate.md`
- `docs/22000_implementation_planning/22020_Build_Sequence_And_Phase_Boundary.md`

## 7 Open Decisions

- whether Mini Kiosk ships in MVP.
- whether Store Agent is MVP or optional later.
- whether printer option is MVP or later.
- whether admin console is internal-only first.
- whether anonymous customer session is allowed.

## 8 Current Status

Status: active MVP implementation non-goals. Not implementation approval.
