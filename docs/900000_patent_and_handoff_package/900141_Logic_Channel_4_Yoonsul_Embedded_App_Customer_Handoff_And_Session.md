# 900141_Logic_Channel_4_Yoonsul_Embedded_App_Customer_Handoff_And_Session

Status: In_Progress
Lifecycle: Logic
Owner: TBD
Last Updated: 2026-06-21

---

## 0. Document Purpose

이 Logic 문서는 Channel 4 윤슬김밥 임베디드 앱의 세션 생성,
유지, 복구, 소멸 제어 로직과 Handoff 상태 전이를 정의한다.

핵심 특성:
```text
캐치메뉴 엔진이 윤슬김밥 앱 내부에 임베디드되어 있다.
고객은 윤슬김밥 앱 하나로 모든 것을 한다.
캐치메뉴와 윤슬OS 는 별개 시스템이다.
멤버십은 Phase 2 에서 추가된다.
```

가장 중요한 세션 원칙:
```text
Phase 1: 운영 기능 검증
  캐치메뉴 웹앱/자체앱 데이터
  → 윤슬김밥 임베디드 앱에 동일하게 반영
  → 데이터 정합성 + 세션 충돌 없음 확인

Phase 2: 멤버십 통합
  anon → authenticated 세션 업그레이드
  브랜드 전체 매장 포인트 통합
```

Related Overview: 900140_Overview_Channel_4_Yoonsul_Embedded_App_Customer_Handoff_And_Session.md

---

## 1. Phase 1 세션 구조

```text
Phase 1 에서 윤슬김밥 앱은 캐치메뉴 MVP 를 검증한다.
멤버십 없음. 로그인 없음 (또는 선택).

세션 저장:
  SharedPreferences (비민감 데이터)
  catchmenu_session_id
  catchmenu_store_id
  catchmenu_locale
  pending_payment_order_id

인증:
  anon 세션 (Supabase)
  또는 전화번호 선택 입력 (phone_hash)

세션 복구:
  앱 재진입 → SharedPreferences session_id 확인
  → get_waiting_status(session_id)
  → 상태별 화면 복구
```

---

## 2. Phase 2 세션 업그레이드

```text
Phase 1 → Phase 2 앱 업데이트 후:

변경사항:
  anon → OTP authenticated
  SharedPreferences → SecureStorage (JWT 추가)
  멤버십 레이어 UI 추가
  FCM 네이티브 push 활성화

업그레이드 흐름:
  1. 앱 업데이트 후 첫 실행
  2. 멤버십 가입 배너 표시
     "포인트 적립 시작하기"
  3. 전화번호 OTP 인증
  4. customers 계정 생성 or 복구

  기존 Phase 1 데이터 귀속:
    phone_hash 일치하는 order_sessions
    → customer_id 귀속 (가능한 범위)
```

---

## 3. 세션 드롭 패턴 및 방어 로직

Ch2 DROP-A ~ DROP-E 동일 적용.
Ch3 DROP-F (tenant_id 혼입) 동일 적용.
아래는 Ch4 고유 추가 패턴.

### DROP-H: 캐치메뉴 앱 ↔ 윤슬앱 세션 충돌

```text
문제:
  Phase 1 검증 중 같은 기기에서
  캐치메뉴 자체 앱 + 윤슬김밥 앱을 동시 사용
  두 앱이 동일 Supabase 프로젝트에 연결
  → 세션이 서로 덮어씌울 가능성

원인:
  SharedPreferences 키 이름이 동일한 경우
  예: 두 앱 모두 'catchmenu_session_id' 키 사용

방어 로직:
  앱별 SharedPreferences 네임스페이스 분리:
    캐치메뉴 앱:   'cm_app_session_id'
    윤슬김밥 앱:   'yoonsul_session_id'

  SecureStorage 도 앱별 분리:
    iOS: Keychain Access Group 분리
    Android: 앱 패키지명 기준 자동 분리

  Supabase 세션:
    두 앱은 별도 패키지명 → Supabase 세션 자동 분리
    동일 사용자가 두 앱 로그인 시 → 각각 독립 세션

  검증 테스트:
    캐치메뉴 앱에서 대기 등록 (session_id = A)
    윤슬앱에서 session_id 조회
    → 다른 값이어야 함 (충돌 없음)
```

