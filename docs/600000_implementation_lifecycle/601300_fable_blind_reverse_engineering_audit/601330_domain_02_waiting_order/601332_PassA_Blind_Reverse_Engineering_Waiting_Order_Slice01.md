# Pass A: Blind Reverse-Engineering — 대기열/주문 슬라이스01 (대기열 등록/조회)

**Date:** 2026-07-18
**Reviewer:** Claude Fable 5 (blind pass — no design docs shown)
**Input provided:** slice_01_waiting_queue_input_package.md, slice_01_waiting_queue_migrations_concat.sql (4개 migration 원본 기반)

> 범위: 대기열 등록/조회 특화 6개 RPC(`register_waiting`, `get_waiting_queue`, `update_queue_position`, `estimate_wait_time`, `get_waiting_status`, `get_waiting_admin_view`)에 집중. 공유 테이블(`order_sessions`/`session_events`/`ledger.events` 등)의 DDL·상태정의는 슬라이스05 관할이므로 참조만 표시하고 깊이 들어가지 않는다. 마이그레이션 원문(0050/0115)에는 이 6개 외에 타 슬라이스 RPC(`call_next_waiting`/`call_waiting_customer`/`confirm_arrival`/`pre_order_while_waiting`/`seat_waiting_customer`/`cancel_waiting`/`mark_no_show`)도 함께 들어 있으나, 이들은 슬라이스 02~04 관할로 표시만 하고 판단하지 않는다.

## 1. Reconstructed Domain Purpose

이 슬라이스는 **손님을 대기열에 넣고(등록), 대기 현황을 조회·재정렬하는** 기능이다. 재구성한 책임:
- **등록**(`register_waiting`): 매장 설정 확인 → 정원 검사 → 오늘 대기번호 채번 → `order_sessions` 로우를 `WAITING`으로 생성 → Realtime(`WAITING_QUEUE`/DID) 브로드캐스트 + (전화번호 있으면) 푸시 큐잉 → `ledger.events(event_domain='waiting')` 기록.
- **조회**: `get_waiting_queue`(매장 전체 대기열), `get_waiting_status`(개별 손님 현재 순번/예상시간), `get_waiting_admin_view`(관리자용 대기 리스트 + 당일 통계), `estimate_wait_time`(입장 전 대기시간 예측 — 좌석 가용성 기반).
- **수동 재정렬**(`update_queue_position`): 관리자가 특정 대기 세션의 `queue_position`을 강제 변경하고 감사 기록.

주석 반복 문구로 보아 "대기 → 호출 → 착석 → 사전주문 → 결제 → KDS Late Binding"의 앞단(대기 등록/조회)을 담당하며, i18n(6개 로케일: ko/en/zh/ja/vi/th) 메시지를 `message_catalog`로 관리한다.

## 2. Reconstructed State Machines

이 슬라이스가 **직접 유발**하는 전이(상태값 정의 자체는 슬라이스05 관할):
- `register_waiting`: (없음) → `order_sessions.session_status='WAITING'`(+`wait_number`, `queue_position = 현재대기수+1`). `event_domain='waiting'`, event_type `waiting_registered`.
- `update_queue_position`: `WAITING` 세션의 `queue_position`만 변경(상태값 전이는 아님). `for update` 잠금, `WAITING`이 아니면 거부. 감사 decision=`OVERRIDDEN`.
- 조회 4종(`get_waiting_queue`/`get_waiting_status`/`get_waiting_admin_view`/`estimate_wait_time`)은 STABLE, 상태 전이 없음.
- 대기번호 채번: `max(wait_number)+1` (오늘·매장 범위, **session_type 무관 전체**). 정원 검사: `count(session_status in WAITING/ARRIVAL_PENDING and session_type in WAITING/PRE_ORDER) >= coalesce(max_wait_number, 30)`.
- 조회 정렬 규약: `get_waiting_queue`는 `ARRIVAL_PENDING(0) → WAITING(1) → 기타(2)` 순, 그 안에서 `coalesce(queue_position, wait_number)` 오름차순. `WAITING`/`PRE_ORDER` 세션타입만 대상.
- `WAITING → ARRIVAL_PENDING`(호출), `→ SEATED`(착석), `→ NO_SHOW` 등의 전이는 슬라이스 02~04 관할.

## 3. Reconstructed Authorization/Boundary Model

