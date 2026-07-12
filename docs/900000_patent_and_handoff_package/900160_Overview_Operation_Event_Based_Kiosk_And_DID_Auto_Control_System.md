# 900160_Overview_Operation_Event_Based_Kiosk_And_DID_Auto_Control_System

Status: In_Progress
Lifecycle: Overview
Owner: TBD
Last Updated: 2026-06-21

---

## 0. Document Purpose

This Overview maps the implementation context for the
Operation Event Based Kiosk and DID Auto Control System.

This is NOT an advertising CMS system.
This is an operational OS that reacts to real-time store events.

특허 전략의 핵심:

```text
기존 특허가 선점한 영역:
  "화면을 누가 어떻게 나누나" (광고 CMS)
  본사 광고 + 가맹점 광고 화면 분할
  시간대별 콘텐츠 스케줄링

캐치메뉴의 특허 영역:
  "매장에 무슨 일이 생겼을 때 화면이 어떻게 반응하나"
  운영 이벤트 → 키오스크/DID 자동 전환
  POS/KDS/재고/대기열/결제 상태 연동
  SOP 기반 자동 의사결정
```

Related Logic: 900161_Logic_Operation_Event_Based_Kiosk_And_DID_Auto_Control_System.md

---

## 1. 시스템 정의

```text
시스템명: 운영 이벤트 기반 키오스크·DID 자동 제어 시스템
영문명:   Operation Event Based Kiosk and DID Auto Control System

핵심 개념:
  매장에서 발생하는 운영 이벤트(품절, 재고 부족,
  조리 지연, 결제 장애, 대기 호출, 인력 부족 등)를
  실시간으로 감지하고, 이벤트의 심각도와 SOP에 따라
  키오스크 주문 화면, DID 안내 화면, 메뉴 노출 상태,
  고객 안내 문구를 자동으로 전환하는 시스템.

기존 광고 CMS와의 차이:
  광고 CMS: 누가 어떤 광고를 언제 보여주나
  이 시스템: 매장에 무슨 일이 생겼을 때 무엇을 보여주나
```

---

## 2. 특허 후보 3개

### Patent A: 운영 이벤트 기반 키오스크·DID 자동 전환

```text
핵심 클레임:
  POS, KDS, 재고, 대기열, 결제 시스템에서
  발생하는 운영 이벤트를 감지하여
  키오스크와 DID 화면을 자동 전환하는 방법

이벤트 → 자동 반응 예시:

  재고 부족 이벤트:
    update_inventory(qty=0)
    → menus.menu_status = 'SOLD_OUT'
    → 키오스크: 해당 메뉴 비활성화/숨김
    → DID: "해당 메뉴 조기 소진" 안내
    → 대체 메뉴 자동 추천 표시
    → POS/KDS/고객앱 동일 상태 반영
    → operation_alerts 이벤트 로그

  대기 호출 이벤트:
    call_waiting_customer()
    → DID: 호출 번호 대형 표시
    → 고객앱: 푸시 알림
    → 키오스크: 대기 현황 업데이트

  결제 완료 이벤트 (Patent 2 연동):
    confirm_payment()
    → KDS: HOLD → COMMITTED 자동 전환
    → DID: 주문 접수 완료 표시
    → 키오스크: 다음 고객 대기 화면

  조리 지연 이벤트:
    kds_tickets.is_late = true
    → DID: 예상 대기 시간 안내
    → 키오스크: 대기 시간 경고 표시
    → 신규 주문 제한 권고

  매장 혼잡 이벤트:
    change_store_mode('BUSY')
    → 키오스크: 대기 안내 강조
    → DID: 예상 대기 시간 표시
    → 일부 메뉴 주문 제한 옵션

선행 특허와의 차이:
  기존: 시간대별 광고 스케줄링 (사람이 설정)
  우리: 운영 이벤트 실시간 감지 (시스템 자동)
```

---

### Patent B: 본사-가맹점 권한 충돌 방지형 운영 오버라이드

```text
핵심 클레임:
  운영 이벤트의 종류에 따라
  본사 권한, 가맹점 권한, 시스템 자동 권한,
  SOP 권한이 다르게 작동하고,
  충돌 시 화면 송출·주문 가능 여부·메뉴 노출·
  고객 안내 문구를 자동 결정하는 구조

운영 우선순위 (광고 우선순위 아님):

  Level 1: 안전/결제 장애/영업 중단
    → 시스템 자동 권한
    → 가맹점/본사 개입 없이 즉시 전환
    → SOP-PAY-001, SOP-SYS-002 자동 발동

  Level 2: 본사 긴급 공지
    → 본사 권한
    → 모든 가맹점 화면 강제 오버라이드
    → send_hq_notice(severity='EMERGENCY')

  Level 3: 품절/재고/조리 지연
    → 시스템 자동 권한 또는 가맹점 권한
    → 해당 매장만 적용
    → 본사 승인 없이 가맹점 자체 처리 가능

  Level 4: 매장 로컬 이벤트
    → 가맹점 권한
    → 본사 템플릿 범위 내

  Level 5: 일반 광고/CMS 콘텐츠
    → 본사 또는 가맹점 스케줄
    → 기존 광고 CMS 영역

  Level 6: 대기 화면/기본 화면
    → 시스템 기본값

충돌 해소 규칙:
  상위 Level 이벤트 발생 시 하위 자동 중단
  해소 후 원래 상태로 자동 복구
  전환 이력과 복구 로그 감사 가능하게 저장

선행 특허와의 차이:
  기존: 본사 광고 우선 = 가맹점 광고 덮어씀
  우리: 운영 심각도 기준 자동 중재
        광고가 아니라 운영 상태로 우선순위 결정
```

