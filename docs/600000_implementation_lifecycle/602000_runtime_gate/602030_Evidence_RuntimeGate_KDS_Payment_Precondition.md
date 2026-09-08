# 602030_Evidence_RuntimeGate_KDS_Payment_Precondition.md

Status: Active
Lifecycle: RuntimeGate
DocumentType: Evidence
Last Updated: 2026-09-08

## §0 성격 · PRE-FLIGHT

`600023` §3 · §5와 `601919` `C-03`을 근거로 KDS payment precondition을 런타임에서 측정한다.

```text
측정일       2026-09-08
Git HEAD     2441a04df893e91be5ce25dba4d6173e71baa10e
working tree clean

DB           postgres
PostgreSQL   17.6
container    supabase_db_yoonsul_wait_order_handoff
container ID b67400e8c73e4ec7b9a25b172d71af347dd22d5e269d49859629fc3d8bd935ec
image        public.ecr.aws/supabase/postgres:17.6.1.156
Compose      yoonsul_wait_order_handoff
Supabase CLI yoonsul_wait_order_handoff
workdir      D:\Workspace\Yoonsul_Wait_Order_Handoff
environment  local/dev

latest successful migration
0174_payment_approval_integrity.sql
eb97562f3983ab84b39deda6f07895107b204dd3ca6c89c4c647816437962069
2026-09-08 09:20:49.864969+00

0175 history rows 0
0175 file         없음
```

실행 명령:

```powershell
git rev-parse HEAD
git status --short --untracked-files=all
docker inspect supabase_db_yoonsul_wait_order_handoff --format '{{.Id}}|{{.Config.Image}}|{{json .Config.Labels}}'
docker exec -i supabase_db_yoonsul_wait_order_handoff psql -X -v ON_ERROR_STOP=1 -U postgres -d postgres
```

migration history 확인 쿼리:

```sql
select filename, checksum, applied_at, applied_by, success
from catchmenu_meta.migration_history
order by applied_at desc nulls last, filename desc
limit 5;

select count(*) as migration_0175_count
from catchmenu_meta.migration_history
where filename like '0175%';
```

## §1 공격

`601919` `C-03` · `T05`와 같은 공격이다. APPROVAL 원장이 없는 HOLD ticket에 caller가 `arrived`, `table_confirmed`, `payment_confirmed`를 모두 `true`로 전달한다. 합성 fixture 전체는 한 transaction 안에서 만들고 마지막에 rollback한다.

```sql
\pset pager off
\pset format aligned
\set ON_ERROR_STOP on
\echo === RG03 T05 fixture begin ===
begin;

insert into catchmenu_hq.tenants (
  id, tenant_code, tenant_name, tenant_type, plan_tier,
  is_active, tenant_status, isolation_state
) values (
  'eeeeeeee-3000-4000-8000-000000000001',
  'RG03_AUDIT_TENANT', 'RG03 Audit Tenant', 'TEST', 'STANDARD',
  true, 'ACTIVE', 'NONE'
);

insert into catchmenu_hq.stores (
  id, tenant_id, store_code, store_name, store_type,
  store_status, timezone, is_active
) values (
  'eeeeeeee-3000-4000-8000-000000000002',
  'eeeeeeee-3000-4000-8000-000000000001',
  'RG03_STORE', 'RG03 Audit Store', 'DINE_IN',
  'ACTIVE', 'Asia/Seoul', true
);

insert into catchmenu_pos.orders (
  id, tenant_id, store_id, order_number,
  order_type, order_status, total_amount, discount_amount,
  final_amount, order_channel, business_day,
  business_timezone, correlation_id
) values (
  'eeeeeeee-3000-4000-8000-000000000003',
  'eeeeeeee-3000-4000-8000-000000000001',
  'eeeeeeee-3000-4000-8000-000000000002',
  'RG03-0001', 'DINE_IN', 'CONFIRMED',
  1000, 0, 1000, 'STAFF_POS', current_date,
  'Asia/Seoul', 'RG03-AUDIT'
);

insert into catchmenu_kds.kds_tickets (
  id, tenant_id, store_id, order_id,
  ticket_number, kds_status, kitchen_zone, priority,
  menu_name_snapshot, quantity_snapshot,
  conditions_met, business_day, business_timezone
) values (
  'eeeeeeee-3000-4000-8000-000000000007',
  'eeeeeeee-3000-4000-8000-000000000001',
  'eeeeeeee-3000-4000-8000-000000000002',
  'eeeeeeee-3000-4000-8000-000000000003',
  'RG03-0001-01', 'HOLD', 'MAIN', 5,
  'RG03 Audit Menu', 1,
  '{}'::jsonb, current_date, 'Asia/Seoul'
);

select
  (select kds_status
   from catchmenu_kds.kds_tickets
   where id = 'eeeeeeee-3000-4000-8000-000000000007') as kds_status,
  (select count(*)
   from catchmenu_payment.payment_ledger
   where tenant_id = 'eeeeeeee-3000-4000-8000-000000000001'
     and order_id = 'eeeeeeee-3000-4000-8000-000000000003')
    as payment_ledger_rows;

set local role authenticated;
select set_config(
  'request.jwt.claims',
  '{"sub":"aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa","tenant_id":"aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa","store_id":"aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa","role":"authenticated","actor_type":"STAFF"}',
  true
);

select catchmenu_kds.commit_kds_ticket(
  'eeeeeeee-3000-4000-8000-000000000001',
  'eeeeeeee-3000-4000-8000-000000000002',
  'eeeeeeee-3000-4000-8000-000000000007',
  '{"arrived":true,"table_confirmed":true,"payment_confirmed":true}'::jsonb,
  'RG03-AUDIT'
) as attack_result;

reset role;
select id, kds_status, conditions_met, payment_ledger_id
from catchmenu_kds.kds_tickets
where id = 'eeeeeeee-3000-4000-8000-000000000007';

select count(*) as payment_ledger_rows
from catchmenu_payment.payment_ledger
where tenant_id = 'eeeeeeee-3000-4000-8000-000000000001'
  and order_id = 'eeeeeeee-3000-4000-8000-000000000003';

rollback;

select
  (select count(*) from catchmenu_hq.tenants
   where id = 'eeeeeeee-3000-4000-8000-000000000001') as tenant_rows,
  (select count(*) from catchmenu_hq.stores
   where id = 'eeeeeeee-3000-4000-8000-000000000002') as store_rows,
  (select count(*) from catchmenu_pos.orders
   where id = 'eeeeeeee-3000-4000-8000-000000000003') as order_rows,
  (select count(*) from catchmenu_kds.kds_tickets
   where id = 'eeeeeeee-3000-4000-8000-000000000007') as ticket_rows,
  (select count(*) from catchmenu_payment.payment_ledger
   where tenant_id = 'eeeeeeee-3000-4000-8000-000000000001')
    as ledger_rows;
```

