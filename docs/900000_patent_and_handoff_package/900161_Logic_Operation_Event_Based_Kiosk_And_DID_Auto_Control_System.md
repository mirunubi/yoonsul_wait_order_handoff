# 900161_Logic_Operation_Event_Based_Kiosk_And_DID_Auto_Control_System

Status: In_Progress
Lifecycle: Logic
Owner: TBD
Last Updated: 2026-06-21

---

## 0. Document Purpose

이 Logic 문서는 운영 이벤트 기반 키오스크·DID 자동 제어 시스템의
Patent A, B, C 각각의 상세 제어 로직을 정의한다.

Related Overview:
  900160_Overview_Operation_Event_Based_Kiosk_And_DID_Auto_Control_System.md

---

## 1. Patent A Logic — 운영 이벤트 기반 자동 전환

### 1.1 이벤트 감지 → 화면 전환 파이프라인

```text
[운영 이벤트 발생]
        ↓
[이벤트 분류기]
  event_type 판별
  severity 결정
        ↓
[SOP 매칭]
  sop_runbooks 에서 해당 SOP 조회
  자동 실행 가능 여부 판단
        ↓
[권한 판단] (Patent B 연동)
  시스템 자동 / 가맹점 / 본사
        ↓
[화면 전환 실행]
  키오스크 상태 변경
  DID 큐 업데이트
  고객앱 Realtime 전송
        ↓
[감사 로그]
  catchmenu_ledger.events INSERT
  transition_log 기록
        ↓
[복구 모니터링]
  이벤트 해소 감지
  원래 상태 자동 복구
```

---

### 1.2 품절 이벤트 상세 로직

```text
트리거: update_inventory(p_qty_delta)
조건:   inventory_items.current_qty <= 0

자동 실행:
  1. menus.menu_status = 'SOLD_OUT'
  2. Realtime broadcast:
     채널: store:{store_id}
     이벤트: menu_status_changed
     payload: {menu_id, status: 'SOLD_OUT'}
  3. 키오스크 반응 (Flutter):
     Realtime 수신
     → get_kiosk_menu() 재호출
     → 해당 메뉴 카드 비활성화
     → 대체 메뉴 자동 하이라이트
  4. DID 반응:
     did_display_queue INSERT
     display_type: SOLD_OUT_NOTICE
     content: {menu_name, alt_menu}
     duration_seconds: 30
  5. 고객앱 반응:
     장바구니에 해당 메뉴 있으면
     → 경고 팝업
     → 제거 또는 대체 유도
  6. KDS 반응:
     기존 HOLD 티켓은 그대로 유지
     (결제된 주문은 취소 불가)
     신규 주문만 차단
  7. 감사 로그:
     event_type: MENU_SOLD_OUT
     from_state: AVAILABLE
     to_state: SOLD_OUT
     auto_executed: true

복구 로직:
  update_inventory(p_qty_delta > 0) 시
  current_qty > 0 이면
  → menus.menu_status = 'AVAILABLE'
  → Realtime broadcast: menu_status_changed
  → 키오스크/DID/고객앱 자동 복구
  → 감사 로그: MENU_RESTOCKED
```

---

### 1.3 대기 호출 이벤트 상세 로직

```text
트리거: call_waiting_customer(p_session_id)
조건:   order_sessions.session_status = 'WAITING'

자동 실행:
  1. order_sessions.session_status = 'ARRIVAL_PENDING'
  2. DID 큐:
     did_display_queue INSERT
     display_type: WAITING_CALL
     content: {wait_number, table_suggestion}
     duration_seconds: 180 (3분)
     sound_alert: true
  3. Realtime broadcast:
     채널: waiting:{store_id}
     이벤트: waiting_called
     payload: {wait_number, session_id}
  4. 고객앱:
     FCM 푸시 알림
     "입장해주세요! W-007번 고객님"
     딥링크: 대기 현황 화면
  5. 키오스크:
     대기 현황 숫자 -1 갱신
  6. 감사 로그:
     event_type: WAITING_CUSTOMER_CALLED
     from_state: WAITING
     to_state: ARRIVAL_PENDING

복구 로직 (노쇼):
  pg_cron: 15분 후 무응답 감지
  → session_status = 'NO_SHOW'
  → DID: 호출 번호 제거
  → 감사 로그: CUSTOMER_NO_SHOW
```

---

### 1.4 결제 완료 이벤트 상세 로직 (Patent 2 연동)

