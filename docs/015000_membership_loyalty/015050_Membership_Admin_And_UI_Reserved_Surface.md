# 015050_Membership_Admin_And_UI_Reserved_Surface

## 1 Purpose

Future membership may need admin and customer UI surfaces.

This document reserves surfaces only.

It does not create UI implementation or active membership runtime.

This document complements `docs/17000_ui_screen_composition/` and `docs/07000_admin_console/` without activating runtime.

## 2 Future Customer Surfaces

| surface | purpose | MVP status |
| --- | --- | --- |
| membership status placeholder | Reserved label for future membership tier or status. | not active |
| coupon list | Show available coupons without redemption engine. | not active |
| stamp progress | Show visit stamp progress without counter runtime. | not active |
| benefit preview | Show benefit eligibility preview only. | not active |
| coupon use guide | Explain how to use coupon at store. | not active |
| recovery coupon notice | Show service recovery coupon notice after approved recovery. | not active |
| external membership connect prompt | Prompt to connect external membership when bridge approved. | not active |

## 3 Future Store/Admin Surfaces

| surface | purpose | MVP status |
| --- | --- | --- |
| coupon issue request | Request coupon issue through approval workflow. | not active |
| coupon campaign setup | Configure tenant or store campaign boundaries. | not active |
| stamp policy setup | Configure stamp proof and threshold policy. | not active |
| benefit usage review | Review benefit preview and redemption requests. | not active |
| manual recovery coupon request | Request recovery coupon after operational incident. | not active |
| external bridge status | Show external membership bridge health and scope. | not active |
| export/report view | Governed export of loyalty-related data where approved. | not active |

Admin placeholder navigation may reference these surfaces but must not expose active ledger, wallet, or bridge runtime in MVP.

## 4 UI Wording Rules

- benefit preview does not equal redemption.
- coupon available does not equal POS discount.
- point placeholder does not equal point balance.
- external membership connect does not equal data sharing consent until approved.

Additional wording rules:

- stamp progress does not equal earned reward until proof rules satisfied.
- coupon issued does not equal coupon redeemed.
- membership hint does not equal verified membership account.

Cross-reference: `docs/13000_app_api_projection/013070_Matrix_Customer_Surface_State_Wording.md` and `docs/17000_ui_screen_composition/017060_Guide_UI_State_Wording_And_Empty_State_Guideline.md`.

## 5 Non-MVP Boundary

- no active membership UI in MVP.
- no active point balance screen.
- no active coupon redemption screen.
- no wallet.
- no membership admin runtime.
- no bridge status runtime.

Placeholders, if visible, must be clearly marked as future-reserved and must not collect membership account data in MVP.

## 6 Cross-References

- `docs/07000_admin_console/007040_Admin_Screen_Inventory_And_Navigation_Model.md`
- `docs/17000_ui_screen_composition/017010_Customer_Webapp_UI_Composition.md`
- `docs/17000_ui_screen_composition/017040_Admin_Console_UI_Composition.md`
- `docs/15000_membership_loyalty/015010_Boundary_Membership_Loyalty_Product.md`

## 7 Open Decisions

- whether placeholders are visible in MVP.
- whether membership belongs in customer webapp or separate app.
- whether store owner can issue coupon.
- whether support can assist coupon recovery.
- whether export is allowed.

## 8 Current Status

Status: future-reserved admin and UI surface inventory. No implementation approval.