### DROP-I: OKpos / 토스POS 결제 후 앱 세션 불일치

```text
문제:
  POS 단말기에서 결제 완료
  → 캐치메뉴 DB 에 payment_ledger APPROVED
  → KDS COMMITTED 전환
  → 그러나 앱에서는 여전히 "결제 대기" 화면

원인:
  POS 결제 완료 이벤트가 앱에 전달 안 됨
  (Realtime 미수신 또는 앱 백그라운드 상태)

방어 로직:
  Realtime kds:{store_id} 구독:
    kds_tickets_released 이벤트 수신
    → 앱 상태 PAID 로 전환
    → "조리 중" 화면 표시

  폴링 백업:
    결제 화면 진입 후 10초마다 폴링
    confirm_payment 상태 확인
    APPROVED 확인 시 화면 전환

  POS 결제 완료 후 앱 동기화 흐름:
    OKpos/토스POS → webhook → toss-payments-webhook
    → confirm_payment() → payment_ledger APPROVED
    → release_kds_after_payment() → COMMITTED
    → Realtime broadcast → 앱 수신 → 화면 전환
```

### DROP-J: 브랜드 전체 매장 포인트 동기화 지연

```text
문제 (Phase 2):
  매장 A 에서 포인트 적립
  바로 매장 B 앱에서 잔액 조회
  → 이전 잔액 표시 (지연)

방어 로직:
  포인트 조회 시 캐시 무효화:
    earn_points_after_order() 완료 후
    Realtime customer_app:{store_id} 이벤트 발행
    앱에서 수신 → get_customer_membership() 재호출
    → 최신 잔액 즉시 반영

  앱 간 동기화:
    매장 A 앱과 매장 B 앱은 별개 인스턴스
    두 앱 모두 같은 customer_id 기반 조회
    → 서버 데이터 기준으로 항상 최신 반영
    → 로컬 캐시 최대 30초
```

---

## 4. Phase 1 검증 핵심 시나리오

```text
캐치메뉴 MVP → 윤슬앱 데이터 정합성 검증

시나리오 1: 웹앱 → 윤슬앱 데이터 연속성
  1. 캐치메뉴 웹앱으로 서울 1호점 대기 등록
     tenant_id = 윤슬김밥, store_id = 서울1호점
  2. 윤슬김밥 앱에서 같은 매장 대기 현황 조회
  3. 동일 대기 번호/세션 표시 확인
  결과: 같은 DB, 같은 tenant_id → 동일 데이터

시나리오 2: 직원 앱 ↔ 고객 앱 (윤슬앱) Realtime
  1. 직원이 캐치메뉴 직원 앱에서 W-007 호출
  2. 윤슬앱 고객 화면에 "입장해주세요" 수신 확인
  3. FCM 알림 수신 확인 (Phase 2)
  결과: Realtime waiting:{store_id} 정상 작동

시나리오 3: OKpos 연동
  1. 윤슬앱에서 사전 주문 → KDS HOLD
  2. OKpos 단말기에서 결제 완료
  3. okpos-order-send Edge Function → OKpos 전송
  4. KDS COMMITTED 전환 확인
  5. 윤슬앱 "조리 중" 화면 표시 확인
  결과: POS 연동 + KDS Late Binding 정상 작동

시나리오 4: 세션 충돌 없음
  1. 캐치메뉴 자체 앱 대기 등록 (session-A)
  2. 같은 기기에서 윤슬앱 실행
  3. 윤슬앱 session_id ≠ session-A 확인
  결과: 앱별 세션 격리 정상
```

---

## 5. 임베디드 구조 세션 초기화

