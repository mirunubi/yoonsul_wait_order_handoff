# 600682 Logic — Pre-Order While Waiting Phantom Correction

- Workpacket: `600680_pre_order_while_waiting_phantom_correction`
- Stage: 4 (설계) — `.sql` 생성/수정 없음
- Depends on: [600681_Overview](600681_Overview_Pre_Order_While_Waiting_Phantom_Correction.md)
- Created: 2026-07-19

이 문서는 `catchmenu_pos.pre_order_while_waiting()`의 phantom 컬럼을 제거하는 정확한 before→after 매핑을 규정한다. 함수의 **시그니처·제어흐름·검증 로직·알림·ledger 이벤트·KDS 티켓 INSERT는 변경하지 않는다.** 오직 아래 §1~§4의 4개 지점만 정정한다.

대상 함수 시그니처 (불변):
```
catchmenu_pos.pre_order_while_waiting(
  p_tenant_id uuid, p_store_id uuid, p_session_id uuid,
  p_cart_items jsonb, p_locale text default 'ko',
  p_correlation_id text default null
) returns jsonb  -- SECURITY DEFINER, plpgsql, volatile
```

## §1. `menus` SELECT 확장 (order_items 정정의 선행 조건)

현재 두 개의 `menus` SELECT가 `menu_code`/`estimated_minutes`를 뽑지 않는다. order_items 정정(§3)에서 `menu_code_snapshot`(NOT NULL)과 `estimated_minutes_snapshot`이 필요하므로, **두 번째 루프의 SELECT**(order_items를 만드는 루프)에 컬럼을 추가한다.

**Before** (현재):
```sql
select id, menu_name, price,
       is_kds_required, kitchen_zone
into v_menu
from catchmenu_pos.menus
where id = (v_item->>'menu_id')::uuid ...
```
**After**:
```sql
select id, menu_code, menu_name, price,
       is_kds_required, kitchen_zone, estimated_minutes
into v_menu
from catchmenu_pos.menus
where id = (v_item->>'menu_id')::uuid ...
```
- 근거: 형제 `create_pre_order()`(0051)가 동일 SELECT에서 `menu_code`/`estimated_minutes`를 뽑아 order_items 스냅샷에 넣는다.
- 첫 번째 루프(금액 계산/품절 확인)는 `menu_code`가 불필요하므로 변경하지 않는다.

## §2. `orders` INSERT 정정

**Before** (현재 — phantom):
```sql
insert into catchmenu_pos.orders (
  tenant_id, store_id,
  session_id, order_number,
  order_type, order_status,
  order_source,                 -- ❌ 존재하지 않는 컬럼 (42703)
  total_amount, final_amount,
  ordered_at,
  business_day, business_timezone
) values (
  p_tenant_id, p_store_id,
  p_session_id, v_order_number,
  'TABLE', 'CONFIRMED',         -- ❌ 'TABLE'은 chk_order_type 위반 (23514)
  'PRE_ORDER',                  -- ❌ order_source 값
  v_total_amount, v_total_amount,
  now(),
  v_business_day, v_timezone
) returning id into v_order_id;
```
**After** (정정):
```sql
insert into catchmenu_pos.orders (
  tenant_id, store_id,
  session_id, order_number,
  order_type, order_status,
  total_amount, final_amount,
  ordered_at,
  business_day, business_timezone
) values (
  p_tenant_id, p_store_id,
  p_session_id, v_order_number,
  'DINE_IN', 'CONFIRMED',       -- ✅ 'TABLE' → 'DINE_IN' (create_pre_order 선례)
  v_total_amount, v_total_amount,
  now(),
  v_business_day, v_timezone
) returning id into v_order_id;
```
변경 요약:
- `order_source` 컬럼 및 값 `'PRE_ORDER'` **제거**(컬럼 미존재).
- `order_type` `'TABLE'` → **`'DINE_IN'`**(4-1 근거: create_pre_order 0051).
- `order_status = 'CONFIRMED'` **유지**(유효 enum, 상태 의미 변경은 범위 밖 — Overview §6-a로 이월).
- `session_id = p_session_id` 이미 세팅됨(orders→session FK). **유지.**
- `order_channel`은 이 INSERT에 없어 기본 `'KIOSK'`가 된다. 이번 미변경(Overview §6-c). "사전주문 출처=PRE_ORDER"의 의미는 `order_source` 제거로 사라지지만, 그 정보는 세션 `session_type='PRE_ORDER'`(§4)와 KDS `conditions_met.order_source`(기존 유지)에 이미 담겨 있어 손실 없음.

