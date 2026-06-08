# 15020 Lightweight Coupon And Stamp Future Model

## 1 Purpose

Some stores may not need a full membership system but may want simple repeat-visit rewards.

Lightweight coupon/stamp can support store-level retention without becoming full point ledger.

This remains future-reserved.

This document is conceptual boundary only.
It does not define coupon runtime, stamp counter implementation, POS discount integration, settlement logic, or customer wallet.

## 2 Candidate Features

| feature | description |
| --- | --- |
| visit stamp | Increment visit count after permitted proof event. |
| 10th visit coupon | Issue coupon after configured visit threshold. |
| first visit coupon | Issue welcome coupon after first verified visit. |
| waiting conversion coupon | Offer coupon after waiting-to-order conversion event. |
| Mini Kiosk first-use coupon | Offer coupon after first Mini Kiosk session completion. |
| store owner manual coupon | Store owner issues one-off or campaign coupon manually. |
| tenant campaign coupon | Tenant-level campaign coupon for scoped stores. |
| no-show recovery coupon | Service recovery coupon after no-show or dispute resolution. |
| service recovery coupon | Compensation coupon after operational failure recovery. |

All features are future candidates only.

## 3 Authority and Proof

- visit must be tied to permitted session/order evidence.
- order candidate alone is not proof of visit.
- printer output is not proof of purchase.
- POS confirmation or staff confirmation may be needed depending store type.
- coupon issue does not equal coupon redemption.

Proof hierarchy should follow store integration level and policy:

- `STAFF_SCREEN_ONLY`: staff confirmation may be required for visit proof.
- `STORE_AGENT_PRINTER`: printer output does not substitute for purchase proof.
- `POS_API`: POS-confirmed order may support stronger visit proof where policy allows.

## 4 Risk Boundary

- coupon can create financial/settlement implications.
- POS-backed coupon requires POS integration or manual reconciliation.
- SaaS-only coupon must be clearly distinguished from POS discount.
- abuse prevention is required before production.
- customer privacy notice is required before production.

Additional risks:

- duplicate stamp or coupon issuance without audit.
- cross-store coupon misuse without scope controls.
- recovery coupon used as undeclared discount settlement.

## 5 Non-MVP Boundary

- no coupon runtime in MVP.
- no stamp counter implementation.
- no coupon redemption engine.
- no POS discount integration.
- no settlement logic.
- no customer wallet.

## 6 Cross-References

- `docs/15000_membership_loyalty/15010_Membership_Loyalty_Product_Boundary.md`
- `docs/11000_integration_boundary/11010_POS_Payment_Printer_Integration_Boundary.md`
- `docs/13000_app_api_projection/13070_Customer_Surface_State_Wording_Matrix.md`
- `docs/20000_validation_security_audit/20010_SaaS_Data_Capture_And_Governance_Principle.md`

## 7 Open Decisions

- stamp proof source.
- coupon expiration.
- coupon transferability.
- store-level vs tenant-level coupon.
- manual override.
- POS reconciliation model.

## 8 Current Status

Status: future-reserved lightweight coupon and stamp model. No implementation approval.
