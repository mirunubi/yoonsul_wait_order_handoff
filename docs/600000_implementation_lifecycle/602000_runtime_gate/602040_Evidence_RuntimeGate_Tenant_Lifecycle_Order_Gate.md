# 602040_Evidence_RuntimeGate_Tenant_Lifecycle_Order_Gate.md

Status: Active
Lifecycle: RuntimeGate
DocumentType: Evidence
Last Updated: 2026-09-10

## §0 성격 · PRE-FLIGHT

`600023` §3 · §3.4 · §3.5와 `601919` `H-01`을 근거로 `catchmenu_pos.orders` INSERT writer 전건의 tenant lifecycle gate를 측정한다.

이 문서는 §2의 공격 재현과 §4.1의 착수 전 실측까지만 기록한다. §5 migration은 Human 확인 전 미착수다.

### §0.1 범위

라이브 `pg_proc.prosrc`에서 `catchmenu_pos.orders`에 INSERT하는 함수는 다음 8건이다.

```text
catchmenu_pos.create_order
catchmenu_pos.create_pre_order
catchmenu_pos.pre_order_while_waiting
catchmenu_store.place_kiosk_order
catchmenu_store.place_takeout_order
catchmenu_integrations.intake_delivery_order
catchmenu_common.flush_offline_queue
catchmenu_common.run_integration_test(uuid,uuid,text)
```

`catchmenu_common.run_integration_test(uuid,uuid,text,text)` overload는 `orders` INSERT writer가 아니므로 8건에 포함하지 않는다.

### §0.2 PRE-FLIGHT 실측

```text
측정일       2026-09-09
DB           postgres
PostgreSQL   17.6
read_only    on — catalog PRE-FLIGHT
container    supabase_db_yoonsul_wait_order_handoff
container id b67400e8c73e4ec7b9a25b172d71af347dd22d5e269d49859629fc3d8bd935ec
image        public.ecr.aws/supabase/postgres:17.6.1.156
Compose      yoonsul_wait_order_handoff
Supabase CLI yoonsul_wait_order_handoff
workdir      D:\Workspace\Yoonsul_Wait_Order_Handoff
environment  local/dev

git HEAD
b8a035998e8e9959391b0a1fd5f22ec3cfb33447

git status --short --untracked-files=all
(0 rows)

latest successful migration
0176_payment_approval_binding_all_paths.sql
checksum DB   fc766450f2fdb273d0df97a5e91b389236ee753f4673d644062f8208607ffd80
checksum file FC766450F2FDB273D0DF97A5E91B389236EE753F4673D644062F8208607FFD80
match         true

0177 migration history count  0
0177 file exists              false
602040 file existed           false
```

실행 명령:

```powershell
git rev-parse HEAD
git status --short --untracked-files=all
Test-Path sql/migrations/0177_tenant_lifecycle_order_gate.sql
Test-Path docs/600000_implementation_lifecycle/602000_runtime_gate/602040_Evidence_RuntimeGate_Tenant_Lifecycle_Order_Gate.md
Get-FileHash -Algorithm SHA256 sql/migrations/0176_payment_approval_binding_all_paths.sql
docker inspect supabase_db_yoonsul_wait_order_handoff --format '{{.Id}}|{{.Config.Image}}|{{json .Config.Labels}}'
docker exec -e PGOPTIONS="-c default_transaction_read_only=on" -i supabase_db_yoonsul_wait_order_handoff psql -X -v ON_ERROR_STOP=1 -U postgres -d postgres
```

migration history 확인 쿼리:

```sql
select filename, checksum, applied_at, applied_by, success
from catchmenu_meta.migration_history
order by applied_at desc nulls last, filename desc
limit 5;

select count(*) as migration_0177_count
from catchmenu_meta.migration_history
where filename like '0177%';
```

실측 출력:

```text
                      filename                       |                             checksum                             |          applied_at           | applied_by | success
-----------------------------------------------------+------------------------------------------------------------------+-------------------------------+------------+---------
 0176_payment_approval_binding_all_paths.sql         | fc766450f2fdb273d0df97a5e91b389236ee753f4673d644062f8208607ffd80 | 2026-09-08 11:11:58.707146+00 | postgres   | t
 0175_kds_payment_precondition.sql                   | f1fbae219d4b35ba7b058636802cf9643b8e3177f873ff6caba0c8746f4af974 | 2026-09-08 10:15:14.656249+00 | postgres   | t
 0174_payment_approval_integrity.sql                 | eb97562f3983ab84b39deda6f07895107b204dd3ca6c89c4c647816437962069 | 2026-09-08 09:20:49.864969+00 | postgres   | t
 0173_caller_tenant_scope_remove_claim_exemption.sql | 47dcd5c034f191098faea178693cf94a39a5a2fa6fd23bcb9eb759a5cbec97f0 | 2026-09-08 07:38:05.234819+00 | postgres   | t
 0172_caller_tenant_scope_gate.sql                   | 194aa3b333c43efd3eff08e7df571437b112fca2a8f2cad91c56a8366ff4c620 | 2026-09-07 23:13:13.023198+00 | postgres   | t

 migration_0177_count
----------------------
                    0
```

