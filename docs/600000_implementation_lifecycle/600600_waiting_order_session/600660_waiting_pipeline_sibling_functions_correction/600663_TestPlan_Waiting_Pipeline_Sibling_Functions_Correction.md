# 600663_TestPlan_Waiting_Pipeline_Sibling_Functions_Correction.md

Status: Draft
Lifecycle: TestPlan
Stage: 5 (Claude Code contract drafting, per `000701_Guide_Controlled_AI_Development_Pipeline.md` §3's 13-stage structure)
Owner: TBD
Last Updated: 2026-07-18

## Change ID

`waiting_pipeline_sibling_functions_correction`

## §0 Scope and numbering confirmation

This TestPlan covers the Stage 8 implementation of `600662_Logic_Waiting_Pipeline_Sibling_Functions_Correction.md` §A-§F — the 4 Slices (`confirm_arrival()`/`get_waiting_status()`/`get_waiting_admin_view()`/`cancel_waiting()`) in a new migration file (tentatively `sql/migrations/0164_waiting_pipeline_sibling_functions_correction.sql`).

Document number check:

- `600661_Overview_Waiting_Pipeline_Sibling_Functions_Correction.md` exists.
- `600662_Logic_Waiting_Pipeline_Sibling_Functions_Correction.md` exists.
- `600663_TestPlan_Waiting_Pipeline_Sibling_Functions_Correction.md` is the next TestPlan document number for this workpacket.
- `600664_ChangeContract_Waiting_Pipeline_Sibling_Functions_Correction.md` is the paired ChangeContract.

Test fixtures use the `__test_600663_*` table-code prefix (distinct from `600653_TestPlan.md`'s `__test_dining_table_600653_*` and this session's ad-hoc `__test_dining_table_claudeverify_*`/`__test_600663_*` verification prefixes) and `<test_tenant_id>`/`<test_store_id>`/`<test_actor_id>` placeholders matching this project's established convention. Every section is a self-contained `begin;...rollback;` block.

**Timezone note (discovered empirically at Stage 5, not present in `600653_TestPlan.md`)**: `get_waiting_admin_view()`/`get_waiting_status()`'s queue-membership filters use `business_day := (timezone('Asia/Seoul', now()))::date`, while this DB session's `current_date` reflects the server's own `TIMEZONE` setting (confirmed live: `UTC`). When the UTC date and the Asia/Seoul date diverge (i.e. between 00:00-09:00 UTC, since Korea is UTC+9), inserting fixtures with `business_day := current_date` silently produces a session that the function's own Asia/Seoul-computed `v_business_day` filter does not match — the call still succeeds but returns an empty/short list, which reads as a false negative, not a real defect. **All fixtures below use `business_day := (timezone('Asia/Seoul', now()))::date` explicitly**, not `current_date`, to avoid this trap.

## §1 Pre-flight checks

Run before modifying or applying anything. If any Stop Condition in `600664_ChangeContract_Waiting_Pipeline_Sibling_Functions_Correction.md` is hit, stop and report.

### §1.1 Target functions still have the pre-fix (phantom-column) signature/behavior; `mark_session_arrived()` unchanged

```sql
select proname, pg_get_function_identity_arguments(oid)
from pg_proc
where pronamespace = 'catchmenu_pos'::regnamespace
  and proname in ('confirm_arrival', 'get_waiting_status', 'get_waiting_admin_view', 'cancel_waiting', 'mark_session_arrived');
```

Expected: all 5 rows present, with the 4 target functions' identity arguments unchanged from `0115`'s original signatures (`confirm_arrival`: `p_tenant_id uuid, p_store_id uuid, p_session_id uuid, p_actor_id uuid, p_locale text, p_correlation_id text`; `cancel_waiting`: `p_tenant_id uuid, p_store_id uuid, p_session_id uuid, p_cancel_reason text, p_actor_type text, p_actor_id uuid, p_locale text, p_correlation_id text`; `get_waiting_status`: `p_tenant_id uuid, p_store_id uuid, p_session_id uuid, p_locale text`; `get_waiting_admin_view`: `p_tenant_id uuid, p_store_id uuid, p_locale text`) — confirms Stage 8 has not already run. `mark_session_arrived`: `p_tenant_id uuid, p_store_id uuid, p_session_id uuid, p_correlation_id text` — confirms the delegation target's contract is unchanged from `600662_Logic.md` §A.1's documented shape.

### §1.2 `mark_session_arrived()`'s GRANT and no-caller status re-confirmed

```sql
select proacl from pg_proc
where pronamespace = 'catchmenu_pos'::regnamespace and proname = 'mark_session_arrived';
```

Expected: `{postgres=X/postgres,authenticated=X/postgres}` — already grantable to `authenticated`, matching `600661_Overview.md` §1.5. Re-verified live (2026-07-18) via `pg_proc.proacl` on the local Supabase Postgres instance directly, cross-checked with `aclexplode(proacl)` and `pg_default_acl` for `catchmenu_pos` (no schema-level default granting `supabase_admin` found) — the grantee set is exactly `{postgres, authenticated}`, matching `0025:665-670`'s explicit `revoke all ... from public; grant execute ... to authenticated;` pair. **Could not reproduce a `supabase_admin` entry from this environment** — if Cursor/Codex's verification ran against a different target (e.g. the actual deployed/remote Supabase project rather than this local docker instance) and found `supabase_admin` there, that would indicate an environment-specific difference (possibly `supabase_admin` as the object owner in that environment, which Postgres implicitly grants full rights to without needing an explicit `proacl` entry, or a different migration-apply role) — **Stage 8 must re-run this exact query against its own target environment before relying on this baseline**, since this document's baseline is only confirmed against the local instance.

### §1.3 `order_sessions` — dependency columns exist and are unmodified by this plan

```sql
select column_name, data_type from information_schema.columns
where table_schema = 'catchmenu_pos' and table_name = 'order_sessions'
  and column_name in ('table_id', 'order_id', 'queue_position', 'arrived_at', 'cancelled_at', 'pre_order_created_at')
order by column_name;
```

Expected: all 6 present (`table_id`/`order_id`/`queue_position` uuid/uuid/int; `arrived_at`/`cancelled_at`/`pre_order_created_at` timestamptz) — matching `600661_Overview.md` §1's baseline.

### §1.4 `error_codes` ORDER-domain ceiling (baseline for §E)

```sql
select max(code) from catchmenu_common.error_codes where error_domain = 'ORDER';
```

Expected (as of this document's writing): `7077` (the ceiling left by `0163`). Record the live value at pre-flight time — input to Stage 8's immediately-before-implementation re-check per `600662_Logic.md` §E, not a fixed assumption.

### §1.5 Server timezone confirmation (basis for §0's timezone note)

```sql
select current_setting('TIMEZONE'), current_date, (timezone('Asia/Seoul', now()))::date;
```

Record both dates at pre-flight time; if they differ, every fixture in this document that depends on `business_day` matching "today" for `get_waiting_status()`/`get_waiting_admin_view()` must use the Asia/Seoul value, not `current_date`.

## §2 Slice A — `confirm_arrival()` facade

### §2.1 Normal delegation success

```sql
begin;

select catchmenu_store.upsert_dining_table(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_table_id := null, p_table_code := '__test_600663_arrival_normal',
  p_capacity := 4, p_actor_id := '<test_actor_id>'::uuid, p_locale := 'ko'
) as resp \gset

insert into catchmenu_pos.order_sessions (
  tenant_id, store_id, session_type, business_day, session_status, wait_number, guest_count, session_started_at
) values (
  '<test_tenant_id>'::uuid, '<test_store_id>'::uuid, 'WALK_IN', (timezone('Asia/Seoul', now()))::date, 'WAITING',
  94001, 2, now() - interval '9 minutes'
) returning id as normal_session_id \gset

select catchmenu_pos.confirm_arrival(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_session_id := :'normal_session_id'::uuid,
  p_actor_id := '<test_actor_id>'::uuid, p_locale := 'ko'
) as arrival_resp \gset

select :'arrival_resp'::jsonb ->> 'success' as success;
select :'arrival_resp'::jsonb -> 'data' ->> 'has_pre_order' as has_pre_order;
select :'arrival_resp'::jsonb -> 'data' ->> 'next_step' as next_step;
select :'arrival_resp'::jsonb -> 'data' ? 'table_number' as has_table_number_key;

-- mark_session_arrived()'s own writes
select session_status, arrived_at is not null as has_arrived_at
from catchmenu_pos.order_sessions where id = :'normal_session_id'::uuid;

rollback;
```

Expected: `success = true`; `has_pre_order = false`; `next_step = 'WAIT_FOR_SEATING'`; `has_table_number_key = false` (`600662_Logic.md` §A.3 step 5 — the always-null `table_number` field was deliberately dropped from the response, 0 callers exist so no compatibility concern); `session_status = 'ARRIVAL_PENDING'`, `has_arrived_at = true` — confirms the crash is gone and `mark_session_arrived()`'s real `arrived_at` column is the one actually written, not the phantom `arrival_confirmed_at`.

### §2.2 Event footprint — `session_events` 1건 + `catchmenu_ledger.events` 2건 (`600662_Logic.md` §A.3/§G acceptance criterion 1)

**(실행 순서 주의)** 이 섹션은 반드시 독립된 `begin;...rollback;` 블록으로 끝까지 실행하고 커밋되지 않은 상태를 남기지 않아야 한다. §2.4로 곧바로 이어서 실행하면 안 된다 — 만약 이 섹션의 `rollback;`을 실행하지 않은 채(또는 같은 세션에서 `begin;`이 이미 열려 있는 상태로) §2.4를 이어서 실행하면, §2.4의 `alter table catchmenu_ledger.events add constraint tmp_block_arrival_confirmed check (event_type <> 'arrival_confirmed')`가 **같은(아직 열려 있는) 트랜잭션 안에서** 실행되어 이 섹션이 이미 삽입한 `event_type='arrival_confirmed'` 행까지 함께 검증 대상이 된다 — PostgreSQL의 `ALTER TABLE ... ADD CONSTRAINT`(`NOT VALID` 없이)는 기존 행 전체를 즉시 검증하므로, 그 기존 행이 새 CHECK를 위반해 **`ADD CONSTRAINT` 자체가 실패**하고 §2.4의 트리거 메커니즘 전체가 깨진다. 각 섹션은 psql을 종료하고 새로 접속하거나, 최소한 앞 섹션의 `rollback;`이 실제로 실행된 것을 확인한 뒤에만 다음 섹션을 실행한다.

```sql
begin;

select catchmenu_store.upsert_dining_table(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_table_id := null, p_table_code := '__test_600663_arrival_events',
  p_capacity := 4, p_actor_id := '<test_actor_id>'::uuid, p_locale := 'ko'
) as resp \gset

insert into catchmenu_pos.order_sessions (
  tenant_id, store_id, session_type, business_day, session_status, wait_number, guest_count
) values (
  '<test_tenant_id>'::uuid, '<test_store_id>'::uuid, 'WALK_IN', (timezone('Asia/Seoul', now()))::date, 'WAITING', 94002, 2
) returning id as events_session_id \gset

select catchmenu_pos.confirm_arrival(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_session_id := :'events_session_id'::uuid,
  p_actor_id := '<test_actor_id>'::uuid, p_locale := 'ko'
) as arrival_resp \gset

select count(*) as session_events_customer_arrived_count
from catchmenu_pos.session_events
where session_id = :'events_session_id'::uuid and event_type = 'customer_arrived';

select event_domain, event_type
from catchmenu_ledger.events
where subject_id = :'events_session_id'::uuid
  and event_type in ('customer_arrived', 'arrival_confirmed')
order by event_domain;

rollback;
```

Expected: `session_events_customer_arrived_count = 1`. Ledger query returns exactly 2 rows: `event_domain='session', event_type='customer_arrived'` (from `mark_session_arrived()`) and `event_domain='waiting', event_type='arrival_confirmed'` (from the facade itself) — live-verified at Stage 5 via a `pg_temp` reproduction of the exact same insert sequence before this document was written.

### §2.3 `invalid_session_status` — reachability + raw pass-through (`600662_Logic.md` §A.2)

```sql
begin;

insert into catchmenu_pos.order_sessions (
  tenant_id, store_id, session_type, business_day, session_status, wait_number, guest_count
) values (
  '<test_tenant_id>'::uuid, '<test_store_id>'::uuid, 'WALK_IN', (timezone('Asia/Seoul', now()))::date, 'CANCELLED', 94003, 2
) returning id as cancelled_session_id \gset

select catchmenu_pos.confirm_arrival(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_session_id := :'cancelled_session_id'::uuid,
  p_actor_id := '<test_actor_id>'::uuid, p_locale := 'ko'
) as resp \gset

select :'resp'::jsonb ->> 'success' as success;
select :'resp'::jsonb ->> 'error_key' as error_key;
select :'resp'::jsonb ->> 'current_status' as current_status;

rollback;
```

Expected: `success = false`; **`error_key = 'invalid_session_status'`** (flat top-level `error_key`, not `error.key` — `mark_session_arrived()`'s raw flat shape passed through unmodified, `600662_Logic.md` §A.2's designed behavior, not `build_error_response()`'s nested shape); `current_status = 'CANCELLED'`. This is also the reachability proof for `600662_Logic.md` §A.2's table — `session_not_found` is structurally unreachable via this facade (the facade's own step 1 already holds the row via `for update of os`) and is not separately reproduced, matching `0163 §7`'s precedent for structurally-unreachable keys.

### §2.4 `EXCEPTION` handler — `waiting_confirm_arrival_failed` + full delegation atomicity

**(2026-07-18, Stage 5 라이브 재현 완료)** `0163 §9`의 기법을 그대로 적용한다 — 파사드 자신이 쓰는 렛저 이벤트(`event_type='arrival_confirmed'`)만 정확히 겨냥하는 임시 `CHECK` 제약을 추가해, `mark_session_arrived()`의 위임이 이미 성공한 **이후** 시점에서만 예외를 유발한다. 이 문서를 작성하기 직전 `pg_temp` 함수로 정확히 동일한 삽입 순서를 재현해 결과를 확인했다.

**(실행 순서 주의, §2.2와 동일 원칙)** 이 섹션도 반드시 독립된 `begin;...rollback;` 블록으로 실행한다. 특히 §2.2를 먼저 실행했다면 그 `rollback;`이 실제로 완료된 뒤에만 이 섹션을 시작한다 — §2.2가 남긴(커밋되지 않았더라도 같은 열린 트랜잭션 안에 존재하는) `event_type='arrival_confirmed'` 행이 있으면, 아래의 `alter table ... add constraint`가 기존 행 검증에서 즉시 실패해 이 섹션 전체가 의도한 대로 동작하지 않는다.

```sql
begin;

alter table catchmenu_ledger.events
  add constraint tmp_block_arrival_confirmed check (event_type <> 'arrival_confirmed');

insert into catchmenu_pos.order_sessions (
  tenant_id, store_id, session_type, business_day, session_status, wait_number, guest_count
) values (
  '<test_tenant_id>'::uuid, '<test_store_id>'::uuid, 'WALK_IN', (timezone('Asia/Seoul', now()))::date, 'WAITING', 94004, 2
) returning id as exc_session_id \gset

select catchmenu_pos.confirm_arrival(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_session_id := :'exc_session_id'::uuid,
  p_actor_id := '<test_actor_id>'::uuid, p_locale := 'ko'
) as resp \gset

select :'resp'::jsonb ->> 'success' as success;
select :'resp'::jsonb -> 'error' ->> 'key' as error_key;

-- mark_session_arrived()'s work must be fully rolled back (no savepoint of its own, 600652_Logic.md §9.2's
-- atomicity finding applies to this delegation too, not just bind_table_to_session())
select session_status, arrived_at is null as arrived_at_is_null
from catchmenu_pos.order_sessions where id = :'exc_session_id'::uuid;
select count(*) as session_events_customer_arrived_count
from catchmenu_pos.session_events where session_id = :'exc_session_id'::uuid and event_type = 'customer_arrived';
select count(*) as ledger_customer_arrived_count
from catchmenu_ledger.events where subject_id = :'exc_session_id'::uuid and event_type = 'customer_arrived';

-- only the facade's own failure audit record survives
select audit_domain, audit_type, decision, decision_payload ->> 'sqlstate' as recorded_sqlstate
from catchmenu_ledger.audit_records
where audit_type = 'confirm_arrival_failed' and subject_id = :'exc_session_id'::uuid;

alter table catchmenu_ledger.events drop constraint tmp_block_arrival_confirmed;

rollback;
```

Expected (Stage 5 라이브 재현 결과 그대로):

- `success = false`; `error_key`(중첩) = `'waiting_confirm_arrival_failed'`.
- `session_status = 'WAITING'`(원래 상태로 롤백, `'ARRIVAL_PENDING'` 아님), `arrived_at_is_null = true`.
- `session_events_customer_arrived_count = 0`, `ledger_customer_arrived_count = 0` — `mark_session_arrived()`이 만들었던 모든 기록이 함께 롤백됐다.
- **정확히 한 행**: `audit_domain = 'session'`(**`'waiting'`이 아님** — `chk_audit_domain`이 `'waiting'`을 허용하지 않는다, `600652_Logic.md` §1.5/`600662_Logic.md` §A.3 EXCEPTION 핸들러 설계와 정확히 일치해야 함 — 만약 `'waiting'`으로 기록됐다면 그 자체가 `append_audit_record()` 호출이 크래시했다는 뜻이므로 이 assertion은 §A.3 설계의 직접적인 회귀 검증이다), `audit_type = 'confirm_arrival_failed'`, `decision = 'FAILED'`, `recorded_sqlstate = '23514'`(CHECK 위반).
- `drop constraint`로 스키마에 영구적 흔적을 남기지 않는다.

## §3 Slice B — `get_waiting_status()` 읽기 교정

### §3.1 Phantom 컬럼 4종 전부 해소 — 크래시 없이 완주 + 값 정확성

```sql
begin;

select catchmenu_store.upsert_dining_table(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_table_id := null, p_table_code := '__test_600663_status_normal',
  p_capacity := 4, p_actor_id := '<test_actor_id>'::uuid, p_locale := 'ko'
) as resp \gset

insert into catchmenu_pos.order_sessions (
  tenant_id, store_id, session_type, business_day, session_status, wait_number, guest_count, session_started_at
) values (
  '<test_tenant_id>'::uuid, '<test_store_id>'::uuid, 'WALK_IN', (timezone('Asia/Seoul', now()))::date, 'WAITING',
  94010, 2, now() - interval '20 minutes'
) returning id as status_session_id \gset

select catchmenu_pos.get_waiting_status(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_session_id := :'status_session_id'::uuid, p_locale := 'ko'
) as resp \gset

select :'resp'::jsonb ->> 'success' as success;
select :'resp'::jsonb -> 'data' ->> 'table_number' as table_number;
select :'resp'::jsonb -> 'data' ->> 'has_pre_order' as has_pre_order;
select :'resp'::jsonb -> 'data' -> 'timestamps' ->> 'called_at' as called_at;
select :'resp'::jsonb -> 'data' -> 'timestamps' ->> 'arrival_at' as arrival_at;
select :'resp'::jsonb -> 'data' ->> 'queue_position' as queue_position_in_response;

rollback;
```

Expected: `success = true`(원본은 여기서 크래시); `table_number = null`(테이블 배정 전이므로 원본 동작과 동일하게 `null`); `has_pre_order = false`; `called_at = null`(아직 호출된 적 없음); `arrival_at = null`(아직 도착 확인 전); `queue_position_in_response`는 숫자(별도 카운트 쿼리로 계산된 지역변수 — `600662_Logic.md` §B.1이 제거한 죽은 SELECT 항목과는 별개).

### §3.2 `called_at`/`arrival_at` 파생 정확성 — 도착 확인 후 재조회

```sql
begin;

select catchmenu_store.upsert_dining_table(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_table_id := null, p_table_code := '__test_600663_status_arrived',
  p_capacity := 4, p_actor_id := '<test_actor_id>'::uuid, p_locale := 'ko'
) as resp \gset

insert into catchmenu_pos.order_sessions (
  tenant_id, store_id, session_type, business_day, session_status, wait_number, guest_count
) values (
  '<test_tenant_id>'::uuid, '<test_store_id>'::uuid, 'WALK_IN', (timezone('Asia/Seoul', now()))::date, 'WAITING', 94011, 2
) returning id as arrived_session_id \gset

select catchmenu_pos.confirm_arrival(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_session_id := :'arrived_session_id'::uuid, p_actor_id := '<test_actor_id>'::uuid
) as arrival_resp \gset

select catchmenu_pos.get_waiting_status(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_session_id := :'arrived_session_id'::uuid, p_locale := 'ko'
) as status_resp \gset

select :'status_resp'::jsonb -> 'data' -> 'timestamps' ->> 'arrival_at' is not null as has_arrival_at;
select :'status_resp'::jsonb -> 'data' ->> 'session_status' as session_status;

rollback;
```

Expected: `has_arrival_at = true`(§2.1의 `confirm_arrival()` 호출로 `arrived_at`이 세팅된 것을 `get_waiting_status()`가 정확히 읽음 — Slice A/B 교차 검증); `session_status = 'ARRIVAL_PENDING'`.

### §3.3 죽은 `queue_position` SELECT 항목 제거 확인 (`600662_Logic.md` §B.1)

```sql
select pg_get_functiondef('catchmenu_pos.get_waiting_status'::regproc) as func_def \gset
select :'func_def' !~ 'select id, wait_number, session_status,\s*\n\s*session_type, guest_count,\s*\n\s*guest_locale, queue_position,' as dead_select_removed;
```

Expected: 함수 본문에서 `queue_position`을 읽는 SELECT 목록 항목이 더 이상 존재하지 않음(정규식 매치 실패 = 제거 확인) — 완전 자동 정규식 매치가 Stage 8의 실제 포맷팅과 어긋날 수 있으므로, 이 항목은 정규식 결과와 무관하게 **코드 리뷰로도 재확인**해야 한다(`pg_get_functiondef()` 전문을 직접 읽고 SELECT 목록에 `queue_position`이 없는지 확인).

## §4 Slice C — `get_waiting_admin_view()` 읽기 교정 + `memo`/`patent_note` 제거

### §4.1 Phantom 컬럼 5종(`memo` 포함) 전부 해소 — 크래시 없이 완주

```sql
begin;

select catchmenu_store.upsert_dining_table(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_table_id := null, p_table_code := '__test_600663_admin_normal',
  p_capacity := 4, p_actor_id := '<test_actor_id>'::uuid, p_locale := 'ko'
) as resp \gset

insert into catchmenu_pos.order_sessions (
  tenant_id, store_id, session_type, business_day, session_status, wait_number, guest_count, session_started_at
) values (
  '<test_tenant_id>'::uuid, '<test_store_id>'::uuid, 'WALK_IN', (timezone('Asia/Seoul', now()))::date, 'WAITING',
  94020, 2, now() - interval '6 minutes'
) returning id as admin_session_id \gset

select catchmenu_pos.get_waiting_admin_view(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid, p_locale := 'ko'
) as resp \gset

select :'resp'::jsonb ->> 'success' as success;
select jsonb_array_length(:'resp'::jsonb -> 'data' -> 'waiting_list') >= 1 as has_at_least_one_entry;

-- the fixture session's own entry, by session_id
select entry
from jsonb_array_elements(:'resp'::jsonb -> 'data' -> 'waiting_list') as entry
where entry ->> 'session_id' = :'admin_session_id';

rollback;
```

Expected: `success = true`(원본은 여기서 크래시); `has_at_least_one_entry = true`; 픽스처 세션의 항목이 `table_number`/`pre_order_amount`/`called_at`/`call_count`/`is_foreign`/`waited_minutes`/`actions` 키를 모두 포함하되 **`memo` 키는 없음**(`600662_Logic.md` §C.1 옵션 1 확정) — `entry`를 직접 눈으로 확인해 `? 'memo' = false`임을 별도로 assert.

### §4.2 `called_at`/`call_count` 파생 정확성 — 다회 호출 시나리오

```sql
begin;

select catchmenu_store.upsert_dining_table(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_table_id := null, p_table_code := '__test_600663_admin_called',
  p_capacity := 4, p_actor_id := '<test_actor_id>'::uuid, p_locale := 'ko'
) as resp \gset

insert into catchmenu_pos.order_sessions (
  tenant_id, store_id, session_type, business_day, session_status, wait_number, guest_count
) values (
  '<test_tenant_id>'::uuid, '<test_store_id>'::uuid, 'WALK_IN', (timezone('Asia/Seoul', now()))::date, 'WAITING', 94021, 2
) returning id as called_session_id \gset

-- 0160의 call_waiting_customer()를 두 번 호출 (재호출 지원 확인)
select catchmenu_pos.call_waiting_customer(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_session_id := :'called_session_id'::uuid, p_actor_id := '<test_actor_id>'::uuid
) as call1_resp \gset

select catchmenu_pos.call_waiting_customer(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_session_id := :'called_session_id'::uuid, p_actor_id := '<test_actor_id>'::uuid
) as call2_resp \gset

select catchmenu_pos.get_waiting_admin_view(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid, p_locale := 'ko'
) as admin_resp \gset

select entry -> 'call_count' as call_count, entry -> 'called_at' as called_at
from jsonb_array_elements(:'admin_resp'::jsonb -> 'data' -> 'waiting_list') as entry
where entry ->> 'session_id' = :'called_session_id';

rollback;
```

Expected: `call_count = 2`(`_record_waiting_call()`이 매 호출 시 `session_events`에 `'customer_called'` 행을 쌓고, `600662_Logic.md` §C.2의 `LEFT JOIN LATERAL`이 그걸 정확히 카운트); `called_at`은 두 번째 호출의 `occurred_at`(가장 최근 값, `max(occurred_at)`).

### §4.3 `patent_note` 실제로 응답에서 제거됨 (`600662_Logic.md` §C.2, Human 별도 승인 대상 — `600664_ChangeContract.md` §9)

```sql
select catchmenu_pos.get_waiting_admin_view(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid, p_locale := 'ko'
) as resp \gset
select :'resp'::jsonb -> 'data' ? 'patent_note' as has_patent_note_key;
```

Expected: `has_patent_note_key = false`. **이 항목은 Stage 8이 `600664_ChangeContract.md` §9의 별도 체크박스를 실제로 승인받았는지 먼저 확인한 뒤에만 실행/PASS 처리한다** — phantom 컬럼 치환과 무관한 응답 계약 변경이므로, 다른 항목들과 달리 이 검증 하나만으로 "정상 동작"을 판단하지 않는다.

## §5 Slice D — `cancel_waiting()` 쓰기 교정

### §5.1 `cancel_reason` — 세션 행엔 없지만 렛저/알림에는 있음 (`600662_Logic.md` §D.1)

```sql
begin;

insert into catchmenu_pos.order_sessions (
  tenant_id, store_id, session_type, business_day, session_status, wait_number, guest_count
) values (
  '<test_tenant_id>'::uuid, '<test_store_id>'::uuid, 'WALK_IN', (timezone('Asia/Seoul', now()))::date, 'WAITING', 94030, 2
) returning id as cancel_session_id \gset

select catchmenu_pos.cancel_waiting(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_session_id := :'cancel_session_id'::uuid,
  p_cancel_reason := '고객 변심', p_actor_type := 'CUSTOMER', p_actor_id := '<test_actor_id>'::uuid
) as resp \gset

select :'resp'::jsonb ->> 'success' as success;
select :'resp'::jsonb -> 'data' ->> 'cancel_reason' as cancel_reason_in_response;

select session_status, cancelled_at is not null as has_cancelled_at
from catchmenu_pos.order_sessions where id = :'cancel_session_id'::uuid;

-- order_sessions에 cancel_reason 컬럼 자체가 없으므로, 이 쿼리는 정보 스키마로 직접 재확인
select count(*) as cancel_reason_column_exists
from information_schema.columns
where table_schema = 'catchmenu_pos' and table_name = 'order_sessions' and column_name = 'cancel_reason';

select event_payload ->> 'cancel_reason' as ledger_cancel_reason
from catchmenu_ledger.events
where subject_id = :'cancel_session_id'::uuid and event_type = 'waiting_cancelled';

rollback;
```

Expected: `success = true`; `cancel_reason_in_response = '고객 변심'`(응답 payload에는 그대로 있음, `p_cancel_reason` 파라미터 echo); `session_status = 'CANCELLED'`, `has_cancelled_at = true`; `cancel_reason_column_exists = 0`(스키마에 컬럼 자체가 없음을 재확인 — 정보 손실이 아니라 애초에 저장 대상이 아니었음의 증거); `ledger_cancel_reason = '고객 변심'`(렛저가 단일 진실 소스로서 정확히 보존).

### §5.2 KDS 티켓 취소 로직 보존 — 사전주문 있는 세션

```sql
begin;

insert into catchmenu_pos.order_sessions (
  tenant_id, store_id, session_type, business_day, session_status, wait_number, guest_count
) values (
  '<test_tenant_id>'::uuid, '<test_store_id>'::uuid, 'PRE_ORDER', (timezone('Asia/Seoul', now()))::date, 'WAITING', 94031, 2
) returning id as kds_session_id \gset

insert into catchmenu_pos.orders (
  tenant_id, store_id, session_id, order_number, order_type, order_status, order_channel,
  total_amount, final_amount, ordered_at, business_day
) values (
  '<test_tenant_id>'::uuid, '<test_store_id>'::uuid, :'kds_session_id'::uuid, 'W94031',
  'DINE_IN', 'CONFIRMED', 'KIOSK', 18000, 18000, now(), (timezone('Asia/Seoul', now()))::date
) returning id as kds_order_id \gset

update catchmenu_pos.order_sessions
set order_id = :'kds_order_id'::uuid, pre_order_created_at = now()
where id = :'kds_session_id'::uuid;

insert into catchmenu_kds.kds_tickets (
  tenant_id, store_id, order_id, kds_status, business_day
) values (
  '<test_tenant_id>'::uuid, '<test_store_id>'::uuid, :'kds_order_id'::uuid, 'HOLD', (timezone('Asia/Seoul', now()))::date
) returning id as kds_ticket_id \gset

select catchmenu_pos.cancel_waiting(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_session_id := :'kds_session_id'::uuid,
  p_cancel_reason := '사전주문 취소', p_actor_type := 'CUSTOMER', p_actor_id := '<test_actor_id>'::uuid
) as resp \gset

select :'resp'::jsonb ->> 'success' as success;
select :'resp'::jsonb -> 'data' ->> 'pre_order_cancelled' as pre_order_cancelled;
select kds_status, cancelled_at is not null as has_cancelled_at
from catchmenu_kds.kds_tickets where id = :'kds_ticket_id'::uuid;

rollback;
```

Expected: `success = true`; `pre_order_cancelled = true`; `kds_status = 'CANCELLED'`, `has_cancelled_at = true` — 사전주문 취소 시 연결된 KDS 티켓도 함께 취소되는 원본 로직이 보존됨을 확인. `kds_tickets` 스키마의 정확한 필수 컬럼은 Stage 8 직전 `\d catchmenu_kds.kds_tickets`로 재확인 필요(이 문서는 `0016_create_kds_tickets.sql` 기준 최소 컬럼만 가정).

### §5.3 `has_pre_order` 경계 케이스 — `pre_order_created_at`만 있고 `orders`/`kds_tickets` 없음 (`600662_Logic.md` §D.1/§H (i))

**(2026-07-18, Stage 5 라이브 재현 완료)** `pre_order_created_at`을 직접 세팅하고 `order_id`는 `null`로 남긴, `pre_order_while_waiting()`이 고장 상태일 경우 발생할 수 있는 비정상 상태를 인위적으로 구성해 재현했다.

```sql
begin;

insert into catchmenu_pos.order_sessions (
  tenant_id, store_id, session_type, business_day, session_status, wait_number, guest_count, pre_order_created_at
) values (
  '<test_tenant_id>'::uuid, '<test_store_id>'::uuid, 'PRE_ORDER', (timezone('Asia/Seoul', now()))::date, 'WAITING',
  94032, 2, now() - interval '3 minutes'
  -- order_id는 의도적으로 세팅하지 않음 -- pre_order_created_at만 있고 orders 행은 없는 비정상 상태
) returning id as edge_session_id \gset

select pre_order_created_at is not null as has_pre_order_created_at, order_id is null as order_id_is_null
from catchmenu_pos.order_sessions where id = :'edge_session_id'::uuid;

select catchmenu_pos.cancel_waiting(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_session_id := :'edge_session_id'::uuid,
  p_cancel_reason := '경계 케이스', p_actor_type := 'CUSTOMER', p_actor_id := '<test_actor_id>'::uuid
) as resp \gset

select :'resp'::jsonb ->> 'success' as success;
select session_status, cancelled_at is not null as has_cancelled_at
from catchmenu_pos.order_sessions where id = :'edge_session_id'::uuid;

rollback;
```

Expected (Stage 5 라이브 재현 결과 그대로): `success = true`, `session_status = 'CANCELLED'`, `has_cancelled_at = true` — **크래시하지 않는다.** `update ... from catchmenu_pos.orders o where o.session_id = p_session_id ...`가 매칭되는 `orders` 행이 없어 단순히 0행 UPDATE로 끝나고(PostgreSQL `UPDATE ... FROM`의 no-op 특성), 함수는 정상 완주한다 — `600662_Logic.md` §D.1의 판단(크래시하지 않을 것으로 추정)이 라이브 재현으로 실증되었다.

### §5.4 `EXCEPTION` 핸들러 — `waiting_cancel_operation_failed` + 자체 쓰기 원자성

**(2026-07-18, Stage 5 라이브 재현 완료)** `cancel_waiting()`은 `bind_table_to_session()`/`mark_session_arrived()`처럼 별도 core에 위임하지 않고 **자기 자신이 직접** `order_sessions`를 UPDATE한다 — 그래도 PL/pgSQL 함수 전체가 단일 최상위 문으로 실행되므로, 함수 자신의 이전 UPDATE도 나중의 예외에 의해 함께 롤백되는지 별도로 확인이 필요하다(위임이 없다고 원자성이 자동으로 보장되는 게 아니라는 점을 실증).

```sql
begin;

alter table catchmenu_ledger.events
  add constraint tmp_block_waiting_cancelled check (event_type <> 'waiting_cancelled');

insert into catchmenu_pos.order_sessions (
  tenant_id, store_id, session_type, business_day, session_status, wait_number, guest_count
) values (
  '<test_tenant_id>'::uuid, '<test_store_id>'::uuid, 'WALK_IN', (timezone('Asia/Seoul', now()))::date, 'WAITING', 94033, 2
) returning id as exc_session_id \gset

select catchmenu_pos.cancel_waiting(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_session_id := :'exc_session_id'::uuid,
  p_cancel_reason := 'exc test', p_actor_type := 'CUSTOMER', p_actor_id := '<test_actor_id>'::uuid
) as resp \gset

select :'resp'::jsonb ->> 'success' as success;
select :'resp'::jsonb -> 'error' ->> 'key' as error_key;

-- cancel_waiting() 자신의 UPDATE도 롤백됐어야 한다
select session_status, cancelled_at is null as cancelled_at_is_null
from catchmenu_pos.order_sessions where id = :'exc_session_id'::uuid;

select audit_domain, audit_type, decision, decision_payload ->> 'sqlstate' as recorded_sqlstate
from catchmenu_ledger.audit_records
where audit_type = 'cancel_waiting_failed' and subject_id = :'exc_session_id'::uuid;

alter table catchmenu_ledger.events drop constraint tmp_block_waiting_cancelled;

rollback;
```

Expected (Stage 5 라이브 재현 결과 그대로):

- `success = false`; `error_key`(중첩) = `'waiting_cancel_operation_failed'`.
- `session_status = 'WAITING'`(원래 상태로 롤백, `'CANCELLED'` 아님), `cancelled_at_is_null = true` — **위임이 없는 함수도 자체 쓰기가 함께 롤백된다는 것을 실증** (`600652_Logic.md` §9.2의 원자성 발견이 위임 케이스만이 아니라 PL/pgSQL 함수 일반의 성질임을 확인).
- **정확히 한 행**: `audit_domain = 'session'`(**`'waiting'`이 아님** — `chk_audit_domain`이 `'waiting'`을 허용하지 않는다, `600662_Logic.md` §D.2 EXCEPTION 핸들러 설계와 정확히 일치해야 함 — Slice A와 동일한 회귀 검증), `audit_type = 'cancel_waiting_failed'`, `decision = 'FAILED'`, `recorded_sqlstate = '23514'`.

## §6 Boundary — 0 diff

```bash
git status --short sql/migrations/0025_create_session_rpc.sql
git status --short sql/migrations/0115_create_waiting_pipeline_rpc.sql
git status --short sql/migrations/0160_call_waiting_customer_contract_recovery.sql
git status --short sql/migrations/0163_seat_waiting_customer_facade_correction.sql
```

Expected: all empty. `0025`(`mark_session_arrived()`/`bind_table_to_session()`, both unmodified — this workpacket only calls the former), `0115`(원본 소스 텍스트 — 4개 함수의 라이브 정의는 신규 `0164`의 `CREATE OR REPLACE`로 덮어써지지만 `0115` 파일 자체는 건드리지 않는다, `0160`/`0163`과 동일 기법), `0160`(`call_waiting_customer()`/`_record_waiting_call()`, §4.2에서 호출만 하고 수정하지 않음), `0163`(`seat_waiting_customer()`/`_resolve_dining_table_by_number()`, 완전히 무관) 전부 diff 0이어야 한다.

## §7 Acceptance criteria

PASS only if all are true:

1. Slice A: 정상 위임 성공(session `ARRIVAL_PENDING`, `arrived_at` 세팅 — `mark_session_arrived()`의 실제 쓰기), `table_number` 필드가 응답에서 완전히 빠짐(§2.1).
2. Slice A: 이벤트 발자국이 정확히 `session_events` 1건 + `catchmenu_ledger.events` 2건(도메인 각 1건씩)(§2.2).
3. Slice A: `invalid_session_status`가 `mark_session_arrived()`의 원시 flat JSON 그대로(재래핑 없이) 반환되고, `session_not_found`는 구조적으로 도달 불가능함이 재확인됨(§2.3).
4. Slice A: `EXCEPTION` 핸들러가 `waiting_confirm_arrival_failed`를 반환하고, `mark_session_arrived()`의 모든 상태 변경(세션/`session_events`/자체 렛저)이 함께 롤백되며, 파사드 자신의 실패 감사기록만 생존(§2.4).
5. Slice B: phantom 컬럼 4종이 전부 실컬럼/파생으로 치환되어 크래시 없이 완주하고, `called_at`/`arrival_at`이 실제 이벤트/컬럼 값과 정확히 일치하며, 죽은 `queue_position` SELECT 항목이 제거됨(§3.1-§3.3).
6. Slice C: phantom 컬럼 5종(`memo` 포함)이 전부 해소되어 크래시 없이 완주하고, `call_count`/`called_at`이 다회 호출 시나리오에서 정확히 파생되며, `patent_note`가 실제로 응답에서 빠지되 이 항목만 별도 Human 승인 확인 후 PASS 처리됨(§4.1-§4.3).
7. Slice D: `cancel_reason`이 `order_sessions` 행에는 없지만(스키마 재확인) 렛저 이벤트에는 정확히 보존되고, 사전주문이 있는 세션의 KDS 티켓 취소 로직이 보존되며, `pre_order_created_at`만 있고 `orders`가 없는 경계 케이스에서 크래시 없이 완주하고, `EXCEPTION` 핸들러가 위임 없는 함수에서도 자체 쓰기를 함께 롤백함(§5.1-§5.4).
8. `0025`/`0115`(원본 텍스트)/`0160`/`0163` 전부 0 diff(§6).
