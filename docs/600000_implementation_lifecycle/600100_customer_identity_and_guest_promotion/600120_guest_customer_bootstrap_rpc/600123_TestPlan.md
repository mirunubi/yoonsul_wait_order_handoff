# 600123_TestPlan.md

Status: Draft
Lifecycle: TestPlan
Stage: 2 (Claude role — compressed with Stage 1.5 this batch, see `600111_Overview.md`/`600121_Overview.md` 저자 표기 원칙)
Owner: TBD
Last Updated: 2026-07-11

Per §28, prose 설명만으로는 불충분 — 아래 모든 단계는 실제 실행 가능한 명령어다. `600122_Logic.md` §0 확인 사항(DO UPDATE SET에 `is_guest` 미포함)이 실제 코드에서 지켜지는지도 §2에서 별도로 검증한다.

## 1. 로컬 적용 (Stage 3 승인 후)

```powershell
cd D:\workspace\yoonsul_wait_order_handoff
python tools/apply_migrations.py
```
기대 결과: `0149`(번호는 Stage 3 재확인)가 `APPLY ... OK`, 기존 148개 파일 전부 `OK (already applied, checksum matches)`.

## 2. 헬퍼 함수 단독 테스트

### 2.1 신규 phone_hash → 신규 row 생성

```sql
select catchmenu_store.get_or_create_guest_customer(
  p_tenant_id := '<test tenant_id>',
  p_phone_hash := '<신규 phone_hash>'
);
-- 반환된 uuid를 v_id_1로 기록

select id, is_guest, phone_hash from catchmenu_store.customers where id = '<v_id_1>';
-- 기대: is_guest = true, phone_hash = 넘긴 값
```

### 2.2 같은 phone_hash 재호출 → 같은 customer_id 반환, row 안 늘어남

```sql
select catchmenu_store.get_or_create_guest_customer(
  p_tenant_id := '<동일 tenant_id>',
  p_phone_hash := '<2.1과 동일 phone_hash>'
);
-- 기대: v_id_1과 정확히 동일한 uuid 반환

select count(*) from catchmenu_store.customers where tenant_id = '<동일 tenant_id>' and phone_hash = '<동일 phone_hash>';
-- 기대: 1 (2번 호출했지만 row는 1개)
```

### 2.3 이미 `is_guest=false`인 회원이 같은 phone_hash로 헬퍼 호출 시 `is_guest` 유지 확인 (`600122_Logic.md` §0 우려 검증)

```sql
-- 사전 준비: 2.1의 row를 회원가입 완료 상태로 전환
update catchmenu_store.customers set is_guest = false, display_name = 'Test Member' where id = '<v_id_1>';

-- 같은 phone_hash로 헬퍼 재호출 (예: 같은 번호로 다시 대기 등록하는 상황 재현)
select catchmenu_store.get_or_create_guest_customer(
  p_tenant_id := '<동일 tenant_id>',
  p_phone_hash := '<동일 phone_hash>'
);

select id, is_guest, display_name from catchmenu_store.customers where id = '<v_id_1>';
-- 기대: is_guest = false 그대로 유지 (true로 되돌아가지 않음), display_name도 유지
```

이 케이스가 실패하면(즉 `is_guest`가 다시 `true`로 바뀌면) `600122_Logic.md` §2의 실제 배포된 함수 코드가 초안과 다르게 `is_guest`를 SET 절에 포함해 배포된 것이므로, 초안이 아니라 실제 적용된 `0149`(또는 해당 번호) 파일 자체를 다시 확인해야 한다.

## 3. `register_waiting()` — `p_customer_id` 생략 호출 시 헬퍼 자동 연동 확인

```sql
select catchmenu_pos.register_waiting(
  p_tenant_id := '<test tenant_id>',
  p_store_id := '<test store_id>',
  p_session_type := 'WAITING',
  p_guest_count := 2,
  p_guest_locale := 'ko',
  p_phone_hash := '<신규 phone_hash 2>'
  -- p_customer_id 생략
);
-- 반환된 session_id로 확인

select customer_id from catchmenu_pos.order_sessions where id = '<반환 session_id>';
-- 기대: null이 아님 — 헬퍼가 내부에서 채운 customer_id

select is_guest from catchmenu_store.customers where id = (select customer_id from catchmenu_pos.order_sessions where id = '<반환 session_id>');
-- 기대: true (신규 게스트)
```

## 4. `bootstrap_customer_app_v2()` — 동일 패턴 확인

```sql
select catchmenu_store.bootstrap_customer_app_v2(
  p_tenant_id := '<test tenant_id>',
  p_store_id := '<test store_id>',
  p_phone_hash := '<신규 phone_hash 3>'
  -- p_customer_id 생략
);
```
기대 결과: `600112_Logic.md` §6/`600113_TestPlan.md` §4가 지적했던 "customer_id 생략 시 빈 결과" 문제가 해소되어, 반환 JSON의 `customer`/`active_waiting` 필드가 게스트 데이터로 정상 채워짐 (더 이상 빈 값이 아님 — `600122_Logic.md` §3.2의 "근본 해소" 주장 검증).

## 5. 완전 익명(phone_hash 없음) — 매번 신규 row 생성 확인 (Human 결정 #4)

```sql
select catchmenu_store.get_or_create_guest_customer(p_tenant_id := '<test tenant_id>');
select catchmenu_store.get_or_create_guest_customer(p_tenant_id := '<test tenant_id>');
-- 두 호출의 반환 uuid가 서로 달라야 함 (dedupe 키 없음, Human 결정 #4)

select count(*) from catchmenu_store.customers where tenant_id = '<test tenant_id>' and phone_hash is null and is_guest = true;
-- 이번 테스트로 생성된 익명 row 수만큼 증가 확인
```

## 6. 회귀 확인 — `600113_TestPlan.md` §3/§4가 패치 후에도 통과하는지

`600113_TestPlan.md` §3(`register_waiting()` 실행 테스트, `p_phone_hash`로 신규 게스트 생성)과 §4(`bootstrap_customer_app_v2()` 실행 테스트, 명시적 `p_customer_id` 전달)를 **패치 적용 후 그대로 재실행**한다:

```sql
-- 600113 §3 재실행 (0115 패치 후에도 동일하게 성공해야 함)
-- 600113 §4 재실행 (0116 패치 후에도 동일하게 성공해야 함, 단 이번엔
--   §4의 "네거티브 컨트롤"(p_customer_id 생략 시 빈 결과)이 더 이상
--   재현되지 않아야 정상 — 이것이 이번 patch의 목적이므로 "회귀"가 아니라
--   "의도된 동작 변경"으로 기록할 것)
```

**주의**: `600113_TestPlan.md` §4의 네거티브 컨트롤 결과가 이번 patch로 뒤집히는 것은 버그가 아니라 `600122_Logic.md` §3.2에서 명시한 의도된 개선이다 — `600101_ChangeHistory.md` 갱신 시 이 사실을 명확히 구분해서 기록해야 오해가 없다.

## 7. `0148`에 이미 적용된 스키마와의 정합성 재확인

```sql
select confdeltype from pg_constraint where conname = 'order_sessions_customer_id_fkey';
-- 기대: n (SET NULL, 0148에서 확정된 값 그대로, 이번 change로 바뀌지 않음)
```
