# 602050_Evidence_RuntimeGate_Order_Request_Identity.md

Status: Active
Lifecycle: RuntimeGate
DocumentType: Evidence
Last Updated: 2026-09-11

## §0 성격 · PRE-FLIGHT

`600023` §3 · §3.4 · §3.5, `601919` `H-02`, `601902` `TI-6`을 근거로 `catchmenu_pos.orders` INSERT writer 8개의 request identity와 주문 번호 범위를 측정한다.

이 판본은 §2 공격 재현, §4.1 실측, Human 범위 승인, 최초 초안의 signature 충돌, RG-F11 최종 처분, `0178_order_request_identity_and_numbering.sql` 적용과 검증을 순서대로 기록한다. signature 충돌이 있던 최초 초안은 적용하지 않았고, 최종 13개 public signature 변경과 `run_integration_test` 내부 갱신 판본만 적용했다.

PRE-FLIGHT 실측:

```text
측정 시각                    2026-09-11 KST
DB                           postgres
PostgreSQL                   17.6
container                    supabase_db_yoonsul_wait_order_handoff
container id                 b67400e8c73e4ec7b9a25b172d71af347dd22d5e269d49859629fc3d8bd935ec
image                        public.ecr.aws/supabase/postgres:17.6.1.156
compose project              yoonsul_wait_order_handoff
환경                         local/dev
Git HEAD                     9a077f7f2ff06280ea37e74b44cae7cd8bec6d68
작업 전 working tree         clean
latest successful migration  0177_tenant_lifecycle_order_gate.sql
0177 history checksum        f27ea1c8b5a743009924e32ed2dd72a7b0fdc31f9b3fe581ed510cc7c0e6ae11
0177 file checksum           F27EA1C8B5A743009924E32ED2DD72A7B0FDC31F9B3FE581ED510CC7C0E6AE11
0178 migration history       0건
0178 file                    없음
602050 file                  작업 전 없음
```

실행 명령:

```powershell
git rev-parse HEAD
git status --short
Test-Path sql/migrations/0178_order_request_identity_and_numbering.sql
Test-Path docs/600000_implementation_lifecycle/602000_runtime_gate/602050_Evidence_RuntimeGate_Order_Request_Identity.md
Get-FileHash -Algorithm SHA256 sql/migrations/0177_tenant_lifecycle_order_gate.sql
docker inspect supabase_db_yoonsul_wait_order_handoff --format '{{.Id}}|{{.Config.Image}}|{{index .Config.Labels "com.docker.compose.project"}}'
docker exec -e PGOPTIONS="-c default_transaction_read_only=on" -i supabase_db_yoonsul_wait_order_handoff psql -X -v ON_ERROR_STOP=1 -U postgres -d postgres
```

migration history 확인 쿼리:

```sql
select filename, checksum, applied_at, applied_by, success
from catchmenu_meta.migration_history
order by applied_at desc
limit 3;

select count(*) as migration_0178_count
from catchmenu_meta.migration_history
where filename like '0178%';
```

실측 출력:

```text
                  filename                   |                             checksum                             |          applied_at           | applied_by | success
---------------------------------------------+------------------------------------------------------------------+-------------------------------+------------+---------
 0177_tenant_lifecycle_order_gate.sql        | f27ea1c8b5a743009924e32ed2dd72a7b0fdc31f9b3fe581ed510cc7c0e6ae11 | 2026-09-09 15:08:35.570396+00 | postgres   | t
 0176_payment_approval_binding_all_paths.sql | fc766450f2fdb273d0df97a5e91b389236ee753f4673d644062f8208607ffd80 | 2026-09-08 11:11:58.707146+00 | postgres   | t
 0175_kds_payment_precondition.sql           | f1fbae219d4b35ba7b058636802cf9643b8e3177f873ff6caba0c8746f4af974 | 2026-09-08 10:15:14.656249+00 | postgres   | t

 migration_0178_count
----------------------
                    0
```

PRE-FLIGHT 조건은 일치했다.

## §1 공격

### §1.1 retry 중복

`ACTIVE + NONE` tenant와 store · `ORDERING` session · menu를 한 transaction에 만든다. `authenticated`와 동일 tenant claim으로 같은 session · items · correlation_id를 사용해 `create_order`를 연속 두 번 호출한다. fixture와 결과는 `ROLLBACK`한다.

핵심 실행문:

```sql
begin;

-- tenant · store · order_session · menu fixture INSERT

set local role authenticated;
select set_config(
  'request.jwt.claims',
  '{"sub":"aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa","role":"authenticated","app_metadata":{"tenant_id":"eeeeeeee-5000-4000-8000-000000000001","store_id":"eeeeeeee-5000-4000-8000-000000000002"}}',
  true
);

select catchmenu_pos.create_order(
  'eeeeeeee-5000-4000-8000-000000000001',
  'eeeeeeee-5000-4000-8000-000000000002',
  'eeeeeeee-5000-4000-8000-000000000005',
  'DINE_IN', 'STAFF_POS',
  '[{"menu_id":"eeeeeeee-5000-4000-8000-000000000006","quantity":1,"options_amount":0,"selected_options":[]}]'::jsonb,
  null, null, 'RG05-SAME-CORRELATION'
);

-- 위와 동일한 인자로 한 번 더 호출

reset role;
select id, order_number, session_id, correlation_id
from catchmenu_pos.orders
where tenant_id='eeeeeeee-5000-4000-8000-000000000001'
order by order_number;

rollback;
```

### §1.2 동시 두 연결

동일 store에 서로 다른 `ORDERING` session 2개를 준비한다. 연결 A가 `create_order`로 `0001`을 INSERT한 뒤 6초간 미커밋 상태를 유지한다. 그 사이 연결 B가 현재 함수와 같은 `COUNT(*) + 1` 공식으로 번호를 측정하고 다른 session에서 `create_order`를 호출한다. 두 연결 모두 최종 `ROLLBACK`한다.

동시 실행은 Python `subprocess.Popen`으로 독립 `docker exec ... psql` 두 개를 시작했다. A를 먼저 시작하고 1.5초 뒤 B를 시작했다.

```text
connection A
  BEGIN
  authenticated + tenant claim
  create_order(session A)
  pg_sleep(6)
  ROLLBACK

connection B
  BEGIN
  SELECT lpad((count(*)+1)::text,4,'0')
  authenticated + tenant claim
  create_order(session B)
  ROLLBACK
```

첫 진단 시 B의 보조 SELECT를 `authenticated` 구간에서 실행해 `permission denied for table orders`로 함수 호출 전에 중단됐다. 연결 종료로 rollback된 것을 확인하고, 보조 SELECT만 postgres 구간으로 옮겨 같은 두 연결 실험을 다시 실행했다. 업무 RPC는 두 번 모두 `authenticated`로 호출했다.