PRE-FLIGHT 조건은 전부 일치했다.

## §1 공격

`601919` `H-01`의 T04와 같은 상태를 합성한다. `tenant_status='TERMINATED'`, `isolation_state='ISOLATED'`인 tenant와 그 tenant의 store · session · menu를 한 transaction 안에 만든 뒤 `authenticated` 역할과 동일 tenant claim으로 `catchmenu_pos.create_order`를 호출한다. 모든 fixture와 결과는 `ROLLBACK`한다.

```sql
\pset pager off
\pset format aligned
\set ON_ERROR_STOP on

select count(*) as residual_before
from catchmenu_hq.tenants
where id='eeeeeeee-4000-4000-8000-000000000001';

begin;

insert into catchmenu_hq.tenants (
  id, tenant_code, tenant_name, tenant_type, plan_tier,
  is_active, tenant_status, isolation_state
) values (
  'eeeeeeee-4000-4000-8000-000000000001',
  'RG04_AUDIT_TENANT', 'RG04 Audit Tenant', 'TEST', 'STANDARD',
  true, 'TERMINATED', 'ISOLATED'
);

insert into catchmenu_hq.stores (
  id, tenant_id, store_code, store_name, store_type,
  store_status, timezone, is_active
) values (
  'eeeeeeee-4000-4000-8000-000000000002',
  'eeeeeeee-4000-4000-8000-000000000001',
  'RG04_STORE', 'RG04 Audit Store', 'DINE_IN',
  'ACTIVE', 'Asia/Seoul', true
);

insert into catchmenu_pos.order_sessions (
  id, tenant_id, store_id, session_type, session_status,
  guest_count, business_day, business_timezone, correlation_id
) values (
  'eeeeeeee-4000-4000-8000-000000000005',
  'eeeeeeee-4000-4000-8000-000000000001',
  'eeeeeeee-4000-4000-8000-000000000002',
  'WALK_IN', 'ORDERING', 1, current_date, 'Asia/Seoul', 'RG04-ATTACK'
);

insert into catchmenu_pos.menus (
  id, tenant_id, store_id, menu_code, menu_name,
  price, menu_status, is_kds_required, kitchen_zone,
  estimated_minutes, display_order, is_active
) values (
  'eeeeeeee-4000-4000-8000-000000000006',
  'eeeeeeee-4000-4000-8000-000000000001',
  'eeeeeeee-4000-4000-8000-000000000002',
  'RG04_MENU', 'RG04 Audit Menu',
  1000, 'AVAILABLE', false, 'MAIN', 5, 1, true
);

select tenant_status, isolation_state
from catchmenu_hq.tenants
where id='eeeeeeee-4000-4000-8000-000000000001';

set local role authenticated;
select set_config(
  'request.jwt.claims',
  '{"sub":"aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa","tenant_id":"eeeeeeee-4000-4000-8000-000000000001","store_id":"eeeeeeee-4000-4000-8000-000000000002","role":"authenticated","actor_type":"STAFF"}',
  true
);

select catchmenu_pos.create_order(
  'eeeeeeee-4000-4000-8000-000000000001',
  'eeeeeeee-4000-4000-8000-000000000002',
  'eeeeeeee-4000-4000-8000-000000000005',
  'DINE_IN', 'STAFF_POS',
  '[{"menu_id":"eeeeeeee-4000-4000-8000-000000000006","quantity":1,"options_amount":0,"selected_options":[]}]'::jsonb,
  null, null, 'RG04-ATTACK'
) as attack_result;

reset role;
select count(*) as created_orders,
       min(order_status) as order_status,
       min(final_amount) as final_amount
from catchmenu_pos.orders
where tenant_id='eeeeeeee-4000-4000-8000-000000000001';

rollback;

select count(*) as residual_tenants
from catchmenu_hq.tenants
where id='eeeeeeee-4000-4000-8000-000000000001';
```

## §2 재현 로그

