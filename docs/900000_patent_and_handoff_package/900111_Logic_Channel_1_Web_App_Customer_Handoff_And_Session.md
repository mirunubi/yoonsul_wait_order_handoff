# 900111_Logic_Channel_1_Web_App_Customer_Handoff_And_Session

Status: In_Progress
Lifecycle: Logic
Owner: TBD
Last Updated: 2026-06-21

---

## 0. Document Purpose

이 Logic 문서는 Channel 1 웹앱의 세션 생성, 유지, 복구,
소멸 제어 로직과 Handoff 상태 전이를 정의한다.

과거 1차/2차 개발에서 세션 드롭이 반복된 이유를 분석하고
각 드롭 패턴에 대한 방어 로직을 명시한다.

Related Overview: 900110_Overview_Channel_1_Web_App_Customer_Handoff_And_Session.md

---

## 1. 세션 드롭 패턴 및 방어 로직

### DROP-001: 탭 닫힘 후 재접속

```text
문제:
  고객이 대기 중 실수로 탭을 닫음
  재접속 시 처음 화면부터 시작됨
  → wait_number 분실, 대기 순서 재등록 혼란

방어 로직:
  register_waiting() 성공 직후:
    localStorage.setItem('catchmenu_session_id', session_id)
    localStorage.setItem('catchmenu_store_id', store_id)
    localStorage.setItem('catchmenu_wait_number', wait_number)

  페이지 로드 시 최우선 체크:
    const sessionId = localStorage.getItem('catchmenu_session_id')
    if (sessionId) {
      // 서버에 세션 상태 확인
      await getWaitingStatus(sessionId)
      // 상태에 따라 해당 화면으로 복구
    }

Flutter Web 구현:
  main.dart 진입 시 SharedPreferences 체크
  session_id 존재 → SessionRecoveryScreen
  없음 → LandingScreen
```

### DROP-002: Supabase JWT 만료 (1시간)

```text
문제:
  대기 시간이 1시간을 넘는 경우
  Supabase anon JWT 만료
  API 호출 시 401 에러
  → 앱 크래시 또는 빈 화면

방어 로직:
  Supabase Flutter SDK autoRefreshToken: true 설정 필수
  (기본값이지만 명시적으로 설정)

  추가 방어:
    API 호출 시 401 수신 → 자동 세션 갱신 후 재시도
    갱신 실패 시 → session_id localStorage 유지하고
                   새 anon 세션 생성 후 session_id 로 상태 복구

  anon 세션 갱신 코드 패턴:
    supabase.auth.onAuthStateChange((event, session) {
      if (event == AuthChangeEvent.tokenRefreshed) {
        // 세션 갱신 완료. 진행 중인 Realtime 재구독
        resubscribeRealtime()
      }
    })
```

### DROP-003: Realtime 연결 끊김

```text
문제:
  네트워크 일시 장애 또는 기기 슬립
  Realtime WebSocket 연결 해제
  → 대기 호출 이벤트 수신 못함
  → 고객이 호출됐는데 화면 변화 없음
  → 노쇼 처리됨

방어 로직:
  Realtime 재연결 핸들러 필수:

    channel.onReconnect(() {
      // 재연결 시 현재 상태를 서버에서 재조회
      refreshWaitingStatus()
    })

  폴링 백업:
    Realtime 구독 중에도 30초마다 get_waiting_status() 폴링
    Realtime 이벤트와 폴링 결과 비교
    불일치 시 서버 상태 우선 적용

  앱 포그라운드 복귀 시:
    WidgetsBindingObserver.didChangeAppLifecycleState
    resumed → Realtime 재구독 + 상태 즉시 갱신
```

### DROP-004: 시크릿 모드 세션 소멸

```text
문제:
  고객이 시크릿 모드로 QR 접속
  탭 닫힘 → localStorage 소멸
  → session_id 분실
  → 서버에는 WAITING 세션이 남아 있음

방어 로직:
  시크릿 모드 감지는 불가능 (브라우저 정책)
  
  대안:
    URL에 session_id 포함 옵션:
      https://catchmenu.app/wait?s=[session_id]
      (단, 보안 상 URL 공개 금지 원칙과 충돌)

  권장 방안:
    전화번호 선택 입력:
      register_waiting 시 phone_hash 선택 입력
      → 같은 전화번호로 재접속 시 세션 복구
      → 입력 안 해도 대기 가능 (선택)

    화면 안내:
      "대기 번호: W-007"을 크게 표시
      "이 화면을 닫지 마세요" 안내 텍스트
```

