# Pass A: Blind Reverse-Engineering — 대기열/주문 슬라이스05 (공통기반)

**Date:** 2026-07-18
**Reviewer:** Claude Fable 5 (blind pass — no design docs shown)
**Input provided:** slice_05_cross_slice_reconciliation_input_package.md, slice_05_cross_slice_reconciliation_migrations_concat.sql (9개 migration 원본 기반)

> 범위 주의: 이 슬라이스는 "대기열/주문" 도메인의 5개 슬라이스 중 공통 기반(공유 테이블/이벤트/트리거)만 다룬다. 개별 업무 흐름(대기 등록·호출/도착·노쇼·사전주문/착석)의 세부 RPC는 슬라이스 01~04에 있으며 여기서 판단하지 않는다. (단, 입력 매니페스트 §D는 "이 슬라이스 전용 RPC 없음"이라 했으나, 제공된 `..._migrations_concat.sql`에는 0025/0026/0049의 공유 RPC 본문 — `create_order_session`/`confirm_order`/`cancel_order`/`ensure_store_settings` 등 — 이 포함돼 있어, 상태전이 재구성에 그 본문을 근거로 사용했다. §5 참조.)

## 1. Reconstructed Domain Purpose

이 슬라이스는 대기열/주문 도메인 전체가 공유하는 **상태·이벤트 기반 레코드 뼈대**다. 손님의 방문 생애주기(대기 → 도착 → 착석 → 주문 → 결제 → 완료)를 하나의 `order_sessions` 로우로 추적하고, 각 전이를 세 갈래 이벤트 저장소(`session_events`, `order_events`, `catchmenu_ledger.events`)와 감사원장(`append_audit_record`)에 병렬 기록한다.

재구성한 공통 기반의 책임:
- **세션 생애주기 척추**: `order_sessions`가 방문 단위의 단일 상태머신. 대기번호(`wait_number`), 테이블 바인딩(`table_id`), 사전주문 창(`pre_order_*`), 도착 신뢰도(`arrival_reliability_score`), 게스트/고객 식별(`customer_id`/`phone_hash`/`customer_token`)을 모두 이 로우가 안고 간다.
- **주문 본체**: `orders` + `order_items`(가격/알레르겐 스냅샷 보존) — 주문 확정 시 가격을 스냅샷으로 굳혀 재계산하지 않는 설계(주석 "가격 스냅샷 — never recalculated").
- **KDS 커플링의 생산자 측**: `confirm_order`가 주방 필요 아이템마다 `catchmenu_kds.kds_tickets`를 **HOLD 상태 + conditions_met 전부 false(payment_confirmed=false)**로 생성한다. 즉 결제 도메인(600500)에서 본 "HOLD→COMMITTED" 게이트의 반대편(티켓을 HOLD로 낳는 쪽)이 여기 있다. 주석 "특허2: 주문 확정 → KDS 티켓(HOLD) → 조건 충족 후 조리 큐", "특허1: 결제 확인 없이 KDS 릴리즈 금지".
- **불변 이벤트 원장**: `catchmenu_ledger.events`(도메인 공통 이벤트 스토어, replay/idempotency 지원)와 `tasks`(비동기 작업 큐).
- **매장 설정/자원**: `dining_tables`(좌석 상태), `store_settings`(운영 모드·KDS 임계치·대기/사전주문/결제 정책 플래그).

## 2. Reconstructed State Machines

### 2.1 order_sessions.session_status (방문 생애주기 — 슬라이스의 중심)
- 허용값(`chk_session_status`, 11종): `WAITING`, `ARRIVAL_PENDING`, `SEATED`, `ORDERING`, `ORDER_CONFIRMED`, `PAYMENT_PENDING`, `PAYMENT_UNCERTAIN`, `COMPLETED`, `CANCELLED`, `EXPIRED`, `NO_SHOW`.
- 초기 상태는 `create_order_session`이 `session_type`으로 결정: WALK_IN→`SEATED`(+`seated_at=now()`), WAITING→`WAITING`, PRE_ORDER→`WAITING`, KIOSK→`ORDERING`, TAKEOUT→`ORDERING`, DELIVERY→`ORDER_CONFIRMED`.
- 시간 순서 무결성 CHECK: `seated_at >= arrived_at`, `order_confirmed_at >= seated_at`, `payment_started_at >= order_confirmed_at`(각각 NULL 허용). 즉 전이 시각의 단조성을 스키마가 강제.
- `PAYMENT_PENDING`/`PAYMENT_UNCERTAIN`은 결제 도메인(600500)의 `confirm_payment_from_provider`/`mark_payment_uncertain`이 세팅(교차 도메인 전이).
- `session_type`(`chk_session_type`, 6종): WALK_IN/WAITING/PRE_ORDER/KIOSK/TAKEOUT/DELIVERY.

