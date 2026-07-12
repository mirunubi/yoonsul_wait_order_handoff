# 900165_Logic_POS_Dynamic_Multi_Service_Slot_Container_Agent_System

Status: In_Progress
Lifecycle: Logic
Owner: TBD
Last Updated: 2026-06-21

---

## 0. Document Purpose

이 Logic 문서는 POS 동적 다중 서비스 슬롯 컨테이너 Agent 시스템의
슬롯 생성, Agent 동작, 이벤트 처리, Flutter 구현 로직을 정의한다.

Related Overview:
  900164_Overview_POS_Dynamic_Multi_Service_Slot_Container_Agent_System.md

---

## 1. 슬롯 생성 트리거 로직

```text
신규 슬롯 생성 조건 (하나 이상 충족 시):

  TRIGGER_USER_PLUS:
    직원/관리자가 + 슬롯 선택
    → 서비스 목록에서 선택
    → 인증 완료 → 슬롯 생성

  TRIGGER_API_AUTH:
    외부 서비스 API 인증 완료
    → 자동 슬롯 생성
    → Agent 자동 활성화

  TRIGGER_CONTRACT:
    배달앱/멤버십 계약 완료
    → 중앙 서버 정책으로 슬롯 배포

  TRIGGER_MODULE:
    AI 고객센터, SOP Agent, 멤버십 모듈 활성화
    → 해당 슬롯 자동 생성

  TRIGGER_EVENT:
    외부 주문/운영 이벤트 최초 수신
    → 미등록 서비스 이벤트 감지
    → 슬롯 자동 생성 제안

  TRIGGER_HQ_POLICY:
    본사에서 가맹점에 서비스 권한 부여
    → 해당 슬롯 자동 배포

슬롯 생성 시:
  slot_container_configs INSERT
  slot_agent_states 초기화
  Realtime broadcast: slot_created
  Flutter: 슬롯 UI 자동 추가
```

---

## 2. SlotContainerAgent 동작 로직

### 2.1 이벤트 수신 흐름

```text
[외부 이벤트 발생]
  배달앱 신규 주문
  멤버십 포인트 적립
  고객 문의 수신
  운영 알림
        ↓
[SlotContainerAgent]
  이벤트 분류
  우선순위 결정 (Level 1~5)
  해당 슬롯 Agent 에 라우팅
        ↓
[해당 슬롯 Agent]
  이벤트 처리
  직원 액션 필요 여부 판단
  필요 시 팝업 트리거
        ↓
[Realtime broadcast]
  채널: slot:{store_id}
  payload: {slot_id, event_type, badge_count, popup_required}
        ↓
[Flutter SlotContainerWidget]
  배지 갱신
  팝업 조건 충족 시 슬라이딩 팝업 표시
        ↓
[직원 확인/처리]
  확인 버튼 → slot_events.status = RESOLVED
  팝업 자동 닫힘
  슬롯 정상화
        ↓
[감사 로그]
  catchmenu_ledger.events INSERT
  slot_id, event_type, resolved_by, resolved_at
```

---

### 2.2 이벤트 우선순위 결정

```text
FUNCTION determine_slot_priority(event_type):

  Level 1 (즉시 강조 + 소리):
    PAYMENT_SYSTEM_DOWN
    KDS_SYSTEM_ERROR
    STORE_EMERGENCY

  Level 2 (배지 + 자동 팝업):
    DELIVERY_NEW_ORDER     ← 시간 민감
    DELIVERY_ORDER_CANCEL
    DELIVERY_ORDER_ERROR

  Level 3 (배지 + 팝업):
    KDS_TICKET_LATE
    MENU_SOLD_OUT
    INVENTORY_LOW

  Level 4 (배지만):
    CUSTOMER_INQUIRY
    MEMBERSHIP_POINT_EARNED
    COUPON_ISSUED

  Level 5 (조용히 배지):
    GENERAL_OPERATION_NOTICE
    DAILY_REPORT_READY

Level 1/2 → 자동 팝업 (직원 확인 전까지 유지)
Level 3   → 팝업 (5초 후 자동 닫힘 또는 확인 시)
Level 4/5 → 배지만 (팝업 없음)
```

---

### 2.3 슬롯별 Agent 상세 로직

#### 슬롯 A: 배달앱 Agent

```text
서비스: 배민 / 요기요 / 쿠팡이츠

이벤트 수신:
  delivery_orders 테이블 변경 감지
  또는 배달앱 webhook 수신

처리 흐름:
  신규 주문 수신
  → slot_events INSERT (NEW_ORDER)
  → 배지 +1
  → Level 2 자동 팝업

  팝업 내용:
    주문 번호 / 메뉴 / 금액 / 예상 배달 시간
    [수락] [거절] [확인]

  수락 시:
    delivery_orders.status = ACCEPTED
    KDS 티켓 생성 (HOLD)
    결제 확인 후 KDS COMMITTED (Patent 2)

  거절 시:
    delivery_orders.status = REJECTED
    배달앱 자동 응답

  오류 시:
    slot_events INSERT (ORDER_ERROR)
    Level 1 강조
    SOP-DEL-001 자동 안내
```

