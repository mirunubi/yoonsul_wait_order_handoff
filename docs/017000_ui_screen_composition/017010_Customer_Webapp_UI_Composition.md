# 017010_Customer_Webapp_UI_Composition

## 1 Purpose

Customer webapp UI supports QR/NFC entry, waiting registration, menu browsing, cart/order candidate, preorder request, staff review pending, called/arrival prompts, table/pickup handoff, and recovery messages.

It must match confirmation authority and customer wording rules from `docs/013000_app_api_projection/013070_Matrix_Customer_Surface_State_Wording.md`.

It must not imply POS/order/payment confirmation unless the correct authority exists.

This document is UI screen composition projection only.
It does not define UI components, routing, API endpoints, database schema, payment integration, POS integration, or production customer app behavior.

## 2 Screen Groups

### 2.1 Entry / Store Landing

| field | composition |
| --- | --- |
| primary information | Store name, supported modes (waiting handoff, Mini Kiosk, multilingual), runtime availability, language shortcut. |
| primary action | Start waiting, open menu, continue existing session. |
| secondary action | Choose language, view store guidance, request staff help. |
| visible state | Store context loaded, mode available or degraded, session resume available. |
| prohibited wording | Do not say payment, POS order, membership, or point benefit is active by default. |
| privacy note | Collect minimum identifiable data; show privacy notice before production capture. |

### 2.2 Language Selection

| field | composition |
| --- | --- |
| primary information | Supported languages, fallback language, current selection. |
| primary action | Select language and continue. |
| secondary action | Continue with default language. |
| visible state | Language list, selected language highlight. |
| prohibited wording | Do not imply AI translation quality unless approved. |
| privacy note | Language choice may become future analytics material; do not expose admin or cross-store data. |

### 2.3 Waiting Registration

| field | composition |
| --- | --- |
| primary information | Waiting availability, required fields, estimated wait guidance if available. |
| primary action | Submit waiting request. |
| secondary action | Skip waiting and browse menu only, cancel. |
| visible state | Registration form, validation hints, submission pending. |
| prohibited wording | Do not say seat is guaranteed. |
| privacy note | Collect only fields required for waiting handoff. |

### 2.4 Waiting Status

| field | composition |
| --- | --- |
| primary information | Registered, confirmed, called, arrived, no-show candidate, cancelled, or expired state. |
| primary action | Check status, browse menu while waiting. |
| secondary action | Cancel where allowed, request staff help. |
| visible state | Current waiting state, call/arrival prompt when applicable. |
| prohibited wording | Do not imply order is confirmed just because waiting exists. |
| privacy note | Customer sees only own waiting session. |

### 2.5 Menu Browsing

| field | composition |
| --- | --- |
| primary information | Menu categories, photos, availability, price display, language display. |
| primary action | Browse items, open item detail, add to cart. |
| secondary action | Change language, return to waiting status. |
| visible state | Menu snapshot, sold-out or unavailable markers. |
| prohibited wording | Do not imply menu interest equals purchase. |
| privacy note | Menu interaction is customer session scoped only. |

### 2.6 Menu Item Detail

| field | composition |
| --- | --- |
| primary information | Item name, description, photo, options, availability, price display. |
| primary action | Select options, quantity, note, add to cart. |
| secondary action | Return to category, remove from consideration. |
| visible state | Option groups, required/optional markers, estimated line total. |
| prohibited wording | Do not imply item is reserved until staff confirmation. |
| privacy note | Notes must not request unnecessary personal data. |

### 2.7 Cart / Order Candidate

| field | composition |
| --- | --- |
| primary information | Cart items, options, notes, estimated total, review status. |
| primary action | Edit cart, submit order candidate. |
| secondary action | Cancel cart, request staff help. |
| visible state | Cart contents, candidate-not-confirmed indicator. |
| prohibited wording | Do not display "order completed" before proper confirmation. |
| privacy note | Cart is session scoped; do not show other customers' data. |

### 2.8 Preorder Request Confirmation

