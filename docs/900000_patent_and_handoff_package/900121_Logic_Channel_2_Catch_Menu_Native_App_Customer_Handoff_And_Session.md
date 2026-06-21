# 900121_Logic_Channel_2_Catch_Menu_Native_App_Customer_Handoff_And_Session

Status: In_Progress
Lifecycle: Logic
Owner: TBD
Last Updated: 2026-06-21

---

## 0. Document Purpose

이 Logic 문서는 Channel 2 캐치메뉴 자체 앱의 세션 생성, 유지,
복구, 소멸 제어 로직과 Handoff 상태 전이를 정의한다.

채널 2는 Channel 1 웹앱과 달리 authenticated 세션을 사용한다.
JWT 자동 갱신, FCM push, SecureStorage 세션 복구가 핵심이다.

과거 드롭 원인:
  JWT 1시간 만료 후 자동 갱신 미처리
  앱 백그라운드 복귀 시 Realtime 재구독 미처리
  기기 변경 시 이전 세션 복구 로직 없음

Related Overview: 900120_Overview_Channel_2_Catch_Menu_Native_App_Customer_Handoff_And_Session.md

---

## 1. 세션 드롭 패턴 및 방어 로직

### DROP-A: JWT 1시간 만료

```text
문제:
  고객이 대기 중 1시간 경과
  Supabase access_token 만료
  API 호출 시 401 Unauthorized
  → 앱 크래시 또는 빈 화면

방어 로직:

  Supabase 초기화 시 필수 설정:
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      authOptions: FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
        autoRefreshToken: true,       ← 필수
        persistSession: true,          ← 필수
      ),
    )

  onAuthStateChange 핸들러 필수:
    supabase.auth.onAuthStateChange.listen((data) {
      final event = data.event
      if (event == AuthChangeEvent.tokenRefreshed) {
        // 토큰 갱신 완료
        // 진행 중인 Realtime 채널 재확인
        _verifyRealtimeSubscriptions()
      }
      if (event == AuthChangeEvent.signedOut) {
        // 예기치 않은 로그아웃
        // 세션 복구 시도 또는 로그인 화면
        _handleUnexpectedSignOut()
      }
    })
```

### DROP-B: 앱 백그라운드 → 포그라운드 복귀

```text
문제:
  고객이 다른 앱 사용 중 (카카오톡 등)
  iOS/Android 가 백그라운드 앱 메모리 해제
  포그라운드 복귀 시 Realtime WebSocket 끊김
  → 대기 호출 이벤트 수신 못함
  → 호출됐는데 모르고 노쇼 처리됨

방어 로직:

  WidgetsBindingObserver 필수 구현:

  class _WaitingScreenState extends State<WaitingScreen>
      with WidgetsBindingObserver {

    @override
    void initState() {
      super.initState()
      WidgetsBinding.instance.addObserver(this)
    }

    @override
    void didChangeAppLifecycleState(AppLifecycleState state) {
      if (state == AppLifecycleState.resumed) {
        // 포그라운드 복귀 시:
        _refreshWaitingStatus()      // 서버 상태 즉시 재조회
        _resubscribeRealtime()       // Realtime 재구독
      }
    }

    void _refreshWaitingStatus() async {
      final sessionId = _currentSessionId
      if (sessionId == null) return
      final result = await supabase.rpc(
        'get_waiting_status',
        params: {'p_session_id': sessionId}
      )
      _applyServerState(result)    // 서버 상태 우선 적용
    }

    void _resubscribeRealtime() {
      // 기존 채널 제거 후 재구독
      supabase.removeChannel(_waitingChannel)
      _waitingChannel = supabase.channel(
        'waiting:$_storeId'
      )..on(RealtimeListenTypes.broadcast,
          ChannelFilter(event: 'waiting_called'),
          (payload, [ref]) {
            _handleWaitingCalled(payload)
          })
        ..subscribe()
    }
  }

  추가 폴링 백업:
    Timer.periodic(Duration(seconds: 30), (_) {
      if (_isWaiting) _refreshWaitingStatus()
    })
    // Realtime 이벤트와 폴링 결과 불일치 시
    // 서버 상태 우선 적용
```

