# 28020_Membership_Loyalty_Point_Future_Model

## 1 Purpose

Membership, loyalty, coupon, stamp, and point design is important for SaaS competitiveness.

However, it is not part of the early MVP runtime.

It is reserved under future expansion because it involves ledger, balance, settlement, refund, tax, accounting, external membership, and multi-brand policy complexity.

This document is conceptual only.
It does not define SQL, migrations, app code, payment implementation, wallet implementation, membership integration, or point ledger implementation.

## 2 Future Point Model Candidates

Future candidates:

- `SAAS_LIGHT_LOYALTY`
- `WHITE_LABEL_LOYALTY`
- `YOONSUL_GROUP_POINTS`
- `EXTERNAL_MEMBERSHIP_BRIDGE`
- `FULL_OS_LOYALTY_LEDGER`

These candidates are future-reserved.
They are not active MVP runtime modes.

## 3 Triangular Relationship

Future point relationships may involve:

- SaaS point.
- White-label point.
- Yoonsul group point.

These programs may exchange identity, eligibility, preview, redemption request, reversal request, and reconciliation events in the future.

They must not silently merge balances.

They must not exchange points without explicit bridge rules, settlement rules, and approval.

## 4 Future Concepts

Future concepts:

- `loyalty_program`
- `loyalty_account`
- `loyalty_event`
- `loyalty_balance`
- `loyalty_bridge_rule`
- `loyalty_redemption_request`
- `loyalty_reversal_request`
- `loyalty_reconciliation`

These concepts are not MVP tables or active runtime entities.

## 5 Future Reward Examples

Future reward examples:

- visit count coupon.
- stamp reward.
- signup coupon.
- revisit coupon.
- birthday coupon.
- Mini Kiosk first-use coupon.
- order candidate coupon.
- store-local points.
- tenant-wide points.
- Yoonsul group points.

## 6 Explicit Non-MVP Boundary

- No point ledger in MVP.
- No point balance in MVP.
- No point exchange in MVP.
- No point settlement in MVP.
- No wallet/prepaid in MVP.
- No external membership integration in MVP.
- No Yoonsul group point integration in MVP.
- No automatic coupon/point application in MVP.

## 7 Relationship To 15000

- `docs/15000_membership_loyalty/` is now the active boundary domain for membership/loyalty/coupon/point.
- This `28020` document remains historical/future context only.
- No point ledger, wallet, coupon runtime, stamp runtime, or external bridge is active here.
- Any future activation must follow `docs/15000_membership_loyalty/15010_Boundary_Membership_Loyalty_Product.md`, `docs/15000_membership_loyalty/15030_Boundary_Point_Ledger_And_Wallet_Non_Implementation.md`, `docs/15000_membership_loyalty/15040_Boundary_External_Membership_Bridge_Future.md`, and `docs/22000_implementation_planning/22010_Implementation_Readiness_Gate.md` readiness gates.

## 8 Future Approval Requirements

Future activation requires:

- legal/tax review.
- settlement design.
- refund/reversal rules.
- seller-of-record clarification if payment is involved.
- tenant/store policy design.
- admin approval model.
- audit/reconciliation model.

## 9 Current Status

Status: future-reserved historical/future context. Active boundaries are in `15000`.