```text
트리거: confirm_payment() 성공
조건:   payment_ledger.status = 'APPROVED'

자동 실행:
  1. release_kds_after_payment()
     kds_tickets.kds_status: HOLD → COMMITTED
     kds_tickets.committed_at = now()
     kds_tickets.conditions_met.payment_confirmed = true
  2. Realtime broadcast:
     채널: kds:{store_id}
     이벤트: kds_tickets_released
     payload: {order_id, ticket_ids}
  3. KDS 반응:
     HOLD 티켓 → 녹색 활성화
     조리 버튼 활성화
     타이머 시작
  4. DID 반응:
     order_sessions 의 wait_number 호출 해제
     "조리 중" 상태 표시 (선택)
  5. 고객앱:
     "결제 완료! 조리가 시작됩니다" 알림
  6. 감사 로그:
     event_type: PAYMENT_CONFIRMED_KDS_RELEASED
     from_state: HOLD
     to_state: COMMITTED

불변 규칙:
  결제 없이 COMMITTED 전환 불가 (Patent 2 핵심)
  seating 만으로 COMMITTED 전환 불가
  calling 만으로 COMMITTED 전환 불가
```

---

### 1.5 조리 지연 이벤트 상세 로직

```text
트리거: pg_cron KDS_LATE_CHECK (1분마다)
조건:   committed_at + estimated_minutes < now()

자동 실행:
  1. kds_tickets.is_late = true (컬럼 또는 파생)
  2. operation_alerts INSERT
     alert_type: KDS_TICKET_LATE
     severity: WARNING
  3. DID 반응:
     예상 대기 시간 연장 표시
     "현재 조리에 시간이 소요되고 있습니다"
  4. 직원앱:
     Realtime: operation_alert 수신
     해당 티켓 빨간색 강조
  5. 신규 주문 제한 (옵션):
     kitchen_load_at_check 기반
     일정 부하 초과 시
     → 키오스크에 예상 대기 시간 경고 표시
  6. SOP 발동:
     SOP-KDS-001 자동 실행
     (주방 직원에게 지원 요청 메시지)
  7. 감사 로그:
     event_type: KDS_TICKET_LATE
```

---

### 1.6 결제 장애 이벤트 상세 로직

```text
트리거: record_van_transaction(status='FAILED')
조건:   연속 3회 이상 실패

자동 실행:
  1. operation_alerts INSERT
     alert_type: PAYMENT_SYSTEM_DOWN
     severity: CRITICAL
  2. change_store_mode('PAYMENT_ISSUE')
  3. 키오스크 반응:
     "현재 카드 결제에 문제가 있습니다
      현금 결제 또는 다른 방법으로 안내받으세요"
  4. DID 반응:
     "카드 결제 일시 장애 안내
      현금 결제 가능합니다"
  5. SOP 발동:
     SOP-PAY-001 자동 실행
     (결제 장애 대응 절차)
  6. 본사 알림:
     send_hq_notice(severity='EMERGENCY')
     해당 매장 결제 장애 즉시 보고
  7. 감사 로그:
     event_type: PAYMENT_SYSTEM_DOWN
     auto_sop_executed: SOP-PAY-001

복구 로직:
  record_van_transaction(status='APPROVED') 성공 시
  → store_mode 원복
  → 키오스크/DID 정상 표시
  → 감사 로그: PAYMENT_SYSTEM_RECOVERED
```

---

## 2. Patent B Logic — 권한 충돌 방지형 오버라이드

### 2.1 운영 우선순위 결정 로직

```text
이벤트 발생 시 우선순위 판단:

FUNCTION determine_override_level(event_type):

  if event_type IN (
    'PAYMENT_SYSTEM_DOWN',
    'STORE_EMERGENCY',
    'FIRE_SAFETY_ALERT'
  ):
    return Level 1 -- 시스템 자동 즉시 실행

  if event_type IN (
    'HQ_EMERGENCY_NOTICE'
  ):
    return Level 2 -- 본사 권한 전체 오버라이드

  if event_type IN (
    'MENU_SOLD_OUT',
    'INVENTORY_LOW',
    'KDS_TICKET_LATE',
    'KITCHEN_OVERLOAD'
  ):
    return Level 3 -- 시스템 자동 또는 가맹점 권한

  if event_type IN (
    'LOCAL_EVENT',
    'LOCAL_PROMOTION'
  ):
    return Level 4 -- 가맹점 권한 (본사 템플릿 범위)

  if event_type IN (
    'HQ_CAMPAIGN',
    'HQ_PROMOTION'
  ):
    return Level 5 -- 일반 광고 스케줄

  return Level 6 -- 기본 대기 화면
```

---

### 2.2 충돌 해소 로직