- 6개 전부 SECURITY DEFINER.
- **proacl 이원화**(§D.1): authenticated 전용 3개(`estimate_wait_time`, `get_waiting_queue`, `update_queue_position`) / **PUBLIC(anon 포함) 3개**(`register_waiting`, `get_waiting_status`, `get_waiting_admin_view` — proacl `=X/...`).
- 0050 마이그레이션은 자기 함수 5개(get_waiting_queue/call_next_waiting/update_queue_position/mark_no_show/estimate_wait_time)에 대해 명시적으로 `revoke all from public; grant to authenticated` 수행. 반면 0115가 만든 `register_waiting`/`get_waiting_status`/`get_waiting_admin_view`는 PUBLIC이 남아 있다(해당 grant 문이 이 자료 범위에 안 보임 — §5).
- **함수 내부 역할 검증 없음**: `update_queue_position`(기본 actor='MANAGER'), `register_waiting`(기본 source='STAFF')은 `p_actor_type`/`p_actor_id`/`p_source`를 감사·이벤트 라벨로만 쓰고 권한 게이트로 검증하지 않는다. 앞선 도메인들과 동일한 자기신고 패턴.
- 테이블 RLS는 슬라이스05 관할(정책 텍스트 불명).

## 4. Anomalies / Suspicious Patterns

**4-1. `store_mode = 'HOLIDAY'`는 존재하지 않는 값(데드 조건).**
`register_waiting`은 `store_mode in ('CLOSED','HOLIDAY','EMERGENCY')`이면 대기 차단하는데, `store_settings.chk_store_mode` 허용집합(슬라이스05)은 NORMAL/PEAK/LIMITED/TAKEOUT_ONLY/DELIVERY_ONLY/CLOSING/CLOSED/EMERGENCY로 **'HOLIDAY'가 없다**. 휴무는 별도 `holiday_mode` boolean으로 표현된다. 즉 이 분기의 'HOLIDAY' 검사는 절대 참이 될 수 없고, `holiday_mode=true`인 휴무일에도 `register_waiting`은 대기를 막지 않는다.

**4-2. 예상 대기시간 계산식이 함수마다 다름(사용자에게 상충된 숫자).**
`estimate_wait_time`(입장 전)은 정교한 공식 `queue_length * avg_session_minutes / suitable_tables`를 쓰지만, `register_waiting`과 `get_waiting_status`는 **`queue_position * 10`(위치당 일괄 10분)** 이라는 단순식을 쓴다. 같은 손님이 등록 직전(estimate)과 직후(register/status)에 서로 다른 예상시간을 받게 된다.

**4-3. 순번(queue_position)의 이중 정의 — 수동 재정렬이 손님 화면에 반영 안 됨.**
`order_sessions`에는 저장된 `queue_position` 컬럼이 있고 `register_waiting`이 채우며 `update_queue_position`이 이를 강제 변경한다. 그런데 `get_waiting_status`는 이 저장 컬럼을 **무시**하고, `wait_number < 내 번호`인 WAITING/ARRIVAL_PENDING 세션 수를 세어 순번을 **동적 재계산**한다. 따라서 관리자가 `update_queue_position`으로 앞당겨/미뤄도 손님이 보는 `get_waiting_status`의 순번에는 반영되지 않는다(두 메커니즘이 서로 다른 순번을 산출).

**4-4. `max_wait_number` 필드 의미/기본값 불일치.**
`register_waiting`은 정원 초과 판정에 `현재_대기수 >= coalesce(max_wait_number, 30)`을 쓴다. 그런데 (a) 필드명 `max_wait_number`는 "대기 번호의 상한(≈999)"을 시사하지만 실제로는 "동시 대기 팀 수 상한"으로 쓰인다(의미 불일치). (b) `store_settings`가 있으면 기본값 **999**(슬라이스05 스키마), 없으면 코드 fallback **30**. 설정 로우 유무에 따라 정원이 30 vs 999로 33배 차이 난다.

**4-5. 대기번호가 큐 범위로 연속되지 않음.**
채번은 `max(wait_number)+1`을 **session_type 무관 전체**에서 뽑는데, 정원/조회는 `session_type in ('WAITING','PRE_ORDER')`로 필터한다. WALK_IN/KIOSK 등 다른 타입 세션에 wait_number가 있으면 대기번호가 건너뛴다. (라이브 증거: WALK_IN 세션 2개가 wait_number 882, 1031 — 다음 register_waiting은 1032가 되어 큐 순번과 무관하게 커진다.)

**4-6. PUBLIC 노출 3종 중 `get_waiting_admin_view`.**
관리자용 대기 리스트+당일 통계(매출 pre_order_amount 합계 포함)를 반환하는 `get_waiting_admin_view`가 proacl PUBLIC(anon 실행 가능)이다. `register_waiting`(QR 자가등록 목적일 수 있음)·`get_waiting_status`(손님 자기 조회)의 PUBLIC은 설명 가능하나, 관리자 뷰의 PUBLIC은 의도 불명. 0050 함수들은 PUBLIC을 명시 회수한 반면 0115의 이 3종은 남겨져 회수 정책이 불일치.

