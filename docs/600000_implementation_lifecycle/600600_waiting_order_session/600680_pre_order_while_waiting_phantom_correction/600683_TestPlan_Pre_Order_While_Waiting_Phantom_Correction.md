# 600683 TestPlan — Pre-Order While Waiting Phantom Correction

- Workpacket: `600680_pre_order_while_waiting_phantom_correction`
- Stage: 5 (검증 계획)
- Depends on: [600681_Overview](600681_Overview_Pre_Order_While_Waiting_Phantom_Correction.md), [600682_Logic](600682_Logic_Pre_Order_While_Waiting_Phantom_Correction.md)
- Created: 2026-07-19

## §0. 전제 / 픽스처

- 테스트 테넌트/매장: `tenant_id = 00000000-0000-0000-0000-000000000001`, `store_id = 00000000-0000-0000-0000-000000000002`(시드 존재).
- 대상 함수: `catchmenu_pos.pre_order_while_waiting(uuid, uuid, uuid, jsonb, text, text)`.
- 세션 전제: `pre_order_while_waiting()`은 `session_status in ('WAITING','ARRIVAL_PENDING')`만 허용하므로, 테스트마다 그 상태의 `order_sessions` 픽스처를 새로 만든다(`session_type='WAITING'`, `wait_number` 부여).
- 메뉴 픽스처: `catchmenu_pos.menus`에 최소 1건 — `is_kds_required=true`, `menu_status='AVAILABLE'`, `kitchen_zone` 값 존재, `menu_code`/`price`/`estimated_minutes` 채워짐(order_items 스냅샷 컬럼 검증용).
- 카트 입력: 이 함수는 옵션을 `v_item->'options'`로 읽으므로(C2, 유지), 테스트 카트는 `[{"menu_id":"...","quantity":2,"options":[]}]` 형태.
- 실행 시점 기준: **정정(0168+) 적용 후**의 라이브 함수. §1은 정정 전 크래시를 참조로만 기술(정정 후 재현 안 됨을 확인).
- 격리: 모든 시나리오는 `begin; ... rollback;`으로 감싸 픽스처를 남기지 않는다. ACL(§6)은 `set local role`로 검증.

## §1. 정정 전 크래시 참조 (회귀 방지 기준선)

정정 전 함수는 다음 두 결함으로 실행이 불가능했다(설계 근거, 재현은 정정 전 스냅샷에서만 의미):
- `orders` INSERT의 `order_source` 컬럼 → `42703 undefined_column`.
- `order_type='TABLE'` → `chk_order_type` `23514 check_violation`.
- `order_items` INSERT의 `unit_price`/`subtotal`/`item_options`, `menu_code_snapshot` 누락 → `42703`/`23502`.
- `order_sessions` UPDATE의 `pre_order_amount` → `42703`.

**기대(정정 후):** 위 어떤 SQLSTATE도 발생하지 않는다.

## §2. Happy path — 정상 호출 성공 (크래시 없음 + 컬럼 정합)

절차:
1. WAITING 세션 픽스처 생성(wait_number=901).
2. `select catchmenu_pos.pre_order_while_waiting(tenant, store, :session_id, '[{"menu_id"::menu_id,"quantity":2,"options":[]}]'::jsonb, 'ko', 'test-600683-happy')`.
3. 반환 `success=true`, `order_id`/`order_number`/`kds_status='HOLD'` 확인.

검증(SELECT로 확인):
- `catchmenu_pos.orders`: 신규 1건, `order_type='DINE_IN'`(≠'TABLE'), `order_status='CONFIRMED'`, `session_id=:session_id`, `final_amount = price*2`. **`order_source` 컬럼 참조 없음**(컬럼 자체 부재이므로 INSERT가 성공했다는 것 자체가 증거).
- `catchmenu_pos.order_items`: 신규 1건, `menu_code_snapshot` NOT NULL로 채워짐, `unit_price_snapshot=price`, `item_amount = price*2`(`chk_order_item_amount` 통과), `selected_options='[]'::jsonb`, `options_amount=0`, `kitchen_zone_snapshot`/`estimated_minutes_snapshot`/`is_kds_required_snapshot` 스냅샷 존재.
- `catchmenu_kds.kds_tickets`: 신규 1건, `kds_status='HOLD'`(기존 로직 유지).

기대: 전 항목 통과, SQLSTATE 오류 0건.

## §3. TEST_B / SEAT_PATTERN — order_id + pre_order_created_at 세팅 후 형제 함수 정상 작동

이 시나리오가 C1(order_id + pre_order_created_at)의 핵심 회귀 검증이다.

절차:
1. §2와 동일하게 pre_order_while_waiting 호출로 사전주문 생성.
2. 세션 직접 확인:
   - `order_sessions.order_id = :order_id` (C1-a, 세팅됨).
   - `order_sessions.pre_order_created_at is not null` (C1-b, 세팅됨).
   - `order_sessions.session_type = 'PRE_ORDER'`.
3. **SEAT_PATTERN**: `select catchmenu_pos.seat_waiting_customer(tenant, store, :session_id, 'A01', null, 'ko', 'test-600683-seat')`.
   - 기대: 반환 `data.has_pre_order = true`, `data.pre_order_amount = price*2`(orders.final_amount LEFT JOIN 파생이 `os.order_id` 덕분에 성립).
