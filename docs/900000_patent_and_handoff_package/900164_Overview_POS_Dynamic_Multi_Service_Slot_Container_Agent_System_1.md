# 900164_Overview_POS_Dynamic_Multi_Service_Slot_Container_Agent_System

Status: In_Progress
Lifecycle: Overview
Owner: TBD
Last Updated: 2026-06-21

---

## 0. Document Purpose

이 Overview 는 POS 동적 다중 서비스 슬롯 컨테이너 Agent 시스템의
구현 컨텍스트를 정의한다.

핵심 개념:

```text
표면: POS 화면 옆 슬롯 컨테이너 (A|B|C|+)
실체: 각 슬롯 뒤에 심어진 SlotContainerAgent

슬롯은 진입점이고 Agent 가 실체다.

마케팅 메시지:
  "더 넣는 게 아니라 더 정리합니다"
  "지저분한 POS 화면을 깔끔하게 정리합니다"
```

Related Logic:
  900165_Logic_POS_Dynamic_Multi_Service_Slot_Container_Agent_System.md
Related SOP:
  010620_SOP_POSDynamicMultiServiceSlotContainer
  010630_SOP_CatchMenu_CleanPOSScreen

---

## 1. 문제 정의

```text
현재 매장 POS 화면 (Image 1 스케치):
  배달앱 태블릿 여러 개
  멤버십 단말
  쿠폰 앱
  AI 고객센터
  운영 알림
  → 각각 따로 흩어져 있음
  → POS 화면 침범
  → 직원이 여기저기 확인해야 함
  → 알림 놓침 / 중복 확인 / 혼란

해결 (Image 2 스케치):
  POS 본 화면 = 그대로 유지
  우측 또는 원하는 위치에
  A/B/C/D/E/+ 슬롯바 분리 배치
  이벤트 없으면 화면 안 가림
  이벤트 있으면 슬라이딩 팝업
```

---

## 2. 슬롯 컨테이너 동작 원리

### 2.1 기본 상태

```text
슬롯바 최소화:
  아이콘만 표시 또는 완전 숨김
  POS 화면 100% 사용 가능
  화면 침범 없음

위치 옵션:
  우측 사이드바 (Image 2 기준)
  상단 바 (Image 3 기준: A|B|C|+)
  하단 바
  플로팅 (위치/크기 드래그 조절)
  POS 종류와 무관하게 작동
```

### 2.2 이벤트 발생 시

```text
배민 새 주문 수신
  → A 슬롯 배지 표시 (숫자)
  → 슬라이딩 팝업 (주문 요약 카드)
  → 직원이 확인/처리
  → 팝업 닫힘 → POS 화면 복귀

멤버십 알림
  → B 슬롯 배지
  → 팝업 (포인트 적립 확인)
  → 확인 후 닫힘

긴급 운영 이벤트
  → D 슬롯 강조 표시
  → 팝업 자동 확장 (SOP 안내 포함)
  → 직원 처리 완료 후 닫힘
```

### 2.3 슬롯 상태

```text
비활성:  숨김 또는 흐림
활성:    기본 아이콘
배지:    신규 이벤트 숫자
긴급:    강조 색상 + 진동
처리중:  스피너
완료:    정상 복귀
오류:    경고 색상
```

---

## 3. Agent 구조 (표면 아래 실체)

```text
[슬롯 A 아이콘] ← 직원이 보는 표면
      ↓
[슬롯 A Agent] ← 실제 동작
  서비스: 배달앱 (배민/요기요/쿠팡)
  역할:
    외부 주문 수신
    주문 상태 추적
    KDS 연동 (Patent 2)
    처리 완료 시 슬롯 정상화
    모든 이벤트 감사 로그

[슬롯 B Agent]
  서비스: 멤버십/쿠폰
  역할:
    포인트 적립 이벤트
    쿠폰 발행 알림
    등급 변경 알림
    catchmenu_store.membership

[슬롯 C Agent]
  서비스: AI 고객센터
  역할:
    고객 문의 수신
    SOP 자동 답변
    직원 확인 필요 시 알림
    sop_runbooks 연동

[슬롯 D Agent]
  서비스: 캐치메뉴 운영OS 코어
  역할:
    품절/재고/KDS 상태
    대기 호출
    결제 완료 → KDS COMMITTED
    운영 이벤트 (Patent A 연동)

[슬롯 E Agent]
  서비스: 추가 서비스 (POS Gateway 등)

[슬롯 +]
  신규 서비스 등록 시 자동 슬롯 생성
  계약/인증 완료 → Agent 자동 활성화
```