### DROP-C: 기기 변경 / 앱 재설치

```text
문제:
  SecureStorage 소멸
  기존 JWT 사라짐
  → 로그인 상태 초기화
  → 진행 중 대기 세션 분실 (서버엔 남아 있음)

방어 로직:

  재로그인 후 세션 복구:
    OTP 재인증 → 동일 phone_number → 동일 customer_id 반환
    → customers 테이블에서 이전 이력 복구

  진행 중 대기 세션 복구:
    로그인 완료 후:
    SELECT * FROM catchmenu_pos.order_sessions
    WHERE customer_id = :customer_id
      AND session_status IN ('WAITING', 'ARRIVAL_PENDING', 'SEATED')
      AND business_day = today
    LIMIT 1

    결과 있으면:
    → 해당 세션으로 복구 (대기 현황 화면)

  Flutter 구현:
    로그인 성공 후 _recoverActiveSession() 호출
    진행 중 세션 발견 → 해당 화면으로 이동
    없으면 → 홈 화면
```

### DROP-D: FCM 토큰 만료 / 기기 변경

```text
문제:
  FCM 토큰이 만료되거나 기기 변경으로 변경됨
  대기 호출 push 알림 미수신
  → 고객이 호출됐는데 모름

방어 로직:

  앱 실행 시마다 FCM 토큰 갱신:
    FirebaseMessaging.instance.getToken().then((token) {
      if (token != null && token != _savedFcmToken) {
        // 서버에 새 토큰 업데이트
        supabase.rpc('update_customer_fcm_token', params: {
          'p_customer_id': customerId,
          'p_fcm_token': token,
        })
        _savedFcmToken = token
      }
    })

  FCM 토큰 갱신 이벤트:
    FirebaseMessaging.instance.onTokenRefresh.listen((token) {
      supabase.rpc('update_customer_fcm_token', params: {
        'p_customer_id': customerId,
        'p_fcm_token': token,
      })
    })

  FCM + Realtime 이중 알림:
    Push (FCM): 앱 백그라운드/종료 상태
    Realtime: 앱 포그라운드 상태
    → 두 채널 모두 구현해야 누락 없음
```

### DROP-E: 결제 중 앱 전환 (토스페이먼츠)

```text
문제:
  토스페이먼츠 결제 창이 외부 앱으로 전환됨
  (카드사 인증 앱 등)
  복귀 시 앱 상태 초기화

방어 로직:

  결제 시작 전 상태 저장:
    SharedPreferences.setString(
      'pending_payment_order_id', orderId
    )
    SharedPreferences.setString(
      'pending_payment_session_id', sessionId
    )

  앱 재진입 시 (onResume 또는 딥링크):
    final pendingOrderId = prefs.getString(
      'pending_payment_order_id'
    )
    if (pendingOrderId != null) {
      // 결제 상태 서버 확인
      final result = await supabase.rpc(
        'check_payment_status',
        params: {'p_order_id': pendingOrderId}
      )
      if (result['paid'] == true) {
        // 이미 결제 완료 → 완료 화면
        _navigateToComplete()
      } else {
        // 미완료 → 결제 화면 복구
        _navigateToPayment()
      }
      // 처리 후 pending 데이터 삭제
      prefs.remove('pending_payment_order_id')
    }
```

---

## 2. 세션 생명주기

```text
[앱 최초 설치]
  스플래시 → 로그인 화면 (OTP)
    ↓ 전화번호 입력 + OTP 인증
  Supabase authenticated 세션 생성
  SecureStorage: access_token, refresh_token 저장
  customers 테이블: customer_id 생성 (신규) 또는 복구

[앱 재실행]
  스플래시 → SecureStorage JWT 복구
    access_token 유효 → 자동 로그인
    access_token 만료 → refresh_token 으로 갱신
    refresh_token 만료 (60일) → OTP 재인증

[대기 등록]
  register_waiting() 호출
    order_sessions.customer_id = customers.id 연결
    session_id → SharedPreferences 저장

[대기 완료 / 주문 완료]
  SharedPreferences: session_id 삭제
  customers: last_visit_at, visit_count, total_spent 갱신
  point_ledger: 포인트 적립 기록

[앱 삭제]
  SecureStorage 소멸
  재설치 후 OTP 재인증 → 동일 customer_id 복구
  포인트/이력은 서버에 보존
```