```text
=== precheck residual ===
 residual_before
-----------------
               0
(1 row)

=== RG04 H-01 reproduction begin ===
BEGIN
INSERT 0 1
INSERT 0 1
INSERT 0 1
INSERT 0 1
=== tenant lifecycle state before role switch ===
 tenant_status | isolation_state
---------------+-----------------
 TERMINATED    | ISOLATED
(1 row)

SET
set_config
{"sub":"aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa","tenant_id":"eeeeeeee-4000-4000-8000-000000000001","store_id":"eeeeeeee-4000-4000-8000-000000000002","role":"authenticated","actor_type":"STAFF"}
(1 row)

=== create_order attack ===
attack_result
{"success": true, "order_id": "f33bdda6-82f5-4a89-9af1-f8f88b6d9196", "item_count": 1, "final_amount": 1000, "order_number": "0001", "order_status": "PENDING", "total_amount": 1000, "kitchen_zone_summary": {"MAIN": 1}}
(1 row)

RESET
=== persisted inside transaction ===
 created_orders | order_status | final_amount
----------------+--------------+-------------
              1 | PENDING      |         1000
(1 row)

ROLLBACK
=== after rollback ===
 residual_tenants
------------------
                0
(1 row)
```

`TERMINATED + ISOLATED` tenant에서 동일 tenant claim을 가진 `authenticated` caller의 주문 생성이 성공했다. §2 공격은 재현됐다. fixture와 생성 주문은 모두 롤백됐고 잔여 tenant는 0건이다.

첫 측정 시도에서는 역할 전환 뒤 증거 출력용으로 `catchmenu_hq.tenants`를 직접 조회해 `permission denied`가 발생했다. 함수 공격에 도달하기 전 transaction이 자동 롤백됐다. 위 재실행은 상태 조회를 역할 전환 전으로 옮겼으며 공격 조건과 함수 인자는 동일하다.

## §3 invariant

⚠️ 다음 invariant는 Human이 확정한 `601902` `TI-13` · `TI-2` · `TI-12` 인용이다. 이 문서가 새로 만들지 않는다.

```text
① tenant 가 ISOLATED 이면 업무 객체 생성이 거부된다

   주문은 tenant-scoped 업무 객체다
   containment block 이 존재하면 접근이 거부되고 fail closed 다

   근거   601902 TI-13 · 010004 §7 Deny-By-Default

② tenant_status 가 TERMINATED 이면 업무 객체 생성이 거부된다

   두 축은 독립이며 각각 별도로 거부 사유가 된다

   근거   601902 TI-2 · TI-12

③ 판정은 서버가 두 축을 직접 조회해 한다

   caller 가 넘긴 값을 근거로 쓰지 않는다

④ tenant scope

   assert_caller_tenant_scope 를 tenant read 보다 먼저 호출한다
```

`0-A-2`가 문서 21개로 도달한 계약을 이 gate가 처음 강제한다. `601902`는 `CONTRACT FROZEN`이며 enforcement를 `0-C`로 이월했다. 이 gate는 그 이월분의 일부를 닫는다.

## §4 근거

| 구분 | 근거 |
|---|---|
| Doctrine | `010004` §7 Deny-By-Default |
| Human invariant | `601902` `TI-13` · `TI-2` · `TI-12` |
| Runtime evidence | `601919` `H-01` · T04 |
| Precedent only | `0172` · `0173` · `0174` · `0175` · `0176` |

`010004` §7은 tenant-scoped object의 기본을 `DENY_UNLESS_CONTEXT_MATCHES`로 두고, 허용 조건에 `no containment block`과 `no suspension block`을 포함하며 context를 해석할 수 없으면 fail closed하도록 요구한다.

## §4.1 실측 — Human 확인 전

### §4.1.1 CHECK 허용값과 거부값 제안

라이브 CHECK와 컬럼:

```text
tenant_status
  CHECK  ACTIVE · TRIAL · SUSPENDED · CANCELLED · TERMINATED
  NOT NULL
  DEFAULT TRIAL

isolation_state
  CHECK  NONE · ISOLATED
  NOT NULL
  DEFAULT NONE
```

실행 쿼리:

```sql
select conname, pg_get_constraintdef(oid, true) as definition
from pg_constraint
where conrelid='catchmenu_hq.tenants'::regclass
  and contype='c'
order by conname;

select column_name, data_type, is_nullable, column_default
from information_schema.columns
where table_schema='catchmenu_hq'
  and table_name='tenants'
  and column_name in ('tenant_status','isolation_state')
order by ordinal_position;
```

제안:

| 축 | 허용 제안 | 주문 생성 거부 제안 | 근거와 한계 |
|---|---|---|---|
| `isolation_state` | `NONE` | `ISOLATED` | `TI-13`이 직접 확정했다. |
| `tenant_status` | `ACTIVE`, `TRIAL` | `SUSPENDED`, `CANCELLED`, `TERMINATED` | `TERMINATED`는 Human invariant가 직접 확정했다. `SUSPENDED`는 `010004` §7의 `no suspension block`과 일치한다. `CANCELLED`까지 거부할지는 기존 선언에 직접 효과가 없으므로 Human 확인이 필요하다. |

`601702` §1.27~§1.28과 `601902` `TI-12`는 상태축 독립성만 확정하고 각 enum의 권한 효과는 확정하지 않았다. 따라서 §5에는 Human이 확정한 집합만 넣는다.

### §4.1.2 여덟 writer 전수

라이브 `pg_proc`의 8개 writer 전부가 `SECURITY DEFINER`이며 `jsonb`를 반환한다. `tenant_status`를 읽는 writer는 0/8, `isolation_state`를 읽는 writer는 0/8, `assert_caller_tenant_scope`를 호출하는 writer는 0/8이다.

| # | writer | 첫 tenant-scoped read | 직접 tenant read | scope helper | EXECUTE | 성격 |
|---:|---|---|---|---|---|---|
| 1 | `catchmenu_pos.create_order` | `catchmenu_hq.stores` → `order_sessions` | 없음 | 없음 | authenticated | 일반 주문 업무 경로 |
| 2 | `catchmenu_pos.create_pre_order` | `catchmenu_hq.stores` → `order_sessions` | 없음 | 없음 | authenticated | 사전 주문 업무 경로 |
| 3 | `catchmenu_pos.pre_order_while_waiting` | `catchmenu_hq.stores` → `order_sessions` | 없음 | 없음 | PUBLIC · authenticated | waiting 사전 주문 업무 경로 |
| 4 | `catchmenu_store.place_kiosk_order` | `catchmenu_hq.stores` → `kiosk_configs` | 없음 | 없음 | PUBLIC · authenticated | 키오스크 주문 업무 경로 |
| 5 | `catchmenu_store.place_takeout_order` | `catchmenu_hq.stores` → `store_settings` | 없음 | 없음 | authenticated | 포장 주문 업무 경로 |
| 6 | `catchmenu_integrations.intake_delivery_order` | 입력 형식 검사 뒤 `catchmenu_hq.stores` | 없음 | 없음 | authenticated | 배달 provider 주문 intake 업무 경로 |
| 7 | `catchmenu_common.flush_offline_queue` | `offline_queue` | 없음 | 없음 | authenticated | Flutter 온라인 복구가 호출하는 영속 주문 업무 경로 |
| 8 | `catchmenu_common.run_integration_test(uuid,uuid,text)` | schema 점검 뒤 `catchmenu_hq.stores` | 없음 | 없음 | PUBLIC · authenticated | 통합 테스트 유틸; test order를 INSERT한 뒤 성공 경로에서 DELETE |

PUBLIC EXECUTE 3건은 catalog `proacl`에 `=X/postgres`가 있다. 세 schema 모두 `anon`의 schema `USAGE`는 없고 authenticated의 `USAGE`와 함수 EXECUTE는 있다. 따라서 현재 anon 직접 도달은 막혀 있으나 authenticated는 세 함수를 호출할 수 있다.

writer 전수 쿼리:

```sql
select n.nspname, p.proname, p.oid::regprocedure
from pg_proc p
join pg_namespace n on n.oid=p.pronamespace
where p.prokind='f'
  and p.prosrc ~* 'insert[[:space:]]+into[[:space:]]+(catchmenu_pos[.])?orders'
order by 1,2,p.oid::regprocedure::text;
```

실측 출력:

```text
catchmenu_common       | flush_offline_queue
catchmenu_common       | run_integration_test(uuid,uuid,text)
catchmenu_integrations | intake_delivery_order
catchmenu_pos          | create_order
catchmenu_pos          | create_pre_order
catchmenu_pos          | pre_order_while_waiting
catchmenu_store        | place_kiosk_order
catchmenu_store        | place_takeout_order
```

### §4.1.3 `run_integration_test` 처분 제안

실측상 `run_integration_test(uuid,uuid,text)`는 통합 테스트 유틸이다. comment는 12개 검증과 `ALL_PASS`를 설명하고, body는 test session · test order · KDS ticket을 INSERT한 뒤 성공 경로에서 세 행을 DELETE한다. 애플리케이션 소스에서 직접 호출자는 발견되지 않았고 SQL validation package에서 호출된다.