## §2 재현 로그

현재 상태에서 공격은 성공했다.

```text
Pager usage is off.
Output format is aligned.
=== RG03 T05 fixture begin ===
BEGIN
INSERT 0 1
INSERT 0 1
INSERT 0 1
INSERT 0 1
=== before attack ===
 kds_status | payment_ledger_rows
------------+---------------------
 HOLD       |                   0
(1 row)

SET
set_config
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
{"sub":"aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa","tenant_id":"aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa","store_id":"aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa","role":"authenticated","actor_type":"STAFF"}
(1 row)

=== attack call ===
attack_result
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
{"success": true, "audit_id": "e1b71102-f1df-4fac-a291-664889622f61", "ticket_id": "eeeeeeee-3000-4000-8000-000000000007", "kds_status": "COMMITTED", "committed_at": "2026-09-08T09:50:15.972432+00:00", "kitchen_zone": "MAIN", "message_code": "kds_committed", "conditions_met": {"arrived": true, "kds_capacity_ok": true, "table_confirmed": true, "payment_confirmed": true}}
(1 row)

RESET
=== after attack ===
                  id                  | kds_status |                                         conditions_met                                         | payment_ledger_id
--------------------------------------+------------+------------------------------------------------------------------------------------------------+-------------------
 eeeeeeee-3000-4000-8000-000000000007 | COMMITTED  | {"arrived": true, "kds_capacity_ok": true, "table_confirmed": true, "payment_confirmed": true} |
(1 row)

 payment_ledger_rows
---------------------
                   0
(1 row)

ROLLBACK
=== residual after rollback ===
 tenant_rows | store_rows | order_rows | ticket_rows | ledger_rows
-------------+------------+------------+-------------+-------------
           0 |          0 |          0 |           0 |           0
(1 row)
```

`601919` §2의 성공 공격과 동일하게 APPROVAL 원장 0행에서 `COMMITTED`가 저장됐다. `payment_ledger_id`도 NULL이다.

## §3 invariant

⚠️ Human이 확정했다. 아래 문면을 그대로 인용한다.

```text
① KDS COMMITTED 는 결제 승인 없이 도달하지 않는다

   해당 order 에 payment_ledger 의 APPROVAL 원장이 존재하고
   그 원장이 승인 상태여야 한다

   caller 가 넘긴 조건 jsonb 는 그 판정의 근거가 아니다
   서버가 원장을 직접 조회해 판정한다

② 무결제 예외는 명시적 store 정책으로만 열린다

   store 설정이 무결제 release 를 허용할 때에만
   전용 경로가 그 예외를 사용한다

   일반 commit 경로는 그 예외를 쓰지 않는다

③ tenant scope

   assert_caller_tenant_scope 를 tenant read 보다 먼저 호출한다
```

> ⚠️ **`①`의 핵심은 「caller 주장을 근거로 쓰지 않는다」다.**
> **`p_conditions`·`p_force_conditions`를 받아도 되나 결제 여부 판정에 그 값을 쓰면 안 된다.**
>
> ⚠️ **`RG-02`가 `payment_ledger`의 승인 identity와 binding을 확정했다.**
> **`①`은 그 산출을 소비한다.**

## §4 근거

| 구분 | 근거 |
|---|---|
| Doctrine | `010004` §14 Payment And Financial Isolation |
| Human invariant | `602030` §3 |
| Runtime evidence | `601919` `C-03` |
| Precedent only | `0143` · `0172` · `0173` · `0174` |

## §4.1 실측 — 5항

### §4.1.1 `commit_kds_ticket` · `bulk_commit_kds_tickets`

라이브 속성 기준선:

| 함수 | signature | return | language | volatility | security | owner | search_path | ACL | body MD5 |
|---|---|---|---|---|---|---|---|---|---|
| `commit_kds_ticket` | `(uuid,uuid,uuid,jsonb,text)` | `jsonb` | `plpgsql` | volatile | `SECURITY DEFINER` | postgres | `catchmenu_kds, catchmenu_ledger, catchmenu_audit, catchmenu_common` | postgres/authenticated EXECUTE | `316c93d430cb0d7f0367e7669c4f8e83` |
| `bulk_commit_kds_tickets` | `(uuid,uuid,uuid,jsonb,text)` | `jsonb` | `plpgsql` | volatile | `SECURITY DEFINER` | postgres | `catchmenu_kds, catchmenu_payment, catchmenu_ledger, catchmenu_common` | postgres/authenticated EXECUTE | `2e0e2ba70fbc2f540d79b23ddd1c5d40` |