```text
충돌 시나리오:
  가맹점이 Level 4 이벤트 진행 중
  Level 2 본사 긴급 공지 발생

충돌 해소:
  1. Level 2 이벤트 감지
  2. 현재 진행 중인 Level 4 상태 스냅샷 저장
     override_snapshot:
       current_display: LOCAL_PROMOTION
       started_at: ...
       scheduled_end: ...
  3. Level 2 즉시 전환
     키오스크: 긴급 공지 전면 표시
     DID: 긴급 공지 전면 표시
     고객앱: 긴급 알림 푸시
  4. Level 2 이벤트 해소 감지
     hq_notices.status = 'RESOLVED'
  5. override_snapshot 기반 자동 복구
     Level 4 상태 복원
     (남은 시간만큼 재개)
  6. 감사 로그:
     event_type: OVERRIDE_APPLIED
     override_level: 2
     preempted_level: 4
     snapshot_restored: true

규칙:
  상위 Level 이 하위 Level 을 항상 선점
  선점 시 하위 상태 스냅샷 보존
  상위 해소 시 하위 자동 복구
  모든 선점/복구는 ledger 에 기록
```

---

### 2.3 가맹점 자율 범위 정의

```text
가맹점이 본사 승인 없이 처리 가능한 것:
  - 메뉴 품절 처리 (Level 3)
  - 재고 부족 안내 (Level 3)
  - 매장 모드 변경 BUSY/QUIET (Level 3)
  - 로컬 이벤트 등록 (Level 4, 본사 템플릿 내)
  - 직원 PIN 변경
  - 대기 호출

가맹점이 본사 승인 필요한 것:
  - 메뉴 가격 변경
  - 신규 메뉴 등록
  - 브랜드 이미지 변경
  - 영업시간 변경
  - Level 2 공지 발행

시스템이 자동 처리하는 것 (가맹점/본사 개입 없음):
  - Level 1 안전/장애 이벤트
  - KDS HOLD → COMMITTED (결제 확인 후)
  - 대기 세션 만료 (15분)
  - pg_cron 정기 배치
```

---

## 3. Patent C Logic — AI SOP 자가진화 시스템

### 3.1 반복 문의 감지 로직

```text
트리거: submit_customer_inquiry() 호출 시
        pg_cron KNOWLEDGE_GAP_BATCH (야간 배치)

감지 로직:
  SELECT
    inquiry_category,
    count(*) as cnt,
    array_agg(inquiry_text) as samples
  FROM catchmenu_knowledge.customer_inquiries
  WHERE resolved_by_sop = false
    AND created_at > now() - interval '7 days'
  GROUP BY inquiry_category
  HAVING count(*) >= 5
  ORDER BY cnt DESC;

결과 있으면:
  sop_evolution_log INSERT
  status: CANDIDATE
  trigger_count: cnt
  sample_inquiries: samples
  suggested_sop_domain: inquiry_category
  auto_generated_steps: AI 생성 (pgvector 유사 SOP 참조)
```

---

### 3.2 SOP 자동 생성 → 승인 → 배포 흐름

```text
[반복 문의 감지]
  detect_recurring_inquiries()
  sop_evolution_log: CANDIDATE 생성
        ↓
[AI 초안 생성]
  기존 sop_runbooks 중 유사한 것 벡터 검색
  (search_sop_runbooks 활용)
  → 초안 recovery_steps 자동 생성
  → sop_evolution_log: DRAFT
        ↓
[가맹점/본부 검토]
  직원앱 또는 관리자 콘솔에 표시
  "새 SOP 후보가 생성되었습니다. 검토해주세요"
        ↓
[승인]
  approve_sop_evolution(p_evolution_id)
  → sop_runbooks INSERT (신규 SOP)
  → sop_evolution_log: APPROVED
        ↓
[자동 배포]
  승인 즉시:
  1. 키오스크 안내 문구 업데이트
     (다음 부트스트랩 시 반영)
  2. DID 공지 업데이트
  3. AI 고객센터 답변 업데이트
  4. 전 가맹점 동시 배포 (tenant 설정에 따라)
  5. 감사 로그:
     event_type: SOP_EVOLVED_AND_DEPLOYED
```

---

### 3.3 키오스크/DID/고객센터 동시 반영 메커니즘

```text
SOP 승인 후 자동 반영:

키오스크:
  sop_runbooks.symptom_description 기반
  관련 메뉴/상황 발생 시
  → 안내 팝업 또는 도움말 버튼에 반영
  → bootstrap_kiosk() 재호출 시 최신 SOP 포함

DID:
  sop_runbooks.related_alert_types 기반
  관련 operation_alert 발생 시
  → DID 안내 문구 자동 업데이트
  → did_display_queue에 SOP 기반 메시지 추가

고객센터 (AI):
  sop_runbooks.recovery_steps 기반
  동일 유형 문의 수신 시
  → 자동 답변에 반영
  → customer_inquiries.resolved_by_sop = true

전 가맹점 배포:
  sop_runbooks에 tenant_id = NULL 이면 공통 SOP
  tenant_id = 특정 테넌트 이면 해당 가맹점만
```