### 2.2 session_events (세션 전이 감사 — append-only)
- 트리거 없음, 삽입 전용. 이벤트 타입(`chk_session_event_type`, 20종): session_created, wait_number_assigned, customer_called, customer_arrived, table_bound, pre_order_created, pre_order_expired, ordering_started, order_confirmed, payment_requested, payment_confirmed, payment_failed, payment_uncertain, payment_recovered, session_completed, session_cancelled, session_expired, no_show_marked, manual_override, session_reopened.
- `from_status`/`to_status`로 전이쌍 기록, `caused_by_type`(7종: SYSTEM/AGENT/STAFF/MANAGER/CUSTOMER/PROVIDER/SCHEDULER), `table_id_at_event`/`order_id_at_event` 스냅샷.

### 2.3 orders.order_status
- 허용값(`chk_order_status`, 9종): PENDING/CONFIRMED/COOKING/READY/SERVED/COMPLETED/CANCELLED/REFUNDED/PARTIAL_REFUNDED. 기본 PENDING.
- `confirm_order`: `PENDING`→`CONFIRMED`(+세션 `ORDER_CONFIRMED`), 이때 KDS 티켓을 HOLD로 생성. 반환 `next_step='PAYMENT_REQUIRED'`.
- `cancel_order`: (COMPLETED/CANCELLED/REFUNDED가 아니면)→`CANCELLED`, 아이템 CANCELLED, KDS 티켓 중 `HOLD/CAPACITY_CHECKING/COMMITTED`를 CANCELLED로.
- COOKING/READY/SERVED/COMPLETED로의 전이는 이 슬라이스에 코드가 없음(KDS/결제 슬라이스 소관).
- `order_type`(5종): DINE_IN/TAKEOUT/DELIVERY/KIOSK/STAFF_ORDER. `order_channel`(8종): KIOSK/TABLE_QR/STAFF_POS/CUSTOMER_APP/DELIVERY_*×3/MANUAL. 금액 무결성 `final = total - discount`.

### 2.4 order_items.item_status
- 허용값(6종): PENDING/CONFIRMED/COOKING/READY/SERVED/CANCELLED. `confirm_order`는 `is_kds_required_snapshot=true and item_status='PENDING'`인 아이템만 티켓화. `cancel_order`는 SERVED/CANCELLED 외 전부 CANCELLED. 금액 무결성 `item_amount = unit_price*qty + options_amount`.

### 2.5 order_events (주문 전이 감사 — append-only)
- 이벤트 타입(`chk_order_event_type`, 15종): order_created, order_confirmed, order_sent_to_kds, order_cooking_started, order_ready, order_served, order_completed, order_cancelled, order_refunded, order_partial_refunded, order_modified, pos_sync_completed, pos_sync_failed, manual_override, recovery_applied.

### 2.6 catchmenu_ledger.events (전 도메인 공통 이벤트 스토어)
- 트리거 없음, 삽입 전용. `event_domain`(`chk_event_domain`)는 0150에서 **`waiting` 추가로 확장**(원래 14종 → session/order/payment/kds/delivery/inventory/staff/device/agent/recovery/knowledge/gateway/system + waiting).
- `caused_by_type`(8종): 위 7종 + `REPLAY`. `is_replay=true`면 `original_event_id` 필수(`chk_event_replay_has_original`). `idempotency_key`, `event_version`, subject/session/order/payment/kds_ticket 상호참조 컬럼 보유 — 다도메인 이벤트를 한 테이블에 수렴.

### 2.7 catchmenu_ledger.tasks (비동기 작업 큐)
- `task_status`(8종): PENDING/SCHEDULED/IN_PROGRESS/COMPLETED/FAILED/CANCELLED/DELEGATED/AWAITING_APPROVAL. retry(`retry_count`/`max_retry=3`), `parent_task_id`(트리), `deadline_at`, priority 1~10. 이 슬라이스에 상태를 바꾸는 코드는 없음(다른 슬라이스/스케줄러 소관 추정).

### 2.8 dining_tables.table_status
- 허용값(5종): AVAILABLE/OCCUPIED/RESERVED/CLEANING/BLOCKED. `create_order_session`이 WALK_IN+table_id면 테이블을 `OCCUPIED`(+`current_session_id`/`occupied_since`)로. 착석 가능 조건은 `AVAILABLE`/`RESERVED`만.

