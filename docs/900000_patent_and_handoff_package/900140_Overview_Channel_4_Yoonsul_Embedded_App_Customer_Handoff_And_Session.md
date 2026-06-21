# 900140_Overview_Channel_4_Yoonsul_Embedded_App_Customer_Handoff_And_Session

Status: In_Progress
Lifecycle: Overview
Owner: TBD
Last Updated: 2026-06-21

---

## 0. Document Purpose

이 Overview 는 Channel 4 윤슬김밥 앱의 고객 Handoff 구현 컨텍스트를 정의한다.

윤슬김밥 앱은 캐치메뉴가 임베디드된 프랜차이즈 전용 앱이다.
고객은 윤슬김밥 앱 하나로 대기, 주문, 결제, 멤버십을 모두 사용한다.
내부적으로는 캐치메뉴 엔진이 운영을 담당한다.

캐치메뉴와 윤슬OS 는 별개 시스템이다.
캐치메뉴 = 매장 운영 OS (대기/주문/결제/KDS)
윤슬OS = 백오피스 (노무/재고/인사/가맹계약)

1호점 위치: 서울

Related Logic: 900141_Logic_Channel_4_Yoonsul_Embedded_App_Customer_Handoff_And_Session.md

---

## 1. 채널 정의

```text
채널명: Yoonsul Kimbap Embedded App (윤슬김밥 앱)
접근 방법: App Store / Play Store (윤슬김밥 브랜드)
인증 요구: 전화번호 OTP (Phase 2 멤버십부터)
대상 고객: 윤슬김밥 방문 고객 (서울 1호점 시작)
KDS 접근: 없음 (고객 앱)
캐치메뉴 역할: 임베디드 운영 엔진
윤슬OS 역할: 별개 백오피스 시스템
```

---

## 2. 앱 구조 — 임베디드 아키텍처

```text
[윤슬김밥 앱]
  ├── 브랜딩 레이어
  │     로고, 색상, 앱 이름, 스플래시
  │
  ├── Phase 2: 멤버십 레이어 (2차 개발)
  │     포인트, 스탬프, 쿠폰, 방문 이력
  │     전화번호 OTP 인증
  │     브랜드 전체 매장 포인트 공유
  │
  └── 캐치메뉴 엔진 (임베디드, Phase 1부터)
        대기 등록 / 대기 현황
        메뉴 탐색 / 사전 주문
        결제 (OKpos / 토스POS 연동)
        KDS 상태 표시 (read-only)
        직원 앱 연동
        DID 연동
```

---

## 3. 개발 단계

### Phase 1: 캐치메뉴 MVP (1차 개발)

```text
목표: 운영 기능 완성 + 검증

포함:
  캐치메뉴 웹앱 MVP
  캐치메뉴 자체 앱 MVP
  OKpos / 토스POS 연동
  서울 1호점 테스트

  검증 핵심:
  캐치메뉴 웹앱/앱 데이터
    → 윤슬김밥 임베디드 앱에 정상 반영 확인
  tenant_id / brand_id 격리 검증
  세션 충돌 없음 확인

제외 (Phase 2로):
  멤버십 포인트/스탬프
  로그인 (anon 또는 선택)
  방문 이력
```

### Phase 2: 멤버십 통합 (2차 개발)

```text
목표: 멤버십 레이어를 1차 앱 위에 추가

포함:
  전화번호 OTP 인증 추가
  스탬프 / 포인트 적립
  쿠폰 발행 / 사용
  방문 이력 UI
  브랜드 전체 매장 포인트 통합

  1차 데이터와 연결:
  Phase 1 anon 세션 → authenticated 업그레이드
  기존 주문 이력 → customer_id 귀속 (가능한 범위)

매장 운영 시나리오:
  매장 오픈 = 멤버십 앱 + 캐치메뉴 기능 임베디드
  OKpos / 토스POS 연동 완성 상태
```

### Phase 3: 고도화 + 확산

```text
목표: 검증 완료 후 외부 확산

  캐치메뉴 자체 고도화 (피드백 기반)
  주변 매장 무료 배포
  피드백 수집 → 개선 반복
  SaaS 상품화
  가맹점 확대
```

---