## §3. `order_items` INSERT 정정

**Before** (현재 — phantom):
```sql
insert into catchmenu_pos.order_items (
  tenant_id, store_id,
  order_id, menu_id,
  menu_name_snapshot,
  quantity, unit_price, subtotal,   -- ❌ unit_price/subtotal 미존재
  item_options                      -- ❌ item_options 미존재
) values (
  p_tenant_id, p_store_id,
  v_order_id, v_menu.id,
  v_menu.menu_name,
  (v_item->>'quantity')::int,
  v_menu.price,
  v_menu.price * (v_item->>'quantity')::int,
  coalesce(v_item->'options', '[]'::jsonb)
);
```
**After** (정정):
```sql
insert into catchmenu_pos.order_items (
  tenant_id, store_id,
  order_id, menu_id,
  menu_code_snapshot, menu_name_snapshot,   -- ✅ menu_code_snapshot 추가 (NOT NULL)
  unit_price_snapshot, quantity, item_amount,
  selected_options, options_amount,
  kitchen_zone_snapshot,
  estimated_minutes_snapshot,
  is_kds_required_snapshot
) values (
  p_tenant_id, p_store_id,
  v_order_id, v_menu.id,
  v_menu.menu_code, v_menu.menu_name,
  v_menu.price,
  (v_item->>'quantity')::int,
  v_menu.price * (v_item->>'quantity')::int,  -- item_amount = unit_price_snapshot*quantity + options_amount(0)
  coalesce(v_item->'options', '[]'::jsonb),
  0,                                          -- options_amount
  v_menu.kitchen_zone,
  v_menu.estimated_minutes,
  v_menu.is_kds_required
);
```
컬럼 매핑:
| Phantom (before) | 실제 컬럼 (after) | 비고 |
|---|---|---|
| `unit_price` | `unit_price_snapshot` | |
| `subtotal` | `item_amount` | `chk_order_item_amount`: `item_amount = unit_price_snapshot*quantity + options_amount` |
| `item_options` | `selected_options` | jsonb 배열, `chk_selected_options_array` |
| (없음) | `menu_code_snapshot` | **NOT NULL, 기본값 없음** → 반드시 추가(§1에서 SELECT 확장) |
| (없음) | `options_amount` | `0` 명시(item_amount 정합성) |
| (없음) | `kitchen_zone_snapshot`/`estimated_minutes_snapshot`/`is_kds_required_snapshot` | create_pre_order 파리티. `is_kds_required_snapshot`/`item_status`는 기본값(true/`PENDING`)이 있으나 스냅샷 일관성을 위해 명시 |
- `allergen_displayed`/`item_status` 등 기본값 있는 컬럼은 생략 가능(기본값 사용) — create_pre_order와 동일 최소셋.
- 옵션 금액 계산은 이번 범위 밖(현재 함수는 옵션 금액을 계산하지 않음). `options_amount=0` 유지로 `item_amount` 정합성만 보장. 옵션가 반영은 core 재설계(Open Item a).
- **C2 — 카트 JSON 키 불일치(동작 변경 없이 유지).** `selected_options` 값을 이 함수는 `coalesce(v_item->'options', ...)`로 읽는데(0115 원문), 형제 `create_pre_order()`(0051)는 같은 자리를 `coalesce(v_item->'selected_options', ...)`로 읽는다. 즉 **두 사전주문 경로의 카트 입력 API 계약이 다르다**(A: `options` 키 / B: `selected_options` 키). 이번 워크패킷은 phantom 제거만 하므로 **`v_item->'options'`를 그대로 둔다**(키를 바꾸면 A안 호출측의 입력 계약이 깨지는 behavior change). 두 경로의 카트 키 통일은 공통 Core 재설계로 이월(Overview §6-e).

## §4. `order_sessions` UPDATE 정정 + order_id 연결

