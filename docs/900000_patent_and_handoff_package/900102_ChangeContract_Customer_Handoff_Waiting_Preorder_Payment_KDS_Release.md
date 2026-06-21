# 900102_ChangeContract_Customer_Handoff_Waiting_Preorder_Payment_KDS_Release

Status: In_Progress
Lifecycle: Logic
Owner: TBD
Last Updated: 2026-06-21

---

## 0. Purpose

This change contract defines the safe implementation boundary for the Catch Menu
customer handoff flow covering waiting registration, preorder while waiting,
seating, payment confirmation, and KDS release.

The goal is to let Codex implement a narrow, auditable slice without accidentally
modifying unrelated runtime, payment, POS, KDS, or admin behavior.

Related Overview:  900100_Overview_Customer_Waiting_Handoff_And_Late_Binding_Pipeline.md
Related Logic:     900101_Logic_Customer_Waiting_Handoff_And_Late_Binding_Pipeline.md
Related TestPlan:  900103_TestPlan_Customer_Handoff_Waiting_Preorder_Payment_KDS_Release.md

---

## 1. Business Claim Protected By This Change

Catch Menu converts waiting time into order-preparation time while preserving kitchen safety.

```text
Customer waits
  → customer preorders
  → KDS ticket appears in HOLD
  → customer is seated
  → payment is approved (server-side)
  → KDS releases to COMMITTED
  → kitchen cooks immediately
```

The protected patent/business-value point:

```text
KDS visibility before payment:  ALLOWED
KDS execution before payment:   FORBIDDEN
```

---

## 2. Source of Truth

### 2.1 Session Source of Truth

`order_sessions` owns the customer's handoff position.

```text
Primary states:
  WAITING → ARRIVAL_PENDING → SEATED → COMPLETED

Exception states:
  WAITING          → CANCELLED
  ARRIVAL_PENDING  → NO_SHOW / CALL_EXPIRED
  SEATED           → PAYMENT_PENDING / PAYMENT_FAILED / CANCELLED
```

### 2.2 Order Source of Truth

`orders` is created when the customer submits a preorder or a normal seated order.

For waiting preorder:

```text
orders.order_source = PRE_ORDER
orders.order_number links to waiting number or session reference
orders.session_id   links to order_sessions.id
```

### 2.3 KDS Source of Truth

`kds_tickets` owns kitchen action state.

```text
Allowed main path:
  HOLD → COMMITTED → COOKING → READY → SERVED

Forbidden direct transitions:
  HOLD      → COOKING        (결제 없이 조리 시작 금지)
  HOLD      → READY          (결제 없이 준비 처리 금지)
  HOLD      → SERVED         (결제 없이 서빙 처리 금지)
  COMMITTED → HOLD           (결제 취소는 별도 환불 흐름)
```

`HOLD`      = 보임. 비활성. 조리 불가.
`COMMITTED` = 결제 확인 완료. 조리 가능.

### 2.4 Payment Source of Truth

`payment_ledger` owns payment confirmation state.

```text
클라이언트 측 결제 성공 화면  ≠  결제 완료
서버 측 payment_ledger.status = APPROVED  =  결제 완료
```

---

## 3. Core Non-Negotiable Invariants

### INV-001 — KDS Release Requires Approved Payment

```text
kds_tickets.kds_status 는 payment_ledger.status = APPROVED 후에만
HOLD → COMMITTED 로 전환될 수 있다.
```

### INV-002 — Seating Is Not Payment

```text
order_sessions.status = SEATED 는 KDS 를 release 하지 않는다.
착석은 결제가 아니다.
```

### INV-003 — Calling Is Not Payment

```text
order_sessions.status = ARRIVAL_PENDING 는 KDS 를 release 하지 않는다.
호출은 결제가 아니다.
```

### INV-004 — Client Is Not Release Authority

```text
고객 앱, 직원 앱, DID, KDS UI 는
HOLD 티켓을 직접 release 할 수 없다.
release_kds_after_payment() 는 SYSTEM 역할 전용이다.
confirm_payment() 내부에서만 호출된다.
```

### INV-005 — Release Is Idempotent

```text
동일 order_id 에 대해 duplicate payment callback,
duplicate confirm, retry 가 들어와도
KDS release 는 한 번만 일어난다.

SQL 패턴 필수:
  UPDATE kds_tickets
  SET kds_status = 'COMMITTED', committed_at = now(), ...
  WHERE order_id = p_order_id
    AND kds_status = 'HOLD'    ← 이 조건이 idempotency 핵심
  RETURNING id;
```

### INV-006 — Ledger Evidence Is Required

