# 602020_Evidence_RuntimeGate_Payment_Approval_Integrity.md

Status: Active
Lifecycle: RuntimeGate
DocumentType: Evidence
Last Updated: 2026-09-08

## §0 성격 · PRE-FLIGHT

`600023` §3 · §5의 Runtime Gate 형식으로 `catchmenu_payment.confirm_payment_from_provider` 1개를 측정한다.

```text
증명할 것      검증된 provider 승인 event binding
               동일 provider approval의 원장 1회 생성과 결과 재사용
               tenant-scoped read / mutation 전 caller tenant 검증

범위 밖        confirm_payment
               confirm_payment_webhook
```

### §0.1 PRE-FLIGHT 실행과 실측

```text
> git rev-parse HEAD
290c751dbc37d429fe235d461b6976c975df0b0c

> git status --short --untracked-files=all
(출력 없음)

> docker inspect supabase_db_yoonsul_wait_order_handoff --format '{{.Id}} {{.Config.Image}} {{json .Config.Labels}}'
b67400e8c73e4ec7b9a25b172d71af347dd22d5e269d49859629fc3d8bd935ec public.ecr.aws/supabase/postgres:17.6.1.156 {"com.docker.compose.project":"yoonsul_wait_order_handoff","com.supabase.cli.project":"yoonsul_wait_order_handoff","com.supabase.cli.workdir":"D:\\Workspace\\Yoonsul_Wait_Order_Handoff"}

> SELECT current_database(), version();
postgres | PostgreSQL 17.6 on x86_64-pc-linux-gnu, compiled by gcc (GCC) 15.2.0, 64-bit

> SELECT filename, checksum, applied_at, applied_by, success, error_message
  FROM catchmenu_meta.migration_history
  WHERE success ORDER BY applied_at DESC LIMIT 1;
0173_caller_tenant_scope_remove_claim_exemption.sql | 47dcd5c034f191098faea178693cf94a39a5a2fa6fd23bcb9eb759a5cbec97f0 | 2026-09-08 07:38:05.234819+00 | postgres | t |

> Get-FileHash -Algorithm SHA256 sql/migrations/0173_caller_tenant_scope_remove_claim_exemption.sql
47DCD5C034F191098FAEA178693CF94A39A5A2FA6FD23BCB9EB759A5CBEC97F0

> SELECT * FROM catchmenu_meta.migration_history WHERE filename LIKE '0174%';
(0 rows)

> Test-Path sql/migrations/0174_payment_approval_integrity.sql
False

> Test-Path docs/600000_implementation_lifecycle/602000_runtime_gate/602020_Evidence_RuntimeGate_Payment_Approval_Integrity.md
False
```

container의 Compose project · Supabase CLI project · workdir가 현재 저장소와 일치한다. DB는 local dev container의 `postgres`다. PRE-FLIGHT 조건은 전부 일치했다.

## §1 공격

`601919` T02 · T03 재현 스크립트 전문:

```sql
\pset pager off
\pset format aligned
\set ON_ERROR_STOP on
\echo === RG02 fixture begin ===
begin;

insert into catchmenu_hq.tenants (
  id, tenant_code, tenant_name, tenant_type, plan_tier,
  is_active, tenant_status, isolation_state
) values (
  'eeeeeeee-2000-4000-8000-000000000001',
  'RG02_AUDIT_TENANT', 'RG02 Audit Tenant', 'TEST', 'STANDARD',
  true, 'ACTIVE', 'NONE'
);

insert into catchmenu_hq.stores (
  id, tenant_id, store_code, store_name, store_type,
  store_status, timezone, is_active
) values (
  'eeeeeeee-2000-4000-8000-000000000002',
  'eeeeeeee-2000-4000-8000-000000000001',
  'RG02_STORE', 'RG02 Audit Store', 'DINE_IN',
  'ACTIVE', 'Asia/Seoul', true
);

insert into catchmenu_pos.order_sessions (
  id, tenant_id, store_id, session_type, session_status,
  guest_count, business_day, business_timezone,
  correlation_id
) values (
  'eeeeeeee-2000-4000-8000-000000000005',
  'eeeeeeee-2000-4000-8000-000000000001',
  'eeeeeeee-2000-4000-8000-000000000002',
  'WALK_IN', 'ORDER_CONFIRMED',
  1, current_date, 'Asia/Seoul',
  'RG02-AUDIT'
);

insert into catchmenu_pos.orders (
  id, tenant_id, store_id, session_id, order_number,
  order_type, order_status, total_amount, discount_amount,
  final_amount, order_channel, business_day,
  business_timezone, correlation_id
) values (
  'eeeeeeee-2000-4000-8000-000000000003',
  'eeeeeeee-2000-4000-8000-000000000001',
  'eeeeeeee-2000-4000-8000-000000000002',
  'eeeeeeee-2000-4000-8000-000000000005',
  'RG02-0001', 'DINE_IN', 'CONFIRMED',
  1000, 0, 1000, 'STAFF_POS', current_date,
  'Asia/Seoul', 'RG02-AUDIT'
);

update catchmenu_pos.order_sessions
set order_id = 'eeeeeeee-2000-4000-8000-000000000003'
where id = 'eeeeeeee-2000-4000-8000-000000000005';

insert into catchmenu_payment.payment_intents (
  id, tenant_id, store_id, order_id, session_id,
  intent_status, payment_method, payment_channel,
  requested_amount, provider_type, idempotency_key,
  business_day, business_timezone
) values (
  'eeeeeeee-2000-4000-8000-000000000004',
  'eeeeeeee-2000-4000-8000-000000000001',
  'eeeeeeee-2000-4000-8000-000000000002',
  'eeeeeeee-2000-4000-8000-000000000003',
  'eeeeeeee-2000-4000-8000-000000000005',
  'PROCESSING', 'CARD', 'STAFF_POS',
  1000, 'TOSS_PAYMENTS', 'RG02-AUDIT-INTENT',
  current_date, 'Asia/Seoul'
);

set local role authenticated;
select set_config(
  'request.jwt.claims',
  '{"sub":"aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa","tenant_id":"aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa","store_id":"aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa","role":"authenticated","actor_type":"STAFF"}',
  true
);

\echo === T02 fake provider key + NULL raw_event_id ===
select catchmenu_payment.confirm_payment_from_provider(
  'eeeeeeee-2000-4000-8000-000000000001',
  'eeeeeeee-2000-4000-8000-000000000002',
  'eeeeeeee-2000-4000-8000-000000000004',
  'AUDIT_FAKE_KEY',
  'AUDIT',
  1000,
  null,
  'RG02-AUDIT'
) as t02_result;

\echo === T03 identical replay ===
select catchmenu_payment.confirm_payment_from_provider(
  'eeeeeeee-2000-4000-8000-000000000001',
  'eeeeeeee-2000-4000-8000-000000000002',
  'eeeeeeee-2000-4000-8000-000000000004',
  'AUDIT_FAKE_KEY',
  'AUDIT',
  1000,
  null,
  'RG02-AUDIT'
) as t03_result;

reset role;
\echo === T03 ledger count / distinct key / approved sum ===
select
  count(*) as ledger_count,
  count(distinct provider_payment_key) as distinct_provider_payment_key,
  sum(approved_amount) as approved_sum
from catchmenu_payment.payment_ledger
where tenant_id = 'eeeeeeee-2000-4000-8000-000000000001'
  and intent_id = 'eeeeeeee-2000-4000-8000-000000000004'
  and provider_payment_key = 'AUDIT_FAKE_KEY';

rollback;
\echo === residual after rollback ===
select
  (select count(*) from catchmenu_hq.tenants
   where id = 'eeeeeeee-2000-4000-8000-000000000001') as tenant_rows,
  (select count(*) from catchmenu_payment.payment_ledger
   where provider_payment_key = 'AUDIT_FAKE_KEY') as ledger_rows;
```

## §2 재현 로그