### §1.3 다음 business day 충돌

동일 store에 전일 `business_day`, `order_number='0001'`인 기존 주문을 넣고 현재 business day의 첫 `create_order`를 호출한다. 현재 함수는 현재 business day 행만 세어 다시 `0001`을 계산하지만 live UNIQUE는 날짜 없는 `(store_id, order_number)`다. 전체 fixture와 결과는 `ROLLBACK`한다.

```sql
insert into catchmenu_pos.orders (
  tenant_id, store_id, order_number,
  order_type, order_status,
  total_amount, discount_amount, final_amount,
  order_channel, guest_locale,
  ordered_at, business_day, business_timezone, correlation_id
) values (
  'eeeeeeee-5300-4000-8000-000000000001',
  'eeeeeeee-5300-4000-8000-000000000002',
  '0001', 'DINE_IN', 'PENDING',
  0, 0, 0, 'STAFF_POS', 'ko',
  now() - interval '1 day',
  (timezone('Asia/Seoul',now()))::date - 1,
  'Asia/Seoul', 'RG05-PREVIOUS-DAY'
);

-- authenticated + 동일 tenant claim 설정 후 현재 business day의 create_order 호출
```

## §2 재현 로그

### §2.1 retry 중복

```text
=== RG05 retry reproduction precheck ===
 residual_tenants
------------------
                0

BEGIN
INSERT 0 1
INSERT 0 1
INSERT 0 1
INSERT 0 1
SET

=== first create_order ===
{"success": true, "order_id": "571d9cb9-5ad3-443e-a940-f30f55cec4f9", "item_count": 1, "final_amount": 1000, "order_number": "0001", "order_status": "PENDING", "total_amount": 1000, "kitchen_zone_summary": {"MAIN": 1}}

=== second create_order same session/items/correlation ===
{"success": true, "order_id": "3b355645-293e-4cbf-8789-d17f19c4f008", "item_count": 1, "final_amount": 1000, "order_number": "0002", "order_status": "PENDING", "total_amount": 1000, "kitchen_zone_summary": {"MAIN": 1}}

=== rows inside transaction ===
                  id                  | order_number |              session_id              |    correlation_id
--------------------------------------+--------------+--------------------------------------+-----------------------
 571d9cb9-5ad3-443e-a940-f30f55cec4f9 | 0001         | eeeeeeee-5000-4000-8000-000000000005 | RG05-SAME-CORRELATION
 3b355645-293e-4cbf-8789-d17f19c4f008 | 0002         | eeeeeeee-5000-4000-8000-000000000005 | RG05-SAME-CORRELATION

 order_count | distinct_order_ids | order_numbers
-------------+--------------------+---------------
           2 |                  2 | {0001,0002}

 session_last_order_id
--------------------------------------
 3b355645-293e-4cbf-8789-d17f19c4f008

ROLLBACK
=== after rollback ===
 residual_tenants
------------------
                0
```

동일 session · items · correlation_id 재호출이 새 주문을 만들었다. `session.order_id`는 두 번째 주문으로 바뀌었다. `601919` `H-02`와 같은 공격이 재현됐다.

### §2.2 동시 두 연결

```text
SESSION_A_EXIT=0
=== SESSION A BEGIN ===
BEGIN
SET
session_a_result
{"success": true, "order_id": "bfbaca6b-6d40-4165-a545-e2f4625a231a", "item_count": 1, "final_amount": 1000, "order_number": "0001", "order_status": "PENDING", "total_amount": 1000, "kitchen_zone_summary": {"MAIN": 1}}

=== SESSION A HOLDS UNCOMMITTED 0001 ===
pg_sleep

ROLLBACK
=== SESSION A ROLLBACK ===

SESSION_B_EXIT=0
=== SESSION B BEGIN ===
BEGIN
=== SESSION B NUMBER FROM CURRENT FORMULA WHILE A IS UNCOMMITTED ===
 session_b_precomputed_number
------------------------------
 0001

SET
session_b_result
{"success": true, "order_id": "b66d8c16-05f0-40b2-b1d3-6497b12ef479", "item_count": 1, "final_amount": 1000, "order_number": "0001", "order_status": "PENDING", "total_amount": 1000, "kitchen_zone_summary": {"MAIN": 1}}

ROLLBACK
=== SESSION B ROLLBACK ===
```

A의 미커밋 `0001`은 B의 snapshot에 보이지 않았다. A와 B가 각각 같은 번호 `0001`을 계산했다. 두 연결 결과를 rollback한 뒤 `orders` 잔존은 0건이었다.

### §2.3 다음 business day `0001` 충돌

```text
=== days before call ===
 order_number | business_day | current_business_day
--------------+--------------+----------------------
 0001         | 2026-09-10   | 2026-09-11

=== create_order on next business day ===
{"success": false, "error_key": "duplicate key value violates unique constraint \"uq_orders_store_number\"", "error_detail": ""}

=== rows after attempted reset to 0001 ===
                  id                  | order_number | business_day |  correlation_id
--------------------------------------+--------------+--------------+-------------------
 09c542d3-0fea-44f7-8a8e-7b126226688c | 0001         | 2026-09-10   | RG05-PREVIOUS-DAY

ROLLBACK
=== after rollback ===
 residual_tenants
------------------
                0
```

현재 함수는 날짜별 count를 사용하지만 UNIQUE는 날짜를 포함하지 않아 다음 business day의 `0001` 재시작이 실패했다.

세 재현 종료 후 확인:

```text
 residual_tenants
------------------
                0

 residual_orders
-----------------
               0
```

## §3 invariant

⚠️ Human이 확정했다. 그대로 인용한다.

```text
H-02-1  request identity

  주문 writer 는 caller 로부터 stable request_id 를 입력받는다
  signature 변경을 허용한다

  server 가 canonical idempotency key 를 파생한다

    tenant_id + store_id + session_id + operation + request_id

  payload_hash 는 key 성분이 아니다
  최초 요청 payload 대응 검증용으로 별도 보존한다

H-02-2  retry 판정

  같은 request_id            동일 action 의 retry
  다른 request_id            새로운 order action

  session 또는 items 동일성으로 retry 여부를 판단하지 않는다

  같은 request_id + 같은 payload    최초 생성 order 반환
  같은 request_id + 다른 payload    거부 — INVALID IDEMPOTENT REPLAY
  다른 request_id + 같은 payload    새 주문

H-02-3  order_number scope

  store × business_day
  UNIQUE (store_id, business_day, order_number)

  created_at calendar date 를 order number scope 기준으로 쓰지 않는다

H-02-4  번호 배정

  COUNT(*) + 1 금지
  transaction-safe atomic allocator 로 생성한다
  concurrent order creation 에서 동일 번호가 계산되는 경로를 허용하지 않는다
```

