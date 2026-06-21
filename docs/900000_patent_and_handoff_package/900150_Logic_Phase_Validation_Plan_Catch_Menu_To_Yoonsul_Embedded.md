# 900150_Logic_Phase_Validation_Plan_Catch_Menu_To_Yoonsul_Embedded

Status: In_Progress
Lifecycle: Logic
Owner: TBD
Last Updated: 2026-06-21

---

## 0. Document Purpose

이 Logic 문서는 캐치메뉴 MVP 에서 윤슬김밥 임베디드 앱까지
단계별 검증 계획을 정의한다.

핵심 검증 질문:

```text
Phase 1:
  캐치메뉴 웹앱/자체앱 데이터가
  윤슬김밥 임베디드 앱에 제대로 들어오는가?

Phase 2:
  멤버십 레이어가 Phase 1 운영 데이터 위에
  충돌 없이 올라오는가?

Phase 3:
  외부 매장에 배포했을 때
  tenant_id 격리가 완벽한가?
```

---

## 1. Phase 1 검증 — 서울 1호점 MVP

### V-01: 기본 인프라 검증

```text
목적: Supabase 연결 + 스키마 정상 작동 확인

실행:
  SELECT catchmenu_common.run_integration_test(
    '[tenant_id]', '[store_id]'
  );

통과 기준:
  overall = 'ALL_PASS'
  9개 스키마 존재 확인
  RLS 정책 전 테이블 활성
  pg_cron 활성 작업 20개+
  SOP 런북 20개+

실패 시:
  마이그레이션 재적용
  run_opening_checklist() 로 미설정 항목 확인
```

---

### V-02: 오픈 준비 체크리스트

```text
목적: 1호점 오픈 전 필수 항목 확인

실행:
  SELECT catchmenu_common.run_opening_checklist(
    '[tenant_id]', '[store_id]'
  );

필수 PASS 항목:
  [ ] 매장 기본 설정
  [ ] 메뉴 등록 (5개+)
  [ ] 알레르겐 등록 (식품위생법 필수)
  [ ] 직원 등록
  [ ] 직원 PIN 설정
  [ ] 영업시간 설정 (7요일)

WARN 허용 항목:
  [ ] 키오스크 설정 (미사용 시 WARN 허용)
  [ ] DID 설정 (미사용 시 WARN 허용)
  [ ] 메뉴 임베딩 (외국인 서비스 준비)
  [ ] POS 연동 (수동 결제 병행 허용)

판정:
  READY → 오픈 가능
  CAUTION → WARN 항목 검토 후 오픈 결정
  NOT_READY → FAIL 항목 해결 필수
```

---

### V-03: Patent 1+2 핵심 흐름 검증

```text
목적: KDS Late Binding 실제 작동 확인

시나리오:
  1. 웹앱 QR 스캔 → 대기 등록
  2. 대기 중 메뉴 선택 → 사전 주문
  3. KDS HOLD 확인 (주방 태블릿)
  4. 직원 앱에서 호출 → DID 표시 확인
  5. 착석 처리 → KDS 여전히 HOLD 확인
  6. 결제 → KDS COMMITTED 전환 확인
  7. 조리 시작 → COOKING → READY → SERVED

검증 쿼리 (결제 후):
  SELECT kt.kds_status,
         kt.conditions_met,
         kt.committed_at,
         pl.approved_at
  FROM catchmenu_kds.kds_tickets kt
  JOIN catchmenu_payment.payment_ledger pl
    ON pl.order_id = kt.order_id
  WHERE kt.order_id = '[order_id]';

  기대:
    kds_status = 'COMMITTED'
    conditions_met.payment_confirmed = true
    committed_at >= approved_at

ledger 증빙 쿼리:
  SELECT event_type, from_state,
         to_state, occurred_at
  FROM catchmenu_ledger.events
  WHERE subject_id = '[session_id]'
  ORDER BY occurred_at;

  필수 6개 이벤트:
    waiting_registered
    pre_order_registered
    waiting_called
    customer_seated
    payment_confirmed
    kds_released_after_payment

통과 기준: KDS COMMITTED = 결제 후에만
```