```text
Pager usage is off.
Output format is aligned.
=== RG02 fixture begin ===
BEGIN
INSERT 0 1
INSERT 0 1
INSERT 0 1
INSERT 0 1
UPDATE 1
INSERT 0 1
SET
set_config
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
{"sub":"aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa","tenant_id":"aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa","store_id":"aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa","role":"authenticated","actor_type":"STAFF"}
(1 row)

=== T02 fake provider key + NULL raw_event_id ===
t02_result
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
{"success": true, "audit_id": "508cd8b6-9a67-4750-9349-b42949e14757", "intent_id": "eeeeeeee-2000-4000-8000-000000000004", "ledger_id": "a8e3874c-7c9b-483f-a5ac-5089927a0dd4", "result_code": "PAYMENT_CONFIRMED_KDS_NO_TICKETS_TO_PROCESS", "message_code": "payment_approved_kds_pending", "ledger_status": "APPROVED", "approved_amount": 1000, "kds_release_result": {"success": true, "audit_id": "6d0f9641-d3a6-46bb-8a57-670f7820dfb2", "order_id": "eeeeeeee-2000-4000-8000-000000000003", "ledger_id": "a8e3874c-7c9b-483f-a5ac-5089927a0dd4", "result_code": "PAYMENT_CONFIRMED_KDS_NO_TICKETS_TO_PROCESS", "pending_count": 0, "skipped_count": 0, "committed_count": 0, "bulk_commit_detail": {"success": true, "order_id": "eeeeeeee-2000-4000-8000-000000000003", "message_code": "no_tickets_committed", "all_committed": true, "pending_count": 0, "skipped_count": 0, "ticket_results": [], "committed_count": 0, "total_processed": 0}}, "reconciliation_status": "PENDING", "kds_release_authorized": false, "kds_tickets_payment_confirmed": 0}
(1 row)

=== T03 identical replay ===
t03_result
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
{"success": true, "audit_id": "bfe6acb5-8e12-4344-820c-de2f5117fd59", "intent_id": "eeeeeeee-2000-4000-8000-000000000004", "ledger_id": "5c2b4736-43ec-412b-a33a-f01712c33ec4", "result_code": "PAYMENT_CONFIRMED_KDS_NO_TICKETS_TO_PROCESS", "message_code": "payment_approved_kds_pending", "ledger_status": "APPROVED", "approved_amount": 1000, "kds_release_result": {"success": true, "audit_id": "814582cd-8557-4921-91a4-5fd16d9f6e63", "order_id": "eeeeeeee-2000-4000-8000-000000000003", "ledger_id": "5c2b4736-43ec-412b-a33a-f01712c33ec4", "result_code": "PAYMENT_CONFIRMED_KDS_NO_TICKETS_TO_PROCESS", "pending_count": 0, "skipped_count": 0, "committed_count": 0, "bulk_commit_detail": {"success": true, "order_id": "eeeeeeee-2000-4000-8000-000000000003", "message_code": "no_tickets_committed", "all_committed": true, "pending_count": 0, "skipped_count": 0, "ticket_results": [], "committed_count": 0, "total_processed": 0}}, "reconciliation_status": "PENDING", "kds_release_authorized": false, "kds_tickets_payment_confirmed": 0}
(1 row)

RESET
=== T03 ledger count / distinct key / approved sum ===
ledger_count | distinct_provider_payment_key | approved_sum
-------------+-------------------------------+-------------
           2 |                             1 |         2000
(1 row)

ROLLBACK
=== residual after rollback ===
tenant_rows | ledger_rows
------------+------------
          0 |           0
(1 row)
```

T02의 가짜 provider key와 `NULL` raw event id가 승인 원장 생성에 성공했다. 같은 인자의 T03 재호출도 성공했고 서로 다른 `ledger_id`를 반환했다. 원장 집계는 2행, distinct provider key 1개, 승인 합계 2000이었다. 합성 fixture와 원장은 `ROLLBACK` 뒤 0행이다.

## §3 invariant

Human 확정 invariant를 그대로 인용한다.

```text
① 승인 원장은 검증된 provider 승인 이벤트 없이 생성되지 않는다

   p_provider_raw_event_id 는 NULL 일 수 없다
   해당 id 는 provider_raw_events 에 실재해야 한다

   해당 raw event 는
   현재 처리 대상 tenant / provider / payment 와 일치하고
   승인 성공으로 검증된 event 여야 한다

② 같은 provider 승인은 원장을 한 번만 만든다

   동일 provider approval identity 에 대해
   DB unique 제약으로 중복 생성을 금지한다

   동일 승인 재호출은 duplicate error 가 아니라
   최초 생성된 원장 결과를 반환한다

③ tenant scope

   RG-01 의 assert_caller_tenant_scope 를 호출한다

   tenant-scoped read / mutation 전에
   caller tenant 검증을 통과해야 한다
```

### §3.1 Human 수정 — 보장 범위

2026-09-08 Human 확인으로 ①의 보장 범위를 다음과 같이 한정한다.

```text
이 gate가 강제하는 것
  §4.2의 공통 조건 전건
  TOSS_PAYMENTS provider-specific 조건 전건
  DB에 기록된 raw event와 현재 payment의 구조적 binding

이 gate가 강제하지 않는 것
  provider webhook의 암호학적 진위
  signature_verified 플래그를 만드는 upstream writer/verifier의 신뢰성
```

암호학적 진위 공백은 §11 `RG-F5`로 분리한다.

## §4 근거

| 구분 | 근거 |
|---|---|
| Doctrine | `010004` §14 Payment And Financial Isolation Rule |
| Doctrine | `010660` §6 `IDEMPOTENCY_PAYLOAD_CONFLICT` |
| Human invariant | `602020` §3 |
| Runtime evidence | `601919` C-02 · T02 · T03 |
| Precedent only | `0172` · `0173` RG-01 helper |

`010004` §14는 financial record의 tenant id, store id, order reference, payment reference, provider reference, authority, masking, audit scope를 요구한다. `010660` §6은 duplicate가 기존 결과를 반환하는 상태와 같은 key의 다른 payload를 실행하지 않는 상태를 구분한다.

## §4.1 approval identity 실측

### §4.1.1 라이브 행과 제약

실행 SQL:

```sql
select count(*) as raw_event_rows,
       count(provider_event_id) as raw_with_provider_event_id,
       count(distinct (tenant_id, provider_type, provider_event_id))
         filter (where provider_event_id is not null)
         as distinct_tenant_provider_event
from catchmenu_gateway.provider_raw_events;

select count(*) as approval_rows,
       count(provider_payment_key) as approval_with_payment_key,
       count(distinct (tenant_id, provider_type, provider_payment_key))
         filter (where provider_payment_key is not null)
         as distinct_tenant_provider_key,
       count(provider_approval_number) as approval_with_approval_number,
       count(distinct (tenant_id, provider_type, provider_approval_number))
         filter (where provider_approval_number is not null)
         as distinct_tenant_provider_approval_number,
       count(provider_response_id) as approval_with_raw_event_id,
       count(distinct provider_response_id)
         filter (where provider_response_id is not null)
         as distinct_raw_event_id
from catchmenu_payment.payment_ledger
where ledger_entry_type = 'APPROVAL';

select indexname, indexdef
from pg_indexes
where (schemaname, tablename) in (
  ('catchmenu_gateway', 'provider_raw_events'),
  ('catchmenu_payment', 'payment_ledger')
)
order by schemaname, tablename, indexname;
```

```text
provider_raw_events
  전체 행                         0
  provider_event_id 비NULL        0
  distinct(tenant, provider, id)  0

payment_ledger WHERE ledger_entry_type = 'APPROVAL'
  전체 행                                      0
  provider_payment_key 비NULL                  0
  distinct(tenant, provider, payment_key)      0
  provider_approval_number 비NULL              0
  distinct(tenant, provider, approval_number)  0
  provider_response_id 비NULL                  0
  distinct provider_response_id                0

중복 group
  provider_payment_key       0
  provider_approval_number   0
  raw_event_id               0
```

라이브 업무 행이 0건이므로 행 분포로 세 후보의 유일성을 입증할 수 없다. catalog에는 `provider_raw_events.id` PK와 `payment_ledger.id` PK만 관련 unique 제약으로 존재한다. `provider_raw_events.provider_event_id`와 `payment_ledger.provider_payment_key`의 현재 index는 모두 non-unique다. `provider_approval_number`에는 index가 없다.

### §4.1.2 소스에서 확인한 필드 의미

| 후보 | 실측 근거 | identity 한계 |
|---|---|---|
| `provider_payment_key` | `0038` 223행에서 Toss `paymentKey`를 raw event의 `provider_event_id`로 저장하고, 298행에서 같은 값을 `confirm_payment_from_provider`에 전달한다. `0130` 397~400행은 VAN 경로에서 승인번호를 우선 사용하고 없으면 내부 VAN transaction UUID를 대체값으로 만든다. | provider와 tenant의 namespace를 함께 두어야 한다. `NULL`이면 unique 제약으로 동일 승인을 식별할 수 없다. |
| `provider_approval_number` | `0038` 285행과 299~300행은 Toss `approveNo`를 별도 승인번호로 저장·전달한다. `0130` 397~400행은 VAN 승인번호가 없을 수 있어 내부 UUID로 대체한다. | 모든 provider 경로에서 항상 존재하는 canonical key가 아니다. 단독 identity로 쓰지 않는다. |
| `raw_event_id` | `provider_raw_events.id` PK라 한 수신 행은 유일하다. `0038`은 webhook 수신 때 새 raw-event 행을 삽입한 뒤 그 UUID를 confirmation에 전달한다. | 같은 provider 승인이 재전송되어 새 raw-event 행이 생기면 UUID가 달라진다. 승인 identity 단독 키가 아니다. |