---

### Patent C: AI SOP 연동형 운영 지식 자동 생성·배포

```text
핵심 클레임:
  고객 문의, 운영 이벤트, 반복 패턴을 분석하여
  SOP를 자동 생성하고,
  생성된 SOP가 키오스크·DID·고객센터에
  동시 반영되는 시스템

흐름:

  1. 고객이 키오스크에서 "왜 이 메뉴 안 되나요?" 문의
  2. AI 고객센터가 품절 이벤트/재고 로그/KDS 상태 확인
  3. 기존 SOP로 즉시 답변
     → 키오스크 화면: 안내 문구 자동 표시
     → DID: 품절 안내 자동 추가

  4. 같은 유형 문의 5회 이상 반복 감지
     detect_recurring_inquiries()
     → sop_evolution_log: 신규 SOP 후보 생성

  5. 가맹점/본부 승인
     → 승인된 SOP가 즉시 반영:
        키오스크 안내 문구 업데이트
        DID 공지 업데이트
        고객센터 자동 답변 업데이트
        전 가맹점 동시 배포 가능

선행 특허와의 차이:
  기존: 사람이 SOP 작성 → 수동 배포
  우리: AI가 반복 패턴 감지 → SOP 자동 생성
        → 운영 디스플레이 자동 반영
        이것이 Patent 3 (AI 자가진화 SOP)
```

---

## 3. 관련 Migration 파일

| Migration | 관련 내용 |
|---|---|
| 0099 | Realtime 채널, broadcast_store_event |
| 0100 | change_store_mode, open_store, close_store |
| 0114 | kiosk_configs, kiosk_sessions, bootstrap_kiosk |
| 0115 | register_waiting, call_waiting_customer |
| 0117 | bootstrap_did_app, did_display_queue |
| 0119 | edge_function_configs |
| 0122 | create_coupon, apply_coupon_to_order |
| 0123 | submit_customer_inquiry, detect_recurring_inquiries, sop_evolution_log |
| 0124 | update_inventory, get_inventory_dashboard |
| 0125 | run_compliance_check, send_hq_notice |
| 0128 | did_devices, did_display_queue, run_opening_checklist |
| 0129 | collect_hourly_metrics, SOP-OPS-001~004 |

---

## 4. 핵심 RPC 맵

### 4.1 운영 이벤트 감지

| 이벤트 | 감지 RPC | 트리거 조건 |
|---|---|---|
| 품절 | update_inventory | current_qty <= 0 |
| 재고 부족 | update_inventory | current_qty <= min_qty |
| 조리 지연 | transition_kds_ticket | elapsed > threshold |
| 대기 초과 | pg_cron WAITING_SESSION_EXPIRE | 15분 무응답 |
| 매장 혼잡 | change_store_mode | 수동 또는 자동 |
| 결제 장애 | record_van_transaction | FAILED/TIMEOUT |
| 본사 긴급 | send_hq_notice | severity=EMERGENCY |
| SOP 발동 | detect_recurring_inquiries | 5회+ 반복 |

### 4.2 화면 자동 전환

| 이벤트 → | 키오스크 반응 | DID 반응 | 고객앱 반응 |
|---|---|---|---|
| 품절 | 메뉴 비활성화 | 품절 안내 | 메뉴 제거 |
| 대기 호출 | 대기 현황 갱신 | 호출 번호 표시 | 푸시 알림 |
| 결제 완료 | 다음 대기 화면 | 호출 해제 | 조리 중 표시 |
| 매장 혼잡 | 대기 안내 강조 | 대기 시간 표시 | 혼잡 안내 |
| 결제 장애 | 결제 불가 안내 | 현금 안내 | 재시도 안내 |
| 본사 긴급 | 긴급 공지 전면 | 긴급 공지 전면 | 긴급 알림 |
| SOP 발동 | 안내 문구 갱신 | 공지 갱신 | 답변 갱신 |

---

## 5. DB 테이블 맵