```text
모든 handoff 전환은 catchmenu_ledger.events 에
before_state, after_state, actor, surface, timestamp,
correlation_id 를 포함한 event 를 기록해야 한다.
증빙 없는 상태 전환은 Patent 2 감사 요건 위반이다.
```

---

## 4. Allowed Implementation Scope

Codex 는 한 번에 하나의 명시적으로 승인된 Scope 만 구현한다.

### Scope D — Server Runtime Guard ← 반드시 1순위

**이유:**

```text
UI 가 아무리 잘 만들어져도
서버 Guard 가 없으면 전체 시스템이 안전하지 않다.
INV-001~006 은 서버에서 강제되어야 한다.
```

**허용 파일:**

```text
supabase/migrations/
  0136_patch_release_kds_idempotency.sql   (신규 파일만)

supabase/functions/
  toss-payments-confirm/index.ts
  toss-payments-webhook/index.ts
```

**구현 범위:**

```text
1. confirm_payment() idempotency
   동일 order_id + APPROVED 이미 존재 → release 재실행 없이 기존 결과 반환

2. release_kds_after_payment() idempotency
   WHERE kds_status = 'HOLD' 조건으로 중복 UPDATE 방지

3. toss-payments-confirm Edge Function
   토스 서버 검증 → 성공 시만 confirm_payment() 호출
   실패 → payment_ledger FAILED 기록
   중복 → APPROVED 이미 있으면 200 반환

4. toss-payments-webhook Edge Function
   시그니처 검증 → DONE 이벤트만 confirm_payment() 호출
   이미 처리된 orderId → 200 반환

5. ledger event 기록
   confirm_payment()          → PAYMENT_APPROVED event
   release_kds_after_payment()→ KDS_RELEASED_AFTER_PAYMENT event
```

**Scope D 금지:**

```text
seat_waiting_customer() 내부에서 release 호출 금지
call_waiting_customer() 내부에서 release 호출 금지
Flutter 클라이언트에서 release_kds_after_payment() 직접 호출 금지
kds_tickets 를 HOLD 조건 없이 UPDATE 금지
기존 migration 파일 수정 금지
RLS 정책 변경 금지
```

---

### Scope C — KDS 디스플레이 화면 (Scope D 통과 후)

**허용 파일:**

```text
lib/features/kds/
  kds_screen.dart
  kds_ticket_card.dart
  kds_state_notifier.dart
  kds_repository.dart
lib/services/supabase/
  kds_supabase_service.dart
```

**허용 동작:**

```text
HOLD 티켓: 회색 배경 + 조리 버튼 disabled + 타이머 미표시
  표시 텍스트: "결제 대기 중 / Payment Pending"
COMMITTED: Realtime 수신 후 녹색 + 버튼 활성 + 타이머 시작
COOKING/READY/SERVED: transition_kds_ticket() 전환 버튼
HOLD 티켓에 "강제 해제" 또는 "시작" 버튼 없음
```

**Scope C 금지:**

```text
KDS UI 에서 release_kds_after_payment() 호출 금지
HOLD → COOKING 직접 전환 금지
kds_status 를 로컬 상태로 임의 변경 금지
```

---

### Scope A — 고객 앱 (Scope D 통과 후)

**허용 파일:**

```text
lib/features/waiting/
  waiting_register_screen.dart
  waiting_status_screen.dart
  pre_order_screen.dart
  pre_order_state_notifier.dart
  waiting_repository.dart
lib/features/payment/
  payment_screen.dart
  toss_payment_widget.dart
  payment_result_handler.dart
lib/services/supabase/
  waiting_supabase_service.dart
  payment_supabase_service.dart
```

**허용 동작:**

```text
대기 등록, 대기 현황, 사전 주문, 결제 프롬프트
onSuccess 후 confirm_payment() 서버 호출
서버 APPROVED 응답 전까지 "결제 확인 중..." 표시
서버 APPROVED 확인 후에만 완료 UI
```

**Scope A 금지:**

```text
onSuccess 직후 완료 UI 표시 금지
release_kds_after_payment() 직접 호출 금지
SEATED 이벤트만으로 결제 완료 처리 금지
```

---

### Scope B — 직원 앱 (Scope D 통과 후)

**허용 파일:**

```text
lib/features/waiting_admin/
  waiting_admin_screen.dart
  waiting_list_tile.dart
  waiting_admin_state_notifier.dart
  waiting_admin_repository.dart
```

**허용 동작:**

```text
대기 목록 관리, 호출, 도착 확인, 착석/테이블 배정
노쇼/호출만료 처리
사전주문/결제/KDS 상태 read-only 표시
```

**Scope B 금지:**

```text
KDS 수동 release 금지
결제 처리 금지
kds_status 직접 변경 금지
```

---

### Scope E — DID 디스플레이 (Scope D 통과 후)