### §4.1.3 제안 키

제안하는 DB unique identity는 다음 partial key다.

```sql
create unique index uq_payment_ledger_provider_approval_identity
on catchmenu_payment.payment_ledger (
  tenant_id,
  provider_type,
  provider_payment_key
)
where ledger_entry_type = 'APPROVAL';
```

구성 사유:

1. `tenant_id`는 provider merchant/account namespace를 구분한다.
2. `provider_type`은 provider별 key namespace를 구분한다.
3. `provider_payment_key`는 Toss 경로의 provider payment identity이며 VAN 경로도 승인번호 또는 transaction UUID를 이 필드에 정규화한다.
4. `store_id`, `intent_id`, `order_id`, `raw_event_id`를 unique key에 넣지 않는다. 같은 승인을 다른 store · intent · order 또는 새 수신 행으로 제출해도 두 번째 승인 원장을 만들지 못하게 하기 위해서다.
5. partial predicate는 취소 · 환불 등 같은 provider payment를 참조하는 후속 ledger entry를 차단하지 않고 승인 원장만 1건으로 제한한다.
6. 별도 CHECK로 `APPROVAL` 행의 `provider_payment_key IS NOT NULL`을 강제해 PostgreSQL unique의 `NULL` 공백을 닫는다.
7. unique 충돌 시 기존 행을 반환하려면 입력 tenant · provider · payment key뿐 아니라 intent · order · store · 승인번호 · 승인액 · raw-event binding이 기존 행과 일치하는지 확인해야 한다. 불일치 입력을 최초 결과로 취급하지 않는다.

### §4.1.4 Human 확인 — 2026-09-08

Human이 다음 approval identity를 확정했다.

```sql
unique (tenant_id, provider_type, provider_payment_key)
where ledger_entry_type = 'APPROVAL'
```

`store_id`는 넣지 않는다. 같은 승인이 두 store에 들어가는 것 자체를 중복으로 차단한다. `tenant_id`는 provider payment key의 provider 전역 유일성이 실증되지 않았으므로 남긴다.

Human이 추가로 확정한 CHECK:

```sql
check (
  ledger_entry_type <> 'APPROVAL'
  or provider_payment_key is not null
)
```

적용 전 기존 위반 행 실측:

```text
payment_ledger WHERE ledger_entry_type = 'APPROVAL'  0행
그중 provider_payment_key IS NULL                   0행
```

## §4.2 provider raw event 구조와 binding 제안

### §4.2.1 컬럼 구조 실측

| # | 컬럼 | 타입 | NULL | default |
|---:|---|---|---|---|
| 1 | `id` | `uuid` | NO | `gen_random_uuid()` |
| 2 | `tenant_id` | `uuid` | NO |  |
| 3 | `store_id` | `uuid` | YES |  |
| 4 | `provider_type` | `text` | NO |  |
| 5 | `provider_code` | `text` | NO |  |
| 6 | `provider_event_id` | `text` | YES |  |
| 7 | `provider_event_type` | `text` | YES |  |
| 8 | `raw_headers` | `jsonb` | YES |  |
| 9 | `raw_payload` | `jsonb` | NO |  |
| 10 | `payload_hash` | `text` | YES |  |
| 11 | `signature_header` | `text` | YES |  |
| 12 | `signature_verified` | `boolean` | YES |  |
| 13 | `signature_verified_at` | `timestamptz` | YES |  |
| 14 | `signature_algorithm` | `text` | YES |  |
| 15 | `schema_validated` | `boolean` | YES |  |
| 16 | `schema_validation_errors` | `jsonb` | YES |  |
| 17 | `processing_status` | `text` | NO | `'RECEIVED'` |
| 18 | `processing_attempts` | `integer` | NO | `0` |
| 19 | `first_received_at` | `timestamptz` | NO | `now()` |
| 20 | `last_processed_at` | `timestamptz` | YES |  |
| 21 | `accepted_at` | `timestamptz` | YES |  |
| 22 | `rejected_at` | `timestamptz` | YES |  |
| 23 | `rejection_reason` | `text` | YES |  |
| 24 | `internal_event_id` | `uuid` | YES |  |
| 25 | `idempotency_key_id` | `uuid` | YES |  |
| 26 | `correlation_id` | `text` | YES |  |
| 27 | `source_ip` | `text` | YES |  |
| 28 | `source_device_id` | `uuid` | YES |  |
| 29 | `received_at` | `timestamptz` | NO | `now()` |

관련 제약과 물리 상태:

```text
PK                         id
FK                         tenant_id · store_id · internal_event_id
                           idempotency_key_id · source_device_id
provider_type CHECK        TOSS_POS · TOSS_PAYMENTS · VAN_NICE · VAN_KIS
                           VAN_KICC · PG_KAKAO · PG_NAVER · ALIPAY
                           WECHAT_PAY · SAMSUNG_PAY · DELIVERY_* · OKPOS
                           KIOSK_VENDOR · INTERNAL_AGENT · OTHER
processing_status CHECK    RECEIVED · VALIDATING · ACCEPTED · REJECTED
                           QUARANTINED · REPLAYED · EXPIRED
raw_payload CHECK          JSON object
trigger                    0건
provider_event_id index    non-unique
업무 행                    0건
```

`provider_raw_events`에는 `intent_id`, `order_id`, `approved_amount` 전용 컬럼이 없다. payment binding은 공통 컬럼만으로 완결되지 않으며 provider별 `raw_payload` 필드를 대조해야 한다.

### §4.2.2 실제 caller 순서

live 함수 본문에서 `confirm_payment_from_provider`를 호출하는 다른 함수는 2개다.

| caller | raw event 기록 | confirmation 호출 시 상태 | payment 표현 |
|---|---|---|---|
| `process_toss_webhook` | `provider_type='TOSS_PAYMENTS'`, `provider_code='TOSS'`, `provider_event_id=paymentKey`, `signature_verified=true`, `signature_verified_at=now()`, `schema_validated=true`, `processing_status='VALIDATING'` | `VALIDATING`; confirmation 반환 뒤 `ACCEPTED`로 변경 | `raw_payload.paymentKey`, `orderId`, `status`, `totalAmount`, `approveNo` |
| `process_van_approval` | `provider_type=p_van_provider`, `provider_code='VAN'`, `provider_event_id=coalesce(approval_number, trace_number)`, `signature_verified=true`, `schema_validated=true`, 승인 판정이면 `ACCEPTED` | `ACCEPTED` | raw payload는 임의 provider response이며 intent/order/amount의 공통 JSON 계약 없음 |

Toss의 정상 첫 호출은 raw event가 `VALIDATING`일 때 일어난다. 따라서 confirmation에서 `processing_status='ACCEPTED'`만 허용하면 현재 정상 Toss 경로가 자기 차단된다.

VAN caller에는 두 가지 물리 공백이 있다.

1. caller가 허용하는 `NICE_PAYMENTS`, `KIS`, `KICC`, `KFTC`, `SMARTRO`, `KCP` 값은 raw-event `provider_type` CHECK 및 payment-intent provider 값과 직접 일치하지 않는다.
2. raw event에 현재 intent · order · 승인액을 표준 필드로 넣지 않는다. 현재 29개 컬럼과 임의 `raw_payload`만으로 VAN event와 payment의 완전한 binding을 구성할 수 없다.

### §4.2.3 제안 binding predicate

`confirm_payment_from_provider`의 tenant-scoped read보다 먼저 다음을 실행한다.

```sql
perform catchmenu_common.assert_caller_tenant_scope(p_tenant_id);
```

그 뒤 intent를 잠그고 raw event를 읽어 다음 공통 조건을 모두 요구한다.

```text
p_provider_raw_event_id IS NOT NULL
p_provider_payment_key IS NOT NULL

raw.id                = p_provider_raw_event_id
raw.tenant_id         = p_tenant_id
raw.store_id          = p_store_id
raw.provider_type     = intent.provider_type
raw.provider_event_id = p_provider_payment_key
raw.signature_verified IS TRUE
raw.signature_verified_at IS NOT NULL
raw.schema_validated IS TRUE
raw.schema_validation_errors IS NULL
```

현재 DB에서 payment binding을 완결할 수 있는 `TOSS_PAYMENTS`에는 다음 provider-specific 조건을 추가한다.

