# 600681 Overview — Pre-Order While Waiting Phantom Correction

- Workpacket: `600680_pre_order_while_waiting_phantom_correction`
- Domain: `600600_waiting_order_session`
- Stage: 4 (Overview/Logic 설계) — 이 문서에서 `.sql` 생성/수정 없음
- Status: Stage 4 진행 — Stage 5(TestPlan/ChangeContract) 대기
- Owner role: Claude Code (설계), Human 결정 반영
- Created: 2026-07-19

## 1. Background

`catchmenu_pos.pre_order_while_waiting()`(원본 `0115_create_waiting_pipeline_rpc.sql`)은 waiting 파이프라인의 **phantom-column 교정 캠페인(0160/0163/0164)에서 유일하게 제외된 다섯 번째 형제 함수**다. 제외는 우연이 아니라 명시적이었다 — `0163_seat_waiting_customer_facade_correction.sql` 30번째 줄 Non-goals에 `pre_order_while_waiting()`이 "수정하지 않는다"로 적혀 있다.

그 결과 이 함수는 현재 라이브 스키마 기준 **실행 즉시 크래시**하는 상태로 남았다. Fable 블라인드 Pass A(슬라이스04, `601335_..._Slice04.md` §4-1/§4-2)가 이를 독립 발견했고, Cursor가 라이브 스키마 대조로 실증했으며, ChatGPT+제미나이 교차검증으로 처리 방향이 확정됐다. 확인된 결함:

1. **`orders` INSERT — 존재하지 않는 `order_source` 컬럼 참조** → 실행 시 PostgreSQL `42703 undefined_column` 크래시.
2. **`order_type = 'TABLE'`** → `chk_order_type` 허용집합(`DINE_IN`/`TAKEOUT`/`DELIVERY`/`KIOSK`/`STAFF_ORDER`)에 없어 `23514 check_violation`. (1번 크래시가 먼저 나므로 실행상으론 후순위지만, 컬럼 결함을 고쳐도 남는 독립 위반.)
3. **`order_items` INSERT — `unit_price`/`subtotal`/`item_options`** = 실제 컬럼(`unit_price_snapshot`/`item_amount`/`selected_options`) 이름과 불일치. 또한 NOT NULL인 `menu_code_snapshot`을 아예 넣지 않는다.
4. **`order_sessions` UPDATE — `pre_order_amount` 컬럼 참조** = 그 컬럼은 존재하지 않는다. (형제 교정본들은 이 값을 `orders.final_amount` LEFT JOIN으로 파생한다.)
5. **PUBLIC(anon) EXECUTE 노출** — proacl `=X/postgres,...`. 형제 `create_pre_order()`는 `authenticated`로 잠겨 있으나 이 함수만 PUBLIC 잔존.

실호출자 0건(라이브 `orders`/`order_items`/`kds_tickets`에 이 함수가 만든 흔적 없음)이라 운영 사고는 아직 없었으나, MVP 대기-중-사전주문 경로의 정본 함수가 호출 불가 상태다.

## 2. 확정된 방향 (Human 결정 — 재논의 금지)

- **이 함수(A안: "대기 중 즉석 사전주문")를 MVP 정본 경로로 확정**한다.
- `create_pre_order()`/`confirm_pre_order_arrival()`(B안: 예약형)의 상태게이트 모순(§5.4 참조)은 **이번에 손대지 않는다** — 별도 후속 재설계 프로그램(공통 Pre-order Core + 2 facade)으로 이월.
- 이번 워크패킷은 **순수 "phantom 컬럼 제거"만** 수행한다 — 0160/0163/0164와 **동일한 패턴 그대로** 적용. 새 기능·새 상태전이·새 조건 로직을 추가하지 않는다.

## 3. Scope

### In scope (이번 워크패킷)
- `pre_order_while_waiting()` 한 함수의 `orders` INSERT / `order_items` INSERT / `order_sessions` UPDATE에서 phantom 컬럼 제거 및 실제 컬럼으로 정정.
- `order_type = 'TABLE'` → 유효 enum 값으로 정정.
- PUBLIC EXECUTE → `authenticated`로 잠금(REVOKE ALL FROM PUBLIC + GRANT authenticated).
- 함수 시그니처는 **불변**(호출측/기존 grant/향후 core 이관 편의를 위해).

### Out of scope (명시적 비목표)
- `create_pre_order()` / `confirm_pre_order_arrival()` / `bind_table_to_session()` **수정 금지**. 상태게이트 모순은 이번 범위 아님.
- "공통 Pre-order Core" 재설계 **시작 금지**.
- 두 사전주문 경로의 `conditions_met` 조건 개수 차이(A안 6종 vs create_pre_order 7종), `order_status` 차이(A안 `CONFIRMED` vs create_pre_order `PENDING`), 주문번호 스킴 차이(`W###` vs `P-####`) — 전부 **후속 core 재설계로 이월**(§6 Open Items).
- KDS 티켓 INSERT는 이미 실제 컬럼만 쓰므로(§5.3) 손대지 않는다.
- `.sql` 파일 생성/수정(이번은 Stage 4 설계만).