`601902` `TI-6`을 주문에 적용한다. `payload_hash`는 canonical key 성분에 넣지 않는다. 같은 request identity에서 payload만 바뀌면 같은 key의 보존 hash와 비교해 `010660` §6 `IDEMPOTENCY_PAYLOAD_CONFLICT`로 실행을 거부할 수 있어야 한다.

## §4 근거

| 구분 | 근거 | 적용 |
|---|---|---|
| Doctrine | `010660` §6 `IDEMPOTENCY_PAYLOAD_CONFLICT` | Same key with different payload must not execute |
| Human invariant | `601902` `TI-6` · `602050` §3 | stable action identity · server canonical key · payload hash 별도 보존 |
| Runtime evidence | `601919` `H-02` | retry 중복 · 번호 범위 불일치 |
| Precedent only | `0174` · `0176` | unique identity · binding · 최초 결과 반환의 선행 사례 |

## §4.1 실측

### §4.1.1 business day assignment

`catchmenu_pos.orders.business_day`는 `date NOT NULL`이며 default가 없다. `business_timezone` default는 `Asia/Seoul`이다. `orders`의 유일한 비내부 trigger는 `updated_at` 갱신용 `trg_orders_updated_at`이며 business day를 채우는 trigger는 없다. business day 전용 helper도 8개 writer에서 호출되지 않는다.

| writer | business day 입력 | timezone | 경계 |
|---|---|---|---|
| `create_order` | `timezone(v_timezone, now())::date` | store의 `timezone` 직접 조회 | store local 자정 |
| `create_pre_order` | `timezone(coalesce(v_timezone,'Asia/Seoul'),now())::date` | store timezone | store local 자정 |
| `pre_order_while_waiting` | 동일 | store timezone | store local 자정 |
| `place_kiosk_order` | 동일 | store timezone | store local 자정 |
| `place_takeout_order` | 동일 | store timezone | store local 자정 |
| `intake_delivery_order` | 동일 | store timezone | store local 자정 |
| `run_integration_test(uuid,uuid,text)` | `timezone('Asia/Seoul',now())::date` | `Asia/Seoul` 고정 | 서울 자정 |
| `flush_offline_queue` | `action_payload->>'business_day'`을 그대로 cast | 저장값은 `Asia/Seoul` 고정 | caller payload가 결정 |

영업 종료 시각이나 자정 외 cutoff를 구현한 규칙은 발견되지 않았다. 6개 업무 writer는 store timezone의 calendar date를 쓰지만 `run_integration_test`는 서울 고정이고 `flush_offline_queue`는 caller payload를 신뢰한다. 기존 규칙이 8개에 통일되어 있지 않다. 이 문서는 새 영업일 규칙을 정하지 않는다.

### §4.1.2 order number 생성 코드 전수

| writer | 현재 번호 생성 |
|---|---|
| `create_order` | 같은 store · business day의 `COUNT(*) + 1`, 4자리 `0001` |
| `create_pre_order` | 같은 store · business day의 `COUNT(*) + 1`, `P-0001` |
| `pre_order_while_waiting` | session의 `wait_number`, `W001` |
| `place_kiosk_order` | 같은 tenant · store · business day · `order_source='KIOSK'`의 `COUNT(*) + 1`, `K001` |
| `place_takeout_order` | 같은 store · business day의 기존 번호 숫자 suffix `MAX(...) + 1`, `TMMDD001` |
| `intake_delivery_order` | 같은 store · business day의 `COUNT(*) + 1`, `D-0001` |
| `flush_offline_queue` | caller `action_payload->>'order_number'` 그대로 사용 |
| `run_integration_test(uuid,uuid,text)` | `TEST-` + `extract(epoch from now())::int` |

`COUNT(*)` 계열 4건(`create_order`, `create_pre_order`, `place_kiosk_order`, `intake_delivery_order`), `MAX` 1건, session wait number 1건, caller 값 1건, 초 단위 timestamp 1건이다. 8개가 하나의 atomic allocator를 공유하지 않는다.

live `orders`에는 `order_channel`은 있으나 `order_source`와 `local_temp_id`는 없다. 그럼에도 아래 네 함수 body는 없는 열을 사용한다.

```text
pre_order_while_waiting  orders.order_source INSERT
place_kiosk_order       orders.order_source 조회 · INSERT
flush_offline_queue     orders.order_source · local_temp_id INSERT
run_integration_test    orders.order_source INSERT
```

이는 정상 INSERT 경로가 해당 지점에 도달하면 실패하는 live schema drift다. `0178` 범위에서 함께 교정할지는 Human 처분이 필요하다.

### §4.1.3 atomic allocator 제안

세 후보를 대조했다.

| 후보 | 실측 범위 적합성 |
|---|---|
| global sequence | store × business_day별 재시작 범위를 직접 표현하지 못한다 |
| advisory transaction lock | 호출을 직렬화할 수 있으나 번호 상태가 남지 않고 orders scan과 lock-key mapping에 계속 의존한다 |
| counter table | `(store_id,business_day)`를 물리 key로 보존하고 atomic upsert 한 번으로 번호를 배정할 수 있다 |

제안은 counter table이다.

```text
catchmenu_pos.order_number_allocators

tenant_id     uuid       NOT NULL
store_id      uuid       NOT NULL
business_day  date       NOT NULL
last_value    bigint     NOT NULL CHECK (last_value > 0)
created_at    timestamptz NOT NULL DEFAULT now()
updated_at    timestamptz NOT NULL DEFAULT now()

PRIMARY KEY (store_id, business_day)
```

배정은 다음 형태의 단일 statement를 사용한다.

```sql
insert into catchmenu_pos.order_number_allocators (
  tenant_id, store_id, business_day, last_value
) values (
  p_tenant_id, p_store_id, v_business_day, 1
)
on conflict (store_id, business_day)
do update set
  last_value = catchmenu_pos.order_number_allocators.last_value + 1,
  updated_at = now()
returning last_value;
```

counter table은 allocator state를 orders 삭제와 분리해 보존하고 PostgreSQL row locking으로 동시 증가를 직렬화한다. 기존 prefix 표현을 유지할 경우에도 8개 writer가 같은 store/day counter에서 받은 하나의 ordinal만 사용하도록 한다. UNIQUE는 Human invariant 그대로 `(store_id, business_day, order_number)`로 바꾼다.

### §4.1.4 request_id 파라미터 추가 영향

현재 writer signature:

| writer | 현재 identity arguments |
|---|---|
| `create_order` | `(uuid,uuid,uuid,text,text,jsonb,text,text,text)` |
| `create_pre_order` | `(uuid,uuid,uuid,jsonb,text,text)` |
| `pre_order_while_waiting` | `(uuid,uuid,uuid,jsonb,text,text)` |
| `place_kiosk_order` | `(uuid,uuid,uuid,uuid,jsonb,text,text,text,text)` |
| `place_takeout_order` | `(uuid,uuid,jsonb,uuid,text,text,text,uuid,integer,timestamptz,text)` |
| `intake_delivery_order` | `(uuid,uuid,text,text,jsonb,uuid,text)` |
| `flush_offline_queue` | `(uuid,uuid,uuid,integer,text)` |
| `run_integration_test` writer overload | `(uuid,uuid,text)` |

필수 `p_request_id text`는 각 함수의 첫 default parameter보다 앞에 추가하는 안을 제안한다. 공백 문자열도 없음과 같이 거부한다. 기존 인자 뒤에 default 없는 값을 놓을 수 없으므로 현재 default parameter 뒤에 단순 추가하는 방식은 쓸 수 없다.

DB 내부 실호출자는 다음 6개다.

```text
submit_kiosk_order       → create_order                    1건
process_baemin_order     → intake_delivery_order          1건
process_coupang_order    → intake_delivery_order          1건
process_okpos_order      → intake_delivery_order          1건
process_toss_pos_order   → intake_delivery_order          1건
process_yogiyo_order     → intake_delivery_order          1건
```

`submit_kiosk_order`는 현재 `p_correlation_id`만 전달하고 request_id가 없다. provider 처리 함수 5개에는 provider order id가 있으나 `intake_delivery_order`에 별도 request_id로 전달하지 않는다. 이 6개 호출자도 새 필수 인자를 전달하도록 함께 바뀌어야 한다. catalog의 guide/summary 문자열 3건은 실제 호출이 아니다.

애플리케이션 소스에서 8개 RPC의 runtime 호출자는 발견되지 않았다. `catchmenu_app/lib/core/constants/app_constants.dart`의 `schemaCommon` 주석에 `run_integration_test` 이름만 있다. SQL 검증·scratch·과거 migration의 호출은 runtime 애플리케이션 호출자로 세지 않았다.

session identity mapping 제안:

```text
create_order · create_pre_order · pre_order_while_waiting
  현재 p_session_id

place_kiosk_order
  현재 p_kiosk_session_id

place_takeout_order · intake_delivery_order · flush_offline_queue
  canonical tuple에 명시적 NULL sentinel
  최초 성공 result에 생성된 order session을 보존

run_integration_test
  명시적 NULL sentinel
```

session을 내부 생성하는 writer는 request마다 새 session UUID를 canonical key 입력으로 쓰면 retry마다 key가 바뀐다. 따라서 최초 claim 전에 알 수 없는 생성 UUID는 key 성분으로 쓰지 않고 명시적 NULL sentinel을 사용한다는 제안이다. Human이 다른 stable session identity를 정하면 그 값을 사용한다.

`run_integration_test`가 매 호출마다 request_id를 자체 생성하는 안은 제안하지 않는다. 그렇게 하면 같은 외부 요청을 retry해도 항상 다른 action이 된다. 이 writer도 caller의 필수 `p_request_id`를 받고 내부 test order용 identity는 그 값에서 server가 파생한다.

### §4.1.5 idempotency 저장 위치

live catalog:

```text
orders.idempotency_key     text NULL
orders payload_hash        없음
orders idempotency UNIQUE  없음
orders row                 0건
```

지시서의 “8개 중 `intake_delivery_order` 하나만 `orders.idempotency_key`를 채운다”는 live INSERT 열과 일치하지 않는다.

```text
orders.idempotency_key를 INSERT하는 writer  0 / 8
```

`intake_delivery_order`는 `orders.idempotency_key`를 채우지 않는다. 대신 별도 `catchmenu_common.idempotency_keys`를 사용한다. 그 테이블에는 이미 다음 요소가 있다.

```text
tenant_id · store_id · idempotency_key · key_domain · key_scope
operation_type · request_hash · processing_status
result_payload · error_payload · replay_count · expires_at

UNIQUE (tenant_id, key_domain, idempotency_key)
```

제안:

1. authoritative request record는 기존 `catchmenu_common.idempotency_keys`를 재사용한다.
2. server가 `tenant_id + store_id + session identity + operation + request_id`의 canonical serialization에서 key를 파생한다.
3. 최초 payload의 hash는 key 성분이 아니라 기존 `request_hash`에 저장한다.
4. 완료 결과는 `result_payload`에 저장하고 retry에서 그대로 반환한다.
5. 생성된 order에는 같은 canonical key를 `orders.idempotency_key`에 기록해 request record와 결과를 연결한다.
6. `orders.idempotency_key`에는 `(tenant_id,idempotency_key)` partial UNIQUE 또는 NOT NULL 전환을 적용할 수 있다. live orders가 0건이므로 현재 backfill 대상은 없다.

기존 table을 재사용하면 payload hash와 최초 결과를 저장할 새 orders column은 필요하지 않다. 동시 claim은 `uq_idempotency_key (tenant_id,key_domain,idempotency_key)`를 사용하고, unique 충돌 후 기존 row를 읽어 같은 hash면 완료 결과 또는 in-progress 처분으로 분기한다.

### §4.1.6 기존 행 위반 여부

실행 쿼리:

```sql
select count(*) as duplicate_groups,
       coalesce(sum(n-1),0) as duplicate_extra_rows
from (
  select store_id, business_day, order_number, count(*) n
  from catchmenu_pos.orders
  group by store_id, business_day, order_number
  having count(*) > 1
) d;

select count(*) as orders_total,
       count(idempotency_key) as idempotency_key_nonnull,
       count(*) filter (where idempotency_key is null) as idempotency_key_null
from catchmenu_pos.orders;
```

실측 출력:

```text
 duplicate_groups | duplicate_extra_rows
------------------+----------------------
                0 |                    0

 orders_total | idempotency_key_nonnull | idempotency_key_null
--------------+-------------------------+----------------------
            0 |                       0 |                    0
```

`UNIQUE (store_id,business_day,order_number)` 위반 기존 행은 0건이다. live `orders` 자체가 0건이므로 idempotency backfill 대상도 0건이다.

### §4.1.7 1차 Human 확인 요청

§5 착수 전 다음 처분이 필요하다.