```text
raw.provider_type                    = 'TOSS_PAYMENTS'
raw.provider_code                    = 'TOSS'
raw.processing_status                IN ('VALIDATING', 'ACCEPTED')
raw.raw_payload->>'paymentKey'       = p_provider_payment_key
raw.raw_payload->>'orderId'          = intent.provider_order_id
raw.raw_payload->>'status'           = 'DONE'
raw.raw_payload->>'totalAmount'      = p_approved_amount의 십진 문자열
raw.raw_payload->>'approveNo'        IS NOT DISTINCT FROM
                                       p_provider_approval_number
raw.payload_hash                     = sha256(raw.raw_payload::text)의 hex
```

제안은 이 migration에서 `TOSS_PAYMENTS` binding만 허용하고 그 밖의 provider type은 fail closed로 반환하는 것이다. 현재 VAN raw event에는 intent · order · 승인액을 동일 event에 결속하는 공통 필드가 없으므로, 추정한 JSON key로 승인하지 않는다.

검사 순서 제안:

```text
1  assert_caller_tenant_scope
2  payment_intents SELECT ... FOR UPDATE
3  필수 key · raw event 존재와 공통 binding 검사
4  TOSS_PAYMENTS provider-specific 승인 성공 · payment binding 검사
5  기존 APPROVAL 원장 조회
6  완전 일치 replay면 최초 ledger 결과 반환
7  기존 행과 payload/scope가 다르면 conflict 반환
8  최초 호출만 원장과 후속 event 생성
```

### §4.2.4 검증 provenance 한계

`provider_raw_events` 테이블은 RLS + FORCE RLS이며 direct table privilege는 `postgres`에만 있다. 그러나 raw event를 만드는 두 caller와 Toss verifier는 `SECURITY DEFINER`, `authenticated=X`다.

live `verify_toss_signature(jsonb,text,text)`는 HMAC을 계산하지 않고 signature header 형식과 길이만 검사한다. `process_toss_webhook`은 caller가 전달한 `p_webhook_secret`을 verifier에 넘기며, 검증 성공 시 raw event의 `signature_verified=true`를 기록한다. `process_van_approval`도 caller 입력으로 승인 여부를 계산하고 `signature_verified=true`, `schema_validated=true`를 기록한다.

따라서 §4.2.3 predicate가 보장하는 범위는 **DB에 기록된 raw event와 현재 payment의 구조적 binding**이다. 현재 upstream writer와 verifier 상태에서는 `signature_verified=true` 자체가 외부 provider의 암호학적 진위를 증명하지 않는다. 진짜 provider-origin verification까지 §3 ①의 의미에 포함하면, `confirm_payment_from_provider` 하나만 수정하는 현재 허용 범위로는 완결할 수 없다.

### §4.2.5 Human 확인 — 2026-09-08

Human이 다음을 승인했다.

```text
TOSS_PAYMENTS만 구조적 binding으로 허용
다른 provider는 fail closed
VALIDATING · ACCEPTED 모두 허용
암호학적 진위는 이 gate의 보장에서 제외하고 RG-F5로 분리
```

## §5 migration

대상: `sql/migrations/0174_payment_approval_integrity.sql`

```text
최종 SHA-256  EB97562F3983AB84B39DEDA6F07895107B204DD3CA6C89C4C647816437962069
적용 시각       2026-09-08 09:20:49.864969+00
적용자          postgres
history success true
```

적용 출력:

```text
BEGIN
DO
ALTER TABLE
CREATE INDEX
CREATE FUNCTION
COMMIT
```

구현 내용:

1. 적용 전 `APPROVAL + NULL provider_payment_key`와 중복 approval identity를 검사하고 발견 시 중단한다.
2. `chk_payment_ledger_approval_provider_key_not_null` CHECK를 추가한다.
3. `(tenant_id, provider_type, provider_payment_key) WHERE ledger_entry_type='APPROVAL'` unique index를 추가한다.
4. `assert_caller_tenant_scope`를 `payment_intents` 조회 전에 호출한다.
5. §4.2 공통 조건과 TOSS 조건을 모두 검사하고 다른 provider는 fail closed로 반환한다.
6. `INSERT ... ON CONFLICT ... DO NOTHING`으로 동시 unique 충돌을 duplicate error로 노출하지 않는다.
7. replay는 최초 payment event와 KDS audit에 저장된 결과를 읽어 최초 호출과 동일한 JSON result를 반환한다.
8. 함수 signature · defaults · 반환형 · 언어 · volatility · SECURITY DEFINER · owner · search_path · ACL을 유지한다.

작업 중 최초 함수 본문은 동일 ledger를 반환했으나 replay의 KDS 표현이 최초 응답과 달랐다. 완료 전 같은 0174 범위에서 저장된 payment event와 KDS audit로 최초 응답을 복원하도록 보정했고, 최종 파일 checksum과 migration history를 위 값으로 동기화했다.

## §6 검증

모든 순차 mutation 검증은 합성 행을 사용한 `BEGIN / ROLLBACK`이다.

### §6.1 T1 ~ T8 실제 출력

| Test | 입력 | 실제 출력 | 판정 |
|---|---|---|---|
| T1 | 가짜 key · `NULL raw_event_id` | `{"success":false,"error_key":"provider_raw_event_required"}` | DENY |
| T2 | 다른 tenant의 raw event id | `{"success":false,"error_key":"provider_raw_event_scope_mismatch"}` | DENY |
| T3 | payload status `CANCELED` | `{"success":false,"error_key":"provider_raw_event_payment_mismatch"}` | DENY |
| T4 | 정상 TOSS 승인 · raw status `VALIDATING` | `success=true` · ledger `17450693-298f-4fd5-9994-a33ed5e24eb0` | SUCCESS |
| T5 | T4 동일 인자 재호출 | T4와 전체 JSON 동일 · 같은 ledger · 원장 1행 · 합계 1000 | 최초 결과 반환 |
| T6 | 다른 tenant claim | `42501 caller tenant scope denied` | DENY |
| T7 | `signature_verified=false` | `{"success":false,"error_key":"provider_raw_event_verification_failed"}` | DENY |
| T8 | intent/provider `VAN_NICE` | `{"success":false,"error_key":"provider_binding_unsupported","provider_type":"VAN_NICE"}` | DENY |

T4 실제 출력:

```json
{"success":true,"audit_id":"53e15468-9e54-41e6-a99b-b27a9789c18f","intent_id":"eeeeeeee-2200-4000-8000-000000000004","ledger_id":"17450693-298f-4fd5-9994-a33ed5e24eb0","result_code":"PAYMENT_CONFIRMED_KDS_NO_TICKETS_TO_PROCESS","message_code":"payment_approved_kds_pending","ledger_status":"APPROVED","approved_amount":1000,"kds_release_result":{"success":true,"audit_id":"e73de720-f698-4aff-810f-6d5767c2c62c","order_id":"eeeeeeee-2200-4000-8000-000000000003","ledger_id":"17450693-298f-4fd5-9994-a33ed5e24eb0","result_code":"PAYMENT_CONFIRMED_KDS_NO_TICKETS_TO_PROCESS","pending_count":0,"skipped_count":0,"committed_count":0,"bulk_commit_detail":{"success":true,"order_id":"eeeeeeee-2200-4000-8000-000000000003","message_code":"no_tickets_committed","all_committed":true,"pending_count":0,"skipped_count":0,"ticket_results":[],"committed_count":0,"total_processed":0}},"reconciliation_status":"PENDING","kds_release_authorized":false,"kds_tickets_payment_confirmed":0}
```

T5 실제 출력은 위 T4 JSON과 동일했다.

```text
same_full_result  true
first_ledger_id   17450693-298f-4fd5-9994-a33ed5e24eb0
replay_ledger_id  17450693-298f-4fd5-9994-a33ed5e24eb0
ledger_count      1
approved_sum      1000
```

T6 실제 출력:

```text
NOTICE: T6 DENY sqlstate=42501 message=caller tenant scope denied
```

검증 transaction 종료 후:

```text
tenant_rows     0
ledger_rows     0
raw_event_rows  0
```

### §6.2 `ACCEPTED` 상태 정상 경로

별도 `BEGIN / ROLLBACK`에서 같은 구조적 binding을 갖는 raw event의 상태만 `ACCEPTED`로 두었다.

```text
success      true
ledger_id    7e7598ad-a302-4b0e-896e-8a3b6e3bbaf9
result_code  PAYMENT_CONFIRMED_KDS_NO_TICKETS_TO_PROCESS
rollback 후 residual  0
```

`VALIDATING`은 T4, `ACCEPTED`는 이 추가 검증에서 각각 SUCCESS였다.

### §6.3 동시 T5

공유 fixture를 커밋한 뒤 독립 PostgreSQL session 2개에서 동일 approval을 호출했다. 세션 A는 함수 반환 뒤 transaction을 4초 유지했다. 세션 B는 A가 잠금을 보유한 동안 호출해 A commit까지 대기했다.

