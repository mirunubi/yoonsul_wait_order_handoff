# Pass A: Blind Reverse-Engineering — 대기열/주문 슬라이스04 (사전주문/착석/주문본체)

**Date:** 2026-07-18
**Reviewer:** Claude Fable 5 (blind pass — no design docs shown)
**Input provided:** slice_04_pre_order_order_session_input_package.md, slice_04_pre_order_order_session_migrations_concat.sql (5개 migration 원본 기반)

> 범위: 사전주문/착석/취소/주문본체 15개 RPC(pre_order_while_waiting, create_pre_order, confirm_pre_order_arrival, cancel_pre_order, get_pre_order_status, seat_waiting_customer, _resolve_dining_table_by_number, cancel_waiting, create_order_session×2 오버로드, bind_table_to_session, expire_session, create_order, confirm_order, cancel_order). 공유 테이블 상태정의·이벤트는 슬라이스05, 앞단(등록/호출/노쇼)은 슬라이스01~03 관할이므로 참조만.

## 1. Reconstructed Domain Purpose

이 슬라이스는 대기 파이프라인의 **뒷단**: 손님이 (a) 대기 중 사전주문을 넣고, (b) 도착해 테이블에 **Late Binding**(후매칭)되어 착석하며, (c) 실제 주문을 생성·확정·취소하는 구간이다. 재구성한 책임:
- **사전주문 생성**: `create_pre_order`(0051)와 `pre_order_while_waiting`(0115) — **두 개의 서로 다른 사전주문 생성 경로**가 공존한다(§4-1).
- **Late Binding 착석**: `bind_table_to_session`(코어, 세션→SEATED + 테이블 OCCUPIED), `seat_waiting_customer`(table_number를 `_resolve_dining_table_by_number`로 table_id 해석 후 bind에 위임), `confirm_pre_order_arrival`(도착 확인 + bind + KDS 조건 arrived/table_confirmed=true).
- **주문 본체**: `create_order`/`confirm_order`/`cancel_order`(주문 생성→확정 시 KDS 티켓 HOLD 생성→취소) — 슬라이스05에서 이미 다룬 공유 RPC.
- **세션 생애 관리**: `create_order_session`(2개 오버로드), `expire_session`(TTL/노쇼 종료 + 테이블 반납), `cancel_waiting`/`cancel_pre_order`(대기/사전주문 취소).
- **조회**: `get_pre_order_status`(세션+주문+KDS 티켓 조건 종합).

주석의 "특허1(Late Binding = 도착 시 테이블 후매칭)", "특허2(사전주문 → KDS HOLD → 조건 충족 후 조리)"가 이 슬라이스의 핵심 서사다.

## 2. Reconstructed State Machines

### 2.1 사전주문 → 착석 흐름(경로에 따라 상이)
- `create_pre_order`(0051): 세션 `{WAITING|ARRIVAL_PENDING}` → **`ORDER_CONFIRMED`**(+session_type=PRE_ORDER, order_id, pre_order_expires_at). 주문 `PENDING`(DINE_IN/TABLE_QR). KDS 티켓 HOLD, **7개 조건**(arrived/table_confirmed/payment_confirmed/kds_capacity_ok=false, menu_available/peak_time_ok/no_show_risk_ok=계산).
- `pre_order_while_waiting`(0115): 세션 session_type=PRE_ORDER(status 변경 없음), 주문 `CONFIRMED`(order_type='TABLE'), KDS 티켓 HOLD, **2개 조건**(payment_confirmed/kds_release_authorized=false)만.
- `confirm_pre_order_arrival`: session_type='PRE_ORDER' + 미만료 확인 → `bind_table_to_session` 호출 → KDS 조건 arrived=true, table_confirmed=true 갱신(HOLD/CAPACITY_CHECKING 티켓).
- `bind_table_to_session`(코어): 세션 `{WAITING|ARRIVAL_PENDING|ORDERING}` → `SEATED`(+table_id, seated_at, ordering_started_at). 테이블 → `OCCUPIED`. `table_id` 이미 있으면 `table_already_bound` 거부.
- `seat_waiting_customer`: SEATED면 즉시 거부, table_number 필수 → `_resolve_dining_table_by_number`(FOUND/NOT_FOUND/AMBIGUOUS/INACTIVE) → bind 위임.

### 2.2 주문 본체 (orders.order_status, chk 9종: PENDING/CONFIRMED/COOKING/READY/SERVED/COMPLETED/CANCELLED/REFUNDED/PARTIAL_REFUNDED)
- `create_order`→PENDING, `confirm_order`→CONFIRMED(+KDS HOLD 티켓, 슬라이스05), `cancel_order`→CANCELLED(+HOLD/CAPACITY_CHECKING/COMMITTED 티켓 취소).
- order_type chk 5종: DINE_IN/TAKEOUT/DELIVERY/KIOSK/STAFF_ORDER — **'TABLE' 없음**(§4-2).

