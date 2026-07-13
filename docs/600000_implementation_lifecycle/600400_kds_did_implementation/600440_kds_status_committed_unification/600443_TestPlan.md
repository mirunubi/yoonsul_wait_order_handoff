# 600443_TestPlan.md

Status: Draft
Lifecycle: TestPlan
Stage: 2 (Claude role)
Last Updated: 2026-07-13

Per §28, prose 설명만으로는 불충분 — 아래 모든 단계는 실제 실행 가능한 SQL이다. `600441_Overview.md`/`600442_Logic.md`(Stage 1.5, 13개 파일·46건, `0151` 포함 확정)를 기준으로 작성하며, 이번 문서 작성 시점에는 아직 어떤 `.sql` 파일도 수정되지 않았다. 실행 방식은 이번 세션에서 계속 써온 대로 로컬 Supabase Docker 컨테이너 직접 접속이다(`docker exec -i supabase_db_yoonsul_wait_order_handoff psql -U postgres -d postgres`, 클라우드/자격증명 불필요).

테스트용 tenant/store는 이 프로젝트에서 이미 쓰이는 시드 값 `00000000-0000-0000-0000-000000000001`(tenant)/`00000000-0000-0000-0000-000000000002`(store)를 사용한다.

## 0. 실행 순서 (요구사항 명시 대응)

`600442_Logic.md` §7 Open Item 3(`0028`/`0039` 원자성)과 별개로, 이번 배치 전체의 적용 순서는 다음으로 고정한다 — 순서를 바꾸면 중간 상태에서 §5(0070 base+wrapper)와 동일한 종류의 불일치가 다른 조합에서도 재현될 수 있다:

1. **제약 변경**: `chk_kds_status` `DROP CONSTRAINT` + `ADD CONSTRAINT`(`600442_Logic.md` §3) — 데이터 0건이므로 UPDATE 마이그레이션 없이 바로 적용.
2. **인덱스 재생성**: `idx_kds_tickets_store_zone`, `idx_kds_tickets_device` `DROP INDEX` + `CREATE INDEX`(§3).
3. **함수 재실행**: 13개 파일 중 실제 함수 본문이 있는 것 전부(`600442_Logic.md` §3.1 표 순서 그대로) — `0070`은 반드시 `bootstrap_app()`(base) 먼저, `bootstrap_kds_app()`(wrapper) 나중.
4. **데이터 기반 검증**: 아래 §2-§6.

1→2→3 순서가 중요한 이유: 함수 재실행(3) 이전에 제약(1)이 먼저 바뀌어 있어야, 재실행된 함수가 `'COMMITTED'`로 INSERT/UPDATE를 시도할 때 제약 위반 없이 통과한다 — 순서가 뒤바뀌면(함수를 먼저 고치고 제약을 나중에 바꾸면) 그 사이 구간에서 재실행된 함수가 실제로는 존재하지 않는 값을 쓰려다 매번 제약 위반으로 실패하는 상태가 된다.

## 1. `chk_kds_status` 제약 검증 — `'COMMITTED'` 성공, `'READY_TO_COMMIT'` 실패

**전제**: 이 섹션은 §0의 순서 1(제약 변경)이 이미 적용된 이후에 실행한다.

### 1.1 `'COMMITTED'` — 성공해야 함

```sql
BEGIN;
with new_order as (
  insert into catchmenu_pos.orders (
    tenant_id, store_id, order_number, business_day
  ) values (
    '00000000-0000-0000-0000-000000000001',
    '00000000-0000-0000-0000-000000000002',
    'TEST-CONSTRAINT-COMMITTED', current_date
  )
  returning id
)
insert into catchmenu_kds.kds_tickets (
  tenant_id, store_id, order_id, ticket_number, kds_status,
  menu_name_snapshot, business_day
)
select
  '00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000002',
  id, 'T-COMMITTED-001', 'COMMITTED', 'Test Menu', current_date
from new_order
returning kds_status;
ROLLBACK;
```

기대 결과: `INSERT 0 1` 성공, `kds_status = 'COMMITTED'` 반환. 에러 없음.

