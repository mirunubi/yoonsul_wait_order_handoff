# 900110_Overview_Channel_1_Web_App_Customer_Handoff_And_Session

Status: In_Progress
Lifecycle: Overview
Owner: TBD
Last Updated: 2026-06-21

---

## 0. Document Purpose

이 Overview 는 Channel 1 웹앱의 고객 Handoff 구현 컨텍스트를 정의한다.

웹앱은 고객이 앱 설치 없이 QR 스캔만으로 대기 등록,
메뉴 탐색, 사전 주문, 결제까지 진행하는 채널이다.

세션 관리가 이 채널의 가장 취약한 영역이다.
브라우저 탭 = 세션이기 때문에
탭 닫힘, 새 탭, 브라우저 캐시 삭제가 모두 세션 소멸을 일으킨다.

Related Logic: 900111_Logic_Channel_1_Web_App_Customer_Handoff_And_Session.md

---

## 1. 채널 정의

```text
채널명: Web App (웹앱)
접근 방법: QR 스캔 → 브라우저 자동 실행
설치 요구: 없음
인증 요구: 없음 (anon)
대상 고객: 외국인 포함 모든 방문 고객
KDS 접근: 없음 (고객 전용)
멤버십: 없음 (게스트 세션)
```

---

## 2. 웹앱 고객 진입 흐름

```text
QR 스캔
  ↓ (브라우저 자동 실행)
웹앱 URL 로드
  ↓
Supabase anon 세션 생성
  ↓
매장 컨텍스트 로드 (bootstrap_customer_app_v2)
  ↓
언어 선택 (ko/en/zh/ja/vi/th)
  ↓
대기 등록 (register_waiting)
  → session_id 발급
  → wait_number 발급
  → localStorage 에 session_id 저장
  ↓
대기 중 메뉴 탐색 (get_kiosk_menu)
  ↓
사전 주문 (pre_order_while_waiting) ← 선택
  → KDS HOLD 생성
  ↓
Realtime 대기 현황 구독 (waiting:{store_id})
  ↓
호출 수신 (Realtime 또는 브라우저 push)
  ↓
결제 (confirm_payment via 토스페이먼츠)
  ↓
주문 추적 (get_order_tracking)
```

---

## 3. 세션 아키텍처

### 3.1 세션 식별자 구조

```text
웹앱 세션은 두 레이어로 구성된다.

Layer 1: Supabase anon 세션
  Supabase 가 자동 발급하는 JWT (1시간 유효)
  브라우저 localStorage 에 저장
  만료 시 자동 갱신 (Supabase SDK 처리)

Layer 2: 캐치메뉴 order_sessions
  register_waiting() 호출 시 생성
  session_id (UUID)
  브라우저 localStorage 에 session_id 저장

두 레이어가 분리되어 있다.
Supabase 세션이 갱신되어도 session_id 는 유지된다.
```

### 3.2 세션 저장 위치

```text
localStorage 저장 항목:
  catchmenu_session_id:   order_sessions.id
  catchmenu_store_id:     현재 매장 ID
  catchmenu_wait_number:  W-007
  catchmenu_locale:       ko / en / zh / ja / vi / th
  catchmenu_order_id:     orders.id (사전 주문 후)

저장 시점:
  register_waiting() 성공 직후 → session_id 저장
  pre_order_while_waiting() 성공 직후 → order_id 저장

복구 시점:
  페이지 재로드 시 localStorage 확인
  session_id 존재하면 get_waiting_status() 로 현재 상태 복구
```

### 3.3 세션 수명

```text
정상 수명:
  대기 등록부터 주문 완료까지
  평균 30분 ~ 2시간

세션 소멸 조건:
  브라우저 탭 닫힘       → localStorage 유지 (세션 복구 가능)
  브라우저 완전 종료     → localStorage 유지 (세션 복구 가능)
  시크릿 모드 탭 닫힘   → localStorage 소멸 (세션 복구 불가)
  localStorage 수동 삭제 → 세션 복구 불가
  pg_cron 2시간 만료     → 서버 세션 CANCELLED

자동 만료 (서버):
  pg_cron WAITING_SESSION_EXPIRE
  WAITING 상태 2시간 → CANCELLED
  ARRIVAL_PENDING 호출 후 15분 무응답 → NO_SHOW
```