### 2.3 세션 종료
- `expire_session`: 비종료 세션 → `EXPIRED`(또는 p_expire_reason='NO_SHOW'면 NO_SHOW). 바인딩된 테이블 → `CLEANING` + current_session_id=null(반납).
- `cancel_waiting`/`cancel_pre_order`: 세션 → CANCELLED, 사전주문 있으면 HOLD KDS 티켓 취소.

## 3. Reconstructed Authorization/Boundary Model

- 15개 전부 SECURITY DEFINER.
- **proacl**(§D.1): authenticated 전용 11, **PUBLIC(=X) 3**(`cancel_waiting`, `pre_order_while_waiting`, `seat_waiting_customer`), owner-only 1(`_resolve_dining_table_by_number` — 내부 헬퍼, 적절히 잠김).
- 0051(create_pre_order 등 4종)은 `revoke public; grant authenticated` 명시. 0115 유래 3종(pre_order_while_waiting/seat_waiting_customer/cancel_waiting)은 PUBLIC 잔존 — 회수 정책 절반 적용(도메인 반복 패턴).
- 내부 역할 검증 없음. `p_actor_type`/`p_actor_id`는 감사·이벤트 라벨로만. `bind_table_to_session` 등도 호출자=주체 검증 없음.

## 4. Anomalies / Suspicious Patterns

**4-1. 사전주문 생성 경로 이중화 — 하나는 깨져 있음(가장 심각).**
`create_pre_order`(0051, 클린)와 `pre_order_while_waiting`(0115)가 **둘 다 라이브**로 존재하며 결과가 다르다. 후자는 다음의 **다중 스키마 위반**을 가진다(§4-2와 결합):
- `orders`에 `order_source` 컬럼 INSERT — orders 스키마에 그 컬럼 없음.
- `order_items`에 `unit_price`, `subtotal`, `item_options` INSERT — 실제 컬럼은 `unit_price_snapshot`/`item_amount`/`selected_options`.
- `order_sessions`에 `pre_order_amount` UPDATE — 그 컬럼 없음.
이는 슬라이스02/04의 형제 함수(get_waiting_status/admin_view/confirm_arrival/seat_waiting_customer/cancel_waiting)가 0160/0163/0164로 phantom 컬럼을 교정받은 것과 달리 **`pre_order_while_waiting`만 미교정으로 남았다**. 현재 스키마 기준 이 함수는 실행 시 실패한다. 게다가 PUBLIC(anon) 노출.

**4-2. `order_type='TABLE'`은 CHECK 제약에 없는 값.**
`pre_order_while_waiting`은 주문을 `order_type='TABLE'`로 생성하는데, `chk_order_type` 허용집합은 DINE_IN/TAKEOUT/DELIVERY/KIOSK/STAFF_ORDER로 **'TABLE'이 없다**. INSERT 자체가 제약 위반으로 거부된다(4-1의 컬럼 부재와 별개의 추가 위반).

**4-3. 사전주문 해피패스 상태 게이트 모순 — end-to-end 완주 불가.**
`create_pre_order`(클린)는 세션을 **`ORDER_CONFIRMED`**로 만든다. 그런데 그 다음 단계 `confirm_pre_order_arrival`은 `bind_table_to_session`에 위임하고, `bind_table_to_session`의 상태 게이트는 `{WAITING|ARRIVAL_PENDING|ORDERING}`만 허용한다 — **`ORDER_CONFIRMED`는 포함되지 않는다**. 즉 create_pre_order로 만든 세션은 confirm_pre_order_arrival에서 `session_not_bindable`로 거부된다. 클린 경로(create_pre_order → confirm_pre_order_arrival)가 상태머신상 이어지지 않는다. (반대로 pre_order_while_waiting은 세션 status를 안 바꿔 bindable하지만, 그 함수 자체가 4-1로 깨져 있다.) 두 경로 모두 사전주문→도착착석 완주가 막혀 있는 것으로 보인다.

**4-4. `create_order_session` 오버로드 2종 공존.**
`create_order_session`이 서로 다른 시그니처 두 벌(`...p_queue_position, p_pre_order_expires_at` vs `...p_table_id, p_expires_minutes`)로 라이브에 존재한다. 슬라이스02/03에서 본 "오버로드 정리(0160/0161)" 흐름과 같은 미정리 잔재로 보이며, 호출측이 어느 쪽을 부르는지에 따라 세션 생성 파라미터 의미가 달라진다.

**4-5. 두 사전주문 경로의 비즈니스 규칙 불일치.**
`create_pre_order`는 `arrival_reliability_score < threshold(60)`이면 사전주문을 **차단**하고(노쇼 이력 방어), KDS 티켓에 7개 조건(no_show_risk_ok/peak_time_ok/menu_available 포함)을 심는다. `pre_order_while_waiting`은 그런 신뢰도 게이트가 **없고** 조건도 2개(payment/release)뿐이다. 같은 "사전주문"인데 진입 함수에 따라 노쇼 방어·조건 판정이 완전히 다르다.

