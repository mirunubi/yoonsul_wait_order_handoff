# 900101_Logic_Customer_Waiting_Handoff_And_Late_Binding_Pipeline

Status: In_Progress
Lifecycle: Logic
Owner: TBD
Last Updated: 2026-06-21

---

## 0. Document Purpose

This Logic document defines the control logic, state transitions, exception
handling, permission boundaries, fallback behavior, audit behavior, and
reconciliation behavior for the Customer Waiting Handoff and KDS Late Binding
pipeline.

이 문서는 파이프라인의 설계 권한 문서다.
Codex 구현은 여기 정의된 로직에서 벗어날 수 없다.
변경이 필요하면 Human 승인 후 이 문서를 먼저 수정한다.

Related Overview: 900100_Overview_Customer_Waiting_Handoff_And_Late_Binding_Pipeline.md

---

## 1. 핵심 상태 머신

### 1.1 order_sessions 상태 전이

```text
정상 경로:

  [null]
    ↓ register_waiting()
  [WAITING]
    ↓ call_waiting_customer()
  [ARRIVAL_PENDING]
    ↓ confirm_arrival()         선택적
  [ARRIVAL_PENDING]
    ↓ seat_waiting_customer()
  [SEATED]
    ↓ confirm_payment() 완료 후 자동
  [COMPLETED]

예외 경로:

  [WAITING]        → cancel_waiting()  → [CANCELLED]
  [ARRIVAL_PENDING]→ cancel_waiting()  → [CANCELLED]
  [ARRIVAL_PENDING]→ mark_no_show()    → [NO_SHOW]

자동 만료 (pg_cron):
  [WAITING]        → 2시간 초과        → [CANCELLED]
  [ARRIVAL_PENDING]→ 호출 후 15분 무응답→ [NO_SHOW]
```

### 1.2 kds_tickets 상태 전이

```text
정상 경로 (Patent 2 핵심):

  [null]
    ↓ pre_order_while_waiting() 또는 place_kiosk_order()
  [HOLD]                        ← 결제 전. 조리 금지. 화면 회색.
    ↓ release_kds_after_payment()  ← confirm_payment() 후 자동 호출
  [COMMITTED]                   ← 결제 확인. 조리 시작. 화면 녹색.
    ↓ transition_kds_ticket()
  [COOKING]                     ← 조리 중. 화면 주황.
    ↓ transition_kds_ticket()
  [READY]                       ← 완료. 화면 파랑.
    ↓ transition_kds_ticket()
  [SERVED]                      ← 서빙 완료.

예외 경로:
  [HOLD] → cancel_waiting() 또는 mark_no_show() → [CANCELLED]
  [HOLD] → 주문 취소 → [CANCELLED]
```

### 1.3 conditions_met 필드 설계

kds_tickets.conditions_met 는 HOLD 해제 조건을 명시적으로 기록한다.

```text
결제 전 (HOLD 상태):
{
  "payment_confirmed": false,
  "kds_release_authorized": false,
  "order_source": "PRE_ORDER",
  "waiting_session_id": "uuid",
  "release_trigger": "payment"
}

결제 후 (COMMITTED 상태):
{
  "payment_confirmed": true,
  "kds_release_authorized": true,
  "order_source": "PRE_ORDER",
  "waiting_session_id": "uuid",
  "release_trigger": "payment",
  "released_at": "2027-09-01T09:30:00+09:00"
}
```

배달 주문 예외:
```text
배달 주문 (order_source IN ('BAEMIN','YOGIYO','COUPANG_EATS')):
  선결제 → 수신 즉시 COMMITTED
  HOLD 단계 없음
  conditions_met.release_trigger = "pre_paid"
```

---

## 2. 고객 행동별 제어 로직

### 2.1 QR 스캔 → 대기 등록