## 4. 확인 완료 사항 (설계 전 검증)

이번 설계 전에 다음을 실제 원문/스키마로 대조 확인했다:

- **4-1. order_type 정정 값 = `'DINE_IN'`.** 0160/0163은 `orders`를 INSERT하지 않으므로 그 자체가 직접 선례는 아니다. 대신 **동일 의미의 형제 `create_pre_order()`(0051)가 `order_type='DINE_IN'`, `order_channel='TABLE_QR'`을 쓴다.** 대기 중 사전주문도 결국 매장 내 식사(dine-in)이므로 `'DINE_IN'`이 문맥상 정확한 값이다. (`order_channel`은 §5.5에서 별도 판단.)
- **4-2. order_items 실제 컬럼명(0051/라이브 스키마 대조):** `menu_code_snapshot`(NOT NULL, 기본값 없음), `menu_name_snapshot`, `unit_price_snapshot`, `quantity`, `item_amount`(= `unit_price_snapshot*quantity + options_amount`, `chk_order_item_amount`), `selected_options`(jsonb 배열), `options_amount`(기본 0), `kitchen_zone_snapshot`, `estimated_minutes_snapshot`, `is_kds_required_snapshot`, `item_status`. → phantom `unit_price`→`unit_price_snapshot`, `subtotal`→`item_amount`, `item_options`→`selected_options`. **추가로 `menu_code_snapshot`을 반드시 채워야 하며**, 이를 위해 함수 내 `menus` SELECT에 `menu_code`(및 KDS 파리티를 위한 `estimated_minutes`)를 포함해야 한다(§5.2).
- **4-3. pre_order_amount 파생 선례 = 0160 LEFT JOIN + 사전주문 판정은 pre_order_created_at.** 형제 교정본(seat_waiting_customer/cancel_waiting)은 `order_sessions os LEFT JOIN orders o ON o.id = os.order_id` 로 `o.final_amount as pre_order_amount`를 파생하고, **사전주문 존재 여부는 `os.pre_order_created_at is not null`로 판정**한다. 그런데 현재 `pre_order_while_waiting()`은 세션 UPDATE에서 **`order_id`도, `pre_order_created_at`도 설정하지 않는다**(§5.1의 핵심 발견). 따라서 "pre_order_amount 참조를 0160 패턴으로 교체"의 필수 귀결로 세션 UPDATE에 **두 컬럼을 함께 추가**한다:
  - **(C1-a) `order_id = v_order_id`** — 없으면 LEFT JOIN이 `os.order_id = null`이라 pre_order_amount를 `null`로 읽는다.
  - **(C1-b) `pre_order_created_at = now()`** — 없으면 `has_pre_order`가 항상 false로 잡혀, (a) seat_waiting_customer의 사전주문 안내 분기, (b) cancel_waiting의 HOLD KDS 티켓 취소 분기가 작동하지 않는다(HOLD 티켓 방치).
  두 값 모두 형제 `create_pre_order()`(0051)가 세션에 세팅하는 값과 일치한다(선례 일치). ※ create_pre_order가 함께 세팅하는 `pre_order_expires_at`/`order_confirmed_at`/`session_status='ORDER_CONFIRMED'`는 예약형(B안)의 만료·확정·상태게이트 개념이므로 A안엔 추가하지 않는다(범위 밖).
- **4-4. grant 선례 = 0167.** `0167_record_waiting_call_grant_correction.sql`이 `revoke all ... from public` + `grant execute ... to authenticated` 패턴을 확립했다. 형제 `create_pre_order()`도 `authenticated`(0051에서 명시 revoke public+grant authenticated). 이 함수는 "고객이 대기 중 직접 메뉴를 담는" 개념이므로 공개용이 맞고, `authenticated` 공개가 정확하다(§5.5).
- **4-5. 시그니처 불변 근거 = 0164.** 0164는 "네 함수의 public 시그니처가 0115와 동일하므로 새 GRANT/REVOKE 불필요"라고 명시했다. 시그니처를 그대로 두면 (a) 호출측 무영향, (b) 향후 공통 core 이관 시 facade 시그니처를 그대로 재사용 가능. 본 워크패킷도 시그니처 불변 원칙을 따른다(단, PUBLIC→authenticated 변경이 목적이므로 GRANT/REVOKE는 이번엔 필요 — 0164와 달리 권한 자체를 바꾸기 때문).

## 5. 설계 요지 (상세는 600682_Logic)

