# 900103_TestPlan_Customer_Handoff_Waiting_Preorder_Payment_KDS_Release

Status: In_Progress
Lifecycle: Logic
Owner: TBD
Last Updated: 2026-06-21

---

## 0. Purpose

This test plan verifies the Catch Menu customer handoff journey from store entry
to served order, with special focus on waiting-session preorder,
payment-confirmed KDS release, and immutable audit evidence.

The purpose is not to test generic ordering only.
The purpose is to prove the business-critical handoff claim:

> Waiting time becomes order-preparation time,
> while kitchen execution remains blocked until payment confirmation.

Related ChangeContract:
  900102_ChangeContract_Customer_Handoff_Waiting_Preorder_Payment_KDS_Release.md

---

## 1. Actors And Devices

| Actor | Device | Responsibility |
|---|---|---|
| Customer | Customer app / mobile | Entry, waiting, preorder, payment |
| Staff | Staff app / admin | Call, arrival confirm, seating, exception |
| Kitchen staff | KDS | Receives HOLD/COMMITTED/COOKING/READY/SERVED |
| Store display | DID | Waiting/call status only. No payment detail. |
| Server runtime | API, DB, Realtime, Ledger | State transitions, audit, idempotency, release authority |

---

## 2. State Model Under Test

### 2.1 Waiting / Order Session

```text
null → WAITING → ARRIVAL_PENDING → SEATED → COMPLETED

Exception paths:
  WAITING          → CANCELLED
  ARRIVAL_PENDING  → NO_SHOW / CALL_EXPIRED
  SEATED           → PAYMENT_PENDING / PAYMENT_FAILED / CANCELLED
```

### 2.2 KDS Ticket

```text
HOLD → COMMITTED → COOKING → READY → SERVED

Forbidden direct transitions:
  HOLD      → COOKING      결제 없이 조리 금지
  HOLD      → READY        결제 없이 준비 금지
  HOLD      → SERVED       결제 없이 서빙 금지
  COMMITTED → HOLD         결제 취소는 환불 흐름 사용
```

---

## 3. Core Invariant

```text
대기 중 생성된 사전 주문은 KDS 티켓을 만들 수 있다.
단, 티켓은 서버 측 결제 확인이 완료될 때까지
HOLD 이며 비활성 상태를 유지해야 한다.
```

KDS release 가 성립하려면 아래 모두 충족:

```text
payment_ledger.status = APPROVED
payment_ledger.order_id = kds_tickets.order_id
서버 측 검증 완료
release operation idempotent
ledger event 기록 완료
conditions_met.payment_confirmed = true
```

---

## 4. Normal Path Test Cases

### TC-001 — QR Entry and Store Context Bootstrap

```text
Given  유효한 매장 QR 코드가 존재
When   고객이 QR 코드를 스캔
Then   qr_scan_action() 이 스캔 이벤트를 기록
And    bootstrap_customer_app_v2() 가 매장 컨텍스트를 로드
And    언어 선택 옵션이 표시됨
And    주문은 아직 생성되지 않음

Expected ledger events:
  CUSTOMER_QR_SCANNED
  CUSTOMER_APP_BOOTSTRAPPED
  LANGUAGE_SELECTED
```

---

### TC-002 — Waiting Registration

```text
Given  고객 앱이 부트스트랩됨
When   고객이 인원 수를 입력하고 대기 등록
Then   register_waiting() 이 order_sessions 를 생성
And    session_status = WAITING
And    wait_number = W-007 발급
And    DID 및 직원 앱 프로젝션 갱신

Expected state:
  order_sessions.status = WAITING
  order_sessions.wait_number = W-007
  orders.id = null (사전 주문 전)
```

---

### TC-003 — Preorder While Waiting Creates KDS HOLD

```text
Given  session_status = WAITING
When   고객이 메뉴를 선택하고 사전 주문 제출
Then   pre_order_while_waiting() 이 orders 를 생성
And    orders.order_source = PRE_ORDER
And    orders.order_number 은 wait_number 에 연결됨
And    KDS 티켓이 HOLD 상태로 생성됨
And    주방 조리 버튼이 비활성화됨

Expected KDS state:
  kds_tickets.kds_status = HOLD
  kds_tickets.conditions_met.payment_confirmed = false
  kds_tickets.committed_at = null
```