`commit_kds_ticket` 본문의 판정 경로:

```sql
v_merged_conditions :=
  coalesce(v_ticket.conditions_met, '{}'::jsonb)
  || coalesce(p_conditions, '{}'::jsonb);

v_merged_conditions := v_merged_conditions || jsonb_build_object(
  'kds_capacity_ok',
  (v_capacity->>'capacity_ok')::boolean
);

v_all_met := (
  coalesce((v_merged_conditions->>'arrived')::boolean, false)
  and coalesce((v_merged_conditions->>'table_confirmed')::boolean, false)
  and coalesce((v_merged_conditions->>'payment_confirmed')::boolean, false)
  and coalesce((v_merged_conditions->>'kds_capacity_ok')::boolean, false)
  and coalesce((v_merged_conditions->>'menu_available')::boolean, true)
  and coalesce((v_merged_conditions->>'peak_time_ok')::boolean, true)
  and coalesce((v_merged_conditions->>'no_show_risk_ok')::boolean, true)
);
```

- `p_conditions`를 기존 `conditions_met`에 그대로 병합한다.
- capacity만 서버가 다시 계산한다.
- `payment_confirmed`는 병합된 JSON에서 읽는다.
- `payment_ledger` 조회가 없다.
- `kds_tickets.payment_ledger_id`를 읽거나 채우지 않는다.
- `assert_caller_tenant_scope` 호출 위치는 0이며 첫 ticket read 전에 tenant scope gate가 없다.

`bulk_commit_kds_tickets` 본문의 판정 경로:

```sql
select coalesce(bool_or(kds_release_authorized), false)
into v_payment_authorized
from catchmenu_payment.payment_ledger
where order_id = p_order_id
  and store_id = p_store_id
  and tenant_id = p_tenant_id
  and ledger_status = 'APPROVED';

v_merged_conditions := coalesce(
  v_ticket.conditions_met, '{}'::jsonb
) || coalesce(p_force_conditions, '{}'::jsonb);

v_commit_result := catchmenu_kds.commit_kds_ticket(
  p_tenant_id := p_tenant_id,
  p_store_id := p_store_id,
  p_ticket_id := v_ticket.id,
  p_conditions := v_merged_conditions,
  p_correlation_id := p_correlation_id
);
```

- 원장 gate를 caller JSON 병합 전에 수행한다.
- 원장 조건은 tenant/store/order, `ledger_status='APPROVED'`, `bool_or(kds_release_authorized)`다.
- `ledger_entry_type='APPROVAL'` 조건은 없다.
- gate 후 `p_force_conditions`를 기존 조건과 병합해 `commit_kds_ticket`에 넘긴다.
- `kds_tickets.payment_ledger_id`를 채우지 않는다.
- `assert_caller_tenant_scope` 호출 위치는 0이며 첫 ledger read 전에 tenant scope gate가 없다.

`p_force_conditions`로 결제를 주장하되 원장이 없는 호출의 실측:

```text
=== bulk p_force_conditions attack without ledger ===
{"message": "payment_ledger.kds_release_authorized must be true for all tickets", "success": false, "order_id": "eeeeeeee-3200-4000-8000-000000000003", "error_key": "kds_release_not_authorized"}

kds_status | conditions_met | payment_ledger_id
-----------+----------------+------------------
HOLD       | {}             |

ROLLBACK
residual 0
```

현재 bulk 경로에서는 원장 없는 `p_force_conditions` 공격이 선행 gate에서 거부된다. 단일 commit 경로가 그 gate를 우회한다.

### §4.1.2 `kds_tickets.conditions_met`

컬럼 comment가 정의한 의미:

```text
Tracks which Late Binding conditions are satisfied.
All must be true before HOLD → COMMITTED transition.
arrived: customer physically arrived at store.
table_confirmed: table assignment completed (Late Binding).
payment_confirmed: payment_ledger.kds_release_authorized = true.
kds_capacity_ok: kitchen load within acceptable threshold.
menu_available: menu item not sold out.
peak_time_ok: not in restricted peak period for this menu.
no_show_risk_ok: customer arrival reliability score acceptable.
```

라이브 함수에서 이 컬럼을 채우거나 바꾸는 경로:

| 구분 | 함수 | 기록 내용 |
|---|---|---|
| test fixture | `catchmenu_common.run_integration_test` | `payment_confirmed=false`, `test=true` |
| order 생성 | `catchmenu_pos.confirm_order` | arrived/table 상태, `payment_confirmed=false`, capacity false, menu/peak/no-show 조건 |
| pre-order 생성 | `catchmenu_pos.create_pre_order` | 7개 조건을 false 또는 메뉴·신뢰도 실측값으로 초기화 |
| waiting pre-order | `catchmenu_pos.pre_order_while_waiting` | payment/release false와 waiting/session 출처 |
| kiosk/takeout | `catchmenu_store.place_kiosk_order`, `place_takeout_order` | payment/release false와 주문 출처 |
| delivery intake | `catchmenu_integrations.intake_delivery_order` | arrived/table/payment true, capacity false, 나머지 true |
| delivery accept | `catchmenu_integrations.accept_delivery_order` | payment/release/delivery_pre_paid true와 platform; 티켓을 COMMITTED로 직접 INSERT |
| arrival | `catchmenu_pos.confirm_pre_order_arrival` | arrived/table true 병합 |
| provider approval | `catchmenu_payment.confirm_payment_from_provider` | payment true 병합, 별도 컬럼 `payment_ledger_id` 설정 |
| menu state | `catchmenu_integrations.sync_pos_menu_item`, `catchmenu_pos.update_menu_status` | menu availability와 POS sync/peak 상태 병합 |
| general commit | `catchmenu_kds.commit_kds_ticket` | caller JSON 전체 병합, capacity 재계산 |
| no-payment release | `catchmenu_kds.release_kds_ticket_no_payment` | capacity와 no-payment policy 출처·actor 기록 |
| payment release | `catchmenu_payment.release_kds_after_payment` | payment/release true와 전달받은 ledger ID로 JSON 전체 교체 |

