# 600473_TestPlan.md

Status: Draft
Lifecycle: TestPlan
Stage: 2 (Claude review / verification planning)
Owner: TBD
Last Updated: 2026-07-13

## Change ID

`orders_pickup_ready_timing_columns_migration`

## 0. Authority And Scope

This TestPlan is derived from:

- `600471_Overview.md`
- `600472_Logic.md`

Confirmed design, without reopening design judgment:

```sql
alter table catchmenu_pos.orders
  add column requested_pickup_at timestamptz,
  add column ready_at timestamptz;
```

The implementation is a forward schema migration only. Existing function bodies already reference the intended column names:

- `catchmenu_store.place_takeout_order()` in `0081_create_customer_app_rpc.sql`
- `catchmenu_store.track_takeout_order()` in `0081_create_customer_app_rpc.sql`
- `catchmenu_store.call_customer_pickup()` live owner in `0094_fix_i18n_hardcoded_strings.sql`

This TestPlan does not approve editing those functions. It verifies that adding the two missing columns resolves the confirmed hard errors.

## 1. Verification Environment

All execution tests must run against local Supabase Docker DB only.

Requirements:

- Run the schema migration through the approved local migration process in Stage 4.
- Wrap data-mutating verification scenarios in `BEGIN; ... ROLLBACK;` unless the migration itself is being applied.
- Do not leave test orders, order items, sessions, DID queue rows, ledger rows, KDS rows, payment rows, or notifications behind.
- Do not modify `0079`, `0081`, `0094`, or the KDS `ready_at` callers during verification.
- Do not change `PICKED_UP` status constraints.
- Do not fix `point_ledger` or `discount_pct` in this workpacket.

Pre-verification schema check:

```sql
select column_name, data_type, is_nullable, column_default
from information_schema.columns
where table_schema = 'catchmenu_pos'
  and table_name = 'orders'
  and column_name in ('requested_pickup_at', 'ready_at')
order by column_name;
```

Expected after implementation:

| column_name | data_type | is_nullable | column_default |
|---|---|---|---|
| `ready_at` | `timestamp with time zone` | `YES` | `NULL` |
| `requested_pickup_at` | `timestamp with time zone` | `YES` | `NULL` |

## 2. Test A — `place_takeout_order()` Reaches Past `requested_pickup_at` INSERT

Purpose:

- Confirm the former hard error `column "requested_pickup_at" of relation "orders" does not exist` is gone.
- Confirm `p_requested_pickup_at` can be inserted into `catchmenu_pos.orders`.
- Confirm execution reaches the next known blocker if one remains.

Execution shape:

```sql
begin;

select catchmenu_store.place_takeout_order(
  p_tenant_id := '00000000-0000-0000-0000-000000000001'::uuid,
  p_store_id := '00000000-0000-0000-0000-000000000002'::uuid,
  p_items := '[{"menu_id":"00000000-0000-0000-0000-000000000050","quantity":1}]'::jsonb,
  p_customer_id := null,
  p_phone_hash := null,
  p_locale := 'ko',
  p_memo := null,
  p_coupon_issue_id := null,
  p_use_points := 0,
  p_requested_pickup_at := now() + interval '20 minutes',
  p_correlation_id := 'verify-600473-place-takeout'
);

select id, order_number, requested_pickup_at, ready_at
from catchmenu_pos.orders
where correlation_id = 'verify-600473-place-takeout';

rollback;
```

Expected result:

- No `requested_pickup_at` missing-column error.
- If the function succeeds far enough to insert an order row, `orders.requested_pickup_at` equals the supplied timestamp and `orders.ready_at` remains `NULL`.
- If the function stops later, the stop point must be a known out-of-scope blocker such as `point_ledger` or `discount_pct`, not either of the two newly added timing columns.

PASS condition:

- Former `requested_pickup_at` INSERT error is absent.

FAIL condition:

- Any error states that `catchmenu_pos.orders.requested_pickup_at` does not exist.

## 3. Test B — `track_takeout_order()` Executes Successfully

Purpose:

- Confirm `track_takeout_order()` no longer fails 100% on `o.ready_at` or `o.requested_pickup_at`.
- Confirm its response timeline includes both fields.

Execution shape:

```sql
begin;

insert into catchmenu_pos.order_sessions (
  tenant_id, store_id,
  session_type, session_status,
  guest_count, guest_locale,
  session_started_at,
  correlation_id,
  business_day, business_timezone
) values (
  '00000000-0000-0000-0000-000000000001'::uuid,
  '00000000-0000-0000-0000-000000000002'::uuid,
  'TAKEOUT', 'ORDER_CONFIRMED',
  1, 'ko',
  now(),
  'verify-600473-track-session',
  current_date, 'Asia/Seoul'
)
returning id;

-- Use the returned session id in the order insert below.
insert into catchmenu_pos.orders (
  tenant_id, store_id, session_id,
  order_number, order_type, order_status,
  total_amount, discount_amount, final_amount,
  memo, requested_pickup_at, ready_at,
  ordered_at, business_day, business_timezone,
  correlation_id
) values (
  '00000000-0000-0000-0000-000000000001'::uuid,
  '00000000-0000-0000-0000-000000000002'::uuid,
  '<returned session id>'::uuid,
  'TVERIFY600473',
  'TAKEOUT', 'CONFIRMED',
  3500, 0, 3500,
  'verify memo',
  now() + interval '20 minutes',
  null,
  now(), current_date, 'Asia/Seoul',
  'verify-600473-track-order'
)
returning id;

select catchmenu_store.track_takeout_order(
  p_tenant_id := '00000000-0000-0000-0000-000000000001'::uuid,
  p_store_id := '00000000-0000-0000-0000-000000000002'::uuid,
  p_order_id := '<returned order id>'::uuid,
  p_locale := 'ko'
);

rollback;
```