---

## 4. 관련 RPC 및 DB

### 4.1 웹앱 전용 RPC 흐름

| 단계 | RPC | 비고 |
|---|---|---|
| 부트스트랩 | bootstrap_customer_app_v2 | 매장 정보, 운영 상태 |
| QR 진입 | qr_scan_action(WAITING_REGISTER) | anon 가능 |
| 대기 등록 | register_waiting | anon 가능. phone_hash 선택 |
| 대기 현황 | get_waiting_status | session_id 기반 |
| 메뉴 조회 | get_kiosk_menu | store_id 기반 |
| 사전 주문 | pre_order_while_waiting | session_id 필수 |
| 결제 | confirm_payment | order_id 필수 |
| 주문 추적 | get_order_tracking | order_id 기반 |

### 4.2 관련 DB 테이블

| 테이블 | 역할 |
|---|---|
| order_sessions | 세션 원장. anon 고객도 row 생성 |
| orders | 주문 원장. order_source=PRE_ORDER |
| kds_tickets | KDS 티켓. HOLD 상태 |
| payment_ledger | 결제 원장 |
| customers | 웹앱에서는 생성 안 됨 (게스트) |

---

## 5. Realtime 채널

| 채널 | 구독 조건 | 수신 이벤트 |
|---|---|---|
| waiting:{store_id} | 대기 등록 직후 | waiting_called, waiting_session_seated |
| customer_app:{store_id} | 결제 완료 후 | order_status_changed |

웹 브라우저 push 알림:
```text
Notification API 권한 요청
iOS Safari: 제한적 (홈 화면 추가 시에만 가능)
Android Chrome: 가능
권한 거부 시: Realtime 폴링 또는 화면 내 상태 표시로 fallback
```

---

## 6. 웹앱 제약 사항

```text
KDS 접근: 없음
멤버십 포인트 적립: 없음 (게스트)
푸시 알림: 브라우저 권한 필요 (iOS 제한)
이전 주문 이력: localStorage 기반 (기기 변경 시 소멸)
결제 후 영수증: 화면 표시 + URL 공유 가능
세션 복구: localStorage session_id 기반 (시크릿 모드 불가)
```

---

## 7. Flutter 구현 대상

웹앱은 Flutter Web 빌드.

| 화면 | Primary RPC | 세션 의존 |
|---|---|---|
| 랜딩 (QR 진입) | bootstrap_customer_app_v2 | store_id |
| 언어 선택 | locale 설정 | — |
| 대기 등록 | register_waiting | anon |
| 대기 현황 | get_waiting_status | session_id |
| 메뉴 탐색 | get_kiosk_menu | store_id |
| 사전 주문 | pre_order_while_waiting | session_id |
| 결제 | confirm_payment | order_id |
| 주문 추적 | get_order_tracking | order_id |
| 완료 | — | — |

---

## 8. 세션 복구 흐름

```text
페이지 재로드 시:

  1. localStorage 에서 session_id 읽기
  2. session_id 없으면 → 신규 대기 등록 화면
  3. session_id 있으면 → get_waiting_status(session_id) 호출
  4. 세션 상태별 화면 복구:
     WAITING          → 대기 현황 화면
     ARRIVAL_PENDING  → "입장해주세요" 안내 화면
     SEATED           → 결제 화면 (next_step: PROCEED_TO_PAYMENT)
     COMPLETED        → 완료 화면
     CANCELLED        → "대기가 취소되었습니다" 화면
     NO_SHOW          → "대기가 만료되었습니다" 화면
  5. 서버 세션 없으면 (만료) → localStorage 초기화 → 신규 등록 화면
```

---

## 9. Out Of Scope

```text
로그인 / 회원가입 (Channel 2, 3, 4)
멤버십 포인트 적립
이전 방문 이력
KDS 화면
직원 앱 기능
관리자 기능
```