```text
RPC: register_waiting()

입력 검증:
  store_mode NOT IN ('CLOSED','HOLIDAY','EMERGENCY')
  → 실패: store_closed 에러
  waiting_enabled = true
  → 실패: WAITING_QUEUE_DISABLED 에러
  현재 WAITING + ARRIVAL_PENDING 수 < max_waiting_count
  → 실패: WAIT_QUEUE_FULL 에러

처리:
  wait_number = 오늘 최대 wait_number + 1
  queue_position = 현재 WAITING + ARRIVAL_PENDING 수 + 1
  order_sessions INSERT (WAITING)

사이드 이펙트:
  Realtime waiting:{store_id} → waiting_session_created
  phone_hash 있으면 push_notification_queued
  ledger.events INSERT: waiting_registered

반환:
  session_id, wait_number, queue_position
  est_wait_minutes = queue_position × 10   (단순 추정)
  i18n 메시지 (고객 locale 기준)
```

### 2.2 대기 중 메뉴 선택 → 사전 주문

```text
RPC: pre_order_while_waiting()
← Patent 1 + Patent 2 결합 핵심

선행 조건:
  order_sessions.session_status IN ('WAITING','ARRIVAL_PENDING')
  → SEATED/CANCELLED/NO_SHOW 이면 pre_order_requires_waiting 에러

메뉴 검증 (각 cart_items):
  menus.is_active = true
  menus.menu_status != 'SOLD_OUT'
  → 실패: menu_sold_out 에러 (메뉴명 포함)

처리:
  orders INSERT:
    order_type = 'TABLE'
    order_status = 'CONFIRMED'
    order_source = 'PRE_ORDER'       ← 일반 주문과 구분. 필수.
    order_number = 'W' + wait_number  예: W003

  order_items INSERT: cart_items 각 항목

  kds_tickets INSERT (is_kds_required=true 메뉴마다):
    kds_status = 'HOLD'              ← Patent 2 핵심
    conditions_met.payment_confirmed = false

  order_sessions UPDATE:
    pre_order_amount = 합계 금액

사이드 이펙트:
  ledger.events INSERT: pre_order_registered
    event_payload.patent_note:
      'Patent1+2: Pre-order HOLD until payment confirmed'
```

### 2.3 호출 → 도착 확인 → 착석

```text
RPC: call_waiting_customer()
  선행: session_status IN ('WAITING','ARRIVAL_PENDING')
  처리:
    session_status = 'ARRIVAL_PENDING'
    called_at = now()
    call_count += 1
    table_number 배정 (선택)
  사이드 이펙트:
    did_display_queue INSERT (WAITING_CALL)
    Realtime did:{store_id} → WAITING_CALL
    Realtime waiting:{store_id} → waiting_called
    phone_hash 있으면 push_notification_queued
    ledger.events: waiting_called

RPC: confirm_arrival()
  처리: arrival_confirmed_at = now()
  사이드 이펙트:
    ledger.events: arrival_confirmed

RPC: seat_waiting_customer()
  선행: session_status != 'SEATED'
  처리:
    session_status = 'SEATED'
    seated_at = now()
    table_number 최종 배정
  사이드 이펙트:
    pre_order_amount > 0 이면:
      KDS는 여전히 HOLD 유지     ← 아직 결제 전
      next_step: 'PROCEED_TO_PAYMENT' 반환
    Realtime waiting:{store_id} → waiting_session_seated
    Realtime did:{store_id} → call_dismissed
    did_display_queue UPDATE: DISMISSED
    ledger.events: customer_seated
      wait_duration_seconds 기록
```

### 2.4 결제 → KDS 해제

```text
RPC: confirm_payment()   ← Patent 2 트리거

처리:
  payment_ledger INSERT (APPROVED)
  orders UPDATE: order_status='PAID', paid_at=now()

사이드 이펙트 (자동):
  release_kds_after_payment() 내부 호출
  earn_points_after_order() 호출 (멤버십 포인트)

RPC: release_kds_after_payment()   ← SYSTEM 전용. 외부 직접 호출 금지.

처리:
  kds_tickets UPDATE (해당 order_id 전체):
    kds_status: HOLD → COMMITTED
    committed_at = now()
    conditions_met.payment_confirmed = true
    conditions_met.kds_release_authorized = true

사이드 이펙트:
  Realtime kds:{store_id} → kds_tickets_released
  ledger.events: kds_released_after_payment
```