---

### V-04: 캐치메뉴 웹앱 → 윤슬앱 데이터 정합성

```text
목적: 두 채널이 같은 DB 데이터를 공유하는지 확인

시나리오:
  1. 캐치메뉴 웹앱으로 서울 1호점 대기 등록
     → session_id = S-001 발급
  2. 윤슬김밥 앱 실행 (같은 store_id)
  3. 대기 현황에서 S-001 세션 조회
  4. 동일 wait_number, queue_position 표시 확인

검증:
  두 앱이 같은 Supabase 프로젝트 연결 확인
  tenant_id = 윤슬김밥 고정 확인
  RLS: 두 앱 모두 동일 데이터 접근 허용 확인

통과 기준: 동일 데이터 표시
실패 시: tenant_id 설정 오류 또는 RLS 정책 확인
```

---

### V-05: 직원 앱 ↔ 고객 앱 Realtime 연동

```text
목적: Realtime 이벤트가 양방향으로 정상 전달되는지 확인

시나리오 A (호출 알림):
  1. 직원 앱 → call_waiting_customer() 호출
  2. 고객 앱 (윤슬앱) Realtime 수신 확인
     waiting_called 이벤트
  3. "입장해주세요" 화면 표시 확인
  4. DID 화면 호출 번호 표시 확인

시나리오 B (KDS 상태 변경):
  1. 결제 완료 → KDS COMMITTED
  2. KDS 디스플레이 앱 Realtime 수신 확인
     kds_tickets_released 이벤트
  3. 티켓 회색 → 녹색 전환 확인

시나리오 C (메뉴 품절):
  1. 직원 앱 → set_menu_status(SOLD_OUT)
  2. 고객 앱 메뉴 화면 즉시 갱신 확인
  3. 키오스크 메뉴 화면 즉시 갱신 확인

통과 기준: 전 시나리오 Realtime 1초 이내 반영
```

---

### V-06: OKpos 연동 검증

```text
목적: 캐치메뉴 주문 → OKpos 정상 전송 확인

선행 조건:
  okpos-order-send Edge Function 배포 완료
  OKpos 테스트 단말기 연결

시나리오:
  1. 캐치메뉴 앱에서 주문 완료
  2. okpos-order-send Edge Function 호출 확인
  3. OKpos 단말기에서 주문 수신 확인
  4. OKpos 영수증 출력 확인

검증:
  pos_transactions 테이블 기록 확인
  okpos_order_id 발급 확인
  주문 금액 일치 확인

통과 기준: OKpos 수신 + 영수증 출력
실패 시: Edge Function 로그 확인 → SOP-POS-001
```

---

### V-07: 토스POS 결제 연동 검증

```text
목적: 토스POS 결제 → KDS COMMITTED 자동 전환 확인

선행 조건:
  toss-payments-confirm Edge Function 배포 완료
  toss-payments-webhook Edge Function 배포 완료
  토스POS 단말기 연결

시나리오:
  1. 사전 주문 → KDS HOLD 확인
  2. 토스POS 단말기에서 결제
  3. webhook 수신 → confirm_payment() 자동 호출
  4. payment_ledger APPROVED 확인
  5. KDS COMMITTED 자동 전환 확인
  6. 고객 앱 "조리 중" 화면 표시 확인

idempotency 검증:
  webhook 인위적 중복 발송
  → KDS COMMITTED 중복 없음 확인
  → payment_ledger 중복 없음 확인

통과 기준:
  결제 → KDS COMMITTED 자동 (직원 개입 없음)
  중복 webhook 안전
```

---

### V-08: 세션 드롭 방어 검증

