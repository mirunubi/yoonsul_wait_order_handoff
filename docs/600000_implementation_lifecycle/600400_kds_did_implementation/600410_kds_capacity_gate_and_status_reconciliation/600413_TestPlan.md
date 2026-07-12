# 600413_TestPlan.md

Status: Draft
Lifecycle: TestPlan
Stage: 2 (Claude role)
Owner: TBD
Last Updated: 2026-07-13

Per §28, prose 설명만으로는 불충분 — 아래 모든 단계는 실제 실행 가능한 SQL/명령이다. `600412_Logic.md`(Stage 1.5)는 `evaluate_kds_capacity()`를 zone 구분 없이 1회 호출하는 단순 wrapper로 설계했으나, 이번 지시의 Human 결정은 **zone별로 순회하며 개별 결과 배열 + 전체 집계를 반환**하는 더 상세한 설계를 확정했다 — 이 TestPlan은 이번 지시의 확정 설계를 기준으로 작성하며, `600412_Logic.md`와의 설계 차이는 §0에 기록하고 그 문서 자체는 이번 턴에 수정하지 않는다(지시 범위 밖).

## §0 설계 확정 사항 재확인 (Human 결정, 재논의 금지)

- `check_kds_capacity(p_tenant_id, p_store_id)`는 zone 목록을 얻어 각 zone에 대해 `evaluate_kds_capacity(p_tenant_id, p_store_id, p_zone)`를 호출한다.
- **zone 목록을 얻는 기존 방법 확인 결과**: `catchmenu_store.store_zones` 같은 별도 마스터 테이블은 존재하지 않는다(이번 턴 재확인, 매치 0건). 대신 `0070_create_flutter_bootstrap_rpc.sql`(L531-539)이 이미 쓰고 있는 패턴 — `catchmenu_kds.kds_tickets`에서 `distinct kitchen_zone`을 집계하는 방식 — 이 이 프로젝트의 "zone 목록을 얻는 기존 방법"이다. `evaluate_kds_capacity()` 자체의 활성 티켓 기준(`kds_status not in ('COMPLETED','CANCELLED','SERVED')`)과 일관되게, zone 목록도 같은 활성 조건으로 도출한다(0070은 `business_day` 필터를 추가로 걸지만, 용량 게이트는 날짜 경계를 넘나드는 활성 티켓도 포함해야 하므로 `business_day` 필터는 넣지 않는다).
- **집계 규칙**(600412_Logic.md에 아직 명시되지 않아 이번 지시 취지에 따라 확정): 하나의 zone이라도 `capacity_ok = false`이면 매장 전체 `is_overloaded = true`(보수적/안전 우선 규칙 — 과부하 자동거절이라는 용도상, 일부 zone만 넘쳐도 매장 전체적으로 주의가 필요하다고 보는 것이 타당). 전체 zone이 `capacity_ok = true`일 때만 매장 전체 `is_overloaded = false`.
- `release_kds_after_payment()` 등 8개 파일의 기존 호출부는 **수정 불필요** — `600411_Overview.md`에서 이미 확인했듯 이 시그니처(`p_tenant_id`, `p_store_id` 2개 named param)로 이미 호출하고 있었으므로 함수가 생기면 즉시 연결된다.
- **`UNASSIGNED` 그룹 처리(2026-07-13 확정, Human 결정)**: `kitchen_zone`이 `null`인 티켓은 "UNASSIGNED"라는 가상 구역명으로 취급해 순회에 포함한다(`600412_Logic.md` §2 갱신). `store_settings.kds_capacity_threshold_per_zone`이 구역별 개별 설정이 아니라 매장 전체 단일값임을 재확인했으므로, `UNASSIGNED`에도 별도 설정 없이 동일 임계값(`8`)을 적용한다. **구현 방식 정정**: `evaluate_kds_capacity(p_kitchen_zone := 'UNASSIGNED')`로 위임하면 실제 `NULL` 컬럼값과 리터럴 문자열이 등호 비교로 매치되지 않아 항상 0건으로 집계되므로(`evaluate_kds_capacity()` 편집 금지 대상), wrapper 내부에서 `UNASSIGNED` 그룹만 `kitchen_zone is null` 직접 카운트로 별도 처리한다(§1.2에서 검증).

## 1. `check_kds_capacity()` 단독 테스트 — 여러 zone에 티켓 분산 배치