**허용 파일:**

```text
lib/features/did/
  did_screen.dart
  did_call_overlay.dart
  did_waiting_list.dart
  did_state_notifier.dart
  did_repository.dart
```

---

## 5. Required Codex Input Before Work

Codex 는 아래 항목이 모두 채워진 후에만 코드를 수정한다.

```text
승인된 Scope: A / B / C / D / E
허용 파일 목록
금지 파일 목록
관련 DB 테이블
관련 RPC/함수
관련 Realtime 채널
추가/수정할 테스트 파일
검증 명령어
롤백 지시
```

하나라도 빠지면 Codex 는 코드를 수정하지 않는다.

---

## 6. Event Contract

모든 상태 전환은 아래 필드를 포함한 event 를 기록해야 한다.

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
result
failure_reason      (nullable)
idempotency_key     (nullable)
correlation_id
created_at
```

정상 경로 필수 event sequence:

```text
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

규칙:

```text
PAYMENT_APPROVED event 없이 KDS_RELEASED_AFTER_PAYMENT event 존재 불가
duplicate payment callback → release event 중복 생성 불가
blocked transition attempt → blocked event 기록 필수
```

---

## 7. Failure Contract

### F-001: Payment Failure

```text
결제 실패 → KDS HOLD 유지 → event 기록 → 고객 재시도/수정 경로 표시
```

### F-002: Duplicate Payment Confirmation

```text
중복 confirm/webhook → release 미재실행 → idempotent event 기록
```

### F-003: No-Show / Call Expired

```text
ARRIVAL_PENDING → NO_SHOW 또는 CALL_EXPIRED → KDS HOLD 유지 → 사전주문 미조리
```

### F-004: Sold-Out Before Payment

```text
결제 전 품절 감지 → 결제 차단 또는 장바구니 재계산 → KDS HOLD 유지
```

### F-005: Unauthorized KDS Release Attempt

```text
미승인 결제 상태에서 release 시도 → 거부 → blocked event 기록
```

### F-006: Table Change Before Payment

```text
착석 후 테이블 변경 → order session 업데이트 → KDS HOLD 유지
결제 금액 및 주문 식별자 변경 없음
```

### F-007: Table Change After KDS Release

```text
COMMITTED 후 테이블 변경 → KDS 표시 업데이트 → kds_status HOLD 로 회귀 없음
```

---

## 8. Forbidden Files (All Scopes)

```text
payment provider settlement core
POS reconciliation core
production menu pricing policy
unrelated admin dashboard files
unrelated KDS queue optimization files
unrelated customer identity/account files
catchmenu_ledger.events 스키마 변경
catchmenu_payment.payment_ledger 스키마 변경
RLS 정책 변경
기존 migration 파일 수정
```

---

## 9. Rollback Rule

아래 중 하나라도 발생하면 즉시 롤백:

```text
결제 없이 KDS release 가능
결제 실패 시 KDS release 발생
중복 결제로 중복 release 발생
기존 일반 착석 주문 흐름 중단
기존 KDS 조리 흐름 중단
상태 전환에 ledger event 누락
RLS/보안 테스트 실패
승인된 파일 경계 외 diff 발생
```

---

## 10. Human Approval Gate

Codex 가 코드를 수정하기 전에 Human 이 승인해야 한다.

```text
[ ] 선택한 Scope: ___
[ ] INV-001~006 확인 완료
[ ] 허용 파일 목록 승인
[ ] 금지 파일 목록 승인
[ ] TestPlan 900103 확인 완료
[ ] Rollback Rule 확인 완료
[ ] 검증 명령어 확인: ___

Owner 서명: _______________
Date:       _______________
```

---

## 11. Verification Commands

실제 프로젝트 명령어로 교체 후 사용:

```bash
# Flutter 테스트
flutter test

# grep: Flutter 클라이언트에 직접 호출 없음 확인
grep -r "release_kds_after_payment" lib/
# 기대 결과: 0건

# grep: Supabase functions 에만 존재 확인
grep -r "release_kds_after_payment" supabase/functions/
# 기대 결과: toss-payments-confirm 과 toss-payments-webhook 에만

# DB 통합 테스트
SELECT catchmenu_common.run_integration_test(
  '00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000002'
);
```

Codex 는 실행한 명령어와 결과를 raw_logs/ 에 저장한다.

---

## 12. Scope Execution Order

```text
1순위: Scope D — Server Runtime Guard
2순위: Scope C — KDS HOLD/COMMITTED UI
3순위: Scope A — 고객 결제 handoff 화면
4순위: Scope B — 직원 대기/착석 화면
5순위: Scope E — DID 투영
```

이 순서를 바꾸지 않는다.