| 테이블 | 역할 |
|---|---|
| catchmenu_pos.menus | 메뉴 상태 (AVAILABLE/SOLD_OUT) |
| catchmenu_store.inventory_items | 재고 수량 |
| catchmenu_kds.kds_tickets | KDS 상태 (HOLD/COMMITTED/COOKING) |
| catchmenu_pos.order_sessions | 대기 세션 상태 |
| catchmenu_store.did_display_queue | DID 호출 큐 |
| catchmenu_store.did_devices | DID 디바이스 설정 |
| catchmenu_store.kiosk_configs | 키오스크 설정 |
| catchmenu_common.operation_alerts | 운영 알림 원장 |
| catchmenu_common.sop_runbooks | SOP 런북 |
| catchmenu_knowledge.sop_evolution_log | AI 자가진화 SOP 로그 |
| catchmenu_hq.hq_notices | 본부 공지 |
| catchmenu_store.store_settings | 매장 모드 설정 |
| catchmenu_ledger.events | 전환 이력 감사 원장 |

---

## 6. Realtime 채널 맵

| 채널 | 이벤트 | 수신 디바이스 |
|---|---|---|
| waiting:{store_id} | waiting_called, seated | DID, 고객앱, 직원앱 |
| kds:{store_id} | kds_tickets_released, kds_ticket_updated | KDS, 직원앱 |
| did:{store_id} | WAITING_CALL, call_dismissed | DID |
| store:{store_id} | menu_status_changed, store_mode_changed | 키오스크, 고객앱 |
| staff:{store_id} | hq_notice_received, operation_alert | 직원앱 |

---

## 7. 기존 광고 CMS 특허와의 차별화 요약

| 항목 | 기존 광고 CMS 특허 | 캐치메뉴 운영 OS |
|---|---|---|
| 제어 트리거 | 시간대 스케줄 (사람 설정) | 운영 이벤트 (시스템 자동 감지) |
| 화면 전환 기준 | 광고 우선순위 | 운영 심각도 |
| 우선순위 결정 | 본사 vs 가맹점 | 안전 > 장애 > 품절 > 광고 |
| 연동 시스템 | 없음 (광고만) | POS, KDS, 재고, 대기, 결제 |
| 로그 | 광고 노출 로그 | 운영 이벤트 감사 원장 |
| SOP | 없음 | AI 자가진화 SOP 연동 |
| 복구 | 없음 | 이벤트 해소 후 자동 복구 |

---

## 8. 변리사 전달용 핵심 문장

```text
본 발명은 프랜차이즈 본사와 가맹점이 각각
콘텐츠 제어 권한을 가지는 계층형 CMS 환경에서,
단순 광고 스케줄이 아니라
POS, KDS, 재고, 주문, 대기열, 결제, 장애, 품절,
조리 지연 등의 매장 운영 이벤트를 감지하고,
해당 이벤트의 심각도와 디지털 SOP에 따라
키오스크 및 디지털 사이니지의 화면 구성,
주문 가능 메뉴, 고객 안내 문구,
광고 슬롯, 로컬 오버라이드 권한을 자동으로 조정하며,
그 조정 이력과 승인·복구 로그를 저장하는
시스템 및 방법에 관한 것이다.
```

---

## 9. 특허 출원 전 준비 사항

```text
이 문서가 변리사에게 가져갈 근거 자료다.

준비 완료:
  900100: Patent 1+2 Overview
  900101: Patent 1+2 Logic
  900160: Patent A+B+C Overview (이 문서)
  900161: Patent A+B+C Logic (다음 문서)
  DB migration 0001~0138

변리사에게 제출할 순서:
  1. 900101 Logic (Patent 1+2 구현 증빙)
  2. 900160 Overview (새 특허 방향)
  3. 900161 Logic (새 특허 상세 로직)
  4. DB 스키마 덤프 (구현 증빙)
  5. run_integration_test 결과 (Patent 2 동작 증빙)

출원 명칭 후보:
  1안: 프랜차이즈 매장 운영 이벤트 기반
       키오스크 및 디지털 사이니지
       계층형 자동 제어 시스템

  2안: POS·KDS·재고·대기열 연동
       운영 상태 기반 키오스크 및
       디지털 사이니지 화면 전환 방법

  3안: 디지털 SOP 연동형 프랜차이즈 매장
       디스플레이 자동 오버라이드 시스템
```

---

## 10. Related Documents

| 문서 | 역할 |
|---|---|
| 900100: Overview Patent 1+2 | Wait/Order Handoff + KDS Late Binding |
| 900101: Logic Patent 1+2 | 상태 머신 + 제어 로직 |
| 900102: ChangeContract | Codex 구현 경계 |
| 900103: TestPlan | 검증 계획 |
| 900150: Phase Validation Plan | 단계별 검증 |
| 900161: Logic (이 문서의 Logic) | Patent A+B+C 상세 로직 |
