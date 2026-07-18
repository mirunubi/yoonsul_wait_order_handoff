# 600673_TestPlan_Record_Waiting_Call_Grant_Correction.md

Status: Draft
Lifecycle: TestPlan
Stage: 5 (Claude Code role)
Owner: TBD
Last Updated: 2026-07-18

## Change ID

`record_waiting_call_grant_correction`

## §0 Scope and numbering confirmation

This TestPlan verifies the final design in `600671_Overview_Record_Waiting_Call_Grant_Correction.md` and `600672_Logic_Record_Waiting_Call_Grant_Correction.md` — both carried 4 rounds of Cursor+Codex Critical tier verification (including a live `pg_proc.proacl` re-confirmation, `600671_Overview.md` §7 (b)). This TestPlan cites that design as final and does not re-litigate it.

**Migration number**: `sql/migrations/` tops out at `0166_canonical_kds_release_orchestration.sql` (confirmed via both directory listing and `catchmenu_meta.migration_history`). `0167` is the next available number for this workpacket — Stage 8 must re-run this exact check immediately before creating the file, per the project's standing numbering discipline (`000701_Guide_Controlled_AI_Development_Pipeline.md` §14.5 Migration Draft Mutability Rule also applies once the file exists).

**Live-reconfirmed at Stage 5 (2026-07-18, this session, via `docker exec ... psql`)** — the exact signatures the new migration's `REVOKE`/`GRANT` statements must target:

```text
catchmenu_pos._record_waiting_call(p_tenant_id uuid, p_store_id uuid, p_session_id uuid, p_from_status text, p_wait_number integer, p_guest_locale text, p_phone_hash text, p_customer_id uuid, p_has_pre_order boolean, p_pre_order_amount integer, p_table_number text, p_expires_at timestamp with time zone, p_actor_type text, p_actor_id uuid, p_locale text, p_correlation_id text)
catchmenu_pos.call_next_waiting_customer(p_tenant_id uuid, p_store_id uuid, p_actor_id uuid, p_locale text, p_correlation_id text)
catchmenu_pos.call_waiting_customer(p_tenant_id uuid, p_store_id uuid, p_session_id uuid, p_table_number text, p_actor_id uuid, p_locale text, p_correlation_id text)
```

All three match exactly what `600672_Logic.md` §1.2/§2.1/§3 assumed — no drift since Stage 1.5.

## §1 Pre-flight checks

### §1.1 Baseline `has_function_privilege()` state (before any change)

```sql
select
  has_function_privilege('anon', 'catchmenu_pos._record_waiting_call(uuid,uuid,uuid,text,int,text,text,uuid,boolean,int,text,timestamptz,text,uuid,text,text)', 'execute') as anon_record_call,
  has_function_privilege('authenticated', 'catchmenu_pos._record_waiting_call(uuid,uuid,uuid,text,int,text,text,uuid,boolean,int,text,timestamptz,text,uuid,text,text)', 'execute') as auth_record_call,
  has_function_privilege('anon', 'catchmenu_pos.call_next_waiting_customer(uuid,uuid,uuid,text,text)', 'execute') as anon_next,
  has_function_privilege('authenticated', 'catchmenu_pos.call_next_waiting_customer(uuid,uuid,uuid,text,text)', 'execute') as auth_next,
  has_function_privilege('anon', 'catchmenu_pos.call_waiting_customer(uuid,uuid,uuid,text,uuid,text,text)', 'execute') as anon_cwc,
  has_function_privilege('authenticated', 'catchmenu_pos.call_waiting_customer(uuid,uuid,uuid,text,uuid,text,text)', 'execute') as auth_cwc;
```

Expected (live-reconfirmed at Stage 5, 2026-07-18): `anon_record_call=t`, `auth_record_call=t`, `anon_next=t`, `auth_next=t`, `anon_cwc=t`, `auth_cwc=t` — all six `true`. This is the exact vulnerability `600671_Overview.md` §1/§7 documented: `proacl` NULL on the first two functions means PostgreSQL's schema-default PUBLIC EXECUTE applies to every role including `anon`; `call_waiting_customer()`'s own separate gap (`authenticated` GRANT present, `PUBLIC` never revoked) produces the same `anon=t` result via a different mechanism.

### §1.2 Roles exist

```sql
select rolname from pg_roles where rolname in ('anon','authenticated','postgres') order by rolname;
```

Expected: all 3 rows present (live-reconfirmed).

## §2 `_record_waiting_call()` — REVOKE-only, verify anon AND authenticated both lose direct EXECUTE