```text
A_START       2026-09-08 09:19:37.143786+00
A_AFTER_CALL  2026-09-08 09:19:37.189482+00
A_COMMIT      2026-09-08 09:19:41.201289+00

B_START       2026-09-08 09:19:38.24367+00
B_AFTER_CALL  2026-09-08 09:19:41.235859+00
B_COMMIT      2026-09-08 09:19:41.241983+00
```

두 session 출력:

```text
A success        true
B success        true
A ledger_id      ec4487f2-7c1e-46d3-94f7-83730ac1bffc
B ledger_id      ec4487f2-7c1e-46d3-94f7-83730ac1bffc
A audit_id       6fac03d4-b6dd-4b72-9855-daaf52fec33f
B audit_id       6fac03d4-b6dd-4b72-9855-daaf52fec33f
A/B 전체 result  동일
duplicate error  없음
ledger count     1
distinct key     1
approved sum     1000
```

동시 fixture를 명시적으로 삭제한 뒤 tenant · ledger · raw event 잔여는 모두 0행이었다.

### §6.4 CHECK 강제

합성 `APPROVAL` 원장에 `provider_payment_key=NULL`을 직접 넣었다.

```text
NOTICE: CHECK DENY sqlstate=23514
constraint=chk_payment_ledger_approval_provider_key_not_null
```

## §7 회귀

### §7.1 예상 delta 대조

| 항목 | before | after | delta | 예상 | 판정 |
|---|---:|---:|---:|---:|---|
| migration success | latest `0173` | latest `0174` | +1 | +1 | 일치 |
| 함수 수 | 475 | 475 | 0 | 0 | 일치 |
| SECURITY DEFINER | 465 | 465 | 0 | 0 | 일치 |
| policy | 183 | 183 | 0 | 0 | 일치 |
| RLS table | 173 | 173 | 0 | 0 | 일치 |
| unique index | 514 | 515 | +1 | +1 | 일치 |
| CHECK 제약 | 507 | 508 | +1 | +1 | 일치 |

### §7.2 함수 전후 9속성

| 속성 | before | after | 변화 |
|---|---|---|---|
| signature | `confirm_payment_from_provider(uuid,uuid,uuid,text,text,integer,uuid,text)` | 동일 | 0 |
| defaults | 마지막 인자 `NULL::text` | 동일 | 0 |
| return type | `jsonb` | `jsonb` | 0 |
| language | `plpgsql` | `plpgsql` | 0 |
| volatility | `VOLATILE` | `VOLATILE` | 0 |
| SECURITY DEFINER | true | true | 0 |
| owner | `postgres` | `postgres` | 0 |
| search_path | `catchmenu_payment, catchmenu_pos, catchmenu_kds, catchmenu_ledger, catchmenu_audit, catchmenu_common` | 동일 | 0 |
| ACL | `postgres=X/postgres, authenticated=X/postgres` | 동일 | 0 |

### §7.3 Governance

```text
> tools/Check-Governance.ps1 -Top 0
PS_EXIT=0
전체 기존 finding 505
```

이번 두 파일에 새로 연결된 finding은 예상한 두 종류뿐이다.

```text
G11  602020 미색인
G15  0174 CONTRACT_NOT_FOUND
```

`602020`의 DocumentType, H1, UTF-8/BOM/LF 관련 신규 finding은 없다. 그 밖의 신규 finding은 관측되지 않았다.

## §8 근거 문서 목록 (000701 §46)

| 문서 | 사용 절 |
|---|---|
| `600023_Governance_Runtime_Gate_Spiral.md` | §3 · §5 |
| `601919_Audit_Independent_Foundation_Audit.md` | C-02 · T02 · T03 |
| `010004_Policy_SaaS_Tenant_Isolation_And_Cross_Tenant_Data_Containment_Beam.md` | §14 |
| `010660_Policy_Idempotency_Retry_Replay_Reconciliation.md` | §6 |
| `602010_Evidence_RuntimeGate_Caller_Tenant_Scope.md` | RG-01 helper precedent |
| `0172_caller_tenant_scope_gate.sql` | helper 최초 정의 |
| `0173_caller_tenant_scope_remove_claim_exemption.sql` | claim exemption 제거 |

## §9 실행 명령

DB 명령은 다음 read-only 형식 또는 mutation 검증의 명시적 `BEGIN / ROLLBACK`으로 실행했다.

```powershell
docker exec -e PGOPTIONS="-c default_transaction_read_only=on" -i supabase_db_yoonsul_wait_order_handoff psql -v ON_ERROR_STOP=1 -U postgres -d postgres
docker exec -i supabase_db_yoonsul_wait_order_handoff psql -v ON_ERROR_STOP=1 -U postgres -d postgres
tools/Check-Governance.ps1 -Top 0
```

동시 검증은 PowerShell `Start-Job`으로 독립 `docker exec ... psql` 두 개를 시작했다. 세션 A가 함수 호출 뒤 4초 동안 transaction을 유지하고 세션 B를 0.5초 뒤 시작했다.

## §10 판정

```text
Primary exploit closure
  T1  PASS — NULL raw_event_id 승인 거부
  T5  PASS — 순차·동시 replay 모두 최초 전체 결과 반환, ledger 1행

정상 경로
  T4  PASS — VALIDATING 정상 승인 성공
  추가 PASS — ACCEPTED 정상 승인 성공

나머지 경계
  T2 · T3 · T7 · T8  PASS — DENY
  T6                 PASS — 42501

회귀 delta           전건 일치
결론                 PASS
```

## §11 Findings

### RG-F5 — provider webhook 서명 검증이 형식 검사뿐이다

원문:

```sql
return (
  p_signature_header like 't=%,v1=%'
  and length(split_part(
    split_part(p_signature_header, ',', 2),
    'v1=', 2
  )) >= 32
);
```

함수 주석:

```text
Here we validate structure only (actual HMAC in app layer)
```

실측:

| 객체/권한 | `prosecdef` | `proacl` 또는 USAGE |
|---|---:|---|
| `verify_toss_signature(jsonb,text,text)` | true | `authenticated=X` |
| `process_toss_webhook` 7인자 | true | `authenticated=X` |
| `process_toss_webhook` 6인자 | true | `authenticated=X` |
| `process_van_approval` | true | `authenticated=X` |
| `catchmenu_integrations` schema |  | authenticated USAGE=true |
| `catchmenu_gateway` schema |  | authenticated USAGE=false |

형식만 맞춘 임의 signature를 `authenticated` 역할로 호출한 실제 출력:

```sql
select catchmenu_integrations.verify_toss_signature(
  '{"paymentKey":"RGF5-FAKE","status":"DONE"}'::jsonb,
  't=1,v1=AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA',
  'caller-supplied-secret'
);
```

```text
crafted_signature_accepted
--------------------------
true
```

함수 주석이 말하는 app-layer 실제 HMAC 검증 계층은 이 저장소에서 확인되지 않았다. raw-event 테이블 직접 권한은 `postgres`에만 있으나, authenticated가 `SECURITY DEFINER` writer와 verifier를 실행할 수 있다. 따라서 `signature_verified` 플래그 자체가 신뢰 가능한 provider-origin 증거가 아니다.

`RG-02`가 강제한 구조적 binding은 이 경로를 막지 않는다. `601919` C-02의 가짜 provider key와 같은 외부 승인 신뢰 경계 문제이며 **후속 Runtime Gate 대상**이다.

## §12 재개방 — 2026-09-08

### §12.1 실측 — 6항

#### §12.1.0 PRE-FLIGHT

```text
측정일       2026-09-08
Git HEAD     2e7bb3c65207da3415508a687b28a1eb888a29f2
working tree clean

DB           postgres
PostgreSQL   17.6
container    supabase_db_yoonsul_wait_order_handoff
container ID b67400e8c73e4ec7b9a25b172d71af347dd22d5e269d49859629fc3d8bd935ec
image        public.ecr.aws/supabase/postgres:17.6.1.156
Compose      yoonsul_wait_order_handoff
Supabase CLI yoonsul_wait_order_handoff
environment  local/dev

latest successful migration
0175_kds_payment_precondition.sql
f1fbae219d4b35ba7b058636802cf9643b8e3177f873ff6caba0c8746f4af974
2026-09-08 10:15:14.656249+00

0176 history rows 0
0176 file         없음
```

실행 명령:

```powershell
git rev-parse HEAD
git status --short --untracked-files=all
docker inspect supabase_db_yoonsul_wait_order_handoff
docker exec -e PGOPTIONS="-c default_transaction_read_only=on" -i supabase_db_yoonsul_wait_order_handoff psql -X -v ON_ERROR_STOP=1 -U postgres -d postgres
docker exec -i supabase_db_yoonsul_wait_order_handoff psql -X -v ON_ERROR_STOP=1 -U postgres -d postgres
```