```sql
-- 준비: 서로 다른 zone(kitchen_zone)에 티켓을 분산 배치
-- (테스트 tenant/store 기준값은 이 프로젝트에서 이미 쓰이는 00000000-...-0001/0002 사용)
insert into catchmenu_kds.kds_tickets (
  tenant_id, store_id, order_id, kitchen_zone, kds_status
) values
  ('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', gen_random_uuid(), 'GRILL', 'COOKING'),
  ('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', gen_random_uuid(), 'GRILL', 'READY_TO_COMMIT'),
  ('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', gen_random_uuid(), 'FRY', 'HOLD'),
  ('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', gen_random_uuid(), 'FRY', 'COOKING');

select catchmenu_kds.check_kds_capacity(
  p_tenant_id := '00000000-0000-0000-0000-000000000001'::uuid,
  p_store_id := '00000000-0000-0000-0000-000000000002'::uuid
);
```

기대 결과: `data.zones`에 `GRILL`, `FRY` 2개 항목(각각 `evaluate_kds_capacity()`의 원본 필드 `cooking_count`/`hold_count`/`ready_count`/`capacity_ok`/`threshold`/`kitchen_zone` 포함), `data.is_overloaded`는 두 zone 모두 `threshold=8` 미만이므로 `false`.

### 1.1 경계값 — 한 zone만 과부하일 때 전체 `is_overloaded`가 반영되는지

```sql
-- GRILL zone에 threshold(8) 이상 COOKING 티켓 채우기
insert into catchmenu_kds.kds_tickets (
  tenant_id, store_id, order_id, kitchen_zone, kds_status
)
select
  '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002',
  gen_random_uuid(), 'GRILL', 'COOKING'
from generate_series(1, 8);

select catchmenu_kds.check_kds_capacity(
  p_tenant_id := '00000000-0000-0000-0000-000000000001'::uuid,
  p_store_id := '00000000-0000-0000-0000-000000000002'::uuid
);
```

기대 결과: `data.zones` 배열에서 `GRILL` 항목의 `capacity_ok = false`, `FRY` 항목은 여전히 `capacity_ok = true`, **매장 전체 `data.is_overloaded = true`**(§0의 "하나라도 초과 시 전체 false" 규칙 검증).

### 1.2 `kitchen_zone`이 `null`인 티켓 — `UNASSIGNED`로 집계되어 용량 판정에 포함되는지

```sql
-- 신규 tenant/store 조합으로 깨끗한 상태에서 테스트(§1/§1.1의 GRILL/FRY 잔여 데이터와 섞이지 않게)
insert into catchmenu_kds.kds_tickets (
  tenant_id, store_id, order_id, kitchen_zone, kds_status
)
select
  '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002',
  gen_random_uuid(), null, 'COOKING'
from generate_series(1, 8);  -- kitchen_zone = null, threshold(8) 이상

select catchmenu_kds.check_kds_capacity(
  p_tenant_id := '00000000-0000-0000-0000-000000000001'::uuid,
  p_store_id := '00000000-0000-0000-0000-000000000002'::uuid
);
```

기대 결과: `data.zones` 배열에 `kitchen_zone: 'UNASSIGNED'` 항목이 실제로 존재하고 `cooking_count = 8`(또는 §1/§1.1 잔여 데이터가 남아있다면 그만큼 추가), `capacity_ok = false`, **매장 전체 `data.is_overloaded = true`**(UNASSIGNED 그룹만으로도 과부하가 반영됨을 확인). `evaluate_kds_capacity()`에 리터럴 `'UNASSIGNED'`를 그대로 넘기는 구현이었다면 이 그룹이 항상 `cooking_count = 0`, `capacity_ok = true`로 나왔을 것이므로, 이 테스트가 **바로 그 구현 오류를 잡아내는 핵심 케이스**다.

## 2. `release_kds_after_payment()` 재실행 — 정확히 한 단계 전진했는지 확인

**주의**: `kds_status = 'COMMITTED'`는 `chk_kds_status` 제약에 없는 값이므로(다른 결함, 이번 change 범위 밖 — 별도로 이미 분석됨), 이번 재실행은 **그 지점에서 실패하는 것이 기대 결과**다. 이번 TestPlan이 검증하는 것은 "이전에는 `check_kds_capacity() does not exist`에서 즉시 실패했는데, 이번 수정 후에는 그 지점을 통과하고 `chk_kds_status` 위반에서 실패하는가"이다 — 즉 정확히 한 단계 전진했는지가 핵심이다.

