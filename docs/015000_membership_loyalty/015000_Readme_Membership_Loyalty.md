# 015000_Readme_Membership_Loyalty

## 1 Purpose

This folder is the active documentation domain for membership, loyalty, coupon, stamp, and point boundaries under the `15000~16999` band.

Membership may become an optional SaaS module later for stores without their own membership system.

This domain is boundary/governance only.
It is not active MVP runtime.

## 2 In Scope

- Future membership and loyalty product boundaries.
- Lightweight coupon and stamp future models.
- Point ledger and wallet non-implementation boundaries.
- External membership bridge future boundaries.
- Reserved admin and customer UI surface inventories.

## 3 Document List

| document | description |
| --- | --- |
| `docs/015000_membership_loyalty/015010_Boundary_Membership_Loyalty_Product.md` | Product boundary for optional SaaS loyalty models and explicit active MVP exclusions. |
| `docs/015000_membership_loyalty/015020_Lightweight_Coupon_And_Stamp_Future_Model.md` | Future lightweight coupon and stamp model with proof, risk, and non-MVP boundaries. |
| `docs/015000_membership_loyalty/015030_Boundary_Point_Ledger_And_Wallet_Non_Implementation.md` | Explicit forbidden boundary for point ledger, wallet, redemption, and exchange until separately approved. |
| `docs/015000_membership_loyalty/015040_Boundary_External_Membership_Bridge_Future.md` | Future boundary for external membership, white-label loyalty, and group point bridge. |
| `docs/015000_membership_loyalty/015050_Membership_Admin_And_UI_Reserved_Surface.md` | Reserved future admin and customer UI surfaces without active runtime. |

## 4 Relationship To 28000

Existing `docs/028000_future_expansion/028020_Membership_Loyalty_Point_Future_Model.md` and `docs/028000_future_expansion/028030_Boundary_Point_Bridge_And_Exchange_Future.md` remain historical/future context in `28000` until a separate migration is approved.

`15000` is now the primary governance domain for membership/loyalty boundaries.

## 5 Out Of Scope

- Active MVP point ledger, wallet, prepaid, coupon runtime, and external membership integration.
- Implementation code, SQL, migrations, payment/settlement logic, and CRM automation.

## 6 Current Status

Status: initial membership/loyalty boundary detail wave. Active documentation domain. Not active MVP runtime. No implementation approval.
