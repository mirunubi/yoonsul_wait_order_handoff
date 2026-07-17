# 600653_TestPlan_Seat_Waiting_Customer_Facade_Correction.md

Status: Draft
Lifecycle: TestPlan
Stage: 5 (Claude Code contract drafting, per `000701_Guide_Controlled_AI_Development_Pipeline.md` §3's 13-stage structure)
Owner: TBD
Last Updated: 2026-07-18

## Change ID

`seat_waiting_customer_facade_correction`

## §0 Scope and numbering confirmation

This TestPlan covers the Stage 8 implementation of `600652_Logic_Seat_Waiting_Customer_Facade_Correction.md` §1-§6 — the new internal helper `catchmenu_pos._resolve_dining_table_by_number()` and the rewritten `catchmenu_pos.seat_waiting_customer()` facade, in a new migration file (tentatively `sql/migrations/0163_seat_waiting_customer_facade_correction.sql`).

Document number check:

- `600651_Overview_Seat_Waiting_Customer_Facade_Correction.md` exists.
- `600652_Logic_Seat_Waiting_Customer_Facade_Correction.md` exists.
- `600653_TestPlan_Seat_Waiting_Customer_Facade_Correction.md` is the next TestPlan document number for this workpacket.
- `600654_ChangeContract_Seat_Waiting_Customer_Facade_Correction.md` is the paired ChangeContract.

Test fixtures use the `__test_dining_table_600653_*` table-code prefix (distinct from every other TestPlan's fixtures in this project) and `<test_tenant_id>`/`<test_store_id>`/`<test_actor_id>` placeholders matching this project's established convention. Every section is a self-contained `begin;...rollback;` block.

## §1 Pre-flight checks

Run before modifying or applying anything. If any Stop Condition in `600654_ChangeContract_Seat_Waiting_Customer_Facade_Correction.md` is hit, stop and report.

### §1.1 Target function does not yet exist; `seat_waiting_customer()` still has the pre-fix signature

```sql
select proname
from pg_proc
where pronamespace = 'catchmenu_pos'::regnamespace
  and proname = '_resolve_dining_table_by_number';

select pg_get_function_identity_arguments(oid)
from pg_proc
where pronamespace = 'catchmenu_pos'::regnamespace
  and proname = 'seat_waiting_customer';
```

Expected: `_resolve_dining_table_by_number` returns 0 rows (new function, not yet created). `seat_waiting_customer` returns its existing identity arguments unchanged (`p_tenant_id uuid, p_store_id uuid, p_session_id uuid, p_table_number text, p_actor_id uuid, p_locale text, p_correlation_id text`) — confirms Stage 8 has not already run.

### §1.2 `bind_table_to_session()`, `orders`, `dining_tables` — dependencies exist and are unmodified by this plan

```sql
select proname from pg_proc
where pronamespace = 'catchmenu_pos'::regnamespace and proname = 'bind_table_to_session';

select column_name, data_type from information_schema.columns
where table_schema = 'catchmenu_pos' and table_name = 'order_sessions'
  and column_name in ('order_id', 'pre_order_created_at', 'table_id')
order by column_name;
```

Expected: `bind_table_to_session` exists; `order_sessions.order_id` (uuid), `pre_order_created_at` (timestamptz), `table_id` (uuid) all present — matching `600651_Overview.md` §3's baseline.

### §1.3 `error_codes` ORDER-domain ceiling (baseline for §9)

```sql
select max(code) from catchmenu_common.error_codes where error_domain = 'ORDER';
```

Expected (as of this document's writing): `7072`. Record the live value at pre-flight time — input to §9's Stage-8-immediately-before-implementation re-check, not a fixed assumption.

## §2 Test A — normal seating: resolver FOUND → bind success → all four side effects

### §2.1 Setup

```sql
begin;

-- Table to seat at.
select catchmenu_store.upsert_dining_table(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_table_id := null, p_table_code := '__test_dining_table_600653_normal',
  p_capacity := 4, p_actor_id := '<test_actor_id>'::uuid, p_locale := 'ko'
) as resp \gset

-- Waiting session, no pre-order.
insert into catchmenu_pos.order_sessions (
  tenant_id, store_id, session_type, business_day, session_status,
  wait_number, guest_count, session_started_at
) values (
  '<test_tenant_id>'::uuid, '<test_store_id>'::uuid, 'WALK_IN', current_date, 'WAITING',
  9001, 2, now() - interval '12 minutes'
) returning id as normal_session_id \gset

select catchmenu_pos.seat_waiting_customer(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_session_id := :'normal_session_id'::uuid,
  p_table_number := '__test_dining_table_600653_normal',
  p_actor_id := '<test_actor_id>'::uuid, p_locale := 'ko'
) as seat_resp \gset
```

### §2.2 Expected result

```sql
select :'seat_resp'::jsonb ->> 'success' as success;
select :'seat_resp'::jsonb -> 'data' ->> 'table_id' as returned_table_id;
select :'seat_resp'::jsonb -> 'data' ->> 'has_pre_order' as has_pre_order;

-- order_sessions state (bind_table_to_session()'s own writes)
select session_status, table_id, seated_at is not null as has_seated_at
from catchmenu_pos.order_sessions where id = :'normal_session_id'::uuid;

-- dining_tables state (bind_table_to_session()'s own writes)
select table_status, current_session_id, occupied_since is not null as has_occupied_since
from catchmenu_store.dining_tables
where tenant_id = '<test_tenant_id>'::uuid and store_id = '<test_store_id>'::uuid
  and table_code = '__test_dining_table_600653_normal';

-- side effect 1: no diagnostic log expected (no pre-order) — see §2.4 for the pre-order variant.

-- side effect 2: remaining_queue in the response reflects other WAITING/ARRIVAL_PENDING sessions.
select :'seat_resp'::jsonb -> 'data' ->> 'remaining_queue' as remaining_queue_in_response;

-- side effect 3: two catchmenu_ledger.events rows for this seating — 'session'/'table_bound'
-- (from bind_table_to_session()) and 'waiting'/'customer_seated' (from the facade, §600652 §3).
select event_domain, event_type, event_payload ->> 'wait_duration_seconds' as wait_duration_seconds
from catchmenu_ledger.events
where subject_id = :'normal_session_id'::uuid
  and event_type in ('table_bound', 'customer_seated')
order by event_domain;

rollback;
```

Expected:

- `success = true`; `returned_table_id` = the created table's id; `has_pre_order = false`.
- `session_status = 'SEATED'`, `table_id` = the resolved table id, `has_seated_at = true`.
- `table_status = 'OCCUPIED'`, `current_session_id` = the session id, `has_occupied_since = true` — confirms `bind_table_to_session()`'s physical-occupation side effect actually fires through the facade (`600651_Overview.md` §1.3, the improvement the original broken `seat_waiting_customer()` never had).
- `remaining_queue_in_response` is a non-negative integer (exact value depends on fixture isolation — assert it is present and numeric, not that it equals a specific count, since other `begin;...rollback;` sections do not leak state into this one).
- Exactly two rows: one `event_domain='session', event_type='table_bound'` (no `wait_duration_seconds` key — that field belongs only to the facade's own event); one `event_domain='waiting', event_type='customer_seated'` with a non-null `wait_duration_seconds` roughly matching the ~12-minute gap set up in §2.1 (`600652_Logic.md` §3 — two ledger events by design, not a bug).

### §2.3 Notification side effects — Realtime channel verification

`catchmenu_common.notify_channel()` does not persist to a queryable table in this codebase (it is a pure Realtime broadcast side effect) — this cannot be asserted via SQL after the fact. This TestPlan records the requirement (`600652_Logic.md` §2 steps in the "대기열 도메인 고유 부수효과" block: one `WAITING_QUEUE`/`waiting_session_seated` and one `DID_DISPLAY`/`call_dismissed` notification) as a **code-review-level check at Stage 8/9**, not a SQL-level assertion — confirm both `perform catchmenu_common.notify_channel(...)` calls are present in the live function body via `pg_get_functiondef()` and match the payload shape `600652_Logic.md` §2 specifies.

### §2.4 Pre-order variant — `orders.final_amount` LEFT JOIN returns the correct amount

```sql
begin;

select catchmenu_store.upsert_dining_table(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_table_id := null, p_table_code := '__test_dining_table_600653_preorder',
  p_capacity := 4, p_actor_id := '<test_actor_id>'::uuid, p_locale := 'ko'
) as resp \gset

insert into catchmenu_pos.order_sessions (
  tenant_id, store_id, session_type, business_day, session_status,
  wait_number, guest_count, session_started_at
) values (
  '<test_tenant_id>'::uuid, '<test_store_id>'::uuid, 'PRE_ORDER', current_date, 'WAITING',
  9002, 2, now() - interval '5 minutes'
) returning id as preorder_session_id \gset

-- Real pre-order row (mirrors 0051.create_pre_order()'s actual writes,
-- 600651_Overview.md §4.2) — order_status must NOT be a value that would
-- itself imply payment, since this is still HOLD/pre-payment.
insert into catchmenu_pos.orders (
  tenant_id, store_id, session_id, order_number,
  order_type, order_status, order_source,
  total_amount, final_amount, ordered_at, business_day
) values (
  '<test_tenant_id>'::uuid, '<test_store_id>'::uuid, :'preorder_session_id'::uuid, 'W9002',
  'TABLE', 'CONFIRMED', 'PRE_ORDER',
  15000, 15000, now(), current_date
) returning id as preorder_order_id \gset

update catchmenu_pos.order_sessions
set order_id = :'preorder_order_id'::uuid, pre_order_created_at = now()
where id = :'preorder_session_id'::uuid;

select catchmenu_pos.seat_waiting_customer(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_session_id := :'preorder_session_id'::uuid,
  p_table_number := '__test_dining_table_600653_preorder',
  p_actor_id := '<test_actor_id>'::uuid, p_locale := 'ko'
) as seat_resp \gset

select :'seat_resp'::jsonb ->> 'success' as success;
select :'seat_resp'::jsonb -> 'data' ->> 'has_pre_order' as has_pre_order;
select :'seat_resp'::jsonb -> 'data' ->> 'pre_order_amount' as pre_order_amount;
select :'seat_resp'::jsonb -> 'data' -> 'next_step' ->> 'action' as next_step_action;

select event_payload ->> 'pre_order_amount' as ledger_pre_order_amount,
       event_payload ->> 'had_pre_order' as ledger_had_pre_order
from catchmenu_ledger.events
where subject_id = :'preorder_session_id'::uuid and event_type = 'customer_seated';

rollback;
```

Expected: `success = true`; `has_pre_order = true`; `pre_order_amount = 15000` (from `orders.final_amount` via the LEFT JOIN, not any `order_sessions` column — `600652_Logic.md` §2 step 1); `next_step_action = 'PROCEED_TO_PAYMENT'`; ledger event's `pre_order_amount = 15000`, `had_pre_order = true`. A pre-fix (phantom-column) implementation could not have reached this point at all — this also serves as the primary regression proof that the crash is gone.

## §3 Test B — `waiting_table_number_required` (omitted)

```sql
begin;

insert into catchmenu_pos.order_sessions (
  tenant_id, store_id, session_type, business_day, session_status, wait_number, guest_count
) values (
  '<test_tenant_id>'::uuid, '<test_store_id>'::uuid, 'WALK_IN', current_date, 'WAITING', 9003, 2
) returning id as no_number_session_id \gset

select catchmenu_pos.seat_waiting_customer(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_session_id := :'no_number_session_id'::uuid,
  p_actor_id := '<test_actor_id>'::uuid, p_locale := 'ko'
) as resp \gset

select :'resp'::jsonb ->> 'success' as success;
select :'resp'::jsonb -> 'error' ->> 'key' as error_key;
select session_status from catchmenu_pos.order_sessions where id = :'no_number_session_id'::uuid;

rollback;
```

Expected: `success = false`; `error_key = 'waiting_table_number_required'`; `session_status` unchanged (`'WAITING'`, no partial write — `p_table_number is null` is checked before the resolver or `bind_table_to_session()` run at all, `600652_Logic.md` §2 step 3).

## §4 Test C — `waiting_table_not_found` (nonexistent code)

```sql
begin;

insert into catchmenu_pos.order_sessions (
  tenant_id, store_id, session_type, business_day, session_status, wait_number, guest_count
) values (
  '<test_tenant_id>'::uuid, '<test_store_id>'::uuid, 'WALK_IN', current_date, 'WAITING', 9004, 2
) returning id as notfound_session_id \gset

select catchmenu_pos.seat_waiting_customer(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_session_id := :'notfound_session_id'::uuid,
  p_table_number := '__test_dining_table_600653_does_not_exist',
  p_actor_id := '<test_actor_id>'::uuid, p_locale := 'ko'
) as resp \gset

select :'resp'::jsonb ->> 'success' as success;
select :'resp'::jsonb -> 'error' ->> 'key' as error_key;
select session_status, table_id from catchmenu_pos.order_sessions where id = :'notfound_session_id'::uuid;

rollback;
```

Expected: `success = false`; `error_key = 'waiting_table_not_found'`; session left untouched (`'WAITING'`, `table_id` still `NULL`).

## §5 Test D — `waiting_table_inactive` (table exists, `is_active=false`)

```sql
begin;

select catchmenu_store.upsert_dining_table(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_table_id := null, p_table_code := '__test_dining_table_600653_inactive',
  p_capacity := 4, p_actor_id := '<test_actor_id>'::uuid, p_locale := 'ko'
) as resp \gset
select :'resp'::jsonb -> 'data' ->> 'table_id' as inactive_table_id \gset

select catchmenu_store.set_dining_table_active(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_table_id := :'inactive_table_id'::uuid, p_is_active := false,
  p_actor_id := '<test_actor_id>'::uuid, p_locale := 'ko'
) as deact_resp \gset

insert into catchmenu_pos.order_sessions (
  tenant_id, store_id, session_type, business_day, session_status, wait_number, guest_count
) values (
  '<test_tenant_id>'::uuid, '<test_store_id>'::uuid, 'WALK_IN', current_date, 'WAITING', 9005, 2
) returning id as inactive_test_session_id \gset

select catchmenu_pos.seat_waiting_customer(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_session_id := :'inactive_test_session_id'::uuid,
  p_table_number := '__test_dining_table_600653_inactive',
  p_actor_id := '<test_actor_id>'::uuid, p_locale := 'ko'
) as resp \gset

select :'resp'::jsonb ->> 'success' as success;
select :'resp'::jsonb -> 'error' ->> 'key' as error_key;

rollback;
```

Expected: `success = false`; `error_key = 'waiting_table_inactive'` — distinct from `waiting_table_not_found` (the resolver found the row but flagged it inactive, `_resolve_dining_table_by_number()`'s `INACTIVE` branch, `600652_Logic.md` §1).

## §6 Test E — `waiting_table_number_ambiguous` (defensive branch, constraint temporarily lifted)

**(중요)** `uq_dining_table_store_code` is a full (non-partial) `UNIQUE (store_id, table_code)` constraint — under the live schema, two rows with the same `table_code` in the same store cannot coexist, so this branch cannot be reached by any normal `upsert_dining_table()` call sequence (`600651_Overview.md` §1.4). To exercise the defensive code path itself, this test temporarily drops the constraint **inside a transaction that always rolls back** — the constraint is restored to its live definition either explicitly (below) or automatically by the `rollback;` at the end (DDL is transactional in PostgreSQL; even if the explicit re-`ADD CONSTRAINT` step were omitted, the `rollback;` alone would already undo the `DROP CONSTRAINT`). No permanent schema change occurs.

```sql
begin;

alter table catchmenu_store.dining_tables drop constraint uq_dining_table_store_code;

insert into catchmenu_store.dining_tables (
  tenant_id, store_id, table_code, capacity
) values
  ('<test_tenant_id>'::uuid, '<test_store_id>'::uuid, '__test_dining_table_600653_ambiguous', 4),
  ('<test_tenant_id>'::uuid, '<test_store_id>'::uuid, '__test_dining_table_600653_ambiguous', 6);

-- Restore the constraint before exercising the function under test, so the
-- test also confirms the resolver's own defensive check — not just a
-- transient constraint-free window — is what produces the AMBIGUOUS result.
alter table catchmenu_store.dining_tables
  add constraint uq_dining_table_store_code unique (store_id, table_code);
```

This `ADD CONSTRAINT` on already-duplicated data will itself fail with a constraint-violation error — which is expected and fine, since the goal is only to prove the two duplicate rows exist for the resolver to see, not to actually restore uniqueness within this test. If the `ADD CONSTRAINT` step is skipped for that reason, proceed directly to the resolver/facade call below; the `rollback;` at the end restores the schema regardless.

```sql
insert into catchmenu_pos.order_sessions (
  tenant_id, store_id, session_type, business_day, session_status, wait_number, guest_count
) values (
  '<test_tenant_id>'::uuid, '<test_store_id>'::uuid, 'WALK_IN', current_date, 'WAITING', 9006, 2
) returning id as ambiguous_session_id \gset

select * from catchmenu_pos._resolve_dining_table_by_number(
  '<test_tenant_id>'::uuid, '<test_store_id>'::uuid, '__test_dining_table_600653_ambiguous'
);

select catchmenu_pos.seat_waiting_customer(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_session_id := :'ambiguous_session_id'::uuid,
  p_table_number := '__test_dining_table_600653_ambiguous',
  p_actor_id := '<test_actor_id>'::uuid, p_locale := 'ko'
) as resp \gset

select :'resp'::jsonb ->> 'success' as success;
select :'resp'::jsonb -> 'error' ->> 'key' as error_key;

rollback;
```

Expected: the direct resolver call returns `v_status = 'AMBIGUOUS'`, `v_table_id = NULL`; the facade call returns `success = false`, `error_key = 'waiting_table_number_ambiguous'`. After `rollback;`, `uq_dining_table_store_code` is confirmed still present via §1-style re-query (recommended as an explicit post-rollback pre-flight-style check the first time this test is run, to build confidence in the technique before relying on it repeatedly).

## §7 Test F — `bind_table_to_session()` delegation failures (reachability analysis + reproductions)

`600651_Overview.md` §1.2 lists five `bind_table_to_session()` failure keys. Tracing the facade's own control flow (`600652_Logic.md` §2) against each:

| `error_key` | Reachable via this facade? | Reasoning |
|---|---|---|
| `session_not_found` | **No** | The facade's own step 1 already looks up the session with the same `p_session_id`/`p_store_id`/`p_tenant_id` and holds a row lock (`for update of os`) through the rest of the call — by the time `bind_table_to_session()` re-queries the same row, it is guaranteed to still exist and be visible in the same transaction. |
| `session_not_bindable` | **Yes** | Any `session_status` outside `('WAITING','ARRIVAL_PENDING','ORDERING')` that also isn't `'SEATED'` (already caught earlier by the facade, §2.1) — e.g. `'CANCELLED'`. |
| `table_already_bound` | **Yes** (requires an artificially-constructed fixture state, §7.3) | `bind_table_to_session()`'s own logic only ever sets `table_id` together with `session_status='SEATED'` — so a session with `table_id` already set but a non-`SEATED` status doesn't arise from normal use of this facade. The test constructs this state directly to exercise the defensive check. |
| `table_not_found` (table-side) | **No** | The resolver (`_resolve_dining_table_by_number()`) already requires the row to exist before returning `FOUND`, using the same `store_id`; no physical `DELETE` path exists for `dining_tables` (`601121_Overview.md` §0.2/§3) and nothing can delete the row between the resolver's check and the bind call within one function execution (no yield point). |
| `table_not_available` | **Yes** | The resolver checks only `is_active`, never `table_status` — an active table that is currently `OCCUPIED`/`CLEANING`/`BLOCKED` passes the resolver as `FOUND` but fails `bind_table_to_session()`'s own `table_status in ('AVAILABLE','RESERVED')` check. |

This table itself is the required evidence for the two "No" rows — TestPlan coverage for `session_not_found` and `table_not_found` (table-side) consists of this reachability proof, not a live reproduction, since no live reproduction through this facade is possible. Constructing an artificial call to `bind_table_to_session()` directly (bypassing the facade) to observe those two keys firing is out of scope — `bind_table_to_session()` itself is not modified by or newly tested by this workpacket (`600651_Overview.md` §1.2, no-regression-only).

### §7.1 `session_not_bindable`

```sql
begin;

select catchmenu_store.upsert_dining_table(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_table_id := null, p_table_code := '__test_dining_table_600653_not_bindable',
  p_capacity := 4, p_actor_id := '<test_actor_id>'::uuid, p_locale := 'ko'
) as resp \gset

insert into catchmenu_pos.order_sessions (
  tenant_id, store_id, session_type, business_day, session_status, wait_number, guest_count
) values (
  '<test_tenant_id>'::uuid, '<test_store_id>'::uuid, 'WALK_IN', current_date, 'CANCELLED', 9007, 2
) returning id as cancelled_session_id \gset

select catchmenu_pos.seat_waiting_customer(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_session_id := :'cancelled_session_id'::uuid,
  p_table_number := '__test_dining_table_600653_not_bindable',
  p_actor_id := '<test_actor_id>'::uuid, p_locale := 'ko'
) as resp \gset

select :'resp'::jsonb ->> 'success' as success;
select :'resp'::jsonb ->> 'error_key' as error_key;

rollback;
```

Expected: `success = false`; **`error_key = 'session_not_bindable'`** (note: flat top-level `error_key`, not `error.key` — `600652_Logic.md` §2.1's raw pass-through, not `build_error_response()`'s nested shape). This is also the primary regression proof for §2.1's correction: the call must complete normally, not crash.

### §7.2 `table_not_available`

```sql
begin;

select catchmenu_store.upsert_dining_table(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_table_id := null, p_table_code := '__test_dining_table_600653_occupied',
  p_capacity := 4, p_actor_id := '<test_actor_id>'::uuid, p_locale := 'ko'
) as resp \gset
select :'resp'::jsonb -> 'data' ->> 'table_id' as occupied_table_id \gset

-- Occupy it via a first, unrelated seating.
insert into catchmenu_pos.order_sessions (
  tenant_id, store_id, session_type, business_day, session_status, wait_number, guest_count
) values (
  '<test_tenant_id>'::uuid, '<test_store_id>'::uuid, 'WALK_IN', current_date, 'WAITING', 9008, 2
) returning id as first_party_session_id \gset

select catchmenu_pos.seat_waiting_customer(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_session_id := :'first_party_session_id'::uuid,
  p_table_number := '__test_dining_table_600653_occupied',
  p_actor_id := '<test_actor_id>'::uuid, p_locale := 'ko'
) as first_seat_resp \gset

-- A second party tries to be seated at the SAME table_number.
insert into catchmenu_pos.order_sessions (
  tenant_id, store_id, session_type, business_day, session_status, wait_number, guest_count
) values (
  '<test_tenant_id>'::uuid, '<test_store_id>'::uuid, 'WALK_IN', current_date, 'WAITING', 9009, 3
) returning id as second_party_session_id \gset

select catchmenu_pos.seat_waiting_customer(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_session_id := :'second_party_session_id'::uuid,
  p_table_number := '__test_dining_table_600653_occupied',
  p_actor_id := '<test_actor_id>'::uuid, p_locale := 'ko'
) as second_seat_resp \gset

select :'first_seat_resp'::jsonb ->> 'success' as first_seat_ok;
select :'second_seat_resp'::jsonb ->> 'success' as second_seat_ok;
select :'second_seat_resp'::jsonb ->> 'error_key' as second_seat_error_key;

rollback;
```

Expected: `first_seat_ok = true`; `second_seat_ok = false`; `second_seat_error_key = 'table_not_available'` — the resolver found the (still `is_active=true`) table (`FOUND`), but `bind_table_to_session()` correctly rejects binding a second session to an already-`OCCUPIED` table.

### §7.3 `table_already_bound` (artificially constructed fixture state)

```sql
begin;

select catchmenu_store.upsert_dining_table(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_table_id := null, p_table_code := '__test_dining_table_600653_prebound',
  p_capacity := 4, p_actor_id := '<test_actor_id>'::uuid, p_locale := 'ko'
) as resp \gset
select :'resp'::jsonb -> 'data' ->> 'table_id' as prebound_table_id \gset

-- Directly construct the edge state bind_table_to_session()'s own logic never
-- produces on its own: table_id already set, but session_status still
-- ARRIVAL_PENDING (not SEATED) — no public RPC creates this combination.
insert into catchmenu_pos.order_sessions (
  tenant_id, store_id, session_type, business_day, session_status,
  wait_number, guest_count, table_id
) values (
  '<test_tenant_id>'::uuid, '<test_store_id>'::uuid, 'WALK_IN', current_date, 'ARRIVAL_PENDING',
  9010, 2, :'prebound_table_id'::uuid
) returning id as prebound_session_id \gset

select catchmenu_pos.seat_waiting_customer(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_session_id := :'prebound_session_id'::uuid,
  p_table_number := '__test_dining_table_600653_prebound',
  p_actor_id := '<test_actor_id>'::uuid, p_locale := 'ko'
) as resp \gset

select :'resp'::jsonb ->> 'success' as success;
select :'resp'::jsonb ->> 'error_key' as error_key;

rollback;
```

Expected: `success = false`; `error_key = 'table_already_bound'`.

## §8 Test G — `waiting_already_seated` intercepted before delegation

```sql
begin;

insert into catchmenu_pos.order_sessions (
  tenant_id, store_id, session_type, business_day, session_status, wait_number, guest_count, table_id
) values (
  '<test_tenant_id>'::uuid, '<test_store_id>'::uuid, 'WALK_IN', current_date, 'SEATED', 9011, 2, null
) returning id as already_seated_session_id \gset

select catchmenu_pos.seat_waiting_customer(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_session_id := :'already_seated_session_id'::uuid,
  p_table_number := 'anything',
  p_actor_id := '<test_actor_id>'::uuid, p_locale := 'ko'
) as resp \gset

select :'resp'::jsonb ->> 'success' as success;
select :'resp'::jsonb -> 'error' ->> 'key' as error_key;

rollback;
```

Expected: `success = false`; `error_key = 'waiting_already_seated'` (nested `error.key` — this path returns via `build_error_response()`, §600652 §2 step 2, unlike §7's flat delegation-failure responses). The resolver and `bind_table_to_session()` are never reached — `p_table_number := 'anything'` (a table_number that doesn't even resolve to a real table) is deliberately used to prove this, since if the already-seated check were bypassed, the call would instead fail with `waiting_table_not_found`, not `waiting_already_seated`.

## §9 Test H — `EXCEPTION` handler: `waiting_seat_operation_failed` + audit persistence + full-call atomicity

**(2026-07-18 재시도 성공)** §6의 "트랜잭션 안에서 제약을 임시로 조작한다"는 기법을 반대 방향으로 적용해 안전한 트리거를 찾았다 — §6은 제약을 **완화**(UNIQUE 제거)해 정상적으로는 불가능한 상태를 만들었고, 이번엔 제약을 **강화**(파사드 자신의 렛저 이벤트 INSERT 하나만 정확히 겨냥하는 신규 CHECK 추가)해서 원래는 성공했을 쓰기를 실패시킨다. 라이브로 직접 재현해 정확히 의도한 대로 작동함을 확인했다.

### §9.1 트리거 설계 — `catchmenu_ledger.events`에 임시 CHECK 추가

`600652_Logic.md` §2 재확인 결과, 이 파사드가 **직접** 쓰는 테이블은 `catchmenu_ledger.events` 하나뿐이다(`event_type='customer_seated'`, §2 step 7) — `order_sessions`/`dining_tables`에 대한 UPDATE는 전부 `bind_table_to_session()` 내부에서 일어나고, 그 함수는 건드리지 않기로 확정했다(`600654_ChangeContract.md` §4). `catchmenu_ledger.events`의 제약 전수 확인(`pg_constraint`) 결과 CHECK 5개(`chk_event_domain`/`chk_event_caused_by_type`/`chk_event_payload_object`/`chk_event_replay_has_original`/`chk_event_type_not_blank`) + FK 6개 + PK 1개, UNIQUE는 없음 — 파사드의 실제 값(`event_domain='waiting'`, `event_type='customer_seated'`, `caused_by_type='STAFF'`, `event_payload`는 항상 object)은 기존 제약을 전부 통과한다. 그래서 **`event_type = 'customer_seated'`만 정확히 겨냥하는 신규 임시 CHECK**를 추가한다:

```sql
alter table catchmenu_ledger.events
  add constraint tmp_block_customer_seated check (event_type <> 'customer_seated');
```

**정밀성 확인(라이브 재현 완료)**: 이 제약은 `bind_table_to_session()` 자신의 렛저 이벤트(`event_type='table_bound'`, 다른 값)에는 전혀 영향을 주지 않는다 — 직접 재현한 결과 `table_bound` INSERT는 성공하고, `customer_seated` INSERT만 정확히 실패한다:

```
INSERT 0 1                               -- table_bound, 성공
ERROR:  new row for relation "events" violates check constraint "tmp_block_customer_seated"  -- customer_seated, 실패
```

즉 이 기법은 `bind_table_to_session()`의 동작에는 전혀 개입하지 않고, 파사드 자신의 실행 지점(bind 위임이 이미 성공한 **이후**)에서만 정확히 예외를 유발한다.

### §9.2 **중요 발견** — 예외 발생 시 `bind_table_to_session()`의 상태 변경도 전부 롤백된다 (전체 원자성)

이 테스트를 설계하는 과정에서 라이브로 직접 재현해 확인한 핵심 사실: `bind_table_to_session()`은 자체 `EXCEPTION` 핸들러가 없는 평범한 `begin...end` 블록이다(라이브 `pg_get_functiondef()` 재확인, `600651_Overview.md` §1.2) — 즉 이 함수 자신의 실행을 위한 별도의 암묵적 SAVEPOINT가 없다. 파사드가 `bind_table_to_session()`을 호출해 성공한 뒤, **그보다 나중에** 파사드 자신의 코드에서 예외가 발생하고 파사드의 `EXCEPTION WHEN OTHERS`가 그것을 잡으면, 그 SAVEPOINT(파사드 함수 시작 시점에 설정됨)까지 롤백된다 — `bind_table_to_session()`이 이미 커밋한 것처럼 보였던 모든 변경(`order_sessions.table_id`/`session_status='SEATED'`, `dining_tables.table_status='OCCUPIED'`, `bind_table_to_session()` 자신의 `session_events`/`ledger.events`('table_bound')/`audit_records`)이 **전부 함께 롤백된다.** 오직 `EXCEPTION` 핸들러 자체가 실행하는 문장(파사드의 `append_audit_record()` 호출)만 이 롤백에서 제외되고 살아남는다.

이 사실을 최소 재현으로 직접 검증했다(임시 함수 2개, 내부 호출 + 이후 실패 + 상위 예외 핸들러 조합):

```sql
-- inner_call()이 tmp_probe_state를 UPDATE(성공) → outer_facade()가 나중에
-- 실패 → outer_facade()의 EXCEPTION 핸들러가 잡음
select pg_temp.outer_facade();  -- 'caught_and_returned'
select * from tmp_probe_state;  -- val = 'initial' (inner_call()의 UPDATE가 롤백됨!)
select * from tmp_probe_audit;  -- 예외 핸들러의 INSERT는 살아있음
```

**이것은 결함이 아니라 바람직한 원자성이다** — "착석 처리가 도중에 실패하면, 부분적으로 성공한 것처럼 보였던 테이블 점유/세션 전이까지 전부 되돌아간다"는 것을 의미한다. `601122_Logic.md`가 발견한 "예외 핸들러 안의 감사 기록조차 함께 롤백된다"는 문제(§1.5)와는 다른 지점이다 — 거기서는 감사 기록 INSERT **자체가** 실패의 원인이자 롤백 대상이었지만, 여기서는 감사 기록은 **예외 핸들러 안에서** 실행되므로 살아남고, 롤백되는 것은 그 이전에 있었던 (겉보기엔 성공한) 다른 작업들이다.

### §9.3 테스트

**전제(2026-07-18 명시, Codex+Cursor 검증)**: 이 테스트를 포함해 이 문서의 모든 섹션은 Stage 8이 `0163` 마이그레이션 파일 **전체**(§6.1이 명시한 순서 — `error_codes`/`message_catalog` INSERT 블록이 함수 정의보다 먼저)를 이미 적용한 뒤 실행된다고 가정한다. `waiting_seat_operation_failed`(§5, 코드 7077)가 아직 `error_codes`에 등록되지 않은 상태에서 이 테스트를 실행하면, `EXCEPTION` 핸들러의 `build_error_response()` 호출 자체가 (등록되지 않은 `error_key`이므로) `600652_Logic.md` §2.1이 라이브로 실증했던 것과 동일한 방식으로 크래시한다 — 즉 이 테스트가 검증하려는 대상(친절한 에러 응답)과 정확히 같은 실패 모드가, 이번엔 "미등록 `error_key`"라는 다른 원인으로 재현될 수 있다. Stage 8은 라이브 함수 재실행 절차(§6.1) 중 이 INSERT 블록을 누락하지 않았는지 먼저 `select code from catchmenu_common.error_codes where error_key='waiting_seat_operation_failed';`로 확인한 뒤 이 테스트를 실행해야 한다.

```sql
begin;

alter table catchmenu_ledger.events
  add constraint tmp_block_customer_seated check (event_type <> 'customer_seated');

select catchmenu_store.upsert_dining_table(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_table_id := null, p_table_code := '__test_dining_table_600653_exc',
  p_capacity := 4, p_actor_id := '<test_actor_id>'::uuid, p_locale := 'ko'
) as resp \gset

insert into catchmenu_pos.order_sessions (
  tenant_id, store_id, session_type, business_day, session_status, wait_number, guest_count
) values (
  '<test_tenant_id>'::uuid, '<test_store_id>'::uuid, 'WALK_IN', current_date, 'WAITING', 9012, 2
) returning id as exc_session_id \gset

select catchmenu_pos.seat_waiting_customer(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_session_id := :'exc_session_id'::uuid,
  p_table_number := '__test_dining_table_600653_exc',
  p_actor_id := '<test_actor_id>'::uuid, p_locale := 'ko'
) as resp \gset

select :'resp'::jsonb ->> 'success' as success;
select :'resp'::jsonb -> 'error' ->> 'key' as error_key;

-- §9.2가 확인한 전체 원자성 — bind_table_to_session()의 변경도 전부 롤백됐어야 한다.
select session_status, table_id from catchmenu_pos.order_sessions where id = :'exc_session_id'::uuid;
select table_status, current_session_id from catchmenu_store.dining_tables
where tenant_id = '<test_tenant_id>'::uuid and store_id = '<test_store_id>'::uuid
  and table_code = '__test_dining_table_600653_exc';

-- bind_table_to_session() 자신의 'table_bound' 이벤트/감사 기록도 함께 사라졌어야 한다.
select count(*) as bind_ledger_event_count from catchmenu_ledger.events
where subject_id = :'exc_session_id'::uuid and event_type = 'table_bound';
select count(*) as bind_audit_count from catchmenu_ledger.audit_records
where subject_id = :'exc_session_id'::uuid and audit_type = 'table_late_binding_completed';

-- 파사드 자신의 실패 감사 기록만 살아남았어야 한다.
select audit_type, decision, decision_payload ->> 'sqlstate' as recorded_sqlstate
from catchmenu_ledger.audit_records
where audit_type = 'seat_waiting_customer_failed' and subject_id = :'exc_session_id'::uuid;

alter table catchmenu_ledger.events drop constraint tmp_block_customer_seated;

rollback;
```

Expected:

- `success = false`; `error_key`(중첩) = `'waiting_seat_operation_failed'` — 클라이언트에 원본 Postgres 예외가 그대로 전파되지 않는다.
- `session_status = 'WAITING'`(원래 상태로 되돌아감, `'SEATED'` 아님), `table_id`는 `NULL`.
- `table_status = 'AVAILABLE'`(원래 상태), `current_session_id`는 `NULL`.
- `bind_ledger_event_count = 0`, `bind_audit_count = 0` — `bind_table_to_session()`이 만들었던 모든 기록이 함께 롤백됐다(§9.2).
- **정확히 한 행**: `audit_type = 'seat_waiting_customer_failed'`, `decision = 'FAILED'`, `recorded_sqlstate = '23514'`(CHECK 위반) — 이 행만 살아남는다. 이것이 `raise;`→`build_error_response()` 반환 정정(`600652_Logic.md` §2)이 실제로 작동함을 보여주는 직접 증거다.
- `alter table ... drop constraint`가 성공(또는 최종 `rollback;`이 이를 대체)해 스키마에 영구적 흔적을 남기지 않는다.

## §10 Boundary — 0 diff

```bash
git status --short sql/migrations/0025_create_session_rpc.sql
git status --short sql/migrations/0048_create_table_management_rpc.sql
git status --short sql/migrations/0050_create_waiting_queue_rpc.sql
git status --short sql/migrations/0110_create_store_admin_rpc.sql
git status --short sql/migrations/0162_create_dining_table_admin_rpc.sql
```

Expected: all empty. In particular, `bind_table_to_session()`'s body (`0025`), `catchmenu_pos.orders`/`catchmenu_store.dining_tables` schema (no migration file in this list touches their `CREATE TABLE` definitions), and the five other domains' RPCs above show zero diff. `0115_create_waiting_pipeline_rpc.sql` is **not** in this zero-diff list — the whole point of this workpacket is that `seat_waiting_customer()`'s live definition changes (via `CREATE OR REPLACE` in the new `0163` file, not by editing `0115` itself) — confirm via `git status --short sql/migrations/0115_create_waiting_pipeline_rpc.sql` that **that source file itself** still shows zero diff (the live function is overridden by the later migration, `0115`'s own text is untouched, matching how `0160` overrode `call_waiting_customer()` without editing `0115`).

## §11 Acceptance criteria

PASS only if all are true:

1. Normal seating succeeds end-to-end: resolver `FOUND` → `bind_table_to_session()` success → session `SEATED`/table `OCCUPIED` (both bind's own writes) → two ledger events (`table_bound` + `customer_seated`, distinct domains) → correct response shape (§2).
2. Pre-order seating correctly reports `has_pre_order`/`pre_order_amount` sourced from `orders.final_amount` via the `order_id` LEFT JOIN, not any phantom column (§2.4) — this is the direct proof the original crash is gone.
3. `waiting_table_number_required`/`waiting_table_not_found`/`waiting_table_inactive` each return the correct friendly error with no partial state change (§3-§5).
4. `waiting_table_number_ambiguous` is reachable via the constraint-lifted test technique and returns correctly (§6).
5. Of `bind_table_to_session()`'s five failure keys, the three reachable via this facade (`session_not_bindable`, `table_already_bound`, `table_not_available`) are reproduced and confirmed to pass through as `bind_table_to_session()`'s original flat JSON, unwrapped — with no crash (§7); the two unreachable ones (`session_not_found`, `table_not_found`) are covered by the reachability proof instead of a live reproduction.
6. `waiting_already_seated` is intercepted by the facade's own check before the resolver or `bind_table_to_session()` ever run (§8).
7. The `EXCEPTION` handler path returns `waiting_seat_operation_failed` with no raw Postgres error reaching the client, the facade's own `FAILED` audit row actually persists, and — the deeper property this test proves — `bind_table_to_session()`'s own state changes (session/table/its own ledger event/its own audit record) are all rolled back together with the exception, since it has no `EXCEPTION` handler of its own to create a separate savepoint boundary (§9, full-call atomicity).
8. `0025`/`0048`/`0050`/`0110`/`0162` all show zero diff; `0115`'s own source text shows zero diff despite `seat_waiting_customer()`'s live behavior changing via the new `0163` migration (§10).