**Before** (현재 — phantom):
```sql
update catchmenu_pos.order_sessions
set
  session_type = 'PRE_ORDER',
  pre_order_amount = v_total_amount,   -- ❌ 존재하지 않는 컬럼
  updated_at = now()
where id = p_session_id;
```
**After** (정정):
```sql
update catchmenu_pos.order_sessions
set
  session_type = 'PRE_ORDER',
  order_id = v_order_id,               -- ✅ C1과 함께 세션↔주문 연결 (0160 파생 성립 조건)
  pre_order_created_at = now(),        -- ✅ C1: has_pre_order 판정 성립 조건
  updated_at = now()
where id = p_session_id;
```
변경 요약:
- `pre_order_amount = v_total_amount` **제거**(컬럼 미존재). 금액은 저장하지 않고 `orders.final_amount`에서 파생한다(0160 선례: 읽는 쪽이 `order_sessions os LEFT JOIN orders o ON o.id = os.order_id` 로 `o.final_amount as pre_order_amount`).
- **`order_id = v_order_id` 추가 (핵심).** 근거: 현재 함수는 세션에 `order_id`를 세팅하지 않아, phantom을 단순 제거만 하면 형제 교정본(seat_waiting_customer/cancel_waiting)의 LEFT JOIN이 `os.order_id = null`이라 pre_order_amount를 `null`로 읽게 된다. "pre_order_amount 참조를 0160 패턴으로 교체"의 필수 귀결로 세션→주문 링크를 세운다. create_pre_order(0051)도 세션에 `order_id`를 세팅한다(선례 일치).
- **`pre_order_created_at = now()` 추가 (C1, 핵심).** 근거: `order_id`와 **동일한 근거 구조**의 필수 귀결이다. 형제 교정본은 사전주문 여부를 **금액이 아니라 `os.pre_order_created_at is not null`로 판정**한다: (a) `seat_waiting_customer()`는 `has_pre_order := v_session.pre_order_created_at is not null`, (b) `cancel_waiting()`은 `if v_session.pre_order_created_at is not null then` HOLD KDS 티켓을 취소한다. 현재 함수는 이 컬럼을 세팅하지 않으므로, phantom만 제거하면 이 함수로 만든 사전주문은 **has_pre_order가 항상 false로 잡히고 취소 시 HOLD 티켓이 방치**된다. create_pre_order(0051)도 세션에 `pre_order_created_at = now()`를 세팅한다(선례 일치). ※ create_pre_order가 함께 세팅하는 `pre_order_expires_at`/`order_confirmed_at`/`session_status='ORDER_CONFIRMED'`는 **추가하지 않는다** — 그것들은 예약형(B안)의 만료·확정 개념이며, 즉석형(A안)에 도입하면 behavior change이자 §5.4/Open Item b의 상태게이트 영역을 건드리게 되어 범위 밖이다. 오직 `has_pre_order` 판정에 필요한 `pre_order_created_at`만 추가한다.
- `session_status`는 **변경하지 않는다**(현재 함수는 status를 안 바꿈). 이 무변경이 A안을 정본으로 택한 이유 중 하나 — bind_table_to_session의 게이트(WAITING/ARRIVAL_PENDING/ORDERING)와 충돌하지 않는다(Overview §5.4). status를 ORDER_CONFIRMED 등으로 바꾸는 것은 범위 밖(behavior change).

## §5. GRANT / REVOKE

현재 proacl: `=X/postgres,postgres=X/postgres,authenticated=X/postgres`(PUBLIC 포함). 0167 선례에 따라 PUBLIC을 회수하고 `authenticated`만 남긴다.

```sql
revoke all on function catchmenu_pos.pre_order_while_waiting(
  uuid, uuid, uuid, jsonb, text, text
) from public;

grant execute on function catchmenu_pos.pre_order_while_waiting(
  uuid, uuid, uuid, jsonb, text, text
) to authenticated;
```
- 근거: 형제 `create_pre_order()`(0051)가 `authenticated`. 이 함수는 "고객이 대기 중 직접 메뉴를 담는" 공개 개념이므로 `authenticated` 공개가 정확(내부 헬퍼가 아니므로 `_record_waiting_call`식 owner-only는 아님).
- `CREATE OR REPLACE`는 기존 ACL을 보존하므로, PUBLIC 회수를 위해 위 REVOKE를 **명시적으로** 넣어야 한다(0164처럼 "grant 불필요"가 아님 — 이번은 권한 경계 자체를 바꾸는 것이 목적).

