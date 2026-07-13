# 600463_TestPlan.md

Status: Draft
Lifecycle: TestPlan
Stage: 2 (Claude review / verification planning)
Owner: TBD
Last Updated: 2026-07-13

## Change ID

`takeout_session_type_fix`

## 0. Authority And Scope

This TestPlan is derived from:

- `600461_Overview.md`
- `600462_Logic.md`

Confirmed design, without reopening design judgment:

- `sql/migrations/0081_create_customer_app_rpc.sql`
  - `catchmenu_store.place_takeout_order()` inserts into `catchmenu_pos.order_sessions`.
  - The `session_type` literal at L826 must change from `'ONLINE'` to `'TAKEOUT'`.
- `sql/migrations/0063_patch_core_rpc_i18n_diagnostics.sql`
  - The second overload of `catchmenu_pos.create_order_session()` validates `p_session_type`.
  - Its validation array must change from allowing `'ONLINE'` to allowing `'TAKEOUT'`.
  - Four status/state mapping blocks must explicitly map `TAKEOUT -> ORDERING`, using `0025_create_session_rpc.sql` L71 as the reference value.
- The `0063` L202-206 `DELIVERY` branch omission is a separate defect and is not fixed here.
- The `0025` vs `0063` `WALK_IN` mapping mismatch is a separate defect and is not fixed here.

## 1. Verification Environment

All execution tests must run against local Supabase Docker DB only.

Requirements:

- Wrap data-mutating tests in `BEGIN; ... ROLLBACK;`.
- Do not leave test sessions, orders, ledger events, session events, point rows, coupon rows, payment rows, or KDS rows behind.
- Do not modify `0025`, `point_ledger`, coupon schema, `discount_pct`, `DELIVERY`, or `WALK_IN` logic during verification.
- After implementation, verify the live function bodies with `pg_get_functiondef()` before scenario execution.

Suggested live-body checks:

```sql
select pg_get_functiondef(
  'catchmenu_store.place_takeout_order'::regproc
);
```

The live body must contain the `order_sessions` insert with:

```sql
'TAKEOUT', 'ORDER_CONFIRMED'
```

and must no longer contain the old L826 insert pair:

```sql
'ONLINE', 'ORDER_CONFIRMED'
```

For `0063`, use the exact second overload signature when inspecting `pg_get_functiondef()`. The body must show:

- validation array includes `'TAKEOUT'`
- validation array does not include `'ONLINE'`
- four status/state mapping blocks include `when 'TAKEOUT' then 'ORDERING'`

## 2. Test A — `place_takeout_order()` Reaches Past `chk_session_type`

Purpose:

- Confirm the former `session_type = 'ONLINE'` path no longer violates `chk_session_type`.
- Confirm the function now reaches the next known execution point.

Execution shape:

```sql
begin;

select catchmenu_store.place_takeout_order(
  p_tenant_id := '<test tenant uuid>'::uuid,
  p_store_id := '<test store uuid>'::uuid,
  p_items := '<valid minimal menu item jsonb>'::jsonb,
  p_customer_id := null,
  p_phone_hash := null,
  p_locale := 'ko',
  p_memo := null,
  p_coupon_issue_id := null,
  p_use_points := 0,
  p_requested_pickup_at := null,
  p_correlation_id := 'verify-600463-place-takeout'
);

rollback;
```

Parameter names re-verified this turn against the live signature (`pg_get_function_arguments` on `catchmenu_store.place_takeout_order`, single overload confirmed — `select count(*) ... = 1`):