### 1.2 `'READY_TO_COMMIT'` — 실패해야 함(제약 위반)

```sql
BEGIN;
with new_order as (
  insert into catchmenu_pos.orders (
    tenant_id, store_id, order_number, business_day
  ) values (
    '00000000-0000-0000-0000-000000000001',
    '00000000-0000-0000-0000-000000000002',
    'TEST-CONSTRAINT-STALE', current_date
  )
  returning id
)
insert into catchmenu_kds.kds_tickets (
  tenant_id, store_id, order_id, ticket_number, kds_status,
  menu_name_snapshot, business_day
)
select
  '00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000002',
  id, 'T-STALE-001', 'READY_TO_COMMIT', 'Test Menu', current_date
from new_order;
ROLLBACK;
```

기대 결과: `ERROR: new row for relation "kds_tickets" violates check constraint "chk_kds_status"`. 이 에러가 나야 정상(구 상태값이 더 이상 허용되지 않음을 증명) — 에러 없이 성공하면 제약 변경이 실제로 적용되지 않은 것이므로 FAIL.

## 2. 부분 인덱스 재생성 확인 — 정의만 확인, explain plan은 선택 사항

**전제**: §0 순서 2(인덱스 재생성)가 적용된 이후.

```sql
select indexname, indexdef
from pg_indexes
where schemaname = 'catchmenu_kds'
  and indexname in ('idx_kds_tickets_store_zone', 'idx_kds_tickets_device');
```

기대 결과: 두 인덱스 정의(`indexdef`, 내부적으로 `pg_get_indexdef()`와 동일 출력) 모두 `kds_status = ANY (ARRAY['COMMITTED'::text, ...]))` 또는 `kds_status = 'COMMITTED'::text` 형태로 `COMMITTED`를 포함하고 `READY_TO_COMMIT`을 포함하지 않아야 한다.

**explain plan 확인은 선택 사항으로 남긴다**: `catchmenu_kds.kds_tickets`가 현재 데이터 0건이므로(`600442_Logic.md` §2), 플래너가 실제로 이 부분 인덱스를 스캔 경로로 선택하는지는 이번 시점에는 신뢰성 있게 관찰하기 어렵다(빈 테이블/소량 데이터에서는 시퀀셜 스캔이 더 저렴하다고 판단될 수 있음). 인덱스 **정의**가 올바른지 확인하는 것으로 이번 배치의 검증 목적은 충분하다 — 실제 스캔 경로 확인은 운영 데이터가 쌓인 뒤 별도로 관찰한다(참고용으로만, PASS/FAIL 판정에 포함하지 않음):

```sql
explain select * from catchmenu_kds.kds_tickets
where store_id = '00000000-0000-0000-0000-000000000002'
  and kitchen_zone = 'GRILL'
  and kds_status in ('COMMITTED', 'COOKING');
```

## 3. `0028`-`0039` 짝 테스트 — `commit_kds_ticket()` 실행 결과를 `bulk_commit_kds_tickets()`가 정확히 카운트하는지

**전제**: §0 순서 3에서 `commit_kds_ticket()`(`0028`)과 `bulk_commit_kds_tickets()`(`0039`)가 모두 재실행된 이후.

`bulk_commit_kds_tickets()`는 실행 전 `payment_ledger.kds_release_authorized = true` (`ledger_status = 'APPROVED'`)를 요구한다 — 이 선행 조건까지 포함한 전체 체인(`orders` → `payment_intents` → `payment_ledger` → `kds_tickets` 3건)을 구성한다. 3건 중 2건은 `conditions_met`이 이미 완전히 충족(→ `COMMITTED` 기대), 1건은 `payment_confirmed = false`로 미충족(→ `CAPACITY_CHECKING` 유지 기대) 상태로 설계해, 단순 전원-성공 케이스가 아니라 **분기 결과를 실제로 구분해서 세는지**까지 검증한다.