1. 6개 writer의 기존 store-timezone calendar date를 공통 business day assignment로 사용할지, `run_integration_test`와 `flush_offline_queue`의 예외를 어떻게 처리할지.
2. `order_number_allocators` counter table 제안과 컬럼 · PK를 승인할지.
3. 필수 `p_request_id text` 위치와 DB 내부 호출자 6개를 `0178` 범위에서 함께 변경할지.
4. 내부 session 생성 writer의 canonical session 성분에 NULL sentinel을 사용할지.
5. 기존 `catchmenu_common.idempotency_keys.request_hash/result_payload` 재사용과 `orders.idempotency_key` linkage를 승인할지.
6. 없는 `order_source` · `local_temp_id`를 참조하는 writer 4개의 live schema drift를 `0178`에서 함께 교정할지 별도 gate로 분리할지.

### §4.1.8 1차 Human 처분

2026-09-11 Human이 다음과 같이 처분했다.

1. business day assignment는 실측 그대로 둔다. 공통 helper나 영업 종료 cutoff 규칙을 만들지 않는다.
2. 현재 다섯 번호 생성 방식은 allocator 하나로 통일한다.
3. `order_number_allocators`, `PRIMARY KEY (store_id,business_day)`, 같은 migration에서 8 writer를 생산자로 만드는 안을 승인했다.
4. 8 writer 전부의 필수 `p_request_id`를 승인했다. `run_integration_test`를 포함한다.
5. authoritative 저장소는 `catchmenu_common.idempotency_keys`, payload hash는 `request_hash`, 최초 결과는 `result_payload`, 주문 linkage는 `orders.idempotency_key`로 확정했다.
6. `intake_delivery_order`가 `orders.idempotency_key`를 채운다는 사전 전제를 철회하고 live 실측 0/8을 채택했다.
7. 기존 행 위반 0건을 확인했다.
8. DB 내부 직접 호출자 6개도 `p_request_id`를 caller로부터 받아 writer에 전달해야 한다. 자체 생성은 금지한다.
9. `order_source` · `local_temp_id`를 참조하는 4 writer의 schema drift는 `0178`에서 고치지 않는다.

finding 처분:

```text
RG-F9
  flush_offline_queue가 caller 제공 business_day를 사용한다.
  caller가 주문 번호 범위를 고를 수 있다.
  offline 복구 경로의 영업일 결정은 별도 gate 대상이다.

RG-F10
  4 writer가 live orders에 없는 order_source 또는 local_temp_id를 참조한다.
  대상: pre_order_while_waiting · place_kiosk_order · flush_offline_queue · run_integration_test
  이 gate는 고치지 않는다. 별도 확인 대상이다.
```

### §4.1.9 DB 내부 호출 연쇄 실측

1차 직접 호출자 6개를 seed로 다시 역방향 전수 검색했다.

```text
level 0 — orders writer
  create_order
  intake_delivery_order

level 1 — 직접 wrapper
  submit_kiosk_order       → create_order
  process_baemin_order     → intake_delivery_order
  process_coupang_order    → intake_delivery_order
  process_okpos_order      → intake_delivery_order
  process_toss_pos_order   → intake_delivery_order
  process_yogiyo_order     → intake_delivery_order

level 2 — 위 6개 wrapper의 DB 내부 호출자
  0건
```

실행 쿼리:

```sql
with names(name) as (
  values
    ('submit_kiosk_order'),
    ('process_baemin_order'),
    ('process_coupang_order'),
    ('process_okpos_order'),
    ('process_toss_pos_order'),
    ('process_yogiyo_order')
)
select names.name as callee,
       p.oid::regprocedure::text as caller
from names
join pg_proc p
  on position(names.name || '(' in lower(p.prosrc)) > 0
order by names.name, caller;
```

실측 출력:

```text
 callee | caller
--------+--------
(0 rows)
```

함수 body 전체에서 괄호 없는 문자열·동적 호출 형태까지 이름 자체를 추가 검색했으나 참조는 0건이었다. 여섯 함수에 대한 non-internal trigger, rewrite, relation dependency도 각각 0건이다. 저장소에서 docs · migrations · replay 제외 후 여섯 함수 이름을 검색한 애플리케이션 호출자도 0건이다.

여섯 wrapper의 실행 경계:

| 함수 | SECURITY DEFINER | 함수 ACL | schema USAGE |
|---|---:|---|---|
| `submit_kiosk_order` | true | authenticated EXECUTE | authenticated true · anon false |
| `process_baemin_order` | true | authenticated EXECUTE | authenticated true · anon false |
| `process_coupang_order` | true | authenticated EXECUTE | authenticated true · anon false |
| `process_okpos_order` | true | authenticated EXECUTE | authenticated true · anon false |
| `process_toss_pos_order` | true | authenticated EXECUTE | authenticated true · anon false |
| `process_yogiyo_order` | true | authenticated EXECUTE | authenticated true · anon false |

상위 DB/app 호출자는 없지만 여섯 함수가 authenticated RPC surface이므로 request identity의 외부 입력 경계가 여기서 끝난다. 이 함수들이 request ID를 생성하면 Human 처분과 `H-02-2`를 위반한다.

제안하는 `0178` signature 전파 범위:

```text
orders writer                         8개
직접 wrapper                          6개
합계                                 14개 함수

submit_kiosk_order
  필수 p_request_id를 받고 create_order에 그대로 전달

provider process 함수 5개
  각각 필수 p_request_id를 받고 intake_delivery_order에 그대로 전달

더 깊은 DB/app caller signature 전파  0개
```

현재 여섯 wrapper에는 optional `p_correlation_id`가 있으나 stable request identity 전용 parameter는 없다. `p_correlation_id`를 request ID로 간주하지 않고 별도 필수 `p_request_id text`를 첫 default parameter 앞에 추가한다는 제안이다.

### §4.1.10 2차 Human 처분

2026-09-11 Human은 writer 8개와 직접 wrapper 6개, 총 14개 함수의 signature를 함께 변경하고 wrapper가 caller의 필수 `p_request_id`를 그대로 전달하는 범위를 승인했다. 추가 상위 전파는 0개로 확정했다.

### §4.1.11 적용 전 signature 충돌 실측

승인 사양대로 `catchmenu_common.run_integration_test(uuid,uuid,text)`의 첫 default parameter `p_scenario text DEFAULT 'ALL'` 앞에 필수 `p_request_id text`를 추가하면 새 identity argument type은 `(uuid,uuid,text,text)`가 된다. 라이브 DB에는 같은 이름과 identity argument type의 별도 non-writer overload가 이미 있다.

```text
writer 기존       catchmenu_common.run_integration_test(uuid,uuid,text)
writer 변경안     catchmenu_common.run_integration_test(uuid,uuid,text,text)
기존 non-writer   catchmenu_common.run_integration_test(uuid,uuid,text,text)
결과              동일 signature 충돌
```

두 객체의 실측:

```text
signature                                                  arguments
---------------------------------------------------------  ------------------------------------------------------------------------------
run_integration_test(uuid,uuid,text)                       p_tenant_id, p_store_id, p_scenario DEFAULT 'ALL'
run_integration_test(uuid,uuid,text,text)                  p_tenant_id, p_store_id, p_test_suite, p_locale DEFAULT 'ko'

writer body md5       406212c7652e53ce9ccc9932a0a26c51
non-writer body md5   41867161724cce24a273eaf437e613d7
```

기존 4-argument overload는 `orders` INSERT writer가 아니며 `602040` §0 · §4.1에서도 8개 writer 범위에서 제외됐다. 두 overload 이름을 본문에서 참조하는 다른 DB 함수 검색 결과는 설명 문자열을 가진 `get_project_completion_summary()` 1개였고 실제 호출은 0개다. 저장소에는 과거 migration과 문서의 호출 예시가 있어 외부 실행 계약 부재는 증명되지 않는다.

적용 전 transaction rollback 컴파일 출력:

```text
BEGIN
CREATE TABLE
ALTER TABLE
ALTER TABLE
CREATE FUNCTION ... 7개 writer 정의 성공
ERROR: cannot change name of input parameter "p_test_suite"
HINT: Use DROP FUNCTION catchmenu_common.run_integration_test(uuid,uuid,text,text) first.
```

`ON_ERROR_STOP=1`과 외부 `ROLLBACK` 판본으로 실행했으므로 table · constraint · function · migration history 변경은 0건이다. 충돌을 해소하려면 기존 non-writer overload의 이름 또는 signature를 변경하거나, 승인된 writer의 `p_request_id text` signature 규칙을 변경해야 한다. 어느 쪽도 승인된 14개 범위 안의 기계적 적용으로 결정할 수 없다.

충돌한 writer 1개만 rollback 입력에서 제외한 13개 함수 컴파일 점검은 table · constraint 변경, 함수 정의 · ACL 복원, 구 signature 제거까지 오류 없이 진행된 뒤 `ROLLBACK`됐다. 따라서 현재 확인된 적용 차단점은 위 signature 충돌 1건이다.

### §4.1.12 signature 충돌 Human 처분

2026-09-11 Human은 기존 non-writer overload 이름 변경과 `p_request_id` 타입 변경을 모두 금지했다. `run_integration_test(uuid,uuid,text)`는 public signature 변경에서 제외하고, `0178` 범위를 public signature 변경 13개(writer 7 · wrapper 6)와 내부 호출 갱신 1개(`run_integration_test`)로 확정했다.

### §4.1.13 `run_integration_test` 내부 writer 호출 실측

여덟 writer 이름의 직접 호출 token을 `run_integration_test(uuid,uuid,text)` body 전체에서 대조한 결과는 전부 0건이다.

```text
create_order(                 0
create_pre_order(             0
pre_order_while_waiting(      0
place_kiosk_order(            0
place_takeout_order(          0
intake_delivery_order(        0
flush_offline_queue(          0
run_integration_test(         0
```

이 함수는 production writer를 호출하지 않고 `PATENT2` 테스트 case에서 `catchmenu_pos.orders`에 직접 INSERT한다.

```text
조건                 p_scenario IN ('ALL','PATENT2') · active KDS menu 존재
session              test session 직접 INSERT
order                catchmenu_pos.orders 직접 INSERT
order number         'TEST-' || extract(epoch from now())::int
business_day         v_business_day
idempotency_key      미기록
allocator            미사용
검증                 KDS HOLD 확인
정리                 KDS ticket → order → session 순서로 DELETE
```

따라서 production writer에 전달할 호출부는 없다. 이 직접 INSERT는 allocator의 동일 `(store_id,business_day)` atomic upsert를 생산자로 사용하고, 새 `(store_id,business_day,order_number)` UNIQUE를 통과하도록 갱신해야 한다.

request identity 처리 제안:

```text
public p_request_id              추가하지 않음
내부 deterministic request_id   integration-test:PATENT2
canonical key                   tenant_id + store_id + NULL session
                                + catchmenu_common.run_integration_test:PATENT2
                                + deterministic request_id
동시 실행                       canonical key advisory transaction lock
orders linkage                  orders.idempotency_key = canonical key hash
authoritative row               test 실행 중 idempotency_keys에 기록
test cleanup                    ephemeral order와 함께 test key도 삭제
```

제안은 동일 tenant/store의 같은 test case 동시 실행을 직렬화하고 direct INSERT에도 deterministic identity linkage를 둔다. 이 utility는 성공 경로에서 order 자체를 삭제하고 같은 test case의 재실행이 실제 INSERT를 다시 검증해야 하므로, 최초 결과를 영구 replay하지 않고 test 전용 idempotency row도 정리한다. production writer의 최초 결과 보존 규칙은 변경하지 않는다. 이 test-only key lifecycle을 적용할지는 Human 확인 대상이다.

### §4.1.14 RG-F11 최종 Human 처분

2026-09-11 Human은 §4.1.13 제안 중 deterministic fixed ID와 test registry row를 채택하지 않았다. 최종 처분은 다음과 같다.

```text
public signature            기존 (uuid,uuid,text) 유지
run_uuid                    함수 실행마다 1회 생성
request_id                  integration-test:PATENT2:<run_uuid>
identity 성질               per-run unique · 같은 action 안에서 stable
canonical identity          tenant + store + NULL session + operation + request_id
orders.idempotency_key      canonical hash 기록
idempotency_keys            INSERT 0건 · cleanup 0건
order number                production allocator 사용
PATENT2 lock                tenant/store/test-case advisory transaction lock 허용
ephemeral cleanup           KDS ticket · order · session 기존 순서 유지
```

`0178`은 이 처분을 그대로 사용한다. PATENT2 lock은 test isolation만 위한 것이며 allocator concurrency evidence로 쓰지 않는다.

## §5 migration

최종 `0178_order_request_identity_and_numbering.sql` 구성:

```text
CREATE OR REPLACE FUNCTION                    14
구 signature DROP FUNCTION                   13
order_number_allocators producer              8
idempotency_keys 성공 결과 writer              7
wrapper p_request_id pass-through              6
assert_caller_tenant_scope 유지                8
tenant_order_creation_blocked gate 유지         8
run_integration_test public signature 변경      0
run_integration_test registry INSERT            0
```

DDL:

```text
CREATE TABLE catchmenu_pos.order_number_allocators
  PK (store_id,business_day)
  tenant/store FK · last_value > 0

DROP CONSTRAINT uq_orders_store_number
ADD CONSTRAINT uq_orders_store_business_day_number
  UNIQUE (store_id,business_day,order_number)
```

