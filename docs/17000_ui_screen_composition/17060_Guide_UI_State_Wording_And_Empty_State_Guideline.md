# 17060_Guide_UI_State_Wording_And_Empty_State_Guideline

## 1 Purpose

Shared UI wording must preserve operational truth.

Empty/error/recovery states must not mislead customer or staff.

This document complements `docs/13000_app_api_projection/13070_Matrix_Customer_Surface_State_Wording.md` and applies across customer webapp, Mini Kiosk, store console, admin console, and support console surfaces.

This document is UI screen composition projection only.
It does not define UI implementation, translation delivery, notification delivery, or production copy.

## 2 Shared State Wording Families

| state family | safe meaning | primary surfaces |
| --- | --- | --- |
| loading | Data or action is in progress; no confirmation implied. | All surfaces. |
| no data | No records exist in current scope; not an error by default. | Store, admin, support consoles. |
| waiting | Customer or session is waiting for next operational step. | Customer webapp, store console. |
| review pending | Store staff must review before confirmation. | Customer, Mini Kiosk, store console. |
| staff confirmed | Staff reviewed and confirmed handoff; not necessarily POS confirmed. | Customer, store console. |
| POS confirmed | POS success response or validated POS-side confirmation exists. | Store console, limited customer visibility. |
| print pending | Print attempt queued or in progress. | Store console, Mini Kiosk customer hint. |
| print failed | Print did not complete; staff must check candidate. | Customer, store console. |
| POS API failed | POS confirmation is not complete; staff must recover. | Store console, limited customer hint. |
| manual recovery required | Staff assistance is required before continuation. | All operational surfaces. |
| support review required | Support or approval workflow is required. | Admin, support consoles. |
| cancelled | Customer or store cancellation is visible. | Customer, store console. |
| expired | Session or candidate expired per policy. | Customer, store console. |
| degraded mode | Store or integration is busy or partially unavailable. | All surfaces. |

## 3 Empty State Guidance

| empty context | recommended primary message | recommended action |
| --- | --- | --- |
| no waiting sessions | No active waiting sessions in this store view. | Refresh or adjust filters. |
| no order candidates | No order candidates awaiting review. | Monitor for new submissions. |
| no recovery items | No open recovery items. | Continue normal operations. |
| no printer events | No recent printer events in selected window. | Check integration profile if unexpected. |
| no audit events visible | No audit events match current scope and filter. | Adjust filter or request broader audit authority. |
| no export requests | No export requests in current scope. | Submit export request through workflow if needed. |

Empty states must not imply success, failure, or confirmation of unrelated operational events.

## 4 Error / Recovery Guidance

| scenario | safe customer wording | safe staff wording |
| --- | --- | --- |
| printer failure | "The printed ticket may not have completed. Staff will check your order candidate." | "Print failed. Review candidate before retry." |
| POS API failure | "POS confirmation is not complete. Staff will review and recover the order." | "POS API failed. Do not mark success until response confirms." |
| staff review delay | "Staff review is taking longer than usual. Please wait or ask staff for help." | "Review queue delayed. Prioritize or request support." |
| duplicate candidate suspected | "A similar order candidate may already exist. Staff will check before confirmation." | "Duplicate suspected. Review before confirm or retry." |
| manual POS input needed | "Staff will enter your order into the store POS." | "Manual POS input required. Mark when completed." |
| customer called but not arrived | "The store has called you. Please follow the arrival guidance or ask staff for help." | "Customer called but not arrived. Follow no-show policy." |

Recovery wording must not hide uncertainty as completed order.

## 5 Forbidden Wording

- do not say completed before confirmation.
- do not say paid when store POS payment is pending.
- do not say POS confirmed when only printer output exists.
- do not say resolved when item is dismissed only.
- do not say support approved when support only assisted.

Additional forbidden wording:

- do not say point/coupon applied in MVP.
- do not say table assigned unless store confirmed.
- do not imply payment settlement, membership benefit, or kitchen execution without real authority.

## 6 Membership / Loyalty UI Wording Cross-Reference

Future membership/coupon/point UI wording must follow `docs/15000_membership_loyalty/`.

- do not show active point balance, wallet, or redemption UI in MVP.
- coupon/benefit wording must avoid implying POS discount or settlement.

See `docs/15000_membership_loyalty/15050_Membership_Admin_And_UI_Reserved_Surface.md`.

## 7 Integration Boundary Wording Cross-Reference

Integration-related UI wording must follow `docs/11000_integration_boundary/11020_Boundary_POS_API_Integration_Truth.md` through `docs/11000_integration_boundary/11060_Boundary_Integration_Failure_Retry_And_Recovery.md`.

- do not show POS confirmed when only printer output exists.
- do not show paid unless payment authority exists.
- retry/recovery UI must not imply success before confirmation.

## 7.1 UI Composition Consolidation Cross-Reference

- Integration wording is refined in `docs/17000_ui_screen_composition/17090_Integration_Status_UI_Wording_Model.md`.
- Button/status badge governance is defined in `docs/17000_ui_screen_composition/17100_Governance_Action_Button_And_Status_Badge.md`.
- Customer/Mini Kiosk wording is consolidated in `docs/17000_ui_screen_composition/17110_Customer_MiniKiosk_State_Wording_Consolidation.md`.
- Admin/support recovery wording is consolidated in `docs/17000_ui_screen_composition/17120_Admin_Support_UI_Authority_And_Recovery_Model.md`.
- Future UI non-MVP boundary is defined in `docs/17000_ui_screen_composition/17130_Boundary_Future_UI_Surface_Non_MVP.md`.

## 8 Cross-References

- `docs/11000_integration_boundary/11020_Boundary_POS_API_Integration_Truth.md`
- `docs/13000_app_api_projection/13070_Matrix_Customer_Surface_State_Wording.md`
- `docs/15000_membership_loyalty/15010_Boundary_Membership_Loyalty_Product.md`
- `docs/09000_data_model_state_machine/09020_Handoff_State_Machine.md`
- `docs/09000_data_model_state_machine/09040_State_And_Event_Ownership_Model.md`
- `docs/17000_ui_screen_composition/17010_Customer_Webapp_UI_Composition.md`
- `docs/17000_ui_screen_composition/17030_Store_Console_UI_Composition.md`

## 9 Open Decisions

- Korean/English/Japanese/Chinese wording set.
- icon usage.
- color/severity mapping.
- legal review of customer wording.
- brand tone vs operational precision.

## 10 Current Status

Status: active shared UI state wording guideline. No implementation approval.