### 2.5 노쇼 처리

```text
RPC: mark_no_show()
  선행: session_status = 'ARRIVAL_PENDING'
  처리:
    session_status = 'NO_SHOW'
    no_show_at = now()
  사이드 이펙트:
    pre_order_amount > 0 이면:
      kds_tickets UPDATE: HOLD → CANCELLED
    Realtime waiting:{store_id} → waiting_session_cancelled
    ledger.events: no_show_marked
      wait_after_call_seconds 기록

자동 노쇼 (pg_cron WAITING_SESSION_EXPIRE):
  조건: session_status='ARRIVAL_PENDING'
        called_at < now() - interval '15 minutes'
  처리: 위와 동일
```

### 2.6 취소

```text
RPC: cancel_waiting()
  입력: p_actor_type = 'CUSTOMER' | 'STAFF'
  처리:
    session_status = 'CANCELLED'
    cancelled_at = now()
    cancel_reason 기록
  사이드 이펙트:
    pre_order_amount > 0 이면:
      kds_tickets UPDATE: HOLD → CANCELLED
    Realtime waiting:{store_id} → waiting_session_cancelled
    ledger.events: waiting_cancelled
      actor_type 기록
```

---

## 3. 상태별 허용 액션 매트릭스

| session_status | register | call | confirm_arrival | pre_order | seat | cancel | mark_no_show |
|---|---|---|---|---|---|---|---|
| WAITING | ✗ | ✓ | ✗ | ✓ | ✗ | ✓ | ✗ |
| ARRIVAL_PENDING | ✗ | ✓ 재호출 | ✓ | ✓ | ✓ | ✓ | ✓ |
| SEATED | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| COMPLETED | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| CANCELLED | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| NO_SHOW | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |

---

## 4. KDS HOLD 상세 조건

### 4.1 HOLD 진입 조건

아래 세 경우에 KDS 티켓이 HOLD로 생성된다.

```text
Case A: pre_order_while_waiting()
  order_source = 'PRE_ORDER'
  결제 전 대기 중 사전 주문

Case B: place_kiosk_order()
  order_source = 'KIOSK'
  키오스크에서 결제 전 주문 접수

Case C: 일반 테이블 주문 (향후 확장)
  order_source = 'TABLE'
  결제 전 직원이 입력한 주문
```

### 4.2 HOLD 중 화면 표시 규칙

```text
KDS 디스플레이에서 HOLD 티켓:
  배경색: 회색 (#9E9E9E)
  텍스트: "결제 대기 중 / Payment Pending"
  버튼: 비활성화 (조리 시작 불가)
  타이머: 표시 안 함

COMMITTED 전환 후:
  배경색: 녹색 (#4CAF50)
  타이머: 시작
  버튼: 활성화
```

### 4.3 HOLD 해제 단일 경로

```text
HOLD → COMMITTED 는 오직 하나의 경로만 존재한다.

  confirm_payment() 성공
    → payment_ledger.ledger_status = 'APPROVED'
    → release_kds_after_payment() 자동 실행 (SYSTEM 권한)
    → kds_status: HOLD → COMMITTED

직원이 수동으로 HOLD → COMMITTED 전환하는 것은 금지된다.
  (release_kds_after_payment는 SYSTEM 역할 전용)
```

---

## 5. 예외 처리 및 Fallback

### 5.1 결제 실패 후 KDS 상태

```text
결제 실패:
  payment_ledger: FAILED 기록
  kds_tickets: HOLD 유지 (변경 없음)
  → 고객 재결제 가능
  → 취소 선택 시: cancel_waiting() → KDS CANCELLED
```

### 5.2 키오스크 세션 타임아웃