#### 슬롯 B: 멤버십 Agent

```text
서비스: 캐치메뉴 멤버십 / 쿠폰

이벤트:
  결제 완료 → 포인트 자동 적립 알림
  쿠폰 발행 알림
  등급 업그레이드 알림

처리 흐름:
  earn_points_after_order() 완료
  → slot_events INSERT (POINT_EARNED)
  → 배지 (Level 4, 팝업 없음)
  → 직원 확인 불필요

  쿠폰 만료 임박:
  → 배지 + Level 3 팝업
  → 직원 고객 안내 유도
```

#### 슬롯 C: AI 고객센터 Agent

```text
서비스: AI 고객센터 + SOP 연동

이벤트:
  고객 문의 수신 (키오스크/DID)
  AI 자동 답변 완료
  직원 확인 필요 문의

처리 흐름:
  submit_customer_inquiry() 수신
  → AI 자동 답변 시도
  → 성공: 배지만 (Level 4)
  → 실패/직원 필요: 팝업 (Level 3)

  팝업 내용:
    문의 내용 요약
    AI 답변 초안
    [전송] [수정 후 전송] [직접 응대]
```

#### 슬롯 D: 캐치메뉴 운영OS Agent

```text
서비스: 캐치메뉴 코어 운영 이벤트

이벤트:
  품절 / 재고 부족 / KDS 지연
  대기 호출 / 결제 완료
  매장 모드 변경

처리 흐름:
  운영 이벤트 감지 (Patent A 연동)
  → 해당 Level 로 분류
  → 팝업 + SOP 자동 안내

  KDS 지연 (Level 3):
    팝업: "테이블 7번 조리 지연 중"
    [SOP 보기] [주방 알림]

  품절 (Level 3):
    팝업: "참치김밥 품절 처리되었습니다"
    [확인] [재입고 예정 설정]
```

---

## 3. Flutter 구현 상세

### 3.1 SlotContainerWidget

```dart
// Android System Overlay 방식
// 모든 POS 앱 위에 올라감

class SlotContainerWidget extends StatefulWidget {
  final String storeId;
  final SlotPosition position; // SIDEBAR/TOPBAR/BOTTOMBAR/FLOATING

  // 초기화
  void _initialize() {
    // 1. slot_container_configs 로드
    // 2. 각 슬롯 Agent 초기화
    // 3. Realtime 구독 시작
    // 4. 위치/크기 설정 복구
  }
}

// 슬롯 위치 옵션
enum SlotPosition {
  rightSidebar,   // Image 2: 우측 세로
  topBar,         // Image 3: 상단 가로 A|B|C|+
  bottomBar,      // 하단 가로
  floating,       // 자유 위치
}
```

### 3.2 SlotBarWidget

```dart
// Image 3 기준: A | B | C | +
// Image 2 기준: 우측 세로 A/B/C/D/E/+

class SlotBarWidget extends StatelessWidget {
  final List<SlotConfig> slots;

  Widget build(BuildContext context) {
    return Row( // 또는 Column (세로 모드)
      children: [
        ...slots.map((slot) => SlotItemWidget(slot)),
        SlotAddButton(), // + 버튼
      ],
    );
  }
}

class SlotItemWidget extends StatelessWidget {
  final SlotConfig slot;

  // 상태별 표시:
  // 비활성 → 흐린 아이콘
  // 활성   → 기본 아이콘
  // 배지   → 아이콘 + 숫자 배지
  // 긴급   → 빨간 강조 + 진동
}
```

### 3.3 SlotPopupWidget (슬라이딩)

```dart
class SlotPopupWidget extends StatefulWidget {
  // 슬라이딩 애니메이션
  // 이벤트 요약 카드
  // 확인/처리 버튼

  // 자동 닫힘 (Level 3: 5초)
  // Level 1/2: 직원 확인 전까지 유지

  void _onConfirm() async {
    await supabase.rpc('resolve_slot_event', params: {
      'p_slot_event_id': event.id,
      'p_resolved_by': currentStaffId,
    });
    // 팝업 닫힘
    // 슬롯 배지 갱신
    // 감사 로그 자동 기록
  }
}
```

### 3.4 Realtime 구독

```dart
void _subscribeRealtime() {
  supabase
    .channel('slot:$storeId')
    .on(RealtimeListenTypes.broadcast,
      ChannelFilter(event: 'slot_event_created'),
      (payload, [ref]) {
        _handleSlotEvent(payload);
      })
    .on(RealtimeListenTypes.broadcast,
      ChannelFilter(event: 'slot_badge_updated'),
      (payload, [ref]) {
        _updateBadge(payload);
      })
    .subscribe();
}

// 앱 포그라운드 복귀 시 재구독 (DROP-B 방어)
@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  if (state == AppLifecycleState.resumed) {
    _subscribeRealtime();
    _refreshAllSlotStates();
  }
}
```

---

## 4. DB 스키마

### 4.1 slot_container_configs

