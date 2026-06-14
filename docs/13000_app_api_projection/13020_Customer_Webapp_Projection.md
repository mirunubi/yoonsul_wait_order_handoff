# 13020 Customer Webapp Projection

## 1 Purpose

Customer webapp supports waiting, menu browsing, cart/order candidate, Mini Kiosk, multilingual flow, and customer notification.

It must not falsely imply POS-confirmed order when store confirmation is still required.

This document is projection only.
It does not define UI components, routing, API implementation, auth implementation, database schema, payment integration, POS integration, or production customer app behavior.

## 2 Customer Modes

Conceptual customer modes:

- waiting handoff mode.
- Mini Kiosk only mode.
- multilingual visitor mode.
- staff-assisted mode.
- pickup/table mode.
- future membership/point placeholder mode.

Future membership/point placeholder mode is not active MVP runtime.

## 3 Customer Screens

| screen | purpose | visible state | allowed customer action | forbidden wording |
| --- | --- | --- | --- | --- |
| entry / store landing | Load store context from QR, NFC, link, or Mini Kiosk entry. | Store name, supported modes, language option, runtime availability. | Start waiting, open menu, choose language, continue existing session. | Do not say payment, POS order, or membership is active by default. |
| language selection | Let customer choose display language. | Supported languages and fallback language. | Select language or continue with default. | Do not imply AI translation quality unless approved. |
| waiting registration | Capture lightweight waiting information. | Store waiting availability and required fields. | Enter party or visit context and submit waiting request. | Do not say seat is guaranteed. |
| waiting status | Show current waiting state. | Registered, confirmed, called, arrived, no-show candidate, cancelled, or expired. | Check status, cancel where allowed, browse menu. | Do not imply order is confirmed just because waiting exists. |
| menu browsing | Show menu categories, photos, options, and availability. | Menu snapshot and language display. | Browse items, choose options, add to cart. | Do not imply menu interest equals purchase. |
| menu item detail | Show item details and options. | Item name, description, photo, options, availability, price display. | Select options, quantity, note, add to cart. | Do not imply item is reserved until staff confirmation. |
| cart / order candidate | Prepare cart before staff review. | Cart items, options, notes, estimated total, review status. | Edit cart, submit order candidate, cancel. | Do not display "order completed" before proper confirmation. |
| preorder request confirmation | Confirm that customer intent was submitted. | Preorder request or order candidate submitted. | Review summary, wait for staff review, edit if allowed. | Do not say POS-confirmed order. |
| staff review pending | Show staff review is required. | Staff review pending, delayed, or recovery required. | Wait, request help, cancel if allowed. | Do not say preparation started unless store confirms. |
| called / arrival prompt | Guide customer after store call. | Called, arrival requested, near-store, or no-show candidate. | Mark arrival where allowed, follow guidance. | Do not guarantee seating without staff action. |
| table or pickup handoff | Show table or pickup context after staff assignment. | Table number, pickup mode, handoff ready, staff confirmation state. | Confirm visibility, request help, review order candidate. | Do not imply POS/payment completion. |
| customer notification | Show order, handoff, delay, ready, cancelled, or recovery notification. | Notification state and message. | Acknowledge, follow store guidance, request help if available. | Do not say fulfilled order unless store process supports it. |
| cancellation / no-show guidance | Explain cancellation, no-show, or expiration state. | Cancelled, no-show candidate, expired, or staff assistance required. | Cancel, restart, contact staff, or follow recovery path. | Do not blame customer or imply financial penalty without policy. |
| recovery message | Show operational exception requiring staff help. | Manual recovery required, menu unavailable, duplicate suspected, integration failed, or staff correction needed. | Request staff help, edit, cancel, or wait. | Do not hide operational uncertainty as completed order. |

## 4 Customer Wording Rules

Allowed wording depends on runtime and confirmation state:

- order candidate.
- preorder request.
- staff review pending.
- staff-confirmed order.
- POS-confirmed order only when POS/API or staff confirmation supports it.
- do not display "order completed" before proper confirmation.

Customer wording must distinguish order candidate, staff-confirmed order, POS-confirmed order, and paid preorder.

## 5 Data / Privacy Notes

- collect minimum customer-identifiable data.
- language/menu interaction may become future analytics material.
- customer-facing consent/privacy notice is required before production.
- future membership/point remains inactive in MVP.
- customer-visible data should not expose admin, tenant, support, or cross-store data.

## 6 Open Decisions

- phone number requirement.
- anonymous waiting.
- multilingual language set.
- photo menu minimum.
- customer notification channel.
- cancellation/no-show message.

## 7 Current Status

Status: active customer webapp projection only. No implementation approval.