판정에 사용하는 코드:

- `commit_kds_ticket`이 7개 flag를 읽어 COMMITTED 여부를 결정한다.
- `bulk_commit_kds_tickets`가 기존 JSON과 `p_force_conditions`를 합친 뒤 단일 commit에 넘긴다.
- `release_kds_ticket_no_payment`가 payment 조건을 제외한 6개 flag를 읽어 전용 예외 release를 결정한다.
- `start_cooking`은 COMMITTED 상태와 `payment_ledger_id` 및 연결 원장의 상태를 검사한다. `conditions_met`은 event/audit 상태로 전달하지만 payment 판정 근거로 쓰지 않는다.
- bootstrap/realtime/status 함수들은 `conditions_met`을 조회·표시한다.

### §4.1.3 `release_kds_ticket_no_payment` 3단계 검증

정책 컬럼은 `catchmenu_store.store_settings.payment_required_for_kds_release boolean NOT NULL DEFAULT true`다.

함수는 다음 순서로 확인한다.

1. session claim에서 읽은 tenant/store/actor가 파라미터와 모두 같은지 확인한다.
2. 같은 tenant/store의 ACTIVE staff이고 `can_override_kds=true`인지 확인한다.
3. 같은 tenant/store의 `store_settings.payment_required_for_kds_release=false` 행이 있는지 확인한다.

그 뒤 ticket tenant/store/order와 HOLD 상태를 잠그고, payment를 제외한 나머지 조건과 capacity를 검사한다.

런타임 실측:

```text
=== stage 1 context mismatch ===
{"success": false, "error_key": "release_context_mismatch"}

=== stage 2 staff cannot override ===
{"success": false, "error_key": "unauthorized_release"}

=== stage 3 policy still requires payment ===
{"success": false, "error_key": "no_payment_policy_not_active"}

=== explicit policy open ===
{"success": true, "audit_id": "2bd6c9b2-feae-4da5-a339-42f3086b82ad", "order_id": "eeeeeeee-3100-4000-8000-000000000003", "ticket_id": "eeeeeeee-3100-4000-8000-000000000007", "kds_status": "COMMITTED", "message_code": "kds_no_payment_policy_released", "authorized_by": "eeeeeeee-3100-4000-8000-000000000008", "release_source": "STORE_NO_PAYMENT_POLICY", "already_released": false}

kds_status COMMITTED
payment_ledger_id NULL
conditions_met.no_payment_policy_released true

ROLLBACK
tenant_rows 0 | staff_rows 0 | ticket_rows 0
```

store 정책은 실제로 확인된다. 정책이 기본값 `true`인 동안 거부됐고 명시적으로 `false`로 바꾼 뒤에만 전용 경로가 성공했다.

### §4.1.4 `payment_ledger`와 order 연결 경로

물리 연결:

```text
kds_tickets.order_id       → orders.id
payment_ledger.order_id    → orders.id
payment_ledger.intent_id   → payment_intents.id
payment_intents.order_id   → orders.id
kds_tickets.payment_ledger_id → payment_ledger.id
```

현재 `commit_kds_ticket`과 `bulk_commit_kds_tickets`는 `kds_tickets.payment_ledger_id`를 채우지 않는다. `confirm_payment_from_provider`는 APPROVAL 생성 뒤 해당 order의 HOLD/CAPACITY_CHECKING ticket에 그 ledger ID를 채운다.

§3 ①을 직접 표현하는 조회 조건 제안:

```sql
select pl.id
into v_approval_ledger_id
from catchmenu_payment.payment_ledger pl
where pl.tenant_id = p_tenant_id
  and pl.store_id = p_store_id
  and pl.order_id = v_ticket.order_id
  and pl.ledger_entry_type = 'APPROVAL'
  and pl.ledger_status = 'APPROVED'
order by pl.approved_at, pl.id
limit 1
for share;
```

이 조회는 caller JSON을 사용하지 않는다. `FOR SHARE`는 COMMITTED 기록 transaction이 끝날 때까지 선택한 행의 `ledger_status` 변경을 막는다. 성공 시 선택한 `pl.id`를 `kds_tickets.payment_ledger_id`에 기록할 수 있다. bulk는 order 단위로 같은 조건을 선확인할 수 있으나 각 ticket의 최종 판정은 단일 commit과 같은 서버 원장 조회를 사용해야 한다.

### §4.1.5 COMMITTED로 가는 다른 경로

지시된 core KDS 상태 기록 함수 8개 전수:

| # | 함수 | 기록 상태 | COMMITTED 기록 |
|---|---|---|---|
| 1 | `commit_kds_ticket` | COMMITTED · CAPACITY_CHECKING | 예 |
| 2 | `start_cooking` | COOKING | 아니오 |
| 3 | `complete_cooking` | READY | 아니오 |
| 4 | `serve_ticket` | SERVED | 아니오 |
| 5 | `complete_order_kds` | COMPLETED | 아니오 |
| 6 | `cancel_kds_hold` | CANCELLED | 아니오 |
| 7 | `expire_no_show_kds_hold` | CANCELLED | 아니오 |
| 8 | `recover_no_show_grace_ticket` | HOLD | 아니오 |