```sql
BEGIN;

with new_order as (
  insert into catchmenu_pos.orders (
    tenant_id, store_id, order_number, business_day
  ) values (
    '00000000-0000-0000-0000-000000000001',
    '00000000-0000-0000-0000-000000000002',
    'TEST-PAIRING-001', current_date
  )
  returning id
),
new_intent as (
  insert into catchmenu_payment.payment_intents (
    tenant_id, store_id, order_id, payment_method, payment_channel,
    requested_amount, provider_type, idempotency_key, business_day
  )
  select
    '00000000-0000-0000-0000-000000000001',
    '00000000-0000-0000-0000-000000000002',
    id, 'CARD', 'COUNTER_CARD', 15000, 'TOSS_PAYMENTS',
    'test-pairing-001-idem', current_date
  from new_order
  returning id, order_id
),
new_ledger as (
  insert into catchmenu_payment.payment_ledger (
    tenant_id, store_id, order_id, intent_id, ledger_entry_type,
    ledger_status, approved_amount, net_amount, provider_type,
    business_day, kds_release_authorized
  )
  select
    '00000000-0000-0000-0000-000000000001',
    '00000000-0000-0000-0000-000000000002',
    order_id, id, 'APPROVAL', 'APPROVED', 15000, 15000,
    'TOSS_PAYMENTS', current_date, true
  from new_intent
  returning order_id
)
insert into catchmenu_kds.kds_tickets (
  tenant_id, store_id, order_id, ticket_number, kds_status,
  menu_name_snapshot, kitchen_zone, conditions_met, business_day
)
select
  '00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000002',
  order_id, t.ticket_number, 'CAPACITY_CHECKING', 'Test Menu',
  'PAIRING_TEST_ZONE', t.conditions, current_date
from new_ledger, (values
  ('T-PAIR-001', '{"arrived": true, "table_confirmed": true, "payment_confirmed": true}'::jsonb),
  ('T-PAIR-002', '{"arrived": true, "table_confirmed": true, "payment_confirmed": true}'::jsonb),
  ('T-PAIR-003', '{"arrived": true, "table_confirmed": true, "payment_confirmed": false}'::jsonb)
) as t(ticket_number, conditions);

-- 실행: bulk_commit_kds_tickets
select catchmenu_kds.bulk_commit_kds_tickets(
  p_tenant_id := '00000000-0000-0000-0000-000000000001'::uuid,
  p_store_id := '00000000-0000-0000-0000-000000000002'::uuid,
  p_order_id := (select order_id from catchmenu_kds.kds_tickets where ticket_number = 'T-PAIR-001')
);

-- 독립 재확인: RPC의 자체 보고(committed_count/pending_count)를 신뢰하지 않고 실제 테이블 상태로 재검증
select kds_status, count(*)
from catchmenu_kds.kds_tickets
where ticket_number like 'T-PAIR-%'
group by kds_status
order by kds_status;

ROLLBACK;
```

기대 결과:
- `bulk_commit_kds_tickets()` 반환 jsonb: `committed_count = 2`, `pending_count = 1`, `skipped_count = 0`, `message_code = 'partial_tickets_committed'`.
- 독립 재확인 쿼리: `COMMITTED` 2건, `CAPACITY_CHECKING` 1건 — **RPC의 자체 보고와 실제 테이블 상태가 일치**해야 한다. 만약 `0028`(commit_kds_ticket)만 고쳐지고 `0039`(bulk_commit_kds_tickets)의 L80/L97 비교식이 여전히 `'READY_TO_COMMIT'`을 찾고 있다면, 실제 테이블은 `COMMITTED` 2건인데 RPC 반환값은 `committed_count = 0`으로 나온다 — 바로 이 불일치가 `600442_Logic.md` §4.6이 경고한 실패 시나리오다.

## 4. `0070` base+wrapper 짝 확인 — 두 방향의 부분 적용 실패 시나리오 포함

**전제**: §0 순서 3에서 `bootstrap_app()`(base)과 `bootstrap_kds_app()`(wrapper)가 모두 재실행된 이후.

### 4.1 소스/라이브 페어 체크 — 두 함수 모두 `READY_TO_COMMIT` 잔존 여부 확인