**4-7. 조회 함수의 타임존 처리 불일치.**
`get_waiting_queue`/`estimate_wait_time`/`register_waiting`은 `stores.timezone`을 조회해 business_day를 계산하지만, `get_waiting_status`와 `get_waiting_admin_view`는 `'Asia/Seoul'`을 하드코딩한다. 비-서울 타임존 매장에서 관리자 뷰/개별 상태의 "오늘" 경계가 등록 시점과 어긋날 수 있다.

**4-8. `estimate_wait_time`의 정수 필드에 센티넬(-1) 혼용.**
`estimated_wait_minutes`가 실제 분(0, 5, N)과 "적합 테이블 없음"을 뜻하는 **-1**을 같은 정수 필드에 섞어 반환한다. 소비 측이 -1을 분으로 오해하면 음수 대기시간 표시 위험.

**4-9. (교차 슬라이스 신호) 형제 함수의 phantom 컬럼 — 0164가 조회 2종만 교정한 정황.**
이 슬라이스의 라이브 `get_waiting_status`/`get_waiting_admin_view`(§D.3)는 `called_at`/`call_count`를 `session_events` lateral 조인으로, `table_number`를 `dining_tables.table_code` 조인으로, `pre_order_amount`를 `orders.final_amount` 조인으로 **파생**한다 — 즉 `order_sessions`에 그런 컬럼이 없음을 전제한 교정본이다. 반면 마이그레이션 0115 원문의 형제 함수들(`call_waiting_customer`/`confirm_arrival`/`seat_waiting_customer`/`pre_order_while_waiting`, 슬라이스 02~04 관할)은 여전히 `order_sessions.called_at`/`table_number`/`call_count`/`pre_order_amount`/`arrival_confirmed_at`와 `orders.order_source`/`order_items.unit_price`·`subtotal`·`item_options` 등 **슬라이스05 스키마에 없는 컬럼**을 직접 참조한다. 4번째 마이그레이션 `0164_waiting_pipeline_sibling_functions_correction`의 이름으로 미루어, 조회 2종은 phantom 컬럼 버그가 교정됐고 형제 함수들은 별도 교정 대상이었던 정황. (형제 함수 자체 판단은 슬라이스 02~04 관할 — 여기선 신호만 표시.)

**4-10. 라이브 작동 증거 없음.**
`register_waiting`으로 생성된 `WAITING` 세션이 라이브에 없다(2개 세션은 WALK_IN, `session_events`=0행, `ledger.events`는 `menu_price_changed`뿐 — 슬라이스05 §C). 대기 등록/호출 파이프라인은 실제로 한 번도 실행된 적 없다 — 이 슬라이스의 모든 전이는 이론 설계.

## 5. Confidence Notes

- **grant 커버리지**: 0050의 5개 함수 grant(revoke public→authenticated)는 원문에 있으나, 0115가 만든 `register_waiting`/`get_waiting_status`/`get_waiting_admin_view`의 grant 문은 이 자료의 열람 범위(마이그레이션 앞부분)에 안 보였다. PUBLIC proacl은 §D.1 요약에서 확정된 사실이나, 그 PUBLIC이 0115의 누락인지 0164에서 의도적으로 부여/유지한 것인지는 확정 불가.
- **4-9(phantom 컬럼)**: 형제 함수들의 실제 "라이브" 정의는 이 슬라이스 §D.3에 포함되지 않았다(6개만 제공). 마이그레이션 0115 원문 기준으로 phantom 참조를 지적했으며, 0164가 그 형제들까지 교정했는지 여부는 슬라이스 02~04 자료로 확인해야 한다. "런타임 실패한다"가 아니라 "0115 원문 기준 슬라이스05 스키마와 부정합"으로 읽어야 한다.
- **0050 vs §D.3 동일성**: `get_waiting_queue`/`update_queue_position`/`estimate_wait_time`의 라이브(§D.3)와 0050 원문은 사실상 동일 확인. `register_waiting` 라이브와 0115 원문도 동일.
- **RLS 정책 텍스트**: 이 자료에 없음(슬라이스05 관할). §3 경계는 grant + proacl 근거.
- **store_settings 0행**: `register_waiting`/`estimate_wait_time`은 `ensure_store_settings`를 부르지 않으므로 설정 로우가 없으면 coalesce 기본값(waiting_enabled=true, max_wait_number→30)으로 동작. 4-4의 30 vs 999 분기는 이 때문.
- 민감 컬럼(phone_hash) redacted — 존재/용도만 판단.