이 8개 중 COMMITTED를 직접 기록하는 것은 `commit_kds_ticket` 1개다. 그러나 라이브 catalog 전체의 `kds_tickets` mutation을 대조하면 다음 별도 경로가 있다.

| 경로 | COMMITTED 기록 | 원장 확인 |
|---|---|---|
| `catchmenu_kds.release_kds_ticket_no_payment` | UPDATE | store 정책·staff·claim의 전용 3단계 예외 |
| `catchmenu_payment.release_kds_after_payment` | UPDATE | 전달받은 ledger UPDATE의 성공행 수·order·entry type·status를 확인하지 않음 |
| `catchmenu_integrations.accept_delivery_order` | INSERT | `conditions_met`에 payment/release/prepaid true를 기록하지만 `payment_ledger_id`를 기록하지 않음 |

호출 연결:

```text
bulk_commit_kds_tickets → commit_kds_ticket
confirm_payment_from_provider → request_kds_release_after_payment
request_kds_release_after_payment → bulk_commit_kds_tickets
confirm_payment → release_kds_after_payment
receive_delivery_order → accept_delivery_order
```

`release_kds_after_payment`는 authenticated EXECUTE가 있는 SECURITY DEFINER 함수다. 존재하지 않는 ledger ID를 넘긴 런타임 실측:

```text
=== RG03 alternate COMMITTED path measurement ===
BEGIN
fixture tenant/store/order/HOLD ticket inserted
SET ROLE authenticated

alternate_path_result
{"data": {"order_id": "eeeeeeee-3300-4000-8000-000000000003", "kds_status": "COMMITTED", "ticket_ids": ["eeeeeeee-3300-4000-8000-000000000007"], "released_count": 1, "late_binding_principle": "HOLD -> COMMITTED after payment only"}, "message": "주방으로 주문이 전달되었습니다", "success": true, "message_key": "kds_released"}

id eeeeeeee-3300-4000-8000-000000000007
kds_status COMMITTED
conditions_met {"released_at": "2026-09-08T09:58:57.554798+00:00", "payment_confirmed": true, "payment_ledger_id": "eeeeeeee-3300-4000-8000-000000000099", "kds_release_authorized": true}
kds_tickets.payment_ledger_id NULL
payment_ledger_rows 0

ROLLBACK
residual 0
```

`commit_kds_ticket`·`bulk_commit_kds_tickets` 두 함수만 수정해도 `release_kds_after_payment`와 `accept_delivery_order`의 직접 COMMITTED 기록은 그대로 남는다.

### §4.1.6 Human 확인 — 범위 확대

Human은 §3 ①이 경로와 무관한 invariant이므로 다음 네 경로를 함께 닫도록 확정했다.

| 함수 | COMMITTED 기록 | 적용할 gate | `payment_ledger_id` 기록 |
|---|---|---|---|
| `commit_kds_ticket` | 기존 ticket UPDATE | 서버가 승인 원장 조회 | 선택한 원장 ID |
| `bulk_commit_kds_tickets` | `commit_kds_ticket` 호출 | bulk 선확인과 각 ticket의 독립 재확인 | 단일 commit이 기록 |
| `release_kds_after_payment` | 기존 ticket UPDATE | 전달받은 ID의 실재·binding·상태 확인 | 검증된 원장 ID |
| `accept_delivery_order` | 새 ticket INSERT | intake에 이미 연결된 order의 승인 원장 조회 | 선택한 원장 ID |

네 함수 모두 `assert_caller_tenant_scope`를 tenant read보다 먼저 호출한다. 원장 조회 조건은 `tenant_id`·`store_id`·`order_id`가 처리 대상과 같고 `ledger_entry_type='APPROVAL'`, `ledger_status='APPROVED'`인 행이다. caller JSON은 결제 판정 근거로 사용하지 않는다.

무결제 예외는 `store_settings.payment_required_for_kds_release=false`일 때의 `release_kds_ticket_no_payment`만 사용한다. 이 함수는 수정하지 않는다.

## §5 migration

대상: `sql/migrations/0175_kds_payment_precondition.sql`

```text
filename    0175_kds_payment_precondition.sql
SHA-256     f1fbae219d4b35ba7b058636802cf9643b8e3177f873ff6caba0c8746f4af974
applied_at  2026-09-08 10:15:14.656249+00
applied_by  postgres
success     true
```

적용 전 파일에서 `BEGIN`·`COMMIT`만 제외한 네 `CREATE OR REPLACE FUNCTION`을 별도 transaction에 넣어 parse한 뒤 rollback했다. parse 성공 후 같은 파일과 checksum으로 migration과 history 기록을 한 transaction에서 적용했다.

적용 내용:

1. `commit_kds_ticket`은 tenant gate 뒤 ticket을 잠그고 서버가 승인 원장을 조회한다. 원장이 없으면 `payment_approval_required`를 반환한다. caller의 `payment_confirmed`·`payment_ledger_id`·`kds_release_authorized`를 제거한 뒤 서버 결과를 넣고, COMMITTED UPDATE에 선택한 ledger ID를 기록한다.
2. `bulk_commit_kds_tickets`은 tenant gate 뒤 order의 승인 원장을 선확인한다. `p_force_conditions`의 결제 관련 키를 제거하며, 각 ticket은 수정된 `commit_kds_ticket`에서 다시 판정한다.
3. `release_kds_after_payment`는 전달받은 ledger ID가 같은 tenant·store·order의 APPROVED APPROVAL인지 잠금 조회로 확인한다. 확인된 ID를 ticket column과 evidence JSON에 기록한다.
4. `accept_delivery_order`는 tenant gate 뒤 intake에 이미 binding된 order를 읽고 그 order의 승인 원장을 조회한다. 원장 없는 신규 order를 만들지 않으며, 기존 order에 ticket을 INSERT하면서 선택한 ledger ID를 기록한다.
5. 네 승인 원장 조회는 `FOR SHARE`로 선택 행을 잠가 COMMITTED 기록 transaction 동안 `ledger_status`의 동시 변경을 차단한다.
6. 네 함수의 signature·defaults·return type·language·volatility·SECURITY DEFINER·owner·search_path·ACL은 유지한다.
7. `release_kds_ticket_no_payment` 본문은 수정하지 않는다.

migration history 실측:

```text
             filename              |                             checksum                             |          applied_at           | applied_by | success
-----------------------------------+------------------------------------------------------------------+-------------------------------+------------+---------
 0175_kds_payment_precondition.sql | f1fbae219d4b35ba7b058636802cf9643b8e3177f873ff6caba0c8746f4af974 | 2026-09-08 10:15:14.656249+00 | postgres   | t
(1 row)
```

## §6 검증

모든 T1~T9는 합성 fixture를 한 transaction 안에서 만들고 마지막에 rollback했다. T1~T6 뒤 상태를 확인한 다음 정상 APPROVAL fixture를 추가해 T7을 수행했다. T8은 `authenticated`와 다른 tenant claim으로 호출했다. T9는 별도 order와 ticket에서 store 정책을 `false`로 둔 전용 무결제 경로다.

### §6.1 T1~T6 공격 차단

실제 출력:

```text
=== T1 commit_kds_ticket without approval ===
{"success": false, "order_id": "eeeeeeee-3500-4000-8000-000000000003", "error_key": "payment_approval_required"}

=== T2 bulk_commit_kds_tickets without approval ===
{"success": false, "order_id": "eeeeeeee-3500-4000-8000-000000000003", "error_key": "payment_approval_required"}

=== T3 p_conditions payment claim ===
{"success": false, "order_id": "eeeeeeee-3500-4000-8000-000000000003", "error_key": "payment_approval_required"}

=== T4 p_force_conditions payment claim ===
{"success": false, "order_id": "eeeeeeee-3500-4000-8000-000000000003", "error_key": "payment_approval_required"}

=== T5 release_kds_after_payment fake ledger id ===
{"success": false, "order_id": "eeeeeeee-3500-4000-8000-000000000003", "error_key": "payment_approval_required", "ledger_id": "eeeeeeee-3500-4000-8000-000000000099"}

=== T6 accept_delivery_order without approval ===
{"success": false, "error_key": "payment_approval_required", "intake_id": "eeeeeeee-3500-4000-8000-000000000010"}

=== state after T1-T6 ===
ticket eeeeeeee-3500-4000-8000-000000000007 | HOLD | payment_ledger_id NULL
ticket eeeeeeee-3500-4000-8000-000000000008 | HOLD | payment_ledger_id NULL
intake eeeeeeee-3500-4000-8000-000000000010 | RECEIVED | order_id NULL
```

| 시험 | 기대 | 실제 | 판정 |
|---|---|---|---|
| T1 단일 commit, 결제 없음 | DENY | `payment_approval_required` | PASS |
| T2 bulk commit, 결제 없음 | DENY | `payment_approval_required` | PASS |
| T3 `p_conditions` 결제 주장 | DENY | `payment_approval_required` | PASS |
| T4 `p_force_conditions` 결제 주장 | DENY | `payment_approval_required` | PASS |
| T5 가짜 ledger ID | DENY | `payment_approval_required` | PASS |
| T6 delivery accept, 결제 없음 | DENY | `payment_approval_required` | PASS |

### §6.2 T7 정상 승인 후 commit

APPROVAL fixture:

```text
ledger_id          eeeeeeee-3500-4000-8000-000000000006
tenant_id          eeeeeeee-3500-4000-8000-000000000001
store_id           eeeeeeee-3500-4000-8000-000000000002
order_id           eeeeeeee-3500-4000-8000-000000000003
ledger_entry_type  APPROVAL
ledger_status      APPROVED
```

실제 출력:

```text
=== T7 approved commit ===
success             true
kds_status          COMMITTED
ticket_id           eeeeeeee-3500-4000-8000-000000000007
stored ledger       eeeeeeee-3500-4000-8000-000000000006
payment_confirmed   true
JSON ledger         eeeeeeee-3500-4000-8000-000000000006
```

정상 승인은 성공했고 ticket column과 `conditions_met.payment_ledger_id`가 선택한 APPROVAL 원장을 가리켰다. T7 PASS.

최종 lock 강도 보정 뒤 같은 deny/success 쌍을 다시 실행했다. caller가 보낸 `payment_confirmed=false`와 가짜 `payment_ledger_id`도 서버 값으로 덮어썼다.

```text
FINAL_T1
{"success": false, "order_id": "eeeeeeee-3700-4000-8000-000000000003", "error_key": "payment_approval_required"}

FINAL_T7
{"success": true, "ticket_id": "eeeeeeee-3700-4000-8000-000000000007", "kds_status": "COMMITTED", "conditions_met": {"arrived": true, "kds_capacity_ok": true, "table_confirmed": true, "payment_confirmed": true, "payment_ledger_id": "eeeeeeee-3700-4000-8000-000000000006"}}

stored
COMMITTED|eeeeeeee-3700-4000-8000-000000000006|true|eeeeeeee-3700-4000-8000-000000000006

ROLLBACK
residual 0
```