```text
윤슬김밥 앱 시작 시 캐치메뉴 엔진 초기화:

class YoonsulApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 캐치메뉴 엔진 초기화
        Provider(create: (_) => CatchMenuEngine(
          tenantId: const String.fromEnvironment('TENANT_ID'),
          brandId:  const String.fromEnvironment('BRAND_ID'),
          supabaseUrl: const String.fromEnvironment('SUPABASE_URL'),
          supabaseKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
        )),
        // 윤슬 브랜딩 레이어
        Provider(create: (_) => YoonsulBranding()),
        // Phase 2: 멤버십 레이어 (추후 추가)
        // Provider(create: (_) => MembershipService()),
      ],
      child: MaterialApp(...)
    )
  }
}

캐치메뉴 엔진은 독립 모듈로 초기화된다.
윤슬 브랜딩과 캐치메뉴 엔진은 분리되어 있다.
멤버십 레이어는 Phase 2 에서 Provider 추가로 활성화.
```

---

## 6. 윤슬OS 와의 데이터 경계

```text
캐치메뉴 DB (Supabase):
  고객 대기 / 주문 / 결제 / KDS
  고객 멤버십 포인트 (Phase 2)
  직원 출퇴근 참고 기록 (캐치메뉴 범위)
  운영 메트릭

윤슬OS (별개 시스템):
  직원 급여 / 노무 관리
  식재료 발주 / 재고
  가맹 계약 / 가맹비
  인사 / 조직 관리

두 시스템 간 직접 연동: 없음 (Phase 1)
향후 연동 가능성:
  운영 메트릭 → 윤슬OS 리포트 (API 연동)
  직원 출퇴근 → 윤슬OS 급여 계산 (Phase 3 이후)
```

---

## 7. Phase별 세션 전환 로드맵

```text
Phase 1 (MVP 검증):
  세션: anon + SharedPreferences
  인증: 없음 또는 전화번호 선택
  검증: 데이터 정합성 + POS 연동

Phase 2 (멤버십 통합):
  세션: authenticated + SecureStorage
  인증: OTP 필수
  추가: FCM push, 포인트, 쿠폰, 이력

Phase 3 (고도화 + 확산):
  세션: 동일 유지
  추가: AI 추천, 다매장 통계
  확산: 주변 매장 무료 배포

각 Phase 전환은 앱 업데이트로 처리.
기존 세션 데이터 최대한 보존.
```

---

## 8. 4채널 세션 최종 비교표

| 항목 | Ch1 웹앱 | Ch2 캐치메뉴앱 | Ch3 화이트라벨 | Ch4 윤슬앱 |
|---|---|---|---|---|
| 인증 | anon | OTP | OTP | P1: anon, P2: OTP |
| 세션 저장 | localStorage | SecureStorage | SecureStorage | P1: SharedPrefs, P2: SecureStorage |
| JWT 갱신 | SDK 자동 | onAuthStateChange | onAuthStateChange | P2부터 적용 |
| 앱 복귀 | 재로드 | WidgetsBinding | WidgetsBinding | WidgetsBinding |
| 멤버십 | 없음 | STAMP/POINT | FRANCHISE_LINK | P2: YOONSUL_LINK |
| POS 연동 | — | OKpos/토스POS | 가맹점별 | OKpos/토스POS |
| 포인트 범위 | 없음 | 단일 매장 | 가맹점 설정 | 브랜드 전체 |
| 드롭 패턴 | A~E | A~E | A~G | A~J |
| 임베디드 | 아님 | 아님 | 아님 | 캐치메뉴 엔진 임베디드 |
| OS 연동 | — | — | — | 윤슬OS 별개 |
| 1호점 | 서울 보조 | 서울 검증 | 추후 | 서울 메인 |

---

## 9. Open Issues

```text
- [ ] Phase 1 → Phase 2 전환 시
  기존 anon 주문 이력 customer_id 귀속 범위 결정
  (phone_hash 있는 것만? 전체?)

- [ ] OKpos vs 토스POS 결제 완료 이벤트 차이
  OKpos: webhook 방식 또는 polling
  토스POS: heartbeat + webhook
  두 경로 모두 DROP-I 방어 적용 확인 필요

- [ ] 윤슬OS 와의 향후 연동 인터페이스
  Phase 3 에서 운영 메트릭 → 윤슬OS 연동 시
  API 스펙 사전 합의 필요

- [ ] 서울 1호점 오픈 전
  Phase 1 시나리오 1~4 검증 완료 필수
  run_integration_test() ALL_PASS 확인
```