---

## 3. anon → authenticated 전환 (Phase 1 → Phase 2)

```text
Phase 1 에서 고객이 anon 으로 사용한 경우
Phase 2 에서 앱 업데이트 후 로그인 유도 시:

전환 흐름:
  1. 앱 업데이트 후 첫 실행
  2. "멤버십 가입하면 포인트 적립!" 배너 표시
  3. 전화번호 OTP 인증
  4. customers 계정 생성

  기존 anon 세션 귀속:
    customer_id 생성 후
    기존 order_sessions (phone_hash 일치하는 것):
    UPDATE order_sessions
    SET customer_id = :new_customer_id
    WHERE phone_hash = SHA256(:phone)
      AND customer_id IS NULL

  귀속 범위:
    phone_hash 가 있는 과거 세션만 가능
    phone_hash 없는 anon 세션은 귀속 불가 (정상)
```

---

## 4. 멤버십 적립 로직

```text
confirm_payment() 성공 직후 자동 실행:

earn_points_after_order():
  membership_mode 확인
    → STAMP: stamp_visit() 호출
      goal 도달 시 쿠폰 자동 발급
    → POINT: point_ledger INSERT
      balance_after 갱신
      tier 자동 업그레이드 확인

Realtime 알림:
  customer_app:{store_id} 채널
  → stamp_added event: 스탬프 +1 표시
  → tier_upgraded event: 등급 업 표시
  → coupon_issued event: 쿠폰 발급 알림

FCM push:
  "도장 7/10 모였습니다!" 또는
  "180포인트 적립! 현재 3,450포인트"
```

---

## 5. 상태 전이 (Ch2 특화 추가)

```text
Channel 1 (웹앱) 과 동일한 기본 흐름 +
아래 Ch2 특화 상태 추가:

[COMPLETED 후]
  earn_points_after_order() 자동 실행
  customers.visit_count += 1
  customers.total_spent_amount += final_amount
  customers.last_visit_at = now()
  get_customer_history() 에 이력 추가

[앱 포그라운드 복귀 시]
  didChangeAppLifecycleState(resumed)
  → get_waiting_status() 재조회
  → Realtime 재구독
  → FCM 토큰 유효성 확인
```

---

## 6. 보안 요건

```text
SecureStorage 저장 항목:
  supabase_access_token
  supabase_refresh_token
  (이 외 민감 정보 저장 금지)

SharedPreferences 저장 항목 (비민감):
  catchmenu_session_id
  catchmenu_store_id
  catchmenu_locale
  pending_payment_order_id (결제 중만)

절대 저장 금지:
  원본 전화번호
  카드 정보
  OTP 코드

RLS:
  customers: customer_id = auth.uid()
  order_sessions: customer_id 또는 anon session
  point_ledger: customer_id = auth.uid()
```

---

## 7. Ch1 웹앱과 Ch2 앱 세션 비교

| 항목 | Ch1 웹앱 | Ch2 캐치메뉴 앱 |
|---|---|---|
| 인증 | anon | OTP authenticated |
| 세션 저장 | localStorage | SecureStorage |
| JWT 갱신 | SDK 자동 | SDK 자동 + onAuthStateChange |
| 앱 복귀 처리 | 페이지 재로드 | WidgetsBindingObserver |
| Realtime 복구 | 폴링 백업 | onReconnect + resume |
| FCM push | 브라우저 제한 | 네이티브 완전 지원 |
| 멤버십 | 없음 | STAMP/POINT |
| 기기 변경 | session_id 분실 | OTP 재인증 → 복구 |
| 세션 복구 | localStorage 기반 | SecureStorage + server |