```text
목적: 과거 드롭 원인이 해결됐는지 확인

DROP-A 검증 (JWT 만료):
  1. 대기 등록 후 1시간 대기 (또는 토큰 강제 만료)
  2. API 호출 시도
  3. 자동 갱신 후 정상 응답 확인
  기대: 401 에러 없음

DROP-B 검증 (앱 복귀):
  1. 대기 등록 후 앱 백그라운드 5분
  2. 포그라운드 복귀
  3. 대기 현황 즉시 갱신 확인
  4. Realtime 구독 자동 재연결 확인

DROP-C 검증 (기기 변경):
  1. 기기 A 에서 대기 등록 + 전화번호 입력
  2. 기기 B 에서 OTP 재로그인
  3. 기기 A 의 대기 세션 복구 확인

DROP-E 검증 (결제 중 앱 전환):
  1. 결제 창에서 카드사 앱으로 전환
  2. 복귀 후 결제 상태 확인
  3. 완료 또는 재시도 화면 정상 표시 확인

통과 기준: DROP-A~E 모두 정상 복구
```

---

### V-09: 세션 충돌 없음 검증 (Ch4 특화)

```text
목적: 캐치메뉴 자체 앱 + 윤슬앱 동시 사용 시
      세션이 충돌하지 않음 확인

시나리오:
  1. 캐치메뉴 앱에서 대기 등록 (session-A)
  2. 같은 기기에서 윤슬앱 실행
  3. 윤슬앱 session_id 확인
  4. session-A 와 다른 값인지 확인

검증:
  SharedPreferences 키 이름 분리 확인
    캐치메뉴 앱: 'cm_app_session_id'
    윤슬앱: 'yoonsul_session_id'
  두 앱의 Supabase 세션이 독립적인지 확인

통과 기준: session_id 값 다름 (충돌 없음)
```

---

## 2. Phase 1 → Phase 2 전환 기준

```text
아래 모두 충족 시 Phase 2 (멤버십) 개발 시작:

운영 검증:
  [ ] V-01 인프라 ALL_PASS
  [ ] V-02 오픈 체크리스트 READY/CAUTION
  [ ] V-03 Patent 1+2 실제 작동 확인
  [ ] V-04 데이터 정합성 확인
  [ ] V-05 Realtime 양방향 1초 이내

POS 연동:
  [ ] V-06 OKpos 주문 전송 확인
  [ ] V-07 토스POS 결제 → KDS 자동 전환
  [ ] V-07 idempotency 확인

세션:
  [ ] V-08 DROP-A~E 방어 확인
  [ ] V-09 세션 충돌 없음 확인

실제 운영:
  [ ] 서울 1호점 실제 고객 1주일 운영
  [ ] 운영 중 에러 없음 (또는 수용 가능한 수준)
  [ ] get_daily_report() 데이터 정상 축적

판정:
  전 항목 체크 → Phase 2 개발 시작 승인
  미체크 항목 → 수정 후 재검증
```

---

## 3. Phase 2 검증 — 멤버십 통합

### V-10: anon → authenticated 세션 업그레이드

```text
목적: Phase 1 anon 세션이 Phase 2 계정으로 연결되는지 확인

시나리오:
  1. Phase 1 에서 전화번호 입력 후 대기 등록
     → order_sessions.phone_hash 저장됨
  2. Phase 2 앱 업데이트 후 OTP 로그인
     → customers 계정 생성
  3. 기존 order_sessions 귀속 확인
     phone_hash 일치 → customer_id 연결

검증:
  SELECT customer_id
  FROM catchmenu_pos.order_sessions
  WHERE phone_hash = SHA256('[phone]')
  기대: customer_id = 새로 생성된 ID

통과 기준: 기존 세션 customer_id 귀속
```

---

### V-11: 스탬프 / 포인트 적립

```text
목적: 결제 후 자동 적립 확인

시나리오:
  1. OTP 로그인 후 대기 등록
  2. 주문 + 결제 완료
  3. earn_points_after_order() 자동 실행 확인
  4. stamp_cards 또는 point_ledger 기록 확인
  5. 고객 앱 Realtime stamp_added 수신 확인
  6. FCM push 알림 수신 확인

STAMP 모드 검증:
  stamp_cards.current_count += 1 확인
  goal 도달 시 쿠폰 자동 발급 확인

POINT 모드 검증:
  point_ledger INSERT 확인
  balance_after 정확성 확인
  tier 업그레이드 기준 도달 시 자동 처리 확인

통과 기준: 결제 후 즉시 적립 + 알림
```