### DROP-005: 결제 후 탭 닫힘

```text
문제:
  결제 완료 후 탭 닫힘
  → 주문 추적 화면 접근 불가
  → 음식 나왔을 때 고객이 모름

방어 로직:
  confirm_payment() 성공 후:
    localStorage.setItem('catchmenu_order_id', order_id)
    localStorage.setItem('catchmenu_payment_done', 'true')

  재접속 시:
    order_id 있고 payment_done = true
    → 주문 추적 화면으로 직접 이동
    → get_order_tracking(order_id) 호출

  추가:
    결제 완료 화면에 "이 화면 저장하기" 버튼
    → 화면 스크린샷 안내 (영수증 대체)
```

---

## 2. 세션 상태 전이 (웹앱 특화)

```text
[신규 접속]
  localStorage 없음
    ↓
  LandingScreen (QR 스캔 결과)
    ↓ register_waiting()
  [WAITING]
    localStorage: session_id, wait_number 저장
    Realtime waiting:{store_id} 구독
    ↓ call_waiting_customer() (직원)
  [ARRIVAL_PENDING]
    화면: "입장해주세요! W-007번"
    브라우저 Notification (권한 있으면)
    ↓ seat_waiting_customer() (직원)
  [SEATED]
    화면: 결제 프롬프트
    next_step: PROCEED_TO_PAYMENT
    ↓ confirm_payment() (고객)
  [PAID]
    localStorage: order_id, payment_done 저장
    화면: 주문 추적
    ↓ KDS SERVED
  [COMPLETED]
    localStorage 초기화
    화면: 완료 + 재방문 안내

[재접속 - 세션 복구]
  localStorage: session_id 있음
    ↓ get_waiting_status(session_id)
  서버 상태 → 해당 화면으로 복구
```

---

## 3. anon → 전화번호 전환 로직

```text
웹앱에서 전화번호는 선택 사항이다.
강제 인증 없이도 대기 등록이 가능해야 한다.

전화번호 입력 시:
  register_waiting(p_phone_hash = SHA256(phone))
  → order_sessions.phone_hash 저장
  → DID 호출 시 SMS 발송 가능

전화번호 미입력 시:
  register_waiting(p_phone_hash = null)
  → 브라우저 Realtime 알림만 사용
  → Notification API 권한 요청

세션 복구 시 전화번호 활용:
  localStorage session_id 소멸 후
  전화번호 재입력 → phone_hash 로 세션 검색
  → 동일 phone_hash 의 WAITING/ARRIVAL_PENDING 세션 반환
  → 기존 세션으로 복구 가능

전화번호 저장 금지:
  원번호는 절대 저장하지 않는다
  SHA-256 해시만 DB 저장
  localStorage 에도 원번호 저장 금지
```

---

## 4. 사전 주문 세션 연결 로직

```text
웹앱에서 사전 주문 생성 시:

  pre_order_while_waiting(
    p_session_id = localStorage.session_id,
    p_cart_items = [...],
    p_locale = 'ko'
  )

선행 조건 검증 (서버):
  order_sessions.session_status IN ('WAITING', 'ARRIVAL_PENDING')
  → SEATED, CANCELLED, NO_SHOW 이면 에러 반환

세션 연결:
  orders.session_id = order_sessions.id
  kds_tickets.conditions_met.waiting_session_id = order_sessions.id

결제 시 세션 연결 확인:
  confirm_payment(p_order_id = localStorage.order_id)
  → payment_ledger.order_id = orders.id
  → release_kds_after_payment() 자동 호출
```

---

## 5. 결제 처리 로직 (웹앱 특화)