| field | composition |
| --- | --- |
| primary information | Submitted preorder request or order candidate summary. |
| primary action | Review summary, wait for staff review. |
| secondary action | Edit if allowed, cancel request. |
| visible state | Submitted state, staff review pending indicator. |
| prohibited wording | Do not say POS-confirmed order. |
| privacy note | Confirmation screen shows only customer-owned session data. |

### 2.9 Staff Review Pending

| field | composition |
| --- | --- |
| primary information | Staff review pending, delayed, or recovery required state. |
| primary action | Wait, follow store guidance. |
| secondary action | Request help, cancel if allowed. |
| visible state | Review pending badge, delay or recovery hint when applicable. |
| prohibited wording | Do not say preparation started unless store confirms. |
| privacy note | Do not expose staff-internal audit or queue details. |

### 2.10 Called / Arrival Prompt

| field | composition |
| --- | --- |
| primary information | Called, arrival requested, near-store, or no-show candidate state. |
| primary action | Mark arrival where allowed, follow arrival guidance. |
| secondary action | Request staff help, view order candidate summary. |
| visible state | Call state, arrival instructions, handoff readiness hint. |
| prohibited wording | Do not guarantee seating without staff action. |
| privacy note | Arrival action applies only to own waiting session. |

### 2.11 Table Or Pickup Handoff

| field | composition |
| --- | --- |
| primary information | Table number, pickup mode, handoff ready, staff confirmation state. |
| primary action | Confirm visibility, review order candidate. |
| secondary action | Request help, update handoff note if allowed. |
| visible state | Table or pickup assignment, staff confirmation progress. |
| prohibited wording | Do not imply POS/payment completion. |
| privacy note | Table assignment visible only after store confirmation. |

### 2.12 Customer Notification

| field | composition |
| --- | --- |
| primary information | Order, handoff, delay, ready, cancelled, or recovery notification state. |
| primary action | Acknowledge, follow store guidance. |
| secondary action | Request help if available. |
| visible state | Notification message, related session state. |
| prohibited wording | Do not say fulfilled order unless store process supports it. |
| privacy note | Notifications must not expose other customers or admin data. |

### 2.13 Cancellation / No-Show Guidance

| field | composition |
| --- | --- |
| primary information | Cancelled, no-show candidate, expired, or staff assistance required state. |
| primary action | Cancel, restart, contact staff, follow recovery path. |
| secondary action | View prior session summary if allowed. |
| visible state | Terminal or recovery-needed state with next-step guidance. |
| prohibited wording | Do not blame customer or imply financial penalty without policy. |
| privacy note | Explain state without exposing internal dispute labels. |

### 2.14 Recovery Message

| field | composition |
| --- | --- |
| primary information | Manual recovery required, menu unavailable, duplicate suspected, integration failed, or staff correction needed. |
| primary action | Request staff help, wait for staff action. |
| secondary action | Edit, cancel, or restart where allowed. |
| visible state | Recovery reason, uncertainty preserved, next action guidance. |
| prohibited wording | Do not hide operational uncertainty as completed order. |
| privacy note | Recovery screen must not expose audit internals or support session details. |

## 3 Customer Wording Rules

- order candidate is not confirmed order.
- preorder request is not paid order.
- staff review pending must be clear before any confirmation wording.
- POS-confirmed wording only after proper POS/API or staff confirmation authority exists.
- printer output must not be shown as POS confirmation.
- future membership/point must not appear as active MVP function.

Customer wording must distinguish order candidate, staff-confirmed order, POS-confirmed order, and paid preorder per `13070`.

## 4 Cross-References

- `docs/013000_app_api_projection/013020_Customer_Webapp_Projection.md`
- `docs/013000_app_api_projection/013070_Matrix_Customer_Surface_State_Wording.md`
- `docs/005000_customer_handoff_and_implementation_readiness/005000_Readme_Customer_Handoff_And_Implementation_Readiness.md`
- `docs/017000_ui_screen_composition/017060_Guide_UI_State_Wording_And_Empty_State_Guideline.md`

## 5 Open Decisions

- anonymous vs phone-based session.
- initial language set.
- customer notification channel.
- photo menu minimum.
- no-show/cancellation wording.

## 6 Current Status

Status: active customer webapp UI composition projection. No implementation approval.