```sql
begin;

revoke all on function catchmenu_pos._record_waiting_call(
  uuid, uuid, uuid, text, int, text, text, uuid,
  boolean, int, text, timestamptz, text, uuid, text, text
) from public;

select
  has_function_privilege('anon', 'catchmenu_pos._record_waiting_call(uuid,uuid,uuid,text,int,text,text,uuid,boolean,int,text,timestamptz,text,uuid,text,text)', 'execute') as anon_after,
  has_function_privilege('authenticated', 'catchmenu_pos._record_waiting_call(uuid,uuid,uuid,text,int,text,text,uuid,boolean,int,text,timestamptz,text,uuid,text,text)', 'execute') as auth_after;

rollback;
```

Expected (live-reconfirmed at Stage 5): `anon_after=f`, `auth_after=f` — **both** roles lose direct EXECUTE, matching the design intent (`_record_waiting_call()` is never called directly by any client, only internally via `SECURITY DEFINER` from the two public functions — the 2-caller fact is confirmed in `600672_Logic.md` §1.1, and the REVOKE-only precedent it follows is documented in `600671_Overview.md` §5.1).

## §3 `call_next_waiting_customer()` — REVOKE + GRANT authenticated, verify anon loses / authenticated keeps

```sql
begin;

revoke all on function catchmenu_pos.call_next_waiting_customer(
  uuid, uuid, uuid, text, text
) from public;

grant execute on function catchmenu_pos.call_next_waiting_customer(
  uuid, uuid, uuid, text, text
) to authenticated;

select
  has_function_privilege('anon', 'catchmenu_pos.call_next_waiting_customer(uuid,uuid,uuid,text,text)', 'execute') as anon_after,
  has_function_privilege('authenticated', 'catchmenu_pos.call_next_waiting_customer(uuid,uuid,uuid,text,text)', 'execute') as auth_after;

rollback;
```

Expected (live-reconfirmed at Stage 5): `anon_after=f`, `auth_after=t` — `anon` loses execute, `authenticated` retains it. This is the exact combination `600672_Logic.md` §2 designed (`0163`'s `REVOKE ALL FROM PUBLIC` form + `0050:714-719`'s `GRANT EXECUTE TO authenticated` form for a public RPC).

## §4 Functional continuity — both public functions still work end-to-end after §2/§3's REVOKE

Reproduces the `SECURITY DEFINER` internal-call principle already established by `0163`'s `_resolve_dining_table_by_number()` precedent: revoking direct EXECUTE on an internal helper does not break callers that invoke it from within another `SECURITY DEFINER` function, because the call executes with the definer's rights, not the direct caller's.