```text
place_kiosk_order() → KDS HOLD 생성
결제 미완료 + idle_timeout_seconds 초과:
  kiosk_sessions: TIMEOUT
  KDS 티켓: HOLD 유지
  pg_cron KIOSK_SESSION_EXPIRE (5분):
    → 수동 정리 또는 자동 CANCELLED 처리
```

### 5.3 DID 장애 Fallback

```text
DID 미응답 상황:
  call_waiting_customer() 계속 정상 실행
  DID 표시 생략
  staff:{store_id} 채널로 직원 앱에 호출 알림
  음성 호출로 임시 운영
  SOP-DID-001 참조
```

### 5.4 네트워크 장애 Fallback

```text
오프라인 상태:
  register_waiting() 실패 가능
  → enqueue_offline_action(CREATE_WAITING_SESSION)
  → flush_offline_queue() 복구 후 자동 동기화

ISP 장애:
  report_network_status(SWITCHED)
  → KT → SKT → LGU+ 자동 전환
  → Realtime 채널 재연결
```

---

## 6. 권한 경계

### 6.1 RPC 호출 권한

| RPC | 허용 호출자 | 비고 |
|---|---|---|
| register_waiting | STAFF, KIOSK(anon), QR(anon), CUSTOMER | 대기 등록 |
| call_waiting_customer | OWNER, MANAGER, STAFF | 직원만 |
| confirm_arrival | CUSTOMER, STAFF | 양측 가능 |
| pre_order_while_waiting | CUSTOMER, KIOSK | 고객/키오스크 |
| seat_waiting_customer | OWNER, MANAGER, STAFF | 직원만 |
| cancel_waiting | CUSTOMER, STAFF | actor_type 기록 필수 |
| mark_no_show | OWNER, MANAGER, STAFF | 직원만 |
| release_kds_after_payment | SYSTEM | 내부 자동 호출 전용 |

### 6.2 직원 권한 매트릭스 연동

```text
check_staff_permission(feature='MANAGE_WAITING') 필요:
  call_waiting_customer
  seat_waiting_customer
  mark_no_show
  cancel_waiting (직원 액터일 때)
```

---

## 7. 감사 및 증빙 요건

### 7.1 Patent 1 감사 쿼리

```sql
-- 대기 파이프라인 전 여정 확인
SELECT event_type, from_state, to_state,
       event_payload, occurred_at
FROM catchmenu_ledger.events
WHERE event_domain = 'waiting'
  AND subject_id = '[session_id]'
ORDER BY occurred_at;

-- 기대 레코드 (순서대로):
-- waiting_registered       null → WAITING
-- pre_order_registered     WAITING → PRE_ORDER
-- waiting_called           WAITING → ARRIVAL_PENDING
-- arrival_confirmed
-- customer_seated          ARRIVAL_PENDING → SEATED
-- kds_released_after_payment HOLD → COMMITTED
```

### 7.2 Patent 2 감사 쿼리

```sql
-- KDS Late Binding 증빙
SELECT kt.kds_status,
       kt.conditions_met,
       kt.committed_at,
       pl.approved_at,
       kt.committed_at >= pl.approved_at AS released_after_payment
FROM catchmenu_kds.kds_tickets kt
JOIN catchmenu_payment.payment_ledger pl
  ON pl.order_id = kt.order_id
WHERE kt.order_id = '[order_id]';

-- 기대 결과:
-- kds_status = 'COMMITTED' (또는 이후)
-- conditions_met.payment_confirmed = true
-- committed_at >= approved_at (결제 후 조리 시작)
```

### 7.3 노쇼 / 취소 증빙

```sql
-- 노쇼 증빙
SELECT event_payload->>'called_at' AS called_at,
       event_payload->>'wait_after_call_seconds' AS seconds,
       occurred_at AS no_show_at
FROM catchmenu_ledger.events
WHERE event_type = 'no_show_marked'
  AND subject_id = '[session_id]';

-- 취소 증빙
SELECT event_payload->>'cancel_reason' AS reason,
       event_payload->>'actor_type' AS actor,
       occurred_at
FROM catchmenu_ledger.events
WHERE event_type = 'waiting_cancelled'
  AND subject_id = '[session_id]';
```