#### §12.1.1 여섯 함수 전수

라이브 `pg_proc.prosrc`에서 실제 `payment_ledger` INSERT와 삽입되는 `ledger_entry_type`을 대조했다. 현재 APPROVAL INSERT를 가진 함수는 지시서의 6개가 아니라 4개다.

```text
catchmenu_common.flush_offline_queue
catchmenu_payment.confirm_payment
catchmenu_payment.confirm_payment_from_provider
catchmenu_payment.record_van_transaction
```

`accept_delivery_order`는 0175 적용으로 APPROVAL producer가 아니며 기존 승인 원장을 소비한다. `request_refund`의 INSERT는 APPROVAL이 아니라 refund 원장용 구식 문장이다.

| 함수 | 현재 APPROVAL INSERT | 경로 도달 | provider key 출처 | raw event binding | tenant helper |
|---|---:|---|---|---|---:|
| `flush_offline_queue` | 예 | authenticated 실호출 성공 | `'MANUAL-' || queue_item.id` | 큐 payload로 raw event를 같은 함수가 생성, 검증 없음 | 없음 |
| `accept_delivery_order` | 아니오 | 승인 원장 소비 경로 | 해당 없음 | raw event를 읽지 않음 | 있음, 첫 tenant read 전 |
| `confirm_payment` | 예, 2개 분기 | authenticated 실호출 성공 | caller의 `p_provider_tx_id` | caller payload로 raw event를 같은 함수가 생성, 검증 없음 | 없음 |
| `confirm_payment_from_provider` | 예 | §6 정상 승인 성공·가짜 event 거부 | caller의 `p_provider_payment_key`, raw event와 대조 | §4.2 공통 조건과 TOSS 조건 전건 | 있음, 첫 tenant read 전 |
| `record_van_transaction` | 예 | **미검증 — 호출 금지(`601505` §4)** | `coalesce(p_approval_number, v_tx_id::text)` | caller VAN payload로 raw event를 같은 함수가 생성, 검증 없음 | 없음 |
| `request_refund` | 아니오 | authenticated 호출은 42703 | 해당 없음 | raw event를 읽지 않음 | 없음 |

여섯 함수는 모두 `SECURITY DEFINER`다. authenticated는 여섯 schema에 USAGE가 있고 여섯 함수 모두에 EXECUTE가 있다. `record_van_transaction`의 raw ACL에는 PUBLIC EXECUTE도 있으나 anon과 service_role은 `catchmenu_payment` schema USAGE가 없어 현재 직접 도달하지 못한다.

```text
function                         authenticated schema/EXECUTE
flush_offline_queue              true / true
accept_delivery_order            true / true
confirm_payment                  true / true
confirm_payment_from_provider    true / true
record_van_transaction           true / true
request_refund                   true / true
```

APPROVAL writer 추출 쿼리:

```sql
select n.nspname, p.proname, p.oid::regprocedure
from pg_proc p
join pg_namespace n on n.oid = p.pronamespace
where p.prosrc ~* 'insert[[:space:]]+into[[:space:]]+(catchmenu_payment[.])?payment_ledger[[:space:]]*\('
  and p.prosrc ~ '''APPROVAL'''
order by 1, 2;
```

#### §12.1.2 `flush_offline_queue`

`RECORD_MANUAL_PAYMENT` 분기는 queue payload에서 `order_id`, `amount`, `payment_method`, `paid_at`, `business_day`, `note`를 읽는다. provider key는 caller 문자열이 아니라 `MANUAL-<queue_item.id>`로 만든다. 이어서 다음 순서로 기록한다.

```text
provider_raw_events
  provider_type       OTHER
  provider_code       MANUAL
  provider_event_id   MANUAL-<queue_item.id>
  raw_payload         offline/manual/queue_item_id/note
  signature_verified  NULL
  processing_status   RECEIVED

payment_intents
  intent_origin       MANUAL_ENTRY
  provider_type       resolve 함수에서 INTERNAL로 정규화

payment_ledger
  ledger_entry_type   APPROVAL
  ledger_status       APPROVED
  provider_type       MANUAL
  provider_payment_key MANUAL-<queue_item.id>
  provider_response_id 방금 만든 raw event
```

큐 삽입 함수 `enqueue_offline_action`도 authenticated EXECUTE가 있고 tenant helper가 없다. `p_action_type`과 `p_action_payload`를 그대로 INSERT한다. DB CHECK는 `RECORD_MANUAL_PAYMENT`라는 action type을 허용하며 payload 내용·provider 증거를 검증하지 않는다.

authenticated 실호출 출력:

```text
=== flush_offline_queue fake manual approval reachability ===
{"data": {"total": 1, "failed": 0, "results": [{"result": {"success": true, "ledger_id": "1c0e2e9e-9480-40ca-9f70-aa8b6956a273"}, "status": "COMPLETED", "queue_id": "eeeeeeee-3800-4000-8000-000000000018", "action_type": "RECORD_MANUAL_PAYMENT"}], "skipped": 0, "processed": 1}, "message": "오프라인 중 1건이 동기화되었습니다", "success": true, "message_key": "offline_queue_flushed"}

ledger_entry_type     APPROVAL
ledger_status         APPROVED
provider_type         MANUAL
provider_payment_key  MANUAL-eeeeeeee-3800-4000-8000-000000000018
signature_verified    NULL
signature_verified_at NULL
processing_status     RECEIVED
raw_payload           {"note":"caller supplied","manual":true,"offline":true,"queue_item_id":"eeeeeeee-3800-4000-8000-000000000018"}
```

fixture는 rollback했고 tenant·ledger·raw event·queue 잔존 행은 모두 0이다.

#### §12.1.3 `accept_delivery_order`

0175 이후 함수에는 `payment_ledger` INSERT가 없다. 다음 조건으로 이미 존재하는 승인 원장을 조회하고 KDS ticket의 `payment_ledger_id`에 기록한다.

```sql
where pl.tenant_id = p_tenant_id
  and pl.store_id = p_store_id
  and pl.order_id = v_intake.order_id
  and pl.ledger_entry_type = 'APPROVAL'
  and pl.ledger_status = 'APPROVED'
```

`assert_caller_tenant_scope`는 store·intake·ledger read 전에 실행된다. 이 함수 자체는 raw event를 읽거나 승인 원장을 생성하지 않는다.

#### §12.1.4 `confirm_payment`

caller가 `p_provider_type`, `p_provider_approval_number`, `p_provider_tx_id`, `p_approved_amount`, `p_provider_response`를 준다. 함수는 `p_provider_tx_id`를 provider key로 사용한다. CANCELLED/REFUNDED/PARTIAL_REFUNDED 분기와 일반 분기 모두 APPROVAL·APPROVED 원장을 INSERT한다.

그 직전에 `provider_raw_events`를 다음 caller 값으로 직접 생성한다.

```text
provider_event_id   p_provider_tx_id
raw_payload         p_provider_response 또는 caller 인자로 조립한 JSON
processing_status   RECEIVED
signature_verified  NULL
schema_validated    NULL
```

기존 raw event를 받거나 signature·schema·payload binding을 확인하지 않는다. tenant helper도 없다.

authenticated 실호출 출력:

```text
=== confirm_payment fake-key reachability ===
success             true
ledger_id           c9629ac0-eb77-460d-9f7e-4b26e408e9c5
provider_tx_id      RG02-FAKE-KEY
approval_number     RG02-FAKE-APPROVAL

ledger_entry_type     APPROVAL
ledger_status         APPROVED
provider_payment_key  RG02-FAKE-KEY
provider_response_id  d8f20984-d1a9-4951-971a-8d84029d6729
signature_verified    NULL
signature_verified_at NULL
processing_status     RECEIVED
raw_payload           {"caller":"fabricated"}
```

fixture는 rollback했고 잔존 행은 0이다.

#### §12.1.5 `confirm_payment_from_provider`

0174가 수정한 경로다. tenant helper가 첫 intent read보다 먼저 실행된다. APPROVAL INSERT 전에 다음을 확인한다.

```text
p_provider_raw_event_id                  non-NULL
raw event tenant/store/provider          처리 intent와 일치
provider_event_id                        provider payment key와 일치
signature_verified                       true
signature_verified_at                    non-NULL
schema_validated                         true
schema_validation_errors                 NULL
provider_code                            TOSS
processing_status                        VALIDATING 또는 ACCEPTED
raw payload paymentKey/orderId/status    intent·key·DONE와 일치
raw payload totalAmount/approveNo         승인 인자와 일치
payload_hash                             raw_payload 재계산값과 일치
provider                                 TOSS_PAYMENTS만 허용
```