기존 `uq_orders_store_number`는 table UNIQUE constraint의 backing index였다. `DROP CONSTRAINT`가 그 index를 함께 제거했고 동일 이름의 잔존 index는 0건이다.

production writer 7개는 공백 request ID를 `order_request_id_required`로 거부한다. server canonical JSON의 SHA-256을 `idempotency_key`로 사용하고, payload의 별도 SHA-256을 `request_hash`에 보존한다. 같은 canonical key의 동시 실행은 `pg_advisory_xact_lock(hashtextextended(key,0))`으로 직렬화한다. 최초 성공 때만 `idempotency_keys`에 `COMPLETED` result를 기록하므로 validation error가 `PROCESSING` row로 남지 않는다.

적용 전 전체 rollback compile은 table · constraint · 함수 14개 · ACL · 구 signature 13개까지 전건 성공했다.

적용 로그:

```text
BEGIN
CREATE TABLE
ALTER TABLE
ALTER TABLE
CREATE FUNCTION 14
DROP FUNCTION 13
COMMIT
```

```text
적용 시각 KST       2026-09-11 14:32:58
history status      success
final SHA-256       AEB82B5550B7D88C4D4A01195D2D2FE192DF8C8B0044FFB95335478A173C609D
```

T8에서 `flush_offline_queue`에 없는 `p_correlation_id`를 completion row에 쓴 `0178` 추가 코드가 확인됐다. 같은 `0178` 실행 중 그 값만 `NULL`로 교정하고 해당 함수 정의를 final file과 동일하게 다시 적용했다. 추가 migration은 만들지 않았고 history checksum을 final file checksum으로 동기화했다.

## §6 검증

### §6.1 T1 · T2 · T3 · T7

```text
T1 first
{"success":true,"order_id":"0c253172-e577-4ef7-9556-565088f40189","order_number":"0001","total_amount":1000}

T1 same request_id + same payload replay
{"success":true,"order_id":"0c253172-e577-4ef7-9556-565088f40189","order_number":"0001","total_amount":1000}

orders             1
distinct order id  1
numbers            {0001}

T2 same request_id + different payload
{"success":false,"error_key":"IDEMPOTENCY_PAYLOAD_CONFLICT"}

T3 different request_id + same payload
{"success":true,"order_id":"911d1ba8-2c68-4e10-b04b-2dbc8a1f1789","order_number":"0002","total_amount":1000}

T7 NULL request_id
{"success":false,"error_key":"order_request_id_required"}
```

T1 · T2 · T3 · T7은 조건대로 통과했다.

### §6.2 T4 — 같은 request ID 동시 두 연결

연결 A가 함수 성공 뒤 transaction을 4초 유지했다. 0.75초 뒤 시작한 B는 동일 canonical advisory lock에서 기다린 뒤 A의 최초 결과를 읽었다.

```text
T4_A_EXIT=0  elapsed=4.558s
A  order_id=647efa8c-433d-4207-a891-5d77a6383df8  order_number=0001

T4_B_EXIT=0  elapsed=3.774s
B  order_id=647efa8c-433d-4207-a891-5d77a6383df8  order_number=0001

orders             1
distinct order id  1
```

T4는 조건대로 통과했다.

### §6.3 T5 — 다른 request ID 동시 두 연결

서로 다른 session과 request ID를 사용했다. A가 allocator row를 갱신한 채 4초 동안 commit하지 않았고 B가 그 row에서 실제로 기다렸다.

```text
T5_A_EXIT=0  elapsed=4.558s
A  order_id=814c273a-4a50-4c8c-82b9-1315b684f947  order_number=0002

T5_B_EXIT=0  elapsed=3.774s
B  order_id=295d137f-1f8a-4899-aaf6-be594b1ce8bb  order_number=0003

orders                    3  (T4의 0001 포함)
distinct order numbers    3
allocator last_value      3
```

PATENT2 test lock을 사용하지 않은 두 production 호출의 실제 allocator 경합이다. T5는 조건대로 통과했다.

### §6.4 T6 — business day 경계

```text
order_number  business_day  correlation_id
0001          2026-09-10    RG05-T6-PREV
0001          2026-09-11    RG05-T6

current-day result
{"success":true,"order_id":"278799fe-dcc2-457c-8f87-36bfd5ecd1f9","order_number":"0001"}
```

날짜별 `0001`이 새 UNIQUE를 함께 통과했다. T6은 조건대로 통과했다.

### §6.5 T8 — 나머지 writer 7개

| writer | first call | replay | order 1건 | 실측 |
|---|---|---|---:|---|
| `create_pre_order` | SUCCESS | 최초 order/result 반환 | 1 | PASS — 두 응답 `order_id=9f3b6460-f72a-4be6-961a-74da6c7699b1`, `P-0001` |
| `pre_order_while_waiting` | ERROR | 미실행 | 0 | `orders.order_source` 없음 |
| `place_kiosk_order` | ERROR | 미실행 | 0 | `store_settings.min_order_amount` 없음 |
| `place_takeout_order` | ERROR | 미실행 | 0 | `order_items.unit_price` 없음 |
| `intake_delivery_order` | ERROR | 미실행 | 0 | function `digest(text,unknown)` 없음 — search_path에 `extensions` 없음 |
| `flush_offline_queue` | outer SUCCESS · item FAILED | 같은 summary 반환 | 0 | `orders.local_temp_id` 없음; queue item 실패 |
| `run_integration_test` | ERROR | 해당 없음 | 0 | temp harness 제공 후 `orders.order_source` 없음 |

`create_pre_order` 1개는 T1 조건을 충족했다. 나머지 6개는 `0178` 이전 body와 live schema의 기존 drift 때문에 최초 order가 생성되지 않아 replay contract를 끝까지 실측할 수 없었다. `0178` 적용 코드는 allocator 8/8 · linkage 8/8 · production registry 7/7로 catalog에서 확인했다.

### §6.6 T9 — wrapper 6개

모든 wrapper의 필수 `p_request_id text`와 하위 writer named pass-through는 catalog에서 6/6 확인했다. runtime first call은 다음 기존 drift에서 중단됐다.

```text
submit_kiosk_order       order_events caused_by_type CHECK 위반
process_baemin_order     function digest(text,unknown) does not exist
process_coupang_order    function digest(text,unknown) does not exist
process_yogiyo_order     function digest(text,unknown) does not exist
process_okpos_order      function digest(text,unknown) does not exist
process_toss_pos_order   function digest(text,unknown) does not exist
```

runtime T1 replay는 0/6 완결됐다. 각 호출은 subtransaction 또는 전체 transaction rollback으로 정리했다.

### §6.7 T10 — 0177 lifecycle gate

```text
ISOLATED create_order
{"success":false,"error_key":"tenant_order_creation_blocked"}
```