The verification runner may use a `DO` block or CTE to avoid manually copying returned UUIDs.

Expected result:

- `track_takeout_order()` returns success JSON.
- Response `timeline.ready_at` is present and `NULL` for this dummy order unless explicitly set.
- Response `timeline.requested_pickup_at` is present and matches the inserted timestamp.
- No missing-column error for `o.ready_at`.
- No missing-column error for `o.requested_pickup_at`.

PASS condition:

- The function executes successfully through its order SELECT and returns timeline fields.

FAIL condition:

- Any error states that `ready_at` or `requested_pickup_at` does not exist on `catchmenu_pos.orders`.

## 4. Test C — `call_customer_pickup()` Sets `orders.ready_at`

Purpose:

- Confirm the live `0094` owner of `call_customer_pickup()` can update `catchmenu_pos.orders.ready_at`.
- Confirm `ready_at` is set only when `p_queue_type = 'PICKUP_READY'`.

Execution shape:

```sql
begin;

-- Create a rollback-scoped TAKEOUT order row with order_status = 'CONFIRMED'.
-- Reuse the same session/order setup pattern from Test B.

select catchmenu_store.call_customer_pickup(
  p_tenant_id := '00000000-0000-0000-0000-000000000001'::uuid,
  p_store_id := '00000000-0000-0000-0000-000000000002'::uuid,
  p_order_id := '<returned order id>'::uuid,
  p_queue_type := 'PICKUP_READY',
  p_target_zone := null,
  p_locale := 'ko',
  p_correlation_id := 'verify-600473-call-pickup'
);

select id, order_status, ready_at
from catchmenu_pos.orders
where id = '<returned order id>'::uuid;

rollback;
```

Expected result:

- `call_customer_pickup()` executes without missing-column error.
- `orders.order_status` becomes `READY`.
- `orders.ready_at` is set to a non-null timestamp.
- Re-calling should preserve the first `ready_at` due to `ready_at = coalesce(ready_at, now())`.

PASS condition:

- `ready_at` is set and no missing-column error occurs.

FAIL condition:

- Any error states that `catchmenu_pos.orders.ready_at` does not exist.

## 5. Sanity Check — KDS `ready_at` Callers Are Unaffected

Purpose:

- Confirm the new `catchmenu_pos.orders.ready_at` column does not alter or collide with existing `catchmenu_kds.kds_tickets.ready_at` usage.

Read-only source sanity check:

```powershell
rg -n "ready_at" sql/migrations --glob "*.sql"
```

Expected classification:

| File | Expected target |
|---|---|
| `0016_create_kds_tickets.sql` | `catchmenu_kds.kds_tickets.ready_at` DDL/constraint |
| `0029_create_kds_cooking_rpc.sql` | `catchmenu_kds.kds_tickets.ready_at` UPDATE/payload |
| `0043_create_did_display_rpc.sql` | `catchmenu_kds.kds_tickets.ready_at` read |
| `0045_create_daily_summary_rpc.sql` | `catchmenu_kds.kds_tickets.ready_at` KPI calculations |
| `0051_create_pre_order_rpc.sql` | `catchmenu_kds.kds_tickets.ready_at` JSON payload |
| `0070_create_flutter_bootstrap_rpc.sql` | `catchmenu_kds.kds_tickets.ready_at` JSON payload |
| `0106_create_delivery_platform_pipeline_rpc.sql` | `catchmenu_kds.kds_tickets.ready_at` UPDATE |

Expected result:

- No KDS function source is modified.
- No KDS `ready_at` behavior changes.
- All KDS `ready_at` references remain table-qualified or contextually tied to `catchmenu_kds.kds_tickets`.

## 6. Sanity Check — `PICKED_UP` Status Drift Remains A No-Op

Purpose:

- Confirm this workpacket does not change the known `PICKED_UP` drift.

Read-only check:

```sql
select pg_get_constraintdef(oid)
from pg_constraint
where conname = 'chk_order_status';
```

Expected result:

- `PICKED_UP` is still absent from `chk_order_status`.
- `call_customer_pickup()` still contains `order_status not in ('READY', 'PICKED_UP', 'COMPLETED', 'CANCELLED')`.
- This is recorded as an Open Item only.

PASS condition:

- No schema/status constraint change occurs for `PICKED_UP`.

FAIL condition:

- The implementation modifies order status constraints or starts resolving `PICKED_UP` drift.

## 7. Boundary Verification

Static boundary checks after implementation:

```powershell
git diff -- sql/migrations/0152_add_orders_pickup_ready_timing_columns.sql
git diff -- sql/migrations/0081_create_customer_app_rpc.sql
git diff -- sql/migrations/0094_fix_i18n_hardcoded_strings.sql
git diff -- sql/migrations/0079_create_did_advanced_rpc.sql
git diff --check
```

Expected result:

- New migration file only.
- No `0081` source change.
- No `0094` source change.
- No `0079` source change.
- No KDS `ready_at` caller changes.
- No `PICKED_UP` status constraint changes.

## 8. Acceptance Criteria

This TestPlan passes if:

1. `catchmenu_pos.orders` has nullable `requested_pickup_at timestamptz`.
2. `catchmenu_pos.orders` has nullable `ready_at timestamptz`.
3. `place_takeout_order()` no longer fails at `requested_pickup_at` INSERT.
4. `track_takeout_order()` executes and returns `timeline.ready_at` and `timeline.requested_pickup_at`.
5. `call_customer_pickup()` executes and sets `orders.ready_at` for `PICKUP_READY`.
6. Existing KDS `ready_at` references remain untouched.
7. `PICKED_UP` drift remains an Open Item only.
8. `git diff --check` passes.

