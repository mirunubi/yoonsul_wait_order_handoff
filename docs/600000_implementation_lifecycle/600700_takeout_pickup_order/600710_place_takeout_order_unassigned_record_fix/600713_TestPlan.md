# 600713_TestPlan.md

Status: Draft
Lifecycle: TestPlan
Stage: 2 (Claude review / verification planning)
Owner: TBD
Last Updated: 2026-07-13

## Change ID

`place_takeout_order_unassigned_record_fix`

## §0 Authority And Scope

This TestPlan is derived from:

- `600711_Overview.md`
- `600712_Logic.md`

Confirmed design, without reopening design judgment:

- `catchmenu_store.place_takeout_order()` in `sql/migrations/0081_create_customer_app_rpc.sql` replaces untyped `record` access for `v_customer` and `v_coupon` with scalar variables.
- The 11 `.id`/field reference points are covered: L609/L622/L653/L661/L714/L852/L864/L869/L924/L930/L949.
- Discount-related field references in the same function are converted to scalar variable names, but the separate `discount_pct` schema mismatch is not fixed by this workpacket.
- If `v_customer_id is null` while `p_use_points > 0`, the order flow must continue and point usage must be skipped, with a warning written through `catchmenu_common.log_diagnostic()`.
- The `discount_pct` defect and coupon double-use race condition remain separate Open Items.

## §1 Verification Environment

All execution tests must be run against local Supabase Docker DB only.

Requirements:

- Wrap each data-mutating scenario in `BEGIN; ... ROLLBACK;`.
- Do not leave test orders, sessions, coupon issues, point ledger rows, diagnostic log rows, or KDS/payment records behind.
- Do not modify schema, constraints, or unrelated migration files during this verification.
- Verify the live function body after implementation with `pg_get_functiondef()` before scenario execution.

Suggested baseline checks:

```sql
select pg_get_functiondef('catchmenu_store.place_takeout_order'::regproc);
```

The returned body must no longer contain direct runtime use of:

- `v_customer.id`
- `v_customer.display_name`
- `v_coupon.id`
- `v_coupon.discount_type`
- `v_coupon.discount_value`
- `v_coupon.discount_pct`
- `v_coupon.min_order_amount`
- `v_coupon.max_discount_amount`

The function body must contain the scalar replacements:

- `v_customer_id`
- `v_customer_display_name`
- `v_customer_membership_tier`
- `v_customer_point_balance`
- `v_coupon_id`
- `v_coupon_discount_type`
- `v_coupon_discount_value`
- `v_coupon_discount_pct`
- `v_coupon_min_order_amount`
- `v_coupon_max_discount_amount`

## §2 Path Tests — Four Required Scenarios

Each scenario must call `catchmenu_store.place_takeout_order()` through SQL in a transaction and then roll back.

### §2.1 Guest + No Coupon

Purpose:

- Reproduce the former `v_customer` unassigned path.
- Confirm L609/L924/L949 no longer crash.

Input shape:

- `p_customer_id := null`
- `p_phone_hash := null`
- `p_coupon_issue_id := null`
- `p_use_points := 0`

Expected result:

- No `record "v_customer" is not assigned yet` error.
- No `record "v_coupon" is not assigned yet` error.
- The function reaches its normal order path or another pre-existing non-record blocker.
- If it succeeds, the staff notification/customer display fallback should use `'비회원'` through `coalesce(v_customer_display_name, '비회원')`.

PASS condition:

- The former record-unassigned crash is absent.

FAIL condition:

- Any error containing `record "v_customer" is not assigned yet` or `record "v_coupon" is not assigned yet`.

### §2.2 Guest + Coupon ID Provided

Purpose:

- Reproduce the former L653 `v_customer.id` coupon lookup path.
- Confirm the coupon lookup uses `v_customer_id` and does not crash when customer identity is absent.

Input shape:

- `p_customer_id := null`
- `p_phone_hash := null`
- `p_coupon_issue_id := <test coupon issue uuid>`
- `p_use_points := 0`

Expected result:

- No record-unassigned crash at the coupon lookup.
- If the coupon is not redeemable for a missing customer, the function should return or raise the existing coupon-not-redeemable behavior, not a PL/pgSQL record assignment error.

PASS condition:

- The former L653 crash is gone.

FAIL condition:

- Any `record "v_customer" is not assigned yet` error.

### §2.3 Member + No Coupon

Purpose:

- Reproduce the former `v_coupon` unassigned path.
- Confirm L714/L852/L930 no longer crash when no coupon is supplied.

Input shape:

- `p_customer_id := <existing active customer uuid>`
- `p_phone_hash := null` or a value that does not alter the selected customer
- `p_coupon_issue_id := null`
- `p_use_points := 0`

Expected result:

- No `record "v_coupon" is not assigned yet` error.
- Coupon discount, coupon usage update, and event payload coupon fields must be skipped or evaluated through `v_coupon_id is not null`.

PASS condition:

- The former L714/L852 record-unassigned crash is absent.

FAIL condition:

- Any `record "v_coupon" is not assigned yet` error.

### §2.4 Member + Coupon Provided

Purpose:

- Confirm this workpacket does not hide the separate coupon schema mismatch.
- Confirm the expected remaining failure is the out-of-scope `discount_pct` defect, not record-unassigned.

Input shape:

- `p_customer_id := <existing active customer uuid>`
- `p_coupon_issue_id := <coupon issue belonging to that customer>`
- `p_use_points := 0`

Expected result:

- The function may still fail at the coupon SELECT/calculation path because `catchmenu_store.coupons.discount_pct` does not exist.
- That failure is expected and is a PASS condition for this workpacket if the error is specifically the known out-of-scope `discount_pct` defect.
- No record-unassigned error should appear before that failure.

PASS condition:

- Error is the known `column c.discount_pct does not exist` or equivalent out-of-scope coupon schema mismatch.

FAIL condition:

- Any `record "v_customer" is not assigned yet` or `record "v_coupon" is not assigned yet` error.
- Any implementation attempt to fix `discount_pct` in this workpacket.

## §3 Point Policy Test — Guest Requests Points

Purpose:

- Verify Human decision A: point usage is silently skipped when no customer is identified.
- Verify diagnostic logging occurs.

Input shape:

- `p_customer_id := null`
- `p_phone_hash := null`
- `p_coupon_issue_id := null`
- `p_use_points := <positive integer>`

Expected behavior:

- The order flow does not fail solely because a guest requested points.
- `v_point_discount` remains zero or equivalent no-point-discount behavior is preserved.
- `catchmenu_common.log_diagnostic()` records a warning event for `points_requested_without_customer`.
- The warning should include enough detail to identify the requested point amount, at minimum `p_use_points`.

Suggested verification query inside the same transaction:

```sql
select *
from catchmenu_common.diagnostic_logs
where rpc_name = 'place_takeout_order'
  and log_event = 'points_requested_without_customer'
order by created_at desc
limit 5;
```

`catchmenu_common.diagnostic_logs` is the actual diagnostic log table. If the live `log_diagnostic()` schema stores these fields under slightly different column names, use that schema and verify the same semantic evidence.

PASS condition:

- Order path is not blocked by point request alone.
- Warning diagnostic exists before rollback.

FAIL condition:

- Function returns an insufficient-points/customer-required error solely because `v_customer_id is null`.
- No diagnostic warning is written.

## §4 Regression Test — Member With Valid Points, No Coupon

Purpose:

- Confirm existing normal member point path still works with scalar variables.

Input shape:

- `p_customer_id := <existing active customer uuid with sufficient point balance>`
- `p_coupon_issue_id := null`
- `p_use_points := <positive amount less than or equal to balance>`

Expected behavior:

- Point balance query uses `where customer_id = v_customer_id`.
- Existing insufficient-balance behavior is preserved when balance is too low.
- Existing successful point discount behavior is preserved when balance is sufficient.
- No coupon-related record-unassigned crash occurs when no coupon is supplied.

PASS condition:

- Existing point path works or fails only for legitimate business-rule reasons.
- No record-unassigned error.

FAIL condition:

- Point path is skipped despite valid `v_customer_id`.
- Any `record` assignment error.

## §5 Static Verification Checklist

After implementation, inspect `sql/migrations/0081_create_customer_app_rpc.sql` and live `pg_get_functiondef()` output.

Required source checks:

- L609 uses `v_customer_id is not null` and the A안 `elsif v_customer_id is null and p_use_points > 0` diagnostic branch.
- L622 uses `customer_id = v_customer_id`.
- L653 uses `ci.customer_id = v_customer_id`.
- L661 uses `v_coupon_id is null`.
- L714 and L852 use `v_coupon_id is not null`.
- L864 uses `v_customer_id is not null`.
- L869 passes `p_customer_id := v_customer_id`.
- L924 uses `v_customer_id`.
- L930 uses `v_coupon_id is not null`.
- L949 uses `v_customer_display_name`.
- Discount field references use scalar variables: `v_coupon_discount_type`, `v_coupon_discount_value`, `v_coupon_discount_pct`, `v_coupon_min_order_amount`, `v_coupon_max_discount_amount`.

Forbidden static findings:

- Direct field access to `v_customer.id`, `v_customer.display_name`, `v_coupon.id`, or `v_coupon.discount_*` remains in executable code.
- `track_takeout_order()` is changed.
- `discount_pct` schema is patched in this workpacket.

## §6 Boundary Verification

Run:

```powershell
git diff -- sql/migrations/0081_create_customer_app_rpc.sql
git diff --check
git status --short
```

Expected:

- Only `sql/migrations/0081_create_customer_app_rpc.sql` is modified for implementation.
- The diff is limited to `place_takeout_order()` function body and required checksum/live replay handling if performed separately.
- No unrelated SQL migration, Flutter, docs, tooling, or runtime file is modified by implementation.

## §7 Acceptance Criteria

Accept if all are true:

- The four path tests no longer produce record-unassigned errors.
- Member+coupon path still exposing `discount_pct` is recorded as expected out-of-scope behavior, not treated as this workpacket failure.
- Guest+points policy follows A안: continue order flow, skip points, log diagnostic warning.
- Existing member+points path does not regress.
- Static inspection confirms all 11 `.id`/field reference points and discount-related scalar conversions are implemented.
- `track_takeout_order()` and unrelated functions remain untouched.

Block if any are true:

- Any record-unassigned error remains in the four required scenarios.
- The implementation attempts to solve `discount_pct` schema mismatch in this workpacket.
- The implementation modifies forbidden functions/files.
- Diagnostic logging for guest+points is missing.
