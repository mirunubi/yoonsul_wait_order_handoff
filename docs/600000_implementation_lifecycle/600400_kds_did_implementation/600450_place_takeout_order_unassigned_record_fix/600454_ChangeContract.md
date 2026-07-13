# 600454_ChangeContract.md

Status: Draft
Lifecycle: ChangeContract
Stage: 2 (Claude review / boundary contract)
Owner: TBD
Last Updated: 2026-07-13

## Change ID

`place_takeout_order_unassigned_record_fix`

## §0 Authority

This ChangeContract is based on:

- `600451_Overview.md`
- `600452_Logic.md`
- `600453_TestPlan.md`

The accepted design is not reopened here:

- Replace untyped `record` access in `catchmenu_store.place_takeout_order()` with scalar variables.
- Cover all 11 confirmed `.id`/field reference points: L609/L622/L653/L661/L714/L852/L864/L869/L924/L930/L949.
- Convert discount-related field references inside the same function to scalar variables.
- Apply point policy A: if no customer is identified but points are requested, skip point usage, continue order flow, and write a warning through `catchmenu_common.log_diagnostic()`.

## §1 Allowed Files

Exactly one source file may be modified:

| File | Allowed scope |
|---|---|
| `sql/migrations/0081_create_customer_app_rpc.sql` | `catchmenu_store.place_takeout_order()` function body only |

Allowed implementation details inside `place_takeout_order()`:

- Replace `v_customer record` with scalar variables needed by the existing function, including:
  - `v_customer_id`
  - `v_customer_display_name`
  - `v_customer_membership_tier`
  - `v_customer_point_balance`
- Replace `v_coupon record` with scalar variables needed by the existing function, including:
  - `v_coupon_id`
  - `v_coupon_discount_type`
  - `v_coupon_discount_value`
  - `v_coupon_discount_pct`
  - `v_coupon_min_order_amount`
  - `v_coupon_max_discount_amount`
- Adjust customer SELECT targets to populate customer scalar variables.
- Adjust coupon SELECT targets to populate coupon scalar variables.
- Replace the 11 confirmed direct reference points:
  - L609: `v_customer.id` → `v_customer_id`
  - L622: `v_customer.id` → `v_customer_id`
  - L653: `v_customer.id` → `v_customer_id`
  - L661: `v_coupon.id` → `v_coupon_id`
  - L714: `v_coupon.id` → `v_coupon_id`
  - L852: `v_coupon.id` → `v_coupon_id`
  - L864: `v_customer.id` → `v_customer_id`
  - L869: `v_customer.id` → `v_customer_id`
  - L924: `v_customer.id` → `v_customer_id`
  - L930: `v_coupon.id` → `v_coupon_id`
  - L949: `v_customer.display_name` → `v_customer_display_name`
- Replace discount-related field references with scalar variables:
  - `v_coupon.discount_type` → `v_coupon_discount_type`
  - `v_coupon.discount_value` → `v_coupon_discount_value`
  - `v_coupon.discount_pct` → `v_coupon_discount_pct`
  - `v_coupon.min_order_amount` → `v_coupon_min_order_amount`
  - `v_coupon.max_discount_amount` → `v_coupon_max_discount_amount`
- Add the Human-approved point policy A branch:
  - If `v_customer_id is null and p_use_points > 0`, do not fail the order because of points.
  - Do not apply a point discount.
  - Write a warning diagnostic through `catchmenu_common.log_diagnostic()`.

## §2 Forbidden Files And Operations

The following are explicitly forbidden:

| Forbidden item | Reason |
|---|---|
| `track_takeout_order()` in `0081_create_customer_app_rpc.sql` | Same file, different function; out of scope |
| Any function in `0081_create_customer_app_rpc.sql` other than `place_takeout_order()` | This workpacket is a single-function fix |
| `catchmenu_store.coupons` table schema | `discount_pct` defect is separate and out of scope |
| New `discount_pct` column | Not approved here |
| `discount_type` enum/constraint changes | Not approved here |
| Coupon discount policy rewrite | Out of scope |
| Coupon double-use/race-condition fix | Open Item, separate candidate |
| `0015` | Unrelated |
| `0121` | Unrelated |
| Any other `sql/migrations/*.sql` file | Out of scope |
| Flutter/runtime code | Out of scope |
| Tools scripts | Out of scope |
| Documentation outside this workpacket | Out of scope unless a later explicit instruction requests Module/Verification/Audit docs |

Implementation must not:

- Use boolean guard patterns such as `v_customer_found and v_customer.id is not null` as the primary fix.
- Keep executable references to untyped `record` fields that can remain unassigned.
- Convert this into a broader stale-schema cleanup.
- Fix `discount_pct`, `'AMOUNT'`, or `'PCT'` in this workpacket.
- Change API response payload keys unless required by the scalar conversion inside `place_takeout_order()` and explicitly documented.

## §3 Required Behavior Preservation

The implementation must preserve:

- Existing function signature of `catchmenu_store.place_takeout_order()`.
- Existing return payload structure except for internal safety changes required by scalar variables.
- Existing order creation flow.
- Existing payment/KDS side effects.
- Existing coupon-not-redeemable behavior when coupon lookup yields no valid issue.
- Existing point balance validation when a valid customer is identified.
- Existing insufficient-points error when a valid customer lacks enough points.
- Existing ledger/event/notification behavior, except that scalar values replace unsafe record field access.

## §4 Required New Behavior

The implementation must add or preserve the following behavior:

- Guest/no-customer calls must not crash merely because `v_customer` was previously unassigned.
- No-coupon calls must not crash merely because `v_coupon` was previously unassigned.
- Guest+points calls must:
  - continue the order path,
  - skip point usage,
  - write a warning diagnostic using `catchmenu_common.log_diagnostic()`.

Suggested diagnostic semantics:

- `p_log_level := 'WARNING'`
- `p_log_domain := 'ORDER'`
- `p_log_event := 'points_requested_without_customer'`
- `p_message := <non-null warning message>` — required because `p_message` has no default value
- details include the requested `p_use_points`
- `p_rpc_name := 'place_takeout_order'`

If Stage 4 needs to adjust exact diagnostic parameter names to match the live `log_diagnostic()` signature, that is allowed only to make the approved warning call compile; it must not change the approved policy. Stage 4 must not omit `p_message`.

## §5 Verification Requirements

Implementation must be verified against `600453_TestPlan.md`.

Required verification groups:

1. Guest + no coupon.
2. Guest + coupon ID provided.
3. Member + no coupon.
4. Member + coupon provided.
5. Guest + points requested.
6. Member + valid points regression.
7. Static source inspection and live `pg_get_functiondef()` inspection.
8. Boundary check confirming only `place_takeout_order()` in `0081` changed.

Member+coupon path may still fail on the known out-of-scope `discount_pct` schema mismatch. That is acceptable only if no record-unassigned error remains and no attempt is made to solve `discount_pct` here.

## §6 Open Items Not Approved In This Contract

### §6.1 `discount_pct` / Coupon Schema Mismatch

`catchmenu_store.coupons` does not have `discount_pct`, and the current code also appears to use stale discount literals (`'AMOUNT'`/`'PCT'`) that do not match the known actual values (`'FIXED'`/`'PERCENTAGE'`). This remains a separate follow-up workpacket candidate.

This ChangeContract does not approve:

- adding `discount_pct`,
- rewriting coupon discount logic,
- changing coupon constraints,
- changing coupon seed data,
- changing coupon client behavior.

### §6.2 Coupon Double-Use Race Condition

The current coupon validity check and later `coupon_issues` update may allow a race if the same coupon is used concurrently. This is separate from record-unassigned safety.

This ChangeContract does not approve:

- adding locks,
- adding affected-row checks,
- changing coupon issue state transition policy,
- adding idempotency keys for coupon usage.

## §7 Risk

Risk level: HIGH.

Reasons:

- `place_takeout_order()` is a customer-facing order RPC.
- The function touches order, point, coupon, ledger/event, notification, and downstream operational paths.
- The allowed file is a previously applied migration file, so implementation will likely require checksum/live replay discipline in later stages.
- A separate coupon schema defect remains intentionally unresolved, which must not be confused with failure of this fix.

Risk controls:

- Single-function boundary.
- Scalar-variable-only mechanism.
- Four path tests plus point policy test.
- Explicit forbidden list.
- Rollback-wrapped verification.

## §8 Human Boundary Approval

Human approval is required before Stage 4 implementation.

☑ I approve modifying only sql/migrations/0081_create_customer_app_rpc.sql.
☑ I approve limiting changes to catchmenu_store.place_takeout_order() only.
☑ I acknowledge that discount_pct and coupon double-use race condition remain out of scope for this workpacket.

## §9 Stage 4 Instruction If Approved

If all three Human approval boxes in §8 are checked, Stage 4 may proceed to implement exactly this contract.

If any box remains unchecked, Stage 4 must stop and report that implementation is not authorized.
