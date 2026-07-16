# 600643_TestPlan.md

Status: Draft
Lifecycle: TestPlan
Stage: 2 Test Plan
Owner: Codex
Revision: 2 (Claude Code, 2026-07-16) — added §4.3 (pre_order_amount coverage for call_next_waiting_customer()) and §6.2 (true cross-path call-count accumulation), per independent verification findings
Last Updated: 2026-07-16

## Change ID

`call_waiting_customer_contract_recovery`

## §0 Purpose

This TestPlan verifies the confirmed `600641` / `600642` design for recovering the waiting-call contract.

The implementation under test is expected to:

- introduce internal helper `catchmenu_pos._record_waiting_call()`,
- redefine `catchmenu_pos.call_waiting_customer()` with the existing `0115` name/signature,
- create public `catchmenu_pos.call_next_waiting_customer()`,
- drop legacy `catchmenu_pos.call_next_waiting()` from `0050`,
- use `catchmenu_store.store_settings.wait_call_expire_minutes` as the canonical call-expiry setting,
- mark `store_settings.no_show_auto_expire_minutes` as deprecated by COMMENT only,
- avoid new schema columns.

The helper is internal and is not tested directly. Its behavior is covered through the two public functions.

## §1 Preconditions

### §1.1 Function inventory before implementation

Before Stage 4 changes, record current function state:

```sql
select
  n.nspname,
  p.proname,
  pg_get_function_identity_arguments(p.oid) as args
from pg_proc p
join pg_namespace n on n.oid = p.pronamespace
where n.nspname = 'catchmenu_pos'
  and p.proname in (
    '_record_waiting_call',
    'call_waiting_customer',
    'call_next_waiting',
    'call_next_waiting_customer'
  )
order by p.proname, args;
```

Expected before implementation:

- `call_waiting_customer(...)` exists.
- `call_next_waiting(...)` exists.
- `_record_waiting_call(...)` does not exist.
- `call_next_waiting_customer(...)` does not exist.

Expected after implementation:

- `_record_waiting_call(...)` exists.
- `call_waiting_customer(...)` exists with the existing `0115` signature.
- `call_next_waiting_customer(...)` exists.
- `call_next_waiting(...)` no longer exists.

### §1.2 Store setting inventory

Confirm both setting columns exist before implementation:

```sql
select column_name, data_type, is_nullable, column_default
from information_schema.columns
where table_schema = 'catchmenu_store'
  and table_name = 'store_settings'
  and column_name in (
    'wait_call_expire_minutes',
    'no_show_auto_expire_minutes'
  )
order by column_name;
```

Expected:

- `wait_call_expire_minutes` exists.
- `no_show_auto_expire_minutes` exists.
- no new setting column is required.

### §1.3 Test isolation

All live execution tests must run in transactions and end with `ROLLBACK`, unless the test is only reading metadata.

Any temporary helper used for concurrency orchestration must:

- start with `__test_`,
- include a verifier-specific suffix if multiple verifiers run in parallel,
- be dropped before the test completes.

## §2 Test A — `call_waiting_customer()` state gate and success paths

### §2.1 WAITING succeeds

Setup:

1. Create a test `order_sessions` row in `WAITING`.
2. Ensure the store has a known `wait_call_expire_minutes` value.
3. Call:

```sql
select catchmenu_pos.call_waiting_customer(
  p_tenant_id := '<tenant_id>'::uuid,
  p_store_id := '<store_id>'::uuid,
  p_session_id := '<waiting_session_id>'::uuid,
  p_table_number := 'T-01',
  p_actor_id := '<actor_id>'::uuid,
  p_locale := 'ko',
  p_correlation_id := '__test_call_waiting_waiting'
);
```

Expected:

- `success = true`.
- `order_sessions.session_status = 'ARRIVAL_PENDING'`.
- `order_sessions.expires_at` is set.
- `session_events` contains `event_type = 'customer_called'`.
- `catchmenu_ledger.events` contains the corresponding waiting-call event.
- response/event payload may include table suggestion, but `order_sessions` does not store `table_number`.

### §2.2 ARRIVAL_PENDING succeeds as recall

Setup:

1. Use the same session after §2.1 or create a fresh `ARRIVAL_PENDING` test session.
2. Record the previous `expires_at`.
3. Call `call_waiting_customer()` again.

Expected:

- `success = true`.
- status remains `ARRIVAL_PENDING`.
- `expires_at` is re-snapshotted and is later than the previous value.
- `session_events` now has two `customer_called` events for the session.
- `call_count`, derived as `count(*)` from `session_events`, equals 2.

### §2.3 Non-callable states are rejected

Run separate test rows for at least:

- `SEATED`
- `COMPLETED`

Call `call_waiting_customer()` for each.

Expected:

- `success = false`.
- no `customer_called` session event is inserted.
- no waiting-call ledger event is inserted.
- session status does not change.

If additional terminal states are easy to instantiate, include them as regression coverage.

## §3 Test B — `call_waiting_customer()` payload/source-of-truth behavior

### §3.1 `table_number` is not stored on session

Call `call_waiting_customer()` with `p_table_number`.

Verify:

```sql
select *
from information_schema.columns
where table_schema = 'catchmenu_pos'
  and table_name = 'order_sessions'
  and column_name = 'table_number';
```

Expected:

- zero rows.
- implementation must not add `order_sessions.table_number`.

Then verify the table suggestion appears only in allowed places:

- function response payload, if included,
- `session_events.event_payload`,
- `catchmenu_ledger.events.event_payload`,
- notification payloads, if observable in the function output/log.

### §3.2 `pre_order_amount` comes from `orders.final_amount`

Create a session with `pre_order_created_at is not null` and a linked order with known `final_amount`.

Call `call_waiting_customer()`.

Expected:

- `has_pre_order = true`.
- returned/prepared `pre_order_amount` equals linked `orders.final_amount`.
- no reference to `order_sessions.pre_order_amount` remains in the live function definition.

Verification:

```sql
select position('pre_order_amount' in pg_get_functiondef(
  'catchmenu_pos.call_waiting_customer(uuid,uuid,uuid,text,uuid,text,text)'::regprocedure
));
```

The string may still appear as a response variable/key, but it must not appear as `v_session.pre_order_amount` sourced from `order_sessions`.

## §4 Test C — `call_next_waiting_customer()` automatic selection

### §4.1 Oldest/lowest queue position selected

Setup:

1. Create at least three `WAITING` sessions for the same tenant/store.
2. Give them different `queue_position` / `wait_number` / `session_started_at` values.
3. Call:

```sql
select catchmenu_pos.call_next_waiting_customer(
  p_tenant_id := '<tenant_id>'::uuid,
  p_store_id := '<store_id>'::uuid,
  p_actor_id := '<actor_id>'::uuid,
  p_locale := 'ko',
  p_correlation_id := '__test_call_next_waiting_1'
);
```

Expected:

- the selected session is the earliest by the confirmed ordering:
  - `coalesce(queue_position, wait_number) asc nulls last`,
  - `session_started_at asc`.
- selected session becomes `ARRIVAL_PENDING`.
- non-selected sessions remain `WAITING`.
- exactly one `customer_called` session event is inserted for the selected session.

### §4.2 No waiting session found

Setup:

- no sessions in `WAITING` for the tenant/store.

Call `call_next_waiting_customer()`.

Expected:

- `success = false`.
- error key is `no_waiting_session_found`.
- no session/event rows are changed.

### §4.3 `pre_order_amount` comes from `orders.final_amount` (auto-selected session)

Same requirement as §3.2, verified for the automatic-selection path — `600642_Logic.md` §1.4 states both public functions use the identical `orders` join, so both must be independently verified.

Setup:

1. Create a `WAITING` session with `pre_order_created_at is not null` and a linked order with a known `final_amount`.
2. Ensure it is the earliest session by the confirmed queue ordering (§4.1), so it is the one auto-selected.
3. Call `call_next_waiting_customer()`.

Expected:

- `success = true`, the session from step 1 is selected.
- `has_pre_order = true`.
- returned/prepared `pre_order_amount` equals the linked `orders.final_amount`.
- no reference to `order_sessions.pre_order_amount` remains in the live function definition:

```sql
select position('pre_order_amount' in pg_get_functiondef(
  'catchmenu_pos.call_next_waiting_customer(uuid,uuid,uuid,text,text)'::regprocedure
));
```

The string may still appear as a response variable/key, but it must not appear as `v_session.pre_order_amount` sourced directly from `order_sessions`.

## §5 Test D — `call_next_waiting_customer()` concurrency / `SKIP LOCKED`

### §5.1 Two concurrent calls choose different sessions

Setup:

1. Create at least two `WAITING` sessions for the same tenant/store.
2. Use two independent DB sessions.
3. In both sessions, call `call_next_waiting_customer()` concurrently.

Implementation note:

- If a test helper is needed to hold locks and widen the race window, use `__test_` prefix and drop it immediately after the test.

Expected:

- both calls succeed if two waiting sessions exist.
- each call returns/updates a different session.
- both sessions become `ARRIVAL_PENDING`.
- no duplicate selection occurs.
- `session_events` contains one `customer_called` event per selected session.

### §5.2 Race boundary when only one waiting session exists

Setup:

- create exactly one `WAITING` session.
- run two concurrent calls.

Expected:

- one call succeeds.
- the other returns `no_waiting_session_found` or equivalent no-row result after `SKIP LOCKED`.
- no duplicate event is created for the same automatic selection.

## §6 Test E — cross-path call count accumulation

### §6.1 Same-function accumulation (`call_waiting_customer()` twice)

Setup:

1. Create one `WAITING` session.
2. Call `call_waiting_customer()` once.
3. Call `call_waiting_customer()` again for the same `ARRIVAL_PENDING` session.

Expected:

- `session_events` count for `event_type = 'customer_called'` is 2.
- derived `call_count` is 2.

If Stage 4 exposes `call_count` in either function response, verify it matches the event count.

### §6.2 True cross-path accumulation (`call_next_waiting_customer()` then `call_waiting_customer()` recall)

This is a realistic operational sequence — the system auto-calls the next customer, then staff manually recalls the same customer later — and is the only scenario that actually exercises both public functions writing to the same session's call history through the shared helper. This supersedes the previous (incorrect) "cross-path consistency cannot be tested" note.

Setup:

1. Create one `WAITING` session (only one, or ensure it is the earliest by the confirmed queue ordering so §5's `call_next_waiting_customer()` selects it deterministically).
2. Call `call_next_waiting_customer()` — the session transitions `WAITING` → `ARRIVAL_PENDING`.
3. Call `call_waiting_customer()` with the same `p_session_id` — a recall on the now-`ARRIVAL_PENDING` session.

Expected:

- both calls return `success = true`.
- `session_events` count for `event_type = 'customer_called'` on this session is exactly 2.
- the first `session_events` row (from step 2) has `from_status = 'WAITING'`, `to_status = 'ARRIVAL_PENDING'`.
- the second `session_events` row (from step 3) has `from_status = 'ARRIVAL_PENDING'`, `to_status = 'ARRIVAL_PENDING'`.
- derived `call_count` (via `count(*)` on `session_events`) is 2 immediately after step 3, confirming the two public functions accumulate into the same counter through `_record_waiting_call()`.
- `order_sessions.expires_at` after step 3 reflects the step-3 snapshot (later than the step-2 value), per §2.2's re-snapshot behavior.

## §7 Test F — store-specific `wait_call_expire_minutes`

Setup:

1. Create or update two test stores with different `wait_call_expire_minutes` values.
2. Create one waiting session per store.
3. Call either public function for each store.

Expected:

- each session's `expires_at` reflects that store's configured value.
- `no_show_auto_expire_minutes` is not used for the calculation.
- changing `wait_call_expire_minutes` before a recall causes the next call to snapshot the new configured duration.

### §7.1 Deprecated comment check

After implementation, verify:

```sql
select col_description(
  'catchmenu_store.store_settings'::regclass,
  (
    select ordinal_position
    from information_schema.columns
    where table_schema = 'catchmenu_store'
      and table_name = 'store_settings'
      and column_name = 'no_show_auto_expire_minutes'
  )
);
```

Expected:

- comment contains `DEPRECATED`.
- column still exists.
- column is not dropped.

## §8 Test G — event and ledger consistency

For both public paths:

- `call_waiting_customer()`
- `call_next_waiting_customer()`

Verify:

```sql
select event_type, from_status, to_status, event_payload
from catchmenu_pos.session_events
where session_id = '<session_id>'::uuid
  and event_type = 'customer_called';
```

Expected:

- event type is `customer_called`.
- `from_status` reflects the actual previous state:
  - `WAITING` for first call,
  - `ARRIVAL_PENDING` for recall.
- `to_status = 'ARRIVAL_PENDING'`.
- payload includes `wait_number`, `expires_at`, and `has_pre_order`.

Also verify the corresponding ledger event exists in `catchmenu_ledger.events` with matching tenant/store/session context and correlation id.

## §9 Test H — legacy function dropped

After implementation:

```sql
select
  p.proname,
  pg_get_function_identity_arguments(p.oid) as args
from pg_proc p
join pg_namespace n on n.oid = p.pronamespace
where n.nspname = 'catchmenu_pos'
  and p.proname = 'call_next_waiting';
```

Expected:

- zero rows.

Verify replacement exists:

```sql
select
  p.proname,
  pg_get_function_identity_arguments(p.oid) as args
from pg_proc p
join pg_namespace n on n.oid = p.pronamespace
where n.nspname = 'catchmenu_pos'
  and p.proname = 'call_next_waiting_customer';
```

Expected:

- one row.

## §10 Boundary Verification

### §10.1 Source diff boundary

Verify diff is limited to approved scope:

- `0115_create_waiting_pipeline_rpc.sql` function body for `call_waiting_customer()` if using §24 in-place source sync.
- new forward migration for helper/new public function/drop/comment, if chosen.
- no unapproved files.

Explicit zero-diff checks:

- `sql/migrations/0118_create_schema_validation_update.sql`
- `confirm_arrival()` body in `0115_create_waiting_pipeline_rpc.sql`
- payment confirmation files
- refund/cancel files
- Flutter/runtime files

### §10.2 Schema boundary

Verify no new columns were added:

```sql
select table_schema, table_name, column_name
from information_schema.columns
where (table_schema, table_name, column_name) in (
  ('catchmenu_pos', 'order_sessions', 'called_at'),
  ('catchmenu_pos', 'order_sessions', 'call_count'),
  ('catchmenu_pos', 'order_sessions', 'table_number'),
  ('catchmenu_pos', 'order_sessions', 'pre_order_amount')
);
```

Expected:

- zero rows.

Verify `no_show_auto_expire_minutes` still exists and was not dropped.

## §11 Acceptance Criteria

Stage 4 passes this TestPlan only if:

1. `call_waiting_customer()` works for `WAITING` and `ARRIVAL_PENDING`.
2. `call_waiting_customer()` rejects non-callable states.
3. `call_next_waiting_customer()` selects the next waiting session correctly.
4. `call_next_waiting_customer()`'s `pre_order_amount`/`has_pre_order` are correctly sourced from `orders.final_amount`, not `order_sessions.pre_order_amount` (§4.3).
5. concurrent automatic calls do not select the same session.
6. both public paths produce `customer_called` session events.
7. call count is correctly derivable from `session_events`, both within a single path (§6.1) and across paths — `call_next_waiting_customer()` followed by a `call_waiting_customer()` recall on the same session (§6.2).
8. `wait_call_expire_minutes` controls `expires_at`.
9. `no_show_auto_expire_minutes` remains only as deprecated.
10. no phantom `order_sessions` columns are added.
11. `0118` cron and `confirm_arrival()` remain untouched.

## §12 Open Items Carried Forward

The following remain outside this TestPlan:

1. Actual `0118` cron correction.
2. `confirm_arrival()` phantom-column repair.
3. `no_show_auto_expire_minutes` physical DROP.
4. Staff Flutter implementation.
5. Non-waiting no-show types:
   - pickup no-show,
   - reservation no-show,
   - group/catering no-show,
   - delivery contact failure.
6. Customer-level no-show blacklist/penalty system.