## §6. 시그니처 불변 원칙 (향후 core 이관 대비)

- 함수 시그니처 6-파라미터를 그대로 유지한다. 이유:
  1. 호출측(엣지/앱, 있다면) 무영향.
  2. 향후 "공통 Pre-order Core + 2 facade" 재설계 시, 이 함수를 **얇은 facade로 축소**해 core에 위임하기 쉽다(시그니처가 안정적이면 facade 계약이 그대로 유지됨).
  3. 0164가 확립한 "public 시그니처 불변 → 호출 계약 안정" 원칙과 일치.
- 따라서 이번 정정은 `CREATE OR REPLACE FUNCTION`(동일 시그니처) + REVOKE/GRANT 형태가 된다(Stage 8에서 실제 마이그레이션 작성 시).

## §7. Migration placement (Stage 8 참고, 이번 미작성)

- 이번 문서는 설계만. 실제 정정은 Stage 8에서 **다음 순번 forward 마이그레이션**(현재 최신 `0167` 다음, 즉 Stage 8 시점의 최소 미사용 번호)으로 작성한다. 기존 0115/0160/0163/0164 원문은 **수정하지 않는다**(forward-only 원칙; 0163:30이 "0115 source text 수정 금지"를 이미 확립).
- `CREATE OR REPLACE FUNCTION catchmenu_pos.pre_order_while_waiting(...)` 전체 재정의 + §5 REVOKE/GRANT 로, 단일 마이그레이션.
- 새 message_catalog/error_codes 항목 불필요(기존 에러키 재사용, 새 사용자 메시지 없음).

## §8. Non-goals (재확인)

- `create_pre_order()` / `confirm_pre_order_arrival()` / `bind_table_to_session()` 수정 금지.
- 상태게이트 모순 해결 금지(Open Item b).
- 공통 Pre-order Core 재설계 금지.
- KDS 티켓 INSERT 로직·`conditions_met` 형상 변경 금지(이미 실제 컬럼만 사용; 형상 통일은 Open Item d).
- 옵션 금액 계산 추가 금지(`options_amount=0` 유지).
- order_status/order_channel/주문번호 스킴 변경 금지(behavior change, 범위 밖).
- 카트 JSON 키 `v_item->'options'` 변경 금지(C2 — A안 입력 계약 유지, Open Item e).
- `pre_order_expires_at`/`order_confirmed_at`/`session_status` 세팅 금지(C1은 `pre_order_created_at`만; 만료·확정·상태 개념 추가는 범위 밖).

## Snapshot Decision

- 2026-07-19: `pre_order_while_waiting()`의 4개 phantom 지점(orders.order_source, order_type='TABLE', order_items 3컬럼, order_sessions.pre_order_amount)에 대한 정확한 before→after 매핑과 GRANT/REVOKE를 확정했다. 설계 중 발견한 핵심 부수사항 — **현재 함수가 세션에 `order_id`를 세팅하지 않아 pre_order_amount 파생(0160 패턴)이 성립하지 않는다** — 을 §4에 명시하고, phantom 제거의 필수 귀결로 `order_id = v_order_id` 추가를 설계에 포함했다. 시그니처·상태전이·조건 로직은 불변. Stage 5(TestPlan/ChangeContract) 진행 대기.
- 2026-07-19 (정정, Cursor 검증 반영): **C1** — 세션 UPDATE에 `pre_order_created_at = now()` 추가를 §4에 반영했다. `order_id`와 동일한 근거 구조의 필수 귀결로, 형제 교정본이 `has_pre_order`를 `pre_order_created_at is not null`로 판정하고(seat_waiting_customer) 그 값에 따라 HOLD KDS 티켓을 취소(cancel_waiting)하기 때문. 이 컬럼이 없으면 이 함수로 만든 사전주문은 has_pre_order가 항상 false로 잡히고 취소 시 HOLD 티켓이 방치된다. `pre_order_expires_at`/`order_confirmed_at`/`session_status`는 범위 밖으로 추가하지 않음(만료·확정·상태게이트 영역). **C2** — 카트 JSON 키 불일치(A안 `v_item->'options'` vs create_pre_order `v_item->'selected_options'`)를 §3에 동작 변경 없이 유지로 기록하고 Open Item e(Overview §6-e)로 이월했다.