`600442_Logic.md` §4.10이 지적한 "base만 고치고 wrapper 놓침" / "wrapper만 고치고 base 놓침" 두 실패 시나리오는, 실제로 한쪽 함수를 의도적으로 미적용 상태로 되돌려 재현하기보다 — 라이브 함수 정의 자체를 직접 검사해 **두 값이 모두 `false`(둘 다 클린)여야만 PASS**로 판정하는 boolean pair-check로 검증한다. 이렇게 하면 실제로 한쪽만 적용된 상태에서 이 쿼리를 돌렸을 때 정확히 어느 쪽이 문제인지도 함께 드러난다(둘 중 하나만 `true`로 나오면 그게 바로 놓친 쪽):

```sql
select
  pg_get_functiondef('catchmenu_common.bootstrap_app(uuid,uuid,uuid,text,text,text,text,text,text)'::regprocedure) like '%READY_TO_COMMIT%' as base_still_stale,
  pg_get_functiondef('catchmenu_common.bootstrap_kds_app(uuid,uuid,uuid,text,text,text,text)'::regprocedure) like '%READY_TO_COMMIT%' as wrapper_still_stale;
```

기대 결과: `base_still_stale = false`, `wrapper_still_stale = false` 둘 다. 어느 한쪽이라도 `true`이면 FAIL — 그 자체가 "base만 고치고 wrapper 놓침"(`wrapper_still_stale = true`) 또는 "wrapper만 고치고 base 놓침"(`base_still_stale = true`) 시나리오가 실제로 발생했다는 증거다.

### 4.2 기능 테스트 — `bootstrap_kds_app()` 호출 시 `v_base` 간접 경로와 자체 쿼리 경로 모두 `COMMITTED` 기준으로 동작하는지

```sql
BEGIN;

with new_order as (
  insert into catchmenu_pos.orders (
    tenant_id, store_id, order_number, business_day
  ) values (
    '00000000-0000-0000-0000-000000000001',
    '00000000-0000-0000-0000-000000000002',
    'TEST-BOOTSTRAP-001', current_date
  )
  returning id
)
insert into catchmenu_kds.kds_tickets (
  tenant_id, store_id, order_id, ticket_number, kds_status,
  menu_name_snapshot, kitchen_zone, business_day
)
select
  '00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000002',
  id, 'T-BOOT-001', 'COMMITTED', 'Test Menu', 'BOOTSTRAP_TEST_ZONE', current_date
from new_order;

select catchmenu_common.bootstrap_kds_app(
  p_tenant_id := '00000000-0000-0000-0000-000000000001'::uuid,
  p_store_id := '00000000-0000-0000-0000-000000000002'::uuid,
  p_device_id := gen_random_uuid(),
  p_kitchen_zone := 'BOOTSTRAP_TEST_ZONE'
);

ROLLBACK;
```

기대 결과: 응답 성공(`v_base`를 통한 `bootstrap_app()` 간접 호출 경로가 정상 완료), 그리고 `bootstrap_kds_app()` 자체의 티켓 목록 조회 결과에 방금 만든 `COMMITTED` 티켓이 포함되며 정렬 순서상 `COOKING` 바로 다음 우선순위(`case ... when 'COMMITTED' then 1`)로 나타나야 한다 — `READY_TO_COMMIT` 리터럴 잔존 시 이 티켓이 `else 4`(최하위) 순위로 밀려나거나, 필터 조건(L301 계열)에서 아예 누락될 수 있다.

## 5. `0151` `check_kds_capacity()` — 오늘 확립된 `UNASSIGNED` 테스트 케이스를 `COMMITTED` 기준으로 재검증

**전제**: §0 순서 3에서 `check_kds_capacity()`가 재실행된 이후. `600413_TestPlan.md` §1.2가 `600410` 워크패킷에서 이미 확립한 것과 동일한 구조의 테스트를, 이번엔 `'COMMITTED'` 상태값으로 재현한다.