**제안은 gate 대상에서 제외하지 않는 것이다.** 이유는 다음과 같다.

1. 함수 이름과 사후 DELETE는 test 성격을 보여주지만 실제 `orders` INSERT를 수행한다.
2. `SECURITY DEFINER`이며 PUBLIC EXECUTE와 authenticated EXECUTE가 있다.
3. caller가 tenant와 store를 파라미터로 제공한다.
4. 성공 시 주문 행을 지우더라도 INSERT 시점의 table trigger와 연계 객체가 실행될 수 있다.
5. §3.5는 결과에 도달하는 경로를 이름이나 의도가 아니라 실제 writer 기준으로 전수 처리한다.

따라서 §5에서 다른 writer와 같은 tenant scope · lifecycle gate를 적용하는 방안을 제안한다. 별도로 test utility의 PUBLIC EXECUTE를 유지할지는 이 gate와 구분한 권한 결정이다.

### §4.1.4 `flush_offline_queue` 처분 제안

`flush_offline_queue`의 `CREATE_ORDER` 분기는 `offline_queue`의 caller-provided `action_payload`에서 주문번호 · 유형 · 금액 · 시각을 읽고 `catchmenu_pos.orders`에 `CONFIRMED` 주문을 영속 INSERT한다. `local_temp_id`로 중복만 확인하며 tenant lifecycle은 확인하지 않는다.

함수 comment는 `ConnectivityPlus → ONLINE 감지 → flush_offline_queue()`라는 Flutter 정상 호출 경로를 명시한다. RG-02에서 수기 결제 승인의 정당성은 별도 범위로 분리됐지만, 이 함수의 주문 생성 분기는 §3의 tenant lifecycle invariant에 직접 포함된다.

**제안은 §5 gate 대상에 포함하는 것이다.** helper와 lifecycle 조회는 `offline_queue`를 읽거나 `PROCESSING`으로 바꾸기 전에 한 번 수행하고, 차단 상태에서는 어느 queue item도 변경하지 않는다.

### §4.1.5 거부 방식과 반환 계약 제안

8개 함수의 반환형은 모두 `jsonb`다.

| writer | 현재 업무 오류 방식 |
|---|---|
| `create_order` | `jsonb_build_object(success=false,error_key=...)` |
| `create_pre_order` | `jsonb_build_object(success=false,error_key=...)` |
| `pre_order_while_waiting` | `build_error_response(error_key=...)` |
| `place_kiosk_order` | `build_error_response(error_key=...)` |
| `place_takeout_order` | `build_error_response(error_key=...)` |
| `intake_delivery_order` | `jsonb_build_object(success=false,error_key=...)` |
| `flush_offline_queue` | item별 exception을 결과 JSON에 기록하고 최종 `build_success_response`; 현재 함수 전체 precondition 오류 없음 |
| `run_integration_test` | 직접 `jsonb_build_object` 반환 |

제안:

```text
tenant scope 불일치 · claim 없음
  assert_caller_tenant_scope 가 기존대로 SQLSTATE 42501 RAISE

lifecycle 차단
  각 함수의 jsonb 반환 계약을 유지
  success=false
  error_key='tenant_order_creation_blocked'

flush_offline_queue
  queue 조회·상태 변경 전에 함수 전체 error jsonb 반환
  item별 FAILED/PENDING 변경을 만들지 않음
```

scope helper는 tenant read보다 먼저 호출한다. 그 다음 서버가 `catchmenu_hq.tenants`의 `tenant_status`와 `isolation_state`를 직접 읽고, caller JSON이나 queue payload를 판정 근거로 사용하지 않는다.

⚠️ §4.1의 제안은 migration 사양이 아니다. Human 확인 후 §5로 진행한다.

### §4.1.6 Human 확인 — 2026-09-10

Human이 §4.1을 다음과 같이 처분했다.

```text
tenant_status
  허용   ACTIVE · TRIAL
  거부   SUSPENDED · CANCELLED · TERMINATED

isolation_state
  ISOLATED 는 tenant_status 와 무관하게 거부
```

허용값을 열거하고 나머지를 거부한다. 거부값만 열거하면 CHECK에 새 값이 생겼을 때 새 값이 열린 채로 남으므로 `010004` §7 deny-by-default와 같은 allowlist 구조를 사용한다.