---

## 4. 이벤트 → 화면 전환 전체 상태 다이어그램

```text
[정상 운영 상태]
  키오스크: 전체 메뉴 표시, 주문 가능
  DID: 대기 현황 + 기본 광고
  고객앱: 대기 등록 가능
          ↓
    운영 이벤트 발생
          ↓
┌─────────────────────────────────────┐
│ Level 1: 안전/결제 장애             │
│  키오스크: 장애 안내 전면 표시      │
│  DID: 장애 안내 전면 표시           │
│  주문: 전면 중단                    │
│  SOP: 자동 발동                     │
├─────────────────────────────────────┤
│ Level 2: 본사 긴급 공지             │
│  키오스크: 긴급 공지 전면 표시      │
│  DID: 긴급 공지 전면 표시           │
│  가맹점 활동: 일시 중단             │
├─────────────────────────────────────┤
│ Level 3: 품절/재고/조리 지연        │
│  키오스크: 해당 메뉴만 비활성화     │
│  DID: 품절/지연 안내 추가           │
│  나머지 운영: 정상 유지             │
├─────────────────────────────────────┤
│ Level 4: 로컬 이벤트               │
│  키오스크: 이벤트 배너 표시         │
│  DID: 이벤트 안내 추가              │
│  전체 운영: 정상 유지               │
├─────────────────────────────────────┤
│ Level 5: 일반 광고                  │
│  키오스크: 광고 배너 (유휴 시)      │
│  DID: 광고 슬롯                     │
├─────────────────────────────────────┤
│ Level 6: 기본 대기 화면             │
│  키오스크: 브랜드 기본 화면         │
│  DID: 대기 번호 현황                │
└─────────────────────────────────────┘
          ↓
    이벤트 해소 감지
          ↓
[원래 상태 자동 복구]
  스냅샷 기반 이전 상태 복원
  감사 로그: EVENT_RESOLVED_AUTO_RECOVERED
```

---

## 5. 감사 로그 요건 (특허 증빙)

```text
모든 화면 전환은 아래 필드를 포함해야 한다:

catchmenu_ledger.events:
  event_type
  store_id
  tenant_id
  triggered_by          (SYSTEM / STAFF / HQ / POS / KDS)
  from_state
  to_state
  override_level        (1~6)
  sop_executed          (SOP 코드 또는 null)
  affected_devices      (KIOSK / DID / CUSTOMER_APP / KDS)
  auto_executed         (boolean)
  approval_required     (boolean)
  approved_by           (null if auto)
  snapshot_saved        (boolean)
  snapshot_restored     (boolean)
  occurred_at

이 로그가 특허 분쟁 시 구현 증빙이 된다.
```

---

## 6. Flutter 구현 바인딩

```text
키오스크 앱 (Flutter Web):
  Realtime 구독:
    store:{store_id} → menu_status_changed
    store:{store_id} → store_mode_changed
  이벤트 수신 시:
    get_kiosk_menu() 재호출
    UI 자동 갱신

DID 앱 (Flutter):
  Realtime 구독:
    waiting:{store_id} → waiting_called
    did:{store_id} → WAITING_CALL
    store:{store_id} → menu_status_changed
  이벤트 수신 시:
    bootstrap_did_app() 또는 상태 직접 갱신

고객앱 (Flutter):
  Realtime 구독:
    waiting:{store_id} → waiting_called
    customer_app:{store_id} → order_status_changed
  FCM:
    백그라운드 푸시 수신
    딥링크로 해당 화면 이동

직원앱 (Flutter):
  Realtime 구독:
    staff:{store_id} → operation_alert
    kds:{store_id} → kds_ticket_updated
  이벤트 수신 시:
    알림 배지 + 소리
    해당 화면 자동 이동
```

---

## 7. Open Issues

```text
- [ ] Level 1 이벤트 자동 감지 기준 최종 결정
  현재: 연속 3회 결제 실패 = Level 1
  검토: 기준 건수 조정 필요

- [ ] Patent C AI 초안 생성 모델 선택
  현재: pgvector 유사 SOP 참조
  향후: LLM API 연동 (OpenAI 또는 자체)

- [ ] DID 디바이스 오프라인 시 처리
  현재: Realtime 재연결 시 최신 상태 수신
  검토: 오프라인 중 이벤트 누락 처리

- [ ] 가맹점 로컬 이벤트 승인 워크플로우
  현재: 본사 템플릿 범위 내 자율
  향후: 일부 이벤트는 본사 사전 승인 필요 여부

- [ ] 특허 출원 시점
  현재: 변리사 미팅 전
  일정: 서울 1호점 오픈 전 출원 권장
```