```sql
BEGIN;

with new_order as (
  insert into catchmenu_pos.orders (
    tenant_id, store_id, order_number, business_day
  ) values (
    '00000000-0000-0000-0000-000000000001',
    '00000000-0000-0000-0000-000000000002',
    'TEST-UNASSIGNED-COMMITTED', current_date
  )
  returning id
)
insert into catchmenu_kds.kds_tickets (
  tenant_id, store_id, order_id, ticket_number, kds_status,
  menu_name_snapshot, kitchen_zone, business_day
)
select
  '00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000002',
  id, 'T-UNASSIGNED-' || gs, 'COMMITTED', 'Test Menu', null, current_date
from new_order, generate_series(1, 8) as gs;  -- kitchen_zone = null, threshold(8) 이상, 전부 COMMITTED

select catchmenu_kds.check_kds_capacity(
  p_tenant_id := '00000000-0000-0000-0000-000000000001'::uuid,
  p_store_id := '00000000-0000-0000-0000-000000000002'::uuid
);

ROLLBACK;
```

기대 결과: `data.zones` 배열에 `kitchen_zone: 'UNASSIGNED'` 항목이 존재하고 `cooking_count = 8`, `capacity_ok = false`, 매장 전체 `data.is_overloaded = true`. `READY_TO_COMMIT` 리터럴이 잔존했다면 이 8건이 전혀 카운트되지 않아(`cooking_count = 0`, `capacity_ok = true`) `600442_Logic.md` §4.13이 경고한 silent undercount가 그대로 재현됐을 것 — 이번 테스트가 그 결함이 실제로 해소됐는지 직접 증명한다.

## 6. Boundary / Post-run Check

```powershell
git status --short
git diff --stat -- sql/migrations/0016_create_kds_tickets.sql sql/migrations/0024_create_store_bootstrap_rpc.sql sql/migrations/0026_create_order_rpc.sql sql/migrations/0028_create_kds_capacity_commit_rpc.sql sql/migrations/0029_create_kds_cooking_rpc.sql sql/migrations/0039_create_kds_bulk_commit_rpc.sql sql/migrations/0044_create_menu_management_rpc.sql sql/migrations/0045_create_daily_summary_rpc.sql sql/migrations/0051_create_pre_order_rpc.sql sql/migrations/0070_create_flutter_bootstrap_rpc.sql sql/migrations/0081_create_customer_app_rpc.sql sql/migrations/0143_add_no_payment_kds_release_policy.sql sql/migrations/0151_create_check_kds_capacity_function.sql
```

기대 결과: 정확히 이 13개 파일만 diff가 있어야 한다. `sql/migrations/0015_create_payment_reconciliation.sql`, `sql/migrations/0121_create_security_pipeline.sql`, `0098`/`0099`/`0106`/`0116`(이미 클린, `600441_Overview.md` §4), 900시리즈 문서, `600417_Audit.md` 등 그 외 어떤 파일도 diff에 나타나면 안 된다.

```sql
select filename, checksum, success
from catchmenu_meta.migration_history
where filename like any (array[
  '0016_%','0024_%','0026_%','0028_%','0029_%','0039_%','0044_%',
  '0045_%','0051_%','0070_%','0081_%','0143_%','0151_%'
])
order by filename;
```

기대 결과: 13개 파일 전부 `success = true`, `checksum`은 소스 파일을 CRLF 정규화 후 SHA-256 재계산한 값과 정확히 일치해야 한다(§24 절차, `600442_Logic.md` §3.1).

## 7. Open Items (→ `600444_ChangeContract.md`로 이월)

1. `600417_Audit.md`로의 교차 참조 필요성 — `600442_Logic.md` §7 Open Item 2에서 이미 확인, 이번 change의 Allowed Files 목록 밖이므로 별도 처리 필요.
2. `0028`/`0039`의 원자성 보장 방식 — 같은 트랜잭션 안에서 재실행할지, 순서만 보장하면 되는지 여전히 미확정(`600442_Logic.md` §7 Open Item 3).
3. §2의 explain plan 확인은 데이터 0건 환경의 한계로 참고용에 그친다 — 운영 데이터 축적 후 재관찰 필요(신규 Open Item은 아니며, 이번 TestPlan 설계상의 알려진 제약으로 기록).