`CANCELLED`를 거부하는 사유는 유예 기간 모델이 없기 때문이다. `601902` `TI-14`는 과금 모델 부재를 선언했고, `CANCELLED` 뒤 특정 시점까지 서비스를 허용하는 문서는 없다. 유예 기간이 정의되면 이 gate를 재개방한다.

`run_integration_test`와 `flush_offline_queue`는 모두 gate에 포함한다. lifecycle 차단은 기존 jsonb 계약을 유지해 `success=false`, `error_key='tenant_order_creation_blocked'`를 반환한다. scope 불일치는 helper의 SQLSTATE `42501`을 그대로 전파한다. PUBLIC EXECUTE 회수는 이 gate에서 하지 않으며 `RG-F6` 별건으로 유지한다.

## §5 migration

### §5.1 대상과 확정 사양

대상 파일:

```text
sql/migrations/0177_tenant_lifecycle_order_gate.sql
SHA-256     f27ea1c8b5a743009924e32ed2dd72a7b0fdc31f9b3fe581ed510cc7c0e6ae11
applied_at  2026-09-09 15:08:35.570396+00
             2026-09-10 00:08:35.570396+09
applied_by  postgres
success     true
```

8개 writer의 signature · 반환형 · 보안속성 · ACL을 유지하고 각 outer `begin`의 첫 실행 지점에 다음 gate를 넣었다.

```sql
perform catchmenu_common.assert_caller_tenant_scope(p_tenant_id);

select t.tenant_status, t.isolation_state
into v_rg04_tenant_status, v_rg04_isolation_state
from catchmenu_hq.tenants t
where t.id = p_tenant_id;

if v_rg04_tenant_status is null
   or v_rg04_tenant_status not in ('ACTIVE', 'TRIAL')
   or v_rg04_isolation_state is distinct from 'NONE'
then
  return jsonb_build_object(
    'success', false,
    'error_key', 'tenant_order_creation_blocked'
  );
end if;
```

`create_order`와 `create_pre_order`는 기존 outer `WHEN OTHERS`가 helper의 `42501`도 jsonb 오류로 바꾸므로 다음 분기를 `WHEN OTHERS`보다 앞에 추가했다.

```sql
when sqlstate '42501' then
  raise;
```

caller가 제공한 JSON · order 조건 · queue payload는 lifecycle 판정에 사용하지 않는다. `flush_offline_queue`는 queue SELECT와 `PROCESSING` UPDATE보다 먼저 차단된다. `run_integration_test`는 temp-table DELETE보다 먼저 차단된다.

### §5.2 정적 확인

```text
CREATE OR REPLACE FUNCTION  8
scope helper               8
tenant_status/state SELECT 8
ACTIVE/TRIAL allowlist     8
ISOLATED fail-closed       8
error key                  8
42501 re-raise             2
GRANT/REVOKE/ALTER FUNCTION 0
UTF-8 BOM                  없음
EOL                        LF
```

### §5.3 적용 출력

```text
BEGIN
CREATE FUNCTION
CREATE FUNCTION
CREATE FUNCTION
CREATE FUNCTION
CREATE FUNCTION
CREATE FUNCTION
CREATE FUNCTION
CREATE FUNCTION
COMMIT

UPDATE 1
checksum=f27ea1c8b5a743009924e32ed2dd72a7b0fdc31f9b3fe581ed510cc7c0e6ae11
```

### §5.4 적용 중 진단

첫 검증에서 두 구현 조건을 확인해 같은 `0177` 안에서 정정한 뒤 재적용했다.

1. `current_tenant_id()`는 `request.jwt.claims -> app_metadata ->> tenant_id`를 읽는다. 첫 검증 입력은 top-level `tenant_id`를 사용해 모든 호출이 scope denial로 끝났다. 최종 검증은 canonical `app_metadata.tenant_id`를 사용했다.
2. `create_order` · `create_pre_order`의 기존 outer exception handler가 helper의 `42501`을 jsonb로 변환했다. §5.1의 `42501` re-raise를 넣어 scope 오류를 그대로 전파했다.

두 진단 실행의 fixture와 결과는 오류 transaction에서 전부 롤백됐다. 추가 migration은 만들지 않았다. 최종 history checksum은 최종 `0177` 파일과 일치한다.

`run_integration_test`는 3인자 writer와 4인자 overload의 default 인자가 겹쳐 3개 positional 인자 호출이 ambiguous하다. T8은 signature를 바꾸지 않고 `p_scenario` named argument로 3인자 writer를 선택했다.

## §6 검증

모든 mutation 검증은 합성 fixture를 `BEGIN` 안에서 만들고 끝에서 `ROLLBACK`했다. 최종 residual tenant는 0건이다.