T10은 조건대로 통과했다. `assert_caller_tenant_scope`와 lifecycle gate는 request identity 처리보다 앞에 남아 있다.

### §6.8 판정

명시된 FAIL 조건 T1 · T2 · T4 · T7과 T3 · T5 · T6 · T10은 전건 통과했다. Primary exploit closure T1 · T4는 PASS다. T8 · T9 runtime 미완결은 침묵하지 않고 §11 finding으로 분리한다.

## §7 회귀

### §7.1 writer · signature 분류

```text
orders writer             8
public signature 변경     7
내부 호출 갱신            1 — run_integration_test
미적용                    0

직접 wrapper              6
wrapper signature 변경    6
wrapper pass-through      6
```

`run_integration_test(uuid,uuid,text,text)` non-writer overload의 body MD5 `41867161724cce24a273eaf437e613d7`과 signature · ACL은 무변경이다.

### §7.2 allocator · constraint

```text
orders writer                                      8
order_number_allocators 생산자                      8
orders.idempotency_key linkage code                 8
idempotency_keys production result writer           7
run_integration_test idempotency_keys writer         0

order_number_allocators PK       (store_id,business_day)
new UNIQUE                       (store_id,business_day,order_number)
old uq_orders_store_number       0
orders.idempotency_key FK        0
```

T5에서 allocator row lock 경합과 distinct 번호 2건을 확인했다.

### §7.3 함수 속성

14개 변경 대상은 모두 전후 `jsonb`, `plpgsql`, `VOLATILE`, non-strict, `SECURITY DEFINER`, non-leakproof, `PARALLEL UNSAFE`, owner `postgres`를 유지했다. 각 함수의 `search_path`와 PUBLIC/authenticated EXECUTE 의미도 유지했다. PUBLIC EXECUTE writer 3개는 `pre_order_while_waiting`, `place_kiosk_order`, `run_integration_test`로 전후 동일하다.

예상 delta와 실측:

```text
function count            0
SECURITY DEFINER          0
policy · RLS              0
table                    +1  order_number_allocators
UNIQUE constraint         0  old -1 · new +1
```

### §7.4 fixture 정리

모든 순차 실험은 `ROLLBACK`했다. T4 · T5의 committed concurrency fixture는 dependent rows, idempotency rows, allocator, menu, store, tenant 순서로 삭제했고 residual tenant는 0건이다.

### §7.5 최종 판본 · live catalog 동기화

최종 migration에서 section marker와 `AS $function$` body를 직접 추출하고, 같은 schema/function의 live `pg_proc.prosrc` MD5와 대조했다.

```text
migration function body section   14
live prosrc exact MD5 match        14
mismatch                            0

file SHA-256     aeb82b5550b7d88c4d4a01195d2d2fe192df8c8b0044ffb95335478a173c609d
history checksum aeb82b5550b7d88c4d4a01195d2d2fe192df8c8b0044ffb95335478a173c609d
history success  true
allocator rows   0
RG-05 registry rows 0
```

`tools/Check-Governance.ps1 -Top 0`은 예상한 `G11`(`602050` 미색인)과 `G15`(`0178` `CONTRACT_NOT_FOUND`)를 출력했다. Runtime Gate 산출물 색인과 migration contract 연결 전의 예상 상태다.

## §8 근거 문서 목록 (000701 §46)

| 문서 | 절 · finding | 용도 |
|---|---|---|
| `600023_Governance_Runtime_Gate_Spiral.md` | §3 · §3.4 · §3.5 | Runtime Gate 형식 · 기존 invariant 인용 · writer 전수 |
| `601919_Audit_Independent_Foundation_Audit.md` | `H-02` | retry 중복 · concurrency/일자 경계 미실행 기록 |
| `601902_Register_Stage1_Business_Rules.md` | `TI-6` | stable action identity · server canonical key · payload hash 분리 |
| `010660_Policy_Idempotency_Retry_Replay_Reconciliation.md` | §6 | `IDEMPOTENCY_PAYLOAD_CONFLICT` |
| `0174_payment_approval_integrity.sql` | 전체 | partial unique · 최초 결과 반환 precedent |
| `0176_payment_approval_binding_all_paths.sql` | 전체 | request evidence binding precedent |
| live PostgreSQL catalog | `pg_proc` · `pg_constraint` · `pg_indexes` · `information_schema.columns` | writer · signature · numbering · business day · constraint 실측 |

## §11 Findings

### RG-F11 — `run_integration_test` public signature exception

```text
status       EXCLUDED_FROM_0178_SIGNATURE_CHANGE

reason       integration-test utility이며 production business entry point가 아니다.
             기존 non-writer overload와 (uuid,uuid,text,text)가 겹친다.

requirement  내부 production writer 호출은 0178 request identity contract를 준수한다.

forbidden    unrelated non-writer overload rename
             request identity type 변경으로 signature 충돌 회피

적용         함수 실행마다 run_uuid 1회 생성
             integration-test:PATENT2:<run_uuid>를 같은 action 안에서 유지
             orders.idempotency_key linkage · production allocator 적용
             idempotency_keys INSERT 0건

잔존         retry 중복 방지는 없다. test utility exception으로 Human이 허용했다.
             PUBLIC EXECUTE이며 실제 orders INSERT를 한다.
             RG-F6와 함께 처분 대상이다.
```

### RG-F12 — 추가 live schema drift

T8 first-call 실측에서 다음 body/catalog 불일치를 확인했다.

```text
place_kiosk_order     store_settings.min_order_amount 참조 · live column 0
place_takeout_order   order_items.unit_price · subtotal 참조 · live column 각각 0
```

`0178` request identity와 allocator 범위를 확대해 고치지 않았다.

### RG-F13 — provider intake digest resolution

`intake_delivery_order`와 provider wrapper 5개는 raw event 기록에서 unqualified `digest(text,'sha256')`를 실행한다. 각 SECURITY DEFINER search_path에 `extensions`가 없어 `function digest(text, unknown) does not exist`로 중단됐다. `extensions.digest(text,text)` 자체는 live catalog에 존재한다. `0178` 범위에서 고치지 않았다.

### RG-F14 — kiosk wrapper actor/check mismatch

`submit_kiosk_order`는 `confirm_order`에 `p_actor_type='KIOSK'`를 전달하고, `confirm_order`는 그 값을 `catchmenu_pos.order_events.caused_by_type`에 기록한다. live `chk_order_event_caused_by` 허용값은 `SYSTEM · AGENT · STAFF · MANAGER · CUSTOMER · PROVIDER · SCHEDULER`이며 `KIOSK`가 없다. T9 호출은 이 CHECK에서 rollback됐다. `0178` 범위에서 고치지 않았다.