## 4. 데이터 흐름 검증 구조

```text
Phase 1 핵심 검증:

[캐치메뉴 웹앱]    [캐치메뉴 자체앱]
       ↓                  ↓
   대기/주문/결제 데이터 생성
       ↓
[캐치메뉴 DB - Supabase]
  tenant_id = 윤슬김밥
  brand_id  = 윤슬김밥
       ↓
[윤슬김밥 임베디드 앱]
  같은 DB, 같은 tenant_id
  → 데이터 동일하게 보이는가?
  → 세션 충돌 없는가?
  → OKpos 주문 데이터 정합성?
  → 토스POS 결제 데이터 정합성?
```

---

## 5. 캐치메뉴 vs 윤슬OS 경계

```text
캐치메뉴 담당:
  고객 대기 / 주문 / 결제 / KDS
  고객 멤버십 포인트 원장 (Phase 2)
  매장 운영 실시간 현황
  직원 앱 (대기 호출, KDS 처리)
  OKpos / 토스POS 연동

윤슬OS 담당 (별개 시스템):
  직원 노무 관리 (출퇴근, 급여)
  재고 발주 / 원가 관리
  프랜차이즈 계약 / 가맹비
  인사 관리

두 시스템은 직접 연결되지 않는다.
고객 앱 = 캐치메뉴 엔진만 사용.
직원 앱 = 캐치메뉴 직원 앱 사용.
윤슬OS = 별도 백오피스 접근.
```

---

## 6. 멤버십 구조 (Phase 2)

```text
멤버십 모드: YOONSUL_LINK

특성:
  윤슬김밥 브랜드 전체 매장 포인트 공유
  서울 1호점 적립 포인트 → 2호점에서 사용 가능
  brand_id 기준 통합 원장

earn_points_after_order():
  membership_mode = 'YOONSUL_LINK'
  → point_ledger: customer_id 기준 적립
  → 브랜드 전체 누적 포인트 갱신
  → tier 자동 업그레이드 (전 매장 방문 합산)

본부 쿠폰:
  send_hq_notice() 또는 issue_coupon_to_customer()
  customer_id 기준 발급
  전 매장 사용 가능
```

---

## 7. POS 연동

```text
OKpos 연동:
  okpos-order-send Edge Function
  캐치메뉴 주문 → OKpos 전송
  OKpos 영수증 → 캐치메뉴 결제 확인

토스POS 연동:
  toss-pos-heartbeat Edge Function
  토스POS 결제 → payment_ledger APPROVED
  → release_kds_after_payment() 자동 호출

Phase 1 검증:
  캐치메뉴 주문 → OKpos 정상 수신?
  토스POS 결제 → KDS COMMITTED 전환?
  데이터 정합성 로그 확인
```

---

## 8. 세션 구조 (Phase별)

```text
Phase 1 세션:
  anon 또는 전화번호 선택 입력
  localStorage / SharedPreferences
  세션 복구: session_id 기반

Phase 2 세션 업그레이드:
  전화번호 OTP → authenticated
  SecureStorage JWT
  기존 anon 세션 → customer_id 귀속
  JWT 자동 갱신
  FCM 네이티브 push 활성화
```

---

## 9. 4채널 전체 비교 (최종)

| 항목 | Ch1 웹앱 | Ch2 캐치메뉴앱 | Ch3 화이트라벨 | Ch4 윤슬앱 |
|---|---|---|---|---|
| 구조 | 독립 | 독립 | SaaS 임베디드 | 브랜드 임베디드 |
| 인증 | anon | OTP | OTP | Phase2부터 OTP |
| 세션 | localStorage | SecureStorage | SecureStorage | P1:SharedPrefs P2:SecureStorage |
| 멤버십 | 없음 | STAMP/POINT | FRANCHISE_LINK | YOONSUL_LINK (P2) |
| POS 연동 | — | OKpos/토스POS | 가맹점별 | OKpos/토스POS |
| 1호점 | 서울 (보조) | 서울 (검증) | 추후 | 서울 (메인) |
| OS 연동 | — | — | — | 윤슬OS 별개 |
| 고도화 경로 | Ch2로 유도 | Ch4로 통합 | 독립 확장 | Phase3 확산 |