### §6.1 T1~T7

| Test | 입력 | 실제 출력 | 판정 |
|---|---|---|---|
| T1 | `ACTIVE + ISOLATED`, `create_order` | `success=false`, `tenant_order_creation_blocked` | PASS |
| T2 | `TERMINATED + NONE`, `create_order` | `success=false`, `tenant_order_creation_blocked` | PASS |
| T3 | `SUSPENDED + NONE`, `create_order` | `success=false`, `tenant_order_creation_blocked` | PASS |
| T4 | `CANCELLED + NONE`, `create_order` | `success=false`, `tenant_order_creation_blocked` | PASS |
| T5 | `ACTIVE + NONE`, `create_order` | `success=true`, order `04e817e2-e32a-4544-9a0e-672029a25177` | PASS |
| T6 | `TRIAL + NONE`, `create_order` | `success=true`, order `48790400-9435-48f0-85e8-aa0a30a469c7` | PASS |
| T7 | target tenant와 다른 `app_metadata.tenant_id` | SQLSTATE `42501`, `caller tenant scope denied` | PASS |

T1~T4 실제 출력:

```json
{"success": false, "error_key": "tenant_order_creation_blocked"}
```

T5 실제 출력:

```json
{"success": true, "order_id": "04e817e2-e32a-4544-9a0e-672029a25177", "item_count": 1, "final_amount": 1000, "order_number": "0001", "order_status": "PENDING", "total_amount": 1000, "kitchen_zone_summary": {"MAIN": 1}}
```

T6 실제 출력:

```json
{"success": true, "order_id": "48790400-9435-48f0-85e8-aa0a30a469c7", "item_count": 1, "final_amount": 1000, "order_number": "0001", "order_status": "PENDING", "total_amount": 1000, "kitchen_zone_summary": {"MAIN": 1}}
```

T7 실제 출력:

```text
NOTICE: T7 SQLSTATE=42501 MESSAGE=caller tenant scope denied
```

T5와 T6은 transaction 안에서 각각 주문 1건을 생성했다. `ROLLBACK` 뒤 두 주문과 모든 fixture는 남지 않았다.

### §6.2 T8 — 나머지 7 writer

`ACTIVE + ISOLATED` tenant와 같은-tenant canonical claim으로 실행했다.

```text
         writer          | success |           error_key
-------------------------+---------+-------------------------------
 create_pre_order        | false   | tenant_order_creation_blocked
 flush_offline_queue     | false   | tenant_order_creation_blocked
 intake_delivery_order   | false   | tenant_order_creation_blocked
 place_kiosk_order       | false   | tenant_order_creation_blocked
 place_takeout_order     | false   | tenant_order_creation_blocked
 pre_order_while_waiting | false   | tenant_order_creation_blocked
 run_integration_test    | false   | tenant_order_creation_blocked
(7 rows)
```

T8 전건 PASS다.

### §6.3 T9 — offline queue 무변경

ISOLATED tenant의 `CREATE_ORDER` queue item을 `PENDING`, `retry_count=0`으로 만든 뒤 `flush_offline_queue`를 호출했다.

함수 출력:

```json
{"success": false, "error_key": "tenant_order_creation_blocked"}
```

queue와 주문 실측:

```text
 queue_status | retry_count | server_result_id | flushed_at | error_detail
--------------+-------------+------------------+------------+-------------
 PENDING      |           0 |                  |            |
(1 row)

 offline_created_orders
------------------------
                      0
(1 row)
```

queue 조회 · `PROCESSING` 변경 전에 차단됐다. T9 PASS다.

### §6.4 판정

```text
Primary exploit closure
  T1 ISOLATED  DENY  PASS
  T2 TERMINATED DENY PASS

Required denial
  T3 · T4 · T8 PASS

Required success
  T5 · T6 PASS

Scope
  T7 42501 PASS

Queue immutability
  T9 PASS
```

§2에서 성공한 `TERMINATED + ISOLATED` 주문 생성은 §6에서 각 독립 거부 사유로 차단됐다.

## §7 회귀 — 예상 delta 대조

### §7.1 orders writer 전수 재확인

```text
writer_count        8
verified_gate_count 8
미검증 경로         0
```

