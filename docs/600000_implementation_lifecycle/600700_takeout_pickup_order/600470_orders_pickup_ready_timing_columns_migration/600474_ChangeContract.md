# 600474_ChangeContract.md

Status: Draft
Lifecycle: ChangeContract
Stage: 2 (Claude review / boundary contract)
Owner: TBD
Last Updated: 2026-07-13

## Change ID

`orders_pickup_ready_timing_columns_migration`

## 0. Authority

This ChangeContract is based on:

- `600471_Overview.md`
- `600472_Logic.md`
- `600473_TestPlan.md`

The accepted design is not reopened here.

Confirmed implementation approach:

- Use a new forward migration.
- Do not edit historical/base DDL migrations in place.
- Add two nullable timestamp columns to `catchmenu_pos.orders`:
  - `requested_pickup_at timestamptz`
  - `ready_at timestamptz`

Current migration-number check:

- `0150_widen_event_domain_constraint.sql` exists.
- `0151_create_check_kds_capacity_function.sql` exists.
- No `0152*.sql` file was present at Stage 2 drafting time.

Therefore the approved target file for Stage 4 is:

```text
sql/migrations/0152_add_orders_pickup_ready_timing_columns.sql
```

## 1. Allowed Files

Exactly one SQL migration file may be created:

| File | Allowed scope |
|---|---|
| `sql/migrations/0152_add_orders_pickup_ready_timing_columns.sql` | Add `requested_pickup_at` and `ready_at` to `catchmenu_pos.orders` |

Allowed SQL:

```sql
alter table catchmenu_pos.orders
  add column requested_pickup_at timestamptz,
  add column ready_at timestamptz;
```

Recommended safe form if Stage 4 confirms local/cloud replay idempotency needs it:

```sql
alter table catchmenu_pos.orders
  add column if not exists requested_pickup_at timestamptz,
  add column if not exists ready_at timestamptz;
```

Stage 4 must choose the stricter project-consistent form based on current migration convention and record the choice. It must not add defaults or constraints unless a new human approval explicitly authorizes them.

## 2. Files Explicitly Not Modified But Relevant

The following files are relevant because their existing code already references the approved column names. They are not modification targets.

| File | Reason no edit is required |
|---|---|
| `sql/migrations/0081_create_customer_app_rpc.sql` | `place_takeout_order()` already writes `requested_pickup_at`; `track_takeout_order()` already reads `ready_at` and `requested_pickup_at`. The defect is missing schema, not wrong function code. |
| `sql/migrations/0094_fix_i18n_hardcoded_strings.sql` | Live owner of `call_customer_pickup()` already updates `orders.ready_at`. The defect is missing schema, not wrong function code. |

These files may be inspected during verification but must not be edited in this workpacket.

## 3. Forbidden Files And Operations

The following are explicitly forbidden:

| Forbidden item | Reason |
|---|---|
| `sql/migrations/0013_create_pos_orders.sql` | Historical/base DDL; use forward migration instead |
| `sql/migrations/0012_create_pos_order_sessions.sql` | Wrong table; not the orders DDL owner for this defect |
| `sql/migrations/0079_create_did_advanced_rpc.sql` | Historical `call_customer_pickup()` source superseded by `0094`; do not edit |
| `sql/migrations/0081_create_customer_app_rpc.sql` | Existing code already uses intended column names; no function edit approved |
| `sql/migrations/0094_fix_i18n_hardcoded_strings.sql` | Existing live code already uses intended column name; no function edit approved |
| `0016`, `0029`, `0043`, `0045`, `0051`, `0070`, `0106` KDS `ready_at` files | These target `catchmenu_kds.kds_tickets.ready_at`, a separate existing column |
| `chk_order_status` / `PICKED_UP` changes | Separate drift, not approved here |
| `point_ledger` fix | Separate blocker candidate |
| `discount_pct` / coupon schema fix | Separate blocker candidate |
| Flutter/runtime code | Out of scope |
| Tools scripts | Out of scope |
| Documentation outside this workpacket lifecycle | Out of scope unless separately requested |

Implementation must not:

- Add `not null` to either new column.
- Add default values to either new column.
- Add check constraints for temporal ordering.
- Rename existing fields.
- Remove or alter `requested_pickup_at` or `ready_at` references in functions.
- Resolve `PICKED_UP` status drift.
- Modify KDS ticket lifecycle behavior.

## 4. Required Migration Header Content

The new migration must include a concise header documenting:

- Purpose: add missing order-level pickup/ready timing columns.
- Depends on: `0151_create_check_kds_capacity_function.sql`.
- Creates:
  - `catchmenu_pos.orders.requested_pickup_at`
  - `catchmenu_pos.orders.ready_at`
- Background:
  - `place_takeout_order()` writes `requested_pickup_at`.
  - `track_takeout_order()` reads `ready_at` and `requested_pickup_at`.
  - live `call_customer_pickup()` from `0094` writes `ready_at`.
- Scope boundary:
  - does not modify function bodies,
  - does not modify KDS `ready_at`,
  - does not resolve `PICKED_UP`, `point_ledger`, or `discount_pct`.

## 5. Required Behavior Preservation

The implementation must preserve:

- Existing `catchmenu_pos.orders` data.
- Existing `orders` constraints and indexes.
- Existing `order_status` allowed values.
- Existing function signatures.
- Existing `0081` and `0094` function bodies.
- Existing `catchmenu_kds.kds_tickets.ready_at` behavior.

Because `catchmenu_pos.orders` currently has 0 rows in local verification, no backfill is required for local. The migration must still be safe for non-empty environments because both new columns are nullable and have no default.

## 6. Required New Behavior

After implementation:

- `catchmenu_pos.orders.requested_pickup_at` exists.
- `catchmenu_pos.orders.ready_at` exists.
- `place_takeout_order()` can insert `p_requested_pickup_at`.
- `track_takeout_order()` can select `o.ready_at` and `o.requested_pickup_at`.
- `call_customer_pickup()` can set `orders.ready_at` when `p_queue_type = 'PICKUP_READY'`.

## 7. Verification Requirements

Implementation must be verified against `600473_TestPlan.md`.

Required verification groups:

1. Schema check for the two new nullable `timestamptz` columns.
2. `place_takeout_order()` execution reaches past former `requested_pickup_at` INSERT blocker.
3. `track_takeout_order()` executes successfully against a rollback-scoped dummy order.
4. `call_customer_pickup()` sets `orders.ready_at` for `PICKUP_READY`.
5. KDS `ready_at` sanity check confirms the seven KDS files are untouched.
6. `PICKED_UP` status drift remains unchanged and documented only as an Open Item.
7. Boundary check confirms only the new migration file changed.
8. `git diff --check` passes.

## 8. Open Items Not Approved In This Contract

### 8.1 `PICKED_UP` Status Drift

`call_customer_pickup()` contains:

```sql
order_status not in (
  'READY', 'PICKED_UP',
  'COMPLETED', 'CANCELLED'
)
```

but `chk_order_status` does not allow `PICKED_UP`.

This is a no-op drift in a WHERE exclusion condition, not the missing-column hard error addressed here.

This ChangeContract does not approve:

- adding `PICKED_UP` to `chk_order_status`,
- removing `PICKED_UP` from the function,
- changing order completion/pickup lifecycle semantics.

### 8.2 `point_ledger` Blocker

Known `place_takeout_order()` downstream point ledger issues remain separate.

This ChangeContract does not approve any point ledger fix.

### 8.3 `discount_pct` / Coupon Schema Blocker

Known coupon schema mismatch remains separate.

This ChangeContract does not approve:

- adding `discount_pct`,
- changing coupon discount literals,
- rewriting coupon logic.

## 9. Risk

Risk level: MEDIUM.

Reasons:

- The change is schema-only and additive.
- Both columns are nullable with no default.
- Local `orders` table currently has 0 rows.
- However, the table is central to order, tracking, and DID pickup flows.

Risk controls:

- Forward migration only.
- Two-column additive change only.
- No function edits.
- No constraint/default additions.
- Rollback-wrapped behavioral verification.
- Explicit exclusion of KDS `ready_at` files and `PICKED_UP` drift.

## 10. Human Boundary Approval

Human approval is required before Stage 4 implementation.

☑ I approve creating only sql/migrations/0152_add_orders_pickup_ready_timing_columns.sql.
☑ I approve adding nullable requested_pickup_at timestamptz and nullable ready_at timestamptz to catchmenu_pos.orders.
☑ I acknowledge that 0081, 0094, 0079, KDS ready_at files, PICKED_UP, point_ledger, and discount_pct remain out of scope for this workpacket.

## 11. Stage 4 Instruction If Approved

If all three Human approval boxes in §10 are checked, Stage 4 may proceed to implement exactly this contract.

If any box remains unchecked, Stage 4 must stop and report that implementation is not authorized.

