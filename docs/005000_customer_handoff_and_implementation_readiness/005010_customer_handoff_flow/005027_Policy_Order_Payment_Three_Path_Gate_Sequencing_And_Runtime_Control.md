# 005027_Policy_Order_Payment_Three_Path_Gate_Sequencing_And_Runtime_Control.md

## 0 Scope

This document defines ONLY the payment-gate sequencing: at what point
in the order flow payment becomes required/blocking, and how that gate
differs across three customer paths — (a) guest, (b) CatchMenu
self-membership, (c) tenant/brand membership (Yoonsul_OS first target).

This document does NOT redefine:
- Guest→account merge/continuity mechanics — fully owned by `005015`
  §8-§11 (merge triggers, preserved context, merge authority, duplicate
  detection). This policy references those merge outcomes as inputs,
  not restates them.
- Payment identity/customer identity separation — owned by `005015` §16.
- Cart/preorder/order state definitions — owned by `005013`.
- Coupon/benefit application timing — owned by `005016` §12-§13.

Resolves the design gap that deferred `0081_create_customer_app_rpc.sql`
(`order_sessions.customer_token` ↔ `customers` relationship).

## 1 Core Principle

«무계정 진입은 계속 허용한다. 결제 확정 시점에만 세 경로 중 하나가 확정된다.»

«Guest entry remains unauthenticated. Only at payment confirmation does
the system resolve the customer into exactly one of three paths.»

## 2 Three Payment Paths (routing only — merge mechanics live in 005015)

### 2.1 Path A — Guest / No-Account
- `customer_token`-scoped session only. No `customer_id` link.
- No benefit routing (per 005016), no persisted order history beyond
  session.

### 2.2 Path B — CatchMenu Self-Membership
- Login resolves session to `customers.id` via a new `customer_id` FK.
- If login happens mid-flow (guest→login), the actual merge follows
  `005015` §8-§11 in full — this policy only marks WHERE in the payment
  sequence that trigger fires.

### 2.3 Path C — Tenant/Brand Membership (Yoonsul_OS first)
- Identity link/claim token per `000010` §10-§11 — CatchMenu never
  becomes the ledger of record.
- Duplicate guard per `000010` §11 applies across Path B/C for the same
  order.

## 3 The Gate — Where It Sits

qr_scan → cart_draft → path_resolution (A|B|C) → PAYMENT GATE →
order_accepted → pos_handoff → kds_handoff

- `PAYMENT GATE` is a hard blocking checkpoint: no `pos_handoff` without
  gate clearance.
- `path_resolution` may occur late (guest until payment screen is
  allowed) — this is the deferred-login pattern already implied by
  `001210` §11/§17 (Stage 0A: no login required through menu
  browsing/selection).
- On gate clearance, `order_sessions.customer_id` is set (Path B/C) or
  left null with `customer_token` retained (Path A) — this is the
  concrete design decision `0081` was blocked on.

## 4 Relationship To Other Documents

| Doc | Owns | This Doc Adds |
|---|---|---|
| 005013 | cart/preorder/order state | where PAYMENT GATE sits relative to those states |
| 005015 | guest↔account merge mechanics | WHEN merge is triggered relative to payment |
| 005016 | coupon/benefit timing | which path unlocks benefit eligibility (B/C only, §2.2-2.3) |
| 000010 §10-11 | tenant identity link / duplicate guard | Path C invokes this; not redefined here |
| 001210 | Stage 0A no-login flow | confirms guest path is valid pre-gate |

## 5 Required Design Outputs (for future implementation lane, not this doc)

- `order_sessions.customer_id` FK addition (new forward migration —
  unblocks `0081`)
- `customer_token` retention policy for Path A after gate
- Path B/C resolution failure handling (login fails at gate — fallback
  to Path A, not blocked entirely)