§6의 T1은 가짜 key·NULL raw event를 거부했고 T4는 정상 raw event 승인에 성공했으며 T6은 타 tenant claim을 42501로 거부했다.

#### §12.1.6 `record_van_transaction` — 본문 열람만

**미검증 — 호출 금지(`601505` §4).** 함수는 호출하지 않았다.

catalog 본문은 `p_transaction_type='APPROVAL'`, `p_transaction_status='APPROVED'`, `p_order_id IS NOT NULL`이면 다음 순서로 실행한다고 적는다.

```text
van_transactions INSERT
provider key = coalesce(p_approval_number, v_tx_id::text)
provider_raw_events INSERT
resolve_or_create_payment_intent
payment_ledger APPROVAL/APPROVED INSERT
van_transactions.payment_ledger_id UPDATE
```

raw event의 `raw_payload`는 caller의 `p_van_response_raw` 또는 caller 인자에서 조립한다. signature·schema·processing status를 검증하지 않는다. tenant helper도 없다. `provider_response_id`는 같은 함수가 방금 만든 raw event를 가리킨다.

provider 이름도 동일하게 유지되지 않는다. raw event는 `NICE`·`NICE_VAN`을 `VAN_NICE`로 정규화하지만 ledger는 `p_van_provider || '_VAN'`을 기록한다. 예를 들어 caller가 `NICE`를 주면 raw event provider는 `VAN_NICE`, ledger provider는 `NICE_VAN`이다.

함수 속성:

```text
SECURITY DEFINER true
authenticated schema USAGE true
authenticated EXECUTE true
raw ACL {=X/postgres,postgres=X/postgres,authenticated=X/postgres}
assert_caller_tenant_scope 없음
```

#### §12.1.7 `request_refund`

이 함수는 APPROVAL을 INSERT하지 않는다. 원결제 조회에서 `ledger_status='APPROVED'`를 사용하고, 이어지는 INSERT는 주석과 반환값상 `REFUND_PENDING` 원장을 만들려는 경로다.

현재 본문은 `ledger_entry_type`을 넣지 않고 현행 `payment_ledger`에 없는 `provider_tx_id`, `payment_method`, `fee_amount`, `refund_reason`, `is_partial_refund`, `original_ledger_id` 컬럼을 사용한다. 원결제 fixture를 둔 authenticated 실호출은 INSERT 전 원결제 SELECT에서 멈췄다.

```text
request_refund sqlstate=42703
message=column "provider_tx_id" does not exist
ROLLBACK
residual 0
```

따라서 현재 스키마에서 refund INSERT는 도달하지 못하며 APPROVAL 생성 경로도 아니다. tenant helper는 없다.

#### §12.1.8 0174 UNIQUE·CHECK의 적용 범위

두 객체는 함수가 아니라 `catchmenu_payment.payment_ledger` 테이블에 직접 걸려 있다.

```text
chk_payment_ledger_approval_provider_key_not_null
  convalidated true
  CHECK (ledger_entry_type <> 'APPROVAL' OR provider_payment_key IS NOT NULL)

uq_payment_ledger_provider_approval_identity
  indisvalid true
  indisready true
  UNIQUE (tenant_id, provider_type, provider_payment_key)
  WHERE ledger_entry_type='APPROVAL'
```

따라서 현재 네 APPROVAL writer의 INSERT는 모두 같은 CHECK와 partial UNIQUE를 통과해야 한다. live approval 행은 0건이고 NULL-key 위반도 0건이다. 두 제약은 NULL key와 동일 identity 재삽입을 막지만 서로 다른 단일 key의 raw-event binding 여부는 검사하지 않는다.

실측 기준 현재 상태:

```text
APPROVAL writer                  4
0174 binding 적용 writer         1  confirm_payment_from_provider
binding 없는 실호출 성공 writer  2  flush_offline_queue, confirm_payment
호출 금지로 미검증 writer         1  record_van_transaction
지시 목록 중 비-writer            2  accept_delivery_order, request_refund
```

⚠️ §12.3 migration은 착수하지 않았다. Human 확인을 기다린다.

### §12.2 재개방 사유

`600023` §3.5는 “X는 Y 없이 도달하지 않는다”와 같은 결과 invariant가 경로 무관 진술이므로 그 결과를 기록·변경하는 객체를 catalog에서 전수 대조하도록 규정한다.

`602020` §3 ①은 승인 원장이 검증된 provider 승인 이벤트 없이 생성되지 않는다고 선언한다. 0174는 `confirm_payment_from_provider` 한 경로에 구조적 binding을 넣었다. 현재 catalog에는 APPROVAL writer가 네 개 있고, 나머지 세 writer에는 같은 binding이 없다. 그중 두 경로는 검증되지 않은 raw event와 단일 가짜 key로 APPROVAL을 실제 생성했으며 한 경로는 호출 금지 때문에 본문만 측정했다.

`accept_delivery_order`와 `request_refund`는 현재 APPROVAL writer가 아니라는 사실도 함께 기록한다.

### §12.3 migration

Human 처분:

```text
confirm_payment          0176에서 수정
flush_offline_queue      RG-02 범위 밖 — RG-F7
record_van_transaction   UNVERIFIABLE — RG-F8
```

대상 파일:

```text
sql/migrations/0176_payment_approval_binding_all_paths.sql
SHA-256     fc766450f2fdb273d0df97a5e91b389236ee753f4673d644062f8208607ffd80
applied_at  2026-09-08 11:11:58.707146+00
applied_by  postgres
success     true
```

대상 함수는 `catchmenu_payment.confirm_payment` 1개다. 적용 내용:

1. `assert_caller_tenant_scope(p_tenant_id)`를 첫 tenant-scoped read보다 먼저 호출한다.
2. 기존 signature 안의 `p_intent_id`로 intent의 tenant·store·order·provider·요청 금액·provider order ID를 고정한다.
3. `p_provider_tx_id`와 같은 `provider_event_id`를 가진 raw event를 tenant·store·`TOSS_PAYMENTS` 범위에서 조회한다. 0건은 `provider_raw_event_scope_mismatch`, 복수 행은 `provider_raw_event_ambiguous`로 거부한다.
4. 선택한 raw event를 `FOR SHARE`로 잠그고 §4.2와 동일한 signature·schema·processing status·payload·hash binding을 검사한다.
5. caller의 `p_provider_response`로 raw event를 생성하던 INSERT를 제거한다. 검증한 기존 raw event의 ID만 `provider_response_id`에 기록한다.
6. provider는 §3.1 Human 확정대로 `TOSS_PAYMENTS`만 허용하며 다른 provider는 `provider_binding_unsupported`로 fail closed한다.
7. 정상 APPROVAL 분기와 CANCELLED·REFUNDED·PARTIAL_REFUNDED의 manual-review APPROVAL 분기보다 앞에서 동일 gate를 실행한다. 두 INSERT 모두 검증한 `v_provider_response_id`를 사용한다.
8. signature·defaults·반환형·언어·volatility·SECURITY DEFINER·owner·search_path·ACL은 유지한다.

적용 전 parse 검증은 다음 결과로 rollback했다.

```text
BEGIN
CREATE FUNCTION
ROLLBACK
```

migration과 history는 한 transaction으로 적용했다.

```text
BEGIN
CREATE FUNCTION
INSERT 0 1
COMMIT
```

### §12.4 검증

T1~T6은 합성 fixture를 한 transaction 안에서 만들고 마지막에 rollback했다. T7은 호출 금지를 유지했다.

#### §12.4.1 T1 — 가짜 key

tenant·store·intent에는 맞지만 `signature_verified=false`인 raw event를 두고 caller가 그 event key와 caller JSON을 전달했다.

```text
=== T1 fake key with unverified raw event ===
confirm_payment
{"success": false, "error_key": "provider_raw_event_verification_failed"}
(1 row)
```

APPROVAL 원장 생성 0건. T1 PASS — DENY.

#### §12.4.2 T2 — raw event 미실재

```text
=== T2 nonexistent raw event ===
confirm_payment
{"success": false, "error_key": "provider_raw_event_scope_mismatch"}
(1 row)
```

T2 PASS — DENY.

#### §12.4.3 T3 — 다른 tenant raw event

같은 provider key의 검증 형식 raw event를 tenant B에 두고 tenant A의 order·intent로 호출했다.

```text
=== T3 other tenant raw event ===
confirm_payment
{"success": false, "error_key": "provider_raw_event_scope_mismatch"}
(1 row)

=== ledger count after T1-T3 ===
0
(1 row)
```

T3 PASS — DENY.

#### §12.4.4 T4 — 정상 승인

정상 fixture는 tenant·store·provider key·intent provider order ID·status `DONE`·amount·approval number가 일치하고 signature·schema가 true, processing status가 `VALIDATING`, payload hash가 재계산값과 일치한다.

