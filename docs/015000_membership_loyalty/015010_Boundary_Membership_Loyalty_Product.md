# 015010_Boundary_Membership_Loyalty_Product

## 1 Purpose

Membership/loyalty may become an optional SaaS module for stores that do not have their own membership system.

This project may support lightweight loyalty such as visit stamp, coupon, simple benefit, or store-level customer reward.

However, membership/loyalty is not active MVP runtime unless explicitly approved later.

This document is boundary/governance only.
It does not define SQL, migrations, app code, point ledger, wallet, coupon runtime, external membership bridge, or payment/settlement logic.

## 2 Product Boundary

Future optional models:

| model | description | status |
| --- | --- | --- |
| SaaS light loyalty | Platform-managed lightweight loyalty for stores without external membership. | future-reserved |
| store-level stamp/coupon | Store-owned visit stamp or simple coupon without full ledger. | future-reserved |
| white-label loyalty | Tenant-branded loyalty program under tenant policy. | future-reserved |
| external membership bridge | Lookup or forward benefit from tenant/store external membership system. | future-reserved |
| Yoonsul group point future bridge | Future bridge to Yoonsul group point program if separately approved. | future-reserved |
| Full OS loyalty ledger | Full ledger, wallet, redemption, and reconciliation under OS-controlled runtime. | future-reserved |

These models are optional SaaS expansion paths.
They are not active MVP runtime modes.

## 3 Active MVP Boundary

- no active point ledger in MVP.
- no wallet in MVP.
- no point redemption in MVP.
- no coupon settlement in MVP.
- no cross-store point exchange in MVP.
- no external membership bridge in MVP.
- no customer membership account requirement in MVP.

Active MVP remains focused on waiting, Mini Kiosk, order candidate, staff confirmation, Store Agent/printer, and POS API boundary.

## 4 Use Cases Reserved for Future

- visit count coupon.
- same-store repeat visit reward.
- lightweight coupon issue.
- stamp-style reward.
- Mini Kiosk returning customer hint.
- waiting/order conversion coupon.
- store-specific benefit.
- tenant-level white-label loyalty.
- future group point integration.

These use cases may be explored in design but must not be treated as active runtime without separate approval.

## 5 Forbidden Claims

- benefit preview does not equal redemption.
- coupon display does not equal settlement.
- point placeholder does not equal active point ledger.
- visit count does not equal verified membership status.
- external membership bridge does not exist until separately approved.

Additional forbidden claims:

- stamp progress does not equal earned benefit until policy and proof rules are satisfied.
- coupon availability does not equal POS discount application.
- loyalty hint does not equal customer identity verification.

## 6 Cross-References

- `docs/28000_future_expansion/028020_Membership_Loyalty_Point_Future_Model.md`
- `docs/28000_future_expansion/028030_Boundary_Point_Bridge_And_Exchange_Future.md`
- `docs/03000_saas_runtime/003010_Tenant_Store_Runtime_And_Package_Model.md`
- `docs/15000_membership_loyalty/015020_Lightweight_Coupon_And_Stamp_Future_Model.md`
- `docs/15000_membership_loyalty/015030_Boundary_Point_Ledger_And_Wallet_Non_Implementation.md`

## 7 Open Decisions

- whether loyalty is per store, per tenant, or platform-level.
- whether phone number is required.
- whether anonymous stamp is allowed.
- whether coupon is POS-backed or SaaS-only.
- whether external membership bridge is allowed.
- whether Yoonsul group point is separate product.

## 8 Current Status

Status: active membership/loyalty product boundary. Not active MVP runtime. No implementation approval.
