# 00110 Project Identity And Overview

## Project Identity

This is a focused MVP/PoC project for wait-order handoff. It validates a business method where a waiting customer can browse menu information, compose a cart, submit an order candidate, and hand that candidate to store staff at seating time.

The MVP is intentionally separate from the full `yoonsul_os` main system.

## Problem

In many stores, customers wait before being seated and only begin ordering after they sit down. This creates an avoidable lead time:

1. Customer waits.
2. Customer is seated.
3. Customer receives or opens menu.
4. Customer discusses choices.
5. Staff takes order.
6. Staff enters order into POS.

The MVP shifts steps 3 and 4 into the waiting period.

## Target Outcome

When the customer is seated, staff can immediately review a prepared order candidate and confirm it.

Expected benefits:

- Reduced seating-to-order time
- Faster table turnover in busy periods
- Better customer experience while waiting
- Lower staff explanation burden for menus and options
- Optional use as a lightweight Mini Kiosk

## Concept Summary

The core concept is a handoff state transition:

```text
Waiting customer
  -> menu browsing
  -> cart
  -> order candidate
  -> seated table assignment
  -> staff review
  -> staff confirmation
```

## MVP Success Criteria

- A customer can enter a store context through QR, NFC, or URL.
- A customer can create or join a waiting session.
- A customer can browse menu items with photos, descriptions, prices, options, and language display.
- A customer can create a cart and submit it as an order candidate.
- Staff can see waiting sessions and order candidates.
- Staff can assign a table number to a waiting session.
- Staff can review and confirm the candidate order.
- The confirmed order remains suitable for manual POS entry.

## Explicit System Limit

This MVP is not a POS, KDS, payment system, loyalty system, payroll system, franchise operating system, or AI automation platform.