---

### V-12: 브랜드 전체 포인트 통합 (Ch4)

```text
목적: 매장 A 포인트가 매장 B 에서 사용 가능한지 확인

시나리오:
  1. 서울 1호점에서 포인트 적립
  2. 서울 2호점 (오픈 후) 앱에서 잔액 확인
  3. 동일 포인트 잔액 표시 확인
  4. 2호점에서 포인트 사용 확인

검증:
  SELECT SUM(points), balance_after
  FROM catchmenu_store.point_ledger
  WHERE customer_id = '[customer_id]'
  GROUP BY customer_id

통과 기준: 브랜드 전체 잔액 통합 표시
```

---

## 4. Phase 3 검증 — 외부 확산

### V-20: 외부 가맹점 tenant_id 격리

```text
목적: 외부 매장 배포 시 데이터 격리 확인

시나리오:
  1. 외부 매장 A 온보딩 (신규 tenant_id)
  2. 외부 매장 A 고객이 윤슬김밥 데이터 접근 시도
  3. RLS 에 의해 빈 결과 반환 확인
  4. 반대 방향도 동일 확인

검증:
  외부 매장 A JWT 로 윤슬김밥 order_sessions 조회
  → 결과: 0건 (RLS 작동)

통과 기준: 완전 격리 확인
실패 시: RLS 정책 즉시 수정. 외부 배포 중단.
```

---

### V-21: 피드백 수집 메트릭

```text
목적: 외부 배포 후 품질 지표 수집

모니터링 항목:
  일일 리포트:
    SELECT catchmenu_common.get_daily_report(
      '[tenant_id]', '[store_id]'
    );

  KPI:
    order_count: 일평균 주문 수
    avg_wait_minutes: 평균 대기 시간
    seat_rate: 대기 → 착석 전환율
    kds_late_tickets: 지연 조리 건수
    foreign_customers: 외국인 방문 수
    error_count: 일일 에러 수

개선 기준:
  seat_rate < 80% → 호출/DID 시스템 점검
  kds_late_tickets > 10% → 주방 용량 검토
  error_count > 5 → 버그 수정 우선
  foreign_customers > 20% → 임베딩 품질 개선
```

---

## 5. 검증 실행 환경

```text
Phase 1 환경:
  Supabase: Pro 플랜 (서울 1호점)
  tenant_id: 실제 운영 테넌트
  store_id:  서울 1호점
  기기:
    직원 앱: 태블릿 1~2대
    KDS: 주방 태블릿 1대
    DID: 입구 모니터 1대
    키오스크: 태블릿 1대 (선택)
    고객 앱: 윤슬앱 + 캐치메뉴 앱 (테스트)

Phase 2 추가:
  고객 기기: 개인 스마트폰 (실제 고객)
  FCM: Firebase 프로젝트 연결

raw log 저장:
  raw_logs/ 폴더에 날짜별 저장
  Claude 감리 시 제출
```

---

## 6. 검증 완료 기준 요약

```text
Phase 1 완료 기준 (서울 1호점 오픈):
  [ ] V-01 인프라 ALL_PASS
  [ ] V-02 오픈 체크 READY
  [ ] V-03 Patent 1+2 실제 작동
  [ ] V-04 데이터 정합성
  [ ] V-05 Realtime 연동
  [ ] V-06 OKpos 연동
  [ ] V-07 토스POS + idempotency
  [ ] V-08 세션 드롭 방어
  [ ] V-09 세션 충돌 없음
  [ ] 1주일 실제 운영 무장애

Phase 2 완료 기준 (멤버십 오픈):
  [ ] V-10 세션 업그레이드
  [ ] V-11 스탬프/포인트 적립
  [ ] V-12 브랜드 전체 통합

Phase 3 완료 기준 (외부 확산):
  [ ] V-20 tenant 격리 완벽
  [ ] V-21 피드백 KPI 기준 충족
  [ ] 외부 매장 3개+ 무장애 운영
```
