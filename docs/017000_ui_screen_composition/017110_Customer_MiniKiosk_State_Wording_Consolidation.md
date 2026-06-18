# 017110_Customer_MiniKiosk_State_Wording_Consolidation

## 1 Purpose

Customer and Mini Kiosk surfaces need simple wording that preserves operational truth.

This document consolidates `17010`, `17020`, `13070`, `09090`, and `11000` truth boundaries.

It does not create final copywriting or translations.

This document is UI wording consolidation only.
It does not approve customer-facing copy or multilingual assets.

## 2 Customer/Mini Kiosk State Groups

| state group | UI meaning |
| --- | --- |
| entry | Customer enters store context via QR, NFC, link, or kiosk. |
| language selection | Customer selects display language. |
| waiting registration | Customer registers or joins waiting. |
| waiting status | Customer sees waiting position or status. |
| menu browsing | Customer explores menu without order intent. |
| item detail | Customer views item information. |
| cart/order candidate | Draft order intent; not confirmed. |
| preorder request submitted | Preorder intent submitted; not paid. |
| staff review pending | Store has not yet reviewed or confirmed. |
| staff confirmed | Operational confirmation; not financial truth. |
| called/arrival prompt | Store calls customer or prompts arrival. |
| table/pickup handoff | Handoff to table or pickup context. |
| cancellation/expiry | Flow cancelled or expired. |
| recovery message | Delay or recovery notice without false resolution. |

## 3 Wording Rules

- order candidate is not confirmed order.
- preorder request is not paid order.
- staff review pending must be clear.
- staff confirmed is not financial truth.
- printer sent should not be shown as POS confirmed.
- payment pending is not paid.
- future coupon/point placeholder must not imply active benefit.
- customer wording must remain simple and multilingual-safe.

## 4 Prohibited Customer Wording

- do not say order completed before confirmation.
- do not say paid before payment authority.
- do not say POS confirmed from printer output.
- do not say point earned in MVP.
- do not say coupon redeemed without redemption authority.
- do not say resolved when only dismissed.

## 5 Cross-References

- `docs/17000_ui_screen_composition/017010_Customer_Webapp_UI_Composition.md`
- `docs/17000_ui_screen_composition/017020_Mini_Kiosk_UI_Composition.md`
- `docs/13000_app_api_projection/013070_Matrix_Customer_Surface_State_Wording.md`
- `docs/09000_data_model_state_machine/009090_Order_Candidate_And_Confirmation_State_Refinement.md`
- `docs/11000_integration_boundary/011040_Boundary_Payment_And_Financial_Truth.md`

## 6 Open Decisions

- Korean/English/Japanese/Chinese wording set.
- whether staff-confirmed state is customer-visible.
- whether show-to-staff screen uses customer language or store language.
- whether wait estimate is shown.
- whether customer phone/session identity is required.

## 7 Current Status

Status: active customer Mini Kiosk state wording consolidation. Not implementation approval.