### 2.9 store_settings.store_mode
- 허용값(8종): NORMAL/PEAK/LIMITED/TAKEOUT_ONLY/DELIVERY_ONLY/CLOSING/CLOSED/EMERGENCY. `ensure_store_settings`가 로우 없으면 기본값으로 지연 생성. 운영 정책 플래그: `payment_required_for_kds_release`(기본 true), `kds_release_auto_authorize`(기본 false), `waiting_enabled`, `pre_order_enabled`, 각종 임계치/자동만료 분(no_show/payment_uncertain).

## 3. Reconstructed Authorization/Boundary Model

- 이 슬라이스에 포함된 공유 RPC(`create_order_session`, `mark_session_arrived`, `bind_table_to_session`, `expire_session`, `create_order`, `confirm_order`, `cancel_order`, `ensure_store_settings`/`get_store_settings`/`update_business_hours`/`toggle_store_mode`/`update_kds_capacity_threshold`)는 **전부 SECURITY DEFINER**.
- 명시적으로 확인되는 grant 패턴(0026 하단): `create_order`/`confirm_order`/`cancel_order` 각각 `revoke all ... from public` 후 `grant execute ... to authenticated`. → PUBLIC(anon) 차단 + authenticated 실행. 나머지 RPC의 grant 문은 이 슬라이스 자료에 안 보임(0025/0049 grant는 잘려 있음, §5).
- **함수 내부 권한 검증 부재**: `confirm_order`(기본 actor_type='CUSTOMER'), `cancel_order`(기본 'STAFF'), `create_order_session`는 `p_actor_type`/`p_actor_id`를 감사 라벨로만 쓰고, 역할 게이트(`is_manager_or_above` 등)를 호출하지 않는다. 앞선 도메인들과 동일하게 실행 주체 자기신고.
- 공유 테이블 전부 RLS 활성(0021 계열), 정책 텍스트는 추출 실패로 불명(§5). 이 슬라이스 RPC가 DEFINER라 실사용 경로는 RLS를 우회.

## 4. Anomalies / Suspicious Patterns

**4-1. 코드가 스키마보다 앞서 작성된 흔적(0150 / 0148 자백).**
0150 주석: "0115/0149의 live `register_waiting()`가 `event_domain='waiting'`으로 기록하는데, 기존 `chk_event_domain` 제약은 이를 허용하지 않았다" → 즉 0150 적용 전에는 그 이벤트 삽입이 CHECK 위반으로 **실패했을 것**. 0148 주석도 "`phone_hash`는 0115가 이미 존재를 가정하지만 0012 기반 테이블엔 없었다"며 뒤늦게 컬럼 추가. 스키마가 코드 뒤를 반응적으로 따라간 정황이 마이그레이션 주석에 명시돼 있다.

**4-2. 거버넌스 밖 라이브 DB 변경(0148 자백).**
0148 주석: `order_sessions.customer_id`·FK·인덱스가 **migration_history 기록 없이 라이브 DB에 out-of-band로 부분 적용**돼 있었고, 그 FK가 승인 설계(`ON DELETE SET NULL`)와 달리 `ON DELETE NO ACTION`이었다. 0148이 이를 안전하게 제거 후 재생성해 교정한다. 통제되지 않은 직접 DB 변경이 실제 있었음을 스스로 기록.

**4-3. `cancel_order` 주석과 코드의 불일치.**
주석은 "COOKING/READY 상태 티켓은 취소하지 않음 — 직원이 처리"라고 하는데, 실제 UPDATE 대상은 `kds_status in ('HOLD','CAPACITY_CHECKING','COMMITTED')`다. `COMMITTED`(결제 후 조리 승인 완료 상태)까지 강제 CANCELLED 처리한다. COMMITTED와 COOKING의 관계는 KDS 슬라이스 소관이라 이 자료로 확정 불가하나, "조리 승인된 티켓을 취소한다"는 점은 주석의 의도와 상충 소지(§5).

**4-4. 결제-KDS 릴리즈 정책 플래그 이원화.**
`store_settings`에 `payment_required_for_kds_release`(기본 true)와 `kds_release_auto_authorize`(기본 false)가 공존한다. 둘 다 "결제와 KDS 방출 사이 게이트"를 제어하는 것으로 보이나 의미가 겹치고 잠재적으로 상반될 수 있다(예: payment_required=false + auto_authorize=false의 조합 의미 불명). 이 슬라이스엔 두 플래그를 읽는 코드가 없어 실제 상호작용은 확인 불가.

