# 17020 Mini Kiosk Ui Composition

## 1 Purpose

Mini Kiosk UI supports store-assisted or customer-operated tablet/QR ordering without assuming waiting flow.

It is useful for foreign visitors, non-face-to-face ordering, and stores without physical kiosks.

It must remain lightweight and must not imply payment/order completion unless confirmed.

This document is UI screen composition projection only.
It does not define UI components, routing, API endpoints, tablet lock implementation, or production kiosk behavior.

## 2 Screen Groups

### 2.1 Kiosk Start / Store Landing

| field | composition |
| --- | --- |
| primary information | Store name, Mini Kiosk mode indicator, language shortcut, staff assistance notice. |
| customer action | Start ordering, choose language, request staff help. |
| staff handoff point | Staff may initiate session or unlock tablet. |
| confirmation wording | Use "start order candidate" or "browse menu," not "place order." |
| forbidden wording | Do not say payment, POS order, or membership is active. |

### 2.2 Language Selection

| field | composition |
| --- | --- |
| primary information | Supported languages, fallback language. |
| customer action | Select language and continue. |
| staff handoff point | Staff may set default language for store tablet. |
| confirmation wording | Language choice only; no order confirmation implied. |
| forbidden wording | Do not imply AI translation quality unless approved. |

### 2.3 Menu Category

| field | composition |
| --- | --- |
| primary information | Category list, availability markers, photo thumbnails. |
| customer action | Open category, browse items. |
| staff handoff point | Staff may guide category selection for visitors. |
| confirmation wording | Browsing only. |
| forbidden wording | Do not imply category selection equals purchase. |

### 2.4 Menu Item Detail

| field | composition |
| --- | --- |
| primary information | Item name, description, photo, options, availability, price display. |
| customer action | Select options, quantity, note, add to cart. |
| staff handoff point | Staff may assist option selection. |
| confirmation wording | "Add to cart" or "add to order candidate." |
| forbidden wording | Do not imply item is reserved until staff confirmation. |

### 2.5 Option Selection

| field | composition |
| --- | --- |
| primary information | Required and optional option groups, validation hints. |
| customer action | Complete required options, confirm selection. |
| staff handoff point | Staff may explain options for foreign visitors. |
| confirmation wording | Option selection only. |
| forbidden wording | Do not say options are confirmed order. |

### 2.6 Cart / Order Candidate

| field | composition |
| --- | --- |
| primary information | Cart items, options, notes, estimated total, review status. |
| customer action | Edit cart, submit order candidate. |
| staff handoff point | Staff reviews cart before submission if store policy requires. |
| confirmation wording | "Submit order candidate for staff review." |
| forbidden wording | Do not display "order completed" before proper confirmation. |

### 2.7 Staff-Assisted Confirmation

| field | composition |
| --- | --- |
| primary information | Order candidate summary, staff review state, next step guidance. |
| customer action | Wait, show screen to staff, request help. |
| staff handoff point | Staff confirms or rejects candidate on store console. |
| confirmation wording | "Staff review pending" until staff action. |
| forbidden wording | Do not say POS-confirmed or paid order. |

### 2.8 Show-To-Staff Screen

| field | composition |
| --- | --- |
| primary information | Large readable order candidate summary, session identifier, language indicator. |
| customer action | Present screen to staff. |
| staff handoff point | Primary staff interaction surface for visitor-assisted mode. |
| confirmation wording | "Please show this screen to staff." |
| forbidden wording | Do not say order is complete on this screen. |

### 2.9 Printer / Staff Review Pending

| field | composition |
| --- | --- |
| primary information | Staff review pending, printed ticket pending, delay or recovery hint. |
| customer action | Wait, request help. |
| staff handoff point | Staff checks printer, POS, or manual input status. |
| confirmation wording | "Printed ticket pending" does not mean POS confirmed. |
| forbidden wording | Printer output must not be shown as POS confirmation. |

### 2.10 Recovery / Unclear Order Message

| field | composition |
| --- | --- |
| primary information | Manual recovery required, duplicate suspected, integration failed, or unclear order state. |
| customer action | Request staff help, cancel session if allowed. |
| staff handoff point | Staff resolves on store console. |
| confirmation wording | Preserve uncertainty; use recovery-required wording. |
| forbidden wording | Do not hide uncertainty as completed order. |

## 3 Multilingual Notes

- translated wording must preserve operational/legal meaning.
- simple wording preferred.
- avoid implying payment/order completion.
- show-to-staff pattern may be needed for visitor-assisted mode.
- language selection should not become membership or identity flow in MVP.

Menu translation must not change order/payment authority meaning per `13070`.

## 4 Cross-References

- `docs/13000_app_api_projection/13010_App_Surface_And_Channel_Projection.md`
- `docs/13000_app_api_projection/13020_Customer_Webapp_Projection.md`
- `docs/13000_app_api_projection/13070_Customer_Surface_State_Wording_Matrix.md`
- `docs/17000_ui_screen_composition/17010_Customer_Webapp_UI_Composition.md`
- `docs/17000_ui_screen_composition/17060_UI_State_Wording_And_Empty_State_Guideline.md`

## 5 Open Decisions

- tablet lock mode.
- whether Mini Kiosk shares customer webapp shell.
- language order.
- offline/degraded handling.
- staff intervention button.

## 6 Current Status

Status: active Mini Kiosk UI composition projection. No implementation approval.
