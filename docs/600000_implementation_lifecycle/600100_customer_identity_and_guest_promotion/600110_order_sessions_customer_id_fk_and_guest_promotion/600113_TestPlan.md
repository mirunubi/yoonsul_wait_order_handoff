# 600113_TestPlan.md

Status: Draft
Lifecycle: TestPlan
Stage: 2 (Claude role — compressed with Stage 1.5 this batch, see `600111_Overview.md` 저자 표기 원칙)
Owner: TBD
Last Updated: 2026-07-11

Per §28, prose 설명만으로는 불충분 — 아래 모든 단계는 실제 실행 가능한 명령어다.

## 1. 로컬 적용

```powershell
cd D:\workspace\yoonsul_wait_order_handoff
python tools/apply_migrations.py
```
기대 결과: 신규 `0148_...sql`은 `APPLY ... OK`, 기존 147개 파일 전부 `OK (already applied, checksum matches)`. 체크섬 불일치가 하나라도 나오면 즉시 중단하고 원인 조사 — 조용히 넘어가지 않는다.

**사전 조건 확인 (§4의 로컬 out-of-band 상태 때문에 필수 추가)**:
```powershell
docker exec -i supabase_db_yoonsul_wait_order_handoff psql -U postgres -d postgres -t -A -c "SELECT confdeltype FROM pg_constraint WHERE conname = 'order_sessions_customer_id_fkey';"
```
적용 전 이 값이 `a`(NO ACTION)로 나오면, `0148`이 `ADD COLUMN IF NOT EXISTS`만으로는 FK의 `ON DELETE` 옵션을 재조정하지 못하므로 (컬럼은 이미 있어 스킵되고 제약은 안 바뀜), `0148`에 `ALTER TABLE ... DROP CONSTRAINT order_sessions_customer_id_fkey, ADD CONSTRAINT ... ON DELETE SET NULL` 구문이 반드시 포함되어야 한다 — 없으면 이 TestPlan의 §5 결과가 승인된 설계와 다르게 나온다.

## 2. 컬럼 직접 확인

```powershell
docker exec -i supabase_db_yoonsul_wait_order_handoff psql -U postgres -d postgres -t -A -c "SELECT column_name FROM information_schema.columns WHERE table_schema='catchmenu_pos' AND table_name='order_sessions' AND column_name IN ('customer_id','phone_hash');"
docker exec -i supabase_db_yoonsul_wait_order_handoff psql -U postgres -d postgres -t -A -c "SELECT column_name FROM information_schema.columns WHERE table_schema='catchmenu_store' AND table_name='customers' AND column_name='is_guest';"
docker exec -i supabase_db_yoonsul_wait_order_handoff psql -U postgres -d postgres -t -A -c "SELECT confdeltype FROM pg_constraint WHERE conname = 'order_sessions_customer_id_fkey';"
```
기대 결과: 첫 쿼리 2행(`customer_id`, `phone_hash`), 둘째 쿼리 1행(`is_guest`), 셋째 쿼리 `n`(SET NULL).

## 3. `register_waiting()` 실행 테스트 (0115)

기존 `customers`에 없는 신규 `p_phone_hash`로 호출. 기대 결과: 성공 (기존엔 "column does not exist" 실패), 반환된 `order_sessions.id`의 `customer_id`가 `is_guest=true`인 신규 `customers` row를 가리킴.

```sql
select id, customer_id, phone_hash from catchmenu_pos.order_sessions where id = '<returned session_id>';
select id, is_guest, phone_hash from catchmenu_store.customers where id = '<customer_id from above>';
```

## 4. `bootstrap_customer_app_v2()` 실행 테스트 (0116) — caller-contract 검증

3번의 게스트 `customer_id`를 `p_customer_id`로 명시 전달. 기대 결과: `if p_customer_id is not null`(0116 L185) 블록 실행, `active_waiting`에 3번 세션 반영.

네거티브 컨트롤 — 같은 게스트에 대해 `p_customer_id` 생략 호출. 기대 결과(버그 아님, 알려진 위험 확인용): `active_waiting` 비어있음 — `600112_Logic.md` §6의 caller-contract 위험이 실재함을 증명.

## 5. 게스트 → 회원 전환 시나리오 (Human 결정 #3, end-to-end)

```sql
-- a. 게스트 상태 확인
select id, is_guest, display_name, phone_hash from catchmenu_store.customers where id = '<customer_id>';
-- 기대: is_guest = true

-- b. 회원가입 시뮬레이션 (같은 phone_hash, 실제 정보로 채움)
update catchmenu_store.customers
set is_guest = false, display_name = 'Test Member', updated_at = now()
where id = '<same customer_id>';

-- c. order_sessions.customer_id가 그대로인지 확인 (merge/rewrite 없었는지 증명)
select customer_id from catchmenu_pos.order_sessions where id = '<session_id from step 3>';
-- 기대: step 3과 동일한 customer_id
```

## 6. `0082`/`0083` 정상 동작 확인 (이번 지시로 추가된 테스트 케이스)

`0082`(saas_billing_rpc, L906-908)와 `0083`(push_notification_rpc, L690 부근)은 이미 `order_sessions.customer_id`를 활성 참조하고 있었다 — 이번 migration은 그 컬럼을 실재하게 만드는 것뿐이므로, migration 적용 후 두 파일이 참조하는 함수가 실제로 정상 동작하는지 확인 필요.

```sql
-- 0082: 일일 고객 수 집계 함수 호출 (함수명은 실제 파일에서 재확인 후 대체)
-- 3번에서 만든 게스트 세션이 카운트에 정상 반영되는지 확인
select count(*) filter (where customer_id is not null),
       count(distinct c.id) filter (where c.created_at::date = current_date)
from catchmenu_pos.order_sessions os
left join catchmenu_store.customers c on c.id = os.customer_id
where os.store_id = '<test store_id>' and os.tenant_id = '<test tenant_id>';
-- 기대: 에러 없이 실행, 3번에서 만든 게스트가 카운트에 잡힘

-- 0083: 주문 알림 조회 시 os.customer_id join 정상 동작 확인
select o.id, o.order_number, os.customer_id
from catchmenu_pos.orders o
join catchmenu_pos.order_sessions os on os.id = o.session_id
where o.id = '<test order_id>';
-- 기대: 에러 없이 실행 (컬럼 부재로 인한 실패 없음)
```

## 7. 클라우드 pause 확인

```powershell
supabase projects list
```
`"ref":"upzthfwhtvazfftxnyfu"`의 `"status"`가 `"ACTIVE_HEALTHY"`인지 확인 — Stage 7 클라우드 배포 직전 반드시 재실행 (이전 턴 확인값은 그 시점 기준, 시간이 지나면 무효).

## 8. 클라우드 적용 + drift 재확인

```powershell
supabase db push --linked
supabase db diff --linked
```
**주의**: `sql/migrations/CHANGELOG.md` 2026-07-11 항목에서 이미 확인된 대로, `supabase db diff --linked`는 `supabase/migrations/`(CLI 네이티브, 이 프로젝트는 사실상 미사용) 기준 shadow DB와 비교하는 것으로 추정되며 `sql/migrations/`의 실제 147+1개 커스텀 마이그레이션과 직접 비교하는지는 불확실하다. "No schema changes found"가 나오더라도 그것만으로 로컬=클라우드 완전 동일을 증명하지 않는다는 점을 감안하고, 필요시 §2의 컬럼 직접 확인 쿼리를 클라우드 프로젝트에도 동일하게 실행해 교차 검증할 것.
