# 9030 Point Bridge And Exchange Future Boundary

## 1 Purpose

This document defines the future bridge boundary among SaaS points, white-label points, Yoonsul group points, and external membership systems.

This is not active integration design.

It does not define SQL, migrations, app code, wallet implementation, membership integration, point exchange implementation, or settlement implementation.

## 2 Bridge Event Types

Future-only bridge event types:

- `IDENTITY_LOOKUP_REQUESTED`
- `BENEFIT_PREVIEW_REQUESTED`
- `BENEFIT_PREVIEW_READY`
- `REDEMPTION_REQUESTED`
- `REDEMPTION_RESERVED`
- `REDEMPTION_APPLIED`
- `REVERSAL_REQUIRED`
- `REVERSAL_COMPLETED`
- `RECONCILIATION_PENDING`
- `RECONCILED`
- `MANUAL_REVIEW_REQUIRED`

## 3 Forbidden Future Assumptions

- preview does not mean apply.
- reserve does not mean settle.
- coupon shown does not mean coupon used.
- point selected does not mean point deducted.
- white-label point does not equal Yoonsul group point.
- SaaS point does not automatically convert to white-label or Yoonsul group point.

## 4 Exchange Boundary

`cross_program_point_exchange_enabled` must default to false in any future design.

Exchange requires explicit bridge rule.

Exchange requires settlement rule.

Exchange requires tenant/admin approval.

Exchange requires audit and reconciliation.

## 5 Relationship To Active MVP

Active MVP may create order candidate and handoff session.

Active MVP must not apply or deduct points.

Active MVP may only reserve future document references.

## 6 Current Status

Status: future-reserved.