- **§5.1 orders INSERT 정정 + 세션 링크**: `order_source` 컬럼/값 제거, `order_type` `'TABLE'`→`'DINE_IN'`. 세션 UPDATE에 `order_id`/`pre_order_created_at` 추가(§5.3).
- **§5.2 order_items INSERT 정정**: 실제 컬럼명으로 교체 + `menu_code_snapshot` 추가 + SELECT에 `menu_code`/`estimated_minutes` 포함. `item_amount`/`options_amount` 정합성 유지. 카트 키 `v_item->'options'`는 유지(C2, §6-e).
- **§5.3 order_sessions UPDATE 정정**: `pre_order_amount = ...` 라인 삭제(파생으로 대체), `session_type='PRE_ORDER'` 유지, **`order_id = v_order_id`(C1-a)** 및 **`pre_order_created_at = now()`(C1-b)** 추가. `session_status`/`pre_order_expires_at`/`order_confirmed_at`은 미변경.
- **§5.4 (참고, 비수정) 상태게이트 모순**: create_pre_order 경로의 문제는 이월. A안(이 함수)은 세션 status를 바꾸지 않으므로 bind_table_to_session의 게이트와 충돌하지 않는다 — 이것이 A안을 정본으로 택한 실무적 이유 중 하나.
- **§5.5 GRANT/REVOKE**: `revoke all on function ... from public` + `grant execute ... to authenticated`. `order_channel`은 기본값(`KIOSK`) 유지 vs `TABLE_QR` 정렬 — Open Item으로 남김(§6-c).

## 6. Open Items (후속 이월, 이번 미해결)

- **(a) [최우선/후속 프로그램] 공통 Pre-order Core 재설계**: create_pre_order(B: 예약형)와 pre_order_while_waiting(A: 즉석형)을 공통 core + 2 facade로 통합. 그 과정에서 상태게이트 모순(§5.4), conditions_met 조건 개수 차이, order_status/주문번호 스킴 차이를 일괄 정리. 본 워크패킷은 A를 "이관 가능한 최소 정상 함수"로 만들어 두는 것이 목적.
- **(b) create_pre_order→confirm_pre_order_arrival 상태게이트 모순**: `create_pre_order`가 세션을 `ORDER_CONFIRMED`로 두는데 `bind_table_to_session`은 이를 bindable 상태로 인정하지 않음. 별도 워크패킷 필요.
- **(c) order_channel 값 정렬**: 이 함수는 order_channel을 명시하지 않아 기본 `'KIOSK'`가 된다. 형제 create_pre_order는 `'TABLE_QR'`. 대기-중-사전주문의 실제 채널 의미 확정은 (a) core 재설계에서. 이번엔 phantom 결함이 아니므로 기본값 유지(변경 시 behavior change라 범위 밖).
- **(d) conditions_met 형상 통일**: A안(payment_confirmed/kds_release_authorized/waiting_session_id/wait_number/order_source/release_trigger)과 create_pre_order(7-조건 arrived/table_confirmed/... 형상)의 KDS 조건 스키마 차이. core 재설계로 이월.
- **(e) [C2] 카트 JSON 키 불일치**: 두 사전주문 경로의 카트 입력 API 계약이 다르다 — A안 `pre_order_while_waiting()`은 옵션을 `v_item->'options'`로, B안 `create_pre_order()`(0051)는 `v_item->'selected_options'`로 읽는다. 이번 워크패킷은 phantom 제거만이므로 A안의 `'options'` 키를 **그대로 유지**한다(키 변경은 A안 호출측 입력 계약을 깨는 behavior change). 두 경로의 카트 키 통일은 공통 Pre-order Core 재설계(Open Item a)에서 정리 대상. (Cursor 검증 C2로 확인·기록.)

## Snapshot Decision

- 2026-07-19: Fable Pass A(slice04)가 발견하고 Cursor 실증·ChatGPT+제미나이 교차검증으로 확정된 `pre_order_while_waiting()` phantom 결함을, 0160/0163/0164와 동일한 "순수 phantom 제거" 패턴으로 정정하는 워크패킷 `600680`을 개설했다. 설계 전 4가지 사실(order_type='DINE_IN' 선례, order_items 실제 컬럼, pre_order_amount 파생을 위한 order_id 연결 필요, grant=0167 선례)을 원문 대조로 확인했다. 상태게이트 모순과 공통 core 통합은 명시적으로 이월(Open Items a/b). Stage 5(TestPlan/ChangeContract)로 진행 대기.
- 2026-07-19 (정정, Cursor 검증 반영): **C1** — 세션 UPDATE에 `pre_order_created_at = now()`를 추가(§4-3 C1-b, §5.3). `order_id`와 동일 근거 구조의 필수 귀결로, 형제 교정본이 `has_pre_order`를 `pre_order_created_at is not null`로 판정하고 그에 따라 cancel_waiting이 HOLD KDS 티켓을 취소하기 때문 — 없으면 이 함수의 사전주문이 has_pre_order=false로 잡혀 취소 시 HOLD 티켓이 방치된다. **C2** — 두 사전주문 경로의 카트 옵션 키 불일치(A안 `options` vs B안 `selected_options`)를 동작 변경 없이 유지로 확정하고 Open Item e로 추가했다. 두 정정 모두 함수 시그니처·상태전이는 여전히 불변.