**4-6. 착석 경로 다중화(3+개).**
세션을 SEATED로 만드는 경로가 `bind_table_to_session`(직접), `seat_waiting_customer`(table_number 해석 후 위임), `confirm_pre_order_arrival`(도착+bind), 그리고 슬라이스05의 `create_order_session`(WALK_IN 즉시 SEATED)까지 존재한다. 착석 상태 진입점이 분산돼 있어 불변식(테이블 OCCUPIED 동기화 등)이 경로마다 일관되는지 확인 필요.

**4-7. PUBLIC 노출 3종 중 `seat_waiting_customer`/`cancel_waiting`.**
직원 조작에 해당하는 착석(`seat_waiting_customer`)과 취소(`cancel_waiting`)가 anon(PUBLIC) 실행 가능하다. 비인증 호출로 임의 세션을 착석/취소시킬 수 있는 표면. (create_pre_order 계열은 0051에서 authenticated로 잠갔으나 0115 계열은 방치.)

**4-8. Late Binding 시각 컬럼 동시 세팅의 의미 중첩.**
`bind_table_to_session`은 한 번의 UPDATE로 `seated_at`과 `ordering_started_at`을 **동시에 now()로** 세팅한다. 착석과 주문개시가 항상 같은 순간으로 기록돼, "착석 후 주문까지의 시간" 같은 지표를 이 두 컬럼으로는 구할 수 없다.

**4-9. `expire_session`의 이벤트 타입이 노쇼와 충돌.**
`expire_session(p_expire_reason='NO_SHOW')`는 세션을 NO_SHOW로 만들고 session_events/ledger에 `no_show_marked` 이벤트를 남긴다. 그런데 노쇼 확정의 정본은 슬라이스03의 `apply_no_show_transition`(score 감점·유예 처리 포함)이다. `expire_session` 경로의 노쇼는 **score 감점·KDS 유예 없이** 상태만 NO_SHOW로 바꿔, 같은 `no_show_marked` 이벤트가 두 종류의 부작용(정본은 감점+유예, 이쪽은 상태만)으로 갈린다.

**4-10. 라이브 작동 증거 없음.**
`orders` 2행은 슬라이스05에서 본 테스트 하네스(`CUR-S9-*`, TAKEOUT/CONFIRMED, session_id=null), `order_items` 0행, kds_tickets 0행. 사전주문/착석/주문본체 어느 흐름도 실제 완주된 적 없다 — 4-1~4-3의 깨진 경로가 라이브 실행으로 드러난 바 없다(전부 이론).

## 5. Confidence Notes

- **4-1/4-2/4-3(깨진 사전주문 경로)**: `pre_order_while_waiting`의 phantom 컬럼·잘못된 order_type='TABLE'은 라이브 함수 정의와 slice04/05 스키마 덤프의 직접 대조로 확정. 다만 이 감사 패키지 밖의 후속 마이그레이션이 `order_source`/`pre_order_amount` 컬럼이나 'TABLE' enum을 추가했을 가능성은 배제 불가(그 경우 일부 위반이 실효). `orders`/`order_items` 라이브 스키마 덤프 기준으로는 부정합이 확정. 4-3의 상태 게이트 모순도 코드로 확정이나, 실제 호출 순서(엣지/앱)가 create_pre_order→confirm_pre_order_arrival인지, 아니면 다른 순서인지는 호출측 코드 부재로 미확인.
- **4-4(오버로드)**: 두 create_order_session이 라이브에 공존함은 §D.2로 확정. 어느 쪽이 정본인지·폐기 예정인지는 블라인드 판단 불가.
- **4-7(PUBLIC)**: §D.1 proacl로 확정. 0115 계열 grant 원문은 이 패키지에 완전히 보이지 않아 PUBLIC이 의도인지 미교정 잔재인지는 불명(0051 계열은 명시 잠금 확인).
- **seat_waiting_customer/cancel_waiting/confirm_arrival(slice02)**: 라이브 정의는 orders LEFT JOIN으로 pre_order_amount를 파생하는 교정본 확인(주석 스스로 "order_sessions.pre_order_amount does not exist" 명시) — 즉 phantom 교정이 이들엔 적용됐고 `pre_order_while_waiting`엔 누락됐다는 비대칭이 이 슬라이스의 핵심.
- **4-9**: 두 노쇼 경로의 부작용 차이는 코드로 확정. 어느 경로가 운영상 실제로 쓰이는지(cron은 슬라이스03 process_expired_no_shows 사용)는 호출 그래프 필요.
- RLS 정책 텍스트 없음(pg_policy 추출 실패). 민감 컬럼 redacted.
- **도메인 종합 참고**: 이로써 5개 슬라이스(05/01/02/03/04) Pass A 완료. 슬라이스 간 반복 확인된 교차 주제(phantom 컬럼 교정 캠페인 0160~0164의 커버리지 누락, 오버로드 미정리, 0115 계열 PUBLIC 잔존, 이벤트 도메인 태깅 불일치)는 Pass B/C에서 도메인 통합 관점으로 종합 판정 필요.