```sql
begin;

revoke all on function catchmenu_pos._record_waiting_call(
  uuid, uuid, uuid, text, int, text, text, uuid,
  boolean, int, text, timestamptz, text, uuid, text, text
) from public;

revoke all on function catchmenu_pos.call_next_waiting_customer(
  uuid, uuid, uuid, text, text
) from public;

grant execute on function catchmenu_pos.call_next_waiting_customer(
  uuid, uuid, uuid, text, text
) to authenticated;

-- Fixture setup must happen BEFORE switching role -- 'authenticated' has no direct table
-- grants in this codebase's access model (no direct table GRANTs, only through
-- SECURITY DEFINER RPCs), so these raw INSERTs would themselves fail as 'authenticated'.
insert into catchmenu_pos.orders (tenant_id, store_id, order_number, order_type, order_status, order_channel, total_amount, final_amount, ordered_at, business_day)
values ('00000000-0000-0000-0000-000000000001'::uuid,'00000000-0000-0000-0000-000000000002'::uuid,'S5-GRANT-CWC','TAKEOUT','CONFIRMED','KIOSK',10000,10000,now(),current_date)
returning id as order_id \gset

insert into catchmenu_pos.order_sessions (tenant_id, store_id, order_id, session_type, session_status, wait_number, guest_count, guest_locale, session_started_at, business_day, business_timezone)
values ('00000000-0000-0000-0000-000000000001'::uuid,'00000000-0000-0000-0000-000000000002'::uuid,:'order_id'::uuid,'WALK_IN','WAITING',101,2,'ko',now(),current_date,'Asia/Seoul')
returning id as session_id \gset

insert into catchmenu_pos.orders (tenant_id, store_id, order_number, order_type, order_status, order_channel, total_amount, final_amount, ordered_at, business_day)
values ('00000000-0000-0000-0000-000000000001'::uuid,'00000000-0000-0000-0000-000000000002'::uuid,'S5-GRANT-CNWC','TAKEOUT','CONFIRMED','KIOSK',10000,10000,now(),current_date)
returning id as order_id2 \gset

insert into catchmenu_pos.order_sessions (tenant_id, store_id, order_id, session_type, session_status, wait_number, guest_count, guest_locale, session_started_at, business_day, business_timezone)
values ('00000000-0000-0000-0000-000000000001'::uuid,'00000000-0000-0000-0000-000000000002'::uuid,:'order_id2'::uuid,'WALK_IN','WAITING',102,2,'ko',now(),current_date,'Asia/Seoul')
returning id as session_id2 \gset

-- (Stage 4 Codex/Cursor 지적 반영) 이 지점부터 실제로 'authenticated' 역할로 전환해
-- 호출한다 -- postgres(슈퍼유저)로 그대로 호출하면 ACL이 전혀 검사되지 않으므로,
-- GRANT가 실제로 이 역할의 호출을 가능하게 하는지 증명하지 못한다. SET LOCAL은
-- 이 트랜잭션(및 마지막의 rollback)에 한정되어 자동으로 원복된다.
set local role authenticated;

-- (Codex 제안 반영) 역할 전환이 실제로 적용됐는지, 그리고 authenticated가
-- superuser가 아니어서 ACL이 실제로 검사되는 컨텍스트인지 직접 확인한다 --
-- current_user만 보고 "authenticated로 전환됐다"고 가정하지 않는다.
select
  session_user,
  current_user,
  (select rolsuper from pg_roles where rolname = current_user) as is_superuser;

-- §4.1: call_waiting_customer() -> _record_waiting_call(), called AS authenticated
select catchmenu_pos.call_waiting_customer(
  p_tenant_id := '00000000-0000-0000-0000-000000000001'::uuid,
  p_store_id := '00000000-0000-0000-0000-000000000002'::uuid,
  p_session_id := :'session_id'::uuid,
  p_table_number := 'T5',
  p_correlation_id := 'verify-600673-cwc'
) as call_waiting_customer_result;

-- §4.2: call_next_waiting_customer() -> _record_waiting_call(), called AS authenticated
select catchmenu_pos.call_next_waiting_customer(
  p_tenant_id := '00000000-0000-0000-0000-000000000001'::uuid,
  p_store_id := '00000000-0000-0000-0000-000000000002'::uuid,
  p_correlation_id := 'verify-600673-cnwc'
) as call_next_waiting_customer_result;

rollback;
```

Expected (live-reconfirmed at Stage 5, 2026-07-18): the `session_user`/`current_user`/`is_superuser` check returns exactly `session_user=postgres`, `current_user=authenticated`, `is_superuser=false` — confirming both that the role switch actually took effect and that `authenticated` is a genuinely non-superuser role for which ACL checks are enforced (not merely that `current_user` displays a different name). Both calls, executed genuinely as the `authenticated` role (not `postgres`), return `{"success": true, "message_key": "waiting_called_alert", ...}` with correct `wait_number`/`session_id`/`call_count` data — identical shape to pre-REVOKE behavior. This proves the `authenticated` GRANT on `call_next_waiting_customer()` actually enables real invocation by that role through the ACL layer, not merely that `has_function_privilege()` reports `true` in the catalog — `postgres` bypasses ACL checks entirely as a superuser, so testing under `postgres` alone (as the original draft did) cannot distinguish "GRANT present and effective" from "GRANT missing but irrelevant because the caller is a superuser." Confirms the GRANT/REVOKE change is purely a direct-caller privilege restriction; it does not alter any function's logic or break the internal call chain (`_record_waiting_call()` is invoked with `security definer` rights regardless of the direct caller's own grants).

## §5 `call_waiting_customer()` — confirm untouched (byte-identical `proacl` comparison, Stage 4 Codex/Cursor 지적 반영)

**(정정, 2026-07-18)** `has_function_privilege()` t/t 비교만으로는 §7 acceptance criterion 3의 "byte-identical" 요구를 실제로 증명하지 못한다 — `t`/`t`는 `anon`과 `authenticated` 둘 다 실행 가능하다는 것만 확인할 뿐, `proacl` 전체(예: 소유자 항목의 순서, `GRANT OPTION` 플래그, 혹시 모를 제3의 역할 항목)가 마이그레이션 적용 전후로 정말 한 글자도 바뀌지 않았는지는 증명하지 않는다. `pg_proc.proacl::text`를 마이그레이션 적용 **직전**에 캡처해 트랜잭션 변수로 저장한 뒤, 적용 **직후** 값과 문자 그대로(`=`) 비교한다.