```text
=== T4 valid approval ===
confirm_payment
{"data": {"kds": {"order_id": "eeeeeeee-4000-4000-8000-000000000003", "kds_status": "COMMITTED", "ticket_ids": [], "capacity_after": {"zones": [], "is_overloaded": false}, "released_count": 0, "late_binding_principle": "HOLD -> COMMITTED after payment only"}, "audit_id": "53fe1984-44bf-43bc-ad9b-b0a3b3357dda", "order_id": "eeeeeeee-4000-4000-8000-000000000003", "ledger_id": "0b0cc9e6-8159-479a-b276-0e8e0ff7f7df", "fee_amount": 15, "net_amount": 1000, "order_number": "RG02-0176-1", "provider_type": "TOSS_PAYMENTS", "provider_tx_id": "RG02-T4-VALID", "approval_number": "RG02-A4", "approved_amount": 1000, "late_binding_note": "결제 확인 후 주방 조리가 시작됩니다"}, "meta": {"locale": "ko", "occurred_at": "2026-09-08T11:16:54.808471+00:00", "correlation_id": "RG02-T4"}, "message": "결제가 완료되었습니다", "success": true, "message_key": "payment_confirmed"}
(1 row)

ledger_entry_type     APPROVAL
ledger_status         APPROVED
provider_payment_key  RG02-T4-VALID
provider_response_id  eeeeeeee-4000-4000-8000-000000000104
provider_event_id     RG02-T4-VALID
signature_verified    true
schema_validated      true
processing_status     VALIDATING
```

T4 PASS — SUCCESS. 원장의 `provider_response_id`는 caller가 만든 새 행이 아니라 검증 fixture의 기존 raw event ID다.

#### §12.4.5 T5 — 타 tenant claim

```text
=== T5 cross tenant claim ===
NOTICE: T5 sqlstate=42501 message=caller tenant scope denied
```

T5 PASS — 42501.

#### §12.4.6 T6 — `flush_offline_queue` 회귀

Human이 RG-02 범위 밖으로 확정한 `RECORD_MANUAL_PAYMENT`를 같은 방식으로 실행했다.

```text
=== T6 flush offline manual payment regression ===
flush_offline_queue
{"data": {"total": 1, "failed": 0, "results": [{"result": {"success": true, "ledger_id": "34b7a293-ba25-4c2a-9aa6-be288cdab2cf"}, "status": "COMPLETED", "queue_id": "eeeeeeee-4000-4000-8000-000000000018", "action_type": "RECORD_MANUAL_PAYMENT"}], "skipped": 0, "processed": 1}, "meta": {"locale": "ko", "occurred_at": "2026-09-08T11:16:54.808471+00:00", "correlation_id": null}, "message": "오프라인 중 1건이 동기화되었습니다", "success": true, "message_key": "offline_queue_flushed"}
(1 row)

ledger_entry_type     APPROVAL
ledger_status         APPROVED
provider_type         MANUAL
provider_payment_key  MANUAL-eeeeeeee-4000-4000-8000-000000000018
```

T6 PASS — SUCCESS.

#### §12.4.7 T7 — `record_van_transaction`

```text
미검증 — 호출 금지 (`601505` §4)
```

함수는 호출하지 않았다. T7 UNVERIFIABLE.

#### §12.4.8 rollback

```text
ROLLBACK
tenant residual     0
payment ledger      0
provider raw event  0
offline queue       0
```

Primary exploit closure T1은 DENY이고 정상 provider 승인 T4와 범위 밖 수기 결제 T6은 SUCCESS다.

### §12.5 회귀

#### §12.5.1 예상 delta

| 항목 | before | after | delta | 예상 | 판정 |
|---|---:|---:|---:|---:|---|
| migration success | latest `0175` | latest `0176` | +1 | +1 | 일치 |
| 함수 수 | 475 | 475 | 0 | 0 | 일치 |
| SECURITY DEFINER | 465 | 465 | 0 | 0 | 일치 |
| policy | 183 | 183 | 0 | 0 | 일치 |
| RLS table | 173 | 173 | 0 | 0 | 일치 |
| unique index | 319 | 319 | 0 | 0 | 일치 |
| CHECK 제약 | 453 | 453 | 0 | 0 | 일치 |

#### §12.5.2 함수 전후 속성

| 속성 | before | after | 변화 |
|---|---|---|---|
| signature | 14인자 기존 identity | 동일 | 0 |
| defaults | 마지막 6인자 기존 default | 동일 | 0 |
| return type | `jsonb` | `jsonb` | 0 |
| language | `plpgsql` | `plpgsql` | 0 |
| volatility | `VOLATILE` | `VOLATILE` | 0 |
| SECURITY DEFINER | true | true | 0 |
| owner | `postgres` | `postgres` | 0 |
| search_path | `catchmenu_payment, catchmenu_pos, catchmenu_kds, catchmenu_ledger, catchmenu_audit, catchmenu_common, catchmenu_hq` | 동일 | 0 |
| ACL | `postgres=X/postgres, authenticated=X/postgres` | 동일 | 0 |
| body MD5 | `b86b5ae0890a9ca43119a6a8fbe5a61c` | `ac868cc99180a82510924a7c2491e35f` | 본문만 변경 |

helper의 본문 문자 위치는 471, 첫 `payment_intents` tenant read는 1302다. `confirm_payment`의 `provider_raw_events` INSERT는 0건이다. 두 APPROVAL INSERT는 공통 binding gate보다 뒤에 있고 모두 검증된 `v_provider_response_id`를 기록한다.

#### §12.5.3 APPROVAL writer 전수 재확인

```text
APPROVAL writer 4
  binding 적용 2
    confirm_payment
    confirm_payment_from_provider

  범위 밖 1
    flush_offline_queue

  미검증 1
    record_van_transaction
```

`accept_delivery_order`와 `request_refund`는 §12.1에서 확인한 대로 APPROVAL writer가 아니다. 이 분류 외 미확인 APPROVAL writer는 0건이다.

#### §12.5.4 Governance

```text
> tools/Check-Governance.ps1 -Top 0
PS_EXIT=0
전체 finding 507
```

이번 migration에 새로 연결된 finding은 예상한 G15 한 건이다.

```text
G15  0176 CONTRACT_NOT_FOUND
```

`602020`의 DocumentType·H1·UTF-8/BOM/LF 관련 신규 finding은 없다. 그 밖의 신규 finding은 관측되지 않았다.

#### §12.5.5 RG-F7 — 수기 결제 승인의 근거가 정의되지 않았다

`flush_offline_queue`가 `RECORD_MANUAL_PAYMENT` action으로 APPROVAL 원장을 만든다. 이 경로는 provider 승인이 아니라 수기 결제이며 provider key도 `MANUAL-<queue item id>`다. 현금 결제에는 provider event가 없으므로 0174의 TOSS binding을 그대로 적용하면 정상 경로가 막힌다.

현재 함수와 queue writer는 staff 신원, store의 수기 결제 허용 정책, 금액 한도를 승인 근거로 검사하지 않는다. `0143`의 staff·claim·store 정책 3단계 패턴이 참고 대상이다. **별도 Runtime Gate 대상**으로 분리한다.

#### §12.5.6 RG-F8 — `record_van_transaction` APPROVAL writer를 검증할 수 없다

`record_van_transaction`은 APPROVAL writer이며 raw ACL에 PUBLIC EXECUTE가 있다. authenticated는 schema USAGE와 EXECUTE를 모두 가진다. 함수는 caller VAN payload로 raw event를 직접 생성하며 signature·schema·processing status를 검증하지 않는다.

그러나 `601505` §4 호출 금지 때문에 공격 재현과 수정 후 차단을 실행할 수 없다. `600023` §3.1 조건 1을 증명할 수 없으므로 **UNVERIFIABLE**로 분리한다. 호출 금지 해제가 선행돼야 별도 gate를 실행할 수 있다.

### §12.6 판정

```text
Primary exploit closure
  T1  PASS — confirm_payment 가짜 key DENY

구조적 binding
  T2  PASS — raw event 미실재 DENY
  T3  PASS — 다른 tenant raw event DENY
  T4  PASS — 정상 검증 event 승인 SUCCESS
  T5  PASS — 타 tenant claim 42501

범위 밖 회귀
  T6  PASS — RECORD_MANUAL_PAYMENT SUCCESS

호출 금지
  T7  UNVERIFIABLE — record_van_transaction 호출하지 않음

APPROVAL writer
  binding 적용  2
  범위 밖       1
  미검증        1
  미확인        0

catalog delta  전건 일치
RG-F7          별도 gate
RG-F8          UNVERIFIABLE
결론           RG-02 재개방 범위 PASS
```
