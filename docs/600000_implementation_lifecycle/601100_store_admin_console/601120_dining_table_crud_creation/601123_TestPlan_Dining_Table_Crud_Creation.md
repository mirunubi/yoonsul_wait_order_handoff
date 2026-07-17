# 601123_TestPlan_Dining_Table_Crud_Creation.md

Status: Draft
Lifecycle: TestPlan
Stage: 5 (Claude Code contract drafting, per `000701_Guide_Controlled_AI_Development_Pipeline.md` §3's 13-stage structure)
Owner: TBD
Last Updated: 2026-07-17

## Change ID

`dining_table_crud_creation`

## §0 Scope and numbering confirmation

This TestPlan covers the Stage 8 implementation of `601122_Logic_Dining_Table_Crud_Creation.md` §1-§6 — the three new functions `catchmenu_store.upsert_dining_table()`/`set_dining_table_active()`/`get_dining_table_admin_list()` in the new migration file (tentatively `sql/migrations/0162_create_dining_table_admin_rpc.sql`). There is no prior TestPlan to re-derive coverage from — every section below is new (`601121_Overview.md` §5).

Document number check:

- `601121_Overview_Dining_Table_Crud_Creation.md` exists.
- `601122_Logic_Dining_Table_Crud_Creation.md` exists.
- `601123_TestPlan_Dining_Table_Crud_Creation.md` is the next TestPlan document number for this workpacket.
- `601124_ChangeContract_Dining_Table_Crud_Creation.md` is the paired ChangeContract.

Test fixtures in this document use the `__test_dining_table_601123_*` table-code prefix and `TEST-DTC-*`-style markers — distinct from every other TestPlan's fixtures in this domain. Every section is a self-contained `begin;...rollback;` block, matching the isolation convention established in `601113_TestPlan.md` §4.3's correction note.

## §1 Pre-flight checks

Run before modifying or applying anything. If any Stop Condition in `601124_ChangeContract_Dining_Table_Crud_Creation.md` is hit, stop and report.

### §1.1 Target functions do not yet exist (baseline)

```sql
select proname
from pg_proc
where pronamespace = 'catchmenu_store'::regnamespace
  and proname in (
    'upsert_dining_table',
    'set_dining_table_active',
    'get_dining_table_admin_list'
  );
```

Expected: 0 rows. If any of the three already exists, Stage 8 has already run (or partially run) — re-verify via `pg_get_functiondef()` against `601122_Logic.md` §1/§2/§3 instead of re-implementing blindly.

### §1.2 `dining_tables` schema matches `601121_Overview.md` §1.1 (20 columns, all constraints)

```sql
select column_name, data_type, is_nullable, column_default
from information_schema.columns
where table_schema = 'catchmenu_store' and table_name = 'dining_tables'
order by ordinal_position;

select conname, pg_get_constraintdef(oid)
from pg_constraint
where conrelid = 'catchmenu_store.dining_tables'::regclass
order by conname;
```

Expected: exactly 20 columns matching `601121_Overview.md` §1.1's table (in particular: `table_code text not null` with no default, `capacity int not null default 4`, `display_order int not null default 0`, `table_status text not null default 'AVAILABLE'`, `is_active boolean not null default true`); `uq_dining_table_store_code UNIQUE (store_id, table_code)`, `chk_dining_table_capacity CHECK (capacity > 0)`, `chk_dining_table_status`, FKs to `device_registry` for `kds_device_id`/`did_device_id`. If the schema differs, Stop Condition (`601124_ChangeContract.md` §6 #1).

### §1.3 `order_sessions.table_id` is the only table-linkage column (no `table_number`)

```sql
select column_name, data_type
from information_schema.columns
where table_schema = 'catchmenu_pos' and table_name = 'order_sessions'
  and column_name ilike '%table%';
```

Expected: exactly one row, `table_id | uuid`. This is the pre-flight baseline for the active-session double-check in `601122_Logic.md` §1.2/§2 (`catchmenu_pos.order_sessions.session_status`) — it does not depend on the separate, out-of-scope `seat_waiting_customer()` defect (`601121_Overview.md` §6 (f)), but confirms the column this workpacket's guards actually read still exists as expected.

### §1.4 Existing operational RPCs (0 diff targets) still present, unmodified

```sql
select n.nspname, p.proname, pg_get_function_identity_arguments(p.oid)
from pg_proc p join pg_namespace n on n.oid = p.pronamespace
where (n.nspname = 'catchmenu_store' and p.proname in (
        'update_table_status', 'get_table_floor_map',
        'register_table_qr', 'release_table'
      ))
   or (n.nspname = 'catchmenu_pos' and p.proname = 'estimate_wait_time')
order by n.nspname, p.proname;
```

Expected: all 5 present (`601121_Overview.md` §1.2). These are the boundary targets for §10.

### §1.5 `error_codes` STORE-domain ceiling (baseline for §9)

```sql
select max(code) from catchmenu_common.error_codes where error_domain = 'STORE';
```

Expected (as of this document's writing): `7104`. Record whatever the live value actually is at pre-flight time — this is the input to §9's Stage-8-immediately-before-implementation re-check procedure, not a fixed assumption.

## §2 Test A — `upsert_dining_table()` creates a new table with all 8 fields

### §2.1 Setup

```sql
begin;

select catchmenu_store.upsert_dining_table(
  p_tenant_id := '<test_tenant_id>'::uuid,
  p_store_id := '<test_store_id>'::uuid,
  p_table_id := null,
  p_table_code := '__test_dining_table_601123_new',
  p_table_name := '601123 신규 테이블',
  p_capacity := 6,
  p_floor_zone := '2층',
  p_table_section := 'B구역',
  p_display_order := 15,
  p_kds_device_id := null,
  p_did_device_id := null,
  p_actor_id := '<test_actor_id>'::uuid,
  p_locale := 'ko'
) as resp \gset

select :'resp'::jsonb ->> 'success' as success;
```

### §2.2 Expected result

```sql
select
  table_code, table_name, capacity, floor_zone, table_section,
  display_order, kds_device_id, did_device_id,
  table_status, is_active
from catchmenu_store.dining_tables
where tenant_id = '<test_tenant_id>'::uuid
  and store_id = '<test_store_id>'::uuid
  and table_code = '__test_dining_table_601123_new';

rollback;
```

Expected:

- Call returns `success:true`, `data.is_new = true`, `message_code = 'table_created'`.
- All 6 explicit metadata fields match the input (`table_name = '601123 신규 테이블'`, `capacity = 6`, `floor_zone = '2층'`, `table_section = 'B구역'`, `display_order = 15`).
- `kds_device_id`/`did_device_id` are `NULL` (explicitly passed as `NULL` this call — confirms the INSERT clause accepts explicit NULL for these two nullable FKs without error, `601122_Logic.md` §1.3).
- `table_status = 'AVAILABLE'` (schema default — never passed as a parameter, `601121_Overview.md` §3).
- `is_active = true` (schema default).

### §2.3 Setup — omitted fields get generation defaults

```sql
begin;

select catchmenu_store.upsert_dining_table(
  p_tenant_id := '<test_tenant_id>'::uuid,
  p_store_id := '<test_store_id>'::uuid,
  p_table_id := null,
  p_table_code := '__test_dining_table_601123_minimal',
  p_actor_id := '<test_actor_id>'::uuid,
  p_locale := 'ko'
) as resp \gset

select :'resp'::jsonb ->> 'success' as success;

select capacity, display_order, table_name, floor_zone, table_section,
       kds_device_id, did_device_id
from catchmenu_store.dining_tables
where tenant_id = '<test_tenant_id>'::uuid
  and store_id = '<test_store_id>'::uuid
  and table_code = '__test_dining_table_601123_minimal';

rollback;
```

Expected (only `p_table_code` supplied, everything else omitted): `success:true`; `capacity = 4`; `display_order = 0`; `table_name`/`floor_zone`/`table_section`/`kds_device_id`/`did_device_id` all `NULL` (`601122_Logic.md` §1.3).

## §3 Test B — partial update preserves omitted fields (`601140` lesson applied to new code)

This is the core regression-class test for this workpacket — confirming the `default null` + `coalesce(p_x, x)` design (`601122_Logic.md` §1.4) actually preserves values on a partial update, the same property `601143_TestPlan.md` §2 verified for `upsert_menu()`.

### §3.1 Setup

```sql
begin;

-- Step 1: create with distinct, non-default values for all 8 fields —
-- including kds_device_id/did_device_id (<test_kds_device_id>/
-- <test_did_device_id> are pre-existing catchmenu_store.device_registry
-- fixture rows, same placeholder convention as <test_actor_id>).
select catchmenu_store.upsert_dining_table(
  p_tenant_id := '<test_tenant_id>'::uuid,
  p_store_id := '<test_store_id>'::uuid,
  p_table_id := null,
  p_table_code := '__test_dining_table_601123_partial',
  p_table_name := '601123 부분수정 원본',
  p_capacity := 8,
  p_floor_zone := '3층',
  p_table_section := 'C구역',
  p_display_order := 33,
  p_kds_device_id := '<test_kds_device_id>'::uuid,
  p_did_device_id := '<test_did_device_id>'::uuid,
  p_actor_id := '<test_actor_id>'::uuid,
  p_locale := 'ko'
) as resp \gset

select :'resp'::jsonb -> 'data' ->> 'table_id' as test_table_id \gset

-- Step 2: update, changing ONLY p_table_name. Every other field omitted.
select catchmenu_store.upsert_dining_table(
  p_tenant_id := '<test_tenant_id>'::uuid,
  p_store_id := '<test_store_id>'::uuid,
  p_table_id := :'test_table_id'::uuid,
  p_table_name := '601123 부분수정 변경됨',
  p_actor_id := '<test_actor_id>'::uuid,
  p_locale := 'ko'
) as resp2 \gset

select :'resp2'::jsonb ->> 'success' as success;
```

### §3.2 Expected result

```sql
select table_code, table_name, capacity, floor_zone, table_section,
       display_order, kds_device_id, did_device_id
from catchmenu_store.dining_tables
where id = :'test_table_id'::uuid;

rollback;
```

Expected: `table_code = '__test_dining_table_601123_partial'` (preserved, not required again), `table_name = '601123 부분수정 변경됨'` (the one field actually targeted), `capacity = 8`, `floor_zone = '3층'`, `table_section = 'C구역'`, `display_order = 33`, **`kds_device_id = '<test_kds_device_id>'`, `did_device_id = '<test_did_device_id>'`** — **all six preserved exactly**, not reset to any hardcoded/schema default or wiped to `NULL`. A pre-`601140`-lesson design (non-null hardcoded defaults, or simply forgetting to `coalesce` a field at all) would have incorrectly reset `capacity` to `4`, `display_order` to `0`, both zone/section fields to `NULL`, and — the two fields most likely to be overlooked since they were added in a later design revision (`601121_Overview.md` §2.4) rather than the original draft — `kds_device_id`/`did_device_id` wiped to `NULL` as well.

## §4 Test C — validation failures (`table_code` required/not-found/duplicate)

### §4.1 `table_code` omitted on the new-table path returns `table_code_required`

```sql
begin;

select catchmenu_store.upsert_dining_table(
  p_tenant_id := '<test_tenant_id>'::uuid,
  p_store_id := '<test_store_id>'::uuid,
  p_table_id := null,
  p_table_name := '테이블코드 없이 생성 시도',
  p_actor_id := '<test_actor_id>'::uuid,
  p_locale := 'ko'
) as resp \gset

select :'resp'::jsonb ->> 'success' as success;
select :'resp'::jsonb -> 'error' ->> 'key' as error_key;

select count(*) as leaked_row_count
from catchmenu_store.dining_tables
where tenant_id = '<test_tenant_id>'::uuid
  and store_id = '<test_store_id>'::uuid
  and table_name = '테이블코드 없이 생성 시도';

rollback;
```

Expected: `success = false`; `error_key = 'table_code_required'` (`601122_Logic.md` §1.2 step 2); `leaked_row_count = 0` — the validation runs before any DML, so no partial row is left behind (`601122_Logic.md` §1.2's design goal, direct application of `601114_ChangeContract.md` §2.10.1's lesson).

### §4.2 Nonexistent `p_table_id` on the update path returns `table_not_found`

```sql
begin;

select catchmenu_store.upsert_dining_table(
  p_tenant_id := '<test_tenant_id>'::uuid,
  p_store_id := '<test_store_id>'::uuid,
  p_table_id := '00000000-0000-0000-0000-00000000dead'::uuid,
  p_table_name := '존재하지 않는 테이블 수정 시도',
  p_actor_id := '<test_actor_id>'::uuid,
  p_locale := 'ko'
) as resp \gset

select :'resp'::jsonb ->> 'success' as success;
select :'resp'::jsonb -> 'error' ->> 'key' as error_key;

rollback;
```

Expected: `success = false`; `error_key = 'table_not_found'` (`601122_Logic.md` §1.2 step 1). Also confirms the same check correctly rejects an update attempt against a table that belongs to a *different* `store_id`/`tenant_id` — that scenario is structurally identical (the `where id = p_table_id and store_id = p_store_id and tenant_id = p_tenant_id` lookup returns no row either way), so it is not repeated as a separate test case.

### §4.3 `table_code` UNIQUE violation returns a friendly error — new-table path

```sql
begin;

select catchmenu_store.upsert_dining_table(
  p_tenant_id := '<test_tenant_id>'::uuid,
  p_store_id := '<test_store_id>'::uuid,
  p_table_id := null,
  p_table_code := '__test_dining_table_601123_dup',
  p_actor_id := '<test_actor_id>'::uuid,
  p_locale := 'ko'
) as resp_a \gset

select catchmenu_store.upsert_dining_table(
  p_tenant_id := '<test_tenant_id>'::uuid,
  p_store_id := '<test_store_id>'::uuid,
  p_table_id := null,
  p_table_code := '__test_dining_table_601123_dup',
  p_actor_id := '<test_actor_id>'::uuid,
  p_locale := 'ko'
) as resp_b \gset

select :'resp_a'::jsonb ->> 'success' as first_call_ok;
select :'resp_b'::jsonb -> 'error' ->> 'key' as second_call_error_key;

rollback;
```

Expected: `first_call_ok = true`; `second_call_error_key = 'table_code_duplicate'` — not a raw `uq_dining_table_store_code` constraint-violation exception (`601122_Logic.md` §1.2 step 3).

### §4.4 `table_code` UNIQUE violation — update path, self-exclusion works, cross-collision still blocked

```sql
begin;

-- Two distinct tables.
select catchmenu_store.upsert_dining_table(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_table_id := null, p_table_code := '__test_dining_table_601123_self',
  p_actor_id := '<test_actor_id>'::uuid, p_locale := 'ko'
) as resp_self \gset
select :'resp_self'::jsonb -> 'data' ->> 'table_id' as self_table_id \gset

select catchmenu_store.upsert_dining_table(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_table_id := null, p_table_code := '__test_dining_table_601123_other',
  p_actor_id := '<test_actor_id>'::uuid, p_locale := 'ko'
) as resp_other \gset

-- Re-save the first table with its OWN existing table_code — must NOT
-- trigger table_code_duplicate against itself.
select catchmenu_store.upsert_dining_table(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_table_id := :'self_table_id'::uuid, p_table_code := '__test_dining_table_601123_self',
  p_table_name := '자기자신 재저장', p_actor_id := '<test_actor_id>'::uuid, p_locale := 'ko'
) as resp_self_resave \gset

-- Attempt to rename the first table to the SECOND table's code — must be blocked.
select catchmenu_store.upsert_dining_table(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_table_id := :'self_table_id'::uuid, p_table_code := '__test_dining_table_601123_other',
  p_actor_id := '<test_actor_id>'::uuid, p_locale := 'ko'
) as resp_cross \gset

select :'resp_self_resave'::jsonb ->> 'success' as self_resave_ok;
select :'resp_cross'::jsonb -> 'error' ->> 'key' as cross_collision_error_key;

rollback;
```

Expected: `self_resave_ok = true` (self-exclusion in `601122_Logic.md` §1.2's `(v_is_new or id <> p_table_id)` condition works); `cross_collision_error_key = 'table_code_duplicate'` (genuine cross-table collision still blocked).

## §5 Test D — three active-session guards

Each subsection creates its own dining table and a minimal `order_sessions` fixture row directly via `INSERT` (no public RPC creates a session in this exact state for test purposes — same established pattern as `601113_TestPlan.md` §4.4's direct `is_active` flip), then links them via `dining_tables.current_session_id` (test-only direct `UPDATE`, mirroring how `current_session_id` is normally set by `bind_table_to_session()` — not exercised here since that function is out of scope, `601121_Overview.md` §1.7).

### §5.1 Setup shared by §5.1-§5.3 — table with a genuinely active session

```sql
begin;

select catchmenu_store.upsert_dining_table(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_table_id := null, p_table_code := '__test_dining_table_601123_active',
  p_capacity := 4, p_actor_id := '<test_actor_id>'::uuid, p_locale := 'ko'
) as resp \gset
select :'resp'::jsonb -> 'data' ->> 'table_id' as active_table_id \gset

insert into catchmenu_pos.order_sessions (
  tenant_id, store_id, session_type, business_day, session_status
) values (
  '<test_tenant_id>'::uuid, '<test_store_id>'::uuid, 'WALK_IN', current_date, 'SEATED'
) returning id as active_session_id \gset

update catchmenu_store.dining_tables
set current_session_id = :'active_session_id'::uuid
where id = :'active_table_id'::uuid;
```

#### §5.1 Expected — deactivation blocked

```sql
select catchmenu_store.set_dining_table_active(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_table_id := :'active_table_id'::uuid, p_is_active := false,
  p_actor_id := '<test_actor_id>'::uuid, p_locale := 'ko'
) as resp_deactivate \gset

select :'resp_deactivate'::jsonb -> 'error' ->> 'key' as deactivate_error_key;
select is_active from catchmenu_store.dining_tables where id = :'active_table_id'::uuid;
```

Expected: `deactivate_error_key = 'table_has_active_session'`; `is_active` still `true` (unchanged).

#### §5.2 Expected — capacity reduction blocked, increase allowed

```sql
-- Reduction attempt (4 -> 2): must be blocked.
select catchmenu_store.upsert_dining_table(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_table_id := :'active_table_id'::uuid, p_capacity := 2,
  p_actor_id := '<test_actor_id>'::uuid, p_locale := 'ko'
) as resp_reduce \gset

select :'resp_reduce'::jsonb -> 'error' ->> 'key' as reduce_error_key;
select capacity from catchmenu_store.dining_tables where id = :'active_table_id'::uuid;

-- Increase attempt (4 -> 10): must succeed.
select catchmenu_store.upsert_dining_table(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_table_id := :'active_table_id'::uuid, p_capacity := 10,
  p_actor_id := '<test_actor_id>'::uuid, p_locale := 'ko'
) as resp_increase \gset

select :'resp_increase'::jsonb ->> 'success' as increase_ok;
select capacity from catchmenu_store.dining_tables where id = :'active_table_id'::uuid;
```

Expected: `reduce_error_key = 'capacity_reduction_blocked_active_session'`, `capacity` still `4` after the blocked attempt; `increase_ok = true`, `capacity = 10` after the increase (`601122_Logic.md` §1.2 step 4 only compares `p_capacity < v_existing.capacity`).

#### §5.3 Expected — name change allowed, preventive audit record written

```sql
select catchmenu_store.upsert_dining_table(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_table_id := :'active_table_id'::uuid, p_table_name := '활성세션중 이름변경',
  p_actor_id := '<test_actor_id>'::uuid, p_locale := 'ko'
) as resp_rename \gset

select :'resp_rename'::jsonb ->> 'success' as rename_ok;
select table_name from catchmenu_store.dining_tables where id = :'active_table_id'::uuid;

select audit_type, decision, before_state, after_state
from catchmenu_ledger.audit_records
where subject_id = :'active_table_id'::uuid
  and audit_type = 'dining_table_name_changed_during_active_session';

rollback;
```

Expected: `rename_ok = true`, `table_name = '활성세션중 이름변경'`; exactly one `catchmenu_ledger.audit_records` row with `audit_type = 'dining_table_name_changed_during_active_session'`, `decision = 'COMPLETED'`, `before_state.table_name` = the pre-change name, `after_state.table_name` = the new name (`601122_Logic.md` §1.4). This audit call is on the **success** path — distinct from the failure-only `EXCEPTION` handler audit in §5.4 below.

### §5.4 Companion failure-path audit test — `capacity <= 0` triggers the `EXCEPTION` handler, and the audit record actually persists

This is the failure-path counterpart to §5.3's success-path audit test, using a genuine unhandled exception (a `chk_dining_table_capacity` CHECK violation) rather than a friendly validation early-return (`table_code_duplicate`, `table_not_found`, etc. never reach the `EXCEPTION` block at all — they `return` normally). No active session is required for this test; it is grouped here purely to sit next to its success-path counterpart.

**(2026-07-17, Stage 6 Critical tier 지적 — 이 테스트를 작성하는 과정에서 `601122_Logic.md` §1.5의 `raise;` 설계가 감사 기록 자체를 무효화한다는 것이 라이브 실증으로 확인되어, §1.5/§2가 `build_error_response()` 반환으로 정정됐다. 이 테스트는 그 정정된 설계를 검증한다 — 정정 전 설계(`raise;`)였다면 아래 두 기대값(친절한 에러 응답 + 영구 감사 기록)이 동시에 성립하는 것이 구조적으로 불가능했다.)**

```sql
begin;

select catchmenu_store.upsert_dining_table(
  p_tenant_id := '<test_tenant_id>'::uuid,
  p_store_id := '<test_store_id>'::uuid,
  p_table_id := null,
  p_table_code := '__test_dining_table_601123_bad_capacity',
  p_capacity := -1,
  p_actor_id := '<test_actor_id>'::uuid,
  p_locale := 'ko'
) as resp \gset

-- The call above must complete normally (no client-level Postgres error) —
-- confirm the transaction is still usable, not aborted.
select :'resp'::jsonb ->> 'success' as success;
select :'resp'::jsonb -> 'error' ->> 'key' as error_key;

select count(*) as leaked_row_count
from catchmenu_store.dining_tables
where tenant_id = '<test_tenant_id>'::uuid
  and store_id = '<test_store_id>'::uuid
  and table_code = '__test_dining_table_601123_bad_capacity';

select audit_type, decision, decision_payload ->> 'sqlstate' as recorded_sqlstate
from catchmenu_ledger.audit_records
where audit_type = 'dining_table_upsert_failed'
  and decision_payload ->> 'table_code' = '__test_dining_table_601123_bad_capacity';

rollback;
```

Expected:

- `success = false`, `error_key = 'dining_table_operation_failed'` (`601122_Logic.md` §1.5/§5, code `7110`) — **not** a raised Postgres exception reaching the client; the `select` statement itself completes and returns a row.
- `leaked_row_count = 0` — the `chk_dining_table_capacity` violation aborted the `INSERT` itself; the `EXCEPTION` block's implicit savepoint rollback undid it before the handler ran.
- Exactly one `catchmenu_ledger.audit_records` row with `audit_type = 'dining_table_upsert_failed'`, `decision = 'FAILED'`, `recorded_sqlstate` = the CHECK-violation SQLSTATE (`23514`) — **this row must actually exist** after the surrounding transaction's `rollback;` runs its course up to this query (i.e., it must be visible within the same transaction before the test's own cleanup `rollback;`, proving the audit `INSERT` was not itself undone by the exception that triggered it). If this row is absent, that is a Stop Condition (`601124_ChangeContract.md` §6 — the exact defect the `raise;`→`build_error_response()` correction was meant to fix has resurfaced).

### §5.5 Projection-drift case — stale `current_session_id` must not block

Confirms `601121_Overview.md` §2.8's rationale for the double-check (`current_session_id` + live `order_sessions.session_status`) actually matters — a table whose `current_session_id` is still populated but whose session has already reached a terminal status must **not** be treated as having an active session.

```sql
begin;

select catchmenu_store.upsert_dining_table(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_table_id := null, p_table_code := '__test_dining_table_601123_drift',
  p_capacity := 4, p_actor_id := '<test_actor_id>'::uuid, p_locale := 'ko'
) as resp \gset
select :'resp'::jsonb -> 'data' ->> 'table_id' as drift_table_id \gset

-- Session exists and is linked, but already COMPLETED — a stale projection
-- (in reality this would normally be cleared by release_table(), but this
-- test deliberately constructs the drifted state directly).
insert into catchmenu_pos.order_sessions (
  tenant_id, store_id, session_type, business_day, session_status
) values (
  '<test_tenant_id>'::uuid, '<test_store_id>'::uuid, 'WALK_IN', current_date, 'COMPLETED'
) returning id as drift_session_id \gset

update catchmenu_store.dining_tables
set current_session_id = :'drift_session_id'::uuid
where id = :'drift_table_id'::uuid;

-- Both the reduction guard and the deactivation guard must NOT fire.
select catchmenu_store.upsert_dining_table(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_table_id := :'drift_table_id'::uuid, p_capacity := 1,
  p_actor_id := '<test_actor_id>'::uuid, p_locale := 'ko'
) as resp_reduce_drift \gset

select catchmenu_store.set_dining_table_active(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_table_id := :'drift_table_id'::uuid, p_is_active := false,
  p_actor_id := '<test_actor_id>'::uuid, p_locale := 'ko'
) as resp_deactivate_drift \gset

select :'resp_reduce_drift'::jsonb ->> 'success' as reduce_drift_ok;
select :'resp_deactivate_drift'::jsonb ->> 'success' as deactivate_drift_ok;

rollback;
```

Expected: both calls return `success:true` — `capacity` reduction to `1` succeeds, and deactivation succeeds, despite `current_session_id` being non-`NULL`, because `session_status = 'COMPLETED'` makes `v_has_active_session` evaluate `false` (`601122_Logic.md` §1.2/§2). If either call is instead blocked, that is a Stop Condition (`601124_ChangeContract.md` §6 #4) — it would mean the guard trusts the projection column alone, exactly the failure mode `601121_Overview.md` §2.8 designed against.

## §6 Test E — `set_dining_table_active()` bidirectional toggle

### §6.1 Setup and toggle both directions

```sql
begin;

select catchmenu_store.upsert_dining_table(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_table_id := null, p_table_code := '__test_dining_table_601123_toggle',
  p_actor_id := '<test_actor_id>'::uuid, p_locale := 'ko'
) as resp \gset
select :'resp'::jsonb -> 'data' ->> 'table_id' as toggle_table_id \gset

-- Deactivate (no active session — must succeed).
select catchmenu_store.set_dining_table_active(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_table_id := :'toggle_table_id'::uuid, p_is_active := false,
  p_actor_id := '<test_actor_id>'::uuid, p_locale := 'ko'
) as resp_off \gset

-- Idempotent re-call (already inactive) — must be a no-op success.
select catchmenu_store.set_dining_table_active(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_table_id := :'toggle_table_id'::uuid, p_is_active := false,
  p_actor_id := '<test_actor_id>'::uuid, p_locale := 'ko'
) as resp_off_again \gset

-- Reactivate.
select catchmenu_store.set_dining_table_active(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_table_id := :'toggle_table_id'::uuid, p_is_active := true,
  p_actor_id := '<test_actor_id>'::uuid, p_locale := 'ko'
) as resp_on \gset

select :'resp_off'::jsonb ->> 'message_code' as off_message;
select :'resp_off_again'::jsonb ->> 'message_code' as off_again_message;
select :'resp_on'::jsonb ->> 'message_code' as on_message;
select is_active from catchmenu_store.dining_tables where id = :'toggle_table_id'::uuid;

rollback;
```

### §6.2 Expected result

- `off_message = 'table_deactivated'`.
- `off_again_message = 'table_active_unchanged'` (idempotent — `601122_Logic.md` §2's `v_table.is_active = p_is_active` short-circuit, no spurious `updated_at` bump).
- `on_message = 'table_activated'`.
- Final `is_active = true`.

## §7 Test F — `get_dining_table_admin_list()` includes inactive tables

### §7.1 Setup

```sql
begin;

select catchmenu_store.upsert_dining_table(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_table_id := null, p_table_code := '__test_dining_table_601123_list_active',
  p_actor_id := '<test_actor_id>'::uuid, p_locale := 'ko'
) as resp_a \gset

select catchmenu_store.upsert_dining_table(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_table_id := null, p_table_code := '__test_dining_table_601123_list_inactive',
  p_actor_id := '<test_actor_id>'::uuid, p_locale := 'ko'
) as resp_b \gset
select :'resp_b'::jsonb -> 'data' ->> 'table_id' as list_inactive_id \gset

select catchmenu_store.set_dining_table_active(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_table_id := :'list_inactive_id'::uuid, p_is_active := false,
  p_actor_id := '<test_actor_id>'::uuid, p_locale := 'ko'
) as resp_deact \gset
```

### §7.2 Expected result

```sql
select catchmenu_store.get_dining_table_admin_list(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid, p_locale := 'ko'
) as resp \gset

select (:'resp'::jsonb -> 'data' -> 'tables') @> jsonb_build_array(
  jsonb_build_object('table_code', '__test_dining_table_601123_list_active')
) as includes_active;
select (:'resp'::jsonb -> 'data' -> 'tables')::text like '%__test_dining_table_601123_list_inactive%' as includes_inactive_text_match;

select
  jsonb_path_exists(:'resp'::jsonb, '$.data.tables[*] ? (@.table_code == "__test_dining_table_601123_list_inactive" && @.is_active == false)') as inactive_row_present_and_flagged;

rollback;
```

Expected: both the active and the inactive table appear in `data.tables` (contrast with `get_table_floor_map()`, which would omit the inactive one — `601121_Overview.md` §2.7); the inactive row's `is_active` field is `false`, not omitted (`601122_Logic.md` §3's field list includes `is_active` explicitly).

## §8 Test G — GRANT/REVOKE verification (`proacl` not NULL)

```sql
select p.proname, p.proacl, p.prosecdef
from pg_proc p join pg_namespace n on n.oid = p.pronamespace
where n.nspname = 'catchmenu_store'
  and p.proname in (
    'upsert_dining_table', 'set_dining_table_active',
    'get_dining_table_admin_list'
  );
```

Expected: all three show a **non-empty** `proacl` (explicit `REVOKE ALL FROM PUBLIC` + `GRANT ... TO authenticated`, `601122_Logic.md` §4) — specifically an ACL that does **not** include a bare `PUBLIC` execute grant, and does include `authenticated`. `prosecdef = 't'` for all three. This is the direct regression guard for the exact gap `601142_Logic.md` §1.2/§3(a) found in `upsert_menu_core()` (`proacl` NULL) — these three functions must never reproduce it. If any of the three shows an empty/NULL `proacl`, Stop Condition (`601124_ChangeContract.md` §6 #6).

## §9 `error_codes` / `message_catalog` Stage-8-immediately-before-implementation re-check

Per `601122_Logic.md` §5's explicit caveat, codes `7105`-`7110` were assigned against a `max(code) = 7104` snapshot taken when the Logic document was written — this can drift before Stage 8 actually runs. This includes `7110` (`dining_table_operation_failed`), the sixth error key, added when §1.5/§2's `EXCEPTION` handlers were corrected from `raise;` to a `build_error_response()` return (`601122_Logic.md` §8 (h)) — the re-check below covers all six, not just the original five.

Procedure (run immediately before applying the migration, not at TestPlan-authoring time):

```sql
select max(code) from catchmenu_common.error_codes where error_domain = 'STORE';
```

- If the result is still `7104`, proceed with codes `7105`-`7110` as designed.
- If the result is higher, renumber all six new `error_codes` rows (and the corresponding rows are otherwise unaffected — `message_catalog` keys are text, not numbers, and do not need renumbering) to start one above the newly observed max, and update `601122_Logic.md` §5/§6 accordingly before running the migration.
- Confirm no existing row already has `error_key` in (`table_not_found`, `table_code_required`, `table_code_duplicate`, `table_has_active_session`, `capacity_reduction_blocked_active_session`, `dining_table_operation_failed`) — if one does, Stop Condition (`601124_ChangeContract.md` §6 #3).

## §10 Boundary — unrelated files/functions 0 diff

```bash
git status --short sql/migrations/0048_create_table_management_rpc.sql
git status --short sql/migrations/0025_create_session_rpc.sql
git status --short sql/migrations/0110_create_store_admin_rpc.sql
git status --short sql/migrations/0050_create_waiting_queue_rpc.sql
git status --short sql/migrations/0115_create_waiting_pipeline_rpc.sql
git diff -- docs/600000_implementation_lifecycle/601100_store_admin_console/601110_store_admin_sql_layer_reconciliation/
git diff -- docs/600000_implementation_lifecycle/601100_store_admin_console/601130_menu_price_list_architecture/
```

Expected: all empty. In particular:

- `0048`/`0025`/`0110`/`0050` — none of the five existing operational RPCs (§1.4) show any diff.
- `0115_create_waiting_pipeline_rpc.sql` — the `seat_waiting_customer()` crash documented in `601121_Overview.md` §6 (f) is explicitly **not** fixed by this workpacket; this file must show zero diff.
- `601110`/`601130` — completely different sub-workpackets in the same domain, must show zero diff.
- The only file this workpacket creates is the new migration (tentatively `0162_create_dining_table_admin_rpc.sql`) — everything else is either untouched source or new documentation under `601120_dining_table_crud_creation/`.

## §11 Acceptance criteria

PASS only if all are true:

1. `upsert_dining_table()` creates a new table with all 8 fields correctly stored, and correctly applies generation defaults (`capacity=4`, `display_order=0`, others `NULL`) when omitted (§2).
2. A partial update that changes only one field preserves all other previously-set values exactly — the `601140` lesson applied to genuinely new code (§3).
3. `table_code` duplicate detection returns the friendly `table_code_duplicate` error on both the new-table and update paths, correctly excludes a table from colliding with its own existing code, and still blocks a genuine cross-table collision (§4).
4. All three active-session guards behave as designed: deactivation blocked, capacity reduction blocked (increase allowed), name change allowed with a written preventive audit record (§5.1-§5.3) — and the guard correctly does **not** fire when `current_session_id` is stale/drifted relative to the session's actual terminal status (§5.5).
5. A genuine unhandled exception (`capacity <= 0`, a `chk_dining_table_capacity` violation) is caught by the `EXCEPTION` handler, returns a structured `dining_table_operation_failed` error (not a raised client-level Postgres error), leaves no partial row, and — critically — the corresponding `catchmenu_ledger.audit_records` `FAILED` row actually persists (proving the `raise;`→`build_error_response()` correction in `601122_Logic.md` §1.5/§2 works as intended, §5.4).
6. `table_code_required` and `table_not_found` are returned as friendly errors (not raw constraint/lookup failures) for, respectively, an omitted `table_code` on a new-table call and a nonexistent `p_table_id` on an update call, with no partial row left behind in the former case (§4.1/§4.2).
7. `set_dining_table_active()` toggles both directions and is idempotent on a repeat call in the same direction (§6).
8. `get_dining_table_admin_list()` returns both active and inactive tables, with `is_active` correctly reflecting each (§7).
9. All three new functions show a non-empty `proacl` with `authenticated` granted and no bare `PUBLIC` grant (§8).
10. The `error_codes`/`message_catalog` Stage-8-immediately-before-implementation re-check procedure was actually run, not skipped (§9).
11. `0048`/`0025`/`0110`/`0050`/`0115` and `601110`/`601130` all show zero diff (§10).