| writer | helper 위치 | tenant read 위치 | orders INSERT 위치 | allowlist | isolation | error key |
|---|---:|---:|---:|---|---|---|
| `flush_offline_queue` | 239 | 379 | 1819 | true | true | true |
| `run_integration_test` | 275 | 415 | 3273 | true | true | true |
| `intake_delivery_order` | 478 | 618 | 4916 | true | true | true |
| `create_order` | 407 | 547 | 2273 | true | true | true |
| `create_pre_order` | 431 | 571 | 3585 | true | true | true |
| `pre_order_while_waiting` | 318 | 458 | 2914 | true | true | true |
| `place_kiosk_order` | 338 | 478 | 4177 | true | true | true |
| `place_takeout_order` | 774 | 914 | 9213 | true | true | true |

전건 `helper 위치 < tenant read 위치 < orders INSERT 위치`다.

### §7.2 8개 함수 9속성 전후 대조

대조 속성:

```text
1 identity arguments
2 arguments + defaults
3 result
4 language
5 volatility
6 SECURITY DEFINER
7 owner
8 search_path
9 ACL
```

8개 함수 모두 9속성 전후 일치다. body MD5만 gate 추가로 변경됐다.

| 함수 | body MD5 전 | body MD5 후 | 9속성 |
|---|---|---|---|
| `flush_offline_queue` | `a99c333b8d46e6bf3b72faf0ab46c4de` | `7dc223e921a100c0d644cd9fd53beb9a` | MATCH |
| `run_integration_test` | `fa6c30b997f40b2fc7db6aec7a6da2bd` | `406212c7652e53ce9ccc9932a0a26c51` | MATCH |
| `intake_delivery_order` | `3e53e32c22e093cca0f72e8143c496d7` | `34516e3c85ff912a1ef5ab1c30fc75c5` | MATCH |
| `create_order` | `f464aac639f22abbbbf12f304de5219b` | `40f339c3cbcfa73698d98ac4cbff344d` | MATCH |
| `create_pre_order` | `775acfe2401cc93f02515a5354867f37` | `8b47a6191f7c254f1f01fa4ea3d1151a` | MATCH |
| `pre_order_while_waiting` | `d409bc362650f82e5bf0632e15e5371d` | `cdd6244d1a5807240b5b0e188f4b7869` | MATCH |
| `place_kiosk_order` | `548d7c7ca90aaf503a74a14fd33db049` | `3c6701647bb5a5168673e6657f780ee6` | MATCH |
| `place_takeout_order` | `d0d0537b5d9659c3dfaa635b96720990` | `412028d4415aae3879c0ff845eea601b` | MATCH |

PUBLIC EXECUTE 3건과 authenticated ACL은 전후 동일하다. `0177`은 GRANT · REVOKE · ALTER FUNCTION을 포함하지 않는다.

### §7.3 delta

| 항목 | 예상 | 실제 | 판정 |
|---|---:|---:|---|
| migration success | +1 | +1 | MATCH |
| 대상 함수 수 | 0 | 0 | MATCH |
| 함수 body 변경 | 8 | 8 | MATCH |
| SECURITY DEFINER 수 | 0 | 0 | MATCH |
| signature · 반환형 · ACL 변경 | 0 | 0 | MATCH |
| policy · RLS 변경 | 0 | 0 | MATCH |
| orders writer | 8 | 8 | MATCH |
| 미검증 writer | 0 | 0 | MATCH |

§7 회귀 검증이 통과했다.

## §8 근거 문서 목록 (`000701` §46)

| 문서·대상 | 인용 | 역할 |
|---|---|---|
| `600023_Governance_Runtime_Gate_Spiral.md` | §3 · §3.4 · §3.5 · §5 | Runtime Gate 형식 · 기존 invariant 인용 · writer 전수 |
| `601919_Audit_Independent_Foundation_Audit.md` | `H-01` · T04 | 공격 원형과 runtime evidence |
| `601902_Register_Stage1_Business_Rules.md` | `TI-2` · `TI-12` · `TI-13` · `TI-14` | Human invariant · 상태축 독립 · 과금 모델 부재 |
| `010004_Policy_SaaS_Tenant_Isolation_And_Cross_Tenant_Data_Containment_Beam.md` | §7 | Deny-By-Default doctrine |
| `601505_ChangeContract_Operational_Authority_Foundation_Ddl.md` | §4 | 호출 금지 경계 |
| `0172` · `0173` | — | caller tenant scope precedent |
| `0174` · `0176` | — | payment gate precedent |
| `0175` | — | jsonb denial · multi-writer gate precedent |
| `0177_tenant_lifecycle_order_gate.sql` | 전문 | 이번 구현 |
| 라이브 PostgreSQL catalog | `pg_proc` · `pg_constraint` · `information_schema.columns` · `catchmenu_meta.migration_history` | writer · 상태값 · 함수 속성 · 적용 실측 |