---

## 8. i18n 요건

모든 사용자 메시지는 catchmenu_common.message_catalog 에서 가져온다.
SQL 내 한글 하드코딩 금지. Flutter 내 하드코딩 금지.

| message_key | 사용 위치 | 지원 로케일 |
|---|---|---|
| waiting_registered | register_waiting 반환 | ko/en/zh/ja/vi/th |
| waiting_called_alert | call_waiting_customer + DID | ko/en/zh/ja/vi/th |
| arrival_confirmed | confirm_arrival 반환 | ko/en/zh/ja/vi/th |
| waiting_seated | seat_waiting_customer 반환 | ko/en/zh/ja/vi/th |
| waiting_cancelled | cancel_waiting 반환 | ko/en/zh/ja/vi/th |
| waiting_no_show | mark_no_show 반환 | ko/en/zh/ja/vi/th |
| pre_order_registered | pre_order_while_waiting 반환 | ko/en/zh/ja/vi/th |
| waiting_current_position | get_waiting_status 반환 | ko/en/zh/ja/vi/th |
| waiting_est_time | get_waiting_status 반환 | ko/en/zh/ja/vi/th |
| did_now_calling | DID 화면 표시 | ko/en/zh/ja/vi/th |
| did_please_proceed | DID 화면 표시 | ko/en/zh/ja/vi/th |

---

## 9. 성능 및 용량 제약

```text
max_waiting_count:         기본 30팀 (store_settings)
DID 표시 최대:             20개 (get_did_waiting_numbers)
est_wait_minutes 계산:     queue_position × 10분
호출 자동 노쇼:            15분 (pg_cron)
대기 자동 만료:            2시간 (pg_cron)
일별 대기 정리:            23:30 KST (pg_cron DAILY_WAITING_CLOSE)
DID 호출 자동 해제:        auto_dismiss_at 기준 (pg_cron DID_QUEUE_EXPIRE)
키오스크 세션 타임아웃:    5분 비활성 (pg_cron KIOSK_SESSION_EXPIRE)
```

---

## 10. 변경 시 영향 범위

이 파이프라인을 변경할 때 반드시 함께 검토해야 하는 영역:

```text
order_sessions 테이블 변경:
  → migration 0115, 0128
  → register_waiting, call_waiting_customer,
    seat_waiting_customer, cancel_waiting, mark_no_show
  → get_waiting_admin_view, get_waiting_status
  → Flutter 직원 앱 대기 관리 화면

kds_tickets 상태 변경:
  → migration 0098, 0115, 0114
  → release_kds_after_payment, pre_order_while_waiting, place_kiosk_order
  → Flutter KDS 디스플레이 화면
  → Realtime kds:{store_id} 이벤트 구조

Realtime 페이로드 변경:
  → Flutter 해당 채널 구독 핸들러 전체
  → DID 앱 Realtime 핸들러

ledger event_type 변경:
  → Patent 1 감사 쿼리 영향
  → Patent 2 감사 쿼리 영향
  → 005025 Customer Runtime 거버넌스 영향

i18n message_key 변경:
  → 6개 로케일 전체 동기화 필요
```

---

## 11. Open Issues

- [ ] near-store 감지 방법 미결정
  현재: 고객 선언 또는 직원 선언
  향후: 위치 기반 가능성 검토 (005020 Section 8)

- [ ] est_wait_minutes 고도화
  현재: queue_position × 10분 단순 계산
  향후: 실제 테이블 회전율 기반 계산

- [ ] 사전 주문 수정 기능
  현재: 생성 후 수정 불가 (취소 후 재생성)
  향후: 메뉴 수정 RPC 추가 검토

- [ ] 그룹 대기 (여러 세션 묶음)
  현재: 단일 session_id 기준
  향후: 그룹 대기 기능 검토