```sql
select catchmenu_kds.release_kds_after_payment(
  p_tenant_id := '00000000-0000-0000-0000-000000000001'::uuid,
  p_store_id := '00000000-0000-0000-0000-000000000002'::uuid,
  p_ledger_id := '<유효한 payment_ledger.id 테스트 값>'::uuid
  -- 실제 파라미터 목록은 0098의 함수 시그니처를 Stage 4에서 그대로 재확인
);
```

기대 결과(수정 전, 참고용): `ERROR: function catchmenu_kds.check_kds_capacity(...) does not exist`.

기대 결과(이번 수정 후): 위 에러는 더 이상 발생하지 않고, 대신 `ERROR: new row for relation "kds_tickets" violates check constraint "chk_kds_status"` 계열의 에러로 실패한다(`kds_status = 'COMMITTED'`가 허용 목록에 없기 때문). **이 에러로 바뀌는 것 자체가 이번 수정이 정확히 의도한 지점까지 진전했다는 증거**이며, 이 새로운 실패는 이번 change의 책임 범위가 아니다(§3 Open Items 이월).

## 3. `0099`의 `get_kds_realtime_state()`가 이번 신규 생성과 무관한지 재확인

```powershell
grep -n "check_kds_capacity" sql/migrations/0099_create_realtime_pipeline_rpc.sql
```

**재확인 결과(600411_Overview.md에서 이미 확인된 사실의 재검증): 무관하지 않다 — 직접 연관됨.** `0099_create_realtime_pipeline_rpc.sql`의 `catchmenu_kds.get_kds_realtime_state(...)` 함수 본문(L367에서 시작, 다음 함수는 L566) 안의 L464에서 `catchmenu_kds.check_kds_capacity(p_tenant_id :=, p_store_id :=)`를 직접 호출한다(`awk`로 함수 경계 재확인: L464가 L367~L565 범위 안에 있음). 따라서 이번 `check_kds_capacity()` 신규 생성은 `get_kds_realtime_state()`에도 **직접 영향을 준다** — "무관함을 확인"이 아니라 "직접 연관됨을 재확인"으로 결과가 정정된다.

```sql
select catchmenu_kds.get_kds_realtime_state(
  p_tenant_id := '00000000-0000-0000-0000-000000000001'::uuid,
  p_store_id := '00000000-0000-0000-0000-000000000002'::uuid
  -- 나머지 파라미터는 0099 시그니처를 Stage 4에서 재확인
);
```

기대 결과(수정 전): 동일하게 `check_kds_capacity does not exist`로 실패.
기대 결과(수정 후): 이 에러 없이 정상 응답(다른 stale 컬럼 문제가 없다면) — 단, `0099`에 다른 stale 컬럼 문제가 남아있을 수 있으므로(§3 Open Items), 이번 TestPlan은 "check_kds_capacity 관련 에러가 사라졌는지"까지만 확인 범위로 한정한다.

## 4. Open Items (→ `600414_ChangeContract.md`로 이월)

1. `chk_kds_status`가 `'COMMITTED'`를 허용하지 않는 문제(§2에서 재현 예정) — 이번 change 범위 밖, 다음 순서의 별도 결함으로 예고.
2. `0099`가 `get_kds_realtime_state()` 내부에서 `check_kds_capacity` 외에 다른 stale 컬럼 참조를 갖고 있는지는 이번 TestPlan에서 다루지 않음 — 실행 시 새로운 에러가 나오면 그 자체를 별도 결함으로 기록(§0 원칙: 결함 하나씩).
3. ~~§1의 집계 규칙이 `600412_Logic.md`에 반영되어 있지 않음~~ — **해결됨**: `600412_Logic.md` §2가 zone별 순회·집계 설계 및 `UNASSIGNED` 처리까지 동기화 완료.
4. **(신규, 이번 범위 밖) `UNASSIGNED` 티켓의 운영자 가시성 UX** — 구역 미지정 티켓 존재를 직원 앱/KDS 화면에서 알아볼 수 있게 하는 것은 이번 SQL 함수 신설 워크패킷 범위 밖 — 별도 후속 workpacket으로 이월(`600412_Logic.md` Open Question #6).