---

## 4. SlotContainerAgent 핵심 역할

```text
SlotContainerAgent 는 단순 메뉴바가 아니다.

통합 제어 역할:
  1. 슬롯별 서비스 상태 유지
  2. 외부 이벤트 수신 (Realtime)
  3. POS 주문 상태와 외부 주문 매칭
  4. 슬롯별 알림 우선순위 결정
  5. 직원 액션 필요 여부 판단
  6. SOP Agent 자동 호출
  7. AI 고객센터 응답 연결
  8. 서비스별 오류 격리
  9. 슬롯 추가/삭제/비활성화 관리
  10. POS 비침범 위치 제어
  11. 모든 이벤트 catchmenu_ledger 기록

이벤트 우선순위:
  Level 1: 결제 장애 / 시스템 오류
  Level 2: 배달앱 신규 주문 (시간 민감)
  Level 3: KDS 지연 / 품절
  Level 4: 고객 문의 / 멤버십
  Level 5: 일반 운영 알림
```

---

## 5. Flutter 구현 대상

### 5.1 핵심 위젯

```text
SlotContainerWidget
  Android: System Overlay (SYSTEM_ALERT_WINDOW)
           모든 앱 위에 올라감
           POS 앱 종류 무관
  iOS:     POS 앱 내 WebView 또는
           Catch Menu 앱 내 오버레이

SlotBarWidget
  가로 바 또는 세로 바
  슬롯 목록 렌더링
  배지 표시

SlotPopupWidget
  슬라이딩 애니메이션
  이벤트 요약 카드
  확인/처리 버튼
  자동 닫힘 타이머 (선택)

SlotFloatingWidget
  드래그로 위치 이동
  핀치로 크기 조절
  POS 화면 비침범 위치 고정 옵션
```

### 5.2 Realtime 연동

```text
Supabase Realtime 채널:
  slot:{store_id}
  → slot_event_created
  → slot_badge_updated
  → slot_popup_trigger
  → slot_resolved

이벤트 수신 시:
  해당 슬롯 배지 갱신
  팝업 조건 충족 시 자동 팝업
  직원 확인 후 resolved 처리
```

---

## 6. DB 테이블 맵

| 테이블 | 역할 |
|---|---|
| catchmenu_store.slot_container_configs | 슬롯 설정 (위치/크기/서비스) |
| catchmenu_store.slot_events | 슬롯 이벤트 원장 |
| catchmenu_store.slot_agent_states | Agent 별 상태 |
| catchmenu_integrations.delivery_configs | 배달앱 연동 설정 |
| catchmenu_common.sop_runbooks | SOP 연동 |
| catchmenu_ledger.events | 전체 감사 원장 |

---

## 7. 기존 특허와의 차이

```text
기존 플로팅 메뉴 / 앱 바로가기:
  고정된 목록
  단순 앱 실행
  POS 연동 없음
  이벤트 감지 없음

SlotContainerAgent:
  서비스 추가 시 슬롯 동적 생성
  POS/KDS/배달앱 상태 실시간 연동
  이벤트 우선순위 자동 결정
  SOP/AI Agent 자동 연결
  모든 이벤트 감사 로그
  이벤트 없으면 화면 완전 비침범

핵심 차별점:
  "슬롯은 진입점이고 Agent 가 실체"
  표면은 정리 도구, 내부는 운영OS
```

---

## 8. 마케팅 연결

```text
영업 메시지:
  "POS 화면이 지저분하신가요?
   배달앱, 멤버십, 고객센터가 따로따로 오신가요?
   캐치메뉴 하나로 깔끔하게 정리해드립니다"

기술 실체:
  슬롯 뒤에 Agent 가 심어져서
  모든 서비스가 캐치메뉴 운영OS 로 연결됨
  표면의 단순함 = 내부의 복잡한 통합

경쟁사 진입 장벽:
  "저 회사는 아이콘 몇 개 붙인 거잖아"
  → 따라 만들려면 캐치메뉴 전체를 만들어야 함
```

---

## 9. Related Documents

| 문서 | 역할 |
|---|---|
| 900100~900103 | Patent 1+2 핵심 |
| 900160~900161 | Patent A+B+C 운영 이벤트 제어 |
| 900164: 이 문서 | 슬롯 컨테이너 Agent Overview |
| 900165 | 슬롯 컨테이너 Agent Logic |
| 010620 SOP | 기술 운영 기준 |
| 010630 SOP | 마케팅 메시지 기준 |