```sql
begin;

select proacl::text as before_proacl
from pg_proc
where proname = 'call_waiting_customer' and pronamespace = 'catchmenu_pos'::regnamespace
\gset

\echo 'before_proacl =' :'before_proacl'

revoke all on function catchmenu_pos._record_waiting_call(
  uuid, uuid, uuid, text, int, text, text, uuid,
  boolean, int, text, timestamptz, text, uuid, text, text
) from public;

revoke all on function catchmenu_pos.call_next_waiting_customer(
  uuid, uuid, uuid, text, text
) from public;

grant execute on function catchmenu_pos.call_next_waiting_customer(
  uuid, uuid, uuid, text, text
) to authenticated;

select
  proacl::text as after_proacl,
  (proacl::text = :'before_proacl') as byte_identical
from pg_proc
where proname = 'call_waiting_customer' and pronamespace = 'catchmenu_pos'::regnamespace;

rollback;
```

Expected (live-reconfirmed at Stage 5, 2026-07-18): `before_proacl` and `after_proacl` are the identical literal string `{=X/postgres,postgres=X/postgres,authenticated=X/postgres}`, and `byte_identical=t`. This function is explicitly out of scope (`600671_Overview.md` §7 (e)); this workpacket's migration touches only `_record_waiting_call()`/`call_next_waiting_customer()`, so `call_waiting_customer()`'s `proacl` must not change by even one character.

## §6 Boundary — 0 diff

### §6.1 Target file itself

```powershell
git diff -- sql/migrations/0160_call_waiting_customer_contract_recovery.sql
```

Expected: no diff. Per `600672_Logic.md` §4, the new migration adds `REVOKE`/`GRANT` statements referencing the two functions by signature — it does not re-declare (`CREATE OR REPLACE`) either function, so `0160` itself is never touched.

### §6.2 Unrelated files

```powershell
git diff -- `
  sql/migrations/0050_create_waiting_queue_rpc.sql `
  sql/migrations/0110_create_store_admin_rpc.sql `
  sql/migrations/0115_create_waiting_pipeline_rpc.sql `
  sql/migrations/0163_seat_waiting_customer_facade_correction.sql `
  sql/migrations/0166_canonical_kds_release_orchestration.sql
```

Expected: no diff on any of these 5 files. `0050`/`0115`/`0163` are cited only as design precedents (§0), never modified. `0110` (`upsert_menu_core()` family) is explicitly out of scope (`600671_Overview.md` §7 (a), `601140`'s prior decision not reversed). `0166` is the most recent unrelated migration, included as a general drift check.

### §6.3 Runtime boundary

```powershell
git diff -- catchmenu_app
```

Expected: no diff.

## §7 Acceptance criteria

The workpacket passes Stage 9 verification only if all of the following are true:

1. `_record_waiting_call()` loses EXECUTE for **both** `anon` and `authenticated` after the migration (§2) — no `GRANT` of any kind remains.
2. `call_next_waiting_customer()` loses EXECUTE for `anon` but retains it for `authenticated` after the migration (§3).
3. `call_waiting_customer()`(`uuid,uuid,uuid,text,uuid,text,text`)'s `pg_proc.proacl::text` is literally byte-identical before and after the migration — not merely `has_function_privilege()` reporting the same `t`/`t` (§5). This is an explicit, deliberate non-fix (`600671_Overview.md` §7 (e)), not an oversight — regression-testing it here guards against silently touching it in Stage 8.
4. Both `call_waiting_customer()` and `call_next_waiting_customer()` continue to complete successfully end-to-end after the REVOKE/GRANT change **when actually invoked as the `authenticated` role via `SET LOCAL ROLE`** (not `postgres`), producing the same response shape as before (§4) — this is the only way to prove the `GRANT` is actually effective for that role rather than merely present in the catalog.
5. `0160_call_waiting_customer_contract_recovery.sql` shows 0 diff (§6.1) — the new migration never re-declares either function.
6. `0050`/`0110`/`0115`/`0163`/`0166` and `catchmenu_app` show 0 diff (§6.2/§6.3).
7. The new migration contains only `REVOKE`/`GRANT` statements for `_record_waiting_call()`/`call_next_waiting_customer()` — no `CREATE OR REPLACE FUNCTION`, no schema change, no statement referencing `call_waiting_customer()` or any `upsert_menu_core()`-family object.