### §6.3 T8 tenant scope

실제 출력:

```text
NOTICE: T8 DENY sqlstate=42501
NOTICE: T8 message=caller tenant scope denied
NOTICE: T8 context=PL/pgSQL function catchmenu_common.assert_caller_tenant_scope(uuid)
```

타 tenant claim 호출은 원장·ticket read 전에 42501로 거부됐다. T8 PASS.

### §6.4 T9 무결제 전용 경로

`payment_required_for_kds_release=false`인 별도 store fixture에서 수정하지 않은 함수를 호출했다.

```text
=== T9 release_kds_ticket_no_payment ===
success                    true
kds_status                 COMMITTED
release_source             STORE_NO_PAYMENT_POLICY
payment_ledger_id          NULL
no_payment_policy_released true
```

store 정책으로 열린 전용 경로만 승인 원장 없이 성공했다. T9 PASS.

### §6.5 rollback 확인

```text
ROLLBACK
tenant residual  0
ticket residual  0
ledger residual  0
intake residual  0
```

Primary exploit closure인 T1·T3·T4·T5·T6가 모두 DENY였고 정상 경로 T7·T9가 성공했다.

## §7 회귀

### §7.1 네 경로 정상 승인

정상 APPROVAL 원장을 각각 가진 별도 fixture로 bulk, release, delivery accept를 추가 확인했다. 최초 fixture의 `order_channel='ONLINE'`은 라이브 CHECK 허용값이 아니어서 함수 호출 전에 rollback했고 잔존 행은 0이었다. 허용값 `DELIVERY_BAEMIN`으로 다시 만든 최종 실행 결과는 다음과 같다.

```text
approved bulk
  success          true
  committed_count  1
  all_committed    true

approved release
  success          true
  released_count   1

approved accept_delivery_order
  success          true
  intake_status    ACCEPTED
  kds_ticket_count 1

stored payment links
  order eeeeeeee-3600-4000-8000-000000000003 -> ledger eeeeeeee-3600-4000-8000-000000000006
  order eeeeeeee-3600-4000-8000-000000000013 -> ledger eeeeeeee-3600-4000-8000-000000000016
  order eeeeeeee-3600-4000-8000-000000000023 -> ledger eeeeeeee-3600-4000-8000-000000000026

ROLLBACK
tenant residual 0
ticket residual 0
ledger residual 0
intake residual 0
```

### §7.2 COMMITTED 기록 객체 전수 재확인

라이브 `pg_proc.prosrc`에서 `kds_tickets`와 `COMMITTED`를 함께 참조하는 객체를 전수 추출한 뒤 실제 mutation 문을 대조했다.

| 경로 | 기록 방식 | gate 결과 |
|---|---|---|
| `commit_kds_ticket` | `UPDATE ... kds_status='COMMITTED'` | 승인 원장 직접 조회·column 기록 |
| `bulk_commit_kds_tickets` | 위 함수를 호출 | 선확인 + 단일 commit 재확인 |
| `release_kds_after_payment` | `UPDATE ... kds_status='COMMITTED'` | 전달 ID의 실재·binding·상태 확인·column 기록 |
| `accept_delivery_order` | `INSERT ... 'COMMITTED'` | binding된 order의 승인 원장 직접 조회·column 기록 |
| `release_kds_ticket_no_payment` | `UPDATE ... kds_status='COMMITTED'` | store 정책 전용 예외·미수정 |

일반 COMMITTED 경로 중 네 함수 밖에 남은 미검증 경로는 0건이다. `bulk_commit_kds_tickets`는 간접 경로이며, `release_kds_ticket_no_payment`는 §3 ②의 전용 예외다.

### §7.3 예상 delta 대조

동일한 catalog 집계 쿼리로 적용 전후를 비교했다.

| 항목 | before | after | delta | 예상 | 판정 |
|---|---:|---:|---:|---:|---|
| migration success | latest `0174` | latest `0175` | +1 | +1 | 일치 |
| 함수 수 | 475 | 475 | 0 | 0 | 일치 |
| SECURITY DEFINER | 465 | 465 | 0 | 0 | 일치 |
| policy | 183 | 183 | 0 | 0 | 일치 |
| RLS table | 173 | 173 | 0 | 0 | 일치 |
| unique index | 319 | 319 | 0 | 0 | 일치 |
| CHECK 제약 | 453 | 453 | 0 | 0 | 일치 |

### §7.4 네 함수 전후 속성

네 함수 모두 다음 여덟 속성이 같고 본문 MD5만 바뀌었다.

| 속성 | before | after | 변화 |
|---|---|---|---|
| signature와 defaults | 각 기존값 | 동일 | 0 |
| return type | `jsonb` | `jsonb` | 0 |
| language | `plpgsql` | `plpgsql` | 0 |
| volatility | `VOLATILE` | `VOLATILE` | 0 |
| SECURITY DEFINER | true | true | 0 |
| owner | `postgres` | `postgres` | 0 |
| search_path | 각 기존값 | 동일 | 0 |
| ACL | `postgres=X/postgres, authenticated=X/postgres` | 동일 | 0 |

함수별 signature와 본문 MD5:

| 함수 | identity arguments | body MD5 before | body MD5 after |
|---|---|---|---|
| `accept_delivery_order` | `uuid,uuid,uuid,integer,uuid,text,text` | `6cad5fb45931bce7fce18fefd90b38fb` | `5b1ef12bf97279354afb4b52d789096e` |
| `bulk_commit_kds_tickets` | `uuid,uuid,uuid,jsonb,text` | `2e0e2ba70fbc2f540d79b23ddd1c5d40` | `c95caac0a796ae6c882b63a597c6586a` |
| `commit_kds_ticket` | `uuid,uuid,uuid,jsonb,text` | `316c93d430cb0d7f0367e7669c4f8e83` | `fa97e89bc2c1919888600c42ef81cc16` |
| `release_kds_after_payment` | `uuid,uuid,uuid,uuid,text,text` | `38ab842bb19377fcfba40de1855b6fac` | `3244490fb26441226f272512da514c13` |

helper와 첫 tenant read의 본문 문자 위치:

| 함수 | helper | 첫 tenant read | 순서 |
|---|---:|---:|---|
| `accept_delivery_order` | 305 | 383 | helper 먼저 |
| `bulk_commit_kds_tickets` | 272 | 359 | helper 먼저 |
| `commit_kds_ticket` | 180 | 876 | helper 먼저 |
| `release_kds_after_payment` | 187 | 274 | helper 먼저 |

`release_kds_ticket_no_payment` 본문 MD5는 적용 전후 모두 `4c01a445537a1abdd0d64f9318c758ed`다.

### §7.5 Governance

```text
> tools/Check-Governance.ps1 -Top 0
PS_EXIT=0
전체 finding 506
```

이번 두 파일에 새로 연결된 finding은 예상한 두 종류뿐이다.

```text
G11  602030 미색인
G15  0175 CONTRACT_NOT_FOUND
```

`602030`의 DocumentType, H1, UTF-8/BOM/LF 관련 신규 finding은 없다. 그 밖의 신규 finding은 관측되지 않았다.

## §8 근거 문서 목록 (000701 §46)

| 문서 | 사용 절 |
|---|---|
| `600023_Governance_Runtime_Gate_Spiral.md` | §3 · §5 |
| `601919_Audit_Independent_Foundation_Audit.md` | C-03 · T05 |
| `010004_Policy_SaaS_Tenant_Isolation_And_Cross_Tenant_Data_Containment_Beam.md` | §14 |
| `602020_Evidence_RuntimeGate_Payment_Approval_Integrity.md` | RG-02 승인 원장 identity·binding |
| `0143_kds_no_payment_policy.sql` | 무결제 전용 경로 precedent |
| `0172_caller_tenant_scope_gate.sql` | tenant scope helper 최초 정의 |
| `0173_caller_tenant_scope_remove_claim_exemption.sql` | claim exemption 제거 |
| `0174_payment_approval_integrity.sql` | 승인 원장 producer precedent |

## §9 실행 명령

DB catalog 조회는 read-only session에서, mutation 검증은 명시적 `BEGIN / ROLLBACK` 안에서 실행했다.

```powershell
git rev-parse HEAD
git status --short --untracked-files=all
Get-FileHash -Algorithm SHA256 sql/migrations/0175_kds_payment_precondition.sql
docker inspect supabase_db_yoonsul_wait_order_handoff
docker exec -e PGOPTIONS="-c default_transaction_read_only=on" -i supabase_db_yoonsul_wait_order_handoff psql -X -v ON_ERROR_STOP=1 -U postgres -d postgres
docker exec -i supabase_db_yoonsul_wait_order_handoff psql -X -v ON_ERROR_STOP=1 -U postgres -d postgres
tools/Check-Governance.ps1 -Top 0
```

주요 catalog 쿼리:

```sql
select filename, checksum, applied_at, applied_by, success
from catchmenu_meta.migration_history
where filename like '0175%';

select n.nspname, p.proname,
       pg_get_function_identity_arguments(p.oid),
       pg_get_function_arguments(p.oid),
       pg_get_function_result(p.oid),
       l.lanname, p.provolatile, p.prosecdef,
       r.rolname, p.proconfig, p.proacl, md5(p.prosrc)
from pg_proc p
join pg_namespace n on n.oid=p.pronamespace
join pg_language l on l.oid=p.prolang
join pg_roles r on r.oid=p.proowner
where (n.nspname,p.proname) in (
  ('catchmenu_kds','commit_kds_ticket'),
  ('catchmenu_kds','bulk_commit_kds_tickets'),
  ('catchmenu_payment','release_kds_after_payment'),
  ('catchmenu_integrations','accept_delivery_order')
)
order by 1,2;

select n.nspname, p.proname, p.prosrc
from pg_proc p
join pg_namespace n on n.oid=p.pronamespace
where n.nspname like 'catchmenu_%'
  and p.prosrc like '%kds_tickets%'
  and p.prosrc like '%COMMITTED%';
```

## §10 판정

```text
Primary exploit closure
  T1  PASS — commit_kds_ticket 결제 없음 DENY
  T3  PASS — p_conditions 결제 주장 DENY
  T4  PASS — p_force_conditions 결제 주장 DENY
  T5  PASS — release_kds_after_payment 가짜 ledger ID DENY
  T6  PASS — accept_delivery_order 결제 없음 DENY

추가 차단
  T2  PASS — bulk_commit_kds_tickets 결제 없음 DENY
  T8  PASS — 타 tenant claim 42501

정상 경로
  T7  PASS — 정상 APPROVAL 후 commit 성공
  T9  PASS — store 정책 기반 무결제 전용 경로 성공

회귀 delta                  전건 일치
일반 COMMITTED 미검증 경로  0
결론                        PASS
```
