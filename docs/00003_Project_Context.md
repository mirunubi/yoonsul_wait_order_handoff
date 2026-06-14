# 00003 Project Context

## 0 Scope

This document applies only to `yoonsul_wait_order_handoff`.

## 1 Why This Project Exists

`yoonsul_wait_order_handoff` exists to reduce waiting-to-order lead time.

The product explores a software handoff path where a customer can browse the menu, prepare a cart, create an order candidate, and hand that order candidate to staff at seating or confirmation time.

The project also supports:

- Mini Kiosk mode.
- multilingual ordering mode.
- non-face-to-face ordering mode.
- SaaS market possibility.
- BM patent separation.

## 2 Relationship To Other Projects

`yoonsul_os` may be referenced for boundary concepts, but implementation remains separate.

`yoonsul_franchise_os` is a long-term future expansion reference only.

`life_os` is unrelated.

## 3 Current Product Assumptions

- SaaS tenant-first.
- store runtime per tenant or store.
- customer session continuity.
- waiting session to handoff session continuity.
- integration boundary must remain high-level until MVP scope is approved.

## 4 Current Non-Goals

- no POS deep integration yet.
- no payment settlement design yet.
- no printer driver design yet.
- no `franchise_os` merge.
- no app implementation before docs approval.

## 5 Current Status

Status: active root governance context.