---

### TC-004 — Staff Calls Waiting Customer

```text
Given  session_status = WAITING
When   직원이 대기 고객을 호출
Then   call_waiting_customer() 가 session 을 ARRIVAL_PENDING 으로 변경
And    DID 에 호출 번호가 표시됨
And    고객 앱에 Realtime/push 알림 전달
And    직원 앱에 호출 상태 표시
And    KDS 는 HOLD 유지

Invariant check:
  호출은 KDS 를 release 하지 않는다
```

---

### TC-005 — Seat Assignment

```text
Given  session_status = ARRIVAL_PENDING
When   직원이 도착을 확인하고 테이블을 배정
Then   seat_waiting_customer() 가 session 을 SEATED 으로 변경
And    table_number 이 바인딩됨
And    DID 에서 호출 번호가 제거됨
And    고객 앱에 next_step = PROCEED_TO_PAYMENT 반환
And    KDS 는 HOLD 유지

Invariant check:
  착석은 KDS 를 release 하지 않는다
```

---

### TC-006 — Payment Approval Releases KDS

```text
Given  session_status = SEATED
And    KDS tickets 가 HOLD 상태
When   서버 측 결제 확인이 성공
Then   confirm_payment() 가 payment_ledger.status = APPROVED 를 기록
And    release_kds_after_payment() 가 서버 측에서 자동 호출
And    kds_status: HOLD → COMMITTED
And    committed_at 이 기록됨
And    주방 조리 버튼이 활성화됨
And    KDS 타이머가 시작됨

Expected KDS state:
  kds_tickets.kds_status = COMMITTED
  kds_tickets.conditions_met.payment_confirmed = true
  kds_tickets.committed_at IS NOT NULL
```

---

### TC-007 — Kitchen Flow

```text
Given  kds_status = COMMITTED
When   주방 직원이 조리 시작
Then   COMMITTED → COOKING
When   주방이 완료 처리
Then   COOKING → READY
When   직원이 서빙
Then   READY → SERVED
```

---

### TC-008 — Order Completion And Ledger Evidence

```text
Given  필수 KDS 티켓이 모두 SERVED
When   완료 조건 충족
Then   order_status = COMPLETED
And    catchmenu_ledger.events 에 전체 handoff 증거 체인 존재
And    operation_metrics 갱신

Required evidence chain:
  CUSTOMER_QR_SCANNED
  CUSTOMER_APP_BOOTSTRAPPED
  WAITING_REGISTERED
  PREORDER_CREATED
  KDS_HOLD_CREATED
  WAITING_CUSTOMER_CALLED
  CUSTOMER_SEATED
  PAYMENT_APPROVED
  KDS_RELEASED_AFTER_PAYMENT
  KDS_COOKING_STARTED
  KDS_READY
  KDS_SERVED
  ORDER_COMPLETED
```

---

## 5. Failure And Edge Case Test Cases

### TC-101 — Payment Failure Does Not Release KDS

```text
Given  kds_status = HOLD
When   결제 확인 실패
Then   payment_ledger 에 실패 기록
And    kds_status = HOLD 유지
And    주방 조리 버튼 비활성 유지

Forbidden result:
  결제 실패 + kds_status = COMMITTED
```

---

### TC-102 — Duplicate Payment Confirmation Is Idempotent

```text
Given  결제 확인 완료 및 KDS 이미 COMMITTED
When   중복 confirm callback 또는 webhook 수신
Then   KDS release 중복 발생 없음
And    committed_at 덮어쓰기 없음
And    중복 이벤트는 idempotent 로 audit 기록

Expected result:
  payment approval: 1건
  KDS release: 1건
  duplicate event: audit 기록 허용
```

---

### TC-103 — Client Cannot Directly Release KDS

```text
Given  고객/직원 클라이언트가 KDS release 엔드포인트 직접 호출 시도
When   서버 측 결제 미확인 상태
Then   요청이 거부됨
And    kds_status = HOLD 유지

코드 검증:
  grep -r "release_kds_after_payment" lib/
  → 결과: 0건 (Flutter 코드에 없어야 함)

  release_kds_after_payment() DB GRANT:
    service_role 또는 SYSTEM 만 허용
    authenticated 미포함
```