**4-5. 세션↔주문 링크의 라이브 데이터 비대칭.**
라이브 `order_sessions` 2행은 각각 `order_id`(717f.../22ef...)를 가리키지만, 그 2개 `orders`의 `session_id`는 **둘 다 null**이다. 즉 세션→주문 방향만 연결돼 있고 주문→세션 역참조가 비어 있다. 양방향 FK가 모두 존재(스키마상)하는데 데이터는 한 방향만 채워짐 — 생성 경로의 부분 링크 정황.

**4-6. 삼중(사중) 이벤트 기록의 중복.**
`confirm_order` 하나가 `order_events` + `catchmenu_ledger.events` + `append_audit_record`(catchmenu_ledger.audit_records) 세 곳에, 세션 전이는 추가로 `session_events`에 기록된다. 동일 사실이 3~4개 저장소에 병렬 기록되는 구조(의도적 다중원장으로 보이나, 정합성 유지 부담·저장 중복이라는 관점에서 특이).

**4-7. `store_settings` 라이브 0행 + 미래 개점일 + ACTIVE 불일치.**
`stores`는 `store_status='ACTIVE'`이지만 `opened_on='2027-09-01'`(미래)이고 `store_settings`는 0행이다. `ensure_store_settings`가 지연 생성하므로 0행 자체는 "아직 설정 RPC가 호출된 적 없음"을 뜻할 뿐 결함은 아니다(§5). 그러나 "미래 개점일 + 지금 ACTIVE"는 상태 정의상 모순 소지.

**4-8. 라이브 데이터가 전부 테스트 하네스 산출물.**
`orders.order_number`가 `CUR-S9-CWC-882`, `CUR-S9-CNWC-1031`(Stage 9 검증 하네스 명명), `order_sessions`의 `wait_number` 882/1031, `ledger.events` 2행은 `menu_price_changed`(system 도메인) 뿐. `session_events`/`order_events`/`order_items`/`tasks` 전부 0행. → 대기/주문 생애주기 전이가 실제로 한 번도 완주된 적 없다. 이 슬라이스의 모든 상태전이는 "이론 설계"이며 "작동 증거" 아님.

**4-9. WALK_IN 세션이 즉시 SEATED로 시작.**
`create_order_session`은 WALK_IN을 곧장 `SEATED`(+seated_at)로 만든다 — WAITING/ARRIVAL_PENDING 단계를 건너뜀. 하드코딩 매핑이라 좌석 미배정 WALK_IN도 SEATED가 될 수 있다(table_id 없이도 SEATED 가능: 테이블 바인딩은 선택).

**4-10. 게스트 식별 컬럼 삼중화.**
`order_sessions`에 `customer_token`(불투명 토큰), `customer_id`(customers FK, nullable, SET NULL), `phone_hash`(해시) 세 가지 신원 표현이 공존한다. 우선순위·정합성 규칙은 이 슬라이스에 없다(0148은 customer_id/phone_hash만 다룸, customer_token 용도 불명).

## 5. Confidence Notes

- **RPC 포함 범위**: 입력 §D는 "이 슬라이스 전용 RPC 없음"이라 했으나 `..._migrations_concat.sql`에는 0025/0026/0049의 공유 RPC 본문이 실제로 들어 있다. §2/§3의 전이·권한은 그 본문 근거(추정 아님). 다만 이 함수들의 "정본" 정의가 슬라이스 01~04에서 재정의/오버라이드됐을 가능성은 이 자료로 배제 불가.
- **4-3(cancel_order COMMITTED 취소)**: `kds_status`의 COMMITTED/COOKING/READY 관계는 KDS 슬라이스(04) 스키마에 달려 있어, "조리 중 티켓을 취소하는가"는 여기서 확정 불가 — Pass B/C에서 KDS 슬라이스와 대조 필요.
- **4-4(플래그 이원화)**: 두 플래그를 읽는 소비 코드가 이 슬라이스에 없어 실제 상호작용/우선순위는 불명. 결제 슬라이스나 KDS 슬라이스에서 해소돼야 함.
- **RLS 정책 텍스트**: `pg_policy.cmd` 추출 오류로 전 테이블 정책 내용 불명. §3의 경계는 grant 문(확인분) + 공통기반 RLS 관례 근거.
- **grant 커버리지**: 0026의 create/confirm/cancel_order grant만 자료에 보이고, 0025(session)·0049(store_settings) RPC의 grant 문은 잘려 있어 그 함수들의 proacl은 확정 불가.
- **4-7(store_settings 0행)**: `ensure_store_settings` 지연 생성 확인됨 — 0행은 결함이 아니라 미접근. 다만 "미래 opened_on + ACTIVE" 모순은 stores 시드 데이터의 문제로 보이나 의도(테스트 픽스처)일 수 있음.
- 민감 컬럼(phone_hash, phone) redacted — 존재/용도만 판단.