```sql
CREATE TABLE catchmenu_store.slot_container_configs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL,
  store_id uuid NOT NULL,

  -- 슬롯 식별
  slot_code text NOT NULL,        -- A, B, C, D, E
  slot_label text,                -- 배달앱, 멤버십...
  service_type text NOT NULL,     -- DELIVERY/MEMBERSHIP/AI/OPS/CUSTOM
  service_code text,              -- BAEMIN, COUPANG, CATCHMENU...

  -- 표시 설정
  display_position text NOT NULL  -- SIDEBAR/TOPBAR/BOTTOMBAR/FLOATING
    DEFAULT 'SIDEBAR',
  display_order int DEFAULT 0,
  icon_url text,
  color_hex text,

  -- 상태
  is_active boolean DEFAULT true,
  agent_config jsonb DEFAULT '{}',

  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);
```

### 4.2 slot_events

```sql
CREATE TABLE catchmenu_store.slot_events (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL,
  store_id uuid NOT NULL,
  slot_id uuid NOT NULL,

  -- 이벤트
  event_type text NOT NULL,
  event_level int NOT NULL DEFAULT 4,  -- 1~5
  event_status text NOT NULL           -- PENDING/RESOLVED/DISMISSED
    DEFAULT 'PENDING',

  -- 내용
  payload jsonb,
  requires_action boolean DEFAULT false,
  popup_triggered boolean DEFAULT false,

  -- 처리
  resolved_by uuid,
  resolved_at timestamptz,

  -- 감사
  correlation_id uuid,
  created_at timestamptz DEFAULT now()
);
```

### 4.3 slot_agent_states

```sql
CREATE TABLE catchmenu_store.slot_agent_states (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL,
  store_id uuid NOT NULL,
  slot_id uuid NOT NULL,

  -- Agent 상태
  agent_status text DEFAULT 'IDLE',   -- IDLE/ACTIVE/ERROR
  badge_count int DEFAULT 0,
  last_event_at timestamptz,
  last_error_at timestamptz,
  last_error_message text,

  -- 서비스 연결 상태
  service_connected boolean DEFAULT false,
  service_last_ping_at timestamptz,

  updated_at timestamptz DEFAULT now()
);
```

---

## 5. RPC 목록

```text
slot_container_configs 관련:
  create_slot(p_tenant_id, p_store_id, p_service_type, p_service_code)
  update_slot_position(p_slot_id, p_position, p_order)
  deactivate_slot(p_slot_id)

slot_events 관련:
  create_slot_event(p_slot_id, p_event_type, p_level, p_payload)
  resolve_slot_event(p_slot_event_id, p_resolved_by)
  dismiss_slot_event(p_slot_event_id)
  get_pending_slot_events(p_store_id)

SlotContainerAgent 관련:
  bootstrap_slot_container(p_store_id)
    → 전체 슬롯 설정 + 미처리 이벤트 반환
  get_slot_badge_summary(p_store_id)
    → 슬롯별 배지 카운트 요약
```

---

## 6. 감사 로그 요건

```text
모든 슬롯 이벤트는 catchmenu_ledger.events 에 기록:

  event_type: SLOT_EVENT_CREATED
  event_type: SLOT_EVENT_RESOLVED
  event_type: SLOT_POPUP_TRIGGERED
  event_type: SLOT_SERVICE_CONNECTED
  event_type: SLOT_SERVICE_ERROR

필수 필드:
  store_id, tenant_id
  slot_id, slot_code
  event_level
  actor_type: STAFF / SYSTEM / AGENT
  actor_id
  occurred_at
```

---

## 7. 구현 우선순위

```text
Phase 1 (MVP):
  [ ] slot_container_configs 테이블
  [ ] slot_events 테이블
  [ ] SlotBarWidget (상단 가로 바, Image 3)
  [ ] SlotItemWidget (배지 표시)
  [ ] SlotPopupWidget (슬라이딩)
  [ ] Realtime 구독
  [ ] 슬롯 D (캐치메뉴 운영OS) Agent 우선

Phase 2:
  [ ] 슬롯 A (배달앱) Agent
  [ ] 슬롯 B (멤버십) Agent
  [ ] 슬롯 C (AI 고객센터) Agent
  [ ] 플로팅 위치 드래그
  [ ] Android System Overlay

Phase 3:
  [ ] 슬롯 동적 추가 (+ 버튼)
  [ ] 본사 정책 기반 슬롯 배포
  [ ] 슬롯별 설정 화면
```

---

## 8. Open Issues

```text
- [ ] Android System Overlay 권한
  SYSTEM_ALERT_WINDOW 권한 필요
  Android 10+ 에서 제한 있음
  → POS 앱 내부 WebView 방식 대안 검토

- [ ] iOS 지원
  iOS 는 시스템 오버레이 불가
  → Catch Menu 앱 내 슬롯 컨테이너
  → 또는 POS 앱과 협력 필요

- [ ] POS 앱 종류별 비침범 영역 자동 감지
  POS 마다 핵심 조작 영역이 다름
  → 초기: 수동 위치 설정
  → 향후: AI 기반 POS 화면 분석 자동 감지

- [ ] 슬롯 특허 전략
  GPT 와 별도 진행 예정
  010620 SOP 가 기술 근거 자료
```