4. **TEST_B (취소 분기)**: 별도 세션으로 §2 재생성 후 `select catchmenu_pos.cancel_waiting(tenant, store, :session_id2, '테스트 취소', 'STAFF', null, 'ko', 'test-600683-cancel')`.
   - 기대: `pre_order_created_at is not null` 분기 진입 → 해당 주문의 `kds_status='HOLD'` 티켓이 `CANCELLED`로 전이. 반환 `pre_order_cancelled=true`.
   - 검증: `catchmenu_kds.kds_tickets where order_id=:order_id2` 의 `kds_status='CANCELLED'`.

기대: has_pre_order=true, amount 정상 파생, HOLD→CANCELLED 정상.

## §4. TEST_A — 비교군: pre_order_created_at 없는 세션 (C1 필요성 입증)

C1이 없으면(또는 사전주문을 하지 않은 세션이면) 형제 함수가 사전주문을 인식하지 못함을 대조로 확인한다.

절차:
1. `pre_order_while_waiting` 호출 **없이** WAITING 세션만 생성(`pre_order_created_at = null`, `order_id = null`).
2. `seat_waiting_customer(...)` 호출 → 기대: `has_pre_order = false`, `pre_order_amount = null`(order_id null → LEFT JOIN 매칭 없음).
3. 그 세션에 HOLD KDS 티켓이 (다른 경로로) 있다고 가정한 상태에서 `cancel_waiting(...)` → 기대: `pre_order_created_at is not null` 분기 미진입 → HOLD 티켓 **유지**(CANCELLED 안 됨).

기대: has_pre_order=false, HOLD 유지 — §3과의 대비로 "pre_order_created_at 세팅이 필수"임을 실증.

## §5. Non-goals 검증 — 세팅하면 안 되는 컬럼 확인

§2/§3의 사전주문 세션에 대해:
- `order_sessions.pre_order_expires_at IS NULL` (예약형 만료 개념 미도입).
- `order_sessions.order_confirmed_at IS NULL` (주문확정 시각 미세팅).
- `order_sessions.session_status` 가 pre_order_while_waiting 호출 **전 상태와 동일**('WAITING' 또는 'ARRIVAL_PENDING' 유지, `ORDER_CONFIRMED`로 바뀌지 않음).

기대: 세 값 모두 위와 같음. (하나라도 세팅되면 범위 위반 → FAIL.)

## §6. ACL — REVOKE/GRANT 검증

절차(정정 적용 후):
```sql
select
  has_function_privilege('anon',
    'catchmenu_pos.pre_order_while_waiting(uuid,uuid,uuid,jsonb,text,text)', 'execute') as anon_exec,
  has_function_privilege('authenticated',
    'catchmenu_pos.pre_order_while_waiting(uuid,uuid,uuid,jsonb,text,text)', 'execute') as auth_exec;
```
기대: `anon_exec = false`, `auth_exec = true`.

보강(byte-identical proacl, 0167 검증 방식): 정정 후 `pg_proc.proacl::text`가 `{postgres=X/postgres,authenticated=X/postgres}` 형태(선두 `=X` PUBLIC 엔트리 없음)인지 확인.

## §7. Boundary — 무변경 함수 0 diff

정정 전/후로 다음 함수들의 `pg_get_functiondef()`가 **완전 동일**(0 diff)해야 한다:
- `catchmenu_pos.create_pre_order(uuid,uuid,uuid,jsonb,text,text)`
- `catchmenu_pos.confirm_pre_order_arrival(uuid,uuid,uuid,uuid,text,uuid,text)`
- `catchmenu_pos.bind_table_to_session(uuid,uuid,uuid,uuid,text,uuid,text)`

또한 `pre_order_while_waiting`의 **시그니처(인자 목록·타입·개수)**가 정정 전후 동일해야 한다(6-파라미터 불변). `pg_get_function_identity_arguments()` 비교로 확인.

기대: 세 함수 정의 문자열 동일, pre_order_while_waiting 시그니처 동일(본문만 변경).

## §8. Acceptance Criteria

1. **§1/§2** 정정 후 정상 호출 시 42703/23514/23502 어떤 SQLSTATE도 발생하지 않고 `success=true`.
2. **§2** orders `order_type='DINE_IN'`, order_source 부재, order_items 실제 컬럼 정합(menu_code_snapshot 채워짐, item_amount 정합).
3. **§3(C1-a)** 세션 `order_id` 세팅 → seat_waiting_customer의 `pre_order_amount`가 orders.final_amount로 정상 파생.
4. **§3(C1-b)** 세션 `pre_order_created_at` 세팅 → seat의 `has_pre_order=true`, cancel_waiting의 HOLD→CANCELLED 분기 작동.
5. **§4** 비교군(pre_order_created_at 없음)에서 has_pre_order=false, HOLD 유지 — C1 필요성 대조 입증.
6. **§5** pre_order_expires_at/order_confirmed_at NULL, session_status 미변경(Non-goals 준수).
7. **§6** anon=false, authenticated=true, proacl에 PUBLIC 엔트리 없음.
8. **§7** create_pre_order/confirm_pre_order_arrival/bind_table_to_session 0 diff, pre_order_while_waiting 시그니처 불변.
