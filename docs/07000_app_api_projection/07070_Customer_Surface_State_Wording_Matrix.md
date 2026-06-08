# 07070 Customer Surface State Wording Matrix

## 1 Purpose

Customer wording must match the real confirmation authority.

The app must not mislead customers into believing an order is confirmed, paid, or in POS when it is only a candidate.

This document is projection only.

It does not define UI implementation, translation implementation, notification delivery, payment implementation, POS integration, or production copy.

## 2 Wording Levels

Conceptual wording levels:

- menu browsing: customer is viewing menu content only.
- cart: customer is preparing selections.
- order candidate: customer has prepared an order candidate for store review.
- preorder request: customer has submitted intent before seating, pickup, or staff confirmation.
- staff review pending: store staff must review before confirmation.
- staff-confirmed order: staff has reviewed and confirmed the handoff.
- POS-confirmed order: POS success response or validated POS-side confirmation exists.
- printer-sent but not POS-confirmed: printer output was attempted or succeeded, but POS sales creation is not confirmed.
- payment pending: payment still needs store POS or approved platform payment handling.
- platform payment future-reserved: platform payment is not active MVP default.
- cancelled: customer or store cancellation is visible.
- expired: session or candidate expired.
- recovery required: staff help or manual recovery is required.

## 3 Integration-Level Wording

| integration level | safe customer wording | stricter wording rule |
| --- | --- | --- |
| `STAFF_SCREEN_ONLY` | order candidate, preorder request, staff review pending, staff-confirmed order after staff action. | STAFF_SCREEN_ONLY: use order candidate / staff review pending before staff confirmation. |
| `STORE_AGENT_ONLY` | order candidate, preorder request, staff review pending, staff-confirmed order after staff action. | Store Agent receipt does not mean staff confirmation or POS confirmation. |
| `STORE_AGENT_PRINTER` | order candidate, preorder request, staff review pending, printed ticket pending, staff-confirmed order after staff action. | STORE_AGENT_PRINTER: printer output does not mean POS-confirmed. |
| `POS_API` | staff review pending, staff-confirmed order, POS-confirmed order after successful POS response. | POS_API: POS-confirmed wording allowed only after POS success response. |
| `FULL_OS_CONTROLLED` | staff-confirmed order, POS-confirmed order, paid preorder only when full runtime and legal/payment authority support it. | FULL_OS_CONTROLLED: stronger confirmation may be possible if full runtime owns order state. |

## 4 Forbidden Customer Wording

- do not say order completed before confirmation.
- do not say paid if store POS payment is still pending.
- do not say POS confirmed when only printer output succeeded.
- do not say point/coupon applied in MVP.
- do not say table assigned unless store confirmed.
- do not imply payment settlement, membership benefit, or kitchen execution without real authority.

## 5 Recovery / Delay Wording

Safe wording examples:

- staff review delay: "Staff review is taking longer than usual. Please wait or ask staff for help."
- printer failure: "The printed ticket may not have completed. Staff will check your order candidate."
- POS API failure: "POS confirmation is not complete. Staff will review and recover the order."
- customer called but not arrived: "The store has called you. Please follow the arrival guidance or ask staff for help."
- store busy/degraded: "The store is busy. Confirmation may take longer than usual."
- manual recovery required: "Staff assistance is required before this can continue."
- duplicate candidate suspected: "A similar order candidate may already exist. Staff will check before confirmation."

Recovery wording must not hide uncertainty as completed order.

## 6 Multilingual / Mini Kiosk Notes

- translated wording must preserve legal/operational meaning.
- simple wording preferred.
- avoid implying payment/order confirmation in ambiguous languages.
- staff-assisted mode may display "Please show this screen to staff."
- menu translation should not change order/payment authority meaning.

## 7 Open Decisions

- Korean/English/Japanese/Chinese initial wording set.
- whether icons can replace text.
- legal review of wording.
- customer notification templates.
- no-show wording.

## 8 Current Status

Status: active customer wording projection. No implementation approval.