```text
웹앱 결제 = 토스페이먼츠 JavaScript SDK

흐름:
  1. 결제 버튼 클릭
  2. 토스페이먼츠 결제 창 팝업
  3. 결제 완료 → 토스 successUrl 리다이렉트
  4. successUrl: /payment/success?paymentKey=...&orderId=...&amount=...

successUrl 처리 (주의):
  이 페이지는 새 탭 또는 리다이렉트로 열릴 수 있음
  → localStorage 접근 가능
  → session_id, order_id 읽어서 confirm_payment() 호출

  흐름:
    const orderId = new URLSearchParams(window.location.search)
      .get('orderId')
    const paymentKey = ...
    const amount = ...

    // 서버에 검증 요청 (클라이언트 성공 화면 믿지 않음)
    const result = await supabase.rpc('confirm_payment', {
      p_order_id: orderId,
      p_toss_payment_key: paymentKey,
      p_amount: amount
    })

    if (result.data.success) {
      // 완료 화면
    } else {
      // 실패 처리
    }

failUrl 처리:
  /payment/fail?code=...&message=...
  → kds_tickets: HOLD 유지 (서버에서 자동)
  → 고객에게 재시도 안내
  → localStorage session_id, order_id 유지
```

---

## 6. 다국어 세션 로직

```text
locale 설정 시점:
  bootstrap 직후 언어 선택 화면
  선택 → localStorage.setItem('catchmenu_locale', 'en')

locale 사용:
  모든 RPC 호출에 p_locale 파라미터 포함
  메시지는 catchmenu_common.message_catalog 에서 반환

재접속 시 locale 복구:
  localStorage.getItem('catchmenu_locale')
  → 언어 선택 화면 건너뛰고 기존 언어 유지

외국인 특화:
  locale != 'ko' 이면:
    get_kiosk_menu() → menu_name_en / menu_name_zh / menu_name_ja 우선
    search_menu_vector() → 자연어 검색 (벡터 임베딩)
    알레르겐 필터 UI 표시
```

---

## 7. 보안 요건

```text
anon 세션 RLS:
  order_sessions: store_id + session_id 기반
  다른 session_id 의 세션 조회 불가
  RLS 정책: session_id = 요청자 소유 세션만

LocalStorage 저장 금지 항목:
  원본 전화번호
  결제 카드 정보
  개인 식별 정보

session_id 노출 위험:
  URL 파라미터에 session_id 포함 금지
  (가로채기 방지)
  localStorage 에만 저장

XSS 방어:
  토스페이먼츠 successUrl 의 쿼리 파라미터는
  서버 검증 전까지 신뢰하지 않음
```

---

## 8. 웹앱 vs 앱 채널 세션 비교

| 항목 | 웹앱 (Ch1) | 자체 앱 (Ch2) | 화이트라벨 (Ch3) | 윤슬 앱 (Ch4) |
|---|---|---|---|---|
| 인증 | anon | authenticated | authenticated | authenticated |
| 세션 저장 | localStorage | SecureStorage | SecureStorage | SecureStorage |
| 세션 복구 | session_id 재조회 | JWT 자동 갱신 | JWT 자동 갱신 | JWT 자동 갱신 |
| 탭 닫힘 복구 | 가능 (시크릿 제외) | N/A | N/A | N/A |
| 멤버십 | 없음 | STAMP/POINT | FRANCHISE_LINK | YOONSUL_LINK |
| push 알림 | 제한적 | 네이티브 FCM | 네이티브 FCM | 네이티브 FCM |
| 이전 이력 | 없음 | 있음 | 있음 | 있음 |

---

## 9. Open Issues

- [ ] 시크릿 모드 세션 복구 방안 최종 결정
  현재: 전화번호 선택 입력으로 복구
  대안: QR URL에 임시 토큰 포함 (보안 검토 필요)

- [ ] iOS Safari 브라우저 push 알림 제한 대응
  현재: Realtime 폴링 30초 fallback
  대안: PWA (홈 화면 추가 유도)

- [ ] 결제 successUrl 새 탭 처리
  현재: localStorage 읽기로 처리
  대안: 서버 측 세션 토큰 URL 포함 검토

- [ ] 웹앱 세션 최대 수명 정책
  현재: 서버 2시간 자동 만료
  검토: 영업 시간 종료 시 일괄 만료
