# 900120_Overview_Channel_2_Catch_Menu_Native_App_Customer_Handoff_And_Session

Status: In_Progress
Lifecycle: Overview
Owner: TBD
Last Updated: 2026-06-21

---

## 0. Document Purpose

이 Overview 는 Channel 2 캐치메뉴 자체 앱의 고객 Handoff 구현 컨텍스트를 정의한다.

캐치메뉴 자체 앱은 1인 점포 또는 직영 매장 고객이 사용하는 네이티브 앱이다.
로그인 기반 세션으로 이전 방문 이력, 포인트 적립, 쿠폰 관리가 가능하다.

세션 관리의 핵심:
  JWT 자동 갱신 미처리 → 1시간 후 401 에러 (과거 드롭 원인)
  기기 변경 시 SecureStorage 소멸 → 재로그인 필요

Related Logic: 900121_Logic_Channel_2_Catch_Menu_Native_App_Customer_Handoff_And_Session.md

---

## 1. 채널 정의

```text
채널명: Catch Menu Native App (캐치메뉴 자체 앱)
접근 방법: App Store / Play Store 설치 후 실행
인증 요구: 전화번호 OTP 로그인 (최초 1회)
대상 고객: 재방문 고객, 포인트 적립 원하는 고객
KDS 접근: 없음 (고객 전용)
멤버십: STAMP / POINT (캐치메뉴 원장)
포인트 생성자: 캐치메뉴 자체 앱
```

---

## 2. 고객 진입 흐름

```text
앱 실행
  ↓
자동 로그인 (SecureStorage JWT 복구)
  or 전화번호 OTP 로그인 (최초/만료 시)
  ↓
bootstrap_customer_app_v2()
  ↓
홈 화면
  - 근처 매장 또는 즐겨찾기 매장
  - 이전 주문 이력
  - 포인트 잔액
  - 쿠폰 목록
  ↓
QR 스캔 또는 매장 선택
  ↓
대기 등록 (register_waiting)
  ↓
대기 현황 + 메뉴 탐색
  ↓
사전 주문 (pre_order_while_waiting) ← 선택
  ↓
호출 수신 (FCM 네이티브 push)
  ↓
착석 + 결제
  ↓
포인트 자동 적립 (earn_points_after_order)
  ↓
주문 이력 저장
```

---

## 3. 세션 아키텍처

### 3.1 인증 세션

```text
인증 방식: 전화번호 OTP → Supabase authenticated

세션 저장:
  Flutter SecureStorage (flutter_secure_storage)
  저장 항목:
    supabase_access_token
    supabase_refresh_token
    supabase_user_id (customers.id)
    catchmenu_preferred_locale

세션 수명:
  access_token:  1시간 (Supabase 기본)
  refresh_token: 60일 (Supabase 기본)
  자동 갱신: Supabase Flutter SDK autoRefreshToken: true

기기 변경 시:
  SecureStorage 소멸 → 재로그인 필요
  전화번호 재인증 → 기존 customers.id 복구
  이전 주문 이력 + 포인트 유지 (서버 기반)
```

### 3.2 대기 세션

```text
register_waiting() 호출 후:
  order_sessions.customer_id = customers.id (로그인 계정)
  session_id → SharedPreferences 저장 (SecureStorage 아님)

이 채널에서 추가되는 것:
  고객 계정과 대기 세션이 연결됨
  → 이전 방문 시 어떤 메뉴를 선택했는지 이력
  → 포인트 자동 적립
  → 쿠폰 자동 적용 가능
```

---

## 4. 멤버십 연동

```text
멤버십 모드: STAMP 또는 POINT

STAMP 모드 (1호점 기본):
  주문 완료 후 stamp_visit() 자동 호출
  목표 도달 (기본 10회) → 쿠폰 자동 발급
  stamp_cards 테이블에 기록

POINT 모드:
  earn_points_after_order() 자동 호출
  결제 금액 × earn_rate 포인트 적립
  point_ledger 원장 기록

포인트 적립 시점:
  confirm_payment() 성공 직후 자동 실행
  별도 호출 불필요

포인트 생성자 원칙:
  캐치메뉴 자체 앱 = 포인트 생성자
  이 앱의 포인트는 캐치메뉴 원장에 저장
  외부 이관 없음 (Channel 3, 4 와 다름)
```

---

## 5. 관련 RPC

| 단계 | RPC | 비고 |
|---|---|---|
| 부트스트랩 | bootstrap_customer_app_v2 | customer_id 포함 |
| 고객 홈 | get_customer_home | 이력, 포인트, 쿠폰 |
| 대기 등록 | register_waiting | customer_id 연결 |
| 대기 현황 | get_waiting_status | session_id |
| 메뉴 조회 | get_kiosk_menu | 알레르겐 프로필 적용 |
| 사전 주문 | pre_order_while_waiting | customer_id 연결 |
| 결제 | confirm_payment | order_id |
| 포인트 적립 | earn_points_after_order | 자동 호출 |
| 쿠폰 조회 | get_customer_coupons | customer_id |
| 주문 이력 | get_customer_history | customer_id |

---

## 6. Realtime 채널

| 채널 | 구독 조건 | 수신 이벤트 |
|---|---|---|
| waiting:{store_id} | 대기 등록 후 | waiting_called, seated |
| customer_app:{store_id} | 앱 실행 중 | stamp_added, tier_upgraded, coupon_issued |

FCM push:
```text
대기 호출 시: 네이티브 push 알림
  제목: "입장해주세요!"
  내용: "W-007번 고객님, 테이블이 준비되었습니다"
  딥링크: 앱 대기 현황 화면으로 이동

포인트 적립 시: 네이티브 push
  제목: "포인트 적립!"
  내용: "180포인트가 적립되었습니다"
```

---

## 7. Flutter 구현 대상

| 화면 | Primary RPC | 세션 의존 |
|---|---|---|
| 스플래시 / 자동 로그인 | — | SecureStorage JWT |
| OTP 로그인 | Supabase OTP | phone |
| 홈 | get_customer_home | customer_id |
| 매장 선택 / QR 스캔 | qr_scan_action | store_id |
| 대기 등록 | register_waiting | customer_id |
| 대기 현황 | get_waiting_status | session_id |
| 메뉴 탐색 | get_kiosk_menu | store_id |
| 사전 주문 | pre_order_while_waiting | session_id |
| 결제 | confirm_payment | order_id |
| 포인트/스탬프 | get_customer_membership | customer_id |
| 쿠폰 | get_customer_coupons | customer_id |
| 주문 이력 | get_customer_history | customer_id |

---

## 8. Out Of Scope

```text
KDS 화면
직원 앱 기능
화이트라벨 브랜딩
윤슬김밥 멤버십 통합
관리자 기능
```