| Draft (previous) | Live (confirmed) | Note |
|---|---|---|
| `p_menu_items` | `p_items` | Wrong name in the draft — does not exist on the live function. |
| `p_guest_count` | *(no such parameter)* | Removed — `place_takeout_order()` has no `p_guest_count` parameter at all; `guest_count` is hardcoded to `1` inside the function body's `order_sessions` insert (L297 area), not caller-supplied. Passing `p_guest_count := 1` in named notation would raise "function ... does not have parameter". |
| `p_request_memo` | `p_memo` | Confirmed already renamed (matches `600450` workpacket's earlier `p_request_memo`→`p_memo` rename) — the previous draft's conditional note ("if already renamed, use `p_memo`") is now resolved: it has been renamed, so `p_memo` is used unconditionally. |
| *(not present in draft)* | `p_requested_pickup_at` | Newly discovered this turn — a real parameter (`timestamptz default null`) missing from the draft entirely. Has a default so omitting it would not break the call, but it is included explicitly above for completeness since the draft's coverage of the live signature was otherwise incomplete. |
| `p_tenant_id`/`p_store_id`/`p_customer_id`/`p_phone_hash`/`p_locale`/`p_coupon_issue_id`/`p_use_points`/`p_correlation_id` | (unchanged) | Confirmed correct as drafted. |

Expected result:

- No error from `chk_session_type` rejecting `'ONLINE'`.
- The function either succeeds or reaches the next known unrelated blocker, such as:
  - point ledger path,
  - coupon/`discount_pct` path,
  - another already-known downstream issue depending on the input combination.

PASS condition:

- The error `new row for relation "order_sessions" violates check constraint "chk_session_type"` caused by `session_type = 'ONLINE'` is gone.

FAIL condition:

- Any failure still indicates `session_type = 'ONLINE'` was inserted into `catchmenu_pos.order_sessions`.

## 3. Test B — `create_order_session()` Second Overload Accepts `TAKEOUT`

Purpose:

- Confirm the `0063` second overload accepts `p_session_type := 'TAKEOUT'`.
- Confirm its status/state outputs consistently use `ORDERING`.

The target function is the second overload from `0063_patch_core_rpc_i18n_diagnostics.sql`, identified by parameters including:

- `p_wait_number`
- `p_queue_position`
- `p_pre_order_expires_at`

Execution shape:

```sql
begin;

select catchmenu_pos.create_order_session(
  p_tenant_id := '<test tenant uuid>'::uuid,
  p_store_id := '<test store uuid>'::uuid,
  p_session_type := 'TAKEOUT',
  p_guest_count := 1,
  p_guest_locale := 'ko',
  p_wait_number := null,
  p_queue_position := null,
  p_pre_order_expires_at := null,
  p_correlation_id := 'verify-600463-create-takeout'
);

-- If the function returns a session id, inspect the rollback-scoped rows:
select id, session_type, session_status
from catchmenu_pos.order_sessions
where correlation_id = 'verify-600463-create-takeout';

select event_type, from_status, to_status
from catchmenu_pos.session_events
where correlation_id = 'verify-600463-create-takeout'
order by created_at desc;

select event_domain, event_type, from_state, to_state
from catchmenu_ledger.events
where correlation_id = 'verify-600463-create-takeout'
order by occurred_at desc;

rollback;
```

Expected result:

- Function call succeeds for `p_session_type := 'TAKEOUT'`.
- `catchmenu_pos.order_sessions.session_type = 'TAKEOUT'`.
- `catchmenu_pos.order_sessions.session_status = 'ORDERING'`.
- `catchmenu_pos.session_events.to_status = 'ORDERING'`.
- `catchmenu_ledger.events.to_state = 'ORDERING'` for the created session event.
- RPC return payload includes `session_status = 'ORDERING'`.

PASS condition:

- All four observable outputs are consistent with `TAKEOUT -> ORDERING`:
  1. `order_sessions.session_status`
  2. `session_events.to_status`
  3. `ledger.events.to_state`
  4. RPC return `data.session_status`

FAIL condition:

- `TAKEOUT` is rejected.
- Any of the four outputs falls through to `WAITING`.
- Any output uses `ONLINE`.

## 4. Test C — `create_order_session()` Rejects `ONLINE` At Function Validation

Purpose:

- Confirm the function's own validation now rejects `ONLINE`.
- Confirm rejection happens at the explicit `p_session_type not in (...)` validation before any table constraint is involved.

Execution shape:

```sql
begin;

select catchmenu_pos.create_order_session(
  p_tenant_id := '<test tenant uuid>'::uuid,
  p_store_id := '<test store uuid>'::uuid,
  p_session_type := 'ONLINE',
  p_guest_count := 1,
  p_guest_locale := 'ko',
  p_wait_number := null,
  p_queue_position := null,
  p_pre_order_expires_at := null,
  p_correlation_id := 'verify-600463-create-online-reject'
);

rollback;
```

Expected result:

- The function rejects `ONLINE`.
- The observed error or failure response must correspond to the function-level invalid `session_type` validation.
- The failure must not be a later `chk_session_type` table constraint error.

PASS condition:

- `ONLINE` is rejected by the explicit function validation at L44-47 equivalent.

FAIL condition:

- `ONLINE` is still accepted by function validation.
- The failure reaches table insert and only then fails by `chk_session_type`.

## 5. Out-Of-Scope Items To Record, Not Test As Fixes

The following are known findings but are not verification targets for this workpacket:

| Item | Reason |
|---|---|
| `0063` L202-206 missing `DELIVERY -> ORDER_CONFIRMED` branch | Separate existing mapping defect; not part of the approved six TAKEOUT/ONLINE corrections |
| `0025` maps `WALK_IN -> SEATED` while `0063` maps `WALK_IN -> ORDERING` | Separate overload alignment issue; changing it would alter WALK_IN semantics |
| `point_ledger` downstream behavior | Separate known downstream blocker candidate |
| `discount_pct` / coupon schema behavior | Separate known downstream blocker candidate |

If any of these appears during execution, record it as a known or newly observed out-of-scope issue. Do not treat it as failure of the TAKEOUT session-type correction unless it prevents confirming that the former `ONLINE` defect is gone.

## 6. Static Boundary Verification

Run read-only source checks after implementation:

```powershell
git diff -- sql/migrations/0081_create_customer_app_rpc.sql
git diff -- sql/migrations/0063_patch_core_rpc_i18n_diagnostics.sql
git diff --check
```

Expected diff boundary:

- `0081`: exactly the `place_takeout_order()` L826 literal change from `'ONLINE'` to `'TAKEOUT'`.
- `0063`: exactly:
  - validation array `'ONLINE'` to `'TAKEOUT'`
  - `when 'TAKEOUT' then 'ORDERING'` added in four approved `case p_session_type` blocks.
- No `0025` changes.
- No `DELIVERY` branch addition.
- No `WALK_IN` mapping change.
- No point ledger or coupon schema change.

## 7. Acceptance Criteria

This TestPlan passes if:

1. `place_takeout_order()` no longer fails at `chk_session_type` because of `ONLINE`.
2. `create_order_session()` second overload accepts `TAKEOUT`.
3. The second overload maps `TAKEOUT` to `ORDERING` consistently across insert, session event, ledger event, and RPC response.
4. `ONLINE` is rejected by function-level validation.
5. Known `DELIVERY`, `WALK_IN`, point ledger, and `discount_pct` findings remain out of scope and are not silently fixed.
6. `git diff --check` passes.