---

### TC-104 — Customer No-Show After Call

```text
Given  session_status = ARRIVAL_PENDING
When   호출 만료 또는 직원이 노쇼 처리
Then   session_status = NO_SHOW 또는 CALL_EXPIRED
And    DID 에서 호출 번호 제거 또는 우선순위 낮춤
And    kds_status = HOLD 유지
And    사전 주문 미조리
```

---

### TC-105 — Seat Assignment Without Preorder

```text
Given  고객이 사전 주문 없이 대기 등록
When   직원이 착석 처리
Then   KDS 티켓 없음
And    고객 앱은 일반 주문/결제 흐름으로 진행
```

---

### TC-106 — Menu Item Sold Out During Waiting

```text
Given  고객이 대기 중 사전 주문 완료
When   결제 전 주문 항목이 품절 처리됨
Then   결제가 차단되거나 장바구니가 재계산됨
And    kds_status = HOLD 유지
And    고객에게 수정 흐름 제공
```

---

### TC-107 — Table Change Before Payment

```text
Given  고객이 테이블 A 에 착석
When   결제 전 직원이 테이블 B 로 변경
Then   order_sessions.table_number 업데이트
And    kds_status = HOLD 유지
And    결제 금액 및 주문 식별자 변경 없음
```

---

### TC-108 — Table Change After KDS Release

```text
Given  결제 승인 완료, kds_status = COMMITTED
When   직원이 테이블 변경
Then   KDS 표시의 테이블 배정이 업데이트됨
And    kds_status 가 HOLD 로 회귀하지 않음
```

---

### TC-109 — Staff Attempts to Start HOLD Ticket

```text
Given  kds_status = HOLD
When   주방 직원이 조리 시작 버튼 클릭 시도
Then   UI 에서 액션이 disabled 상태
And    서버가 직접 전환 시도를 거부
And    blocked transition event 기록됨
```

---

### TC-110 — Partial Payment Or Amount Mismatch

```text
Given  사전 주문 금액 = 18,000원
When   결제 승인 금액이 기대 금액과 다름
Then   KDS release 없음
And    결제 이벤트가 검토 대상으로 플래그 또는 정책에 의해 거부됨
```

---

## 6. Realtime Projection Tests

| Test | Trigger | Expected Projection |
|---|---|---|
| RT-001 | Waiting registered | DID 와 직원 앱 목록 갱신 |
| RT-002 | Preorder submitted | KDS 에 HOLD 티켓만 표시 |
| RT-003 | Customer called | DID 호출 화면 + 고객 push/realtime 알림 |
| RT-004 | Customer seated | DID 호출 번호 제거, 고객에게 결제 단계 표시 |
| RT-005 | Payment approved | KDS HOLD → COMMITTED 전환 |
| RT-006 | KDS COOKING/READY/SERVED | 직원 앱 상태 갱신 |

---

## 7. Security And Permission Tests

| Test | Actor | Forbidden Action | Expected Result |
|---|---|---|---|
| SEC-001 | Customer | 대기 상태 직접 변경 | 거부 |
| SEC-002 | Customer | KDS 직접 release | 거부 |
| SEC-003 | Staff | 결제 승인 없이 KDS release | 거부 |
| SEC-004 | Kitchen | HOLD 티켓 조리 시작 | 거부 |
| SEC-005 | Anonymous | 타인 세션 접근 | 거부 |
| SEC-006 | Client app | payment-approved 플래그 위조 | 거부 |

---

## 8. Audit Evidence Tests

모든 상태 변경 액션은 아래 필드를 포함한 event 를 기록해야 한다:

```text
event_id
store_id
session_id
order_id            (nullable)
kds_ticket_id       (nullable)
actor_type
actor_id            (nullable)
device_surface
event_type
before_state
after_state
idempotency_key     (nullable)
correlation_id
created_at
result
failure_reason      (nullable)
```

감사 검증 규칙:

```text
event 순서는 실제 handoff 타임라인과 일치해야 함
PAYMENT_APPROVED event 없이 KDS_RELEASED_AFTER_PAYMENT event 존재 불가
중복 payment callback 으로 release event 중복 생성 불가
blocked transition attempt 는 반드시 기록됨
ledger 는 append-only 또는 승인된 감사 정책으로 보호
```

---

## 9. Performance Acceptance Criteria

| Area | Acceptance Criteria |
|---|---|
| QR bootstrap | 매장 컨텍스트가 앱 성능 기준 내에 로드 |
| Waiting registration | DID/직원 앱 프로젝션 near-realtime 갱신 |
| KDS HOLD creation | 티켓이 조리 컨트롤 활성화 없이 표시 |
| Payment to KDS release | 직원 수동 갱신 없이 KDS 가 COMMITTED 로 전환 |
| Realtime updates | 상태 변경 후 stale state 없음 |
| Duplicate webhook | 중복 release 또는 중복 주문 생성 없음 |

---

## 10. Test Data

```text
store_id:          STORE_TEST_001
wait_number:       W-007
table_number:      T-03
party_size:        2
language:          ko
pre_order_amount:  18000
order_source:      PRE_ORDER
payment_provider:  TossPayments sandbox 또는 승인된 mock
kds_initial_state: HOLD
```

---

## 11. Phase 1 (Scope D) 통과 기준

아래 모두 통과 후에만 Scope C/A/B/E 진입:

```text
[ ] TC-001 QR entry + bootstrap
[ ] TC-002 Waiting registration
[ ] TC-003 Preorder → KDS HOLD
[ ] TC-004 Call → KDS HOLD 유지
[ ] TC-005 Seat → KDS HOLD 유지
[ ] TC-006 Payment → KDS COMMITTED
[ ] TC-007 Kitchen flow
[ ] TC-008 Ledger evidence chain
[ ] TC-101 Payment failure → HOLD 유지
[ ] TC-102 Duplicate payment idempotency
[ ] TC-103 Client direct release 불가
[ ] TC-109 Staff HOLD ticket blocked

하나라도 실패: Scope D 수정 후 재검증. 다음 Scope 진입 금지.
```

---

## 12. Claude 감리 제출 항목

Scope D 완료 후 Claude 감리 시 제출:

```text
[ ] git diff (허용 파일 외 변경 없음)
[ ] grep 결과: "release_kds_after_payment" in lib/ → 0건
[ ] grep 결과: "release_kds_after_payment" in supabase/functions/ → 2개 파일만
[ ] idempotency SQL WHERE kds_status = 'HOLD' 존재 확인
[ ] ledger event 13개 체인 확인
[ ] TC-001~TC-103 raw log (raw_logs/ 폴더)
[ ] TC-109 blocked transition log
```

---

## 13. Verification Commands

```bash
# Flutter 테스트
flutter test

# 직접 호출 없음 확인
grep -r "release_kds_after_payment" lib/
# 기대: 0건

grep -r "release_kds_after_payment" supabase/functions/
# 기대: toss-payments-confirm, toss-payments-webhook 2개 파일만

# DB 통합 테스트
SELECT catchmenu_common.run_integration_test(
  '00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000002'
);

# raw log 저장
flutter test 2>&1 | tee raw_logs/flutter_test_$(date +%Y%m%d_%H%M%S).log
```

---

## 14. Acceptance Gate

아래 모두 충족 시에만 이 TestPlan 통과:

```text
[ ] 정상 7단계 handoff 통과
[ ] 결제 승인 전 KDS release 없음
[ ] 착석만으로 KDS release 없음
[ ] 호출만으로 KDS release 없음
[ ] 결제 실패로 KDS release 없음
[ ] 중복 결제 확인이 idempotent
[ ] 미승인 KDS release 시도 차단됨
[ ] ledger 에 완전한 handoff 증거 체인
[ ] 고객 앱/직원 앱/DID/KDS 에 Realtime 일관성
[ ] 모든 실패가 복구 가능하고 감사 가능한 상태 생성
```

---

## 15. Codex Implementation Boundary Note

이 TestPlan 은 검증 문서이지 구현 승인서가 아니다.
Codex 는 900102 ChangeContract 의 Human Approval Gate
서명 후에만 코드를 수정한다.
